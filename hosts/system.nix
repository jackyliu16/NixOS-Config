{ config, pkgs, lib, inputs, user, ... }:

{
  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "nixos"; # Define your hostname.
    networkmanager.enable = true;
    hosts = {
      "185.199.109.133" = [ "raw.githubusercontent.com" ];
      "185.199.111.133" = [ "raw.githubusercontent.com" ];
      "185.199.110.133" = [ "raw.githubusercontent.com" ];
      "185.199.108.133" = [ "raw.githubusercontent.com" ];
    };
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  
  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      # Basical 
      git
      wget curl
      p7zip unzip zip rar tar

      # Terminal Programs
      neofetch
      gdb
      pciutils # cudatoolkit
      nodejs_18

      # Complie
      gcc clang

      # ruixi_rebirth:  git neovim wget neofetch exa gcc clang cargo zig p7zip atool unzip ranger ffmpeg ffmpegthumbnailer glib xdg-utils pciutils gdb killall nodejs socat zip rar frp sops
    ];
  };
  
  services.dbus.enable = true;

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    package = pkgs.nixFlakes;
    settings = {
      substitutes = [
        "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=20"
      ];
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than-7d";
      dates = "weekly";
    };
  };
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";
}

