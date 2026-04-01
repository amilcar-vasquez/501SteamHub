/**
 * LocalStorage utilities for persisting form state
 */

const STORAGE_KEY = 'submitResourceDraft';

/**
 * Save form data and lesson content to localStorage
 */
export function saveDraftToLocalStorage(formData, lessonContent, videoDetails, draftResourceId = null) {
  try {
    const draftData = {
      formData,
      lessonContent,
      videoDetails,
      draftResourceId,
      timestamp: new Date().toISOString(),
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(draftData));
  } catch (error) {
    console.error('Failed to save draft to localStorage:', error);
  }
}

/**
 * Load form data and lesson content from localStorage
 */
export function loadDraftFromLocalStorage() {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      const draftData = JSON.parse(stored);
      return {
        formData: draftData.formData || {},
        lessonContent: draftData.lessonContent || { version: 1, blocks: [] },
        videoDetails: draftData.videoDetails || {
          youtube_title: '',
          youtube_description: '',
          tags: '',
          privacy_status: 'unlisted',
          made_for_kids: true,
        },
        draftResourceId: draftData.draftResourceId || null,
        timestamp: draftData.timestamp,
      };
    }
  } catch (error) {
    console.error('Failed to load draft from localStorage:', error);
  }
  return null;
}

/**
 * Clear the draft from localStorage
 */
export function clearDraftFromLocalStorage() {
  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch (error) {
    console.error('Failed to clear draft from localStorage:', error);
  }
}

/**
 * Check if a draft exists in localStorage
 */
export function hasDraftInLocalStorage() {
  try {
    return localStorage.getItem(STORAGE_KEY) !== null;
  } catch (error) {
    console.error('Failed to check localStorage:', error);
    return false;
  }
}
