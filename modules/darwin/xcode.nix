{
  # Homebrew refuses to run until the Xcode license is accepted
  system.activationScripts.preActivation.text = ''
    if [ -d /Applications/Xcode.app ]; then
      xcode-select -s /Applications/Xcode.app
      xcodebuild -license accept
      xcodebuild -runFirstLaunch
      xcrun simctl list runtimes | grep -q '^iOS' || xcodebuild -downloadPlatform iOS
    fi
  '';
}
