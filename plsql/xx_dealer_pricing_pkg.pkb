-- plsql/xx_dealer_pricing_pkg.pkb
-- Dealer pricing package body - standard dealer discount applied flat from the dealer master

CREATE OR REPLACE PACKAGE BODY xx_dealer_pricing_pkg AS

  FUNCTION get_dealer_price (p_part_number IN VARCHAR2,
                             p_dealer_id   IN NUMBER) RETURN NUMBER
  IS
    l_list_price   NUMBER;
    l_discount_pct NUMBER;
    l_net_price    NUMBER;
  BEGIN
    SELECT list_price
      INTO l_list_price
      FROM xx_part_prices
     WHERE part_number = p_part_number;

    SELECT standard_discount_pct
      INTO l_discount_pct
      FROM xx_dealers
     WHERE dealer_id = p_dealer_id;

    l_net_price := ROUND(l_list_price * (1 - l_discount_pct / 100), 2);

    log_price_request(p_part_number, p_dealer_id, l_net_price);

    RETURN l_net_price;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END get_dealer_price;

  PROCEDURE refresh_list_price (p_part_number IN VARCHAR2,
                                p_new_price   IN NUMBER,
                                x_status      OUT VARCHAR2)
  IS
  BEGIN
    IF p_new_price IS NULL OR p_new_price <= 0 THEN
      x_status := 'ERROR: price must be positive';
      RETURN;
    END IF;

    UPDATE xx_part_prices
       SET list_price   = p_new_price,
           last_updated = SYSDATE
     WHERE part_number = p_part_number;

    IF SQL%ROWCOUNT = 0 THEN
      x_status := 'ERROR: part not found';
    ELSE
      x_status := 'SUCCESS';
    END IF;
  END refresh_list_price;

  PROCEDURE log_price_request (p_part_number IN VARCHAR2,
                               p_dealer_id   IN NUMBER,
                               p_price       IN NUMBER)
  IS
  BEGIN
    INSERT INTO xx_price_request_log (part_number, dealer_id, quoted_price, requested_on)
    VALUES (p_part_number, p_dealer_id, p_price, SYSDATE);
  END log_price_request;

END xx_dealer_pricing_pkg;
/
