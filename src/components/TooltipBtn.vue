<template lang="pug">
    v-tooltip(left).tooltip-btn
        template(v-slot:activator="{ on }")
            v-btn(@click.stop="" v-on="on") {{ text }}
        span {{ tip }}
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "TooltipBtn",
  props: ["tip", "text"],
});
</script>

<style lang="sass" scoped>
</style>