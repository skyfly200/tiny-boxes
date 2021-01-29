<template lang="pug">
    v-card.share
      v-card-title Share Your Options
      v-card-text
        span Found some interesting options?
        span Share them with your friends!
      CopyField(:url="url")
      v-card-actions
        v-spacer
        v-btn.twitter-share-button(:href="twitterPost" target="_blank" icon)
          v-icon mdi-twitter
        v-btn(:href="email" target="_blank" icon)
          v-icon mdi-email
</template>

<script lang="ts">
import Vue from "vue";
import CopyField from "@/components/CopyField.vue";

export default Vue.extend({
  name: "ShareDialog",
  components: { CopyField },
  computed: {
    url: function () {
      return window.location.origin + (this.$route as any).fullPath;
    },
    twitterPost() {
      const text = 'Check out this TinyBox I designed! ';
      return 'https://twitter.com/intent/tweet?text=' + encodeURI(text) + encodeURIComponent((this as any).url);
    },
    email() {
      const subject = encodeURIComponent('I designed a cool TinyBox!');
      const body = encodeURIComponent('Check out this TinyBox I designed.\n') + encodeURIComponent((this as any).url);
      return "mailto:?subject="+subject+"&body="+body;
    },
    inProgress: function() {
      return (
        (this as any).overlay === "confirm" || (this as any).overlay === "wait"
      );
    },
  },
  methods: {
  }
});
</script>
