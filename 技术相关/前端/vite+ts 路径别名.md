## 安装依赖

```javascript
npm i path -D
```



## vite.config.ts

```javascript
resolve: {
  alias: {
    '@': path.resolve("./src"),
  }
}
```

## tsconfig.json

```javascript
"compilerOptions": {
    ...
    "types": ["element-plus/global"],
    "baseUrl": "./", // 解析非相对模块的基地址，默认是当前目录
    "paths": { //路径映射，相对于baseUrl
      "@/*": ["src/*"]
    },
    "allowSyntheticDefaultImports": true // 允许默认导入
  },
```