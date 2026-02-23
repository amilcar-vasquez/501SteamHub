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
    try {
      const result = await adminAPI.updateUserRole(user.user_id, parseInt(newRoleId), token);
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
    padding: 8px 12px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    color: var(--md-sys-color-on-surface-variant);
    white-space: nowrap;
  }

  .user-table td {
    padding: 12px 12px;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    vertical-align: middle;
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
    padding: 5px 8px;
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
</style>
