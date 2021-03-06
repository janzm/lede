local ucursor = require "luci.model.uci"
local json = require "luci.jsonc"
local server_section = arg[1]
local proto = arg[2] 

local server = ucursor:get_all("shadowsocksr", server_section)

local v2ray = {
    -- 传入连接
    inbound = {
        port = 1234,
        protocol = "dokodemo-door",
        settings = {
            network = proto,
            followRedirect = true
        },
        sniffing = {
            enabled = true,
            destOverride = { "http", "tls" }
        }
    },
    -- 传出连接
    outbound = {
        protocol = "vmess",
        settings = {
            vnext = {
                {
                    address = server.server,
                    port = tonumber(server.server_port),
                    users = {
                        {
                            id = server.vmess_id,
                            alterId = tonumber(server.alter_id),
                            security = server.security
                        }
                    }
                }
            }
        },
    -- 底层传输配置
        streamSettings = {
            network = server.transport,
            security = (server.tls == '1') and "tls" or "none",
            kcpSettings = (server.transport == "kcp") and {
              mtu = tonumber(server.mtu),
              tti = tonumber(server.tti),
              uplinkCapacity = tonumber(server.uplink_capacity),
              downlinkCapacity = tonumber(server.downlink_capacity),
              congestion = (server.congestion == "1") and true or false,
              readBufferSize = tonumber(server.read_buffer_size),
              writeBufferSize = tonumber(server.write_buffer_size),
              header = {
                  type = server.kcp_guise
              }
          } or nil,
             wsSettings = (server.transport == "ws") and {
                path = server.ws_path,
                headers = (server.ws_host ~= nil) and {
                    Host = server.ws_host
                } or nil,
            } or nil,
            httpSettings = (server.transport == "h2") and {
                path = server.h2_path,
                host = server.h2_host,
            } or nil
        }
    },

    -- 额外传出连接
    outboundDetour = {
        {
            protocol = "freedom",
            tag = "direct",
            settings = { keep = "" }
        }
    }
}
print(json.stringify(v2ray))