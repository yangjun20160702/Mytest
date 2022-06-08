*&---------------------------------------------------------------------*
*& Report ZCOR010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*******************************************************************
* 事务代码：ZCO012                                                 *
* 程序名称：ZCOR010                                             *
* 程序目的：产品损益表                                          *
* 使用变式：                                                       *
* 设 计 人：李晓娟                                                   *
* 设计时间：2021-04-20                                            *
* 程序类型: ABAP/4 程序 ，报表                             *
* 输入文件:                                                        *
* 输出文件:                                                        *
* 应用类型: CO                                              *
* 描    述: 产品损益表                         *
*(修改日志)--------------------------------------------------------*
*                                                  *
* 日志号   修改人  修改时间       修改说明              传输号码    *
*  ----    ----    ------         -----------
* 001                                                              *
********************************************************************
REPORT zcor010new.

*----------------------------------------------------------------------*
* 类型池声明
*----------------------------------------------------------------------*
TYPE-POOLS: slis,
            ole2,
            vrm.

*----------------------------------------------------------------------*
* 数据库表声明
*----------------------------------------------------------------------*
TABLES: faglflext,     " 总帐: 总计
        bkpf,          " 会计核算凭证标题
        bseg,          " 会计核算凭证段
        csks,          " 成本中心主数据
        coas,          " 控制的订单主记录(AUFK表所有字段)
        sscrfields.    " 选择屏幕上的字段

*----------------------------------------------------------------------*
* 宏定义
*----------------------------------------------------------------------*
DEFINE fillfiedcat.
  ls_fieldcat-fieldname     = &1.  " ALV 控制: 内部表字段的字段名称
  ls_fieldcat-seltext_l     = &2.  " 长字段标签
  ls_fieldcat-no_zero       = &3.  " 无前导零
*  ls_fieldcat-decimals_out  = &4.
*  ls_fieldcat-round = 2.
  APPEND ls_fieldcat TO gt_fieldcat.
  CLEAR ls_fieldcat.
END-OF-DEFINITION.

*----------------------------------------------------------------------*
* 数据对象声明
*----------------------------------------------------------------------*
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv.      " 字段目录的内表
DATA: ls_fieldcat TYPE slis_fieldcat_alv.       " 字段目录的工作区
DATA: gs_layout TYPE slis_layout_alv.           " ALV布局
DATA: myrepid LIKE sy-repid.                    " 当前程序

DATA: gt_events TYPE slis_t_event,               " 事件的内表
      ls_event  TYPE LINE OF slis_t_event.       " 事件的工作区

DATA : BEGIN OF it_t001 OCCURS 0,
         bukrs LIKE t001-bukrs,      " 公司代码
         butxt LIKE t001-butxt,      " 公司描述
       END OF it_t001.

DATA:  BEGIN OF it_month OCCURS 0,
        year LIKE faglflext-ryear,
        month LIKE faglflext-rpmax,
       END OF it_month.

DATA:  BEGIN OF it_month_qn OCCURS 0,
        year LIKE faglflext-ryear,
        month LIKE faglflext-rpmax,
       END OF it_month_qn.

TYPES: BEGIN OF it_output1,
        item     LIKE ztfi009-zfiitem ,                                " 项目号
        text     LIKE ztfi009-zfitext ,                                " 项目名称
        zfisign  LIKE ztfi009-zfisign ,                                " 贷方标记
        ncs      LIKE faglflext-hslvt,                                  " 年初数
        qms      LIKE faglflext-hslvt,                                  " 年末数
        hsl01    LIKE faglflext-hsl01,                                  " 1月余额
        hsl02    LIKE faglflext-hsl02,                                  " 2月余额
        hsl03    LIKE faglflext-hsl03,                                  " 3月余额
        hsl04    LIKE faglflext-hsl04,                                  " 4月余额
        hsl05    LIKE faglflext-hsl05,                                  " 5月余额
        hsl06    LIKE faglflext-hsl06,                                  " 6月余额
        hsl07    LIKE faglflext-hsl07,                                  " 7月余额
        hsl08    LIKE faglflext-hsl08,                                  " 8月余额
        hsl09    LIKE faglflext-hsl09,                                  " 9月余额
        hsl10    LIKE faglflext-hsl10,                                  " 10月余额
        hsl11    LIKE faglflext-hsl11,                                  " 11月余额
        hsl12    LIKE faglflext-hsl12,                                  " 12月余额
        hsl13    LIKE faglflext-hsl13,                                  " 13月余额
        hsl14    LIKE faglflext-hsl14,                                  " 14月余额
        hsl15    LIKE faglflext-hsl15,                                  " 15月余额
        hsl16    LIKE faglflext-hsl16,                                  " 16月余额
        zhhj     LIKE faglflext-hsl01,                                  " 16月余额
        color(4) TYPE c,                                                " 控制ALV颜色的字段
      END OF  it_output1.

DATA:  BEGIN OF it_sy_jn OCCURS 0,
        item     LIKE ztfi009-zfiitem ,                                " 项目号
        text     LIKE ztfi009-zfitext ,                                " 项目名称
        zfisign  LIKE ztfi009-zfisign ,                                " 贷方标记
        ncs      LIKE faglflext-hslvt,                                  " 年初数
        qms      LIKE faglflext-hslvt,                                  " 年末数
        hsl01    LIKE faglflext-hsl01,                                  " 1月余额
        hsl02    LIKE faglflext-hsl02,                                  " 2月余额
        hsl03    LIKE faglflext-hsl03,                                  " 3月余额
        hsl04    LIKE faglflext-hsl04,                                  " 4月余额
        hsl05    LIKE faglflext-hsl05,                                  " 5月余额
        hsl06    LIKE faglflext-hsl06,                                  " 6月余额
        hsl07    LIKE faglflext-hsl07,                                  " 7月余额
        hsl08    LIKE faglflext-hsl08,                                  " 8月余额
        hsl09    LIKE faglflext-hsl09,                                  " 9月余额
        hsl10    LIKE faglflext-hsl10,                                  " 10月余额
        hsl11    LIKE faglflext-hsl11,                                  " 11月余额
        hsl12    LIKE faglflext-hsl12,                                  " 12月余额
        hsl13    LIKE faglflext-hsl13,                                  " 13月余额
        hsl14    LIKE faglflext-hsl14,                                  " 14月余额
        hsl15    LIKE faglflext-hsl15,                                  " 15月余额
        hsl16    LIKE faglflext-hsl16,                                  " 16月余额
        zhhj     LIKE faglflext-hsl01,                                  " 16月余额
      END OF  it_sy_jn.

DATA: it_sy_qn LIKE it_sy_jn OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF it_out,
        werks         LIKE vbrp-werks,
        matnr         LIKE vbrp-matnr,
        prctr         LIKE vbrp-prctr,
        ktext         LIKE cepct-ktext,
        matkl         LIKE mara-matkl,
        wgbez         LIKE v023-wgbez,
        bklas         LIKE mbew-bklas,
        bkbez         LIKE t025t-bkbez,
        arktx         LIKE vbrp-arktx,
        fkimg         LIKE vbrp-fkimg,  "  销售数量
        netwr         LIKE vbrp-netwr, "	主营业务收入
        stprs_t       LIKE vbrp-netwr, "主营业务成本-标准
        pvprs_t       TYPE vbrp-netwr, "p decimals 5, "主营业务成本-实际
        netwr_a(10)   TYPE p DECIMALS 8, "vbrp-netwr, "平均单位售价
        stprs(10)     TYPE p DECIMALS 8,
        pvprs(10)     TYPE p DECIMALS 8,
        kunrg         LIKE vbrk-kunrg,
        name(70)      TYPE c,
        ktokd         LIKE kna1-ktokd, "客户帐户组
        netwr_stprs_t TYPE vbrp-netwr, "p decimals 5,"标准毛利
        netwr_pvprs_t TYPE vbrp-netwr, "p decimals 5,"实际毛利
        cyfpje1       TYPE p DECIMALS 4,                              "差异分配金额1
        cyfpje2       TYPE p DECIMALS 4,                              "差异分配金额2
        sjcb2         LIKE vbrp-netwr,                                "实际成本2
        dwcbjg2       LIKE vbrp-netwr,                                "单位成本价格2
        sjml2         LIKE vbrp-netwr,                                "实际毛利2
        aubel         LIKE vbrp-aubel,
        aupos         LIKE vbrp-aupos,
        ps_psp_pnr    LIKE vbrp-ps_psp_pnr,
        post1         LIKE prps-post1,
        fkart         LIKE vbrk-fkart,
        vtext         LIKE tvfkt-vtext,
        js_vbeln      TYPE string,
        zzcpym        TYPE ztmm001-zzcpym,
        vbeln         LIKE vbrp-vbeln,
        posnr         LIKE vbrp-posnr,
        vbund         TYPE kna1-vbund,
        netwr_1       TYPE vbrp-netwr, "原币净价
        waerk         TYPE vbrk-waerk, "币种
        tline         TYPE tline-tdline,
        kst001_s      LIKE ckmlprkeph-kst001, "实际单位成本
        kst003_s      LIKE ckmlprkeph-kst003,
        kst005_s      LIKE ckmlprkeph-kst005,
        kst007_s      LIKE ckmlprkeph-kst007,
        kst009_s      LIKE ckmlprkeph-kst009,
        kst011_s      LIKE ckmlprkeph-kst011,
        kst077_s      LIKE ckmlprkeph-kst077,
        kst085_s      LIKE ckmlprkeph-kst085,
        kst001_st     LIKE ckmlprkeph-kst001, "实际成本合计
        kst003_st     LIKE ckmlprkeph-kst003,
        kst005_st     LIKE ckmlprkeph-kst005,
        kst007_st     LIKE ckmlprkeph-kst007,
        kst009_st     LIKE ckmlprkeph-kst009,
        kst011_st     LIKE ckmlprkeph-kst011,
        kst077_st     LIKE ckmlprkeph-kst077,
        kst085_st     LIKE ckmlprkeph-kst085,
        land1         TYPE kna1-land1,
        landx         TYPE t005t-landx,
        regio         TYPE kna1-regio,
        bezei         TYPE t005u-bezei,
        vgbel         LIKE vbrp-vgbel,
        vgpos         LIKE vbrp-vgpos,
        belnr         LIKE bkpf-belnr,
        auart         LIKE vbak-auart,
        ddlxms        TYPE tvakt-bezei,
        lgort         LIKE vbrp-lgort,
        lgobe         LIKE t001l-lgobe,
        ddms          TYPE string, "订单文本
        zsjzz         TYPE vbrp-netwr, "实际成本总额-总账
        zsjze         TYPE vbrp-netwr, "实际成本总额-ML
        zfyhj         TYPE vbrp-netwr,
        zdwcb_zz      TYPE vbrp-netwr, "单位销售成本-总账
        zdwcb         TYPE vbrp-netwr, "单位销售成本
        zdwsj         TYPE vbrp-netwr, "单位实际-制造费用
        zyyzz         TYPE vbrp-netwr, "营业收入-总账
        shkzg         TYPE vbrp-shkzg,
        prsdt         TYPE vbrp-prsdt,
      END   OF it_out.

DATA: BEGIN OF it_sr_jn OCCURS 0.
      INCLUDE TYPE it_out.
DATA: END OF it_sr_jn.

DATA: BEGIN OF it_srjn OCCURS 0,
      year  LIKE faglflext-ryear,
      month LIKE faglflext-rpmax,
      netwr LIKE vbrp-netwr, "营业收入
      kst001_st     LIKE ckmlprkeph-kst001, "实际-直接材料合计
      kst003_st     LIKE ckmlprkeph-kst003, "实际-直接人工合计
      kst005_st     LIKE ckmlprkeph-kst005, "实际-电费合计
      kst007_st     LIKE ckmlprkeph-kst007, "实际-动力费其他合计
      kst011_st     LIKE ckmlprkeph-kst011, "实际-制造费用合计
      kst009_st     LIKE ckmlprkeph-kst009, "实际-折旧费合计
      kst077_st     LIKE ckmlprkeph-kst077, "实际-间接人工
      kst085_st     LIKE ckmlprkeph-kst085, "实际-直接材料-废品合计
      kst_yf        LIKE ckmlprkeph-kst009, "运费66010900的余额
*      kst_jjrg      LIKE ckmlprkeph-kst009, "间接人工所取科目为51010000~51010700，以及51013600的余额相加
*      kst_zzfy      LIKE ckmlprkeph-kst009, "总的制造费用为5101开头的所有制造费用的余额
      END OF it_srjn.

DATA: it_srqn LIKE it_srjn OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF it_sr_qn OCCURS 0.
      INCLUDE TYPE it_out.
DATA: END OF it_sr_qn.

DATA go_data TYPE REF TO data.

FIELD-SYMBOLS: <git_outtab> TYPE ANY TABLE.
FIELD-SYMBOLS: <gis_outtab> TYPE it_output1.
FIELD-SYMBOLS: <it_outtab> TYPE ANY TABLE.
FIELD-SYMBOLS: <is_outtab> TYPE it_out.

DATA: BEGIN OF itab OCCURS 0,
        item     LIKE ztfi009-zfiitem ,                                " 项目号
        text     LIKE ztfi009-zfitext ,                                " 项目名称
"今年
        hsl01    LIKE faglflext-hsl01,                                  " 1月余额
        hsl02    LIKE faglflext-hsl02,                                  " 2月余额
        hsl03    LIKE faglflext-hsl03,                                  " 3月余额
        hsl04    LIKE faglflext-hsl04,                                  " 4月余额
        hsl05    LIKE faglflext-hsl05,                                  " 5月余额
        hsl06    LIKE faglflext-hsl06,                                  " 6月余额
        hsl07    LIKE faglflext-hsl07,                                  " 7月余额
        hsl08    LIKE faglflext-hsl08,                                  " 8月余额
        hsl09    LIKE faglflext-hsl09,                                  " 9月余额
        hsl10    LIKE faglflext-hsl10,                                  " 10月余额
        hsl11    LIKE faglflext-hsl11,                                  " 11月余额
        hsl12    LIKE faglflext-hsl12,                                  " 12月余额
        hsl13    LIKE faglflext-hsl13,                                  " 13月余额
        hsl14    LIKE faglflext-hsl14,                                  " 14月余额
        hsl15    LIKE faglflext-hsl15,                                  " 15月余额
        hsl16    LIKE faglflext-hsl16,                                  " 16月余额
        jnhj     LIKE faglflext-hsl01,                                  " 余额合计
"去年
        qnhsl01    LIKE faglflext-hsl01,                                  " 1月余额
        qnhsl02    LIKE faglflext-hsl02,                                  " 2月余额
        qnhsl03    LIKE faglflext-hsl03,                                  " 3月余额
        qnhsl04    LIKE faglflext-hsl04,                                  " 4月余额
        qnhsl05    LIKE faglflext-hsl05,                                  " 5月余额
        qnhsl06    LIKE faglflext-hsl06,                                  " 6月余额
        qnhsl07    LIKE faglflext-hsl07,                                  " 7月余额
        qnhsl08    LIKE faglflext-hsl08,                                  " 8月余额
        qnhsl09    LIKE faglflext-hsl09,                                  " 9月余额
        qnhsl10    LIKE faglflext-hsl10,                                  " 10月余额
        qnhsl11    LIKE faglflext-hsl11,                                  " 11月余额
        qnhsl12    LIKE faglflext-hsl12,                                  " 12月余额
        qnhsl13    LIKE faglflext-hsl13,                                  " 13月余额
        qnhsl14    LIKE faglflext-hsl14,                                  " 14月余额
        qnhsl15    LIKE faglflext-hsl15,                                  " 15月余额
        qnhsl16    LIKE faglflext-hsl16,                                  " 16月余额
        qnhj     LIKE faglflext-hsl01,                                  " 余额合计
      END OF itab.

DATA: itab2 LIKE itab OCCURS 0 WITH HEADER LINE.

DATA :BEGIN OF it_itab OCCURS 0 ,
        ryear  LIKE faglflext-ryear,                                    " 年度
        drcrk  LIKE faglflext-drcrk,                                    " 借方/贷方标识
        rpmax  LIKE faglflext-rpmax,                                    " 期间
        rtcur  LIKE faglflext-rtcur,                                    " 货币码
        racct  LIKE faglflext-racct,                                    " 科目号
        rbukrs LIKE faglflext-rbukrs,                                   " 公司
        rfarea LIKE faglflext-rfarea,                                   " 功能范围
        hslvt  LIKE faglflext-hslvt,                                    " 年初
        hsl01  LIKE faglflext-hsl01,                                    " 1月余额
        hsl02  LIKE faglflext-hsl02,                                    " 2月余额
        hsl03  LIKE faglflext-hsl03,                                    " 3月余额
        hsl04  LIKE faglflext-hsl04,                                    " 4月余额
        hsl05  LIKE faglflext-hsl05,                                    " 5月余额
        hsl06  LIKE faglflext-hsl06,                                    " 6月余额
        hsl07  LIKE faglflext-hsl07,                                    " 7月余额
        hsl08  LIKE faglflext-hsl08,                                    " 8月余额
        hsl09  LIKE faglflext-hsl09,                                    " 9月余额
        hsl10  LIKE faglflext-hsl10,                                    " 10月余额
        hsl11  LIKE faglflext-hsl11,                                    " 11月余额
        hsl12  LIKE faglflext-hsl12,                                    " 12月余额
        hsl13  LIKE faglflext-hsl13,                                    " 13月余额
        hsl14  LIKE faglflext-hsl14,                                    " 14月余额
        hsl15  LIKE faglflext-hsl15,                                    " 15月余额
        hsl16  LIKE faglflext-hsl16,                                    " 16月余额
        zqmye  LIKE faglflext-hsl16,                                    " 16月余额
      END OF it_itab.

DATA: it_itab_qn LIKE it_itab OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF itab3_jn OCCURS 0,
       year  LIKE faglflext-ryear,
       month LIKE faglflext-rpmax,
       kst_yf        LIKE ckmlprkeph-kst009, "运费66010900的余额
*       kst_jjrg      LIKE ckmlprkeph-kst009, "间接人工所取科目为51010000~51010700，以及51013600的余额相加
*       kst_zzfy      LIKE ckmlprkeph-kst009, "总的制造费用为5101开头的所有制造费用的余额
      END OF itab3_jn.

DATA: itab3_qn LIKE itab3_jn OCCURS 0 WITH HEADER LINE.
*&---------------------------------------------------------------------*
*& Selection Screen/选择屏幕
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl01 WITH FRAME TITLE TEXT-000.
  PARAMETERS : p_ver LIKE ztfi009-zversion.                                         " 报表版本
  SELECT-OPTIONS s_bukrs FOR faglflext-rbukrs OBLIGATORY DEFAULT '1000' NO-EXTENSION NO INTERVALS.            " 公司代码
  PARAMETERS:    p_year  LIKE faglflext-ryear OBLIGATORY DEFAULT sy-datum(4).        " 会计年度

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN: COMMENT 1(30) zmtxt FOR FIELD p_month,
    POSITION 33.
    PARAMETERS: p_month LIKE faglflext-rpmax OBLIGATORY.                            " 会计期间
    SELECTION-SCREEN: COMMENT 52(3) zmtxt2 FOR FIELD p_month,
    POSITION 58.
    PARAMETERS: p_month1 LIKE faglflext-rpmax OBLIGATORY.                           " 会计期间
  SELECTION-SCREEN END OF LINE.
  PARAMETERS: p_ldgrp LIKE bkpf-ldgrp OBLIGATORY DEFAULT '0L'.

  PARAMETERS: p_wy AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK bl01.
*&---------------------------------------------------------------------*
*& INITIALIZATION/选择屏幕前初始化
*&---------------------------------------------------------------------*
INITIALIZATION.
  zmtxt = '会计期间'.
  zmtxt2 = '到'.

  p_month  = sy-datum+4(2).
  p_month1 = sy-datum+4(2).

*&---------------------------------------------------------------------*
*& at selection-screen/选择屏幕开始
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  DATA lv_msg TYPE string.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD s_bukrs-low
           ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    CONCATENATE '您没有公司代码'  s_bukrs-low  '的权限！' INTO lv_msg .
    MESSAGE lv_msg TYPE 'E'.
  ENDIF.

AT SELECTION-SCREEN ON s_bukrs.
*&---公司描述
  SELECT bukrs
         butxt
    FROM t001
    INTO CORRESPONDING FIELDS OF TABLE it_t001
    WHERE bukrs IN s_bukrs.

*用于给报表版本添加搜索帮助
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ver .

  PERFORM frm_f4_version.

*&---------------------------------------------------------------------*
*& Start-of-selection/开始选择屏幕
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_ver IS INITIAL.
    MESSAGE '报表版本为必输！' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  DATA:p_mess TYPE string.
  IF ( p_month NOT BETWEEN '01' AND '16') OR ( p_month1 NOT BETWEEN '01' AND '16').
    IF p_month  NOT BETWEEN '01' AND '16'.
      CONCATENATE '输入的期间' p_month '无效' INTO p_mess.
    ELSEIF p_month1 NOT BETWEEN '01' AND '16'.
      CONCATENATE '输入的期间' p_month1 '无效' INTO p_mess.
    ENDIF.
    MESSAGE p_mess TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*&---获取报表数据ZFIR002损益表
  DATA: s_year LIKE faglflext-ryear.
  s_year = p_year - 1.
  PERFORM frm_get_data."选择屏幕会计年度/期间
  PERFORM frm_get_data_qn."选择屏幕上一会计年度/期间

*&---获取报表数据ZCO019销售收入成本表
  DATA:  s_month LIKE faglflext-rpmax,
         lv_month LIKE faglflext-rpmax.

  CLEAR: it_month, it_month[],
         it_month_qn, it_month_qn[].

  it_month-year = p_year.
  it_month-month = p_month.
  APPEND it_month.
  CLEAR it_month.

  s_month = p_month1 - p_month.
  lv_month = p_month.
  DO s_month TIMES.
  lv_month = lv_month + 1.
  it_month-year = p_year.
  it_month-month = lv_month.
  APPEND it_month.
  CLEAR it_month.
  ENDDO.

  it_month_qn-year = s_year.
  it_month_qn-month = p_month.
  APPEND it_month_qn.
  CLEAR it_month_qn.
  lv_month = p_month.
  DO s_month TIMES.
  lv_month = lv_month + 1.
  it_month_qn-year = s_year.
  it_month_qn-month = lv_month.
  APPEND it_month_qn.
  CLEAR it_month_qn.
  ENDDO.

  CLEAR: it_srjn, it_srjn[].
  LOOP AT it_month.
    PERFORM frm_get_data2 USING it_month-year it_month-month."选择屏幕会计年度/期间
    IF go_data IS NOT INITIAL .
     LOOP AT <it_outtab> ASSIGNING <is_outtab>.
      MOVE-CORRESPONDING <is_outtab> TO it_sr_jn.
      APPEND it_sr_jn.
      CLEAR it_sr_jn.
     ENDLOOP.
     LOOP AT it_sr_jn.
"保定分1100公司只统计物料是“动力电池包总成”的“营业收入”数据
       IF s_bukrs-low = '1100'.
         IF it_sr_jn-matkl = '101'.
           it_srjn-year = it_month-year.
           it_srjn-month = it_month-month.
           MOVE-CORRESPONDING it_sr_jn TO it_srjn.
           COLLECT it_srjn.
           CLEAR it_srjn.
         ENDIF.
       ELSE.
          IF it_sr_jn-matkl+0(1) = '2' OR it_sr_jn-matkl+0(1) = '1'.
            IF s_bukrs-low = '1000'.
              IF it_sr_jn-matkl = '103'."金坛103物料组不归尤总管
              ELSE.
               it_srjn-year = it_month-year.
               it_srjn-month = it_month-month.
               MOVE-CORRESPONDING it_sr_jn TO it_srjn.
               COLLECT it_srjn.
               CLEAR it_srjn.
              ENDIF.
            ELSE.
               it_srjn-year = it_month-year.
               it_srjn-month = it_month-month.
               MOVE-CORRESPONDING it_sr_jn TO it_srjn.
               COLLECT it_srjn.
               CLEAR it_srjn.
            ENDIF.
          ENDIF.

       ENDIF.
     ENDLOOP.
    ENDIF.
  ENDLOOP.
  CLEAR: it_srqn, it_srqn[].
  LOOP AT it_month_qn.
    PERFORM frm_get_data2 USING it_month_qn-year it_month_qn-month."选择屏幕上一会计年度/期间
    IF go_data IS NOT INITIAL .
     LOOP AT <it_outtab> ASSIGNING <is_outtab>.
      MOVE-CORRESPONDING <is_outtab> TO it_sr_qn.
      APPEND it_sr_qn.
      CLEAR it_sr_qn.
     ENDLOOP.
     LOOP AT it_sr_qn.
"保定分1100公司只统计物料是“动力电池包总成”的“营业收入”数据
       IF s_bukrs-low = '1100'.
         IF it_sr_qn-matkl = '101'.
          it_srqn-year = it_month_qn-year.
          it_srqn-month = it_month_qn-month.
          MOVE-CORRESPONDING it_sr_qn TO it_srqn.
          COLLECT it_srqn.
          CLEAR it_srqn.
         ENDIF.
       ELSE.
          IF it_sr_qn-matkl+0(1) = '1' OR it_sr_qn-matkl+0(1) = '2'.
           it_srqn-year = it_month_qn-year.
           it_srqn-month = it_month_qn-month.
           MOVE-CORRESPONDING it_sr_qn TO it_srqn.
           COLLECT it_srqn.
           CLEAR it_srqn.
          ENDIF.
       ENDIF.
     ENDLOOP.
    ENDIF.
  ENDLOOP.

*&---特别处理：获取运费\间接人工\制造费用的总账余额
  PERFORM frm_get_data3.

*&---处理报表数据
  PERFORM data_process.
  PERFORM data_process_qn.

*&---展示ALV
  PERFORM frm_display_alv.
*&---------------------------------------------------------------------*
*& Form FRM_F4_VERSION
*&---------------------------------------------------------------------*
*& 版本搜索帮助
*&---------------------------------------------------------------------*
FORM frm_f4_version .
  TYPES: BEGIN OF ty_version,
           zversion   TYPE ztfi009-zversion,
           zversion_t TYPE ztfi009-zversion_t,
         END OF ty_version.

  DATA:lt_rt_tab TYPE STANDARD TABLE OF ddshretval,
       lt_f4tab  TYPE STANDARD TABLE OF ty_version.


* 报表版本 报表版本名称
  SELECT zversion,zfiitem, zfisuit,zversion_t INTO TABLE @DATA(lt_version)
    FROM ztfi009.
  SORT lt_version BY zversion zfiitem zfisuit.
  DELETE ADJACENT DUPLICATES FROM lt_version COMPARING zversion.
  MOVE-CORRESPONDING lt_version TO lt_f4tab.

* 添加搜索帮助
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = 'ZVERSION'    "字段的名字
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = 'P_VER'      "选择屏幕的元素
      value_org        = 'S'
      callback_program = sy-repid
    TABLES
      value_tab        = lt_f4tab
      return_tab       = lt_rt_tab
    EXCEPTIONS
      parameter_error  = 1
      no_values_found  = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data .

  CLEAR: it_sy_jn, it_sy_jn[].

   cl_salv_bs_runtime_info=>set(
      display  = abap_false
      metadata = abap_false
      data     = abap_true  ).

  SUBMIT zfir002
  WITH p_ver = p_ver
  WITH s_bukrs IN s_bukrs
  WITH p_year = p_year
  WITH p_month = p_month
  WITH p_month1 = p_month1
  WITH p_ldgrp = p_ldgrp
  EXPORTING LIST TO MEMORY AND RETURN.

  TRY.
"取得运行数据
  cl_salv_bs_runtime_info=>get_data_ref(
  IMPORTING
    r_data = go_data
    ).
*   数据赋值
  ASSIGN go_data->* TO <git_outtab>.  "结构必须和被调程序的ALV 结构一样
  CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.

  CALL METHOD cl_salv_bs_runtime_info=>clear_all.
  IF go_data IS NOT INITIAL .
    LOOP AT <git_outtab> ASSIGNING <gis_outtab>.
      MOVE-CORRESPONDING <gis_outtab> TO it_sy_jn.
      APPEND it_sy_jn.
      CLEAR it_sy_jn.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_get_data_qn
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data_qn .

  CLEAR: it_sy_qn, it_sy_qn[].

   cl_salv_bs_runtime_info=>set(
      display  = abap_false
      metadata = abap_false
      data     = abap_true  ).

  SUBMIT zfir002
  WITH p_ver = p_ver
  WITH s_bukrs IN s_bukrs
  WITH p_year = s_year
  WITH p_month = p_month
  WITH p_month1 = p_month1
  WITH p_ldgrp = p_ldgrp
  EXPORTING LIST TO MEMORY AND RETURN.

  TRY.
"取得运行数据
  cl_salv_bs_runtime_info=>get_data_ref(
  IMPORTING
    r_data = go_data
    ).
*   数据赋值
  ASSIGN go_data->* TO <git_outtab>.  "结构必须和被调程序的ALV 结构一样
  CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.

  CALL METHOD cl_salv_bs_runtime_info=>clear_all.
  IF go_data IS NOT INITIAL .
    LOOP AT <git_outtab> ASSIGNING <gis_outtab>.
      MOVE-CORRESPONDING <gis_outtab> TO it_sy_qn.
      APPEND it_sy_qn.
      CLEAR it_sy_qn.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_get_data2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data2 USING ss_year ss_month .

   CLEAR: it_sr_jn, it_sr_jn[],
          it_sr_qn, it_sr_qn[].

   cl_salv_bs_runtime_info=>set(
      display  = abap_false
      metadata = abap_false
      data     = abap_true  ).

  SUBMIT zcor005
  WITH p_bukrs = s_bukrs-low
  WITH p_gjahr = ss_year
  WITH p_poper = ss_month
  WITH p_curtp = '10'
  WITH r_detail =  'X'
  EXPORTING LIST TO MEMORY AND RETURN.

  TRY.
"取得运行数据
  cl_salv_bs_runtime_info=>get_data_ref(
  IMPORTING
    r_data = go_data
    ).
*   数据赋值
  ASSIGN go_data->* TO <it_outtab>.  "结构必须和被调程序的ALV 结构一样
  CATCH cx_salv_bs_sc_runtime_info.
  ENDTRY.

  CALL METHOD cl_salv_bs_runtime_info=>clear_all.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form frm_get_data2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM frm_get_data3.

FIELD-SYMBOLS: <fs> TYPE any.                 " 字段符号1
DATA: lv_text(19)  TYPE c.   " 文本1

  CLEAR: it_itab, it_itab[],
         it_itab_qn, it_itab_qn[],
         itab3_jn, itab3_jn[],
         itab3_qn, itab3_qn[].
*&---获取
"选择屏幕年度
  SELECT ryear drcrk rpmax rtcur racct rbukrs rfarea
         hslvt hsl01 hsl02 hsl03 hsl04
         hsl05 hsl06 hsl07 hsl08 hsl09
         hsl10 hsl11 hsl12 hsl13 hsl14
         hsl15 hsl16
    INTO CORRESPONDING FIELDS OF TABLE it_itab
    FROM faglflext
   WHERE ryear  = p_year
     AND rldnr = p_ldgrp
     AND rrcty  = '0'
     AND rbukrs IN s_bukrs
*     AND ( racct = '0066010900' OR racct LIKE '005101%' ).
    AND racct = '0066010900' .

"选择屏幕上一年度
   SELECT ryear drcrk rpmax rtcur racct rbukrs rfarea
         hslvt hsl01 hsl02 hsl03 hsl04
         hsl05 hsl06 hsl07 hsl08 hsl09
         hsl10 hsl11 hsl12 hsl13 hsl14
         hsl15 hsl16
    INTO CORRESPONDING FIELDS OF TABLE it_itab_qn
    FROM faglflext
   WHERE ryear  = s_year
     AND rldnr = p_ldgrp
     AND rrcty  = '0'
     AND rbukrs IN s_bukrs
*     AND ( racct = '0066010900' OR racct LIKE '005101%' ).
     AND racct = '0066010900' .


    LOOP AT it_itab.
     LOOP AT it_month.
      CLEAR lv_text.
      CONCATENATE 'IT_ITAB-HSL' it_month-month+1(2) INTO lv_text.
      ASSIGN (lv_text) TO <fs>.
*      IF it_itab-racct = '0066010900'.
        itab3_jn-kst_yf = <fs>. "运费66010900的余额
*      ELSEIF it_itab-racct = '0051013600' OR it_itab-racct = '0051012700' OR ( it_itab-racct >= '0051010000' AND it_itab-racct <= '0051010800' ).
*        itab3_jn-kst_jjrg = <fs>. "间接人工所取科目为51010000~51010800，以及51013600的余额相加
*      ENDIF.
*
*      IF it_itab-racct+0(6) = '005101'.
*        IF it_itab-racct <> '0051011000'.
*        itab3_jn-kst_zzfy = <fs> ."总的制造费用为5101开头的所有制造费用的余额
*        ENDIF.
*      ENDIF.

      itab3_jn-year = it_month-year.
      itab3_jn-month = it_month-month.
      COLLECT itab3_jn.
      CLEAR itab3_jn.
     ENDLOOP.
    ENDLOOP.
    LOOP AT itab3_jn.
      MOVE-CORRESPONDING itab3_jn TO it_srjn.
      COLLECT it_srjn.
      CLEAR it_srjn.
    ENDLOOP.

    LOOP AT it_itab_qn.
     LOOP AT it_month_qn.
      CLEAR lv_text.
      CONCATENATE 'IT_ITAB_QN-HSL' it_month_qn-month+1(2) INTO lv_text.
      ASSIGN (lv_text) TO <fs>.
*      IF it_itab_qn-racct = '0066010900'.
        itab3_qn-kst_yf = <fs>. "运费66010900的余额
*      ELSEIF it_itab_qn-racct = '0051013600' OR it_itab_qn-racct = '0051012700' OR ( it_itab_qn-racct >= '0051010000' AND it_itab_qn-racct <= '0051010800' ).
*        itab3_qn-kst_jjrg = <fs>. "间接人工所取科目为51010000~51010800，以及51013600的余额相加
*      ENDIF.
*
*      IF it_itab_qn-racct+0(6) = '005101'.
*        IF it_itab_qn-racct <> '0051011000'.
*        itab3_qn-kst_zzfy = <fs> ."总的制造费用为5101开头的所有制造费用的余额要扣除折旧费
*        ENDIF.
*      ENDIF.

      itab3_qn-year = it_month_qn-year.
      itab3_qn-month = it_month_qn-month.
      COLLECT itab3_qn.
      CLEAR itab3_qn.
     ENDLOOP.
    ENDLOOP.
    LOOP AT itab3_qn.
      MOVE-CORRESPONDING itab3_qn TO it_srqn.
      COLLECT it_srqn.
      CLEAR it_srqn.
    ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_process
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM data_process.
FIELD-SYMBOLS: <fs> TYPE any.                 " 字段符号1
DATA: lv_text(19)  TYPE c.   " 文本1
FIELD-SYMBOLS: <fs2> TYPE any.                 " 字段符号1
DATA: lv_text2(19)  TYPE c.   " 文本1
DATA:   v_hsl01  LIKE faglflext-hsl01,                                    " 1月余额
        v_hsl02  LIKE faglflext-hsl02,                                    " 2月余额
        v_hsl03  LIKE faglflext-hsl03,                                    " 3月余额
        v_hsl04  LIKE faglflext-hsl04,                                    " 4月余额
        v_hsl05  LIKE faglflext-hsl05,                                    " 5月余额
        v_hsl06  LIKE faglflext-hsl06,                                    " 6月余额
        v_hsl07  LIKE faglflext-hsl07,                                    " 7月余额
        v_hsl08  LIKE faglflext-hsl08,                                    " 8月余额
        v_hsl09  LIKE faglflext-hsl09,                                    " 9月余额
        v_hsl10  LIKE faglflext-hsl10,                                    " 10月余额
        v_hsl11  LIKE faglflext-hsl11,                                    " 11月余额
        v_hsl12  LIKE faglflext-hsl12,                                    " 12月余额
        v_hsl13  LIKE faglflext-hsl13,                                    " 13月余额
        v_hsl14  LIKE faglflext-hsl14,                                    " 14月余额
        v_hsl15  LIKE faglflext-hsl15,                                    " 15月余额
        v_hsl16  LIKE faglflext-hsl16.                                    " 16月余额

DATA:   sr_hsl01  LIKE faglflext-hsl01,                                    " 1月余额
        sr_hsl02  LIKE faglflext-hsl02,                                    " 2月余额
        sr_hsl03  LIKE faglflext-hsl03,                                    " 3月余额
        sr_hsl04  LIKE faglflext-hsl04,                                    " 4月余额
        sr_hsl05  LIKE faglflext-hsl05,                                    " 5月余额
        sr_hsl06  LIKE faglflext-hsl06,                                    " 6月余额
        sr_hsl07  LIKE faglflext-hsl07,                                    " 7月余额
        sr_hsl08  LIKE faglflext-hsl08,                                    " 8月余额
        sr_hsl09  LIKE faglflext-hsl09,                                    " 9月余额
        sr_hsl10  LIKE faglflext-hsl10,                                    " 10月余额
        sr_hsl11  LIKE faglflext-hsl11,                                    " 11月余额
        sr_hsl12  LIKE faglflext-hsl12,                                    " 12月余额
        sr_hsl13  LIKE faglflext-hsl13,                                    " 13月余额
        sr_hsl14  LIKE faglflext-hsl14,                                    " 14月余额
        sr_hsl15  LIKE faglflext-hsl15,                                    " 15月余额
        sr_hsl16  LIKE faglflext-hsl16.                                    " 16月余额

DATA: lv_xh TYPE i.    " 序号

  LOOP AT it_srjn.

"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
    itab-item = '001'.
    itab-text = '产品销售收入'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = it_srjn-netwr.
    COLLECT itab.
    CLEAR itab.
   ELSE.
       itab-item = '001'.
       itab-text = '产品销售收入'.

       CLEAR lv_text.
       CONCATENATE 'IT_SY_JN-HSL' it_srjn-month+1(2) INTO lv_text.
       ASSIGN (lv_text) TO <fs>.

       CLEAR lv_text2.
       CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text2.
       ASSIGN (lv_text2) TO <fs2>.

       READ TABLE it_sy_jn WITH KEY item = '002'.
       <fs2> = <fs>.

       COLLECT itab.
       CLEAR itab.
   ENDIF.

"1100保定逻辑不变，其他公司分开
  IF s_bukrs-low = '1100'.
    itab-item = '002'.
    itab-text = '材料成本'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * ( it_srjn-kst001_st + it_srjn-kst085_st ).
    COLLECT itab.
    CLEAR itab.
  ELSE.
    itab-item = '002'.
    itab-text = '材料成本'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * ( it_srjn-kst003_st + it_srjn-kst005_st + it_srjn-kst007_st + it_srjn-kst077_st + it_srjn-kst009_st + it_srjn-kst011_st ).

    CLEAR lv_text2.
    CONCATENATE 'IT_SY_JN-HSL' it_srjn-month+1(2) INTO lv_text2.
    ASSIGN (lv_text2) TO <fs2>.

    READ TABLE it_sy_jn WITH KEY item = '007'.
    <fs> = - <fs2> - <fs> .
    COLLECT itab.
    CLEAR itab.
  ENDIF.

    itab-item = '004'.
    itab-text = '直接人工'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srjn-kst003_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '006'.
    itab-text = '燃动'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * ( it_srjn-kst005_st + it_srjn-kst007_st ).
    COLLECT itab.
    CLEAR itab.

    itab-item = '008'.
    itab-text = '运费'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srjn-kst_yf.
    COLLECT itab.
    CLEAR itab.

    itab-item = '012'.
    itab-text = '间接人工'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srjn-kst077_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '014'.
    itab-text = '折旧'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srjn-kst009_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '016'.
    itab-text = '制造费用'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-HSL' it_srjn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srjn-kst011_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '018'.
    itab-text = '费用分配差额'.
    COLLECT itab.
    CLEAR itab.

    itab-item = '019'.
    itab-text = ''.
    COLLECT itab.
    CLEAR itab.

  ENDLOOP.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].

  LOOP AT it_sy_jn.

   itab-hsl01 = it_sy_jn-hsl01 .     " 1月余额
   itab-hsl02 = it_sy_jn-hsl02 .     " 2月余额
   itab-hsl03 = it_sy_jn-hsl03 .     " 3月余额
   itab-hsl04 = it_sy_jn-hsl04 .     " 4月余额
   itab-hsl05 = it_sy_jn-hsl05 .     " 5月余额
   itab-hsl06 = it_sy_jn-hsl06 .     " 6月余额
   itab-hsl07 = it_sy_jn-hsl07 .     " 7月余额
   itab-hsl08 = it_sy_jn-hsl08 .     " 8月余额
   itab-hsl09 = it_sy_jn-hsl09 .     " 9月余额
   itab-hsl10 = it_sy_jn-hsl10 .     " 10月余额
   itab-hsl11 = it_sy_jn-hsl11 .     " 11月余额
   itab-hsl12 = it_sy_jn-hsl12 .     " 12月余额
   itab-hsl13 = it_sy_jn-hsl13 .     " 13月余额
   itab-hsl14 = it_sy_jn-hsl14 .     " 14月余额
   itab-hsl15 = it_sy_jn-hsl15 .     " 15月余额
   itab-hsl16 = it_sy_jn-hsl16 .     " 16月余额

   CASE it_sy_jn-item.

    WHEN '001'."损益表001项目
"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
     itab-item = '022'.
     itab-text = '其他业务收入'.
     READ TABLE itab2 WITH KEY item = '001'.
     itab-hsl01 = itab-hsl01 - itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 - itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 - itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 - itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 - itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 - itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 - itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 - itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 - itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 - itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 - itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 - itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 - itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 - itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 - itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 - itab2-hsl16 .     " 16月余额
     COLLECT itab.
     CLEAR itab.
   ENDIF.

     "总销售收入
     CLEAR: sr_hsl01,sr_hsl02,sr_hsl03,sr_hsl04,sr_hsl05,sr_hsl06,sr_hsl07,sr_hsl08,sr_hsl09,sr_hsl10,sr_hsl11,sr_hsl12,sr_hsl13,sr_hsl14,sr_hsl15,sr_hsl16.
     sr_hsl01 = it_sy_jn-hsl01 .     " 1月余额
     sr_hsl02 = it_sy_jn-hsl02 .     " 2月余额
     sr_hsl03 = it_sy_jn-hsl03 .     " 3月余额
     sr_hsl04 = it_sy_jn-hsl04 .     " 4月余额
     sr_hsl05 = it_sy_jn-hsl05 .     " 5月余额
     sr_hsl06 = it_sy_jn-hsl06 .     " 6月余额
     sr_hsl07 = it_sy_jn-hsl07 .     " 7月余额
     sr_hsl08 = it_sy_jn-hsl08 .     " 8月余额
     sr_hsl09 = it_sy_jn-hsl09 .     " 9月余额
     sr_hsl10 = it_sy_jn-hsl10 .     " 10月余额
     sr_hsl11 = it_sy_jn-hsl11 .     " 11月余额
     sr_hsl12 = it_sy_jn-hsl12 .     " 12月余额
     sr_hsl13 = it_sy_jn-hsl13 .     " 13月余额
     sr_hsl14 = it_sy_jn-hsl14 .     " 14月余额
     sr_hsl15 = it_sy_jn-hsl15 .     " 15月余额
     sr_hsl16 = it_sy_jn-hsl16 .     " 16月余额
     itab-item = '040'.
     itab-text = '总销售收入'.
     itab-hsl01 = sr_hsl01.     " 1月余额
     itab-hsl02 = sr_hsl02.     " 2月余额
     itab-hsl03 = sr_hsl03.     " 3月余额
     itab-hsl04 = sr_hsl04.     " 4月余额
     itab-hsl05 = sr_hsl05.     " 5月余额
     itab-hsl06 = sr_hsl06.     " 6月余额
     itab-hsl07 = sr_hsl07.     " 7月余额
     itab-hsl08 = sr_hsl08.     " 8月余额
     itab-hsl09 = sr_hsl09.     " 9月余额
     itab-hsl10 = sr_hsl10.     " 10月余额
     itab-hsl11 = sr_hsl11.     " 11月余额
     itab-hsl12 = sr_hsl12.     " 12月余额
     itab-hsl13 = sr_hsl13.     " 13月余额
     itab-hsl14 = sr_hsl14.     " 14月余额
     itab-hsl15 = sr_hsl15.     " 15月余额
     itab-hsl16 = sr_hsl16.     " 16月余额
     COLLECT itab.
     CLEAR itab.

    WHEN '003'.
"1100保定逻辑不变，其他公司分开
    IF s_bukrs-low = '1100'.
    ELSE.
     itab-item = '022'.
     itab-text = '其他业务收入'.
     COLLECT itab.
     CLEAR itab.
    ENDIF.


    WHEN '006'."损益表006项目
"1100保定逻辑不变，其他公司分开
    IF s_bukrs-low = '1100'.
     itab-item = '023'.
     itab-text = '其他业务成本'.
     CLEAR: v_hsl01,v_hsl02,v_hsl03,v_hsl04,v_hsl05,v_hsl06,v_hsl07,v_hsl08,v_hsl09,v_hsl10,v_hsl11,v_hsl12,v_hsl13,v_hsl14,v_hsl15,v_hsl16.
     LOOP AT itab2 WHERE item = '002' OR item = '004' OR item = '006' OR item = '012' OR item = '014' OR item = '016'.
        v_hsl01 = v_hsl01 + itab2-hsl01 .     " 1月余额
        v_hsl02 = v_hsl02 + itab2-hsl02 .     " 2月余额
        v_hsl03 = v_hsl03 + itab2-hsl03 .     " 3月余额
        v_hsl04 = v_hsl04 + itab2-hsl04 .     " 4月余额
        v_hsl05 = v_hsl05 + itab2-hsl05 .     " 5月余额
        v_hsl06 = v_hsl06 + itab2-hsl06.     " 6月余额
        v_hsl07 = v_hsl07 + itab2-hsl07 .     " 7月余额
        v_hsl08 = v_hsl08 + itab2-hsl08 .     " 8月余额
        v_hsl09 = v_hsl09 + itab2-hsl09 .     " 9月余额
        v_hsl10 = v_hsl10 + itab2-hsl10 .     " 10月余额
        v_hsl11 = v_hsl11 + itab2-hsl11 .     " 11月余额
        v_hsl12 = v_hsl12 + itab2-hsl12 .     " 12月余额
        v_hsl13 = v_hsl13 + itab2-hsl13 .     " 13月余额
        v_hsl14 = v_hsl14 + itab2-hsl14 .     " 14月余额
        v_hsl15 = v_hsl15 + itab2-hsl15 .     " 15月余额
        v_hsl16 = v_hsl16 + itab2-hsl16 .     " 16月余额
     ENDLOOP.
     itab-hsl01 = -1 * ( itab-hsl01 - ( -1 ) * v_hsl01 ).     " 1月余额
     itab-hsl02 = -1 * ( itab-hsl02 - ( -1 ) * v_hsl02 ) .     " 2月余额
     itab-hsl03 = -1 * ( itab-hsl03 - ( -1 ) * v_hsl03 ) .     " 3月余额
     itab-hsl04 = -1 * ( itab-hsl04 - ( -1 ) * v_hsl04 ).     " 4月余额
     itab-hsl05 = -1 * ( itab-hsl05 - ( -1 ) * v_hsl05 ).     " 5月余额
     itab-hsl06 = -1 * ( itab-hsl06 - ( -1 ) * v_hsl06 ).     " 6月余额
     itab-hsl07 = -1 * ( itab-hsl07 - ( -1 ) * v_hsl07 ).     " 7月余额
     itab-hsl08 = -1 * ( itab-hsl08 - ( -1 ) * v_hsl08 ).     " 8月余额
     itab-hsl09 = -1 * ( itab-hsl09 - ( -1 ) * v_hsl09 ).     " 9月余额
     itab-hsl10 = -1 * ( itab-hsl10 - ( -1 ) * v_hsl10 ).     " 10月余额
     itab-hsl11 = -1 * ( itab-hsl11 - ( -1 ) * v_hsl11 ).     " 11月余额
     itab-hsl12 = -1 * ( itab-hsl12 - ( -1 ) * v_hsl12 ).     " 12月余额
     itab-hsl13 = -1 * ( itab-hsl13 - ( -1 ) * v_hsl13 ).     " 13月余额
     itab-hsl14 = -1 * ( itab-hsl14 - ( -1 ) * v_hsl14 ).     " 14月余额
     itab-hsl15 = -1 * ( itab-hsl15 - ( -1 ) * v_hsl15 ).     " 15月余额
     itab-hsl16 = -1 * ( itab-hsl16 - ( -1 ) * v_hsl16 ).     " 16月余额
     COLLECT itab.
     CLEAR itab.
     ENDIF.

     WHEN '008'."损益表008项目
"1100保定逻辑不变，其他公司分开
    IF s_bukrs-low = '1100'.
    ELSE.
     itab-item = '023'.
     itab-text = '其他业务成本'.
     itab-hsl01 = -1 * itab-hsl01.     " 1月余额
     itab-hsl02 = -1 * itab-hsl02.     " 2月余额
     itab-hsl03 = -1 * itab-hsl03.     " 3月余额
     itab-hsl04 = -1 * itab-hsl04.     " 4月余额
     itab-hsl05 = -1 * itab-hsl05.     " 5月余额
     itab-hsl06 = -1 * itab-hsl06.     " 6月余额
     itab-hsl07 = -1 * itab-hsl07.     " 7月余额
     itab-hsl08 = -1 * itab-hsl08.     " 8月余额
     itab-hsl09 = -1 * itab-hsl09.     " 9月余额
     itab-hsl10 = -1 * itab-hsl10.     " 10月余额
     itab-hsl11 = -1 * itab-hsl11.     " 11月余额
     itab-hsl12 = -1 * itab-hsl12.     " 12月余额
     itab-hsl13 = -1 * itab-hsl13.     " 13月余额
     itab-hsl14 = -1 * itab-hsl14.     " 14月余额
     itab-hsl15 = -1 * itab-hsl15.     " 15月余额
     itab-hsl16 = -1 * itab-hsl16.     " 16月余额
     COLLECT itab.
     CLEAR itab.
    ENDIF.

     WHEN '013'."损益表013项目管理费用
       itab-item = '028'.
       itab-text = '管理费用'.
       itab-hsl01 = -1 * itab-hsl01.     " 1月余额
       itab-hsl02 = -1 * itab-hsl02.     " 2月余额
       itab-hsl03 = -1 * itab-hsl03.     " 3月余额
       itab-hsl04 = -1 * itab-hsl04.     " 4月余额
       itab-hsl05 = -1 * itab-hsl05.     " 5月余额
       itab-hsl06 = -1 * itab-hsl06.     " 6月余额
       itab-hsl07 = -1 * itab-hsl07.     " 7月余额
       itab-hsl08 = -1 * itab-hsl08.     " 8月余额
       itab-hsl09 = -1 * itab-hsl09.     " 9月余额
       itab-hsl10 = -1 * itab-hsl10.     " 10月余额
       itab-hsl11 = -1 * itab-hsl11.     " 11月余额
       itab-hsl12 = -1 * itab-hsl12.     " 12月余额
       itab-hsl13 = -1 * itab-hsl13.     " 13月余额
       itab-hsl14 = -1 * itab-hsl14.     " 14月余额
       itab-hsl15 = -1 * itab-hsl15.     " 15月余额
       itab-hsl16 = -1 * itab-hsl16.     " 16月余额
       COLLECT itab.
       CLEAR itab.

      WHEN '012'."损益表012项目　　销售费用
        itab-item = '030'.
        itab-text = '销售费用'.
        READ TABLE itab2 WITH KEY item = '008'.
        itab-hsl01 = -1 * ( itab-hsl01 + itab2-hsl01 ) .     " 1月余额
        itab-hsl02 = -1 * ( itab-hsl02 + itab2-hsl02 ) .     " 2月余额
        itab-hsl03 = -1 * ( itab-hsl03 + itab2-hsl03 ).     " 3月余额
        itab-hsl04 = -1 * ( itab-hsl04 + itab2-hsl04 ) .     " 4月余额
        itab-hsl05 = -1 * ( itab-hsl05 + itab2-hsl05 ).     " 5月余额
        itab-hsl06 = -1 * ( itab-hsl06 + itab2-hsl06 ).     " 6月余额
        itab-hsl07 = -1 * ( itab-hsl07 + itab2-hsl07 ).     " 7月余额
        itab-hsl08 = -1 * ( itab-hsl08 + itab2-hsl08 ).     " 8月余额
        itab-hsl09 = -1 * ( itab-hsl09 + itab2-hsl09 ).     " 9月余额
        itab-hsl10 = -1 * ( itab-hsl10 + itab2-hsl10 ).     " 10月余额
        itab-hsl11 = -1 * ( itab-hsl11 + itab2-hsl11 ).     " 11月余额
        itab-hsl12 = -1 * ( itab-hsl12 + itab2-hsl12 ).     " 12月余额
        itab-hsl13 = -1 * ( itab-hsl13 + itab2-hsl13 ).     " 13月余额
        itab-hsl14 = -1 * ( itab-hsl14 + itab2-hsl14 ).     " 14月余额
        itab-hsl15 = -1 * ( itab-hsl15 + itab2-hsl15 ).     " 15月余额
        itab-hsl16 = -1 * ( itab-hsl16 + itab2-hsl16 ).     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '014'."损益表012项目　　研发费用
        itab-item = '032'.
        itab-text = '研发费用'.
        itab-hsl01 = -1 * itab-hsl01.     " 1月余额
        itab-hsl02 = -1 * itab-hsl02.     " 2月余额
        itab-hsl03 = -1 * itab-hsl03.     " 3月余额
        itab-hsl04 = -1 * itab-hsl04.     " 4月余额
        itab-hsl05 = -1 * itab-hsl05.     " 5月余额
        itab-hsl06 = -1 * itab-hsl06.     " 6月余额
        itab-hsl07 = -1 * itab-hsl07.     " 7月余额
        itab-hsl08 = -1 * itab-hsl08.     " 8月余额
        itab-hsl09 = -1 * itab-hsl09.     " 9月余额
        itab-hsl10 = -1 * itab-hsl10.     " 10月余额
        itab-hsl11 = -1 * itab-hsl11.     " 11月余额
        itab-hsl12 = -1 * itab-hsl12.     " 12月余额
        itab-hsl13 = -1 * itab-hsl13.     " 13月余额
        itab-hsl14 = -1 * itab-hsl14.     " 14月余额
        itab-hsl15 = -1 * itab-hsl15.     " 15月余额
        itab-hsl16 = -1 * itab-hsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '011'."损益表011项目　　　税金及附加
        itab-item = '034'.
        itab-text = '税金及附加'.
        itab-hsl01 = -1 * itab-hsl01.     " 1月余额
        itab-hsl02 = -1 * itab-hsl02.     " 2月余额
        itab-hsl03 = -1 * itab-hsl03.     " 3月余额
        itab-hsl04 = -1 * itab-hsl04.     " 4月余额
        itab-hsl05 = -1 * itab-hsl05.     " 5月余额
        itab-hsl06 = -1 * itab-hsl06.     " 6月余额
        itab-hsl07 = -1 * itab-hsl07.     " 7月余额
        itab-hsl08 = -1 * itab-hsl08.     " 8月余额
        itab-hsl09 = -1 * itab-hsl09.     " 9月余额
        itab-hsl10 = -1 * itab-hsl10.     " 10月余额
        itab-hsl11 = -1 * itab-hsl11.     " 11月余额
        itab-hsl12 = -1 * itab-hsl12.     " 12月余额
        itab-hsl13 = -1 * itab-hsl13.     " 13月余额
        itab-hsl14 = -1 * itab-hsl14.     " 14月余额
        itab-hsl15 = -1 * itab-hsl15.     " 15月余额
        itab-hsl16 = -1 * itab-hsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '016'."损益表016项目　　　　　资产减值损失
        itab-item = '036'.
        itab-text = '资产减值损失'.
        itab-hsl01 = -1 * itab-hsl01.     " 1月余额
        itab-hsl02 = -1 * itab-hsl02.     " 2月余额
        itab-hsl03 = -1 * itab-hsl03.     " 3月余额
        itab-hsl04 = -1 * itab-hsl04.     " 4月余额
        itab-hsl05 = -1 * itab-hsl05.     " 5月余额
        itab-hsl06 = -1 * itab-hsl06.     " 6月余额
        itab-hsl07 = -1 * itab-hsl07.     " 7月余额
        itab-hsl08 = -1 * itab-hsl08.     " 8月余额
        itab-hsl09 = -1 * itab-hsl09.     " 9月余额
        itab-hsl10 = -1 * itab-hsl10.     " 10月余额
        itab-hsl11 = -1 * itab-hsl11.     " 11月余额
        itab-hsl12 = -1 * itab-hsl12.     " 12月余额
        itab-hsl13 = -1 * itab-hsl13.     " 13月余额
        itab-hsl14 = -1 * itab-hsl14.     " 14月余额
        itab-hsl15 = -1 * itab-hsl15.     " 15月余额
        itab-hsl16 = -1 * itab-hsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '017'."损益表017项目　　　　　信用减值损失
        itab-item = '038'.
        itab-text = '信用减值损失'.
        itab-hsl01 = -1 * itab-hsl01.     " 1月余额
        itab-hsl02 = -1 * itab-hsl02.     " 2月余额
        itab-hsl03 = -1 * itab-hsl03.     " 3月余额
        itab-hsl04 = -1 * itab-hsl04.     " 4月余额
        itab-hsl05 = -1 * itab-hsl05.     " 5月余额
        itab-hsl06 = -1 * itab-hsl06.     " 6月余额
        itab-hsl07 = -1 * itab-hsl07.     " 7月余额
        itab-hsl08 = -1 * itab-hsl08.     " 8月余额
        itab-hsl09 = -1 * itab-hsl09.     " 9月余额
        itab-hsl10 = -1 * itab-hsl10.     " 10月余额
        itab-hsl11 = -1 * itab-hsl11.     " 11月余额
        itab-hsl12 = -1 * itab-hsl12.     " 12月余额
        itab-hsl13 = -1 * itab-hsl13.     " 13月余额
        itab-hsl14 = -1 * itab-hsl14.     " 14月余额
        itab-hsl15 = -1 * itab-hsl15.     " 15月余额
        itab-hsl16 = -1 * itab-hsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '020'."损益表020项目　投资收益
        itab-item = '043'.
        itab-text = '投资收益'.
        COLLECT itab.
        CLEAR itab.
       WHEN '019'."损益表019项目　其他收益
        itab-item = '044'.
        itab-text = '其他收益'.
        COLLECT itab.
        CLEAR itab.
       WHEN '024'."损益表024项目　营业外收入
        itab-item = '451'.
        itab-text = '营业外收入'.
        COLLECT itab.
        CLEAR itab.
       WHEN '025'."损益表025项目　营业外支出
        itab-item = '452'.
        itab-text = '营业外支出'.
        COLLECT itab.
        CLEAR itab.
       WHEN '015'."损益表015项目　财务费用
        itab-item = '046'.
        itab-text = '财务费用'.
        itab-hsl01 = -1 * itab-hsl01.     " 1月余额
        itab-hsl02 = -1 * itab-hsl02.     " 2月余额
        itab-hsl03 = -1 * itab-hsl03.     " 3月余额
        itab-hsl04 = -1 * itab-hsl04.     " 4月余额
        itab-hsl05 = -1 * itab-hsl05.     " 5月余额
        itab-hsl06 = -1 * itab-hsl06.     " 6月余额
        itab-hsl07 = -1 * itab-hsl07.     " 7月余额
        itab-hsl08 = -1 * itab-hsl08.     " 8月余额
        itab-hsl09 = -1 * itab-hsl09.     " 9月余额
        itab-hsl10 = -1 * itab-hsl10.     " 10月余额
        itab-hsl11 = -1 * itab-hsl11.     " 11月余额
        itab-hsl12 = -1 * itab-hsl12.     " 12月余额
        itab-hsl13 = -1 * itab-hsl13.     " 13月余额
        itab-hsl14 = -1 * itab-hsl14.     " 14月余额
        itab-hsl15 = -1 * itab-hsl15.     " 15月余额
        itab-hsl16 = -1 * itab-hsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.
       WHEN '027'."损益表027项目　所得税费用
        itab-item = '050'.
        itab-text = '所得税费用'.
        itab-hsl01 = -1 * itab-hsl01.     " 1月余额
        itab-hsl02 = -1 * itab-hsl02.     " 2月余额
        itab-hsl03 = -1 * itab-hsl03.     " 3月余额
        itab-hsl04 = -1 * itab-hsl04.     " 4月余额
        itab-hsl05 = -1 * itab-hsl05.     " 5月余额
        itab-hsl06 = -1 * itab-hsl06.     " 6月余额
        itab-hsl07 = -1 * itab-hsl07.     " 7月余额
        itab-hsl08 = -1 * itab-hsl08.     " 8月余额
        itab-hsl09 = -1 * itab-hsl09.     " 9月余额
        itab-hsl10 = -1 * itab-hsl10.     " 10月余额
        itab-hsl11 = -1 * itab-hsl11.     " 11月余额
        itab-hsl12 = -1 * itab-hsl12.     " 12月余额
        itab-hsl13 = -1 * itab-hsl13.     " 13月余额
        itab-hsl14 = -1 * itab-hsl14.     " 14月余额
        itab-hsl15 = -1 * itab-hsl15.     " 15月余额
        itab-hsl16 = -1 * itab-hsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.
   ENDCASE.

  ENDLOOP.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '002'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
   IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '003'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '004'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '005'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '006'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '007'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '008'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '009'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  LOOP AT itab2 WHERE item = '001' OR item = '002' OR item = '004' OR item = '006' OR item = '008'.
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '010'.
   itab-text = '边际贡献'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '010'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
   IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '011'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

 READ TABLE itab2 WITH KEY item = '012'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '013'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '014'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '015'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '016'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '017'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
   LOOP AT itab2 WHERE item = '010' OR item = '012' OR item = '014' OR item = '016'.
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '020'.
   itab-text = '毛利'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '020'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '021'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '022'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '023'.
   itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab-hsl06 + itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   itab-item = '024'.
   itab-text = '其他业务利润'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
   LOOP AT itab2 WHERE item = '020' OR item = '024'.
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '026'.
   itab-text = '综合毛利'.
   COLLECT itab.
   CLEAR itab.
   ELSE.
    LOOP AT itab2 WHERE item = '020' OR item = '024' .
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   LOOP AT itab2 WHERE item = '008' .
     itab-hsl01 = itab-hsl01 - itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 - itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 - itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 - itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 - itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 - itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 - itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 - itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 - itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 - itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 - itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 - itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 - itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 - itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 - itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 - itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '026'.
   itab-text = '综合毛利'.
   COLLECT itab.
   CLEAR itab.
   ENDIF.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '451'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '452'.
   itab-hsl01 = itab-hsl01 - itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab-hsl02 - itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab-hsl03 - itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab-hsl04 - itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab-hsl05 - itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab-hsl06 - itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab-hsl07 - itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab-hsl08 - itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab-hsl09 - itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab-hsl10 - itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab-hsl11 - itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab-hsl12 - itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab-hsl13 - itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab-hsl14 - itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab-hsl15 - itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab-hsl16 - itab2-hsl16 .     " 16月余额
   itab-item = '045'.
   itab-text = '营业外损益'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   LOOP AT itab2 WHERE item = '020' OR item = '024' OR item = '028' OR item = '030' OR item = '032' OR item = '034' OR item = '036' OR item = '038'.
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '041'.
   itab-text = '经营利润'.
   COLLECT itab.
   CLEAR itab.

   itab-item = '047'.
   itab-text = '其他'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   LOOP AT itab2 WHERE item = '041' OR item = '043' OR item = '044' OR item = '045' OR item = '046' OR item = '047'.
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '048'.
   itab-text = '税前利润'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   LOOP AT itab2 WHERE item = '048' OR item = '050'.
     itab-hsl01 = itab-hsl01 + itab2-hsl01 .     " 1月余额
     itab-hsl02 = itab-hsl02 + itab2-hsl02 .     " 2月余额
     itab-hsl03 = itab-hsl03 + itab2-hsl03 .     " 3月余额
     itab-hsl04 = itab-hsl04 + itab2-hsl04 .     " 4月余额
     itab-hsl05 = itab-hsl05 + itab2-hsl05 .     " 5月余额
     itab-hsl06 = itab-hsl06 + itab2-hsl06.     " 6月余额
     itab-hsl07 = itab-hsl07 + itab2-hsl07 .     " 7月余额
     itab-hsl08 = itab-hsl08 + itab2-hsl08 .     " 8月余额
     itab-hsl09 = itab-hsl09 + itab2-hsl09 .     " 9月余额
     itab-hsl10 = itab-hsl10 + itab2-hsl10 .     " 10月余额
     itab-hsl11 = itab-hsl11 + itab2-hsl11 .     " 11月余额
     itab-hsl12 = itab-hsl12 + itab2-hsl12 .     " 12月余额
     itab-hsl13 = itab-hsl13 + itab2-hsl13 .     " 13月余额
     itab-hsl14 = itab-hsl14 + itab2-hsl14 .     " 14月余额
     itab-hsl15 = itab-hsl15 + itab2-hsl15 .     " 15月余额
     itab-hsl16 = itab-hsl16 + itab2-hsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '051'.
   itab-text = '净利润'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   READ TABLE itab2 WITH KEY item = '024'.
   itab-hsl01 = itab2-hsl01 .     " 1月余额
   itab-hsl02 = itab2-hsl02 .     " 2月余额
   itab-hsl03 = itab2-hsl03 .     " 3月余额
   itab-hsl04 = itab2-hsl04 .     " 4月余额
   itab-hsl05 = itab2-hsl05 .     " 5月余额
   itab-hsl06 = itab2-hsl06 .     " 6月余额
   itab-hsl07 = itab2-hsl07 .     " 7月余额
   itab-hsl08 = itab2-hsl08 .     " 8月余额
   itab-hsl09 = itab2-hsl09 .     " 9月余额
   itab-hsl10 = itab2-hsl10 .     " 10月余额
   itab-hsl11 = itab2-hsl11 .     " 11月余额
   itab-hsl12 = itab2-hsl12 .     " 12月余额
   itab-hsl13 = itab2-hsl13 .     " 13月余额
   itab-hsl14 = itab2-hsl14 .     " 14月余额
   itab-hsl15 = itab2-hsl15 .     " 15月余额
   itab-hsl16 = itab2-hsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '022'.
      IF itab2-hsl01 <> 0.
   itab-hsl01 = itab-hsl01 / itab2-hsl01 * 100 .     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF itab2-hsl02 <> 0.
   itab-hsl02 = itab-hsl02 / itab2-hsl02 * 100 .     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF itab2-hsl03 <> 0.
   itab-hsl03 = itab-hsl03 / itab2-hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF itab2-hsl04 <> 0.
   itab-hsl04 = itab-hsl04 / itab2-hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF itab2-hsl05 <> 0.
   itab-hsl05 = itab-hsl05 / itab2-hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF itab2-hsl06 <> 0.
   itab-hsl06 = itab-hsl06 / itab2-hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF itab2-hsl07 <> 0.
   itab-hsl07 = itab-hsl07 / itab2-hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF itab2-hsl08 <> 0.
   itab-hsl08 = itab-hsl08 / itab2-hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF itab2-hsl09 <> 0.
   itab-hsl09 = itab-hsl09 / itab2-hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF itab2-hsl10 <> 0.
   itab-hsl10 = itab-hsl10 / itab2-hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF itab2-hsl11 <> 0.
   itab-hsl11 = itab-hsl11 / itab2-hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF itab2-hsl12 <> 0.
   itab-hsl12 = itab-hsl12 / itab2-hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF itab2-hsl13 <> 0.
   itab-hsl13 = itab-hsl13 / itab2-hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF itab2-hsl14 <> 0.
   itab-hsl14 = itab-hsl14 / itab2-hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF itab2-hsl15 <> 0.
   itab-hsl15 = itab-hsl15 / itab2-hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF itab2-hsl16 <> 0.
   itab-hsl16 = itab-hsl16 / itab2-hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '025'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '026'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '027'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '028'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '029'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '030'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '031'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '032'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '033'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '034'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '035'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '036'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '037'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '038'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '039'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '041'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '042'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '048'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '049'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '051'.
   IF sr_hsl01 <> 0.
   itab-hsl01 = itab2-hsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-hsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-hsl02 = itab2-hsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-hsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-hsl03 = itab2-hsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-hsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-hsl04 = itab2-hsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-hsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-hsl05 = itab2-hsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-hsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-hsl06 = itab2-hsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-hsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-hsl07 = itab2-hsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-hsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-hsl08 = itab2-hsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-hsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-hsl09 = itab2-hsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-hsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-hsl10 = itab2-hsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-hsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-hsl11 = itab2-hsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-hsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-hsl12 = itab2-hsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-hsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-hsl13 = itab2-hsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-hsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-hsl14 = itab2-hsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-hsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-hsl15 = itab2-hsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-hsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-hsl16 = itab2-hsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-hsl16 = 0.
   ENDIF.
   itab-item = '052'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form data_process_qn
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM data_process_qn.
FIELD-SYMBOLS: <fs> TYPE any.                 " 字段符号1
DATA: lv_text(19)  TYPE c.   " 文本1
FIELD-SYMBOLS: <fs2> TYPE any.                 " 字段符号1
DATA: lv_text2(19)  TYPE c.   " 文本1
DATA:   v_hsl01  LIKE faglflext-hsl01,                                    " 1月余额
        v_hsl02  LIKE faglflext-hsl02,                                    " 2月余额
        v_hsl03  LIKE faglflext-hsl03,                                    " 3月余额
        v_hsl04  LIKE faglflext-hsl04,                                    " 4月余额
        v_hsl05  LIKE faglflext-hsl05,                                    " 5月余额
        v_hsl06  LIKE faglflext-hsl06,                                    " 6月余额
        v_hsl07  LIKE faglflext-hsl07,                                    " 7月余额
        v_hsl08  LIKE faglflext-hsl08,                                    " 8月余额
        v_hsl09  LIKE faglflext-hsl09,                                    " 9月余额
        v_hsl10  LIKE faglflext-hsl10,                                    " 10月余额
        v_hsl11  LIKE faglflext-hsl11,                                    " 11月余额
        v_hsl12  LIKE faglflext-hsl12,                                    " 12月余额
        v_hsl13  LIKE faglflext-hsl13,                                    " 13月余额
        v_hsl14  LIKE faglflext-hsl14,                                    " 14月余额
        v_hsl15  LIKE faglflext-hsl15,                                    " 15月余额
        v_hsl16  LIKE faglflext-hsl16.                                    " 16月余额

DATA:   sr_hsl01  LIKE faglflext-hsl01,                                    " 1月余额
        sr_hsl02  LIKE faglflext-hsl02,                                    " 2月余额
        sr_hsl03  LIKE faglflext-hsl03,                                    " 3月余额
        sr_hsl04  LIKE faglflext-hsl04,                                    " 4月余额
        sr_hsl05  LIKE faglflext-hsl05,                                    " 5月余额
        sr_hsl06  LIKE faglflext-hsl06,                                    " 6月余额
        sr_hsl07  LIKE faglflext-hsl07,                                    " 7月余额
        sr_hsl08  LIKE faglflext-hsl08,                                    " 8月余额
        sr_hsl09  LIKE faglflext-hsl09,                                    " 9月余额
        sr_hsl10  LIKE faglflext-hsl10,                                    " 10月余额
        sr_hsl11  LIKE faglflext-hsl11,                                    " 11月余额
        sr_hsl12  LIKE faglflext-hsl12,                                    " 12月余额
        sr_hsl13  LIKE faglflext-hsl13,                                    " 13月余额
        sr_hsl14  LIKE faglflext-hsl14,                                    " 14月余额
        sr_hsl15  LIKE faglflext-hsl15,                                    " 15月余额
        sr_hsl16  LIKE faglflext-hsl16.                                    " 16月余额

  LOOP AT it_srqn.

"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
    itab-item = '001'.
    itab-text = '产品销售收入'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srqn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = it_srqn-netwr.
    COLLECT itab.
    CLEAR itab.
   ELSE.
       itab-item = '001'.
       itab-text = '产品销售收入'.

       CLEAR lv_text.
       CONCATENATE 'IT_SY_QN-HSL' it_srqn-month+1(2) INTO lv_text.
       ASSIGN (lv_text) TO <fs>.

       CLEAR lv_text2.
       CONCATENATE 'ITAB-QNHSL' it_srqn-month+1(2) INTO lv_text2.
       ASSIGN (lv_text2) TO <fs2>.

       READ TABLE it_sy_qn WITH KEY item = '002'.
       <fs2> = <fs>.

       COLLECT itab.
       CLEAR itab.
   ENDIF.

"1100保定逻辑不变，其他公司分开
  IF s_bukrs-low = '1100'.
    itab-item = '002'.
    itab-text = '材料成本'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srqn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * ( it_srqn-kst001_st + it_srqn-kst085_st ).
    COLLECT itab.
    CLEAR itab.
  ELSE.
    itab-item = '002'.
    itab-text = '材料成本'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srqn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * ( it_srqn-kst003_st + it_srqn-kst005_st + it_srqn-kst007_st + it_srqn-kst077_st + it_srqn-kst009_st + it_srqn-kst011_st ).

    CLEAR lv_text2.
    CONCATENATE 'IT_SY_QN-HSL' it_srqn-month+1(2) INTO lv_text2.
    ASSIGN (lv_text2) TO <fs2>.

    READ TABLE it_sy_qn WITH KEY item = '007'.
    <fs> = - <fs2> - <fs> .
    COLLECT itab.
    CLEAR itab.
  ENDIF.

    itab-item = '004'.
    itab-text = '直接人工'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srQn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srQn-kst003_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '006'.
    itab-text = '燃动'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srQn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * ( it_srQn-kst005_st + it_srQn-kst007_st ).
    COLLECT itab.
    CLEAR itab.

    itab-item = '008'.
    itab-text = '运费'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srQn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srQn-kst_yf.
    COLLECT itab.
    CLEAR itab.

    itab-item = '012'.
    itab-text = '间接人工'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srQn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srQn-kst077_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '014'.
    itab-text = '折旧'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srQn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srQn-kst009_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '016'.
    itab-text = '制造费用'.
    CLEAR lv_text.
    CONCATENATE 'ITAB-QNHSL' it_srQn-month+1(2) INTO lv_text.
    ASSIGN (lv_text) TO <fs>.
    <fs> = -1 * it_srQn-kst011_st.
    COLLECT itab.
    CLEAR itab.

    itab-item = '018'.
    itab-text = '费用分配差额'.
    COLLECT itab.
    CLEAR itab.

    itab-item = '019'.
    itab-text = ''.
    COLLECT itab.
    CLEAR itab.

  ENDLOOP.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].

  LOOP AT it_sy_Qn.

   itab-QNhsl01 = it_sy_Qn-hsl01 .     " 1月余额
   itab-QNhsl02 = it_sy_Qn-hsl02 .     " 2月余额
   itab-QNhsl03 = it_sy_Qn-hsl03 .     " 3月余额
   itab-QNhsl04 = it_sy_Qn-hsl04 .     " 4月余额
   itab-QNhsl05 = it_sy_Qn-hsl05 .     " 5月余额
   itab-QNhsl06 = it_sy_Qn-hsl06 .     " 6月余额
   itab-QNhsl07 = it_sy_Qn-hsl07 .     " 7月余额
   itab-QNhsl08 = it_sy_Qn-hsl08 .     " 8月余额
   itab-QNhsl09 = it_sy_Qn-hsl09 .     " 9月余额
   itab-QNhsl10 = it_sy_Qn-hsl10 .     " 10月余额
   itab-QNhsl11 = it_sy_Qn-hsl11 .     " 11月余额
   itab-QNhsl12 = it_sy_Qn-hsl12 .     " 12月余额
   itab-QNhsl13 = it_sy_Qn-hsl13 .     " 13月余额
   itab-QNhsl14 = it_sy_Qn-hsl14 .     " 14月余额
   itab-QNhsl15 = it_sy_Qn-hsl15 .     " 15月余额
   itab-QNhsl16 = it_sy_Qn-hsl16 .     " 16月余额

   CASE it_sy_Qn-item.

    WHEN '001'."损益表001项目
"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
     itab-item = '022'.
     itab-text = '其他业务收入'.
     READ TABLE itab2 WITH KEY item = '001'.
     itab-QNhsl01 = itab-qnhsl01 - itab2-qnhsl01 .     " 1月余额
     itab-QNhsl02 = itab-qnhsl02 - itab2-qnhsl02 .     " 2月余额
     itab-QNhsl03 = itab-qnhsl03 - itab2-qnhsl03 .     " 3月余额
     itab-QNhsl04 = itab-qnhsl04 - itab2-qnhsl04 .     " 4月余额
     itab-QNhsl05 = itab-qnhsl05 - itab2-qnhsl05 .     " 5月余额
     itab-QNhsl06 = itab-qnhsl06 - itab2-qnhsl06.     " 6月余额
     itab-QNhsl07 = itab-qnhsl07 - itab2-qnhsl07 .     " 7月余额
     itab-QNhsl08 = itab-qnhsl08 - itab2-qnhsl08 .     " 8月余额
     itab-QNhsl09 = itab-qnhsl09 - itab2-qnhsl09 .     " 9月余额
     itab-QNhsl10 = itab-qnhsl10 - itab2-qnhsl10 .     " 10月余额
     itab-QNhsl11 = itab-qnhsl11 - itab2-qnhsl11 .     " 11月余额
     itab-QNhsl12 = itab-qnhsl12 - itab2-qnhsl12 .     " 12月余额
     itab-QNhsl13 = itab-qnhsl13 - itab2-qnhsl13 .     " 13月余额
     itab-QNhsl14 = itab-qnhsl14 - itab2-qnhsl14 .     " 14月余额
     itab-QNhsl15 = itab-qnhsl15 - itab2-qnhsl15 .     " 15月余额
     itab-QNhsl16 = itab-qnhsl16 - itab2-qnhsl16 .     " 16月余额
     COLLECT itab.
     CLEAR itab.
   ENDIF.

     "总销售收入
     CLEAR: sr_hsl01,sr_hsl02,sr_hsl03,sr_hsl04,sr_hsl05,sr_hsl06,sr_hsl07,sr_hsl08,sr_hsl09,sr_hsl10,sr_hsl11,sr_hsl12,sr_hsl13,sr_hsl14,sr_hsl15,sr_hsl16.
     sr_hsl01 = it_sy_qn-hsl01 .     " 1月余额
     sr_hsl02 = it_sy_qn-hsl02 .     " 2月余额
     sr_hsl03 = it_sy_qn-hsl03 .     " 3月余额
     sr_hsl04 = it_sy_qn-hsl04 .     " 4月余额
     sr_hsl05 = it_sy_qn-hsl05 .     " 5月余额
     sr_hsl06 = it_sy_qn-hsl06 .     " 6月余额
     sr_hsl07 = it_sy_qn-hsl07 .     " 7月余额
     sr_hsl08 = it_sy_qn-hsl08 .     " 8月余额
     sr_hsl09 = it_sy_qn-hsl09 .     " 9月余额
     sr_hsl10 = it_sy_qn-hsl10 .     " 10月余额
     sr_hsl11 = it_sy_qn-hsl11 .     " 11月余额
     sr_hsl12 = it_sy_qn-hsl12 .     " 12月余额
     sr_hsl13 = it_sy_qn-hsl13 .     " 13月余额
     sr_hsl14 = it_sy_qn-hsl14 .     " 14月余额
     sr_hsl15 = it_sy_qn-hsl15 .     " 15月余额
     sr_hsl16 = it_sy_qn-hsl16 .     " 16月余额
     itab-item = '040'.
     itab-text = '总销售收入'.
     itab-qnhsl01 = sr_hsl01.     " 1月余额
     itab-qnhsl02 = sr_hsl02.     " 2月余额
     itab-qnhsl03 = sr_hsl03.     " 3月余额
     itab-qnhsl04 = sr_hsl04.     " 4月余额
     itab-qnhsl05 = sr_hsl05.     " 5月余额
     itab-qnhsl06 = sr_hsl06.     " 6月余额
     itab-qnhsl07 = sr_hsl07.     " 7月余额
     itab-qnhsl08 = sr_hsl08.     " 8月余额
     itab-qnhsl09 = sr_hsl09.     " 9月余额
     itab-qnhsl10 = sr_hsl10.     " 10月余额
     itab-qnhsl11 = sr_hsl11.     " 11月余额
     itab-qnhsl12 = sr_hsl12.     " 12月余额
     itab-qnhsl13 = sr_hsl13.     " 13月余额
     itab-qnhsl14 = sr_hsl14.     " 14月余额
     itab-qnhsl15 = sr_hsl15.     " 15月余额
     itab-qnhsl16 = sr_hsl16.     " 16月余额
     COLLECT itab.
     CLEAR itab.

    WHEN '003'.
"1100保定逻辑不变，其他公司分开
    IF s_bukrs-low = '1100'.
    ELSE.
     itab-item = '022'.
     itab-text = '其他业务收入'.
     COLLECT itab.
     CLEAR itab.
    ENDIF.


    WHEN '006'."损益表006项目
"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
     itab-item = '023'.
     itab-text = '其他业务成本'.
     CLEAR: v_hsl01,v_hsl02,v_hsl03,v_hsl04,v_hsl05,v_hsl06,v_hsl07,v_hsl08,v_hsl09,v_hsl10,v_hsl11,v_hsl12,v_hsl13,v_hsl14,v_hsl15,v_hsl16.
     LOOP AT itab2 WHERE item = '002' OR item = '004' OR item = '006' OR item = '012' OR item = '014' OR item = '016'.
        v_hsl01 = v_hsl01 + itab2-qnhsl01 .     " 1月余额
        v_hsl02 = v_hsl02 + itab2-qnhsl02 .     " 2月余额
        v_hsl03 = v_hsl03 + itab2-qnhsl03 .     " 3月余额
        v_hsl04 = v_hsl04 + itab2-qnhsl04 .     " 4月余额
        v_hsl05 = v_hsl05 + itab2-qnhsl05 .     " 5月余额
        v_hsl06 = v_hsl06 + itab2-qnhsl06.     " 6月余额
        v_hsl07 = v_hsl07 + itab2-qnhsl07 .     " 7月余额
        v_hsl08 = v_hsl08 + itab2-qnhsl08 .     " 8月余额
        v_hsl09 = v_hsl09 + itab2-qnhsl09 .     " 9月余额
        v_hsl10 = v_hsl10 + itab2-qnhsl10 .     " 10月余额
        v_hsl11 = v_hsl11 + itab2-qnhsl11 .     " 11月余额
        v_hsl12 = v_hsl12 + itab2-qnhsl12 .     " 12月余额
        v_hsl13 = v_hsl13 + itab2-qnhsl13 .     " 13月余额
        v_hsl14 = v_hsl14 + itab2-qnhsl14 .     " 14月余额
        v_hsl15 = v_hsl15 + itab2-qnhsl15 .     " 15月余额
        v_hsl16 = v_hsl16 + itab2-qnhsl16 .     " 16月余额
     ENDLOOP.
     itab-qnhsl01 = -1 * ( itab-qnhsl01 - ( -1 ) * v_hsl01 ).     " 1月余额
     itab-qnhsl02 = -1 * ( itab-qnhsl02 - ( -1 ) * v_hsl02 ) .     " 2月余额
     itab-qnhsl03 = -1 * ( itab-qnhsl03 - ( -1 ) * v_hsl03 ) .     " 3月余额
     itab-qnhsl04 = -1 * ( itab-qnhsl04 - ( -1 ) * v_hsl04 ).     " 4月余额
     itab-qnhsl05 = -1 * ( itab-qnhsl05 - ( -1 ) * v_hsl05 ).     " 5月余额
     itab-qnhsl06 = -1 * ( itab-qnhsl06 - ( -1 ) * v_hsl06 ).     " 6月余额
     itab-qnhsl07 = -1 * ( itab-qnhsl07 - ( -1 ) * v_hsl07 ).     " 7月余额
     itab-qnhsl08 = -1 * ( itab-qnhsl08 - ( -1 ) * v_hsl08 ).     " 8月余额
     itab-qnhsl09 = -1 * ( itab-qnhsl09 - ( -1 ) * v_hsl09 ).     " 9月余额
     itab-qnhsl10 = -1 * ( itab-qnhsl10 - ( -1 ) * v_hsl10 ).     " 10月余额
     itab-qnhsl11 = -1 * ( itab-qnhsl11 - ( -1 ) * v_hsl11 ).     " 11月余额
     itab-qnhsl12 = -1 * ( itab-qnhsl12 - ( -1 ) * v_hsl12 ).     " 12月余额
     itab-qnhsl13 = -1 * ( itab-qnhsl13 - ( -1 ) * v_hsl13 ).     " 13月余额
     itab-qnhsl14 = -1 * ( itab-qnhsl14 - ( -1 ) * v_hsl14 ).     " 14月余额
     itab-qnhsl15 = -1 * ( itab-qnhsl15 - ( -1 ) * v_hsl15 ).     " 15月余额
     itab-qnhsl16 = -1 * ( itab-qnhsl16 - ( -1 ) * v_hsl16 ).     " 16月余额
     COLLECT itab.
     CLEAR itab.
     ENDIF.

    WHEN '008'."损益表008项目
"1100保定逻辑不变，其他公司分开
    IF s_bukrs-low = '1100'.
    ELSE.
     itab-item = '023'.
     itab-text = '其他业务成本'.
     itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
     itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
     itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
     itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
     itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
     itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
     itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
     itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
     itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
     itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
     itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
     itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
     itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
     itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
     itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
     itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
     COLLECT itab.
     CLEAR itab.
    ENDIF.

     WHEN '013'."损益表013项目管理费用
       itab-item = '028'.
       itab-text = '管理费用'.
       itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
       itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
       itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
       itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
       itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
       itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
       itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
       itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
       itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
       itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
       itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
       itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
       itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
       itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
       itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
       itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
       COLLECT itab.
       CLEAR itab.

      WHEN '012'."损益表012项目　　销售费用
        itab-item = '030'.
        itab-text = '销售费用'.
        READ TABLE itab2 WITH KEY item = '008'.
        itab-qnhsl01 = -1 * ( itab-qnhsl01 + itab2-qnhsl01 ) .     " 1月余额
        itab-qnhsl02 = -1 * ( itab-qnhsl02 + itab2-qnhsl02 ) .     " 2月余额
        itab-qnhsl03 = -1 * ( itab-qnhsl03 + itab2-qnhsl03 ).     " 3月余额
        itab-qnhsl04 = -1 * ( itab-qnhsl04 + itab2-qnhsl04 ) .     " 4月余额
        itab-qnhsl05 = -1 * ( itab-qnhsl05 + itab2-qnhsl05 ).     " 5月余额
        itab-qnhsl06 = -1 * ( itab-qnhsl06 + itab2-qnhsl06 ).     " 6月余额
        itab-qnhsl07 = -1 * ( itab-qnhsl07 + itab2-qnhsl07 ).     " 7月余额
        itab-qnhsl08 = -1 * ( itab-qnhsl08 + itab2-qnhsl08 ).     " 8月余额
        itab-qnhsl09 = -1 * ( itab-qnhsl09 + itab2-qnhsl09 ).     " 9月余额
        itab-qnhsl10 = -1 * ( itab-qnhsl10 + itab2-qnhsl10 ).     " 10月余额
        itab-qnhsl11 = -1 * ( itab-qnhsl11 + itab2-qnhsl11 ).     " 11月余额
        itab-qnhsl12 = -1 * ( itab-qnhsl12 + itab2-qnhsl12 ).     " 12月余额
        itab-qnhsl13 = -1 * ( itab-qnhsl13 + itab2-qnhsl13 ).     " 13月余额
        itab-qnhsl14 = -1 * ( itab-qnhsl14 + itab2-qnhsl14 ).     " 14月余额
        itab-qnhsl15 = -1 * ( itab-qnhsl15 + itab2-qnhsl15 ).     " 15月余额
        itab-qnhsl16 = -1 * ( itab-qnhsl16 + itab2-qnhsl16 ).     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '014'."损益表012项目　　研发费用
        itab-item = '032'.
        itab-text = '研发费用'.
        itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
        itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
        itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
        itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
        itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
        itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
        itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
        itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
        itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
        itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
        itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
        itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
        itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
        itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
        itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
        itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '011'."损益表011项目　　　税金及附加
        itab-item = '034'.
        itab-text = '税金及附加'.
        itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
        itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
        itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
        itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
        itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
        itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
        itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
        itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
        itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
        itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
        itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
        itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
        itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
        itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
        itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
        itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '016'."损益表016项目　　　　　资产减值损失
        itab-item = '036'.
        itab-text = '资产减值损失'.
        itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
        itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
        itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
        itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
        itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
        itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
        itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
        itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
        itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
        itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
        itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
        itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
        itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
        itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
        itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
        itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '017'."损益表017项目　　　　　信用减值损失
        itab-item = '038'.
        itab-text = '信用减值损失'.
        itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
        itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
        itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
        itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
        itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
        itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
        itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
        itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
        itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
        itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
        itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
        itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
        itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
        itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
        itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
        itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.

       WHEN '020'."损益表020项目　投资收益
        itab-item = '043'.
        itab-text = '投资收益'.
        COLLECT itab.
        CLEAR itab.
       WHEN '019'."损益表019项目　其他收益
        itab-item = '044'.
        itab-text = '其他收益'.
        COLLECT itab.
        CLEAR itab.
       WHEN '024'."损益表024项目　营业外收入
        itab-item = '451'.
        itab-text = '营业外收入'.
        COLLECT itab.
        CLEAR itab.
       WHEN '025'."损益表025项目　营业外支出
        itab-item = '452'.
        itab-text = '营业外支出'.
        COLLECT itab.
        CLEAR itab.
       WHEN '015'."损益表015项目　财务费用
        itab-item = '046'.
        itab-text = '财务费用'.
        itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
        itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
        itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
        itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
        itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
        itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
        itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
        itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
        itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
        itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
        itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
        itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
        itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
        itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
        itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
        itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.
       WHEN '027'."损益表027项目　所得税费用
        itab-item = '050'.
        itab-text = '所得税费用'.
        itab-qnhsl01 = -1 * itab-qnhsl01.     " 1月余额
        itab-qnhsl02 = -1 * itab-qnhsl02.     " 2月余额
        itab-qnhsl03 = -1 * itab-qnhsl03.     " 3月余额
        itab-qnhsl04 = -1 * itab-qnhsl04.     " 4月余额
        itab-qnhsl05 = -1 * itab-qnhsl05.     " 5月余额
        itab-qnhsl06 = -1 * itab-qnhsl06.     " 6月余额
        itab-qnhsl07 = -1 * itab-qnhsl07.     " 7月余额
        itab-qnhsl08 = -1 * itab-qnhsl08.     " 8月余额
        itab-qnhsl09 = -1 * itab-qnhsl09.     " 9月余额
        itab-qnhsl10 = -1 * itab-qnhsl10.     " 10月余额
        itab-qnhsl11 = -1 * itab-qnhsl11.     " 11月余额
        itab-qnhsl12 = -1 * itab-qnhsl12.     " 12月余额
        itab-qnhsl13 = -1 * itab-qnhsl13.     " 13月余额
        itab-qnhsl14 = -1 * itab-qnhsl14.     " 14月余额
        itab-qnhsl15 = -1 * itab-qnhsl15.     " 15月余额
        itab-qnhsl16 = -1 * itab-qnhsl16.     " 16月余额
        COLLECT itab.
        CLEAR itab.
   ENDCASE.

  ENDLOOP.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '002'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
   IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '003'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '004'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '005'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '006'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '007'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '008'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '009'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  LOOP AT itab2 WHERE item = '001' OR item = '002' OR item = '004' OR item = '006' OR item = '008'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '010'.
   itab-text = '边际贡献'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '010'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '011'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '012'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '013'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '014'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '015'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  READ TABLE itab2 WITH KEY item = '016'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
      IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '017'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
   LOOP AT itab2 WHERE item = '010' OR item = '012' OR item = '014' OR item = '016'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '020'.
   itab-text = '毛利'.
   COLLECT itab.
   CLEAR itab.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '020'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '001'.
     IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '021'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.



  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '022'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '023'.
   itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   itab-item = '024'.
   itab-text = '其他业务利润'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
"1100保定逻辑不变，其他公司分开
   IF s_bukrs-low = '1100'.
   LOOP AT itab2 WHERE item = '020' OR item = '024'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '026'.
   itab-text = '综合毛利'.
   COLLECT itab.
   CLEAR itab.
   ELSE.
    LOOP AT itab2 WHERE item = '020' OR item = '024'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   LOOP AT itab2 WHERE item = '008' .
     itab-qnhsl01 = itab-qnhsl01 - itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 - itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 - itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 - itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 - itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 - itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 - itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 - itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 - itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 - itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 - itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 - itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 - itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 - itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 - itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 - itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '026'.
   itab-text = '综合毛利'.
   COLLECT itab.
   CLEAR itab.
   ENDIF.

  CLEAR: itab2, itab2[].
  itab2[] = itab[].
  READ TABLE itab2 WITH KEY item = '451'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '452'.
   itab-qnhsl01 = itab-qnhsl01 - itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab-qnhsl02 - itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab-qnhsl03 - itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab-qnhsl04 - itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab-qnhsl05 - itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab-qnhsl06 - itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab-qnhsl07 - itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab-qnhsl08 - itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab-qnhsl09 - itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab-qnhsl10 - itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab-qnhsl11 - itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab-qnhsl12 - itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab-qnhsl13 - itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab-qnhsl14 - itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab-qnhsl15 - itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab-qnhsl16 - itab2-qnhsl16 .     " 16月余额
   itab-item = '045'.
   itab-text = '营业外损益'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   LOOP AT itab2 WHERE item = '020' OR item = '024' OR item = '028' OR item = '030' OR item = '032' OR item = '034' OR item = '036' OR item = '038'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '041'.
   itab-text = '经营利润'.
   COLLECT itab.
   CLEAR itab.

   itab-item = '047'.
   itab-text = '其他'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   LOOP AT itab2 WHERE item = '041' OR item = '043' OR item = '044' OR item = '045' OR item = '046' OR item = '047'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '048'.
   itab-text = '税前利润'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   LOOP AT itab2 WHERE item = '048' OR item = '050'.
     itab-qnhsl01 = itab-qnhsl01 + itab2-qnhsl01 .     " 1月余额
     itab-qnhsl02 = itab-qnhsl02 + itab2-qnhsl02 .     " 2月余额
     itab-qnhsl03 = itab-qnhsl03 + itab2-qnhsl03 .     " 3月余额
     itab-qnhsl04 = itab-qnhsl04 + itab2-qnhsl04 .     " 4月余额
     itab-qnhsl05 = itab-qnhsl05 + itab2-qnhsl05 .     " 5月余额
     itab-qnhsl06 = itab-qnhsl06 + itab2-qnhsl06.     " 6月余额
     itab-qnhsl07 = itab-qnhsl07 + itab2-qnhsl07 .     " 7月余额
     itab-qnhsl08 = itab-qnhsl08 + itab2-qnhsl08 .     " 8月余额
     itab-qnhsl09 = itab-qnhsl09 + itab2-qnhsl09 .     " 9月余额
     itab-qnhsl10 = itab-qnhsl10 + itab2-qnhsl10 .     " 10月余额
     itab-qnhsl11 = itab-qnhsl11 + itab2-qnhsl11 .     " 11月余额
     itab-qnhsl12 = itab-qnhsl12 + itab2-qnhsl12 .     " 12月余额
     itab-qnhsl13 = itab-qnhsl13 + itab2-qnhsl13 .     " 13月余额
     itab-qnhsl14 = itab-qnhsl14 + itab2-qnhsl14 .     " 14月余额
     itab-qnhsl15 = itab-qnhsl15 + itab2-qnhsl15 .     " 15月余额
     itab-qnhsl16 = itab-qnhsl16 + itab2-qnhsl16 .     " 16月余额
   ENDLOOP.
   itab-item = '051'.
   itab-text = '净利润'.
   COLLECT itab.
   CLEAR itab.

   CLEAR: itab2, itab2[].
   itab2[] = itab[].
   READ TABLE itab2 WITH KEY item = '024'.
   itab-qnhsl01 = itab2-qnhsl01 .     " 1月余额
   itab-qnhsl02 = itab2-qnhsl02 .     " 2月余额
   itab-qnhsl03 = itab2-qnhsl03 .     " 3月余额
   itab-qnhsl04 = itab2-qnhsl04 .     " 4月余额
   itab-qnhsl05 = itab2-qnhsl05 .     " 5月余额
   itab-qnhsl06 = itab2-qnhsl06 .     " 6月余额
   itab-qnhsl07 = itab2-qnhsl07 .     " 7月余额
   itab-qnhsl08 = itab2-qnhsl08 .     " 8月余额
   itab-qnhsl09 = itab2-qnhsl09 .     " 9月余额
   itab-qnhsl10 = itab2-qnhsl10 .     " 10月余额
   itab-qnhsl11 = itab2-qnhsl11 .     " 11月余额
   itab-qnhsl12 = itab2-qnhsl12 .     " 12月余额
   itab-qnhsl13 = itab2-qnhsl13 .     " 13月余额
   itab-qnhsl14 = itab2-qnhsl14 .     " 14月余额
   itab-qnhsl15 = itab2-qnhsl15 .     " 15月余额
   itab-qnhsl16 = itab2-qnhsl16 .     " 16月余额
  READ TABLE itab2 WITH KEY item = '022'.
     IF itab2-qnhsl01 <> 0.
   itab-qnhsl01 = itab-qnhsl01 / itab2-qnhsl01 * 100 .     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF itab2-qnhsl02 <> 0.
   itab-qnhsl02 = itab-qnhsl02 / itab2-qnhsl02 * 100 .     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF itab2-qnhsl03 <> 0.
   itab-qnhsl03 = itab-qnhsl03 / itab2-qnhsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF itab2-qnhsl04 <> 0.
   itab-qnhsl04 = itab-qnhsl04 / itab2-qnhsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF itab2-qnhsl05 <> 0.
   itab-qnhsl05 = itab-qnhsl05 / itab2-qnhsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF itab2-qnhsl06 <> 0.
   itab-qnhsl06 = itab-qnhsl06 / itab2-qnhsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF itab2-qnhsl07 <> 0.
   itab-qnhsl07 = itab-qnhsl07 / itab2-qnhsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF itab2-qnhsl08 <> 0.
   itab-qnhsl08 = itab-qnhsl08 / itab2-qnhsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF itab2-qnhsl09 <> 0.
   itab-qnhsl09 = itab-qnhsl09 / itab2-qnhsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF itab2-qnhsl10 <> 0.
   itab-qnhsl10 = itab-qnhsl10 / itab2-qnhsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF itab2-qnhsl11 <> 0.
   itab-qnhsl11 = itab-qnhsl11 / itab2-qnhsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF itab2-qnhsl12 <> 0.
   itab-qnhsl12 = itab-qnhsl12 / itab2-qnhsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF itab2-qnhsl13 <> 0.
   itab-qnhsl13 = itab-qnhsl13 / itab2-qnhsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF itab2-qnhsl14 <> 0.
   itab-qnhsl14 = itab-qnhsl14 / itab2-qnhsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF itab2-qnhsl15 <> 0.
   itab-qnhsl15 = itab-qnhsl15 / itab2-qnhsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF itab2-qnhsl16 <> 0.
   itab-qnhsl16 = itab-qnhsl16 / itab2-qnhsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '025'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '026'.
   IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '027'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '028'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '029'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '030'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '031'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '032'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '033'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '034'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '035'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '036'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '037'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '038'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '039'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '041'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '042'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '048'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '049'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

   READ TABLE itab2 WITH KEY item = '051'.
      IF sr_hsl01 <> 0.
   itab-qnhsl01 = itab2-qnhsl01 / sr_hsl01 * 100.     " 1月余额
   ELSE.
   itab-qnhsl01 = 0.
   ENDIF.
   IF sr_hsl02 <> 0.
   itab-qnhsl02 = itab2-qnhsl02 / sr_hsl02 * 100.     " 2月余额
   ELSE.
   itab-qnhsl02 = 0.
   ENDIF.
   IF sr_hsl03 <> 0.
   itab-qnhsl03 = itab2-qnhsl03 / sr_hsl03 * 100.     " 3月余额
   ELSE.
   itab-qnhsl03 = 0.
   ENDIF.
   IF sr_hsl04 <> 0.
   itab-qnhsl04 = itab2-qnhsl04 / sr_hsl04 * 100.     " 4月余额
   ELSE.
   itab-qnhsl04 = 0.
   ENDIF.
   IF sr_hsl05 <> 0.
   itab-qnhsl05 = itab2-qnhsl05 / sr_hsl05 * 100.     " 5月余额
   ELSE.
   itab-qnhsl05 = 0.
   ENDIF.
   IF sr_hsl06 <> 0.
   itab-qnhsl06 = itab2-qnhsl06 / sr_hsl06 * 100.     " 6月余额
   ELSE.
   itab-qnhsl06 = 0.
   ENDIF.
   IF sr_hsl07 <> 0.
   itab-qnhsl07 = itab2-qnhsl07 / sr_hsl07 * 100.     " 7月余额
   ELSE.
   itab-qnhsl07 = 0.
   ENDIF.
   IF sr_hsl08 <> 0.
   itab-qnhsl08 = itab2-qnhsl08 / sr_hsl08 * 100.     " 8月余额
   ELSE.
   itab-qnhsl08 = 0.
   ENDIF.
   IF sr_hsl09 <> 0.
   itab-qnhsl09 = itab2-qnhsl09 / sr_hsl09 * 100.     " 9月余额
   ELSE.
   itab-qnhsl09 = 0.
   ENDIF.
   IF sr_hsl10 <> 0.
   itab-qnhsl10 = itab2-qnhsl10 / sr_hsl10 * 100.     " 10月余额
   ELSE.
   itab-qnhsl10 = 0.
   ENDIF.
   IF sr_hsl11 <> 0.
   itab-qnhsl11 = itab2-qnhsl11 / sr_hsl11 * 100.     " 11月余额
   ELSE.
   itab-qnhsl11 = 0.
   ENDIF.
   IF sr_hsl12 <> 0.
   itab-qnhsl12 = itab2-qnhsl12 / sr_hsl12 * 100.     " 12月余额
   ELSE.
   itab-qnhsl12 = 0.
   ENDIF.
   IF sr_hsl13 <> 0.
   itab-qnhsl13 = itab2-qnhsl13 / sr_hsl13 * 100.     " 13月余额
   ELSE.
   itab-qnhsl13 = 0.
   ENDIF.
   IF sr_hsl14 <> 0.
   itab-qnhsl14 = itab2-qnhsl14 / sr_hsl14 * 100.     " 14月余额
   ELSE.
   itab-qnhsl14 = 0.
   ENDIF.
   IF sr_hsl15 <> 0.
   itab-qnhsl15 = itab2-qnhsl15 / sr_hsl15 * 100.     " 15月余额
   ELSE.
   itab-qnhsl15 = 0.
   ENDIF.
   IF sr_hsl16 <> 0.
   itab-qnhsl16 = itab2-qnhsl16 / sr_hsl16 * 100.     " 16月余额
   ELSE.
   itab-qnhsl16 = 0.
   ENDIF.
   itab-item = '052'.
   itab-text = '%'.
   COLLECT itab.
   CLEAR itab.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  frm_display_alv
*&---------------------------------------------------------------------*
*      展示ALV
*----------------------------------------------------------------------*
FORM frm_display_alv.
  DATA:gv_program  TYPE string.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-info_fieldname = 'COLOR'.

  MOVE 'TOP_OF_PAGE' TO ls_event-name.
  MOVE 'TOP_OF_PAGE' TO ls_event-form.
  APPEND ls_event TO gt_events.

  MOVE 'PF_STATUS_SET' TO ls_event-name.
  MOVE 'PF_STATUS_SET' TO ls_event-form.
  APPEND ls_event TO gt_events.

*  CLEAR ls_event.
*  MOVE 'USER_COMMAND' TO ls_event-name.
*  MOVE 'USER_COMMAND' TO ls_event-form.
*  APPEND ls_event TO gt_events.

*&---设置字段目录的子例程
  PERFORM frm_set_fieldcat.

  PERFORM data_process_new.

  IMPORT gv_program FROM MEMORY ID 'ZCALL_PROGRAM'.
  IF gv_program = 'ZFID012_D' .
    cl_salv_bs_runtime_info=>set(
      EXPORTING display  = abap_false
                metadata = abap_false
                data     = abap_true ).
    FREE MEMORY ID 'ZCALL_PROGRAM'.
    EXPORT itab TO MEMORY ID 'ZFID012_D'.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'  "statt LIST
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      it_events          = gt_events
      i_save             = 'A'  " Anzeigevarianten
    TABLES
      t_outtab           = itab
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.


ENDFORM. "frm_display_alv
*&---------------------------------------------------------------------*
*&      Form  frm_set_fieldcat
*&---------------------------------------------------------------------*
*       设置字段目录的子例程
*----------------------------------------------------------------------*
FORM frm_set_fieldcat.
  DATA: lv_fieldname(10) TYPE c,
        lv_ltx(20)      TYPE c.
  fillfiedcat 'TEXT' '项目' '' .
  SORT it_month_qn BY month.
  LOOP AT it_month_qn.
    CLEAR: lv_fieldname,
           lv_ltx.
    CONCATENATE 'QNHSL' it_month_qn-month+1(2) INTO lv_fieldname.
    CONCATENATE it_month_qn-year '.' it_month_qn-month+1(2) INTO lv_ltx.
    fillfiedcat lv_fieldname lv_ltx 'X' .

    CLEAR: lv_fieldname,
           lv_ltx.
    CONCATENATE 'HSL' it_month_qn-month+1(2) INTO lv_fieldname.
    READ TABLE it_month WITH KEY month = it_month_qn-month.
    CONCATENATE it_month-year '.' it_month-month+1(2) INTO lv_ltx.
    fillfiedcat lv_fieldname lv_ltx 'X' .
  ENDLOOP.
  fillfiedcat 'QNHJ' '累计' 'X'.
  fillfiedcat 'JNHJ' '累计' 'X'.

ENDFORM. "frm_set_fieldcat
*&---------------------------------------------------------------------*
*&      Form  pf_status_set
*&---------------------------------------------------------------------*
*      ALV工具栏状态
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS '1000' .
ENDFORM. "pf_status_set
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*      设置ALV表头
*----------------------------------------------------------------------*
FORM top_of_page.
  DATA: gt_header TYPE slis_t_listheader,       " 表头的内表
        wa_header TYPE slis_listheader,         " 表头的工作区
        l_num     TYPE i,
        lv_txt    TYPE string,                  " 公司编号+公司描述的文本
        lv_waers  TYPE string.

  wa_header-typ  = 'H'.
  wa_header-info = '产品损益表'.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.
  DESCRIBE TABLE it_t001 LINES l_num.

  wa_header-typ  = 'S'.
  wa_header-key  = '编制单位:'.
  l_num = lines( it_t001 ).

  IF l_num = 1.
    READ TABLE it_t001 INDEX 1.
    CONCATENATE it_t001-bukrs '-' it_t001-butxt INTO lv_txt.
    wa_header-info = lv_txt.
  ELSE.
    wa_header-info = '*'.
  ENDIF.

  CLEAR lv_txt.
  APPEND wa_header TO gt_header.

  SELECT SINGLE  ltext
    INTO lv_waers
    FROM t001
    INNER JOIN tcurt
    ON t001~waers = tcurt~waers
    WHERE bukrs IN s_bukrs
      AND tcurt~spras = sy-langu.
  wa_header-typ  = 'S'.
  wa_header-key  = '币种:'.
  wa_header-info = lv_waers.
  APPEND wa_header TO gt_header.
  CLEAR wa_header.

  IF p_wy = 'X'.
    wa_header-typ  = 'S'.
    wa_header-key  = '单位:'.
    wa_header-info = '万元'.
    APPEND wa_header TO gt_header.
    CLEAR wa_header.
  ENDIF.


*&---调用函数显示表单标题
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_header
      i_logo             = ''.

ENDFORM. "top_of_page
*&---------------------------------------------------------------------*
*& Form data_process_new
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
FORM data_process_new.

DATA: s_amount LIKE itab-hsl01,
      d_amount LIKE itab-hsl01,
      sqn_amount LIKE itab-hsl01,
      dqn_amount LIKE itab-hsl01,
      bfb LIKE itab-hsl01,
      bfb_qn LIKE itab-hsl01.

FIELD-SYMBOLS: <fs> TYPE any.                 " 字段符号1
DATA: lv_text(19)  TYPE c.   " 文本1
DATA: lv_month LIKE faglflext-rpmax.

  LOOP AT itab.
    IF itab-text = '%'.
    ELSE.
    itab-jnhj = itab-hsl01 + itab-hsl02 + itab-hsl03 + itab-hsl04 + itab-hsl05 + itab-hsl06 + itab-hsl07 + itab-hsl08 + itab-hsl09
              + itab-hsl10 + itab-hsl11 + itab-hsl12 + itab-hsl13 + itab-hsl14 + itab-hsl15 + itab-hsl16.

    itab-qnhj = itab-qnhsl01 + itab-qnhsl02 + itab-qnhsl03 + itab-qnhsl04 + itab-qnhsl05 + itab-qnhsl06 + itab-qnhsl07 + itab-qnhsl08 + itab-qnhsl09
              + itab-qnhsl10 + itab-qnhsl11 + itab-qnhsl12 + itab-qnhsl13 + itab-qnhsl14 + itab-qnhsl15 + itab-qnhsl16.
    ENDIF.
    MODIFY itab.
    CLEAR itab.
  ENDLOOP.
  DELETE itab WHERE item = '451'.
  DELETE itab WHERE item = '452'.
  SORT itab BY item.

"=材料成本/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '002'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '003'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=直接人工/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '004'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '005'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=电费/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '006'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '007'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=运费/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '008'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '009'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=边际贡献/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '010'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '011'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=间接人工/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '012'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '013'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=折旧/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '014'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '015'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=制造费用/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '016'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '017'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=毛利/产品销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '001'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '020'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '021'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=其他业务利润/其他业务收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '022'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '024'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '025'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=综合毛利/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '026'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '027'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=管理费用/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '028'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '029'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=销售费用/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '030'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '031'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"研发费用/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '032'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '033'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=税金及附加/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '034'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '035'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=资产减值损失/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '036'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '037'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=信用减值损失/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '038'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '039'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=经营利润/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '041'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '042'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=税前利润/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '048'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '049'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

"=净利润/总销售收入
  CLEAR: s_amount, d_amount, sqn_amount, dqn_amount, bfb, bfb_qn.
  READ TABLE itab WITH KEY item = '040'.
  s_amount = itab-jnhj.
  sqn_amount = itab-qnhj.
  READ TABLE itab WITH KEY item = '051'.
  d_amount = itab-jnhj.
  dqn_amount = itab-qnhj.
  IF s_amount <> 0.
  bfb = d_amount / s_amount * 100.
  ENDIF.
  IF sqn_amount <> 0.
  bfb_qn = dqn_amount / sqn_amount * 100.
  ENDIF.
  LOOP AT itab WHERE item = '052'.
  itab-jnhj = bfb.
  itab-qnhj = bfb_qn.
  MODIFY itab.
  CLEAR itab.
  ENDLOOP.

  IF p_wy = 'X'.
    LOOP AT itab WHERE text <> '%'.
      CLEAR : lv_month, lv_text.
      DO 16 TIMES.
        lv_month = lv_month + 1.
        CONCATENATE 'ITAB-HSL' lv_month+1(2) INTO lv_text.
        ASSIGN (lv_text) TO <fs>.
        <fs> = <fs> / 10000.
      ENDDO.
      CLEAR : lv_month, lv_text.
      DO 16 TIMES.
        lv_month = lv_month + 1.
        CONCATENATE 'ITAB-QNHSL' lv_month+1(2) INTO lv_text.
        ASSIGN (lv_text) TO <fs>.
        <fs> = <fs> / 10000.
      ENDDO.
      itab-jnhj = itab-jnhj / 10000.
      itab-qnhj = itab-qnhj / 10000.
      MODIFY itab.
      CLEAR itab.
    ENDLOOP.
  ENDIF.
ENDFORM.
