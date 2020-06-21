<template lang="pug">
  .guide
    v-navigation-drawer(v-model="drawer" :permanent="!mobile" :absolute="mobile").menu
      v-list(dense nav)
        v-list-item(v-for="t,tKey of topics" :to="'/guide/' + tKey" :key="tKey")
          v-list-item-content
            v-list-item-title(class="title")
              b {{ t.title }}
            template(v-if="t.subtopics")
              v-divider
              v-list(dense nav)
                v-list-item(v-for="s,sKey of t.subtopics" :to="'/guide/' + tKey + '/' + sKey" :key="tKey + '/' + sKey")
                  v-list-item-content
                    v-list-item-title(class="title") {{s.title}}
    v-sheet.content
      v-btn(v-show="mobile && !drawer" @click="drawer = !drawer" fab fixed left)
        v-icon mdi-book
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
    mobile: false,
    mobileBreak: 720,
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
      const t = this as any;
      const topic = t.topic;
      const subtopic = t.subtopic;
      return t.topics[topic]
        ? subtopic && t.topics[topic].subtopics
          ? t.topics[topic].subtopics[subtopic]
            ? t.topics[topic].subtopics[subtopic].component
            : null
          : t.topics[topic].component
        : null;
    },
    items() {
      const t = this as any;
      const topicData = t.topics[t.topic];
      const title = topicData ? topicData.title : "404";
      if (!this.subtopic) {
        return [{ text: title }];
      } else if (this.active) {
        return [
          {
            text: title,
            exact: true,
            to: "/guide/" + t.topic
          },
          {
            text: topicData.subtopics[t.subtopic]
              ? topicData.subtopics[t.subtopic].title
              : ""
          }
        ];
      } else return [{ text: "404" }];
    }
  },
  created() {
    this.resized();
    const debouncedResize = this.debounce(this.resized, 250, false);
    window.addEventListener("resize", debouncedResize);
  },
  destroyed() {
    window.removeEventListener("resize", this.resized);
  },
  methods: {
    resized() {
      this.mobile = window.innerWidth < this.mobileBreak;
    },
    debounce(func: Function, wait: number, immediate: boolean) {
      let timeout: null | boolean;
      return () => {
        const later = () => {
          timeout = null;
          if (!immediate) func.apply(this);
        };
        const callNow = immediate && !timeout;
        clearTimeout(this as any);
        timeout = (setTimeout(later, wait) as unknown) as boolean;
        if (callNow) func.apply(this);
      };
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
