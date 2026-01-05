#!/bin/bash
# Install pg_probackup for PostgreSQL 17
# Tested on Ubuntu/Debian
set -e

echo "=== Installing pg_probackup for PostgreSQL 17 ==="

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y \
    postgresql-server-dev-17 \
    build-essential \
    git \
    zlib1g-dev \
    bison \
    flex \
    libicu-dev \
    pkg-config \
    liblz4-dev \
    libzstd-dev \
    libreadline-dev

# Create build directory
BUILD_DIR="/tmp/pg_probackup_build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download PostgreSQL source
echo "Downloading PostgreSQL 17 source..."
git clone --branch REL_17_STABLE --depth 1 https://github.com/postgres/postgres.git postgresql-src

# Clone pg_probackup
echo "Downloading pg_probackup..."
git clone --branch REL_2_5 https://github.com/postgrespro/pg_probackup.git

# Build PostgreSQL from source
echo "Building PostgreSQL 17 from source..."
cd "$BUILD_DIR/postgresql-src"
./configure --prefix=/usr/local/pgsql-17
make -j$(nproc)
sudo make install

# Build pg_probackup
echo "Building pg_probackup..."
cd "$BUILD_DIR/pg_probackup"
make USE_PGXS=1 PG_CONFIG=/usr/local/pgsql-17/bin/pg_config top_srcdir="$BUILD_DIR/postgresql-src"
sudo make USE_PGXS=1 PG_CONFIG=/usr/local/pgsql-17/bin/pg_config top_srcdir="$BUILD_DIR/postgresql-src" install

# Verify installation
echo ""
echo "=== Verification ==="
/usr/local/pgsql-17/bin/pg_probackup --version

# Cleanup
echo ""
echo "Cleaning up build files..."
rm -rf "$BUILD_DIR"

echo ""
echo "=== pg_probackup for PostgreSQL 17 installed successfully! ==="
echo "Binary location: /usr/local/pgsql-17/bin/pg_probackup"
