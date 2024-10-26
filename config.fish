starship init fish | source

set -gx JAVA_HOME "/opt/jdk-17.0.12/"
set -gx PATH "\$JAVA_HOME/bin:\$PATH"



alias cls='clear'
alias ..='cd ..'
alias vs='code .'
alias ls='eza'
alias l='eza --oneline'
alias la='l --all'
alias lt='l --tree'
alias lat='la --tree'
alias lgi='la -git-ignore'

function mkcd
    mkdir \$argv[1]
    cd \$argv[1]
end

# Configurações de prompt
set -g SPACESHIP_PROMPT_ORDER user dir host git exec_time line_sep vi_mode jobs exit_code char
set -g SPACESHIP_USER_SHOW always
set -g SPACESHIP_CHAR_SYMBOL "❯"
set -g SPACESHIP_CHAR_SUFFIX " "
