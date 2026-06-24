FROM factoriotools/factorio:2.1

# Build context is the directory containing sosciencity/ and sosciencity-graphics/ as siblings.
# Local:  cd mods/ && docker build -t sosciencity-test -f sosciencity/test-setup/Dockerfile .
# CI:     run from workspace root after checking out both repos as siblings

ENV MODS=/factorio/mods

COPY sosciencity                               "$MODS/sosciencity"
COPY sosciencity-graphics                      "$MODS/sosciencity-graphics"
COPY sosciencity/test-setup/sosciencity-debug  "$MODS/sosciencity-debug"

COPY sosciencity/test-setup/mod-list.json         "$MODS/mod-list.json"
COPY sosciencity/test-setup/server-settings.json  /factorio/config/server-settings.json
COPY sosciencity/test-setup/tests-entrypoint.sh   /tests-entrypoint.sh

RUN chmod +x /tests-entrypoint.sh

ENTRYPOINT ["/tests-entrypoint.sh"]
