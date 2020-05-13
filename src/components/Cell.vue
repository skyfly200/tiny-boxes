<template lang="pug">
  .shape
</template>

<script>
import Vue from "vue";

export default Vue.extend({
  name: "Cell",
  props: ["id", "data"],
  data: () => ({
    size: 100
  }),
  async mounted() {
    this.load();
  },
  methods: {
    load() {
      alert(this.size);
    }
  }
});
</script>
