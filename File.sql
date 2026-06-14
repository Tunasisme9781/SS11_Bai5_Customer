CREATE SCHEMA bai5;

CREATE TABLE bai5.customers (
                                customer_id SERIAL PRIMARY KEY,
                                name VARCHAR(100) NOT NULL,
                                balance NUMERIC(12,2) NOT NULL CHECK (balance >= 0)
);

CREATE TABLE bai5.products (
                               product_id SERIAL PRIMARY KEY,
                               name VARCHAR(100) NOT NULL,
                               stock INT NOT NULL CHECK (stock >= 0),
                               price NUMERIC(10,2) NOT NULL CHECK (price > 0)
);

CREATE TABLE bai5.orders (
                             order_id SERIAL PRIMARY KEY,
                             customer_id INT NOT NULL REFERENCES bai5.customers(customer_id),
                             total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
                             created_at TIMESTAMP NOT NULL DEFAULT NOW(),
                             status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                                 CHECK (status IN ('PENDING','COMPLETED','CANCELLED'))
);

CREATE TABLE bai5.order_items (
                                  item_id SERIAL PRIMARY KEY,
                                  order_id INT NOT NULL REFERENCES bai5.orders(order_id),
                                  product_id INT NOT NULL REFERENCES bai5.products(product_id),
                                  quantity INT NOT NULL CHECK (quantity > 0),
                                  subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0)
);
INSERT INTO bai5.customers(name, balance) VALUES
                                              ('Nguyen Van An', 5000000),
                                              ('Tran Thi Binh', 1200000),
                                              ('Le Hoang Nam', 800000),
                                              ('Pham Minh Quan', 25000000),
                                              ('Do Thi Huong', 300000),
                                              ('Vo Quoc Dat', 15000000),
                                              ('Nguyen Thu Ha', 0),
                                              ('Tran Gia Bao', 7000000),
                                              ('Le Thanh Tung', 450000),
                                              ('Pham Ngoc Anh', 100000000);
INSERT INTO bai5.products(name, stock, price) VALUES
                                                  ('Laptop MSI Cyborg 15', 15, 21000000),
                                                  ('iPhone 15', 20, 22000000),
                                                  ('Mechanical Keyboard', 50, 1500000),
                                                  ('Gaming Mouse', 80, 800000),
                                                  ('27 Inch Monitor', 25, 4500000),
                                                  ('USB 64GB', 100, 250000),
                                                  ('External SSD 1TB', 30, 2500000),
                                                  ('Webcam HD', 40, 900000),
                                                  ('Office Chair', 12, 3200000),
                                                  ('Bluetooth Headphone', 35, 1800000);
INSERT INTO bai5.orders(customer_id, total_amount, status) VALUES
                                                               (1, 22500000, 'COMPLETED'),
                                                               (2, 1500000, 'COMPLETED'),
                                                               (3, 800000, 'CANCELLED'),
                                                               (4, 4500000, 'COMPLETED'),
                                                               (5, 250000, 'PENDING'),
                                                               (6, 5000000, 'PENDING'),
                                                               (7, 900000, 'CANCELLED'),
                                                               (8, 3600000, 'COMPLETED'),
                                                               (9, 1800000, 'PENDING'),
                                                               (10, 43000000, 'COMPLETED');
INSERT INTO bai5.order_items(order_id, product_id, quantity, subtotal) VALUES

-- Order 1
(1, 1, 1, 21000000),
(1, 6, 6, 1500000),

-- Order 2
(2, 3, 1, 1500000),

-- Order 3
(3, 4, 1, 800000),

-- Order 4
(4, 5, 1, 4500000),

-- Order 5
(5, 6, 1, 250000),

-- Order 6
(6, 7, 2, 5000000),

-- Order 7
(7, 8, 1, 900000),

-- Order 8
(8, 10, 2, 3600000),

-- Order 9
(9, 10, 1, 1800000),

-- Order 10
(10, 2, 1, 22000000),
(10, 1, 1, 21000000),

-- Thêm một số dòng để đa dạng dữ liệu
(4, 3, 1, 1500000),
(6, 4, 2, 1600000),
(6, 6, 4, 1000000),
(8, 8, 2, 1800000),
(8, 6, 4, 1000000),
(2, 4, 1, 800000),
(1, 3, 1, 1500000),
(10, 10, 1, 1800000);

BEGIN;

DO $$
    DECLARE
        v_customer_id INT;
        v_balance NUMERIC(12,2);

        v_order_id INT;

        v_price1 NUMERIC(10,2);
        v_price3 NUMERIC(10,2);

        v_stock1 INT;
        v_stock3 INT;

        v_subtotal1 NUMERIC(12,2);
        v_subtotal3 NUMERIC(12,2);

        v_total NUMERIC(12,2);
    BEGIN

        -- Lấy thông tin khách hàng
        SELECT customer_id, balance
        INTO v_customer_id, v_balance
        FROM bai5.customers
        WHERE name = 'Tran Thi Binh';

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Khong tim thay khach hang';
        END IF;

        -- Lấy thông tin sản phẩm 1
        SELECT stock, price
        INTO v_stock1, v_price1
        FROM bai5.products
        WHERE product_id = 1;

        -- Lấy thông tin sản phẩm 3
        SELECT stock, price
        INTO v_stock3, v_price3
        FROM bai5.products
        WHERE product_id = 3;

        -- Kiểm tra tồn kho
        IF v_stock1 < 1 THEN
            RAISE EXCEPTION 'Product 1 khong du ton kho';
        END IF;

        IF v_stock3 < 2 THEN
            RAISE EXCEPTION 'Product 3 khong du ton kho';
        END IF;

        -- Tính tiền
        v_subtotal1 := v_price1 * 1;
        v_subtotal3 := v_price3 * 2;

        v_total := v_subtotal1 + v_subtotal3;

        -- Kiểm tra số dư
        IF v_balance < v_total THEN
            RAISE EXCEPTION 'Khach hang khong du tien';
        END IF;

        -- Tạo đơn hàng
        INSERT INTO bai5.orders(
            customer_id,
            total_amount,
            status
        )
        VALUES(
                  v_customer_id,
                  v_total,
                  'PENDING'
              )
        RETURNING order_id
            INTO v_order_id;

        -- Chi tiết đơn hàng
        INSERT INTO bai5.order_items(
            order_id,
            product_id,
            quantity,
            subtotal
        )
        VALUES
            (v_order_id,1,1,v_subtotal1);

        INSERT INTO bai5.order_items(
            order_id,
            product_id,
            quantity,
            subtotal
        )
        VALUES
            (v_order_id,3,2,v_subtotal3);

        -- Giảm tồn kho
        UPDATE bai5.products
        SET stock = stock - 1
        WHERE product_id = 1;

        UPDATE bai5.products
        SET stock = stock - 2
        WHERE product_id = 3;

        -- Trừ tiền khách
        UPDATE bai5.customers
        SET balance = balance - v_total
        WHERE customer_id = v_customer_id;

        -- Hoàn tất đơn
        UPDATE bai5.orders
        SET status = 'COMPLETED'
        WHERE order_id = v_order_id;

    END $$;

COMMIT;

UPDATE bai5.customers
SET balance = 50000000
WHERE name = 'Tran Thi Binh';

UPDATE bai5.products
SET stock = 50
WHERE product_id IN (1,3);