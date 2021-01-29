<template lang="pug">
  v-app
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
});
</script>

<style lang="sass">
.title
  font-family: "Pangolin"
  font-size: 2rem
  color: #ffffff !important
  text-decoration: none
</style>
