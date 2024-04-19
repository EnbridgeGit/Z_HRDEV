*&---------------------------------------------------------------------*
*&  Include           ZHTMC_CATSDBLOAD_SUB_NEW
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZHTMC_CATSDBLOAD_SUB .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  READ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_data .
  REFRESH : git_pernr, git_error.
  rp_provide_from_last p0001 space pn-begda pn-endda.
  IF pnp-sw-found EQ 1.
    IF p0001-persk IN pnppersk.
      CLEAR gwa_pernr.
      gwa_pernr-pernr = p0001-pernr.
      APPEND gwa_pernr TO git_pernr.
      gv_tot_ee = gv_tot_ee + 1.
    ELSE.
      CLEAR :gs_alv_data.
      gs_alv_data-pernr    = pernr-pernr.
      gs_alv_data-msg_typ  = 'W'.
      gs_alv_data-message  = text-t05.
      gs_alv_data-status   = gc_yellow.
      APPEND gs_alv_data TO gt_alv_data.
      REJECT.
    ENDIF.
  ENDIF.

ENDFORM.                    " READ_DATA
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_data .

*  DATA: return_cats LIKE bapiret2 OCCURS 0 WITH HEADER LINE.
*  DATA l_flag(1).
*  DATA lv_stdzad TYPE pthours.
*  DATA lv_subrc TYPE sy-subrc.
*
*  DATA: prev_workdate TYPE catsdbcomm-workdate. "MZH01
*
*  FIELD-SYMBOLS: <fs_catsdbcomm> LIKE LINE OF git_catsdbcomm,  "MZH01
*                 <fs_catscomm1> LIKE LINE OF git_catsdbcomm1. "MZH01
*
*  IF p_prof IS NOT INITIAL.
*    CLEAR l_flag.
*    IF p_test EQ abap_true.
*      l_flag = 'X'.
*    ELSE.
*      l_flag = ''.
*    ENDIF.
*
*    REFRESH git_catsrecords_in.
*    REFRESH: git_catsdb,git_catsd,git_message.
*    CLEAR: gv_begin_date , gv_end_date.
*
*    CALL FUNCTION 'CATS_READ_TIMESHEET_DATA'
*      EXPORTING
*        i_pernr        = pernr-pernr
*        i_key_date     = pn-begda
*        i_profile      = p_prof
**       I_SIMULATE     =
*      IMPORTING
*        e_dateto       = gv_end_date
*        e_datefrom     = gv_begin_date
**       ERROR_OCCURRED =
*      TABLES
*        e_catsdb       = git_catsdb
*        e_catsd        = git_catsd
*        check_messages = git_message.
*
*    " add logic to get previous timesheet and any hours already submitted on timesheet.
*    REFRESH git_catsdbcomm.
*    CALL FUNCTION 'CATS_READ_CATSDB'
*      EXPORTING
*        catspernr    = pernr-pernr
*        fromdate     = gv_begin_date
*        todate       = gv_end_date
*        void         = ' '
*        changed      = 'X'
*        approved     = 'X'
*        free         = 'X'
*        locked       = 'X'
*        rejected     = 'X'
*      TABLES
*        i_catsdbcomm = git_catsdbcomm
**       I_PERNR      =
*      .
*    IF git_catsdbcomm IS NOT INITIAL.
*      "REFRESH git_catsdbcomm1.
*      SORT git_catsdbcomm BY workdate.
*      CLEAR lv_hours.
*      CLEAR: gwa_catsdbcomm , gwa_catsdbcomm1.
*
**Begin of comment MZH01
**      LOOP AT  git_catsdbcomm INTO gwa_catsdbcomm.
**        ON CHANGE OF gwa_catsdbcomm-workdate.
**          CLEAR : lv_hours.
**          gwa_catsdbcomm1-pernr      = gwa_catsdbcomm-pernr.
**          gwa_catsdbcomm1-workdate   = gwa_catsdbcomm-workdate.
**
**          gwa_catsdbcomm1-catshours = gwa_catsdbcomm-catshours.
**          COLLECT gwa_catsdbcomm1 INTO git_catsdbcomm1.
**          CLEAR : gwa_catsdbcomm1.
**        ELSE.
**          IF gwa_catsdbcomm-catshours IS NOT INITIAL.
**            gwa_catsdbcomm1-pernr      = gwa_catsdbcomm-pernr.
**            gwa_catsdbcomm1-workdate   = gwa_catsdbcomm-workdate.
**
**            gwa_catsdbcomm1-catshours = gwa_catsdbcomm-catshours.
**            COLLECT gwa_catsdbcomm1 INTO git_catsdbcomm1.
**            CLEAR : gwa_catsdbcomm1.
**          ENDIF.
**        ENDON.
**        CLEAR : gwa_catsdbcomm.
**      ENDLOOP.
**End of comment MZH01
*
**Begin of MZH01
*      REFRESH: git_catsdbcomm1.
*      CLEAR: prev_workdate.
*      LOOP AT  git_catsdbcomm ASSIGNING <fs_catsdbcomm>.
*        CHECK <fs_catsdbcomm>-catshours IS NOT INITIAL.
*        IF prev_workdate EQ <fs_catsdbcomm>-workdate.
*          <fs_catscomm1>-catshours = <fs_catscomm1>-catshours + <fs_catsdbcomm>-catshours.
*        ELSE.
*          UNASSIGN <fs_catscomm1>.
*          APPEND INITIAL LINE TO git_catsdbcomm1 ASSIGNING <fs_catscomm1>.
*          <fs_catscomm1>-pernr     = <fs_catsdbcomm>-pernr.
*          <fs_catscomm1>-workdate  = <fs_catsdbcomm>-workdate.
*          <fs_catscomm1>-catshours = <fs_catsdbcomm>-catshours.
*        ENDIF.
*        prev_workdate = <fs_catsdbcomm>-workdate.
*      ENDLOOP.
**End of MZH01
*    ENDIF.
*
*    IF gv_begin_date IS NOT INITIAL AND gv_end_date IS NOT INITIAL.
*      CLEAR lv_subrc.
*      REFRESH git_target_hours.
*      CALL FUNCTION 'CATS_GET_TARGET_HOURS'
*        EXPORTING
*          pernr                    = pernr-pernr
*          begda                    = gv_begin_date
*          endda                    = gv_end_date
**         TIMETYPE                 = '    '
**         SUBHRTIMES               = ' '
**         ADDOVERTIME              = ' '
*        IMPORTING
*          subrc                    = lv_subrc
*        TABLES
*          target_hours             = git_target_hours
*        EXCEPTIONS
*          pernr_not_found          = 1
*          too_many_days            = 2
*          error_in_sap_enhancement = 3
*          OTHERS                   = 4.
*      IF lv_subrc <> 0.
** Implement suitable error handling here
*      ENDIF.
*
*    ELSE.
*      "EXIT. Do Nothing.
*
*    ENDIF.
*
*    IF git_target_hours IS NOT INITIAL.
*
*      CLEAR gwa_target_hours.
*      CLEAR gwa_catsrecords_in.
*
*      LOOP AT git_target_hours INTO gwa_target_hours.
*        CLEAR gwa_catsdbcomm1.
**
**        READ TABLE git_catsdbcomm1 INTO gwa_catsdbcomm1
**                                    WITH KEY
**                                    workdate = gwa_target_hours-date. "MZH01
*
*        READ TABLE git_catsdbcomm1 ASSIGNING <fs_catscomm1>
*                                   WITH KEY pernr    = pernr-pernr
*                                            workdate = gwa_target_hours-date. "MZH01
*
*        IF sy-subrc EQ 0.
*          gwa_catsrecords_in-workdate = gwa_target_hours-date.
*          CLEAR lv_stdzad.
**          lv_stdzad = gwa_target_hours-stdaz - gwa_catsdbcomm1-catshours. "MZH01
*          lv_stdzad = gwa_target_hours-stdaz - <fs_catscomm1>-catshours. "MZH01
*          gwa_catsrecords_in-catshours = lv_stdzad."gwa_target_hours-stdaz.
*          gwa_catsrecords_in-quantity = lv_stdzad."gwa_target_hours-stdaz.
*          gwa_catsrecords_in-employeenumber = pernr-pernr.
*          gwa_catsrecords_in-abs_att_type = '2000'.
*          APPEND gwa_catsrecords_in TO git_catsrecords_in.
*        ELSE.
*          gwa_catsrecords_in-workdate = gwa_target_hours-date.
*          gwa_catsrecords_in-catshours = gwa_target_hours-stdaz.
*          gwa_catsrecords_in-quantity = gwa_target_hours-stdaz.
*          gwa_catsrecords_in-employeenumber = pernr-pernr.
*          gwa_catsrecords_in-abs_att_type = '2000'.
*          APPEND gwa_catsrecords_in TO git_catsrecords_in.
*        ENDIF.
*      ENDLOOP.
*
*      "PERFORM checkcatsdb.
*
*      IF git_catsrecords_in IS NOT INITIAL.
*        REFRESH: git_catsrecords_out, git_return_cats.
*
*        CALL FUNCTION 'BAPI_CATIMESHEETMGR_INSERT'
*          EXPORTING
*            profile          = p_prof
*            testrun          = l_flag
*            text_format_imp  = 'ITF'
*          TABLES
*            catsrecords_in   = git_catsrecords_in
**           EXTENSIONIN      =
*            catsrecords_out  = git_catsrecords_out
**           EXTENSIONOUT     =
**           WORKFLOW_TEXT    =
*            return           = git_return_cats
**           LONGTEXT         = longtext .
**           SA_EXTENSION_IN  =
**           SA_EXTENSION_OUT =
*          .
*        COMMIT WORK.
*      ENDIF.
*    ENDIF."git_target_hours
*  ENDIF.

ENDFORM.                    " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  COLLECT_MESSAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM collect_messages .

  DATA : lv_local_date1 TYPE char10.

  DATA : lv_local_date2  TYPE char10,
         gwa_return_cats TYPE bapiret2.

  IF git_return_cats IS NOT INITIAL.

    CLEAR : lv_local_date1,lv_local_date2.
    WRITE gv_begin_date TO lv_local_date1 MM/DD/YYYY.
    WRITE gv_end_date TO lv_local_date2 MM/DD/YYYY.

    CLEAR :gwa_success,gwa_return_cats.

    APPEND INITIAL LINE TO  git_success.

    LOOP AT git_return_cats INTO gwa_return_cats.
      gwa_success-pernr = pernr-pernr.

      CONCATENATE gwa_return_cats-type ' ' ' '  ' ' gwa_return_cats-message  INTO gwa_success-message
      SEPARATED BY space.

      APPEND gwa_success TO git_success.
    ENDLOOP.
***
***    CLEAR gwa_success.
***    gwa_success-pernr = pernr-pernr.
***    CONCATENATE text-t02
***   lv_local_date1  text-t03 lv_local_date2  '.'
***    INTO gwa_success-message
***    SEPARATED BY space.
***    APPEND gwa_success TO git_success.
***  ELSE.
***    CLEAR: gwa_return_cats, gwa_error.
***    LOOP AT git_return_cats INTO gwa_return_cats.
***      gwa_error-pernr = pernr-pernr.
***      gwa_error-message = gwa_return_cats-message.
***      APPEND gwa_error TO git_error.
***    ENDLOOP.
  ENDIF.

  IF git_message IS NOT INITIAL.

    CLEAR: gwa_error,gwa_message.
    LOOP AT git_message INTO gwa_message.
      gwa_error-pernr = pernr-pernr.
      gwa_error-message = gwa_message-text.
      APPEND gwa_error TO git_error.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " COLLECT_MESSAGES
*&---------------------------------------------------------------------*
*&      Form  WRITE_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_status .
  DATA:lv_total TYPE i,
        lv_success TYPE i,
        lv_error TYPE i,
        git_msg  TYPE srm_t_solisti1,
        gwa_msg   TYPE char300.
  DESCRIBE TABLE git_pernr LINES lv_total.
  DESCRIBE TABLE git_error LINES lv_error.
  DESCRIBE TABLE  git_success LINES lv_success.
**  IF lv_total IS NOT INITIAL .
**    lv_success = lv_total - lv_error.
**  ENDIF.

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
  gwa_msg+20(10) = lv_error + lv_success.
  gwa_msg+65(10) = text-z21.
  gwa_msg+75(10) = lv_error.
  APPEND gwa_msg TO git_msg.
  CLEAR gwa_msg.
  IF git_error IS NOT INITIAL.
    gwa_msg+0(20)  = text-z26.
*    CONCATENATE text-t01 sy-datum '_' sy-uzeit '.TXT' INTO
*    gwa_msg+20(100).
    APPEND gwa_msg TO git_msg.
    CLEAR gwa_msg.
  ENDIF.

  LOOP AT git_msg INTO gwa_msg.
    WRITE /  gwa_msg.
  ENDLOOP.
  SORT git_success BY pernr message.
  IF git_success IS NOT INITIAL.
    INSERT INITIAL LINE INTO git_success INDEX 1.
    "gwa_success-pernr = text-l01.

    INSERT gwa_success INTO git_success INDEX 1.

    gwa_success-message = text-l02.

    LOOP AT git_success INTO gwa_msg.
      WRITE /  gwa_msg.
    ENDLOOP.
  ENDIF.

  IF git_error IS NOT INITIAL.
    INSERT INITIAL LINE INTO git_error INDEX 1.
    CLEAR gwa_error.
    "gwa_error-pernr = text-l03.
    gwa_error-message = text-l04.
    INSERT gwa_error INTO git_error INDEX 1.

    LOOP AT git_error INTO gwa_msg.
      WRITE /  gwa_msg.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " WRITE_STATUS
*&---------------------------------------------------------------------*
*&      Form  CHECKCATSDB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM checkcatsdb .
  REFRESH git_catsdb2.
  SELECT * FROM catsdb
    INTO TABLE git_catsdb2
    WHERE pernr EQ pernr-pernr
    AND workdate BETWEEN gv_begin_date AND gv_end_date
    AND awart EQ '2000'
    AND status EQ '30'.

  IF git_catsrecords_in IS NOT INITIAL AND git_catsdb2 IS NOT INITIAL.

    SORT  git_catsrecords_in .
    SORT git_catsdb2.
    CLEAR gwa_catsdb2.

    LOOP AT git_catsdb2 INTO gwa_catsdb2.
      CLEAR gwa_catsrecords_in.
      READ TABLE git_catsrecords_in INTO gwa_catsrecords_in
       WITH  KEY employeenumber = gwa_catsdb2-pernr
                      workdate = gwa_catsdb2-workdate.
      IF sy-subrc EQ 0.
        DELETE git_catsrecords_in FROM gwa_catsrecords_in.
        CLEAR gwa_error.
        gwa_error = pernr-pernr.
        CONCATENATE text-t25 pernr-pernr 'on' gwa_catsdb2-workdate INTO
        gwa_error-message SEPARATED BY space.
        APPEND gwa_error TO git_error.
      ENDIF.

    ENDLOOP.
  ENDIF.
ENDFORM.                    " CHECKCATSDB
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_alv .

  TABLES : pa0002.
  DATA lv_ename TYPE char80.
  DATA gwa_pa0002 TYPE pa0002.

  REFRESH: git_catsdb,git_catsd.
  CLEAR: gv_begin_date , gv_end_date.

  CLEAR gwa_success.
  DATA lv_pernr TYPE catsdb-pernr.

  CLEAR lv_pernr.
  LOOP AT git_success INTO gwa_success.

    lv_pernr = gwa_success-pernr.

    CALL FUNCTION 'CATS_READ_TIMESHEET_DATA'
      EXPORTING
        i_pernr        = lv_pernr
        i_key_date     = pn-begda
        i_profile      = p_prof
*       I_SIMULATE     =
      IMPORTING
        e_dateto       = gv_end_date
        e_datefrom     = gv_begin_date
*       ERROR_OCCURRED =
      TABLES
        e_catsdb       = git_catsdb
        e_catsd        = git_catsd
        check_messages = git_message.

    DELETE git_catsdb WHERE status EQ '60'.

    CLEAR: gwa_catsdb, gwa_output.
    REFRESH git_output.
    CLEAR :lv_ename.

    SELECT SINGLE *
      FROM pa0002 INTO gwa_pa0002 WHERE pernr = pernr-pernr.

    CONCATENATE gwa_pa0002-vorna gwa_pa0002-nachn  INTO  lv_ename SEPARATED BY space.
    APPEND LINES OF git_catsdb TO git_catsdb1.
  ENDLOOP.
  "APPEND LINES OF git_catsdb TO git_catsdb1.

  PERFORM build_field_catalog.
  PERFORM add_layout.
  PERFORM print_alv_report.


ENDFORM.                    " PRINT_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_field_catalog .

  gwa_fieldcat-fieldname = 'PERNR'.
  gwa_fieldcat-seltext_l = text-001.     "'Employee Number '.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'NAME'.
  gwa_fieldcat-seltext_l = text-002.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'AWART'.
  gwa_fieldcat-seltext_l = text-003.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY1'.
  CLEAR lv_date.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS1'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY2'.
  CLEAR lv_date.
  gv_begin_date = gv_begin_date + 1.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS2'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY3'.
  CLEAR lv_date.
  gv_begin_date = gv_begin_date + 1.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS3'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY4'.
  CLEAR lv_date.
  gv_begin_date = gv_begin_date + 1.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS4'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY5'.
  CLEAR lv_date.
  gv_begin_date = gv_begin_date + 1.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS5'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY6'.
  CLEAR lv_date.
  gv_begin_date = gv_begin_date + 1.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS6'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.


  gwa_fieldcat-fieldname = 'DAY7'.
  CLEAR lv_date.
  gv_begin_date = gv_begin_date + 1.
  WRITE gv_begin_date TO lv_date MM/DD/YYYY .
  gwa_fieldcat-seltext_l = lv_date.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

  gwa_fieldcat-fieldname = 'CATSHOURS7'.
  gwa_fieldcat-seltext_l = text-015.     "'Employee Name.
  APPEND gwa_fieldcat TO git_fieldcat.
  CLEAR gwa_fieldcat.

ENDFORM.                    " BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  ADD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_layout .

  CONSTANTS : lc_x TYPE char1 VALUE 'X'.

  CLEAR : gwa_layout,
          gwa_sort.
  gwa_layout-zebra = lc_x.
  gwa_layout-colwidth_optimize = lc_x.

ENDFORM.                    " ADD_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_alv_report .
  CONSTANTS:
gc_e     TYPE c VALUE 'E'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'TOP-OF-PAGE'
      is_layout              = gwa_layout
      it_fieldcat            = git_fieldcat
    TABLES
      t_outtab               = git_output
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE text-e02 TYPE gc_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " PRINT_ALV_REPORT

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_data_new .

  DATA: l_flag(1)     TYPE c,
        lv_stdzad     TYPE pthours,
        lv_subrc      TYPE sy-subrc,
        prev_workdate TYPE catsdbcomm-workdate,
        return        TYPE bapiret2.

  FIELD-SYMBOLS: <fs_catsdbcomm>  LIKE LINE OF git_catsdbcomm,
                 <fs_catscomm1>   LIKE LINE OF git_catsdbcomm1,
                 <fs_cats_target> LIKE LINE OF git_target_hours.

  REFRESH: git_catsrecords_in.

* Read CATSDB to see if employee already entered some hours
  REFRESH git_catsdbcomm.
  CALL FUNCTION 'CATS_READ_CATSDB'
    EXPORTING
      catspernr    = pernr-pernr
      fromdate     = gv_begin_date
      todate       = gv_end_date
      void         = ' '
      changed      = 'X'
      approved     = 'X'
      free         = 'X'
      locked       = 'X'
      rejected     = 'X'
    TABLES
      i_catsdbcomm = git_catsdbcomm.

*merge and Cumulate hours entered for the same work date
  IF git_catsdbcomm IS NOT INITIAL.
    SORT git_catsdbcomm BY workdate.
    REFRESH: git_catsdbcomm1.
    CLEAR: prev_workdate.
    LOOP AT  git_catsdbcomm ASSIGNING <fs_catsdbcomm>.
      CHECK <fs_catsdbcomm>-catshours IS NOT INITIAL.
      IF prev_workdate EQ <fs_catsdbcomm>-workdate.
        <fs_catscomm1>-catshours = <fs_catscomm1>-catshours + <fs_catsdbcomm>-catshours.
      ELSE.
        UNASSIGN <fs_catscomm1>.
        APPEND INITIAL LINE TO git_catsdbcomm1 ASSIGNING <fs_catscomm1>.
        <fs_catscomm1>-pernr     = <fs_catsdbcomm>-pernr.
        <fs_catscomm1>-workdate  = <fs_catsdbcomm>-workdate.
        <fs_catscomm1>-catshours = <fs_catsdbcomm>-catshours.
      ENDIF.
      prev_workdate = <fs_catsdbcomm>-workdate.
    ENDLOOP.
  ENDIF.

*Get Target hours for each day based on data entry period
*  IF gv_begin_date IS NOT INITIAL AND gv_end_date IS NOT INITIAL.
*    CLEAR lv_subrc.
*    REFRESH git_target_hours.
*    CALL FUNCTION 'CATS_GET_TARGET_HOURS'
*      EXPORTING
*        pernr                    = pernr-pernr
*        begda                    = gv_begin_date
*        endda                    = gv_end_date
*      IMPORTING
*        subrc                    = lv_subrc
*      TABLES
*        target_hours             = git_target_hours
*      EXCEPTIONS
*        pernr_not_found          = 1
*        too_many_days            = 2
*        error_in_sap_enhancement = 3
*        OTHERS                   = 4.
*    IF lv_subrc <> 0.
** Implement suitable error handling here
*    ENDIF.
*  ELSE.
*    CLEAR gs_alv_data.
*    gs_alv_data-pernr    = pernr-pernr.
*    gs_alv_data-msg_typ  = 'E'.
*    gs_alv_data-message  = 'Data entry period cannot be determined'.
*    gs_alv_data-status   = gc_red.
*    APPEND gs_alv_data TO gt_alv_data.
*    CLEAR gs_alv_data.
*    EXIT.
*  ENDIF.

  CHECK git_target_hours IS NOT INITIAL.
  UNASSIGN <fs_cats_target>.

*Fill in CATS records to pass into BAPI
  LOOP AT git_target_hours ASSIGNING <fs_cats_target>.
    UNASSIGN <fs_catscomm1>.
    CLEAR gwa_catsrecords_in.

    IF <fs_cats_target>-stdaz IS NOT INITIAL.
      CALL FUNCTION 'CATS_CHECK_EMPLOYEE_ACTIVE'
        EXPORTING
          pernr            = pernr-pernr
          begda            = <fs_cats_target>-date
          endda            = <fs_cats_target>-date
        EXCEPTIONS
          pernr_not_found  = 1
          pernr_not_active = 2
          OTHERS           = 3.
    ENDIF.

    gwa_catsrecords_in-employeenumber = pernr-pernr.
    gwa_catsrecords_in-abs_att_type   = '2000'.

*If time already entered for a day then subtract hours entered from the target
*hours for the day and create a record with A/A type '2000'
    READ TABLE git_catsdbcomm1 ASSIGNING <fs_catscomm1>
                               WITH KEY pernr    = pernr-pernr
                                        workdate = <fs_cats_target>-date.

    IF sy-subrc EQ 0.
      gwa_catsrecords_in-workdate = <fs_cats_target>-date.
      IF <fs_catscomm1>-catshours LE <fs_cats_target>-stdaz.
        CLEAR lv_stdzad.
        lv_stdzad = <fs_cats_target>-stdaz - <fs_catscomm1>-catshours.
        gwa_catsrecords_in-catshours      = lv_stdzad.
        gwa_catsrecords_in-quantity       = lv_stdzad.
      ENDIF.
    ELSE.
      gwa_catsrecords_in-workdate       = <fs_cats_target>-date.
      gwa_catsrecords_in-catshours      = <fs_cats_target>-stdaz.
      gwa_catsrecords_in-quantity       = <fs_cats_target>-stdaz.
    ENDIF.
    CHECK <fs_cats_target>-stdaz IS NOT INITIAL.
    APPEND gwa_catsrecords_in TO git_catsrecords_in.
    gv_tot_recs = gv_tot_recs + 1.
  ENDLOOP.
*  ELSE.
*    CLEAR gs_alv_data.
*    gs_alv_data-pernr    = pernr-pernr.
*    gs_alv_data-msg_typ  = 'E'.
*    gs_alv_data-message  = 'Target hours cannot be determined'.
*    gs_alv_data-status   = gc_red.
*    APPEND gs_alv_data TO gt_alv_data.
*    CLEAR gs_alv_data.
*    EXIT.
*  ENDIF.

  IF git_catsrecords_in IS NOT INITIAL.
    REFRESH: git_catsrecords_out, git_return_cats.
    CLEAR: l_flag,gwa_success,return,gwa_error,gwa_return_cats.

    IF p_test EQ abap_true.
      l_flag = 'X'.
    ELSE.
      l_flag = ''.
    ENDIF.

    CALL FUNCTION 'BAPI_CATIMESHEETMGR_INSERT'
      EXPORTING
        profile         = p_prof
        testrun         = l_flag
      TABLES
        catsrecords_in  = git_catsrecords_in
        catsrecords_out = git_catsrecords_out
        return          = git_return_cats.

    LOOP AT git_return_cats INTO gwa_return_cats.
      IF gwa_return_cats-type CA 'EA'. " Error or Abort
        PERFORM fill_msg_and_alv_data USING gwa_return_cats git_catsrecords_in[]
                                            git_target_hours[] git_catsdbcomm1[].
        IF gv_error EQ abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

*Commit only if there is no Error or Abort
    IF gwa_return_cats-type NA 'EA'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        IMPORTING
          return = return.

      PERFORM fill_msg_and_alv_data USING return git_catsrecords_in[]
                                          git_target_hours[] git_catsdbcomm1[].
    ENDIF.
  ELSE.
    CLEAR gs_alv_data.
    gs_alv_data-pernr    = pernr-pernr.
    gs_alv_data-msg_typ  = 'W'.
    gs_alv_data-message  = 'Target hours blank'.
    gs_alv_data-status   = gc_yellow.
    APPEND gs_alv_data TO gt_alv_data.
    CLEAR gs_alv_data.
    EXIT.
  ENDIF.

ENDFORM.                    " UPLOAD_DATA_NEW
*&---------------------------------------------------------------------*
*&      Form  BROWSE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_PATH1  text
*----------------------------------------------------------------------*
FORM browse_file  USING p_path TYPE any.

  cl_gui_frontend_services=>directory_browse(
   CHANGING
     selected_folder      = p_path
   EXCEPTIONS
     cntl_error           = 1
     error_no_gui         = 2
     not_supported_by_gui = 3
     OTHERS               = 4
        ).
  IF sy-subrc <> 0.

  ENDIF.

ENDFORM.                    " BROWSE_FILE

*&---------------------------------------------------------------------*
*&      Form  DEFAULT_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM default_filename .

  DATA: lv_repid TYPE sy-repid,
        lv_year  TYPE char10.

  CLEAR: p_file2 ,p_path2.

  IF p_appl EQ 'X'. "Application server
    CLEAR: p_path1, p_file1.
    IF ( p_file2 EQ ' ' OR p_path2 EQ ' ' ).
      lv_repid = sy-repid.
      PERFORM get_filename USING lv_repid CHANGING gwa_path.
      REFRESH git_pathsplit.
      SPLIT gwa_path AT gc_fslash INTO TABLE git_pathsplit.
      CLEAR gwa_path.
      gwa_path = lines( git_pathsplit ).

      IF p_file2 EQ ' ' AND NOT git_pathsplit IS INITIAL.
        READ TABLE git_pathsplit INTO gwa_pathsplit INDEX gwa_path.
        p_file2 = gwa_pathsplit.
      ENDIF.

      IF p_appl EQ abap_true.
        IF NOT git_pathsplit IS INITIAL.
          DELETE git_pathsplit INDEX gwa_path.
        ENDIF.
        CLEAR gwa_path.
        CONCATENATE LINES OF git_pathsplit
        INTO gwa_path SEPARATED BY
             gc_fslash.
        CONDENSE gwa_path.
        p_path2 = gwa_path.
      ENDIF.
    ENDIF.
  ELSE.  "Presentation server
    CLEAR:p_file1,p_path2, p_file2.
    CONCATENATE 'CATS_AUTO_LOG_' sy-datum '_'sy-uzeit '.CSV'INTO p_file1.
    IF p_path1 IS INITIAL.
      p_path1 = 'H:\'.
    ENDIF.
  ENDIF.

ENDFORM.                    " DEFAULT_FILENAME
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_REPID  text
*----------------------------------------------------------------------*
FORM get_filename  USING p_repid p_filename .

  DATA: l_logical_filename TYPE filename-fileintern.

  l_logical_filename = p_repid.

* Lookup logical file path
  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      logical_filename = l_logical_filename
      parameter_1      = 'CATS_AUTO_LOG'
      parameter_2      = 'CSV'
*     PARAMETER_3      = ' '
    IMPORTING
      file_name        = p_filename
    EXCEPTIONS
      file_not_found   = 1
      OTHERS           = 2.

ENDFORM.                    " GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  ALV_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_display .

  IF lines( gt_alv_data ) GE 1.
    PERFORM build_fieldcatalog.
    PERFORM build_layout.
    PERFORM display_alv.
  ELSE.
    WRITE:/ 'No data to process'.
  ENDIF.

ENDFORM.                    " ALV_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_fieldcatalog .

*Need to read table structure because ALV header text needs to be read
*from the structure and all the fields in the structure are defined as
*predefined data type

  DATA: it_comp_file TYPE TABLE OF rstrucinfo,
        wa_comp      TYPE rstrucinfo,
        wa_alv_fcat  TYPE slis_fieldcat_alv.

  CALL FUNCTION 'GET_COMPONENT_LIST'
    EXPORTING
      program    = sy-repid
      fieldname  = 'GS_ALV_DATA'
    TABLES
      components = it_comp_file.

  REFRESH: gt_fieldcatalog.

  LOOP AT it_comp_file INTO wa_comp.
    CLEAR: wa_alv_fcat.
    wa_alv_fcat-fieldname     = wa_comp-compname.

    IF wa_comp-compname EQ 'PERNR'.

      wa_alv_fcat-seltext_l     = 'Pers. No.'.
      wa_alv_fcat-seltext_m     = 'Pers. No.'.
      wa_alv_fcat-seltext_s     = 'Personnel #'.

    ELSEIF wa_comp-compname EQ 'MESSAGE'.

      wa_alv_fcat-seltext_l     = 'Message'.
      wa_alv_fcat-seltext_m     = 'Message'.
      wa_alv_fcat-seltext_s     = 'Message'.

    ELSEIF wa_comp-compname EQ 'TARGET_HR'.

      wa_alv_fcat-seltext_l     = 'Target Hours'.
      wa_alv_fcat-seltext_m     = 'Target hrs'.
      wa_alv_fcat-seltext_s     = 'Target hrs'.

    ELSEIF wa_comp-compname EQ 'HOURS_ENT'.

      wa_alv_fcat-seltext_l     = 'Already Entered Hours'.
      wa_alv_fcat-seltext_m     = 'Hrs Entered'.
      wa_alv_fcat-seltext_s     = 'Hrs Entered'.

    ELSEIF wa_comp-compname EQ 'CATSHOURS'.

      wa_alv_fcat-seltext_l     = 'Auto filled Hours'.
      wa_alv_fcat-seltext_m     = 'Auto filled Hours'.
      wa_alv_fcat-seltext_s     = 'Auto Hours'.

    ELSEIF wa_comp-compname EQ 'MSG_TYP'.

      wa_alv_fcat-seltext_l     = 'Messsage Type'.
      wa_alv_fcat-seltext_m     = 'Msg Type'.
      wa_alv_fcat-seltext_s     = 'Msg Type'.

    ELSEIF wa_comp-compname EQ 'AWART'.

      wa_alv_fcat-seltext_l     = 'Abs/Att Type'.
      wa_alv_fcat-seltext_m     = 'Abs/Att'.
      wa_alv_fcat-seltext_s     = 'A/A Type'.

    ELSEIF wa_comp-compname EQ 'WORKDATE'.

      wa_alv_fcat-seltext_l     = 'Work Date'.
      wa_alv_fcat-seltext_m     = 'Work Date'.
      wa_alv_fcat-seltext_s     = 'Date'.

    ELSEIF wa_comp-compname EQ 'STATUS'.
      wa_alv_fcat-fieldname     = 'STATUS'.
      wa_alv_fcat-seltext_l     = 'Msg Category'.
      wa_alv_fcat-seltext_m     = 'Category'.
      wa_alv_fcat-seltext_s     = 'Category'.
      wa_alv_fcat-icon          = 'X'.  " Display the field as ICON
      wa_alv_fcat-edit          = ' '.
    ENDIF.

    APPEND wa_alv_fcat TO gt_fieldcatalog.
  ENDLOOP.


ENDFORM.                    " BUILD_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_layout .

  gv_layout-no_input          = 'X'.
  gv_layout-colwidth_optimize = 'X'.
  gv_layout-zebra             = 'X'.


ENDFORM.                    " BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  DATA: lv_repid    TYPE sy-repid,
        lt_alv_data TYPE STANDARD TABLE OF ty_alv_data.

  lt_alv_data[] = gt_alv_data[].

  IF p_err EQ 'X'.
    DELETE lt_alv_data WHERE msg_typ EQ 'S'.
  ENDIF.

  lv_repid = sy-repid.

  SORT gt_alv_data.
  DELETE ADJACENT DUPLICATES FROM gt_alv_data.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = lv_repid
      i_callback_top_of_page = 'TOP-OF-PAGE' "see subroutine
      is_layout              = gv_layout
      it_fieldcat            = gt_fieldcatalog[]
    TABLES
      t_outtab               = lt_alv_data
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.

  IF sy-subrc <> 0.
    WRITE: / 'ALV Display error'.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV


*&---------------------------------------------------------------------*
*&      Form  FILL_MSG_AND_ALV_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_RETURN_CATS  text
*      -->P_GIT_CATSRECORDS_IN[]  text
*----------------------------------------------------------------------*
FORM fill_msg_and_alv_data  USING p_return      TYPE bapiret2
                                  p_catsrecords TYPE ty_catsrecords
                                  pt_targethrs  TYPE ty_t_target_hr
                                  pt_catsdbcomm TYPE ty_t_catsdbcomm1.

  DATA: ls_record    TYPE LINE OF ty_catsrecords,
        lv_hours     TYPE char8,
        lv_target_hr TYPE char8,
        lv_hrs_ent   TYPE char8,
        ls_attach    LIKE LINE OF gt_attach,
        lv_lines     TYPE i,
        ls_target    TYPE LINE OF ty_t_target_hr,
        ls_catsdbcomm TYPE LINE OF ty_t_catsdbcomm1.

  CLEAR: gs_alv_data,gv_error.

  IF p_return-type CA 'EA'.  "Errot/Abort occured
    LOOP AT p_catsrecords INTO ls_record.
      CLEAR: gs_alv_data, ls_target, ls_catsdbcomm.
      gs_alv_data-pernr     = pernr-pernr.
      gs_alv_data-msg_typ   = p_return-type.
      gs_alv_data-message   = p_return-message.
      REPLACE ALL OCCURRENCES OF ',' IN gs_alv_data-message WITH space.
      CONDENSE gs_alv_data-message.
      gs_alv_data-status    = gc_red.
      gs_alv_data-workdate  = ls_record-workdate.
      gs_alv_data-awart     = ls_record-abs_att_type.
*      gs_alv_data-catshours = ls_record-catshours.
      READ TABLE pt_targethrs INTO ls_target
                              WITH KEY date = ls_record-workdate
                              BINARY SEARCH.
      IF sy-subrc EQ 0.
        gs_alv_data-target_hr = ls_target-stdaz.
      ENDIF.

      READ TABLE pt_catsdbcomm INTO ls_catsdbcomm
                               WITH KEY pernr     = pernr-pernr
                                        workdate  = ls_record-workdate
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        gs_alv_data-hours_ent = ls_catsdbcomm-catshours.
      ENDIF.

      IF ls_target-stdaz IS NOT INITIAL AND
         ls_catsdbcomm-catshours IS NOT INITIAL AND
         ls_catsdbcomm-catshours GE ls_target-stdaz.

      ENDIF.
      APPEND gs_alv_data TO gt_alv_data.
      gv_tot_fail = gv_tot_fail + 1.
    ENDLOOP.
    gv_error = abap_true.
  ELSE.
*    IF p_all EQ 'X'. "If error & success report requested
    LOOP AT p_catsrecords INTO ls_record.
      CLEAR: gs_alv_data, ls_target, ls_catsdbcomm.

      gs_alv_data-pernr     = pernr-pernr.
      gs_alv_data-msg_typ   = 'S'.
      gs_alv_data-status    = gc_green.
      gs_alv_data-workdate  = ls_record-workdate.
      gs_alv_data-awart     = ls_record-abs_att_type.
      gs_alv_data-catshours = ls_record-catshours.
      gs_alv_data-message   = 'Success'.

      READ TABLE pt_targethrs INTO ls_target
                              WITH KEY date = ls_record-workdate
                              BINARY SEARCH.
      IF sy-subrc EQ 0.
        gs_alv_data-target_hr = ls_target-stdaz.
      ENDIF.

      READ TABLE pt_catsdbcomm INTO ls_catsdbcomm
                               WITH KEY pernr     = pernr-pernr
                                        workdate  = ls_record-workdate
                                        BINARY SEARCH.
      IF sy-subrc EQ 0.
        gs_alv_data-hours_ent = ls_catsdbcomm-catshours.
        IF ls_catsdbcomm-catshours IS NOT INITIAL AND
           ls_target-stdaz         IS NOT INITIAL AND
           ls_catsdbcomm-catshours GE ls_target-stdaz.
          gs_alv_data-message   = 'Target hours already entered'.
          gs_alv_data-msg_typ   = 'W'.
          gs_alv_data-status    = gc_yellow.
        ELSE.
          gs_alv_data-message   = 'Partial hours already entered'.
        ENDIF.
      ENDIF.

      APPEND gs_alv_data TO gt_alv_data.
      gv_tot_suc     = gv_tot_suc + 1.
    ENDLOOP.
    gv_tot_suc_hrs = gv_tot_suc_hrs + gv_tot_hrs_pernr.
*    ELSE. "Only error report requested, Just add up
*      lv_lines       = lines( p_catsrecords ).
*      gv_tot_suc     = gv_tot_suc + lv_lines.
*      gv_tot_suc_hrs = gv_tot_suc_hrs + gv_tot_hrs_pernr.
*    ENDIF.
  ENDIF.

*If error report in email is requested then fill attachment table
*  IF s_ids[] IS NOT INITIAL AND gt_alv_data[] IS NOT INITIAL.
*    LOOP AT gt_alv_data INTO gs_alv_data.
*      lv_hours = gs_alv_data-catshours.
*      CONDENSE lv_hours.
*      lv_target_hr = gs_alv_data-target_hr.
*      CONDENSE lv_target_hr.
*      lv_hrs_ent = gs_alv_data-hours_ent.
*      CONDENSE lv_hrs_ent.
*
*      CONCATENATE gs_alv_data-pernr
*                  gs_alv_data-workdate
*                  gs_alv_data-awart
*                  lv_target_hr
*                  lv_hrs_ent
*                  lv_hours
*                  gs_alv_data-msg_typ
*                  gs_alv_data-message
*                  INTO ls_attach SEPARATED BY con_tab.
*      CONCATENATE con_cret ls_attach INTO ls_attach.
*      APPEND ls_attach TO gt_attach.
*    ENDLOOP.
*  ENDIF.

ENDFORM.                    " FILL_MSG_AND_ALV_DATA

*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_email .

  DATA: lt_bodytext TYPE bcsy_text,
        lv_text     TYPE so_text255,
        lv_subj     TYPE so_obj_des,
        lt_ids      TYPE STANDARD TABLE OF ad_smtpadr,
        ls_id       LIKE LINE OF lt_ids.

  FIELD-SYMBOLS: <fs_alv_data> LIKE LINE OF gt_alv_data.

  IF s_ids[]     IS NOT INITIAL AND
     gt_attach[] IS NOT INITIAL.

    lv_subj = 'CATS Auto load error'.

    lv_text = 'Please check attached error file for details'.
    APPEND lv_text TO lt_bodytext.

    LOOP AT s_ids.
      ls_id    = s_ids-low.
      APPEND ls_id TO lt_ids.
    ENDLOOP.

    PERFORM transmit_email USING s_ids[] lt_bodytext[] lv_subj
                                 gt_attach[] 'CATS_AUTO_ERR'.
  ENDIF.

ENDFORM.                    " SEND_EMAIL

*&---------------------------------------------------------------------*
*&      Form  TRANSMIT_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transmit_email USING im_ids       TYPE STANDARD TABLE
                          im_body_txt  TYPE bcsy_text
                          im_subj      TYPE any
                          im_attach    TYPE soli_tab
                          im_att_name  TYPE any.

  DATA: l_send_request   TYPE REF TO cl_bcs,            " Send request
        l_sender         TYPE REF TO if_sender_bcs,     " Sender address
        l_recipient      TYPE REF TO if_recipient_bcs,  " Recipient
        l_email          TYPE ad_smtpadr,               " Email ID
        l_sent_to_all    TYPE os_boolean,
        bcs_exception    TYPE REF TO cx_bcs,
        ls_ex            TYPE REF TO cx_root,
        lv_msg           TYPE string,
        requested_status TYPE bcs_rqst VALUE 'E',
        status_mail      TYPE bcs_stml.

  DATA: l_extension      TYPE soodk-objtp VALUE 'XLS', " Excel format
        l_size           TYPE sood-objlen,             " Attachment size
        att_name         TYPE sood-objdes,
        l_lines          TYPE i,                       " Line count
        l_document       TYPE REF TO cl_document_bcs,   " Mail body
        l_id             TYPE string.

  TRY.
* Creates persistent send request
      l_send_request = cl_bcs=>create_persistent( ).
* Create document for mail body
      TRY.
          l_document = cl_document_bcs=>create_document(
                       i_type    = 'RAW'
                       i_text    = im_body_txt  " Mail body
                       i_subject = im_subj ).
        CATCH cx_document_bcs INTO ls_ex.
          lv_msg  = ls_ex->get_text( ).
      ENDTRY.

*  Process data for attachment
      IF im_attach[] IS NOT INITIAL.
        l_lines = lines(  im_attach ).
        l_size = l_lines * 255.
        CONCATENATE im_att_name sy-datum '_' sy-uzeit INTO att_name.
        CALL METHOD l_document->add_attachment
          EXPORTING
            i_attachment_type    = l_extension
            i_attachment_subject = att_name
            i_attachment_size    = l_size
            i_att_content_text   = im_attach. " Attachment for serror record
      ENDIF.
* Add the document to send request
      TRY.
          CALL METHOD l_send_request->set_document( l_document ).
        CATCH cx_send_req_bcs INTO ls_ex.
          lv_msg  = ls_ex->get_text( ).
      ENDTRY.

* Sender addess
      l_sender = cl_sapuser_bcs=>create( sy-uname ).
      CALL METHOD l_send_request->set_sender
        EXPORTING
          i_sender = l_sender.

      IF im_ids[] IS NOT INITIAL.
        LOOP AT  im_ids INTO l_id.
          l_email = l_id.
          TRY.
              l_recipient = cl_cam_address_bcs=>create_internet_address( l_email ).
            CATCH cx_address_bcs INTO ls_ex.
              lv_msg  = ls_ex->get_text( ).
          ENDTRY.
*        Add recipient address to send request
          TRY.
              CALL METHOD l_send_request->add_recipient
                EXPORTING
                  i_recipient  = l_recipient
                  i_express    = 'X'
                  i_copy       = ' '
                  i_blind_copy = ' '
                  i_no_forward = ' '.
            CATCH cx_send_req_bcs INTO ls_ex.
              lv_msg  = ls_ex->get_text( ).
          ENDTRY.
        ENDLOOP.
      ENDIF.

* Set that you don't need a Return Status E-mail
      status_mail = requested_status.
      CALL METHOD l_send_request->set_status_attributes
        EXPORTING
          i_requested_status = requested_status
          i_status_mail      = status_mail.

* Trigger E-Mail immediately
      l_send_request->set_send_immediately( 'X' ).
* Send mail
      CLEAR l_sent_to_all.
      TRY.
          CALL METHOD l_send_request->send
            RECEIVING
              result = l_sent_to_all.

        CATCH cx_send_req_bcs INTO ls_ex.
          lv_msg  = ls_ex->get_text( ).
      ENDTRY.

    CATCH cx_bcs INTO ls_ex.
      lv_msg  = ls_ex->get_text( ).
  ENDTRY.

ENDFORM.                    " TRANSMIT_EMAIL

*&---------------------------------------------------------------------*
*&      Form  RESTRICT_SELECT_OPTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM restrict_select_options .

  TYPE-POOLS: sscr.

  DATA: t_ass_tab  TYPE sscr_ass,
        t_opt_list TYPE sscr_opt_list,
        restrict   TYPE sscr_restrict.

* Create t_ass_tab entry to show we're restricting select-option S_BUKRS.
  CLEAR t_ass_tab.
  t_ass_tab-kind    = 'S'.
  t_ass_tab-name    = 'S_IDS'.
  t_ass_tab-sg_main = 'I'.
  t_ass_tab-op_main = 'EXCLUSION'.
  APPEND t_ass_tab TO restrict-ass_tab.

  CLEAR t_opt_list.
  t_opt_list-name       = 'EXCLUSION'.
  t_opt_list-options-bt = space.     "Do not permit BETWEEN
  t_opt_list-options-cp = space.     "Do not permit MATCHES-PATTERN
  t_opt_list-options-eq = 'X'.       " Permit EQUALS
  t_opt_list-options-ge = space.     "Do not permit GREATER-OR-EQUAL
  t_opt_list-options-gt = space.     "Do not permit GREATER-THAN
  t_opt_list-options-le = space.     "Do not permit LESS-OR-EQUAL
  t_opt_list-options-lt = space.     "Do not permit LESS-THAN
  t_opt_list-options-nb = space.     "Do not permit NOT-BETWEEN
  t_opt_list-options-ne = space.     "Do not permit NOT-EQUAL
  t_opt_list-options-np = space.     "Do not permit NO-PATTERN-MATCH
  APPEND t_opt_list TO restrict-opt_list_tab.

  CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
    EXPORTING
      restriction            = restrict
    EXCEPTIONS
      too_late               = 1
      repeated               = 2
      selopt_without_options = 3
      selopt_without_signs   = 4
      invalid_sign           = 5
      empty_option_list      = 6
      invalid_kind           = 7
      repeated_kind_a        = 8
      OTHERS                 = 9.

  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " RESTRICT_SELECT_OPTIONS

*&---------------------------------------------------------------------*
*&      Form  TOP-OF-PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top-of-page.
*ALV Header declarations
  DATA: t_header   TYPE slis_t_listheader,
        wa_header  TYPE slis_listheader,
        lv_tot_hrs TYPE char20,
        t_line     LIKE wa_header-info,
        ld_lines   TYPE i,
        ld_linesc(10)   TYPE c.
*TITLE
  wa_header-typ = 'H'.
  wa_header-info = 'Report Summary'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

*DATE
  wa_header-typ = 'S'.
  wa_header-key = 'Date: '.
  CONCATENATE sy-datum+4(2) '/' sy-datum+6(2) '/'
  sy-datum(4) INTO wa_header-info. "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

  wa_header-typ = 'S'.
  wa_header-key = ' '.
  wa_header-info = ' '.
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

*TOTAL NO. OF RECORDS SELECTED
  wa_header-typ  = 'S'.
  wa_header-key  = 'Total Employess :'.
  SHIFT gv_tot_ee LEFT DELETING LEADING '0'.
  wa_header-info = gv_tot_ee.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

*Total number of records for processing
  wa_header-typ  = 'S'.
  wa_header-key  = '# of Target Recs :'.
  SHIFT gv_tot_recs LEFT DELETING LEADING '0'.
  wa_header-info = gv_tot_recs.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

*Total number of records failed
  wa_header-typ = 'S'.
  wa_header-key  = 'Total Failed Recs :'.
  SHIFT gv_tot_fail LEFT DELETING LEADING '0'.
  wa_header-info = gv_tot_fail.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

*Total number of successful records
  wa_header-typ  = 'S'.
  wa_header-key  = 'Total Succ. Recs :'.
  SHIFT gv_tot_suc LEFT DELETING LEADING '0'.
  wa_header-info = gv_tot_suc.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

*Total number of successful hours
  wa_header-typ  = 'S'.
  wa_header-key  = 'Total Succ. Hrs :'.
  lv_tot_hrs = gv_tot_suc_hrs.
  SHIFT lv_tot_hrs LEFT DELETING LEADING '0'.
  wa_header-info = lv_tot_hrs.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.


ENDFORM.                    "APPLICATION_SERVER

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_ENTRY_PERIOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_END_DATE  text
*      -->P_GV_BEGIN_DATE  text
*----------------------------------------------------------------------*
FORM get_data_entry_period  USING p_end_date p_begin_date.

  DATA: ls_date  LIKE LINE OF git_dates,
        lv_begda TYPE catsdate,
        lv_day   TYPE sy-tabix.

  PERFORM set_week USING pn-begda catsfields-catsweek.
  PERFORM get_boundaries USING pn-begda
                               p_begin_date
                               p_end_date
                               catsfields-catsweek
                               days_on_screen.

  IF p_begin_date    IS NOT INITIAL AND
     p_end_date     IS NOT INITIAL  AND
     days_on_screen IS NOT INITIAL.

    lv_begda = p_begin_date.
    WHILE lv_day LT days_on_screen.
      ls_date-date = lv_begda + lv_day.
      APPEND ls_date TO git_dates.
      lv_day = lv_day + 1.
    ENDWHILE.
  ELSE.
    CLEAR gs_alv_data.
    gs_alv_data-pernr    = pernr-pernr.
    gs_alv_data-msg_typ  = 'E'.
    gs_alv_data-message  = 'Data entry period cannot be determined'.
    gs_alv_data-status   = gc_red.
    APPEND gs_alv_data TO gt_alv_data.
    CLEAR gs_alv_data.
    REJECT.
  ENDIF.

ENDFORM.                    " GET_DATA_ENTRY_PERIOD

*&---------------------------------------------------------------------*
*&      Form  SET_WEEK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_KEY_DATE  text
*      -->P_CATSFIELDS_CATSWEEK  text
*----------------------------------------------------------------------*
FORM set_week USING udate TYPE sy-datum
                    week  TYPE catsfields-catsweek.

* determing the week, keep an eye on first day of week.
  udate = udate + tcats-firstdayof.
  CALL FUNCTION 'DATE_GET_WEEK'
    EXPORTING
      date         = udate
    IMPORTING
      week         = week
    EXCEPTIONS
      date_invalid = 1
      OTHERS       = 2.
  IF sy-subrc NE 0.

  ENDIF.
  udate = udate - tcats-firstdayof.

ENDFORM.                    " SET_WEEK

*&---------------------------------------------------------------------*
*&      Form  GET_BOUNDARIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CATSFIELDS_INPUTDATE  text
*      -->P_CATSFIELDS_DATEFROM  text
*      -->P_CATSFIELDS_DATETO  text
*      -->P_CATSFIELDS_CATSWEEK  text
*      -->P_DAYS_ON_SCREEN  text
*----------------------------------------------------------------------*
FORM get_boundaries  USING sdate TYPE sy-datum
                           fdate TYPE sy-datum
                           tdate TYPE sy-datum
                           week  TYPE catsfields-catsweek
                           udays_on_screen TYPE any.

  DATA: udate TYPE sy-datum.

  IF tcats-pertype = pertype-daily.
    udays_on_screen = tcats-catsperiod.
    fdate = sdate.
    tdate = sdate + udays_on_screen - 1.
  ELSEIF tcats-pertype = pertype-weekly.
    udays_on_screen = tcats-catsperiod * days_of_a_week.
    CALL FUNCTION 'WEEK_GET_FIRST_DAY'
      EXPORTING
        week         = week
      IMPORTING
        date         = fdate
      EXCEPTIONS
        week_invalid = 1
        OTHERS       = 2.
    IF sy-subrc NE 0.

    ENDIF.
* Modify first day
    fdate = fdate - tcats-firstdayof.
    tdate = fdate + udays_on_screen - const_1.
  ELSEIF tcats-pertype = pertype-halfmonthly.
    fdate = sdate.
    udate = sdate.
    IF udate+6(2) GE const_16.
      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = fdate
        IMPORTING
          last_day_of_month = tdate
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.
      IF sy-subrc NE 0.
      ENDIF.
      fdate+6(2) = '16'.
    ELSE.
      fdate+6(2) = '01'.
      tdate = fdate.
      tdate+6(2) = '15'.
    ENDIF.
    udays_on_screen = tdate - fdate + const_1.
  ELSEIF tcats-pertype = pertype-monthly.
    fdate = sdate.
    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = fdate
      IMPORTING
        last_day_of_month = tdate
      EXCEPTIONS
        day_in_no_date    = 1
        OTHERS            = 2.
    IF sy-subrc NE 0.
    ENDIF.
    fdate+6(2) = '01'.
    udays_on_screen = tdate - fdate + const_1.
  ELSE.
  ENDIF.

ENDFORM.                    " GET_BOUNDARIES

*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_PRESENTATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_to_presentation .

  DATA: lv_msg      TYPE string,
        lv_filename TYPE string.

  CONSTANTS lc_error_type TYPE msgty VALUE 'E'.

  REFRESH git_tab_data[].

  IF gt_alv_data[] IS NOT INITIAL.
    PERFORM build_report_summary.
    IF git_header IS NOT INITIAL.
      CLEAR gwa_header.
      LOOP AT  git_header INTO  gwa_header.
        CLEAR gwa_tab_data.
        PERFORM delimit_record USING gwa_header con_comma CHANGING gwa_tab_data.
        APPEND gwa_tab_data TO git_tab_data.
      ENDLOOP.
    ENDIF.

    CLEAR gs_alv_data.
    LOOP AT gt_alv_data INTO gs_alv_data.
      CLEAR gwa_tab_data.
      PERFORM delimit_record USING gs_alv_data con_comma CHANGING gwa_tab_data.
      APPEND gwa_tab_data TO git_tab_data.
    ENDLOOP.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = text-d05.

* Data File
    CONCATENATE gwa_fold1 gwa_fname1 INTO lv_filename
                                     SEPARATED BY gc_fslash.
    IF p_prd EQ gc_x.
      PERFORM download_to_pc USING lv_filename git_tab_data[] lv_msg.
      IF lv_msg NE ' '.
        CONCATENATE 'Error Writing log File -' lv_msg INTO lv_msg.
        MESSAGE lv_msg TYPE lc_error_type.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " WRITE_TO_PRESENTATION

*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_APPL_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_to_appl_server .

  DATA: lv_rptfile TYPE string, " Report file name
        lv_msg     TYPE string. " Error message

  CONSTANTS lc_error_type TYPE msgty VALUE 'E'.

  REFRESH git_tab_data[].

* Write data file to Application server
  IF gt_alv_data[] IS NOT INITIAL .
    PERFORM build_report_summary.
    IF git_header IS NOT INITIAL.
      CLEAR gwa_header.
      LOOP AT  git_header INTO  gwa_header.
        CLEAR gwa_tab_data.
        PERFORM delimit_record USING gwa_header con_comma CHANGING gwa_tab_data.
        APPEND gwa_tab_data TO git_tab_data.
      ENDLOOP.
    ENDIF.

    CLEAR gs_alv_data .
    LOOP AT gt_alv_data[] INTO gs_alv_data .
      CLEAR gwa_tab_data.
      PERFORM delimit_record USING gs_alv_data con_comma CHANGING gwa_tab_data.
      APPEND gwa_tab_data TO git_tab_data.
    ENDLOOP.

    CONCATENATE p_path2 p_file2 INTO lv_rptfile SEPARATED BY gc_fslash.

    IF p_prd EQ gc_x.
      PERFORM write_to_file_server USING lv_rptfile git_tab_data[] lv_msg.
      IF lv_msg NE ' '.
        CONCATENATE 'Error Writing log File -' lv_msg INTO lv_msg.
        MESSAGE lv_msg TYPE lc_error_type.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " WRITE_TO_APPL_SERVER

*&---------------------------------------------------------------------*
*&      Form  DELIMIT_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_HEADER  text
*      <--P_GWA_TAB_DATA  text
*----------------------------------------------------------------------*
FORM delimit_record  USING im_rec TYPE any  p_delimiter TYPE any
                     CHANGING ex_outrec TYPE any.

  DATA: l_fields TYPE i,
        l_type(1).

  FIELD-SYMBOLS: <fld>  TYPE  any.

  DESCRIBE FIELD im_rec TYPE l_type COMPONENTS l_fields.
  DO l_fields TIMES.
    CHECK sy-index NE l_fields.  "Do not need to concatenate last column
    ASSIGN COMPONENT sy-index OF STRUCTURE im_rec TO <fld>.
    IF sy-index = 1.
      ex_outrec = <fld>.
    ELSE.
      CONCATENATE ex_outrec  <fld>
             INTO ex_outrec SEPARATED BY p_delimiter.
    ENDIF.
  ENDDO.

ENDFORM.                    " DELIMIT_RECORD

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_TO_PC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FILENAME  text
*----------------------------------------------------------------------*
FORM download_to_pc  USING p_filename TYPE any
                           pt_data_tab TYPE STANDARD TABLE
                           p_msg TYPE any.

  DATA: l_filename TYPE string,
        im_delim   TYPE flag VALUE space.

  l_filename = p_filename.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = l_filename
      write_field_separator   = im_delim
    TABLES
      data_tab                = pt_data_tab
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc EQ '1'.
    p_msg = 'file_write_error'.
  ELSEIF sy-subrc EQ '2'.
    p_msg = 'no_batch'.
  ELSEIF sy-subrc EQ '3'.
    p_msg = 'gui_refuse_filetransfer'.
  ELSEIF sy-subrc EQ '4'.
    p_msg = 'invalid_type'.
  ELSEIF sy-subrc EQ '5'.
    p_msg = 'no_authority'.
  ELSEIF sy-subrc EQ '6'.
    p_msg = 'unknown_error'.
  ELSEIF sy-subrc EQ '7'.
    p_msg = 'header_not_allowed'.
  ELSEIF sy-subrc EQ '8'.
    p_msg = 'separator_not_allowed'.
  ELSEIF sy-subrc EQ '9'.
    p_msg = 'filesize_not_allowed'.
  ELSEIF sy-subrc EQ '10'.
    p_msg = 'header_too_long'.
  ELSEIF sy-subrc EQ '11'.
    p_msg = 'dp_error_create'.
  ELSEIF sy-subrc EQ '12'.
    p_msg = 'dp_error_send'.
  ELSEIF sy-subrc EQ '13'.
    p_msg = 'dp_error_write'.
  ELSEIF sy-subrc EQ '14'.
    p_msg = 'unknown_dp_error'.
  ELSEIF sy-subrc EQ '15'.
    p_msg = 'access_denied'.
  ELSEIF sy-subrc EQ '16'.
    p_msg = 'dp_out_of_memory'.
  ELSEIF sy-subrc EQ '17'.
    p_msg = 'disk_full'.
  ELSEIF sy-subrc EQ '18'.
    p_msg = 'dp_timeout'.
  ELSEIF sy-subrc EQ '19'.
    p_msg = 'file_not_found'.
  ELSEIF sy-subrc EQ '20'.
    p_msg = 'dataprovider_exception'.
  ELSEIF sy-subrc EQ '21'.
    p_msg = 'control_flush_error'.
  ELSEIF sy-subrc EQ '22'.
    p_msg = 'others'.
  ENDIF.


ENDFORM.                    " DOWNLOAD_TO_PC

*&---------------------------------------------------------------------*
*&      Form  WRITE_TO_FILE_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_RPTFILE  text
*      -->P_GIT_TAB_DATA[]  text
*      -->P_LV_MSG  text
*----------------------------------------------------------------------*
FORM write_to_file_server  USING  p_filename  TYPE any
                                  pt_data_tab TYPE STANDARD TABLE
                                  p_msg       TYPE any.
  DATA:lv_file1 TYPE string.

  FIELD-SYMBOLS: <f_t_table> TYPE any.

  lv_file1 = p_filename.
  OPEN DATASET lv_file1 FOR OUTPUT IN TEXT MODE ENCODING DEFAULT MESSAGE p_msg.
  IF sy-subrc EQ 0.
    LOOP AT pt_data_tab ASSIGNING <f_t_table> .
      TRANSFER <f_t_table> TO lv_file1.
    ENDLOOP.
    CLOSE DATASET lv_file1.
  ENDIF.

ENDFORM.                    " WRITE_TO_FILE_SERVER

*&---------------------------------------------------------------------*
*&      Form  BUILD_REPORT_SUMMARY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_report_summary .

  DATA:lv_val TYPE string.

  CLEAR: gwa_tab_data.
  gwa_tab_data = 'Report Summary:'.
  APPEND gwa_tab_data TO git_tab_data.

  CLEAR: gwa_tab_data.
  CONCATENATE sy-datum+4(2) '/' sy-datum+6(2) '/' sy-datum(4) INTO lv_val.
  CONCATENATE 'Date' lv_val INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.
  CLEAR: lv_val.

  CLEAR: gwa_tab_data.
  CONCATENATE 'Run by' sy-uname INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.

  CLEAR: gwa_tab_data.
  CONCATENATE 'Total Employess' gv_tot_ee INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.

  CLEAR: gwa_tab_data.
  CONCATENATE '# of Target Recs' gv_tot_recs INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.

  CLEAR: gwa_tab_data.
  CONCATENATE 'Total Failed Recs' gv_tot_fail INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.

  CLEAR: gwa_tab_data.
  CONCATENATE 'Total Succ. Recs' gv_tot_suc INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.

  CLEAR: gwa_tab_data.
  lv_val = gv_tot_suc_hrs.
  SHIFT lv_val LEFT DELETING LEADING '0'.
  CONCATENATE 'Total Succ. Hrs' lv_val INTO gwa_tab_data SEPARATED BY con_comma.
  APPEND gwa_tab_data TO git_tab_data.

  APPEND space TO git_tab_data.
  APPEND 'Report Details:' TO git_tab_data.
  CLEAR: gwa_tab_data.

ENDFORM.                    " BUILD_REPORT_SUMMARY

*&---------------------------------------------------------------------*
*&      Form  POPULATE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM populate_header .

  REFRESH git_header.
  CLEAR gwa_header.
  MOVE  'Personnel No.'         TO gwa_header-pernr .
  MOVE  'Work Date'             TO gwa_header-workdate .
  MOVE  'A/A Type'              TO gwa_header-awart .
  MOVE  'Target Hrs'            TO gwa_header-target_hr  .
  MOVE  'Hours Already Entered' TO gwa_header-hours_ent  .
  MOVE  'Auto Filled Hours'     TO gwa_header-catshours  .
  MOVE  'Msg Type'              TO gwa_header-msg_typ .
  MOVE  'Message'               TO gwa_header-message .
  MOVE  'Status'                TO gwa_header-status.
  APPEND gwa_header TO  git_header.

ENDFORM.                    " POPULATE_HEADER

*&---------------------------------------------------------------------*
*&      Form  CHECK_EMPLOYEE_IS_ACTIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_employee_is_active .

* Check how many days employee was for the date range and fill
* internal table with dates employee as active

  DATA: lt_inactive TYPE STANDARD TABLE OF ty_date,
        lv_begda    TYPE char10,
        lv_endda    TYPE char10.

  FIELD-SYMBOLS: <date> LIKE LINE OF git_dates.

*  LOOP AT git_dates ASSIGNING <date>.
*    CALL FUNCTION 'CATS_CHECK_EMPLOYEE_ACTIVE'
*      EXPORTING
*        pernr            = pernr-pernr
*        begda            = <date>-date
*        endda            = <date>-date
*      EXCEPTIONS
*        pernr_not_found  = 1
*        pernr_not_active = 2
*        OTHERS           = 3.
*    IF sy-subrc NE 0.
*      <date>-active = abap_false.
*    ELSE.
*      <date>-active = abap_true.
*    ENDIF.
*  ENDLOOP.
*
*  lt_inactive[] = git_dates[].
*
*  DELETE git_dates WHERE active EQ abap_false.
*  IF git_dates IS NOT INITIAL.
*    SORT git_dates.
*    DELETE lt_inactive WHERE active EQ abap_true.
*    IF lt_inactive IS NOT INITIAL. "Print message for the dates employee was inactive
*      LOOP AT lt_inactive ASSIGNING <date>.
*        CLEAR: gs_alv_data,lv_begda.
*        gs_alv_data-pernr    = pernr-pernr.
*        gs_alv_data-workdate = <date>-date.
*        gs_alv_data-msg_typ  = 'W'.
*        gs_alv_data-status   = gc_yellow.
*        WRITE <date>-date TO lv_begda MM/DD/YYYY.
*        gs_alv_data-message  = |Employee is not active on | && |{ lv_begda }|.
*        APPEND gs_alv_data TO gt_alv_data.
*        CLEAR gs_alv_data.
*      ENDLOOP.
*    ENDIF.
*  ELSE.  " employee is inactive for whole period
*    CLEAR: gs_alv_data, lv_begda, lv_endda.
*    gs_alv_data-pernr    = pernr-pernr.
*    gs_alv_data-msg_typ  = 'W'.
*    gs_alv_data-status   = gc_yellow.
*    WRITE gv_begin_date TO lv_begda MM/DD/YYYY.
*    WRITE gv_end_date   TO lv_endda MM/DD/YYYY.
*    gs_alv_data-message  = |Employee is not active on period: |
*                           && |{ lv_begda }| && '-' && |{ lv_endda }|.
*    APPEND gs_alv_data TO gt_alv_data.
*    CLEAR gs_alv_data.
*    REJECT.
*  ENDIF.

ENDFORM.                    " CHECK_EMPLOYEE_IS_ACTIVE

*&---------------------------------------------------------------------*
*&      Form  GET_TARGET_HOURS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_target_hours .

  DATA:lv_subrc       TYPE sy-subrc,
       "temp_target_hr TYPE ty_t_target_hr,
       lv_date        TYPE char10.

  FIELD-SYMBOLS <date> LIKE LINE OF git_dates.

  CLEAR lv_subrc.
  REFRESH git_target_hours.

*  LOOP AT git_dates ASSIGNING <date>.
*  REFRESH: temp_target_hr.
  CLEAR: lv_subrc.
  CALL FUNCTION 'CATS_GET_TARGET_HOURS'
    EXPORTING
      pernr                    = pernr-pernr
      begda                    = gv_begin_date
      endda                    = gv_end_date
    IMPORTING
      subrc                    = lv_subrc
    TABLES
      target_hours             = git_target_hours
    EXCEPTIONS
      pernr_not_found          = 1
      too_many_days            = 2
      error_in_sap_enhancement = 3
      OTHERS                   = 4.

  IF lv_subrc <> 0.
    CLEAR gs_alv_data.
    gs_alv_data-pernr    = pernr-pernr.
    gs_alv_data-msg_typ  = 'E'.
    gs_alv_data-message  = 'Target hours cannot be determined'.
    WRITE <date>-date TO lv_date MM/DD/YYYY.
    gs_alv_data-workdate = lv_date.
    gs_alv_data-status   = gc_red.
    APPEND gs_alv_data TO gt_alv_data.
    CLEAR gs_alv_data.
    gv_tot_fail = gv_tot_fail + 1.
*  ELSE.
*    APPEND LINES OF temp_target_hr TO git_target_hours.
  ENDIF.
*  ENDLOOP.

  DELETE git_target_hours WHERE stdaz IS INITIAL.

  IF git_target_hours[] IS INITIAL.
    REJECT.
  ELSE.
    SORT git_target_hours.
  ENDIF.

ENDFORM.                    " GET_TARGET_HOURS

*&---------------------------------------------------------------------*
*&      Form  PROCESS_CATS_RECORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_cats_records .

  DATA: lv_stdzad     TYPE pthours,
        return        TYPE bapiret2,
        lv_tot_hrs(7) TYPE n.

  FIELD-SYMBOLS: <fs_catscomm1>   LIKE LINE OF git_catsdbcomm1,
                 <fs_cats_target> LIKE LINE OF git_target_hours.

  CHECK git_target_hours[] IS NOT INITIAL.
  REFRESH: git_catsrecords_in.
  CLEAR: gv_tot_hrs_pernr.
*Fill in CATS records to pass into BAPI
  LOOP AT git_target_hours ASSIGNING <fs_cats_target>.
    UNASSIGN <fs_catscomm1>.
    CLEAR gwa_catsrecords_in.

    gwa_catsrecords_in-employeenumber = pernr-pernr.
    gwa_catsrecords_in-abs_att_type   = '2000'.

*If time already entered for a day then subtract hours entered from the target
*hours for the day and create a record with A/A type '2000'
    READ TABLE git_catsdbcomm1 ASSIGNING <fs_catscomm1>
                               WITH KEY pernr    = pernr-pernr
                                        workdate = <fs_cats_target>-date.

    IF sy-subrc EQ 0.
      gwa_catsrecords_in-workdate = <fs_cats_target>-date.
      IF <fs_catscomm1>-catshours LE <fs_cats_target>-stdaz.
        CLEAR lv_stdzad.
        lv_stdzad = <fs_cats_target>-stdaz - <fs_catscomm1>-catshours.
        gwa_catsrecords_in-catshours    = lv_stdzad.
        gwa_catsrecords_in-quantity     = lv_stdzad.
      ENDIF.
    ELSE.
      gwa_catsrecords_in-workdate       = <fs_cats_target>-date.
      gwa_catsrecords_in-catshours      = <fs_cats_target>-stdaz.
      gwa_catsrecords_in-quantity       = <fs_cats_target>-stdaz.
    ENDIF.
    APPEND gwa_catsrecords_in TO git_catsrecords_in.
    gv_tot_recs = gv_tot_recs + 1.
    gv_tot_hrs_pernr  = gv_tot_hrs_pernr + gwa_catsrecords_in-catshours. "Total hours for pernr
  ENDLOOP.

*Bapi processing to create CATS record
  CHECK git_catsrecords_in IS NOT INITIAL.
  REFRESH: git_catsrecords_out, git_return_cats.
  CLEAR: gwa_success,gwa_error,return,gwa_return_cats.

  CALL FUNCTION 'BAPI_CATIMESHEETMGR_INSERT'
    EXPORTING
      profile         = p_prof
      testrun         = gv_commit
    TABLES
      catsrecords_in  = git_catsrecords_in
      catsrecords_out = git_catsrecords_out
      return          = git_return_cats.

  LOOP AT git_return_cats INTO gwa_return_cats.
    IF gwa_return_cats-type CA 'EA'. " Error or Abort
      PERFORM fill_msg_and_alv_data USING gwa_return_cats git_catsrecords_in[]
                                          git_target_hours[] git_catsdbcomm1[].
      IF gv_error EQ abap_true.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

*Commit only if there is no Error or Abort
  IF gwa_return_cats-type NA 'EA'.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      IMPORTING
        return = return.

    PERFORM fill_msg_and_alv_data USING return git_catsrecords_in[]
                                        git_target_hours[] git_catsdbcomm1[].
  ENDIF.

*If no error found and error report was selected on the screen then just add
*a record with successfull message
  IF p_err EQ 'X'               AND
     gt_alv_data[] IS INITIAL   AND
     gv_tot_recs IS NOT INITIAL.
    CLEAR gs_alv_data.
    gs_alv_data-msg_typ   = 'S'.
    gs_alv_data-status    = gc_green.
    gs_alv_data-message   = 'All Data processed without any error'.
    APPEND gs_alv_data TO gt_alv_data.
  ENDIF.

ENDFORM.                    " PROCESS_CATS_RECORDS

*&---------------------------------------------------------------------*
*&      Form  READ_MERGE_EXISTING_CATS_RECS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_merge_existing_cats_recs .

  DATA: prev_workdate TYPE catsdbcomm-workdate,
        return        TYPE bapiret2.

  FIELD-SYMBOLS: <fs_catsdbcomm>  LIKE LINE OF git_catsdbcomm,
                 <fs_catscomm1>   LIKE LINE OF git_catsdbcomm1.

*Read CATSDB to see if employee already entered some hours and
*merge hours for the same work date
  REFRESH git_catsdbcomm.
  CALL FUNCTION 'CATS_READ_CATSDB'
    EXPORTING
      catspernr    = pernr-pernr
      fromdate     = gv_begin_date
      todate       = gv_end_date
      void         = ' '
      changed      = 'X'
      approved     = 'X'
      free         = 'X'
      locked       = 'X'
      rejected     = 'X'
    TABLES
      i_catsdbcomm = git_catsdbcomm.

*merge and Cumulate hours entered for the same work date
  IF git_catsdbcomm IS NOT INITIAL.
    SORT git_catsdbcomm BY workdate.
    REFRESH: git_catsdbcomm1.
    CLEAR: prev_workdate.
    LOOP AT git_catsdbcomm ASSIGNING <fs_catsdbcomm>.
      CHECK <fs_catsdbcomm>-catshours IS NOT INITIAL.
      IF prev_workdate EQ <fs_catsdbcomm>-workdate.
        IF <fs_catsdbcomm>-awart(1) EQ '2' AND <fs_catsdbcomm>-awart NE '2000'. "Overtime attendace type
          <fs_catscomm1>-overtime = <fs_catscomm1>-overtime + <fs_catsdbcomm>-catshours.
        ELSE.
          <fs_catscomm1>-catshours = <fs_catscomm1>-catshours + <fs_catsdbcomm>-catshours.
        ENDIF.
      ELSE.
        UNASSIGN <fs_catscomm1>.
        APPEND INITIAL LINE TO git_catsdbcomm1 ASSIGNING <fs_catscomm1>.
        <fs_catscomm1>-pernr     = <fs_catsdbcomm>-pernr.
        <fs_catscomm1>-workdate  = <fs_catsdbcomm>-workdate.
        IF <fs_catsdbcomm>-awart(1) EQ '2' AND <fs_catsdbcomm>-awart NE '2000'. "Overtime attendace type
          <fs_catscomm1>-overtime  = <fs_catsdbcomm>-catshours.
        ELSE.
          <fs_catscomm1>-catshours = <fs_catsdbcomm>-catshours.
        ENDIF.
      ENDIF.
      prev_workdate = <fs_catsdbcomm>-workdate.
    ENDLOOP.
    SORT git_catsdbcomm1.
  ENDIF.

ENDFORM.                    " READ_MERGE_EXISTING_CATS_RECS
