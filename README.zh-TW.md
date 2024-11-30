## 🌐 Language / 語言

- [English](README.md) (Translated by Gemini 1.5 Pro)
- [繁體中文](README.zh-TW.md)

---

## Squid 代理伺服器安裝腳本
本腳本用於在 Ubuntu 系統上快速安裝和配置 Squid 代理伺服器。

## 腳本功能
本腳本會執行以下操作：
1. 安裝必要套件：
   - 更新 apt 套件列表，確保獲取最新的套件資訊。
   - 安裝 squid 套件：Squid 是一個功能齊全的網頁快取代理伺服器，支援 HTTP、HTTPS、FTP 等協議。
   - 安裝 apache2-utils 套件：提供 htpasswd 工具，用於建立和管理認證檔案。
2. 設定認證：
   - 提示使用者輸入 Squid 使用者名稱和密碼
   - 建立密碼檔案 /etc/squid/passwd，並設定檔案權限為 777（允許所有使用者讀取、寫入和執行），方便后续操作
   - 使用 htpasswd 工具將使用者名稱和密碼添加到 /etc/squid/passwd 檔案中
3. 設定 Prot：
   - 提示使用者輸入 Prot
   - 驗證輸入的 Prot 是否為數字，並檢查其是否在有效範圍內（1-65535）。
   - 使用 ss 指令檢查 Prot 是否已被其他程式占用。如果埠號已被占用，則會提示您輸入其他埠號。
4. 備份設定檔：
   - 檢查 /etc/squid/squid.conf 檔案是否存在。如果存在，則將其備份到 /etc/squid/squid.conf.bak。
5. 配置 Squid：
   - 建立新的 /etc/squid/squid.conf 設定檔。
   - 設定檔中包含以下重要配置：
      - acl (Access Control List) 設定：定義允許和拒絕的連線規則，例如允許安全埠（80, 21, 443 等）和 HTTPS 連線。
      - http_access 設定：根據 ACL 規則控制訪問權限，例如拒絕非安全埠的連線。
      - auth_param 設定：設定基本驗證機制，使用 /etc/squid/passwd 檔案進行身份驗證。
      - http_port 設定：設定 Squid 監聽的埠號。
      - via off, forwarded_for delete, request_header_access 等設定：用於隱藏代理伺服器的資訊，提高安全性。
      - refresh_pattern 設定：設定快取刷新規則。
      - cache deny all, access_log none, cache_store_log none, cache_log /dev/null：禁用快取功能，並關閉所有日誌記錄。
6. 重新啟動 Squid 服務：
   - 使用 systemctl restart squid 命令重新啟動 Squid 服務，使新的設定生效。
7. 顯示連線資訊：
   - 使用 curl ifconfig.me 命令獲取伺服器的公網 IP 位址。如果無法獲取公網 IP，則會顯示錯誤訊息。
   - 顯示伺服器的 IP 位址、Prot、使用者名稱和密碼。

---

## 系統需求

- Linux 的系統（已在 Ubuntu 測試）。
- 擁有 root 權限執行腳本。

---

## 使用方式

1. 下載腳本：
   ```bash
   git clone https://github.com/yourusername/squid-proxy-setup.git
   cd squid-proxy-setup
   ```
2. 賦予腳本執行權限：
   ```bash
   chmod +x squid-setup.sh
   ```
3. 執行腳本：
   ```bash
   sudo ./squid-setup.sh
   ```
4. 根據提示輸入以下資料：
   - 代理伺服器的使用者名稱
   - 代理伺服器的密碼
   - 代理伺服器的埠號（預設：8080）
5. 腳本完成後，將顯示以下訊息：
   - 伺服器的 IP 位址
   - Port
   - 使用者名稱及密碼
