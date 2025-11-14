import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  // --- BASE_PATH ADDITION START ---
  basePath: process.env.NEXT_PUBLIC_BASE_PATH || '',
  // --- BASE_PATH ADDITION END ---

  env: {
    NEXT_PUBLIC_API_URL:
      process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8001',
    INTERNAL_API_URL: process.env.INTERNAL_API_URL || 'http://backend:8000',
  },
  serverExternalPackages: [],

  // Enable source maps for production debugging
  productionBrowserSourceMaps: true,

  // Ensure TypeScript errors fail the build
  typescript: {
    ignoreBuildErrors: false,
  },

  // Development optimizations
  ...(process.env.NODE_ENV === 'development' && {
    experimental: {
      optimizePackageImports: ['@radix-ui/react-icons', 'lucide-react'],
    },

    // Optimize bundling for development
    webpack: (config: any, { dev }: { dev: boolean }) => {
      if (dev) {
        config.watchOptions = {
          poll: 1000,
          aggregateTimeout: 300,
          ignored: /node_modules/,
        }
        config.infrastructureLogging = { level: 'error' }
      }
      return config
    },
  }),
}

export default nextConfig
