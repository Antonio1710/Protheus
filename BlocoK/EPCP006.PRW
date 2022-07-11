#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function EPCP006
	Rotina de processamento de Estorno de ajuste de inventário customizado
	@type  Function
	@author Eduardo Fernandes
	@since 16/08/2006
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 054451 - Fernando Macieira - 29/01/2020 - OS 055846 || CONTROLADORIA || || 8947 || ESTORNO SEM ENDERECO
	@history chamado 056607 - Fernando Macieira - 16/03/2020 - || OS 058077 || CONTROLADORIA || FRED_SANTOS || 8947 || SALDO ESTOQUE
	@history chamado 056607 - Fernando Macieira - 10/06/2020 - || OS 058077 || CONTROLADORIA || FRED_SANTOS || 8947 || SALDO ESTOQUE
	@history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio
	@history ticket   18250 - Fernando Macieira - 23/08/2021 - Perda de Endereçamento - Protheus
	@history ticket      TI - Fernando Macieira - 15/09/2021 - MV_PAR05 no logzbe sem tratativa de conversão data/caracter
	@history ticket   64740 - Fernando Macieira - 30/11/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria
/*/
User Function EPCP006()

	Local nOpca  		:= 0
	Local oDlg          := NIL

	Private cPerg := "PCP006"
	Private cMV_PAR01, cMV_PAR02, cMV_PAR03, cMV_PAR04, cMV_PAR05, cMV_PAR06, cMV_PAR07 // @history ticket   64740 - Fernando Macieira - 30/11/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria
	Private lNewEstorno   := GetMV("MV_#KFSDEL",,.T.) // @history ticket   64740 - Fernando Macieira - 30/11/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de processamento de Estorno de ajuste de inventário customizado')

	If Substr(cAcesso,19,1) == " "
		Help ( " ", 1, "SEMPERM" )
		Return .F.
	EndIf

	DEFINE MSDIALOG oDlg FROM  96,4 TO 355,625 TITLE OemToAnsi("Estorno de Ajuste de Inventario") PIXEL

		@ 18, 9 TO 99, 300 LABEL "" OF oDlg  PIXEL
		@ 29, 15 Say OemToAnsi("O objetivo deste programa e gerar automaticamente o estorno do inventario, conforme o preenchimento") SIZE 275, 10 OF oDlg PIXEL	
		@ 38, 15 Say OemToAnsi("dos parametros. Se o estorno for concretizado, a legendada tela de inventario ficara com a cor LARANJA,") SIZE 275, 10 OF oDlg PIXEL	
		@ 48, 15 Say OemToAnsi("retornando o saldo a situacao anterior.") SIZE 275, 10 OF oDlg PIXEL	
		@ 68, 15 Say OemToAnsi("Sera gerado historico para todos os processamentos, mesmos dos que tiveram inconsistencias.") SIZE 255, 10 OF oDlg PIXEL	

		DEFINE SBUTTON FROM 108,209 TYPE 05 ACTION Pergunte("PCP006",.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTER

	If nOpca <> 1
		Return Nil
	Endif 

	Pergunte(cPerg, .f.) // Chamado n. 058838 || OS 060356 || CONTROLADORIA || FRED_SANTOS || 1196426706 || ROTINA INVENTARIO - FWNM - 10/06/2020

	cMV_PAR01 := MV_PAR01 // do produto
	cMV_PAR02 := MV_PAR02 // até produto
	cMV_PAR03 := MV_PAR03 // do inventário
	cMV_PAR04 := MV_PAR04 // até inventário
	cMV_PAR05 := MV_PAR05 // data fim inventário
	cMV_PAR06 := MV_PAR06 // do armazém
	cMV_PAR07 := MV_PAR07 // até armazém

	If nOpcA == 1	
		If lNewEstorno
			msAguarde({||newPCP006(cMV_PAR01,cMV_PAR02,cMV_PAR03,cMV_PAR04,cMV_PAR06,cMV_PAR07)},,"Estornando movimentação do produto... ") // @history ticket   64740 - Fernando Macieira - 30/11/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria
		Else
			Processa({||PCP006PROC()},,"Analisando movimentos para estorno...")
		EndIf
	Endif 

Return      

/*/{Protheus.doc} Static Function AjustaSX1
	Ajusta perguntas SX1
	@type  Static Function
	@author Eduardo Fernandes
	@since 17/08/2006
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function AjustaSX1()

	PutSX1(cPerg,"01","Do Produto       ","","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01"	,""		,""		,""		,Space(15)			,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1(cPerg,"02","Ate o Produto    ","","","mv_ch2","C",15,0,0,"G","","SB1","","","mv_par02"	,""		,""		,""		,"ZZZZZZZZZZZZZZZ"	,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1(cPerg,"03","Do  Inventario   ","","","mv_ch3","C", 6,0,0,"G","","   ","","","mv_par03"	,""		,""		,""		,Space(6)			,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1(cPerg,"04","Ate o Inventario ","","","mv_ch4","C", 6,0,0,"G","","   ","","","mv_par04"	,""		,""		,""		,"ZZZZZZ"			,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1(cPerg,"05","Data Fim Invent. ","","","mv_ch5","D",08,0,0,"G","","   ","", "","mv_par05","", "", "", "",    "", "", "", "", "", "", "", "", "", "", "", "", {}, {}, {} )

	// @history ticket   64740 - Fernando Macieira - 15/12/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria
	PutSX1(cPerg,"06","Do Armazem   ","","","mv_ch6","C", TamSX3("NNR_CODIGO")[1],0,0,"G","","   ","","","mv_par06"	,""		,""		,""		,Space(6)			,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1(cPerg,"07","Ate Armazem  ","","","mv_ch7","C", TamSX3("NNR_CODIGO")[1],0,0,"G","","   ","","","mv_par07"	,""		,""		,""		,"ZZZZZZ"			,""		,""		,""		,"","","","","","","","","",{},{},{})
	//

Return .T.

/*/{Protheus.doc} nomeStaticFunction
	Rotina de processamento de Estorno de ajuste de inventário
	@type  Static Function
	@author Eduardo Fernandes
	@since 21/08/2006
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PCP006Proc() 

	Local dData2:=GETMV("MV_ULMES")
	Local dData1:=GETNEWPAR("MV_DBLQMOV",dData2)
	Local dDataFec:=IIF(dData1>dData2,dData1,dData2)
	Local aSaldo		:= Array(7)  
	Local cNumInv,cLog,cCod,cLocal,nTotEnd,nTotSB2,cLocaliz,nQtd,cOp,cLotCtl,cLote,cNumLot,cTm,i
	Local nCount 		:= 0
	Local cQuerSD3      
	Local aMata			:= {} //Array para execucao do ExecAuto   
	Local aErro 		:= {} 
	Local aErroSaldo    := {}
	Local nAchou        := 0
	Local nI            := 0
	Local dDataSC2           
	Local dDataAte 
	Local nDif          := 0 
	Local cNumOld       := Space(06) 
	Local aSaldoSBF     := {}
	Local lSB9 := .F. 

	Private lMSErroAuto    := .F.  

	// Verifica se a data do inventario e menor que do ultimo fechamento ou MV_DBLQMOV
	If dDataFec >= MV_PAR05
		Aviso("Aviso","Data do ultimo fechamento/parametro MV_DBLQMOV deve ser menor que a data final do inventario",{"OK"})
		Return Nil
	Endif

	cQuerSD3  := " SELECT D3_NUMINV, D3_TM, D3_COD, D3_UM, D3_QUANT, D3_OP, D3_LOCAL, D3_LOCALIZ, "
	cQuerSD3  += " D3_CC, D3_EMISSAO, D3_LOTECTL, D3_NUMSERI, D3_NUMLOTE, D3_FLAGINV, D3_DTVALID, "
	cQuerSD3  += " D3_DOC, D3_NUMSEQ "
	cQuerSD3  += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) " 
	cQuerSD3  += " WHERE D3_COD >= '" + MV_PAR01 + "' AND D3_COD <= '" + MV_PAR02 + "' AND "
	cQuerSD3  += " D3_EMISSAO LIKE '" + Left(DtoS(MV_PAR05),6) + "%' AND "
	cQuerSD3  += " D3_NUMINV >= '" + MV_PAR03 + "' AND D3_NUMINV <= '" + MV_PAR04 + "' AND " 
	cQuerSD3  += " D3_NUMINV <> '' AND D3_ESTORNO <> 'S' AND D3_FLAGINV = '2' AND D_E_L_E_T_ <> '*'"
	cQuerSD3  += " ORDER BY D3_NUMINV, D3_NUMSEQ "

	If Select("TMPSD3") > 0
		TMPSD3->(dbCloseArea())
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerSD3),"TMPSD3",.F.,.T.)
	TMPSD3->( dbEval( { || nCount++ },, { || !EOF() } ) )

	TCSetField("TMPSD3","D3_QUANT","N",16,3)
	TCSetField("TMPSD3","D3_EMISSAO","D",8,0)
	TCSetField("TMPSD3","D3_DTVALID","D",8,0)

	ProcRegua(nCount)	

	If nCount == 0
		Aviso("Aviso","Nao existem registros a serem analisados",{"OK"})
		Return Nil
	Endif

	TMPSD3->(DbGoTop())
	While TMPSD3->(!Eof())
			
		cNumInv   := TMPSD3->D3_NUMINV
		
		cTm       := If(TMPSD3->D3_TM == "499","999","499")
		
		// @history ticket 76071  - Fernando Macieira - 07/07/2022 - MATA240 - TM (* 499 para 497) (* 999 para 997)
		If AllTrim(cTM) == "499"
			cTM := "497"
		ElseIf AllTrim(cTM) == "999"
			cTM := "997"
		EndIf
		//

		cCod      := TMPSD3->D3_COD
		cLocal    := TMPSD3->D3_LOCAL
		cLocaliz  := TMPSD3->D3_LOCALIZ 
		cLotCtl   := TMPSD3->D3_LOTECTL
		cNumLot   := TMPSD3->D3_NUMLOTE
		cNumSer   := TMPSD3->D3_NUMSERI
		dDataAte  := Posicione("ZAM",4,xFilial("ZAM")+cNumInv,"ZAM_DTATE")
		nDif      := Posicione("ZAM",4,xFilial("ZAM")+cNumInv,"ZAM_DIF")
		nTotEnd   := 0
		nTotSB2   := 0  
		cLog      := ""  
		aSaldoSBF := {} // William Costa Chamado 041657 || CONTROLADORIA || DANIELLE_MEIRA || SALDO ESTOQUE 16/05/2018

		If cNumOld <> cNumInv

			aSaldo  := CalcEst(cCod,cLocal,dDataAte+1)
			
			nTotSB2 := aSaldo[1]
			
			// Chamado n. 056607 || OS 058077 || CONTROLADORIA || FRED_SANTOS || 8947 || SALDO ESTOQUE - FWNM - 16/03/2020
			If nTotSB2 < nDif 
				lSB9 := .T.
				nTotSB2 := UpSB9(cCod, cLocal, dDataAte)
			EndIf

			// verifica se o saldo no SB2 esta bloqueado
			If Posicione("SB2",1,xFilial("SB2")+cCod+cLocal,"B2_STATUS") == "2" 

				If U_PesqHist(aErro,cNumInv)
					Aadd(aErro,{cNumInv,2,.F.})
					Aviso("Avisso","O Saldo esta bloqueado para o produto: "+cCod,{"OK"})
				Endif	
				
				// verifica se existe o numero inventario no vetor de erros
				If Ascan(aErroSaldo, cNumInv) == 0
					AAdd(aErroSaldo, cNumInv)
				Endif

				cNumOld := cNumInv

				TMPSD3->(DbSkip())	
				Loop

			Endif    
	
		Endif	
		
		nAchou := 0
		nAchou := Ascan(aErroSaldo, cNumInv)
				
		If nAchou == 0
		
			// Inicio do movimentos de estorno
			While TMPSD3->(!Eof()) .And. cNumInv == TMPSD3->D3_NUMINV
	
				cOp		  := TMPSD3->D3_OP
				cDoc      := TMPSD3->D3_DOC
				nQtd      := TMPSD3->D3_QUANT
						
				Begin Transaction // @history ticket   64740 - Fernando Macieira - 30/11/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria

					SC2->(DbSetOrder(1))
					If SC2->(DbSeek(xFilial("SC2")+cOp))
						dDataSC2 := SC2->C2_DATRF
						Reclock("SC2",.F.)
							SC2->C2_DATRF := Ctod("  /  /  ")
						SC2->( MsUnlock() )
					Endif  
									
					aMata	:= {} 	
					Aadd(aMata,{"D3_NUMSEQ ",TMPSD3->D3_NUMSEQ      ,nil})
					Aadd(aMata,{"INDEX"     ,4	      			     ,nil})				   				   										
					
					lMSErroAuto := .F.
					
					MsExecAuto({|x,y|Mata240(x,y)},aMata,5) //ExecAuto de Estorno
		
					If lMSErroAuto

						If U_PesqHist(aErro,cNumInv)
							Aadd(aErro,{cNumInv,5,.F.})
						Endif						

						If IsBlind()
							Conout("Erro na gravacao da movimentacao")
						Endif	

						DisarmTransaction()
						
					Else

						EvalTrigger()
						SC2->(DbSetOrder(1))
						If SC2->(DbSeek(xFilial("SC2")+cOp))
							Reclock("SC2",.F.)
								SC2->C2_DATRF := dDataSC2
							SC2->( MsUnlock() )
						Endif 			
													
						// Limpa o Flag da Op Original
						DbSelectArea("SD3")
						DbSetOrder(1)
						DbSeek(xFilial("SD3")+cOp+cCod+cLocal)
						While !Eof() .And. (D3_FILIAL+D3_OP+D3_COD+D3_LOCAL==xFilial("SD3")+cOp+cCod+cLocal)
							RecLock("SD3",.F.)
								If SD3->D3_FLAGINV == "1"
									SD3->D3_FLAGINV := "" // limpa o flag da op origem	
								Endif	
							SD3->( MsUnLock() )
							SD3->(DbSkip())
						EndDo	  	
						
						//Carrega Vetor com Historicos
						If U_PesqHist(aErro,cNumInv)
							Aadd(aErro,{cNumInv,0,.F.})// Processamento OK
						Endif									

					Endif

				End Transaction 
		
				TMPSD3->(DbSkip())

			Enddo
		
			If !lMSErroAuto 
				U_TotalZAM(cNumInv,.T.)	 
				U_StatusZAM(cLog,cNumInv,.T.)	 
			Endif		
	
		Else
	
			TMPSD3->(DbSkip())	
	
		Endif

		cNumInv := TMPSD3->D3_NUMINV
	
	Enddo	

	TMPSD3->(DbCloseArea())
	
	//Gravacao do Historico do Estorno
	For nI:= 1 to Len(aErro)
		U_EPCP004(aErro[nI][1],aErro[nI][2],aErro[nI][3])	
	Next
		
	aErro :={}

	// Chamado n. 054451 || OS 055846 || CONTROLADORIA || || 8947 || ESTORNO SEM ENDERECO - FWNM - 29/01/2020
	aParamJob := {cMV_PAR01, cMV_PAR02, cMV_PAR05, cEmpAnt, cFilAnt}

	//gera log - @history ticket   18250 - Fernando Macieira - 23/08/2021 - Perda de Endereçamento - Protheus
	u_GrLogZBE( msDate(), TIME(), cUserName," ESTORNO INVENTARIO","CONTROLADORIA","EPCP006",;
	"ESTORNO INVENTARIO PARAMETROS: " + cMV_PAR01 + " " + cMV_PAR02 + " " + DtoC(cMV_PAR05) + " " + cEmpAnt + "/" + cFilAnt, ComputerName(), LogUserName() ) // @history ticket      TI - Fernando Macieira - 15/09/2021 - MV_PAR05 no logzbe sem tratativa de conversão data/caracter

	StartJob("u_ChkEnd", GetEnvServer(), .F., aParamJob)
	//

Return

/*/{Protheus.doc} Static Function ChkEnd
	(long_description)
	@type  Static Function
	@author FWNM
	@since 29/01/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 054451
/*/
User Function ChkEnd(aParamJob)

	Local cQuery  := ""
	Local aCab    := {}
	Local aItem   := {}
	Local cLocZAM := ""

	Local aCabSDA    := {}
	Local aItSDB     := {}
	Local _aItensSDB := {} 

	cMV_PAR01 := aParamJob[1]
	cMV_PAR02 := aParamJob[2]
	cMV_PAR05 := aParamJob[3]
	cEmpAnt   := aParamJob[4]
	cFilAnt   := aParamJob[5]

	rpcClearEnv()
	rpcSetType(3)
		
	If !rpcSetEnv(cEmpAnt, cFilAnt,,,,,{"SM0"})
		ConOut( "[EPCP006-01] - Não foi possível inicializar o ambiente, empresa/filial " + cEmpAnt + "/" + cFilAnt )

		//gera log - @history ticket   18250 - Fernando Macieira - 23/08/2021 - Perda de Endereçamento - Protheus
		u_GrLogZBE( msDate(), TIME(), cUserName," ESTORNO INVENTARIO","CONTROLADORIA","EPCP006",;
		"ESTORNO NÃO REALIZADO", ComputerName(), LogUserName() )

		Return
	EndIf

	U_ADINF009P('EPCP006' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	cLocZAM := GetMV("MV_#LOCZAM",,"PROD")

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DA_PRODUTO, DA_NUMSEQ, DA_DATA, DA_SALDO 
    cQuery += " FROM " + RetSqlName("SDA") + " SDA (NOLOCK)
    cQuery += " WHERE DA_FILIAL='"+FWxFilial("SDA")+"' 
    cQuery += " AND DA_PRODUTO BETWEEN '"+cMV_PAR01+"' AND '"+cMV_PAR02+"' 
    cQuery += " AND DA_DATA LIKE '"+Left(DtoS(cMV_PAR05),6)+"%'
    cQuery += " AND DA_SALDO>0 
    cQuery += " AND DA_ORIGEM='SD3' 
	cQuery += " AND DA_DOC='RATEIO' 
    cQuery += " AND D_E_L_E_T_=''
    cQuery += " ORDER BY DA_DATA, DA_PRODUTO

    tcQuery cQuery New Alias "Work"

    aTamSX3 := TamSX3("DA_SALDO")
    tcSetField("Work", "DA_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    aTamSX3 := TamSX3("DA_DATA")
    tcSetField("Work", "DA_DATA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    Work->( dbGoTop() )
    Do While Work->( !EOF() )

		//Cabeçalho com a informação do item e NumSeq que sera endereçado.
		aCabSDA := {{"DA_PRODUTO" , Work->DA_PRODUTO, Nil},;	  
					{"DA_NUMSEQ"  , Work->DA_NUMSEQ,  Nil}}

		//Dados do item que será endereçado
		aItSDB := {{"DB_ITEM"	  , "0001"	       , Nil},;                   
				   {"DB_ESTORNO"  , "S "	       , Nil},;                   
		    	   {"DB_LOCALIZ"  , cLocZAM        , Nil},;                   
				   {"DB_DATA"	  , Work->DA_DATA  , Nil},;                   
				   {"DB_QUANT"    , Work->DA_SALDO , Nil}}       

		aAdd(_aItensSDB, aitSDB)

		//Executa o endereçamento do item
		lMSErroAuto := .F.
		MATA265(aCabSDA, _aItensSDB, 3)

		If lMSErroAuto
			//DisarmTransaction() // @history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio 

			//gera log - @history ticket   18250 - Fernando Macieira - 23/08/2021 - Perda de Endereçamento - Protheus
			u_GrLogZBE( msDate(), TIME(), cUserName," ESTORNO INVENTARIO","CONTROLADORIA","EPCP006",;
			"ESTORNO NAO REALIZADO EXECAUTO NAO REALIZADO - MATA265", ComputerName(), LogUserName() )

			MostraErro()
		Else
			ConOut( "[EPCP006-02] - Endereçamento " + Work->DA_NUMSEQ + " OK em " + DtoC(msDate()) + " " + time() )
		Endif
				
		aCab  := {}
		aItem := {}
		aCabSDA    := {}
		aItSDB     := {}
		_aItensSDB := {} 

	    Work->( dbSkip() )

	EndDo

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf
	
Return

/*/{Protheus.doc} Static Function UpSB9(cCod, cLocal, dDataAte)
	(long_description)
	@type  Static Function
	@author FWNM
	@since 16/03/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056607 || OS 058077 || CONTROLADORIA || FRED_SANTOS || 8947 || SALDO ESTOQUE
/*/
Static Function UpSB9(cCod, cLocal, dDataAte)

	Local nQtdB9 := 0
	Local cQuery := ""

	If Select("WorkB9") > 0
		WorkB9->( dbCloseArea() )
	EndIf

	cQuery := " SELECT B9_QINI
	cQuery += " FROM " + RetSqlName("SB9") + " (NOLOCK)
	cQuery += " WHERE B9_FILIAL='"+FWxFilial("SB9")+"' 
	cQuery += " AND B9_COD='"+cCod+"' 
	cQuery += " AND B9_LOCAL='"+cLocal+"'
	//cQuery += " AND B9_DATA>='"+DtoS(dDataAte)+"'
	cQuery += " AND D_E_L_E_T_=''
	cQuery += " ORDER BY B9_DATA DESC

	tcQuery cQuery New Alias "WorkB9"

	WorkB9->( dbGoTop() )

	If WorkB9->( !EOF() )
		nQtdB9 := WorkB9->B9_QINI
	EndIf

	If Select("WorkB9") > 0
		WorkB9->( dbCloseArea() )
	EndIf

Return nQtdB9

/*/{Protheus.doc} Static Function 
	(long_description)
	@type  Static Function
	@author user
	@since 30/11/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket   64740 - Fernando Macieira - 30/11/2021 - Otimização do tempo na rotina de estorno, decisão conjunta gestores TI e Controladoria	
/*/
Static Function newPCP006(cProdDe, cProdAte, cInventDe, cInventAte, cArmazDe, cArmazAte)

	Local cSql     := ""
	Local cQuery   := ""
	Local lJob     := .t.
	Local cPergBkp := cPerg
	Local cPerg300 := "MTA300"

	Local dData2:=GETMV("MV_ULMES")
	Local dData1:=GETNEWPAR("MV_DBLQMOV",dData2)
	Local dDataFec:=IIF(dData1>dData2,dData1,dData2)

	// Verifica se a data do inventario e menor que do ultimo fechamento ou MV_DBLQMOV
	If dDataFec >= MV_PAR05
		Aviso("Aviso","Data do ultimo fechamento/parametro MV_DBLQMOV deve ser menor que a data final do inventario",{"OK"})
		Return
	Endif

	Begin Transaction
	
		// DELETO PRODUTOS A ENDEREÇAR/ENDEREÇADOS (SDA)
		cSql := " DELETE " + RetSqlName("SDA")
		cSql += " WHERE DA_FILIAL='"+FWxFilial("SDA")+"' 
		cSql += " AND DA_DATA LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
		cSql += " AND DA_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
		cSql += " AND DA_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
		cSql += " AND DA_DOC='RATEIO'

		If tcSqlExec(cSql) < 0

			If Select("Work") > 0
				Work->( dbCloseArea() )
			endIf
			
			cQuery := " SELECT R_E_C_N_O_ RECNO, DA_FILIAL, DA_PRODUTO, DA_DOC, DA_NUMSEQ
			cQuery += " FROM " + RetSqlName("SDA") + " (NOLOCK)
			cQuery += " WHERE DA_FILIAL='"+FWxFilial("SDA")+"' 
			cQuery += " AND DA_DATA LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
			cQuery += " AND DA_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
			cQuery += " AND DA_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
			cQuery += " AND DA_DOC='RATEIO'
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery New Alias "Work"

			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				SDA->( dbGoTo(Work->RECNO) )

				If SDA->DA_FILIAL == Work->DA_FILIAL .and. SDA->DA_PRODUTO == Work->DA_PRODUTO .and. SDA->DA_DOC == Work->DA_DOC .and. SDA->DA_NUMSEQ == Work->DA_NUMSEQ
					RecLock("SDA", .F.)
						SDA->( dbDelete() )
					SDA->( msUnLock() )
				EndIf

				Work->( dbSkip() )

			EndDo
		
		EndIf

		// DELETO PRODUTOS A ENDEREÇAR/ENDEREÇADOS (SDB)
		cSql := " DELETE " + RetSqlName("SDB")
		cSql += " WHERE DB_FILIAL='"+FWxFilial("SDB")+"' 
		cSql += " AND DB_DATA LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
		cSql += " AND DB_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
		cSql += " AND DB_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
		cSql += " AND DB_DOC='RATEIO'

		If tcSqlExec(cSql) < 0

			If Select("Work") > 0
				Work->( dbCloseArea() )
			endIf
			
			cQuery := " SELECT R_E_C_N_O_ RECNO, DB_FILIAL, DB_PRODUTO, DB_DOC, DB_NUMSEQ
			cQuery += " FROM " + RetSqlName("SDB") + " (NOLOCK)
			cQuery += " WHERE DB_FILIAL='"+FWxFilial("SDA")+"' 
			cQuery += " AND DB_DATA LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
			cQuery += " AND DB_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
			cQuery += " AND DB_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
			cQuery += " AND DB_DOC='RATEIO'
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery New Alias "Work"

			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				SDB->( dbGoTo(Work->RECNO) )

				If SDB->DB_FILIAL == Work->DB_FILIAL .and. SDB->DB_PRODUTO == Work->DB_PRODUTO .and. SDB->DB_DOC == Work->DB_DOC .and. SDB->DB_NUMSEQ == Work->DB_NUMSEQ
					RecLock("SDB", .F.)
						SDB->( dbDelete() )
					SDB->( msUnLock() )
				EndIf

				Work->( dbSkip() )

			EndDo
		
		EndIf

		// Deleto movimentos MATA240 gerados pelo rateio
		cSql := " DELETE " + RetSqlName("SD3")
		cSql += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
		cSql += " AND D3_EMISSAO LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
		cSql += " AND D3_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
		cSql += " AND D3_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
		cSql += " AND D3_DOC='RATEIO'

		If tcSqlExec(cSql) < 0

			If Select("Work") > 0
				Work->( dbCloseArea() )
			endIf
			
			cQuery := " SELECT R_E_C_N_O_ RECNO, D3_FILIAL, D3_COD, D3_DOC, D3_TM, D3_NUMSEQ
			cQuery += " FROM " + RetSqlName("SD3") + " (NOLOCK)
			cQuery += " WHERE D3_FILIAL='"+FWxFilial("SD3")+"' 
			cQuery += " AND D3_EMISSAO LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
			cQuery += " AND D3_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
			cQuery += " AND D3_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
			cQuery += " AND D3_DOC='RATEIO'
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery New Alias "Work"

			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				SD3->( dbGoTo(Work->RECNO) )
				If SD3->D3_FILIAL == Work->D3_FILIAL .and. SD3->D3_COD == Work->D3_COD .and. SD3->D3_DOC == Work->D3_DOC .and. SD3->D3_TM == Work->D3_TM .and. SD3->D3_NUMSEQ == Work->D3_NUMSEQ .and. SD3->(Recno()) == Work->RECNO
					RecLock("SD3", .F.)
						SD3->( dbDelete() )
					SD3->( msUnLock() )
				EndIf

				Work->( dbSkip() )

			EndDo

		EndIf

		// Atualizo status do inventário = 3 = ESTORNADO
		cSql := " UPDATE " + RetSqlName("ZAM")
		cSql += " SET ZAM_STATUS='3' 
		cSql += " WHERE ZAM_FILIAL='"+FWxFilial("ZAM")+"' 
		cSql += " AND ZAM_NUM BETWEEN '"+cInventDe+"' AND '"+cInventAte+"' 
		cSql += " AND ZAM_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
		cSql += " AND ZAM_DTATE LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
		cSql += " AND ZAM_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
		cSql += " AND D_E_L_E_T_=''

		If tcSqlExec(cSql) < 0

			If Select("Work") > 0
				Work->( dbCloseArea() )
			endIf
			
			cQuery := " SELECT R_E_C_N_O_ RECNO, ZAM_FILIAL, ZAM_COD, ZAM_NUM
			cQuery += " FROM " + RetSqlName("ZAM") + " (NOLOCK)
			cQuery += " WHERE ZAM_FILIAL='"+FWxFilial("ZAM")+"' 
			cQuery += " AND ZAM_NUM BETWEEN '"+cInventDe+"' AND '"+cInventAte+"' 
			cQuery += " AND ZAM_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' 
			cQuery += " AND ZAM_DTATE LIKE '" + Left(DtoS(MV_PAR05),6) + "%'
			cQuery += " AND ZAM_LOCAL BETWEEN '"+cArmazDe+"' AND '"+cArmazAte+"' 
			cQuery += " AND D_E_L_E_T_=''

			tcQuery cQuery New Alias "Work"

			Work->( dbGoTop() )
			Do While Work->( !EOF() )

				ZAM->( dbGoTo(Work->RECNO) )
				If ZAM->ZAM_FILIAL == Work->ZAM_FILIAL .and. ZAM->ZAM_COD == Work->ZAM_COD .and. ZAM->ZAM_NUM == Work->ZAM_NUM .and. ZAM->(Recno()) == Work->RECNO
					RecLock("ZAM", .F.)
						ZAM->ZAM_STATUS := "3" // Estornado
					ZAM->( msUnLock() )
				EndIf

				Work->( dbSkip() )

			EndDo

		EndIf

	End Transaction

	// Rodo o saldo atual
	lJob  := .t.
	cPerg300 := "MTA300"

	Pergunte(cPerg300, .F.)
		MV_PAR01 := ""
		MV_PAR02 := "zz"
		MV_PAR03 := cProdDe
		MV_PAR04 := cProdAte
	Pergunte(cPerg300, .F.)

	lMsErroAuto := .F.
	MSExecAuto({|x| MATA300(x)}, lJob)

	cPerg := cPergBkp

	msgInfo("Estorno realizado com sucesso! O saldo atual dos produtos selecionados também já foram processados! Verifique...")
	
Return
