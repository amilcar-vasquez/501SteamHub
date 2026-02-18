<script>
  export let content = [];
</script>

<div class="extension-viewer">
  {#if content && content.length > 0}
    <ul class="extension-list">
      {#each content as item}
        <li class="extension-item">
          <span class="material-symbols-outlined">rocket_launch</span>
          <span class="extension-text">{item}</span>
        </li>
      {/each}
    </ul>
  {:else}
    <p class="empty-message">No extension activities provided</p>
  {/if}
</div>

<style>
  .extension-viewer {
    width: 100%;
  }

  .extension-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .extension-item {
    display: flex;
    align-items: flex-start;
    gap: 0.75rem;
    padding: 1rem;
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-sm);
    border-left: 3px solid var(--md-sys-color-tertiary);
  }

  .extension-item .material-symbols-outlined {
    color: var(--md-sys-color-tertiary);
    font-size: 1.25rem;
    flex-shrink: 0;
  }

  .extension-text {
    flex: 1;
    line-height: 1.6;
    color: var(--md-sys-color-on-surface);
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
