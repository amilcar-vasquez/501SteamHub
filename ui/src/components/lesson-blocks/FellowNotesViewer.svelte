<script>
  export let content = '';
</script>

<div class="fellow-notes-viewer">
  {#if content}
    <div class="notes-content">
      <p>{content}</p>
    </div>
  {:else}
    <p class="empty-message">No fellow notes provided</p>
  {/if}
</div>

<style>
  .fellow-notes-viewer {
    width: 100%;
  }

  .notes-content {
    padding: 1rem;
    background-color: var(--md-sys-color-tertiary-container);
    border-radius: var(--md-sys-shape-corner-sm);
    border-left: 4px solid var(--md-sys-color-tertiary);
  }

  .notes-content p {
    margin: 0;
    color: var(--md-sys-color-on-tertiary-container);
    line-height: 1.6;
    white-space: pre-wrap;
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
