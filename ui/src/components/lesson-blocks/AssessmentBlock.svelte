<script>
  export let content = { type: '', description: '' };
  export let onUpdate = () => {};

  const assessmentTypes = [
    { value: 'formative', label: 'Formative' },
    { value: 'summative', label: 'Summative' },
    { value: 'diagnostic', label: 'Diagnostic' },
    { value: 'peer', label: 'Peer Assessment' },
    { value: 'self', label: 'Self Assessment' },
  ];

  function handleUpdate() {
    onUpdate(content);
  }
</script>

<div class="assessment-block">
  <div class="field">
    <label for="assessment-type">Assessment Type</label>
    <select
      id="assessment-type"
      bind:value={content.type}
      on:change={handleUpdate}
    >
      <option value="">Select type...</option>
      {#each assessmentTypes as type}
        <option value={type.value}>{type.label}</option>
      {/each}
    </select>
  </div>

  <div class="field">
    <label for="assessment-desc">Description</label>
    <textarea
      id="assessment-desc"
      bind:value={content.description}
      on:input={handleUpdate}
      placeholder="Describe the assessment method and criteria..."
      rows="4"
    ></textarea>
  </div>
</div>

<style>
  .assessment-block {
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

  select,
  textarea {
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-family: inherit;
  }

  select:focus,
  textarea:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  select {
    cursor: pointer;
  }
</style>
