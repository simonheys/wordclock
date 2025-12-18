const pluginReact = require('eslint-plugin-react')
const pluginReactHooks = require('eslint-plugin-react-hooks')

const baseConfig = require('./base')

/** @type {import('eslint').Linter.FlatConfig[]} */
const reactConfig = [
  ...baseConfig,
  {
    ...pluginReact.configs.flat.recommended,
    settings: {
      ...pluginReact.configs.flat.recommended.settings,
      react: {
        version: 'detect',
      },
    },
  },
  {
    plugins: {
      'react-hooks': pluginReactHooks,
    },
    rules: {
      ...pluginReactHooks.configs.recommended.rules,
      'react/react-in-jsx-scope': 'off',
      'react/jsx-curly-brace-presence': 'error',
    },
  },
]

module.exports = reactConfig
