<template>
    <div class="container" ref="container"></div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import useAdaptScreen from '@/hooks/useAdaptScreen.js';

// 容器
const container = ref(null);
// 创建场景
const scene = new THREE.Scene();

// 创建相机
const camera = new THREE.PerspectiveCamera(
    45,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
);
// 设置相机位置
camera.position.set(100, 100, 0);
// 设置相机方向
camera.lookAt(0, 0, 0);

// 创建渲染器
const renderer = new THREE.WebGLRenderer();
// 设置渲染器尺寸
renderer.setSize(window.innerWidth, window.innerHeight);

// 添加聚光灯
const spotLight = new THREE.SpotLight(0xffffff);
spotLight.position.set(2000, 8000, 4000);
scene.add(spotLight);

// 创建圆柱体
const geometry = new THREE.CylinderGeometry(2, 2, 40, 8, 12);
// 创建材质
const material = new THREE.MeshPhongMaterial();
// 创建网格模型
const mesh = new THREE.SkinnedMesh(geometry, material);
// 将网格模型添加到场景中
scene.add(mesh);

// 创建骨骼系统
const b1 = new THREE.Bone();
b1.position.set(0, -20, 0);

const b2 = new THREE.Bone();
b1.add(b2);
b1.position.set(0, 10, 0);

const b3 = new THREE.Bone();
b2.add(b3);
b1.position.set(0, 10, 0);

const b4 = new THREE.Bone();
b3.add(b4);
b1.position.set(0, 10, 0);

const b5 = new THREE.Bone();
b4.add(b5);
b1.position.set(0, 10, 0);

// 创建骨架
const skeleton = new THREE.Skeleton([b1, b2, b3, b4, b5]);
mesh.add(b1);
mesh.bind(skeleton);

// 添加权重
const index = [];
const weight = [];
const arr = geometry.attributes.position.array;
for (let i = 0; i < arr.length; i += 3) {
    const y = arr[i + 1] + 20;
    const indexValue = Math.floor(y / 10);
    const weightValue = (y % 10) / 10;
    index.push(indexValue, indexValue + 1, 0, 0);
    weight.push(1 - weightValue, weightValue, 0, 0);
}
geometry.setAttribute('skinIndex', new THREE.Uint16BufferAttribute(index, 4));
geometry.setAttribute(
    'skinWeight',
    new THREE.Float32BufferAttribute(weight, 4)
);

// 渲染函数
let step = 0.1;
const render = () => {
    // 渲染
    renderer.render(scene, camera);
    // 添加边界
    if (
        mesh.skeleton.bones[0].rotation.x > 0.3 ||
        mesh.skeleton.bones[0].rotation.x < -0.3
    ) {
        step = -step;
    }

    for (let i = 0; i < mesh.skeleton.bones.length; i++) {
        mesh.skeleton.bones[i].rotation.x += (step * Math.PI) / 180;
    }
    // 帧动画渲染
    requestAnimationFrame(render);
};

// 适配屏幕
useAdaptScreen(camera, renderer);

onMounted(() => {
    // 将渲染器添加到容器内
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
