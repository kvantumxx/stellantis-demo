-- plsql/xx_dealer_pricing_tables.sql
-- Supporting tables for the dealer pricing package

CREATE TABLE xx_part_prices (
  part_number  VARCHAR2(30) PRIMARY KEY,
  list_price   NUMBER NOT NULL,
  last_updated DATE
);

CREATE TABLE xx_dealers (
  dealer_id             NUMBER PRIMARY KEY,
  dealer_name           VARCHAR2(100),
  dealer_type           VARCHAR2(20),
  standard_discount_pct NUMBER NOT NULL
);

CREATE TABLE xx_price_request_log (
  log_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  part_number  VARCHAR2(30),
  dealer_id    NUMBER,
  quoted_price NUMBER,
  requested_on DATE
);
