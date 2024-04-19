*----------------------------------------------------------------------*
* Program Name       :   ZHTMI008_CATSDBFI_CATSDBHR                    *
* Author             :   Jagadeesh Vanga                               *
* Date               :   01/11/2011                                    *
* Technical Contact  :   Rupesh Kumar                                  *
* Business Contact   :                                                 *
*                                                                      *
* Purpose            :   Absence/Attendance transfer from CATSDBFI to  *
*                        CATSDBHR for UGL Canada                       *
* Notes              :                                                 *
*                                                                      *
*----------------------------------------------------------------------*
*                      Modification Log                                *
*                                                                      *
* Changed On   Changed By      CTS          Description                *
* ---------------------------------------------------------------------*
*                                                                      *
*                                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*Revision # MZH01                              Name: Zakir Hossain     *
*SDP Ticket # 84928                            Date: 8/26/2015         *
*Description: The portal report that runs CATS_DA is getting the error *
* message # system error: ARBID.  ARBID on the CATSDB table is the     *
* objected for EAM config, which does not exist in PHR. Change         *
* ZHTMI008_CATSDBFI_CATSDBHR to send null in this field rather than    *
* the existing value in P01.                                           *
*----------------------------------------------------------------------*


REPORT  ZHTMI008_CATSDBFI_CATSDBHR LINE-SIZE 300 LINE-COUNT 65
NO STANDARD PAGE HEADING.

INCLUDE ZHTMI008_CATSDBFI_CATSDBHR_TOP.
INCLUDE ZHTMI008_CATSDBFI_CATSDBHR_SL.
INCLUDE ZHTMI008_CATSDBFI_CATSDBHR_LOG.
INCLUDE ZHTMI008_CATSDBFI_CATSDBHR_SUB.
