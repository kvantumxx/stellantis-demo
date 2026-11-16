# Vision

Apply the code review findings below. Make only these fixes, nothing else.

=== Finding BUG-018 | LOW | BUG ===
Title    : CREATE TABLE has no statement terminator; no keys, constraints or indexes
Location : xxstr_gstin_status_table.sql, line 29
Problem  : The statement ends at line 29 without a semicolon or slash, so SQL*Plus will not execute it as a standalone script. The table has no primary key on HEADER_ID, no NOT NULL constraints, and no index on GSTIN or party columns. GSTIN_STATUS_MESSAGE is VARCHAR2(200) while the caller's message variable is 500 characters, so longer messages risk truncation or ORA-12899.
Fix      : Terminate the statement and add a primary key on HEADER_ID plus indexes on GSTIN and party_number. Align the message column length with the 500-character caller variable.
Proposed replacement code:
----------------------------------------
)
/
----------------------------------------
