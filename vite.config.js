import { defineConfig } from "vite";
import melangePlugin from "vite-plugin-melange";

export default defineConfig({
  //base: "/belenios-mel-verifier/",
  plugins: [
    melangePlugin({
      emitDir: "src",
      buildCommand: "opam exec -- dune build @app",
      watchCommand: "opam exec -- dune build --watch @app",
    }),
  ],
  server: {
    watch: {
      awaitWriteFinish: {
        stabilityThreshold: 500,
        pollInterval: 20,
      },
    },
  },
});
