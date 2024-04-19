*&---------------------------------------------------------------------*
*&  Include           ZHTMI004_WARP_IHR_TOP
*&---------------------------------------------------------------------*

TABLES: sscrfields.
TYPE-POOLS: abap, slis, icon.

*---------------------------------------------------------------------
*TYPES
*---------------------------------------------------------------------
TYPES : BEGIN OF ty_tab,
        pernr(8) TYPE n,
        begda TYPE begda,
        wbs_elm  TYPE ps_posid,"3.  WBS elements / Internal Order / Cost center
        rec_order TYPE eaufnr, "CATS receiving order
        rec_cctr TYPE ekostl, "CATS receiving cost center.
        awart TYPE awart,"Attendance / Abscence Quota type
        versl TYPE vrsch,
        wagetype TYPE lgart, "Wage Type
        unit TYPE meinh,"catsnumber, "Unit of Mesuare
        catshours TYPE  char7," catshours, "Attendance Hours
        END OF ty_tab.

TYPES : BEGIN OF ty_error,
          pernr(8) TYPE n,
        begda TYPE char10,
        wbs_elm  TYPE char24,"3.  WBS elements / Internal Order / Cost center
        rec_order TYPE eaufnr, "CATS receiving order
        rec_cctr TYPE ekostl, "CATS receiving cost center.
        awart TYPE awart,"Attendance / Abscence Quota type
        versl TYPE vrsch,
        wagetype TYPE lgart, "Wage Type
        unit TYPE meinh,"catsnumber, "Unit of Mesuare
        catshours TYPE  char7," catshours, "Attendance Hours
        err_txt(150) TYPE c,
        END OF ty_error.

TYPES : BEGIN OF ty_p0000,
          pernr TYPE pernr_d,
          stat2 LIKE p0000-stat2,
        END OF ty_p0000.

TYPES : BEGIN OF ty_success,
        pernr(8) TYPE n,
        begda TYPE char10,
        wbs_elm  TYPE char24,"eproj,"3.	WBS elements / Internal Order / Cost center
        rec_order TYPE eaufnr, "CATS receiving order
        rec_cctr TYPE ekostl, "CATS receiving cost center.
        awart TYPE awart,"Attendance / Abscence Quota type
        versl TYPE vrsch,
        wagetype TYPE lgart, "Wage Type
        unit TYPE meinh,"catsnumber, "Unit of Mesuare
        catshours TYPE  char7," catshours, "Attendance Hours
        msg_txt(150) TYPE c,
        END OF ty_success.
TYPES : BEGIN OF gt_output,
        stat TYPE char14,"Stuatu of the upddate
        pernr(8) TYPE n,
        begda TYPE char10,
        wbs_elm  TYPE char24,"eproj,"3.	WBS elements / Internal Order / Cost center
        rec_order TYPE eaufnr, "CATS receiving order
        rec_cctr TYPE ekostl, "CATS receiving cost center.
        awart TYPE awart,"Attendance / Abscence Quota type
        versl TYPE vrsch,
        wagetype TYPE lgart, "Wage Type
        unit TYPE meinh,"catsnumber, "Unit of Mesuare
        catshours TYPE  char7," catshours, "Attendance Hours
        status  TYPE string,
        END OF gt_output.
*---------------------------------------------------------------------
*Internal tables
*---------------------------------------------------------------------
DATA : git_bdcdata TYPE STANDARD TABLE OF bdcdata,
       git_bdcmsgcoll TYPE STANDARD TABLE OF bdcmsgcoll,
       git_input TYPE STANDARD TABLE OF string,
       git_tab TYPE STANDARD TABLE OF ty_tab,
       git_error TYPE STANDARD TABLE OF ty_error,
       git_warning TYPE STANDARD TABLE OF ty_error,
       git_p0000 TYPE STANDARD TABLE OF ty_p0000,
       git_success TYPE STANDARD TABLE OF ty_success,
       git_msg TYPE srm_t_solisti1,
       git_msg1 TYPE srm_t_solisti1,
       git_fieldcat TYPE slis_t_fieldcat_alv,
       git_output TYPE STANDARD TABLE OF gt_output,
       git_pathsplit TYPE STANDARD TABLE OF string,
       git_t511 TYPE STANDARD TABLE OF t511.

DATA:    gwa_dir_list  TYPE epsfili.
DATA:    git_dir_list  LIKE STANDARD TABLE OF gwa_dir_list.
*---------------------------------------------------------------------
*Work Areas
*---------------------------------------------------------------------
DATA : gwa_tab TYPE ty_tab,
       gwa_t511 TYPE t511,
       gwa_input TYPE string,
       gwa_error TYPE ty_error,
       gwa_warning TYPE ty_error,
       gwa_fieldcat TYPE slis_fieldcat_alv,
       gwa_layout    TYPE slis_layout_alv,
       gwa_p0000 TYPE ty_p0000,
       gwa_output TYPE  gt_output,
       gwa_bdcdata TYPE bdcdata,
       gwa_bdcmsgcoll TYPE bdcmsgcoll,
       gwa_success TYPE ty_success,
       gwa_msg TYPE solisti1.
*---------------------------------------------------------------------
*Global Variables
*---------------------------------------------------------------------
DATA:file_table  TYPE STANDARD TABLE OF sdokpath,
     file_table1 TYPE STANDARD TABLE OF sdokpath,
     dir_table   TYPE STANDARD TABLE OF sdokpath,
     gv_tcode TYPE tstc-tcode,
     gv_ctumode TYPE ctu_params-dismode,
     gv_cupdate  TYPE ctu_params-updmode,
     gv_qid TYPE apqi-qid,
     gv_sess_flag TYPE c,
     gv_colpos  TYPE i,
     gv_insert_incl TYPE i. " No of records inserted into session.

*---------------------------------------------------------------------
*Reference Variables
*---------------------------------------------------------------------
* Reference for Interface monitor
*DATA : gref_util TYPE REF TO zcl_hr_interface_util.

*---------------------------------------------------------------------
*Constants
*---------------------------------------------------------------------
*{   REPLACE        D30K920054                                        1
*\CONSTANTS : gc_for_slash TYPE c VALUE '\'.
CONSTANTS : gc_for_slash TYPE c VALUE '/'.
*}   REPLACE
