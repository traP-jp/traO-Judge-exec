# check=skip=FromPlatformFlagConstDisallowed
# hadolint ignore=DL3006,DL3029
FROM --platform=amd64 nixos/nix

# configの修正
RUN printf "filter-syscalls = false\nexperimental-features = nix-command flakes\nsandbox = true" >> /etc/nix/nix.conf