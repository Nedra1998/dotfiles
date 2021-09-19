# GREETER {{{
command -v pfetch &>/dev/null && pfetch
if [ -s "$HOME/.dotfiles/dot" ]; then
  $HOME/.dotfiles/dot sync -qd '12 hours'
fi
# }}}
# VIRTUALENV {{{
if ! [ -d "$HOME/.pyenv" ]; then
  git clone --quiet --depth=1 https://github.com/pyenv/pyenv.git $HOME/.pyenv
  git clone --quiet --depth=1 https://github.com/pyenv/pyenv-virtualenv.git $HOME/.pyenv/plugins/pyenv-virtualenv
  cd ~/.pyenv && src/configure && make -C src
fi

export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$HOME/.pyenv" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

  source "$(pyenv root)/completions/pyenv.zsh"
fi

if ! [ -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

if [ -d "$HOME/.cargo" ]; then
  export PATH="$PATH:$HOME/.cargo/bin"
fi
# }}}
# ZINIT {{{
if ! [ -d "$HOME/.config/zsh/zinit" ]; then
  mkdir -p "$HOME/.config/zsh/zinit/bin"
  git clone --quiet --depth=1 https://github.com/zdharma/zinit.git "$HOME/.config/zsh/zinit/bin"
fi
declare -A ZINIT
ZINIT[BIN_DIR]="$HOME/.config/zsh/zinit/bin"
ZINIT[HOME_DIR]="$HOME/.config/zsh/zinit"

if [ -f "$HOME/.config/zsh/zinit/bin/zinit.zsh" ]; then
  source "$HOME/.config/zsh/zinit/bin/zinit.zsh"

  zinit light zinit-zsh/z-a-bin-gem-node

  zinit wait lucid light-mode for \
    atinit='zicompinit; zicdreplay' \
      zdharma/fast-syntax-highlighting \
      OMZP::colored-man-pages \
    atload='_zsh_autosuggest_start' \
      zsh-users/zsh-autosuggestions \
    blockf atpull='zinit creinstall -q .' \
      zsh-users/zsh-completions \
    atload='bindkey "^[[A" history-substring-search-up; \
            bindkey "^[[B" history-substring-search-down' \
      zsh-users/zsh-history-substring-search

  zinit ice lucid
  zinit snippet OMZP::command-not-found

  zinit ice lucid atclone="dircolors -b LS_COLORS > clrs.zsh" \
    atpull='%atclone' pick='clrs.zsh' nocompile='!' \
    atload='zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"'
  zinit light trapd00r/LS_COLORS
    
  zinit lucid as='command' from='gh-r' \
    atclone='./starship init zsh > init.zsh; ./starship completions zsh > _starship' \
    atpull='%atclone' src='init.zsh' light-mode for \
    starship/starship

  zinit ice lucid wait='0b' from='gh-r' sbin="fzf"
  zinit light junegunn/fzf
  zinit ice wait="1" lucid \
    atload='zstyle ":fzf-tab:*" switch-group "," "."'
  zinit light Aloxaf/fzf-tab

  zinit ice lucid from='gh-r' mv='fd* -> fd' sbin="fd/fd"
  zinit light sharkdp/fd

  zinit ice lucid from='gh-r' sbin="bat/bat" \
    atclone="cp -vf bat*/autocomplete/bat.zsh _bat" \
    atpull="%atclone" mv='bat* -> bat' \
    atload='alias cat=bat'
  zinit light sharkdp/bat

  zinit ice lucid from='gh-r' mv='hexyl* -> hexyl' sbin='hexyl/hexyl' \
    atload='alias hex=hexyl'
  zinit light sharkdp/hexyl

  zinit ice lucid from='gh-r' mv='hyperfine* -> hyperfine' \
    sbin="hyperfine/hyperfine"
  zinit light sharkdp/hyperfine

  zinit ice lucid from='gh-r' mv='delta* -> delta' sbin='delta/delta'
  zinit light dandavison/delta

  zinit ice lucid from='gh-r' mv='dust* -> dust' sbin='dust/dust' \
    atload='alias du=dust'
  zinit light bootandy/dust

  zinit ice lucid from='gh-r' sbin='bin/dog' atload='alias dig=dog'
  zinit light ogham/dog

  zinit ice lucid from='gh-r' mv='ripgrep* -> rg' sbin='rg/rg' \
    atload='alias grep=rg'
  zinit light BurntSushi/ripgrep
  
  zinit ice wait="2" lucid from="gh-r" \
    atclone="cp -vf completions/exa.zsh _exa" atpull='%atclone' \
    mv="exa* -> exa" sbin="bin/exa" \
    atload='alias ls=exa'
  zinit light ogham/exa
fi
# }}}
# ALIASES {{{
command -v bat    &>/dev/null && alias cat=bat
command -v bpytop &>/dev/null && alias top=bpytop
command -v curlie &>/dev/null && alias curl=curlie
command -v duf    &>/dev/null && alias df=duf
command -v dust   &>/dev/null && alias du=dust
command -v exa    &>/dev/null && alias ls=exa
command -v procs  &>/dev/null && alias ps=procs
command -v sd     &>/dev/null && alias sed=sd
# }}}
# HISTORY {{{
export HISTFILE="$HOME/.config/zsh/history"
export HISTSIZE=5000
export SAVEHIST=2500
setopt append_history
setopt extended_history
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
# }}}
# COMPLETION {{{
zstyle ":completion:*" completer _extensions _complete _approximate _expand_alias
zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path "$HOME/.config/zsh/.zcompcache"
zstyle ":completion:*" menu select=2
zstyle ":completion:*:descriptions" format '[%d]'
zstyle ":completion:*:corrections" format '%F{yellow}%d%f'
zstyle ":completion:*:messages" format '%F{purple}%d%f'
zstyle ":completion:*:warnings" format '%F{red}%d%f'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# }}}
# OPTIONS {{{
setopt extended_glob
[ -s "$HOME/.config/fzf/fzfrc" ] && source "$HOME/.config/fzf/fzfrc"
# }}}
# vim:ft=zsh foldmethod=marker foldlevel=0
