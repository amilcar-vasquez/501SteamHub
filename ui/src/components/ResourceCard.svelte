<script>
  export let id;
  export let category;
  export let title;
  export let description;
  export let subject;
  export let subjects = []; // Optional array of all subjects
  export let grade;
  export let grades = []; // Optional array of all grades
  export let iloCount;
  export let contributor;
  export let viewCount;
  export let contributionScore;
  export let status = null;
  export let showStatus = false;
  export let slug = null; // Add slug prop
  
  let isHovered = false;
  
  // Display text for subjects/grades
  $: subjectDisplay = subjects.length > 1 ? `${subject} +${subjects.length - 1}` : subject;
  $: gradeDisplay = grades.length > 1 ? `${grade} +${grades.length - 1}` : grade;
  
  import { navigateTo } from '../router.js';
  
  function handleClick(event) {
    // Prevent default and stop propagation to ensure the click is handled
    event?.preventDefault();
    event?.stopPropagation();
    
    console.log('Resource clicked:', { id, slug, title });
    
    // Navigate to resource detail page using slug if available, otherwise use ID
    if (slug) {
      console.log('Navigating to:', `/resources/${slug}`);
      navigateTo(`/resources/${slug}`);
    } else {
      console.warn('No slug available for resource', id, '- This resource was likely created before slug generation was implemented');
      alert(`This resource doesn't have a URL yet. Please contact an administrator.`);
    }
  }
  
  function getCategoryColor(cat) {
    switch(cat) {
      case 'Lesson Plan': return 'category-lesson';
      case 'Video': return 'category-video';
      case 'Assessment': return 'category-assessment';
      default: return 'category-default';
    }
  }
  
  function getStatusColor(stat) {
    switch(stat) {
      case 'Published': return 'status-published';
      case 'Approved': return 'status-approved';
      case 'Under Review': return 'status-review';
      case 'Submitted': return 'status-submitted';
      default: return 'status-default';
    }
  }
  
  function formatNumber(num) {
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + 'k';
    }
    return num.toString();
  }
</script>

<div 
  class="resource-card" 
  class:hovered={isHovered}
  on:click={handleClick}
  on:mouseenter={() => isHovered = true}
  on:mouseleave={() => isHovered = false}
  on:keydown={(e) => e.key === 'Enter' && handleClick(e)}
  role="button"
  tabindex="0"
  aria-label="View resource: {title}"
>
  {#if showStatus && status}
    <div class="status-badge label-medium {getStatusColor(status)}">
      {status}
    </div>
  {/if}
  
  <article class="card-content">
    <!-- Category chip -->
    <div class="category-chip label-medium {getCategoryColor(category)}">
      {category}
    </div>
    
    <!-- Title -->
    <h3 class="card-title title-medium">{title}</h3>
    
    <!-- Description -->
    <p class="card-description body-medium">{description}</p>
    
    <!-- Metadata chips -->
    <div class="metadata-chips">
      <div class="assist-chip label-medium">
        <span class="material-symbols-outlined">book</span>
        {subjectDisplay}
      </div>
      <div class="assist-chip label-medium">
        <span class="material-symbols-outlined">school</span>
        {gradeDisplay}
      </div>
    </div>
    
    <!-- Footer -->
    <div class="card-footer">
      <span class="contributor body-medium">{contributor}</span>
      <div class="stats">
        <div class="stat-item label-medium">
          <span class="material-symbols-outlined">visibility</span>
          {formatNumber(viewCount)}
        </div>
        <div class="stat-item label-medium">
          <span class="material-symbols-outlined">star</span>
          {contributionScore}
        </div>
      </div>
    </div>
  </article>
</div>

<style>
  .resource-card {
    background-color: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-md);
    padding: var(--md-sys-spacing-md);
    cursor: pointer;
    transition: box-shadow 0.3s cubic-bezier(0.4, 0, 0.2, 1), 
                transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    overflow: hidden;
  }
  
  .resource-card:hover,
  .resource-card:focus {
    outline: none;
    box-shadow: var(--md-sys-elevation-2);
    transform: translateY(-2px);
  }
  
  .resource-card:active {
    transform: translateY(0);
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .status-badge {
    position: absolute;
    top: var(--md-sys-spacing-sm);
    right: var(--md-sys-spacing-sm);
    padding: 4px 8px;
    border-radius: var(--md-sys-shape-corner-sm);
    font-weight: 500;
  }
  
  .status-published {
    background-color: var(--md-sys-color-success-container);
    color: var(--md-sys-color-success);
  }
  
  .status-approved {
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-secondary);
  }
  
  .status-review {
    background-color: var(--md-sys-color-warning-container);
    color: var(--md-sys-color-warning);
  }
  
  .status-submitted {
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .card-content {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-md);
  }
  
  .category-chip {
    display: inline-flex;
    align-items: center;
    padding: 4px 12px;
    border-radius: var(--md-sys-shape-corner-full);
    width: fit-content;
  }
  
  .category-lesson {
    background-color: #e8f5e9;
    color: #2e7d32;
  }
  
  .category-video {
    background-color: #e3f2fd;
    color: #1565c0;
  }
  
  .category-assessment {
    background-color: #fff3e0;
    color: #e65100;
  }
  
  .category-default {
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .card-title {
    color: var(--md-sys-color-on-surface);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    min-height: 48px;
  }
  
  .card-description {
    color: var(--md-sys-color-on-surface-variant);
    display: -webkit-box;
    -webkit-line-clamp: 3;
    line-clamp: 3;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    min-height: 60px;
  }
  
  .metadata-chips {
    display: flex;
    flex-wrap: wrap;
    gap: var(--md-sys-spacing-sm);
  }
  
  .assist-chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    background-color: var(--md-sys-color-surface-variant);
    color: var(--md-sys-color-on-surface-variant);
    border-radius: var(--md-sys-shape-corner-sm);
  }
  
  .assist-chip .material-symbols-outlined {
    font-size: 18px;
  }
  
  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: var(--md-sys-spacing-sm);
    border-top: 1px solid var(--md-sys-color-outline-variant);
  }
  
  .contributor {
    color: var(--md-sys-color-on-surface-variant);
    font-size: 12px;
  }
  
  .stats {
    display: flex;
    gap: var(--md-sys-spacing-md);
  }
  
  .stat-item {
    display: flex;
    align-items: center;
    gap: 4px;
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .stat-item .material-symbols-outlined {
    font-size: 18px;
  }
</style>
