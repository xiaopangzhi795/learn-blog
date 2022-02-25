#!/bin/sh

## mac系统，让自动启动脚本生效的命令
launchctl load /Users/qian/command/automaticStart/sync.plist

## 卸载服务的话，使用unload
#launchctl unload /Users/qian/command/automaticStart/sync.plist