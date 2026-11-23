#!/usr/bin/env python3
"""Rebuild original disposable ART-001 format probes; never production game art."""
import hashlib
import json
import math
import struct
import subprocess
import sys
import wave
from pathlib import Path

from PIL import Image, ImageDraw, __version__ as PILLOW_VERSION

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "reports/capabilities/samples/art-audio"
REL = OUT.relative_to(ROOT).as_posix()
COMMANDS = []


def run(args):
    COMMANDS.append(args)
    return subprocess.run(args, cwd=ROOT, check=True, capture_output=True, text=True).stdout


def checksum(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def image_info(name):
    with Image.open(OUT / name) as im:
        info = {"format": im.format, "mode": im.mode, "size": list(im.size)}
        info["frames"] = getattr(im, "n_frames", 1)
        delays = []
        for i in range(info["frames"]):
            im.seek(i)
            if "duration" in im.info:
                delays.append(im.info["duration"])
        if delays:
            info["frame_duration_ms"] = delays
            info["loop_duration_ms"] = sum(delays)
        return info


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "sample.svg").write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">\n'
        '  <title>Disposable ART-001 original geometry capability sample</title>\n'
        '  <circle cx="32" cy="32" r="20" fill="#787878" stroke="#262626" stroke-width="2"/>\n'
        '  <path d="M32 24 L40 32 L32 40 L24 32 Z" fill="#e1e1e1"/>\n'
        '</svg>\n', encoding="utf-8")
    run(["inkscape", f"{REL}/sample.svg", "--export-type=png",
         f"--export-filename={REL}/sample.png"])
    with Image.open(OUT / "sample.png") as im:
        im.load()
        assert im.mode == "RGBA" and im.size == (64, 64)
        assert im.getchannel("A").getextrema() == (0, 255)

    frames = []
    for radius in (10, 12, 15, 18, 20, 18, 15, 12):
        frame = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
        draw = ImageDraw.Draw(frame)
        draw.ellipse((32-radius, 32-radius, 32+radius, 32+radius),
                     fill=(120, 120, 120, 255), outline=(38, 38, 38, 255), width=2)
        draw.polygon(((32, 27), (37, 32), (32, 37), (27, 32)), fill=(225, 225, 225, 255))
        assert frame.getchannel("A").getbbox()[0] >= 12
        frames.append(frame)
    strip = Image.new("RGBA", (512, 64))
    for i, frame in enumerate(frames):
        strip.paste(frame, (64*i, 0))
    strip.save(OUT / "frame-strip.png")
    frames[0].save(OUT / "pulse.apng", format="PNG", save_all=True, append_images=frames[1:],
                   duration=125, loop=0, disposal=0, blend=0)
    gif_frames = []
    palette = [0, 0, 0, 120, 120, 120, 38, 38, 38, 225, 225, 225] + [0]*756
    colors = {(0, 0, 0, 0): 0, (120, 120, 120, 255): 1,
              (38, 38, 38, 255): 2, (225, 225, 225, 255): 3}
    for frame in frames:
        indexed = Image.new("P", (64, 64))
        indexed.putpalette(palette)
        indexed.putdata([colors[frame.getpixel((x, y))] for y in range(64) for x in range(64)])
        gif_frames.append(indexed)
    gif_frames[0].save(OUT / "pulse.gif", save_all=True, append_images=gif_frames[1:],
                      duration=[120, 130]*4, loop=0, transparency=0, disposal=2, optimize=False)
    assert image_info("pulse.apng")["frame_duration_ms"] == [125.0]*8
    assert image_info("pulse.gif")["frame_duration_ms"] == [120, 130]*4
    assert image_info("frame-strip.png")["size"] == [512, 64]

    samples = [round(0.08*32767*math.sin(math.pi*i/23999)**2 *
                     math.sin(2*math.pi*440*i/48000)) for i in range(24000)]
    with wave.open(str(OUT / "cue.wav"), "wb") as wav:
        wav.setparams((1, 2, 48000, 0, "NONE", "not compressed"))
        wav.writeframes(struct.pack("<24000h", *samples))
    run(["ffmpeg", "-v", "error", "-y", "-i", f"{REL}/cue.wav", "-map_metadata", "-1",
         "-fflags", "+bitexact", "-flags:a", "+bitexact", "-c:a", "libvorbis", "-q:a", "4",
         f"{REL}/cue.ogg"])
    audio = {}
    for name, codec in (("cue.wav", "pcm_s16le"), ("cue.ogg", "vorbis")):
        probe = json.loads(run(["ffprobe", "-v", "error", "-show_streams", "-show_format",
                                "-of", "json", f"{REL}/{name}"]))
        stream = probe["streams"][0]
        assert stream["codec_name"] == codec and stream["sample_rate"] == "48000"
        assert stream["channels"] == 1 and abs(float(probe["format"]["duration"])-0.5) < 0.001
        run(["ffmpeg", "-v", "error", "-i", f"{REL}/{name}", "-f", "null", "-"])
        audio[name] = {"codec": codec, "sample_rate_hz": 48000, "channels": 1,
                       "duration_seconds": float(probe["format"]["duration"])}
    audio["cue.wav"].update({"pcm_bits": 16, "samples": len(samples),
                             "peak_absolute_pcm": max(map(abs, samples)), "frequency_hz": 440})
    assert samples[0] == samples[-1] == 0 and max(map(abs, samples)) < 32767

    preview = Image.new("RGB", (576, 256), "#f0f0f0")
    draw = ImageDraw.Draw(preview)
    draw.text((16, 12), "DISPOSABLE CAPABILITY SAMPLE - not Little Ray art", fill="#202020")
    for y in range(40, 168, 16):
        for x in range(16, 144, 16):
            draw.rectangle((x, y, x+15, y+15), fill="#cccccc" if (x//16+y//16)%2 else "#ffffff")
    with Image.open(OUT / "sample.png") as im:
        preview.paste(im.resize((128, 128)), (16, 40), im.resize((128, 128)))
    draw.text((160, 48), "Original neutral SVG -> RGBA PNG", fill="#202020")
    draw.text((160, 68), "8 original geometry frames; no game-style decision", fill="#202020")
    draw.text((160, 88), "APNG: 125 ms/frame; GIF: alternating 120/130 ms", fill="#202020")
    draw.text((160, 108), "Audio: quiet 0.5 s synthetic tone; WAV + Ogg", fill="#202020")
    preview.paste(strip, (16, 180), strip)
    preview.save(OUT / "preview.png")
    (OUT / "README.md").write_text(
        "# Disposable ART-001 capability samples\n\n"
        "Original neutral geometry and synthetic audio created for format/export verification. "
        "These are not Little Ray assets, style trials, palette choices, or runtime requirements. "
        "Do not import them as game content.\n\n"
        "Reproduce from the repository root (Python with Pillow, Inkscape, FFmpeg/FFprobe):\n\n"
        "    python3 scripts/art_audio_capability_sample.py\n\n"
        "The script rewrites only its named disposable outputs in this directory. "
        "No network or generation service is used. The manifest records hashes, actual decoded "
        "formats, command arguments, versions, and source provenance.\n\n"
        "- sample.svg / sample.png: editable original geometry and transparent 64x64 export.\n"
        "- frame-strip.png: eight 64x64 cells, left to right, center pivot (32,32), transparent padding.\n"
        "- pulse.apng: eight frames at 125 ms, one-second loop, full-frame source replacement.\n"
        "- pulse.gif: GIF's 10 ms precision needs alternating 120/130 ms delays for the same "
        "one-second loop; indexed transparency and disposal-to-background.\n"
        "- cue.wav / cue.ogg: 0.5 seconds, 48 kHz mono, 440 Hz with a smooth envelope. "
        "PCM WAV is 16-bit; Ogg is lossy Vorbis. Decode/metadata checked; no listening claim.\n"
        "- preview.png: static review sheet; animated playback and engine import are unverified.\n\n"
        "Provenance: original assistant-authored geometry, timing, and synthesized waveform; "
        "no third-party assets or references. The script and samples were created for this "
        "authorized repository work; no external license is introduced or claimed. "
        "Existing repository terms apply. These files do not establish rights for other assets.\n",
        encoding="utf-8")
    names = ["sample.svg", "sample.png", "frame-strip.png", "pulse.apng", "pulse.gif",
             "cue.wav", "cue.ogg", "preview.png", "README.md"]
    manifest = {"schema_version": 1, "task": "ART-001", "disposable": True,
                "purpose": "Format/export capability evidence only; no game art direction",
                "source": {"path": "scripts/art_audio_capability_sample.py",
                           "sha256": checksum(Path(__file__)), "provenance": "Original assistant-authored geometry and synthesis; no third-party assets"},
                "reproduce": "python3 scripts/art_audio_capability_sample.py",
                "animation": {"cell_px": [64, 64], "pivot_px": [32, 32], "frames": 8,
                              "apng_ms": [125]*8, "gif_ms": [120, 130]*4, "loop_ms": 1000,
                              "minimum_transparent_padding_px": 11},
                "audio": audio, "commands_executed": COMMANDS,
                "versions": {"python": sys.version.split()[0], "pillow": PILLOW_VERSION,
                             "inkscape": run(["inkscape", "--version"]).strip(),
                             "ffmpeg": run(["ffmpeg", "-version"]).splitlines()[0]},
                "assets": {name: {"sha256": checksum(OUT/name), "bytes": (OUT/name).stat().st_size}
                           for name in names},
                "limits": ["No engine import", "No observed animation playback", "No human listening/playtest",
                           "Encoder versions may alter bytes; reproducible content is defined by this source"]}
    for name in ("sample.png", "frame-strip.png", "pulse.apng", "pulse.gif", "preview.png"):
        manifest["assets"][name].update(image_info(name))
    (OUT / "local-manifest.json").write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({"result": "PASS", "output": REL, "assets": len(names),
                      "apng_frames": 8, "gif_frames": 8, "loop_ms": 1000,
                      "audio_duration_seconds": 0.5, "pcm_peak": max(map(abs, samples))}))


if __name__ == "__main__":
    main()
