<script>
  import { onMount } from 'svelte';
  import { resourceAPI, reviewAPI } from '../api/client.js';
  import { currentUser, authToken } from '../stores/auth.js';
  import TopAppBar from '../components/TopAppBar.svelte';
  import LoadingSkeleton from '../components/LoadingSkeleton.svelte';
  import LessonViewer from '../components/LessonViewer.svelte';
  
  export let slug = '';
  
  let resource = null;
  let lessons = [];
  let videoMetadata = null;
  let isLoading = true;
  let error = '';
  
  onMount(() => {
    loadResource();
  });
  
  async function loadResource() {
    if (!slug) {
      error = 'No resource specified';
      isLoading = false;
      return;
    }
    
    isLoading = true;
    error = '';
    
    try {
      const response = await resourceAPI.getBySlug(slug);
      resource = response.resource;
      lessons = response.lessons || [];
      videoMetadata = response.video_metadata || null;
      console.log('Resource loaded:', resource);
      console.log('Lessons loaded:', lessons);
      console.log('Video metadata:', videoMetadata);
    } catch (err) {
      console.error('Failed to load resource:', err);
      if (err.status === 404) {
        error = 'Resource not found';
      } else {
        error = 'Failed to load resource. Please try again.';
      }
    } finally {
      isLoading = false;
    }
  }
  
  import { navigateTo } from '../router.js';
  
  function handleNavigate(event) {
    navigateTo(event.detail.page || '/home');
  }
  
  function goBack() {
    navigateTo('/home');
  }
  
  // Parse lesson content from JSON string
  function parseLessonContent(lesson) {
    if (!lesson || !lesson.content) return null;
    try {
      return typeof lesson.content === 'string' 
        ? JSON.parse(lesson.content) 
        : lesson.content;
    } catch (error) {
      console.error('Failed to parse lesson content:', error);
      return null;
    }
  }

  // ── Video helpers ───────────────────────────────────────────────────────────
  function getYouTubeEmbedURL(url) {
    if (!url) return null;
    // https://www.youtube.com/watch?v=ID  or  https://youtu.be/ID  or  already /embed/
    const patterns = [
      /(?:youtube\.com\/watch\?(?:.*&)?v=)([\w-]{11})/,
      /(?:youtu\.be\/)([\w-]{11})/,
      /(?:youtube\.com\/embed\/)([\w-]{11})/,
    ];
    for (const re of patterns) {
      const m = url.match(re);
      if (m) return `https://www.youtube.com/embed/${m[1]}`;
    }
    return null;
  }

  $: embedURL = getYouTubeEmbedURL(resource?.published_url);

  // ── Review mode ─────────────────────────────────────────────────────────────
  const REVIEWER_ROLES = ['SubjectExpert', 'TeamLead', 'DSC', 'admin'];
  let reviewMode = false;
  $: canReview = $currentUser && REVIEWER_ROLES.includes($currentUser.role_name);

  function toggleReviewMode() {
    reviewMode = !reviewMode;
  }

  // ── Approve resource ────────────────────────────────────────────────────────
  let isApproving = false;
  let approveError = '';
  let approveSuccess = false;

  $: canApprove = canReview && resource && resource.status !== 'Approved';

  async function approveResource() {
    if (!$currentUser || !$authToken || !resource) return;
    isApproving = true;
    approveError = '';
    approveSuccess = false;
    try {
      const reviewResponse = await reviewAPI.createReview(
        {
          resource_id: resource.resource_id,
          reviewer_id: $currentUser.user_id,
          reviewer_role_id: $currentUser.role_id,
          decision: 'Approved',
        },
        $authToken
      );
      // Use the status returned by the server (ground truth) so the UI
      // always reflects what is actually in the DB.
      if (reviewResponse.resource) {
        resource = { ...resource, ...reviewResponse.resource };
      } else {
        // Fallback: reload the full resource from the API.
        await loadResource();
      }
      approveSuccess = true;
    } catch (err) {
      approveError = err.message || 'Failed to approve resource.';
    } finally {
      isApproving = false;
    }
  }
</script>

<div class="page">
  <TopAppBar 
    on:navigate={handleNavigate}
  />
  
  <main class="content">
    {#if isLoading}
      <div class="loading-container">
        <LoadingSkeleton />
        <p class="loading-text">Loading resource...</p>
      </div>
    {:else if error}
      <div class="error-container">
        <span class="material-symbols-outlined error-icon">error</span>
        <h2>{error}</h2>
        <button class="back-button" on:click={goBack}>
          <span class="material-symbols-outlined">arrow_back</span>
          Back to Home
        </button>
      </div>
    {:else if resource}
      <div class="resource-container">
        <!-- Back button -->
        <button class="back-link" on:click={goBack}>
          <span class="material-symbols-outlined">arrow_back</span>
          Back to Resources
        </button>
        
        <!-- Resource header -->
        <div class="resource-header">
          <div class="header-top-row">
            <div class="category-chip">{resource.category}</div>
            <span class="status-badge status-{resource.status?.toLowerCase().replace(/\s+/g, '-')}">
              <span class="material-symbols-outlined status-icon">contract_edit</span>
              {resource.status}
            </span>
          </div>
          <h1 class="resource-title">{resource.title}</h1>
          
          {#if resource.summary}
            <p class="resource-summary">{resource.summary}</p>
          {/if}
          
          <!-- Metadata -->
          <div class="resource-metadata">
            {#if resource.subjects && resource.subjects.length > 0}
              <div class="metadata-group">
                <span class="material-symbols-outlined">book</span>
                <div class="chip-group">
                  {#each resource.subjects as subject}
                    <span class="chip">{subject}</span>
                  {/each}
                </div>
              </div>
            {/if}
            
            {#if resource.grade_levels && resource.grade_levels.length > 0}
              <div class="metadata-group">
                <span class="material-symbols-outlined">school</span>
                <div class="chip-group">
                  {#each resource.grade_levels as grade}
                    <span class="chip">{grade}</span>
                  {/each}
                </div>
              </div>
            {/if}
          </div>

          <!-- Reviewer actions -->
          {#if canApprove}
            <div class="reviewer-actions">
              {#if approveSuccess}
                <span class="approve-success">
                  <span class="material-symbols-outlined">check_circle</span>
                  Resource approved!
                </span>
              {:else}
                <button
                  class="approve-btn"
                  type="button"
                  on:click={approveResource}
                  disabled={isApproving}
                >
                  {#if isApproving}
                    <span class="material-symbols-outlined spin">progress_activity</span>
                    Approving…
                  {:else}
                    <span class="material-symbols-outlined">verified</span>
                    Approve Resource
                  {/if}
                </button>
                {#if approveError}
                  <span class="approve-error">{approveError}</span>
                {/if}
              {/if}
            </div>
          {/if}
        </div>
        
        <!-- Video content (Video category resources) -->
        {#if resource.category === 'Video'}
          <div class="video-section">

            <!-- Embedded player -->
            {#if embedURL}
              <div class="video-embed-wrapper">
                <iframe
                  src="{embedURL}"
                  title="{resource.title}"
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen
                ></iframe>
              </div>
            {:else}
              <div class="video-not-uploaded">
                <span class="material-symbols-outlined video-pending-icon">pending</span>
                <p>This video hasn't been uploaded to YouTube yet. It will appear here once approved and processed.</p>
              </div>
            {/if}

            <!-- Links row -->
            <div class="video-links">
              {#if resource.published_url}
                <a class="video-link-btn video-link-btn--primary" href="{resource.published_url}" target="_blank" rel="noreferrer">
                  <span class="material-symbols-outlined">smart_display</span>
                  Watch on YouTube
                </a>
              {/if}
              {#if resource.drive_link}
                <a class="video-link-btn" href="{resource.drive_link}" target="_blank" rel="noreferrer">
                  <span class="material-symbols-outlined">folder_open</span>
                  View Source File
                </a>
              {/if}
            </div>

            <!-- Video metadata details -->
            {#if videoMetadata}
              <div class="video-meta-card">
                {#if videoMetadata.youtube_description}
                  <div class="video-meta-row">
                    <span class="video-meta-label">Description</span>
                    <p class="video-meta-value">{videoMetadata.youtube_description}</p>
                  </div>
                {/if}
                {#if videoMetadata.tags && videoMetadata.tags.length > 0}
                  <div class="video-meta-row">
                    <span class="video-meta-label">Tags</span>
                    <div class="video-tags">
                      {#each videoMetadata.tags as tag}
                        <span class="chip">{tag}</span>
                      {/each}
                    </div>
                  </div>
                {/if}
                <div class="video-meta-row video-meta-row--inline">
                  <div class="video-meta-badge">
                    <span class="material-symbols-outlined">privacy_tip</span>
                    {videoMetadata.privacy_status}
                  </div>
                  <div class="video-meta-badge">
                    <span class="material-symbols-outlined">{videoMetadata.made_for_kids ? 'child_care' : 'person'}</span>
                    {videoMetadata.made_for_kids ? 'Made for kids' : 'Not for kids'}
                  </div>
                </div>
              </div>
            {/if}

          </div>

        <!-- Lesson content (non-Video resources) -->
        {:else if lessons && lessons.length > 0}
          <div class="lessons-container">
            {#each lessons as lesson}
              {@const lessonContent = parseLessonContent(lesson)}
              <div class="lesson-section">
              <div class="lesson-header">
                  <h2 class="lesson-title">
                    <span class="lesson-number">Lesson {lesson.lesson_number}</span>
                    {lesson.title}
                  </h2>
                  <div class="lesson-header-actions">
                    {#if lesson.duration_minutes}
                      <div class="lesson-duration">
                        <span class="material-symbols-outlined">schedule</span>
                        {lesson.duration_minutes} minutes
                      </div>
                    {/if}
                    {#if canReview}
                      <button
                        class="review-toggle"
                        class:active={reviewMode}
                        type="button"
                        on:click={toggleReviewMode}
                        title={reviewMode ? 'Hide review comments' : 'Show review comments'}
                      >
                        <span class="material-symbols-outlined">
                          {reviewMode ? 'rate_review' : 'reviews'}
                        </span>
                        {reviewMode ? 'Exit Review Mode' : 'Review Mode'}
                      </button>
                    {/if}
                  </div>
                </div>
                
                {#if lessonContent}
                  <LessonViewer 
                    lessonContent={lessonContent} 
                    userRole={$currentUser?.role}
                    {reviewMode}
                    resourceId={resource.resource_id}
                    currentUser={$currentUser}
                  />
                {:else}
                  <p class="no-content">No lesson content available</p>
                {/if}
              </div>
            {/each}
          </div>
        {:else}
          <div class="no-lessons">
            <span class="material-symbols-outlined">description</span>
            <p>No lessons available for this resource yet.</p>
          </div>
        {/if}
      </div>
    {/if}
  </main>
</div>

<style>
  .page {
    min-height: 100vh;
    background-color: var(--md-sys-color-background);
  }
  
  .content {
    margin-top: 64px;
    padding: var(--md-sys-spacing-lg);
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
  }
  
  .loading-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    gap: 1rem;
  }
  
  .loading-text {
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .error-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 4rem 2rem;
    gap: 1.5rem;
    text-align: center;
  }
  
  .error-icon {
    font-size: 4rem;
    color: var(--md-sys-color-error);
  }
  
  .error-container h2 {
    color: var(--md-sys-color-on-surface);
    margin: 0;
  }
  
  .back-button {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    background-color: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    border-radius: var(--md-sys-shape-corner-full);
    cursor: pointer;
    font-size: 1rem;
    font-weight: 500;
    transition: background-color 0.2s;
  }
  
  .back-button:hover {
    background-color: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
  }
  
  .resource-container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }
  
  .back-link {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--md-sys-color-primary);
    background: none;
    border: none;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 500;
    padding: 0.5rem;
    margin-left: -0.5rem;
    transition: background-color 0.2s;
  }
  
  .back-link:hover {
    background-color: var(--md-sys-color-primary-container);
    border-radius: var(--md-sys-shape-corner-sm);
  }
  
  .resource-header {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .header-top-row {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
  }

  /* Status badge */
  .status-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    padding: 0.25rem 0.75rem;
    border-radius: 999px;
    font-size: 0.8125rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    border: 1.5px solid currentColor;
  }

  .status-icon {
    font-size: 15px;
  }

  /* Per-status colours using MD3 tokens */
  .status-badge.status-draft {
    color: var(--md-sys-color-on-surface-variant);
    background: var(--md-sys-color-surface-variant);
    border-color: var(--md-sys-color-outline-variant);
  }
  .status-badge.status-submitted {
    color: var(--md-sys-color-on-tertiary-container);
    background: var(--md-sys-color-tertiary-container);
    border-color: var(--md-sys-color-tertiary);
  }
  .status-badge.status-underreview {
    color: var(--md-sys-color-on-secondary-container);
    background: var(--md-sys-color-secondary-container);
    border-color: var(--md-sys-color-secondary);
  }
  .status-badge.status-needsrevision {
    color: var(--md-sys-color-on-error-container);
    background: var(--md-sys-color-error-container);
    border-color: var(--md-sys-color-error);
  }
  .status-badge.status-approved {
    color: var(--md-sys-color-on-primary-container);
    background: var(--md-sys-color-primary-container);
    border-color: var(--md-sys-color-primary);
  }
  .status-badge.status-published,
  .status-badge.status-indexed {
    color: var(--md-sys-color-on-primary);
    background: var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }
  .status-badge.status-archived {
    color: var(--md-sys-color-on-surface-variant);
    background: var(--md-sys-color-surface-variant);
    border-color: var(--md-sys-color-outline);
    opacity: 0.7;
  }
  
  .category-chip {
    display: inline-flex;
    align-items: center;
    padding: 0.25rem 0.75rem;
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-on-secondary-container);
    border-radius: var(--md-sys-shape-corner-full);
    font-size: 0.875rem;
    font-weight: 500;
    width: fit-content;
  }
  
  .resource-title {
    font-size: 2.5rem;
    font-weight: 400;
    color: var(--md-sys-color-on-surface);
    margin: 0;
    line-height: 1.2;
  }
  
  .resource-summary {
    font-size: 1.125rem;
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
    line-height: 1.5;
  }
  
  .resource-metadata {
    display: flex;
    flex-wrap: wrap;
    gap: 1.5rem;
    margin-top: 0.5rem;
  }
  
  .metadata-group {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }
  
  .metadata-group .material-symbols-outlined {
    color: var(--md-sys-color-primary);
    font-size: 1.25rem;
  }
  
  .chip-group {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }
  
  .chip {
    padding: 0.25rem 0.75rem;
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
    border-radius: var(--md-sys-shape-corner-full);
    font-size: 0.875rem;
  }
  
  .lessons-container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }
  
  .lesson-section {
    background-color: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-lg);
    padding: 2rem;
  }
  
  .lesson-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 1rem;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
  }

  .lesson-header-actions {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-shrink: 0;
  }

  .review-toggle {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.375rem 0.875rem;
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 999px;
    background: none;
    color: var(--md-sys-color-on-surface-variant);
    font-size: 0.8125rem;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s, color 0.2s, border-color 0.2s;
    white-space: nowrap;
  }

  .review-toggle:hover {
    background: var(--md-sys-color-surface-variant);
  }

  .review-toggle.active {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border-color: var(--md-sys-color-primary);
  }

  .review-toggle .material-symbols-outlined {
    font-size: 18px;
  }

  /* ── Reviewer actions (approve) ──────────────────────────────────────────── */
  .reviewer-actions {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-top: 1rem;
    flex-wrap: wrap;
  }

  .approve-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.5rem 1.25rem;
    background: var(--md-sys-color-tertiary, #386a20);
    color: var(--md-sys-color-on-tertiary, #fff);
    border: none;
    border-radius: 999px;
    font-size: 0.875rem;
    font-weight: 600;
    cursor: pointer;
    transition: opacity 0.2s, background 0.2s;
  }

  .approve-btn:hover:not(:disabled) {
    opacity: 0.88;
  }

  .approve-btn:disabled {
    opacity: 0.38;
    cursor: not-allowed;
  }

  .approve-btn .material-symbols-outlined {
    font-size: 18px;
  }

  .approve-success {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    color: var(--md-sys-color-tertiary, #386a20);
    font-size: 0.875rem;
    font-weight: 600;
  }

  .approve-success .material-symbols-outlined {
    font-size: 18px;
  }

  .approve-error {
    color: var(--md-sys-color-error);
    font-size: 0.8125rem;
  }

  @keyframes spin {
    to { rotate: 360deg; }
  }

  .spin {
    animation: spin 0.8s linear infinite;
  }

  .lesson-title {
    font-size: 1.75rem;
    font-weight: 400;
    color: var(--md-sys-color-on-surface);
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }
  
  .lesson-number {
    font-size: 0.875rem;
    color: var(--md-sys-color-primary);
    font-weight: 500;
    text-transform: uppercase;
  }
  
  .lesson-duration {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--md-sys-color-on-surface-variant);
    font-size: 0.875rem;
    white-space: nowrap;
  }
  
  .no-content,
  .no-lessons {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 1rem;
    padding: 3rem 2rem;
    color: var(--md-sys-color-on-surface-variant);
    text-align: center;
  }

  /* ── Video section ──────────────────────────────────────────────────────── */
  .video-section {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .video-embed-wrapper {
    position: relative;
    width: 100%;
    aspect-ratio: 16 / 9;
    border-radius: var(--md-sys-shape-corner-md);
    overflow: hidden;
    background: #000;
  }

  .video-embed-wrapper iframe {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    border: none;
  }

  .video-not-uploaded {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
    padding: 3rem 2rem;
    background: var(--md-sys-color-surface-variant);
    border-radius: var(--md-sys-shape-corner-md);
    color: var(--md-sys-color-on-surface-variant);
    text-align: center;
  }

  .video-pending-icon {
    font-size: 3rem;
  }

  .video-links {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
  }

  .video-link-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.6rem 1.25rem;
    border-radius: var(--md-sys-shape-corner-full);
    border: 1px solid var(--md-sys-color-outline);
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    text-decoration: none;
    font-size: 0.9rem;
    font-weight: 500;
    transition: background 0.2s;
  }

  .video-link-btn:hover {
    background: var(--md-sys-color-surface-variant);
  }

  .video-link-btn--primary {
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border-color: transparent;
  }

  .video-link-btn--primary:hover {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
  }

  .video-meta-card {
    background: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-md);
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
  }

  .video-meta-row {
    display: flex;
    flex-direction: column;
    gap: 0.4rem;
  }

  .video-meta-row--inline {
    flex-direction: row;
    flex-wrap: wrap;
    gap: 0.75rem;
    align-items: center;
  }

  .video-meta-label {
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--md-sys-color-on-surface-variant);
  }

  .video-meta-value {
    font-size: 0.95rem;
    color: var(--md-sys-color-on-surface);
    line-height: 1.5;
    margin: 0;
    white-space: pre-wrap;
  }

  .video-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .video-meta-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    padding: 0.3rem 0.75rem;
    border-radius: var(--md-sys-shape-corner-full);
    background: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
    font-size: 0.825rem;
    font-weight: 500;
    text-transform: capitalize;
  }

  .video-meta-badge .material-symbols-outlined {
    font-size: 1rem;
  }
  
  .no-lessons .material-symbols-outlined {
    font-size: 3rem;
    opacity: 0.5;
  }
  
  @media (max-width: 768px) {
    .content {
      padding: var(--md-sys-spacing-md);
    }
    
    .resource-title {
      font-size: 2rem;
    }
    
    .lesson-header {
      flex-direction: column;
    }
    
    .lesson-section {
      padding: 1.5rem;
    }
  }
</style>
