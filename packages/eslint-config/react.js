import eslintReact from '@eslint-react/eslint-plugin'
import pluginReactHooks from 'eslint-plugin-react-hooks'

import baseConfig from './base.js'

/** @type {import('eslint').Linter.FlatConfig[]} */
const reactConfig = [
  ...baseConfig,
  eslintReact.configs['recommended-typescript'],
  {
    plugins: {
      'react-hooks': pluginReactHooks,
    },
    rules: {
      ...pluginReactHooks.configs.recommended.rules,
      '@eslint-react/no-array-index-key': 'off',
      '@eslint-react/no-use-context': 'off',
      '@eslint-react/set-state-in-effect': 'off',
    },
  },
]

export default reactConfig
