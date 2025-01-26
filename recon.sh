#!/bin/bash

# Use the first argument as the domain name
domain=$1

# Check if the domain argument is provided
if [ -z "$domain" ]; then
    echo -e "\033[1;31mError: No domain name provided.\033[0m"
    echo "Usage: ./recon.sh <domain>"
    exit 1
fi

# Define colors
RED="\033[1;31m"
RESET="\033[0m"

# Define directories based on the domain name
base_dir="$domain"
info_path="$base_dir/info"
subdomain_path="$base_dir/subdomains"
screenshot_path="$base_dir/screenshots"

# Debug output: Print paths
echo "Base directory: $base_dir"
echo "Info directory: $info_path"
echo "Subdomain directory: $subdomain_path"
echo "Screenshot directory: $screenshot_path"

# Create directories if they don't exist
for path in "$info_path" "$subdomain_path" "$screenshot_path"; do
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
        echo "Created directory: $path"
    else
        echo "Directory already exists: $path"
    fi
done

echo -e "${RED} [+] Checking who it is ... ${RESET}"
whois "$domain" > "$info_path/whois.txt"

echo -e "${RED} [+] Launching subfinder ... ${RESET}"
subfinder -d "$domain" > "$subdomain_path/found.txt"

echo -e "${RED} [+] Running assetfinder ... ${RESET}"
assetfinder "$domain" | grep "$domain" >> "$subdomain_path/found.txt"

echo -e "${RED} [+] Checking what's alive ... ${RESET}"
cat "$subdomain_path/found.txt" | grep "$domain" | sort -u | httprobe -prefer-https | grep https | sed 's/https\?:\/\///' | tee -a "$subdomain_path/alive.txt"

echo -e "${RED} [+] Taking screenshots ... ${RESET}"
gowitness scan --input-file "$subdomain_path/alive.txt" --output "$screenshot_path/"


