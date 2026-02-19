<script>
  import { onMount } from 'svelte';
  import { slide } from 'svelte/transition';
  import { authToken } from '../../stores/auth.js';
  import { getReviewComments, createReviewComment, resolveReviewComment } from '../../lib/api/reviewComments.js';

  /** @type {number} */
  export let resourceId;
  /** @type {number|null} block position inside lesson_content.blocks */
  export let blockIndex = null;
  /** @type {string|null} block type (objectives, activity, etc.) */
  export let section = null;
  /** @type {object|null} currentUser object from auth store */
  export let currentUser = null;

  // Roles that may add new review comments
  const REVIEWER_ROLES = ['SubjectExpert', 'TeamLead', 'DSC', 'admin'];

  $: canAddComments = currentUser && REVIEWER_ROLES.includes(currentUser.role_name);

  // ── State ──────────────────────────────────────────────────────────────────

  let allComments = [];       // raw list from API
  let isLoading = true;
  let loadError = '';
  let submitError = '';
  let isSubmitting = false;
  let newComment = '';

  // Filtered to this block/section
  $: blockComments = allComments.filter(c => {
    const sectionMatch = section == null || c.section === section;
    const indexMatch   = blockIndex == null || c.block_index === blockIndex;
    return sectionMatch && indexMatch;
  });

  $: openCount     = blockComments.filter(c => !c.resolved).length;
  $: resolvedCount = blockComments.filter(c =>  c.resolved).length;

  // ── Load ───────────────────────────────────────────────────────────────────

  let token = null;
  authToken.subscribe(v => (token = v));

  onMount(async () => {
    await loadComments();
  });

  async function loadComments() {
    if (!resourceId || !token) {
      isLoading = false;
      return;
    }
    isLoading = true;
    loadError = '';
    try {
      const res = await getReviewComments(resourceId, token);
      allComments = res.review_comments || [];
    } catch (err) {
      loadError = err.message || 'Failed to load review comments.';
    } finally {
      isLoading = false;
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  async function handleSubmit() {
    if (!newComment.trim() || !currentUser || !token) return;

    isSubmitting = true;
    submitError = '';

    const payload = {
      resource_id: resourceId,
      reviewer_id: currentUser.user_id,
      comment:     newComment.trim(),
      section:     section    || undefined,
      block_index: blockIndex != null ? blockIndex : undefined,
    };

    try {
      const res = await createReviewComment(payload, token);
      allComments = [...allComments, res.review_comment];
      newComment = '';
    } catch (err) {
      submitError = err.message || 'Failed to submit comment.';
    } finally {
      isSubmitting = false;
    }
  }

  // ── Resolve ────────────────────────────────────────────────────────────────

  async function handleResolve(commentId) {
    if (!token) return;
    try {
      const res = await resolveReviewComment(commentId, token);
      allComments = allComments.map(c =>
        c.comment_id === commentId ? res.review_comment : c
      );
    } catch (err) {
      // Surface error inline near the comment via a store or simple alert
      console.error('Failed to resolve comment:', err);
    }
  }

  // ── Formatting helpers ─────────────────────────────────────────────────────

  function fmtDate(iso) {
    if (!iso) return '';
    return new Date(iso).toLocaleString(undefined, {
      dateStyle: 'medium',
      timeStyle: 'short',
    });
  }
</script>

<!-- Only render when there is something to show or the user can add a comment -->
{#if !isLoading && (blockComments.length > 0 || canAddComments)}
  <div class="review-panel" transition:slide={{ duration: 180 }}>
    <!-- Header -->
    <div class="panel-header">
      <span class="material-symbols-outlined header-icon">rate_review</span>
      <span class="header-title">Review Comments</span>
      {#if openCount > 0}
        <span class="badge open">{openCount} open</span>
      {/if}
      {#if resolvedCount > 0}
        <span class="badge resolved">{resolvedCount} resolved</span>
      {/if}
    </div>

    <!-- Load error -->
    {#if loadError}
      <p class="inline-error">{loadError}</p>
    {/if}

    <!-- Comment list -->
    {#if blockComments.length > 0}
      <ul class="comment-list" role="list">
        {#each blockComments as c (c.comment_id)}
          <li class="comment-item" class:is-resolved={c.resolved} transition:slide={{ duration: 150 }}>
            <div class="comment-meta">
              <span class="reviewer-label">
                <span class="material-symbols-outlined meta-icon">person</span>
                Reviewer #{c.reviewer_id}
              </span>
              <span class="comment-date">{fmtDate(c.created_at)}</span>
              {#if c.resolved}
                <span class="status-chip resolved">
                  <span class="material-symbols-outlined chip-icon">check_circle</span>
                  Resolved
                </span>
              {:else}
                <span class="status-chip open">Open</span>
              {/if}
            </div>

            <p class="comment-text">{c.comment}</p>

            {#if c.resolved && c.resolved_at}
              <p class="resolved-at">Resolved {fmtDate(c.resolved_at)}</p>
            {/if}

            {#if canAddComments && !c.resolved}
              <button
                class="resolve-btn"
                type="button"
                on:click={() => handleResolve(c.comment_id)}
              >
                <span class="material-symbols-outlined">check</span>
                Mark resolved
              </button>
            {/if}
          </li>
        {/each}
      </ul>
    {:else if !loadError}
      <p class="empty-message">No comments on this block yet.</p>
    {/if}

    <!-- New comment form (reviewers only) -->
    {#if canAddComments}
      <div class="add-comment">
        <textarea
          class="comment-input"
          bind:value={newComment}
          placeholder="Add a review comment…"
          rows="3"
          disabled={isSubmitting}
          aria-label="New review comment"
        ></textarea>
        {#if submitError}
          <p class="inline-error">{submitError}</p>
        {/if}
        <div class="add-comment-actions">
          <button
            class="submit-btn"
            type="button"
            on:click={handleSubmit}
            disabled={isSubmitting || !newComment.trim()}
          >
            {#if isSubmitting}
              <span class="material-symbols-outlined spin">progress_activity</span>
              Submitting…
            {:else}
              <span class="material-symbols-outlined">add_comment</span>
              Add Comment
            {/if}
          </button>
        </div>
      </div>
    {/if}
  </div>
{/if}

<style>
  /* ── Panel shell ─────────────────────────────────────────────────────────── */
  .review-panel {
    margin-top: 0.875rem;
    background: var(--md-sys-color-surface-container-low);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-left: 3px solid var(--md-sys-color-primary);
    border-radius: 0 8px 8px 0;
    padding: 0.875rem 1rem;
    font-size: 0.8125rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  /* ── Header ──────────────────────────────────────────────────────────────── */
  .panel-header {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    color: var(--md-sys-color-primary);
    font-weight: 600;
    font-size: 0.8125rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  .header-icon {
    font-size: 16px;
  }

  .header-title {
    flex: 1;
  }

  .badge {
    padding: 0.125rem 0.5rem;
    border-radius: 999px;
    font-size: 0.6875rem;
    font-weight: 600;
  }

  .badge.open {
    background: var(--md-sys-color-error-container);
    color: var(--md-sys-color-on-error-container);
  }

  .badge.resolved {
    background: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
  }

  /* ── Comment list ────────────────────────────────────────────────────────── */
  .comment-list {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 0.625rem;
  }

  .comment-item {
    background: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 8px;
    padding: 0.625rem 0.75rem;
    display: flex;
    flex-direction: column;
    gap: 0.375rem;
    transition: opacity 0.2s;
  }

  .comment-item.is-resolved {
    opacity: 0.6;
  }

  /* ── Comment meta row ────────────────────────────────────────────────────── */
  .comment-meta {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .reviewer-label {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
  }

  .meta-icon {
    font-size: 14px;
  }

  .comment-date {
    color: var(--md-sys-color-on-surface-variant);
    opacity: 0.7;
    margin-left: auto;
    font-size: 0.75rem;
  }

  .status-chip {
    display: inline-flex;
    align-items: center;
    gap: 0.2rem;
    padding: 0.1rem 0.5rem;
    border-radius: 999px;
    font-size: 0.6875rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-chip.open {
    background: var(--md-sys-color-error-container);
    color: var(--md-sys-color-on-error-container);
  }

  .status-chip.resolved {
    background: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
  }

  .chip-icon {
    font-size: 13px;
  }

  /* ── Comment text ────────────────────────────────────────────────────────── */
  .comment-text {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    line-height: 1.5;
    white-space: pre-wrap;
    word-break: break-word;
  }

  .resolved-at {
    margin: 0;
    font-size: 0.75rem;
    color: var(--md-sys-color-on-surface-variant);
    opacity: 0.7;
  }

  /* ── Resolve button ──────────────────────────────────────────────────────── */
  .resolve-btn {
    align-self: flex-start;
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.25rem 0.75rem;
    background: none;
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 999px;
    color: var(--md-sys-color-on-surface-variant);
    font-size: 0.75rem;
    cursor: pointer;
    transition: background 0.15s, color 0.15s;
  }

  .resolve-btn:hover {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border-color: var(--md-sys-color-primary);
  }

  .resolve-btn .material-symbols-outlined {
    font-size: 14px;
  }

  /* ── New comment form ────────────────────────────────────────────────────── */
  .add-comment {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    border-top: 1px solid var(--md-sys-color-outline-variant);
    padding-top: 0.75rem;
  }

  .comment-input {
    width: 100%;
    padding: 0.625rem 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.8125rem;
    font-family: inherit;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    resize: vertical;
    min-height: 72px;
    transition: border-color 0.15s;
    box-sizing: border-box;
  }

  .comment-input:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  .comment-input:disabled {
    opacity: 0.5;
  }

  .add-comment-actions {
    display: flex;
    justify-content: flex-end;
  }

  .submit-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.375rem;
    padding: 0.375rem 1rem;
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    border-radius: 999px;
    font-size: 0.8125rem;
    font-weight: 500;
    cursor: pointer;
    transition: background 0.2s;
  }

  .submit-btn:hover:not(:disabled) {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
  }

  .submit-btn:disabled {
    opacity: 0.38;
    cursor: not-allowed;
  }

  .submit-btn .material-symbols-outlined {
    font-size: 16px;
  }

  /* ── Misc ────────────────────────────────────────────────────────────────── */
  .empty-message {
    margin: 0;
    color: var(--md-sys-color-on-surface-variant);
    opacity: 0.65;
    font-size: 0.8125rem;
  }

  .inline-error {
    margin: 0;
    color: var(--md-sys-color-error);
    font-size: 0.8125rem;
  }

  @keyframes spin {
    to { rotate: 360deg; }
  }

  .spin {
    animation: spin 0.8s linear infinite;
  }
</style>
