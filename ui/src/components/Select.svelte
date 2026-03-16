<script>
  export let label = '';
  export let value = '';
  export let options = []; // Array of {value, label} objects
  export let error = '';
  export let required = false;
  export let helperText = '';
  
  let focused = false;
  let selectId = `select-${Math.random().toString(36).substr(2, 9)}`;
  let isOpen = false;

  function parseLabel(labelText) {
    const parts = labelText.split(' ');
    if (parts.length > 1) {
      const iconName = parts[0];
      const displayText = parts.slice(1).join(' ');
      return { iconName, displayText };
    }
    return { iconName: null, displayText: labelText };
  }

  function getSelectedLabel() {
    const selectedOption = options.find(opt => opt.value === value);
    if (selectedOption) {
      const { displayText } = parseLabel(selectedOption.label);
      return displayText;
    }
    return `Choose ${label.toLowerCase()}`;
  }

  function handleClickOutside(event) {
    if (!event.target.closest('.select-field')) {
      isOpen = false;
    }
  }

  function selectOption(optionValue) {
    value = optionValue;
    isOpen = false;
    focused = false;
  }
</script>

<svelte:window on:click={handleClickOutside} />

<div class="select-field" class:filled={value} class:focused class:error>
  <div 
    class="select-trigger"
    on:click={() => isOpen = !isOpen}
    on:focus={() => focused = true}
    on:blur={() => focused = false}
    role="button"
    tabindex="0"
  >
    <div class="trigger-content">
      {#if value}
        {@const selectedOption = options.find(opt => opt.value === value)}
        {@const { iconName, displayText } = parseLabel(selectedOption?.label || '')}
        {#if iconName}
          <span class="material-symbols-outlined icon">{iconName}</span>
        {/if}
        <span class="text">{displayText}</span>
      {:else}
        <span class="placeholder">Choose {label.toLowerCase()}</span>
      {/if}
    </div>
    <span class="material-symbols-outlined dropdown-icon" class:open={isOpen}>expand_more</span>
  </div>

  <label for={selectId}>
    {label}{required ? ' *' : ''}
  </label>

  {#if isOpen}
    <div class="dropdown" on:click|stopPropagation>
      <div class="options">
        {#each options as option}
          {@const { iconName, displayText } = parseLabel(option.label)}
          <div 
            class="option" 
            class:selected={value === option.value}
            on:click={() => selectOption(option.value)}
          >
            {#if iconName}
              <span class="material-symbols-outlined icon">{iconName}</span>
            {/if}
            <span class="option-text">{displayText}</span>
          </div>
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
  .select-field {
    position: relative;
    margin-bottom: var(--md-sys-spacing-lg);
  }

  .select-trigger {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    height: 64px;
    padding: 20px 16px 8px;
    font-size: 16px;
    color: var(--md-sys-color-on-surface);
    background-color: var(--md-sys-color-surface-variant);
    border: 1px solid var(--md-sys-color-outline);
    border-radius: var(--md-sys-shape-corner-sm);
    cursor: pointer;
    transition: all 0.2s;
    outline: none;
  }

  .select-trigger:hover {
    background-color: rgba(124, 61, 130, 0.08);
    border-color: var(--md-sys-color-on-surface);
  }

  .select-field.focused .select-trigger,
  .select-trigger:focus {
    background-color: rgba(124, 61, 130, 0.12);
    border-color: var(--md-sys-color-primary);
    border-width: 2px;
    padding: 19px 15px 7px 15px;
  }

  .trigger-content {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    flex: 1;
    min-height: 24px;
  }

  .trigger-content .icon {
    font-size: 20px;
    color: var(--md-sys-color-primary);
    flex-shrink: 0;
  }

  .trigger-content .text,
  .placeholder {
    font-size: 16px;
    font-family: var(--md-sys-typescale-body-large-font);
    color: var(--md-sys-color-on-surface);
  }

  .placeholder {
    color: var(--md-sys-color-on-surface-variant);
  }

  .dropdown-icon {
    font-size: 24px;
    color: var(--md-sys-color-on-surface-variant);
    transition: transform 0.2s;
    flex-shrink: 0;
  }

  .dropdown-icon.open {
    transform: rotate(180deg);
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

  .select-field.focused label,
  .select-field.filled label {
    color: var(--md-sys-color-primary);
  }

  .select-field.error .select-trigger {
    border-color: var(--md-sys-color-error);
    background-color: rgba(179, 38, 30, 0.05);
  }

  .select-field.error label {
    color: var(--md-sys-color-error);
  }

  .dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    margin-top: 4px;
    background: white;
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-sm);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    z-index: 1000;
    max-height: 300px;
    overflow-y: auto;
  }

  .options {
    display: flex;
    flex-direction: column;
    padding: 0;
    margin: 0;
  }

  .option {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 12px 16px;
    cursor: pointer;
    transition: background-color 0.15s;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
  }

  .option:last-child {
    border-bottom: none;
  }

  .option:hover {
    background-color: var(--md-sys-color-primary-container);
  }

  .option.selected {
    background-color: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
  }

  .option .icon {
    font-size: 20px;
    color: var(--md-sys-color-primary);
    flex-shrink: 0;
  }

  .option.selected .icon {
    color: var(--md-sys-color-on-primary-container);
  }

  .option-text {
    font-size: 14px;
    color: var(--md-sys-color-on-surface);
  }

  .option.selected .option-text {
    color: var(--md-sys-color-on-primary-container);
    font-weight: 500;
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
</style>
