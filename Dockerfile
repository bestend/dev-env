FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=1000
ARG TZ=Asia/Seoul
ARG NODE_MAJOR=24
ARG PNPM_VERSION=11.1.2
ARG CODEX_VERSION=0.130.0
ARG CLAUDE_CODE_VERSION=2.1.143
ARG CODE_SERVER_VERSION=4.118.0
ARG UV_VERSION=0.11.14
ARG LAZYGIT_VERSION=0.61.1

ENV TZ=${TZ} \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TARGET_USER=${USERNAME} \
    TARGET_HOME=/home/${USERNAME} \
    SHELL=/usr/bin/zsh \
    NODE_MAJOR=${NODE_MAJOR} \
    PNPM_VERSION=${PNPM_VERSION} \
    CODEX_VERSION=${CODEX_VERSION} \
    CLAUDE_CODE_VERSION=${CLAUDE_CODE_VERSION} \
    CODE_SERVER_VERSION=${CODE_SERVER_VERSION} \
    UV_VERSION=${UV_VERSION} \
    LAZYGIT_VERSION=${LAZYGIT_VERSION}

COPY scripts/ /opt/dev-image/scripts/
COPY home/ /opt/dev-image/home/
COPY docs/dev-image.md /opt/dev-image/docs/dev-image.md
COPY .env.example /opt/dev-image/.env.example

RUN chmod +x /opt/dev-image/scripts/*.sh \
    && /opt/dev-image/scripts/install-system-tools.sh

RUN existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)" \
    && existing_group="$(getent group "${USER_GID}" | cut -d: -f1 || true)" \
    && if [ -z "${existing_group}" ]; then groupadd --gid "${USER_GID}" "${USERNAME}"; existing_group="${USERNAME}"; fi \
    && if id -u "${USERNAME}" >/dev/null 2>&1; then \
         usermod --gid "${existing_group}" --shell /usr/bin/zsh "${USERNAME}"; \
       elif [ -n "${existing_user}" ]; then \
         usermod --login "${USERNAME}" "${existing_user}"; \
         usermod --home "/home/${USERNAME}" --move-home --gid "${existing_group}" --shell /usr/bin/zsh "${USERNAME}"; \
       else \
         useradd --uid "${USER_UID}" --gid "${existing_group}" -m -s /usr/bin/zsh "${USERNAME}"; \
       fi \
    && usermod --append --groups sudo "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/90-${USERNAME} \
    && chmod 0440 /etc/sudoers.d/90-${USERNAME} \
    && mkdir -p /workspace /var/run/sshd /etc/skel/.config \
    && chown -R "${USER_UID}:${USER_GID}" /workspace

RUN /opt/dev-image/scripts/install-runtimes.sh \
    && /opt/dev-image/scripts/install-codex.sh \
    && /opt/dev-image/scripts/install-claude.sh \
    && /opt/dev-image/scripts/install-code-server.sh

RUN /opt/dev-image/scripts/configure-shell.sh \
    && /opt/dev-image/scripts/configure-fzf.sh \
    && /opt/dev-image/scripts/configure-theme.sh \
    && /opt/dev-image/scripts/configure-dotfiles.sh \
    && /opt/dev-image/scripts/configure-tmux.sh \
    && /opt/dev-image/scripts/configure-ssh.sh \
    && install -m 0755 /opt/dev-image/scripts/entrypoint.sh /usr/local/bin/dev-entrypoint.sh \
    && install -m 0755 /opt/dev-image/scripts/healthcheck.sh /usr/local/bin/dev-healthcheck.sh \
    && chown -R "${USER_UID}:${USER_GID}" "/home/${USERNAME}" /workspace \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workspace

EXPOSE 2222 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 CMD ["/usr/local/bin/dev-healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/dev-entrypoint.sh"]
CMD ["sleep", "infinity"]
