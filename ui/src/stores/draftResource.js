import { writable } from 'svelte/store';

/**
 * Draft resource store to track the current resource being edited
 * Allows users to save drafts and resume editing later
 */
function createDraftResourceStore() {
  const { subscribe, set, update } = writable({
    id: null,
    resourceId: null,
    title: '',
    category: '',
    subjects: [],
    grade_levels: [],
    summary: '',
    drive_link: '',
    lesson_content: { version: 1, blocks: [] },
    video_metadata: null,
    lastSaved: null,
    isDirty: false,
  });

  return {
    subscribe,
    /**
     * Initialize or update the current draft
     */
    set: (resourceId, formData, lessonContent, videoMetadata = null) =>
      update(() => ({
        resourceId,
        title: formData.title,
        category: formData.category,
        subjects: formData.subjects,
        grade_levels: formData.grade_levels,
        summary: formData.summary,
        drive_link: formData.drive_link,
        lesson_content: lessonContent || { version: 1, blocks: [] },
        video_metadata: videoMetadata,
        lastSaved: new Date(),
        isDirty: false,
      })),
    /**
     * Mark draft as modified
     */
    markDirty: () => update(state => ({ ...state, isDirty: true })),
    /**
     * Mark draft as saved
     */
    markSaved: () =>
      update(state => ({
        ...state,
        lastSaved: new Date(),
        isDirty: false,
      })),
    /**
     * Clear the current draft
     */
    clear: () =>
      update(() => ({
        id: null,
        resourceId: null,
        title: '',
        category: '',
        subjects: [],
        grade_levels: [],
        summary: '',
        drive_link: '',
        lesson_content: { version: 1, blocks: [] },
        video_metadata: null,
        lastSaved: null,
        isDirty: false,
      })),
  };
}

// Export the draft store
export const draftResource = createDraftResourceStore();
