<script>
  import { createEventDispatcher } from 'svelte';
  import FilterChip from './FilterChip.svelte';
  
  export let filters;
  export let isMobileOpen = false;
  
  const dispatch = createEventDispatcher();
  
  let isMobile = false;
  
  function checkMobile() {
    isMobile = window.innerWidth < 1024;
  }
  
  if (typeof window !== 'undefined') {
    checkMobile();
    window.addEventListener('resize', checkMobile);
  }
  
  const subjects = [
    'Science', 'Mathematics', 'Technology', 'Engineering', 
    'Arts', 'English', 'History', 'Biology', 'Chemistry', 'Physics'
  ];
  
  const gradeLevels = [
    'Preschool',
    'Infant 1',
    'Infant 2',
    'Standard 1',
    'Standard 2',
    'Standard 3',
    'Standard 4',
    'Standard 5',
    'Standard 6',
    'Mixed'
  ];
  
  const resourceTypes = [
    'Lesson Plan', 'Video', 'Assessment', 'Activity', 'Presentation', 'Worksheet'
  ];
  
  const contributors = [
    'Dr. Sarah Mitchell', 'Prof. James Chen', 'Maria Rodriguez', 
    'Alex Thompson', 'Dr. Emily Zhang', 'Robert Williams'
  ];
  
  const schools = [
    'Lincoln High School', 'Washington Middle School', 'Jefferson Elementary',
    'Roosevelt Academy', 'Madison STEM School'
  ];
  
  function toggleSubject(subject) {
    if (filters.subjects.includes(subject)) {
      filters.subjects = filters.subjects.filter(s => s !== subject);
    } else {
      filters.subjects = [...filters.subjects, subject];
    }
  }
  
  function toggleGradeLevel(grade) {
    if (filters.gradeLevels.includes(grade)) {
      filters.gradeLevels = filters.gradeLevels.filter(g => g !== grade);
    } else {
      filters.gradeLevels = [...filters.gradeLevels, grade];
    }
  }
  
  function toggleResourceType(type) {
    if (filters.resourceTypes.includes(type)) {
      filters.resourceTypes = filters.resourceTypes.filter(r => r !== type);
    } else {
      filters.resourceTypes = [...filters.resourceTypes, type];
    }
  }
  
  function handleBackdropClick() {
    if (isMobile) {
      dispatch('close');
    }
  }
</script>

{#if isMobile && isMobileOpen}
  <div 
    class="backdrop" 
    on:click={handleBackdropClick}
    on:keydown={(e) => e.key === 'Escape' && handleBackdropClick()}
    role="button"
    tabindex="0"
    aria-label="Close filters"
  ></div>
{/if}

<aside class="navigation-drawer" class:mobile-open={isMobile && isMobileOpen} class:mobile={isMobile}>
  {#if isMobile}
    <div class="drawer-header">
      <h2 class="title-medium">Filters</h2>
      <button class="icon-button" on:click={() => dispatch('close')}>
        <span class="material-symbols-outlined">close</span>
      </button>
    </div>
  {/if}
  
  <div class="drawer-content">
    <!-- Subject Filter -->
    <div class="filter-section">
      <h3 class="filter-title title-medium">Subject</h3>
      <div class="checkbox-list">
        {#each subjects as subject}
          <label class="checkbox-item">
            <input 
              type="checkbox" 
              checked={filters.subjects.includes(subject)}
              on:change={() => toggleSubject(subject)}
            />
            <span class="checkbox-label body-medium">{subject}</span>
          </label>
        {/each}
      </div>
    </div>
    
    <!-- Grade Level Filter -->
    <div class="filter-section">
      <h3 class="filter-title title-medium">Grade Level</h3>
      <div class="checkbox-list">
        {#each gradeLevels as grade}
          <label class="checkbox-item">
            <input 
              type="checkbox" 
              checked={filters.gradeLevels.includes(grade)}
              on:change={() => toggleGradeLevel(grade)}
            />
            <span class="checkbox-label body-medium">{grade}</span>
          </label>
        {/each}
      </div>
    </div>
    
    <!-- Resource Type Filter -->
    <div class="filter-section">
      <h3 class="filter-title title-medium">Resource Type</h3>
      <div class="chip-list">
        {#each resourceTypes as type}
          <FilterChip 
            label={type} 
            selected={filters.resourceTypes.includes(type)}
            on:click={() => toggleResourceType(type)}
          />
        {/each}
      </div>
    </div>
    
    <!-- Contributor Filter -->
    <div class="filter-section">
      <h3 class="filter-title title-medium">Contributor</h3>
      <select class="dropdown body-medium" bind:value={filters.contributor}>
        <option value="">All Contributors</option>
        {#each contributors as contributor}
          <option value={contributor}>{contributor}</option>
        {/each}
      </select>
    </div>
    
    <!-- School Filter -->
    <div class="filter-section">
      <h3 class="filter-title title-medium">School</h3>
      <select class="dropdown body-medium" bind:value={filters.school}>
        <option value="">All Schools</option>
        {#each schools as school}
          <option value={school}>{school}</option>
        {/each}
      </select>
    </div>
    
    <!-- Sort By -->
    <div class="filter-section">
      <h3 class="filter-title title-medium">Sort By</h3>
      <div class="radio-list">
        <label class="radio-item">
          <input 
            type="radio" 
            name="sortBy" 
            value="relevance"
            bind:group={filters.sortBy}
          />
          <span class="radio-label body-medium">Relevance</span>
        </label>
        <label class="radio-item">
          <input 
            type="radio" 
            name="sortBy" 
            value="recent"
            bind:group={filters.sortBy}
          />
          <span class="radio-label body-medium">Most Recent</span>
        </label>
        <label class="radio-item">
          <input 
            type="radio" 
            name="sortBy" 
            value="accessed"
            bind:group={filters.sortBy}
          />
          <span class="radio-label body-medium">Most Accessed</span>
        </label>
      </div>
    </div>
  </div>
</aside>

<style>
  .navigation-drawer {
    width: 280px;
    background-color: var(--md-sys-color-surface-container-low);
    border-right: 1px solid var(--md-sys-color-outline-variant);
    overflow-y: auto;
    flex-shrink: 0;
  }
  
  .drawer-content {
    padding: var(--md-sys-spacing-md);
  }
  
  .filter-section {
    margin-bottom: var(--md-sys-spacing-lg);
    padding-bottom: var(--md-sys-spacing-lg);
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
  }
  
  .filter-section:last-child {
    border-bottom: none;
  }
  
  .filter-title {
    color: var(--md-sys-color-on-surface);
    margin-bottom: var(--md-sys-spacing-md);
  }
  
  .checkbox-list {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-sm);
  }
  
  .checkbox-item {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    cursor: pointer;
    padding: var(--md-sys-spacing-xs);
    border-radius: var(--md-sys-shape-corner-sm);
    transition: background-color 0.2s;
  }
  
  .checkbox-item:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  .checkbox-item input[type="checkbox"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: var(--md-sys-color-primary);
  }
  
  .checkbox-label {
    color: var(--md-sys-color-on-surface);
  }
  
  .chip-list {
    display: flex;
    flex-wrap: wrap;
    gap: var(--md-sys-spacing-sm);
  }
  
  .dropdown {
    width: 100%;
    padding: 12px var(--md-sys-spacing-md);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    background-color: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    cursor: pointer;
    transition: border-color 0.2s;
  }
  
  .dropdown:hover {
    border-color: var(--md-sys-color-on-surface);
  }
  
  .dropdown:focus {
    outline: none;
    border-color: var(--md-sys-color-primary);
    border-width: 2px;
    padding: 11px 15px;
  }
  
  .radio-list {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-sm);
  }
  
  .radio-item {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    cursor: pointer;
    padding: var(--md-sys-spacing-xs);
    border-radius: var(--md-sys-shape-corner-sm);
    transition: background-color 0.2s;
  }
  
  .radio-item:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  .radio-item input[type="radio"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
    accent-color: var(--md-sys-color-primary);
  }
  
  .radio-label {
    color: var(--md-sys-color-on-surface);
  }
  
  .backdrop {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.4);
    z-index: 199;
  }
  
  /* Mobile styles */
  .navigation-drawer.mobile {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    z-index: 200;
    transform: translateX(-100%);
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: var(--md-sys-elevation-3);
  }
  
  .navigation-drawer.mobile.mobile-open {
    transform: translateX(0);
  }
  
  .drawer-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--md-sys-spacing-md);
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
  }
  
  .icon-button {
    background: none;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: var(--md-sys-shape-corner-full);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--md-sys-color-on-surface-variant);
    transition: background-color 0.2s;
  }
  
  .icon-button:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  @media (max-width: 1024px) {
    .navigation-drawer:not(.mobile) {
      display: none;
    }
  }
</style>
