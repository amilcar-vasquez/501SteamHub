<script>
  export let content = [];
  export let onUpdate = () => {};

  function addStep() {
    content = [...content, { step: content.length + 1, text: '' }];
    onUpdate(content);
  }

  function removeStep(index) {
    content = content.filter((_, i) => i !== index);
    // Renumber steps
    content = content.map((step, i) => ({ ...step, step: i + 1 }));
    onUpdate(content);
  }

  function updateStep(index, text) {
    content[index].text = text;
    onUpdate(content);
  }
</script>

<div class="activity-block">
  <div class="steps-list">
    {#each content as step, index}
      <div class="step-item">
        <div class="step-number">Step {step.step}</div>
        <textarea
          bind:value={content[index].text}
          on:input={() => updateStep(index, content[index].text)}
          placeholder="Describe this step..."
          rows="3"
          class="step-input"
        ></textarea>
        <button
          type="button"
          class="remove-btn"
          on:click={() => removeStep(index)}
          title="Remove step"
        >
          <span class="material-symbols-outlined">close</span>
        </button>
      </div>
    {/each}
  </div>

  <button type="button" class="add-btn" on:click={addStep}>
    <span class="material-symbols-outlined">add</span>
    Add Step
  </button>
</div>

<style>
  .activity-block {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .steps-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .step-item {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    padding: 1rem;
    background: var(--md-sys-color-surface-container);
    border-radius: 8px;
    position: relative;
  }

  .step-number {
    font-weight: 600;
    color: var(--md-sys-color-primary);
    font-size: 0.875rem;
  }

  .step-input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-family: inherit;
    resize: vertical;
  }

  .step-input:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  .remove-btn {
    position: absolute;
    top: 0.5rem;
    right: 0.5rem;
    background: none;
    border: none;
    color: var(--md-sys-color-error);
    cursor: pointer;
    padding: 0.25rem;
    display: flex;
    align-items: center;
    border-radius: 4px;
  }

  .remove-btn:hover {
    background: rgba(179, 38, 30, 0.1);
  }

  .remove-btn .material-symbols-outlined {
    font-size: 20px;
  }

  .add-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 500;
    transition: background 0.2s;
  }

  .add-btn:hover {
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
  }

  .add-btn .material-symbols-outlined {
    font-size: 20px;
  }
</style>
