*&---------------------------------------------------------------------*
*&  Include           ZHTMI008_CATSDBFI_CATSDBHR_SUB
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_CATSDB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CATSDB_DATA .

  FIELD-SYMBOLS: <CATSDB> LIKE LINE OF GIT_CATSDB.  "MZH01

  REFRESH GIT_CATSDB.
  IF GIT_PERNR IS NOT INITIAL.

    IF P_UPD IS INITIAL.
      SELECT * FROM CATSDB
      INTO TABLE GIT_CATSDB
      FOR ALL ENTRIES IN GIT_PERNR
      WHERE PERNR = GIT_PERNR-PERNR
      AND   LAEDA GE PN-BEGDA
      AND   LAEDA LE PN-ENDDA.
    ELSE.
      READ TABLE GIT_ZHR_CATSDB_DT INTO GWA_ZHR_CATSDB_DT INDEX 1.
      IF SY-SUBRC = 0.
        SELECT * FROM CATSDB INTO TABLE GIT_CATSDB
          FOR ALL ENTRIES IN GIT_PERNR
          WHERE PERNR = GIT_PERNR-PERNR
          AND LAEDA >= GWA_ZHR_CATSDB_DT-ZZLASTRUNDT
          AND LAEDA <= PN-ENDDA.
      ELSE.
        SELECT * FROM CATSDB
        INTO TABLE GIT_CATSDB
        FOR ALL ENTRIES IN GIT_PERNR
        WHERE PERNR = GIT_PERNR-PERNR.
      ENDIF.
    ENDIF.
  ENDIF.

* Begin of changes MZH01
  LOOP AT GIT_CATSDB ASSIGNING <CATSDB>.
    CLEAR <CATSDB>-ARBID.
  ENDLOOP.
* End of changes MZH01


ENDFORM.                    " GET_CATSDB_DATA
*&---------------------------------------------------------------------*
*&      Form  POPULATE_PERNR_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM POPULATE_PERNR_TABLE .
  GWA_PERNR-PERNR = PERNR-PERNR.
  APPEND GWA_PERNR-PERNR TO GIT_PERNR.
  CLEAR GWA_PERNR.
ENDFORM.                    " POPULATE_PERNR_TABLE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ZHR_CATSDB_DT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_ZHR_CATSDB_DT .
  SELECT * FROM   ZHR_CATSDB_DT
  INTO TABLE GIT_ZHR_CATSDB_DT.
  IF SY-SUBRC = 0.
    READ TABLE GIT_ZHR_CATSDB_DT INTO GWA_ZHR_CATSDB_DT INDEX 1.
    IF SY-SUBRC = 0.
      GV_DATE = GWA_ZHR_CATSDB_DT-ZZLASTRUNDT.
    ENDIF.
  ELSE.
    GV_DATE = PN-BEGDA."sy-datum.
    GV_TIME = SY-UZEIT.
  ENDIF.


ENDFORM.                    " GET_DATA_ZHR_CATSDB_DT
*&---------------------------------------------------------------------*
*&      Form  UPDATE_CATSDB_HR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_CATSDB_HR .

  PERFORM GET_DATA_PRPS.

  SORT GIT_CATSDB_FINAL BY PERNR ASCENDING.
  SORT GIT_PTEX2000FI   BY AWKEY ASCENDING.
  SORT GIT_PTEX2010FI   BY AWKEY ASCENDING.
  SORT GIT_WBS_FI       BY PNPNR ASCENDING.

  GV_DEST = P_DEST.
  CALL FUNCTION 'ZHR_UPDATE_CATSDBHR_UGL' DESTINATION GV_DEST
    TABLES
      GIT_CATSDBFI             = GIT_CATSDB_FINAL
      GIT_CATSDBHR             = GIT_CATSDB_ERROR
      GIT_WBS_FI               = GIT_WBS_FI
      GIT_WBS_HR               = GIT_WBS_HR
      GIT_PTEX2000FI           = GIT_PTEX2000FI
      GIT_PTEX2000HR           = GIT_PTEX2000HR
      GIT_PTEX2010FI           = GIT_PTEX2010FI
      GIT_PTEX2010HR           = GIT_PTEX2010HR
    EXCEPTIONS
      EX_SUCCESS_FILE          = 1
      EX_ERROR_FILE            = 2
      EX_SYSTEM_FAILURE        = 3
      EX_COMMUNICATION_FAILURE = 4.
*    others = 3.

  IF SY-SUBRC = 0.
    GV_FLAG = 'X'.
  ELSE.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.


    EXIT.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM GIT_CATSDB_FINAL COMPARING ALL FIELDS.
  DELETE ADJACENT DUPLICATES FROM GIT_CATSDB_ERROR COMPARING ALL
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
FORM CLOSE_CONNECTION .
  CALL FUNCTION 'RFC_CONNECTION_CLOSE'
    EXPORTING
      DESTINATION          = GV_DEST "'DHRCLNT200'
*     TASKNAME             =
    EXCEPTIONS
      DESTINATION_NOT_OPEN = 1
      OTHERS               = 2.
  IF SY-SUBRC <> 0.
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
FORM UPDAT_ZHR_CATSDB_DT .
*  gv_date = pn-begda."sy-datum.
*  gv_time = sy-uzeit.
  IF P_UPD = 'X'.
    IF GIT_CATSDB_ERROR IS INITIAL AND GV_FLAG = 'X'.
      GWA_ZHR_CATSDB_DT-ZZINTERFACE = SY-REPID.
      GWA_ZHR_CATSDB_DT-ZZLASTRUNDT = SY-DATUM.
      GWA_ZHR_CATSDB_DT-ZZLASTRUNTM = SY-UZEIT.
      MODIFY ZHR_CATSDB_DT FROM GWA_ZHR_CATSDB_DT.
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
FORM CONTROL_TOTAL .
  DATA:LV_TOTAL TYPE I,
       LV_SUCCESS TYPE I,
       LV_ERROR TYPE I,
       GIT_MSG  TYPE SRM_T_SOLISTI1,
       GWA_MSG   TYPE CHAR300.
  CLEAR :GIT_MSG,GWA_MSG.

  DESCRIBE TABLE GIT_CATSDB LINES LV_TOTAL.
  DESCRIBE TABLE GIT_CATSDB_ERROR LINES LV_ERROR.
  IF LV_TOTAL IS NOT INITIAL .
    LV_SUCCESS = LV_TOTAL - LV_ERROR.
  ENDIF.

  GWA_MSG+0(11) = TEXT-Z01.
  GWA_MSG+11(30)  = SY-SYSID.
  GWA_MSG+65(10) = TEXT-Z02.
  GWA_MSG+76(15)  = SY-UNAME.
  GWA_MSG+105(9) = TEXT-Z03.
  GWA_MSG+114(15) = 1 ."sy-pagno.
  APPEND GWA_MSG TO GIT_MSG.
  CLEAR GWA_MSG.

  GWA_MSG+0(11) = TEXT-Z04.
  GWA_MSG+12(30) = SY-REPID.
  GWA_MSG+65(9) = TEXT-Z05.
  WRITE SY-DATUM DD/MM/YYYY TO GWA_MSG+75(15).
*  gwa_msg+75(15) = sy-datum.
  GWA_MSG+105(9) = TEXT-Z06.
  WRITE SY-UZEIT USING EDIT MASK '__:__:__' TO GWA_MSG+115(15).
*  gwa_msg+114(15) = sy-uzeit.
  CONDENSE GWA_MSG+164(15).
  APPEND GWA_MSG TO GIT_MSG.
  CLEAR GWA_MSG.
  APPEND GWA_MSG TO GIT_MSG.

  GWA_MSG+0(65) = TEXT-Z16.
  GWA_MSG+65(14) = TEXT-Z13.
  GWA_MSG+79(65) = TEXT-Z16.
  APPEND GWA_MSG TO GIT_MSG.
  CLEAR GWA_MSG.

  GWA_MSG+0(20) = TEXT-Z07.
  GWA_MSG+20(10) = LV_TOTAL.
  GWA_MSG+65(10) = TEXT-Z21.
  GWA_MSG+75(10) = LV_ERROR.
*  gwa_msg+65(10) = text-z27.
*  gwa_msg+75(10) = lv_success.
  APPEND GWA_MSG TO GIT_MSG.
  CLEAR GWA_MSG.

  IF GIT_CATSDB_ERROR IS NOT INITIAL.
    GWA_MSG+0(20)  = TEXT-Z26.
    CONCATENATE TEXT-T01  SY-DATUM '_' SY-UZEIT '.TXT'
    INTO    GWA_MSG+20(100).
    APPEND GWA_MSG TO GIT_MSG.
    CLEAR GWA_MSG.

  ENDIF.
  LOOP AT GIT_MSG INTO GWA_MSG.
    WRITE /  GWA_MSG.
  ENDLOOP.

*  APPEND INITIAL LINE TO git_msg.
*  APPEND INITIAL LINE TO git_msg.
  REFRESH GIT_MSG.
  CLEAR GWA_MSG.
  SORT GIT_CATSDB_FINAL ASCENDING.
  IF  GIT_CATSDB_FINAL IS NOT INITIAL.
*    SKIP 1.
    GWA_MSG+0(65) = TEXT-Z16.
    GWA_MSG+65(18) = TEXT-Z29.
    GWA_MSG+83(65) = TEXT-Z16.
    APPEND GWA_MSG TO GIT_MSG.
    CLEAR GWA_MSG.
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

    GWA_MSG+0(15)   = TEXT-Q01  .
    GWA_MSG+15(15)  = TEXT-Q02  .
    GWA_MSG+30(15)  = TEXT-Q03  .
    GWA_MSG+45(15)  = TEXT-Q04  .
    GWA_MSG+60(15)  = TEXT-Q05  .
    GWA_MSG+75(15)  = TEXT-Q06  .
    GWA_MSG+90(15)  = TEXT-Q07  .
    GWA_MSG+105(15) = TEXT-Q08  .
    GWA_MSG+120(15) = TEXT-Q09  .
    GWA_MSG+135(15) = TEXT-Q10  .
    GWA_MSG+150(15) = TEXT-Q11  .
    GWA_MSG+165(15) = TEXT-Q12  .
    GWA_MSG+180(15) = TEXT-Q13  .
    GWA_MSG+195(15) = TEXT-Q14  .
    GWA_MSG+210(15) = TEXT-Q15  .
    APPEND GWA_MSG TO GIT_MSG.
    CLEAR GWA_MSG.
    SKIP 1.
  ENDIF.
  DELETE ADJACENT DUPLICATES FROM GIT_CATSDB_FINAL COMPARING ALL FIELDS.

  LOOP AT GIT_CATSDB_FINAL INTO GWA_CATSDB.
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

    GWA_MSG+0(15)   =   GWA_CATSDB-COUNTER  .
    GWA_MSG+15(15)  =   GWA_CATSDB-PERNR  .
    GWA_MSG+30(15)  =   GWA_CATSDB-WORKDATE .
    GWA_MSG+45(15)  =   GWA_CATSDB-RKOSTL .
    GWA_MSG+60(15)  =   GWA_CATSDB-RPROJ  .
    GWA_MSG+75(15)  =   GWA_CATSDB-AWART  .
    GWA_MSG+90(15)  =   GWA_CATSDB-LGART  .
    GWA_MSG+105(15) =   GWA_CATSDB-ERSDA  .
    GWA_MSG+120(15) =   GWA_CATSDB-ERSTM  .
    GWA_MSG+135(15) =   GWA_CATSDB-LAEDA  .
    GWA_MSG+150(15) =   GWA_CATSDB-LAETM  .
    GWA_MSG+165(15) =   GWA_CATSDB-STATUS .
    GWA_MSG+180(15) =   GWA_CATSDB-REFCOUNTER .
    GWA_MSG+195(15) =   GWA_CATSDB-BELNR  .
    GWA_MSG+210(15) =   GWA_CATSDB-CATSHOURS  .
    APPEND GWA_MSG TO GIT_MSG.
    CLEAR GWA_MSG.
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

  LOOP AT GIT_MSG INTO GWA_MSG.
    WRITE /  GWA_MSG.
  ENDLOOP.

  REFRESH GIT_MSG.
ENDFORM.                    " CONTROL_TOTAL
*&---------------------------------------------------------------------*
*&      Form  GET_CHANGED_CATSDB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CHANGED_CATSDB .
**  IF git_pernr IS NOT INITIAL.
**    SELECT * FROM catsdb INTO TABLE git_catsdb1
**    FOR ALL ENTRIES IN git_pernr
**    WHERE pernr = git_pernr-pernr.
**  ENDIF.

  IF GIT_CATSDB  IS NOT INITIAL.
    SELECT * FROM CATSDB INTO TABLE GIT_CATSDB1
    FOR ALL ENTRIES IN GIT_CATSDB
    WHERE COUNTER = GIT_CATSDB-REFCOUNTER.
  ENDIF.

***  LOOP AT git_catsdb INTO gwa_catsdb
***    WHERE refcounter IS NOT INITIAL.
***    READ TABLE git_catsdb1 INTO gwa_catsdb1 WITH KEY
***    counter = gwa_catsdb-refcounter.
***    IF sy-subrc = 0.
***      APPEND gwa_catsdb1 TO git_catsdb2.
***    ENDIF.
***  ENDLOOP.

  APPEND LINES OF GIT_CATSDB TO GIT_CATSDB_FINAL.
  APPEND LINES OF GIT_CATSDB1 TO GIT_CATSDB_FINAL.

ENDFORM.                    " GET_CHANGED_CATSDB
*&---------------------------------------------------------------------*
*&      Form  CLEAR_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CLEAR_DATA .
  REFRESH:GIT_CATSDB,
    GIT_CATSDB1,
    GIT_CATSDB2,
    GIT_CATSDB_FINAL,
    GIT_CATSDB_ERROR,
    GIT_PTEX2000FI,
    GIT_PTEX2000HR,
    GIT_PERNR,
    GIT_ZHR_CATSDB_DT.
ENDFORM.                    " CLEAR_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PTEXTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_PTEXTABLE .
  IF P_UPD IS NOT INITIAL AND GV_DATE IS NOT INITIAL.

    REFRESH GIT_PTEX2000FI.
    SELECT * FROM PTEX2000 INTO TABLE GIT_PTEX2000FI
      FOR ALL ENTRIES IN GIT_PERNR
    WHERE PERNR = GIT_PERNR-PERNR
    AND DATUM1 >= GV_DATE.

    REFRESH GIT_PTEX2010FI.
    SELECT * FROM PTEX2010 INTO TABLE GIT_PTEX2010FI
      FOR ALL ENTRIES IN GIT_PERNR
    WHERE PERNR = GIT_PERNR-PERNR
    AND DATUM1 >= GV_DATE.

  ELSE.

    REFRESH GIT_PTEX2000FI.
    SELECT * FROM PTEX2000 INTO TABLE GIT_PTEX2000FI
      FOR ALL ENTRIES IN GIT_PERNR
         WHERE PERNR = GIT_PERNR-PERNR
     AND DATUM1 >= P_BEGDA.

    REFRESH GIT_PTEX2010FI.
    SELECT * FROM PTEX2010 INTO TABLE GIT_PTEX2010FI
      FOR ALL ENTRIES IN GIT_PERNR
    WHERE PERNR = GIT_PERNR-PERNR
    AND DATUM1 >= P_BEGDA1.

  ENDIF.
ENDFORM.                    " GET_DATA_PTEXTABLE
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PRPS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA_PRPS .
  SELECT PSPNR POSID POSKI INTO TABLE GIT_WBS_FI FROM PRPS
    FOR ALL ENTRIES IN GIT_CATSDB_FINAL WHERE  PSPNR = GIT_CATSDB_FINAL-RPROJ.
ENDFORM.                    " GET_DATA_PRPS
