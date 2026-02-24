<script>
  export let label = '';
  export let value = '';
  export let options = []; // Array of {value, label} objects
  export let error = '';
  export let required = false;
  export let helperText = '';
  
  let focused = false;
  let selectId = `select-${Math.random().toString(36).substr(2, 9)}`;
</script>

<div class="select-field" class:filled={value} class:focused class:error>
  <select
    id={selectId}
    bind:value
    on:focus={() => focused = true}
    on:blur={() => focused = false}
    {required}
  >
    <option value="" disabled selected>Choose {label.toLowerCase()}</option>
    {#each options as option}
      <option value={option.value}>{option.label}</option>
    {/each}
  </select>
  <label for={selectId}>
    {label}{required ? ' *' : ''}
  </label>
  
  {#if error}
    <div class="error-text">
      <span class="material-symbols-outlined">error</span>
      {error}
    </div>
  {:else if helperText}
    <div class="helper-text">{helperText}</div>
  {/if}
</div>

<style>
  .select-field {
    position: relative;
    margin-bottom: var(--md-sys-spacing-lg);
  }

  select {
    width: 100%;
    height: 64px; /* Larger for fellows */
    padding: 24px 16px 8px;
    font-size: 18px; /* Bigger font */
    font-family: var(--md-sys-typescale-body-large-font);
    color: var(--md-sys-color-on-surface);
    background-color: var(--md-sys-color-surface-variant);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    outline: none;
    transition: all 0.2s;
    cursor: pointer;
    appearance: none;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24'%3E%3Cpath fill='%23666' d='M7 10l5 5 5-5z'/%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 12px center;
    padding-right: 48px;
  }

  select:hover {
    background-color: rgba(124, 61, 130, 0.08);
    border-color: var(--md-sys-color-on-surface);
  }

  .focused select,
  select:focus {
    background-color: rgba(124, 61, 130, 0.12);
    border-color: var(--md-sys-color-primary);
    border-width: 2px;
    padding: 23px 15px 7px 15px;
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

  .error select {
    border-color: var(--md-sys-color-error);
    background-color: rgba(179, 38, 30, 0.05);
  }

  .error label {
    color: var(--md-sys-color-error);
  }

  .error-text {
    display: flex;
    align-items: center;
    gap: 4px;
    margin-top: 4px;
    font-size: 12px;
    color: var(--md-sys-color-error);
  }

  .error-text .material-symbols-outlined {
    font-size: 16px;
  }

  .helper-text {
    margin-top: 4px;
    font-size: 12px;
    color: var(--md-sys-color-on-surface-variant);
  }

  option {
    font-size: 16px;
    padding: 12px;
  }
</style>
