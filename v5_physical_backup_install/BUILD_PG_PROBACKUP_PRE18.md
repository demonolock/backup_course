# Building pg_probackup for PostgreSQL 17

**OS:** Ubuntu/Debian (tested on Ubuntu 22.04)
**PostgreSQL version:** 17.x

## Prerequisites

1. PostgreSQL 17 installed
2. Build tools and development libraries
3. Internet access (to download sources)

## Quick Installation

```bash
# 1. Install dependencies
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

# 2. Create build directory
BUILD_DIR="/tmp/pg_probackup_build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 3. Download sources
git clone --branch REL_17_STABLE --depth 1 https://github.com/postgres/postgres.git postgresql-src
git clone https://github.com/postgrespro/pg_probackup.git

# 4. Build PostgreSQL from source
cd "$BUILD_DIR/postgresql-src"
./configure --prefix=/usr/local/pgsql-17
make -j$(nproc)
sudo make install

# 5. Build pg_probackup
cd "$BUILD_DIR/pg_probackup"
make USE_PGXS=1 PG_CONFIG=/usr/local/pgsql-17/bin/pg_config top_srcdir="$BUILD_DIR/postgresql-src"
sudo make USE_PGXS=1 PG_CONFIG=/usr/local/pgsql-17/bin/pg_config top_srcdir="$BUILD_DIR/postgresql-src" install

# 6. Verify
/usr/local/pgsql-17/bin/pg_probackup --version

# 7. Cleanup (optional)
rm -rf "$BUILD_DIR"
```

## Verification

```bash
# Check installation
/usr/local/pgsql-17/bin/pg_probackup --version

# Test basic functionality
mkdir -p /tmp/test_backups
/usr/local/pgsql-17/bin/pg_probackup init -B /tmp/test_backups
/usr/local/pgsql-17/bin/pg_probackup show -B /tmp/test_backups
echo "pg_probackup for PostgreSQL 17 installed successfully!"
```

## Dependencies Explained

### Critical (build impossible without these)

| Package | Purpose |
|---------|---------|
| `postgresql-server-dev-17` | PostgreSQL headers (`.h`) and libraries |
| `build-essential` | `gcc` compiler, `ld` linker, `make` utility |
| `git` | Clone repositories from GitHub |
| `bison`, `flex` | Parser generators for PostgreSQL build |
| `libicu-dev`, `pkg-config` | ICU library for Unicode support |
| `libreadline-dev` | Readline library for PostgreSQL |

### Recommended (for full functionality)

| Package | Purpose |
|---------|---------|
| `zlib1g-dev` | Compression with `--compress-algorithm=zlib` |
| `liblz4-dev` | LZ4 compression support |
| `libzstd-dev` | ZSTD compression support |

## Automated Installation Script

Save as `install_pg_probackup_pg17.sh` and run with `sudo bash install_pg_probackup_pg17.sh`:

```bash
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
git clone https://github.com/postgrespro/pg_probackup.git

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
```

## Docker Installation

You can also build pg_probackup using Docker:

### Build Docker Image

```bash
docker build -f Dockerfile.pg17-probackup -t pg17-probackup .
```

### Run Container Interactively for test

Be careful, running like this is only for test, data will be removed when container stop.
```bash
docker run -it --rm -v $(pwd):/workspace pg17-probackup bash
```

# Run Container with volume for saving pgdata data

```bash
  docker run -it --rm \
    -v $(pwd):/workspace \
    -v $(pwd)/pgdata:/var/lib/postgresql/data \
    pg17-probackup bash
```

### Verify Inside Container

```bash
pg_probackup --version
cd /workspace
```

## Important Notes

1. **No patch required** - PostgreSQL 17 works with pg_probackup without modifications
2. **PostgreSQL build required** - pg_probackup needs PostgreSQL source headers
3. **Build time** - PostgreSQL build takes ~3-5 minutes depending on hardware
4. **Disk space** - Requires ~1GB for build, cleaned up after installation
5. **Binary location** - Installed to `/usr/local/pgsql-17/bin/pg_probackup`
6. **pg_config location** - `/usr/local/pgsql-17/bin/pg_config`
7. **PostgreSQL installation** - `/usr/local/pgsql-17/`
