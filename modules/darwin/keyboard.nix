{ asUser, config, ... }:
let
  user = config.system.primaryUser;
in
{
  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
    };
    CustomUserPreferences.NSGlobalDomain.WebAutomaticSpellingCorrectionEnabled = false;
    CustomUserPreferences."com.apple.HIToolbox" =
      let
        eurkey = {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = -31468;
          "KeyboardLayout Name" = "EurKEY Next";
        };
      in
      {
        AppleFnUsageType = 1;
        AppleCurrentKeyboardLayoutInputSourceID = "de.felixfoertsch.keyboardlayout.EurKEY-Next.eurkeynext";
        AppleSelectedInputSources = [ eurkey ];
        AppleEnabledInputSources = [
          eurkey
          {
            InputSourceKind = "Keyboard Layout";
            "KeyboardLayout ID" = 3;
            "KeyboardLayout Name" = "German";
          }
          {
            "Bundle ID" = "com.apple.CharacterPaletteIM";
            InputSourceKind = "Non Keyboard Input Method";
          }
        ];
      };
  };

  # Free the screenshot shortcuts for CleanShot X, and ⌘Space for Vicinae by moving
  # Spotlight (64) to ⌃Space, which input source switching (60) gives up.
  # The parameters must be integers; defaults -dict-add stores strings, which macOS ignores
  system.activationScripts.postActivation.text = ''
    pb=/usr/libexec/PlistBuddy
    hotkeys=$(mktemp)
    chown ${user} "$hotkeys"
    sudo -u ${user} defaults export com.apple.symbolichotkeys "$hotkeys"
    while read -r id enabled key code mods; do
      e=":AppleSymbolicHotKeys:$id"
      $pb -c "Delete $e" "$hotkeys" 2>/dev/null || true
      $pb -c "Add $e dict" -c "Add $e:enabled bool $enabled" -c "Add $e:value dict" \
        -c "Add $e:value:type string standard" -c "Add $e:value:parameters array" \
        -c "Add $e:value:parameters:0 integer $key" -c "Add $e:value:parameters:1 integer $code" \
        -c "Add $e:value:parameters:2 integer $mods" "$hotkeys"
    done <<'EOF'
    28 false 51 20 1179648
    29 false 51 20 1441792
    30 false 52 21 1179648
    31 false 52 21 1441792
    184 false 53 23 1179648
    60 false 32 49 262144
    64 true 32 49 262144
    EOF
    sudo -u ${user} defaults import com.apple.symbolichotkeys "$hotkeys"
    rm -f "$hotkeys"
    ${asUser} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
