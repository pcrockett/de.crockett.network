#!/usr/bin/env bash

# TODO: Build a Dendrite image and run it.
#
#     https://github.com/matrix-org/dendrite/tree/master/build/docker
#
# The following is a work in progress.

image_name="docker.io/matrixdotorg/dendrite-monolith:latest"
container_name="dendrite"
container_data_dir="/etc/dendrite" # The path where Dendrite data is stored inside the container
volume="dendrite-data:${container_data_dir}"

if run_unprivileged podman container exists "${container_name}"; then
    run_unprivileged podman container start "${container_name}"
else

    # First run. Generate keys and save them in the dendrite-data volume.
    run_unprivileged podman container run \
        --entrypoint /usr/bin/generate-keys \
        --volume "${volume}" \
        "${image_name}" \
        "--private-key=${container_data_dir}/matrix_key.pem" \
        "--tls-cert=${container_data_dir}/server.crt" \
        "--tls-key=${container_data_dir}/server.key"

    # TODO: Place Dendrite config file in the volume as well.

    # Now create the actual container where Dendrite will run
    run_unprivileged podman container create \
        --name "${container_name}" \
        --publish 8008:8008 \
        --publish 8448:8448 \
        --volume "${volume}" \
        "${image_name}"

    run_unprivileged podman container start "${container_name}"
fi
