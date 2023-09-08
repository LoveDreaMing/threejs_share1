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

const height = 40; // 圆柱高度
const segmentHeight = 10; // 段高度
// 创建圆柱体
const geometry = new THREE.CylinderGeometry(2, 2, height, 8, 12);
// 创建材质
const material = new THREE.MeshPhongMaterial();
// 创建网格模型
const mesh = new THREE.SkinnedMesh(geometry, material);
// 将网格模型添加到场景中
scene.add(mesh);

// 创建骨骼系统
const b1 = new THREE.Bone();
b1.position.set(0, -(height / 2), 0);

const b2 = new THREE.Bone();
b1.add(b2);
b1.position.set(0, segmentHeight, 0);

const b3 = new THREE.Bone();
b2.add(b3);
b1.position.set(0, segmentHeight, 0);

const b4 = new THREE.Bone();
b3.add(b4);
b1.position.set(0, segmentHeight, 0);

const b5 = new THREE.Bone();
b4.add(b5);
b5.position.set(0, segmentHeight, 0);

// 创建骨架
const skeleton = new THREE.Skeleton([b1, b2, b3, b4, b5]);
mesh.add(b1);
mesh.bind(skeleton);

// 添加权重
const index = [];
const weight = [];
const arr = geometry.attributes.position.array;
console.log(arr);
for (let i = 0; i < arr.length; i += 3) {
    const y = arr[i + 1] + height / 2; // 每个顶点的y坐标，保存相对于圆柱体底面的高度值 0 , 1, 2, 3
    const indexValue = Math.floor(y / segmentHeight); // 高度除以段高度在向下取整，得到当前的skinIndex
    const weightValue = (y % segmentHeight) / segmentHeight; //  //当前的y值占该段的百分比
    index.push(indexValue, indexValue + 1, 0, 0);
    weight.push(1 - weightValue, weightValue, 0, 0);
}
/*
skinWeights :
当在处理一个 SkinnedMesh 时，每个顶点最多可以有 4 个相关的 bones 来影响它。
skinWeights 属性是一个权重队列，顺序同几何体中的顶点保持一致。
因而，队列中的第一个 skinWeight 就对应几何体中的第一个顶点。
由于每个顶点可以被 4 个 bones 营销，因而每个顶点的 skinWeights 就采用一个 Vector4 表示。
skinWeight 矢量中每个元素的取值范围应该在 0 到 1 之间。
例如，当设置为 0，骨骼对该顶点的位置没有影响。当设置为 0.5, 则对顶点的影响为 50%。
当设置为 100% 则对顶点的影响是 100%。如果矢量中只有一个骨骼与顶点相关联，则你只需要关注矢量中的第一个元素，
剩余的元素可以忽略，他们的值可以都设置为 0。
*/
/*
skinIndices :
就如同 skinWeights 属性一样。skinWeights 的值也是与几何体的顶点相对应。每个顶点可以最多有 4 个骨骼与之相关联。
因而第一个 skinIndex 就与几何体的第一个顶点相关联，skinIndex 的值就指明了影响该顶点的骨骼是哪个。
*/
geometry.setAttribute('skinIndex', new THREE.Uint16BufferAttribute(index, 4));
geometry.setAttribute('skinWeight', new THREE.Float32BufferAttribute(weight, 4));

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
