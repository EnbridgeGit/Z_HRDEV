*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_PRGLOG
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_PRGLOG
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM clear_data.

  PERFORM get_data_zhr_catsdb_dt.

GET peras.

  PERFORM populate_pernr_table.

END-OF-SELECTION.

  PERFORM get_catsdb_data.

  PERFORM get_changed_catsdb.

  PERFORM get_data_ptextable."SKAPSE 06/04/2012

  PERFORM update_catsdb_hr.

  PERFORM updat_zhr_catsdb_dt.

  PERFORM close_connection.

  PERFORM control_total.
