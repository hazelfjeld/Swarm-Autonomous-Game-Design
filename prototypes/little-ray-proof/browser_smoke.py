"""Real Chromium click-path smoke for the isolated Little Ray demo.

Automated browser evidence, NOT a human playtest or GDD acceptance.
The test clock accelerates the breeding/hatch timers.
"""
from pathlib import Path
import json
import os
from playwright.sync_api import sync_playwright

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


def open_game(context):
    page = context.new_page()
    page.add_init_script("""(() => {
       const realNow = Date.now.bind(Date);
       window.__littleRayTestNow = realNow();
       Date.now = () => window.__littleRayTestNow;
       window.advanceDemoClock = (seconds) => {
           window.__littleRayTestNow += seconds * 1000;
           window.LittleRayDebug.render();
       };
    })();""")
    page.goto(INDEX.as_uri(), wait_until="load")
    check(page.locator("#heading").inner_text() == "The Sunlit Reef", "Island heading renders")
    return page


def advance(page, seconds):
    page.evaluate("(seconds) => window.advanceDemoClock(seconds)", seconds)


def desktop_journey(browser):
    context = browser.new_context(viewport={"width": 1280, "height": 900})
    page = open_game(context)
    errors = []
    page.on("pageerror", lambda error: errors.append(str(error)))
    try:
        check(len(state(page)["rays"]) == 2, "Two starter rays")
        page.locator('#nav [data-view="rays"]').click()
        for ray in (1, 2):
            for _ in range(2):
                page.locator(f'#view [data-act="feed"][data-i="{ray}"]').click()
        check([ray["lv"] for ray in state(page)["rays"]] == [4, 4], "Founders level to four via clicks")
        page.locator('#nav [data-view="nursery"]').click()
        page.locator('#view [data-act="breed"]').click()
        check(state(page)["breed"]["kind"] == "pearlcloud", "First pairing commits Pearlcloud")
        advance(page, 19)
        page.locator('#view [data-act="transfer"]').click()
        check(state(page)["hatch"]["kind"] == "pearlcloud", "Egg transferred to separate hatchery")
        advance(page, 15)
        page.locator('#view [data-act="claim"]').click()
        check(len(state(page)["rays"]) == 3, "Hatching grants exactly one ray")
        page.locator('#nav [data-view="battle"]').click()
        page.locator('#view [data-act="startBattle"]').click()
        for _ in range(20):
            if state(page)["battle"]["finished"]:
                break
            page.locator('#view [data-act="special"]').click()
        check(state(page)["battle"]["won"] is True, "3v3 encounter won through UI buttons")
        page.locator('#view [data-act="endBattle"]').click()
        page.locator('#view [data-act="expand"]').click()
        check(state(page)["land"] == 5, "Island sector purchased through UI")
        before = state(page)
        page.reload(wait_until="load")
        after = state(page)
        check(after["land"] == before["land"] and len(after["rays"]) == 3, "Island and rays persist across browser reload")
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
    page = open_game(context)
    try:
        page.locator('#view [data-act="plant"][data-i="0"]').tap()
        check(state(page)["crops"][0] is not None, "Touch planting works at mobile viewport")
        page.locator('#nav [data-view="rays"]').tap()
        check(page.locator('#view .raycard').count() == 2, "Mobile ray roster is visible")
        page.screenshot(path=str(OUT / "mobile.png"), full_page=True)
        print("MOBILE_BROWSER_PASS")
    except Exception:
        page.screenshot(path=str(OUT / "mobile-failure.png"), full_page=True)
        raise
    finally:
        context.close()


def main():
    check(INDEX.exists(), "Exact prototype HTML exists")
    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(headless=True)
        try:
            desktop_journey(browser)
            mobile_journey(browser)
        finally:
            browser.close()
    print("Automated Chromium smoke passed; human playtesting and production GDD remain unverified.")


if __name__ == "__main__":
    main()
