# 创建项目

```javascript
创建项目
npm create vite@latest demo -- --template vue-ts

cd demo
npm i
```

# 安装依赖

```javascript
# element plus  页面效果
npm i element-plus -S

# vuex  全局状态管理
npm i vuex -S

# vue-i18n  国际化
npm i vue-i18n -S

# router  路由
npm i vue-router -S

# path 路径别名
npm i path -D

# less 语言支持
npm i less -D
```

# 初始化配置

## 配置路径别名

```javascript
# vite.config.ts

resolve: {
  alias: {
    '@': path.resolve("./src"),
  }
},
base: './'

# tsconfig.json  =》 compilerOptions
"baseUrl": "./", // 解析非相对模块的基地址，默认是当前目录
"paths": { //路径映射，相对于baseUrl
  "@/*": ["src/*"]
},
```

## 配置服务器信息

```javascript
server: {
  host: "localhost",
  port: 9090,
  open: true,
  strictPort: false,
  https: false,
},
publicDir: "public",
```

## 实验功能配置

```javascript
 plugins: [
  vue({
    reactivityTransform: true, //开启自动解包，有这个才能使用$ref,否则只能使用ref
  })
]
```

## 图片大小配置

```javascript
## vite.config.ts
build: {
  assetsInlineLimit: 4096		//低于这个大小的图片使用base64，超过的使用图片资源路径
}
```

## element & i18n 配置

### 基础配置

```javascript
# ts config  -》 compilerOptions
"types": ["element-plus/global"],

# 如果element 需要自动引入
## vite.config.ts => plugins
AutoImport({
  resolvers: [ElementPlusResolver()],
}),
Components({
  resolvers: [ElementPlusResolver()],
}),
```

### 引入依赖

```javascript
export default {
  'zh-cn': {
    i18n: {
      breadcrumb: '国际化产品',
      tips: '通过切换语言按钮，来改变当前内容的语言。',
      btn: '切换英文',
      title1: '常用用法',
      p1: '要是你把你的秘密告诉了风，那就别怪风把它带给树。',
      p2: '没有什么比信念更能支撑我们度过艰难的时光了。',
      p3: '只要能把自己的事做好，并让自己快乐，你就领先于大多数人了。'
    }
  },
  'en': {
    i18n: {
      breadcrumb: 'International Products',
      tips: 'Click on the button to change the current language. ',
      btn: 'Switch Chinese',
      title1: 'Common usage',
      p1: "If you reveal your secrets to the wind you should not blame the wind for  revealing them to the trees.",
      p2: "Nothing can help us endure dark times better than our faith. ",
      p3: "If you can do what you do best and be happy, you're further along in life  than most people."
    }
  }
}
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import en from 'element-plus/es/locale/lang/en'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

import { createI18n } from 'vue-i18n'

import messages from '@/common/i18n';



const i18n = createI18n({
  locale: zhCn.name,
  fallbackLocale: en.name,
  messages,
})


/*创建element*/
export default (app: any) => {
  app.use(ElementPlus, {
    locale: zhCn,
    size: 'small',
    zIndex: 3000});
  app.use(i18n);
   // icon注册
  for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
  }
};
import installElement( from '@/plugins/element';

installElement(app)
```

## vuex配置

```javascript
import {createStore} from "vuex";


export default createStore({
  state: {
    count: 0
  },
  mutations: {
    addCount(state, data:number){
      state.count+=data
    }
  }
}
import store from '@/plugins/store';
app.use(store)
```

## router配置

```javascript
import {createRouter, createWebHashHistory} from "vue-router";

const routes = [
  {
    path: "/",
    name: "Home",
    component: () => import('@/view/Home.vue'),
    meta: {
      title: "主页"
    },
    children: [
      {
        path: "/child",
        name: "Child",
        component: () => import("@/view/child.vue"),
        meta: {
          title: "子页面"
        }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title}`;
  
  // 可以进行权限控制
  // const role = localStorage.getItem('ms_username');
  // if (!role && to.path !== '/login') {
  //   next('/login');
  // } else if (to.meta.permission) {
  //   // 如果是管理员权限则可进入，这里只是简单的模拟管理员权限而已
  //   role === 'admin'
  //       ? next()
  //       : next('/403');
  // } else {
  //   next();
  // }
  
  // 进入下个页面
  next();
});

export default router;
import router from '@/pugins/router'
app.vue(router);
```