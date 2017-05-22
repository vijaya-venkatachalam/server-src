#!/bin/sh
logger MY connection $PLUTO_PEER_ID $PLUTO_VERB $PLUTO_UNIQUEID
if test $PLUTO_VERB = "up-host"
then
	lxc-copy -n base -N $PLUTO_PEER_ID
	lxc-start -n $PLUTO_PEER_ID -d
	lxc-attach -n $PLUTO_PEER_ID -- ip l s dev eth0 up	
	lxc-attach -n $PLUTO_PEER_ID -- ip a a 10.52.43.2/24 dev eth0
	lxc-attach -n $PLUTO_PEER_ID -- ip r a default via 10.52.43.1 dev eth0
        lxc-attach -n $PLUTO_PEER_ID -- ip l2tp add tunnel tunnel_id 5000 peer_tunnel_id 5000 encap udp udp_sport 5000 udp_dport 5000 local 10.52.43.2 remote 78.33.59.98
        lxc-attach -n $PLUTO_PEER_ID -- ip l2tp add session tunnel_id 5000 session_id 5000 peer_session_id 5000 
        lxc-attach -n $PLUTO_PEER_ID -- ip link set l2tpeth0 up 
        lxc-attach -n $PLUTO_PEER_ID -- ip addr add 192.168.66.3/31 dev l2tpeth0
        lxc-attach -n $PLUTO_PEER_ID -- iptables -A INPUT -i l2tpeth0 -j ACCEPT
fi
if test $PLUTO_VERB = "down-host"
then
        lxc-attach -n $PLUTO_PEER_ID -- ip l2tp del session tunnel_id 5000  session_id 5000
        lxc-attach -n $PLUTO_PEER_ID -- ip l2tp del tunnel tunnel_id 5000 
        lxc-attaxh -n $PLUTO_PEER_ID -- iptables -D INPUT -i l2tpeth0 -j ACCEPT
	lxc-stop -n $PLUTO_PEER_ID -k
        lxc-destroy -n $PLUTO_PEER_ID
fi

exit 0
