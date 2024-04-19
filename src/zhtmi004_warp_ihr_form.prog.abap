*&---------------------------------------------------------------------*
*&  Include           ZHTMI004_WARP_IHR_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELSCREEN_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_selscreen_output .
  LOOP AT SCREEN. ""include start
    IF rb_pres EQ abap_true.
      IF screen-group1 = 'F2' .
*         screen-input      = 0.
*         screen-output     = 0.
        screen-active     = 0.
        screen-invisible  = 1.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF rb_appl EQ abap_true.
      IF screen-group1 = 'F1'.
*         screen-input      = 0.
*         screen-output     = 0.
        screen-active     = 0.
        screen-invisible  = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF  screen-group1 = 'ON1'.
*      screen-input      = 0.
*      screen-output     = 0.
      screen-active     = 0.
      screen-invisible  = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.""include ends

ENDFORM.                    " F_SELSCREEN_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  DEFAULT_FILEPATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM default_filepath .
  DATA : lv_rep_file TYPE filename-fileintern.

*  IF rb_pres EQ 'X' AND rb_prod EQ 'X' ."AND p_file2 IS INITIAL.
**" Default the output report path
*    CONCATENATE text-t15 text-f00 sy-datum '_' sy-uzeit '.TXT' INTO p_file2.
*    TRANSLATE p_file2 TO UPPER CASE.
*  ENDIF.
  IF rb_pres IS NOT INITIAL.
    p_file3 = '/V:'.
  ENDIF.
*  IF p_file3 IS INITIAL.
  IF rb_appl EQ 'X' .
    PERFORM get_filename.
*{   DELETE         D30K920054                                        1
*\    p_file3 = '/tmp/'.
*}   DELETE
*    p_file3 = zcl_hr_interface_util=>get_dat_filename( im_lfile = sy-repid ).
*{   DELETE         D30K920054                                        2
*\    TRANSLATE p_file3 TO UPPER CASE.
*}   DELETE

    IF rb_prod EQ 'X'.
      lv_rep_file = text-f01.
*      p_file2 = zcl_hr_interface_util=>get_dat_filename( im_lfile = lv_rep_file ).
*      TRANSLATE p_file2 TO UPPER CASE.
    ENDIF.
  ENDIF.
*  ENDIF.
ENDFORM.                    " DEFAULT_FILEPATH
*&---------------------------------------------------------------------*
*&      Form  F_SELSCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_selscreen .
  IF sscrfields-ucomm = 'ONLI' AND
             rb_pres EQ abap_true     AND
             p_file1 IS               INITIAL .

    MESSAGE 'Please enter filepath' TYPE 'E'.
  ELSEIF sscrfields-ucomm = 'ONLI' AND
         rb_appl EQ abap_true      AND
         p_file3 IS               INITIAL .
    MESSAGE 'Please enter filepath' TYPE 'E'.
  ENDIF.
ENDFORM.                    " F_SELSCREEN
*&---------------------------------------------------------------------*
*&      Form  F_VALREQ_FILE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE1  text
*----------------------------------------------------------------------*
FORM f_valreq_file1  CHANGING p_file1.
  DATA : lt_filetab TYPE filetable,
              lwa_filetab TYPE file_table,
              l_rc TYPE i.

  IF rb_pres EQ 'X'.
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
*       EXPORTING
*         window_title            =
*         default_extension       =
*         default_filename        =
*         file_filter             =
*         with_encoding           =
*         initial_directory       =
*         multiselection          =
      CHANGING
        file_table              = lt_filetab
        rc                      = l_rc
*         user_action             =
*         file_encoding           =
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5
            .
    IF sy-subrc <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      READ TABLE lt_filetab INTO lwa_filetab INDEX 1.
      p_file1 = lwa_filetab-filename.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALREQ_FILE1
*&---------------------------------------------------------------------*
*&      Form  F_VALREQ_FILE2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE2  text
*----------------------------------------------------------------------*
FORM f_valreq_file2  CHANGING p_file2.
  DATA : lv_path TYPE string.

  IF rb_pres EQ 'X'.
    CALL METHOD cl_gui_frontend_services=>directory_browse
*       EXPORTING
*         window_title         =
*         initial_folder       =
      CHANGING
        selected_folder      = lv_path
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4
            .
    IF sy-subrc <> 0.
*      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      CONCATENATE lv_path '\' text-f00 sy-datum '_' sy-uzeit '.TXT' INTO p_file2.
    ENDIF.

  ELSEIF rb_appl EQ 'X'.
*    CALL METHOD zcl_hr_interface_util=>f4_serverfile
*      RECEIVING
*        re_file = p_file2.
  ENDIF.
ENDFORM.                    " F_VALREQ_FILE2
*&---------------------------------------------------------------------*
*&      Form  READ_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_files .
  DATA : lv_filename TYPE string,
           lv_pernr(8) TYPE c,
           lv_betrg(15) TYPE c,
           lwa_filetab TYPE sdokpath,
           lwa_file1 TYPE sdokpath,
           lv_file1 TYPE string,
           l_msg TYPE string.

  DATA: lv_test TYPE text60,
        l_file1 TYPE string,
        lv_string TYPE string.

  lv_test = p_file3.

  DATA : lit_input TYPE STANDARD TABLE OF string.

  CONSTANTS : lc_delim TYPE c VALUE cl_abap_char_utilities=>horizontal_tab..


*" In case of Presenation Server, a single file will be read
  IF rb_pres = 'X'.
    lv_filename = p_file1.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_filename
        filetype                = 'ASC'
        has_field_separator     = space
      CHANGING
        data_tab                = git_input
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.
    IF sy-subrc <> 0.
      gwa_error-err_txt = text-e00.
      APPEND gwa_error TO git_error.
      CLEAR gwa_error.
      MESSAGE e003(zhr01).
    ENDIF.
  ELSEIF rb_appl EQ 'X'.
    CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
      EXPORTING
        dir_name               = lv_test                    "p_file3
      TABLES
        dir_list               = git_dir_list
      EXCEPTIONS
        invalid_eps_subdir     = 1
        sapgparam_failed       = 2
        build_directory_failed = 3
        no_authorization       = 4
        read_directory_failed  = 5
        too_many_read_errors   = 6
        empty_directory_list   = 7
        OTHERS                 = 8.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      CASE sy-subrc.
        WHEN '7'.
          MESSAGE 'EMPTY_DIRECTORY_LIST' TYPE 'I'.
          EXIT.
      ENDCASE.
    ENDIF.
    LOOP AT git_dir_list INTO gwa_dir_list.
      CLEAR l_file1.
      CONCATENATE p_file3 gwa_dir_list-name INTO l_file1.
*        lwa_file1-pathname = lv_file1.
      APPEND l_file1 TO file_table1.
      REFRESH lit_input.
      PERFORM read_appl_server TABLES lit_input
        USING l_file1.
*      CALL FUNCTION 'ZHR_APPLN_UPLOAD'
*        EXPORTING
*          lfile_path     = l_file1                          "lv_file1
*        TABLES
*          t_table        = lit_input
*        EXCEPTIONS
*          upload_error   = 1
*          upload_success = 2
*          OTHERS         = 3.
*{   REPLACE        D30K920054                                        1
*\      IF sy-subrc NE 2.   "Report error message
      IF lit_input IS  INITIAL.   "Report error message
*}   REPLACE
        CONCATENATE text-e02 lwa_filetab-pathname INTO l_msg.
        MESSAGE e016(zhr01) WITH l_msg.
      ELSE.
        APPEND LINES OF lit_input[] TO git_input[].
      ENDIF.

    ENDLOOP.

  ENDIF.
  DATA : lv_begda  TYPE char10,
         lv_unit TYPE char19.
*" populate the Internal table for processing

  LOOP AT git_input INTO gwa_input.

    SPLIT gwa_input AT lc_delim INTO lv_pernr
                                     lv_begda
                                     gwa_tab-wbs_elm
                                     gwa_tab-rec_order
                                     gwa_tab-rec_cctr
                                     gwa_tab-awart
                                     gwa_tab-versl
                                     gwa_tab-wagetype
                                     gwa_tab-unit
                                     gwa_tab-catshours.
*Choose the correnct date format. CA
*    gwa_tab-unit = lv_unit .
    PERFORM get_sap_dateformat USING lv_begda CHANGING gwa_tab-begda .

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_pernr
      IMPORTING
        output = gwa_tab-pernr.
**Convert date MMDDYYY to YYYYMMDD.
*    CONCATENATE gwa_tab-begda+4(4)
*                gwa_tab-begda+0(2)
*                gwa_tab-begda+2(2) INTO gwa_tab-begda.
    APPEND gwa_tab TO git_tab.
    CLEAR: gwa_tab, lv_pernr, lv_betrg.
  ENDLOOP.
ENDFORM.                    " READ_FILES
*&---------------------------------------------------------------------*
*&      Form  GENERATE_OUTPUT_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM generate_output_report .
*  DATA: lv_count_e TYPE i,
*            lv_count_s TYPE i,
*            lv_count TYPE i,
*            lv_txt(5) TYPE c,
*            lv_output TYPE string,
*            lv_mode TYPE c,
*            lv_high TYPE i,
*            lv_page TYPE i,
*            lv_sess TYPE char30,
*            lv_rptfile TYPE string, " Report file name
*            lv_eff_date1 TYPE char10,
*            lv_first   TYPE i,
*            lv_second  TYPE i,
*            lv_high1   TYPE i.
*
*  CLEAR: lv_count, lv_count_e, lv_count_s, lv_output, lv_txt.
*
*  SORT git_success ASCENDING.
*  SORT git_error ASCENDING.
**  DELETE ADJACENT DUPLICATES FROM git_success COMPARING begda.
**  DELETE ADJACENT DUPLICATES FROM git_error COMPARING begda.
*
*  lv_count_e = LINES( git_error ). "Error Records
*  lv_count_s = LINES( git_success ). "Success Records
*
*  lv_count = lv_count_s + lv_count_e. "Total Records
*
*  lv_output = p_file2.
****  lv_high = 40.
*  lv_high1 = 65.
*
*  IF rb_test EQ abap_true.
*    lv_mode = 'X'.
*  ELSE.
*    lv_mode = 'Y'.
*  ENDIF.
*
*  CLEAR lv_sess.
*  lv_sess = p_sess.
*
*  CALL FUNCTION 'ZHR_DISPLAY_CONTROL_TOTALS_IN'
*    EXPORTING
*      im_programname  = sy-repid
*      im_totalrecs    = lv_count
*      im_errors       = lv_count_e
*      im_outputreport = lv_output
*      im_mode         = lv_mode
*      im_session      = lv_sess "p_sess
*      im_success      = lv_count_s
*    TABLES
*      it_msg          = git_msg
*      it_file_table   = file_table1.
*
*  git_msg1[] = git_msg[].
*  DESCRIBE TABLE git_msg1 LINES lv_first.
*  lv_page = 1.
*
**" Append Error records to the output report - table git_msg
*  LOOP AT git_error INTO gwa_error.
*    IF sy-tabix EQ 1.
*      gwa_msg+0(10) = text-006.
*      gwa_msg+11(8) = text-007.
*      gwa_msg+20(12) = text-008.
*      gwa_msg+35(30) = text-009.
*      gwa_msg+70(25) = text-011.
*      gwa_msg+100(150) = text-010.
*      APPEND gwa_msg TO git_msg.
*      CLEAR gwa_msg.
*      lv_high = lv_first + 1.
*    ENDIF.
**
*    lv_high = lv_high + 1.
*    gwa_msg+0(10) = gwa_error-pernr.
*    gwa_msg+11(8) = gwa_error-begda.
*    gwa_msg+20(12) = gwa_error-wbs_elm.
*    gwa_msg+35(30) = gwa_error-awart.
*    gwa_msg+70(25) = gwa_error-catshours.
*    gwa_msg+100(150) = gwa_error-err_txt.
*    APPEND gwa_msg TO git_msg.
*    CLEAR gwa_msg.
*
****    IF sy-tabix EQ lv_high.
*    IF lv_high = lv_high1.
*      lv_page = lv_page + 1.
*      REFRESH git_msg1.
*      CALL FUNCTION 'ZHR_DISPLAY_CONTROL_TOTALS_IN'
*        EXPORTING
*          im_pageno       = lv_page
*          im_programname  = sy-repid
*          im_totalrecs    = lv_count
*          im_errors       = lv_count_e
*          im_outputreport = lv_output
*          im_mode         = lv_mode
*          im_session      = lv_sess "p_sess
*          im_success      = lv_count_s
*        TABLES
*          it_msg          = git_msg1
*          it_file_table   = file_table1.
*      APPEND LINES OF git_msg1 TO git_msg.
**      lv_high = lv_high + 30.
*      lv_high = lv_first + lv_high.
*      lv_high1 = lv_high1 + 65.
*    ENDIF.
*  ENDLOOP.
*
**Append Success records to the output report
*  LOOP AT git_success INTO gwa_success.
*    IF sy-tabix EQ 1.
*      IF rb_test EQ abap_true.
*        gwa_msg+0(65) = text-z16.
*        gwa_msg+50(33) = text-z23.
*        gwa_msg+83(65) = text-z16.
*        APPEND gwa_msg TO git_msg.
*        CLEAR gwa_msg.
*      ELSE.
*        gwa_msg+0(65) = text-z16.
*        gwa_msg+65(7) = text-z24.
*        gwa_msg+72(65) = text-z16.
*        APPEND gwa_msg TO git_msg.
*        CLEAR gwa_msg.
*      ENDIF.
*
*
**      gwa_msg+0(20) = text-006.
**      gwa_msg+30(20) = text-007.
**      gwa_msg+60(30) = text-008.
**      gwa_msg+100(30) = text-009.
**      gwa_msg+140(105) = text-011.
*      gwa_msg+0(10) = text-006.
*      gwa_msg+11(8) = text-007.
*      gwa_msg+20(12) = text-008.
*      gwa_msg+35(30) = text-009.
*      gwa_msg+70(25) = text-011.
*      gwa_msg+100(150) = text-012.
*      APPEND gwa_msg TO git_msg.
*      CLEAR gwa_msg.
*      lv_high = lv_high + 2.
*    ENDIF.
*    lv_high = lv_high + 1.
*    gwa_msg+0(10) = gwa_success-pernr.
*    gwa_msg+11(8) = gwa_success-begda.
*    gwa_msg+20(12) = gwa_success-wbs_elm.
*    gwa_msg+35(30) = gwa_success-awart.
*    gwa_msg+70(25) = gwa_success-catshours.
*    gwa_msg+100(150) = gwa_success-msg_txt.
*
*    APPEND gwa_msg TO git_msg.
*    CLEAR gwa_msg.
*
****    IF sy-tabix EQ lv_high.
*    IF lv_high = lv_high1.
*      lv_page = lv_page + 1.
*      REFRESH git_msg1.
*      CALL FUNCTION 'ZHR_DISPLAY_CONTROL_TOTALS_IN'
*        EXPORTING
*          im_pageno       = lv_page
*          im_programname  = sy-repid
*          im_totalrecs    = lv_count
*          im_errors       = lv_count_e
*          im_outputreport = lv_output
*          im_mode         = lv_mode
*          im_session      = lv_sess "p_sess
*          im_success      = lv_count_s
*        TABLES
*          it_msg          = git_msg1
*          it_file_table   = file_table1.
*
*      APPEND LINES OF git_msg1 TO git_msg.
****      lv_high = lv_high + 30.
*      lv_high = lv_first + lv_high.
*      lv_high1 = lv_high + 65.
*    ENDIF.
*  ENDLOOP.
*
*  IF rb_prod EQ abap_true.
**Download Output report
*    PERFORM download_output USING lv_output.
*  ENDIF.
*
** Add program message to table, for display at end of program
*  LOOP AT git_msg INTO gwa_msg.
*    gref_util->add_pgm_msg( gwa_msg ).
*  ENDLOOP.
*
*  IF rb_test NE abap_true.
*    IF rb_appl EQ abap_true.
*      IF git_msg IS NOT INITIAL.
*        CLEAR lv_rptfile.
*
*        zcl_hr_interface_util=>write_rptfile1(
*          EXPORTING
*            im_repid      = sy-cprog
**            im_struc_name = gc_fiddefin_struc "'ZHRS_FIDDEFIN_ERROR'
*            im_data_tab   = git_msg[]
*            im_textonly   = abap_true
*            im_filename   = lv_output "gv_filename
*            im_title      = text-t05                        "#EC *
*            im_testrun    = abap_true
*         IMPORTING
*            ex_fullfile   = lv_rptfile ).
*
*      ENDIF.
*    ENDIF.
*  ENDIF.
*ENDFORM.                    " GENERATE_OUTPUT_REPORT
*&---------------------------------------------------------------------*
*&      Form  ARCHIVE_INPUT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM archive_input_file .
  DATA: lwa_file TYPE sdokpath,
          lv_path TYPE string,
          lv_string TYPE string.

  DATA: lwa_pathsplit TYPE string.


  LOOP AT file_table1 INTO lwa_file .

    OPEN DATASET lwa_file-pathname FOR INPUT IN TEXT MODE ENCODING DEFAULT.

    IF sy-subrc EQ 0.
*" Build the Pathname of the Archive file
      REFRESH git_pathsplit.
      SPLIT lwa_file AT gc_for_slash INTO TABLE git_pathsplit.
      lv_path = LINES( git_pathsplit ).

      IF NOT git_pathsplit IS INITIAL.
        CLEAR lwa_pathsplit.
        READ TABLE git_pathsplit INTO lwa_pathsplit INDEX lv_path.
        DELETE git_pathsplit INDEX lv_path.
      ENDIF.

      CLEAR lv_path.
*{   DELETE         D30K920054                                        1
*\      CONCATENATE LINES OF git_pathsplit INTO lv_path SEPARATED BY gc_for_slash.
*}   DELETE
*{   REPLACE        D30K920054                                        2
*\      CONCATENATE lv_path text-f02 lwa_pathsplit INTO lv_path SEPARATED BY gc_for_slash.
*\      CONDENSE lv_path.
      CONCATENATE '/usr/sap/interfaces/' sy-sysid '/HCM/BACKUP/WARP/' INTO lv_path.
      CONCATENATE lv_path  lwa_pathsplit INTO lv_path SEPARATED BY gc_for_slash.
      CONDENSE lv_path.
*}   REPLACE
      OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc EQ 0.
        DO.
          READ DATASET lwa_file-pathname INTO lv_string.
          IF sy-subrc EQ 0.

            TRANSFER lv_string TO lv_path.
          ELSE.
            EXIT.
          ENDIF.
        ENDDO.
      ELSE.
        MESSAGE 'Error reading the file' TYPE 'E'.
      ENDIF.
    ENDIF.
*    ENDDO.

*{   REPLACE        D30K920054                                        3
*\    CLOSE DATASET lwa_file-pathname.
*\    CLOSE DATASET lv_path.
    CLOSE DATASET lv_path.
    CLOSE DATASET lwa_file-pathname.
*}   REPLACE
    DELETE DATASET lwa_file-pathname.
  ENDLOOP.
ENDFORM.                    " ARCHIVE_INPUT_FILE
*&---------------------------------------------------------------------*
*&      Form  PROCESS_RECORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_records .
  DATA: lv_return TYPE bapireturn,
          lv_lgart TYPE p0267-lgart,
          lv_pernr(8) TYPE c,
          lv_date(10) TYPE c,
          lv_molga TYPE molga,
          lv_waers TYPE waers,
          lv_ok TYPE boole_d.

  DATA : l_msg_handle TYPE REF TO  if_hrpa_message_handler.



  LOOP AT git_tab INTO gwa_tab.

*" Check whether the pernr is valid
    CLEAR :  lv_return.

    CALL FUNCTION 'BAPI_EMPLOYEE_CHECKEXISTENCE'
      EXPORTING
        number = gwa_tab-pernr
      IMPORTING
        return = lv_return.
    IF lv_return IS NOT INITIAL.
      gwa_error-pernr = gwa_tab-pernr.
      WRITE gwa_tab-begda TO gwa_error-begda.
*      CONCATENATE gwa_tab-begda+4(2)
*                 gwa_tab-begda+6(2)
*                 gwa_tab-begda+0(4) INTO gwa_error-begda
*                 SEPARATED BY '/'.
      gwa_error-awart = gwa_tab-awart.
      gwa_error-wbs_elm = gwa_tab-wbs_elm.
      gwa_error-versl  = gwa_tab-versl .
      gwa_error-catshours = gwa_tab-catshours.
      gwa_error-err_txt = lv_return.
      APPEND gwa_error TO git_error.
      CLEAR gwa_error.
      CONTINUE.
    ENDIF.
*Call the BAPI and create the time sheet.
    PERFORM create_timesheet.

*" Check the employee's Status

  ENDLOOP.
ENDFORM.                    " PROCESS_RECORDS
*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_OUTPUT  text
*----------------------------------------------------------------------*
FORM download_output  USING    p_lv_output.
  DATA: lv_file TYPE string,
            lwa_msg TYPE string. " Error message

  CONSTANTS lc_error_type TYPE msgty VALUE 'E'.

  lv_file = p_lv_output.

  CHECK git_msg[] IS NOT INITIAL.
  IF rb_pres EQ 'X'.
    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
*      bin_filesize              =
        filename                  = lv_file
        filetype                  = 'ASC'
*      append                    = SPACE
*      write_field_separator     = SPACE
*      header                    = '00'
*      trunc_trailing_blanks     = SPACE
*      write_lf                  = 'X'
*      col_select                = SPACE
*      col_select_mask           = SPACE
*      dat_mode                  = SPACE
*      confirm_overwrite         = SPACE
*      no_auth_check             = SPACE
*      codepage                  = SPACE
*      ignore_cerr               = ABAP_TRUE
*      replacement               = '#'
*      write_bom                 = SPACE
*      trunc_trailing_blanks_eol = 'X'
*      wk1_n_format              = SPACE
*      wk1_n_size                = SPACE
*      wk1_t_format              = SPACE
*      wk1_t_size                = SPACE
*      show_transfer_status      = 'X'
*      fieldnames                =
*      write_lf_after_last_line  = 'X'
*    IMPORTING
*      filelength                =
      CHANGING
        data_tab                  = git_msg
      EXCEPTIONS
        file_write_error          = 1
        no_batch                  = 2
        gui_refuse_filetransfer   = 3
        invalid_type              = 4
        no_authority              = 5
        unknown_error             = 6
        header_not_allowed        = 7
        separator_not_allowed     = 8
        filesize_not_allowed      = 9
        header_too_long           = 10
        dp_error_create           = 11
        dp_error_send             = 12
        dp_error_write            = 13
        unknown_dp_error          = 14
        access_denied             = 15
        dp_out_of_memory          = 16
        disk_full                 = 17
        dp_timeout                = 18
        file_not_found            = 19
        dataprovider_exception    = 20
        control_flush_error       = 21
        not_supported_by_gui      = 22
        error_no_gui              = 23
        OTHERS                    = 24
            .
    IF sy-subrc EQ 0.
      MESSAGE s006(zhr01).
    ENDIF.
  ELSEIF rb_appl EQ 'X'.
*    TRY.
*        gref_util->write_file_server( im_filename = lv_file
*                                     im_data_tab =  git_msg[] ).
*      CATCH cx_sy_file_io.
*        CLEAR lwa_msg.
*        CONCATENATE text-t02 lv_file INTO lwa_msg.
*        MESSAGE lwa_msg TYPE lc_error_type.
*    ENDTRY.
*
*    IF git_msg[] IS INITIAL.
*      gref_util->add_pgm_msg( ).
*      CLEAR gwa_msg.
*      gwa_msg = text-t03.
*
*      gref_util->add_pgm_msg( gwa_msg ).
*    ENDIF.
  ENDIF.
ENDFORM.                    " DOWNLOAD_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_TIMESHEET
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_timesheet .
  DATA: lit_return_cats TYPE STANDARD TABLE OF bapiret2,
        lwa_return_cats TYPE  bapiret2,
        lv_flag(1),
*        lv_profile TYPE tcatst-variant VALUE 'ZUG_EMPD',
        lv_profile TYPE tcatst-variant VALUE 'ZUG_EMPL',
*****************Added because of Phase3 ESS/MSS CATS Implementation***********************
*        lv_profile TYPE tcatst-variant VALUE 'ZUG_WARP',
        lit_catsrecords_in TYPE STANDARD TABLE OF bapicats1,
        lwa_catsrecords_in TYPE  bapicats1,
        lv_quantity TYPE catsnumber,
        lit_catsrecords_out TYPE STANDARD TABLE OF bapicats2.

*  DATA  catsrecords_out TYPE STANDARD TABLE OF bapicats2.

  CLEAR lv_flag.
  IF rb_test IS NOT INITIAL.
    lv_flag = 'X'.
  ELSE."IF rb_prod IS NOT INITIAL.
    lv_flag = ''.
  ENDIF.
*Populate the Timesheet entries with respect to EE.
  lwa_catsrecords_in-employeenumber = gwa_tab-pernr.
  lwa_catsrecords_in-workdate = gwa_tab-begda.
  lwa_catsrecords_in-abs_att_type = gwa_tab-awart.
  lwa_catsrecords_in-ot_comp_type = gwa_tab-versl.
  IF gwa_tab-awart IS NOT INITIAL.
    lwa_catsrecords_in-catshours =  gwa_tab-catshours.
  ENDIF.
*  lwa_catsrecords_in-OT_COMP_TYPE = gwa_tab-pernr.
*  lwa_catsrecords_in-WORKTAXAREA = gwa_tab-pernr.
*  lwa_catsrecords_in-POSITION = gwa_tab-pernr.
  lwa_catsrecords_in-wbs_element = gwa_tab-wbs_elm.
  lwa_catsrecords_in-rec_order = gwa_tab-rec_order.
  lwa_catsrecords_in-rec_cctr = gwa_tab-rec_cctr.
  lwa_catsrecords_in-wagetype = gwa_tab-wagetype.
  IF gwa_tab-wagetype IS NOT INITIAL.
    CLEAR gwa_t511.
    READ TABLE git_t511 INTO gwa_t511 WITH KEY lgart = gwa_tab-wagetype.
    IF sy-subrc = 0.
      IF gwa_t511-zeinh IS NOT INITIAL.
        lwa_catsrecords_in-unitq = 'STD'.
        lwa_catsrecords_in-quantity =  gwa_tab-catshours.
      ELSE.
        lwa_catsrecords_in-amount =  gwa_tab-catshours.
        lwa_catsrecords_in-currency = 'CAD'.
*        lwa_catsrecords_in-CURRENCY_ISO = 'CAD'.
      ENDIF.
    ENDIF.

  ENDIF.

*  lwa_catsrecords_in-meinh = gwa_tab-unit.
*  lwa_catsrecords_in-anzhl = lv_quantity.

  APPEND lwa_catsrecords_in TO lit_catsrecords_in.
  CLEAR lwa_catsrecords_in.
  REFRESH: lit_return_cats,
            lit_catsrecords_out.
  CALL FUNCTION 'BAPI_CATIMESHEETMGR_INSERT'
    EXPORTING
      profile          = lv_profile
      testrun          = lv_flag
    TABLES
      catsrecords_in   = lit_catsrecords_in
*     EXTENSIONIN      =
      catsrecords_out  = lit_catsrecords_out
*     EXTENSIONOUT     =
*     WORKFLOW_TEXT    =
      return           = lit_return_cats
*     LONGTEXT         = longtext .
*     SA_EXTENSION_IN  =
*     SA_EXTENSION_OUT =
    .
*Whether are any error records.
  LOOP AT lit_return_cats INTO lwa_return_cats.
    IF lwa_return_cats-type = 'A' OR lwa_return_cats-type = 'E'.
      gwa_error-pernr = gwa_tab-pernr.
      WRITE gwa_tab-begda TO gwa_error-begda.
*    CONCATENATE gwa_tab-begda+4(2)
*                 gwa_tab-begda+6(2)
*                 gwa_tab-begda+0(4) INTO gwa_error-begda.
**                 SEPARATED BY '/'.
      gwa_error-awart = gwa_tab-awart.
      gwa_error-wbs_elm = gwa_tab-wbs_elm.
      gwa_error-versl  = gwa_tab-versl .
      gwa_error-rec_order = gwa_tab-rec_order.
      gwa_error-rec_cctr = gwa_tab-rec_cctr.
      gwa_error-wagetype = gwa_tab-wagetype.
      gwa_error-unit = gwa_tab-unit.
      gwa_error-catshours = gwa_tab-catshours.
      gwa_error-err_txt = lwa_return_cats-message.
      APPEND gwa_error TO git_error.
      CLEAR gwa_error.
    ELSEIF lwa_return_cats-type = 'W' OR lwa_return_cats-type = 'I'.
      gwa_warning-pernr = gwa_tab-pernr.
      WRITE gwa_tab-begda TO gwa_warning-begda.
*    CONCATENATE gwa_tab-begda+4(2)
*                 gwa_tab-begda+6(2)
*                 gwa_tab-begda+0(4) INTO gwa_error-begda.
**                 SEPARATED BY '/'.
      gwa_warning-awart = gwa_tab-awart.
      gwa_warning-wbs_elm = gwa_tab-wbs_elm.
      gwa_warning-versl  = gwa_tab-versl .
      gwa_warning-rec_order = gwa_tab-rec_order.
      gwa_warning-rec_cctr = gwa_tab-rec_cctr.
      gwa_warning-wagetype = gwa_tab-wagetype.
      gwa_warning-unit = gwa_tab-unit.
      gwa_warning-catshours = gwa_tab-catshours.
      gwa_warning-err_txt = lwa_return_cats-message.
      APPEND gwa_warning TO git_warning.
      CLEAR gwa_warning.
    ENDIF.

  ENDLOOP.
  IF  sy-subrc NE 0.
    IF rb_test IS NOT INITIAL.
      gwa_success-pernr = gwa_tab-pernr.
      WRITE gwa_tab-begda TO gwa_success-begda.
*      CONCATENATE gwa_tab-begda+4(2)
*                  gwa_tab-begda+6(2)
*                  gwa_tab-begda+0(4) INTO gwa_success-begda.
**                  SEPARATED BY '/'.
**       = gwa_tab-begda.
      gwa_success-awart = gwa_tab-awart.
      gwa_success-wbs_elm = gwa_tab-wbs_elm.
      gwa_success-rec_order = gwa_tab-rec_order.
      gwa_success-rec_cctr = gwa_tab-rec_cctr.
      gwa_success-versl  = gwa_tab-versl .
      gwa_success-wagetype = gwa_tab-wagetype.
      gwa_success-unit = gwa_tab-unit.
      gwa_success-catshours = gwa_tab-catshours.
      gwa_success-msg_txt = 'Employee Timesheet Can be created'(013).
      APPEND gwa_success TO git_success.
      CLEAR gwa_success.
    ELSE.
      gwa_success-pernr = gwa_tab-pernr.
      WRITE gwa_tab-begda TO gwa_success-begda.
*      CONCATENATE gwa_tab-begda+4(2)
*                 gwa_tab-begda+6(2)
*                 gwa_tab-begda+0(4) INTO gwa_success-begda.
*                 SEPARATED BY '/'.
*      gwa_success-begda = gwa_tab-begda.
      gwa_success-awart = gwa_tab-awart.
      gwa_success-wbs_elm = gwa_tab-wbs_elm.
      gwa_success-versl  = gwa_tab-versl .
      gwa_success-rec_order = gwa_tab-rec_order.
      gwa_success-rec_cctr = gwa_tab-rec_cctr.
      gwa_success-unit = gwa_tab-unit.
      gwa_success-wagetype = gwa_tab-wagetype.
      gwa_success-catshours = gwa_tab-catshours.
*      READ TABLE lit_return_cats INTO lwa_return_cats WITH KEY type = 'S'.
      gwa_success-msg_txt = 'Employee Timesheet Successfully Created'(015).
      APPEND gwa_success TO git_success.
      CLEAR gwa_success.
    ENDIF.

  ENDIF.
*ENDIF.


ENDFORM.                    " CREATE_TIMESHEET
*&---------------------------------------------------------------------*
*&      Form  READ_APPL_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LIT_INPUT  text
*      -->P_L_FILE1  text
*----------------------------------------------------------------------*
FORM read_appl_server  TABLES   t_table
                       USING    lfile_path.


  DATA: l_file1 TYPE string,
        lv_string TYPE string.

  l_file1 = lfile_path.
  TRY.
      OPEN DATASET l_file1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc EQ 0.
        DO.
          READ DATASET l_file1 INTO lv_string.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          APPEND lv_string TO t_table.
          CLEAR lv_string.
        ENDDO.
        CLOSE DATASET l_file1.
*        MESSAGE s029(zdev) RAISING upload_success.
      ELSE.
        MESSAGE 'File could not open' TYPE 'E'.
      ENDIF.
    CATCH cx_sy_conversion_codepage.
*      MESSAGE e094(zdev) RAISING upload_error.
  ENDTRY.

ENDFORM.                    " READ_APPL_SERVER
*&---------------------------------------------------------------------*
*&      Form  ALV_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alv_fieldcat .
  DATA: lv_table TYPE slis_tabname VALUE 'GIT_OUTPUT'.
  PERFORM write_fieldcat USING 'STAT' lv_table space 'Update Status'.
  PERFORM write_fieldcat USING 'PERNR' lv_table  space 'Employee Number'.
  PERFORM write_fieldcat USING 'BEGDA' lv_table  space 'Start Date'.
  PERFORM write_fieldcat USING 'WBS_ELM' lv_table space 'WBS Element' .
  PERFORM write_fieldcat USING 'REC_ORDER' lv_table space 'Internal Order (CATS Receiving Order)' .
  PERFORM write_fieldcat USING 'REC_CCTR' lv_table space 'Cost Center (CATS Receiving Cost Center)' .
  PERFORM write_fieldcat USING 'AWART' lv_table   space 'Attendance / Abscence Quota type'.
  PERFORM write_fieldcat USING 'VERSL' lv_table   space 'Overtime Compensation Type'.
  PERFORM write_fieldcat USING 'WAGETYPE' lv_table   space 'Wagtype'.
  PERFORM write_fieldcat USING 'UNIT' lv_table   space 'Measure of Unit'.
  PERFORM write_fieldcat USING 'CATSHOURS' lv_table  space 'Attendance Hours'.
  PERFORM write_fieldcat USING 'STATUS' lv_table  space 'Status Message'.

ENDFORM.                    " ALV_FIELDCAT

*
*&---------------------------------------------------------------------*
*&      Form  DESIGN_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM design_layout .
  gwa_layout-colwidth_optimize = 'X'.
ENDFORM.                    " DESIGN_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv.

  LOOP AT git_warning INTO  gwa_warning.
    MOVE-CORRESPONDING gwa_warning TO gwa_output.
    gwa_output-stat = icon_yellow_light.
    gwa_output-status = gwa_warning-err_txt.
    APPEND gwa_output TO git_output.
    CLEAR : gwa_output, gwa_warning.
  ENDLOOP.

  LOOP AT git_success INTO  gwa_success.
    MOVE-CORRESPONDING gwa_success TO gwa_output.
    gwa_output-stat = icon_green_light.
    gwa_output-status = gwa_success-msg_txt.
    APPEND gwa_output TO git_output.
    CLEAR :gwa_output, gwa_success.
  ENDLOOP.

  LOOP AT git_error INTO  gwa_error.
    MOVE-CORRESPONDING gwa_error TO gwa_output.
    gwa_output-stat = icon_red_light.
    gwa_output-status = gwa_error-err_txt.
    APPEND gwa_output TO git_output.
    CLEAR :gwa_output, gwa_error.
  ENDLOOP.

*SORT GIT_OUTPUT.
  SORT git_output BY  pernr.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'TOP_OF_PAGE'
*      i_save                 = gv_save
*      is_variant             = gs_sel_variant
      is_layout              = gwa_layout
      it_fieldcat            = git_fieldcat
    TABLES
      t_outtab               = git_output
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page .
  DATA : lit_list_top_of_page TYPE slis_t_listheader.
  DATA: ws_line TYPE slis_listheader.
  DATA: w_date(10) TYPE c,
        w_time(8) TYPE c.

  REFRESH: lit_list_top_of_page.

  CONCATENATE sy-datum+4(2) '/' sy-datum+6(2) '/' sy-datum+0(4)
  INTO w_date.
  CONCATENATE sy-uzeit+0(2) ':' sy-uzeit+2(2) ':' sy-uzeit+4(2)
  INTO w_time.

  CLEAR ws_line.
  ws_line-typ = 'H'.
*  ws_line-key = 'Date :'(014).
  ws_line-info = 'East(WARP) Time Data from IHR Inbound'.
  APPEND ws_line TO lit_list_top_of_page.

  CLEAR ws_line.
  ws_line-typ = 'S'.
  ws_line-key = 'Date :'(020).
  ws_line-info = w_date.
  APPEND ws_line TO lit_list_top_of_page.

  CLEAR ws_line.
  ws_line-typ = 'S'.
  ws_line-key = 'Time :'(021).
  ws_line-info = w_time.
  APPEND ws_line TO lit_list_top_of_page.

  CLEAR ws_line.
  ws_line-typ = 'S'.
  ws_line-key = 'User :'(022).
  ws_line-info = sy-uname.
  APPEND ws_line TO lit_list_top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lit_list_top_of_page.
ENDFORM.                    "top_of_page
*&---------------------------------------------------------------------*
*&      Form  WRITE_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM write_fieldcat  USING    p_fldname TYPE slis_fieldname
                           p_tabname TYPE slis_tabname
                           p_reftable TYPE dd03p-tabname
                           p_col_heading TYPE any.
  CLEAR gwa_fieldcat.
  ADD 1 TO gv_colpos.
  gwa_fieldcat-col_pos      = gv_colpos.
  gwa_fieldcat-fieldname    = p_fldname.
  gwa_fieldcat-tabname      = p_tabname.
  gwa_fieldcat-ref_tabname  = p_reftable.
  gwa_fieldcat-seltext_l    = p_col_heading.
  gwa_fieldcat-seltext_m    = p_col_heading.
  gwa_fieldcat-seltext_s    = p_col_heading.
  gwa_fieldcat-reptext_ddic = p_col_heading.
  APPEND gwa_fieldcat TO git_fieldcat.

ENDFORM.                    " WRITE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_filename .
  DATA:
      l_logical_filename TYPE filename-fileintern,
      lv_filename TYPE string.
*      lv_parma2 TYPE c.


  l_logical_filename = sy-repid.


* Lookup logical file path
  CALL FUNCTION 'FILE_GET_NAME'
    EXPORTING
      logical_filename            = l_logical_filename
*    parameter_1                   = lv_param1
*    parameter_2                   = lv_param2
*   PARAMETER_3                   = ' '
    IMPORTING
      file_name                   = lv_filename
    EXCEPTIONS
      file_not_found                = 1
      OTHERS                        = 2.

  p_file3 =  lv_filename.
ENDFORM.                    " GET_FILENAME
*&---------------------------------------------------------------------*
*&      Form  GET_F4FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE3  text
*----------------------------------------------------------------------*
FORM get_f4filename  CHANGING p_p_file3.
  DATA : l_dirname TYPE dirname,
         lv_file TYPE ibipparms-path.

*" Fetch the directory name to be used
  SELECT SINGLE dirname
    FROM user_dir
    INTO l_dirname
    WHERE aliass EQ 'DIR_TEMP'."'Z_HR_FOLDER'.

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
*{   REPLACE        DHRK900088                                        1
*\      directory        = ' '
      directory        = l_dirname "'D:\ '
*}   REPLACE
*{   REPLACE        DHRK900088                                        2
*\      filemask         = ' '
      filemask         = '*.*'
*}   REPLACE
    IMPORTING
      serverfile       = lv_file
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  p_p_file3 = lv_file.
ENDFORM.                    " GET_F4FILENAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_I_BEGDA  text
*----------------------------------------------------------------------*
FORM get_sap_dateformat USING p_i_begda  CHANGING lv_date .
  DATA: lv_excel_date TYPE char10,
          lv_sap_date TYPE dats.

  lv_excel_date = p_i_begda.

  CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
    EXPORTING
      excel_date  = lv_excel_date
      date_format = 'MTJ'
    IMPORTING
      sap_date    = lv_sap_date.
  IF  sy-subrc = 0.
    lv_date = lv_sap_date.
  ENDIF.
ENDFORM.                    " GET_SAP_DATEFORMAT
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_T511
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data_t511 .
  REFRESH git_t511.
  SELECT * FROM t511 INTO TABLE git_t511 WHERE molga = '07'.

ENDFORM.                    " GET_DATA_T511
