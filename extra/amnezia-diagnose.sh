#!/usr/bin/env bash
set -u

output=/tmp/amnezia-diag.log
service_log=/var/log/AmneziaVPN/AmneziaVPN-service.log

exec >"$output" 2>&1

echo "Waiting up to 120 seconds for Amnezia GUI interface..."
interface=""
for _ in $(seq 1 120); do
  for candidate in amn0 amn1 amn2; do
    if ip link show "$candidate" >/dev/null 2>&1; then
      interface="$candidate"
      break 2
    fi
  done
  sleep 1
done

if [ -z "$interface" ]; then
  echo "ERROR: GUI interface did not appear"
  exit 1
fi

echo "Detected interface: $interface"
sleep 3

capture() {
  echo
  echo "===== timestamp ====="
  date -Is
  echo
  echo "===== addresses ====="
  ip -brief address
  echo
  echo "===== links ====="
  ip -details link show "$interface"
  echo
  echo "===== policy rules ====="
  ip -4 rule show
  ip -6 rule show
  echo
  echo "===== IPv4 routes (all tables) ====="
  ip -4 route show table all
  echo
  echo "===== IPv6 routes (all tables) ====="
  ip -6 route show table all
  echo
  echo "===== route probes ====="
  ip -4 route get 1.1.1.1
  ip -4 route get 185.196.117.103
  echo
  echo "===== DNS ====="
  resolvectl status
  echo
  echo "===== AmneziaWG status ====="
  awg show "$interface"
  echo
  echo "===== Amnezia iptables rules ====="
  iptables-save | grep -E '(^\*|^COMMIT|amnvpn)' || true
  ip6tables-save | grep -E '(^\*|^COMMIT|amnvpn)' || true
  echo
  echo "===== connectivity ====="
  timeout 8 curl -k -4 -sS -o /dev/null -w 'default HTTP: %{http_code}, remote=%{remote_ip}\n' https://1.1.1.1 || true
  timeout 8 curl -k -4 --interface eno1 -sS -o /dev/null -w 'eno1 HTTP: %{http_code}, remote=%{remote_ip}\n' https://1.1.1.1 || true
  echo
  echo "===== recent service decisions ====="
  tail -n 500 "$service_log" | grep -E 'ERROR|Invalid destination|Adding (exclusion )?route|Connection status|handshake|Handshake|DnsUtils|cgroup|amnvpnrt|RTNETLINK|Operation not permitted' || true
}

capture
sleep 15
capture

echo
echo "Diagnostic capture complete. Disconnect the GUI and inspect $output"
