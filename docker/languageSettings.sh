#!/bin/sh

# コンテナビルド
if ! nix build --extra-experimental-features nix-command --extra-experimental-features flakes .#languageSettings
then
  exit 1
fi

# /resultに書き込み権限を付与
chmod u+w /result

# ビルド結果をコピー
realpath /workspace/result | xargs -I {} cp {}/languages.json /result

# 読み取り専用に戻す
chmod u-w /result
