IGNORED_NETS = %w(
    10.0.0.0/8
    192.65.241.0/24
    204.14.76.0/23
    173.245.64.0/16
    74.115.0.0/21
    199.255.208.0/21
    46.16.32.0/22
    144.76.70.112
    94.100.16.0/20
    176.56.174.0/24
    93.189.0.0/21
    193.235.73.0/24
    162.210.196.160/27
    46.151.208.0/23
    186.19.62.19/32
    173.246.32.0/19
).collect

NetAddr.summ_IPv4Net(IGNORED_NETS)
