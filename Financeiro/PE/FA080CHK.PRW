#include "rwmake.ch"   
#include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH    

/*/{Protheus.doc} User Function FA080CHK
	PONTO DE ENTRADA Baixa de Titulos a Pagar e Mensagem de Adiantamento a Fornecedor 
	@type  Function
	@author Rogerio Nutti
	@since 19/12/2001
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado TI     - Heraldo - 26/05/2004 - Incluido o procedimento de atualizacao da Tabela SZ9 quando for pagamento antecipado de frete.
	@history Chamado 053347 - FWNM    - 09/12/2019 - || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
    @history Chamado 056247 - FWNM    - 15/05/2020 - OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
/*/
User Function FA080CHK()
                         
	Local _cRet := ""
	Local E2NUM     := SE2->E2_NUM 
	Local E2PREFIXO := SE2->E2_PREFIXO 
	Local E2FORNECE := SE2->E2_FORNECE 
	Local E2LOJA    := SE2->E2_LOJA
	Local E2DIVERG  := SE2->E2_XDIVERG
	Local lPgICM    := .F.
	Local cTpDivf   := "000004"

	SetPrvt("_SALIAS,_SINDEX,_SRECNO,_NVALBX,_SNUMF1,_SNUMD1")
	SetPrvt("_NPERC,_NVALRAT,_CFORNECE,_CNOMFOR,_SINDE2,_SNUME2, _aAreaE2")
	SetPrvt("_NCONTFOR,CTELAENTR,_cMens,_lRET,_lPASE2,_cSql,_cCNPJ,_cCodSa1,_cNumTit,_lSe1,_cAutBx")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava ambiente inicial     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_sAlias := Alias()
	_sIndex := IndexOrd()
	_sRecno := Recno()
	_aAreaE2 := GetArea("SE2")
	_lRet := .T.
	_lPASE2 := .F.
	_lSe1 := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotina de aviso de Adiantamento de Fornecedores ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cFornece := SE2->E2_FORNECE
	_cNomFor  := SE2->E2_NOMFOR
	_cAutBx   := ""  && SE2->E2_YAUTBX  Retirado por gerar error.log na baixa por falta do campo.
	_cCNPJ :=  SubStr(Posicione("SA2",1,xFilial("SA2")+_cFornece,"A2_CGC"),1,8)  //Captura o CNPJ do fornecedor para procurar no SA1
	_cCodSa1 := ""
	_cNumTit := ""

	If SE2->E2_TIPO = "PFA"
		dbSelectArea("SZ9")
		dbsetorder(1)
		If dbSeek( xFilial("SZ9")+SE2->E2_APAGTO)
			RecLock("SZ9",.F.)
			SZ9->Z9_DTPGTO := DDATABASE
			SZ9->Z9_STATUS := "3"
			Msunlock()
		Endif	
	Endif

    // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 15/05/2020
    If AllTrim(SE2->E2_XDIVERG) == "S" .or. AllTrim(SE2->E2_RJ) == "X" 
    	_lRet := .F.
        MsgAlert("Título não pode ser movimentado pois está aguardando aprovação!", "Central Aprovação")
	EndIf
    //

	// RICARDO LIMA - 03/01/18
	IF _lRet
		DbSelectArea("SF1")
		DbSetOrder(1) // SF10101 F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
		if DbSeek( FwxFilial("SF1") +  E2NUM + E2PREFIXO + E2FORNECE + E2LOJA  )
			IF SF1->F1_COND = "ICM"
				IF EMPTY(E2DIVERG)
				lPgICM := .T.
				ENDIF
			ENDIF			
		endif
	ENDIF

	IF lPgICM 	 	
		If MsgYesNo("Titulo gerado a partir de um Pedido de Compra de ICMS, antes de Realizar a Baixa e necessario enviar para aprovação, Deseja Enviar?")
			_lRet := .F.
			
			SE2->E2_XDIVERG := 'S'
			DbSelectArea("SX5")
			DbSetOrder(1)
			DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
			
			// gera registro para aprovacao		
			RecLock("ZC7",.T.)
				ZC7->ZC7_FILIAL := FwxFilial("SE2")
				ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
				ZC7->ZC7_NUM   	:= SE2->E2_NUM
				ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
				ZC7->ZC7_TIPO   := SE2->E2_TIPO // Ricardo Lima - 27/03/18
				ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
				ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
				ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
				ZC7->ZC7_TPBLQ 	:= cTpDivf
				ZC7->ZC7_DSCBLQ	:= ALLTRIM(SX5->X5_DESCRI) + " - " + "TITULOS DE ICMS"
				ZC7->ZC7_RECPAG := "P"	 
				ZC7->ZC7_USRALT := __cUserID						 		
			MSUnlock()    	     	
		else
			_lRet := .F.
		endif   	 	
	ENDIF
//	endif

	/* RETIRADO POR GERAR ERROR.LOG E T
	//Busca no SA1 a existencia de mais CNPJ pegando os 8 primeiros
	_cSql := "SELECT A1_COD FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND "
	_cSql += "SUBSTRING(A1_CGC,1,8) = '"+ _cCNPJ +"' AND D_E_L_E_T_ = ''"  
	TcQuery _cSql NEW ALIAS "QSA1"
	If !Empty(QSA1->A1_COD)
	dbSelectArea("QSA1")     
	dbGoTop()
	While !Eof()
		If _cCodSa1 = ""
			_cCodSa1 := "'" + QSA1->A1_COD + "'"
		Else   
			_cCodSa1 := _cCodSa1 + ",'" + QSA1->A1_COD + "'"
		EndIf   
		QSA1->(dbSkip())
	End  
	QSA1->(dbCloseArea())  
	Else
	QSA1->(dbCloseArea())  
	EndIf   

	_cSql := ""
	_cSql := "SELECT E1_NUM FROM " + RetSqlName("SE1") + " WHERE E1_CLIENTE IN (" + _cCodSa1 + ") AND "
	_cSql += "E1_SALDO > 0 AND D_E_L_E_T_ = ''"
	TcQuery _cSql NEW ALIAS "QSE1"
	If !Empty(QSE1->E1_NUM)
	dbSelectArea("QSE1")
	dbGoTop()
	While !Eof()
		If _cNumTit = ""
			_cNumTit := QSE1->E1_NUM
		Else
			_cNumTit := _cNumTit + "," + QSE1->E1_NUM
		EndIf
		QSE1->(dbSkip())
	End      
	QSE1->(dbCloseArea())
		_cMens := 			   OemToAnsi("Existem titulos a receber para este fornecedor que ainda não foram baixados.") +Chr(13)
		_cMens := _cMens + 	OemToAnsi("Cliente codigo "+SubStr(_cCodSa1,2,6) + " Titulo(s)" + _cNumTit) +Chr(13)
		_cMens := _cMens + 	OemToAnsi("Nao efetue a baixa antes da verificação do(s) titulo(s)!")  +Chr(13)
		MsgBox(_cMens,"ATENCAO","ALERT")
	_lSe1 := .T.
	Else
	QSE1->(dbCloseArea())
	EndIf
		
	_aAreaE2 := GetArea("SE2")

	dbSelectArea("SE2")
	_sAliasSE2 := Alias()
	_sIndexSE2 := IndexOrd()
	_sRecnoSE2 := Recno()
	dbSetOrder(14)  // E2_FILIAL+E2_TIPO+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_FORNECE+E2_LOJA

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o primeiro titulo do Tipo PA          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dbSeek( xFilial("SE2")+"PA " )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a leitura dos titulos do Fornecedor         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do While !Eof() .and. Alltrim(SE2->E2_TIPO) == "PA"
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza titulos diferentes de PA               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If _cFornece # SE2->E2_FORNECE
				dbSkip()
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se achou PA do Forneceodor e valor > 0, apresenta msg e sai do laco   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE2->E2_TIPO = "PA " .and. !EMPTY(SE2->E2_APAGTO)
				dbSelectArea("SZ9")
				dbsetorder(1)
				If dbSeek( xFilial("SZ9")+SE2->E2_APAGTO)
					RecLock("SZ9",.F.)
					SZ9->Z9_DTPGTO := DDATABASE
					SZ9->Z9_STATUS := "3"
					Msunlock()
				Endif
			Endif
			If SE2->E2_SALDO > 0
				_cMens := 			OemToAnsi("Existem ADIANTAMENTOS feitos para este Fornecedor ")+Chr(13)
				_cMens := _cMens + 	OemToAnsi("e que nao foram compensados ainda.") +Chr(13)
				_cMens := _cMens + 	OemToAnsi(_cFornece + " - " + _cNomFor) +Chr(13)
				_cMens := _cMens + 	OemToAnsi("Nao efetue a baixa antes da compensacao dos titulos!")  +Chr(13)
				MsgBox(_cMens,"ATENCAO","ALERT")
				_lPASE2 := .T.
				Exit
			Endif		
			dbSelectArea("SE2")
			dbSkip()
		Enddo       
	
	
	if _lSe1 .Or. _lPASE2    
		if _cAutBx $ "1"
			_lRet := .T.  
			dbGoto(_sRecnoSE2)
			RecLock("SE2",.F.)
				SE2->E2_YVALAC := "2"
			MsUnlock()      
			RestArea(_aAreaE2)      
		Else   
			_lRet := .F.
			MsgBox("Baixa não realizada, verifique autorização!","ATENCAO","ALERT")
			dbGoto(_sRecnoSE2)
			RecLock("SE2",.F.)
				SE2->E2_YVALAC := "1"
			MsUnlock()      
			RestArea(_aAreaE2)
		EndIf   
	else
		_lRet := .T.
	endif
		
	Endif
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura ambiente inicial  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//dbSelectArea(_sAliasSE2)
	//dbSetOrder(_sIndexSE2)
	//dbGoto(_sRecnoSE2)

	dbSelectArea(_sAlias)
	dbSetOrder(_sIndex)
	dbGoto(_sRecno)

Return _lRet