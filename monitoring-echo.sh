#!/bin/bash
arc=$(uname -a)
p_cpu=$(grep "physical id" /proc/cpuinfo | uniq | wc -l)										# Gets the physical CPU core count.
l_cpu=$(grep "^processor" /proc/cpuinfo | wc -l)											# Gets the total CPU core count.
f_mem=$(free -m | grep "^Mem: " | awk '{print $2}')											# Gets the free memory in the RAM.
u_mem=$(free -m | grep "^Mem: " | awk '{print $3}')											# Gets the used memory in the RAM.
t_ram=$(free | grep '^Mem:' | awk '{printf("%.2f"), $3/$2*100}')									# Calculates the percentage of RAM used.
t_disk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{f_t += $2} END {print f_t}')							# Gets and calculates the total size of the disks.
u_disk=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{u_t += $3} END {print u_t}')							# Gets and calculates the total size of the disks.
p_disk=$(df -BM | grep '^/dev/' | grep -v '/boot$' | awk '{u_t += $3} {f_t+= $2} END {printf("%d"), u_t/f_t*100}')			# Calculates the percentage of disk used.
cpu_l=$(mpstat | grep "all" | awk '{print 100 - $12}')											# Gets the current CPU load.
l_boot=$(who -b | grep "system" | awk '{print $3 " | " $4}')										# Gets the last boot of the system.
is_lvm=$(if [ $(lsblk | grep "lvm" | wc -l) -eq 0 ]; then echo False; else echo True; fi)						# Boolean for if the system is using LVM disk management.
c_tcp=$(ss -neopt state established | grep -v "Recv-Q"  | wc -l)									# Counts how many TCP are alive.
u_log=$(users | wc -w)															# Counts how many user session are logged in.
du_log=$(users | tr " " "\n" | uniq | wc -w)												# Counts how many unique user sessions are logged in.
ip=$(hostname -I | grep -o -E '(\b25[0-5]|\b2[0-4][0-9]|\b[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}' | head -1)	# Gets the local gateway of the system.
mac=$(ip link show | grep 'ether' | grep -o -E '([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})' | head -1)					# Gets the MAC address of the ether adapter.
s_count=$(journalctl _COMM=sudo -q | grep COMMAND | wc -l)										# Counts the amount of times sudo was used for commands.
echo "
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
║		Architecture	:	"$arc"
║		Physical CPUs	:	"$p_cpu"
║		CPUs		:	"$l_cpu"
║		Memory Usage	:	"$u_mem/$f_mem \(MB\)   [$t_ram%]"
║		Disk Usage	:	"$u_disk/$t_disk \(GB\) [$p_disk%]"
║		CPU Load	:	"$cpu_l%"
║		Last Boot	:	"$l_boot"
║		IsLVM		:	"$is_lvm"
║		TCP Connections	:	"$c_tcp"
║		User Log	:	"$u_log [Unique: $du_log]"
║		Network		:	"$ip [$mac]"
║		Sudo		:	"$s_count commands"
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
"
