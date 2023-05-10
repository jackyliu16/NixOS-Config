{ config, pkgs, lib, inputs, users, lib, ... }: {
  
  imports = [
    (import /etc/nixos/hardware-configuration.nix)
    # TODO fonts

  ];

  users.mutableUsers = false;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    packages = (with pkgs; [
      thunderbird
      # tdesktop
      # qq
    ]);
    # ]) ++ (with config.nur.repos; [
    # ]);
  };
  
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
        # thunderbird
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
