<template lang="pug">
  .guide
    v-navigation-drawer(permanent).menu
      v-list(dense nav)
        v-list-item
          v-list-item-content
            v-list-item-title(class="title") Welcome
        v-list-item
          v-list-item-content
            v-list-item-title(class="title") Minting
        v-list-item
          v-list-item-content
            v-list-item-title(class="title") Types
    v-sheet.content
      h1 Welcome to the Guide
      h2 Learn more about tiny boxes
      h3 Get started here
      h3 {{ topic }}
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "Guide",
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
