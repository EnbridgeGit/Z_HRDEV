*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_ROUTINES
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_ROUTINES
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_CATSDB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_catsdb_data .
  REFRESH git_catsdb.
  IF git_pernr IS NOT INITIAL.

    IF p_upd IS INITIAL.

      SELECT * FROM catsdb
      INTO TABLE git_catsdb
      FOR ALL ENTRIES IN git_pernr
      WHERE pernr = git_pernr-pernr
      AND   laeda GE pn-begda
      AND   laeda LE pn-endda.
*    AND   laetm LE sy-uzeit.

    ELSE.
      CLEAR gwa_zhr_catsdb_dt. " SKAPSE 07/16/2012.
      READ TABLE git_zhr_catsdb_dt INTO gwa_zhr_catsdb_dt INDEX 1.
      IF sy-subrc = 0.
*    SELECT * FROM catsdb
*    INTO TABLE git_catsdb
*    FOR ALL ENTRIES IN git_pernr
*    WHERE pernr = git_pernr-pernr
**    AND   laeda BETWEEN  gwa_zhr_catsdb_dt-zzlastrundt AND sy-datum
**    AND   laetm BETWEEN  gwa_zhr_catsdb_dt-zzlastruntm AND sy-uzeit .
*    AND   laeda >= gwa_zhr_catsdb_dt-zzlastrundt
*    AND   laeda <= sy-datum
*    AND   laetm >= '000000'."gwa_zhr_catsdb_dt-zzlastruntm.
**        gwa_zhr_catsdb_dt-zzlastruntm = gwa_zhr_catsdb_dt-zzlastruntm " SKAPSE 07/16/2012.
**        - 3000 .                                                      " SKAPSE 07/16/2012.
        SELECT * FROM catsdb INTO TABLE git_catsdb
        FOR ALL ENTRIES IN git_pernr
        WHERE pernr = git_pernr-pernr
        AND laeda >= gwa_zhr_catsdb_dt-zzlastrundt
        AND laeda <= pn-endda.
        "AND laetm >= gwa_zhr_catsdb_dt-zzlastruntm." SKAPSE 07/16/2012.
*        SELECT * FROM catsdb
*        INTO TABLE git_catsdb
*        FOR ALL ENTRIES IN git_pernr
*        WHERE pernr = git_pernr-pernr
*        AND ( ( laeda = gwa_zhr_catsdb_dt-zzlastrundt
*        AND   laetm >= gwa_zhr_catsdb_dt-zzlastruntm )
*         OR  laeda <= pn-endda )." gwa_zhr_catsdb_dt-zzlastrundt ).
*    AND   laetm <= sy-uzeit .

      ELSE.
        SELECT * FROM catsdb
        INTO TABLE git_catsdb
        FOR ALL ENTRIES IN git_pernr
        WHERE pernr = git_pernr-pernr.
*    AND   laeda LE sy-datum
*    AND   laetm LE sy-uzeit.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_CATSDB_DATA
*&---------------------------------------------------------------------*
*&      Form  POPULATE_PERNR_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_pernr_table .
  gwa_pernr-pernr = pernr-pernr.
  APPEND gwa_pernr-pernr TO git_pernr.
  CLEAR gwa_pernr.
ENDFORM.                    " POPULATE_PERNR_TABLE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZHR_CATSDB_DT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_zhr_catsdb_dt .
  SELECT * FROM   zhr_catsdb_dt
  INTO TABLE git_zhr_catsdb_dt.

  gv_date = pn-begda."sy-datum.
  "  gv_time = sy-uzeit.

  "SELECT * FROM ptex2000 INTO TABLE git_ptex2000fi.
ENDFORM.                    " GET_DATA_ZHR_CATSDB_DT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_CATSDB_HR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_catsdb_hr .
  PERFORM get_data_prps. "Changes by SK

  gv_dest = p_dest.
  CALL FUNCTION 'ZHR_UPDATE_CATSDBHR' DESTINATION gv_dest "'DHRCLNT200'
    TABLES
      git_catsdbfi   = git_catsdb_final
      git_catsdbhr   = git_catsdb_error
      git_wbs_fi     = git_wbs_fi
      git_wbs_hr     = git_wbs_hr
      git_ptex2000fi = git_ptex2000fi
      git_ptex2000hr = git_ptex2000hr
  EXCEPTIONS
    ex_error_file = 1
    ex_success_file = 1
    OTHERS = 3.

  IF sy-subrc <> 1.
    gv_flag = 'X'.
  ELSE.
*    WRITE 'error'.
    EXIT.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM git_catsdb_final COMPARING ALL FIELDS.
  DELETE ADJACENT DUPLICATES FROM git_catsdb_error COMPARING ALL
FIELDS.

ENDFORM.                    " UPDATE_CATSDB_HR
*&---------------------------------------------------------------------*
*&      Form  CLOSE_CONNECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM close_connection .
  CALL FUNCTION 'RFC_CONNECTION_CLOSE'
    EXPORTING
      destination          = gv_dest "'DHRCLNT200'
*     TASKNAME             =
    EXCEPTIONS
      destination_not_open = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " CLOSE_CONNECTION
*&---------------------------------------------------------------------*
*&      Form  UPDAT_ZHR_CATSDB_DT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM updat_zhr_catsdb_dt .
  gv_date = pn-begda."sy-datum.
  "gv_time = sy-uzeit.
  IF p_upd = 'X'.
    IF git_catsdb_error IS INITIAL AND gv_flag = 'X'.
      gwa_zhr_catsdb_dt-zzinterface = sy-repid.
      gwa_zhr_catsdb_dt-zzlastrundt = gv_date.
      gwa_zhr_catsdb_dt-zzlastruntm =  space. "'00:00:00'."gv_time.
      MODIFY zhr_catsdb_dt FROM gwa_zhr_catsdb_dt.
    ENDIF.
  ENDIF.
ENDFORM.                    " UPDAT_ZHR_CATSDB_DT
*&---------------------------------------------------------------------*
*&      Form  CONTROL_TOTAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM control_total .
  DATA:lv_total TYPE i,
       lv_success TYPE i,
       lv_error TYPE i,
       git_msg  TYPE srm_t_solisti1,
       gwa_msg   TYPE char300.
  CLEAR :git_msg,gwa_msg.

  DESCRIBE TABLE git_catsdb LINES lv_total.
  DESCRIBE TABLE git_catsdb_error LINES lv_error.
  IF lv_total IS NOT INITIAL .
    lv_success = lv_total - lv_error.
  ENDIF.

  gwa_msg+0(11) = text-z01.
  gwa_msg+11(30)  = sy-sysid.
  gwa_msg+65(10) = text-z02.
  gwa_msg+76(15)  = sy-uname.
  gwa_msg+105(9) = text-z03.
  gwa_msg+114(15) = 1 ."sy-pagno.
  APPEND gwa_msg TO git_msg.
  CLEAR gwa_msg.

  gwa_msg+0(11) = text-z04.
  gwa_msg+12(30) = sy-repid.
  gwa_msg+65(9) = text-z05.
  WRITE sy-datum DD/MM/YYYY TO gwa_msg+75(15).
*  gwa_msg+75(15) = sy-datum.
  gwa_msg+105(9) = text-z06.
  WRITE sy-uzeit USING EDIT MASK '__:__:__' TO gwa_msg+115(15).
*  gwa_msg+114(15) = sy-uzeit.
  CONDENSE gwa_msg+164(15).
  APPEND gwa_msg TO git_msg.
  CLEAR gwa_msg.
  APPEND gwa_msg TO git_msg.

  gwa_msg+0(65) = text-z16.
  gwa_msg+65(14) = text-z13.
  gwa_msg+79(65) = text-z16.
  APPEND gwa_msg TO git_msg.
  CLEAR gwa_msg.

  gwa_msg+0(20) = text-z07.
  gwa_msg+20(10) = lv_total.
  gwa_msg+65(10) = text-z21.
  gwa_msg+75(10) = lv_error.
*  gwa_msg+65(10) = text-z27.
*  gwa_msg+75(10) = lv_success.
  APPEND gwa_msg TO git_msg.
  CLEAR gwa_msg.

  IF git_catsdb_error IS NOT INITIAL.
    gwa_msg+0(20)  = text-z26.
    CONCATENATE text-t01  sy-datum '_' sy-uzeit '.TXT'
    INTO    gwa_msg+20(100).
    APPEND gwa_msg TO git_msg.
    CLEAR gwa_msg.

  ENDIF.
  LOOP AT git_msg INTO gwa_msg.
    WRITE /  gwa_msg.
  ENDLOOP.

*  APPEND INITIAL LINE TO git_msg.
*  APPEND INITIAL LINE TO git_msg.
  REFRESH git_msg.
  CLEAR gwa_msg.
  SORT git_catsdb_final ASCENDING.
  IF  git_catsdb_final IS NOT INITIAL.
*    SKIP 1.
    gwa_msg+0(65) = text-z16.
    gwa_msg+65(18) = text-z29.
    gwa_msg+83(65) = text-z16.
    APPEND gwa_msg TO git_msg.
    CLEAR gwa_msg.
    SKIP 1.
*    gwa_msg+0(15)   = text-m01 .
*    gwa_msg+15(11) = text-m02  .
*    gwa_msg+26(11) = text-m03  .
*    gwa_msg+37(7)   = text-m04 .
*    gwa_msg+43(7)   = text-m05 .
*    gwa_msg+50(13) = text-m06  .
*    gwa_msg+63(13)   = text-m07 .
*    gwa_msg+76(13)   = text-m08 .
*    gwa_msg+89(13)   = text-m09 .
*    gwa_msg+102(13)   = text-m10 .
*    gwa_msg+115(13)   = text-m11 .
*    gwa_msg+128(5)    = text-m12 .
*    gwa_msg+133(15)   = text-m13 .
*    gwa_msg+148(7)   = text-m14  .

    gwa_msg+0(15)   = text-q01  .
    gwa_msg+15(15)  = text-q02  .
    gwa_msg+30(15)  = text-q03  .
    gwa_msg+45(15)  = text-q04  .
    gwa_msg+60(15)  = text-q05  .
    gwa_msg+75(15)  = text-q06  .
    gwa_msg+90(15)  = text-q07  .
    gwa_msg+105(15) = text-q08  .
    gwa_msg+120(15) = text-q09  .
    gwa_msg+135(15) = text-q10  .
    gwa_msg+150(15) = text-q11  .
    gwa_msg+165(15) = text-q12  .
    gwa_msg+180(15) = text-q13  .
    gwa_msg+195(15) = text-q14  .
    gwa_msg+210(15) = text-q15  .
    APPEND gwa_msg TO git_msg.
    CLEAR gwa_msg.
    SKIP 1.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM git_catsdb_final COMPARING ALL FIELDS.

  LOOP AT git_catsdb_final INTO gwa_catsdb.
*    gwa_msg+0(15)      = gwa_catsdb-counter.
*    gwa_msg+15(11)    = gwa_catsdb-pernr.
*    gwa_msg+26(11)    = gwa_catsdb-rproj.
*    gwa_msg+37(7)      = gwa_catsdb-awart.
*    gwa_msg+43(7)      = gwa_catsdb-lgart.
*    gwa_msg+50(13)    = gwa_catsdb-workdate.
*    gwa_msg+63(13)    = gwa_catsdb-ersda.
*    gwa_msg+76(13)    = gwa_catsdb-erstm.
*    gwa_msg+89(13)    = gwa_catsdb-laeda.
*    gwa_msg+102(13)    = gwa_catsdb-laetm.
*    gwa_msg+115(13)    = gwa_catsdb-apdat.
*    gwa_msg+128(5)    = gwa_catsdb-status.
*    gwa_msg+133(15)    = gwa_catsdb-refcounter.
*    gwa_msg+148(7)    = gwa_catsdb-catshours.

    gwa_msg+0(15)   =   gwa_catsdb-counter  .
    gwa_msg+15(15)  =   gwa_catsdb-pernr  .
    gwa_msg+30(15)  =   gwa_catsdb-workdate .
    gwa_msg+45(15)  =   gwa_catsdb-rkostl .
    gwa_msg+60(15)  =   gwa_catsdb-rproj  .
    gwa_msg+75(15)  =   gwa_catsdb-awart  .
    gwa_msg+90(15)  =   gwa_catsdb-lgart  .
    gwa_msg+105(15) =   gwa_catsdb-ersda  .
    gwa_msg+120(15) =   gwa_catsdb-erstm  .
    gwa_msg+135(15) =   gwa_catsdb-laeda  .
    gwa_msg+150(15) =   gwa_catsdb-laetm  .
    gwa_msg+165(15) =   gwa_catsdb-status .
    gwa_msg+180(15) =   gwa_catsdb-refcounter .
    gwa_msg+195(15) =   gwa_catsdb-belnr  .
    gwa_msg+210(15) =   gwa_catsdb-catshours  .
    APPEND gwa_msg TO git_msg.
    CLEAR gwa_msg.
*    WRITE:/
*    gwa_catsdb-counter,
*    gwa_catsdb-pernr,
*    gwa_catsdb-rproj,
*    gwa_catsdb-awart,
*    gwa_catsdb-lgart,
*    gwa_catsdb-workdate,
*    gwa_catsdb-ersda,
*    gwa_catsdb-erstm,
*    gwa_catsdb-laeda,
*    gwa_catsdb-laetm,
*    gwa_catsdb-apdat,
*    gwa_catsdb-status,
*    gwa_catsdb-refcounter,
*    gwa_catsdb-catshours.
  ENDLOOP.

  LOOP AT git_msg INTO gwa_msg.
    WRITE /  gwa_msg.
  ENDLOOP.

  REFRESH git_msg.
ENDFORM.                    " CONTROL_TOTAL
*&---------------------------------------------------------------------*
*&      Form  GET_CHANGED_CATSDB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_changed_catsdb .
  IF git_pernr IS NOT INITIAL.
    SELECT * FROM catsdb INTO TABLE git_catsdb1
    FOR ALL ENTRIES IN git_pernr
    WHERE pernr = git_pernr-pernr.
  ENDIF.

  LOOP AT git_catsdb INTO gwa_catsdb
    WHERE refcounter IS NOT INITIAL.
    READ TABLE git_catsdb1 INTO gwa_catsdb1 WITH KEY
    counter = gwa_catsdb-refcounter.
    IF sy-subrc = 0.
      APPEND gwa_catsdb1 TO git_catsdb2.
    ENDIF.
  ENDLOOP.
  APPEND LINES OF git_catsdb TO git_catsdb_final.
  APPEND LINES OF git_catsdb2 TO git_catsdb_final.
ENDFORM.                    " GET_CHANGED_CATSDB
*&---------------------------------------------------------------------*
*&      Form  CLEAR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_data .
  REFRESH:git_catsdb,
    git_catsdb1,
    git_catsdb2,
    git_catsdb_final,
    git_catsdb_error,
    git_ptex2000fi,
    git_ptex2000hr,
    git_pernr,
    git_zhr_catsdb_dt.
ENDFORM.                    " CLEAR_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PTEXTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_ptextable .
  REFRESH git_ptex2000fi.

  SELECT * FROM ptex2000 INTO TABLE git_ptex2000fi FOR ALL ENTRIES IN git_pernr

       WHERE pernr = git_pernr-pernr
       AND (    datum1 GE gv_date
             OR datum2 GE gv_date
             OR datum3 GE gv_date
             OR datum4 GE gv_date ).

  "AND begda >= gv_date. " SKAPSE 06/25/2012 " Retroactive time .


ENDFORM.                    " GET_DATA_PTEXTABLE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PRPS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_prps .
  SELECT pspnr posid poski INTO TABLE git_wbs_fi FROM prps
      FOR ALL ENTRIES IN git_catsdb_final WHERE  pspnr = git_catsdb_final-rproj.

ENDFORM.                    " GET_DATA_PRPS
