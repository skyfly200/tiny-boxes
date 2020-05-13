<template lang="pug">
  v-container.guide
    v-row(cols=6).landing
      v-col(align="center").content
        h1 Guide
        h2 Index panel to left
        h3 content pane to right
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

<style lang="sass" scoped>
</style>
