# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ../../hardware/lenovo/yoga/7/14AHP9/hardware-configuration.nix
  ];

  # register 'pkgsUnstable' to access anywhere in the config
  # _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
  #   inherit (pkgs.stdenv.hostPlatform) system;
  #   inherit (config.nixpkgs) config;
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Lisbon";

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

  # automatic timezone
  services.automatic-timezoned.enable = true;
  services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.cups-pdf.enable = true;
  services.printing.cups-pdf.instances = {
    pdf = {
      settings = {
        Out = "\${HOME}/pdf-printed";
        UserUMask = "0033";
      };
    };
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = true;

  security.rtkit.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  # automatically switch to newly-connected devices
  services.pulseaudio.extraConfig = "load-module module-switch-on-connect";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.woile = {
    isNormalUser = true;
    description = "Santiago Fraire";
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm" # apparently helps with android emulators
      "adbusers" # android debugging
      "libvirtd" # virtualisation
    ];
    packages = with pkgs; [
      vim
      rng-tools
    ];
  };

  programs.adb.enable = true;
  programs.bandwhich.enable = true;

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  programs.nix-ld = {
    enable = true;
  };
  # does some system configuration that Home Manager doesn’t have the privileges to do
  programs.steam = {
    enable = true;
    # Open ports in the firewall for Steam Remote Play
    remotePlay.openFirewall = true;
    # Open ports in the firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
    # Open ports in the firewall for Steam Local Network Game Transfers
    localNetworkGameTransfers.openFirewall = true;
  };
  programs.partition-manager.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # GameMode
  # Add to game launch options in steam:
  # gamemoderun %command%
  programs.gamemode.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    usbutils

    # kde
    kdePackages.kcalc
    catppuccin-kde
    kdePackages.kate # text-editor
    kdePackages.kgpg
    kdePackages.merkuro # calendar
    kdePackages.francis # pomodoro
    kdePackages.koi # dark/light auto-switch
    kdePackages.okular # PDF viewer
    kdePackages.kontrast # color contrast
    kdePackages.calligra # office suite
    kdePackages.akonadi # contacts
    # clipboard
    wl-clipboard-rs

    # used to sign PDF by okular
    nss_latest
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [
      "hf.co/bartowski/zed-industries_zeta-GGUF:Q5_K_M"
      "qwen3:8b"
      "gemma3n:e4b"
      "hf.co/unsloth/Qwen3-8B-GGUF:Q4_K_XL"
      "hf.co/unsloth/Qwen3-14B-GGUF:Q4_K_XL"
      "hf.co/unsloth/medgemma-4b-it-GGUF:Q4_K_XL"
    ];
  };

  # Open ports in the firewall.
  networking.firewall = rec {
    allowedTCPPorts = [
      51413 # transmission
    ];
    allowedTCPPortRanges = [
      # KDE Connect
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = allowedTCPPortRanges;
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.nameservers = [ "1.1.1.1" ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  nix = {
    # Store optimization
    optimise = {
      automatic = true;
      dates = [ "13:00" ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [ "@wheel" ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # nixpkgs instance config
  nixpkgs = {
    config = {
      # Always allow unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
}
