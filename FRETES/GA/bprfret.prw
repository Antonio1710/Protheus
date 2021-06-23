#include "Protheus.ch"

User Function bprfret

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cRet := .T.
codTab  := M->ZVB_CODTAB
dInicio := M->ZVB_DATINI 

IF !EMPTY(M->ZVB_DATFIM) 
     IF(M->ZVB_DATINI > M->ZVB_DATFIM)
          Alert("PERIODO DE DATA INVALIDA")
          cRet := .F.
     Else
         cRet := .T.
     End If
End If          

If !EMPTY(dInicio)
  	dbSelectArea("ZVB")
   	dbSetOrder(1)  //   Indice Codigo
    If dbSeek(xFilial("ZVB")+codTab)
       While ZVB->ZVB_CODTAB == codTab
          If dInicio <= ZVB->ZVB_DATFIM
             Alert("A data informada ja esta cadastrada em algum periodo.") 
             cRet := .F.
             Dbskip()
          Else
             Dbskip()
             cRet := .T.
          End If  
       End Do
    End If
End If

Return (cRet)