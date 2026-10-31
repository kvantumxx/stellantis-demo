# Vision

refresh_list_price accepts any positive price, so a typo can double a part’s price instantly. Add a guard in xx_dealer_pricing_pkg.refresh_list_price: reject an update that raises the price more than 25% above the current list price, return status ‘ERROR: increase above threshold’, and log the rejected attempt. Normal updates within the threshold are unchanged.
