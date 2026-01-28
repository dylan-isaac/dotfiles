---
name: gobbler-batch
description: Batch convert directories of audio files or documents to markdown. Use when converting all files in a folder, multiple recordings, or bulk document processing.
---

# Gobbler Batch Directory Conversion

Convert entire directories of audio files or documents to markdown in a single command. Handles concurrent processing, progress tracking, and graceful error recovery.

## Quick Start

**Batch convert audio recordings:**
```bash
gobbler batch directory ./recordings -o ./output --pattern "*.mp3"
```

**Batch convert PDF documents:**
```bash
gobbler batch directory ./docs -o ./output --pattern "*.pdf" --type document
```

**Convert everything (auto-detect types):**
```bash
gobbler batch directory ./mixed -o ./output --pattern "*.*"
```

## Pattern Matching Guide

Glob patterns control which files get processed:

| Pattern | Matches |
|---------|---------|
| `*.mp3` | All MP3 files |
| `*.pdf` | All PDF files |
| `recording_*.wav` | Files starting with "recording_" |
| `*.{mp3,wav}` | MP3 and WAV files |
| `*.*` | All files (relies on auto-detection) |

Patterns are case-sensitive. Use `*.*` with caution - it processes everything the tool recognizes.

## File Type Detection

When `--type` is not specified, gobbler auto-detects based on extension:

**Audio formats:** mp3, wav, m4a, flac, ogg, wma, aac

**Document formats:** pdf, docx, doc, pptx, ppt, xlsx, xls

Unrecognized extensions are skipped with a warning.

## Options Reference

| Flag | Description | Default |
|------|-------------|---------|
| `-o, --output` | Output directory for markdown files | Required |
| `--pattern, -p` | Glob pattern for file matching | `*.*` |
| `--type, -t` | Force file type: `audio` or `document` | Auto-detect |
| `--concurrency, -c` | Parallel processing limit | `3` |

## Batch Processing Mechanics

**Concurrency:** Files process in parallel up to the concurrency limit. Higher values speed up processing but use more memory.

**Auto-queue:** When batch contains >10 items, processing moves to background with Redis. You'll get a job ID to check status.

**Progress tracking:** Real-time progress bar shows completion percentage and current file.

**Output structure:**
```
output_dir/
  meeting_notes.md      # from meeting_notes.mp3
  quarterly_report.md   # from quarterly_report.pdf
  interview.md          # from interview.wav
```

Output filenames match input filenames with `.md` extension.

## Saving Output

**Tip**: If the user has configured `output.default_directory` in `~/.config/gobbler/config.yml`, save files there.

```bash
gobbler batch directory ./recordings -o "$OUTPUT_DIR" --pattern "*.mp3"
```

## Error Handling

Batch processing continues even when individual files fail:

- Failed files are logged but don't stop the batch
- Summary report shows: `X successful, Y failed`
- Failed file list included in output for retry

Example summary:
```
Processed 47 files successfully
3 files failed to process
```

## Performance Tips

**Concurrency tuning:**
- Default (3): Safe for most systems
- Increase to 5-8: Faster on good hardware with available memory
- Reduce to 1-2: For large files or limited memory

```bash
# Faster processing
gobbler batch directory ./files -o ./out --pattern "*.wav" --concurrency 5

# Conservative for large files
gobbler batch directory ./videos -o ./out --pattern "*.m4a" --concurrency 1
```

**Memory considerations:**
- Large audio files (>100MB) benefit from lower concurrency
- Document batches are generally lighter on memory
- Monitor system resources on first large batch

## Troubleshooting

### Pattern not matching any files

- Check case sensitivity (`*.MP3` != `*.mp3`)
- Verify files exist in the source directory
- Test pattern with `ls ./source/*.mp3` first

### Mixed file types producing errors

- Use specific patterns instead of `*.*`
- Or explicitly set `--type` when directory contains one type

### Memory issues with large batches

- Reduce concurrency: `--concurrency 1`
- Process in smaller batches by using more specific patterns
- Large audio files (podcasts, long recordings) need lower concurrency

### Processing seems stuck

- Large files take time - check progress bar
- >10 files triggers background queue; check job status with `gobbler jobs list`
- Retry the batch if network issues caused API timeouts
