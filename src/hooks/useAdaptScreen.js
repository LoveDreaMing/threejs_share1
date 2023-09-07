export default function useAdaptScreen(camera, renderer) {
    // 屏幕适配
    window.addEventListener('resize', () => {
        // 更新相机宽高比
        camera.aspect = window.innerWidth / window.innerHeight;
        // 更新相机投影矩阵
        camera.updateProjectionMatrix();
        // 更新渲染器尺寸
        renderer.setSize(window.innerWidth, window.innerHeight);
    });
}
