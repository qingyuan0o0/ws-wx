#! /bin/bash
if [[ -z "${CORPID}" ]]; then
  CORPID="abc"
fi

if [[ -z "${CORPSECRET}" ]]; then
  CORPSECRET="abc"
fi

if [[ -z "${AGENTID}" ]]; then
  AGENTID="abc"
fi

if [[ -z "${sToken}" ]]; then
  sToken="abc"
fi

if [[ -z "${sEncodingAESKey}" ]]; then
  sEncodingAESKey="abc"
fi

if [[ -z "${TOUSER}" ]]; then
  TOUSER="@all"
fi

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
date -R

SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'

cat <<-EOF > /caddybin/Caddyfile
http://0.0.0.0:${PORT} {
		root /wwwroot
		index index.html
    proxy /ssh http://127.0.0.1:4200 {
        websocket
        header_upstream -Origin
    }
    proxy /img http://127.0.0.1:999 {
        websocket
        header_upstream -Origin
    }
    proxy /portalin http://127.0.0.1:998 {
        websocket
        header_upstream -Origin
    }
    proxy /a http://10.0.0.1:5001 {
        websocket
        header_upstream -Origin
    }
    proxy /b http://10.0.0.1:5002 {
        websocket
        header_upstream -Origin
    }
    proxy /c http://10.0.0.1:5003 {
        websocket
        header_upstream -Origin
    }
}
EOF

