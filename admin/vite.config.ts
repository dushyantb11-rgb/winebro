import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { fileURLToPath, URL } from "node:url";

// Local dev talks to the deployed API; production is same-origin via
// Firebase Hosting rewrite (/api/** -> adminApi).
export default defineConfig({
  plugins: [react()],
  resolve: { alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) } },
  server: {
    port: 5180,
    proxy: {
      "/api": {
        target: "https://asia-south1-winebro.cloudfunctions.net/adminApi",
        changeOrigin: true,
      },
    },
  },
  build: { sourcemap: false, chunkSizeWarningLimit: 1500 },
});
