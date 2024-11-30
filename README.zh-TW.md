## 🌐 Language / 語言

- [English](README.md)
- [繁體中文](README.zh-TW.md)

---

##  此腳本對系統的操作

執行腳本後，會對系統執行以下動作：

1. **安裝所需套件**：
   - 使用 `apt update` 更新軟體清單。
   - 安裝 `squid`（代理伺服器軟體）和 `apache2-utils`（用於管理用戶驗證）。
2. **建立密碼檔案**：
   - 在 `/etc/squid/passwd` 位置生成驗證檔案。
   - 設定適當的權限（`chmod 777`）以管理檔案。
   - 使用 `htpasswd` 建立代理伺服器的使用者名稱和密碼。
3. **備份現有的 Squid 配置**：
   - 將原有的 Squid 配置檔案保存為 `/etc/squid/squid.conf.bak`。
4. **生成新的 Squid 配置**：
   - 設置代理伺服器以：
     - 使用基本身份驗證。
     - 僅允許安全埠（如 HTTP、HTTPS）的流量。
     - 停用緩存及日誌記錄以保護隱私。
     - 使用用戶自定義的埠號連接代理伺服器。
5. **重新啟動 Squid 服務**：
   - 透過重啟 Squid 服務應用新配置。
6. **顯示配置信息**：
   - 輸出伺服器的公共 IP 位址、代理埠號、使用者名稱及密碼供使用者參考。

---

## 系統需求

- 基於 Linux 的系統（已在 Ubuntu/Debian 測試）。
- 擁有 root 權限以執行腳本。

---

## 使用方式

1. 將此專案克隆至本機：
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
5. 腳本完成後，將顯示以下信息：
   - 伺服器的公共 IP 位址
   - 代理埠號
   - 使用者名稱及密碼
