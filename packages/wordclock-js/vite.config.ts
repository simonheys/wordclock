import { defineConfig } from 'vite'
import { dts } from 'rolldown-plugin-dts'

export default defineConfig(({ mode }) => ({
  plugins:
    mode === 'types'
      ? [dts({ generator: 'tsgo', emitDtsOnly: true, tsconfig: 'tsconfig.build.json' })]
      : [],
  oxc: { exclude: [/\.js$/, /\.d\.[cm]?ts$/] },
  build: {
    emptyOutDir: mode !== 'types',
    minify: false,
    lib: {
      entry: 'src/index.ts',
      formats: mode === 'types' ? ['es'] : ['es', 'cjs'],
      fileName: (format, name) => `${name}.${format === 'es' ? 'js' : 'cjs'}`,
    },
    rolldownOptions: {
      external: [/^react(?:\/|$)/, /^react-dom(?:\/|$)/, 'resize-observer-polyfill'],
      output: { banner: mode === 'types' ? '' : "'use client';" },
    },
  },
}))
