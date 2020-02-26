#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock -w
sed -i 's/#en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
sed -i 's/#nl_NL.UTF-8 UTF-8/nl_NL.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_GB.UTF-8 UTF-8" >> /etc/locale.conf
echo "fintasticman-arch" >> /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\tfintasticman-arch.localdomain\tfintasticman-arch" >> /etc/hosts
reflector -a 1 -p https --ipv4 --ipv6 --sort rate --save /etc/pacman.d/mirrorlist
echo -e "[Trigger]\nOperation = Upgrade\nType = Package\nTarget = pacman-mirrorlist\n\n[Action]\nDescription = Updating pacman-mirrorlist with reflector and removing pacnew...\nWhen = PostTransaction\nDepends = reflector\nExec = /bin/sh -c "reflector -a 1 -p https --ipv4 --ipv6 --sort rate --save /etc/pacman.d/mirrorlist; rm -f /etc/pacman.d/mirrorlist.pacnew"" >> /etc/pacman.d/hooks/mirrorupgrade.hook
echo -e "[Unit]\nDescription=Pacman mirrorlist update\nWants=network-online.target\nAfter=network-online.target\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/reflector -a 1 -p https --ipv4 --ipv6 --sort rate --save /etc/pacman.d/mirrorlist\n\n[Install]\nRequiredBy=multi-user.target" >> /etc/systemd/system/reflector.service
echo -e "[Unit]\nDescription=Run reflector weekly\n\n[Timer]\nOnCalendar=Mon *-*-* 7:00:00\nRandomizedDelaySec=15h\nPersistent=true\n[Install]\nWantedBy=timers.target" >> /etc/systemd/system/reflector.timer
passwd
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable fstrim.timer
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable reflector.timer
useradd -m finlay
passwd finlay
gpasswd -a finlay wheel
cp /etc/sudoers /etc/sudoers.bak
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers.bak
echo -e "\nDefaults insults" >> /etc/sudoers.bak
visudo -c -f /etc/sudoers.bak
echo "If the output of the last command was good, run 'cp /etc/sudoers.bak /etc/sudoers' and reboot.  If it wasn't, cry.  And then try to fix it, and inevitably fail."
exit
