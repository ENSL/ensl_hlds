FROM ubuntu

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install wget lib32gcc1 lib32stdc++6 libcurl3:i386 unzip liblz4-tool gcc-multilib g++-multilib

# Accept ToS
RUN printf "\n2\n"|apt-get install -y steamcmd

RUN useradd -m steam

USER steam
WORKDIR /home/steam

RUN mkdir -p /home/steam/hlds/steamapps/

# Run app validate several times workaround HLDS bug
RUN /usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate +app_update 90 +quit ||true

# HLDS bug workaround. Whee.
COPY --chown=steam files/*.acf /home/steam/hlds/steamapps/

# HLDS bug workaround. Geez. 
RUN printf "quit\nquit\n"|/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate ||true
RUN printf "quit\nquit\n"|/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate ||true
RUN printf "quit\nquit\nquit\nquit\nquit\n" |/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate ||true

# HLDS bug workaround. Yay.
RUN mkdir -p ~/.steam/sdk32 && ln -s ~/.steam/steamcmd/linux32/steamclient.so ~/.steam/sdk32/steamclient.so

WORKDIR /home/steam/hlds

# NS bug workaround. Since NS links to a GCC which is not included in the steam-provided libstdc++:i386
RUN mv libstdc++* /home/steam/

# Install NS
RUN wget 'https://github.com/ENSL/NS/releases/download/v3.2.2/ns_v322_full.zip'
COPY --chown=steam files/ns.sha /home/steam/hlds
# RUN sha256sum -c ns.sha
RUN unzip ns_v322_full.zip

WORKDIR /home/steam/hlds/ns

# NS workarounds
RUN echo 70 > steam_appid.txt
# RUN mv dlls/ns_i386.so dlls/ns.so || echo

# ENSL package
RUN cp liblist.gam liblist.bak
# RUN wget https://github.com/ENSL/ensl-plugin/releases/download/v1.4/ensl_srvpkg-v1.4.zip -O srv.zip
RUN wget https://github.com/ENSL/ensl-plugin/releases/download/1.4-extra/ENSL_SrvPkg-1.4-extra.zip -O srv.zip
RUN unzip -o srv.zip

# Use seperate server.cfg because autoexec.cfg is unreliable
RUN touch /home/steam/hlds/ns/server.cfg

# Copy own configs including bans
ADD overlay /home/steam/hlds/ns/
COPY scripts/*.sh /home/steam/hlds/

USER root
RUN chown -R steam /home/steam/hlds
RUN apt-get install -y libstdc++6:i386
USER steam

WORKDIR /home/steam/hlds

# VAC, HLDS, RCON, HLTV
EXPOSE 26900
EXPOSE 27016/udp
EXPOSE 27016
EXPOSE 27020

# ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/home/steam/hlds/entry.sh"]
