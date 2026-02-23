<!-- filename: ui/src/lib/components/admin/StatusOverrideDialog.svelte -->
<script>
  import { createEventDispatcher } from 'svelte';
  import { authToken } from '../../../stores/auth.js';
  import { adminAPI } from '../../../api/client.js';

  export let resource = null; // { resource_id, title, status }
  export let open = false;

  const dispatch = createEventDispatcher();

  const STATUS_OPTIONS = [
    'Draft',
    'Submitted',
    'UnderReview',
    'NeedsRevision',
    'Rejected',
    'Approved',
    'DesignCurate',
    'Published',
    'Indexed',
    'Archived',
  ];

  let selectedStatus = '';
  let reason = '';
  let isLoading = false;
  let errorMessage = '';

  $: if (open && resource) {
    selectedStatus = resource.status || '';
    reason = '';
    errorMessage = '';
  }

  let token = null;
  authToken.subscribe(v => (token = v));

  async function handleSubmit() {
    if (!selectedStatus) {
      errorMessage = 'Please select a status.';
      return;
    }
    isLoading = true;
    errorMessage = '';
    try {
      const result = await adminAPI.overrideResourceStatus(
        resource.resource_id,
        selectedStatus,
        reason,
        token,
      );
      dispatch('statusChanged', { resource: result.resource });
      open = false;
    } catch (err) {
      errorMessage = err.message || 'Failed to update status.';
    } finally {
      isLoading = false;
    }
  }

  function handleClose() {
    open = false;
    dispatch('close');
  }

  function handleBackdropClick(e) {
    if (e.target === e.currentTarget) handleClose();
  }
</script>

{#if open && resource}
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="dialog-backdrop" on:click={handleBackdropClick}>
    <div class="dialog" role="dialog" aria-modal="true" aria-labelledby="dialog-title">
      <header class="dialog-header">
        <h2 class="title-large" id="dialog-title">Override Resource Status</h2>
        <button class="icon-btn" on:click={handleClose} aria-label="Close">
          <span class="material-symbols-outlined">close</span>
        </button>
      </header>

      <div class="dialog-body">
        <p class="body-medium resource-name">
          <span class="material-symbols-outlined">folder</span>
          {resource.title}
        </p>
        <p class="body-small current-status">
          Current status: <strong>{resource.status}</strong>
        </p>

        <label class="field-label label-large" for="status-select">New Status</label>
        <select id="status-select" class="select-field" bind:value={selectedStatus}>
          <option value="" disabled>Choose a status…</option>
          {#each STATUS_OPTIONS as s}
            <option value={s}>{s}</option>
          {/each}
        </select>

        <label class="field-label label-large" for="reason-input">Reason (optional)</label>
        <textarea
          id="reason-input"
          class="textarea-field"
          rows="3"
          placeholder="Provide a reason for this override…"
          bind:value={reason}
        ></textarea>

        {#if errorMessage}
          <p class="error-msg body-small">{errorMessage}</p>
        {/if}
      </div>

      <footer class="dialog-footer">
        <button class="btn-text label-large" on:click={handleClose} disabled={isLoading}>
          Cancel
        </button>
        <button
          class="btn-filled label-large"
          on:click={handleSubmit}
          disabled={isLoading || !selectedStatus}
        >
          {isLoading ? 'Saving…' : 'Apply'}
        </button>
      </footer>
    </div>
  </div>
{/if}

<style>
  .dialog-backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 16px;
  }

  .dialog {
    background: var(--md-sys-color-surface);
    border-radius: 28px;
    width: 100%;
    max-width: 480px;
    box-shadow: var(--md-sys-elevation-level3, 0 4px 16px rgba(0,0,0,.25));
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .dialog-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 24px 24px 12px;
    gap: 8px;
  }

  .dialog-header h2 {
    color: var(--md-sys-color-on-surface);
    margin: 0;
    font-size: 22px;
    font-weight: 400;
  }

  .icon-btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: 8px;
    border-radius: 50%;
    color: var(--md-sys-color-on-surface-variant);
    display: flex;
    align-items: center;
    transition: background 0.15s;
  }
  .icon-btn:hover { background: var(--md-sys-color-surface-variant); }

  .dialog-body {
    padding: 0 24px 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .resource-name {
    display: flex;
    align-items: center;
    gap: 6px;
    color: var(--md-sys-color-on-surface);
    font-weight: 500;
    margin: 0;
  }
  .resource-name .material-symbols-outlined { font-size: 18px; }

  .current-status {
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
  }

  .field-label {
    color: var(--md-sys-color-on-surface-variant);
    margin-bottom: -4px;
  }

  .select-field,
  .textarea-field {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 4px;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-size: 14px;
    font-family: inherit;
    box-sizing: border-box;
    transition: border-color 0.15s;
  }
  .select-field:focus,
  .textarea-field:focus {
    outline: none;
    border-color: var(--md-sys-color-primary);
  }

  .error-msg {
    color: var(--md-sys-color-error);
    margin: 0;
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
    padding: 12px 24px 20px;
  }

  .btn-text {
    background: none;
    border: none;
    cursor: pointer;
    padding: 10px 16px;
    border-radius: 20px;
    color: var(--md-sys-color-primary);
    font-family: inherit;
    transition: background 0.15s;
  }
  .btn-text:hover { background: color-mix(in srgb, var(--md-sys-color-primary) 8%, transparent); }
  .btn-text:disabled { opacity: 0.5; cursor: not-allowed; }

  .btn-filled {
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    cursor: pointer;
    padding: 10px 24px;
    border-radius: 20px;
    font-family: inherit;
    transition: opacity 0.15s;
  }
  .btn-filled:hover { opacity: 0.9; }
  .btn-filled:disabled { opacity: 0.5; cursor: not-allowed; }
</style>
