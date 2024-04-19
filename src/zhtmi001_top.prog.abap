*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Table Declaration
*&---------------------------------------------------------------------*
TABLES:pernr.
NODES:peras.
*&---------------------------------------------------------------------*
*&  Type Declaration
*&---------------------------------------------------------------------*
TYPES:
BEGIN OF gt_pernr,
  pernr TYPE pernr_d,
  msg   TYPE char100,
END OF gt_pernr,

BEGIN OF gt_wbs,
  pnpnr TYPE ps_posnr,
  posid TYPE ps_posid,
  poski   TYPE ps_poski,
END OF gt_wbs.

*&---------------------------------------------------------------------*
*&  Internal table Declaration
*&---------------------------------------------------------------------*
DATA:
      git_catsdb          TYPE STANDARD TABLE OF catsdb,
      git_catsdb1         TYPE STANDARD TABLE OF catsdb,
      git_catsdb2         TYPE STANDARD TABLE OF catsdb,
      git_wbs_hr          TYPE STANDARD TABLE OF gt_wbs,
      git_wbs_fi          TYPE STANDARD TABLE OF gt_wbs,
      git_catsdb_final    TYPE STANDARD TABLE OF catsdb,
      git_catsdb_error    TYPE STANDARD TABLE OF catsdb,
      git_ptex2000fi      TYPE STANDARD TABLE OF ptex2000,
      git_ptex2000hr      TYPE STANDARD TABLE OF ptex2000,

      git_pernr           TYPE STANDARD TABLE OF gt_pernr,
      git_zhr_catsdb_dt   TYPE STANDARD TABLE OF zhr_catsdb_dt.
*&---------------------------------------------------------------------*
*&  Workarea Declaration
*&---------------------------------------------------------------------*
DATA:
      gwa_catsdb          TYPE catsdb,
      gwa_catsdb1         TYPE catsdb,
      gwa_pernr           TYPE gt_pernr,
      gwa_zhr_catsdb_dt   TYPE zhr_catsdb_dt .
*&---------------------------------------------------------------------*
*&  Global Variable Declaration
*&---------------------------------------------------------------------*
DATA:
      gv_date             TYPE begda,
      gv_time             TYPE uzeit,
      gv_flag             TYPE c,
      gv_dest             TYPE logsys.
