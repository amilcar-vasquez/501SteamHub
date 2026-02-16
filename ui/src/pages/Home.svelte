<script>
  import TopAppBar from '../components/TopAppBar.svelte';
  import NavigationDrawer from '../components/NavigationDrawer.svelte';
  import ResourceCard from '../components/ResourceCard.svelte';
  import Chip from '../components/Chip.svelte';
  import LoadingSkeleton from '../components/LoadingSkeleton.svelte';
  import Button from '../components/Button.svelte';
  import { createEventDispatcher } from 'svelte';
  import { currentUser } from '../stores/auth.js';
  
  const dispatch = createEventDispatcher();
  
  let searchQuery = '';
  let isMobileFilterOpen = false;
  let isLoading = false;
  let showRoleBasedStatus = false; // Toggle for admin/fellow view
  
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
    ...filters.gradeLevels.map(g => ({ type: 'gradeLevel', value: g, label: `Grade ${g}` })),
    ...filters.resourceTypes.map(r => ({ type: 'resourceType', value: r, label: r })),
    ...(filters.contributor ? [{ type: 'contributor', value: filters.contributor, label: filters.contributor }] : []),
    ...(filters.school ? [{ type: 'school', value: filters.school, label: filters.school }] : [])
  ];
  
  // Mock resources data
  let resources = [
    {
      id: 1,
      category: 'Lesson Plan',
      title: 'Introduction to Renewable Energy Systems',
      description: 'A comprehensive lesson plan exploring solar, wind, and hydroelectric power generation with hands-on activities.',
      subject: 'Science',
      grade: '9-10',
      iloCount: 5,
      contributor: 'Dr. Sarah Mitchell',
      viewCount: 1234,
      contributionScore: 87,
      status: 'Published'
    },
    {
      id: 2,
      category: 'Video',
      title: 'The Water Cycle Explained',
      description: 'An animated video demonstrating evaporation, condensation, and precipitation in Earth\'s water cycle.',
      subject: 'Science',
      grade: '6-8',
      iloCount: 3,
      contributor: 'Prof. James Chen',
      viewCount: 2891,
      contributionScore: 92,
      status: 'Published'
    },
    {
      id: 3,
      category: 'Assessment',
      title: 'Algebra I: Linear Equations Quiz',
      description: 'A formative assessment covering solving one and two-step linear equations with variables on both sides.',
      subject: 'Mathematics',
      grade: '8-9',
      iloCount: 8,
      contributor: 'Maria Rodriguez',
      viewCount: 567,
      contributionScore: 78,
      status: 'Under Review'
    },
    {
      id: 4,
      category: 'Lesson Plan',
      title: 'Digital Citizenship and Online Safety',
      description: 'Interactive lesson teaching students about responsible internet use, privacy, and identifying misinformation.',
      subject: 'Technology',
      grade: '7-9',
      iloCount: 6,
      contributor: 'Alex Thompson',
      viewCount: 1876,
      contributionScore: 85,
      status: 'Published'
    },
    {
      id: 5,
      category: 'Video',
      title: 'Photosynthesis in Plants',
      description: 'Visual explanation of how plants convert sunlight into energy through the process of photosynthesis.',
      subject: 'Biology',
      grade: '9-11',
      iloCount: 4,
      contributor: 'Dr. Emily Zhang',
      viewCount: 3421,
      contributionScore: 95,
      status: 'Published'
    },
    {
      id: 6,
      category: 'Assessment',
      title: 'Colonial America: Historical Analysis',
      description: 'Document-based assessment examining primary sources from the colonial period of American history.',
      subject: 'History',
      grade: '10-11',
      iloCount: 7,
      contributor: 'Robert Williams',
      viewCount: 892,
      contributionScore: 81,
      status: 'Approved'
    },
    {
      id: 7,
      category: 'Lesson Plan',
      title: 'Introduction to Python Programming',
      description: 'Beginner-friendly introduction to Python covering variables, data types, and basic control structures.',
      subject: 'Computer Science',
      grade: '9-12',
      iloCount: 9,
      contributor: 'Lisa Patel',
      viewCount: 2156,
      contributionScore: 88,
      status: 'Published'
    },
    {
      id: 8,
      category: 'Video',
      title: 'Shakespeare\'s Romeo and Juliet Analysis',
      description: 'Comprehensive analysis of themes, characters, and literary devices in Romeo and Juliet.',
      subject: 'English',
      grade: '9-10',
      iloCount: 5,
      contributor: 'Catherine Moore',
      viewCount: 1543,
      contributionScore: 83,
      status: 'Submitted'
    }
  ];
  
  $: resultCount = resources.length;
  
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
      {#if isLoading}
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
              {...resource} 
              showStatus={showRoleBasedStatus}
            />
          {/each}
        </div>
      {/if}
    </main>
  </div>
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
  }
</style>
