const js = require('@eslint/js')
const eslintConfigPrettier = require('eslint-config-prettier')
const onlyWarn = require('eslint-plugin-only-warn')
const tseslint = require('typescript-eslint')

/** @type {import('eslint').Linter.FlatConfig[]} */
const baseConfig = [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  eslintConfigPrettier,
  {
    plugins: {
      onlyWarn,
    },
  },
  {
    rules: {
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          destructuredArrayIgnorePattern: '^_',
          caughtErrorsIgnorePattern: '^_',
        },
      ],
    },
  },
  {
    ignores: ['dist/**', 'node_modules/**', 'build/**', '.next/**', '.turbo/**'],
  },
]

module.exports = baseConfig
