<script>
  import { createEventDispatcher } from 'svelte';

  export let blockTypes = [];
  
  const dispatch = createEventDispatcher();
  let isOpen = false;
  let containerRef;

  function toggleDropdown(event) {
    event.stopPropagation();
    isOpen = !isOpen;
  }

  function selectBlockType(blockType, event) {
    event.stopPropagation();
    dispatch('add', { blockType });
    isOpen = false;
  }

  function handleClickOutside(event) {
    if (containerRef && !containerRef.contains(event.target)) {
      isOpen = false;
    }
  }
</script>

<svelte:window on:click={handleClickOutside} />

<div class="add-block-button" bind:this={containerRef}>
  <button
    type="button"
    class="add-btn"
    on:click={toggleDropdown}
    on:mousedown|stopPropagation
    title="Insert block here"
    aria-label="Insert block"
    aria-expanded={isOpen}
  >
    <span class="material-symbols-outlined">add</span>
  </button>

  {#if isOpen}
    <div class="dropdown" role="menu" tabindex="-1" on:mousedown|stopPropagation>
      {#each blockTypes as blockType}
        <button
          type="button"
          class="dropdown-item"
          role="menuitem"
          on:click={(e) => selectBlockType(blockType.value, e)}
        >
          {blockType.label}
        </button>
      {/each}
    </div>
  {/if}
</div>

<style>
  .add-block-button {
    position: relative;
    display: flex;
    justify-content: center;
    padding: 0.5rem 0;
    opacity: 0;
    transition: opacity 0.2s;
    z-index: 1;
  }

  .add-block-button:has(.dropdown) {
    z-index: 9999;
  }

  .add-block-button:hover {
    opacity: 1;
  }

  /* Show on hover of parent */
  :global(.blocks-list):hover .add-block-button {
    opacity: 0.5;
  }

  .add-block-button:hover {
    opacity: 1 !important;
  }

  .add-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    border-radius: 50%;
    cursor: pointer;
    transition: all 0.2s;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    position: relative;
    z-index: 1;
  }

  .add-btn:hover {
    transform: scale(1.1);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.25);
  }

  .add-btn .material-symbols-outlined {
    font-size: 20px;
  }

  .dropdown {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: 0.5rem;
    background: var(--md-sys-color-surface-container);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 12px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
    z-index: 10000;
    min-width: 220px;
    max-height: 320px;
    overflow-y: auto;
    animation: dropdownFadeIn 0.2s ease-out;
  }

  @keyframes dropdownFadeIn {
    from {
      opacity: 0;
      transform: translateX(-50%) translateY(-8px);
    }
    to {
      opacity: 1;
      transform: translateX(-50%) translateY(0);
    }
  }

  .dropdown-item {
    width: 100%;
    padding: 0.875rem 1rem;
    background: none;
    border: none;
    text-align: left;
    cursor: pointer;
    font-size: 0.875rem;
    color: var(--md-sys-color-on-surface);
    transition: background 0.15s;
    display: block;
  }

  .dropdown-item:first-child {
    border-radius: 12px 12px 0 0;
  }

  .dropdown-item:last-child {
    border-radius: 0 0 12px 12px;
  }

  .dropdown-item:hover {
    background: var(--md-sys-color-surface-container-highest);
  }

  .dropdown-item:active {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
  }
</style>
