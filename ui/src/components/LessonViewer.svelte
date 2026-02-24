<script>
  import ObjectivesViewer from './lesson-blocks/ObjectivesViewer.svelte';
  import MaterialsViewer from './lesson-blocks/MaterialsViewer.svelte';
  import WarmupViewer from './lesson-blocks/WarmupViewer.svelte';
  import ActivityViewer from './lesson-blocks/ActivityViewer.svelte';
  import AssessmentViewer from './lesson-blocks/AssessmentViewer.svelte';
  import ExtensionViewer from './lesson-blocks/ExtensionViewer.svelte';
  import FellowNotesViewer from './lesson-blocks/FellowNotesViewer.svelte';
  import ReviewPanel from './review/ReviewPanel.svelte';

  export let lessonContent = { version: 1, blocks: [] };
  export let userRole = null;
  /** Enable block-level review annotation layer */
  export let reviewMode = false;
  /** Resource DB id — required when reviewMode is true */
  export let resourceId = null;
  /** currentUser object from auth store — required when reviewMode is true */
  export let currentUser = null;

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

  // Pair each block with its original index before filtering so block_index values
  // always refer to the correct position in lesson_content.blocks.
  $: visibleBlocks = (lessonContent.blocks || [])
    .map((block, originalIndex) => ({ block, originalIndex }))
    .filter(({ block }) => {
      if (block.visibility === 'fellow') {
        // Only show fellow-only blocks to certain roles
        return userRole && ['admin', 'CEO', 'DEC', 'TSC', 'Fellow'].includes(userRole);
      }
      return true;
    });
</script>

<div class="lesson-viewer">
  {#if visibleBlocks.length === 0}
    <div class="empty-state">
      <span class="material-symbols-outlined">description</span>
      <p>No lesson content available</p>
    </div>
  {:else}
    <div class="blocks-container">
      {#each visibleBlocks as { block, originalIndex }}
        <div class="block-viewer" class:fellow-only={block.visibility === 'fellow'}>
          <div class="block-header">
            <div class="block-type">
              <span class="material-symbols-outlined">{blockTypeIcons[block.type]}</span>
              <span class="type-label">{blockTypeLabels[block.type]}</span>
            </div>
            {#if block.visibility === 'fellow'}
              <span class="fellow-badge">Fellow Only</span>
            {/if}
          </div>

          {#if block.title}
            <h3 class="block-title">{block.title}</h3>
          {/if}

          <div class="block-content">
            {#if block.type === 'objectives'}
              <ObjectivesViewer content={block.content} />
            {:else if block.type === 'materials'}
              <MaterialsViewer content={block.content} />
            {:else if block.type === 'warmup'}
              <WarmupViewer content={block.content} />
            {:else if block.type === 'activity'}
              <ActivityViewer content={block.content} />
            {:else if block.type === 'assessment'}
              <AssessmentViewer content={block.content} />
            {:else if block.type === 'extension'}
              <ExtensionViewer content={block.content} />
            {:else if block.type === 'fellow_notes'}
              <FellowNotesViewer content={block.content} />
            {/if}
          </div>

          {#if reviewMode && resourceId}
            <ReviewPanel
              {resourceId}
              section={block.type}
              blockIndex={originalIndex}
              {currentUser}
            />
          {/if}
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .lesson-viewer {
    width: 100%;
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 3rem 2rem;
    color: var(--md-sys-color-on-surface-variant);
    text-align: center;
    gap: 1rem;
  }

  .empty-state .material-symbols-outlined {
    font-size: 3rem;
    opacity: 0.5;
  }

  .blocks-container {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .block-viewer {
    background-color: var(--md-sys-color-surface-container-low);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-md);
    padding: 1.5rem;
  }

  .block-viewer.fellow-only {
    background-color: var(--md-sys-color-tertiary-container);
    border-left: 4px solid var(--md-sys-color-tertiary);
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
    color: var(--md-sys-color-primary);
    font-weight: 500;
  }

  .block-type .material-symbols-outlined {
    font-size: 1.5rem;
  }

  .type-label {
    font-size: 1rem;
  }

  .fellow-badge {
    padding: 0.25rem 0.75rem;
    background-color: var(--md-sys-color-tertiary);
    color: var(--md-sys-color-on-tertiary);
    border-radius: var(--md-sys-shape-corner-full);
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .block-title {
    font-size: 1.25rem;
    font-weight: 500;
    color: var(--md-sys-color-on-surface);
    margin: 0 0 1rem 0;
  }

  .block-content {
    color: var(--md-sys-color-on-surface);
  }

  @media (max-width: 768px) {
    .block-viewer {
      padding: 1rem;
    }

    .block-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }
  }
</style>
