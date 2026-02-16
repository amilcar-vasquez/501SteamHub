<script>
  import TextField from '../components/TextField.svelte';
  import Button from '../components/Button.svelte';
  import { userAPI, APIError } from '../api/client.js';
  import { createEventDispatcher } from 'svelte';
  
  const dispatch = createEventDispatcher();
  
  let token = '';
  let error = '';
  let isLoading = false;
  let isSuccess = false;
  
  async function handleSubmit(e) {
    e.preventDefault();
    error = '';
    
    if (!token.trim()) {
      error = 'Please enter your activation token';
      return;
    }
    
    isLoading = true;
    
    try {
      await userAPI.activate(token);
      isSuccess = true;
      
      // Navigate to sign in page after 3 seconds
      setTimeout(() => {
        dispatch('navigate', { page: 'signin' });
      }, 3000);
      
    } catch (err) {
      if (err instanceof APIError) {
        if (err.errors && err.errors.token) {
          error = err.errors.token;
        } else {
          error = err.message;
        }
      } else {
        error = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      isLoading = false;
    }
  }
  
  function handleSignUpClick() {
    dispatch('navigate', { page: 'signup' });
  }
  
  function handleSignInClick() {
    dispatch('navigate', { page: 'signin' });
  }
</script>

<div class="activation-page">
  <div class="activation-container">
    <div class="activation-card">
      {#if isSuccess}
        <!-- Success State -->
        <div class="success-state">
          <span class="material-symbols-outlined success-icon">check_circle</span>
          <h1 class="title-large">Account Activated!</h1>
          <p class="body-large">
            Your account has been successfully activated. 
            You'll be redirected to sign in shortly.
          </p>
          <Button
            variant="filled"
            color="secondary"
            fullWidth
            on:click={handleSignInClick}
          >
            Sign In Now
          </Button>
        </div>
      {:else}
        <!-- Activation Form -->
        <div class="activation-header">
          <span class="material-symbols-outlined header-icon">mail</span>
          <h1 class="title title-large">Activate Your Account</h1>
          <p class="subtitle body-large">
            Enter the activation token from your email to activate your account
          </p>
        </div>
        
        {#if error}
          <div class="error-banner">
            <span class="material-symbols-outlined">error</span>
            <div>
              <p class="body-medium">{error}</p>
            </div>
          </div>
        {/if}
        
        <form on:submit={handleSubmit} class="activation-form">
          <TextField
            label="Activation Token"
            type="text"
            bind:value={token}
            placeholder="Enter your activation token"
            required
            disabled={isLoading}
          />
          
          <div class="info-box body-medium">
            <span class="material-symbols-outlined">info</span>
            <p>
              Check your email inbox for the activation token. 
              The token is valid for 24 hours after registration.
            </p>
          </div>
          
          <Button
            type="submit"
            variant="filled"
            color="secondary"
            fullWidth
            disabled={isLoading}
            loading={isLoading}
          >
            Activate Account
          </Button>
          
          <div class="divider">
            <span class="divider-text body-medium">Need help?</span>
          </div>
          
          <div class="action-links">
            <Button
              type="button"
              variant="text"
              color="secondary"
              on:click={handleSignUpClick}
            >
              Create New Account
            </Button>
            <Button
              type="button"
              variant="text"
              color="secondary"
              on:click={handleSignInClick}
            >
              Sign In
            </Button>
          </div>
        </form>
      {/if}
    </div>
    
    <div class="activation-footer body-medium">
      <p>Having trouble? Contact support@501steamhub.org</p>
    </div>
  </div>
</div>

<style>
  .activation-page {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #7c3d82 0%, #069ec9 100%);
    padding: var(--md-sys-spacing-lg);
  }
  
  .activation-container {
    width: 100%;
    max-width: 480px;
  }
  
  .activation-card {
    background-color: var(--md-sys-color-surface);
    border-radius: var(--md-sys-shape-corner-lg);
    padding: var(--md-sys-spacing-xl);
    box-shadow: var(--md-sys-elevation-3);
  }
  
  .activation-header {
    text-align: center;
    margin-bottom: var(--md-sys-spacing-xl);
  }
  
  .header-icon {
    font-size: 64px;
    color: var(--md-sys-color-secondary);
    margin-bottom: var(--md-sys-spacing-md);
  }
  
  .title {
    color: var(--md-sys-color-on-surface);
    margin-bottom: var(--md-sys-spacing-sm);
  }
  
  .subtitle {
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .activation-form {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-lg);
  }
  
  .info-box {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    background-color: var(--md-sys-color-secondary-container);
    color: var(--md-sys-color-on-secondary-container);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
  }
  
  .info-box .material-symbols-outlined {
    font-size: 24px;
    flex-shrink: 0;
  }
  
  .error-banner {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
    margin-bottom: var(--md-sys-spacing-lg);
    background-color: var(--md-sys-color-error-container);
    color: var(--md-sys-color-error);
  }
  
  .error-banner .material-symbols-outlined {
    font-size: 24px;
  }
  
  .divider {
    display: flex;
    align-items: center;
    text-align: center;
    margin: var(--md-sys-spacing-sm) 0;
  }
  
  .divider::before,
  .divider::after {
    content: '';
    flex: 1;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
  }
  
  .divider-text {
    padding: 0 var(--md-sys-spacing-md);
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .action-links {
    display: flex;
    justify-content: center;
    gap: var(--md-sys-spacing-md);
    flex-wrap: wrap;
  }
  
  .activation-footer {
    text-align: center;
    color: rgba(255, 255, 255, 0.9);
    margin-top: var(--md-sys-spacing-lg);
  }
  
  /* Success State */
  .success-state {
    text-align: center;
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-lg);
    align-items: center;
  }
  
  .success-icon {
    font-size: 80px;
    color: var(--md-sys-color-success);
  }
  
  .success-state h1 {
    color: var(--md-sys-color-on-surface);
  }
  
  .success-state p {
    color: var(--md-sys-color-on-surface-variant);
  }
  
  @media (max-width: 600px) {
    .activation-page {
      padding: var(--md-sys-spacing-md);
    }
    
    .activation-card {
      padding: var(--md-sys-spacing-lg);
    }
    
    .action-links {
      flex-direction: column;
      width: 100%;
    }
  }
</style>
