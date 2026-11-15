import path from 'node:path'
import { copyFileSync } from 'node:fs'
import tailwindcss from '@tailwindcss/vite'
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
    {
      // Hosts that fall back to 404.html for unknown paths still need to boot
      // the single-page app on /docs and friends.
      name: 'spa-fallback',
      apply: 'build',
      writeBundle() {
        copyFileSync('dist/index.html', 'dist/404.html')
      },
    },
  ],
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
    },
  },
  build: {
    // Split the vendors that every route needs into their own chunks so the
    // entry stays small and long-lived dependencies keep their cache hash.
    rolldownOptions: {
      output: {
        codeSplitting: {
          groups: [
            {
              name: 'react',
              test: /node_modules[\\/](react|react-dom|scheduler|react-router|react-router-dom)[\\/]/,
              priority: 3,
            },
            {
              name: 'motion',
              test: /node_modules[\\/](motion|framer-motion|motion-dom|motion-utils)[\\/]/,
              priority: 2,
            },
            {
              name: 'ui-vendor',
              test: /node_modules[\\/](@radix-ui|radix-ui|cmdk|embla-carousel|embla-carousel-react|embla-carousel-autoplay)[\\/]/,
              priority: 1,
            },
          ],
        },
      },
    },
  },
})
