# Vision

The flat dealer discount is wrong for fleet dealers. In xx_dealer_pricing_pkg, apply a dealer-type based discount in get_dealer_price: dealers with dealer_type FLEET get an additional 5% over their standard discount, capped at 20% total. Non-fleet dealer behaviour must not change.
