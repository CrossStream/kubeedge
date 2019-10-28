#
# Regular cron jobs for the kubeedge package
#
0 4	* * *	root	[ -x /usr/bin/kubeedge_maintenance ] && /usr/bin/kubeedge_maintenance
