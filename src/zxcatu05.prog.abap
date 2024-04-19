*&---------------------------------------------------------------------*
*&  Include           ZXCATU05
*&---------------------------------------------------------------------*
* 2013/02/01 - Ashwin Johari
* This exit is called after a user saves or check data in CATS screen.
* You cannot modify screen field values with this user exit - only
* validations are intended here.
************************************************************************
*----------------------------------------------------------------------*
*Revision # MZH01                             Name: Zakir Hossain      *
*SDP Ticket # 84360                           Date: 5/5/2015           *
*Description: Force entry of overtime code (OC) for overtime           *
*             attendance codes                                         *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*Revision # MZH02                                  Name: Zakir Hossain *
*SDP Ticket # 80769                                Date: 5/12/2015     *
*Description: Only allow Part time employees to use attendance 2009    *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*Revision # MZH03                          Name: Zakir Hossain         *
*SDP Ticket # 63930                        Date: 8/26/2015             *
*Description: Remove code as per the specification provided            *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*Revision # MZH04                          Name: Zakir Hossain         *
*SDP Ticket # 63930                        Date: 5/4/2016              *
*Description: Remove code as per the specification provided            *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*Revision # MZH05                             Name: Zakir Hossain      *
*SDP Ticket # ACR-3149                        Date: 12/6/2016          *
*Description: if CATSHOURS  us greater or less than 0.00 execute the   *
*error if it is 0.00 then ignore the error                             *
*----------------------------------------------------------------------*

DATA: HOLD_PERNR TYPE PERNR_D.  "MZH04
* check correct OC type is filled with absence/attendence type
* perform check-emp-data-for-date.

SORT CHECK_TABLE BY WORKDATE DESCENDING.

*Comment out by SAHMAD, SDP#80652

REFRESH LT_0001.  "MZH02

LOOP AT CHECK_TABLE INTO WA_CHECK_TABLE.
* Begin of MZH01
*  OC Code Validation is performed only for work date greater than/equals to July 1st 2015
  CHECK WA_CHECK_TABLE-WORKDATE GE '20150628'.
  IF ( WA_CHECK_TABLE-AWART EQ '2017' OR WA_CHECK_TABLE-AWART EQ '2018' OR
       WA_CHECK_TABLE-AWART EQ '2019' OR WA_CHECK_TABLE-AWART EQ '2022' OR
       WA_CHECK_TABLE-AWART EQ '2025' OR WA_CHECK_TABLE-AWART EQ '2028' ) .

    IF WA_CHECK_TABLE-VERSL IS INITIAL.
      I_MESSAGES-PERNR    = WA_CHECK_TABLE-PERNR.
      I_MESSAGES-CATSDATE = WA_CHECK_TABLE-WORKDATE.
      I_MESSAGES-MSGTY    = 'E'.
      I_MESSAGES-MSGID    = 'ZA'.
      I_MESSAGES-MSGNO    = '123'.
      I_MESSAGES-MSGV1    = WA_CHECK_TABLE-AWART.
      APPEND I_MESSAGES.
    ENDIF.

  ELSEIF WA_CHECK_TABLE-AWART NE '2100' AND WA_CHECK_TABLE-VERSL IS NOT INITIAL.

    I_MESSAGES-PERNR    = WA_CHECK_TABLE-PERNR.
    I_MESSAGES-CATSDATE = WA_CHECK_TABLE-WORKDATE.
    I_MESSAGES-MSGTY    = 'E'.
    I_MESSAGES-MSGID    = 'ZA'.
    I_MESSAGES-MSGNO    = '124'.
    I_MESSAGES-MSGV1    = WA_CHECK_TABLE-AWART.
    APPEND I_MESSAGES.
  ENDIF.

*  End of MZH01

*Begin of MZH02
*  Allow only part time employees to use attendance code 2009

  IF WA_CHECK_TABLE-AWART EQ '2009'
     AND WA_CHECK_TABLE-CATSHOURS NE '0.00'.  "MZH05
    IF HOLD_PERNR NE WA_CHECK_TABLE-PERNR.    "MZH04
      REFRESH LT_0001.                      "MZH04
      CALL FUNCTION 'HR_READ_INFOTYPE'
        EXPORTING
          TCLAS           = 'A'
          PERNR           = WA_CHECK_TABLE-PERNR
          INFTY           = '0001'
          BEGDA           = PRD_DATE
          ENDDA           = '99991231'
        IMPORTING
          SUBRC           = LV_SUBRC
        TABLES
          INFTY_TAB       = LT_0001
        EXCEPTIONS
          INFTY_NOT_FOUND = 1
          OTHERS          = 2.
    ENDIF.  "MZH04

    HOLD_PERNR = WA_CHECK_TABLE-PERNR.    "MZH04

    SORT LT_0001 BY ENDDA DESCENDING.
    LOOP AT LT_0001 INTO LS_0001
                    WHERE PERNR EQ WA_CHECK_TABLE-PERNR   "MZH04
                    AND   BEGDA LE WA_CHECK_TABLE-WORKDATE
                    AND   ENDDA GE WA_CHECK_TABLE-WORKDATE.
      IF ( LS_0001-PERSG EQ '1' AND ( LS_0001-PERSK EQ '02' OR LS_0001-PERSK EQ '04' OR LS_0001-PERSK EQ '06' ) ) OR
         ( LS_0001-PERSG EQ '2' AND ( LS_0001-PERSK EQ '02' OR LS_0001-PERSK EQ '04' OR LS_0001-PERSK EQ '06' ) ) OR
         ( LS_0001-PERSG EQ '4' AND ( LS_0001-PERSK EQ '02' OR LS_0001-PERSK EQ '04' OR LS_0001-PERSK EQ '06' ) ).
      ELSE. "not a part time employees
        I_MESSAGES-PERNR    = WA_CHECK_TABLE-PERNR.
        I_MESSAGES-CATSDATE = WA_CHECK_TABLE-WORKDATE.
        I_MESSAGES-MSGTY    = 'E'.
        I_MESSAGES-MSGID    = 'ZA'.
        I_MESSAGES-MSGNO    = '136'.
        I_MESSAGES-MSGV1    = WA_CHECK_TABLE-AWART.
        APPEND I_MESSAGES.
      ENDIF.
      EXIT.
    ENDLOOP.
  ENDIF.  "MZH04
* End of MZH02
ENDLOOP.


*End of Comment out by SAHMAD, SDP#80652

* * For WARP employees only ZUG_WARP profile should be selected and ZUG_WARP should not used for NON_WARP employees.

* * For WARP employees only ZUG_WARP profile should be selected and ZUG_WARP should not used for NON_WARP employees.
*{   INSERT         S01K900456                                        1
CALL FUNCTION 'HR_READ_INFOTYPE'
     EXPORTING
*           TCLAS                 = 'A'
       PERNR                 = WA_CHECK_TABLE-PERNR
       INFTY                 = '0007'
      BEGDA                 = SY-DATUM
      ENDDA                 =  SY-DATUM
*           BYPASS_BUFFER         = ' '
*           LEGACY_MODE           = ' '
*         IMPORTING
*           SUBRC                 =
     TABLES
       INFTY_TAB             =  IT_P0007
    EXCEPTIONS
      INFTY_NOT_FOUND       = 1
      OTHERS                = 2
             .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

LOOP AT IT_P0007 INTO WA_P0007.

ENDLOOP.

*
*}   INSERT

IF SAP_TCATS-VARIANT NE 'ZUG_PYAD'.
  IF SAP_TCATS-VARIANT NE 'ZUG_WARP' AND WA_P0007-KZTIM EQ 'WA'.
    I_MESSAGES-PERNR = WA_CHECK_TABLE-PERNR.
    I_MESSAGES-CATSDATE = WA_CHECK_TABLE-WORKDATE.
    I_MESSAGES-MSGTY = 'E'.
    I_MESSAGES-MSGID = 'ZA'.
    I_MESSAGES-MSGNO = '125'.
    I_MESSAGES-MSGV1 = WA_P0007-PERNR.
    APPEND I_MESSAGES.


  ELSEIF SAP_TCATS-VARIANT EQ 'ZUG_WARP' AND WA_P0007-KZTIM NE 'WA'.
    I_MESSAGES-PERNR = WA_CHECK_TABLE-PERNR.
    I_MESSAGES-CATSDATE = WA_CHECK_TABLE-WORKDATE.
    I_MESSAGES-MSGTY = 'E'.
    I_MESSAGES-MSGID = 'ZA'.
    I_MESSAGES-MSGNO = '126'.
    I_MESSAGES-MSGV1 = WA_P0007-PERNR.
    APPEND I_MESSAGES.
  ENDIF.
*Begin Addition by SAHMAD, SDP#80652
  IF ( SAP_TCATS-VARIANT NE 'ZUG_EWM1' AND WA_P0007-KZTIM EQ 'WM' ) OR
     ( SAP_TCATS-VARIANT EQ 'ZUG_EWM1' AND WA_P0007-KZTIM NE 'WM' ).
    I_MESSAGES-PERNR = WA_CHECK_TABLE-PERNR.
    I_MESSAGES-CATSDATE = WA_CHECK_TABLE-WORKDATE.
    I_MESSAGES-MSGTY = 'E'.
    I_MESSAGES-MSGID = 'ZA'.
    I_MESSAGES-MSGNO = '000'.
    I_MESSAGES-MSGV1 = 'Profile ZUG_EWM1 is allowed only for WM '.
    I_MESSAGES-MSGV2 = WA_P0007-PERNR.
    APPEND I_MESSAGES.
  ENDIF.
*End Addition by SAHMAD, SDP#80652
ENDIF.
