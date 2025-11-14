const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8001'
const BASE_PATH = process.env.NEXT_PUBLIC_BASE_PATH || ''

/**
 * Simplified API client without authentication.
 * @param endpoint The API endpoint to call, e.g., '/api/test' or '/api/admin/dashboard'.
 *                 The endpoint should include the '/api' prefix.
 * @param options Standard fetch options (method, body, etc.).
 */
async function apiClient(endpoint: string, options: RequestInit = {}) {
  const headers = new Headers(options.headers || {})
  
  // Set default headers
  headers.set('Content-Type', 'application/json')

  // Construct the full URL: http://localhost:8001/api/test
  const fullUrl = `${API_URL}${BASE_PATH}${endpoint}`

  const response = await fetch(fullUrl, { ...options, headers })

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({
      detail: response.statusText,
    }))
    throw new Error(errorData.detail || 'An API error occurred.')
  }

  // Handle responses with no content
  if (response.status === 204) {
    return null
  }

  return response.json()
}

export default apiClient
