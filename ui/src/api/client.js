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

async function request(endpoint, options = {}) {
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
      throw new APIError(
        data.error || 'An error occurred',
        response.status,
        data.errors || {}
      );
    }

    return data;
  } catch (error) {
    console.error('API Request Failed:', error);
    if (error instanceof APIError) {
      throw error;
    }
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

export { APIError };
