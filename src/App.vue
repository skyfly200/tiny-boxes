<template lang="pug">
  v-app
    Nav(v-if="this.$route.path !== '/'")
    v-content
      router-view
    v-bottom-navigation.bottom-nav(v-if="this.$route.path !== '/'" :value="page" color="secondary" app shift grow)
      v-btn(to="/about" value="About")
        span About
        v-icon mdi-information
      v-btn(to="/collection" value="Collection")
        span Collection
        v-icon mdi-scatter-plot-outline
      v-btn(to="/guide" value="Guide")
        span Guide
        v-icon mdi-book-open-page-variant
</template>

<script>
import Vue from "vue";
import Nav from "@/components/Nav.vue";

export default Vue.extend({
  name: "App",
  components: { Nav },
  computed: {
    page() {
      const route = this.$route.name;
      if (route === 'Cell') return "Collection"; // show cell page as collection route
      else return route;
    }
  },
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
@media (min-width: 600px)
  .v-bottom-navigation
    visibility: hidden
  
</style>
