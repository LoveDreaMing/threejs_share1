<template>
    <div class="container" ref="container"></div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import useAdaptScreen from '@/hooks/useAdaptScreen';

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
camera.position.set(5, 5, 5);

// 创建渲染器
const renderer = new THREE.WebGLRenderer();
// 是否执行抗锯齿。默认为false.
renderer.antialias = true;
// 允许在场景中使用阴影贴图。默认是 false。
renderer.shadowMap.enabled = true;
// 设置设备像素比，防止Canvas画布模糊输出
renderer.setPixelRatio(window.devicePixelRatio);
// 设置渲染器尺寸
renderer.setSize(window.innerWidth, window.innerHeight);

// 添加控制器
const controls = new OrbitControls(camera, renderer.domElement);
// 设置控制器阻尼
controls.enableDamping = true;

// 坐标轴
// 红色代表 X 轴、绿色代表 Y 轴、蓝色代表 Z 轴
const axesHelper = new THREE.AxesHelper( 100 );
scene.add( axesHelper );

// 添加立方缓冲几何体
const geometry = new THREE.BoxGeometry(2, 2, 2);
const material = new THREE.MeshPhongMaterial({
    color: 0x0000ff,
    shininess: 100
});
const cube = new THREE.Mesh(geometry, material);
cube.position.set(1, 1, 1);
// 对象是否被渲染到阴影贴图中。默认值为false。
cube.castShadow = true;
scene.add(cube);

// 创建平面缓冲几何体
const planeGeometry = new THREE.PlaneGeometry(10, 10);
const planeMaterial = new THREE.MeshPhongMaterial({ color: 0x00ff00 });
const plane = new THREE.Mesh(planeGeometry, planeMaterial);
// 材质是否接收阴影。默认值为false。
plane.receiveShadow = true;
plane.rotation.x = -Math.PI / 2;
scene.add(plane);

// 添加环境光
const ambientLight = new THREE.AmbientLight(0x606008, 1);
scene.add(ambientLight);

// 添加聚光灯
const spotLight = new THREE.SpotLight(0xff0000, 5);
spotLight.position.set(-10, 15, -10);
// 对象是否被渲染到阴影贴图中。默认值为false。
spotLight.castShadow = true;
scene.add(spotLight);

const render = () => {
    // 渲染
    renderer.render(scene, camera);
    // 更新控制器
    controls.update();
    // 帧动画渲染
    requestAnimationFrame(render);
};

// 适配屏幕
useAdaptScreen(camera, renderer);

onMounted(() => {
    // 将渲染内容添加到容器内
    container.value.appendChild(renderer.domElement);
    // 执行渲染函数
    render();
});
</script>

<style scoped>
.container {
    height: 100%;
}
</style>