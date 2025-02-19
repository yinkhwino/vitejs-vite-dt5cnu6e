import { createRouter, createWebHistory } from 'vue-router'
import PlanePart from './components/PlanePart.vue'
import Order from './components/Order.vue'

const routes = [
  { path: '/', component: PlanePart },
  { path: '/order', component: Order },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router