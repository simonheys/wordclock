// vitest.config.mts
import {
  defineConfig as defineConfig2,
  mergeConfig,
} from 'file:///Applications/MAMP/htdocs/wordclock/node_modules/.pnpm/vitest@2.1.8_@types+node@22.10.5_happy-dom@16.3.0_jsdom@16.7.0_sass@1.80.3/node_modules/vitest/dist/config.js'

// vite.config.mts
import react from 'file:///Applications/MAMP/htdocs/wordclock/node_modules/.pnpm/@vitejs+plugin-react-swc@3.7.2_@swc+helpers@0.5.15_vite@6.0.7_@types+node@22.10.5_jiti@_24b61740c68ca2eedf46f9d2790ad514/node_modules/@vitejs/plugin-react-swc/index.mjs'
import dts from 'file:///Applications/MAMP/htdocs/wordclock/node_modules/.pnpm/vite-plugin-dts@4.4.0_@types+node@22.10.5_rollup@4.24.0_typescript@5.7.2_vite@6.0.7_@ty_d756a2358eb258ca024d23d5799dc8ae/node_modules/vite-plugin-dts/dist/index.mjs'
import { defineConfig } from 'file:///Applications/MAMP/htdocs/wordclock/node_modules/.pnpm/vite@6.0.7_@types+node@22.10.5_jiti@1.21.6_sass@1.80.3_tsx@4.20.3_yaml@2.6.1/node_modules/vite/dist/node/index.js'
import path from 'path'
var __vite_injected_original_dirname = '/Applications/MAMP/htdocs/wordclock/packages/wordclock-js'
var vite_config_default = defineConfig(({ mode }) => ({
  publicDir: false,
  plugins: [
    dts({
      rollupTypes: true,
    }),
    react(),
  ],
  build: {
    lib: {
      entry: path.resolve(__vite_injected_original_dirname, 'src/components/index.ts'),
      name: 'wordclock',
    },
    rollupOptions: {
      external: ['react', 'react-dom', 'react/jsx-runtime', 'lodash-es'],
    },
  },
  esbuild: {
    pure: mode === 'production' ? ['console.log', 'console.warn'] : [],
  },
}))

// vitest.config.mts
var vitest_config_default = defineConfig2((configEnv) =>
  mergeConfig(
    vite_config_default(configEnv),
    defineConfig2({
      test: {
        globals: true,
        environment: 'happy-dom',
        setupFiles: 'test/setup.ts',
        exclude: [
          '**/node_modules/**',
          '**/dist/**',
          '**/.{idea,git,cache,output,temp}/**',
          '.rollup.cache/**',
        ],
      },
    }),
  ),
)
export { vitest_config_default as default }
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZXN0LmNvbmZpZy5tdHMiLCAidml0ZS5jb25maWcubXRzIl0sCiAgInNvdXJjZXNDb250ZW50IjogWyJjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfZGlybmFtZSA9IFwiL0FwcGxpY2F0aW9ucy9NQU1QL2h0ZG9jcy93b3JkY2xvY2svcGFja2FnZXMvd29yZGNsb2NrLWpzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ZpbGVuYW1lID0gXCIvQXBwbGljYXRpb25zL01BTVAvaHRkb2NzL3dvcmRjbG9jay9wYWNrYWdlcy93b3JkY2xvY2stanMvdml0ZXN0LmNvbmZpZy5tdHNcIjtjb25zdCBfX3ZpdGVfaW5qZWN0ZWRfb3JpZ2luYWxfaW1wb3J0X21ldGFfdXJsID0gXCJmaWxlOi8vL0FwcGxpY2F0aW9ucy9NQU1QL2h0ZG9jcy93b3JkY2xvY2svcGFja2FnZXMvd29yZGNsb2NrLWpzL3ZpdGVzdC5jb25maWcubXRzXCI7aW1wb3J0IHsgZGVmaW5lQ29uZmlnLCBtZXJnZUNvbmZpZyB9IGZyb20gXCJ2aXRlc3QvY29uZmlnXCI7XG5cbmltcG9ydCB2aXRlQ29uZmlnIGZyb20gXCIuL3ZpdGUuY29uZmlnLm1qc1wiO1xuXG5leHBvcnQgZGVmYXVsdCBkZWZpbmVDb25maWcoKGNvbmZpZ0VudikgPT5cbiAgbWVyZ2VDb25maWcoXG4gICAgdml0ZUNvbmZpZyhjb25maWdFbnYpLFxuICAgIGRlZmluZUNvbmZpZyh7XG4gICAgICB0ZXN0OiB7XG4gICAgICAgIGdsb2JhbHM6IHRydWUsXG4gICAgICAgIGVudmlyb25tZW50OiBcImhhcHB5LWRvbVwiLFxuICAgICAgICBzZXR1cEZpbGVzOiBcInRlc3Qvc2V0dXAudHNcIixcbiAgICAgICAgZXhjbHVkZTogW1xuICAgICAgICAgIFwiKiovbm9kZV9tb2R1bGVzLyoqXCIsXG4gICAgICAgICAgXCIqKi9kaXN0LyoqXCIsXG4gICAgICAgICAgXCIqKi8ue2lkZWEsZ2l0LGNhY2hlLG91dHB1dCx0ZW1wfS8qKlwiLFxuICAgICAgICAgIFwiLnJvbGx1cC5jYWNoZS8qKlwiLFxuICAgICAgICBdLFxuICAgICAgfSxcbiAgICB9KSxcbiAgKSxcbik7XG4iLCAiY29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2Rpcm5hbWUgPSBcIi9BcHBsaWNhdGlvbnMvTUFNUC9odGRvY3Mvd29yZGNsb2NrL3BhY2thZ2VzL3dvcmRjbG9jay1qc1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9maWxlbmFtZSA9IFwiL0FwcGxpY2F0aW9ucy9NQU1QL2h0ZG9jcy93b3JkY2xvY2svcGFja2FnZXMvd29yZGNsb2NrLWpzL3ZpdGUuY29uZmlnLm10c1wiO2NvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9pbXBvcnRfbWV0YV91cmwgPSBcImZpbGU6Ly8vQXBwbGljYXRpb25zL01BTVAvaHRkb2NzL3dvcmRjbG9jay9wYWNrYWdlcy93b3JkY2xvY2stanMvdml0ZS5jb25maWcubXRzXCI7aW1wb3J0IHBhdGggZnJvbSBcInBhdGhcIjtcblxuaW1wb3J0IHJlYWN0IGZyb20gXCJAdml0ZWpzL3BsdWdpbi1yZWFjdC1zd2NcIjtcbmltcG9ydCB7IGRlZmluZUNvbmZpZyB9IGZyb20gXCJ2aXRlXCI7XG5pbXBvcnQgZHRzIGZyb20gXCJ2aXRlLXBsdWdpbi1kdHNcIjtcblxuZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKCh7IG1vZGUgfSkgPT4gKHtcbiAgcHVibGljRGlyOiBmYWxzZSxcbiAgcGx1Z2luczogW1xuICAgIGR0cyh7XG4gICAgICByb2xsdXBUeXBlczogdHJ1ZSxcbiAgICB9KSxcbiAgICByZWFjdCgpLFxuICBdLFxuICBidWlsZDoge1xuICAgIGxpYjoge1xuICAgICAgZW50cnk6IHBhdGgucmVzb2x2ZShfX2Rpcm5hbWUsIFwic3JjL2NvbXBvbmVudHMvaW5kZXgudHNcIiksXG4gICAgICBuYW1lOiBcIndvcmRjbG9ja1wiLFxuICAgIH0sXG4gICAgcm9sbHVwT3B0aW9uczoge1xuICAgICAgZXh0ZXJuYWw6IFtcInJlYWN0XCIsIFwicmVhY3QtZG9tXCIsIFwicmVhY3QvanN4LXJ1bnRpbWVcIiwgXCJsb2Rhc2gtZXNcIl0sXG4gICAgfSxcbiAgfSxcbiAgZXNidWlsZDoge1xuICAgIHB1cmU6IG1vZGUgPT09IFwicHJvZHVjdGlvblwiID8gW1wiY29uc29sZS5sb2dcIiwgXCJjb25zb2xlLndhcm5cIl0gOiBbXSxcbiAgfSxcbn0pKTtcbiJdLAogICJtYXBwaW5ncyI6ICI7QUFBbVcsU0FBUyxnQkFBQUEsZUFBYyxtQkFBbUI7OztBQ0E5QyxPQUFPLFVBQVU7QUFFaFgsT0FBTyxXQUFXO0FBQ2xCLFNBQVMsb0JBQW9CO0FBQzdCLE9BQU8sU0FBUztBQUpoQixJQUFNLG1DQUFtQztBQU16QyxJQUFPLHNCQUFRLGFBQWEsQ0FBQyxFQUFFLEtBQUssT0FBTztBQUFBLEVBQ3pDLFdBQVc7QUFBQSxFQUNYLFNBQVM7QUFBQSxJQUNQLElBQUk7QUFBQSxNQUNGLGFBQWE7QUFBQSxJQUNmLENBQUM7QUFBQSxJQUNELE1BQU07QUFBQSxFQUNSO0FBQUEsRUFDQSxPQUFPO0FBQUEsSUFDTCxLQUFLO0FBQUEsTUFDSCxPQUFPLEtBQUssUUFBUSxrQ0FBVyx5QkFBeUI7QUFBQSxNQUN4RCxNQUFNO0FBQUEsSUFDUjtBQUFBLElBQ0EsZUFBZTtBQUFBLE1BQ2IsVUFBVSxDQUFDLFNBQVMsYUFBYSxxQkFBcUIsV0FBVztBQUFBLElBQ25FO0FBQUEsRUFDRjtBQUFBLEVBQ0EsU0FBUztBQUFBLElBQ1AsTUFBTSxTQUFTLGVBQWUsQ0FBQyxlQUFlLGNBQWMsSUFBSSxDQUFDO0FBQUEsRUFDbkU7QUFDRixFQUFFOzs7QUR0QkYsSUFBTyx3QkFBUUM7QUFBQSxFQUFhLENBQUMsY0FDM0I7QUFBQSxJQUNFLG9CQUFXLFNBQVM7QUFBQSxJQUNwQkEsY0FBYTtBQUFBLE1BQ1gsTUFBTTtBQUFBLFFBQ0osU0FBUztBQUFBLFFBQ1QsYUFBYTtBQUFBLFFBQ2IsWUFBWTtBQUFBLFFBQ1osU0FBUztBQUFBLFVBQ1A7QUFBQSxVQUNBO0FBQUEsVUFDQTtBQUFBLFVBQ0E7QUFBQSxRQUNGO0FBQUEsTUFDRjtBQUFBLElBQ0YsQ0FBQztBQUFBLEVBQ0g7QUFDRjsiLAogICJuYW1lcyI6IFsiZGVmaW5lQ29uZmlnIiwgImRlZmluZUNvbmZpZyJdCn0K
