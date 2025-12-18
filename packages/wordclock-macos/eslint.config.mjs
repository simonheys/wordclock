import js from '@eslint/js'

export default [
  js.configs.recommended,
  {
    languageOptions: {
      sourceType: 'module',
    },
  },
  {
    ignores: ['dist/**', 'node_modules/**'],
  },
]
