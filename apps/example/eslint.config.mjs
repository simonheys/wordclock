import nextConfig from '@simonheys/eslint-config/next'

export default [...nextConfig, { ignores: ['.next/**', 'dist/**'] }]
