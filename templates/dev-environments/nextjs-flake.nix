{
  description = "Next.js development environment with SQLite support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js and npm
            nodejs_20

            # Build tools for native Node modules (better-sqlite3, etc.)
            gcc
            gnumake
            pkg-config
            python3  # Required for node-gyp

            # Development tools
            git
          ];

          shellHook = ''
            echo "🚀 Next.js development environment loaded!"
            echo ""
            echo "Node.js: $(node --version)"
            echo "npm: $(npm --version)"
            echo ""
            echo "📦 Run 'npm install' to install dependencies"
            echo "🔧 Run 'npm run dev' to start development server"
            echo ""
          '';
        };
      }
    );
}
