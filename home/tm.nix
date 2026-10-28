{ link, ... }:
{
  home.stateVersion = "26.05";

  xdg.configFile = {
    "fish/config.fish".source = link "config/fish/config.fish";
    "git/config".source = link "config/git/config";
    "gh/config.yml".source = link "config/gh/config.yml";
    "mise/config.toml".source = link "config/mise/config.toml";
    "zed/settings.json".source = link "config/zed/settings.json";
  };

  home.file = {
    ".pi/agent/settings.json".source = link "pi/settings.json";
    ".pi/agent/APPEND_SYSTEM.md".source = link "pi/APPEND_SYSTEM.md";
    ".pi/agent/skills".source = link "pi/skills";
  };
}
