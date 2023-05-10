{ inputs, outputs, config, pkgs ? import <nixpkgs> {} , lib, ... }:

let 
  # shell color: diff typr of file will have diff color
  # b = pkgs.callPackage ./src/b {};
  LS_COLORS = pkgs.fetchgit {
    url = "https://github.com/trapd00r/LS_COLORS";
    rev = "09dab448207002624d17f01ed7cbf820aa048063";
    sha256 = "sha256-hQTT/yNS9UIDZqHuul0xmknnOh6tOtfotQIm0SY5TTE=";
  };
  ls-colors = pkgs.runCommand "ls-colors" { } ''
    mkdir -p $out/bin $out/share
    ln -s ${pkgs.coreutils}/bin/ls          $out/bin/ls
    ln -s ${pkgs.coreutils}/bin/dircolors   $out/bin/dircolors
    cp ${LS_COLORS}/LS_COLORS               $out/share/LS_COLORS
  '';
  minidev = pkgs.callPackage ./src/minidev {};
  user = "jacky";
  my-python-packages = p: with p; [
    pandas
    matplotlib
    pylint
    rarfile
  ];
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.sessionVariables = rec {
    XDG_CACHE_HOME  = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME    = "\${HOME}/.local/bin";
    XDG_DATA_HOME   = "\${HOME}/.local/share";
  };
  home.stateVersion = "22.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
   #  ./src/zsh.nix
   #  ./src/tmux.nix
   #  ./vimAndNeovim/nixvim.nix
  ];

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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages = (with pkgs; [
    (pkgs.writeScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
    # (vscode-with-extensions.override {
    #   vscodeExtensions = with vscode-extensions; [
    #     bbenoist.nix
    #     vscodevim.vim
    #     jnoortheen.nix-ide
    #     ms-vscode-remote.remote-ssh
    #     davidanson.vscode-markdownlint
    #     valentjn.vscode-ltex
    #     donjayamanne.githistory
    #     mhutchie.git-graph
    #     ms-vscode.cpptools
    #     # vscode-extensions.wakatime.vscode-wakatime
    #     ms-python.python
    #     ms-pyright.pyright
    #     njpwerner.autodocstring
    #   ];
    # })
    vscode
    # nerdfonts
    # font-awesome
    # powerline-fonts
    # Basical 
    tldr
    ripgrep   # search the content of the file in a directory
    tmux      # terminal split screen
    tree      # show the directory structure as a tree
    jq        # ?
    fzf       # everything
    rnix-lsp  # lsp support of nix
    htop      # colorful top
    ranger    # file management
    xclip     # using for neovim clipboard
    zola      # blog

    # Coding 
    gnumake
    clang
    (python310.withPackages my-python-packages)
    wsl-open

    # personal packages
    ls-colors
    minidev
  ]) ++ ( with pkgs.unstable; [
    # nix development
    nix-init
  ]);

  fonts.fontconfig.enable = true;

  # config: vim and neovim
  programs = {
    vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ 
        # language support
        vim-lsp
        # asyncomplete-vim
        # jedi-vim
        vim-nix
        rust-vim
        vim-toml
        # YouCompleteMe   # 自动补全

        # UI
        vim-gitgutter   # status in gitter
        vim-airline     # vim-devicons
        (nvim-treesitter.withPlugins (p: [ p.c p.java p.rust p.python p.go ]))
        vim-bufferline  # 标签页
        nvim-gdb
        
        ## colocscheme
        gruvbox
        vim-devicons    

        # Tools
        auto-pairs
        LeaderF         # 模糊查找
        nerdcommenter   # 多行注释支持
        Vundle-vim      # plug-in manager for Vim
        # lightline     # tabline customization
        vim-startify    # 最近打开的文件
        vim-fugitive    # Git Support

        # NERDTree
        nerdtree
        vim-nerdtree-tabs
        vim-nerdtree-syntax-highlight
        nerdtree-git-plugin
      ];
      extraConfig = builtins.readFile ./vimAndNeovim/vimExtraConfig;
    };
  };


  # terminal 
  programs = {
    bat = {
      enable = true;
      config = {
        # theme = "ansi-dark";
        theme = "base16-256";
      };
    };
    command-not-found.enable = true;
  };
}
