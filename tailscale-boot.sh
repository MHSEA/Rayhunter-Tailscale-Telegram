#!/bin/sh
# Tailscale auto-start script with Telegram alert

LOGFILE="/media/sdcard/scripts/tailscale-boot.log"
[ -w /media/sdcard/scripts ] || LOGFILE="/tmp/tailscale-boot.log"
exec >> "$LOGFILE" 2>&1

# Fix DNS temporarily (overwrite in case boot DHCP is bad)
echo "nameserver 1.1.1.1" > /etc/resolv.conf

# Telegram config
BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
CHAT_ID="YOUR_CHAT_ID_HERE"

send_telegram() {
  RAW_TEXT="$1"
  TEXT=$(echo "$RAW_TEXT" | sed 's/$/%0A/' | tr -d '\n')
  wget -qO- \
    --post-data="chat_id=${CHAT_ID}&text=${TEXT}&parse_mode=HTML&text=${TEXT}" \
    "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" >/dev/null
}

wait_for_internet() {
  echo "Waiting for internet..."
  for i in $(seq 1 30); do
    ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 && return 0
    echo "Attempt $i: No internet yet"
    sleep 2
  done
  echo "ERROR: No internet after 60s"
  return 1
}

echo "=== Tailscale boot starting at $(date) ==="

wait_for_internet || {
  send_telegram "❌ Rayhunter boot aborted
Internet not available after 60s"
  exit 1
}

send_telegram "📡 Rayhunter booting..."

# Validate Tailscaled binary
if [ ! -x /media/sdcard/Tail/tailscaled ]; then
  echo "ERROR: tailscaled not found"
  send_telegram "❌ tailscaled not found or not executable!"
  exit 1
fi

# Kill any old instance
killall tailscaled 2>/dev/null

# Start tailscaled
/media/sdcard/Tail/tailscaled --state=/media/sdcard/Tail/tailscaled.state &
TS_PID=$!
echo "tailscaled started with PID $TS_PID"
sleep 5

# Bring up Tailscale
MAX_RETRIES=5
COUNT=0
while [ $COUNT -lt $MAX_RETRIES ]; do
  echo "Attempt $(($COUNT + 1)) to bring up Tailscale..."
  /media/sdcard/Tail/tailscale up \
    --authkey tskey-auth-kCGQE8uzf211CNTRL-Mkbztyq3oWCqzqFa1X8DWCCY5dr8CGVF \
    --advertise-routes=192.168.0.0/24 \
    --accept-routes \
    --accept-dns

  if [ $? -eq 0 ]; then
    echo "Tailscale up succeeded"
    break
  else
    echo "Tailscale up failed, retrying in 10s..."
    sleep 10
  fi
  COUNT=$(($COUNT + 1))
done

# Enable IP forwarding and NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "IP forwarding enabled"
iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
echo "NAT rule applied"

# Capture device info
HOSTNAME=$(hostname)
if command -v curl >/dev/null 2>&1; then
  WAN_IP=$(curl -s --max-time 5 http://ifconfig.me/ip || echo "unknown")
else
  WAN_IP=$(wget -qO - http://ifconfig.me/ip || echo "unknown")
fi

# Extract local Tailscale IP only (first IP line)
LOCAL_IP="192.168.0.1"
TS_IP=$(/media/sdcard/Tail/tailscale ip | head -n 1)
UPTIME=$(uptime | sed 's/.*up \([^,]*\),.*/\1/')

# Final Telegram message
STATUS_MESSAGE="✅ Rayhunter live!

<b>Time:</b> $(date)
<b>Device:</b> ${HOSTNAME}
<b>WAN IP:</b> ${WAN_IP}
<b>Local IP:</b> <a href=\"http://192.168.0.1:8080\">192.168.0.1:8080</a>
<b>Tailscale IP:</b> <a href=\"http://${TS_IP}:8080\">${TS_IP}:8080</a>
<b>Uptime:</b> ${UPTIME}"

send_telegram "$STATUS_MESSAGE"

echo "=== Tailscale boot finished at $(date) ==="te) ==="shed at $(date) ==="
gram "$STATUS_MESSAGE"

echo "=== Tailscale boot finished at $(date) ==="
==="
t finished at $(date) ==="b>Status:</b><pre>$(tailscale status)</pre>"

echo "=== Tailscale boot finished at $(date) ==="
