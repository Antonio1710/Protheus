#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MATR110.CH"
#INCLUDE "REPORT.CH"

#DEFINE GD_INSERT	1
#DEFINE GD_DELETE	4	
#DEFINE GD_UPDATE	2

#DEFINE STR0082 "Legendas da Aprovacao :"
#DEFINE STR0060 "BLQ:Bloqueado"
#DEFINE STR0061 "Ok:Liberado"
#DEFINE STR0131 "Ok:REJEITADO"
#DEFINE STR0062 "??:Aguar.Lib"
#DEFINE STR0067 "##:Nivel Lib"
#DEFINE STR0081 "NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
#DEFINE STR0083 "NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
#DEFINE STR0125 "1- "
#DEFINE STR0126 "2- "
#DEFINE STR0127 "3- "
#DEFINE STR0128 "1, 2, 3"
#DEFINE STR0110 " "
#DEFINE STR0111 " "
#DEFINE STR0112 " "
#DEFINE STR0124 ":"
#DEFINE STR0129 " "
#DEFINE STR0130 " "
#DEFINE STR0131 " "
#DEFINE STR0132 "Por conta remetente"
#DEFINE STR0133 "Por conta destinatario"
#DEFINE STR0134 "Por Conta Terceiros"

#DEFINE  ENTER 		Chr(13)+Chr(10)

// Variaveis estaticas
Static cRotina  := "ADCOM034P"
Static cTitulo  := "Envia PC aprovado por email"
Static lAuto    := .t.

/*/{Protheus.doc} User Function ADCOM034P
    Rotina job para envio de relatório de PC aprovados aos compradores/fornecedores
    Chamada original desativada do ADOA040 devido lentidão
    @type  Function
    @author FWNM
    @since 19/12/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado TI
	@history chamado 055379 - FWNM            - 30/01/2020 - OS 056780 || SUPRIMENTOS || VICTOR || 3524 || WORKFLOW DE PEDIDOS
	@history chamado 055379 - FWNM            - 06/02/2020 - OS 057023 || SUPRIMENTOS || VICTOR || 3524 || WORKFLOW DE PEDIDOS - Nenhuma alteração no fonte foi realizada, apenas constatamos que o problema estava nos dicionários das empresas 03, 06 e 08 (falta do índice 4 tabela SCR)
	@history chamado 056899 - FWNM            - 26/03/2020 - || OS 058363 || COMPRAS || GRAZIELE_ALMEIDA || 8441 || WORKFLOW P.C
	@history chamado 056899 - FWNM            - 31/03/2020 - || OS 058363 || COMPRAS || GRAZIELE_ALMEIDA || 8441 || WORKFLOW P.C - Comentado sleep
	@history chamado 050729 - FWNM            - 30/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history Ticket  69088  - ADRIANO SAVOINE - 02/03/2022 - RETIRADO O LOCK BY NAME.
	@history Ticket  69072  - ADRIANO SAVOINE - 04/03/2022 - Ajuste na query para não pegar os pedidos gerados no SAG.
/*/
User Function ADCOM034P()

    Local cEmpPC    := "01"
    Local cDtIni    := ""
    Local cEmpRun   := ""
    Local cQuery    := ""
    Local cMailPC   := ""
    Local cMailA2   := ""
    Local cTipoPC   := ""
    Local aEmpresas := {}
    Local aParamJob := {}
	Local i         := 0

	// Inicializo ambiente
	rpcClearEnv()
	rpcSetType(3)
		
	If !rpcSetEnv(cEmpPC, "02",,,,,{"SM0"})
		ConOut( cRotina + " Não foi possível inicializar o ambiente, empresa " + cEmpPC + ", filial 02" )
		Return
	EndIf

    PtInternal( 1, cRotina + " - Inicializando ambiente da empresa código [" + cEmpAnt + "]")
        
    cDtIni  := GetMv("MV_#PCDTI",,"20200131")
    cEmpRun := GetMV("MV_#PCEMP",,"01|02|03|06|07|08|09")

	// debug
	//cDtIni  := "20200101"
	// 

	// Carrega Empresas para processamentos
	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbGoTop())
	Do While SM0->(!EOF())
		If (SM0->M0_CODIGO $ cEmpRun)
			aAdd(aEmpresas, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
		SM0->( dbSkip() )
	EndDo

    // Processa empresas
    For i:=1 to Len(aEmpresas)

		RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aEmpresas[ i,1 ] , aEmpresas[ i,2 ] )
		//Ticket  69088  - ADRIANO SAVOINE - 02/03/2022
        // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
    	 /*   If !LockByName("ADCOM034P"+cEmpAnt+cFilAnt, .T., .F.)
            ConOut("[ADCOM034P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf*/

        PtInternal( 1, cRotina + " - Inicializando ambiente da empresa/filial [" + cEmpAnt + "/" +cFilAnt + "]")

		//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina job para envio de relatório de PC aprovados aos compradores/fornecedores')

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT DISTINCT C7_FILIAL, C7_NUM "
		//cQuery := " SELECT DISTINCT TOP 10 C7_FILIAL, C7_NUM " // Chamado n. 056899 || OS 058363 || COMPRAS || GRAZIELE_ALMEIDA || 8441 || WORKFLOW P.C - FWNM - 26/03/2020
        cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK) "
        cQuery += " WHERE C7_FILIAL ='"+FWxFilial("SC7")+"' " 
        cQuery += " AND C7_EMISSAO >= '"+cDtIni+"'
        //cQuery += " AND C7_EMITIDO='' "
		cQuery += " AND C7_XEMITID = '' " // Chamado n. 055379 || OS 056780 || SUPRIMENTOS || VICTOR || 3524 || WORKFLOW DE PEDIDOS - FWNM - 30/01/2020
        cQuery += " AND C7_CONAPRO = 'L' "
		cQuery += " AND C7_CONTATO <> 'SAG' " //Ticket  69072  - ADRIANO SAVOINE - 04/03/2022
        cQuery += " AND D_E_L_E_T_ = '' "

		// DEBUG
		//cQuery += " AND C7_FILIAL='02'
		//cQuery += " AND C7_NUM='167500'
		//

        cQuery += " ORDER BY 1,2 "

        tcQuery cQuery New Alias "Work"

        Work->( dbGoTop() )
        Do While Work->( !EOF() )

            PtInternal( 1, cRotina + " - Gerando relatório PC aprovado [" + cEmpAnt + "/" +cFilAnt + " => " + Work->C7_NUM + "]")

            // Posiciono PC
            SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM
            If SC7->( dbSeek(Work->(C7_FILIAL+C7_NUM)) )

                cMailPC := AllTrim(Posicione("SY1",3,FWxFilial("SY1")+SC7->C7_USER,"Y1_EMAIL")) //UsrRetMail( SC7->C7_USER )
                cMailA2 := AllTrim(Posicione("SA2",1,FWxFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_EMAIL"))
                cTipoPC := Posicione("SCR",4,FWxFilial("SCR")+SC7->C7_NUM,"CR_TIPO")

                // debug
				//cMailPC := 'fwnmacieira@gmail.com;fernando.sigoli@adoro.com.br'
				//
				
				//Sleep( 20000 ) // Para o processamento por 20 segundos // Chamado n. 056899 || OS 058363 || COMPRAS || GRAZIELE_ALMEIDA || 8441 || WORKFLOW P.C - FWNM - 31/03/2020
				aParamJob := { cEmpAnt, cFilAnt, Work->C7_NUM, cMailA2, cMailPC, cTipoPC, SC7->(RecNo()), .T. }
                StartJob("U_ADMATR110", GetEnvServer(), .T., aParamJob)
                //u_ADMATR110(aParamJob) // debug

            EndIf

            Work->( dbSkip() )

        EndDo

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf
		
		//Ticket  69088  - ADRIANO SAVOINE - 02/03/2022
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //³Destrava a rotina para o usuário	    ?
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //UnLockByName("ADCOM034P"+cEmpAnt+cFilAnt)

		RpcClearEnv()

    Next i
    
Return 

/*/{Protheus.doc} Static Function ADMATR110
	Gera PC em PDF e envia para fornecedor e comprador
	@type  Static Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/
User Function ADMATR110(ParamIXB)

	// aParamJob := { cEmpAnt, SCR->CR_FILIAL, SCR->CR_NUM, SA2->A2_EMAIL, UsrRetMail( SC7->C7_USER ), SCR->CR_TIPO, SC7->(Recno()) }

	Local nReg      := 0
	Local nOpcX     := 1 // PC
	Local aAreaSC7  := {}

	// Chamado n. 051895 || OS 053235 || SUPRIMENTOS || LUIS || 3525 || WORKFLOW PEDIDOS - FWNM - 25/11/2019
	Local lEnvFor   := .F. // Ativa/Desativa envio para fornecedor, além do comprador
	//

	Local cEmpPC    := ParamIXB[1]
	Local cFilPC    := ParamIXB[2]
	Local cNumPC    := ParamIXB[3]
	Local cMailA2   := ParamIXB[4]
	Local cMailC7   := ParamIXB[5]
	Local cTipo     := ParamIXB[6]
	Local nRecnoC7  := ParamIXB[7]
	Local lStartJob := ParamIXB[8]

	If lStartJob 
		
		rpcClearEnv()
		rpcSetType(3)
	
		If !rpcSetEnv(cEmpPC, cFilPC, /*cUserId*/, /*cPasswd*/ , "COM")
		//If !rpcSetEnv(cEmpPC, cFilPC,,,,,{"SM0"})
			Conout("ADCOM034P - NAO FOI POSSIVEL INICIALIZAR AMBIENTE PARA ENVIAR PC POR EMAIL AO FORNECEDOR")
			Return
		EndIf

	    // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
        /*If !LockByName("ADMATR110"+cEmpAnt+cFilAnt, .T., .F.)
            ConOut("[ADMATR110] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf*/
	
	EndIf
	
	//U_ADINF009P('ADCOM034P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina job para envio de relatório de PC aprovados aos compradores/fornecedores')

	// Chamado n. 051895 || OS 053235 || SUPRIMENTOS || LUIS || 3525 || WORKFLOW PEDIDOS - FWNM - 25/11/2019
	lEnvFor  := GetMV("MV_#FORENV",,.F.) // Ativa/Desativa envio para fornecedor, além do comprador
	//

	dbSelectArea("SC7")
	dbGoTo(nRecnoC7)
	nReg  := nRecnoC7
	nOpcX := Iif(AllTrim(cTipo)=="PC",1,2)

	aAreaSC7 := SC7->( GetArea() )
	
	If !EOF()
		If AllTrim(SC7->C7_FILIAL) <> AllTrim(cFilPC) .and. AllTrim(SC7->C7_NUM) <> AllTrim(cNumPC)
			conout("----------------" )
			conout("ADCOM034P - NAO ACHOU PC " + cFilPC + cNumPC )
			Return
		EndIf
	Else
		conout("----------------" )
		conout("ADCOM034P - EOF " + SC7->C7_FILIAL + SC7->C7_NUM + STR(RECNO()) )
		Return
	EndIf
			
	conout("ADCOM034P - PC POSICIONADO: " + SC7->C7_FILIAL + SC7->C7_NUM + " " + cMailA2 + " " + cMailC7)
 
	conout("ADCOM034P - Iniciando REPORTDEF")
 
	oReport := ReportDef(nReg, nOpcx)
	//oReport:PrintDialog()

	oReport:nRemoteType := NO_REMOTE        // FORMA DE GERAÇÃO DO RELATÓRIO
	oReport:nDevice     := 8 				//8 ENVIO DE .PDF VIA E-MAIL

	// DEBUG
	//oReport:cEmail      := "fwnmacieira@gmail.com;william.costa@adoro.com.br" // DESTINATÁRIO
	//
	If lEnvFor
		oReport:cEmail      := cMailA2 + ";" + cMailC7
	else
		oReport:cEmail      := cMailC7
	EndIf
    //
	conout("ADCOM034P - Iniciando SETREPORTPORTAL " + cNumPC + " " + cMailA2 + " " + cMailC7)

	//oReport:SetReportPortal("cRptPortal") // DEFINE O NOME DO RELATÓRIO
	//oReport:SetReportPortal(AllTrim("PC_APROVADO_"+cNumPC)) // DEFINE O NOME DO RELATÓRIO
	
	// Chamado n. 056899 || OS 058363 || COMPRAS || GRAZIELE_ALMEIDA || 8441 || WORKFLOW P.C - FWNM - 26/03/2020
	cNomArq := "PC_"+AllTrim(cNumPC)+"_"+AllTrim(cEmpAnt)+"_"+AllTrim(cFilAnt)+"_"+StrTran(Time(),":","")
	oReport:SetReportPortal(cNomArq) // DEFINE O NOME DO RELATÓRIO
	//

	oReport:Print()
	//oReport:Finish()
	
	RestArea( aAreaSC7 )

	// Chamado n. 051895 || OS 053235 || SUPRIMENTOS || LUIS || 3525 || WORKFLOW PEDIDOS - FWNM - 25/11/2019
	dbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
		Replace ZBE_DATA 	   	WITH msDate()
		Replace ZBE_HORA 	   	WITH TIME()
		Replace ZBE_USUARI	    WITH SCR->CR_USER
		Replace ZBE_LOG	        WITH ("ADCOM034P -" + " Filial : " + cFilPC  + " PC : " + AllTrim(cNumPC) + " Variavel: " + 'L, - Emails enviados: ' + Iif(lEnvFor, cMailA2 + ";" + cMailC7, cMailC7) )
		Replace ZBE_MODULO	    WITH "COMPRAS"
		Replace ZBE_ROTINA	    WITH cRotina
	MsUnlock() 
	ZBE->(dbCloseArea())

	conout("ADCOM034P - ZBE Gravado " + cEmpPC + cFilPC + cNumPC + ' Emails enviados: ' + Iif(lEnvFor, cMailA2 + ";" + cMailC7, cMailC7))
	//

	If lStartJob

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //³Destrava a rotina para o usuário	    ?
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
        //UnLockByName("ADMATR110"+cEmpAnt+cFilAnt)

		rpcClearEnv() // ENCERRRA AMBIENTE

	EndIf

Return

/*/{Protheus.doc} Static Function REPORTDEF
	Relatorio TREPORT
	@type  Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/
Static Function ReportDef(nReg,nOpcx)

	Local cTitle     := AllTrim(SM0->M0_NOME) + " - " + AllTrim(SM0->M0_FILIAL) + " - Pedidos de Compras n. " + SC7->C7_NUM
	Local nTamCdProd := TamSX3("C7_PRODUTO")[1]
	Local oReport
	Local oSection1
	Local oSection2
	
	If Type("lAuto") == "U"
		lAuto := (nReg!=Nil)
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01               Do Pedido                             ³
	//³ mv_par02               Ate o Pedido                          ³
	//³ mv_par03               A partir da data de emissao           ³
	//³ mv_par04               Ate a data de emissao                 ³
	//³ mv_par05               Somente os Novos                      ³
	//³ mv_par06               Campo Descricao do Produto    	     ³
	//³ mv_par07               Unidade de Medida:Primaria ou Secund. ³
	//³ mv_par08               Imprime ? Pedido Compra ou Aut. Entreg³
	//³ mv_par09               Numero de vias                        ³
	//³ mv_par10               Pedidos ? Liberados Bloqueados Ambos  ³
	//³ mv_par11               Impr. SC's Firmes, Previstas ou Ambas ³
	//³ mv_par12               Qual a Moeda ?                        ³
	//³ mv_par13               Endereco de Entrega                   ³
	//³ mv_par14               todas ou em aberto ou atendidos       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MTR110",.F.)
	
	MV_PAR01 := SC7->C7_NUM
	MV_PAR02 := SC7->C7_NUM
	MV_PAR03 := CtoD(DtoC(SC7->C7_EMISSAO))
	MV_PAR04 := CtoD(DtoC(SC7->C7_EMISSAO))
	MV_PAR05 := 2
	MV_PAR06 := ""
	MV_PAR07 := 1
	MV_PAR08 := 1
	MV_PAR09 := 1
	MV_PAR10 := 1 // LIBERADOS
	MV_PAR11 := 3
	MV_PAR12 := SC7->C7_MOEDA // 1 // Chamado n. 054308 || OS 055703 || SUPRIMENTOS || RACHEL || 1621063514 || PEDIDO DE COMPRA - FWNM - 19/12/2019
	MV_PAR13 := ""
	MV_PAR14 := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= TReport():New("MATR110",cTitle,"MTR110", {|oReport| ReportPrint(oReport,nReg,nOpcx)},STR0001+" "+STR0002)
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:HideHeader()
	oReport:HideFooter()
	oReport:SetTotalInLine(.F.)
	oReport:DisableOrientation()
	oReport:ParamReadOnly(lAuto)
	oSection1:= TRSection():New(oReport,STR0102,{"SC7","SM0","SA2"}, /* <aOrder> */ ,;
									 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
									 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
									 .T./* <.lLineStyle.>  */, /* <nColSpace>  */,.T. /*<.lAutoSize.> */, /*<cSeparator> */,;
									 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	oSection1:SetReadOnly()
	oSection1:SetNoFilter("SA2")
	
	TRCell():New(oSection1,"M0_NOMECOM","SM0",STR0087      ,/*Picture*/,49,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ENDENT" ,"SM0",STR0088      ,/*Picture*/,48,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CEPENT" ,"SM0",STR0089      ,/*Picture*/,10,/*lPixel*/,{|| Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")) })
	TRCell():New(oSection1,"M0_CIDENT" ,"SM0",STR0090      ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ESTENT" ,"SM0",STR0091      ,/*Picture*/,11,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CGC"    ,"SM0",STR0124      ,/*Picture*/,18,/*lPixel*/,{|| Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) })
	If cPaisLoc == "BRA"
		TRCell():New(oSection1,"M0IE"  ,"   ",STR0041      ,/*Picture*/,18,/*lPixel*/,{|| InscrEst()})
	EndIf
	TRCell():New(oSection1,"M0_TEL"    ,"SM0",STR0092      ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_FAX"    ,"SM0",STR0093      ,/*Picture*/,34,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_COD"    ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_LOJA"   ,"SA2",/*Titulo*/   ,/*Picture*/,04,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_END"    ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_BAIRRO" ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CEP"    ,"SA2",/*Titulo*/   ,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_MUN"    ,"SA2",/*Titulo*/   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_EST"    ,"SA2",/*Titulo*/   ,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CGC"    ,"SA2",/*Titulo*/   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"INSCR"     ,"   ",If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 ),/*Picture*/,18,/*lPixel*/,{|| If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ) })
	TRCell():New(oSection1,"FONE"      ,"   ",STR0094      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)})
	TRCell():New(oSection1,"FAX"       ,"   ",STR0093      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)})
	
	oSection1:Cell("A2_BAIRRO"):SetCellBreak()
	oSection1:Cell("A2_CGC"   ):SetCellBreak()
	oSection1:Cell("INSCR"    ):SetCellBreak()
	
	oSection2:= TRSection():New(oSection1, STR0103, {"SC7","SB1"}, /* <aOrder> */ ,;
									 /* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
									 /* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
									 /* <.lLineStyle.>  */, /* <nColSpace>  */, /*<.lAutoSize.> */, /*<cSeparator> */,;
									 /*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	
	oSection2:SetCellBorder("ALL",,,.T.)
	oSection2:SetCellBorder("RIGHT")                        
	oSection2:SetCellBorder("LEFT")                                   
	
	TRCell():New(oSection2,"C7_NUM"			,"SC7",STR0129   	,/*Picture*/)                                                                                
	TRCell():New(oSection2,"C7_ITEM"    	,"SC7",/*Titulo*/	,/*Picture*/)
	TRCell():New(oSection2,"C7_PRODUTO" 	,"SC7",/*Titulo*/	,/*Picture*/,25)
	TRCell():New(oSection2,"DESCPROD"   	,"   ",STR0097   	,/*Picture*/,100,/*lPixel*/, {|| cDescPro},,,,,,.F.)
	TRCell():New(oSection2,"C7_UM"      	,"SC7",STR0115   	,/*Picture*/,04,/*lPixel*/,/* */,"CENTER",,"CENTER")
	TRCell():New(oSection2,"C7_QUANT"   	,"SC7",/*Titulo*/	,/*Picture*/,14,/*lPixel*/,/* */,"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"C7_SEGUM"   	,"SC7",STR0118		,/*Picture*/,07,/*lPixel*/,/* */,"CENTER",,"CENTER")
	TRCell():New(oSection2,"C7_QTSEGUM" 	,"SC7",/*Titulo*/	,/*Picture*/,14,/*lPixel*/,/* */,"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"PRECO"      	,"   ",STR0098		,/*Picture*/,20,/*lPixel*/,{|| nVlUnitSC7 },"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"C7_IPI"     	,"SC7",STR0119		,/*Picture*/,10,/*lPixel*/,/* */,"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"TOTAL"     		,"   ",STR0099		,/*Picture*/,20,/*lPixel*/,{|| nValTotSC7 },"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"C7_DATPRF"  	,"SC7",/*Titulo*/	,/*Picture*/,15,/*lPixel*/,/* */,"CENTER",,"CENTER")
	TRCell():New(oSection2,"C7_CC"      	,"SC7",STR0066		,/*Picture*/,10,/*lPixel*/,/* */,"CENTER",,"CENTER")
	TRCell():New(oSection2,"C7_NUMSC"   	,"SC7",STR0123		,/*Picture*/,16,/*lPixel*/,/* */,"CENTER",,"CENTER")
	TRCell():New(oSection2,"OPCC"       	,"   ",STR0100  	,/*Picture*/,TamSX3("C7_OP")[1],/*lPixel*/,{|| cOPCC },,,,,,.F.)          
	
	oSection2:Cell("C7_PRODUTO"):SetLineBreak()
	oSection2:Cell("DESCPROD"):SetLineBreak()
	oSection2:Cell("C7_CC"):SetLineBreak()
	oSection2:Cell("OPCC"):SetLineBreak()
	oSection2:Cell("C7_NUMSC"):SetLineBreak()
	
Return(oReport)
	
/*/{Protheus.doc} Static Function REPORTPRINT
	Relatorio TREPORT
	@type  Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/
Static Function ReportPrint(oReport,nReg,nOpcX)
	
	Local oSection1   := oReport:Section(1)
	Local oSection2   := oReport:Section(1):Section(1)
	
	Local aRecnoSave  := {}
	Local aPedido     := {}
	Local aPedMail    := {}
	Local aValIVA     := {}
	
	Local cNumSC7		:= Len(SC7->C7_NUM)
	Local cCondicao		:= ""
	Local cFiltro		:= ""
	Local cComprador	:= ""
	LOcal cAlter		:= ""
	Local cAprov		:= ""
	Local cTipoSC7		:= ""
	Local cCondBus		:= ""
	Local cMensagem		:= ""
	Local cVar			:= ""
	Local cPictVUnit	:= PesqPict("SC7","C7_PRECO",15)
	Local cPictVTot		:= PesqPict("SC7","C7_TOTAL",, mv_par12)
	Local lNewAlc		:= .F.
	Local lLiber		:= .F.
	Local lRejeit		:= .F.
	Local lRet			:= .T.
	
	Local nRecnoSC7   	:= 0
	Local nTotalsX3   	:= 0
	Local nRecnoSM0   	:= 0
	Local nX          	:= 0
	Local nY          	:= 0
	Local nVias       	:= 0
	Local nTxMoeda    	:= 0
	Local nTpImp	    := IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
	Local nPageWidth  	:= IIF(nTpImp==1.Or.nTpImp==6,2435,2435) // oReport:PageWidth()
	Local nPrinted    	:= 0
	Local nValIVA     	:= 0
	Local nTotIpi	    := 0
	Local nTotIcms    	:= 0
	Local nTotDesp    	:= 0
	Local nTotFrete   	:= 0
	Local nTotalNF    	:= 0
	Local nTotSeguro  	:= 0
	Local nLinPC	    := 0
	Local nLinObs     	:= 0
	Local nDescProd   	:= 0
	Local nTotal      	:= 0
	Local nTotMerc    	:= 0
	Local nPagina     	:= 0
	Local nOrder      	:= 1
	Local cUserId     	:= RetCodUsr()
	Local cCont       	:= Nil
	Local lImpri      	:= .F.
	Local cCident	  	:= ""
	Local cCidcob	  	:= ""
	Local nLinPC2	  	:= 0
	Local nLinPC3	  	:= 0
	Local nAprovLin 	:= 0
	Local aAux1
	Local nQtdLinhas //, nX
	Local lC7OBSChar  	:= Type( "SC7->C7_OBS" ) == "C"
	
	Private cDescPro  	:= ""
	Private cOPCC     	:= ""
	Private nVlUnitSC7	:= 0
	Private nValTotSC7	:= 0
	
	Private cObs01    	:= ""
	Private cObs02    	:= ""
	Private cObs03    	:= ""
	Private cObs04    	:= ""
	Private cObs05    	:= ""
	Private cObs06    	:= ""
	Private cObs07    	:= ""
	Private cObs08    	:= ""
	Private cObs09    	:= ""
	Private cObs10    	:= ""
	Private cObs11    	:= ""
	Private cObs12    	:= ""
	Private cObs13    	:= ""
	Private cObs14    	:= ""
	Private cObs15    	:= ""
	Private cObs16    	:= ""
	
	lAuto := .t.
	
	If Type("lPedido") != "L"
		lPedido := .F.
	Endif
	
	If Type("lAuto") == "U"
		lAuto := (nReg!=Nil)
	Endif
	
	dbSelectArea("SC7")
	
	If lAuto
		dbSelectArea("SC7")
		dbGoto(nReg)
		mv_par01 := SC7->C7_NUM
		mv_par02 := SC7->C7_NUM
		mv_par03 := SC7->C7_EMISSAO
		mv_par04 := SC7->C7_EMISSAO
		mv_par05 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","05"),If(cCont == Nil,2,cCont) })
		mv_par08 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,C7_TIPO,cCont) })
		mv_par09 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","09"),If(cCont == Nil,1,cCont) })
		mv_par10 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","10"),If(cCont == Nil,3,cCont) }) 
		mv_par11 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","11"),If(cCont == Nil,3,cCont) }) 
		MV_PAR12 := SC7->C7_MOEDA // 1 // Chamado n. 054308 || OS 055703 || SUPRIMENTOS || RACHEL || 1621063514 || PEDIDO DE COMPRA - FWNM - 19/12/2019
		mv_par14 := Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","14"),If(cCont == Nil,1,cCont) }) 
		cCondBus := AllTrim(Str(SC7->C7_TIPO) + SC7->C7_NUM)
	Else
		MakeAdvplExpr(oReport:uParam)
		
		cCondicao := 'C7_FILIAL=="'       + xFilial("SC7") + '".And.'
		cCondicao += 'C7_NUM>="'          + mv_par01       + '".And.C7_NUM<="'          + mv_par02 + '".And.'
		cCondicao += 'Dtos(C7_EMISSAO)>="'+ Dtos(mv_par03) +'".And.Dtos(C7_EMISSAO)<="' + Dtos(mv_par04) + '"'
		
		oReport:Section(1):SetFilter(cCondicao,IndexKey())
		
		cCondBus := "1"+PadL(mv_par01, Len(SC7->C7_NUM),"0")
	EndIf      
	
	/*
	If lPedido
		mv_par12 := MAX(SC7->C7_MOEDA,1)
	EndIf
	*/

	nOrder	 := 10
	
	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf
	
	oSection2:Cell("PRECO"):SetPicture(cPictVUnit)
	oSection2:Cell("TOTAL"):SetPicture(cPictVTot)
	
	TRPosition():New(oSection2,"SB1",1,{ || xFilial("SB1") + SC7->C7_PRODUTO })
	TRPosition():New(oSection2,"SB5",1,{ || xFilial("SB5") + SC7->C7_PRODUTO })
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o CodeBlock com o PrintLine da Sessao 1 toda vez que rodar o oSection1:Init()   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , CabecPCxAE(oReport,oSection1,nVias,nPagina) })
	
	oReport:SetMeter(SC7->(LastRec()))
	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	dbSeek(xFilial("SC7")+cCondBus,.T.)
	
	oSection2:Init()
	
	cNumSC7 := SC7->C7_NUM
	
	While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02
		
		// somente aprovados
		If AllTrim(SC7->C7_CONAPRO) <> "L"
			dbSelectArea("SC7")
			dbSkip()
			Loop
		EndIf
		
		If (SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
			(SC7->C7_CONAPRO <> "L" .And. mv_par10 == 1) .Or.;
			(SC7->C7_XEMITID == "S" .And. mv_par05 == 1) .Or.;
			((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
			((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
			(SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
			(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
			((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
			
			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif
		
		If oReport:Cancel()
			Exit
		EndIf
		
		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)
		
		cObs01    := " "
		cObs02    := " "
		cObs03    := " "
		cObs04    := " "
		cObs05    := " "
		cObs06    := " "
		cObs07    := " "
		cObs08    := " "
		cObs09    := " "
		cObs10    := " "
		cObs11    := " "
		cObs12    := " "
		cObs13    := " "
		cObs14    := " "
		cObs15    := " "
		cObs16    := " "
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Roda a impressao conforme o numero de vias informado no mv_par09 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nVias := 1 to mv_par09
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dispara a cabec especifica do relatorio.                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:EndPage()
			
			nPagina  := 0
			nPrinted := 0
			nTotal   := 0
			nTotMerc := 0
			nDescProd:= 0
			nLinObs  := 0
			nRecnoSC7:= SC7->(Recno())
			cNumSC7  := SC7->C7_NUM
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}
			
			While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNumSC7
				
				If (SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
					(SC7->C7_CONAPRO <> "L" .And. mv_par10 == 1) .Or.;
					(SC7->C7_XEMITID == "S" .And. mv_par05 == 1) .Or.;
					((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
					((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
					(SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
					(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
					((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
					dbSelectArea("SC7")
					dbSkip()
					Loop
				Endif
				
				If oReport:Cancel()
					Exit
				EndIf
				
				oReport:IncMeter()
				
				If oReport:Row() > oReport:LineHeight() * 100
					oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
					oReport:EndPage()
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Ascan(aRecnoSave,SC7->(Recno())) == 0
					AADD(aRecnoSave,SC7->(Recno()))
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa o descricao do Produto conf. parametro digitado.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDescPro :=  ""
				If Empty(mv_par06)
					mv_par06 := "B1_DESC"
				EndIf
				
				If AllTrim(mv_par06) == "B1_DESC"
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				ElseIf AllTrim(mv_par06) == "B5_CEME"
					SB5->(dbSetOrder(1))
					If SB5->(dbSeek( xFilial("SB5") + SC7->C7_PRODUTO ))
						cDescPro := SB5->B5_CEME
					EndIf
				ElseIf AllTrim(mv_par06) == "C7_DESCRI"
					cDescPro := SC7->C7_DESCRI
				EndIf
				
				If Empty(cDescPro)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				EndIf
				
				SA5->(dbSetOrder(1))
				If SA5->(dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
					cDescPro := Alltrim(cDescPro) + " ("+Alltrim(SA5->A5_CODPRF)+")"
				EndIf
				
				If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializacao da Observacao do Pedido.                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lC7OBSChar .AND. !Empty(SC7->C7_OBS) .And. nLinObs < 17
					If !(SC7->C7_OBS $ SC7->C7_OBSM) 
						nLinObs++
						cVar:="cObs"+StrZero(nLinObs,2)
						Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBS))
					EndIf 
				Endif
				
				If !Empty(SC7->C7_OBSM) .And. nLinObs < 17
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),Alltrim(SC7->C7_OBSM))
				Endif
							
				nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
				nValTotSC7 := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				
				nTotal     := nTotal + SC7->C7_TOTAL
				nTotMerc   := MaFisRet(,"NF_TOTAL")
				
				If oReport:nDevice != 4 .Or. (oReport:nDevice == 4 .And. !oReport:lXlsTable .And. oReport:lXlsHeader)  //impressao em planilha tipo tabela
					oSection2:Cell("C7_NUM"):Disable()
				EndIf
				
				If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Disable()
					oSection2:Cell("C7_QUANT"  ):Disable()
					nVlUnitSC7 := xMoeda(((SC7->C7_PRECO*SC7->C7_QUANT)/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
					oSection2:Cell("C7_SEGUM"  ):Disable()
					oSection2:Cell("C7_QTSEGUM"):Disable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				Else
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				EndIf
				
				If cPaisLoc <> "BRA" .Or. mv_par08 == 2
					oSection2:Cell("C7_IPI" ):Disable()
				EndIf
				 
				If mv_par08 == 1 .OR. mv_par08 == 3
					oSection2:Cell("OPCC"):Disable()
				Else
					oSection2:Cell("C7_DATPRF"):SetSize(9)
					oSection2:Cell("C7_CC"):Disable()
					oSection2:Cell("C7_NUMSC"):Disable()
					If !Empty(SC7->C7_OP)
						cOPCC := STR0065 + " " + SC7->C7_OP
					ElseIf !Empty(SC7->C7_CC)
						cOPCC := STR0066 + " " + SC7->C7_CC
					EndIf
				EndIf
				
				oSection2:Cell("C7_ITEM"):SetSize(10)
				oSection2:Cell("DESCPROD"):SetSize(50)
				oSection2:Cell("C7_NUMSC"):SetSize(12.3)
				If MV_PAR07 == 1
					If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(17.6)
						oSection2:Cell("DESCPROD"):SetSize(70)
					EndIF
				ElseIf MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
					   oSection2:Cell("DESCPROD"):SetSize(47)
					   If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(24.7)
						oSection2:Cell("DESCPROD"):SetSize(80)
					EndIF
				   Else
					   oSection2:Cell("DESCPROD"):SetSize(32.3)
					   oSection2:Cell("C7_NUMSC"):SetSize(8)
					   oSection2:Cell("C7_ITEM"):SetSize(9)
					   If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(14.7)
						oSection2:Cell("DESCPROD"):SetSize(85)
						oSection2:Cell("C7_NUMSC"):SetSize(20.5)
					EndIF
				   EndIF
				   
					 oSection2:Cell("C7_ITEM"):SetSize(10)
					 oSection2:Cell("C7_PRODUTO"):SetSize(017)
					
					Do 	Case
						Case oReport:PageWidth() = 2550 // 2435
	
							oSection2:Cell("DESCPROD"):SetSize(049.57)
		
						Case oReport:PageWidth() = 2479 // 2550
							oSection2:Cell("DESCPROD"):SetSize(090)		
						
						Case oReport:PageWidth() = 3300
	
					EndCase				
					oSection2:Cell("C7_QUANT"):SetSize(015) 	// 30
					oSection2:Cell("C7_QTSEGUM"):SetSize(015) 	// 30
					oSection2:Cell("PRECO"):SetSize(019) 
					oSection2:Cell("TOTAL"):SetSize(019)  		// 25
					oSection2:Cell("C7_DATPRF"):SetSize(013)    			
					oSection2:Cell("C7_CC"):SetSize(010)
					oSection2:Cell("C7_NUMSC"):SetSize(008)
	
				If oReport:nDevice == 4 .And. oReport:lXlsTable .And. !oReport:lXlsHeader  //impressao em planilha tipo tabela	
					oSection1:Init()
					TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })
					oSection1:PrintLine()
					oSection2:PrintLine()
					oSection1:Finish()
				Else	
					oSection2:PrintLine()
				EndIf
				
				nPrinted ++
				lImpri  := .T.
				dbSelectArea("SC7")
				dbSkip()
				
			EndDo
			
			SC7->(dbGoto(nRecnoSC7))
			
			If oReport:Row() > oReport:LineHeight() * 68
				
				oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
				oReport:SkipLine()
				oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dispara a cabec especifica do relatorio.                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:EndPage()
				oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape
				
				oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
				
			Else
				oReport:Box( oReport:Row(),oReport:Col(),oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			EndIf
			
			oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			
			oReport:Box( 2200 , 1080 , 2320 , 1400 ) // Box da Data de Emissao
			oReport:Box( 2320 ,  010 , 2406 , 1220 ) // Box do Reajuste
			oReport:Box( 2320 , 1220 , 2460 , 1750 ) // Box do IPI e do Frete
			oReport:Box( 2320 , 1750 , 2460 , nPageWidth ) // Box do ICMS Despesas e Seguro
			oReport:Box( 2406 ,  010 , 2700 , 1220 ) // Box das Observacoes
	
			cMensagem:= Formula(C7_MSG)
			If !Empty(cMensagem)
				oReport:SkipLine()
				oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
			Endif
			
			oReport:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
			TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
			TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
			TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
			TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , PesqPict("SC7","C7_VLDESC",14, MV_PAR12) ),;
			2022 , 050 )
			
			oReport:SkipLine()
			oReport:SkipLine()
			oReport:SkipLine()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o Arquivo de Empresa SM0.                          ³
			//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
			//³ e o Local de Cobranca :                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SM0->(dbSetOrder(1))
			nRecnoSM0 := SM0->(Recno())
			SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))
	
			cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
			cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)
	
			If Empty(MV_PAR13) //"Local de Entrega  : "
				oReport:PrintText(STR0008 + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP")),, 050 )
			Else
				oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
			Endif
			SM0->(dbGoto(nRecnoSM0))
			oReport:PrintText(STR0010 + SM0->M0_ENDCOB+"  "+Rtrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP")),, 050 )
			
			oReport:SkipLine()
			oReport:SkipLine()
			
			SE4->(dbSetOrder(1))
			SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))
			
			nLinPC := oReport:Row()
			oReport:PrintText( STR0011+SubStr(SE4->E4_CODIGO,1,40),nLinPC,050 )
			oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
			oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 ) //"Total das Mercadorias : "
			oReport:SkipLine()
			nLinPC := oReport:Row()
			
			If cPaisLoc<>"BRA"
				aValIVA := MaFisRet(,"NF_VALIMP")
				nValIVA :=0
				If !Empty(aValIVA)
					For nY:=1 to Len(aValIVA)
						nValIVA+=aValIVA[nY]
					Next nY
				EndIf
				oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
				Transform(xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Else
				oReport:PrintText( SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
				Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Endif
			oReport:SkipLine()
			
			nTotIpi	  := MaFisRet(,'NF_VALIPI')
			nTotIcms  := MaFisRet(,'NF_VALICM')
			nTotDesp  := MaFisRet(,'NF_DESPESA')
			nTotFrete := MaFisRet(,'NF_FRETE')
			nTotSeguro:= MaFisRet(,'NF_SEGURO')
			nTotalNF  := MaFisRet(,'NF_TOTAL')
			
			oReport:SkipLine()
			oReport:SkipLine()
			nLinPC := oReport:Row()
			
			SM4->(dbSetOrder(1))
			If SM4->(dbSeek(xFilial("SM4")+SC7->C7_REAJUST))
				oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
			EndIf			
	
			If cPaisLoc == "BRA"
				oReport:PrintText( STR0071 + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIpi ,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"IPI      :"
				oReport:PrintText( STR0072 + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"ICMS     :"
			EndIf
			oReport:SkipLine()
	
			nLinPC := oReport:Row()
			oReport:PrintText( STR0073 + Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotFrete,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"Frete    :"
			oReport:PrintText( STR0074 + Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotDesp ,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"Despesas :"
			oReport:SkipLine()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializar campos de Observacoes.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			If Empty(cObs02) .Or. cObs01 == cObs02
				
				cObs02 := ""
				aAux1 := strTokArr(cObs01, chr(13)+chr(10))
				nQtdLinhas := 0						
				for nX := 1 To  Len(aAux1)
					nQtdLinhas += Ceiling(Len(aAux1[nX]) / 65)
				Next nX			
				If nQtdLinhas <= 8
					R110cObs(aAux1, 65)
				Else
					R110cObs(aAux1, 40)
				EndIf			
			Else
				cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<65,Len(cObs01),65))
				cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<65,Len(cObs02),65))
				cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<65,Len(cObs03),65))
				cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<65,Len(cObs04),65))
				cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<65,Len(cObs05),65))
				cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<65,Len(cObs06),65))
				cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<65,Len(cObs07),65))
				cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<65,Len(cObs08),65))
				cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<65,Len(cObs09),65))
				cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<65,Len(cObs10),65))
				cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<65,Len(cObs11),65))
				cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<65,Len(cObs12),65))
				cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<65,Len(cObs13),65))
				cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<65,Len(cObs14),65))
				cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<65,Len(cObs15),65))
				cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<65,Len(cObs16),65))
			EndIf
			
			cComprador:= ""
			cAlter	  := ""
			cAprov	  := ""
			lNewAlc	  := .F.
			lLiber 	  := .F.
			lRejeit	  := .F.
			
			dbSelectArea("SC7")
		//Incluida validação para os pedidos de compras por item do pedido  (IP/alçada)			
			cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE") 
			
			If cTipoSC7 == "PC"
			
				dbSelectArea("SCR")
				dbSetOrder(1)
				If dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
					cTst = ''
				Else
					If dbSeek(xFilial("SCR")+"IP"+SC7->C7_NUM)
						cTst = ''
					EndIf
				EndIf
			
			Else
			
				dbSelectArea("SCR")
				dbSetOrder(1)
				dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
			EndIf
			
			If !Empty(SC7->C7_APROV) .Or. (Empty(SC7->C7_APROV) .And. SCR->CR_TIPO == "IP")
				
				lNewAlc := .T.
				cComprador := UsrFullName(SC7->C7_USER)
				If SC7->C7_CONAPRO != "B"
					IF SC7->C7_CONAPRO == "R"
						lRejeit	  := .T.
					Else
						lLiber    := .T.
					EndIf
				EndIf
	
				While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO $ "PC|AE|IP"
					cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
					Do Case
						Case SCR->CR_STATUS=="02" //Pendente
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="03" //Liberado
							cAprov += "Ok"
						Case SCR->CR_STATUS=="04" //Bloqueado
							cAprov += "BLQ"
						Case SCR->CR_STATUS=="05" //Nivel Liberado
							cAprov += "##"
						Case SCR->CR_STATUS=="06" //Rejeitado
							cAprov += "REJ"
							
						OtherWise                 //Aguar.Lib
							cAprov += "??"
					EndCase
					cAprov += "] - "
					dbSelectArea("SCR")
					dbSkip()
				Enddo
				If !Empty(SC7->C7_GRUPCOM)
					dbSelectArea("SAJ")
					dbSetOrder(1)
					dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
					While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
						If SAJ->AJ_USER != SC7->C7_USER
							If SAJ->(FieldPos("AJ_MSBLQL") > 0)
								If SAJ->AJ_MSBLQL == "1"
									dbSkip()
									LOOP
								EndIf 
							EndIf
							cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
						EndIf
						dbSelectArea("SAJ")
						dbSkip()
					EndDo
				EndIf
			EndIf
	
			nLinPC := oReport:Row()
			oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
			oReport:PrintText( STR0076 + Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1815 ) // "SEGURO   :"
			oReport:SkipLine()
	
			nLinPC2 := oReport:Row()
			oReport:PrintText(cObs01,,050 )
			oReport:PrintText(cObs02,,050 )
	
			nLinPC := oReport:Row()
			oReport:PrintText(cObs03,nLinPC,050 )
	
			If !lNewAlc
				oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 ) //"Total Geral :"
			Else
				If lLiber
					oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 )
				Else
					oReport:PrintText( STR0078 + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),IF(lRejeit,STR0130,STR0051),STR0086) ,nLinPC,1390 )
				EndIf
			EndIf
			oReport:SkipLine()
			
			oReport:PrintText(cObs04,,050 )
			oReport:PrintText(cObs05,,050 )
			oReport:PrintText(cObs06,,050 )
			nLinPC3 := oReport:Row()
			oReport:PrintText(cObs07,,050 )
			oReport:PrintText(cObs08,,050 )
			oReport:PrintText(cObs09,nLinPC2,650 )
			oReport:SkipLine()
			oReport:PrintText(cObs10,,650 )
			oReport:PrintText(cObs11,,650 )
			oReport:PrintText(cObs12,,650 )
			oReport:PrintText(cObs13,,650 )
			oReport:PrintText(cObs14,,650 )
			oReport:PrintText(cObs15,,650 )
			oReport:PrintText(cObs16,,650 )
	
			If !lNewAlc
				
				oReport:Box( 2700 , 0010 , 3020 , 0400 )
				oReport:Box( 2700 , 0400 , 3020 , 0800 )
				oReport:Box( 2700 , 0800 , 3020 , 1220 )
				oReport:Box( 2600 , 1220 , 3020 , 1770 )
				oReport:Box( 2600 , 1770 , 3020 , nPageWidth )
				
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
	
				nLinPC := oReport:Row()
				oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
				oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "R",STR0132,IF(SC7->C7_TPFRETE $ "D",STR0133,IF(SC7->C7_TPFRETE $ "T",STR0134," " ) )))) ,nLinPC,1820 ) //STR0132 Por conta remetente, STR0133 Por conta destinatario,STR0134 Por Conta Terceiros.
				oReport:SkipLine()
	
				oReport:SkipLine()
				oReport:SkipLine()
	
				nLinPC := oReport:Row()
				oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
				oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
				oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"
				oReport:SkipLine()
	
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
	
				nLinPC := oReport:Row()
				oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
				oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
				oReport:SkipLine()
	
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
				
			Else
				
				oReport:Box( 2570 , 1220 , 2700 , 1820 )
				oReport:Box( 2570 , 1820 , 2700 , nPageWidth )
				oReport:Box( 2700 , 0010 , 3020 , nPageWidth )
				oReport:Box( 2970 , 0010 , 3020 , 1800 )
				
				nLinPC := nLinPC3
				
				oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber , STR0050 , IF(lRejeit,STR0130,STR0051) ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1290 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
				oReport:PrintText( STR0080 + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1830 ) //"Obs. do Frete: "
				oReport:SkipLine()
	
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
				oReport:SkipLine()
				oReport:PrintText(STR0053+" "+ If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
				oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"
				
				
	
				nLinCar := 140
				nColCarac := 050
				nCCarac := 140
				
				nAprovLin := Ceiling( IIF(Len(AllTrim(cAprov)) < 75 , 75 , Len(AllTrim(cAprov))) / nLinCar,0)
				
				For nX := 1 to nAprovLin 
					If nX == 1
						oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,nLinCar) , " " ),,nColCarac ) //"Aprovador(es) :"
						nColCarac+=250
					Else
						oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,nCCarac+1,nLinCar) , " " ),,nColCarac )
						nCCarac+=nLinCar
					EndIf
				Next nx
	
				nX:=nAprovLin
				While nX <= 3			
					oReport:SkipLine()
					nX:=nX+1
				EndDo
	
	
				nLinPC := oReport:Row()
				oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
				oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
				oReport:PrintText(       "|  "+STR0131 ,nLinPC, 830 ) 	//"Ok:REJEITADO"
				oReport:PrintText(       "|  "+STR0062 ,nLinPC, 1050 ) 	//"??:Aguar.Lib"
				oReport:PrintText(       "|  "+STR0067 ,nLinPC, 1300 )	//"##:Nivel Lib"
				oReport:SkipLine()
	
				oReport:SkipLine()
				If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
			EndIf
			
		Next nVias
		
		MaFisEnd()
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC7")
		If Len(aRecnoSave) > 0
			For nX :=1 to Len(aRecnoSave)
				dbGoto(aRecnoSave[nX])
				If(SC7->C7_QTDREEM >= 99)	
					If nRet == 1
						RecLock("SC7",.F.)
						SC7->C7_XEMITID := "S"
						MsUnLock()
					Elseif nRet == 2
						RecLock("SC7",.F.)
						SC7->C7_QTDREEM := 1
						SC7->C7_XEMITID := "S"
						MsUnLock()
					Elseif nRet == 3
						//cancelar
					Endif
				Else
					RecLock("SC7",.F.)
					SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
					SC7->C7_XEMITID := "S"
					SC7->( MsUnLock() )
				Endif
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbGoto(aRecnoSave[Len(aRecnoSave)])
		Endif
		
		Aadd(aPedMail,aPedido)
		
		aRecnoSave := {}
		
		dbSelectArea("SC7")
		dbSkip()
		
	EndDo
	
	oSection2:Finish()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
	//³ enviada por email, fornecendo um Array para o usuario conten ³
	//³ do os pedidos enviados para possivel manipulacao.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M110MAIL")
		lEnvMail := (oReport:nDevice == 3)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf
	
	If lAuto .And. !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif
	
	dbSelectArea("SC7")
	dbClearFilter()
	dbSetOrder(1)
	
Return
	
/*/{Protheus.doc} Static Function CABECPCXAE
	Relatorio TREPORT
	@type  Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/
Static Function CabecPCxAE(oReport,oSection1,nVias,nPagina)

	Local cMoeda		:= IIf( mv_par12 < 10 , Str(mv_par12,1) , Str(mv_par12,2) )
	Local nLinPC		:= 0
	Local nTpImp	  	:= IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
	Local nPageWidth	:= IIF(nTpImp==1.Or.nTpImp==6,2435,2435)
	Local cCident		:= IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
	Local cCGC			:= ""
	Public nRet		:= 0
	
	If Val(cMoeda) == 0
		cMoeda := "1"
	Endif
	
	TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })
	cBitmap := R110Logo()
	
	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))
	
	oSection1:Init()
	
	oReport:Box( 010 , 010 ,  260 , 1000 )
	oReport:Box( 010 , 1010,  260 , nPageWidth-2 ) 
	
	oReport:PrintText( If(nPagina > 1,(STR0033)," "),,oSection1:Cell("M0_NOMECOM"):ColPos())
	
	nLinPC := oReport:Row()
	oReport:PrintText( If( mv_par08 == 1 , (STR0068), (STR0069) ) + " - " + GetMV("MV_MOEDA"+cMoeda) ,nLinPC,1030 )
	oReport:PrintText( If( mv_par08 == 1 , SC7->C7_NUM, SC7->C7_NUMSC + "/" + SC7->C7_NUM ) + " /" + Ltrim(Str(nPagina,2)) ,nLinPC,1910 )
	oReport:SkipLine()
	
	
	nLinPC := oReport:Row()
	If(SC7->C7_QTDREEM >= 99)	
		nRet := Aviso("TOTVS", STR0125 +chr(13)+chr(10)+ "1- " + STR0126 +chr(13)+chr(10)+ "2- " + STR0127 +chr(13)+chr(10)+ "3- " + STR0128,{"1", "2", "3"},2)
		If(nRet == 1)
			oReport:PrintText( Str(SC7->C7_QTDREEM,2) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 2)
			oReport:PrintText( "1" + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 3)
			oReport:CancelPrint()
		Endif
	Else		
		oReport:PrintText( If( SC7->C7_QTDREEM > 0, Str(SC7->C7_QTDREEM+1,2) , "1" ) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
	Endif                                             
	
	oReport:SkipLine()
	
	_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap
	oReport:SayBitmap(25,25,_cFileLogo,150,60) // insere o logo no relatorio
	
	nLinPC := oReport:Row()
	oReport:PrintText(STR0087 + SM0->M0_NOMECOM,nLinPC,15)  // "Empresa:"
	oReport:PrintText(STR0106 + Substr(SA2->A2_NOME,1,50) + " " + STR0107 + SA2->A2_COD + " " + STR0108 + SA2->A2_LOJA ,nLinPC,1025)
	oReport:SkipLine()
	
	nLinPC := oReport:Row()
	oReport:PrintText(STR0088 + SM0->M0_ENDENT,nLinPC,15)
	oReport:PrintText(STR0088 + Substr(SA2->A2_END,1,49) + " " + STR0109 + Substr(SA2->A2_BAIRRO,1,25),nLinPC,1025)
	oReport:SkipLine()
	
	If cPaisLoc == "BRA"
		cCGC	:= Transform(SA2->A2_CGC,Iif(SA2->A2_TIPO == 'F',Substr(PICPES(SA2->A2_TIPO),1,17),Substr(PICPES(SA2->A2_TIPO),1,21))) 
	Else  
		cCGC	:= SA2->A2_CGC
	EndIf   
			
	nLinPC := oReport:Row()
	oReport:PrintText(STR0089 + Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP"))+Space(2)+STR0090 + "  " + RTRIM(SM0->M0_CIDENT) + " " + STR0091 + SM0->M0_ESTENT ,nLinPC,15)
	oReport:PrintText(STR0110+Left(SA2->A2_MUN, 30)+" "+STR0111+SA2->A2_EST+" "+STR0112+SA2->A2_CEP+" "+STR0124+":"+cCGC,nLinPC,1025)
	oReport:SkipLine()
	
	nLinPC := oReport:Row()
	oReport:PrintText(STR0092 + SM0->M0_TEL + Space(2) + STR0093 + SM0->M0_FAX ,nLinPC,15)
	oReport:PrintText(STR0094 + "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + " "+STR0114+"("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)+" "+If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 )+If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ),nLinPC,1025)
	oReport:SkipLine()
	
	nLinPC := oReport:Row()
	oReport:PrintText(STR0124 + Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) ,nLinPC,15)
	If cPaisLoc == "BRA"
		oReport:PrintText(Space(2) + STR0041 + InscrEst() ,nLinPC,415)
	Endif
	oReport:SkipLine()
	oReport:SkipLine()
	
	oSection1:Finish()
	
Return

/*/{Protheus.doc} Static Function R110FINIPC
	Relatorio TREPORT
	@type  Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid	:= ""
	Local nPosRef	:= 0
	Local nItem		:= 0
	Local cItemDe	:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''
	Local aStru		:= FWFormStruct(3,"SC7")[1]
	Local nX
	
	DEFAULT cSequen	:= ""
	DEFAULT cFiltro	:= ""
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
				SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)
	
			// Nao processar os Impostos se o item possuir residuo eliminado  
			If &cFiltro
				dbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf
				
			// Inicia a Carga do item nas funcoes MATXFIS  
			nItem++
			MaFisIniLoad(nItem)
	
			For nX := 1 To Len(aStru)
				cValid	:= StrTran(UPPER(GetCbSource(aStru[nX][7]))," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid .And. !(aStru[nX][14]) //campos que não são virtuais
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.           
					MaFisLoad(cRefCols,&("SC7->"+ aStru[nX][3]),nItem)
				EndIf
			Next nX		
	
			MaFisEndLoad(nItem,2)
			dbSelectArea('SC7')
			dbSkip()
		End
	EndIf
	
	RestArea(aAreaSC7)
	RestArea(aArea)
	
Return .T.
	
/*/{Protheus.doc} Static Function R110LOGO
	Logotipo
	@type  Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/

Static Function R110Logo()

	Local cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo com o codigo do grupo de empresas ³
	//³ completo, retira os espacos em branco do codigo da empresa   ³
	//³ para nova tentativa.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + SM0->M0_CODFIL+".BMP" // Empresa+Filial
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo com o codigo da filial completo,  ³
	//³ retira os espacos em branco do codigo da filial para nova    ³
	//³ tentativa.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ainda nao encontrar, retira os espacos em branco do codigo³
	//³ da empresa e da filial simultaneamente para nova tentativa.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo por filial, usa o logo padrao     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf
	
Return cBitmap
	
/*/{Protheus.doc} Static Function R110COBS
	Observacoes
	@type  Function
	@author FWNM
	@since 18/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 053321 || OS 054677 || TECNOLOGIA || LUIZ || 8451 || ENVIAR PEDIDO COMPRA
/*/
Static Function R110cObs(aAux1, nTamLinha)	
	
	Local cVar
	Local nObs := 1
	Local xTam := "( nTamLinha *( nY - 1 )) + 1"
	Local nX, nY
	Local nQtdLinhas := 0
	
	For nX := 1 To Len(aAux1)				
	
		nY := 1
		nQtdLinhas := Ceiling(Len(aAux1[nX]) / nTamLinha)
	
		While nY <= nQtdLinhas .And. nObs <= 16			
			cVar  := "cObs"+StrZero(nObs,2)
			&cVar := Substr(aAux1[nX], &xTam , IIF( nY <> nQtdLinhas, nTamLinha, (( Len(aAux1[nX]) - ( &xTam ))) + 1 ))
			nObs++	
			nY++					
		EndDo
	
	Next nY	

Return
