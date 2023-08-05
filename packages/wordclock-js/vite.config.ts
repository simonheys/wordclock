import path from "path";

import react from "@vitejs/plugin-react-swc";
import { defineConfig } from "vite";
import dts from "vite-plugin-dts";

export default defineConfig({
  publicDir: false,
  plugins: [
    dts({
      rollupTypes: true,
    }),
    react(),
  ],
  build: {
    lib: {
      entry: path.resolve(__dirname, "src/components/index.ts"),
      name: "wordclock",
      formats: ["es", "umd"],
      fileName: (format) => `wordclock.${format}.js`,
    },
    rollupOptions: {
      external: ["react", "react-dom", "react/jsx-runtime", "lodash"],
    },
  },
  esbuild: {
    pure: process.env.NODE_ENV === "production" ? ["console.log"] : [],
  },
});
