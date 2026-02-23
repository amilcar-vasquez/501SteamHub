<script>
  import { onMount } from 'svelte';
  import ResourceCard from '../../../components/ResourceCard.svelte';
  import LoadingSkeleton from '../../../components/LoadingSkeleton.svelte';
  import { resourceAPI } from '../../../api/client.js';
  import { navigateTo } from '../../../router.js';

  // Filters fed in from ReviewerDashboard via on:filterChange
  export let filters = { subject: '', grade_level: '', status: '' };

  let resources = [];
  let isLoading = true;
  let loadError = '';

  // Reload whenever filters change
  $: filters, loadQueue();

  onMount(loadQueue);

  async function loadQueue() {
    isLoading = true;
    loadError = '';
    try {
      const params = {};

      // Default to pending-review statuses when no explicit status is chosen
      if (filters.status) {
        params.status = filters.status;
      } else {
        // Fetch Submitted + UnderReview + NeedsRevision by making two requests
        // and merging, because the current API supports a single status param.
        // We show all three "in-flight" statuses by default.
        const [sub, rev, needs] = await Promise.all([
          resourceAPI.getAll({ ...params, status: 'Submitted' }),
          resourceAPI.getAll({ ...params, status: 'UnderReview' }),
          resourceAPI.getAll({ ...params, status: 'NeedsRevision' }),
        ]);
        const merged = [
          ...(sub.resources || []),
          ...(rev.resources || []),
          ...(needs.resources || []),
        ];
        resources = mapResources(merged);
        return;
      }

      if (filters.subject)     params.subject     = filters.subject;
      if (filters.grade_level) params.grade_level = filters.grade_level;

      const resp = await resourceAPI.getAll(params);
      resources = mapResources(resp.resources || []);
    } catch (err) {
      loadError = err.message || 'Failed to load queue.';
      resources = [];
    } finally {
      isLoading = false;
    }
  }

  function mapResources(list) {
    return list.map(r => ({
      id:                 r.resource_id,
      category:           r.category,
      title:              r.title,
      description:        r.summary || 'No description available',
      subject:            r.subjects?.[0] ?? 'General',
      subjects:           r.subjects  ?? [],
      grade:              r.grade_levels?.[0] ?? 'Mixed',
      grades:             r.grade_levels ?? [],
      iloCount:           0,
      contributor:        `Contributor #${r.contributor_id}`,
      viewCount:          0,
      contributionScore:  0,
      status:             r.status,
      slug:               r.slug,
    }));
  }

  function openReview(slug) {
    navigateTo(`/resources/${slug}`);
  }
</script>

<section class="queue-section" aria-label="Review queue">
  <div class="queue-header">
    <h2 class="title-large queue-title">Review Queue</h2>
    <span class="resource-count label-medium">
      {#if !isLoading}{resources.length} resource{resources.length !== 1 ? 's' : ''}{/if}
    </span>
  </div>

  {#if loadError}
    <div class="empty-state error">
      <span class="material-symbols-outlined">error</span>
      <p class="body-medium">{loadError}</p>
      <button class="action-btn label-medium" on:click={loadQueue}>Try Again</button>
    </div>
  {:else if isLoading}
    <div class="resource-grid">
      {#each Array(6) as _}
        <LoadingSkeleton />
      {/each}
    </div>
  {:else if resources.length === 0}
    <div class="empty-state">
      <span class="material-symbols-outlined">check_circle</span>
      <p class="title-medium">Queue is clear</p>
      <p class="body-medium">No resources match the current filters.</p>
    </div>
  {:else}
    <div class="resource-grid">
      {#each resources as resource (resource.id)}
        <div class="card-wrapper">
          <ResourceCard
            id={resource.id}
            category={resource.category}
            title={resource.title}
            description={resource.description}
            subject={resource.subject}
            subjects={resource.subjects}
            grade={resource.grade}
            grades={resource.grades}
            iloCount={resource.iloCount}
            contributor={resource.contributor}
            viewCount={resource.viewCount}
            contributionScore={resource.contributionScore}
            status={resource.status}
            showStatus={true}
            slug={resource.slug}
          />
          <button
            class="review-btn label-large"
            on:click={() => openReview(resource.slug)}
            disabled={!resource.slug}
          >
            <span class="material-symbols-outlined">rate_review</span>
            Open Review
          </button>
        </div>
      {/each}
    </div>
  {/if}
</section>

<style>
  .queue-section {
    flex: 1;
  }

  .queue-header {
    display: flex;
    align-items: baseline;
    gap: 12px;
    margin-bottom: 16px;
  }

  .queue-title {
    color: var(--md-sys-color-on-surface);
  }

  .resource-count {
    color: var(--md-sys-color-on-surface-variant);
  }

  .resource-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
  }

  .card-wrapper {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .review-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    width: 100%;
    padding: 10px 16px;
    border-radius: 999px;
    border: none;
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    cursor: pointer;
    box-shadow: var(--md-sys-elevation-1);
    transition: background 0.2s, box-shadow 0.2s;
  }
  .review-btn:hover {
    background: #8a4590;
    box-shadow: var(--md-sys-elevation-2);
  }
  .review-btn:disabled {
    background: var(--md-sys-color-surface-container-high);
    color: var(--md-sys-color-on-surface-variant);
    box-shadow: none;
    cursor: not-allowed;
  }
  .review-btn .material-symbols-outlined {
    font-size: 18px;
  }

  /* Empty / error state */
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 320px;
    gap: 12px;
    color: var(--md-sys-color-on-surface-variant);
    text-align: center;
    border: 1px dashed var(--md-sys-color-outline-variant);
    border-radius: 16px;
  }
  .empty-state .material-symbols-outlined {
    font-size: 56px;
    color: var(--md-sys-color-outline);
  }
  .empty-state.error .material-symbols-outlined {
    color: var(--md-sys-color-error);
  }
  .action-btn {
    padding: 8px 20px;
    border-radius: 999px;
    border: 1px solid var(--md-sys-color-outline-variant);
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-primary);
    cursor: pointer;
  }

  @media (max-width: 1024px) {
    .resource-grid { grid-template-columns: repeat(2, 1fr); }
  }
  @media (max-width: 600px) {
    .resource-grid { grid-template-columns: 1fr; }
  }
</style>
