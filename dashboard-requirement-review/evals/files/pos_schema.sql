-- 連鎖餐飲 POS 系統 現行資料表結構（MySQL 8.0）
-- 匯出日期 2026-08-05
-- 共 11 張表

-- ===== 門市 =====
CREATE TABLE stores (
  store_id      INT PRIMARY KEY,
  store_name    VARCHAR(50),
  region        VARCHAR(20),      -- 北區/中區/南區
  open_time     TIME,             -- 一般 17:00
  close_time    TIME,             -- 一般 02:00（跨日）
  is_active     TINYINT
);

-- ===== 品項主檔 =====
CREATE TABLE menu_items (
  item_id       INT PRIMARY KEY,
  item_name     VARCHAR(100),
  category_id   INT,             -- 目前分類
  unit_price    DECIMAL(10,2),   -- 目前售價
  cost          DECIMAL(10,2),
  is_active     TINYINT
);

CREATE TABLE categories (
  category_id   INT PRIMARY KEY,
  category_name VARCHAR(50)      -- 主餐/小菜/飲料/酒類/甜點
);

-- ===== 訂單 =====
CREATE TABLE orders (
  order_id      BIGINT PRIMARY KEY,
  store_id      INT,
  table_no      VARCHAR(10),
  member_id     INT NULL,         -- 沒帶卡就是 NULL
  guest_count   INT,              -- 服務生手動輸入
  total_amount  DECIMAL(10,2),    -- 含稅、已扣折扣後的實收
  discount_amt  DECIMAL(10,2),    -- 整單折扣，只記在這裡
  service_charge DECIMAL(10,2),
  pay_method    VARCHAR(20),
  created_at    DATETIME,         -- 開單時間
  closed_at     DATETIME          -- 結帳時間
);

CREATE TABLE order_items (
  order_item_id BIGINT PRIMARY KEY,
  order_id      BIGINT,
  item_id       INT,
  qty           INT,
  price         DECIMAL(10,2),    -- 當下售價
  created_at    DATETIME
);

-- ===== 退菜 / 作廢 =====
-- 註：目前只有整單作廢，單品退菜是店長直接在 order_items 刪除該列
CREATE TABLE void_orders (
  void_id       BIGINT PRIMARY KEY,
  order_id      BIGINT,
  reason        VARCHAR(100),
  void_by       VARCHAR(50),
  created_at    DATETIME
);

-- ===== 會員 =====
CREATE TABLE members (
  member_id     INT PRIMARY KEY,   -- 換卡會重發新號
  phone         VARCHAR(20),
  name          VARCHAR(50),
  join_date     DATE,
  member_level  VARCHAR(10),       -- 一般/銀卡/金卡，會隨消費升降
  points        INT                -- 目前剩餘點數
);

-- ===== 班別 =====
CREATE TABLE shifts (
  shift_id      BIGINT PRIMARY KEY,
  store_id      INT,
  staff_id      INT,
  clock_in      DATETIME,
  clock_out     DATETIME
);

CREATE TABLE staff (
  staff_id      INT PRIMARY KEY,
  staff_name    VARCHAR(50),
  store_id      INT,               -- 目前所屬門市
  position      VARCHAR(20)
);

-- ===== 訂位 =====
CREATE TABLE reservations (
  reservation_id BIGINT PRIMARY KEY,
  store_id       INT,
  phone          VARCHAR(20),
  party_size     INT,
  reserve_time   DATETIME,
  status         VARCHAR(20),      -- 已預約/已到店/未到/取消
  created_at     DATETIME
);

-- ===== 進貨 =====
CREATE TABLE purchases (
  purchase_id   BIGINT PRIMARY KEY,
  store_id      INT,
  item_id       INT,
  qty           INT,
  amount        DECIMAL(10,2),
  purchase_date DATE
);

-- 補充說明（IT 提供）：
-- 1. 資料保留：orders / order_items 永久保留，shifts 保留 2 年
-- 2. 沒有 updated_at 欄位；資料修正由店長透過後台直接改
-- 3. members 表若客人要求刪除個資，會直接 DELETE
-- 4. POS 離線時會先存本機，恢復連線後補上傳，時間戳用本機時間
