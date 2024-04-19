*&---------------------------------------------------------------------*
*&  Include           ZHTMI004_WARP_IHR_LOGIC                          *
*&---------------------------------------------------------------------*
*======================================================================
* AT-SELECTION SCREEN OUTPUT
*======================================================================

 AT SELECTION-SCREEN OUTPUT.
   PERFORM f_selscreen_output.
   PERFORM default_filepath.

*======================================================================
* AT-SELECTION SCREEN
*======================================================================
 AT SELECTION-SCREEN.
   PERFORM f_selscreen.


*======================================================================
* AT SELECTION-SCREEN ON VALUE-REQUEST
*======================================================================
 AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file1.
*" Presentation Server filename
   PERFORM f_valreq_file1 CHANGING p_file1.


 AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file3.
**" Application Server filename
   PERFORM get_f4filename CHANGING p_file3.


*======================================================================
* START-OF-SELECTION
*======================================================================
 START-OF-SELECTION.
** Instantiate interface utilities class
*   CLEAR gref_util.
*   IF rb_pres = abap_true.
*     CREATE OBJECT gref_util
*       EXPORTING
*         im_test     = abap_true
*         im_progname = sy-repid.
*   ELSE.
*     CREATE OBJECT gref_util.
*   ENDIF.
*" Read input file in an internal table
   PERFORM read_files.

   Perform get_data_t511.

*" Process the input file data
   PERFORM process_records.

*======================================================================
* END-OF-SELECTION
*======================================================================
 END-OF-SELECTION.

*Build the list output and the output report to be downloaded
*   PERFORM generate_output_report.
*{   INSERT         D30K920054                                        1
*Archive input file processed i.e. move input file to ARCH folder
*and delete it from input folder on application server
   IF rb_appl EQ abap_true.
*     CHECK rb_test NE abap_true. "Dont Archive the File when the interface is run in Test Mode
     IF rb_test NE abap_true.
     PERFORM archive_input_file.
     ENDIF.
   ENDIF.

*}   INSERT

* Standard interface end processing
*   gref_util->end_of_interface( ).
*Prepare ALV.
*Design the ALV layouts.
   PERFORM design_layout.
*perform ALV field cataloge.
   PERFORM alv_fieldcat.
*Display the ALV ouput.
   PERFORM display_alv.

*Archive input file processed i.e. move input file to ARCH folder
*and delete it from input folder on application server
*{   DELETE         D30K920054                                        2
*\   IF rb_appl EQ abap_true.
*\     CHECK rb_test NE abap_true. "Dont Archive the File when the interface is run in Test Mode
*\     PERFORM archive_input_file.
*\   ENDIF.
*}   DELETE
