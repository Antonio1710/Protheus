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
/*/
User Function EPCP006()

	Local nOpca  		:= 0
	Local oDlg          := NIL
	
	Private cPerg := "PCP006"
	Private cMV_PAR01, cMV_PAR02, cMV_PAR05

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

	If nOpcA == 1	
		Processa({||PCP006PROC()},,"Analisando os Movimentos Originais...")
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
	Local cAreaSD3
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
	Local lSBK := .F.

	Private lMSErroAuto    := .F.  

	Pergunte(cPerg, .f.) // Chamado n. 058838 || OS 060356 || CONTROLADORIA || FRED_SANTOS || 1196426706 || ROTINA INVENTARIO - FWNM - 10/06/2020

	cMV_PAR01 := MV_PAR01
	cMV_PAR02 := MV_PAR02
	cMV_PAR05 := MV_PAR05

	// Verifica se a data do inventario e menor que do ultimo fechamento ou MV_DBLQMOV
	If dDataFec >= MV_PAR05
		Aviso("Aviso","Data do ultimo fechamento/parametro MV_DBLQMOV deve ser menor que a data final do inventario",{"OK"})
		Return Nil
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totaliza registros de digitacao de inventario                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cQuerSD3  := " SELECT D3_NUMINV, D3_TM, D3_COD, D3_UM, D3_QUANT, D3_OP, D3_LOCAL, D3_LOCALIZ, "
	cQuerSD3  += " D3_CC, D3_EMISSAO, D3_LOTECTL, D3_NUMSERI, D3_NUMLOTE, D3_FLAGINV, D3_DTVALID, "
	cQuerSD3  += " D3_DOC, D3_NUMSEQ "
	cQuerSD3  += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) " 
	cQuerSD3  += " WHERE D3_COD >= '" + MV_PAR01 + "' AND D3_COD <= '" + MV_PAR02 + "' AND "
	cQuerSD3  += " D3_EMISSAO LIKE '" + Left(DtoS(MV_PAR05),6) + "%' AND "
	cQuerSD3  += " D3_NUMINV >= '" + MV_PAR03 + "' AND D3_NUMINV <= '" + MV_PAR04 + "' AND " 
	cQuerSD3  += " D3_NUMINV <> '' AND D3_ESTORNO <> 'S' AND D3_FLAGINV = '2' AND D_E_L_E_T_ <> '*'"
	cQuerSD3  += " ORDER BY D3_NUMINV, D3_NUMSEQ "
	//cQuerSD3  := ChangeQuery(cQuerSD3) // @history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio 

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
			
			// Chamado n. 058838 || OS 060356 || CONTROLADORIA || FRED_SANTOS || 1196426706 || ROTINA INVENTARIO - FWNM - 10/06/2020
			nTotSB2 := aSaldo[1]
			//
			
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
		
			//Begin Transaction // @history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio 
		
				// Inicio do movimentos de estorno
				While TMPSD3->(!Eof()) .And. cNumInv == TMPSD3->D3_NUMINV
		
					cOp		  := TMPSD3->D3_OP		
					cDoc      := TMPSD3->D3_DOC
					nQtd      := TMPSD3->D3_QUANT
							
					IncProc("Estornando movimentacao do produto: "+cCod)				

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Alteracao realizada conforme orientacao da Inteligencia Protheus - 		³
					//³ Chamado AAXISZ - Limpar o campo C2_DATRF e depois restaura-lo (19/10/06)³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
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
		
					If lMSErroAuto  // Se der erro 		   		
	
						If U_PesqHist(aErro,cNumInv)
							Aadd(aErro,{cNumInv,5,.F.})
						Endif						
	
						If IsBlind()
							Conout("Erro na gravacao da movimentacao")
						Endif	
	
						//DisarmTransaction() // @history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio 
						
					Else // naum deu erro 
	
						EvalTrigger()
						//Commit // @history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio 
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Alteracao realizada conforme orientacao da Inteligencia Protheus - 		³
						//³ Chamado AAXISZ - Restaurar o campo C2_DATRF (19/10/06)					³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
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
			
					TMPSD3->(DbSkip())

				Enddo
		
			//End Transaction // @history ticket      TI - Fernando Macieira - 19/08/2021 - Lentidão e bloqueio 

			If !lMSErroAuto 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Zera Totais do Inventario processado                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ														
				U_TotalZAM(cNumInv,.T.)	 
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza status de processamento                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
