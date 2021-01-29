import Vue from "vue";
import App from "./App.vue";
import "./registerServiceWorker";
import router from "./router";
import vuetify from "./plugins/vuetify";
import vueAwesomeCountdown from "vue-awesome-countdown";

Vue.use(vueAwesomeCountdown, 'vac') // Component name, `countdown` and `vac` by default

Vue.config.productionTip = false;

new Vue({
  router,
  vuetify,
  render: (h) => h(App),
}).$mount("#app");
