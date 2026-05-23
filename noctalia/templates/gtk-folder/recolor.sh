#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="WhiteSur-Matugen"
TEMPLATE_DIR="$HOME/.config/noctalia/templates/WhiteSur-Matugen-template"
TARGET_DIR="$HOME/.local/share/icons/$THEME_NAME"
WORK_DIR="$HOME/.cache/noctalia/$THEME_NAME.tmp"

FOLDER_BODY="{{colors.primary.default.hex}}"
FOLDER_BODY_DARK="{{colors.primary_container.default.hex}}"
FOLDER_BODY_LIGHT="{{colors.primary_fixed.default.hex}}"
FOLDER_HIGHLIGHT="{{colors.primary_fixed_dim.default.hex}}"
FOLDER_EDGE="{{colors.outline.default.hex}}"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Missing WhiteSur template: $TEMPLATE_DIR" >&2
  exit 1
fi

rm -rf "$WORK_DIR"
mkdir -p "$(dirname "$WORK_DIR")" "$(dirname "$TARGET_DIR")"
cp -a "$TEMPLATE_DIR" "$WORK_DIR"

sed -i "s/^Name=.*/Name=$THEME_NAME/" "$WORK_DIR/index.theme"

recolor_files() {
  local dir="$1"

  # WhiteSur folder SVGs use several blue stops plus color/style attributes.
  # Replacing all known blue folder tones keeps the original shapes and most
  # shading while letting Noctalia drive the visible folder color.
  find "$dir" -maxdepth 1 -type f \
    \( -name "folder*.svg" -o -name "user-home*.svg" -o -name "user-desktop*.svg" -o -name "inode-directory*.svg" \) \
    -print0 | xargs -0 -r sed -i \
      -e "s/#009ef8/$FOLDER_BODY_DARK/g" \
      -e "s/#008ea2/$FOLDER_BODY_DARK/g" \
      -e "s/#27affa/$FOLDER_BODY/g" \
      -e "s/#3ab8fb/$FOLDER_BODY/g" \
      -e "s/#46a2d7/$FOLDER_BODY/g" \
      -e "s/#60c0f0/$FOLDER_BODY/g" \
      -e "s/#60c4fb/$FOLDER_HIGHLIGHT/g" \
      -e "s/#83d4fb/$FOLDER_BODY_LIGHT/g" \
      -e "s/#a4caee/$FOLDER_BODY/g" \
      -e "s/#438de6/$FOLDER_BODY_DARK/g" \
      -e "s/#62a0ea/$FOLDER_BODY/g" \
      -e "s/#afd4ff/$FOLDER_BODY_LIGHT/g" \
      -e "s/#c0d5ea/$FOLDER_BODY_LIGHT/g"
}

recolor_files "$WORK_DIR/places/scalable"

install_custom_icon_links() {
  # WhiteSur-Matugen keeps most app and mime directories as links into the
  # base WhiteSur theme. Add local aliases there so they survive regeneration.
  local base="$HOME/.local/share/icons/WhiteSur"

  mkdir -p "$base/apps/scalable" "$base/mimes/16" "$base/mimes/22" "$base/mimes/scalable"

  ln -sf ../../../WhiteSur-Matugen/apps/22/preferences-system-network-vpn.svg "$base/apps/scalable/flclash.svg"
  ln -sf ../../../WhiteSur-Matugen/apps/22/preferences-system-network-vpn.svg "$base/apps/scalable/io.github.radiolamp.mangojuice.svg"
  ln -sf ../../../WhiteSur-Matugen/apps/22/preferences-desktop-theme-applications.svg "$base/apps/scalable/nwg-look.svg"
  ln -sf ../../../WhiteSur-Matugen/apps/22/preferences-desktop-theme-applications.svg "$base/apps/scalable/dev.noctalia.noctalia-qs.svg"
  ln -sf ../../../WhiteSur-Matugen/apps/22/system-file-manager.svg "$base/apps/scalable/yazi.svg"
  ln -sf accessories-screenshot.svg "$base/apps/scalable/satty.svg"
  ln -sf audio-player.svg "$base/apps/scalable/SPlayer.svg"

  ln -sf application-x-shellscript.svg "$base/mimes/scalable/application-x-dotfile.svg"
  ln -sf text-x-script.svg "$base/mimes/16/application-x-dotfile.svg"
  ln -sf text-x-script.svg "$base/mimes/22/application-x-dotfile.svg"
}

install_custom_icon_links

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f "$HOME/.local/share/icons/WhiteSur" || true
  gtk-update-icon-cache -q -f "$WORK_DIR" || true
fi

rm -rf "$TARGET_DIR"
mv "$WORK_DIR" "$TARGET_DIR"

if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface icon-theme "$THEME_NAME" || true
fi
