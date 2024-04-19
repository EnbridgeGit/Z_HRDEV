*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZHR_CATS_LOCK
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZHR_CATS_LOCK      .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
