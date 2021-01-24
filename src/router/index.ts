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
    path: "/create",
    name: "Create",
    component: () =>
      import(/* webpackChunkName: "create" */ "../views/Create.vue")
  },
  {
    path: "/render",
    name: "Render",
    component: () =>
      import(/* webpackChunkName: "render" */ "../views/Render.vue")
  },
  {
    path: "/explore",
    name: "Explore",
    component: () =>
      import(/* webpackChunkName: "explore" */ "../views/Explore.vue")
  },
  {
    path: "/token/:id",
    name: "Token",
    component: () =>
      import(/* webpackChunkName: "token" */ "../views/TokenPage.vue")
  },
  {
    path: "/list/:page?",
    name: "List",
    component: () => import(/* webpackChunkName: "list" */ "../views/List.vue")
  },
  {
    path: "/le",
    name: "CreateLE",
    component: () =>
      import(/* webpackChunkName: "le" */ "../views/CreateLE.vue")
  },
  {
    path: "/admin",
    name: "Admin",
    component: () =>
      import(/* webpackChunkName: "admin" */ "../views/Admin.vue")
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
