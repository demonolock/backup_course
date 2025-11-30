# PostgreSQL 18 Installation Guide for Linux

This guide covers PostgreSQL 18 installation on various Linux distributions. PostgreSQL 18 is the latest version released in November 2024 with improved performance and new features.

## Ubuntu/Debian

### Method 1: Using APT Package Manager (Default Repository)

**Note:** This method installs the PostgreSQL version available in your distribution's default repository, which may not be PostgreSQL 18. For the latest version (PostgreSQL 18), use Method 2 below.

1. **Update package list:**
   ```bash
   sudo apt update
   ```

2. **Install PostgreSQL:**
   ```bash
   sudo apt install postgresql postgresql-contrib
   ```

3. **Start and enable PostgreSQL service:**
   ```bash
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

### Method 2: Using Official PostgreSQL APT Repository (Automated - Recommended for PostgreSQL 18)

1. **Install postgresql-common and run automated setup script:**
   ```bash
   sudo apt install -y postgresql-common ca-certificates
   sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
   ```

2. **Install PostgreSQL 18:**
   ```bash
   sudo apt update
   sudo apt install postgresql-18 postgresql-contrib-18
   ```

3. **Start and enable PostgreSQL service:**
   ```bash
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

### Method 3: Manual APT Repository Setup

1. **Import PostgreSQL signing key (new secure method):**
   ```bash
   sudo apt install curl ca-certificates
   sudo install -d /usr/share/postgresql-common/pgdg
   sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
   ```

2. **Add PostgreSQL APT repository:**
   ```bash
   . /etc/os-release
   sudo sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
   ```

3. **Update package list and install PostgreSQL 18:**
   ```bash
   sudo apt update
   sudo apt install postgresql-18 postgresql-contrib-18
   ```

4. **Start and enable PostgreSQL service:**
   ```bash
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

## CentOS/RHEL/Fedora/Rocky/AlmaLinux

### For Rocky Linux 9/AlmaLinux 9/CentOS Stream 9:

1. **Install PostgreSQL repository:**
   ```bash
   sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
   ```

2. **Disable built-in PostgreSQL module (if present):**
   ```bash
   sudo dnf -qy module disable postgresql
   ```

3. **Install PostgreSQL 18:**
   ```bash
   sudo dnf install -y postgresql18-server postgresql18
   ```

4. **Initialize database:**
   ```bash
   sudo /usr/pgsql-18/bin/postgresql-18-setup initdb
   ```

5. **Start and enable service:**
   ```bash
   sudo systemctl start postgresql-18
   sudo systemctl enable postgresql-18
   ```

### For Rocky Linux 8/AlmaLinux 8/CentOS 8:

1. **Install PostgreSQL repository:**
   ```bash
   sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
   ```

2. **Disable built-in PostgreSQL module:**
   ```bash
   sudo dnf -qy module disable postgresql
   ```

3. **Install PostgreSQL 18:**
   ```bash
   sudo dnf install -y postgresql18-server postgresql18
   ```

4. **Initialize database:**
   ```bash
   sudo /usr/pgsql-18/bin/postgresql-18-setup initdb
   ```

5. **Start and enable service:**
   ```bash
   sudo systemctl start postgresql-18
   sudo systemctl enable postgresql-18
   ```

### For Fedora:

**Note:** Fedora typically includes recent PostgreSQL versions. Check available versions first:

```bash
dnf search postgresql18
```

**If PostgreSQL 18 is available in default repos:**
1. **Install PostgreSQL 18:**
   ```bash
   sudo dnf install postgresql18-server postgresql18 postgresql18-contrib
   ```

2. **Initialize database:**
   ```bash
   sudo postgresql-setup --initdb
   ```

3. **Start and enable service:**
   ```bash
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

**If PostgreSQL 18 is not available, use PGDG repository:**
1. **Install PostgreSQL repository:**
   ```bash
   sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/F-$(rpm -E %{fedora})-x86_64/pgdg-fedora-repo-latest.noarch.rpm
   ```

2. **Install PostgreSQL 18:**
   ```bash
   sudo dnf install -y postgresql18-server postgresql18 postgresql18-contrib
   ```

3. **Initialize database:**
   ```bash
   sudo /usr/pgsql-18/bin/postgresql-18-setup initdb
   ```

4. **Start and enable service:**
   ```bash
   sudo systemctl start postgresql-18
   sudo systemctl enable postgresql-18
   ```

## Arch Linux

Arch Linux typically includes the latest PostgreSQL version in its repositories.

1. **Install PostgreSQL:**
   ```bash
   sudo pacman -S postgresql
   ```

2. **Initialize database:**
   ```bash
   sudo -u postgres initdb -D /var/lib/postgres/data
   ```

3. **Start and enable service:**
   ```bash
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

4. **Check installed version:**
   ```bash
   sudo -u postgres psql -c "SELECT version();"
   ```

## Initial Configuration

### 1. Switch to PostgreSQL user and create database user:
```bash
sudo -i -u postgres
createuser --interactive
```

### 2. Create a database:
```bash
createdb mydatabase
```

### 3. Access PostgreSQL prompt:
```bash
psql
```

### 4. Set password for postgres user:
```sql
\password postgres
```

### 5. Exit PostgreSQL prompt:
```sql
\q
```

## Configure PostgreSQL for Remote Connections (Optional)

1. **Edit postgresql.conf (adjust version number as needed):**
   ```bash
   # For PostgreSQL 18:
   sudo nano /etc/postgresql/18/main/postgresql.conf
   ```

   Find and uncomment:
   ```
   listen_addresses = '*'
   ```

2. **Edit pg_hba.conf (adjust version number as needed):**
   ```bash
   # For PostgreSQL 18:
   sudo nano /etc/postgresql/18/main/pg_hba.conf
   ```

   Add line for remote connections:
   ```
   host    all             all             0.0.0.0/0               md5
   ```

3. **Restart PostgreSQL:**
   ```bash
   sudo systemctl restart postgresql
   ```

## Verify Installation

1. **Check PostgreSQL version:**
   ```bash
   psql --version
   ```

2. **Check service status:**
   ```bash
   sudo systemctl status postgresql
   ```

3. **Connect to PostgreSQL:**
   ```bash
   sudo -u postgres psql
   ```

## Finding PostgreSQL Installation and PG_CONFIG

### Locate PostgreSQL Installation

1. **Find PostgreSQL binary location:**
   ```bash
   which psql
   which postgres
   ```

2. **Find all PostgreSQL executables:**
   ```bash
   find /usr -name "psql" 2>/dev/null
   find /usr -name "postgres" 2>/dev/null
   ```

3. **Check installed PostgreSQL packages:**
   ```bash
   # Ubuntu/Debian
   dpkg -l | grep postgresql

   # CentOS/RHEL/Fedora
   rpm -qa | grep postgresql

   # Arch Linux
   pacman -Q | grep postgresql
   ```

### Find PG_CONFIG

PG_CONFIG is a utility that provides configuration information about the installed PostgreSQL.

1. **Locate pg_config:**
   ```bash
   which pg_config
   ```

2. **If pg_config is not found, search for it:**
   ```bash
   find /usr -name "pg_config" 2>/dev/null
   ```

3. **Install development packages if pg_config is missing:**
   ```bash
   # Ubuntu/Debian (PostgreSQL 18)
   sudo apt install postgresql-server-dev-18

   # CentOS/RHEL (PostgreSQL 18)
   sudo yum install postgresql18-devel

   # Fedora (PostgreSQL 18)
   sudo dnf install postgresql18-devel

   # Arch Linux
   # pg_config is included in the main postgresql package
   ```

4. **Get PostgreSQL configuration information:**
   ```bash
   pg_config --version          # PostgreSQL version
   pg_config --bindir           # Binary directory
   pg_config --libdir           # Library directory
   pg_config --includedir       # Include directory
   pg_config --pkglibdir        # Package library directory
   pg_config --configure        # Configuration options
   pg_config --cc               # C compiler used
   pg_config --cflags           # C compiler flags
   ```

### Common Installation Paths by Distribution

#### Ubuntu/Debian (PostgreSQL 18):
- **Binaries:** `/usr/lib/postgresql/18/bin/` (psql, postgres, pg_dump, etc.)
- **Configuration:** `/etc/postgresql/18/main/`
- **Data directory:** `/var/lib/postgresql/18/main/`
- **Log files:** `/var/log/postgresql/`
- **pg_config:** `/usr/lib/postgresql/18/bin/pg_config`

#### CentOS/RHEL (PostgreSQL 18):
- **Binaries:** `/usr/pgsql-18/bin/`
- **Configuration:** `/var/lib/pgsql/18/data/`
- **Data directory:** `/var/lib/pgsql/18/data/`
- **Log files:** `/var/lib/pgsql/18/data/log/`
- **pg_config:** `/usr/pgsql-18/bin/pg_config`

#### Fedora:
- **Binaries:** `/usr/bin/` or `/usr/pgsql-18/bin/`
- **Configuration:** `/var/lib/pgsql/data/`
- **Data directory:** `/var/lib/pgsql/data/`
- **Log files:** `/var/lib/pgsql/data/log/`
- **pg_config:** `/usr/bin/pg_config` or `/usr/pgsql-18/bin/pg_config`

#### Arch Linux:
- **Binaries:** `/usr/bin/`
- **Configuration:** `/var/lib/postgres/data/`
- **Data directory:** `/var/lib/postgres/data/`
- **Log files:** `/var/lib/postgres/data/log/`
- **pg_config:** `/usr/bin/pg_config`

### Using PostgreSQL with Development Tools (testgres)

For development tools like testgres, you need to specify the correct binary directory.

```python
# Example for testgres (CORRECT METHOD)
from testgres import get_new_node, DumpFormat

# Method 1: Let testgres find PostgreSQL automatically (recommended)
node = get_new_node()

# Method 2: Specify binary directory explicitly
# Ubuntu/Debian with PostgreSQL 18:
node = get_new_node(bin_dir='/usr/lib/postgresql/18/bin')

# CentOS/RHEL with PostgreSQL 18:
node = get_new_node(bin_dir='/usr/pgsql-18/bin')

# Method 3: Set PATH environment variable
import os
os.environ['PATH'] = '/usr/lib/postgresql/18/bin:' + os.environ['PATH']
node = get_new_node()
```

#### Common testgres Setup Example:
```python
import os
from testgres import get_new_node, DumpFormat

# Create and configure PostgreSQL test instance
node = get_new_node()
node.init()  # Initialize database

# Configure socket directory to avoid permission issues
node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')

node.start()  # Start PostgreSQL server

# Create test database
node.psql('postgres', 'CREATE DATABASE test_db;')

# Use the database
node.psql('test_db', 'CREATE TABLE users (id SERIAL, name TEXT);')

# Create backup
backup_file = 'backup.sql'
node.dump(backup_file, dbname='test_db', format=DumpFormat.Plain)

# Cleanup
node.stop()
```

## Useful Commands

- **Start PostgreSQL:** `sudo systemctl start postgresql`
- **Stop PostgreSQL:** `sudo systemctl stop postgresql`
- **Restart PostgreSQL:** `sudo systemctl restart postgresql`
- **Check logs:** `sudo journalctl -u postgresql`

## Troubleshooting

### Common Issues:

1. **Service won't start:**
   - Check logs: `sudo journalctl -u postgresql`
   - Verify data directory permissions
   - Ensure database is properly initialized

2. **Connection refused:**
   - Check if service is running: `sudo systemctl status postgresql`
   - Verify pg_hba.conf configuration
   - Check firewall settings

3. **Permission denied:**
   - Ensure you're using the correct user (postgres)
   - Check file permissions on data directory

## Uninstallation

### Ubuntu/Debian:
```bash
sudo apt remove --purge postgresql postgresql-*
sudo rm -rf /var/lib/postgresql/
```

### CentOS/RHEL:
```bash
sudo yum remove postgresql*
sudo rm -rf /var/lib/pgsql/
```

### Arch Linux:
```bash
sudo pacman -R postgresql
sudo rm -rf /var/lib/postgres/
```