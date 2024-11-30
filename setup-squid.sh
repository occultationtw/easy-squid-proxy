#!/bin/bash

# Set -e: Exit immediately if a command exits with a non-zero status.
# 設定 -e: 若任何指令執行失敗，立即結束腳本
set -e
# Set -u: Treat unset variables as an error.
# 設定 -u: 將未設定的變數視為錯誤
set -u

# Color variables for enhanced output
# 顏色變數，用於增強輸出效果
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
nc='\033[0m' # No Color/Reset color

# Function to print colored messages with newline
# 印出帶換行符的彩色訊息的函數
print_message() {
  color="$1"
  message="$2"
  echo -e "${color}${message}${nc}"
}

# Function to print colored messages without newline
# 印出不帶換行符的彩色訊息的函數 (用於提示)
print_prompt() {
    color="$1"
    message="$2"
    printf "${color}${message}${nc}"
}



# Prompt the user for input, requiring a username
# 提示使用者輸入，要求輸入使用者名稱
while [[ -z "${PROXY_USER:-}" ]]; do
    print_prompt ${blue} "Enter the proxy server username: "
    print_prompt ${blue} "輸入代理伺服器使用者名稱: "
    read PROXY_USER
    echo "" # Newline for better formatting
    if [[ -z "$PROXY_USER" ]]; then
        print_message ${red} "Username cannot be empty. Please enter a valid username."
        print_message ${red} "使用者名稱不能為空。請輸入有效的使用者名稱。"
    fi
done

# Prompt the user for input, requiring a password
# 提示使用者輸入，要求輸入密碼
while [[ -z "${PROXY_PASSWORD:-}" ]]; do
    print_prompt ${blue} "Enter the proxy server password: "
    print_prompt ${blue} "輸入代理伺服器密碼: "
    read -s PROXY_PASSWORD
    echo "" # Newline for better formatting
    if [[ -z "$PROXY_PASSWORD" ]]; then
        print_message ${red} "Password cannot be empty. Please enter a valid password."
        print_message ${red} "密碼不能為空。請輸入有效的密碼。"
    fi
done

# Prompt the user for input, validating the port number
# 提示使用者輸入，並驗證 port 是否有被佔用
while true; do
    print_prompt ${blue} "Enter the proxy server port (default: 8080): "
    print_prompt ${blue} "輸入代理伺服器埠號 (預設值: 8080): "
    read PROXY_PORT
    PROXY_PORT=${PROXY_PORT:-8080}
    echo ""

    # 檢查 port 是否為數字
    if [[ ! "$PROXY_PORT" =~ ^[0-9]+$ ]]; then
        print_message ${red} "Invalid port number. Please enter a valid number."
        print_message ${red} "無效的埠號。請輸入有效的數字。"
        continue
    fi

    # 檢查範圍 (1-65535)
    if (( PROXY_PORT < 1 || PROXY_PORT > 65535 )); then
        print_message ${red} "Port number out of range (1-65535). Please enter a valid port."
        print_message ${red} "埠號超出範圍 (1-65535)。請輸入有效的埠號。"
        continue
    fi


    # 檢查是否被佔用
    if ss -tulnp | grep ":$PROXY_PORT " | grep -v squid; then
      OCCUPIED_BY=$(ss -tulnp | grep ":$PROXY_PORT " | awk '{print $5}' | awk -F':' '{print $2}')
      print_message ${red} "Port $PROXY_PORT is already in use by: $OCCUPIED_BY. Please choose another port."
      print_message ${red} "埠 $PROXY_PORT 已被 $OCCUPIED_BY 使用。請選擇其他埠。"
      continue
    fi

    # 都通過就跳出
    break
done

# Install required packages
# 安裝必要的套件
print_message ${yellow} "Installing required packages..."
print_message ${yellow} "正在安裝必要的套件..."
apt update && apt install -y squid apache2-utils || { print_message ${red} "Package installation failed (套件安裝失敗)"; exit 1; }
print_message ${green} "Package installation successful (套件安裝成功)"


# Create the password file
# 建立密碼檔案
touch /etc/squid/passwd || { print_message ${red} "Failed to create password file (建立密碼檔案失敗)"; exit 1; }
chmod 777 /etc/squid/passwd || { print_message ${red} "Failed to change permissions on password file (更改密碼檔案權限失敗)"; exit 1; }
ESCAPED_PROXY_PASSWORD=$(printf '%q' "$PROXY_PASSWORD")
htpasswd -cb /etc/squid/passwd "$PROXY_USER" "$ESCAPED_PROXY_PASSWORD" || { print_message ${red} "Failed to create htpasswd entry (建立 htpasswd 項目失敗)"; exit 1; }

# Backup the original configuration file (if it exists)
# 備份原始設定檔 (如果存在)
if [[ -f /etc/squid/squid.conf ]]; then
  cp /etc/squid/squid.conf /etc/squid/squid.conf.bak || { print_message ${red} "Failed to backup squid.conf (備份 squid.conf 失敗)"; exit 1; }
fi

# Update squid configuration file
# 更新 squid 設定檔
cat > /etc/squid/squid.conf << EOF || { print_message ${red} "Failed to write squid.conf (寫入 squid.conf 失敗)"; exit 1; }
acl all src all

acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Squid proxy-caching web server
auth_param basic credentialsttl 24 hours
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

http_access deny all

http_port $PROXY_PORT

via off
forwarded_for delete
follow_x_forwarded_for deny all
request_header_access X-Forwarded-For deny all
request_header_access From deny all
request_header_access Referer deny all
request_header_access User-Agent deny all

refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern \/(Packages|Sources)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims
refresh_pattern \/Release(|\.gpg)$ 0 0% 0 refresh-ims
refresh_pattern \/InRelease$ 0 0% 0 refresh-ims
refresh_pattern \/(Translation-.*)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims
refresh_pattern .		0	20%	4320

cache deny all
access_log none
cache_store_log none
cache_log /dev/null
EOF

# Restart squid service
# 重新啟動 squid 服務
systemctl restart squid || { print_message ${red} "Failed to restart squid service (重新啟動 squid 服務失敗)"; exit 1; }

# Check squid service status and display a concise message
# 檢查 squid 服務狀態並顯示訊息
if systemctl is-active --quiet squid; then
  print_message ${green} "Squid service started successfully. (Squid 服務已成功啟動.)"
else
  print_message ${red} "Squid service failed to start. (Squid 服務啟動失敗.)"
fi



# Display configuration details
# 顯示設定詳細資訊
echo ""
current_ip=$(curl -s ifconfig.me) || { print_message ${red} "Failed to get current IP (取得目前 IP 位址失敗)"; current_ip="Could not determine IP (無法確定 IP)"; }

print_message ${green} "（Proxy server setup complete. Use the following details to connect）"
print_message ${green} "（代理伺服器設定完成。請使用以下資訊進行連線）"
print_message ${yellow} "IP Address: ${current_ip}"
print_message ${yellow} "Port: ${PROXY_PORT}"
print_message ${yellow} "Username: ${PROXY_USER}"
print_message ${yellow} "Password: ${ESCAPED_PROXY_PASSWORD}"
