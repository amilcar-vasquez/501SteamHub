<script>
  export let id;
  export let category;
  export let title;
  export let description;
  export let subject;
  export let subjects = []; // Optional array of all subjects
  export let grade;
  export let grades = []; // Optional array of all grades
  export let contributor;
  export let viewCount;
  export let contributionScore = null; // Optional: now replaced by STEAM Points
  export let status = null;
  export let showStatus = false;
  export let slug = null; // Add slug prop
  export let isBookmarked = false; // Bookmark status
  
  let isHovered = false;

  // Display text for subjects/grades
  $: subjectDisplay = subjects.length > 1 ? `${subject} +${subjects.length - 1}` : subject;
  $: gradeDisplay = grades.length > 1 ? `${grade} +${grades.length - 1}` : grade;

  // ── Lesson content preview (lazy-fetched on first hover) ────────
  export let lessons = []; // can be pre-loaded; otherwise fetched lazily

  let previewLessons = lessons;
  let previewFetched = lessons.length > 0;
  let previewLoading = false;

  import { createEventDispatcher } from 'svelte';
  import { navigateTo } from '../router.js';
  import { resourceAPI } from '../api/client.js';

  const dispatch = createEventDispatcher();

  // Trigger fetch on first hover
  $: if (isHovered && !previewFetched && slug && !previewLoading) {
    fetchPreview();
  }

  async function fetchPreview() {
    previewLoading = true;
    try {
      const response = await resourceAPI.getBySlug(slug);
      previewLessons = response.lessons || [];
      // Capture video-specific data for Video resource cards
      previewVideoMeta = response.video_metadata || null;
      previewPublishedURL = response.resource?.published_url || null;
      previewDriveLink = response.resource?.drive_link || null;
    } catch (_) {
      // silently ignore — placeholder stays
    } finally {
      previewFetched = true;
      previewLoading = false;
    }
  }

  // Pull objectives and activity steps out of the first lesson's blocks
  function parseLessonContent(lesson) {
    if (!lesson?.content) return null;
    try { return typeof lesson.content === 'string' ? JSON.parse(lesson.content) : lesson.content; }
    catch (_) { return null; }
  }

  $: _allBlocks = previewLessons.flatMap(l => parseLessonContent(l)?.blocks ?? []);
  $: previewObjectives = (_allBlocks.find(b => b.type === 'objectives')?.content ?? []).slice(0, 4);
  $: previewSteps      = (_allBlocks.find(b => b.type === 'activity')?.content ?? []).slice(0, 3);
  $: previewWarmup     = _allBlocks.find(b => b.type === 'warmup')?.content ?? null;
  $: extraBlockCount   = new Set(_allBlocks.map(b => b.type)).size
                         - (previewObjectives.length > 0 ? 1 : 0)
                         - (previewSteps.length > 0 ? 1 : 0)
                         - (previewWarmup ? 1 : 0);

  // ── Video preview data ─────────────────────────────────────────────────────
  let previewVideoMeta = null;
  let previewPublishedURL = null;
  let previewDriveLink = null;

  $: isVideo = category === 'Video';

  function getYouTubeID(url) {
    if (!url) return null;
    const patterns = [
      /(?:youtube\.com\/watch\?(?:.*&)?v=)([\w-]{11})/,
      /(?:youtu\.be\/)([\w-]{11})/,
      /(?:youtube\.com\/embed\/)([\w-]{11})/,
    ];
    for (const re of patterns) {
      const m = url.match(re);
      if (m) return m[1];
    }
    return null;
  }

  $: videoID = getYouTubeID(previewPublishedURL);
  $: videoThumbnail = videoID ? `https://img.youtube.com/vi/${videoID}/hqdefault.jpg` : null;
  
  function handleClick(event) {
    // Prevent default and stop propagation to ensure the click is handled
    event?.preventDefault();
    event?.stopPropagation();
    
    console.log('Resource clicked:', { id, slug, title });
    
    // Navigate to resource detail page using slug if available, otherwise use ID
    if (slug) {
      console.log('Navigating to:', `/resources/${slug}`);
      navigateTo(`/resources/${slug}`);
    } else {
      console.warn('No slug available for resource', id, '- This resource was likely created before slug generation was implemented');
      alert(`This resource doesn't have a URL yet. Please contact an administrator.`);
    }
  }
  
  function getCategoryColor(cat) {
    switch(cat) {
      case 'LessonPlan': return 'category-lesson';
      case 'Video':      return 'category-video';
      case 'Slideshow':  return 'category-slideshow';
      case 'Assessment': return 'category-assessment';
      case 'Other':      return 'category-other';
      default:           return 'category-default';
    }
  }

  function getCategoryLabel(cat) {
    switch(cat) {
      case 'LessonPlan': return 'Lesson Plan';
      case 'Video':      return 'Video';
      case 'Slideshow':  return 'Slideshow';
      case 'Assessment': return 'Assessment';
      case 'Other':      return 'Other';
      default:           return cat || 'Unknown';
    }
  }
  
  function getStatusColor(stat) {
    switch(stat) {
      case 'Published': return 'status-published';
      case 'Approved': return 'status-approved';
      case 'Under Review': return 'status-review';
      case 'Submitted': return 'status-submitted';
      default: return 'status-default';
    }
  }
  
  function formatNumber(num) {
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  }
</script>

<div 
  class="resource-card" 
  class:hovered={isHovered}
  on:click={handleClick}
  on:mouseenter={() => isHovered = true}
  on:mouseleave={() => isHovered = false}
  on:keydown={(e) => e.key === 'Enter' && handleClick(e)}
  role="button"
  tabindex="0"
  aria-label="View resource: {title}"
>
 
  {#if showStatus && status}
    <div class="status-badge label-medium {getStatusColor(status)}">
      {status}
    </div>
  {/if}

  <!-- Bookmark button -->
  <button
    class="bookmark-btn"
    class:bookmarked={isBookmarked}
    on:click={(e) => {
      e.stopPropagation();
      dispatch('bookmark');
    }}
    aria-label={isBookmarked ? 'Remove bookmark' : 'Bookmark resource'}
    title={isBookmarked ? 'Remove from bookmarks' : 'Add to bookmarks'}
  >
    <span class="material-symbols-outlined">
      {isBookmarked ? 'bookmark' : 'bookmark'}
    </span>
  </button>
  
  <article class="card-content">
    <!-- Category chip -->
    <div class="category-chip label-medium {getCategoryColor(category)}">
      {getCategoryLabel(category)}
    </div>
    
    <!-- Title -->
    <h3 class="card-title title-medium">{title}</h3>
    
    <!-- Description -->
    <p class="card-description body-medium">{description}</p>
    
  <!-- ── Content preview ─────────────────────────────────────────── -->
  {#if !showStatus}
  <div class="page-preview-viewport" class:pp-video-viewport={isVideo}>

    {#if isVideo}
      <!-- ── VIDEO preview ─────────────────────────────────────────── -->
      {#if previewLoading}
        <div class="pp-skeleton pp-skeleton--video">
          <div class="pp-skel-thumb"></div>
        </div>

      {:else if !previewFetched}
        <div class="pp-placeholder">
          <span class="material-symbols-outlined pp-placeholder-icon">smart_display</span>
          <span class="pp-placeholder-text">Hover to preview video</span>
        </div>

      {:else if videoThumbnail}
        <div class="pp-video-preview">
          <img
            class="pp-video-thumb"
            src="{videoThumbnail}"
            alt="{title} thumbnail"
            loading="lazy"
          />
          <div class="pp-video-play-overlay">
            <span class="material-symbols-outlined pp-play-icon">play_circle</span>
          </div>
          {#if previewVideoMeta}
            <div class="pp-video-info">
              {#if previewVideoMeta.youtube_title}
                <span class="pp-video-yt-title">{previewVideoMeta.youtube_title}</span>
              {/if}
              <div class="pp-video-badges">
                <span class="pp-video-badge">
                  <span class="material-symbols-outlined">privacy_tip</span>
                  {previewVideoMeta.privacy_status}
                </span>
                {#if previewVideoMeta.made_for_kids}
                  <span class="pp-video-badge">
                    <span class="material-symbols-outlined">child_care</span>
                    Kids
                  </span>
                {/if}
              </div>
            </div>
          {/if}
        </div>

      {:else}
        <!-- No published_url yet -->
        <div class="pp-placeholder">
          <span class="material-symbols-outlined pp-placeholder-icon">cloud_upload</span>
          <span class="pp-placeholder-text">Video pending upload</span>
        </div>
      {/if}

    {:else}
      <!-- ── LESSON preview (existing) ─────────────────────────────── -->
      <div class="page-preview-content">

      {#if previewLoading}
        <!-- Loading skeleton -->
        <div class="pp-skeleton">
          <div class="pp-skel-bar pp-skel-bar--wide"></div>
          <div class="pp-skel-bar"></div>
          <div class="pp-skel-bar"></div>
          <div class="pp-skel-bar pp-skel-bar--short"></div>
        </div>

      {:else if !previewFetched}
        <!-- Not yet hovered — subtle placeholder -->
        <div class="pp-placeholder">
          <span class="material-symbols-outlined pp-placeholder-icon">preview</span>
          <span class="pp-placeholder-text">Hover to preview content</span>
        </div>

      {:else if _allBlocks.length === 0}
        <!-- Fetched but empty -->
        <div class="pp-placeholder">
          <span class="material-symbols-outlined pp-placeholder-icon">description</span>
          <span class="pp-placeholder-text">No lesson content yet</span>
        </div>

      {:else}
        <div class="pp-body">

          <!-- Objectives section -->
          {#if previewObjectives.length > 0}
            <div class="pp-section">
              <div class="pp-section-header">
                <span class="material-symbols-outlined pp-section-icon">emoji_objects</span>
                <span class="pp-section-title">Learning Objectives</span>
              </div>
              <ul class="pp-objectives-list">
                {#each previewObjectives as obj}
                  <li class="pp-objective-item">
                    <span class="material-symbols-outlined pp-check">check_circle</span>
                    <span class="pp-objective-text">{obj}</span>
                  </li>
                {/each}
              </ul>
            </div>
          {/if}

          <!-- Warmup snippet -->
          {#if previewWarmup && typeof previewWarmup === 'string' && previewWarmup.trim()}
            <div class="pp-section">
              <div class="pp-section-header">
                <span class="material-symbols-outlined pp-section-icon">local_fire_department</span>
                <span class="pp-section-title">Warm-up</span>
              </div>
              <p class="pp-warmup-text">{previewWarmup}</p>
            </div>
          {/if}

          <!-- Activity steps -->
          {#if previewSteps.length > 0}
            <div class="pp-section">
              <div class="pp-section-header">
                <span class="material-symbols-outlined pp-section-icon">bolt</span>
                <span class="pp-section-title">Activity</span>
              </div>
              <ol class="pp-steps-list">
                {#each previewSteps as step}
                  <li class="pp-step-item">
                    <span class="pp-step-num">{step.step}.</span>
                    <span class="pp-step-text">{step.text}</span>
                  </li>
                {/each}
              </ol>
            </div>
          {/if}

          <!-- Overflow hint -->
          {#if extraBlockCount > 0}
            <div class="pp-more-hint">
              <span class="material-symbols-outlined">more_horiz</span>
              {extraBlockCount} more section{extraBlockCount === 1 ? '' : 's'} inside
            </div>
          {/if}

        </div>
      {/if}

      </div>
    {/if}
  </div>
  {/if}


    <!-- Metadata chips -->
    <div class="metadata-chips">
      <div class="assist-chip label-medium">
        <span class="material-symbols-outlined">book</span>
        {subjectDisplay}
      </div>
      <div class="assist-chip label-medium">
        <span class="material-symbols-outlined">school</span>
        {gradeDisplay}
      </div>
    </div>
    
    <!-- Footer -->
    <div class="card-footer">
      <span class="contributor body-medium">{contributor}</span>
      <div class="stats">
        <div class="stat-item label-medium">
          <span class="material-symbols-outlined">visibility</span>
          {formatNumber(viewCount)}
        </div>
        {#if contributionScore !== null && contributionScore !== undefined}
          <div class="stat-item label-medium">
            <span class="material-symbols-outlined">star</span>
            {contributionScore}
          </div>
        {/if}
      </div>
    </div>
  </article>
</div>

<style>
  /* ── Lesson content preview thumbnail ─────────────────────────── */
  .page-preview-viewport {
    width: 100%;
    height: 190px;
    overflow: hidden;
    border-radius: var(--md-sys-shape-corner-sm);
    border: 1px solid var(--md-sys-color-outline-variant);
    background: #fafafa;
    margin-bottom: var(--md-sys-spacing-md);
    flex-shrink: 0;
    display: flex;
    align-items: stretch;
  }

  /* Scaled inner page — 210% wide so 0.8× makes it fill the viewport */
  .page-preview-content {
    width: 210%;
    transform: scale(0.9);
    transform-origin: top left;
    /* keep the scaled height filling the viewport */
    height: calc(190px / 0.9);
    pointer-events: none;
    user-select: none;
    font-family: inherit;
    overflow: hidden;
  }

  /* ── Placeholder / loading states ──────────────────────────────── */
  .pp-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 16px;
    height: 100%;
    padding: 40px 24px;
  }

  .pp-placeholder-icon {
    font-size: 52px;
    color: rgba(0,0,0,0.18);
  }

  .pp-placeholder-text {
    font-size: 20px;
    color: rgba(0,0,0,0.35);
    text-align: center;
    line-height: 1.4;
  }

  .pp-skeleton {
    display: flex;
    flex-direction: column;
    gap: 18px;
    padding: 28px 24px;
    height: 100%;
  }

  .pp-skel-bar {
    height: 22px;
    border-radius: 6px;
    background: linear-gradient(90deg, #e8e8e8 25%, #f0f0f0 50%, #e8e8e8 75%);
    background-size: 200% 100%;
    animation: pp-shimmer 1.4s infinite;
    width: 90%;
  }

  .pp-skel-bar--wide  { width: 60%; }
  .pp-skel-bar--short { width: 45%; }

  @keyframes pp-shimmer {
    0%   { background-position: 200% 0; }
    100% { background-position: -200% 0; }
  }

  /* ── Content body ───────────────────────────────────────────────── */
  .pp-body {
    padding: 22px 24px 18px;
    display: flex;
    flex-direction: column;
    gap: 22px;
  }

  .pp-section {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .pp-section-header {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .pp-section-icon {
    font-size: 22px;
    color: rgba(0,0,0,0.45);
  }

  .pp-section-title {
    font-size: 19px;
    font-weight: 600;
    color: rgba(0,0,0,0.65);
    letter-spacing: 0.2px;
    text-transform: uppercase;
  }

  /* Objectives */
  .pp-objectives-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .pp-objective-item {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 10px 14px;
    background: rgba(0,0,0,0.03);
    border-radius: 8px;
  }

  .pp-check {
    font-size: 20px;
    color: #388e3c;
    flex-shrink: 0;
    margin-top: 1px;
  }

  .pp-objective-text {
    font-size: 17px;
    color: rgba(0,0,0,0.72);
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  /* Warmup */
  .pp-warmup-text {
    font-size: 17px;
    color: rgba(0,0,0,0.6);
    margin: 0;
    padding: 10px 14px;
    background: rgba(0,0,0,0.03);
    border-radius: 8px;
    border-left: 4px solid #ef6c00;
    display: -webkit-box;
    -webkit-line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
    line-height: 1.4;
  }

  /* Activity steps */
  .pp-steps-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .pp-step-item {
    display: flex;
    gap: 12px;
    padding: 10px 14px;
    background: rgba(0,0,0,0.03);
    border-radius: 8px;
    border-left: 4px solid var(--md-sys-color-primary, #1565c0);
  }

  .pp-step-num {
    font-size: 16px;
    font-weight: 700;
    color: var(--md-sys-color-primary, #1565c0);
    flex-shrink: 0;
  }

  .pp-step-text {
    font-size: 17px;
    color: rgba(0,0,0,0.72);
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  /* More hint */
  .pp-more-hint {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 17px;
    color: rgba(0,0,0,0.38);
    padding: 4px 0;
  }

  .pp-more-hint .material-symbols-outlined {
    font-size: 22px;
  }

  /* ── Video preview ────────────────────────────────────────────── */
  .pp-video-viewport {
    height: 190px;    /* same height as lesson preview */
  }

  .pp-skeleton--video {
    height: 100%;
    padding: 0;
    display: flex;
    align-items: stretch;
  }

  .pp-skel-thumb {
    width: 100%;
    height: 100%;
    border-radius: 6px;
    background: linear-gradient(90deg, #e8e8e8 25%, #f0f0f0 50%, #e8e8e8 75%);
    background-size: 200% 100%;
    animation: pp-shimmer 1.4s infinite;
  }

  .pp-video-preview {
    position: relative;
    width: 100%;
    height: 100%;
    overflow: hidden;
  }

  .pp-video-thumb {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  .pp-video-play-overlay {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(0,0,0,0.15);
    transition: background 0.2s;
  }

  .resource-card:hover .pp-video-play-overlay {
    background: rgba(0,0,0,0.3);
  }

  .pp-play-icon {
    font-size: 52px;
    color: rgba(255,255,255,0.92);
    filter: drop-shadow(0 2px 4px rgba(0,0,0,0.35));
  }

  .pp-video-info {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    padding: 24px 10px 8px;
    background: linear-gradient(to top, rgba(0,0,0,0.72) 0%, transparent 100%);
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .pp-video-yt-title {
    font-size: 12px;
    font-weight: 600;
    color: #fff;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .pp-video-badges {
    display: flex;
    gap: 6px;
  }

  .pp-video-badge {
    display: inline-flex;
    align-items: center;
    gap: 2px;
    font-size: 10px;
    font-weight: 500;
    color: rgba(255,255,255,0.85);
    background: rgba(255,255,255,0.15);
    border-radius: 10px;
    padding: 1px 7px;
  }

  .pp-video-badge .material-symbols-outlined {
    font-size: 12px;
  }

  /* ── Card shell ───────────────────────────────────────────────── */
  .resource-card {
    background-color: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-md);
    padding: var(--md-sys-spacing-md);
    cursor: pointer;
    transition: box-shadow 0.3s cubic-bezier(0.4, 0, 0.2, 1), 
                transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }
  
  .resource-card:hover,
  .resource-card:focus {
    outline: none;
    box-shadow: var(--md-sys-elevation-2);
    transform: translateY(-2px);
  }
  
  .resource-card:active {
    transform: translateY(0);
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .status-badge {
    position: absolute;
    top: var(--md-sys-spacing-sm);
    right: var(--md-sys-spacing-sm);
    padding: 4px 8px;
    border-radius: var(--md-sys-shape-corner-sm);
    font-weight: 500;
  }
  
  .status-published {
    background-color: var(--md-sys-color-success-container);
    color: var(--md-sys-color-success);
  }
  
  .status-approved {
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-secondary);
  }
  
  .status-review {
    background-color: var(--md-sys-color-warning-container);
    color: var(--md-sys-color-warning);
  }
  
  .status-submitted {
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
  }

  /* ── BOOKMARK BUTTON ────────────────────────────────────────────────────────── */
  .bookmark-btn {
    position: absolute;
    top: var(--md-sys-spacing-sm);
    right: 110px;
    width: 40px;
    height: 40px;
    border: none;
    border-radius: 50%;
    background-color: transparent;
    color: var(--md-sys-color-outline);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 10;
  }

  .bookmark-btn:hover {
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-secondary);
    transform: scale(1.1);
  }

  .bookmark-btn:active {
    transform: scale(0.95);
  }

  .bookmark-btn.bookmarked {
    color: var(--md-sys-color-primary);
    background-color: var(--md-sys-color-primary-container);
  }

  .bookmark-btn.bookmarked:hover {
    background-color: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
  }

  .bookmark-btn .material-symbols-outlined {
    font-size: 24px;
    font-weight: 400;
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .bookmark-btn:active .material-symbols-outlined {
    animation: bookmarkPulse 0.6s ease-out;
  }

  @keyframes bookmarkPulse {
    0% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.3);
    }
    100% {
      transform: scale(1);
    }
  }

  .card-content {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-md);
  }
  
  .category-chip {
    display: inline-flex;
    align-items: center;
    padding: 4px 12px;
    border-radius: var(--md-sys-shape-corner-full);
    width: fit-content;
  }
  
  .category-lesson {
    background-color: #e8f5e9;
    color: #2e7d32;
  }
  
  .category-video {
    background-color: #e3f2fd;
    color: #1565c0;
  }
  
  .category-assessment {
    background-color: #fff3e0;
    color: #e65100;
  }

  .category-slideshow {
    background-color: #f3e5f5;
    color: #6a1b9a;
  }

  .category-other {
    background-color: #fce4ec;
    color: #880e4f;
  }
  
  .category-default {
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .card-title {
    color: var(--md-sys-color-secondary);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    min-height: 48px;
  }
  
  .card-description {
    color: var(--md-sys-color-on-surface-variant);
    display: -webkit-box;
    -webkit-line-clamp: 3;
    line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    min-height: 60px;
  }
  
  .metadata-chips {
    display: flex;
    flex-wrap: wrap;
    gap: var(--md-sys-spacing-sm);
  }
  
  .assist-chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
    border-radius: var(--md-sys-shape-corner-sm);
  }
  
  .assist-chip .material-symbols-outlined {
    font-size: 18px;
  }
  
  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: var(--md-sys-spacing-sm);
    border-top: 1px solid var(--md-sys-color-outline-variant);
  }
  
  .contributor {
    color: var(--md-sys-color-on-surface-variant);
    font-size: 12px;
  }
  
  .stats {
    display: flex;
    gap: var(--md-sys-spacing-md);
  }
  
  .stat-item {
    display: flex;
    align-items: center;
    gap: 4px;
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .stat-item .material-symbols-outlined {
    font-size: 18px;
  }
</style>
