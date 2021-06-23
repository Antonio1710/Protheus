#Include "rwmake.ch"

&&Para atendimento do chamado 008188 conforme solicitado por Rosana apos analise do LP532001.
               
User Function LP532001()    
Local _nRet := 0

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

if SE5->E5_MOTBX == "DEB" .AND. ALLTRIM(SE5->E5_TIPO) != "PA" .AND. SE5->E5_TIPODOC == "BA"
   IF SE5->E5_VLDESCO == 0 .And. SE2->E2_DECRESC > 0
      _nRet := SE5->(E5_VALOR-E5_VLACRES)+SE2->E2_DECRESC
   Else
      _nRet := SE5->(E5_VALOR+E5_VLDESCO-E5_VLACRES)
   endif
endif
      
Return(_nRet)
