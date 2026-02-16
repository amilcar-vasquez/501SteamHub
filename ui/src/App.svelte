<script>
  import SignUp from './pages/SignUp.svelte';
  import SignIn from './pages/SignIn.svelte';
  import Activate from './pages/Activate.svelte';
  import Home from './pages/Home.svelte';
  import SubmitResource from './pages/SubmitResource.svelte';
  
  let currentPage = 'home'; // home, signup, signin, activate, submit
  
  function navigate(event) {
    currentPage = event.detail.page;
    window.location.hash = event.detail.page;
    window.scrollTo(0, 0);
  }
  
  // Simple hash-based routing
  function handleHashChange() {
    const hash = window.location.hash.slice(1);
    if (hash) {
      currentPage = hash;
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
  {:else}
    <Home on:navigate={navigate} />
  {/if}
</div>

<style>
  .app-root {
    min-height: 100vh;
  }
</style>
