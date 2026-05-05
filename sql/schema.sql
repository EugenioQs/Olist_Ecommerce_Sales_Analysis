-- =============================================================
-- Olist E-Commerce — Schema & Data Load
-- Crea la base de datos y carga los exports limpios de Python
-- Ejecutar desde la raíz del proyecto:
--   mysql -u root -p < sql/schema.sql
-- =============================================================

CREATE DATABASE IF NOT EXISTS olist_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE olist_db;

-- -------------------------------------------------------------
-- Tabla maestra (granularidad: 1 fila por item de orden)
-- -------------------------------------------------------------
DROP TABLE IF EXISTS orders_features;
CREATE TABLE orders_features (
    order_id                        VARCHAR(50),
    customer_id                     VARCHAR(50),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        DATETIME,
    order_approved_at               DATETIME,
    order_delivered_carrier_date    DATETIME,
    order_delivered_customer_date   DATETIME,
    order_estimated_delivery_date   DATETIME,
    order_item_id                   INT,
    product_id                      VARCHAR(50),
    seller_id                       VARCHAR(50),
    shipping_limit_date             DATETIME,
    price                           DECIMAL(10,2),
    freight_value                   DECIMAL(10,2),
    customer_unique_id              VARCHAR(50),
    customer_state                  VARCHAR(5),
    customer_city                   VARCHAR(100),
    product_category_name_english   VARCHAR(100),
    product_weight_g                DECIMAL(10,2),
    product_length_cm               DECIMAL(10,2),
    product_height_cm               DECIMAL(10,2),
    product_width_cm                DECIMAL(10,2),
    seller_zip_code_prefix          VARCHAR(10),
    seller_city                     VARCHAR(100),
    seller_state                    VARCHAR(5),
    payment_value                   DECIMAL(10,2),
    payment_installments            INT,
    payment_type                    VARCHAR(30),
    review_score                    TINYINT,
    revenue                         DECIMAL(10,2),
    total_cost                      DECIMAL(10,2),
    delivery_days                   INT,
    estimated_days                  INT,
    is_late                         TINYINT,
    days_early_late                 INT,
    purchase_year                   SMALLINT,
    purchase_month                  TINYINT,
    purchase_month_name             VARCHAR(5),
    purchase_quarter                TINYINT,
    purchase_day_of_week            TINYINT,
    purchase_year_month             VARCHAR(8),
    month_order                     TINYINT,
    day_of_week_name                VARCHAR(10),
    day_of_week_order               TINYINT
);

-- -------------------------------------------------------------
-- Tablas pre-agregadas
-- -------------------------------------------------------------
DROP TABLE IF EXISTS agg_monthly;
CREATE TABLE agg_monthly (
    purchase_year_month VARCHAR(8),
    purchase_year       SMALLINT,
    purchase_month      TINYINT,
    purchase_month_name VARCHAR(5),
    month_order         TINYINT,
    revenue             DECIMAL(12,2),
    orders              INT,
    items               INT,
    avg_ticket          DECIMAL(10,2)
);

DROP TABLE IF EXISTS agg_category;
CREATE TABLE agg_category (
    product_category_name_english VARCHAR(100),
    revenue                       DECIMAL(12,2),
    orders                        INT,
    items                         INT,
    avg_price                     DECIMAL(10,2),
    avg_review                    DECIMAL(4,2)
);

DROP TABLE IF EXISTS agg_state;
CREATE TABLE agg_state (
    customer_state      VARCHAR(5),
    revenue             DECIMAL(12,2),
    orders              INT,
    customers           INT,
    avg_delivery_days   DECIMAL(6,2),
    pct_late            DECIMAL(6,4)
);

DROP TABLE IF EXISTS agg_delivery;
CREATE TABLE agg_delivery (
    seller_state        VARCHAR(5),
    orders              INT,
    avg_delivery_days   DECIMAL(6,2),
    avg_estimated_days  DECIMAL(6,2),
    pct_late            DECIMAL(6,4),
    late_orders         INT
);

DROP TABLE IF EXISTS agg_sellers;
CREATE TABLE agg_sellers (
    seller_id   VARCHAR(50),
    seller_state VARCHAR(5),
    seller_city  VARCHAR(100),
    revenue      DECIMAL(12,2),
    orders       INT,
    items        INT,
    avg_price    DECIMAL(10,2),
    avg_review   DECIMAL(4,2)
);

DROP TABLE IF EXISTS agg_payment;
CREATE TABLE agg_payment (
    payment_type        VARCHAR(30),
    orders              INT,
    revenue             DECIMAL(12,2),
    avg_installments    DECIMAL(4,2)
);
