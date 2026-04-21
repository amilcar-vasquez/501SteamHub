// src/lib/api/reviewComments.js
//
// Review Comment API service.
// Follows the same request/error pattern used by resourceAPI in src/api/client.js.
// Import pattern:
//   import { getReviewComments, createReviewComment, resolveReviewComment } from '$lib/api/reviewComments';

import { APIError } from '../../api/client.js';
import { getApiBaseUrl } from '../config/apiBaseUrl.js';

const API_BASE_URL = getApiBaseUrl();

async function request(endpoint, options = {}) {
  const url = `${API_BASE_URL}${endpoint}`;
  const config = {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  };

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
}

/**
 * Fetch all review comments for a resource.
 *
 * @param {number} resourceId
 * @param {string} authToken
 * @returns {Promise<{ review_comments: ReviewComment[] }>}
 */
export async function getReviewComments(resourceId, authToken) {
  return request(`/resources/${resourceId}/review-comments`, {
    headers: {
      Authorization: `Bearer ${authToken}`,
    },
  });
}

/**
 * Create a new review comment on a resource.
 * The resource must be in 'UnderReview' status.
 *
 * @param {{ resource_id: number, reviewer_id: number, comment: string, section?: string, block_index?: number }} payload
 * @param {string} authToken
 * @returns {Promise<{ review_comment: ReviewComment }>}
 */
export async function createReviewComment(payload, authToken) {
  return request('/review-comments', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${authToken}`,
    },
    body: JSON.stringify(payload),
  });
}

/**
 * Resolve an open review comment (set resolved=true, resolved_at=NOW()).
 *
 * @param {number} commentId
 * @param {string} authToken
 * @returns {Promise<{ review_comment: ReviewComment }>}
 */
export async function resolveReviewComment(commentId, authToken) {
  return request(`/review-comments/${commentId}/resolve`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${authToken}`,
    },
  });
}

/**
 * @typedef {Object} ReviewComment
 * @property {number}  comment_id
 * @property {number}  resource_id
 * @property {number}  reviewer_id
 * @property {string}  [section]       - lesson JSON block type (objectives, activity, etc.)
 * @property {number}  [block_index]   - index inside lesson_content.blocks
 * @property {string}  comment
 * @property {boolean} resolved
 * @property {string}  created_at      - ISO 8601
 * @property {string}  [resolved_at]   - ISO 8601, present when resolved
 */
