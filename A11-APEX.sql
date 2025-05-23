-- Title: A11-APEX.sql

CREATE TABLE date_dim (
  date_sk        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  full_ts        TIMESTAMP(6)  NOT NULL,   -- 2025-04-23 18:34:22.123456
  cal_day        DATE  NOT NULL,
  day_name       VARCHAR2(9),              -- Monday …
  fiscal_year    NUMBER(4),
  fiscal_qtr     NUMBER(1),
  is_bus_day     CHAR(1),                  -- Y/N (banking)
  is_trade_day   CHAR(1)                   -- Y/N (market)
);


CREATE TABLE customer_dim (
  cust_sk        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  cust_id_src    VARCHAR2(30),          -- natural key from source systems
  full_name      VARCHAR2(100),
  segment        VARCHAR2(10),         -- retail / private / corporate
  risk_rating    NUMBER(3,1),
  branch_now     VARCHAR2(10),          -- current branch  (Type-3)
  branch_prev    VARCHAR2(10),          -- previous branch (Type-3)
  start_ts       TIMESTAMP(6),          -- when customer was created
  end_ts         TIMESTAMP(6),
  is_current     CHAR(1)                -- Y / N
);


CREATE TABLE product_dim   (prod_sk  NUMBER GENERATED AS IDENTITY PRIMARY KEY, prod_id  VARCHAR2(20), prod_name VARCHAR2(60), prod_type VARCHAR2(12));

CREATE TABLE branch_dim    (branch_sk NUMBER GENERATED AS IDENTITY PRIMARY KEY, branch_id VARCHAR2(10), branch_name VARCHAR2(60), region VARCHAR2(20));

CREATE TABLE channel_dim   (chan_sk   NUMBER GENERATED AS IDENTITY PRIMARY KEY, chan_name VARCHAR2(20));   -- Branch / Online / Mobile / Call

CREATE TABLE risk_dim      (risk_sk   NUMBER GENERATED AS IDENTITY PRIMARY KEY, risk_cd   VARCHAR2(10), risk_name VARCHAR2(40));


CREATE TABLE bank_txn_fact (          -- deposits / withdrawals / transfers
  txn_id        NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  date_sk       NUMBER,
  cust_sk       NUMBER,
  prod_sk       NUMBER,               -- the deposit account product
  branch_sk     NUMBER,
  chan_sk       NUMBER,
  txn_type      VARCHAR2(12),
  amount        NUMBER(18,2)
);

CREATE TABLE loan_fact (              -- every loan event
  loan_evt_id   NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  date_sk       NUMBER,
  cust_sk       NUMBER,
  prod_sk       NUMBER,               -- the loan product
  evt_type      VARCHAR2(12),         -- APPLY / PAY / DEFAULT …
  evt_amt       NUMBER(18,2)
);

CREATE TABLE trade_fact (             -- each executed trade
  trade_id      NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  date_sk       NUMBER,
  cust_sk       NUMBER,
  prod_sk       NUMBER,               -- investment product
  exch_code     VARCHAR2(8),
  side_bs       CHAR(1),              -- B / S
  qty           NUMBER,
  price         NUMBER(18,4),
  fee           NUMBER(18,2)
);

CREATE TABLE interact_fact (          -- one customer touch-point
  int_id        NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  date_sk       NUMBER,
  cust_sk       NUMBER,
  chan_sk       NUMBER,
  topic         VARCHAR2(20)
);

CREATE TABLE prod_perf_fact (         -- nightly KPIs per product
  snap_dt       DATE,
  prod_sk       NUMBER,
  kpi_code      VARCHAR2(10),         -- PROFIT / LOSS / REVENUE / COST
  kpi_val       NUMBER(18,4),
  PRIMARY KEY (snap_dt, prod_sk, kpi_code)
);

CREATE TABLE risk_fact (              -- risk metrics at any moment
  risk_id       NUMBER GENERATED AS IDENTITY PRIMARY KEY,
  date_sk       NUMBER,
  risk_sk       NUMBER,
  port_id       VARCHAR2(30),
  risk_val      NUMBER(18,6)
);
