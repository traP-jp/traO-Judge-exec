FROM mcr.microsoft.com/devcontainers/base
COPY nix.conf /home/vscode/.config/nix/extra.nix.conf
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | \
    sh -s -- \
    --daemon \
    --nix-extra-conf-file /home/vscode/.config/nix/extra.nix.conf \
    --yes

# Starting nix daemon. This is required for non-root users to use Nix.
CMD ["/nix/var/nix/profiles/default/bin/nix", "daemon"]
