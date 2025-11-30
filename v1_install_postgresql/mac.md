# PostgreSQL Installation Guide for macOS

This guide covers PostgreSQL installation on macOS using different methods.

## Method 1: Using Homebrew (Recommended)

Homebrew is the most popular package manager for macOS and provides the easiest installation method.

### Install Homebrew (if not already installed)

1. **Open Terminal** (Applications → Utilities → Terminal)

2. **Install Homebrew:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Follow the on-screen instructions** to add Homebrew to your PATH

### Install PostgreSQL

1. **Update Homebrew:**
   ```bash
   brew update
   ```

2. **Install PostgreSQL:**
   ```bash
   brew install postgresql@15
   ```

3. **Start PostgreSQL service:**
   ```bash
   brew services start postgresql@15
   ```

4. **Add PostgreSQL to PATH** (add to your shell profile):
   ```bash
   echo 'export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

   For Intel Macs, use:
   ```bash
   echo 'export PATH="/usr/local/opt/postgresql@15/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

## Method 2: Using MacPorts

1. **Install MacPorts** from https://www.macports.org/install.php

2. **Update MacPorts:**
   ```bash
   sudo port selfupdate
   ```

3. **Install PostgreSQL:**
   ```bash
   sudo port install postgresql15-server
   ```

4. **Initialize database:**
   ```bash
   sudo -u postgres /opt/local/lib/postgresql15/bin/initdb -D /opt/local/var/db/postgresql15/defaultdb
   ```

5. **Load and start the service:**
   ```bash
   sudo port load postgresql15-server
   ```

## Method 3: Using the Official Installer

### Download and Install

1. **Visit PostgreSQL website:**
   - Go to https://www.postgresql.org/download/macosx/
   - Click "Download the installer"

2. **Download the installer:**
   - Choose the latest stable version for macOS
   - Download the .dmg file

3. **Install PostgreSQL:**
   - Open the downloaded .dmg file
   - Run the installer package
   - Follow the installation wizard:
     - Accept license agreement
     - Choose installation directory (default: `/Library/PostgreSQL/15`)
     - Select components (Server, pgAdmin 4, Stack Builder, Command Line Tools)
     - Choose data directory (default: `/Library/PostgreSQL/15/data`)
     - Set superuser password
     - Set port (default: 5432)
     - Set locale
   - Complete the installation

## Method 4: Using Postgres.app

Postgres.app provides a simple, native macOS app for PostgreSQL.

1. **Download Postgres.app:**
   - Visit https://postgresapp.com/
   - Download the latest version

2. **Install:**
   - Move Postgres.app to Applications folder
   - Double-click to launch

3. **Configure PATH:**
   ```bash
   echo 'export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. **Initialize:**
   - Click "Initialize" to create a new server
   - The app will create a database with your username

## Post-Installation Configuration

### 1. Verify Installation

```bash
# Check PostgreSQL version
psql --version

# Check if service is running (Homebrew)
brew services list | grep postgresql

# Check if service is running (system service)
ps aux | grep postgres
```

### 2. Initial Database Setup

#### Using Homebrew installation:

1. **Create initial database:**
   ```bash
   createdb $(whoami)
   ```

2. **Connect to PostgreSQL:**
   ```bash
   psql
   ```

#### Using official installer:

1. **Connect as postgres user:**
   ```bash
   sudo -u postgres psql
   ```

2. **Set password for postgres user:**
   ```sql
   \password postgres
   ```

### 3. Create a New Database and User

```sql
-- Create a new database
CREATE DATABASE mydatabase;

-- Create a new user
CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;

-- Exit
\q
```

## Finding PostgreSQL Installation and PG_CONFIG

### Locate PostgreSQL Installation

1. **Find PostgreSQL using which command:**
   ```bash
   which psql
   which postgres
   which pg_config
   ```

2. **Find PostgreSQL using find command:**
   ```bash
   # Search in common directories
   find /usr/local /opt /Applications -name "psql" 2>/dev/null
   find /usr/local /opt /Applications -name "postgres" 2>/dev/null
   ```

3. **Check Homebrew installation:**
   ```bash
   # List Homebrew PostgreSQL installations
   brew list | grep postgresql
   brew --prefix postgresql@15

   # Get info about PostgreSQL installation
   brew info postgresql@15
   ```

4. **Check official installer locations:**
   ```bash
   # Check if PostgreSQL is installed via official installer
   ls -la /Library/PostgreSQL/
   ls -la /Applications/Postgres.app/
   ```

### Find PG_CONFIG

PG_CONFIG is a utility that provides configuration information about the installed PostgreSQL.

1. **Locate pg_config:**
   ```bash
   which pg_config
   ```

2. **If pg_config is not in PATH, search for it:**
   ```bash
   # Search for pg_config
   find /usr/local /opt /Library /Applications -name "pg_config" 2>/dev/null
   ```

3. **Get PostgreSQL configuration information:**
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

### Common Installation Paths by Method

#### Homebrew (Apple Silicon):
- **Binaries:** `/opt/homebrew/bin/`
- **Configuration:** `/opt/homebrew/var/postgres/`
- **Data directory:** `/opt/homebrew/var/postgres/`
- **Log files:** `/opt/homebrew/var/log/postgresql@15.log`
- **pg_config:** `/opt/homebrew/bin/pg_config`

#### Homebrew (Intel Mac):
- **Binaries:** `/usr/local/bin/`
- **Configuration:** `/usr/local/var/postgres/`
- **Data directory:** `/usr/local/var/postgres/`
- **Log files:** `/usr/local/var/log/postgresql@15.log`
- **pg_config:** `/usr/local/bin/pg_config`

#### Official Installer:
- **Binaries:** `/Library/PostgreSQL/15/bin/`
- **Configuration:** `/Library/PostgreSQL/15/data/`
- **Data directory:** `/Library/PostgreSQL/15/data/`
- **Log files:** `/Library/PostgreSQL/15/data/log/`
- **pg_config:** `/Library/PostgreSQL/15/bin/pg_config`

#### Postgres.app:
- **Binaries:** `/Applications/Postgres.app/Contents/Versions/latest/bin/`
- **Configuration:** `~/Library/Application Support/Postgres/var-15/`
- **Data directory:** `~/Library/Application Support/Postgres/var-15/`
- **pg_config:** `/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config`

#### MacPorts:
- **Binaries:** `/opt/local/lib/postgresql15/bin/`
- **Configuration:** `/opt/local/var/db/postgresql15/defaultdb/`
- **Data directory:** `/opt/local/var/db/postgresql15/defaultdb/`
- **pg_config:** `/opt/local/lib/postgresql15/bin/pg_config`

### Using pg_config for Development

For development tools like testgres, you may need to specify the pg_config path:

```python
# Example for testgres
import testgres

# Homebrew installation (Apple Silicon)
node = testgres.get_new_node(bin_dir='/opt/homebrew/bin/pg_config')

# Homebrew installation (Intel Mac)
node = testgres.get_new_node(bin_dir='/usr/local/bin/pg_config')

# Official installer
node = testgres.get_new_node(bin_dir='/Library/PostgreSQL/15/bin/pg_config')

# Postgres.app
node = testgres.get_new_node(bin_dir='/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config')

# MacPorts
node = testgres.get_new_node(bin_dir='/opt/local/lib/postgresql15/bin/pg_config')

# Or let testgres find it automatically if it's in PATH
node = testgres.get_new_node()
```

### Adding PostgreSQL to PATH

If you want to use PostgreSQL commands from any location:

1. **For Homebrew installation, add to shell profile:**
   ```bash
   # For Apple Silicon Macs (add to ~/.zshrc or ~/.bash_profile)
   echo 'export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"' >> ~/.zshrc

   # For Intel Macs
   echo 'export PATH="/usr/local/opt/postgresql@15/bin:$PATH"' >> ~/.zshrc

   # Reload your shell configuration
   source ~/.zshrc
   ```

2. **For official installer:**
   ```bash
   echo 'export PATH="/Library/PostgreSQL/15/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **For Postgres.app:**
   ```bash
   echo 'export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. **Verify PATH addition:**
   ```bash
   # Open a new terminal or run source command
   psql --version
   pg_config --version
   ```

## Managing PostgreSQL Service

### Using Homebrew:

```bash
# Start service
brew services start postgresql@15

# Stop service
brew services stop postgresql@15

# Restart service
brew services restart postgresql@15

# Check service status
brew services list | grep postgresql
```

### Using launchctl (for official installer):

```bash
# Start service
sudo launchctl load /Library/LaunchDaemons/com.edb.launchd.postgresql-15.plist

# Stop service
sudo launchctl unload /Library/LaunchDaemons/com.edb.launchd.postgresql-15.plist
```

### Manual start/stop:

```bash
# Start PostgreSQL manually (Homebrew)
pg_ctl -D /opt/homebrew/var/postgres start

# Stop PostgreSQL manually (Homebrew)
pg_ctl -D /opt/homebrew/var/postgres stop

# For Intel Macs, use: /usr/local/var/postgres
```

## Configuration Files

### Homebrew installation locations:
- **Configuration:** `/opt/homebrew/var/postgres/postgresql.conf`
- **Authentication:** `/opt/homebrew/var/postgres/pg_hba.conf`
- **Data directory:** `/opt/homebrew/var/postgres/`

### Official installer locations:
- **Configuration:** `/Library/PostgreSQL/15/data/postgresql.conf`
- **Authentication:** `/Library/PostgreSQL/15/data/pg_hba.conf`
- **Data directory:** `/Library/PostgreSQL/15/data/`

## Configure for Remote Connections (Optional)

1. **Edit postgresql.conf:**
   ```bash
   # For Homebrew
   nano /opt/homebrew/var/postgres/postgresql.conf

   # For official installer
   sudo nano /Library/PostgreSQL/15/data/postgresql.conf
   ```

   Find and uncomment:
   ```
   listen_addresses = '*'
   ```

2. **Edit pg_hba.conf:**
   ```bash
   # For Homebrew
   nano /opt/homebrew/var/postgres/pg_hba.conf

   # For official installer
   sudo nano /Library/PostgreSQL/15/data/pg_hba.conf
   ```

   Add line for remote connections:
   ```
   host    all             all             0.0.0.0/0               md5
   ```

3. **Restart PostgreSQL:**
   ```bash
   brew services restart postgresql@15
   ```

## GUI Management Tools

### pgAdmin 4
- **Install via Homebrew:**
  ```bash
  brew install --cask pgadmin4
  ```
- **Or download from:** https://www.pgadmin.org/download/pgadmin-4-macos/

### Other GUI Tools
- **TablePlus:** Available on Mac App Store
- **Postico:** Native macOS PostgreSQL client
- **DBeaver:** Free universal database tool

## Useful Commands

### Database Operations:
```bash
# Create database
createdb mydatabase

# Drop database
dropdb mydatabase

# Backup database
pg_dump mydatabase > backup.sql

# Restore database
psql mydatabase < backup.sql

# Connect to specific database
psql -d mydatabase

# Connect with specific user
psql -U myuser -d mydatabase
```

### User Management:
```sql
-- List all users
\du

-- Create user with specific privileges
CREATE USER newuser WITH PASSWORD 'password' CREATEDB;

-- Drop user
DROP USER username;

-- Change user password
ALTER USER username WITH PASSWORD 'newpassword';
```

## Environment Variables

Add these to your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
# PostgreSQL environment variables
export PGDATA="/opt/homebrew/var/postgres"  # For Apple Silicon
# export PGDATA="/usr/local/var/postgres"   # For Intel Macs
export PGUSER="postgres"
export PGDATABASE="postgres"
```

## Troubleshooting

### Common Issues:

1. **PostgreSQL won't start:**
   ```bash
   # Check logs
   tail -f /opt/homebrew/var/log/postgresql@15.log

   # Remove postmaster.pid if it exists
   rm /opt/homebrew/var/postgres/postmaster.pid
   ```

2. **Permission denied:**
   ```bash
   # Fix permissions on data directory
   sudo chown -R $(whoami) /opt/homebrew/var/postgres
   ```

3. **Port already in use:**
   ```bash
   # Check what's using port 5432
   lsof -i :5432

   # Kill the process if needed
   sudo kill -9 <PID>
   ```

4. **Connection refused:**
   - Ensure PostgreSQL service is running
   - Check pg_hba.conf for authentication settings
   - Verify port configuration

5. **Database does not exist:**
   ```bash
   # Create database with your username
   createdb $(whoami)
   ```

### Log Files:
- **Homebrew:** `/opt/homebrew/var/log/postgresql@15.log`
- **Official installer:** `/Library/PostgreSQL/15/data/log/`

## Performance Optimization

1. **Edit postgresql.conf:**
   ```bash
   nano /opt/homebrew/var/postgres/postgresql.conf
   ```

2. **Key settings to adjust:**
   ```
   shared_buffers = 256MB          # 25% of RAM
   effective_cache_size = 1GB      # 75% of RAM
   work_mem = 4MB                  # Per query operation
   maintenance_work_mem = 64MB     # For maintenance operations
   ```

3. **Restart PostgreSQL after changes:**
   ```bash
   brew services restart postgresql@15
   ```

## Uninstallation

### Homebrew installation:
```bash
# Stop service
brew services stop postgresql@15

# Remove PostgreSQL
brew uninstall postgresql@15

# Remove data directory (optional)
rm -rf /opt/homebrew/var/postgres
```

### Official installer:
```bash
# Stop service
sudo launchctl unload /Library/LaunchDaemons/com.edb.launchd.postgresql-15.plist

# Remove application
sudo rm -rf /Library/PostgreSQL

# Remove service file
sudo rm /Library/LaunchDaemons/com.edb.launchd.postgresql-15.plist
```

### Postgres.app:
1. Quit Postgres.app
2. Move Postgres.app to Trash
3. Remove data directory: `~/Library/Application Support/Postgres/`

## Backup and Maintenance

### Automated backups:
```bash
# Create backup script
cat > backup_postgres.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/postgres_backups"
mkdir -p $BACKUP_DIR
pg_dumpall > "$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"
EOF

chmod +x backup_postgres.sh
```

### Schedule with cron:
```bash
# Edit crontab
crontab -e

# Add line for daily backup at 2 AM
0 2 * * * /path/to/backup_postgres.sh
```

### Regular maintenance:
```sql
-- Analyze database statistics
ANALYZE;

-- Vacuum database
VACUUM;

-- Reindex database
REINDEX DATABASE mydatabase;
```

## Security Best Practices

1. **Change default passwords**
2. **Use strong authentication methods**
3. **Limit network access**
4. **Regular security updates**
5. **Monitor logs for suspicious activity**
6. **Use SSL connections for remote access**

## Additional Resources

- **Official Documentation:** https://www.postgresql.org/docs/
- **Homebrew PostgreSQL:** https://formulae.brew.sh/formula/postgresql
- **macOS PostgreSQL Wiki:** https://wiki.postgresql.org/wiki/Homebrew