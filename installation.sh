#!/bin/bash

timedatectl set-ntp true
blkdiscard /dev/nvme0n1
parted -s /dev/nvme0n1 mklabel gpt
parted -s mkpart " " fat32 2048s 513MiB
parted -s mkpart " " linux-swap 513MiB 16897MiB
parted -s mkpart " " ext4 16897MiB 82433MiB
parted -s mkpart " " ext4 82433MiB 100%
parted -s set 1 esp on
parted -s set 2 swap on
parted -s set 3 root on
# make partitions for esp with 512 MiB, swap with 16 GiB, root with 64 GiB, home with the rest
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
reflector -a 1 -p https --ipv4 --ipv6 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap /mnt base linux linux-firmware dosfstools exfat-utils e2fsprogs ntfs-3g networkmanager nano man-db man-pages texinfo pacmatic reflector base-devel git intel-ucode grub efibootmgr alsa-utils xorg-server mesa lib32-mesa vulkan-intel intel-media-driver nvidia lib32-nvidia-utils nvidia-prime libva-vdpau-driver libvdpau-va-gl libva-utils vdpauinfo
genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/relatime/noatime/g' /mnt/etc/fstab
cp /personal-arch-installation-script/installation2.sh /mnt/installation2.sh
cp /pacman.conf /mnt/etc/pacman.conf
arch-chroot /mnt '/bin/bash /installation2.sh'
umount -R /mnt
echo "please reboot to conclude installation"
