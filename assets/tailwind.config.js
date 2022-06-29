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
          "slide-from-right .5s ease-out forwards, fade-in .5s ease-out forwards",
      },
      keyframes: {
        "scale-y": {
          "0%": { "max-height": "0", overflow: "hidden", opacity: 0 },
          "100%": { "max-height": "300px", opacity: 1 },
        },
        "slide-from-right": {
          "0%": {
            transform:
              "perspective(50rem) translateZ(-20rem) rotateY(60deg) translateZ(20rem)",
          },
          "80%": {
            transform:
              "perspective(50rem) translateZ(-20rem) rotateY(-2deg) translateZ(20rem)",
          },
          "100%": {
            transform:
              "perspective(50rem) translateZ(-20rem) rotateY(0deg) translateZ(20rem)",
          },
        },
        "fade-in": {
          "0%": { opacity: 0 },
          "100%": { opacity: 1 },
        },
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
