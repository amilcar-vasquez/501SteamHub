<!-- filename: ui/src/lib/components/admin/ResourceAdminTable.svelte -->
<script>
  import { onMount } from 'svelte';
  import { authToken } from '../../../stores/auth.js';
  import { resourceAPI } from '../../../api/client.js';
  import StatusOverrideDialog from './StatusOverrideDialog.svelte';

  const STATUS_OPTIONS = [
    '', 'Draft', 'Submitted', 'UnderReview', 'NeedsRevision',
    'Rejected', 'Approved', 'DesignCurate', 'Published', 'Indexed', 'Archived',
  ];

  const STATUS_CHIP_CLASS = {
    Draft: 'chip-draft',
    Submitted: 'chip-submitted',
    UnderReview: 'chip-review',
    NeedsRevision: 'chip-revision',
    Rejected: 'chip-rejected',
    Approved: 'chip-approved',
    DesignCurate: 'chip-design',
    Published: 'chip-published',
    Indexed: 'chip-indexed',
    Archived: 'chip-archived',
  };

  let token = null;
  authToken.subscribe(v => (token = v));

  let resources = [];
  let isLoading = true;
  let loadError = '';

  let filterStatus = '';
  let searchQuery = '';

  let dialogOpen = false;
  let selectedResource = null;

  onMount(loadResources);

  async function loadResources() {
    isLoading = true;
    loadError = '';
    try {
      const data = await resourceAPI.getAll({ status: filterStatus, page_size: 100 });
      resources = data.resources || [];
    } catch (err) {
      loadError = err.message || 'Failed to load resources.';
    } finally {
      isLoading = false;
    }
  }

  $: filteredResources = resources.filter(r => {
    const q = searchQuery.trim().toLowerCase();
    return !q || r.title.toLowerCase().includes(q);
  });

  function openManage(resource) {
    selectedResource = resource;
    dialogOpen = true;
  }

  function handleStatusChanged(event) {
    const updated = event.detail.resource;
    resources = resources.map(r =>
      r.resource_id === updated.resource_id ? updated : r
    );
    dialogOpen = false;
  }

  async function handleFilterChange() {
    await loadResources();
  }
</script>

<section class="panel" aria-label="Resource Admin Panel">
  <header class="panel-header">
    <h2 class="title-large panel-title">
      <span class="material-symbols-outlined">folder_managed</span>
      Resources
    </h2>
  </header>

  <!-- Toolbar -->
  <div class="toolbar">
    <div class="search-wrapper">
      <span class="material-symbols-outlined search-icon">search</span>
      <input
        class="search-input body-medium"
        type="text"
        placeholder="Search by title…"
        bind:value={searchQuery}
        aria-label="Search resources"
      />
    </div>

    <label class="filter-label label-medium" for="status-filter">Status</label>
    <select
      id="status-filter"
      class="filter-select body-medium"
      bind:value={filterStatus}
      on:change={handleFilterChange}
    >
      {#each STATUS_OPTIONS as s}
        <option value={s}>{s === '' ? 'All statuses' : s}</option>
      {/each}
    </select>

    <button class="btn-icon" on:click={loadResources} aria-label="Refresh resources" title="Refresh">
      <span class="material-symbols-outlined">refresh</span>
    </button>
  </div>

  <!-- Table -->
  {#if isLoading}
    <div class="empty-state body-medium">
      <span class="material-symbols-outlined spinning">progress_activity</span>
      Loading resources…
    </div>
  {:else if loadError}
    <div class="empty-state body-medium error">
      <span class="material-symbols-outlined">warning</span>
      {loadError}
      <button class="retry-btn label-medium" on:click={loadResources}>Retry</button>
    </div>
  {:else if filteredResources.length === 0}
    <div class="empty-state body-medium">No resources found.</div>
  {:else}
    <div class="table-wrapper">
      <table class="resource-table" aria-label="Resources list">
        <thead>
          <tr>
            <th class="label-medium">Title</th>
            <th class="label-medium">Category</th>
            <th class="label-medium">Status</th>
            <th class="label-medium">Created</th>
            <th class="label-medium" aria-label="Actions"></th>
          </tr>
        </thead>
        <tbody>
          {#each filteredResources as resource (resource.resource_id)}
            <tr>
              <td class="body-medium title-cell">{resource.title}</td>
              <td class="body-small">{resource.category}</td>
              <td>
                <span class="status-chip label-small {STATUS_CHIP_CLASS[resource.status] || ''}">
                  {resource.status}
                </span>
              </td>
              <td class="body-small date-cell">
                {new Date(resource.created_at).toLocaleDateString()}
              </td>
              <td class="action-cell">
                <button
                  class="btn-tonal label-small"
                  on:click={() => openManage(resource)}
                >
                  <span class="material-symbols-outlined">tune</span>
                  Manage
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</section>

<StatusOverrideDialog
  bind:open={dialogOpen}
  resource={selectedResource}
  on:statusChanged={handleStatusChanged}
/>

<style>
  .panel {
    background: var(--md-sys-color-surface);
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,.12);
  }

  .panel-header {
    margin-bottom: 20px;
  }

  .panel-title {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--md-sys-color-on-surface);
    margin: 0;
    font-size: 20px;
    font-weight: 500;
  }
  .panel-title .material-symbols-outlined { font-size: 22px; }

  /* Toolbar */
  .toolbar {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 20px;
  }

  .search-wrapper {
    position: relative;
    flex: 1 1 220px;
  }
  .search-icon {
    position: absolute;
    left: 10px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--md-sys-color-on-surface-variant);
    font-size: 18px;
  }
  .search-input {
    width: 100%;
    padding: 9px 12px 9px 36px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 24px;
    background: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface);
    font-size: 14px;
    font-family: inherit;
    box-sizing: border-box;
  }
  .search-input:focus { outline: none; border-color: var(--md-sys-color-primary); }

  .filter-label { color: var(--md-sys-color-on-surface-variant); white-space: nowrap; }

  .filter-select {
    padding: 8px 12px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-size: 14px;
    font-family: inherit;
  }
  .filter-select:focus { outline: none; border-color: var(--md-sys-color-primary); }

  .btn-icon {
    background: none;
    border: none;
    cursor: pointer;
    padding: 6px;
    border-radius: 50%;
    color: var(--md-sys-color-on-surface-variant);
    display: flex;
    align-items: center;
    transition: background 0.15s;
  }
  .btn-icon:hover { background: var(--md-sys-color-surface-variant); }

  /* Empty / loading */
  .empty-state {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 32px 0;
    justify-content: center;
    color: var(--md-sys-color-on-surface-variant);
  }
  .empty-state.error { color: var(--md-sys-color-error); }
  .retry-btn {
    background: none;
    border: none;
    cursor: pointer;
    color: var(--md-sys-color-primary);
    text-decoration: underline;
    font-family: inherit;
  }

  @keyframes spin { to { transform: rotate(360deg); } }
  .spinning { animation: spin 1s linear infinite; }

  /* Table */
  .table-wrapper {
    overflow-x: auto;
  }

  .resource-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }

  .resource-table th {
    text-align: left;
    padding: 8px 12px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    color: var(--md-sys-color-on-surface-variant);
    white-space: nowrap;
  }

  .resource-table td {
    padding: 12px 12px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    vertical-align: middle;
  }

  .resource-table tbody tr:hover {
    background: color-mix(in srgb, var(--md-sys-color-primary) 5%, transparent);
  }

  .title-cell {
    max-width: 320px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-weight: 500;
    color: var(--md-sys-color-on-surface);
  }

  .date-cell { color: var(--md-sys-color-on-surface-variant); white-space: nowrap; }

  .action-cell { white-space: nowrap; }

  /* Status chips */
  .status-chip {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-weight: 500;
    white-space: nowrap;
  }
  .chip-draft     { background: #e0e0e0; color: #424242; }
  .chip-submitted { background: #e3f2fd; color: #0d47a1; }
  .chip-review    { background: #fff8e1; color: #e65100; }
  .chip-revision  { background: #fce4ec; color: #880e4f; }
  .chip-rejected  { background: #ffebee; color: #b71c1c; }
  .chip-approved  { background: #e8f5e9; color: #1b5e20; }
  .chip-design    { background: #f3e5f5; color: #4a148c; }
  .chip-published { background: #e0f7fa; color: #006064; }
  .chip-indexed   { background: #e8eaf6; color: #1a237e; }
  .chip-archived  { background: #efebe9; color: #3e2723; }

  /* Manage button */
  .btn-tonal {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 6px 14px;
    border-radius: 16px;
    border: none;
    cursor: pointer;
    background: color-mix(in srgb, var(--md-sys-color-secondary) 20%, var(--md-sys-color-surface));
    color: var(--md-sys-color-on-secondary-container, var(--md-sys-color-secondary));
    font-family: inherit;
    font-size: 12px;
    font-weight: 600;
    transition: opacity 0.15s;
  }
  .btn-tonal .material-symbols-outlined { font-size: 16px; }
  .btn-tonal:hover { opacity: 0.8; }
</style>
