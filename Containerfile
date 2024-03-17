FROM registry.fedoraproject.org/fedora-toolbox:39

LABEL com.github.containers.toolbox="true" \
      name="toolbox-nix" \
      version="23.11" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Base image for creating Fedora with Nix toolbox containers" \
      maintainer="Miroslav Vadkerti <mvadkert@redhat.com>"

COPY nix.sh /etc/profile.d/nix.sh
