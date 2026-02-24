<script>
  export let label = '';
  export let value = '';
  export let error = '';
  export let required = false;
  export let placeholder = '';
  export let helperText = '';
  export let rows = 5;
  export let maxLength = null;
  
  let focused = false;
  let textareaId = `textarea-${Math.random().toString(36).substr(2, 9)}`;
  
  $: characterCount = value.length;
  $: remainingChars = maxLength ? maxLength - characterCount : null;
</script>

<div class="textarea-field" class:filled={value} class:focused class:error>
  <textarea
    id={textareaId}
    bind:value
    on:focus={() => focused = true}
    on:blur={() => focused = false}
    {required}
    {placeholder}
    {rows}
    maxlength={maxLength}
  ></textarea>
  <label for={textareaId}>
    {label}{required ? ' *' : ''}
  </label>
  
  <div class="footer">
    <div class="left">
      {#if error}
        <div class="error-text">
          <span class="material-symbols-outlined">error</span>
          {error}
        </div>
      {:else if helperText}
        <div class="helper-text">{helperText}</div>
      {/if}
    </div>
    {#if maxLength}
      <div class="char-count" class:warning={remainingChars < 50}>
        {characterCount}/{maxLength}
      </div>
    {/if}
  </div>
</div>

<style>
  .textarea-field {
    position: relative;
    margin-bottom: var(--md-sys-spacing-lg);
  }

  textarea {
    width: 100%;
    min-height: 120px; /* Larger for fellows */
    padding: 28px 16px 12px;
    font-size: 18px; /* Bigger font */
    font-family: var(--md-sys-typescale-body-large-font);
    line-height: 1.5;
    color: var(--md-sys-color-on-surface);
    background-color: var(--md-sys-color-surface-variant);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    outline: none;
    transition: all 0.2s;
    resize: vertical;
  }

  textarea:hover {
    background-color: rgba(124, 61, 130, 0.08);
    border-color: var(--md-sys-color-on-surface);
  }

  .focused textarea,
  textarea:focus {
    background-color: rgba(124, 61, 130, 0.12);
    border-color: var(--md-sys-color-primary);
    border-width: 2px;
    padding: 27px 15px 11px 15px;
  }

  label {
    position: absolute;
    left: 16px;
    top: 8px;
    font-size: 12px;
    font-weight: 500;
    color: var(--md-sys-color-on-surface-variant);
    transition: all 0.2s;
    pointer-events: none;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .focused label,
  .filled label {
    color: var(--md-sys-color-primary);
  }

  .error textarea {
    border-color: var(--md-sys-color-error);
    background-color: rgba(179, 38, 30, 0.05);
  }

  .error label {
    color: var(--md-sys-color-error);
  }

  .footer {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-top: 4px;
    min-height: 20px;
  }

  .left {
    flex: 1;
  }

  .error-text {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    color: var(--md-sys-color-error);
  }

  .error-text .material-symbols-outlined {
    font-size: 16px;
  }

  .helper-text {
    font-size: 12px;
    color: var(--md-sys-color-on-surface-variant);
  }

  .char-count {
    font-size: 12px;
    color: var(--md-sys-color-on-surface-variant);
    white-space: nowrap;
    margin-left: 8px;
  }

  .char-count.warning {
    color: var(--md-sys-color-tertiary);
    font-weight: 500;
  }

  textarea::placeholder {
    color: var(--md-sys-color-on-surface-variant);
    opacity: 0.6;
  }
</style>
