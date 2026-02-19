<script>
  import { onMount } from 'svelte';
  import TopAppBar from '../components/TopAppBar.svelte';
  import NavigationDrawer from '../components/NavigationDrawer.svelte';
  import ResourceCard from '../components/ResourceCard.svelte';
  import Chip from '../components/Chip.svelte';
  import LoadingSkeleton from '../components/LoadingSkeleton.svelte';
  import Button from '../components/Button.svelte';
  import { createEventDispatcher } from 'svelte';
  import { currentUser } from '../stores/auth.js';
  import { navigateTo } from '../router.js';
  import { resourceAPI } from '../api/client.js';
  
  const dispatch = createEventDispatcher();
  
  let searchQuery = '';
  let isMobileFilterOpen = false;
  let isLoading = true;
  let loadError = '';
  let showRoleBasedStatus = false; // Toggle for reviewer/admin view — shows all statuses
  
  // Roles allowed to see non-Approved resources
  const REVIEWER_ROLES = ['SubjectExpert', 'TeamLead', 'DSC', 'admin'];
  $: canReview = $currentUser && REVIEWER_ROLES.includes($currentUser.role_name);
  
  // Filter state
  let filters = {
    subjects: [],
    gradeLevels: [],
    resourceTypes: [],
    contributor: '',
    school: '',
    sortBy: 'relevance'
  };
  
  // Active filters for chips display
  $: activeFilters = [
    ...filters.subjects.map(s => ({ type: 'subject', value: s, label: s })),
    ...filters.gradeLevels.map(g => ({ type: 'gradeLevel', value: g, label: g })),
    ...filters.resourceTypes.map(r => ({ type: 'resourceType', value: r, label: r })),
    ...(filters.contributor ? [{ type: 'contributor', value: filters.contributor, label: filters.contributor }] : []),
    ...(filters.school ? [{ type: 'school', value: filters.school, label: filters.school }] : [])
  ];
  
  // Resources from API
  let resources = [];
  let metadata = {};
  
  $: resultCount = resources.length;
  
  // Load resources on mount and when filters change
  onMount(() => {
    loadResources();
  });
  
  // Reload when filters or review-mode toggle changes
  $: if (filters.subjects || filters.gradeLevels || searchQuery || showRoleBasedStatus !== undefined) {
    loadResources();
  }
  
  async function loadResources() {
    isLoading = true;
    loadError = '';
    
    try {
      const params = {};
      
      // Public users and fellows only see Approved resources.
      // Reviewer roles can toggle to see all statuses for review purposes.
      if (!canReview || !showRoleBasedStatus) {
        params.status = 'Approved';
      }
      
      // Note: Current API supports single filter values, not arrays
      // For now, we'll use the first value if multiple are selected
      if (filters.subjects.length > 0) {
        params.subject = filters.subjects[0];
      }
      if (filters.gradeLevels.length > 0) {
        params.grade_level = filters.gradeLevels[0];
      }
      if (searchQuery) {
        params.search = searchQuery;
      }
      
      console.log('Loading resources with params:', params);
      const response = await resourceAPI.getAll(params);
      console.log('Resources loaded:', response);
      
      // Map API response to match ResourceCard props
      const apiResources = response.resources || [];
      resources = apiResources.map(resource => ({
        id: resource.resource_id,
        category: resource.category,
        title: resource.title,
        description: resource.summary || 'No description available',
        subject: resource.subjects && resource.subjects.length > 0 ? resource.subjects[0] : 'General',
        subjects: resource.subjects || [],
        grade: resource.grade_levels && resource.grade_levels.length > 0 ? resource.grade_levels[0] : 'Mixed',
        grades: resource.grade_levels || [],
        iloCount: 0, // No longer tracking ILO in new schema
        contributor: `Contributor #${resource.contributor_id}`, // TODO: fetch user name
        viewCount: 0, // TODO: implement view tracking
        contributionScore: 0, // TODO: implement scoring system
        status: resource.status,
        slug: resource.slug, // Include slug for navigation
      }));
      
      metadata = response.metadata || {};
      
    } catch (error) {
      console.error('Failed to load resources:', error);
      loadError = 'Failed to load resources. Please try again.';
      resources = [];
    } finally {
      isLoading = false;
    }
  }
  
  function removeFilter(filter) {
    if (filter.type === 'subject') {
      filters.subjects = filters.subjects.filter(s => s !== filter.value);
    } else if (filter.type === 'gradeLevel') {
      filters.gradeLevels = filters.gradeLevels.filter(g => g !== filter.value);
    } else if (filter.type === 'resourceType') {
      filters.resourceTypes = filters.resourceTypes.filter(r => r !== filter.value);
    } else if (filter.type === 'contributor') {
      filters.contributor = '';
    } else if (filter.type === 'school') {
      filters.school = '';
    }
  }
  
  function clearAllFilters() {
    filters = {
      subjects: [],
      gradeLevels: [],
      resourceTypes: [],
      contributor: '',
      school: '',
      sortBy: 'relevance'
    };
  }
  
  function toggleMobileFilter() {
    isMobileFilterOpen = !isMobileFilterOpen;
  }
  
  function handleSignUp() {
    dispatch('navigate', { page: 'signup' });
  }
</script>

<div class="app">
  <TopAppBar bind:searchQuery on:toggleFilter={toggleMobileFilter} />
  
  <div class="app-content">
    <NavigationDrawer 
      bind:filters 
      bind:isMobileOpen={isMobileFilterOpen}
      on:close={() => isMobileFilterOpen = false}
    />
    
    <main class="main-content">
      <!-- Auth CTA Banner (only show when not authenticated) -->
      {#if !$currentUser}
        <div class="auth-banner">
          <div class="banner-content">
            <span class="material-symbols-outlined">info</span>
            <p class="body-medium">
              <strong>New to 501 STEAM Hub?</strong> Sign up to access more resources and features
            </p>
          </div>
          <Button variant="filled" color="secondary" on:click={handleSignUp}>
            Sign Up
          </Button>
        </div>
      {/if}
      
      <!-- Results summary -->
      <div class="results-header">
        <p class="results-summary body-large">
          Showing {resultCount} results sorted by {filters.sortBy === 'relevance' ? 'Relevance' : filters.sortBy === 'recent' ? 'Most Recent' : 'Most Accessed'}
        </p>
        
        {#if canReview}
          <button
            class="review-mode-toggle"
            class:active={showRoleBasedStatus}
            type="button"
            on:click={() => { showRoleBasedStatus = !showRoleBasedStatus; loadResources(); }}
            title={showRoleBasedStatus ? 'Showing all statuses — click to show Approved only' : 'Show resources pending review'}
          >
            <span class="material-symbols-outlined">
              {showRoleBasedStatus ? 'visibility' : 'pending_actions'}
            </span>
            {showRoleBasedStatus ? 'All Statuses' : 'Pending Review'}
          </button>
        {/if}
        
        <!-- Active filters chips -->
        {#if activeFilters.length > 0}
          <div class="active-filters">
            {#each activeFilters as filter}
              <Chip 
                label={filter.label} 
                removable 
                on:remove={() => removeFilter(filter)}
              />
            {/each}
            <button class="clear-all-btn label-medium" on:click={clearAllFilters}>
              Clear all
            </button>
          </div>
        {/if}
      </div>
      
      <!-- Resource grid -->
      {#if loadError}
        <div class="zero-state error-state">
          <span class="material-symbols-outlined zero-state-icon">error</span>
          <h2 class="title-large">Error Loading Resources</h2>
          <p class="body-medium">{loadError}</p>
          <button class="clear-filters-btn" on:click={loadResources}>
            Try Again
          </button>
        </div>
      {:else if isLoading}
        <div class="resource-grid">
          {#each Array(6) as _}
            <LoadingSkeleton />
          {/each}
        </div>
      {:else if resultCount === 0}
        <div class="zero-state">
          <span class="material-symbols-outlined zero-state-icon">search_off</span>
          <h2 class="title-large">No results found</h2>
          <p class="body-medium">Try adjusting your filters or search query</p>
          <button class="clear-filters-btn" on:click={clearAllFilters}>
            Clear Filters
          </button>
        </div>
      {:else}
        <div class="resource-grid">
          {#each resources as resource (resource.id)}
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
              showStatus={showRoleBasedStatus}
              slug={resource.slug}
            />
          {/each}
        </div>
      {/if}
    </main>
  </div>
  
  <!-- Floating Action Button for submitting resources -->
  {#if $currentUser}
    <button class="fab" on:click={() => navigateTo('/submit')}>
      <span class="material-symbols-outlined">add</span>
    </button>
  {/if}
</div>

<style>
  .app {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
  }
  
  .app-content {
    display: flex;
    flex: 1;
    overflow: hidden;
  }
  
  .main-content {
    flex: 1;
    padding: var(--md-sys-spacing-lg);
    overflow-y: auto;
    background-color: var(--md-sys-color-surface);
  }
  
  .auth-banner {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--md-sys-spacing-md);
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-on-secondary-container);
    padding: var(--md-sys-spacing-md) var(--md-sys-spacing-lg);
    border-radius: var(--md-sys-shape-corner-md);
    margin-bottom: var(--md-sys-spacing-lg);
  }
  
  .banner-content {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    flex: 1;
  }
  
  .banner-content .material-symbols-outlined {
    font-size: 24px;
  }
  
  .results-header {
    margin-bottom: var(--md-sys-spacing-lg);
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: var(--md-sys-spacing-sm);
  }

  .review-mode-toggle {
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

  .review-mode-toggle:hover {
    background: var(--md-sys-color-surface-variant);
  }

  .review-mode-toggle.active {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border-color: var(--md-sys-color-primary);
  }

  .review-mode-toggle .material-symbols-outlined {
    font-size: 18px;
  }
  
  .results-summary {
    color: var(--md-sys-color-on-surface-variant);
    margin-bottom: var(--md-sys-spacing-md);
  }
  
  .active-filters {
    display: flex;
    flex-wrap: wrap;
    gap: var(--md-sys-spacing-sm);
    align-items: center;
  }
  
  .clear-all-btn {
    background: none;
    border: none;
    color: var(--md-sys-color-primary);
    cursor: pointer;
    padding: var(--md-sys-spacing-sm) var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
    transition: background-color 0.2s;
  }
  
  .clear-all-btn:hover {
    background-color: rgba(124, 61, 130, var(--md-sys-state-hover-opacity));
  }
  
  .resource-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: var(--md-sys-spacing-lg);
  }
  
  .zero-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: var(--md-sys-spacing-xl) var(--md-sys-spacing-lg);
    text-align: center;
    min-height: 400px;
  }
  
  .zero-state-icon {
    font-size: 64px;
    color: var(--md-sys-color-outline);
    margin-bottom: var(--md-sys-spacing-md);
  }
  
  .zero-state h2 {
    color: var(--md-sys-color-on-surface);
    margin-bottom: var(--md-sys-spacing-sm);
  }
  
  .zero-state p {
    color: var(--md-sys-color-on-surface-variant);
    margin-bottom: var(--md-sys-spacing-lg);
  }
  
  .error-state .zero-state-icon {
    color: var(--md-sys-color-error);
  }
  
  .clear-filters-btn {
    background-color: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    padding: 10px 24px;
    border-radius: var(--md-sys-shape-corner-full);
    font-family: var(--md-sys-typescale-label-large-font);
    font-size: var(--md-sys-typescale-label-large-size);
    font-weight: var(--md-sys-typescale-label-large-weight);
    cursor: pointer;
    box-shadow: var(--md-sys-elevation-1);
    transition: box-shadow 0.2s, background-color 0.2s;
  }
  
  .clear-filters-btn:hover {
    box-shadow: var(--md-sys-elevation-2);
    background-color: #8a4590;
  }
  
  .clear-filters-btn:active {
    box-shadow: var(--md-sys-elevation-1);
  }
  
  /* Floating Action Button */
  .fab {
    position: fixed;
    bottom: 24px;
    right: 24px;
    width: 64px;
    height: 64px;
    border-radius: var(--md-sys-shape-corner-lg);
    background-color: var(--md-sys-color-secondary);
    color: var(--md-sys-color-on-secondary);
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: var(--md-sys-elevation-3);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 999;
  }
  
  .fab:hover {
    box-shadow: var(--md-sys-elevation-4);
    transform: scale(1.05);
    background-color: rgba(6, 158, 201, 0.9);
  }
  
  .fab:active {
    transform: scale(0.95);
  }
  
  .fab .material-symbols-outlined {
    font-size: 32px;
    font-weight: 500;
  }
  
  /* Tablet */
  @media (max-width: 1024px) {
    .resource-grid {
      grid-template-columns: repeat(2, 1fr);
    }
    
    .main-content {
      padding: var(--md-sys-spacing-md);
    }
    
    .auth-banner {
      flex-direction: column;
      text-align: center;
    }
    
    .banner-content {
      flex-direction: column;
    }
  }
  
  /* Mobile */
  @media (max-width: 600px) {
    .resource-grid {
      grid-template-columns: 1fr;
    }
    
    .main-content {
      padding: var(--md-sys-spacing-md);
    }
    
    .fab {
      width: 56px;
      height: 56px;
      bottom: 16px;
      right: 16px;
    }
    
    .fab .material-symbols-outlined {
      font-size: 28px;
    }
  }
</style>
