<script>
  import TextField from '../components/TextField.svelte';
  import Button from '../components/Button.svelte';
  import { tokenAPI, APIError } from '../api/client.js';
  import { authToken, currentUser } from '../stores/auth.js';
  import { createEventDispatcher } from 'svelte';
  
  const dispatch = createEventDispatcher();
  
  let formData = {
    email: '',
    password: ''
  };
  
  let errors = {};
  let isLoading = false;
  
  function validateForm() {
    errors = {};
    
    // Email validation
    if (!formData.email) {
      errors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      errors.email = 'Please enter a valid email address';
    }
    
    // Password validation
    if (!formData.password) {
      errors.password = 'Password is required';
    }
    
    return Object.keys(errors).length === 0;
  }
  
  async function handleSubmit(e) {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }
    
    isLoading = true;
    errors = {};
    
    try {
      const response = await tokenAPI.authenticate(
        formData.email,
        formData.password
      );
      
      // Store authentication token and user data
      authToken.set(response.token.plaintext);
      currentUser.set(response.user);
      
      // Navigate to home
      dispatch('navigate', { page: 'home' });
      
    } catch (error) {
      if (error instanceof APIError) {
        if (error.status === 401) {
          errors.general = 'Invalid email or password';
        } else if (error.status === 403) {
          errors.general = 'Your account is not activated. Please check your email for the activation link.';
        } else if (error.errors) {
          errors = error.errors;
        } else {
          errors.general = error.message;
        }
      } else {
        errors.general = 'An unexpected error occurred. Please try again.';
      }
    } finally {
      isLoading = false;
    }
  }
  
  function handleSignUpClick() {
    dispatch('navigate', { page: 'signup' });
  }
  
  function handleActivateClick() {
    dispatch('navigate', { page: 'activate' });
  }
  
  function handleForgotPasswordClick() {
    // TODO: Implement forgot password flow
    console.log('Forgot password clicked');
  }
</script>

<div class="signin-page">
  <div class="signin-container">
    <div class="signin-card">
      <!-- Header -->
      <div class="signin-header">
        <h1 class="title title-large">Welcome Back</h1>
        <p class="subtitle body-large">Sign in to access your account</p>
      </div>
      
      <!-- General Error -->
      {#if errors.general}
        <div class="error-banner">
          <span class="material-symbols-outlined">error</span>
          <div>
            <p class="body-medium">{errors.general}</p>
          </div>
        </div>
      {/if}
      
      <!-- Form -->
      <form on:submit={handleSubmit} class="signin-form">
        <TextField
          label="Email Address"
          type="email"
          bind:value={formData.email}
          error={errors.email}
          placeholder="Enter your email"
          required
          disabled={isLoading}
        />
        
        <TextField
          label="Password"
          type="password"
          bind:value={formData.password}
          error={errors.password}
          placeholder="Enter your password"
          required
          disabled={isLoading}
        />
        
        <div class="form-actions">
          <button
            type="button"
            class="forgot-password-link label-medium"
            on:click={handleForgotPasswordClick}
          >
            Forgot password?
          </button>
        </div>
        
        <Button
          type="submit"
          variant="filled"
          color="secondary"
          fullWidth
          disabled={isLoading}
          loading={isLoading}
        >
          Sign In
        </Button>
        
        <div class="divider">
          <span class="divider-text body-medium">Don't have an account?</span>
        </div>
        
        <Button
          type="button"
          variant="outlined"
          color="secondary"
          fullWidth
          disabled={isLoading}
          on:click={handleSignUpClick}
        >
          Create Account
        </Button>
        
        <div class="helper-links">
          <button
            type="button"
            class="helper-link label-medium"
            on:click={handleActivateClick}
          >
            Need to activate your account?
          </button>
        </div>
      </form>
    </div>
    
    <!-- Footer -->
    <div class="signin-footer body-medium">
      <p>501 STEAM Hub - Educational Resources Platform</p>
    </div>
  </div>
</div>

<style>
  .signin-page {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #7c3d82 0%, #069ec9 100%);
    padding: var(--md-sys-spacing-lg);
  }
  
  .signin-container {
    width: 100%;
    max-width: 480px;
  }
  
  .signin-card {
    background-color: var(--md-sys-color-surface);
    border-radius: var(--md-sys-shape-corner-lg);
    padding: var(--md-sys-spacing-xl);
    box-shadow: var(--md-sys-elevation-3);
  }
  
  .signin-header {
    text-align: center;
    margin-bottom: var(--md-sys-spacing-xl);
  }
  
  .title {
    color: var(--md-sys-color-on-surface);
    margin-bottom: var(--md-sys-spacing-sm);
  }
  
  .subtitle {
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .signin-form {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-lg);
  }
  
  .form-actions {
    display: flex;
    justify-content: flex-end;
    margin-top: calc(var(--md-sys-spacing-sm) * -1);
  }
  
  .forgot-password-link {
    background: none;
    border: none;
    color: var(--md-sys-color-secondary);
    cursor: pointer;
    padding: var(--md-sys-spacing-xs) var(--md-sys-spacing-sm);
    border-radius: var(--md-sys-shape-corner-sm);
    transition: background-color 0.2s;
  }
  
  .forgot-password-link:hover {
    background-color: rgba(6, 158, 201, 0.08);
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
  
  .helper-links {
    display: flex;
    justify-content: center;
    margin-top: var(--md-sys-spacing-sm);
  }
  
  .helper-link {
    background: none;
    border: none;
    color: var(--md-sys-color-on-surface-variant);
    cursor: pointer;
    padding: var(--md-sys-spacing-xs) var(--md-sys-spacing-sm);
    border-radius: var(--md-sys-shape-corner-sm);
    transition: background-color 0.2s, color 0.2s;
  }
  
  .helper-link:hover {
    background-color: rgba(0, 0, 0, 0.05);
    color: var(--md-sys-color-secondary);
  }
  
  .signin-footer {
    text-align: center;
    color: rgba(255, 255, 255, 0.9);
    margin-top: var(--md-sys-spacing-lg);
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
  
  @media (max-width: 600px) {
    .signin-page {
      padding: var(--md-sys-spacing-md);
    }
    
    .signin-card {
      padding: var(--md-sys-spacing-lg);
    }
  }
</style>
