// Simple auth store for managing authentication state
import { writable } from 'svelte/store';

// Initialize from localStorage if available
const storedToken = typeof window !== 'undefined' ? localStorage.getItem('authToken') : null;
const storedUser = typeof window !== 'undefined' ? localStorage.getItem('authUser') : null;

export const authToken = writable(storedToken);
export const currentUser = writable(storedUser ? JSON.parse(storedUser) : null);

// Subscribe to token changes and sync with localStorage
authToken.subscribe(value => {
  if (typeof window !== 'undefined') {
    if (value) {
      localStorage.setItem('authToken', value);
    } else {
      localStorage.removeItem('authToken');
    }
  }
});

// Subscribe to user changes and sync with localStorage
currentUser.subscribe(value => {
  if (typeof window !== 'undefined') {
    if (value) {
      localStorage.setItem('authUser', JSON.stringify(value));
    } else {
      localStorage.removeItem('authUser');
    }
  }
});

// Helper function to check if user is authenticated
export function isAuthenticated() {
  let token = null;
  authToken.subscribe(value => token = value)();
  return !!token;
}

// Helper function to sign out
export function signOut() {
  authToken.set(null);
  currentUser.set(null);
}
