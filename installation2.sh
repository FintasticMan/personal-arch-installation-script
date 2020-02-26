#!/bin/bash

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock -w
nano /etc/locale.gen
# uncomment en_GB.UTF-8 UTF-8, en_US.UTF-8 UTF-8, nl_NL.UTF-8 UTF-8
locale-gen
echo LANG=en_GB.UTF-8 UTF-8 >> /etc/locale.conf
echo fintasticman-arch >> /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\tfintasticman-arch.localdomain\tfintasticman-arch" >> /etc/hosts
passwd
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable fstrim.timer
systemctl enable NetworkManager.service
useradd -m finlay
passwd finlay
EDITOR=nano visudo
# allow user finlay to use sudo
pacmatic -Syu gnome gnome-extra
# choose packages you want
sudo systemctl enable gdm.service
exit