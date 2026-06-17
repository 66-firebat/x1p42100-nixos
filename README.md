## Updates
 * As of kernel 7.1, bootmac has been integrated into the kernel configuration, resolving previous networking setup steps.
### Step 1: Building the Installer ISO
Currently, a pre-built binary ISO is not available. Because cross-compiling can be problematic, the ISO must be built on an ARM64 environment (such as WSL with Nix installed on your Surface Pro, or another ARM64 Linux system).
```bash
git clone [https://github.com/66-firebat/x1p42100-nixos.git](https://github.com/66-firebat/x1p42100-nixos.git)
cd x1p42100-nixos
nix build --extra-experimental-features 'nix-command flakes' .#nixosConfigurations.slim5xISO.config.system.build.isoImage

```
Flash the resulting ISO onto a USB drive using Rufus or BalenaEtcher or ventoy
#### Warning if Rufus or BalenaEtcher doesnt boot then try ventoy
### Step 2: Device Preparation
 1. **Disable BitLocker:** By opening powershell as a administrator and run
``` Disable-BitLocker -MountPoint (Get-BitLockerVolume -MountPoint "C:")```
 2. **Partitioning:** Right-click the Windows Start button and select **Disk Management**. Shrink your main Windows partition (C:) to free up unallocated space for your NixOS root filesystem.
   * *Caution:* Leave the default Windows EFI partition intact. Do not attempt to resize it manually, as this can corrupt the bootloader layout.
 3. **Disable Secure Boot:** * Shut down the Surface Pro completely.
   * Press and hold the **Volume Up (+)** button.
   * Press and release the **Power** button.
   * Keep holding **Volume Up** until the Surface UEFI screen appears.
   * Navigate to **Security**, select **Change configuration** under Secure Boot, set it to **None**, and restart.
### Step 3: Booting the ISO
 1. Shut down the device completely and plug in your flashed installation USB drive.
 2. Press and hold the **Volume Down (-)** button.
 3. Press and release the **Power** button.
 4. Keep holding **Volume Down** until the Surface logo appears and the device begins booting from the USB drive.
### Step 4: Installation
#### Install on your own risk.
You can proceed with the manual command-line method.
#### Manual CLI Installation
 1. Open a terminal window and connect to Wi-Fi via nmtui.
 2. Drop into a root shell and format your target partition also /mnt and /mnt/boot are hardecoded by nixos-install:
   ```
   sudo -i
   mkfs.ext4 -L root /dev/sda3
   fatlabel /dev/sda1 BOOT
   ```
 3. Mount your freshly formatted root partition along with the native EFI system partition:
   ```
   mount /dev/sda3 /mnt
   mkdir -p /mnt/boot
   mount /dev/sda1 /mnt/boot
   ```

 4. Run the installer flake targeting the configuration profile:
   ```
   sudo nixos-install --root /mnt --no-channel-copy --no-root-password --flake .?submodules=1#qcom-nixos
   ```

## Related repos

This project relies heavily on work by others.

- [jglathe's Ubuntu kernel for Snapdragon X laptops](https://github.com/jglathe/linux_ms_dev_kit)
- [kurugzgy's x1e NixOS config](https://github.com/kuruczgy/x1e-nixos-config)
