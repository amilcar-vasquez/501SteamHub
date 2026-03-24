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

  // Document modal state
  let showDocumentModal = false;
  let selectedDocumentUrl = null;
  let selectedDocumentName = null;
  let documentLoading = false;
  let expandedAppId = null;

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
      actionSuccess = `${app.first_name} ${app.last_name}'s application approved. Their role has been upgraded to Fellow.`;
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
      actionSuccess = `${app.first_name} ${app.last_name}'s application has been rejected.`;
    } catch (err) {
      actionError = err.message || 'Failed to reject application.';
    }
  }

  async function viewDocument(app) {
    if (!app.moe_doc_path) {
      actionError = 'No document available for this application.';
      return;
    }
    documentLoading = true;
    selectedDocumentName = `${app.first_name}_${app.last_name}_MOE_Document`;
    try {
      const response = await fetch(`${import.meta.env.VITE_API_URL}/admin/moe-documents?path=${encodeURIComponent(app.moe_doc_path)}`, {
        headers: { 'Authorization': `Bearer ${token}` },
      });
      if (!response.ok) throw new Error('Failed to fetch document');
      const blob = await response.blob();
      selectedDocumentUrl = URL.createObjectURL(blob);
      showDocumentModal = true;
    } catch (err) {
      actionError = err.message || 'Failed to load document.';
    } finally {
      documentLoading = false;
    }
  }

  function closeDocumentModal() {
    showDocumentModal = false;
    if (selectedDocumentUrl) {
      URL.revokeObjectURL(selectedDocumentUrl);
      selectedDocumentUrl = null;
    }
  }

  function toggleExpanded(appId) {
    expandedAppId = expandedAppId === appId ? null : appId;
  }

  function changeFilter(tab) {
    statusFilter = tab;
    expandedAppId = null;
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

  <!-- Accordion list -->
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
    <div class="accordion-list">
      {#each applications as app (app.application_id)}
        <div class="accordion-item" class:expanded={expandedAppId === app.application_id}>
          <button 
            class="accordion-header"
            on:click={() => toggleExpanded(app.application_id)}
            aria-expanded={expandedAppId === app.application_id}
          >
            <span class="accordion-icon material-symbols-outlined">expand_more</span>
            <div class="accordion-header-content">
              <div class="app-name body-large">
                {app.first_name} {app.last_name}
              </div>
              <div class="accordion-meta body-small">
                <span class="meta-item">
                  <span class="material-symbols-outlined">business</span>
                  {app.organization || '—'}
                </span>
                <span class="meta-item">
                  <span class="material-symbols-outlined">calendar_today</span>
                  {formatDate(app.created_at)}
                </span>
                <span class="status-badge label-small badge-{app.status.toLowerCase()}">
                  {app.status}
                </span>
              </div>
            </div>
          </button>

          {#if expandedAppId === app.application_id}
            <div class="accordion-content">
              <div class="content-grid">
                <!-- Left column -->
                <div class="content-column">
                  <div class="info-group">
                    <h4 class="label-medium">Personal Details</h4>
                    <div class="info-row">
                      <span class="label-small info-label">First Name:</span>
                      <span class="body-small info-value">{app.first_name}</span>
                    </div>
                    <div class="info-row">
                      <span class="label-small info-label">Last Name:</span>
                      <span class="body-small info-value">{app.last_name}</span>
                    </div>
                    <div class="info-row">
                      <span class="label-small info-label">MOE Identifier:</span>
                      <span class="body-small info-value">{app.moe_identifier}</span>
                    </div>
                  </div>

                  <div class="info-group">
                    <h4 class="label-medium">Professional Info</h4>
                    <div class="info-row">
                      <span class="label-small info-label">Organization:</span>
                      <span class="body-small info-value">{app.organization}</span>
                    </div>
                    <div class="info-row">
                      <span class="label-small info-label">Experience (years):</span>
                      <span class="body-small info-value">{app.experience_years}</span>
                    </div>
                  </div>

                  <div class="info-group">
                    <h4 class="label-medium">Specializations</h4>
                    <div class="info-row">
                      <span class="label-small info-label">Subjects:</span>
                      <span class="body-small info-value">{joinArray(app.subjects)}</span>
                    </div>
                    <div class="info-row">
                      <span class="label-small info-label">Grade Levels:</span>
                      <span class="body-small info-value">{joinArray(app.grade_levels)}</span>
                    </div>
                  </div>
                </div>

                <!-- Right column -->
                <div class="content-column">
                  <div class="info-group">
                    <h4 class="label-medium">Bio</h4>
                    <p class="body-small bio-text">{app.bio}</p>
                  </div>

                  <div class="info-group">
                    <h4 class="label-medium">Credentials & Documents</h4>
                    {#if app.credentials_link}
                      <a href={app.credentials_link} target="_blank" rel="noopener noreferrer" class="credentials-link label-small">
                        <span class="material-symbols-outlined">open_in_new</span>
                        View Portfolio
                      </a>
                    {:else}
                      <span class="body-small muted">No portfolio link provided</span>
                    {/if}
                    
                    {#if app.moe_doc_path}
                      <div class="doc-button-group">
                        <button 
                          class="btn-document label-small"
                          on:click={() => viewDocument(app)}
                          disabled={documentLoading}
                        >
                          <span class="material-symbols-outlined">
                            {documentLoading && expandedAppId === app.application_id ? 'progress_activity' : 'description'}
                          </span>
                          {documentLoading && expandedAppId === app.application_id ? 'Loading…' : 'View MOE Document'}
                        </button>
                      </div>
                    {:else}
                      <span class="body-small muted">No MOE document uploaded</span>
                    {/if}
                  </div>

                  <div class="info-group">
                    <h4 class="label-medium">Application Timeline</h4>
                    <div class="info-row">
                      <span class="label-small info-label">Applied:</span>
                      <span class="body-small info-value">{formatDate(app.created_at)}</span>
                    </div>
                    {#if app.reviewed_at}
                      <div class="info-row">
                        <span class="label-small info-label">Reviewed:</span>
                        <span class="body-small info-value">{formatDate(app.reviewed_at)}</span>
                      </div>
                    {/if}
                  </div>
                </div>
              </div>

              <!-- Action buttons -->
              {#if app.status === 'Pending'}
                <div class="action-buttons">
                  <button
                    class="btn-approve label-small"
                    on:click={() => approveApplication(app)}
                  >
                    <span class="material-symbols-outlined">how_to_reg</span>
                    Approve Application
                  </button>
                  <button
                    class="btn-reject label-small"
                    on:click={() => rejectApplication(app)}
                  >
                    <span class="material-symbols-outlined">person_off</span>
                    Reject Application
                  </button>
                </div>
              {/if}
            </div>
          {/if}
        </div>
      {/each}
    </div>
  {/if}

  <!-- Document Modal/Popup -->
  {#if showDocumentModal}
    <div class="modal-overlay" on:click={closeDocumentModal}>
      <div class="modal" on:click|stopPropagation>
        <div class="modal-header">
          <h3 class="title-medium">{selectedDocumentName}</h3>
          <button class="modal-close" on:click={closeDocumentModal} aria-label="Close">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        <div class="modal-body">
          {#if selectedDocumentUrl}
            {#if selectedDocumentName.endsWith('.pdf')}
              <iframe src={selectedDocumentUrl} title="MOE Document"></iframe>
            {:else}
              <img src={selectedDocumentUrl} alt="MOE Document" />
            {/if}
          {/if}
        </div>
        <div class="modal-footer">
          <button class="btn-secondary label-small" on:click={closeDocumentModal}>
            Close
          </button>
        </div>
      </div>
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

  /* ── Accordion ── */
  .accordion-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .accordion-item {
    border: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
    border-radius: 8px;
    overflow: hidden;
    transition: box-shadow 0.2s;
  }

  .accordion-item:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }

  .accordion-item.expanded {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .accordion-header {
    width: 100%;
    padding: 16px;
    background: var(--md-sys-color-surface-container-low, #f7f2fa);
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 12px;
    transition: background 0.2s;
  }

  .accordion-header:hover {
    background: var(--md-sys-color-surface-container, #f3edf7);
  }

  .accordion-icon {
    font-size: 24px;
    color: var(--md-sys-color-on-surface-variant);
    transition: transform 0.3s ease;
    flex-shrink: 0;
  }

  .accordion-item.expanded .accordion-icon {
    transform: rotate(180deg);
  }

  .accordion-header-content {
    flex: 1;
    text-align: left;
  }

  .app-name {
    color: var(--md-sys-color-on-surface);
    margin: 0 0 4px;
    font-weight: 500;
  }

  .accordion-meta {
    display: flex;
    align-items: center;
    gap: 16px;
    flex-wrap: wrap;
    color: var(--md-sys-color-on-surface-variant);
  }

  .meta-item {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .meta-item .material-symbols-outlined {
    font-size: 16px;
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

  /* ── Accordion Content ── */
  .accordion-content {
    padding: 24px;
    background: var(--md-sys-color-surface);
    border-top: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  .content-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 32px;
    margin-bottom: 24px;
  }

  @media (max-width: 900px) {
    .content-grid {
      grid-template-columns: 1fr;
      gap: 24px;
    }
  }

  .content-column {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .info-group {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .info-group h4 {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    font-weight: 500;
  }

  .info-row {
    display: flex;
    justify-content: space-between;
    gap: 16px;
    padding: 8px 0;
    border-bottom: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  .info-row:last-child {
    border-bottom: none;
  }

  .info-label {
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
    min-width: 120px;
  }

  .info-value {
    color: var(--md-sys-color-on-surface);
    text-align: right;
    flex: 1;
  }

  .bio-text {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    line-height: 1.6;
    white-space: pre-wrap;
    word-wrap: break-word;
  }

  .credentials-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--md-sys-color-primary, #6750a4);
    text-decoration: none;
    padding: 8px 0;
    transition: opacity 0.2s;
  }

  .credentials-link:hover {
    opacity: 0.8;
    text-decoration: underline;
  }

  .credentials-link .material-symbols-outlined {
    font-size: 16px;
  }

  .doc-button-group {
    margin-top: 12px;
  }

  .btn-document {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: 8px;
    border: none;
    background: color-mix(in srgb, #6750a4 18%, transparent);
    color: #6750a4;
    cursor: pointer;
    transition: opacity 0.2s;
    font-family: inherit;
  }

  .btn-document:hover:not(:disabled) {
    opacity: 0.85;
  }

  .btn-document:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .btn-document .material-symbols-outlined {
    font-size: 18px;
  }

  /* ── Action buttons ── */
  .action-buttons {
    display: flex;
    gap: 12px;
    padding-top: 16px;
    border-top: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  @media (max-width: 600px) {
    .action-buttons {
      flex-direction: column;
    }
  }

  .btn-approve,
  .btn-reject {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    font-family: inherit;
    transition: opacity 0.15s;
    flex: 1;
    justify-content: center;
  }

  .btn-approve {
    background: color-mix(in srgb, #386a20 18%, transparent);
    color: #386a20;
  }

  .btn-approve:hover {
    opacity: 0.85;
  }

  .btn-reject {
    background: color-mix(in srgb, #b3261e 12%, transparent);
    color: #b3261e;
  }

  .btn-reject:hover {
    opacity: 0.85;
  }

  .btn-approve .material-symbols-outlined,
  .btn-reject .material-symbols-outlined {
    font-size: 18px;
  }

  /* ── Modal ── */
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    padding: 16px;
  }

  .modal {
    background: var(--md-sys-color-surface);
    border-radius: 16px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    max-width: 90vw;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 24px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  .modal-header h3 {
    margin: 0;
    color: var(--md-sys-color-on-surface);
    font-size: 18px;
    font-weight: 500;
    flex: 1;
    word-break: break-word;
  }

  .modal-close {
    background: none;
    border: none;
    cursor: pointer;
    padding: 0;
    display: flex;
    align-items: center;
    color: var(--md-sys-color-on-surface-variant);
    font-size: 24px;
  }

  .modal-close:hover {
    color: var(--md-sys-color-on-surface);
  }

  .modal-body {
    flex: 1;
    overflow: auto;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 16px;
    background: var(--md-sys-color-surface-container-low);
  }

  .modal-body iframe,
  .modal-body img {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
    border-radius: 8px;
  }

  .modal-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    padding: 16px 24px;
    border-top: 1px solid var(--md-sys-color-outline-variant, #cac4d0);
  }

  .btn-secondary {
    padding: 8px 24px;
    border-radius: 8px;
    border: 1px solid var(--md-sys-color-outline);
    background: transparent;
    color: var(--md-sys-color-on-surface);
    cursor: pointer;
    font-family: inherit;
    transition: background 0.15s;
  }

  .btn-secondary:hover {
    background: var(--md-sys-color-surface-container-high);
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

  .muted {
    color: var(--md-sys-color-outline, #79747e);
  }
</style>
