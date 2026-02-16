<script>
  import { generateUUID } from '../utils/uuid.js';
  import BlockRenderer from './BlockRenderer.svelte';

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

  function addBlock() {
    if (!selectedBlockType) return;

    const blockType = blockTypes.find(bt => bt.value === selectedBlockType);
    if (!blockType) return;

    const newBlock = {
      id: generateUUID(),
      type: selectedBlockType,
      title: '',
      visibility: selectedBlockType === 'teacher_notes' ? 'teacher' : 'public',
      content: JSON.parse(JSON.stringify(blockType.defaultContent)) // Deep clone
    };

    lessonContent.blocks = [...lessonContent.blocks, newBlock];
    selectedBlockType = '';
  }

  function removeBlock(blockId) {
    lessonContent.blocks = lessonContent.blocks.filter(b => b.id !== blockId);
  }

  function updateBlock(blockId, updatedBlock) {
    const index = lessonContent.blocks.findIndex(b => b.id === blockId);
    if (index !== -1) {
      lessonContent.blocks[index] = updatedBlock;
      lessonContent = lessonContent; // Trigger reactivity
    }
  }

  function moveBlockUp(index) {
    if (index === 0) return;
    const blocks = [...lessonContent.blocks];
    [blocks[index - 1], blocks[index]] = [blocks[index], blocks[index - 1]];
    lessonContent.blocks = blocks;
  }

  function moveBlockDown(index) {
    if (index === lessonContent.blocks.length - 1) return;
    const blocks = [...lessonContent.blocks];
    [blocks[index], blocks[index + 1]] = [blocks[index + 1], blocks[index]];
    lessonContent.blocks = blocks;
  }
</script>

<div class="lesson-builder">
  <div class="builder-header">
    <h3>Lesson Plan Structure</h3>
    <p class="helper-text">
      Build your lesson plan by adding structured blocks. Start with learning objectives and materials.
    </p>
  </div>

  <div class="add-block-section">
    <select bind:value={selectedBlockType} class="block-type-select">
      <option value="">Select block type to add...</option>
      {#each blockTypes as blockType}
        <option value={blockType.value}>{blockType.label}</option>
      {/each}
    </select>
    
    <button
      type="button"
      class="add-block-btn"
      on:click={addBlock}
      disabled={!selectedBlockType}
    >
      <span class="material-symbols-outlined">add_circle</span>
      Add Block
    </button>
  </div>

  {#if lessonContent.blocks.length === 0}
    <div class="empty-state">
      <span class="material-symbols-outlined">description</span>
      <p>No blocks added yet</p>
      <p class="hint">Start by adding learning objectives or materials</p>
    </div>
  {:else}
    <div class="blocks-list">
      {#each lessonContent.blocks as block, index (block.id)}
        <BlockRenderer
          {block}
          onUpdate={(updatedBlock) => updateBlock(block.id, updatedBlock)}
          onRemove={() => removeBlock(block.id)}
          onMoveUp={() => moveBlockUp(index)}
          onMoveDown={() => moveBlockDown(index)}
          isFirst={index === 0}
          isLast={index === lessonContent.blocks.length - 1}
        />
      {/each}
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

  .add-block-section {
    display: flex;
    gap: 0.75rem;
    align-items: center;
  }

  .block-type-select {
    flex: 1;
    padding: 0.875rem 1rem;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    font-size: 0.875rem;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    cursor: pointer;
  }

  .block-type-select:focus {
    outline: 2px solid var(--md-sys-color-primary);
    border-color: var(--md-sys-color-primary);
  }

  .add-block-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.875rem 1.5rem;
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    border-radius: 20px;
    cursor: pointer;
    font-size: 0.875rem;
    font-weight: 600;
    transition: all 0.2s;
    white-space: nowrap;
  }

  .add-block-btn:hover:not(:disabled) {
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  }

  .add-block-btn:disabled {
    opacity: 0.38;
    cursor: not-allowed;
  }

  .add-block-btn .material-symbols-outlined {
    font-size: 20px;
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

  .empty-state p {
    margin: 0.25rem 0;
    color: var(--md-sys-color-on-surface-variant);
  }

  .empty-state .hint {
    font-size: 0.875rem;
    opacity: 0.7;
  }

  .blocks-list {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  @media (max-width: 768px) {
    .add-block-section {
      flex-direction: column;
    }

    .block-type-select {
      width: 100%;
    }

    .add-block-btn {
      width: 100%;
      justify-content: center;
    }
  }
</style>
