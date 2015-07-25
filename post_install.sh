set -x

passwd

# Add user mike
useradd -m -G wheel -s /bin/bash mike
passwd -d mike

sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Add Virtualbox stuff
pacman -S --noconfirm virtualbox-guest-utils xorg-xinit

systemctl enable vboxservice
systemctl start vboxservice

# Add KDE
pacman -S --noconfirm plasma
pacman -S --noconfirm konsole
pacman -S --noconfirm kate
pacman -Rns --noconfirm ksshaskpass



