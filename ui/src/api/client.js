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

    if (!response.ok) {
      throw new APIError(
        data.error || 'An error occurred',
        response.status,
        data.errors || {}
      );
    }

    return data;
  } catch (error) {
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

export { APIError };
