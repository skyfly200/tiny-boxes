<template lang="pug">
    v-tooltip(bottom).copy-field
        template(v-slot:activator="{ on }")
            v-text-field.url#share-url(:value="url"  v-on="on" @click="copyPath" @click:append-outer="copyPath" width="250px" append-outer-icon="mdi-content-copy")
        span Copy
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "CopyField",
  props: ["url"],
  methods: {
    copyPath() {
      const copyText: any = document.querySelector("#share-url");
      if (copyText) {
        copyText.select();
        document.execCommand("copy");
      }
    },
  }
});
</script>
