// uniform变量用于从外部传入的参数
uniform vec3 iResolution;    // 视口分辨率（像素）
uniform float iTime;         // 着色器播放时间（秒）
uniform sampler2D iChannel0; // 纹理通道0
uniform sampler2D iChannel1; // 纹理通道1
uniform sampler2D iChannel2; // 纹理通道2
uniform vec2 iMouse;         // 鼠标位置

varying vec2 vUv; // 当前像素的UV坐标

// 定义一些预处理指令和常量
#define DITHERING
#define pi 3.14159265
#define R(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)

// iq 的噪音函数
float noise(in vec3 x) {
    vec3 p = floor(x);             // 向下取整，获取整数部分
    vec3 f = fract(x);             // 获取小数部分
    f = f * f * (3.0 - 2.0 * f);      // 平滑噪音，用于生成更自然的纹理
    vec2 uv = (p.xy + vec2(37.0, 17.0) * p.z) + f.xy;  // 生成噪音纹理坐标
    vec2 rg = textureLod(iChannel0, (uv + 0.5) / 256.0, 0.0).yx;  // 从纹理通道0获取噪音值
    return 1. - 0.82 * mix(rg.x, rg.y, f.z);  // 返回噪音值
}

// 分形布朗运动函数
float fbm(vec3 p) {
    // 返回分形布朗运动值，通过不同频率的噪音叠加生成
    return noise(p * .06125) * .5 + noise(p * .125) * .25 + noise(p * .25) * .125 + noise(p * .4) * .2;
}

// 球体函数
float Sphere(vec3 p, float r) {
    return length(p) - r;           // 返回点到球体表面的距离，即球体方程
}

const float nudge = 4.;             // 垂直向量的大小
float normalizer = 1.0 / sqrt(1.0 + nudge * nudge); // 用于保持垂直向量的比例的勾股定理

float SpiralNoiseC(vec3 p) {
    float n = -mod(iTime * 0.2, -2.); // 噪音量
    float iter = 2.0;
    for(int i = 0; i < 8; i++) {
        // 添加正弦和余弦按比例缩放的逆频率
        n += -abs(sin(p.y * iter) + cos(p.x * iter)) / iter; // 使用绝对值以获得崎岖的外观
        // 通过添加垂直向量并缩小来旋转
        p.xy += vec2(p.y, -p.x) * nudge;
        p.xy *= normalizer;
        // 在另一个轴上旋转
        p.xz += vec2(p.z, -p.x) * nudge;
        p.xz *= normalizer;
        // 增加频率
        iter *= 1.733733;
    }
    return n;
    // 返回旋转的噪音值，用于生成螺旋纹理
}

// 体积爆炸函数
float VolumetricExplosion(vec3 p) {
    float final = Sphere(p, 4.);  // 生成一个半径为4的球体
    #ifdef LOW_QUALITY
    final += noise(p * 12.5) * .2;  // 在低质量模式下添加额外的噪音
    #else
    final += fbm(p * 50.);           // 在标准质量模式下使用分形布朗运动
    #endif
    final += SpiralNoiseC(p.zxy * 0.4132 + 333.) * 3.0; //1.25;

    return final; // 返回体积爆炸的效果，包括球体、噪音和螺旋纹理
}

// 映射函数
float map(vec3 p) {
    R(p.xz, iMouse.x * 0.008 * pi + iTime * 0.1);  // 根据鼠标位置和时间旋转
    float VolExplosion = VolumetricExplosion(p / 0.5) * 0.5;
    return VolExplosion;  // 返回体积爆炸的效果
}

// 计算颜色
vec3 computeColor(float density, float radius) {
    vec3 result = mix(vec3(1.0, 0.9, 0.8), vec3(0.4, 0.15, 0.1), density);  // 根据密度混合颜色
    vec3 colCenter = 7. * vec3(0.8, 1.0, 1.0);
    vec3 colEdge = 1.5 * vec3(0.48, 0.53, 0.5);
    result *= mix(colCenter, colEdge, min((radius + .05) / .9, 1.15));   // 根据半径混合颜色
    return result;  // 返回最终颜色
}

// 射线-球体相交测试
bool RaySphereIntersect(vec3 org, vec3 dir, out float near, out float far) {
    float b = dot(dir, org);  // 计算射线方向与原点的点积
    float c = dot(org, org) - 8.;  // 计算原点到球心的距离的平方减去半径的平方
    float delta = b * b - c;  // 计算判别式
    if(delta < 0.0)
        return false;  // 如果判别式小于零，没有相交点
    float deltasqrt = sqrt(delta);  // 计算判别式的平方根
    near = -b - deltasqrt;  // 计算近距离
    far = -b + deltasqrt;   // 计算远距离
    return far > 0.0;  // 如果远距离大于零，表示相交
}

// 色调映射函数
vec3 ToneMapFilmicALU(vec3 _color) {
    _color = max(vec3(0), _color - vec3(0.004));  // 对颜色进行修正，确保不小于零
    _color = (_color * (6.2 * _color + vec3(0.5))) / (_color * (6.2 * _color + vec3(1.7)) + vec3(0.06));  // 应用色调映射算法
    return _color;
}

void main() {
    const float KEY_1 = 49.5 / 256.0;
    const float KEY_2 = 50.5 / 256.0;
    const float KEY_3 = 51.5 / 256.0;
    float key = 0.0;
    key += 0.7 * texture(iChannel1, vec2(KEY_1, 0.25)).x;  // 从纹理通道1获取键盘输入的值
    key += 0.7 * texture(iChannel1, vec2(KEY_2, 0.25)).x;  // 从纹理通道1获取键盘输入的值
    key += 0.7 * texture(iChannel1, vec2(KEY_3, 0.25)).x;  // 从纹理通道1获取键盘输入的值
    vec2 uv = vUv;  // 获取当前像素的UV坐标
    vec2 uvCoord = vec2(uv.x * iResolution.x, uv.y * iResolution.y);  // 将UV坐标映射到屏幕坐标
    vec3 rd = normalize(vec3(2.0 * (uvCoord - 0.5 * iResolution.xy) / iResolution.xy, 1.));  // 计算从相机发出的射线方向
    vec3 ro = vec3(0., 0., -6. + key * 1.6);  // 设置相机位置
    float ld = 0., td = 0., w = 0.;
    float d = 1., t = 0.;
    const float h = 0.1;  // 阈值
    vec4 sum = vec4(0.0);  // 用于存储最终颜色
    float min_dist = 0.0, max_dist = 0.0;
    if(RaySphereIntersect(ro, rd, min_dist, max_dist)) {
        t = min_dist * step(t, min_dist);  // 计算初始距离
        #ifdef LOW_QUALITY
        for(int i = 0; i < 56; i++)
        #else
        for(int i = 0; i < 86; i++)
        #endif
        {
            vec3 pos = ro + t * rd;  // 计算射线上的点
            if(td > 0.9 || d < 0.12 * t || t > 10. || sum.a > 0.99 || t > max_dist)
                break;  // 如果条件满足，退出循环
            float d = map(pos);  // 计算当前点的映射值
            #ifdef BOTH
            d = cos(iTime) * uv.x < 0.1 ? abs(d) + 0.07 : d;  // 根据时间和UV坐标进行映射
            #else
            #ifdef LEFT
            d = abs(d) + 0.07;  // 仅在左侧应用映射
            #endif
            #endif
            d = max(d, 0.03);  // 限制映射值的最小值
            vec3 ldst = vec3(0.0) - pos;  // 计算光线方向
            float lDist = max(length(ldst), 0.001);  // 计算光线长度
            vec3 lightColor = vec3(1.0, 0.5, 0.25);  // 光线颜色
            sum.rgb += (lightColor / exp(lDist * lDist * lDist * .08) / 30.); // 辉光效果
            if(d < h) {
                ld = h - d;  // 计算漫反射距离
                w = (1. - td) * ld;  // 计算权重
                td += w + 1. / 200.;
                vec4 col = vec4(computeColor(td, lDist), td);  // 计算颜色
                sum += sum.a * vec4(sum.rgb, 0.0) * 0.2 / lDist;
                col.a *= 0.2;
                col.rgb *= col.a;
                sum = sum + col * (1.0 - sum.a);  // 混合颜色
            }
            td += 1. / 70.;  // 更新漫反射距离
            #ifdef DITHERING
            vec2 uvd = uv;
            uvd.y *= 120.;
            uvd.x *= 280.;
            d = abs(d) * (.8 + 0.08 * texture(iChannel2, vec2(uvd.y, -uvd.x + 0.5 * sin(4. * iTime + uvd.y * 4.0))).r);  // 应用抖动纹理
            #endif
            #ifdef LOW_QUALITY
            t += max(d * 0.25, 0.01);  // 更新距离
            #else
            t += max(d * 0.08 * max(min(length(ldst), d), 2.0), 0.01);  // 更新距离
            #endif
        }
        #ifdef LOW_QUALITY
        sum *= 1. / exp(ld * 0.2) * 0.9;  // 应用低质量效果
        #else
        sum *= 1. / exp(ld * 0.2) * 0.8;  // 应用标准质量效果
        #endif
        sum = clamp(sum, 0.0, 1.0);  // 确保颜色值在[0, 1]范围内
        sum.xyz = sum.xyz * sum.xyz * (3.0 - 2.0 * sum.xyz);  // 应用颜色修正
    }
    #ifdef TONEMAPPING
    gl_FragColor = vec4(ToneMapFilmicALU(sum.xyz * 2.2), 1.0);  // 应用色调映射
    #else
    gl_FragColor = vec4(sum.xyz, 1.0);
    #endif
}
