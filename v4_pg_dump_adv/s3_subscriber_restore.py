import os
import subprocess
import time
from testgres import get_new_node, DumpFormat

# =============================================================================
# STEP 1. Create publisher node
# =============================================================================
publisher_node = get_new_node()
publisher_node.init()  # initdb -D <data_directory>

# Configure for logical replication
publisher_node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')
publisher_node.append_conf('postgresql.conf', 'wal_level = logical')
publisher_node.start() # pg_ctl start -D <data_directory>

publisher_node.psql('postgres', 'CREATE DATABASE sales;')

prepare_data_sql = """
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    category_id INT,
    last_updated TIMESTAMP DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE sales_transactions (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    customer_email TEXT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    sale_date TIMESTAMP DEFAULT NOW()
);

-- Add constraints
ALTER TABLE products ADD CONSTRAINT fk_products_category
    FOREIGN KEY (category_id) REFERENCES categories(id);

ALTER TABLE sales_transactions ADD CONSTRAINT fk_sales_product
    FOREIGN KEY (product_id) REFERENCES products(id);

-- Create indexes
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_sales_product_id ON sales_transactions(product_id);
CREATE INDEX idx_sales_customer ON sales_transactions(customer_email);
CREATE INDEX idx_sales_date ON sales_transactions(sale_date);

-- Create a view
CREATE VIEW product_sales_summary AS
SELECT
    p.name as product_name,
    c.name as category_name,
    COUNT(st.id) as total_sales,
    SUM(st.total_amount) as total_revenue
FROM products p
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN sales_transactions st ON p.id = st.product_id
GROUP BY p.id, p.name, c.name;

-- Create a function
CREATE OR REPLACE FUNCTION update_product_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger
CREATE TRIGGER trigger_update_product_timestamp
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_product_timestamp();

-- Insert sample data (will NOT be included in schema-only dump)
INSERT INTO categories (name, description) VALUES
    ('Electronics', 'Electronic devices and gadgets'),
    ('Office', 'Office supplies and equipment'),
    ('Gaming', 'Gaming accessories and peripherals');

INSERT INTO products (name, price, category_id) VALUES
    ('MacBook Pro', 1999.99, 1),
    ('Wireless Mouse', 59.99, 2),
    ('Gaming Keyboard', 149.99, 3),
    ('Monitor 4K', 399.99, 1);

INSERT INTO sales_transactions (product_id, customer_email, quantity, unit_price) VALUES
    (1, 'alice@example.com', 1, 1999.99),
    (2, 'bob@example.com', 2, 59.99),
    (3, 'charlie@example.com', 1, 149.99);
"""

publisher_node.psql('sales', prepare_data_sql)

os.makedirs('dump_output', exist_ok=True)
schema_dump_file = os.path.join(os.getcwd(), 'dump_output', 'schema_only.sql')
data_dump_file = os.path.join(os.getcwd(), 'dump_output', 'data_only.sql')

# pg_dump -h localhost -p <port> -d sales --schema-only -f schema_only.sql
publisher_node.dump(schema_dump_file, dbname='sales', format=DumpFormat.Plain, options=['--schema-only'])
# pg_dump -h localhost -p <port> -d sales --data-only -f data_only.sql
publisher_node.dump(data_dump_file, dbname='sales', format=DumpFormat.Plain, options=['--data-only'])


# =============================================================================
# STEP 2: Create PUBLICATION for logical replication
# =============================================================================
publisher_node.psql('sales', 'CREATE PUBLICATION sales_publication FOR ALL TABLES;')


# =============================================================================
# STEP 3: Create and setup SUBSCRIBER node
# =============================================================================
subscriber_node = get_new_node("subscriber")
subscriber_node.init()  # initdb -D <data_directory>

subscriber_node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')
subscriber_node.start() # pg_ctl start -D <data_directory>


# =============================================================================
# STEP 4: Restore schema only to SUBSCRIBER
# =============================================================================
subscriber_node.psql('postgres', 'CREATE DATABASE sales;')

try:
    # psql -h localhost -p <subscriber.port> -d sales -f schema_only.sql -v ON_ERROR_STOP=1 -q
    psql_cmd = [
        'psql', '-h', 'localhost', '-p', str(subscriber_node.port),
        '-d', 'sales', '-f', schema_dump_file, '-v', 'ON_ERROR_STOP=1', '-q'
    ]
    subprocess.run(psql_cmd, capture_output=True, text=True, check=True)
except subprocess.CalledProcessError as e:
    print(f"Schema restoration failed: {e}")
    exit(1)

# Verify schema was restored
tables_check = subscriber_node.psql('sales', """
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
""")
print("Restore schema only to SUBSCRIBER")
print(f"Restored {tables_check[1].decode().strip()} tables on subscriber\n")

# Check that tables don't contain data
print("Check no data after restore schema only")
categories_count = subscriber_node.psql('sales', 'SELECT COUNT(*) FROM categories;')
print(f"Categories count before data load: {categories_count[1].decode().strip()}\n")

# =============================================================================
# STEP 5: Create subscription
# =============================================================================

# Create subscription with copy_data=false to avoid initial sync
subscription_sql = f"""
CREATE SUBSCRIPTION sales_subscription
CONNECTION 'host=localhost port={publisher_node.port} dbname=sales'
PUBLICATION sales_publication
WITH (copy_data = false);
"""

try:
    subscriber_node.psql('sales', subscription_sql)
    print("Created SUBSCRIPTION 'sales_subscription'")
except Exception as e:
    print(f"Error creating subscription: {e}")
    exit(1)


# Check replication slot was created
pub_slots = publisher_node.psql('sales', """
    SELECT slot_name, active FROM pg_replication_slots;
""")
print(pub_slots)

# Check subscription was created
sub_status = subscriber_node.psql('sales', """
    SELECT subname, subenabled FROM pg_subscription;
""")
print(f"Subscription status: {sub_status[1].decode().strip()}\n")

# =============================================================================
# STEP 6: Restore data to SUBSCRIBER
# =============================================================================

try:
    # psql -h localhost -p <subscriber.port> -d sales -f data_only.sql -v ON_ERROR_STOP=1 -q
    data_cmd = [
        'psql', '-h', 'localhost', '-p', str(subscriber_node.port),
        '-d', 'sales', '-f', data_dump_file, '-v', 'ON_ERROR_STOP=1', '-q'
    ]
    subprocess.run(data_cmd, capture_output=True, text=True, check=True)
    print("Data restored to SUBSCRIBER")
except subprocess.CalledProcessError as e:
    print(f"Data restoration error: {e}")
    exit(1)

# =============================================================================
# STEP 7: Check data after restore
# =============================================================================

cat_count_pub = publisher_node.psql('sales', 'SELECT COUNT(*) FROM categories;')
cat_count_sub = subscriber_node.psql('sales', 'SELECT COUNT(*) FROM categories;')
before_insert = f"Categories   - Publisher: {cat_count_pub[1].decode().strip()}, Subscriber: {cat_count_sub[1].decode().strip()}"
print(before_insert)

prod_count_pub = publisher_node.psql('sales', 'SELECT COUNT(*) FROM products;')
prod_count_sub = subscriber_node.psql('sales', 'SELECT COUNT(*) FROM products;')
print(f"Products     - Publisher: {prod_count_pub[1].decode().strip()}, Subscriber: {prod_count_sub[1].decode().strip()}")

trans_count_pub = publisher_node.psql('sales', 'SELECT COUNT(*) FROM sales_transactions;')
trans_count_sub = subscriber_node.psql('sales', 'SELECT COUNT(*) FROM sales_transactions;')
print(f"Transactions - Publisher: {trans_count_pub[1].decode().strip()}, Subscriber: {trans_count_sub[1].decode().strip()}\n")

# =============================================================================
# STEP 8: Real-time replication
# =============================================================================
test_insert = """
INSERT INTO categories (name, description) VALUES
    ('Books', 'Books and educational materials');
"""
print(test_insert)

publisher_node.psql('sales', test_insert)

# Wait a bit for replication
time.sleep(3)

# Check if data replicated
cat_count_pub_new = publisher_node.psql('sales', 'SELECT COUNT(*) FROM categories;')
cat_count_sub_new = subscriber_node.psql('sales', 'SELECT COUNT(*) FROM categories;')
print(f"Before insert:")
print(before_insert)
print(f"\nAfter insert:")
print(f"Categories - Publisher: {cat_count_pub_new[1].decode().strip()}, Subscriber: {cat_count_sub_new[1].decode().strip()}")
