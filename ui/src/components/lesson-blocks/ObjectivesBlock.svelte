<script>
  export let content = [];
  export let onUpdate = () => {};

  function addObjective() {
    content = [...content, ''];
    onUpdate(content);
  }

  function removeObjective(index) {
    content = content.filter((_, i) => i !== index);
    onUpdate(content);
  }

  function updateObjective(index, value) {
    content[index] = value;
    onUpdate(content);
  }
</script>

<div class="objectives-block">
  <div class="objectives-list">
    {#each content as objective, index}
      <div class="objective-item">
        <span class="objective-number">{index + 1}.</span>
        <input
          type="text"
          bind:value={content[index]}
          on:input={() => updateObjective(index, content[index])}
          placeholder="Enter learning objective..."
          class="objective-input"
        />
        <button
          type="button"
          class="remove-btn"
          on:click={() => removeObjective(index)}
          title="Remove objective"
        >
          <span class="material-symbols-outlined">close</span>
        </button>
      </div>
    {/each}
  </div>

  <button type="button" class="add-btn" on:click={addObjective}>
    <span class="material-symbols-outlined">add</span>
    Add Objective
  </button>
</div>

<style>
  .objectives-block {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .objectives-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .objective-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .objective-number {
    font-weight: 500;
    color: var(--md-sys-color-primary);
    min-width: 24px;
  }

  .objective-input {
    flex: 1;
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
  }

  .objective-input:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  .remove-btn {
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
