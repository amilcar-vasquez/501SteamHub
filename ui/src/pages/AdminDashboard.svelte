<!-- filename: ui/src/pages/AdminDashboard.svelte -->
<script>
  import { onMount } from 'svelte';
  import { currentUser, authToken } from '../stores/auth.js';
  import { navigateTo } from '../router.js';
  import { adminAPI } from '../api/client.js';
  import TopAppBar from '../components/TopAppBar.svelte';
  import ResourceAdminTable from '../lib/components/admin/ResourceAdminTable.svelte';
  import UserAdminTable from '../lib/components/admin/UserAdminTable.svelte';

  const ADMIN_ROLES = ['admin', 'DSC'];

  let token = null;
  authToken.subscribe(v => (token = v));

  // Metrics state
  let metrics = null;
  let metricsLoading = true;
  let metricsError = '';

  const METRIC_CARDS = [
    { key: 'total_users',     label: 'Users',      icon: 'group',       colorClass: 'mc-users'     },
    { key: 'total_resources', label: 'Resources',  icon: 'folder_open', colorClass: 'mc-resources' },
    { key: 'submitted',       label: 'Submitted',  icon: 'upload_file', colorClass: 'mc-submitted' },
    { key: 'approved',        label: 'Approved',   icon: 'check_circle',colorClass: 'mc-approved'  },
    { key: 'published',       label: 'Published',  icon: 'public',      colorClass: 'mc-published' },
    { key: 'archived',        label: 'Archived',   icon: 'inventory_2', colorClass: 'mc-archived'  },
  ];

  // Route guard — block non-admin/DSC immediately
  onMount(async () => {
    const user = $currentUser;
    if (!user || !ADMIN_ROLES.includes(user.role_name)) {
      navigateTo('/');
      return;
    }
    await loadMetrics();
  });

  // Reactive guard in case the store changes after mount
  $: if ($currentUser !== undefined && $currentUser !== null) {
    if (!ADMIN_ROLES.includes($currentUser.role_name)) {
      navigateTo('/');
    }
  }

  async function loadMetrics() {
    metricsLoading = true;
    metricsError = '';
    try {
      const data = await adminAPI.getMetrics(token);
      metrics = data.metrics;
    } catch (err) {
      metricsError = err.message || 'Failed to load metrics.';
    } finally {
      metricsLoading = false;
    }
  }

  $: greeting = $currentUser
    ? `Welcome back, ${$currentUser.username}`
    : 'Admin Dashboard';
</script>

<div class="dashboard">
  <TopAppBar />

  <main class="dashboard-content">
    <!-- ── Header ──────────────────────────────────────────────────────────── -->
    <header class="page-header">
      <div class="header-text">
        <h1 class="headline-medium page-title">Admin Dashboard</h1>
        <p class="body-large greeting">{greeting}</p>
      </div>
      <div class="role-chip label-medium">
        <span class="material-symbols-outlined">admin_panel_settings</span>
        {$currentUser?.role_name ?? ''}
      </div>
    </header>

    <!-- ── Metrics Row ─────────────────────────────────────────────────────── -->
    <section class="metrics-section" aria-label="Admin metrics">
      {#if metricsLoading}
        {#each METRIC_CARDS as _}
          <div class="metric-card metric-skeleton">
            <div class="skeleton-icon"></div>
            <div class="skeleton-count"></div>
            <div class="skeleton-label"></div>
          </div>
        {/each}
      {:else if metricsError}
        <div class="metrics-error body-medium">
          <span class="material-symbols-outlined">warning</span>
          {metricsError}
          <button class="retry-btn label-medium" on:click={loadMetrics}>Retry</button>
        </div>
      {:else}
        {#each METRIC_CARDS as card}
          <div class="metric-card {card.colorClass}">
            <span class="material-symbols-outlined metric-icon">{card.icon}</span>
            <span class="metric-count">{metrics?.[card.key] ?? 0}</span>
            <span class="metric-label label-medium">{card.label}</span>
          </div>
        {/each}
      {/if}
    </section>

    <!-- ── Resource Admin Panel ────────────────────────────────────────────── -->
    <ResourceAdminTable />

    <!-- ── User Management Panel ──────────────────────────────────────────── -->
    <UserAdminTable />
  </main>
</div>

<style>
  .dashboard {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background: var(--md-sys-color-background);
  }

  .dashboard-content {
    flex: 1;
    padding: 24px;
    max-width: 1440px;
    margin: 0 auto;
    width: 100%;
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  /* ── Header ── */
  .page-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 16px;
    flex-wrap: wrap;
  }

  .page-title {
    color: var(--md-sys-color-on-surface);
    font-size: 28px;
    font-weight: 400;
    margin: 0 0 4px;
  }

  .greeting {
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
  }

  .role-chip {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 16px;
    border-radius: 20px;
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    font-weight: 600;
  }
  .role-chip .material-symbols-outlined { font-size: 18px; }

  /* ── Metrics ── */
  .metrics-section {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 12px;
  }

  @media (max-width: 1200px) { .metrics-section { grid-template-columns: repeat(3, 1fr); } }
  @media (max-width: 600px)  { .metrics-section { grid-template-columns: repeat(2, 1fr); } }

  .metric-card {
    border-radius: 16px;
    padding: 20px 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    text-align: center;
  }

  .metric-icon   { font-size: 28px; }
  .metric-count  { font-size: 32px; font-weight: 600; line-height: 1; }
  .metric-label  { opacity: 0.75; }

  /* Per-card colour tokens */
  .mc-users     { background: #e8eaf6; color: #1a237e; }
  .mc-resources { background: #f3e5f5; color: #4a148c; }
  .mc-submitted { background: #e3f2fd; color: #0d47a1; }
  .mc-approved  { background: #e8f5e9; color: #1b5e20; }
  .mc-published { background: #e0f7fa; color: #006064; }
  .mc-archived  { background: #efebe9; color: #3e2723; }

  /* Skeleton shimmer */
  .metric-skeleton {
    background: var(--md-sys-color-surface-variant);
    animation: shimmer 1.4s infinite;
  }
  .skeleton-icon, .skeleton-count, .skeleton-label {
    background: rgba(0,0,0,.1);
    border-radius: 4px;
  }
  .skeleton-icon  { width: 28px; height: 28px; border-radius: 50%; }
  .skeleton-count { width: 48px; height: 32px; }
  .skeleton-label { width: 72px; height: 14px; }

  @keyframes shimmer {
    0%  { opacity: 1;   }
    50% { opacity: 0.5; }
    100%{ opacity: 1;   }
  }

  /* Metrics error state */
  .metrics-error {
    grid-column: 1 / -1;
    display: flex;
    align-items: center;
    gap: 8px;
    color: var(--md-sys-color-error);
    padding: 16px;
  }
  .retry-btn {
    background: none; border: none; cursor: pointer;
    color: var(--md-sys-color-primary); text-decoration: underline; font-family: inherit;
  }
</style>
