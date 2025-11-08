import os

from testgres import get_new_node, DumpFormat

node = get_new_node()
node.init()
# In case of permission error use this command
# node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')
node.start()

node.psql('postgres', 'create database backup;')

create_tables_sql = """  
CREATE TABLE customers (  
    id SERIAL PRIMARY KEY,    name TEXT UNIQUE NOT NULL);  

CREATE TABLE orders (  
    id SERIAL PRIMARY KEY,    customer_id INT NOT NULL REFERENCES customers(id),    order_date DATE NOT NULL);  

INSERT INTO customers (name) VALUES ('Alice'), ('Bob');  
INSERT INTO orders (customer_id, order_date) VALUES (1, '2025-11-01'), (2, '2025-11-02');  
"""

node.psql('backup', create_tables_sql)

node.psql('backup', 'Select * from customers')
node.psql('backup', 'Select * from orders')

# Dump the database
backup_file = os.path.join(os.path.curdir, 'dump_output/my_db_dump.sql')
node.dump(backup_file, dbname='my_db', format=DumpFormat.Plain)
