<script>
  export let content = { description: '', duration_minutes: 5 };
  export let onUpdate = () => {};

  function handleUpdate() {
    onUpdate(content);
  }
</script>

<div class="warmup-block">
  <div class="field">
    <label for="warmup-desc">Description</label>
    <textarea
      id="warmup-desc"
      bind:value={content.description}
      on:input={handleUpdate}
      placeholder="Describe the warm-up activity..."
      rows="4"
    ></textarea>
  </div>

  <div class="field">
    <label for="warmup-duration">Duration (minutes)</label>
    <input
      id="warmup-duration"
      type="number"
      bind:value={content.duration_minutes}
      on:input={handleUpdate}
      min="1"
      max="60"
    />
  </div>
</div>

<style>
  .warmup-block {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .field {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  label {
    font-size: 0.875rem;
    font-weight: 500;
    color: var(--md-sys-color-on-surface);
  }

  textarea,
  input {
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-family: inherit;
  }

  textarea:focus,
  input:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  input[type="number"] {
    max-width: 150px;
  }
</style>
