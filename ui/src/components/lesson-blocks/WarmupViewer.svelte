<script>
  export let content = { description: '', duration_minutes: 5 };
</script>

<div class="warmup-viewer">
  {#if content.duration_minutes}
    <div class="duration-badge">
      <span class="material-symbols-outlined">schedule</span>
      {content.duration_minutes} minutes
    </div>
  {/if}

  {#if content.description}
    <div class="description">
      <p>{content.description}</p>
    </div>
  {:else}
    <p class="empty-message">No warm-up description provided</p>
  {/if}
</div>

<style>
  .warmup-viewer {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .duration-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background-color: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border-radius: var(--md-sys-shape-corner-full);
    width: fit-content;
    font-weight: 500;
  }

  .duration-badge .material-symbols-outlined {
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
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
