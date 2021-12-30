#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function INTNFEb 
    Vai garar Pre-Notas por uma op็ใo no menu do usuario   
    @type  Function
    @author Microsiga
    @since 07/19/2013 
    @version version
    @history chamado TI
	@history chamado 044933 - Fernanado Sigoli  13/03/2019   - Tratamento para validar na integra็ใo de nota e cte se cnpj da do fornecedor esta de-acordo com a chave da nota 
    @history chamado 047834 - Fernanado Sigoli  13/03/2019   - Removido codigo de produto chumbado, para pegar do banco intermediario  
    @history chamado 048963 - Everson           06/05/2019   - Adicionado o campo F1_DESPESA no cabe็alho da nota. 
    @history chamado 048580 - || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 14/05/2019
    @history chamado 047900 - || OS 049165 || FISCAL || ALLAN || 8394 || VALIDAR EMISSAO CTE - FWNM - 14/05/2019 
    @history chamado 048529 - || OS 049805 || FISCAL || ALLAN || 8394 ||ณ|| VALIDAR NFE INT - FWNM - 14/05/2019 
    @history chamado TI     - || Formulario proprio nao devera consistir Central XML - FWNM - 14/05/2019 
    @history chamado TI     - || Fernando Sigol 16/05/2019-Tratamento na valida็ใo para eliminar zero a esquerda para validar serie SAG x Central 
    @history chamado TI     - || Fernando Sigol 16/05/2019-Tratamento na valida็ใo para eliminar zero a esquerda para validar serie SAG x Central 
    @history chamado TI     - || Fernando Sigoli 20/05/2019-Tratamento na valida็ใo da serie para SAG x Central   
    @history chamado TI     - || Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM 
    @history chamado 050135 - || Fernando Sigoli 01/07/2019 -  Nao consistir na central xmlquando Especie NF  Sobra de racao
    @history chamado 050855 - || Leon 05/08/2019 -  Entrada por compra para armazenagem em terceiros. NF nao aparece para importar
    @history chamado 046976 - || William 09/08/2019 - Quando for frango vivo apanha nao deixar entrar com a nota na empresa 02 se a data de emissao for menor que a nota de saida de Sใo Carlos
    @history chamado 046976 - || Leon   13/08/2019  - Corre็ใo de zeros a esquerda para campo F1_DOC. Linha 1062.
    @history chamado 052097 - || OS 053474 || FISCAL || SIMONE || 8463 || CTES 3182 ณE 3189 - FWNM - 02/10/2019       
    @history chamado 052097 - || Exclusao de NF - Filtrar OPERACAO_INT <> E  ณFWNM - 03/10/2019 
    @history chamado 052097 - || Formulario proprio nao consistir CNPJ Destino ณFWNM - 04/10/2019  
    @history chamado 052097 - || Nao consistir valor quando nao possuir chave eletronica - FWNM - 04/10/2019
    @history chamado 052097 - || Consistir valor considerando apenas 1 digito decimal    - FWNM - 04/10/2019   
    @history chamado 052348 - || Tratamento para notas de transfer๊ncia entre filiais - Everson - 18/10/2019.
    @history chamado 055874 - || Fernando Sigoli 17/02/2020 - OS 057283 || FISCAL || NOEMI || 21063534 || INTEGRACAO CTE/Valida็ใo E2_NATUREZ
    @history chamado 057922 - || Fernando Sigoli 07/05/2020 - OS 059404 || CONTROLADORIA || THIAGO || 8439 || ORDEM CARREGAMENTO ALTERADO PARA PEGAR DATA F1_DTDIGIT BANCO DBINTERFACE
	@history chamado 058500 - || Everson 27/05/2020. Alterada a forma como o c๓digo da condi็ใo de pagamento ้ composto.
	@history chamado 060547 - || Everson 12/08/2020. Tratamento para trazer somente as transfer๊ncias entre empresas com data igual a data base.
	@history ticket    3873 - Fernando Macieira - 26/10/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
	@history ticket    3873 - Fernando Macieira - 24/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
	@history ticket    3873 - Fernando Macieira - 25/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
	@history ticket    T.I  - Fernando Sigoli   - 02/12/2020 - Removido fun็ใo transmNF que transmite notas automaticamente
	@history ticket    T.I  - Fernando Sigoli   - 07/12/2020 - Retornado fun็ใo transmNF que transmite notas automaticamente
	@history ticket    6082 - Fernando Macieira - 07/12/2020 - IMPORTAวรO NF 49322 - PC n. S0
	@history ticket    6376 - Fernando Macieira - 09/12/2020 - ERRO DE LOG IMPORTAวรO
	@history ticket    7257 - Fernando Sigoli   - 28/12/2020 - IMPORTAวรO DE CTE
	@history ticket    8201 - Fernando Macieira - 18/01/2021 - IMPORTAวรO NFS 13820 E 13821
	@history ticket   14360 - Everson 			- 24/05/2021 - Tratamento para valida็ใo de importa็ใo de nota fiscal de produtor rural, movimento 6.
	@history ticket   33037 - Fernando Sigoli   - 01/10/2021 - Corre็ใo notas de Transferencia 
	@history ticket   62952 - Fernando Sigoli   - 27/10/2021 - Na inclusa do PC carregar na condi็ใo de pagamento que vem do SAG e nao mais do parametro.
	@history ticket   64254 - Jonathan Carvalho - 30/11/2021 - Filtro: 8 Frango 1 retorno de cria็ใo puxar 50 registros por vez
	@history ticket   65598 - Jonathan Carvalho - 28/12/2021 - Filtro: 8 Frango 1 retorno corre็ใo no filtro do ticket 64254 e ordena็ใo

/*/
User Function INTNFEB()
	Local aArea             := GetArea()
	Local oInterface
	Local oSBtn01
	Local oSBtn02
	Local oSBtn03
	Local oSBtn04
	Local oSBtn05
	Local oGroupTot
	Local oGroup1
	Local oFontDtBs         := TFont():New(,,-15,.T.)
	Local oTxtBusca
	Local cSelBusca         := ""
	Local oSelBusca
	Local aSelBusca         := {}
	Local oBusca
	Local oBtnBusca
	Local oCSV 
	Private cBusca          := ""
	Private _sDtLim         := DToS(dDatabase)
	Private _conProthe      := advConnection()
	Private _conSAG
	Private _cNomBco2
	Private _cSrvBco2
	Private _cPortBco2
	Private oCombo2
	Private aFiltro         := {}
	Private oQtdReg
	Private nQtdReg         := 0
	Private oDtBase
	Private cDtBase         := DToC(dDatabase)
	Private nOpcImp         := ""
	Private oRegistros
	Private aHInterface     := {}
	Private aAltInterface   := {}
	Private aColsInterface  := {}
	Private cInsSer         := Alltrim(cValToChar(GetMv("MV_#SERIMP"))) // Everson - 03/07/2017. Chamado 035012.
	Private cNFApanha       := ''
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Vai gerar Pre-Notas por uma op็ใo no menu do usuario ')
	// FWNM - CHAMADO 037757 - 07/05/2018
	If msgYesNo("Classificar as notas fiscais diแrias de Complemento de Frango Vivo?")
		LFVClass()
		Return
	EndIf
	// FWNM - FIM
	aFiltro := {}
	Aadd(aFiltro,"1=Todos")
	Aadd(aFiltro,"2=Entrada por compra")
	Aadd(aFiltro,"3=Entrada por devolu็ใo")
	Aadd(aFiltro,"4=Entrada por transfer๊ncia filial")
	Aadd(aFiltro,"5=Notas de servi็o")
	Aadd(aFiltro,"6=Entrada por transfer๊ncia integrado")
	Aadd(aFiltro,"7=Entrada frango vivo apanha")
	Aadd(aFiltro,"8=Frango 1 retorno de cria็ใo")
	Aadd(aFiltro,"9=Frango 2 retorno simb๓lico cria็ใo")
	Aadd(aFiltro,"10=Frango 4 compra frango vivo")
	Aadd(aFiltro,"11=Produtor rural")
	Aadd(aFiltro,"12=Nota de frete")
	Aadd(aFiltro,"13=Exclusใo Nota de frete")
	_cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	_cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	_cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	//Everson - 10/08/2017.
	//Ajuste da data do CT-e.
	MsAguarde({|| procDtCTE() },"Aguarde","Checando datas de lan็amento dos CT-e's pendentes de importa็ใo...")
	//Cria objeto MsDialog.
	oInterface:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Entradas - Processamentos Pendentes Protheus x SAG"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1100
	oInterface:nHeight   := 460
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	//
	oDtBase := TSay():New(005,004,{|| "Data base: " + cDtBase },oInterface,,oFontDtBs,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	//Cria botใo de busca.
	oTxtBusca := TSay():New(005,180,{||"Localiza pedido:"},oInterface,,,,,,.T.,CLR_RED,CLR_WHITE,250,20)
	cSelBusca := Space(15)
	aSelBusca := {"7=Num Doc"}
	cSelBusca := aSelBusca[1]
	oSelBusca := TComboBox():New(005,220,{|u|if(PCount()>0,cSelBusca:=u,cSelBusca)},;
		aSelBusca,050,25,oInterface,,,,,,.T.,,,,,,,,,'cSelBusca')
	cBusca := Space(10)
	oBusca   := TGet():New(005,271,{|u|If(PCount() == 0,cBusca,cBusca := u)},oInterface,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"",2)
	oBtnBusca:= TButton():New(005,322,"Ok",oInterface,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnBusca:bAction := {|| nBusca := Ascan(oRegistros:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[Val(cValToChar(cSelBusca))])}),;
		Iif(nBusca > 0,Eval({||oRegistros:ForceRefresh(),oRegistros:GoTo(nBusca),oRegistros:Refresh()}),;
		MsgAlert("Nใo foi possํvel localizar o registro","Fun็ใo IntNFEB"))}
	//Combobox para sele็ใo de filtro.
	nOpcImp := aFiltro[1]
	oCombo2 := TComboBox():New(005,445,{|u|if(PCount() > 0,nOpcImp := u, nOpcImp)},;
		aFiltro,100,20,oInterface,,{|| MsAguarde({|| pendImp() },"Aguarde","Carregando registros...") },,,,.T.,,,,,,,,,'nOpcImp')
	//Cria Header.
	Aadd(aHInterface,{" ","LEG"    	  ,"@BMP"    ,01     			     , 00,.T.,"","","","R","","",.F.,"V","","","",""})
	Aadd(aHInterface,{"Opera็ใo"  	  ,"OPER"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Status"  	  ,"STATUS"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Filial"        ,"FILIAL"	 ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Tipo"          ,"TIPO"	 ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Esp้cie"       ,"ESPEC"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Num Doc"       ,"DOCSG"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"S้rie"         ,"SERIE"	 ,""	 				 , 03,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Form. Prop"    ,"FORMPROP",""	 				 , 03,0,"","" ,"C","",""})
	Aadd(aHInterface,{"DT Emissใo"    ,"DTEMIS"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"DT Lan็amento" ,"DTALNC"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Fornecedor"    ,"FORN"    ,""	 				 , 06,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Loja"          ,"LOJ"     ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"ChaveNF"       ,"CHAVENF" ,""	 			  	 , 50,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Produto"       ,"PROD"    ,""	 				 , 12,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Qtd"           ,"QTD"     ,"@E 999,999,999.999"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Vl Unit"       ,"VLRUNT"  ,"@E 999,999,999.999"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Valor"         ,"VLR"     ,"@E 999,999,999.99"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Tes"       	  ,"TES"     ,""	 				 , 05,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Desconto"      ,"DESC"    ,"@E 999,999,999.99"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Placa"         ,"PLACA"   ,""	 				 , 07,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Erro"          ,"ERR"     ,""	 				 , 100,0,"","","C","",""})
	Aadd(aHInterface,{"NF Ori"        ,"NFORI"   ,""	 				 , 09,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Sr Ori"        ,"SRORI"   ,""	 				 , 09,0,"","" ,"C","",""})
	Aadd(aHInterface,{"D1 Forn"       ,"D1FOR"   ,""	 				 , 06,0,"","" ,"C","",""})
	Aadd(aHInterface,{"D1 Loja"       ,"D1LOJA"  ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Mensagem 1"    ,"MENNOTA1"   ,""	 				 , 200,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Mensagem 2"    ,"MENNOTA2"  ,""	 				 , 200,0,"","" ,"C","",""})
	//Cria objeto MsNewGetDados(Grid).
	oRegistros := MsNewGetDados():New(025,004,165,545,,"Allwaystrue()","Allwaystrue()","",aAltInterface,Nil,999,Nil,Nil,Nil,oInterface,aHInterface,@aColsInterface)
	//
	oGroupTot := TGroup():Create(oInterface,162,433,185,545,"",,,.T.)
	oGroupTot:SetCss("QGroupBox{background-color: #F5F5F5}")
	//
	oQtdReg := TGet():New(170,438, { | u | If( PCount() == 0, nQtdReg, nQtdReg := u ) },oInterface, ;
		060, 010, "@E 999,999,999",, 0, 16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdReg",,,,.F.,,,"Total de registros:",2,,CLR_RED)
	//
	oGroup1 := TGroup():Create(oInterface,190,004,210,545,"",,,.T.)
	oGroup1:SetCss("QGroupBox{background-color: #F5F5F5}")
	//Importa็ใo.
	oSBtn01:= SButton():Create(oInterface)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "Importar"
	oSBtn01:nLeft := 014
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
	oSBtn01:bAction := {|| procEntr() }
	//Sped.
	oSBtn05:= SButton():Create(oInterface)
	oSBtn05:cName := "oSBtn05"
	oSBtn05:cCaption := "Sped"
	oSBtn05:nLeft := 081
	oSBtn05:nTop := 390
	oSBtn05:nWidth := 50
	oSBtn05:nHeight := 20
	oSBtn05:lShowHint := .F.
	oSBtn05:lReadOnly := .F.
	oSBtn05:Align := 0
	oSBtn05:bAction := {|| /*//TCSetConn(_conProthe),*/ MsAguarde({|| SPEDNFe()    },"Aguarde","Acessando rotina SPEDNFe...") }
	//Cria para recarregar dados.
	oSBtn02:= SButton():Create(oInterface)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Atualizar"
	oSBtn02:nLeft := 899
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 80
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {|| procDtCTE(), MsAguarde({|| pendImp() },"Aguarde","Carregando registros...") }
	//Cria botใo de confirma็ใo.
	oSBtn03:= SButton():Create(oInterface)
	oSBtn03:cName := "oSBtn03"
	oSBtn03:cCaption := "Legenda"
	oSBtn03:nLeft := 966
	oSBtn03:nTop := 390
	oSBtn03:nWidth := 50
	oSBtn03:nHeight := 20
	oSBtn03:lShowHint := .F.
	oSBtn03:lReadOnly := .F.
	oSBtn03:Align := 0
	oSBtn03:bAction := {||lngPedImp()}
	//Cria botใo de cancelamento.
	oSBtn04:= SButton():Create(oInterface)
	oSBtn04:cName := "oSBtn04"
	oSBtn04:cCaption := "Fechar"
	oSBtn04:nLeft := 1031
	oSBtn04:nTop := 390
	oSBtn04:nWidth := 50
	oSBtn04:nHeight := 20
	oSBtn04:lShowHint := .F.
	oSBtn04:lReadOnly := .F.
	oSBtn04:Align := 0
	oSBtn04:lVisibleControl := .T.
	oSBtn04:bAction := {||oInterface:End()}
	oSBtn04:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")
	//
	oInterface:Activate(,,,.T.,{||.T.},,{|| pendImp() })
	//
	//TcUnLink(_conSAG)
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrLRCCSV  บAutor  ณEverson             บ Data ณ  14/08/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera aquivo CSV para objeto msnewgetdados.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033511.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grLRCCSV(oRegistros,aHReg,cArq)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	cDir := cGetFile("Arquivo CSV.", "Selecione o diret๓rio para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil
	EndIf
	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)
	//Verifica se foi possํvel criar o arquivo.
	If nHdl == -1
		MsgAlert("O Arquivo nใo " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Fun็ใo grLRCCSV")
		Return Nil
	EndIf
	//
	cLin := ""
	For i := 2 To Len(aHReg)
		cLin += cValToChar(aHReg[i][1]) + ";"
	Next i
	cLin += cEof
	For i := 2 To Len(oRegistros:aCols)
		For w := 2 To Len(aHReg)
			If Alltrim(cValToChar(aHReg[w][8])) == "N"
				cLin += Transform(Val(cValToChar(oRegistros:aCols[i][w])),"@E 999,999,999.99") + ";"
			Else
				cLin += cValToChar(oRegistros:aCols[i][w]) + ";"
			EndIf
		Next w
		cLin += cEof
		FWrite(nHdl,cLin,Len(cLin))
		cLin := ""
	Next i
	//Fecha o arquivo.
	FClose(nHdl)
	WinExec("Explorer.exe" + Space(1) + cDir )
	MsgInfo("Arquivo gerado.","Fun็ใo grLRCCSV")
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlngPedImp บ Autor ณ Everson            บ Data ณ  11/08/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql de registros pendentes de importa็ใo.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033511.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptSql(nRadio)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	Local cQry	:= ""
	Local nTop  := Supergetmv("MV_#TPNFEB",,50)
	//
	If nRadio == 1 // ENTRADA POR COMPRA				SGNFE010	PO01MVES	SEQ UNICO	Menu\PROTHEUS
		cQry := " SELECT '1' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND substring(F1_DOC,1,2) <> '0 ' AND F1_DOC <> '999999') AND (TABEGENE IN ('PO01MVES','POCAMVES','PO11MVES','PO12MVES') ) AND F1_EMISSAO <= '" + _sDtlim + "' AND F1_DTDIGIT = '"+DTOS(dDatabase)+"' AND F1_FORMUL = 'N' "  //Leon | 05/08/2019 | Ch:050855
		// DEBUG - VOLTAR
		//cQry += " AND F1_FORNECE='029421'
	ElseIf nRadio == 2 //ENTRADA POR DEVOLUวรO			SGNFE010	PO02MVES	SEQ UNICO	Menu\PROTHEUS  -- Adriana Garcia, Rosangela, Simone
		cQry := " SELECT '2' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND substring(F1_DOC,1,2) <> '0 ' AND F1_DOC <> '999999') AND TABEGENE = 'PO02MVES' AND F1_EMISSAO <= '"+_sDtlim+"' "
	ElseIf nRadio == 3 //ENTRADA POR TRANS. EMPRESA		SGNFE010	PO03MVES	SEQ UNICO	Menu\PROTHEUS  -- Noemi, Rosangla, Simone
		cQry := " SELECT '3' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND substring(F1_DOC,1,2) <> '0 ' AND F1_DOC <> '999999') AND TABEGENE = 'PO03MVES' AND F1_EMISSAO <= '"+_sDtlim+"' AND F1_DTDIGIT = '"+DTOS(dDatabase)+"' " //Everson - 12/08/2020. Chamado 060547.
	ElseIf nRadio == 4 //NOTAS DE SERVIวO				SGNFE010	POCAFINA	SEQ UNICO
		cQry := " SELECT '4' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' ) AND (TABEGENE = 'POCAFINA' OR TABEGENE='POCAMVNE') AND D1_TIPO <> 'F' AND F1_EMISSAO <= '"+_sDtlim+"' "
	ElseIf nRadio == 5 //ENTRADA POR TRANS. INTEGRADO	SGNFE010	POCAMVTP	SEQ UNICO	Menu\PROTHEUS     -- Adriana Garcia, Adriana Caldeira, Rosangela, Simone, Noemi, Pera, Fornari
		cQry := " SELECT '5' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' ) AND TABEGENE = 'POCAMVTP' AND F1_EMISSAO <= '"+_sDtlim+"' "
	ElseIf nRadio == 6 //ENTRADA FRANGO VIVO APANHA		SGNFE010	FCCAMVAP	SEQ UNICO	Automatico        -- Simone, rosangela, Valeria
		cQry := " SELECT '6' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' ) AND TABEGENE = 'FCCAMVAP' AND F1_EMISSAO <= '"+_sDtlim+"' "
		//(IDENTICO A ESTE)
	ElseIf nRadio == 7 //FRANGO 1 RETORNO DE CRIACAO		SGNFE010	EC01LOTE	SEQ UNICO	Menu\PROTHEUS -- Adriana Garcia, Rosangela, Simone
		//@Ticket 64254 - JONATHAN.CARVALHO - 29/11/2021 puxar 50 registros por vez 
		//@Ticket 65598 - JONATHAN.CARVALHO - 22/12/2021 incluido a consulta dentro da fun็ใo IN para puxar os F1_DOC iguais
		cQry := " SELECT '7' AS TP, * FROM SGNFE010 WHERE F1_DOC IN(SELECT TOP "+CValToChar(nTop)+" F1_DOC FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND F1_FORMUL = 'S' ) AND TABEGENE = 'EC01LOTE' AND F1_EMISSAO <= '"+_sDtlim+"' ) "
	ElseIf nRadio == 8 //FRANGO 2 RETORNO SIMBOL CRIACAO	SGNFE010	EC02LOTE	SEQ UNICO	Menu\PROTHEUS  -- Adriana Garcia, Rosangela, Simone
		cQry := " SELECT '8' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND F1_FORMUL = 'S' ) AND TABEGENE = 'EC02LOTE' AND F1_EMISSAO <= '"+_sDtlim+"' "
	ElseIf nRadio == 9 //FRANGO 4 COMPRA FRANGO VIVO		SGNFE010	EC04LOTE	SEQ UNICO	Menu\PROTHEUS   -- Adriana Garcia, Rosangela, Simone
		cQry := " SELECT '9' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND F1_FORMUL = 'S' ) AND TABEGENE = 'EC04LOTE' AND F1_EMISSAO <= '"+_sDtlim+"' "
	ElseIf nRadio == 10 //PRODUTOR RURAL
		cQry := " SELECT '10' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '"+cFilAnt+"' AND F1_FORMUL = 'S' ) AND TABEGENE IN ('PO11MVES','PO01MVES') AND F1_EMISSAO <= '"+_sDtlim+"' AND F1_DTDIGIT = '"+DTOS(dDatabase)+"' AND F1_FORMUL = 'S' "
	ElseIf nRadio == 11 //Nota de Frete
		cQry := " SELECT '11' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E')) AND F1_FILIAL = '" + cFilAnt + "'  AND D1_TIPO = 'F' AND F1_ESPECIE = 'CTE' ) AND F1_EMISSAO <= '"+_sDtlim+"' AND F1_DTDIGIT = '"+DTOS(dDatabase)+"' AND TABEGENE LIKE 'POCAMVNE' AND OPERACAO_INT <> 'E' "
	ElseIf nRadio == 12 //Exclusใo Nota de Frete
		cQry := " SELECT '12' AS TP, * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt + "' AND D1_TIPO = 'F' AND F1_ESPECIE = 'CTE' ) AND F1_EMISSAO <= '"+_sDtlim+"' AND F1_DTDIGIT = '"+DTOS(dDatabase)+"' AND TABEGENE LIKE 'POCAMVNE' AND OPERACAO_INT = 'E'  "
	EndIf
	//
	RestArea(aArea)
Return cQry
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpendImp() บ Autor ณ Everson            บ Data ณ  11/08/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega grid com os registros pendentes de importa็ใo.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033511.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function pendImp()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local i			:= 1
	Local cQuery	:= ""
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
	Local oMarrom   := LoadBitmap( GetResources(), "BR_MARRON_OCEAN")
	Local oAzul		:= LoadBitmap( GetResources(), "BR_AZUL")
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA")
	Local oBranco 	:= LoadBitmap( GetResources(), "BR_BRANCO")
	Local oPreto	:= LoadBitmap( GetResources(), "BR_PRETO")
	Local oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Local oVioleta  := LoadBitmap( GetResources(), "BR_VIOLETA")
	Local oCinza	:= LoadBitmap( GetResources(), "BR_CINZA")
	Local oVdEsc	:= LoadBitmap( GetResources(), "BR_VERDE_ESCURO")
	Local cOper		:= ""
	nOpcImp := Val(Alltrim(cValToChar(nOpcImp)))
	oRegistros:aCols := {}
	oRegistros:Refresh()
	nQtdReg := 0
	oQtdReg:Refresh()
	cQuery += " SELECT * FROM ( "
	For i := 1 To 12
		cQuery += scriptSql(i) + Chr(13) + Chr(10)
		If i < 12
			cQuery += " UNION ALL " + Chr(13) + Chr(10)
		EndIf
	Next i
	cQuery += " ) AS FONTE "
	If (nOpcImp - 1 ) > 0
		cQuery += " WHERE FONTE.TP = '" + Alltrim(cValToChar((nOpcImp - 1 ))) + "' "
	EndIf
	cQuery += "  ORDER BY CAST(FONTE.TP AS NUMERIC), FONTE.F1_FILIAL,FONTE.CODIGENE,FONTE.R_E_C_N_O_ , FONTE.D1_TRANSIT  "
	//
	If Select("CARR_PEND") > 0
		CARR_PEND->(DbCloseArea())
	EndIf
	//
	//////TCSetConn(_conSAG)
	MsAguarde({|| DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "CARR_PEND", .T., .F.) },"Aguarde","Carregando registros...")
	DbSelectArea("CARR_PEND")
	CARR_PEND->(DbGoTop())
	If CARR_PEND->(Eof())
		Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
		oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"    })] 	:= ""
	EndIf
	//
	While ! CARR_PEND->(Eof())
		IIf( Alltrim(cValToChar(CARR_PEND->OPERACAO_INT)) = "E" ,cOper := "Exclusใo" , cOper := "Inclusใo")
		Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
		oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"    })] 	:= cOper
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STATUS"  })] 	:= Alltrim(cValToChar(CARR_PEND->STATUS_INT))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FILIAL"  })] 	:= Alltrim(cValToChar(CARR_PEND->F1_FILIAL))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TIPO"    })] 	:= Alltrim(cValToChar(CARR_PEND->F1_TIPO))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ESPEC"    })] 	:= Alltrim(cValToChar(CARR_PEND->F1_ESPECIE))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DOCSG"   })] 	:= Alltrim(cValToChar(CARR_PEND->F1_DOC))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SERIE"   })] 	:= Alltrim(cValToChar(CARR_PEND->F1_SERIE))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FORMPROP"})] 	:= Alltrim(cValToChar(CARR_PEND->F1_FORMUL))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"  })] 	:= Iif(Empty(Alltrim(cValToChar(CARR_PEND->F1_EMISSAO))),"",DToC(SToD(CARR_PEND->F1_EMISSAO)))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTALNC"  })] 	:= Iif(Empty(Alltrim(cValToChar(CARR_PEND->F1_DTDIGIT))),"",DToC(SToD(CARR_PEND->F1_DTDIGIT)))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FORN"    })] 	:= Alltrim(cValToChar(CARR_PEND->F1_FORNECE))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"     })] 	:= Alltrim(cValToChar(CARR_PEND->F1_LOJA))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CHAVENF" })] 	:= Alltrim(cValToChar(CARR_PEND->F1_CHVNFE))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PROD"    })] 	:= Alltrim(cValToChar(CARR_PEND->D1_COD))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"     })] 	:= Val(cValToChar(CARR_PEND->D1_QUANT))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLRUNT"  })] 	:= Val(cValToChar(CARR_PEND->D1_VUNIT))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"     })] 	:= Val(cValToChar(CARR_PEND->D1_TOTAL))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TES"     })] 	:= Alltrim(cValToChar(CARR_PEND->D1_TES))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DESC"    })] 	:= Val(cValToChar(CARR_PEND->D1_DESC))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"     })] 	:= Alltrim(cValToChar(CARR_PEND->MENSAGEM_INT))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NFORI"   })] 	:= Alltrim(cValToChar(CARR_PEND->D1_NFORI))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SRORI"   })] 	:= Alltrim(cValToChar(CARR_PEND->D1_SERIORI))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLACA"   })] 	:= Alltrim(cValToChar(CARR_PEND->D1_PLACA))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "D1FOR"   })] 	:= Alltrim(cValToChar(CARR_PEND->D1_FORNECE))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "D1LOJA"  })] 	:= Alltrim(cValToChar(CARR_PEND->D1_LOJA))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "MENNOTA1"   })] := Alltrim(cValToChar(CARR_PEND->F1_MENNOTA))
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "MENNOTA2"  })] 	:= Alltrim(cValToChar(CARR_PEND->F1_MENNOTB))
		//
		If Alltrim(cValToChar(CARR_PEND->TP)) == "1"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVerde
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "2"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVermelho
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "3"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oAmarelo
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "4"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oMarrom
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "5"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oAzul
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "6"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oLaranja
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "7"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oBranco
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "8"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oPreto
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "9"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oPink
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "10"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVioleta
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "11"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oCinza
		ElseIf Alltrim(cValToChar(CARR_PEND->TP)) == "12"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVdEsc
		EndIf
		nQtdReg++
		CARR_PEND->(DbSkip())
	EndDo
	CARR_PEND->(DbCloseArea())
	//
	oRegistros:Refresh()
	oQtdReg:Refresh()
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNFE001B   บAutor  ณMicrosiga           บ Data ณ  07/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็๕es de integra็ใo com o Compras                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro - P11                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                        
Static Function procEntr()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	    := GetArea()
	Private cMensagem	:= ""
	Private cImpOK		:= "Notas Importadas com Sucesso:" + CRLF + CRLF
	Private cImpEr		:= "Notas Nใo Importadas:" + CRLF + CRLF"
	Private _cNomBco2   := ""
	Private _cSrvBco2   := ""
	Private _cPortBco2  := ""
	Private cPara       := ""
	Private cCopia      := ""
	Private cCpOcul     := ""
	Private cAssunto    := ""
	Private cDe         := ""
	Private cLocal      := ""
	cEmp := cEmpAnt
	cFil := cFilAnt
	//
	If Val(cValToChar(nOpcImp)) == 1
		MsgStop("Por favor, selecione uma op็ใo diferente de 1 - Todos no filtro.","Fun็ใo procEntr")
		RestArea(aArea)
		Return Nil
	EndIf
	Private nRadio  := Val(cValToChar(nOpcImp)) - 1
	Private cQueryP := ''
	Private cCod    := "" //Incluido por Adriana chamado 028496
	cPara      := SuperGetMV("MV_XMPARA" ,,"")
	cCopia     := SuperGetMV("MV_XMCOPIA",,"")
	cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
	cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
	cDe        := SuperGetMV("MV_XMAILDE",,"")
	cEmail	   := GetMV("MV_XEMAIL",.F.,"")
	cExt	   := GetMv("MV_XEXT",.F.,"*.CSV")
	Processa({|lEnd| U_InteNfeB() },"Aguarde...","Gerando Interface ...",.F.)
	MsAguarde({|| pendImp() },"Aguarde","Carregando registros...")
	cMensagem += cImpOK + CRLF + CRLF
	cMensagem += cImpER + CRLF + CRLF
	U_ExTelaMen("INTNFEB - Processo de Importa็ใo concluido!!!", cMensagem, "Arial", 10, , .F., .T.)
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTENfeB  บAutor  ณMicrosiga           บ Data ณ  07/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function InteNfeB()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local _aArea     := GetArea()
	Local lHtml      := .T.
	Local cAnexo     := ""
	Local aRec		 := {}
	Local _lJob      := .F.
	Local lMsErroAuto:= .F.
	Local lMata103 	 := .F.
	Local cCHVNFE    := ''
	Local lMata116	 := .F.  // determina se a execauto vai ser pelo mata116 conhecimento de frete
	Local xDoc		 := CriaVar("F1_DOC",.F.)
	Local cNumero    := CriaVar("F1_DOC",.F.) //Tkt 33037 - Fernando Sigoli 01/10/2021
	Local xPrc		 := ""
	Local aAreaNFE
	Local cFornec	 := ""
	Local cLoja		 := ""
	Local nTotReg	 := 0
	Local cCheckDoc  := ""
	Local cCheckForn := ""
	Local cCheckLoja := ""
	Local aNFtrans	 := {} //Everson - 06/11/2018.
	Local cTpNrNfs	 := "" //Everson - 06/11/2018.
	Local cErro		 := "" //Everson - 06/11/2018.
	//Everson - 18/10/2019. Chamado 052348.
	Local cTesTrans	 := Alltrim(cValToChar(GetMv("MV_#TESTRA",,"1X1X1X1/1X1X1X1/1X1X1X1")))
	Local aTesTrans	 := StrToKarr(cTesTrans,"/")
	Local cTesPTra	 := aTesTrans[1]
	Local cCCPTra	 := aTesTrans[2]
	Local cICCPTra	 := aTesTrans[3]
	//
	Local aPCSAG := {}
	// define link com a base da Interface
	_cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	_cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	_cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	Private cAliasNFE	:= GetNextAlias()
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.
	Private cEstado         := ''
	Private cFornecOri      := ''
	Private cLojaForOri     := ''
	Private cNaturez        := ''
	Private lErroFrete      := .F.
	Private cDocFrete       := ''
	Private cCodProdFrete   := ''
	Private cSerieFrete     := ''
	Private cForneceFrete   := ''
	Private cLojaFrete      := ''
	Private cChaveNfeFrete  := ''
	Private dDataRec		:= CTOD("  /  /  ")
	Private lAltFrete       := .F.
	Private aRecno          := {}
	Private aRecnos         := {}
	Private cPnfOri 	    := ''
	Private	cPseriOri 	    := ''
	Private	cPforneceOri    := ''
	Private	cPLojaOri       := ''
	Private cDocOri         := ''
	Private cSerieOri       := ''
	Private _NFORI 		    := ''
	Private	_SERIORI 	    := ''
	Private	_FORNECE	    := ''
	Private	_LOJA   	    := ''
	Private cMensFinal      := ''
	Private cDoc			:= ''
	Private nTotReg			:= 0
	Private cCheckDoc 		:= ""
	Private cCheckForn		:= ""
	Private cCheckLoja		:= ""
	Private cCheckOr  		:= ""
	Private cCheckOp		:= ""
	Private nVlrFrt			:= 0 //Everson - 13/10/2017. Chamado 037596.
	Private cCheckFor  		:= ""//fernando sigoli - 22/02/2018
	Private	cCheckLoj  		:= ""//fernando sigoli - 22/02/2018
	Private cCheckRur  		:= ""//fernando sigoli - 22/02/2018
	Private cCheckTG   		:= ""//fernando sigoli - 22/02/2018
	Private cCheckTP		:= ""//fernando sigoli - 22/02/2018
	Private cProdCod        := ""//fernando sigoli - 01/03/2018
	Private _CONTA          := ""//fernando sigoli - 01/03/2018
	Private _ITEMCC         := ""//fernando sigoli - 01/03/2018
	//
	Private cEstOri         := ''//fernando sigoli - 10/04/2018
	Private cMunOri         := ''//fernando sigoli - 10/04/2018
	Private cEstDes         := ''//fernando sigoli - 10/04/2018
	Private cMunDes         := ''//fernando sigoli - 10/04/2018
	Private cCCFV           :=GetMV("MV_#CCFRVI",,"6110")
	Private cITFV           :=GetMV("MV_#ITFRVI",,"121")
	Private cCNPJ           := "" //fernando sigoli - 05/1/2019
	U_ADINF009P('INTNFEB' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Vai gerar Pre-Notas por uma op็ใo no menu do usuario ')
	//
	//////TCSetConn(_conSAG)
	If nRadio <> 11 .And. nRadio <> 12
		cQry := scriptSql(nRadio)
		cQry += " ORDER BY F1_FILIAL,CODIGENE,R_E_C_N_O_ , D1_TRANSIT "
	ElseIf nRadio == 11 .Or. nRadio == 12
		//
		If nRadio == 11 //Nota de Frete.
			GeraFrete()
		ElseIf nRadio == 12 //Exclusใo Nota de Frete.
			ExcluiFrete()
		EndIf
		Return Nil
	Else
		MsgStop("Op็ใo selecionada invแlida.","Fun็ใo InteNfeB")
		Return Nil
	EndIf
	//
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasNFE, .T., .F.)
	TcSetField( cAliasNFE, "F1_EMISSAO", "D", 8, 0)
	TcSetField( cAliasNFE, "F1_XREC", "D", 8, 0)
	TcSetField( cAliasNFE, "F1_DTDIGIT", "D", 8, 0)   //chamado 057922 - || Fernando Sigoli 07/05/2020 - OS 059404 || CONTROLADORIA || THIAGO || 8439
	(cAliasNFE)->(DbGoTop())
	If (cAliasNFE)->(Eof())
		MsgInfo("Nใo hแ documentos de entrada a serem importados.","Fun็ใo InteNfeB")
		//////TCSetConn(_conProthe)
		(cAliasNFE)->(DbCloseArea())
		RestArea(_aArea)
		Return Nil
	EndIf
	//
	If nRadio == 6
	dOrigB := dDataBase
EndIf
cChave   := ""
cNotaDe  := Space(9)
cNotaAte := Space(9)
DbSelectArea(cAliasNFE)
(cAliasNFE)->(dbGotop())
nTotReg := 0
While ! (cAliasNFE)->(Eof())
	nTotReg++
	(cAliasNFE)->(DbSkip())
EndDo
ProcRegua(nTotReg)
(cAliasNFE)->(dbGotop())
While ! (cAliasNFE)->(Eof())
	//Conexใo banco de dados integra็ใo.
	//////TCSetConn(_conSAG)
	IncProc("NF | " + Alltrim(cValToChar((cAliasNFE)->F1_DOC)) + "/" + Alltrim(cValToChar((cAliasNFE)->F1_Serie))  )
	// ** INICIO DA CRIACAO DE LOG CHAMADO 032948 - WILLIAM COSTA ** //
	TcSqlExec("UPDATE SGNFE010 SET DTPROCESSO='" +DTOS(DATE()) + "' , HRPROCESSO='"+SUBSTR(TIME(),1,5)+ "' WHERE CODIGENE = '" + CVALTOCHAR((cAliasNFE)->CODIGENE) + "'")
	// ** FINAL DA CRIACAO DE LOG CHAMADO 032948 - WILLIAM COSTA ** //
	cCheckDoc 	:= 	Alltrim(cValToChar((cAliasNFE)->F1_DOC))
	cCheckForn	:= 	Alltrim(cValToChar((cAliasNFE)->F1_FORNECE))
	cCheckLoja	:= 	Alltrim(cValToChar((cAliasNFE)->F1_LOJA))
	cCheckOr  	:= 	Alltrim(cValToChar((cAliasNFE)->D1_NFORI))
	cCheckOp  	:= 	Alltrim(cValToChar((cAliasNFE)->OPERACAO_INT))
	//Fernando Sigoli 22/02/2018
	cCheckFor  := (cAliasNFE)->F1_Fornece
	cCheckLoj  := (cAliasNFE)->F1_Loja
	cCheckRur  := (cAliasNFE)->(D1_SRRURAL+D1_NFRURAL)
	cCheckTG   := ALLTRIM((cAliasNFE)->TABEGENE)
	cCheckTP   := ALLTRIM((cAliasNFE)->D1_IDENTB6)
	If Alltrim(cValToChar((cAliasNFE)->D1_TIPO)) == 'X'
		//////TCSetConn(_conProthe)
		cQryS:=" SELECT F1_DOC FROM " + RetSqlName("SF1") + " WHERE F1_FILIAL = '" + cFilAnt + "' AND F1_DOC = '" + Padl(cCheckOr,9,"0") + "' AND F1_FORNECE = '" + cCheckForn + "' AND F1_LOJA = '" + cCheckLoja + "' AND D_E_L_E_T_ = '' "
		If Select("ChecRess") > 0
			ChecRess->(DbCloseArea())
		EndIf
		TcQuery cQryS New Alias "ChecRess"
		DbSelectArea("ChecRess")
		ChecRess->(DbGoTop())
		If ChecRess->(Eof())
			cErro := "A nota de origem " + cCheckOr + " referente เ remessa " + cCheckDoc + " nใo estแ lan็ada no Protheus."
			cImpEr+= cErro + CRLF + CRLF
			MsgStop(cErro,"Fun็ใo InteNfeB")
			ChecRess->(DbCloseArea())
			//////TCSetConn(_conSAG)
			DbSelectArea(cAliasNFE)
			(cAliasNFE)->(dbSkip())
			//////TCSetConn(_conProthe)
			Loop
		Else
			//////TCSetConn(_conSAG)
			ChecRess->(DbCloseArea())
		EndIf
	EndIf
	cFornec := (cAliasNFE)->F1_FORNECE
	cLoja  	:= (cAliasNFE)->F1_LOJA
	//
	If (cAliasNFE)->OPERACAO_INT == 'A'
		//
		If Alltrim(cValToChar((cAliasNFE)->F1_Formul)) == "S" //Everson - 09/11/2018.
			lInc:=.T.
		Else
			cDoc := (cAliasNFE)->F1_DOC
			cCodiGene  := (cAliasNFE)->(CODIGENE)
			//SE TIPO A E NรO EXISTIR NO SISTEMA, EFETUA A INCLUSรO
			////TCSetConn(_conProthe)
			cAliasT := GetNextAlias()
			cQryS	:= "SELECT 1 FROM "+RetSqlName("SF1")+" (NOLOCK) WHERE F1_CODIGEN = " +alltrim(str(cCodiGene))+ " AND D_E_L_E_T_='' "
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryS), cAliasT, .T., .F.)
			If (cAliasT)->(Eof())
				lInc:=.T.
			Else
				IntNFEB1(.F.)
				lInc:=.T.
			EndIf
			//
			(cAliasT)->(DbCloseArea())
		EndIf
	Else
		If (cAliasNFE)->OPERACAO_INT == 'E'
			lInc:=.F.
		Else
			lInc:=.T.
		EndIf
	EndIf
	//Conexใo banco de dados integra็ใo.
	////TCSetConn(_conSAG)
	If lInc
		// para verificar se a nota ja esta no protheus
		// estes campos sao da base de interface e nao do protheus
		If SubStr((cAliasNFE)->F1_Doc,1,1) == "E"
			cDoc := SubStr((cAliasNFE)->F1_Doc,2,10)
		Else
			cDoc := StrZero(Val((cAliasNFE)->F1_Doc),9)
		EndIf
		cNota	 := rTrim((cAliasNFE)->F1_DOC)
		cNotaSag := rTrim((cAliasNFE)->F1_DOC)
		cFornSag := rTrim((cAliasNFE)->F1_FORNECE)
		cChave   := (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
		cSeek    := (cAliasNFE)->(F1_FILIAL+cDoc+(cAliasNFE)->F1_Serie+F1_FORNECE+F1_LOJA)
		cFornec  := (cAliasNFE)->F1_Fornece
		cLoja	 := (cAliasNFE)->F1_Loja
		cTipo 	 := (cAliasNFE)->F1_TIPO
		nRecno   := (cAliasNFE)->R_E_C_N_O_
		dDataRec := (cAliasNFE)->F1_XREC
		cProdCod := (cAliasNFE)->D1_COD
		_CONTA   :=  ''
		_ITEMCC  :=  ''
		//Conexใo banco de dados Protheus.
		////TCSetConn(_conProthe)
		cCNPJ    := Posicione('SA2',1,xFilial('SA2')+ cFornec + cLoja,"A2_CGC") //Fernanado Sigoli 05/11/2018 Chamado: 044933
		//Inicio: fernando sigoli 21/09/2018 Chamado: 044053
		If !Empty((cAliasNFE)->F1_CHVNFE)
			If (cAliasNFE)->F1_DOC <> SubStr((cAliasNFE)->F1_CHVNFE,26,9)
				cErro     := "NFE "+alltrim((cAliasNFE)->F1_DOC)+" com chave diferente do numero da Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
				cImpEr	  += cErro + CRLF + CRLF
				//////TCSetConn(_conSAG)
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(dbSkip())
				Loop
			EndIF
		EndIf
		//Fim: fernando sigoli 21/09/2018 Chamado: 044053
		//inicio: Fernanado Sigoli 05/11/2018 Chamado: 044933
		If !Empty((cAliasNFE)->F1_CHVNFE)
			If cCNPJ <> SubStr((cAliasNFE)->F1_CHVNFE,07,14)
				cErro     := "NFE "+alltrim((cAliasNFE)->F1_DOC)+" com CNPJ diferente do numero da Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
				cImpEr	  += cErro + CRLF + CRLF
				//////TCSetConn(_conSAG)
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(dbSkip())
				Loop
			EndIF
		EndIf
		//Fim: Fernanado Sigoli 05/11/2018 Chamado: 044933
		// *** INICIO WILLIAM COSTA 09/08/2019 CHAMADO 046976 || OS 048247 || TECNOLOGIA || WAGNER || 3522 || PROTHEUS X SAG
		IF ALLTRIM((cAliasNFE)->TABEGENE) == 'FCCAMVAP'
			cNFApanha := GetNextAlias()
			cQryf := " SELECT F2_DOC, F2_SERIE, F2_EMISSAO FROM " + RetSqlName("SF2") + " WITH (NOLOCK) WHERE F2_FILIAL = '03' AND F2_SERIE = '" + (cAliasNFE)->F1_SERIE + "' AND F2_DOC = '" + StrZero(Val(Alltrim((cAliasNFE)->F1_DOC)),9) + "' AND D_E_L_E_T_ <> '*' " // Leon | Chamado 051029 | 13/08/2019 | StrZero para F1_DOC
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryf), cNFApanha, .T., .F.)
			(cNFApanha)->(dbGotop())
			If (cNFApanha)->(Eof())
				cErro := "Nota fiscal de Saida nao encontrada no Protheus: "+AllTrim((cAliasNFE)->F1_DOC)+ CRLF + CRLF
				cImpEr+= cErro + CRLF + CRLF
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(dbSkip())
				Loop
			Else
				IF (cAliasNFE)->F1_EMISSAO < STOD((cNFApanha)->F2_EMISSAO)
					cErro := "Data da Nota fiscal de Entrada Menor que a Data da Nota Fiscal de Saida: "+AllTrim((cAliasNFE)->F1_DOC)+ CRLF + CRLF
					cImpEr+= cErro + CRLF + CRLF
					DbSelectArea(cAliasNFE)
					(cAliasNFE)->(dbSkip())
					Loop
					(cNFApanha)->(DbCloseArea())
				ELSE
					(cNFApanha)->(DbCloseArea())
				ENDIF
			ENDIF
		ENDIF
		// *** FINAL WILLIAM COSTA 09/08/2019 CHAMADO 046976 || OS 048247 || TECNOLOGIA || WAGNER || 3522 || PROTHEUS X SAG
		// Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 08/05/2019
		If !u_ExistXML((cAliasNFE)->F1_DOC, (cAliasNFE)->F1_SERIE, cCNPJ, (cAliasNFE)->F1_ESPECIE, (cAliasNFE)->F1_FORMUL, 0)
			cErro     := "XML da NF n. " + (cAliasNFE)->F1_DOC + "/" + (cAliasNFE)->F1_SERIE + " - CNPJ " + Transform(cCNPJ,"@R 99.999.999/9999-99") + " nใo encontrada na tabela da Central XML..." + CRLF + CRLF
			cImpEr	  += cErro + CRLF + CRLF
			(cAliasNFE)->(dbSkip())
			Loop
		EndIf
		// Chamado n. 048529 || OS 049805 || FISCAL || ALLAN || 8394 || VALIDAR NFE INT - FWNM - 14/05/2019
		//User Function ChkChvNF(cFilNF, cDoc, cSer, cFor, cLoj, cTipo, cSistema, cChaveNFe, cUF, cAnoMes, cCNPJ)
		If !u_ChkChvNF((cAliasNFE)->F1_FILIAL, (cAliasNFE)->F1_DOC, (cAliasNFE)->F1_SERIE, (cAliasNFE)->F1_FORNECE, (cAliasNFE)->F1_LOJA, (cAliasNFE)->F1_TIPO, "SAG", (cAliasNFE)->F1_CHVNFE, DtoS((cAliasNFE)->F1_EMISSAO), cCNPJ)
			cErro     := "NFE "+alltrim((cAliasNFE)->F1_DOC)+" com DATA, CNPJ, SERIE ou DOC diferente dos dados contidos na Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
			cImpEr	  += cErro + CRLF + CRLF
			(cAliasNFE)->(dbSkip())
			Loop
		EndIf
		//
		///// Consisto total da NF
		// Chamado n. 052097 || OS 053474 || FISCAL || SIMONE || 8463 || CTES 3182 E 3189 - fwnm - 02/10/2019
		If !Empty( (cAliasNFE)->F1_CHVNFE ) // Chamado n. 052097 || Nao consistir valor quando nao possuir chave eletronica - FWNM - 04/10/2019
			nValrNFE := 0
			cFilNFE  := (cAliasNFE)->F1_FILIAL
			cNumeNFE := (cAliasNFE)->F1_DOC
			cSeriNFE := (cAliasNFE)->F1_SERIE
			cTipoNFE := (cAliasNFE)->F1_TIPO
			cFornNFE := (cAliasNFE)->F1_FORNECE
			cLojaNFE := (cAliasNFE)->F1_LOJA
			cChavNFE := (cAliasNFE)->F1_CHVNFE
			cEspNFE  := (cAliasNFE)->F1_ESPECIE
			// Conecto com DBINTERFACE/SAG para buscar total da NF no SAG
			aTamSX3 := TamSX3("D1_TOTAL")
			//TCSetConn(_conSAG)
			If Select("Work1") > 0
				Work1->( dbCloseArea() )
			EndIf
			cQuery := " SELECT SUM(D1_TOTAL) TOT_NF "
			cQuery += " FROM SGNFE010 (NOLOCK) "
			cQuery += " WHERE F1_FILIAL = '"+cFilNFE+"' "
			cQuery += " AND F1_DOC = '"+cNumeNFE+"' "
			cQuery += " AND F1_SERIE = '"+cSeriNFE+"' "
			cQuery += " AND F1_TIPO = '"+cTipoNFE+"' "
			cQuery += " AND F1_FORNECE = '"+cFornNFE+"' "
			cQuery += " AND F1_LOJA = '"+cLojaNFE+"' "
			cQuery += " AND F1_CHVNFE = '"+cChavNFE+"' "
			cQuery += " AND	F1_ESPECIE = '"+cEspNFE+"' "
			cQuery += " AND	OPERACAO_INT <> 'E' " // Chamado n. 052097 || Exclusao de NF - Filtrar OPERACAO_INT <> E - fwnm - 03/10/2019
			tcQuery cQuery New Alias "Work1"
			// Compatibilizo campos numericos e data
			tcSetField("Work1","TOT_NF", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			If Work1->( !EOF() )
				nValrNFE := Work1->TOT_NF
			EndIf
			If Select("Work1") > 0
				Work1->( dbCloseArea() )
			EndIf
			// Restauro conexao Protheus e busco total da NF na Central XML
			////TCSetConn(_conProthe)
			If Select("Work2") > 0
				Work2->( dbCloseArea() )
			EndIf
			cQuery := " SELECT SUM(XIT_TOTNFE) XIT_TOTNFE "
			cQuery += " FROM RECNFXMLITENS (NOLOCK) "
			cQuery += " WHERE XIT_CHAVE = '"+cChavNFE+"' "
			cQuery += " AND	D_E_L_E_T_='' "
			tcQuery cQuery New Alias "Work2"
			aTamSX3 := TamSX3("D1_TOTAL")
			tcSetField("Work2","XIT_TOTNFE", aTamSX3[3], aTamSX3[1], aTamSX3[2])
			If Work2->( !EOF() )
				// Chamado n. 052097 || Consistir valor considerando apenas 1 digito decimal - FWNM - 04/10/2019
				cXIT_TOTNFE := AllTrim(Str(Work2->XIT_TOTNFE))
				cnValrNFE := AllTrim(Str(nValrNFE))
				If Left(cXIT_TOTNFE,At(".",cXIT_TOTNFE)-1) <> Left(cnValrNFE,At(".",cnValrNFE)-1)
					cErro := "NFE.: "+STRZERO(VAL(cNumeNFE),9)+" Fornec.: "+cFornNFE+" com valor "+cnValrNFE+ " diferente do XML " +cXIT_TOTNFE+  ", favor verificar!!!" + CRLF + CRLF
					cImpEr	  += cErro + CRLF + CRLF
					(cAliasNFE)->( dbSkip() )
					Loop
				EndIf
			EndIf
			If Select("Work2") > 0
				Work2->( dbCloseArea() )
			EndIf
		EndIf
		/////
		//
		//inicio - Fernando Sigoli 22/02/2017
		If cCheckTG == 'POCAMVTP'
			//verifico se a nota informado do produtor rural existe no sistema
			If cCheckTP == 'TRANS'   //TRANS = Transferencia ou SOBRA = Sobra
				If !Empty(cCheckRur)
					NFRURAL := GetNextAlias()
					cQryf := " SELECT F2_DOC, F2_SERIE FROM " + RetSqlName("SF2") + " WITH (NOLOCK) WHERE F2_FILIAL = '" +cFilAnt+ "' AND F2_SERIE+F2_DOC = '" +cCheckRur+ "' AND D_E_L_E_T_ = '' "
					DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryf), NFRURAL, .T., .F.)
					(NFRURAL)->(dbGotop())
					If (NFRURAL)->(Eof())
						cErro := "Nota fiscal do produtor informado nใo encontrada no Protheus "+AllTrim(cCheckRur)+ CRLF + CRLF
						cImpEr+= cErro + CRLF + CRLF
						DbSelectArea(cAliasNFE)
						(cAliasNFE)->(dbSkip())
						Loop
					Else
						(NFRURAL)->(DbCloseArea())
					EndIf
				EndIF
			EndIf
			//verifico se a nota do produtor rural ja foi feito entrada de trasnferencia
			If !Empty(cCheckRur)
				NFTRANF := GetNextAlias()
				cQryt := " SELECT "
				cQryt += " TOP(1)  D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_LOCAL  "
				cQryt += " FROM " + RetSqlName("SD1") + " "
				cQryt += " 	WHERE "
				cQryt += " D1_FILIAL   = '" +cFilAnt+ "' AND D1_SRRURAL+D1_NFRURAL  = '" +cCheckRur+ "'  AND D1_FORNECE  = '" +cCheckFor+ "' AND D1_LOJA = '" +cCheckLoj+ "' AND D_E_L_E_T_ <> '*' "
				DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryt), NFTRANF, .T., .F.)
				(NFTRANF)->(dbGotop())
				If !(NFTRANF)->(Eof())
					cErro := "Nota fiscal do produtor rural "+AllTrim(cCheckRur)+"encontra-se como tranferencia realizada. Operacao Abortada"+CRLF + CRLF
					cImpEr+= cErro + CRLF + CRLF
					DbSelectArea(cAliasNFE)
					(cAliasNFE)->(dbSkip())
					Loop
				Else
					(NFTRANF)->(DbCloseArea())
				EndIf
			EndIF
			//verificar se produto da sobra e transferencia esta como os itens corretos.
			_CONTA  := Posicione('SB1',1,xFilial('SB1')+cProdCod,"B1_CONTA")
			_ITEMCC := Posicione('SB1',1,xFilial('SB1')+cProdCod,"B1_ITEMCC")
			//
			If  Alltrim(_CONTA) <> '111520004' .or. Alltrim(_ITEMCC) <> '114'
				cErro := "Nota fiscal "+AllTrim(cNota)+" nao importada, verificar no cadastro de produtos Nro.CONTA e ITEM CONTA. Operacao Abortada"+CRLF + CRLF
				cImpEr+= cErro + CRLF + CRLF
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(dbSkip())
				Loop
			EndIf
		EndIf
		//fim - Fernando Sigoli 22/02/2017
		// VERIFICA SE A NOTA JA EXISTE NO SISTEMA A PESAR DE NAO ESTAR FLEGADA NO SGNFE010 INTERFACE
		NFSEEK := GetNextAlias()
		//chamado 041786- fernando sigoli 30/05/2018
		cQryS := " SELECT * FROM " + RetSqlName("SF1") + " WHERE D_E_L_E_T_ = ' ' AND F1_FILIAL = '" + cFilAnt + "' AND F1_NOTASAG = '"+ cCheckDoc +"' AND F1_FORNECE = '"+ cCheckForn +"' AND F1_LOJA = '" + cCheckLoja + "' "
		cQryS += " AND NOT EXISTS(SELECT * FROM " + RetSqlName("SD2") + " SD2 WHERE D2_TIPO = 'D' AND D2_NFORI=F1_DOC AND D2_SERIORI=F1_SERIE AND D2_FILIAL=F1_FILIAL AND SD2.D_E_L_E_T_ = ' ') "
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryS), NFSEEK, .T., .F.)
		(NFSEEK)->(dbGotop())
		If ! (NFSEEK)->(Eof()) .And. ! nRadio == 5 //Everson - 24/05/2021. Chamado 14360. A valida็ใo de nota de produtor rural ้ realizada na SD1.
			MsgStop("Jแ hแ no Protheus entrada da nota do SAG " + cCheckDoc + ", fornecedor " + cCheckForn + ".","Fun็ใo InteNfeB")
			////TCSetConn(_conSAG)
			cStrUpd := "UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' , MENSAGEM_INT='' , F1_XDOC= '"+ cCheckDoc +"' , STATUS_PRC= 'P' WHERE F1_DOC = '" + cCheckDoc + "' AND F1_FORNECE = '" + cCheckForn + "' AND F1_LOJA = '" + cCheckLoja  + "' AND F1_ESPECIE = 'NF' AND OPERACAO_INT = '" + cCheckOp + "' "
			TcSqlExec(cStrUpd)
			(NFSEEK)->(DbCloseArea())
			////TCSetConn(_conSAG)
			dbSelectArea(cAliasNFE)
			(cAliasNFE)->(dbSkip())
			////TCSetConn(_conProthe)
			Loop
		Else
			(NFSEEK)->(DbCloseArea())
		EndIf
		If nRadio == 10
			If Empty(Alltrim(cValToChar((cAliasNFE)->D1_TES)))
				cErro := "Nota.: "+AllTrim(cNota)+" - Sem TES informada!: "+cFornec+" Lj.:"+cLoja + CRLF + CRLF
				cImpEr+= cErro + CRLF + CRLF
				MsgAlert("Nota produtor rural sem TES informada!")
				////TCSetConn(_conSAG)
				TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecno)))
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(dbSkip())
				Loop
			EndIf
		EndIf
		////TCSetConn(_conProthe)
		If cTipo == "B"
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If ! SA1->(DbSeek(xFilial("SA1")+cFornec+cLoja))
				cErro := "Nota.: "+AllTrim(cNota)+" - Cliente nao cadastrado Forn;:"+cFornec+" Lj.:"+cLoja + CRLF + CRLF
				cImpEr+= cErro + CRLF + CRLF
				MsgAlert(cErro)
				////TCSetConn(_conSAG)
				TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecno)))
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(DbSkip())
				Loop
			EndIf
		Else
			dbSelectArea("SA2")
			SA2->(DbSetOrder(1))
			If ! SA2->(DbSeek(xFilial("SA2")+cFornec+cLoja))
				cErro := "Nota.: "+AllTrim(cNota)+" - Fornecedor nao cadastrado Forn;:"+cFornec+" Lj.:"+cLoja + CRLF + CRLF
				cImpEr+= cErro + CRLF + CRLF
				MsgAlert(cErro)
				////TCSetConn(_conSAG)
				TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecno)))
				DbSelectArea(cAliasNFE)
				(cAliasNFE)->(DbSkip())
				Loop
			EndIf
		EndIf
		////TCSetConn(_conSAG)
		//Inicio: fernando sigoli 21/09/2018 Chamado: 044053
			/*
		If !Empty((cAliasNFE)->F1_CHVNFE)
				
			If (cAliasNFE)->F1_DOC <> SubStr((cAliasNFE)->F1_CHVNFE,26,9)
					
					cErro     := "NFE "+(cAliasNFE)->F1_DOC+" com chave diferente do numero da Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
					cImpEr	  += cErro + CRLF + CRLF
					////TCSetConn(_conSAG)
					dbSelectArea(cAliasNFE)
					dbSkip()
					Loop
			
			EndIF
			
		EndIf
			*/
		//Fim: fernando sigoli 21/09/2018 Chamado: 044053
		If (cAliasNFE)->F1_Serie == "000"
			If ! Empty((cAliasNFE)->D1_SERIORI)
				cSerie := (cAliasNFE)->D1_SERIORI
			Else
				cSerie  := (cAliasNFE)->F1_Serie
			EndIf
		Else
			cSerie  := (cAliasNFE)->F1_Serie
		EndIf
		cSerie  := (cAliasNFE)->F1_Serie
			/*
			D1_TIPO = 'C' notas com tipo de despesa de Comissใo
			D1_TIPO = 'F' notas com tipo de despesa de Frete
			D1_TIPO = 'A' notas com tipo de despesa de Armazenagem
			D1_TIPO = 'O'  Estou adicionando outras despesas, pois nใo sei se estas podem existir a pesar de nใo apontadas na reuniใo.
			*/
		cTpNota  := "NORMAL"
		cEspecie := "SPED"
		If (cAliasNFE)->D1_TIPO == "C"
			cTpNota  := "COMISS"
			cEspecie := (cAliasNFE)->F1_ESPECIE
		ElseIf (cAliasNFE)->D1_TIPO == "F"
			cTpNota  := "FRETE"
			cEspecie := "CTE"
		ElseIf (cAliasNFE)->D1_TIPO == "A"
			cTpNota := "ARMAZEN"
		ElseIf (cAliasNFE)->D1_TIPO == "O"
			cTpNota := "OUTROS"
		ElseIf (cAliasNFE)->D1_TIPO == "R"
			cTpNota := "CORRETAG"
		ElseIf (cAliasNFE)->D1_TIPO == "L"
			cTpNota := "FRANGO"
		ElseIf (cAliasNFE)->D1_TIPO == "M"
			cTpNota := "FRANGO"
		ElseIf (cAliasNFE)->D1_TIPO == 'T'
			//cCod := '813526' //por Adriana em 04/05/2016 - conforme chamado 028384
			cCod :=(cAliasNFE)->D1_COD //Chamado:047834 Fernando sigoli 13/03/2019
			cTpNota := "TRANSP"
			cEspecie := "NFS"
		ElseIf (cAliasNFE)->D1_TIPO == 'S'
			//cCod := '824729' //por Adriana em 03/06/2016 - conforme chamado 028846
			cCod :=(cAliasNFE)->D1_COD //fernando sigoli 13/04/2018
			cEspecie := "NFS"
		ElseIf (cAliasNFE)->D1_TIPO == 'V' // TIPO NFA
			cTpNota  := "FRETE"
			cEspecie := "NFA"
		ElseIf (cAliasNFE)->D1_TIPO == 'X' // Remessa.
			cTpNota  := "REMESSA"
		ElseIf (cAliasNFE)->D1_TIPO == 'U' 	// Chamado: 050135 - Fernando Sigoli 01/07/2019 - Nao consistir na central xml, quando Especie = NF
			cTpNota  := "NORMAL"
			cEspecie := (cAliasNFE)->F1_ESPECIE
		EndIf
		// se o produto for servico a especie muda para NFS
		If cEspecie == "SPED"
			cCod := (cAliasNFE)->D1_Cod
			////TCSetConn(_conProthe)
			cTip  := Posicione('SB1',1,xFilial('SB1')+cCod,"B1_TIPO")
			////TCSetConn(_conSAG)
			If rTrim(cTip) == "SV"
				cEspecie := "NFS"
			EndIf
		EndIf
		//tratamento para pegar chave da NF de-Entrada por Compra //fernando sigoli 06/03/2018
		If (nRadio == 1 .and. ALLTRIM((cAliasNFE)->TABEGENE) == 'PO01MVES') .OR. (nRadio == 5 .and. ALLTRIM((cAliasNFE)->TABEGENE) == 'POCAMVTP') .OR. (nRadio == 1 .and. ALLTRIM((cAliasNFE)->TABEGENE) == 'PO11MVES') //Leon | 05/08/2019 | Ch:050855
			cCHVNFE := (cAliasNFE)->F1_CHVNFE
		EndIf
		//CHAMADO: 040531 - FERNANDO SIGOLI
		If nRadio == 3 .and. ALLTRIM((cAliasNFE)->TABEGENE) == 'PO03MVES'
			cCHVNFE := (cAliasNFE)->F1_CHVNFE
		EndIf
		// se o tipo for frango apanha pegar a chave da nota de saida
		If ALLTRIM((cAliasNFE)->TABEGENE) == 'FCCAMVAP'
			cCHVNFE := ''
			////TCSetConn(_conProthe)
			cCHVNFE  := Posicione("SF2",1,'03'+cDoc+cSerie,"F2_CHVNFE")
			////TCSetConn(_conSAG)
		EndIf
		//
		aCabec	  := {}
		aCabNFR   := {}
		aItens	  := {}
		aItensNFR := {}
		aRec	  := {}
		cFormul   := (cAliasNFE)->F1_Formul
		If cFormul == "S"
			cDoc := "         "
		Else
			// retira a letra do sag do numero da nota
			If SubStr((cAliasNFE)->F1_Doc,1,1) == "E"
				cDoc := SubStr((cAliasNFE)->F1_Doc,2,10)
			Else
				cDoc := StrZero(Val((cAliasNFE)->F1_Doc),9)
			EndIf
		EndIf
		////TCSetConn(_conProthe)
		xDoc := ""
		xPrc := ""
		If cFormul == "S"
			//Everson - 06/11/2018.
			cSerie := Alltrim(cValToChar(GETMV("MV_#SRNFIT",,""))) // "01 "
			If Empty(cSerie)
				MsgStop("S้rie da nota fiscal nใo definida no parโmetro MV_#SRNFIT.","Fun็ใo InteNfeB")
				RestArea(aArea)
				Return Nil
			EndIf
			//
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Atualiza o Documento com o Numero do Proximo Documento de Saida ou Entrada com formulario proprio  ณ
			//ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			// Obtem numero do documento dentro da transacao
			cTpNrNfs  := SuperGetMV("MV_TPNRNFS") //Everson - 09/11/2018.
			DbSelectArea("SX5") //Tkt 33037 - Fernando Sigoli 01/10/2021
    		SX5->(DbSetOrder(1)) //Tkt 33037 - Fernando Sigoli 01/10/2021
			SX5->(DbGoTop()) //Tkt 33037 - Fernando Sigoli 01/10/2021
			If SX5->(DbSeek(xFilial("SX5")+'01'+cSerie))
				// funcao do padrao do protheus que retorna o proximo numero da nota				
				SX3->(dbSetOrder(1))
				If (SX3->(dbSeek("SD9"))) .And. cTpNrNfs == "3"
					cNumero	 := MA461NumNf(.T.,cSerie,Nil)
				Else
					cNumero  := NxtSX5Nota( cSerie,.T.,cTpNrNfs)
				EndIf
			Else
				cErro     := "Nota SAG "+(cAliasNFE)->F1_Doc+" S้rie nใo localizada na tabela 01: "+Alltrim(cSerie)
				cImpEr	  += cErro + CRLF + CRLF
				////TCSetConn(_conSAG)
				dbSelectArea(cAliasNFE)
				dbSkip()
				Loop
			EndIf
			cDoc := cNumero
			xDoc := cNumero
			xPrc := "P"
		EndIf
		////TCSetConn(_conSAG)
		//	nota de Frango
		If (cAliasNFE)->D1_TIPO = 'M'
			// O USUARIO TERA QUE DIGITAR a observa็ใo da nota
			If Empty((cAliasNFE)->F1_MENNOTA)
				cObs := DigObs((cAliasNFE)->F1_Doc)
			Else
				cObs := (cAliasNFE)->F1_MENNOTA
			EndIf
		EndIf
		// NO CASO DE FORMULARIO PROPRIO A DATA DE EMISSAO VAI SER SEMPRE A DATA BASE DO SISTEMA PARA NAO
		// PEGAR UMA DATA RETROATIVA DO SAG E EMITIR UMA NOTA 70 COM DIA 10 E 71 COM DIA 09
		dEmissao := iIf((cAliasNFE)->F1_Formul == "S",DDATABASE, (cAliasNFE)->F1_EMISSAO)
		If nRadio == 6
			dDataBase := dOrigB
			////TCSetConn(_conProthe)
			NFSEEK := GetNextAlias()
			cQryS:="SELECT F2_EMISSAO FROM "+RetSqlName("SF2")+" WHERE D_E_L_E_T_ = ' ' AND F2_FILIAL = '03' AND F2_CLIENTE = '027601' AND F2_DOC = '" + cDoc + "'"
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryS), NFSEEK, .T., .F.)
			TcSetField( NFSEEK, "F2_EMISSAO", "D", 8, 0)
			dbGotop()
			If !Eof()
				dEmissao   := (NFSEEK)->(F2_EMISSAO)
				(NFSEEK)->(DbCloseArea())
				////TCSetConn(_conSAG)
			EndIf
			////TCSetConn(_conSAG)
			//dDataBase  := (cAliasNFE)->F1_Emissao //chamado 057922 - || Fernando Sigoli 07/05/2020 - OS 059404 || CONTROLADORIA || THIAGO || 8439
			dDataBase  := (cAliasNFE)->F1_DTDIGIT  //chamado 057922 - || Fernando Sigoli 07/05/2020 - OS 059404 || CONTROLADORIA || THIAGO || 8439
		EndIf
		//cSerie := Iif((cAliasNFE)->F1_Formul == "S","01 ", cSerie) - Everson 06/11/2018.
		Aadd(aCabec,{"F1_FILIAL" , (cAliasNFE)->F1_Filial})  //Tipo de Nf
		Aadd(aCabec,{"F1_TIPO"   , (cAliasNFE)->F1_Tipo})    //Tipo de Nf
		Aadd(aCabec,{"F1_FORMUL" , cFormul})  		 //Formulแrio pr๓prio
		Aadd(aCabec,{"F1_DOC"    , cDoc})     //N๚mero do documento
		//Aadd(aCabec,{"F1_SERIE"  , iIf((cAliasNFE)->F1_Foปrmul == "S","001", StrZero(Val(cSerie),2))})   //Serie
		//Everson - 03/07/2017. Chamado 035012.
		If nRadio == 1 .And. Alltrim(cValToChar((cAliasNFE)->F1_Fornece)) $(cInsSer)
			cSerie := Padl(Alltrim(cValToChar(cSerie)),2,"0")
		EndIf
		//
		Aadd(aCabec,{"F1_SERIE"  , cSerie})   //Serie
		Aadd(aCabec,{"F1_EMISSAO", dEmissao}) //Emissao
		Aadd(aCabec,{"F1_DTDIGIT", DDATABASE})//Emissao
		Aadd(aCabec,{"F1_DESPESA", Val(cValToChar((cAliasNFE)->F1_DESPESA)) }) //Everson - 06/05/2019. Chamado 048963.
		Aadd(aCabec,{"F1_FORNECE", (cAliasNFE)->F1_Fornece}) //Fornecedor
		Aadd(aCabec,{"F1_LOJA"   , (cAliasNFE)->F1_Loja})    //Loja
		Aadd(aCabec,{"F1_ESPECIE", iIf(ALLTRIM((cAliasNFE)->F1_Formul) == "S" .OR. ALLTRIM((cAliasNFE)->TABEGENE) == 'FCCAMVAP',"SPED",cEspecie)})	 //Especie
		Aadd(aCabec,{"F1_CHVNFE" , Alltrim(cValToChar(cCHVNFE)) , Nil})          //Chave
		Aadd(aCabec,{"F1_NOMECON", (cAliasNFE)->NOMECOND, Nil})
		Aadd(aCabec,{"F1_MENNOTA", iIf((cAliasNFE)->D1_TIPO = 'M', cObs, (cAliasNFE)->F1_MENNOTA), Nil})
		Aadd(aCabec,{"F1_MENNOTB", (cAliasNFE)->F1_MENNOTB, Nil})
		Aadd(aCabec,{"F1_TPNOTA" , cTpNota, Nil})	  // TIPO DA NOTA NO SAG
		Aadd(aCabec,{"F1_NOTASAG", (cAliasNFE)->F1_DOC, Nil}) // TIPO DA NOTA NO SAG
		Aadd(aCabec,{"F1_CODIGEN", (cAliasNFE)->CODIGENE, Nil}) // TIPO DA NOTA NO SAG
		Aadd(aCabec,{"F1_XREC"   , (cAliasNFE)->F1_XREC, Nil}) // TIPO DA NOTA NO SAG
		//Aadd(aCabec,{"E2_NATUREZ", (cAliasNFE)->F1_NATUREZ, Nil}) // NATUREZA
		// ** INICIO REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
		////TCSetConn(_conProthe)
		cQueryP := " SELECT TOP(1)  D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_LOCAL "
		cQueryP += " FROM "+RetSqlName("SD1")+ " "
		cQueryP += " WHERE D1_FILIAL   = '" + xFilial("SD1")                      + "'"
		cQueryP += " AND D1_NFRURAL  = '" + STRZERO(VAL((cAliasNFE)->D1_NFORI),9) + "'"
		cQueryP += " AND D1_SRRURAL  = '" + (cAliasNFE)->D1_SERIORI               + "'"
		cQueryP += " AND D1_FORNECE  = '" + (cAliasNFE)->D1_FORNECE               + "'"
		cQueryP += " AND D1_LOJA     = '" + (cAliasNFE)->D1_LOJA                  + "'"
		cQueryP += " AND D_E_L_E_T_ <> '*' "
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQueryP), "TRB", .F., .T.)
		While TRB->(!EOF())
			cPnfOri 	 := TRB->D1_DOC
			cPseriOri 	 := TRB->D1_SERIE
			cPforneceOri := TRB->D1_FORNECE
			cPLojaOri    := TRB->D1_LOJA
			cLocal       := TRB->D1_LOCAL
			TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())
		////TCSetConn(_conSAG)
		// ** FINAL REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
		If dEmissao < dDataBase
			nDias := dDataBase - dEmissao
		Else
			nDias := 0
		EndIf
		//
		If AllTrim((cAliasNFE)->NOMECOND) == "ICM"    //alterado por Adriana em 01/07/2016 - chamado 029508
			Aadd(aCabec ,{"F1_COND", "ICM", Nil})
		ElseIf ALLTRIM((cAliasNFE)->F1_COND) == ''
			cCond := "S" + PadL(cValToChar(Abs(Val((cAliasNFE)->NOMECOND)-nDias)),2,"0")    //Incluido "S" no codigo para Condicoes utilizadas na integracao com SAG - por Adriana em 18/11/14 - chamado 020980 //Everson - 27/05/2020. Chamado 058500.
			Aadd(aCabec,{"F1_COND" ,cCond        ,Nil})	 // Condi็ใo Pagamento
		Else
			Aadd(aCabec	,{"F1_COND" ,(cAliasNFE)->F1_COND	, Nil})
		EndIf
		nRecNFE := (cAliasNFE)->R_E_C_N_O_
		cFilNFE := (cAliasNFE)->F1_Filial
		cChave  := (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT)
		aAreaNFE:= (cAliasNFE)->(GetArea())
		nVlrFrt := 0
		While (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT) == cChave
			aLinha :={}
			cLocal := ''
			nVlrFrt += (cAliasNFE)->F1_FRETE //Everson - 13/10/2017. Chamado 037596.
			//Everson - 27/06/2017. Chamado 035949.
			cVlrTxt := Alltrim(cValToChar((cAliasNFE)->D1_Total))
			cCsDec  := ""
			If At(".",cVlrTxt) > 0
				cCsDec := Alltrim(cValToChar(Substr(cVlrTxt, at(".",cVlrTxt) + 1 , Len(cVlrTxt))))
			EndIf
			//
			Conout("nRadio " + cValToChar(nRadio) )
			If nRadio == 1 .And. Len(cCsDec) >= 3 .And. (cAliasNFE)->D1_VUnit > 0 .And. (cAliasNFE)->D1_Total > 0
				nTotal   := (cAliasNFE)->D1_Total
				nVlrUnit := (cAliasNFE)->D1_VUnit
				nValDesc := Round((cAliasNFE)->D1_Desc,TamSX3("D1_VALDESC")[2])
				nQuant	 := (cAliasNFE)->D1_Total / nVlrUnit
			ElseIf nRadio == 3 .And. Alltrim(cValToChar((cAliasNFE)->D1_TES)) == Alltrim(cValToChar(cTesPTra)) //Everson - 18/10/2019. Chamado - 052348.
				nTotal   := (cAliasNFE)->D1_Total
				nVlrUnit := (cAliasNFE)->D1_VUnit
				nQuant	 := (cAliasNFE)->D1_QUANT
				nValDesc := Round((cAliasNFE)->D1_Desc,TamSX3("D1_VALDESC")[2])
			Else
				nTotal	:= Round((cAliasNFE)->D1_Total,2)
				nVlrUnit := (cAliasNFE)->D1_VUnit
				nValDesc := Round((cAliasNFE)->D1_Desc,TamSX3("D1_VALDESC")[2])
				If nTotal > 0 .And. nRadio <> 7 .And. nRadio <> 8 .And. nRadio <> 9 .and. nRadio <> 5
					nQuant	:= nTotal / nVlrUnit
					nValDesc := Round((cAliasNFE)->D1_Desc,TamSX3("D1_VALDESC")[2])
					nTotal   := Round(nTotal,2) //AJUSTE ERRO NO VALOR TOTAL DA NOTA CHAMADO - 024345 - WILLIAM COSTA
				Else
					nQuant   := (cAliasNFE)->D1_QUANT
					nTotal   := Round(nQuant * nVlrUnit,TamSX3("D1_TOTAL")[2])
					nTotal   := Round(nTotal,2) //AJUSTE ERRO NO VALOR TOTAL DA NOTA CHAMADO - 024345 - WILLIAM COSTA
				EndIf
			EndIf
			If AllTrim((cAliasNFE)->D1_LOCAL) == "04" .and. Alltrim((cAliasNFE)->D1_COD) <> ""
				////TCSetConn(_conProthe)
				cLocal  :=  IIF(!RetArqProd((cAliasNFE)->D1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+(cAliasNFE)->D1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+(cAliasNFE)->D1_COD,"B1_LOCPAD")) //alterado pelo chamado 030317 - William Costa iIf((AllTrim(Nfe->D1_LOCAL)) == "04",SubStr(AllTrim(Nfe->D1_CC),3,2),RetFldProd(Nfe->D1_COD,"B1_LOCPAD"))
				////TCSetConn(_conSAG)
			Endif
			If ((cAliasNFE)->D1_TIPO == 'C' .Or. (cAliasNFE)->D1_TIPO == 'A' .Or. (cAliasNFE)->D1_TIPO == 'R' .Or. (cAliasNFE)->D1_TIPO == 'O' .Or. (cAliasNFE)->D1_TIPO == 'S')
				_NFORI 		:= (cAliasNFE)->D1_NFORI
				_SERIORI 	:= (cAliasNFE)->D1_SERIORI
				_FORNECE	:= (cAliasNFE)->D1_FORNECE
				_LOJA		:= (cAliasNFE)->D1_LOJA
				//D1_TIPO,D1_NFORI,D1_SERIORI,D1_FORNECE,D1_ITEMORI
				////TCSetConn(_conSAG)
				cQryF:="SELECT * FROM SGNFE010 WHERE F1_FILIAL = '"+cFilAnt+"' AND F1_DOC = '"+_NFORI+"' AND F1_SERIE = '"+_SERIORI+"' AND F1_FORNECE = '"+_FORNECE+"' AND F1_LOJA = '"+rTrim(_LOJA)+"'"
				DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryF), "NFRETE", .T., .F.)
				TcSetField( "NFRETE", "F1_EMISSAO", "D", 8, 0 )
				dbSelectArea("NFRETE")
				NFRETE->(dbGotop())
				If ! NFRETE->(Eof())
					cCod := NFRETE->D1_COD
					////TCSetConn(_conProthe)
					dbSelectArea("ZA3")
					dbSeek(xFilial("ZA3")+cCod)
					If ZA3->(Eof())
						NFRETE->(DbCloseArea())
						cErFrete  := Posicione('SB1',1,xFilial('SB1')+cCod,"B1_DESC")
						cErro     := " Nao tem tabela ZA3 Amarra็ใo Frete X Produto.: "+Alltrim(cCod)+" - " + rTrim(cErFrete)
						cImpEr	  += cErro + CRLF + CRLF
						////TCSetConn(_conSAG)
						TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecno)))
						dbSelectArea(cAliasNFE)
						dbSkip()
						Loop
						cCod := Space(15)
					Else
						cCod := ZA3->ZA3_FRETE
					EndIf
					////TCSetConn(_conSAG)
				Else
					NFRETE->(DbCloseArea())
					If (cAliasNFE)->D1_TIPO == "C"
						cErro     := "Nao foi localizada a nota original da comissao.: "+Alltrim(_NFORI)+" Serie " + rTrim(_SERIORI)
					ElseIf (cAliasNFE)->D1_TIPO == "F"
						cErro     := "Nao foi localizada a nota original do transporte do frete.: "+Alltrim(_NFORI)+" Serie " + rTrim(_SERIORI)
					ElseIf (cAliasNFE)->D1_TIPO == "A"
						cErro     := "Nao foi localizada a nota original de armazenagem.: "+Alltrim(_NFORI)+" Serie " + rTrim(_SERIORI)
					ElseIf (cAliasNFE)->D1_TIPO == "O"
						cErro     := "Nao foi localizada a nota original 'outros'.: "+Alltrim(_NFORI)+" Serie " + rTrim(_SERIORI)
					ElseIf (cAliasNFE)->D1_TIPO == "R"
						cErro     := "Nao foi localizada a nota original da corretagem.: "+Alltrim(_NFORI)+" Serie " + rTrim(_SERIORI)
					ElseIf (cAliasNFE)->D1_TIPO == 'V' // TIPO NFA
						cErro     := "Nao foi localizada a nota original NFA.: "+Alltrim(_NFORI)+" Serie " + rTrim(_SERIORI)
					EndIf
					cImpEr    += cErro + CRLF + CRLF
					////TCSetConn(_conSAG)
					TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecno)))
					dbSelectArea(cAliasNFE)
					dbSkip()
					Loop
					cCod := Space(15)
				EndIf
				If (cAliasNFE)->D1_TIPO == 'C'
					//cCod := '821948' //Alterado de 813533 para 821948 conforme chamado 022493
					cCod :=(cAliasNFE)->D1_COD //Chamado:047834 Fernando sigoli 13/03/2019
				ElseIf (cAliasNFE)->D1_TIPO == 'A'
					//cCod := '821951' //Alterado de 881525 para 821951 conforme chamado 022493
					cCod :=(cAliasNFE)->D1_COD //Chamado:047834 Fernando sigoli 13/03/2019
				ElseIf (cAliasNFE)->D1_TIPO == 'R'
					//cCod := '821948' //Alterado de 813533 para 821948 conforme chamado 022493
					cCod :=(cAliasNFE)->D1_COD //Chamado:047834 Fernando sigoli 13/03/2019
				ElseIf (cAliasNFE)->D1_TIPO == 'S'
					//cCod := '824729' //conforme chamado 027518
					cCod :=(cAliasNFE)->D1_COD //Chamado:047834 Fernando sigoli 13/03/2019
				EndIf
				NFRETE->(DbCloseArea())
			Else
				////TCSetConn(_conSAG)
				dbSelectArea(cAliasNFE)
				cCod := iif((cAliasNFE)->D1_TIPO <> 'T',(cAliasNFE)->D1_Cod,cCod) //cCod := (cAliasNFE)->D1_Cod //por Adriana em 11/05/16 chamado  //por Adriana em 04/05/2016 - conforme chamado 028384
			EndIf
			dbSelectArea(cAliasNFE)
			cTpNota := "NORMAL"
			If (cAliasNFE)->D1_TIPO == "C"
				cTpNota := "COMISS"
			ElseIf (cAliasNFE)->D1_TIPO == "F"
				cTpNota := "FRETE"
			ElseIf (cAliasNFE)->D1_TIPO == "A"
				cTpNota := "ARMAZEN"
			ElseIf (cAliasNFE)->D1_TIPO == "O"
				cTpNota := "OUTROS"
			ElseIf (cAliasNFE)->D1_TIPO == "R"
				cTpNota := "CORRETAG"
			ElseIf (cAliasNFE)->D1_TIPO == 'V' // TIPO NFA
				cTpNota  := "FRETE"
				cEspecie := "NFA"
			EndIf
			////TCSetConn(_conProthe) //Everson 26/10/2017. Chamado 037789 -- ////TCSetConn(_conSAG)
			If((cAliasNFE)->TABEGENE = 'FCCAMVAP' .And. (cAliasNFE)->F1_Filial = '02')
				cLocal := IIF(!RetArqProd((cAliasNFE)->D1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+(cAliasNFE)->D1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+(cAliasNFE)->D1_COD,"B1_LOCPAD")) //chamado 030317 - William Costa // "16" 	//CHAMADO 029720 WILLIAM COSTA //"05"
			EndIf
			dbSelectArea(cAliasNFE)
			// ** INICIO ENCONTRAR O LOCAL CORRETO - chamado 030317 - William Costa ** //
			////TCSetConn(_conProthe)
			If (ALLTRIM(cLocal) == '' .AND. ALLTRIM((cAliasNFE)->D1_NFORI) == '') .Or. (Alltrim((cAliasNFE)->D1_TIPO) == 'X') .Or. (Alltrim((cAliasNFE)->TABEGENE) $('EC01LOTE|EC02LOTE|EC04LOTE|POCAMVTP'))  //fernando sigoli 21/02/2017
				If ALLTRIM(cCod) == ''
					cLocal := IIF(!RetArqProd((cAliasNFE)->D1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+(cAliasNFE)->D1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+(cAliasNFE)->D1_COD,"B1_LOCPAD")) //chamado 030317 - William Costa // "16" //CHAMADO 029720 WILLIAM COSTA
				Else
					cLocal := IIF(!RetArqProd(cCod + SPACE(TamSX3("B1_COD")[1] - (LEN(cCod)))),POSICIONE("SBZ",1,xFilial("SBZ")+cCod + SPACE(TamSX3("B1_COD")[1] - (LEN(cCod))),"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+cCod + SPACE(TamSX3("B1_COD")[1] - (LEN(cCod))),"B1_LOCPAD")) //chamado 030317 - William Costa // "16" //CHAMADO 029720 WILLIAM COSTA
				EndIf
				//fernando sigoli 21/02/2018
				If Alltrim((cAliasNFE)->TABEGENE) $ ('POCAMVTP')
					cLocal :=  Alltrim((cAliasNFE)->D1_LOCAL)
				EndIF
			Else
				If Alltrim((cAliasNFE)->D1_NFORI) <> '' .And. Alltrim(cLocal) == '' .And. Alltrim((cAliasNFE)->D1_TIPO) <> 'X' .And. !(Alltrim((cAliasNFE)->TABEGENE) $('EC01LOTE|EC02LOTE|EC04LOTE|POCAMVTP'))
					////TCSetConn(_conProthe)
					cQueryP := " SELECT TOP(1)  D1_LOCAL "
					cQueryP += "           FROM "+RetSqlName("SD1")+ " "
					cQueryP += "          WHERE D1_FILIAL   = '" + xFilial("SD1")                + "'"
					cQueryP += "            AND D1_DOC      = '" + STRZERO(VAL((cAliasNFE)->D1_NFORI),9) + "'"
					cQueryP += "            AND D1_SERIE    = '" + (cAliasNFE)->D1_SERIORI               + "'"
					cQueryP += "            AND D1_FORNECE  = '" + (cAliasNFE)->D1_FORNECE               + "'"
					cQueryP += "            AND D1_LOJA     = '" + (cAliasNFE)->D1_LOJA                  + "'"
					cQueryP += "            AND D_E_L_E_T_ <> '*' "
					DbUseArea(.t., "TOPCONN", TcGenQry(,, cQueryP), "TRC", .F., .T.)
					While TRC->(!EOF())
						cLocal := TRC->D1_LOCAL //chamado 030317 - William Costa
						TRC->(dbSkip())
					ENDDO
					TRC->(dbCloseArea())
					////TCSetConn(_conSAG)
				EndIf
			EndIf
			// ** FINAL ENCONTRAR O LOCAL CORRETO - chamado 030317 - William Costa ** //
			////TCSetConn(_conSAG)
			Aadd(aLinha,{"D1_FILIAL"  	, (cAliasNFE)->F1_Filial, Nil}) //item da nota
			Aadd(aLinha,{"D1_COD"   	, cCod			, Nil}) //c๓digo do produto
			Aadd(aLinha,{"D1_QUANT" 	, iIf(cTpNota == "FRETE", 1 ,nQuant)		, Nil}) //quantidade
			Aadd(aLinha,{"D1_VUNIT" 	, iIf(cTpNota == "FRETE", nTotal ,nVlrUnit)		, Nil}) //valor unitแrio
			Aadd(aLinha,{"D1_TOTAL" 	, nTotal		, Nil}) //total
			Aadd(aLinha,{"D1_LOCAL" 	, cLocal		, Nil}) //Centro de Custos
			Aadd(aLinha,{"D1_VALDESC" 	, nValDesc		, Nil}) //valor desconto do item
			Aadd(aLinha,{"D1_TPNOTA" 	, cTpNota		, Nil}) //tipo da nota que veio do SAG - frete, armazenagem, outros....
			Aadd(aLinha,{"D1_FORMUL" 	, cFormul, Nil})
			//Nota de origem da remessa.
			If Alltrim((cAliasNFE)->D1_TIPO) == 'X'
				Aadd(aLinha,{"D1_NFORI"   , Padl(Alltrim((cAliasNFE)->D1_NFORI),9,"0") , Nil})
				Aadd(aLinha,{"D1_SERIORI" , Alltrim((cAliasNFE)->D1_SERIORI)   , Nil})
			EndIf
			//Everson - 19/10/2017. Chamado 037488.
			If Alltrim((cAliasNFE)->TABEGENE) $('EC01LOTE|EC02LOTE|EC04LOTE')  //fernando sigoli 21/02/2017
				Aadd(aLinha,{"D1_NFRURAL" 	, Padl(Alltrim((cAliasNFE)->D1_NFORI),9,"0") , Nil})
				Aadd(aLinha,{"D1_SRRURAL" 	, Alltrim((cAliasNFE)->D1_SERIORI)   , Nil})
			Endif
			//D1_NFORI, D1_SERIORI,
			//fernando sigoli 21/02/2017
			If Alltrim((cAliasNFE)->TABEGENE) $('POCAMVTP')  //fernando sigoli 21/02/2017
				Aadd(aLinha,{"D1_NFORI" 	, Padl(Alltrim((cAliasNFE)->D1_NFORI),9,"0")    , Nil})
				Aadd(aLinha,{"D1_SERIORI" 	, Alltrim((cAliasNFE)->D1_SERIORI)   		    , Nil})
				Aadd(aLinha,{"D1_ITEMORI" 	, Alltrim((cAliasNFE)->D1_ITEMORI)   		    , Nil})
				//
				Aadd(aLinha,{"D1_NFRURAL" 	, Padl(Alltrim((cAliasNFE)->D1_NFRURAL),9,"0")  , Nil})
				Aadd(aLinha,{"D1_SRRURAL" 	, Alltrim((cAliasNFE)->D1_SRRURAL)   			, Nil})
			Endif
			//ajuste aplicado apenas para notas de produtor rural.
			If	nRadio == 10
				Aadd(aLinha,{"D1_NFRURAL" 	, (cAliasNFE)->F1_DOC, Nil})	//nota do produtor rural
				Aadd(aLinha,{"D1_SRRURAL" 	, (cAliasNFE)->F1_SERIE, Nil})	//s้rie do produtor rural
			Endif
			If ((cAliasNFE)->D1_TIPO == "L" .Or. (cAliasNFE)->D1_TIPO == "M") .Or.;
					(ALLTRIM((cAliasNFE)->TABEGENE) = 'FCCAMVAP' .And.(cAliasNFE)->F1_Filial = '02') .Or.;
					(ALLTRIM((cAliasNFE)->TABEGENE) = 'EC01LOTE') .Or.;
					(ALLTRIM((cAliasNFE)->TABEGENE) = 'EC02LOTE') .Or.;
					(ALLTRIM((cAliasNFE)->TABEGENE) = 'EC04LOTE') .Or.;
					(Substring(ALLTRIM((cAliasNFE)->TABEGENE),1,2) ==  'PO' .and. (cAliasNFE)->F1_FORMUL=='S') .Or.;
					(ALLTRIM((cAliasNFE)->TABEGENE) = 'POCAMVTP' .And.(cAliasNFE)->F1_FORMUL = 'S')
				lMata103 := .T.
				If nRadio == 6 // ENTRADA FRANGO VIVO APANHA
					//chamado: 041255 - 26/04/2018 - Fernando Sigoli
					Aadd(aLinha,{"D1_TES" 	 , (cAliasNFE)->D1_TES, Nil})
					Aadd(aLinha,{"D1_CC" 	 , cCCFV     		  , Nil}) //Centro de Custos
					Aadd(aLinha,{"D1_ITEMCTA", cITFV              , Nil}) //Centro de Custos
					////TCSetConn(_conSAG)
					If ALLTRIM((cAliasNFE)->TABEGENE) == 'FCCAMVAP' .And. (cAliasNFE)->F1_Filial == '02'
						Aadd(aLinha,{"D1_CONTA" 	, "111520005", Nil})   	//alterado por Everson em 06/03/17 chamado 033784
					EndIf
				Else
					//ajuste feito paras as nota de entrada de produtor rural transferencia e sobra
					//fernando sigoli 21/02/2017
					//IF  ALLTRIM((cAliasNFE)->TABEGENE) == 'POCAMVTP' .and. cCheckTP == 'SOBRA'
					//	Aadd(aLinha,{"D1_CONTA" 	, "111520004", Nil}) //Conta contabil
					//	Aadd(aLinha,{"D1_ITEMCTA"   , "114"      , Nil}) //item da conta
					//EndIF
					lMata103 := .T.
					Aadd(aLinha,{"D1_TES" 	, (cAliasNFE)->D1_TES, Nil})
					If ALLTRIM((cAliasNFE)->TABEGENE) <> 'POCAMVTP'
						Aadd(aLinha,{"D1_CC" 	, "5131"     , Nil}) //Centro de Custos
					EndIf
					////TCSetConn(_conSAG)
					If ALLTRIM((cAliasNFE)->TABEGENE) == 'FCCAMVAP' .And. (cAliasNFE)->F1_Filial == '02'
						Aadd(aLinha,{"D1_CONTA" 	, "111520005", Nil})	//alterado por Everson em 06/03/17 chamado 033784
					EndIf
				EndIf
			ElseIf nRadio == 3 .And. Alltrim(cValToChar((cAliasNFE)->D1_TES)) == Alltrim(cValToChar(cTesPTra)) //Everson - 18/10/2019. Chamado 052348.
				lMata103 := .T.
				Aadd(aLinha,{"D1_TES" 	 , cTesPTra, Nil})
				Aadd(aLinha,{"D1_CONTA"  , cCCPTra , Nil})
				Aadd(aLinha,{"D1_ITEMCTA", cICCPTra, Nil})
			Else
				Aadd(aLinha,{"D1_CC" 		, (cAliasNFE)->D1_CC	, Nil}) //Centro de Custos
				lMata103 := .F.
			EndIf
			////TCSetConn(_conProthe)
			// @history ticket 3873 - FWNM - 26/10/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
			//aPCSAG := UpCompSAG( (cAliasNFE)->F1_Filial, cDoc, cSerie, (cAliasNFE)->F1_TIPO, (cAliasNFE)->F1_FORNECE, (cAliasNFE)->F1_LOJA, cCod, nRadio, (cAliasNFE)->D1_CC )
			aPCSAG := UpCompSAG( (cAliasNFE)->F1_Filial, (cAliasNFE)->F1_DOC, (cAliasNFE)->F1_SERIE, (cAliasNFE)->F1_TIPO, (cAliasNFE)->F1_FORNECE, (cAliasNFE)->F1_LOJA, (cAliasNFE)->D1_COD, nRadio, (cAliasNFE)->D1_CC ) // @history ticket    8201 - Fernando Macieira - 18/01/2021 - IMPORTAวรO NFS 13820 E 13821
			If Len(aPCSAG) >= 2
				If !Empty(aPCSAG[1]) // @history ticket    3873 - Fernando Macieira - 24/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
					aAdd(aLinha,{"D1_PEDIDO" , aPCSAG[1]	, Nil}) // PC SAG
				EndIf
				If !Empty(aPCSAG[2]) // @history ticket    3873 - Fernando Macieira - 24/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
					aAdd(aLinha,{"D1_ITEMPC" , aPCSAG[2]	, Nil}) // Item PC SAG
				EndIf
			EndIf
			//
			//-----------------------|
			//log de registro        |
			//-----------------------|
			DbSelectArea("ZBE")
			RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH Date()
			Replace ZBE_HORA 	   	WITH TIME()
			Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("INTEGRACAO dDataBase" + Alltrim(dDataBase) + " NOTA : " + (cAliasNFE)->F1_DOC + " SERIE : " + (cAliasNFE)->F1_SERIE + " FORNECEDOR: "  + (cAliasNFE)->F1_FORNECE + " LOJA: " + (cAliasNFE)->F1_LOJA + " NOTA ORIGINAL " + (cAliasNFE)->D1_NFORI + " cPnfOri " + cPnfOri + " SERIE ORIGINAL: " + (cAliasNFE)->D1_SERIORI + " cPseriOri " + cPseriOri + " FORNECEDOR ORIGINAL: " + " cFornecOri: " + cFornecOri + " cPforneceOri: " + cPforneceOri + " LOJA: " + " cLojaForOri " + cLojaForOri + " cPLojaOri " + cPLojaOri)
			Replace ZBE_MODULO	    WITH "COMPRAS"
			Replace ZBE_ROTINA	    WITH "INTNFEB"
			////TCSetConn(_conSAG)
			dbSelectArea(cAliasNFE)
			Aadd(aRec,(cAliasNFE)->R_E_C_N_O_)
			Aadd(aItens, aLinha)
			(cAliasNFE)->(DbSkip())
		EndDo
		//Everson - 18/10/2019. Chamado 052348.
		If lMata103 .And. nRadio == 3
			Aadd(aCabec,{"F1_STATUS" ,"A"   , Nil})
		EndIf
		Aadd(aCabec,{"F1_FRETE"  , nVlrFrt, Nil}) 				 //Frete - incluido em 28/05/15 por Adriana  //Everson - 13/10/2017. Chamado 037596.
		////TCSetConn(_conProthe)
		// Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 08/05/2019
		If u_ExistXML(cDoc, cSerie, cCNPJ, cEspecie, cFormul, nRadio)
			// Chamado n. 052097 || OS 053474 || FISCAL || SIMONE || 8463 || CTES 3182 E 3189 - fwnm - 02/10/2019
			If u_DestOk(cDoc, cSerie, cCNPJ, cEspecie, cFormul, nRadio)
				lMsErroAuto	:= .F.
				lMsHelpAuto := .F.
				If lMata103 == .T.
					//Ordena os campos conforme dicionแrio de dados.
					aCabec := FWVetByDic(aCabec,"SF1")
					aItens := FWVetByDic(aItens,"SD1",.T.)
					//
					Conout( DToC(Date()) + " " + Time() + " INTNFEB  aCabec ")
					VarInfo("aCabec",aCabec)
					VarInfo("aItens",aItens)
					Conout("INTNFEB - MsExecAuto 103")
					MsExecAuto({|x,y| MATA103(x,y)},aCabec,aItens,3) // Inclusao
					If lMsErroAuto
						MostraErro()
					Endif
				Else
					//Ordena os campos conforme dicionแrio de dados.
					aCabec := FWVetByDic(aCabec,"SF1")
					aItens := FWVetByDic(aItens,"SD1",.T.)
					Conout("INTNFEB - MsExecAuto 140") 
					MsExecAuto({|x,y| MATA140(x,y)},aCabec,aItens,3)
				EndIf
			Else
				lMsErroAuto := .T.
				msgStop("[INTNFEB-01] - Lan็amento nใo realizado! " + Chr(13) + Chr(10) + "CNPJ do destinatแrio contido no XML da NF n. " + cDoc + "/" + cSerie + " nใo coincide com o CNPJ da empresa/filial que voc๊ estแ tentando lan็ar! Verifique ou entre na empresa/filial do CNPJ do destinatแrio...")
			EndIf
			//
		Else
			lMsErroAuto := .T.
			msgStop("[INTNFEB-02] - Lan็amento nใo realizado! " + Chr(13) + Chr(10) + "XML da NF n. " + cDoc + "/" + cSerie + " - CNPJ " + Transform(cCNPJ,"@R 99.999.999/9999-99") + " nใo encontrada na tabela da Central XML...")
		EndIf
		//
		//************ FINAL DO ACABEC WILLIAM COSTA***********//
		// Formulario Proprio vai mandar e-mail avisado os responsaveis.
		If !lMsErroAuto .And. cFormul == 'S'
			////TCSetConn(_conProthe)
			DbSelectArea("SF1")
			SF1->(DbSetOrder(1))
			If ! SF1->(DbSeek( xFilial("SF1") + cDoc + cSerie + Space(TamSX3("F1_SERIE")[1] - Len(cSerie)) +  cFornec +  cLoja ))
				MsgStop("Nใo foi possํvel gerar a nota fiscal n๚mero " + cDoc + "/" + cSerie + " para o fornecedor " + cFornec + "/" + cLoja)
				lMsErroAuto := .T.
			Else
				Aadd(aNFtrans,{cNumero,cSerie, cFornec, cLoja})
				cDe			:= "workflow@adoro.com.br"
				cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal com formularo pr๓prio de numero " + cDoc
				If  nRadio == 2 // ENTRADA POR DEVOLUวรO		 	-- Adriana Garcia, Rosangela, Simone
					cPara 		:= "adriana@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-ENTRADA POR DEVOLUวรO"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal ENTRADA POR DEVOLUวรO com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 3 // ENTRADA POR TRANSF. EMPRESA	 	-- Noemi, Rosangla, Simone
					cPara 		:= "noemi.ximenes@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-ENTRADA POR TRANSF. EMPRESA"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal ENTRADA POR TRANSF. EMPRESA com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 5 // ENTRADA POR TRANSF. INTEGRADO 	-- Adriana Garcia, Adriana Caldeira, Rosangela, Simone, Noemi, Pera, Fornari
					cPara 		:= "adriana.garcia@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br;adriana@adoro.com.br;noemi.ximenes@adoro.com.br;pera@adoro.com.br;valdecir.fornari@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-ENTRADA POR TRANSF. INTEGRADO"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal ENTRADA POR TRANSF. INTEGRADO com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 6 // ENTRADA FRANGO VIVO APANHA		-- Simone, rosangela, Valeria
					cPara 		:= "valeria@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-ENTRADA FRANGO VIVO APANHA"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal ENTRADA FRANGO VIVO APANHA com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 7 // FRANGO NF 1 RETORNO DE CRIACAO	 	-- Adriana Garcia, Rosangela, Simone
					cPara 		:= "adriana.garcia@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-FRANGO NF 1 RETORNO DE CRIACAO"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal FRANGO NF 1 RETORNO DE CRIACAO com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 8 // FRANGO 2 RETORNO SIMBOL CRIACAO	-- Adriana Garcia, Rosangela, Simone
					cPara 		:= "adriana.garcia@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-FRANGO NF 2 RETORNO DE CRIACAO"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal FRANGO NF 2 RETORNO DE CRIACAO com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 9 // FRANGO 4 COMPRA FRANGO VIVO		-- Adriana Garcia, Rosangela, Simone
					cPara 		:= "adriana.garcia@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-FRANGO NF 4 RETORNO DE CRIACAO"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal FRANGO NF 4 RETORNO DE CRIACAO com formularo pr๓prio de numero "+cDoc
				ElseIf nRadio == 10 //PRODUTOR RURAL
					cPara 		:= "noemi.ximenes@adoro.com.br"
					cCopia 		:= "rosangela@adoro.com.br;simone@adoro.com.br"
					cAssunto	:= "Nota Fiscal SAG X Protheus-PRODUTOR RURAL"
					cMensag		:= "Foi emitida via interface SAG X Protheus a nota fiscal PRODUTOR RURAL com formularo pr๓prio de numero "+cDoc
				EndIf
				lHtml		:= .F.
				U_M001MAIL(cPara,cCopia,cCpOcul,cAssunto,cDe,cMensag,lHtml,cAnexo,_lJob)
			EndIf
		EndIf
		//Tratamento caso haja erro no execauto.
		If lMsErroAuto
			cErro := ""
			aErroLog := GetAutoGrLog()
			If Len(aErrolog) > 0
				cErro := Alltrim(aErrolog[1])
				For k:=1 to Len(aErroLog) 
					If "INVALIDO" $ UPPER (aErroLog[k])
						cErro+= Alltrim(aErroLog[k]) + Chr(13)+Chr(10)
					EndIf
				Next
			Else
				cErro := "[INTNFEB-03] - Lan็amento nใo realizado! " + Chr(13) + Chr(10) + "XML da NF n. " + cDoc + "/" + cSerie + " - CNPJ " + Transform(cCNPJ,"@R 99.999.999/9999-99") + " nใo encontrada na tabela da Central XML..."
			EndIf
			////TCSetConn(_conProthe)
			U_CCSGrvLog(cErro, cAliasNFE, nRecNFE, 3, cFilNFE)
			cImpEr+= cErro + CRLF + CRLF
			MsgAlert(cErro)
			////TCSetConn(_conSAG)
			For ncont:=1 to Len (aRec)
				TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(aRec[nCont])))
			Next nCont
		Else
			If cFormul <> 'S'
				////TCSetConn(_conProthe)
				NFSEEK := GetNextAlias()
				If lMata116 == .T.
					cQryS:= "SELECT * FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = ' ' AND F1_FILIAL = '"+cFilAnt+"' AND F1_DOC = '"+STRZERO(VAL(cNotaSag),9)+"' AND F1_SERIE = '"+cSerie+"' AND F1_FORNECE = '"+rTrim(cFornSag)+"' AND F1_LOJA = '"+rTrim(cLoja)+"'"
				Else
					cQryS:="SELECT * FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = ' ' AND F1_FILIAL = '"+cFilAnt+"' AND F1_NOTASAG = '"+rTrim(cNotaSag)+"' AND F1_SERIE = '"+cSerie+"' AND F1_FORNECE = '"+rTrim(cFornSag)+"' AND F1_LOJA = '"+rTrim(cLoja)+"'"
				EndIf
				DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryS), NFSEEK, .T., .F.)
				//				dbSelectArea(NFSEEK)
				dbGotop()
				If Eof() // nao encontrou a nota no protheus
					(NFSEEK)->(DbCloseArea())
					lErroFrete := .T.
					cErro     := "Nota.: "+cDoc+" Fornec.: "+cFornec+" Nao importada para o Protheus!!!"
					cImpEr	  += cErro + CRLF + CRLF
				Else
					(NFSEEK)->(DbCloseArea())
					////TCSetConn(_conSAG)
					For ncont := 1 to Len (aRec)
						cImpOK += "Nota.: "+AllTrim(cDoc)+" - Fornecedor :"+cFornec+" Lj.:"+cLoja	+ CRLF + CRLF
						TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='"+Space(50)+"' WHERE R_E_C_N_O_="+AllTrim(Str(aRec[nCont])))
					Next nCont
					If lMata116 == .T. //ALTERACAO DE NOTA DE FRETE
						////TCSetConn(_conProthe)
						For ncont:=1 to Len (aRec)
							TcSqlExec("UPDATE "+RetSqlName("SF1")+ "  SET F1_CHVNFE = " + "'" + cChaveNfeFrete + "'" + " WHERE F1_FILIAL = " + "'"  + xFILIAL("SF1") + "'" + " AND F1_DOC = " + "'"  + cDocFrete + "'" + " AND F1_SERIE = " + "'"  + cSerieFrete + "'" + " AND F1_FORNECE = " + "'"  + cForneceFrete + "'" + " AND F1_LOJA = " + "'"  + cLojaFrete + "'" + " AND D_E_L_E_T_ <> '*' ")
						Next nCont
						For ncont:=1 to Len (aRec)
							TcSqlExec("UPDATE "+RetSqlName("SFT")+ " SET FT_CHVNFE = " + "'" + cChaveNfeFrete + "'" + " WHERE FT_FILIAL = " + "'"  + xFILIAL("SFT") + "'" + " AND FT_NFISCAL = " + "'"  + cDocFrete + "'" + " AND FT_SERIE = " + "'"  + cSerieFrete + "'" + " AND FT_CLIEFOR = " + "'"  + cForneceFrete + "'" + " AND FT_LOJA = " + "'"  + cLojaFrete + "'" + " AND D_E_L_E_T_ <> '*' ")
						Next nCont
						For ncont:=1 to Len (aRec)
							TcSqlExec("UPDATE "+RetSqlName("SF3")+ " SET F3_CHVNFE = " + "'" + cChaveNfeFrete + "'" + " WHERE F3_FILIAL = " + "'"  + xFILIAL("SF3") + "'" + " AND F3_NFISCAL = " + "'"  + cDocFrete + "'" + " AND F3_SERIE = " + "'"  + cSerieFrete + "'" + " AND F3_CLIEFOR = " + "'"  + cForneceFrete + "'" + " AND F3_LOJA = " + "'"  + cLojaFrete + "'" + " AND D_E_L_E_T_ <> '*' ")
						Next nCont
						////TCSetConn(_conSAG)
					EndIf
				EndIf
			Else
				If Empty(cNotaDe)
					cNotaDe := cDoc+" Serie "+cSerie
				EndIf
				cNotaAte := cDoc+" Serie "+cSerie
				////TCSetConn(_conSAG)
				cImpOK += "Nota.: "+AllTrim(cDoc)+" - Fornecedor :"+cFornec+" Lj.:"+cLoja	+ CRLF + CRLF
				For ncont:=1 to Len (aRec)
					TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='' , MENSAGEM_INT='"+Space(50)+"' , F1_XDOC= '"+ xDoc +"' , STATUS_PRC= '"+ xPrc +"' WHERE R_E_C_N_O_="+AllTrim(Str(aRec[nCont])))
				Next nCont
			EndIF
		EndIf
		////TCSetConn(_conSAG)
		RestArea(aAreaNFE)
		dbSelectArea(cAliasNFE)
	Else
		//******************************************************************************************************
		// EXCLUSAO
		// efetua cancelamento da nota no Protheus
		If IntNFEB1(.T.)
			cDoc := (cAliasNFE)->F1_DOC
		EndIf
	EndIf
EndDo
//
If nRadio == 6
	dDataBase := dOrigB
EndIf
//Everson - 06/11/2018.
If Len(aNFtrans) > 0
	MsAguarde({|| transmNF(aNFTrans,cSerie) },"Aguarde","Transmitindo NF's")
ElseIf !Empty(cNotaDe)
	MsgAlert("Geradas Notas Fiscais De.: "+cNotaDe+" a Ate -> "+cNotaAte)
ELSEIF !Empty(cDoc) .AND. Empty(cNotaDe) .AND. lErroFrete == .F.  .and. cDoc <> '000000000'
	MsgAlert("Geradas Notas Fiscais De.: "+cDoc+" a Ate -> "+cDoc)
EndIf
If ALLTRIM(cMensFinal) <> ''
	MsgAlert(cMensFinal + ' Verifique o Email Enviado ')
EndIf
//
////TCSetConn(_conSAG)
DbSelectArea(cAliasNFE)
(cAliasNFE)->(DbCloseArea())
//
RestArea(_aArea)
Return NiL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo	 ณ IntNFEB1     ณ Autor ณ Leonardo Rios	     ณ Data ณ 11.10.16 	  	ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri็ใo ณ Fun็ใo utilizado para realizar a exclusใo da nota caso esteja 	ณฑฑ
ฑฑณ			 ณ como uma pr้-nota ou caso ela esteja classificada				ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ IntNFEB - Importa็ใo de Notas do SAG no Protheus			      	ณฑฑ
ฑฑณ			 ณ Projeto SAG II													ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParโmetrosณ Nome		 - Tipo - Descri็ใo							 			ณฑฑ
ฑฑณParโmetrosณ lFlega	 - [B]  - Utilizado para informar se deverแ flegar a 	ณฑฑ
ฑฑณ								  tabela intermediaria							ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function IntNFEB1(lFlega)
	Local aArea			:= GetArea()
	Local aCabec		:= {}
	Local aItens		:= {}
	Local aRec			:= {}
	Local aLinha		:= {}
	Local cDoc 			:= ""
	Local cFilNFE 		:= ""
	Local cChave 		:= ""
	Local cSeek 		:= ""
	Local nfeFil		:= ""
	Local nfetipo		:= ""
	Local nfeDoc		:= ""
	Local nfeSerie		:= ""
	Local nfeFor		:= ""
	Local nfeLoja		:= ""
	Local cDocSag		:= ""
	Local cNotaSag		:= ""
	Local NFSEEK 		:= ""
	Local cQryS			:= ""
	Local cDoc  		:= (cAliasNFE)->F1_DOC
	Local cFornec   	:= (cAliasNFE)->F1_FORNECE
	Local cLoja  		:= (cAliasNFE)->F1_LOJA
	Local cOperInt 		:= Alltrim(cValToChar((cAliasNFE)->OPERACAO_INT))
	Local lCancNFE 		:= .T.
	Local lMsErroAuto	:= .F.
	Local nRec 			:= 0
	Local nREcNFE 		:= 0
	// efetua cancelamento da nota no Protheus
	nRec := (cAliasNFE)->(R_E_C_N_O_)
	//
	If SubStr((cAliasNFE)->F1_DOC,1,1) == "E"
		cDoc := SubStr((cAliasNFE)->F1_DOC,2,10)
	Else
		cDoc := StrZero(Val((cAliasNFE)->F1_DOC),9)
	EndIf
	nRecNFE  := (cAliasNFE)->R_E_C_N_O_
	cFilNFE  := (cAliasNFE)->F1_Filial
	cChave   := (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT)
	cSeek    := (cAliasNFE)->(F1_FILIAL+cDoc+(cAliasNFE)->F1_Serie+F1_FORNECE+F1_LOJA+F1_TIPO)
	nfeFil   := (cAliasNFE)->F1_FILIAL
	nfetipo  := (cAliasNFE)->F1_TIPO
	nfeDoc   := cDoc //F1_DOC
	nfeSerie := (cAliasNFE)->F1_SERIE
	nfeFor   := (cAliasNFE)->F1_FORNECE
	nfeLoja  := (cAliasNFE)->F1_LOJA
	cDocSag	 := (cAliasNFE)->F1_DOC
	cNotaSag := (cAliasNFE)->F1_DOC
	nCodGen	 := (cAliasNFE)->CODIGENE
	//
	////TCSetConn(_conProthe)
	If File("NFSEEK")
		(NFSEEK)->(dbCloseArea())
	EndIf
	//
	NFSEEK := GetNextAlias()
	cQryS	:= "SELECT R_E_C_N_O_ recn ,* FROM " + RetSqlName("SF1") + " WHERE D_E_L_E_T_=' ' AND F1_FILIAL = '" + cFilAnt + "' AND F1_FORNECE = '" + nfeFor + "' AND F1_CODIGEN = '" + ALLTRIM(STR(nCodGen)) + "' "	//"' AND F1_NOTASAG = '" + cNotaSag + "' "
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryS), NFSEEK, .T., .F.)
	dbGotop()
	If Eof() // nao encontrou a nota no protheus
		lCancNFE := .F.
		(NFSEEK)->(dbCloseArea())
		////TCSetConn(_conSAG)
		(cAliasNFE)->(DbSkip())
		RestArea(aArea)
		Return .F.
	Else
		nRec := (NFSEEK)->Recn
		dbSelectArea("SF1")
		dbSetOrder(1)
		go nRec
		////TCSetConn(_conProthe)
		dbSelectArea("SD1")
		//	D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD
		dbSetNickname("D1INTERFAC")
		SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		If Eof()
			lCancNFE := .F.
		Else
			lJaClassif  := .F. // indica se a nota ja foi classificada ou nใo
			aCabec		:= {}
			aItens		:= {}
			aLinha		:= {}
			aRec		:= {}
			Aadd(aCabec,{"F1_FILIAL" 	, SF1->F1_FILIAL	, Nil})
			Aadd(aCabec,{"F1_TIPO"   	, SF1->F1_TIPO		, Nil})
			Aadd(aCabec,{"F1_FORMUL" 	, SF1->F1_FORMUL	, Nil})
			Aadd(aCabec,{"F1_DOC"    	, SF1->F1_DOC		, Nil})
			Aadd(aCabec,{"F1_SERIE"  	, SF1->F1_SERIE		, Nil})
			Aadd(aCabec,{"F1_EMISSAO"	, SF1->F1_EMISSAO	, Nil})
			Aadd(aCabec,{"F1_DESPESA"	, SF1->F1_DESPESA	, Nil})
			Aadd(aCabec,{"F1_FORNECE"	, SF1->F1_FORNECE	, Nil})
			Aadd(aCabec,{"F1_LOJA"   	, SF1->F1_LOJA 		, Nil})
			Aadd(aCabec,{"F1_ESPECIE"	, SF1->F1_ESPECIE	, Nil})
			Aadd(aCabec,{"F1_CHVNFE"	, SF1->F1_CHVNFE	, Nil})
			While ! SD1->(Eof()) .AND. xFilial("SD1") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
				If ! Empty(SD1->D1_TES)  // ja foi classificada
					lCancNFE := .F.
					Exit
				EndIf
				If Empty(SD1->D1_TES)
					Aadd(aLinha,{"D1_ITEM"		,SD1->D1_ITEM		, Nil})
					Aadd(aLinha,{"D1_COD"		,SD1->D1_COD		, Nil})
					Aadd(aLinha,{"D1_UM"		,SD1->D1_UM			, Nil})
					Aadd(aLinha,{"D1_QUANT"		,SD1->D1_QUANT		, Nil})
					Aadd(aLinha,{"D1_VUNIT"		,SD1->D1_VUNIT		, Nil})
					Aadd(aLinha,{"D1_TOTAL"		,SD1->D1_TOTAL		, Nil})
					RecLock("SD1",.F.)
					dbDelete()
					MsUnLock()
				Else
					Aadd(aLinha,{"D1_FILIAL"	,SD1->D1_FILIAL		, Nil})
					Aadd(aLinha,{"D1_ITEM"		,SD1->D1_ITEM		, Nil})
					Aadd(aLinha,{"D1_COD"		,SD1->D1_COD		, Nil})
					Aadd(aLinha,{"D1_UM"		,SD1->D1_UM			, Nil})
					Aadd(aLinha,{"D1_QUANT"		,SD1->D1_QUANT		, Nil})
					Aadd(aLinha,{"D1_VUNIT"		,SD1->D1_VUNIT		, Nil})
					Aadd(aLinha,{"D1_TOTAL"		,SD1->D1_TOTAL		, Nil})
					Aadd(aLinha,{"D1_CF"		,SD1->D1_CF			, Nil})
					Aadd(aLinha,{"D1_DESC"		,SD1->D1_DESC		, Nil})
					Aadd(aLinha,{"D1_FORNECE"	,SD1->D1_FORNECE	, Nil})
					Aadd(aLinha,{"D1_LOJA"		,SD1->D1_LOJA		, Nil})
					Aadd(aLinha,{"D1_LOCAL"		,SD1->D1_LOCAL		, Nil})
					Aadd(aLinha,{"D1_DOC"		,SD1->D1_DOC		, Nil})
					Aadd(aLinha,{"D1_EMISSAO"	,SD1->D1_EMISSAO	, Nil})
					Aadd(aLinha,{"D1_DTDIGIT"	,SD1->D1_DTDIGIT	, Nil})
					Aadd(aLinha,{"D1_TIPO"		,SD1->D1_TIPO		, Nil})
					Aadd(aLinha,{"D1_SERIE"		,SD1->D1_SERIE		, Nil})
					Aadd(aLinha,{"D1_TP"		,SD1->D1_TP			, Nil})
					Aadd(aLinha,{"D1_TES"		,SD1->D1_TES		, Nil})
					lJaClassif := .T.
				EndIf
				If ! lJaClassif
					dbSelectArea("SF1")
					RecLock("SF1",.F.)
					dbDelete()
					MsUnLock()
				EndIf
				Aadd(aItens, aLinha)
				SD1->(dbSkip()) // Everson - 25/09/2017. Chamado 037326.
			EndDo
			lMsErroAuto:=.F.
			If ! lJaClassif // pre-nota
				// NAO FAZ NADA POIS JA EXCLUIU POR DELEวรO
				//					MsExecAuto({|x,y| MATA140(x,y)},aCabec,aItens,5) // Exclusao
			Else  // ja classificada
				MsExecAuto({|x,y| MATA103(x,y)},aCabec,aItens,5) // Exclusao
			EndIf
			If lMsErroAuto
				aErroLog:=GetAutoGrLog()
				cErro := ""
				For k:=1 to Len(aErroLog)
					//If "INVALIDO" $ UPPER (aErroLog[k])
					cErro+= Alltrim(aErroLog[k]) + Chr(13)+Chr(10)
					//EndIf
				Next
				cImpEr+= cErro + CRLF + CRLF
				U_CCSGrvLog(cErro, cAliasNFE, nRecNFE, 5, cFilNFE)
				////TCSetConn(_conSAG)
				dbSelectArea(cAliasNFE)
				cChave :=(cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT)
				cImpEr += "Nota.: "+AllTrim(cDoc)+" - Fornecedor :"+cFornec+" Lj.:"+cLoja	+ CRLF + CRLF
				If lFlega
					While (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT) == cChave
						nRec := (cAliasNFE)->(R_E_C_N_O_)
						//cQuery := "UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+"' "
						cQuery := "UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' "
						cQuery += " WHERE R_E_C_N_O_="+AllTrim(Str(nRec))
						TcSqlExec(cQuery)
						dbSkip()
					EndDo
				EndIf
			Else
				////TCSetConn(_conSAG)
				dbSelectArea(cAliasNFE)
				cChave:=(cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT)
				If lFlega .And. lCancNFE
					cImpOK += "Nota.: "+AllTrim(cDoc)+" - Fornecedor :"+cFornec+" Lj.:"+cLoja	+ CRLF + CRLF
					While (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT) == cChave
						nRec := (cAliasNFE)->(R_E_C_N_O_)
						cQuery := "UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' "
						cQuery += " WHERE R_E_C_N_O_="+AllTrim(Str(nRec))
						TcSqlExec(cQuery)
						dbSkip()
					EndDo
				EndIF
			EndIf
		EndIf
		////TCSetConn(_conProthe)
		(NFSEEK)->(dbCloseArea())
		////TCSetConn(_conSAG)
	EndIf
	//
	If ! lCancNFE // Nao foi possivel excluir a nota
		////TCSetConn(_conProthe)
		cErro := "Nota fiscal nao encontrada no Protheus, ou a nota jแ estแ classificada. "
		cImpEr+= cErro + CRLF + CRLF
		U_CCSGrvLog(cErro, cAliasNFE, nRecNFE, 5, cFilNFE)
		////TCSetConn(_conSAG)
		dbSelectArea(cAliasNFE)
		cChave:=(cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT)
		If cOperInt == "E"
			MsgStop(cErro + CRLF + CRLF + Alltrim(cValToChar(F1_DOC)) + "/" + Alltrim(cValToChar(F1_SERIE)) + " Fornecedor: " + Alltrim(cValToChar(F1_FORNECE)) + "-" + Alltrim(cValToChar(F1_LOJA)) + ".","Fun็ใo IntNFEB1")
		EndIf
		//
		If !Empty(cChave)
			cImpEr += "Nota.: "+AllTrim(cDoc)+" - Fornecedor :"+cFornec+" Lj.:"+cLoja	+ CRLF + CRLF
			While (cAliasNFE)->(F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT) == cChave
				nRec := (cAliasNFE)->(R_E_C_N_O_)
				//cQuery := "UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+"' "
				cQuery := "UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='"+cErro+"' "
				cQuery += " WHERE R_E_C_N_O_="+AllTrim(Str(nRec))
				TcSqlExec(cQuery)
				dbSelectArea(cAliasNFE)
				dbSkip()
			EndDo
		EndIf
	EndIf
	//
	////TCSetConn(_conSAG)
	If lFlega
		dbSelectArea(cAliasNFE)
		While (cAliasNFE)->(!Eof()) .And. cChave == F1_FILIAL+F1_TIPO+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+OPERACAO_INT
			(cAliasNFE)->(DbSkip())
		EndDo
	EndIf
	//
	RestArea(aArea)
Return lCancNFE
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSerieFrete   บAutor  ณMicrosiga           บ Data ณ  07/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SerieFrete(cDoc,cSerie)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define variaveis proprias da rotina                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Local cSerie := CriaVar("F1_SERIE",.F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Dialog Principal.														  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 160,215 TITLE "Confirma็ใo da Serie das Notas" PIXEL
	@ 003,003 To 030,106 OF oDlg1 PIXEL
	@ 003,005 Say "Nota " Size 25,10 Of oDlg1 PIXEL
	@ 015,015 Say cDoc   SIZE 36,10 OF oDlg1 PIXEL
	@ 033,003 To 060,106 OF oDlg1 PIXEL
	@ 033,005 Say "Informe a Serie" Size 40,10 OF oDlg1 PIXEL
	@ 045,020 MsGet cSerie SIZE 35,10 OF oDlg1 PIXEL
	DEFINE SBUTTON FROM 066,075 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	Activate Dialog oDlg1 Centered
Return(cSerie)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDigObs   บAutor  ณMicrosiga           บ Data ณ  07/08/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DigObs(cDoc)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define variaveis proprias da rotina                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cMenNota := CriaVar("F1_MENNOTA",.F.)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Dialog Principal.														  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE MSDIALOG oDlg1 FROM 000,000 TO 160,315 TITLE "Observa็ใo Nota Produtor Rural" PIXEL
	@ 003,003 To 030,156 OF oDlg1 PIXEL
	@ 003,005 Say "Nota " Size 25,10 Of oDlg1 PIXEL
	@ 015,015 Say cDoc   SIZE 36,10 OF oDlg1 PIXEL
	@ 033,003 To 060,156 OF oDlg1 PIXEL
	@ 033,005 Say "Digite a Obs:" Size 40,10 OF oDlg1 PIXEL
	@ 045,020 MsGet cMenNota SIZE 100,10 OF oDlg1 PIXEL
	DEFINE SBUTTON FROM 066,075 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	Activate Dialog oDlg1 Centered
Return(cMenNota)
//--------------------------------------------------------------------|
//rotina de gera็a๕ de frete, utilizando a rotina Automatica MATA116  |
//--------------------------------------------------------------------|  
STATIC FUNCTION GeraFrete()
	aRecno         := {}
	aRecnos        := {}
	aCabNFR        := {}
	aItensNFR      := {}
	cChaveTRCFrete := ''
	cQueryP        := ''
	cQueryTRG      := ''
	cCond          := ''
	cPnfOri 	   := ''
	cPseriOri 	   := ''
	cPforneceOri   := ''
	cPLojaOri      := ''
	cEstado        := ''
	cEstOri        := ''
	cMunOri        := ''
	cEstDes        := ''
	cMunDes        := ''
	cNaturez       := ''
	cQueryFrete    := ''
	cNotaDe        := ''
	cNotaAte       := ''
	lErroFrete     := .F.
	ncont          := 0
	lAltFrete      := .F.
	cSerNfOri	   := ""
	cQry       	   := '' //fernando sigoli 19/06/2018
	cNumeCTE       := '' //fernando sigoli 19/06/2018
	cFornCTE       := '' //fernando sigoli 19/06/2018
	cChavCTE       := '' //fernando sigoli 19/06/2018
	nValrCTE       := '' //fernando sigoli 19/06/2018
	cCNPJ          := '' //fernando sigoli 05/11/2018
	////TCSetConn(_conSAG)
	SqlCabFrete()
	ProcRegua(Contar("TRC","!Eof()"))
	TRC->(DbGoTop())
	While TRC->(!EOF())
		IncProc("CT-e | " + Alltrim(cValToChar(TRC->F1_DOC)) + "/" + Alltrim(cValToChar(TRC->F1_SERIE))  )
		// ************ INICIO DO ACABEC WILLIAM COSTA*********** //
		// *********************** INICIO ACABNFR MATA116 - WILLIAM COSTA 17/09/2015 ******************* //
		aRecno     := {}
		aRecnos    := {}
		aCabNFR    := {}
		aItensNFR  := {}
		lAltFrete  := .F.
		lErroFrete := .F.
		If ALLTRIM(TRC->OPERACAO_INT) == 'A'
			lAltFrete      := .T.
			////TCSetConn(_conProthe)
			cQryS:= "SELECT * FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = ' ' AND F1_FILIAL = '"+cFilAnt+"' AND F1_DOC = '"+STRZERO(VAL(TRC->F1_DOC),9)+"' AND F1_SERIE = '" + rTrim(TRC->F1_SERIE) + "' AND F1_FORNECE = '"+rTrim(TRC->F1_FORNECE)+"' AND F1_ESPECIE = 'CTE' "
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryS), 'NFSEEK', .F., .T.)
			DBGOTOP()
			If EOF() // nao encontrou a nota no protheus
				NFSEEK->(DbCloseArea())
				lAltFrete := .F.
			Else
				lAltFrete      := .T.
				ExcluiFrete()
				NFSEEK->(DbCloseArea())
			EndIf
		EndIf
		////TCSetConn(_conProthe)
		cEstado  := POSICIONE("SA2",1,xFilial("SA2")+TRC->F1_FORNECE + TRC->F1_LOJA,"A2_EST")
		//cNaturez := POSICIONE("SA2",1,xFilial("SA2")+TRC->F1_FORNECE + TRC->F1_LOJA,"A2_NATUREZ") //Chamado: 055874 - Fernando Sigoli  17/02/2020
		//Inicio: fernando sigoli 10/04/2018
		//Estado+municio - Origem
		cEstOri := POSICIONE("SA2",1,xFilial("SA2")+TRC->D1_FORNECE + TRC->D1_LOJA,"A2_EST")
		cMunOri := POSICIONE("SA2",1,xFilial("SA2")+TRC->D1_FORNECE + TRC->D1_LOJA,"A2_COD_MUN")
		//Estado+municio - Destino
		DbSelectArea("SM0")
		SM0->(DbGoTop())
		While ! SM0->(Eof() .And. SM0->M0_CODIGO == cEmpAnt)	//While SM0->(!Eof() .And. SM0->M0_CODIGO == cEmpAnt)
			If TRC->F1_FILIAL = Alltrim(cValToChar(SM0->M0_CODFIL))
				cEstDes := Alltrim(SM0->M0_ESTENT)
				cMunDes := substr(Alltrim(SM0->M0_CODMUN),3,5)
				Exit
			Endif
			SM0->(DbSkip())
		EndDo
		//Fim: fernando sigoli 10/04/2018
		////TCSetConn(_conSAG)
		aCabNFR        := {}
		aItensNFR      := {}
		Aadd(aCabNFR,{"",dDataBase-90                            		,Nil}) // Data Inicial
		Aadd(aCabNFR,{"",dDataBase                               		,Nil}) // Data Final
		Aadd(aCabNFR,{"",2                                       		,Nil}) // 2-Inclusao;1=Exclusao
		Aadd(aCabNFR,{"",TRC->F1_FORNECE                         		,Nil}) // Fornecedor do documento de Origem  - opcional
		Aadd(aCabNFR,{"",TRC->F1_LOJA                            		,Nil}) // Loja de origem - opcional
		Aadd(aCabNFR,{"",1                                       		,Nil}) // Tipo da nota de origem: 1=Normal;2=Devol/Benef
		Aadd(aCabNFR,{"",2                                       		,Nil}) // 1=Aglutina;2=Nao aglutina produtos
		Aadd(aCabNFR,{"F1_EST",cEstado                           		,Nil}) // Unidade da Federa็ใo - opcional
		Aadd(aCabNFR,{"",TRC->D1_TOTAL                                  ,Nil}) // Valor do conhecimento
		Aadd(aCabNFR,{"F1_FORMUL",IIF(TRC->F1_FORMUL == "S",2,1) 		,Nil}) // Formulแrio pr๓prio 1=Nao; 2=Sim
		Aadd(aCabNFR,{"F1_DOC",STRZERO(VAL(TRC->F1_DOC),9)       		,Nil}) // Numero do conhecimento
		Aadd(aCabNFR,{"F1_SERIE",TRC->F1_SERIE                   		,Nil}) // S้rie do documento
		Aadd(aCabNFR,{"F1_FORNECE",TRC->F1_FORNECE               		,Nil}) // C๓digo fornecedor (Transportador)
		Aadd(aCabNFR,{"F1_LOJA",TRC->F1_LOJA                     		,Nil}) // Loja fornecedor (Transportador)
		Aadd(aCabNFR,{"",TRC->D1_TES                             		,Nil}) // TES - Tipo de Entrada para Frete
		Aadd(aCabNFR,{"F1_BASERET",0                             		,Nil}) // Base do ICMS Retido - opcional
		Aadd(aCabNFR,{"F1_ICMRET",0                              		,Nil}) // Valor do ICMS Retido - opcional
		Aadd(aCabNFR,{"",TRC->F1_COND                            		,Nil}) // Condi็ใo de Pagamento
		Aadd(aCabNFR,{"F1_EMISSAO"  ,STOD(TRC->F1_EMISSAO)       		,Nil})
		Aadd(aCabNFR,{"F1_ESPECIE"  ,"CTE"                       		,Nil})
		Aadd(aCabNFR,{"F1_NATUREZ"  ,TRC->F1_NATUREZ             		,Nil})
		Aadd(aCabNFR,{"F1_TPNOTA"   ,"FRETE"                     		,Nil}) // TIPO DA NOTA NO SAG
		Aadd(aCabNFR,{"F1_NOTASAG"  ,TRC->F1_DOC					 	,Nil})
		//
		Aadd(aCabNFR,{"F1_UFORITR"  ,cEstOri					 	    ,Nil}) // Uf Origem do transporte
		Aadd(aCabNFR,{"F1_MUORITR"  ,cMunOri					 	    ,Nil}) // Municํpio Original do Transporte
		Aadd(aCabNFR,{"F1_UFDESTR"  ,cEstDes    					 	,Nil}) // UF Destino do Transporte
		Aadd(aCabNFR,{"F1_MUDESTR"  ,cMunDes   					     	,Nil}) // Municํpio Destino Transporte
		Aadd(aCabNFR,{"F1_DESPESA"  ,Val(cValToChar(TRC->F1_DESPESA))   ,Nil}) // Despesas. //Everson - 06/05/2019. Chamado 048963.
		// *********************** FINAL ACABNFR MATA116 - WILLIAM COSTA 17/09/2015 *******************/
		////TCSetConn(_conSAG)
		//Inicio. Chamado: 055874 - Fernando Sigoli  17/02/2020
		If Empty(TRC->F1_NATUREZ)
			cNaturez := POSICIONE("SA2",1,xFilial("SA2")+TRC->F1_FORNECE + TRC->F1_LOJA,"A2_NATUREZ")
		Else
			cNaturez := TRC->F1_NATUREZ
		EndIf
		//Fim. Chamado: 055874 - Fernando Sigoli  17/02/2020
		SqlItensFrete(TRC->F1_DOC,TRC->F1_SERIE,TRC->F1_FORNECE,TRC->F1_LOJA)
		If ! TRD->(Eof())
			Aadd(aCabNFR,{"F1_CODIGEN"  ,TRD->CODIGENE 	,Nil})
		EndIf
		While TRD->(!EOF())
			// *** INICIO VERIFICACAO SE A NOTA FISCAL ESTA NO PROTHEUS *** //
			////TCSetConn(_conProthe)
			cSerNfOri := Alltrim(cValToChar(TRD->D1_SERIORI ))
			If Alltrim(cValToChar(TRD->D1_FORNECE)) $cInsSer
				cSerNfOri := Padl(cSerNfOri,2,"0")
			EndIf
			//
			cQueryTRG := ""
			If Alltrim(cValToChar(TRD->ORIGRURAL)) == "S"
				cQueryTRG := " SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_TES,F1_DTDIGIT "
				cQueryTRG += "   FROM SF1010, SD1010    "
				cQueryTRG += "  WHERE F1_FILIAL          = '" + xFilial("SF1")                + "'"
				cQueryTRG += "    AND D1_NFRURAL         = '" + STRZERO(VAL(TRD->D1_NFORI),9) + "'"
				cQueryTRG += "    AND D1_SRRURAL         = '" + cSerNfOri                     + "'"
				cQueryTRG += "    AND F1_FORNECE         = '" + TRD->D1_FORNECE               + "'"
				cQueryTRG += "    AND F1_LOJA            = '" + TRD->D1_LOJA                  + "'"
				cQueryTRG += "    AND SF1010.D_E_L_E_T_ <> '*' "
				cQueryTRG += "    AND D1_FILIAL          = F1_FILIAL "
				cQueryTRG += "    AND D1_DOC             = F1_DOC "
				cQueryTRG += "    AND D1_SERIE           = F1_SERIE "
				cQueryTRG += "    AND D1_FORNECE         = F1_FORNECE "
				cQueryTRG += "    AND D1_LOJA            = F1_LOJA  "
				cQueryTRG += "    AND SD1010.D_E_L_E_T_ <> '*'  "
			Else
				cQueryTRG := " SELECT F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_TES,F1_DTDIGIT "
				cQueryTRG += "   FROM SF1010, SD1010    "
				cQueryTRG += "  WHERE F1_FILIAL          = '" + xFilial("SF1")                + "'"
				cQueryTRG += "    AND F1_DOC             = '" + STRZERO(VAL(TRD->D1_NFORI),9) + "'"
				cQueryTRG += "    AND F1_SERIE           = '" + cSerNfOri                     + "'"
				cQueryTRG += "    AND F1_FORNECE         = '" + TRD->D1_FORNECE               + "'"
				cQueryTRG += "    AND F1_LOJA            = '" + TRD->D1_LOJA                  + "'"
				cQueryTRG += "    AND SF1010.D_E_L_E_T_ <> '*' "
				cQueryTRG += "    AND D1_FILIAL          = F1_FILIAL "
				cQueryTRG += "    AND D1_DOC             = F1_DOC "
				cQueryTRG += "    AND D1_SERIE           = F1_SERIE "
				cQueryTRG += "    AND D1_FORNECE         = F1_FORNECE "
				cQueryTRG += "    AND D1_LOJA            = F1_LOJA  "
				cQueryTRG += "    AND SD1010.D_E_L_E_T_ <> '*'  "
			EndIf
			If Select("TRG") > 0
				TRG->(DbCloseArea())
			EndIf
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQueryTRG), "TRG", .F., .T.)
			TRG->(DbGoTop())
			If TRG->(EOF()) // nao encontrou a nota no protheus
				TRG->(DbCloseArea())
				If lErroFrete == .F.
					lErroFrete := .T.
				EndIf
				cImpEr+= "Nota.: "+STRZERO(VAL(TRD->D1_NFORI),9)+" Fornec.: "+TRD->D1_FORNECE+" Nota de Entrada nใo encontrada no Protheus, favor verificar!!!" + CRLF + CRLF
			Else
				//Validacao de TES
				If ALLTRIM(TRG->D1_TES) == ''
					If lErroFrete == .F.
						lErroFrete := .T.
					EndIf
					cImpEr+= "Nota.: "+STRZERO(VAL(TRD->D1_NFORI),9)+" Fornec.: "+TRD->D1_FORNECE+" Nota de Entrada nใo classificada no Protheus, favor verificar!!!" + CRLF + CRLF
				EndIf
				//Validacao de Data de Digita็ใo
				If STOD(TRG->F1_DTDIGIT) > dDataBase
					If lErroFrete == .F.
						lErroFrete := .T.
					EndIf
					cImpEr+= "Nota.: "+STRZERO(VAL(TRD->D1_NFORI),9)+" Fornec.: "+TRD->D1_FORNECE+" Nota de Entrada com Data de Digita็ใo maior que a Database." + CRLF + "Data Digita็ใo = " + DTOC(STOD(TRG->F1_DTDIGIT)) + " Data Base = " + DTOC(dDataBase) + " , favor verificar!!!" + CRLF + CRLF
				EndIf
				//valida se a nota CTE que esta sendo integrada existe o XML na central
				//nesse momento o xml esta apenas importado/baixa do sefaz
				//Inicio Fernando Sigoli 19/06/2018
				cNumeCTE := TRC->F1_DOC
				cFornCTE := TRC->F1_FORNECE
				cChavCTE := TRD->F1_CHVNFE
				nValrCTE := TRD->D1_TOTAL + TRC->F1_DESPESA
				cCNPJ   := Posicione('SA2',1,xFilial('SA2')+TRC->F1_FORNECE + TRC->F1_LOJA,"A2_CGC")   // Fernanado Sigoli 05/11/2018 Chamado: 044933
				//Inicio: fernando sigoli 21/09/2018 Chamado: 044053
				If !Empty(cChavCTE)
					If cNumeCTE <> SubStr(cChavCTE,26,9)
						cImpEr+= "CTE.: "+alltrim(STRZERO(VAL(cNumeCTE),9))+" Fornec.: "+cFornCTE+" chave diferente do numero da Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
						lErroFrete := .T.
					EndIF
				EndIf
				//Fim: fernando sigoli 21/09/2018 Chamado: 044053
				//inicio:  Fernanado Sigoli 05/11/2018 Chamado: 044933
				If !Empty(cChavCTE)
					If cCNPJ <> SubStr(cChavCTE,07,14)
						cImpEr+= "CTE.: "+alltrim(STRZERO(VAL(cNumeCTE),9))+" Fornec.: "+cFornCTE+" CNPJ diferente do numero da Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
						lErroFrete := .T.
					EndIF
				EndIf
				//Fim: Fernanado Sigoli 05/11/2018 Chamado: 044933
				// Chamado n. 047900 || OS 049165 || FISCAL || ALLAN || 8394 || VALIDAR EMISSAO CTE - FWNM - 14/05/2019
				//User Function ChkChvNF(cFilNF, cDoc, cSer, cFor, cLoj, cTipo, cSistema, cChaveNFe, cUF, cAnoMes, cCNPJ)
				If !u_ChkChvNF(TRC->F1_FILIAL, TRC->F1_DOC, TRC->F1_SERIE, TRC->F1_FORNECE, TRC->F1_LOJA, TRC->F1_TIPO, "SAG", cChavCTE, TRC->F1_EMISSAO, cCNPJ)
					cErro     := "CTE.: "+alltrim(STRZERO(VAL(cNumeCTE),9))+" Fornec.: "+cFornCTE+" com DATA, CNPJ, SERIE ou DOC diferente dos dados contidos na Nota Fiscal Informada, favor verificar!!!" + CRLF + CRLF
					cImpEr	  += cErro + CRLF + CRLF
					lErroFrete := .T.
				EndIf
				//
				////TCSetConn(_conProthe)
				RCTE := GetNextAlias()
				BeginSQL Alias RCTE
					SELECT	XML_CHAVE, XML_TOTCTE
					FROM 	RECNFCTE
					WHERE	%NotDel%
					AND		XML_CHAVE = %Exp:cChavCTE%
				EndSQL
				If !( RCTE )->( Eof() )
					If ( RCTE )->XML_TOTCTE <> nValrCTE
						cImpEr+= "CTE.: "+STRZERO(VAL(cNumeCTE),9)+" Fornec.: "+cFornCTE+" com valor "+cvaltochar(nValrCTE)+ " diferente do XML " +cvaltochar((RCTE)->XML_TOTCTE) +  ", favor verificar!!!" + CRLF + CRLF
						lErroFrete := .T.
					EndIf
				Else
					lErroFrete := .T.
					cImpEr+= "CTE.: "+STRZERO(VAL(cNumeCTE),9)+" Fornec.: "+cFornCTE+" nใo encontrado na central XML. Importa็ใo nao autorizada, favor verificar!!!" + CRLF + CRLF
				EndIf
				(RCTE)->(dbCloseArea())
				////TCSetConn(_conSAG)
				//Fim: Fernando Sigoli 19/06/2018
				TRG->(DbCloseArea())
			EndIf
			// *** FINAL VERIFICACAO SE A NOTA FISCAL ESTA NO PROTHEUS *** //
			aRecno := {}
			Aadd(aRecno,TRD->R_E_C_N_O_)
			Aadd(aRecno,TRD->F1_CHVNFE)
			Aadd(aRecno,TRC->F1_DOC)
			Aadd(aRecno,TRC->F1_SERIE)
			Aadd(aRecno,TRC->F1_FORNECE)
			Aadd(aRecno,TRC->F1_LOJA)
			Aadd(aRecno,STRZERO(VAL(TRD->D1_NFORI),9))
			Aadd(aRecno,TRD->D1_SERIORI )
			Aadd(aRecnos,aRecno)
			// ** INICIO REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
			////TCSetConn(_conProthe)
			cQueryP := " SELECT TOP(1)  D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA "
			cQueryP += "           FROM SD1010 "
			cQueryP += "          WHERE D1_FILIAL   = '" + xFilial("SD1")                + "'"
			cQueryP += "            AND D1_NFRURAL  = '" + STRZERO(VAL(TRD->D1_NFORI),9) + "'"
			cQueryP += "            AND D1_SRRURAL  = '" + TRD->D1_SERIORI               + "'"
			cQueryP += "            AND D1_FORNECE  = '" + TRD->D1_FORNECE               + "'"
			cQueryP += "            AND D1_LOJA     = '" + TRD->D1_LOJA                  + "'"
			cQueryP += "            AND D_E_L_E_T_ <> '*' "
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQueryP), "TRB", .F., .T.)
			//Everson - 11/01/2018. Chamado 039161.
			cPnfOri 	 := ""
			cPseriOri 	 := ""
			cPforneceOri := ""
			cPLojaOri    := ""
			//
			While TRB->(!EOF())
				cPnfOri 	 := TRB->D1_DOC
				cPseriOri 	 := TRB->D1_SERIE
				cPforneceOri := TRB->D1_FORNECE
				cPLojaOri    := TRB->D1_LOJA
				TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())
			////TCSetConn(_conSAG)
			// ** FINAL REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
			If	ALLTRIM(cPnfOri) 		== '' .AND. ;
					ALLTRIM(cPseriOri) 	 	== '' .AND. ;
					ALLTRIM(cPforneceOri)	== '' .AND. ;
					ALLTRIM(cPLojaOri)    	== ''
				aCabNFR[4][2] := TRD->D1_FORNECE
				aCabNFR[5][2] := TRD->D1_LOJA
				Aadd(aItensNFR,{{"",STRZERO(VAL(TRD->D1_NFORI),9)+ALLTRIM(cSerNfOri)+SPACE(( TamSX3("F1_SERIE")[1] - LEN(ALLTRIM(cSerNfOri)))),nil}})
			Else
				aCabNFR[4][2] := cPforneceOri
				aCabNFR[5][2] := cPLojaOri
				Aadd(aItensNFR,{{"",STRZERO(VAL(cPnfOri),9)+ALLTRIM(cPseriOri)+SPACE(( TamSX3("F1_SERIE")[1] - LEN(ALLTRIM(cPseriOri)))),nil}})
			EndIf
			TRD->(dbSkip())
		ENDDO
		TRD->(dbCloseArea())
		If lErroFrete == .F.
			lMsErroAuto 	:= .F.
			Begin Transaction
				////TCSetConn(_conProthe)
				// Chamado n. 048580 || OS 049871 || FISCAL || DEJAIME || 8921 || REL. WOKFLOW - FWNM - 08/05/2019
				If u_ExistXML(cNumeCTE, TRC->F1_SERIE, cCNPJ, TRC->F1_ESPECIE, TRC->F1_FORMUL, 0)
					// Chamado n. 052097 || OS 053474 || FISCAL || SIMONE || 8463 || CTES 3182 E 3189 - fwnm - 02/10/2019
					If u_DestOk(cNumeCTE, TRC->F1_SERIE, cCNPJ, TRC->F1_ESPECIE, TRC->F1_FORMUL, 0)
						MsExecAuto({|x,y| MATA116(x,y)},aCabNFR,aItensNFR)
						SF1->(dbClearFilter())
					Else
						lMsErroAuto := .T.
						lErroFrete := .T.
						msgStop("[INTNFEB-06] - Lan็amento nใo realizado! " + Chr(13) + Chr(10) + "CNPJ do destinatแrio contido no XML do CTE n. " + cNumeCTE + "/" + TRC->F1_SERIE + " nใo coincide com o CNPJ da empresa/filial que voc๊ estแ tentando lan็ar! Verifique ou entre na empresa/filial do CNPJ do destinatแrio...") //Tkt - 7257 - Fernando Sigoli 28/12/2020
					EndIf
					//
				Else
					lMsErroAuto := .T.
					lErroFrete := .T.
					msgStop("[INTNFEB-04] - Lan็amento nใo realizado! " + Chr(13) + Chr(10) + "XML do CTE n. " + cNumeCTE + "/" + TRC->F1_SERIE + " - CNPJ " + Transform(cCNPJ,"@R 99.999.999/9999-99") + " nใo encontrada na tabela da Central XML...")
				EndIf
				//
			End Transaction //fecha transacao
			If lMsErroAuto == .T. //nใo importou
				If lErroFrete == .F.
					lErroFrete := .T.
				EndIf
				aErroLog := GetAutoGrLog()
				cErro := ""
				If Len(aErrolog) > 0
					cErro := Alltrim(aErrolog[1]) + CRLF + CRLF
				Else
					cErro := "[INTNFEB-05] - Lan็amento nใo realizado! " + Chr(13) + Chr(10) + "XML do CTE n. " + cNumeCTE + "/" + TRC->F1_SERIE + " - CNPJ " + Transform(cCNPJ,"@R 99.999.999/9999-99") + " nใo encontrada na tabela da Central XML..."
				EndIf
				For k:=1 to Len(aErroLog)
					If "INVALIDO" $ UPPER (aErroLog[k])
						cErro += Alltrim(aErroLog[k]) + CRLF + CRLF
					EndIf
				Next
				MsgStop(cErro,"Erro importa็ใo")
				For ncont:=1 to Len (aRecnos)
					cImpEr+= "Nota.: "+STRZERO(VAL(aRecnos[ncont][7]),9)+" Serie.: "+aRecnos[ncont][8]+" Nao importada para o Protheus, verifique as notas de entrada!!!" + CRLF + CRLF
				NEXT
			Else
				For ncont:=1 to Len (aRecnos)
					////TCSetConn(_conProthe)
					cQryS:= "SELECT * FROM "+RetSqlName("SF1")+" WHERE D_E_L_E_T_ = ' ' AND F1_FILIAL = '"+cFilAnt+"' AND F1_DOC = '"+STRZERO(VAL(aRecnos[ncont][3]),9)+"' AND F1_SERIE = '" + cValToChar(aRecnos[ncont][4]) + "' AND F1_FORNECE = '" + rTrim(aRecnos[ncont][5]) + "' AND F1_ESPECIE = 'CTE' "
					DbUseArea(.t., "TOPCONN", TcGenQry(,, cQryS), 'NFSEEK', .F., .T.)
					NFSEEK->(dbGotop())
					If Eof() // nao encontrou a nota no protheus
						NFSEEK->(DbCloseArea())
						If lErroFrete == .F.
							lErroFrete := .T.
						EndIf
						cImpEr+= "Nota.: "+STRZERO(VAL(aRecnos[ncont][3]),9)+" Fornec.: "+aRecnos[ncont][5]+" Nao importada para o Protheus, verifique as notas de entrada do frete!!!" + CRLF + CRLF
					Else
						NFSEEK->(DbCloseArea())
						////TCSetConn(_conSAG)
						TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='"+Space(50)+"' WHERE R_E_C_N_O_="+AllTrim(Str(aRecnos[nCont][1])))
						////TCSetConn(_conProthe)
						//for็a a grava็ใo do estado e municiipo
						TcSqlExec("UPDATE SF1010 SET F1_UFORITR = " + "'" + cEstOri  + "'" + " WHERE F1_FILIAL = " + "'"  + xFILIAL("SF1") + "'" + " AND F1_DOC = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND F1_SERIE   = " + "'"  + aRecnos[nCont][4] + "'" + " AND F1_FORNECE = " + "'"  + aRecnos[nCont][5] + "'" + " AND F1_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						TcSqlExec("UPDATE SF1010 SET F1_MUORITR = " + "'" + cMunOri  + "'" + " WHERE F1_FILIAL = " + "'"  + xFILIAL("SF1") + "'" + " AND F1_DOC = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND F1_SERIE   = " + "'"  + aRecnos[nCont][4] + "'" + " AND F1_FORNECE = " + "'"  + aRecnos[nCont][5] + "'" + " AND F1_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						TcSqlExec("UPDATE SF1010 SET F1_MUORITR = " + "'" + cMunOri  + "'" + " WHERE F1_FILIAL = " + "'"  + xFILIAL("SF1") + "'" + " AND F1_DOC = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND F1_SERIE   = " + "'"  + aRecnos[nCont][4] + "'" + " AND F1_FORNECE = " + "'"  + aRecnos[nCont][5] + "'" + " AND F1_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						//FORวA A GRAVAR A NATUREZA DO TITULO APAGAR
						//Inicio. Chamado: 055874 - Fernando Sigoli  17/02/2020
						TcSqlExec("UPDATE SE2010 SET E2_NATUREZ = " + "'" + cNaturez + "'" + " WHERE E2_FILIAL = " + "'"  + xFILIAL("SE2") + "'" + " AND E2_NUM = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND E2_PREFIXO = " + "'"  + aRecnos[nCont][4] + "'" + " AND E2_FORNECE = " + "'"  + aRecnos[nCont][5] + "'" + " AND E2_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						//Fim. Chamado: 055874 - Fernando Sigoli  17/02/2020
						TcSqlExec("UPDATE SF1010 SET F1_CHVNFE = " + "'" + aRecnos[nCont][2] + "'" + " WHERE F1_FILIAL = " + "'"  + xFILIAL("SF1") + "'" + " AND F1_DOC = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND F1_SERIE = " + "'"  + aRecnos[nCont][4] + "'" + " AND F1_FORNECE = " + "'"  + aRecnos[nCont][5] + "'" + " AND F1_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						TcSqlExec("UPDATE SFT010 SET FT_CHVNFE = " + "'" + aRecnos[nCont][2] + "'" + " WHERE FT_FILIAL = " + "'"  + xFILIAL("SFT") + "'" + " AND FT_NFISCAL = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND FT_SERIE = " + "'"  + aRecnos[nCont][4] + "'" + " AND FT_CLIEFOR = " + "'"  + aRecnos[nCont][5] + "'" + " AND FT_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						TcSqlExec("UPDATE SF3010 SET F3_CHVNFE = " + "'" + aRecnos[nCont][2] + "'" + " WHERE F3_FILIAL = " + "'"  + xFILIAL("SF3") + "'" + " AND F3_NFISCAL = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND F3_SERIE = " + "'"  + aRecnos[nCont][4] + "'" + " AND F3_CLIEFOR = " + "'"  + aRecnos[nCont][5] + "'" + " AND F3_LOJA = " + "'"  + aRecnos[nCont][6] + "'" + " AND D_E_L_E_T_ <> '*' ")
						//TcSqlExec("UPDATE SD1010 SET D1_LOCAL = '05' " + "WHERE D1_FILIAL = " + "'"  + xFILIAL("SD1") + "'" + " AND D1_DOC = " + "'"  + STRZERO(VAL(aRecnos[ncont][3]),9) + "'" + " AND D1_SERIE = " + "'"  + aRecnos[nCont][4] + "'" + " AND D1_FORNECE = " + "'"  + aRecnos[nCont][5] + "'" + " AND D1_LOJA = " + "'"  + aRecnos[nCont][6] + "'"+ " AND D_E_L_E_T_ <> '*' ") //Everson 31/08/2017. Removido update. Chamado 036928
						////TCSetConn(_conSAG)
					EndIf
					If lErroFrete == .F.
						If EMPTY(cNotaDe)
							cNotaDe := STRZERO(VAL(aRecnos[ncont][3]),9)+" Serie "+aRecnos[ncont][4]
						EndIf
						cNotaAte := STRZERO(VAL(aRecnos[ncont][3]),9)+" Serie "+aRecnos[ncont][4]
						////TCSetConn(_conSAG)
						TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' , MENSAGEM_INT='"+Space(50)+"' , F1_XDOC= '"+ STRZERO(VAL(aRecnos[ncont][3]),9) +"' , STATUS_PRC= 'P'" + "WHERE R_E_C_N_O_="+AllTrim(Str(aRecnos[nCont][1])))
					EndIf
				Next nCont
			EndIF
		EndIf
		//-----------------------|
		//log de registro        |
		//-----------------------|
		////TCSetConn(_conProthe)
		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
		Replace ZBE_DATA 	   	WITH Date()
		Replace ZBE_HORA 	   	WITH TIME()
		Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
		Replace ZBE_LOG	        WITH ("INTEGRACAO " + Alltrim(dDataBase) + " CTE : " + TRC->F1_DOC + " SERIE : " + TRC->F1_SERIE + " FORNECEDOR: "  + TRC->F1_FORNECE + " LOJA: " + TRC->F1_LOJA)
		Replace ZBE_MODULO	    WITH "COMP-ICTE"
		Replace ZBE_ROTINA	    WITH "INTNFEB"
		DbSelectArea("TRC")
		TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea())
	If ALLTRIM(cNotaDe) <> ''
		cMensagem += "Geradas Notas Fiscais De.: "+cNotaDe+" a Ate -> "+cNotaAte + CRLF + CRLF
	EndIf
Return Nil
Static Function SqlCabFrete()
	cQueryFrete := "SELECT F1_DOC, "
	cQueryFrete += "       F1_SERIE, "
	cQueryFrete += "       F1_FORNECE, "
	cQueryFrete += "       F1_LOJA, "
	cQueryFrete += "       D1_TES, "
	cQueryFrete += "       D1_TOTAL, "
	cQueryFrete += "       F1_FORMUL, "
	cQueryFrete += "       NOMECOND, "
	cQueryFrete += "       F1_COND, "
	cQueryFrete += "       F1_NATUREZ, "
	cQueryFrete += "       F1_EMISSAO, "
	cQueryFrete += "       F1_DESPESA, " //Everson - 06/05/2019. Chamado 048963.
	cQueryFrete += "       OPERACAO_INT, ORIGRURAL, D1_FORNECE , D1_LOJA, F1_FILIAL, F1_ESPECIE, F1_TIPO "
	cQueryFrete += "  FROM SGNFE010 "
	cQueryFrete += " WHERE ((D1_MSEXP    = ' ' "
	cQueryFrete += "    OR (D1_MSEXP    <> ' ' "
	cQueryFrete += "   AND STATUS_INT    = 'E' )) "
	cQueryFrete += "   AND F1_FILIAL     = '" +cFilAnt+ "' ) "
	cQueryFrete += "   AND TABEGENE      = 'POCAMVNE' "
	cQueryFrete += "   AND D1_TIPO       = 'F' "
	//cQueryFrete += "   AND F1_DOC        = '000065223' "
	cQueryFrete += "   AND (OPERACAO_INT = 'I' "
	cQueryFrete += "   OR OPERACAO_INT  = 'A') "
	cQueryFrete += "   AND F1_DTDIGIT    = '" +DTOS(DDATABASE)+ "' "
	cQueryFrete += "   AND F1_EMISSAO   <= '" +DTOS(DDATABASE)+ "' "
	cQueryFrete += " GROUP BY F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_TES,D1_TOTAL,F1_FORMUL,NOMECOND,F1_COND,F1_NATUREZ,F1_EMISSAO, F1_DESPESA, OPERACAO_INT, ORIGRURAL, D1_FORNECE, D1_LOJA, F1_FILIAL, F1_ESPECIE, F1_TIPO "
	cQueryFrete += " ORDER BY F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_TES,D1_TOTAL,F1_FORMUL,NOMECOND,F1_COND,F1_NATUREZ,F1_EMISSAO, F1_DESPESA, OPERACAO_INT, ORIGRURAL, D1_FORNECE, D1_LOJA, F1_FILIAL, F1_ESPECIE, F1_TIPO "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryFrete), "TRC", .F., .T.)
Return Nil
Static Function SqlItensFrete(cF1_DOC,cF1_SERIE,cF1_FORNECE,cF1_LOJA)
	cQueryFrete := "SELECT D1_NFORI, "
	cQueryFrete += "       D1_SERIORI, "
	cQueryFrete += "       D1_FORNECE, "
	cQueryFrete += "       D1_LOJA, "
	cQueryFrete += "       R_E_C_N_O_, "
	cQueryFrete += "       F1_CHVNFE, "
	cQueryFrete += "       F1_DESPESA, " //Everson - 06/05/2019. Chamado 048963.
	cQueryFrete += "       OPERACAO_INT, CODIGENE, ORIGRURAL,D1_TOTAL " //fernando sigoli 19/06/2018, add na queru o campo D1_TOTAL (VALOR DO CTE) "
	cQueryFrete += "   FROM SGNFE010 "
	cQueryFrete += " WHERE ((D1_MSEXP    =' ' "
	cQueryFrete += "    OR (D1_MSEXP    <> ' ' "
	cQueryFrete += "   AND STATUS_INT    = 'E' )) "
	cQueryFrete += "   AND F1_FILIAL     = '"+cFilAnt+ "' ) "
	cQueryFrete += "   AND TABEGENE      = 'POCAMVNE' "
	cQueryFrete += "   AND F1_EMISSAO   <= '"+DTOS(DDATABASE)+ "' "
	cQueryFrete += "   AND D1_TIPO       = 'F' "
	cQueryFrete += "   AND (OPERACAO_INT = 'I' "
	cQueryFrete += "    OR OPERACAO_INT  = 'A') "
	cQueryFrete += "   AND F1_DOC        = '"+cF1_DOC+ "' "
	cQueryFrete += "   AND F1_SERIE      = '"+cF1_SERIE+ "' "
	cQueryFrete += "   AND F1_FORNECE    = '"+cF1_FORNECE+ "' "
	cQueryFrete += "   AND F1_LOJA       = '"+cF1_LOJA+ "' "
	cQueryFrete += "   AND F1_DTDIGIT    = '" +DTOS(DDATABASE)+ "' "
	cQueryFrete += " ORDER BY F1_FILIAL,CODIGENE,R_E_C_N_O_ , D1_TRANSIT, F1_DESPESA "
	If Select("TRD") > 0
		TRD->(DbCloseArea())
	Endif
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryFrete), "TRD", .F., .T.)
	TRD->(DbGoTop())
Return Nil
STATIC FUNCTION ExcluiFrete()
	aRecno         := {}
	aRecnos        := {}
	aCabNFR        := {}
	aItensNFR      := {}
	cChaveTRCFrete := ''
	cQueryP        := ''
	cCond          := ''
	cPnfOri 	   := ''
	cPseriOri 	   := ''
	cPforneceOri   := ''
	cPLojaOri      := ''
	cEstado        := ''
	cNaturez       := ''
	cQueryFrete    := ''
	cNotaDe        := ''
	cNotaAte       := ''
	lErroFrete     := .F.
	ncont          := 0
	cQrChek		   := ""
	cRemUpd		   := ""
	////TCSetConn(_conSAG)
	SqlExcCabFrete()
	ProcRegua(Contar("TRE","!Eof()"))
	TRE->(DbGoTop())
	While TRE->(!EOF())
		IncProc("CT-e | " + Alltrim(cValToChar(TRE->F1_DOC)) + "/" + Alltrim(cValToChar(TRE->F1_SERIE))  )
		// ************ INICIO DO ACABEC WILLIAM COSTA*********** //
		// *********************** INICIO ACABNFR MATA116 - WILLIAM COSTA 17/09/2015 ******************* //
		aRecno     := {}
		aRecnos    := {}
		////TCSetConn(_conProthe)
		cEstado  := POSICIONE("SA2",1,xFilial("SA2")+TRE->F1_FORNECE + TRE->F1_LOJA,"A2_EST")
		cNaturez := POSICIONE("SA2",1,xFilial("SA2")+TRE->F1_FORNECE + TRE->F1_LOJA,"A2_NATUREZ")
		////TCSetConn(_conSAG)
		cQrChek := " SELECT * FROM " + RetSqlName("SF1") + " "
		cQrChek += " WHERE F1_FILIAL = '" + cFilAnt +  "' "
		cQrChek += " AND F1_DOC = '" + STRZERO(VAL(Alltrim(cValToChar(TRE->F1_DOC))),9) + "' "
		cQrChek += " AND F1_SERIE = '" + Alltrim(cValToChar(TRE->F1_SERIE)) + "' AND F1_FORNECE = '" + Alltrim(cValToChar(TRE->F1_FORNECE)) + "' AND F1_LOJA = '" + Alltrim(cValToChar(TRE->F1_LOJA)) + "' AND F1_ESPECIE = 'CTE' AND D_E_L_E_T_ = '' "
		If Select("CK_CTE") > 0
			CK_CTE->(DbCloseArea())
		EndIf
		////TCSetConn(_conProthe)
		TcQuery cQrChek New Alias "CK_CTE"
		DbSelectArea("CK_CTE")
		CK_CTE->(DbGoTop())
		If CK_CTE->(Eof())
			MsgStop("O CT-e " + Alltrim(cValToChar(TRE->F1_DOC)) + " nใo serแ excluํdo, pois nใo estแ lan็ado no Protheus.","Fun็ใo ExcluiFrete")
			////TCSetConn(_conSAG)
			TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' , MENSAGEM_INT='"+Space(50)+"' , F1_XDOC= '"+ Alltrim(cValToChar(TRE->F1_DOC)) +"' , STATUS_PRC= 'P'" +" WHERE F1_DOC = '" + Alltrim(cValToChar(TRE->F1_DOC)) + "' AND F1_SERIE = '" + Alltrim(cValToChar(TRE->F1_SERIE)) + "' AND F1_FORNECE = '" + Alltrim(cValToChar(TRE->F1_FORNECE)) + "' AND F1_LOJA = '" + Alltrim(cValToChar(TRE->F1_LOJA))  + "' AND F1_ESPECIE = 'CTE' AND OPERACAO_INT = 'E' " )
			CK_CTE->(DbCloseArea())
			TRE->(DbSkip())
			Loop
		EndIf
		CK_CTE->(DbCloseArea())
		aCabNFR        := {}
		aItensNFR      := {}
		Aadd(aCabNFR,{"",dDataBase-90                            ,Nil}) // Data Inicial
		Aadd(aCabNFR,{"",dDataBase                               ,Nil}) // Data Final
		Aadd(aCabNFR,{"",1                                       ,Nil}) // 2-Inclusao;1=Exclusao
		Aadd(aCabNFR,{"",TRE->F1_FORNECE                         ,Nil}) // Fornecedor do documento de Origem  - opcional
		Aadd(aCabNFR,{"",TRE->F1_LOJA                            ,Nil}) // Loja de origem - opcional
		Aadd(aCabNFR,{"",1                                       ,Nil}) // Tipo da nota de origem: 1=Normal;2=Devol/Benef
		Aadd(aCabNFR,{"",2                                       ,Nil}) // 1=Aglutina;2=Nao aglutina produtos
		Aadd(aCabNFR,{"F1_EST",cEstado                           ,Nil}) // Unidade da Federa็ใo - opcional
		Aadd(aCabNFR,{"",TRE->D1_TOTAL                           ,Nil}) // Valor do conhecimento
		Aadd(aCabNFR,{"F1_FORMUL",IIF(TRE->F1_FORMUL == "S",2,1) ,Nil}) // Formulแrio pr๓prio 1=Nao; 2=Sim
		Aadd(aCabNFR,{"F1_DOC",STRZERO(VAL(TRE->F1_DOC),9)       ,Nil}) // Numero do conhecimento
		Aadd(aCabNFR,{"F1_SERIE",TRE->F1_SERIE                   ,Nil}) // S้rie do documento
		Aadd(aCabNFR,{"F1_FORNECE",TRE->F1_FORNECE               ,Nil}) // C๓digo fornecedor (Transportador)
		Aadd(aCabNFR,{"F1_LOJA",TRE->F1_LOJA                     ,Nil}) // Loja fornecedor (Transportador)
		Aadd(aCabNFR,{"",TRE->D1_TES                             ,Nil}) // TES - Tipo de Entrada para Frete
		Aadd(aCabNFR,{"F1_BASERET",0                             ,Nil}) // Base do ICMS Retido - opcional
		Aadd(aCabNFR,{"F1_ICMRET",0                              ,Nil}) // Valor do ICMS Retido - opcional
		Aadd(aCabNFR,{"",TRE->F1_COND                            ,Nil}) // Condi็ใo de Pagamento
		Aadd(aCabNFR,{"F1_EMISSAO"  ,STOD(TRE->F1_EMISSAO)       ,Nil})
		Aadd(aCabNFR,{"F1_ESPECIE"  ,"CTE"                       ,Nil})
		Aadd(aCabNFR,{"F1_NATUREZ"  ,TRE->F1_NATUREZ             ,Nil})
		Aadd(aCabNFR,{"F1_TPNOTA"   ,"FRETE"                     ,Nil}) // TIPO DA NOTA NO SAG
		// *********************** FINAL ACABNFR MATA116 - WILLIAM COSTA 17/09/2015 *******************/
		////TCSetConn(_conSAG)
		SqlExcItensFrete(TRE->F1_DOC,TRE->F1_SERIE,TRE->F1_FORNECE,TRE->F1_LOJA)
		While TRF->(!EOF())
			aRecno := {}
			Aadd(aRecno,TRF->R_E_C_N_O_)
			Aadd(aRecno,TRF->F1_CHVNFE)
			Aadd(aRecno,TRE->F1_DOC)
			Aadd(aRecno,TRE->F1_SERIE)
			Aadd(aRecno,TRE->F1_FORNECE)
			Aadd(aRecno,TRE->F1_LOJA)
			Aadd(aRecnos,aRecno)
			// ** INICIO REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
			////TCSetConn(_conProthe)
			cQueryP := " SELECT TOP(1)  D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA "
			cQueryP += "           FROM SD1010 "
			cQueryP += "          WHERE D1_FILIAL   = '" + xFilial("SD1")                + "'"
			cQueryP += "            AND D1_NFRURAL  = '" + STRZERO(VAL(TRF->D1_NFORI),9) + "'"
			cQueryP += "            AND D1_SRRURAL  = '" + TRF->D1_SERIORI               + "'"
			cQueryP += "            AND D1_FORNECE  = '" + TRF->D1_FORNECE               + "'"
			cQueryP += "            AND D1_LOJA     = '" + TRF->D1_LOJA                  + "'"
			cQueryP += "            AND D_E_L_E_T_ <> '*' "
			DbUseArea(.t., "TOPCONN", TcGenQry(,, cQueryP), "TRB", .F., .T.)
			While TRB->(!EOF())
				cPnfOri 	 := TRB->D1_DOC
				cPseriOri 	 := TRB->D1_SERIE
				cPforneceOri := TRB->D1_FORNECE
				cPLojaOri    := TRB->D1_LOJA
				TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())
			////TCSetConn(_conSAG)
			// ** FINAL REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
			If ALLTRIM(cPnfOri) 	 == '' .AND. ;
					ALLTRIM(cPseriOri) 	 == '' .AND. ;
					ALLTRIM(cPforneceOri) == '' .AND. ;
					ALLTRIM(cPLojaOri)    == ''
				aCabNFR[4][2] := TRF->D1_FORNECE
				aCabNFR[5][2] := TRF->D1_LOJA
				Aadd(aItensNFR,{{"",STRZERO(VAL(TRF->D1_NFORI),9)+ALLTRIM(TRF->D1_SERIORI)+SPACE(( TamSX3("F1_SERIE")[1] - LEN(ALLTRIM(TRF->D1_SERIORI)))),nil}})
			Else
				aCabNFR[4][2] := cPforneceOri
				aCabNFR[5][2] := cPLojaOri
				Aadd(aItensNFR,{{"",STRZERO(VAL(cPnfOri),9)+ALLTRIM(cPseriOri)+SPACE(( TamSX3("F1_SERIE")[1] - LEN(ALLTRIM(cPseriOri)))),nil}})
			EndIf
			TRF->(dbSkip())
		ENDDO
		TRF->(dbCloseArea())
		Begin Transaction
			////TCSetConn(_conProthe)
			lMsErroAuto 	:= .F.
			cRemUpd := " UPDATE SF1010 SET F1_CODIGEN = 0 WHERE F1_FILIAL = '" + cFilAnt + "' AND F1_ESPECIE = 'CTE' AND F1_DOC = '" + Alltrim(cValToChar(STRZERO(VAL(TRE->F1_DOC),9))) + "' AND F1_SERIE = '" + Alltrim(cValToChar(TRE->F1_SERIE)) + "' AND F1_FORNECE = '" + Alltrim(cValToChar(TRE->F1_FORNECE)) + "' AND F1_LOJA = '" + Alltrim(cValToChar(TRE->F1_LOJA)) + "' "
			If TcSqlExec(cRemUpd) < 0
				MsgStop("Nใo foi possํvel excluir o CT-e " + Alltrim(cValToChar(TRE->F1_DOC)) + "/" + Alltrim(cValToChar(TRE->F1_SERIE)) + ". Fornecedor " +;
					Alltrim(cValToChar(TRE->F1_FORNECE)) + "-" + Alltrim(cValToChar(TRE->F1_LOJA)) + Chr(10) + Chr(13) + "Nใo efetuou update no campo F1_CODIGEN","Fun็ใo ExcluiFrete")
				cImpEr += "CT-E.: "+ Alltrim(cValToChar(TRE->F1_DOC)) +" Serie.: "+ Alltrim(cValToChar(TRE->F1_SERIE)) + Chr(10) + Chr(13) + cErro + Chr(10) + Chr(13) + Chr(10) + Chr(13)
			Else
				MsExecAuto({|x,y| MATA116(x,y)},aCabNFR,aItensNFR)
				SF1->(dbClearFilter())
			EndIf
		End Transaction //fecha transacao
		If lMsErroAuto == .T. //nใo importou
			If lErroFrete == .F.
				lErroFrete := .T.
			EndIf
			aErroLog := GetAutoGrLog()
			cErro := ""
			For k := 1 to Len(aErroLog)
				//If "INVALIDO" $ UPPER (aErroLog[k])
				cErro += Alltrim(aErroLog[k]) + Chr(13)+Chr(10)
				//EndIf
			Next
			cImpEr += "CT-E.: "+ Alltrim(cValToChar(TRE->F1_DOC)) +" Serie.: "+ Alltrim(cValToChar(TRE->F1_SERIE)) + Chr(10) + Chr(13) + cErro + Chr(10) + Chr(13) + Chr(10) + Chr(13)
			MsgStop("Nใo foi possํvel excluir o CT-e " + Alltrim(cValToChar(TRE->F1_DOC)) + "/" + Alltrim(cValToChar(TRE->F1_SERIE)) + ". Fornecedor " +;
				Alltrim(cValToChar(TRE->F1_FORNECE)) + "-" + Alltrim(cValToChar(TRE->F1_LOJA)) + Chr(10) + Chr(13) + cErro,"Fun็ใo ExcluiFrete")
		Else
			For ncont:=1 to Len (aRecnos)
				If EMPTY(cNotaDe)
					cNotaDe := STRZERO(VAL(aRecnos[ncont][3]),9)+" Serie "+aRecnos[ncont][4]
				EndIf
				cNotaAte := STRZERO(VAL(aRecnos[ncont][3]),9)+" Serie "+aRecnos[ncont][4]
				//				MsgAlert("Geradas Notas processo Frango De.: "+cNotaDe+" Ate -> "+cNotaAte)
				////TCSetConn(_conSAG)
				TcSqlExec("UPDATE SGNFE010 SET D1_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' , MENSAGEM_INT='"+Space(50)+"' , F1_XDOC= '"+ STRZERO(VAL(aRecnos[ncont][3]),9) +"' , STATUS_PRC= 'P'" +" WHERE R_E_C_N_O_="+AllTrim(Str(aRecnos[nCont][1])))
			Next nCont
		EndIF
		//-----------------------|
		//log de registro        |
		//-----------------------|
		////TCSetConn(_conProthe)
		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
		Replace ZBE_DATA 	   	WITH Date()
		Replace ZBE_HORA 	   	WITH TIME()
		Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
		Replace ZBE_LOG	        WITH ("INTEGRACAO " + Alltrim(dDataBase) + " CTE : " + TRE->F1_DOC + " SERIE : " + TRE->F1_SERIE + " FORNECEDOR: "  + TRE->F1_FORNECE + " LOJA: " + TRE->F1_LOJA)
		Replace ZBE_MODULO	    WITH "COMP-ECTE"
		Replace ZBE_ROTINA	    WITH "INTNFEB"
		TRE->(dbSkip())
	ENDDO
	TRE->(dbCloseArea())
	If lErroFrete == .F.
		cMensagem += "Excluidas Notas Fiscais De.: "+cNotaDe+" a Ate -> "+cNotaAte + CRLF + CRLF
	EndIf
Return Nil
Static Function SqlExcCabFrete()
	cQueryFrete := "SELECT F1_DOC, "
	cQueryFrete += "       F1_SERIE, "
	cQueryFrete += "       F1_FORNECE, "
	cQueryFrete += "       F1_LOJA, "
	cQueryFrete += "       D1_TES, "
	cQueryFrete += "       D1_TOTAL, "
	cQueryFrete += "       F1_FORMUL, "
	cQueryFrete += "       NOMECOND, "
	cQueryFrete += "       F1_COND, "
	cQueryFrete += "       F1_NATUREZ, "
	cQueryFrete += "       F1_EMISSAO, ORIGRURAL "
	cQueryFrete += "  FROM SGNFE010 "
	cQueryFrete += " WHERE ((D1_MSEXP    = ' ' "
	cQueryFrete += "    OR (D1_MSEXP    <> ' ' "
	cQueryFrete += "   AND STATUS_INT    = 'E' )) "
	cQueryFrete += "   AND F1_FILIAL     = '" +cFilAnt+ "' ) "
	cQueryFrete += "   AND TABEGENE      = 'POCAMVNE' "
	cQueryFrete += "   AND D1_TIPO       = 'F' "
	If lAltFrete == .T.
		cQueryFrete += "   AND (OPERACAO_INT = 'E' "
		cQueryFrete += "    OR OPERACAO_INT  = 'A') "
	Else
		cQueryFrete += "   AND OPERACAO_INT = 'E' "
	EndIf
	cQueryFrete += "   AND F1_EMISSAO   <= '" +DTOS(DDATABASE)+ "' "
	cQueryFrete += "   AND F1_DTDIGIT   = '" +DTOS(DDATABASE)+ "' "
	If lAltFrete == .T.
		cQueryFrete += "   AND F1_DOC        = '"+TRC->F1_DOC+ "' "
		cQueryFrete += "   AND F1_SERIE      = '"+TRC->F1_SERIE+ "' "
		cQueryFrete += "   AND F1_FORNECE    = '"+TRC->F1_FORNECE+ "' "
		cQueryFrete += "   AND F1_LOJA       = '"+TRC->F1_LOJA+ "' "
	EndIf
	cQueryFrete += " GROUP BY F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_TES,D1_TOTAL,F1_FORMUL,NOMECOND,F1_COND,F1_NATUREZ,F1_EMISSAO, ORIGRURAL "
	cQueryFrete += " ORDER BY F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_TES,D1_TOTAL,F1_FORMUL,NOMECOND,F1_COND,F1_NATUREZ,F1_EMISSAO, ORIGRURAL "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryFrete), "TRE", .F., .T.)
Return Nil
Static Function SqlExcItensFrete(cF1_DOC,cF1_SERIE,cF1_FORNECE,cF1_LOJA)
	cQueryFrete := "SELECT D1_NFORI, "
	cQueryFrete += "       D1_SERIORI, "
	cQueryFrete += "       D1_FORNECE, "
	cQueryFrete += "       D1_LOJA, "
	cQueryFrete += "       R_E_C_N_O_, "
	cQueryFrete += "       F1_CHVNFE, ORIGRURAL "
	cQueryFrete += "   FROM SGNFE010 "
	cQueryFrete += " WHERE ((D1_MSEXP    =' ' "
	cQueryFrete += "    OR (D1_MSEXP    <> ' ' "
	cQueryFrete += "   AND STATUS_INT    = 'E' )) "
	cQueryFrete += "   AND F1_FILIAL     = '"+cFilAnt+ "' ) "
	cQueryFrete += "   AND TABEGENE      = 'POCAMVNE' "
	cQueryFrete += "   AND F1_EMISSAO   <= '"+DTOS(DDATABASE)+ "' "
	cQueryFrete += "   AND F1_DTDIGIT   = '" +DTOS(DDATABASE)+ "' "
	cQueryFrete += "   AND D1_TIPO       = 'F' "
	If lAltFrete == .T.
		cQueryFrete += "   AND (OPERACAO_INT = 'E' "
		cQueryFrete += "    OR OPERACAO_INT  = 'A') "
	Else
		cQueryFrete += "   AND OPERACAO_INT = 'E' "
	EndIf
	cQueryFrete += "   AND F1_DOC        = '"+cF1_DOC+ "' "
	cQueryFrete += "   AND F1_SERIE      = '"+cF1_SERIE+ "' "
	cQueryFrete += "   AND F1_FORNECE    = '"+cF1_FORNECE+ "' "
	cQueryFrete += "   AND F1_LOJA       = '"+cF1_LOJA+ "' "
	cQueryFrete += " ORDER BY F1_FILIAL,CODIGENE,R_E_C_N_O_ , D1_TRANSIT "
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQueryFrete), "TRF", .F., .T.)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocDtCTE        บ Autor ณ Everson   บ Data ณ  10/08/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAjusta a data de lan็amentos dos CT-e's pendentes de         ฑฑ
ฑฑ           ณimporta็ใo de acordo com a data da nota de origem.           ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033511.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procDtCTE()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aCTEInteg	:= {}
	Local cSeriOri	:= ""
	//Altera conexใo para o banco integra็ใo.
	////TCSetConn(_conSAG)
	cQuery := " SELECT * FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt + "' AND D1_TIPO = 'F' AND F1_ESPECIE = 'CTE' ) AND TABEGENE LIKE 'POCAMVNE' ORDER BY F1_FILIAL,CODIGENE,R_E_C_N_O_ , D1_TRANSIT "
	//
	If Select("DT_CTE") > 0
		DT_CTE->(DbCloseArea())
	EndIf
	MsAguarde({|| DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "DT_CTE", .T., .F.) },"Aguarde","Consultando banco integra็ใo...")
	DbSelectArea("DT_CTE")
	DT_CTE->(DbGoTop())
	If DT_CTE->(Eof())
		//Altera conexใo para o banco Protheus.
		////TCSetConn(_conProthe)
		RestArea(aArea)
		Return Nil
	EndIf
	//
	While ! DT_CTE->(Eof())
		cSeriOri := Alltrim(cValToChar(DT_CTE->D1_SERIORI))
		If Alltrim(cValToChar(DT_CTE->D1_FORNECE)) $cInsSer
			cSeriOri := Padl(cSeriOri,2,"0")
		EndIf
		Aadd(aCTEInteg,{;
			DT_CTE->F1_FILIAL,;
			DT_CTE->F1_DOC,;
			DT_CTE->F1_SERIE,;
			DT_CTE->F1_FORNECE,;
			DT_CTE->F1_LOJA,;
			DT_CTE->D1_FORNECE,;
			DT_CTE->D1_LOJA,;
			Padl(Alltrim(cValToChar(DT_CTE->D1_NFORI)),9,"0"),;
			cSeriOri,;
			DT_CTE->F1_DTDIGIT,;
			DT_CTE->ORIGRURAL;
			})
		DT_CTE->(DbSkip())
	EndDo
	//
	If Len(aCTEInteg) > 0
		Processa({|| ajtDtCTE(aCTEInteg) },"Aguarde","Ajustando datas de lan็amentos de CT-e's...")
	Else
		MsgStop("Ocorreu um erro ao obter os CT-e's para ajuste da data de lan็amento.","Fun็ใo procDtCTE")
	EndIf
	//Altera conexใo para o banco Protheus.
	////TCSetConn(_conProthe)
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณajtDtCTE          บ Autor ณ Everson   บ Data ณ  10/08/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณProcessa registros para ajuste a data de lan็amentos dos CT-eฑฑ
ฑฑ           ณpendentes deimporta็ใo de acordo com a data da nota do mesmo.ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033511.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ajtDtCTE(aCTEInteg)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local i 		:= 1
	Local cQuery	:= ""
	Local cCTENNFOr	  := "CT-e's sem notas de origem localizadas no Protheus " + Chr(13) + Chr(10) + Chr(13) + Chr(10)
	Private cCTEAjust := ""
	//
	ProcRegua(Len(aCTEInteg))
	For i := 1 To Len(aCTEInteg)
		//Altera conexใo para o banco Protheus.
		////TCSetConn(_conProthe)
		IncProc("CT-e | " + Alltrim(cValToChar(aCTEInteg[i][2])) + "/" + Alltrim(cValToChar(aCTEInteg[i][3])) )
		If Alltrim(cValToChar(aCTEInteg[i][11])) == "S"
			cQuery := " SELECT TOP 1 F1_DTDIGIT "
			cQuery += "   FROM SF1010, SD1010    "
			cQuery += "  WHERE F1_FILIAL          = '" + xFilial("SF1")                + "'"
			cQuery += "    AND D1_NFRURAL         = '" + Alltrim(cValToChar(aCTEInteg[i][8])) + "'"
			cQuery += "    AND D1_SRRURAL         = '" + Alltrim(cValToChar(aCTEInteg[i][9])) + "'"
			cQuery += "    AND F1_FORNECE         = '" + Alltrim(cValToChar(aCTEInteg[i][6])) + "'"
			cQuery += "    AND F1_LOJA            = '" + Alltrim(cValToChar(aCTEInteg[i][7])) + "'"
			cQuery += "    AND SF1010.D_E_L_E_T_ <> '*' "
			cQuery += "    AND D1_FILIAL          = F1_FILIAL "
			cQuery += "    AND D1_DOC             = F1_DOC "
			cQuery += "    AND D1_SERIE           = F1_SERIE "
			cQuery += "    AND D1_FORNECE         = F1_FORNECE "
			cQuery += "    AND D1_LOJA            = F1_LOJA  "
			cQuery += "    AND SD1010.D_E_L_E_T_ <> '*'  "
		Else
			cQuery := " SELECT "
			cQuery += " F1_DTDIGIT "
			cQuery += " FROM " + RetSqlName("SF1") + " AS SF1 "
			cQuery += " WHERE "
			cQuery += " SF1.D_E_L_E_T_ = '' "
			cQuery += " AND F1_FILIAL = '"  + cFilAnt + "' "
			cQuery += " AND F1_FORNECE = '" + Alltrim(cValToChar(aCTEInteg[i][6])) + "' "
			cQuery += " AND F1_LOJA = '"    + Alltrim(cValToChar(aCTEInteg[i][7])) + "' "
			cQuery += " AND F1_DOC = '"     + Alltrim(cValToChar(aCTEInteg[i][8])) + "' "
			cQuery += " AND F1_SERIE = '"   + Alltrim(cValToChar(aCTEInteg[i][9])) + "' "
			cQuery += " AND F1_ESPECIE = 'SPED'"
		EndIf
		//
		If Select("CON_SF1") > 0
			CON_SF1->(DbCloseArea())
		EndIf
		//
		TcQuery cQuery New Alias "CON_SF1"
		DbSelectArea("CON_SF1")
		CON_SF1->(DbGoTop())
		If ! CON_SF1->(Eof())
			If ! Empty(Alltrim(cValToChar(CON_SF1->F1_DTDIGIT))) .And. (Alltrim(cValToChar(CON_SF1->F1_DTDIGIT)) <> Alltrim(cValToChar(aCTEInteg[i][10]))) .And. (Alltrim(cValToChar(CON_SF1->F1_DTDIGIT)) >= Alltrim(cValToChar(aCTEInteg[i][10])))
				cCte	:= Alltrim(cValToChar(aCTEInteg[i][2]))
				cSerie	:= Alltrim(cValToChar(aCTEInteg[i][3]))
				cForne	:= Alltrim(cValToChar(aCTEInteg[i][4]))
				cLoja	:= Alltrim(cValToChar(aCTEInteg[i][5]))
				cDtAnt	:= Alltrim(cValToChar(aCTEInteg[i][10]))
				cDtPos	:= Alltrim(cValToChar(CON_SF1->F1_DTDIGIT))
				updDtCTE(cCte,cSerie,cForne,cLoja,cDtAnt,cDtPos)
			EndIf
		Else
			cCTENNFOr += "CT-e " + Alltrim(cValToChar(aCTEInteg[i][2]))  + "/" + Alltrim(cValToChar(aCTEInteg[i][3])) + Chr(13) + Chr(10)
		EndIf
		CON_SF1->(DbCloseArea())
	Next i
	//Altera conexใo para o banco Protheus.
	////TCSetConn(_conProthe)
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณupdDtCTE          บ Autor ณ Everson   บ Data ณ  10/08/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณUpdate registros para ajuste a data de lan็amentos dos CT-e  ฑฑ
ฑฑ           ณpendentes deimporta็ใo de acordo com a data da nota do mesmo.ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033511.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function updDtCTE(cCte,cSerie,cForne,cLoja,cDtAnt,cDtPos)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local Pula		:= Chr(13) + Chr(10)
	Local cUpdate	:= ""
	//
	cCte	:= Alltrim(cValToChar(cCte))
	cSerie	:= Alltrim(cValToChar(cSerie))
	cForne	:= Alltrim(cValToChar(cForne))
	cLoja	:= Alltrim(cValToChar(cLoja))
	cDtAnt	:= Alltrim(cValToChar(cDtAnt))
	cDtPos	:= Alltrim(cValToChar(cDtPos))
	//Altera conexใo para o banco integra็ใo.
	////TCSetConn(_conSAG)
	cUpdate := " UPDATE SGNFE010 SET F1_DTDIGIT = '" + cDtPos + "' WHERE F1_FILIAL = '" + cFilAnt + "' AND F1_ESPECIE = 'CTE' AND F1_DOC = '" + cCte + "' AND F1_SERIE = '" + cSerie + "' AND F1_FORNECE = '" + cForne + "' AND F1_LOJA = '" + cLoja + "' AND F1_DTDIGIT = '" + cDtAnt + "' "
	//
	If TcSqlExec(cUpdate) < 0
		MsgStop("Nใo foi possํvel atualizar a data do CT-e " + cCte + "/" + cSerie + " - For: " + cForne + "/" + cLoja + ".","Fun็ใo updDtCTE")
	Else
		cCTEAjust += "CT-e " + cCte + "/" + cSerie + " - For: " + cForne + "/" + cLoja + " - DtAnt: " + DToC(SToD(cDtAnt)) + " DTPos: " + DToC(SToD(cDtPos)) + Pula
	EndIf
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlngPedImp()  	   บ Autor ณ Everson     บ Data ณ  11/08/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Legenda de pedidos.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033511.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lngPedImp()
	Local cTitulo := "Status pedido"
	Local aLegenda:= {}
	Aadd(aLegenda, {"BR_VERDE"    		,"Entrada por compra"					})
	Aadd(aLegenda, {"BR_VERMELHO" 		,"Entrada por devolu็ใo"				})
	Aadd(aLegenda, {"BR_AMARELO"  		,"Entrada por transfer๊ncia filial" 	})
	Aadd(aLegenda, {"BR_MARRON_OCEAN" 	,"Notas de servi็o"						})
	Aadd(aLegenda, {"BR_AZUL"     		,"Entrada por transfer๊ncia integrado"	})
	Aadd(aLegenda, {"BR_LARANJA"  		,"Entrada frango vivo apanha" 			})
	Aadd(aLegenda, {"BR_BRANCO"   		,"Frango 1 retorno de cria็ใo" 			})
	Aadd(aLegenda, {"BR_PRETO"    		,"Frango 2 retorno simb๓lico cria็ใo"	})
	Aadd(aLegenda, {"BR_PINK"     		,"Frango 4 compra frango vivo" 			})
	Aadd(aLegenda, {"BR_VIOLETA"  		,"Produtor rural" 						})
	Aadd(aLegenda, {"BR_CINZA"    		,"Nota de frete" 						})
	Aadd(aLegenda, {"BR_VERDE_ESCURO"  	,"Exclusใo nota de frete" 				})
	BrwLegenda("Legenda do Browse",cTitulo,aLegenda)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLFVClass  บAutor  ณFernando Macieira   บ Data ณ  05/07/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classificacao Complemento Frango Vivo                      บฑฑ
ฑฑบ          ณ Chamado 037757                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LFVClass()
	Local aArea			:= GetArea()
	Local oInterface
	Local oSBtn01
	Local oSBtn02
	Local oSBtn03
	Local oSBtn04
	Local oGroupTot
	Local oGroup1
	Local oFontDtBs 	:= TFont():New(,,-15,.T.)
	Local oTxtBusca
	Local cSelBusca		:= ""
	Local oSelBusca
	Local aSelBusca		:= {}
	Local oBusca
	Local oBtnBusca
	Local oCSV
	Private cMails  := GetMV("MV_#LFVMA2",,"danielle.meira@adoro.com.br") // -------- VOLTAR ESTA LINHA ANTES DE PUBLICAR EM PRD
	Private cDescri := "CLASSIFICAวรO NFE - COMPLEMENTO FRANGO VIVO"
	aFiltro := {}
	Aadd(aFiltro,"1=Complemento Frango Vivo")
//Cria objeto MsDialog.
	oInterface:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Classifica็ใo - Complemento Frango Vivo"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1100
	oInterface:nHeight   := 460
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
//
	oDtBase := TSay():New(005,004,{|| "Data base: " + cDtBase },oInterface,,oFontDtBs,,,,.T.,CLR_RED,CLR_WHITE,200,20)
//Cria Header.
	Aadd(aHInterface,{" ","LEG"    	  ,"@BMP"    ,01     			     , 00,.T.,"","","","R","","",.F.,"V","","","",""})
	Aadd(aHInterface,{"Filial"        ,"FILIAL"	 ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Tipo"          ,"TIPO"	 ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Esp้cie"       ,"ESPEC"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Num Doc"       ,"DOCSG"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"S้rie"         ,"SERIE"	 ,""	 				 , 03,0,"","" ,"C","",""})
	Aadd(aHInterface,{"DT Emissใo"    ,"DTEMIS"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"DT Lan็amento" ,"DTALNC"	 ,""	 				 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Fornecedor"    ,"FORN"    ,""	 				 , 06,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Loja"          ,"LOJ"     ,""	 				 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Produto"       ,"PROD"    ,""	 				 , 12,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Qtd"           ,"QTD"     ,"@E 999,999,999.999"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Vl Unit"       ,"VLRUNT"  ,"@E 999,999,999.999"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Valor"         ,"VLR"     ,"@E 999,999,999.99"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"ChaveNF"       ,"CHAVENF" ,""	 			  	 , 50,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Tes"       	  ,"TES"     ,""	 				 , 05,0,"","" ,"C","",""})
//Cria objeto MsNewGetDados(Grid).
	oRegistros := MsNewGetDados():New(025,004,165,545,,"Allwaystrue()","Allwaystrue()","",aAltInterface,Nil,999,Nil,Nil,Nil,oInterface,aHInterface,@aColsInterface)
//
	oCSV := TButton():New(170,009,"CSV",oInterface,,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oCSV:bAction := {||MsAguarde({||;
		grLRCCSV(oRegistros,aHInterface,"ntentrada_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV");
		},"Aguarde","Exportando CSV...") }
//
	oGroupTot := TGroup():Create(oInterface,162,433,185,545,"",,,.T.)
	oGroupTot:SetCss("QGroupBox{background-color: #F5F5F5}")
//
	oQtdReg := TGet():New(170,438, { | u | If( PCount() == 0, nQtdReg, nQtdReg := u ) },oInterface, ;
		060, 010, "@E 999,999,999",, 0, 16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdReg",,,,.F.,,,"Total de registros:",2,,CLR_RED)
//
	oGroup1 := TGroup():Create(oInterface,190,004,210,545,"",,,.T.)
	oGroup1:SetCss("QGroupBox{background-color: #F5F5F5}")
// Classificacao
	oSBtn01:= SButton():Create(oInterface)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "Classificar"
	oSBtn01:nLeft := 014
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
//oSBtn01:bAction := {|| u_ExecAu103() }
	oSBtn01:bAction := {|| RunLFVClass() }
//Cria para recarregar dados.
	oSBtn02:= SButton():Create(oInterface)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Atualizar"
	oSBtn02:nLeft := 899
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 80
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {|| LFVPreNotas() }
//Cria botใo de confirma็ใo.
	oSBtn03:= SButton():Create(oInterface)
	oSBtn03:cName := "oSBtn03"
	oSBtn03:cCaption := "Legenda"
	oSBtn03:nLeft := 966
	oSBtn03:nTop := 390
	oSBtn03:nWidth := 50
	oSBtn03:nHeight := 20
	oSBtn03:lShowHint := .F.
	oSBtn03:lReadOnly := .F.
	oSBtn03:Align := 0
	oSBtn03:bAction := {||LFVLegenda()}
//Cria botใo de cancelamento.
	oSBtn04:= SButton():Create(oInterface)
	oSBtn04:cName := "oSBtn04"
	oSBtn04:cCaption := "Fechar"
	oSBtn04:nLeft := 1031
	oSBtn04:nTop := 390
	oSBtn04:nWidth := 50
	oSBtn04:nHeight := 20
	oSBtn04:lShowHint := .F.
	oSBtn04:lReadOnly := .F.
	oSBtn04:Align := 0
	oSBtn04:lVisibleControl := .T.
	oSBtn04:bAction := {||oInterface:End()}
	oSBtn04:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")
//
	oInterface:Activate(,,,.T.,{||.T.},,{|| LFVPreNotas() })
//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTNFEB   บAutor  ณMicrosiga           บ Data ณ  05/07/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LFVPreNotas(lClass)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aCTEInteg	:= {}
	Local cSeriOri	:= ""
	Local i			:= 1
	Local cQuery	:= ""
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local cOper		:= ""
	Local cFilPV  := GetMV("MV_#LFVFIL",,"03")
	Local cFilPre   := GetMV("MV_#LFVPRE",,"02")
	Local cTESPre   := GetMV("MV_#LFVTEE",,"031")
	Local cCliCod := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj := GetMV("MV_#LFVLOJ",,"00")
// Dados da Pre-Nota
	Local cFilPre   := GetMV("MV_#LFVPRE",,"02")
	Local cFornCod  := GetMV("MV_#LFVFOR",,"000217")
	Local cLojaCod  := GetMV("MV_#LFVLOJ",,"01")
	Local cCC       := GetMV("MV_#LFVCC" ,,"9999")
	Local cCtaCtb   := GetMV("MV_#LFVCTA",,"111520005")
	Local cItemCtb  := GetMV("MV_#LFVITC",,"121")
	Local cLocal    := GetMV("MV_#LFVALM",,"16")
	Local cEspLFV   := GetMV("MV_#LFVESP",,"SPED")
	Local cProduto  := GetMV("MV_#LFVPRD",,"300042")  //  publicar este em producao
	Default lClass := .f.
	nOpcImp := Val(Alltrim(cValToChar(nOpcImp)))
	oRegistros:aCols := {}
	oRegistros:Refresh()
	nQtdReg := 0
	oQtdReg:Refresh()
	cQuery := " SELECT D1_FILIAL, D1_TIPO, F1_ESPECIE, D1_DOC, D1_SERIE, D1_EMISSAO, D1_DTDIGIT, D1_FORNECE, D1_LOJA, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_TES, F1_CHVNFE "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF1") + " SF1 "
	cQuery += " WHERE F1_FILIAL=D1_FILIAL "
	cQuery += " AND F1_DOC=D1_DOC "
	cQuery += " AND F1_SERIE=D1_SERIE "
	cQuery += " AND F1_FORNECE=D1_FORNECE "
	cQuery += " AND F1_LOJA=D1_LOJA "
	cQuery += " AND F1_TIPO=D1_TIPO "
	cQuery += " AND D1_FILIAL='"+cFilPre+"' "
	cQuery += " AND D1_FORNECE='"+cFornCod+"' "
	cQuery += " AND D1_LOJA='"+cLojaCod+"' "
	cQuery += " AND D1_COD='"+cProduto+"' "
	If lClass
		cQuery += " AND D1_TES='"+cTESPre+"' "
		cQuery += " AND F1_CHVNFE<>'' "
	Else
		cQuery += " AND D1_TES='' "
	EndIf
	cQuery += " AND SD1.D_E_L_E_T_='' "
	cQuery += " AND SF1.D_E_L_E_T_='' "
	cQuery += " ORDER BY D1_DOC, D1_SERIE DESC "
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	tcQuery cQuery New Alias "Work"
	aTamSX3 := TamSX3("D1_DTDIGIT")
	tcSetField("Work", "D1_DTDIGIT", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	aTamSX3 := TamSX3("D1_EMISSAO")
	tcSetField("Work", "D1_EMISSAO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	aTamSX3 := TamSX3("D1_QUANT")
	tcSetField("Work", "D1_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	aTamSX3 := TamSX3("D1_VUNIT")
	tcSetField("Work", "D1_VUNIT", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	aTamSX3 := TamSX3("D1_TOTAL")
	tcSetField("Work", "D1_TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])
//////
	If Work->( EOF() )
		Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
		oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FILIAL"    })] 	:= ""
	EndIf
	//
	Do While !Work->( EOF() )
		cC5_XLFVCMP := ""
		cChvNFe     := ""
		SD2->( dbSetOrder(3) ) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If SD2->( dbSeek(cFilPV + Work->D1_DOC + PadR(Work->D1_SERIE,TamSX3("D2_SERIE")[1]) + cCliCod + cCliLoj) )
			SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
			If SC5->( dbSeek(cFilPV+SD2->D2_PEDIDO) )
				cC5_XLFVCMP := SC5->C5_XLFVCMP
			EndIf
		EndIf
		// Pedido de Complemento de Frango Vivo
		If AllTrim(cC5_XLFVCMP) == "S"
			SF2->( dbSetOrder(1) ) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->( dbSeek(cFilPV + Work->D1_DOC + PadR(Work->D1_SERIE,TamSX3("F2_SERIE")[1]) + cCliCod + cCliLoj) )
				cChvNFe := SF2->F2_CHVNFE
				If !Empty(cChvNFe)
					Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
					oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FILIAL"  })] 	:= Alltrim(cValToChar(Work->D1_FILIAL))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TIPO"    })] 	:= Alltrim(cValToChar(Work->D1_TIPO))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ESPEC"    })] 	:= Work->F1_ESPECIE
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DOCSG"   })] 	:= Alltrim(cValToChar(Work->D1_DOC))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SERIE"   })] 	:= Alltrim(cValToChar(Work->D1_SERIE))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"  })] 	:= Work->D1_EMISSAO
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTALNC"  })] 	:= Work->D1_DTDIGIT
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FORN"    })] 	:= Alltrim(cValToChar(Work->D1_FORNECE))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"     })] 	:= Alltrim(cValToChar(Work->D1_LOJA))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PROD"    })] 	:= Alltrim(cValToChar(Work->D1_COD))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"     })] 	:= Val(cValToChar(Work->D1_QUANT))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLRUNT"  })] 	:= Val(cValToChar(Work->D1_VUNIT))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"     })] 	:= Val(cValToChar(Work->D1_TOTAL))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CHAVENF" })] 	:= Alltrim(cValToChar(Work->F1_CHVNFE))
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TES"     })] 	:= Alltrim(cValToChar(Work->D1_TES))
					If !Empty(Work->D1_TES)
						oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVerde
					Else
						oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVermelho
					EndIf
					nQtdReg++
				EndIf
			EndIf
		EndIf
		Work->(DbSkip())
	EndDo
	Work->(DbCloseArea())
	//
	oRegistros:Refresh()
	oQtdReg:Refresh()
	//
	RestArea(aArea)
//////
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTNFEB   บAutor  ณMicrosiga           บ Data ณ  05/07/18   บฑฑ                                                                      
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LFVLegenda()
	Local cTitulo := "Legenda - Complemento Frango Vivo"
	Local aLegenda:= {}
	Aadd(aLegenda, {"BR_VERDE"    		,"Classificada"			})
	Aadd(aLegenda, {"BR_VERMELHO" 		,"Pr้-Nota"     		})
	BrwLegenda("Legenda do Browse",cTitulo,aLegenda)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTNFEB   บAutor  ณFernando Macieira   บ Data ณ  05/07/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classificacao da NF de Complemento do Frango Vivo          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RunLFVClass()
	Local i
	Local aAreaAtu := GetArea()
	Local cFilPre   := GetMV("MV_#LFVPRE",,"02")
	Local cTESPre   := GetMV("MV_#LFVTEE",,"031")
	Local cFilPV  := GetMV("MV_#LFVFIL",,"03")
	Local cCliCod := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj := GetMV("MV_#LFVLOJ",,"00")
	Local cChvNfe := ""
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	Local aColsCC := {}
	Local aCodRet := {}
	Local nX := 0
	Local nY := 0
	Local cDoc := ""
	Local lOk := .T.
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	For i:=1 to Len(oRegistros:aCols)
		If Empty(oRegistros:aCols[i][16])
			// Busco dados da NF de SAIDA
			//		cChvNFe := Posicione("SF2", 1, cFilPV + oRegistros:aCols[i][5] + PadR(oRegistros:aCols[i][6],TamSX3("F2_SERIE")[1]) + cCliCod + cCliLoj, "F2_CHVNFE")
			SF2->( dbSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->( dbSeek(cFilPV + oRegistros:aCols[i][5] + PadR(oRegistros:aCols[i][6],TamSX3("F2_SERIE")[1]) + cCliCod + cCliLoj) )
				cChvNFe  := SF2->F2_CHVNFE
				dDtClass := SF2->F2_EMISSAO
			Else
				cChvNFe  := ""
				dDtClass := CtoD("  /  /  ")
			EndIf
			If !Empty(cChvNfe) .and. !Empty(dDtClass)
				// Posiciono na NF a classificar
				SF1->( dbSetOrder(1) )  // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
				SF1->( dbSeek(oRegistros:aCols[i][2] + oRegistros:aCols[i][5] + PadR(oRegistros:aCols[i][6],TamSX3("D1_SERIE")[1]) + oRegistros:aCols[i][9] + oRegistros:aCols[i][10] + "N") )
				SD1->( dbSetOrder(1) )  // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				SD1->( dbSeek(oRegistros:aCols[i][2] + oRegistros:aCols[i][5] + PadR(oRegistros:aCols[i][6],TamSX3("D1_SERIE")[1]) + oRegistros:aCols[i][9] + oRegistros:aCols[i][10] + oRegistros:aCols[i][11]) )
				//ExpA1 - Array contendo os dados do cabe็alho da Nota Fiscal de Entrada.
				Aadd(aCabec,{"F1_TIPO" , SF1->F1_TIPO , Nil})
				Aadd(aCabec,{"F1_FORMUL" , SF1->F1_FORMUL , Nil})
				Aadd(aCabec,{"F1_DOC" , SF1->F1_DOC , Nil})
				Aadd(aCabec,{"F1_SERIE" , SF1->F1_SERIE , Nil})
				Aadd(aCabec,{"F1_FORNECE" , SF1->F1_FORNECE , Nil})
				Aadd(aCabec,{"F1_LOJA" , SF1->F1_LOJA, Nil})
				Aadd(aCabec,{"F1_ESPECIE" , SF1->F1_ESPECIE , Nil})
				Aadd(aCabec,{"F1_CHVNFE", cChvNfe		 , Nil})
				Aadd(aCabec,{"F1_COND" , SF1->F1_COND , Nil})
				Aadd(aCabec,{"F1_MOEDA" , 1 , Nil})
				Aadd(aCabec,{"F1_TXMOEDA" , 1 , Nil})
				Aadd(aCabec,{"F1_STATUS" , "A" , Nil})
				Aadd(aCabec,{"F1_DTDIGIT" , dDtClass , Nil}) // Chamado 043071 (Classificar na data da NF de Saํda) - FWNM - 21/08/2018
				//ExpA2- Array contendo os itens da Nota Fiscal de Entrada.
				aLinha := {}
				Aadd(aLinha,{"D1_DTDIGIT" , dDtClass   , Nil}) // Chamado 043071 (Classificar na data da NF de Saํda) - FWNM - 21/08/2018
				Aadd(aLinha,{"D1_COD"     , SD1->D1_COD   , Nil})
				Aadd(aLinha,{"D1_TES"     , cTesPre       , Nil})
				Aadd(aLinha,{"D1_CC" 	  ,SD1->D1_CC     ,NIL})
				Aadd(aLinha,{"D1_CONTA"   ,SD1->D1_CONTA  ,NIL})
				Aadd(aLinha,{"D1_ITEMCTA" ,SD1->D1_ITEMCTA,NIL})
				Aadd(aLinha,{"AUTDELETA" , "N" , Nil}) // Incluir sempre no ๚ltimo elemento do array de cada item
				Aadd(aItens,aLinha)
				//ExpA6 - Array contendo os dados do rateio por centro de custo
				//ExpA7 - Array contendo a informa็ใo se gera DIRF e os c๓digos de reten็ใo por imposto
				Aadd( aCodRet, {01, "0297", 1, "..."} )
				Aadd( aCodRet, {02, "0297", 1, "IRR"} )
				Aadd( aCodRet, {03, "5979", 1, "PIS"} )
				Aadd( aCodRet, {04, "5960", 1, "COF"} )
				Aadd( aCodRet, {05, "5987", 1, "CSL"} )
				Begin Transaction
					// Bkp filial setada
					cFilBkp := cFilAnt
					// Mudo filial para codigo onde NF de entrada se encontra
					cFilAnt  := cFilPre
					// Classifica็ใo
					dBkpDtBs := dDataBase // Chamado 043071 (Classificar na data da NF de Saํda) - FWNM - 21/08/2018
					dDataBase := dDtClass // Chamado 043071 (Classificar na data da NF de Saํda) - FWNM - 21/08/2018
					MsAguarde({|| MATA103(aCabec,aItens,4,,,,,aColsCC,,,aCodRet) },"Aguarde","Classificando NF n. " + SD1->D1_DOC + "/" + SD1->D1_SERIE)
					//	MsAguarde({|| msExecAuto({|x,y,z| MATA103(x,y,z)}, _aCabec, _aItens, 4) },"Aguarde","Classificando NF n. " + SD1->D1_DOC + "/" + SD1->D1_SERIE)
					dDataBase := dBkpDtBs // Chamado 043071 (Classificar na data da NF de Saํda) - FWNM - 21/08/2018
					If lMsErroAuto
					/*
					Aviso("INTNFEB-01", "Serแ necessแrio CLASSIFICAR manualmente a Pr้-Nota de Complemento de Frango Vivo..." + chr(10) + chr(13) +;
					"Verifique os CADASTROS... " + chr(10) + chr(13) + chr(10) + chr(13) +;
					"Abaixo, dados da Pr้-Nota que NรO foi classificada: " + chr(10) + chr(13) +;
					"Filial: " + SD1->D1_FILIAL + chr(10) + chr(13) +;
					"N๚mero: " + SD1->D1_DOC  + chr(10) + chr(13) +;
					"S้rie: " + SD1->D1_SERIE + chr(10) + chr(13) +;
					"Fornecedor: " + SD1->D1_FORNECE + "/" + SD1->D1_LOJA + chr(10) + chr(13) +;
					"Fantasia: " + Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NREDUZ"), {"&Ok"}, 3, "Pr้-Nota de Entrada NรO foi CLASSIFICADA! Cadastros inconsistentes!")
					*/
						msgInfo("Pr้-Nota n. " + SD1->D1_DOC + "/" + SD1->D1_SERIE + " NรO FOI CLASSIFICADA!")
						ConOut("ERRO NA INCLUSAO! " + SD1->D1_DOC + "/" + SD1->D1_SERIE)
						MostraErro()
					Else
					/*
					Aviso("INTNFEB-02", "Pr้-Nota de Complemento de Frango Vivo CLASSIFICADA" + chr(10) + chr(13) + chr(10) + chr(13) +;
					"Abaixo, dados da Pr้-Nota classificada: " + chr(10) + chr(13) +;
					"Filial: " + SD1->D1_FILIAL + chr(10) + chr(13) +;
					"N๚mero: " + SD1->D1_DOC  + chr(10) + chr(13) +;
					"S้rie: " + SD1->D1_SERIE + chr(10) + chr(13) +;
					"TES: " + SD1->D1_TES + chr(10) + chr(13) +;
					"Fornecedor: " + SD1->D1_FORNECE + "/" + SD1->D1_LOJA + chr(10) + chr(13) +;
					"Fantasia: " + Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NREDUZ"), {"&Ok"}, 3, "Pr้-Nota Complemento Frango Vivo CLASSIFICADA com Sucesso!")
					*/
						ConOut("Incluido com sucesso! " + SD1->D1_DOC + "/" + SD1->D1_SERIE)
						msgInfo("Pr้-Nota n. " + SD1->D1_DOC + "/" + SD1->D1_SERIE + " classificada com sucesso!")
						// Enviar email
						EmailFVL()
					EndIf
					// Restauro filial corrente
					cFilAnt := cFilBkp
				End Transaction
			EndIf
		EndIf
	Next i
	RestArea(aAreaAtu)
	LFVPreNotas()
//	LFVPreNotas(.t.)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADLFV010P บAutor  ณFernando Macieira   บ Data ณ  04/18/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia email com dados do PV Complemento Frango Vivo        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EmailFVL()
	LogZBN("1")
	ProcRel()
	LogZBN("2")
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogZBN       บAutor  ณFernando Sigoli บData ณ  29/03/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera log na ZBN.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso: Adoro S/A                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logZBN(cStatus)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	Local cNomeRotina := "INTNFEB"
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
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocRel        บAutor  ณFernando Sigoli บData ณ  29/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera relat๓rio.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro S/A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procRel()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cAssunto	:= cDescri
	Local cMensagem	:= ""
	Local cQuery	:= ""
	//
	cQuery := _ScriptSQL()
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
	cMensagem += '<td>Nota Fiscal</td>'
	cMensagem += '<td>S้rie</td>'
	cMensagem += '<td>Esp้cie</td>'
	cMensagem += '<td>Fornecedor</td>'
	cMensagem += '<td>Loja</td>'
	cMensagem += '<td>Fantasia</td>'
	cMensagem += '<td>Chave NFE</td>'
	cMensagem += '<td>Produto</td>'
	cMensagem += '<td>Descri็ใo</td>'
	cMensagem += '<td>Quantidade</td>'
	cMensagem += '<td>Valor Unitแrio</td>'
	cMensagem += '<td>Total</td>'
	cMensagem += '<td>TES</td>'
	cMensagem += '<td>Almoxarifado</td>'
	cMensagem += '<td>Data Digita็ใo</td>'
	cMensagem += '</tr>'
	TcQuery cQuery New Alias "DADOS"
	DbSelectArea("DADOS")
	DADOS->(DbGoTop())
	While ! DADOS->(Eof())
		cMensagem += '<tr>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_FILIAL)    + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_DOC)       + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_SERIE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_ESPECIE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_FORNECE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_LOJA)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->A2_NREDUZ)    + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_CHVNFE)     + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_COD)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->B1_DESC)    + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->D1_QUANT,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->D1_VUNIT,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->D1_TOTAL,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_TES)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_LOCAL)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_DTDIGIT)   + '</td>'
		cMensagem += '</tr>'
		DADOS->(DbSkip())
	EndDo
	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'
	DADOS->(DbCloseArea())
	//
	ProcessarEmail(cAssunto,cMensagem,cMails)
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptSql      บAutor  ณFernando Sigoli บData ณ  29/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro S/A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _ScriptSQL()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	/*
		cMensagem += '<td>' + cValToChar(DADOS->F1_FILIAL)    + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_DOC)       + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_SERIE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_ESPECIE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_FORNECE)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_LOJA)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->A2_NREDUZ)    + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->F1_CHVNFE)     + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_COD)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->B1_DESC)    + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->D1_QUANT,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->D1_VUNIT,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(Transform(DADOS->D1_TOTAL,"@E 999,999,999.99"))  + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_TES)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_LOCAL)   + '</td>'
		cMensagem += '<td>' + cValToChar(DADOS->D1_DTDIGIT)   + '</td>'
	*/
	cQuery := " "
	cQuery += "  SELECT "
	cQuery += "  F1_FILIAL, F1_DOC, F1_SERIE, F1_ESPECIE, F1_FORNECE, F1_LOJA, A2_NREDUZ, F1_CHVNFE, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_TES, D1_LOCAL, CONVERT(VARCHAR(10),CAST(D1_DTDIGIT AS DATE),103) AS D1_DTDIGIT, F1_DTDIGIT "  //chamado 057922 - || Fernando Sigoli 07/05/2020 - OS 059404 || CONTROLADORIA || THIAGO || 8439
	cQuery += "  FROM " + RetSqlName("SF1") + " SF1 WITH (NOLOCK), " + RetSqlName("SD1") + " SD1 WITH (NOLOCK), " + RetSqlName("SA2") + " SA2 WITH (NOLOCK), " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) "
	cQuery += "  WHERE F1_FILIAL=D1_FILIAL "
	cQuery += "  AND F1_DOC=D1_DOC "
	cQuery += "  AND F1_SERIE=D1_SERIE "
	cQuery += "  AND F1_TIPO=D1_TIPO "
	cQuery += "  AND F1_FORNECE=D1_FORNECE "
	cQuery += "  AND F1_LOJA=D1_LOJA "
	cQuery += "  AND F1_FORNECE=A2_COD "
	cQuery += "  AND F1_LOJA=A2_LOJA "
	cQuery += "  AND D1_COD=B1_COD "
	cQuery += "  AND F1_FILIAL='"+SF1->F1_FILIAL+"' "
	cQuery += "  AND F1_DOC='"+SF1->F1_DOC+"' "
	cQuery += "  AND F1_SERIE='"+SF1->F1_SERIE+"' "
	cQuery += "  AND F1_TIPO='"+SF1->F1_TIPO+"' "
	cQuery += "  AND F1_FORNECE='"+SF1->F1_FORNECE+"' "
	cQuery += "  AND F1_LOJA='"+SF1->F1_LOJA+"' "
	cQuery += "  AND SF1.D_E_L_E_T_ = '' "
	cQuery += "  AND SD1.D_E_L_E_T_ = '' "
	cQuery += "  AND SA2.D_E_L_E_T_ = '' "
	cQuery += "  AND SB1.D_E_L_E_T_ = '' "
	RestArea(aArea)
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocessarEmail บAutor  ณFernando Sigoli บData ณ  29/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfigura็๕es de e-mail.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro S/A                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcessarEmail(cAssunto,cMensagem,email)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
	Local cAtach        := ""
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
			// Aviso(	"INTNFEB-01",;
				// "Email enviado com sucesso!"  + chr(13) + chr(10)+;
				// "Emails: "  + Left(cMails,66) + chr(13) + chr(10) +;
				// "" + Subs(cMails,67,Len(cMails)),;
				// { "&OK" },3,;
				// "NFE - Classifica็ใo Complemento Frango Vivo" )
			MsgInfo("Email enviado com sucesso! Emails: "  + cMails)
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
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtransmNF          บ Autor ณ Everson   บ Data ณ  06/11/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTransmissใo de nota fiscal.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033511.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function transmNF(aNFTrans,cSerie)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cNFIni	:= aNFTrans[1][1]
	Local cNFFim	:= aNFTrans[Len(aNFTrans)][1]
	Local cFornec	:= aNFTrans[1][3]
	Local cLoja		:= aNFTrans[1][4]
	Local cAmbiTrans:= Alltrim(cValToChar(GetMv("MV_#AMBNF",,"")))
	////TCSetConn(_conProthe)
	//
	MsgInfo("Notas geradas de " + cNFIni + " at้ " + cNFFim + ".","Fun็ใo emitNfGrp")
	//
	If Empty(cAmbiTrans)
		MsgStop("Nใo foi possํvel transmitir as notas fiscais pois o parโmetro MV_#AMBNF nใo estแ preenchido.","Fun็ใo transmNF")
		RestArea(aArea)
		Return .F.
	EndIf
	//
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	SF1->(DbGoTop())
	If SF1->(DbSeek( xFilial("SF1") + cNFIni + cSerie + Space(TamSX3("F1_SERIE")[1] - Len(cSerie)) +  cFornec +  cLoja ))
		MsAguarde({|| AutoNfeEnv(cEmpAnt,SF1->F1_FILIAL,"5",cAmbiTrans,SF1->F1_SERIE,cNFIni,cNFFim) },"Transmitindo NF","De " + cNFIni + " at้ " + cNFFim + " S้rie: " + cValToChar(SF1->F1_SERIE) + " ..." )
		MsAguarde({|| imprimeNF(cValToChar(aNFTrans[1][1]),cValToChar(aNFTrans[Len(aNFTrans)][1])) },"Aguarde","Imprimindo notas fiscais...")
	Else
		MsgStop("Nใo foi possํvel efetuar a transmissใo das notas fiscais.","Fun็ใo transmNF")
	EndIf
	//
	RestArea(aArea)
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimprimeNF บ Autor ณ Everson            บ Data ณ  06/11/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCarrega o conte๚do na variแvel da pergunta.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function imprimeNF(cNFIni,cNFFim)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea 	:= GetArea()
	Local cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"
	Private aFilBrw	:=	{'SF2',cCondicao}
	Default cNFIni	:= ""
	Default cNFFim	:= ""
	//
	If ! Empty(cNFIni) .And. ! Empty(cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR01", cNFIni)
		zAtuPerg("NFSIGW", "MV_PAR02", cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR04", 1)
	EndIf
	//
	SpedDanfe()
	//
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณzAtuPerg  บ Autor ณ Everson            บ Data ณ  06/11/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCarrega o conte๚do na variแvel da pergunta.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado .                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function zAtuPerg(cPergAux, cParAux, xConteud)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea      := GetArea()
	Local nPosCont   := 8
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}
	Default xConteud := ''
	//Se nใo tiver pergunta, ou nใo tiver ordem.
	If Empty(cPergAux) .Or. Empty(cParAux)
		Return Nil
	EndIf
	//Chama a pergunta em mem๓ria.
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)
	//Procura a posi็ใo do MV_PAR.
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })
	//Se encontrou o parโmetro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")
			//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD("+dToS(xConteud)+")")
			//Num้rico ou L๓gico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")
		EndIf
		//Chama a rotina para salvar os parโmetros
		__SaveParam(cPergAux, aPergAux)
	EndIf
	RestArea(aArea)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณExistXML  บAutor  ณFernando Macieira   บ Data ณ 14/05/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa se a NF de entrada possui XML na Central             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ExistXML(cNum, cSer, cCNPJ, cEspecie, cFormul, nRdo)
	Local aAreaAtu   := GetArea()
	Local lExistXML  := .f.
	Local cQuery     := ""
	Local cXMLNUMNF  := ""
	Local cXMLNUNFX  := ""
	Default cNum     := ""
	Default cSer     := ""
	Default cCNPJ    := ""
	Default cEspecie := ""
	Default cFormul  := ""
	U_ADINF009P('INTNFEB' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Vai gerar Pre-Notas por uma op็ใo no menu do usuario ')
	// Chamado TI - Formulario proprio nao devera consistir Central XML - FWNM - 08/05/2019
	If AllTrim(cFormul) == "S"
		lExistXML := .t.
		Return lExistXML
	EndIf
	// Chamado: 050135 - Fernando Sigoli 01/07/2019 - Nao consistir na central xml, quando Especie = NF
	If AllTrim(cFormul) == "N" .and. AllTrim(cEspecie) == 'NF'
		lExistXML := .t.
		Return lExistXML
	EndIf
	// Consisto chave que sera utilizada na pesquisa
	// TI - Fernando Sigol 16/05/2019
	cXMLNUMNF := PADR(cvaltochar(Val(cSer)) ,3,'')+ cNum
	cXMLNUNFX := cSer + cNum
	If Empty(cXMLNUMNF) .or. Empty(cCNPJ) .or. Empty(cEspecie)
		Return lExistXML
	EndIf
	// Busco XML na tabela da central
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	If AllTrim(cEspecie) == "SPED"
		cQuery := " SELECT COUNT(1) TT "
		cQuery += " FROM RECNFXML (NOLOCK) "
		cQuery += " WHERE ( XML_NUMNF = '"+cXMLNUMNF+"' "
		cQuery += " OR XML_NUMNF = '"+cXMLNUNFX+"' )"      //Chamado TI, 20/05/2019 - Fernando Sigoli
		cQuery += " AND XML_EMIT = '"+cCNPJ+"' "
		cQuery += " AND D_E_L_E_T_='' "
	ElseIf AllTrim(cEspecie) == "CTE" .or. AllTrim(cEspecie) == 'CTEOS'"
		cQuery := " SELECT COUNT(1) TT "
		cQuery += " FROM RECNFCTE (NOLOCK) "
		cQuery += " WHERE ( XML_NUMNF = '"+cXMLNUMNF+"' "
		cQuery += " OR XML_NUMNF = '"+cXMLNUNFX+"' )"   //Chamado TI, 20/05/2019 - Fernando Sigoli
		cQuery += " AND XML_EMIT = '"+cCNPJ+"' "
		cQuery += " AND D_E_L_E_T_='' "
	EndIf
	tcQuery cQuery new alias "Work"
	Work->( dbGoTop() )
	If Work->TT >= 1
		lExistXML := .t.
	EndIf
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	RestArea( aAreaAtu )
Return lExistXML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChkChvNF  บAutor  ณFernando Macieira   บ Data ณ 14/05/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa dados do XML para permitir lancamento/classificacao  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบChamado   ณN. 047900 || OS 049165 || FISCAL || ALLAN || 8394 ||        บฑฑ
ฑฑบ          ณ|| VALIDAR EMISSAO CTE - FWNM - 14/05/2019                  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบChamado   ณN. 048529 || OS 049805 || FISCAL || ALLAN || 8394 ||        บฑฑ
ฑฑบ          ณ|| VALIDAR NFE INT - FWNM - 14/05/2019                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ChkChvNF(cFilNF, cDoc, cSer, cFor, cLoj, cTipo, cSistema, cChaveNFe, cAnoMes, cCNPJ)
	Local aAreaAtu    := GetArea()
	Local lXMLOk      := .t.
	Local cQuery      := ""
	Default cFilNF    := ""
	Default cDoc      := ""
	Default cSer      := ""
	Default cFor      := ""
	Default cLoj      := ""
	Default cTipo     := ""
	Default cSistema  := ""
	Default cChaveNFe := ""
	Default cAnoMes   := ""
	Default cCNPJ     := ""
	U_ADINF009P('INTNFEB' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Vai gerar Pre-Notas por uma op็ใo no menu do usuario ')
	// Nao consisto qdo nao possui chave
	If Empty(cChaveNFe)
		Return lXMLOk
	EndIf
	// Consisto chave que sera utilizada na pesquisa
	If Empty(cFilNF) .or. Empty(cDoc) .or. Empty(cSer) .or. Empty(cFor) .or. Empty(cLoj) .or. Empty(cTipo) .or. Empty(cSistema) .or. Empty(cAnoMes) .or. Empty(cCNPJ)
		lXMLOk := .f.
		Return lXMLOk
	EndIf
	If cSistema == "PROTHEUS"
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		cQuery := " SELECT F1_EST, F1_EMISSAO, F1_DTDIGIT, F1_SERIE, F1_DOC, F1_FORNECE, F1_LOJA, F1_TIPO, F1_ESPECIE, F1_CHVNFE, A2_CGC "
		cQuery += " FROM " + RetSqlName("SF1") + " SF1 (NOLOCK) "
		cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_COD=F1_FORNECE AND A2_LOJA=F1_LOJA AND SA2.D_E_L_E_T_='' "
		cQuery += " WHERE F1_FILIAL='"+cFilNF+"' "
		cQuery += " AND F1_DOC='"+cDoc+"' "
		cQuery += " AND F1_SERIE='"+cSer+"' "
		cQuery += " AND F1_FORNECE='"+cFor+"' "
		cQuery += " AND F1_LOJA='"+cLoj+"' "
		cQuery += " AND F1_TIPO='"+cTipo+"' "
		cQuery += " AND SF1.D_E_L_E_T_='' "
		tcQuery cQuery new alias "Work"
		Work->( dbGoTop() )
		If Work->( !EOF() )
			/*
			//  Formacao da Chave de Acesso de uma NF-e, NFC-e, de um CT-e e um MDF-e
			
			(02 dํgitos) *** C๓digo do Estado (UF) do emitente
			(04 dํgitos) *** Ano e m๊s da emissใo da NF-e (no formato AAMM)
			(14 dํgitos) *** CNPJ do emitente da NF-e (CNPJ da sua Empresa)
			(02 dํgitos) *** Modelo do NF-e
			(03 dํgitos) *** S้rie do NF-e
			(09 dํgitos) *** N๚mero da NF-e
			(09 dํgitos) *** C๓digo da NF-e - N๚mero gerado pelo sistema
			(01 dํgitos) *** Dํgito verificador - DV (Cแlculo no m๓dulo 11).
			
			        10        20        30        40  44  
			12345678901234567890123456789012345678901234
			UFAAMMCNPJ123456CNPJ12SER123456789
			*/
			_cAnoMes := Subs(Work->F1_CHVNFE,3,4)
			_cCNPJ   := Subs(Work->F1_CHVNFE,7,14)
			_cSerie  := Subs(Work->F1_CHVNFE,23,3)
			_cDoc    := Subs(Work->F1_CHVNFE,26,9)
			//Consisto DATA, CNPJ, SERIE e DOC
			// DATA
			If lXMLOk
				If _cAnoMes <> Subs(Work->F1_EMISSAO,3,4)
					lXMLOk := .f.
				EndIf
			EndIf
			// CNPJ
			If lXMLOk
				If _cCNPJ <> AllTrim(Work->A2_CGC)
					lXMLOk := .f.
				EndIf
			EndIf
			// Serie
			If lXMLOk
				If _cSerie <> StrZero(Val(AllTrim(Work->F1_SERIE)),3)
					lXMLOk := .f.
				EndIf
			EndIf
			// Documento
			If lXMLOk
				If _cDoc <> AllTrim(Work->F1_DOC)
					lXMLOk := .f.
				EndIf
			EndIf
		EndIf
		If Select("Work") > 0
			Work->( dbCloseArea() )
		EndIf
		// SAG
	Else
		/*
		//  Formacao da Chave de Acesso de uma NF-e, NFC-e, de um CT-e e um MDF-e
			
		(02 dํgitos) *** C๓digo do Estado (UF) do emitente
		(04 dํgitos) *** Ano e m๊s da emissใo da NF-e (no formato AAMM)
		(14 dํgitos) *** CNPJ do emitente da NF-e (CNPJ da sua Empresa)
		(02 dํgitos) *** Modelo do NF-e
		(03 dํgitos) *** S้rie do NF-e
		(09 dํgitos) *** N๚mero da NF-e
		(09 dํgitos) *** C๓digo da NF-e - N๚mero gerado pelo sistema
		(01 dํgitos) *** Dํgito verificador - DV (Cแlculo no m๓dulo 11).
			
		        10        20        30        40  44  
		12345678901234567890123456789012345678901234
		UFAAMMCNPJ123456CNPJ12SER123456789
		*/
		_cAnoMes := Subs(cChaveNFe,3,4)
		_cCNPJ   := Subs(cChaveNFe,7,14)
		_cSerie  := Subs(cChaveNFe,23,3)
		_cDoc    := Subs(cChaveNFe,26,9)
		//Consisto UF, DATA, CNPJ, SERIE e DOC
		// DATA
		If lXMLOk
			If _cAnoMes <> Subs(cAnoMes,3,4)
				lXMLOk := .f.
			EndIf
		EndIf
		// CNPJ
		If lXMLOk
			If _cCNPJ <> AllTrim(cCNPJ)
				lXMLOk := .f.
			EndIf
		EndIf
		// Serie
		If lXMLOk
			If _cSerie <> StrZero(Val(AllTrim(cSer)),3)
				lXMLOk := .f.
			EndIf
		EndIf
		// Documento
		If lXMLOk
			If _cDoc <> AllTrim(cDoc)
				lXMLOk := .f.
			EndIf
		EndIf
	EndIf
	RestArea( aAreaAtu )
Return lXMLOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDestOk    บAutor  ณFernando Macieira   บ Data ณ 02/10/2019  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Checa se a NF/CTE esta sendo lancada no destino correto    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 052097 || OS 053474 || FISCAL || SIMONE || 8463 || CTES    บฑฑ
ฑฑบ          ณ 3182 E 3189                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DestOk(cNum, cSer, cCNPJ, cEspecie, cFormul, nRdo)
	Local lDestOk    := .f.
	Local cQuery     := ""
	Local cXMLNUMNF  := ""
	Local cXMLNUNFX  := ""
	Local aAreaAtu   := GetArea()
	Local aAreaSM0   := SM0->( GetArea() )
	Local cCNPJDest  := ""
	Default cNum     := ""
	Default cSer     := ""
	Default cCNPJ    := ""
	Default cEspecie := ""
	Default cFormul  := ""
	Default nRdo     := ""
	U_ADINF009P('INTNFEB' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Vai gerar Pre-Notas por uma op็ใo no menu do usuario ')
	// Chamado n. 052097 || Formulario proprio nao consistir CNPJ Destino - fwnm - 04/10/2019
	// Chamado TI - Formulario proprio nao devera consistir Central XML - FWNM - 08/05/2019
	If AllTrim(cFormul) == "S"
		lDestOk := .t.
		Return lDestOk
	EndIf
	// Chamado: 050135 - Fernando Sigoli 01/07/2019 - Nao consistir na central xml, quando Especie = NF
	If AllTrim(cFormul) == "N" .and. AllTrim(cEspecie) == 'NF'
		lDestOk := .t.
		Return lDestOk
	EndIf
	// Consisto chave que sera utilizada na pesquisa
	// TI - Fernando Sigol 16/05/2019
	cXMLNUMNF := PADR(cvaltochar(Val(cSer)) ,3,'')+ cNum
	cXMLNUNFX := cSer + cNum
	If Empty(cXMLNUMNF) .or. Empty(cCNPJ) .or. Empty(cEspecie)
		Return lDestOk
	EndIf
	//
	// Carrego CGC da empresa/filial corrente
	SM0->( dbSetOrder(1) ) // M0_CODIGO + M0_CODFIL
	If SM0->( dbSeek( cEmpAnt + cFilAnt ) )
		cCNPJDest := AllTrim(SM0->M0_CGC)
	EndIf
	// Busco Destino na tabela da central
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	If AllTrim(cEspecie) == "SPED"
		cQuery := " SELECT XML_DEST "
		cQuery += " FROM RECNFXML (NOLOCK) "
		cQuery += " WHERE ( XML_NUMNF = '"+cXMLNUMNF+"' "
		cQuery += " OR XML_NUMNF = '"+cXMLNUNFX+"' )"      //Chamado TI, 20/05/2019 - Fernando Sigoli
		cQuery += " AND XML_EMIT = '"+cCNPJ+"' "
		cQuery += " AND D_E_L_E_T_='' "
	ElseIf AllTrim(cEspecie) == "CTE" .or. AllTrim(cEspecie) == 'CTEOS'"
		cQuery := " SELECT XML_DEST "
		cQuery += " FROM RECNFCTE (NOLOCK) "
		cQuery += " WHERE ( XML_NUMNF = '"+cXMLNUMNF+"' "
		cQuery += " OR XML_NUMNF = '"+cXMLNUNFX+"' )"   //Chamado TI, 20/05/2019 - Fernando Sigoli
		cQuery += " AND XML_EMIT = '"+cCNPJ+"' "
		cQuery += " AND D_E_L_E_T_='' "
	EndIf
	tcQuery cQuery new alias "Work"
	Work->( dbGoTop() )
	If Work->( !EOF() )
		If AllTrim(Work->XML_DEST) == cCNPJDest
			lDestOk := .t.
		EndIf
	EndIf
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	RestArea( aAreaAtu )
	RestArea( aAreaSM0 )
Return lDestOk
/*/{Protheus.doc} Static Function UpCompSAG()
	Insere PC na NF e gera amarra็ใo entre adiantamentos SAG e PC
	@type  Function
	@author FWNM
	@since 27/10/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	ticket 3873 - FWNM - 26/10/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
/*/
Static Function UpCompSAG(cF1_Filial, cDoc, cSerie, cTipo, cF1_FORNECE, cF1_LOJA, cCod, nRadio, cCCusto)
	Local cPCSAG   := ""
	Local cLinked  := GetMV("MV_#SAGLS",,"SCSRV03")
	Local cQuery   := ""
	Local aAreaAtu := GetArea()
	Local lLockFIE := .t.
	Local lLockSC7 := .t.
	Local nOpcPC   := 3
	Local aCabec   := {}
	Local aItens   := {}
	Local aLinha   := {}
	Local cCondPC  := GetMV("MV_#SAGSE4",,"SAG")
	Local cItemPC  := "0001"
	Local lGeraFIE := .T.
	PRIVATE lMsErroAuto := .F.
	Default cF1_Filial  := ""
	Default cDoc        := ""
	Default cSerie      := ""
	Default cTipo       := ""
	Default cF1_FORNECE := ""
	Default cF1_LOJA    := ""
	Default cCod        := ""
	Default nRadio      := 0
	Default cCCusto     := ""
	//Begin Transaction
	// Busco os dados do PC na view POCANFE contida no banco ADORO do servidor SAG
	If Select("WorkPC") > 0
		WorkPC->( dbCloseArea() )
	EndIf
	cQuery := " SELECT * FROM OPENQUERY (SCSRV03, '
	cQuery += " SELECT F1_PED, D1_QUANT, D1_VUNIT,F1_COND 
	cQuery += " FROM ADORO.dbo.POCANFE (NOLOCK)
	cQuery += " WHERE F1_FILIAL=''"+cF1_Filial+"''
	cQuery += " AND F1_DOC=''"+cDoc+"''
	cQuery += " AND F1_SERIE=''"+cSerie+"''
	cQuery += " AND F1_TIPO=''"+cTipo+"''
	cQuery += " AND F1_FORNECE=''"+cF1_FORNECE+"''
	cQuery += " AND F1_LOJA=''"+cF1_LOJA+"''
	cQuery += " AND D1_COD=''"+cCod+"''
	cQuery += " AND F1_PED IS NOT NULL
	cQuery += " ')
	tcQuery cQuery New Alias "WorkPC"  
	WorkPC->( dbGoTop() )
	If WorkPC->( !EOF() )
		cPCSAG := "S" + AllTrim(Str(WorkPC->F1_PED))
		If !Empty(WorkPC->F1_COND)  //ticket   62952   - Fernando Sigoli   - 27/10/2021
			cCondPC := WorkPC->F1_COND	
		EndIf	
	EndIf
	// debug
	/*If AllTrim(cPCSAG) == "S20594"
		cDebug := ""
	EndIf */
	// debug
		// Checo se o PC existe
		//If Empty(cPCSAG) 
If Empty(cPCSAG) .or. ( Len(cPCSAG) < TamSX3("C7_NUM")[1] ) // // @history ticket    6082 - Fernando Macieira - 07/12/2020 - IMPORTAวรO NF 49322 - PC n. S0
			
			cPCSAG  := ""
			cItemPC := ""
			Return {}
Else
			// @history ticket    6376 - Fernando Macieira - 09/12/2020 - ERRO DE LOG IMPORTAวรO
			SC7->( dbSetOrder(1) ) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
	If SC7->( dbSeek( cF1_Filial + PadR(cPCSAG,TamSX3("C7_NUM")[1]) ) )
				
				// Checo se ้ o mesmo fornecedor
		If cF1_FORNECE <> SC7->C7_FORNECE .or. cF1_LOJA <> SC7->C7_LOJA
					//MsgAlert("PC n. : " + cPCSAG + " na filial " + cF1_Filial + " jแ existe na base para outro fornecedor... NF " + cDoc + " nใo serแ incluida! Verifique no SAG!")
				
				    cErro := "PC n. : " + cPCSAG + " na filial " + cF1_Filial + " jแ existe na base para outro fornecedor... NF " + cDoc + " serแ incluida sem o PC! Verifique no SAG!"+CRLF + CRLF
					cImpEr+= cErro + CRLF + CRLF
					u_GrLogZBE ( msDate(), TIME(), cUserName, "DOCUMENTO ENTRADA", "SAG", "INTNFEB",;
                	"PC n. : " + cPCSAG + " na filial " + cF1_Filial + " jแ existe na base para outro fornecedor... NF " + cDoc + " nใo serแ incluida! Verifique no SAG!", ComputerName(), LogUserName() )
				
					cPCSAG  := ""
					cItemPC := ""
					Return {}
				
		EndIf
				// Gero SCY - Historico PC (Antes da alteracao)
				//GrvSCY(cPCSAG) // @history ticket    6376 - Fernando Macieira - 09/12/2020 - ERRO DE LOG IMPORTAวรO
				// defino o C7_ITEM sequencial
		If Select("WorkPCItem") > 0
					WorkPCItem->( dbCloseArea() )
		EndIf
				cQuery := " SELECT ISNULL(MAX(C7_ITEM),0) C7_ITEM
				cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK)
				cQuery += " WHERE C7_FILIAL='"+cF1_Filial+"'
				cQuery += " AND C7_NUM='"+cPCSAG+"'
				cQuery += " AND C7_FORNECE='"+cF1_FORNECE+"'
				cQuery += " AND C7_LOJA='"+cF1_LOJA+"'
				cQuery += " AND D_E_L_E_T_=''
				tcQuery cQuery New Alias "WorkPCItem"
				
				cItemPC  := Soma1(WorkPCItem->C7_ITEM,Len(SC7->C7_ITEM))
		If Select("WorkPCItem") > 0
			WorkPCItem->( dbCloseArea() )
		EndIf
				
	EndIf
	// ExecAuto PC (SC7)
	ConOut("INTNFEB - SAG - Incluido PC: " + cPCSAG)
	SB1->( dbSetOrder(1) ) // B1_FILIAL + B1_COD
	SB1->( dbSeek(FWxFilial("SB1")+PadR(cCod,TamSX3("B1_COD")[1])))
	// Insert manual autorizado do PC (SC7) pois
	// o mesmo existirแ apenas para fazer amarra็ใo do realizado e nใo deverแ cair nas regras atuais
	// e tamb้m nใo mudaremos os pontos de entradas existentes devido complexidade e utiliza็ใo que logo serแ desativaada
	RecLock("SC7", lLockSC7)
	SC7->C7_FILIAL  := FWxFilial("SC7")
	SC7->C7_NUM     := cPCSAG
	SC7->C7_EMISSAO := dDataBase
	SC7->C7_FORNECE := cF1_FORNECE
	SC7->C7_LOJA    := cF1_LOJA
	SC7->C7_COND    := cCondPC
	SC7->C7_CONTATO := "SAG"
	SC7->C7_OBS     := "SAG"
	SC7->C7_FILENT  := cF1_Filial
	SC7->C7_TIPO    := 1
	SC7->C7_XRESPON := AllTrim(cUserName)
	SC7->C7_USER    := __CUSERID
	SC7->C7_CONAPRO := "L"
	SC7->C7_ITEM    := cItemPC
	SC7->C7_PRODUTO := cCod
	SC7->C7_UM      := SB1->B1_UM
	SC7->C7_DESCRI  := SB1->B1_DESC
	SC7->C7_LOCAL   := SB1->B1_LOCPAD
	SC7->C7_QUANT   := nQuant
	SC7->C7_PRECO   := nVlrUnit
	SC7->C7_TOTAL   := nTotal
	SC7->C7_VLDESC  := nValDesc
	SC7->C7_CC      := cCCusto
	//SC7->C7_CONTA   := ""
	//SC7->C7_ITEMCTA := ""
	SC7->( msUnLock() )
	// Amarro todos os adiantamentos existentes a este PC
	If Select("WorkPA") > 0
		WorkPA->( dbCloseArea() )
	EndIf
	cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_SALDO, E2_VALOR
	cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
	cQuery += " WHERE E2_FILIAL='"+cF1_Filial+"'
	cQuery += " AND E2_NUM='"+AllTrim(Str(WorkPC->F1_PED))+"'
	cQuery += " AND E2_TIPO='PA'
	cQuery += " AND E2_FORNECE='"+cF1_FORNECE+"'
	cQuery += " AND E2_LOJA='"+cF1_LOJA+"'
	cQuery += " AND D_E_L_E_T_=''
	tcQuery cQuery New Alias "WorkPA"
	WorkPA->( dbGoTop() )
	Do While WorkPA->( !EOF() )
		// Parametro para gerar FIE mesmo quando o PA nใo possuir movimento bancแrio (ocorre apenas no retorno do CNAB)
		// => Ativar o parโmetro quando a TOTVS corrigir a classifica็ใo da NF com condi็ใo de pagamento que nใo ้ de adiantamento e mesmo assim obriga o usuแrio a desamarrar o PA x PC (mesmo que a compensa็ใo nใo ocorrerแ)
		// => Chamado TOTVS #10116918
		If GetMV("MV_#SAGFIE",,.F.)
			lGeraFIE := .T.
		Else
			lGeraFIE := ChkSE5(cF1_Filial, WorkPA->E2_PREFIXO, WorkPA->E2_NUM, WorkPA->E2_PARCELA, WorkPA->E2_TIPO, cF1_FORNECE, cF1_LOJA)
		EndIf
		If lGeraFIE
			FIE->( dbSetOrder(3) ) // FIE_FILIAL, FIE_CART, FIE_FORNEC, FIE_LOJA, FIE_PREFIX, FIE_NUM, FIE_PARCEL, FIE_TIPO, FIE_PEDIDO, R_E_C_N_O_, D_E_L_E_T_
			If FIE->( dbSeek(cF1_Filial+"P"+cF1_FORNECE+cF1_LOJA+WorkPA->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+cPCSAG) )
				lLockFIE := .f.
			Else
				lLockFIE := .t.
			EndIf
			// Gero vinculo do PA com o Pedido de Vendas
			RecLock("FIE", lLockFIE)
			FIE->FIE_FILIAL := FWxFilial("FIE")
			FIE->FIE_CART   := "P"
			FIE->FIE_PEDIDO := cPCSAG
			FIE->FIE_PREFIX := WorkPA->E2_PREFIXO
			FIE->FIE_NUM    := WorkPA->E2_NUM
			FIE->FIE_PARCEL := WorkPA->E2_PARCELA
			FIE->FIE_TIPO   := WorkPA->E2_TIPO
			FIE->FIE_FORNEC := WorkPA->E2_FORNECE
			FIE->FIE_LOJA   := WorkPA->E2_LOJA
			FIE->FIE_VALOR  := WorkPA->E2_VALOR
			FIE->FIE_SALDO  := 0 //WorkPA->E2_SALDO (Saldo zerado pois o financeiro precisa compensar adiantamento manualmente e com outros documentos - Padrใo do sistema nใo permite!) // @history ticket    3873 - Fernando Macieira - 25/11/2020 - Projeto - Contrato e Controle de Entradas - Sใo Carlos
			FIE->( msUnLock() )
			//FIE->( fkCommit() )
		EndIf
		WorkPA->( dbSkip() )
	EndDo
	//Else
	//	MostraErro()
EndIf
If Select("WorkPC") > 0
	WorkPC->( dbCloseArea() )
EndIf
//End Transaction
RestArea( aAreaAtu )
Return { cPCSAG, cItemPC }
/*/{Protheus.doc} Static Function GrvSCY
	Armazena dados do PC antes de altera็๕es
	@type  Static Function
	@author FWNM 
	@since 28/10/2020
/*/
Static Function GrvSCY(cPCSAG)
	Local cQuery   := ""
	Local aAreaAtu := GetArea()
	Default cPCSAG := ""
	//  Verifica a ultima versao de alteracao do pedido no SCY e
	//  disponibiliza a proxima versao disponivel para a alteracao.
	If Select("MA120GRVQ2") > 0
		MA120GRVQ2->( dbCloseArea() )
	EndIf
	cVerSCY := StrZero(0,Len(SCY->CY_VERSAO))
	cQuery := "SELECT MAX(CY_VERSAO) VERSCY
	cQuery += "FROM " + RetSqlName("SCY") + " SCY (NOLOCK)
	cQuery += "WHERE CY_FILIAL='"+FWxFilial("SCY")+"' AND
	cQuery += "CY_NUM ='"+cPCSAG+"' AND
	cQuery += "SCY.D_E_L_E_T_=' '
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"MA120GRVQ2",.T.,.T.)
	cVerSCY := Substr(VERSCY,1,TamSX3("CY_VERSAO")[1])
	If Select("MA120GRVQ2") > 0
		MA120GRVQ2->( dbCloseArea() )
	EndIf
	dbSelectArea("SCY")
	cVerSCY := Soma1(cVerSCY,Len(SCY->CY_VERSAO))
	//  Antes de atualizar o Pedido de Compras SC7 com a alteracao
	//  atual, grava o SCY com os dados do SC7 gerando assim um
	//  historico com as versoes anteriores da alteracoes do PC.
	RecLock("SCY",.T.)
	For nX:=1 to SC7->( fCount() )
		cNomCpoSC7 := AllTrim(SC7->( FieldName( nX ) ))
		cNomCpoSCY := StrTran( cNomCpoSC7, "C7", "CY" )
		If SCY->( FieldPos( cNomCpoSCY ) ) > 0
			cNomCpoSC7 := SC7->( FieldName( nX ) )
			cVlrCpo := SC7->( FieldGet( FieldPos( cNomCpoSC7 ) ) )
			SCY->( FieldPut( FieldPos( cNomCpoSCY ), cVlrCpo ) )
		EndIf
	Next nX
	SCY->CY_VERSAO := cVerSCY
	SCY->( msUnLock() )
	RestArea( aAreaAtu )
Return
/*/{Protheus.doc} Static Function ChkSE5(cF1_Filial, WorkPA->E2_PREFIXO, WorkPA->E2_NUM, WorkPA->E2_PARCELA, WorkPA->E2_TIPO, cF1_FORNECE, cF1_LOJA)
	Determina se o PA possui movimento bancแrio para fazer amarra็ใo
	@type  Function
	@author FWNM
	@since 19/11/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkSE5(cF1_Filial, cE2_PREFIXO, cE2_NUM, cE2_PARCELA, cE2_TIPO, cF1_FORNECE, cF1_LOJA)
	Local lTemSE5 := .f.
	Local cQuery  := ""
	If Select("WorkSE5") > 0
		WorkSE5->( dbCloseArea() )
	EndIf
	cQuery := " SELECT E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA, E5_RECPAG, E5_TIPODOC, E5_MOTBX
	cQuery += " FROM " + RetSqlName("SE5") + " (NOLOCK)
	cQuery += " WHERE E5_FILIAL='"+cF1_Filial+"'
	cQuery += " AND E5_PREFIXO='"+cE2_PREFIXO+"'
	cQuery += " AND E5_NUMERO='"+cE2_NUM+"'
	cQuery += " AND E5_PARCELA='"+cE2_PARCELA+"'
	cQuery += " AND E5_TIPO='"+cE2_TIPO+"'
	cQuery += " AND E5_CLIFOR='"+cF1_FORNECE+"'
	cQuery += " AND E5_LOJA='"+cF1_LOJA+"'
	cQuery += " AND E5_RECPAG='P'
	cQuery += " AND E5_TIPODOC='PA'
	cQuery += " AND D_E_L_E_T_=''
	tcQuery cQuery new Alias "WorkSE5"
	WorkSE5->( dbGoTop() )
	If WorkSE5->( !EOF() )
		lTemSE5 := .t.
	EndIf
	If Select("WorkSE5") > 0
		WorkSE5->( dbCloseArea() )
	EndIf
Return lTemSE5
