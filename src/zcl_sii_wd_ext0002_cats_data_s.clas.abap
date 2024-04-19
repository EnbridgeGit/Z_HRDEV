class ZCL_SII_WD_EXT0002_CATS_DATA_S definition
  public
  create public .

public section.
*"* public components of class ZCL_SII_WD_EXT0002_CATS_DATA_S
*"* do not include other source files here!!!

  interfaces ZII_SII_WD_EXT0002_CATS_DATA_S .
protected section.
*"* protected components of class ZCL_SII_WD_EXT0002_CATS_DATA_S
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_SII_WD_EXT0002_CATS_DATA_S
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_SII_WD_EXT0002_CATS_DATA_S IMPLEMENTATION.


METHOD zii_sii_wd_ext0002_cats_data_s~sii_wd_ext0002_cats_data_sync.
*----------------------------------------------------------------------------------------------------
*Class Name:        ZII_SII_WD_EXT0002_CATS_DATA_S
*Author:            Nidhi Singh (Accenture)
*Date:              18.06.2018
*Application Area:  HR - TM
*Description:       CATS EAST Time Export Interface (EXT0002)
*----------------------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*Modification details
*Version No:      Date:          Modified By:   Ticket No:      Correction No:
*                 31.08.2018     Nidhi Singh    SIT             SIT
*Description: Add two new field in header - changed on start time and changed on end time
*----------------------------------------------------------------------------------------------------
*& Type declaration
  TYPES: BEGIN OF lty_pa0007,
          pernr TYPE pernr_d,
         END OF lty_pa0007.

*& Internal table declaration
  DATA: lt_employee      TYPE TABLE OF bapihrselemployee,
        lt_catsrec       TYPE TABLE OF bapicats2,
        lt_return        TYPE TABLE OF bapiret2,
        lt_0007          TYPE TABLE OF lty_pa0007,
        lt_output        TYPE zdt_response_ext0002_sapgh_tab.

*& Work area declaration
  DATA: ls_output        TYPE zdt_response_ext0002_sapghr_re,
        ls_catsrec       TYPE bapicats2,
        ls_catsrec_pre   TYPE bapicats2,
        ls_return        TYPE bapiret2,
        ls_0007          TYPE lty_pa0007,
        ls_employee      TYPE bapihrselemployee.

*& Variable declaration
  DATA:lv_text           TYPE camsg,
       lv_flag           TYPE char1,
       lv_counter        TYPE catscounte,
       lv_for_sdate      TYPE	datum,
       lv_for_edate      TYPE datum,
       lv_in_sdate       TYPE datum,
       lv_in_edate       TYPE datum,
       lv_retro          TYPE char1,
       lv_in_stime       TYPE uzeit,
       lv_in_etime       TYPE uzeit,
       lv_skip           TYPE char1.

*& Constant declaration
  CONSTANTS: lc_error    TYPE char8      VALUE 'ERROR',
             lc_success  TYPE char8      VALUE 'SUCCESS',
             lc_yes      TYPE char1      VALUE 'Y',
             lc_no       TYPE char1      VALUE 'N',
             lc_approved TYPE catsstatus VALUE '30',
             lc_wm       TYPE kztim      VALUE 'WM',
             lc_i        TYPE char1      VALUE 'I',
             lc_eq       TYPE char2      VALUE 'EQ',
             lc_000000   TYPE uzeit      VALUE '000000',
             lc_240000   TYPE uzeit      VALUE '240000'.

  CLEAR: output, lt_output, ls_output.
***********************************************************************************
*&                     Pass input data
***********************************************************************************
  lv_for_sdate  = input-mt_request_ext0002_sapghr-for_start_date.
  lv_for_edate  = input-mt_request_ext0002_sapghr-for_end_date.
  lv_in_sdate	  = input-mt_request_ext0002_sapghr-in_start_date.
  lv_in_edate	  = input-mt_request_ext0002_sapghr-in_end_date.
  lv_in_stime   = input-mt_request_ext0002_sapghr-in_start_time.
  lv_in_etime   = input-mt_request_ext0002_sapghr-in_end_time.
  lv_retro      = input-mt_request_ext0002_sapghr-retro_indicator.
***********************************************************************************
*&                                Header Validation
***********************************************************************************
*& Record start date validation
  IF lv_for_sdate IS NOT INITIAL.
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date                      = lv_for_sdate
      EXCEPTIONS
        plausibility_check_failed = 1
        OTHERS                    = 2.
    IF sy-subrc EQ 0.
      ls_output-for_start_date = lv_for_sdate.
    ELSE.
      ls_output-result_code = lc_error.
      "Record start date is invalid
      MESSAGE e000(zhrworkday) INTO lv_text.
      ls_output-result_text = lv_text.
    ENDIF.
  ELSE.
    ls_output-result_code = lc_error.
    "Record start date is invalid
    MESSAGE e001(zhrworkday) INTO lv_text.
    ls_output-result_text = lv_text.
  ENDIF.

*& Record end date validation
  IF ls_output-result_code IS INITIAL.
    IF lv_for_edate IS NOT INITIAL.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_for_edate
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc EQ 0.
        ls_output-for_end_date = lv_for_edate.
      ELSE.
        ls_output-result_code = lc_error.
        "Record end date is invalid
        MESSAGE e002(zhrworkday) INTO lv_text.
        ls_output-result_text = lv_text.
      ENDIF.
    ELSE.
      ls_output-result_code = lc_error.
      "Record end date is blank
      MESSAGE e003(zhrworkday) INTO lv_text.
      ls_output-result_text = lv_text.
    ENDIF.
  ENDIF.

*& Record end date should be greater than or equal to record end date
  IF ls_output-result_code IS INITIAL.
    IF lv_for_sdate GT lv_for_edate.
      "Record start date is greater than record end date
      ls_output-result_code = lc_error.
      MESSAGE e012(zhrworkday) INTO lv_text.
      ls_output-result_text = lv_text.
    ENDIF.
  ENDIF.

*& Retro indicator validation
  IF lv_retro IS NOT INITIAL.
    IF lv_retro EQ lc_yes.
      ls_output-retro_indicator = lv_retro.
*& Changed on start date validation
      IF ls_output-result_code IS INITIAL.
        IF lv_in_sdate IS NOT INITIAL.
          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              date                      = lv_in_sdate
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc EQ 0.
            ls_output-in_start_date = lv_in_sdate.
          ELSE.
            ls_output-result_code = lc_error.
            "Changed on start date is invalid
            MESSAGE e004(zhrworkday) INTO lv_text.
            ls_output-result_text = lv_text.
          ENDIF.
        ELSE.
          ls_output-result_code = lc_error.
          "Changed on start date is blank
          MESSAGE e005(zhrworkday) INTO lv_text.
          ls_output-result_text = lv_text.
        ENDIF.
      ENDIF.
*& Changed on end date validation
      IF ls_output-result_code IS INITIAL.
        IF lv_in_edate IS NOT INITIAL.
          CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
            EXPORTING
              date                      = lv_in_edate
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc EQ 0.
            ls_output-in_end_date = lv_in_edate.
          ELSE.
            ls_output-result_code = lc_error.
            "Changed on end date is invalid
            MESSAGE e006(zhrworkday) INTO lv_text.
            ls_output-result_text = lv_text.
          ENDIF.
        ELSE.
          ls_output-result_code = lc_error.
          "Changed on end date is blank
          MESSAGE e007(zhrworkday) INTO lv_text.
          ls_output-result_text = lv_text.
        ENDIF.
      ENDIF.

*& Changed on start time validation
      IF ls_output-result_code IS INITIAL.
        IF lv_in_stime IS NOT INITIAL.
          CALL FUNCTION 'TIME_CHECK_PLAUSIBILITY'
            EXPORTING
              time                      = lv_in_stime
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc EQ 0.
            ls_output-in_start_time = lv_in_stime.
          ELSE.
            ls_output-result_code = lc_error.
            "Changed on start time is invalid
            MESSAGE e014(zhrworkday) INTO lv_text.
            ls_output-result_text = lv_text.
          ENDIF.
        ELSE.
          lv_in_stime = lc_000000.
        ENDIF.
      ENDIF.

*& Changed on end time validation
      IF ls_output-result_code IS INITIAL.
        IF lv_in_etime IS NOT INITIAL.
          CALL FUNCTION 'TIME_CHECK_PLAUSIBILITY'
            EXPORTING
              time                      = lv_in_etime
            EXCEPTIONS
              plausibility_check_failed = 1
              OTHERS                    = 2.
          IF sy-subrc EQ 0.
            ls_output-in_end_time = lv_in_etime.
          ELSE.
            ls_output-result_code = lc_error.
            "Changed on end time is invalid
            MESSAGE e015(zhrworkday) INTO lv_text.
            ls_output-result_text = lv_text.
          ENDIF.
        ELSE.
          lv_in_etime = lc_240000.
        ENDIF.
      ENDIF.

*& Changed on end date should be greater than or equal to changed on start date
      IF ls_output-result_code IS INITIAL.
        IF lv_in_sdate GT lv_in_edate.
          "Changed on start date is greater than changed on end date
          ls_output-result_code = lc_error.
          MESSAGE e013(zhrworkday) INTO lv_text.
          ls_output-result_text = lv_text.
        ENDIF.
      ENDIF.

*& Changed on end time should be greater than or equal to changed on start time
      IF ls_output-result_code IS INITIAL.
        IF lv_in_sdate EQ lv_in_edate AND lv_in_stime GT lv_in_etime.
          "Changed on start time is greater than changed on end time
          ls_output-result_code = lc_error.
          MESSAGE e016(zhrworkday) INTO lv_text.
          ls_output-result_text = lv_text.
        ENDIF.
      ENDIF.

    ELSEIF lv_retro = lc_no.
      ls_output-retro_indicator = lv_retro.
    ELSE.
      ls_output-result_code = lc_error.
      "Retro indicator is invalid
      MESSAGE e008(zhrworkday) INTO lv_text.
      ls_output-result_text = lv_text.
    ENDIF.
  ELSE.
    ls_output-result_code = lc_error.
    "Retro indicator is blank
    MESSAGE e009(zhrworkday) INTO lv_text.
    ls_output-result_text = lv_text.
  ENDIF.

***********************************************************************************
*&                           Data Extraction
***********************************************************************************
  IF ls_output-result_code IS INITIAL AND ls_output-result_text IS INITIAL.
*& Begin of insert by SINGHN7 on 14.08.2018 SIT
*& Get EAM employees
    CLEAR: lt_0007, lt_employee, ls_0007, ls_employee.
    SELECT pernr
      FROM pa0007
INTO TABLE lt_0007
     WHERE endda GE lv_for_sdate
       AND begda LE lv_for_edate
       AND kztim EQ lc_wm.
    IF sy-subrc EQ 0.
      SORT lt_0007 BY pernr ASCENDING.
      ls_employee-sign = lc_i.
      ls_employee-option = lc_eq.
      LOOP AT lt_0007 INTO ls_0007.
        ls_employee-low = ls_0007-pernr.
        APPEND ls_employee TO lt_employee.
        CLEAR: ls_employee-low, ls_0007.
      ENDLOOP.
    ENDIF.
    IF lt_employee IS NOT INITIAL.
*& End of insert by SINGHN7 on 14.08.2018 SIT

*& Read CATSDB data
      CLEAR: lt_catsrec, lt_return.
      CALL FUNCTION 'BAPI_CATIMESHEETRECORD_GETLIST'
        EXPORTING
          fromdate        = lv_for_sdate
          todate          = lv_for_edate
        TABLES
          sel_employee    = lt_employee
          catsrecords_out = lt_catsrec
          return          = lt_return.

      IF lt_return IS INITIAL.
        IF lt_catsrec IS NOT INITIAL.

          ls_output-result_code = lc_success.
          "Data extracted successfully
          MESSAGE s010(zhrworkday) INTO lv_text.
          ls_output-result_text = lv_text.

*& Extract regular records
          IF lv_retro EQ lc_no.

            LOOP AT lt_catsrec INTO ls_catsrec WHERE status = lc_approved.

              ls_output-counter    = ls_catsrec-counter.
              ls_output-pernr      = ls_catsrec-employeenumber.
              ls_output-workdate   = ls_catsrec-workdate.
              ls_output-vornr      = ls_catsrec-avtivity.
              ls_output-skostl     = ls_catsrec-send_cctr.
              ls_output-rproj      = ls_catsrec-wbs_element.
              ls_output-raufnr     = ls_catsrec-rec_order.
              ls_output-awart      = ls_catsrec-abs_att_type.
              ls_output-lgart      = ls_catsrec-wagetype.
              ls_output-versl      = ls_catsrec-ot_comp_type.
              ls_output-laeda      = ls_catsrec-lastchanged_on.
              ls_output-laetm      = ls_catsrec-lastchanged_at.
              ls_output-aenam      = ls_catsrec-changed_by.
              ls_output-status     = ls_catsrec-status.
              ls_output-catshours  = ls_catsrec-catshours.
              ls_output-refcounter = ls_catsrec-refcounter.
              ls_output-catsamount = ls_catsrec-amount.

              APPEND ls_output TO lt_output.
              CLEAR: ls_output-counter, ls_output-pernr, ls_output-workdate, ls_output-vornr, ls_output-skostl,
                     ls_output-rproj, ls_output-raufnr, ls_output-awart, ls_output-lgart, ls_output-versl,
                     ls_output-laeda, ls_output-laetm, ls_output-aenam,  ls_output-status, ls_output-catshours,
                     ls_output-refcounter, ls_output-catsamount.

              CLEAR: ls_catsrec.
            ENDLOOP.

            IF lt_output IS NOT INITIAL.
              SORT lt_output BY pernr workdate counter.
            ELSE.
              ls_output-result_code = lc_success.
              "No data found for selection criteriaa
              MESSAGE s011(zhrworkday) INTO lv_text.
              ls_output-result_text = lv_text.
              APPEND ls_output TO lt_output.
            ENDIF.
*& Extract retro records.
          ELSE.
            LOOP AT lt_catsrec INTO ls_catsrec WHERE lastchanged_on  GE lv_in_sdate
                                                 AND lastchanged_on  LE lv_in_edate
                                                 AND status          EQ lc_approved.

              CLEAR: lv_skip.
              IF ls_catsrec-lastchanged_on EQ lv_in_sdate AND
                 ls_catsrec-lastchanged_at LT lv_in_stime.

                lv_skip = abap_true.

              ELSEIF ls_catsrec-lastchanged_on EQ lv_in_edate AND
                     ls_catsrec-lastchanged_at GT lv_in_etime.

                lv_skip = abap_true.

              ENDIF.

              IF lv_skip IS INITIAL.
                ls_output-counter    = ls_catsrec-counter.
                ls_output-pernr      = ls_catsrec-employeenumber.
                ls_output-workdate   = ls_catsrec-workdate.
                ls_output-vornr      = ls_catsrec-avtivity.
                ls_output-skostl     = ls_catsrec-send_cctr.
                ls_output-rproj      = ls_catsrec-wbs_element.
                ls_output-raufnr     = ls_catsrec-rec_order.
                ls_output-awart      = ls_catsrec-abs_att_type.
                ls_output-lgart      = ls_catsrec-wagetype.
                ls_output-versl      = ls_catsrec-ot_comp_type.
                ls_output-laeda      = ls_catsrec-lastchanged_on.
                ls_output-laetm      = ls_catsrec-lastchanged_at.
                ls_output-aenam      = ls_catsrec-changed_by.
                ls_output-status     = ls_catsrec-status.
                ls_output-catshours  = ls_catsrec-catshours.
                ls_output-refcounter = ls_catsrec-refcounter.
                ls_output-catsamount = ls_catsrec-amount.

                APPEND ls_output TO lt_output.
                CLEAR: ls_output-counter, ls_output-pernr, ls_output-workdate, ls_output-vornr, ls_output-skostl,
                       ls_output-rproj, ls_output-raufnr, ls_output-awart, ls_output-lgart, ls_output-versl,
                       ls_output-laeda,ls_output-laetm, ls_output-aenam,  ls_output-status, ls_output-catshours,
                       ls_output-refcounter, ls_output-catsamount.

*& Get previous cancelled entries from CATSDB for retro data
                CLEAR: ls_catsrec_pre, lv_counter.
                IF ls_catsrec-refcounter IS NOT INITIAL.

                  lv_counter = ls_catsrec-refcounter.
                  lv_flag = abap_true.
                  WHILE lv_flag IS NOT INITIAL.
                    READ TABLE lt_catsrec INTO ls_catsrec_pre WITH KEY counter = lv_counter.
                    IF sy-subrc EQ 0.
                      " Continue querying previous record
                      IF ls_catsrec_pre-refcounter IS NOT INITIAL.
                        lv_counter = ls_catsrec_pre-refcounter.
                        " Terminate while loop as there is no more previous record exists
                      ELSE.
                        lv_flag = abap_false.
                      ENDIF.

                      ls_output-counter    = ls_catsrec_pre-counter.
                      ls_output-pernr      = ls_catsrec_pre-employeenumber.
                      ls_output-workdate   = ls_catsrec_pre-workdate.
                      ls_output-vornr      = ls_catsrec_pre-avtivity.
                      ls_output-skostl     = ls_catsrec_pre-send_cctr.
                      ls_output-rproj      = ls_catsrec_pre-wbs_element.
                      ls_output-raufnr     = ls_catsrec_pre-rec_order.
                      ls_output-awart      = ls_catsrec_pre-abs_att_type.
                      ls_output-lgart      = ls_catsrec_pre-wagetype.
                      ls_output-versl      = ls_catsrec_pre-ot_comp_type.
                      ls_output-laeda      = ls_catsrec_pre-lastchanged_on.
                      ls_output-laetm      = ls_catsrec_pre-lastchanged_at.
                      ls_output-aenam      = ls_catsrec_pre-changed_by.
                      ls_output-status     = ls_catsrec_pre-status.
                      ls_output-catshours  = ls_catsrec_pre-catshours.
                      ls_output-refcounter = ls_catsrec_pre-refcounter.
                      ls_output-catsamount = ls_catsrec_pre-amount.

                      APPEND ls_output TO lt_output.

                      CLEAR: ls_output-counter, ls_output-pernr, ls_output-workdate, ls_output-vornr, ls_output-skostl,
                             ls_output-rproj, ls_output-raufnr, ls_output-awart, ls_output-lgart, ls_output-versl,
                             ls_output-laeda, ls_output-laetm, ls_output-aenam,  ls_output-status, ls_output-catshours,
                             ls_output-refcounter, ls_output-catsamount.
                      CLEAR: ls_catsrec_pre.
                    ENDIF.
                  ENDWHILE.
                ENDIF.
              ENDIF.
              CLEAR: ls_catsrec.
            ENDLOOP.

            IF lt_output IS NOT INITIAL.
              SORT lt_output BY pernr workdate counter.
            ELSE.
              ls_output-result_code = lc_success.
              "No data found for selection criteriaa
              MESSAGE s011(zhrworkday) INTO lv_text.
              ls_output-result_text = lv_text.
              APPEND ls_output TO lt_output.
            ENDIF.

          ENDIF.
*& Report message if FM does not return any data
        ELSE.
          ls_output-result_code = lc_success.
          "No data found for selection criteriaa
          MESSAGE s011(zhrworkday) INTO lv_text.
          ls_output-result_text = lv_text.
          APPEND ls_output TO lt_output.
        ENDIF.
*& Report error message if FM throws any error
      ELSE.
        CLEAR: ls_return.
        READ TABLE lt_return INTO ls_return INDEX 1.
        IF sy-subrc EQ 0.
          ls_output-result_code = lc_error.
          ls_output-result_text = ls_return-message.
          APPEND ls_output TO lt_output.
        ENDIF.
      ENDIF.
*& Begin of insert by SINGHN7 on 14.08.2018 SIT
*& Report message if no EAM employee found
    ELSE.
      ls_output-result_code = lc_success.
      "No data found for selection criteriaa
      MESSAGE s011(zhrworkday) INTO lv_text.
      ls_output-result_text = lv_text.
      APPEND ls_output TO lt_output.
    ENDIF.
*& End of insert by SINGHN7 on 14.08.2018 SIT
  ELSE.
    ls_output-for_start_date  = lv_for_sdate.
    ls_output-for_end_date    = lv_for_edate.
    ls_output-in_start_date   = lv_in_sdate.
    ls_output-in_end_date     = lv_in_edate.
    ls_output-in_start_time   = lv_in_stime.
    ls_output-in_end_time     = lv_in_etime.
    ls_output-retro_indicator = lv_retro.
    APPEND ls_output TO lt_output.
  ENDIF.

  IF lt_output IS NOT INITIAL.
    output-mt_response_ext0002_sapghr-response = lt_output.
  ENDIF.
ENDMETHOD.
ENDCLASS.
