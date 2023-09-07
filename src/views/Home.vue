<template>
    <div class="title">Three.js</div>
    <div class="btns">
        <router-link class="btn" to="/base">基础结构</router-link>
        <router-link class="btn" to="/skeleton">骨骼动画</router-link>
        <router-link class="btn" to="/vr">VR看房</router-link>
        <router-link class="btn" to="/earth">环绕地球</router-link>
        <router-link class="btn" to="/bomb">导弹轰炸</router-link>
    </div>
</template>

<style scoped>
.title {
    text-align: center;
    margin-top: 100px;
    font-size: 50px;
    font-weight: bold;
}
.btns {
    margin-top: 30px;
    display: flex;
    justify-content: center;
}
.btn {
    margin: 0 15px;
    text-decoration: underline;
    color: blue;
    font-size: 20px;
    cursor: pointer;
}
</style>
