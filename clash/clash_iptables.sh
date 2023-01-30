# Support tproxy
insmod /lib/modules/nfnetlink.ko &> /dev/null
insmod /lib/modules/ip_set.ko &> /dev/null
insmod /lib/modules/ip_set_hash_ip.ko &> /dev/null
insmod /lib/modules/xt_set.ko &> /dev/null
insmod /lib/modules/ip_set_hash_net.ko &> /dev/null
insmod /lib/modules/xt_mark.ko &> /dev/null
insmod /lib/modules/xt_connmark.ko &> /dev/null
insmod /lib/modules/nf_tproxy_core.ko &> /dev/null
insmod /lib/modules/xt_TPROXY.ko &> /dev/null
insmod /lib/modules/iptable_mangle.ko &> /dev/null

# ROUTE RULES
ip rule add fwmark 1 table 100
ip route add local default dev lo table 100

# LOCAL CLIENTS
iptables -t mangle -N CLASH
iptables -t mangle -A CLASH -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A CLASH -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH -d 240.0.0.0/4 -j RETURN

iptables -t mangle -A CLASH -p tcp -d 198.18.0.0/16 -j TPROXY --on-port 7893 --tproxy-mark 1
iptables -t mangle -A CLASH -p udp -d 198.18.0.0/16 -j TPROXY --on-port 7893 --tproxy-mark 1
iptables -t mangle -A PREROUTING -j CLASH

# LOCAL MACHINE
iptables -t mangle -N CLASH_MASK
iptables -t mangle -A CLASH_MASK -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_MASK -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_MASK -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A CLASH_MASK -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A CLASH_MASK -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A CLASH_MASK -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A CLASH_MASK -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH_MASK -d 240.0.0.0/4 -j RETURN
iptables -t mangle -A CLASH_MASK -d 255.255.255.255/32 -j RETURN

iptables -t mangle -A CLASH_MASK -j RETURN -m mark --mark 0xff
iptables -t mangle -A CLASH_MASK -p tcp -d 198.18.0.0/16 -j MARK --set-mark 1
iptables -t mangle -A CLASH_MASK -p udp -d 198.18.0.0/16 -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -j CLASH_MASK

iptables -t nat -N CLASH_DNS
iptables -t nat -F CLASH_DNS 
iptables -t nat -A CLASH_DNS -p udp -j REDIRECT --to-port 1053
iptables -t nat -I OUTPUT -p udp --dport 53 -j CLASH_DNS
iptables -t nat -I PREROUTING -p udp --dport 53 -j CLASH_DNS