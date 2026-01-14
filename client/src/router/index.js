import Vue from 'vue';
import VueRouter from 'vue-router';
import LoginView from '../views/Login.vue'

Vue.use(VueRouter);

const routes = [
    {
        path: '/',
        redirect: '/login'
    },
    {
        path: '/login',
        name: "Login",
        component: LoginView
    },
    {
        path: '/chat',
        name: 'Chat',
        //component: "Chat"
    }
];

const router = new VueRouter({
    mode: 'history',
    base: process.env.BASE_URL,
    routes
});

export default router;