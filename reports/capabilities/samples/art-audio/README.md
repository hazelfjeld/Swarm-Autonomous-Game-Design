# Disposable ART-001 capability samples

Original neutral geometry and synthetic audio created for format/export verification. These are not Little Ray assets, style trials, palette choices, or runtime requirements. Do not import them as game content.

Reproduce from the repository root (Python with Pillow, Inkscape, FFmpeg/FFprobe):

    python3 scripts/art_audio_capability_sample.py

The script rewrites only its named disposable outputs in this directory. No network or generation service is used. The manifest records hashes, actual decoded formats, command arguments, versions, and source provenance.

- sample.svg / sample.png: editable original geometry and transparent 64x64 export.
- frame-strip.png: eight 64x64 cells, left to right, center pivot (32,32), transparent padding.
- pulse.apng: eight frames at 125 ms, one-second loop, full-frame source replacement.
- pulse.gif: GIF's 10 ms precision needs alternating 120/130 ms delays for the same one-second loop; indexed transparency and disposal-to-background.
- cue.wav / cue.ogg: 0.5 seconds, 48 kHz mono, 440 Hz with a smooth envelope. PCM WAV is 16-bit; Ogg is lossy Vorbis. Decode/metadata checked; no listening claim.
- preview.png: static review sheet; animated playback and engine import are unverified.

Provenance: original assistant-authored geometry, timing, and synthesized waveform; no third-party assets or references. The script and samples were created for this authorized repository work; no external license is introduced or claimed. Existing repository terms apply. These files do not establish rights for other assets.
