---
name: gobbler-playlist
description: Process entire YouTube playlists to markdown. Use for "download playlist", "batch youtube", "all videos from", "course videos", or "transcribe playlist" requests.
---

# YouTube Playlist Processing

Convert entire YouTube playlists to markdown files. Each video becomes a separate markdown file with frontmatter and transcript.

## Quick Start

```bash
# Process a playlist
gobbler batch youtube-playlist "https://youtube.com/playlist?list=PLxxxxx" \
  -o "./Playlist Name" \
  --timestamps

# With custom concurrency (default: 3)
gobbler batch youtube-playlist "https://youtube.com/playlist?list=PLxxxxx" \
  -o "./Playlist Name" \
  --timestamps \
  --concurrency 5
```

## Options Reference

| Flag | Default | Description |
|------|---------|-------------|
| `-o, --output` | Required | Output directory path |
| `--timestamps` | `false` | Include timestamps in transcript |
| `--concurrency, -c` | `3` | Parallel video processing (1-10) |
| `--language, -l` | `en` | Preferred transcript language |
| `--skip-existing` | `true` | Skip videos that already have output files |
| `--no-skip-existing` | - | Force reprocess all videos |

## Features

- **Parallel processing**: Multiple videos process simultaneously
- **Skip existing**: Only processes new videos by default
- **Progress tracking**: Shows which videos are starting and completing
- **Graceful failures**: One failed video won't stop the batch
- **Rate limit handling**: Uses webshare proxy + paid API fallback

## Output Structure

```
Playlist Name/
  Video Title One.md
  Video Title Two.md
  Video Title Three.md
  ...
```

Each file contains:
- YAML frontmatter (source URL, video ID, title, channel, duration, etc.)
- Timestamped transcript (if `--timestamps` used)

## Saving Output

**Tip**: If the user has configured `output.default_directory` in `~/.config/gobbler/config.yml`, save files there:

```bash
gobbler batch youtube-playlist "URL" -o "$OUTPUT_DIR/Playlist Name" --timestamps
```

## Progress Output

```
Fetching playlist info...
Found 47 videos (42 existing, 5 new)
Processing 5 videos (3 parallel)...

  Starting: Video Title One
  Starting: Video Title Two
  Starting: Video Title Three
Video Title Two
  Progress: 1/5
Video Title One
  Progress: 2/5
  Starting: Video Title Four
...

Sync complete!
  New: 5
  Skipped (existing): 42
```

## Rate Limiting

YouTube may rate-limit transcript requests. Gobbler handles this with:

1. **Webshare proxy**: Rotating proxies via `WEBSHARE_USER`/`WEBSHARE_PASS`
2. **Paid API fallback**: `TRANSCRIPTAPI_KEY` for reliable access
3. **Concurrency control**: Lower `-c` value if hitting limits

```bash
# If rate limited, reduce concurrency
gobbler batch youtube-playlist "URL" -o ./out --concurrency 1
```

## Troubleshooting

### Videos failing with no transcript

Some videos don't have transcripts available:
- Live streams often lack transcripts
- Music videos may have only lyrics
- Creator may have disabled captions

### Playlist not found

Verify the playlist URL works:
```bash
yt-dlp --flat-playlist --print "%(title)s" "YOUR_PLAYLIST_URL" | head -5
```

### Many failures (rate limited)

```bash
# Reduce concurrency
gobbler batch youtube-playlist "URL" -o ./out --concurrency 1

# Or wait 5-10 minutes and retry
```

### Resume interrupted download

Just run the same command again - `--skip-existing` (default) will skip completed videos.
