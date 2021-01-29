<template lang="pug">
    v-tooltip(:bottom="bottom" :top="top" :left="left" :right="right").tooltip-icon-btn
        template(v-slot:activator="{ on }")
            v-btn(@click="$emit('click')" v-on="on" icon)
                v-icon {{ icon }}
        span(v-if="tip !== ''") {{ tip }}
        slot
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "TooltipIconBtn",
  props: ["tip", "icon", "bottom", "top", "left", "right"],
});
</script>

<style lang="sass" scoped>
</style>