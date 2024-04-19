*&-------------------------------------------------------------------------------------------------
*& Report  ZHR_WD_GETINCONSISTENTRECORDS
*&--------------------------------------------------------------------------------------------------
*Program Name:      ZHR_WD_GETINCONSISTENTRECORDS
*Author:            Nidhi Singh (SINGHN7)
*Date:              12.11.2018
*Application Area:  HR
*Description:       Report to find employees having inconsistency in IT0000, IT0001 and IT0007
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*Modification details
*Version No:      Date:          Modified By:   Ticket No:      Correction No:
*                       xxxxxxxxx   xxxxxxxxxxxx  xxxxxxxx        xxxxxxxxxx
*Description:
*----------------------------------------------------------------------------------------------------

REPORT  zhr_wd_getinconsistentrecords.

TYPES: BEGIN OF lty_data,
        pernr TYPE pernr_d,
        endda TYPE endda,
        begda TYPE begda,
       END OF lty_data.

TYPES: BEGIN OF lty_inconsistent,
        pernr              TYPE pernr_d,
        infty              TYPE infty,
        rec1_start_date    TYPE begda,
        rec1_end_date      TYPE endda,
        rec2_start_date    TYPE begda,
        rec2_end_date      TYPE endda,
        inconsistency      TYPE char10,
       END OF lty_inconsistent.

DATA: ls_0000     TYPE lty_data,
      ls_0001     TYPE lty_data,
      ls_0007     TYPE lty_data,
      ls_before   TYPE lty_data,
      ls_incon    TYPE lty_inconsistent,
      lt_0000     TYPE TABLE OF lty_data,
      lt_0001     TYPE TABLE OF lty_data,
      lt_0007     TYPE TABLE OF lty_data,
      lt_incon    TYPE TABLE OF lty_inconsistent.

DATA: lv_pernr TYPE pernr_d,
      lv_diff  TYPE i.

CONSTANTS: lc_0000  TYPE infty  VALUE '0000',
           lc_0001  TYPE infty  VALUE '0001',
           lc_0007  TYPE infty  VALUE '0007',
           lc_gap   TYPE char10 VALUE 'GAP',
           lc_over  TYPE char10 VALUE 'OVERLAP'.

CLEAR: lt_0000, lt_0001, lt_0007, lt_incon.
*& Get IT0000 data
SELECT pernr endda begda INTO TABLE lt_0000 FROM pa0000.
*& Get IT0001 data
SELECT pernr endda begda INTO TABLE lt_0001 FROM pa0001.
*& Get IT0007 data
SELECT pernr endda begda INTO TABLE lt_0007 FROM pa0007.

*& Check inconsistent  records in IT0000
CLEAR: lv_pernr, lv_diff, ls_before, ls_incon.
SORT lt_0000 BY pernr begda ASCENDING.
LOOP AT lt_0000 INTO ls_0000.

  IF lv_pernr NE ls_0000-pernr.
    lv_pernr = ls_0000-pernr.
    CLEAR: ls_before.
  ENDIF.

  IF ls_before IS NOT INITIAL.
    CLEAR: lv_diff.
    lv_diff = ls_0000-begda - ls_before-endda.
*& Check gap
    IF lv_diff > 1.
      ls_incon-pernr           = ls_0000-pernr.
      ls_incon-inconsistency   = lc_gap.
      ls_incon-infty           = lc_0000.
      ls_incon-rec2_start_date = ls_0000-begda.
      ls_incon-rec2_end_date   = ls_0000-endda.
      ls_incon-rec1_start_date = ls_before-begda.
      ls_incon-rec1_end_date   = ls_before-endda.
      APPEND ls_incon TO lt_incon.
    ENDIF.
*& Check overlap
    IF lv_diff < 1.
      ls_incon-pernr           = ls_0000-pernr.
      ls_incon-inconsistency   = lc_over.
      ls_incon-infty           = lc_0000.
      ls_incon-rec2_start_date = ls_0000-begda.
      ls_incon-rec2_end_date   = ls_0000-endda.
      ls_incon-rec1_start_date = ls_before-begda.
      ls_incon-rec1_end_date   = ls_before-endda.
      APPEND ls_incon TO lt_incon.
    ENDIF.
  ENDIF.
  ls_before = ls_0000.
  CLEAR: ls_0000, lv_diff.
ENDLOOP.

*& Check inconsistent records in IT0001
CLEAR: lv_pernr, lv_diff, ls_before, ls_incon.
SORT lt_0001 BY pernr begda ASCENDING.
LOOP AT lt_0001 INTO ls_0001.

  IF lv_pernr NE ls_0001-pernr.
    lv_pernr = ls_0001-pernr.
    CLEAR: ls_before.
  ENDIF.

  IF ls_before IS NOT INITIAL.
    CLEAR: lv_diff.
    lv_diff = ls_0001-begda - ls_before-endda.
*& Check gap
    IF lv_diff > 1.
      ls_incon-pernr           = ls_0001-pernr.
      ls_incon-inconsistency   = lc_gap.
      ls_incon-infty           = lc_0001.
      ls_incon-rec2_start_date = ls_0001-begda.
      ls_incon-rec2_end_date   = ls_0001-endda.
      ls_incon-rec1_start_date = ls_before-begda.
      ls_incon-rec1_end_date   = ls_before-endda.
      APPEND ls_incon TO lt_incon.
    ENDIF.
*& Check overlap
    IF lv_diff < 1.
      ls_incon-pernr           = ls_0001-pernr.
      ls_incon-inconsistency   = lc_over.
      ls_incon-infty           = lc_0001.
      ls_incon-rec2_start_date = ls_0001-begda.
      ls_incon-rec2_end_date   = ls_0001-endda.
      ls_incon-rec1_start_date = ls_before-begda.
      ls_incon-rec1_end_date   = ls_before-endda.
      APPEND ls_incon TO lt_incon.
    ENDIF.
  ENDIF.
  ls_before = ls_0001.
  CLEAR: ls_0001, lv_diff.
ENDLOOP.

*& Check inconsistent records in IT0007
CLEAR: lv_pernr, lv_diff, ls_before, ls_incon.
SORT lt_0007 BY pernr begda ASCENDING.
LOOP AT lt_0007 INTO ls_0007.

  IF lv_pernr NE ls_0007-pernr.
    lv_pernr = ls_0007-pernr.
    CLEAR: ls_before.
  ENDIF.

  IF ls_before IS NOT INITIAL.
    CLEAR: lv_diff.
    lv_diff = ls_0007-begda - ls_before-endda.
*& Check gap
    IF lv_diff > 1.
      ls_incon-pernr           = ls_0007-pernr.
      ls_incon-inconsistency   = lc_gap.
      ls_incon-infty           = lc_0007.
      ls_incon-rec2_start_date = ls_0007-begda.
      ls_incon-rec2_end_date   = ls_0007-endda.
      ls_incon-rec1_start_date = ls_before-begda.
      ls_incon-rec1_end_date   = ls_before-endda.
      APPEND ls_incon TO lt_incon.
    ENDIF.
*& Check overlap
    IF lv_diff < 1.
      ls_incon-pernr           = ls_0007-pernr.
      ls_incon-inconsistency   = lc_over.
      ls_incon-infty           = lc_0007.
      ls_incon-rec2_start_date = ls_0007-begda.
      ls_incon-rec2_end_date   = ls_0007-endda.
      ls_incon-rec1_start_date = ls_before-begda.
      ls_incon-rec1_end_date   = ls_before-endda.
      APPEND ls_incon TO lt_incon.
    ENDIF.
  ENDIF.
  ls_before = ls_0007.
  CLEAR: ls_0007, lv_diff.
ENDLOOP.

IF lt_incon IS NOT INITIAL.
  DELETE ADJACENT DUPLICATES FROM lt_incon COMPARING ALL FIELDS.
  SORT lt_incon BY pernr infty ASCENDING.

  CALL FUNCTION 'HR_IT_SHOW_ANY_TABLE_ON_ALV'
    TABLES
      table    = lt_incon
    EXCEPTIONS
      fb_error = 1
      OTHERS   = 2.
ELSE.
  MESSAGE 'No data found' TYPE 'W'.
ENDIF.
