import Vue from 'vue';
import VueRouter from 'vue-router';
import LoginView from '@/views/Login.vue'
import SignupView from '@/views/Signup.vue';
import MessageView from '@/views/Messages.vue'

Vue.use(VueRouter);

const routes = [
    {
        path: '/',
        redirect: '/signup'
    },
    {
        path: '/login',
        name: "Login",
        component: LoginView
    },
    {
        path: '/signup',
        name: "Signup",
        component: SignupView
    },
    {
        path: '/messages/:id?',
        name: 'Messages',
        component: MessageView
    }
];

const router = new VueRouter({
    mode: 'history',
    base: process.env.BASE_URL,
    routes
});

export default router;