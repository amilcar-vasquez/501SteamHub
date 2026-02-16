<script>
  import { createEventDispatcher } from 'svelte';
  
  export let label;
  export let selected = false;
  
  const dispatch = createEventDispatcher();
</script>

<button 
  class="filter-chip label-medium" 
  class:selected
  on:click={() => dispatch('click')}
>
  {#if selected}
    <span class="material-symbols-outlined check-icon">check</span>
  {/if}
  {label}
</button>

<style>
  .filter-chip {
    display: inline-flex;
    align-items: center;
    gap: var(--md-sys-spacing-xs);
    padding: 6px 12px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    background-color: transparent;
    color: var(--md-sys-color-on-surface-variant);
    cursor: pointer;
    transition: background-color 0.2s, border-color 0.2s, color 0.2s;
    white-space: nowrap;
  }
  
  .filter-chip:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  .filter-chip.selected {
    background-color: var(--md-sys-color-secondary-container);
    border-color: var(--md-sys-color-secondary);
    color: var(--md-sys-color-on-secondary-container);
  }
  
  .check-icon {
    font-size: 18px;
  }
</style>
