import { createRouter, createWebHistory } from 'vue-router'
import Order from './components/Order.vue'
import BladeAnalysis from './components/BladeAnalysis.vue';

const routes = [
  { path: '/', component: BladeAnalysis},
  { path: '/order', component: Order },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router