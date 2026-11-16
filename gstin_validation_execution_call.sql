DECLARE
lv_context            VARCHAR2 (50)  := 'GSTIN_VALIDATE';
p_gstin               VARCHAR2 (50)  := NULL;
p_org_id              NUMBER         := NULL;
p_party_type          VARCHAR2 (50)  := NULL;
p_party_number        VARCHAR2 (50)  := NULL;
p_party_name          VARCHAR2 (100) := NULL;
p_party_site_name     VARCHAR2 (100) := NULL;
lc_status             VARCHAR2 (50)  ;
lc_statusmessage       VARCHAR2 (5000) ;
BEGIN
xxstr_gst_engine_pkg.validate_gstin_wrapper
                                          (p_context            => lv_context,
                                           p_gstin              => p_gstin,
                                           p_org_id             => p_org_id,
                                           p_party_type         => p_party_type, 
                                           p_party_number       => p_party_number,
                                           p_party_name         => p_party_name,
                                           p_party_site_name    => p_party_site_name,
                                           x_status             => lc_status,
                                           x_statusmessage      => lc_statusmessage
                                          );
      DBMS_OUTPUT.put_line ('x_status          :  ' || lc_status);
      DBMS_OUTPUT.put_line ('x_status message  :  ' || lc_statusmessage);
      COMMIT;
EXCEPTION
WHEN OTHERS 
THEN
NULL;
END;