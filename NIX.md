# Nix Development Environment

This document explains how to use Nix for a reproducible development environment.

## What is Nix?

Nix is a package manager that provides:
- **Reproducible builds**: Same environment on any machine
- **Declarative configuration**: All dependencies in one file
- **Isolation**: Project dependencies don't conflict with system packages
- **No Docker needed**: All tools available natively

## Quick Start

### 1. Install Nix

If you don't have Nix installed:

```bash
# Recommended: Determinate Systems installer (with flakes enabled by default)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Alternative: Official installer
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### 2. Enable Flakes (if using official installer)

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Enter Development Environment

```bash
cd hasura-blog

# Option 1: Manual
nix develop

# Option 2: Using direnv (recommended)
# Install direnv first
nix-env -iA nixpkgs.direnv

# Then
direnv allow
```

### 4. Start Developing

Once in the Nix shell, all tools are available:

```bash
# Check available tools
node --version
npm --version
docker --version
hasura version
psql --version

# Start development
npm install
docker-compose -f docker-compose.dev.yml up -d
npm run dev
```

## What's Included?

The Nix environment provides:

- **Node.js 20**: JavaScript runtime
- **npm**: Package manager
- **Docker**: Container runtime
- **Docker Compose**: Multi-container orchestration
- **Hasura CLI**: Database migrations and metadata management
- **PostgreSQL 15 client**: Database CLI tools
- **Git**: Version control
- **Make**: Build automation
- **curl**: HTTP client
- **jq**: JSON processor

## Configuration Files

### flake.nix

The main configuration file for Nix flakes:
- Defines all dependencies
- Sets up environment variables
- Configures the development shell

### shell.nix

Legacy Nix configuration for backwards compatibility:
- Same dependencies as flake.nix
- Works with older Nix versions
- Can be used with `nix-shell` command

### .envrc

Direnv configuration for automatic environment loading:
- Automatically loads Nix environment when entering directory
- No need to manually run `nix develop`
- Recommended for daily development

## Using Direnv (Recommended)

Direnv automatically loads the Nix environment when you `cd` into the project:

### Install direnv

```bash
# Using Nix
nix-env -iA nixpkgs.direnv

# Or using your system package manager
# macOS: brew install direnv
# Ubuntu: apt install direnv
```

### Configure your shell

Add to your shell RC file (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
eval "$(direnv hook bash)"  # or zsh, fish, etc.
```

### Allow the project

```bash
cd hasura-blog
direnv allow
```

Now the environment loads automatically!

## Commands

### With Flakes (Modern)

```bash
# Enter development shell
nix develop

# Run a command in the shell
nix develop -c npm install

# Update dependencies
nix flake update
```

### With shell.nix (Legacy)

```bash
# Enter development shell
nix-shell

# Run a command in the shell
nix-shell --run "npm install"
```

## Customizing the Environment

### Adding New Packages

Edit `flake.nix` and add packages to `buildInputs`:

```nix
buildInputs = with pkgs; [
  nodejs_20
  docker
  # Add more packages here
  vim
  tmux
];
```

Then reload the environment:

```bash
# With direnv
direnv reload

# Or manually
exit
nix develop
```

### Adding Environment Variables

Edit the `shellHook` section in `flake.nix`:

```nix
shellHook = ''
  echo "Custom environment loaded"
  export MY_VAR="my_value"
'';
```

## Advantages

### vs Docker

- **Native Performance**: No virtualization overhead
- **Better IDE Integration**: Tools run natively
- **Faster Startup**: No container boot time
- **Direct File Access**: No volume mounting issues

### vs Manual Installation

- **Reproducible**: Same environment everywhere
- **Version Locked**: No "works on my machine"
- **Clean Uninstall**: No system pollution
- **Multiple Projects**: Different versions per project

## CI/CD Integration

You can use the same Nix environment in CI:

### GitHub Actions

```yaml
- uses: DeterminateSystems/nix-installer-action@main
- uses: DeterminateSystems/magic-nix-cache-action@main
- name: Build
  run: nix develop -c npm run build
```

### GitLab CI

```yaml
image: nixos/nix:latest
before_script:
  - nix develop -c npm install
script:
  - nix develop -c npm run build
```

## Troubleshooting

### "Experimental features not enabled"

Enable flakes in your Nix config:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### "Cannot connect to Docker daemon"

Docker must be running on your host system. Nix provides the Docker CLI, but you need Docker Desktop or Docker daemon running.

### Slow first load

The first time you run `nix develop`, it downloads all dependencies. Subsequent runs are instant as everything is cached.

### Clean rebuild

```bash
# Remove build artifacts
rm -rf .direnv result

# Rebuild
nix develop
```

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Direnv](https://direnv.net/)
- [Zero to Nix](https://zero-to-nix.com/)

## Tips

1. **Use direnv**: Makes environment loading seamless
2. **Pin versions**: Nix ensures reproducibility
3. **Share configs**: Commit flake.lock for exact reproducibility
4. **Use in CI**: Same environment in development and CI
5. **Cache builds**: Use [Cachix](https://cachix.org/) for faster rebuilds
