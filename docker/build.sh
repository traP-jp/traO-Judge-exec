#!/bin/sh

# コンテナビルド
if ! nix build -o /tmp/result
then
  exit 1
fi

# ビルド結果をコピー
realpath /tmp/result | xargs -I {} cp {} ./result
