FROM ubuntu

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y install wget lib32gcc1 lib32stdc++6 libcurl3 unzip

RUN printf "\n2\n"|apt-get install -y steamcmd

RUN useradd -m steam

USER steam
WORKDIR /home/steam

RUN mkdir -p /home/steam/hlds/steamapps/

# Run app validate several times workaround HLDS bug
RUN /usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate +app_update 90 +quit

# HLDS bug workaround. Whee.
COPY --chown=steam files/*.acf /home/steam/hlds/steamapps/

# HLDS bug workaround. Geez. 
RUN printf "quit\nquit\n"|/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate || echo
RUN printf "quit\nquit\n"|/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate || echo
RUN printf "quit\nquit\nquit\nquit\nquit\n" |/usr/games/steamcmd +login anonymous +force_install_dir /home/steam/hlds +app_set_config 90 mod valve +app_update 90 validate || echo

# HLDS bug workaround. Yay.
RUN mkdir -p ~/.steam/sdk32 && ln -s ~/.steam/steamcmd/linux32/steamclient.so ~/.steam/sdk32/steamclient.so

WORKDIR /home/steam/hlds

RUN wget 'https://www.ensl.org/files/server/ns_dedicated_server_v32.zip'
COPY --chown=steam files/ns.sha /home/steam/hlds
# RUN sha256sum -c ns.sha

RUN unzip ns_dedicated_server_v32.zip

# NS workaround
RUN echo 70 > ns/steam_appid.txt
RUN mv ns/dlls/ns_i386.so ns/dlls/ns.so

# VAC, HLDS, RCON, HLTV
EXPOSE 26900
EXPOSE 27015/udp
EXPOSE 27015
EXPOSE 27020

ENTRYPOINT ["./hlds_run", "-game ns", "+maxplayers 32", "+log on"]
