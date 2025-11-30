import os

from testgres import get_new_node


node = get_new_node()
# > initdb -D <data_directory>
node.init()
# In case of permission error use this command
node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')
# > pg_ctl start -D <data_directory>
node.start()

# > psql -h localhost -p <port> -d postgres -c "create database restored_backup;"
node.psql('postgres', 'create database restored_backup;')

# Path to dump file
dump_file = os.path.join('..', 'v2_logical_backup', 'dump_output', 'my_db_dump.sql')

# Restore database from dump
# > psql -h localhost -p <port> -d restored_backup -f ../v2_logical_backup/dump_output/my_db_dump.sql
node.restore(dump_file, dbname='restored_backup')

# Verify that data was restored correctly
def print_table_data(table_name, result):
    """Pretty print table data from psql result"""
    print(f"\n{table_name} table:")
    print("-" * 30)
    if result[1]:  # if stdout is not empty
        data = result[1].decode('utf-8').strip()
        print(data)
    else:
        print("No data found")

# > psql -h localhost -p <port> -d restored_backup -c "SELECT * FROM customers;"
customers_result = node.psql('restored_backup', 'SELECT * FROM customers;')
print_table_data("Customers", customers_result)

# > psql -h localhost -p <port> -d restored_backup -c "SELECT * FROM orders;"
orders_result = node.psql('restored_backup', 'SELECT * FROM orders;')
print_table_data("Orders", orders_result)
