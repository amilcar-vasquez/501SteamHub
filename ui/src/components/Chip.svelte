<script>
  import { createEventDispatcher } from 'svelte';
  
  export let label;
  export let removable = false;
  
  const dispatch = createEventDispatcher();
</script>

<div class="chip label-medium">
  <span class="chip-label">{label}</span>
  {#if removable}
    <button class="remove-button" on:click={() => dispatch('remove')}>
      <span class="material-symbols-outlined">close</span>
    </button>
  {/if}
</div>

<style>
  .chip {
    display: inline-flex;
    align-items: center;
    gap: var(--md-sys-spacing-xs);
    padding: 6px 12px;
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-on-secondary-container);
    border-radius: var(--md-sys-shape-corner-sm);
  }
  
  .chip-label {
    line-height: 1;
  }
  
  .remove-button {
    background: none;
    border: none;
    padding: 0;
    margin: 0;
    width: 18px;
    height: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--md-sys-color-on-secondary-container);
    border-radius: var(--md-sys-shape-corner-full);
    transition: background-color 0.2s;
  }
  
  .remove-button:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  .remove-button .material-symbols-outlined {
    font-size: 16px;
  }
</style>
