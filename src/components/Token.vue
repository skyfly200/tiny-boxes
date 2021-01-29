<template lang="pug">
  .token
    v-img(:src="src" :key="id" aspect-ratio="1").token-svg
</template>

<script>
import Vue from "vue";

export default Vue.extend({
  name: "Token",
  props: ["id", "data"],
  data: () => ({
    src: ""
  }),
  async mounted() {
    this.load();
  },
  methods: {
    load() {
      this.src = URL.createObjectURL(new Blob([this.data], {type: 'image/svg+xml'}));
    }
  }
});
</script>
