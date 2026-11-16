CREATE OR REPLACE PACKAGE XXSTR_GSTIN_ONE_TIME_VALID
AS
/*################################################################################################
  # Module:     GST-VALIDATION                                                                    #
  #                                                                                               #
  # File name:  xxtsr_gstin_one_time_validation.pks                                               #
  #                                                                                               #
  # Function:   Wrapper Package for Stage Tables                                                  #
  #                                                                                              #
  # Author:     STERCK SYSTEMS                                                                   #
  #                                                                                              #
  # Written:    20-OCT-2021                                                                     #
  #                                                                                              #
  # Modification History                                                                         #
  #----------------------------------------------------------------------------------------------#
  #  Author                      Date            Version      Description                        #
  #----------------------------------------------------------------------------------------------#
  #  STERCK SYSTEMS              20-OCT-2021       1.0          Initial Version                   #
  ################################################################################################*/
PROCEDURE XXSTR_GSTIN_SUPPLIER_VALID
(   
    p_type             IN       VARCHAR2,
    x_status           OUT      VARCHAR2,
    x_statusmessage    OUT      VARCHAR2
);

PROCEDURE XXSTR_GSTIN_CUSTOMER_VALID
(   
    p_type             IN       VARCHAR2,
    x_status           OUT      VARCHAR2,
    x_statusmessage    OUT      VARCHAR2
);


END XXSTR_GSTIN_ONE_TIME_VALID;
/