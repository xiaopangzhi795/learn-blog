#!/bin/sh
## 打印参数个数
echo "param count is :" $#

# 如果参数个数不是一个，就打印错误信息，并退出
if [ "$#" -ne 1 ]; then
	echo "error path! please enter a path to open."
	exit 1;
fi

# 打印即将要打开的文件
echo "is about to open $1 in vscode"

# 调用vscode 进行打开该文件
open $1 -a Visual\ Studio\ Code

