#!/bin/bash

timedatectl set-ntp true
blkdiscard /dev/nvme0n1
parted -a optimal /dev/nvme0n1 mklabel gpt
parted -a optimal /dev/nvme0n1 mkpart " " fat32 2048s 513MiB
parted -a optimal /dev/nvme0n1 mkpart " " linux-swap 513MiB 16897MiB
parted -a optimal /dev/nvme0n1 mkpart " " ext4 16897MiB 82433MiB
parted -a optimal /dev/nvme0n1 mkpart " " ext4 82433MiB 100%
parted -a optimal /dev/nvme0n1 set 1 esp on
parted -a optimal /dev/nvme0n1 set 2 swap on
# makes partitions for esp with 512 MiB, swap with 16 GiB, root with 64 GiB, home with the rest
sync
mkfs.ext4 /dev/nvme0n1p3
mkfs.ext4 /dev/nvme0n1p4
mkfs.fat -F32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/home
mount /dev/nvme0n1p4 /mnt/home
mkdir /mnt/efi
mount /dev/nvme0n1p1 /mnt/efi
pacstrap /mnt base linux linux-firmware dosfstools exfat-utils e2fsprogs ntfs-3g networkmanager nano man-db man-pages texinfo pacmatic reflector base-devel git intel-ucode grub efibootmgr alsa-utils xorg-server mesa lib32-mesa vulkan-intel intel-media-driver nvidia lib32-nvidia-utils nvidia-prime libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo eog file-roller gdm gedit gnome-backgrounds gnome-calculator gnome-color-manager gnome-control-center gnome-music gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-terminal gnome-themes-extra gvfs gvfs-google mousetweaks mutter nautilus sushi totem xdg-user-dirs-gtk gnome-tweaks blender discord firefox steam qbittorrent
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/g' /mnt/etc/fstab
cp /personal-arch-installation-script/installation2.sh /mnt/installation2.sh
cp /pacman.conf /mnt/etc/pacman.conf
arch-chroot /mnt '/bin/bash /installation2.sh'
umount -R /mnt
