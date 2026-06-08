#!/usr/bin/env bash
set -euo pipefail

IFACE="${GTM_IFACE:-wlan0}"
ROUTER_IP="${GTM_ROUTER:-192.168.1.1}"
PCAP_DIR="${GTM_PCAP_DIR:-$HOME/captures}"

GOOGLE_PATTERN='google|gstatic|googleapis|googlevideo|ggpht|doubleclick|googlesyndication|firebase|googleusercontent|googleadservices|googletagmanager|googletagservices|google-analytics|googleads|blogspot|blogger|withgoogle|gmail|youtube|ytimg|googlezip|chromecast|nest|waze'

declare -A SERVICE_TAGS=(
    ["google"]="GOOGLE"
    ["gstatic"]="GOOGLE"
    ["googleapis"]="GOOGLE"
    ["googlevideo"]="GOOGLE"
    ["youtube"]="GOOGLE"
    ["ytimg"]="GOOGLE"
    ["gmail"]="GOOGLE"
    ["doubleclick"]="GOOGLE"
    ["firebase"]="GOOGLE"
    ["blogspot"]="GOOGLE"
    ["facebook"]="META"
    ["fbcdn"]="META"
    ["instagram"]="META"
    ["whatsapp"]="META"
    ["microsoft"]="MICROSOFT"
    ["live.com"]="MICROSOFT"
    ["azure"]="MICROSOFT"
    ["windows"]="MICROSOFT"
    ["apple"]="APPLE"
    ["icloud"]="APPLE"
    ["amazon"]="AMAZON"
    ["aws"]="AMAZON"
    ["cloudfront"]="AMAZON"
    ["cloudflare"]="CLOUDFLARE"
    ["tiktok"]="TIKTOK"
    ["netflix"]="NETFLIX"
    ["twitter"]="TWITTER"
    ["x.com"]="TWITTER"
)

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
  capture [seconds]     Full capture + save pcap + live stats (default: 120s)
  live [seconds]        Real-time stats only, no save (default: 120s)
  analyze <pcap>        Analyze a pcap file
  report <pcap>         Generate summary report from pcap
  dns [seconds]         DNS-only capture, log all queries (default: 60s)
  router-check          Check if router supports remote capture

Environment:
  GTM_IFACE             Network interface (default: wlan0)
  GTM_ROUTER            Router IP (default: 192.168.1.1)
  GTM_PCAP_DIR          Directory for pcap files (default: ~/captures)

Examples:
  $(basename "$0") capture 300        # Capture for 5 minutes
  $(basename "$0") live 60            # Watch live for 1 minute
  $(basename "$0") analyze cap.pcapng # Analyze saved capture
  $(basename "$0") dns 120            # Log DNS queries for 2 minutes
  $(basename "$0") router-check       # Check router SSH access
EOF
}

check_deps() {
    local missing=()
    command -v tshark &>/dev/null || missing+=(tshark)
    command -v awk &>/dev/null || missing+=(awk)
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing dependencies: ${missing[*]}" >&2
        exit 1
    fi
}

ensure_pcap_dir() {
    mkdir -p "$PCAP_DIR"
}

get_service_tag() {
    local domain="$1"
    domain=$(echo "$domain" | tr '[:upper:]' '[:lower:]')
    for pattern in "${!SERVICE_TAGS[@]}"; do
        if [[ "$domain" == *"$pattern"* ]]; then
            echo "[${SERVICE_TAGS[$pattern]}]"
            return
        fi
    done
    echo ""
}

is_google() {
    local domain="$1"
    echo "$domain" | grep -qiE "$GOOGLE_PATTERN"
}

is_valid_domain() {
    local domain="$1"
    [[ -n "$domain" ]] && echo "$domain" | grep -qE '[A-Za-z]' && echo "$domain" | grep -q '\.'
}

bpf_filter() {
    echo "port 53 or port 443 or port 80 or udp port 443 or port 8080 or port 8443"
}

run_capture() {
    local duration="${1:-120}"
    local save_pcap="${2:-true}"
    local pcap_file=""
    local tmp_data
    local tmp_dns

    ensure_pcap_dir
    tmp_data=$(mktemp /tmp/nm-data-XXXXXX.tsv)
    tmp_dns=$(mktemp /tmp/nm-dns-XXXXXX.tsv)

    if [[ "$save_pcap" == "true" ]]; then
        pcap_file="$PCAP_DIR/net-monitor-$(date +%Y%m%d-%H%M%S).pcapng"
        echo "Saving capture to: $pcap_file"
    fi

    echo "=== Network Traffic Monitor ==="
    echo "Interface: $IFACE | Duration: ${duration}s | Started: $(date +%H:%M:%S)"
    echo ""

    local general_args=(-i "$IFACE" -a "duration:$duration" -f "$(bpf_filter)")
    if [[ "$save_pcap" == "true" ]]; then
        general_args+=(-w "$pcap_file")
    fi
    general_args+=(-T fields -e frame.time_epoch -e ip.src -e ip.dst -e _ws.col.Protocol -e frame.len -e tls.handshake.extensions_server_name -E separator=$'\t' -E header=n)

    sudo tshark "${general_args[@]}" 2>/dev/null | while IFS=$'\t' read -r epoch src dst proto size sni; do
        local domain="${sni:-}"
        [[ -z "$domain" ]] && domain=""
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$epoch" "$src" "$dst" "$proto" "$domain" "$size" >> "$tmp_data"
    done &
    local tshark_pid=$!

    sudo tshark -i "$IFACE" -a "duration:$duration" -f "port 53" -Y dns \
        -T fields -e frame.time_epoch -e dns.qry.name -e dns.a -e ip.src \
        -E separator=$'\t' -E header=n 2>/dev/null | while IFS=$'\t' read -r epoch dns_name dns_answer src; do
        if [[ -n "$dns_name" ]]; then
            printf '%s\t%s\t%s\t%s\n' "$epoch" "$dns_name" "${dns_answer:-}" "$src" >> "$tmp_dns"
        fi
    done &
    local dns_pid=$!

    trap "kill $tshark_pid $dns_pid 2>/dev/null; print_full_summary '$tmp_data' '$tmp_dns' '$duration'; rm -f '$tmp_data' '$tmp_dns'" EXIT INT TERM

    local elapsed=0
    while [[ $elapsed -lt $duration ]] && kill -0 "$tshark_pid" 2>/dev/null; do
        sleep 5
        elapsed=$((elapsed + 5))
        local pcount=0
        local dcount=0
        local unique_ips=0
        [[ -f "$tmp_data" ]] && pcount=$(wc -l < "$tmp_data")
        [[ -f "$tmp_dns" ]] && dcount=$(wc -l < "$tmp_dns")
        [[ -f "$tmp_data" ]] && unique_ips=$(awk -F'\t' '{print $3}' "$tmp_data" | sort -u | wc -l)
        printf '\r[%3ds] Total: %d pkts | Unique IPs: %d | DNS queries: %d' "$elapsed" "$pcount" "$unique_ips" "$dcount"
    done

    wait "$tshark_pid" 2>/dev/null || true
    wait "$dns_pid" 2>/dev/null || true
    echo ""
    print_full_summary "$tmp_data" "$tmp_dns" "$duration"
    rm -f "$tmp_data" "$tmp_dns"
    trap - EXIT INT TERM

    if [[ "$save_pcap" == "true" ]] && [[ -f "$pcap_file" ]]; then
        echo ""
        echo "Pcap saved: $pcap_file"
        echo "Analyze with: $(basename "$0") analyze $pcap_file"
    fi
}

print_full_summary() {
    local data_file="$1"
    local dns_file="$2"
    local duration="$3"

    local pcount=0
    local dcount=0
    [[ -f "$data_file" ]] && pcount=$(wc -l < "$data_file")
    [[ -f "$dns_file" ]] && dcount=$(wc -l < "$dns_file")

    echo ""
    echo "============================================"
    echo "  Network Traffic Summary"
    echo "============================================"
    echo "Duration: ${duration}s | Total packets: $pcount | DNS queries: $dcount"
    echo ""

    if [[ "$pcount" -eq 0 ]]; then
        echo "No traffic detected."
        return
    fi

    echo "--- Top Domains (by connections) ---"
    if [[ -f "$dns_file" ]] && [[ $dcount -gt 0 ]]; then
        awk -F'\t' '{print $2}' "$dns_file" | awk '/[A-Za-z]/ && /\./' | sort | uniq -c | sort -rn | head -20 | while read -r count domain; do
            local tag
            tag=$(get_service_tag "$domain")
            local google_marker=""
            if is_google "$domain"; then
                google_marker=" [GOOGLE]"
            fi
            printf '  %-40s %6d conn  %s%s\n' "$domain" "$count" "$tag" "$google_marker"
        done
    else
        awk -F'\t' '$5 != "" {print $5}' "$data_file" | sort | uniq -c | sort -rn | head -20 | while read -r count domain; do
            local tag
            tag=$(get_service_tag "$domain")
            local google_marker=""
            if is_google "$domain"; then
                google_marker=" [GOOGLE]"
            fi
            printf '  %-40s %6d conn  %s%s\n' "$domain" "$count" "$tag" "$google_marker"
        done
    fi

    echo ""
    echo "--- Top Destination IPs (by packets) ---"
    awk -F'\t' '{print $3}' "$data_file" | grep -v '^$' | sort | uniq -c | sort -rn | head -15 | while read -r count ip; do
        local bytes
        bytes=$(awk -F'\t' -v ip="$ip" '$3==ip {sum+=$6} END {printf "%.1f KB", sum/1024}' "$data_file")
        printf '  %-20s %6d pkts   %s\n' "$ip" "$count" "$bytes"
    done

    echo ""
    echo "--- Bandwidth Hogs (top by bytes) ---"
    awk -F'\t' '{bytes[$3]+=$6} END {for (ip in bytes) printf "%d\t%s\n", bytes[ip], ip}' "$data_file" | sort -rn | head -10 | while IFS=$'\t' read -r bytes ip; do
        printf '  %-20s %.2f MB\n' "$ip" "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}")"
    done

    echo ""
    echo "--- Protocol Breakdown ---"
    awk -F'\t' '{print $4}' "$data_file" | sort | uniq -c | sort -rn | while read -r count proto; do
        printf '  %-15s %d\n' "$proto" "$count"
    done

    echo ""
    echo "--- Suspicious Patterns ---"
    local suspicious_found=false

    if [[ -f "$dns_file" ]] && [[ $dcount -gt 0 ]]; then
        awk -F'\t' '{print $2}' "$dns_file" | awk '/[A-Za-z]/ && /\./' | sort | uniq -c | sort -rn | head -20 | while read -r count domain; do
            if [[ $count -gt 50 ]] && [[ $duration -gt 0 ]]; then
                local rate
                rate=$(awk "BEGIN {printf \"%.1f\", $count / ($duration / 60)}")
                if (( $(echo "$rate > 30" | bc -l 2>/dev/null || echo 0) )); then
                    local tag
                    tag=$(get_service_tag "$domain")
                    printf '  ! %-35s %d conn in %ds (%.1f/min) %s\n' "$domain" "$count" "$duration" "$rate" "$tag"
                    suspicious_found=true
                fi
            fi
        done
    else
        awk -F'\t' '$5 != "" {print $5}' "$data_file" | sort | uniq -c | sort -rn | head -20 | while read -r count domain; do
            if [[ $count -gt 50 ]] && [[ $duration -gt 0 ]]; then
                local rate
                rate=$(awk "BEGIN {printf \"%.1f\", $count / ($duration / 60)}")
                if (( $(echo "$rate > 30" | bc -l 2>/dev/null || echo 0) )); then
                    local tag
                    tag=$(get_service_tag "$domain")
                    printf '  ! %-35s %d conn in %ds (%.1f/min) %s\n' "$domain" "$count" "$duration" "$rate" "$tag"
                    suspicious_found=true
                fi
            fi
        done
    fi

    awk -F'\t' '{print $3}' "$data_file" | sort | uniq -c | sort -rn | head -10 | while read -r count ip; do
        local timestamps
        timestamps=$(awk -F'\t' -v ip="$ip" '$3==ip {print $1}' "$data_file" | sort -n)
        local ts_count
        ts_count=$(echo "$timestamps" | wc -l)
        if [[ $ts_count -gt 5 ]]; then
            local intervals
            intervals=$(echo "$timestamps" | awk 'NR>1 {print $1-prev} {prev=$1}' | sort -n)
            local avg_interval
            avg_interval=$(echo "$intervals" | awk '{sum+=$1; count++} END {if (count>0) printf "%.1f", sum/count; else print 0}')
            if [[ "$avg_interval" != "0" ]] && (( $(echo "$avg_interval < 10" | bc -l 2>/dev/null || echo 0) )); then
                printf '  ! %-20s beaconing ~every %.0fs (%d hits)\n' "$ip" "$avg_interval" "$ts_count"
                suspicious_found=true
            fi
        fi
    done

    awk -F'\t' '$4 !~ /^(TCP|UDP|TLS|DNS|HTTP|HTTPS|QUIC)$/ && $4 != "" {print $4}' "$data_file" | sort | uniq -c | sort -rn | head -5 | while read -r count proto; do
        if [[ $count -gt 0 ]]; then
            printf '  ! Unusual protocol: %s (%d packets)\n' "$proto" "$count"
            suspicious_found=true
        fi
    done

    if [[ "$suspicious_found" == "false" ]]; then
        echo "  No suspicious patterns detected."
    fi

    echo ""
    echo "--- Google Traffic Summary ---"
    local google_count=0
    local google_bytes=0
    if [[ -f "$data_file" ]]; then
        while IFS=$'\t' read -r epoch src dst proto domain size; do
            if [[ -n "$domain" ]] && is_google "$domain"; then
                google_count=$((google_count + 1))
                google_bytes=$((google_bytes + size))
            fi
        done < "$data_file"
    fi
    if [[ -f "$dns_file" ]] && [[ $dcount -gt 0 ]]; then
        while IFS=$'\t' read -r epoch domain answer src; do
            if is_valid_domain "$domain" && is_google "$domain"; then
                google_count=$((google_count + 1))
            fi
        done < "$dns_file"
    fi
    printf '  Google packets: %d | Google bytes: %.2f MB\n' "$google_count" "$(awk "BEGIN {printf \"%.2f\", $google_bytes/1048576}")"

    if [[ -f "$dns_file" ]] && [[ $dcount -gt 0 ]]; then
        echo ""
        echo "--- Top DNS Queries ---"
        awk -F'\t' '{print $2}' "$dns_file" | awk '/[A-Za-z]/ && /\./' | sort | uniq -c | sort -rn | head -15 | while read -r count domain; do
            local tag
            tag=$(get_service_tag "$domain")
            printf '  %-40s %6d queries  %s\n' "$domain" "$count" "$tag"
        done
    fi
}

run_dns_capture() {
    local duration="${1:-60}"
    local tmp_dns

    ensure_pcap_dir
    tmp_dns=$(mktemp /tmp/nm-dns-only-XXXXXX.tsv)

    echo "=== DNS Query Monitor ==="
    echo "Interface: $IFACE | Duration: ${duration}s | Started: $(date +%H:%M:%S)"
    echo ""

    sudo tshark -i "$IFACE" -a "duration:$duration" -f "port 53" \
        -T fields -e frame.time_epoch -e dns.qry.name -e dns.a -e ip.src \
        -E separator=$'\t' -E header=n 2>/dev/null | while IFS=$'\t' read -r epoch dns_name dns_answer src; do
        if [[ -n "$dns_name" ]]; then
            local tag
            tag=$(get_service_tag "$dns_name")
            local ts
            ts=$(date -d "@$epoch" +%H:%M:%S 2>/dev/null || date -r "$epoch" +%H:%M:%S 2>/dev/null || echo "$epoch")
            printf '[%s] %-40s -> %-15s %s\n' "$ts" "$dns_name" "${dns_answer:-?}" "$tag"
            printf '%s\t%s\t%s\t%s\n' "$epoch" "$dns_name" "${dns_answer:-}" "$src" >> "$tmp_dns"
        fi
    done &

    local tshark_pid=$!

    trap "kill $tshark_pid 2>/dev/null; echo ''; print_dns_summary '$tmp_dns'; rm -f '$tmp_dns'" EXIT INT TERM

    wait "$tshark_pid" 2>/dev/null || true
    echo ""
    print_dns_summary "$tmp_dns"
    rm -f "$tmp_dns"
    trap - EXIT INT TERM
}

print_dns_summary() {
    local dns_file="$1"

    if [[ ! -f "$dns_file" ]] || [[ ! -s "$dns_file" ]]; then
        echo "No DNS queries captured."
        return
    fi

    local dcount
    dcount=$(wc -l < "$dns_file")

    echo ""
    echo "============================================"
    echo "  DNS Query Summary"
    echo "============================================"
    echo "Total queries: $dcount"
    echo ""

    echo "--- Top Queried Domains ---"
    awk -F'\t' '{print $2}' "$dns_file" | sort | uniq -c | sort -rn | head -20 | while read -r count domain; do
        local tag
        tag=$(get_service_tag "$domain")
        printf '  %-40s %6d queries  %s\n' "$domain" "$count" "$tag"
    done

    echo ""
    echo "--- Unique Domains Queried ---"
    local unique
    unique=$(awk -F'\t' '{print $2}' "$dns_file" | sort -u | wc -l)
    echo "  $unique unique domains"

    echo ""
    echo "--- Google DNS Queries ---"
    local google_count=0
    while IFS=$'\t' read -r epoch domain answer src; do
        if is_google "$domain"; then
            google_count=$((google_count + 1))
        fi
    done < "$dns_file"
    echo "  $google_count Google-related queries"
}

analyze_pcap() {
    local pcap_file="$1"

    if [[ ! -f "$pcap_file" ]]; then
        echo "File not found: $pcap_file" >&2
        exit 1
    fi

    echo "=== Analyzing: $pcap_file ==="
    echo ""

    local tmp_data
    local tmp_dns
    tmp_data=$(mktemp /tmp/nm-analyze-data-XXXXXX.tsv)
    tmp_dns=$(mktemp /tmp/nm-analyze-dns-XXXXXX.tsv)

    tshark -r "$pcap_file" -T fields \
        -e frame.time_epoch -e ip.src -e ip.dst -e _ws.col.Protocol \
        -e dns.qry.name -e dns.a -e tls.handshake.extensions_server_name -e frame.len \
        -E separator=$'\t' -E header=n 2>/dev/null | while IFS=$'\t' read -r epoch src dst proto dns_name dns_answer sni size; do
        local domain="${sni:-$dns_name}"
        [[ -z "$domain" ]] && domain=""

        if [[ -n "$dns_name" ]]; then
            printf '%s\t%s\t%s\t%s\n' "$epoch" "$dns_name" "${dns_answer:-}" "$src" >> "$tmp_dns"
        fi

        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$epoch" "$src" "$dst" "$proto" "$domain" "$size" >> "$tmp_data"
    done

    local total_packets
    total_packets=$(tshark -r "$pcap_file" -T fields -e frame.number 2>/dev/null | wc -l)

    print_full_summary "$tmp_data" "$tmp_dns" "0"

    echo ""
    echo "--- Connection Timeline (per minute) ---"
    if [[ -f "$tmp_data" ]] && [[ -s "$tmp_data" ]]; then
        awk -F'\t' '{
            t = int($1 / 60) * 60
            count[t]++
        } END {
            for (t in count) {
                cmd = "date -d @" t " +%H:%M 2>/dev/null || date -r " t " +%H:%M 2>/dev/null"
                cmd | getline ts
                close(cmd)
                printf "  %s  %d connections\n", ts, count[t]
            }
        }' "$tmp_data" | sort
    fi

    echo ""
    echo "--- Services Detected ---"
    if [[ -f "$tmp_data" ]] && [[ -s "$tmp_data" ]]; then
        awk -F'\t' '$5 != "" {print $5}' "$tmp_data" | sort -u | while read -r domain; do
            local tag
            tag=$(get_service_tag "$domain")
            if [[ -n "$tag" ]]; then
                printf '  %-45s %s\n' "$domain" "$tag"
            fi
        done
    fi

    rm -f "$tmp_data" "$tmp_dns"
}

report_pcap() {
    local pcap_file="$1"

    if [[ ! -f "$pcap_file" ]]; then
        echo "File not found: $pcap_file" >&2
        exit 1
    fi

    local report_file="${pcap_file%.pcapng}-report.txt"

    echo "Generating report: $report_file"
    analyze_pcap "$pcap_file" > "$report_file" 2>&1
    echo "Report saved: $report_file"
}

router_check() {
    echo "=== Router Capture Check ==="
    echo "Router: $ROUTER_IP"
    echo ""

    echo "Checking SSH (port 22)..."
    if timeout 3 bash -c "echo >/dev/tcp/$ROUTER_IP/22" 2>/dev/null; then
        echo "  SSH is OPEN on $ROUTER_IP"
        echo ""
        echo "Try connecting:"
        echo "  ssh root@$ROUTER_IP"
        echo "  ssh admin@$ROUTER_IP"
        echo ""
        echo "If SSH works, stream capture to local tshark:"
        echo "  ssh root@$ROUTER_IP 'tcpdump -i any -w - port 53 or port 443 or port 80' | tshark -i - -f ''"
        echo ""
        echo "Or save on router and download:"
        echo "  ssh root@$ROUTER_IP 'tcpdump -i any -w /tmp/cap.pcap -c 10000'"
        echo "  scp root@$ROUTER_IP:/tmp/cap.pcap ."
    else
        echo "  SSH is CLOSED"
    fi

    echo ""
    echo "Checking Telnet (port 23)..."
    if timeout 3 bash -c "echo >/dev/tcp/$ROUTER_IP/23" 2>/dev/null; then
        echo "  Telnet is OPEN on $ROUTER_IP"
        echo "  Try: telnet $ROUTER_IP"
    else
        echo "  Telnet is CLOSED"
    fi

    echo ""
    echo "Checking HTTP management (port 80)..."
    if timeout 3 bash -c "echo >/dev/tcp/$ROUTER_IP/80" 2>/dev/null; then
        echo "  HTTP is OPEN - check router web UI for traffic stats"
        echo "  URL: http://$ROUTER_IP"
    else
        echo "  HTTP is CLOSED"
    fi

    echo ""
    echo "--- TP-Link Home Router Options ---"
    echo "Most TP-Link home routers do NOT support packet capture."
    echo ""
    echo "Alternatives:"
    echo "  1. Check router web UI: http://$ROUTER_IP"
    echo "     Look for: System Tools > Traffic Monitor / Statistics"
    echo ""
    echo "  2. Flash OpenWrt for full tcpdump support:"
    echo "     https://openwrt.org/toh/tp-link/start"
    echo ""
    echo "  3. Use this script's local capture ($IFACE) to see"
    echo "     all traffic from your machine."
    echo ""
    echo "  4. Set up a mirror port with a managed switch between"
    echo "     router and your network for full visibility."
}

main() {
    check_deps

    local cmd="${1:-}"
    shift || true

    case "$cmd" in
        capture)
            run_capture "${1:-120}" true
            ;;
        live)
            run_capture "${1:-120}" false
            ;;
        analyze)
            if [[ -z "${1:-}" ]]; then
                echo "Usage: $(basename "$0") analyze <pcap-file>" >&2
                exit 1
            fi
            analyze_pcap "$1"
            ;;
        report)
            if [[ -z "${1:-}" ]]; then
                echo "Usage: $(basename "$0") report <pcap-file>" >&2
                exit 1
            fi
            report_pcap "$1"
            ;;
        dns)
            run_dns_capture "${1:-60}"
            ;;
        router-check)
            router_check
            ;;
        help|--help|-h|"")
            usage
            ;;
        *)
            echo "Unknown command: $cmd" >&2
            usage
            exit 1
            ;;
    esac
}

main "$@"
