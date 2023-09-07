<template>
    <div class="container" ref="container"></div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js';
import useAdaptScreen from '../hooks/useAdaptScreen';

// 容器
const container = ref(null);
// 创建场景
const scene = new THREE.Scene();

// 创建相机
const camera = new THREE.PerspectiveCamera(
    75,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
);
// 设置相机位置
camera.position.z = 0.1;

// 创建渲染器
const renderer = new THREE.WebGLRenderer();
// 设置渲染器尺寸
renderer.setSize(window.innerWidth, window.innerHeight);

// 添加控制器
const controls = new OrbitControls(camera, renderer.domElement);
// 设置控制器阻尼
controls.enableDamping = true;
// 设置控制器不允许缩放
controls.enableZoom = false;

// 渲染函数
const render = () => {
    // 渲染
    renderer.render(scene, camera);
    // 帧动画渲染
    requestAnimationFrame(render);
};

/*
    面的顺序右、左、上、下、后和前对应着这个坐标系中的方向：
    右面位于正X轴的一侧
    左面位于负X轴的一侧
    上面位于正Y轴的一侧
    下面位于负Y轴的一侧
    后面位于正Z轴的一侧
    前面位于负Z轴的一侧
*/

// 图片资源
const arr = ['home_right', 'home_left', 'home_up', 'home_down', 'home_front', 'home_back'];
// 基础网格材质
const materials = [];
arr.forEach((item) => {
    // 加载纹理
    const texture = new THREE.TextureLoader().load(`/imgs/${item}.jpg`);
    // 设置纹理贴图
    materials.push(new THREE.MeshBasicMaterial({ map: texture }));
});
// 添加立方缓冲几何体
const geometry = new THREE.BoxGeometry(10, 10, 10);
// 立方体
const mesh = new THREE.Mesh(geometry, materials);
// 翻转
mesh.geometry.scale(1, 1, -1);
// 添加到场景
scene.add(mesh);

// // 添加球体
// const geometry = new THREE.SphereGeometry(5, 32, 32);
// // 加载纹理
// const loader = new RGBELoader();
// loader.load('/hdr/living.hdr', (texture) => {
//     // 设置纹理贴图
//     const material = new THREE.MeshBasicMaterial({ map: texture });
//     const mesh = new THREE.Mesh(geometry, material);
//     mesh.geometry.scale(1, 1, -1);
//     scene.add(mesh);
// });
// const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
// const mesh = new THREE.Mesh(geometry, material);
// scene.add(mesh);

// 适配屏幕
useAdaptScreen(camera, renderer);

onMounted(() => {
    // 将渲染内容添加到容器内
    container.value.appendChild(renderer.domElement);
    // 更新控制器
    controls.update();
    // 执行渲染函数
    render();
});
</script>

<style scoped>
.container {
    height: 100%;
}
</style>
