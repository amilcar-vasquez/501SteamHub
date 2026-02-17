<script>
  import { generateUUID } from '../utils/uuid.js';
  import { dndzone } from 'svelte-dnd-action';
  import BlockRenderer from './BlockRenderer.svelte';
  import AddBlockButton from './AddBlockButton.svelte';

  export let lessonContent = {
    version: 1,
    blocks: []
  };

  const blockTypes = [
    { value: 'objectives', label: '🎯 Learning Objectives', defaultContent: [] },
    { value: 'materials', label: '📦 Materials', defaultContent: [] },
    { value: 'warmup', label: '🔥 Warm-up', defaultContent: { description: '', duration_minutes: 5 } },
    { value: 'activity', label: '⚡ Activity', defaultContent: [] },
    { value: 'assessment', label: '✅ Assessment', defaultContent: { type: '', description: '' } },
    { value: 'extension', label: '🚀 Extension', defaultContent: [] },
    { value: 'teacher_notes', label: '📝 Teacher Notes', defaultContent: '' },
  ];

  let selectedBlockType = '';
  const flipDurationMs = 200;
  const dragDisabledDefault = false;

  // Pure function to create new block
  function createNewBlock(blockTypeValue) {
    const blockType = blockTypes.find(bt => bt.value === blockTypeValue);
    if (!blockType) return null;

    return {
      id: generateUUID(),
      type: blockTypeValue,
      title: '',
      visibility: blockTypeValue === 'teacher_notes' ? 'teacher' : 'public',
      content: JSON.parse(JSON.stringify(blockType.defaultContent))
    };
  }

  // Immutable block insertion at end
  function addBlock() {
    if (!selectedBlockType) return;
    const newBlock = createNewBlock(selectedBlockType);
    if (newBlock) {
      lessonContent = {
        ...lessonContent,
        blocks: [...lessonContent.blocks, newBlock]
      };
      selectedBlockType = '';
    }
  }

  // Immutable block insertion at specific index
  function addBlockAtIndex(event, index) {
    const newBlock = createNewBlock(event.detail.blockType);
    if (newBlock) {
      lessonContent = {
        ...lessonContent,
        blocks: [
          ...lessonContent.blocks.slice(0, index),
          newBlock,
          ...lessonContent.blocks.slice(index)
        ]
      };
    }
  }

  // Quick add for empty state
  function addQuickBlock(blockTypeValue) {
    const newBlock = createNewBlock(blockTypeValue);
    if (newBlock) {
      lessonContent = {
        ...lessonContent,
        blocks: [...lessonContent.blocks, newBlock]
      };
    }
  }

  // Immutable block removal
  function removeBlock(blockId) {
    lessonContent = {
      ...lessonContent,
      blocks: lessonContent.blocks.filter(b => b.id !== blockId)
    };
  }

  // Immutable block update
  function updateBlock(blockId, updatedBlock) {
    lessonContent = {
      ...lessonContent,
      blocks: lessonContent.blocks.map(b => 
        b.id === blockId ? updatedBlock : b
      )
    };
  }

  // Handle drag and drop events
  function handleDndConsider(e) {
    lessonContent = {
      ...lessonContent,
      blocks: e.detail.items
    };
  }

  function handleDndFinalize(e) {
    lessonContent = {
      ...lessonContent,
      blocks: e.detail.items
    };
  }
</script>

<div class="lesson-builder">
  <div class="builder-header">
    <h3>Lesson Plan Structure</h3>
    <p class="helper-text">
      Build your lesson plan by adding structured blocks. Drag to reorder.
    </p>
  </div>
  {#if lessonContent.blocks.length === 0}
    <div class="empty-state">
      <span class="material-symbols-outlined">description</span>
      <h4>Start Building Your Lesson</h4>
      <p class="hint">Add structured blocks to create your lesson plan</p>
      
      <div class="quick-add-buttons">
        <button
          type="button"
          class="quick-add-btn"
          on:click={() => addQuickBlock('objectives')}
        >
          <span class="material-symbols-outlined">emoji_objects</span>
          Add Objectives
        </button>
        <button
          type="button"
          class="quick-add-btn"
          on:click={() => addQuickBlock('activity')}
        >
          <span class="material-symbols-outlined">bolt</span>
          Add Activity
        </button>
        <button
          type="button"
          class="quick-add-btn"
          on:click={() => addQuickBlock('assessment')}
        >
          <span class="material-symbols-outlined">task_alt</span>
          Add Assessment
        </button>
      </div>
    </div>
  {:else}
    <div class="blocks-container">
      <AddBlockButton {blockTypes} on:add={(e) => addBlockAtIndex(e, 0)} />
      
      <div 
        class="blocks-list"
        use:dndzone={{
          items: lessonContent.blocks, 
          flipDurationMs,
          dragDisabled: dragDisabledDefault,
          dropTargetStyle: { outline: '2px dashed var(--md-sys-color-primary)', outlineOffset: '4px' },
          type: 'blocks'
        }}
        on:consider={handleDndConsider}
        on:finalize={handleDndFinalize}
      >
        {#each lessonContent.blocks as block (block.id)}
          <div class="block-item">
            <BlockRenderer
              {block}
              onUpdate={(updatedBlock) => updateBlock(block.id, updatedBlock)}
              onRemove={() => removeBlock(block.id)}
            />
            <AddBlockButton 
              {blockTypes} 
              on:add={(e) => addBlockAtIndex(e, lessonContent.blocks.findIndex(b => b.id === block.id) + 1)} 
            />
          </div>
        {/each}
      </div>
    </div>
  {/if}
</div>

<style>
  .lesson-builder {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .builder-header h3 {
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--md-sys-color-primary);
    margin: 0 0 0.5rem 0;
  }

  .helper-text {
    font-size: 0.875rem;
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
  }
  
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 3rem 2rem;
    background: var(--md-sys-color-surface-container-low);
    border: 2px dashed var(--md-sys-color-outline-variant);
    border-radius: 12px;
    text-align: center;
  }

  .empty-state .material-symbols-outlined {
    font-size: 64px;
    color: var(--md-sys-color-on-surface-variant);
    opacity: 0.5;
    margin-bottom: 1rem;
  }

  .empty-state h4 {
    margin: 0.5rem 0;
    font-size: 1.25rem;
    font-weight: 600;
    color: var(--md-sys-color-on-surface);
  }

  .empty-state p {
    margin: 0.25rem 0;
    color: var(--md-sys-color-on-surface-variant);
  }

  .empty-state .hint {
    font-size: 0.875rem;
    opacity: 0.7;
    margin-bottom: 2rem;
  }

  .quick-add-buttons {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
    justify-content: center;
  }

  .quick-add-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.875rem 1.5rem;
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border: none;
    border-radius: 20px;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 600;
    transition: all 0.2s;
  }

  .quick-add-btn:hover {
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    transform: translateY(-2px);
  }

  .quick-add-btn .material-symbols-outlined {
    font-size: 20px;
  }

  .blocks-container {
    display: flex;
    flex-direction: column;
    position: relative;
  }

  .blocks-list {
    display: flex;
    flex-direction: column;
    min-height: 100px;
    gap: 0;
    position: relative;
  }

  .block-item {
    display: flex;
    flex-direction: column;
    transition: transform 0.2s ease, opacity 0.2s ease;
    position: relative;
  }

  .block-item:has(.add-block-button .dropdown) {
    z-index: 9999;
  }

  /* Dragging states - global styles for dnd-action library */
  :global(.blocks-list .block-item[aria-grabbed="true"]) {
    opacity: 0.4;
    cursor: grabbing;
  }

  :global(.blocks-list .block-item[aria-grabbed="true"] *) {
    cursor: grabbing !important;
  }

  :global(.blocks-list .block-item.svelte-dnd-shadow-placeholder) {
    background: var(--md-sys-color-primary-container);
    border: 2px dashed var(--md-sys-color-primary);
    border-radius: 12px;
    opacity: 0.3;
  }

  :global(.blocks-list .block-item:not([aria-grabbed="true"])) {
    cursor: default;
  }

  /* Smooth reordering animation */
  .block-item {
    will-change: transform;
  }
</style>
