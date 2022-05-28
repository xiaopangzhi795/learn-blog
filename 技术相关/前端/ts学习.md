# ts是什么

ts：TypeScript。它是微软公司，c#的首席架构师，安德斯.海尔斯伯格 编写的。

由于js本身的特性，无法胜任大型复杂的项目，所以有了ts，它是js的一个超集，在js的基础上添加了额外的语法，支持编译器在编译过程中发现错误并提示出来。

ts代码可以编译出纯净简介的js代码，它可以在js运行的任何地方运行。浏览器，node.js，或者应用程序中。

强大的工具构建，类型是可选的，类型推断让一些类型的注释使你的代码的静态验证有很大的不同。类型让你定义软件组织之间的接口和洞察现有js库的行为。



# 手册

## 基础类型

- 显式的声明类型，ts支持的类型和js几乎相同，此外还提供了枚举类型

```shell
# js
let isDone = false
let num = 3
let name = 'bob'

# ts
let isDone: boolean = false
let age: number = 18
let name: string = 'rubik'
## 数组
let list: Array<number> = [1,2,3]
## 元组
let x: [string, number];
x = ['rubik', 18]
x = ['money', 999]
## 枚举
enum Color {Red = 1, Green = 2, Blue = 3}
let c: Color = Color.Green
## any
let notSure: any = 4;
notSure = 'hello typescript'
notSure = false
```

# 变量声明

- let和const是js中比较新的变量声明方式，ts中天然支持。var是一个不被推荐的使用方式，原因是var的声明周期怪异，会导致项目中有很多怪异的地方。为了防止这种情况，出现了let和const。let和var基本一样，const是为了防止变量重新赋值，也就是常量。

```javascript
function f(num) {
    if (true) {
        var x = 123;
    }
    return x - num;
}

console.log(f(2));  // return 121
//在if中定义的变量，在外面依然可以访问到

//解决var的作用域，以前的古老做法是使用闭包的方式。现在使用模块化，let和const就可以解决该问题
```