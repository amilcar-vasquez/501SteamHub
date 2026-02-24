<script>
  import { slide } from 'svelte/transition';
  import ObjectivesBlock from './lesson-blocks/ObjectivesBlock.svelte';
  import MaterialsBlock from './lesson-blocks/MaterialsBlock.svelte';
  import WarmupBlock from './lesson-blocks/WarmupBlock.svelte';
  import ActivityBlock from './lesson-blocks/ActivityBlock.svelte';
  import AssessmentBlock from './lesson-blocks/AssessmentBlock.svelte';
  import ExtensionBlock from './lesson-blocks/ExtensionBlock.svelte';
  import FellowNotesBlock from './lesson-blocks/FellowNotesBlock.svelte';
  import ReviewPanel from './review/ReviewPanel.svelte';

  export let block;
  export let onUpdate;
  export let onRemove;
  /** Enable block-level review annotation layer */
  export let reviewMode = false;
  /** Resource DB id — required when reviewMode is true */
  export let resourceId = null;
  /** Position of this block inside lesson_content.blocks */
  export let blockIndex = 0;
  /** currentUser object from auth store — required when reviewMode is true */
  export let currentUser = null;

  let collapsed = false;

  const blockTypeLabels = {
    objectives: '🎯 Learning Objectives',
    materials: '📦 Materials',
    warmup: '🔥 Warm-up',
    activity: '⚡ Activity',
    assessment: '✅ Assessment',
    extension: '🚀 Extension',
    fellow_notes: '📝 Fellow Notes',
  };

  const blockTypeIcons = {
    objectives: 'emoji_objects',
    materials: 'inventory_2',
    warmup: 'local_fire_department',
    activity: 'bolt',
    assessment: 'task_alt',
    extension: 'rocket_launch',
    fellow_notes: 'note',
  };

  // Pure update functions - return new object
  function handleContentUpdate(newContent) {
    onUpdate({ ...block, content: newContent });
  }

  function handleTitleUpdate(event) {
    onUpdate({ ...block, title: event.target.value });
  }

  function toggleCollapsed() {
    collapsed = !collapsed;
  }

  function toggleVisibility() {
    const newVisibility = block.visibility === 'public' ? 'fellow' : 'public';
    onUpdate({ ...block, visibility: newVisibility });
  }
</script>

<div class="block-container" class:fellow-only={block.visibility === 'fellow'} class:collapsed>
  <div class="block-header">
    <div class="header-left">
      <div
        class="drag-handle"
        role="button"
        aria-label="Drag to reorder"
        tabindex="0"
      >
        <span class="material-symbols-outlined">drag_indicator</span>
      </div>
      
      <div class="block-type">
        <span class="material-symbols-outlined">{blockTypeIcons[block.type]}</span>
        <span class="type-label">{blockTypeLabels[block.type]}</span>
      </div>
    </div>

    <div class="block-actions">
      <button
        type="button"
        class="icon-btn visibility-toggle"
        on:click={toggleVisibility}
        title={block.visibility === 'public' ? 'Visible to all' : 'Fellow only'}
        aria-label={block.visibility === 'public' ? 'Make fellow only' : 'Make visible to all'}
      >
        <span class="material-symbols-outlined">
          {block.visibility === 'public' ? 'visibility' : 'visibility_off'}
        </span>
      </button>
      
      <button
        type="button"
        class="icon-btn collapse-toggle"
        on:click={toggleCollapsed}
        title={collapsed ? 'Expand block' : 'Collapse block'}
        aria-label={collapsed ? 'Expand' : 'Collapse'}
      >
        <span class="material-symbols-outlined">
          {collapsed ? 'expand_more' : 'expand_less'}
        </span>
      </button>
      
      <button
        type="button"
        class="icon-btn delete"
        on:click={onRemove}
        title="Remove block"
        aria-label="Delete block"
      >
        <span class="material-symbols-outlined">delete</span>
      </button>
    </div>
  </div>

  {#if !collapsed}
    <div class="block-body" transition:slide={{ duration: 200 }}>
      {#if block.type !== 'objectives' && block.type !== 'materials'}
        <div class="block-title-input">
          <input
            type="text"
            bind:value={block.title}
            on:input={handleTitleUpdate}
            placeholder="Block title (optional)"
            class="title-input"
            aria-label="Block title"
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
        {:else if block.type === 'fellow_notes'}
          <FellowNotesBlock content={block.content} onUpdate={handleContentUpdate} />
        {/if}
      </div>

      {#if reviewMode && resourceId}
        <ReviewPanel
          {resourceId}
          section={block.type}
          {blockIndex}
          {currentUser}
        />
      {/if}
    </div>
  {/if}
</div>

<style>
  .block-container {
    background: var(--md-sys-color-surface-container-low);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: 12px;
    padding: 1.25rem;
    transition: all 0.2s;
    margin: 0.5rem 0;
    will-change: transform;
    position: relative;
  }

  .block-container:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .block-container.fellow-only {
    background: var(--md-sys-color-tertiary-container);
    border-left: 4px solid var(--md-sys-color-tertiary);
  }

  .block-container.fellow-only::before {
    content: 'Fellow Only';
    position: absolute;
    top: 0.5rem;
    right: 0.5rem;
    font-size: 0.625rem;
    text-transform: uppercase;
    font-weight: 600;
    color: var(--md-sys-color-tertiary);
    opacity: 0.6;
  }

  .block-container.collapsed {
    padding: 1rem 1.25rem;
  }

  .block-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .header-left {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex: 1;
  }

  .drag-handle {
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--md-sys-color-on-surface-variant);
    cursor: grab;
    padding: 0.25rem;
    border-radius: 4px;
    transition: all 0.2s;
    user-select: none;
  }

  .drag-handle:hover {
    background: rgba(0, 0, 0, 0.05);
    color: var(--md-sys-color-primary);
  }

  .drag-handle:active {
    cursor: grabbing;
  }

  .drag-handle .material-symbols-outlined {
    font-size: 20px;
    pointer-events: none;
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

  .icon-btn.visibility-toggle {
    color: var(--md-sys-color-tertiary);
  }

  .icon-btn.collapse-toggle {
    color: var(--md-sys-color-primary);
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

  .block-body {
    overflow: hidden;
  }

  .block-title-input {
    margin-top: 1rem;
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
