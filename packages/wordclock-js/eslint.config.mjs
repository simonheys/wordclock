import reactConfig from '@simonheys/eslint-config/react'

export default [...reactConfig, { ignores: ['dist/**', '**/dist/**'] }]
