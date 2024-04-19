*&---------------------------------------------------------------------*
*&  Include           ZHTMC_CATSDBLOAD_SEL_NEW
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHTMC_CATSDBLOAD_SEL
*&---------------------------------------------------------------------*


DATA: lv_subrc      TYPE subrc,
      lv_path       TYPE string,
      lv_id         TYPE ad_smtpadr.

DATA :report_title LIKE sy-title.

report_title = sy-title.
* Read file name


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
PARAMETERS : p_prof TYPE tcatst-variant DEFAULT 'ZHR_EMPD' OBLIGATORY MODIF ID prf.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK r1 WITH FRAME TITLE text-t14.
SELECTION-SCREEN: BEGIN OF LINE,
POSITION 1, COMMENT 1(10) text-y19 FOR FIELD p_test.
PARAMETERS:p_err RADIOBUTTON GROUP r3 DEFAULT 'X' USER-COMMAND upd1.
SELECTION-SCREEN:POSITION 22,COMMENT 22(15) text-y21 FOR FIELD p_all.
PARAMETERS:p_all RADIOBUTTON GROUP r3.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN: BEGIN OF LINE,
*  POSITION 1, COMMENT 1(12) text-y22 FOR FIELD s_ids.
SELECT-OPTIONS: s_ids FOR lv_id NO-DISPLAY.
*SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK r1.

*Update mode (test run or production run)
SELECTION-SCREEN BEGIN OF BLOCK s3 WITH FRAME TITLE text-t11.
SELECTION-SCREEN: BEGIN OF LINE,
POSITION 1, COMMENT 1(10) text-y17 FOR FIELD p_test.
PARAMETERS:p_test RADIOBUTTON GROUP r2 DEFAULT 'X' USER-COMMAND upd1.
SELECTION-SCREEN:POSITION 30,COMMENT 30(15) text-y18 FOR FIELD  p_prd.
PARAMETERS:p_prd RADIOBUTTON GROUP r2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK s3.

*Write report to application server or presentation server
SELECTION-SCREEN BEGIN OF BLOCK s1 WITH FRAME TITLE text-t10.
SELECTION-SCREEN :BEGIN OF LINE,
  POSITION 1, COMMENT 1(18) text-y15 FOR FIELD p_pres MODIF ID m3.
PARAMETERS:p_pres RADIOBUTTON GROUP r1 DEFAULT 'X' USER-COMMAND upd   MODIF ID m3.
SELECTION-SCREEN:POSITION 45,COMMENT 30(17) text-y16 FOR FIELD  p_appl  MODIF ID m3.
PARAMETERS:p_appl RADIOBUTTON GROUP r1 MODIF ID m3.
SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN END OF BLOCK s1.
*
SELECTION-SCREEN BEGIN OF BLOCK s2 WITH FRAME TITLE text-t12.
PARAMETERS:p_path1 TYPE string MODIF ID m1.
PARAMETERS:p_file1 TYPE string MODIF ID m1.
SELECTION-SCREEN END OF BLOCK s2.
*
SELECTION-SCREEN BEGIN OF BLOCK s4 WITH FRAME TITLE text-t13.
PARAMETERS:p_path2 TYPE string MODIF ID m2.
PARAMETERS:p_file2 TYPE string MODIF ID m2.
SELECTION-SCREEN END OF BLOCK s4.

*---------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
*---------------------------------------------------------------------
  LOOP AT SCREEN.
*    IF screen-group1 = 'PRF'. " Make data entry profile read only
*      screen-input = 0.
*      MODIFY SCREEN.
*    ENDIF.

    IF screen-group1 = 'M2'.
      IF p_pres = space .
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF screen-group1 = 'M1'.
      IF p_appl = space .
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF p_test = gc_x.
      IF  screen-group1 = 'M1'
         OR screen-group1 = 'M2'
         OR screen-group1 = 'M3'
         OR screen-group1 = 'M4'
         OR screen-group1 = 'M5'.
        " OR screen-group1 = 'M6'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM restrict_select_options.

  PERFORM default_filename.

*---------------------------------------------------------------------
AT SELECTION-SCREEN.
*---------------------------------------------------------------------

  TRANSLATE p_path2 TO UPPER CASE.
  IF sscrfields-ucomm = 'R3' .
    IF p_pres = abap_true.
      CLEAR p_file1.
      CLEAR p_path1.
    ELSE.
      CLEAR p_file2.
      CLEAR p_path2.
    ENDIF.
  ENDIF.

  IF p_test NE abap_true.
    IF sscrfields-ucomm = 'ONLI'.
      IF ( p_file1 IS INITIAL   AND
          p_pres EQ abap_true ) OR
         ( p_file2 IS INITIAL AND
           p_appl EQ abap_true ).
        MESSAGE i001(zhr01).
        CLEAR sscrfields-ucomm.
      ENDIF.

      IF ( p_path1 IS INITIAL AND
           p_pres EQ abap_true ) OR
          ( p_path2 IS INITIAL AND
          p_appl EQ abap_true ).
        MESSAGE i002(zhr01).
        CLEAR sscrfields-ucomm.
      ENDIF.

      gwa_fname1 = p_file1.
      gwa_fold1 = p_path1.
      CLEAR p_file1.
    ENDIF.
  ENDIF.

  IF p_prof IS NOT INITIAL.
    SELECT SINGLE * FROM tcats WHERE variant = p_prof.
    IF sy-subrc NE 0.
      MESSAGE 'Invalid data entry profile' TYPE 'E'.
    ENDIF.
  ENDIF.

* Browrse to select a file
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path1.
  PERFORM browse_file USING p_path1.
