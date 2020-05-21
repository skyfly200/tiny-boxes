import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);

const routes = [
  {
    path: "/",
    name: "Home",
    component: () => import(/* webpackChunkName: "home" */ "../views/Home.vue")
  },
  {
    path: "/token/:id",
    name: "Token",
    component: () =>
      import(/* webpackChunkName: "cell" */ "../views/TokenPage.vue")
  },
  {
    path: "/collection/:page?",
    name: "Collection",
    component: () =>
      import(/* webpackChunkName: "collection" */ "../views/Collection.vue")
  },
  {
    path: "/about",
    name: "About",
    component: () =>
      import(/* webpackChunkName: "about" */ "../views/About.vue")
  },
  {
    path: "/guide/:topic?/:subtopic?",
    name: "Guide",
    component: () =>
      import(/* webpackChunkName: "guide" */ "../views/Guide.vue")
  },
  {
    path: "/*",
    name: "404",
    component: () => import(/* webpackChunkName: "404" */ "../views/404.vue")
  }
];

const router = new VueRouter({
  mode: "history",
  base: process.env.BASE_URL,
  routes
});

export default router;
