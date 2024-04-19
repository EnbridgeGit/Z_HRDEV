class ZCL_IM_TRIP_IMP_EXP_IMPL definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_TRIP_IMP_EXP_IMPL
*"* do not include other source files here!!!

  interfaces IF_EX_TRIP_IMP_EXP .
protected section.
*"* protected components of class ZCL_IM_TRIP_IMP_EXP_IMPL
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_TRIP_IMP_EXP_IMPL
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_TRIP_IMP_EXP_IMPL IMPLEMENTATION.


METHOD IF_EX_TRIP_IMP_EXP~RESTRICT_TRAVEL_RANGE.

  DATA: LV_ROLE TYPE AGR_NAME.

  SELECT SINGLE AGR_NAME INTO  LV_ROLE
                       FROM  AGR_USERS
                       WHERE AGR_NAME EQ 'Z:TV_TRAVEL_MANAGER'
                       AND   UNAME    EQ SY-UNAME
                       AND   TO_DAT   GE SY-DATUM.
  IF SY-SUBRC EQ 0.
    DELIMITING_DATE = '19000101'.
  ENDIF.
ENDMETHOD.


method IF_EX_TRIP_IMP_EXP~RESTRICT_TRIPS_IN_RANGE.

endmethod.
ENDCLASS.
