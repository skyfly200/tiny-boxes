<template lang="pug">
  v-app
    Nav(v-if="this.$route.path !== '/'")
    v-content
      router-view
</template>

<script>
import Vue from "vue";
import Nav from "@/components/Nav.vue";
import Axios from 'axios'

Vue.prototype.$http = Axios;

export default Vue.extend({
  name: "App",
  components: { Nav },
  computed: {
    page() {
      const route = this.$route.name;
      if (route === "Cell") return "Collection";
      // show cell page as collection route
      else return route;
    }
  }
});
</script>

<style lang="sass">
body
  margin: 0
  background-color: #121212
  font-family: sans-serif
.title
  font-family: "Pangolin"
  font-size: 2rem
  color: #ffffff !important
  text-decoration: none
</style>
