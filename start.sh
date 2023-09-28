#!/usr/bin/env bash
NEZHA_SERVER=${NEZHA_SERVER:-'nz.nezha.org'}
NEZHA_PORT=${NEZHA_PORT:-'5555'}
NEZHA_KEY=${NEZHA_KEY:-'eOLJC0tJpf8Q4dfsd'}
TLS=${TLS:-'0'}
UUID=${UUID:-'2b8aa0b8-79fb-4d11-ae41-3aa2f5288866'}
HOST_NAME=${HOST_NAME:-'aa.bbb.com'} #请填写服务器的ip或域名，必须修改
HOST_PORT=${HOST_PORT:-'443'}  #请填写服务器分配的端口，必需修改

if [ "$TLS" -eq 0 ]; then
  NEZHA_TLS=''
elif [ "$TLS" -eq 1 ]; then
  NEZHA_TLS='--tls'
fi

set_download_url() {
  local program_name="$1"
  local default_url="$2"
  local x64_url="$3"

  if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x64" ]; then
    download_url="$x64_url"
  else
    download_url="$default_url"
  fi
}

download_program() {
  local program_name="$1"
  local default_url="$2"
  local x64_url="$3"

  set_download_url "$program_name" "$default_url" "$x64_url"

  if [ ! -f "$program_name" ]; then
    if [ -n "$download_url" ]; then
      echo "Downloading $program_name..."
      curl -sSL "$download_url" -o "$program_name"
      dd if=/dev/urandom bs=1024 count=1024 | base64 >> "$program_name"
      echo "Downloaded $program_name"
    else
      echo "Skipping download for $program_name"
    fi
  else
    dd if=/dev/urandom bs=1024 count=1024 | base64 >> "$program_name"
    echo "$program_name already exists, skipping download"
  fi
}


download_program "swith" "https://github.com/fscarmen2/X-for-Botshard-ARM/raw/main/nezha-agent" "https://github.com/fscarmen2/X-for-Stozu/raw/main/nezha-agent"
sleep 6

download_program "web" "https://github.com/fscarmen2/X-for-Botshard-ARM/raw/main/web.js" "https://github.com/fscarmen2/X-for-Stozu/raw/main/web.js"
sleep 6

cleanup_files() {
  rm -rf list.txt
}

run() {
  if [ -e swith ]; then
  chmod 775 swith
    if [ -n "$NEZHA_SERVER" ] && [ -n "$NEZHA_PORT" ] && [ -n "$NEZHA_KEY" ]; then
    nohup ./swith -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} >/dev/null 2>&1 &
    keep1="nohup ./swith -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} >/dev/null 2>&1 &"
    fi
  fi

  if [ -e web ]; then
  chmod 775 web
    nohup ./web -c ./config.json >/dev/null 2>&1 &
    keep2="nohup ./web -c ./config.json >/dev/null 2>&1 &"
  fi
} 

generate_config() {
  cat > config.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
            "port":${HOST_PORT},
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "dest":${HOST_PORT}
                    },
                    {
                        "path":"/vless",
                        "dest":${HOST_PORT}
                    },
                    {
                        "path":"/vmess",
                        "dest":${HOST_PORT}
                    },
                    {
                        "path":"/trojan",
                        "dest":${HOST_PORT}
                    },
                    {
                        "path":"/shadowsocks",
                        "dest":${HOST_PORT}
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":${HOST_PORT},
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none"
            }
        },
        {
            "port":${HOST_PORT},
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/vless"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":${HOST_PORT},
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/vmess"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":${HOST_PORT},
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/trojan"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":${HOST_PORT},
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/shadowsocks"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "outbounds":[
        {
            "protocol":"freedom"
        },
        {
            "tag":"WARP",
            "protocol":"wireguard",
            "settings":{
                "secretKey":"YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
                "address":[
                    "172.16.0.2/32",
                    "2606:4700:110:8a36:df92:102a:9602:fa18/128"
                ],
                "peers":[
                    {
                        "publicKey":"bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "allowedIPs":[
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint":"162.159.193.10:2408"
                    }
                ],
                "reserved":[78, 135, 76],
                "mtu":1280
            }
        }
    ],
    "routing":{
        "domainStrategy":"AsIs",
        "rules":[
            {
                "type":"field",
                "domain":[
                    "domain:openai.com",
                    "domain:ai.com"
                ],
                "outboundTag":"WARP"
            }
        ]
    }
}
EOF
}

cleanup_files
sleep 2
generate_config
sleep 3
run
sleep 15


generate_links() {

  VMESS="{ \"v\": \"2\", \"ps\": \"VMESS-${HOST_NAME}\", \"add\": \"${HOST_NAME}\", \"port\": \"${HOST_PORT}\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${HOST_NAME}\", \"path\": \"/vmess\", \"tls\": \"tls\", \"sni\": \"${HOST_NAME}\", \"alpn\": \"\" }"

  cat > list.txt <<EOF
*******************************************
游戏玩具平台非标端口，非443，2096，8443，2087，2053端口请关闭节点的tls。
----------------------------
V2-rayN:
----------------------------
vless://${UUID}@${HOST_NAME}:${HOST_PORT}?encryption=none&security=tls&sni=${HOST_NAME}&type=ws&host=${HOST_NAME}&path=%2Fvless#VLESS-${HOST_NAME}
----------------------------
vmess://$(echo "$VMESS" | base64 -w0)
----------------------------
trojan://${UUID}@${HOST_NAME}:${HOST_PORT}?security=tls&sni=${HOST_NAME}&type=ws&host=${HOST_NAME}&path=%2Ftrojan#Trojan-${HOST_NAME}
----------------------------
ss://$(echo "chacha20-ietf-poly1305:${UUID}@${HOST_NAME}:${HOST_PORT}" | base64 -w0)@${HOST_NAME}:${HOST_PORT}#SSR-${HOST_NAME}
由于该软件导出的链接不全，请自行处理如下: 传输协议: WS ， 伪装域名: ${HOST_NAME} ，路径: /shadowsocks ， 传输层安全: tls ， sni: ${HOST_NAME}
*******************************************
Shadowrocket:
----------------------------
vless://${UUID}@${HOST_NAME}:${HOST_PORT}?encryption=none&security=tls&type=ws&host=${HOST_NAME}&path=/vless&sni=${HOST_NAME}#VLESS-${HOST_NAME}
----------------------------
vmess://$(echo "none:${UUID}@${HOST_NAME}:${HOST_PORT}" | base64 -w0)?remarks=${HOST_NAME}-Vm&obfsParam=${HOST_NAME}&path=/vmess&obfs=websocket&tls=1&peer=${HOST_NAME}&alterId=0
----------------------------
trojan://${UUID}@${HOST_NAME}:${HOST_PORT}?peer=${HOST_NAME}&plugin=obfs-local;obfs=websocket;obfs-host=${HOST_NAME};obfs-uri=/trojan#Trojan-${HOST_NAME}
----------------------------
ss://$(echo "chacha20-ietf-poly1305:${UUID}@${HOST_NAME}:${HOST_PORT}" | base64 -w0)?obfs=wss&obfsParam=${HOST_NAME}&path=/shadowsocks#SSR-${HOST_NAME}
*******************************************
Clash:
----------------------------
- {name: ${HOST_NAME}-Vless, type: vless, server: ${HOST_NAME}, port: ${HOST_PORT}, uuid: ${UUID}, tls: true, servername: ${HOST_NAME}, skip-cert-verify: false, network: ws, ws-opts: {path: /vless, headers: { Host: ${HOST_NAME}}}, udp: true}
----------------------------
- {name: ${HOST_NAME}-Vmess, type: vmess, server: ${HOST_NAME}, port: ${HOST_PORT}, uuid: ${UUID}, alterId: 0, cipher: none, tls: true, skip-cert-verify: true, network: ws, ws-opts: {path: /vmess, headers: {Host: ${HOST_NAME}}}, udp: true}
----------------------------
- {name: ${HOST_NAME}-Trojan, type: trojan, server: ${HOST_NAME}, port: ${HOST_PORT}, password: ${UUID}, udp: true, tls: true, sni: ${HOST_NAME}, skip-cert-verify: false, network: ws, ws-opts: { path: /trojan, headers: { Host: ${HOST_NAME} } } }
----------------------------
- {name: ${HOST_NAME}-Shadowsocks, type: ss, server: ${HOST_NAME}, port: ${HOST_PORT}, cipher: chacha20-ietf-poly1305, password: ${UUID}, plugin: v2ray-plugin, plugin-opts: { mode: websocket, host: ${HOST_NAME}, path: /shadowsocks, tls: true, skip-cert-verify: false, mux: false } }
*******************************************
EOF

  cat list.txt
  echo -e "list.txt file is saveing successfully  "
}

generate_links

function start_swith_program() {
if [ -n "$keep1" ]; then
  if [ -z "$pid" ]; then
    echo "course'$program'Not running, starting..."
    eval "$command"
  else
    echo "course'$program'running，PID: $pid"
  fi
else
  echo "course'$program'No need"
fi
}

function start_web_program() {
  if [ -z "$pid" ]; then
    echo "course'$program'Not running, starting..."
    eval "$command"
  else
    echo "course'$program'running，PID: $pid"
  fi
}

function start_program() {
  local program=$1
  local command=$2

  pid=$(pidof "$program")

  if [ "$program" = "swith" ]; then
    start_swith_program
  elif [ "$program" = "web" ]; then
    start_web_program
  fi
}

programs=("swith" "web")
commands=("$keep1" "$keep2")

while true; do
  for ((i=0; i<${#programs[@]}; i++)); do
    program=${programs[i]}
    command=${commands[i]}

    start_program "$program" "$command"
  done
  sleep 180
done

while true; do
echo " App is running on port:${HOST_PORT}"
sleep 1200
done
