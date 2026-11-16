CREATE OR REPLACE PACKAGE xxstr_gst_engine_pkg 
AUTHID CURRENT_USER AS
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
 

PROCEDURE gstin_publish2cleartax(p_gstin          IN   VARCHAR2,
                                 p_context        IN   VARCHAR2,
                                 p_json_payload   IN   LONG,
  							     p_party_type      IN   VARCHAR2,
                                 p_party_number    IN   VARCHAR2,
                                 p_party_name      IN   VARCHAR2,
                                 p_party_site_name IN   VARCHAR2,                                 
                                 x_status         OUT  VARCHAR2,
                                 x_statusmessage  OUT  VARCHAR2);

PROCEDURE gstin_response_wrapper(p_gstin          IN   VARCHAR2,
                                 p_response       IN   VARCHAR2,
                                 p_context        IN   VARCHAR2,
  							     p_party_type      IN   VARCHAR2,
                                 p_party_number    IN   VARCHAR2,
                                 p_party_name      IN   VARCHAR2,
                                 p_party_site_name IN   VARCHAR2,
                                 x_status         OUT  VARCHAR2,
                                 x_statusmessage  OUT  VARCHAR2);
                                 
                                    
PROCEDURE validate_gstin_wrapper(p_context         IN   VARCHAR2,
                                 p_gstin           IN   VARCHAR2,
                                 p_org_id          IN   NUMBER,
							     p_party_type      IN   VARCHAR2,
                                 p_party_number    IN   VARCHAR2,
                                 p_party_name      IN   VARCHAR2,
                                 p_party_site_name IN   VARCHAR2,                                 
                                 x_status          OUT  VARCHAR2,
                                 x_statusmessage   OUT  VARCHAR2);



PROCEDURE get_status_wrapper (p_gstin           IN   VARCHAR2,
                              p_org_id          IN   NUMBER,
  							  p_party_type      IN   VARCHAR2,
                              p_party_number    IN   VARCHAR2,
                              p_party_name      IN   VARCHAR2,
                              p_party_site_name IN   VARCHAR2);

END xxstr_gst_engine_pkg;
/