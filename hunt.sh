#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# --- 1. User Audit ---
echo -e "\n${YELLOW}[1] Auditing Users${NC}"
echo "Checking for unauthorized UID 0 (root) users..."
# Detect UID 0 other than root
awk -F: '($3 == 0 && $1 != "root") {
    print "'${RED}'[!] WARNING: User " $1 " has UID 0! DELETE THEM: userdel -f " $1 "'${NC}'"
}' /etc/passwd

echo "Listing 'Human' Users (UID >= 1000 with login shells):"
awk -F: '($3 >= 1000 && $7 !~ /(nologin|false)/) {print "    User: " $1 " (UID: " $3 ", Shell: " $7 ")"}' /etc/passwd
echo -e "${BLUE}ACTION:${NC} If you see any user other than 'user' or 'ssh-user', delete them:"
echo "    userdel -f -r <username>"
read -p "Press Enter to continue..."

# --- 2. SUID Binary Audit ---
echo -e "\n${YELLOW}[2] Auditing SUID Binaries${NC}"
echo "Searching for SUID files (files that run as root)..."
find / -type f -perm -4000 2>/dev/null > /tmp/suid_list.txt

# Check for GTFOBins (Dangerous if SUID)
DANGEROUS=("vim" "nano" "cp" "find" "python3" "bash" "sh" "awk" "sed" "nmap" "more" "less")
FOUND_DANGER=0

echo "Checking for DANGEROUS SUID binaries..."
for bin in "${DANGEROUS[@]}"; do
    if grep -q "/$bin$" /tmp/suid_list.txt; then
        FOUND_DANGER=1
        path=$(grep "/$bin$" /tmp/suid_list.txt)
        echo -e "${RED}[!] DANGER: $path has SUID set!${NC}"
        echo "    RECOMMENDATION: chmod u-s $path"
    fi
done

if [ $FOUND_DANGER -eq 0 ]; then
    echo -e "${GREEN}No common GTFOBins found with SUID.${NC}"
fi
echo -e "${BLUE}ACTION:${NC} Review /tmp/suid_list.txt for other weird binaries."
read -p "Press Enter to continue..."

# --- 3. PAM & Auth Audit ---
echo -e "\n${YELLOW}[3] Auditing Authentication (PAM)${NC}"
# Reinstall is a safe baseline, but we check first
echo "Checking /etc/pam.d/common-auth for 'pam_permit.so' (Backdoor)..."
if grep -q "pam_permit.so" /etc/pam.d/common-auth; then
    echo -e "${RED}[!] WARNING: Found 'pam_permit.so' in /etc/pam.d/common-auth!${NC}"
    echo "    This allows login without accurate password."
    echo "    RECOMMENDATION: Edit the file and remove that line, or run:"
    echo "    apt install --reinstall -y libpam-runtime libpam-modules"
else
    echo -e "${GREEN}PAM common-auth looks clean (no pam_permit.so).${NC}"
fi

# --- 4. World Writable Files ---
echo -e "\n${YELLOW}[4] Checking for World-Writable Files in /etc and /bin${NC}"
find /etc /bin /sbin /usr/bin /usr/sbin -type f -perm -0002 2>/dev/null | while read -r file; do
    echo -e "${RED}[!] WARNING: World-writable file found: $file${NC}"
    echo "    RECOMMENDATION: chmod o-w $file"
done

echo -e "\n${BLUE}--- Done ---${NC}"
