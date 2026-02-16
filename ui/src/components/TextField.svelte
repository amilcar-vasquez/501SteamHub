<script>
  export let label = '';
  export let type = 'text';
  export let value = '';
  export let error = '';
  export let placeholder = '';
  export let required = false;
  export let disabled = false;
  export let id = '';
  
  $: inputId = id || label.toLowerCase().replace(/\s+/g, '-');
</script>

<div class="text-field">
  {#if label}
    <label for={inputId} class="label body-medium">
      {label}
      {#if required}
        <span class="required">*</span>
      {/if}
    </label>
  {/if}
  
  <div class="input-container" class:error={error} class:disabled>
    {#if type === 'password'}
      <input
        {id}
        type="password"
        {placeholder}
        {required}
        {disabled}
        bind:value
        on:input
        on:blur
        on:focus
        class="input body-large"
        aria-invalid={error ? 'true' : 'false'}
        aria-describedby={error ? `${inputId}-error` : undefined}
      />
    {:else if type === 'email'}
      <input
        {id}
        type="email"
        {placeholder}
        {required}
        {disabled}
        bind:value
        on:input
        on:blur
        on:focus
        class="input body-large"
        aria-invalid={error ? 'true' : 'false'}
        aria-describedby={error ? `${inputId}-error` : undefined}
      />
    {:else}
      <input
        {id}
        type="text"
        {placeholder}
        {required}
        {disabled}
        bind:value
        on:input
        on:blur
        on:focus
        class="input body-large"
        aria-invalid={error ? 'true' : 'false'}
        aria-describedby={error ? `${inputId}-error` : undefined}
      />
    {/if}
  </div>
  
  {#if error}
    <span id="{inputId}-error" class="error-message label-medium">
      {error}
    </span>
  {/if}
</div>

<style>
  .text-field {
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-xs);
    width: 100%;
  }
  
  .label {
    color: var(--md-sys-color-on-surface);
    display: block;
  }
  
  .required {
    color: var(--md-sys-color-error);
  }
  
  .input-container {
    position: relative;
    display: flex;
    align-items: center;
    background-color: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    transition: border-color 0.2s, background-color 0.2s;
  }
  
  .input-container:hover:not(.disabled):not(.error) {
    border-color: var(--md-sys-color-on-surface);
  }
  
  .input-container:focus-within:not(.disabled):not(.error) {
    border-color: var(--md-sys-color-primary);
    border-width: 2px;
  }
  
  .input-container:focus-within:not(.disabled):not(.error) .input {
    padding: 15px;
  }
  
  .input-container.error {
    border-color: var(--md-sys-color-error);
  }
  
  .input-container.disabled {
    background-color: var(--md-sys-color-surface-variant);
    opacity: 0.6;
  }
  
  .input {
    flex: 1;
    padding: 16px;
    border: none;
    background: transparent;
    outline: none;
    color: var(--md-sys-color-on-surface);
    width: 100%;
  }
  
  .input::placeholder {
    color: var(--md-sys-color-on-surface-variant);
  }
  
  .input:disabled {
    cursor: not-allowed;
  }
  
  .error-message {
    color: var(--md-sys-color-error);
    display: flex;
    align-items: center;
    gap: var(--md-sys-spacing-xs);
  }
</style>
