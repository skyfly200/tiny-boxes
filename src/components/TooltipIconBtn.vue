<template lang="pug">
    v-tooltip(left).tooltip-icon-btn
        template(v-slot:activator="{ on }")
            v-btn(@click.stop="" v-on="on" icon)
                v-icon {{ icon }}
        span {{ tip }}
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "TooltipIconBtn",
  props: ["tip", "icon"],
});
</script>

<style lang="sass" scoped>
</style>