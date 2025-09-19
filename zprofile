function gitgit() {
  (
    set -e
    branch=$(git_main_branch)
    git switch --quiet "$branch"
    git fetch --all --prune --jobs=10 --quiet > /dev/null
    git pull --quiet > /dev/null
    echo "$branch branch is up to date"
    branches=$(git for-each-ref --format '%(refname:short)' "refs/heads/feat/" "refs/heads/feature/" "refs/heads/docs" "refs/heads/chore" "refs/heads/fix")
    if [ -z "$branches" ]; then
      echo "no branches to delete"
      return
    else
      branches=("${(@f)branches}")
      for branch in "${branches[@]}"; do
        echo -n "Delete branch $branch? (Y/n) "
        read -r delete
        if [ "$delete" = "Y" ] || [ "$delete" = "y" ] || [ -z "$delete" ]; then
          git branch -d "$branch"
          echo ""
        fi
      done
    fi
  )
}

function git_repo_full_name() {
  git remote get-url origin | awk -F'[/:]' '{print $(NF-1)"/"$(NF)}' | awk -F'[.]' '{print $(NF-1)}' 
}

#==============================================
# Aliases
#==============================================

alias -- gfl='gfa && gl'
alias -- gsha='git log -1 --format=%H | cat'

#==============================================
# apt packages installation
#==============================================
apt_packages() {
  local packages
  packages=(
    vim
  )
  
  if (( ${#packages[@]} )); then
    sudo apt-get update &> /dev/null
    sudo apt-get install -y --no-install-recommends "${packages[@]}" &> /dev/null
  fi
}

apt_packages

#==============================================
# git packages installation
#==============================================

git_packages() {
  local commitsha pkgdir
  if ! command -v fzf &> /dev/null; then
    pkgdir=~/.fzf
    commitsha=f2179f015c29a7c5e741e7cbd9f3baf21b5acd0c
    git clone -q --depth 1 --no-checkout https://github.com/junegunn/fzf.git "$pkgdir" &> /dev/null || :
    git -C "$pkgdir" fetch -q origin "$commitsha"
    git -C "$pkgdir" checkout -q "$commitsha"
    ~/.fzf/install --key-bindings --completion --update-rc &> /dev/null
  fi
}

git_packages