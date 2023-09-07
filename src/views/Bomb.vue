<template>
    <div class="container" ref="container"></div>
</template>

<script setup>
import { onMounted, ref } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
import useAdaptScreen from '@/hooks/useAdaptScreen';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import fragmentShader from '../shader/fragmentShader.glsl?raw';

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
camera.position.set(0, 5, 10);

// 创建渲染器
const renderer = new THREE.WebGLRenderer();
// 设置渲染器尺寸
renderer.setSize(window.innerWidth, window.innerHeight);

// 设置色调映射
renderer.toneMapping = THREE.ACESFilmicToneMapping;
// 色调映射的曝光级别。默认是1
renderer.toneMappingExposure = 1;
// 允许在场景中使用阴影贴图。默认是 false。
renderer.shadowMap.enabled = true;

// 添加控制器
const controls = new OrbitControls(camera, renderer.domElement);
// 设置控制器阻尼
controls.enableDamping = true;
// 禁止缩放
controls.enableZoom = false;

// 加载模型
let els, wkl, path, dd; // 俄罗斯、乌克兰、飞行路线、导弹
let curvePath; // 曲线路径
const loader = new GLTFLoader();
loader.load('/glb/ew.glb', (gltf) => {
    console.log('gltf', gltf);
    console.log('scene', gltf.scene.children);
    // 遍历模型
    gltf.scene.traverse((child) => {
        if (child.isMesh) {
            // 对象是否被渲染到阴影贴图中。默认值为false。
            child.castShadow = true;
            // 材质是否接收阴影。默认值为false。
            child.receiveShadow = true;
        }
    });
    els = gltf.scene.children[0]; // 俄罗斯
    wkl = gltf.scene.children[1]; // 乌克兰
    path = gltf.scene.children[2]; // 飞行路线
    dd = gltf.scene.children[3]; // 导弹
    scene.add(els, wkl, dd);

    // 根据点创建曲线
    const points = [];
    for (let i = path.geometry.attributes.position.count - 1; i >= 0; i--) {
        points.push(
            new THREE.Vector3(
                path.geometry.attributes.position.array[i * 3],
                path.geometry.attributes.position.array[i * 3 + 1],
                path.geometry.attributes.position.array[i * 3 + 2]
            )
        );
    }
    curvePath = new THREE.CatmullRomCurve3(points); // 曲线路径
});

// 添加环境光
const ambientLight = new THREE.AmbientLight(0xffffff, 1);
scene.add(ambientLight);
// 添加平行光
const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
directionalLight.position.set(1, 10, 1); // 设置光源位置
directionalLight.castShadow = true; // 设置光源阴影
scene.add(directionalLight); // 添加光源
// 添加平行光2
const directionalLight2 = new THREE.DirectionalLight(0xffffff, 3);
directionalLight2.position.set(1, -1, 1); // 设置光源位置
directionalLight2.castShadow = true; // 设置光源阴影
scene.add(directionalLight2); // 添加光源

// 爆炸效果
const params = {
    iTime: {
        value: 0
    }
};
// 创建精灵材质
const spriteMaterial = new THREE.SpriteMaterial({
    color: 0xffffff,
    blending: THREE.AdditiveBlending
});
spriteMaterial.onBeforeCompile = (shader) => {
    // 视口分辨率（像素）
    shader.uniforms.iResolution = {
        value: new THREE.Vector2(window.innerWidth, window.innerHeight)
    };
    // 着色器播放时间（秒）
    shader.uniforms.iTime = params.iTime;
    // 纹理通道0
    shader.uniforms.iChannel0 = {
        value: new THREE.TextureLoader().load('/imgs/iChannel0.png')
    };
    // 纹理通道1
    shader.uniforms.iChannel1 = {
        value: new THREE.TextureLoader().load('/imgs/iChannel1.png')
    };
    // 纹理通道2
    shader.uniforms.iChannel2 = {
        value: new THREE.TextureLoader().load('/imgs/iChannel2.png')
    };
    // 鼠标位置
    shader.uniforms.iMouse = {
        value: new THREE.Vector2(0, 0)
    };
    console.log(shader.vertexShader);
    shader.vertexShader = shader.vertexShader.replace(
        '#include <common>',
        `
        #include <common>
        varying vec2 vUv;
        `
    );
    shader.vertexShader = shader.vertexShader.replace(
        '#include <uv_vertex>',
        `
        #include <uv_vertex>
        vUv = uv;
        `
    );
    shader.fragmentShader = fragmentShader;
};
const sprite = new THREE.Sprite(spriteMaterial);
sprite.position.set(-5.5, 0.8, 0);

// 添加声音
const listener = new THREE.AudioListener();
const sound = new THREE.Audio(listener);
const audioLoader = new THREE.AudioLoader();
audioLoader.load('/audio/bomb.mp3', (buffer) => {
    // 给一个加载器对象设置音频对象的缓存
    sound.setBuffer(buffer);
    // 设置音量
    sound.setVolume(0.5);
});

// 渲染函数
const clock = new THREE.Clock(); // 该对象用于跟踪时间
const duration = 5;
const render = () => {
    // 渲染
    renderer.render(scene, camera);
    // .getElapsedTime()：获取自时钟启动后的秒数
    const t = clock.getElapsedTime() % duration / duration;
    if (curvePath) {
        const point = curvePath.getPointAt(t);
        dd.position.set(point.x, point.y, point.z);
        if (t + 0.01 < 1) {
            dd.lookAt(curvePath.getPointAt(t + 0.01));
        }
    }
    params.iTime.value = t * 10;
    if (t > 0.95) {
        scene.add(sprite);
        if (!sound.isPlaying) {
            sound.play();
        }
    }
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
