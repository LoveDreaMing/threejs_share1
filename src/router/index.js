import { createRouter, createWebHistory } from 'vue-router';

const routes = [
    {
        path: '/',
        name: 'Home',
        component: () => import('@/views/Home.vue')
    },
    {
        path: '/base',
        name: 'Base',
        component: () => import('@/views/Base.vue')
    },
    {
        path: '/skeleton',
        name: 'Skeleton',
        component: () => import('@/views/Skeleton.vue')
    },
    {
        path: '/vr',
        name: 'Vr',
        component: () => import('@/views/Vr.vue')
    },
    {
        path: '/earth',
        name: 'Earth',
        component: () => import('@/views/Earth.vue')
    },
    {
        path: '/bomb',
        name: 'Bomb',
        component: () => import('@/views/Bomb.vue')
    }
];

const router = createRouter({
    history: createWebHistory(),
    routes
});

export default router;
