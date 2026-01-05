import os
from testgres import get_new_node, DumpFormat

node = get_new_node()
node.init()  # initdb -D <data_directory>
# In case of permission error use this command
node.append_conf('postgresql.conf', 'unix_socket_directories = \'/tmp\'')
node.start()  # pg_ctl start -D <data_directory>

node.psql('postgres', 'CREATE DATABASE sales;')


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

-- Insert sample data (will NOT be included in data-only dump)
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

node.psql('sales', prepare_data_sql)

data_dump_file = os.path.join(os.getcwd(), 'dump_output', 'data_only.sql')

# pg_dump -h localhost -p <port> -d sales --data-only -f data_only.sql
node.dump(data_dump_file, dbname='sales', format=DumpFormat.Plain, options=['--data-only'])
