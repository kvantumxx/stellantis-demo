-- Creates the xxstr_gstin_status table with its primary key and indexes
CREATE TABLE xxstr_gstin_status
(
  HEADER_ID             NUMBER,
  GSTIN                 VARCHAR2(50 BYTE),
  TRADENAME             VARCHAR2(150 BYTE),
  LEGALNAME             VARCHAR2(150 BYTE),
  BUILDINGNAME          VARCHAR2(100 BYTE),
  BUILDINGNUMBER        VARCHAR2(150 BYTE),
  FLOORNUMBER           VARCHAR2(150 BYTE),
  STREET                VARCHAR2(150 BYTE),
  LOCATION              VARCHAR2(150 BYTE),
  STATECODE             VARCHAR2(30 BYTE),
  PINCODE               VARCHAR2(20 BYTE),
  TAXPAYERTYPE          VARCHAR2(150 BYTE),
  GSTIN_STATUS          VARCHAR2(150 BYTE),
  EWBGENERATIONSTATUS   VARCHAR2(150 BYTE),
  GSTIN_STATUS_MESSAGE  VARCHAR2(500 BYTE),
  VALIDATION_DATE       DATE,
  STATUS                VARCHAR2(50 BYTE),
  PARTY_TYPE            VARCHAR2(100 BYTE),
  PARTY_NUMBER          VARCHAR2(30 BYTE),
  PARTY_NAME            VARCHAR2(150 BYTE),
  PARTY_SITE_NAME       VARCHAR2(150 BYTE),
  CREATION_DATE         DATE,
  CREATED_BY            NUMBER,
  LAST_UPDATE_DATE      DATE,
  LAST_UPDATED_BY       NUMBER,
  VALIDATION_COUNT      NUMBER                  DEFAULT 1
)
/

ALTER TABLE xxstr_gstin_status
  ADD CONSTRAINT xxstr_gstin_status_pk PRIMARY KEY (HEADER_ID)
/

CREATE INDEX xxstr_gstin_status_gstin_idx ON xxstr_gstin_status (GSTIN)
/

CREATE INDEX xxstr_gstin_status_party_idx ON xxstr_gstin_status (PARTY_NUMBER)
/