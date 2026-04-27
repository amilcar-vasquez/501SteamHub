<script>
  import { onMount } from 'svelte';
  import TopAppBar from '../components/TopAppBar.svelte';
  import TextField from '../components/TextField.svelte';
  import TextArea from '../components/TextArea.svelte';
  import MultiSelect from '../components/MultiSelect.svelte';
  import Button from '../components/Button.svelte';
  import { currentUser, authToken } from '../stores/auth.js';
  import { fellowApplicationAPI } from '../api/client.js';
  import { getApiBaseUrl } from '../lib/config/apiBaseUrl.js';
  import { navigateTo } from '../router.js';

  // ── Options (mirrored from SubmitResource.svelte) ─────────────────────────
  const gradeLevelOptions = [
    { value: 'Preschool', label: 'Preschool' },
    { value: 'Infant 1', label: 'Infant 1' },
    { value: 'Infant 2', label: 'Infant 2' },
    { value: 'Standard 1', label: 'Standard 1' },
    { value: 'Standard 2', label: 'Standard 2' },
    { value: 'Standard 3', label: 'Standard 3' },
    { value: 'Standard 4', label: 'Standard 4' },
    { value: 'Standard 5', label: 'Standard 5' },
    { value: 'Standard 6', label: 'Standard 6' },
    { value: 'Mixed', label: 'Mixed Grades' },
  ];

  const subjectOptions = [
    { value: 'Computer Science', label: '💻 Computer Science' },
    { value: 'Information Technology', label: '🖥️ Information Technology' },
    { value: 'Science and Technology', label: '🔬 Science and Technology' },
    { value: 'Engineering', label: '⚙️ Engineering' },
    { value: 'Robotics', label: '🤖 Robotics' },
    { value: 'Expressive Arts', label: '🎨 Expressive Arts' },
    { value: 'Belizean History', label: '🇧🇿 Belizean History' },
    { value: 'Mathematics', label: '➕ Mathematics' },
    { value: 'Language Arts', label: '📖 Language Arts' },
    { value: 'Social Studies', label: '🌍 Social Studies' },
    { value: 'Physical Education', label: '⚽ Physical Education' },
    { value: 'Health Education', label: '🏥 Health Education' },
  ];

  // ── State ─────────────────────────────────────────────────────────────────
  let formData = {
    first_name: '',
    last_name: '',
    bemis_number: '',
    organization: '',
    subjects: [],
    grade_levels: [],
    experience_years: 0,
    bio: '',
    credentials_link: '',
  };

  let errors = {};
  let loading = false;
  let submitError = '';
  let submitted = false;
  let uploadingFile = false;
  let moeDocFile = null;
  let fileUploadError = '';

  let existingApplication = null;
  let loadingExisting = true;

  // ── Auth + role guards ────────────────────────────────────────────────────
  const ALREADY_FELLOW_ROLES = ['Fellow', 'admin', 'DSC', 'SubjectExpert', 'TeamLead', 'Secretary'];
  $: alreadyFellow = $currentUser && ALREADY_FELLOW_ROLES.includes($currentUser.role_name);

  let token = null;
  authToken.subscribe(v => (token = v));

  onMount(async () => {
    if (!$currentUser) {
      navigateTo('/signin');
      return;
    }

    // Load any existing application status
    try {
      const data = await fellowApplicationAPI.getMyApplication(token);
      existingApplication = data.application || null;
    } catch {
      // 404 means no application yet — that's expected
      existingApplication = null;
    } finally {
      loadingExisting = false;
    }

    // Pre-fill names from user profile if available
    if ($currentUser.username) {
      const parts = $currentUser.username.trim().split(' ');
      formData.first_name = parts[0] || '';
      formData.last_name = parts.slice(1).join(' ') || '';
    }
  });

  // ── Validation ────────────────────────────────────────────────────────────
  function validateForm() {
    errors = {};

    if (!formData.first_name.trim()) {
      errors.first_name = 'First name is required';
    } else if (formData.first_name.length > 100) {
      errors.first_name = 'First name must be 100 characters or less';
    }

    if (!formData.last_name.trim()) {
      errors.last_name = 'Last name is required';
    } else if (formData.last_name.length > 100) {
      errors.last_name = 'Last name must be 100 characters or less';
    }

    if (!formData.bemis_number.trim()) {
      errors.bemis_number = 'BEMIS Number is required';
    } else if (formData.bemis_number.length > 50) {
      errors.bemis_number = 'BEMIS Number must be 50 characters or less';
    }

    if (!formData.organization.trim()) {
      errors.organization = 'Organization is required';
    } else if (formData.organization.length > 200) {
      errors.organization = 'Organization must be 200 characters or less';
    }

    if (formData.subjects.length === 0) {
      errors.subjects = 'Select at least one subject you teach';
    }

    if (formData.grade_levels.length === 0) {
      errors.grade_levels = 'Select at least one grade level you teach';
    }

    const years = parseInt(formData.experience_years, 10);
    if (isNaN(years) || years < 0) {
      errors.experience_years = 'Enter a valid number of years (0 or more)';
    } else if (years > 60) {
      errors.experience_years = 'Experience years seems too high';
    }

    if (!formData.bio.trim()) {
      errors.bio = 'Bio is required';
    } else if (formData.bio.trim().length < 50) {
      errors.bio = 'Bio must be at least 50 characters';
    }

    if (formData.credentials_link.trim()) {
      try {
        new URL(formData.credentials_link);
      } catch {
        errors.credentials_link = 'Enter a valid URL';
      }
    }

    // File validation (client-side, backend is final authority)
    if (!moeDocFile) {
      errors.moe_document = 'MOE verification document is required';
    } else {
      const maxSize = 5 * 1024 * 1024; // 5 MB
      if (moeDocFile.size > maxSize) {
        errors.moe_document = 'File must be smaller than 5MB';
      }
      const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png'];
      if (!allowedTypes.includes(moeDocFile.type)) {
        errors.moe_document = 'Only PDF, JPG, and PNG files are allowed';
      }
    }

    return Object.keys(errors).length === 0;
  }

  // ── File Handling ─────────────────────────────────────────────────────────
  function handleFileSelect(e) {
    const files = e.target.files;
    if (files && files.length > 0) {
      moeDocFile = files[0];
      fileUploadError = '';
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  async function handleSubmit() {
    if (!validateForm()) return;

    loading = true;
    submitError = '';
    fileUploadError = '';

    try {
      // Step 1: Upload MOE document first
      uploadingFile = true;
      const moeDocPath = await uploadMoeDocument();
      uploadingFile = false;

      if (!moeDocPath) {
        return; // Error already set in fileUploadError
      }

      // Step 2: Submit application with MOE document path
      const payload = {
        ...formData,
        experience_years: parseInt(formData.experience_years, 10),
        moe_doc_path: moeDocPath,
      };
      await fellowApplicationAPI.apply(payload, token);
      submitted = true;
    } catch (err) {
      submitError = err.message || 'Failed to submit application. Please try again.';
    } finally {
      loading = false;
      uploadingFile = false;
    }
  }

  // ── Upload MOE Document ────────────────────────────────────────────────────
  async function uploadMoeDocument() {
    if (!moeDocFile) {
      fileUploadError = 'No document selected';
      return null;
    }

    const formData = new FormData();
    formData.append('moe_document', moeDocFile);

    try {
      const apiUrl = getApiBaseUrl();
      const response = await fetch(`${apiUrl}/fellow-applications/moe-document/upload`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        body: formData,
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'File upload failed');
      }

      const data = await response.json();
      return data.storage_path;
    } catch (err) {
      fileUploadError = err.message || 'Failed to upload document. Please try again.';
      return null;
    }
  }
</script>

<div class="page">
  <TopAppBar />

  <main class="main-content">
    <div class="form-container">

      <!-- ── Already a Fellow ──────────────────────────────────────────── -->
      {#if alreadyFellow}
        <div class="status-card status-approved">
          <span class="material-symbols-outlined status-icon">verified</span>
          <div>
            <h2 class="title-large">You're already a Fellow!</h2>
            <p class="body-medium">Your account has the <strong>{$currentUser.role_name}</strong> role and can already submit resources.</p>
          </div>
          <Button variant="filled" on:click={() => navigateTo('/submit')}>
            Submit a Resource
          </Button>
        </div>

      <!-- ── Success state after submission ───────────────────────────── -->
      {:else if submitted}
        <div class="status-card status-approved">
          <span class="material-symbols-outlined status-icon">check_circle</span>
          <div>
            <h2 class="title-large">Application Submitted!</h2>
            <p class="body-medium">Your application is under review. You'll be notified once it's processed.</p>
          </div>
          <Button variant="outlined" on:click={() => navigateTo('/')}>
            Back to Home
          </Button>
        </div>

      <!-- ── Existing Pending application ─────────────────────────────── -->
      {:else if !loadingExisting && existingApplication && existingApplication.status === 'Pending'}
        <div class="status-card status-pending">
          <span class="material-symbols-outlined status-icon">hourglass_top</span>
          <div>
            <h2 class="title-large">Application Pending Review</h2>
            <p class="body-medium">
              You submitted an application on {new Date(existingApplication.created_at).toLocaleDateString()}.
              Our team will review it shortly.
            </p>
          </div>
          <Button variant="outlined" on:click={() => navigateTo('/')}>
            Back to Home
          </Button>
        </div>

      <!-- ── Existing Rejected application — allow re-apply ───────────── -->
      {:else if !loadingExisting && existingApplication && existingApplication.status === 'Rejected'}
        <div class="banner-error" role="alert">
          <span class="material-symbols-outlined">cancel</span>
          Your previous application was not approved. You may submit a new one below.
        </div>
        <!-- fall through to form below -->
        <!-- (application form is rendered outside this if-chain) -->
      {/if}

      <!-- ── Application Form (shown for User with no pending app, or after rejection) -->
      {#if !alreadyFellow && !submitted && !(existingApplication?.status === 'Pending')}
        {#if !loadingExisting}
          <div class="page-header">
            <span class="material-symbols-outlined header-icon">school</span>
            <div>
              <h1 class="display-small">Apply to Become a Fellow</h1>
              <p class="body-large subtitle">
                501 STEAM Hub Fellows are verified educators who can contribute resources to the platform.
                Tell us about yourself and your teaching experience.
              </p>
            </div>
          </div>

          <form class="application-form" on:submit|preventDefault={handleSubmit}>

            {#if submitError}
              <div class="banner-error" role="alert">
                <span class="material-symbols-outlined">error</span>
                {submitError}
              </div>
            {/if}

            <div class="form-section">
              <h2 class="title-medium section-title">Personal Information</h2>

              <div class="form-row">
                <TextField
                  label="First Name"
                  bind:value={formData.first_name}
                  error={errors.first_name}
                  required
                  placeholder="Your first name"
                />

                <TextField
                  label="Last Name"
                  bind:value={formData.last_name}
                  error={errors.last_name}
                  required
                  placeholder="Your last name"
                />
              </div>

              <TextField
                label="BEMIS Number"
                bind:value={formData.bemis_number}
                error={errors.bemis_number}
                required
                placeholder="Your BEMIS number"
              />

              <TextField
                label="Organization / School"
                bind:value={formData.organization}
                error={errors.organization}
                required
                placeholder="e.g. Belize Elementary School"
              />
            </div>

            <div class="form-section">
              <h2 class="title-medium section-title">Teaching Background</h2>

              <MultiSelect
                label="Subjects You Teach"
                options={subjectOptions}
                bind:value={formData.subjects}
                error={errors.subjects}
                required
              />

              <MultiSelect
                label="Grade Levels You Teach"
                options={gradeLevelOptions}
                bind:value={formData.grade_levels}
                error={errors.grade_levels}
                required
              />

              <TextField
                label="Years of Teaching Experience"
                type="number"
                bind:value={formData.experience_years}
                error={errors.experience_years}
                required
                placeholder="e.g. 5"
                min="0"
                max="60"
              />
            </div>

            <div class="form-section">
              <h2 class="title-medium section-title">About You</h2>

              <TextArea
                label="Bio"
                bind:value={formData.bio}
                error={errors.bio}
                required
                placeholder="Tell us about your teaching experience, the types of STEAM resources you create, and why you want to be a Fellow (minimum 50 characters)."
                rows={5}
              />

              <TextField
                label="Credentials / Portfolio Link (optional)"
                bind:value={formData.credentials_link}
                error={errors.credentials_link}
                placeholder="https://your-portfolio.com"
                type="url"
              />
            </div>

            <div class="form-section">
              <h2 class="title-medium section-title">MOE Verification Document</h2>

              <p class="body-medium section-subtitle">
                Please upload a scanned copy of your Ministry of Education identification or verification document.
              </p>

              {#if fileUploadError}
                <div class="banner-error" role="alert">
                  <span class="material-symbols-outlined">error</span>
                  {fileUploadError}
                </div>
              {/if}

              <div class="file-input-container">
                <input
                  type="file"
                  id="moe_document"
                  accept=".pdf,image/jpeg,image/png"
                  on:change={handleFileSelect}
                  disabled={uploadingFile}
                  class:error={errors.moe_document}
                />
                <label for="moe_document" class="file-input-label">
                  <span class="material-symbols-outlined">cloud_upload</span>
                  <div class="file-label-text">
                    {#if moeDocFile}
                      <strong>Selected: {moeDocFile.name}</strong>
                      <span class="file-size">({(moeDocFile.size / 1024 / 1024).toFixed(2)} MB)</span>
                    {:else}
                      <strong>Click to select file or drag and drop</strong>
                      <span class="file-info">PDF, JPG, or PNG (max 5 MB)</span>
                    {/if}
                  </div>
                </label>
              </div>

              {#if errors.moe_document}
                <p class="error-message">{errors.moe_document}</p>
              {/if}
            </div>

            <div class="form-actions">
              <Button variant="outlined" type="button" on:click={() => navigateTo('/')}>
                Cancel
              </Button>
              <Button variant="filled" type="submit" disabled={loading || uploadingFile}>
                {#if uploadingFile}
                  Uploading Document…
                {:else if loading}
                  Submitting…
                {:else}
                  Submit Application
                {/if}
              </Button>
            </div>

          </form>
        {/if}
      {/if}

    </div>
  </main>
</div>

<style>
  .page {
    min-height: 100vh;
    background: var(--md-sys-color-background, #fdf7ff);
  }

  .main-content {
    max-width: 760px;
    margin: 0 auto;
    padding: 32px 16px 64px;
  }

  .form-container {
    display: flex;
    flex-direction: column;
    gap: 32px;
  }

  /* ── Page header ── */
  .page-header {
    display: flex;
    align-items: flex-start;
    gap: 16px;
  }

  .header-icon {
    font-size: 48px;
    color: var(--md-sys-color-primary, #6750a4);
    flex-shrink: 0;
    margin-top: 4px;
  }

  .display-small {
    font-size: 2rem;
    font-weight: 400;
    margin: 0 0 8px;
    color: var(--md-sys-color-on-background, #1d1b20);
  }

  .subtitle {
    color: var(--md-sys-color-on-surface-variant, #49454f);
    margin: 0;
  }

  /* ── Status cards ── */
  .status-card {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 24px;
    border-radius: 16px;
    flex-wrap: wrap;
  }

  .status-approved {
    background: color-mix(in srgb, var(--md-sys-color-tertiary, #386a20) 10%, transparent);
    border: 1px solid var(--md-sys-color-tertiary, #386a20);
  }

  .status-pending {
    background: color-mix(in srgb, var(--md-sys-color-secondary, #625b71) 10%, transparent);
    border: 1px solid var(--md-sys-color-secondary-container, #e8def8);
  }

  .status-icon {
    font-size: 48px;
    color: var(--md-sys-color-tertiary, #386a20);
    flex-shrink: 0;
  }

  .status-pending .status-icon {
    color: var(--md-sys-color-secondary, #625b71);
  }

  .status-card > div {
    flex: 1;
    min-width: 0;
  }

  .title-large {
    font-size: 1.375rem;
    font-weight: 500;
    margin: 0 0 4px;
  }

  /* ── Form ── */
  .application-form {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .form-section {
    display: flex;
    flex-direction: column;
    gap: 16px;
    background: var(--md-sys-color-surface-container-low, #f7f2fa);
    border-radius: 16px;
    padding: 24px;
  }

  .section-title {
    font-size: 1rem;
    font-weight: 600;
    color: var(--md-sys-color-primary, #6750a4);
    margin: 0 0 4px;
  }

  .title-medium {
    font-size: 1rem;
    font-weight: 500;
  }

  .body-medium {
    font-size: 0.875rem;
    line-height: 1.5;
    margin: 0;
  }

  .body-large {
    font-size: 1rem;
    line-height: 1.6;
  }

  /* ── Banners ── */
  .banner-error {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 18px;
    border-radius: 12px;
    background: color-mix(in srgb, var(--md-sys-color-error, #b3261e) 12%, transparent);
    color: var(--md-sys-color-error, #b3261e);
    font-size: 0.9rem;
  }

  /* ── Actions ── */
  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    flex-wrap: wrap;
  }

  /* ── Form rows for side-by-side fields ── */
  .form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  /* ── File Input ── */
  .file-input-container {
    position: relative;
  }

  #moe_document {
    display: none;
  }

  .file-input-label {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    padding: 32px 24px;
    border: 2px dashed var(--md-sys-color-primary, #6750a4);
    border-radius: 12px;
    background: var(--md-sys-color-surface-container, #ede7f6);
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .file-input-label:hover {
    border-color: var(--md-sys-color-primary, #6750a4);
    background: color-mix(in srgb, var(--md-sys-color-primary, #6750a4) 5%, var(--md-sys-color-surface-container, #ede7f6));
  }

  #moe_document:disabled + .file-input-label {
    opacity: 0.6;
    cursor: not-allowed;
  }

  #moe_document.error + .file-input-label {
    border-color: var(--md-sys-color-error, #b3261e);
    background: color-mix(in srgb, var(--md-sys-color-error, #b3261e) 10%, transparent);
  }

  .file-input-label .material-symbols-outlined {
    font-size: 40px;
    color: var(--md-sys-color-primary, #6750a4);
  }

  .file-label-text {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    text-align: center;
  }

  .file-label-text strong {
    color: var(--md-sys-color-on-background, #1d1b20);
    font-size: 0.95rem;
  }

  .file-info {
    font-size: 0.85rem;
    color: var(--md-sys-color-on-surface-variant, #49454f);
  }

  .file-size {
    font-size: 0.8rem;
    color: var(--md-sys-color-on-surface-variant, #49454f);
  }

  .section-subtitle {
    color: var(--md-sys-color-on-surface-variant, #49454f);
  }

  .error-message {
    font-size: 0.8rem;
    color: var(--md-sys-color-error, #b3261e);
    margin: 8px 0 0;
  }

  @media (max-width: 600px) {
    .form-row {
      grid-template-columns: 1fr;
    }

    .file-input-label {
      padding: 24px 16px;
    }

    .file-input-label .material-symbols-outlined {
      font-size: 32px;
    }
  }
</style>
