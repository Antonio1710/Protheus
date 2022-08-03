#include 'rwmake.ch'
#include 'protheus.ch'   
#include "AP5MAIL.CH"
#include "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE 'Parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "MSMGADD.CH"  
#INCLUDE "FWBROWSE.CH"   
#INCLUDE "DBINFO.CH"
#INCLUDE 'FILEIO.CH'
  
Static cTitulo      := "Bloqueio de clientes"

/*/{Protheus.doc} User Function HCFU001
	Rotina para selecionar e permitir ao usuário efetuar      
	bloqueio de uma faixa de clientes escolhidos via parâmetro.
	@type  Function
	@author HC CONSYS 
	@since 28/04/2009
	@version 01
	@history Adriana, 24/05/2019, TI-Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM.
	@history Adriano S., 05/08/2019, Ajustado para enviar email pelo parametro FS_MOVMAIL
	@history Everson, 16/06/2020, Chamado 058848 - Incluido o total de pedidos pendentes que o cliente possui.
	@history chamado 050729  - FWNM         - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history Everson, 29/07/2020, Chamado 060134 - Tratamento para não bloquear cliente com pedido em aberto.
	@history Everson, 03/12/2020, Chamado 6009 - Correção de validação de bloqueio de cliente com pedido em aberto.
	@history Ticket 74275  - Everson, 14/06/2022, tratamento para bloqueio de cliente a partir do número de pedidos em aberto.
	@history Ticket 77222 - Everson, 03/08/2022 - Tratamento para a rotina de bloqueio verificar se há pedido em aberto em todas a filiais.
/*/
User Function HCFU001()  // U_HCFU001()

	Private lOk        := .T.
	Private lInverte   :=.F., oDlg
	Private inclui     := .T.,nOpca:=0
	Private cCadastro  :=""
	Private cMarca     := GetMark()
	Private nTipo      := 2
	Private cPerg      :=PADR("HCF001",10," ")
	Private oExcelApp                   && Objeto para abrir Excel

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para selecionar e permitir ao usuário efetuar bloqueio de uma faixa de clientes escolhidos via parâmetro.')


	//Everson - 03/08/2022. Chamado 77222.
	If Alltrim(cValToChar(RetSqlName("SA1"))) == "SA1010" .And. cEmpAnt <> "01"
		Alert("Bloqueio de clientes da Ad'oro somente pode ser realizado na empresa 01.")
		return

	EndIf
	//
	
	validPerg()

	if !pergunte(cPerg,.T.)
		return
	else
		//------------------------------------------------
		// Executa query conforme parametros selecionados
		//------------------------------------------------
		Processa({|| bloqCli()})
		//--------------------------------------------------
		// Cria arquivo temporario com os clientes
		// a serem bloqueados pelo usuário conf. consulta
		//---------------------------------------------------
		MsAguarde({|| criatemp() },"Função HCFU001(HCFU001)","Criando arquivo temporário...") //Everson, 16/06/2020, Chamado 058848.
		dbSelectArea("BLQCLI")
		dbCloseArea()
		//--------------------------------------------------
		// Chama função para abrir janela de seleção dos
		// clientes para bloqueio...
		//---------------------------------------------------
		if seleciona()
			//if !msgBox("Confirma efetivar o bloqueio dos clientes selecionados ? ","Bloqueio de Clientes","YESNO")
			//	dbSelectArea("TR1")
			//	dbCloseArea()
			//	return
			//endif
		else
			dbSelectArea("TR1")
			dbCloseArea()
			return
		endif
	endif


	//------------------------------------------------
	// Inicio do procedimento para bloqueio de
	// clientes selecionados
	//------------------------------------------------
	dbSelectArea("TR1")
	dbgotop()
	nTotMark:=contaCli(.F.)
	if nTotMark < 1
		msgBox("Nenhum cliente selecionado para bloqueio. Selecione ao menos 1 cliente!")
		dbSelectArea("TR1")
		dbCloseArea()
		return
	else
		if !msgBox("Confirma efetivar o bloqueio dos clientes selecionados ? "+chr(10)+chr(13)+chr(13)+chr(10)+;
		"Total de Clientes selecionados para bloqueio:  "+str(nTotMark,5,0),"Bloqueio de Clientes","YESNO")
			dbSelectArea("TR1")
			dbCloseArea()
			return
		else
			Processa({|| bloqCli2()})
		endif
	endif

	//--------------------------
	// Fecha arquivo trabalho
	//--------------------------
	dbSelectArea("TR1")
	dbCloseArea()

Return
/*/{Protheus.doc} criaTemp
	Cria arquivo temporário.
	@type  Static Function
	@author 
	@since
	@version 01
	/*/
Static Function criaTemp()

	//Variáveis.
	Local nNumPed	:= 0 //Everson - 16/06/2020. Chamado 058848.

	aCpos:= {{'OK'         ,"C",02,0 },;
	{'A1_COD'     ,"C",06,0},;
	{'A1_LOJA'    ,"C",02,0},;
	{'A1_NOME'    ,"C",40,0},;
	{'A1_MUN'     ,"C",15,0},;
	{'A1_EST'     ,"C",02,0},;
	{'A1_VEND'    ,"C",06,0},;
	{'A1_SATIV1'  ,"C",15,0},;
	{'A1_LC'      ,"N",12,2},;
	{'A1_DTREAT'  ,"D",08,0},;
	{'A1_DTCAD'   ,"D",08,0},;
	{'A1_ULTCOM'  ,"D",08,0},;
	{'NUM_PED'    ,"N",4,0}} //Everson - 16/06/2020. Chamado 058848.

	cNomeArq := CriaTrab(aCpos)
	
	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
	//dbUseArea( .T.,"DBFCDXADS" , cNomeArq             , "TR1")
	dbUseArea( .T.,, cNomeArq             , "TR1") 
	
	dbSelectArea("BLQCLI")
	dbgotop()
	do while !eof()
		dbSelectArea("TR1")
		recLock("TR1",.T.)
		replace TR1->OK        WITH cMarca
		REPLACE TR1->A1_COD    WITH BLQCLI->A1_COD
		REPLACE TR1->A1_LOJA   WITH BLQCLI->A1_LOJA
		REPLACE TR1->A1_NOME   WITH BLQCLI->A1_NOME
		REPLACE TR1->A1_MUN    WITH BLQCLI->A1_MUN
		REPLACE TR1->A1_EST    WITH BLQCLI->A1_EST
		REPLACE TR1->A1_VEND   WITH BLQCLI->A1_VEND
		REPLACE TR1->A1_LC     WITH BLQCLI->A1_LC 
		REPLACE TR1->A1_SATIV1 WITH POSICIONE("SX5",1,XFILIAL("SX5")+"87"+BLQCLI->A1_SATIV1,"ALLTRIM(X5_DESCRI)") 
		REPLACE TR1->A1_DTREAT WITH STOD(BLQCLI->A1_DTREAT)
		REPLACE TR1->A1_DTCAD  WITH STOD(BLQCLI->A1_DTCAD)
		REPLACE TR1->A1_ULTCOM WITH STOD(BLQCLI->A1_ULTCOM)
		REPLACE TR1->NUM_PED   WITH BLQCLI->C5_NUMPED //Everson - 16/06/2020. Chamado 058848.
		msUnlock()
		dbSelectArea("BLQCLI")
		dbSkip()
	enddo

Return
/*/{Protheus.doc} criaTemp
	Funcao para consultar via Query
	cliente para bloqueio.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function BLOQCLI()

	Local cQry      := ""
	Local lRet      := .F.
	Local cDivVend  := ""
	Local cDias     := cValToChar(GetMv("MV_#DIABLQ",,10)) //Everson - 14/06/2022. Tratamento para bloqueio de clientes.

	//-------------------------------------------
	// Monta condicao para filtro dos vendedores
	//-------------------------------------------
	mv_par02:=alltrim(mv_par02)
	if !empty(mv_par02)
		For nS:=1 to Len(ALLTRIM(mv_par02)) STEP 7
			cDIVvend  += "'"+Subs(mv_par02,nS,6)+"'"
			If ( nS+6) <= Len(ALLTRIM(mv_par02))
				cDIVvend  += Subs(mv_par02,7,1)
			Endif
		Next nS
	endif
	//-------------------------------------
	// Monta Query
	//-------------------------------------
	cQry+= " SELECT "+RetSqlName("SA1")+ ".A1_COD , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_LOJA , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_NOME , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_MUN  , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_EST  , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_VEND , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_SATIV1 , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_LC  , " 
	cQry+= " "+RetSqlName("SA1")+ ".A1_DTREAT , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_DTCAD , "
	cQry+= " "+RetSqlName("SA1")+ ".A1_ULTCOM,  PEDIDOS.C5_NUMPED  "
	cQry+= " FROM " + RETSQLNAME("SA1") + " "+RetSqlName("SA1")+ " "

	//Everson, 16/06/2020, Chamado 058848.
	cQry += " LEFT OUTER JOIN "
	cQry += " ( "
	cQry += " SELECT " 
	cQry += " C5_CLIENTE, C5_LOJACLI, COUNT(DISTINCT C5_NUM) AS C5_NUMPED " 
	cQry += " FROM " 
	cQry += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQry += " WHERE " 

	//cQry += " C5_FILIAL = '" + FWxFilial("SC5") + "' " //Everson - 03/08/2022. Chamado 77222. Removido o filtro por filial, pois o cliente não pode ter pedido em aberto em nenhuma filial.
	// cQry += " AND SC5.D_E_L_E_T_ = '' " 
	
	cQry += " SC5.D_E_L_E_T_ = '' " 
	cQry += " AND C5_NOTA = '' " 
	cQry += " AND C5_SERIE = '' "

	cQry += " AND CAST(C5_DTENTR AS DATE) >= CAST(GETDATE() - " + cDias + " AS DATE) " //Everson - 14/06/2022. Tratamento para bloqueio de clientes.

	cQry += " GROUP BY  C5_CLIENTE, C5_LOJACLI "
	cQry+= " ) AS PEDIDOS ON A1_COD = PEDIDOS.C5_CLIENTE AND A1_LOJA = PEDIDOS.C5_LOJACLI "
	//

	cQry+= " WHERE ("+RetSqlName("SA1")+ ".A1_DTREAT<='"+dtos(mv_par01)+"' )" // And SA1010.A1_DTREAT<>'' ) " retirado para atender consulta do reginaldo em 01/06
	cQry+= "   AND ("+RetSqlName("SA1")+ ".A1_DTCAD <='"+dtos(mv_par01)+"' )" // And SA1010.A1_DTCAD<>''  ) "retirado para atender consulta do reginaldo em 01/06
	cQry+= "   AND ("+RetSqlName("SA1")+ ".A1_ULTCOM<='"+dtos(mv_par01)+"') "
	if !empty(mv_par02)
		cQry+= "   AND "+RetSqlName("SA1")+ ".A1_VEND NOT IN (" + cDivVend + ") "
	endif
	cQry+= "   AND ("+RetSqlName("SA1")+ ".A1_COD<>'"+GETMV("MV_INUTCLI",.F.,"017040")+"') "    //Nao pode bloquear cliente de Inutilizacao NF - Incluido por Adriana em 10/07/2014
	cQry+= "   AND ("+RetSqlName("SA1")+ ".A1_MSBLQL<>'1') "
	cQry+= "   AND ("+RetSqlName("SA1")+ ".D_E_L_E_T_='') "
	cQry+= " ORDER BY "+RetSqlName("SA1")+ ".A1_COD , "+RetSqlName("SA1")+ ".A1_LOJA "

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"BLQCLI", .F., .T.)

	dbSelectArea("BLQCLI")
	count to totReg

	if totReg > 0
		lRet := .T.
	else
		lRet := .F.
	endif

Return(lRet)
/*/{Protheus.doc} criaTemp
	Função para abrir janela de seleção dos
	clientes para bloqueio.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function seleciona()

	LOCAL oDlg,oUsado,nUsado:=0
	LOCAL aSize := MsAdvSize()
	LOCAL aObjects := {}
	Local aButtons		:= { {"NOTE",{ || contaCli(.T.) },"Contar Registros","Contar" }}

	Aadd(aButtons,{"PMSEXCEL" ,{|| EXPEXCEL()  }           , "Exporta dados da tela para Excel" , "Excel" })


	AAdd( aObjects, { 100, 100, .T., .T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aObj  := MsObjSize( aInfo, aObjects, .T. )

	aCampos := { {"OK"  ,"A126Marca","Bloquear" },;
	{"A1_COD","A126Marca","Código"},;
	{'A1_LOJA'     ,, 'Loja'       ,'@!'},;
	{'A1_NOME'     ,, 'Nome'       ,'@!'},;
	{'A1_MUN'      ,, 'Município'  ,'@!'},;
	{'A1_EST'      ,, 'UF'         ,'@!'},;
	{'A1_VEND'     ,, 'Vendedor'   ,'@!'},;
	{'A1_SATIV1'   ,, 'Segmento'   ,'@!'},;
	{'A1_DTCAD'    ,, 'Dt.Cadastro'   ,''},;
	{'A1_DTREAT'   ,, 'Dt.Reativação' ,''},;
	{'A1_ULTCOM'   ,, 'Última Compra' ,''},;
	{'A1_LC'       ,, 'Limite Crédito','@R 999,999,999.99'},;
	{'NUM_PED'     ,, 'Pedidos em aberto','@R 9,999'}} //Everson - 16/06/2020. Chamado 058848.

	dbSelectArea("TR1")
	dbGotop()
	If BOF() .and. EOF()
		HELP(" ",1,"RECNO")
		Return
	Else
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Bloqueio de Clientes") From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		cAlias:=Alias()
		oMark := MsSelect():New(cAlias,"OK",,aCampos,linverte,cMarca,aObj[1])
		oMark:oBrowse:lCanAllMark:=.T.
		oMark:oBrowse:lHasMark	 :=.T.
		oMark:bMark 			 := {| | U_HC01ESCOL(cMarca,lInverte,oDlg)}
		oMark:oBrowse:bAllMark	 := {| | U_HC01MarkAll(cMarca,oDlg)}
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(.T.,oDlg:End(),)},{||nopca:=0,oDlg:End()},,aButtons)
		if nopca = 1
			return(.T.)
		else
			return(.F.)
		endif
	EndIf

Return
/*/{Protheus.doc} User Function HC01Escol
	(long_description)
	@type  Function
	@author 
	@since 
	@version 01
	/*/
User Function HC01Escol(cMarca,lInverte,oDlg)

	U_ADINF009P('HCFU001' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para selecionar e permitir ao usuário efetuar bloqueio de uma faixa de clientes escolhidos via parâmetro.')

	iF IsMark("OK",cMarca,lInverte)
		RecLock("TR1",.F.)
		If !lInverte
			Replace TR1->OK   With cMarca
		Else
			Replace TR1->OK   With "  "
		Endif
		MsUnlock()
	Else
		RecLock("TR1",.F.)
		If !lInverte
			Replace TR1->OK   With "  "
		Else
			Replace TR1->OK   With cMarca
		Endif
		MsUnlock()
	Endif
	oDlg:Refresh()
Return .T.
/*/{Protheus.doc} User Function HC01MarkAll
	(long_description)
	@type  Function
	@author 
	@since 
	@version 01
	/*/
User Function HC01MarkAll(cMarca,oDlg)

	LOCAL nRecno:=Recno()

	U_ADINF009P('HCFU001' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para selecionar e permitir ao usuário efetuar bloqueio de uma faixa de clientes escolhidos via parâmetro.')

	dbGotop()
	Do While !Eof()
		RecLock("TR1",.F.)
		If Empty(TR1->OK)
			Replace TR1->OK   With cMarca
		Else
			Replace TR1->OK   With "  "
		Endif
		MsUnlock()
		dbSkip()
	EndDo
	dbGoto(nRecno)
	oDlg:Refresh()

Return .T.
/*/{Protheus.doc} ValidPerg
	(long_description)
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function ValidPerg
	//*-----------------------------------------------------*
	PutSx1(cPerg,"01","Bloq. c/ Ultimo  Movimento ate"    , "Bloq. c/ Data Movimento ate"    , "Bloq. c/ Data Movimento ate"    , "mv_ch1","D",8 ,0,0,"G","","   ","","","mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"02","Descons.Vendedores  :"    , "Descons.Vendedores  :"    , "Descons.Vendedores  :"    , "mv_ch2","C",50,0,0,"G","","SA3","","","mv_par02","","","","","","","","","","","","","","","","")
Return
/*/{Protheus.doc} contaCli
	Funcao para retornar o
	total de clientes selecionados.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function contaCli(lMostraResul)

	Local nTot := 0

	dbSelectArea("TR1")
	dbgotop()
	do while !eof()
		if !empty(TR1->OK)
			nTot++
		endif
		dbSkip()
	enddo
	dbGotop()
	if lMostraResul
		msgBox("Total de Clientes Selecionados: " + str(nTot,5,0),"Total","INFO")
	endif

Return(nTot)
/*/{Protheus.doc} bloqCli2
	Funcao para gravar o codigo de
	bloqueio no campo do cadastro de clientes.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function bloqCli2()

	Local cPb3_cod  := ""
	Local cPb3_Loja := ""
	Local cClienteSF:= ""

	dbSelectArea("TR1")
	dbGotop()
	do while !eof()
		//- Se item nao selecionado
		//- nao bloqueia cliente
		If Empty(TR1->OK)
			dbSkip()
			loop
		else

			//Everson - 03/12/2020. Chamado 6009.
			If TR1->NUM_PED <= 0

				dbSelectArea("SA1")
				dbSetOrder(1)
				if dbSeek(xFilial("SA1")+TR1->A1_COD+TR1->A1_LOJA)
					recLock("SA1",.F.)
					replace SA1->A1_MSBLQL with "1"
					replace SA1->A1_ATIVO  with "N"
					msUnLock()
					
					cClienteSF += "'" + Alltrim(cValToChar(TR1->A1_COD)) + Alltrim(cValToChar(TR1->A1_LOJA)) + "',"
					
				endif

			EndIf
			//

			If Alltrim(cEmpAnt) == "01" && apenas para a empresa 01, entrar na PB3  Chamado: 034630

				//faz o bloqueio na PB3 e Gravação do log 
				//inicio - Chamado 029995 sigoli 06/09/2016
				DbSelectArea( 'PB3' )
				PB3->( dbSetOrder(11))
				If PB3->(dbSeek( xFilial( 'PB3' )+TR1->A1_COD+TR1->A1_LOJA))

					//Everson - 29/07/2020. Chamado 060134.
					If TR1->NUM_PED <= 0

						//Grava LOG  
						U_Ado05Log( PB3_COD, PB3_LOJA, alltrim(cusername), dDataBase, Posicione('SX3', 2, 'PB3_BLOQUE', 'X3_Titulo' ),'Desbloqueado','Bloqueado' )
						U_Ado05Log( PB3_COD, PB3_LOJA, alltrim(cusername), dDataBase, Posicione('SX3', 2, 'PB3_MOTBLQ', 'X3_Titulo' ), PB3->PB3_MOTBLQ," BLOQUEADO PELA ROTINA AUTOMATICA, S/ UTILIZAÇÃO A 6 MESES")

						cPb3_cod  := PB3_COD
						cPb3_loja := PB3_LOJA

						RecLock( 'PB3', .F. )
						PB3->PB3_BLOQUE 	:= '1'
						PB3->PB3_MOTBLQ  	:= "BLOQUEADO PELA ROTINA AUTOMATICA, S/ UTILIZAÇÃO A 6 MESES"
						PB3->PB3_SITUAC		:= '3'
						PB3->( MsUnLock())

						//Grava Ocorrencia no parecer do Cliente
						DbSelectArea( 'PBA' )
						RecLock( 'PBA', .T. )
						PBA_FILIAL	:= xFilial('PBA')
						PBA_CODCLI	:= cPb3_cod
						PBA_LOJACL	:= cPb3_loja
						PBA_NIVEL	:= '1'
						PBA_USUARI	:= __cUserId
						PBA_NOME	:= GetAdvFval( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
						PBA_DATA	:= dDatabase
						PBA_HORA	:= TIME()
						MSMM(,TamSx3("PBA_PARECE")[1],,"BLOQUEADO PELA ROTINA AUTOMATICA, CLIENTE SEM UTILIZAÇÃO A MAIS DE 6 MESES",1,,,"PBA","PBA_CODMEM")
						PBA->( MsUnLock())

					EndIf

					//enviar email informando o bloqueio         
					EnviaEmail(TR1->A1_COD,TR1->A1_LOJA,TR1->A1_VEND,TR1->NUM_PED) //Everson, 16/06/2020, Chamado 058848.

				EndIF	
				//fim - Chamado 029995 Sigoli 06/09/2016  

			EndIf

		Endif
		dbSelectArea("TR1")
		dbSkip()
	enddo
	
	//Everson - 05/03/2018. Chamado 037261. SalesForce.
	If !Empty(cClienteSF) .And. FindFunction("U_ADVEN076P")
		cClienteSF := Substr(cClienteSF,1,Len(cClienteSF)-1)

		U_ADVEN076P("","",.F., " AND (RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA))) IN (" + cClienteSF + ") ","BLQFN",.T.," BLOQUEADO PELA ROTINA AUTOMATICA, CLIENTE SEM UTILIZAÇÃO A MAIS DE 6 MESES ")
		cClienteSF := ""

	EndIf

	msgBox("Processo Finalizado.","Finalizado.","INFO")

Return
/*/{Protheus.doc} ExpExcel
	Funcao para exportar dados do aCols para Excel.
	@type  Static Function
	@author 
	@since 
	@version 01
/*/
Static Function ExpExcel()

    // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 25/06/2020
	Local oExcel    := FWMsExcelEx():New()
    Local nLinha    := 0
    Local nExcel    := 1

    Private aLinhas   := {}

	if !msgBox("Confirma exportar os dados para o Ms-Excel ? ","Exportar Excel...","YESNO") 
		return 
	endif 

	dbSelectArea("TR1")
	dbGotop()

	cDirDocs := MsDocPath()
	cPath    := AllTrim(GetTempPath())

	//cArq:="\HCFU001"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".DBF"
	cArq:="\HCFU001"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".XLS"
	_cCamin:=cDirDocs+cArq

    // Cabecalho Excel
    oExcel:AddworkSheet(cArq)
	oExcel:AddTable (cArq,cTitulo)
    oExcel:AddColumn(cArq,cTitulo,"OK"            ,1,1) // 01 A
	oExcel:AddColumn(cArq,cTitulo,"A1_COD"        ,1,1) // 02 B
	oExcel:AddColumn(cArq,cTitulo,"A1_LOJA"       ,1,1) // 03 C
	oExcel:AddColumn(cArq,cTitulo,"A1_NOME"       ,1,1) // 04 D
	oExcel:AddColumn(cArq,cTitulo,"A1_MUN"        ,1,1) // 05 E
	oExcel:AddColumn(cArq,cTitulo,"A1_EST"        ,1,1) // 06 F
	oExcel:AddColumn(cArq,cTitulo,"A1_VEND"       ,1,1) // 07 G
	oExcel:AddColumn(cArq,cTitulo,"A1_SATIV1"     ,1,1) // 08 H
	oExcel:AddColumn(cArq,cTitulo,"A1_LC"         ,1,1) // 09 I
	oExcel:AddColumn(cArq,cTitulo,"A1_DTREAT"     ,1,1) // 10 I
	oExcel:AddColumn(cArq,cTitulo,"A1_DTCAD"      ,1,1) // 11 I
	oExcel:AddColumn(cArq,cTitulo,"A1_ULTCOM"     ,1,1) // 12 I

    // Gera Excel
    TR1->( dbGoTop() )
    Do While TR1->( !EOF() )

    	nLinha++

	   	aAdd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               ""  ; // 09 I  
	   	                   })

		aLinhas[nLinha][01] := TR1->OK
		aLinhas[nLinha][02] := TR1->A1_COD
		aLinhas[nLinha][03] := TR1->A1_LOJA
		aLinhas[nLinha][04] := TR1->A1_NOME
		aLinhas[nLinha][05] := TR1->A1_MUN
		aLinhas[nLinha][06] := TR1->A1_EST
		aLinhas[nLinha][07] := TR1->A1_VEND
		aLinhas[nLinha][08] := TR1->A1_SATIV1
		aLinhas[nLinha][09] := TR1->A1_LC
		aLinhas[nLinha][10] := TR1->A1_DTREAT
		aLinhas[nLinha][11] := TR1->A1_DTCAD
		aLinhas[nLinha][12] := TR1->A1_ULTCOM

        TR1->( dbSkip() )

    EndDo

	// IMPRIME LINHA NO EXCEL
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArq,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08],; // 08 H  
	                                     aLinhas[nExcel][09],; // 08 H  
	                                     aLinhas[nExcel][10],; // 08 H  
	                                     aLinhas[nExcel][11],; // 08 H  
	                                     aLinhas[nExcel][12] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)

	/*
	COPY TO &_cCamin VIA "DBFCDXADS"
	CpyS2T(_cCamin, cPath, .T. )
	*/

	//------------------------------
	// Abre MS-EXCEL
	//------------------------------
	If ! ApOleClient( 'MsExcel' )
		MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
		Return
	EndIf

	oExcelApp:= MsExcel():New()  //Objeto para abrir Excel.
	oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

	dbSelectArea("TR1")
	dbGoTop()

Return

/*/{Protheus.doc} EnviaEmail
	Monta email de cliente bloqueado, enviado para representante e supervisor
	@type  Static Function
	@author 
	@since 
	@version 01
/*/
Static Function EnviaEmail(cCodcli, cLojaCli,cCodVend,nNPedAb) //Everson, 16/06/2020, Chamado 058848.
			
	Local cNomeUsr	:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
	Local cPara		:= SuperGetMv("FS_MOVMAIL", .F., 0 ) // Ajustado por Adriano Savoine 05/08/2019 para entrar no parametro 
	Local cMotivo	:= "BLOQUEADO PELA ROTINA AUTOMATICA, CLIENTE SEM UTILIZAÇÃO A MAIS DE 6 MESES"
	Local cCC		:= Alltrim(Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_EMAIL")) //email representante  

	//buscar email do  Supervisor
	cSuperv    := Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_CODSUP") 
	cSupUsu    := Posicione("SZR",1,xFilial("SZR")+cSuperv,"ZR_USER")  
	cEmaiSup   := Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL") 

	if !Empty(cEmaiSup)
		cCC := cCC+";"+Alltrim(cEmaiSup)
	EndIF

	DbSelectArea( 'SA1' )
	SA1->( dbSetOrder( 1 ))
	If SA1->( dbSeek( xFilial( 'SA1' ) + cCodCli + cLojaCli ))

		cMensagem := "Codigo          : "+ SA1->A1_COD+chr(13) + chr(10)
		cMensagem += "Loja            : "+ SA1->A1_LOJA+chr(13) + chr(10)
		cMensagem += "Cliente         : "+ SA1->A1_NOME+chr(13) + chr(10)
		cMensagem += "CNPJ/CPF        : "+ Transform(SA1->A1_CGC,U_Pic(SA1->A1_PESSOA))+chr(13) + chr(10)
		cMensagem += "Vendedor        : "+ cCodVend+" - "+Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_NOME")+chr(13) + chr(10)
		cMensagem += "Limite Aprov.   : "+ Alltrim(Transform(SA1->A1_LC,"@E 999,999,999.99"))+chr(13) + chr(10)
		cMensagem += "Prazo           : "+ SA1->A1_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+SA1->A1_COND, 1)+chr(13) + chr(10)
		cMensagem += "Motivo Bloqueio : "+ cMotivo+chr(13) + chr(10)

		//Everson - 29/07/2020. Chamado 060134.
		If nNPedAb > 0
			cMensagem += " *** CLIENTE NÃO BLOQUEADO *** POSSUI PEDIDO(S) EM ABERTO *** " +chr(13) + chr(10)
			cMensagem += "Pedidos em aberto : "+ cValToChar(nNPedAb) +chr(13) + chr(10) //Everson, 16/06/2020, Chamado 058848.

		EndIf
		//

		cMensagem += "Análise realizada por :"+cNomeUsr+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)
		NewMail(cPara, 'Cliente Bloqueado', cMensagem, ,cCC, .F., .F., cCodcli, cLojaCli)

	Endif    

Return nil

/*/{Protheus.doc} NewMail
	Faz o envio do e-mail.
	@type  Static Function
	@author VogasJunior
	@since 22/09/2009
	@version 01
/*/
Static Function NewMail(cPara, cAssunto, cMsg, cDe, cCC, lAnexo, lParecer, cCodCli, cLojaCli )

	Local aArea		 :=  GetArea()
	Local lResulConn := .T.
	Local lResulSend := .T.
	Local cError     := ''
	Local cServer    := Trim( GetMV('MV_RELSERV') ) //'smtp.adoro.com.br' // smtp.ig.com.br ou 200.181.100.51
	Local cEmail     := Trim( GetMV('MV_RELACNT') ) // fulano@ig.com.br
	Local cPass      := Trim( GetMV('MV_RELPSW') )  // 123abc
	Local lRet       := .T.
	Local cUser      := ''
	Local lAutentica := .F.
	Local cParecer	 := ''
	Local cAnexo	 := ''
	//Local cNivel	 := Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NIVEL')
	Local cNivel	 := GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)
	Local cFileLog 	 := Criatrab(,.f.)+".TXT"
	Local cFOpen	 := ''
	Local nOpcao 	 := 0
	Local i			 := 0
	Local aArquivos	 := {}
	Local aArq2		 := {}
	Local cCaminho	 := ''
	Local nPosicao	 := 0
	Local oDlgDoc	 := Nil
	Local oListBox	 := Nil
	Local cRootPath  := AllTrim( GetSrvProfString( "RootPath", "\" ) )
	Local cStartPath := AllTrim( GetSrvProfString( "StartPath", "\" ) )
	Local nPos       := 0
	Local lTemAnexo	 := .F.
	Local oTik		 := LoadBitMap(GetResources(), 'LBTIK')
	Local oNo		 := LoadBitMap(GetResources(), 'LBNO' )
	Local cPathEst   := "C:\TEMP"
	Local aAnexos	 := {}
	//Local cNomeUsr 		:= Posicione( 'PB1', 1, xFilial( 'PB1' ) + __cUserId, 'PB1_NOME')
	Local cNomeUsr 		:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)

	Default cMsg     := ''
	Default cCodCli  := Space(6)
	Private nLastKey := 0

	If Empty( cServer ) .AND. Empty( cEmail ) .AND. Empty( cPass )
		ApMsgStop( 'Não foram definidos os parâmetros no server do Protheus para envio de e-mail', cAssunto )
		Return .F.
	Endif

	If lAnexo

		dbSelectArea("PB3")
		PB3->( dbSetOrder(1))
		PB3->( dbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))

		cDirServer := Alltrim(GetPvProfString(GetEnvServer(),"Rootpath","",GetADV97())) + "\Anexos" //GetMv("AC_DIRANEX",,"chamados\")

		if Right(cDirServer,1) <> "\"
			cDirServer += "\"
		endif

		cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
		if !lIsDir(cDirServer)
			makeDir(cDirServer)
		endif

		// verifica se cliente já possui diretório
		cDirServer += ( StrZero( Val( alltrim(cCodCli)), 6 ) + cLojaCli + "\")
		cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
		if lIsDir(cDirServer)
			lTemAnexo:= .T.
		endif

		if Right(cPathEst,1) <> "\"
			cPathEst += "\"
		endif

		nPos := 1
		nPos1 := 1
		cdirTemp := ""

		While .t.
			nPos := at("\", substr(cPathEst,nPos1))
			if nPos > 3
				cDirTemp := substr(cPathEst,1, nPos1+nPos-1)
				if !lIsDir(cDirTemp)
					makeDir(cDirTemp)
				endif
			Endif
			nPos1 := nPos1+npos
			if nPos1 >= len(cPathEst)
				exit
			Endif
		Enddo

		cAnexFile 	:= StrZero( Val( AllTrim( cCodCli )), 6 ) + cLojaCli  + ".XLS"
		nPos 		:= rat(".", cAnexFile)
		cExtens 	:= ""
		if Len(Dtoc(dDataBase)) = 8
			cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 7, 2 )
		else
			cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 9, 2 )
		endif
		if nPos>0
			cExtens := substr(cAnexFile, nPos+1)
		Endif

		If lTemAnexo

			// apaga arquivos que estejam na maquina do usuario
			If File( cPathEst + cAnexFile )
				Ferase( cPathEst + cAnexFile )
			EndIf

			cFileOrig := cDirServer //+cAnexFile
			// pega os arquivos do cliente
			aAnexos := Directory( /*cRootPath + */cDirServer + '*.*', '')
			If Empty( aAnexos )
				Alert( 'Não existem anexos para o cliente selecionado')
			Else
				// monta array com as informacoes que serao exibidas em tela Nome arquivo, data que foi inserido, usuario que inseriu
				for i:= 1 to len( aAnexos )
					aAnexos[ i, 2 ] := 	aAnexos[ i, 1 ]
					aAnexos[ i, 1 ] := .F.
					aAnexos[ i, 3 ] := CtoD( SubStr( aAnexos[ i, 2 ], 9, 2 ) + '/' + SubStr( aAnexos[ i, 2 ], 11, 2 ) + '/' + SubStr( aAnexos[ i, 2 ], 13, 2 ) )
					//				aAnexos[ i, 4 ] := Posicione( 'PB1',1,xFilial('PB1') + Substr(aAnexos[ i, 2 ], 21, 6 ),'PB1_NOME')
					aAnexos[ i, 4 ] := GetAdvFVal( 'PB1', 'PB1_NOME',xFilial('PB1') + Substr(aAnexos[ i, 2 ], 21, 6 ), 1)
				Next i

				DEFINE MSDIALOG oDlgDoc TITLE "Seleção de Anexos" FROM 10,10 To 400,/*397*/470 OF oMainWnd PIXEL

				@ 000,000 Say 'SELECIONE O ARQUIVO QUE DESEJA VISUALIZAR' SIZE 200,15 OF oDlgDoc PIXEL CENTERED
				@ 020,007 ListBox oListBox Fields HEADER " ","Arquivo", "Data", "Usuário";
				Size 220 , 170 Of oDlgDoc Pixel ColSizes 25,100,50,50;
				On DBLCLICK (aAnexos[oListBox:nAt,1] := !aAnexos[oListBox:nAt,1] , oListBox:Refresh())
				oListBox:SetArray(aAnexos)
				oListBox:bLine := {|| {If( aAnexos[oListBox:nAT,01], oTIK, oNO ),aAnexos[oListBox:nAT,02],aAnexos[oListBox:nAT,03],aAnexos[oListBox:nAT,04]}}

				ACTIVATE MSDIALOG oDlgDoc CENTERED ON INIT EnchoiceBar(oDlgDoc,{||nOpcao:= 1,oDlgDoc:End()},{||nOpcao:=0,oDlgDoc:End()})
			Endif
		Endif

		// Selecao de arquivos em qqer diretorio
		/*	While nOpcao == 0
		//cFOpen += cGetFile('Todos os Arquivos  (*.*)   | *.*     ','Seleção de Arquivo',1,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD ) 	//+ '; '
		aAdd( aArquivos, cGetFile('Todos os Arquivos  (*.*)   | *.*     ','Seleção de Arquivo',1,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD ))
		If ! msgYesNo( 'Deseja Incluir Novo Arquivo?')
		nOpcao := 1
		EndIf
		//	Enddo		*/
		If nOpcao == 1 .And. !Empty( aAnexos )
			For i:= 1 to len( aAnexos )
				If aAnexos[ i, 1 ]
					aAdd(aArquivos, aAnexos[ i, 2 ] )
				Endif
			Next i

			//copia dos arquivos selecionados para o system
			If !Empty( aArquivos )
				//			cCaminho := MontaDir(cStartPath+'\Anexos\')
				For i := 1 to Len( aArquivos )

					// encontra a posicao da ultima barra
					//				nPosicao := Rat( '\', aArquivos[i] )
					// extrai apenas o nome do arquivo
					cFOpen:= Right( aArquivos[i], ( Len( aArquivos[i] ) - nPosicao ) )
					// copia o arquivo para o caminho desejado
					//				__copyfile( aArquivos[i] , cStartPath+'\Anexos\' + cFOpen )
					// alimenta array com os nomes de arquivo
					//				aAdd( aArq2, cFOpen )
					//cAnexo += cStartPath+'\Anexos\' + cFOpen + '; '
					cAnexo += cDirServer + cFOpen + ';'
					//cFOpen+= Right( aArquivos[i], ( Len( aArquivos[i] ) - nPosicao ) ) + '; '
				Next i
			Endif
		Endif
	Endif

	// Deseja enviar os pareceres por anexo
	If lParecer
		cParecer := AdoGetHist( cCodCli, cLojaCli, cNivel )
		MemoWrite( cFileLog, cParecer )
		//	cAnexo 	 += cStartPath+'\'+ cFileLog+ ';'
		cAnexo 	 += cStartPath+'\'+ cFileLog+ ';'
	Endif
	cAnexo := Left(cAnexo,len(cAnexo)-1)
	cDe := NIL
	cDe      := IIf( cDe == NIL, AllTrim(GetMv("MV_RELFROM")), AllTrim( cDe ) ) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	cPara    := AllTrim( cPara )
	cCC      := AllTrim( cCC )
	cAssunto := AllTrim( cAssunto )

	CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

	If !lResulConn
		GET MAIL ERROR cError
		CONOUT( 'Falha na conexão para envio de e-mail ' + cError,, .F. )

		If !IsBlind()
			ApMsgStop( 'Falha na conexão para envio de e-mail ' + cError )
		EndIf
		cNomeUsr := GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

		//Grava LOG
		U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lResulConn, "Enviado com sucesso!", "Falha de envio!"), " " )

		Return .F.
	Endif

	lAutentica:= GETMV('MV_RELAUTH')
	If lAutentica
		cUser:= GETMV('MV_RELACNT')
		cPass:= GETMV('MV_RELAPSW')
		If !MailAuth(cUser,cPass)
			Msginfo(OemToAnsi('Falha autenticacao Usuario'))
			cNomeUsr := GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

			//Grava LOG
			U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lAutentica, "Enviado com sucesso!", "Falha de envio!"), " " )
			Return .F.
		Endif
	Endif

	If Empty( cCc ) .AND.  Empty( cAnexo )
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend

	ElseIf  Empty( cCc ) .AND. !Empty( cAnexo )
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	ElseIf !Empty( cCc ) .AND.  Empty( cAnexo )
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend

	Else
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend

	Endif

	If !lResulSend
		GET MAIL ERROR cError
		lRet := .F.

		If !IsBlind()
			ApMsgStop( 'Falha no envio do e-mail (' + cError + ') ' )
		Else
			CONOUT( 'Falha no envio do e-mail (' + cError + ') ',, .F. )
		EndIf
	Endif
	cNomeUsr := GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

	//Grava LOG
	U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lResulSend, "Enviado com sucesso!", "Falha de envio!"), " " )

	DISCONNECT SMTP SERVER
	cMsg :=''

	FERASE( cFileLog )
	RestArea( aArea )

Return lRet
