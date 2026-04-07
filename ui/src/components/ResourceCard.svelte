<script>
  export let id;
  export let category;
  export let title;
  export let description;
  export let subject;
  export let subjects = [];
  export let grade;
  export let grades = [];
  export let contributor;
  export let viewCount;
  export let contributionScore = null;
  export let status = null;
  export let showStatus = false;
  export let slug = null;
  export let isBookmarked = false;
  export let coverImageUrl = null;

  let isHovered = false;

  $: subjectDisplay = subjects.length > 1 ? `${subject} +${subjects.length - 1}` : subject;
  $: gradeDisplay = grades.length > 1 ? `${grade} +${grades.length - 1}` : grade;

  import { createEventDispatcher } from 'svelte';
  import { navigateTo } from '../router.js';

  const dispatch = createEventDispatcher();

  // Determine cover image based on category if not provided
  $: defaultCoverImage = getCoverImageByCategory(category);
  $: finalCoverImage = coverImageUrl || defaultCoverImage;

  function handleClick(event) {
    event?.preventDefault();
    event?.stopPropagation();
    
    if (slug) {
      navigateTo(`/resources/${slug}`);
    } else {
      console.warn('No slug available for resource', id);
      alert(`This resource doesn't have a URL yet. Please contact an administrator.`);
    }
  }

  function getCoverImageByCategory(cat) {
    switch(cat) {
      case 'LessonPlan': return '/lessonCover.png';
      case 'Video':      return '/videoCover.png';
      case 'Slideshow':  return '/sildeshowCover.png';
      case 'Assessment': return '/assessmentCover.png';
      default:           return '/lessonCover.png';
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
  <!-- Cover Image Section -->
  <div class="cover-image-wrapper">
    <img 
      src={finalCoverImage}
      alt={`${getCategoryLabel(category)}: ${title}`}
      class="cover-image"
      loading="lazy"
    />
    
    <!-- Status Badge (overlaid on cover) -->
    {#if showStatus && status}
      <div class="status-badge label-medium {getStatusColor(status)}">
        {status}
      </div>
    {/if}
    
    <!-- Bookmark Button -->
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
      <span class="material-symbols-outlined">bookmark</span>
    </button>
  </div>

  <!-- Content Section -->
  <div class="card-content">
    <!-- Resource Type Label -->
    <div class="resource-type label-small">
      {getCategoryLabel(category)}
    </div>
    
    <!-- Title -->
    <h3 class="card-title headline-small">{title}</h3>
    
    <!-- Subject/Category -->
    <div class="card-subject body-small">
      {subject || 'General'}
    </div>

    <!-- Metadata Row -->
    <div class="metadata-row">
      <div class="metadata-item">
        <span class="material-symbols-outlined metadata-icon">school</span>
        <span class="metadata-text">{gradeDisplay}</span>
      </div>
      {#if subjectDisplay}
        <div class="metadata-item">
          <span class="material-symbols-outlined metadata-icon">book</span>
          <span class="metadata-text">{subjectDisplay}</span>
        </div>
      {/if}
    </div>
  </div>

  <!-- Footer Section -->
  <div class="card-footer">
    <div class="contributor-info body-small">
      {contributor}
    </div>
    <div class="view-count label-small">
      <span class="material-symbols-outlined">visibility</span>
      <span>{formatNumber(viewCount)}</span>
    </div>
  </div>
</div>

<style>
  /* ── CARD CONTAINER ─────────────────────────────────────────── */
  .resource-card {
    display: flex;
    flex-direction: column;
    background-color: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-md);
    overflow: hidden;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    outline: none;
  }

  .resource-card:hover,
  .resource-card:focus {
    box-shadow: var(--md-sys-elevation-2);
    transform: translateY(-4px);
  }

  .resource-card:active {
    transform: translateY(-2px);
  }

  /* ── COVER IMAGE SECTION ───────────────────────────────────── */
  .cover-image-wrapper {
    position: relative;
    width: 100%;
    height: 160px;
    overflow: hidden;
    background: linear-gradient(135deg, #f5f5f5 0%, #e8e8e8 100%);
  }

  .cover-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }

  .resource-card:hover .cover-image {
    transform: scale(1.05);
  }

  /* Status badge on cover */
  .status-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    padding: 4px 12px;
    border-radius: var(--md-sys-shape-corner-sm);
    font-weight: 500;
    background-color: rgba(255, 255, 255, 0.95);
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
  }

  .status-published {
    color: var(--md-sys-color-success);
  }

  .status-approved {
    color: var(--md-sys-color-secondary);
  }

  .status-review {
    color: var(--md-sys-color-warning);
  }

  .status-submitted {
    color: var(--md-sys-color-on-surface-variant);
  }

  /* Bookmark button */
  .bookmark-btn {
    position: absolute;
    top: 12px;
    right: 12px;
    width: 40px;
    height: 40px;
    border: none;
    border-radius: 50%;
    background-color: rgba(255, 255, 255, 0.9);
    color: var(--md-sys-color-outline);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 10;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
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

  .bookmark-btn .material-symbols-outlined {
    font-size: 24px;
    font-weight: 400;
  }

  /* ── CONTENT SECTION ────────────────────────────────────────── */
  .card-content {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 16px;
    flex: 1;
  }

  .resource-type {
    display: inline-block;
    color: var(--md-sys-color-primary);
    font-weight: 500;
    letter-spacing: 0.3px;
    text-transform: uppercase;
  }

  .card-title {
    color: var(--md-sys-color-on-surface);
    font-weight: 500;
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    margin: 4px 0 0 0;
  }

  .card-subject {
    color: var(--md-sys-color-on-surface-variant);
    line-height: 1.4;
    display: -webkit-box;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }

  .metadata-row {
    display: flex;
    gap: 12px;
    margin-top: 8px;
    flex-wrap: wrap;
  }

  .metadata-item {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 10px;
    background-color: var(--md-sys-color-surface-variant);
    border-radius: var(--md-sys-shape-corner-sm);
    color: var(--md-sys-color-on-surface-variant);
  }

  .metadata-icon {
    font-size: 16px;
    flex-shrink: 0;
  }

  .metadata-text {
    font-size: 12px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  /* ── FOOTER SECTION ────────────────────────────────────────── */
  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px 16px;
    border-top: 1px solid var(--md-sys-color-outline-variant);
    gap: 12px;
  }

  .contributor-info {
    color: var(--md-sys-color-on-surface-variant);
    flex: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .view-count {
    display: flex;
    align-items: center;
    gap: 4px;
    color: var(--md-sys-color-on-surface-variant);
    flex-shrink: 0;
  }

  .view-count .material-symbols-outlined {
    font-size: 18px;
  }
</style>
