# Reset extroot automatically
cat << "EOF" > /etc/uci-defaults/90-extroot-restore
if [ ! -e /etc/extroot-restore ] \
&& lock -n /var/lock/extroot-restore \
&& uci -q get fstab.overlay > /dev/null \
&& block info > /dev/null
then
OVR_UUID="$(uci -q get fstab.overlay.uuid)"
OVR_DEV="$(block info | sed -n -e "/${OVR_UUID}/s/:.*$//p")"
mount "${OVR_DEV}" /mnt
OVR_BAK="$(mktemp -d -p /mnt -t bak.XXXXXX)"
mv -f /mnt/etc /mnt/upper "${OVR_BAK}"
cp -f -a /overlay/. /mnt
umount /mnt
rm -f /etc/opkg-restore
touch /etc/extroot-restore
lock -u /var/lock/extroot-restore
reboot
fi
exit 1
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/uci-defaults/90-extroot-restore
EOF
