{ lib, config, pkgs, ... }: {
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxPackages_6_10;

    # Enable networking, disable firewall.
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

    # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system with KDE Plasma
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "euro";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # For printing?
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

    # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    frank = {
      isNormalUser = true;
      description = "Frank van Viegen";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
      #  thunderbird
      ];
    };
    quin = {
      isNormalUser = true;
      description = "Quin van Viegen";
    };
    vera = {
      isNormalUser = true;
      description = "Vera van Viegen";
    };
    iris = {
      isNormalUser = true;
      description = "Iris Allijn";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    brave
    vscode
    git
    furmark
    lshw
    usbutils
    pciutils
    switcheroo-control
    qemu_kvm
    openra
    avahi
    killall
    wget
    distrobox
    vim
    appimage-run
    broot
    curl
    eza
    file
    fuse
    fzf
    graphviz
    plantuml
    p7zip
    xz
    mplayer
    ripgrep
    sshfs
    tmux
    unzip
    xsel
    zsh
  ];

  programs = {
    kdeconnect = {
      enable = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall = true; # Open ports in the firewall for steam server
    };
    firefox.enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

    # Dynamic libraries for unpackaged programs
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    libcxx
  ];

  programs.java.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

}
