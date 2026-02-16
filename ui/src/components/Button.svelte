<script>
  export let variant = 'filled'; // filled, outlined, text
  export let color = 'primary'; // primary, secondary
  export let type = 'button';
  export let disabled = false;
  export let fullWidth = false;
  export let loading = false;
</script>

<button
  {type}
  {disabled}
  on:click
  class="button label-large"
  class:filled={variant === 'filled'}
  class:outlined={variant === 'outlined'}
  class:text={variant === 'text'}
  class:primary={color === 'primary'}
  class:secondary={color === 'secondary'}
  class:full-width={fullWidth}
  class:loading
>
  {#if loading}
    <span class="loader"></span>
  {:else}
    <slot />
  {/if}
</button>

<style>
  .button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: var(--md-sys-spacing-sm);
    padding: 10px 24px;
    border-radius: var(--md-sys-shape-corner-full);
    border: none;
    cursor: pointer;
    transition: background-color 0.2s, box-shadow 0.2s, transform 0.1s;
    min-height: 40px;
    position: relative;
  }
  
  .button:disabled {
    cursor: not-allowed;
    opacity: 0.38;
  }
  
  .button:active:not(:disabled) {
    transform: scale(0.98);
  }
  
  .button.full-width {
    width: 100%;
  }
  
  /* Filled variant */
  .button.filled.primary {
    background-color: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .button.filled.primary:hover:not(:disabled) {
    box-shadow: var(--md-sys-elevation-2);
    background-color: #8a4590;
  }
  
  .button.filled.secondary {
    background-color: var(--md-sys-color-secondary);
    color: var(--md-sys-color-on-secondary);
    box-shadow: var(--md-sys-elevation-1);
  }
  
  .button.filled.secondary:hover:not(:disabled) {
    box-shadow: var(--md-sys-elevation-2);
    background-color: #07b0df;
  }
  
  /* Outlined variant */
  .button.outlined.primary {
    background-color: transparent;
    color: var(--md-sys-color-primary);
    border: 1px solid var(--md-sys-color-outline);
  }
  
  .button.outlined.primary:hover:not(:disabled) {
    background-color: rgba(124, 61, 130, 0.08);
    border-color: var(--md-sys-color-primary);
  }
  
  .button.outlined.secondary {
    background-color: transparent;
    color: var(--md-sys-color-secondary);
    border: 1px solid var(--md-sys-color-outline);
  }
  
  .button.outlined.secondary:hover:not(:disabled) {
    background-color: rgba(6, 158, 201, 0.08);
    border-color: var(--md-sys-color-secondary);
  }
  
  /* Text variant */
  .button.text.primary {
    background-color: transparent;
    color: var(--md-sys-color-primary);
    padding: 10px 12px;
  }
  
  .button.text.primary:hover:not(:disabled) {
    background-color: rgba(124, 61, 130, 0.08);
  }
  
  .button.text.secondary {
    background-color: transparent;
    color: var(--md-sys-color-secondary);
    padding: 10px 12px;
  }
  
  .button.text.secondary:hover:not(:disabled) {
    background-color: rgba(6, 158, 201, 0.08);
  }
  
  /* Loading state */
  .loader {
    width: 16px;
    height: 16px;
    border: 2px solid currentColor;
    border-radius: 50%;
    border-top-color: transparent;
    animation: spin 0.8s linear infinite;
  }
  
  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }
</style>
