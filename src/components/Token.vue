<template lang="pug">
  .token
    span(v-html="data" :key="id").token-svg
</template>

<script>
import Vue from "vue";

export default Vue.extend({
  name: "Token",
  props: ["id", "data"],
  data: () => ({
    size: 100
  }),
  async mounted() {
    this.load();
  },
  methods: {
    load() {
      this.size = 100;
    }
  }
});
</script>
