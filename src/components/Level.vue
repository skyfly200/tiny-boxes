<template lang="pug">
  .level
    v-tooltip(left)
      template(v-slot:activator="{ on }")
        v-progress-circular(:value="levelProgress(mass)" size=40 width=6 rotate=-90 v-on="on" color="secondary")
          span {{ level(mass) }}
      .level-progress
        span {{ mass }} of {{ 2 ** (level(mass)+3) }}
        br
        span to level {{ level(mass) + 1 }}
</template>

<script>
import cellUtils from "@/mixins/cellUtils";

export default {
  name: "Level",
  mixins: [cellUtils],
  props: ["mass"]
};
</script>

<style lang="sass"></style>