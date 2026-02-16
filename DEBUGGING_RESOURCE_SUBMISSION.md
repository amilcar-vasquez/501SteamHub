# Debugging Resource Submission

## Changes Made

### Backend (API)
1. **Enhanced Logging in `resourceHandlers.go`**:
   - Added logging at every step of resource creation
   - Logs incoming request, parsed data, validation errors, database operations
   - Logs will appear in the API terminal

2. **Improved Validation**:
   - Added comprehensive field validation
   - Validates title length, category, subject, grade_level, ILO, status, contributor_id
   - Better error messages

### Frontend (UI)
1. **Enhanced Debugging in `SubmitResource.svelte`**:
   - Added console logging at each step
   - Logs form data, auth token, request payload, responses, and errors
   - Wrapped with `=== SUBMIT RESOURCE START/END ===` markers

2. **Enhanced API Client Logging**:
   - Logs every API request (URL, method, headers, body)
   - Logs every API response (status, data)
   - Logs failures with detailed error information

## How to Debug

### Step 1: Open Browser Console
1. Navigate to http://localhost:3000 in your browser
2. Open Developer Tools (F12 or Right-click → Inspect)
3. Go to the Console tab

### Step 2: Try to Submit a Resource
1. Make sure you're signed in (you should see your avatar in the top right)
2. Click the "Submit Resource" button (either in top bar or the floating + button)
3. Fill out the form:
   - Title: "Test Resource"
   - Category: Choose any
   - Subject: Choose any
   - Grade Level: Choose any
   - ILO: "This is a test to see if resource submission works properly"
4. Click "Submit Resource"

### Step 3: Check Console Output
Look for these log entries in order:

```
=== SUBMIT RESOURCE START ===
Current User: {...}
Auth Token: eyJhbGci...
Form Data: {...}
API Request: {...}
```

### Step 4: Check API Terminal
Look at the terminal where the API is running. You should see:

```
INFO Receiving resource creation request method=POST path=/v1/resources
INFO Parsed resource data title="Test Resource" category=... grade_level=...
INFO Attempting to insert resource into database
INFO Resource created successfully resource_id=1
```

## Common Issues and Solutions

### Issue 1: "Current User is null"
**Problem**: User is not authenticated
**Solution**: 
- Go to Sign In page
- Log in with your credentials
- Make sure activation is complete

### Issue 2: "Auth Token is undefined or null"
**Problem**: Authentication token not stored
**Solution**:
- Check localStorage in DevTools → Application → Local Storage
- Should see `authToken` key
- Try signing out and signing in again

### Issue 3: "Network error" or CORS error
**Problem**: API not running or CORS misconfiguration
**Solution**:
- Check API terminal is running: `make run/api`
- Verify API is accessible: `curl http://localhost:4000/v1/healthcheck`
- Check .env file has correct VITE_API_URL

### Issue 4: "403 Forbidden" or "401 Unauthorized"
**Problem**: Invalid token or unactivated account
**Solution**:
- Verify user is activated in database
- Check token hasn't expired
- Try generating a new token by signing in again

### Issue 5: Validation errors
**Problem**: Form data doesn't meet requirements
**Solution**:
- Check console logs for validation error details
- Ensure all required fields are filled
- Verify grade_level matches enum values

### Issue 6: Database error
**Problem**: Database constraint violation or connection issue
**Solution**:
- Check API logs for database error details
- Verify migrations are up to date: `make db/migrations/up`
- Check contributor_id exists in users table
- Verify grade_level is valid enum value

## Testing Checklist

- [ ] Browser console shows "=== SUBMIT RESOURCE START ==="
- [ ] Current User object is populated with user_id
- [ ] Auth Token is present (starts with eyJ...)
- [ ] Form Data shows all fields filled
- [ ] API Request log shows POST to /resources
- [ ] API terminal shows "Receiving resource creation request"
- [ ] API terminal shows "Parsed resource data"
- [ ] API terminal shows "Resource created successfully"
- [ ] Browser console shows successful response
- [ ] Success banner appears on page
- [ ] Page redirects to home after 2 seconds

## Next Steps

After running through the checklist, report:
1. Where the process stops (which log is the last one you see?)
2. Any error messages in console or API terminal
3. Screenshots if applicable

This will help identify exactly where the issue is occurring.
