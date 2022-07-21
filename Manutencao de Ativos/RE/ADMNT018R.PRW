
#INCLUDE "PROTHEUS.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "ADMNT018R.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "Topconn.ch"
#DEFINE CRLF CHR(13)+CHR(10) 
//---------------------------------------------------------------------
/*/{Protheus.doc} ADMNT018R 
Relatorio horas Disponivel X Realizadas - baseado na Consulta MNTC905
@author Antonio Domingos
@since 18/05/2022
@version undefined
@type User Function. 
@Ticket 63356, Data 21/07/2022, Antonio Domingos, SIGAMNT - E-mail - Homem Hora. Solicitado por DEBORA ROSILAI DA SILVA.
/*/
//---------------------------------------------------------------------
User Function ADMNT018R(cParam)

Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT018R"
Local aInfoCustom 	:= {}
Local cTxtIntro	    := "Rotina responsável pela extracao EXCEL do Relatorio Horas Disponiveis x Realizadas"
local lSetEnv       := .f.

Private cPara      := SuperGetMv('ZZ_MNT018B', .f. ,"pcm@adoro.com.br") 
Private cAssunto   := "Relatorio de Horas Disponiveis x Realizadas"
Private cCorpo     := "Relatorio de Horas Disponiveis x Realizadas"
Private aAnexos    := {}
Private lMostraLog := .F.
Private lUsaTLS    := .T.
Private cHtml		:= ""
//Local cEmp 		:= "01"
//Local cFil 		:= "02"

		//RPCClearEnv()
		//RPCSetType(3)
		//RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })		

Private lJob          := IsBlind()
Private oProcess
Private dPeriodoDe  //Do Periodo
Private dPeriodoAte //Ate Periodo
Private cCCustoDe   //Do Centro de Custo
Private cCCustoAte  //Até Centro de Custo
Private cEspeciDe   //Da especialidade
Private cEspeciAte  //Ate Especialidade
Private cFuncioDe   //Do Funcionario 
Private cFuncioAte  //Ate Funcionario
Private nTipoRel    //Tipo 1=Por Centro Cust, 2=Por Especialid., 3=Por Funcionario
Private nTipoOrd    //Tipo de Ordens 1=Corretiva, 2=Preventiva, 3=Outros, 4=Todas
Private czEMP	:= cEmpAnt
Private czFIL   := cFilAnt
Private cNivel  := SuperGetMv('ZZ_MNT018A', .f. ,"4" ) //1=Imprimir Nivel1,2=Imprimir Nivel2,3=Imprimir Nivel3,4= Imprimir Todos os Niveis
Private _cNomeEmpFil := ALLTRIM(SM0->M0_NOME)+'-'+ALLTRIM(SM0->M0_FILIAL)
//Aadd(aInfoCustom,{"Visualizar",{|oCenterPanel| visualiza(oCenterPanel)},"WATCH" })
//Aadd(aInfoCustom,{"Relatorio" ,{|oCenterPanel| Relat(oCenterPanel) },"RELATORIO"})

If lJob
	RpcSetType(3)
	lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
    czEMP    := aParam[1]   
    czFIL    := aParam[2]   
    
    PREPARE ENVIRONMENT EMPRESA czEMP FILIAL czFIL MODULO "EST"
    cPara      :=  SuperGetMv('ZZ_MNT018B', .f. ,"pcm@adoro.com.br" ) 
    
    oProcess := Executa()
Else
    oProcess := tNewProcess():New("ADMNT018R","Relação HDR",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Relação HDR", .T. )
Endif

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Custo por OS ')

Return

Return

Static Function Executa(oProcess)

	//------------------------------------------------
	// Armazena variaveis p/ devolucao (NGRIGHTCLICK)
	//------------------------------------------------
	Local aNGBEGINPRM	:= NGBEGINPRM()
	Local oFont			:= TFont():New( "Arial",8,14,,.T.,,.F.,,.F.,.F. )
	Local aSize			:= MsAdvSize(,.F.,430)
	Local nLargura		:= aSize[5]
	Local nAltura		:= aSize[6]
	Local nPercent		:= 	0

	//Tabelas Temporárias
	Local oTmpTbl1 //Objeto Tabela Temporária 1 || Alias (cTRB)
	Local oTmpTbl2 //Objeto Tabela Temporária 2 || Alias (cTRB9051)
	Local oTmpTbl3 //Objeto Tabela Temporária 3 || Alias (cTRB9052)

	Private aTRB9051	:= {}
	Private aHrsBloq	:= {} //Array que armazena a quantidade de horas que um funcionário encontra-se bloqueado;
	Private vVETHORAS	:= {}
	Private cCadastro	:= OemToAnsi(STR0001) //"Horas Trabalhadas Na Manutencao"
	Private lRETOR		:= .F.
	Private lExistInf	:= .T.
	Private aHrsCal		:= {} //Array que monta uma matriz com os dados do calendario.

	// Totais Utilizados na tela principal
	Private nTotDISP	:= 0 // Total Disponivel
	Private nHrsFuBlo	:= 0 // Horas de bloqueio por funcionário.
	Private nHrsDisp	:= 0 // Horas disponíveis.
	Private nTotal		:= 0 // Total de Horas.
	Private cHrsExtras	:= 0 // Horas extras.

	//Variáveis utilzadas para armazenar os totais da 'TRB'.
	Private nTotalCal := 0
	Private nTotalBlo := 0
	Private nTotalDis := 0
	Private nTotalRel := 0
	Private nTotalDif := 0
	Private nTotalPer := 0
	Private nTotalExt := 0
	Private nHorasBlq := 0
	Private nTotHrBlo := 0

	//Alias Tabela Temporária
	Private cTRB		:= GetNextAlias()
	Private cTRBV		:= GetNextAlias()
	Private cTRB9051	:= GetNextAlias()
	Private cTRB9052	:= GetNextAlias()

	// Totais Utilizados nos relatorios
	Private nToHrCale := 0 // Total Disponíveis - (Calendário)
	Private nToHrBloq := 0 // Total Bloqueadas
	Private nToHrDisp := 0 // Total Disponíveis
	Private nToHrReal := 0 // Total Realizadas
	Private nToHrDiff := 0 // Total Diferença
	Private nToHrPerc := 0 // Total Percentual
	Private nTHrExtra := 0 // Total Extras

	Private cRelCab  := "" // Descritivo da faixa de datas
	Private cRelDet1 := "" // Descritivo do filtro da tela principal
	Private cRelDet2 := "" // Descritivo do filtro da tela de detalhamento por funcionario
	Private cRelDet3 := "" // Descritivo do filtro da tela de detalhamento por funcionario/data
				//cRelCab  := STR0047 + " " + DToC(dPeriodoDe) + "  -  " + STR0048 + " " + DToC(dPeriodoAte) + ""
    Private cDataInicio := CToD("")
	Private cDataFinal  := CToD("")
	Private oExcel  	:= FwMsExcel():New()
		
	Private cNomArq
	Private cDIRARQ
	Private cDIRREDE
	
	SET CENTURY ON
	
	Private dPeriodoDe  := FirstDay(DATE()) 						//Do Periodo
	Private dPeriodoAte := DATE()-1  								//Ate Periodo
	Private cCCustoDe   := "5304" 									//Do Centro de Custo
	Private cCCustoAte  := "5304"									//Até Centro de Custo
	Private cEspeciDe   := Space(TAMSX3("T2_ESPECIA")[1]) 			//Da especialidade
	Private cEspeciAte  := REPLICATE("Z",TAMSX3("T2_ESPECIA")[1]) 	//Ate Especialidade
	Private cFuncioDe   := Space(TAMSX3("T1_CODFUNC")[1]) 			//Do Funcionario 
	Private cFuncioAte  := REPLICATE("Z",TAMSX3("T1_CODFUNC")[1]) 	//Ate Funcionario
	Private nTipoRel    := 3 										//Tipo 1=Por Centro Cust, 2=Por Especialid., 3=Por Funcionario
	Private nTipoOrd    := 4 										//Tipo de Ordens 1=Corretiva, 2=Preventiva, 3=Outros, 4=Todas
	Private aParamBox   := {}
    Private aRet        := {}

    If lJob
		dPeriodoDe  := FirstDay(DATE()) 						//Do Periodo
		dPeriodoAte := DATE()-1  								//Ate Periodo
		cCCustoDe   := "5304" 									//Do Centro de Custo
		cCCustoAte  := "5304"									//Até Centro de Custo
		cEspeciDe   := Space(TAMSX3("T2_ESPECIA")[1]) 			//Da especialidade
		cEspeciAte  := REPLICATE("Z",TAMSX3("T2_ESPECIA")[1]) 	//Ate Especialidade
		cFuncioDe   := Space(TAMSX3("T1_CODFUNC")[1]) 			//Do Funcionario 
		cFuncioAte  := REPLICATE("Z",TAMSX3("T1_CODFUNC")[1]) 	//Ate Funcionario
		nTipoRel    := 3 										//Tipo 1=Por Centro Cust, 2=Por Especialid., 3=Por Funcionario
		nTipoOrd    := 4 										//Tipo de Ordens 1=Corretiva, 2=Preventiva, 3=Outros, 4=Todas
		aParamBox   := {}
		aRet        := {}
	else
 		dPeriodoDe  := mv_par01 	//Do Periodo
		dPeriodoAte := mv_par02  	//Ate Periodo
		cCCustoDe   := mv_par03 	//Do Centro de Custo
		cCCustoAte  := mv_par04		//Até Centro de Custo
		cEspeciDe   := mv_par05 	//Da especialidade
		cEspeciAte  := mv_par06 	//Ate Especialidade
		cFuncioDe   := mv_par07 	//Do Funcionario 
		cFuncioAte  := mv_par08 	//Ate Funcionario
		nTipoRel    := mv_par09 	//Tipo 1=Por Centro Cust, 2=Por Especialid., 3=Por Funcionario
		nTipoOrd    := mv_par10 	//Tipo de Ordens 1=Corretiva, 2=Preventiva, 3=Outros, 4=Todas
	EndIf	

	aDBF := {{"TIPO"  , "C", Len(STJ->TJ_CCUSTO),0},;
			 {"NOME"  , "C", 15,0},;
			 {"DIFERE", "C", 10,0},;
			 {"DISPON", "C", 10,0},;
			 {"CALEND", "C", 10,0},;
			 {"REALIZ", "C", 10,0},;
			 {"BLOQUE", "C", 10,0},;
			 {"PERCEN", "N", 12,2},;
			 {"EXTRA" , "N", 10,2}}

	//Instancia classe FWTemporaryTable
	oTmpTbl1 := FWTemporaryTable():New( cTRB, aDBF )
	//Cria indices
	oTmpTbl1:AddIndex( "Ind01" , {"TIPO"} )
	//Cria a tabela temporaria
	oTmpTbl1:Create()

	//-------------------------
	// Alteracao 04/07/2014
	// Elynton Fellipe Bazzo
	//--------------------------
	// Geracao de arquivo temporario com as informacoes do detalhamento
	// por funcionario e data
	aDBFR9051 := {{"CODFUN", "C", Len(ST1->T1_CODFUNC),0},;
				  {"TIPO"  , "C", Len(stj->tj_ccusto),0},;
				  {"NOME"  , "C", 15  ,0},;
				  {"DATAF" , "D", 08  ,0},;
				  {"DISPO" , "N", 12  ,2},;
				  {"CALEND", "C", 10  ,0},;
				  {"REAL"  , "N", 12  ,2},;
				  {"DISPON", "C", 10  ,0},;
				  {"REALIZ", "C", 10  ,0},;
				  {"DIFERE", "C", 10  ,0},;
				  {"BLOQUE", "C", 10  ,0},;
				  {"PERCEN", "N", 12  ,2},;
				  {"EXTRA" , "C", 10  ,0}}

	//Instancia classe FWTemporaryTable
	oTmpTbl2 := FWTemporaryTable():New( cTRB9051, aDBFR9051 )
	//Cria indices
	oTmpTbl2:AddIndex( "Ind01" , {"TIPO","CODFUN","DATAF"} )
	//Cria a tabela temporaria
	oTmpTbl2:Create()

	//-------------------------
	// Alteracao 04/07/2014
	// Elynton Fellipe Bazzo
	//--------------------------
	// Geracao de arquivo temporario com as informacoes do
	// agrupamento por funcionario
	aDBFR9052 := {{"CODFUN", "C", Len(ST1->T1_CODFUNC),0},;
				  {"TIPO"  , "C", Len(stj->tj_ccusto),0},;
				  {"NOME"  , "C", 15  ,0},;
				  {"DATAF" , "D", 08  ,0},;
				  {"DISPO" , "N", 12  ,2},;
				  {"CALEND", "C", 10  ,0},;
				  {"REAL"  , "N", 12  ,2},;
				  {"DISPON", "C", 10  ,0},;
				  {"REALIZ", "C", 10  ,0},;
				  {"DIFERE", "C", 10  ,0},;
				  {"BLOQUE", "C", 10  ,0},;
				  {"PERCEN", "N", 12  ,2},;
				  {"EXTRA" , "C", 10  ,0}}

	//Instancia classe FWTemporaryTable
	oTmpTbl3 := FWTemporaryTable():New( cTRB9052, aDBFR9052 )
	//Cria indices
	oTmpTbl3:AddIndex( "Ind01" , {"TIPO","CODFUN"} )
	//Cria a tabela temporaria
	oTmpTbl3:Create()

	Processa({ || C905PROC() })
	
	If lRETOR .Or. lExistInf

		oTmpTbl2:Delete()//Deleta Tabela Temporária 2
		oTmpTbl3:Delete()//Deleta Tabela Temporária 3
		oTmpTbl1:Delete()//Deleta Tabela Temporária 1

		DbSelectArea("STL")
		Return
	EndIf

	DbSelectArea(cTRB)
	DbGoTop()

	If Reccount() = 0
		Help(" ",1,"NGTDADGRAF") //"Nao existem dados para montar o grafico."###"ATENCAO"

		oTmpTbl2:Delete()//Deleta Tabela Temporária 2
		oTmpTbl3:Delete()//Deleta Tabela Temporária 3
		oTmpTbl1:Delete()//Deleta Tabela Temporária 1

		DbSelectArea("STL")
		Return
	Endif

	cTIT := If(nTipoRel = 1,STR0016,If(nTipoRel = 2,STR0017,STR0018)) //"Centro Custo"###"Especialidade"###"Funcionario"

	//If nTipoRel == 1 .Or. nTipoRel == 2

		//Define MsDialog oDlg1 Title STR0019 From aSize[7],0 To nAltura,nLargura Of oMainWnd Pixel //"Horas Disponiveis X Horas Realizadas"

			//oDlg1:lMaximized := .T.
			//oPanelTop := TPanel():New(01,01,,oDlg1,,,,,,40,40,.F.,.F.)
			//oPanelTop:Align := CONTROL_ALIGN_TOP

			cRelDet1 := STR0046 + " " + If(nTipoRel = 1,STR0016,If(nTipoRel = 2,STR0017,STR0018))
			//cRelCab  := STR0047 + " " + DToC(dPeriodoDe) + "  -  " + STR0048 + " " + DToC(dPeriodoAte) + ""
            cDataInicio := DToC(dPeriodoDe)
			cDataFinal  := DToC(dPeriodoAte)

			DbselectArea(cTRB)
			DbSetOrder(1)
			
			nTotalPer := Round(( NGCONVERHORA( HTON( nTotalRel ),'D','S') * 100 ) / NGCONVERHORA( HTON( nTotalCal ),'D','S'),5 )

			aAreaTRB := GetArea()

			DbSelectArea(cTRB)
			DbGoTop()
			While !Eof()
				nPercent += Round(( NGCONVERHORA( HTON( nTotalRel ),'D','S') * 100 ) / NGCONVERHORA( HTON( nTotalCal ),'D','S'),5 )//Variável que acumula o percentual de horas.
				DbSelectArea(cTRB)
				DbSkip()
			End While
			nPercent := PADR(Transform( nPercent,"@!" ),6)

			RestArea( aAreaTRB )

			C905PRINT(cNivel,(cTRB),(cTRB)->CALEND,(cTRB)->BLOQUE,(cTRB)->DISPON,(cTRB)->REALIZ ,oprocess)

	SET CENTURY OFF

	oTmpTbl1:Delete()//Deleta Tabela Temporária 1
	oTmpTbl2:Delete()//Deleta Tabela Temporária 2
	oTmpTbl3:Delete()//Deleta Tabela Temporária 3

	//---------------------------------------------
	// Devolve variaveis armazenadas (NGRIGHTCLICK)
	//---------------------------------------------
	NGRETURNPRM(aNGBEGINPRM)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} C905PROC()
Processa OS e gera arquivo de trabalho
@Author: Paulo Pego
@Since:   06/09/99
/*/
//---------------------------------------------------------------------
Static Function C905PROC()

	Local nTAM       	:= Len(st1->t1_codfunc)
	Local cESP       	:= Space(Len(stl->tl_codigo)-nTAM)
	Local cNGMNTRH		:= AllTrim(GetMv("MV_NGMNTRH"))
	Local lESPECIA   	:= .F.
	Local lFuncDem   	:= .F.
	Local lFstSeek   	:= .F.
	Local lBloqueio  	:= .T.
	Local lMNTC9051	 	:= ExistBlock("MNTC9051")
	Local DtPar02    	:= dPeriodoAte
	Local nExcRh     	:= 0
	Local i          	:= 0
	Local nIndisp    	:= 0
	Local nHoraExtra 	:= 0
	Local nX         	:= 1
	Local aHrsBloq   	:= {}

	Private aARRCALE := {}, aDtExcRH := {}

	DbselectArea( "ST1" )
	Dbsetorder( 01 )
	Dbseek( xFilial( "ST1" )+cFuncioDe,.T. )
	ProcRegua(LastRec())
	While !Eof() .And. xfilial( "ST1" ) = ST1->T1_FILIAL .And. ST1->T1_CODFUNC <= cFuncioAte
		IncProc()

		If lMNTC9051
			If !ExecBlock("MNTC9051",.F.,.F.)
				dbSelectArea("ST1")
				dbSkip()
				Loop
			EndIf
		EndIf

		nDispo		:= 0.00
		nQuantExc	:= 0.00
		nExcRh		:= 0
		nIndisp		:= 0
		aDtExcRH	:= {}

		If ST1->T1_CCUSTO >= cCCustoDe .And. ST1->T1_CCUSTO <= cCCustoAte

			//Volta a Varial para considerar por funcionario
			DtPar02 := dPeriodoAte

			lESPECIA := .F.

			DbselectArea('ST2')
			Dbsetorder(01)
			DbSeek(xFilial("ST2")+ST1->T1_CODFUNC)
			While !Eof() .And. xfilial("ST2") = ST2->T2_FILIAL .And. ST2->T2_CODFUNC = ST1->T1_CODFUNC
				If ST2->T2_ESPECIA >= cEspeciDe .AND. ST2->T2_ESPECIA <= cEspeciAte
					lESPECIA := .T.
					Exit
				EndIf
				Dbskip()
			End While

			If lESPECIA
				If nTipoRel == 1
					cSeek := ST1->T1_CCUSTO
					cNOME := If(SI3->(DbSeek(xFilial("SI3") + cSEEK)), SI3->I3_DESC, Space(15) )
					If lFstSeek
						If cOldSeek <> cSeek
							nHorasBlq := 0
						EndIf
					EndIf
				ElseIf nTipoRel == 2
					cSeek := ST2->T2_ESPECIA+Space(Len(stj->tj_ccusto)-Len(st2->t2_especia))
					cNOME := If(ST0->(DbSeek(xFilial("ST0") + cSEEK)), ST0->T0_NOME, Space(15) )
					If lFstSeek
						If cOldSeek <> cSeek
							nHorasBlq := 0
						EndIf
					EndIf
				Else
					cSeek := ST1->T1_CODFUNC+Space(Len(stj->tj_ccusto)-Len(st1->t1_codfunc))
					cNOME := ST1->T1_NOME
				EndIf
				cOldSeek:= cSeek
				lFstSeek:= .T.
				lFuncDem:= .F.

				If cNGMNTRH $ "SX"
					DbselectArea("SRA")
					Dbsetorder(01)
					If Dbseek(xFilial("SRA")+st1->t1_codfunc)
						If !Empty(sra->ra_demissa)
							If sra->ra_demissa < dPeriodoDe
								DbselectArea('ST1')
								DbSkip()
								Loop
							Endif
							If sra->ra_demissa >= dPeriodoDe .And. sra->ra_demissa <= dPeriodoAte
								lFuncDem := .t.
								DtPar02  := sra->ra_demissa
							Endif
						Endif
					Else
						dbSelectArea("ST1")
						If FieldPos("T1_DTFIMDI")>0
							If ST1->T1_DISPONI == "N" .And. !Empty(ST1->T1_DTFIMDI)
								lFuncDem := .T.
								DtPar02  := ST1->T1_DTFIMDI
							EndIf
						EndIf
					Endif
				Else
					dbSelectArea("ST1")
					If FieldPos("T1_DTFIMDI")>0
						If ST1->T1_DISPONI == "N" .And. !Empty(ST1->T1_DTFIMDI)
							lFuncDem := .T.
							DtPar02  := dPeriodoAte
						EndIf
					EndIf
				EndIf

				//---------------------
				// Integracao com RH
				//---------------------
				If cNGMNTRH $ "SX"

					//Encontra calendario em array aARRCALE
					nPosC := Ascan(aARRCALE,{|x| x[1] = ST1->T1_TURNO})
					If nPosC = 0
						aDIAMAN := NG_H7(ST1->T1_TURNO)
						Aadd(aARRCALE,{ST1->T1_TURNO,aDIAMAN})
						nPosC := Len(aARRCALE)
					EndIf

					dDtAtu := dPeriodoDe
					If !Empty(aARRCALE[nPosC])
						While dDtAtu <= DtPar02
							nSem := If( DOW(dDTATU) == 1, 7, DOW(dDTATU)-1)
							If !NGFRHAFAST(ST1->T1_CODFUNC,dDtAtu,dDtAtu,/*msg tela*/.F.,/*so demitidos*/.F.)
								nIndisp += HtoM(aARRCALE[nPosC,2][nSem,3])  //soma horas de indisponibilidade
								aAdd(aDtExcRH,dDtAtu)  //adiciona data de excecao no RH
							Endif
							dDtAtu := dDtAtu + 1
						End While
					Else
						nIndisp := 0
					EndIf

				EndIf

				nExcRh		:= nIndisp
				nQTDHORAS	:= 0.00
				nHora		:= 0.00
				nHoraExtra	:= 0.00
				cExtra		:= 0.00

				If !Empty( ST1->T1_DTFIMDI ) .And. dPeriodoDe == dPeriodoAte .And. dPeriodoAte > ST1->T1_DTFIMDI
					MNTCALCULO( ST1->T1_DTFIMDI )
				Else
					If !lFuncDem
						MNTCALCULO( dPeriodoAte )
					Else
						MNTCALCULO( DtPar02 )
					EndIf
				EndIf

				DbselectArea('STL')
				DbSetOrder(8)
				DbSeek(xFilial("STL")+ "M"+ST1->T1_CODFUNC+cESP)
				While !Eof() .And. xfilial("STL") = STL->TL_FILIAL .And. STL->TL_TIPOREG = "M" .and.  Substr(STL->TL_CODIGO,1,nTAM) = ST1->T1_CODFUNC

					If STL->TL_DTINICI >= dPeriodoDe .and. STL->TL_DTINICI <= dPeriodoAte .And. Alltrim(STL->TL_SEQRELA) <> "0"

						DbselectArea( "STJ" )
						DbSetOrder(1)
						If DbSeek(xFilial("STJ")+STL->TL_ORDEM+STL->TL_PLANO)

							DbselectArea('ST4')
							DbSetOrder(1)
							If DbSeek(xFilial("ST4")+STJ->TJ_SERVICO)

								DbselectArea('STE')
								DbSetOrder(1)
								DbSeek(xFilial("STE")+ST4->T4_TIPOMAN)
								If (STE->TE_CARACTE == "C" .And. nTipoOrd = 1) .Or. (STE->TE_CARACTE == "P" .And. nTipoOrd = 2) .Or.;
								(STE->TE_CARACTE == "O" .And. nTipoOrd = 3) .Or. (nTipoOrd = 4)

									vVETHORAS	:= NGTQUATINS( STL->TL_CODIGO,STL->TL_TIPOREG,STL->TL_USACALE,STL->TL_QUANTID,STL->TL_TIPOHOR,;
									STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM,STL->TL_UNIDADE )

									nQTDHORAS	:= vVETHORAS[2]
									nHORA		:= SomaHoras( nQTDHORAS,nHORA )
									nHoraExtra	:= 0.00

									If NGCADICBASE('TL_PCTHREX','A','STL',.F.)
										If !Empty(STL->TL_PCTHREX)
											nHoraExtra := STL->TL_QUANTID
											cExtra += STL->TL_QUANTID
										Endif
									Else
										If !Empty(STL->TL_HREXTRA) .AND. STL->TL_HREXTRA != '000.00'
											nHoraExtra := STL->TL_QUANTID
											cExtra += STL->TL_QUANTID
										Endif
									EndIf

									///GRAVAR DETALHES REALIZADO
									GrvTRB9051( cSeek,ST1->T1_CODFUNC,ST1->T1_NOME,STL->TL_DTINICI,0,nQTDHORAS,aDtExcRH,nHoraExtra )
									lExistInf := .F.
								EndIf
							Endif
						EndIf
					Endif
					DbSelectArea( "STL" )
					DbSkip()
				End While

				nQTDHORAS := 0.00
				DbselectArea('STT')
				DbSetOrder(3)
				DbSeek(xFilial("STT")+"M"+ST1->T1_CODFUNC+cESP)
				While !Eof() .And. xfilial("STT") = STT->TT_FILIAL .and. STT->TT_TIPOREG = "M" .and.  Substr(STT->TT_CODIGO,1,nTAM) = ST1->T1_CODFUNC
					If STT->TT_DTINICI >= dPeriodoDe .and. STT->TT_DTINICI <= dPeriodoAte .and. Alltrim(STT->TT_SEQRELA) <> "0"
						DbselectArea('STS')
						DbSetOrder(1)

						If DbSeek(xFilial("STS")+STT->TT_ORDEM+STT->TT_PLANO)
							DbselectArea('ST4')
							DbSetOrder(1)

							If DbSeek(xFilial("ST4")+STS->TS_SERVICO)
								DbselectArea('STE')
								DbSetOrder(1)
								DbSeek(xFilial("STE")+ST4->T4_TIPOMAN)

								If (STE->TE_CARACTE == "C" .And. nTipoOrd = 1) .Or.;
								(STE->TE_CARACTE == "P" .And. nTipoOrd = 2) .Or.;
								(STE->TE_CARACTE == "O" .And. nTipoOrd = 3) .Or.;
								(nTipoOrd = 4)

									vVETHORAS := NGTQUATINS(STT->TT_CODIGO,STT->TT_TIPOREG,STT->TT_USACALE,;
									STT->TT_QUANTID,STT->TT_TIPOHOR,STT->TT_DTINICI,;
									STT->TT_HOINICI,STT->TT_DTFIM,STT->TT_HOFIM,STT->TT_UNIDADE)
									nQTDHORAS := vVETHORAS[2]
									nHORA := SomaHoras( nQTDHORAS,nHORA )

									If NGCADICBASE('TT_PCTHREX','A','STT',.F.)
										If !Empty(STT->TT_PCTHREX)
											nHoraExtra := STT->TT_QUANTID
											cExtra += STL->TL_QUANTID
										Endif
									Else
										If !Empty(STT->TT_HREXTRA) .AND. STT->TT_HREXTRA != '000.00'
											nHoraExtra := STT->TT_QUANTID
											cExtra += STL->TL_QUANTID
										Endif
									EndIf

									///GRAVAR DETALHES REALIZADO
									GrvTRB9051( cSeek,ST1->T1_CODFUNC,ST1->T1_NOME,STT->TT_DTINICI,0,nQTDHORAS,aDtExcRH,nHoraExtra )
									lExistInf := .F.
								EndIf
							Endif
						EndIf
					Endif
					DbSelectArea( "STT" )
					DbSkip()
				End While

				nDISPO := nDISPO - nQuantExc - nExcRh

				If !Empty(cSeek)
					If !(cTRB)->(DbSeek(cSeek))
						(cTRB)->(DbAppend())
						(cTRB)->TIPO := cSeek
						(cTRB)->NOME := cNOME
					Else
						RecLock( (cTRB),.F. )
					Endif

					//Horas Calendário atual do funcionário.
					If SomaHoras( (cTRB)->CALEND,( nDISPO / 60 )) == 0
						(cTRB)->CALEND := MTOH( 0 )
					Else
						(cTRB)->CALEND := NgTraNtoH( SomaHoras( (cTRB)->CALEND, NtoH( nDISPO / 60 )))
					EndIf

					(cTRB)->BLOQUE := If( nHorasBlq == 0, MTOH( 0 ), NgTraNtoH( nHorasBlq ))

					//Diferença entre as horas: Calendário/Bloqueadas.
					If SubHoras( (cTRB)->CALEND,(cTRB)->BLOQUE ) == 0
						(cTRB)->DISPON := MTOH( 0 )
					Else
						(cTRB)->DISPON := NgTraNtoH( SubHoras( (cTRB)->CALEND,(cTRB)->BLOQUE ))
					EndIf

					//Horas realizadas.
					If SomaHoras( (cTRB)->REALIZ, NgTraNtoH( nHora )) == 0
						(cTRB)->REALIZ := MTOH( 0 )
					Else
						(cTRB)->REALIZ := NgTraNtoH( SomaHoras( (cTRB)->REALIZ, NgTraNtoH( nHora )))
					EndIf

					//Diferença entre as horas: disponibilidade/realizadas.
					If SubHoras( (cTRB)->DISPON,(cTRB)->REALIZ ) == 0
						(cTRB)->DIFERE := MTOH( 0 )
					Else
						(cTRB)->DIFERE := NgTraNtoH( SubHoras( (cTRB)->DISPON,(cTRB)->REALIZ ))
					EndIf

					//Percentual de Horas.
					(cTRB)->PERCEN	:= Round(( NGCONVERHORA( HTON( (cTRB)->REALIZ ),'D','S') * 100 ) / NGCONVERHORA( HTON( (cTRB)->CALEND ),'D','S'),5 )

					//Horas extras.
					(cTRB)->EXTRA := (cTRB)->EXTRA+cExtra
					MsUnlock(cTRB)

					cHrsExtras	+= cExtra
				Endif
			Endif
		Endif
		DbselectArea('ST1')
		DbSkip()
	End

	nHorasBlq := 0
	GrvTRB9052() //Gravacao dos agrupamentos por funcionarios
	fLoadDados( aTRB9051, @aHrsBloq ) //Função que em threads realiza a gravação dos totais dos detalhes das horas dos funcionarios.
	GrvTRT9052( aHrsBloq ) //Gravacao dos totais do agrupamentos por funcionarios

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} G905DET1()
Gera o detalhamento por funcionários.
@Return: .T.
@Author: Ricardo Dal Ponte
@Since:  18/08/2006
Melhoria realizada:
@Author: Elynton Fellipe Bazzo
@Since:  20/06/2014
/*/
//---------------------------------------------------------------------

Static Function G905DET1( cTipo,cCodFun )

	Local oFont		:= TFont():New( "Arial",8,14,,.T.,,.F.,,.F.,.F. )
	Local aSize		:= MsAdvSize(,.F.,430)
	Local nLargura	:= aSize[5]
	Local nAltura	:= aSize[6]
	Local nPerce	:= 0

	DbselectArea(cTRB9051)
	SET FILTER TO (cTRB9051)->TIPO = cTipo .And. (cTRB9051)->CODFUN = cCodFun
	DbGotop()
	/*
	Define MsDialog oDlg1 Title STR0050 From aSize[7],0 To nAltura,nLargura Of oMainWnd Pixel //"Horas Disponiveis X Horas Realizadas (por Funcionario/Data)"

	oDlg1:lMaximized := .T.
	oPanelTop := TPanel():New(01,01,,oDlg1,,,,,,40,40,.F.,.F.)
	oPanelTop:Align := CONTROL_ALIGN_TOP

	cRelDet3:=STR0051 + " (" + Alltrim((cTRB9051)->CODFUN) + " - " + Alltrim((cTRB9051)->NOME) + ")" //"Utilizacao do Funcionario.:"
	cRelCab :=STR0047 + " " + DToC(dPeriodoDe) + "  -  " + STR0048 + " " + DToC(dPeriodoAte) + "" //"Data Inicio:"###"Data Fim:"

	@ 04,005 Button STR0021 Of oPanelTop Size 40,09 Pixel Action (C905PRINT(3, (cTRB9051), (cTRB9052)->CALEND, (cTRB9052)->BLOQUE, (cTRB9052)->DISPON, (cTRB9052)->REALIZ)) //"&Imprimir"

	@ 20,005 Say cRelDet3 SIZE 200,12 Of oPanelTop Pixel Font oFont
	@ 30,005 Say cRelCab  SIZE 200,12 Of oPanelTop Pixel Font oFont

	oPnlList := TPanel():New(01,01,,oDlg1,,,,,,70,70,.F.,.F.)
	oPnlList:Align := CONTROL_ALIGN_ALLCLIENT

	@ 3,0.3 ListBox OLIST1 Fields	DATAF,; //"Data"
	PADL( CALEND, 12 ),; //"Carga horária"
	PADL( BLOQUE, 12 ),; //"Bloqueios"
	PADL( DISPON, 12 ),; //"Disponibilidade"
	PADL( REALIZ, 12 ),; //"Hr.Realizadas"
	PADR( DIFERE, 12 ),; //"Diferenca"
	PADR( PERCEN, 12 ),; //"Percentual"
	PADL( EXTRA , 10 );  //"Hr. Extras"
	HEADERS STR0052,;	 //"Data"
	STR0023,;	//"Carga horária"
	STR0062,;   //"Bloqueios"
	STR0063,;	//"Disponibilidade"
	STR0024,;	//"Hr.Realizadas"
	STR0049,;   //"Diferenca"
	STR0065,;   //"Percentual (%)"
	STR0060;	//"Hr. Extras"
	Of oPnlList Size 610,350 FieldSizes 70,70,70,70,70,70,70

	OLIST1:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelUnder := TPanel():New(01,01,,oDlg1,,,,,,40,40,.F.,.F.)
	oPanelUnder:Align := CONTROL_ALIGN_BOTTOM
	*/
	aAreaTRB := GetArea()

	DbSelectArea(cTRB9051)
	DbGoTop()
	While !Eof()
		nPerce += (cTRB9051)->PERCEN //Variável que acumula o percentual de horas.
		DbSelectArea(cTRB9051)
		DbSkip()
	End While

	RestArea( aAreaTRB )
	/*
	@ 05,010 Say STR0038 SIZE 60,10 Of oPanelUnder  Pixel  Font oFont  //"TOTAL GERAL"
	@ 05,075 Say AllTrim( (cTRB9052)->CALEND ) SIZE 60,10 Of oPanelUnder  Pixel  Font oFont
	@ 05,145 Say AllTrim( (cTRB9052)->BLOQUE ) SIZE 60,10 Of oPanelUnder  Pixel  Font oFont
	@ 05,213 Say AllTrim( (cTRB9052)->DISPON ) SIZE 60,10 Of oPanelUnder  Pixel  Font oFont
	@ 05,286 Say AllTrim( (cTRB9052)->REALIZ ) SIZE 60,10 Of oPanelUnder  Pixel  Font oFont
	@ 05,350 Say AllTrim( (cTRB9052)->DIFERE ) SIZE 60,10 Of oPanelUnder  Pixel  Font oFont
	@ 05,435 Say PADR( Transform( nPerce,"@!" ),6 )	SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
	@ 05,501 Say (cTRB9052)->EXTRA             SIZE 60,10 Of oPanelUnder  Pixel  Font oFont

	OLIST1:Refresh()
	Activate Dialog oDlg1
	*/
	DbselectArea(cTRB9052)
	
Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} G905DET2()
Gera o detalhamento por funcionarios/data na tela principal.
@Return: .T.
@Author: Ricardo Dal Ponte
@Since:  18/08/2006
Melhoria realizada:
@Author: Elynton Fellipe Bazzo
@Since:  20/06/2014
/*/
//---------------------------------------------------------------------
Static Function G905DET2( cDescri,cTipo,cTipoD )

	Local oFont		:= TFont():New( "Arial",8,14,,.T.,,.F.,,.F.,.F. )
	Local aSize		:= MsAdvSize(,.F.,430)
	Local nLargura	:= aSize[5]
	Local nAltura	:= aSize[6]
	Local nPerce	:= 0
	
	/*
	Define MsDialog oDlg1 Title STR0053 From aSize[7],0 To nAltura,nLargura Of oMainWnd Pixel //"Horas Disponiveis X Horas Realizadas (por Funcionario)"

	If nTipoRel = 1 .Or. nTipoRel = 2
		cRelDet2:=STR0054 + " " + cDescri + ".: (" + Alltrim(cTipo) + " - " + Alltrim(cTipoD) + ")" //"Utilizacao por"
		cRelCab :=STR0047 + " " + DToC(dPeriodoDe) + "  -  " + STR0048 + " " + DToC(dPeriodoAte) + "" //"Data Inicio:"###"Data Fim:"
	Else
		cRelDet2:=STR0046 + " " + If(nTipoRel = 1,STR0016,If(nTipoRel = 2,STR0017,STR0018)) //"MDO por"###"Centro Custo"###"Especialidade"###"Funcionario"
		cRelCab :=STR0047 + " " + DToC(dPeriodoDe) + "  -  " + STR0048 + " " + DToC(dPeriodoAte) + "" //"Data Inicio:"###"Data Fim:"
	EndIf

	oDlg1:lMaximized := .T.
	oPanelTop := TPanel():New(01,01,,oDlg1,,,,,,40,40,.F.,.F.)
	oPanelTop:Align := CONTROL_ALIGN_TOP

	@ 04,005 Button STR0020 Of oPanelTop Size 40,09 Pixel Action (C905GRAFI(2)) //"&Grafico"
	@ 04,045 Button STR0021 Of oPanelTop Size 40,09 Pixel Action (C905PRINT(2, (cTRB9051), (cTRB)->CALEND, (cTRB)->BLOQUE, (cTRB)->DISPON, (cTRB)->REALIZ )) //"&Imprimir"

	@ 20,005 Say cRelDet2 SIZE 388,12 Of oPanelTop Pixel Font oFont
	@ 30,005 Say cRelCab  SIZE 200,12 Of oPanelTop Pixel Font oFont

	oPnlList := TPanel():New(01,01,,oDlg1,,,,,,70,70,.F.,.F.)
	oPnlList:Align := CONTROL_ALIGN_ALLCLIENT

	@ 3,0.3 ListBox OLIST2 Fields	CODFUN,;
	NOME,;
	PADL( CALEND, 12 ),; //"Carga horária"
	PADL( BLOQUE, 12 ),; //"Bloqueios"
	PADL( DISPON, 12 ),; //"Disponibilidade"
	PADL( REALIZ, 12 ),; //"Hr.Realizadas"
	PADR( DIFERE, 12 ),; //"Diferenca"
	PADR( PERCEN, 12 ),; //"Percentual"
	PADL( EXTRA , 10 );  //"Hr. Extras"
	HEADERS	STR0018,; //"Funcionario"
	STR0022,; //"Nome"
	STR0023,; //"Carga horária"
	STR0062,; //"Bloqueios"
	STR0063,; //"Disponibilidade"
	STR0024,; //"Hr.Realizadas"
	STR0049,; //"Diferenca"
	STR0065,; //"Percentual (%)"
	STR0060;  //"Hr. Extras"
	Of oPnlList Size 610,350 FieldSizes 70,70,70,70,70,70,70 On DblClick(G905DET1((cTRB9052)->TIPO, (cTRB9052)->CODFUN))

	OLIST2:Align := CONTROL_ALIGN_ALLCLIENT

	oPanelUnder := TPanel():New(01,01,,oDlg1,,,,,,40,40,.F.,.F.)
	oPanelUnder:Align := CONTROL_ALIGN_BOTTOM
	*/
	If nTipoRel = 1 .Or. nTipoRel = 2

		aAreaTRB := GetArea()
		DbSelectArea(cTRB9052)
		DbGoTop()
		While !Eof()
			nPerce += (cTRB9052)->PERCEN //Variável que acumula o percentual de horas.
			DbSelectArea(cTRB9052)
			DbSkip()
		End While
		RestArea( aAreaTRB )
		/*
		@ 05,050 Say STR0038 SIZE 60,10 OF oPanelUnder  Pixel  Font oFont  //"TOTAL GERAL"
		@ 05,146 Say AllTrim( (cTRB)->CALEND ) SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
		@ 05,213 Say AllTrim( (cTRB)->BLOQUE ) SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
		@ 05,286 Say AllTrim( (cTRB)->DISPON ) SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
		@ 05,359 Say AllTrim( (cTRB)->REALIZ ) SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
		@ 05,425 Say AllTrim( (cTRB)->DIFERE ) SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
		@ 05,503 Say PADR( Transform( nPerce,"@!" ),6 )	SIZE 60,10 OF oPanelUnder  PIXEL  Font oFont
		@ 05,560 Say (cTRB)->EXTRA             SIZE 60,10 OF oPanelUnder  Pixel  Font oFont
		*/
	EndIf
	*/
	
			//oPnlList := TPanel():New(01,01,,oDlg1,,,,,,70,70,.F.,.F.)
			//oPnlList:Align := CONTROL_ALIGN_ALLCLIENT

/*
		@ 05,050 Say STR0038   SIZE 60,10 OF oPanelUnder Pixel Font oFont  //"TOTAL GERAL"
		@ 05,146 Say nTotalCal SIZE 60,10 OF oPanelUnder Pixel Font oFont
		@ 05,213 Say nTotalBlo SIZE 60,10 OF oPanelUnder Pixel Font oFont
		@ 05,286 Say nTotalDis SIZE 60,10 OF oPanelUnder Pixel Font oFont
		@ 05,359 Say nTotalRel SIZE 60,10 OF oPanelUnder Pixel Font oFont
		@ 05,425 Say nTotalDif SIZE 60,10 OF oPanelUnder Pixel Font oFont
		@ 05,503 Say PADR( Transform( nTotalPer,"@!" ),6 )	SIZE 60,10 OF oPanelUnder Pixel Font oFont
		@ 05,560 Say nTotalExt SIZE 60,10 OF oPanelUnder Pixel Font oFont
*/	
	//@ 05,050 Say STR0038	Size 60,10 Of oPanelUnder Pixel Font oFont //"TOTAL GERAL"
			
	//EndIf

	//OLIST2:Refresh()
	//Activate Dialog oDlg1
	DbselectArea(cTRB)

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} GrvTRB9051()
Gravacao dos detalhes das horas dos funcionarios
@Return: .T.
@Author: Ricardo Dal Ponte
@Since:  17/08/2006
/*/
//---------------------------------------------------------------------
Static Function GrvTRB9051(cTipo, cCodFun, cNome, cDataF, nDispon, nReali, aDtExcRH, nHoraExtra)

	Local i, nPosRH
	Local nX	    := 0
	Local nTime	    := 0
	Local nQtdHrBlq := 0.0

	Default nHoraExtra := 0

	DbselectArea(cTRB9051)
	DbSetOrder(1)

	nPosRH  := Ascan(aDtExcRH,{|x| x = cDataF})
	If nPosRH > 0
		Return .T.
	EndIf

	If Empty(cTipo)
		return .t.
	End If

	If DbSeek( cTipo + cCodFun + DtOs( cDataF ) )
		(cTRB9051)->DISPO  := (cTRB9051)->DISPO + nDispon
		(cTRB9051)->REAL   := Somahoras((cTRB9051)->REAL,nReali)
		If nHoraExtra > 0
			(cTRB9051)->EXTRA := If(Somahoras((cTRB9051)->EXTRA,cValToChar(nHoraExtra)) == 0,MTOH(0),NgTraNtoH(Somahoras((cTRB9051)->EXTRA,cValToChar(nHoraExtra))))
		Endif

		nTime := Transform( Time(),'99:99' )

		For nX := 1 To Len( aTRB9051 ) //Percorre o Array de funcionários com O.S realizadas;
			//Se o funcionário for o mesmo, altera a qutd de horas;
			If cCodFun == aTRB9051[nX][1] .And. cDataF == aTRB9051[nX][2] .And. nTime == aTRB9051[nX][5]
				aTRB9051[nX][4] := (cTRB9051)->REAL //Horas Realizadas
			EndIf
		Next nX

	Else
		(cTRB9051)->(DbAppend())
		(cTRB9051)->TIPO   := cTipo
		(cTRB9051)->CODFUN := cCodFun
		(cTRB9051)->DATAF  := cDataF
		(cTRB9051)->NOME   := cNome
		(cTRB9051)->DISPO  := 0
		(cTRB9051)->REAL   := 0
		(cTRB9051)->DISPO  := (cTRB9051)->DISPO + nDispon
		(cTRB9051)->REAL   := Somahoras((cTRB9051)->REAL,nReali)
		If nHoraExtra > 0
			(cTRB9051)->EXTRA  := If(Somahoras((cTRB9051)->EXTRA,cValToChar(nHoraExtra)) == 0,MTOH(0),NgTraNtoH(Somahoras((cTRB9051)->EXTRA,cValToChar(nHoraExtra))))
		Endif

		nTime := Transform( Time(),'99:99' )

		//Adiciona no array 'aTRB9051' todos os funcionários para realizar o cálculo de horas;
		aAdd( aTRB9051,{ (cTRB9051)->CODFUN,(cTRB9051)->DATAF,(cTRB9051)->DISPO,(cTRB9051)->REAL,nTime })

		//Faz a chamada da função em que calcula a totalidade de horas bloqueadas por funcionário.
		nQtdHrBlq := Mnt905Blq( cCodFun,cDataF )
		//Soma a quantidade de horas em que o funcionário encontra-se bloqueado.
		nHorasBlq := SomaHoras( nHorasBlq,nQtdHrBlq )

	EndIf

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} GrvTRT9051()
Função de gravação dos totais dos detalhes das horas dos funcionarios.

@Return: .T.

@Author: Ricardo Dal Ponte
@Since:  21/08/2006

Melhoria realizada:
@Author: Elynton Fellipe Bazzo
@Since:  21/01/2014
/*/
//---------------------------------------------------------------------
Static Function GrvTRT9051( cEmp,cFil,cEmpAnt,aTRB9051,cThread1,aThread1 )

	Local nX		:= 0
	Local nHoras	:= 0
	Local nQtdHoras	:= 0
	Local nHrsReal	:= 0
	Local nHrsFds	:= 0
	Local nSabado	:= 0
	Local nDomingo	:= 0
	Local nHrsInRel	:= 0
	Local nDiffHrs	:= 0
	Local nDisponib := 0
	Local nDiferenc := 0
	Local nTotal	:= 0
	Local aArrayTRB	:= {} //Array que armazena as horas da 'TRB9051'.
	Local dDtFim	:= CTOD('  /  /  ')
	Local dDataF	:= CTOD('  /  /  ')
	Local cNGUNIDT	:= ""

	Private aHrsBloq := {}

	// Seta job para nao consumir licensas
	RpcSetType( 3 )
	// Seta job para empresa filial desejadas
	RPCSetEnv( cEmp,cFil,,,'MNT' )

	cNGUNIDT := AllTrim(GetMv( "MV_NGUNIDT"))

	For nX := 1 To Len( aTRB9051 ) //Percorre o array de detalhes das horas dos funcionarios;

		dbSelectArea( "STL" )
		dbSetOrder( 8 ) //TL_FILIAL+TL_TIPOREG+TL_CODIGO+TL_SEQRELA+DTOS( TL_DTINICI )
		dbSeek( xFilial( "STL" )+ "M" + PadR( aTRB9051[nX][1], TAMSX3( "TL_CODIGO" )[1] ) + "1" + DTOS( aTRB9051[nX][2] ))
		While !EoF() .And. &( "STL->( " + IndexKey() + " )" ) == xFilial( "STL" )+ "M" + PadR( aTRB9051[nX][1], TAMSX3( "TL_CODIGO" )[1] + "1  " + DTOS( aTRB9051[nX][2] ))

			If AllTrim( STL->TL_SEQRELA ) == "1"

				If STL->TL_USACALE == "N" // Se o funcionário NÃO utiliza calendário.

					While STL->TL_DTINICI < aTRB9051[nX][2] .And. STL->TL_DTFIM >= aTRB9051[nX][2]

						dDtFim		:= STL->TL_DTFIM  // Data Fim.
						dDataF		:= aTRB9051[nX][2] // Data Atual.
						nHrsDisp	:= aTRB9051[nX][3] / 60 //Horas que o funcionário encontra-se disponível por dia.
						nHrsFuBlo	:= Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

						If nHrsFuBlo > nHrsDisp //Se a qtd de horas do func. bloqueado for maior que as horas disponíveis.
							nDiffHrs := MTOH( 0 ) //Atribui zero para a variável, (Funcionário não pode ter mais hrs indisp., que horas disponíveis.)
						Else
							nDiffHrs := SubHoras( nHrsDisp,nHrsFuBlo ) //Calcula a quantidade de horas que o funcionário encontra-se disponível.
						EndIf

						If dDtFim > dDataF
							dDtFim	:= dDtFim - 1 //Decrementa a data fim.
							nHoras	:= TIMEWORK( aTRB9051[nX][2],"00:00",aTRB9051[nX][2],"24:00","" )
							nTotal	:= Somahoras( nTotal,nHoras ) //Realiza um calculo, incrementando o total de horas, com a hora atual.
						ElseIf STL->TL_DTFIM == aTRB9051[nX][2]
							nHoras		:= HTON( STL->TL_HOFIM ) //Converte o valor nHoras (Numérico) em Horas (EX: 99:99).
							nQtdHrs		:= TIMEWORK( STL->TL_DTFIM,"00:00",STL->TL_DTFIM,STL->TL_HOFIM,"" ) //Calcula as horas do ultimo dia.
							nTotal		:= Somahoras( nTotal, NtoH( nQtdHrs ) ) //Realiza um calculo, incrementando o total de horas, com a hora atual.
						Else
							nHoras		:= 0
							nDiffHrs	:= 0
						EndIf

						aAdd( aArrayTRB, Array( 7 ) )
						aArrayTRB[Len( aArrayTRB )][1] := If( nHrsDisp == 0  , MTOH( 0 ), NgTraNtoH( nHrsDisp  )) //Horas disponíveis (calendário).
						If cNGUNIDT == "D"
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
						Else
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
						EndIf
						aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
						aArrayTRB[Len( aArrayTRB )][3] := If( nDiffHrs == 0, MTOH( 0 ), NgTraNtoH( nDiffHrs  )) //Diferença de horas disponíveis/indisponíveis.
						aArrayTRB[Len( aArrayTRB )][4] := If( nHoras == 0, MTOH( 0 ), NgTraNtoH( nHoras )) //Horas realizadas.
						aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
						aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
						aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

						nHrsFuBlo := 0
						dbSkip()
					End While

					If STL->TL_DTINICI == aTRB9051[nX][2] .And. STL->TL_DTFIM > aTRB9051[nX][2]

						nQtdHoras := aTRB9051[nX][4]
						nHrsDisp  := aTRB9051[nX][3] / 60 //Horas que o funcionário encontra-se disponível por dia.
						nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

						If nHrsFuBlo > nHrsDisp //Se a qtd de horas do func. bloqueado for maior que as horas disponíveis.
							nDiffHrs := MTOH( 0 ) //Atribui zero para a variável, (Funcionário não pode ter mais hrs indisp., que horas disponíveis.)
						Else
							nDiffHrs := SubHoras( NTOH( nHrsDisp ),nHrsFuBlo ) //Calcula a quantidade de horas que o funcionário encontra-se disponível.
						EndIf

						If nQtdHoras == 0
							nHoras := 0
						Else
							If STL->TL_DTFIM > STL->TL_DTINICI // Se a data Fim for mais que a de Início.
								nHoras := SomaHoras( nHoras,SubHoras( "24:00",STL->TL_HOINICI )) //Pega a diferença da hora de início até as 24:00 horas.
							Else
								nHoras := SomaHoras( nHoras,SubHoras( STL->TL_HOFIM,STL->TL_HOINICI )) //Pega a diff de horas de início e fim de trabalho.
							EndIf
						EndIf

						aAdd( aArrayTRB, Array( 7 ) )
						aArrayTRB[Len( aArrayTRB )][1] := NTOH( nHrsDisp ) //Horas disponíveis (calendário).
						If cNGUNIDT == "D"
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
						Else
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
						EndIf
						aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
						aArrayTRB[Len( aArrayTRB )][3] := If( nDiffHrs == 0, MTOH( 0 ), NgTraNtoH( nDiffHrs  )) //Diferença de horas disponíveis/indisponíveis.
						aArrayTRB[Len( aArrayTRB )][4] := If( nHoras == 0, MTOH( 0 ), NgTraNtoH( nHoras )) //Horas realizadas.
						aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
						aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
						aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario


						nQtdHoras := SubHoras( nQtdHoras,nHoras ) // Subtrai a qtd total de horas pelas horas trabalhadas (dia-a-dia).
						nHrsFuBlo := 0

						While !Eof() .And. !Empty( nQtdHoras )

							nQtdHoras += aTRB9051[nX][4]
							nHrsDisp  := aTRB9051[nX][3] / 60 //Horas que o funcionário encontra-se disponível por dia.
							nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

							nDiffHrs  := SubHoras( NTOH( nHrsDisp ),nHrsFuBlo )

							If nQtdHoras > 24 //Se a qtd de hrs for maior que 24.
								nHoras		:= 24 //Como não utiliza calend. atribui 24 hrs trabalhadas.
								nQtdHoras	:= SubHoras( nQtdHoras,"24:00" ) //Subtrai a qtd de horas - 24.
							Else
								nHoras		:= nQtdHoras
								nQtdHoras	:= 0
							EndIf

							aAdd( aArrayTRB, Array( 7 ) )
							aArrayTRB[Len( aArrayTRB )][1] := NTOH( nHrsDisp ) //Horas disponíveis (calendário).
							If cNGUNIDT == "D"
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
							Else
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
							EndIf
							aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
							aArrayTRB[Len( aArrayTRB )][3] := If( nDiffHrs == 0, MTOH( 0 ), NgTraNtoH( nDiffHrs  )) //Diferença de horas disponíveis/indisponíveis.
							aArrayTRB[Len( aArrayTRB )][4] := If( nHoras == 0, MTOH( 0 ), NgTraNtoH( nHoras )) //Horas realizadas.
							aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
							aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
							aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

							nHrsFuBlo := 0
							dbSkip()
						End While

					ElseIf STL->TL_DTINICI == aTRB9051[nX][2] .And. STL->TL_DTFIM == aTRB9051[nX][2] // Pega a Hora final do calend. - Hora inicial.

						nHoras	  := aTRB9051[nX][4] //Horas realizadas.
						nHrsDisp  := aTRB9051[nX][3] / 60 //Horas que o funcionário encontra-se disponível por dia.
						nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

						aAdd( aArrayTRB, Array( 7 ) )
						aArrayTRB[Len( aArrayTRB )][1] := NTOH( nHrsDisp ) //Horas disponíveis (calendário).
						If cNGUNIDT == "D"
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
						Else
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
						EndIf
						aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
						aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
						aArrayTRB[Len( aArrayTRB )][4] := If( nHoras == 0, MTOH( 0 ), NgTraNtoH( nHoras )) //Horas realizadas.
						aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
						aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
						aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

						nHoras		:= 0
						nHrsDisp	:= 0
						nHrsFuBlo	:= 0
					EndIf

				ElseIf STL->TL_USACALE == "S" // Se o funcionário UTILIZA calendário.

					DBSelectArea( "ST1" )
					DBSetOrder( 01 ) //T1_FILIAL+T1_CODFUNC
					DBSeek( xFilial( "ST1" )+ PadR( aTRB9051[nX][1], TAMSX3( "TL_CODIGO" )[1] ), .T. )
					aHrsCal	:= NG_H7( ST1->T1_TURNO ) // Monta uma matriz com os dados do calendario.
					nHfIM		:= aHrsCal[1][2] // Hora final de horas trabalhadas no calendário.
					nHoras		:= aHrsCal[1][3] // Qtd de horas trabalhadas por dia.
					nSabado		:= aHrsCal[6][3] // Qtd de horas trabalhadas aos sábados.
					nDomingo	:= aHrsCal[7][3] // Qtd de horas trabalhadas aos domingos.
					nHrsInRel	:= NTOH( TIMEWORK( STL->TL_DTINICI, STL->TL_HOINICI, aTRB9051[nX][2], nHfIM, ST1->T1_TURNO )) // Horas Iniciais

					While STL->TL_DTINICI < aTRB9051[nX][2] .And. STL->TL_DTFIM >= aTRB9051[nX][2]

						dDtFim    := STL->TL_DTFIM //Data Fim.
						dDataF    := aTRB9051[nX][2]
						nQtdHoras := aTRB9051[nX][4] //Qtd de horas realizadas.
						nHrsDisp  := NTOH( aTRB9051[nX][3] / 60 ) //Horas que o funcionário encontra-se disponível por dia.
						nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

						If CDOW( aTRB9051[nX][2] ) == "Saturday" .Or. CDOW( aTRB9051[nX][2] ) == "Sunday" //Se a data atual cair no sábado/domingo.

							If CDOW( aTRB9051[nX][2] ) == "Saturday" //Se a data atual cair no sábado.
								nHrsDisp := nSabado //Atribui a qtd de horas trabalhadas no sábado à variável dinâmica.
							ElseIf CDOW( aTRB9051[nX][2] ) == "Sunday" //Se a data atual cair no domingo.
								nHrsDisp := nDomingo //Atribui a qtd de horas trabalhadas no domingo à variável dinâmica.
							EndIf

							aAdd( aArrayTRB, Array( 7 ) )
							aArrayTRB[Len( aArrayTRB )][1] := nHrsDisp //Horas disponíveis (calendário).
							If cNGUNIDT == "D"
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
							Else
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
							EndIf
							aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
							aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
							aArrayTRB[Len( aArrayTRB )][4] := nHrsDisp
							aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
							aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
							aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

							nQtdHoras	:= SubHoras( nQtdHoras,nHrsDisp ) //Subtrai a qtd de horas, com as hora trabalhada no sábado/domingo.
							nTotal		:= Somahoras( nTotal,nHrsDisp ) //Incrementa ao Total de horas trabalhadas, as hrs do sábado/domingo.
						Else
							If dDtFim > dDataF //Se a data final for maior que a data atual.
								dDtFim		:= dDtFim - 1 //Decrementa a data fim.
								nHrsReal	:= nHoras
								nTotal		:= Somahoras( nTotal, nHoras ) //Realiza um calculo, incrementando o total de horas, com a hora atual.
							ElseIf STL->TL_DTFIM == aTRB9051[nX][2]
								nHrsReal	:= NTOH( TIMEWORK( STL->TL_DTFIM, aHrsCal[1][1], STL->TL_DTFIM, STL->TL_HOFIM, ST1->T1_TURNO))
								nQtdHrs		:= TIMEWORK( STL->TL_DTFIM, STL->TL_HOINICI, STL->TL_DTFIM, STL->TL_HOFIM, ST1->T1_TURNO) //Calcula as horas do ultimo dia.
								nTotal		:= Somahoras( nTotal, NtoH( nQtdHrs ) ) //Realiza um calculo, incrementando o total de horas, com a hora atual.
							Else
								nHrsReal	:= NTOH( 0 ) // Converte no formato de horas (EX: 00:00).
								nHoras		:= 0
								nQtdHrs		:= 0
							EndIf

							aAdd( aArrayTRB, Array( 7 ) )
							aArrayTRB[Len( aArrayTRB )][1] := nHrsDisp //Horas disponíveis (calendário).
							If cNGUNIDT == "D"
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
							Else
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
							EndIf
							aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
							aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
							aArrayTRB[Len( aArrayTRB )][4] := nHrsReal
							aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
							aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
							aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario
						EndIf

						nHrsFuBlo := 0
						dbSkip()
					End While

					If STL->TL_DTINICI == aTRB9051[nX][2] .And. STL->TL_DTFIM > aTRB9051[nX][2]

						nQtdHoras := aTRB9051[nX][4]
						nHrsDisp  := NTOH( aTRB9051[nX][3] / 60 ) //Horas que o funcionário encontra-se disponível por dia.
						nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

						If CDOW( aTRB9051[nX][2] ) == "Saturday" .Or. CDOW( aTRB9051[nX][2] ) == "Sunday" //Se a data atual cair no sábado/domingo.
							If CDOW( aTRB9051[nX][2] ) == "Saturday" //Se a data atual cair no sábado.
								nHrsFds := nSabado //Atribui a qtd de horas trabalhadas no sábado à variável dinâmica.
							ElseIf CDOW( aTRB9051[nX][2] ) == "Sunday" //Se a data atual cair no domingo.
								nHrsFds := nDomingo //Atribui a qtd de horas trabalhadas no domingo à variável dinâmica.
							EndIf

							aAdd( aArrayTRB, Array( 7 ) )
							aArrayTRB[Len( aArrayTRB )][1] := nHrsDisp //Horas disponíveis (Calendário).
							If cNGUNIDT == "D"
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
							Else
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
							EndIf
							aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
							aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
							aArrayTRB[Len( aArrayTRB )][4] := nHrsFds
							aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
							aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
							aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

							If nQtdHoras > HtoN( nHrsFds )
								nQtdHoras := SubHoras( nQtdHoras, NtoH( Val( nHrsFds ))) //Subtrai a qtd de horas, com as hora trabalhada (dia-a-dia).
							Else
								nQtdHoras := nQtdHoras
							EndIf
							nTotal	:= Somahoras( nTotal, NtoH( Val( nHrsFds ))) //Soma ao total geral de horas, as horas trabalhadas (dia-a-dia).
							nHrsFds	:= 0
						Else
							aAdd( aArrayTRB, Array( 7 ) )
							aArrayTRB[Len( aArrayTRB )][1] := nHrsDisp //Horas disponíveis (Calendário).
							If cNGUNIDT == "D"
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
							Else
								nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
							EndIf
							aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
							aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
							aArrayTRB[Len( aArrayTRB )][4] := nHrsInRel //Horas iniciais trabalhadas.
							aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
							aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
							aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

							nQtdHoras	:= SubHoras( nQtdHoras,nHrsInRel ) //Subtrai da qtd total de horas a hora do primeiro dia de trabalho da semana.
							nTotal		:= nHrsInRel
							nHrsInRel	:= 0
						EndIf

						nHrsFuBlo := 0

						While !Eof() .And. !Empty( nQtdHoras )

							nHrsDisp  := NTOH( aTRB9051[nX][3] / 60 ) //Horas que o funcionário encontra-se disponível por dia.
							nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

							If CDOW( aTRB9051[nX][2] ) == "Saturday" .Or. CDOW( aTRB9051[nX][2] ) == "Sunday" //Se a data atual cair no sábado/domingo.

								If CDOW( aTRB9051[nX][2] ) == "Saturday" //Se a data atual cair no sábado.
									If NgTraNtoH( nQtdHoras ) < nSabado
										nHrsFds := NgTraNtoH( nQtdHoras )
									Else
										nHrsFds := nSabado //Atribui a qtd de horas trabalhadas no sábado à variável dinâmica.
									EndIf
								ElseIf CDOW( aTRB9051[nX][2] ) == "Sunday" //Se a data atual cair no domingo.
									If NgTraNtoH( nQtdHoras ) < nDomingo
										nHrsFds := NgTraNtoH( nQtdHoras )
									Else
										nHrsFds := nDomingo //Atribui a qtd de horas trabalhadas no domingo à variável dinâmica.
									EndIf
								EndIf

								aAdd( aArrayTRB, Array( 7 ) )
								aArrayTRB[Len( aArrayTRB )][1] := nHrsFds
								If cNGUNIDT == "D"
									nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
								Else
									nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
								EndIf
								aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
								aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
								aArrayTRB[Len( aArrayTRB )][4] := nHrsFds
								aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
								aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
								aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

								If nQtdHoras > HtoN( nHrsFds )
									nQtdHoras := SubHoras( nQtdHoras,nHrsFds )//Subtrai da qtd total de horas a hora trabalhada por dia.
								Else
									nQtdHoras := nQtdHoras
								EndIf
								nTotal	:= Somahoras( nTotal, NtoH( Val( nHrsFds ))) //Soma ao total geral de horas, as horas trabalhadas (dia-a-dia).
								nHrsFds	:= 0
							Else
								aAdd( aArrayTRB, Array( 7 ) )
								aArrayTRB[Len( aArrayTRB )][1] := nHrsDisp //Horas disponíveis.
								If cNGUNIDT == "D"
									nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
								Else
									nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
								EndIf
								aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
								aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
								If nQtdHoras > aTRB9051[nX][3] / 60 // Se o total de horas for maior que a qtd de horas trabalhadas.
									aArrayTRB[Len( aArrayTRB )][4] := nHoras
									nQtdHoras	:= SubHoras( nQtdHoras,nHoras ) //Subtrai da qtd total de horas a hora trabalhada por dia.
									nTotal		:= Somahoras( nTotal,nHoras ) //Soma as horas trabalhadas por dia, no total geral.
								Else
									aArrayTRB[Len( aArrayTRB )][4] := NgTraNtoH( nQtdHoras )
									nTotal		:= Somahoras( nTotal,nQtdHoras ) //Incrementa ao total de horas a 'sobra' de horas.
									nHoras		:= 0
									nQtdHoras	:= 0
								EndIf
								aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
								aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
								aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario
							EndIf

							nHrsFuBlo := 0
							dbSkip()
						End While
					EndIf

					If STL->TL_DTINICI == aTRB9051[nX][2] .And. STL->TL_DTFIM == aTRB9051[nX][2] // Pega a Hora final do calend - Hora inicial.
						nHoras		:= aTRB9051[nX][4] //Horas realizadas.
						nHrsDisp	:= aTRB9051[nX][3] / 60 //Horas que o funcionário encontra-se disponível por dia.
						nHrsFuBlo	:= Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

						aAdd( aArrayTRB, Array( 7 ) )
						aArrayTRB[Len( aArrayTRB )][1] := If( nHrsDisp == 0, MTOH( 0 ), NgTraNtoH( nHrsDisp  )) //Horas disponíveis (calendário).
						If cNGUNIDT == "D"
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
						Else
							nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
						EndIf
						aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo
						aArrayTRB[Len( aArrayTRB )][3] := NTOH(HTON( aArrayTRB[nX][1] ) - HTON( aArrayTRB[nX][2] ))
						aArrayTRB[Len( aArrayTRB )][4] := If( nHoras == 0, MTOH( 0 ), NgTraNtoH( nHoras )) //Horas realizadas.
						aArrayTRB[Len( aArrayTRB )][5] := NTOH(HTON( aArrayTRB[nX][3] ) - HTON( aArrayTRB[nX][4] ))
						aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
						aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

						nHoras		:= 0
						nHrsDisp	:= 0
						nHrsFuBlo	:= 0
					EndIf
				EndIf
			EndIf
			DBSelectArea( "STL" )
			DBSkip()
		End While

		nHrsFuBlo := 0
		nQtdHoras := aTRB9051[nX][4] //Horas realizadas.
		DBSelectArea( "ST1" )
		DBSetOrder( 01 ) //T1_FILIAL+T1_CODFUNC
		DBSeek( xFilial( "ST1" )+ PadR( aTRB9051[nX][1], TAMSX3( "TL_CODIGO" )[1] ), .T. )
		If ST1->T1_DTFIMDI < aTRB9051[nX][2] .And. !Empty( ST1->T1_DTFIMDI )
			nHrsDisp  := 0
		Else
			nHrsDisp  := aTRB9051[nX][3] / 60 //Horas que o funcionário encontra-se disponível por dia.
		EndIf

		nHrsFuBlo := Mnt905Blq( aTRB9051[nX][1],aTRB9051[nX][2] ) //Função que retorna a quantidade de horas por Bloqueio de Funcionário.

		If nQtdHoras == 0
			nHoras := MTOH( 0 )
		Else
			If STL->TL_DTFIM > STL->TL_DTINICI // Se a data Fim for mais que a de Início.
				nHoras := NgTraNtoH( SubHoras( "24:00",STL->TL_HOINICI )) //Pega a diferença da hora de início até as 24:00 horas.
			Else
				nHoras := NgTraNtoH( aTRB9051[nX][4] ) //TIMEWORK( STL->TL_DTINICI,STL->TL_HOINICI,STL->TL_DTFIM,STL->TL_HOFIM,"" ))
			EndIf
		EndIf

		aAdd( aArrayTRB, Array( 7 ) )
		aArrayTRB[Len( aArrayTRB )][1] := If( nHrsDisp == 0, MTOH( 0 ),NTOH( nHrsDisp )) //Horas disponíveis (calendário).
		If cNGUNIDT == "D"
			nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NTOH( nHrsFuBlo ))
		Else
			nHrsFuBlo := If( nHrsFuBlo == 0, MTOH( 0 ), NgTraNtoH( nHrsFuBlo )) //Horas indisponíveis.
		EndIf

		aArrayTRB[Len( aArrayTRB )][2] := nHrsFuBlo //Horas Bloqueadas
		nDisponib := IIf(HTON(aArrayTRB[nX][1])-HTON(aArrayTRB[nX][2]) <= 0,MTOH(0),NTOH(HTON(aArrayTRB[nX][1])-HTON(aArrayTRB[nX][2])))

		aArrayTRB[Len( aArrayTRB )][3] := nDisponib //Disponibilidade
		aArrayTRB[Len( aArrayTRB )][4] := nHoras    //Horas realizadas.
		nDiferenc := IIf(HTON(aArrayTRB[nX][3])-HTON(aArrayTRB[nX][4]) <= 0,MTOH(0),NTOH(HTON(aArrayTRB[nX][3])-HTON(aArrayTRB[nX][4])))

		aArrayTRB[Len( aArrayTRB )][5] := nDiferenc //Diferença -- Disponiveis - (Bloqueio + Realizadas)
		aArrayTRB[Len( aArrayTRB )][6] := Round(( NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][4] ),'D','S') * 100 ) / NGCONVERHORA( HTON( aArrayTRB[Len( aArrayTRB )][1] ),'D','S'),5 )
		aArrayTRB[Len( aArrayTRB )][7] := aTRB9051[nX][1] // Funcionario

		nHrsFuBlo	:= 0
		nHoras		:= 0
		nHrsDisp	:= 0

	Next nX

	PutGlbValue( cThread1,'.T.' ) //Define com o .T. a variável 'cThread1'.
	PutGlbVars( aThread1,aArrayTRB ) //Armazena sob o 'aThread1', o conteúdo do array 'aArrayTRB'.

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} GrvTRB9052()
Gravacao dos agrupamentos por funcionarios
@return .T.
@Author: Ricardo Dal Ponte
@Since:  17/08/2006
Melhoria realizada:
@Author: Elynton Fellipe Bazzo
@Since:  19/06/2014
/*/
//---------------------------------------------------------------------
Static Function GrvTRB9052()

	Local dData := CTOD("  /  /    ") //Variável utilizada na função 'Mnt905Blq', que retorna a quantidade de horas por Bloqueio de Funcionário.

	DbselectArea(cTRB9051)
	DbGotop()
	ProcRegua(LastRec())

	While !Eof()
		IncProc()
		DbselectArea(cTRB9052)
		DbSetOrder(1)

		aArea := GetArea()

		DBSelectArea( "STL" )
		DBSetOrder( 8 ) //TL_FILIAL+TL_TIPOREG+TL_CODIGO
		DBSeek( xFilial( "STL" )+ "M"+PadR( (cTRB9051)->CODFUN, TAMSX3( "TL_CODIGO" )[1] ) )
		DBSelectArea( "STK" )
		DBSetOrder( 01 )
		If DBSeek( xFilial( "STK" )+Space(Len( STK->TK_ORDEM ))+Space(Len( STK->TK_PLANO ))+Space(Len( STK->TK_TAREFA ))+(cTRB9051)->CODFUN )
			If !Empty( STL->TL_DTINICI )
				dData := STL->TL_DTINICI //Data de início do insumo.
			Else
				dData := STK->TK_DATAINI //Data de início do bloqueio.
			EndIf
		EndIf

		RestArea( aArea )

		If DbSeek( (cTRB9051)->TIPO+(cTRB9051)->CODFUN )
			If (cTRB9051)->REAL > 0
				(cTRB9051)->REAL := (cTRB9051)->REAL
			EndIf
			(cTRB9052)->DISPO := (cTRB9052)->DISPO + (cTRB9051)->DISPO
			(cTRB9052)->REAL  := SomaHoras((cTRB9052)->REAL ,(cTRB9051)->REAL)
			(cTRB9052)->EXTRA := cValToChar(SomaHoras((cTRB9052)->EXTRA,(cTRB9051)->EXTRA))
		Else
			If (cTRB9051)->REAL > 0
				(cTRB9051)->REAL :=(cTRB9051)->REAL
			EndIf
			(cTRB9052)->(DbAppend())
			(cTRB9052)->TIPO   := (cTRB9051)->TIPO
			(cTRB9052)->CODFUN := (cTRB9051)->CODFUN
			(cTRB9052)->NOME   := (cTRB9051)->NOME
			(cTRB9052)->DATAF  := dData
			(cTRB9052)->DISPO  := 0
			(cTRB9052)->REAL   := 0
			(cTRB9052)->PERCEN := 0
			(cTRB9052)->DISPO  := (cTRB9052)->DISPO + (cTRB9051)->DISPO
			(cTRB9052)->REAL   := (cTRB9052)->REAL  + (cTRB9051)->REAL
			(cTRB9052)->EXTRA  := cValToChar(SomaHoras((cTRB9052)->EXTRA,(cTRB9051)->EXTRA))
		EndIf

		DbselectArea(cTRB9051)
		DbSkip()
	End While

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} GrvTRT9052()
Função que executa a gravação dos totais do agrupamentos por funcionarios.

@return .T.

@Author: Elynton Fellipe Bazzo
@Since:  19/06/2014
/*/
//---------------------------------------------------------------------
Static Function GrvTRT9052( aHrsBloq )

	Local nX := 1
	Local nPosFunc

	DbselectArea(cTRB9052)
	DbGoTop()
	ProcRegua(LastRec())
	While !Eof()
		IncProc()

		nTotHrBlo := 0 //Zera a variável que armazena a qtd de horas disponíveis;

		If (nPosFunc := aScan( aHrsBloq, {|x| x[1] == (cTRB9052)->CODFUN } ) ) > 0
			nTotHrBlo := aHrsBloq[nPosFunc][2]
		Endif
		nTotDisp := NTOH( (cTRB9052)->DISPO / 60 ) //Horas disponíveis.

		RecLock((cTRB9052),.F. )
		(cTRB9052)->CALEND := If((cTRB9052)->DISPO == 0,MTOH(0),nTotDisp) //Horas disponíveis.
		(cTRB9052)->BLOQUE := If(nTotHrBlo == 0,MTOH(0),NgTraNtoH(nTotHrBlo)) //Horas indisponíveis.
		(cTRB9052)->DISPON := If(SubHoras((cTRB9052)->CALEND,(cTRB9052)->BLOQUE ) == 0,MTOH(0),NgTraNtoH(SubHoras((cTRB9052)->CALEND,(cTRB9052)->BLOQUE))) //Diferenças entre as horas disponíveis/indisponíveis.
		(cTRB9052)->REALIZ := If((cTRB9052)->REAL == 0,MTOH(0),NgTraNtoH((cTRB9052)->REAL)) //Horas realizadas.
		(cTRB9052)->PERCEN := Round((NGCONVERHORA(HTON((cTRB9052)->REALIZ),'D','S') * 100) / NGCONVERHORA(HTON((cTRB9052)->CALEND ),'D','S'),5)
		(cTRB9052)->DIFERE := If(SubHoras((cTRB9052)->DISPON,(cTRB9052)->REALIZ ) == 0, MTOH(0),NgTraNtoH(SubHoras((cTRB9052)->DISPON,(cTRB9052)->REALIZ))) //Diferença entre disponibilidades e horas realizadas.
		(cTRB9052)->EXTRA  := If(Val((cTRB9052)->EXTRA) == 0,MTOH(0),NgTraNtoH(Val((cTRB9052)->EXTRA))) //Horas Extras.
		MsUnLock(cTRB9052)

		//Variáveis utilizadas para a gravação dos totais.
		nTotalCal := If(SomaHoras(nTotalCal,(cTRB9052)->CALEND) == 0,MTOH(0),NgTraNtoH(SomaHoras(nTotalCal,(cTRB9052)->CALEND)))
		nTotalBlo := If(SomaHoras(nTotalBlo,(cTRB9052)->BLOQUE) == 0,MTOH(0),NgTraNtoH(SomaHoras(nTotalBlo,(cTRB9052)->BLOQUE)))
		nTotalDis := If(SomaHoras(nTotalDis,(cTRB9052)->DISPON) == 0,MTOH(0),NgTraNtoH(SomaHoras(nTotalDis,(cTRB9052)->DISPON)))
		nTotalRel := If(SomaHoras(nTotalRel,(cTRB9052)->REALIZ) == 0,MTOH(0),NgTraNtoH(SomaHoras(nTotalRel,(cTRB9052)->REALIZ)))
		nTotalDif := If(SomaHoras(nTotalDif,(cTRB9052)->DIFERE) == 0,MTOH(0),NgTraNtoH(SomaHoras(nTotalDif,(cTRB9052)->DIFERE)))
		nTotalPer := Round((NGCONVERHORA(HTON(nTotalRel),'D','S') * 100) / NGCONVERHORA(HTON(nTotalCal),'D','S'),5)
		nTotalExt := If(SomaHoras(nTotalExt,(cTRB9052)->EXTRA ) == 0,MTOH(0),NgTraNtoH(SomaHoras(nTotalExt,(cTRB9052)->EXTRA )))

		(cTRB9052)->(DbSkip())
	End While

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} c905GRAFI()
Grafico das O.S Trabalhadas
@return NIL
@Author: Inacio Luiz Kolling
@Since:  22/08/06
/*/
//---------------------------------------------------------------------
Static Function c905GRAFI( cTipo )

	Local nValor1 := 0
	Local oTmpTbl4 //Objeto Tabela Temporária 3 || Alias (cTRBV)

	Private cDispo := ""

	If nTipoRel = 1
		cDispo := STR0016 //"Centro Custo"
	ElseIf nTipoRel = 2
		cDispo := STR0017 //"Especialidade"
	ElseIf nTipoRel = 3
		cDispo := STR0018 //"Funcionario"
	EndIf

	// ARQUIVO DE DADOS
	aDBF3 := {{"CODIGO" , "C", 20,0},;
			  {"NOMECOD", "C", 30,0},;
			  {"VALOR1" , "N", 12,2},;
			  {"VALOR2" , "N", 12,2},;
			  {"VALOR3" , "N", 12,2}}

	//Instancia classe FWTemporaryTable
	oTmpTbl4 := FWTemporaryTable():New( cTRBV, aDBF3 )
	//Cria indices
	oTmpTbl4:AddIndex( "Ind01" , {"CODIGO"} )
	//Cria a tabela temporaria
	oTmpTbl4:Create()

	If cTipo = 1
		DbselectArea(cTRB)
	ELSE
		DbselectArea(cTRB9052)
		cDispo := STR0018 //"Funcionario"
	Endif

	Dbgotop()
	While !Eof()
		(cTRBV)->(DbAppend())
		If cTipo = 1
			(cTRBV)->CODIGO  := (cTRB)->TIPO
			(cTRBV)->NOMECOD := (cTRB)->NOME
			(cTRBV)->VALOR1  := NGCONVERHORA( HTON( (cTRB)->DISPON ),"D","S" )
			(cTRBV)->VALOR2  := NGCONVERHORA( HTON( (cTRB)->REALIZ ),"D","S" )
			(cTRBV)->VALOR3  := (cTRB)->EXTRA
			DbselectArea(cTRB)
		Else
			(cTRBV)->CODIGO  := (cTRB9052)->CODFUN
			(cTRBV)->NOMECOD := (cTRB9052)->NOME
			nValor1 	  := MTOH( (cTRB9052)->DISPO )
			(cTRBV)->VALOR1  := NGCONVERHORA( HTON( nValor1 ),"D","S" )
			(cTRBV)->VALOR2  := (cTRB9052)->REAL
			(cTRBV)->VALOR3  := Val((cTRB9052)->EXTRA)
			DbselectArea(cTRB9052)
		EndIf
		Dbskip()
	End While
	//---------------------------------------------------------------------
	// 1 - linha titulo do grafico (janela) 							  |
	// 2 - linha titulo da direita do grafico							  |
	// 3 - linha titulo superior do grafico  							  |
	// 4 - linha titulo da direita do grafico							  |
	// 5 - linha titulo da inferior do grafico							  |
	// 6 - linha series do grafico										  |
	// 7 - leitura ("A" - Arquivo temporario,"M" - Matriz)				  |
	// 8 - alias doa arquivo temporario com os dados /ou				  |
	// 9 - matriz com os dados											  |
	//---------------------------------------------------------------------

	vCRIGTXT := NGGRAFICO(" "+STR0001,; //"Horas Trabalhadas Na Manutencao"
	" ",;
	STR0001,; //"Horas Trabalhadas Na Manutencao"
	STR0019,; //"Horas Disponiveis X Horas Realizadas"
	STR0037+ " " + cDispo,; //"Disponibilidade por"
	{STR0025,; //"DISPONIVEL"
	STR0026,; //"REALIZADO"
	STR0061},; //"EXTRA"
	"A",(cTRBV))

	oTmpTbl4:Delete()//Deleta Tabela Temporária 4

	If cTipo = 1
		DbselectArea(cTRB)
	Else
		DbselectArea(cTRB9052)
	Endif

	Dbgotop()

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} C905PRINT()
Impressão das Horas Trabalhadas.
@return NIL
@Author: Inacio Luiz Kolling
@Since:  19/06/2014
/*/
//---------------------------------------------------------------------
Static Function C905PRINT( cNivel,cTabela,nHrsCalen,nHrsBloqu,nHrsReali,nHrsDifer  )

	Local cString	:= cTabela
	Local cDesc1	:= ""
	Local cDesc2	:= ""
	Local cDesc3	:= ""
	Local wnrel	:= "MNTC905"

	Private aReturn  := {STR0030, 1,STR0031, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	Private nLastKey := 0
	Private Titulo   := cDesc1
	Private Tamanho  := "M"
	Private oExcel  	:= FwMsExcel():New()

	DbSelectArea(cTabela)
	DbGoTop()

	If cNivel = "1" .OR. cNivel = "4"
		Titulo   := STR0055 //"Horas Disponiveis X Trabalhadas - " + AllTrim(cRelDet1) //"Analisede utilizacao de MDO - Disponivel X Realizado"
		Tamanho  := "M"
		RptStatus({|lEnd| C9051Imp(@lEnd,wnRel,titulo,tamanho,oprocess)})
	EndIf
	If cNivel = "2" .OR. cNivel = "4"
		Titulo   := STR0056 //"Horas Disponiveis X Trabalhadas - " + AllTrim(cRelDet2) //"Analisede utilizacao de MDO - Disponivel X Realizado por Funcionario"
		Tamanho  := "M"
		RptStatus({|lEnd| C9052Imp(@lEnd,wnRel,titulo,tamanho,oprocess)})
	EndIf
	If cNivel = "3" .OR. cNivel = "4"
		Titulo   := STR0057 //Horas Disponiveis X Trabalhadas - "  //"Analisede utilizacao de MDO - Disponivel X Realizado por Funcionario/Data"
		Tamanho  := "M"
		RptStatus({|lEnd| C9053Imp(@lEnd,wnRel,titulo,tamanho,oprocess)})
	EndIf

    If !(lJob)
        cDIRARQ := "C:\TEMP\"
        cNomArq := "REL_HDR"+cEmpAnt+"_"+cFilAnt+".XLS" 
    	//cNomZip := "REL_HDR"+czEMP+"_"+czFIL+".ZIP"
	Else
        cDIRARQ := "\rel_mnt\"
        cNomArq := "REL_HDR"+czEMP+"_"+czFIL+".XLS"
        //cNomZip := "REL_HDR"+czEMP+"_"+czFIL+".ZIP"
    EndIf

	oExcel:Activate()
	
    If !(lJob)
        MsAguarde({||Processa({|| oExcel:GetXMLFile(cDIRARQ+cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
		//fZip(cDIRARQ+cNomZip,{cDIRARQ+cNomArq})
     	//@Ticket 13242 ini
        cDIRREDE :="\rel_mnt\"
        nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 		
		If FError() == 25 //Arquivo já existe na pasta destino
			FERASE(cDIRREDE+cNomArq) 
            nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 
		EndIf
	Else
        oExcel:GetXMLFile(cDIRARQ+cNomArq)

        //fZip(cDIRARQ+cNomZip,{cDIRARQ+cNomArq})
     	//@Ticket 13242 ini
        cDIRREDE :="\rel_mnt\"
        nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 		
		If FError() == 25 //Arquivo já existe na pasta destino
			FERASE(cDIRREDE+cNomArq) 
            nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 
		EndIf

    Endif
    // oExcel:WorkBooks:Open(cNomArq) 	// Abre uma planilha
	// oExcel:SetVisible(.T.) 			// visualiza a planilha
	// apresenta a planilha gerada                      
	// oExcel:OpenXML(cNomArq) 
	oExcelApp:=MsExcel():New()                                         
	
	cTipoRel:=""	
	If nTipoRel == 1
		cTipoREL := "1=Por Centro Cust"
	ElseIf nTipoRel == 2
		cTipoREL := "2=Por Especialid."
	ElseIf nTipoRel == 3
		cTipoREL := "3=Por Funcionario"
	EndIf
	
	cTipoOrd:=""
	If nTipoOrd == 1
		cTipoOrd := "1=Corretiva"
	ElseIf nTipoOrd == 2
		cTipoOrd := "2=Preventiva"
	ElseIf nTipoOrd == 3
		cTipoOrd := "3=Outros"
	ElseIf nTipoOrd == 4
		cTipoOrd := "4=Todas"
	EndIf

	
			cHtml += ' <html>'
			cHtml += ' 	<head>'
			cHtml += ' 		<title>Editor HTML Online</title>'
			cHtml += ' 	</head>'
			cHtml += ' 	<body>'
			cHtml += ' 		<div style="text-align: left;">'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong><em>'+_cNomeEmpFil+' Relatorio de Horas Disponiveis x Realizadas</em></strong></p>'
			cHtml += ' 			<h3 style="color:red;">'
			cHtml += ' 				<strong><u>Parametros:</u></strong></h3>'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong>Do Periodo :</strong> <strong><span style="color:#0000cd;">'+DTOC(dPeriodoDe)+'</span></strong> <strong>Ate Periodo:</strong> <strong><span style="color:#0000cd;">'+DTOC(dPeriodoAte)+'</span></strong></p>'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong>Do Centro de Custo</strong>: <strong><span style="color:#0000cd;">'+cCCustoDe+'</span></strong> <strong>At&eacute; Centro de Custo:</strong> <span style="color:#0000cd;"><strong>'+cCCustoAte+'</strong></span></p>'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong>Da especialidade:&nbsp;</strong>'+cEspeciDe+'<strong>Ate Especialidade:</strong> <span style="color:#0000cd;"><strong>'+cEspeciAte+'</strong></span></p>'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong>Do Funcionario:</strong> <span style="color:#0000cd;"><strong>'+cFuncioDe+'</strong></span> <strong>Ate Funcionario:</strong> <strong><span style="color:#0000cd;">'+cFuncioAte+'</span></strong></p>'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong>Tipo de Rel.: <span style="color:#0000cd;">'+cTipoRel+'</span></strong></p>'
			cHtml += ' 			<p>'
			cHtml += ' 				<strong>Tipo de Ordens</strong> <span style="color:#0000cd;"><strong>'+cTipoOrd+'</strong></span></p>'
			cHtml += ' 		</div>'
			cHtml += ' 		<p>'
			cHtml += ' 			&nbsp;</p>'
			cHtml += ' 	</body>'
			cHtml += ' </html>'

	If !(lJob)
        oExcelApp:WorkBooks:Open( cDIRARQ+cNomArq ) // Abre uma planilha
        oExcelApp:SetVisible(.T.)
    Else
        aAdd(aAnexos, cDIRREDE+cNomArq)
        fEnvMail(cPara, cAssunto, cHtml, aAnexos, lMostraLog, lUsaTLS)
	EndIf

Return NIL
//---------------------------------------------------------------------
/*/{Protheus.doc} C9051Imp()
Chamada do Relat¢rio
@return NIL
@Author: Ricardo Dal Ponte
@Since:  22/06/06
/*/
//---------------------------------------------------------------------
Static Function C9051Imp( lEnd,wnRel,titulo,tamanho,oprocess)

	Local cRodaTxt := ""
	Local nCntImpr := 0
	Local nTotalRel := 0
	Local _cPlanilha := "HDR_N1"
	Local _cTitulo   := _cNomeEmpFil+" Relação de Horas Disponiveis x Realizadas "

	Private li		:= 80
	Private Cabec1	:=  AllTrim(cRelDet1) + " (" + AllTrim(cRelCab) + ")"
	Private Cabec2	:=  STR0058
	Private m_pag	:= 1
	Private nTipo	:= IIF(aReturn[4]==1,15,18)
	Private nomeprog:= "MNTC905"
	
	oExcel:AddworkSheet(_cPlanilha) // Planilha
	oExcel:AddTable (_cPlanilha,_cTitulo) // Titulo da Planilha (Cabeçalho)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Tipo"         ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Nome"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Bloqueio"	        ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Disponíveis"	        ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Realizadas"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Diferenças"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Percentual"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Extras"	    ,1,1)

	DbSelectArea(cTRB)
	DbGoTop()
	SetRegua(LastRec())
	While !(cTRB)->(Eof())
		IncRegua()

		NGSOMALI(58)
		oExcel:AddRow(_cPlanilha,_cTitulo,{(cTRB)->TIPO ,;
				                        (cTRB)->NOME   ,;
		                        		(cTRB)->BLOQUE ,;
		                        		(cTRB)->DISPON ,;
		                        		(cTRB)->REALIZ ,;
		                        		(cTRB)->DIFERE ,;
		                        		(cTRB)->PERCEN ,;
		                        		(cTRB)->EXTRA})	// Linha

		nTotalRel := NgTraNtoH( SomaHoras( (cTRB)->REALIZ, nTotalRel ) ) //Soma as horas realizadas de cada linha.

		(cTRB)->(DbSkip())
	End While

	NGSOMALI(58)
	NGSOMALI(58)
	NGSOMALI(58)

	nTotalPer := Round(( NGCONVERHORA( HTON( nTotalRel ),'D','S') * 100 ) / NGCONVERHORA( HTON( nTotalCal ),'D','S'),5 )//Variavel que verifica percentual realizado.

	oExcel:AddRow(_cPlanilha,_cTitulo,{	STR0038   ,;
			                        " "		  ,;
	                        		nTotalBlo ,;
	                        		nTotalDis ,;
	                        		nTotalRel ,;
	                        		nTotalDif ,;
	                        		nTotalPer ,;
	                        		nTotalExt})	// Linha

	DBgotop()

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} C9052Imp()
Chamada do Relat¢rio de detalhamento por funcionario
@return NIL
@Author: Ricardo Dal Ponte
@Since:  22/06/06
/*/
//---------------------------------------------------------------------
Static Function C9052Imp(lEnd,wnRel,titulo,tamanho,oprocess)

	Local cRodaTxt := ""
	Local nCntImpr := 0
	Local _cPlanilha := "HDR_N2"
	Local _cTitulo   := _cNomeEmpFil+" Relação de Horas Disponiveis x Realizadas "

	Private li		:= 80
	Private m_pag	:= 1
	Private nTipo	:= IIF(aReturn[4]==1,15,18)
	Private Cabec1	:= AllTrim(cRelDet2) + " " + AllTrim(cRelCab)
	Private Cabec2	:= STR0058
	Private nomeprog:= "MNTC905"
	//Private oExcel  	:= FwMsExcel():New()

	oExcel:AddworkSheet(_cPlanilha) // Planilha
	oExcel:AddTable (_cPlanilha,_cTitulo) // Titulo da Planilha (Cabeçalho)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Funcionario"         ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Nome"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.bloqueadas"	        ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.Disponíveis"	        ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.Realizadas"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Diferenças"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Percentual"		    ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.Extras"	    ,1,1)

	DbSelectArea(cTRB9052)
	DbGoTop()
	SetRegua(LastRec())
	While !(cTRB9052)->(Eof())
		IncRegua()

		NGSOMALI(58)
	
		oExcel:AddRow(_cPlanilha,_cTitulo,{(cTRB9052)->CODFUN,;
										(cTRB9052)->NOME,;
										(cTRB9052)->BLOQUE,;
										(cTRB9052)->DISPON,;
										(cTRB9052)->REALIZ,;
										(cTRB9052)->DIFERE,;
										(cTRB9052)->PERCEN,;
										(cTRB9052)->EXTRA})	// Linha

		nToHrCale := If(SomaHoras((cTRB9052)->CALEND,nToHrCale) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9052)->CALEND,nToHrCale)))
		nToHrBloq := If(SomaHoras((cTRB9052)->BLOQUE,nToHrBloq) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9052)->BLOQUE,nToHrBloq)))
		nToHrDisp := If(SomaHoras((cTRB9052)->DISPON,nToHrDisp) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9052)->DISPON,nToHrDisp)))
		nToHrReal := If(SomaHoras((cTRB9052)->REALIZ,nToHrReal) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9052)->REALIZ,nToHrReal)))
		nToHrDiff := If(SomaHoras((cTRB9052)->DIFERE,nToHrDiff) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9052)->DIFERE,nToHrDiff)))
		nToHrPerc := Round((NGCONVERHORA(HTON(nToHrReal),'D','S') * 100 ) / NGCONVERHORA(HTON(nToHrCale),'D','S'),5)
		nTHrExtra := If(SomaHoras((cTRB9052)->EXTRA,nTHrExtra ) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9052)->EXTRA,nTHrExtra )))

		(cTRB9052)->(DbSkip())
	End While

	NGSOMALI(58)
	NGSOMALI(58)
	NGSOMALI(58)

	oExcel:AddRow(_cPlanilha,_cTitulo,{	STR0038   ,;
			                        " "		  ,;
	                        		nToHrBloq ,;
	                        		nToHrDisp ,;
	                        		nToHrReal ,;
	                        		nToHrDiff ,;
	                        		nToHrPerc ,;
	                        		nTHrExtra})	// Linha

	DBgotop()

	nToHrCale := 0
	nToHrBloq := 0
	nToHrDisp := 0
	nToHrReal := 0
	nToHrDiff := 0
	nToHrPerc := 0
	nTHrExtra := 0

	DBgotop()

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} C9053Imp()
Chamada do Relat¢rio de detalhamento por funcionario/data
@return NIL
@Author: Ricardo Dal Ponte
@Since:  22/06/06
/*/
//---------------------------------------------------------------------
Static Function C9053Imp( lEnd,wnRel,titulo,tamanho,oprocess)

	Local cRodaTxt := ""
	Local nCntImpr := 0
	Local _cPlanilha := "HDR_N3"
	Local _cTitulo   := _cNomeEmpFil+" Relação de Horas Disponiveis x Realizadas "
	
	Private li		:= 80
	Private Cabec1	:= AllTrim(cRelDet3) + " " + AllTrim(cRelCab)
	Private Cabec2	:= STR0059
	Private m_pag	:= 1
	Private nTipo	:= IIF(aReturn[4]==1,15,18)
	Private nomeprog:= "MNTC905"

	oExcel:AddworkSheet(_cPlanilha) // Planilha
	oExcel:AddTable (_cPlanilha,_cTitulo) // Titulo da Planilha (Cabeçalho)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Data"          ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Calend"		  ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.bloqueadas" ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.Disponíveis",1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.Realizadas" ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Diferenças"	  ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Percentual"	  ,1,1)
	oExcel:AddColumn(_cPlanilha,_cTitulo,"Hr.Extras"	  ,1,1)
	
	DbSelectArea(cTRB9051)
	DbGoTop()
	SetRegua(LastRec())
	While !(cTRB9051)->(Eof())
		IncRegua()

		NGSOMALI(58)
	
		oExcel:AddRow(_cPlanilha,_cTitulo,{(cTRB9051)->DATAF,;
											(cTRB9051)->CALEND,;
											(cTRB9051)->BLOQUE,;
											(cTRB9051)->DISPON,;
											(cTRB9051)->REALIZ,;
											(cTRB9051)->DIFERE,;
											(cTRB9051)->PERCEN,;
											(cTRB9051)->EXTRA})	// Linha
		
		nToHrCale := If(SomaHoras((cTRB9051)->CALEND,nToHrCale) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9051)->CALEND,nToHrCale)))
		nToHrBloq := If(SomaHoras((cTRB9051)->BLOQUE,nToHrBloq) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9051)->BLOQUE,nToHrBloq)))
		nToHrDisp := If(SomaHoras((cTRB9051)->DISPON,nToHrDisp) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9051)->DISPON,nToHrDisp)))
		nToHrReal := If(SomaHoras((cTRB9051)->REALIZ,nToHrReal) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9051)->REALIZ,nToHrReal)))
		nToHrDiff := If(SomaHoras((cTRB9051)->DIFERE,nToHrDiff) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9051)->DIFERE,nToHrDiff)))
		nToHrPerc += (cTRB9051)->PERCEN
		nTHrExtra := If(SomaHoras((cTRB9051)->EXTRA ,nTHrExtra) == 0,MTOH(0),NgTraNtoH(SomaHoras((cTRB9051)->EXTRA ,nTHrExtra)))

		(cTRB9051)->(DbSkip())
	End

	NGSOMALI(58)
	NGSOMALI(58)
	
	oExcel:AddRow(_cPlanilha,_cTitulo,{STR0038,;
	       			                nToHrCale  ,;
	                        		nToHrBloq  ,;
	                        		nToHrDisp  ,;
	                        		nToHrReal  ,;
	                        		nToHrDiff  ,;
	                        		nToHrPerc  ,;
	                        		nTHrExtra})	// Linha

	nToHrCale := 0
	nToHrBloq := 0
	nToHrDisp := 0
	nToHrReal := 0
	nToHrDiff := 0
	nTHrExtra := 0

	DBgotop()

Return Nil
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCALCULO()
Calculo das horas disponiveis e realizadas (Turno Flutua.)
@return NIL
@Author: Marcos Wagner Junior
@Since:  01/08/09
/*/
//---------------------------------------------------------------------
Static Function MNTCALCULO(_dData)

	dDTATU := dPeriodoDe

	//Trata o calendario flutuante
	If GetNewPar("MV_NGFLUT","N") == "S"
		dbSelectArea("TP4")
		dbSetOrder(1)
		If dbSeek(xFilial("TP4")+ST1->T1_EQUIPE)
			While dDTATU <= dPeriodoAte
				dbSelectArea("TP6")
				dbSetOrder(1)
				If dbSeek(xFilial("TP6")+TP4->TP4_CODIGO) //+DTOS(dDTATU))
					While !Eof() .And. TP6->TP6_FILIAL = Xfilial("TP6") .And.;
					TP6->TP6_EQUIPE == TP4->TP4_CODIGO
						While dDTATU >= TP6->TP6_DTINI .And.  dDTATU <= TP6->TP6_DTFIM .And. dDTATU <= dPeriodoAte

							nPOS := ASCAN(aARRCALE,{|x| x[1] == TP6->TP6_CALEND})

							If nPOS = 0
								aDIAMAN := NG_H7(TP6->TP6_CALEND)
								Aadd(aARRCALE,{TP6->TP6_CALEND,aDIAMAN})
							Else
								aDIAMAN := aARRCALE[nPOS][2]
							EndIf

							If !Empty(aDIAMAN)
								nSEM    := If( DOW(dDTATU) == 1, 7, DOW(dDTATU)-1)
								nDISPO  += HtoM( aDIAMAN[nSEM][03] )

								//Tratamento da Excecao do Calendario
								nQuantD := HtoM(aDIAMAN[nSEM][03])
								If nDISPO > 0
									vHOREXC   := NG_H9(dDTATU)
									If !Empty(vHOREXC)
										nQuantDEx := HTOM(vHOREXC[3])
										nQUANTEXC += nQuantDEx
										nQuantD   := nQuantD - nQuantDEx
									EndIf
								EndIf

								///GRAVAR DETALHES DISPONIVEL
								GrvTRB9051(cSeek, ST1->T1_CODFUNC, ST1->T1_NOME,dDTATU,nQuantD, 0, aDtExcRH)
								lExistInf := .F.
							Endif
							dDTATU := dDTATU + 1
						End
						DbSelectArea("TP6")
						DbSkip()
					End
				EndIf
				dDTATU := dDTATU + 1
			End
		Else
			MNTCNAOFL(_dData)
		EndIf
	Else
		MNTCNAOFL(_dData)
	EndIf

Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} MNTCNAOFL()
Calculo das horas disponiveis e realizadas (Nao Turno Flut)
@return NIL
@Author: Marcos Wagner Junior
@Since:  01/08/09
/*/
//---------------------------------------------------------------------
Static Function MNTCNAOFL(_dData)

	nPOS := ASCAN(aARRCALE,{|x| x[1] == ST1->T1_TURNO})

	If nPOS = 0
		aDIAMAN := NG_H7(ST1->T1_TURNO)
		Aadd(aARRCALE,{ST1->T1_TURNO,aDIAMAN})
	Else
		aDIAMAN := aARRCALE[nPOS][2]
	EndIf

	If Empty(aDIAMAN)
		MsgInfo(STR0039+" "+ST1->T1_TURNO+" "+STR0040+" "+ST1->T1_CODFUNC+" "+STR0041+chr(13); //"Calendario/Turno"###"do funcionario"###"nao cadastrado"
		+STR0042,STR0028) //"O processo sera cancelado..."###"ATENCAO"
		lRETOR := .t.
		Return
	Endif

	While dDTATU <= _dData
		If !Empty( aDIAMAN )
			If ST1->T1_DTFIMDI >= dDTATU .Or. Empty( ST1->T1_DTFIMDI ) //Se a data fim da disponibilidade do funcionário for maior/igual que a data atual.
				nSEM    := If( DOW(dDTATU) == 1, 7, DOW(dDTATU)-1)
				nDISPO  += HtoM( aDIAMAN[nSEM][03] )

				//Tratamento da Excecao do Calendario
				nQuantD := HtoM(aDIAMAN[nSEM][03])
				If nDISPO > 0
					vHOREXC := NG_H9( dDTATU )
					If !Empty( vHOREXC )
						nQuantDEx := HTOM(vHOREXC[3])
						nQUANTEXC += nQuantDEx
						nQuantD   := nQuantD - nQuantDEx
					EndIf
				EndIf

				//Executa a função de gravação dos detalhes das horas dos funcionários.
				GrvTRB9051( cSeek,ST1->T1_CODFUNC,ST1->T1_NOME,dDTATU,nQuantD,0,aDtExcRH )
				lExistInf := .F.
			EndIf
		EndIf
		dDTATU := dDTATU + 1
	End While

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} Mnt905Blq()
Função que retorna a quantidade de horas por Bloqueio de Funcionário,
ou seja, a quantidade de horas que o funcionário encontra-se indisponível.
@param cCodFun --> Código do Funcionário.
@param dData ----> Data inicial do bloqueio.
@return nHrsFuBlo
@Author: Elynton Fellipe Bazzo
@Since:  21/05/2014
/*/
//---------------------------------------------------------------------

Static Function Mnt905Blq( cCodFun,dData )

	Local nHrsIni	:= 0.0
	Local nHrsFim	:= 0.0
	Local nHrsCal	:= 0.0

	Local aArea := GetArea() //Salva o ambiente ativo.

	nHrsFuBlo := 0

	DBSelectArea( "ST1" )
	DBSetOrder( 01 ) //T1_FILIAL+T1_CODFUNC
	DBSeek( xFilial( "ST1" )+ PadR( cCodFun, TAMSX3( "TL_CODIGO" )[1] ), .T. )
	aHrsCal	:= NG_H7( ST1->T1_TURNO ) // Monta uma matriz com os dados do calendario.
	nHrsIni	:= aHrsCal[1][1] // Hora início do calendário.
	nHrsFim	:= aHrsCal[1][2] // Hora fim do calendário.
	nHrsCal	:= aHrsCal[1][3] // Quantidade de horas do calendário.

	DBSelectArea( "STK" )
	DBSetOrder( 02 ) //TK_FILIAL+TK_CODFUNC+DTOS(TK_DATAINI)+DTOS(TK_DATAFIM)
	If !DBSeek(	xFilial( "STK" )+ cCodFun + DTOS( dData ), .T. )
		dbSkip(-1)
	Endif

	While !EoF().And. cCodFun == STK->TK_CODFUNC //Percorre os registros da 'STK'.

		//Se for o funcionário condizente e o bloqueio estiver dentro das datas informadas por parâmetros.
		If cCodFun == STK->TK_CODFUNC .And. STK->TK_DATAINI <= dData .And. STK->TK_DATAFIM >= dData

			//Se a data fim da disponibilidade for maior ou igual que a data percorrida OU a data fim da disponiblidade estiver vazia.
			If ST1->T1_DTFIMDI >= dData .Or. Empty( ST1->T1_DTFIMDI )

				If STK->TK_DATAINI == STK->TK_DATAFIM //Se o funcionário estiver bloqueado um dia.

					//Cálculo das horas por dia de bloqueio.
					nHrsFuBlo := SomaHoras( nHrsFuBlo,NGCONVERHORA( TIMEWORK( STK->TK_DATAINI,STK->TK_HORAINI,STK->TK_DATAFIM,STK->TK_HORAFIM,ST1->T1_TURNO ),'D','S' ))

				ElseIf dData == STK->TK_DATAINI //Se o funcionário estiver bloqueado mais que um dia.

					If	!(	( STK->TK_HORAINI < nHrsIni .And. STK->TK_HORAFIM < nHrsIni ) .Or. ;
					( STK->TK_HORAINI > nHrsFim .And. STK->TK_HORAFIM > nHrsFim ) )
						nHrsFuBlo := SomaHoras( nHrsFuBlo, SubHoras( nHrsFim, STK->TK_HORAINI ) ) //Cálculo das horas inicias do bloqueio.
					Endif

				ElseIf dData == STK->TK_DATAFIM //Se o funcionário estiver bloqueado mais que um dia.

					If	!(	( STK->TK_HORAINI < nHrsIni .And. STK->TK_HORAFIM < nHrsIni ) .Or. ;
					( STK->TK_HORAINI > nHrsFim .And. STK->TK_HORAFIM > nHrsFim ) )
						nHrsFuBlo := SomaHoras( nHrsFuBlo, SubHoras( STK->TK_HORAFIM,nHrsIni ) ) //Cálculo das horas finais do bloqueio.
					Endif

				Else

					nHrsFuBlo := SomaHoras( nHrsFuBlo,nHrsCal ) //Cálculo que realiza a soma das horas bloqueadas com as horas do calendário (ST1).

				Endif

			Endif
		Endif

		DBSkip()//Pula um registro.
	End While //Fim do While.

	RestArea( aArea ) //Restaura o ambiente salvo anteriormente.

Return nHrsFuBlo
//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadDados()
Função que executa em duas threads a função que realiza a gravação dos
totais dos detalhes das horas dos funcionarios.
@Parametrs: aTRB9051 - Array que será dividido para executar as threads;
@Author: Elynton Fellipe Bazzo
@Since:  04/11/2014
/*/
//---------------------------------------------------------------------
Static Function fLoadDados( aTRB9051, aHrsBloq )

	Local nX		:= 0
	Local aFirstVet	:= {}
	Local aSecondVt	:= {}
	Local aVetTotal	:= {}
	Local nPosFunc

	Local cThread1	:= "_lThrd1"+cValToChar( ThreadId() )
	Local cThread2	:= "_lThrd2"+cValToChar( ThreadId() )

	Local aThread1	:= "_aThrd1"+cValToChar( ThreadId() )
	Local aThread2	:= "_aThrd2"+cValToChar( ThreadId() )

	//Ordena os dados por funcionário+data. NÃO MEXER
	//Ocorre que quando o cliente possui turno flutuante é verificado todos os dias do mês com base no turno
	//flutuante e jogando no array aTRB9051. Após isso irá buscar na STL/TTL os apontamentos que ocorreram, e
	//adiciona ao final do array. Dessa forma, pode acontecer de datas menores ficaram ao final do array.
	//A lógica de inclusão abaixo não considerava isso, e o vetor aVetTotal estava ordenado por data, fazendo
	//assim que dados que só existiam no vetor fosse concatenado com dados que só existia no array misturando
	//a datas e mostrando dados incorretos na tela.
	//Como o aTRB9051 é unico para vários funcionário, é necessário ordenar por funcionário e data.
	aSort(aTRB9051,,,{|x,y|x[1] + DtoS(x[2]) <= y[1] + DtoS(y[2])})

	// Cria variaveis globais para controle das threads
	PutGlbValue( cThread1,'.F.' ) //Cria e define um valor ( string ) para a variável global 'cThread1';
	PutGlbValue( aThread1,'{0}' ) //Cria e define um valor ( string ) para a variável global 'aThread1';

	PutGlbValue( cThread2,'.F.' ) //Cria e define um valor ( string ) para a variável global 'cThread1';
	PutGlbValue( aThread2,'{0}' ) //Cria e define um valor ( string ) para a variável global 'aThread1';

	If Len( aTRB9051 ) == 0 //Se não houver conteúdo para ser exibido na consulta.
		MsgAlert( STR0064 ) //"Não existem dados para montar a consulta de Disponibilidade."
		Return .F.
	ElseIf Len(aTRB9051) > 1
		aFirstVet := array(Int(Len(aTRB9051)/2))
		aCopy(aTRB9051,aFirstVet,1,(Int(Len(aTRB9051)/2)))
		If Len(aTRB9051)%2 == 0
			aSecondVt := array((Int(Len(aTRB9051)/2)))
		Else
			aSecondVt := array((Int(Len(aTRB9051)/2)+1))
		EndIf
		aCopy(aTRB9051,aSecondVt,(Int(Len(aTRB9051)/2))+1)
	Else
		aAdd(aFirstVet,aTRB9051[1])
	EndIf

	//Executa a função "GrvTRT9051()" em uma thread sem interface.
	StartJob( "GrvTRT9051",GetEnvServer(),.F.,cEmpAnt,cFilAnt,'1',aFirstVet,cThread1,aThread1 )

	//Executa a função "GrvTRT9051()" em uma thread sem interface.
	StartJob( "GrvTRT9051",GetEnvServer(),.F.,cEmpAnt,cFilAnt,'2',aSecondVt,cThread2,aThread2 )

	//-------------------------------------------------------
	// Garante que a threads foi executada de forma perfeita
	//-------------------------------------------------------
	While .T.

		If &(GetGlbValue(cThread1))  .And. &(GetGlbValue(cThread2)) //Verifica o retorno da Thread.
			Sleep( 8000 )
			Exit
		EndIf

	End While

	aFirstVet := {} //Limpo o array para preenche-lô posteriormente com o conteúdo que será gravado na 'TRB';
	aSecondVt := {} //Limpo o array para preenche-lô posteriormente com o conteúdo que será gravado na 'TRB';

	//Recupera o conteúdo do array, armazenadas na variável global através da função PutGlbVars();
	GetGlbVars( aThread1,@aFirstVet )
	GetGlbVars( aThread2,@aSecondVt )

	aVetTotal := Array( Len( aFirstVet ) + Len( aSecondVt )) //Cria um novo array.
	aCopy( aFirstVet, aVetTotal, 1, Len( aFirstVet ) ) //Copia os elementos do array 'aFirstVet', unificando o array 'aVetTotal'.
	aCopy( aSecondVt, aVetTotal, 1, Len( aSecondVt ), Len( aFirstVet ) + 1 )//Copia os elementos do array 'aSecondVt', unificando o array 'aVetTotal'.

	dbSelectArea(cTRB9051)
	dbGoTop()

	For nX := 1 To Len( aVetTotal ) //Percorre o array e grava a 'TRB';

		RecLock((cTRB9051),.F. ) //Trava o registro do arquivo de dados que está posicionado, permitindo a gravação da alteração;
		(cTRB9051)->CALEND := aVetTotal[nX][1] //Calendário Funcionário 'Disponíveis';
		(cTRB9051)->BLOQUE := aVetTotal[nX][2] //Horas Bloqueadas 'Indisponíveis';
		(cTRB9051)->DISPON := aVetTotal[nX][3] //Diferença de Horas Disponíveis/Indisponíveis;
		(cTRB9051)->REALIZ := aVetTotal[nX][4] //Horas Realizadas 'STL';
		(cTRB9051)->DIFERE := aVetTotal[nX][5] //Diferença Total de Horas;
		(cTRB9051)->PERCEN := aVetTotal[nX][6] //Percentual da diferença entre as Horas;
		MsUnLock(cTRB9051)

		// Verifica se o funcionario em questao ja existe no array
		// Caso nao exista, adiciona nova linha no array com o funcionario
		If ( nPosFunc := aScan( aHrsBloq, {|x| x[1] == aVetTotal[nX][7] } ) ) == 0
			aAdd( aHrsBloq, { aVetTotal[nX][7], 0 } )
			nPosFunc := Len(aHrsBloq)
		Endif
		aHrsBloq[nPosFunc][2] := SomaHoras( aHrsBloq[nPosFunc][2], aVetTotal[nX][2] ) //Incrementa a quantidade de horas bloqueadas para o funcionario

		dbSelectArea(cTRB9051)
		dbSkip()
	Next nX

Return .T.
//---------------------------------------------------------------------
/*/{Protheus.doc} fEnvMail 
Função de envio de e-mail do relatorio
@author Antonio Domingos
@since 18/05/2022
@version undefined
@type Static Function
/*/
Static Function fEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cPass        := Alltrim(GetMV("MV_RELPSW"))
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .F.
 
    //Se tiver em branco o destinatário, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
 
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
 
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
 
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
 
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
 
            //Senao, acrescenta no log
            Else
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
 
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
 
        //Define se irá utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
 
        //Inicializa conexão
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
 
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
            EndIf
 
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
 
            If lRet
                //Realiza a autenticação do usuário e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
 
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
 
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
 
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        cLog := "fEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao - " + FunName() + CRLF + CRLF +;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog
        ConOut(cLog)
 
        //Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
 
    RestArea(aArea)
Return lRet
