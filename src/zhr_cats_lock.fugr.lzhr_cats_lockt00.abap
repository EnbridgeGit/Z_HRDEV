*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHR_CATS_LOCK...................................*
DATA:  BEGIN OF STATUS_ZHR_CATS_LOCK                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHR_CATS_LOCK                 .
CONTROLS: TCTRL_ZHR_CATS_LOCK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHR_CATS_LOCK                 .
TABLES: ZHR_CATS_LOCK                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
