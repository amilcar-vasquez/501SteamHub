<script>
  import SignUp from './pages/SignUp.svelte';
  import SignIn from './pages/SignIn.svelte';
  import Activate from './pages/Activate.svelte';
  import Home from './pages/Home.svelte';
  import SubmitResource from './pages/SubmitResource.svelte';
  import ResourcePage from './pages/ResourcePage.svelte';
  
  let currentPage = 'home'; // home, signup, signin, activate, submit, resource
  let resourceSlug = '';
  
  function navigate(event) {
    currentPage = event.detail.page;
    window.location.hash = event.detail.page;
    window.scrollTo(0, 0);
  }
  
  // Simple hash-based routing
  function handleHashChange() {
    const hash = window.location.hash.slice(1);
    if (hash) {
      // Check if it's a resource route (#resources/:slug)
      if (hash.startsWith('resources/')) {
        currentPage = 'resource';
        resourceSlug = hash.substring('resources/'.length);
      } else {
        currentPage = hash;
      }
    } else {
      currentPage = 'home';
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
  {:else if currentPage === 'signin'}
    <SignIn on:navigate={navigate} />
  {:else if currentPage === 'activate'}
    <Activate on:navigate={navigate} />
  {:else if currentPage === 'submit'}
    <SubmitResource on:navigate={navigate} />
  {:else if currentPage === 'resource'}
    <ResourcePage slug={resourceSlug} />
  {:else}
    <Home on:navigate={navigate} />
  {/if}
</div>

<style>
  .app-root {
    min-height: 100vh;
  }
</style>
