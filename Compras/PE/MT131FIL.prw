#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT131FIL  �Autor  �Everson             � Data �  20/10/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para adicionar filtro na rotina gera      ���
��           � cota��o.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Chamado 029625                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION MT131FIL()
	
	//��������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                     �
	//����������������������������������������������������������������
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
		
		
		//Pede confirma��o ao usu�rio.
		If MsgYesNo("Deseja filtrar as cota��es pelo seu c�digo de comprador?","Fun��o MT131FIL")
			
			//Obt�m o c�digo do usu�rio.
			cCodUser := Alltrim(cValToChar(__cuserid))
			
			//Obt�m o c�digo de comprador do usu�rio.
			cCodComp := Posicione("SY1",3,xFilial("SY1") + cCodUser, "Y1_COD")
			cCodComp := Alltrim(cValToChar(cCodComp))
			
			//Valia o retorno da fun��o posicione.
			If Empty(cCodComp)
				MsgAlert("N�o foi poss�vel obter seu c�digo de comprador.","Fun��o M131FIL")
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
			//Obt�m o c�digo do usu�rio.
			//cCodUser := Alltrim(cValToChar(__cuserid))
			
			//Obt�m o c�digo de comprador do usu�rio.
			cCodComp := Posicione("SY1",3,xFilial("SY1") + cCompGer, "Y1_COD")
			cCodComp := Alltrim(cValToChar(cCodComp))
			
			//Valia o retorno da fun��o posicione.
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
