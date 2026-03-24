<script>
  import { onMount } from 'svelte';
  import { currentUser, authToken } from '../stores/auth.js';
  import { resourceAPI } from '../api/client.js';
  import TextField from '../components/TextField.svelte';
  import TextArea from '../components/TextArea.svelte';
  import Select from '../components/Select.svelte';
  import MultiSelect from '../components/MultiSelect.svelte';
  import Button from '../components/Button.svelte';
  import LessonBuilder from '../components/LessonBuilder.svelte';
  import { navigateTo } from '../router.js';

  let formData = {
    title: '',
    category: '',
    subjects: [],
    grade_levels: [],
    summary: '',
    drive_link: '',
  };

  let lessonContent = {
    version: 1,
    blocks: []
  };

  let errors = {};
  let loading = false;
  let successMessage = '';

  // ── Video-specific metadata ────────────────────────────────────────────────
  let videoDetails = {
    youtube_title: '',
    youtube_description: '',
    tags: '',              // comma-separated input; split on submit
    privacy_status: 'unlisted',
    made_for_kids: true,
  };

  $: isVideo = formData.category === 'Video';

  // Autopopulate YouTube fields from resource details
  $: if (isVideo) {
    videoDetails.youtube_title = formData.title || '';
    videoDetails.youtube_description = formData.summary || '';
    videoDetails.tags = [...formData.subjects, ...formData.grade_levels].join(', ');
  }

  const privacyOptions = [
    { value: 'unlisted', label: 'Unlisted' },
    { value: 'public',   label: 'Public' },
    { value: 'private',  label: 'Private' },
  ];

  const categoryOptions = [
    { value: 'LessonPlan', label: 'school Lesson Plan' },
    { value: 'Video', label: 'video_file Video' },
    { value: 'Slideshow', label: 'slideshow Slideshow' },
    { value: 'Assessment', label: 'assignment Assessment' },
    { value: 'Other', label: 'media_link Other' },
  ];

  const gradeLevelOptions = [
    { value: 'Preschool', label: 'playground Preschool' },
    { value: 'Infant 1', label: 'counter_1 Infant 1' },
    { value: 'Infant 2', label: 'counter_2 Infant 2' },
    { value: 'Standard 1', label: 'filter_1 Standard 1' },
    { value: 'Standard 2', label: 'filter_2 Standard 2' },
    { value: 'Standard 3', label: 'filter_3 Standard 3' },
    { value: 'Standard 4', label: 'filter_4 Standard 4' },
    { value: 'Standard 5', label: 'filter_5 Standard 5' },
    { value: 'Standard 6', label: 'filter_6 Standard 6' },
    { value: 'Mixed', label: 'pin Mixed Grades' },
  ];

  const subjectOptions = [
    { value: 'Computer Science', label: 'code_blocks Computer Science' },
    { value: 'Information Technology', label: 'network_node Information Technology' },
    { value: 'Science', label: 'science Science' },
    { value: 'Engineering', label: 'construction Engineering' },
    { value: 'Robotics', label: 'smart_toy Robotics' },
    { value: 'Arts', label: 'palette Arts' },
    { value: 'Belizean History', label: 'history Belizean History' },
    { value: 'Mathematics', label: 'calculate Mathematics' },
    { value: 'English Language Arts', label: 'library_books English Language Arts' },
    { value: 'Social Studies', label: 'public Social Studies' },
    { value: 'Physical Education', label: 'sports_soccer Physical Education' },
  ];

  onMount(() => {
    // Redirect if not authenticated
    if (!$currentUser) {
      navigateTo('/signin');
      return;
    }
    // Redirect Users (non-Fellows) to the application page
    const ALLOWED_ROLES = ['Fellow', 'admin', 'DSC', 'SubjectExpert', 'TeamLead', 'Secretary'];
    if (!ALLOWED_ROLES.includes($currentUser.role_name)) {
      navigateTo('/dashboard/apply-fellow');
    }
  });

  function validateForm() {
    errors = {};
    
    if (!formData.title.trim()) {
      errors.title = 'Title is required';
    } else if (formData.title.length < 3) {
      errors.title = 'Title must be at least 3 characters';
    } else if (formData.title.length > 255) {
      errors.title = 'Title must be less than 255 characters';
    }
    
    if (!formData.category) {
      errors.category = 'Category is required';
    }
    
    if (formData.subjects.length === 0) {
      errors.subjects = 'At least one subject is required';
    }
    
    if (formData.grade_levels.length === 0) {
      errors.grade_levels = 'At least one grade level is required';
    }
    
    if (formData.summary.trim() && formData.summary.length < 10) {
      errors.summary = 'Summary should be at least 10 characters if provided';
    }
    
    // Drive link is required for non-LessonPlan resource types; optional for LessonPlan.
    if (formData.category && formData.category !== 'LessonPlan') {
      if (!formData.drive_link.trim()) {
        errors.drive_link = 'Google Drive link is required for this resource type';
      } else {
        try {
          new URL(formData.drive_link);
        } catch {
          errors.drive_link = 'Please enter a valid URL';
        }
      }
    } else if (formData.drive_link.trim()) {
      // For LessonPlan, the link is optional but must be valid if supplied.
      try {
        new URL(formData.drive_link);
      } catch {
        errors.drive_link = 'Please enter a valid URL';
      }
    }

    // Lesson plan specific validation
    if (formData.category === 'LessonPlan') {
      if (lessonContent.blocks.length === 0) {
        errors.lesson_content = 'Lesson plan must have at least one block';
      } else {
        // Check if at least one objectives block exists
        const hasObjectives = lessonContent.blocks.some(block => block.type === 'objectives');
        if (!hasObjectives) {
          errors.lesson_content = 'Lesson plan must include at least one Learning Objectives block';
        }
      }
    }

    // Video-specific validation
    if (formData.category === 'Video') {
      if (!videoDetails.privacy_status) {
        errors.privacy_status = 'Privacy status is required';
      }
    }
    
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit() {
    console.log('=== SUBMIT RESOURCE START ===');
    console.log('Current User:', $currentUser);
    console.log('Auth Token:', $authToken);
    console.log('Form Data:', formData);
    console.log('Lesson Content:', lessonContent);
    
    if (!validateForm()) {
      console.log('Validation failed:', errors);
      return;
    }
    
    loading = true;
    successMessage = '';
    
    try {
      const resourceData = {
        ...formData,
        drive_link: formData.drive_link.trim() || null,
        status: 'Submitted', // Submit directly to review queue
        contributor_id: $currentUser.user_id,
      };
      
      // Include lesson_content if this is a lesson plan
      if (formData.category === 'LessonPlan' && lessonContent.blocks.length > 0) {
        resourceData.lesson_content = lessonContent;
      }

      // Include video_metadata if this is a video
      if (formData.category === 'Video') {
        resourceData.video_metadata = {
          youtube_title:       videoDetails.youtube_title.trim()       || formData.title,
          youtube_description: videoDetails.youtube_description.trim() || formData.summary || '',
          tags:                videoDetails.tags.split(',').map(t => t.trim()).filter(Boolean),
          privacy_status:      videoDetails.privacy_status,
          made_for_kids:       videoDetails.made_for_kids,
          category_id:         27,
        };
      }
      
      console.log('Submitting resource data:', resourceData);
      console.log('Using auth token:', $authToken);
      
      const response = await resourceAPI.create(resourceData, $authToken);
      
      console.log('Response received:', response);
      console.log('Created resource:', response.resource);
      console.log('Resource slug:', response.resource?.slug);
      
      // Success!
      successMessage = 'Resource submitted successfully! 🎉';
      
      // If resource has a slug, offer to view it
      if (response.resource?.slug) {
        successMessage += ` <a href="/resources/${response.resource.slug}" style="color: var(--md-sys-color-primary); text-decoration: underline;">View Resource</a>`;
      }
      
      // Reset form
      formData = {
        title: '',
        category: '',
        subjects: [],
        grade_levels: [],
        summary: '',
        drive_link: '',
      };
      
      lessonContent = {
        version: 1,
        blocks: []
      };

      videoDetails = {
        youtube_title: '',
        youtube_description: '',
        tags: '',
        privacy_status: 'unlisted',
        made_for_kids: true,
      };
      
      // Scroll to top to see success message
      window.scrollTo({ top: 0, behavior: 'smooth' });
      
      // Redirect to home after 2 seconds
      setTimeout(() => {
        navigateTo('/home');
      }, 2000);
      
    } catch (error) {
      console.error('=== SUBMIT RESOURCE ERROR ===');
      console.error('Error object:', error);
      console.error('Error message:', error.message);
      console.error('Error status:', error.status);
      console.error('Error errors:', error.errors);
      
      if (error.errors) {
        errors = error.errors;
      } else {
        errors.general = error.message || 'Failed to submit resource. Please try again.';
      }
    } finally {
      loading = false;
      console.log('=== SUBMIT RESOURCE END ===');
    }
  }

  function handleCancel() {
    if (confirm('Are you sure you want to cancel? All unsaved changes will be lost.')) {
      navigateTo('/home');
    }
  }
</script>

<div class="submit-resource">
  <!-- HEADER -->
  <header class="page-header">
    <div class="header-left">
      <button class="back-button" on:click={handleCancel}>
        <span class="material-symbols-outlined">arrow_back</span>
      </button>
      <div class="header-text">
        <h1>Submit a Resource</h1>
        <p class="subtitle">Share your teaching materials with the 501SteamHub community</p>
      </div>
    </div>
    <div class="header-right">
      <span class="save-indicator">Saved just now</span>
    </div>
  </header>

  {#if successMessage}
    <div class="success-banner">
      <span class="material-symbols-outlined">check_circle</span>
      <div>
        <strong>Success!</strong>
        <p>{@html successMessage}</p>
      </div>
    </div>
  {/if}

  {#if errors.general}
    <div class="error-banner">
      <span class="material-symbols-outlined">error</span>
      <div>
        <strong>Error</strong>
        <p>{errors.general}</p>
      </div>
    </div>
  {/if}

  <form on:submit|preventDefault={handleSubmit} class="workspace-container">
    <!-- DOCUMENT CANVAS (Left Column) -->
    <div class="document-canvas">
      <div class="document">
        <!-- Title Field -->
        <div class="canvas-section">
          <TextField
            label="Resource Title"
            bind:value={formData.title}
            error={errors.title}
            required
            placeholder="e.g., Introduction to Fractions for Standard 1"
            helperText="Give your resource a clear, descriptive title"
          />
        </div>

        <!-- Summary Field -->
        <div class="canvas-section">
          <TextArea
            label="Summary (Optional)"
            bind:value={formData.summary}
            error={errors.summary}
            rows={4}
            maxLength={500}
            placeholder="Provide a brief description of this resource and what it covers..."
            helperText="A short summary to help others understand what this resource is about"
          />
        </div>

        <!-- Lesson Builder (if Lesson Plan) -->
        {#if formData.category === 'LessonPlan'}
          <div class="canvas-section lesson-plan-canvas">
            <LessonBuilder bind:lessonContent />
            {#if errors.lesson_content}
              <p class="error-text">{errors.lesson_content}</p>
            {/if}
          </div>
        {/if}
      </div>
    </div>

    <!-- SIDEBAR METADATA (Right Column) -->
    <aside class="sidebar-metadata">
      <!-- Category -->
      <div class="sidebar-card">
        <h3 class="sidebar-title">Category</h3>
        <Select
          bind:value={formData.category}
          options={categoryOptions}
          error={errors.category}
          required
          helperText="What type of resource is this?"
        />
      </div>

      <!-- Subjects -->
      <div class="sidebar-card">
        <h3 class="sidebar-title">Subjects</h3>
        <MultiSelect
          bind:value={formData.subjects}
          options={subjectOptions}
          error={errors.subjects}
          required
          helperText="Select all subjects this resource covers"
          placeholder="Select subjects..."
        />
      </div>

      <!-- Grade Levels -->
      <div class="sidebar-card">
        <h3 class="sidebar-title">Grade Levels</h3>
        <MultiSelect
          bind:value={formData.grade_levels}
          options={gradeLevelOptions}
          error={errors.grade_levels}
          required
          helperText="Select all grade levels this resource is designed for"
          placeholder="Select grade levels..."
        />
      </div>

      <!-- Google Drive Link -->
      <div class="sidebar-card">
        <h3 class="sidebar-title">Resource Link</h3>
        <TextField
          type="url"
          label="Google Drive Link"
          bind:value={formData.drive_link}
          error={errors.drive_link}
          placeholder="https://drive.google.com/..."
          helperText={formData.category && formData.category !== 'LessonPlan'
            ? 'Required for this resource type'
            : 'Optional'}
        />
      </div>

      <!-- Video Metadata (if Video) -->
      {#if isVideo}
        <div class="sidebar-card video-metadata-card">
          <h3 class="sidebar-title">YouTube Details</h3>
          <p class="sidebar-hint">These fields control how your video appears on YouTube after it is approved and uploaded.</p>

          <TextField
            label="YouTube Title"
            bind:value={videoDetails.youtube_title}
            placeholder={formData.title || 'Video title for YouTube…'}
            helperText="Max 100 characters. Defaults to the resource title if left blank."
            maxLength={100}
          />

          <TextArea
            label="YouTube Description"
            bind:value={videoDetails.youtube_description}
            placeholder={formData.summary || 'Describe the video for YouTube viewers…'}
            rows={3}
            helperText="Defaults to the resource summary if left blank."
          />

          <TextField
            label="Tags (comma-separated)"
            bind:value={videoDetails.tags}
            placeholder="science, grade 3, fractions…"
            helperText="Separate tags with commas."
          />

          <Select
            label="Privacy Status"
            bind:value={videoDetails.privacy_status}
            options={privacyOptions}
            error={errors.privacy_status}
            required
            helperText="Unlisted means only people with the link can view it."
          />

          <!-- Made for Kids Toggle -->
          <div class="made-for-kids-field">
            <p class="mfk-label">
              <span class="material-symbols-outlined mfk-icon">child_care</span>
              Is this video made for kids?
              <span class="mfk-required">*</span>
            </p>
            <p class="mfk-hint">YouTube requires this declaration.</p>
            <div class="mfk-options">
              <button
                type="button"
                class="mfk-btn"
                class:selected={videoDetails.made_for_kids === false}
                on:click={() => (videoDetails.made_for_kids = false)}
              >
                <span class="material-symbols-outlined">close</span>
                No
              </button>
              <button
                type="button"
                class="mfk-btn"
                class:selected={videoDetails.made_for_kids === true}
                on:click={() => (videoDetails.made_for_kids = true)}
              >
                <span class="material-symbols-outlined">child_care</span>
                Yes
              </button>
            </div>
          </div>
        </div>
      {/if}
    </aside>
  </form>

  <!-- STICKY ACTION BAR -->
  <div class="action-bar">
    <Button
      variant="text"
      type="button"
      on:click={handleCancel}
      disabled={loading}
    >
      Cancel
    </Button>
    
    <div class="action-spacer">
      <Button
        variant="outlined"
        type="button"
        disabled={loading}
      >
        Save Draft
      </Button>
    </div>

    <Button
      variant="filled"
      type="submit"
      disabled={loading}
      on:click={handleSubmit}
    >
      {#if loading}
        <span class="material-symbols-outlined spinning">progress_activity</span>
        Submitting...
      {:else}
        <span class="material-symbols-outlined">send</span>
        Submit Resource
      {/if}
    </Button>
  </div>
</div>

<style>
  .submit-resource {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background: var(--md-sys-color-background);
  }

  /* HEADER */
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: var(--md-sys-spacing-lg) var(--md-sys-spacing-xl);
    border-bottom: 1px solid var(--md-sys-color-outline-variant);
    background: white;
    position: sticky;
    top: 0;
    z-index: 100;
  }

  .header-left {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    flex: 1;
  }

  .back-button {
    background: none;
    border: none;
    color: var(--md-sys-color-on-surface);
    cursor: pointer;
    padding: 8px;
    border-radius: var(--md-sys-shape-corner-full);
    transition: background-color 0.2s;
    margin-top: 4px;
    flex-shrink: 0;
  }

  .back-button:hover {
    background-color: rgba(0, 0, 0, 0.05);
  }

  .back-button .material-symbols-outlined {
    font-size: 28px;
  }

  .header-text {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  h1 {
    font-size: 28px;
    font-weight: 500;
    color: var(--md-sys-color-primary);
    margin: 0;
  }

  .subtitle {
    font-size: 14px;
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
  }

  .header-right {
    display: flex;
    align-items: center;
  }

  .save-indicator {
    font-size: 13px;
    color: var(--md-sys-color-on-surface-variant);
    font-weight: 500;
  }

  /* BANNERS */
  .success-banner {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-lg);
    margin: var(--md-sys-spacing-lg) var(--md-sys-spacing-xl) 0;
    background-color: rgba(6, 158, 201, 0.1);
    border-left: 4px solid var(--md-sys-color-secondary);
    border-radius: var(--md-sys-shape-corner-sm);
  }

  .success-banner .material-symbols-outlined {
    font-size: 28px;
    color: var(--md-sys-color-secondary);
    flex-shrink: 0;
  }

  .success-banner strong {
    color: var(--md-sys-color-secondary);
    font-size: 16px;
    display: block;
    margin-bottom: 4px;
  }

  .success-banner p {
    margin: 0;
    color: var(--md-sys-color-on-surface);
  }

  .error-banner {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-lg);
    margin: var(--md-sys-spacing-lg) var(--md-sys-spacing-xl) 0;
    background-color: rgba(179, 38, 30, 0.1);
    border-left: 4px solid var(--md-sys-color-error);
    border-radius: var(--md-sys-shape-corner-sm);
  }

  .error-banner .material-symbols-outlined {
    font-size: 28px;
    color: var(--md-sys-color-error);
    flex-shrink: 0;
  }

  .error-banner strong {
    color: var(--md-sys-color-error);
    font-size: 16px;
    display: block;
    margin-bottom: 4px;
  }

  .error-banner p {
    margin: 0;
    color: var(--md-sys-color-on-surface);
  }

  /* WORKSPACE CONTAINER */
  .workspace-container {
    display: grid;
    grid-template-columns: 1fr 320px;
    gap: 32px;
    align-items: start;
    padding: var(--md-sys-spacing-xl);
    width: 90%;
    max-width: 1600px;
    margin: 0 auto;
    flex: 1;
  }

  /* DOCUMENT CANVAS */
  .document-canvas {
    display: flex;
    flex-direction: column;
  }

  .document {
    background: white;
    padding: 40px;
    border-radius: var(--md-sys-shape-corner-large);
    border: 1px solid rgba(0, 0, 0, 0.06);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.03);
    display: flex;
    flex-direction: column;
    gap: 32px;
  }

  .canvas-section {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .lesson-plan-canvas {
    gap: 20px;
  }

  .lesson-plan-canvas h2 {
    font-size: 18px;
    font-weight: 600;
    color: var(--md-sys-color-primary);
    margin: 0;
  }

  /* SIDEBAR METADATA */
  .sidebar-metadata {
    display: flex;
    flex-direction: column;
    gap: 20px;
    position: sticky;
    top: 80px;
    overflow: visible;
  }

  .sidebar-card {
    padding: 20px;
    background: rgba(255, 255, 255, 0.8);
    border: 1px solid rgba(0, 0, 0, 0.05);
    border-radius: var(--md-sys-shape-corner-md);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  /* Ensure MultiSelect dropdowns appear above all cards */
  .sidebar-card :global(.dropdown) {
    z-index: 1000 !important;
    position: absolute;
  }

  .sidebar-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--md-sys-color-on-surface);
    margin: 0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .sidebar-hint {
    font-size: 12px;
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
    line-height: 1.4;
  }

  .video-metadata-card {
    border: 1px solid rgba(200, 30, 30, 0.15);
    background: linear-gradient(135deg, rgba(200, 30, 30, 0.02) 0%, rgba(252, 100, 50, 0.02) 100%);
  }

  /* ERROR TEXT */
  .error-text {
    color: var(--md-sys-color-error);
    font-size: 0.875rem;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 0.25rem;
  }

  /* MADE FOR KIDS TOGGLE */
  .made-for-kids-field {
    margin-top: 8px;
    padding: 12px;
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-sm);
    background: var(--md-sys-color-surface);
  }

  .mfk-label {
    display: flex;
    align-items: center;
    gap: 0.375rem;
    font-weight: 600;
    font-size: 0.875rem;
    color: var(--md-sys-color-on-surface);
    margin: 0 0 8px 0;
  }

  .mfk-icon {
    font-size: 18px;
    color: var(--md-sys-color-primary);
  }

  .mfk-required {
    color: var(--md-sys-color-error);
    font-weight: 700;
  }

  .mfk-hint {
    font-size: 0.75rem;
    color: var(--md-sys-color-on-surface-variant);
    margin: 0 0 10px 0;
    line-height: 1.3;
  }

  .mfk-options {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
  }

  .mfk-btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    border: 2px solid var(--md-sys-color-outline-variant);
    border-radius: 999px;
    background: none;
    font-size: 0.75rem;
    font-weight: 500;
    color: var(--md-sys-color-on-surface-variant);
    cursor: pointer;
    transition: all 0.15s;
  }

  .mfk-btn:hover {
    border-color: var(--md-sys-color-primary);
    color: var(--md-sys-color-primary);
    background: var(--md-sys-color-primary-container, rgba(6, 158, 201, 0.1));
  }

  .mfk-btn.selected {
    border-color: var(--md-sys-color-primary);
    background: var(--md-sys-color-primary);
    color: var(--md-sys-color-on-primary, #fff);
  }

  .mfk-btn .material-symbols-outlined {
    font-size: 16px;
  }

  /* STICKY ACTION BAR */
  .action-bar {
    position: sticky;
    bottom: 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: var(--md-sys-spacing-md);
    padding: 16px 24px;
    background: rgba(255, 255, 255, 0.95);
    border-top: 1px solid rgba(0, 0, 0, 0.05);
    box-shadow: 0 -1px 2px rgba(0, 0, 0, 0.02);
    z-index: 50;
    backdrop-filter: blur(2px);
  }

  .action-spacer {
    flex: 1;
    display: flex;
    justify-content: center;
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }
    to {
      transform: rotate(360deg);
    }
  }

  .spinning {
    animation: spin 1s linear infinite;
  }

  /* RESPONSIVE */
  @media (max-width: 900px) {
    .workspace-container {
      grid-template-columns: 1fr;
      gap: 24px;
      padding: var(--md-sys-spacing-lg);
    }

    .sidebar-metadata {
      position: static;
      top: auto;
    }

    .sidebar-card {
      flex-direction: row;
      align-items: center;
      gap: 16px;
    }

    .sidebar-title {
      min-width: 100px;
    }
  }

  @media (max-width: 768px) {
    .page-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 12px;
      padding: var(--md-sys-spacing-md);
    }

    .header-left {
      width: 100%;
    }

    .header-right {
      width: 100%;
    }

    .save-indicator {
      font-size: 12px;
    }

    h1 {
      font-size: 24px;
    }

    .subtitle {
      font-size: 12px;
    }

    .document {
      padding: 24px;
      gap: 24px;
    }

    .action-bar {
      flex-direction: column-reverse;
      gap: 12px;
    }

    .action-bar :global(button) {
      width: 100%;
    }

    .workspace-container {
      grid-template-columns: 1fr;
      gap: 16px;
      padding: var(--md-sys-spacing-md);
    }
  }
</style>
