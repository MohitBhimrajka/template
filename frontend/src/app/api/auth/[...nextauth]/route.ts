// frontend/src/app/api/auth/[...nextauth]/route.ts
/**
 * Authentication removed from template.
 * This file can be deleted or replaced with your own authentication system.
 * All backend endpoints are now public by default.
 */

import { NextResponse } from 'next/server'

export async function GET() {
  return NextResponse.json({ 
    message: 'Authentication has been removed from this template. Implement your own auth system as needed.' 
  })
}

export async function POST() {
  return NextResponse.json({ 
    message: 'Authentication has been removed from this template. Implement your own auth system as needed.' 
  })
}
