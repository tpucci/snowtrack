const colors = require("tailwindcss/colors");

// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/snowtrack_web.ex",
    "../lib/snowtrack_web/**/*.*ex",
  ],
  theme: {
    extend: {
      colors: {
        primary: colors.sky,
        background: colors.slate,
      },
      animation: {
        appear: "scale-y 1s ease-out 1",
      },
      keyframes: {
        "scale-y": {
          "0%": { "max-height": "0", overflow: "hidden", opacity: 0 },
          "100%": { "max-height": "300px", opacity: 1 },
        },
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
