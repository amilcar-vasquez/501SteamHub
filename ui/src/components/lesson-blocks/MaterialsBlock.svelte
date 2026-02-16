<script>
  export let content = [];
  export let onUpdate = () => {};

  function addMaterial() {
    content = [...content, ''];
    onUpdate(content);
  }

  function removeMaterial(index) {
    content = content.filter((_, i) => i !== index);
    onUpdate(content);
  }

  function updateMaterial(index, value) {
    content[index] = value;
    onUpdate(content);
  }
</script>

<div class="materials-block">
  <div class="materials-list">
    {#each content as material, index}
      <div class="material-item">
        <span class="material-bullet">•</span>
        <input
          type="text"
          bind:value={content[index]}
          on:input={() => updateMaterial(index, content[index])}
          placeholder="Enter material required..."
          class="material-input"
        />
        <button
          type="button"
          class="remove-btn"
          on:click={() => removeMaterial(index)}
          title="Remove material"
        >
          <span class="material-symbols-outlined">close</span>
        </button>
      </div>
    {/each}
  </div>

  <button type="button" class="add-btn" on:click={addMaterial}>
    <span class="material-symbols-outlined">add</span>
    Add Material
  </button>
</div>

<style>
  .materials-block {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .materials-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .material-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .material-bullet {
    font-size: 1.5rem;
    color: var(--md-sys-color-primary);
    min-width: 24px;
    text-align: center;
  }

  .material-input {
    flex: 1;
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
  }

  .material-input:focus {
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
