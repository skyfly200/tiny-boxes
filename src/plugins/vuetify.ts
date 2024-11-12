import Vue from "vue";
import Vuetify from "vuetify/lib";
import "./overrides.sass";
import { preset } from 'vue-cli-plugin-vuetify-preset-shrine/preset'
import OpenSeaIcon from "@/components/OpenSeaIcon.vue";
import DiscordIcon from "@/components/DiscordIcon.vue";
import RaribleIcon from "@/components/RaribleIcon.vue";

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
      opensea: { // name of our custom icon
        component: OpenSeaIcon, // our custom component
      },
      discord: { // name of our custom icon
        component: DiscordIcon, // our custom component
      },
      rarible: { // name of our custom icon
        component: RaribleIcon, // our custom component
      },
    },
  },
});
