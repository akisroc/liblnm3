import { defineConfig } from "vite";

export default defineConfig(({ cmd }) => {
  return {
    publicDir: "../priv/static",
    build: {
      outDir: "../priv/static/assets",
      emptyOutDir: false,
      minify: cmd === "build",
      rollupOptions: {
        input: {
          app: "./js/app.js",
        },
        output: {
          entryFileNames: "app.js",
          chunkFileNames: "[name].js",
          assetFileNames: (assetInfo) => {
            const name = assetInfo.names ? assetInfo.names[0] : assetInfo.name;

            // STYLES
            if (name.endsWith(".css")) {
              return "[name][extname]";
            }

            // FONTS
            if (/\.(woff2?|eot|ttf|otf)$/.test(name)) {
              return "fonts/[name][extname]";
            }

            // IMAGES
            if (/\.(png|jpe?g|gif|svg|webp)$/.test(name)) {
              return "images/[name][extname]";
            }

            // OTHER
            return "[name][extname]";
          },
        },
      },
    },
  };
});
