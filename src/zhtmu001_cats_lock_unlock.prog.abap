*&---------------------------------------------------------------------*
*& Report  ZHTMU001_CATS_LOCK_UNLOCK
*&
*&---------------------------------------------------------------------*
*&Program Name       : ZHPYU001_QUOTA_CORRECTION
*
*----------------------------------------------------------------------*
*                      Modification Log                                *
*                                                                      *
* Changed On   Changed By      CTS          Description                *
* ---------------------------------------------------------------------*
*
*&
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT  ZHTMU001_CATS_LOCK_UNLOCK.

* Table Declaration
TABLES: TCATS,
        ZHR_CATS_LOCK.


DATA: ITAB_LOCK LIKE ZHR_CATS_LOCK OCCURS 0 WITH HEADER LINE.

* Selection Screen Design

SELECTION-SCREEN BEGIN OF BLOCK FRM4 WITH FRAME TITLE text-012.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_BWKLY AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-013.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_MNTLY AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-014.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK FRM4.

SELECTION-SCREEN BEGIN OF BLOCK FRM1 WITH FRAME TITLE text-001.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
P_LOCK RADIOBUTTON GROUP GRP1 USER-COMMAND LOC.
SELECTION-SCREEN COMMENT 4(50) text-002.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK FRM2 WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_USRLK AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-004.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_TADLK AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-005.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_PAYLK AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-015.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_ALLLK AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-006.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK FRM2.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
P_UNLOCK RADIOBUTTON GROUP GRP1.
SELECTION-SCREEN COMMENT 4(50) text-007.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK FRM3 WITH FRAME TITLE text-011.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_USRUL AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-008.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_TADUL AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-009.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_PAYUL AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-016.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: P_ALLUL AS CHECKBOX.
SELECTION-SCREEN COMMENT 4(50) text-010.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK FRM3.
SELECTION-SCREEN END OF BLOCK FRM1.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF     P_LOCK = 'X'.
           P_USRUL = SPACE.
           P_TADUL = SPACE.
           P_PAYUL = SPACE.
           P_ALLUL = SPACE.
           MODIFY SCREEN.

           IF P_ALLLK = 'X'.
              P_USRLK = SPACE.
              P_TADLK = SPACE.
              P_PAYLK = SPACE.
              MODIFY SCREEN.
           ENDIF.

    ELSEIF P_UNLOCK = 'X'.
           P_USRLK = SPACE.
           P_TADLK = SPACE.
           P_PAYLK = SPACE.
           P_ALLLK = SPACE.
           MODIFY SCREEN.

           IF P_ALLUL = 'X'.
              P_USRUL = SPACE.
              P_TADUL = SPACE.
              P_PAYUL = SPACE.
              MODIFY SCREEN.
           ENDIF.
    ENDIF.

  ENDLOOP.

INITIALIZATION.

START-OF-SELECTION.

  PERFORM read_data.

  IF NOT     P_LOCK IS INITIAL.
     PERFORM LOCK_CATS.
  ELSEIF NOT P_UNLOCK IS INITIAL.
     PERFORM UNLOCK_CATS.
  ENDIF.

     PERFORM COMMIT_DATA.

     PERFORM WRITE_REPORT.


*&---------------------------------------------------------------------*
*&      Form  READ_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_DATA .
SELECT * FROM ZHR_CATS_LOCK
         INTO TABLE ITAB_LOCK.
ENDFORM.                    " READ_DATA
*&---------------------------------------------------------------------*
*&      Form  LOCK_CATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LOCK_CATS .
     IF NOT P_BWKLY IS INITIAL.

              LOOP AT ITAB_LOCK WHERE ABKRS   = '3B'.
                  IF NOT P_ALLLK IS INITIAL.
                         ITAB_LOCK-CATSLOCK = 'X'.
                         MODIFY ITAB_LOCK INDEX SY-TABIX.
                         CONTINUE.
                  ELSE.
                       IF ITAB_LOCK-USERGRP = 'ESSUSR' AND
                          NOT P_USRLK IS INITIAL.
                              ITAB_LOCK-CATSLOCK = 'X'.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

*{   REPLACE        DECK909278                                        1
*\                       IF ( ITAB_LOCK-USERGRP = 'TMADMG' OR
*\                          ITAB_LOCK-USERGRP = 'TMADMI' ) AND
*\                          NOT P_TADLK IS INITIAL.
                     IF ( ITAB_LOCK-USERGRP = 'TMADMG'   OR
                          ITAB_LOCK-USERGRP = 'TMADMI'   OR
                          ITAB_LOCK-USERGRP = 'SUPTAD' ) AND
                          NOT P_TADLK IS INITIAL.
*}   REPLACE
                              ITAB_LOCK-CATSLOCK = 'X'.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

                       IF ITAB_LOCK-USERGRP = 'PAYADM' AND
                          NOT P_PAYLK IS INITIAL.
                              ITAB_LOCK-CATSLOCK = 'X'.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.
                  ENDIF.
               ENDLOOP.
     ENDIF.

     IF NOT P_MNTLY IS INITIAL.

             LOOP AT ITAB_LOCK WHERE ABKRS   = '5B'.
                  IF NOT P_ALLLK IS INITIAL.
                         ITAB_LOCK-CATSLOCK = 'X'.
                         MODIFY ITAB_LOCK INDEX SY-TABIX.
                         CONTINUE.
                  ELSE.
                       IF ITAB_LOCK-USERGRP = 'ESSUSR' AND
                          NOT P_USRLK IS INITIAL.
                              ITAB_LOCK-CATSLOCK = 'X'.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

*{   REPLACE        DECK909278                                        2
*\                       IF ( ITAB_LOCK-USERGRP = 'TMADMG' OR
*\                          ITAB_LOCK-USERGRP = 'TMADMI' ) AND
*\                          NOT P_TADLK IS INITIAL.
                      IF ( ITAB_LOCK-USERGRP = 'TMADMG'   OR
                           ITAB_LOCK-USERGRP = 'TMADMI'   OR
                           ITAB_LOCK-USERGRP = 'SUPTAD' ) AND
                           NOT P_TADLK IS INITIAL.
*}   REPLACE
                              ITAB_LOCK-CATSLOCK = 'X'.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

                       IF ITAB_LOCK-USERGRP = 'PAYADM' AND
                          NOT P_PAYLK IS INITIAL.
                              ITAB_LOCK-CATSLOCK = 'X'.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.
                  ENDIF.
               ENDLOOP.
     ENDIF.

ENDFORM.                    " LOCK_CATS
*&---------------------------------------------------------------------*
*&      Form  UNLOCK_CATS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UNLOCK_CATS .

       IF NOT P_BWKLY IS INITIAL.

              LOOP AT ITAB_LOCK WHERE ABKRS   = '3B'.
                  IF NOT P_ALLUL IS INITIAL.
                         ITAB_LOCK-CATSLOCK = ' '.
                         MODIFY ITAB_LOCK INDEX SY-TABIX.
                         CONTINUE.
                  ELSE.
                       IF ITAB_LOCK-USERGRP = 'ESSUSR' AND
                          NOT P_USRUL IS INITIAL.
                              ITAB_LOCK-CATSLOCK = ' '.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

*{   REPLACE        DECK909278                                        1
*\                      IF ( ITAB_LOCK-USERGRP = 'TMADMG' OR
*\                          ITAB_LOCK-USERGRP = 'TMADMI' ) AND
*\                          NOT P_TADLK IS INITIAL.
                     IF ( ITAB_LOCK-USERGRP = 'TMADMG'    OR
                           ITAB_LOCK-USERGRP = 'TMADMI'    OR
                           ITAB_LOCK-USERGRP = 'SUPTAD' )  AND
                          NOT P_TADLK IS INITIAL.
*}   REPLACE
                              ITAB_LOCK-CATSLOCK = ' '.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

                       IF ITAB_LOCK-USERGRP = 'PAYADM' AND
                          NOT P_PAYUL IS INITIAL.
                              ITAB_LOCK-CATSLOCK = ' '.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.
                  ENDIF.
               ENDLOOP.
     ENDIF.

     IF NOT P_MNTLY IS INITIAL.

             LOOP AT ITAB_LOCK WHERE ABKRS   = '5B'.
                  IF NOT P_ALLUL IS INITIAL.
                         ITAB_LOCK-CATSLOCK = ' '.
                         MODIFY ITAB_LOCK INDEX SY-TABIX.
                         CONTINUE.
                  ELSE.
                       IF ITAB_LOCK-USERGRP = 'ESSUSR' AND
                          NOT P_USRUL IS INITIAL.
                              ITAB_LOCK-CATSLOCK = ' '.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

*{   REPLACE        DECK909278                                        2
*\                      IF ( ITAB_LOCK-USERGRP = 'TMADMG' OR
*\                          ITAB_LOCK-USERGRP = 'TMADMI' ) AND
*\                          NOT P_TADLK IS INITIAL.
                     IF ( ITAB_LOCK-USERGRP = 'TMADMG'    OR
                           ITAB_LOCK-USERGRP = 'TMADMI'    OR
                           ITAB_LOCK-USERGRP = 'SUPTAD' )  AND
                          NOT P_TADLK IS INITIAL.
*}   REPLACE
                              ITAB_LOCK-CATSLOCK = ' '.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.

                       IF ITAB_LOCK-USERGRP = 'PAYADM' AND
                          NOT P_PAYUL IS INITIAL.
                              ITAB_LOCK-CATSLOCK = ' '.
                              MODIFY ITAB_LOCK INDEX SY-TABIX.
                       ENDIF.
                  ENDIF.
               ENDLOOP.
     ENDIF.

ENDFORM.                    " UNLOCK_CATS
*&---------------------------------------------------------------------*
*&      Form  COMMIT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COMMIT_DATA .
     LOOP AT ITAB_LOCK.
          SELECT SINGLE * FROM ZHR_CATS_LOCK
                 WHERE VARIANT = ITAB_LOCK-VARIANT.
          IF SY-SUBRC NE 0.
*             INSERT ZHR_CATS_LOCK FROM ITAB_LOCK.
*                    IF SY-SUBRC = 0.
*                       COMMIT WORK.
*                    ELSE.
*                       ROLLBACK WORK.
*                    ENDIF.
          ELSE.
               UPDATE ZHR_CATS_LOCK FROM ITAB_LOCK.
                      IF SY-SUBRC = 0.
                         COMMIT WORK.
                      ELSE.
                         ROLLBACK WORK.
                      ENDIF.
          ENDIF.
     ENDLOOP.
ENDFORM.                    " COMMIT_DATA
*&---------------------------------------------------------------------*
*&      Form  WRITE_REPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_REPORT .

     CLEAR ITAB_LOCK.
     REFRESH ITAB_LOCK.
     FREE ITAB_LOCK.
     SELECT * FROM ZHR_CATS_LOCK
              INTO TABLE ITAB_LOCK.

            WRITE:/5 'Payroll Area' COLOR COL_HEADING INTENSIFIED ON,
                   19 '|',
                   20 'Payroll Area Text' COLOR COL_HEADING INTENSIFIED ON,
                   39 '|',
                   40 'User Group' COLOR COL_HEADING INTENSIFIED ON,
                   59 '|',
                   60 'User Group Name' COLOR COL_HEADING INTENSIFIED ON,
                   89 '|',
                   90 'Time Entry Profile' COLOR COL_HEADING INTENSIFIED ON,
                  109 '|',
                  110 'Time Entry Profile Name' COLOR COL_HEADING INTENSIFIED ON,
                  159 '|',
                  160 'Locked/Unlocked Status' COLOR COL_HEADING INTENSIFIED ON,
                  182 '|',
                  / SY-ULINE(182).
      LOOP AT ITAB_LOCK.
           WRITE:/    ITAB_LOCK-ABKRS UNDER 'Payroll Area',
                   19 '|',
                      ITAB_LOCK-ATEXT UNDER 'Payroll Area Text',
                   39 '|',
                      ITAB_LOCK-USERGRP UNDER 'User Group',
                   59 '|',
                      ITAB_LOCK-USRGRPTXT UNDER 'User Group Name',
                   89 '|',
                      ITAB_LOCK-VARIANT UNDER 'Time Entry Profile',
                  109 '|',
                      ITAB_LOCK-TEPTEXT UNDER 'Time Entry Profile Name',
                  159 '|',
                      ITAB_LOCK-CATSLOCK UNDER 'Locked/Unlocked Status',
                  182 '|',
                  / SY-ULINE(182).
      ENDLOOP.

ENDFORM.                    " WRITE_REPORT
