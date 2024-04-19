*&---------------------------------------------------------------------*
*& Report  ZHTMC_CATS_AUTO_LOAD
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZHTMC_CATS_AUTO_LOAD  LINE-COUNT 65 NO STANDARD PAGE HEADING .

*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*Revision # MZH01                               Name: Zakir Hossain    *
*SDP Ticket # 70536                             Date: 11/18/2014       *
*Description: Load timesheet using BAPI                                *
*&---------------------------------------------------------------------*

*include for global data declaration
INCLUDE ZHTMC_CATS_AUTO_LOAD_TOP.

*include for selection screen
INCLUDE ZHTMC_CATS_AUTO_LOAD_SEL.

*include for subroutines
INCLUDE ZHTMC_CATS_AUTO_LOAD_SUB.

INITIALIZATION.
  PNPPERSK-SIGN   = 'I'.
  PNPPERSK-OPTION = 'EQ'.
  PNPPERSK-LOW    = '05'.
  APPEND PNPPERSK.

  PNPPERSK-LOW    = '06'.
  APPEND PNPPERSK.

START-OF-SELECTION.

*Get data entry period date range based on the key date
*entered on the selection screen
  PERFORM GET_DATA_ENTRY_PERIOD USING GV_END_DATE GV_BEGIN_DATE.

*set BAPI commit flag
  IF P_TEST EQ ABAP_TRUE.
    GV_COMMIT = 'X'.
  ELSE.
    GV_COMMIT = ''.
  ENDIF.

GET PERAS.

  PERFORM READ_DATA.
*  PERFORM check_employee_is_active.
  PERFORM GET_TARGET_HOURS.
  PERFORM READ_MERGE_EXISTING_CATS_RECS.
  PERFORM PROCESS_CATS_RECORDS.

END-OF-SELECTION.

* Send report as an attachment if requested
*  PERFORM send_email.

  IF P_PRES EQ ABAP_TRUE AND P_PRD EQ ABAP_TRUE.
    PERFORM POPULATE_HEADER.
    PERFORM WRITE_TO_PRESENTATION.
  ELSEIF P_APPL EQ ABAP_TRUE AND P_PRD EQ ABAP_TRUE.
    PERFORM POPULATE_HEADER.
    PERFORM WRITE_TO_APPL_SERVER.
  ENDIF.

* Display report on ALV
  PERFORM ALV_DISPLAY.
