<script>
  import { onMount } from 'svelte';
  import { currentUser } from '../stores/auth.js';
  import { navigateTo } from '../router.js';
  import TopAppBar from '../components/TopAppBar.svelte';
  import MetricsRow from '../lib/components/dashboard/MetricsRow.svelte';
  import ReviewFilters from '../lib/components/dashboard/ReviewFilters.svelte';
  import ReviewQueueGrid from '../lib/components/dashboard/ReviewQueueGrid.svelte';

  // Roles allowed to access this dashboard
  const REVIEWER_ROLES = ['SubjectExpert', 'TeamLead', 'DSC', 'admin'];

  let filters = { subject: '', grade_level: '', status: '' };
  let searchQuery = '';
  let isMobileFilterOpen = false;

  // Role guard — redirect non-reviewers to home immediately
  onMount(() => {
    const user = $currentUser;
    if (!user || !REVIEWER_ROLES.includes(user.role_name)) {
      navigateTo('/');
    }
  });

  // Also guard reactively in case the store changes after mount
  $: if ($currentUser !== undefined && $currentUser !== null) {
    if (!REVIEWER_ROLES.includes($currentUser.role_name)) {
      navigateTo('/');
    }
  }

  function handleFilterChange(event) {
    filters = event.detail;
  }

  $: greeting = $currentUser
    ? `Welcome back, ${$currentUser.username}`
    : 'Reviewer Dashboard';

  $: roleLabel = $currentUser?.role_name ?? '';
</script>

<div class="dashboard">
  <TopAppBar bind:searchQuery on:toggleFilter={() => (isMobileFilterOpen = !isMobileFilterOpen)} />

  <main class="dashboard-content">
    <!-- ── Header ─────────────────────────────────────────────────────────── -->
    <header class="page-header">
      <div class="header-text">
        <h1 class="headline-medium page-title">Reviewer Dashboard</h1>
        <p class="body-large greeting">{greeting}</p>
      </div>
      <div class="role-chip label-medium">
        <span class="material-symbols-outlined">verified_user</span>
        {roleLabel}
      </div>
    </header>

    <!-- ── Metrics Row ────────────────────────────────────────────────────── -->
    <MetricsRow />

    <!-- ── Filters Row ────────────────────────────────────────────────────── -->
    <ReviewFilters on:filterChange={handleFilterChange} />

    <!-- ── Review Queue ───────────────────────────────────────────────────── -->
    <ReviewQueueGrid {filters} />
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
  }

  /* ── Header ── */
  .page-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 24px;
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
    padding: 8px 16px;
    border-radius: 999px;
    background: var(--md-sys-color-primary-container);
    color: var(--md-sys-color-on-primary-container);
    border: 1px solid var(--md-sys-color-outline-variant);
    white-space: nowrap;
  }
  .role-chip .material-symbols-outlined {
    font-size: 16px;
  }

  @media (max-width: 600px) {
    .dashboard-content { padding: 16px; }
    .page-header       { flex-direction: column; }
  }
</style>
