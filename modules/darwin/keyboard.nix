{
  homebrew.casks = [ "eurkey-next" ];

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
}
