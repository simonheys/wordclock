import path from 'path'

import react from '@vitejs/plugin-react-swc'
import { defineConfig } from 'vite'
import dts from 'vite-plugin-dts'

export default defineConfig(({ mode }) => ({
  publicDir: false,
  plugins: [
    dts({
      rollupTypes: true,
    }),
    react(),
  ],
  build: {
    lib: {
      entry: path.resolve(__dirname, 'src/components/index.ts'),
      name: 'wordclock',
    },
    rollupOptions: {
      external: ['react', 'react-dom', 'react/jsx-runtime', 'lodash-es'],
    },
  },
  esbuild: {
    pure: mode === 'production' ? ['console.log', 'console.warn'] : [],
  },
}))
