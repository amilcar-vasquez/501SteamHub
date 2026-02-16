<script>
  import SignUp from './pages/SignUp.svelte';
  import Activate from './pages/Activate.svelte';
  import Home from './pages/Home.svelte';
  
  let currentPage = 'home'; // home, signup, activate, signin
  
  function navigate(event) {
    currentPage = event.detail.page;
    window.scrollTo(0, 0);
  }
  
  // Simple hash-based routing
  function handleHashChange() {
    const hash = window.location.hash.slice(1);
    if (hash) {
      currentPage = hash;
    }
  }
  
  if (typeof window !== 'undefined') {
    window.addEventListener('hashchange', handleHashChange);
    handleHashChange();
  }
</script>

<div class="app-root">
  {#if currentPage === 'signup'}
    <SignUp on:navigate={navigate} />
  {:else if currentPage === 'activate'}
    <Activate on:navigate={navigate} />
  {:else}
    <Home on:navigate={navigate} />
  {/if}
</div>

<style>
  .app-root {
    min-height: 100vh;
  }
</style>
