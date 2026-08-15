import { resolve } from 'node:path'

import { defineConfig } from 'vite'
import dts from 'vite-plugin-dts'

export default defineConfig(() => ({
  publicDir: false,
  plugins: [
    dts({
      bundleTypes: true,
      exclude: ['src/**/*.test.*'],
    }),
  ],
  build: {
    lib: {
      entry: resolve(import.meta.dirname, 'src/index.ts'),
      fileName: (format) => (format === 'es' ? 'wordclock-canvas.js' : 'wordclock-canvas.cjs'),
      formats: ['es', 'cjs'],
      name: 'wordclockCanvas',
    },
    rolldownOptions: {
      output: {
        exports: 'named',
      },
    },
  },
}))
