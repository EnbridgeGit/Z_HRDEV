*&---------------------------------------------------------------------*
* Program Name       : ZHTMI004_WARP_IHR_IN                            *
* Author             : Prakash Jeevakala                               *
* Date               : 21/02/2012 (dd/mm/yyyy)                         *
* Technical Contact  : Prakash Jeevakala                               *
* Business Contact   : Jagadeesh Vanga                                 *
* Purpose            : This is an inbound interface to update CATSB    *
*                      with list of WARP EE timesheet data from pipe   *
*                      delimited input file.                           *
*----------------------------------------------------------------------*
*                      Modification Log                                *
*                                                                      *
* Changed On   Changed By           CTS          Description           *
*----------------------------------------------------------------------*
*                                                                      *
*                                                                      *
*&---------------------------------------------------------------------*

REPORT  zhtmi004_warp_ihr_in.

INCLUDE zhtmi004_warp_ihr_top.
INCLUDE zhtmi004_warp_ihr_sel.
INCLUDE zhtmi004_warp_ihr_logic.
INCLUDE zhtmi004_warp_ihr_form_dup.
