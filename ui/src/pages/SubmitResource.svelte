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

  const categoryOptions = [
    { value: 'LessonPlan', label: '📚 Lesson Plan' },
    { value: 'Video', label: '🎥 Video' },
    { value: 'Slideshow', label: '📊 Slideshow' },
    { value: 'Assessment', label: '📝 Assessment' },
    { value: 'Other', label: '📂 Other' },
  ];

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
    { value: 'Science', label: '🔬 Science' },
    { value: 'Engineering', label: '⚙️ Engineering' },
    { value: 'Robotics', label: '🤖 Robotics' },
    { value: 'Arts', label: '🎨 Arts' },
    { value: 'Belizean History', label: '🇧🇿 Belizean History' },
    { value: 'Mathematics', label: '➕ Mathematics' },
    { value: 'English Language Arts', label: '📖 English Language Arts' },
    { value: 'Social Studies', label: '🌍 Social Studies' },
    { value: 'Physical Education', label: '⚽ Physical Education' },
  ];

  onMount(() => {
    // Redirect if not authenticated
    if (!$currentUser) {
      window.location.hash = '#signin';
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
    
    // Drive link is optional, but if provided, should be a valid URL
    if (formData.drive_link.trim()) {
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
        status: 'Draft', // Default status
        contributor_id: $currentUser.user_id,
      };
      
      // Include lesson_content if this is a lesson plan
      if (formData.category === 'LessonPlan' && lessonContent.blocks.length > 0) {
        resourceData.lesson_content = lessonContent;
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
        successMessage += ` <a href="#resources/${response.resource.slug}" style="color: var(--md-sys-color-primary); text-decoration: underline;">View Resource</a>`;
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
      
      // Scroll to top to see success message
      window.scrollTo({ top: 0, behavior: 'smooth' });
      
      // Redirect to home after 2 seconds
      setTimeout(() => {
        window.location.hash = '#home';
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
      window.location.hash = '#home';
    }
  }
</script>

<div class="submit-resource">
  <div class="header">
    <button class="back-button" on:click={handleCancel}>
      <span class="material-symbols-outlined">arrow_back</span>
    </button>
    <div>
      <h1>Submit a Resource</h1>
      <p class="subtitle">Share your teaching materials with the 501SteamHub community</p>
    </div>
  </div>

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

  <form on:submit|preventDefault={handleSubmit}>
    <div class="form-section">
      <h2>Basic Information</h2>
      
      <TextField
        label="Resource Title"
        bind:value={formData.title}
        error={errors.title}
        required
        placeholder="e.g., Introduction to Fractions for 3rd Grade"
        helperText="Give your resource a clear, descriptive title"
      />

      <Select
        label="Category"
        bind:value={formData.category}
        options={categoryOptions}
        error={errors.category}
        required
        helperText="What type of resource is this?"
      />

      <MultiSelect
        label="Subjects"
        bind:value={formData.subjects}
        options={subjectOptions}
        error={errors.subjects}
        required
        helperText="Select all subjects this resource covers"
        placeholder="Select subjects..."
      />

      <MultiSelect
        label="Grade Levels"
        bind:value={formData.grade_levels}
        options={gradeLevelOptions}
        error={errors.grade_levels}
        required
        helperText="Select all grade levels this resource is designed for"
        placeholder="Select grade levels..."
      />
    </div>

    <div class="form-section">
      <h2>Description</h2>
      
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

    {#if formData.category === 'LessonPlan'}
      <div class="form-section lesson-plan-section">
        <h2>Lesson Plan Structure</h2>
        <LessonBuilder bind:lessonContent />
        {#if errors.lesson_content}
          <p class="error-text">{errors.lesson_content}</p>
        {/if}
      </div>
    {/if}

    <div class="form-section">
      <h2>Resource Link (Optional)</h2>
      
      <TextField
        type="url"
        label="Google Drive Link"
        bind:value={formData.drive_link}
        error={errors.drive_link}
        placeholder="https://drive.google.com/..."
        helperText="Share a link to your resource on Google Drive or other cloud storage"
      />
    </div>

    <div class="form-actions">
      <Button
        variant="text"
        type="button"
        on:click={handleCancel}
        disabled={loading}
      >
        Cancel
      </Button>
      
      <Button
        variant="filled"
        type="submit"
        disabled={loading}
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
  </form>
</div>

<style>
  .submit-resource {
    max-width: 1024px;
    margin: 0 auto;
    padding: var(--md-sys-spacing-xl);
  }

  .header {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    margin-bottom: var(--md-sys-spacing-xl);
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
  }

  .back-button:hover {
    background-color: rgba(0, 0, 0, 0.05);
  }

  .back-button .material-symbols-outlined {
    font-size: 28px;
  }

  h1 {
    font-size: 36px;
    font-weight: 500;
    color: var(--md-sys-color-primary);
    margin: 0 0 8px 0;
  }

  .subtitle {
    font-size: 18px;
    color: var(--md-sys-color-on-surface-variant);
    margin: 0;
  }

  .success-banner {
    display: flex;
    align-items: flex-start;
    gap: var(--md-sys-spacing-md);
    padding: var(--md-sys-spacing-lg);
    background-color: rgba(6, 158, 201, 0.1);
    border-left: 4px solid var(--md-sys-color-secondary);
    border-radius: var(--md-sys-shape-corner-sm);
    margin-bottom: var(--md-sys-spacing-lg);
  }

  .success-banner .material-symbols-outlined {
    font-size: 28px;
    color: var(--md-sys-color-secondary);
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
    background-color: rgba(179, 38, 30, 0.1);
    border-left: 4px solid var(--md-sys-color-error);
    border-radius: var(--md-sys-shape-corner-sm);
    margin-bottom: var(--md-sys-spacing-lg);
  }

  .error-banner .material-symbols-outlined {
    font-size: 28px;
    color: var(--md-sys-color-error);
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

  .lesson-plan-section {
    background: linear-gradient(135deg, rgba(6, 158, 201, 0.05) 0%, rgba(252, 180, 21, 0.05) 100%);
    border: 2px solid var(--md-sys-color-primary);
  }

  .error-text {
    color: var(--md-sys-color-error);
    font-size: 0.875rem;
    margin-top: 0.5rem;
    display: flex;
    align-items: center;
    gap: 0.25rem;
  }

  .form-section {
    margin-bottom: var(--md-sys-spacing-xl);
    padding: var(--md-sys-spacing-lg);
    background-color: var(--md-sys-color-surface-variant);
    border-radius: var(--md-sys-shape-corner-lg);
  }

  .form-section h2 {
    font-size: 24px;
    font-weight: 500;
    color: var(--md-sys-color-primary);
    margin: 0 0 var(--md-sys-spacing-lg) 0;
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: var(--md-sys-spacing-md);
    margin-top: var(--md-sys-spacing-xl);
    padding-top: var(--md-sys-spacing-lg);
    border-top: 1px solid var(--md-sys-color-outline-variant);
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

  /* Mobile responsiveness */
  @media (max-width: 768px) {
    .submit-resource {
      padding: var(--md-sys-spacing-md);
    }

    h1 {
      font-size: 28px;
    }

    .subtitle {
      font-size: 16px;
    }

    .form-section {
      padding: var(--md-sys-spacing-md);
    }

    .form-actions {
      flex-direction: column-reverse;
    }

    .form-actions :global(button) {
      width: 100%;
    }
  }
</style>
