#!/bin/bash
# NCAE Threat Hunting Checklist
# Usage: sudo ./hunt.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
    echo "STEP: $2"
}

prompt() {
    echo -e "${YELLOW}ACTION:${NC} $1"
    read -p "Press Enter to see findings (or Ctrl+C to stop)..."
    eval "$2"
    echo -e "\n${GREEN}RECOMMENDATION:${NC} $3"
    read -p "    Done? Press Enter for next check..."
}

echo -e "${BLUE}=== NCAE Interactive Threat Hunt ===${NC}"
echo "This script will show you system info. YOU must decide if it is bad."

# --- 1. Shell Hygiene ---
header "1. Shell Hygiene" "Checking for malicious aliases"
prompt "Look for strange aliases (e.g., ls='rm -rf')." \
    "alias" \
    "Run 'unalias -a' to clear all aliases."

header "1. Shell Hygiene" "Checking .bashrc attributes"
prompt "Look for 'i' (immutable) flag on .bashrc." \
    "lsattr /home/*/.bashrc /root/.bashrc 2>/dev/null" \
    "If immutable, run 'chattr -i <file>' then check contents."

# --- 2. Identity & Access ---
header "2. Identity & Access" "Checking Sudoers"
prompt "Who is in the 'sudo' group? (Should only be 'user')." \
    "grep sudo /etc/group" \
    "Run 'gpasswd -d <username> sudo' to remove unauthorized admins."

header "2. Identity & Access" "Checking User Shells"
prompt "Look for weird shells (e.g., /bin/esrever, /bin/sh for normal users)." \
    "awk -F: '(\$3 >= 1000) {print \$1 \" -> \" \$7}' /etc/passwd" \
    "Run 'chsh -s /bin/bash <user>' to fix."

header "2. Identity & Access" "Checking UID 0 (God Mode)"
prompt "Are there any root users besides 'root'?" \
    "awk -F: '(\$3 == 0) {print \$1 \" (UID \" \$3 \")\"}' /etc/passwd" \
    "Run 'userdel -f <user>' to delete fake roots immediately."

# --- 3. Network & Persistence ---
header "3. Network & Persistence" "Checking Listeners"
prompt "Look for weird ports (4444, 1337, 666, 23 (telnet))." \
    "ss -tulpn" \
    "Identify PID, then run 'systemctl stop <service>' or 'kill -9 <pid>'."

header "3. Network & Persistence" "Checking SUID Binaries"
prompt "Look for standard tools (vim, find, cp, python) in this list." \
    "find / -type f -perm -4000 2>/dev/null | grep -E '/bin/|/sbin/'" \
    "Run 'chmod u-s <file>' to remove the danger."

header "3. Network & Persistence" "Checking Systemd Services"
prompt "Look for recently modified service files." \
    "find /etc/systemd/system -type f -mtime -2 -exec ls -l {} \;" \
    "Inspect file with 'cat', if bad: 'rm <file>' and 'systemctl daemon-reload'."

echo -e "\n${BLUE}=== Hunt Complete ===${NC}"
echo "Good hunting!"
