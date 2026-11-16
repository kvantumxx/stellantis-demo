CREATE OR REPLACE PACKAGE BODY XXSTR_GSTIN_ONE_TIME_VALID
AS
/******************************************************************************
*  Script Name         : xxtsr_gstin_one_time_valid.pks
*
*  Script Owners       : Sterck Systems
*
*  Associated Release  : 2021.1
*
*  Functional Purpose  : 

*  Change History      :
*
*  PVCS Version    Date             Author           Change Description
*  ------------    -------------    ----------       -----------------
*  1.0             20-OCT-2021       Sterck Systems   Initial Version.
*
******************************************************************************/
PROCEDURE XXSTR_GSTIN_SUPPLIER_VALID
(   
    p_type             IN       VARCHAR2,
    x_status           OUT      VARCHAR2,
    x_statusmessage    OUT      VARCHAR2
)
IS
CURSOR sup_gst
IS
SELECT *
    FROM (SELECT distinct /*+ index (aps AP_SUPPLIERS_U1) */ assa.org_id,
                 aps.segment1  vendor_code,
                 aps.vendor_name,
                 assa.vendor_site_code,assa.address_line1,assa.address_line2,assa.address_line3,assa.address_line4, assa.city,assa.state, assa.country,  assa.zip,                 
                 ((SELECT MAX (registration_number)
                     FROM jai_party_regs     jpr,
                          jai_party_reg_lines jprl
                    WHERE     jpr.party_id = assa.vendor_id
                          AND party_site_id = assa.vendor_site_id
                          AND jpr.party_type_code = 'THIRD_PARTY_SITE'
                          AND jpr.supplier_flag = 'Y'
                          AND jpr.party_reg_id = jprl.party_reg_id
                          AND registration_type_code = 'GST'
                          AND regime_id = 10001
                          AND registration_number IS NOT NULL
                          AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                          jprl.effective_from)
                                                  AND NVL (
                                                          TRUNC (
                                                              jprl.effective_to),
                                                          TRUNC (SYSDATE))))
                     gstin
            FROM ap_suppliers aps, ap_supplier_sites_all assa
           WHERE aps.vendor_id = to_number(aps.vendor_id) and aps.vendor_id = assa.vendor_id)
   /*WHERE gstin NOT IN ('19AAACT2935J1Z5',
                                                          '29AAACT2935J1Z4',
                                                          '32AAACT2935J1ZH',
                                                          '27AAACT2935J1Z8',
                                                          '07AAACT2935J1ZA',
                                                          '37AAACT2935J1Z7',
                                                          '33AAACT2935J1ZF',
                                                          '36AAACT2935J1Z9',
                                                          '33AAACT2935J2ZE')*/
ORDER BY  vendor_code;
lv_context            VARCHAR2 (50)  := 'GSTIN_VALIDATE';
p_gstin               VARCHAR2 (50)  := NULL;
p_org_id              NUMBER         := NULL;
p_party_type          VARCHAR2 (50)  := NULL;
p_party_number        VARCHAR2 (50)  := NULL;
p_party_name          VARCHAR2 (100) := NULL;
p_party_site_name     VARCHAR2 (100) := NULL;
lv_status             VARCHAR2 (50)  := NULL;
lv_stausmessage       VARCHAR2 (500) := NULL;
BEGIN
FOR cur_hdr IN sup_gst
LOOP
p_gstin              := cur_hdr.gstin;
p_org_id             := cur_hdr.org_id;
p_party_type         := 'Supplier';
p_party_number       := cur_hdr.vendor_code;
p_party_name         := cur_hdr.vendor_name;
p_party_site_name    := cur_hdr.vendor_site_code;
BEGIN
xxstr_gst_engine_pkg.validate_gstin_wrapper
                                          (p_context            => lv_context,
                                           p_gstin              => p_gstin,
                                           p_org_id             => p_org_id,
                                           p_party_type         => p_party_type, 
                                           p_party_number       => p_party_number,
                                           p_party_name         => p_party_name,
                                           p_party_site_name    => p_party_site_name,
                                           x_status             => lv_status,
                                           x_statusmessage      => lv_stausmessage
                                          );
      DBMS_OUTPUT.put_line ('x_status          :  ' || lv_status);
      DBMS_OUTPUT.put_line ('x_status message  :  ' || lv_stausmessage);
      COMMIT;
EXCEPTION
WHEN OTHERS 
THEN
x_status := 'E';
x_statusmessage := 'Error:' || SQLERRM;
END;
END LOOP;
EXCEPTION
WHEN OTHERS 
THEN
x_status := 'E';
x_statusmessage := 'Error:' || SQLERRM;
END;

PROCEDURE XXSTR_GSTIN_CUSTOMER_VALID
(   
    p_type             IN       VARCHAR2,
    x_status           OUT      VARCHAR2,
    x_statusmessage    OUT      VARCHAR2
)
IS
CURSOR cus_gst
IS
--------------- Customer GSTN Details --------------------
select DISTINCT A.* --- , length(cust_gst_no)size
from 
(
select cust.account_number customer_number,acct.org_id,
 party_site.party_site_number,--  registration_type_code,
 party.party_name cust_name, 
 loc.ADDRESS1,loc.ADDRESS2,loc.ADDRESS3,loc.ADDRESS4,loc.city,loc.state, loc.country,loc.POSTAL_CODE,
 (select max (jprl.registration_number)
 from jai_party_regs jpr, jai_party_reg_lines jprl
 where jprl.party_reg_id = jpr.party_reg_id
 and jpr.party_site_id(+) = acct.cust_acct_site_id
 and jpr.party_id = cust.cust_account_id
 AND TRUNC (SYSDATE) BETWEEN TRUNC (jprl.effective_from)
                                             AND NVL
                                                    (TRUNC (jprl.effective_to),
                                                     TRUNC (SYSDATE)
                                                    )
 --- and registration_type_code = 'GST'
 and jpr.party_type_code in ('THIRD_PARTY_SITE')) cust_gst_no,
 (select max (registration_type_code)
 from jai_party_regs jpr, jai_party_reg_lines jprl
 where jprl.party_reg_id = jpr.party_reg_id
 and jpr.party_site_id(+) = acct.cust_acct_site_id
 and jpr.party_id = cust.cust_account_id
 AND TRUNC (SYSDATE) BETWEEN TRUNC (jprl.effective_from)
                                             AND NVL
                                                    (TRUNC (jprl.effective_to),
                                                     TRUNC (SYSDATE)
                                                    )
  ---- and registration_type_code <> 'GST'
 and jpr.party_type_code in ('THIRD_PARTY_SITE')) cust_gst_type
 from hz_cust_accounts_all cust,
 hz_cust_acct_sites_all acct,
 hz_cust_site_uses_all ship,
 hz_party_sites party_site,
 hz_locations loc,
 hz_parties party
 where cust.cust_account_id = acct.cust_account_id
 and acct.cust_acct_site_id = ship.cust_acct_site_id
 and acct.org_id = ship.org_id
 --and ship.site_use_code in('BILL_TO')
 and cust.status = 'A'
 and loc.location_id = party_site.location_id
 and acct.party_site_id = party_site.party_site_id
 and cust.party_id = party.party_id
 ) A
 where 1 = 1
-- and  cust_name like '%2S FORMS%'
 AND CUST_GST_NO NOT LIKE 'UN%'
 AND CUST_GST_NO NOT LIKE 'EXPO%'
 /*AND cust_gst_no not in( 
   '19AAACT2935J1Z5',
   '29AAACT2935J1Z4',
   '32AAACT2935J1ZH',
   '27AAACT2935J1Z8',
   '07AAACT2935J1ZA',
   '37AAACT2935J1Z7',
   '33AAACT2935J1ZF',
   '36AAACT2935J1Z9',
   '33AAACT2935J2ZE')
    AND cust_name not like '%TNPL%'*/
order by 5;

lv_context            VARCHAR2 (50)  := 'GSTIN_VALIDATE';
p_gstin               VARCHAR2 (50)  := NULL;
p_org_id              NUMBER         := NULL;
p_party_type          VARCHAR2 (50)  := NULL;
p_party_number        VARCHAR2 (50)  := NULL;
p_party_name          VARCHAR2 (100) := NULL;
p_party_site_name     VARCHAR2 (100) := NULL;
lv_status             VARCHAR2 (50)  := NULL;
lv_stausmessage       VARCHAR2 (500) := NULL;
BEGIN
FOR cur_lin IN cus_gst
LOOP
p_gstin              := cur_lin.cust_gst_no;
p_org_id             := cur_lin.org_id;
p_party_type         := 'Customer';
p_party_number       := cur_lin.customer_number;
p_party_name         := cur_lin.cust_name;
p_party_site_name    := cur_lin.party_site_number;
BEGIN
xxstr_gst_engine_pkg.validate_gstin_wrapper
                                          (p_context            => lv_context,
                                           p_gstin              => p_gstin,
                                           p_org_id             => p_org_id,
                                           p_party_type         => p_party_type, 
                                           p_party_number       => p_party_number,
                                           p_party_name         => p_party_name,
                                           p_party_site_name    => p_party_site_name,
                                           x_status             => lv_status,
                                           x_statusmessage      => lv_stausmessage
                                          );
      DBMS_OUTPUT.put_line ('x_status          :  ' || lv_status);
      DBMS_OUTPUT.put_line ('x_status message  :  ' || lv_stausmessage);
      COMMIT;
EXCEPTION
WHEN OTHERS 
THEN
x_status := 'E';
x_statusmessage := 'Error:' || SQLERRM;
END;
END LOOP;
EXCEPTION
WHEN OTHERS 
THEN
x_status := 'E';
x_statusmessage := 'Error:' || SQLERRM;
END;
END XXSTR_GSTIN_ONE_TIME_VALID;
/