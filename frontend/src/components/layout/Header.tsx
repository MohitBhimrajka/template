'use client'

import Link from 'next/link'

export function Header() {
  return (
    <header className='sticky top-0 z-10 w-full border-b border-gray-200 bg-white/95 backdrop-blur supports-[backdrop-filter]:bg-white/80'>
      <div className='flex h-16 items-center justify-between px-6'>
        <div className='mr-4 hidden md:flex'>
          <Link href='/' className='mr-6 flex items-center space-x-2'>
            <span className='text-xl font-semibold text-[#000b37]'>
              Web Template
            </span>
          </Link>
        </div>
        <div className='flex flex-1 items-center justify-end space-x-2'>
          <span className='text-sm text-gray-600'>
            No authentication required - Template ready for customization
          </span>
        </div>
      </div>
    </header>
  )
}
