#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT131FIL  บAutor  ณEverson             บ Data ณ  20/10/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada para adicionar filtro na rotina gera      บฑฑ
ฑฑ           ณ cota็ใo.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 029625                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION MT131FIL()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cCodUser	:= ""
	Local cCodComp	:= ""
	Local cUsuarios	:= Alltrim(cValToChar(GetMv("MV_#USERFI")))
	Local _cRet		:= ""        
	Local cCompGer 	:= Alltrim(cValToChar(GetMv("MV_#USERGI")))     // incluido por Adriana em 23/10/17 - chamado 037734
	Local aFiltroSC1 := {}
	
	//Valida a empresa.
	If cEmpAnt <> "01"
		aFiltroSC1 := {}
		aAdd(aFiltroSC1,"")     //Retorno ADVPL
		aAdd(aFiltroSC1,"") // Retorno SQL
		Return(aFiltroSC1)
		
	EndIf
	
	//Valida a filial.
	If (Alltrim(cValToChar(__cuserid)) $(cUsuarios))
		
		
		//Pede confirma็ใo ao usuแrio.
		If MsgYesNo("Deseja filtrar as cota็๕es pelo seu c๓digo de comprador?","Fun็ใo MT131FIL")
			
			//Obt้m o c๓digo do usuแrio.
			cCodUser := Alltrim(cValToChar(__cuserid))
			
			//Obt้m o c๓digo de comprador do usuแrio.
			cCodComp := Posicione("SY1",3,xFilial("SY1") + cCodUser, "Y1_COD")
			cCodComp := Alltrim(cValToChar(cCodComp))
			
			//Valia o retorno da fun็ใo posicione.
			If Empty(cCodComp)
				MsgAlert("Nใo foi possํvel obter seu c๓digo de comprador.","Fun็ใo M131FIL")
				aFiltroSC1 := {}
				aAdd(aFiltroSC1,"")     //Retorno ADVPL
				aAdd(aFiltroSC1,"") // Retorno SQL
				Return(aFiltroSC1)          
			else
				_cRet      := "C1_CODCOMP ='" + cCodComp + "'"
				aFiltroSC1 := {}
				aAdd(aFiltroSC1,"")     //Retorno ADVPL
				aAdd(aFiltroSC1,_cRet) // Retorno SQL
			EndIf
			
		ELSE
		
			aFiltroSC1 := {}
			aAdd(aFiltroSC1,"")     //Retorno ADVPL
			aAdd(aFiltroSC1,_cRet) // Retorno SQL
			
		Endif
		
	else
			// incluido por Adriana em 23/10/17 - chamado 037734
			//Obt้m o c๓digo do usuแrio.
			//cCodUser := Alltrim(cValToChar(__cuserid))
			
			//Obt้m o c๓digo de comprador do usuแrio.
			cCodComp := Posicione("SY1",3,xFilial("SY1") + cCompGer, "Y1_COD")
			cCodComp := Alltrim(cValToChar(cCodComp))
			
			//Valia o retorno da fun็ใo posicione.
			If Empty(cCodComp)
				aFiltroSC1 := {}
				aAdd(aFiltroSC1,"") //Retorno ADVPL
				aAdd(aFiltroSC1,"") // Retorno SQL
				Return(aFiltroSC1)          
			else
				_cRet      := "C1_CODCOMP <> '" + cCodComp + "'"
				aFiltroSC1 := {}
				aAdd(aFiltroSC1,"")     //Retorno ADVPL
				aAdd(aFiltroSC1,_cRet) // Retorno SQL
			endif
		
	endif
Return(aFiltroSC1)
