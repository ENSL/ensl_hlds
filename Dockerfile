FROM ubuntu AS Ubuntu_SteamCMD

# Get Package Dependencies, Accept ToS with Steam Dependency, clear appt cache
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install \
    wget \
    lib32gcc1 \
    lib32stdc++6 \
    libstdc++6:i386 \
    libcurl3:i386 \
    gcc-multilib \
    g++-multilib \
    unzip \
    liblz4-tool \
    # Fro env subst
    gettext-base && \
    # Install steam
    printf "\n2\n" |apt-get install -y steamcmd && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m steam

USER steam
WORKDIR /home/steam

FROM Ubuntu_SteamCMD AS SteamCMD_HLDS

RUN mkdir -p /home/steam/hlds/steamapps/

# Run app validate several times workaround HLDS bug
RUN /usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate +app_update 90 +quit ||true

# HLDS bug workaround. Whee.
COPY --chown=steam files/*.acf /home/steam/hlds/steamapps/

# HLDS bug workaround. Geez.
RUN printf "quit\nquit\n"|/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate ||true && \
    printf "quit\nquit\n"|/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate ||true && \
    printf "quit\nquit\nquit\nquit\nquit\n" |/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate ||true

# HLDS bug workaround. Yay.
RUN mkdir -p ~/.steam/sdk32 && ln -s ~/.steam/steamcmd/linux32/steamclient.so ~/.steam/sdk32/steamclient.so

COPY scripts/*.sh /home/steam/hlds/

FROM SteamCMD_HLDS AS HLDS_NS

ARG NS_URL='https://github.com/ENSL/NS/releases/download/v3.2.2/ns_v322_full.zip'

WORKDIR /home/steam/hlds

COPY --chown=steam files/ns.sha /home/steam/hlds

# NS bug workaround. Since NS links to a GCC which is not included in the steam-provided libstdc++:i386
RUN mv /home/steam/hlds/libstdc++* /home/steam/ && \
    # Install NS
    wget "$NS_URL" && \
    unzip ns_*.zip && \
    cp /home/steam/hlds/ns/liblist.gam /home/steam/hlds/ns/liblist.bak

FROM HLDS_NS AS HLDS_ENSL

ARG PLUGIN_URL='https://github.com/ENSL/ensl-plugin/releases/download/1.4-extra/ENSL_SrvPkg-1.4-extra.zip'

WORKDIR /home/steam/hlds/ns

# ENSL package
RUN wget "$PLUGIN_URL" -O srv.zip && \
    unzip -o srv.zip && \
    # Use seperate server.cfg because autoexec.cfg is unreliable
    touch /home/steam/hlds/ns/server.cfg

# Copy own configs including bans
ADD overlay /home/steam/hlds/ns/

#USER root
#RUN chown -R steam /home/steam/hlds
#USER steam

WORKDIR /home/steam/hlds

# VAC Service
EXPOSE 26900 \
    # HLDS 
    27016 \
    # HLDS RCON
    27016/udp \
    # HLTV
    27020

# ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/home/steam/hlds/entry.sh"]
