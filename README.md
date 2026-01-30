# NCAE Tryouts Script

This repository contains the setup script and configuration files for the NCAE competition tryouts.

## Usage

1.  Clone this repository to your Debian machine.
2.  Make the script executable:
    ```bash
    chmod +x setup.sh
    ```
3.  Run the script with root privileges:
    ```bash
    sudo ./setup.sh
    ```

## Services

The script sets up the following services:
-   **HTTP**: Nginx (Port 80)
-   **FTP**: vsftpd (Port 21)
-   **DNS**: Bind9 (Port 53)
-   **SQL**: MariaDB (Port 3306)
-   **SSH**: OpenSSH (Port 22)

## Configuration

Configuration files are located in the `configs/` directory. The script will copy them to the appropriate locations during setup.
