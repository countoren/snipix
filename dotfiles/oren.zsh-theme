# show which vim mode we are in
setopt PROMPT_SUBST

vim_ins_mode="INS"
vim_cmd_mode="CMD"
vim_mode=$vim_ins_mode

function zle-keymap-select {
	vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
	zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
	vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

PROMPT='%F{green}%B%~%b%f'$' %F{white}%*%f %F{magenta}%n%f %F{blue}[${vim_mode}]%f\n'"$ "
# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

# render prompt
#setopt prompt_subst

#### Segments of the prompt, default order declaration

#typeset -aHg AGNOSTER_PROMPT_SEGMENTS=(
#    prompt_status
#    prompt_context
#    prompt_virtualenv
#    prompt_dir
#    prompt_nix_shell
#    prompt_git
#    prompt_newline
#    prompt_end
#)

#### Segment drawing
## A few utility functions to make it easy and re-usable to draw segmented prompts

#CURRENT_BG='NONE'
#if [[ -z "$PRIMARY_FG" ]]; then
#	PRIMARY_FG=black
#fi

## Characters
#SEGMENT_SEPARATOR="\ue0b0"
#PLUSMINUS="\u00b1"
#BRANCH="\ue0a0"
#DETACHED="\u27a6"
#CROSS="\u2718"
#LIGHTNING="\u26a1"
#GEAR="\u2699"

## Begin a segment
## Takes two arguments, background and foreground. Both can be omitted,
## rendering default background/foreground.
#prompt_segment() {
#  local bg fg
#  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
#  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
#  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
#    print -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
#  else
#    print -n "%{$bg%}%{$fg%}"
#  fi
#  CURRENT_BG=$1
#  [[ -n $3 ]] && print -n $3
#}

## End the prompt, closing any open segments
#prompt_end() {
#  if [[ -n $CURRENT_BG ]]; then
#    print -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
#  else
#    print -n "%{%k%}"
#  fi
#  print -n "%{%f%}"
#  CURRENT_BG=''
#}

#prompt_newline(){
#    NEWLINE=$'\n'
#    print -n "%-100(l::${NEWLINE})"
#}
#### Prompt components
## Each component will draw itself, and hide itself if no information needs to be shown

## Context: user@hostname (who am I and where am I)
#prompt_context() {
#  local user=`whoami`

#  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
#    prompt_segment $PRIMARY_FG default " %(!.%{%F{yellow}%}.)$user@%m "
#  fi
#}

## Git: branch/detached head, dirty status
#prompt_git() {
#  local color ref
#  is_dirty() {
#    test -n "$(git status --porcelain --ignore-submodules)"
#  }
#  ref="$vcs_info_msg_0_"
#  if [[ -n "$ref" ]]; then
#    if is_dirty; then
#      color=yellow
#      ref="${ref} $PLUSMINUS"
#    else
#      color=green
#      ref="${ref} "
#    fi
#    if [[ "${ref/.../}" == "$ref" ]]; then
#      ref="$BRANCH $ref"
#    else
#      ref="$DETACHED ${ref/.../}"
#    fi
#    prompt_segment $color $PRIMARY_FG
#    print -n " $ref"
#  fi
#}

## # Dir: current working directory
## prompt_dir() {
##   prompt_segment blue $PRIMARY_FG ' %~ '
## }

## Dir: current working directory
#prompt_dir() {
#  prompt_segment cyan $PRIMARY_FG ' %~ '
#}

## Status:
## - was there an error
## - am I root
## - are there background jobs?
#prompt_status() {
#  local symbols
#  symbols=()
#  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$CROSS"
#  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$LIGHTNING"
#  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$GEAR"

#  [[ -n "$symbols" ]] && prompt_segment $PRIMARY_FG default " $symbols "
#}

## Display current virtual environment
#prompt_virtualenv() {
#  if [[ -n $VIRTUAL_ENV ]]; then
#    color=cyan
#    prompt_segment $color $PRIMARY_FG
#    print -Pn " $(basename $VIRTUAL_ENV) "
#  fi
#}

### Main prompt
#prompt_agnoster_main() {
#  RETVAL=$?
#  CURRENT_BG='NONE'
#  for prompt_segment in "${AGNOSTER_PROMPT_SEGMENTS[@]}"; do
#    [[ -n $prompt_segment ]] && $prompt_segment
#  done
#}

#prompt_agnoster_precmd() {
#  vcs_info
#  PROMPT='%{%f%b%k%}$(prompt_agnoster_main) '
#}

#prompt_agnoster_setup() {
#  autoload -Uz add-zsh-hook
#  autoload -Uz vcs_info

#  prompt_opts=(cr subst percent)

#  add-zsh-hook precmd prompt_agnoster_precmd

#  zstyle ':vcs_info:*' enable git
#  zstyle ':vcs_info:*' check-for-changes false
#  zstyle ':vcs_info:git*' formats '%b'
#  zstyle ':vcs_info:git*' actionformats '%b (%a)'
#}

#prompt_agnoster_setup "$@"


## vi mode agnoster Plugin
## A Powerline-inspired plugin for Agnoster theme
##
## # README
##
## In order for this extension to work properly, you will need a
## [Agnoster-theme](https://gist.github.com/agnoster/3712874).
##
## # Goals
##
## Using Vi mode in Zsh this plugin shows a right prompt segment
## with the current mode.

## Updates editor information when the keymap changes.
## https://gist.github.com/steakknife/2051560
#zle-keymap-select() {
#  zle reset-prompt
#  zle -R
#}

#zle -N zle-keymap-select

#bindkey -v

## Segment drawing
## https://gist.github.com/agnoster/3712874
#CURRENT_BG='NONE'
#PRIMARY_FG=black

## Characters
#RSEGMENT_SEPARATOR="\ue0b2"

## Vi mode
#VICMD_INDICATOR="NORMAL"
#VIINS_INDICATOR="INSERT"

## Begin an RPROMPT segment
## Takes two arguments, background and foreground. Both can be omitted,
## rendering default background/foreground.
## https://gist.github.com/rjorgenson/83094662ace4d3b82b95
#rprompt_segment() {
#  local bg fg
#  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
#  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
#  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
#    echo -n "%{%K{$CURRENT_BG}%F{$1}%}$RSEGMENT_SEPARATOR%{$bg%}%{$fg%}"
#  else
#    echo -n "%F{$1}%{%K{default}%}$RSEGMENT_SEPARATOR%{$bg%}%{$fg%}"
#  fi
#  CURRENT_BG=$1
#  # [[ -n $3 ]] && echo -n $3
#  [[ -n $3 ]] && echo -n "%{$fg_bold[$2]%} $3 %{$reset_color%}"
#}

## Vi mode
#prompt_vi_mode() {
#  local color mode
#  is_normal() {
#    test -n "${${KEYMAP/vicmd/$VICMD_INDICATOR}/(main|viins)/}"  # param expans
#  }
#  if is_normal; then
#    color=green
#    mode="$VICMD_INDICATOR"
#  else
#    color=blue
#    mode="$VIINS_INDICATOR"
#  fi
#  rprompt_segment $color white $mode
#}

## Timestamp
#prompt_timestamp() {
#  if [[ $ZSH_TIME = "24" ]]; then
#    local time_string="%H:%M:%S"
#  else
#    local time_string="%L:%M:%S %p"
#  fi
#  rprompt_segment cyan $PRIMARY_FG "%D{$time_string}"
#}

## Right prompt
#rprompt_agnoster_vi() {
#  prompt_vi_mode
#  prompt_timestamp
#  echo -n " "  # rprompt looks awful without a space at the end
#}

#if [[ "$RPS1" == "" && "$RPROMPT" == "" ]]; then
#  RPROMPT='%{%f%b%k%}$(rprompt_agnoster_vi)'
#fi

#prompt_nix_shell() {
#  if [ -n "$IN_NIX_SHELL" ]; then
#    if [[ -n $NIX_SHELL_PACKAGES ]]; then
#      local package_names=""
#      local packages=($NIX_SHELL_PACKAGES)
#      for package in $packages; do
#        package_names+=" ${package##*.}"
#      done
#      prompt_segment black yellow "{$package_names }"
#    elif [[ -n "$name" ]]; then
#      local cleanName=${name#interactive-}
#      cleanName=${cleanName%-environment}
#      prompt_segment black yellow "{ $cleanName }"
#    else # This case is only reached if the nix-shell plugin isn't installed or failed in some way
#      prompt_segment black yellow $'\u2744'
#    fi
#  fi
#}

##Optionally to hide the “user@hostname” info when you’re logged in as yourself on your local machine.
#prompt_context(){}
