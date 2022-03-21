#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#include "protheus.ch"
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
  
Static cTitulo      := "EXPPROJ - XLS de Projetos de Investimentos"

/*/{Protheus.doc} User Function EXPPROJ
	(Exporta para txt massa de dados relativos ao controle de projetos/investimentos(Requisicoes e Pedidos de Compras))
	@type  Function
	@author Mauricio-HC Consys
	@since 08/10/2009
	@version 01
	@history Adriana - 24/05/2019 - TI - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Adriano Savoine - 26/07/2019 - chamado 050635 - Criado o campo DTEMIP
	@history Adriano Savoine - 02/01/2020 - chamado 054383 - Criado a coluna Grupo de Projeto e Descrição do Projeto tabela ZFL.
	@history Adriano Savoine - 08/01/2020 - Chamado 054681 - Ajuste na variavel para consulta com codigo de projeto.
	@history chamado 050729  - FWNM       - 25/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
	@history Everson - 18/05/2021 - Chamado 14270. Tratamento ErrorLog.
/*/
User Function EXPPROJ() 

	Private oGeraTxt
	Private _cPerg    := "EXPPRJ"
	Private _cArqTmp
	Private _cDtLanc  := ""
	Private cProjPed  := ''
	Private nVlContab := 0

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exporta para txt massa de dados relativos ao controle de projetos/investimentos(Requisicoes e Pedidos de Compras')
	
	PutSx1(_cPerg,"01","Filial de           ?" , "Filial de           ?" , "Filial de           ?" , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"02","Filial ate          ?" , "Filial ate          ?" , "Filial ate          ?" , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"03","Da digitação          ?" , "Da digitação          ?" , "Da digitação          ?" , "mv_ch3","D",8 ,0,0,"G","","   ","","","mv_par03","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"04","Ate digitação         ?" , "Ate digitação         ?" , "Ate digitação         ?" , "mv_ch4","D",8 ,0,0,"G","","   ","","","mv_par04","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"05","Diretório de saida    ?" , "Diretório de saida    ?" , "Diretório de saida    ?" , "mv_ch5","C",50,0,0,"G","","   ","","","mv_par05","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"06","Centro de Custo de  ?" , "Centro de Custo de  ?" , "Centro de Custo de  ?" , "mv_ch6","C",4 ,0,0,"G","","   ","","","mv_par06","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"07","Centro de Custo ate ?" , "Centro de Custo ate ?" , "Centro de Custo ate ?" , "mv_ch7","C",4 ,0,0,"G","","   ","","","mv_par07","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"08","Projeto de          ?" , "Projeto de          ?" , "Projeto de          ?" , "mv_ch8","C",7 ,0,0,"G","","   ","","","mv_par08","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"09","Projeto ate         ?" , "Projeto ate         ?" , "Projeto ate         ?" , "mv_ch9","C",7 ,0,0,"G","","   ","","","mv_par09","","","","","","","","","","","","","","","","")
	pergunte(_cPerg,.T.)
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	
	// FWNM - 23/03/2018 - CENTRO DE CUSTO DE
	If Left(AllTrim(mv_par06),1) <> "9"
		MsgAlert("Projetos de investimentos são iniciados por 9! Verifique os parâmetros...","Centro de Custo Inválido")
		Return
	EndIf
	
	// FWNM - 23/03/2018 - CENTRO DE CUSTO ATE
	If Left(AllTrim(mv_par07),1) <> "9"
		MsgAlert("Projetos de investimentos são iniciados por 9! Verifique os parâmetros...","Centro de Custo Inválido")
		Return
	EndIf
	
	// FWNM - 23/04/2018 - XLS
	If Right(AllTrim(mv_par05),1) <> "\"
		MsgAlert("Informe um diretório válido! Exemplo: C:\PROTHEUS\","Diretório Inválido")
		Return
	EndIf
	
	// Montagem da tela de processamento.                                 
	@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Geração XLS de Projetos")
	//@ 02,10 TO 080,190
	@ 01,03 Say " Este programa ira gerar um arquivo EXPPROJ.XLS, conforme os "
	@ 02,03 Say " parâmetros definidos pelo usuário, com os registros referentes as "
	@ 03,03 Say " movimentações de projetos(Notas Fiscais/Requisicoes).    "
	
	@ 70,128 BMPBUTTON TYPE 01 ACTION OkGeraTxt()
	@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
	
	Activate Dialog oGeraTxt Centered
	
	If Select("PROJ") > 0
		PROJ->(DbCloseArea())
	ENDIF
	If Select("PSD1") > 0
		PSD1->(DbCloseArea())
	ENDIF
	If Select("PSD2") > 0
		PSD2->(DbCloseArea())
	Endif
	
	//Everson - 18/05/2021. Chamado 14270.
	If Valtype(_cArqTmp) <> "U"
		If File(_cArqTmp+".DBF"); fErase(_cArqTmp+".DBF"); EndIf
		If File(_cArqTmp); fErase(_cArqTmp); EndIf

	EndIf
	//

Return

/*/{Protheus.doc} Static Function OKGERATXT
	(Funcao chamada pelo botao OK na tela inicial de processamento. Executa a geracao do arquivo texto. )
	@type  Function
	@author AP5 IDE
	@since 08/10/2009
	@version 01
	@history Programa principal
	/*/


Static Function OkGeraTxt

	
	// Cria o arquivo texto       

	/*
	Private nHdl    := fCreate(mv_par05)
	Private cEOL    := "CHR(13)+CHR(10)"
	
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+mv_par05+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif
	*/
	
	
	// Inicializa a regua de processamento                                 


	// Cria diretório
	If !ExistDir(MV_PAR05)
		nRet := MakeDir(AllTrim(MV_PAR05))
		
		If nRet != 0
			MsgAlert("Não foi possível criar o diretório. Erro: " + cValToChar( FError() ) )
		EndIf
	  
	EndIf
	
	
	Processa({|| RunCont() },"Processando...")
	
	// fecha arquivo temporario caso tenha sido criado

	If Select("PROJ") > 0
		DbSelectArea("PROJ")
		PROJ->(DbCloseArea())
		If File(_cArqTmp+".DBF"); fErase(_cArqTmp+".DBF"); EndIf
		If File(_cArqTmp); fErase(_cArqTmp); EndIf
	EndIf

Return


/*/{Protheus.doc} Static Function RUNCONT
	(Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA monta a janela com a regua de processamento. )
	@type  Function
	@author AP5 IDE
	@since 08/10/2009
	@version version
	/*/


Static Function RunCont

	Local nTamLin, cLin, cCpo
	
	_aStr := {}
	
	AADD(_aStr,{'FILIAL'     ,"C",02})
	AADD(_aStr,{'PEDIDO'     ,"C",06})
	//AADD(_aStr,{'PEDATE'   ,"C",01}) &&Chamado 008500 - Inclusao de status para pedidos parcialmente atendidos.
	AADD(_aStr,{'SOLICARMAZ' ,"C",06}) // FWNM - CHAMADO 039677-B - 07/05/2019
	AADD(_aStr,{'REQUISICAO' ,"C",06})
	AADD(_aStr,{'NFISCAL'    ,"C",09})
	AADD(_aStr,{'SERIE'      ,"C",03})
	AADD(_aStr,{'DATAEMINF'  ,"C",10}) // ADRIANO SAVOINE 26/07/2019 CHAMADO 050635
	AADD(_aStr,{'DATAEMIPC'  ,"C",10}) // ADRIANO SAVOINE 26/07/2019 CHAMADO 050635
	AADD(_aStr,{'ITEM'       ,"C",04})
	AADD(_aStr,{'CCUSTO'     ,"C",45})
	AADD(_aStr,{'CNPJFORNEC' ,"C",14}) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
	AADD(_aStr,{'NOME'       ,"C",50})
	AADD(_aStr,{'PRODUTO'    ,"C",15})                                                                    
	AADD(_aStr,{'DESCRI'     ,"C",40})
	AADD(_aStr,{'VALOR'      ,"N",17,02})
	AADD(_aStr,{'CNTPED'     ,"C",20}) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
	AADD(_aStr,{'DESCCONTA1' ,"C",60}) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
	AADD(_aStr,{'CNTCONT'    ,"C",20}) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
	AADD(_aStr,{'DESCCONTA2' ,"C",60}) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
	AADD(_aStr,{'VALORCTB'   ,"N",17,02}) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
	AADD(_aStr,{'ENCERRADO'  ,"C",24})
	AADD(_aStr,{'DTDIGNF'    ,"C",10})  &&Chamado 005696 - Mauricio.
	AADD(_aStr,{'VALORNF'    ,"N",17,02}) &&Chamado 007139 - Mauricio.
	AADD(_aStr,{'NFDEVOL'    ,"C",09})  &&Chamado 007452 - Mauricio - inicio
	//AADD(_aStr,{'SERDEV'   ,"C",03})
	AADD(_aStr,{'VLRDEV'     ,"N",17,02})
	AADD(_aStr,{'DTNFDEV'    ,"C",10})  &&Chamado 007452 - Mauricio - fim
	AADD(_aStr,{'OBSERVACA'  ,"C",50})  && Chamado
	AADD(_aStr,{'REVESTRUT'  ,"C",TamSX3("C1_REVISAO")[1]})  //Everson - 24/08/2016. Chamado 030283.
	AADD(_aStr,{'DADOSINV'   ,"C",TamSX3("C1_XDDINVE")[1]})  //Everson - 03/02/2017. Chamado 033095.
	AADD(_aStr,{'DTLANC'     ,"C",10})  //Adriana - 16/10/2017 Chamado 037637
	AADD(_aStr,{'GRUPOPRJ'   ,"C",10}) // ADRIANO SAVOINE - 02/01/2020 CHAMADO 054383
	AADD(_aStr,{'GRUPDESC'   ,"C",53}) // ADRIANO SAVOINE - 02/01/2020 CHAMADO 054383
	AADD(_aStr,{'PROJETOPED' ,"C",53})
	AADD(_aStr,{'PROJETONOT' ,"C",53})
	AADD(_aStr,{'MESEXTENSO' ,"C",11})
	
	_cArqTmp :=CriaTrab(_aStr,.T.)
	DbUseArea(.T.,,_cArqTmp,"PROJ",.F.,.F.)
	
	_cIndex:="PEDIDO+ITEM"
	indRegua("PROJ",_cArqTmp,_cIndex,,,"Criando Indices...")
	
	aAreaAtu := GetArea()
	
	// Requisicoes - Solicitacoes ao Armazem
	
	If Select ("PSD3") > 0
		DbSelectArea("PSD3")
		PSD3->(DbCloseArea())
	Endif
	
	_cQuery := "SELECT SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_CONTA, SD3.D3_EMISSAO, SD3.D3_CC, SD3.D3_CUSTO1, SB1.B1_DESC, SD3.D3_DOC, SD3.D3_ESTORNO, SD3.D3_QUANT, SD3.D3_PROJETO, SD3.D3_CODPROJ, SD3.D3_NUMSA, SD3.D3_ITEMSA "
	
	_cQuery += "FROM "
	_cQuery += RetSqlName( "SD3" ) + " SD3, "
	_cQuery += RetSqlName( "SB1" ) + " SB1 "
	
	_cQuery += "WHERE "
	_cQuery += "SD3.D3_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
	_cQuery += "AND SD3.D3_EMISSAO BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
	_cQuery += "AND SD3.D3_CC BETWEEN '" + AllTrim( mv_par06 ) + "' AND '" + AllTrim( mv_par07 ) + "' "
	_cQuery += "AND SD3.D3_PROJETO BETWEEN '" + AllTrim( mv_par08 ) + "' AND '" + AllTrim( mv_par09 ) + "' "
	_cQuery += "AND SD3.D3_CF = 'RE0' "      && somente requisicoes.
	_cQuery += "AND SD3.D3_ESTORNO = ' ' "   &&somente nao estornados
	_cQuery += "AND SD3.D_E_L_E_T_ = '' "
	
	_cQuery += "AND SB1.B1_COD = SD3.D3_COD "
	_cQuery += "AND SB1.D_E_L_E_T_ = '' "
	
	_cQuery += "ORDER BY SD3.D3_EMISSAO "
	
	TcQuery _cQuery NEW ALIAS "PSD3"
	
	DbSelectArea("PSD3")
	DbGotop()
	
	ProcRegua(RecCount())
	
	While !EOF()
		
		IncProc("Requisições: " + PSD3->D3_PROJETO)
		                   
		// FWNM - CHAMADO 039677-B - 07/05/2018
		cPrj      := PSD3->D3_PROJETO
		nVlContab := 0
		
		If Empty(cPrj)
			SCP->( dbSetOrder(2) ) // CP_FILIAL+CP_PRODUTO+CP_NUM+CP_ITEM                                                                                                                             
			If SCP->( dbSeek(PSD3->D3_FILIAL+PSD3->D3_COD+PSD3->D3_NUMSA+PSD3->D3_ITEMSA) )
				cPrj := SCP->CP_CONPRJ
			EndIf
		EndIf



		DbSelectArea("ZFL")
		DbSetOrder(1)
		
		RecLock("PROJ",.T.)
		
		PROJ->FILIAL      := PSD3->D3_FILIAL
		PROJ->PEDIDO      := SPACE(06)
		PROJ->SOLICARMAZ  := PSD3->D3_NUMSA // FWNM - CHAMADO 039677-B - 07/05/2018
		PROJ->REQUISICAO  := PSD3->D3_DOC
		PROJ->NFISCAL     := SPACE(09)
		PROJ->SERIE       := SPACE(03)
		PROJ->DATAEMINF   := substr(PSD3->D3_EMISSAO,7,2)+"/"+substr(PSD3->D3_EMISSAO,5,2)+"/"+substr(PSD3->D3_EMISSAO,1,4)
		PROJ->DATAEMIPC   := SPACE(10) // ADRIANO SAVOINE 25/07/2019 CHAMADO 050635
		PROJ->ITEM        := SPACE(04)
		PROJ->CCUSTO      := AllTrim(PSD3->D3_CC) + "-" + Posicione("CTT",1,xFilial("CTT")+PSD3->D3_CC,"CTT_DESC01")
		PROJ->CNPJFORNEC  := "ALMOXARIFADO"
		PROJ->NOME        := "ALMOXARIFADO" // SPACE(40)
		PROJ->PRODUTO     := PSD3->D3_COD
		PROJ->DESCRI      := SUBSTR(PSD3->B1_DESC,1,40)
		PROJ->VALORNF     := PSD3->D3_CUSTO1
		PROJ->CNTPED      := PSD3->D3_CONTA
		PROJ->DESCCONTA1  := Posicione("CT1",1,xFilial("CT1")+PROJ->CNTPED,"CT1_DESC01") 
		PROJ->CNTCONT     := BuscaRequisicao(PSD3->D3_EMISSAO,PSD3->D3_DOC,PSD3->D3_COD)
		PROJ->DESCCONTA2  := Posicione("CT1",1,xFilial("CT1")+PROJ->CNTCONT,"CT1_DESC01") 
		PROJ->VALORCTB    := nVlContab
		PROJ->ENCERRADO   := "E-PEDIDO ATENDIDO" // FWNM - //"E"  //SPACE(01) Solicitado por fabiana vir sempre E - 15/01/10.
		PROJ->DTDIGNF     := substr(PSD3->D3_EMISSAO,7,2)+"/"+substr(PSD3->D3_EMISSAO,5,2)+"/"+substr(PSD3->D3_EMISSAO,1,4)
		PROJ->GRUPOPRJ    := IIF(!EMPTY(cPrj), Posicione("ZFL",1,xFilial("ZFL")+AF8->AF8_XGRUPO,"ZFL_CODIGO"),"") // ADRIANO SAVOINE 02/01/2020 CHAMADO: 054383
		PROJ->GRUPDESC    := IIF(!EMPTY(cPrj), Posicione("ZFL",1,xFilial("ZFL")+AF8->AF8_XGRUPO,"ZFL_DESCRI"),"") // ADRIANO SAVOINE 02/01/2020 CHAMADO: 054383
		PROJ->PROJETOPED  := PadR(cPrj,TamSX3("AF8_PROJET")[1]) + "-" + IIF(!EMPTY(cPrj), Posicione("AF8",1,xFilial("AF8")+cPrj,"AF8_DESCRI"), "") // FWNM - CHAMADO 039677-B - 07/05/2018
		PROJ->PROJETONOT  := PadR(cPrj,TamSX3("AF8_PROJET")[1]) + "-" + IIF(!EMPTY(cPrj), Posicione("AF8",1,xFilial("AF8")+cPrj,"AF8_DESCRI"), "") // FWNM - CHAMADO 039677-B - 07/05/2018
	//	PROJ->PROJETO     := PadR(PSD3->D3_PROJETO,TamSX3("AF8_PROJET")[1]) + "-" + IIF(!EMPTY(PSD3->D3_PROJETO), Posicione("AF8",1,xFilial("AF8")+PSD3->D3_PROJETO,"AF8_DESCRI"), "")
		PROJ->MESEXTENSO  := MesExtenso( StoD(PSD3->D3_EMISSAO) )
		
		MsUnlock()
		
		DbSelectArea("PSD3")
		DbSkip()
		
	Enddo
	
	
	
	// Notas Fiscais - pedidos de compras
	
	
	// Inicio - FWNM - 09/04/2018
	
	/*
	Chamado 039677
	
	- NECESSITO QUE O RELATÓRIO "DADOS INVESTIMENTO (EXPPROJ)" SEJA EXTRAÍDO DO SISTEMA PELO PERÍODO "DT.DIG.NF" E NÃO PELA "DATA DE EMISSÃO DA Requisição / Pedido".
	- IMPLEMENTAR OS AJUSTES ABAIXO:
	. Centro de Custo: acrescentar coluna de descrição
	. Fornecedor: acrescentar coluna com o nome
	. Projeto: acrescentar descrição do projeto
	. Número de documento: D3_DOC aumentar para 9 posições
	. Data: acrescentar uma coluna com o nome do mês (Janeiro, Fevereiro...)
	. Coluna Encerrado: se E preencher com E-Pedido Atendido, e se P, preencher com P-Pedido Parcialmente Atendido
	. Pedidos de compra: considerar apenas os pedidos atendidos, ou seja C7_QUJE <> 0
	*/
	
	If Select ("PSD1") > 0
		DbSelectArea("PSD1")
		PSD1->(DbCloseArea())
	Endif
	
	
	_cQuery1 := "SELECT SD1.D1_FILIAL, SD1.D1_COD, SD1.D1_DTDIGIT, SD1.D1_QUANT, SD1.D1_CONTA, SD1.D1_CC, SD1.D1_TOTAL, SD1.D1_VALIPI, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_ITEM, "
	_cQuery1 += "SB1.B1_DESC, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME, SD1.D1_PROJETO, SD1.D1_PROJ, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_CUSTO, SD1.D1_EMISSAO, SF1.F1_DTLANC,SA2.A2_CGC,SD1.D1_ICMSCOM "
	
	_cQuery1 += "FROM "
	_cQuery1 += RetSqlName( "SF1" ) + " SF1, "
	_cQuery1 += RetSqlName( "SD1" ) + " SD1, "
	_cQuery1 += RetSqlName( "SB1" ) + " SB1, "
	_cQuery1 += RetSqlName( "SA2" ) + " SA2 "
	
	_cQuery1 += "WHERE "
	_cQuery1 += " SD1.D1_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
	_cQuery1 += "AND SD1.D1_DTDIGIT BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
	_cQuery1 += "AND SD1.D1_CC BETWEEN '" + AllTrim( mv_par06 ) + "' AND '" + AllTrim( mv_par07 ) + "' "
	_cQuery1 += "AND SD1.D1_PROJETO BETWEEN '" + AllTrim( mv_par08 ) + "' AND '" + AllTrim( mv_par09 ) + "' "
	_cQuery1 += "AND SD1.D_E_L_E_T_ = '' "
	
	_cQuery1 += "AND SB1.B1_COD = SD1.D1_COD "
	_cQuery1 += "AND SB1.D_E_L_E_T_ = '' "
	
	_cQuery1 += "AND SA2.A2_COD = SD1.D1_FORNECE "
	_cQuery1 += "AND SA2.A2_LOJA = SD1.D1_LOJA "
	_cQuery1 += "AND SA2.D_E_L_E_T_ = '' "
	
	_cQuery1 += "AND SF1.F1_FILIAL = SD1.D1_FILIAL "
	_cQuery1 += "AND SF1.F1_DOC = SD1.D1_DOC "
	_cQuery1 += "AND SF1.F1_SERIE = SD1.D1_SERIE "
	_cQuery1 += "AND SF1.F1_FORNECE = SD1.D1_FORNECE "
	_cQuery1 += "AND SF1.F1_LOJA = SF1.F1_LOJA "
	_cQuery1 += "AND SF1.F1_TIPO = SD1.D1_TIPO "
	_cQuery1 += "AND SF1.F1_TIPO = 'N' "
	_cQuery1 += "AND SF1.D_E_L_E_T_ = '' "
	
	_cQuery1 += "ORDER BY SD1.D1_DOC, SD1.D1_ITEM "
	
	TcQuery _cQuery1 NEW ALIAS "PSD1"
	
	dbSelectArea("PSD1")
	PSD1->( dbGotop() )
	
	ProcRegua(RecCount())

	
	
	Do While PSD1->( !EOF() )
		
		IncProc("NF Entrada somente tipos N: " + PSD1->D1_DOC + "/" + PSD1->D1_SERIE + "/" + PSD1->D1_FORNECE)
		
		_cFIL           := PSD1->D1_FILIAL
		_cPEDIDO        := PSD1->D1_PEDIDO
		_cITEM          := PSD1->D1_ITEMPC
		
		cEncerrado      := ""
		cC7_OBS         := ""
		cC7_DTEMISSAOPC := "" // ADRIANO SAVOINE 25/07/2019 CHAMADO 050635
		cProjPed        := ""
		nVlContab       := 0
		
		cRevisao        := ""
		cDadosInv       := ""

		cGrupo          := "" // ADRIANO SAVOINE 08/01/2020 CHAMADO 054681
		
		// Pedidos de Compras
		If !Empty(_cPEDIDO)
			
			SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
			If SC7->( dbSeek(xFilial("SC7")+_cPEDIDO+_cITEM) )
				
				cEncerrado      := Iif(Empty(SC7->C7_ENCER), Iif(SC7->C7_QUJE > 0 .AND. SC7->C7_QUJE < SC7->C7_QUANT, "P", "A"), SC7->C7_ENCER)
				cC7_OBS         := SC7->C7_OBS
				cC7_DTEMISSAOPC := DTOC(SC7->C7_DATPRF) // ADRIANO SAVOINE 25/07/2019 CHAMADO 050635
				cProjPed        := SC7->C7_PROJETO
				
			EndIf
			
			
			// Unificacao das funcoes ObterRevisao e ObterDadosInv visando otimizacao
			aDadSC1 :=  ObterSC1(_cFIL,_cPEDIDO,_cITEM)
			
			cRevisao  := aDadSC1[1]
			cDadosInv := aDadSC1[2]
			
		EndIf
		// ADRIANO SAVOINE 08/01/2020 CHAMADO 054681
		IF !EMPTY(PSD1->D1_PROJETO)

			AF8->( dbSetOrder(1) )
			IF AF8-> ( dbSeek(xFilial("AF8")+PSD1->D1_PROJETO) )
				cGrupo = AF8-> AF8_XGRUPO
			ENDIF
			
				
		ENDIF
		// ADRIANO SAVOINE 08/01/2020 CHAMADO 054681

		// Tratamento descritivos dos status dos pedidos de compras
		cEncerrado := AllTrim(cEncerrado)
		
		If cEncerrado == "E"
			cEncerrado := "E-PEDIDO ATENDIDO"
			
		ElseIf cEncerrado == "A"
			cEncerrado := "A-PEDIDO PENDENTE"
			
		ElseIf cEncerrado == "P"
			cEncerrado := "P-PARCIALMENTE ATENDIDO"
			
		EndIf
		
		
		
		// Devolucoes de compras
		
		_cNOTA 	 := PSD1->D1_DOC
		_cSER  	 := PSD1->D1_SERIE
		_cDT   	 := PSD1->D1_DTDIGIT
		_nVlr  	 := PSD1->D1_CUSTO
		_cFOR  	 := PSD1->D1_FORNECE
		_cLOJ  	 := PSD1->D1_LOJA
		_cITE  	 := PSD1->D1_ITEM
		_nQTD  	 := PSD1->D1_QUANT
		_cDtLanc := PSD1->F1_DTLANC
		
		&&Chamado 007452 - Mauricio.
		If Select ("PSD2") > 0
			DbSelectArea("PSD2")
			PSD2->(DbCloseArea())
		Endif
		
		_cQuery3 := "SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_QUANT, SD2.D2_TOTAL, SD2.D2_EMISSAO "
		
		_cQuery3 += "FROM "
		_cQuery3 += RetSqlName( "SD2" ) + " SD2 "
		
		_cQuery3 += "WHERE SD2.D2_CLIENTE = '" + _cFOR + "' "
		_cQuery3 += "AND SD2.D2_LOJA = '" + _cLOJ + "' "
		_cQuery3 += "AND SD2.D2_SERIORI = '" + _cSER + "' "
		_cQuery3 += "AND SD2.D2_NFORI = '" + _cNOTA + "' "
		_cQuery3 += "AND SD2.D2_ITEMORI = '" + _cITE + "' "
		_cQuery3 += "AND SD2.D_E_L_E_T_ = '' "
		
		TcQuery _cQuery3 NEW ALIAS "PSD2"
		
		dbSelectarea("PSD2")
		dbGoTop()
		
		
		If !EOF()
			
			&&Tratamento para apurar valor proporcional para NF devolucao conforme acordado com Jair Sbaraini.
			_cNFDEV := PSD2->D2_DOC
			_cSEDEV := PSD2->D2_SERIE
			
			If _nQTD <> PSD2->D2_QUANT
				_nVLDEV := Round((_nVlr/_nQTD)* PSD2->D2_QUANT,2)
			Else
				_nVLDEV := _nVlr
			Endif
			
			_dDTDEV := PSD2->D2_EMISSAO
			
		Else
			_cNFDEV := SPACE(09)
			_cSEDEV := SPACE(02)
			_nVLDEV := 0.00
			_dDTDEV := SPACE(10)
			
		ENDIF

		
		DbSelectArea("ZFL")
		DbSetOrder(1)

		RecLock("PROJ",.T.)
		
		PROJ->FILIAL       := PSD1->D1_FILIAL
		PROJ->PEDIDO       := PSD1->D1_PEDIDO
		PROJ->REQUISICAO   := SPACE(06)
		PROJ->NFISCAL      := _cNOTA
		PROJ->SERIE        := _cSER
		PROJ->DATAEMINF    := substr(PSD1->D1_EMISSAO,7,2)+"/"+substr(PSD1->D1_EMISSAO,5,2)+"/"+substr(PSD1->D1_EMISSAO,1,4)
		PROJ->DATAEMIPC    := cC7_DTEMISSAOPC
		PROJ->ITEM         := PSD1->D1_ITEMPC
		PROJ->CCUSTO       := AllTrim(PSD1->D1_CC) + "-" + Posicione("CTT",1,xFilial("CTT")+PSD1->D1_CC,"CTT_DESC01")
		PROJ->CNPJFORNEC   := PSD1->A2_CGC
		PROJ->NOME         := PSD1->D1_FORNECE+"-"+PSD1->D1_LOJA + "-" + SUBSTR(PSD1->A2_NOME,1,40)
		PROJ->PRODUTO      := PSD1->D1_COD
		PROJ->DESCRI       := SUBSTR(PSD1->B1_DESC,1,40)
		PROJ->VALOR        := PSD1->D1_TOTAL + PSD1->D1_VALIPI
		PROJ->CNTPED       := PSD1->D1_CONTA
		PROJ->DESCCONTA1   := Posicione("CT1",1,xFilial("CT1")+PROJ->CNTPED,"CT1_DESC01")
		PROJ->CNTCONT      := BuscaConta(PSD1->D1_FILIAL,_cNOTA,_cSER,PSD1->D1_FORNECE,PSD1->D1_LOJA,_nVlr,IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT),PSD1->D1_ICMSCOM) //WILLIAM COSTA 29/06/2018 CHAMADO 042341
		PROJ->DESCCONTA2   := Posicione("CT1",1,xFilial("CT1")+PROJ->CNTCONT,"CT1_DESC01")
		PROJ->VALORCTB     := nVlContab
		PROJ->ENCERRADO    := cEncerrado  //IIF(EMPTY(PSC7->C7_ENCER),IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P","A"),PSC7->C7_ENCER)
		PROJ->DTDIGNF      := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
		PROJ->VALORNF      := _nVlr
		PROJ->NFDEVOL      := _cNFDEV
	//	PROJ->SERDEV       := _cSEDEV
		PROJ->VLRDEV       := _nVLDEV
		PROJ->DTNFDEV      := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
		//PROJ->DESCODPRO  := IIF(!EMPTY(PSD1->D1_PROJETO), Posicione("AF8",1,xFilial("AF8")+PSD1->D1_PROJETO,"AF8_DESCRI"), "")
		PROJ->OBSERVACA    := cC7_OBS //PSC7->C7_OBS
		PROJ->REVESTRUT    := cRevisao //Everson - 25/08/2016. Chamado 030283.
		PROJ->DADOSINV	   := cDadosInv //Everson - 03/02/2016. Chamado 033095.
		PROJ->DTLANC	   := IIF(!EMPTY(_cDtLanc),substr(_cDtLanc,7,2)+"/"+substr(_cDtLanc,5,2)+"/"+substr(_cDtLanc,1,4),_cDtLanc) //Adriana - 16/10/2017 Chamado 037637
		PROJ->GRUPOPRJ     := IIF(!EMPTY(cGrupo), Posicione("ZFL",1,xFilial("ZFL")+cGrupo,"ZFL_CODIGO"),"") // ADRIANO SAVOINE 02/01/2020 CHAMADO: 054383
		PROJ->GRUPDESC     := IIF(!EMPTY(cGrupo), Posicione("ZFL",1,xFilial("ZFL")+cGrupo,"ZFL_DESCRI"),"") // ADRIANO SAVOINE 02/01/2020 CHAMADO: 054383
		PROJ->PROJETOPED   := PadR(cProjPed,TamSX3("AF8_PROJET")[1]) + "-" + IIF(!EMPTY(cProjPed), Posicione("AF8",1,xFilial("AF8")+cProjPed,"AF8_DESCRI"), "")
		PROJ->PROJETONOT   := PadR(PSD1->D1_PROJETO,TamSX3("AF8_PROJET")[1]) + "-" + IIF(!EMPTY(PSD1->D1_PROJETO), Posicione("AF8",1,xFilial("AF8")+PSD1->D1_PROJETO,"AF8_DESCRI"), "")
		PROJ->MESEXTENSO   := MesExtenso( StoD(PSD1->D1_DTDIGIT) )
		
		MsUnlock()
		
		dbSelectArea("PSD1")
		PSD1->( dbskip() )
		
	EndDo
	
	
	/*
	If Select ("PSC7") > 0
	DbSelectArea("PSC7")
	PSC7->(DbCloseArea())
	Endif
	
	
	_cQuery1 := "SELECT SC7.C7_FILIAL, SC7.C7_PRODUTO, SC7.C7_EMISSAO, SC7.C7_QUJE, SC7.C7_QUANT,SC7.C7_CONTA, SC7.C7_ENCER, SC7.C7_CC, SC7.C7_TOTAL, SC7.C7_VALIPI, SC7.C7_NUM, SC7.C7_ITEM, "
	_cQuery1 += "SB1.B1_DESC, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SC7.C7_PROJETO, SC7.C7_CODPROJ, SC7.C7_OBS "
	_cQuery1 += "FROM "
	_cQuery1 += RetSqlName( "SC7" ) + " SC7, "
	_cQuery1 += RetSqlName( "SB1" ) + " SB1, "
	_cQuery1 += RetSqlName( "SA2" ) + " SA2 "
	_cQuery1 += "WHERE  "
	_cQuery1 += " SC7.C7_EMISSAO BETWEEN '" + DtoS( mv_par03 ) + "' AND '" + DtoS( mv_par04 ) + "' "
	_cQuery1 += "AND SC7.C7_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
	_cQuery1 += "AND SC7.C7_CC BETWEEN '" + AllTrim( mv_par06 ) + "' AND '" + AllTrim( mv_par07 ) + "' "
	_cQuery1 += "AND SC7.C7_PROJETO BETWEEN '" + AllTrim( mv_par08 ) + "' AND '" + AllTrim( mv_par09 ) + "' "
	_cQuery1 += "AND SC7.D_E_L_E_T_ = '' "
	_cQuery1 += "AND SB1.B1_COD = SC7.C7_PRODUTO "
	_cQuery1 += "AND SB1.D_E_L_E_T_ = '' "
	_cQuery1 += "AND SA2.A2_COD = SC7.C7_FORNECE "
	_cQuery1 += "AND SA2.A2_LOJA = SC7.C7_LOJA "
	_cQuery1 += "AND SA2.D_E_L_E_T_ = '' "
	_cQuery1 += "ORDER BY SC7.C7_NUM, SC7.C7_ITEM "
	
	TcQuery _cQuery1 NEW ALIAS "PSC7"
	
	DbSelectArea("PSC7")
	DbGotop()
	
	ProcRegua(RecCount())
	
	While !EOF()
	
	IncProc("PC: " + PSC7->C7_NUM)
	
	_cFIL    := PSC7->C7_FILIAL
	_cPEDIDO := PSC7->C7_NUM
	_cITEM   := PSC7->C7_ITEM
	
	//Everson - 25/08/2016 - Obtém a a revisão da estrutura (C1_REVISAO). Chamado 030283.
	cRevisao := obterRevisao(_cFIL,_cPEDIDO,_cITEM)
	//
	
	//Everson - 03/02/2017 - Obtém dados de investimento (C1_XDDINVE). Chamado 033095.
	cDadosInv := obterDadosInv(_cFIL,_cPEDIDO,_cITEM)
	//
	
	
	// Notas Fiscais de Entrada
	
	If Select ("PSD1") > 0
	DbSelectArea("PSD1")
	PSD1->(DbCloseArea())
	Endif
	
	_cQuery2 := "SELECT SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_QUANT, SD1.D1_CUSTO, SD1.D1_DTDIGIT, SD1.D1_ITEM, SD1.D1_FORNECE, SD1.D1_LOJA, SF1.F1_DTLANC "
	
	_cQuery2 += "FROM "
	_cQuery2 += RetSqlName( "SD1" ) + " SD1 "
	
	_cQuery2 += "INNER JOIN "+RetSqlName("SF1") + " SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SF1.D_E_L_E_T_ = ''
	
	_cQuery2 += "WHERE SD1.D1_FILIAL = '" + _cFIL + "' "
	_cQuery2 += "AND SD1.D1_PEDIDO = '" + _cPEDIDO + "' "
	_cQuery2 += "AND SD1.D1_ITEMPC = '" + _cITEM + "' "
	_cQuery2 += "AND SD1.D_E_L_E_T_ = '' "
	
	TcQuery _cQuery2 NEW ALIAS "PSD1"
	
	DbSelectarea("PSD1")
	DBGOTOP()
	
	ProcRegua(RecCount())
	
	IF !EOF()
	
	While !EOF()
	
	IncProc("NF: " + PSD1->D1_DOC + "/" + PSD1->D1_SERIE)
	
	_cNOTA 	:= PSD1->D1_DOC
	_cSER  	:= PSD1->D1_SERIE
	_cDT   	:= PSD1->D1_DTDIGIT
	_nVlr  	:= PSD1->D1_CUSTO
	_cFOR  	:= PSD1->D1_FORNECE
	_cLOJ  	:= PSD1->D1_LOJA
	_cITE  	:= PSD1->D1_ITEM
	_nQTD  	:= PSD1->D1_QUANT
	_cDtLanc	:= PSD1->F1_DTLANC
	
	
	// Devolucoes de compras
	
	&&Chamado 007452 - Mauricio.
	If Select ("PSD2") > 0
	DbSelectArea("PSD2")
	PSD2->(DbCloseArea())
	Endif
	
	_cQuery3 := "SELECT SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_QUANT, SD2.D2_TOTAL, SD2.D2_EMISSAO "
	_cQuery3 += "FROM "
	_cQuery3 += RetSqlName( "SD2" ) + " SD2 "
	_cQuery3 += "WHERE SD2.D2_NFORI = '" + _cNOTA + "' "
	_cQuery3 += "AND SD2.D2_SERIORI = '" + _cSER + "' "
	_cQuery3 += "AND SD2.D2_CLIENTE = '" + _cFOR + "' "
	_cQuery3 += "AND SD2.D2_LOJA = '" + _cLOJ + "' "
	_cQuery3 += "AND SD2.D2_ITEMORI = '" + _cITE + "' "
	_cQuery3 += "AND SD2.D_E_L_E_T_ = '' "
	
	TcQuery _cQuery3 NEW ALIAS "PSD2"
	
	DbSelectarea("PSD2")
	DBGOTOP()
	
	
	IF !EOF()
	&&Tratamento para apurar valor proporcional para NF devolucao conforme acordado com Jair Sbaraini.
	_cNFDEV := PSD2->D2_DOC
	_cSEDEV := PSD2->D2_SERIE
	If _nQTD <> PSD2->D2_QUANT
	_nVLDEV := Round((_nVlr/_nQTD)* PSD2->D2_QUANT,2)
	Else
	_nVLDEV := _nVlr
	Endif
	_dDTDEV := PSD2->D2_EMISSAO
	ELSE
	_cNFDEV := SPACE(09)
	_cSEDEV := SPACE(02)
	_nVLDEV := 0.00
	_dDTDEV := SPACE(10)
	ENDIF
	
	RecLock("PROJ",.T.)
	
	PROJ->FILIAL     := PSC7->C7_FILIAL
	PROJ->PEDIDO     := PSC7->C7_NUM
	PROJ->REQUISICAO := SPACE(06)
	PROJ->NFISCAL    := _cNOTA
	PROJ->SERIE      := _cSER
	PROJ->DATAEMI  := substr(PSC7->C7_EMISSAO,7,2)+"/"+substr(PSC7->C7_EMISSAO,5,2)+"/"+substr(PSC7->C7_EMISSAO,1,4)
	PROJ->ITEM       := PSC7->C7_ITEM
	PROJ->CCUSTO     := PSC7->C7_CC
	PROJ->CODFORNEC  := PSC7->C7_FORNECE+"-"+PSC7->C7_LOJA
	PROJ->NOME       := SUBSTR(PSC7->A2_NOME,1,40)
	PROJ->PRODUTO    := PSC7->C7_PRODUTO
	PROJ->DESCRI     := SUBSTR(PSC7->B1_DESC,1,40)
	PROJ->VALOR      := PSC7->C7_TOTAL + PSC7->C7_VALIPI
	PROJ->PROJETO    := PSC7->C7_PROJETO
	PROJ->CONTA      := PSC7->C7_CONTA
	PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P","A"),PSC7->C7_ENCER)
	PROJ->DTDIGNF    := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
	PROJ->VALORNF    := _nVlr
	PROJ->NFDEVOL    := _cNFDEV
	PROJ->SERDEV     := _cSEDEV
	PROJ->VLRDEV     := _nVLDEV
	PROJ->DTNFDEV    := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
	PROJ->DESCODPRO  := IIF(!EMPTY(PSC7->C7_PROJETO), Posicione("AF8",1,xFilial("AF8")+PSC7->C7_PROJETO,"AF8_DESCRI"), "")
	PROJ->OBSERVACA  := PSC7->C7_OBS
	PROJ->REVESTRUT  := cRevisao //Everson - 25/08/2016. Chamado 030283.
	PROJ->DADOSINV	  := cDadosInv //Everson - 03/02/2016. Chamado 033095.
	PROJ->DTLANC	  := IIF(!EMPTY(_cDtLanc),substr(_cDtLanc,7,2)+"/"+substr(_cDtLanc,5,2)+"/"+substr(_cDtLanc,1,4),_cDtLanc) //Adriana - 16/10/2017 Chamado 037637
	
	MsUnlock()
	
	DbSelectArea("PSD1")
	PSD1->(Dbskip())
	
	Enddo
	
	ELSE
	_cNOTA := SPACE(09)
	_cSER  := SPACE(03)
	_cDt   := SPACE(10)
	_nVlr  := 0
	_cNFDEV := SPACE(09)
	_cSEDEV := SPACE(02)
	_nVLDEV := 0.00
	_dDTDEV := SPACE(10)
	_cDtLanc:= SPACE(10)
	
	RecLock("PROJ",.T.)
	
	PROJ->FILIAL     := PSC7->C7_FILIAL
	PROJ->PEDIDO     := PSC7->C7_NUM
	PROJ->REQUISICAO := SPACE(06)
	PROJ->NFISCAL    := _cNOTA
	PROJ->SERIE      := _cSER
	PROJ->DATAEMI  := substr(PSC7->C7_EMISSAO,7,2)+"/"+substr(PSC7->C7_EMISSAO,5,2)+"/"+substr(PSC7->C7_EMISSAO,1,4)
	PROJ->ITEM       := PSC7->C7_ITEM
	PROJ->CCUSTO     := PSC7->C7_CC
	PROJ->CODFORNEC  := PSC7->C7_FORNECE+"-"+PSC7->C7_LOJA
	PROJ->NOME       := SUBSTR(PSC7->A2_NOME,1,40)
	PROJ->PRODUTO    := PSC7->C7_PRODUTO
	PROJ->DESCRI     := SUBSTR(PSC7->B1_DESC,1,40)
	PROJ->VALOR      := PSC7->C7_TOTAL + PSC7->C7_VALIPI
	PROJ->PROJETO    := PSC7->C7_PROJETO
	PROJ->CONTA      := PSC7->C7_CONTA
	PROJ->ENCERRADO  := IIF(EMPTY(PSC7->C7_ENCER),IIF(PSC7->C7_QUJE > 0 .AND. PSC7->C7_QUJE < PSC7->C7_QUANT,"P","A"),PSC7->C7_ENCER)
	PROJ->DTDIGNF    := IIF(!EMPTY(_cDT),substr(_cDT,7,2)+"/"+substr(_cDT,5,2)+"/"+substr(_cDT,1,4),_cDT)
	PROJ->VALORNF    := _nVlr
	PROJ->NFDEVOL    := _cNFDEV
	PROJ->SERDEV     := _cSEDEV
	PROJ->VLRDEV     := _nVLDEV
	PROJ->DTNFDEV    := IIF(!EMPTY(_dDTDEV),substr(_dDTDEV,7,2)+"/"+substr(_dDTDEV,5,2)+"/"+substr(_dDTDEV,1,4),_dDTDEV)
	PROJ->DESCODPRO  := IIF(!EMPTY(PSC7->C7_PROJETO), Posicione("AF8",1,xFilial("AF8")+PSC7->C7_PROJETO,"AF8_DESCRI"), "")
	PROJ->OBSERVACA  := PSC7->C7_OBS
	PROJ->REVESTRUT  := cRevisao //Everson - 25/08/2016. Chamado 030283.
	PROJ->DADOSINV	  := cDadosInv //Everson - 03/02/2016. Chamado 033095.
	PROJ->DTLANC	  := IIF(!EMPTY(_cDtLanc),substr(_cDtLanc,7,2)+"/"+substr(_cDtLanc,5,2)+"/"+substr(_cDtLanc,1,4),_cDtLanc) //Adriana - 16/10/2017 Chamado 037637
	
	MsUnlock()
	
	ENDIF
	
	DbSelectArea("PSC7")
	PSC7->(DbSkip())
	Enddo
	
	*/
	
	// fim mudanca - FWNM - 09/04/2018
	
	
	
	// FWNM - 23/04/2018 - CHAMADO 039677
	RestArea( aAreaAtu )
	GeraXLS()

	Return
	// FWNM - FIM
	
	// Gera arquivo texto
	dbSelectArea("PROJ")
	dbGoTop()
	
	ProcRegua(RecCount())
	
	//inclui cabecalho
	if !EOF()
		
		
		// Grava cabecalho                                                     
	
	//	nTamLin := 430
		nTamLin := 574 // FWNM - 09/04/2018
		//
		
		cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
		
		
		// Substitui nas respectivas posicioes na variavel cLin pelo conteudo  dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma string dentro de outra string.
		                                    
		
		
		/*
		FWNM - 09/04/2018 - CHAMADO 039677
		
		NOVO LEIAUTE
		
		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º Lay-Out do arquivo Texto gerado:                                º
		//ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
		//ºCampo           ³ Inicio ³ Tamanho                               º
		//ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶
		//º FILIAL         ³ 01     ³ 02                                    º
		//º PEDIDO         ³ 04     ³ 06                                    º
		//º REQUISICAO     ³ 11     ³ 06                                    º
		//º NOTA FISCAL    ³ 18     ³ 09                                    º
		//º SERIE          ³ 28     ³ 03                                    º
		//º EMISSAO        ³ 32     ³ 10                                    º
		//º ITEM           ³ 43     ³ 04                                    º
		//º CENTRO CUSTO   ³ 48     ³ 45                                    º
		//º COD FORNECEDOR ³ 94     ³ 09                                    º
		//º RAZAO SOCIAL   ³ 104    ³ 40                                    º
		//º PRODUTO        ³ 145    ³ 15                                    º
		//º DESCRICAO PROD ³ 161    ³ 40                                    º
		//º VALOR PC       ³ 201    ³ 17                                    º
		//º CONTA          ³ 219    ³ 20                                    º
		//º ENCERRADO      ³ 240    ³ 24                                    º
		//º DTDIGNF        | 264    | 10									º
		//º VALOR NF       ³ 275    ³ 17                                    º
		//  NFDEVOL          293      09
		//  SERDEV           303      03
		//  VLRDEV           309      17
		//  DTNFDEV          326      10
		//  OBS              337      50
		//  REV              388      03
		//  DADOS INVENT     392      60
		//  DT DIGITACAO     453      10
		//  PROJETO          464      100
		//  MES EXTENSO      565      11
		//
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
		
		*/
		
		// Cabeçalho
		
		cCpo := "FL"
		cLin := Stuff(cLin,01,02,cCpo)
		
		cCpo := "PEDIDO"
		cLin := Stuff(cLin,04,06,cCpo)
		
		cCpo := "REQ.  "
		cLin := Stuff(cLin,11,06,cCpo)
		
		cCpo := "N.FISCAL "
		cLin := Stuff(cLin,18,09,cCpo)
		
		cCpo := "SER"
		cLin := Stuff(cLin,28,03,cCpo)
		
		cCpo := "DT. EMISS. NF"
		cLin := Stuff(cLin,32,10,cCpo)
		
		// ADRIANO SAVOINE 25/07/2019 CHAMADO 050635
		cCpo := "DT. EMISS. PC"
		cLin := Stuff(cLin,43,10,cCpo)
		
		cCpo := "ITEM"
		cLin := Stuff(cLin,54,04,cCpo)
		
		cCpo := PadR("C.CUSTO",45)
		cLin := Stuff(cLin,59,45,cCpo)
		
		cCpo := PadR("COD. FORNEC.",09)
		cLin := Stuff(cLin,105,09,cCpo)
		
		cCpo := PadR("RAZAO SOCIAL",40)
		cLin := Stuff(cLin,115,40,cCpo)
		
		cCpo := "PRODUTO        "
		cLin := Stuff(cLin,156,15,cCpo)
		
		cCpo := PadR("DESCRICAO",40)
		cLin := Stuff(cLin,172,40,cCpo)
		
		cCpo := PadR("VALOR PC",17)
		cLin := Stuff(cLin,213,17,cCpo)
		
		cCpo := PadR("CONTA",20)
		cLin := Stuff(cLin,231,20,cCpo)
		
		cCpo := PadR("STATUS PC",24)
		cLin := Stuff(cLin,252,24,cCpo)
		
		cCpo := "DT.DIG.NF "
		cLin := Stuff(cLin,277,10,cCpo)
		
		cCpo := PadR("VALOR NF",17)
		cLin := Stuff(cLin,288,17,cCpo)
		
		cCpo := "NF DEVOL "
		cLin := Stuff(cLin,306,09,cCpo)
		
		cCpo := "SER"
		cLin := Stuff(cLin,316,03,cCpo)
		
		cCpo := "VALOR DEVOLUCAO  "
		cLin := Stuff(cLin,320,17,cCpo)
		
		cCpo := "DT.NF.DEV."
		cLin := Stuff(cLin,338,10,cCpo)
		
		cCpo := PadR("OBSERVACAO",50)
		cLin := Stuff(cLin,349,50,cCpo)
		
		cCpo := "REV"
		cLin := Stuff(cLin,400,3,cCpo)
		
		cCpo := PadR("DADOS INVENTARIO",60)
		cLin := Stuff(cLin,404,60,cCpo)
		
		cCpo := "DT.LANC.  "
		cLin := Stuff(cLin,465,10,cCpo)
		
		// ADRIANO SAVOINE - 02/01/2020 CHAMADO: 054383
		cCpo := PadR("GRUPOPRJ",10)
		cLin := Stuff(cLin,476,10,cCpo)

		// ADRIANO SAVOINE - 02/01/2020 CHAMADO: 054383
		cCpo := PadR("GRUPDESC",100)
		cLin := Stuff(cLin,487,100,cCpo)

		// FWNM - 09/04/2018 - Chamado 039677
		cCpo := PadR("PROJETOPED",100)
		cLin := Stuff(cLin,588,100,cCpo)
		
		// FWNM - 09/04/2018 - Chamado 039677
		cCpo := "MES EXTENSO"
		cLin := Stuff(cLin,689,11,cCpo)
		
		
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			Alert("Ocorreu um erro na gravacao do arquivo.")
		Endif
		
	EndIf
	//
	
	
	
	While !EOF()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Incrementa a regua                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		IncProc("Gerando arquivo texto..." + cLin)
		
	//	nTamLin := 430
		nTamLin := 780
		cLin    := Space(nTamLin)+cEOL // Variavel para criacao da linha do registros para gravacao
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
		//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
		//³ string dentro de outra string.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		//º FILIAL         ³ 01     ³ 02                                    º
		//º PEDIDO         ³ 04     ³ 06                                    º
		//º REQUISICAO     ³ 11     ³ 06                                    º
		//º NOTA FISCAL    ³ 18     ³ 09                                    º
		//º SERIE          ³ 28     ³ 03                                    º
		//º EMISSAO        ³ 32     ³ 10                                    º
		//º ITEM           ³ 43     ³ 04                                    º
		//º CENTRO CUSTO   ³ 48     ³ 45                                    º
		//º COD FORNECEDOR ³ 94     ³ 09                                    º
		//º RAZAO SOCIAL   ³ 104    ³ 40                                    º
		//º PRODUTO        ³ 145    ³ 15                                    º
		//º DESCRICAO PROD ³ 161    ³ 40                                    º
		//º VALOR PC       ³ 201    ³ 17                                    º
		//º CONTA          ³ 219    ³ 20                                    º
		//º ENCERRADO      ³ 240    ³ 24                                    º
		//º DTDIGNF        | 264    | 10									º
		//º VALOR NF       ³ 275    ³ 17                                    º
		//  NFDEVOL          293      09
		//  SERDEV           303      03
		//  VLRDEV           309      17
		//  DTNFDEV          326      10
		//  OBS              337      50
		//  REV              388      03
		//  DADOS INVENT     392      60
		//  DT DIGITACAO     453      10
		//  PROJETO          464      100
		//  MES EXTENSO      565      11
		
		
		cCpo := PADR(PROJ->FILIAL,02)
		cLin := Stuff(cLin,01,02,cCpo)
		
		cCpo := PADR(PROJ->PEDIDO,06)
		cLin := Stuff(cLin,04,06,cCpo)
		
		cCpo := PADR(PROJ->REQUISICAO,06)
		cLin := Stuff(cLin,11,06,cCpo)
		
		cCpo := PadR(PROJ->NFISCAL,09)
		cLin := Stuff(cLin,18,09,cCpo)
		
		cCpo := PadR(PROJ->SERIE,03)
		cLin := Stuff(cLin,28,03,cCpo)
		
		cCpo := PadR(PROJ->DATAEMINF,10)
		cLin := Stuff(cLin,32,10,cCpo)
		
		// ADRIANO SAVOINE 25/07/2019 CHAMADO 050635
		cCpo := PadR(PROJ->DATAEMIPC,10)
		cLin := Stuff(cLin,43,10,cCpo)
		
		cCpo := PADR(PROJ->ITEM,04)
		cLin := Stuff(cLin,54,04,cCpo)
		
		cCpo := PADR(PROJ->CCUSTO,45)
		cLin := Stuff(cLin,59,45,cCpo)
		
		cCpo := PADR(PROJ->CODFORNEC,09)
		cLin := Stuff(cLin,105,09,cCpo)
		
		cCpo := PadR(PROJ->NOME,40)
		cLin := Stuff(cLin,115,40,cCpo)
		
		cCpo := PADR(PROJ->PRODUTO,15)
		cLin := Stuff(cLin,156,15,cCpo)
		
		cCpo := PadR(PROJ->DESCRI,40)
		cLin := Stuff(cLin,172,40,cCpo)
		
		cCpo := Str(PROJ->VALOR,17,02)
		_ncount  := AT(".",cCpo)  &&Chamado 005342 - Mauricio HC Consys.
		_cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
		cCpo := _cString
		cLin := Stuff(cLin,213,17,cCpo)
		
		cCpo := PadR(PROJ->CONTA,20)
		cLin := Stuff(cLin,231,20,cCpo)
		
		cCpo := PadR(PROJ->ENCERRADO,24)
		cLin := Stuff(cLin,252,24,cCpo)
		
		cCpo := PadR(PROJ->DTDIGNF,10)
		cLin := Stuff(cLin,277,10,cCpo)
		
		cCpo := Str(PROJ->VALORNF,17,02)
		_ncount  := AT(".",cCpo)
		_cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
		cCpo := _cString
		cLin := Stuff(cLin,288,17,cCpo)
		
		cCpo := PadR(PROJ->NFDEVOL,09)
		cLin := Stuff(cLin,306,09,cCpo)
		
		cCpo := PROJ->SERDEV
		cLin := Stuff(cLin,316,03,cCpo)
		
		cCpo := Str(PROJ->VLRDEV,17,02)
		_ncount  := AT(".",cCpo)
		_cString := Substr(cCpo,1,_ncount-1)+","+Substr(cCpo,_ncount+1,2)
		cCpo := _cString
		cLin := Stuff(cLin,320,17,cCpo)
		
		cCpo := PROJ->DTNFDEV
		cLin := Stuff(cLin,338,10,cCpo)
		
		cCpo := PadR(PROJ->OBSERVACA,50)
		cLin := Stuff(cLin,349,50,cCpo)
		
		//Everson - 25/08/2016. Chamado 030283.
		cCpo := PROJ->REVESTRUT
		cLin := Stuff(cLin,400,3,cCpo)
		
		//Everson - 03/02/2017. Chamado 033095.
		cCpo := PadR(PROJ->DADOSINV,60)
		cLin := Stuff(cLin,404,60,cCpo)
		
		//Adriana - 17/10/2017. Chamado 037637
		cCpo := PROJ->DTLANC
		cLin := Stuff(cLin,465,10,cCpo)

		// ADRIANO SAVOINE - 02/01/2020 CHAMADO: 054383
		cCpo := PadR("GRUPOPRJ",10)
		cLin := Stuff(cLin,476,10,cCpo)

		// ADRIANO SAVOINE - 02/01/2020 CHAMADO: 054383
		cCpo := PadR("GRUPDESC",100)
		cLin := Stuff(cLin,487,100,cCpo)
		
		// FWNM - 09/04/2018 - Chamado 039677
		cCpo := PadR(PROJ->PROJETOPED,100)
		cLin := Stuff(cLin,588,100,cCpo)
		
		// FWNM - 09/04/2018 - Chamado 039677
		cCpo := PadR(PROJ->MESEXTENSO,11)
		cLin := Stuff(cLin,689,11,cCpo)
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
		//³ linha montada.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		IncProc("Arquivo: " + cLin)
		
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		
		DbSelectArea("PROJ")
		dbSkip()
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
	//³ cao anterior.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If fClose(nHdl)
		Close(oGeraTxt)              
		msgInfo("Arquivo texto gerado com sucesso no path: " + MV_PAR05)
	EndIf


Return


static function DTINIPRE(_Proj)

	Local _cProj := _Proj
	Local _cData := ""
	
	DbSelectArea("AF8")
	DbSetOrder(1)
	
	if dbSeek(xFilial("AF8")+_cProj)
		_cData := substr(DTOS(AF8->AF8_START),7,2)+"/"+substr(DTOS(AF8->AF8_START),5,2)+"/"+substr(DTOS(AF8->AF8_START),1,4)
	endif

return(_cData)



static function DTFIMPRE(_Proj)

	Local _cProj := _Proj
	Local _cData := ""
	
	DbSelectArea("AF8")
	DbSetOrder(1)
	
	if dbSeek(xFilial("AF8")+_cProj)
		_cData := substr((DTOS(AF8->AF8_FINISH)),7,2)+"/"+substr((DTOS(AF8->AF8_FINISH)),5,2)+"/"+substr((DTOS(AF8->AF8_FINISH)),1,4)
	endif

return(_cData)




static function DATAINI(_Proj)

	Local _cProj := _Proj
	Local _cData := ""
	
	DbSelectArea("AF8")
	DbSetOrder(1)
	
	if dbSeek(xFilial("AF8")+_cProj)
		_cData := substr((DTOS(AF8->AF8_DTATUI)),7,2)+"/"+substr((DTOS(AF8->AF8_DTATUI)),5,2)+"/"+substr((DTOS(AF8->AF8_DTATUI)),1,4)
	endif

return(_cData)


static function DATAFIM(_Proj)

	Local _cProj := _Proj
	Local _cData := ""
	
	DbSelectArea("AF8")
	DbSetOrder(1)
	
	if dbSeek(xFilial("AF8")+_cProj)
		_cData := substr((DTOS(AF8->AF8_DTATUF)),7,2)+"/"+substr((DTOS(AF8->AF8_DTATUF)),5,2)+"/"+substr((DTOS(AF8->AF8_DTATUF)),1,4)
	endif

return(_cData)



/*
Everson - 25/08/2016. Chamado 030283.
Função retorna a Rev. Estrutura
*/
Static Function obterRevisao(cFil,cNum,cItem)

	//Declaração de variáveis.
	Local aArea	:= GetArea()
	Local cQuery	:= ""
	Local cRetorno:= Space(3)
	
	//Remove espaços em branco.
	cFil	:= Alltrim(cValToChar(cFil))
	cNum	:= Alltrim(cValToChar(cNum))
	cItem	:= Alltrim(cValToChar(cItem))
	
	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT C1_REVISAO "
	cQuery += " FROM  "
	
	cQuery += " " + RetSqlName("SC7") + " AS SC7 "
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SC1") + " AS SC1 ON "
	cQuery += " C7_FILIAL = C1_FILIAL "
	cQuery += " AND C7_NUMSC = C1_NUM "
	cQuery += " AND C7_ITEMSC = C1_ITEM "
	cQuery += " AND C7_PRODUTO = C1_PRODUTO "
	
	cQuery += " WHERE "
	
	cQuery += " SC7.D_E_L_E_T_ = '' "
	cQuery += " AND SC1.D_E_L_E_T_ = '' "
	cQuery += " AND C7_NUMSC <> '' "
	cQuery += " AND C7_ITEMSC <> '' "
	cQuery += " AND C1_REVISAO <> '' "
	cQuery += " AND C7_FILIAL = '" + cFil + "' "
	cQuery += " AND C7_NUM = '" + cNum + "' "
	cQuery += " AND C7_ITEM = '" + cItem + "' "
	
	//Verifica se o alias existe.
	If Select("REVISAO") > 0
		REVISAO->(DbCloseArea())
	EndIf
	
	//Executa consulta ao BD.
	TcQuery cQuery New Alias "REVISAO"
	
	DbSelectArea("REVISAO")
	REVISAO->(DbGoTop())
	
	cRetorno := cValToChar(REVISAO->C1_REVISAO)
	
	DbCloseArea("REVISAO")
	
	RestArea(aArea)

Return cRetorno


/*/{Protheus.doc} Static Function obterDadosInv
	(Função retorna descrição dos dados de investimento.)
	@type  Function
	@author Everson
	@since 23/08/2016
	@version 01
	@history Chamado 033095. 
	/*/


Static Function obterDadosInv(cFil,cNum,cItem)

	//Declaração de variáveis.
	Local aArea	:= GetArea()
	Local cQuery	:= ""
	Local cRetorno:= Space(3)
	
	//Remove espaços em branco.
	cFil	:= Alltrim(cValToChar(cFil))
	cNum	:= Alltrim(cValToChar(cNum))
	cItem	:= Alltrim(cValToChar(cItem))
	
	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT C1_XDDINVE "
	cQuery += " FROM  "
	
	cQuery += " " + RetSqlName("SC7") + " AS SC7 "
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SC1") + " AS SC1 ON "
	cQuery += " C7_FILIAL = C1_FILIAL "
	cQuery += " AND C7_NUMSC = C1_NUM "
	cQuery += " AND C7_ITEMSC = C1_ITEM "
	cQuery += " AND C7_PRODUTO = C1_PRODUTO "
	
	cQuery += " WHERE "
	
	cQuery += " SC7.D_E_L_E_T_ = '' "
	cQuery += " AND SC1.D_E_L_E_T_ = '' "
	cQuery += " AND C7_NUMSC <> '' "
	cQuery += " AND C7_ITEMSC <> '' "
	cQuery += " AND C7_FILIAL = '" + cFil + "' "
	cQuery += " AND C7_NUM = '" + cNum + "' "
	cQuery += " AND C7_ITEM = '" + cItem + "' "
	
	//Verifica se o alias existe.
	If Select("DADOSINV") > 0
		DADOSINV->(DbCloseArea())
	EndIf
	
	//Executa consulta ao BD.
	TcQuery cQuery New Alias "DADOSINV"
	
	DbSelectArea("DADOSINV")
	DADOSINV->(DbGoTop())
	
	cRetorno := cValToChar(DADOSINV->C1_XDDINVE)
	
	DbCloseArea("DADOSINV")
	
	RestArea(aArea)

Return cRetorno


/*/{Protheus.doc} Static Function ObterSC1
	(Funcao para unificar dados do SC1, visando otimizacao.)
	@type  Function
	@author Fernando Macieira 
	@since 04/09/2018
	@version 01
	@history Funcao para unificar dados do SC1, visando otimizacao.
	/*/


Static Function ObterSC1(cFil,cNum,cItem)

	//Declaração de variáveis.
	Local aArea	   := GetArea()
	Local cQuery   := ""
	Local aDadSC1  := {}
	
	//Remove espaços em branco.
	cFil	:= Alltrim(cValToChar(cFil))
	cNum	:= Alltrim(cValToChar(cNum))
	cItem	:= Alltrim(cValToChar(cItem))
	
	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT C1_REVISAO, C1_XDDINVE "
	
	cQuery += " FROM  "
	cQuery += " " + RetSqlName("SC7") + " AS SC7 "
	
	cQuery += " INNER JOIN "
	cQuery += " " + RetSqlName("SC1") + " AS SC1 ON "
	cQuery += " C7_FILIAL = C1_FILIAL "
	cQuery += " AND C7_PRODUTO = C1_PRODUTO "
	cQuery += " AND C7_NUMSC = C1_NUM "
	cQuery += " AND C7_ITEMSC = C1_ITEM "
	
	cQuery += " WHERE "
	cQuery += " C7_FILIAL = '" + cFil + "' "
	cQuery += " AND C7_NUM = '" + cNum + "' "
	cQuery += " AND C7_ITEM = '" + cItem + "' "
	cQuery += " AND C7_NUMSC <> '' "
	cQuery += " AND C7_ITEMSC <> '' "
	cQuery += " AND SC7.D_E_L_E_T_ = '' "
	cQuery += " AND SC1.D_E_L_E_T_ = '' "
	
	//Verifica se o alias existe.
	If Select("WorkSC1") > 0
		WorkSC1->( dbCloseArea() )
	EndIf
	
	//Executa consulta ao BD.
	tcQuery cQuery New Alias "WorkSC1"
	
	dbSelectArea("WorkSC1")
	WorkSC1->( dbGoTop() )
	
	aDadSC1 := { cValToChar(WorkSC1->C1_REVISAO), cValToChar(WorkSC1->C1_XDDINVE) }
	
	dbCloseArea("WorkSC1")
	
	RestArea(aArea)

Return aDadSC1

/*/{Protheus.doc} Static Function AbreXLS
	(long_description)
	@type  Function
	@author Fernando Macieira
	@since 23/04/2018
	@history Chamado 039677 
/*/
Static Function GeraXLS()

	Local oExcel := FWMsExcelEx():New()
	Local cDirDocs  := MsDocPath()
	Local cPath		:= AllTrim(MV_PAR05)
	Local nLinha    := 0
    Local nExcel    := 1

	Private cArqXLS   := "EXPPROJ.XLS"               
	Private aLinhas   := {}
	Private cStartPath
	
	cIniFile   := GetAdv97()
	cRootPath  := GetPvProfString(GetEnvServer(),"RootPath","ERROR", cIniFile )
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )
	
	cPathData := cRootPath+"\EXPPROJ\"
	
	//dbSelectArea(cArquivo)
	If !ExistDir(cPathData)
		MakeDir(cPathData)
	EndIf
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf
	
	fErase( cPath+cArqXLS )
	fErase( cPathData+cArqXLS )
	
	// Copia arquivo do servidor para diretório local
	//PROJ->( dbCloseArea() )
	
	lExcel := .f.

		// Cabecalho Excel
    oExcel:AddworkSheet(cArqXLS)
	oExcel:AddTable (cArqXLS,cTitulo)
    oExcel:AddColumn(cArqXLS,cTitulo,"FILIAL"         ,1,1) // 01 A
	oExcel:AddColumn(cArqXLS,cTitulo,"PEDIDO"         ,1,1) // 02 B
	oExcel:AddColumn(cArqXLS,cTitulo,"SOLICARMAZ"     ,1,1) // 03 C
	oExcel:AddColumn(cArqXLS,cTitulo,"REQUISICAO"     ,1,1) // 04 D
	oExcel:AddColumn(cArqXLS,cTitulo,"NFISCAL"        ,1,1) // 05 E
	oExcel:AddColumn(cArqXLS,cTitulo,"SERIE"          ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"DATAEMINF"      ,1,1) // 07 G
	oExcel:AddColumn(cArqXLS,cTitulo,"DATAEMIPC"      ,1,1) // 07 G
	oExcel:AddColumn(cArqXLS,cTitulo,"ITEM"           ,1,1) // 08 H
	oExcel:AddColumn(cArqXLS,cTitulo,"CCUSTO"         ,1,1) // 09 I
	oExcel:AddColumn(cArqXLS,cTitulo,"CNPJFORNEC"     ,1,1) // 10 I
	oExcel:AddColumn(cArqXLS,cTitulo,"NOME"           ,1,1) // 11 I
	oExcel:AddColumn(cArqXLS,cTitulo,"PRODUTO"        ,1,1) // 12 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DESCRI"         ,1,1) // 13 I
	oExcel:AddColumn(cArqXLS,cTitulo,"VALOR"          ,1,1) // 14 I
	oExcel:AddColumn(cArqXLS,cTitulo,"CNTPED"         ,1,1) // 15 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DESCCONTA1"     ,1,1) // 16 I
	oExcel:AddColumn(cArqXLS,cTitulo,"CNTCONT"        ,1,1) // 17 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DESCCONTA2"     ,1,1) // 18 I
	oExcel:AddColumn(cArqXLS,cTitulo,"VALORCTB"       ,1,1) // 19 I
	oExcel:AddColumn(cArqXLS,cTitulo,"ENCERRADO"      ,1,1) // 20 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DTDIGNF"        ,1,1) // 21 I
	oExcel:AddColumn(cArqXLS,cTitulo,"VALORNF"        ,1,1) // 22 I
	oExcel:AddColumn(cArqXLS,cTitulo,"NFDEVOL"        ,1,1) // 23 I
	oExcel:AddColumn(cArqXLS,cTitulo,"VLRDEV"         ,1,1) // 24 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DTNFDEV"        ,1,1) // 25 I
	oExcel:AddColumn(cArqXLS,cTitulo,"OBSERVACA"      ,1,1) // 26 I
	oExcel:AddColumn(cArqXLS,cTitulo,"REVESTRUT"      ,1,1) // 27 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DADOSINV"       ,1,1) // 28 I
	oExcel:AddColumn(cArqXLS,cTitulo,"DTLANC"         ,1,1) // 29 I
	oExcel:AddColumn(cArqXLS,cTitulo,"GRUPOPRJ"        ,1,1) // 30 I
	oExcel:AddColumn(cArqXLS,cTitulo,"GRUPDESC"        ,1,1) // 31 I
	oExcel:AddColumn(cArqXLS,cTitulo,"PROJETOPED"     ,1,1) // 32 I
	oExcel:AddColumn(cArqXLS,cTitulo,"PROJETONOT"     ,1,1) // 33 I
	oExcel:AddColumn(cArqXLS,cTitulo,"MESEXTENSO"     ,1,1) // 34 I

    // Gera Excel
    PROJ->( dbGoTop() )
    Do While PROJ->( !EOF() )

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
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "", ; // 08 H   
	   	               "" ; // 08 H   
	   	                   })

		aLinhas[nLinha][01] := PROJ->FILIAL     //A
		aLinhas[nLinha][02] := PROJ->PEDIDO     //B
		aLinhas[nLinha][03] := PROJ->SOLICARMAZ   //C
		aLinhas[nLinha][04] := PROJ->REQUISICAO        //D
		aLinhas[nLinha][05] := PROJ->NFISCAL  //E
		aLinhas[nLinha][06] := PROJ->SERIE          //F
		aLinhas[nLinha][07] := PROJ->DATAEMINF          //F
		aLinhas[nLinha][08] := PROJ->DATAEMIPC          //F
		aLinhas[nLinha][09] := PROJ->ITEM          //F
		aLinhas[nLinha][10] := PROJ->CCUSTO          //F
		aLinhas[nLinha][11] := PROJ->CNPJFORNEC          //F
		aLinhas[nLinha][12] := PROJ->NOME          //F
		aLinhas[nLinha][13] := PROJ->PRODUTO          //F
		aLinhas[nLinha][14] := PROJ->DESCRI          //F
		aLinhas[nLinha][15] := PROJ->VALOR          //F
		aLinhas[nLinha][16] := PROJ->CNTPED          //F
		aLinhas[nLinha][17] := PROJ->DESCCONTA1          //F
		aLinhas[nLinha][18] := PROJ->CNTCONT          //F
		aLinhas[nLinha][19] := PROJ->DESCCONTA2          //F
		aLinhas[nLinha][20] := PROJ->VALORCTB          //F
		aLinhas[nLinha][21] := PROJ->ENCERRADO          //F
		aLinhas[nLinha][22] := PROJ->DTDIGNF          //F
		aLinhas[nLinha][23] := PROJ->VALORNF          //F
		aLinhas[nLinha][24] := PROJ->NFDEVOL          //F
		aLinhas[nLinha][25] := PROJ->VLRDEV          //F
		aLinhas[nLinha][26] := PROJ->DTNFDEV          //F
		aLinhas[nLinha][27] := PROJ->OBSERVACA          //F
		aLinhas[nLinha][28] := PROJ->REVESTRUT          //F
		aLinhas[nLinha][29] := PROJ->DADOSINV          //F
		aLinhas[nLinha][30] := PROJ->DTLANC          //F
		aLinhas[nLinha][31] := PROJ->GRUPOPRJ          //F
		aLinhas[nLinha][32] := PROJ->GRUPDESC          //F
		aLinhas[nLinha][33] := PROJ->PROJETOPED          //F
		aLinhas[nLinha][34] := PROJ->PROJETONOT          //F
		aLinhas[nLinha][35] := PROJ->MESEXTENSO          //F

        PROJ->( dbSkip() )

    EndDo

	// IMPRIME LINHA NO EXCEL
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArqXLS,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08],; // 08 H  
	                                     aLinhas[nExcel][09], ; // 09 I  
	                                     aLinhas[nExcel][10], ; // 09 I  
	                                     aLinhas[nExcel][11], ; // 09 I  
	                                     aLinhas[nExcel][12], ; // 09 I  
	                                     aLinhas[nExcel][13], ; // 09 I  
	                                     aLinhas[nExcel][14], ; // 09 I  
	                                     aLinhas[nExcel][15], ; // 09 I  
	                                     aLinhas[nExcel][16], ; // 09 I  
	                                     aLinhas[nExcel][17], ; // 09 I  
	                                     aLinhas[nExcel][18], ; // 09 I  
	                                     aLinhas[nExcel][19], ; // 09 I  
	                                     aLinhas[nExcel][20], ; // 09 I  
	                                     aLinhas[nExcel][21], ; // 09 I  
	                                     aLinhas[nExcel][22], ; // 09 I  
	                                     aLinhas[nExcel][23], ; // 09 I  
	                                     aLinhas[nExcel][24], ; // 09 I  
	                                     aLinhas[nExcel][25], ; // 09 I  
	                                     aLinhas[nExcel][26], ; // 09 I  
	                                     aLinhas[nExcel][27], ; // 09 I  
	                                     aLinhas[nExcel][28], ; // 09 I  
	                                     aLinhas[nExcel][29], ; // 09 I  
	                                     aLinhas[nExcel][30], ; // 09 I  
	                                     aLinhas[nExcel][31], ; // 09 I  
	                                     aLinhas[nExcel][32], ; // 09 I  
	                                     aLinhas[nExcel][33], ; // 09 I  
	                                     aLinhas[nExcel][34], ; // 09 I  
	                                     aLinhas[nExcel][35] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArqXLS)
    lExcel := .t.
	
	/*
	If CpyS2T( (_cArqTmp)+".DBF" , cPath, .T. )
	
		lExcel := .t.
		fRename( cPath+(_cArqTMP)+".DBF", cPath+cArqXLS )
		
	Else 
		
		// Aviso ao usuario
		Aviso(	"EXPPROJ-01",;
		"Cópia do arquivo falhou! O arquivo XLS será enviado por email..." + chr(13) + chr(10)+;
		""  + chr(13) + chr(10) +;
		"" ,;
		{ "&OK" },,;
		"Projetos - Investimentos" )
	
		fRename( cStartPath+(_cArqTMP)+".DBF", cStartPath+cArqXLS )                   
	
		// Enviar email
		EmailFVL()
	
	EndIf
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta arquivo de Trabalho                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Everson - 18/05/2021. Chamado 14270.
	If Valtype(_cArqTmp) <> "U"
		fErase( (_cArqTmp)+GetDBExtension() )
		fErase( (_cArqTmp)+OrdBagExt() )

	EndIf
	//
	
	
	If lExcel

		msgInfo("Arquivo " + cArqXLS + " gerado com sucesso no path: " + MV_PAR05)
		
		If msgYesNo("Deseja abrí-lo agora?")
		
			// Abre Excel
			If ! ApOleClient( 'MsExcel' )
				MsgStop( 'Excel não instalado! Abra o arquivo manualmente no diretório:' + cPath ) 
				Return
			EndIf
			
			oExcel := MsExcel():New()
			oExcel:WorkBooks:Open( cPath+cArqXLS ) // Abre uma planilha
			oExcel:SetVisible(.T.)
		
		EndIf
	
	EndIf
	
Return

/*/{Protheus.doc} Static Function EmailFVL
	(Envia email com dados do PV Complemento Frango Vivo)
	@type  Function
	@author Fernando Macieira
	@since 18/04/2018
	/*/

Static Function EmailFVL()

	Private cDescri := "Projetos - Arquivo XLS"
	
	LogZBN("1")
	
	ProcRel()
	
	LogZBN("2")
	
Return

/*/{Protheus.doc} Static Function procRel
	(Gera relatório.)
	@type  Function
	@author Fernando Sigoli
	@since 29/03/2018
/*/
Static Function procRel()

	// Declaração de variávies.
	Local aArea		:= GetArea()
	Local cAssunto	:= "Projetos - Arquivo XLS"
	Local cMensagem	:= ""
	Local cQuery	:= ""
	        
	//Private cMails  := GetMV("MV_#PRJMAI",,"fwnmacieira@gmail.com") // -------- APENAS DEBUG
	Private cMails  := GetMV("MV_#PRJMAI",,"jeferson.apolito@adoro.com.br") // -------- VOLTAR ESTA LINHA ANTES DE PUBLICAR EM PRD
	
	//
	cMensagem += '<html>'
	cMensagem += '<body>'
	cMensagem += '<p style="color:red">'+cValToChar(cDescri)+'</p>'
	cMensagem += '<hr>'
	cMensagem += '<table border="1">'
	cMensagem += '<tr style="background-color: black;color:white">'
	cMensagem += '</tr>'
	
	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	//
	ProcessarEmail(cAssunto,cMensagem,cMails)
	
	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function processarEmail
	(Configurações de e-mail.)
	@type  Function
	@author Fernando Sigoli
	@since 29/03/2018
/*/
Static Function ProcessarEmail(cAssunto,cMensagem,email)

	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := email
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.
	Local cAtach        := cStartPath+cArqXLS //"system\EXPPROJ.XLS"
	Local cSubject      := ""
	
	//Assunto do e-mail.
	cSubject := cAssunto
	
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
			ConOut("3 - " + cErrorMsg)
		
		Else
	
			// Aviso ao usuario
			Aviso(	"EXPPROJ-02",;
			"Email enviado com sucesso!"  + chr(13) + chr(10)+;
			"Emails: "  + Left(cMails,66) + chr(13) + chr(10) +;
			"" + Subs(cMails,67,Len(cMails)),;
			{ "&OK" },3,;
			"Projetos - Investimentos" )
		
		EndIf
		
	Else

		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)

	EndIf
	
	If lOk
		Disconnect Smtp Server
	EndIf
	
	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function logZBN
	(Gera log na ZBN.)
	@type  Function
	@author Fernando Sigoli
	@since 29/03/2018
/*/
Static Function logZBN(cStatus)

	// Declaração de variávies.
	Local aArea	:= GetArea()
	Local cNomeRotina := "ADLFV010P"
	Local cDescri := "Projetos - Arquivo XLS"
	
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

// *** INICIO WILLIAM COSTA 29/06/2018 CHAMADO 042341
STATIC FUNCTION BuscaConta(cFilialAtual,cNOTA,cSER,cFornece,cLoja,_nVlr,dDigit,nICMSCOM)

	LOCAL cConta := ''
	
	SqlConta(cFilialAtual,cNOTA,cSER,cFornece,cLoja,_nVlr,dDigit)
	TRC->(DbGoTop())
	While !TRC->(Eof()) 
	                                                          
		IF ALLTRIM(TRC->CT2_DEBITO) <> ''
		
			cConta    := TRC->CT2_DEBITO
			nVlContab := TRC->CT2_VALOR
			
		ENDIF
		
		TRC->(DBSKIP())    
		
	ENDDO
	TRC->(DbCloseArea())
	
	IF ALLTRIM(cConta) = ''
	
		_nVlr := _nVlr + nICMSCOM //Soma o Valor do ICMS COMPLEMENTAR para trazer a conta correta
		
		SqlConta(cFilialAtual,cNOTA,cSER,cFornece,cLoja,_nVlr,dDigit)
		TRC->(DbGoTop())
		While !TRC->(Eof()) 
		                                                          
			IF ALLTRIM(TRC->CT2_DEBITO) <> ''
			
				cConta    := TRC->CT2_DEBITO
				nVlContab := TRC->CT2_VALOR
				
			ENDIF
			
			TRC->(DBSKIP())    
			
		ENDDO
		TRC->(DbCloseArea())
	
	ENDIF
	

RETURN(cConta)

// *** INICIO WILLIAM COSTA 29/06/2018 CHAMADO 042341
STATIC FUNCTION SqlConta(cFilialAtual,cNOTA,cSER,cFornece,cLoja,_nVlr,dDigit)

	Local cFilCT2 := FWFILIAL("CT2")
	Local cData   := DTOS(CTOD(dDigit))

	BeginSQL Alias "TRC"
		     %NoPARSER%
		      SELECT       CT2_DEBITO,
							CT2_CREDIT,
							CT2_FILKEY,
							CT2_PREFIX,
							CT2_NUMDOC,
							CT2_PARCEL,
							CT2_TIPODC,
							CT2_CLIFOR,
							CT2_LOJACF,
							CT2_VALOR
						FROM %TABLE:CT2% WITH (NOLOCK)
						WHERE CT2_FILIAL  = %EXP:cFilCT2%
						  AND CT2_LOTE    = '008810'
						  AND CT2_FILKEY  = %EXP:cFilialAtual%
						  AND CT2_PREFIX  = %EXP:cSER%
						  AND CT2_NUMDOC  = %EXP:cNOTA%
						  AND CT2_TIPODC  = 'NF'  
						  AND CT2_CLIFOR  = %EXP:cFornece%
						  AND CT2_LOJACF  = %EXP:cLoja%
						  AND CT2_VALOR   = %EXP:_nVlr%
						  AND CT2_DATA    = %EXP:cData%
			 		      AND D_E_L_E_T_ <> '*'
	EndSQl

RETURN(NIL)

// *** INICIO WILLIAM COSTA 29/06/2018 CHAMADO 042341
STATIC FUNCTION BuscaRequisicao(dEmissao,cDoc,cCod)

	Local cConta := ''
	
	SqlRequisicao(dEmissao,cDoc,cCod)
	TRD->(DbGoTop())
	While !TRD->(Eof()) 
	                                                          
		IF ALLTRIM(TRD->CT2_DEBITO) <> ''
		
			cConta    := TRD->CT2_DEBITO
			nVlContab := TRD->CT2_VALOR
			
		ENDIF
		
		TRD->(DBSKIP())    
		
	ENDDO
	TRD->(DbCloseArea())
	
RETURN(cConta)	

// *** INICIO WILLIAM COSTA 29/06/2018 CHAMADO 042341
STATIC FUNCTION SqlRequisicao(dEmissao,cDoc,cCod)

	Local cFilCT2 := FWFILIAL("CT2")
	Local cHist   := cDoc + '/' + cCod
	
	BeginSQL Alias "TRD"
		     %NoPARSER%
		        SELECT CT2_DEBITO,
		               CT2_VALOR
				  FROM %TABLE:CT2% WITH (NOLOCK)
			  	 WHERE CT2_FILIAL    = %EXP:cFilCT2%
				   AND CT2_DATA      = %Exp:DTOS(LASTDATE(STOD(dEmissao)))%
				   AND CT2_HIST LIKE '%' + %EXP:cHist% + '%'
				   
	EndSQl

RETURN(NIL) // *** FINAL WILLIAM COSTA 29/06/2018 CHAMADO 042341
