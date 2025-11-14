// frontend/src/middleware.ts
/**
 * Middleware simplified - no authentication required.
 * Add your own middleware logic as needed.
 */
import { NextResponse } from 'next/server'

export function middleware() {
  // No authentication or access control - all requests are allowed
  // Add your own middleware logic here as needed
  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
