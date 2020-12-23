import Vue from "vue";
import Vuetify from "vuetify/lib";
import "./overrides.sass";

Vue.use(Vuetify);

export default new Vuetify({
  theme: {
    dark: true,
    themes: {
      dark: {
        primary: "#009688",
        secondary: "#795548",
        accent: "#cddc39",
        error: "#ff5722",
        warning: "#ff9800",
        info: "#2196f3",
        success: "#4caf50"
      }
    }
  }
});
