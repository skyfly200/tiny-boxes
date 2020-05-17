<template lang="pug">
  .guide
    v-navigation-drawer(v-model="drawer" :permanent="!mobile" :absolute="mobile").menu
      v-list(dense nav)
        v-list-item(v-for="t,tKey of topics" :to="'/guide/' + tKey")
          v-list-item-content
            v-list-item-title(class="title")
              b {{ t.title }}
            template(v-if="t.subtopics")
              v-divider
              v-list(dense nav)
                v-list-item(v-for="s,sKey of t.subtopics" :to="'/guide/' + tKey + '/' + sKey")
                  v-list-item-content
                    v-list-item-title(class="title") {{s.title}}
    v-sheet.content
      v-app-bar(v-show="mobile && !drawer" collapse absolute width="55px")
        v-btn(icon @click="drawer = !drawer")
          v-icon mdi-book
        v-spacer
      v-breadcrumbs(:items="items" large).breadcrumbs
      v-divider
      component(v-if="active" :is="active")
      .err404(v-else) 
        v-alert(type="error" prominent)
          v-row 
            v-col 
              p Error 404
              p {{ subtopic ? topic + '/' + subtopic : topic }} not found in guide
            v-col
              v-btn(to="/guide/").btn404 Guide Home
</template>

<script lang="ts">
import Vue from "vue";
import Welcome from "./guide/Welcome.vue";

export default Vue.extend({
  name: "Guide",
  components: { Welcome },
  data: () => ({
    drawer: false,
    mobile: true,
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
      return this.$route.params.topic ? this.$route.params.topic : "";
    },
    subtopic() {
      return this.$route.params.subtopic ? this.$route.params.subtopic : "";
    },
    active() {
      const t = this.topic;
      const s = this.subtopic;
      return this.topics[t]
        ? s && this.topics[t].subtopics
          ? this.topics[t].subtopics[s]
            ? this.topics[t].subtopics[s].component
            : null
          : this.topics[t].component
        : null;
    },
    items() {
      const topicData = this.topics[this.topic];
      const title = topicData ? topicData.title : "404";
      if (!this.subtopic) {
        return [{ text: title }];
      } else if (this.active) {
        return [
          {
            text: title,
            exact: true,
            to: "/guide/" + this.topic
          },
          {
            text: topicData.subtopics[this.subtopic]
              ? topicData.subtopics[this.subtopic].title
              : ""
          }
        ];
      } else return [{ text: "404" }];
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
.err404
  margin: 20% 2em 2em 2em
  .btn404
    margin-top: 2em
</style>
