#include "protheus.ch"
#include "topconn.ch"
#Include "Tbiconn.ch"

// Facility
#define FAC_FRAME_ 22
#define FAC_SEGMENTS_ 23

// Severity
#define SEV_EMG_ 0
#define SEV_ALERT_ 1
#define SEV_CRITICAL_ 2
#define SEV_ERROR_ 3
#define SEV_WARN_ 4
#define SEV_NOTICE_ 5
#define SEV_INFORM_ 6
#define SEV_DEBUG_ 7

/*/{Protheus.doc} User Function ADLFV010P
	Gera PV de complemento de frango vivo.
	Chamado 037729
	@type  Function
	@author Fernando Macieira 
	@since 04/16/2018
	@version 01
	@history Adriana, 24/05/2019, TI-Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Everson, 06/08/2020, Chamado TI. Alterado relatório excel para utilizar a função FWMSEXCEL.
	@history Sigoli , 05/10/2021, Ticket 52836. Removido LockByName das rotinas de scheduleds
	@history Sigoli , 14/10/2021, Ticket T.I  . Alterado a forma, de receber o lAuto para tomada de decisção (JoB ou Tela)
	@history Ticket: 62540 - 18/10/2021 - Adriano Savoine - Ajustado a entrada da Variavel e alterada a mesma apos entrar no IF devido que por padrão estava dando erro pois o TIPO é C e está entrando String.
	@history Ticket: 62540 - 20/10/2021 - Fernando Sigoli - VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
	@history Ticket: 62976 - 28/10/2021 - Fernando Sigoli - Substituido criatrab por FWTemporaryTable na função CriaTMP
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial
	@history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
	@history ticket 71972 - Fernando Macieira - 04/05/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
	@history ticket 73501 - Fernando Macieira - 24/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO
	@history ticket 73655 - Fernando Macieira - 26/05/2022 - PEDIDO VENDA COMPLEMENTO FRANGO VIVO - NÃO FOI GERADO
	@history ticket 73501 - Fernando Macieira - 27/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO - SELECT * FROM SCHDTSK WHERE TSK_ROTINA LIKE '%ADLFV010%'
	@history ticket 76964 - Fernando Macieira - 01/08/2022 - Pedido Complemento Filial 0A - Continuação do Ticket 74568
/*/
User Function ADLFV010P()

	Local lOk		:= .F.
	Local alSay		:= {}
	Local alButton	:= {}
	Local clTitulo	:= 'Complemento Frango Vivo'
	Local clDesc1   := ''
	Local clDesc2   := 'O objetivo desta rotina é gerar um PV de complemento de frango vivo nas granjas.'
	Local clDesc3   := 'Importante:'
	Local clDesc4   := '- Granjas 03 (São Carlos) e 0A (HH)'
	Local clDesc5   := ''
	Local aGranjas  := {}
	Local i

	Private cRootPath
	
	//@history ticket 73655 - Fernando Macieira - 26/05/2022 - PEDIDO VENDA COMPLEMENTO FRANGO VIVO - NÃO FOI GERADO
	Private lAuto := .f.
	Private cForGranjas := "03|0A"
	Private cFilGranja  := ""
	//

	//Ticket: 62540 - 20/10/2021 - Fernando Sigoli  - VERIFICA SE ESTA RODANDO VIA MENU OU SCHEDULE
	If Select("SX6") == 0
		lAuto := .T.
	EndIf
	
	If lAuto

		// Inicializa ambiente
		RpcClearEnv()
		RpcSetType(3)
		If !rpcSetEnv("01", "02",,,,,{"SM0"})
			//ConOut(	"[ADLFV010P] - JOB - NAO FOI POSSIVEL INICIALIZAR O AMBIENTE 01/03 !!! ")
			LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - NAO FOI POSSIVEL INICIALIZAR O AMBIENTE') // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial
			Return .F.
		EndIf

		// @history ticket 73501 - Fernando Macieira - 27/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO - SELECT * FROM SCHDTSK WHERE TSK_ROTINA LIKE '%ADLFV010%'
		// Garanto uma única thread sendo executada
		If !LockByName("ADLFV010P", .T., .F.)
			ConOut("[ADLFV010P] - Existe outro processamento sendo executado! Verifique...")
			RPCClearEnv()
			Return
		Else
			Sleep( 30000 ) // Segura o processamento por 30 segundos
		EndIf
		//
		
		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Complemento Frango Vivo')
		
		// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
		//FWMonitorMsg(ALLTRIM(PROCNAME()))

		//@history ticket 73655 - Fernando Macieira - 26/05/2022 - PEDIDO VENDA COMPLEMENTO FRANGO VIVO - NÃO FOI GERADO
		cForGranjas := GetMV("MV_#GRANJA",,"03|0A")
		aGranjas := Separa(cForGranjas,"|")

		For i:=1 to Len(aGranjas)
			cFilGranja := aGranjas[i]
			GeraPV(lAuto, cFilGranja)
		Next i
		//

	Else

		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Complemento Frango Vivo')

		// Mensagens de Tela Inicial
		AADD(alSay, clDesc1)
		AADD(alSay, clDesc2)
		AADD(alSay, clDesc3)
		AADD(alSay, clDesc4)
		AADD(alSay, clDesc5)
		
		// Botoes do Formatch
		AADD(alButton, {1, .T., {|| lOk := .T., FechaBatch()}})
		AADD(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})
		
		FormBatch(clTitulo, alSay, alButton)
		
		If lOk

			// @history Ticket 76964 - Fernando Macieira - 27/07/2022 - Pedido Complemento Filial 0A - Continuação do Ticket 74568
			cForGranjas := GetMV("MV_#GRANJA",,"03|0A")
			aGranjas := Separa(cForGranjas,"|")

			For i:=1 to Len(aGranjas)
				cFilGranja := aGranjas[i]
				Processa( { || GeraPV(lAuto, cFilGranja) }, "Gerando PV na granja " + cFilGranja)
				//GeraPV(lAuto, cFilGranja)
			Next i

			/*
			cFilGranja := cFilAnt
			Processa( { || GeraPV(lAuto, cFilGranja) }, "Gerando PV..." )
			*/

		EndIf

	EndIf

	If lAuto

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//³Destrava a rotina para o usuário	    ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		UnLockByName("ADLFV010P") // @history ticket 73501 - Fernando Macieira - 27/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO

		//Fecha o ambiente.
		RpcClearEnv()

	EndIf
	
Return

/*/{Protheus.doc} GeraPV 
	@type  Static Function
	@author Microsiga 
	@since 04/16/2018
	@version 01
/*/
Static Function GeraPV(lAuto, cFilGranja)

	Local aAreaAtu := GetArea()
	Local cFunBkp  := FunName()

	Local aCabec  := {}
	Local cCliCod := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj := GetMV("MV_#LFVLOJ",,"00")
	Local cProdPV := GetMV("MV_#LFVPRD",,"300042")   // --------- VOLTAR ESTA LINHA ANTES DE PUBLICAR EM PRD
	Local nPrcPV  := GetMV("MV_#LFVPRC",,2)
	Local cTESPV  := GetMV("MV_#LFVTES",,"701")
	Local lPVExist := .f.

	Private cNumPV  := ""
	Private cFilPV  := cFilGranja // GetMV("MV_#LFVFIL",,"03") // @history ticket 71972 - Fernando Macieira - 04/05/2022 - Complemento Frango Vivo - Granja HH - Filial 0A

	// Emails
	Private cMails  := GetMV("MV_#LFVMAI",,"faturamento@adoro.com.br;cleber.santos@adoro.com.br;danielle.meira@adoro.com.br;glean.rocha@adoro.com.br;reinaldo.francischinelli@adoro.com.br") // -------- VOLTAR ESTA LINHA ANTES DE PUBLICAR EM PRD
	Private cDescri := "PEDIDO VENDA COMPLEMENTO FRANGO VIVO"

	// Variaveis trocadas com a funcao u_AD0143
	Private cNFNot := ""
	Private nTtPLO := 0
	Private cSql   := ""                        
	Private nTtPLP := 0
	Private lMsErroAuto := .F.
	Private cArquivo
	Private oFuDimep
	Private cFilOrig // @history ticket 71972 - Fernando Macieira - 28/04/2022 - Complemento Frango Vivo - Granja HH - Filial 0A
	Private cFilUpd := "" // @history ticket 76964 - Fernando Macieira - 01/08/2022 - Pedido Complemento Filial 0A - Continuação do Ticket 74568

	// @history ticket 73501 - Fernando Macieira - 24/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO
	If lAuto
		lPVExist := ExistPVDay()
		If lPVExist
			//gera log
			u_GrLogZBE(msDate(), TIME(), cUserName, "PV COMPLEMENTO FRANGO VIVO","CONTROLADORIA","ADLFV010P",;
			"JA EXISTE PV GERADO NESTA DATA PARA ESTA FILIAL/GRANJA " + DtoC(msDate()) + " - " + cFilPV, ComputerName(), LogUserName())
			Return
		EndIf
	EndIf
	//

	//Cria arq tmp
	CriaTMP()

	// Chama relatório de relação diária ordem de carregamento do frango vivo
	//u_AD0143(@cNFNot, @nTtPLO, @cSql, @nTtPLP, lAuto, cFilGranja)
	u_AD0143(@cNFNot, @nTtPLO, @cSql, @nTtPLP, lAuto, cFilGranja, @cFilUpd) // @history ticket 76964 - Fernando Macieira - 01/08/2022 - Pedido Complemento Filial 0A - Continuação do Ticket 74568

	// Efetua cálculo da DIFERENCA para gerar o PV
	nQtdPV := (nTtPLO - nTtPLP)
	
	// Aborta processamento pois o PV já foi gerado com os registros selecionados
	If nQtdPV <= 0
		
		// Aviso ao usuario
		If lAuto
			//ApMsgStop( '[ADLFV010P] - JOB - Não existem dados com os filtros utilizados para a geração do PV !!! ' )
			//ConOut(	"[ADLFV010P] - JOB - Não existem dados com os filtros utilizados para a geração do PV !!! ")
			LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - NAO existem dados com os filtros utilizados para a geracao do PV') // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial

		Else
			Aviso(	"ADLFV010P-02",;
			"Não existem dados com os filtros utilizados para a geração do PV na filial " + cFilPV + chr(13) + chr(10) +  chr(13) + chr(10)+;
			"Verifique se o pedido de venda de complemento de frango vivo já foi gerado através do campo ZV1_FLAGPV no cadastro de frango vivo... "  + chr(13) + chr(10) +;
			"" ,;
			{ "&OK" },,;
			"PV - Complemento Frango Vivo - Filial " + cFilPV )
		EndIf
				
		Return
		
	EndIf

	// Backup filial ativa
	cFilBkp := cFilAnt

	// Seto filial na qual será incluído o PV
	cFilAnt := cFilPV 

	// Gera o PV
	dbSelectArea("SC5")
	cNumPV := GetSx8Num("SC5","C5_NUM") // numero do pedido
	ConfirmSX8(.T.)

	SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_FILIAL
	SA1->( dbSeek(xFilial("SA1")+cCliCod+cCliLoj) )

	SB1->( dbSetOrder(1) ) // B1_FILIAL + B1_COD
	SB1->( dbSeek(xFilial("SB1")+cProdPV) )

	// Cabecalho do PV
	Aadd(aCabec,{"C5_FILIAL"   ,cFilPV        ,Nil})
	Aadd(aCabec,{"C5_NUM"      ,cNumPV        ,Nil})
	Aadd(aCabec,{"C5_TIPO"     ,"N"           ,Nil})
	Aadd(aCabec,{"C5_CLIENTE"  ,cCliCod       ,Nil})
	Aadd(aCabec,{"C5_LOJACLI"  ,cCliLoj       ,Nil})
	Aadd(aCabec,{"C5_VEND1"    ,SA1->A1_VEND  ,Nil})
	Aadd(aCabec,{"C5_DTENTR"   ,(msDate()+1)  ,Nil})
	Aadd(aCabec,{"C5_MOEDA"    ,1             ,Nil})

	// Item do PV
	aItem  := {}
	aItens := {}

	nVlTot := Round(Round(nQtdPV,TamSX3("C6_QTDVEN")[2]) * Round(nPrcPV,TamSX3("C6_PRCVEN")[2]),TamSX3("C6_VALOR")[2])

	Aadd(aItem,{"C6_FILIAL" , cFilPV                                    , Nil})
	Aadd(aItem,{"C6_ITEM"   , "01"                                      , Nil })
	Aadd(aItem,{"C6_PRODUTO", cProdPV                                   , Nil })
	Aadd(aItem,{"C6_UNSVEN" , Round(nQtdPV,TamSX3("C6_UNSVEN")[2])  ,0  , Nil })
	Aadd(aItem,{"C6_PRCVEN" , Round(nPrcPV,TamSX3("C6_PRCVEN")[2])  ,0  , Nil })
	Aadd(aItem,{"C6_VALOR"  , nVlTot                                ,0  , Nil })
	Aadd(aItem,{"C6_QTDVEN" , Round(nQtdPV,TamSX3("C6_QTDVEN")[2])  ,0  , Nil })
	Aadd(aItem,{"C6_TES"    , cTESPV                                    , Nil })
	Aadd(aItem,{"C6_QTDLIB" , Round(nQtdPV,TamSX3("C6_QTDLIB")[2])  ,0  , Nil })

	aAdd(aItens,aItem)

	//Ordena os campos conforme dicionário de dados.
	aCabec := FWVetByDic(aCabec,"SC5",.F.,1)
	aItens := FWVetByDic(aItens,"SC6",.T.,1)


	BEGIN TRANSACTION

	lMsHelpAuto := .F.
	lMsErroAuto := .F.

	//dbSelectArea("SC6")
	//msExecAuto({|x,y,z| Mata410(x,y,z) }, aCabec, aItens, 3)
	MATA410(aCabec,aItens,3)

	If lMsErroAuto
		
		If !lAuto
			MostraErro()
		EndIf
		
		DisarmTransaction()
		RollBackSxe()
		
	Else

		// @history ticket 73501 - Fernando Macieira - 24/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO
		//gera log
		u_GrLogZBE(msDate(), TIME(), cUserName, "PV COMPLEMENTO FRANGO VIVO","CONTROLADORIA","ADLFV010P",;
		"GEROU PV N " + cNumPV + " NESTA DATA PARA ESTA GRANJA(FILIAL) " + DtoC(msDate()) + " - " + cFilPV, ComputerName(), LogUserName())
		//

		// Atualizo com o número do PV gerado os regitros utilizados para composição do mesmo visando impedir a geração de duplicidade
		cFiltro := ""
		cFiltro2 := "" // @history ticket 76964 - Fernando Macieira - 01/08/2022 - Pedido Complemento Filial 0A - Continuação do Ticket 74568
		If !Empty(cNFNot)
			cNFNotQry := ""
			cNFNotQry := Left(AllTrim(cNFNot),Len(cNFNot)-1)
		
			cFiltro := " AND ZV1_NUMNFS NOT IN " + FormatIn(cNFNotQry,"|")
		EndIf
		
		cUpd    := " UPDATE " + RetSqlName("ZV1") + " SET ZV1_FLAGPV = '"+cNumPV+"' "
		
		// @history ticket 76964 - Fernando Macieira - 01/08/2022 - Pedido Complemento Filial 0A - Continuação do Ticket 74568
		If !Empty(cFilUpd)
			cFilUpd := Left(AllTrim(cFilUpd),Len(cFilUpd)-1)
			cFiltro2 := " AND ZV1_NUMOC IN " + FormatIn(cFilUpd,"|")
		EndIf
		//
											
		If !Empty(cFiltro) .or. !Empty(cFiltro2)
			cSql := cUpd + Subs(cSql, At("FROM", cSql)-1, Len(cSql)) + cFiltro + cFiltro2
		Else
			cSql := cUpd + Subs(cSql, At("FROM", cSql)-1, Len(cSql))
		EndIf
		
		TCSQLEXEC(cSql)
		
	EndIf

	END TRANSACTION

	// restauro filial
	cFilAnt := cFilBkp


	If !lmsErroAuto
		
		// Atualizo campo C5_XLFVCMP C(1) ' Ped Venda Compl F.V     
		If SC5->(FieldPos("C5_XLFVCMP")) > 0

			SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM                                                                                                                                                
			If SC5->( dbSeek(cFilPV+cNumPV) )
				RecLock("SC5", .f.)
					C5_XLFVCMP := "S"
				SC5->( msUnLock() )
			EndIf		

		EndIf		

		// Aviso ao usuario
		If lAuto
			//ApMsgStop( "[ADLFV010P] - JOB - PV n. " + AllTrim(cNumPV) + " incluído com sucesso! ")
			//ConOut(	"[ADLFV010P] - JOB - PV n. " + AllTrim(cNumPV) + " incluído com sucesso! " )
			LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - PV n. " + AllTrim(cNumPV) + " incluido com sucesso') // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial

		Else
		
			Aviso(	"ADLFV010P-01",;
			"PV n. " + AllTrim(cNumPV) + " incluído com sucesso! " + chr(13) + chr(10) +  chr(13) + chr(10)+;
			"Filial: " + cFilPV + chr(13) + chr(10) +;                                                                                                              
			"" ,;
			{ "&OK" },,;
			"PV - Complemento Frango Vivo" )
		EndIf
			
		// Grava Num PV
		GrvPV()

		// Gero XLS para envio no anexo do email
		GeraXLS()
		
		// Enviar email
		EmailFVL(lAuto)
		
	EndIf

	If ValType(oFuDimep) <> "U"
		oFuDimep:delete()
	EndIf 

	SetFunName(cFunBkp)
	RestArea(aAreaAtu)

Return

/*/{Protheus.doc} EmailFVL 
	Envia email com dados do PV Complemento Frango Vivo 
	@type  Static Function
	@author Fernando Macieira 
	@since 04/18/2018
	@version 01
/*/
Static Function EmailFVL(lAuto)

	LogZBN("1")
	ProcRel(lAuto)
	LogZBN("2")

Return

/*/{Protheus.doc} EmailFVL 
	Gera log na ZBN.
	@type  Static Function
	@author Fernando Sigoli 
	@since 04/18/2018
	@version 01
/*/
Static Function logZBN(cStatus)

	Local aArea	:= GetArea()
	Local cNomeRotina := "ADLFV010P"

	DbSelectArea("ZBN")
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop())
	If ZBN->(DbSeek(xFilial("ZBN") + cNomeRotina))
		
		RecLock("ZBN",.F.)
		
		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= cNomeRotina
		ZBN_DESCRI  := cDescri
		ZBN_STATUS	:= cStatus
		
		MsUnlock()
		
	Else
		
		RecLock("ZBN",.T.)
		
		ZBN_FILIAL  := xFilial("ZBN")
		ZBN_DATA    := Date()
		ZBN_HORA    := cValToChar(Time())
		ZBN_ROTINA	:= cNomeRotina
		ZBN_DESCRI  := cDescri
		ZBN_STATUS	:= cStatus
		
		MsUnlock()
		
	EndIf

	ZBN->(dbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} EmailFVL 
	Gera relatório.
	@type  Static Function
	@author Fernando Sigoli 
	@since 29/03/2018
	@version 01
/*/
Static Function procRel(lAuto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cAssunto	:= cDescri
	Local cMensagem	:= ""
	Local cQuery	:= ""

	//
	cQuery := ScriptSQL()

	//
	If Select("DADOS") > 0
		DADOS->(DbCloseArea())
	EndIf

	//
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cDescri)+'</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '<td>Filial</td>'
	cMensagem += '<td>Pedido Venda</td>'
	cMensagem += '<td>Cliente</td>'
	cMensagem += '<td>Loja</td>'
	cMensagem += '<td>Nome</td>'
	cMensagem += '<td>Produto</td>'
	cMensagem += '<td>Descrição</td>'
	cMensagem += '<td>Quantidade</td>'
	cMensagem += '<td>Preço Unitário</td>'
	cMensagem += '<td>Valor Total</td>'
	cMensagem += '<td>Almoxarifado</td>'
	cMensagem += '<td>TES</td>'
	cMensagem += '<td>Data Emissao</td>'
	cMensagem += '<td>Data Entrega</td>'
	cMensagem += '<td>Usuário/Login</td>'
	cMensagem += '</tr>'

	TcQuery cQuery New Alias "DADOS"
	DbSelectArea("DADOS")
	DADOS->(DbGoTop())

	While ! DADOS->(Eof())
		
		//	cQuery += "  C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C6_PRODUTO, C6_DESCRI, C6_UNSVEN, C6_PRCVEN, C6_VALOR, C6_TES, C6_LOCAL, CONVERT(VARCHAR(10),CAST(C6_ENTREG AS DATE),103) AS C6_ENTREG "
		
		cMensagem += '<tr>'
		cMensagem += '<td>' + cValToChar(DADOS->C5_FILIAL)    + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C5_NUM)       + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C5_CLIENTE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C5_LOJACLI)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C5_NOMECLI)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C6_PRODUTO)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C6_DESCRI)    + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->C6_UNSVEN,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->C6_PRCVEN,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->C6_VALOR,"@E 999,999,999.99"))   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C6_LOCAL)     + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C6_TES)       + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C5_EMISSAO)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->C6_ENTREG)    + '</td>'
		cMensagem += '<td>' + cValToChar(cUserName)           + '</td>'
		
		cMensagem += '</tr>'
		
		DADOS->(DbSkip())
		
	EndDo

	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'

	DADOS->(DbCloseArea())

	// Envia no corpo do email as NFs de saída não encontradas
	If !Empty(cNFNot)                                         
		cMsgNFNot := "NOTAS FISCAIS SAÍDAS NÃO ENCONTRADAS/CONSIDERADAS NOS CÁLCULOS"
		
		cMensagem += '</tr>'
		cMensagem += '</tr>'
		cMensagem += '<html>'
		cMensagem += '<body>'
		cMensagem += '<p style="color:red">'+cValToChar(cMsgNFNot)+'</p>'
		cMensagem += '<hr>'

		cMensagem += '</tr>'
		cMensagem += '<td>' + cValToChar(cNFNot)    + '</td>'
		cMensagem += '</tr>'

		cMensagem += '</table>'
		cMensagem += '</body>'
		cMensagem += '</html>'
	EndIf


	//
	ProcessarEmail(cAssunto,cMensagem,cMails,lAuto)

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} EmailFVL 
	Script sql.
	@type  Static Function
	@author Fernando Sigoli 
	@since 29/03/2018
	@version 01
	/*/
Static Function ScriptSQL()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cQuery	:= ""

	cQuery := " "
	cQuery += "  SELECT "
	cQuery += "  C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C6_PRODUTO, C6_DESCRI, C6_UNSVEN, C6_PRCVEN, C6_VALOR, C6_TES, C6_LOCAL, CONVERT(VARCHAR(10),CAST(C6_ENTREG AS DATE),103) AS C6_ENTREG, CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO "
	cQuery += "  FROM " + RetSqlName("SC5") + " SC5 WITH (NOLOCK), " + RetSqlName("SC6") + " SC6 WITH (NOLOCK) "
	cQuery += "  WHERE C5_FILIAL=C6_FILIAL "
	cQuery += "  AND C5_NUM=C6_NUM "
	cQuery += "  AND C5_FILIAL='"+cFilPV+"' "
	cQuery += "  AND C5_NUM='"+cNumPV+"' "
	cQuery += "  AND SC5.D_E_L_E_T_ = '' "
	cQuery += "  AND SC6.D_E_L_E_T_ = '' "

	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} ProcessarEmail 
	Configurações de e-mail. 
	@type  Static Function
	@author Fernando Sigoli 
	@since 29/03/2018
	@version 01
	/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email,lAuto)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := "\LFV\LFV.XML" //Everson - 06/08/2020. Chamado 060221.
	//Local cAtach        := cRootPath+"\LFV\LFV.XML"
	Local cSubject      := ""

	//Assunto do e-mail.
	cSubject := cAssunto

	// Anexo
	StrTran( cAtach, "\\", "\" )

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

	//
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
			
		Else
			lAutOk := .T.
			
		EndIf
		
	EndIf

	//
	If lOk .And. lAutOk
		
		//Envia o e-mail.
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		
		//Tratamento de erro no envio do e-mail.
		If !lOk
			Get Mail Error cErrorMsg
			//ConOut("3 - " + cErrorMsg)
			LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - ' + cErrorMsg) // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial
		
		Else

			// Aviso ao usuario
			If lAuto
				/*
				ApMsgStop( "[ADLFV010P] - JOB - Email enviado com sucesso!"  + cMails )
				ConOut(	"[ADLFV010P] - JOB - Email enviado com sucesso!"  + cMails )
				*/
				LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - Email enviado com sucesso'  + cMails) // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial
			
			Else
				Aviso(	"ADLFV010P-03",;
				"Email enviado com sucesso!"  + chr(13) + chr(10)+;
				"Emails: "  + Left(cMails,66) + chr(13) + chr(10) +;
				"" + Subs(cMails,67,Len(cMails)),;
				{ "&OK" },3,;
				"PV - Complemento Frango Vivo" )
			EndIf
		
		EndIf
		
	Else
		Get Mail Error cErrorMsg
		//ConOut("4 - " + cErrorMsg)
		LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - ' + cErrorMsg) // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial
		
	EndIf

	If lOk
		Disconnect Smtp Server
		
	EndIf

	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} CriaTMP 
	@type  Static Function
	@author Microsiga 
	@since 04/23/2018
	@version 01
/*/
Static Function CriaTMP()

	Local aAreaAtu  := GetArea()
	Local aStru		:= {}
	
	cArquivo := "TMPTRC"

	// //@history ticket 73655 - Fernando Macieira - 26/05/2022 - PEDIDO VENDA COMPLEMENTO FRANGO VIVO - NÃO FOI GERADO
	If Select(cArquivo) > 0
		(cArquivo)->( dbCloseArea() )
	EndIf
	//

	//Ticket: 62976 - 28/10/2021 - Fernando Sigoli - Substituido criatrab por FWTemporaryTable na função CriaTMP
	oFuDimep := FWTemporaryTable():New(cArquivo)

	aStru := {	{"PEDIDO"	   , "C", TamSX3("C6_NUM")[1],      0},;
				{"ORDEMCARGA"  , "C", TamSX3("ZV1_NUMOC")[1],   0},;
				{"DATA_ABATE"  , "C", 10,                       0},;
				{"PL_ORIGEM"   , "N", TamSX3("ZV1_RPESOT")[1],  TamSX3("ZV1_RPESOT")[2]},;
				{"NF"          , "C", TamSX3("ZV1_NUMNFS")[1],  0},;
				{"SERIE"       , "C", TamSX3("ZV1_SERIE")[1],   0},;
				{"QTD_NF"      , "N", TamSX3("D2_QUANT")[1],    TamSX3("D2_QUANT")[2]},;
				{"NF_NAOENCO"  , "C", TamSX3("D2_DOC")[1],      0 } }

	oFuDimep:SetFields(aStru)
	oFuDimep:AddIndex("01", {"PEDIDO"})

	//
	oFuDimep:Create()
	DbSelectArea(cArquivo) 

	RestArea( aAreaAtu )

Return
/*/{Protheus.doc} GeraXLS 

	@type  Static Function
	@author Microsiga 
	@since 04/23/2018
	@version 01
	/*/
Static Function GeraXLS()

	Local oExcel 	:= FWMSEXCEL():New() //Everson - 06/08/2020. Chamado 060221.

	cIniFile   := GetAdv97()
	cRootPath  := GetPvProfString(GetEnvServer(),"RootPath","ERROR", cIniFile )
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )

	// RETIRA "\\"
	cRootPath  := StrTran( cRootPath, "\\", "\" )
	cStartPath := StrTran( cStartPath, "\\", "\" )

	cPathData := cRootPath+"\LFV\"
	cPath     := cRootPath + cStartPath

	If !ExistDir(cPathData)
		MakeDir(cPathData)
	EndIf

	If !ExistDir(cPath+"\LFV\")
		MakeDir(cPath)
	EndIf

	//
	fErase( cPath+"LFV\LFV.XML" )
	fErase( cRootPath+"\LFV\LFV.XML" )
	fErase( cPath+"LFV.XML" )
	fErase("\LFV\LFV.XML")

	//Everson - 06/08/2020. Chamado 060221.
	oExcel:AddworkSheet("LFV")
	oExcel:AddTable ("LFV","LFV - FATURAMENTO")
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","PEDIDO",3,1)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","ORDEMCARGA",3,1)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","DATA_ABATE",3,1)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","PL_ORIGEM",3,2)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","NF",3,1)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","SERIE",3,1)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","QTD_NF",3,2)
	oExcel:AddColumn("LFV","LFV - FATURAMENTO","NF_NAOENCO",3,1)

	//
	dbSelectArea(cArquivo)
	(cArquivo)->(DbGoTop())
	While ! (cArquivo)->(Eof())
		//conout( (cArquivo)->PEDIDO + " " + (cArquivo)->NF )
		LogMsg('ADLFV010P', FAC_FRAME_, SEV_NOTICE_, 1, '', '', '[ADLFV010P] - JOB - ' + (cArquivo)->PEDIDO + " " + (cArquivo)->NF) // @history Ticket: 69945 - 25/03/2022 - Fernan Macieira - Tratamento da setagem da empresa/filial
		//
		oExcel:AddRow("LFV","LFV - FATURAMENTO",{(cArquivo)->PEDIDO,;
												 (cArquivo)->ORDEMCARGA,;
												 (cArquivo)->DATA_ABATE,;
												 (cArquivo)->PL_ORIGEM,;
												 (cArquivo)->NF,;
												 (cArquivo)->SERIE,;
												 (cArquivo)->QTD_NF,;
												 (cArquivo)->NF_NAOENCO;
												 })

		//
		(cArquivo)->(DbSkip())

	End

	//
	oExcel:Activate()
	oExcel:GetXMLFile("\LFV\LFV.XML")

	//
	FreeObj(oExcel)
	oExcel := Nil

	// Copio arquivo tmp para pasta LFV abaixo do rootpath já renomeando
	//__CopyFile(cPath+cArquivo+GetDBExtension(), cRootPath+"\LFV\LFV.XLS" )  
	//__CopyFile(cStartPath+cArquivo+GetDBExtension(), "\LFV\LFV.XLS" )
	//fRename( cPath+cArquivo+GetDBExtension(), cPath+"LFV.XLS" )

	//fRename( cPath+cArquivo+GetDBExtension(), cPath+"LFV.XLS" )
	//__CopyFile(cPath+"LFV.XLS", cRootPath+"\LFV\LFV.XLS" )


	dbSelectArea(cArquivo)
	(cArquivo)->( dbCloseArea() )

Return
/*/{Protheus.doc} GrvPV 

	@type  Static Function
	@author Microsiga 
	@since 04/23/2018
	@version 01
	/*/
Static Function GrvPV()

	Local aAreaAtu  := GetArea()

				
	(cArquivo)->( dbGoTop() )
	Do While (cArquivo)->( !EOF() )

		If Empty((cArquivo)->NF_NAOENCO)
		
			RecLock(cArquivo, .f.)                                                               
				(cArquivo)->PEDIDO := cNumPV
				
				If Empty((cArquivo)->DATA_ABATE)
					(cArquivo)->DATA_ABATE := dDtAbate
				Else
					dDtAbate := (cArquivo)->DATA_ABATE
				EndIf
				
			(cArquivo)->( msUnLock() )
			
		EndIf
		
		(cArquivo)->( dbSkip() )
		
	EndDo

	RestArea( aAreaAtu )

Return

/*/{Protheus.doc} nomeStaticFunction
	Checa se existe PV de Complemento de Frango no mesmo dia
	@type  Static Function
	@author FWNWM
	@since 24/05/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 73501 - Fernando Macieira - 24/05/2022 - DUPLICIDADE NO PEDIDO DE COMPLEMENTO DE FRANGO VIVO
/*/
Static Function ExistPVDay()

	Local lRet := .f.
	Local cQuery  := ""

	Local cCliCod := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj := GetMV("MV_#LFVLOJ",,"00")
	Local cProdPV := GetMV("MV_#LFVPRD",,"300042") 
	Local cTESPV  := GetMV("MV_#LFVTES",,"701")

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT
	cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL=C6_FILIAL AND C5_NUM=C6_NUM AND C5_XLFVCMP='S' AND SC5.D_E_L_E_T_=''
	cQuery += " WHERE C6_FILIAL='"+cFilPV+"'
	cQuery += " AND C6_PRODUTO='"+cProdPV+"'
	cQuery += " AND C6_TES='"+cTESPV+"'
	cQuery += " AND SC6.D_E_L_E_T_=''
	cQuery += " AND C5_CLIENTE='"+cCliCod+"'
	cQuery += " AND C5_LOJACLI='"+cCliLoj+"'
	cQuery += " AND C5_EMISSAO='"+DtoS(msDate())+"' 

	tcQuery cQuery new Alias "Work"

	Work->( dbGoTop() )
	If Work->TT >= 1
		lRet := .t.
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
Return lRet
