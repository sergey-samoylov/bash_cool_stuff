#!/usr/env/bin bash

# Simple network scanner with tree-like visualization

# Get your network interface and IP range
interface=$(ip route | awk '/default/ {print $5}')
ip_range=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n1)

echo "Scanning network on interface $interface (range: $ip_range)"
echo "----------------------------------------"

# Use nmap for scanning (install if needed: sudo apt install nmap)
nmap -sn $ip_range | awk '/Nmap scan/ {print $5, $6}' | while read -r ip host; do
    echo "├── $ip ($host)"
    
    # Scan common ports
    ports=$(nmap -Pn -p- --min-rate=1000 -T4 $ip | awk '/^[0-9]+\/tcp/ {print $1}')
    if [ -n "$ports" ]; then
        echo "│   ├── Open ports:"
        for port in $ports; do
            service=$(grep "^$port/" /etc/services | awk '{print $1}')
            echo "│   │   ├── $port ($service)"
        done
    else
        echo "│   └── No open ports detected"
    fi
    
done
