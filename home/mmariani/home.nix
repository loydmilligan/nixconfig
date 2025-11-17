{ config, pkgs, pkgs-unstable, ... }:

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
    home-manager
    jq
    
    # LSP servers (for neovim)
    pyright                              # Python
    nodePackages.typescript-language-server  # TypeScript/JS
    nil                                  # Nix
    lua-language-server                  # Lua (for editing nvim config!)
   
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
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
    };
  };
  programs.neovim = {
    package = pkgs-unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      plenary-nvim
      nvim-web-devicons
      (nvim-treesitter.withAllGrammars)
    ];
  
    extraLuaConfig = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
    
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = false
      vim.opt.termguicolors = true
      vim.opt.mouse = "a"
      vim.opt.cursorline = true
      vim.opt.signcolumn = "yes"
    
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git", "clone", "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)
    
      require("lazy").setup({
        {
          "catppuccin/nvim",
          name = "catppuccin",
          priority = 1000,
          config = function()
            require("catppuccin").setup({
              flavour = "mocha",
            })
            vim.cmd.colorscheme("catppuccin")
          end,
        },
      
        {
          "nvim-telescope/telescope.nvim",
          dependencies = { "nvim-lua/plenary.nvim" },
          keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
          },
        },
      
        {
          "nvim-tree/nvim-tree.lua",
          keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Tree" },
          },
          config = function()
            require("nvim-tree").setup()
          end,
        },
      
        {
          "nvim-lualine/lualine.nvim",
          config = function()
            require("lualine").setup({
              options = { theme = "catppuccin" }
            })
          end,
        },
      
        {
          "hrsh7th/nvim-cmp",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
          },
          config = function()
            local cmp = require("cmp")
            cmp.setup({
              snippet = {
                expand = function(args)
                  require("luasnip").lsp_expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping.select_next_item(),
                ["<S-Tab>"] = cmp.mapping.select_prev_item(),
              }),
              sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
              },
            })
          end,
        },
        {
          "neovim/nvim-lspconfig",
          config = function()
            -- Use new vim.lsp.config API (nvim 0.11+)
            vim.lsp.config.pyright = {}
            vim.lsp.config.ts_ls = {}
            vim.lsp.config.nil_ls = {}
    
            -- Enable the LSP servers
            vim.lsp.enable('pyright')
            vim.lsp.enable('ts_ls')
            vim.lsp.enable('nil_ls')
    
            -- LSP Keybindings
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local opts = { buffer = args.buf }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
              end,
            })
          end,
        },     
      })
    '';
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
  
      # Git shortcuts
      gd = "git diff";
      gcmsg = "git commit -m";
      gitc = "git checkout";
  
      # NixOS system rebuilds
      nrs = "cd ~/nixconfig && sudo nixos-rebuild switch --flake .#nixos-dev";
      nrb = "cd ~/nixconfig && sudo nixos-rebuild build --flake .#nixos-dev";
      nrt = "cd ~/nixconfig && sudo nixos-rebuild test --flake .#nixos-dev";
  
      # Home Manager rebuilds
      hms = "cd ~/nixconfig && sudo nixos-rebuild switch --flake .#nixos-dev";
      hmb = "cd ~/nixconfig && sudo nixos-rebuild build --flake .#nixos-dev";
  
      # Combined rebuild
      rebuild = "cd ~/nixconfig && sudo nixos-rebuild switch --flake .#nixos-dev && home-manager switch --flake .#mmariani";
  
      # Nix utilities
      ngc = "sudo nix-collect-garbage -d";
      nfu = "cd ~/nixconfig && nix flake update";
  
      # Quick config editing
      nconf = "cd ~/nixconfig && nvim .";
      nhome = "nvim ~/nixconfig/home/mmariani/home.nix";
      nsys = "nvim ~/nixconfig/hosts/proxmox-dev/configuration.nix";
  
      # Git workflow
      cfgs = "cd ~/nixconfig && git status";
      cfgp = "cd ~/nixconfig && git push";
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
