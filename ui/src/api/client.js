// API configuration
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/v1';

class APIError extends Error {
  constructor(message, status, errors = {}) {
    super(message);
    this.name = 'APIError';
    this.status = status;
    this.errors = errors;
  }
}

// Check if token is expired before making requests
function isTokenExpiredClient() {
  const expiryStr = localStorage.getItem('tokenExpiry');
  if (!expiryStr) return false;
  return new Date() > new Date(expiryStr);
}

async function request(endpoint, options = {}) {
  // If token is expired and this is an authenticated request, clear auth and redirect
  if (options.headers?.Authorization && isTokenExpiredClient()) {
    console.warn('Token expired. Clearing authentication.');
    localStorage.removeItem('authToken');
    localStorage.removeItem('authUser');
    localStorage.removeItem('tokenExpiry');
    // Redirect to signin
    if (typeof window !== 'undefined') {
      window.location.href = '/signin';
    }
    throw new APIError('Session expired. Please sign in again.', 401);
  }
  const url = `${API_BASE_URL}${endpoint}`;
  
  console.log('API Request:', {
    url,
    method: options.method || 'GET',
    headers: options.headers,
    body: options.body ? JSON.parse(options.body) : null
  });
  
  const config = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  };

  try {
    const response = await fetch(url, config);
    const data = await response.json();

    console.log('API Response:', {
      status: response.status,
      ok: response.ok,
      data
    });

    if (!response.ok) {
      // Check if error is a validation errors object (map) or a string message
      let errorMessage = 'An error occurred';
      let errorMap = {};
      
      if (typeof data.error === 'object' && data.error !== null) {
        // Validation errors come as an object map
        errorMap = data.error;
        errorMessage = 'Validation failed';
      } else if (typeof data.error === 'string') {
        // Regular error messages come as strings
        errorMessage = data.error;
      }
      
      throw new APIError(
        errorMessage,
        response.status,
        errorMap
      );
    }

    return data;
  } catch (error) {
    if (error instanceof APIError) {
      console.error('API Request Failed - Validation Errors:', {
        status: error.status,
        message: error.message,
        errors: error.errors
      });
      throw error;
    }
    console.error('API Request Failed:', error);
    throw new APIError('Network error. Please check your connection.', 0);
  }
}

// User API methods
export const userAPI = {
  register: async (username, email, password) => {
    return request('/users', {
      method: 'POST',
      body: JSON.stringify({ username, email, password }),
    });
  },

  activate: async (token) => {
    return request('/users/activated', {
      method: 'PUT',
      body: JSON.stringify({ token }),
    });
  },

  getUser: async (id, authToken) => {
    return request(`/users/${id}`, {
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
    });
  },
};

// Token API methods
export const tokenAPI = {
  authenticate: async (email, password) => {
    return request('/tokens/authentication', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  },
};

// Resource API methods
export const resourceAPI = {
  create: async (resourceData, authToken) => {
    return request('/resources', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
      body: JSON.stringify(resourceData),
    });
  },

  getAll: async (filters = {}) => {
    const params = new URLSearchParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value) params.append(key, value);
    });
    const queryString = params.toString();
    return request(`/resources${queryString ? `?${queryString}` : ''}`);
  },

  get: async (id) => {
    return request(`/resources/${id}`);
  },

  getBySlug: async (slug) => {
    return request(`/resource-by-slug/${slug}`);
  },

  update: async (id, resourceData, authToken) => {
    return request(`/resources/${id}`, {
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
      body: JSON.stringify(resourceData),
    });
  },

  getMetrics: async (authToken) => {
    return request('/resource-metrics', {
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
    });
  },

  delete: async (id, authToken) => {
    return request(`/resources/${id}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
    });
  },
};

// Resource Review API methods
export const reviewAPI = {
  createReview: async ({ resource_id, reviewer_id, reviewer_role_id, decision, comment_summary = '' }, authToken) => {
    return request('/resource-reviews', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${authToken}`,
      },
      body: JSON.stringify({ resource_id, reviewer_id, reviewer_role_id, decision, comment_summary }),
    });
  },
};

// Admin API methods
export const adminAPI = {
  // GET /v1/admin/metrics
  getMetrics: async (authToken) => {
    return request('/admin/metrics', {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // GET /v1/users  (reuse existing endpoint, admin-scoped)
  getUsers: async (authToken, params = {}) => {
    const qs = new URLSearchParams(params).toString();
    return request(`/users${qs ? `?${qs}` : ''}`, {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // POST /v1/admin/users
  createUser: async (userData, authToken) => {
    return request('/admin/users', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify(userData),
    });
  },

  // PUT /v1/admin/users/:id
  updateUser: async (id, userData, authToken) => {
    return request(`/admin/users/${id}`, {
      method: 'PUT',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify(userData),
    });
  },

  // PATCH /v1/admin/users/:id/role
  updateUserRole: async (id, roleId, authToken) => {
    return request(`/admin/users/${id}/role`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify({ role_id: roleId }),
    });
  },

  // PATCH /v1/admin/users/:id/active
  toggleUserActive: async (id, isActive, authToken) => {
    return request(`/admin/users/${id}/active`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify({ is_active: isActive }),
    });
  },

  // POST /v1/admin/users/:id/send-email
  sendEmailToUser: async (id, subject, body, authToken) => {
    return request(`/admin/users/${id}/send-email`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify({ subject, body }),
    });
  },

  // POST /v1/resources/:id/status
  overrideResourceStatus: async (resourceId, status, reason, authToken) => {
    return request(`/resources/${resourceId}/status`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify({ status, reason }),
    });
  },
};

// Fellow Application API methods
export const fellowApplicationAPI = {
  // POST /v1/fellow-applications — submit a new application (role=User only)
  // NOTE: /fellow-applications prefix avoids httprouter wildcard conflict with /fellows/:id
  apply: async (applicationData, authToken) => {
    return request('/fellow-applications', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify(applicationData),
    });
  },

  // GET /v1/fellow-applications/me — get the current user's application status
  getMyApplication: async (authToken) => {
    return request('/fellow-applications/me', {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },
};

// Admin fellow application endpoints
Object.assign(adminAPI, {
  // GET /v1/admin/fellow-applications
  listFellowApplications: async (authToken, statusFilter = '') => {
    const qs = statusFilter ? `?status=${statusFilter}` : '';
    return request(`/admin/fellow-applications${qs}`, {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // PATCH /v1/admin/fellow-applications/:id/approve
  approveFellowApplication: async (id, authToken) => {
    return request(`/admin/fellow-applications/${id}/approve`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // PATCH /v1/admin/fellow-applications/:id/reject
  rejectFellowApplication: async (id, authToken) => {
    return request(`/admin/fellow-applications/${id}/reject`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // GET /v1/admin/moe-documents?path=... - retrieve MOE verification document
  getMoeDocument: async (moeDocPath, authToken) => {
    const qs = moeDocPath ? `?path=${encodeURIComponent(moeDocPath)}` : '';
    return request(`/admin/moe-documents${qs}`, {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },
});

// Fellow API methods
export const fellowAPI = {
  // GET /v1/fellows/:id - get a fellow by fellow ID
  get: async (id, authToken) => {
    return request(`/fellows/${id}`, {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // GET /v1/fellows?user_id=:user_id - get a fellow by user ID
  getByUserId: async (userId, authToken) => {
    return request(`/fellows?user_id=${userId}`, {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },

  // PATCH /v1/fellows/:id - update fellow profile
  update: async (id, fellowData, authToken) => {
    return request(`/fellows/${id}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify(fellowData),
    });
  },

  // GET /v1/fellows - get all fellows
  getAll: async (authToken) => {
    return request('/fellows', {
      headers: { 'Authorization': `Bearer ${authToken}` },
    });
  },
};

// User API improvements (add missing methods)
Object.assign(userAPI, {
  // PATCH /v1/users/:id - update user profile
  update: async (id, userData, authToken) => {
    return request(`/users/${id}`, {
      method: 'PATCH',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify(userData),
    });
  },
});

// ILO API methods
export const iloAPI = {
  // GET /v1/ilos - get all ILOs with optional filtering
  getAll: async (filters = {}) => {
    const params = new URLSearchParams();
    if (filters.subject) params.append('subject', filters.subject);
    if (filters.grade) params.append('grade', filters.grade);
    if (filters.cycle) params.append('cycle', filters.cycle);
    if (filters.strand) params.append('strand', filters.strand);
    
    const qs = params.toString() ? `?${params.toString()}` : '';
    return request(`/ilos${qs}`);
  },

  // GET /v1/ilos/:id - get a specific ILO by ID
  getById: async (id) => {
    return request(`/ilos/${id}`);
  },

  // GET /v1/suggested-ilos - get suggested ILOs for browsing
  getSuggested: async (filters = {}) => {
    const params = new URLSearchParams();
    if (filters.subject) params.append('subject', filters.subject);
    if (filters.grade) params.append('grade', filters.grade);
    if (filters.cycle) params.append('cycle', filters.cycle);
    
    const qs = params.toString() ? `?${params.toString()}` : '';
    return request(`/suggested-ilos${qs}`);
  },

  // GET /v1/resources/:resourceId/ilos - get ILOs linked to a resource
  getForResource: async (resourceId) => {
    return request(`/resources/${resourceId}/ilos`);
  },

  // POST /v1/resources/:resourceId/ilos - attach ILOs to a resource
  attachToResource: async (resourceId, iloIds, authToken) => {
    return request(`/resources/${resourceId}/ilos`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${authToken}` },
      body: JSON.stringify({ ilo_ids: iloIds }),
    });
  },
};

export { APIError };
