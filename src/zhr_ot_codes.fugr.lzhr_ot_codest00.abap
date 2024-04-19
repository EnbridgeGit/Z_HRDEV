*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHR_OT_CODES....................................*
DATA:  BEGIN OF STATUS_ZHR_OT_CODES                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHR_OT_CODES                  .
CONTROLS: TCTRL_ZHR_OT_CODES
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHR_OT_CODES                  .
TABLES: ZHR_OT_CODES                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
