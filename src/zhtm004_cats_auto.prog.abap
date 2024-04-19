*&---------------------------------------------------------------------*
*& Report  ZHTM004_CATS_AUTO
*&---------------------------------------------------------------------*
* Program Name       : ZHTM004_CATS_AUTO                               *
* Author             : Atul Mule                                       *
* Date               : 12/12/2011(dd/mm/yyyy)                          *
* Technical Contact  : Subramanian Madasamy/                           *
* Business Contact   : Phyllis Patrick                                 *
* Purpose            : This  interface will automatically populate     *
*                      the timesheet for salaried non exempt           *
*                      Employees on weekly basis, This interface will  *
*                      Schduly as weekly job
*----------------------------------------------------------------------*
*                      Modification Log                                *
*                                                                      *
* Changed On   Changed By           CTS          Description           *
*----------------------------------------------------------------------*
*                                                                      *
*&---------------------------------------------------------------------*
*
*&
*&---------------------------------------------------------------------*

REPORT  zhtm001_cats_auto LINE-COUNT 65
NO STANDARD PAGE HEADING .

************************************************************************
* Type Pools
************************************************************************
TYPE-POOLS abap. " ABAP Pool constants*
*----------------------------------------------------------------------*

*   Table declaration
*----------------------------------------------------------------------*
NODES:peras.
TABLES:sscrfields,pernr.
*----------------------------------------------------------------------*
*   Infotype declaration
*----------------------------------------------------------------------*
INFOTYPES:0000,
0001,
0007.

CONSTANTS : gc_x TYPE c VALUE 'X'.

TYPES:
BEGIN OF gt_pernr,
  pernr TYPE pernr-pernr,
END OF gt_pernr.

TYPES :
BEGIN OF gt_message,
  pernr TYPE  char30, "pernr-pernr,
  message TYPE char200,
END OF gt_message.


DATA: git_pernr TYPE STANDARD TABLE OF gt_pernr.
DATA :gwa_pernr TYPE gt_pernr.

DATA: git_zhr_ot_codes TYPE STANDARD TABLE OF zhr_ot_codes.
DATA :gwa_zhr_ot_codes TYPE zhr_ot_codes.

DATA: git_catsdb TYPE STANDARD TABLE OF catsdb.
DATA :gwa_catsdb TYPE catsdb.

DATA :git_success TYPE STANDARD TABLE OF gt_message,
      gwa_success TYPE  gt_message.
DATA :git_error TYPE STANDARD TABLE OF gt_message,
      gwa_error TYPE  gt_message.

DATA: gwa_bdcdata TYPE bdcdata,
      git_bdcdata TYPE STANDARD TABLE OF bdcdata.
DATA: g_tcode TYPE tstc-tcode,
      g_ctumode TYPE ctu_params-dismode,
      g_cupdate TYPE ctu_params-updmode.

DATA git_bdcmsgcoll TYPE STANDARD TABLE OF bdcmsgcoll.
*{   INSERT         D30K919902                                        1
DATA  : gwa_bdcmsgcoll  TYPE bdcmsgcoll.
*}   INSERT

DATA : gv_flag TYPE c.

INCLUDE zhtm004_cats_auto_sub.

INITIALIZATION.

START-OF-SELECTION.

  PERFORM get_catsdb_data.

GET peras.

  PERFORM get_emp_data.

END-OF-SELECTION.

  PERFORM write_status.
