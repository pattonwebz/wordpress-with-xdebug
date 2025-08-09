# WordPress with Xdebug, Redis and Intl

This repository contains lightweight Docker images for WordPress with Xdebug, Redis and the PHP Intl extension pre-installed, designed for local development environments.

## Available Tags

Multi-architecture images (amd64, arm64) available for various PHP versions:

- `pattonwebz/local-wordpress-with-xdebug:php8.0-apache`
- `pattonwebz/local-wordpress-with-xdebug:php8.1-apache`
- `pattonwebz/local-wordpress-with-xdebug:php8.2-apache` (also tagged as `latest`)
- `pattonwebz/local-wordpress-with-xdebug:php8.3-apache`
- `pattonwebz/local-wordpress-with-xdebug:php8.4-apache`

Legacy PHP 7 versions are also available but no longer actively maintained:

- `pattonwebz/local-wordpress-with-xdebug:php7.0-apache`
- `pattonwebz/local-wordpress-with-xdebug:php7.1-apache`
- `pattonwebz/local-wordpress-with-xdebug:php7.2-apache`
- `pattonwebz/local-wordpress-with-xdebug:php7.4-apache`

## Features

- Lightweight WordPress base images
- Xdebug pre-installed and configured (Xdebug 2.x for PHP 7, Xdebug 3.x for PHP 8+)
- Redis PHP extension
- PHP Intl extension
- Multi-architecture support (amd64, arm64)

## Usage

```bash
docker run -d -p 8080:80 pattonwebz/local-wordpress-with-xdebug:php8.2-apache
```

### Xdebug Configuration

- For PHP 7.x images: Xdebug 2.x is configured on port 9000
- For PHP 8.x images: Xdebug 3.x is configured on port 9003

### Using with Apple Silicon Macs or Raspberry Pi

The images support both amd64 (standard x86_64) and arm64 architectures, making them compatible with Apple Silicon Macs (M1/M2/M3) and Raspberry Pi devices without any special configuration.

## Building the Images

You can build images locally using the provided `build.sh` script:

```bash
# Build for your current architecture
./build.sh

# Build multi-architecture images
./build.sh --multi-arch
```

## Automated Builds

Images are automatically built and pushed to Docker Hub using GitHub Actions:
- On the 1st of each month to incorporate security updates
- Manually triggered builds as needed

## License

This project is open-sourced under the MIT license.
