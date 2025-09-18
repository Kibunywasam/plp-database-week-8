-- E-commerce Store Database Management System
-- Created for a real-world e-commerce use case

-- Create the database
CREATE DATABASE IF NOT EXISTS ecommerce_store;
USE ecommerce_store;

-- Table: users
-- Stores customer and admin user information
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    user_type ENUM('customer', 'admin') DEFAULT 'customer'
);

-- Table: user_profiles (One-to-One with users)
-- Additional profile information for users
CREATE TABLE user_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    bio TEXT,
    profile_picture_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table: categories
-- Product categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Table: products
-- Product information
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    cost DECIMAL(10, 2) CHECK (cost >= 0),
    sku VARCHAR(100) NOT NULL UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- Table: product_images
-- Multiple images per product (One-to-Many)
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Table: addresses
-- Customer shipping/billing addresses (One-to-Many with users)
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_type ENUM('shipping', 'billing') DEFAULT 'shipping',
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Table: orders
-- Customer orders (One-to-Many with users)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (tax_amount >= 0),
    shipping_cost DECIMAL(10, 2) DEFAULT 0.00 CHECK (shipping_cost >= 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    shipping_address_id INT NOT NULL,
    billing_address_id INT NOT NULL,
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id) ON DELETE RESTRICT
);

-- Table: order_items
-- Items within each order (Many-to-One with orders, Many-to-One with products)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
);

-- Table: reviews
-- Product reviews by users (One-to-Many with users and products)
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(255),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_review (user_id, product_id)
);

-- Table: tags
-- Tags for products (Many-to-Many relationship with products)
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Junction table for Many-to-Many relationship: products and tags
CREATE TABLE product_tags (
    product_id INT NOT NULL,
    tag_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, tag_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- Table: coupons
-- Discount coupons (Many-to-Many with users via user_coupons)
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    min_order_amount DECIMAL(10, 2) DEFAULT 0.00 CHECK (min_order_amount >= 0),
    max_discount_amount DECIMAL(10, 2),
    valid_from TIMESTAMP NOT NULL,
    valid_until TIMESTAMP NOT NULL,
    max_uses INT DEFAULT NULL,
    uses_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (valid_from < valid_until)
);

-- Junction table for Many-to-Many relationship: users and coupons
CREATE TABLE user_coupons (
    user_id INT NOT NULL,
    coupon_id INT NOT NULL,
    redeemed_at TIMESTAMP NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, coupon_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) ON DELETE CASCADE
);

-- Table: wishlists
-- User wishlists (Many-to-Many relationship between users and products)
CREATE TABLE wishlists (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- Table: shopping_cart
-- User shopping cart items (Many-to-Many relationship with additional attributes)
CREATE TABLE shopping_cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (user_id, product_id)
);

-- Table: payments
-- Payment records for orders (One-to-One with orders)
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(50) NOT NULL,
    transaction_id VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Table: shipping_providers
-- Available shipping providers
CREATE TABLE shipping_providers (
    provider_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    tracking_url_template VARCHAR(500),
    estimated_delivery_days INT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Table: shipments
-- Shipment tracking for orders (One-to-One with orders)
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    provider_id INT NOT NULL,
    tracking_number VARCHAR(255),
    status ENUM('pending', 'shipped', 'in_transit', 'delivered', 'returned') DEFAULT 'pending',
    shipped_date TIMESTAMP NULL,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES shipping_providers(provider_id) ON DELETE RESTRICT
);





-- INSERT SAMPLE DATA INTO E-COMMERCE DATABASE


-- Insert Users (5 customers + 1 admin)
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, user_type) VALUES
('john_doe', 'john.doe@email.com', '$2a$10$N.zmdr9k7uOCQb376NoPeuR2R0/7KJkx0Mz.4lV6YdUwYjW0eXr7q', 'John', 'Doe', '+1-555-123-4567', 'customer'),
('jonte_fresh', 'jonte.fresh@email.com', '$2a$10$N.zmdr9k7uOCQb376NoPeuR2R0/7KJkx0Mz.4lV6YdUwYjW0eXr7q', 'Jane', 'Smith', '+1-555-987-6543', 'customer'),
('mike_mbwa', 'mike.mbwa@email.com', '$2a$10$N.zmdr9k7uOCQb376NoPeuR2R0/7KJkx0Mz.4lV6YdUwYjW0eXr7q', 'Mike', 'Brown', '+1-555-456-7890', 'customer'),
('sarah_lee', 'sarah.lee@email.com', '$2a$10$N.zmdr9k7uOCQb376NoPeuR2R0/7KJkx0Mz.4lV6YdUwYjW0eXr7q', 'Sarah', 'Lee', '+1-555-321-6549', 'customer'),
('jackie_chan', 'jackie.chan@email.com', '$2a$10$N.zmdr9k7uOCQb376NoPeuR2R0/7KJkx0Mz.4lV6YdUwYjW0eXr7q', 'David', 'Wilson', '+1-555-654-3210', 'customer'),
('admin_user', 'admin@store.com', '$2a$10$N.zmdr9k7uOCQb376NoPeuR2R0/7KJkx0Mz.4lV6YdUwYjW0eXr7q', 'Admin', 'User', '+1-555-000-0000', 'admin');

-- Insert User Profiles
INSERT INTO user_profiles (user_id, date_of_birth, gender, bio) VALUES
(1, '1990-05-15', 'Male', 'Tech enthusiast and frequent online shopper.'),
(2, '1985-12-22', 'Female', 'Loves fashion and home decor. Always hunting for deals.'),
(3, '1992-03-30', 'Male', 'Gamer and gadget collector.'),
(4, '1988-07-19', 'Female', 'Fitness coach and wellness advocate.'),
(5, '1995-11-08', 'Male', 'Student and part-time streamer.');

-- Insert Categories (with parent-child hierarchy)
INSERT INTO categories (name, description, parent_category_id) VALUES
('Electronics', 'Devices and gadgets for everyday use.', NULL),
('Computers', 'Laptops, desktops, and accessories.', 1),
('Smartphones', 'Mobile phones and accessories.', 1),
('Home & Kitchen', 'Products for your home and kitchen.', NULL),
('Furniture', 'Indoor and outdoor furniture.', 4),
('Cookware', 'Pots, pans, and kitchen tools.', 4),
('Fashion', 'Clothing and accessories.', NULL),
('Men''s Clothing', 'Apparel for men.', 7),
('Women''s Clothing', 'Apparel for women.', 7);

-- Insert Products
INSERT INTO products (name, description, price, cost, sku, stock_quantity, category_id) VALUES
('MacBook Pro 16"', 'Apple MacBook Pro with M2 Pro chip, 16GB RAM, 512GB SSD.', 2499.99, 1800.00, 'MBP16-M2-512', 25, 2),
('iPhone 15 Pro', '6.1-inch Super Retina XDR display, A17 Pro chip.', 999.99, 650.00, 'IP15-PRO-256', 50, 3),
('Dell XPS 13', 'Ultra-thin laptop with 13.4" FHD+ display, Intel i7.', 1199.99, 800.00, 'DXPS13-I7-512', 30, 2),
('Non-Stick Frying Pan Set', '3-piece ceramic non-stick frying pan set.', 49.99, 20.00, 'NSPAN-SET3', 100, 6),
('Modern Office Chair', 'Ergonomic mesh office chair with lumbar support.', 199.99, 90.00, 'OFFCHAIR-MOD01', 40, 5),
('Men''s Slim Fit Jeans', 'Classic blue denim, slim fit, 100% cotton.', 59.99, 25.00, 'JEANS-MEN-SLIM', 200, 8),
('Women''s Summer Dress', 'Floral print, lightweight cotton, sizes S-XL.', 39.99, 15.00, 'DRESS-WOM-SUMMER', 150, 9);

-- Insert Product Images
INSERT INTO product_images (product_id, image_url, is_primary, display_order) VALUES
(1, 'https://https://images.pexels.com/photos/3568521/pexels-photo-3568521.jpeg', TRUE, 1),
(1, 'https://https://images.pexels.com/photos/2047905/pexels-photo-2047905.jpeg', FALSE, 2),
(2, 'https://https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg', TRUE, 1),
(3, 'https://https://images.pexels.com/photos/1266982/pexels-photo-1266982.jpeg', TRUE, 1),
(4, 'https://https://images.pexels.com/photos/1194434/pexels-photo-1194434.jpeg', TRUE, 1),
(5, 'https://https://images.pexels.com/photos/2762247/pexels-photo-2762247.jpeg', TRUE, 1),
(6, 'https://https://images.pexels.com/photos/1082529/pexels-photo-1082529.jpeg', TRUE, 1),
(7, 'https://https://images.pexels.com/photos/985635/pexels-photo-985635.jpeg', TRUE, 1);

-- Insert Addresses
INSERT INTO addresses (user_id, address_type, street_address, city, state_province, postal_code, country, is_default) VALUES
(1, 'shipping', '123 oloo St', 'Eldoret', 'hehe', '10001', 'KENYA', TRUE),
(1, 'billing', '123 Main St', 'Nairobi', 'wewe', '10001', 'KENYA', TRUE),
(2, 'shipping', '456 kenyatta Ave', 'Nairobi', 'ooh', '90210', 'KENYA', TRUE),
(2, 'billing', '456 moi Ave', 'Nairobi', 'sijui', '90210', 'KENYA', TRUE),
(3, 'shipping', '789 odinga Rd', 'Kisumu', 'raila', '60601', 'KENYA', TRUE),
(4, 'shipping', '321 Ushirika', 'Limuru', 'mf', '33101', 'KENYA', TRUE),
(5, 'shipping', '654 Koinange', 'Nairobi', 'nugu', '98101', 'KENYA', TRUE);

-- Insert Orders
INSERT INTO orders (user_id, order_number, status, subtotal, tax_amount, shipping_cost, total_amount, shipping_address_id, billing_address_id, payment_method) VALUES
(1, 'ORD000001', 'delivered', 2499.99, 199.99, 0.00, 2699.98, 1, 1, 'Credit Card'),
(2, 'ORD000002', 'shipped', 1049.98, 84.00, 10.00, 1143.98, 3, 3, 'PayPal'),
(3, 'ORD000003', 'pending', 1199.99, 96.00, 0.00, 1295.99, 5, 5, 'Credit Card');

-- Insert Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 1, 2499.99, 2499.99),
(2, 2, 1, 999.99, 999.99),
(2, 4, 1, 49.99, 49.99),
(3, 3, 1, 1199.99, 1199.99);

-- Insert Reviews
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_verified_purchase) VALUES
(1, 1, 5, 'Amazing Performance', 'This MacBook is a beast! Handles everything I throw at it.', TRUE),
(2, 2, 4, 'Great Phone', 'Love the camera and battery life. A bit expensive though.', TRUE),
(3, 3, 5, 'Perfect for Work', 'Lightweight and powerful. Best laptop I’ve owned.', TRUE),
(4, 2, 5, 'Sticks Like Magic', 'No oil needed! Cleans up easily. Highly recommend.', TRUE),
(6, 4, 4, 'Stylish and Comfortable', 'Fits true to size. Looks great for casual outings.', TRUE);

-- Insert Tags
INSERT INTO tags (name) VALUES
('Apple'), ('Laptop'), ('Smartphone'), ('Premium'), ('Kitchen'), ('Furniture'), ('Fashion'), ('Sale'), ('New Arrival');

-- Insert Product Tags (Many-to-Many)
INSERT INTO product_tags (product_id, tag_id) VALUES
(1, 1), (1, 2), (1, 4),
(2, 1), (2, 3), (2, 4),
(3, 2),
(4, 5), (4, 8),
(5, 6),
(6, 7), (6, 8),
(7, 7), (7, 9);

-- Insert Coupons
INSERT INTO coupons (code, description, discount_type, discount_value, min_order_amount, valid_from, valid_until, max_uses) VALUES
('WELCOME10', 'Welcome discount for new users', 'percentage', 10.00, 50.00, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1000),
('SAVE50', 'Flat $50 off orders over $200', 'fixed_amount', 50.00, 200.00, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), 200);

-- Insert User Coupons (Many-to-Many)
INSERT INTO user_coupons (user_id, coupon_id, is_used) VALUES
(1, 1, FALSE),
(2, 1, TRUE),
(3, 2, FALSE),
(4, 1, FALSE);

-- Insert Wishlists
INSERT INTO wishlists (user_id, product_id) VALUES
(1, 2), -- John wishes for iPhone
(2, 5), -- Jane wishes for Office Chair
(3, 7), -- Mike wishes for Summer Dress (gift?)
(4, 1), -- Sarah wishes for MacBook Pro
(5, 6); -- David wishes for Jeans

-- Insert Shopping Cart Items
INSERT INTO shopping_cart (user_id, product_id, quantity) VALUES
(1, 4, 2), -- John has 2 frying pans in cart
(2, 6, 1), -- Jane has 1 jeans in cart
(4, 7, 3); -- Sarah has 3 dresses in cart

-- Insert Payments
INSERT INTO payments (order_id, payment_method, transaction_id, amount, status) VALUES
(1, 'Credit Card', 'TXN-MC-1001', 2699.98, 'completed'),
(2, 'PayPal', 'TXN-PP-1002', 1143.98, 'completed'),
(3, 'Credit Card', 'TXN-MC-1003', 1295.99, 'pending');

-- Insert Shipping Providers
INSERT INTO shipping_providers (name, tracking_url_template, estimated_delivery_days) VALUES
('Fargo', 'https://www.Fargo.com/Fargotrack/?trknbr={TRACKING_NUMBER}', 3),
('G4S', 'https://www.G4S.com/track?tracknum={TRACKING_NUMBER}', 4),
('Carrier', 'https://tools.Carrier.com/go/TrackConfirmAction?tLabels={TRACKING_NUMBER}', 5);

-- Insert Shipments
INSERT INTO shipments (order_id, provider_id, tracking_number, status, shipped_date, estimated_delivery_date) VALUES
(1, 1, 'FDX123456789', 'delivered', '2024-05-01 09:30:00', '2024-05-04'),
(2, 2, '1Z999AA10123456784', 'in_transit', '2024-06-05 14:20:00', '2024-06-09');