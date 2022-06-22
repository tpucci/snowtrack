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
        notify:
          "slide-from-right .3s cubic-bezier(.24,1.66,.75,.78) forwards, scale .3s cubic-bezier(.24,1.66,.75,.78) forwards, fade-in .5s ease-out forwards",
      },
      keyframes: {
        "scale-y": {
          "0%": { "max-height": "0", overflow: "hidden", opacity: 0 },
          "100%": { "max-height": "300px", opacity: 1 },
        },
        flash: {
          "0%": { right: "0", opacity: 0 },
          "10%": { right: "1em", opacity: 1 },
          "90%": { right: "1em", opacity: 1 },
          "100%": { right: "0", opacity: 0, visibility: "hidden" },
        },
        "slide-from-right": {
          "0%": { right: "-4em" },
          "100%": { right: "1em" },
        },
        "fade-in": {
          "0%": { opacity: 0 },
          "100%": { opacity: 1 },
        },
        scale: {
          "0%": { transform: "scale(0.5)" },
          "100%": { transform: "scale(1)" },
        },
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
