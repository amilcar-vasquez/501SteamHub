# User Authentication Flow

## Sign Up Flow

The application now includes a complete user registration and activation system that integrates with the backend API.

### Pages

1. **Home** (`/` or `#home`)
   - Main resource browsing page
   - Includes banner with "Sign Up" call-to-action for unauthenticated users
   - Access via: `http://localhost:3000/`

2. **Sign Up** (`#signup`)
   - User registration form with validation
   - Access via: `http://localhost:3000/#signup`
   - Form fields:
     - Username (3-50 characters)
     - Email (valid email format)
     - Password (8-72 characters)
     - Confirm Password (must match)

3. **Activate** (`#activate`)
   - Account activation page
   - Access via: `http://localhost:3000/#activate`
   - Users enter activation token received via email

### User Journey

```
1. User visits Home page
   ↓
2. Clicks "Sign Up" button
   ↓
3. Fills out registration form
   ↓
4. Submits form → API creates user (inactive) and sends activation email
   ↓
5. User receives email with activation token
   ↓
6. User navigates to Activate page (or auto-redirected after signup)
   ↓
7. Enters activation token
   ↓
8. Account activated → Redirected to Sign In
```

### API Endpoints Used

- **POST /v1/users** - Register new user
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string"
  }
  ```

- **PUT /v1/users/activated** - Activate user account
  ```json
  {
    "token": "string"
  }
  ```

### Components Created

#### Reusable Form Components
- **TextField.svelte** - Material 3 text input with validation
- **Button.svelte** - Material 3 button (filled, outlined, text variants)

#### Pages
- **SignUp.svelte** - User registration form
- **Activate.svelte** - Account activation form
- **Home.svelte** - Main resource browsing page (refactored from App.svelte)

#### Services
- **api/client.js** - API client with error handling

### Styling

All forms follow Material 3 design principles:
- **Primary Color**: `#7c3d82` (Purple) - Used for primary actions
- **Secondary Color**: `#069ec9` (Cyan) - Used for buttons and accents
- **Gradient Background**: Purple to Cyan gradient for auth pages
- **Elevated Cards**: Material 3 elevation and shadows
- **Form Validation**: Real-time validation with error messages
- **Loading States**: Button loading spinners
- **Success/Error Banners**: Color-coded feedback messages

### Navigation

The app uses hash-based routing for simplicity:
- `#home` - Home/resource browsing page
- `#signup` - Sign up page
- `#activate` - Activation page
- `#signin` - Sign in page (to be implemented)

### Configuration

Environment variables in `.env`:
```
VITE_API_URL=http://localhost:4000/v1
```

### Testing the Flow

1. Start the backend API (should be running on port 4000)
2. Start the Vite dev server: `npm run dev`
3. Navigate to `http://localhost:3000/#signup`
4. Fill out the registration form
5. Check backend logs/email system for activation token
6. Navigate to `http://localhost:3000/#activate`
7. Enter the token and activate your account

### Form Validation

**Username**:
- Required
- Min 3 characters
- Max 50 characters

**Email**:
- Required
- Valid email format

**Password**:
- Required
- Min 8 characters
- Max 72 characters
- Must match confirmation

**Activation Token**:
- Required
- Validated against backend

### Error Handling

- **Network Errors**: Generic connectivity message
- **Validation Errors**: Field-specific error messages
- **API Errors**: Server error messages displayed to user
- **Success States**: Green banners with confirmation messages

### Next Steps

To complete the authentication system:
1. Create Sign In page
2. Implement  token storage (localStorage/cookies)
3. Add authenticated routes/guards
4. Add password reset flow
5. Add profile management
