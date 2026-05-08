import { resolve } from 'node:path'

import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import dts from 'vite-plugin-dts'

const external = ['react', 'react-dom', 'react/jsx-runtime', 'resize-observer-polyfill']
const clientDirective = "'use client';"
const pureConsoleCalls = ['console.log', 'console.warn']

export default defineConfig(({ mode }) => ({
  publicDir: false,
  plugins: [
    dts({
      bundleTypes: true,
      exclude: ['src/**/*.test.*', 'test/**'],
    }),
    react(),
  ],
  build: {
    lib: {
      entry: resolve(import.meta.dirname, 'src/components/index.ts'),
      fileName: (format) => {
        if (format === 'es') {
          return 'wordclock.js'
        }
        return 'wordclock.cjs'
      },
      formats: ['es', 'cjs'],
      name: 'wordclock',
    },
    rolldownOptions: {
      external,
      ...(mode === 'production'
        ? {
            treeshake: {
              manualPureFunctions: pureConsoleCalls,
            },
          }
        : {}),
      output: {
        banner: clientDirective,
        exports: 'named',
      },
    },
  },
}))
