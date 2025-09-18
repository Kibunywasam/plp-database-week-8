#  E-Commerce Store Database

> **A complete, production-ready relational database schema for an e-commerce platform built with MySQL.**

---

##  Overview

This project provides a **fully functional relational database** designed to power a real-world **e-commerce store**. It includes:

-  Schema design with normalized tables
-  Realistic sample data for immediate testing
-  Proper constraints, relationships, and indexes
-  Support for users, products, orders, payments, shipping, reviews, coupons, wishlists, and more

Built for **MySQL 8.0+**, this database is ready to integrate with any backend framework (Node.js, Django, Laravel, Spring Boot, etc.).

---

##  Database Structure

### Core Tables

| Table                 | Description |
|----------------------|-------------|
| `users`              | Customer and admin accounts |
| `user_profiles`      | Extended user info (One-to-One) |
| `categories`         | Hierarchical product categories |
| `products`           | Product catalog with pricing and stock |
| `product_images`     | Multiple images per product |
| `addresses`          | Shipping and billing addresses |
| `orders`             | Customer orders with totals and status |
| `order_items`        | Items within each order |
| `reviews`            | Product reviews with ratings |
| `tags` + `product_tags` | Tagging system for products (Many-to-Many) |
| `coupons` + `user_coupons` | Discount system with usage limits |
| `wishlists`          | Saved products per user |
| `shopping_cart`      | Current cart items per user |
| `payments`           | Payment records linked to orders |
| `shipping_providers` | Carrier services (FedEx, UPS, USPS) |
| `shipments`          | Shipment tracking and delivery status |

---

##  Relationships Implemented

| Type              | Example |
|-------------------|---------|
| **One-to-One**    | `users` ↔ `user_profiles`, `orders` ↔ `payments`, `orders` ↔ `shipments` |
| **One-to-Many**   | `users` → `addresses`, `categories` → `products`, `products` → `product_images` |
| **Many-to-Many**  | `products` ↔ `tags`, `users` ↔ `coupons`, `users` ↔ `products` (via `wishlists`/`shopping_cart`) |

---

##  Constraints & Data Integrity

-  **Primary Keys** on every table
-  **Foreign Keys** with appropriate `ON DELETE` behavior
-  **NOT NULL** on required fields
-  **UNIQUE** constraints (email, username, SKU, order_number, etc.)
-  **CHECK** constraints (e.g., `price >= 0`, `rating BETWEEN 1 AND 5`)
-  **ENUMs** for controlled values (status, gender, user_type, etc.)
-  **Timestamps** for auditing (`created_at`, `updated_at`)

---

##  Sample Data Included

The database comes pre-loaded with realistic sample data for immediate testing:

- **6 Users** (5 customers + 1 admin)
- **9 Categories** with hierarchy (e.g., Electronics → Smartphones)
- **7 Products** (MacBook Pro, iPhone 15, Office Chair, etc.)
- **3 Orders** with items, payments, and shipments
- **5 Reviews**, **9 Tags**, **2 Coupons**, **3 Wishlist entries**, **3 Cart items**

---
--  Find top-rated products
SELECT p.name, AVG(r.rating) as avg_rating
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id
ORDER BY avg_rating DESC;

--  View a user's cart
SELECT u.username, p.name, sc.quantity, p.price
FROM shopping_cart sc
JOIN users u ON sc.user_id = u.user_id
JOIN products p ON sc.product_id = p.product_id
WHERE u.username = 'john_doe';

--  Track shipped orders
SELECT o.order_number, s.status, sp.name as carrier, s.tracking_number
FROM orders o
JOIN shipments s ON o.order_id = s.order_id
JOIN shipping_providers sp ON s.provider_id = sp.provider_id
WHERE o.status = 'shipped'
##  Setup Instructions

### Prerequisites

- MySQL Server 8.0+ (or MariaDB 10.5+)
- MySQL client or GUI tool (e.g., MySQL Workbench, phpMyAdmin, DBeaver, or command line)

### Installation

1. **Save the SQL file** as `ecommerce_store_complete.sql`

2. **Import into MySQL**:

   **Via Terminal:**
   ```bash
   mysql -u your_username -p < ecommerce_store_complete.sql
