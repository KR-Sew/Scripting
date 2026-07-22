sudo bash <<'EOF'
total=0

while read -r vmid; do
    qm status "$vmid" | grep -q "status: running" || continue

    config=$(qm config "$vmid")
    cores=$(awk -F': ' '/^cores:/ {print $2}' <<< "$config")
    sockets=$(awk -F': ' '/^sockets:/ {print $2}' <<< "$config")

    cores=${cores:-1}
    sockets=${sockets:-1}

    total=$((total + cores * sockets))
done < <(qm list | awk 'NR > 1 {print $1}')

echo "Total vCPUs assigned to running VMs: $total"
EOF