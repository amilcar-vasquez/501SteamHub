<script>
  import TextField from '../components/TextField.svelte';
  import Button from '../components/Button.svelte';
  import { userAPI, APIError } from '../api/client.js';
  import { createEventDispatcher } from 'svelte';
  
  const dispatch = createEventDispatcher();
  
  let formData = {
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  };
  
  let errors = {};
  let isLoading = false;
  let successMessage = '';
  
  function validateForm() {
    errors = {};
    
    // Username validation
    if (!formData.username) {
      errors.username = 'Username is required';
    } else if (formData.username.length < 3) {
      errors.username = 'Username must be at least 3 characters';
    } else if (formData.username.length > 50) {
      errors.username = 'Username must not exceed 50 characters';
    }
    
    // Email validation
    if (!formData.email) {
      errors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      errors.email = 'Please enter a valid email address';
    }
    
    // Password validation
    if (!formData.password) {
      errors.password = 'Password is required';
    } else if (formData.password.length < 8) {
      errors.password = 'Password must be at least 8 characters';
    } else if (formData.password.length > 72) {
      errors.password = 'Password must not exceed 72 characters';
    }
    
    // Confirm password validation
    if (!formData.confirmPassword) {
      errors.confirmPassword = 'Please confirm your password';
    } else if (formData.password !== formData.confirmPassword) {
      errors.confirmPassword = 'Passwords do not match';
    }
    
    return Object.keys(errors).length === 0;
  }
  
  async function handleSubmit(e) {
    e.preventDefault();
    successMessage = '';
    
    if (!validateForm()) {
      return;
    }
    
    isLoading = true;
    
    try {
      const response = await userAPI.register(
        formData.username,
        formData.email,
        formData.password
      );
      
      successMessage = 'Registration successful! Please check your email for an activation link.';
      
      // Clear form
      formData = {
        username: '',
        email: '',
        password: '',
        confirmPassword: ''
      };
      
      // Navigate to activation page after 3 seconds
      setTimeout(() => {
        dispatch('navigate', { page: 'activate' });
      }, 3000);
      
    } catch (error) {
      if (error instanceof APIError) {
        if (error.errors) {
          // Map API errors to form fields
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
  
  function handleSignInClick() {
    dispatch('navigate', { page: 'signin' });
  }
</script>

<div class="signup-page">
  <div class="signup-container">
    <div class="signup-card">
      <!-- Header -->
      <div class="signup-header">
        <h1 class="title title-large">Create Your Account</h1>
        <p class="subtitle body-large">Join 501 STEAM Hub to access educational resources</p>
      </div>
      
      <!-- Success Message -->
      {#if successMessage}
        <div class="success-banner">
          <span class="material-symbols-outlined">check_circle</span>
          <div>
            <p class="body-medium">{successMessage}</p>
          </div>
        </div>
      {/if}
      
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
      <form on:submit={handleSubmit} class="signup-form">
        <TextField
          label="Username"
          type="text"
          bind:value={formData.username}
          error={errors.username}
          placeholder="Enter your username"
          required
          disabled={isLoading || successMessage}
        />
        
        <TextField
          label="Email Address"
          type="email"
          bind:value={formData.email}
          error={errors.email}
          placeholder="Enter your email"
          required
          disabled={isLoading || successMessage}
        />
        
        <TextField
          label="Password"
          type="password"
          bind:value={formData.password}
          error={errors.password}
          placeholder="Create a password (min 8 characters)"
          required
          disabled={isLoading || successMessage}
        />
        
        <TextField
          label="Confirm Password"
          type="password"
          bind:value={formData.confirmPassword}
          error={errors.confirmPassword}
          placeholder="Confirm your password"
          required
          disabled={isLoading || successMessage}
        />
        
        <div class="password-requirements body-medium">
          <p class="requirements-title">Password requirements:</p>
          <ul class="requirements-list">
            <li class:valid={formData.password.length >= 8}>At least 8 characters</li>
            <li class:valid={formData.password.length <= 72}>Maximum 72 characters</li>
          </ul>
        </div>
        
        <Button
          type="submit"
          variant="filled"
          color="secondary"
          fullWidth
          disabled={isLoading || successMessage}
          loading={isLoading}
        >
          Sign Up
        </Button>
        
        <div class="divider">
          <span class="divider-text body-medium">Already have an account?</span>
        </div>
        
        <Button
          type="button"
          variant="outlined"
          color="secondary"
          fullWidth
          disabled={isLoading}
          on:click={handleSignInClick}
        >
          Sign In
        </Button>
      </form>
    </div>
    
    <!-- Footer -->
    <div class="signup-footer body-medium">
      <p>By signing up, you agree to our Terms of Service and Privacy Policy</p>
    </div>
  </div>
</div>

<style>
  .signup-page {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #7c3d82 0%, #069ec9 100%);
    padding: var(--md-sys-spacing-lg);
  }
  
  .signup-container {
    width: 100%;
    max-width: 480px;
  }
  
  .signup-card {
    background-color: var(--md-sys-color-surface);
    border-radius: var(--md-sys-shape-corner-lg);
    padding: var(--md-sys-spacing-xl);
    box-shadow: var(--md-sys-elevation-3);
  }
  
  .signup-header {
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
  
  .signup-form {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-lg);
  }
  
  .password-requirements {
    background-color: var(--md-sys-color-surface-variant);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .requirements-title {
    font-weight: 500;
    margin-bottom: var(--md-sys-spacing-xs);
  }
  
  .requirements-list {
    list-style: none;
    padding-left: 0;
    margin: 0;
  }
  
  .requirements-list li {
    padding-left: 24px;
    position: relative;
    margin-bottom: 4px;
  }
  
  .requirements-list li::before {
    content: '○';
    position: absolute;
    left: 0;
    color: var(--md-sys-color-outline);
  }
  
  .requirements-list li.valid::before {
    content: '✓';
    color: var(--md-sys-color-success);
    font-weight: bold;
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
  
  .signup-footer {
    text-align: center;
    color: rgba(255, 255, 255, 0.9);
    margin-top: var(--md-sys-spacing-lg);
  }
  
  .success-banner,
  .error-banner {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-md);
    border-radius: var(--md-sys-shape-corner-sm);
    margin-bottom: var(--md-sys-spacing-lg);
  }
  
  .success-banner {
    background-color: var(--md-sys-color-success-container);
    color: var(--md-sys-color-success);
  }
  
  .error-banner {
    background-color: var(--md-sys-color-error-container);
    color: var(--md-sys-color-error);
  }
  
  .success-banner .material-symbols-outlined,
  .error-banner .material-symbols-outlined {
    font-size: 24px;
  }
  
  @media (max-width: 600px) {
    .signup-page {
      padding: var(--md-sys-spacing-md);
    }
    
    .signup-card {
      padding: var(--md-sys-spacing-lg);
    }
  }
</style>
