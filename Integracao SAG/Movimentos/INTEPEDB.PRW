#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*/{Protheus.doc} User Function INTEPEDB
	Interface de entradas. Chamado 033511.  
	@type  Function
	@author Everson
	@since 24/03/2017
	@version 01
	@history Everson,  08/01/2019, chamado 046285 - Incluído faturamento por código de produto.
	@history Everson,  22/01/2019, chamado 046622 - Incluída função de ordenamento do array de itens do pedido de venda.
	@history Fernando, 07/02/2019, chamado 047017 - tratamento da função FWVetByDic. Apenas integração de pedidos de transferencia.
	@history Everson,  26/05/2020, chamado 058120 - Tratamento para importação automática de pedidos de saída.
	@history Everson,  29/05/2020, chamado 058120 - Checa se a Sefaz está disponível antes de fazer a transmissão das notas fiscais.
	@history Everson,  03/06/2020, chamado TI - Incluído parâmetro para indicar se haverá transmissão automática ou não da nf.
	@history Everson,  09/06/2020, chamado 058847 - Tratamento para corrigir erro ao utilizar consulta padrão no modelo2.
	@history Everson,  26/11/2020, chamado TI  - Tratamento com lockbyname para que a rotina de emissão de nf não seja executada simultaneamente.
	@history Everson,  30/11/2020, chamado TI  - Comentada a chamada da função de transmissão automática de nota fiscal.
	@history Andre,    02/12/2020, chamado TI  -  Adiicionado validação na chamada da função - If SM0->M0_CODFIL == SF2->F2_FILIAL
	@history Macieira, 11/02/2021, ticket 9352 - variable is not an object on ALTDADOSGRID(INTEPEDB.PRW) 02/12/2020 16:55:06 line : 1774
	@history Macieira, 17/02/2021, ticket 9571 - Error LOG - PED001B
	@history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
	@history Macieira, 18/02/2021, ticket 11804 - GRAVAR REGISTRO NO PROTHEUS para enviar ao SAG
	@history Abel B    10/05/2021, Ticket 13852 - Retirada a chamada da Função LIMPAEST() e direcionada para função padrão
	@history Abel B    11/05/2021, Ticket 13852 - Criado loop para liberação de estoque automática de todos os pedidos
	@history Everson,  17/05/2021, Ticket 13987 - Validação de tabela de preço e condição de pagamento.
	@history Everson,  17/09/2021, Ticket 31690 - Tratamento para controle de acesso de usuários da balança SC.
	@history Everson,  22/09/2021, Ticket TI    - Removido lockbyname.
	@history Jonathan  14/12/2021, Ticket 64214 - Incluir validação de conexão ao banco do SAG.
/*/
User Function PED001B()

	//Variáveis.
	Local aArea		:= GetArea()
	Local nRdTab	:= ""
	Local aItems	:= {"Pedidos Proth x SAG","Pendência importação"}
	Local oGroup1	:= Nil
	Local oGroupTot	:= Nil
	Local i			:= 1
	Local lUser		:= (RetCodUsr() $Alltrim(cValToChar(GetMv("MV_#FTPROD",,""))) ) //Everson - 08/01/2019. Chamado 046285. //Everson  - 26/05/2020, chamado 058120.
	
	//
	Private oSBtn01	:= Nil
	Private oSBtn02	:= Nil
	Private oSBtn03	:= Nil
	Private oSBtn04	:= Nil
	Private oSBtn07	:= Nil
	Private aRadio 	:= {;
						"Saída por devolução",;					// Pesagem final.
						"Saída por trans. filial",;				// Pesagem final.
						"Saída por trans. integrado",;			// Pesagem final.
						"Remessa para integrado",;				// Pesagem final.
						"Frango 3 transmissão propriedade",;	// Registro pode ser excluído.
						"Saída frango vivo apanha",;			// Registro pode ser excluído.
						"Saída trans. armazém",;				// Registro pode ser excluído.
						"Saída por venda",;						
						"Corte pedido de venda",;				
						"Venda/Remessa a ordem",;				// Registro pode ser excluído.
						"Revenda",;
						"Remessa Insumos p/ Granja";            // @history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
						}
	Private nRadio 			:= 0  
	Private oInterface		:= Nil
	Private aAltInterface	:= {}
	Private aHInterface		:= {}
	Private aColsInterface	:= {}
	Private oRegistros		:= Nil
	Private cCombo2			:= ""
	Private oCombo2			:= Nil
	Private oQtdReg			:= Nil
	Private nQtdReg			:= 0
	Private aFiltTpMv		:= {}
	Private oPnlBtn1		:= Nil
	Private oPnlBtn2		:= Nil
	Private oRdTab			:= Nil
	Private oTxtBusca		:= Nil
	Private cSelBusca		:= ""
	Private aSelBusca 		:= {"4=Pedido Protheus","3=Pedido SAG"}
	Private oSelBusca 		:= Nil
	Private cBusca 			:= Space(10)
	Private oBusca   		:= Nil
	Private oBtnBusca		:= Nil
	Private oTButton1 		:= Nil
	Private oTButton2 		:= Nil
	Private oTButton3 		:= Nil
	Private oTButton4 		:= Nil
	Private oTButton5 		:= Nil
	Private oTButton6 		:= Nil
	Private oTButton7 		:= Nil
	Private oTButton8		:= Nil
	Private dDataIni		:= dDataBase
	Private oDataIni		:= Nil
	Private oBtnFatP		:= Nil
	
	//@history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
	Private cTESRemGra      := GetMV("MV_#GRATES",,"912") // opção 12 - Separar as TES por #
	Private cTESPreGra      := GetMV("MV_#GRATE2",,"734#710") // opção 12 - Separar as TES por # // premissa para gerar a NF com o TES 912
	//
	
	//
	U_ADINF009P('INTEPEDB' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Interface de entradas.')
	
	//
	MsAguarde({|| enviStComp() },"Função PED001B","Checando movimentos 'Saída por venda'...")
	
	//Obtém as opções de filtro.
	Aadd(aFiltTpMv,"0=Todos")
	For i := 1 To Len(aRadio)
		Aadd(aFiltTpMv,"" + Alltrim(cValToChar(i)) + "=" + Alltrim(cValToChar(aRadio[i])) + "")
	
	Next i
	
	//Cria objeto MsDialog.
	oInterface:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Saídas - Processamentos Pendentes Protheus x SAG"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1100
	oInterface:nHeight   := 460
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
		//Radio para seleção de pendências.    
	    nRdTab := 1
		oRdTab := TRadMenu():New (005,006,aItems,,oInterface,,,,,,,,065,10,,,,.T.)
		oRdTab:SetOption(1)
		oRdTab:bSetGet := {|u|Iif (PCount()==0,nRdTab,nRdTab:=u)}
		oRdTab:bChange := {||altDadosGrid(nRdTab)}
		
		//Combobox para seleção de filtro.
		cCombo2 := aFiltTpMv[1]
	    oCombo2 := TComboBox():New(005,445,{|u|if(PCount()>0,cCombo2 := u,cCombo2)},;
	    aFiltTpMv,100,20,oInterface,,{|| MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") },,,,.T.,,,,,,,,,'cCombo2',"Filtro:",1)
	    oCombo2:lVisibleControl := .T.
	    
	    //Cria botão de busca.
		oTxtBusca := TSay():New(005,180,{||"Localiza pedido:"},oInterface,,,,,,.T.,CLR_RED,CLR_WHITE,250,20)
		cSelBusca := Space(15)
		cSelBusca := aSelBusca[1]
		oSelBusca := TComboBox():New(005,220,{|u|if(PCount()>0,cSelBusca:=u,cSelBusca)},;
		aSelBusca,050,25,oInterface,,,,,,.T.,,,,,,,,,'cSelBusca')
		oBusca    := TGet():New(005,271,{|u|If(PCount() == 0,cBusca,cBusca := u)},oInterface,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"",2) 
		oBtnBusca := TButton():New(005,322,"Ok",oInterface,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )

		//@history Macieira, 17/02/2021, ticket 9571 - Error LOG - PED001B
		If cBusca == Nil
			cBusca := ""
		EndIf
		//

		//nQtdReg
		oBtnBusca:bAction := {||;
		 						nBusca := Iif(nQtdReg <= 0, 0, Ascan(oRegistros:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[Val(cValToChar(cSelBusca))])})),;
								Iif(nBusca > 0,Eval({||oRegistros:ForceRefresh(),oRegistros:GoTo(nBusca),oRegistros:Refresh()}),;
								MsgAlert("Não foi possível localizar o registro","Função PED001B"));
							} 

	
		  
		//
		oDataIni := TGet():New(030,004,{|u|If(PCount() == 0,dDataIni,dDataIni := u)},oInterface,050,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataIni",,,,.T.,,,"Data Início",1) 
		oDataIni:bChange := {|| MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }
		    
		//Atualizar dados.
		oSBtn03:= SButton():Create(oInterface)
		oSBtn03:cName := "oSBtn03"
		oSBtn03:cCaption := "Atualizar"
		oSBtn03:nLeft := 125
		oSBtn03:nTop := 075
		oSBtn03:nWidth := 50
		oSBtn03:nHeight := 20
		oSBtn03:lShowHint := .F.
		oSBtn03:lReadOnly := .F.
		oSBtn03:Align := 0
		oSBtn03:lVisibleControl := .T.
		oSBtn03:bAction := {|| MsAguarde({|| enviStComp() },"Aguarde","Checando movimentos 'Saída por venda'..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }
		
		//Cria botão de confirmação.
		oSBtn01:= SButton():Create(oInterface)
		oSBtn01:cName := "oSBtn01"
		oSBtn01:cCaption := "Legenda"
		oSBtn01:nLeft := 190
		oSBtn01:nTop := 075
		oSBtn01:nWidth := 50
		oSBtn01:nHeight := 20
		oSBtn01:lShowHint := .F.
		oSBtn01:lReadOnly := .F.
		oSBtn01:Align := 0
		oSBtn01:lVisibleControl := .T.
		oSBtn01:bAction := {||lngProth()}
		
		//
		oPnlBtn1 := TPanel():New(035,145,"",oInterface,,.T.,,,,400,018)
			//Ticket 13852 - Abel Babini - Retirada a chamada da Função LIMPAEST() e direcionada para função padrão
			oTButton1 := TButton():New( 003, 002, "Lib. Estoque"    ,oPnlBtn1,{|| MsAguarde({|| xLibEst() },"Aguarde","Acessando rotina Lib. Estoque...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTButton2 := TButton():New( 003, 047, "Emitir NF"       ,oPnlBtn1,{|| MsAguarde({|| emitNfGrp( Val(cCombo2), oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})],"",.F. )  },"Aguarde","Acessando rotina Emissão de NF...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTButton3 := TButton():New( 003, 092, "SPED"            ,oPnlBtn1,{|| MsAguarde({|| SPEDNFe()    },"Aguarde","Acessando rotina SPEDNFe..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTButton4 := TButton():New( 003, 137, "Boleto"          ,oPnlBtn1,{|| MsAguarde({|| U_HCRFIBLT() },"Aguarde","Acessando Emissão de Boleto..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTButton8 := TButton():New( 003, 182, "Imprimir NF"     ,oPnlBtn1,{|| MsAguarde({|| imprimeNF("","") },"Aguarde","Acessando Impressão de NF...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			oTButton5 := TButton():New( 003, 247, "Visualizar Ped." ,oPnlBtn1,{|| MsAguarde({|| visualPed(oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})])  },"Aguarde","Acessando pedido " + Alltrim(cValToChar(oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})])) + "...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTButton6 := TButton():New( 003, 292, "Excluir Ped."    ,oPnlBtn1,{|| MsAguarde({|| exclPedido(cFilAnt,oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]) },"Aguarde","Excluindo pedido..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oTButton7 := TButton():New( 003, 337, "Cort. Man."      ,oPnlBtn1,{|| MsAguarde({|| corteMan() },"Aguarde","Acessando corte manual de produtos..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
		//
		oPnlBtn2 := TPanel():New(035,145,"",oInterface,,.T.,,,,400,018)
			//Importação.
			oSBtn04:= SButton():Create(oPnlBtn2)
			oSBtn04:cName := "oSBtn04"
			oSBtn04:cCaption := "Importar"
			oSBtn04:nLeft := 003
			oSBtn04:nTop := 005
			oSBtn04:nWidth := 50
			oSBtn04:nHeight := 20
			oSBtn04:lShowHint := .F.
			oSBtn04:lReadOnly := .F.
			oSBtn04:Align := 0
			oSBtn04:lVisibleControl := .F.
			oSBtn04:bAction := {|| oRdTab:SetOption(1), telProcess(Val(cCombo2),.F.) } //Everson - 26/05/2020. Chamado 058120.
			
			//Editar Registro.
			oSBtn07:= SButton():Create(oPnlBtn2)
			oSBtn07:cName := "oSBtn07"
			oSBtn07:cCaption := "Editar"
			oSBtn07:nLeft := 068
			oSBtn07:nTop := 005
			oSBtn07:nWidth := 50
			oSBtn07:nHeight := 20
			oSBtn07:lShowHint := .F.
			oSBtn07:lReadOnly := .F.
			oSBtn07:Align := 0
			oSBtn07:lVisibleControl := .F.
			oSBtn07:bAction := {|| MsAguarde({|| U_PED_EDRG(oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPRAD"})],; //Everson  - 09/06/2002, chamado 058847.
											oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PEDS"})]) },"Aguarde","Acessando rotina...") }
		
		//
		oPnlBtn1:lVisibleControl := .T.
		oPnlBtn2:lVisibleControl := .F.
				
		//
		oGroupTot := TGroup():Create(oInterface,162,433,185,545,"",,,.T.)
		
		//
		oQtdReg := TGet():New(170,438, { | u | If( PCount() == 0, nQtdReg, nQtdReg := u ) },oInterface, ;
	    		   060, 010, "@E 999,999,999",, 0, 16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdReg",,,,.F.,,,"Total de registros:",2,,CLR_RED)
	
		//
		oGroup1 := TGroup():Create(oInterface,190,004,210,545,"",,,.T.)
		
		//Everson - 08/01/2019. Chamado 046285.
		oBtnFatP:= SButton():Create(oInterface)
		oBtnFatP:cName := "oBtnFatP"
		oBtnFatP:cCaption := "Fat. Prod"
		oBtnFatP:nLeft := 014
		oBtnFatP:nTop := 390
		oBtnFatP:nWidth := 50
		oBtnFatP:nHeight := 20
		oBtnFatP:lShowHint := .F.
		oBtnFatP:lReadOnly := .F.
		oBtnFatP:Align := 0
		oBtnFatP:lVisibleControl := lUser 
		oBtnFatP:bAction := {|| FatPProd() }
		//
	
		//Cria botão de cancelamento.
		oSBtn02:= SButton():Create(oInterface)
		oSBtn02:cName := "oSBtn02"
		oSBtn02:cCaption := "Fechar"
		oSBtn02:nLeft := 1031
		oSBtn02:nTop := 390
		oSBtn02:nWidth := 50
		oSBtn02:nHeight := 20
		oSBtn02:lShowHint := .F.
		oSBtn02:lReadOnly := .F.
		oSBtn02:Align := 0
		oSBtn02:lVisibleControl := .T.
		oSBtn02:bAction := {||oInterface:End()}
		oSBtn02:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")		
		
		//Cria Header.
		Aadd(aHInterface,{" ","LEG"    	  ,"@BMP"    ,01     , 00,.T.,"","","","R","","",.F.,"V","","","",""})
		Aadd(aHInterface,{"DT Emissão"    ,"DTEMIS"	 ,""	 , 10,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Pedido SAG"    ,"PEDS"    ,""	 , 12,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Pedido Protheus","PED"    ,""	 , 12,0,"","" ,"C","",""})
		//Aadd(aHInterface,{"Nota"          ,"NF"      ,""	 , 13,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Placa"         ,"PLC"     ,""	 , 07,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Granja"        ,"GRJ"     ,""	 , 06,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Qtd"           ,"QTD"     ,"@E 999,999,999.999999"	 , 18,6,"","" ,"N","",""})
		Aadd(aHInterface,{"Bloq Corte"    ,"BLQC"    ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Bloq Est"      ,"BLEST"   ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Bloq Fin"      ,"BLFIN"   ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Operação"  	  ,"OPER"	 ,""	 , 10,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Status Op"  	  ,"STOPER"	 ,""	 , 01,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Cliente"       ,"CLI"     ,""	 , 06,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Loja"          ,"LOJ"     ,""	 , 02,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Nome"          ,"NOM"     ,""	 , 40,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Tipo Ped"      ,"TPPED"   ,""	 , 01,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Tipo Frete"    ,"TPFRT"   ,""	 , 07,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Transp"    	  ,"TRANS"   ,""	 , 06,0,"","" ,"C","",""})
		Aadd(aHInterface,{"UF Placa"      ,"UFPLC"   ,""	 , 02,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Granjada"      ,"GRJD"    ,""	 , 04,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Produto"       ,"PROD"    ,""	 , 10,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Tes"       	  ,"TES"     ,""	 , 05,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Vl Unit"       ,"VLRUNT"  ,"@E 999,999,999.999999"	 , 18,6,"","" ,"N","",""})
		Aadd(aHInterface,{"Valor"         ,"VLR"     ,"@E 999,999,999.999999"	 , 18,6,"","" ,"N","",""})
		Aadd(aHInterface,{"NF Ori"        ,"NFORI"   ,""	 , 09,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Ser Ori"       ,"SRORI"   ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Erro"          ,"ERR"     ,""	 , 100,0,"","","C","",""})
		Aadd(aHInterface,{"TPRAD"         ,"TPRAD"   ,""	 , 001,0,"","","C","",""})
		
		//Cria objeto MsNewGetDados(Grid).
		oRegistros := MsNewGetDados():New(055,004,165,545,,"Allwaystrue()","Allwaystrue()","",aAltInterface,Nil,999,Nil,Nil,Nil,oInterface,aHInterface,@aColsInterface)
		
	//Preenche o MsNewGetDados.
	oInterface:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") })
	
	//Restaura áreas de trabalho.
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} enviStComp
	Cria pergunta na SX1.
	@type  Static Function
	@author Everson
	@since 07/04/2017
	@version 01
/*/
Static Function enviStComp()

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cUpdate	:= ""
	
	//
	cUpdate := ""
	cUpdate += " UPDATE PED SET STATUS_PRC= CASE WHEN SC5.D_E_L_E_T_ = '' THEN 'S' ELSE 'N' END, STATUS_INT='' " 
	cUpdate += " FROM SGPED010 PED WITH(NOLOCK) " 
	cUpdate += " INNER JOIN " + RetSqlName("SC5") + " SC5 WITH(NOLOCK) ON PED.C5_FILIAL = SC5.C5_FILIAL COLLATE Latin1_General_CI_AS AND PED.C5_NUM = C5_PEDSAG COLLATE Latin1_General_CI_AS  AND PED.C5_CLIENTE = SC5.C5_CLIENTE COLLATE Latin1_General_CI_AS  AND PED.C5_LOJACLI = SC5.C5_LOJACLI COLLATE Latin1_General_CI_AS  AND PED.TABEGENE = SC5.C5_TABEGEN COLLATE Latin1_General_CI_AS  " 
	cUpdate += " INNER JOIN " + RetSqlName("SC6") + " SC6 WITH(NOLOCK) ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_CLIENTE = C6_CLI AND SC5.C5_LOJACLI = C6_LOJA  AND PED.CODIGENE = SC6.C6_XCODIGE " 
	cUpdate += " INNER JOIN " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) ON SC6.C6_FILIAL = C9_FILIAL AND SC6.C6_NUM = C9_PEDIDO AND SC6.C6_CLI = C9_CLIENTE AND SC6.C6_LOJA = C9_LOJA AND SC6.C6_ITEM = C9_ITEM AND SC6.C6_PRODUTO = C9_PRODUTO " 
	cUpdate += " WHERE SC5.C5_XLIBSAG = '1' AND PED.STATUS_PRC='A' AND SC5.C5_PEDSAG <> '' AND SC6.C6_XCODIGE <> '' AND SC9.C9_BLCRED = '' AND C9_BLEST = '' AND (SELECT COUNT(*) FROM SGPED010 PED2 WITH(NOLOCK) WHERE PED2.C5_NUM = PED.C5_NUM AND PED2.TABEGENE= PED.TABEGENE) = (SELECT COUNT(*) FROM " + RetSqlName("SC9") + " SC9 WITH(NOLOCK) WHERE SC6.C6_FILIAL = SC9.C9_FILIAL AND SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_CLI = SC9.C9_CLIENTE AND SC6.C6_LOJA = SC9.C9_LOJA AND SC9.D_E_L_E_T_ = '' AND SC9.C9_BLCRED = '' AND C9_BLEST = '') " 
	
	If TcSqlExec(cUpdate) < 0
		MsgStop("Não foi possível atualizar os status de liberação dos movimentos 'Saída por venda'","enviStComp(INTEPEDB)")
		
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} testConexao
	Valida conexão com o banco do SAG.
	@type  Static Function
	@author 14/12/2021
	@since 14/12/2021
	@version 01
/*/
Static Function testConexa(lConexao)

	//Variaveis.
	Local aArea    := GetArea()
	Local cQuery   := ""

	//Verificação se o linkedServer esta ativo
	cQuery := " SELECT * FROM OPENQUERY(SCSRV03, 'SELECT TOP(1) 1 AS CONEXAO FROM ADORO.dbo.VW_ADO_PESAGEM_FRETE_PROTHEUS') " 
	//

	If TcSqlExec(cQuery) < 0
		MsgStop("Não foi possível sincronizar com o banco de dados SAG por gentileza reiniciar o processo!!! Caso o problema persista entrar em contato com a T.I", "Erro acesso servidor SAG")
		lConexao := .F.
	Endif 

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} pendenciaNF
	Carregar dados de pedidos importados, mas não faturados. Chamado 033511.
	@type  Static Function
	@author 27/03/17
	@since 19/05/2020
	@version 01
/*/
Static Function pendenciaNF()

	//Variáveis.
	Local aArea		:= GetArea()
	//Local i			:= 1
	Local cQuery	:= ""
	Local nTotReg	:= 0
	Local cNome		:= ""
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
	Local oAzul		:= LoadBitmap( GetResources(), "BR_AZUL")
	//Local oBranco 	:= LoadBitmap( GetResources(), "BR_BRANCO")
	//Local oPreto	:= LoadBitmap( GetResources(), "BR_PRETO")
	//Local oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA")
	//Local oVioleta  := LoadBitmap( GetResources(), "BR_VIOLETA")
	Private lConexao := .T.
	//
	nQtdReg := 0
	MsAguarde({|| testConexa(@lConexao) },"Aguarde","Checando a conexão com o servidor 'SAG'...")
	
	oQtdReg:Refresh()
	
	//Apaga registros do aCols.
	oRegistros:aCols := {}
	oRegistros:Refresh()
	
	if lConexao
		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " TOP 100 C5_EMISSAO, C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, "
		cQuery += " C5_TIPO, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_LIBEROK, C5_NOTA, C5_BLQ, " 
		cQuery += " SUM(C6_QTDVEN) AS C6_QTDVEN, SUM(C6_VALOR) AS C6_VALOR, C5_TRANSP, C5_TPFRETE, C5_UFPLACA, C5_PEDSAG, C5_XLIBSAG, C5_NOTA, C5_SERIE " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += "  " + RetSqlName("SC6") + "  AS SC6 " 
		cQuery += " ON C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " WHERE " 
		cQuery += " SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ ='' " 
		cQuery += " AND C5_PEDSAG <> '' " 
		
		//
		If     cCombo2 == "1"
			cQuery += " AND C5_TABEGEN = 'PO02MVES' "
			
		ElseIf cCombo2 == "2"
			cQuery += " AND C5_TABEGEN = 'PO03MVES' "
			
		ElseIf cCombo2 == "3"
			cQuery += " AND C5_TABEGEN = 'POCAMVTP' "
			
		ElseIf cCombo2 == "4"
			cQuery += " AND ( C5_TABEGEN = 'PO01MVES' OR C5_TABEGEN = 'POCAMVES' ) "
			
		ElseIf cCombo2 == "5"
			cQuery += " AND C5_TABEGEN = 'EC03LOTE' "
			
		ElseIf cCombo2 == "6"
			cQuery += " AND C5_TABEGEN = 'FCCAORAP' "
			
		ElseIf cCombo2 == "7"
			cQuery += " AND C5_TABEGEN = 'PO11MVES' "
			
		ElseIf cCombo2 == "8"
			cQuery += " AND C5_TABEGEN = 'RACAORSA' "

		ElseIf cCombo2 == "9"
			cQuery += " AND C5_TABEGEN = 'XXXXXXXX' " //Everson - 17/09/2021. Chamado 31690.
			
		ElseIf cCombo2 == "10"
			cQuery += " AND C5_TABEGEN = 'PO14MVES' "
		
		ElseIf cCombo2 == "11"
			cQuery += " AND C5_TABEGEN = 'PO15MVES' "

		// @history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
		ElseIf cCombo2 == "12"
			cQuery += " AND C5_TABEGEN = 'PO16MVES' "
		//

		EndIf
		
		cQuery += " AND C5_NOTA = '' " 
		cQuery += " AND C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND C5_EMISSAO >= '" + DToS(dDataIni) + "' " 
		cQuery += " GROUP BY " 
		cQuery += " C5_EMISSAO,C5_FILIAL, C5_NUM, C5_CLIENTE,C5_LIBEROK, C5_NOTA, C5_BLQ, C5_TRANSP, C5_TPFRETE, C5_UFPLACA, " 
		cQuery += " C5_LOJACLI, C5_TIPO, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_PEDSAG, C5_XLIBSAG, C5_NOTA, C5_SERIE " 
		cQuery += " ORDER BY C5_NUM DESC " 
		
		//
		If Select("PED_NF") > 0
			PED_NF->(DbCloseArea())
			
		EndIf
		
		//Obtém dados do BD Interface.
		MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "PED_NF", .F., .T.)},"Função pendenciaNF(INTEPEDB)","Carregando registros...")
		
		DbSelectArea("PED_NF")
		PED_NF->(DbGoTop())
		
		//Obtém a quantidade de registros.
		nTotReg := Contar("PED_NF","!EOF()")

		//Configura a quantidade de registros na régua de processamento.
		ProcRegua(nTotReg)

		//
		If nTotReg <= 0

			// Gera linha em branco.
			fRegLin()
			
			/*
			Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
			oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= ""
			
			oRegistros:Refresh()
			*/
		Else
			
			//
			PED_NF->(DbGoTop())
			While ! PED_NF->(Eof())
				
				//Incrementa régua de processamento.
				IncProc("Pedido | " + Alltrim(cValToChar(PED_NF->C5_NUM)))
				
				If Alltrim(cValToChar(PED_NF->C5_TIPO)) $("B|D") //Pedido utiliza cadastro de fornecedor.
					cNome	:=  Posicione("SA2",1,xFilial("SA2") + Alltrim(cValToChar(PED_NF->C5_CLIENTE)) + Alltrim(cValToChar(PED_NF->C5_LOJACLI)),"A2_NOME")
					
				Else
					cNome	:=  Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(PED_NF->C5_CLIENTE)) + Alltrim(cValToChar(PED_NF->C5_LOJACLI)),"A1_NOME")
					
				EndIf

				//
				Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
				oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= DToC(SToD(Alltrim(cValToChar(PED_NF->C5_EMISSAO))))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"  })]  := "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STOPER"})]  := "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"   })]  := Alltrim(cValToChar(PED_NF->C5_CLIENTE))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"   })]  := Alltrim(cValToChar(PED_NF->C5_LOJACLI))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"   })]  := Alltrim(cValToChar(cNome))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"   })]  := Alltrim(cValToChar(PED_NF->C5_NUM))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLQC"})]    := Iif(Alltrim(cValToChar(PED_NF->C5_XLIBSAG)) == "1","Sim","Não")
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"})]   := Iif(blqCrEst(Alltrim(cValToChar(PED_NF->C5_NUM)),1),"Sim","Não")
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLFIN"})]   := Iif(blqCrEst(Alltrim(cValToChar(PED_NF->C5_NUM)),2),"Sim","Não")
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PEDS"})]    := Alltrim(cValToChar(PED_NF->C5_PEDSAG))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED" })]  := Alltrim(cValToChar(PED_NF->C5_TIPO))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TRANS"})]   := Alltrim(cValToChar(PED_NF->C5_TRANSP))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPFRT"})]   := Alltrim(cValToChar(PED_NF->C5_TPFRETE))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"   })]  := Alltrim(cValToChar(PED_NF->C5_PLACA))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "UFPLC"})]   := Alltrim(cValToChar(PED_NF->C5_UFPLACA))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"   })]  := Alltrim(cValToChar(PED_NF->C5_GRANJA))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"  })]  := Alltrim(cValToChar(PED_NF->C5_GRANJDA))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TES"})]   	:= "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLRUNT"})]  := 0
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PROD"})]   	:= "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"   })]  := Val(cValToChar(PED_NF->C6_VALOR))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"   })]  := Val(cValToChar(PED_NF->C6_QTDVEN))
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NFORI"})]   := "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SRORI"})]   := "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"   })]  := "-"
				oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPRAD"})]   := "-"

				//	    	
				If Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ) //Pedido aberto.
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVerde
					
				ElseIf ! Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ) //Pedido encerrado.
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVermelho
					
				ElseIf ! Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ) //Pedido aprovado.
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oAmarelo
					
				ElseIf C5_BLQ == '1' //Bloqueado por regra.
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oAzul
				
				ElseIf C5_BLQ == '2' //Bloqueado por verba.
					oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oLaranja
					
				EndIf

				//
				PED_NF->(DbSkip())
				nQtdReg++
				
			End
		
		EndIf
		
		//
		PED_NF->(DbCloseArea())
	
	else
		// Gera linha em branco.
		fRegLin()
	endif	
	

	oRegistros:Refresh()
	oQtdReg:Refresh()
	
	//
	RestArea(aArea)
	
Return Nil

Static function fRegLin()
	oRegistros:aCols := {}

	Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
	oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"  	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STOPER"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLQC"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLFIN"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PEDS"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED" 	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TRANS"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPFRT"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "UFPLC"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"  	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TES"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLRUNT"	})]  := 0
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PROD"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"   	})]  := 0
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"   	})]  := 0
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NFORI"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SRORI"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPRAD"	})]  := ""

	oRegistros:Refresh()
return

/*/{Protheus.doc} telProcess
	Funções de integração com o Faturamento.
	IDENTIFICADOR OPERAÇÃO SAG X PROTHEUS
	SAIDA POR DEVOLUÇÃO				SGPED010	PO02MVES	SEQ UNICO	Menu\PROTHEUS
	SAIDA POR TRANS. EMPRESA		SGPED010	PO03MVES	SEQ UNICO	Menu\PROTHEUS
	SAIDA POR TRANS. INTEGRADO		SGPED010	POCAMVTP	SEQ UNICO	Menu\PROTHEUS
	SAIDA POR VENDA					SGPED010	PO01MVES	SEQ UNICO	Menu\PROTHEUS
	FRANGO 3 TRANSMISSAO PROPRIEDADESGPED010	EC03LOTE	SEQ UNICO	Menu\PROTHEUS
	SAIDA FRANGO VIVO APANHA		SGPED010	FCCAORAP	SEQ UNICO	Menu\PROTHEUS
	@type  Static Function
	@author Microsiga
	@since 07/19/2013
	@version 01
/*/
Static Function telProcess(nOpc,lAut)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cSeqPed	:= ""
	Local i			:= 1
	Local aNFTrans	:= {}
	Local aPedInc	:= {}

	//
	Default lAut	:= .F.
	
	//
	If nOpc == 0
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - telProcess - Selecione uma opção diferente de '0 - Todos' no filtro para realizar a importação." )
		MsgStop("Selecione uma opção diferente de '0 - Todos' no filtro para realizar a importação.","Função telProcess(INTEPEDB)")
		RestArea(aArea)
		Return aNFTrans

	EndIf 

	//Everson - 17/09/2021. Chamado 31690. Validação de usuário de balança.
	If __CUSERID $(GetMv("MV_#USPORT",,"")) .And. ! (cValToChar(nOpc) $(GetMv("MV_#BALLB",,"")))
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - telProcess - Opção inválida." )
		MsgStop("Opção inválida.","Função telProcess(INTEPEDB)")
		RestArea(aArea)
		Return aNFTrans

	EndIf
	//

	// Gera PV
	MsAguarde({|| IntPedB(nOpc,@aPedInc,lAut) },"Função telProcess(INTEPEDB)","Importando pedido(s)...")
	
	//
	If ( lAut .And. Len(aPedInc) > 0 ) .Or.; //Everson - 26/05/2020. Chamado 058120.
		( nOpc <> 9 .And. nOpc <> 8 .And. Len(aPedInc) > 0 .And. MsgYesNo("Deseja emitir as notas fiscais para os pedidos importados?","Função telProcess(INTEPEDB)") )
		
		//Obtém os números dos pedidos do SAG.
		cSeqPed := ""
		For i := 1 To Len(aPedInc)
			cSeqPed += "'" + aPedInc[i][1] + "',"
			
		Next i
		
		//
		cSeqPed := Substr(cSeqPed,1,Len(cSeqPed) - 1)
		
		// Gera NF
		MsAguarde({|| aNFTrans := emitNfGrp(nOpc, "",cSeqPed,lAut) },"Aguarde","Emitindo nota(s) fiscal(is) de saída...")
		
	EndIf
	
	//
	RestArea(aArea)
	
Return aNFTrans

/*/{Protheus.doc} IntPedB
	
	@type  Static Function
	@author Microsiga
	@since 07/19/2013
	@version 01
/*/
Static Function IntPedB(nRadio,aPedInc,lAut)

	//Variáveis.
	Local aArea    		:= GetArea()
	Local cQry			:= ""
	Local cMens2 		:= ""
	Local cRotDesc		:= "Importação Pedidos - SAG"
	Local aDadosNFOri	:= ""
	Local lContLoopExt	:= .T.
	Local aCabec		:= {}
	Local aItens		:= {}
	Local cCli 			:= ""
	Local cFilPed		:= ""
	Local cNum			:= ""
	Local cOperacao		:= ""
	Local cTabGene		:= ""
	Local dData			:= Nil
	Local dDataB		:= Nil
	Local nRecPed		:= 0
	Local cChave 		:= "" 
	Local aCampo		:= {}
	Local lCanc			:= .F.
	Local cQryS			:= ""
	Local lItDupl   	:= .F.
	Local nItem     	:= "00"
	Local k				:= 1
	Local cCondPag 		:= "" //Everson - 17/05/2021. Chamado 13987.
	
	//
	Private cQueryP        	:= "" 
	Private cPnfOri 	   	:= ""
	Private	cPseriOri 	   	:= ""
	Private	cPforneceOri   	:= ""
	Private	cPLojaOri      	:= ""
	Private	cPItemOri      	:= ""
	Private cLocPad        	:= ""
	Private lMsErroAuto    	:= .F.
	Private lMsHelpAuto    	:= .T.
	Private lAutoErrNoFile 	:= .T.

	//
	Default lAut			:= .F.
	Default aPedInc	   		:= {}
	
	//Obtém o script sql.
	If nRadio <> 9 .And. nRadio <> 0
		cQry := ""
		cQry := sqlPedidos(nRadio,lAut)
		
		///////////////////////////////// // DEBUG - INIBIR
		//cQry += " AND C5_NUM IN ('S0679228','S0679230') " // DEBUG - INIBIR
		///////////////////////////////// // DEBUG - INIBIR

		If nRadio == 12
			cQry += " ORDER BY C6_TES" // ticket 8897 - FWNM - 23/02/2021
		Else		
			cQry += " ORDER BY " + Iif(!lAut,""," ORDENUME, ") + " CODIGENE, R_E_C_N_O_ " //Everson - 26/05/2020. Chamado 058120.
		EndIf
		
	ElseIf nRadio == 9
		Processa({||aTelPedAbert()},"Função IntPedB(INTEPEDB)","Ajustando quantidade dos pedidos de venda.")
		RestArea(aArea)
		Return Nil
			
	Else
		MsgStop("Nenhuma opção foi selecionada.","Função IntPedB(INTEPEDB)") //Incluido por Adriana para nao gerar error.log 
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Valida se o alias já existe.
	If Select("PED") > 0
		PED->(DbCloseArea())
		
	EndIf

	//
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "PED", .F., .T.)

	//Valida se há pedidos a serem importados.
	If PED->(Eof())
		MsgStop("Não há pedidos a serem importados.","Função IntPedB(INTEPEDB)")
		RestArea(aArea)
		Return Nil
		
	EndIf

	//Everson - 26/05/2020. Chamado 058120.
	If lAut
		libEst()

	EndIf
	
	//Converte os campos para data.
	TcSetField( "PED", "C5_DTENTR",  "D", 8, 0 )
	TcSetField( "PED", "C5_DATA1",   "D", 8, 0 )
	TcSetField( "PED", "C5_EMISSAO", "D", 8, 0 )
	
	//
	ProcRegua(Contar("PED","!Eof()"))
	PED->(DbGoTop())                              

	//
	While !PED->(Eof())

		//
		IncProc("Pedido " + Alltrim(cValToChar(PED->C5_NUM)))
		
		//
		lContLoopExt:= .T.
		aCabec		:= {}
		aItens		:= {}
		cCli  		:= Alltrim(cValToChar(PED->C5_CLIENTE)) + Alltrim(cValToChar(PED->C5_LOJACLI))
		cFilPed 	:= Alltrim(cValToChar(PED->C5_FILIAL))
		cNum		:= Alltrim(cValToChar(PED->C5_NUM))
		cOperacao 	:= Alltrim(cValToChar(PED->OPERACAO_INT))
		cTabGene	:= Alltrim(cValToChar(PED->TABEGENE))
		dData 		:= PED->C5_EMISSAO
		nRecPed   	:= PED->R_E_C_N_O_
		cChave    	:= PED->(C5_FILIAL + C5_NUM + OPERACAO_INT)
		
		//Obtém dados do cliente/fornecedor.
		If Upper(Alltrim(cValToChar(PED->C5_TIPO))) $("B|D") //Pedido utiliza cadastro de fornecedor.

			//
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1))
			SA2->(DbSeek( xFilial("SA2") + cCli))

			//			
			If ! SA2->(Eof())
				
				//
				If Alltrim(cValToChar(SA2->A2_MSBLQL)) == "1"
					erroProcess("Fornecedor bloqueado " + cCli + ".",cFilPed,cNum,"",cTabGene,cOperacao)
					MsgStop("Fornecedor bloqueado " + cCli + ". O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
					pularPedido(cChave)
					Loop
				
				EndIf
				
				//
				aCampo  := {{"A2_END", SA2->A2_END}, {"A2_EST", SA2->A2_EST}, {"A2_BAIRRO", SA2->A2_BAIRRO}, {"A2_CIDADE", SA2->A2_Mun}, {"A2_COND", SA2->A2_COND},  {"A2_COND", SA2->A2_COND}}
			
			Else

				//
				erroProcess("Não foi possível localizar o cadastro do fornecedor " + cCli + ".",cFilPed,cNum,"",cTabGene,cOperacao)
				MsgStop("Não foi possível localizar o cadastro do fornecedor " + cCli + ". O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
				
			EndIf
			
		Else //Pedido utiliza cadastro de cliente.

			//
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbSeek( xFilial("SA1") + cCli))
			
			//
			If ! SA1->(Eof())
				
				If Alltrim(cValToChar(SA1->A1_MSBLQL)) == "1"

					//
					erroProcess("Cliente bloqueado " + cCli + ".",cFilPed + ".",cNum,"",cTabGene,cOperacao)
					MsgStop("Cliente bloqueado " + cCli + ". O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
					pularPedido(cChave)
					Loop
				
				EndIf
		
				//Everson - 17/05/2021. Chamado 13987.
				DbSelectArea("DA0")
				DA0->(DbSetOrder(1))
				DA0->(DbGoTop())
				If ! DA0->( DbSeek( FWxFilial("DA0") + Sa1->A1_TABELA ) )
					//
					erroProcess("Não foi possível localizar a tabela de preço do cadastro do cliente " + cCli + ".",cFilPed + ".",cNum,"",cTabGene,cOperacao)
					MsgStop("Não foi possível localizar a tabela de preço do cadastro do cliente " + cCli + ". O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
					pularPedido(cChave)
					Loop

				EndIf
				//
		
				//
				aCampo  := {{"A1_END", Sa1->A1_END}, {"A1_EST", Sa1->A1_EST}, {"A1_BAIRRO", Sa1->A1_BAIRRO}, {"A1_CIDADE", Sa1->A1_Mun}, {"A1_COND", Sa1->A1_COND}}
				
			Else

				//
				erroProcess("Não foi possível localizar o cadastro do cliente " + cCli + ".",cFilPed + ".",cNum,"",cTabGene,cOperacao)
				MsgStop("Não foi possível localizar o cadastro do cliente " + cCli + ". O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
							
			EndIf
			
		EndIf
		
		//Verifica se já há pedido lançado no Protheus com o mesmo número do SAG.
		If ! Empty(cNum)
			
			//Monta script sql para verificar se o pedido já existe no Protheus.
			cQryS := ""
			cQryS += " SELECT C5_FILIAL, C5_NUM, C5_TABEGEN " 
			cQryS += " FROM " + RetSqlName("SC5") + " SC5 "
			cQryS += " WHERE " 
			cQryS += " SC5.D_E_L_E_T_ = '' "
			cQryS += " AND C5_FILIAL = '" + FWxFilial("SC5") + "' " 
			cQryS += " AND C5_PEDSAG = '" + cNum + "' " 
			cQryS += " AND LTRIM(RTRIM(C5_CLIENTE)) + LTRIM(RTRIM(C5_LOJACLI)) = '" + Alltrim(cValToChar(cCli)) + "' "
			cQryS += " AND C5_TABEGEN = '" + cTabGene + "' "
			
			//Verifica se o alias existe.
			If Select("CNFSEEK") > 0
				CNFSEEK->(DbCloseArea())
			
			EndIf
			
			//Executa consulta no BD Protheus.
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryS),"CNFSEEK", .F., .T.) 
			
			//
			DbSelectArea("CNFSEEK")
			CNFSEEK->(DbGoTop())
			If ! CNFSEEK->(Eof()) // Se achou registro no Protheus.
				
				If cOperacao == "E" //Se for operação de exclusão.
					
					//Função para definição de exclusão de pedido ou item do pedido.
					//Se for passado para exclusão todos os itens do pedido, o pedido será excluído.
					//Caso seja passado apenas um item, somente esse item será excluído.
					lCanc := .F.
					opExPedOuItem(Alltrim(cValToChar(CNFSEEK->C5_FILIAL)),Alltrim(cValToChar(CNFSEEK->C5_NUM)),cNum,Alltrim(cValToChar(CNFSEEK->C5_TABEGEN)),cOperacao,@lCanc)
					pularPedido(cChave)
					Loop
				
				//Se for operação de inclusão, mas já há pedido no Protheus correspondente ao pedido do SAG.
				//Se o usuário não confirmar a exclusão, o pedido do SAG não é integrado.
				Else
					
					//
					sucessoProcess(cFilPed,cNum,"",cTabGene,cOperacao)
					MsgStop("Já há no Protheus o pedido " + Alltrim(cValToChar(CNFSEEK->C5_NUM)) + " que faz referência ao pedido " + cNum + " do SAG.","Função IntPedB(INTEPEDB)")
					CNFSEEK->(DbCloseArea())
					pularPedido(cChave)
					Loop
				
				EndIf
			
			ElseIf CNFSEEK->(Eof()) .And. cOperacao == "E" // Se for exclusão, mas não encontrou o registro, desconsidera o mesmo e registra o log de erro.

				//
				erroProcess("",cFilPed,cNum,"",cTabGene,cOperacao)
				MsgStop("Não foi possível encontrar o pedido no Protheus referente ao pedido " + cNum + " do SAG para efetuar a exclusão.","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
				
			EndIf
			
			//
			CNFSEEK->(DbCloseArea())
			
			//Se conseguiu excluir, volta ao início e checa novamente o número do pedido no Protheus.
			If lCanc
				Loop
				
			EndIf
			
		EndIf

		//Valida a operação indicada. Somente operações de inclusão(I) e alteração(A) podem seguir o fluxo.
		If ! (Upper(cOperacao) $('A|I'))
			MsgStop("Não foi possível processar o pedido " + cNum + ", devido à operação indicada " + cOperacao + ".","Função IntPedB(INTEPEDB)")
			pularPedido(cChave)
			Loop
					
		EndIf
		
		Aadd( aCabec, { "C5_FILIAL"	 , PED->C5_FILIAL , Nil } )

		Aadd( aCabec, { "C5_TIPO"	 , PED->C5_TIPO   , Nil } )
		Aadd( aCabec, { "C5_CLIENTE" , PED->C5_CLIENTE, Nil } )
		Aadd( aCabec, { "C5_LOJACLI" , PED->C5_LOJACLI, Nil } )
		Aadd( aCabec, { "C5_LOJAENT" , PED->C5_LOJACLI, Nil } )
		
		//Se não há condição de pagamento no BD Interface, obtém no cadastro do cliente/fornecedor.
		If ! Empty(Alltrim(cValToChar(PED->C5_CondPag)))

			cCondPag := PED->C5_CondPag //Everson - 17/05/2021. Chamado 13987.
		
		Else
			cCondPag := aCampo[5,2] //Everson - 17/05/2021. Chamado 13987.
		
		EndIf
		//

		//Everson - 17/05/2021. Chamado 13987.
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1))
		SE4->(MsSeek(xFilial("SE4") + cCondPag))
		If SE4->(Eof())
			erroProcess("Reveja a condição de pagamento.",cFilPed,cNum,"",cTabGene,cOperacao)
			MsgStop("Por favor, reveja a condição de pagamento. O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
			pularPedido(cChave)
			Loop

		EndIf
		//
		
		//
		Aadd( aCabec, { "C5_CONDPAG", cCondPag   , Nil } )
		Aadd( aCabec, { "C5_ENDERE" , aCampo[1,2], Nil } )
		Aadd( aCabec, { "C5_EST"    , aCampo[2,2], Nil } )
		Aadd( aCabec, { "C5_BAIRRO" , aCampo[3,2], Nil } )
		Aadd( aCabec, { "C5_CIDADE" , aCampo[4,2], Nil } )
		Aadd( aCabec, { "C5_DTENTR" , PED->C5_DTENTR , Nil } )
		Aadd( aCabec, { "C5_EMISSAO", PED->C5_EMISSAO, Nil } )
		Aadd( aCabec, { "C5_MENNOTA", PED->C5_MENNOTA, Nil } )
		
		//Se os campos que indicam a granja e a granjada não estiverem vazios, estes são adicionados na mensagem da nota fiscal no Protheus.
		If ! Empty(PED->C5_GRANJA + PED->C5_GRANJDA )
			cGranja := "Granja.: " + PED->C5_GRANJA + " - Granjada.:" + PED->C5_GRANJDA + "   " + PED->C5_MENNOT2
			Aadd( aCabec, { "C5_MENNOT2", cGranja, Nil } )
			
		Else
			Aadd( aCabec, { "C5_MENNOT2", PED->C5_MENNOT2, Nil } )
			
		EndIf
		//

		//
		Aadd( aCabec, { "C5_GRANJA" , PED->C5_GRANJA, Nil })
		Aadd( aCabec, { "C5_GRANJDA", PED->C5_GRANJDA, Nil})
		
		//Tipo de frete (1 =  CIF, 2 = FOB, 0 = Sem frete)
		If Val(cValToChar(PED->C5_TPFRETE)) == 1
			
			//Valida se os campos de frete foram preenchidos.
			If Empty(Alltrim(cValToChar(PED->C5_PLACA))) .Or.;
			   Empty(Alltrim(cValToChar(PED->C5_TRANSP))) .Or. Empty(Alltrim(cValToChar(PED->C5_UFPLACA)))
			   
			   	//
				erroProcess("Verificar o preenchimento dos campos transportadora, placa e UF da placa.",cFilPed,cNum,"",cTabGene,cOperacao)
				MsgStop("Por favor, reveja se os campos transportadora, placa e UF da placa estão preenchidos. O pedido " + cNum + " não será integrado.","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
			
			EndIf
			
			Aadd( aCabec, { "C5_TPFRETE"  , "C", .F. } )
			Aadd( aCabec, { "C5_FRETE"    , PED->C5_FRETE  , .F. } )
			Aadd( aCabec, { "C5_PLACA"    , PED->C5_PLACA  , .F. } )
			Aadd( aCabec, { "C5_TRANSP"   , PED->C5_TRANSP , .F. } )
			Aadd( aCabec, { "C5_UFPLACA"  , PED->C5_UFPLACA, .F. } )
			
		ElseIf Val(cValToChar(PED->C5_TPFRETE)) == 2
			Aadd( aCabec, { "C5_TPFRETE"  , "F", .F. } )
			
		Else
			Aadd( aCabec, { "C5_TPFRETE"  , "S", .F. } )
			
		EndIf
		
		Aadd( aCabec, { "C5_PESOL"  , PED->C5_PESOL  , Nil } )
		Aadd( aCabec, { "C5_PESOTOT", PED->C5_PESOTOT, Nil } )
		Aadd( aCabec, { "C5_PEDSAG"	, cNum , Nil } )
		Aadd( aCabec, { "C5_PEDXML" , SubStr(cNum,2,10) , Nil } )
		Aadd( aCabec, { "C5_TABEGEN", PED->TABEGENE  , Nil } )
		Aadd( aCabec, { "C5_CODIGEN", PED->CODIGENE  , Nil } )
		
		//Everson - 16/03/2017. Chamado 033511.
		//Se for saída por venda, bloqueia o pedido no Protheus até que haja o ajuste de quantidades ("CORTE PEDIDO VENDA").
		If nRadio == 8
			Aadd( aCabec, { "C5_XLIBSAG", "1", Nil } )
			
		EndIf
		//
		
		//
		lItDupl   := .F.
		nItem     := "00"
		
		//Inicia processamento dos itens do pedido, para preenchimento do array de itens.
		While PED->(C5_FILIAL + C5_NUM + OPERACAO_INT) == cChave

			//
			nItem   := Soma1(nItem)
			aLinha  := {}
			cLocPad := ''
			
			//Valida se a nota de devolução possui nota e série de origem.
			If Alltrim(cValToChar(PED->C5_TIPO)) == "D" .And. ( Empty(Alltrim(cValToChar(PED->C6_NFORI))) .Or. Empty(Alltrim(cValToChar(PED->C6_SERIORI))))
				
				//
				lContLoopExt := .F.
				erroProcess("Registro não possui nota fiscal/série de origem vinculada.",cFilPed,cNum,"",cTabGene,cOperacao)
				MsgStop("O pedido " + cNum + " não será integrado, pois o pedido gerado será de devolução, mas o produto " +  Alltrim(cValToChar(PED->C6_PRODUTO)) + " não possui nota fiscal/série de origem vinculada.","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
							
			EndIf
				
			//Valida se o produto existe no Protheus e não está bloqueado.
			cPedBloq := Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + Alltrim(cValToChar(PED->C6_PRODUTO)),"B1_MSBLQL")))
			
			//
			If Empty(cPedBloq)

				//
				lContLoopExt := .F.
				erroProcess("Produto não cadastrado no Protheus. Entre em contato com o adm/financeiro/comercial!",cFilPed,cNum,"",cTabGene,cOperacao)
				MsgStop("O pedido " + cNum + " não será integrado, pois o produto " +  Alltrim(cValToChar(PED->C6_PRODUTO)) + " não está cadastrado no Protheus ","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
							
			ElseIf cPedBloq == "1"

				//
				lContLoopExt := .F.
				erroProcess("Produto bloqueado no Protheus. Entre em contato com o adm/financeiro/comercial!",cFilPed,cNum,"",cTabGene,cOperacao)
				MsgStop("O pedido " + cNum + " não será integrado, pois o produto " +  Alltrim(cValToChar(PED->C6_PRODUTO)) + " está bloqueado no Protheus ","Função IntPedB(INTEPEDB)")
				pularPedido(cChave)
				Loop
							
			EndIf
			
			//Ajusta o tamanho das decimais para não dar diferença no valor total do pedido.
			nQuant := Round(PED->C6_QtdVen,TamSX3("C6_QTDVEN")[2])
			
			//
			If PED->C6_QtdVen > 0.And. PED->C6_VALOR > 0
				
				//Recalcula o valor unitario para não dar diferença de arredondamento em relação ao SAG.				
				nTotal	 := Round(PED->C6_Valor    ,TamSX3("C6_VALOR")[2])
				
				nQuant   := Round(PED->C6_QtdVen   ,TamSX3("C6_QTDVEN")[2])
				
				nVlrUnit := Round((nTotal / nQuant),TamSX3("C6_PRCVEN")[2])
				
				If nRadio == 1 // Saída por devolução.
					nVlrUnit := PED->C6_PRCVEN
					
				EndIf

			Else // Se nao tiver valor unitario, procuro um valor médio no Protheus
				 // tem um problema de reprocessamento no SAG que só vai calcular o valor a noite
				 // por isso tive que fazer isso, pegando o custo medio do protheus
				
				//
				cProduto := PED->C6_PRODUTO
				
				//Busca o local padrao para pegar o custo do B2.
				cLocPad := ""
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1") + cProduto))
				If ! SB1->(Eof())
				
					// *** INICIO ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA *** //
		
					If ! RetArqProd(cProduto)
						cLocPad := POSICIONE("SBZ",1,xFilial("SBZ")+cProduto,"BZ_LOCPAD")
						
					Else
						cLocPad := POSICIONE("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD")
				
					EndIf
					
					// *** FINAL ALTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA *** //         
							
				EndIf
				
				// pego o custo do SB2 na filial de processamento, caso o custo esteja a zero
				// pego o custo na filial 03 que tem o maior numero de movimentos
				nVlrUnit := 0
				nTotal	 := 0
				DbSelectArea("SB2")
				SB2->(DbSetOrder(1))
				SB2->(DbSeek(xFilial("SB2")+cProduto+cLocPad))
				
				If ! SB2->(Eof()) .And. B2_CM1 > 0
					nVlrUnit := Round(B2_CM1,TamSX3("C6_PRCVEN")[2])
					nTotal   := nQuant * nVlrUnit
					nTotal   := Round(nTotal,TamSX3("C6_VALOR")[2])
					
				Else
					
					SB2->(DbSeek("03"+cProduto+cLocPad))
					If ! SB2->(Eof()) .And. B2_CM1 > 0
						nVlrUnit := Round(B2_CM1,TamSX3("C6_PRCVEN")[2])
						nTotal   := nQuant*nVlrUnit
						nTotal   := Round(nTotal,TamSX3("C6_VALOR")[2])
						
					Else
						SB2->(DbSeek("02"+cProduto+cLocPad))
						If ! SB2->(Eof()) .And. B2_CM1 > 0
							nVlrUnit := Round(B2_CM1,TamSX3("C6_PRCVEN")[2])
							nTotal   := nQuant*nVlrUnit
							nTotal   := Round(nTotal,TamSX3("C6_VALOR")[2])
							
						EndIf
						
					EndIf
					
				EndIf
				
			EndIf
			
			// ** INICIO REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //        
	        cQueryP := " SELECT A2_COD,A2_LOJA  "
	        cQueryP += "   FROM " + RetSqlName("SA1") + " , " + RetSqlName("SA2") + " "
	        cQueryP += "  WHERE A1_COD   = '" + PED->C5_CLIENTE + "'"
	        cQueryP += "    AND A1_LOJA  = '" + PED->C5_LOJACLI + "'"
	        cQueryP += "    AND A1_CGC   = A2_CGC "
	        
			DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryP), "TRA", .F., .T.) 
			
			cPnfOri 	 := ''
			cPseriOri 	 := ''
			cPforneceOri := ''
			cPLojaOri    := ''
		    cPItemOri    := ''
		    cLocPad      := ''
	        
	        While TRA->(! Eof())
	        
	        	cQueryP := " SELECT TOP(1)  D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_FORNECE,D1_LOJA, D1_ITEM,D1_LOCAL  "
		        cQueryP += "   FROM " + RetSqlName("SD1") + " "
		        cQueryP += "  WHERE D1_FILIAL   = '" + xFilial("SD1")                + "'"
		        cQueryP += "    AND D1_NFRURAL  = '" + STRZERO(VAL(PED->C6_NFORI),9) + "'"
		        cQueryP += "    AND D1_SRRURAL  = '" + PED->C6_SERIORI               + "'"
		        cQueryP += "    AND D1_FORNECE  = '" + TRA->A2_COD                   + "'"
		        cQueryP += "    AND D1_LOJA     = '" + TRA->A2_LOJA                  + "'"
		        cQueryP += "    AND D_E_L_E_T_ <> '*' "
		            
		        DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryP), "TRB", .F., .T.)
		        
		        While TRB->(!EOF())
		        
		        	cPnfOri 	 := TRB->D1_DOC
					cPseriOri 	 := TRB->D1_SERIE
					cPforneceOri := TRB->D1_FORNECE
					cPLojaOri    := TRB->D1_LOJA
		            cPItemOri    := TRB->D1_ITEM
		            cLocPad      := TRB->D1_LOCAL
		            
		            //recalcula o valor unitario para nao dar diferença de arredondamento em relação ao SAG.
					nVlrUnit := Round(PED->C6_PrcVen,TamSX3("C6_PRCVEN")[2])
					nTotal   := nQuant * nVlrUnit
					nTotal   := Round(nTotal,TamSX3("C6_VALOR")[2])
		            	      
		            TRB->(dbSkip())
				End
				
				TRB->(dbCloseArea())
	            TRA->(dbSkip())
	            
			End
			
			TRA->(dbCloseArea())
			
	        // ** FINAL REGRA NOTA PRODUTOR - WILLIAM COSTA 28/06/2016  CHAMADO - 028768 ** //
			
			Aadd( aLinha, { "C6_FILIAL"	 , PED->C5_FILIAL	, Nil } )
			Aadd( aLinha, { "C6_ITEM"	 , nItem			, Nil } )
			Aadd( aLinha, { "C6_PRODUTO" , PED->C6_PRODUTO	, Nil } )
			Aadd( aLinha, { "C6_UNSVEN"	 , nQuant			,0 , Nil } )
			Aadd( aLinha, { "C6_PRCVEN"	 , nVlrUnit			,0 , Nil } )
			Aadd( aLinha, { "C6_VALOR"	 , nTotal			,0 , Nil } )
			
			//
			If  Alltrim(cPnfOri) 	  <> '' .AND. ;
				Alltrim(cPseriOri) 	  <> '' .AND. ;
				Alltrim(cPforneceOri) <> '' .AND. ;
				Alltrim(cPLojaOri)    <> '' .AND. ;
			    Alltrim(cPItemOri)    <> '' .AND. ;
			    Alltrim(cValToChar(PED->C5_TIPO)) <> 'D'
			    
				Aadd( aLinha, { "C6_UNSVEN" , nQuant   ,0 , Nil } )
			    Aadd( aLinha, { "C6_PRCVEN" , nVlrUnit ,0 , Nil } )
			    Aadd( aLinha, { "C6_VALOR"  , nTotal   ,0 , Nil } )
				Aadd( aLinha, { "C6_QTDVEN" , nQuant   ,0 , Nil } )
			
			Else //  *** INICIO CHAMADO 033954 WILLIAM COSTA 09/03/2017	*** //
				
				lSegUnd := .F.
				
				cQueryQ := " SELECT B1_COD,B1_DESC,B1_MSBLQL,B1_CONV,B1_SEGUM,B1_UM,B1_TIPCONV "
	            cQueryQ += "   FROM "+RetSqlName("SB1") + " "
	            cQueryQ += "  WHERE B1_COD   = '" + PED->C6_PRODUTO + "'"
	            cQueryQ += "    AND D_E_L_E_T_ <> '*' "
	        
				DbUseArea(.t., "TOPCONN", TcGenQry(,, cQueryQ), "TRC", .F., .T.)
			
				While TRC->(! Eof()) 	                
	                	
		        	If Alltrim(TRC->B1_UM) <> '' .AND. Alltrim(TRC->B1_SEGUM) <> '' //garantir que tenha duas unidades de medida
		        		
		        		lSegUnd := .T.
		        		
			        	If Upper(Alltrim(TRC->B1_TIPCONV)) == 'D' //Divisor.
			                	
			            	nQtdConv := Int(nQuant / Iif(TRC->B1_CONV == 0,1,TRC->B1_CONV))

			            Else //Multiplicador.
			                	                                                    
			            	nQtdConv := Int(nQuant * Iif(TRC->B1_CONV == 0,1,TRC->B1_CONV))   
			                
						EndIf
						
					EndIf
					
					TRC->(dbSkip())
					
	            End   
	                                                              
	            TRC->(DbCloseArea())

		        If lSegUnd
		        	
		        	Aadd( aLinha, { "C6_QTDVEN" , nQuant                             ,0 , Nil } )
				    Aadd( aLinha, { "C6_PRCVEN" , nVlrUnit                           ,0 , Nil } )
				    Aadd( aLinha, { "C6_VALOR"  , nTotal                             ,0 , Nil } )
				    Aadd( aLinha, { "C6_UNSVEN" , Iif(nQtdConv > 0, nQtdConv,nQuant) ,0 , Nil } )
					Aadd( aLinha, { "C6_QTDLIB" , nQuant                             ,0 , Nil } )
		            Aadd( aLinha, { "C6_QTDLIB2", Iif(nQtdConv > 0, nQtdConv,nQuant) ,0 , Nil } )
		            
				//  *** FINAL CHAMADO 033954 WILLIAM COSTA 09/03/2017	*** //
			
				Else
			
					Aadd( aLinha, { "C6_UNSVEN"	, nQuant   ,0 , Nil } )
					Aadd( aLinha, { "C6_PRCVEN"	, nVlrUnit ,0 , Nil } )
					Aadd( aLinha, { "C6_VALOR"	, nTotal   ,0 , Nil } )
			
				EndIf
				
			EndIf
			
			//fernando sigoli 23/02/2017
			If Alltrim(PED->C5_TPINTPED) == 'TRANS' .OR. Alltrim(PED->C5_TPINTPED) == 'SOBRA' 	
			
				cLocPad	:= Alltrim(PED->C6_LOCAL)
			
			Else
			
				cLocPad  :=  Iif(Alltrim(cLocPad) <> '',cLocPad,Iif(! RetArqProd(PED->C6_PRODUTO),Posicione("SBZ",1,xFilial("SBZ")+PED->C6_PRODUTO,"BZ_LOCPAD"),Posicione("SB1",1,xFilial("SB1")+PED->C6_PRODUTO,"B1_LOCPAD")))
			
			EndIF   
			
			Aadd( aLinha, { "C6_TES"	 , PED->C6_TES	    , .F. } )
			Aadd( aLinha, { "C6_LOCAL"	 , cLocPad          , Nil } )
			Aadd( aLinha, { "C6_NFORI"   , cPnfOri	        , Nil } )
			Aadd( aLinha, { "C6_SERIORI" , cPseriOri	    , Nil } )
			Aadd( aLinha, { "C6_ITEMORI" , cPItemOri	    , Nil } )
			Aadd( aLinha, { "C6_PRUNIT"	 , nVlrUnit		 ,0 , Nil } )
			Aadd( aLinha, { "C6_XCODIGE" , PED->CODIGENE    , Nil } )
			
			//Se for pedido de devolução, são adicionados o número e série da nota de origem.
			If nRadio == 1
				
				//Obtém o item da nota fiscal de devolução.
				aDadosNFOri := obtItemNFOri(Alltrim(cValToChar(PED->C5_FILIAL)),;			//Filial.
										   Alltrim(cValToChar(PED->C5_CLIENTE)),;			//Fornecedor.
										   Alltrim(cValToChar(PED->C5_LOJACLI)),;			//Loja.
										   Padl(Alltrim(cValToChar(PED->C6_NFORI)),9,"0"),;	//Nota fiscal de origem.
										   Alltrim(cValToChar(PED->C6_SERIORI)),;			//Série da nota de origem.
										   Alltrim(cValToChar(PED->C6_PRODUTO)))			//Produto.
				
				//Valida o retorno da função posicione.			    
			    If Len(aDadosNFOri) == 0
					lContLoopExt := .F.
					erroProcess("Não foi possível localizar o item do produto no documento de entrada.",cFilPed,cNum,"",cTabGene,cOperacao)
			    	MsgStop("O pedido " + cNum + " não poderá ser integrado, pois não foi possível localizar o item/preço unitário no documento de entrada " +;
			    			 Padl(Alltrim(cValToChar(PED->C6_NFORI)),9,"0") + "/" +  Alltrim(cValToChar(PED->C6_SERIORI)) + ".","Função IntPedB")
					pularPedido(cChave)
					Loop
				    	
			    EndIf
			    //
			    
			    //Valida o preço unitário.
			    If Val(cValToChar(aDadosNFOri[1][2])) <> Val(cValToChar(nVlrUnit))
					lContLoopExt := .F.
					erroProcess("Preço unitário divergente do documento de entrada.",cFilPed,cNum,"",cTabGene,cOperacao)
			    	MsgStop("O pedido " + cNum + " não poderá ser integrado, pois o preço unitário está divergente do documento de entrada " +;
			    			 Padl(Alltrim(cValToChar(PED->C6_NFORI)),9,"0") + "/" +  Alltrim(cValToChar(PED->C6_SERIORI)) + ".","Função IntPedB")
					pularPedido(cChave)
					Loop
			    	
			    EndIf
			    //
			    
				Aadd( aLinha, { "C6_NFORI"	 , Padl(Alltrim(cValToChar(PED->C6_NFORI)),9,"0") , Nil } )
				Aadd( aLinha, { "C6_SERIORI" , PED->C6_SERIORI , Nil } )
				Aadd( aLinha, { "C6_ITEMORI" , Alltrim(cValToChar(aDadosNFOri[1][1])) , Nil } )
				
			EndIf
			//
			
			//Se for saída por venda, marca o registro como não tendo a quantidade ajustada.
			If nRadio == 8
				Aadd(aLinha, { "C6_XLIBSAG", "1", Nil })
			
			EndIf
			//
			
			//Verifica se há itens duplicados no pedido.
			If (aScan(aItens, {|Z|z[1][2] = aLinha[1][2] .And. z[2][2] = aLinha[2][2]  .And. z[3][2] = aLinha[3][2]  .And. z[4][2] = aLinha[4][2]  .And. z[5][2] = aLinha[5][2]  .And. z[6][2] = aLinha[6][2]})) <> 0

				lItDupl := .T.
				
				//Log interface Protheus x SAG.
				RecLock("ZA1",.T.)
					ZA1->ZA1_FILIAL  := PED->C5_FILIAL
					ZA1->ZA1_TABELA  := "PED"
					ZA1->ZA1_REGISTR := PED->R_E_C_N_O_
					ZA1->ZA1_ACAO    := PED->OPERACAO_INT
					ZA1->ZA1_DATA    := dDataBase
					ZA1->ZA1_HORA    := Time()
					ZA1->ZA1_MENSAG  := "O Pedido "+ PED->C5_NUM + " esta com itens duplicados. Verifique "
					ZA1->ZA1_USER    := SubStr(cusuario,7,15)
				ZA1->(MsUnLock())
				
				//
				lContLoopExt := .F.
				erroProcess("Há itens duplicados no pedido.",Alltrim(cValToChar(PED->C5_FILIAL)),Alltrim(cValToChar(PED->C5_NUM)),"",cTabGene,cOperacao)
				MsgStop("Há itens duplicados no pedido " + cNum + ". O pedido não poderá ser integrado.","Função IntPedB")
				pularPedido(cChave)
				Loop
				
			EndIf
			
			//Adiciona item no array de itens do pedido.
			Aadd(aItens, aLinha)
			
			PED->(DbSkip())
			
		End

		//		
		If ! lItDupl .And. lContLoopExt
		
			dDataB := dDataBase
			dDataBase := dData
			lMsErroAuto:=.F.
			
			Begin Transaction
				
				//Everson - 22/01/2019. Chamado 046622.       
				//aItens := FWVetByDic(aItens,"SC6",.T.,1)// comentado 07/02/2019
		         
				//Inicio: chamado:047017 07/02/2019 Fernando Sigoli
				IF nRadio = 2 // tratamento de ordenação de itens, quando tranferencia
			   
					aItens := FWVetByDic(aItens,"SC6",.T.,1)
				
				EndIf
				//Fim: chamado:047017 07/02/2019 Fernando Sigoli

				//
				VarInfo("aCabec " , aCabec)

				//
				MSExecAuto( { |x, y, z, p| mata410(x, y, z,,,,,,, p) }, aCabec, aItens, 3 ) 
				
				If lMsErroAuto //Apresentou erro na rotina padrão de inclusão de pedido de venda.
					
					DisarmTransaction()
					aErroLog:=GetAutoGrLog()
					cErro:=Alltrim(aErrolog[1])
					
					For k :=1 to Len(aErroLog)
						If "INVALIDO" $ UPPER (aErroLog[k])
							cErro+= "PV - "+"S-"+cNum+" - "+Alltrim(aErroLog[k])
						EndIf

					Next k
					
					//
					U_CCSGrvLog(cErro, "PED", nRecPed, 3, cFilPed)
					
					//
					TcSqlExec("UPDATE SGPED010 SET C5_MSEXP='" +DToS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' where C5_FILIAL ='"+SubStr(cChave,1,2)+"' AND C5_NUM='"+cNum+"' ")
					cMens2 := "Pedido : "+ cNum +"-"+cErro+ chr(13)+chr(10) + cMens2 + Chr(13) + Chr(10)
					
				Else
					
					//Todo registro que necessita ser novamente sincronizado no lado do SAG, deve ir com STATUS_INT = ''
					//If nRadio == 8 //Saída por venda. // @history Macieira, 18/02/2021, ticket 11804 - GRAVAR REGISTRO NO PROTHEUS para enviar ao SAG
					If nRadio == 8 .OR. nRadio == 12  // @history Macieira, 18/02/2021, ticket 11804 - GRAVAR REGISTRO NO PROTHEUS para enviar ao SAG
						TcSqlExec("UPDATE SGPED010 SET C5_MSEXP='" + DToS(DDATABASE) + "' ,STATUS_INT='', MENSAGEM_INT='"+SPACE(70)+ "' WHERE C5_FILIAL ='"+SubStr(cChave,1,2)+"' AND C5_NUM='"+cNum+"' ")
					
					Else
						TcSqlExec("UPDATE SGPED010 SET C5_MSEXP='" + DToS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='"+SPACE(70)+ "' WHERE C5_FILIAL ='"+SubStr(cChave,1,2)+"' AND C5_NUM='"+cNum+"' ")
						
					EndIf
					
					Aadd(aPedInc,{cNum})
				
				EndIF
				
			End Transaction
			
			dDataBase := dDataB
			
		EndIf
		
	End
	
	//
	If ! Empty(cMens2) .And. ! lAut
		cMens2 := 'Documentos NÃO Processados: ' + chr(13)+chr(10) + cMens2 + chr(13)+chr(10)
		U_TExTelaMen(cRotDesc,cMens2,"Arial",10,,.F.,.T.)
		
	EndIf
	
	//
	PED->(DbCloseArea())
	
	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} exclPedido
	Exclusão de pedido de venda.Chamado 033511.
	@type  Static Function
	@author Everson
	@since 21/08/2017
	@version 01
/*/
Static Function exclPedido(cFil,cNum)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .F.	
	
	//
	If ! MsgYesNo("Deseja excluir o pedido de venda " + cNum + ".","Função exclPedido(INTEPEDB)")
		RestArea(aArea)
		Return lRet
	
	EndIf
	
	//
	If uExcPedB(cFil,cNum)
		lRet := .T.
		MsgInfo("Pedido " + cNum + " excluído.","Função exclPedido")
		
	Else
		MsgStop("Pedido " + cNum + " não excluído.","Função exclPedido")
		
	EndIf
	
	//
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} corteMan
	Rotina para corte manual de produtos. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 21/08/2017
	@version 01
/*/
Static Function corteMan()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()	
	
	//
	MsAguarde({|| ajtBlPed() },"Aguarde","Verificando bloqueio de pedido...")
	
	//
	MsAguarde({|| MATA455() },"Aguarde","Acessando rotina lib estoque...")

	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} ajtBlPed
	Rotina para verificação de bloqueio de pedido por corte. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 19/05/2020
	@version 01
/*/
Static Function ajtBlPed()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lAux		:= .F.	
	Local cProdutos	:= GetMv("MV_#PDLIBC")
	Local cFil		:= ""
	Local cNum	:= ""
	Local nRec		:= 0
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " C5_FILIAL, C5_NUM, SC5.R_E_C_N_O_ AS REC  " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
	cQuery += " WHERE " 
	cQuery += " SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND C5_XLIBSAG = '1' " 
	cQuery += " AND C5_NOTA = '' " 
	cQuery += " ORDER BY " 
	cQuery += " C5_FILIAL, C5_NUM " 
	
	//
	If Select("CK_BQL") > 0
		CK_BQL->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CK_BQL"
	DbSelectArea("CK_BQL")
	CK_BQL->(DbGoTop())
	While ! CK_BQL->(Eof())
		
		//
		cFil    := Alltrim(cValToChar(CK_BQL->C5_FILIAL))
		cNum	:= Alltrim(cValToChar(CK_BQL->C5_NUM))
		nRec	:= Val(cValToChar(CK_BQL->REC))
		
		//
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		
		//
		lAux := .F.
		If SC6->(DbSeek(cFil + cNum))
		
			While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_FILIAL)) == cFil .And. Alltrim(cValToChar(SC6->C6_NUM)) == cNum
				
				If Alltrim(cValToChar(SC6->C6_PRODUTO)) $cProdutos
					
					//Remove bloqueio por corte do item do pedido de venda.
					Reclock("SC6",.F.)
						Replace C6_XLIBSAG With "2"
					MsUnlock()
				
				ElseIf ! (Alltrim(cValToChar(SC6->C6_PRODUTO)) $cProdutos) .And. SC6->C6_XLIBSAG = '1'
					lAux := .T.
					
				EndIf
				
				SC6->(DbSkip())
				
			End
			
		EndIf
		
		//Remove bloqueio por corte do pedido de venda.
		If ! lAux .And. nRec > 0
			
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			SC5->(DbGoTop())
			SC5->(DbGoTo(nRec))
			
			Reclock("SC5",.F.)
				Replace C5_XLIBSAG With "2"
			MsUnlock()		
		
		EndIf
	
		CK_BQL->(DbSkip())
		
	End
	
	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} PED_EDRG
	Editar registro pendente de importação no BD Interface.
	@type  Static Function
	@author Everson
	@since 11/04/2017
	@version 01
/*/
User Function PED_EDRG(cTpMov,cPedSAG) //Everson  - 09/06/2002, chamado 058847.

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lRetMod2	:= .F.
	Local cDescPrd	:= ""
	Local i			:= 1
	
	//
	Private nUsado		:= 0
	Private aHeader		:= {}
	Private aCols		:= {}
	Private cTitulo		:= "Edição de Pedido. (Pré-Importação)"
	Private aC			:= {}
	Private cFil		:= ""
	Private cEmissao	:= ""
	Private cNum		:= ""
	Private cCod		:= ""
	Private cLoja		:= ""
	Private aR			:= {}
	Private aCGD		:= {}
	Private aGetsD		:= {"C6_TES"}
	Private aButtons	:= {}	
	Private cUPdate		:= ""

	//
	Default cTpMov		:= ""
	Default cPedSAG		:= ""

	//
	If Empty(cTpMov)
		MsgStop("Não foi possível obter o tipo de saída do registro.","Função PED_EDRG(INTEPEDB)")
		RestArea(aArea)
		Return Nil
				
	ElseIf Empty(cPedSAG)
		MsgStop("Não foi possível obter o pedido do SAG do registro.","Função PED_EDRG(INTEPEDB)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//Obtém consulta.
	cQuery := sqlPedidos(Val(cTpMov))
	cQuery += " AND C5_NUM = '" + cPedSAG + "' "
	cQuery += " ORDER BY CODIGENE, R_E_C_N_O_ "
	
	//Valida se o alias existe.
	If Select("DADOS_EDIT") > 0
		DADOS_EDIT->(DbCloseArea())
		
	EndIf
	
	//Obtém dados do BD Interface.
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DADOS_EDIT", .F., .T.)},"Função PED_EDRG(INTEPEDB)","Carregando registros...")
	
	DbSelectArea("DADOS_EDIT")
	DADOS_EDIT->(DbGoTop())
	
	//Valida se houve retorno da consulta ao BD.
	If DADOS_EDIT->(Eof())
		MsgStop("Não foi possível obter os dados do registro.","Função PED_EDRG(INTEPEDB)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Monta aHeader.
	aHeader := montarHeader()
	If Len(aHeader) == 0
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	// Array com os campos do cabecalho.
	Aadd(aC,{"cFil"    , {20,002}, "Filial: "  , "@!", "",,.F.})
	Aadd(aC,{"cEmissao", {20,052}, "Emissão: " , "@!", "",,.F.})
	Aadd(aC,{"cNum"    , {20,160}, "Pedido: "  , "@!", "",,.F.})
	Aadd(aC,{"cCod"    , {20,250}, "Código: "  , "@!", "",,.F.})
	Aadd(aC,{"cLoja"   , {20,330}, "Loja: "    , "@!", "",,.F.})
	
	//Array com descrições dos campos do rodapé do Modelo 2.
	aR := {}

	//Array com coordenadas da GetDados do Modelo 2.
	aCGD := {60,5,118,315}
	
	//
	While ! DADOS_EDIT->(Eof())
		
		//Obtém o nome do produto.
		cDescPrd := Posicione("SB1",1,xFilial("SB1") + Alltrim(cValToChar(DADOS_EDIT->C6_PRODUTO)),"B1_DESC")
		
		//Variáveis do cabeçalho.
		cFil 	:= Alltrim(cValToChar(DADOS_EDIT->C5_FILIAL))
		cEmissao:= DToC(SToD(Alltrim(cValToChar(DADOS_EDIT->C5_EMISSAO))))
		cNum	:= Alltrim(cValToChar(DADOS_EDIT->C5_NUM))
		cCod	:= Alltrim(cValToChar(DADOS_EDIT->C5_CLIENTE))
		cLoja	:= Alltrim(cValToChar(DADOS_EDIT->C5_LOJACLI))
		
		Aadd(aCols,{;
					DADOS_EDIT->C6_PRODUTO,;
					cDescPrd,;
					DADOS_EDIT->C6_PRCVEN,;
					DADOS_EDIT->C6_VALOR,;
					DADOS_EDIT->C6_QTDVEN,;
					DADOS_EDIT->C6_TES,;
					DADOS_EDIT->CODIGENE,;
				    .F.})
		
		DADOS_EDIT->(DbSkip())
		
	End
	
	//Obtém o retorno da função Modelo2.
	lRetMod2 :=	Modelo2(cTitulo,aC,aR,aCGD,4,Nil,Nil,aGetsD,Nil,Nil,12,Nil,.F.,.T.,aButtons)
	
	//	
	If lRetMod2 //Confirmou.
	
		For i := 1 To Len(aCols)
		
			cUPdate := " UPDATE SGPED010 SET C6_TES = '" + cValToChar(aCols[i][6]) + "' WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND C5_NUM = '" + cNum + "' AND C6_PRODUTO = '" + cValToChar(aCols[i][1]) + "' AND CODIGENE = '" + cValToChar(aCols[i][7]) + "' "
			
			TcSqlExec(cUPdate)
			
			MsAguarde({|| pendenciaNF(), oRdTab:SetOption(1) },"Função PED_EDRG(INTEPEDB)","Carregando registros...")
		
		Next i
	
	EndIf
	
	//
	DADOS_EDIT->(DbCloseArea())
	
	//
	RestArea(aArea)
		
Return Nil

/*/{Protheus.doc} montarHeader
	Monta aHeader da para função PED_EDRG. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 11/04/2017
	@version 01
/*/
Static Function montarHeader()

	//Variáveis.
	Local aArea		:= GetArea() 
	Local aCabecalho:= {}
	
	//Montando aHeader.
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	If ! SX3->(DbSeek("SC6"))
		MsgStop("Não foi possível montar o cabeçalho.","Função montarHeader")
		RestArea(aArea)
		Return aCabecalho
		
	EndIf

	While ! SX3->(Eof()) .And. (X3_ARQUIVO == "SC6")
	
		If (AllTrim(X3_CAMPO) = "C6_PRODUTO" .Or.;
			AllTrim(X3_CAMPO) = "C6_DESCRI"  .Or.;
		    AllTrim(X3_CAMPO) = "C6_QTDVEN"  .Or.;
		    AllTrim(X3_CAMPO) = "C6_PRCVEN"  .Or.;
		    AllTrim(X3_CAMPO) = "C6_VALOR"	 .Or.;
		    AllTrim(X3_CAMPO) = "C6_TES"     .Or.;
		    AllTrim(X3_CAMPO) = "C6_XCODIGE") .And. X3USO(X3_USADO)
		   
			nUsado++
			Aadd(aCabecalho,{;
							AllTrim(x3_titulo), AllTrim(x3_campo), x3_picture,;
							x3_tamanho, x3_decimal,"AllwaysTrue()",; //Everson  - 09/06/2002, chamado 058847.
							x3_usado, x3_tipo, x3_arquivo, x3_context;
			})
			
		EndIf
		
		SX3->(DbSkip())
		
	End
	
	//Restaura áreas de trabalho.
	RestArea(aArea)
	
Return aCabecalho

/*/{Protheus.doc} altDadosGrid
	Lengenda de saídas. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 27/03/2017
	@version 01
/*/
Static Function altDadosGrid(nOpc)

	// @history Macieira, 11/02/2021, ticket 9352 - variable is not an object on ALTDADOSGRID(INTEPEDB.PRW) 02/12/2020 16:55:06 line : 1774
	If oInterface = Nil
		oInterface:= MsDialog():Create()
		oInterface:cName     := "oInterface"
		oInterface:cCaption  := "Saídas - Processamentos Pendentes Protheus x SAG"
		oInterface:nLeft     := 34
		oInterface:nTop      := 222
		oInterface:nWidth    := 1100
		oInterface:nHeight   := 460
		oInterface:lShowHint := .F.
		oInterface:lCentered := .T.
	EndIf

	If oPnlBtn2 == Nil
		oPnlBtn2 := TPanel():New(035,145,"",oInterface,,.T.,,,,400,018)
	EndIf
	
	If oSBtn07 == Nil
		oSBtn07:= SButton():Create(oPnlBtn2)
		oSBtn07:cName := "oSBtn07"
		oSBtn07:cCaption := "Editar"
		oSBtn07:nLeft := 068
		oSBtn07:nTop := 005
		oSBtn07:nWidth := 50
		oSBtn07:nHeight := 20
		oSBtn07:lShowHint := .F.
		oSBtn07:lReadOnly := .F.
		oSBtn07:Align := 0
		oSBtn07:lVisibleControl := .F.
	EndIf
	//
	
	//Variáveis.
	
	//
	If nOpc == 1
		oDataIni:lVisibleControl := .T.
		oSBtn01:bAction := {||lngProth()}
		oSBtn04:lVisibleControl := .F.
		oPnlBtn1:lVisibleControl := .T.
		oPnlBtn2:lVisibleControl := .F.
		oSBtn07:lVisibleControl	:= .F.
		oSBtn03:bAction := {|| MsAguarde({|| enviStComp() },"Aguarde","Checando movimentos 'Saída por venda'..."), MsAguarde({|| pendenciaNF()},"Aguarde","Carregando registros...") }
		oCombo2:bChange := {|| pendenciaNF() }
		MsAguarde({|| enviStComp() },"Aguarde","Checando movimentos 'Saída por venda'...")
		MsAguarde({|| pendenciaNF()},"Aguarde","Carregando registros...")
		
	ElseIf nOpc == 2
		oDataIni:lVisibleControl := .F.
		oSBtn01:bAction := {||lngSaida()}
		oSBtn04:lVisibleControl := .T.
		oPnlBtn1:lVisibleControl := .F.
		oPnlBtn2:lVisibleControl := .T.
		oSBtn07:lVisibleControl	:= .T.
		oSBtn03:bAction := {|| MsAguarde({|| enviStComp() },"Aguarde","Checando movimentos 'Saída por venda'..."), MsAguarde({|| sCrgDado(cCombo2)},"Aguarde","Carregando registros...") }
		oCombo2:bChange := {|| MsAguarde({|| sCrgDado(cCombo2)},"Aguarde","Carregando registros...") }
		MsAguarde({|| enviStComp() },"Aguarde","Checando movimentos 'Saída por venda'...")
		MsAguarde({|| sCrgDado(cCombo2)},"Aguarde","Carregando registros...")

	EndIf
	
	oSBtn01:Refresh()
	oSBtn04:Refresh()
	
	oInterface:Refresh()
	
Return Nil

/*/{Protheus.doc} lngProth
	Lengenda de pedidos. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 03/03/2017
	@version 01
/*/
Static Function lngProth()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Local cTitulo := "Status pedido"
     Local aLegenda:= {}
     
     Aadd(aLegenda, {"BR_VERDE"    ,"Pedido em aberto"})
     Aadd(aLegenda, {"BR_VERMELHO" ,"Pedido encerrado"})
     Aadd(aLegenda, {"BR_AMARELO"  ,"Pedido liberado" })
     Aadd(aLegenda, {"BR_AZUL"     ,"Pedido bloqueado por regra"})
     Aadd(aLegenda, {"BR_LARANJA"  ,"Pedido bloqueado por verba" })
     
     BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil

/*/{Protheus.doc} lngSaida
	Lengenda de saídas. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 19/05/2020
	@version 01
/*/
Static Function lngSaida()

	//Variáveis.
    Local cTitulo := "Tipos de saídas"
    Local aLegenda:= {}
     
    Aadd(aLegenda, {"BR_VERMELHO" ,"Saída por devolução"})
    Aadd(aLegenda, {"BR_VERDE"    ,"Saída por trans. filial"})
    Aadd(aLegenda, {"BR_AMARELO"  ,"Saída por trans. integrado" })
     
    Aadd(aLegenda, {"BR_AZUL"     ,"Remessa para integrado"})
    Aadd(aLegenda, {"BR_BRANCO"   ,"Frango 3 transmissão propriedade"})
    Aadd(aLegenda, {"BR_PRETO"    ,"Saída frango vivo apanha" })
     
    Aadd(aLegenda, {"BR_PINK"     ,"Saída trans. armazém"})
    Aadd(aLegenda, {"BR_LARANJA"  ,"Saída por venda"})
    Aadd(aLegenda, {"BR_VIOLETA"  ,"Corte pedido de venda"})
     
    Aadd(aLegenda, {"BR_CINZA"    ,"Venda/Remessa  a ordem"})
    Aadd(aLegenda, {"BR_VERDE_ESCURO","Revenda"})
     
    BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil

/*/{Protheus.doc} blqCrEst
	Status pedido.
	@type  Static Function
	@author Everson
	@since 18/08/2017
	@version 01
/*/
Static Function blqCrEst(cNum,nOpc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .F.
		
	//
	cNum := Alltrim(cValToChar(cNum))
	If nOpc == 1
		cQuery := " SELECT C9_BLEST AS CAMPO FROM " + RetSqlName("SC9") + " AS SC9 WHERE SC9.D_E_L_E_T_ = '' AND C9_FILIAL = '" + cFilAnt + "' AND C9_PEDIDO = '" + cNum + "' "
	
	Else
		cQuery := " SELECT C9_BLCRED AS CAMPO FROM " + RetSqlName("SC9") + " AS SC9 WHERE SC9.D_E_L_E_T_ = '' AND C9_FILIAL = '"+ cFilAnt + "' AND C9_PEDIDO = '" + cNum + "' "
	
	EndIf
	
	//
	If Select("BL_PED") > 0
		BL_PED->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "BL_PED"
	BL_PED->(DbGoTop())
	
	If BL_PED->(Eof())
		
		lRet := .T.
		
	Else
	
		While ! BL_PED->(Eof())
	
			If ! Empty(Alltrim(cValToChar(BL_PED->CAMPO)))
				lRet := .T.
				Exit
				
			EndIf
			
			
			BL_PED->(DbSkip())
		
		End
	
	EndIf

	//
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} sCrgDado
	Carregar dados. 
	@type  Static Function
	@author Everson
	@since 03/03/2017
	@version 01
/*/
Static Function sCrgDado(nOpc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local cQuery	:= ""
	Local nTotReg	:= 0
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
	Local oAzul		:= LoadBitmap( GetResources(), "BR_AZUL")
	Local oBranco 	:= LoadBitmap( GetResources(), "BR_BRANCO")
	Local oPreto	:= LoadBitmap( GetResources(), "BR_PRETO")
	Local oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA")
	Local oVioleta  := LoadBitmap( GetResources(), "BR_VIOLETA")
	Local oCinza    := LoadBitmap(  GetResources(), "BR_CINZA")
	Local oVerdeEsc := LoadBitmap(  GetResources(), "BR_VERDE_ESCURO")
	Local cNome		:= ""
	Local cOper		:= ""
	//Local lChkPed	:= .F.
	Local nErroCad	:= 0
	
	//
	nQtdReg := 0
	oQtdReg:Refresh()
	
	//
	oRegistros:aCols := {}
	oRegistros:Refresh()
	
	//Opção para consulta no BD Interface.
	nOpc := Val(cValToChar(nOpc))
	
	//Apaga registros do aCols.
	oRegistros:aCols := {}

	//Opção para exibição de dados na grid.
	If nOpc > 0
		cQuery := ""
		cQuery += sqlPedidos(nOpc)
	
	Else
	
		//Obtém script sql.
		cQuery := ""
		For i := 1 To Len(aRadio)
			cQuery += sqlPedidos(i) + Chr(13) + Chr(10)
			
			If i < Len(aRadio)
				cQuery += " UNION ALL " + Chr(13) + Chr(10)
				
			EndIf
		
		Next i
	
	EndIf
	
	cQuery += " ORDER BY TP, CODIGENE, R_E_C_N_O_ "
	
	//Valida se o alias já existe.
	If Select("DADOSINT") > 0
		DADOSINT->(DbCloseArea())
		
	EndIf
	
	//Obtém dados do BD Interface.
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DADOSINT", .F., .T.)},"Aguarde","Carregando registros...")
	
	DbSelectArea("DADOSINT")
	DADOSINT->(DbGoTop())
	
	//Obtém a quantidade de registros.
	nTotReg := Contar("DADOSINT","!EOF()")

	//Configura a quantidade de registros na régua de processamento.
	ProcRegua(nTotReg)
	
	//
	If nTotReg <= 0
       
		Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
		oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STOPER"})]  := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"})]  	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]    	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLQC"})]    := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLFIN"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PEDS"})]    := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TRANS"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPFRT"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"   })]  := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "UFPLC"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PROD"})]   	:= ""
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"})]   	:= 0
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"})]   	:= 0
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TES"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLRUNT"})]  := 0
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NFORI"})]   := ""
	    oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SRORI"})]   := ""
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"})]   	:= ""
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPRAD"})]   := ""
        
    	oRegistros:Refresh()
	
	Else
		
		DADOSINT->(DbGoTop())
		While ! DADOSINT->(Eof())
			
			//Incrementa régua de processamento.
			IncProc("Pedido | " + Alltrim(cValToChar(DADOSINT->C5_NUM)))
			
			If     Alltrim(cValToChar(DADOSINT->OPERACAO_INT)) $("I|A") // Éverson - 09/03/2017. Chamado 033959.
				cOper := "Inclusão"
				
			ElseIf Alltrim(cValToChar(DADOSINT->OPERACAO_INT)) == "E"
				cOper := "Exclusão"
			
			Else	
				cOper := "Indef."
				
			EndIf
			
			//Obtém o nome do cliente ou fornecedor.
			If Alltrim(cValToChar(DADOSINT->C5_TIPO)) $("B|D") //Pedido utiliza cadastro de fornecedor.
				cNome	:=  Posicione("SA2",1,xFilial("SA2") + Alltrim(cValToChar(DADOSINT->C5_CLIENTE)) + Alltrim(cValToChar(DADOSINT->C5_LOJACLI)),"A2_NOME")
				
				If Empty(Alltrim(cValToChar(cNome)))
					cNome := ">>> ERRO FORNECEDOR NÃO LOCALIZADO!!!!!!!!!!!!!!  <<<"
					nErroCad++
					
				EndIf
				
			Else
				cNome	:=  Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(DADOSINT->C5_CLIENTE)) + Alltrim(cValToChar(DADOSINT->C5_LOJACLI)),"A1_NOME")
				
				If Empty(Alltrim(cValToChar(cNome)))
					cNome := ">>> ERRO CLIENTE NÃO LOCALIZADO!!!!!!!!!!!!!!  <<<"
					nErroCad++
					
				EndIf
				
			EndIf

			Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
			
			oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= DToC(SToD(Alltrim(cValToChar(DADOSINT->C5_EMISSAO))))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"  })]  := cOper
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STOPER"})]  := Alltrim(cValToChar(DADOSINT->STATUS_INT))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"   })]  := Alltrim(cValToChar(DADOSINT->C5_CLIENTE))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"   })]  := Alltrim(cValToChar(DADOSINT->C5_LOJACLI))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"   })]  := Alltrim(cValToChar(cNome))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"   })]  := "-"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLQC"  })]  := "-"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"})]   := "-"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLFIN"})]   := "-"
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PEDS"  })]  := Alltrim(cValToChar(DADOSINT->C5_NUM))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED" })]  := Alltrim(cValToChar(DADOSINT->C5_TIPO))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TRANS" })]  := Alltrim(cValToChar(DADOSINT->C5_TRANSP))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPFRT" })]  := Alltrim(cValToChar(DADOSINT->C5_TPFRETE))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"   })]  := Alltrim(cValToChar(DADOSINT->C5_PLACA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "UFPLC" })]  := Alltrim(cValToChar(DADOSINT->C5_UFPLACA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"   })]  := Alltrim(cValToChar(DADOSINT->C5_GRANJA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"  })]  := Alltrim(cValToChar(DADOSINT->C5_GRANJDA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PROD"  })]  := Alltrim(cValToChar(DADOSINT->C6_PRODUTO))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"   })]  := Val(cValToChar(DADOSINT->C6_VALOR))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TES"   })]  := Alltrim(cValToChar(DADOSINT->C6_TES))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLRUNT"})]  := Val(cValToChar(DADOSINT->C6_PRCVEN))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"   })]  := Val(cValToChar(DADOSINT->C6_QTDVEN))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NFORI" })]  := Alltrim(cValToChar(DADOSINT->C6_NFORI))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SRORI" })]  := Alltrim(cValToChar(DADOSINT->C6_SERIORI))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"   })]  := StrTran(StrTran(DADOSINT->MENSAGEM_INT,Chr(13)," "),Chr(10)," ")
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPRAD" })]  := Alltrim(cValToChar(DADOSINT->TP))
	    	
	    	If     Alltrim(cValToChar(DADOSINT->TP)) == "1"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVermelho
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "2"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVerde
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "3"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oAmarelo
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "4"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oAzul
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "5"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oBranco
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "6"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oPreto
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "7"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oPink
	    		
	        ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "8"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oLaranja

	        ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "9"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVioleta
	    		
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "10"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oCinza
	    	
	    	ElseIf Alltrim(cValToChar(DADOSINT->TP)) == "11"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVerdeEsc
	    				    		
	    	EndIf
	    	
	    	nQtdReg++
		
			DADOSINT->(DbSkip())
			
			oRegistros:Refresh()
			
		End
	
	EndIf
	
	DADOSINT->(DbCloseArea())
	
	oRegistros:Refresh()
	
	//Valida se há cadastro de cliente/fornecedor não localizado.
	If nErroCad > 0
		MsgAlert("Há código(s) de cliente(s) e/ou fornecedor(es) não localizados no cadastro do Protheus.","Função sCrgDado")
		
	EndIf
	
	//
	oQtdReg:Refresh()
	
	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} sqlPedidos
	Script sql de saída. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 03/03/2017
	@version 01
/*/
Static Function sqlPedidos(nRadio,lAut)

	//Variáveis.
	Local cQry		:= ""

	//
	Default lAut := .F. //Everson - 26/05/2020. Chamado 058120.
	
	If nRadio == 1 // SAIDA POR DEVOLUÇÃO				SGPED010	PO02MVES	SEQ UNICO	Menu\PROTHEUS
		cQry := " SELECT '1' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'PO02MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_TIPO = 'D' " 
	
	ElseIf nRadio == 2 // SAIDA POR TRANS. FILIAL		SGPED010	PO03MVES	SEQ UNICO	Menu\PROTHEUS
		cQry := " SELECT '2' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'PO03MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_TIPO = 'N' "
	
	ElseIf nRadio == 3 // SAIDA POR TRANS. INTEGRADO	SGPED010	POCAMVTP	SEQ UNICO	Menu\PROTHEUS
		cQry := " SELECT '3' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'POCAMVTP' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '"+FWxFilial("SC5")+"' "
	
	ElseIf nRadio == 4 // REMESSA PARA INTEGRADO		SGPED010	PO01MVES	SEQ UNICO	Menu\PROTHEUS

		//Everson - 26/05/2020. Chamado 058120.
		If lAut

			//
			cQry := ""
			cQry += " SELECT " 
			cQry += " '4' AS TP, * " 
			cQry += " FROM " 
			cQry += " SGPED010 " 
			cQry += " WHERE " 
			cQry += " ORDENUME IN " 
			cQry += " ( " 
			cQry += " SELECT  " 
			cQry += " ORDENUME " 
			cQry += " FROM  " 
			cQry += " SGPED010 A  " 
			cQry += " WHERE  " 
			cQry += " (TABEGENE = 'PO01MVES' OR TABEGENE = 'POCAMVES')  " 
			cQry += " AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E'))  " 
			cQry += " AND C5_FILIAL = '"+FWxFilial("SC5")+"'   " 
			cQry += " AND (OLDTABEGENE = '' OR OLDTABEGENE IS NULL)  " 
			cQry += " AND OLDCODIGENE = 0 " 
			cQry += " AND ISNULL(ORDENUME,'') <> '' " 
			cQry += " AND ULTIPESA = 'S' " 
			cQry += " ) " 

		Else
			cQry := " SELECT '4' AS TP, * FROM SGPED010 A WHERE (TABEGENE = 'PO01MVES' OR TABEGENE = 'POCAMVES') AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + FWxFilial("SC5") + "'  AND (OLDTABEGENE = '' OR OLDTABEGENE IS NULL) AND OLDCODIGENE = 0 "

		EndIf 
		//

	ElseIf nRadio == 5 // FRANGO 3 TRANSMISSAO PROPRIEDADE SGPED010	EC03LOTE	SEQ UNICO	Menu\PROTHEUS
		cQry := " SELECT '5' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'EC03LOTE' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '"+FWxFilial("SC5")+"'  "
	
	ElseIf nRadio == 6 // SAIDA FRANGO VIVO APANHA		SGPED010	FCCAORAP	SEQ UNICO	Menu\PROTHEUS
		cQry := " SELECT '6' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'FCCAORAP' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('I','E','A')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '"+FWxFilial("SC5")+"'  "

	ElseIf nRadio == 7 // Saída transferência para armazém.
		cQry := " SELECT '7' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'PO11MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E'))  AND C5_FILIAL = '"+FWxFilial("SC5")+"'  "

	ElseIf nRadio == 8 //Saída por venda.
		cQry := " SELECT '8' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'RACAORSA' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND (STATUS_PRC IN ('A','S')) AND C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_TIPO = 'N' "
	
	ElseIf nRadio == 9 //Corte de pedido de venda.
		cQry := " SELECT '9' AS TP, * "
		cQry += " FROM SGPED010 A WHERE TABEGENE = 'PO01MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ')) "
		cQry += " AND C5_FILIAL = '" + FWxFilial("SC5") + "'  AND OLDCODIGENE <> '' AND OLDTABEGENE <> '' "
	
	ElseIf nRadio == 10 //Conta de Ordem.
		cQry := " SELECT '10' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'PO14MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E'))  AND C5_FILIAL = '"+FWxFilial("SC5")+"' "
	
	ElseIf nRadio == 11//Revenda.
		cQry := " SELECT '11' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'PO15MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND (STATUS_PRC = 'A') AND C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_TIPO = 'N' "

	ElseIf nRadio == 12 // @history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
		cQry := " SELECT '12' AS TP, * FROM SGPED010 A WHERE TABEGENE = 'PO16MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E'))  AND C5_FILIAL = '"+FWxFilial("SC5")+"' AND C5_EMPRESA='"+cEmpAnt+"' " //+ " AND C5_NUM IN ('S0679228','S0679230') DEBUG INIBIR

	EndIf

Return cQry

/*/{Protheus.doc} pularPedido
	Desconsidera registros conforme o parâmetro.
	@type  Static Function
	@author Microsiga
	@since 28/03/2017
	@version 01
/*/
Static Function pularPedido(cChave)
	
	While ! PED->(Eof()) .And. PED->(C5_FILIAL + C5_NUM + OPERACAO_INT) == cChave
		PED->(DbSkip())
		
	End

Return Nil
/*/{Protheus.doc} opExPedOuItem
	Realiza exclusão do pedido de venda, ou do item do pedido. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 04/04/2017
	@version 01
	/*/
Static Function opExPedOuItem(cFil,cPedProth,cPedSAG,cTabegene,cOperacao,lCanc)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery1	:= ""
	Local cCodigenes:= ""
	Local cQuery2	:= ""
	Local i			:= 1
	Local aItensEx	:= {}
	Local nTotPedSC6:= 0
	
	//
	Private cMsgErro:= ""
	
	//Busca o pedido na tabela SC5.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->(DbSeek(cFil + cPedProth))
		MsgStop("Não foi possivel localizar o pedido " + cPedProth + " na tabela SC5.","Função opExPedOuItem(INTEPEDB)")
		sucessoProcess(cFil,cPedSAG,"",cTabegene,cOperacao)
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//Valida se o campo C5_NOTA (nota fiscal) está vazio.
	If ! Empty(Alltrim(cValToChar(SC5->C5_NOTA)))
		MsgStop("O campo nota fiscal do pedido " + cPedProth + " não está vazio (NF " + Alltrim(cValToChar(SC5->C5_NOTA)) + ") - tabela SC5. Não é possível excluir o pedido.","Função opExPedOuItem(INTEPEDB)")
		sucessoProcess(cFil,cPedSAG,"",cTabegene,cOperacao)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	cQuery1 := ""
	cQuery1 += " SELECT " 
	cQuery1 += " C6_XCODIGE AS CODIGENE " 
	cQuery1 += " FROM " 
	cQuery1 += " " + RetSqlName("SC5") + " AS SC5 " 
	cQuery1 += " INNER JOIN " 
	cQuery1 += " " + RetSqlName("SC6") + " AS SC6 " 
	cQuery1 += " ON C5_FILIAL = C6_FILIAL " 
	cQuery1 += " AND C5_NUM = C6_NUM " 
	cQuery1 += " WHERE " 
	cQuery1 += " SC5.D_E_L_E_T_ = '' " 
	cQuery1 += " AND SC6.D_E_L_E_T_ = '' " 
	cQuery1 += " AND C5_FILIAL = '" + cFil + "' " 
	cQuery1 += " AND C5_NUM = '" + cPedProth + "' "
	cQuery1 += " AND C5_PEDSAG = '" + cPedSAG + "' " 
	cQuery1 += " AND C5_NOTA = '' "
	cQuery1 += " AND C5_SERIE = '' "
	cQuery1 += " ORDER BY C6_XCODIGE " 
	
	//Verifica se o alias já existe.
	If Select("PEDEXCL") > 0
		PEDEXCL->(DbCloseArea())
		
	EndIf
	
	//Executa consulta no BD Protheus.
	TcQuery cQuery1 New Alias "PEDEXCL"
	DbSelectArea("PEDEXCL")
	PEDEXCL->(DbGoTop())
	
	//
	cCodigenes := ""
	While ! PEDEXCL->(Eof())
		
		//
		cCodigenes += "'" + Alltrim(cValToChar(PEDEXCL->CODIGENE)) + "',"
		
		//
		PEDEXCL->(DbSkip())
		
	End
	
	//
	PEDEXCL->(DbCloseArea())
	
	//Remove a última vírgula da string.
	cCodigenes := Substr(cCodigenes,1,Len(cCodigenes) - 1)
	
	//Valida retorno do BD Protheus.
	If Empty(cCodigenes)
		MsgStop("Não foi possível localizar o pedido " + cPedProth + "/" + cPedSAG + " no Protheus. O pedido/item não poderá ser excluído.","Função opExPedOuItem(INTEPEDB)")
		erroProcess("opExPedOuItem - Não foi possível localizar o pedido no Protheus.",cFil,cPedSAG,"",cTabegene,cOperacao)
		RestArea(aArea)
		Return Nil
		
	EndIf

	//	
	cQuery2 := ""
	cQuery2 += " SELECT * " 
	cQuery2 += " FROM SGPED010 A "
	cQuery2 += " WHERE "
	cQuery2 += " TABEGENE = '" + cTabegene + "' "
	cQuery2 += " AND C5_NUM = '" + cPedSAG + "' "
	cQuery2 += " AND C5_FILIAL = '" + cFil + "' "
	cQuery2 += " AND CODIGENE IN (" + cCodigenes  + ") "
	cQuery2 += " AND ((C5_MSEXP='' AND OPERACAO_INT IN ('E')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E'))
	cQuery2 += " ORDER BY CODIGENE "
	
	//
	If Select("PEDSAGEX") > 0
		PEDSAGEX->(DbCloseArea())
		
	EndIf
	
	//Valida retorno do BD Interface.
	TcQuery cQuery2 New Alias "PEDSAGEX"
	DbSelectArea("PEDSAGEX")
	PEDSAGEX->(DbGoTop())
	
	//Obtém todos os itens na interface.
	If PEDSAGEX->(Eof())

		//
		MsgStop("Não foi possível localizar o pedido " + cPedProth + "/" + cPedSAG + " na Interface. O pedido/item não poderá ser excluído.","Função opExPedOuItem(INTEPEDB)")
		sucessoProcess(cFil,cPedSAG,"",cTabegene,cOperacao)
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	While ! PEDSAGEX->(Eof())
		
		//
		Aadd(aItensEx,{CODIGENE})
		
		//
		PEDSAGEX->(DbSkip())
		
	End
	
	//
	PEDSAGEX->(DbCloseArea())
	
	//Valida se todos os itens da SC6 foram encontrados no array.
	//Exclui item.
	For i := 1 To Len(aItensEx)
		lRetEx   := .F.
		cMsgErro := ""
		MsAguarde({||lRetEx := excluiItem(cFil,cPedProth,Alltrim(cValToChar(aItensEx[i][1])),cOperacao,cPedSAG,cTabegene)},"Função opExPedOuItem(INTEPEDB)","Excluindo item codigene " + Alltrim(cValToChar(aItensEx[i][1])) + " do pedido " + cPedProth)
		
		If ! lRetEx
			erroProcess(cMsgErro,cFil,cPedSAG,Alltrim(cValToChar(aItensEx[i][1])),cTabegene,cOperacao)
			
		Else
			sucessoProcess(cFil,cPedSAG,Alltrim(cValToChar(aItensEx[i][1])),cTabegene,cOperacao)
			
		EndIf
		
	Next i
	
	//Busca itens na tabela SC6.
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	
	If ! SC6->(DbSeek(cFil + cPedProth))
		MsgStop("Não foi possível localizar o pedido " + cPedProth + "/" + cPedSAG + " no Protheus(SC6). O pedido/item não poderá ser excluído.","Função opExPedOuItem(INTEPEDB)")
		erroProcess("opExPedOuItem - Não foi possível localizar o pedido no Protheus(SC6).",cFil,cPedSAG,"",cTabegene,cOperacao)
		RestArea(aArea)
		Return Nil	
	
	EndIf
	
	//
	nTotPedSC6 := 0
	While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_FILIAL)) == cFil .And. Alltrim(cValToChar(SC6->C6_NUM)) == cPedProth
		
		//Soma a quantidade total do pedido.
		nTotPedSC6 += (Val(cValToChar(SC6->C6_QTDVEN)) + Val(cValToChar(SC6->C6_UNSVEN)))
		
		SC6->(DbSkip())
		
	End
	
	//Se total for zero, exclui o pedido de venda.
	If nTotPedSC6 == 0
		//Exclui o pedido do Protheus.
		
		//Apaga liberações do cabeçalho do pedido.
		RecLock("SC5",.F.)
			SC5->C5_LIBEROK := ""
			SC5->C5_BLQ		:= ""
		MsUnlock()
		
		//
		lCanc := .F.
		MsAguarde({||lCanc := uExcPedB(cFil,cPedProth)},"Função opExPedOuItem(INTEPEDB)","Excluindo pedido " + Alltrim(cValToChar(cPedProth)) + ".")
		
		//Se a operação era de exclusão e foi bem sucedida, registra log no BD Integração.
		If lCanc
			
			//Gera log de sucesso na SGPED010.
			For i := 1 To Len(aItensEx)
				sucessoProcess(cFil,cPedSAG,Alltrim(cValToChar(aItensEx[i][1])),cTabegene,cOperacao)
			
			Next i
			
		Else
			
			//Gera log de erro na SGPED010.
			For i := 1 To Len(aItensEx)
				erroProcess("Não foi possível excluir o pedido do Protheus.",cFil,cPedSAG,Alltrim(cValToChar(aItensEx[i][1])),cTabegene,cOperacao)
			
			Next i
			
		EndIf
		
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} excluiItem
	Exclui item do pedido de venda.
	@type  Static Function
	@author Everson
	@since 07/03/2017
	@version 01
	/*/
Static Function excluiItem(cFil,cPedProth,cCodigene,cOperacao,cPedSAG,cTabegene)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	
	//
	Private nVlrCred	:= 0
	
	cMsgErro := ""
	//Inicia transação.
	BeginTran()
	
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbGoTop())
		If ! SC5->(DbSeek(cFil + cPedProth))
			MsgStop("Não foi possivel localizar o pedido " + cPedProth + " na tabela SC5.","Função uExcPedB")
			cMsgErro := "excluiItem - Não foi possível localizar o pedido no Protheus(SC5)."
			DisarmTransaction() 
			MsUnlockAll()
			RestArea(aArea)
			Return .F.
			
		EndIf

		//Busca itens na tabela SC6.
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())	
		If ! SC6->(DbSeek(cFil + cPedProth))
			MsgStop("Não foi possível localizar o pedido " + cPedProth + "/" + cPedSAG + " no Protheus(SC6). O pedido/item não poderá ser excluído.","Função excluiItem")
			cMsgErro := "excluiItem - Não foi possível localizar o pedido no Protheus(SC6)."
			DisarmTransaction() 
			MsUnlockAll() 
			RestArea(aArea)
			Return .F.	
		
		EndIf
		
		While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_FILIAL)) == cFil .And. Alltrim(cValToChar(SC6->C6_NUM)) == cPedProth
			
			//Valida codigene.
			If Alltrim(cValToChar(SC6->C6_XCODIGE)) == cCodigene
			
				//Busca o pedido na tabela SC9.
				DbSelectArea("SC9")
				SC9->(DbSetOrder(1))
				SC9->(DbGoTop())
				If SC9->(DbSeek(cFil + cPedProth + Alltrim(cValToChar(SC6->C6_ITEM))))
					
					//Apaga o registro da SC9.
					Reclock("SC9",.F.)
						DbDelete()
					
					Msunlock()
							
				EndIf
				
				//Zera quantidade da tabela SC6.
				Reclock("SC6",.F.)
					Replace C6_QTDORI   With C6_QTDVEN
					Replace C6_QTDORI2  With C6_UNSVEN
					Replace C6_UNSVEN   With 0
					Replace C6_QTDVEN   With 0
					Replace C6_UNSVEN   With 0
					Replace C6_QTDLIB   With 0
					Replace C6_QTDLIB2  With 0
					Replace C6_VALOR    With 0
					Replace C6_QTDEMP   With 0
					Replace C6_QTDEMP2  With 0
					Replace C6_XLIBSAG	With Iif(! Empty(Alltrim(cValToChar(C6_XLIBSAG))),"2","")
				Msunlock()
				
			EndIf
			
			SC6->(DbSkip())
			
		End
	
	//Finaliza transação.
	EndTran()
		
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} uExcPedB
	Realiza exclusão do pedido de venda. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 07/03/2017
	@version 01
	/*/
Static Function uExcPedB(cFilPed,cNum)
	
	//Variáveis.
	Local aArea	 	:= GetArea()
	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local k 		:= 1
	Local lRet		:= .T.
	
	//
	Private nVlrCred	:= 0
	Private lMsErroAuto := .F.
	
	//Remove espaços em branco.
	cFilPed := Alltrim(cValToChar(cFilPed))
	cNum   := Alltrim(cValToChar(cNum))
	
	//Localiza pedido na tabela SC5.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->(DbSeek(cFilPed + cNum))
		MsgStop("Não foi possivel localizar o pedido " + cNum + " na tabela SC5.","Função uExcPedB(INTEPEDB)")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Valida se o campo C5_NOTA (nota fiscal) está vazio.
	If ! Empty(Alltrim(cValToChar(SC5->C5_NOTA)))
		MsgStop("O campo nota fiscal do pedido " + cNum + " não está vazio - tabela SC5. Não é possível excluir o pedido.","Função uExcPedB(INTEPEDB)")
		RestArea(aArea)	
		Return .F.
		
	EndIf
	
	//Localiza pedido na tabela SC6.
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	If ! SC6->(DbSeek(cFilPed + cNum))
		MsgStop("Não foi possivel localizar o pedido " + cNum + " na tabela SC6.","Função uExcPedB(INTEPEDB)")
		RestArea(aArea)
		Return .F.
			
	EndIf

	//Localiza o pedido na tabela SC9 e faz o estorno dos itens.
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())
	
	lRetSC9 := SC9->(DbSeek(cFilPed + cNum))
	
	If lRetSC9
	
		//Faz o estorno dos itens liberados.
		While Alltrim(cValToChar(SC9->C9_FILIAL)) == Alltrim(cValToChar(SC5->C5_FILIAL)) .And.;
		      Alltrim(cValToChar(SC9->C9_PEDIDO)) == Alltrim(cValToChar(SC5->C5_NUM))
			
			nVlrCred := 0
			SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))
			SC9->(DbSkip())
			
		End
	
	ElseIf ! lRetSC9 .And. Alltrim(cValToChar(SC5->C5_LIBEROK)) == "S"
		MsgStop("Não foi possivel estornar os itens do pedido " + Alltrim(cValToChar(SC5->C5_NUM)) + " na tabela SC9.","Função uExcPedB(INTEPEDB)")
		RestArea(aArea)
		Return .F.
				
	EndIf
	
	//Monta cabeçalho para exclusão do pedido de venda.
	Aadd( aCabec, { "C5_FILIAL"	 , SC5->C5_FILIAL	, Nil } )
	Aadd( aCabec, { "C5_NUM"	 , SC5->C5_NUM		, Nil } )
	Aadd( aCabec, { "C5_TIPO"	 , SC5->C5_TIPO		, Nil } )
	Aadd( aCabec, { "C5_CLIENTE" , SC5->C5_CLIENTE	, Nil } )
	Aadd( aCabec, { "C5_LOJACLI" , SC5->C5_LOJACLI	, Nil } )
	Aadd( aCabec, { "C5_LOJAENT" , SC5->C5_LOJAENT	, Nil } )
	Aadd( aCabec, { "C5_CONDPAG" , SC5->C5_CONDPAG	, Nil } )
	Aadd( aCabec, { "C5_ENDERE"  , SC5->C5_ENDERE	, Nil } )
	Aadd( aCabec, { "C5_EST"     , SC5->C5_EST		, Nil } )
	Aadd( aCabec, { "C5_BAIRRO"  , SC5->C5_BAIRRO	, Nil } )
	Aadd( aCabec, { "C5_CIDADE"  , SC5->C5_CIDADE   , Nil } )
	
	//Seleciona os itens do pedido de venda.
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbSeek(SC5->C5_FILIAL + SC5->C5_NUM))
	
	//Seleciona os itens do pedido.
	While ! SC6->(Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
	
		aLinha := {}
		
		//Aadd( aLinha, {"LINPOS","C6_ITEM",SC6->C6_ITEM})
		//Aadd( aLinha, {"AUTDELETA","N",Nil})

		Aadd( aLinha, { "C6_FILIAL"	 , SC6->C6_FILIAL												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_ITEM"	 , SC6->C6_ITEM					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_PRODUTO" , SC6->C6_PRODUTO				    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_QTDVEN"	 , SC6->C6_QTDVEN												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_PRCVEN"	 , SC6->C6_PRCVEN		            							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_VALOR"	 , SC6->C6_VALOR				    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_TES"	 , SC6->C6_TES					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_DESCRI"	 , SC6->C6_DESCRI											 	                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_UM"	 	 , SC6->C6_UM					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_LOCAL"	 , Iif(!RetArqProd(SC6->C6_PRODUTO),POSICIONE("SBZ",1,xFilial("SBZ")+SC6->C6_PRODUTO,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCPAD"))   , Nil } )
		Aadd( aLinha, { "C6_QTDEMP"	 , SC6->C6_QTDEMP												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_CF"	 	 , SC6->C6_CF					    						 	                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_CLI"	 , SC6->C6_CLI					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_ENTREG"	 , SC6->C6_ENTREG												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_LOJA"	 , SC6->C6_LOJA					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_PRUNIT"	 , SC6->C6_PRUNIT												                                                                                                   , Nil } )
		
		//Adiciona o Item do pedido de venda no array de itens.
		Aadd(aItens, aLinha)
		
		SC6->(DbSkip())
		
	End
	
	//Necessário excluir o codigene para poder excluir o pedido, devido à validação de pontos de entrada.
	RecLock("SC5",.F.)
		SC5->C5_CODIGEN := 0
		SC5->C5_PLACA	:= ""
	MsUnlock()
	
	//Inicia controle de transação.
	Begin Transaction
		
		//Faze exclusão do pedido de venda.
		MSExecAuto( { |x, y, z, p| mata410(x, y, z,,,,,,, p) }, aCabec, aItens, 5 ) //cOperacao 3 inclui, 4 altera, 5 exclui.
		
		If lMsErroAuto //Verifica se houve erro na exclusão do pedido de venda.
			
			//Desarma transação e obtém o log de erro.
			DisarmTransaction()
			aErroLog:=GetAutoGrLog()
			cErro:=Alltrim(aErrolog[1])
			
			For k := 1 to Len(aErroLog)
				If "INVALIDO" $ Upper(aErroLog[k])
					cErro+= "PV - S - "+cNum+" - "+Alltrim(aErroLog[k])
					
				EndIf   
				                                                                                
			Next k
			
			//Grava mensagem de erro no registro do pedido no BD Integração.
			If TcSqlExec("UPDATE SGPED010 SET C5_MSEXP='" + DToS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+ cErro + "' WHERE C5_FILIAL ='" + SubStr(cChave,1,2) + "' AND C5_NUM='" + cNum + "' ") < 0
				MsgAlert("Não foi possível lançar o erro abaixo no BD Integração. " + Chr(13) + Chr(10) + cErro + ".","Função uExcPedB(INTEPEDB)")
				
			EndIf
			
			MsgStop("Não foi possível excluir o pedido " + cNum + ".","Função uExcPedB(INTEPEDB)")
			lRet := .F.
			
		Else
			lRet := .T.
			
		EndIF
	
	//Finaliza controle de transação.
	End Transaction
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} aTelPedAbert
	Interface com os pedido pendentes de ajuste. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 04/04/2017
	@version 01
	/*/
Static Function aTelPedAbert()

	//Variáveis.
	Local aStru			:= {}
	Local aCpoBro 		:= {}
	Local oDlg			:= Nil 
	Local aButtons		:= {}
	Local oTemp			:= Nil //Everson - 26/05/2020. Chamado 058120.
	Local cAliasTP		:= ""
	Local cQuery		:= ""
	
	//
	Private lInverte 	:= .F.
	Private cMark   	:= GetMark()   
	Private oMark		:= Nil
	Private oTxt		:= Nil
	
	//Cria um arquivo de temporário.
	Aadd(aStru,{"OK"     ,"C"	,02		,0		})
	Aadd(aStru,{"FILIAL" ,"C"	,02		,0		})
	Aadd(aStru,{"EMISSAO","C"	,10		,0		})
	Aadd(aStru,{"PEDIDO" ,"C"	,06		,0		})
	Aadd(aStru,{"PEDIDOS","C"	,10		,0		})
	Aadd(aStru,{"COD"    ,"C"	,06		,0		})
	Aadd(aStru,{"LOJA"   ,"C"	,02  	,0		})
	Aadd(aStru,{"NOME"   ,"C"	,40		,2		})
	Aadd(aStru,{"PLACA"  ,"C"	,07		,0		})
	Aadd(aStru,{"TRANSP" ,"C"	,07		,0		})
	Aadd(aStru,{"STATUS" ,"C"	,01		,0		})

	//Everson - 26/05/2020. Chamado 058120.
	oTemp :=  FWTemporaryTable():New("TTRB")
	oTemp:SetFields(aStru)
	oTemp:AddIndex("indice1",{"FILIAL","PEDIDOS"})
	oTemp:Create()	
	
	//Obtém o script sql.
	cQuery := scriptImport(1,"")
	
	//
	cAliasTP := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTP, .F., .T.)	

	//
	(cAliasTP)->(DbGoTop())
	
	If (cAliasTP)->(Eof())
	
		DbSelectArea("TTRB")	
		RecLock("TTRB",.T.)	
			TTRB->FILIAL  := ""
			TTRB->EMISSAO := ""
			TTRB->PEDIDO  := ""
			TTRB->PEDIDOS := ""
			TTRB->COD     := ""		
			TTRB->LOJA    := ""
			TTRB->NOME    := ""				
			TTRB->PLACA   := ""
			TTRB->TRANSP  := ""
			TTRB->STATUS  := ""
		MsunLock()
	
	EndIf
	
	While ! (cAliasTP)->(Eof())
		
		//Popula o arquivo temporário.
		DbSelectArea("TTRB")	
		RecLock("TTRB",.T.)	
			TTRB->FILIAL  := (cAliasTP)->C5_FILIAL
			TTRB->EMISSAO := (cAliasTP)->C5_EMISSAO
			TTRB->PEDIDO  := (cAliasTP)->C5_NUM
			TTRB->PEDIDOS := (cAliasTP)->C5_PEDSAG
			TTRB->COD     := (cAliasTP)->C5_CLIENTE		
			TTRB->LOJA    := (cAliasTP)->C5_LOJACLI		
			TTRB->NOME    := (cAliasTP)->C5_NOMECLI				
			TTRB->PLACA   := (cAliasTP)->C5_PLACA
			TTRB->TRANSP  := (cAliasTP)->C5_TRANSP
			TTRB->STATUS  := (cAliasTP)->C5_XLIBSAG
		MsunLock()
		
		(cAliasTP)->(DbSkip())
		
	End

	//
	(cAliasTP)->(DbCloseArea())
	
	//Define quais colunas (campos da TTRB) serao exibidas na MsSelect.
	aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;
				{ "FILIAL"	 	,, "Filial"         ,"@!"},;
				{ "EMISSAO"	 	,, "Emissão"        ,"@!"},;			
				{ "PEDIDO"		,, "Pedido"         ,"@!"},;	
				{ "PEDIDOS"		,, "Pedido SAG"     ,"@!"},;
				{ "COD"			,, "Código"         ,"@!"},;			
				{ "LOJA"		,, "Loja"           ,"@!"},;			
				{ "NOME"		,, "Nome"           ,"@!"},;
				{ "TRANSP"		,, "Transp"         ,"@!"},;			
				{ "PLACA"		,, "Placa"   		,"@!"}}	
	
	
	//Cria interface.
	Define MsDialog oDlg Title "Pedidos em aberto" From 0,0 To 340,805 Pixel
		
		oTxt := TSay():New(005,001,{||"Selecione o pedido a ser processado"},oDlg,,,,,,.T.,CLR_RED,CLR_WHITE,250,20)
		
		DbSelectArea("TTRB")
		TTRB->(DbGotop())
		
		oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{17,1,150,405},,,,,)
 
		Aadd(aButtons,{"ANALITIC", {||ajustPed(.T.,"'" + Alltrim(cValToChar(TTRB->PEDIDO)) + "'")}, "Detalhes", "Detalhes" , {|| .T.}})  
		Aadd(aButtons,{"ANALITIC", {||apagRelSPed()}, "Cancelar Reg", "Cancelar Reg" , {|| .T.}} )  
	
	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{|| processArq(oDlg)},{|| oDlg:End()},,@aButtons,,,.F.,.F.,.F.,,.F.)
	
	//Fecha arquivo temporário.
	TTRB->(DbCloseArea())
	
	//Apaga arquivo temporário.
	oTemp:Delete()
	
Return Nil
/*/{Protheus.doc} apagRelSPed
	Apaga registros de corte sem pedido no Protheus. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 10/04/2017
	@version 01
	/*/ 
Static Function apagRelSPed(lAut)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aCodigente:= {}
	Local i			:= 1
	Local aRegExcl	:= {}
	
	Default lAut    := .F.
	
	//Solicita confirmação do usuário.
	If ! lAut
		If ! MsgYesNo("Esta rotina irá cancelar os registros referentes a corte de pedido venda em que " +;
		 			  "não há mais o pedido referenciado no Protheus, ou o pedido já esteja faturado. Deseja prosseguir?","Função apagRelSPed")
			RestArea(aArea)
			Return Nil
			
		EndIF
	
	EndIf
	
	//Monta script sql.
	cQuery := " SELECT * "
	cQuery += " FROM SGPED010 A WHERE TABEGENE = 'PO01MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','E','I')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ')) "
	cQuery += " AND C5_FILIAL = '" + cFilAnt + "'  AND OLDCODIGENE <> '' AND OLDTABEGENE <> '' "
	
	//Verifica se o alias já existe.
	If Select("REG_APG") > 0
		REG_APG->(DbCloseArea())
		
	EndIf
	
	//Executa consulta no BD Protheus.
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "REG_APG", .F., .T.)},"Aguarde","Carregando registros...")
	
	//Obtém os dados a serem marcados.
	DbSelectArea("REG_APG")
	REG_APG->(DbGoTop())
	
	While ! REG_APG->(Eof())
		
		Aadd(aCodigente,{REG_APG->CODIGENE,;
						 REG_APG->OPERACAO_INT,;
						 REG_APG->TABEGENE,;
						 REG_APG->C5_NUM})
	
		REG_APG->(DbSkip())
	End
	
	//
	REG_APG->(DbCloseArea())
	
	//Obtém o registros que devem ser excluídos.
	For i := 1 To Len(aCodigente)
		
		//Monta script sql.
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " C5_NUM, C5_PEDSAG, C5_TABEGEN " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC6") + " AS SC6 " 
		cQuery += " ON C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " AND C5_CLIENTE = C6_CLI " 
		cQuery += " AND C5_LOJACLI = C6_LOJA " 
		cQuery += " WHERE " 
		cQuery += " SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND C5_FILIAL = '" + cFilAnt + "' " 
		cQuery += " AND C6_FILIAL = '" + cFilAnt + "' " 
		cQuery += " AND C5_NOTA = '' "
		cQuery += " AND C5_SERIE = '' "
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 
		cQuery += " AND C5_TABEGEN = 'RACAORSA' " 
		cQuery += " AND C6_XCODIGE = '" + Alltrim(cValToChar(aCodigente[i][1])) + "' " 
		
		//Verifica se o alias já existe.
		If Select("PED_B") > 0
			PED_B->(DbCloseArea())
			
		EndIf
		
		TcQuery cQuery New Alias "PED_B"
		DbSelectArea("PED_B")
		
			If PED_B->(Eof())
				Aadd(aRegExcl,{cFilAnt,;
							   Alltrim(cValToChar(aCodigente[i][4])),;
							   Alltrim(cValToChar(aCodigente[i][1])),;
							   Alltrim(cValToChar(aCodigente[i][3])),;
							   Alltrim(cValToChar(aCodigente[i][2]))})
				
			EndIF
		
		PED_B->(DbCloseArea())
		
		
	Next i
	
	//Cancela os pedidos pendentes.
	For i := 1 To Len(aRegExcl)

		MsAguarde({||sucessoProcess(aRegExcl[i][1],; //Filial.
									aRegExcl[i][2],; //Pedido SAG.
									aRegExcl[i][3],; //Codigene.
									aRegExcl[i][4],; //Tabegene.
									aRegExcl[i][5],; //Operação.
									""); //Mensagem.
									},"Aguarde","Cancelando registro")
	
	Next i
	
	//Atualiza MsNewGetDados.
	If ! lAut
		MsAguarde({||sCrgDado(cCombo2)},"Aguarde","Carregando registros...")
	
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} processArq
	Obtém os números dos pedidos a serem processados. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 05/04/2017
	@version 01
	/*/
Static Function processArq(oDlg)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cPedidos	:= ""
	
	//
	DbSelectArea("TTRB")
	TTRB->(DbGoTop())
	
	While ! TTRB->(Eof())
		
		//Obtém os registros marcados.
		If ! Empty(Alltrim(cValToChar(TTRB->OK)))
			cPedidos += "'" + TTRB->PEDIDO + "',"
			
		EndIf
		
		TTRB->(DbSkip())
		
	End
	
	//Valida se há registros selecionados.
	If Empty(cPedidos)
		MsgStop("Não há registros selecionados.","Função processArq")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Encerra interface.
	oDlg:End()
	
	//Remove a última vírgula da string.
	cPedidos := Substr(cPedidos,1,Len(cPedidos) - 1)
	
	//Executa o ajuste de quantidades nos pedidos selecionados.
	ajustPed(.F.,cPedidos)
	
	//Restaura áreas de trabalho.
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} ajustPed
	Ajusta as quantidades na saída por venda. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 16/02/2017
	@version 01
	/*/
Static Function ajustPed(lVisualizar,cPedSelec)

	//Variáveis.		
	Local aArea	 	:= GetArea()
	Local cQuery1 	:= ""
	Local cQuery2 	:= ""
	Local aPedProtheus	:= {}
	//Local aRetAjust	:= {}
	Local i			:= 1
	Local aNvQuant	:= {}
	
	Local cFil		:= ""
	Local cPedProth	:= ""
	Local cRecSC9	:= ""
	Local cPedSag	:= ""
	Local cCodiGen	:= ""
	Local cItem		:= ""
	Local cProduto	:= ""
	Local cNomeCli	:= ""
	
	//Local cEof		:= Chr(13) + Chr(10)
	
	Local aPedErro	:= {}
	Local aPedSucess:= {}
	//Local cMsgFinal	:= ""
	Local cTabGene	:= ""
	
	//Remove espaços em branco.
	cPedSelec	:= Alltrim(cValToChar(cPedSelec))

	//Monta script sql.
	cQuery1 := scriptImport(2,cPedSelec)

	//Valida se o Alias já existe.
	If Select("AJUSTE") > 0
		AJUSTE->(DbCloseArea())
		
	EndIf
	
	//Preenche o vetor.
	TcQuery cQuery1 New Alias "AJUSTE"
	DbSelectArea("AJUSTE")
	AJUSTE->(DbGoTop())
	
	While ! AJUSTE->(Eof())
	
		If Alltrim(cValToChar(AJUSTE->C5_TIPO)) == "B"
			cNomeCli :=  Posicione("SA2",1,xFilial("SA2") + Alltrim(cValToChar(AJUSTE->C5_CLIENTE)) + Alltrim(cValToChar(AJUSTE->C5_LOJACLI)),"A2_NOME")
			
		Else
			cNomeCli :=  Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(AJUSTE->C5_CLIENTE)) + Alltrim(cValToChar(AJUSTE->C5_LOJACLI)),"A1_NOME")
			
		EndIf
		
		//Valida se não há bloquerio de crédito e estoque do item.
		If ! Empty(Alltrim(cValToChar(AJUSTE->C9_BLCRED))) .Or. ! Empty(Alltrim(cValToChar(AJUSTE->C9_BLEST)))
			MsgAlert("O produto " + Alltrim(cValToChar(AJUSTE->C6_PRODUTO)) + " do pedido " + Alltrim(cValToChar(AJUSTE->C5_NUM)) +;
			         " não terá sua quantidade ajustada no Protheus, pois está com bloqueio de estoque e/ou crédito.","Função ajustPed")
			 
			 AJUSTE->(DbSkip())
			 Loop
			 
		EndIf
		
		Aadd(aPedProtheus,{AJUSTE->C5_NUM,;		//1-Pedido Protheus.
						   AJUSTE->C5_PEDSAG,;	//2-Pedido SAG.
						   AJUSTE->C6_XCODIGE,; //3-Codigene.
						   AJUSTE->C6_ITEM,;	//4-Item.
						   AJUSTE->C6_PRODUTO,;	//5-Produto.
						   AJUSTE->C9_RECNO,;	//6-Recno SC9.
						   AJUSTE->C6_FILIAL,;	//7-Filial.
						   AJUSTE->C6_QTDVEN,;	//8-Quantidade.
						   AJUSTE->C5_CLIENTE,;	//9-Cliente.
						   AJUSTE->C5_LOJACLI,;	//10-Loja.
						   cNomeCli,;			//11-Nome.
						   AJUSTE->C5_TABEGEN})	//12-Tabegen.

		AJUSTE->(DbSkip())
		
	End
	
	//Obtém as quantidades corretas do pedido de venda no banco interface.
	For i := 1 To Len(aPedProtheus)
		
		//Carrega variáveis para obter novas quantidades no BD interface.
		cPedProth 	:= Alltrim(cValToChar(aPedProtheus[i][1]))
		cProduto	:= Alltrim(cValToChar(aPedProtheus[i][5]))
		cRecSC9		:= Alltrim(cValToChar(aPedProtheus[i][6]))
		cPedSag   	:= Alltrim(cValToChar(aPedProtheus[i][2]))
		cCodiGen  	:= Alltrim(cValToChar(aPedProtheus[i][3]))
		cFil		:= Alltrim(cValToChar(aPedProtheus[i][7]))
		cItem		:= Alltrim(cValToChar(aPedProtheus[i][4]))
		cQtdProth	:= Val(cValToChar(aPedProtheus[i][8]))
		cTabGene	:= Alltrim(cValToChar(aPedProtheus[i][12]))
	
		IncProc(" Obtendo novas quantidades | " + cPedProth + " " + cProduto)
		
		//Script sql para obter as novas quantidades do produto.
		cQuery2 := scriptCorte(cFilAnt,cPedSag,cCodiGen,cTabGene)
		
		If Select("NOVAQTD") > 0
			NOVAQTD->(DbCloseArea())
			
		EndIf
		
		//Executa consulta no BD Interface.
		TcQuery cQuery2 New Alias "NOVAQTD"
		
		DbSelectArea("NOVAQTD")
		NOVAQTD->(DbGoTop())
		
		While ! NOVAQTD->(Eof())
			
			Aadd(aNvQuant,{;
							   cFil,; 										// 1-Filial.
							   cPedProth,; 									// 2-Pedido Protheus.
							   cCodiGen,;  									// 3-Codigene.
							   cPedSag,;   									// 4-Pedido Sag primeiro registro.
							   cRecSC9,;   									// 5-Recno SC9.
							   Alltrim(cValToChar(NOVAQTD->C6_PRODUTO)),; 	// 6-Produto.
							   Val(cValToChar(NOVAQTD->C6_PRCVEN)),; 		// 7-Preço unitário de venda Protheus.
							   Val(cValToChar(NOVAQTD->C6_VALOR)),;  		// 8-Valor total do item.
							   Val(cValToChar(NOVAQTD->C6_QTDVEN)),; 		// 9-Quantidade.
							   cItem,; 										//10-Item.
							   cQtdProth,; 									//11-Quantidade Protheus.
							   Alltrim(cValToChar(NOVAQTD->C5_NUM)),; 		//12-Pedido Sag segundo registro.
							   Alltrim(cValToChar(aPedProtheus[i][9])),; 	//13-Código CliFor.
							   Alltrim(cValToChar(aPedProtheus[i][10])),; 	//14-Loja CliFor.
							   Alltrim(cValToChar(aPedProtheus[i][11])),; 	//15-Nome CliFor.
							   Alltrim(cValToChar(NOVAQTD->OPERACAO_INT)),;	//16-Operação a ser realizada.
							   Alltrim(cValToChar(NOVAQTD->TABEGENE)),;     //17-Tabegene.
							   Val(cValToChar(NOVAQTD->C6_PRCVEN)),;		//18-Preço unitário SAG.
							   Alltrim(cValToChar(NOVAQTD->C5_PLACA)),;		//19-Placa do veículo.
							   Alltrim(cValToChar(NOVAQTD->CODIGENE)),;		//20-Nova codigene.	
							   cTabGene,;									//21-Primeiro tabegene.
							   Alltrim(cValToChar(NOVAQTD->MENSAGEM_INT)),; //22-Mensagem de erro.	
							   Alltrim(cValToChar(NOVAQTD->C5_TRANSP)),;	//23-Transportadora.
							   NOVAQTD->C5_FRETE,;							//24-Valor do frete.
							   Alltrim(cValToChar(NOVAQTD->C5_UFPLACA)),;	//25-UF da placa.
							   Val(cValToChar(NOVAQTD->C5_TPFRETE));		//26-Tipo frete.
						   })								
			
			NOVAQTD->(DbSkip())
			
		End
		
	Next i
	
	//Cria interface com os pedidos que serão importados.
	If lVisualizar
		MsAguarde({||telPedCort(aNvQuant,aPedErro,aPedSucess)},"Aguarde","Criando interface.")
	
	Else //Efetua ajuste de quantidade do pedido.
		MsAguarde({||ok_Pedidos(aNvQuant,aPedErro,aPedSucess)},"Aguarde","Efetuando ajustes na quantidade do(s) pedido(s).")
	
	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} scriptImport
	Monta script sql para consulta de pedidos pendentes. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 04/04/2017
	@version 01
	/*/  
Static Function scriptImport(nCabec,cPedSelec)
	
	//Variáveis.
	Local cQuery1	:= ""
	
	//Remove espaços em branco.
	cPedSelec := Alltrim(cValToChar(cPedSelec))
	
	cQuery1 := ""
	cQuery1 += " SELECT   " 
	
	If nCabec == 1
		cQuery1 += " DISTINCT C5_FILIAL,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, "
		cQuery1 += " C5_PEDSAG, C5_TRANSP, C5_PLACA, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_XLIBSAG, C5_TABEGEN " 
	
	Else
		cQuery1 += " C6_FILIAL,C5_TABEGEN,C5_TIPO,C5_NUM,C5_PEDSAG,C5_CLIENTE,C5_LOJACLI,C6_XCODIGE,C6_ITEM,C6_PRODUTO,C6_QTDVEN,C9_BLCRED,C9_BLEST,SC6.R_E_C_N_O_ AS C6_RECNO, SC9.R_E_C_N_O_ AS C9_RECNO " 
		
	EndIf
	
	cQuery1 += " FROM    " 
	cQuery1 += " " + RetSqlName("SC5") + " AS SC5    " 
	cQuery1 += " INNER JOIN   " 
	cQuery1 += " " + RetSqlName("SC6") + " AS SC6   " 
	cQuery1 += " ON C5_FILIAL = C6_FILIAL   " 
	cQuery1 += " AND C5_NUM = C6_NUM " 
	cQuery1 += " AND C5_CLIENTE = C6_CLI " 
	cQuery1 += " AND C5_LOJACLI = C6_LOJA  " 
	
	cQuery1 += " INNER JOIN "
	cQuery1 += " " + RetSqlName("SC9") + " AS SC9 "
	cQuery1 += " ON C6_FILIAL = C9_FILIAL "
	cQuery1 += " AND C6_NUM = C9_PEDIDO "
	cQuery1 += " AND C6_CLI = C9_CLIENTE "
	cQuery1 += " AND C6_LOJA = C9_LOJA "
	cQuery1 += " AND C6_ITEM = C9_ITEM "
	cQuery1 += " AND C6_PRODUTO = C9_PRODUTO "
	
	cQuery1 += " WHERE    " 
	
	cQuery1 += " SC5.D_E_L_E_T_ = ''  " 
	cQuery1 += " AND SC6.D_E_L_E_T_ = ''   " 
	cQuery1 += " AND SC9.D_E_L_E_T_ = ''  "
	cQuery1 += " AND C5_XLIBSAG IN ('1','2') "
	cQuery1 += " AND C5_FILIAL = '" + cFilAnt + "' " 
	cQuery1 += " AND C5_PEDSAG <> '' "
	cQuery1 += " AND C6_XCODIGE <> '' "
	cQuery1 += " AND C6_XLIBSAG IN ('1','2') "
	cQuery1 += " AND C5_NOTA = '' "
	cQuery1 += " AND C5_SERIE = '' "
	
	If ! Empty(cPedSelec)
		cQuery1 += " AND C5_NUM IN (" + cPedSelec + ") "
	
	EndIf
	
	cQuery1 += " AND C9_BLCRED = '' "
	cQuery1 += " AND C9_BLEST = '' "
	cQuery1 += " AND C9_SERIENF = '' "
	cQuery1 += " AND C9_NFISCAL = '' "
	
	cQuery1 += " ORDER BY   " 
	
	If nCabec == 1
		cQuery1 += " C5_FILIAL, C5_NUM "
		
	Else
		cQuery1 += " C5_FILIAL, C5_NUM, C6_ITEM " 
	
	EndIf

Return cQuery1
/*/{Protheus.doc} scriptCorte
	Script sql dos registros de corte. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 10/04/2017
	@version 01
	/*/
Static Function scriptCorte(cFilAnt,cPedSag,cCodiGen,cTabGene)
	
	//Variáveis.
	Local cQuery2	:= ""
	
	//
	cQuery2 := ""
	cQuery2 += " SELECT * "
	cQuery2 += " FROM SGPED010 A WHERE TABEGENE = 'PO01MVES' AND ((C5_MSEXP='' AND OPERACAO_INT IN ('A','I','E')) OR (C5_MSEXP <> ' ' AND MENSAGEM_INT <> ' ' AND STATUS_INT='E')) "
	cQuery2 += " AND C5_FILIAL = '" + cFilAnt + "' AND C5_NUM <> '" + cPedSag + "' AND OLDCODIGENE = '" + cCodiGen + "' AND OLDTABEGENE = '" + cTabGene + "' "

Return cQuery2
/*/{Protheus.doc} telPedCort
	Interface com os pedidos que serão ajustados. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 17/03/2017
	@version 01
	/*/
Static Function telPedCort(aNvQuant,aPedErro,aPedSucess)
	
	//Variáveis.
	Local oInterPed
	Local aAltParam	:= {}
	Local aHPedidos		:= {}
	Local aColsPedidos	:= {}
	//Local oSBtn01
	Local oSBtn02
	Local oPedidos
	Local oGroup1
	
	//Cria objeto MsDialog.
	oInterPed:= MsDialog():Create()
	oInterPed:cName     := "oInterPed"
	oInterPed:cCaption  := "Registros que terão as quantidades ajustadas."
	oInterPed:nLeft     := 34
	oInterPed:nTop      := 222
	oInterPed:nWidth    := 1100
	oInterPed:nHeight   := 460
	oInterPed:lShowHint := .F.
	oInterPed:lCentered := .T.
	
	//
	oGroup1 := TGroup():Create(oInterPed,190,004,210,545,"",,,.T.)
	
	//Cria botão de cancelamento.
	oSBtn02:= SButton():Create(oInterPed)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Fechar"
	oSBtn02:nLeft := 1031
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 50
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {||oInterPed:End()}
	
	//Cria Header.
	Aadd(aHPedidos,{"Operação"     ,"OPER"    ,""	,01,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Filial"       ,"FILIAL"  ,""	,02,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"PED Protheus" ,"PEDPROT" ,""	,06,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"PED SAG Fin"  ,"PEDSAG"  ,""	,10,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"PED SAG Ajust","PEDSAG2"  ,""	,10,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Cliente"	   ,"CLI"     ,""	,06,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Loja"	       ,"LOJA"    ,""	,02,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Nome"	       ,"NOME"    ,""	,40,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Codigene"	   ,"CODIGENE",""	,10,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Produto"	   ,"PRODUTO" ,""	,10,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Item"	       ,"ITEM"    ,""	,01,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Qtd Protheus" ,"QTDPROT" ,""	,15,3,"","" ,"N","",""})
	Aadd(aHPedidos,{"Qtd Real"	   ,"QTDREAL" ,""	,15,3,"","" ,"N","",""})
	Aadd(aHPedidos,{"Diferença"	   ,"DIF"     ,""	,15,3,"","" ,"N","",""})
	Aadd(aHPedidos,{"Recno SC9"	   ,"RECNO"    ,""	,10,0,"","" ,"C","",""})
	Aadd(aHPedidos,{"Erro"	       ,"ERRO"    ,""	,70,0,"","" ,"C","",""})
	
	oPedidos := MsNewGetDados():New(005,004,180,545,,"Allwaystrue()","Allwaystrue()","",aAltParam,Nil,Len(aNvQuant),Nil,Nil,Nil,oInterPed,aHPedidos,@aColsPedidos)
	
	oInterPed:Activate(,,,.T.,{||.T.},,{||carregaPedidos(oPedidos,aHPedidos,aNvQuant)})

Return Nil
/*/{Protheus.doc} carregaPedidos
	Carrega registros na interface. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 17/03/2017
	@version 01
	/*/
Static Function carregaPedidos(oPedidos,aHPedidos,aNvQuant)
	
	//Variáveis.
	Local i := 1
	
	//Verifica se há registros a serem exibidos.
	If Len(aNvQuant) <= 0
		MsgInfo("Não há registros de ajuste.","Função carregaPedidos")
		Return Nil
		
	EndIf
	
	//Remove registro em branco da interface.
	oPedidos:aCols := {}
	
	//Preenche a interface com os registros que terão suas quantidades alteradas.
	For i := 1 To Len(aNvQuant)
		
		Aadd(oPedidos:aCols , Array(Len(aHPedidos)+1) )
		
		oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.
		
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "FILIAL"	})] := Alltrim(cValtoChar(aNvQuant[i][1]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "OPER" 	})] := Alltrim(cValtoChar(aNvQuant[i][16]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "PEDPROT" 	})] := Alltrim(cValtoChar(aNvQuant[i][2]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "PEDSAG"   })] := Alltrim(cValtoChar(aNvQuant[i][4]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "PEDSAG2"  })] := Alltrim(cValtoChar(aNvQuant[i][12]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "CLI"      })] := Alltrim(cValtoChar(aNvQuant[i][13]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "LOJA"     })] := Alltrim(cValtoChar(aNvQuant[i][14]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "NOME"     })] := Alltrim(cValtoChar(aNvQuant[i][15]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "CODIGENE"	})] := Alltrim(cValtoChar(aNvQuant[i][3]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "PRODUTO" 	})] := Alltrim(cValtoChar(aNvQuant[i][6]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "ITEM"     })] := Alltrim(cValtoChar(aNvQuant[i][10]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "QTDPROT"	})] := Val(cValToChar(aNvQuant[i][11]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "QTDREAL" 	})] := Val(cValToChar(aNvQuant[i][9]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "DIF"      })] := Val(cValToChar(aNvQuant[i][11])) - Val(cValToChar(aNvQuant[i][9]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "RECNO"    })] := Alltrim(cValtoChar(aNvQuant[i][5]))
		oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPedidos,{|x| AllTrim(x[2]) == "ERRO"     })] := Alltrim(cValtoChar(aNvQuant[i][22]))
		
	Next i
	
	//Atualiza o objeto msnewgetdados, para exibir os dados.
	oPedidos:Refresh()

Return Nil
/*/{Protheus.doc} ok_Pedidos
	Efetua ajuste nos pedidos de venda tabela SC9. Chamado 033511.
	@type  Static Function
	@author user
	@since 17/03/2017
	@version 01
	/*/
Static Function ok_Pedidos(aNvQuant,aPedErro,aPedSucess,cChave)

	//Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local cFil		:= ""
	Local cPedProth := ""
	Local cItem		:= ""
	Local cProduto	:= ""
	Local nNvQtd1	:= 0
	Local nNvQtd2	:= 0
	Local cSgUnMed	:= ""
	Local cTpConver := ""
	Local nConversor:= 0
	Local lRetCorte	:= .F.
	Local cNvPedSag	:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cC9Recno	:= ""
	
	Local cCodigene	:= ""
	Local cTabgene	:= ""
	Local cPlaca	:= ""
	Local oNvCodGene:= THashMap():New()
	Local cNvCodigene:= ""
	Local cPedSAGPr	:= ""
	Local cTabGenAnt:= ""
	Local lRePeso	:= .F.
	Local aLibCab	:= {}	
	Local cOperacao	:= ""
	
	//
	Private cMsgErro:= ""
	
	//Valida se há itens.
	If Len(aNvQuant) <= 0
		MsgStop("Não há dados a serem processsados.","Função telPedCort(INTEPEDB)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Efetua o corte de produtos na tabela SC9.
	For i := 1 To Len(aNvQuant)
		
		//Carrega variáveis com os dados a serem alterados.
		cMsgErro	:= ""
		cFil		:= aNvQuant[i][1]
		cPedProth 	:= aNvQuant[i][2]
		cItem		:= aNvQuant[i][10]
		cProduto	:= aNvQuant[i][6]
		nNvQtd1		:= aNvQuant[i][9]
		nNvQtd2		:= aNvQuant[i][9]
		cNvPedSag	:= aNvQuant[i][12]
		cCliente	:= aNvQuant[i][13]
		cLoja		:= aNvQuant[i][14]
		cC9Recno	:= aNvQuant[i][5]
		cCodigene	:= aNvQuant[i][3]
		
		cTabgene	:= aNvQuant[i][17]
		nPrcUntSAG	:= aNvQuant[i][18]
		
		cNvCodigene	:= aNvQuant[i][20]
		cPedSAGPr	:= aNvQuant[i][4]
		cTabGenAnt	:= aNvQuant[i][21]
		
		nTpFrt		:= Val(cValToChar(aNvQuant[i][26]))
		cTransp		:= aNvQuant[i][23]
		cPlaca		:= aNvQuant[i][19]
		cUFPlaca	:= aNvQuant[i][25]
		nVlFrt		:= Val(cValToChar(aNvQuant[i][24]))
		
		cOperacao	:= aNvQuant[i][16]
		
		//Obtém a segunda unidade de medida.
		cSgUnMed	:= Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_SEGUM")))
		
		//Verifica se há segunda unidade de medida.
		If ! Empty(cSgUnMed)
			
			//Obtém conversor e fator de conversor.
			cTpConver	:= Alltrim(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_TIPCONV")))
			nConversor	:= Val(cValToChar(Posicione("SB1",1,xFilial("SB1") + cProduto,"B1_CONV")))
			
			//Ajusta a quantidade da segunda unidade de medida.
			If Upper(cTpConver) == 'D'    	
            	nNvQtd2 := Int(nNvQtd1 / Iif(nConversor == 0,1,nConversor)) //Divisor.
            	
            Else	                                                    
            	nNvQtd2 := Int(nNvQtd1 * Iif(nConversor == 0,1,nConversor)) //Multiplicador.
                
			EndIf
		
		EndIf
		
		//Inicia transação.
		BeginTran()
		
			//Efetua corte do produto.
			MsAguarde({|| lRetCorte := cortaPed(cFil,cPedProth,cItem,cProduto,nNvQtd1,nNvQtd2,;
			                                    cNvPedSag,cCliente,cLoja,cC9Recno,nPrcUntSAG,;
			                                    nTpFrt,cTransp,cPlaca,cUFPlaca,nVlFrt,cOperacao)},"Aguarde","Corte pedido: " + cPedProth + " | produto: " + cProduto + "")
			
			//Valida se foi possível cortar a quantidade do produto.
			If ! lRetCorte
				DisarmTransaction() 
				MsUnlockAll() 

			EndIf

		//Finaliza transação.
		EndTran()
		
		If ! lRetCorte //Lança log de erro.
			erroProcess(cMsgErro,cFil,cNvPedSag,cNvCodigene,cTabgene,cOperacao) 
			Aadd(aPedErro,{cFil+cPedProth,cFil,cPedProth,cMsgErro})
			
		Else //Lança log de importação.
			sucessoProcess(cFil,cNvPedSag,cNvCodigene,cTabgene,cOperacao)
			Aadd(aPedSucess,{cFil,cPedProth,cNvPedSag,;
			                 cTabgene,cPlaca,cPedSAGPr,;
			                 cTabGenAnt,cOperacao,;
			                 nTpFrt,cTransp,cUFPlaca,nVlFrt})
			
		EndIf
		
		//Adiciona novo codigene.
		oNvCodGene:Set(cFil+cPedProth+cItem+cProduto,cNvCodigene)
	
	Next i
	
	//Zera variáveis.
	cNvPedSag 	:= ""
	cPedXml   	:= ""
	cTabGen   	:= ""
	cPlaca    	:= ""
	cPedSAGPr  	:= ""
	cTabGenAnt 	:= ""
	cMsgErro	:= ""
	
	//Ajuste na tabela SC5.
	For i := 1 To Len(aPedSucess)
	
		cFil 		:= Alltrim(cValToChar(aPedSucess[i][1]))
		cPedProth	:= Alltrim(cValToChar(aPedSucess[i][2]))
	
		//Verifica se o pedido já apresentou erro em algum item.
		If Ascan(aPedErro,{|x| Alltrim(cValToChar(x[1])) == cFil + cPedProth}) > 0
			Loop
			
		EndIf
	
		//Novos valores da tabela SC5.
		cNvPedSag := Alltrim(cValToChar(aPedSucess[i][3]))
		cPedXml   := Substr(cNvPedSag,2,Len(cNvPedSag))
		cTabGen   := Alltrim(cValToChar(aPedSucess[i][4]))
		cPedSAGPr := Alltrim(cValToChar(aPedSucess[i][6]))
		cTabGenAnt:= Alltrim(cValToChar(aPedSucess[i][7]))
		lRePeso	  := .F.
		cMsgErro  := ""
		cOperacao := Alltrim(cValToChar(aPedSucess[i][8]))
		
		cPlaca		:= Alltrim(cValToChar(aPedSucess[i][5]))
		nTpFrt		:= Val(cValToChar(aPedSucess[i][9]))
		cTransp		:= Alltrim(cValToChar(aPedSucess[i][10]))
		cUFPlaca	:= Alltrim(cValToChar(aPedSucess[i][11]))
		nVlFrt		:= Val(cValToChar(aPedSucess[i][12]))
		
		//Ajusta peso, volume e liberações na tabela SC5 dos pedidos que não apresentaram erro.
		MsAguarde({||lRePeso := pesoPedido(cFil,cPedProth,cNvPedSag,;
										   cPedXml,cPlaca,cTabGen,;
										   oNvCodGene,cPedSAGPr,cTabGenAnt,;
										   nTpFrt,cTransp,cUFPlaca,nVlFrt,cOperacao)},"Aguarde","Atualizando cabeçalho do pedido " + cPedProth + ".")
		
		//Valida se foi possível atualizar o cabeçalho do pedido.
		If lRePeso // Se não houve 
			Aadd(aLibCab,{cFil,cPedProth,cNvPedSag,cTabGen,cPlaca,cPedSAGPr,cTabGenAnt})
			
		Else //Se houve erro, adiciona o pedido no array de pedidos não ajustados e lança log no BD Integração..
			Aadd(aPedErro,{cFil+cPedProth,cFil,cPedProth,cMsgErro})
			erroProcess(cMsgErro,cFil,cNvPedSag,"",cTabGen,cOperacao)
			
		EndIf
	
	Next i
	
	//Atualiza o array de pedidos liberados.
	aPedSucess := aClone(aLibCab)
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} cortaPed
	Efetua o corte nas quantiades do pedido. 
	@type  Static Function
	@author Everson
	@since 20/03/2017
	@version 01
	/*/
Static Function cortaPed(cFil,cNum,cItem,cProduto,nNvQtd1,nNvQtd2,cNvPedSag,cCliente,cLoja,cC9Recno,nPrcUntSAG,nTpFrt,cTransp,cPlaca,cUFPlaca,nVlFrt,cOperacao)
	
	//Variáveis.
	Local aArea	:= GetArea()
	//Local i 	:= 1
	Local cEof	:= Chr(13) + Chr(10)
	
	//Remove espaços em branco.
	cFil		:= Alltrim(cValToChar(cFil))
	cNum		:= Alltrim(cValToChar(cNum))
	cItem		:= Alltrim(cValToChar(cItem))
	cProduto	:= Alltrim(cValToChar(cProduto))
	cNvPedSag	:= Alltrim(cValToChar(cNvPedSag))
	cCliente	:= Alltrim(cValToChar(cCliente))
	cLoja		:= Alltrim(cValToChar(cLoja))
	cC9Recno	:= Val(cValToChar(cC9Recno))
	cTransp		:= Alltrim(cValToChar(cTransp))
	cPlaca		:= Alltrim(cValToChar(cPlaca))
	cUFPlaca	:= Alltrim(cValToChar(cUFPlaca))
	
	//Não efetua corte se a quantidade for igual a Zero.
	If nNvQtd1 == 0
		MsgStop("Por favor, reveja a nova quantidade. O produto " +;
		        cProduto + " do pedido " + cNum + " não terá a quantidade ajustada.","Função cortaPed")
		cMsgErro := "cortaPed - a no quantidade é igual a 0"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Tipo de frete (1 =  CIF, 2 = FOB, 0 = Sem frete)
	If  nTpFrt == 1
		
		//Valida se os campos de frete foram preenchidos.
		If Empty(cPlaca) .Or.;
		   Empty(cTransp) .Or. Empty(cUFPlaca)
		   
			MsgStop("Por favor, reveja se os campos transportadora, placa e UF da placa estão preenchidos. O produto " +;
			        cProduto + " do pedido " + cNum + " não terá a quantidade ajustada.","Função cortaPed")
			cMsgErro := "cortaPed - reveja se os campos transportadora, placa e UF da placa estão preenchidos"
			RestArea(aArea)
			Return .F.
		
		EndIf
	
	EndIf
	
	//Localiza o pedido de venda na tabela SC5.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->(DbSeek(cFil + cNum))
		MsgStop("Não foi possível localizar o pedido " + cNum + ". Tabela SC5." + cEof +;
				"Chave: " + Alltrim(cValToChar(cFil + " " + cNum)),"Função cortaPed")
		cMsgErro := "cortaPed - Pedido " + cNum + " não encontrado na tabela SC5"
		RestArea(aArea)
		Return .F.
				
	EndIf
	
	//Pedido não liberado.
	If Empty(Alltrim(cValToChar(SC5->C5_LIBEROK)))
		MsgStop("O pedido não está liberado. Pedido " + cNum + ".","Função cortaPed")
		cMsgErro := "cortaPed - Pedido " + cNum + " não liberado tabela SC5"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//O pedido está aberto.
	If Empty(Alltrim(cValToChar(SC5->C5_LIBEROK))) .And. Empty(Alltrim(cValToChar(SC5->C5_NOTA))) .And. Empty(Alltrim(cValToChar(SC5->C5_BLQ)))
		MsgStop("O pedido está com o status de aberto. Pedido " + cNum + ".","Função cortaPed")
		cMsgErro := "cortaPed - Pedido " + cNum + " em aberto tabela SC5(C5_LIBEROK)"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Valida se o campo nota fiscal está preenchido.
	If ! Empty(Alltrim(cValToChar(SC5->C5_NOTA)))
		MsgStop("O campo nota fiscal da tabela SC5 está preenchido. Pedido " + cNum + ".","Função cortaPed")
		cMsgErro := "cortaPed - Pedido " + cNum + " com campo nota fiscal preenchido tabela SC5(C5_NOTA)"
		RestArea(aArea)
		Return .F.
				
	EndIf
	
	//Localiza o pedido de venda na tabela SC6.
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	If ! SC6->(DbSeek(cFil + cNum + cItem))
		MsgStop("Não foi possível localizar o pedido " + cNum + ". Tabela SC6." + cEof +;
				"Chave: " + Alltrim(cValToChar(cFil + " " + cNum)),"Função cortaPed")
		cMsgErro := "cortaPed - Pedido " + cNum + " não encontrado tabela SC6"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Valida se as novas quantidades não são maiores que as quantidades aprovadas.
	If (nNvQtd1 > SC6->C6_QTDVEN) .And. cOperacao <> "E"
		MsgStop("A quantidade informada para o produto " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + " do pedido " + cNum + " está maior que a quantidade liberada." + cEof +;
				"Qtd. liberada:  " + Transform(SC6->C6_QTDVEN,"@E 999,999,999.999") + cEof + ;
				"Qtd. ajuste:  "   + Transform(nNvQtd1,"@E 999,999,999.999"),"Função cortaPed")
		cMsgErro := "cortaPed - Quantidade de corte maior que quantidade liberada (Qtd Lib " + Transform(SC6->C6_QTDVEN,"@E 999,999,999.999") + ")"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Valida preço unitário do produto.
	If (nPrcUntSAG <> SC6->C6_PRCVEN)
		MsgStop("O preço unitário do produto " + cProduto + " do pedido " + cNum + " no SAG está divergente do preço unitário do Protheus - Tabela SC6." + cEof +;
				"Preço Protheus:  " + Alltrim(cValToChar(Transform(SC6->C6_PRCVEN,"@E 999,999,999.999"))) + cEof + ;
				"Preço SAG:  "      + Alltrim(cValToChar(Transform(nPrcUntSAG,"@E 999,999,999.999"))),"Função cortaPed")
		cMsgErro := "cortaPed - Preço unitário divergente Protheus(" + Transform(SC6->C6_PRCVEN,"@E 999,999,999.999") + ") x SAG"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Preenche os dados de frete com as novas informações do registro.
	If nTpFrt == 1 //Frete CIF.
		RecLock("SC5",.F.)
			Replace SC5->C5_PLACA   With cPlaca
			Replace SC5->C5_TRANSP  With cTransp
			Replace SC5->C5_UFPLACA With cUFPlaca
			Replace SC5->C5_FRETE   With nVlFrt
			Replace SC5->C5_TPFRETE With "C"
		MsUnlock()
	
	Else //Outra opções de frete (FOB e Sem Frete).
		RecLock("SC5",.F.)
			Replace SC5->C5_PLACA   With ""
			Replace SC5->C5_TRANSP  With ""
			Replace SC5->C5_UFPLACA With ""
			Replace SC5->C5_FRETE   With 0
			Replace SC5->C5_TPFRETE With Iif(nTpFrt == 2,"F","S")
		MsUnlock()	
	
	EndIf
	
	//Localiza o pedido na tabela SC9.
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())
	SC9->(DbGoTo(cC9Recno))
	
	//Valida se não está no final do arquivo.
	If SC9->(Eof()) // Verifica se a área de trabalho não está no final de arquivo
		MsgStop("Não foi possível atualizar o pedido " + cNum + " produto " + cProduto + ". Registro não encontrado na tabela SC9.","Função cortaPed")
		cMsgErro := "cortaPed - Pedido " + cNum + "não encontrado tabela SC9"
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Valida os campos da SC9 com os dados vindos do BD Integração.
	If Alltrim(cValToChar(SC9->C9_FILIAL)) <> cFil  .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) <> cNum   .And. Alltrim(cValToChar(SC9->C9_CLIENTE)) <> cCliente .And.;
	   Alltrim(cValToChar(SC9->C9_LOJA)) <> cLoja   .And. Alltrim(cValToChar(SC9->C9_PRODUTO)) <> cProduto .And. Alltrim(cValToChar(SC9->C9_ITEM)) <> cItem
	   
		MsgStop("Não foi possível atualizar o pedido " + cNum + " produto " + cProduto + ". Registro não encontrado na tabela SC9.","Função cortaPed")
		cMsgErro := "cortaPed - Pedido não dados divergentes tabela SC9"
		RestArea(aArea)
		Return .F.
			
	EndIF
	
	//Verifica se há bloqueio de estoque.
	If ! Empty(SC9->C9_BLEST)
		MsgStop("Não foi possível atualizar o pedido " + cNum + " produto " + cProduto + ". Registro está com bloqueio de estoque na tabela SC9.","Função cortaPed")
		cMsgErro := "cortaPed - Produto com bloqueio de estoque tabela SC9"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Verifica se há bloqueio de crédito.
	If ! Empty(SC9->C9_BLCRED)
		MsgStop("Não foi possível atualizar o pedido " + cNum + " produto " + cProduto + ". Registro está com bloqueio de crédito na tabela SC9.","Função cortaPed")
		cMsgErro := "cortaPed - Produto com bloqueio de crédito tabela SC9"
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Verifica se há reserva.
	If ! Empty(SC9->C9_RESERVA)
		MsgStop("Não foi possível atualizar o pedido " + cNum + " produto " + cProduto + ". Registro possui reserva na tabela SC9.","Função cortaPed")
		cMsgErro := "cortaPed - Produto com reserva tabela SC9"
		RestArea(aArea)
		Return .F.
			
	EndIf
	
	//Altera as quantidades na tabela SC9.
	RecLock("SC9",.F.)
		Replace C9_QTDLIB  With nNvQtd1
		Replace C9_QTDLIB2 With Iif(nNvQtd2 == 0,nNvQtd1,nNvQtd2)
	MsUnlock()

	//Ajusta as quantidades na tabela SC6.
	If cOperacao <> "E"
	
		Reclock("SC6",.F.)
			Replace C6_QTDORI  With C6_QTDVEN
			Replace C6_QTDORI2 With C6_UNSVEN
			Replace C6_QTDVEN  With nNvQtd1
			Replace C6_UNSVEN  With nNvQtd2
			Replace C6_QTDLIB  With nNvQtd1
			Replace C6_QTDLIB2 With nNvQtd2
			Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
			Replace C6_QTDEMP  With nNvQtd1
			Replace C6_QTDEMP2 With nNvQtd2
			Replace C6_XLIBSAG With "2"
		Msunlock()
		
	Else

		Reclock("SC6",.F.)
			Replace C6_QTDVEN  With Iif(C6_QTDORI  > 0,C6_QTDORI ,C6_QTDVEN)
			Replace C6_UNSVEN  With Iif(C6_QTDORI2 > 0,C6_QTDORI2,C6_UNSVEN)
			Replace C6_QTDLIB  With Iif(C6_QTDORI  > 0,C6_QTDORI ,C6_QTDLIB)
			Replace C6_QTDLIB2 With Iif(C6_QTDORI2 > 0,C6_QTDORI2,C6_QTDLIB2)
			Replace C6_VALOR   With Iif(C6_QTDORI  > 0,C6_QTDORI * C6_PRCVEN,C6_VALOR)              
			Replace C6_QTDEMP  With Iif(C6_QTDORI  > 0,C6_QTDORI,C6_QTDEMP)
			Replace C6_QTDEMP2 With Iif(C6_QTDORI2 > 0,C6_QTDORI2,C6_QTDEMP2)
			Replace C6_XLIBSAG With "1"
		Msunlock()		
		
	EndIf
	
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} pesoPedido
	Calcula peso do pedido baseado nos itens liberados, ajusta
	cabeçalho do pedido. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 20/03/2017
	@version 01
	/*/
Static Function pesoPedido(cFil,cPedProth,cPedSag,cPedXml,cPlaca,cTabGen,oNvCodGene,cPedSAGPr,cTabGenAnt,nTpFrt,cTransp,cUFPlaca,nVlFrt,cOperacao)

	//Variáveis.
	Local aArea			:= GetArea()
	Local nTotalVol		:= 0
	Local nTotalPeso	:= 0
	Local nTotalBruto	:= 0
	//Local cNvCodigene	:= ""
	//Local cChave		:= ""
	//Local cParame		:= ""
	Local lLibSC6		:= .T.
	
	//Apaga variável de erro.
	cMsgErro := ""
	
	//Inicia controle de transação.
	BeginTran()
	
		//Busca o pedido na tabela SC5.
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1))
		SC5->(DbGoTop())
		If ! SC5->(DbSeek(cFil + cPedProth))
			MsgStop("Não foi possível alterar a quantidade do pedido " + cPedProth + " na tabela SC5. Por favor, informe a T.I.","Função pesoPedido")
			cMsgErro := "pesoPedido - Pedido não encontrado na tabela SC5."
			DisarmTransaction() 
			MsUnlockAll()
			RestArea(aArea)
			Return .F.
			
		EndIf
		
		//Busca o pedido na tabela SC6.
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		If ! SC6->(DbSeek(cFil + cPedProth))
			MsgStop("Não foi possível localizar o pedido " + cPedProth + " na tabela SC6. Por favor, informe a T.I.","Função pesoPedido")
			cMsgErro := "pesoPedido - Pedido não encontrado na tabela SC6."
			DisarmTransaction() 
			MsUnlockAll()
			RestArea(aArea)
			Return .F.
			
		EndIf
	
		//Busca o pedido na tabela SC9.
		DbSelectArea("SC9")
		SC9->(DbSetOrder(1))
		SC9->(DbGoTop())
		If ! SC9->(DbSeek(cFil + cPedProth))
			MsgStop("Não foi possível localizar o pedido " + cPedProth + " na tabela SC9. Por favor, informe a T.I.","Função pesoPedido")
			cMsgErro := "pesoPedido - Pedido não encontrado na tabela SC9."
			DisarmTransaction() 
			MsUnlockAll()
			RestArea(aArea)
			Return .F.
				
		EndIf
		
		//Zera variáveis.
		nTotalPeso := 0
		nTotalVol  := 0
		nTotalBruto:= 0
		lLibSC6	   := .T.
		
		//Obtém as novas quantidades.
		While SC9->(! Eof()) .And. cFil == Alltrim(cValToChar(SC9->C9_FILIAL )) .And. Alltrim(cValToChar(SC9->C9_PEDIDO)) == cPedProth
		
			//Verifica se há itens na tabela SC6 com quantidade não ajustada.
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbGoTop())
			If ! SC6->(DbSeek(cFil + cPedProth + Alltrim(cValToChar(SC9->C9_ITEM)) + Alltrim(cValToChar(SC9->C9_PRODUTO)) ))
				MsgStop("Não foi possível localizar o item " + Alltrim(cValToChar(SC9->C9_ITEM)) + " do pedido " + cPedProth + " - tabela SC6.","Função pesoPedido")
				cMsgErro := "pesoPedido - Não foi possível localizar o item " + Alltrim(cValToChar(SC9->C9_ITEM)) + " do pedido " + cPedProth + " "
				DisarmTransaction() 
				MsUnlockAll()
				RestArea(aArea)
				Return .F.
						
			EndIf
			
			If (Alltrim(cValTochar(SC6->C6_XLIBSAG)) == "1" .Or. Empty(Alltrim(cValTochar(SC6->C6_XLIBSAG)))) .And. (Empty(Alltrim(cValToChar(SC9->C9_BLCRED))) .And. Empty(Alltrim(cValToChar(SC9->C9_BLEST))))
				lLibSC6 := .F.
				
			EndIf
			
			//Busca as unidades de medida do produto na tabela SB1.	
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If ! SB1->(DbSeek(xFilial("SB1") + SC9->C9_PRODUTO))
				MsgStop("Produto não encontrado na tabela SB1 " + Alltrim(cValToChar(SC9->C9_PRODUTO)) + ". Pedido " + cPedProth + ".","Função pesoPedido")
				cMsgErro := "pesoPedido - Produto não encontrado na tabela SB1 " + Alltrim(cValToChar(SC9->C9_PRODUTO))
				DisarmTransaction() 
				MsUnlockAll()
				RestArea(aArea)
				Return .F.
							
			EndIf
			
			//Segunda unidade de medida.
			nTotalVol   := nTotalVol   + SC9->C9_QTDLIB2
			
			//Primeira unidade de medida.
			nTotalPeso  := nTotalPeso  + SC9->C9_QTDLIB
			
			//Obtém os dados da embalagem, para cálculo do peso bruto.
			DbSelectArea("SZC")
			SZC->(DbSetOrder(1))
			If SZC->(DbSeek(xFilial("SZC") + SB1->B1_SEGUM))
				nTotalBruto   += (SC9->C9_QTDLIB2  * SZC->ZC_TARA ) //Peso bruto.
				
			Else
				nTotalBruto   += SC9->C9_QTDLIB //Peso bruto.
				
			EndIf
			
			//Ajusta as informações na tabela SC9.
			DbSelectArea("SC9")
			Reclock("SC9",.F.)
				Replace C9_ROTEIRO With SC5->C5_ROTEIRO
				Replace C9_DTENTR  With SC5->C5_DTENTR
				Replace C9_VEND1   With SC5->C5_VEND1
				Replace C9_PLACA   With cPlaca
			Msunlock()
			
			SC9->(Dbskip())
			
		End
		
		//Ajusta as quantidades e liberações na tabela SC5.
		RecLock("SC5",.F.)
			SC5->C5_PBRUTO  := nTotalBruto + nTotalPeso
			SC5->C5_PESOL   := nTotalPeso
			SC5->C5_VOLUME1 := nTotalVol
			SC5->C5_XLIBSAG	:= Iif(lLibSC6,"2","1")
		MsUnlock()
		
		//Se a operação for diferente de exclusão, 
		If cOperacao <> "E"
			
			If nTpFrt == 1 //Frete CIF.
				RecLock("SC5",.F.)
					Replace SC5->C5_PLACA   With cPlaca
					Replace SC5->C5_TRANSP  With cTransp
					Replace SC5->C5_UFPLACA With cUFPlaca
					Replace SC5->C5_FRETE   With nVlFrt
					Replace SC5->C5_TPFRETE With "C"
				MsUnlock()
			
			Else //Outra opções de frete (FOB e Sem Frete).
				RecLock("SC5",.F.)
					Replace SC5->C5_PLACA   With ""
					Replace SC5->C5_TRANSP  With ""
					Replace SC5->C5_UFPLACA With ""
					Replace SC5->C5_FRETE   With 0
					Replace SC5->C5_TPFRETE With Iif(nTpFrt == 2,"F","S")
				MsUnlock()	
			
			EndIf
			
		EndIf
	
	//Finaliza controle de transação.
	EndTran()
	
	//Restaura áreas de trabalho.
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} erroProcess
	Grava erro no banco integração. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 17/03/2017
	@version 01
	/*/
Static Function erroProcess(cErro,cFil,cNum,cCodigene,cTabgene,cOperacao)
	
	//Variáveis.
	Local nRet	:= 0
	Local cUpd	:= "UPDATE SGPED010 SET C5_MSEXP='" + DToS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' " 
		  cUpd  += " WHERE C5_FILIAL ='" + cFil + "' AND C5_NUM='" + cNum + "' AND OPERACAO_INT = '" + cOperacao + "' "
		  
		  If ! Empty(Alltrim(cValToChar(cCodigene)))
		  	cUpd  += " AND CODIGENE = '" + cCodigene + "' "
		  
		  EndIf
		  
		  cUpd  += " AND TABEGENE = '" + cTabgene + "' "

	
	//Executa update no BD Interface.
	nRet := TcSqlExec(cUpd)
		
	If (nRet < 0)
		MsgAlert("Não foi possivel atualizar o registro no banco interface." + Chr(13) + Chr(10) + "Erro: "+ TCSQLError(),"Função erroProcess")
		
	EndIf
	
Return Nil
/*/{Protheus.doc} sucessoProcess
	Atualiza o registro no banco interface como integrado. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 17/03/2017
	@version 01
	/*/
Static Function sucessoProcess(cFil,cNum,cCodigene,cTabgene,cOperacao,cMsg)

	//Variáveis.
	Local nRet	:= 0
	Local cUpd	:= "UPDATE SGPED010 SET C5_MSEXP='" + DToS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='" + Iif(Empty(Alltrim(cValToChar(cMsg))),Space(70),Alltrim(cValToChar(cMsg))) + "' " 
		  cUpd	+= " WHERE C5_FILIAL ='" + cFil + "' AND C5_NUM='" + cNum + "' AND OPERACAO_INT = '" + cOperacao + "' "
		  
		  If ! Empty(Alltrim(cValToChar(cCodigene)))
		  	cUpd	+= " AND CODIGENE = '" + cCodigene + "' " 
		  
		  EndIf
		  
		  cUpd	+= " AND TABEGENE = '" + cTabgene + "' "
	
	//Executa update no BD Interface.
	nRet :=  TcSqlExec(cUpd)
	
	If nRet < 0
		MsgAlert("Não foi possivel atualizar o registro no banco interface." + Chr(13) + Chr(10) + "Erro: "+ TCSQLError(),"Função sucessoProcess(INTEPEDB)")
		
	EndIf

Return Nil
/*/{Protheus.doc} obtItemNFOri
	Retorna o item e o preço unitário da NF de entrada. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 24/03/2017
	@version 01
	/*/
Static Function obtItemNFOri(cFil,cFornece,cLoja,cNF,cSerie,cProduto)

	//Variáveis.
	Local aArea	:= GetArea()
	Local cQuery:= ""
	Local aDados:= {}
	
	//Remove espaços em branco.
	cFil 		:= Alltrim(cValToChar(cFil))
	cFornece	:= Alltrim(cValToChar(cFornece))
	cLoja		:= Alltrim(cValToChar(cLoja))
	cNF			:= Alltrim(cValToChar(cNF))
	cNF			:= Padl(cNF,9,"0")
	cSerie		:= Alltrim(cValToChar(cSerie))
	cProduto	:= Alltrim(cValToChar(cProduto))
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " TOP 1 D1_ITEM, D1_VUNIT " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD1") + " AS SD1 " 
	cQuery += " WHERE " 
	cQuery += " SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND D1_FILIAL = '" + cFil + "' " 
	cQuery += " AND D1_FORNECE = '" + cFornece + "' " 
	cQuery += " AND D1_LOJA = '" + cLoja + "' " 
	cQuery += " AND D1_DOC = '" + cNF + "' " 
	cQuery += " AND D1_SERIE = '" + cSerie + "' " 
	cQuery += " AND D1_COD = '" + cProduto + "' " 
	
	//Valida se o alias já existe.
	If Select("ITEM_DEV") > 0
		ITEM_DEV->(DbCloseArea())
		
	EndIf
	
	//Executa consulta no BD.
	TcQuery cQuery New Alias "ITEM_DEV"
	DbSelectArea("ITEM_DEV")
	ITEM_DEV->(DbGoTop())
	
	//
	If ! ITEM_DEV->(Eof())
		Aadd(aDados,{ITEM_DEV->D1_ITEM,ITEM_DEV->D1_VUNIT})
	
	EndIf
	
	//
	ITEM_DEV->(DbCloseArea())
	
	//
	RestArea(aArea)

Return aDados

/*/{Protheus.doc} emitNfGrp
	Interface para seleção de pedidos a serem faturados. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 05/04/2017
	@version 01
/*/
Static Function emitNfGrp(nOpc, cPedProth, cSeqPed, lAut)

	//Variáveis.	
	Local aArea		:= GetArea() 
	Local cQuery	:= ""
	Local cPlaca	:= ""
	Local cNumIni	:= ""
	Local cNumFim	:= ""
	Local cSagIni	:= ""
	Local cSagFim	:= ""
	Local cPerg		:= "INTEGSAIDA"
	Local nNFGer	:= 0
	Local nNFErr    := 0
	Local lRetNf	:= .F.
	Local cNota     := ""
	Local cSerie	:= Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
	Local aNFTrans	:= {}
	Local cNFErro	:= ""
	Local cAliasF2	:= ""
	//Local nAux 		:= 1
	//Local cIdent    := RetIdEnti()
	
	//
	Private aNfGerada 	:= {}

	//
	Default cSeqPed     := ""
	Default lAut		:= .F.

	//Everson  - 29/05/2020, chamado 058120.
    If lAut .And. ! chkSefaz()
        RestArea(aArea)
        Return aNFTrans 

    EndIf
	
	//
	If Empty(cSerie)
		MsgStop("Série da nota fiscal não definida no parâmetro MV_#SRNFIT.","Função emitNfGrp(INTEPEDB)")
		RestArea(aArea)
		Return aNFTrans
			
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " C5_FILIAL, CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_PEDSAG, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_PLACA, C5_TRANSP " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " AS SC5 (NOLOCK) " 
	cQuery += " WHERE " 
	cQuery += " SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND C5_NOTA = '' " 
	cQuery += " AND C5_SERIE = '' " 
	cQuery += " AND C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND C5_PEDSAG <> '' "
	
	//
	If Empty(cSeqPed)
	
		//
		cPedProth := Alltrim(cValToChar(cPedProth))
		If ! Empty(cPedProth)
			zAtuPerg(cPerg, "MV_PAR01", Space(8))
			zAtuPerg(cPerg, "MV_PAR02", cPedProth)
			zAtuPerg(cPerg, "MV_PAR03", cPedProth)
			zAtuPerg(cPerg, "MV_PAR04", Space(10))
			zAtuPerg(cPerg, "MV_PAR05", "ZZZZZZZZZZ")
			
		EndIf
	
		//Cria pergunta.
		validPerg(cPerg)
		
		//Executa a pergunta.
		If ! Pergunte(cPerg,.T.)
			RestArea(aArea)
			Return aNFTrans
			
		EndIf
		
		//Obtém as seleções.
		cPlaca := MV_PAR01
		cNumIni:= MV_PAR02
		cNumFim:= MV_PAR03
		cSagIni:= MV_PAR04
		cSagFim:= MV_PAR05
		
		//Remove espaços em branco.
		cPlaca	:= Alltrim(cValToChar(cPlaca))
		cNumIni	:= Alltrim(cValToChar(cNumIni))
		cNumFim	:= Alltrim(cValToChar(cNumFim))
		cSagIni	:= Alltrim(cValToChar(cSagIni))
		cSagFim	:= Alltrim(cValToChar(cSagFim))
		
		If ! Empty(cPlaca)
			cQuery += " AND C5_PLACA = '" + cPlaca + "' " 
		
		EndIf
		
		cQuery += " AND C5_NUM >= '" + cNumIni + "' " 
		cQuery += " AND C5_NUM <= '" + cNumFim + "' " 
		cQuery += " AND C5_PEDSAG >= '" + cSagIni + "' " 
		cQuery += " AND C5_PEDSAG <= '" + cSagFim + "' " 
		cQuery += " AND C5_XLIBSAG <> '1' "
		
	Else
		cQuery += " AND C5_PEDSAG IN (" + cSeqPed + ")"
	
	EndIf
	
	//
	If     nOpc == 1
		cQuery += " AND C5_TABEGEN = 'PO02MVES' "
		
	ElseIf nOpc == 2
		cQuery += " AND C5_TABEGEN = 'PO03MVES' "
		
	ElseIf nOpc == 3
		cQuery += " AND C5_TABEGEN = 'POCAMVTP' "
		
	ElseIf nOpc == 4
		cQuery += " AND ( C5_TABEGEN = 'PO01MVES' OR C5_TABEGEN = 'POCAMVES' ) "
		
	ElseIf nOpc == 5
		cQuery += " AND C5_TABEGEN = 'EC03LOTE' "
		
	ElseIf nOpc == 6
		cQuery += " AND C5_TABEGEN = 'FCCAORAP' "
		
	ElseIf nOpc == 7
		cQuery += " AND C5_TABEGEN = 'PO11MVES' "
		
	ElseIf nOpc == 8
		cQuery += " AND C5_TABEGEN = 'RACAORSA' "
		
	ElseIf nOpc == 10
		cQuery += " AND C5_TABEGEN = 'PO14MVES' "
	
	ElseIf nOpc == 11
		cQuery += " AND C5_TABEGEN = 'PO15MVES' "
		
	// @history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
	ElseIf nOpc == 12
		cQuery += " AND C5_TABEGEN = 'PO16MVES' "
	//

	EndIf
	
	//
	cAliasF2 := GetNextAlias()

	//Executa consulta no BD Protheus.
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasF2, .F., .T.)},"Função emitNfGrp(INTEPEDB)","Carregando registros...")
	
	//
	DbSelectArea(cAliasF2)
	(cAliasF2)->(DbGoTop())
	
	//
	If (cAliasF2)->(Eof())
		(cAliasF2)->(DbCloseArea())
		MsgStop("Não há pedidos para emissão doc de saída.","Função emitNfGrp(INTEPEDB)")
		RestArea(aArea)
		Return aNFTrans
		
	EndIf
	
	//
	While ! (cAliasF2)->(Eof())
		
		lRetNf := .F.
		MsAguarde({|| NfLot(Alltrim(cValToChar((cAliasF2)->C5_NUM)), @cNota, @lRetNf,cSerie) },"Aguarde","Emitindo NF, pedido " + Alltrim(cValToChar((cAliasF2)->C5_NUM + "...")))
		
		If lRetNf
			
			nNFGer++

			// @history Macieira, 18/02/2021, ticket 8897 - Remessa para Criação
			If nOpc == 12
				
				// Gravo NF/Serie gerada no PED010 e limpo STATUS_INT para enviar ao SAG
				//cSql := " UPDATE SGPED010 SET C5_NOTA='"+cNota+"', C5_SERIE='"+cSerie+"' // @history Macieira, 18/02/2021, ticket 11804 - GRAVAR REGISTRO NO PROTHEUS para enviar ao SAG
				cSql := " UPDATE SGPED010 SET C5_NOTA='"+cNota+"', C5_SERIE='"+cSerie+"', STATUS_INT='' 
				cSql += " WHERE TABEGENE = 'PO16MVES'
				cSql += " AND C5_NUM='"+AllTrim(SC5->C5_PEDSAG)+"'

				tcSqlExec(cSql)

			EndIf
			//
			
		Else
		
			nNFErr++
			
		EndIf
		Aadd(aNfGerada,{cNota,Alltrim(cValToChar((cAliasF2)->C5_NUM)),lRetNf,cSerie})
		
		//
		If lRetNf
			Aadd(aNFTrans,{cNota,cSerie})
			
		EndIf
		
		//
		If ! lRetNf
			cNFErro += Alltrim(cValToChar((cAliasF2)->C5_NUM)) + " " + cNota + Chr(13) + Chr(10)
		
		EndIf
		
		(cAliasF2)->(DbSkip())
		
	End
	
	//
	If ! lAut //Everson - 26/05/2020. Chamado 058120.
		MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...")

	EndIf
	
	//
	If ! Empty(cNFErro)
		cNFErro := "Não foram geradas as notas fiscais para os pedidos abaixo: " + Chr(13) + Chr(10) + cNFErro
		MsgAlert(cNFErro)
	
	EndIf
	
	//Everson - 30/11/2020. Chamado T.I.
	If Len(aNFTrans) > 0
	 	MsAguarde({|| transmNF(@aNFTrans,cSerie,lAut) },"Aguarde","Transmitindo NF's")

	EndIf
	
	//
	RestArea(aArea)
	
Return aNFTrans //Everson - 26/05/2020. Chamado 058120.

/*/{Protheus.doc} transmNF
	Transmissão de nota fiscal. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 11/10/2018
	@version 01
	/*/
Static Function transmNF(aNFTrans,cSerie,lAut)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cIdent    := ""
    Local oWs       := Nil
	Local cURL		:= ""
	Local cNFIni	:= aNFTrans[1][1]
	Local cNFFim	:= aNFTrans[Len(aNFTrans)][1]
	Local cNFT 		:= ""
	Local cAmbiTrans:= ""
	Local nAux		:= 1
	Local lTAut  	:= GetMv("MV_#TRAUT",,.F.)
	
	//Everson - 30/11/2020. Chamado TI.
	//RestArea(aArea)
	//return Nil

	//Everson - 03/06/2020. Chamado T.I.
	If lAut .And. ! lTAut
		aNFTrans := {}
		RestArea(aArea)
		Return .F.

	EndIf

	//
	Default lAut	:= .F.
	
	//
	MsgInfo("Notas geradas de " + cNFIni + " até " + cNFFim + ".","Função transmNF")

	//Everson - 26/05/2020. Chamado 058120.
    If ! CTIsReady()
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - transmNF - CTIsReady retornou .F. " )
        MsgSTop( "A função CTIsReady retornou .F. . Não será possível fazer a transmissão automática, faça a transmissão manual." ,"Função transmNF(INTEPEDB)")
		RestArea(aArea)
        Return .F. 

    EndIf

	//
    cIdent := RetIdEnti()

    //
    oWs := WsSpedCfgNFe():New()

    //
    cURL := PadR(GetMv("MV_SPEDURL"),250)

    //
    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT := cIdent
    oWS:nAmbiente := 0
    oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    
    //
    If oWS:CFGAMBIENTE()
        cAmbiTrans := oWS:cCfgAmbienteResult
        cAmbiTrans := Substr(cAmbiTrans,1,1)

    EndIf

    //
    Conout( DToC(Date()) + " " + Time() + " INTEPEDB - transmNF - ambiente para transmissão NF " + cAmbiTrans)
	
	//
	If Empty(cAmbiTrans)
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - transmNF - Não foi possível obter o ambiente de transmissão de nota fiscal.")
		MsgStop("Não foi possível obter o ambiente de transmissão de nota fiscal.","Função transmNF")
		RestArea(aArea)
		Return .F.
		
	EndIf

	//
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	
	//
	For nAux := 1 To Len(aNFTrans) 

		//
		cNFT := aNFTrans[nAux][1]

		//
		SF2->(DbGoTop())
		If SF2->(DbSeek( xFilial("SF2") + cNFT + cSerie ))
			
			If SM0->M0_CODFIL == SF2->F2_FILIAL
				MsAguarde({|| AutoNfeEnv(FWCodEmp(),SF2->F2_FILIAL,"1",cAmbiTrans,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC) },"Transmitindo NF","De " + cNFT + " até " + cNFT + " Série: " + cSerie + " ..." )
			Else
				MsgStop("A filial corrente está divergente da NF para transmissão " + cNFT + cSerie + ".", "Função transmNF(INTEPEDB)")
			Endif

		Else 
			MsgStop("NF não encontrada para transmissão " + cNFT + cSerie + ".", "Função transmNF(INTEPEDB)")
			

		EndIf 

	Next nAux 

	//Everson - 26/05/2020. Chamado 058120.
	If ! lAut
		MsAguarde({|| imprimeNF(cValToChar(aNFTrans[1][1]),cValToChar(aNFTrans[Len(aNFTrans)][1])) },"Aguarde","Imprimindo notas fiscais...")

	EndIf
	
	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} imprimeNF
	Carrega o conteúdo na variável da pergunta. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 23/10/2018
	@version 01
	/*/
Static Function imprimeNF(cNFIni,cNFFim)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"

	//Variável necessária para função SpedDanfe.
	Private aFilBrw	:=	{'SF2',cCondicao}

	//
	Default cNFIni	:= ""
	Default cNFFim	:= ""
	
	//
	If ! Empty(cNFIni) .And. ! Empty(cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR01", cNFIni)
		zAtuPerg("NFSIGW", "MV_PAR02", cNFFim)
		
	EndIf
	
	//
	SpedDanfe()
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} zAtuPerg
	Carrega o conteúdo na variável da pergunta. Chamado 033511. 
	@type  Static Function
	@author Everson
	@since 27/07/2017
	@version 01
	/*/
Static Function zAtuPerg(cPergAux, cParAux, xConteud)

	//Variáveis.
	Local aArea      := GetArea()
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}

	//
	Default xConteud := ''

	//Se não tiver pergunta, ou não tiver ordem.
	If Empty(cPergAux) .Or. Empty(cParAux)
		Return Nil

	EndIf

	//Chama a pergunta em memória.
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	//Procura a posição do MV_PAR.
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })

	//Se encontrou o parâmetro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")

		//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD("+dToS(xConteud)+")")

		//Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")

		EndIf

		//Chama a rotina para salvar os parâmetros
		__SaveParam(cPergAux, aPergAux)

	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} visualPed
	Visualiza o pedido. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 05/04/2017
	@version 01
	/*/
Static Function visualPed(cNum)

	//Variáveis.
	Local aArea := GetArea()

	//Variáveis necessárias para função MatA410.
	Private Inclui    	:= .F.
	Private Altera    	:= .T.
	Private nOpca     	:= 1
	Private cCadastro 	:= "Pedido de Venda"
	Private aRotina 	:= {}
 
	//Busca o pedido na tabela SC5.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If ! SC5->(DbSeek(xFilial("SC5") + cNum))
		MsgStop("Não foi possível localizar o pedido " + cNum + " (SC5).","Função visualPed(INTEPEDB)")
		RestArea(aArea)
		Return Nil	
	
	EndIf

	//
	SC5->(DbGoTo(Recno()))
	
	//
	MatA410(Nil, Nil, Nil, Nil, "A410Visual")

	//
	SC5->(DbCloseArea())
	
	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} NfLot
	Gera nota fiscal de saída.
	@type  Static Function
	@author Everson
	@since 08/10/2018
	@version 01
/*/
Static Function NfLot(cNumPed,cNota,lRetNf,cSerie)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	  	:= GetArea()
	Local aPvlNfs 	:= {}
	Local lRet		:= .F.
	Local lNF912Ok  := .f.
	//Local lNF710734 := .f.
	
	//Everson - 22/09/2021. Chamado TI.
	//Everson - 26/11/2020. Chamado TI.
	// If !LockByName("NfLot", .T., .F.)
	// 	Aviso("NfLot (INTEPEDB)", "Processo (NfLot) já está sendo executado.", {"OK"}, 3)
	// 	RestArea(aArea)
	// 	Return Nil 
	// EndIf
	//

	//Localiza pedido de venda - cabeçalho.
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(MsSeek(xFilial("SC5") + cNumPed))
	If SC5->(Eof())
		cNota := "Pedido não localizado (SC5)."
		RestArea(aArea)
		Return lRet
	EndIf

	//Valida liberação de pedido de venda pelo SAG.
	If Alltrim(cValToChar(SC5->C5_XLIBSAG)) == "1"
		cNota := "Pedido não liberado pelo SAG."
		RestArea(aArea)
		Return lRet		
	EndIf

	//Localiza condição de pagamento do pedido.
	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(MsSeek(xFilial("SE4") + SC5->C5_CONDPAG))
	If SE4->(Eof())
		cNota := "Condição de pagamento não localizada (SE4): " + Alltrim(cValToChar(SC5->C5_CONDPAG)) + "."
		RestArea(aArea)
		Return lRet
	EndIf

	//Localiza pedido de venda - itens.
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(MsSeek(xFilial("SC6") + cNumPed))
	If SC6->(Eof())
		cNota := "Pedido não localizado (SC6)."
		RestArea(aArea)
		Return lRet
	EndIf
	
	//Abre tabelas e configura os índices a serem usados.
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))	

	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	
	//Itera sobre os itens do pedido de venda.
	While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_NUM)) == cNumPed
	
	 	If SC9->(MsSeek(xFilial("SC9") + SC6->(C6_NUM + C6_ITEM))) // Valida se o item está liberado na tabela SC9.
	 		
	 		If Empty(Alltrim(cValToChar(SC9->C9_BLCRED))) .And. Empty(Alltrim(cValToChar(SC9->C9_BLEST))) // Valida se o item está liberado pelo financeiro e estoque.
	 			
	 			//Localiza cadastro do produto.
				SB1->(MsSeek(xFilial("SB1") + SC6->C6_PRODUTO))
				If SB1->(Eof())
					cNota := "Produto não localizado: " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
					RestArea(aArea)
					Return lRet
				EndIf
				
				//Localiza cadastro de saldos físico e financeiro do produto para o local informado.
				SB2->(MsSeek(xFilial("SB2") + SC6->(C6_PRODUTO + C6_LOCAL)))
				If SB2->(Eof())
					cNota := "Produto sem cadastro de saldos físicos e financeiros (SB2): " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + " Local: " + Alltrim(cValToChar(SC6->C6_LOCAL)) + "."
					RestArea(aArea)
					Return lRet
				EndIf
				
				//Localiza o cadastro do TES informado.			
				SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES))
				If SF4->(Eof())
					cNota := "TES não localizado (SF4): " + Alltrim(cValToChar(SC6->C6_TES)) + "."
					RestArea(aArea)
					Return lRet
				EndIf
				
				//Monta array para geração da NF de saída.		 	
				Aadd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								SC9->C9_PRCVEN,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo())})
			
			Else

				cNota := "Item não liberado: " + Alltrim(cValToChar(SC6->C6_NUM)) + " " + Alltrim(cValToChar(SC6->C6_ITEM)) + " " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
				RestArea(aArea)
				Return lRet	
			
			EndIf
			
		Else

			cNota := "Item não liberado: " + Alltrim(cValToChar(SC6->C6_NUM)) + " " + Alltrim(cValToChar(SC6->C6_ITEM)) + " " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
			RestArea(aArea)
			Return lRet			
			
		EndIf
		
		SC6->(DbSkip())
	
	End
	
	/*
	±±³Descri‡…o ³Inclusao de Nota fiscal de Saida atraves do PV liberado     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array com os itens a serem gerados                   ³±±
	±±³          ³ExpC2: Serie da Nota Fiscal                                 ³±±
	±±³          ³ExpC3: Numero da Nota Fiscal                                ³±±
	±±³          ³ExpL4: Lancamento 610                                       ³±±
	±±³          ³ExpL5: Lancamento 620                                       ³±±
	±±³          ³ExpN6: Controle de contabilizacao                           ³±±
	±±³          ³ExpN7: Handle do arquivo de contabilizacao                  ³±±
	±±³          ³ExpL8: Reajuste de preco na nota fiscal                     ³±±
	±±³          ³ExpN9: Tipo de Acrescimo Financeiro                         ³±±
	±±³          ³ExpNA: Tipo de Arredondamento                               ³±±
	±±³          ³ExpLB: Atualiza Amarracao Cliente x Produto                 ³±±
	±±³          ³ExplC: Cupom Fiscal                                         ³±±
	±±³          ³ExpCD: Numero do Embarque de Exportacao                     ³±±
	±±³          ³ExpBE: Code block para complemento de atualizacao dos titu- ³±±
	±±³          ³       los financeiros.                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	*/
	If Len(aPvlNfs) > 0

		If AllTrim(SC5->C5_TABEGENE) <> "PO16MVES"

			DbSelectArea("SX5")
			cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
			lRet   := .T.
			lRetNf := lRet

		Else

			// Checo se a NF é Remessa Ordem TES 912, pois deverá ser emitida apenas se a 710#734 existirem - combo 12
			l912 := Posicione("SC6",1,FWxFilial("SC6")+SC5->C5_NUM,"C6_TES") $ cTESRemGra
			If l912
				
				lNF912Ok := UpNF710734()
				
				If lNF912Ok

					DbSelectArea("SX5")
					cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
					lRet   := .T.
					lRetNf := lRet

				Else
				
					cNota := "NF Remessa Ordem (5923) e/ou Outras Saídas (5949) não foi gerada, pois NF premissa (TES 710/734) não foi encontrada! "
				
				EndIf

			Else

				DbSelectArea("SX5")
				cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
				lRet   := .T.
				lRetNf := lRet

			EndIf

		EndIf
		//
		
	Else

		cNota := "Pedido de venda não liberado (SC9)."
		
	EndIf

	//Everson - 22/09/2021. Chamado TI.
	//Everson - 26/11/2020. Chamado TI.
	//UnLockByName("NfLot")
	
	//
	RestArea(aArea)

return lRet

/*/{Protheus.doc} FatPProd
	Fatura pedido por pedido. Chamado 046285.
	@type  Static Function
	@author Everson
	@since 08/01/2019
	@version 01
/*/
Static Function FatPProd()

	//Variáveis.	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local oFont 	:= TFont():New(,,-15,.T.)
	Local oSay1		:= Nil
	Local oDlg		:= Nil
	Local cAliasF 	:= ""
	Local cTemp	:= ""
	Local oTempFT	:= Nil

	//
	Private lInverte 	:= .F.
	Private cMark   	:= GetMark()   
	Private oMark		:= Nil
	Private aStru		:= {}

	//
	If ! Pergunte("FATPPROD",.T.)
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " DISTINCT C5_FILIAL, C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
	cQuery += " C5_FILIAL = C6_FILIAL " 
	cQuery += " AND C5_NUM = C6_NUM " 
	cQuery += " WHERE " 
	cQuery += " SC5.C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND SC5.C5_EMISSAO = '" + DToS(MV_PAR02) +  "' " 
	cQuery += " AND SC5.C5_BLQ = '' "
	cQuery += " AND SC5.C5_NOTA = '' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND SC6.D_E_L_E_T_ = '' " 
	cQuery += " AND SC6.C6_PRODUTO = '" + cValToChar(MV_PAR01) + "' ORDER BY SC5.C5_NUM " 

	//
	cAliasF := GetNextAlias()

	//
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasF, .F., .T.)},"Função FatPProd(INTEPEDB)","Carregando registros...")
	DbSelectArea(cAliasF)
	(cAliasF)->(DbGoTop())
	If (cAliasF)->(Eof())
		MsgStop("Não há pedidos para os parâmetros informados.","Função FatPProd(INTEPEDB)")
		(cAliasF)->(DbCloseArea())
		RestArea(aArea)
		Return Nil

	EndIf

	//Cria um arquivo de temporário.
	Aadd(aStru,{"OK"     ,"C"	,02		,0		})
	Aadd(aStru,{"FILIAL" ,"C"	,02		,0		})
	Aadd(aStru,{"EMISSAO","C"	,10		,0		})
	Aadd(aStru,{"PEDIDO" ,"C"	,06		,0		})
	Aadd(aStru,{"COD"    ,"C"	,06		,0		})
	Aadd(aStru,{"LOJA"   ,"C"	,02  	,0		})
	Aadd(aStru,{"NOME"   ,"C"	,40		,2		})

	//
	cTemp:= GetNextAlias()

	//
	oTempFT := FWTemporaryTable():New( cTemp )
	oTempFT:SetFields( aStru )
	oTempFT:AddIndex("indice1", {"PEDIDO"} )
	oTempFT:Create()

	//
	While ! (cAliasF)->(Eof())

		//Popula o arquivo temporário.
		RecLock(cTemp,.T.)	
			(cTemp)->OK	  	 := cMark
			(cTemp)->FILIAL  := (cAliasF)->C5_FILIAL
			(cTemp)->EMISSAO := DToC(SToD((cAliasF)->C5_EMISSAO))
			(cTemp)->PEDIDO  := (cAliasF)->C5_NUM
			(cTemp)->COD     := (cAliasF)->C5_CLIENTE		
			(cTemp)->LOJA    := (cAliasF)->C5_LOJACLI		
			(cTemp)->NOME    := (cAliasF)->C5_NOMECLI				
		MsunLock()

		SC5->(dbSeek(xFilial('SC5')+(cAliasF)->C5_NUM))
		IF SC9->(dbSeek(xFilial('SC9')+(cAliasF)->C5_NUM))
			IF ALLTRIM(SC9->C9_BLEST) <> '' .AND. ALLTRIM(SC9->C9_BLEST) <> '10'
				MATA455(3,.T.)
			ENDIF
		ENDIF

		//
		(cAliasF)->(DbSkip())

	End

	//Define quais colunas (campos da (cTemp)) serao exibidas na MsSelect.
	aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;
	{ "FILIAL"	 	,, "Filial"         ,"@!"},;
	{ "EMISSAO"	 	,, "Emissão"        ,"@!"},;			
	{ "PEDIDO"		,, "Pedido"         ,"@!"},;	
	{ "COD"			,, "Código"         ,"@!"},;			
	{ "LOJA"		,, "Loja"           ,"@!"},;			
	{ "NOME"		,, "Nome"           ,"@!"}}	


	//Cria interface.
	Define MsDialog oDlg TITLE "Emissão de Documento de Saída" From 0,0 To 400,805 PIXEL

		oSay1:= TSay():New(003,003,{||'Selecione os pedidos para geração de NF.'},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)

		DbSelectArea(cTemp)
		(cTemp)->(DbGotop())

		oMark := MsSelect():New(cTemp,"OK","",aCpoBro,@lInverte,@cMark,{35,1,170,403},,,,,)
		oMark:bMark := {| | Disp5(cTemp,oMark,cMark)}   

	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{||gerNFLt(cTemp), oDlg:End() },{||oDlg:End()})

	//
	(cTemp)->(DbCloseArea())
	oTempFT:Delete() 

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} gerNFLt
	Função gera nota fiscal. Chamado 046285.
	@type  Static Function
	@author Everson
	@since 08/01/2018
	@version 01
	/*/
Static Function gerNFLt(cTemp)

	//Variáveis.		
	Local aArea      := GetArea()
	Local aPedSelect := {}
	Local i          := 1
	Local aNfGerada  := {}
	Local lRetNf     := .F.
	Local cNota      := ""
	Local cSerie     := Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
	Local nNFGer     := 0
	Local nNFErr     := 0
	Local cNFErro    := ""
	Local aNFTrans   := {}

	//
	If Empty(cSerie)
		MsgStop("Série da nota fiscal não definida no parâmetro MV_#SRNFIT.","Função gerNFLt(INTEPEDB)")
		RestArea(aArea)
		Return Nil

	EndIf

	//Obtém os pedidos selecionados.
	(cTemp)->(DbGoTop())
	While ! (cTemp)->(Eof())

		//
		If ! Empty(Alltrim(cValToChar((cTemp)->OK)))
			Aadd(aPedSelect,{(cTemp)->PEDIDO})

		EndIf

		//
		(cTemp)->(DbSkip())

	End

	//
	If ! MsgYesNo("Serão faturados " + cValToChar(Len(aPedSelect)) + " pedidos. Deseja prosseguir?","Função gerNFLt(INTEPEDB)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	For i := 1 To Len(aPedSelect)

		lRetNf := .F.
		cNota  := ""
		MsAguarde({|| NfLot(Alltrim(cValToChar(aPedSelect[i][1]) ), @cNota, @lRetNf,cSerie) },"Aguarde","Emitindo NF, pedido " + Alltrim(cValToChar(aPedSelect[i][1])) + "...")
		If lRetNf
			nNFGer++

		Else
			nNFErr++

		EndIf
		Aadd(aNfGerada,{cNota, Alltrim(cValToChar(aPedSelect[i][1])) ,lRetNf,cSerie})

		//
		If lRetNf
			Aadd(aNFTrans,{cNota,cSerie})

		EndIf

		//
		If ! lRetNf
			cNFErro += Alltrim(cValToChar(aPedSelect[i][1]) ) + " " + cNota + Chr(13) + Chr(10)

		EndIf

	Next i

	//Exibe notas fiscais não geradas.
	If ! Empty(cNFErro)
		cNFErro := "Não foram geradas as notas fiscais para os pedidos abaixo: " + Chr(13) + Chr(10) + cNFErro
		MsgAlert(cNFErro)

	EndIf

	//Acessa a rotina para transmissão da nota fiscal.
	If Len(aNFTrans) > 0
	 	MsAguarde({|| transmNF(aNFTrans,cSerie) },"Aguarde","Transmitindo NF's")

	EndIf

	MsgInfo("Processo finalizado.","Função gerNFLt (INTEPEDB)")

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} Disp5
	Função para efetuar marcação dos registros. Chamado 046285.
	@type  Static Function
	@author user
	@since 08/01/2019
	@version 01
	/*/ 
Static Function Disp5(cAlias,oMark,cMark)

	//Variáveis.
	Local aArea	:= GetArea()

	//Altera marcação no arquivo temporário.
	DbSelectArea(cAlias)
	RecLock(cAlias,.F.)

	//
	If Marked("OK")	
		(cAlias)->OK := cMark

	Else	
		(cAlias)->OK := ""

	Endif   

	//
	MsUnlock()

	//
	oMark:oBrowse:Refresh()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} validPerg
	Cria pergunta na SX1. Chamado 033511.
	@type  Static Function
	@author Everson
	@since  07/04/2017
	@version 01
	/*/
Static Function validPerg(cPerg)

	PutSX1(cPerg,"01","Placa"           ,"Placa"           ,"Placa"             ,"mv_ch1","C", 08,0,0  ,"G","","","","","mv_par01" ,"" ,"","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"02","Ped Protheus de" ,"Ped Protheus de" ,"Ped Protheus de"   ,"mv_ch2","C", 06,0,0  ,"G","","","","","mv_par02" ,"" ,"","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"03","Ped Protheus até","Ped Protheus até","Ped Protheus até"  ,"mv_ch3","C", 06,0,0  ,"G","","","","","mv_par03" ,"" ,"","","","","","","","","","","","","",""," ")
	PutSX1(cPerg,"04","Ped SAG de"      ,"Ped SAG de"      ,"Ped SAG de"        ,"mv_ch4","C", 10,0,0  ,"G","","","","","mv_par04" ,"" ,"","","","","","","","","","","","","",""," ")
	PutSx1(cPerg,"05","Ped SAG até"     ,"Ped SAG até"     ,"Ped SAG até"       ,"mv_ch5","C", 10,0,0  ,"G","","","","","mv_par05","","","","","","","","","","","","","","","","","","","")

Return Nil
/*/{Protheus.doc} libEst
    Libera estoque.
    @type  Static Function
    @author Everson
    @since 26/05/2020
    @version 01
    /*/
Static Function libEst()

    //Variáveis.
	Local aArea	:= GetArea()

	//
	Private _dData1 := Date()-1    				
	Private _dData2	:= Date()+5                    
	Private _cFil1	:= FWxFilial("SC5")                           
	Private _cFil2	:= FWxFilial("SC5") 

    //
    Conout( DToC(Date()) + " " + Time() + " INTEPEDB - libEst - libera estoque." )

    //
    // StaticCall(LIMPAEST,Elimina)
		MsAguarde({|| MATA455() },"Aguarde","Acessando rotina lib estoque...")
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} chkSefaz
    Checa se o serviço de emissão de nota fiscal eletrônica tipo 55.
    @type  Static Function
    @author Everson
    @since 29/05/2020
    @version 01
    /*/
Static Function chkSefaz()

    //Variáveis.
    Local aArea 	:= GetArea()
	Local cIdent 	:= RetIdEnti()
    Local lRet  	:= .F.
    Local oWS   	:= Nil
    Local cURL  	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local lOk   	:= .F.
    Local aXML  	:= {}
    Local nAux  	:= 1
    Local cMsg  	:= ""

    //
    Conout( DToC(Date()) + " " + Time() + " INTEPEDB - chkSefaz - início checagem da disponibilidade SEFAZ." )

	//
    If ! CTIsReady()
		Conout( DToC(Date()) + " " + Time() + " INTEPEDB - chkSefaz - CTIsReady retornou .F. " )
        MsgSTop( "A função CTIsReady retornou .F. . Não será possível fazer a emissão de NF automática, faça a emissão manual." ,"Função chkSefaz(INTEPEDB)")
		RestArea(aArea)
        Return lRet 

    EndIf

    //
    oWS:= WSNFeSBRA():New()
    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT    := cIdEnt
    oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
    lOk := oWS:MONITORSEFAZMODELO()

    //
    If lOk

        //
        aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
        For nAux := 1 To Len(aXML)

			//
			cMsg :=  Upper(Alltrim(aXML[nAux]:cStatusMensagem))
            If aXML[nAux]:cModelo == "55" .And. cMsg == "SERVIÇO EM OPERAÇÃO"
                lRet := .T.

            EndIf
            
        next Aux

    Else 
        Conout( DToC(Date()) + " " + Time() + " INTEPEDB - chkSefaz - falha no consumo do web service." )

    EndIf

    //
    Conout( DToC(Date()) + " " + Time() + " INTEPEDB - chkSefaz - " + cMsg )

    //
    RestArea(aArea)

Return lRet 

/*/{Protheus.doc} Static Function UpNF710734
	Se for NF com TES 912, terá que existir NF com TES 710#734
	@type  Function
	@author FWNM
	@since 23/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function UpNF710734()

	Local lRet      := .F.
	Local cQuery    := ""
	Local cTESEmp09 := GetMV("MV_TESEMP9",,"734")
	Local cTESEmp01 := GetMV("MV_TESEMP1",,"710")

	If Posicione("SC6",1,FWxFilial("SC6")+SC5->C5_NUM,"C6_TES") $ cTESRemGra 
		
		// NF 912
		cAlias912 := GetNextAlias()

		cQuery := " SELECT C5_XAGRUPA
		cQuery += " FROM SGPED010 (NOLOCK)
		cQuery += " WHERE TABEGENE = 'PO16MVES' 
		cQuery += " AND C5_NUM='"+SC5->C5_PEDSAG+"'

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias912, .F., .T.)

		// NF PREMISSA 710#734
		cAliasTES := GetNextAlias()

		cQuery := " SELECT ISNULL(C5_NOTA,'') C5_NOTA, ISNULL(C5_SERIE,'') C5_SERIE
		cQuery += " FROM SGPED010 (NOLOCK)
		cQuery += " WHERE TABEGENE = 'PO16MVES' 
		cQuery += " AND C6_TES IN " + FormatIn(cTESPreGra,"#")
		cQuery += " AND C6_TES = '" + Iif(cEmpAnt=="09",cTESEmp09,cTESEmp01) + "' 
		cQuery += " AND C5_TIPO='B'
		cQuery += " AND C5_XAGRUPA='"+AllTrim(Str((cAlias912)->C5_XAGRUPA))+"'

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTES, .F., .T.)

		If (cAliasTES)->( !EOF() )

			If !Empty((cAliasTES)->C5_NOTA) .and. !Empty((cAliasTES)->C5_SERIE)

				lRet    := .T.

			EndIf
		
		EndIf

	EndIf

Return lRet


/*/{Protheus.doc} Static Function xLibEst
	Faz chamada na rotina de liberação manual de pedidos
	@type  Function
	@author Abel Babini
	@since 10/05/2021
	@history Ticket 13852 - Abel Babini - Retirada a chamada da Função LIMPAEST() e direcionada para função padrão
/*/
Static Function xLibEst()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())
	Local _i := 0

	//Ticket 13852 - Abel Babini - 11/05/2021 - Criado loop para liberação de estoque automática de todos os pedidos
	For _i := 1 to Len(oRegistros:aCols)

		SC5->(dbSeek(xFilial('SC5')+oRegistros:aCols[_i][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]))
		IF SC9->(dbSeek(xFilial('SC9')+oRegistros:aCols[_i][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]))
			WHILE !SC9->(eof()) .AND. SC9->C9_PEDIDO == oRegistros:aCols[_i][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]
				
				IF ALLTRIM(SC9->C9_BLEST) <> '' .AND. ALLTRIM(SC9->C9_BLEST) <> '10'
					MATA455(3,.T.)
					oRegistros:aCols[_i][Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"})] := "Não"
				ENDIF

				SC9->(dbSkip())
			ENDDO
		ENDIF

	Next _i

	oRegistros:Refresh()

	RestArea(aAreaSC5)
	RestArea(aAreaSC9)

Return
