"""Real Chromium click-path smoke for the isolated Little Ray demo.

Automated browser evidence, NOT a human playtest or GDD acceptance.
The desktop journey uses ordinary real-time timers; no game-state mutation or debug render.
"""
from pathlib import Path
import json
import os
import shutil
from playwright.sync_api import expect, sync_playwright

HERE = Path(__file__).resolve().parent
INDEX = HERE / "index.html"
OUT = Path(os.environ.get("LITTLE_RAY_EVIDENCE", str(HERE / "evidence"))).resolve()
OUT.mkdir(parents=True, exist_ok=True)


def check(condition, description):
    if not condition:
        raise AssertionError(description)
    print("PASS:", description)


def state(page):
    return page.evaluate("window.LittleRayDebug.getState()")


def open_game(context, errors=None):
    page = context.new_page()
    if errors is not None:
        page.on("pageerror", lambda error: errors.append(str(error)))
    page.goto(INDEX.as_uri(), wait_until="load")
    check(page.locator("#heading").inner_text() == "The Sunlit Reef", "Island heading renders")
    return page


def desktop_journey(browser):
    context = browser.new_context(viewport={"width": 1280, "height": 900})
    errors = []
    page = open_game(context, errors)
    try:
        check(len(state(page)["rays"]) == 2, "Two starter rays")
        check(page.locator('[data-sector-state="owned"]').count() == 4 and page.locator('[data-sector-state="next"]').count() == 1, "Fresh island draws four owned sectors and one highlighted frontier")
        expect(page.locator('#view [data-act="expand"]')).to_be_disabled()
        collect = page.locator('#view [data-act="collect"]')
        initial_gold = state(page)["gold"]
        expect(collect).to_be_enabled(timeout=10000)
        collect.click()
        after_collect = state(page)["gold"]
        check(after_collect > initial_gold, "Resident Gold accrues in real time and is collected by click")
        initial_food = state(page)["food"]
        for plot in (0, 1):
            page.locator(f'#view [data-act="plant"][data-i="{plot}"]').click()
        check(state(page)["gold"] == after_collect - 80, "Both plots charge their planting cost exactly once")
        check(state(page)["food"] == initial_food, "Planting grants no premature Food")
        expect(page.locator('#view [data-crop="0"]')).to_be_disabled()
        # Reload a growing crop, not just the finished city. No clock injection.
        deadlines = [crop["until"] for crop in state(page)["crops"]]
        page.reload(wait_until="load")
        check([crop["until"] for crop in state(page)["crops"]] == deadlines, "Both growing crop deadlines survive reload")
        for plot in (0, 1):
            harvest = page.locator(f'#view [data-act="harvest"][data-i="{plot}"]')
            expect(harvest).to_be_enabled(timeout=20000)
            harvest.click()
        check(state(page)["food"] == initial_food + 130 and state(page)["crops"] == [None, None],
              "Both crops mature on real timers and grant Food once")
        page.locator('#nav [data-view="rays"]').click()
        feed = page.locator('#view [data-act="feed"][data-i="1"]')
        feed.focus()
        tick_before = state(page)["lastTick"]
        page.wait_for_function("(before) => window.LittleRayDebug.getState().lastTick > before", arg=tick_before)
        expect(feed).to_be_focused()
        check(True, "Keyboard focus survives a real idle timer tick")
        for ray in (1, 2):
            for _ in range(2):
                page.locator(f'#view [data-act="feed"][data-i="{ray}"]').click()
        check([ray["lv"] for ray in state(page)["rays"]] == [4, 4], "Founders level to four via clicks")
        page.locator('#nav [data-view="nursery"]').click()
        page.locator('#view [data-act="breed"]').click()
        check(state(page)["breed"]["kind"] == "pearlcloud", "First pairing commits Pearlcloud")
        transfer = page.locator('#view [data-act="transfer"]')
        expect(transfer).to_be_disabled()
        expect(transfer).to_be_enabled(timeout=25000)
        transfer.click()
        check(state(page)["hatch"]["kind"] == "pearlcloud", "Egg transferred to separate hatchery")
        claim = page.locator('#view [data-act="claim"]')
        expect(claim).to_be_disabled()
        expect(claim).to_be_enabled(timeout=20000)
        claim.click()
        check(len(state(page)["rays"]) == 3, "Hatching grants exactly one ray")
        page.locator('#nav [data-view="rays"]').click()
        for _ in range(6):
            page.locator('#view [data-act="feed"][data-i="3"]').click()
        check(state(page)["rays"][2]["lv"] == 4, "Hatched Pearlcloud trained to level four through UI")
        page.locator('#nav [data-view="battle"]').click()
        page.locator('#view [data-act="startBattle"]').click()
        enemy = page.locator('#view [data-act="target"][data-i="1"]')
        enemy.focus()
        enemy.press("Enter")
        check(state(page)["battle"]["target"] == 1, "Keyboard selects a rival in 3v3 battle")
        for _ in range(20):
            if state(page)["battle"]["finished"]:
                break
            page.locator('#view [data-act="special"]').click()
        check(state(page)["battle"]["won"] is True, "3v3 encounter won through UI buttons")
        page.locator('#view [data-act="endBattle"]').click()
        wallet_before = state(page)["gold"]
        page.screenshot(path=str(OUT / "island-before-expansion.png"), full_page=True)
        page.locator('#view [data-act="expand"]').click()
        check(state(page)["land"] == 5 and state(page)["gold"] == wallet_before - 200, "Island sector purchased through map control with exact debit")
        check(page.locator('[data-sector="4"][data-sector-state="owned"]').count() == 1 and page.locator('[data-sector="5"][data-sector-state="next"]').count() == 1 and page.locator('[data-sector-state="owned"]').count() == 5, "Purchased terrain appears and frontier advances on actual rendered map")
        before = state(page)
        page.reload(wait_until="load")
        after = state(page)
        check(all(after[key] == before[key] for key in ("land", "rays", "gold", "food", "battles", "crops")),
              "Island, individual levels, currencies, battle count and crops persist across browser reload")
        check(page.locator('[data-sector="4"][data-sector-state="owned"]').count() == 1 and page.locator('[data-sector-state="owned"]').count() == 5, "Purchased map tile remains visible after reload")
        check(not errors, "No uncaught JavaScript errors")
        page.screenshot(path=str(OUT / "desktop.png"), full_page=True)
        print("DESKTOP_BROWSER_PASS", json.dumps({"rays": len(after["rays"]), "land": after["land"], "battles": after["battles"]}))
    except Exception:
        page.screenshot(path=str(OUT / "desktop-failure.png"), full_page=True)
        print("PAGE_ERRORS", errors)
        raise
    finally:
        context.close()


def mobile_journey(browser):
    context = browser.new_context(viewport={"width": 390, "height": 844}, device_scale_factor=2, has_touch=True, is_mobile=True)
    errors = []
    page = open_game(context, errors)
    try:
        check(page.locator('[data-sector-state="owned"]').count() == 4, "Fresh sector map renders on mobile")
        check(page.locator(".map-toolbar").bounding_box()["width"] <= 390, "Map controls fit the mobile viewport")
        page.locator('#view [data-act="plant"][data-i="0"]').tap()
        check(state(page)["crops"][0] is not None, "Touch planting works at mobile viewport")
        page.locator('#nav [data-view="rays"]').tap()
        check(page.locator('#view .raycard').count() == 2, "Mobile ray roster is visible")
        page.screenshot(path=str(OUT / "mobile.png"), full_page=True)
        check(not errors, "No uncaught mobile JavaScript errors")
        print("MOBILE_BROWSER_PASS")
    except Exception:
        page.screenshot(path=str(OUT / "mobile-failure.png"), full_page=True)
        raise
    finally:
        context.close()


def main():
    check(INDEX.exists(), "Exact prototype HTML exists")
    with sync_playwright() as playwright:
        chrome = shutil.which("google-chrome") or shutil.which("chromium") or shutil.which("chromium-browser")
        browser = playwright.chromium.launch(headless=True, executable_path=chrome)
        try:
            desktop_journey(browser)
            mobile_journey(browser)
        finally:
            browser.close()
    print("Automated Chromium smoke passed; human playtesting and production GDD remain unverified.")


if __name__ == "__main__":
    main()
