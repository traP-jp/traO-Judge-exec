#!/bin/sh

# コンテナビルド
if ! nix build -o /tmp/result .#languageSettings
then
  exit 1
fi

# ビルド結果をコピー
realpath /tmp/result | xargs -I {} cp {}/languages.json ./languages.json
