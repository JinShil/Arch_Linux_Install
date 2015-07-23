set -x

useradd -m -G wheel -s /bin/bash mike
passwd -d mike

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/hosts

pacman -S --noconfirm virtualbox-guest-utils

systemctl enable vboxservice
systemctl start vboxservice

pacman -S --noconfirm xorg-server xorg-xinit

pacman -S --noconfirm plasma



