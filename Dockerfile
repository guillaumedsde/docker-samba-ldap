
FROM debian:bullseye-slim

ARG DEBIAN_VERSION
ARG DEBIAN_FRONTEND=noninteractive 
ARG DEBCONF_NONINTERACTIVE_SEEN=true
ARG S6_VERSION=v2.0.0.1

LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="samba-ldap" \
  org.label-schema.description="Debian bullseyes based docker image for SAMBA with ldap authentication" \
  org.label-schema.url="https://guillaumedsde.gitlab.io/samba-ldap/" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/guillaumedsde/samba-ldap" \
  org.label-schema.vendor="guillaumedsde" \
  org.label-schema.schema-version="1.0"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  SAMBA_CONFIG=/etc/samba/smb.conf \
  NSLCD_CONFIG=/etc/nslcd.conf

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  samba \
  libnss-ldapd \
  wget \
  && ARCH="$(uname -m)" \
  && if [ "${ARCH}" = "x86_64" ]; then S6_ARCH=amd64; \
  elif [ "${ARCH}" = "i386" ]; then S6_ARCH=X86; \
  elif echo "${ARCH}" | grep -E -q "armv6|armv7"; then S6_ARCH=arm; \
  else S6_ARCH="${ARCH}"; \
  fi \
  && echo using architecture "${S6_ARCH}" for S6 Overlay \
  && wget -O "s6.tgz" "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" \
  && tar xzf "s6.tgz" -C / \ 
  && rm "s6.tgz" \
  && apt-get remove --purge -y wget \
  && apt-get --purge -y autoremove \
  && rm -rf "/var/lib/apt/lists/*" \
  && rm "${SAMBA_CONFIG}" \
  && rm "${NSLCD_CONFIG}"

COPY rootfs/ /

EXPOSE 139 445

ENTRYPOINT ["/init"]
