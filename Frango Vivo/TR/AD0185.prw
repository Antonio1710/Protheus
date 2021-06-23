#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAD0185    บ Autor ณ DANIEL             บ Data ณ  03/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MANUTENCAO DAS APANAHAS                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function AD0185     

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MANUTENCAO DAS APANAHAS')


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	Private cString := "ZV5"
	
	dbSelectArea("ZV5")
	dbSetOrder(1)
	
	AxCadastro(cString,"APANHA","U_DelFV5()","U_AltFV5()")

Return                                            

USER FUNCTION AltFV5()

	Local _lRet:=.F.
	Local _aArea:=GetArea()  
	Local _cChave:=xFilial("ZV1")+ZV5->ZV5_NUMOC	                   
	Local _nApnNew:=M->ZV5_QTDAVE	
	Local _nApnOld:=ZV5->ZV5_QTDAVE		
	Local _nDif:=ABS(_nApnNew-_nApnOld)
	Local _nApn:=_nDif
	
	U_ADINF009P('AD0185' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MANUTENCAO DAS APANAHAS')
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica o tipo de operacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if _nApnNew<_nApnOld 
		_nApn:=(-1)*_nDif  		
	EndIf		
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsiste Alteracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("ZV1")
	DbSetOrder(3)
	If DbSeek(_cChave,.T.)
  		RecLock("ZV1",.F.)
  		REPLACE ZV1_QTDAPN WITH ZV1_QTDAPN+_nApn
  		MsUnlock()      
  		_lRet:=.T.
	Else                                 
		RestArea(_aArea)
		MsgInfo("Ordem "+ZV5->ZV5_NUMOC+" nao encontrada","Inconsistente")
		_lRet:=.F.
	EndIf		
	RestArea(_aArea)
Return(_lRet)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacao da Exclusaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
USER FUNCTION DelFV5()

	Local _lRet:=.F.
	Local _aArea:=GetArea()                     
	Local _cChave:=xFilial("ZV5")+ZV5->ZV5_NUMOC	
	Local _nApn :=ZV5_QTDAVE

	U_ADINF009P('AD0185' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MANUTENCAO DAS APANAHAS')
					  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsiste Exclusaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("ZV1")
	DbSetOrder(3)
	If DbSeek(_cChave,.T.)
  		RecLock("ZV1",.F.)
  		REPLACE ZV1_QTDAPN WITH ZV1_QTDAPN-_nApn
  		MsUnlock()      
  		_lRet:=.T.
	Else                                 
		RestArea(_aArea)
		MsgInfo("Ordem "+ZV5->ZV5_NUMOC+" nao encontrada","Inconsistente")
		_lRet:=.T.
	EndIf		
	RestArea(_aArea)
RETURN(_lRet)
