*&---------------------------------------------------------------------*
*&  Include           ZHTMI008_CATSDBFI_CATSDBHR_LOG
*&---------------------------------------------------------------------*
start-of-selection.

  perform clear_data.

  perform get_data_zhr_catsdb_dt.

get peras.

  perform populate_pernr_table.

end-of-selection.

  perform get_catsdb_data.

  PERFORM get_data_ptextable.

  perform get_changed_catsdb.

  perform update_catsdb_hr.

  perform updat_zhr_catsdb_dt.

  perform close_connection.

  perform control_total.
