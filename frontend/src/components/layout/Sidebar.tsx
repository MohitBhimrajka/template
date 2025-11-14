'use client'
import { LayoutDashboard, Settings, BotMessageSquare } from 'lucide-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

// Dummy NavLink component for demonstration
const NavLink = ({
  href,
  children,
  icon: Icon,
}: {
  href: string
  children: React.ReactNode
  icon: React.ElementType
}) => {
  const pathname = usePathname()
  const isActive = pathname === href

  return (
    <Link
      href={href}
      className={`flex items-center gap-3 rounded-lg px-4 py-3 text-sm font-medium transition-all ${
        isActive
          ? 'bg-[#000b37] text-white'
          : 'text-gray-700 hover:bg-gray-100 hover:text-[#000b37]'
      }`}
    >
      <Icon className='h-5 w-5' />
      {children}
    </Link>
  )
}

export function Sidebar() {
  return (
    <div className='hidden border-r border-gray-200 bg-white md:block'>
      <div className='flex h-full max-h-screen flex-col gap-2'>
        <div className='flex h-16 items-center border-b border-gray-200 px-6'>
          <Link href='/' className='flex items-center gap-2'>
            <div className='flex h-8 w-8 items-center justify-center rounded-lg bg-[#000b37]'>
              <span className='text-lg font-bold text-white'>W</span>
            </div>
            <span className='text-lg font-semibold text-[#000b37]'>Web Template</span>
          </Link>
        </div>
        <div className='flex-1 px-3 py-4'>
          <nav className='grid gap-1'>
            <NavLink href='/' icon={LayoutDashboard}>
              Dashboard
            </NavLink>
            <NavLink href='/workbench' icon={BotMessageSquare}>
              Workbench
            </NavLink>
            <NavLink href='/settings' icon={Settings}>
              Settings
            </NavLink>
          </nav>
        </div>
      </div>
    </div>
  )
}
