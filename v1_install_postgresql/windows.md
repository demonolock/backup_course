# PostgreSQL Installation Guide for Windows

This guide covers PostgreSQL installation on Windows using different methods.

## Method 1: Using the Official Installer (Recommended)

### Download PostgreSQL

1. **Visit the official PostgreSQL website:**
   - Go to https://www.postgresql.org/download/windows/
   - Click "Download the installer"

2. **Download the installer:**
   - Choose the latest stable version (e.g., PostgreSQL 15.x)
   - Select your Windows architecture (x86-64 for 64-bit systems)
   - Download the installer file (postgresql-15.x-x-windows-x64.exe)

### Installation Steps

1. **Run the installer:**
   - Right-click the downloaded file and select "Run as administrator"
   - Click "Yes" when prompted by User Account Control

2. **Installation wizard:**
   - **Welcome screen:** Click "Next"
   - **Installation Directory:** Keep default (`C:\Program Files\PostgreSQL\15`) or choose custom path
   - **Select Components:**
     - PostgreSQL Server (required)
     - pgAdmin 4 (recommended - GUI management tool)
     - Stack Builder (optional - additional tools)
     - Command Line Tools (recommended)
   - Click "Next"

3. **Data Directory:**
   - Keep default (`C:\Program Files\PostgreSQL\15\data`) or choose custom path
   - Click "Next"

4. **Password:**
   - Set a strong password for the postgres superuser
   - **Remember this password** - you'll need it to connect to PostgreSQL
   - Click "Next"

5. **Port:**
   - Keep default port 5432 (recommended)
   - Click "Next"

6. **Advanced Options:**
   - Keep default locale or select your preferred locale
   - Click "Next"

7. **Pre Installation Summary:**
   - Review your settings
   - Click "Next" to begin installation

8. **Installation:**
   - Wait for the installation to complete (may take several minutes)
   - Click "Next" when finished

9. **Completing the Setup:**
   - Uncheck "Launch Stack Builder" unless you need additional components
   - Click "Finish"

## Method 2: Using Package Managers

### Using Chocolatey

1. **Install Chocolatey** (if not already installed):
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **Install PostgreSQL:**
   ```powershell
   choco install postgresql
   ```

### Using Scoop

1. **Install Scoop** (if not already installed):
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   irm get.scoop.sh | iex
   ```

2. **Install PostgreSQL:**
   ```powershell
   scoop install postgresql
   ```

## Method 3: Using Windows Subsystem for Linux (WSL)

If you have WSL installed, you can follow the Linux installation guide within your WSL environment.

## Post-Installation Configuration

### 1. Verify Installation

1. **Open Command Prompt or PowerShell as Administrator**

2. **Check PostgreSQL version:**
   ```cmd
   psql --version
   ```

3. **Check if service is running:**
   ```cmd
   sc query postgresql-x64-15
   ```

### 2. Connect to PostgreSQL

1. **Using Command Line:**
   ```cmd
   psql -U postgres -h localhost
   ```
   - Enter the password you set during installation

2. **Using pgAdmin 4:**
   - Start Menu → PostgreSQL 15 → pgAdmin 4
   - Create a new server connection with:
     - Host: localhost
     - Port: 5432
     - Username: postgres
     - Password: (the password you set)

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

1. **Default installation paths:**
   - **Official installer:** `C:\Program Files\PostgreSQL\15\`
   - **Chocolatey:** `C:\ProgramData\chocolatey\lib\postgresql\tools\postgresql\pgsql\`
   - **Scoop:** `C:\Users\[username]\scoop\apps\postgresql\[version]\pgsql\`

2. **Find PostgreSQL using Command Prompt:**
   ```cmd
   # Find psql.exe location
   where psql

   # Find postgres.exe location
   where postgres

   # Search for PostgreSQL installation
   dir "C:\Program Files" | findstr PostgreSQL
   dir "C:\Program Files (x86)" | findstr PostgreSQL
   ```

3. **Find PostgreSQL using PowerShell:**
   ```powershell
   # Find PostgreSQL executables
   Get-Command psql
   Get-Command postgres

   # Search for installation directories
   Get-ChildItem "C:\Program Files" | Where-Object {$_.Name -like "*PostgreSQL*"}
   Get-ChildItem "C:\Program Files (x86)" | Where-Object {$_.Name -like "*PostgreSQL*"}
   ```

4. **Check Windows Registry:**
   ```cmd
   reg query "HKEY_LOCAL_MACHINE\SOFTWARE\PostgreSQL" /s
   ```

### Find PG_CONFIG

PG_CONFIG is a utility that provides configuration information about the installed PostgreSQL.

1. **Locate pg_config.exe:**
   ```cmd
   where pg_config
   ```

2. **If not in PATH, check common locations:**
   ```cmd
   # Official installer
   "C:\Program Files\PostgreSQL\15\bin\pg_config.exe" --version

   # Check if file exists
   dir "C:\Program Files\PostgreSQL\15\bin\pg_config.exe"
   ```

3. **Get PostgreSQL configuration information:**
   ```cmd
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

#### Official Installer:
- **Binaries:** `C:\Program Files\PostgreSQL\15\bin\`
- **Configuration:** `C:\Program Files\PostgreSQL\15\data\`
- **Data directory:** `C:\Program Files\PostgreSQL\15\data\`
- **Log files:** `C:\Program Files\PostgreSQL\15\data\log\`
- **pg_config:** `C:\Program Files\PostgreSQL\15\bin\pg_config.exe`

#### Chocolatey:
- **Binaries:** `C:\ProgramData\chocolatey\lib\postgresql\tools\postgresql\pgsql\bin\`
- **Configuration:** `C:\ProgramData\chocolatey\lib\postgresql\tools\postgresql\pgsql\data\`
- **pg_config:** `C:\ProgramData\chocolatey\lib\postgresql\tools\postgresql\pgsql\bin\pg_config.exe`

#### Scoop:
- **Binaries:** `C:\Users\[username]\scoop\apps\postgresql\[version]\pgsql\bin\`
- **Configuration:** `C:\Users\[username]\scoop\apps\postgresql\[version]\pgsql\data\`
- **pg_config:** `C:\Users\[username]\scoop\apps\postgresql\[version]\pgsql\bin\pg_config.exe`

### Using pg_config for Development

For development tools like testgres, you may need to specify the pg_config path:

```python
# Example for testgres
import testgres

# Specify pg_config path on Windows
node = testgres.get_new_node(bin_dir='C:/Program Files/PostgreSQL/15/bin/pg_config.exe')

# Or use forward slashes for cross-platform compatibility
node = testgres.get_new_node(bin_dir='C:\\Program Files\\PostgreSQL\\15\\bin\\pg_config.exe')

# Or let testgres find it automatically if it's in PATH
node = testgres.get_new_node()
```

### Adding PostgreSQL to System PATH

If you want to use PostgreSQL commands from any location:

1. **Open Environment Variables:**
   - Right-click "This PC" → Properties → Advanced system settings
   - Click "Environment Variables"

2. **Edit PATH variable:**
   - Under "System variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\Program Files\PostgreSQL\15\bin`
   - Click "OK" to save

3. **Verify PATH addition:**
   ```cmd
   # Open a new Command Prompt
   psql --version
   pg_config --version
   ```

## Environment Variables (Optional)

Add PostgreSQL to your system PATH:

1. **Open System Properties:**
   - Right-click "This PC" → Properties → Advanced system settings
   - Click "Environment Variables"

2. **Edit PATH:**
   - Under "System variables", find and select "Path"
   - Click "Edit" → "New"
   - Add: `C:\Program Files\PostgreSQL\15\bin`
   - Click "OK" to save

3. **Restart Command Prompt** to use the new PATH

## Windows Service Management

### Using Services GUI:
1. Press `Win + R`, type `services.msc`, press Enter
2. Find "postgresql-x64-15" service
3. Right-click to Start/Stop/Restart

### Using Command Line:
```cmd
# Start service
net start postgresql-x64-15

# Stop service
net stop postgresql-x64-15

# Restart service
net stop postgresql-x64-15 && net start postgresql-x64-15
```

### Using PowerShell:
```powershell
# Start service
Start-Service -Name postgresql-x64-15

# Stop service
Stop-Service -Name postgresql-x64-15

# Restart service
Restart-Service -Name postgresql-x64-15

# Check status
Get-Service -Name postgresql-x64-15
```

## Configure for Remote Connections (Optional)

1. **Edit postgresql.conf:**
   - Navigate to: `C:\Program Files\PostgreSQL\15\data\`
   - Open `postgresql.conf` in a text editor (as Administrator)
   - Find and uncomment:
     ```
     listen_addresses = '*'
     ```

2. **Edit pg_hba.conf:**
   - In the same directory, open `pg_hba.conf`
   - Add line for remote connections:
     ```
     host    all             all             0.0.0.0/0               md5
     ```

3. **Restart PostgreSQL service:**
   ```cmd
   net stop postgresql-x64-15
   net start postgresql-x64-15
   ```

4. **Configure Windows Firewall:**
   ```cmd
   netsh advfirewall firewall add rule name="PostgreSQL" dir=in action=allow protocol=TCP localport=5432
   ```

## Useful Tools and Extensions

### pgAdmin 4
- **Location:** Start Menu → PostgreSQL 15 → pgAdmin 4
- **Web interface:** Usually opens at http://localhost:63124/browser/

### Command Line Tools
- **psql:** Interactive PostgreSQL terminal
- **pg_dump:** Backup databases
- **pg_restore:** Restore databases
- **createdb:** Create databases from command line

## Troubleshooting

### Common Issues:

1. **Installation fails:**
   - Run installer as Administrator
   - Disable antivirus temporarily
   - Check Windows version compatibility

2. **Service won't start:**
   - Check Windows Event Logs
   - Verify data directory permissions
   - Ensure port 5432 isn't in use

3. **Connection refused:**
   - Verify service is running
   - Check firewall settings
   - Verify pg_hba.conf configuration

4. **Password authentication failed:**
   - Ensure you're using the correct password
   - Check pg_hba.conf authentication method

5. **Port already in use:**
   ```cmd
   netstat -an | findstr :5432
   ```

### Log Files Location:
- **Installation logs:** `%TEMP%\install-postgresql.log`
- **Server logs:** `C:\Program Files\PostgreSQL\15\data\log\`

## Uninstallation

### Method 1: Using Control Panel
1. Control Panel → Programs and Features
2. Find "PostgreSQL 15"
3. Click "Uninstall"

### Method 2: Using Installer
1. Run the original installer
2. Select "Uninstall PostgreSQL"

### Method 3: Manual Cleanup (if needed)
1. **Remove service:**
   ```cmd
   sc delete postgresql-x64-15
   ```

2. **Remove directories:**
   - `C:\Program Files\PostgreSQL\`
   - `%APPDATA%\postgresql\`

3. **Remove registry entries:**
   - `HKEY_LOCAL_MACHINE\SOFTWARE\PostgreSQL`

## Performance Tips

1. **Adjust shared_buffers** in postgresql.conf (typically 25% of RAM)
2. **Set effective_cache_size** (typically 75% of RAM)
3. **Configure work_mem** appropriately for your workload
4. **Enable logging** for monitoring performance

## Backup and Maintenance

### Create a backup:
```cmd
pg_dump -U postgres -h localhost mydatabase > backup.sql
```

### Restore from backup:
```cmd
psql -U postgres -h localhost mydatabase < backup.sql
```

### Regular maintenance:
```sql
VACUUM ANALYZE;
REINDEX DATABASE mydatabase;
```