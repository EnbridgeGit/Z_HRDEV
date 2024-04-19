*----------------------------------------------------------------------*
***INCLUDE ZHTM001_CATS_AUTO_SUB .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_EMP_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_EMP_DATA .


  DATA : LV_HTYPE    TYPE DD01V-DATATYPE,
        LV_MOLGA(2) TYPE C.

  CLEAR : GV_FLAG,
  LV_MOLGA,
  LV_HTYPE.

  CALL FUNCTION 'RH_PM_GET_MOLGA_FROM_PERNR'
    EXPORTING
      PERNR           = PERNR-PERNR
    IMPORTING
      MOLGA           = LV_MOLGA
    EXCEPTIONS
      NOTHING_FOUND   = 1
      NO_ACTIVE_PLVAR = 2
      OTHERS          = 3.
  IF SY-SUBRC = 0.
    IF LV_MOLGA = 07. "Runs only for canada employee
      RP_PROVIDE_FROM_LAST P0001 SPACE PN-BEGDA PN-ENDDA.

      IF PNP-SW-FOUND EQ 1.
        CALL FUNCTION 'NUMERIC_CHECK'
          EXPORTING
            STRING_IN = P0001-WERKS
          IMPORTING
            HTYPE     = LV_HTYPE.

        IF LV_HTYPE EQ 'NUMC'.
          "Do Nothing
        ELSE.
          "Set West Employee
          "Error msg. Employee Doesn't belongs to UGL OR MNE
          CLEAR :GWA_ERROR.
          GWA_ERROR-PERNR = PERNR-PERNR.
          GWA_ERROR-MESSAGE = TEXT-T05.
          APPEND GWA_ERROR TO GIT_ERROR.
          GV_FLAG = GC_X.
*      REJECT.
        ENDIF.
      ENDIF.

      IF P0001-PERSK EQ '02' OR  P0001-PERSK EQ '04' OR  P0001-PERSK EQ '06'.
        "CPT Employees are identified and rejected
        CLEAR :GWA_ERROR.
        GWA_ERROR-PERNR = PERNR-PERNR.
        GWA_ERROR-MESSAGE = TEXT-T04.
        APPEND GWA_ERROR TO GIT_ERROR.
        GV_FLAG = GC_X.
*    REJECT.
      ENDIF.


      RP_PROVIDE_FROM_LAST P0007 SPACE PN-BEGDA PN-ENDDA.
      IF PNP-SW-FOUND EQ 1.
        IF P0007-KZTIM EQ 'WA'. " WARP User
          CLEAR :GWA_ERROR.
          GWA_ERROR-PERNR = PERNR-PERNR.
          GWA_ERROR-MESSAGE = TEXT-T03.
          APPEND GWA_ERROR TO GIT_ERROR.
          GV_FLAG = GC_X.
        ELSE.
          "Non-WARP/Non-Work manager User
        ENDIF.
      ENDIF.

      IF GV_FLAG NE GC_X.
        PERFORM LOAD_VIA_CALL_TRANSACTION.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_EMP_DATA
*&---------------------------------------------------------------------*
*&      Form  load_via_call_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LOAD_VIA_CALL_TRANSACTION.

  DATA LV_DATUM TYPE CHAR10.
  CLEAR GWA_PERNR.

  CONSTANTS : LC_ZUG_EMPD(8) TYPE C  VALUE 'ZUG_EMPD'.

  DATA : LV_DATE_FROM  TYPE DATUM,
         LV_DATE_TO    TYPE DATUM,
         LIT_WORKLIST  TYPE TABLE OF BAPICATS5,
         LIT_RETURN    TYPE TABLE OF BAPIRET2,
         LIT_PERNR_TAB TYPE TABLE OF PDPNR,
         LIT_PSP       TYPE TABLE OF PDPSP,
         LIT_DAY_PSP   TYPE TABLE OF PDSPPSP,
         LV_HOURS      TYPE STDAZ,
         LV_CAT1       TYPE STDAZ,
         LV_CAT1_DIFF  TYPE STDAZ,
         LV_CAT2       TYPE STDAZ,
         LV_CAT2_DIFF  TYPE STDAZ,
         LV_CAT3       TYPE STDAZ,
         LV_CAT3_DIFF  TYPE STDAZ,
         LV_CAT4       TYPE STDAZ,
         LV_CAT4_DIFF  TYPE STDAZ,
         LV_CAT5       TYPE STDAZ,
         LV_CAT5_DIFF  TYPE STDAZ,
         LV_CAT6       TYPE STDAZ,
         LV_CAT6_DIFF  TYPE STDAZ,
         LV_CAT7       TYPE STDAZ,
         LV_CAT7_DIFF  TYPE STDAZ."n.

  DATA : LWA_PERNR_TAB TYPE PDPNR,
         LWA_PSP       TYPE PDPSP.

  REFRESH : LIT_PERNR_TAB,LIT_PSP.

  WRITE PN-BEGDA TO LV_DATUM MM/DD/YYYY.

  CALL FUNCTION 'BAPI_EECATIMESHEET_GETWORKLIST'
    EXPORTING
      PROFILE        = LC_ZUG_EMPD
      EMPLOYEENUMBER = PERNR-PERNR
      INPUTDATE      = PN-BEGDA "lv_datum
    IMPORTING
      DATE_FROM      = LV_DATE_FROM
      DATE_TO        = LV_DATE_TO
    TABLES
      WORKLIST       = LIT_WORKLIST
*     EXTENSIONOUT   =
      RETURN         = LIT_RETURN.
*   SA_EXTENSION_OUT       =

  MOVE PERNR-PERNR TO LWA_PERNR_TAB-PERNR.
  APPEND LWA_PERNR_TAB TO LIT_PERNR_TAB.

  CALL FUNCTION 'HR_PERSON_READ_WORK_SCHEDULE'
    EXPORTING
      BEGIN_DATE         = LV_DATE_FROM
      END_DATE           = LV_DATE_TO
    TABLES
      PERNR_TAB          = LIT_PERNR_TAB
      PSP                = LIT_PSP
      DAY_PSP            = LIT_DAY_PSP
    EXCEPTIONS
      ERROR_IN_BUILD_PSP = 1
      OTHERS             = 2.

  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR: GWA_BDCDATA, GIT_BDCDATA[].

  WRITE PN-BEGDA TO LV_DATUM MM/DD/YYYY.

  PERFORM BDC_DYNPRO      USING 'SAPLCATS' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
        'CATSFIELDS-PERNR'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
        '=TIME'.
  PERFORM BDC_FIELD       USING 'TCATST-VARIANT'
*{   REPLACE        D30K919902                                        1
*\        'ZHR_EMPD'.
        LC_ZUG_EMPD."'ZUG_EMPD'.
*}   REPLACE
  PERFORM BDC_FIELD       USING 'CATSFIELDS-INPUTDATE'
        LV_DATUM ." '06/16/2011'.
  PERFORM BDC_FIELD       USING 'CATSFIELDS-PERNR'
        PERNR-PERNR.
  "gwa_pernr-pernr.
*  PERFORM bdc_dynpro      USING 'SAPLCATS' '2030'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*        '=TIHR'.
*  PERFORM bdc_dynpro      USING 'SAPLSPO1' '0300'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*        '=YES'.
  PERFORM BDC_DYNPRO      USING 'SAPLCATS' '2030'.
*{   INSERT         D30K919902                                        4


  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT1,LV_CAT1_DIFF.
  READ TABLE LIT_PSP INDEX 1 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
      WHERE PERNR = LWA_PSP-PERNR AND
            WORKDATE = LWA_PSP-DATUM.
      LV_CAT1 = LV_CAT1 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT1_DIFF = LWA_PSP-STDAZ - LV_CAT1.
    IF LV_CAT1_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY1(10)'
                                      LV_CAT1_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY1(10)'
                              '0.00'.
    ENDIF.
  ENDIF.

  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT2,LV_CAT2_DIFF.
  READ TABLE LIT_PSP INDEX 2 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
    WHERE PERNR = LWA_PSP-PERNR AND
    WORKDATE = LWA_PSP-DATUM.
      LV_CAT2 = LV_CAT2 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT2_DIFF = LWA_PSP-STDAZ - LV_CAT2.
    IF LV_CAT2_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY2(10)'
            LV_CAT2_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY2(10)'
            '0.00'.
    ENDIF.
  ENDIF.


  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT3,LV_CAT3_DIFF.
  READ TABLE LIT_PSP INDEX 3 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
    WHERE PERNR = LWA_PSP-PERNR AND
    WORKDATE = LWA_PSP-DATUM.
      LV_CAT3 = LV_CAT3 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT3_DIFF = LWA_PSP-STDAZ - LV_CAT3.
    IF LV_CAT3_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY3(10)'
            LV_CAT3_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY3(10)'
            '0.00'.
    ENDIF.
  ENDIF.

  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT4,LV_CAT4_DIFF.
  READ TABLE LIT_PSP INDEX 4 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
    WHERE PERNR = LWA_PSP-PERNR AND
    WORKDATE = LWA_PSP-DATUM.
      LV_CAT4 = LV_CAT4 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT4_DIFF = LWA_PSP-STDAZ - LV_CAT4.
    IF LV_CAT4_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY4(10)'
            LV_CAT4_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY4(10)'
            '0.00'.
    ENDIF.
  ENDIF.


  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT5,LV_CAT5_DIFF.
  READ TABLE LIT_PSP INDEX 5 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
    WHERE PERNR = LWA_PSP-PERNR AND
    WORKDATE = LWA_PSP-DATUM.
      LV_CAT5 = LV_CAT5 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT5_DIFF = LWA_PSP-STDAZ - LV_CAT5.
    IF LV_CAT5_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY5(10)'
            LV_CAT5_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY5(10)'
            '0.00'.
    ENDIF.
  ENDIF.


  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT6,LV_CAT6_DIFF.
  READ TABLE LIT_PSP INDEX 6 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
    WHERE PERNR = LWA_PSP-PERNR AND
    WORKDATE = LWA_PSP-DATUM.
      LV_CAT6 = LV_CAT6 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT6_DIFF = LWA_PSP-STDAZ - LV_CAT6.
    IF LV_CAT6_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY6(10)'
            LV_CAT6_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY6(10)'
            '0.00'.
    ENDIF.
  ENDIF.


  CLEAR : LWA_PSP ,LV_HOURS,LV_CAT7,LV_CAT7_DIFF.
  READ TABLE LIT_PSP INDEX 7 INTO LWA_PSP.
  IF SY-SUBRC = 0 ."AND lwa_psp-ftkla = '1'.
    LOOP AT GIT_CATSDB INTO GWA_CATSDB
    WHERE PERNR = LWA_PSP-PERNR AND
    WORKDATE = LWA_PSP-DATUM.
      LV_CAT7 = LV_CAT7 + GWA_CATSDB-CATSHOURS.
    ENDLOOP.
*    IF lwa_psp-stdaz IS NOT INITIAL.
    LV_CAT7_DIFF = LWA_PSP-STDAZ - LV_CAT7.
    IF LV_CAT7_DIFF GT 0.

      LV_HOURS = LWA_PSP-STDAZ.
      PERFORM BDC_FIELD       USING 'CATSD-DAY7(10)'
            LV_CAT7_DIFF.
    ELSE.
      PERFORM BDC_FIELD       USING 'CATSD-DAY7(10)'
            '0.00'.
    ENDIF.
  ENDIF.

***  CLEAR :lwa_psp ,lv_hours.
***  READ TABLE lit_psp INDEX 2 INTO lwa_psp.
***  IF sy-subrc = 0 AND lwa_psp-ftkla = '1'.
***    IF lwa_psp-stdaz IS NOT INITIAL.
***      lv_hours = lwa_psp-stdaz.
***      PERFORM bdc_field       USING 'CATSD-DAY2(10)'
***                                       lv_hours."lwa_psp-STDAZ.  "day2.
***    ENDIF.
***  ENDIF.
***
***  CLEAR : lwa_psp ,lv_hours.
***  READ TABLE lit_psp INDEX 3 INTO lwa_psp.
***  IF sy-subrc = 0 AND lwa_psp-ftkla = '1'.
***    IF lwa_psp-stdaz IS NOT INITIAL.
***      lv_hours = lwa_psp-stdaz.
***      PERFORM bdc_field       USING 'CATSD-DAY3(10)'
***                                      lv_hours."lwa_psp-STDAZ.   "day3.
***    ENDIF.
***  ENDIF.
***
***  CLEAR : lwa_psp ,lv_hours.
***  READ TABLE lit_psp INDEX 4 INTO lwa_psp.
***  IF sy-subrc = 0 AND lwa_psp-ftkla = '1'..
***    IF lwa_psp-stdaz IS NOT INITIAL.
***      lv_hours = lwa_psp-stdaz.
***      PERFORM bdc_field       USING 'CATSD-DAY4(10)'
***                                      lv_hours."lwa_psp-STDAZ.   "day4.
***    ENDIF.
***  ENDIF.
***
***  CLEAR : lwa_psp ,lv_hours.
***  READ TABLE lit_psp INDEX 5 INTO lwa_psp.
***  IF sy-subrc = 0 AND lwa_psp-ftkla = '1'..
***    IF lwa_psp-stdaz IS NOT INITIAL.
***      lv_hours = lwa_psp-stdaz.
***      PERFORM bdc_field       USING 'CATSD-DAY5(10)'
***                                      lv_hours."lwa_psp-STDAZ.   "day5.
***    ENDIF.
***  ENDIF.
***
***  CLEAR : lwa_psp ,lv_hours.
***  READ TABLE lit_psp INDEX 6 INTO lwa_psp.
***  IF sy-subrc = 0 AND lwa_psp-ftkla = '1'..
***    IF lwa_psp-stdaz IS NOT INITIAL.
***      lv_hours = lwa_psp-stdaz.
***      PERFORM bdc_field       USING 'CATSD-DAY6(10)'
***                                      lv_hours."lwa_psp-STDAZ.   "day6.
***    ENDIF.
***  ENDIF.
***
***  CLEAR : lwa_psp ,lv_hours.
***  READ TABLE lit_psp INDEX 7 INTO lwa_psp.
***  IF sy-subrc = 0 AND lwa_psp-ftkla = '1'..
***    IF lwa_psp-stdaz IS NOT INITIAL.
***      lv_hours = lwa_psp-stdaz.
***      PERFORM bdc_field       USING 'CATSD-DAY7(10)'
***                                      lv_hours."lwa_psp-STDAZ.   "day7.
***    ENDIF.
***  ENDIF.

*}   INSERT
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
        '=SAVE'.
*{   INSERT         D30K919902                                        3
  PERFORM BDC_DYNPRO      USING 'saplcate' '0120'.
  PERFORM BDC_FIELD       USING 'bdc_okcode'
                                '=back'.


*}   INSERT

  G_TCODE = 'CAT2'.
  G_CTUMODE = 'N'.
  CALL TRANSACTION G_TCODE USING GIT_BDCDATA
        MODE   G_CTUMODE
        UPDATE G_CUPDATE
        MESSAGES INTO GIT_BDCMSGCOLL.

*{   DELETE         D30K919902                                        5
*\  REFRESH git_bdcdata.
*}   DELETE
*{   INSERT         D30K919902                                        6
  IF SY-SUBRC = 0.
*}   INSERT
*{   INSERT         D30K919902                                        8
*PERFORM populate_bdc_errors.
*}   INSERT
    CLEAR GWA_SUCCESS.
    GWA_SUCCESS-PERNR = PERNR-PERNR.
    CONCATENATE TEXT-T01
    LV_DATUM
    INTO GWA_SUCCESS-MESSAGE
    SEPARATED BY SPACE.
    APPEND GWA_SUCCESS TO GIT_SUCCESS.
*{   INSERT         D30K919902                                        7
  ELSE.
    CLEAR GWA_ERROR.
    GWA_ERROR-PERNR = PERNR-PERNR.
***Start of "Ticket# 64717 Changes.
*    CONCATENATE text-t06
*               lv_datum
*               INTO gwa_error-message
*               SEPARATED BY space.
    DELETE GIT_BDCMSGCOLL WHERE MSGTYP = 'I'.
    READ TABLE GIT_BDCMSGCOLL INDEX 1 INTO GWA_BDCMSGCOLL.
    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = GWA_BDCMSGCOLL-MSGID
        MSGNR               = GWA_BDCMSGCOLL-MSGNR
        MSGV1               = GWA_BDCMSGCOLL-MSGV1
        MSGV2               = GWA_BDCMSGCOLL-MSGV2
        MSGV3               = GWA_BDCMSGCOLL-MSGV3
        MSGV4               = GWA_BDCMSGCOLL-MSGV4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = GWA_ERROR-MESSAGE.
    APPEND GWA_ERROR TO GIT_ERROR.
    CLEAR: GWA_BDCMSGCOLL, GIT_BDCMSGCOLL.
    REFRESH GIT_BDCMSGCOLL.
***End of "Ticket# 64717 Changes.
  ENDIF.

  REFRESH GIT_BDCDATA.
  CLEAR : GWA_SUCCESS,GWA_ERROR.
*}   INSERT

*  ENDLOOP.

ENDFORM.                    "load_via_call_transaction
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
.
*&---------------------------------------------------------------------*
*&      Form  bdc_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FLDNAM   text
*      -->P_FLDVAL   text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING P_FLDNAM
      P_FLDVAL.

  IF NOT P_FLDVAL EQ SPACE.
    CLEAR GWA_BDCDATA.
    GWA_BDCDATA-FNAM = P_FLDNAM.
    GWA_BDCDATA-FVAL = P_FLDVAL.
*{   INSERT         D30K919902                                        1
    SHIFT GWA_BDCDATA-FVAL LEFT DELETING LEADING SPACE.
*}   INSERT
    APPEND GWA_BDCDATA TO GIT_BDCDATA.
  ENDIF.

ENDFORM. " BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  bdc_dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROGRAM  text
*      -->P_DYNPRO   text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING P_PROGRAM
      P_DYNPRO.

  CLEAR GWA_BDCDATA.
  GWA_BDCDATA-PROGRAM  = P_PROGRAM.
  GWA_BDCDATA-DYNPRO   = P_DYNPRO.
  GWA_BDCDATA-DYNBEGIN = 'X'.
  APPEND GWA_BDCDATA TO GIT_BDCDATA.


ENDFORM. " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  WRITE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_STATUS .
  DATA:LV_TOTAL   TYPE I,
        LV_SUCCESS TYPE I,
        LV_ERROR   TYPE I,
        GIT_MSG    TYPE SRM_T_SOLISTI1,
        GWA_MSG    TYPE CHAR300.
*  DESCRIBE TABLE git_pernr LINES lv_total.
  DESCRIBE TABLE  GIT_ERROR   LINES LV_ERROR.
  DESCRIBE TABLE  GIT_SUCCESS LINES LV_SUCCESS.
**  IF lv_total IS NOT INITIAL .
**    lv_success = lv_total - lv_error.
**  ENDIF.

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
  GWA_MSG+20(10) = LV_ERROR + LV_SUCCESS.
  GWA_MSG+65(10) = TEXT-Z21.
  GWA_MSG+75(10) = LV_ERROR.
  APPEND GWA_MSG TO GIT_MSG.
  CLEAR GWA_MSG.


  IF GIT_ERROR IS NOT INITIAL.
*    gwa_msg+0(20)  = text-z26.
**    CONCATENATE text-t01 sy-datum '_' sy-uzeit '.TXT' INTO
**    gwa_msg+20(100).
*    APPEND gwa_msg TO git_msg.
*    CLEAR gwa_msg.
  ENDIF.

  LOOP AT GIT_MSG INTO GWA_MSG.
    WRITE /  GWA_MSG.
  ENDLOOP.

  IF GIT_SUCCESS IS NOT INITIAL.
    INSERT INITIAL LINE INTO GIT_SUCCESS INDEX 1.
    GWA_SUCCESS-PERNR = TEXT-L01.
    GWA_SUCCESS-MESSAGE = TEXT-L02.
    INSERT GWA_SUCCESS INTO GIT_SUCCESS INDEX 1.

    LOOP AT GIT_SUCCESS INTO GWA_MSG.
      WRITE /  GWA_MSG.
    ENDLOOP.
  ENDIF.

  IF GIT_ERROR IS NOT INITIAL.
    SKIP 1.
    INSERT INITIAL LINE INTO GIT_ERROR INDEX 1.
    CLEAR GWA_ERROR.
    GWA_ERROR-PERNR = TEXT-L03.
    GWA_ERROR-MESSAGE = TEXT-L04.
    INSERT GWA_ERROR INTO GIT_ERROR INDEX 1.

    LOOP AT GIT_ERROR INTO GWA_MSG.
      WRITE /  GWA_MSG.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "write_status
*{   INSERT         D30K919902                                        1
FORM POPULATE_BDC_ERRORS.
*
*DATA : lv_msg TYPE char100.
*
*DATA lv_datum TYPE char10.
*
*  READ TABLE git_bdcmsgcoll
*  INTO gwa_bdcmsgcoll
*  WITH KEY msgtyp = 'E' BINARY SEARCH.
*
*  IF sy-subrc EQ 0.
*
*    LOOP AT git_bdcmsgcoll INTO gwa_bdcmsgcoll.
*
*      CHECK gwa_bdcmsgcoll-msgtyp EQ 'E'.
*      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*        EXPORTING
*          msgid               = gwa_bdcmsgcoll-msgid
*          msgnr               = gwa_bdcmsgcoll-msgnr
*          msgv1               = gwa_bdcmsgcoll-msgv1
*          msgv2               = gwa_bdcmsgcoll-msgv2
*          msgv3               = gwa_bdcmsgcoll-msgv3
*          msgv4               = gwa_bdcmsgcoll-msgv4
*        IMPORTING
*          message_text_output = gwa_error-MESSAGE.
*
*         CLEAR gwa_error.
*         gwa_error-pernr = pernr-pernr.
**         CONCATENATE text-t06
**                     lv_datum
**                INTO gwa_error-message
**        SEPARATED BY space.
*
*      EXIT.
*    ENDLOOP.
*
*    APPEND gwa_error TO git_error.
*    CLEAR gwa_error.
*  ELSE.
*
*    LOOP AT git_bdcmsgcoll INTO gwa_bdcmsgcoll WHERE msgid = 'PG'
*AND ( msgnr = '208' OR msgnr = '102' OR msgnr = '103' OR msgnr = '113').
*
*      CHECK gwa_bdcmsgcoll-msgtyp EQ 'S'.
*      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
*        EXPORTING
*          msgid               = gwa_bdcmsgcoll-msgid
*          msgnr               = gwa_bdcmsgcoll-msgnr
*          msgv1               = gwa_bdcmsgcoll-msgv1
*          msgv2               = gwa_bdcmsgcoll-msgv2
*          msgv3               = gwa_bdcmsgcoll-msgv3
*          msgv4               = gwa_bdcmsgcoll-msgv4
*        IMPORTING
*          message_text_output = lv_msg.
*
*       CLEAR gwa_success.
*       gwa_success-pernr = pernr-pernr.
*       CONCATENATE text-t01
*                   lv_datum
*              INTO gwa_success-message
*         SEPARATED BY space.
*
*      EXIT.
*    ENDLOOP.
*    APPEND gwa_success TO git_success.
*    CLEAR gwa_success.
*
*  ENDIF.

ENDFORM.                    "populate_bdc_errors
*}   INSERT
*&---------------------------------------------------------------------*
*&      Form  GET_CATSDB_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CATSDB_DATA .
  DATA : LV_MON TYPE BEGDA,
         LV_FRI TYPE BEGDA,
         LV_SAT TYPE BEGDA,
         LV_SUN TYPE BEGDA,
         LV_WEEK LIKE SCAL-WEEK..

  CALL FUNCTION 'GET_WEEK_INFO_BASED_ON_DATE'
    EXPORTING
      DATE   = PN-BEGDA
    IMPORTING
      WEEK   = LV_WEEK
*     monday = lv_mon
*     sunday =    lv_sun
    .

  CALL FUNCTION 'NEXT_WEEK'
    EXPORTING
      CURRENT_WEEK = LV_WEEK
    IMPORTING
*     NEXT_WEEK    =
      MONDAY       = LV_MON
      SUNDAY       = LV_SUN.

  LV_FRI = LV_SUN - 2.
  SELECT *  FROM ZHR_OT_CODES INTO TABLE GIT_ZHR_OT_CODES.

  SELECT * FROM CATSDB INTO TABLE GIT_CATSDB
    WHERE "status = '30'
          WORKDATE GE LV_MON
    AND   WORKDATE LE LV_FRI.
*    AND awart <> git_zhr_ot_codes-awart.
  LOOP AT GIT_ZHR_OT_CODES INTO GWA_ZHR_OT_CODES.
    DELETE GIT_CATSDB WHERE AWART = GWA_ZHR_OT_CODES-AWART OR STATUS = '10' OR STATUS = '60'
    OR STATUS = '40'.
  ENDLOOP.

ENDFORM.                    " GET_CATSDB_DATA
