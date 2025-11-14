/**
 * Logout route removed from template.
 * This file can be deleted or replaced with your own authentication system.
 */

import { NextResponse } from 'next/server'

export async function GET() {
  return NextResponse.json({ 
    message: 'Authentication has been removed from this template. Implement your own auth system as needed.' 
  })
}