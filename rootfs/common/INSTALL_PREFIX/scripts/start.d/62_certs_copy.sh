#!/bin/sh

# In case there are no certificates, copy them
# from ${INSTALL_PREFIX}/certs folder (part of SW release)

mkdir -p /var/certs

if [ ! -r /var/certs/ca.pem ] || \
   [ ! -r /var/certs/client.pem ] || \
   [ ! -r /var/certs/client_dec.key ]; then

    echo "No certs found in flash, using default certs"
    cp ${INSTALL_PREFIX}/certs/ca.pem /var/certs/
    cp ${INSTALL_PREFIX}/certs/client.pem /var/certs/
    cp ${INSTALL_PREFIX}/certs/client_dec.key /var/certs/
fi

cp ${INSTALL_PREFIX}/certs/auth.pem /var/certs/.

