# 501 STEAM Hub - UI

A responsive web application built with Svelte and Material 3 design system.

## Features

- **Material 3 Design System**: Custom implementation with brand colors
  - Primary: #7c3d82
  - Secondary (Accent): #069ec9

- **Responsive Layout**:
  - Desktop (1440px+): 3-4 cards per row with permanent navigation drawer
  - Tablet (600-1024px): 2 cards per row
  - Mobile (<600px): 1 card per row with modal navigation drawer

- **Components**:
  - Top App Bar with search functionality
  - Navigation Drawer with filters (permanent on desktop, modal on mobile)
  - Resource Cards with outlined Material 3 styling
  - Filter and Assist Chips
  - Loading skeleton states
  - Zero results state

- **Filters**:
  - Subject (multi-select checkboxes)
  - Grade Level (multi-select checkboxes)
  - Resource Type (filter chips)
  - Contributor (dropdown)
  - School (dropdown)
  - Sort By (radio buttons: Relevance, Most Recent, Most Accessed)

- **Resource Cards**:
  - Category chip (Lesson Plan / Video / Assessment)
  - Title (max 2 lines)
  - Description preview (3 lines)
  - Subject, Grade, and ILO count chips
  - Contributor name
  - View count and contribution score
  - Optional status badge for Admin/Fellow view
  - Hover elevation increase
  - Entire card clickable

## Getting Started

### Install Dependencies

```bash
npm install
```

### Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:3000`

### Build for Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
ui/
├── index.html
├── package.json
├── vite.config.js
├── src/
│   ├── main.js
│   ├── App.svelte
│   ├── components/
│   │   ├── TopAppBar.svelte
│   │   ├── NavigationDrawer.svelte
│   │   ├── ResourceCard.svelte
│   │   ├── Chip.svelte
│   │   ├── FilterChip.svelte
│   │   └── LoadingSkeleton.svelte
│   └── styles/
│       └── global.css
```

## Technologies

- **Svelte 4**: Modern reactive framework
- **Vite 5**: Fast build tool
- **Material 3 Design**: Custom CSS implementation
- **CSS Grid**: Responsive layout system
- **Google Fonts**: Roboto font family
- **Material Symbols**: Icon set

## Accessibility

- Semantic HTML structure
- ARIA attributes for interactive elements
- Keyboard navigation support
- Focus states for all interactive elements
- Color contrast compliance with WCAG 2.1 AA

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)

## License

Proprietary - 501 STEAM Hub
