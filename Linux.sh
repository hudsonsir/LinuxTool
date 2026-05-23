#!/bin/bash

# 颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# 检测并自动安装 sudo（部分精简系统镜像默认未安装）
ensure_sudo() {
    if command -v sudo &> /dev/null; then
        return 0
    fi

    echo "未检测到 sudo，正在尝试自动安装..."

    if [ "$(id -u)" -ne 0 ]; then
        echo "当前用户非 root，且系统未安装 sudo，无法自动安装。"
        echo "请先以 root 身份登录后重新执行本脚本。"
        exit 1
    fi

    if command -v apt-get &> /dev/null; then
        apt-get update -y && apt-get install -y sudo
    elif command -v dnf &> /dev/null; then
        dnf install -y sudo
    elif command -v yum &> /dev/null; then
        yum install -y sudo
    elif command -v apk &> /dev/null; then
        apk add --no-cache sudo
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm sudo
    elif command -v zypper &> /dev/null; then
        zypper install -y sudo
    else
        echo "未识别的包管理器，无法自动安装 sudo，请手动安装后重试。"
        exit 1
    fi

    if ! command -v sudo &> /dev/null; then
        echo "sudo 安装失败，请检查网络或软件源后手动安装。"
        exit 1
    fi

    echo "sudo 安装完成。"
}

# 获取服务器状态信息
server_ip=$(hostname -I 2>/dev/null)
uptime=$(uptime -p 2>/dev/null)
uptime_cn=$(echo "$uptime" | sed 's/up/已运行/; s/hour/时/; s/minutes/分/; s/days/天/; s/months/月/')

# 根据当前时间返回问候语
get_greeting() {
    local hour
    hour=$(date +"%H")

    case "$hour" in
        1|2|3|4|5|6|7|8|9|10|11)
            echo "上午好！欢迎使用Linux工具"
            ;;
        12|13|14|15|16|17|18)
            echo "下午好！欢迎使用Linux工具"
            ;;
        *)
            echo "晚上好！欢迎使用Linux工具"
            ;;
    esac
}

show_menu() {
    clear
    local greeting
    greeting=$(get_greeting)

    echo -e "
===================================================
✪  工具名称：${RED}Linux工具${RESET}            
✪  服务器IP：$server_ip
✪  运行时间：$uptime_cn
--------------------[综合菜单]---------------------

   1. 系统操作菜单(修改密码、SSH端口、更新系统等)
   q. 退出脚本
   u. 卸载脚本

===================================================
$greeting
	"
}

# 系统操作菜单
system_menu() {
    clear
    echo "=== 系统操作菜单 ==="
    echo "1. 更新本地脚本"
    echo "2. 一键修改密码"
    echo "3. 一键同步上海时间"
    echo "4. 一键修改SSH端口"
    echo "5. 一键修改DNS"
    echo "6. 一键开启/关闭SSH登录"
    echo "7. 一键更新CentOS最新版系统"
    echo "8. 一键更新Ubuntu最新版系统"
    echo "9. 一键更新Debian最新版系统"
    echo "10. 一键更换系统软件源(LinuxMirrors)"
    echo "11. 一键创建子用户或管理员"
    echo "12. 一键查看当前与服务器连接的IP"
    echo "13. 一键修改服务器主机名"
    echo "14. 一键查看SSH登录成功的IP地址"
    echo "15. 查看当前服务器时区时间"
    echo "16. 一键设置SWAP大小"
    echo "17. 一键开启/关闭IPv6"
    echo "q. 返回上级菜单"
    echo "===================="
}

# 卸载本地脚本
uninstall_script() {
    local script_path confirm

    script_path="$(readlink -f "$0" 2>/dev/null || echo "$0")"

    echo "即将卸载本地脚本: $script_path"
    read -p "确认删除该脚本及其备份文件吗？(y/N): " confirm
    case "$confirm" in
        y|Y|yes|YES)
            rm -f "${script_path}.bak" 2>/dev/null
            if rm -f "$script_path"; then
                echo "脚本已成功卸载，再见！"
                exit 0
            else
                echo "删除失败，请使用 sudo 重新运行后再试。"
                return 1
            fi
            ;;
        *)
            echo "已取消卸载。"
            ;;
    esac
}

# 更新本地脚本
update_script() {
    local remote_url="https://raw.githubusercontent.com/hudsonsir/LinuxTool/main/Linux.sh"
    local script_path tmp_file

    script_path="$(readlink -f "$0" 2>/dev/null || echo "$0")"
    tmp_file="$(mktemp)"

    echo "正在从 GitHub 拉取最新版本的脚本..."
    echo "源地址: $remote_url"
    echo "本地路径: $script_path"

    if ! command -v curl &> /dev/null; then
        echo "未检测到 curl，请先安装 curl 后再试。"
        return 1
    fi

    if ! curl -fsSL "$remote_url" -o "$tmp_file"; then
        echo "下载失败，请检查网络或稍后重试。"
        rm -f "$tmp_file"
        return 1
    fi

    if [ ! -s "$tmp_file" ]; then
        echo "下载到的文件为空，已取消更新。"
        rm -f "$tmp_file"
        return 1
    fi

    if ! bash -n "$tmp_file" 2>/dev/null; then
        echo "新脚本语法校验失败，已取消更新。"
        rm -f "$tmp_file"
        return 1
    fi

    cp "$script_path" "${script_path}.bak" 2>/dev/null && echo "已备份当前脚本到 ${script_path}.bak"
    if ! cp "$tmp_file" "$script_path"; then
        echo "写入失败，请使用 sudo 重新运行后再试。"
        rm -f "$tmp_file"
        return 1
    fi

    chmod +x "$script_path"
    rm -f "$tmp_file"

    echo "脚本更新完成，正在重新加载..."
    exec bash "$script_path"
}

# 一键修改密码
change_password() {
    local username
    username=$(whoami)
    sudo passwd "$username"
    echo "密码已成功修改。"
}

# 检查并安装 ntpdate
install_ntpdate() {
    if command -v ntpdate &> /dev/null; then
        return 0
    fi

    echo "正在安装 ntpdate..."
    if [ -f /etc/redhat-release ]; then
        sudo yum install -y ntpdate
    elif [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install -y ntpdate
    else
        echo "不支持的操作系统类型。"
        return 1
    fi
    echo "ntpdate 安装完成。"
}

# 同步上海时间
sync_shanghai_time() {
    install_ntpdate || return 1
    echo "正在同步上海时间..."
    sudo timedatectl set-timezone Asia/Shanghai
    sudo ntpdate cn.pool.ntp.org
    echo "时间同步完成。"
}

# 一键修改 SSH 端口
change_ssh_port() {
    local new_port use_socket socket_name dropin_dir restart_confirm server_ip

    read -p "请输入新的 SSH 端口: " new_port
    if ! [[ "$new_port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}错误：端口必须是纯数字${RESET}"
        return 1
    fi

    if [ "$new_port" -lt 1 ] || [ "$new_port" -gt 65535 ]; then
        echo -e "${RED}错误：端口范围必须在 1-65535 之间${RESET}"
        return 1
    fi

    local SSH_CONFIG="/etc/ssh/sshd_config"
    sudo cp "$SSH_CONFIG" "${SSH_CONFIG}.bak" 2>/dev/null

    if grep -q "^Port " "$SSH_CONFIG"; then
        sudo sed -i "s/^Port .*/Port $new_port/g" "$SSH_CONFIG"
    elif grep -q "^#\s*Port " "$SSH_CONFIG"; then
        sudo sed -i "s/^#\s*Port .*/Port $new_port/g" "$SSH_CONFIG"
    else
        echo "Port $new_port" | sudo tee -a "$SSH_CONFIG" > /dev/null
    fi

    use_socket=0
    socket_name=""
    if systemctl is-active --quiet ssh.socket; then
        use_socket=1
        socket_name="ssh.socket"
    elif systemctl is-active --quiet sshd.socket; then
        use_socket=1
        socket_name="sshd.socket"
    fi

    if [ "$use_socket" -eq 1 ]; then
        echo -e "${YELLOW}检测到系统当前正在使用 Socket 模式管理 SSH (${socket_name})，正在进行兼容性配置...${RESET}"
        dropin_dir="/etc/systemd/system/${socket_name}.d"
        sudo mkdir -p "$dropin_dir"
        cat <<EOF | sudo tee "$dropin_dir/listen.conf" > /dev/null
[Socket]
ListenStream=
ListenStream=$new_port
EOF
        echo "Systemd Socket 端口覆盖配置已生成。"
    fi

    if ! sudo sshd -t 2>/dev/null; then
        echo -e "${RED}SSH 配置检测失败，正在恢复原配置...${RESET}"
        sudo cp "${SSH_CONFIG}.bak" "$SSH_CONFIG"
        if [ "$use_socket" -eq 1 ]; then
            sudo rm -f "/etc/systemd/system/${socket_name}.d/listen.conf"
        fi
        return 1
    fi

    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow "$new_port"/tcp >/dev/null 2>&1
    fi

    if command -v firewall-cmd >/dev/null 2>&1; then
        sudo firewall-cmd --permanent --add-port=${new_port}/tcp >/dev/null 2>&1
        sudo firewall-cmd --reload >/dev/null 2>&1
    fi

    echo -e "${GREEN}SSH 端口配置成功，新端口: $new_port${RESET}"
    read -p "是否立即重启 SSH 服务使配置生效？(y/n): " restart_confirm

    if [[ "$restart_confirm" =~ ^[Yy]$ ]]; then
        if [ "$use_socket" -eq 1 ]; then
            sudo systemctl daemon-reload
            sudo systemctl restart "$socket_name"
        fi

        if systemctl list-unit-files | grep -q '^sshd.service'; then
            sudo systemctl restart sshd
        else
            sudo systemctl restart ssh
        fi

        server_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
        echo "SSH 服务已重启"
        echo -e "${YELLOW}请务必保留当前终端，并新开一个窗口测试连接：${RESET}"
        echo "ssh -p $new_port $(whoami)@$server_ip"
    else
        echo "已取消重启，配置将在下次手动重启服务或重载 Systemd 后生效。"
    fi
}

# 一键修改 DNS
set_dns() {
    local dns_server

    read -p "请输入新的DNS服务器地址: " dns_server
    if [ -z "$dns_server" ]; then
        echo "DNS 服务器地址不能为空。"
        return 1
    fi

    if [[ -f /etc/redhat-release ]]; then
        echo "nameserver $dns_server" | sudo tee /etc/resolv.conf >/dev/null
    elif [[ -f /etc/lsb-release || -f /etc/debian_version ]]; then
        if grep -q "^nameserver " /etc/resolv.conf; then
            sudo sed -i "s/^nameserver .*/nameserver $dns_server/" /etc/resolv.conf
        else
            echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf >/dev/null
        fi
    else
        echo "不支持的操作系统"
        return 1
    fi

    echo "DNS服务器已修改为 $dns_server"
}

# 一键开启/关闭 SSH 登录
toggle_ssh() {
    local service_name

    if systemctl list-unit-files | grep -q '^sshd.service'; then
        service_name="sshd"
    elif systemctl list-unit-files | grep -q '^ssh.service'; then
        service_name="ssh"
    else
        echo "未检测到 ssh/sshd 服务。"
        return 1
    fi

    if sudo systemctl is-active --quiet "$service_name"; then
        sudo systemctl stop "$service_name"
        sudo systemctl disable "$service_name"
        echo "SSH登录已禁用"
    else
        sudo systemctl enable "$service_name"
        sudo systemctl start "$service_name"
        echo "SSH登录已启用"
    fi
}

# 一键更新 CentOS 最新版系统
update_centos() {
    local confirm

    read -p "确认要更新 CentOS 最新版系统吗？(y/n): " confirm
    if [[ "$confirm" == [yY] ]]; then
        echo "正在更新 CentOS 最新版系统..."
        sudo yum update -y
        echo "CentOS 最新版系统更新完成"
        sudo reboot
    else
        echo "取消更新 CentOS 最新版系统"
    fi
}

# 一键更新 Ubuntu 最新版系统
update_ubuntu() {
    local confirm

    read -p "确认要更新 Ubuntu 最新版系统吗？(y/n): " confirm
    if [[ "$confirm" == [yY] ]]; then
        echo "正在更新 Ubuntu 最新版系统..."
        sudo apt update
        sudo apt upgrade -y
        echo "Ubuntu 最新版系统更新完成"
        sudo reboot
    else
        echo "取消更新 Ubuntu 最新版系统"
    fi
}

# 一键更新 Debian 最新版系统
update_debian() {
    local confirm

    read -p "确认要更新 Debian 最新版系统吗？(y/n): " confirm
    if [[ "$confirm" == [yY] ]]; then
        echo "正在更新 Debian 最新版系统..."
        sudo apt update
        sudo apt upgrade -y
        echo "Debian 最新版系统更新完成"
        sudo reboot
    else
        echo "取消更新 Debian 最新版系统"
    fi
}

# 使用 LinuxMirrors 一键更换系统软件源
change_system_mirror() {
    echo "即将调用 LinuxMirrors 一键换源脚本..."
    echo "项目地址: https://github.com/SuperManito/LinuxMirrors"
    if ! command -v curl &> /dev/null; then
        echo "未检测到 curl，请先安装 curl 后再试。"
        return 1
    fi
    bash <(curl -sSL https://linuxmirrors.cn/main.sh)
}

# 一键创建子用户或管理员
create_user() {
    local username add_sudo sudo_group

    read -p "请输入要创建的用户名: " username
    if [ -z "$username" ]; then
        echo "用户名不能为空。"
        return 1
    fi

    if id "$username" &>/dev/null; then
        echo "用户 $username 已存在"
        return 0
    fi

    sudo useradd -m "$username"
    if [ $? -ne 0 ]; then
        echo "创建用户 $username 失败"
        return 1
    fi

    echo "用户 $username 创建成功"
    sudo passwd "$username"

    read -p "是否要将用户 $username 设置为管理员(y/n): " add_sudo
    if [[ "$add_sudo" =~ ^[Yy]$ ]]; then
        if getent group sudo >/dev/null; then
            sudo_group="sudo"
        else
            sudo_group="wheel"
        fi
        sudo usermod -aG "$sudo_group" "$username"
        echo "用户 $username 已加入 $sudo_group 管理员组"
    fi
}

# 尝试安装 netstat
install_netstat() {
    if command -v netstat &> /dev/null; then
        return 0
    fi

    echo "netstat 未安装，正在尝试安装..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
    fi

    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt-get update
        sudo apt-get install -y net-tools
    elif [[ "$ID" == "centos" || "$ID" == "rhel" || -f /etc/redhat-release ]]; then
        sudo yum install -y net-tools
    else
        echo "不支持的操作系统"
        return 1
    fi
}

# 查看连接到本机的远程 IP 地址数量
show_connected_ips_count() {
    install_netstat || return 1
    netstat -tn | awk '{print $5}' | grep -v 'Address' | cut -d: -f1 | sort | uniq -c | sort -nr
}

# 一键修改服务器主机名
change_hostname() {
    local new_hostname old_hostname success current_hostname

    old_hostname=$(hostname 2>/dev/null)
    read -p "请输入新的主机名 (当前: ${old_hostname}): " new_hostname

    if [ -z "$new_hostname" ]; then
        echo "错误：主机名不能为空。"
        return 1
    fi

    if [ "${#new_hostname}" -gt 63 ]; then
        echo "错误：主机名长度不能超过 63 个字符。"
        return 1
    fi

    if ! [[ "$new_hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
        echo "错误：主机名仅允许字母、数字和连字符，且不能以连字符开头或结尾。"
        return 1
    fi

    if [ "$new_hostname" = "$old_hostname" ]; then
        echo "新主机名与当前一致，无需修改。"
        return 0
    fi

    echo "正在将主机名从 [${old_hostname}] 修改为 [${new_hostname}]..."
    [ -f /etc/hostname ] && sudo cp /etc/hostname /etc/hostname.bak 2>/dev/null
    [ -f /etc/hosts ] && sudo cp /etc/hosts /etc/hosts.bak 2>/dev/null

    success=0
    if command -v hostnamectl &> /dev/null; then
        sudo hostnamectl set-hostname "$new_hostname" 2>/dev/null && success=1
    fi

    if [ "$success" -eq 0 ]; then
        sudo hostname "$new_hostname" 2>/dev/null && success=1
        echo "$new_hostname" | sudo tee /etc/hostname > /dev/null 2>&1 && success=1
    fi

    if [ "$success" -eq 0 ]; then
        echo "错误：修改主机名失败，已尝试恢复原配置。"
        [ -f /etc/hostname.bak ] && sudo mv /etc/hostname.bak /etc/hostname 2>/dev/null
        return 1
    fi

    if [ -f /etc/hosts ]; then
        if grep -q "127.0.1.1" /etc/hosts; then
            sudo sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t${new_hostname}/" /etc/hosts
        elif [ -n "$old_hostname" ] && grep -qw "$old_hostname" /etc/hosts; then
            sudo sed -i "s/\b${old_hostname}\b/${new_hostname}/g" /etc/hosts
        else
            echo -e "127.0.1.1\t${new_hostname}" | sudo tee -a /etc/hosts > /dev/null
        fi
    fi

    current_hostname=$(hostname 2>/dev/null)
    if [ "$current_hostname" = "$new_hostname" ]; then
        echo "主机名已成功修改为：$new_hostname"
        sudo rm -f /etc/hostname.bak /etc/hosts.bak 2>/dev/null
    else
        echo "主机名文件已修改，但运行时主机名仍为：${current_hostname}"
        echo "请重启系统或重新登录使其完全生效。"
    fi
}

# 获取 SSH 登录日志路径
get_log_file_path() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            centos|rhel|fedora|rocky|almalinux)
                echo "/var/log/secure"
                ;;
            ubuntu|debian)
                echo "/var/log/auth.log"
                ;;
            *)
                return 1
                ;;
        esac
    else
        return 1
    fi
}

# 一键查看 SSH 登录成功的 IP 地址
show_login_ips() {
    local log_file_path

    log_file_path=$(get_log_file_path) || {
        echo "不支持的操作系统，无法确定 SSH 登录日志路径。"
        return 1
    }

    if [ ! -f "$log_file_path" ]; then
        echo "未找到日志文件：$log_file_path"
        return 1
    fi

    grep 'sshd.*Accepted' "$log_file_path" | awk '{print $11}' | sort | uniq
}

# 查看当前服务器时区与时间
show_timezone() {
    echo "=== 服务器时区与时间 ==="
    if command -v timedatectl &> /dev/null; then
        timedatectl
    else
        echo "当前时区: $(cat /etc/timezone 2>/dev/null || readlink -f /etc/localtime | sed 's|.*/zoneinfo/||')"
        echo "本地时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
        echo "UTC 时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    fi
    echo "========================"
}

# SWAP 设置菜单
set_swap_menu() {
    local swap_choice swap_size_mb

    echo "========================="
    echo "     SWAP 大小设置"
    echo "========================="
    echo "1. 500MB"
    echo "2. 1GB"
    echo "3. 2GB"
    echo "4. 5GB"
    echo "5. 自定义大小(MB)"
    echo "========================="

    read -p "请选择: " swap_choice
    case "$swap_choice" in
        1)
            swap_size_mb=500
            ;;
        2)
            swap_size_mb=1024
            ;;
        3)
            swap_size_mb=2048
            ;;
        4)
            swap_size_mb=5120
            ;;
        5)
            read -p "请输入SWAP大小(MB): " swap_size_mb
            if ! [[ "$swap_size_mb" =~ ^[0-9]+$ ]]; then
                echo "请输入正确的数字"
                return 1
            fi
            ;;
        *)
            echo "无效选项"
            return 1
            ;;
    esac

    echo "准备设置 ${swap_size_mb}MB SWAP..."
    sudo swapoff -a 2>/dev/null
    sudo sed -i '/\/swapfile/d' /etc/fstab
    sudo rm -f /swapfile

    sudo fallocate -l "${swap_size_mb}M" /swapfile
    if [ $? -ne 0 ]; then
        sudo dd if=/dev/zero of=/swapfile bs=1M count="$swap_size_mb"
    fi

    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab >/dev/null

    echo "SWAP 设置完成"
    free -h
}

# 一键开启/关闭 IPv6
toggle_ipv6() {
    local disable_all choice SYSCTL_CONF

    echo "=== 正在检测 IPv6 状态 ==="
    disable_all=$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null)

    if [ -z "$disable_all" ]; then
        if ip addr show | grep -q "inet6"; then
            disable_all=0
        else
            disable_all=1
        fi
    fi

    SYSCTL_CONF="/etc/sysctl.conf"
    [ -f "$SYSCTL_CONF" ] && sudo cp "$SYSCTL_CONF" "${SYSCTL_CONF}.bak" 2>/dev/null

    if [ "$disable_all" -eq 0 ]; then
        echo -e "当前 IPv6 状态：${GREEN}已开启 (Enabled)${RESET}"
        read -p "是否要【关闭】IPv6 功能？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "正在关闭 IPv6..."
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null
            sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1 >/dev/null
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' "$SYSCTL_CONF"
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' "$SYSCTL_CONF"
            sudo sed -i '/net.ipv6.conf.lo.disable_ipv6/d' "$SYSCTL_CONF"
            echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a "$SYSCTL_CONF" >/dev/null
            echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a "$SYSCTL_CONF" >/dev/null
            echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a "$SYSCTL_CONF" >/dev/null
            sudo sysctl -p >/dev/null 2>&1
            echo -e "${YELLOW}IPv6 已关闭，配置已持久化。部分服务可能需要重启生效。${RESET}"
        else
            echo "已取消操作。"
        fi
    else
        echo -e "当前 IPv6 状态：${RED}已关闭 (Disabled)${RESET}"
        read -p "是否要【开启】IPv6 功能？(y/n): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            echo "正在开启 IPv6..."
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null
            sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0 >/dev/null
            sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=0 >/dev/null
            sudo sed -i '/net.ipv6.conf.all.disable_ipv6/d' "$SYSCTL_CONF"
            sudo sed -i '/net.ipv6.conf.default.disable_ipv6/d' "$SYSCTL_CONF"
            sudo sed -i '/net.ipv6.conf.lo.disable_ipv6/d' "$SYSCTL_CONF"
            echo "net.ipv6.conf.all.disable_ipv6 = 0" | sudo tee -a "$SYSCTL_CONF" >/dev/null
            echo "net.ipv6.conf.default.disable_ipv6 = 0" | sudo tee -a "$SYSCTL_CONF" >/dev/null
            echo "net.ipv6.conf.lo.disable_ipv6 = 0" | sudo tee -a "$SYSCTL_CONF" >/dev/null
            sudo sysctl -p >/dev/null 2>&1
            echo -e "${GREEN}IPv6 已开启，配置已持久化。${RESET}"
        else
            echo "已取消操作。"
        fi
    fi
}

ensure_sudo

# 主循环
while true; do
    show_menu
    read -p "请输入选项: " choice
    case "$choice" in
        1)
            while true; do
                system_menu
                read -p "请输入选项: " system_choice
                case "$system_choice" in
                    1)
                        update_script
                        ;;
                    2)
                        change_password
                        ;;
                    3)
                        sync_shanghai_time
                        ;;
                    4)
                        change_ssh_port
                        ;;
                    5)
                        set_dns
                        ;;
                    6)
                        toggle_ssh
                        ;;
                    7)
                        update_centos
                        ;;
                    8)
                        update_ubuntu
                        ;;
                    9)
                        update_debian
                        ;;
                    10)
                        change_system_mirror
                        ;;
                    11)
                        create_user
                        ;;
                    12)
                        show_connected_ips_count
                        ;;
                    13)
                        change_hostname
                        ;;
                    14)
                        show_login_ips
                        ;;
                    15)
                        show_timezone
                        ;;
                    16)
                        set_swap_menu
                        ;;
                    17)
                        toggle_ipv6
                        ;;
                    q|Q)
                        break
                        ;;
                    *)
                        echo "无效的选项，请重新输入"
                        ;;
                esac
                read -p "按回车键继续..."
            done
            ;;
        q|Q)
            echo "再见！"
            break
            ;;
        u|U)
            uninstall_script
            ;;
        *)
            echo "无效的选项，请重新输入"
            ;;
    esac
    read -p "按回车键继续..."
done
