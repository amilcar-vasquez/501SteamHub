<!-- filename: ui/src/lib/components/admin/UserAdminTable.svelte -->
<script>
  import { onMount } from 'svelte';
  import { authToken } from '../../../stores/auth.js';
  import { adminAPI } from '../../../api/client.js';

  // Role seed data kept in sync with migrations/010_seed_roles.up.sql
  const ROLES = [
    { id: 1, name: 'admin' },
    { id: 2, name: 'User' },
    { id: 3, name: 'Fellow' },
    { id: 4, name: 'SubjectExpert' },
    { id: 5, name: 'TeamLead' },
    { id: 6, name: 'DSC' },
    { id: 7, name: 'Secretary' },
  ];

  let token = null;
  authToken.subscribe(v => (token = v));

  let users = [];
  let isLoading = true;
  let loadError = '';

  let actionError = '';
  let actionSuccess = '';

  // Create-user form
  let showCreateForm = false;
  let newUser = { username: '', email: '', password: '', role_id: 2 };
  let createError = '';
  let createLoading = false;

  // Send email dialog
  let showEmailDialog = false;
  let emailUser = null;
  let emailForm = { subject: '', body: '' };
  let emailError = '';
  let emailSending = false;

  // Role change confirmation dialog (for admin role changes)
  let showRoleConfirmDialog = false;
  let roleChangeUser = null;
  let roleChangeNewId = null;

  onMount(loadUsers);

  async function loadUsers() {
    isLoading = true;
    loadError = '';
    try {
      const data = await adminAPI.getUsers(token, { page_size: 100 });
      users = data.users || [];
    } catch (err) {
      loadError = err.message || 'Failed to load users.';
    } finally {
      isLoading = false;
    }
  }

  async function handleRoleChange(user, newRoleId) {
    actionError = '';
    actionSuccess = '';
    
    const newRoleIdInt = parseInt(newRoleId);
    const adminRoleId = 1;
    
    // If changing to/from admin role, show confirmation dialog
    if (user.role_id === adminRoleId || newRoleIdInt === adminRoleId) {
      roleChangeUser = user;
      roleChangeNewId = newRoleIdInt;
      showRoleConfirmDialog = true;
      return;
    }
    
    // Otherwise proceed with the change
    await commitRoleChange(user, newRoleIdInt);
  }

  async function commitRoleChange(user, newRoleId) {
    try {
      const result = await adminAPI.updateUserRole(user.user_id, newRoleId, token);
      users = users.map(u => u.user_id === user.user_id ? result.user : u);
      actionSuccess = `Role updated for ${user.username}.`;
    } catch (err) {
      actionError = err.message || 'Failed to update role.';
    }
  }

  async function handleToggleActive(user) {
    actionError = '';
    actionSuccess = '';
    try {
      const result = await adminAPI.toggleUserActive(user.user_id, !user.is_active, token);
      users = users.map(u => u.user_id === user.user_id ? result.user : u);
      actionSuccess = `${user.username} is now ${!user.is_active ? 'active' : 'disabled'}.`;
    } catch (err) {
      actionError = err.message || 'Failed to toggle user status.';
    }
  }

  async function handleCreateUser() {
    createError = '';
    createLoading = true;
    try {
      const result = await adminAPI.createUser({ ...newUser, role_id: parseInt(newUser.role_id) }, token);
      users = [result.user, ...users];
      newUser = { username: '', email: '', password: '', role_id: 2 };
      showCreateForm = false;
      actionSuccess = 'User created successfully.';
    } catch (err) {
      createError = err.message || 'Failed to create user.';
    } finally {
      createLoading = false;
    }
  }

  function openEmailDialog(user) {
    emailUser = user;
    emailForm = { subject: '', body: '' };
    emailError = '';
    showEmailDialog = true;
  }

  async function handleSendEmail() {
    emailError = '';
    emailSending = true;
    try {
      await adminAPI.sendEmailToUser(emailUser.user_id, emailForm.subject, emailForm.body, token);
      actionSuccess = `Email sent to ${emailUser.username}.`;
      showEmailDialog = false;
      emailUser = null;
      emailForm = { subject: '', body: '' };
    } catch (err) {
      emailError = err.message || 'Failed to send email.';
    } finally {
      emailSending = false;
    }
  }

  function roleName(roleId) {
    return ROLES.find(r => r.id === roleId)?.name ?? `Role ${roleId}`;
  }
</script>

<section class="panel" aria-label="User Admin Panel">
  <header class="panel-header">
    <h2 class="title-large panel-title">
      <span class="material-symbols-outlined">manage_accounts</span>
      Users
    </h2>
    <button
      class="btn-filled label-medium"
      on:click={() => { showCreateForm = !showCreateForm; createError = ''; }}
    >
      <span class="material-symbols-outlined">person_add</span>
      {showCreateForm ? 'Cancel' : 'New User'}
    </button>
  </header>

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

  <!-- Create user form -->
  {#if showCreateForm}
    <form class="create-form" on:submit|preventDefault={handleCreateUser} novalidate>
      <h3 class="title-medium form-title">Create New User</h3>
      <div class="form-row">
        <div class="form-field">
          <label class="label-medium" for="new-username">Username</label>
          <input id="new-username" class="input-field body-medium" type="text" bind:value={newUser.username} required />
        </div>
        <div class="form-field">
          <label class="label-medium" for="new-email">Email</label>
          <input id="new-email" class="input-field body-medium" type="email" bind:value={newUser.email} required />
        </div>
      </div>
      <div class="form-row">
        <div class="form-field">
          <label class="label-medium" for="new-password">Password</label>
          <input id="new-password" class="input-field body-medium" type="password" bind:value={newUser.password} required />
        </div>
        <div class="form-field">
          <label class="label-medium" for="new-role">Role</label>
          <select id="new-role" class="input-field body-medium" bind:value={newUser.role_id}>
            {#each ROLES as role}
              <option value={role.id}>{role.name}</option>
            {/each}
          </select>
        </div>
      </div>
      {#if createError}
        <p class="error-msg body-small">{createError}</p>
      {/if}
      <div class="form-actions">
        <button type="submit" class="btn-filled label-medium" disabled={createLoading}>
          {createLoading ? 'Creating…' : 'Create User'}
        </button>
      </div>
    </form>
  {/if}

  <!-- Table -->
  {#if isLoading}
    <div class="empty-state body-medium">
      <span class="material-symbols-outlined spinning">progress_activity</span>
      Loading users…
    </div>
  {:else if loadError}
    <div class="empty-state error body-medium">
      <span class="material-symbols-outlined">warning</span>
      {loadError}
      <button class="retry-btn label-medium" on:click={loadUsers}>Retry</button>
    </div>
  {:else if users.length === 0}
    <div class="empty-state body-medium">No users found.</div>
  {:else}
    <div class="table-wrapper">
      <table class="user-table" aria-label="Users list">
        <thead>
          <tr>
            <th class="label-medium">User</th>
            <th class="label-medium">Email</th>
            <th class="label-medium">Role</th>
            <th class="label-medium">Status</th>
            <th class="label-medium">Actions</th>
          </tr>
        </thead>
        <tbody>
          {#each users as user (user.user_id)}
            <tr class:row-inactive={!user.is_active}>
              <td class="body-medium name-cell">
                <span class="avatar-icon material-symbols-outlined">account_circle</span>
                {user.username}
              </td>
              <td class="body-small">{user.email}</td>
              <td>
                <!-- Inline role selector -->
                <select
                  class="role-select body-small"
                  value={user.role_id}
                  on:change={e => handleRoleChange(user, e.target.value)}
                  aria-label="Change role for {user.username}"
                >
                  {#each ROLES as role}
                    <option value={role.id}>{role.name}</option>
                  {/each}
                </select>
              </td>
              <td>
                <span class="status-badge label-small {user.is_active ? 'badge-active' : 'badge-disabled'}">
                  {user.is_active ? 'Active' : 'Disabled'}
                </span>
              </td>
              <td class="action-cell">
                <button
                  class="btn-tonal label-small {user.is_active ? 'btn-disable' : 'btn-enable'}"
                  on:click={() => handleToggleActive(user)}
                  title="{user.is_active ? 'Disable' : 'Enable'} {user.username}"
                >
                  <span class="material-symbols-outlined">
                    {user.is_active ? 'person_off' : 'how_to_reg'}
                  </span>
                  {user.is_active ? 'Disable' : 'Enable'}
                </button>
                <button
                  class="btn-tonal label-small btn-email"
                  on:click={() => openEmailDialog(user)}
                  title="Send email to {user.username}"
                >
                  <span class="material-symbols-outlined">mail</span>
                  Email
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}

  <!-- Email dialog -->
  {#if showEmailDialog && emailUser}
    <div 
      class="dialog-overlay" 
      on:click={() => (showEmailDialog = false)}
      on:keydown={(e) => e.key === 'Escape' && (showEmailDialog = false)}
      role="button"
      tabindex="0"
      aria-label="Close email dialog"
    >
      <div class="dialog" on:click|stopPropagation role="presentation">
        <div class="dialog-header">
          <h3 class="title-medium">Send Email to {emailUser.username}</h3>
          <button
            class="dialog-close"
            on:click={() => (showEmailDialog = false)}
            aria-label="Close dialog"
          >
            ×
          </button>
        </div>

        <div class="dialog-content">
          {#if emailError}
            <div class="banner banner-error body-small">
              <span class="material-symbols-outlined">error</span>
              {emailError}
            </div>
          {/if}

          <div class="form-field">
            <label class="label-medium" for="email-subject">Subject</label>
            <input
              id="email-subject"
              class="input-field body-medium"
              type="text"
              bind:value={emailForm.subject}
              placeholder="Email subject..."
              maxlength="255"
              disabled={emailSending}
            />
          </div>

          <div class="form-field">
            <label class="label-medium" for="email-body">Message</label>
            <textarea
              id="email-body"
              class="input-field body-medium"
              bind:value={emailForm.body}
              placeholder="Email body..."
              rows="6"
              maxlength="5000"
              disabled={emailSending}
            />
          </div>
        </div>

        <div class="dialog-footer">
          <button
            class="btn-text label-medium"
            on:click={() => (showEmailDialog = false)}
            disabled={emailSending}
          >
            Cancel
          </button>
          <button
            class="btn-filled label-medium"
            on:click={handleSendEmail}
            disabled={emailSending || !emailForm.subject || !emailForm.body}
          >
            {emailSending ? 'Sending...' : 'Send Email'}
          </button>
        </div>
      </div>
    </div>
  {/if}

  <!-- Role change confirmation dialog (for admin role changes) -->
  {#if showRoleConfirmDialog && roleChangeUser}
    <div 
      class="dialog-overlay" 
      on:click={() => (showRoleConfirmDialog = false)}
      on:keydown={(e) => e.key === 'Escape' && (showRoleConfirmDialog = false)}
      role="button"
      tabindex="0"
      aria-label="Close role confirmation dialog"
    >
      <div class="dialog" on:click|stopPropagation role="presentation">
        <div class="dialog-header">
          <h3 class="title-medium warning-title">
            <span class="material-symbols-outlined">warning</span>
            Confirm Role Change
          </h3>
          <button
            class="dialog-close"
            on:click={() => (showRoleConfirmDialog = false)}
            aria-label="Close dialog"
          >
            ×
          </button>
        </div>

        <div class="dialog-content">
          <p class="body-medium warning-text">
            {roleChangeUser.role_id === 1
              ? `You are about to remove admin privileges from <strong>${roleChangeUser.username}</strong>. This user will lose access to the admin panel.`
              : `You are about to assign admin privileges to <strong>${roleChangeUser.username}</strong>. This user will gain full administrative access.`
            }
          </p>
          <p class="body-small secondary-text">This action is protected due to its security impact.</p>
        </div>

        <div class="dialog-footer">
          <button
            class="btn-text label-medium"
            on:click={() => (showRoleConfirmDialog = false)}
          >
            Cancel
          </button>
          <button
            class="btn-filled btn-warning label-medium"
            on:click={async () => {
              await commitRoleChange(roleChangeUser, roleChangeNewId);
              showRoleConfirmDialog = false;
              roleChangeUser = null;
              roleChangeNewId = null;
            }}
          >
            Confirm Change
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
    box-shadow: 0 1px 3px rgba(0,0,0,.12);
  }

  .panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
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
  .panel-title .material-symbols-outlined { font-size: 22px; }

  /* Feedback banners */
  .banner {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
  }
  .banner .material-symbols-outlined { font-size: 18px; }
  .banner-success { background: #e8f5e9; color: #1b5e20; }
  .banner-error   { background: #ffebee; color: #b71c1c; }
  .banner-close {
    background: none;
    border: none;
    cursor: pointer;
    margin-left: auto;
    font-size: 18px;
    line-height: 1;
    opacity: 0.7;
    color: inherit;
  }
  .banner-close:hover { opacity: 1; }

  /* Create form */
  .create-form {
    background: var(--md-sys-color-surface-variant);
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
  }
  .form-title { color: var(--md-sys-color-on-surface); margin: 0 0 16px; }
  .form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
    margin-bottom: 16px;
  }
  @media (max-width: 600px) { .form-row { grid-template-columns: 1fr; } }
  .form-field { display: flex; flex-direction: column; gap: 4px; }
  .form-field label { color: var(--md-sys-color-on-surface-variant); }
  .input-field {
    padding: 10px 14px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 4px;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-family: inherit;
    font-size: 14px;
  }
  .input-field:focus { outline: none; border-color: var(--md-sys-color-primary); }
  .error-msg { color: var(--md-sys-color-error); margin: 0; font-size: 12px; }
  .form-actions { display: flex; justify-content: flex-end; }

  /* Empty / loading */
  .empty-state {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 32px 0;
    justify-content: center;
    color: var(--md-sys-color-on-surface-variant);
  }
  .empty-state.error { color: var(--md-sys-color-error); }
  .retry-btn {
    background: none; border: none; cursor: pointer;
    color: var(--md-sys-color-primary); text-decoration: underline; font-family: inherit;
  }

  @keyframes spin { to { transform: rotate(360deg); } }
  .spinning { animation: spin 1s linear infinite; }

  /* Table */
  .table-wrapper { overflow-x: auto; }

  .user-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }

  .user-table th {
    text-align: left;
    padding: 12px 12px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    color: var(--md-sys-color-on-surface-variant);
    white-space: nowrap;
  }

  .user-table td {
    padding: 12px 12px;
  }

  .user-table tbody tr:hover { background: color-mix(in srgb, var(--md-sys-color-primary) 5%, transparent); }

  .row-inactive td { opacity: 0.55; }

  .name-cell {
    display: flex;
    align-items: center;
    gap: 6px;
    font-weight: 500;
    color: var(--md-sys-color-on-surface);
    white-space: nowrap;
  }
  .avatar-icon { font-size: 20px; color: var(--md-sys-color-on-surface-variant); }

  .role-select {
    padding: 8px 8px;
    border: 1px solid var(--md-sys-color-outline);
    border-radius: 6px;
    background: var(--md-sys-color-surface);
    color: var(--md-sys-color-on-surface);
    font-family: inherit;
    cursor: pointer;
  }
  .role-select:focus { outline: none; border-color: var(--md-sys-color-primary); }

  .status-badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-weight: 600;
    white-space: nowrap;
  }
  .badge-active   { background: #e8f5e9; color: #1b5e20; }
  .badge-disabled { background: #eeeeee; color: #757575; }

  .action-cell { white-space: nowrap; }

  .btn-tonal {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 6px 14px;
    border-radius: 16px;
    border: none;
    cursor: pointer;
    font-family: inherit;
    font-size: 12px;
    font-weight: 600;
    transition: opacity 0.15s;
  }
  .btn-tonal .material-symbols-outlined { font-size: 16px; }
  .btn-tonal:hover { opacity: 0.8; }

  .btn-disable {
    background: #ffebee;
    color: #b71c1c;
  }
  .btn-enable {
    background: #e8f5e9;
    color: #1b5e20;
  }
  .btn-email {
    background: #e3f2fd;
    color: #0d47a1;
    margin-left: 8px;
  }

  /* Shared filled button */
  .btn-filled {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary);
    border: none;
    cursor: pointer;
    padding: 9px 20px;
    border-radius: 20px;
    font-family: inherit;
    font-size: 13px;
    font-weight: 600;
    transition: opacity 0.15s;
  }
  .btn-filled .material-symbols-outlined { font-size: 18px; }
  .btn-filled:hover { opacity: 0.9; }
  .btn-filled:disabled { opacity: 0.5; cursor: not-allowed; }

  /* Email dialog */
  .dialog-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .dialog {
    background: var(--md-sys-color-surface);
    border-radius: 12px;
    box-shadow: 0 5px 16px rgba(0, 0, 0, 0.25);
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
  }

  .dialog-header {
    padding: 20px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .dialog-header h3 {
    color: var(--md-sys-color-on-surface);
    margin: 0;
    font-size: 20px;
  }

  .dialog-close {
    background: none;
    border: none;
    font-size: 28px;
    line-height: 1;
    cursor: pointer;
    color: var(--md-sys-color-on-surface-variant);
    padding: 0;
    width: 40px;
    height: 40px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .dialog-close:hover {
    color: var(--md-sys-color-on-surface);
  }

  .dialog-content {
    flex: 1;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 14px;
  }

  .dialog-footer {
    padding: 16px 20px;
    border-top: 1px solid var(--md-sys-color-outline-variant);
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }

  .btn-text {
    background: none;
    border: none;
    color: var(--md-sys-color-primary);
    cursor: pointer;
    padding: 8px 16px;
    border-radius: 8px;
    font-family: inherit;
    font-size: 13px;
    font-weight: 600;
    transition: background 0.15s;
  }

  .btn-text:hover {
    background: var(--md-sys-color-primary-container);
  }

  .btn-text:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  textarea.input-field {
    resize: vertical;
    font-family: inherit;
  }

  /* Warning dialog styling */
  .warning-title {
    display: flex;
    align-items: center;
    gap: 8px;
    color: #f57f17;
  }

  .warning-title .material-symbols-outlined {
    font-size: 24px;
  }

  .warning-text {
    color: var(--md-sys-color-on-surface);
    margin: 0;
    line-height: 1.5;
  }

  .secondary-text {
    color: var(--md-sys-color-on-surface-variant);
    margin: 8px 0 0;
  }

  .btn-warning {
    background: #ff9800;
    color: white;
  }

  .btn-warning:hover {
    opacity: 0.9;
  }
</style>
