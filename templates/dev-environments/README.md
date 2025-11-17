# Development Environment Templates

Templates for setting up Nix-based development environments with direnv.

## Next.js Template

For Next.js/TypeScript projects with SQLite support (like idealisted).

### Setup Instructions

1. **Copy flake.nix to your project:**
   ```bash
   cp ~/nixconfig/templates/dev-environments/nextjs-flake.nix ~/Projects/your-project/flake.nix
   ```

2. **Copy .envrc to your project:**
   ```bash
   cp ~/nixconfig/templates/dev-environments/nextjs-envrc ~/Projects/your-project/.envrc
   ```

3. **Allow direnv:**
   ```bash
   cd ~/Projects/your-project
   direnv allow
   ```

4. **Wait for environment to build** (first time takes a few minutes, then cached)

5. **Install dependencies:**
   ```bash
   npm install
   ```

6. **Create .env.local for secrets** (never commit this):
   ```bash
   cat > .env.local << 'EOF'
   OPENAI_API_KEY=your-key-here
   # Add other secrets here
   EOF
   ```

7. **Add to .gitignore:**
   ```bash
   echo ".env.local" >> .gitignore
   echo ".envrc.cache" >> .gitignore
   echo ".direnv/" >> .gitignore
   ```

8. **Start development:**
   ```bash
   npm run dev
   ```

### What This Provides

- ✅ Node.js 20
- ✅ npm package manager
- ✅ Build tools for native modules (better-sqlite3, canvas, etc.)
- ✅ Python 3 for node-gyp
- ✅ Auto-loading environment on directory change
- ✅ Cached for instant subsequent loads
- ✅ Isolated from system packages

### Customization

Edit `flake.nix` to add more packages to `buildInputs`:
- PostgreSQL: `postgresql`
- Redis: `redis`
- Docker: already available system-wide
- Additional Node versions: `nodejs_18`, `nodejs_22`

### Troubleshooting

**"direnv: error .envrc is blocked"**
- Run: `direnv allow`

**"npm install fails with build errors"**
- Make sure direnv loaded (you should see the shellHook message)
- Try: `npm rebuild` after direnv loads

**"Environment takes forever to load"**
- First time builds the environment (can take 2-5 minutes)
- Subsequent loads are instant (cached by nix-direnv)
- If rebuilding often, check `watch_file` isn't watching too many files
