#!/bin/sh

## 获取当前路径
cur_dir=$(pwd)

echo "current path is :" $cur_dir

## 当前shell的路径是什么？参数传进来
cur_shell=$1

echo "current shell path is :" $cur_shell

# 将当前的shell路径添加到rc中，可以缺省调用
echo "export SHELL_PATH=$cur_dir" >> $cur_shell
echo "export PATH=\$PATH:/\$SHELL_PATH" >> $cur_shell 

# 使path生效
source $cur_shell