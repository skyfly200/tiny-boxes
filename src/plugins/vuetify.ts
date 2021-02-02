import Vue from "vue";
import Vuetify from "vuetify/lib";
import "./overrides.sass";
import { preset } from 'vue-cli-plugin-vuetify-preset-shrine/preset'
import OpenSeaIcon from "@/components/OpenSeaIcon.vue";

Vue.use(Vuetify);

export default new Vuetify({
  preset,
  theme: {
    dark: true,
    themes: {
      dark: {
        primary: "#5F51B5",
        secondary: "#009688",
        accent: "#cddc39",
        error: "#ff5722",
        warning: "#ff9800",
        info: "#2196f3",
        success: "#4caf50"
      }
    }
  },
  icons: {
    values: {
      custom: { // name of our custom icon
        component: OpenSeaIcon, // our custom component
      },
    },
  },
});
