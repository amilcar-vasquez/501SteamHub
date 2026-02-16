<script>
  import { createEventDispatcher } from 'svelte';
  
  export let searchQuery = '';
  
  const dispatch = createEventDispatcher();
  
  let isMobile = false;
  
  function checkMobile() {
    isMobile = window.innerWidth < 1024;
  }
  
  if (typeof window !== 'undefined') {
    checkMobile();
    window.addEventListener('resize', checkMobile);
  }
  
  function handleSearch(e) {
    searchQuery = e.target.value;
  }
</script>

<header class="top-app-bar">
  <div class="app-bar-content">
    <!-- Left: Logo and menu button -->
    <div class="app-bar-left">
      {#if isMobile}
        <button class="icon-button" on:click={() => dispatch('toggleFilter')}>
          <span class="material-symbols-outlined">menu</span>
        </button>
      {/if}
      <h1 class="app-title title-large">501 STEAM Hub</h1>
    </div>
    
    <!-- Center: Search -->
    <div class="app-bar-center">
      <div class="search-field">
        <span class="material-symbols-outlined search-icon">search</span>
        <input 
          type="text" 
          placeholder="Search resources, topics, or contributors..." 
          bind:value={searchQuery}
          on:input={handleSearch}
          class="search-input body-large"
        />
        {#if searchQuery}
          <button class="icon-button-small" on:click={() => searchQuery = ''}>
            <span class="material-symbols-outlined">close</span>
          </button>
        {/if}
      </div>
    </div>
    
    <!-- Right: User avatar -->
    <div class="app-bar-right">
      <button class="icon-button">
        <span class="material-symbols-outlined">notifications</span>
      </button>
      <button class="avatar-button">
        <span class="material-symbols-outlined">account_circle</span>
      </button>
    </div>
  </div>
</header>

<style>
  .top-app-bar {
    background-color: var(--md-sys-color-surface);
    box-shadow: var(--md-sys-elevation-2);
    position: sticky;
    top: 0;
    z-index: 100;
    height: 64px;
  }
  
  .app-bar-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 100%;
    padding: 0 var(--md-sys-spacing-md);
    max-width: 1920px;
    margin: 0 auto;
  }
  
  .app-bar-left {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    min-width: 200px;
  }
  
  .app-title {
    color: var(--md-sys-color-primary);
    white-space: nowrap;
    user-select: none;
  }
  
  .app-bar-center {
    flex: 1;
    max-width: 720px;
    padding: 0 var(--md-sys-spacing-lg);
  }
  
  .search-field {
    display: flex;
    align-items: center;
    background-color: var(--md-sys-color-surface-container-high);
    border-radius: var(--md-sys-shape-corner-full);
    padding: 0 var(--md-sys-spacing-md);
    height: 48px;
    transition: background-color 0.2s, box-shadow 0.2s;
  }
  
  .search-field:focus-within {
    background-color: var(--md-sys-color-surface-container-highest);
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .search-icon {
    color: var(--md-sys-color-on-surface-variant);
    margin-right: var(--md-sys-spacing-sm);
  }
  
  .search-input {
    flex: 1;
    border: none;
    background: transparent;
    outline: none;
    color: var(--md-sys-color-on-surface);
  }
  
  .search-input::placeholder {
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .app-bar-right {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-sm);
    min-width: 120px;
    justify-content: flex-end;
  }
  
  .icon-button {
    background: none;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: var(--md-sys-shape-corner-full);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--md-sys-color-on-surface-variant);
    transition: background-color 0.2s;
  }
  
  .icon-button:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  .icon-button-small {
    background: none;
    border: none;
    width: 32px;
    height: 32px;
    border-radius: var(--md-sys-shape-corner-full);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--md-sys-color-on-surface-variant);
    transition: background-color 0.2s;
  }
  
  .icon-button-small:hover {
    background-color: rgba(0, 0, 0, var(--md-sys-state-hover-opacity));
  }
  
  .icon-button-small .material-symbols-outlined {
    font-size: 20px;
  }
  
  .avatar-button {
    background: none;
    border: none;
    width: 40px;
    height: 40px;
    border-radius: var(--md-sys-shape-corner-full);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    color: var(--md-sys-color-primary);
    transition: background-color 0.2s;
  }
  
  .avatar-button:hover {
    background-color: rgba(124, 61, 130, var(--md-sys-state-hover-opacity));
  }
  
  .avatar-button .material-symbols-outlined {
    font-size: 32px;
  }
  
  /* Tablet and Mobile */
  @media (max-width: 1024px) {
    .app-bar-content {
      padding: 0 var(--md-sys-spacing-sm);
    }
    
    .app-bar-center {
      padding: 0 var(--md-sys-spacing-md);
    }
    
    .app-title {
      font-size: 18px;
    }
  }
  
  @media (max-width: 600px) {
    .app-bar-left {
      min-width: auto;
    }
    
    .app-bar-center {
      padding: 0 var(--md-sys-spacing-sm);
    }
    
    .app-title {
      font-size: 16px;
    }
    
    .search-input {
      font-size: 14px;
    }
    
    .search-input::placeholder {
      font-size: 14px;
    }
  }
</style>
