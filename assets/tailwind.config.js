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
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
