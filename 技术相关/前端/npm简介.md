<a name="RHy3I"></a>
# npm是什么
npm（“Node 包管理器”）是 JavaScript 运行时 Node.js 的默认程序包管理器。<br />npm 由两个主要部分组成:

- 用于发布和下载程序包的 CLI（命令行界面）工具
- 托管 JavaScript 程序包的  [在线存储库](https://www.npmjs.com/)

<br />为了更直观地解释，我们可以将存储库  npmjs.com  视为一个物流集散中心，该中心从卖方（npm 包裹的作者）那里接收货物的包裹，并将这些货物分发给买方（npm 包裹的用户）。


<a name="KIrVE"></a>
# package.json
每个 JavaScript 项目（无论是 Node.js 还是浏览器应用程序）都可以被当作 npm 软件包，并且通过  package.json  来描述项目和软件包信息。<br />我们可以将  package.json  视为快递盒子上的运输信息<br />当运行  npm init  初始化 JavaScript/Node.js 项目时，将生成  package.json  文件，文件内的内容(基本元数据)由开发人员提供：

- `name`：JavaScript 项目或库的名称
- `version`： 项目的版本。通常，在应用程序开发中，由于没有必要对开源进行版本控制，因此经常忽略这一块。但是，仍可以用它来定义版本。
- `description`： 项目的描述
- `license`： 项目的许可证


<a name="SIZF6"></a>
# npm script
`package.json`  还支持一个 `scripts` 属性，可以把它当作在项目本地运行的命令行工具。 例如，一个`npm`项目的 `scripts` 部分可能看起来像这样
```shell
{
  "scripts": {
    "build": "tsc",
    "format": "prettier --write **/*.ts",
    "format-check": "prettier --check **/*.ts",
    "lint": "eslint src/**/*.ts",
    "pack": "ncc build",
    "test": "jest",
    "all": "npm run build && npm run format && npm run lint && npm run pack && npm test"
  }
}
```

`eslint` , `prettier`, `ncc` , `jest` 不是安装为全局可执行文件，而是安装在项目本地的  `node_modules/.bin/` 中

最新引入的  `npx`  使我们可以像在全局安装程序一样运行这些  `node_modules`  项目作用域命令，  方法是在其前面加上  `npx  ...`  （即 `npx prettier --write ** /*.ts`)
<a name="DFM2b"></a>
# denpendencies  vs  devDenpendencies
这两个以键值对象的形式出现，其中npm 库的名称为键， 其语意格式版本为值。 大家可以看看 github 的 TypeScript 操作模版中的示例：
```shell
{
  "dependencies": {
    "@actions/core": "^1.2.3",
    "@actions/github": "^2.1.1"
  },
  "devDependencies": {
    "@types/jest": "^25.1.4",
    "@types/node": "^13.9.0",
    "@typescript-eslint/parser": "^2.22.0",
    "@zeit/ncc": "^0.21.1",
    "eslint": "^6.8.0",
    "eslint-plugin-github": "^3.4.1",
    "eslint-plugin-jest": "^23.8.2",
    "jest": "^25.1.0",
    "jest-circus": "^25.1.0",
    "js-yaml": "^3.13.1",
    "prettier": "^1.19.1",
    "ts-jest": "^25.2.1",
    "typescript": "^3.8.3"
  }
}
```

这些依赖通过带有 --save 或 --save-dev  标志的 npm install 命令安装。<br />他们分别用于生产和开发/测试环境。 

- `^` ： 表示最新的次版本， 例如 `^1.0.4`  可能会安装主版本系列` 1` 的最新次版本 `1.3.0`
- `～` ： 表示最新的补丁程序版本，与 `^`  类似， `～1.0.4 ` 可能会安装次版本系列` 1.0 `的最新次版本 `1.0.7` 

所有这些确切的软件包版本都将记录在 package-lock.json 文件中。

<a name="GCHVb"></a>
# package-lock.json
该文件描述了 npm JavaScript 项目中使用的依赖项的确切版本。 如果 package.json 是通用的描述性标签， 则 package-lock.json 是成分表。

就像我们通常不会读取食品包装袋上的成分表（除非你太无聊或者需要知道）一样，package-lock.json 并不会被开发人员一行一行的进行读取。

package-lock.json 通常是由 npm  install  命令生成的，  也可以由我们的 npm cli 工具读取， 以确保使用 npm ci 复制项目的构建环境。

<a name="Ys5aj"></a>
# 如何使用npm

<a name="mv0oX"></a>
## npm install
这是最常用到的命令<br />默认情况下，npm install <package-name>  将安装带有 ^ 版本号的软件包的最新版本。 npm 项目上下文中的 npm install 将根据 package.json 规范将软件包下载到项目的 node_modules 文件夹中， 从而升级软件包的版本 （并重新生成 package-lock.json）。 npm install <package-name> 可以基于 `^` 和 `~` 版本匹配。

如果要在全局上下文中安装程序包，可以在机器的任何地方使用它，则可以指定全局标志。 -g  例如 `npm install -g live-server`

npm包太大，太深这样的问题可以通过 --production 标志来拯救。将此标志附加到 npm install 命令，我们将仅从 dependencies 安装软件包，从而将 node_modules 的大小大大减小到应用程序正常运行所必须的大小。 不应该将 devDependencies 引入生产环境。

<a name="Wjdg4"></a>
## npm ci
如果 npm install  --production  对于生产环境是最佳选项， npm ci 就是本地环境，测试环境最合适的选项。

就像如果 package_lock.json 尚不存在于项目中一样， 无论何时调用 npm install  都会生成它， npm ci 会消耗该文件来下载项目所依赖的每个软件包的确切版本。

这样，无论是用于本地开发的笔记本电脑，还是github actions等ci构建环境，我们都可以确保项目上下文在不同机器上保持完全相同。

<a name="VZgHi"></a>
## npm audit
npm.js维护了一个安全漏洞列表，开发人员可以使用 npm audit 命令来审核项目中的依赖项。

npm audit 为开发人员提供了有关漏洞以及是否有要修复的版本的信息。

如果补救措施在下一个不间断的版本升级中可用，则可以使用 npm audit fix 来自动升级受影响的依赖项的版本。

<a name="fOD5Z"></a>
## npm publish
只需要运行 npm publish，就可以将软件包发送到 npmjs.com , <br />根据  [semver.org](https://semver.org/)  的经验法则：

1. 当你进行不兼容的 API 更改时使用 MAJOR 版本
1. 以向后兼容的方式添加功能时使用 MINOR 版本
1. 进行向后兼容的 bug 修复时使用 PATCH 版本




