# Build command 
sudo nixos-install --root /mnt --no-channel-copy --no-root-password --flake .?submodules=1#qcom-nixos

# Updates
- As of kernel 7.1, bootmac has been integrated into the kernel configuration, and is included with jglathe's shipped kernel

# TOSTUDY
```
 networking = {
   hostName = "qcom-nixos";

    wireless = {
      enable = false; # true; # false;
      iwd = {
        enable = true;
        settings = {
          General.ControlPortOverNL80211 = false;
          Settings = {
            AutoConnect = true;
            # AlwaysRandomizeAddress = true;
          };
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
          # DriverQuirks.DefaultInterface = "wlan0";
        };
      };
    };

   networkmanager = {
     enable = true;

     wifi = {
       # powersave = true;
       # backend = "iwd";
     };
   };
 };
```

# NixOS for x1p42100

NixOS for the Qualcomm Snapdragon X Plus (x1p42100) based _Lenovo Ideapad Slim
5x_.

# Installation

_Note: This exact installation process has yet to be tested._

### Step 1: Building the installer ISO

Currently, a binary release of the ISO is not available, and you will have to
compile it yourself. Since cross-compiling is not currently supported, the ISO
must be built on the device itself or another ARM64 based system.

The easiest way to build the ISO on Windows is probably to use WSL with
[Nix installed](https://nixos.org/download/#nix-install-windows).

Once you have Nix installed on some ARM64 system, you can use the following
commands to build the ISO:

```
git clone git@github.com:Tokor0/x1p42100-nixos
cd x1p42100-nixos
nix build --extra-experimental-features 'nix-command flakes' .#nixosConfigurations.slim5xISO.config.system.build.isoImage
```

Then, flash the ISO onto a USB-**A** device. Note that USB-C will not work.

### Step 2: Device preparation

BitLocker must be turned off. To do this, search for "Device encryption
settings" in the start menu, and turn "Device encryption" off.

Next, create a new partition for the Linux root filesystem. To do this you
probably want to shrink the Windows partition. Search for "Create and format
hard disk partitions" in the start menu and shrink the (C:) partition to your
liking. Then, create the new partition in the free space.

_Note: The default EFI partition is very small, and you may want to extend it.
This may break the Windows installation._

### Step 3: Booting the ISO

Reboot the laptop, and enter the UEFI menu by pressing F2 when the boot logo
screen is showing.

Go to "Security > Secure Boot" and disable it. Then exit and save the changes.

Connect the previously flashed bootable USB drive to the laptop and enter the
boot menu by pressing F12 at boot and select the drive.

### Step 4: Installation

First, connect to Wi-Fi using `nmtui`.

Enter a root shell and format the previously created partition:

```
sudo -i
mkfs.ext4 -L root /dev/nvme0n1pX
```

Mount the root filesystem and the EFI partition:

```
mount /dev/disk/by-label/root /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/SYSTEM_DRV /mnt/boot
```

Finally, run `nixos-install`:

```
nixos-install --root /mnt --no-channel-copy --no-root-passoword --flake git@github.com:Tokor0/x1p42100-nixos#slim5xSystem
```

Now, NixOS is installed, and you should be able to boot into it by rebooting and
selecting the appropriate boot option.

After booting, you can login with the username `user` and password `arm`. You
probably want to change the password using `passwd`. You can connect to Wi-Fi
using `nmtui`.

By default, some programs are installed. You can start Hyprland using
`start-hyprland`. In Hyprland, press Super-Q to open a terminal emulator, or
Super-Space to open a program launcher. Here, Super refers to the Windows key.

# Using in your own NixOS configuration

**TODO**

## TODO

- Get the ISO to boot **DONE**
- Add a system configuration output to the flake **DONE**
- Get firmware -> graphics **DONE**
- Make it convenient to use in other configs **DONE**
- Finish the guide **IN PROGRESS**

## Related repos

This project relies heavily on work by others.

- [jglathe's Ubuntu kernel for Snapdragon X laptops](https://github.com/jglathe/linux_ms_dev_kit)
- [kurugzgy's x1e NixOS config](https://github.com/kuruczgy/x1e-nixos-config)
