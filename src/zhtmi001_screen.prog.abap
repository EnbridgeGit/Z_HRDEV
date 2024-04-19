*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_SCREEN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZHTMI001_SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:p_upd AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS:p_dest TYPE tbdls-logsys OBLIGATORY ."DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.
