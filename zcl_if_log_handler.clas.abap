class ZCL_IF_LOG_HANDLER definition
  public
  final
  create public .

public section.
  type-pools ABAP .

  methods CONSTRUCTOR
    importing
      !FUNCTION_NAME type RS38L_FNAM .
  methods ADD_PARAMATER
    importing
      !NAME type ABAP_PARMNAME
      !VALUE type ANY
    raising
      CX_AI_SYSTEM_FAULT .
  methods SAVE_LOG
    importing
      !I_GUID type ZIF_GUID
      !I_FNAM type RS38L_FNAM optional .
  methods SAVE_PAYLOAD
    importing
      value(I_GUID) type ZIF_LOGDAT-GUID
      value(I_LOGTYP) type ZIF_LOGDAT-LOGTYP
      value(I_PAYLOD) type ZIF_LOGDAT-PAYLOD .
protected section.
private section.

 data PARAMTAB type ABAP_FUNC_PARMBIND_TAB .
  data EXCEPTAB type ABAP_FUNC_EXCPBIND_TAB .
  data t_params_p type table of RFC_FINT_P.
ENDCLASS.



CLASS ZCL_IF_LOG_HANDLER IMPLEMENTATION.


  method ADD_PARAMATER.
    FIELD-SYMBOLS <PARM> TYPE ABAP_FUNC_PARMBIND.
  READ TABLE PARAMTAB ASSIGNING <PARM> WITH KEY NAME = NAME.
  IF SY-SUBRC = 0.
    GET REFERENCE OF VALUE INTO <PARM>-VALUE.
  ELSE.

    RAISE EXCEPTION TYPE CX_AI_SYSTEM_FAULT
      EXPORTING
        CODE      = 'E'
        ERRORTEXT = '输入参数不存在'.

  ENDIF.
  endmethod.


  method CONSTRUCTOR.
     REFRESH:PARAMTAB,EXCEPTAB,T_PARAMS_P.
  CALL METHOD ZCL_JSON_HANDLER=>BUILD_PARAMS
    EXPORTING
      FUNCTION_NAME          = FUNCTION_NAME
    IMPORTING
      PARAMTAB               = PARAMTAB
      EXCEPTAB               = EXCEPTAB
      PARAMS                 = T_PARAMS_P
    EXCEPTIONS
      INVALID_FUNCTION       = 1
      UNSUPPORTED_PARAM_TYPE = 2
      OTHERS                 = 3.
  IF SY-SUBRC = 1.
    RAISE EXCEPTION TYPE CX_AI_SYSTEM_FAULT
      EXPORTING
        CODE      = 'E'
        ERRORTEXT = '函数名错误'.
  ELSEIF SY-SUBRC <> 0.
    RAISE EXCEPTION TYPE CX_AI_SYSTEM_FAULT
      EXPORTING
        CODE      = 'E'
        ERRORTEXT = '函数名错误'.

  ENDIF.
  endmethod.


  METHOD save_log.
    DATA:ls_logdat TYPE zif_logdat.
    CALL METHOD zcl_json_handler=>serialize_json
      EXPORTING
        paramtab  = paramtab
        show_impp = 'X'
      IMPORTING
        o_string  = ls_logdat-paylod.

    ls_logdat-guid = i_guid.
    ls_logdat-logtyp = 'F'.
    MODIFY zif_logdat FROM ls_logdat.


*&-------Update by handcxm 20200527------------
*    DATA:lv_funcname TYPE char50.
*
*    IMPORT lv_funcname TO lv_funcname  FROM MEMORY ID 'FUNCNAME'.

*    IF I_FNAM EQ 'ZZPP_AUFNR_DETAIL_TO_MES' OR I_FNAM EQ 'ZZPP_AUFNR_STATE_TO_MES' OR I_FNAM EQ 'ZZPP_AUFNR_CHANGE_TO_MES'.
*      "表示在增强调用日志，则不能COMMIT，防止事务中断
*    ELSE.
    COMMIT WORK AND WAIT.
*    ENDIF.
*&-------Update by handxz 20191227------------
  ENDMETHOD.


  method SAVE_PAYLOAD.
    DATA:LS_ZIF_LOGDAT TYPE ZIF_LOGDAT.
  LS_ZIF_LOGDAT-GUID = I_GUID.
  LS_ZIF_LOGDAT-LOGTYP = I_LOGTYP.
  LS_ZIF_LOGDAT-PAYLOD = I_PAYLOD.
  MODIFY ZIF_LOGDAT FROM LS_ZIF_LOGDAT.
  COMMIT WORK AND WAIT.
  endmethod.
ENDCLASS.
