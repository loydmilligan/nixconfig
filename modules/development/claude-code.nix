{ config, lib, pkgs, ... }:

with lib;

{
  options.development.claude-code = {
    enable = mkEnableOption "Claude Code CLI and development environment";
  };

  config = mkIf config.development.claude-code.enable {
    # ============================================================================
    # Claude Code Installation
    # ============================================================================
    #
    # Claude Code (@anthropic-ai/claude-code) does not yet have an official
    # Nix package in nixpkgs. As a result, we install it imperatively via npm
    # after the initial system setup.
    #
    # Installation workflow:
    #   1. System rebuild installs npm and creates helper aliases
    #   2. User runs: install-claude-code
    #   3. User authenticates: claude-code auth login
    #
    # The claude-code binary will be available globally after installation.
    #
    # ============================================================================

    environment.systemPackages = with pkgs; [
      # ------------------------------------------------------------------------
      # Node.js Package Manager
      # ------------------------------------------------------------------------
      # npm is required for installing Claude Code globally
      nodePackages.npm
    ];

    # ============================================================================
    # Shell Aliases for Claude Code Management
    # ============================================================================

    environment.shellAliases = {
      # Install Claude Code globally via npm
      install-claude-code = "npm install -g @anthropic-ai/claude-code";

      # Update Claude Code to the latest version
      update-claude-code = "npm update -g @anthropic-ai/claude-code";
    };

    # ============================================================================
    # Post-Installation Steps
    # ============================================================================
    #
    # After rebuilding your system configuration, complete the Claude Code setup:
    #
    # 1. Install Claude Code:
    #    $ install-claude-code
    #
    # 2. Authenticate with your Anthropic account:
    #    $ claude-code auth login
    #
    # 3. Verify installation:
    #    $ claude-code --version
    #
    # 4. Start using Claude Code in any project directory:
    #    $ claude-code
    #
    # To update Claude Code to the latest version in the future:
    #    $ update-claude-code
    #
    # ============================================================================
  };
}
