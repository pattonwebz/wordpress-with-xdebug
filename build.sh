#!/bin/bash

# List of PHP versions to build
PHP_VERSIONS=("7.0" "7.1" "7.2" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")

# Base image name
IMAGE_NAME="pattonwebz/local-wordpress-with-xdebug"

# Build for all versions
for version in "${PHP_VERSIONS[@]}"; do
    echo "Building image for PHP $version..."
    docker build --build-arg PHP_VERSION="php${version}-apache" -t "${IMAGE_NAME}:php${version}-apache" .

    # Tag latest for the newest stable version (currently 8.2)
    if [ "$version" = "8.2" ]; then
        docker tag $IMAGE_NAME:"php${version}-apache" $IMAGE_NAME:latest
        echo "Tagged PHP $version as latest"
    fi
done

echo "All images built successfully"
echo "Available images:"
docker images | grep $IMAGE_NAME
