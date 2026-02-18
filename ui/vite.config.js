import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [svelte()],
  server: {
    port: 3000,
  },
  // SPA mode is the default - Vite serves index.html for all non-file routes
  appType: 'spa',
});
