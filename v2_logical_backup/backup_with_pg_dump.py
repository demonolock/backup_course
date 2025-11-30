import os

from testgres import get_new_node, DumpFormat

node = get_new_node()
node.init()  # initdb -D <data_directory>
# In case of permission error use this command
node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')
node.start()  # pg_ctl start -D <data_directory>

# > psql -h localhost -p <port> -d postgres -c "create database backup;"
node.psql('postgres', 'create database backup;')

create_tables_sql = """
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,    name TEXT UNIQUE NOT NULL);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,    customer_id INT NOT NULL REFERENCES customers(id),    order_date DATE NOT NULL);

INSERT INTO customers (name) VALUES ('Alice'), ('Bob');
INSERT INTO orders (customer_id, order_date) VALUES (1, '2025-11-01'), (2, '2025-11-02');
"""

# > psql -h localhost -p <port> -d backup -c "<SQL_commands>"
node.psql('backup', create_tables_sql)

# > psql -h localhost -p <port> -d backup -c "Select * from customers"
node.psql('backup', 'Select * from customers')
# > psql -h localhost -p <port> -d backup -c "Select * from orders"
node.psql('backup', 'Select * from orders')

# Dump the database
# > pg_dump -h localhost -p <port> -d my_db -f dump_output/my_db_dump.sql --format=plain
backup_file = os.path.join(os.path.curdir, 'dump_output/my_db_dump.sql')
node.dump(backup_file, dbname='backup', format=DumpFormat.Plain)
