<script>
  import ObjectivesBlock from './lesson-blocks/ObjectivesBlock.svelte';
  import MaterialsBlock from './lesson-blocks/MaterialsBlock.svelte';
  import WarmupBlock from './lesson-blocks/WarmupBlock.svelte';
  import ActivityBlock from './lesson-blocks/ActivityBlock.svelte';
  import AssessmentBlock from './lesson-blocks/AssessmentBlock.svelte';
  import ExtensionBlock from './lesson-blocks/ExtensionBlock.svelte';
  import TeacherNotesBlock from './lesson-blocks/TeacherNotesBlock.svelte';

  export let block;
  export let onUpdate;
  export let onRemove;
  export let onMoveUp;
  export let onMoveDown;
  export let isFirst;
  export let isLast;

  const blockTypeLabels = {
    objectives: '🎯 Learning Objectives',
    materials: '📦 Materials',
    warmup: '🔥 Warm-up',
    activity: '⚡ Activity',
    assessment: '✅ Assessment',
    extension: '🚀 Extension',
    teacher_notes: '📝 Teacher Notes',
  };

  const blockTypeIcons = {
    objectives: 'emoji_objects',
    materials: 'inventory_2',
    warmup: 'local_fire_department',
    activity: 'bolt',
    assessment: 'task_alt',
    extension: 'rocket_launch',
    teacher_notes: 'note',
  };

  function handleContentUpdate(newContent) {
    onUpdate({ ...block, content: newContent });
  }

  function handleTitleUpdate(event) {
    onUpdate({ ...block, title: event.target.value });
  }
</script>

<div class="block-container">
  <div class="block-header">
    <div class="block-type">
      <span class="material-symbols-outlined">{blockTypeIcons[block.type]}</span>
      <span class="type-label">{blockTypeLabels[block.type]}</span>
    </div>

    <div class="block-actions">
      <button
        type="button"
        class="icon-btn"
        on:click={onMoveUp}
        disabled={isFirst}
        title="Move up"
      >
        <span class="material-symbols-outlined">arrow_upward</span>
      </button>
      <button
        type="button"
        class="icon-btn"
        on:click={onMoveDown}
        disabled={isLast}
        title="Move down"
      >
        <span class="material-symbols-outlined">arrow_downward</span>
      </button>
      <button
        type="button"
        class="icon-btn delete"
        on:click={onRemove}
        title="Remove block"
      >
        <span class="material-symbols-outlined">delete</span>
      </button>
    </div>
  </div>

  {#if block.type !== 'objectives' && block.type !== 'materials'}
    <div class="block-title-input">
      <input
        type="text"
        bind:value={block.title}
        on:input={handleTitleUpdate}
        placeholder="Block title (optional)"
        class="title-input"
      />
    </div>
  {/if}

  <div class="block-content">
    {#if block.type === 'objectives'}
      <ObjectivesBlock content={block.content} onUpdate={handleContentUpdate} />
    {:else if block.type === 'materials'}
      <MaterialsBlock content={block.content} onUpdate={handleContentUpdate} />
    {:else if block.type === 'warmup'}
      <WarmupBlock content={block.content} onUpdate={handleContentUpdate} />
    {:else if block.type === 'activity'}
      <ActivityBlock content={block.content} onUpdate={handleContentUpdate} />
    {:else if block.type === 'assessment'}
      <AssessmentBlock content={block.content} onUpdate={handleContentUpdate} />
    {:else if block.type === 'extension'}
      <ExtensionBlock content={block.content} onUpdate={handleContentUpdate} />
    {:else if block.type === 'teacher_notes'}
      <TeacherNotesBlock content={block.content} onUpdate={handleContentUpdate} />
    {/if}
  </div>
</div>

<style>
  .block-container {
    background: var(--md-sys-color-surface-container-low);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 12px;
    padding: 1.25rem;
    transition: box-shadow 0.2s;
  }

  .block-container:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .block-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  .block-type {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-weight: 600;
    color: var(--md-sys-color-primary);
  }

  .block-type .material-symbols-outlined {
    font-size: 24px;
  }

  .type-label {
    font-size: 1rem;
  }

  .block-actions {
    display: flex;
    gap: 0.25rem;
  }

  .icon-btn {
    background: none;
    border: none;
    color: var(--md-sys-color-on-surface-variant);
    cursor: pointer;
    padding: 0.5rem;
    display: flex;
    align-items: center;
    border-radius: 50%;
    transition: background 0.2s;
  }

  .icon-btn:hover:not(:disabled) {
    background: rgba(0, 0, 0, 0.05);
  }

  .icon-btn:disabled {
    opacity: 0.38;
    cursor: not-allowed;
  }

  .icon-btn.delete {
    color: var(--md-sys-color-error);
  }

  .icon-btn.delete:hover {
    background: rgba(179, 38, 30, 0.1);
  }

  .icon-btn .material-symbols-outlined {
    font-size: 20px;
  }

  .block-title-input {
    margin-bottom: 1rem;
  }

  .title-input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 1rem;
    font-weight: 500;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
  }

  .title-input:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  .block-content {
    margin-top: 1rem;
  }
</style>
