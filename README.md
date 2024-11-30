## 🌐 Language / 語言

- [English](README.md)
- [繁體中文](README.zh-TW.md)

---

## What This Script Does
This script automates the following actions on your system:
1. **Installs Required Packages**:
   - Updates the package list using `apt update`.
   - Installs `squid` (proxy server software) and `apache2-utils` (for managing user authentication).
2. **Creates a Password File**:
   - Generates an authentication file at `/etc/squid/passwd`.
   - Sets appropriate permissions (`chmod 777`) for managing the file.
   - Uses `htpasswd` to create a username and password for proxy access.
3. **Backs Up the Existing Squid Configuration**:
   - Saves the original Squid configuration file as `/etc/squid/squid.conf.bak`.
4. **Creates a New Squid Configuration**:
   - Configures the proxy server to:
     - Use basic authentication for access.
     - Allow traffic only on safe ports (e.g., HTTP, HTTPS).
     - Disable caching and logging for privacy.
     - Use the user-defined port for proxy connections.
5. **Restarts the Squid Service**:
   - Applies the new configuration by restarting the Squid service.
6. **Displays Configuration Details**:
   - Outputs the server's public IP address, proxy port, username, and password for user reference.

---

## Prerequisites
- A Linux-based system (tested on Ubuntu/Debian).
- Root privileges to run the script.

---

## Usage

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/squid-proxy-setup.git
   cd squid-proxy-setup
   ```
2. Make the script executable:
  ```bash
  chmod +x squid-setup.sh
  ```
3. Run the script:
   ```bash
   sudo ./squid-setup.sh
   ```
4. Follow the on-screen prompts to input:
  - Proxy server username
  - Proxy server password
  - Proxy server port (default: 8080)
5. Once the script finishes, it will display the following details:
  - Your server's public IP address
  - The proxy port
  - The username and password you set
