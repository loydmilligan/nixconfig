{ config, lib, pkgs, ... }:

with lib;

{
  options.development.tools = {
    enable = mkEnableOption "development tools and environments";
  };

  config = mkIf config.development.tools.enable {
    # ============================================================================
    # Development Tools Package Installation
    # ============================================================================

    environment.systemPackages = with pkgs; [
      # ------------------------------------------------------------------------
      # Python Development (3.12)
      # ------------------------------------------------------------------------
      # Python 3.12 with standard library and pip
      python312
      python312Packages.pip
      python312Packages.virtualenv
      # uv: Fast Python package installer and resolver (Rust-based)
      uv

      # ------------------------------------------------------------------------
      # Node.js Development (v20)
      # ------------------------------------------------------------------------
      # Node.js 20 LTS with npm
      nodejs_20
      # Alternative package managers
      nodePackages.pnpm  # Fast, disk-efficient package manager
      nodePackages.yarn  # Classic package manager

      # ------------------------------------------------------------------------
      # Rust Development
      # ------------------------------------------------------------------------
      # Rust compiler and package manager
      rustc   # Rust compiler
      cargo   # Rust package manager and build tool

      # ------------------------------------------------------------------------
      # Essential Development Tools
      # ------------------------------------------------------------------------
      # direnv: Load/unload environment variables based on directory
      direnv
      # nix-direnv: Fast direnv integration for Nix
      nix-direnv

      # Modern replacements for classic Unix tools
      ripgrep  # rg: Fast recursive grep alternative (Rust)
      fd       # Fast find alternative (Rust)
      bat      # Cat clone with syntax highlighting (Rust)
      eza      # Modern ls replacement (Rust)

      # Command-line utilities
      fzf      # Fuzzy finder for command-line
      jq       # JSON processor and query tool

      # ------------------------------------------------------------------------
      # Git Helpers and Tools
      # ------------------------------------------------------------------------
      gh        # GitHub CLI - interact with GitHub from terminal
      lazygit   # Terminal UI for git commands
      delta     # Syntax-highlighting pager for git diff

      # ------------------------------------------------------------------------
      # Build Tools and Compilers
      # ------------------------------------------------------------------------
      gcc        # GNU Compiler Collection (C/C++)
      gnumake    # GNU Make build automation tool
      pkg-config # Helper tool for compiling applications and libraries
    ];

    # ============================================================================
    # Direnv Configuration with Nix Integration
    # ============================================================================

    # Enable direnv system-wide for automatic environment loading
    programs.direnv = {
      enable = true;

      # Enable nix-direnv for faster and more reliable Nix integration
      # This caches environment builds and provides better performance
      nix-direnv.enable = true;

      # Silent mode: don't print direnv output on every directory change
      silent = false;
    };

    # ============================================================================
    # Git Configuration for Better Diff Output
    # ============================================================================

    # Configure git to use delta as the default pager for better diffs
    programs.git = {
      enable = true;

      config = {
        core = {
          # Use delta for git diff/log/show/blame
          pager = "delta";
        };

        interactive = {
          # Use delta for interactive commands like git add -p
          diffFilter = "delta --color-only";
        };

        delta = {
          # Delta configuration for enhanced diff viewing
          navigate = true;     # Use n/N to move between diff sections
          light = false;       # Use dark theme (set to true for light terminals)
          line-numbers = true; # Show line numbers
          side-by-side = false; # Use unified diff by default
        };

        merge = {
          # Show conflict style with base, ours, and theirs
          conflictstyle = "diff3";
        };

        diff = {
          # Use delta's algorithm for better diff quality
          colorMoved = "default";
        };
      };
    };

    # ============================================================================
    # Environment Variables
    # ============================================================================

    environment.variables = {
      # Inform direnv to use nix-direnv for .envrc files
      # This ensures better caching and performance
      NIX_DIRENV_ENABLED = "1";
    };

    # ============================================================================
    # Shell Integration Hints
    # ============================================================================

    # Note: For full direnv integration, users should add the following to their
    # shell configuration:
    #
    # For bash (~/.bashrc):
    #   eval "$(direnv hook bash)"
    #
    # For zsh (~/.zshrc):
    #   eval "$(direnv hook zsh)"
    #
    # For fish (~/.config/fish/config.fish):
    #   direnv hook fish | source
    #
    # This is typically handled by home-manager in the user's home.nix file.
  };
}
