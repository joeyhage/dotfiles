#!/bin/zsh

ZPLUGINDIR=${ZDOTDIR:-$HOME/.config/zsh}/plugins

# declare a simple plugin-clone function, leaving the user to load plugins themselves
function plugin-clone {
  local plugin repo commitsha plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/plugins}
  for plugin in $@; do
    repo="$plugin"
    clone_args=(-q --depth 1 --recursive --shallow-submodules)
    # Pin repo to a specific commit sha if provided
    if [[ "$plugin" == *'@'* ]]; then
      repo="${plugin%@*}"
      commitsha="${plugin#*@}"
      clone_args+=(--no-checkout)
    fi
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone "${clone_args[@]}" https://github.com/$repo $plugdir
      if [[ -n "$commitsha" ]]; then
        git -C $plugdir fetch -q origin "$commitsha"
        git -C $plugdir checkout -q "$commitsha"
      fi
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) && ln -sf $initfiles[1] $initfile
    fi
  done
}

function plugin-source {
  local plugdir initfile
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for plugdir in $@; do
    [[ $plugdir = /* ]] || plugdir=$ZPLUGINDIR/$plugdir
    fpath+=$plugdir
    initfile=$plugdir/${plugdir:t}.plugin.zsh
    . $initfile
  done
}

# make list of the Zsh plugins you use
# Commit sha is required after the @ symbol to ensure reproducibility.
repos=(
  # projects with nested plugins
  'belak/zsh-utils@3ebd1e4038756be86da095b88f3713170171aec1'
  'ohmyzsh/ohmyzsh@a6beb0f5958e935d33b0edb6d4470c3d7c4e8917'

  # regular plugins
  'mattmc3/ez-compinit@be538a22edf8e0e4fe9cc6f480da8f1511f5be20'
  'sindresorhus/pure@5c2158096cd992ad73ae4b42aa43ee618383e092'
  'zsh-users/zsh-autosuggestions@85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5'
  'zsh-users/zsh-syntax-highlighting@5eb677bb0fa9a3e60f0eff031dc13926e093df92'
)

plugin-clone $repos
plugin-source ez-compinit

# handle non-standard plugins
for file in $ZPLUGINDIR/ohmyzsh/lib/*.zsh; do
  source $file
done

# source other plugins
plugins=(
  # load these first
  pure

  # nested plugins
  zsh-utils/history
  zsh-utils/completion
  zsh-utils/utility
  ohmyzsh/plugins/git
  ohmyzsh/plugins/history-substring-search

  # regular plugins
  zsh-autosuggestions
  zsh-syntax-highlighting
)
plugin-source $plugins

zstyle ':plugin:ez-compinit' 'compstyle' 'zshzoo'

[[ -f ~/.aliases ]] && source ~/.aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
