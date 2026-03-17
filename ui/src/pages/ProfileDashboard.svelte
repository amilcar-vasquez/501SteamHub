<!-- filename: ui/src/pages/ProfileDashboard.svelte -->
<script>
  import { onMount } from 'svelte';
  import { tweened } from 'svelte/motion';
  import { cubicOut } from 'svelte/easing';
  import { fade } from 'svelte/transition';
  import { currentUser, authToken } from '../stores/auth.js';
  import { bookmarkedResourceIds, toggleBookmark } from '../stores/bookmarks.js';
  import { navigateTo } from '../router.js';
  import { userAPI, resourceAPI, fellowAPI } from '../api/client.js';
  import TopAppBar from '../components/TopAppBar.svelte';
  import TextField from '../components/TextField.svelte';
  import Button from '../components/Button.svelte';
  import FilterChip from '../components/FilterChip.svelte';
  import ResourceCard from '../components/ResourceCard.svelte';

  // ── State ─────────────────────────────────────────────────────────────────
  let user = null;
  let fellow = null;
  let resources = [];
  let filteredResources = [];
  let isFellow = false;
  let isLoading = true;
  let isSaving = false;
  let error = '';
  let successMessage = '';

  // Tab navigation state
  let activeTab = 'overview'; // 'overview', 'resources', 'bookmarks', 'settings'

  // Bookmarked resources
  let bookmarkedResources = [];

  // Resource filtering
  let selectedCategories = new Set();
  const categoryOptions = [
    { value: 'Lesson Plan', label: 'Lesson Plan' },
    { value: 'Video', label: 'Video' },
    { value: 'Slideshow', label: 'Slideshow' },
    { value: 'Assessment', label: 'Assessment' },
  ];

  // Account settings form
  let settingsForm = {
    username: '',
    password: '',
    passwordConfirm: '',
  };
  let passwordValidation = {
    isValid: true,
    message: '',
  };

  // Tweened STEAM Points (for animation)
  const steamPointsDisplay = tweened(0, {
    duration: 1800,
    easing: cubicOut,
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  onMount(async () => {
    console.log('ProfileDashboard - Current User:', $currentUser);
    console.log('ProfileDashboard - Auth Token:', !!$authToken);

    if (!$currentUser || !$authToken) {
      navigateTo('/signin');
      return;
    }

    // Ensure user has required properties
    if (!$currentUser.user_id && !$currentUser.id) {
      error = 'User session is invalid. Please sign in again.';
      setTimeout(() => navigateTo('/signin'), 1500);
      return;
    }

    // Load bookmarked resources on mount
    loadBookmarkedResources();

    await loadUserData();
  });

  // ── API Calls ──────────────────────────────────────────────────────────────
  async function loadUserData() {
    try {
      isLoading = true;
      error = '';
      const userId = getUserId();

      // Fetch user data - gracefully handle permission errors
      try {
        const userData = await userAPI.getUser(userId, $authToken);
        user = userData.user || userData;
      } catch (err) {
        // If user fetch fails (e.g., permission denied), use current user from auth store
        console.log('Using auth store user data due to API error:', err.message);
        user = $currentUser;
      }

      // Fetch user resources
      await loadUserResources();

      // Check if user has fellow profile
      try {
        const fellowData = await fellowAPI.getByUserId(userId, $authToken);
        fellow = fellowData.fellow || fellowData;
        isFellow = !!fellow && fellow.profile_status !== 'rejected';
        
        // Trigger STEAM Points animation
        if (fellow && fellow.steam_points) {
          steamPointsDisplay.set(fellow.steam_points);
        }
      } catch (e) {
        // User is not a fellow yet
        isFellow = false;
        steamPointsDisplay.set(0);
      }

      // Pre-populate settings form
      if (user) {
        settingsForm.username = user.username || '';
      }
    } catch (err) {
      error = 'Failed to load profile data: ' + err.message;
      console.error(err);
    } finally {
      isLoading = false;
    }
  }

  async function loadUserResources() {
    try {
      const userId = getUserId();
      
      // Try to load resources - will fail gracefully for regular users
      // who don't have permission to view their resource submissions
      try {
        const data = await resourceAPI.getAll({ contributor: userId });
        resources = data.resources || [];
      } catch (err) {
        // User likely doesn't have permission (e.g., regular User role)
        // This is expected behavior - regular users shouldn't see resources tab
        console.log('Note: User cannot view submitted resources (expected for regular users)');
        resources = [];
      }
      
      applyResourceFilters();
    } catch (err) {
      console.error('Failed to load resources:', err);
      resources = [];
    }
  }

  async function handleSaveSettings() {
    try {
      isSaving = true;
      error = '';
      successMessage = '';

      // Validate password
      if (settingsForm.password) {
        if (settingsForm.password !== settingsForm.passwordConfirm) {
          passwordValidation.isValid = false;
          passwordValidation.message = 'Passwords do not match';
          isSaving = false;
          return;
        }
        if (settingsForm.password.length < 8) {
          passwordValidation.isValid = false;
          passwordValidation.message = 'Password must be at least 8 characters';
          isSaving = false;
          return;
        }
      }

      const updateData = { username: settingsForm.username };
      if (settingsForm.password) {
        updateData.password = settingsForm.password;
      }

      await userAPI.update(userId, updateData, $authToken);
      successMessage = 'Settings updated successfully!';
      settingsForm.password = '';
      settingsForm.passwordConfirm = '';
      passwordValidation.isValid = true;

      // Reset message after 3 seconds
      setTimeout(() => {
        successMessage = '';
      }, 3000);
    } catch (err) {
      error = 'Failed to save settings: ' + err.message;
      console.error(err);
    } finally {
      isSaving = false;
    }
  }

  // ── Resource Filtering ─────────────────────────────────────────────────────
  function toggleCategory(category) {
    if (selectedCategories.has(category)) {
      selectedCategories.delete(category);
    } else {
      selectedCategories.add(category);
    }
    selectedCategories = selectedCategories; // Trigger reactivity
    applyResourceFilters();
  }

  function applyResourceFilters() {
    if (selectedCategories.size === 0) {
      filteredResources = resources;
    } else {
      filteredResources = resources.filter(r =>
        selectedCategories.has(r.category)
      );
    }
  }

  // ── Bookmark Functions ────────────────────────────────────────────────────
  function loadBookmarkedResources() {
    // Subscribe to bookmarks store and update displayed resources
    // This handles real-time updates when bookmarks change
    bookmarkedResourceIds.subscribe(bookmarks => {
      // For now, we use cached resources from the profile data if available
      // In a real app, we could fetch full details from API for all bookmarked IDs
      bookmarkedResources = resources.filter(r => bookmarks.has(r.resource_id));
    });
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  function getUserId() {
    // Support both user_id (from API) and id (potential alternative format)
    return $currentUser?.user_id || $currentUser?.id;
  }

  function getInitials(name) {
    return name
      ? name
          .split(' ')
          .map(word => word[0])
          .join('')
          .toUpperCase()
      : '?';
  }

  function getContributionStats() {
    return {
      totalSubmissions: resources.length,
      approvedCount: resources.filter(r => r.status === 'Approved').length,
      verificationRate: resources.length > 0
        ? Math.round((resources.filter(r => r.status === 'Approved').length / resources.length) * 100)
        : 0,
    };
  }
</script>

<TopAppBar />

<main class="profile-container">
  {#if isLoading}
    <div class="hero-skeleton">
      <div class="hero-loading-spinner"></div>
    </div>
  {:else if error}
    <div class="error-banner">
      <p>{error}</p>
      <Button variant="filled" on:click={() => location.reload()}>Retry</Button>
    </div>
  {:else if user}
    <!-- ─ HERO SECTION ────────────────────────────────────────────────────────── -->
    <section class="hero" style="background-color: color-mix(in srgb, var(--md-sys-color-primary) 8%, var(--md-sys-color-background));">
      <div class="hero-content">
        <!-- Avatar -->
        <div class="avatar">
          {getInitials(user.username)}
        </div>

        <!-- Name & Title -->
        <div class="hero-info">
          <h1 class="headline-large">{user.username}</h1>
          {#if isFellow && fellow}
            <p class="label-large fellow-badge">⭐ 501 STEAM Fellow</p>
          {/if}
        </div>

        <!-- STEAM Points Card (Elevated) -->
        <div class="steam-points-card">
          <div class="points-display">
            <span class="points-value">{$steamPointsDisplay.toFixed(0)}</span>
            <span class="points-label">501 STEAM Points</span>
          </div>
          <span class="material-symbols-outlined points-icon">trending_up</span>
        </div>
      </div>
    </section>

    <!-- ─ TAB NAVIGATION ──────────────────────────────────────────────────────── -->
    <nav class="tab-navigation">
      <button
        class="tab"
        class:active={activeTab === 'overview'}
        on:click={() => (activeTab = 'overview')}
      >
        <span class="material-symbols-outlined">person</span>
        <span>Overview</span>
      </button>
      {#if isFellow}
        <button
          class="tab"
          class:active={activeTab === 'resources'}
          on:click={() => (activeTab = 'resources')}
        >
          <span class="material-symbols-outlined">collections</span>
          <span>My Resources</span>
        </button>
      {/if}
      <button
        class="tab"
        class:active={activeTab === 'bookmarks'}
        on:click={() => (activeTab = 'bookmarks')}
      >
        <span class="material-symbols-outlined">bookmark</span>
        <span>Bookmarks</span>
      </button>
      <button
        class="tab"
        class:active={activeTab === 'settings'}
        on:click={() => (activeTab = 'settings')}
      >
        <span class="material-symbols-outlined">settings</span>
        <span>Settings</span>
      </button>
    </nav>

    <!-- ─ TAB CONTENT ───────────────────────────────────────────────────────── -->
    <div class="tab-content">
      <!-- OVERVIEW TAB -->
      {#if activeTab === 'overview'}
        <div class="tab-panel" transition:fade={{ duration: 300 }}>
          {#if isFellow && fellow}
            <!-- Fellow Status Card -->
            <div class="status-card" style="background-color: var(--md-sys-color-success-container); border-left: 4px solid var(--md-sys-color-success);">
              <div class="status-icon">✓</div>
              <div>
                <p class="title-medium">Fellow Status</p>
                <p class="body-medium">You are an approved 501 STEAM Fellow</p>
              </div>
            </div>

            <!-- Impact Stats Grid -->
            <div class="stats-grid">
              <div class="stat-card">
                <div class="stat-value">{getContributionStats().totalSubmissions}</div>
                <div class="stat-label">Total Submissions</div>
              </div>
              <div class="stat-card">
                <div class="stat-value">{getContributionStats().verificationRate}%</div>
                <div class="stat-label">Approval Rate</div>
              </div>
              <div class="stat-card">
                <div class="stat-value">{fellow.steam_points?.toFixed(1) || '0'}</div>
                <div class="stat-label">STEAM Points</div>
              </div>
            </div>

            <!-- Fellow Profile Section -->
            {#if fellow}
              <div class="profile-section">
                <h2 class="title-large">Profile Information</h2>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="label-medium">School</span>
                    <p class="body-medium">{fellow.school || 'Not specified'}</p>
                  </div>
                  <div class="info-item">
                    <span class="label-medium">Subject Specialization</span>
                    <p class="body-medium">{fellow.subject_specialization || 'Not specified'}</p>
                  </div>
                  <div class="info-item">
                    <span class="label-medium">District</span>
                    <p class="body-medium">{fellow.district || 'Not specified'}</p>
                  </div>
                </div>
              </div>
            {/if}
          {:else}
            <!-- Non-Fellow CTA Card -->
            <div class="cta-card">
              <div class="cta-icon">🚀</div>
              <h2 class="headline-medium">Become a 501 STEAM Fellow</h2>
              <p class="body-large">
                Join our community of educators and start earning STEAM Points for your educational contributions. Fellows get recognition, exclusive resources, and the ability to track their impact.
              </p>
              <Button variant="filled" on:click={() => navigateTo('/dashboard/apply-fellow')}>
                Apply Now (FR-33)
              </Button>
            </div>

            <!-- Limited Stats for Non-Fellows -->
            {#if resources.length > 0}
              <div class="stats-grid">
                <div class="stat-card">
                  <div class="stat-value">{getContributionStats().totalSubmissions}</div>
                  <div class="stat-label">Resources Submitted</div>
                </div>
                <div class="stat-card">
                  <div class="stat-value">{getContributionStats().approvedCount}</div>
                  <div class="stat-label">Approved</div>
                </div>
              </div>
            {/if}
          {/if}
        </div>

        <!-- MY RESOURCES TAB -->
      {:else if activeTab === 'resources'}
        <div class="tab-panel" transition:fade={{ duration: 300 }}>
          {#if resources.length > 0}
            <!-- Filter Chips -->
            <div class="filter-section">
              <h3 class="label-large">Filter by Category</h3>
              <div class="chips-container">
                {#each categoryOptions as category}
                  <FilterChip
                    label={category.label}
                    selected={selectedCategories.has(category.value)}
                    on:click={() => toggleCategory(category.value)}
                  />
                {/each}
              </div>
              <p class="body-medium" style="margin-top: 8px; color: var(--md-sys-color-on-surface-variant);">
                {filteredResources.length} of {resources.length} resources
              </p>
            </div>

            <!-- Resource Grid -->
            {#if filteredResources.length > 0}
              <div class="resources-grid">
                {#each filteredResources as resource (resource.resource_id)}
                  <ResourceCard
                    id={resource.resource_id}
                    category={resource.category}
                    title={resource.title}
                    description={resource.summary}
                    subject={resource.subjects?.[0]}
                    subjects={resource.subjects}
                    grade={resource.grade_levels?.[0]}
                    grades={resource.grade_levels}
                    contributor={resource.contributor_name}
                    viewCount={resource.view_count}
                    status={resource.status}
                    showStatus={true}
                    slug={resource.slug}
                  />
                {/each}
              </div>
            {:else}
              <div class="empty-state">
                <span class="material-symbols-outlined">filter_alt_off</span>
                <p class="headline-medium">No resources match these filters</p>
              </div>
            {/if}
          {:else}
            <div class="empty-state">
              <span class="material-symbols-outlined">collections</span>
              <p class="headline-medium">No resources yet</p>
              <p class="body-medium">Start creating and sharing educational resources</p>
              <Button variant="filled" on:click={() => navigateTo('/submit')}>
                Submit a Resource
              </Button>
            </div>
          {/if}
        </div>

        <!-- BOOKMARKED RESOURCES TAB -->
      {:else if activeTab === 'bookmarks'}
        <div class="tab-panel" transition:fade={{ duration: 300 }}>
          {#if bookmarkedResources.length > 0}
            <div class="resources-grid">
              {#each bookmarkedResources as resource (resource.resource_id)}
                <ResourceCard
                  id={resource.resource_id}
                  category={resource.category}
                  title={resource.title}
                  description={resource.summary}
                  subject={resource.subjects?.[0]}
                  subjects={resource.subjects}
                  grade={resource.grade_levels?.[0]}
                  grades={resource.grade_levels}
                  status={resource.status}
                  avgRating={resource.avg_rating}
                  reviewCount={resource.review_count}
                  isBookmarked={true}
                  on:bookmark={() => toggleBookmark(resource.resource_id)}
                  slug={resource.slug}
                />
              {/each}
            </div>
          {:else}
            <div class="empty-state">
              <span class="material-symbols-outlined">bookmark</span>
              <p class="headline-medium">No Bookmarked Resources</p>
              <p class="body-medium">
                Save your favorite resources to access them quickly. Visit the home page to start adding bookmarks!
              </p>
              <Button variant="filled" on:click={() => navigateTo('/')}>
                Explore Resources
              </Button>
            </div>
          {/if}
        </div>

        <!-- ACCOUNT SETTINGS TAB -->
      {:else if activeTab === 'settings'}
        <div class="tab-panel" transition:fade={{ duration: 300 }}>
          <div class="settings-section">
            <h2 class="headline-medium">Account Settings</h2>

            {#if successMessage}
              <div class="success-banner">
                <span class="material-symbols-outlined">check_circle</span>
                <p>{successMessage}</p>
              </div>
            {/if}

            {#if error}
              <div class="error-banner">
                <span class="material-symbols-outlined">error</span>
                <p>{error}</p>
              </div>
            {/if}

            <form on:submit|preventDefault={handleSaveSettings} class="settings-form">
              <!-- Username Field -->
              <TextField
                label="Username"
                type="text"
                bind:value={settingsForm.username}
                required
                placeholder="Enter username"
              />

              <!-- Password Field -->
              <TextField
                label="New Password (Optional)"
                type="password"
                bind:value={settingsForm.password}
                placeholder="Leave blank to keep current password"
                helperText="Must be at least 8 characters"
              />

              <!-- Password Confirm -->
              <TextField
                label="Confirm Password"
                type="password"
                bind:value={settingsForm.passwordConfirm}
                placeholder="Re-enter new password"
                error={!passwordValidation.isValid && settingsForm.password !== ''}
                helperText={!passwordValidation.isValid ? passwordValidation.message : ''}
              />

              <!-- Save Button -->
              <div class="button-group">
                <Button
                  variant="filled"
                  type="submit"
                  disabled={isSaving}
                >
                  {isSaving ? 'Saving...' : 'Save Changes'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      {/if}
    </div>
  {/if}
</main>

<style>
  .profile-container {
    min-height: 100vh;
    background-color: var(--md-sys-color-background);
  }

  /* ── HERO SECTION ──────────────────────────────────────────────────────────── */
  .hero {
    padding: 48px 24px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .hero-content {
    display: flex;
    align-items: center;
    gap: 32px;
    max-width: 1200px;
  }

  .avatar {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--md-sys-color-primary), var(--md-sys-color-secondary));
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 48px;
    font-weight: 700;
    flex-shrink: 0;
    box-shadow: var(--md-sys-elevation-3);
  }

  .hero-info {
    flex: 1;
    min-width: 0;
  }

  .headline-large {
    margin: 0;
    font-size: var(--md-sys-typescale-headline-large-size);
    font-weight: var(--md-sys-typescale-headline-large-weight);
    line-height: var(--md-sys-typescale-headline-large-line-height);
    color: var(--md-sys-color-on-background);
    word-break: break-word;
  }

  .fellow-badge {
    margin-top: 8px;
    color: var(--md-sys-color-primary);
    display: inline-block;
  }

  /* STEAM Points Card */
  .steam-points-card {
    background: linear-gradient(135deg, var(--md-sys-color-primary-container), var(--md-sys-color-secondary-container));
    border-radius: 12px;
    padding: 24px 32px;
    display: flex;
    align-items: center;
    gap: 24px;
    box-shadow: var(--md-sys-elevation-2);
    min-width: 240px;
    flex-shrink: 0;
  }

  .points-display {
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .points-value {
    font-size: 48px;
    font-weight: 700;
    color: var(--md-sys-color-primary);
    line-height: 1;
  }

  .points-label {
    font-size: var(--md-sys-typescale-label-large-size);
    color: var(--md-sys-color-on-surface-variant);
    margin-top: 8px;
  }

  .points-icon {
    color: var(--md-sys-color-secondary);
    font-size: 32px;
  }

  /* ── TAB NAVIGATION ────────────────────────────────────────────────────────── */
  .tab-navigation {
    display: flex;
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    padding: 0 24px;
    gap: 8px;
    max-width: 1200px;
    margin: 0 auto;
    background-color: var(--md-sys-color-surface);
  }

  .tab {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 16px 12px;
    background: none;
    border: none;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    color: var(--md-sys-color-on-surface-variant);
    font-family: var(--md-sys-typescale-label-large-font);
    font-size: var(--md-sys-typescale-label-large-size);
    font-weight: var(--md-sys-typescale-label-large-weight);
    transition: all 200ms ease;
  }

  .tab:hover {
    color: var(--md-sys-color-on-surface);
    background-color: color-mix(in srgb, var(--md-sys-color-primary) 8%, transparent);
  }

  .tab.active {
    color: var(--md-sys-color-primary);
    border-bottom-color: var(--md-sys-color-primary);
  }

  .tab .material-symbols-outlined {
    font-size: 20px;
  }

  /* ── TAB CONTENT ───────────────────────────────────────────────────────────── */
  .tab-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 32px 24px;
  }

  .tab-panel {
    animation: fadeIn 300ms ease;
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  /* ── STATUS CARD ────────────────────────────────────────────────────────────── */
  .status-card {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 20px;
    border-radius: 12px;
    background-color: var(--md-sys-color-success-container);
    margin-bottom: 32px;
  }

  .status-icon {
    font-size: 32px;
    color: var(--md-sys-color-success);
    font-weight: 700;
    min-width: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  /* ── STATS GRID ────────────────────────────────────────────────────────────── */
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
    margin-bottom: 32px;
  }

  .stat-card {
    background-color: var(--md-sys-color-surface-container-low);
    border-radius: 12px;
    padding: 24px;
    text-align: center;
    border: 1px solid var(--md-sys-color-outline-variant);
  }

  .stat-value {
    font-size: 32px;
    font-weight: 700;
    color: var(--md-sys-color-primary);
    line-height: 1.2;
  }

  .stat-label {
    font-size: var(--md-sys-typescale-label-large-size);
    color: var(--md-sys-color-on-surface-variant);
    margin-top: 8px;
  }

  /* ── PROFILE SECTION ───────────────────────────────────────────────────────── */
  .profile-section {
    background-color: var(--md-sys-color-surface-container-low);
    border-radius: 12px;
    padding: 24px;
    margin-bottom: 32px;
  }

  .profile-section .title-large {
    margin-top: 0;
    margin-bottom: 24px;
  }

  .info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 24px;
  }

  .info-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .info-item .label-medium {
    color: var(--md-sys-color-on-surface-variant);
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .info-item .body-medium {
    margin: 0;
    color: var(--md-sys-color-on-surface);
  }

  /* ── CTA CARD ──────────────────────────────────────────────────────────────── */
  .cta-card {
    background: linear-gradient(
      135deg,
      color-mix(in srgb, var(--md-sys-color-primary) 8%, var(--md-sys-color-surface)),
      color-mix(in srgb, var(--md-sys-color-secondary) 8%, var(--md-sys-color-surface))
    );
    border: 2px dashed var(--md-sys-color-primary);
    border-radius: 12px;
    padding: 48px 24px;
    text-align: center;
    margin-bottom: 32px;
  }

  .cta-icon {
    font-size: 64px;
    margin-bottom: 16px;
  }

  .cta-card .headline-medium {
    margin: 16px 0;
  }

  .cta-card .body-large {
    color: var(--md-sys-color-on-surface);
    margin: 16px 0 24px;
  }

  /* ── FILTERS ───────────────────────────────────────────────────────────────── */
  .filter-section {
    margin-bottom: 32px;
  }

  .filter-section .label-large {
    display: block;
    margin-bottom: 16px;
  }

  .chips-container {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 16px;
  }

  /* ── RESOURCES GRID ────────────────────────────────────────────────────────── */
  .resources-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 24px;
  }

  /* ── EMPTY STATE ───────────────────────────────────────────────────────────── */
  .empty-state {
    text-align: center;
    padding: 64px 24px;
    color: var(--md-sys-color-on-surface-variant);
  }

  .empty-state .material-symbols-outlined {
    font-size: 64px;
    display: block;
    margin-bottom: 16px;
    color: var(--md-sys-color-outline);
  }

  .empty-state .headline-medium {
    color: var(--md-sys-color-on-surface);
    margin: 0 0 8px;
  }

  .empty-state .body-medium {
    margin: 0 0 24px;
  }

  /* ── SETTINGS SECTION ──────────────────────────────────────────────────────── */
  .settings-section {
    max-width: 500px;
  }

  .settings-section .headline-medium {
    margin-top: 0;
    margin-bottom: 32px;
  }

  .settings-form {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .button-group {
    display: flex;
    gap: 12px;
    margin-top: 24px;
  }

  /* ── SUCCESS/ERROR BANNERS ─────────────────────────────────────────────────── */
  .success-banner,
  .error-banner {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 24px;
    font-size: var(--md-sys-typescale-body-medium-size);
  }

  .success-banner {
    background-color: var(--md-sys-color-success-container);
    color: var(--md-sys-color-on-surface);
  }

  .success-banner .material-symbols-outlined {
    color: var(--md-sys-color-success);
    flex-shrink: 0;
  }

  .error-banner {
    background-color: var(--md-sys-color-error-container);
    color: var(--md-sys-color-on-surface);
  }

  .error-banner .material-symbols-outlined {
    color: var(--md-sys-color-error);
    flex-shrink: 0;
  }

  /* ── SKELETON LOADERS ──────────────────────────────────────────────────────── */
  .hero-skeleton {
    padding: 64px 24px;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 300px;
  }

  .hero-loading-spinner {
    width: 48px;
    height: 48px;
    border: 4px solid var(--md-sys-color-outline-variant);
    border-top-color: var(--md-sys-color-primary);
    border-radius: 50%;
    animation: spin 0.8s linear infinite;
  }

  @keyframes spin {
    to {
      transform: rotate(360deg);
    }
  }

  /* ── RESPONSIVE ────────────────────────────────────────────────────────────── */
  @media (max-width: 768px) {
    .hero-content {
      flex-direction: column;
      gap: 24px;
      text-align: center;
    }

    .steam-points-card {
      min-width: auto;
      width: 100%;
    }

    .tab-navigation {
      padding: 0 12px;
      gap: 4px;
      overflow-x: auto;
    }

    .tab {
      font-size: 12px;
      padding: 12px 8px;
      white-space: nowrap;
    }

    .tab span:not(.material-symbols-outlined) {
      display: none;
    }

    .tab-content {
      padding: 24px 12px;
    }

    .stats-grid {
      grid-template-columns: 1fr;
    }

    .resources-grid {
      grid-template-columns: 1fr;
    }

    .cta-card {
      padding: 32px 16px;
    }
  }

  @media (max-width: 480px) {
    .hero {
      padding: 32px 16px;
    }

    .avatar {
      width: 80px;
      height: 80px;
      font-size: 36px;
    }

    .headline-large {
      font-size: 24px;
    }

    .steam-points-card {
      padding: 16px 20px;
    }

    .points-value {
      font-size: 36px;
    }
  }
</style>
