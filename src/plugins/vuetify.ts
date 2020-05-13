import Vue from "vue";
import Vuetify from "vuetify";

Vue.use(Vuetify);

export default new Vuetify({
  theme: {
    dark: true,
    themes: {
      dark: {
        primary: "#673ab7",
        secondary: "#ffc107",
        accent: "#607d8b",
        error: "#ff5722",
        warning: "#ff9800",
        info: "#2196f3",
        success: "#4caf50"
      }
    }
  }
});
