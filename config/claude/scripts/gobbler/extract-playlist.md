# Extract YouTube Playlist - Complete Metadata Extraction

Extract complete metadata from a YouTube playlist with intelligent scrolling and validation.

**Key Pattern**: Process and save data in browser to bypass MCP response size limits.

## Arguments

`<PLAYLIST_URL>` - YouTube playlist URL (e.g., "https://www.youtube.com/playlist?list=PLRI6w0OgqPh0ytfk5erf0LPZWKCGzpDsY")
`[OUTPUT_FILENAME]` - Optional filename (defaults to `playlist_<playlistId>_<date>.json`)

Example: `/extract-playlist https://www.youtube.com/playlist?list=PLRI6w0OgqPh0ytfk5erf0LPZWKCGzpDsY my_playlist.json`

---

## Phase 1: Navigation & Discovery

### Navigate to Playlist
1. Use `browser_navigate_to_url` with the provided playlist URL
2. Wait for page to load completely
3. Verify we're on a valid playlist page

### Extract Total Video Count
Use `browser_execute_script` to get the total count:

```javascript
(function() {
  const countElement = document.evaluate(
    '/html/body/ytd-app/div[1]/ytd-page-manager/ytd-browse[1]/yt-page-header-renderer/yt-page-header-view-model/div[2]/div/div[1]/div/yt-content-metadata-view-model/div[2]/span[5]',
    document,
    null,
    XPathResult.FIRST_ORDERED_NODE_TYPE,
    null
  ).singleNodeValue;

  const totalVideos = parseInt(countElement?.textContent?.replace(/[^0-9]/g, '') || '0');
  return totalVideos;
})()
```

### Report Initial State
```
# Playlist Extraction - Phase 1 Complete

Playlist URL: [url]
Total Videos: [count]
Status: Ready to scroll and extract ✅
```

---

## Phase 2: Intelligent Scrolling

### Execute Progressive Scrolling
Use `browser_execute_script` with this logic:

```javascript
(async () => {
  const targetCount = [TOTAL_FROM_PHASE_1];
  let currentCount = 0;
  let previousCount = 0;
  let staleScrollCount = 0;
  const maxStaleScrolls = 3;

  // Find scrollable container
  const scrollContainer = document.querySelector('#primary #contents') || document.documentElement;

  // Update page title to show progress
  const originalTitle = document.title;

  while (currentCount < targetCount && staleScrollCount < maxStaleScrolls) {
    // Count currently loaded videos
    currentCount = document.querySelectorAll('ytd-playlist-video-renderer').length;

    // Update progress in page title
    document.title = `Loading... ${currentCount}/${targetCount}`;

    // Check if we're making progress
    if (currentCount === previousCount) {
      staleScrollCount++;
    } else {
      staleScrollCount = 0;
    }
    previousCount = currentCount;

    // Scroll down incrementally
    const scrollHeight = scrollContainer.scrollHeight || document.body.scrollHeight;
    scrollContainer.scrollTo?.(0, scrollHeight) || window.scrollTo(0, scrollHeight);

    // Wait for new content to load
    await new Promise(resolve => setTimeout(resolve, 2000));
  }

  // Restore title
  document.title = originalTitle;

  return {
    targetVideos: targetCount,
    loadedVideos: currentCount,
    complete: currentCount >= targetCount,
    coveragePercentage: ((currentCount / targetCount) * 100).toFixed(1)
  };
})()
```

### Report Progress
```
# Playlist Extraction - Phase 2 Complete

Target Videos: [target]
Loaded Videos: [loaded]
Coverage: [percentage]%
Status: [Complete ✅ / Partial ⚠️]
```

**If coverage < 95%:** Inform user that 8+ videos may be private/deleted but continue anyway.

---

## Phase 3: Extract & Save in Browser

**KEY INSIGHT**: Don't return large data through MCP. Process and save in browser, return summary only.

Use `browser_execute_script` to extract, format, and trigger download:

```javascript
(async () => {
  const videos = Array.from(document.querySelectorAll('ytd-playlist-video-renderer'));
  const playlistUrl = window.location.href;
  const playlistId = new URL(playlistUrl).searchParams.get('list');
  const totalVideosExpected = [TOTAL_FROM_PHASE_1];

  // Extract all metadata
  const videoData = videos.map((video, index) => {
    const titleElement = video.querySelector('a#video-title');
    const channelElement = video.querySelector('ytd-channel-name a');
    const durationElement = video.querySelector('ytd-thumbnail-overlay-time-status-renderer span');
    const videoId = titleElement?.href?.match(/[?&]v=([^&]+)/)?.[1] || null;

    return {
      playlistIndex: index + 1,
      title: titleElement?.title || titleElement?.textContent?.trim() || 'Unknown',
      videoId: videoId,
      url: titleElement?.href || null,
      watchUrl: videoId ? `https://www.youtube.com/watch?v=${videoId}` : null,
      channel: channelElement?.textContent?.trim() || 'Unknown',
      channelUrl: channelElement?.href || null,
      duration: durationElement?.textContent?.trim() || null,
      thumbnailUrl: videoId ? `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg` : null,
      playlistUrl: playlistUrl,
      playlistId: playlistId,
      position: index + 1,
      extractedAt: new Date().toISOString()
    };
  });

  // Count unique channels
  const uniqueChannels = new Set(videoData.map(v => v.channel)).size;

  // Build complete JSON structure
  const output = {
    metadata: {
      extractedAt: new Date().toISOString(),
      playlistUrl: playlistUrl,
      playlistId: playlistId,
      totalVideos: totalVideosExpected,
      extractedVideos: videos.length,
      missingVideos: totalVideosExpected - videos.length,
      extractionMethod: "gobbler-browser-extension",
      gobblerVersion: "0.1.0",
      coveragePercentage: parseFloat(((videos.length / totalVideosExpected) * 100).toFixed(1))
    },
    statistics: {
      videoCount: videos.length,
      uniqueChannels: uniqueChannels,
      missingVideosNote: totalVideosExpected - videos.length > 0
        ? `${totalVideosExpected - videos.length} videos appear to be private/deleted`
        : "All videos successfully extracted"
    },
    videos: videoData
  };

  // Create filename
  const date = new Date().toISOString().split('T')[0];
  const filename = `[FILENAME]` || `playlist_${playlistId}_${date}.json`;

  // Trigger browser download
  const jsonString = JSON.stringify(output, null, 2);
  const blob = new Blob([jsonString], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);

  // Return summary only (NOT the full data - keep response small)
  return {
    status: 'success',
    videosExtracted: videos.length,
    targetVideos: totalVideosExpected,
    missingVideos: totalVideosExpected - videos.length,
    uniqueChannels: uniqueChannels,
    fileDownloaded: filename,
    fileSizeKB: Math.round(jsonString.length / 1024),
    coveragePercentage: parseFloat(((videos.length / totalVideosExpected) * 100).toFixed(1))
  };
})()
```

**IMPORTANT**: Replace `[FILENAME]` with user-provided filename or auto-generated name.

---

## Phase 4: Verify & Report

### Ask User to Confirm Download
"Please check your Downloads folder. Did the file download successfully?"

### Generate Final Report

```
# ✅ Playlist Extraction Complete

## Summary
- Playlist ID: [id]
- URL: [url]
- Videos Extracted: [count] / [total] ([percentage]%)
- Missing Videos: [count] (likely private/deleted)
- Downloaded File: [filename]
- File Size: [size] KB

## Statistics
- Unique Channels: [count]
- Coverage: [percentage]%

## Download Location
Check your browser's Downloads folder for: [filename]

## Data Structure
The JSON file contains:
- `metadata`: Extraction details and playlist info
- `statistics`: Summary statistics
- `videos`: Array of [count] video objects with:
  - playlistIndex, title, videoId, url, watchUrl
  - channel, channelUrl, duration
  - thumbnailUrl, playlistUrl, playlistId
  - position, extractedAt timestamp

## Next Steps
You can now:
1. Use video IDs to batch transcribe: `/transcribe-playlist [filename]`
2. Analyze playlist content and trends
3. Download videos using video IDs
4. Build a knowledge base from the playlist

## Validation
If you'd like, I can read the downloaded file to verify data quality.
```

---

## Error Handling

### Common Issues & Recovery

**Issue: Page didn't load**
- Verify playlist URL is valid
- Check if playlist is private/unlisted
- Ensure browser is logged into YouTube (if needed)
- Retry navigation

**Issue: Video count mismatch (coverage < 95%)**
- Some videos may be private/deleted
- This is normal - proceed anyway
- Missing videos noted in metadata

**Issue: No file downloaded**
- Check browser's download settings
- May have blocked popup/download
- Check Downloads folder manually
- Try re-running Phase 3 extraction

**Issue: Browser extension disconnected**
- Run `browser_check_connection()`
- Reload page and reconnect
- Resume from current phase

---

## Important Rules

### ⚠️ Validation Rules
**Before starting:**
- ✅ Playlist URL is valid YouTube playlist
- ✅ Browser extension connected
- ✅ User on playlist page

### ✅ Execution Rules
- Always report progress after each phase
- Use page title for visual progress feedback
- Process data in browser, not in Claude
- Return summaries only (not full datasets)
- Handle missing videos gracefully

### 📝 Output Rules
- Auto-generate filename with playlist ID and date
- Pretty-print JSON (indent=2)
- Include metadata and statistics
- Preserve original video order
- Add extraction timestamp to each video

---

## Design Pattern: Browser-Side Processing

**When to use this pattern:**
- Extracting large datasets (>100 items)
- Data that would exceed MCP response limits (25K tokens)
- Any operation where final output is a file

**Benefits:**
- ✅ Bypasses MCP token limits
- ✅ Scales to any size dataset
- ✅ Faster (no data serialization through MCP)
- ✅ Better UX (file auto-downloads)
- ✅ Simpler error handling

**Pattern:**
1. Extract data in browser
2. Format/transform in browser
3. Trigger download in browser
4. Return summary statistics only
5. Optionally verify file after download

**Other use cases:**
- Crawling sites and saving all pages
- Extracting large tables/datasets
- Downloading batch transcripts
- Generating reports from scraped data
