import { defineConfig, mergeConfig } from "vitest/config";

import viteConfig from "./vite.config.mjs";

export default defineConfig((configEnv) =>
  mergeConfig(
    viteConfig(configEnv),
    defineConfig({
      test: {
        globals: true,
        environment: "happy-dom",
        setupFiles: "test/setup.ts",
        exclude: [
          "**/node_modules/**",
          "**/dist/**",
          "**/.{idea,git,cache,output,temp}/**",
          ".rollup.cache/**",
        ],
      },
    }),
  ),
);
