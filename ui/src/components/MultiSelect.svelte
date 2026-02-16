<script>
  export let label = '';
  export let value = []; // Array of selected values
  export let options = []; // Array of {value, label} objects
  export let error = '';
  export let required = false;
  export let helperText = '';
  export let placeholder = 'Select options...';
  export let disabled = false;

  let isOpen = false;
  let searchQuery = '';

  $: filteredOptions = options.filter(opt => 
    opt.label.toLowerCase().includes(searchQuery.toLowerCase())
  );

  $: selectedLabels = value.map(val => {
    const option = options.find(opt => opt.value === val);
    return option ? option.label : val;
  });

  function toggleOption(optionValue) {
    if (value.includes(optionValue)) {
      value = value.filter(v => v !== optionValue);
    } else {
      value = [...value, optionValue];
    }
  }

  function removeChip(optionValue) {
    value = value.filter(v => v !== optionValue);
  }

  function handleClickOutside(event) {
    if (!event.target.closest('.multiselect-container')) {
      isOpen = false;
      searchQuery = '';
    }
  }
</script>

<svelte:window on:click={handleClickOutside} />

<div class="multiselect-container" class:error class:disabled>
  {#if label}
    <label class="label">
      {label}
      {#if required}<span class="required">*</span>{/if}
    </label>
  {/if}

  <div class="multiselect" on:click|stopPropagation={() => !disabled && (isOpen = !isOpen)}>
    <div class="selected-items">
      {#if value.length === 0}
        <span class="placeholder">{placeholder}</span>
      {:else}
        <div class="chips">
          {#each value as val}
            {@const option = options.find(opt => opt.value === val)}
            <div class="chip">
              <span>{option?.label || val}</span>
              <button 
                type="button"
                class="chip-remove" 
                on:click|stopPropagation={() => !disabled && removeChip(val)}
                disabled={disabled}
              >
                <span class="material-symbols-outlined">close</span>
              </button>
            </div>
          {/each}
        </div>
      {/if}
    </div>
    <span class="material-symbols-outlined dropdown-icon" class:open={isOpen}>
      expand_more
    </span>
  </div>

  {#if isOpen && !disabled}
    <div class="dropdown" on:click|stopPropagation>
      <div class="search-box">
        <span class="material-symbols-outlined">search</span>
        <input 
          type="text" 
          bind:value={searchQuery}
          placeholder="Search..."
          on:click|stopPropagation
        />
      </div>
      <div class="options">
        {#each filteredOptions as option}
          <div 
            class="option" 
            class:selected={value.includes(option.value)}
            on:click={() => toggleOption(option.value)}
          >
            <div class="checkbox">
              {#if value.includes(option.value)}
                <span class="material-symbols-outlined">check_box</span>
              {:else}
                <span class="material-symbols-outlined">check_box_outline_blank</span>
              {/if}
            </div>
            <span>{option.label}</span>
          </div>
        {:else}
          <div class="no-options">No options found</div>
        {/each}
      </div>
    </div>
  {/if}

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
  .multiselect-container {
    position: relative;
    width: 100%;
    margin-bottom: 1rem;
  }

  .label {
    display: block;
    font-size: 0.875rem;
    font-weight: 500;
    color: var(--md-sys-color-on-surface);
    margin-bottom: 0.5rem;
  }

  .required {
    color: var(--md-sys-color-error);
    margin-left: 0.25rem;
  }

  .multiselect {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    min-height: 56px;
    padding: 0.5rem 1rem;
    background: var(--md-sys-color-surface-container-high);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
  }

  .multiselect:hover {
    border-color: var(--md-sys-color-on-surface);
  }

  .multiselect:focus-within {
    border-color: var(--md-sys-color-primary);
    outline: 2px solid rgba(var(--md-sys-color-primary-rgb), 0.12);
  }

  .disabled .multiselect {
    background: var(--md-sys-color-surface-variant);
    opacity: 0.6;
    cursor: not-allowed;
  }

  .error .multiselect {
    border-color: var(--md-sys-color-error);
  }

  .selected-items {
    flex: 1;
    min-height: 40px;
    display: flex;
    align-items: center;
  }

  .placeholder {
    color: var(--md-sys-color-on-surface-variant);
    font-size: 0.875rem;
  }

  .chips {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .chip {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    padding: 0.25rem 0.5rem;
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border-radius: 8px;
    font-size: 0.875rem;
  }

  .chip-remove {
    display: flex;
    align-items: center;
    justify-content: center;
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
    color: inherit;
  }

  .chip-remove .material-symbols-outlined {
    font-size: 16px;
  }

  .chip-remove:hover {
    opacity: 0.7;
  }

  .dropdown-icon {
    transition: transform 0.2s;
    color: var(--md-sys-color-on-surface-variant);
  }

  .dropdown-icon.open {
    transform: rotate(180deg);
  }

  .dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    margin-top: 0.25rem;
    background: var(--md-sys-color-surface-container);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 8px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    z-index: 1000;
    max-height: 300px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  .search-box {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
  }

  .search-box input {
    flex: 1;
    border: none;
    background: transparent;
    outline: none;
    font-size: 0.875rem;
    color: var(--md-sys-color-on-surface);
  }

  .search-box .material-symbols-outlined {
    font-size: 20px;
    color: var(--md-sys-color-on-surface-variant);
  }

  .options {
    overflow-y: auto;
    max-height: 240px;
  }

  .option {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1rem;
    cursor: pointer;
    transition: background 0.2s;
  }

  .option:hover {
    background: var(--md-sys-color-surface-container-high);
  }

  .option.selected {
    background: rgba(var(--md-sys-color-primary-rgb), 0.08);
  }

  .checkbox {
    display: flex;
    align-items: center;
    color: var(--md-sys-color-primary);
  }

  .checkbox .material-symbols-outlined {
    font-size: 24px;
  }

  .no-options {
    padding: 1rem;
    text-align: center;
    color: var(--md-sys-color-on-surface-variant);
    font-size: 0.875rem;
  }

  .error-text {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    margin-top: 0.25rem;
    font-size: 0.75rem;
    color: var(--md-sys-color-error);
  }

  .error-text .material-symbols-outlined {
    font-size: 16px;
  }

  .helper-text {
    margin-top: 0.25rem;
    font-size: 0.75rem;
    color: var(--md-sys-color-on-surface-variant);
  }
</style>
