import { resolve } from 'node:path'

import react from '@vitejs/plugin-react-swc'
import { defineConfig } from 'vite'
import dts from 'vite-plugin-dts'

const external = ['react', 'react-dom', 'react/jsx-runtime', 'resize-observer-polyfill']
const clientDirective = "'use client';"

export default defineConfig(({ mode }) => ({
  publicDir: false,
  plugins: [
    dts({
      exclude: ['src/**/*.test.*', 'test/**'],
      rollupTypes: true,
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
    rollupOptions: {
      external,
      output: {
        banner: clientDirective,
        exports: 'named',
      },
    },
  },
  esbuild: {
    pure: mode === 'production' ? ['console.log', 'console.warn'] : [],
  },
}))
