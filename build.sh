#!/bin/bash

# List of PHP versions to build
PHP_VERSIONS=("7.0" "7.1" "7.2" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")

# Base image name
IMAGE_NAME="pattonwebz/local-wordpress-with-xdebug"

# Check if --multi-arch flag is passed
MULTI_ARCH=false
PUSH_IMAGES=false

for arg in "$@"; do
  if [ "$arg" == "--multi-arch" ]; then
    MULTI_ARCH=true
  elif [ "$arg" == "--push" ]; then
    PUSH_IMAGES=true
  fi
done

# Set up buildx if multi-arch is requested
if [ "$MULTI_ARCH" = true ]; then
  echo "Setting up Docker Buildx for multi-architecture builds..."
  docker buildx create --name multiarch --use 2>/dev/null || docker buildx use multiarch
  docker buildx inspect --bootstrap

  PLATFORMS="linux/amd64,linux/arm64"
  BUILDX_CMD="buildx build --platform $PLATFORMS"

  if [ "$PUSH_IMAGES" = true ]; then
    BUILDX_CMD="$BUILDX_CMD --push"
  else
    BUILDX_CMD="$BUILDX_CMD --load"
  fi
else
  BUILDX_CMD="build"
fi

echo "Build command: docker $BUILDX_CMD"

# Build for all versions
for version in "${PHP_VERSIONS[@]}"; do
    echo "Building image for PHP $version..."

    if [ "$MULTI_ARCH" = true ]; then
      docker $BUILDX_CMD --build-arg PHP_VERSION="php${version}-apache" -t "${IMAGE_NAME}:php${version}-apache" .
    else
      docker build --build-arg PHP_VERSION="php${version}-apache" -t "${IMAGE_NAME}:php${version}-apache" .
    fi

    # Tag latest for the newest stable version (currently 8.2)
    if [ "$version" = "8.2" ] && [ "$MULTI_ARCH" = false ]; then
        docker tag $IMAGE_NAME:"php${version}-apache" $IMAGE_NAME:latest
        echo "Tagged PHP $version as latest"
    elif [ "$version" = "8.2" ] && [ "$MULTI_ARCH" = true ] && [ "$PUSH_IMAGES" = true ]; then
        # For multi-arch with push, need to create the latest tag with buildx
        docker $BUILDX_CMD --build-arg PHP_VERSION="php${version}-apache" -t "${IMAGE_NAME}:latest" .
        echo "Tagged PHP $version as latest"
    fi
done

echo "All images built successfully"
echo "Available images:"
docker images | grep $IMAGE_NAME
