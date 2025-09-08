#bin/bash

sudo nmcli connection down "netplan-enX0" && sudo nmcli connection up "netplan-enX0"