# Linux Tools 脚本仓库

## 脚本功能

<font style="color:rgb(67, 67, 107);">该脚本工具的功能是快速换源，一键安装BBR、宝塔面板等，测试服务器回程线路、IP质量、流媒体解锁以及服务器性能情况、提供多种操作菜单以实现系统、网络、文件传输等功能。以下是具体功能总结：  
(AI生成的总结，如有错误或遗漏请反馈)
</font>

#### **<font style="color:rgba(0, 0, 0, 0.85);">1. 系统菜单</font>**
+ **<font style="color:rgb(67, 67, 107);">重启服务器</font>**<font style="color:rgb(67, 67, 107);">：用户可以通过该功能重启服务器，确保系统的正常运行。</font>
+ **<font style="color:rgb(67, 67, 107);">修改密码</font>**<font style="color:rgb(67, 67, 107);">：提供了一键修改服务器登录密码的功能，提高安全性。</font>
+ **<font style="color:rgb(67, 67, 107);">同步上海时间</font>**<font style="color:rgb(67, 67, 107);">：通过安装ntpdate同步服务器时间，确保时间的准确性。</font>
+ **<font style="color:rgb(67, 67, 107);">修改SSH端口</font>**<font style="color:rgb(67, 67, 107);">：用户可以方便地更改SSH端口，增强安全性。</font>
+ **<font style="color:rgb(67, 67, 107);">修改DNS</font>**<font style="color:rgb(67, 67, 107);">：支持一键修改DNS设置，提高域名解析速度。</font>
+ **<font style="color:rgb(67, 67, 107);">开启/关闭SSH登录</font>**<font style="color:rgb(67, 67, 107);">：可以禁用或启用SSH登录功能，提升系统安全。</font>
+ **<font style="color:rgb(67, 67, 107);">更新系统版本</font>**<font style="color:rgb(67, 67, 107);">：支持一键更新CentOS、Ubuntu和Debian等系统的最新版本，确保系统的稳定性和安全性。</font>
+ **<font style="color:rgb(67, 67, 107);">更换源</font>**<font style="color:rgb(67, 67, 107);">：提供更换不同操作系统源为阿里云镜像的功能，确保软件包的更新和稳定性。</font>
+ **<font style="color:rgb(67, 67, 107);">创建用户和管理员</font>**<font style="color:rgb(67, 67, 107);">：允许用户创建新用户并设置权限，满足多用户环境的管理需求。</font>
+ **<font style="color:rgb(67, 67, 107);">查看当前连接IP</font>**<font style="color:rgb(67, 67, 107);">：显示当前与服务器连接的IP地址，有助于网络安全管理。</font>
+ **<font style="color:rgb(67, 67, 107);">修改主机名</font>**<font style="color:rgb(67, 67, 107);">：允许用户修改服务器的主机名，便于管理和识别。</font>

## 更新日志
- 2026年5月7日更新，精简菜单仅保留系统操作菜单；移除内置阿里云换源逻辑，统一调用 LinuxMirrors 一键换源脚本；移除 CentOS8 Stream 仓库源更新功能；新增「查看当前服务器时区时间」功能。

## 特别感谢
- LinuxMirrors<br>
免费开源Linux换源脚本及docker安装脚本<br>
项目链接：https://github.com/SuperManito/LinuxMirrors
- 所有脚本中包含，但未提及的开源项目维护者。


## 使用方法
项目地址：[https://github.com/hudsonsir/LinuxTool](https://github.com/hudsonsir/LinuxTool)

大陆服务器
```bash
curl -L https://ghfast.top/https://raw.githubusercontent.com/hudsonsir/LinuxTool/main/Linux.sh -o Linux.sh && chmod +x Linux.sh && bash Linux.sh
```
境外服务器
```bash
curl -L https://raw.githubusercontent.com/hudsonsir/LinuxTool/main/Linux.sh -o Linux.sh && chmod +x Linux.sh && bash Linux.sh
```
