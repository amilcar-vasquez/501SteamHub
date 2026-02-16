<script>
  export let content = [];
  export let onUpdate = () => {};

  function addExtension() {
    content = [...content, ''];
    onUpdate(content);
  }

  function removeExtension(index) {
    content = content.filter((_, i) => i !== index);
    onUpdate(content);
  }

  function updateExtension(index, value) {
    content[index] = value;
    onUpdate(content);
  }
</script>

<div class="extension-block">
  <div class="extensions-list">
    {#each content as extension, index}
      <div class="extension-item">
        <span class="extension-bullet">→</span>
        <input
          type="text"
          bind:value={content[index]}
          on:input={() => updateExtension(index, content[index])}
          placeholder="Enter extension activity..."
          class="extension-input"
        />
        <button
          type="button"
          class="remove-btn"
          on:click={() => removeExtension(index)}
          title="Remove extension"
        >
          <span class="material-symbols-outlined">close</span>
        </button>
      </div>
    {/each}
  </div>

  <button type="button" class="add-btn" on:click={addExtension}>
    <span class="material-symbols-outlined">add</span>
    Add Extension Activity
  </button>
</div>

<style>
  .extension-block {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .extensions-list {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .extension-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .extension-bullet {
    font-size: 1.25rem;
    font-weight: bold;
    color: var(--md-sys-color-primary);
    min-width: 24px;
    text-align: center;
  }

  .extension-input {
    flex: 1;
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
  }

  .extension-input:focus {
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
