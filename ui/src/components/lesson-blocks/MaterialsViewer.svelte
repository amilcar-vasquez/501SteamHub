<script>
  export let content = [];
</script>

<div class="materials-viewer">
  {#if content && content.length > 0}
    <ul class="materials-list">
      {#each content as material}
        <li class="material-item">
          <span class="material-symbols-outlined">inventory_2</span>
          <span class="material-text">{material}</span>
        </li>
      {/each}
    </ul>
  {:else}
    <p class="empty-message">No materials specified</p>
  {/if}
</div>

<style>
  .materials-viewer {
    width: 100%;
  }

  .materials-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .material-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem;
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-sm);
  }

  .material-item .material-symbols-outlined {
    color: var(--md-sys-color-secondary);
    font-size: 1.25rem;
    flex-shrink: 0;
  }

  .material-text {
    flex: 1;
    line-height: 1.5;
    color: var(--md-sys-color-on-surface);
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
