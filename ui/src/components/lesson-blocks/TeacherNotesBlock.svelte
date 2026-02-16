<script>
  export let content = '';
  export let onUpdate = () => {};

  function handleUpdate() {
    onUpdate(content);
  }
</script>

<div class="teacher-notes-block">
  <div class="visibility-badge">
    <span class="material-symbols-outlined">visibility_off</span>
    Teacher Only
  </div>
  
  <textarea
    bind:value={content}
    on:input={handleUpdate}
    placeholder="Add notes visible only to teachers (tips, common pitfalls, timing suggestions, etc.)..."
    rows="6"
  ></textarea>
</div>

<style>
  .teacher-notes-block {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .visibility-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.25rem 0.75rem;
    background: var(--md-sys-color-tertiary-container);
    color: var(--md-sys-color-on-tertiary-container);
    border-radius: 16px;
    font-size: 0.75rem;
    font-weight: 500;
    width: fit-content;
  }

  .visibility-badge .material-symbols-outlined {
    font-size: 16px;
  }

  textarea {
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

  textarea:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }
</style>
