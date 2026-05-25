FROM factoriotools/factorio

# Build context is the directory containing sosciencity/ and sosciencity-graphics/ as siblings.
# Local:  cd mods/ && docker build -t sosciencity-snapshot -f sosciencity/snapshot-setup/Dockerfile .
# Then run via: bash sosciencity/generate-snapshot.sh

ENV MODS=/factorio/mods

COPY sosciencity                              "$MODS/sosciencity"
COPY sosciencity-graphics                     "$MODS/sosciencity-graphics"
COPY sosciencity-balancing                    "$MODS/sosciencity-balancing"

COPY sosciencity/snapshot-setup/mod-list.json        "$MODS/mod-list.json"
COPY sosciencity/snapshot-setup/server-settings.json /factorio/config/server-settings.json
COPY sosciencity/snapshot-setup/snapshot-entrypoint.sh /snapshot-entrypoint.sh

RUN chmod +x /snapshot-entrypoint.sh

ENTRYPOINT ["/snapshot-entrypoint.sh"]
