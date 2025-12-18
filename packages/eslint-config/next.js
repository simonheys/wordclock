const pluginNext = require('@next/eslint-plugin-next')

const reactConfig = require('./react')

/** @type {import('eslint').Linter.FlatConfig[]} */
const nextConfig = [
  ...reactConfig,
  {
    plugins: {
      '@next/next': pluginNext,
    },
    rules: {
      ...pluginNext.configs.recommended.rules,
      ...pluginNext.configs['core-web-vitals'].rules,
    },
  },
  {
    files: ['**/next-env.d.ts'],
    rules: {
      '@typescript-eslint/triple-slash-reference': 'off',
    },
  },
]

module.exports = nextConfig
