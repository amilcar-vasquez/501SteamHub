<script>
  import { onMount } from 'svelte';
  import { authToken } from '../../../stores/auth.js';
  import { resourceAPI } from '../../../api/client.js';

  let token = null;
  authToken.subscribe(v => (token = v));

  let metrics = null;
  let isLoading = true;
  let loadError = '';

  const CARDS = [
    {
      key: 'submitted',
      label: 'Submitted',
      icon: 'upload_file',
      colorClass: 'metric-submitted',
    },
    {
      key: 'under_review',
      label: 'Under Review',
      icon: 'rate_review',
      colorClass: 'metric-review',
    },
    {
      key: 'needs_revision',
      label: 'Needs Revision',
      icon: 'edit_note',
      colorClass: 'metric-revision',
    },
    {
      key: 'approved',
      label: 'Approved',
      icon: 'check_circle',
      colorClass: 'metric-approved',
    },
    {
      key: 'published',
      label: 'Published',
      icon: 'public',
      colorClass: 'metric-published',
    },
  ];

  onMount(loadMetrics);

  async function loadMetrics() {
    isLoading = true;
    loadError = '';
    try {
      const data = await resourceAPI.getMetrics(token);
      metrics = data.metrics;
    } catch (err) {
      loadError = err.message || 'Failed to load metrics.';
    } finally {
      isLoading = false;
    }
  }
</script>

<div class="metrics-row" role="region" aria-label="Resource status metrics">
  {#if isLoading}
    {#each CARDS as _}
      <div class="metric-card metric-skeleton">
        <div class="skeleton-icon"></div>
        <div class="skeleton-count"></div>
        <div class="skeleton-label"></div>
      </div>
    {/each}
  {:else if loadError}
    <div class="metrics-error body-medium">
      <span class="material-symbols-outlined">warning</span>
      {loadError}
      <button class="retry-btn label-medium" on:click={loadMetrics}>Retry</button>
    </div>
  {:else}
    {#each CARDS as card}
      <div class="metric-card {card.colorClass}">
        <span class="material-symbols-outlined metric-icon">{card.icon}</span>
        <span class="metric-count display-count">
          {metrics?.[card.key] ?? 0}
        </span>
        <span class="metric-label label-medium">{card.label}</span>
      </div>
    {/each}
  {/if}
</div>

<style>
  .metrics-row {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 12px;
    margin-bottom: 24px;
  }

  @media (max-width: 1024px) {
    .metrics-row {
      grid-template-columns: repeat(3, 1fr);
    }
  }
  @media (max-width: 600px) {
    .metrics-row {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  .metric-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    padding: 20px 12px;
    border-radius: 16px;
    background: var(--md-sys-color-surface-container-low);
    border: 1px solid var(--md-sys-color-outline-variant);
    box-shadow: var(--md-sys-elevation-1);
    transition: box-shadow 0.2s, transform 0.15s;
  }
  .metric-card:hover {
    box-shadow: var(--md-sys-elevation-2);
    transform: translateY(-1px);
  }

  .metric-icon {
    font-size: 28px;
    margin-bottom: 2px;
  }
  .display-count {
    font-family: 'Roboto', sans-serif;
    font-size: 32px;
    font-weight: 500;
    line-height: 1;
  }
  .metric-label {
    color: var(--md-sys-color-on-surface-variant);
    text-align: center;
  }

  /* Per-status tints */
  .metric-submitted  { --accent: var(--md-sys-color-secondary); background: var(--md-sys-color-secondary-container); }
  .metric-submitted .metric-icon,
  .metric-submitted .display-count { color: var(--md-sys-color-on-secondary-container); }

  .metric-review { background: var(--md-sys-color-primary-container); }
  .metric-review .metric-icon,
  .metric-review .display-count { color: var(--md-sys-color-on-primary-container); }

  .metric-revision { background: var(--md-sys-color-warning-container); }
  .metric-revision .metric-icon,
  .metric-revision .display-count { color: var(--md-sys-color-warning); }

  .metric-approved { background: var(--md-sys-color-success-container); }
  .metric-approved .metric-icon,
  .metric-approved .display-count { color: var(--md-sys-color-success); }

  .metric-published { background: #e8f5e9; }
  .metric-published .metric-icon,
  .metric-published .display-count { color: #2e7d32; }

  /* Skeleton */
  .metric-skeleton { background: var(--md-sys-color-surface-container); }
  .skeleton-icon,
  .skeleton-count,
  .skeleton-label {
    border-radius: 8px;
    background: var(--md-sys-color-surface-container-highest);
    animation: shimmer 1.4s infinite;
  }
  .skeleton-icon  { width: 32px; height: 32px; border-radius: 50%; }
  .skeleton-count { width: 48px; height: 32px; margin: 4px 0; }
  .skeleton-label { width: 70px; height: 14px; }

  @keyframes shimmer {
    0%, 100% { opacity: 0.5; }
    50%       { opacity: 1; }
  }

  .metrics-error {
    grid-column: 1 / -1;
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--md-sys-color-error);
    padding: 12px;
  }
  .retry-btn {
    background: none;
    border: 1px solid currentColor;
    border-radius: 999px;
    padding: 4px 12px;
    cursor: pointer;
    color: inherit;
  }
</style>
