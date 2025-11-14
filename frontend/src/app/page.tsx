'use client'

import { useState } from 'react'
import apiClient from '@/lib/api-client'
import { AccentButton, NavyButton } from '@/components/ui/accent-button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { TrendingUp, Users, Activity, CheckCircle2 } from 'lucide-react'

// Stats Card Component
const StatCard = ({
  title,
  value,
  icon: Icon,
  trend,
  color,
}: {
  title: string
  value: string
  icon: React.ElementType
  trend?: string
  color: string
}) => (
  <Card className='border-0 bg-white shadow-sm transition-shadow hover:shadow-md'>
    <CardContent className='p-6'>
      <div className='flex items-center justify-between'>
        <div className='space-y-2'>
          <p className='text-sm font-medium text-gray-600'>{title}</p>
          <p className='text-3xl font-bold text-gray-900'>{value}</p>
          {trend && (
            <p className='flex items-center text-sm text-gray-500'>
              <TrendingUp className='mr-1 h-4 w-4 text-green-500' />
              {trend}
            </p>
          )}
        </div>
        <div className={`rounded-2xl ${color} p-4`}>
          <Icon className='h-8 w-8 text-white' />
        </div>
      </div>
    </CardContent>
  </Card>
)

export default function HomePage() {
  const [apiResponse, setApiResponse] = useState<string>('')
  const [adminResponse, setAdminResponse] = useState<string>('')
  const [isLoading, setIsLoading] = useState(false)

  const callApi = async (
    endpoint: string,
    setter: React.Dispatch<React.SetStateAction<string>>
  ) => {
    setIsLoading(true)
    setter('Loading...')
    try {
      const data = await apiClient(endpoint)
      setter(JSON.stringify(data, null, 2))
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error'
      setter(`Error: ${errorMessage}`)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className='space-y-8'>
      {/* Welcome Section */}
      <div>
        <h1 className='text-4xl font-bold text-gray-900'>
          Welcome to Your Template!
        </h1>
        <p className='mt-2 text-lg text-gray-600'>
          This is a clean template without authentication. Add your own auth system as needed.
        </p>
      </div>

      {/* Example Stats Grid */}
      <div className='grid gap-6 md:grid-cols-2 lg:grid-cols-4'>
        <StatCard
          title='Example 1'
          value='10K+'
          icon={Users}
          trend='+12% from last month'
          color='bg-[#000b37]'
        />
        <StatCard
          title='Example 2'
          value='500K+'
          icon={Activity}
          trend='+8% from last month'
          color='bg-[#85c20b]'
        />
        <StatCard
          title='Example 3'
          value='98%'
          icon={CheckCircle2}
          trend='+2% from last month'
          color='bg-blue-500'
        />
        <StatCard
          title='Example 4'
          value='50%'
          icon={TrendingUp}
          trend='Faster processing'
          color='bg-purple-500'
        />
      </div>

      {/* Main Content Grid */}
      <div className='grid gap-6 lg:grid-cols-2'>
        {/* API Tests Card */}
        <Card className='border-0 bg-white shadow-sm'>
          <CardHeader className='border-b border-gray-100'>
            <CardTitle className='text-xl font-semibold text-gray-900'>
              API Endpoint Tests
            </CardTitle>
          </CardHeader>
          <CardContent className='space-y-6 p-6'>
            <div className='space-y-3'>
              <p className='text-sm font-medium text-gray-700'>
                Call Test Endpoint (No Auth Required)
              </p>
              <NavyButton
                onClick={() => callApi('/api/test', setApiResponse)}
                disabled={isLoading}
                className='w-full'
              >
                {isLoading ? 'Calling...' : 'Test API'}
              </NavyButton>
              {apiResponse && (
                <div className='mt-4 rounded-lg border border-gray-200 bg-gray-50 p-4'>
                  <pre className='overflow-x-auto text-xs text-gray-700'>
                    <code>{apiResponse}</code>
                  </pre>
                </div>
              )}
            </div>
            <div className='space-y-3'>
              <p className='text-sm font-medium text-gray-700'>
                Call Admin Endpoint (No Auth Required)
              </p>
              <AccentButton
                onClick={() =>
                  callApi('/api/admin/dashboard', setAdminResponse)
                }
                disabled={isLoading}
                className='w-full'
              >
                {isLoading ? 'Calling...' : 'Test Admin API'}
              </AccentButton>
              {adminResponse && (
                <div className='mt-4 rounded-lg border border-gray-200 bg-gray-50 p-4'>
                  <pre className='overflow-x-auto text-xs text-gray-700'>
                    <code>{adminResponse}</code>
                  </pre>
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Example Tabs Card */}
        <Card className='border-0 bg-white shadow-sm'>
          <CardHeader className='border-b border-gray-100'>
            <CardTitle className='text-xl font-semibold text-gray-900'>
              Example Tabs
            </CardTitle>
          </CardHeader>
          <CardContent className='p-6'>
            <div className='space-y-4'>
              <div className='flex space-x-1 rounded-lg bg-gray-100 p-1'>
                <button className='flex-1 rounded-md bg-white px-3 py-2 text-sm font-medium text-gray-900 shadow-sm'>
                  Tab 1
                </button>
                <button className='flex-1 rounded-md px-3 py-2 text-sm font-medium text-gray-500 hover:text-gray-900'>
                  Tab 2
                </button>
                <button className='flex-1 rounded-md px-3 py-2 text-sm font-medium text-gray-500 hover:text-gray-900'>
                  Tab 3
                </button>
              </div>
              
              <div className='mt-6 rounded-lg border border-blue-200 bg-blue-50 p-4'>
                <p className='text-blue-800 font-medium'>Build Your Own</p>
                <p className='mt-2 text-sm text-blue-700'>
                  This is a template interface. Customize these tabs and components to build your own application features.
                </p>
                <ul className='mt-3 space-y-1 text-sm text-blue-700'>
                  <li>• Replace with your content</li>
                  <li>• Add interactive functionality</li>
                  <li>• Connect to your backend APIs</li>
                  <li>• Style to match your brand</li>
                </ul>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
