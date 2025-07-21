# traO-Judge-exec

## Tasks

[![xc compatible](https://xcfile.dev/badge.svg)](https://xcfile.dev)

### Build

実行環境コンテナをビルド

Environment: OUTPUT=result

```shell
touch $OUTPUT
docker build -t trao-exec .
docker volume create trao-exec_build-cache
docker run -v ./$OUTPUT:/result -v trao-exec_build-cache:/nix -v ./flake.lock:/workspace/flake.lock trao-exec
```

### Load

ビルドしたコンテナをロード

Environment: INPUT=result

```shell
docker load -i $INPUT
```

### License

依存パッケージのライセンスチェックを実行

```shell
touch /tmp/result
docker build -t trao-exec .
docker volume create trao-exec_build-cache
docker run -v /tmp/result:/result -v trao-exec_build-cache:/nix -v ./flake.lock:/workspace/flake.lock trao-exec /workspace/docker/license-check.sh
```

### Lang

言語情報ファイルを生成

Environment: OUTPUT=languages.json

```shell
touch $OUTPUT
docker build -t trao-exec .
docker volume create trao-exec_build-cache
docker run -v ./$OUTPUT:/result -v trao-exec_build-cache:/nix -v ./flake.lock:/workspace/flake.lock trao-exec /workspace/docker/languageSettings.sh
```

### Shell

`trao-nix`イメージのシェルを起動

```shell
touch /tmp/result
docker run -it --rm -v /tmp/result:/result -v trao-exec_build-cache:/nix -v ./flake.lock:/workspace/flake.lock trao-exec /bin/sh
```
