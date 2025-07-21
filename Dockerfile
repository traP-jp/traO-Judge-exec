# hadolint ignore=DL3029
FROM --platform=amd64 nixos/nix:2.30.1

# configの修正、ワークスペースの作成
RUN printf "filter-syscalls = false\nexperimental-features = nix-command flakes" >> /etc/nix/nix.conf \
	&& mkdir /workspace
COPY . /workspace
WORKDIR /workspace

# ビルド成果物用の空ファイル作成とスクリプトの実行権限付与
RUN touch /result \
	&& chmod +x /workspace/docker/build.sh \
	&& chmod +x /workspace/docker/languageSettings.sh \
	&& chmod +x /workspace/docker/license-check.sh

# ビルドキャッシュとビルド成果物、lockファイル
VOLUME [ "/nix", "/result", "/workspace/flake.lock" ]

# ビルド実行
CMD [ "/workspace/docker/build.sh" ]
