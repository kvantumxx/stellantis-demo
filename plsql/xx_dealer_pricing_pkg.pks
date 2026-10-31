-- plsql/xx_dealer_pricing_pkg.pks
-- Dealer pricing package - list price lookup, dealer discount application, price request logging

CREATE OR REPLACE PACKAGE xx_dealer_pricing_pkg AS

  FUNCTION get_dealer_price (p_part_number IN VARCHAR2,
                             p_dealer_id   IN NUMBER) RETURN NUMBER;

  PROCEDURE refresh_list_price (p_part_number IN VARCHAR2,
                                p_new_price   IN NUMBER,
                                x_status      OUT VARCHAR2);

  PROCEDURE log_price_request (p_part_number IN VARCHAR2,
                               p_dealer_id   IN NUMBER,
                               p_price       IN NUMBER);

END xx_dealer_pricing_pkg;
/
