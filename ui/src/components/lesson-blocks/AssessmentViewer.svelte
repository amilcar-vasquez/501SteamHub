<script>
  export let content = { type: '', description: '' };
</script>

<div class="assessment-viewer">
  {#if content.type}
    <div class="assessment-type">
      <span class="material-symbols-outlined">task_alt</span>
      <span class="type-label">{content.type}</span>
    </div>
  {/if}

  {#if content.description}
    <div class="description">
      <p>{content.description}</p>
    </div>
  {:else}
    <p class="empty-message">No assessment description provided</p>
  {/if}
</div>

<style>
  .assessment-viewer {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .assessment-type {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-on-secondary-container);
    border-radius: var(--md-sys-shape-corner-full);
    width: fit-content;
    font-weight: 500;
  }

  .assessment-type .material-symbols-outlined {
    font-size: 1.125rem;
  }

  .description {
    padding: 1rem;
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-sm);
    line-height: 1.6;
  }

  .description p {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    white-space: pre-wrap;
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
