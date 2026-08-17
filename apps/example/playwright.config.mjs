import { defineConfig, devices } from '@playwright/test'
import { dirname, resolve } from 'node:path'
import process from 'node:process'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const repositoryRoot = resolve(__dirname, '../..')
const port = Number(process.env.PORT ?? 3100)
const baseURL = process.env.PLAYWRIGHT_BASE_URL ?? `http://127.0.0.1:${port}`
const webServer = process.env.PLAYWRIGHT_BASE_URL
  ? undefined
  : {
      command: `pnpm --filter @wordclock/react build && pnpm --filter @wordclock/example dev --hostname 127.0.0.1 --port ${port}`,
      cwd: repositoryRoot,
      reuseExistingServer: !process.env.CI,
      timeout: 120000,
      url: baseURL,
    }

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? [['github'], ['list']] : 'list',
  use: {
    baseURL,
    screenshot: 'off',
    trace: 'off',
    video: 'off',
  },
  webServer,
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
})
