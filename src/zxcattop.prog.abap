*&---------------------------------------------------------------------*
*&  Include           ZXCATTOP
*&---------------------------------------------------------------------*

* Variables for check whole timesheet.
DATA: WA_CHECK_TABLE LIKE CATS_COMM.
DATA  IT_P0007 TYPE TABLE OF  P0007.
DATA  WA_P0007 TYPE P0007.
DATA  PRD_DATE TYPE DATS VALUE '20150628'.

DATA: LV_SUBRC TYPE SYSUBRC,                  "MZH02
      LT_0001  TYPE STANDARD TABLE OF P0001,  "MZH02
      ls_0001  like LINE OF lt_0001.          "MZH02
