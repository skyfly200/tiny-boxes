<template lang="pug">
  .guide
    v-navigation-drawer(permanent).menu
      v-list(dense nav)
        v-list-item(to="/guide/minting")
          v-list-item-content
            v-list-item-title(class="title") Minting
        v-list-item(to="/guide/types")
          v-list-item-content
            v-list-item-title(class="title") Types
        v-list-item(to="/guide/graphics")
          v-list-item-content
            v-list-item-title(class="title") Graphics
    v-sheet.content
      Welcome(v-if="!topic")
      h1(v-else-if="topic === 'minting'") Minting
      h1(v-else-if="topic === 'types'") Types
      h1(v-else-if="topic === 'graphics'") Graphics
      .err404(v-else) 
        h1.error 404 Error: Page {{ topic }} not found in guide
</template>

<script lang="ts">
import Vue from "vue";
import Welcome from "./guide/Welcome.vue";

export default Vue.extend({
  name: "Guide",
  components: { Welcome },
  computed: {
    topic() {
      return this.$route.params.topic;
    }
  }
});
</script>

<style lang="sass">
.v-content
  padding-bottom: 0 !important
.guide
  display: flex
  height: 100%
.menu
  height: 100%
.content
  width: 100%
  text-align: center
</style>
