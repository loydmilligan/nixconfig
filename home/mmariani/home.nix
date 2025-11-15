{ config, pkgs, ... }:

{
  home.username = "mmariani";
  home.homeDirectory = "/home/mmariani";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  # Packages
  home.packages = with pkgs; [
    # Development
    python312
    python312Packages.pip
    nodejs_20
    docker-compose
    
    # CLI tools
    eza
    bat
    ripgrep
    fd
    fzf
    jq
    
    # Terminal
    tmux
    
    # Nix dev tools
    direnv
    
    # Modern shell tools
    starship
    atuin
    zoxide
  ];

  # Git
  programs.git = {
    enable = true;
    userName = "loydmilligan";
    userEmail = "mattmarian2@protonmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };

  # Tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
    terminal = "screen-256color";
    extraConfig = ''
      set -g mouse on
      set -g history-limit 10000
    '';
  };

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Atuin
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "sha256-gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
    ];
    
    shellAliases = {
      # Eza aliases
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --header";
      la = "eza -la --icons --group-directories-first --header";
      lt = "eza --tree --icons --level=2";
      ltd = "eza --tree --icons --level=2 --only-dirs";
      l = "eza -lbF --git --icons";
      llm = "eza -lbGd --git --sort=modified";
      lls = "eza -lbhHigmuSa --time-style=long-iso --git --color-scale";
      
      # Git
      gd = "git diff";
      gcmsg = "git commit -m";
      gitc = "git checkout";
      
      # NixOS
      nrs = "sudo nixos-rebuild switch --flake .#nixos-dev";
      nrb = "sudo nixos-rebuild build --flake .#nixos-dev";
      nrt = "sudo nixos-rebuild test --flake .#nixos-dev";
    };
    
    initExtra = ''
      # Autosuggestion styling
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"
      
      # Starship prompt
      eval "$(starship init zsh)"
    '';
  };

  # Starship (Catppuccin Mocha theme)
  programs.starship = {
    enable = true;
    settings = {
      format = "$os$username$directory$git_branch$git_status$python$nodejs$rust$golang$docker$time$cmd_duration$line_break$character";
      
      palette = "catppuccin_mocha";
      
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
      
      os = {
        disabled = false;
        style = "bg:red fg:base";
        symbols.NixOS = " ";
      };
      
      username = {
        show_always = true;
        style_user = "bg:red fg:base";
        style_root = "bg:red fg:base";
        format = "[ $user ]($style)";
      };
      
      directory = {
        style = "bg:peach fg:base";
        format = "[ $path ]($style)";
        truncation_length = 3;
      };
      
      git_branch = {
        style = "bg:yellow fg:base";
        format = "[ $symbol$branch ]($style)";
        symbol = " ";
      };
      
      git_status = {
        style = "bg:yellow fg:base";
        format = "[$all_status$ahead_behind ]($style)";
      };
      
      python = {
        style = "bg:green fg:base";
        format = "[ $symbol$version ]($style)";
        symbol = " ";
      };
      
      nodejs = {
        style = "bg:green fg:base";
        format = "[ $symbol$version ]($style)";
        symbol = " ";
      };
      
      rust = {
        style = "bg:green fg:base";
        format = "[ $symbol$version ]($style)";
        symbol = " ";
      };
      
      golang = {
        style = "bg:green fg:base";
        format = "[ $symbol$version ]($style)";
        symbol = " ";
      };
      
      docker_context = {
        style = "bg:sapphire fg:base";
        format = "[ $symbol$context ]($style)";
        symbol = " ";
      };
      
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender fg:base";
        format = "[ ♥ $time ]($style)";
      };
      
      cmd_duration = {
        style = "fg:overlay2";
        format = "[ $duration ]($style)";
        min_time = 500;
      };
      
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
