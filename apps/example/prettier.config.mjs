import organizeImports from 'prettier-plugin-organize-imports'
import * as tailwindcss from 'prettier-plugin-tailwindcss'

/** @type {import('prettier').Config & import('prettier-plugin-tailwindcss').PluginOptions} */
const config = {
  singleQuote: true,
  trailingComma: 'all',
  printWidth: 100,
  semi: false,
  plugins: [organizeImports, tailwindcss],
  tailwindStylesheet: './src/app/globals.css',
  tailwindFunctions: ['clsx', 'cva', 'cn'],
}

export default config
