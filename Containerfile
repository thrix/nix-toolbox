ARG FEDORA_VERSION

FROM registry.fedoraproject.org/fedora-toolbox:$FEDORA_VERSION

LABEL com.github.containers.toolbox="true" \
      name="nix-toolbox" \
      version="$FEDORA_VERSION" \
      usage="This image is meant to be used with the toolbox command." \
      summary="Base image for creating Fedora toolbox containers with pre-installed Nix and optionally home-manager." \
      maintainer="Miroslav Vadkerti <mvadkert@redhat.com>"

RUN dnf -y install gum

COPY nix.sh /etc/profile.d/
