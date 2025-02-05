{ config, lib, pkgs, modulesPath, ... }: {
  # Ensure proper configuration for PCI passthrough
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "nvidia_drm.modeset=0"
    "nvidia_drm.fbdev=0"
  ];

  # Load nvidia driver for Xorg and Wayland
  boot.blacklistedKernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];


  fileSystems."/extra" = {
    device = "/dev/disk/by-uuid/66B2C4FFB2C4D529";
    fsType = "ntfs-3g";
  };

  hardware.nvidia = {
 
    # Modesetting is required.
    modesetting.enable = false;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
  	# accessible via `nvidia-settings`.
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "565.57.01";
      sha256_64bit = "sha256-buvpTlheOF6IBPWnQVLfQUiHv4GcwhvZW3Ks0PsYLHo==";
      sha256_aarch64 = "sha256-aDVc3sNTG4O3y+vKW87mw+i9AqXCY29GVqEIUlsvYfE==";
      openSha256 = "sha256-unknown";
      settingsSha256 = "sha256-42RMyO2LlUjRIBx1lbr8VWNj3zgheaCsVnUcCJdsARY==";
      persistencedSha256 = "sha256-fUt+7ZESLzZLA4RobN8x1LkdjWPVNweF6cizyK9p8uU==";
    };
  };
  
  environment.etc.seat = {
    target = "udev/rules.d/72-multiseat.rules";
    text = ''
      TAG=="seat", ENV{ID_FOR_SEAT}=="sound-pci-0000_10_00_1", ENV{ID_SEAT}="seat1"
      TAG=="seat", ENV{ID_FOR_SEAT}=="graphics-pci-0000_10_00_0", ENV{ID_SEAT}="seat1"
      TAG=="seat", ENV{ID_FOR_SEAT}=="drm-pci-0000_10_00_0", ENV{ID_SEAT}="seat1"
      TAG=="seat", ENV{ID_FOR_SEAT}=="usb-pci-0000_16_00_0-usb-0_5", ENV{ID_SEAT}="seat1"
    '';
  };
  environment.systemPackages = with pkgs; [
    kdialog
    qemu_kvm
    OVMFFull
  ];

  # Prevent dup login
  services.xserver.displayManager.sessionCommands = ''
  active_sessions=$(loginctl list-sessions --no-legend | awk -v user=$USER -v sid=$XDG_SESSION_ID 'BEGIN {count=0} {gsub(/^[ \t]+/, ""); if ($3 == user && $5 !~ /^tty/ && ($6 == "active" || $6 == "online") && $1 != sid) count++} END {print count}')
  if [ "$active_sessions" -gt 0 ] ; then
    kdialog --error "User $USER is already logged in."
    exit 1
  fi
  ''; 

  security.sudo.configFile = ''
  ALL ALL=(ALL) NOPASSWD: /etc/nixos/windows-kvm.sh
  '';

  services.displayManager.sessionPackages = [
    (pkgs.runCommand "windows-kvm-session" { passthru.providedSessions = [ "windows-kvm" ]; } ''
      mkdir -p $out/share/xsessions
      cat <<EOF > $out/share/xsessions/windows-kvm.desktop
[Desktop Entry]
Name=Windows 11
Exec=/etc/nixos/windows-kvm.sh session
Type=Application
DesktopNames=X-NIXOS-SYSTEMD-AWARE
EOF
    '')
  ];

  # Disable suspend, as it is not reliable.
  powerManagement.enable = false;
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Don't allow users to suspend/shutdown. This is a server.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.login") == 0 &&
         (action.id.indexOf("power-off") != -1 ||
          action.id.indexOf("reboot") != -1 ||
          action.id.indexOf("suspend") != -1 ||
          action.id.indexOf("hibernate") != -1)) {
        return polkit.Result.NO;
      }
    });
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
