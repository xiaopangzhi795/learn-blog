# linux无法使用 ll 命令

## centos
- 打开 ~/.bashrc，添加
  
```
alias ll='ls -l'
```

- 使之生效

```
source ~/.bashrc
```