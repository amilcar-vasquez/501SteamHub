<script>
  import { onMount } from 'svelte';
  import { resourceAPI } from '../api/client.js';
  import { currentUser } from '../stores/auth.js';
  import TopAppBar from '../components/TopAppBar.svelte';
  import LoadingSkeleton from '../components/LoadingSkeleton.svelte';
  import LessonViewer from '../components/LessonViewer.svelte';
  
  export let slug = '';
  
  let resource = null;
  let lessons = [];
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
      console.log('Resource loaded:', resource);
      console.log('Lessons loaded:', lessons);
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
          <div class="category-chip">{resource.category}</div>
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
        </div>
        
        <!-- Lesson content -->
        {#if lessons && lessons.length > 0}
          <div class="lessons-container">
            {#each lessons as lesson}
              {@const lessonContent = parseLessonContent(lesson)}
              <div class="lesson-section">
                <div class="lesson-header">
                  <h2 class="lesson-title">
                    <span class="lesson-number">Lesson {lesson.lesson_number}</span>
                    {lesson.title}
                  </h2>
                  {#if lesson.duration_minutes}
                    <div class="lesson-duration">
                      <span class="material-symbols-outlined">schedule</span>
                      {lesson.duration_minutes} minutes
                    </div>
                  {/if}
                </div>
                
                {#if lessonContent}
                  <LessonViewer 
                    lessonContent={lessonContent} 
                    userRole={$currentUser?.role}
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
