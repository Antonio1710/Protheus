#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "REPORT.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} User Function ADMNT008R
	Relatorio por fornecedor de valores pagos e em aberto
	@type  Function
	@author Mauricio
	@since 10/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 046075 - William Costa - 27/12/2018 - 046075 || OS 047253 || ENGENHARIA || ROSIANE || 8411 || SALDO PROJETO - Ajustado para não ver pedidos rejeitados
	@history Chamado 046111 - FWNM          - 08/01/2019 - Valor requisição zerado
	@history Chamado TI     - FWNM          - 25/02/2019 - REGINALDO CONTROLAD. || Consumo do projeto errado devido elimina residuos e valor total da NF   
	@history Chamado 048738 - FWNM          - 24/04/2019 - 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO
	@history Chamado 049415 - FWNM          - 27/05/2019 - 049415 || OS 050724 || ENGENHARIA || SILVANA || 8406 || REL. PROJETOSA
	@history Chamado 050791 - FWNM          - 30/07/2019 - 050791 - Considerar saldo pedido qdo entrega parcial do item. Exemplo: C7_QUJE < C7_QUANT e C7_QUJE > 0 e C7_ENCER<>E
	@history Chamado 051453 - Adriana Oliv. - 03/09/2019 - 051453 - Considerar impostos de importacao no consumo do projeto
	@history Chamado 053469 - FWNM          - 19/11/2019 - 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO
	@history Chamado 053839 - FWNM          - 05/12/2019 - 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ
	@history Chamado 054064 - FWNM          - 11/12/2019 - OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO
	@history Chamado TI     - FWNM          - 08/05/2020 - Inclusão campo C7_XOBSINT
	@history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	@history Ticket 4174    - William Costa - 03/11/2020 - Solicitação para informar na linha de solicitação de armazém adicionar os seguintes dados Campo Nome Fornecedor = "Almoxarifado" DATA DA DIGITAÇÃO = 'data da emissão' Obs Fornecedor = 'Observação da solicitação ao armazém' Obs Adoro = 'Observação da solicitação ao armazém'
	@history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
	@history Ticket 7715    - Fernando Macie- 08/01/2021 - Divergência de Valor Consumido no Projeto entre Relatório x Posição Projetos
/*/
User Function ADMNT008R()

	Private cAliasTRB    := ""
	Private cPerg        := "RELFORP"
	Private cAprovadores := ''
	
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio por fornecedor de valores pagos e em aberto')
	
	u_xPutSx1(cPerg,"01","Filial de           ?"    , "Filial de           ?"    , "Filial de           ?"    , "mv_ch1","C",2 ,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"02","Filial ate          ?"    , "Filial ate          ?"    , "Filial ate          ?"    , "mv_ch2","C",2 ,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"03","Projeto De"          		,"Projeto De"          ,"Projeto De"          ,"mv_ch3","C",10,0,0,"G",""         ,"AF8","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"04","Projeto Ate"         		,"Projeto Ate"         ,"Projeto Ate"         ,"mv_ch4","C",10,0,0,"G",""         ,"AF8","","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"05","Do C.Custo    "  			,"Do C.Custo    "  		,"Do C.Custo    "  ,"mv_ch5","C",09,0,0,"G","","CTT","","","mv_par05" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"06","Ate o C.Custo "  			,"Ate o C.Custo "  ,"Ate o C.Custo "  ,"mv_ch6","C",09,0,0,"G","","CTT","","","mv_par06" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"07","Fornecedor ?"				,"Fornecedor   ?","Fornecedor  ?","mv_ch7","C",6 ,0,0,"G",""         ,"SA2","","","mv_par07",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"08","Loja ?"						,"Loja   ?","Loja  ?","mv_ch8","C",2 ,0,0,"G",""         ,"","","","mv_par08",""      ,"","","","","","","","","","","","","","","")
	u_xPutSx1(cPerg,"09","Dt Emissao De "          	,"Dt Emissao De "      ,"Dt Emissao De "      ,"mv_ch9","D",08,0,0,"G",""         ,"","","","mv_par09" ,"","","","","","","","","","","","","","",""," ")
	u_xPutSx1(cPerg,"10","Dt Emissao Ate "         	,"Dt Emissao Ate "     ,"Dt Emissao Ate "     ,"mv_chA","D",08,0,0,"G",""         ,"","","","mv_par10" ,"","","","","","","","","","","","","","",""," ")
	
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(@cAliasTRB)
	oReport:PrintDialog()

Return()

/*/{Protheus.doc} Static Function ReportDef
	(long_description)
	@type  Function
	@author user
	@since 19/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportDef(cAliasTRB)

	Local oReport
	Local oProjeto
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	
	oReport := TReport():New("RELFORP",OemToAnsi("Relatorio Projetos e Fornecedor"), cPerg, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+CRLF+;
	OemToAnsi("")+CRLF+;
	OemToAnsi("") )
	
	oReport:SetLandscape()
	//oReport:SetTotalInLine(.F.)
	
	oProjeto := TRSection():New(oReport, OemToAnsi("Projetos/Fornecedor"),{"TRB"}, aOrdem /*{}*/, .F., .F.)
	//oProjeto:SetTotalInLine(.F.)
	
	TRCell():New(oProjeto,	"CODPRJ" ,"","PROJETO"         /*Titulo*/,                        /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DESPRJ" ,"","DESCRICAO"       /*Titulo*/,                        /*Picture*/,35 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"PEDIDO" ,"","PEDIDO"          /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"REQUIS" ,"","REQUISICAO"      /*Titulo*/,                        /*Picture*/,12 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"NFISCAL","","NOTA FISCAL"     /*Titulo*/,                        /*Picture*/,12 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"SERIE"	 ,"","SERIE"           /*Titulo*/,                        /*Picture*/,05 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"EMISSAO","","DATA EMISSAO"    /*Titulo*/,                        /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"CCUSTO" ,"","C. CUSTO"        /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"CODFOR" ,"","COD. FORNEC."    /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"NOME"	 ,"","NOME FORNECEDOR" /*Titulo*/,                        /*Picture*/,30 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"PRODUTO","","PRODUTO"         /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DESCPRD","","DESC PRODUTO"    /*Titulo*/,                        /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) // Chamado n. 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO - FWNM - 19/11/2019
	TRCell():New(oProjeto,	"CONTA"	 ,"","CONTA CONTABIL"  /*Titulo*/,                        /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DATADIG","","DATA DIGIT.NF"   /*Titulo*/,                        /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"VALOR"	 ,"","VALOR"		   /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"NFDEVOL","","DEVOLUCAO"       /*Titulo*/,                        /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"SERDEV" ,"","SERDEV"		   /*Titulo*/,                        /*Picture*/,05 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"VLRDEV" ,"","VLRDEVOLUCAO"    /*Titulo*/,"@E         999,999.99" /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DATDEV" ,"","DT DEVOLUCAO"    /*Titulo*/,                        /*Picture*/,15 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"DESCONTO","","DESCONTO"       /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	TRCell():New(oProjeto,	"CONSUMO","","CONSUMO PROJETO" /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) // Chamado n. 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO - FWNM - 24/04/2019
	TRCell():New(oProjeto,	"STATUS" ,"","STATUS"          /*Titulo*/,                        /*Picture*/,20 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"APROV"  ,"","APROVADOR"       /*Titulo*/,                        /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"OBSFOR" ,"","OBSERVACAO FORNECEDOR"      /*Titulo*/,                        /*Picture*/,70 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"OBSINT" ,"","OBSERVACAO ADORO"      /*Titulo*/,                        /*Picture*/,70 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/) // Chamado TI - 08/05/2020 - FWNM
	
	// @history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
	TRCell():New(oProjeto,	"QTDPC","","QTD PC"       /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"UMPC" ,"","UM PC"       /*Titulo*/,"@!" /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"QTDNF","","QTD NF"       /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"UMNF" ,"","UM NF"       /*Titulo*/,"@!" /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"QTDSA","","QTD SA"       /*Titulo*/,"@E 999,999,999,999.99" /*Picture*/,40 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	TRCell():New(oProjeto,	"UMSA" ,"","UM SA"       /*Titulo*/,"@!" /*Picture*/,10 /*Tamanho*/,/*lPixel*/,/*{|| bloco-de-impressao }*/)
	//

	oBreak1 := TRBreak():New(oProjeto,oProjeto:Cell("CODPRJ"),"S",.F.)
	
	TRFunction():New(oProjeto:Cell("VALOR"),NIL,"SUM",oBreak1,"","@E 999,999,999,999,999.99",/*uFormula*/,.F.,.F.)
	TRFunction():New(oProjeto:Cell("VLRDEV"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)
	TRFunction():New(oProjeto:Cell("CONSUMO"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.) // Chamado n. 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO - FWNM - 24/04/2019
	TRFunction():New(oProjeto:Cell("DESCONTO"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.) // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	
	oBreak1:SetTitle('Totais por Projeto')
	
	//oProjeto:SetLineStyle()

Return(oReport)

/*/{Protheus.doc} Static Function ReportPrint
	(long_description)
	@type  Function
	@author user
	@since 19/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ReportPrint(cAliasTRB)

	Local oProjeto  := oReport:Section(1)
	
	MakeSqlExpr(cPerg)
	
	// Cria e popula TRB para impressão
	fSeleciona()
	
	dbSelectArea("PROJ")
	
	oProjeto:SetMeter( LastRec() )
	
	PROJ->(DbGoTop())
	Do While PROJ->(!EOF())
		
		oProjeto:IncMeter()
		
		oProjeto:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//impressao propriamente dita....
		oProjeto:Cell("CODPRJ")	  :SetBlock( {|| PROJ->PROJETO} )
		oProjeto:Cell("DESPRJ")	  :SetBlock( {|| PROJ->DESCODPRO} )
		oProjeto:Cell("PEDIDO")	  :SetBlock( {|| PROJ->PEDIDO} )
		oProjeto:Cell("REQUIS")	  :SetBlock( {|| PROJ->REQUISICAO} )
		oProjeto:Cell("NFISCAL")  :SetBlock( {|| PROJ->NFISCAL} )
		oProjeto:Cell("SERIE")    :SetBlock( {|| PROJ->SERIE} )
		oProjeto:Cell("EMISSAO")  :SetBlock( {|| PROJ->DATAEMISS} )
		oProjeto:Cell("CCUSTO")	  :SetBlock( {|| PROJ->CCUSTO} )
		oProjeto:Cell("CODFOR")	  :SetBlock( {|| PROJ->CODFORNEC} )
		oProjeto:Cell("NOME")	  :SetBlock( {|| PROJ->NOME} )
		oProjeto:Cell("PRODUTO")  :SetBlock( {|| PROJ->PRODUTO} )
		oProjeto:Cell("DESCPRD")  :SetBlock( {|| PROJ->DESCPRD} ) // Chamado n. 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO - FWNM - 19/11/2019
		oProjeto:Cell("CONTA")    :SetBlock( {|| PROJ->CONTA} )
		oProjeto:Cell("DATADIG")  :SetBlock( {|| PROJ->DTDIGNF} )
		oProjeto:Cell("VALOR")    :SetBlock( {|| PROJ->VALOR} )
		oProjeto:Cell("NFDEVOL")  :SetBlock( {|| PROJ->NFDEVOL} )
		oProjeto:Cell("SERDEV")   :SetBlock( {|| PROJ->SERDEV} )
		oProjeto:Cell("VLRDEV")   :SetBlock( {|| PROJ->VLRDEV} )
		oProjeto:Cell("DATDEV")   :SetBlock( {|| PROJ->DTNFDEV} )
		oProjeto:Cell("DESCONTO") :SetBlock( {|| PROJ->DESCONTO} ) // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório // Chamado n. 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO - FWNM - 24/04/2019
		//oProjeto:Cell("CONSUMO")  :SetBlock( {|| PROJ->VALOR - PROJ->VLRDEV} ) // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório // Chamado n. 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO - FWNM - 24/04/2019
		oProjeto:Cell("CONSUMO")  :SetBlock( {|| PROJ->VALOR - PROJ->VLRDEV - PROJ->DESCONTO} ) // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório // Chamado n. 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO - FWNM - 24/04/2019
		oProjeto:Cell("STATUS")   :SetBlock( {|| PROJ->STATUS} )
		oProjeto:Cell("APROV")    :SetBlock( {|| PROJ->APROV} )
		oProjeto:Cell("OBSFOR")   :SetBlock( {|| PROJ->OBSFOR} )
		oProjeto:Cell("OBSINT")   :SetBlock( {|| PROJ->OBSINT} ) // Chamado TI - 08/05/2020 - FWNM

		// @history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
		oProjeto:Cell("QTDPC")    :SetBlock( {|| PROJ->QTDPC} )
		oProjeto:Cell("UMPC")     :SetBlock( {|| PROJ->UMPC} )
		oProjeto:Cell("QTDNF")    :SetBlock( {|| PROJ->QTDNF} )
		oProjeto:Cell("UMNF")     :SetBlock( {|| PROJ->UMNF} )
		oProjeto:Cell("QTDSA")    :SetBlock( {|| PROJ->QTDSA} )
		oProjeto:Cell("UMSA")     :SetBlock( {|| PROJ->UMSA} )
		//

		oProjeto:PrintLine()
		oReport:IncMeter()
	
		dbSelectArea("PROJ")
		PROJ->(DbSkip())
		
	Enddo
	
	oProjeto:Finish()
	
	PROJ->(dbCloseArea())

Return()

/*/{Protheus.doc} Static Function fSeleciona
	(long_description)
	@type  Function
	@author user
	@since 19/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static function fSeleciona()

	Local nTamLin, cLin, cCpo
	_aStr := {}
	
	AADD(_aStr,{'FILIAL'    ,"C",02})
	AADD(_aStr,{'PEDIDO'    ,"C",06})
	AADD(_aStr,{'PEDATE'    ,"C",01})
	AADD(_aStr,{'REQUISICAO',"C",06})
	AADD(_aStr,{'NFISCAL'   ,"C",09})
	AADD(_aStr,{'SERIE'     ,"C",03})
	AADD(_aStr,{'DATAEMISS' ,"D",08})
	AADD(_aStr,{'ITEM'      ,"C",04})
	AADD(_aStr,{'CCUSTO'    ,"C",09})
	AADD(_aStr,{'CODFORNEC' ,"C",09})
	AADD(_aStr,{'NOME'      ,"C",40})
	AADD(_aStr,{'PRODUTO'   ,"C",15})
	AADD(_aStr,{'DESCPRD'   ,"C",40}) // Chamado n. 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO - FWNM - 19/11/2019
	AADD(_aStr,{'VALOR'     ,"N",17,02})
	AADD(_aStr,{'PROJETO'   ,"C",10})
	AADD(_aStr,{'CONTA'     ,"C",20})
	AADD(_aStr,{'ENCERRADO' ,"C",03})
	AADD(_aStr,{'DTDIGNF'   ,"D",08})
	AADD(_aStr,{'VALORNF'   ,"N",17,02})
	AADD(_aStr,{'NFDEVOL'   ,"C",09})
	AADD(_aStr,{'SERDEV'    ,"C",03})
	AADD(_aStr,{'VLRDEV'    ,"N",17,02})
	AADD(_aStr,{'DTNFDEV'   ,"D",08})
	AADD(_aStr,{'DESCODPRO' ,"C",41})
	//AADD(_aStr,{'OBSERVACA' ,"C",50})
	AADD(_aStr,{'DESCONTO'  ,"N",17,02})  // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	AADD(_aStr,{'CONSUMO'   ,"N",17,02})  // Chamado n. 048738 || OS 050022 || ENGENHARIA || SILVANA || 8406 || SALDO PROJETO - FWNM - 24/04/2019
	AADD(_aStr,{'STATUS'    ,"C",30})
	AADD(_aStr,{'APROV'     ,"C",180})
	AADD(_aStr,{'OBSFOR'    ,"C",254})
	AADD(_aStr,{'OBSINT'    ,"C",254}) // Chamado TI - FWNM - 08/05/2020

	// @history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
	AADD(_aStr,{'QTDPC'     ,"N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2]})
	AADD(_aStr,{'UMPC'      ,"C",TamSX3("C7_UM")[1]})
	AADD(_aStr,{'QTDNF'     ,"N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2]})
	AADD(_aStr,{'UMNF'      ,"C",TamSX3("D1_UM")[1]})
	AADD(_aStr,{'QTDSA'     ,"N",TamSX3("CP_QUANT")[1],TamSX3("CP_QUANT")[2]})
	AADD(_aStr,{'UMSA'      ,"C",TamSX3("CP_UM")[1]})
	//

	_cArqTmp :=CriaTrab(_aStr,.T.)
	DbUseArea(.T.,,_cArqTmp,"PROJ",.F.,.F.)
	_cIndex:="PROJETO+CCUSTO+DTOS(DATAEMISS)"
	indRegua("PROJ",_cArqTmp,_cIndex,,,"Criando Indices...")
	
	IF Empty(MV_PAR07) //Só imprimo requisição se não foi escolhido fornecedor, pois as requisições não possuem vinculo com fornecedor
		
		If Select ("PSCP") > 0
			DbSelectArea("PSCP")
			PSCP->(DbCloseArea())
		Endif
	
		// Query compatibilizada com regras do fonte ADCOM017P (Saldo/Consumo Projeto) - chamado n. 043489
		_cQuery := " SELECT CP_FILIAL, CP_PRODUTO, CP_CONTA, CP_EMISSAO, CP_CC, CP_XPRJVLR, CP_NUM, CP_QUANT, CP_CONPRJ, CP_SOLICIT, CP_CODSOLI, CP_OBS, CP_UM "

		_cQuery += " FROM " + RetSqlName( "SCP" ) + " SCP (NOLOCK) "
	
		_cQuery += "  WHERE CP_FILIAL  BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
		_cQuery += "  AND CP_EMISSAO BETWEEN '" + DTOS(mv_par09)      + "' AND '" + DTOS(mv_par10)     + "' "
		_cQuery += "  AND CP_CONPRJ  BETWEEN '" + mv_par03            + "' AND '" + mv_par04            + "' "
		_cQuery += "  AND CP_CC      BETWEEN '" + mv_par05            + "' AND '" + mv_par06            + "' "
		_cQuery += "  AND SCP.D_E_L_E_T_       = ''    "
	
		_cQuery += " ORDER BY CP_EMISSAO "
	
		TcQuery _cQuery NEW ALIAS "PSCP"
		
		DbSelectArea("PSCP")
	
		ProcRegua( LastRec() )
	
		DbGotop()
		While !EOF()
			
			IncProc("Gerando dados..." + PSCP->CP_NUM)
			
			RecLock("PROJ",.T.)
			
			PROJ->FILIAL     := PSCP->CP_FILIAL
			PROJ->PEDIDO     := SPACE(06)
			PROJ->REQUISICAO := PSCP->CP_NUM
			PROJ->NFISCAL    := SPACE(09)
			PROJ->SERIE      := SPACE(03)
			PROJ->DATAEMISS  := STOD(PSCP->CP_EMISSAO)
			PROJ->ITEM       := SPACE(04)
			PROJ->CCUSTO     := PSCP->CP_CC
			PROJ->CODFORNEC  := SPACE(09)
			PROJ->NOME       := 'ALMOXARIFADO'//SPACE(40)
			PROJ->PRODUTO    := PSCP->CP_PRODUTO
			PROJ->DESCPRD    := Left(AllTrim(Posicione("SB1",1,FWxFilial("SB1")+PSCP->CP_PRODUTO,"B1_DESC")),40) // Chamado n. 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO - FWNM - 19/11/2019
			PROJ->VALOR      := PSCP->CP_XPRJVLR // Chamado n. 046111 
			PROJ->PROJETO    := PSCP->CP_CONPRJ
			PROJ->CONTA      := PSCP->CP_CONTA
			PROJ->STATUS     := 'SOLICITACAO ARMAZEM'
			PROJ->DTDIGNF    := STOD(PSCP->CP_EMISSAO)
			PROJ->APROV      := PSCP->CP_SOLICIT // Chamado n. 049415 || OS 050724 || ENGENHARIA || SILVANA || 8406 || REL. PROJETOSA - FWNM - 27/05/2019
			PROJ->OBSFOR     := PSCP->CP_OBS
			PROJ->OBSINT     := PSCP->CP_OBS

			// @history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
			PROJ->QTDSA     := PSCP->CP_QUANT
			PROJ->UMSA      := PSCP->CP_UM
			//
			
			AF8->( dbSetOrder(1) ) 
			If AF8->( dbSeek(FWxFilial("AF8")+PSCP->CP_CONPRJ) )
				_cEncer          := AF8->AF8_ENCPRJ
				PROJ->ENCERRADO  := IIF(_cEncer == "1","SIM","NAO")
				PROJ->DESCODPRO  := IIF(!EMPTY(PSCP->CP_CONPRJ), AF8->AF8_DESCRI, "")
			EndIf		
			
			MsUnlock()
			
			DbSelectArea("PSCP")
			DbSkip()
			
		Enddo
		
	ENDIF
	
	/////////////////////////////////////////////////////////////////////////////////////////	
	// Notas de Entrada
	/////////////////////////////////////////////////////////////////////////////////////////

	If Select ("PSD1") > 0
		DbSelectArea("PSD1")
		PSD1->(DbCloseArea())
	Endif
	
	// Query compatibilizada com regras do fonte ADCOM017P (Saldo/Consumo Projeto) - chamado n. 043489
	_cQuery2 := " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_PEDIDO, D1_ITEMPC, D1_QUANT, D1_CUSTO, D1_DTDIGIT, D1_ITEM, D1_FORNECE, D1_LOJA, D1_PROJETO, D1_EMISSAO, D1_CC, D1_COD, D1_UM, "

	//Incluido tratamento para nota de importacao - por Adriana - 03/09/2019 - Chamado 051453
	_cQuery2 += " D1_TOTAL = CASE "
	_cQuery2 += " WHEN D1_CF LIKE '3%' "
	_cQuery2 += " THEN D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_VALICM+D1_VALIMP5+D1_VALIMP6+D1_ICMSRET-D1_VALDESC "
	_cQuery2 += " ELSE D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC "
	_cQuery2 += " END, "
  	_cQuery2 += " D1_VALIPI, D1_CONTA, "
	
	_cQuery2 += " (SELECT C7_OBS FROM " + RetSqlName( "SC7" ) + " WHERE C7_FILIAL = D1_FILIAL AND C7_PRODUTO = D1_COD AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC  AND D_E_L_E_T_ = '' ) AS OBSFOR, "
	_cQuery2 += " (SELECT C7_XOBSINT FROM " + RetSqlName( "SC7" ) + " WHERE C7_FILIAL = D1_FILIAL AND C7_PRODUTO = D1_COD AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC  AND D_E_L_E_T_ = '' ) AS OBSINT, " // Chamado TI - FWNM - 08/05/2020

	_cQuery2 += " (SELECT C7_CONAPRO FROM " + RetSqlName( "SC7" ) + " SC7 WITH (NOLOCK) WHERE C7_FILIAL = D1_FILIAL AND C7_PRODUTO = D1_COD AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.D_E_L_E_T_ = '' ) AS CONAPRO "
	
	_cQuery2 += " FROM "
	_cQuery2 +=  RetSqlName( "SD1" ) + " SD1 WITH (NOLOCK), "
	_cQuery2 +=  RetSqlName( "SF4" ) + " SF4 WITH (NOLOCK), "
	_cQuery2 +=  RetSqlName( "SF1" ) + " SF1 WITH (NOLOCK) " // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	
	//_cQuery2 += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_='' AND F1_STATUS='A'
	_cQuery2 += " WHERE F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_TIPO=D1_TIPO AND F1_FORNECE=D1_FORNECE AND F1_LOJA=D1_LOJA AND SF1.D_E_L_E_T_='' " // @history Ticket 7715    - Fernando Macie- 08/01/2021 - Divergência de Valor Consumido no Projeto entre Relatório x Posição Projetos

	_cQuery2 += " AND D1_TES=F4_CODIGO "
	//_cQuery2 += " WHERE D1_TES=F4_CODIGO "
	//
	
	_cQuery2 += "  AND D1_FILIAL  BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
	_cQuery2 += "  AND D1_EMISSAO BETWEEN '" + DTOS(mv_par09)      + "' AND '" + DTOS(mv_par10)      + "' "
	_cQuery2 += "  AND D1_PROJETO BETWEEN '" + mv_par03            + "' AND '" + mv_par04            + "' "
	_cQuery2 += "  AND D1_CC      BETWEEN '" + mv_par05            + "' AND '" + mv_par06            + "' "
	
	If !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
		_cQuery2 += "AND D1_FORNECE = '" + mv_par07+ "' AND D1_LOJA ='" + mv_par08 + "' "
	
	ElseIf !Empty(MV_PAR07) .And. Empty(MV_PAR08)
		_cQuery2 += "AND D1_FORNECE = '"+ mv_par07+ "'
	
	Endif
	
	//_cQuery2 += " AND SD1.D1_TES <> ' ' " // //@history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	_cQuery2 += " AND F4_DUPLIC='S' "
	_cQuery2 += " AND SD1.D_E_L_E_T_ = '' "
	_cQuery2 += " AND SF4.D_E_L_E_T_ = '' "
	
	TcQuery _cQuery2 NEW ALIAS "PSD1"
	
	DbSelectArea("PSD1")
	
	ProcRegua( LastRec() )
		
	DbGotop()
	While PSD1->(!EOF())
	
		IncProc("Gerando dados... " + PSD1->D1_DOC)
	
		_cNOTA := PSD1->D1_DOC
		_cSER  := PSD1->D1_SERIE
		_cDT   := PSD1->D1_DTDIGIT
		_cEMIS := PSD1->D1_EMISSAO
		_nVlr  := PSD1->D1_CUSTO
		_cFOR  := PSD1->D1_FORNECE
		_cLOJ  := PSD1->D1_LOJA
		_cITE  := PSD1->D1_ITEM
		_nQTD  := PSD1->D1_QUANT
		
		/////////////////////////////////////////////////////////////////////////////////////////	
		// Devoluções de Compras
		/////////////////////////////////////////////////////////////////////////////////////////
	
		If Select ("PSD2") > 0
			DbSelectArea("PSD2")
			PSD2->(DbCloseArea())
		Endif
		
		_cQuery3 := "SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_QUANT, D2_TOTAL-D2_DESCON D2_TOTAL, D2_EMISSAO "
	
		_cQuery3 += "FROM "
		_cQuery3 += RetSqlName( "SD2" ) + " SD2 WITH (NOLOCK)"
	
		_cQuery3 += " WHERE D2_FILIAL BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' "
		_cQuery3 += " AND D2_TIPO = 'D' "
	
		_cQuery3 += " AND SD2.D2_NFORI = '" + _cNOTA + "' "
		_cQuery3 += " AND SD2.D2_SERIORI = '" + _cSER  + "' "
		_cQuery3 += " AND SD2.D2_CLIENTE = '" + _cFOR  + "' "
		_cQuery3 += " AND SD2.D2_LOJA    = '" + _cLOJ  + "' "
		_cQuery3 += " AND SD2.D2_ITEMORI = '" + _cITE  + "' "
		_cQuery3 += " AND SD2.D2_XPROJET BETWEEN '" + mv_par03            + "' AND '" + mv_par04            + "' "
	
		_cQuery3 += "AND SD2.D_E_L_E_T_ = '' "
		
		TcQuery _cQuery3 NEW ALIAS "PSD2"
		
		DbSelectarea("PSD2")
		DBGOTOP()
	
		IF PSD2->(!EOF())
			//Tratamento para apurar valor proporcional para NF devolucao conforme acordado com Jair Sbaraini.
			_cNFDEV := PSD2->D2_DOC
			_cSEDEV := PSD2->D2_SERIE
	
			If _nQTD <> PSD2->D2_QUANT
				_nVLDEV := Round((_nVlr/_nQTD)* PSD2->D2_QUANT,2)
	
			Else
				_nVLDEV := _nVlr
	
			Endif

			_nVLDEV := PSD2->D2_TOTAL
			_dDTDEV := PSD2->D2_EMISSAO
	
		ELSE
			_cNFDEV := SPACE(09)
			_cSEDEV := SPACE(02)
			_nVLDEV := 0.00
			_dDTDEV := SPACE(10)
	
		ENDIF
		
		RecLock("PROJ",.T.)
	
		PROJ->FILIAL     := PSD1->D1_FILIAL
		PROJ->PEDIDO     := PSD1->D1_PEDIDO
		PROJ->REQUISICAO := SPACE(06)
		PROJ->NFISCAL    := _cNOTA
		PROJ->SERIE      := _cSER
		PROJ->DATAEMISS  := STOD(PSD1->D1_EMISSAO)
		PROJ->CCUSTO     := PSD1->D1_CC
		PROJ->CODFORNEC  := PSD1->D1_FORNECE+"-"+PSD1->D1_LOJA
		PROJ->NOME       := Left(AllTrim(Posicione("SA2",1,FWxFilial("SA2")+PSD1->D1_FORNECE+PSD1->D1_LOJA,"A2_NOME")),40)
		PROJ->PRODUTO    := PSD1->D1_COD
		PROJ->DESCPRD    := Left(AllTrim(Posicione("SB1",1,FWxFilial("SB1")+PSD1->D1_COD,"B1_DESC")),40) // Chamado n. 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO - FWNM - 19/11/2019
		PROJ->VALOR      := PSD1->D1_TOTAL
		PROJ->PROJETO    := PSD1->D1_PROJETO
		PROJ->CONTA      := PSD1->D1_CONTA
		PROJ->DTDIGNF    := STOD(_cDT)
		PROJ->VALORNF    := _nVlr
		PROJ->NFDEVOL    := _cNFDEV
		PROJ->SERDEV     := _cSEDEV
		PROJ->VLRDEV     := _nVLDEV
		PROJ->DTNFDEV    := STOD(_dDTDEV)
		PROJ->STATUS     := 'NOTA FISCAL'
		PROJ->APROV      := IIF(!EMPTY(PSD1->D1_PEDIDO), PesqAPR(PSD1->D1_FILIAL,PSD1->D1_PEDIDO), "")
		PROJ->OBSFOR     := PSD1->OBSFOR
		PROJ->OBSINT     := PSD1->OBSINT // Chamado TI - FWNM - 08/05/2020

		// @history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
		PROJ->QTDNF     := PSD1->D1_QUANT
		PROJ->UMNF      := PSD1->D1_UM
		//

		AF8->( dbSetOrder(1) ) 
		If AF8->( dbSeek(FWxFilial("AF8")+PSD1->D1_PROJETO) )
			_cEncer          := AF8->AF8_ENCPRJ
			PROJ->ENCERRADO  := IIF(_cEncer == "1","SIM","NAO")
			PROJ->DESCODPRO  := IIF(!EMPTY(PSD1->D1_PROJETO), AF8->AF8_DESCRI, "")
		EndIf		
	
		MsUnlock()
	
		DbSelectArea("PSD1")
		PSD1->(Dbskip())
		
	Enddo
	
	
	/////////////////////////////////////////////////////////////////////////////////////////
	// Pedidos de Compras - SEM NF
	/////////////////////////////////////////////////////////////////////////////////////////

	If Select ("PSC7") > 0
		DbSelectArea("PSC7")
		PSC7->(DbCloseArea())
	Endif
	
	// Chamado n. 054064 || OS 055455 || CONTROLADORIA || DAIANE || (16) || SALDO DE PROJETO - fwnm - 11/12/2019
	/*
	// Query compatibilizada com regras do fonte ADCOM017P (Saldo/Consumo Projeto) - chamado n. 043489
	_cQuery4 := "SELECT C7_FILIAL,C7_PROJETO,C7_NUM,C7_EMISSAO,C7_CC,C7_FORNECE,C7_LOJA,C7_PRODUTO,C7_CONTA,C7_OBS,C7_CONAPRO,C7_APROV, "

	// Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ - fwnm - 05/12/2019
	_cQuery4 += " C7_TOTAL = CASE "
	_cQuery4 += " WHEN C7_MOEDA <= 1 "
	_cQuery4 += " THEN C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC "
	_cQuery4 += " ELSE (C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)*C7_XTXMOED "
	_cQuery4 += " END, R_E_C_N_O_ "
	//

	_cQuery4 += "FROM "
	_cQuery4 += RetSqlName( "SC7" ) + " SC7 WITH (NOLOCK) "
	
	_cQuery4 += " WHERE C7_FILIAL          >= " + "'" + AllTrim(MV_PAR01) + "'"
	_cQuery4 += "   AND C7_FILIAL          <= " + "'" + AllTrim(MV_PAR02) + "'"
	_cQuery4 += "   AND C7_EMISSAO         >= " + "'" +    DTOS(MV_PAR09)  + "'"
	_cQuery4 += "   AND C7_EMISSAO        <= " + "'" +    DTOS(MV_PAR10)  + "'"
	_cQuery4 += "   AND C7_CC              >= " + "'" +         MV_PAR05  + "'"
	_cQuery4 += "   AND C7_CC              <= " + "'" +         MV_PAR06  + "'"
	_cQuery4 += "   AND C7_PROJETO         >= " + "'" +         MV_PAR03  + "'"
	_cQuery4 += "   AND C7_PROJETO         <= " + "'" +         MV_PAR04  + "'"
	_cQuery4 += "   AND C7_PROJETO         <> '' "
	_cQuery4 += "   AND C7_RESIDUO         <> 'S' "
	_cQuery4 += "   AND C7_CONAPRO         <> 'R' " // Não trazer os pedidos rejeitados 27/12/2018 William Costa chamado 046075 
	
	IF !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
		_cQuery4 += " AND C7_FORNECE = '" + mv_par07 + "' "
		_cQuery4 += " AND C7_LOJA    = '" + mv_par08 + "' "
	
	Elseif !Empty(MV_PAR07) .And. Empty(MV_PAR08)
		_cQuery4 += "AND C7_FORNECE = '" + mv_par07+ "'
	
	Endif
	
	_cQuery4 += "   AND SC7.D_E_L_E_T_    = '' "

	_cQuery4 += " AND NOT EXISTS "
	_cQuery4 += " ( "
	_cQuery4 += " SELECT 'X' "
	_cQuery4 += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
	_cQuery4 += " WHERE D1_FILIAL=C7_FILIAL "
	_cQuery4 += " AND D1_PEDIDO=C7_NUM "
	_cQuery4 += " AND D1_ITEMPC=C7_ITEM "
	_cQuery4 += " AND D_E_L_E_T_='' "
	_cQuery4 += " ) "
    
	_cQuery4 += " UNION "
	
	/////////////////////////////////////////////////////////////////////////////////////////
	// Pedidos de Compras - COM PRE NOTA
	/////////////////////////////////////////////////////////////////////////////////////////
	_cQuery4 += "SELECT C7_FILIAL,C7_PROJETO,C7_NUM,C7_EMISSAO,C7_CC,C7_FORNECE,C7_LOJA,C7_PRODUTO,C7_CONTA,C7_OBS,C7_CONAPRO,C7_APROV, "

	// Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ - fwnm - 05/12/2019
	_cQuery4 += " C7_TOTAL = CASE "
	_cQuery4 += " WHEN C7_MOEDA <= 1 "
	_cQuery4 += " THEN C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC "
	_cQuery4 += " ELSE (C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)*C7_XTXMOED "
	_cQuery4 += " END, R_E_C_N_O_  "
	//
	
	_cQuery4 += "FROM "
	_cQuery4 += RetSqlName( "SC7" ) + " SC7 WITH (NOLOCK) "
	
	_cQuery4 += " WHERE C7_FILIAL          >= " + "'" + AllTrim(MV_PAR01) + "'"
	_cQuery4 += "   AND C7_FILIAL          <= " + "'" + AllTrim(MV_PAR02) + "'"
	_cQuery4 += "   AND C7_EMISSAO         >= " + "'" +    DTOS(MV_PAR09)  + "'"
	_cQuery4 += "   AND C7_EMISSAO        <= " + "'" +    DTOS(MV_PAR10)  + "'"
	_cQuery4 += "   AND C7_CC              >= " + "'" +         MV_PAR05  + "'"
	_cQuery4 += "   AND C7_CC              <= " + "'" +         MV_PAR06  + "'"
	_cQuery4 += "   AND C7_PROJETO         >= " + "'" +         MV_PAR03  + "'"
	_cQuery4 += "   AND C7_PROJETO         <= " + "'" +         MV_PAR04  + "'"
	_cQuery4 += "   AND C7_PROJETO         <> '' "
	_cQuery4 += "   AND C7_RESIDUO         <> 'S' "
	_cQuery4 += "   AND C7_CONAPRO         <> 'R' " 
	
	IF !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
		_cQuery4 += " AND C7_FORNECE = '" + mv_par07 + "' "
		_cQuery4 += " AND C7_LOJA    = '" + mv_par08 + "' "
	
	Elseif !Empty(MV_PAR07) .And. Empty(MV_PAR08)
		_cQuery4 += "AND C7_FORNECE = '" + mv_par07+ "'
	
	Endif
	
	_cQuery4 += "   AND SC7.D_E_L_E_T_    = '' "

	_cQuery4 += " AND EXISTS "
	_cQuery4 += " ( "
	_cQuery4 += " SELECT 'X' "
	_cQuery4 += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
	_cQuery4 += " WHERE D1_FILIAL=C7_FILIAL "
	_cQuery4 += " AND D1_PEDIDO=C7_NUM "
	_cQuery4 += " AND D1_ITEMPC=C7_ITEM "
	_cQuery4 += " AND D1_TES='' "
	_cQuery4 += " AND D_E_L_E_T_='' "
	_cQuery4 += " ) "

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// pedido com saldo parcial do item. Exemplo: C7_QUJE < C7_QUANT e C7_QUJE > 0 e C7_ENCER<>E (FWNM - 30/07/2019 - Chamado 050791)
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	_cQuery4 += " UNION "
	*/

	_cQuery4 := "SELECT C7_FILIAL,C7_PROJETO,C7_NUM,C7_EMISSAO,C7_CC,C7_FORNECE,C7_LOJA,C7_PRODUTO,C7_CONTA,C7_OBS,C7_XOBSINT,C7_CONAPRO,C7_APROV, C7_QUANT, C7_UM, "

	// Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ - fwnm - 05/12/2019
	_cQuery4 += " C7_TOTAL = CASE "
	_cQuery4 += " WHEN C7_MOEDA <= 1 "
	_cQuery4 += " THEN ROUND(((C7_QUANT-C7_QUJE)*C7_PRECO),2)              + ROUND(((C7_VALIPI/C7_QUANT)*(C7_QUANT-C7_QUJE)),2)              + ROUND(((C7_VALFRE/C7_QUANT)*(C7_QUANT-C7_QUJE)),2)              + ROUND(((C7_DESPESA/C7_QUANT)*(C7_QUANT-C7_QUJE)),2)              + ROUND(((C7_SEGURO/C7_QUANT)*(C7_QUANT-C7_QUJE)),2)              + ROUND(((C7_ICMSRET/C7_QUANT)*(C7_QUANT-C7_QUJE)),2) "
	_cQuery4 += " ELSE ROUND((((C7_QUANT-C7_QUJE)*C7_PRECO)*C7_XTXMOED),2) + ROUND((((C7_VALIPI/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2) + ROUND((((C7_VALFRE/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2) + ROUND((((C7_DESPESA/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2) + ROUND((((C7_SEGURO/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2) + ROUND((((C7_ICMSRET/C7_QUANT)*(C7_QUANT-C7_QUJE))*C7_XTXMOED),2) "
	_cQuery4 += " END, R_E_C_N_O_, C7_VLDESC  " // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
//	_cQuery4 += " END, R_E_C_N_O_  " // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório
	//

	_cQuery4 += "FROM "
	_cQuery4 += RetSqlName( "SC7" ) + " SC7 WITH (NOLOCK) "
	
	_cQuery4 += " WHERE C7_FILIAL          >= " + "'" + AllTrim(MV_PAR01) + "'"
	_cQuery4 += "   AND C7_FILIAL          <= " + "'" + AllTrim(MV_PAR02) + "'"
	_cQuery4 += "   AND C7_EMISSAO         >= " + "'" +   DTOS(MV_PAR09)  + "'"
	_cQuery4 += "   AND C7_EMISSAO        <= " + "'" +    DTOS(MV_PAR10)  + "'"
	_cQuery4 += "   AND C7_CC              >= " + "'" +         MV_PAR05  + "'"
	_cQuery4 += "   AND C7_CC              <= " + "'" +         MV_PAR06  + "'"
	_cQuery4 += "   AND C7_PROJETO         >= " + "'" +         MV_PAR03  + "'"
	_cQuery4 += "   AND C7_PROJETO         <= " + "'" +         MV_PAR04  + "'"
	_cQuery4 += "   AND C7_PROJETO         <> '' "
	_cQuery4 += "   AND C7_RESIDUO         <> 'S' "
	_cQuery4 += "   AND C7_CONAPRO         <> 'R' " 
	
	//_cQuery4 += " AND C7_ENCER<>'E' "
	//_cQuery4 += " AND C7_QUJE>0 "
	//_cQuery4 += " AND C7_QUANT<>C7_QUJE "
	
	IF !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
		_cQuery4 += " AND C7_FORNECE = '" + mv_par07 + "' "
		_cQuery4 += " AND C7_LOJA    = '" + mv_par08 + "' "
	
	Elseif !Empty(MV_PAR07) .And. Empty(MV_PAR08)
		_cQuery4 += "AND C7_FORNECE = '" + mv_par07+ "'
	
	Endif
	
	_cQuery4 += "   AND SC7.D_E_L_E_T_    = '' "

	/*
	_cQuery4 += " AND EXISTS "
	_cQuery4 += " ( "
	_cQuery4 += " SELECT 'X' "
	_cQuery4 += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
	_cQuery4 += " WHERE D1_FILIAL=C7_FILIAL "
	_cQuery4 += " AND D1_PEDIDO=C7_NUM "
	_cQuery4 += " AND D1_ITEMPC=C7_ITEM "
	_cQuery4 += " AND D_E_L_E_T_='' "
	_cQuery4 += " ) "
	*/
	
	TcQuery _cQuery4 NEW ALIAS "PSC7"
	
	DbSelectArea("PSC7")
	
	ProcRegua( LastRec() )
	
	DbGotop()
	While PSC7->(!EOF())
		
		IncProc("Gerando dados...")
		
		If Select ("PSCR") > 0
			DbSelectArea("PSCR")
			PSCR->(DbCloseArea())
		Endif
		
		_cQuery5 := "SELECT CR_NUM, CR_USER,CR_DATALIB  "
		_cQuery5 += "FROM "
		_cQuery5 += RetSqlName( "SCR" ) + " SCR WITH (NOLOCK) "
		_cQuery5 += " WHERE CR_NUM      = " + "'" + PSC7->C7_NUM + "'"
		_cQuery5 += "   AND D_E_L_E_T_ <> '*' "
		_cQuery5 += "   ORDER BY CR_NIVEL "
		
		TcQuery _cQuery5 NEW ALIAS "PSCR"
		
		cAprovadores := ''
		DbSelectArea("PSCR")
		DbGotop()
		While PSCR->(!EOF())
			
			cAprovadores += PSCR->CR_USER + '-' + Alltrim(UsrRetName(PSCR->CR_USER)) + '||' + "Dt Lib: " + DTOC(STOD(PSCR->CR_DATALIB)) + " "
			
			DbSelectArea("PSCR")
			PSCR->(Dbskip())
			
		ENDDO
		
		RecLock("PROJ",.T.)
		
		PROJ->FILIAL     := PSC7->C7_FILIAL
		PROJ->PEDIDO     := PSC7->C7_NUM
		PROJ->REQUISICAO := SPACE(06)
		PROJ->NFISCAL    := SPACE(09)
		PROJ->SERIE      := SPACE(03)
		PROJ->DATAEMISS  := STOD(PSC7->C7_EMISSAO)
		PROJ->CCUSTO     := PSC7->C7_CC
		PROJ->CODFORNEC  := PSC7->C7_FORNECE+"-"+PSC7->C7_LOJA
		PROJ->NOME       := Left(AllTrim(Posicione("SA2",1,FWxFilial("SA2")+PSC7->C7_FORNECE+PSC7->C7_LOJA,"A2_NOME")),40)
		PROJ->PRODUTO    := PSC7->C7_PRODUTO
		PROJ->DESCPRD    := Left(AllTrim(Posicione("SB1",1,FWxFilial("SB1")+PSC7->C7_PRODUTO,"B1_DESC")),40) // Chamado n. 053469 || OS 054845 || ENGENHARIA || JEFERSON || 8406 || RELATORIO DE PROJETO - FWNM - 19/11/2019
		PROJ->VALOR      := PSC7->C7_TOTAL
		PROJ->PROJETO    := PSC7->C7_PROJETO
		PROJ->CONTA      := PSC7->C7_CONTA
		PROJ->DTDIGNF    := STOD(PSC7->C7_EMISSAO)
		PROJ->VALORNF    := 0
		PROJ->NFDEVOL    := SPACE(9)
		PROJ->SERDEV     := SPACE(3)
		PROJ->VLRDEV     := 0
		PROJ->STATUS     := 'PEDIDO COMPRA'
		PROJ->APROV      := cAprovadores
		PROJ->OBSFOR     := PSC7->C7_OBS
		PROJ->OBSINT     := PSC7->C7_XOBSINT
		PROJ->DESCONTO   := PSC7->C7_VLDESC // @history Ticket 705     - FWNM          - 31/08/2020 - Projetos Investimentos - Divergência em Relatório

		// @history Ticket 6653    - Fernando Macie- 15/12/2020 - Incluir a Quantidade do material no Relatório de projetos Detalhados, facilitando a analise de compra
		PROJ->QTDPC     := PSC7->C7_QUANT
		PROJ->UMPC      := PSC7->C7_UM
		//

		AF8->( dbSetOrder(1) ) 
		If AF8->( dbSeek(FWxFilial("AF8")+PSC7->C7_PROJETO) )
			_cEncer          := AF8->AF8_ENCPRJ
			PROJ->ENCERRADO  := IIF(_cEncer == "1","SIM","NAO")
			PROJ->DESCODPRO  := IIF(!EMPTY(PSC7->C7_PROJETO), AF8->AF8_DESCRI, "")
		EndIf		
	
		MsUnlock()
	
		DbSelectArea("PSC7")
		PSC7->(Dbskip())
		
	Enddo

Return()

/*/{Protheus.doc} Static Function PESQAPR
	RETORNA OS APROVADORES DOS PEDIDOS, MESMO QUE APOS ESTEJA COM NOTA FISCAL
	@type  Function
	@author user
	@since 19/11/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function PesqAPR(cFilCor,cPedCor)

	Local cQuy 	:= ""
	Local cAprv := ""
	
	If Select ("QSCR") > 0
		
		DbSelectArea("QSCR")
		QSCR->(DbCloseArea())
		
	Endif
	
	cQuy := " SELECT CR_NUM, CR_USER, CR_DATALIB  "
	cQuy += " FROM "
	cQuy += RetSqlName( "SCR" ) + " SCR WITH (NOLOCK) "
	cQuy += " WHERE  CR_FILIAL = '"+cFilCor+"' AND CR_NUM = '"+cPedCor + "' "
	cQuy += "   AND D_E_L_E_T_ <> '*' "
	cQuy += "   ORDER BY CR_NIVEL "
	
	TcQuery cQuy NEW ALIAS "QSCR"
	
	DbSelectArea("QSCR")
	DbGotop()
	
	While QSCR->(!EOF())
		
		cAprv += QSCR->CR_USER + '-' + Alltrim(UsrRetName(QSCR->CR_USER)) + '||' + "Dt Lib: " + DTOC(STOD(QSCR->CR_DATALIB)) + " "
		
		DbSelectArea("QSCR")
	
		QSCR->(Dbskip())
	
	ENDDO

Return(cAprv)
