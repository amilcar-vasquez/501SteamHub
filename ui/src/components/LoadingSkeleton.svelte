<div class="skeleton-card">
  <div class="skeleton-chip"></div>
  <div class="skeleton-title"></div>
  <div class="skeleton-title short"></div>
  <div class="skeleton-text"></div>
  <div class="skeleton-text"></div>
  <div class="skeleton-text short"></div>
  <div class="skeleton-chips">
    <div class="skeleton-chip small"></div>
    <div class="skeleton-chip small"></div>
    <div class="skeleton-chip small"></div>
  </div>
  <div class="skeleton-footer">
    <div class="skeleton-text mini"></div>
    <div class="skeleton-stats">
      <div class="skeleton-stat"></div>
      <div class="skeleton-stat"></div>
    </div>
  </div>
</div>

<style>
  .skeleton-card {
    background-color: var(--md-sys-color-surface);
    border: 1px solid var(--md-sys-color-outline-variant);
    border-radius: var(--md-sys-shape-corner-md);
    padding: var(--md-sys-spacing-md);
    display: flex;
    flex-direction: column;
    gap: var(--md-sys-spacing-md);
  }
  
  @keyframes shimmer {
    0% {
      background-position: -468px 0;
    }
    100% {
      background-position: 468px 0;
    }
  }
  
  .skeleton-chip,
  .skeleton-title,
  .skeleton-text,
  .skeleton-stat {
    background: linear-gradient(
      to right,
      var(--md-sys-color-surface-variant) 0%,
      var(--md-sys-color-surface-container-high) 20%,
      var(--md-sys-color-surface-variant) 40%,
      var(--md-sys-color-surface-variant) 100%
    );
    background-size: 800px 100%;
    animation: shimmer 1.5s infinite linear;
    border-radius: var(--md-sys-shape-corner-sm);
  }
  
  .skeleton-chip {
    height: 24px;
    width: 100px;
    border-radius: var(--md-sys-shape-corner-full);
  }
  
  .skeleton-chip.small {
    width: 80px;
  }
  
  .skeleton-title {
    height: 20px;
    width: 100%;
  }
  
  .skeleton-title.short {
    width: 60%;
  }
  
  .skeleton-text {
    height: 16px;
    width: 100%;
  }
  
  .skeleton-text.short {
    width: 80%;
  }
  
  .skeleton-text.mini {
    width: 120px;
  }
  
  .skeleton-chips {
    display: flex;
    gap: var(--md-sys-spacing-sm);
  }
  
  .skeleton-footer {
    display: flex;
    justify-content: space-between;
    padding-top: var(--md-sys-spacing-sm);
    border-top: 1px solid var(--md-sys-color-outline-variant);
  }
  
  .skeleton-stats {
    display: flex;
    gap: var(--md-sys-spacing-md);
  }
  
  .skeleton-stat {
    height: 16px;
    width: 40px;
  }
</style>
