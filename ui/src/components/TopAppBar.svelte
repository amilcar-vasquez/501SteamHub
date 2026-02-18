<script>
  import { createEventDispatcher } from 'svelte';
  import { currentUser, signOut } from '../stores/auth.js';
  
  export let searchQuery = '';
  
  const dispatch = createEventDispatcher();
  
  let isMobile = false;
  let showUserMenu = false;
  
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
  
  function toggleUserMenu() {
    showUserMenu = !showUserMenu;
  }
  
  import { navigateTo } from '../router.js';
  
  function handleSignOut() {
    signOut();
    showUserMenu = false;
    navigateTo('/home');
  }
  
  function handleSignIn() {
    navigateTo('/signin');
  }
  
  function handleSubmitResource() {
    navigateTo('/submit');
  }
  
  // Close menu when clicking outside
  function handleClickOutside(event) {
    if (showUserMenu && !event.target.closest('.user-menu-container')) {
      showUserMenu = false;
    }
  }
  
  if (typeof window !== 'undefined') {
    window.addEventListener('click', handleClickOutside);
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
      {#if $currentUser}
        <button class="submit-resource-button" on:click={handleSubmitResource}>
          <span class="material-symbols-outlined">add_circle</span>
          {#if !isMobile}
            <span>Submit Resource</span>
          {/if}
        </button>
        <button class="icon-button">
          <span class="material-symbols-outlined">notifications</span>
        </button>
        <div class="user-menu-container">
          <button class="avatar-button" on:click={toggleUserMenu}>
            <span class="material-symbols-outlined">account_circle</span>
          </button>
          
          {#if showUserMenu}
            <div class="user-menu">
              <div class="user-menu-header">
                <span class="material-symbols-outlined user-icon">account_circle</span>
                <div class="user-info">
                  <p class="user-name label-large">{$currentUser.username}</p>
                  <p class="user-email body-medium">{$currentUser.email}</p>
                  <p class="user-role label-medium">{$currentUser.role_name || 'User'}</p>
                </div>
              </div>
              <div class="menu-divider"></div>
              <button class="menu-item label-large" on:click={handleSignOut}>
                <span class="material-symbols-outlined">logout</span>
                Sign Out
              </button>
            </div>
          {/if}
        </div>
      {:else}
        <button class="sign-in-button label-large" on:click={handleSignIn}>
          Sign In
        </button>
      {/if}
    </div>
  </div>
</header>

<style>
  .top-app-bar {
    background-color: var(--md-sys-color-primary);
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
    color: var(--md-sys-color-on-primary);
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
    background-color: rgba(255, 255, 255, 0.15);
    border-radius: var(--md-sys-shape-corner-full);
    padding: 0 var(--md-sys-spacing-md);
    height: 48px;
    transition: background-color 0.2s, box-shadow 0.2s;
  }
  
  .search-field:focus-within {
    background-color: rgba(255, 255, 255, 0.25);
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .search-icon {
    color: rgba(255, 255, 255, 0.9);
    margin-right: var(--md-sys-spacing-sm);
  }
  
  .search-input {
    flex: 1;
    border: none;
    background: transparent;
    outline: none;
    color: var(--md-sys-color-on-primary);
  }
  
  .search-input::placeholder {
    color: rgba(255, 255, 255, 0.7);
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
    color: var(--md-sys-color-on-primary);
    transition: background-color 0.2s;
  }
  
  .icon-button:hover {
    background-color: rgba(255, 255, 255, 0.1);
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
    color: var(--md-sys-color-on-primary);
    transition: background-color 0.2s;
  }
  
  .icon-button-small:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }
  
  .icon-button-small .material-symbols-outlined {
    font-size: 20px;
  }
  
  .submit-resource-button {
    display: flex;
    align-items: center;
    gap: 8px;
    background-color: var(--md-sys-color-secondary);
    color: var(--md-sys-color-on-secondary);
    border: none;
    padding: 10px 20px;
    border-radius: var(--md-sys-shape-corner-full);
    cursor: pointer;
    font-size: 16px;
    font-weight: 500;
    transition: all 0.2s;
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .submit-resource-button:hover {
    background-color: rgba(6, 158, 201, 0.85);
    box-shadow: var(--md-sys-elevation-2);
  }
  
  .submit-resource-button .material-symbols-outlined {
    font-size: 24px;
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
    color: var(--md-sys-color-on-primary);
    transition: background-color 0.2s;
  }
  
  .avatar-button:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }
  
  .avatar-button .material-symbols-outlined {
    font-size: 32px;
  }
  
  .user-menu-container {
    position: relative;
  }
  
  .user-menu {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    background-color: var(--md-sys-color-surface);
    border-radius: var(--md-sys-shape-corner-md);
    box-shadow: var(--md-sys-elevation-3);
    min-width: 280px;
    overflow: hidden;
    z-index: 1000;
  }
  
  .user-menu-header {
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-md);
    background-color: var(--md-sys-color-surface-variant);
  }
  
  .user-icon {
    font-size: 48px;
    color: var(--md-sys-color-primary);
  }
  
  .user-info {
    flex: 1;
    min-width: 0;
  }
  
  .user-name {
    color: var(--md-sys-color-on-surface);
    font-weight: 500;
    margin-bottom: 2px;
  }
  
  .user-email {
    color: var(--md-sys-color-on-surface-variant);
    font-size: 12px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  
  .user-role {
    color: var(--md-sys-color-secondary);
    text-transform: capitalize;
    margin-top: 4px;
  }
  
  .menu-divider {
    height: 1px;
    background-color: var(--md-sys-color-outline-variant);
  }
  
  .menu-item {
    width: 100%;
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-md);
    background: none;
    border: none;
    color: var(--md-sys-color-on-surface);
    cursor: pointer;
    transition: background-color 0.2s;
    text-align: left;
  }
  
  .menu-item:hover {
    background-color: rgba(0, 0, 0, 0.05);
  }
  
  .menu-item .material-symbols-outlined {
    font-size: 20px;
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .sign-in-button {
    background-color: rgba(255, 255, 255, 0.15);
    color: var(--md-sys-color-on-primary);
    border: none;
    padding: 8px 16px;
    border-radius: var(--md-sys-shape-corner-full);
    cursor: pointer;
    transition: background-color 0.2s;
  }
  
  .sign-in-button:hover {
    background-color: rgba(255, 255, 255, 0.25);
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
    
    .submit-resource-button {
      padding: 8px 12px;
      font-size: 14px;
      min-width: 48px;
      justify-content: center;
    }
  }
</style>
