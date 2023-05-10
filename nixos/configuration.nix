# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: 

let 
  binutils = builtins.fetchTarball {
    # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
    url = "https://github.com/nix-community/NUR/archive/3a6a6f4da737da41e27922ce2cfacf68a109ebce.tar.gz";
    # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
    sha256 = "04387gzgl8y555b3lkz9aiw9xsldfg4zmzp930m62qw8zbrvrshd";
  };
in
{
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "jacky" ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ./services
    ./pkgs
  ];

  system.autoUpgrade.enable = true;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      packageOverrides = pkgs: {
        nur = import (binutils.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          inherit pkgs;
        };
      };
    };
  };

  nix = {

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    package = pkgs.nixFlakes;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      substituters = [ 
        "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=20"
        # "https://mirror.sjtu.edu.cn/nix-channels/store?priority=10"
        # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 
        # "https://nix-community.cachix.org?priority=50"
        # "https://cache.nixos.org/?priority=40"
      ];
      # trusted-public-keys = [
      #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      #   "cache.nixos.org:EEOzc3df4TjmU6aIsF7dIf2UWCHe+BcLywnFXYegnXr/mLGqr8oEWff51zqnSKhyldQ2RFWFPutJOQtn0hsbrA==%"
      #   "mirrors.tuna.tsinghua.edu.cn:HwH/zNjloL2N2xbsBIAh0hwZ3Mf8ZXzsWsk8A8cNjOwsQqMo4Q7kRWMeZ3IjmNmGD69ag49Xy46mP/liAONL+w==%"
      # ];
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

  boot.loader = {
    systemd-boot = {
      enable = true;
      extraEntries = {
        "UkyinUbuntu.conf" = ''
          title UkyinUbuntu
          efi /efi/ubuntu/shimx64.efi
        '';
      };
    };
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
  };

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  i18n = {
    # defaultLocale = "C.UTF-8";
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-rime 
        fcitx5-chinese-addons 
        fcitx5-table-extra 
      ];
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      noto-fonts
      source-han-sans
      source-han-serif
      source-code-pro
      hack-font
      jetbrains-mono
    ];
  };
  
         
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  users.users = {
    jacky = {
      # NOTE: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # NOTE: Add your SSH public key(s) here, if you plan on using SSH to connect
	      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD5Rf2rSlpYwc+euAnZG6RB2mBNkrfApMIf+yGVT9GFotnvVHyejn+X/7Lw1VTy9IcajXd2MbGvxrwHcVqPfe0wt7GrEcEkhPyeooUXfq+i7WY03ClOHai7uNwbotfqra9wtTRJ8gzmXTq5Q3CaMyHwY7SymK6DdWnpCeVvszzasaqcF3nYdhFVfjLm7gbCB2P+6VNE6dXEkNtihrK3NTcPbZ/yCF16QJg7ePKDbu4/GEMUtFuF0fJL6kUgDYI7NlhQvGnAREfa7tHPrJZR1sqnpg7BVunUC79IwxxZHEEWokU0bOHozOm/6n4rg9b8JPw8AFsU7ZtC4bihg2XcjlF0/nxpPOmgbRrPHYvLWdWxtbMiuCYVKrNUNG2IBrq3T8m/acmDyFOCzN3TOW60XMKzBcPxe5vCssbRG8sKihKeh/1byP8HCvwqFkTbPZMwpq3ploHbCsVw/KDOk7dwvYyM1JS09kBJjnaV2r6owrNKVS8Su4sLC8lXOnEh5VgWm0= 18922251299@163.com"
      ];
      # Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "wheel" ];
      packages = (with pkgs; [
	      # GUI Programs
	      libsForQt5.ark
	      zotero
        thunderbird
        gparted

        # Shell Programs
	      coreutils-prefixed
	      clash
        zola
        sshfs
      ]) ++ (with pkgs.unstable; [
        realvnc-vnc-viewer
      ]);
    };
  };

}
