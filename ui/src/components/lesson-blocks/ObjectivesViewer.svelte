<script>
  export let content = [];
</script>

<div class="objectives-viewer">
  {#if content && content.length > 0}
    <ul class="objectives-list">
      {#each content as objective}
        <li class="objective-item">
          <span class="material-symbols-outlined check-icon">check_circle</span>
          <span class="objective-text">{objective}</span>
        </li>
      {/each}
    </ul>
  {:else}
    <p class="empty-message">No learning objectives specified</p>
  {/if}
</div>

<style>
  .objectives-viewer {
    width: 100%;
  }

  .objectives-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .objective-item {
    display: flex;
    align-items: flex-start;
    gap: 0.75rem;
    padding: 0.75rem;
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-sm);
  }

  .check-icon {
    color: var(--md-sys-color-primary);
    font-size: 1.25rem;
    flex-shrink: 0;
  }

  .objective-text {
    flex: 1;
    line-height: 1.5;
    color: var(--md-sys-color-on-surface);
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
