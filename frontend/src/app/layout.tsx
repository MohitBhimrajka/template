import './globals.css'
import { Providers } from './providers'
import { Header } from '@/components/layout/Header'
import { Sidebar } from '@/components/layout/Sidebar'
import { Inter as FontSans } from 'next/font/google'
import { cn } from '@/lib/utils'

export const metadata = {
  title: 'Web Template',
  description: 'Full-Stack Web Application Template',
}

const fontSans = FontSans({
  subsets: ['latin'],
  variable: '--font-sans',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang='en' className='light' suppressHydrationWarning>
      <body
        className={cn(
          'bg-background min-h-screen font-sans antialiased',
          fontSans.variable
        )}
      >
        <Providers>
          <div className='grid min-h-screen w-full md:grid-cols-[240px_1fr] lg:grid-cols-[260px_1fr]'>
            <Sidebar />
            <div className='flex flex-col'>
              <Header />
              <main className='flex flex-1 flex-col gap-4 bg-gray-50 p-4 lg:gap-6 lg:p-8'>
                {children}
              </main>
            </div>
          </div>
        </Providers>
      </body>
    </html>
  )
}
