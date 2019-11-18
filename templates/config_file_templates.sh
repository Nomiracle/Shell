# ss config
ss_config_standalone(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp"
	}
	EOF
}

# ss + v2ray-plugin config
ss_v2ray_ws_http_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"v2ray-plugin",
		"plugin_opts":"server"
	}
	EOF
}

ss_v2ray_ws_tls_cdn_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"v2ray-plugin",
		"plugin_opts":"server;tls;host=${domain};cert=${cerpath};key=${keypath}"
	}
	EOF
}


ss_v2ray_quic_tls_cdn_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_only",
		"plugin":"v2ray-plugin",
		"plugin_opts":"server;mode=quic;host=${domain};cert=${cerpath};key=${keypath}"
	}
	EOF
}

ss_v2ray_ws_tls_web_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"v2ray-plugin",
		"plugin_opts":"server;path=${path}"
	}
	EOF
}

caddy_config_none_cdn(){
	cat > ${CADDY_CONF_FILE}<<-EOF
	${domain}:443 {
		gzip
		tls ${email}
		timeouts none
		proxy ${path} localhost:${shadowsocksport} {
			websocket
			header_upstream -Origin
		}
		proxy / ${mirror_site} {
			except ${path}
		}
	}
	EOF
}

ss_v2ray_ws_tls_web_cdn_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"v2ray-plugin",
		"plugin_opts":"server;path=${path}"
	}
	EOF
}

nginx_config(){
	cat > /etc/nginx/nginx.conf<<-EOF
	events {
	    worker_connections  4096;  ## Default: 1024
	}

	http {
	    server {
	        listen 80;
	        server_name ${domain};
	        return 301 https://\$http_host\$request_uri;
	    }
	    
	    server{
	        listen 443 ssl;
	        server_name ${domain};
	        ssl on;
	        ssl_certificate ${cerpath};
	        ssl_certificate_key ${keypath};
	        ssl_session_cache shared:SSL:10m;
	        ssl_session_timeout  10m;
	        add_header Strict-Transport-Security "max-age=31536000";
	        
	        location ${path} {
	            proxy_redirect off;
	            proxy_http_version 1.1;
	            proxy_pass http://localhost:${shadowsocksport};
	            proxy_set_header Host \$http_host;
	            proxy_set_header Upgrade \$http_upgrade;
	            proxy_set_header Connection "upgrade";
	        }
	        
	        location / {
	            sub_filter ${mirror_domain} ${domain};
	            sub_filter_once off;
	            proxy_set_header X-Real-IP \$remote_addr;
	            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
	            proxy_set_header Referer ${mirror_site};
	            proxy_set_header Host ${mirror_domain};
	            proxy_pass ${mirror_site};
	            proxy_set_header Accept-Encoding "";
	        }
	    }
	}
	EOF
}

caddy_config_with_cdn(){
	cat > ${CADDY_CONF_FILE}<<-EOF
	${domain}:443 {
		gzip
		tls {
			dns cloudflare
		}
		timeouts none
		proxy ${path} localhost:${shadowsocksport} {
			websocket
			header_upstream -Origin
		}
		proxy / ${mirror_site} {
			except ${path}
		}
	}
	EOF
}

# kcptun config (Standalone)
kcptun_config_standalone(){
	cat > ${KCPTUN_CONFIG}<<-EOF
	{
		"listen": ":${listen_port}",
		"target": "127.0.0.1:${shadowsocksport}",
		"key": "${key}",
		"crypt": "${crypt}",
		"mode": "${mode}",
		"mtu": ${MTU},
		"sndwnd": ${sndwnd},
		"rcvwnd": ${rcvwnd},
		"datashard": ${datashard},
		"parityshard": ${parityshard},
		"dscp": ${DSCP},
		"nocomp": ${nocomp},
		"tcp": ${KP_TCP}
	}
	EOF
}

# ss + simple-obfs
ss_obfs_http_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"obfs-server",
		"plugin_opts":"obfs=${shadowsocklibev_obfs}"
	}
	EOF
}

ss_obfs_tls_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"obfs-server",
		"plugin_opts":"obfs=${shadowsocklibev_obfs}"
	}
	EOF
}

# ss + goquiet
ss_goquiet_config(){
	cat > ${SHADOWSOCKS_CONFIG}<<-EOF
	{
		"server":${server_value},
		"server_port":${shadowsocksport},
		"password":"${shadowsockspwd}",
		"timeout":300,
		"user":"nobody",
		"method":"${shadowsockscipher}",
		"fast_open":${fast_open},
		"nameserver":"8.8.8.8",
		"mode":"tcp_and_udp",
		"plugin":"gq-server",
		"plugin_opts":"WebServerAddr=${gqwebaddr};Key=${gqkey}"
	}
	EOF
}

# ss + cloak config
cloak2_server_config(){
	cat > ${CK_SERVER_CONFIG}<<-EOF
	{
		"ProxyBook":{
		"shadowsocks":["tcp","127.0.0.1:${shadowsocksport}"]
		},
		"BindAddr":[":443",":80"],
		"BypassUID":[],
		"RedirAddr":"${ckwebaddr}",
		"PrivateKey":"${ckpv}",
		"AdminUID":"${ckauid}",
		"DatabasePath":"${CK_DB_PATH}/userinfo.db",
		"StreamTimeout":300
	}
	EOF
}

cloak2_client_config(){
	cat > ${CK_CLIENT_CONFIG}<<-EOF
	{
		"Transport":"direct",
		"ProxyMethod":"shadowsocks",
		"EncryptionMethod":"plain",
		"UID":"${ckauid}",
		"PublicKey":"${ckpub}",
		"ServerName":"${domain}",
		"NumConn":4,
		"BrowserSig":"chrome",
		"StreamTimeout":300
	}
	EOF
}












