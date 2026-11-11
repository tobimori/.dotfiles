{ pkgs, ... }:
let
  version = "16.5";
  sha256 = "8935dacf8a0cdf41164c34402897aa3c44e8688b70674b82ee2daaeb7379a082";
in
{
  # Blackmagic signs every download link and the zip is 1 GB, so it is not a store path
  system.activationScripts.postActivation.text = ''
    if ! pkgutil --pkg-info com.blackmagic-design.DesktopVideo 2>/dev/null | grep -x "version: ${version}" >/dev/null; then
      tmp=$(mktemp -d)
      api=https://www.blackmagicdesign.com/api
      id=$(curl -fsS "$api/support/us/downloads.json" \
        | ${pkgs.jq}/bin/jq -r '.downloads[].urls."Mac OS X"[]? | select(.downloadTitle == "Desktop Video ${version}") | .downloadId') \
        && url=$(curl -fsS -A "Mozilla/5.0" -H "Content-Type: application/json" \
          --data '{"country":"de","downloadOnly":true,"platform":"Mac OS X","policy":true}' \
          "$api/register/us/download/$id") \
        && curl -fsSL --retry 3 -o "$tmp/dv.zip" "$url" \
        && echo "${sha256}  $tmp/dv.zip" | shasum -a 256 -c --status \
        && unzip -q "$tmp/dv.zip" -d "$tmp" \
        && hdiutil attach -nobrowse -readonly -mountpoint "$tmp/mnt" "$tmp/Blackmagic_Desktop_Video_${version}.dmg" >/dev/null \
        && installer -pkg "$tmp/mnt/Install Desktop Video ${version}.pkg" -target / \
        || echo "warning: could not install Desktop Video ${version}"
      hdiutil detach "$tmp/mnt" >/dev/null 2>&1 || true
      rm -rf "$tmp"
    fi
  '';
}
