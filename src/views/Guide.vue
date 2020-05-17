<template lang="pug">
  .guide
    v-navigation-drawer(permanent).menu
      v-list(dense nav)
        v-list-item(v-for="t,tKey of topics" :to="'/guide/' + tKey")
          v-list-item-content
            v-list-item-title(class="title") {{ t.title }}
            template(v-if="t.subtopics")
              v-divider
              v-list(dense nav)
                v-list-item(v-for="s,sKey of t.subtopics" :to="'/guide/' + tKey + '/' + sKey")
                  v-list-item-content
                    v-list-item-title(class="title") {{s.title}}
    v-sheet.content
      v-breadcrumbs(:items="items" large).breadcrumbs
      v-divider
      Welcome(v-if="!topic")
      h1(v-else-if="topic === 'minting'") Minting
      h1(v-else-if="topic === 'types'") Types
      h1(v-else-if="topic === 'graphics'") Graphics
      .err404(v-else) 
        h1.error 404 Error: Page {{ topic }} not found in guide
</template>

<script lang="ts">
import Vue from "vue";
import Welcome from "./guide/Welcome.vue";

export default Vue.extend({
  name: "Guide",
  components: { Welcome },
  data: () => ({
    topics: {
      "": {
        title: "Welcome",
        component: Welcome
      },
      minting: {
        title: "Minting",
        subtopics: {
          colors: {
            title: "Colors",
            component: Welcome
          }
        },
        component: Welcome
      },
      types: {
        title: "Types",
        component: Welcome
      },
      graphics: {
        title: "Graphics",
        component: Welcome
      }
    }
  }),
  computed: {
    topic() {
      return this.$route.params.topic;
    },
    subtopic() {
      return this.$route.params.subtopic;
    },
    items() {
      if (!this.subtopic) {
        return [
          {
            text: this.topic
              ? this.topics[this.topic]
                ? this.topics[this.topic].title
                : "404"
              : this.topics[""].title
          }
        ];
      } else {
        return [
          {
            text: this.topic
              ? this.topics[this.topic]
                ? this.topics[this.topic].title
                : "404"
              : this.topics[""].title,
            exact: true,
            to: "/guide/" + this.topic
          },
          {
            text: this.topics[this.topic].subtopics[this.subtopic].title
          }
        ];
      }
    }
  }
});
</script>

<style lang="sass">
.v-content
  padding-bottom: 0 !important
.guide
  display: flex
  height: 100%
.menu
  height: 100%
.content
  width: 100%
  text-align: center
  .breadcrumbs
    display: flex
    justify-content: center
    padding-bottom: 0
</style>
