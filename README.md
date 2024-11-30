## 🌐 Language / 語言

- [English](README.md) (Translated by Gemini 1.5 Pro)
- [繁體中文](README.zh-TW.md)

---

## Squid Proxy Server Installation Script

This script is designed for quickly installing and configuring a Squid proxy server on Ubuntu systems.

## Script Functionality

This script performs the following actions:

1. Installs necessary packages:
   - Updates the apt package list to ensure the latest package information is retrieved.
   - Installs the `squid` package: Squid is a fully-featured web cache proxy server supporting HTTP, HTTPS, FTP, and other protocols.
   - Installs the `apache2-utils` package: Provides the `htpasswd` tool for creating and managing authentication files.

2. Configures authentication:
   - Prompts the user for a Squid username and password.
   - Creates the password file `/etc/squid/passwd` and sets file permissions to 777 (allowing all users read, write, and execute access) for easier subsequent operations.
   - Uses the `htpasswd` tool to add the username and password to the `/etc/squid/passwd` file.

3. Configures the Port:
   - Prompts the user for the port number.
   - Validates the entered port number to ensure it is a number and within the valid range (1-65535).
   - Uses the `ss` command to check if the port is already in use. If the port is in use, it prompts the user to enter a different port number.

4. Backs up the configuration file:
   - Checks if the `/etc/squid/squid.conf` file exists. If it exists, it backs it up to `/etc/squid/squid.conf.bak`.

5. Configures Squid:
   - Creates a new `/etc/squid/squid.conf` configuration file.
   - The configuration file includes the following important settings:
      - `acl` (Access Control List) settings: Defines rules for allowed and denied connections, such as allowing secure ports (80, 21, 443, etc.) and HTTPS connections.
      - `http_access` settings: Controls access based on ACL rules, such as denying connections to non-secure ports.
      - `auth_param` settings: Configures basic authentication using the `/etc/squid/passwd` file.
      - `http_port` settings: Sets the port number Squid listens on.
      - `via off`, `forwarded_for delete`, `request_header_access`, and other settings: Used to hide proxy server information and enhance security.
      - `refresh_pattern` settings: Configures cache refresh rules.
      - `cache deny all`, `access_log none`, `cache_store_log none`, `cache_log /dev/null`: Disables caching and turns off all logging.

6. Restarts the Squid service:
   - Uses the `systemctl restart squid` command to restart the Squid service and apply the new configuration.

7. Displays connection information:
   - Uses the `curl ifconfig.me` command to obtain the server's public IP address. If the public IP cannot be obtained, an error message is displayed.
   - Displays the server's IP address, port, username, and password.


---

## System Requirements

- Linux system (tested on Ubuntu).
- Root privileges to execute the script.

---

## Usage

1. Download the script:
   ```bash
   git clone https://github.com/yourusername/squid-proxy-setup.git
   cd squid-proxy-setup
   ```
2. Grant execute permission to the script:
   ```bash
   chmod +x squid-setup.sh
   ```
3. Run the script:
   ```bash
   sudo ./squid-setup.sh
   ```
4. Enter the following information when prompted:
   - Proxy server username
   - Proxy server password
   - Proxy server port (default: 8080)
5. After the script completes, the following information will be displayed:
   - Server IP address
   - Port
   - Username and password
