# Requirements

**Task Count:** 1
**Generated:** 2026-10-31T08:38:59.894506Z

## task_1
Modify the function get_dealer_price in the package body of xx_dealer_pricing_pkg so that dealers with dealer_type FLEET receive an additional 5% discount on top of their standard discount, with the total discount capped at 20%. Inputs: the existing package body source of xx_dealer_pricing_pkg (the .pkb file), the current implementation of get_dealer_price, and the existing dealer table or view the function already reads to resolve the standard discount. dealer_type must be read from the same source the function already queries for dealer attributes. Do not invent new tables, columns, or helper packages. If dealer_type is not reachable from the existing lookup, add it to the function's existing dealer query only.

Implementation: after the standard discount is resolved, add a branch for dealer_type = 'FLEET'. In that branch compute the fleet discount as the standard discount plus 5 percentage points, capped at 20 with LEAST. Guard the result with GREATEST against the original standard discount, so a fleet dealer whose standard discount already exceeds 20% is never reduced below it. Use the same unit (percent or fraction) and the same rounding and NULL handling as the existing code. Apply the resulting discount through the existing price calculation path.

Non-fleet behaviour must not change. Any dealer whose dealer_type is not FLEET, including NULL, must flow through the original logic unchanged, with identical return values, rounding, and exception handling. Preserve the function signature, return type, and parameter names exactly, so the package specification (.pks), callers, and grants are untouched and no recompilation of dependents is triggered by a spec change. Follow the existing naming, indentation, and exception-handling conventions of the package body. Keep comments minimal: one purpose comment at most, no inline comments, no section dividers.

Output: the complete, syntactically valid updated package body file for xx_dealer_pricing_pkg, compiling cleanly with no other subprograms altered.

Dependencies: none.
