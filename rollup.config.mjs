import resolve from "@rollup/plugin-node-resolve";
import { terser } from "rollup-plugin-terser";
import pkg from "./package.json" assert { type: "json" };
import path from "path";

export default [
  {
    input: "katalyst/kpop.js",
    output: {
      file: "app/assets/builds/katalyst/kpop.js",
      format: "esm",
      inlineDynamicImports: true
    },
    plugins: [
      resolve({
        modulePaths: [path.join(process.cwd(), 'app/assets/javascripts')],
      }),
      terser({
        mangle: false,
        compress: false,
        format: {
          beautify: true,
          indent_level: 2
        }
      })
    ]
  },
  {
    input: "katalyst/kpop.js",
    output: {
      file: "app/assets/builds/katalyst/kpop.min.js",
      format: "esm",
      inlineDynamicImports: true
    },
    plugins: [
      resolve({
        modulePaths: [path.join(process.cwd(), 'app/assets/javascripts')],
      }),
      terser({
        mangle: true,
        compress: true
      })
    ]
  }
]
