<script>
  import { onMount } from 'svelte';
  import TopAppBar from '../components/TopAppBar.svelte';
  import LoadingSkeleton from '../components/LoadingSkeleton.svelte';
  import { iloAPI } from '../api/client.js';
  import { navigateTo } from '../router.js';

  let ilos = [];
  let isLoading = true;
  let error = '';
  let expandedIloId = null;

  // Filter state
  let filters = {
    subject: '',
    grade: '',
    cycle: '',
    strand: ''
  };

  // Available filter options
  const subjects = [
    'Computer Science',
    'Information Technology',
    'Science and Technology',
    'Engineering',
    'Robotics',
    'Expressive Arts',
    'Belizean History',
    'Mathematics',
    'Language Arts',
    'Social Studies',
    'Physical Education',
    'Health Education'
  ];

  const grades = [
    'Infant 1', 'Infant 2', 'Infant 3',
    'Standard 1', 'Standard 2', 'Standard 3', 'Standard 4', 'Standard 5', 'Standard 6',
    'Form 1'
  ];

  const cycles = ['1', '2', '3', '4'];

  onMount(() => {
    loadILOs();
  });

  async function loadILOs() {
    isLoading = true;
    error = '';

    try {
      const response = await iloAPI.getAll(filters);
      ilos = response.ilos || [];
      console.log('ILOs loaded:', ilos);
    } catch (err) {
      console.error('Failed to load ILOs:', err);
      error = err.message || 'Failed to load ILOs. Please try again.';
    } finally {
      isLoading = false;
    }
  }

  function applyFilters() {
    expandedIloId = null;
    loadILOs();
  }

  function clearFilters() {
    filters = { subject: '', grade: '', cycle: '', strand: '' };
    expandedIloId = null;
    loadILOs();
  }

  function toggleExpanded(iloId) {
    expandedIloId = expandedIloId === iloId ? null : iloId;
  }

  function getStrandLabel(strandId) {
    // This is a placeholder - in a real app, you might fetch strand names
    return strandId || 'Unknown Strand';
  }
</script>

<div class="app">
  <TopAppBar />

  <main class="ilo-browser">
    <div class="page-header">
      <h1 class="headline-large">ILO Browser</h1>
      <p class="body-medium text-secondary">
        Browse and explore all Intended Learning Outcomes for the 501 STEAM Hub curriculum
      </p>
    </div>

    <!-- Filters Panel -->
    <div class="filters-panel">
      <div class="filters-grid">
        <div class="filter-field">
          <label for="subject-filter" class="label-medium">Subject</label>
          <select id="subject-filter" bind:value={filters.subject} class="filter-select">
            <option value="">All Subjects</option>
            {#each subjects as subject}
              <option value={subject}>{subject}</option>
            {/each}
          </select>
        </div>

        <div class="filter-field">
          <label for="grade-filter" class="label-medium">Grade Level</label>
          <select id="grade-filter" bind:value={filters.grade} class="filter-select">
            <option value="">All Grades</option>
            {#each grades as grade}
              <option value={grade}>{grade}</option>
            {/each}
          </select>
        </div>

        <div class="filter-field">
          <label for="cycle-filter" class="label-medium">Cycle</label>
          <select id="cycle-filter" bind:value={filters.cycle} class="filter-select">
            <option value="">All Cycles</option>
            {#each cycles as cycle}
              <option value={cycle}>Cycle {cycle}</option>
            {/each}
          </select>
        </div>

        <div class="filter-field">
          <label for="strand-filter" class="label-medium">Strand ID</label>
          <input
            id="strand-filter"
            type="text"
            bind:value={filters.strand}
            placeholder="Filter by strand"
            class="filter-input"
          />
        </div>
      </div>

      <div class="filter-actions">
        <button class="btn-primary" on:click={applyFilters}>
          <span class="material-symbols-outlined">search</span>
          Apply Filters
        </button>
        <button class="btn-secondary" on:click={clearFilters}>
          <span class="material-symbols-outlined">clear</span>
          Clear All
        </button>
      </div>
    </div>

    <!-- Results Summary -->
    <div class="results-summary">
      <p class="body-medium">
        Found <strong>{ilos.length}</strong> {ilos.length === 1 ? 'ILO' : 'ILOs'}
      </p>
    </div>

    <!-- Error State -->
    {#if error}
      <div class="error-container">
        <span class="material-symbols-outlined">error</span>
        <p>{error}</p>
      </div>
    {/if}

    <!-- Loading State -->
    {#if isLoading}
      <div class="loading-container">
        <LoadingSkeleton count={6} />
      </div>
    {/if}

    <!-- ILOs List -->
    {#if !isLoading && ilos.length === 0 && !error}
      <div class="empty-state">
        <span class="material-symbols-outlined">search_off</span>
        <h2 class="headline-medium">No ILOs Found</h2>
        <p class="body-medium">Try adjusting your filters to find more results</p>
      </div>
    {/if}

    {#if !isLoading && ilos.length > 0}
      <div class="ilos-list">
        {#each ilos as ilo (ilo.id)}
          <div class="ilo-card">
            <div
              class="ilo-header"
              on:click={() => toggleExpanded(ilo.id)}
              role="button"
              tabindex="0"
              on:keydown={(e) => e.key === 'Enter' && toggleExpanded(ilo.id)}
            >
              <div class="ilo-title-section">
                <h3 class="title-medium">{ilo.ilo_code}</h3>
                <span class="material-symbols-outlined expand-icon">
                  {expandedIloId === ilo.id ? 'expand_less' : 'expand_more'}
                </span>
              </div>
              <p class="body-medium ilo-description">{ilo.description}</p>
            </div>

            {#if expandedIloId === ilo.id}
              <div class="ilo-details">
                <div class="details-grid">
                  <div class="detail-item">
                    <span class="label-small">Subject</span>
                    <p class="body-small">{ilo.subject || 'N/A'}</p>
                  </div>
                  <div class="detail-item">
                    <span class="label-small">Grade Level</span>
                    <p class="body-small">{ilo.grade_level || 'N/A'}</p>
                  </div>
                  <div class="detail-item">
                    <span class="label-small">Cycle</span>
                    <p class="body-small">{ilo.cycle || 'N/A'}</p>
                  </div>
                  <div class="detail-item">
                    <span class="label-small">Strand</span>
                    <p class="body-small">{ilo.strand || 'N/A'}</p>
                  </div>
                  <div class="detail-item">
                    <span class="label-small">Subject ID</span>
                    <p class="body-small">{ilo.subject_id || 'N/A'}</p>
                  </div>
                  <div class="detail-item">
                    <span class="label-small">Grade Level ID</span>
                    <p class="body-small">{ilo.grade_level_id || 'N/A'}</p>
                  </div>
                  <div class="detail-item">
                    <span class="label-small">Strand ID</span>
                    <p class="body-small">{ilo.strand_id || 'N/A'}</p>
                  </div>
                </div>

                <div class="ilo-meta">
                  <div class="meta-row">
                    <span class="label-small">ILO Code</span>
                    <code class="body-small">{ilo.ilo_code}</code>
                  </div>
                  <div class="meta-row">
                    <span class="label-small">Record ID</span>
                    <code class="body-small">{ilo.id}</code>
                  </div>
                </div>

                <div class="dates-info">
                  <p class="body-small"><strong>Created:</strong> {new Date(ilo.created_at).toLocaleDateString()}</p>
                  <p class="body-small"><strong>Updated:</strong> {new Date(ilo.updated_at).toLocaleDateString()}</p>
                </div>
              </div>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </main>
</div>

<style>
  .app {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background-color: var(--md-sys-color-surface);
  }

  .ilo-browser {
    flex: 1;
    padding: var(--md-sys-spacing-lg);
    overflow-y: auto;
  }

  .page-header {
    margin-bottom: var(--md-sys-spacing-xl);
  }

  .page-header h1 {
    margin: 0 0 var(--md-sys-spacing-sm) 0;
    color: var(--md-sys-color-on-surface);
  }

  .page-header .body-medium {
    margin: 0;
    color: var(--md-sys-color-on-surface-variant);
  }

  /* Filters Panel */
  .filters-panel {
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-lg);
    padding: var(--md-sys-spacing-lg);
    margin-bottom: var(--md-sys-spacing-lg);
    box-shadow: var(--md-sys-elevation-1);
  }

  .filters-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: var(--md-sys-spacing-md);
    margin-bottom: var(--md-sys-spacing-md);
  }

  .filter-field {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-xs);
  }

  .filter-field label {
    color: var(--md-sys-color-on-surface);
    font-weight: 500;
  }

  .filter-select,
  .filter-input {
    padding: var(--md-sys-spacing-sm) var(--md-sys-spacing-md);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    background-color: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-family: inherit;
    font-size: inherit;
  }

  .filter-select:focus,
  .filter-input:focus {
    outline: none;
    border-color: var(--md-sys-color-primary);
    box-shadow: 0 0 0 3px var(--md-sys-color-primary-container);
  }

  .filter-actions {
    display: flex;
    gap: var(--md-sys-spacing-md);
    flex-wrap: wrap;
  }

  .btn-primary,
  .btn-secondary {
    display: inline-flex;
    align-items: center;
    gap: var(--md-sys-spacing-sm);
    padding: var(--md-sys-spacing-sm) var(--md-sys-spacing-lg);
    border: none;
    border-radius: var(--md-sys-shape-corner-sm);
    font-size: inherit;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-primary {
    background-color: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
  }

  .btn-primary:hover {
    background-color: var(--md-sys-color-primary);
    opacity: 0.9;
    box-shadow: var(--md-sys-elevation-3);
  }

  .btn-secondary {
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-on-secondary-container);
  }

  .btn-secondary:hover {
    opacity: 0.9;
  }

  .btn-primary .material-symbols-outlined,
  .btn-secondary .material-symbols-outlined {
    font-size: 20px;
  }

  /* Results Summary */
  .results-summary {
    margin-bottom: var(--md-sys-spacing-lg);
    color: var(--md-sys-color-on-surface-variant);
  }

  /* Error State */
  .error-container {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-lg);
    background-color: var(--md-sys-color-error-container);
    color: var(--md-sys-color-on-error-container);
    border-radius: var(--md-sys-shape-corner-lg);
    margin-bottom: var(--md-sys-spacing-lg);
  }

  .error-container .material-symbols-outlined {
    font-size: 24px;
    flex-shrink: 0;
  }

  /* Empty State */
  .empty-state {
    text-align: center;
    padding: var(--md-sys-spacing-xl);
    color: var(--md-sys-color-on-surface-variant);
  }

  .empty-state .material-symbols-outlined {
    font-size: 48px;
    margin-bottom: var(--md-sys-spacing-md);
    opacity: 0.5;
  }

  .empty-state h2 {
    margin: 0 0 var(--md-sys-spacing-sm) 0;
  }

  /* ILOs List */
  .ilos-list {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-md);
  }

  .ilo-card {
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-lg);
    box-shadow: var(--md-sys-elevation-1);
    overflow: hidden;
    transition: all 0.2s ease;
  }

  .ilo-card:hover {
    box-shadow: var(--md-sys-elevation-2);
  }

  .ilo-header {
    padding: var(--md-sys-spacing-lg);
    cursor: pointer;
    transition: background-color 0.2s ease;
  }

  .ilo-header:hover {
    background-color: var(--md-sys-color-surface-container-highest);
  }

  .ilo-title-section {
    display: flex;
    align-items: baseline;
    gap: var(--md-sys-spacing-md);
    margin-bottom: var(--md-sys-spacing-sm);
  }

  .ilo-title-section h3 {
    margin: 0;
    color: var(--md-sys-color-primary);
  }

  .expand-icon {
    margin-left: auto;
    color: var(--md-sys-color-on-surface-variant);
  }

  .ilo-description {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    line-height: 1.5;
  }

  /* Expanded Details */
  .ilo-details {
    padding: 0 var(--md-sys-spacing-lg) var(--md-sys-spacing-lg);
    border-top: 1px solid var(--md-sys-color-outline-variant);
  }

  .details-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: var(--md-sys-spacing-md);
    margin-bottom: var(--md-sys-spacing-lg);
  }

  .detail-item {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-xs);
  }

  .detail-item .label-small {
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
  }

  .detail-item .body-small {
    margin: 0;
    color: var(--md-sys-color-on-surface);
  }

  .full-description {
    background-color: var(--md-sys-color-surface);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
    margin-bottom: var(--md-sys-spacing-md);
  }

  .full-description .label-small {
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
    display: block;
    margin-bottom: var(--md-sys-spacing-xs);
  }

  .full-description .body-small {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    line-height: 1.6;
  }

  .ilo-id {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-xs);
  }

  .ilo-id .label-small {
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
  }

  .ilo-id code {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    background-color: var(--md-sys-color-surface);
    padding: var(--md-sys-spacing-xs) var(--md-sys-spacing-sm);
    border-radius: var(--md-sys-shape-corner-xs);
    font-family: 'Monaco', 'Courier New', monospace;
    word-break: break-all;
  }

  .ilo-meta {
    background-color: var(--md-sys-color-surface);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
    margin-bottom: var(--md-sys-spacing-md);
  }

  .meta-row {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    margin-bottom: var(--md-sys-spacing-sm);
  }

  .meta-row:last-child {
    margin-bottom: 0;
  }

  .meta-row .label-small {
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
    min-width: 100px;
  }

  .meta-row code {
    color: var(--md-sys-color-primary);
    background-color: var(--md-sys-color-primary-container);
    padding: var(--md-sys-spacing-xs) var(--md-sys-spacing-sm);
    border-radius: var(--md-sys-shape-corner-xs);
    font-family: 'Monaco', 'Courier New', monospace;
    word-break: break-all;
  }

  .dates-info {
    background-color: var(--md-sys-color-secondary-container);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
  }

  .dates-info .body-small {
    margin: var(--md-sys-spacing-xs) 0;
    color: var(--md-sys-color-on-secondary-container);
  }

  .dates-info .body-small:last-child {
    margin-bottom: 0;
  }

  /* Loading State */
  .loading-container {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-md);
  }

  /* Responsive */
  @media (max-width: 600px) {
    .ilo-browser {
      padding: var(--md-sys-spacing-md);
    }

    .filters-grid {
      grid-template-columns: 1fr;
    }

    .filters-panel {
      padding: var(--md-sys-spacing-md);
    }

    .ilo-header {
      padding: var(--md-sys-spacing-md);
    }

    .ilo-details {
      padding: 0 var(--md-sys-spacing-md) var(--md-sys-spacing-md);
    }

    .details-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }
</style>
