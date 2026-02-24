<!-- filename: ui/src/lib/components/admin/FellowApplicationsTable.svelte -->
<script>
  import { onMount } from 'svelte';
  import { authToken } from '../../../stores/auth.js';
  import { adminAPI } from '../../../api/client.js';

  let token = null;
  authToken.subscribe(v => (token = v));

  let applications = [];
  let isLoading = true;
  let loadError = '';

  let actionError = '';
  let actionSuccess = '';

  // Filter tabs: All | Pending | Approved | Rejected
  let statusFilter = 'Pending';
  const STATUS_TABS = ['Pending', 'Approved', 'Rejected', 'All'];

  onMount(() => loadApplications());

  async function loadApplications() {
    isLoading = true;
    loadError = '';
    try {
      const filter = statusFilter === 'All' ? '' : statusFilter;
      const data = await adminAPI.listFellowApplications(token, filter);
      applications = data.applications || [];
    } catch (err) {
      loadError = err.message || 'Failed to load applications.';
    } finally {
      isLoading = false;
    }
  }

  async function approveApplication(app) {
    actionError = '';
    actionSuccess = '';
    try {
      await adminAPI.approveFellowApplication(app.application_id, token);
      applications = applications.filter(a => a.application_id !== app.application_id);
      actionSuccess = `${app.full_name}'s application approved. Their role has been upgraded to Fellow.`;
    } catch (err) {
      actionError = err.message || 'Failed to approve application.';
    }
  }

  async function rejectApplication(app) {
    actionError = '';
    actionSuccess = '';
    try {
      await adminAPI.rejectFellowApplication(app.application_id, token);
      applications = applications.filter(a => a.application_id !== app.application_id);
      actionSuccess = `${app.full_name}'s application has been rejected.`;
    } catch (err) {
      actionError = err.message || 'Failed to reject application.';
    }
  }

  function changeFilter(tab) {
    statusFilter = tab;
    loadApplications();
  }

  function formatDate(dateStr) {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString(undefined, { year: 'numeric', month: 'short', day: 'numeric' });
  }

  function joinArray(arr) {
    if (!arr || arr.length === 0) return '—';
    return arr.join(', ');
  }
</script>

<section class="panel" aria-label="Fellow Applications Panel">
  <header class="panel-header">
    <h2 class="title-large panel-title">
      <span class="material-symbols-outlined">school</span>
      Fellow Applications
    </h2>
  </header>

  <!-- Status filter tabs -->
  <div class="tab-row" role="tablist" aria-label="Filter by status">
    {#each STATUS_TABS as tab}
      <button
        class="tab-btn label-medium"
        class:tab-active={statusFilter === tab}
        role="tab"
        aria-selected={statusFilter === tab}
        on:click={() => changeFilter(tab)}
      >
        {tab}
      </button>
    {/each}
  </div>

  <!-- Feedback banners -->
  {#if actionSuccess}
    <div class="banner banner-success body-small" role="status">
      <span class="material-symbols-outlined">check_circle</span>
      {actionSuccess}
      <button class="banner-close" on:click={() => (actionSuccess = '')} aria-label="Dismiss">×</button>
    </div>
  {/if}
  {#if actionError}
    <div class="banner banner-error body-small" role="alert">
      <span class="material-symbols-outlined">error</span>
      {actionError}
      <button class="banner-close" on:click={() => (actionError = '')} aria-label="Dismiss">×</button>
    </div>
  {/if}

  <!-- Table -->
  {#if isLoading}
    <div class="empty-state body-medium">
      <span class="material-symbols-outlined spinning">progress_activity</span>
      Loading applications…
    </div>
  {:else if loadError}
    <div class="empty-state error body-medium">
      <span class="material-symbols-outlined">warning</span>
      {loadError}
      <button class="retry-btn label-medium" on:click={loadApplications}>Retry</button>
    </div>
  {:else if applications.length === 0}
    <div class="empty-state body-medium">
      No {statusFilter === 'All' ? '' : statusFilter.toLowerCase()} applications found.
    </div>
  {:else}
    <div class="table-wrapper">
      <table class="app-table" aria-label="Fellow applications list">
        <thead>
          <tr>
            <th class="label-medium">Applicant</th>
            <th class="label-medium">Organization</th>
            <th class="label-medium">Subjects</th>
            <th class="label-medium">Grade Levels</th>
            <th class="label-medium">Exp. (yrs)</th>
            <th class="label-medium">Applied</th>
            <th class="label-medium">Status</th>
            {#if statusFilter === 'Pending' || statusFilter === 'All'}
              <th class="label-medium">Actions</th>
            {/if}
          </tr>
        </thead>
        <tbody>
          {#each applications as app (app.application_id)}
            <tr>
              <td class="body-medium name-cell">
                <span class="material-symbols-outlined avatar-icon">account_circle</span>
                <div>
                  <div class="app-name">{app.full_name}</div>
                  {#if app.credentials_link}
                    <a href={app.credentials_link} target="_blank" rel="noopener noreferrer" class="cred-link body-small">
                      Portfolio ↗
                    </a>
                  {/if}
                </div>
              </td>
              <td class="body-small">{app.organization}</td>
              <td class="body-small subjects-cell">{joinArray(app.subjects)}</td>
              <td class="body-small">{joinArray(app.grade_levels)}</td>
              <td class="body-small center">{app.experience_years}</td>
              <td class="body-small">{formatDate(app.created_at)}</td>
              <td>
                <span class="status-badge label-small badge-{app.status.toLowerCase()}">
                  {app.status}
                </span>
              </td>
              {#if statusFilter === 'Pending' || statusFilter === 'All'}
                <td class="action-cell">
                  {#if app.status === 'Pending'}
                    <button
                      class="btn-tonal btn-approve label-small"
                      on:click={() => approveApplication(app)}
                      title="Approve {app.full_name}'s application"
                    >
                      <span class="material-symbols-outlined">how_to_reg</span>
                      Approve
                    </button>
                    <button
                      class="btn-tonal btn-reject label-small"
                      on:click={() => rejectApplication(app)}
                      title="Reject {app.full_name}'s application"
                    >
                      <span class="material-symbols-outlined">person_off</span>
                      Reject
                    </button>
                  {:else}
                    <span class="body-small muted">—</span>
                  {/if}
                </td>
              {/if}
            </tr>
            <!-- Bio row (collapsed accordion style) -->
            <tr class="bio-row">
              <td colspan="8" class="bio-cell body-small">
                <details>
                  <summary class="label-small bio-summary">View Bio</summary>
                  <p class="bio-text">{app.bio}</p>
                </details>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</section>

<style>
  .panel {
    background: var(--md-sys-color-surface);
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.12);
  }

  .panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
    gap: 12px;
    flex-wrap: wrap;
  }

  .panel-title {
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--md-sys-color-on-surface);
    margin: 0;
    font-size: 20px;
    font-weight: 500;
  }

  /* ── Tabs ── */
  .tab-row {
    display: flex;
    gap: 4px;
    margin-bottom: 16px;
    flex-wrap: wrap;
  }

  .tab-btn {
    padding: 6px 16px;
    border-radius: 20px;
    border: 1px solid var(--md-sys-color-outline, #79747e);
    background: transparent;
    color: var(--md-sys-color-on-surface-variant, #49454f);
    cursor: pointer;
    transition: background 0.15s, color 0.15s;
  }

  .tab-btn:hover {
    background: var(--md-sys-color-surface-container-high, #ece6f0);
  }

  .tab-btn.tab-active {
    background: var(--md-sys-color-primary, #6750a4);
    color: var(--md-sys-color-on-primary, #fff);
    border-color: var(--md-sys-color-primary, #6750a4);
  }

  /* ── Banners ── */
  .banner {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 12px;
  }

  .banner-success {
    background: color-mix(in srgb, #386a20 12%, transparent);
    color: #386a20;
  }

  .banner-error {
    background: color-mix(in srgb, var(--md-sys-color-error, #b3261e) 12%, transparent);
    color: var(--md-sys-color-error, #b3261e);
  }

  .banner-close {
    margin-left: auto;
    background: none;
    border: none;
    cursor: pointer;
    font-size: 1.1rem;
    color: inherit;
    line-height: 1;
  }

  /* ── Table ── */
  .table-wrapper {
    overflow-x: auto;
    border-radius: 8px;
    border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  .app-table {
    width: 100%;
    border-collapse: collapse;
    min-width: 720px;
  }

  .app-table th {
    background: var(--md-sys-color-surface-container, #f3edf7);
    padding: 10px 12px;
    text-align: left;
    color: var(--md-sys-color-on-surface-variant, #49454f);
    font-weight: 600;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    white-space: nowrap;
  }

  .app-table td {
    padding: 10px 12px;
    vertical-align: top;
    border-top: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  .app-table tr:hover > td {
    background: var(--md-sys-color-surface-container-low, #f7f2fa);
  }

  /* ── Name cell ── */
  .name-cell {
    display: flex;
    align-items: flex-start;
    gap: 8px;
  }

  .avatar-icon {
    font-size: 24px;
    color: var(--md-sys-color-on-surface-variant, #49454f);
    flex-shrink: 0;
    margin-top: 2px;
  }

  .app-name {
    font-weight: 500;
  }

  .cred-link {
    color: var(--md-sys-color-primary, #6750a4);
    text-decoration: none;
  }

  .cred-link:hover {
    text-decoration: underline;
  }

  /* ── Subjects cell ── */
  .subjects-cell {
    max-width: 180px;
    white-space: normal;
    word-break: break-word;
  }

  /* ── Status badges ── */
  .status-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 0.7rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    white-space: nowrap;
  }

  .badge-pending {
    background: color-mix(in srgb, #f9a825 20%, transparent);
    color: #9a6700;
  }

  .badge-approved {
    background: color-mix(in srgb, #386a20 15%, transparent);
    color: #386a20;
  }

  .badge-rejected {
    background: color-mix(in srgb, #b3261e 12%, transparent);
    color: #b3261e;
  }

  /* ── Action buttons ── */
  .action-cell {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
    align-items: center;
  }

  .btn-tonal {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 5px 12px;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    font-size: 0.75rem;
    font-weight: 500;
    transition: opacity 0.15s;
  }

  .btn-tonal:hover {
    opacity: 0.85;
  }

  .btn-tonal .material-symbols-outlined {
    font-size: 16px;
  }

  .btn-approve {
    background: color-mix(in srgb, #386a20 18%, transparent);
    color: #386a20;
  }

  .btn-reject {
    background: color-mix(in srgb, #b3261e 12%, transparent);
    color: #b3261e;
  }

  /* ── Bio row ── */
  .bio-row > td {
    padding: 0 12px;
    border-top: none;
  }

  .bio-cell {
    padding-bottom: 0 !important;
  }

  .bio-summary {
    cursor: pointer;
    color: var(--md-sys-color-primary, #6750a4);
    padding: 4px 0;
    display: inline-block;
  }

  .bio-text {
    margin: 6px 0 10px;
    color: var(--md-sys-color-on-surface-variant, #49454f);
    line-height: 1.6;
    max-width: 720px;
  }

  /* ── Empty / loading states ── */
  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    padding: 40px;
    color: var(--md-sys-color-on-surface-variant, #49454f);
    text-align: center;
  }

  .empty-state.error {
    color: var(--md-sys-color-error, #b3261e);
  }

  .empty-state .material-symbols-outlined {
    font-size: 40px;
  }

  .retry-btn {
    padding: 6px 16px;
    border-radius: 20px;
    border: 1px solid currentColor;
    background: none;
    cursor: pointer;
    color: inherit;
    margin-top: 4px;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .spinning {
    animation: spin 1s linear infinite;
    display: inline-block;
  }

  .center {
    text-align: center;
  }

  .muted {
    color: var(--md-sys-color-outline, #79747e);
  }
</style>
