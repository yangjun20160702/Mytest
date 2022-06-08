CLASS ZCL_LOG_RECORD DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPE-POOLS ABAP .
    TYPE-POOLS JS .
    CLASS-METHODS ABAP2JSON
      IMPORTING
        !ABAP_DATA         TYPE DATA
        !NAME              TYPE STRING OPTIONAL
        !UPCASE            TYPE XFELD OPTIONAL
        !CAMELCASE         TYPE XFELD OPTIONAL
      RETURNING
        VALUE(JSON_STRING) TYPE STRING
      EXCEPTIONS
        ERROR_IN_DATA_DESCRIPTION .
    METHODS LOG_RECORD
      IMPORTING
        !LOWERCASE TYPE ABAP_BOOL
      EXPORTING
        !E_MSG     TYPE ZIF_IFMSG
      CHANGING
        !I_IMPORT  TYPE ZSZZLOG .

    METHODS ADD_PARAMATER
      IMPORTING
        !NAME  TYPE ABAP_PARMNAME
        !VALUE TYPE ANY
      RAISING
        CX_AI_SYSTEM_FAULT .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA PARAMTAB  TYPE STANDARD TABLE OF  ZSZZLOG_DATA..

ENDCLASS.



CLASS ZCL_LOG_RECORD IMPLEMENTATION.


  METHOD ABAP2JSON.
*/**********************************************/*
*/ This method takes any ABAP data variable and /*
*/ returns a string representing its value in   /*
*/ JSON format.                                 /*
*/ ABAP references are always de-referenced and /*
*/ treated as normal variables.                 /*
*/**********************************************/*

    TYPE-POOLS: ABAP.

    CONSTANTS:
      C_COMMA TYPE C VALUE ',',
      C_COLON TYPE C VALUE ':',
      C_QUOTE TYPE C VALUE '"'.

    DATA:
      DONT_QUOTE      TYPE XFELD,
      JSON_FRAGMENTS  TYPE TABLE OF STRING,
      REC_JSON_STRING TYPE STRING,
      L_TYPE          TYPE C,
      S_TYPE          TYPE C,
      L_COMPS         TYPE I,
      L_LINES         TYPE I,
      L_INDEX         TYPE I,
      L_VALUE         TYPE STRING,
      L_NAME          TYPE STRING,
      L_STRUDESCR     TYPE REF TO CL_ABAP_STRUCTDESCR.

    FIELD-SYMBOLS:
      <ABAP_DATA> TYPE ANY,
      <ITAB>      TYPE ANY TABLE,
      <STRU>      TYPE ANY TABLE,
      <COMP>      TYPE ANY,
      <ABAPCOMP>  TYPE ABAP_COMPDESCR.


    DEFINE GET_SCALAR_VALUE.
      " &1 : assigned var
      " &2 : abap data
      " &3 : abap type
      &1 = &2.
****************************************************
* Adapt some basic ABAP types (pending inclusion of all basic abap types?)
* Feel free to customize this for your needs
      case &3.
*       1. ABAP numeric types
        when 'I'. " Integer
          condense &1.
          if sign( &1 ) < 0.
            shift &1 by 1 places right circular.
          endif.
          dont_quote = 'X'.

        when 'F'. " Float
          condense &1.
          dont_quote = 'X'.

        when 'P'. " Packed number (used in quantities or currency, for example)
          condense &1.
          if sign( &1 ) < 0.
            shift &1 by 1 places right circular.
          endif.
          dont_quote = 'X'.

        when 'X'. " Hexadecimal
          condense &1.
          concatenate '0x' &1 into &1.
*        dont_quote = 'X'.
*        "Quote it, as JSON doesn't support Hex or Octal as native types.

*       2. ABAP char types
        when 'D'. " Date type
          CONCATENATE &1(4) '-' &1+4(2) '-' &1+6(2) INTO &1.

        when 'T'. " Time representation
          CONCATENATE &1(2) ':' &1+2(2) ':' &1+4(2) INTO &1.

        when 'N'. " Numeric text field
*           condense &1.

        when 'C' or 'g'. " Char sequences and Strings
* Put safe chars
          replace all occurrences of '\' in &1 with '\\' .
          replace all occurrences of '"' in &1 with '\"' .
          replace all occurrences of cl_abap_char_utilities=>cr_lf in &1 with '\r\n' .
          replace all occurrences of cl_abap_char_utilities=>newline in &1 with '\n' .
          replace all occurrences of cl_abap_char_utilities=>horizontal_tab in &1 with '\t' .
          replace all occurrences of cl_abap_char_utilities=>backspace in &1 with '\b' .
          replace all occurrences of cl_abap_char_utilities=>form_feed in &1 with '\f' .

        when 'y'.  " XSTRING
* Put the XSTRING in Base64
          &1 = cl_http_utility=>ENCODE_X_BASE64( &2 ).

        when others.
* Don't hesitate to add and modify scalar abap types to suit your taste.

      endcase.
** End of scalar data preparing.

* Enclose value in quotes (or not)
      if dont_quote ne 'X'.
        concatenate c_quote &1 c_quote into &1.
      endif.

      clear dont_quote.

    END-OF-DEFINITION.


***************************************************
*  Prepare field names, JSON does quote names!!   *
*  You must be strict in what you produce.        *
***************************************************
    IF NAME IS NOT INITIAL.
      CONCATENATE C_QUOTE NAME C_QUOTE C_COLON INTO REC_JSON_STRING.
      APPEND REC_JSON_STRING TO JSON_FRAGMENTS.
      CLEAR REC_JSON_STRING.
    ENDIF.

**
* Get ABAP data type
    DESCRIBE FIELD ABAP_DATA TYPE L_TYPE COMPONENTS L_COMPS.

***************************************************
*  Get rid of data references
***************************************************
    IF L_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_DREF.
      ASSIGN ABAP_DATA->* TO <ABAP_DATA>.
      IF SY-SUBRC NE 0.
        APPEND '{}' TO JSON_FRAGMENTS.
        CONCATENATE LINES OF JSON_FRAGMENTS INTO JSON_STRING.
        EXIT.
      ENDIF.
    ELSE.
      ASSIGN ABAP_DATA TO <ABAP_DATA>.
    ENDIF.

* Get ABAP data type again and start
    DESCRIBE FIELD <ABAP_DATA> TYPE L_TYPE COMPONENTS L_COMPS.

***************************************************
*  Tables
***************************************************
    IF L_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_TABLE.
* '[' JSON table opening bracket
      APPEND '[' TO JSON_FRAGMENTS.
      ASSIGN <ABAP_DATA> TO <ITAB>.
      L_LINES = LINES( <ITAB> ).
      LOOP AT <ITAB> ASSIGNING <COMP>.
        ADD 1 TO L_INDEX.
*> Recursive call for each table row:
        REC_JSON_STRING = ABAP2JSON( ABAP_DATA = <COMP> UPCASE = UPCASE CAMELCASE = CAMELCASE ).
        APPEND REC_JSON_STRING TO JSON_FRAGMENTS.
        CLEAR REC_JSON_STRING.
        IF L_INDEX < L_LINES.
          APPEND C_COMMA TO JSON_FRAGMENTS.
        ENDIF.
      ENDLOOP.
      APPEND ']' TO JSON_FRAGMENTS.
* ']' JSON table closing bracket


***************************************************
*  Structures
***************************************************
    ELSE.
      IF L_COMPS IS NOT INITIAL.
* '{' JSON object opening curly brace
        APPEND '{' TO JSON_FRAGMENTS.
        L_STRUDESCR ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( <ABAP_DATA> ).
        LOOP AT L_STRUDESCR->COMPONENTS ASSIGNING <ABAPCOMP>.
          L_INDEX = SY-TABIX .
          ASSIGN COMPONENT <ABAPCOMP>-NAME OF STRUCTURE <ABAP_DATA> TO <COMP>.
          L_NAME = <ABAPCOMP>-NAME.
** ABAP names are usually in caps, set upcase to avoid the conversion to lower case.
          IF UPCASE NE 'X'.
            " translate l_name to lower case.
            L_NAME = TO_LOWER( L_NAME ).
          ENDIF.
          IF CAMELCASE EQ 'X'.
            L_NAME = TO_MIXED( VAL = L_NAME  CASE = 'a' ).
          ENDIF.
          DESCRIBE FIELD <COMP> TYPE S_TYPE.
          IF S_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_TABLE OR S_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_DREF OR
             S_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_STRUCT1 OR S_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_STRUCT2.
*> Recursive call for non-scalars:
            REC_JSON_STRING = ABAP2JSON( ABAP_DATA = <COMP> NAME = L_NAME UPCASE = UPCASE CAMELCASE = CAMELCASE ).
          ELSE.
            IF S_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_OREF OR S_TYPE EQ CL_ABAP_TYPEDESCR=>TYPEKIND_IREF.
              REC_JSON_STRING = '"REF UNSUPPORTED"'.
            ELSE.
              GET_SCALAR_VALUE REC_JSON_STRING <COMP> S_TYPE.
            ENDIF.
            CONCATENATE C_QUOTE L_NAME C_QUOTE C_COLON REC_JSON_STRING INTO REC_JSON_STRING.
          ENDIF.
          APPEND REC_JSON_STRING TO JSON_FRAGMENTS.
          CLEAR REC_JSON_STRING. CLEAR L_NAME.
          IF L_INDEX < L_COMPS.
            APPEND C_COMMA TO JSON_FRAGMENTS.
          ENDIF.
        ENDLOOP.
        APPEND '}' TO JSON_FRAGMENTS.
* '}' JSON object closing curly brace


****************************************************
*                  - Scalars -                     *
****************************************************
      ELSE.
        GET_SCALAR_VALUE L_VALUE <ABAP_DATA> L_TYPE.
        APPEND L_VALUE TO JSON_FRAGMENTS.

      ENDIF.
* End of structure/scalar IF block.
***********************************

    ENDIF.
* End of main IF block.
**********************

* Use a loop in older releases that don't support concatenate lines.
    CONCATENATE LINES OF JSON_FRAGMENTS INTO JSON_STRING.

  ENDMETHOD.


  METHOD ADD_PARAMATER.
    DATA:LS_PARM  TYPE ZSZZLOG_DATA.
    LS_PARM-NAME = NAME.
    GET REFERENCE OF VALUE INTO LS_PARM-VALUE.
    APPEND LS_PARM TO PARAMTAB.
  ENDMETHOD.


  METHOD LOG_RECORD.
* ABAP based JSON serializer for function modules (January 2013).
    TYPE-POOLS: ABAP.

    DATA:LS_LOG_HEAD TYPE ZIF_HEADER,
         O_MSG       TYPE CHAR50,
         LS_IFCFG    TYPE ZIF_IFCFG,
         LS_IFFN     TYPE ZIF_IFFN,
         LT_TLOG     TYPE TABLE OF ZIF_IFLGFG.
    DATA O_STRING TYPE STRING.
    DATA JSON_FRAGMENTS TYPE TABLE OF STRING.
    DATA REC_JSON_STRING TYPE STRING.
    DATA PARAMNAME TYPE STRING.
    DATA L_LINES TYPE I.
    DATA L_INDEX TYPE I.
    DATA UPCASE TYPE XFELD VALUE 'X'.
    FIELD-SYMBOLS <PARM> TYPE ZSZZLOG_DATA.
    FIELD-SYMBOLS <EXCEP> TYPE ABAP_FUNC_EXCPBIND.
    DATA:LS_LOGDAT TYPE ZIF_LOGDAT.
    DATA:LR_LOG TYPE REF TO ZCL_IF_LOG_HANDLER.
*_检查接口是否启用，及配置。
    CALL FUNCTION 'ZIF_CONF_CHECK'
      EXPORTING
        I_IFNUM   = I_IMPORT-ZCONTROL-IFNUM
      IMPORTING
        O_HEADER  = LS_LOG_HEAD
        O_MSG     = O_MSG
        O_IFCFG   = LS_IFCFG
        O_IFFN    = LS_IFFN
      TABLES
        IF_IFLGFG = LT_TLOG.

* 日志数据保存
    IF LS_IFFN-IFFUC <> ''.
      TRY.
          IF I_IMPORT-ZCONTROL-GUID IS INITIAL.
            TRY.
                I_IMPORT-ZCONTROL-GUID = CL_SYSTEM_UUID=>CREATE_UUID_C32_STATIC( ).
              CATCH CX_UUID_ERROR.
            ENDTRY.
          ENDIF.
*_日志记录表
          LS_LOG_HEAD-GUID = I_IMPORT-ZCONTROL-GUID.
          LS_LOG_HEAD-IFOPT = I_IMPORT-ZCONTROL-IFOPT.
          LS_LOG_HEAD-IF_STATU = I_IMPORT-IF_STATU.
          LS_LOG_HEAD-IFMSG = I_IMPORT-IFMSG.
          LS_LOG_HEAD-BUSNO = I_IMPORT-BUSNO.
          MODIFY ZIF_HEADER FROM LS_LOG_HEAD. "提交到日志记录表

          REC_JSON_STRING = '{'.
          APPEND REC_JSON_STRING TO JSON_FRAGMENTS.
          CLEAR REC_JSON_STRING.

          CLEAR L_INDEX.
*          L_LINES = LINES( I_IMPORT-ZDATA ).
          L_LINES = LINES( PARAMTAB ).

          LOOP AT PARAMTAB ASSIGNING <PARM>.
            ADD 1 TO L_INDEX.
            PARAMNAME = <PARM>-NAME.
            IF LOWERCASE EQ ABAP_TRUE.
              TRANSLATE PARAMNAME TO LOWER CASE.
              PARAMNAME = TO_LOWER( PARAMNAME ).
              UPCASE = SPACE.
            ENDIF.
            REC_JSON_STRING = ABAP2JSON( ABAP_DATA = <PARM>-VALUE  NAME = PARAMNAME  UPCASE = UPCASE  ).

            APPEND REC_JSON_STRING TO JSON_FRAGMENTS.
            CLEAR REC_JSON_STRING.
            IF L_INDEX < L_LINES.
              APPEND ',' TO JSON_FRAGMENTS .
            ENDIF .
          ENDLOOP.
          REC_JSON_STRING = '}'.
          APPEND REC_JSON_STRING TO JSON_FRAGMENTS.
          CLEAR REC_JSON_STRING.

          CONCATENATE LINES OF JSON_FRAGMENTS INTO O_STRING.

          LS_LOGDAT-PAYLOD = O_STRING.
          LS_LOGDAT-GUID = I_IMPORT-ZCONTROL-GUID.
          LS_LOGDAT-LOGTYP = 'F'.
          MODIFY ZIF_LOGDAT FROM LS_LOGDAT.
          COMMIT WORK AND WAIT.
          E_MSG = '保存日志成功'.

        CATCH CX_AI_SYSTEM_FAULT INTO DATA(LO_SYS_EXCEPTION2).
      ENDTRY.
    ELSE.
      E_MSG = O_MSG.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
