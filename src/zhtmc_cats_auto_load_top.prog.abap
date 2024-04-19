*&---------------------------------------------------------------------*
*&  Include           ZHTMC_CATSDBLOAD_TOP_NEW
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHTMC_CATSDBLOAD_TOP
*&---------------------------------------------------------------------*
TABLES: catsfields, tcats.

TYPES : BEGIN OF gt_input,
         employeenumber TYPE pernr-pernr,
         abs_att_type   TYPE awart,
         ot_comp_type   TYPE vrsch,
         position       TYPE plans,
         worktaxarea    TYPE hrwrkar,
         workdate       TYPE catsdate,
         catshours      TYPE catshours,
       END OF gt_input.

* Reference for Interface monitor
*DATA : gref_util TYPE REF TO zcl_hr_interface_util.

DATA: i_input TYPE STANDARD TABLE OF gt_input,
      w_input TYPE gt_input.

TYPES: ty_catsrecords TYPE STANDARD TABLE OF bapicats1.

DATA : git_catsrecords_in TYPE STANDARD TABLE OF bapicats1.
DATA : gwa_catsrecords_in TYPE  bapicats1.

DATA  git_catsrecords_out TYPE STANDARD TABLE OF bapicats2.
DATA git_return_cats TYPE STANDARD TABLE OF bapiret2.
DATA gwa_return_cats TYPE bapiret2.

CONSTANTS: con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
           con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf,
           con_comma TYPE c VALUE ','.

TYPES: BEGIN OF gty_catsdbcomm,
         pernr     TYPE pernr-pernr,
         workdate  TYPE catsdb-workdate,
         catshours TYPE catsdb-catshours,
         overtime  TYPE catshours,
       END OF gty_catsdbcomm.


TYPES: ty_t_target_hr   TYPE STANDARD TABLE OF cats_hours_per_day,
       ty_t_catsdbcomm  TYPE STANDARD TABLE OF catsdbcomm,
       ty_t_catsdbcomm1 TYPE STANDARD TABLE OF gty_catsdbcomm.

DATA : git_catsdb TYPE STANDARD TABLE OF catsdb.
DATA : git_catsdb1 TYPE STANDARD TABLE OF catsdb.
DATA : gwa_catsdb TYPE  catsdb.
DATA: git_catsdbcomm TYPE ty_t_catsdbcomm.

*DATA gwa_catsdbcomm TYPE catsdbcomm.
DATA git_catsdbcomm1 TYPE STANDARD TABLE OF gty_catsdbcomm.
*DATA gwa_catsdbcomm1 TYPE gty_catsdbcomm.
DATA : git_catsd TYPE STANDARD TABLE OF catsd.
DATA: git_message TYPE STANDARD TABLE OF mesg.
DATA: gwa_message TYPE  mesg.
DATA : gv_begin_date TYPE catsfields-dateto.
DATA : gv_end_date TYPE catsfields-datefrom.
DATA git_target_hours TYPE ty_t_target_hr.
DATA gwa_target_hours TYPE cats_hours_per_day.
DATA lv_hours TYPE catshours.
DATA : lv_date TYPE char10.

DATA: gwa_fname1    TYPE string,
      gwa_filename  TYPE string, " File name
      gwa_path      TYPE string,
      gwa_pathsplit TYPE string,
      git_pathsplit TYPE STANDARD TABLE OF string,
      gwa_fname2    TYPE string,
      gwa_fold1     TYPE string,
      gwa_fold2     TYPE localfile.

CONSTANTS:
    gc_x            TYPE c                VALUE 'X',
    gc_y            TYPE c                VALUE 'Y',
    gc_slash        TYPE char1            VALUE '/',
    gc_fslash       TYPE char1            VALUE '\',
    gc_underscore   TYPE c                VALUE '_',
    gc_dash         TYPE c                VALUE '-',
    gc_error_struc  TYPE tabname          VALUE 'ZHRS_CEREDIAN_ERROR',
    gc_error_rep    TYPE tabname          VALUE 'ZHPYI009_STIP_AUTH_OUT_LOG',
    gc_ucomm_onli   TYPE sscrfields-ucomm VALUE 'ONLI'.

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
0001.

TYPES:
BEGIN OF gty_pernr,
  pernr TYPE pernr-pernr,
END OF gty_pernr.

TYPES :
BEGIN OF gty_message,
  pernr    TYPE  char30, "pernr-pernr,
  workdate TYPE catsdb-workdate,        "MZH01
  msg_typ  TYPE bapi_mtype,
  message  TYPE char300,
END OF gty_message.


DATA: git_pernr      TYPE STANDARD TABLE OF gty_pernr.
DATA :gwa_pernr      TYPE gty_pernr,
      gv_tot_ee(7)   TYPE n,
      gv_tot_fail(7) TYPE n,
      gv_tot_recs(7) TYPE n,
      gv_tot_suc(7)  TYPE n,
      gv_tot_hrs_pernr(6) TYPE p DECIMALS 2,
      gv_tot_suc_hrs(16)  TYPE p DECIMALS 2.

DATA :git_success TYPE STANDARD TABLE OF gty_message,
      gwa_success TYPE  gty_message.
DATA :git_error TYPE STANDARD TABLE OF gty_message,
      gwa_error TYPE  gty_message.

DATA : git_catsdb2 TYPE STANDARD TABLE OF catsdb.
DATA : gwa_catsdb2 TYPE catsdb.

DATA: gwa_fieldcat   TYPE slis_fieldcat_alv,
      gwa_layout     TYPE slis_layout_alv,
      gwa_sort       TYPE slis_sortinfo_alv,
      git_fieldcat   TYPE slis_t_fieldcat_alv,
      git_sort       TYPE STANDARD TABLE OF slis_sortinfo_alv.

TYPES :

  BEGIN OF gty_output,
    pernr TYPE pernr-pernr,
    name  TYPE ename,
    absatts TYPE awart,
    day1 TYPE catscell,
    catshours1 TYPE pthours,
        day2 TYPE catscell,
    catshours2 TYPE pthours,
        day3 TYPE catscell,
    catshours3 TYPE pthours,
        day4 TYPE catscell,
    catshours4 TYPE pthours,
        day5 TYPE catscell,
    catshours5 TYPE pthours,
        day6 TYPE catscell,
    catshours6 TYPE pthours,
        day7 TYPE catscell,
    catshours7 TYPE pthours,
    END OF gty_output.

DATA :git_output TYPE STANDARD TABLE OF gty_output.
DATA gwa_output TYPE gty_output.

TYPES: BEGIN OF ty_alv_data,
         pernr      TYPE char30,
         workdate   TYPE catsdb-workdate,
         awart      TYPE awart,
*         target_hr  TYPE catshours,
*         hours_ent  TYPE catshours,
*         catshours  TYPE catshours,
         target_hr  TYPE char6,
         hours_ent  TYPE char6,
         catshours  TYPE char6,
         msg_typ    TYPE bapi_mtype,
         message    TYPE char300,
         status     TYPE icon-id,
       END OF ty_alv_data.

*TYPES: BEGIN OF ty_alv_data,
*         pernr      TYPE text15,
*         workdate   TYPE text12,
*         awart      TYPE text15,
*         target_hr  TYPE char12,
*         hours_ent  TYPE text20,
*         catshours  TYPE text15,
*         msg_typ    TYPE text15,
*         message    TYPE char300,
*         status     TYPE text10,
*       END OF ty_alv_data.

TYPES: BEGIN OF ty_header,
         pernr      TYPE text15,
         workdate   TYPE text12,
         awart      TYPE text10,
         target_hr  TYPE text25,
         hours_ent  TYPE text20,
         catshours  TYPE text15,
         msg_typ    TYPE text15,
         message    TYPE char300,
         status     TYPE text10,
       END OF ty_header.

TYPES: BEGIN OF ty_date,
         date   TYPE catsdate,
         active TYPE boole_d, "employee active?
       END OF ty_date.

DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv,
      gt_alv_data     TYPE STANDARD TABLE OF ty_alv_data,
      gs_alv_data     LIKE LINE OF gt_alv_data,
      gv_error        TYPE boole_d,
      gv_layout       TYPE slis_layout_alv,
      gt_events       TYPE slis_t_event,
      gt_attach       TYPE soli_tab,
      git_header      TYPE STANDARD TABLE OF ty_header,
      gwa_header      LIKE LINE OF git_header,
      git_tab_data    TYPE STANDARD TABLE OF string,
      gwa_tab_data    LIKE LINE OF git_tab_data,
      gv_spool        TYPE tsp01-rqident,
      git_dates       TYPE STANDARD TABLE OF ty_date.

CONSTANTS: gc_green  TYPE icon-id VALUE '@08@',
           gc_yellow TYPE icon-id VALUE '@09@',
           gc_red    TYPE icon-id VALUE '@0A@'.

CONSTANTS: BEGIN OF pertype,
             daily(1)       VALUE '1',
             weekly(1)      VALUE '2',
             halfmonthly(1) VALUE '3',
             monthly(1)     VALUE '4',
           END OF pertype.

DATA: days_on_screen TYPE sy-tabix,"number of days on screen
      gv_commit(1)   TYPE c.

CONSTANTS: days_of_a_week TYPE sy-tabix VALUE '7',
           const_1        TYPE sy-tabix VALUE '1',
           const_16       TYPE sy-tabix VALUE '16',
           const_31       TYPE sy-tabix VALUE '31'.
