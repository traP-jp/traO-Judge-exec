# traO-Judge-exec

## Tasks

[![xc compatible](https://xcfile.dev/badge.svg)](https://xcfile.dev)

### Build

実行環境コンテナをビルド

```shell
docker build -t trao-exec-builder docker/builder
docker volume create trao-exec_build-cache
docker run --rm -w /workspace -v trao-exec_build-cache:/nix -v .:/workspace --privileged trao-exec-builder docker/build.sh
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
docker build -t trao-exec-builder docker/builder
docker volume create trao-exec_build-cache
docker run --rm -w /workspace -v trao-exec_build-cache:/nix -v .:/workspace --privileged trao-exec-builder docker/license-check.sh
```

### Lang

言語情報ファイルを生成

```shell
docker build -t trao-exec-builder docker/builder
docker volume create trao-exec_build-cache
docker run --rm -w /workspace -v trao-exec_build-cache:/nix -v .:/workspace --privileged trao-exec-builder docker/languageSettings.sh
```
