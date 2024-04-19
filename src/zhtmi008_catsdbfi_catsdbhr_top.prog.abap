*&---------------------------------------------------------------------*
*&  Include           ZHTMI008_CATSDBFI_CATSDBHR_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Table Declaration
*&---------------------------------------------------------------------*
tables:pernr.
nodes:peras.
*&---------------------------------------------------------------------*
*&  Type Declaration
*&---------------------------------------------------------------------*
types:
begin of gt_pernr,
  pernr type pernr_d,
  msg   type char100,
end of gt_pernr,

BEGIN OF gt_WBS,
  pnpnr TYPE PS_POSNR,
  posid TYPE PS_POSID,
  poski   TYPE PS_POSKI,
END OF gt_wbs.

*&---------------------------------------------------------------------*
*&  Internal table Declaration
*&---------------------------------------------------------------------*
data:
      git_catsdb          type standard table of catsdb,
      git_wbs_hr          type standard table of gt_wbs,
      git_wbs_fi          type standard table of gt_wbs,
      git_catsdb1         type standard table of catsdb,
      git_catsdb2         type standard table of catsdb,
      git_catsdb_final    type standard table of catsdb,
      git_catsdb_error    type standard table of catsdb,
      git_ptex2000fi      type standard table of ptex2000,
      git_ptex2000hr      type standard table of ptex2000,

      git_ptex2010fi      type standard table of ptex2010,
      git_ptex2010hr      type standard table of ptex2010,

      git_pernr           type standard table of gt_pernr,
      git_zhr_catsdb_dt   type standard table of zhr_catsdb_dt.
*&---------------------------------------------------------------------*
*&  Workarea Declaration
*&---------------------------------------------------------------------*
data:
      gwa_catsdb          type catsdb,
      gwa_wbs             type gt_wbs,
      gwa_catsdb1         type catsdb,
      gwa_pernr           type gt_pernr,
      gwa_zhr_catsdb_dt   type zhr_catsdb_dt .
*&---------------------------------------------------------------------*
*&  Global Variable Declaration
*&---------------------------------------------------------------------*
data:
      gv_date             type begda,
      gv_time             type uzeit,
      gv_flag             type c,
      gv_dest             type logsys.
