<script>
  import SignUp from './pages/SignUp.svelte';
  import SignIn from './pages/SignIn.svelte';
  import Activate from './pages/Activate.svelte';
  import Home from './pages/Home.svelte';
  import SubmitResource from './pages/SubmitResource.svelte';
  import ResourcePage from './pages/ResourcePage.svelte';
  import { currentRoute, navigateTo, handleRouteChange } from './router.js';
  
  function navigate(event) {
    navigateTo(event.detail.page);
    window.scrollTo(0, 0);
  }
  
  // Initialize route on first load
  if (typeof window !== 'undefined') {
    handleRouteChange();
  }
  
  $: currentPage = $currentRoute.page;
  $: resourceSlug = $currentRoute.params.slug || '';
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
