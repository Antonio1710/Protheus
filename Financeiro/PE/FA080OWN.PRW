User Function FA080OWN()  

If IsInCallStack("FA080Can") .and. SE5->E5_LA='S'
MV_PAR03:=1
EndIf

// Alex Borges 10/01/12
_Produto :=  GetMV("MV_PRBLQ")              
_Conta   :=   GetMV("MV_CONTBLQ")
_ItemConta := GetMV("MV_ITMCTBL")
_CCusto :=  GetMV("MV_CCBLQ")

dbSelectArea("SD1")
dbSetOrder(1)
If dbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
     If (ALLTRIM(SD1->D1_COD) $ _Produto .AND. ALLTRIM(SD1->D1_CONTA) $ _Conta .AND. ALLTRIM(SD1->D1_ITEMCTA) $ _ItemConta .AND. ALLTRIM(SD1->D1_CC) $ _CCusto)
     	_lib := cTod('')
     Else
        _lib := DDatabase
     End If
Else
	_lib := DDatabase
End If

dbSelectArea("SE2")
RecLock("SE2",.F.) 
//E2_DATALIB := _lib
SE2->E2_DATALIB := _lib
SE2->E2_HIST    := SE2->E2_HIST + 'FA080OWN'  // Ricardo Lima - 05/06/18
MsUnlock()


Return .T.
