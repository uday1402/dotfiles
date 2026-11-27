#!/usr/bin/env bash
# Zero-to-ready WSL2 / Ubuntu-Debian dotfiles bootstrap & GNU Stow installer.
# Safe to run from any working directory and idempotent across re-runs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Defaults & package layout (must stay aligned with README.md / dotfiles)
# ---------------------------------------------------------------------------
CONFIGS_ONLY=false
DRY_RUN=false
SKIP_NVIM_SYNC=false
SKIP_CHSH=false
TARGET_HOME="${HOME}"

readonly -a NO_FOLD_PACKAGES=(zsh git tmux starship vim readline btop gh)
readonly -a FOLD_PACKAGES=(nvim)

readonly -a CORE_APT_PACKAGES=(
  git curl wget unzip zip tar gzip
  build-essential cmake pkg-config ca-certificates gnupg fontconfig
  zsh zsh-autosuggestions zsh-syntax-highlighting
  tmux stow fzf ripgrep fd-find zoxide jq tree btop htop xclip gh vim
  python3 python3-pip python3-venv pipx
  ffmpeg poppler-utils imagemagick
)

# Runtime state
HAS_APT=false
IS_WSL=false
OS_DESC="Unknown"
ARCH_RAW=""
ARCH_DEB=""
NVIM_ARCH=""
LAZYGIT_ARCH=""
YAZI_TRIPLE=""
WORK_TMPDIR=""
BACKUP_DIR=""
declare -a BACKED_UP_ITEMS=()

# ---------------------------------------------------------------------------
# Logging & utility helpers
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_BLUE=$'\033[34m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'
  C_CYAN=$'\033[36m'
else
  C_RESET="" C_BOLD="" C_BLUE="" C_GREEN="" C_YELLOW="" C_RED="" C_CYAN=""
fi

log_info() { printf '%s[INFO]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
log_ok()   { printf '%s[OK]%s   %s\n' "$C_GREEN" "$C_RESET" "$*"; }
log_warn() { printf '%s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
log_dry()  { printf '%s[DRY]%s  %s\n' "$C_CYAN" "$C_RESET" "$*"; }
log_err()  { printf '%s[ERR]%s  %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()      { log_err "$*"; exit 1; }

cleanup() {
  if [[ -n "$WORK_TMPDIR" && -d "$WORK_TMPDIR" ]]; then
    rm -rf "$WORK_TMPDIR"
  fi
}
trap cleanup EXIT

ensure_tmpdir() {
  if [[ -z "$WORK_TMPDIR" ]]; then
    WORK_TMPDIR="$(mktemp -d)"
  fi
  printf '%s\n' "$WORK_TMPDIR"
}

run_priv() {
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would run privileged: $*"
    return 0
  fi
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

prepend_path() {
  local dir="$1"
  [[ -n "$dir" ]] || return 0
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
  esac
}

# Return 0 if version $1 >= $2 (numeric dot-separated semver, strips leading v and suffixes)
version_ge() {
  local v1="${1#v}" v2="${2#v}"
  v1="${v1%%[-+]*}"
  v2="${v2%%[-+]*}"
  local IFS=.
  local -a a1=() a2=()
  read -ra a1 <<<"$v1"
  read -ra a2 <<<"$v2"
  local len=${#a1[@]}
  (( ${#a2[@]} > len )) && len=${#a2[@]}
  local i n1 n2
  for ((i = 0; i < len; i++)); do
    n1="${a1[i]:-0}"
    n2="${a2[i]:-0}"
    n1="${n1//[^0-9]/}"
    n2="${n2//[^0-9]/}"
    n1="${n1:-0}"
    n2="${n2:-0}"
    if (( 10#$n1 > 10#$n2 )); then
      return 0
    elif (( 10#$n1 < 10#$n2 )); then
      return 1
    fi
  done
  return 0
}

# ---------------------------------------------------------------------------
# CLI usage & argument parsing
# ---------------------------------------------------------------------------
usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS]

Zero-to-ready WSL2 / Ubuntu-Debian dotfiles bootstrap and GNU Stow installer.
May be invoked from any working directory.

Options:
  --configs-only, --stow-only
                    Skip package, binary, plugin installs and chsh; only ensure
                    parent directories, create the fd symlink if fdfind exists,
                    back up conflicting targets, and stow config packages.
  --dry-run         Print every action without modifying the filesystem,
                    creating backup directories, or invoking sudo.
  --skip-nvim-sync  Skip headless Neovim (+Lazy! sync) plugin bootstrap.
  --skip-chsh       Skip changing the default login shell to zsh.
  --target DIR      Target home directory to stow into (default: $HOME).
  -h, --help        Show this help message and exit.
EOF
}

normalize_target_home() {
  if [[ -z "$TARGET_HOME" ]]; then
    die "--target directory cannot be empty"
  fi
  if [[ "$TARGET_HOME" != "/" ]]; then
    TARGET_HOME="${TARGET_HOME%/}"
  fi
  if [[ -e "$TARGET_HOME" && ! -d "$TARGET_HOME" ]]; then
    die "Target path exists and is not a directory: $TARGET_HOME"
  fi
  if [[ -d "$TARGET_HOME" ]]; then
    TARGET_HOME="$(cd "$TARGET_HOME" && pwd)"
  elif [[ "$DRY_RUN" == true ]]; then
    log_dry "Target directory does not exist yet (would create): $TARGET_HOME"
  else
    mkdir -p "$TARGET_HOME"
    TARGET_HOME="$(cd "$TARGET_HOME" && pwd)"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --configs-only|--stow-only)
        CONFIGS_ONLY=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --skip-nvim-sync)
        SKIP_NVIM_SYNC=true
        shift
        ;;
      --skip-chsh)
        SKIP_CHSH=true
        shift
        ;;
      --target)
        [[ $# -ge 2 && -n "$2" ]] || die "Option --target requires a directory argument"
        TARGET_HOME="$2"
        shift 2
        ;;
      --target=*)
        TARGET_HOME="${1#*=}"
        [[ -n "$TARGET_HOME" ]] || die "Option --target=DIR requires a non-empty directory"
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log_err "Unknown option: $1"
        usage >&2
        exit 1
        ;;
    esac
  done

  normalize_target_home
  prepend_path "/usr/local/bin"
  prepend_path "$TARGET_HOME/.local/bin"
  prepend_path "$TARGET_HOME/.npm-global/bin"
  export PATH
}

# ---------------------------------------------------------------------------
# Environment detection
# ---------------------------------------------------------------------------
detect_environment() {
  if [[ -r /etc/os-release ]]; then
    OS_DESC="$(awk -F= '/^PRETTY_NAME=/ { gsub(/^"|"$/, "", $2); print $2; exit }' /etc/os-release)"
    [[ -n "$OS_DESC" ]] || OS_DESC="$(uname -s)"
  else
    OS_DESC="$(uname -s)"
  fi

  if command -v apt-get &>/dev/null; then
    HAS_APT=true
  fi

  ARCH_RAW="$(uname -m)"
  case "$ARCH_RAW" in
    x86_64|amd64)
      ARCH_DEB="amd64"
      NVIM_ARCH="x86_64"
      LAZYGIT_ARCH="x86_64"
      YAZI_TRIPLE="x86_64-unknown-linux-gnu"
      ;;
    aarch64|arm64)
      ARCH_DEB="arm64"
      NVIM_ARCH="arm64"
      LAZYGIT_ARCH="arm64"
      YAZI_TRIPLE="aarch64-unknown-linux-gnu"
      ;;
    *)
      if [[ "$CONFIGS_ONLY" == false ]]; then
        die "Unsupported CPU architecture: $ARCH_RAW (supported: x86_64, aarch64)"
      fi
      log_warn "Unrecognized architecture '$ARCH_RAW' (continuing in --configs-only mode)"
      ;;
  esac

  if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
  fi

  if [[ "$CONFIGS_ONLY" == false && "$HAS_APT" == false ]]; then
    die "Debian/Ubuntu (apt-get) is required for package installation. Use --configs-only to stow configs only."
  fi

  log_info "Environment: OS='${OS_DESC}' arch=${ARCH_RAW} (${ARCH_DEB:-n/a}) wsl=${IS_WSL}"
  log_info "Dotfiles dir: ${SCRIPT_DIR} -> Target: ${TARGET_HOME}"
}

# ---------------------------------------------------------------------------
# Package & tool installation (skipped in --configs-only mode)
# ---------------------------------------------------------------------------
apt_has_package() {
  local pkg="$1"
  apt-cache show "$pkg" 2>/dev/null | grep -qE "^Package: ${pkg}[[:space:]]*$"
}

install_eza_repo() {
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would add deb.gierens.de repository and install eza"
    return 0
  fi
  log_info "Adding official gierens.de apt repository for eza..."
  local tmp_asc
  tmp_asc="$(ensure_tmpdir)/eza-deb.asc"
  if curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc -o "$tmp_asc"; then
    run_priv mkdir -p /etc/apt/keyrings
    run_priv gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg "$tmp_asc"
    printf 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main\n' \
      | run_priv tee /etc/apt/sources.list.d/gierens.list >/dev/null
    run_priv chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    run_priv apt-get update -qq
    run_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y eza || log_warn "eza install from gierens.de failed (non-fatal)"
  else
    log_warn "Failed to download eza GPG key from gierens.de (non-fatal)"
  fi
}

install_apt_packages() {
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would run: sudo apt-get update"
  else
    log_info "Updating apt package index..."
    run_priv apt-get update
  fi

  local -a apt_pkgs=("${CORE_APT_PACKAGES[@]}")
  local need_eza_repo=false

  if apt_has_package eza; then
    apt_pkgs+=(eza)
  elif ! command -v eza &>/dev/null; then
    need_eza_repo=true
  fi

  if apt_has_package 7zip; then
    apt_pkgs+=(7zip)
  elif apt_has_package p7zip-full; then
    apt_pkgs+=(p7zip-full)
  else
    log_warn "Neither 7zip nor p7zip-full found in apt cache"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install APT packages: ${apt_pkgs[*]}"
  else
    log_info "Installing core APT packages..."
    run_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y "${apt_pkgs[@]}"
  fi

  if [[ "$need_eza_repo" == true ]]; then
    install_eza_repo
  fi
}

install_neovim() {
  local nvim_ver=""
  if command -v nvim &>/dev/null; then
    nvim_ver="$(nvim --version 2>/dev/null | awk 'NR==1 { gsub(/^v/, "", $2); split($2, a, /[-+]/); print a[1] }')"
    if [[ -n "$nvim_ver" ]] && version_ge "$nvim_ver" "0.11"; then
      log_ok "Neovim >= 0.11 already installed (v${nvim_ver})"
      return 0
    fi
  fi

  local nvim_tar_name="nvim-linux-${NVIM_ARCH}.tar.gz"
  local nvim_url="https://github.com/neovim/neovim/releases/latest/download/${nvim_tar_name}"
  local nvim_opt_dir="/opt/nvim-linux-${NVIM_ARCH}"

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install latest Neovim (>= 0.11) from ${nvim_url} -> ${nvim_opt_dir} and symlink /usr/local/bin/nvim (current: ${nvim_ver:-missing})"
    return 0
  fi

  log_info "Installing latest Neovim (>= 0.11) from official release (current: ${nvim_ver:-missing})..."
  local tmp_tar
  tmp_tar="$(ensure_tmpdir)/${nvim_tar_name}"
  curl -fsSL "$nvim_url" -o "$tmp_tar"
  run_priv rm -rf "$nvim_opt_dir"
  run_priv mkdir -p /opt /usr/local/bin
  run_priv tar -C /opt -xzf "$tmp_tar"
  run_priv ln -sfn "${nvim_opt_dir}/bin/nvim" /usr/local/bin/nvim
  hash -r 2>/dev/null || true
  log_ok "Neovim installed: $(nvim --version 2>/dev/null | head -n1)"
}

install_nodejs() {
  if command -v node &>/dev/null && command -v npm &>/dev/null; then
    log_ok "Node.js already installed ($(node --version 2>/dev/null), npm $(npm --version 2>/dev/null))"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install Node.js 24.x LTS via https://deb.nodesource.com/setup_24.x (fallback: apt nodejs npm)"
    return 0
  fi

  log_info "Installing Node.js 24.x LTS..."
  local setup_script
  setup_script="$(ensure_tmpdir)/nodesource_setup_24.sh"
  if curl -fsSL https://deb.nodesource.com/setup_24.x -o "$setup_script" \
    && run_priv bash "$setup_script" \
    && run_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs; then
    hash -r 2>/dev/null || true
    log_ok "Node.js installed via NodeSource ($(node --version 2>/dev/null))"
  else
    log_warn "NodeSource setup failed; falling back to apt nodejs npm"
    run_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs npm
    hash -r 2>/dev/null || true
  fi
}

install_starship() {
  if command -v starship &>/dev/null; then
    log_ok "Starship already installed ($(starship --version 2>/dev/null | head -n1))"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install Starship via https://starship.rs/install.sh (-y)"
    return 0
  fi

  log_info "Installing Starship..."
  local starship_script
  starship_script="$(ensure_tmpdir)/starship_install.sh"
  curl -fsSL https://starship.rs/install.sh -o "$starship_script"
  sh "$starship_script" -y
  hash -r 2>/dev/null || true
  log_ok "Starship installed"
}

resolve_github_latest_tag() {
  local repo="$1"
  local effective_url tag=""
  effective_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest" 2>/dev/null || true)"
  if [[ "$effective_url" == */releases/tag/* ]]; then
    tag="${effective_url##*/releases/tag/}"
  fi
  if [[ -z "$tag" ]]; then
    tag="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null \
      | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1 || true)"
  fi
  printf '%s\n' "$tag"
}

install_lazygit() {
  if command -v lazygit &>/dev/null; then
    log_ok "Lazygit already installed ($(lazygit --version 2>/dev/null | head -n1))"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install latest Lazygit tarball into /usr/local/bin/lazygit"
    return 0
  fi

  log_info "Installing latest Lazygit..."
  local tag ver lg_url tmp_dir
  tag="$(resolve_github_latest_tag "jesseduffield/lazygit")"
  ver="${tag#v}"
  [[ -n "$ver" ]] || die "Failed to determine latest Lazygit release tag"

  lg_url="https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_${LAZYGIT_ARCH}.tar.gz"
  tmp_dir="$(ensure_tmpdir)/lazygit"
  mkdir -p "$tmp_dir"
  curl -fsSL "$lg_url" -o "${tmp_dir}/lazygit.tar.gz"
  tar -xzf "${tmp_dir}/lazygit.tar.gz" -C "$tmp_dir" lazygit
  run_priv mkdir -p /usr/local/bin
  run_priv install -m 0755 "${tmp_dir}/lazygit" /usr/local/bin/lazygit
  hash -r 2>/dev/null || true
  log_ok "Lazygit installed: v${ver}"
}

ensure_local_bin_env() {
  local env_file="$TARGET_HOME/.local/bin/env"
  if [[ -f "$env_file" ]]; then
    return 0
  fi
  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would ensure $env_file exists"
    return 0
  fi
  mkdir -p "$TARGET_HOME/.local/bin"
  cat >"$env_file" <<'EOF'
#!/bin/sh
case ":${PATH}:" in
    *:"$HOME/.local/bin":*)
        ;;
    *)
        export PATH="$HOME/.local/bin:$PATH"
        ;;
esac
EOF
}

install_uv_and_debugpy() {
  if command -v uv &>/dev/null; then
    log_ok "uv already installed ($(uv --version 2>/dev/null))"
    ensure_local_bin_env
  elif [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install uv via https://astral.sh/uv/install.sh and ensure $TARGET_HOME/.local/bin/env"
  else
    log_info "Installing uv..."
    local uv_script
    uv_script="$(ensure_tmpdir)/uv_install.sh"
    curl -LsSf https://astral.sh/uv/install.sh -o "$uv_script"
    env HOME="$TARGET_HOME" sh "$uv_script"
    ensure_local_bin_env
    hash -r 2>/dev/null || true
    log_ok "uv installed"
  fi

  # Best-effort debugpy via uv (used by nvim-dap-python)
  if [[ "$DRY_RUN" == true ]]; then
    if [[ ! -x "$TARGET_HOME/.local/bin/debugpy-adapter" ]]; then
      log_dry "Would run (best-effort): uv tool install debugpy"
    fi
    return 0
  fi

  if command -v uv &>/dev/null; then
    local uv_tool_dir="$TARGET_HOME/.local/share/uv/tools"
    local uv_bin_dir="$TARGET_HOME/.local/bin"
    if [[ -x "$uv_bin_dir/debugpy-adapter" ]] || \
       env HOME="$TARGET_HOME" UV_TOOL_DIR="$uv_tool_dir" UV_TOOL_BIN_DIR="$uv_bin_dir" uv tool list 2>/dev/null | grep -qE '^debugpy[[:space:]]'; then
      log_ok "uv tool debugpy already installed"
    else
      log_info "Installing debugpy via uv (best-effort)..."
      env HOME="$TARGET_HOME" UV_TOOL_DIR="$uv_tool_dir" UV_TOOL_BIN_DIR="$uv_bin_dir" \
        uv tool install debugpy || log_warn "uv tool install debugpy failed (non-fatal)"
    fi
  fi
}

install_yazi() {
  if command -v yazi &>/dev/null && command -v ya &>/dev/null; then
    log_ok "Yazi already installed ($(yazi --version 2>/dev/null | awk 'NR==2 {print $2; exit}'))"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install latest Yazi + ya (best-effort) into $TARGET_HOME/.local/bin"
    return 0
  fi

  log_info "Installing Yazi (best-effort)..."
  local yazi_url="https://github.com/sxyazi/yazi/releases/latest/download/yazi-${YAZI_TRIPLE}.zip"
  local tmp_dir yazi_bin ya_bin
  tmp_dir="$(ensure_tmpdir)/yazi"
  mkdir -p "$tmp_dir" "$TARGET_HOME/.local/bin"

  if curl -fsSL "$yazi_url" -o "${tmp_dir}/yazi.zip" && unzip -q "${tmp_dir}/yazi.zip" -d "$tmp_dir"; then
    yazi_bin="$(find "$tmp_dir" -type f -name yazi -print -quit)"
    ya_bin="$(find "$tmp_dir" -type f -name ya -print -quit)"
    if [[ -n "$yazi_bin" && -n "$ya_bin" ]]; then
      install -m 0755 "$yazi_bin" "$TARGET_HOME/.local/bin/yazi"
      install -m 0755 "$ya_bin" "$TARGET_HOME/.local/bin/ya"
      hash -r 2>/dev/null || true
      log_ok "Yazi installed into $TARGET_HOME/.local/bin"
    else
      log_warn "Yazi archive did not contain expected binaries (non-fatal)"
    fi
  else
    log_warn "Yazi download/extraction failed (non-fatal)"
  fi
}

install_fastfetch() {
  if command -v fastfetch &>/dev/null; then
    log_ok "Fastfetch already installed ($(fastfetch --version 2>/dev/null | head -n1))"
    return 0
  fi

  if apt_has_package fastfetch; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would install fastfetch via apt"
    else
      log_info "Installing fastfetch via apt (best-effort)..."
      run_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y fastfetch \
        || log_warn "fastfetch apt install failed (non-fatal)"
    fi
    return 0
  fi

  if command -v add-apt-repository &>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would add ppa:zhangsongcui3371/fastfetch and install fastfetch (best-effort)"
    else
      log_info "Installing fastfetch via PPA (best-effort)..."
      if run_priv add-apt-repository -y ppa:zhangsongcui3371/fastfetch && run_priv apt-get update -qq; then
        run_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y fastfetch \
          || log_warn "fastfetch PPA install failed (non-fatal)"
      else
        log_warn "Failed to configure fastfetch PPA (non-fatal)"
      fi
    fi
    return 0
  fi

  log_warn "fastfetch not available in apt and add-apt-repository missing; skipping (best-effort)"
}

install_treesitter_cli() {
  local ts_ver=""
  if command -v tree-sitter &>/dev/null; then
    ts_ver="$(tree-sitter --version 2>/dev/null | awk '{print $2; exit}')"
    if [[ -n "$ts_ver" ]] && version_ge "$ts_ver" "0.25"; then
      log_ok "tree-sitter CLI >= 0.25 already installed (${ts_ver})"
      return 0
    fi
  fi

  if ! command -v npm &>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would install tree-sitter-cli (>= 0.25) via npm once Node.js/npm is installed"
    else
      log_warn "npm not available; skipping tree-sitter-cli install (best-effort)"
    fi
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would install tree-sitter-cli (>= 0.25) via npm globally or into $TARGET_HOME/.npm-global (current: ${ts_ver:-missing})"
    return 0
  fi

  log_info "Installing tree-sitter-cli >= 0.25 (current: ${ts_ver:-missing})..."
  local npm_prefix
  npm_prefix="$(npm prefix -g 2>/dev/null || true)"
  if [[ "$TARGET_HOME" == "$HOME" && -n "$npm_prefix" && -w "$npm_prefix" ]] && npm install -g tree-sitter-cli; then
    hash -r 2>/dev/null || true
    log_ok "tree-sitter-cli installed into global npm prefix"
    return 0
  fi

  if [[ "$TARGET_HOME" == "$HOME" ]] && run_priv npm install -g tree-sitter-cli 2>/dev/null; then
    hash -r 2>/dev/null || true
    log_ok "tree-sitter-cli installed globally"
    return 0
  fi

  mkdir -p "$TARGET_HOME/.npm-global"
  if npm install -g --prefix "$TARGET_HOME/.npm-global" tree-sitter-cli; then
    hash -r 2>/dev/null || true
    log_ok "tree-sitter-cli installed into $TARGET_HOME/.npm-global"
  else
    log_warn "tree-sitter-cli installation failed (non-fatal)"
  fi
}

install_all_packages() {
  install_apt_packages
  install_neovim
  install_nodejs
  install_starship
  install_lazygit
  install_uv_and_debugpy
  install_yazi
  install_fastfetch
  install_treesitter_cli
}

# ---------------------------------------------------------------------------
# Parent directories, backup, fd symlink & GNU Stow (always runs)
# ---------------------------------------------------------------------------
get_backup_dir() {
  if [[ -z "$BACKUP_DIR" ]]; then
    BACKUP_DIR="$TARGET_HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    if [[ "$DRY_RUN" != true ]]; then
      mkdir -p "$BACKUP_DIR"
    fi
  fi
}

backup_target() {
  local target="$1"
  local rel="$2"
  get_backup_dir
  local dest="$BACKUP_DIR/$rel"
  BACKED_UP_ITEMS+=("$rel")

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would back up $target -> $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  mv "$target" "$dest"
  log_warn "Backed up conflicting target: $target -> $dest"
}

ensure_real_dir() {
  local dir="$1"
  local rel="${dir#"$TARGET_HOME"/}"

  if [[ -d "$dir" && ! -L "$dir" ]]; then
    return 0
  fi

  if [[ -L "$dir" ]]; then
    local resolved script_real
    resolved="$(readlink -f "$dir" 2>/dev/null || true)"
    script_real="$(readlink -f "$SCRIPT_DIR")"
    if [[ -n "$resolved" && ( "$resolved" == "$script_real" || "$resolved" == "$script_real"/* ) ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        log_dry "Would unfold Stow-managed directory symlink: $dir -> real directory"
      else
        rm "$dir"
        mkdir -p "$dir"
        log_warn "Unfolded symlinked parent directory into real directory: $dir"
      fi
      return 0
    fi
    backup_target "$dir" "$rel"
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would create real directory: $dir"
    else
      mkdir -p "$dir"
    fi
    return 0
  fi

  if [[ -e "$dir" ]]; then
    backup_target "$dir" "$rel"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would create directory: $dir"
  else
    mkdir -p "$dir"
  fi
}

ensure_shared_parent_dirs() {
  local -a parent_dirs=(
    "$TARGET_HOME/.config"
    "$TARGET_HOME/.config/git"
    "$TARGET_HOME/.config/btop"
    "$TARGET_HOME/.config/gh"
    "$TARGET_HOME/.local/bin"
  )
  local dir
  for dir in "${parent_dirs[@]}"; do
    ensure_real_dir "$dir"
  done
}

setup_fd_symlink() {
  local fdfind_bin fd_link
  fdfind_bin="$(command -v fdfind || true)"
  fd_link="$TARGET_HOME/.local/bin/fd"

  if [[ -z "$fdfind_bin" ]]; then
    if [[ "$DRY_RUN" == true && "$CONFIGS_ONLY" == false ]]; then
      log_dry "Would create symlink $fd_link -> fdfind (after fd-find is installed)"
    else
      log_warn "fdfind not found; skipping $fd_link symlink"
    fi
    return 0
  fi

  if [[ -e "$fd_link" ]]; then
    log_ok "fd already present at $fd_link"
  elif [[ -L "$fd_link" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would replace broken symlink: $fd_link -> $fdfind_bin"
    else
      ln -sfn "$fdfind_bin" "$fd_link"
      log_ok "Replaced broken fd symlink: $fd_link -> $fdfind_bin"
    fi
  else
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would create symlink: $fd_link -> $fdfind_bin"
    else
      ln -s "$fdfind_bin" "$fd_link"
      log_ok "Created fd symlink: $fd_link -> $fdfind_bin"
    fi
  fi
}

paths_match_resolved() {
  local a="$1" b="$2"
  local a_real b_real
  a_real="$(readlink -f "$a" 2>/dev/null || true)"
  b_real="$(readlink -f "$b" 2>/dev/null || true)"
  [[ -n "$a_real" && -n "$b_real" && "$a_real" == "$b_real" ]]
}

backup_conflicts() {
  local pkg src rel dest

  for pkg in "${NO_FOLD_PACKAGES[@]}"; do
    [[ -d "$SCRIPT_DIR/$pkg" ]] || { log_warn "Package directory missing, skipping scan: $SCRIPT_DIR/$pkg"; continue; }
    while IFS= read -r -d '' src; do
      rel="${src#"$SCRIPT_DIR/$pkg/"}"
      dest="$TARGET_HOME/$rel"
      if [[ -e "$dest" || -L "$dest" ]]; then
        if ! paths_match_resolved "$dest" "$src"; then
          backup_target "$dest" "$rel"
        fi
      fi
    done < <(find "$SCRIPT_DIR/$pkg" -mindepth 1 \( -type f -o -type l \) -print0)
  done

  # Folded packages (nvim) link the whole .config/nvim directory
  local nvim_src="$SCRIPT_DIR/nvim/.config/nvim"
  local nvim_dest="$TARGET_HOME/.config/nvim"
  if [[ -d "$nvim_src" && ( -e "$nvim_dest" || -L "$nvim_dest" ) ]]; then
    if ! paths_match_resolved "$nvim_dest" "$nvim_src"; then
      backup_target "$nvim_dest" ".config/nvim"
    fi
  fi
}

stow_packages() {
  if ! command -v stow &>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would run: stow --no-folding --restow -d \"$SCRIPT_DIR\" -t \"$TARGET_HOME\" ${NO_FOLD_PACKAGES[*]}"
      log_dry "Would run: stow --restow -d \"$SCRIPT_DIR\" -t \"$TARGET_HOME\" ${FOLD_PACKAGES[*]}"
      log_warn "stow is not currently installed; skipping --simulate preview"
      return 0
    fi
    die "GNU Stow (stow) is required. Install stow first or run without --configs-only."
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would run: stow --no-folding --restow -d \"$SCRIPT_DIR\" -t \"$TARGET_HOME\" ${NO_FOLD_PACKAGES[*]}"
    log_dry "Would run: stow --restow -d \"$SCRIPT_DIR\" -t \"$TARGET_HOME\" ${FOLD_PACKAGES[*]}"
    if [[ -d "$TARGET_HOME" && ${#BACKED_UP_ITEMS[@]} -eq 0 ]]; then
      log_info "Running stow --simulate preview..."
      stow --simulate --no-folding --restow -d "$SCRIPT_DIR" -t "$TARGET_HOME" "${NO_FOLD_PACKAGES[@]}" \
        || log_warn "stow --simulate (no-folding) reported potential issues without parent dir creation"
      stow --simulate --restow -d "$SCRIPT_DIR" -t "$TARGET_HOME" "${FOLD_PACKAGES[@]}" \
        || log_warn "stow --simulate (folding) reported potential issues without parent dir creation"
    elif [[ ${#BACKED_UP_ITEMS[@]} -gt 0 ]]; then
      log_dry "Skipping stow --simulate because ${#BACKED_UP_ITEMS[@]} conflict(s) would be backed up first"
    fi
    return 0
  fi

  log_info "Stowing non-folded packages: ${NO_FOLD_PACKAGES[*]}"
  stow --no-folding --restow -d "$SCRIPT_DIR" -t "$TARGET_HOME" "${NO_FOLD_PACKAGES[@]}"
  log_info "Stowing folded packages: ${FOLD_PACKAGES[*]}"
  stow --restow -d "$SCRIPT_DIR" -t "$TARGET_HOME" "${FOLD_PACKAGES[@]}"
  log_ok "All config packages stowed"
}

# ---------------------------------------------------------------------------
# Post-stow setup (skipped in --configs-only mode)
# ---------------------------------------------------------------------------
setup_tpm() {
  local tpm_dir="$TARGET_HOME/.tmux/plugins/tpm"

  if [[ ! -d "$tpm_dir" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would clone https://github.com/tmux-plugins/tpm -> $tpm_dir"
    else
      log_info "Cloning tmux plugin manager (TPM)..."
      mkdir -p "$TARGET_HOME/.tmux/plugins"
      git clone https://github.com/tmux-plugins/tpm "$tpm_dir" || log_warn "TPM clone failed (non-fatal)"
    fi
  else
    log_ok "TPM already present at $tpm_dir"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would run: $tpm_dir/bin/install_plugins"
  elif [[ -x "$tpm_dir/bin/install_plugins" ]]; then
    log_info "Installing tmux plugins via TPM..."
    env HOME="$TARGET_HOME" TMUX_PLUGIN_MANAGER_PATH="$TARGET_HOME/.tmux/plugins/" \
      "$tpm_dir/bin/install_plugins" </dev/null || true
  fi
}

sync_neovim_plugins() {
  if [[ "$SKIP_NVIM_SYNC" == true ]]; then
    log_info "Skipping Neovim plugin sync (--skip-nvim-sync)"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would run: nvim --headless \"+Lazy! sync\" +qa"
    return 0
  fi

  if command -v nvim &>/dev/null; then
    log_info "Bootstrapping/syncing Neovim plugins headlessly..."
    env HOME="$TARGET_HOME" nvim --headless "+Lazy! sync" +qa </dev/null || true
    log_ok "Neovim plugin sync step completed"
  else
    log_warn "nvim not found; skipping plugin sync"
  fi
}

setup_default_shell() {
  if [[ "$SKIP_CHSH" == true ]]; then
    log_info "Skipping default shell change (--skip-chsh)"
    return 0
  fi

  local zsh_path current_login_shell current_user
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      log_dry "Would set default login shell to zsh (after zsh is installed)"
    else
      log_warn "zsh not found; skipping chsh"
    fi
    return 0
  fi

  current_user="${USER:-$(id -un)}"
  current_login_shell="$(getent passwd "$current_user" 2>/dev/null | cut -d: -f7 || printf '%s' "${SHELL:-}")"

  if [[ "${SHELL:-}" == *"/zsh" || "$current_login_shell" == *"/zsh" ]]; then
    log_ok "Default shell is already zsh ($zsh_path)"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_dry "Would run: chsh -s $zsh_path"
    return 0
  fi

  log_info "Changing default login shell to $zsh_path..."
  if [[ -t 0 ]]; then
    chsh -s "$zsh_path" || log_warn "chsh failed; change manually with: chsh -s $zsh_path"
  else
    chsh -s "$zsh_path" </dev/null >/dev/null 2>&1 \
      || log_warn "chsh failed in non-interactive mode; change manually with: chsh -s $zsh_path"
  fi
}

run_post_stow() {
  setup_tpm
  sync_neovim_plugins
  setup_default_shell
}

# ---------------------------------------------------------------------------
# Summary banner
# ---------------------------------------------------------------------------
print_summary() {
  printf '\n%s============================================================%s\n' "$C_BOLD" "$C_RESET"
  printf '%s  Dotfiles Setup Summary%s\n' "$C_BOLD" "$C_RESET"
  printf '%s============================================================%s\n' "$C_BOLD" "$C_RESET"
  printf '  Mode          : %s%s\n' \
    "$([[ "$CONFIGS_ONLY" == true ]] && echo "configs-only" || echo "full install")" \
    "$([[ "$DRY_RUN" == true ]] && echo " (dry-run)" || echo "")"
  printf '  Target Home   : %s\n' "$TARGET_HOME"
  printf '  No-Fold Stowed: %s\n' "${NO_FOLD_PACKAGES[*]}"
  printf '  Folded Stowed : %s\n' "${FOLD_PACKAGES[*]}"
  if [[ ${#BACKED_UP_ITEMS[@]} -gt 0 ]]; then
    printf '  Backups       : %s (%d item(s))\n' "$BACKUP_DIR" "${#BACKED_UP_ITEMS[@]}"
    local item
    for item in "${BACKED_UP_ITEMS[@]}"; do
      printf '    - %s\n' "$item"
    done
  else
    printf '  Backups       : None (no conflicting targets)\n'
  fi
  printf '\n  Post-install reminders:\n'
  printf '    1. Set a Nerd Font (e.g. JetBrainsMono / CaskaydiaCove Nerd Font) in Windows Terminal.\n'
  printf '    2. Create ~/.config/secrets/env.zsh (chmod 600) for private API keys/tokens.\n'
  printf '    3. Authenticate GitHub CLI: gh auth login (~/.config/gh/hosts.yml remains local).\n'
  printf '    4. Restart your shell: exec zsh\n'
  printf '%s============================================================%s\n\n' "$C_BOLD" "$C_RESET"
}

main() {
  parse_args "$@"
  detect_environment

  if [[ "$CONFIGS_ONLY" == false ]]; then
    install_all_packages
  else
    log_info "Skipping package/binary/plugin installs and chsh (--configs-only)"
  fi

  ensure_shared_parent_dirs
  setup_fd_symlink
  backup_conflicts
  stow_packages

  if [[ "$CONFIGS_ONLY" == false ]]; then
    run_post_stow
  fi

  print_summary
}

main "$@"
