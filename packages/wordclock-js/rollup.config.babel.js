import babel from "@rollup/plugin-babel";
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import postcss from "rollup-plugin-postcss";

const config = {
  input: "./src/components/WordClock.js",

  output: {
    dir: "dist",
    format: "cjs",
    sourcemap: true,
    globals: {
      react: "React",
      "react-dom": "ReactDOM",
    },
  },

  plugins: [
    postcss({
      modules: true,
    }),
    babel({
      exclude: "**/node_modules/**",
    }),
    resolve(),
    commonjs(),
  ],

  external: ["react", "react-dom"],
};

export default config;
