# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ../../hardware/aistone/x4sp4nal/hardware-configuration.nix

    ../../users/woile/user.nix

    ../../profiles/laptop
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackagesFor (
    pkgs.linux_latest.override {
      argsOverride = rec {
        version = "7.0.6";
        modDirVersion = "7.0.6";
        src = pkgs.fetchurl {
          url = "mirror://kernel/linux/kernel/v7.x/linux-${version}.tar.xz";
          sha256 = "08vm18wx6399phzgr3wz94yga3ab4fyca79445ygvbspm904996b";
        };
      };
    }
  );
  networking.hostName = "aconcagua"; # Define your hostname.
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
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Virtualisation
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  environment.systemPackages = with pkgs; [
    inputs.temporis.packages.${stdenv.hostPlatform.system}.temporis-desktop
    inputs.agenix.packages.${stdenv.hostPlatform.system}.agenix
    # security
    age
    age-plugin-tpm
    tpm2-tools # Useful for debugging
  ];

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  services.llama-cpp = {
    enable = true;

    package = pkgs.llama-cpp-vulkan;
    # package =
    #   with pkgs;
    # (llama-cpp-rocm.overrideAttrs (oldAttrs: {
    #   DGFX_VERSION = "11.5.0";
    #   # FORCE_REBUILD = builtins.currentTime;
    #   # Adding a dummy attribute forces a local build
    #   passthru = (oldAttrs.passthru or { }) // {
    #     forceRebuild = 1;
    #   };
    # }));
    port = 8093;
    openFirewall = true;
    modelsPreset = {
      # TODO: Keep
      # - nemotron
      "medgemma-1.5-4b-it" = {
        hf-repo = "unsloth/medgemma-1.5-4b-it-GGUF";
        hf-file = "medgemma-1.5-4b-it-UD-Q8_K_XL.gguf";
        alias = "unsloth/medgemma-1.5-4b-it";
        fa = true;
        ctx-size = "131072"; # 128K
        temp = "0.0";
        jinja = true;
        special = true;
        # chat-template = "chatml";
        # <unused95>
        # reasoning-format = "deepseek";
      };
      "gemma-4-26B-A4B" = {
        hf-repo = "unsloth/gemma-4-26B-A4B-it-GGUF";
        hf-file = "gemma-4-26B-A4B-it-UD-Q8_K_XL.gguf";
        alias = "unsloth/gemma-4-26B-A4B-it";
        ctx-size = "268288"; # 262K
        temp = "1.0";
        top-p = "0.95";
        top-k = "64";
      };
      "translategemma-12b" = {
        hf-repo = "bullerwins/translategemma-12b-it-GGUF";
        hf-file = "translategemma-12b-it-Q8_0.gguf";
        alias = "bullerwins/translategemma-12b-it";
        ctx-size = "2048"; # 2K
        temp = "1.0";
        top-p = "0.95";
        top-k = "64";
      };

      "Qwen3.6-35B-A3B" = {
        hf-repo = "unsloth/Qwen3.6-35B-A3B-GGUF";
        hf-file = "Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf";
        alias = "unsloth/Qwen3.6-35B-A3B";
        temp = "1.0";
        top-p = "0.95";
        top-k = "20";
        min-p = "0.0";
        presence-penalty = "0.0";
        repeat-penalty = "1.0";
        ctx-size = "90112";
      };
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        alias = "unsloth/Qwen3-Coder-Next";
        temp = "1.0";
        top-p = "0.95";
        top-k = "40";
        ctx-size = "65536";
      };
      "sweep-next-edit" = {
        hf-repo = "sweepai/sweep-next-edit-1.5B";
        hf-file = "sweep-next-edit-1.5b.q8_0.v2.gguf";
        alias = "sweepai/sweep-next-edit-1.5B";
        ctx-size = "8192";
      };
    };
  };
  systemd.services.llama-cpp = {
    environment = {
      # 1. Direct the Vulkan driver to use systemd's pre-created writable cache
      XDG_CACHE_HOME = "/var/cache/llama-cpp";
      MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp";
    };
  };
  # services.ollama.acceleration = "rocm";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Ensure the TPM2 resource manager daemon is running
  security.tpm2.enable = true;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.01"; # Did you read the comment?

}
