<script>
  export let content = [];
</script>

<div class="activity-viewer">
  {#if content && content.length > 0}
    <div class="steps-container">
      {#each content as step}
        <div class="step-item">
          <div class="step-number">Step {step.step}</div>
          <div class="step-text">{step.text}</div>
        </div>
      {/each}
    </div>
  {:else}
    <p class="empty-message">No activity steps provided</p>
  {/if}
</div>

<style>
  .activity-viewer {
    width: 100%;
  }

  .steps-container {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .step-item {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 1rem;
    background-color: var(--md-sys-color-surface-container);
    border-radius: var(--md-sys-shape-corner-sm);
    border-left: 4px solid var(--md-sys-color-primary);
  }

  .step-number {
    font-weight: 600;
    color: var(--md-sys-color-primary);
    font-size: 0.875rem;
    text-transform: uppercase;
  }

  .step-text {
    color: var(--md-sys-color-on-surface);
    line-height: 1.6;
    white-space: pre-wrap;
  }

  .empty-message {
    color: var(--md-sys-color-on-surface-variant);
    font-style: italic;
  }
</style>
