CREATE OR REPLACE PACKAGE BODY xxstr_gst_engine_pkg AS
/******************************************************************************
*  Script Name         : xxstr_gst_engine_pkg.pks
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
*  1.0             29-JUL-2021      Sterck Systems   Initial Version.
*
******************************************************************************/

FUNCTION getLookupMeaning(p_lookup_type  IN  VARCHAR2,
                          p_lookup_code  IN  VARCHAR2)
RETURN VARCHAR2
IS

  lc_lookup_meaning  VARCHAR2(200);

BEGIN

  BEGIN
--    SELECT DECODE(p_lookup_code,'EINVOICE_AUTH_TOKEN',description,meaning)
--      INTO lc_lookup_meaning
--    FROM  fnd_lookup_values_vl
--    WHERE
--      lookup_type = p_lookup_type  AND
--      enabled_flag = 'Y'                     AND
--      lookup_code = p_lookup_code;

    NULL;
  EXCEPTION
  WHEN OTHERS THEN
    lc_lookup_meaning := NULL;
  END;

  RETURN lc_lookup_meaning;

EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;



PROCEDURE gstin_publish2cleartax(p_gstin          IN   VARCHAR2,
                                 p_context        IN   VARCHAR2,
                                 p_json_payload   IN   LONG,
                                   p_party_type      IN   VARCHAR2,
                                 p_party_number    IN   VARCHAR2,
                                 p_party_name      IN   VARCHAR2,
                                 p_party_site_name IN   VARCHAR2,                                 
                                 x_status         OUT  VARCHAR2,
                                 x_statusmessage  OUT  VARCHAR2)
   IS

    ln_count                  NUMBER   := 0;
    lc_request                utl_http.req;
    lc_response               json;

    lc_base_response_payload  VARCHAR2(32766) := NULL; --LONG;
    lc_response_payload       VARCHAR2(32766) := NULL;

    lc_supplier_gstin         VARCHAR2(50)  := NULL;
    lc_enabled_flag           VARCHAR2(3)   := 'Y';
    
    lc_gstin_api_url          VARCHAR2(500);
    
    lc_error_message          VARCHAR2(1000) := NULL;
    lc_error_code             VARCHAR2(100) := NULL;


    lc_einv_owner_id          VARCHAR2(100);
    lc_einv_auth_token        VARCHAR2(200);
    lc_wallet_path            VARCHAR2(100) := NULL;
    lc_wallet_password        VARCHAR2(20)  := NULL;

    lc_statusmessage          VARCHAR2(32766) := NULL;
    lc_document_number        VARCHAR2(100)   := NULL;
    
    lc_vc_header_name         VARCHAR2(256);
    lc_vc_header_value        VARCHAR2(1024);

    x_payload                 VARCHAR2(32766) := NULL; --LONG;

BEGIN


  --x_payload := p_json_payload;

---
-- GSTIN Validation API sandbox: https://einvoicing.internal.cleartax.co?/v1/govt/api/Master/gstin/
---

  /*----------------------------------------------------------------------------------------*/
  --                  SET HEADER
  /*----------------------------------------------------------------------------------------*/
  BEGIN


    IF p_context  LIKE  '%GSTIN%'
    THEN 
      SELECT utl_http.request('http://192.168.2.47:5000/gstin/validate/'||p_gstin)
        INTO lc_base_response_payload
      FROM dual; 
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;

  /*----------------------------------------------------------------------------------------*/

  --dbms_output.put_line('Response Payload = '||lc_base_response_payload);

  BEGIN
    gstin_response_wrapper(p_gstin           => p_gstin,
                           p_response        => lc_base_response_payload,
                           p_context         => p_context,
                           p_party_type      => p_party_type, 
                           p_party_number    => p_party_number,
                           p_party_name      => p_party_name,
                           p_party_site_name => p_party_site_name,
                           x_status             => x_status,
                           x_statusmessage      => x_statusmessage);
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;

    


  EXCEPTION
  WHEN OTHERS THEN
   x_status        := 'E';
   x_statusmessage := SQLERRM;
   dbms_output.put_line('Error = ' || SQLERRM);
  END;


PROCEDURE gstin_response_wrapper(p_gstin          IN   VARCHAR2,
                                 p_response       IN   VARCHAR2,
                                 p_context        IN   VARCHAR2,
                                 p_party_type      IN   VARCHAR2,
                                 p_party_number    IN   VARCHAR2,
                                 p_party_name      IN   VARCHAR2,
                                 p_party_site_name IN   VARCHAR2,
                                 x_status         OUT  VARCHAR2,
                                 x_statusmessage  OUT  VARCHAR2)
IS

  lc_statusmessage          VARCHAR2(32766);

  lc_response               VARCHAR2(32766);
  lc_base_response_payload  VARCHAR2(32766);
  lc_response_payload       json;

  lc_gstin_exists_flag      VARCHAR2(1)    := 'N';
  lc_success                VARCHAR2(50)   := 'Y';
  lc_error_message          VARCHAR2(500);
  lc_error_details          VARCHAR2(500);
  
  ln_header_id              NUMBER;
  lc_gstin                  VARCHAR2(50);
  lc_trade_name             VARCHAR2(150);
  lc_legal_name             VARCHAR2(150);
  lc_building_name          VARCHAR2(150);
  lc_building_number        VARCHAR2(100);
  lc_floor_number           VARCHAR2(100);
  lc_street                 VARCHAR2(100);
  lc_location               VARCHAR2(100);
  lc_state_code             VARCHAR2(50);
  lc_pin_code               VARCHAR2(30);
  lc_taxpayer_type          VARCHAR2(50);
  lc_gstin_status           VARCHAR2(50);
  lc_ewb_generation_status    VARCHAR2(50);
  lc_status                 VARCHAR2(50);
  
  tempdata json_value;

BEGIN
  --LOOP
  BEGIN


    --dbms_output.put_line('entered....');
      
    lc_response := p_response;


  lc_base_response_payload := '{
    "gstin": "29AAFCD5862R000",
    "tradeName": "DEFMACRO SOFTWARE LEGAL NAME",
    "legalName": "DEFMACRO SOFTWARE PRIVATE LIMITED",
    "buildingName": "Bldg Name",
    "buildingNumber": "Bldg Number",
    "floorNumber": "update",
    "street": "also",
    "location": "works",
    "stateCode": "29",
    "pincode": "518001",
    "taxpayerType": "fine",
    "status": "ACTIVE",
    "ewbGenerationStatus": "ok",
    "errorDetails": {
        "errors": [
            {
                "error_code": "3001",
                "error_message": "Requested data is not available",
                "error_source": "GOVT"
            }
        ]
    }
}';

      
     dbms_output.put_line('Response  = '||lc_response);

      lc_response_payload := json(lc_base_response_payload);
      ---------lc_response_payload := json(lc_response);

    /*----------------------------------------------------------------------------------------*/
    -- 
    /*----------------------------------------------------------------------------------------*/

    BEGIN

        ---------lc_gstin            := json_ext.get_string(lc_response_payload,'["gstin"]');
        lc_gstin            := p_gstin;
        lc_trade_name       := json_ext.get_string(lc_response_payload,'["tradeName"]');
        lc_legal_name       := json_ext.get_string(lc_response_payload,'["legalName"]');
        lc_building_name    := json_ext.get_string(lc_response_payload,'["buildingName"]');
        lc_building_number  := json_ext.get_string(lc_response_payload,'["buildingNumber"]');
        lc_floor_number     := json_ext.get_string(lc_response_payload,'["floorNumber"]');
        lc_street           := json_ext.get_string(lc_response_payload,'["street"]');
        lc_location         := json_ext.get_string(lc_response_payload,'["location"]');
        lc_state_code       := json_ext.get_string(lc_response_payload,'["stateCode"]');
        lc_pin_code         := json_ext.get_string(lc_response_payload,'["pincode"]');
        lc_taxpayer_type    := json_ext.get_string(lc_response_payload,'["taxpayerType"]');
        lc_gstin_status     := json_ext.get_string(lc_response_payload,'["status"]');
        lc_ewb_generation_status  := json_ext.get_string(lc_response_payload,'["ewbGenerationStatus"]');
        begin
        lc_error_message    := json_ext.get_string(lc_response_payload,'["errorDetails"].["errors"][0].["error_code"]');
        exception
        when others then
          NULL;
        end;
        --dbms_output.put_line('error message : '||lc_error_message);



         -------------------------------------------------------------------------
         -- Error Response Handler 
         -------------------------------------------------------------------------
             BEGIN
               FOR i in 1 .. 3
               LOOP
                 --dbms_output.put_line(i);
                 BEGIN
                   IF json_ext.get_string(lc_response_payload,'errorDetails.errors['||i||'].error_message') IS NOT NULL
                   THEN
                     lc_error_details := SUBSTR(lc_error_details||'--'||json_ext.get_string(lc_response_payload,'errorDetails.errors['||i||'].error_message'),1,490);
                     lc_success       := 'N';
                     --dbms_output.put_line('iiiiii-'||lc_error_details);
                   END IF;
                 EXCEPTION
                 WHEN OTHERS THEN
                   NULL;
                 END;
               END LOOP;
             EXCEPTION
             WHEN OTHERS THEN
               null;
               --lc_error_details := NULL;
             END;
               
         -------------------------------------------------------------------------*/
         
       IF NVL(lc_success,'X') = 'N'     OR
          lc_gstin_status LIKE 'SUS%'   OR  --SUSPENDED
          lc_gstin_status LIKE 'CAN%'       --'CANCELLED'
       THEN
         lc_success         := 'N';
         lc_statusmessage   := lc_error_details; 
         IF lc_statusmessage IS NULL
         THEN
           lc_statusmessage := 'The Entered GSTIN : '||p_gstin||' is in '||lc_gstin_status||' state.';
         END IF;
         lc_status          := 'GSTIN_VALIDATION_FAILED';
         lc_statusmessage   := 'GSTIN Validation Failed due to below reason(s):'||CHR(10)||lc_statusmessage;
       END IF;       

       IF NVL(lc_success,'X') = 'Y'
       THEN
         lc_success         := 'Y'; 
         lc_status          := 'GSTIN_VALIDATION_OK';
         lc_statusmessage   := 'Entered GSTIN: '||p_gstin||' is Valid and Active';
       END IF;       

     EXCEPTION
     WHEN OTHERS THEN
       NULL;
    END;           
  END;


dbms_output.put_line('Validation Status'||CHR(10)||RPAD('=',20,'=')||CHR(10)||lc_status||CHR(10));
dbms_output.put_line('Validation Message'||CHR(10)||RPAD('=',20,'=')||CHR(10)||lc_statusmessage);

  BEGIN
    SELECT 'Y',
           header_id
      INTO lc_gstin_exists_flag,
           ln_header_id
    FROM xxstr_gstin_status
    WHERE
      gstin = p_gstin  AND
      rownum < 2;
  EXCEPTION
  WHEN OTHERS THEN
    lc_gstin_exists_flag := 'N';
  END;
  
  IF lc_gstin_exists_flag = 'N'
  THEN
    INSERT INTO xxstr_gstin_status
    (
      header_id,
      gstin,
      tradeName,
      legalName,
      buildingName,
      buildingNumber,
      floorNumber,
      street,
      location,
      stateCode,
      pincode,
      taxpayerType,
      gstin_status,
      ewbGenerationStatus,  
      gstin_status_message,
      validation_date,
      party_type,
      party_number, 
      party_name,
      party_site_name,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      status,
      validation_count
    )
    VALUES
    (xxstr_gstin_status_s.NEXTVAL,
      p_gstin, -------lc_gstin,
      lc_trade_name,
      lc_legal_name,
      lc_building_name,
      lc_building_number,
      lc_floor_number,
      lc_street,
      lc_location,
      lc_state_code,
      lc_pin_code,
      lc_taxpayer_type,
      lc_gstin_status,
      lc_ewb_generation_status,
      lc_statusmessage,
      SYSDATE,
      p_party_type,
      p_party_number,
      p_party_name,
      p_party_site_name,
      SYSDATE,
      -1,
      SYSDATE,
      -1,
      lc_status,
      1);
      
  
  END IF; 
 
  IF lc_gstin_exists_flag = 'Y'
  THEN
  BEGIN
      UPDATE xxstr_gstin_status
      SET
        gstin                  = lc_gstin,
        tradeName              = lc_trade_name,
        legalName              = lc_legal_name,
        buildingName           = lc_building_name,
        buildingNumber         = lc_building_number,
        floorNumber            = lc_floor_number,
        street                 = lc_street,
        location               = lc_location,
        stateCode              = lc_state_code,
        pincode                = lc_pin_code,
        taxpayerType           = lc_taxpayer_type,
        gstin_status           = lc_gstin_status,
        ewbGenerationStatus    = lc_ewb_generation_status,
        gstin_status_message   = lc_statusmessage,
        validation_date        = SYSDATE,
        party_type             = p_party_type,
        party_number           = p_party_number,
        party_name             = p_party_name,
        party_site_name        = p_party_site_name,
        last_update_date       =  SYSDATE,
        last_updated_by        = -1,
        status                 = lc_status,
        validation_count       = NVL(validation_count,1) + 1
      WHERE
        header_id = ln_header_id;
      
        EXCEPTION
        WHEN OTHERS THEN
          INSERT INTO GSTIN_TEMP VALUES(3,ln_header_id);
        END;
  END IF;

  COMMIT;
  
  
  x_status        := 'S';
  x_statusmessage := lc_statusmessage;

EXCEPTION
WHEN OTHERS THEN
  x_status        := 'E';
  x_statusmessage := 'GSTIN Verfication Failed:'||SUBSTR(SQLERRM,1,200);

  dbms_output.put_line(SQLERRM);
END;                                   


PROCEDURE validate_gstin_wrapper(p_context         IN   VARCHAR2,
                                 p_gstin           IN   VARCHAR2,
                                 p_org_id          IN   NUMBER,
                                 p_party_type      IN   VARCHAR2,
                                 p_party_number    IN   VARCHAR2,
                                 p_party_name      IN   VARCHAR2,
                                 p_party_site_name IN   VARCHAR2,                                 
                                 x_status          OUT  VARCHAR2,
                                 x_statusmessage   OUT  VARCHAR2)
IS

  lc_status        VARCHAR2(100)   := NULL;
  lc_context       VARCHAR2(100)   := NULL;
  
  x_json_payload   LONG;

BEGIN

  lc_context := p_context;

  IF lc_context = 'GSTIN_VALIDATE'
  THEN
    NULL;                              
  END IF;

   /** gstin_response_wrapper(p_gstin          => p_gstin,
                           p_response       => NULL, --lc_response,
                           p_context        => p_context,
                           x_status         => x_status,
                           x_statusmessage  => x_statusmessage);
   **/
   
  gstin_publish2cleartax(p_gstin          => p_gstin,
                         p_context        => lc_context,
                         p_json_payload   => x_json_payload,
                         p_party_type         => p_party_type, 
                         p_party_number       => p_party_number,
                         p_party_name         => p_party_name,
                         p_party_site_name    => p_party_site_name,
                         x_status             => x_status,
                         x_statusmessage      => x_statusmessage);

EXCEPTION
WHEN OTHERS THEN
  NULL;
END;


PROCEDURE get_status_wrapper (p_gstin           IN   VARCHAR2,
                              p_org_id          IN   NUMBER,
                                p_party_type      IN   VARCHAR2,
                              p_party_number    IN   VARCHAR2,
                              p_party_name      IN   VARCHAR2,
                              p_party_site_name IN   VARCHAR2)
IS
   lv_context        VARCHAR2 (50)  := 'GSTIN_VALIDATE';
   lv_gstin          VARCHAR2 (50)  := NULL; --'29AABCM9516H1Z8';
   lv_org_id         NUMBER         := NULL; --82;
   lv_status         VARCHAR2 (50)  := NULL;
   lv_stausmessage   VARCHAR2 (500) := NULL;
BEGIN
   BEGIN
   lv_gstin := p_gstin;
   lv_org_id:= p_org_id;
   
   
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
      lv_status := lv_status ; -- lv_status || ' XX';
   EXCEPTION
   WHEN OTHERS THEN
      lv_status := 'E';
      DBMS_OUTPUT.put_line (' exception x_status          :  ' || lv_status);
      DBMS_OUTPUT.put_line (' exception x_status message  :  '|| lv_stausmessage);
   END;

   
EXCEPTION
WHEN OTHERS THEN
  NULL;
END;
END xxstr_gst_engine_pkg;
/