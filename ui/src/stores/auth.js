// Auth store with token expiry tracking and auto-logout
import { writable } from 'svelte/store';

// Initialize from localStorage if available
const storedToken = typeof window !== 'undefined' ? localStorage.getItem('authToken') : null;
const storedUser = typeof window !== 'undefined' ? localStorage.getItem('authUser') : null;
const storedExpiry = typeof window !== 'undefined' ? localStorage.getItem('tokenExpiry') : null;

export const authToken = writable(storedToken);
export const currentUser = writable(storedUser ? JSON.parse(storedUser) : null);
export const tokenExpiry = writable(storedExpiry ? new Date(storedExpiry) : null);

// Subscribe to token changes and sync with localStorage
authToken.subscribe(value => {
  if (typeof window !== 'undefined') {
    if (value) {
      localStorage.setItem('authToken', value);
    } else {
      localStorage.removeItem('authToken');
      localStorage.removeItem('tokenExpiry');
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

// Subscribe to expiry changes and sync with localStorage
tokenExpiry.subscribe(value => {
  if (typeof window !== 'undefined') {
    if (value) {
      localStorage.setItem('tokenExpiry', value.toISOString());
    } else {
      localStorage.removeItem('tokenExpiry');
    }
  }
});

// Check if token is expired
export function isTokenExpired() {
  let expiry = null;
  tokenExpiry.subscribe(value => expiry = value)();
  if (!expiry) return false;
  return new Date() > expiry;
}

// Get minutes until token expires
export function getTimeUntilExpiry() {
  let expiry = null;
  tokenExpiry.subscribe(value => expiry = value)();
  if (!expiry) return null;
  const minutes = Math.floor((expiry - new Date()) / 1000 / 60);
  return Math.max(0, minutes);
}

// Helper function to check if user is authenticated
export function isAuthenticated() {
  if (isTokenExpired()) {
    signOut();
    return false;
  }
  let token = null;
  authToken.subscribe(value => token = value)();
  return !!token;
}

// Helper function to sign out and clear all auth data
export function signOut() {
  authToken.set(null);
  currentUser.set(null);
  tokenExpiry.set(null);
}

// Set auth token with expiry information
export function setAuthToken(token, expiryTime) {
  authToken.set(token);
  if (expiryTime) {
    tokenExpiry.set(new Date(expiryTime));
  }
}

// Initialize auto-logout check on app mount
if (typeof window !== 'undefined') {
  // Check every 30 seconds if token has expired
  const checkInterval = setInterval(() => {
    if (isTokenExpired()) {
      console.warn('Auth token expired. Signing out.');
      signOut();
      // Redirect to signin if user tries to access protected route
      window.location.href = '/signin';
      clearInterval(checkInterval);
    }
  }, 30000); // Check every 30 seconds
}
