<template lang="pug">
  v-container.about
    v-row(cols=6).landing
      v-col(align="center").content
        h1 404 Error
        h2 Page not found!
        v-btn(to="/") Return to Home
    
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "Error404"
});
</script>
 
<style lang="sass" scoped>
.content
  margin-top: 35vh
</style>
