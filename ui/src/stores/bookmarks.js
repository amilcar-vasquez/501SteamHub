// Bookmarks store for managing user's saved resources
import { writable } from 'svelte/store';
import { currentUser } from './auth.js';

// Get the localStorage key scoped to current user
function getBookmarksKey() {
  let userId = null;
  currentUser.subscribe(user => {
    userId = user?.user_id || user?.id;
  })();
  return userId ? `bookmarkedResourceIds_${userId}` : null;
}

// Initialize from localStorage if available
const storedBookmarks = typeof window !== 'undefined' 
  ? (() => {
      try {
        const key = getBookmarksKey();
        if (!key) return [];
        const stored = localStorage.getItem(key);
        return stored ? JSON.parse(stored) : [];
      } catch (err) {
        console.error('Failed to parse bookmarks from localStorage:', err);
        return [];
      }
    })()
  : [];

export const bookmarkedResourceIds = writable(new Set(storedBookmarks));

// Subscribe to changes and sync with localStorage
bookmarkedResourceIds.subscribe(value => {
  if (typeof window !== 'undefined') {
    try {
      const key = getBookmarksKey();
      if (!key) return;
      localStorage.setItem(key, JSON.stringify(Array.from(value)));
    } catch (err) {
      console.error('Failed to save bookmarks to localStorage:', err);
    }
  }
});

// Helper functions
export function toggleBookmark(resourceId) {
  bookmarkedResourceIds.update(bookmarks => {
    const newBookmarks = new Set(bookmarks);
    if (newBookmarks.has(resourceId)) {
      newBookmarks.delete(resourceId);
    } else {
      newBookmarks.add(resourceId);
    }
    return newBookmarks;
  });
}

export function isBookmarked(resourceId) {
  let isBookmarkedValue = false;
  bookmarkedResourceIds.subscribe(bookmarks => {
    isBookmarkedValue = bookmarks.has(resourceId);
  })();
  return isBookmarkedValue;
}

export function clearAllBookmarks() {
  bookmarkedResourceIds.set(new Set());
}
