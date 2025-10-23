#!/bin/bash
#
# Copyright (C) 2023 cs59 (original author)
# Copyright (C) 2025 com.iOShAT.telegram (modifications)
#
# Original: https://github.com/cs59/Dylib-to-Deb-Converter
#
# Licensed under GPLv3 - see LICENSE for details
# SPDX-License-Identifier: GPL-3.0-only
#
set -- *.dylib
if [ $# -eq 0 ]; then
    echo "エラー: dylib ファイルが見つかりません。"
    exit 1
fi

echo "dylibが見つかりました！:"
i=1
for file; do
    printf " %s) %s\n" "$i" "$file"
    eval "DYLIB_OPTION_$i=\"$file\""
    i=$((i + 1))
done

echo "使用する .dylib ファイルの番号を入力してください:"
read SELECTED_NUM

if ! [ "$SELECTED_NUM" -ge 1 ] 2>/dev/null || [ "$SELECTED_NUM" -ge "$i" ]; then
    echo "エラー: 無効な選択です。"
    exit 1
fi

eval "DYLIB_PATH=\"\$DYLIB_OPTION_$SELECTED_NUM\""
if [ -z "${DYLIB_PATH}" ]; then
    echo "エラー: .dylib のパスは必須です。"
    exit 1
fi

if [ ! -f "${DYLIB_PATH}" ]; then
    echo "エラー: 指定された .dylib ファイルが存在しないか、権限がありません。"
    exit 2
fi
DYLIB_FILENAME=$(basename "$DYLIB_PATH")
DYLIB_BASE_NAME=${DYLIB_FILENAME%.dylib}
MODIFIED_DYLIB_NAME=$(echo "$DYLIB_BASE_NAME" | tr -d ' ')".dylib"
echo "パッケージのバージョンを入力してください（デフォルト: 1.0）:"
read VERSION
VERSION=${VERSION:-1.0}
echo "パッケージの説明を入力してください:"
read DESCRIPTION
DESCRIPTION=${DESCRIPTION:-"iOS用のダイナミックライブラリパッケージ"}
echo "ジェイルブレイクの種類を選択してください:"
echo " 1) Rootless"
echo " 2) Rootful"
read JAILBREAK_NUM

PKG_SUFFIX=""
ARCH="iphoneos-arm"
INSTALL_PATH="/Library/MobileSubstrate/DynamicLibraries"

case "$JAILBREAK_NUM" in
    1)
        ARCH="iphoneos-arm64"
        PKG_SUFFIX="-Rootless"
        INSTALL_PATH="/var/jb/Library/MobileSubstrate/DynamicLibraries"
        echo "Rootless 環境向けに設定中..."
        ;;
    2)
        PKG_SUFFIX="-Rootful"
        echo "Rootful 環境向けに設定中..."
        ;;
    *)
        echo "エラー: 1 または 2 を入力してください。"
        exit 1
        ;;
esac

echo "バンドル識別子を入力してください（デフォルト: com.apple.springboard）:"
read BUNDLE_ID
BUNDLE_ID=${BUNDLE_ID:-"com.apple.springboard"}

MAINTAINER_NAME="com.iOShAT.telegram"
OUTPUT_DIR="$(pwd)"
DEB_FOLDER="${MODIFIED_DYLIB_NAME}_${ARCH}${PKG_SUFFIX}"
DEB_PACKAGE="${OUTPUT_DIR}/${DEB_FOLDER}.deb"

# ディレクトリ作成
mkdir -p "${DEB_FOLDER}/DEBIAN"
mkdir -p "${DEB_FOLDER}${INSTALL_PATH}"

# .dylib をコピーし、スペースを削除した名前で保存
cp "${DYLIB_PATH}" "${DEB_FOLDER}${INSTALL_PATH}/${MODIFIED_DYLIB_NAME}"

# .plist ファイルを作成
PLIST_PATH="${DEB_FOLDER}${INSTALL_PATH}/${MODIFIED_DYLIB_NAME%.dylib}.plist"
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
 <key>Filter</key>
 <dict>
  <key>Bundles</key>
  <array>
   <string>$BUNDLE_ID</string>
  </array>
 </dict>
</dict>
</plist>
EOF

# control ファイルを作成
cat > "${DEB_FOLDER}/DEBIAN/control" <<EOF
Package: ${MODIFIED_DYLIB_NAME%.dylib}$PKG_SUFFIX
Version: $VERSION
Architecture: $ARCH
Maintainer: $MAINTAINER_NAME
Description: $DESCRIPTION
EOF

# パッケージをビルド
if dpkg-deb --build "${DEB_FOLDER}" > /dev/null; then
    mv "${DEB_FOLDER}.deb" "${DEB_PACKAGE}"
    echo "パッケージが作成されました: ${DEB_PACKAGE}"
    rm -rf "${DEB_FOLDER}"
else
    echo "エラー: .deb パッケージの作成に失敗しました。"
    exit 3
fi