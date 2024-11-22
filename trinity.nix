{ config, lib, pkgs, modulesPath, ... }: {
  # Ensure proper configuration for PCI passthrough
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
  ];

  # Load nvidia driver for Xorg and Wayland
  boot.blacklistedKernelModules = [ "nouveau" ];
  hardware.opengl.enable = true;
  services.xserver.videoDrivers = ["nvidia" "amdgpu"];
  
  hardware.nvidia = {
 
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

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
      version = "560.35.03";
      sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
      sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
      openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
      settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
      persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
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

  # Prevent dup login
  services.xserver.displayManager.sessionCommands = ''
  active_sessions=$(loginctl list-sessions --no-legend | awk -v user=$USER -v seat=$\{XDG_SEAT:-seat0} -v sid=$XDG_SESSION_ID '{gsub(/^[ \t]+/, ""); if ($3 == user && ($6 == "active" || $6 == "online") && $1 != sid) count++} END {print count}')
  if [ "$active_sessions" -gt 0 ] ; then
    zenity --error --text="User $USER is already logged in."
    exit 1
  fi

  #if [ "$XDG_SEAT" = seat1] ; then
  #  /usr/bin/env xrandr --auto || true
  #fi
  ''; 

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
