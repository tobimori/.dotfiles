set -gx PNPM_HOME $HOME/.local/share/pnpm
fish_add_path --global $PNPM_HOME/bin

# Plannotator: keep the server on loopback for Tailscale Serve.
set -gx PLANNOTATOR_REMOTE 0
set -gx PLANNOTATOR_PORT 19432

# pi: use long prompt cache retention (1h on Anthropic)
set -gx PI_CACHE_RETENTION long

switch (uname)
    case Darwin
        test -x /opt/homebrew/bin/brew; and /opt/homebrew/bin/brew shellenv fish | source
    case Linux
        set -gx JAVA_HOME /usr/lib/jvm/java-17-openjdk
        set -gx ANDROID_HOME $HOME/Android/Sdk
        set -gx ANDROID_SDK_ROOT $ANDROID_HOME
        fish_add_path --global $JAVA_HOME/bin
        fish_add_path --global /opt/android-sdk/cmdline-tools/latest/bin
        fish_add_path --global $ANDROID_HOME/platform-tools
        set -gx BLENDER_SYSTEM_SCRIPTS $HOME/.local/share/blender-gpu
end

if status is-interactive
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'

    mise activate fish | source
    starship init fish | source
end
