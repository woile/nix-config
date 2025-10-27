{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    usbutils
    # clipboard
    wl-clipboard-rs
    # used to sign PDF by okular
    nss_latest
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.nix-ld = {
    enable = true;
  };

  programs.partition-manager.enable = true;

  programs.bandwhich.enable = true;
  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp2s0";

  # automatic timezone
  services.automatic-timezoned.enable = true;
  services.geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.cups-pdf.enable = false;
  services.printing.cups-pdf.instances = {
    pdf = {
      settings = {
        Out = "\${HOME}/pdf-printed";
        UserUMask = "0033";
      };
    };
  };

  # disable pulseaudio
  services.pulseaudio.enable = false;
  # Enable sound with pipewire.
  security.rtkit.enable = true; # for performance
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
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.rsyncd.enable = true;

  services.ollama = {
    enable = true;
    loadModels = [
      "qwen3:8b"
      "gemma3n:e4b"
    ];
  };
  services.flatpak.enable = true;

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
  networking.nameservers = [ "1.1.1.1" ];

  virtualisation.docker = {
    # Consider disabling the system wide Docker daemon
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
      # Optionally customize rootless Docker daemon settings
      daemon.settings = {
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };
  };

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
        "https://reciperium.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "reciperium.cachix.org-1:xAmT5McauMNqMlXkkyVzDzoDNO6G+Zo7gCAUYaPsGxQ="
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
