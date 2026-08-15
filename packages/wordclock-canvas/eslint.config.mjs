import baseConfig from '@simonheys/eslint-config/base'

export default [...baseConfig, { ignores: ['dist/**', '**/dist/**'] }]
