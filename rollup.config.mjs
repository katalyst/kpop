import resolve from "@rollup/plugin-node-resolve"
import { terser } from "rollup-plugin-terser"

export default [
  {
    input: "kpop/application.js",
    output: [
      {
        name: "kpop",
        file: "app/assets/builds/katalyst/kpop.esm.js",
        format: "esm",
      },
      {
        file: "app/assets/builds/katalyst/kpop.js",
        format: "es",
      },
    ],
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails"]
  },
  {
    input: "kpop/application.js",
    output: {
      file: "app/assets/builds/katalyst/kpop.min.js",
      format: "es",
      sourcemap: true,
    },
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      }),
      terser({
        mangle: true,
        compress: true
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails"]
  }
]
