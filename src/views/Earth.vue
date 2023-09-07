<template>
    <div class="container" ref="container"></div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import useAdaptScreen from '@/hooks/useAdaptScreen';
import { gsap } from 'gsap';

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
camera.position.set(0, 100, 300);

// 创建渲染器
const renderer = new THREE.WebGLRenderer();
// 设置渲染器尺寸
renderer.setSize(window.innerWidth, window.innerHeight);

// 添加控制器
const controls = new OrbitControls(camera, renderer.domElement);
// 设置控制器阻尼
controls.enableDamping = true;
// 禁止缩放
controls.enableZoom = false;
// 自动旋转
controls.autoRotate = true;

// 地球几何体
const earthGeometry = new THREE.SphereGeometry(53, 32, 32);
// 地球纹理
const earthTexture = new THREE.TextureLoader().load('/imgs/map.jpg');
// 地球材质
const earthMaterial = new THREE.MeshBasicMaterial({
    map: earthTexture
});
// 地球
const earth = new THREE.Mesh(earthGeometry, earthMaterial);
// 地球添加到场景
scene.add(earth);

// 发光地球几何体
const lightEarthGeometry = new THREE.SphereGeometry(53, 32, 32);
// 发光地球纹理
const lightTexture = new THREE.TextureLoader().load('/imgs/earth.jpg');
// 发光地球材质
const lighthMaterial = new THREE.MeshBasicMaterial({
    map: lightTexture,
    alphaMap: lightTexture,
    blending: THREE.AdditiveBlending,
    transparent: true
});
// 发光地球
const lightEarth = new THREE.Mesh(lightEarthGeometry, lighthMaterial);
// 发光地球添加到场景
scene.add(lightEarth);

// 外部光纹理
const outsideTexture = new THREE.TextureLoader().load('/imgs/outside.png');
// 外部光精灵材质
const outsideMaterial = new THREE.SpriteMaterial({
    map: outsideTexture, // 颜色贴图
    color: 0x4d76cf, // 材质的颜色
    transparent: true, // 定义此材质是否透明
    depthWrite: false, // 继承材质(Material)，渲染此材质是否对深度缓冲区有任何影响。默认为true。
    depthTest: false, // 继承材质(Material)，是否在渲染此材质时启用深度测试。默认为 true。
    blending: THREE.AdditiveBlending // 继承材质(Material)，在使用此材质显示对象时要使用何种混合。
});
// 外部光
const outside = new THREE.Sprite(outsideMaterial);
// 设置外部光缩放比例
outside.scale.set(155, 155, 0);
// 添加外部光
scene.add(outside);

// 内部光纹理
const insideTexture = new THREE.TextureLoader().load('/imgs/inside.png');
// 内部光精灵材质
const insideMaterial = new THREE.SpriteMaterial({
    map: insideTexture, // 颜色贴图
    color: 0x4d76cf, // 材质的颜色
    transparent: true, // 定义此材质是否透明
    depthWrite: false, // 继承材质(Material)，渲染此材质是否对深度缓冲区有任何影响。默认为true。
    depthTest: false, // 继承材质(Material)，是否在渲染此材质时启用深度测试。默认为 true。
    blending: THREE.AdditiveBlending // 继承材质(Material)，在使用此材质显示对象时要使用何种混合。
});
// 内部光
const inside = new THREE.Sprite(insideMaterial);
// 设置内部光缩放比例
inside.scale.set(128, 128, 0);
// 添加内部光
scene.add(inside);

// 圆环几何体
const ringGeometry = new THREE.RingGeometry(145, 155, 64);
// 圆环纹理
const ringTexture = new THREE.TextureLoader().load('/imgs/ring.png');
// 圆环材质
const ringMaterial = new THREE.MeshBasicMaterial({
    map: ringTexture, // 颜色贴图
    transparent: true, // 定义此材质是否透明
    blending: THREE.AdditiveBlending, // 继承材质(Material)，在使用此材质显示对象时要使用何种混合。
    side: THREE.DoubleSide, // 继承材质(Material)，定义将要渲染哪一面 - 正面，背面或两者。
    depthWrite: false, // 继承材质(Material)，渲染此材质是否对深度缓冲区有任何影响。默认为true。
    opacity: 0.5 // 继承材质(Material)，在0.0 - 1.0的范围内的浮点数，表明材质的透明度。
});
// 圆环
const ring = new THREE.Mesh(ringGeometry, ringMaterial);
// 旋转圆环
ring.rotation.x = -Math.PI / 2;
// 添加圆环
scene.add(ring);

// 月球几何体
const moonGeometry = new THREE.SphereGeometry(5, 32, 32);
const moonTexture = new THREE.TextureLoader().load('/imgs/moon.jpg');
const moonMaterial = new THREE.MeshStandardMaterial({
    map: moonTexture, // 颜色贴图
    emissive: 0xffffff, // 材质的放射（光）颜色，基本上是不受其他光照影响的固有颜色。默认为黑色。
    emissiveMap: moonTexture // 设置放射（发光）贴图
});
const moon = new THREE.Mesh(moonGeometry, moonMaterial);
moon.position.set(150, 0, 0);
scene.add(moon);

let time = {
    val: 0
};
gsap.to(time, {
    value: 1,
    duration: 10, // 动画的持续时间
    repeat: -1, // 动画应重复多少次，使用 -1 无限重复
    ease: 'linear',
    onUpdate: () => {
        // 更新月球x轴位置
        moon.position.x = 150 * Math.cos(time.value * Math.PI * 2);
        // 更新月球z轴位置
        moon.position.z = 150 * Math.sin(time.value * Math.PI * 2);
        // 月球自转
        moon.rotation.y = time.value * Math.PI * 8;
    }
});

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
