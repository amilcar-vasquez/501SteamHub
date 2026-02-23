<script>
  import { createEventDispatcher } from 'svelte';

  const dispatch = createEventDispatcher();

  // Known subjects from seed migration
  const SUBJECTS = [
    'Computer Science',
    'Information Technology',
    'Science',
    'Engineering',
    'Robotics',
    'Arts',
    'Belizean History',
    'Mathematics',
    'English Language Arts',
    'Social Studies',
    'Physical Education',
  ];

  // Known grade levels from seed migration
  const GRADE_LEVELS = [
    'Preschool',
    'Infant 1',
    'Infant 2',
    'Standard 1',
    'Standard 2',
    'Standard 3',
    'Standard 4',
    'Standard 5',
    'Standard 6',
    'Mixed',
  ];

  const STATUSES = [
    { value: '', label: 'All Pending' },
    { value: 'Submitted', label: 'Submitted' },
    { value: 'UnderReview', label: 'Under Review' },
    { value: 'NeedsRevision', label: 'Needs Revision' },
    { value: 'Approved', label: 'Approved' },
  ];

  let selectedSubject = '';
  let selectedGrade = '';
  let selectedStatus = '';

  function emitChange() {
    dispatch('filterChange', {
      subject: selectedSubject,
      grade_level: selectedGrade,
      status: selectedStatus,
    });
  }

  function clearAll() {
    selectedSubject = '';
    selectedGrade = '';
    selectedStatus = '';
    emitChange();
  }

  $: hasActiveFilters = selectedSubject || selectedGrade || selectedStatus;
</script>

<div class="filters-bar" role="search" aria-label="Review queue filters">
  <!-- Subject -->
  <div class="filter-group">
    <label class="label-medium filter-label" for="filter-subject">Subject</label>
    <select
      id="filter-subject"
      class="filter-select body-medium"
      bind:value={selectedSubject}
      on:change={emitChange}
    >
      <option value="">All Subjects</option>
      {#each SUBJECTS as s}
        <option value={s}>{s}</option>
      {/each}
    </select>
  </div>

  <!-- Grade Level -->
  <div class="filter-group">
    <label class="label-medium filter-label" for="filter-grade">Grade Level</label>
    <select
      id="filter-grade"
      class="filter-select body-medium"
      bind:value={selectedGrade}
      on:change={emitChange}
    >
      <option value="">All Grades</option>
      {#each GRADE_LEVELS as g}
        <option value={g}>{g}</option>
      {/each}
    </select>
  </div>

  <!-- Status -->
  <div class="filter-group">
    <label class="label-medium filter-label" for="filter-status">Status</label>
    <select
      id="filter-status"
      class="filter-select body-medium"
      bind:value={selectedStatus}
      on:change={emitChange}
    >
      {#each STATUSES as opt}
        <option value={opt.value}>{opt.label}</option>
      {/each}
    </select>
  </div>

  <!-- Clear -->
  {#if hasActiveFilters}
    <button class="clear-btn label-medium" on:click={clearAll}>
      <span class="material-symbols-outlined">filter_list_off</span>
      Clear
    </button>
  {/if}
</div>

<style>
  .filters-bar {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 12px;
    padding: 16px;
    background: var(--md-sys-color-surface-container-low);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 16px;
    margin-bottom: 20px;
  }

  .filter-group {
    display: flex;
    flex-direction: column;
    gap: 4px;
    flex: 1;
    min-width: 160px;
  }

  .filter-label {
    color: var(--md-sys-color-on-surface-variant);
    padding-left: 4px;
  }

  .filter-select {
    height: 40px;
    padding: 0 12px;
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 8px;
    background: var(--md-sys-color-surface-container-lowest);
    color: var(--md-sys-color-on-surface);
    outline: none;
    cursor: pointer;
    transition: border-color 0.2s, box-shadow 0.2s;
  }
  .filter-select:focus {
    border-color: var(--md-sys-color-primary);
    box-shadow: 0 0 0 2px rgba(124, 61, 130, 0.2);
  }

  .clear-btn {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    height: 40px;
    padding: 0 16px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 999px;
    background: none;
    color: var(--md-sys-color-on-surface-variant);
    cursor: pointer;
    transition: background 0.2s;
    align-self: flex-end;
  }
  .clear-btn:hover {
    background: var(--md-sys-color-surface-container);
  }
  .clear-btn .material-symbols-outlined {
    font-size: 18px;
  }

  @media (max-width: 600px) {
    .filter-group { min-width: 100%; }
  }
</style>
