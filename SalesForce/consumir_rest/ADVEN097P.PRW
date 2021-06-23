#Include "Protheus.ch"
#Include 'Topconn.ch'
/*/{Protheus.doc} User Function ADVEN097P
	Rotina para conferência de pedidos de venda Protheus x Salesforce.
	@type  Function
	@author Everson
	@since 23/05/2018
	@version 01
    @history Everson, 27/12/2018, Chamado TI. Criada funcionalidade para verificar 
	todos os registros de integração Salesforce de um determinado pedido
    @history Everson, 08/07/2019, Chamado T.I. Ajustado filtro de pedidos.    
    @history Everson, 26/08/2019, Chamado T.I. Adicionada função para remover
    pedidos duplicados.                                                  
    @history Everson, 24/09/2019, Chamado T.I. Incluído mais espaços para digitar o 
    número do pedido do Salesforce.    
	@history Everson, 18/06/2020, Chamado 059048. Incluído tratamento para quando o Salesforce não retornar
	todas as tags.  
	@history Everson, 18/02/2020, Chamado TI. Adicionado campos com informação de vendedores, supervisores e opção para exportar os registro de erros para CSV.                                
	/*/
User Function ADVEN097P() // U_ADVEN097P()

	//Variáveis.
	Local aArea		 := GetArea()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para comparação Protheus x SalesForce.')
	
	//
	If ! Pergunte("SFFECHVEND",.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	MsAguarde({|| interface()},"Aguarde","Gerando interface...")
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} interface
	Query de consulta de pedidos no SalesForce
	@type  Static Function
	@author Everson 
	@since 15/06/2018
	@version 01
	/*/
Static Function interface()
	
	//Variáveis.
	Local aArea	   := GetArea()
	Local oInterface := Nil
	Local oPedidos	 := Nil
	Local oAtual	 := Nil
	Local oFechar	 := Nil
	Local oGroup1	 := Nil
	Local oTotEr	 := Nil
	Local oGerArq	 := Nil
	Local aHPv	     := {}
	Local aColsPv	 := {}
	Local oTotPT	 := Nil
	Local oTotSF	 := Nil
	Local oTotBV	 := Nil
	Local aTab		 := {}
	Local oTTabs	 := Nil
	Local oPnl1		 := Nil
	Local oPnl2		 := Nil
	Local oPnl3      := Nil
	Local bMudaAba	 := {|| oPnl1:lVisibleControl := (oTTabs:nOption == 1),;
	 						oPnl2:lVisibleControl := (oTTabs:nOption == 2),;
	 					    oPnl3:lVisibleControl := (oTTabs:nOption == 3),;
	 					    oGerArq:lVisibleControl := (oTTabs:nOption == 1 .Or. oTTabs:nOption == 2),;
	 					    oEnviId:lVisibleControl := (oTTabs:nOption == 1 .Or. oTTabs:nOption == 2),;
	 					    oCSVId:lVisibleControl := (oTTabs:nOption == 1 .Or. oTTabs:nOption == 2),;
	 					    oGetZCI:lVisibleControl := (oTTabs:nOption == 1 .Or. oTTabs:nOption == 2);
	 				    }
	
	Local oBandVer	 := Nil
	Local aHBV		 := {}
	Local aColsBV	 := {}
	Local oSay1		 := Nil
	Local oSay2		 := Nil
	Local oCheckPro  := Nil
	Local oSay3		 := Nil
	Local aHCK       := {}
	Local aColsCK    := {}
	Local oEnviId	 := Nil
	Local oCSVId	 := Nil
	Local oGetZCI    := Nil
	Local oParamSF   := Nil
	Local oTotErr	 := Nil
	
	//
	Private nTotPT	 := 0
	Private nTotSF	 := 0
	Private nTotEr	 := 0
	Private nTotBV   := 0
	Private nTotErr	 := 0
	Private oTBlqP  := Nil
	Private oTBlqS  := Nil
	Private nTBlqP  := 0
	Private nTBlqS	:= 0
	
	//
	oInterface			:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Conferência Pedidos de Venda - Protheus x SalesForce"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1200
	oInterface:nHeight   := 550
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
		//
		aTab   := {'Pedidos de venda','Bandeira vermelha','Check Protheus'}
		oTTabs := TTabs():New(001,001,aTab,Nil,oInterface,Nil,CLR_HRED,Nil,.T.,Nil,595,235,Nil)
		oTTabs:SetOption(1)
			oPnl1 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)
				oTotPT  := TGet():New(017,010,{|u|If(PCount() == 0,nTotPT,nTotPT := u)},oPnl1,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotPT",,,,.T.,,,"Ped. Protheus:",1) 
				
				oTotSF  := TGet():New(017,085,{|u|If(PCount() == 0,nTotSF,nTotSF := u)},oPnl1,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotSF",,,,.T.,,,"Ped. SalesForce:",1) 
				
				oTotEr  := TGet():New(017,160,{|u|If(PCount() == 0,nTotEr,nTotEr := u)},oPnl1,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotEr",,,,.T.,,,"Erros:",1) 
				
				oTBlqP  := TGet():New(017,235,{|u|If(PCount() == 0,nTBlqP,nTBlqP := u)},oPnl1,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTBlqP",,,,.T.,,,"Blq Protheus:",1) 
				
				oTBlqS  := TGet():New(017,310,{|u|If(PCount() == 0,nTBlqS,nTBlqS := u)},oPnl1,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTBlqS",,,,.T.,,,"Blq SalesForce:",1) 
				
				oSay1:= TSay():New(002,240,{||'Data de entrega de ' + DToC(MV_PAR01) + " até " + DToC(MV_PAR02)},oPnl1,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
				
				Aadd(aHPv,{"Sup"        	   ,"SUPER","" ,006, 0,"","" ,"C","",""}) //Everson, 18/02/2020. Chamado TI.
				Aadd(aHPv,{"Vend"   		   ,"VEND" ,"" ,006, 0,"","" ,"C","",""}) //Everson, 18/02/2020. Chamado TI.

				Aadd(aHPv,{"Pedido Protheus"   ,"PEDPT","" ,006, 0,"","" ,"C","",""})
				Aadd(aHPv,{"Pedido SalesForce" ,"PEDSF","" ,008, 0,"","" ,"C","",""})
				Aadd(aHPv,{"Valor Total PT"    ,"VLRPT","@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
				Aadd(aHPv,{"Valor Total SF"    ,"VLRSF","@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
				
				Aadd(aHPv,{"Entrega PT"        ,"ENTPT","" ,010, 0,"","" ,"C","",""})
				Aadd(aHPv,{"Entrega SF"        ,"ENTSF","" ,010, 0,"","" ,"C","",""})
				
				Aadd(aHPv,{"Status SF"    ,"SFSTATUS","" ,050, 0,"","" ,"C","",""})
				Aadd(aHPv,{"Erro"         ,"ERRO","" ,050, 0,"","" ,"C","",""})
				Aadd(aHPv,{"IDSF"         ,"IDSF","" ,018, 0,"","" ,"C","",""})
				
				oPedidos  := MsNewGetDados():New(040,002,200,585,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl1,aHPv,@aColsPv)
				oPedidos:oBrowse:bLDblClick := {|| MsAguarde({|| solicIndPed( oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "IDSF" })] )},"Aguarde","Obtendo id SF...") }
				
			oPnl2 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)
				
				oTotBV  := TGet():New(002,010,{|u|If(PCount() == 0,nTotBV,nTotBV := u)},oPnl2,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotBV",,,,.T.,,,"Total ped.:",1) 
				
				oSay2:= TSay():New(002,240,{||'Data de entrega de ' + DToC(MV_PAR01) + " até " + DToC(MV_PAR02)},oPnl2,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
				
				Aadd(aHBV,{"Id SalesForce"     ,"IDSF",""  ,018, 0,"","" ,"C","",""})
				Aadd(aHBV,{"Pedido SalesForce" ,"PEDSF","" ,008, 0,"","" ,"C","",""})
				Aadd(aHBV,{"Pedido Protheus"   ,"PEDPT","" ,006, 0,"","" ,"C","",""})
				Aadd(aHBV,{"Entrega SF"        ,"ENTSF","" ,010, 0,"","" ,"C","",""})
				Aadd(aHBV,{"Status SF"         ,"SFSTATUS","" ,050, 0,"","" ,"C","",""})
				
				oBandVer  := MsNewGetDados():New(025,002,200,585,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl2,aHBV,@aColsBV)
				oBandVer:oBrowse:bLDblClick := {|| MsAguarde({|| solicIndPed( oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "IDSF" })] )},"Aguarde","Obtendo id SF...") }
				
			oPnl3 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)
				
				oTotErr  := TGet():New(002,010,{|u|If(PCount() == 0,nTotErr,nTotErr := u)},oPnl3,070,010,"@E 999999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotErr",,,,.T.,,,"Tot. Erro:",1) 
				
				oSay3:= TSay():New(002,240,{||'Data de entrega de ' + DToC(MV_PAR01) + " até " + DToC(MV_PAR02)},oPnl3,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)

				Aadd(aHCK,{"Id SalesForce"     ,"IDSF",""  ,018, 0,"","" ,"C","",""})
				Aadd(aHCK,{"Pedido SalesForce" ,"PEDSF","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCK,{"Pedido Protheus"   ,"PEDPT","" ,006, 0,"","" ,"C","",""})
				Aadd(aHCK,{"Erro"              ,"ERRO",""  ,200, 0,"","" ,"C","",""})
				Aadd(aHCK,{"Tipo Erro"         ,"TPERR","" ,002, 0,"","" ,"C","",""})
				
				oCheckPro := MsNewGetDados():New(025,002,170,585,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl3,aHCK,@aColsCK)
				
				TButton():New(190,495,"Rmv. Duplicado",oPnl3,{|| MsAguarde({|| rmvDuplic(aHCK,oCheckPro) },"Aguarde","Excluindo pedidos duplicados") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson-26/08/2019.Chamado T.I.
				TButton():New(190,540,"Repr. SC9"     ,oPnl3,{|| MsAguarde({|| reprocSC9(aHCK,oCheckPro) },"Aguarde","Voltando registros para reprocessamento (tipo 1)...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
								
		//
		oGroup1	 := TGroup():Create(oInterface,239,005,260,595,"",,,.T.)
		
			oGerArq	 := TButton():New(245,010,"Ger. Cod."  ,oInterface,{|| MsAguarde({|| Iif( oTTabs:nOption == 1 , gerarReenv(oPedidos,aHPv) , gerarReenv(oBandVer,aHBV) ) },"Aguarde","Carregando rotina...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
						
			oEnviId	 := TButton():New(245,055,"Solic. SF"  ,oInterface,{|| MsAguarde({|| Iif( oTTabs:nOption == 1 , carSolic(oPedidos,aHPv) , carSolic(oBandVer,aHBV) ) }    ,"Aguarde","Solicitando reenvio de pedidos...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
				
			oCSVId	 := TButton():New(245,100,"CSV. SF"    ,oInterface,{|| MsAguarde({|| impCSVLV() },"Aguarde","Solicitando reenvio de pedidos...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			oGetZCI  := TButton():New(245,145,"Tab ZCI"    ,oInterface,{|| MsAguarde({|| Iif( oTTabs:nOption == 1 , getZCI(oPedidos,aHPv) , getZCI(oBandVer,aHBV) ) },"Aguarde","Acessando ZCI...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			TButton():New(245,190,"Pesq. Ped." ,oInterface,{|| MsAguarde({|| pesqPedido(oPedidos,aHPv) },"Aguarde","Acessando rotina...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			TButton():New(245,235,"Exportar"    ,oInterface,{|| MsAguarde({|| geraCSV(oPedidos,aHPv) },"Aguarde","Acessando rotina...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson, 18/02/2020. Chamado TI.
					
			oParamSF := TButton():New(245,460,"Param. SF" ,oInterface,{|| MsAguarde({|| U_ADVEN078P() ,"Aguarde","Carregando interface..." }) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oAtual	 := TButton():New(245,505,"Recarregar",oInterface,{|| Iif(Pergunte("SFFECHVEND",.T.), atuaVetor(oPedidos,aHPv,oTotPT,oTotSF,oTotEr,oBandVer,aHBV,oTotBV,oSay1,oSay2,oCheckPro,aHCK,oSay3,oTotErr) ,Nil) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oFechar	 := TButton():New(245,550,"Fechar"    ,oInterface,{|| oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
	
		//
		oTTabs:bAction := bMudaAba
		Eval(bMudaAba)
		
	oInterface:Activate(,,,.T.,{||.T.},,{|| atuaVetor(oPedidos,aHPv,oTotPT,oTotSF,oTotEr,oBandVer,aHBV,oTotBV,oSay1,oSay2,oCheckPro,aHCK,oSay3,oTotErr) })

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} rmvDuplic
	Remove pedidos duplicados.
	@type  Static Function
	@author Everson 
	@since 26/08/2019
	@version 01
	/*/
Static Function rmvDuplic(aHCK,oCheckPro)
	
	//Variáveis.
	Local aArea			:= GetArea()
	Local i				:= 1
	Local nAux			:= 0
	Local oParseJSON	:= Nil
	Local lRetSF		:= .F.
	Local cPedS			:= ""
	Local aDados		:= {}
	Local cPedProth		:= ""
	Local cQuery		:= ""
	Local cErro			:= ""
	Local cUrlServ		:= "/pedidosdevenda/"

	//
	If Len(oCheckPro:aCols) <= 0 .Or. Alltrim(cValToChar(oCheckPro:aCols[1][1])) = ""
		MsgAlert("Não há registros a serem processados.","Função rmvDuplic(ADVEN097P)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	For i := 1 To Len(oCheckPro:aCols)
	
		//Everson - 05/08/2019. Chamado TI.
		If Alltrim(cValToChar(oCheckPro:aCols[i,Ascan(aHCK,{|x| AllTrim(x[2]) == "TPERR" })])) == "2"
			Aadd(aDados, { Alltrim(cValToChar(oCheckPro:aCols[i,Ascan(aHCK,{|x| AllTrim(x[2]) == "PEDSF" })])), "" } )
			nAux++
			
		EndIf
	
	Next i
	
	//Everson - 05/08/2019. Chamado TI.
	If nAux <= 0
		MsgAlert("Não há registros a serem reprocessados.","Função rmvDuplic(ADVEN097P)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If ! MsgYesNo("Deseja processar a exclusão de duplicidades ?","Função rmvDuplic")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	For i := 1 To Len(aDados)
	
	 	//
		oParseJSON := Nil
		lRetSF := .F.
		cPedS := Alltrim( aDados[i][1] )
	
		//
		MsAguarde({|| acessaSF(@oParseJSON,@lRetSF,3,.F.,cPedS)},"Aguarde","Obtendo dados do SalesForce...")
		If ! lRetSF
			RestArea(aArea)
			Return Nil
			
		EndIf
		
		//
		VarInfo("oParseJSON",oParseJSON)
		
		//
		If oParseJSON:DONE .And. Len(oParseJSON:RECORDS) > 0
			cPedProth := Alltrim(oParseJSON:RECORDS[1]:CODIGO_PROTHEUS__C)
			
			//
			cQuery := " SELECT C5_NUM FROM " + RetSqlName("SC5") + " (NOLOCK) WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND C5_NUM <> '" + cPedProth + "' AND C5_XSFPED = '" + cPedS + "' AND D_E_L_E_T_= '' "
			
			//
			If Select("D_PEDEX") > 0
				D_PEDEX->(DbCloseArea())
				
			EndIf
			
			//
			TcQuery cQuery New Alias "D_PEDEX"
			DbSelectArea("D_PEDEX")
			
			//
			While ! D_PEDEX->(Eof())
				
				//
				cErro := ""
				StaticCall(ADVEN086P,exclPedVend,@cErro,D_PEDEX->C5_NUM,0,RetCodUsr( ),cUrlServ + Alltrim(D_PEDEX->C5_NUM) )
				
				//
				If ! Empty(cErro)
					MsgStop("Ocorreu erro na exclusão do pedido " + Alltrim(D_PEDEX->C5_NUM) + "." + Chr(13) + Chr(10) + DecodeUTF8(cErro),"Função rmvDuplic(ADVEN097P)")
				
				EndIf
			
				D_PEDEX->(DbSkip())
				
			End
			
			//
			D_PEDEX->(DbCloseArea())
			
		EndIf
	
	Next i
	
	//
	RestArea(aArea)
		
Return Nil
/*/{Protheus.doc} pesqPedido
	Pesquisa histórico do pedido (integração).
	@type  Static Function
	@author Everson 
	@since 27/12/2018
	@version 01
	/*/
Static Function pesqPedido(oPedGrid,aHPv)
	
	//Variáveis.
	Local aArea			:= GetArea()
	Local aInterPesq	:= Nil
	Local oPed			:= Nil
	Local oFechar		:= Nil
	Local oPedChk		:= Nil
	Local oBtnPesq		:= Nil
	Local aHeadPesq		:= {}
	Local aColsPesq		:= {}
	Local cPedido		:= Alltrim(cValToChar( oPedGrid:aCols[oPedGrid:nAt,Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDPT" })]  ))
	
	Private cPed		:= Iif(!Empty(cPedido),cPedido + Space(20),Space(20)) // Everson - 24/09/2019. Chamado T.I.
	Private cCadastro 	:= "Registro ZCI" 

	//
	aInterPesq			 := MsDialog():Create()
	aInterPesq:cName     := "aInterPesq"
	aInterPesq:cCaption  := "Checagem Pedidos de Venda - Protheus x SalesForce"
	aInterPesq:nLeft     := 34
	aInterPesq:nTop      := 222
	aInterPesq:nWidth    := 1200
	aInterPesq:nHeight   := 550
	aInterPesq:lShowHint := .F.
	aInterPesq:lCentered := .T.
	
	oPed      := TGet():New(017,010,{|u|If(PCount() == 0,cPed,cPed := u)},aInterPesq,050,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPed",,,,.T.,,,"Pedido:",2) 
	oBtnPesq  := TButton():New(017,080,"Ok"   ,aInterPesq,{|| MsAguarde({|| carrPesq(cPed,oPedChk,aHeadPesq)},"Aguarde","Obtendo registros...") },20,10,,,.F.,.T.,.F.,,.F.,,,.F. )	
	
	Aadd(aHeadPesq,{"Id SalesForce"     ,"IDSF" ,""  ,018, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Pedido SalesForce" ,"PEDSF",""  ,008, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Pedido Protheus"   ,"PEDPT",""  ,006, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Data"              ,"DATA",""   ,010, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Hora"              ,"HORA",""   ,010, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Método"            ,"METD" ,""  ,010, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Recno"             ,"REC"  ,""  ,020, 0,"","" ,"C","",""})
	Aadd(aHeadPesq,{"Erro"              ,"ERRO" ,""  ,200, 0,"","" ,"C","",""})		
	
	oPedChk  := MsNewGetDados():New(035,010,230,595,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,aInterPesq,aHeadPesq,@aColsPesq)
	oPedChk:oBrowse:bLDblClick := {|| alPesq(oPedChk,aHeadPesq) }
	
	oGroup1	 := TGroup():Create(aInterPesq,239,005,260,595,"",,,.T.)
	oFechar	 := TButton():New(245,550,"Fechar"   ,aInterPesq,{||aInterPesq:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )		
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
	
	aInterPesq:Activate(,,,.T.,{||.T.},,{||  })
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} alPesq
	Altera registro na tabela ZCI. 
	@type  Static Function
	@author Everson 
	@since 08/07/2019
	@version 01
	/*/
Static Function alPesq(oPedChk,aHeadPesq)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local nRecno	:= Val(Alltrim(cValToChar(oPedChk:aCols[oPedChk:nAt,Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "REC" })])) )
	
	//
	DbSelectArea("ZCI")
	ZCI->(DbGoTo(nRecno))
	MsAguarde({|| AxAltera("ZCI",nRecno,4) },"Aguarde","Selecionando registro...")

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} carrPesq
	Processa pesquisa de pedido.
	@type  Static Function
	@author Everson 
	@since 27/12/2018
	@version 01
	/*/
Static Function carrPesq(cPed,oPedidos,aHeadPesq)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cNumP 	:= "" 
	LOcal cNumS 	:= ""
	
	Default cPed	:= ""

	If Empty(cPed)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	cQuery := ""
	cQuery += "SELECT " 
	cQuery += "TOP 1 ZCI_NUMP, ZCI_PEDSAL  " 
	cQuery += "FROM " + RetSqlName("ZCI") + " (NOLOCK) AS ZCI " 
	cQuery += "WHERE  " 
	cQuery += "ZCI_FILIAL = '" + cFilAnt + "' " 
	cQuery += "AND ( ZCI_NUMP = '" + cPed + "' OR ZCI_PEDSAL = '" + cPed + "' ) " 
	cQuery += "AND ZCI.D_E_L_E_T_ = '' " 
	cQuery += "ORDER BY R_E_C_N_O_ DESC " 
	
	If Select("NUM_PED") > 0
		NUM_PED->(DbCloseArea())
		
	EndIf

	TcQuery cQuery New Alias "NUM_PED"
	DbSelectArea("NUM_PED")
	NUM_PED->(DbGoTop())
	If NUM_PED->(Eof())
		NUM_PED->(DbCloseArea())
		RestArea(aArea)
		Return Nil	
	
	EndIf
	
	cNumP := Alltrim(cValToChar(NUM_PED->ZCI_NUMP))
	cNumS := Alltrim(cValToChar(NUM_PED->ZCI_PEDSAL))
	NUM_PED->(DbCloseArea())
	
	cQuery := ""
	cQuery += "SELECT " 
	cQuery += " ZCI_IDSF, ZCI_PEDSAL, ZCI_NUMP, ZCI_DATA, ZCI_HORA, ZCI_METD, R_E_C_N_O_ AS REC, ISNULL(CONVERT(VARCHAR(MAX),ZCI_ERRO),'') AS ERRO " 
	cQuery += "FROM " + RetSqlName("ZCI") + " (NOLOCK) AS ZCI " 
	cQuery += "WHERE  " 
	cQuery += "ZCI_FILIAL = '" + cFilAnt + "' " 
	
	If Empty(cNumP)
		cQuery += "AND ZCI_PEDSAL = '" + cNumS + "' " 
		
	ElseIf Empty(cNumS)
		cQuery += "AND ZCI_NUMP = '" + cNumP + "' " 
		
	Else
		cQuery += "AND ( ZCI_NUMP = '" + cNumP + "' OR ZCI_PEDSAL = '" + cNumS + "' ) " 
	
	EndIf
	
	cQuery += "AND ZCI.D_E_L_E_T_ = '' " 
	cQuery += "ORDER BY R_E_C_N_O_  " 	

	If Select("INFO_PED") > 0
		INFO_PED->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "INFO_PED"
	DbSelectArea("INFO_PED")
	INFO_PED->(DbGoTop())	
	If ! INFO_PED->(Eof())
		
		oPedidos:aCols := {}
		
		While ! INFO_PED->(Eof())
				
			Aadd(oPedidos:aCols , Array(Len(aHeadPesq) + 1) )
			oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "IDSF"  })]	:= Alltrim(cValToChar(INFO_PED->ZCI_IDSF))
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "PEDSF" })]	:= Alltrim(cValToChar(INFO_PED->ZCI_PEDSAL))
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "PEDPT" })]	:= Alltrim(cValToChar(INFO_PED->ZCI_NUMP))
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "DATA"  })]	:= DToC(SToD(INFO_PED->ZCI_DATA)) 
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "HORA"  })]	:= Alltrim(cValToChar(INFO_PED->ZCI_HORA))
			
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "METD"  })]	:= Alltrim(cValToChar(INFO_PED->ZCI_METD))
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "REC"   })]	:= Alltrim(cValToChar(INFO_PED->REC)) 
			
			DbSelectArea("ZCI")
			ZCI->(DbGoTo(Val(cValToChar(INFO_PED->REC)) ))
			
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHeadPesq,{|x| AllTrim(x[2]) == "ERRO"  })]	:= ZCI->ZCI_ERRO
			
			INFO_PED->(DbSkip())
			
		End

	EndIf
	
	INFO_PED->(DbCloseArea())
	
	//
	oPedidos:Refresh()
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} reprocSC9
	Volta registros duplicados (SC9) para reprocessamento.
	@type  Static Function
	@author Everson 
	@since 27/07/2018
	@version 01
	/*/
Static Function reprocSC9(aHCK,oCheckPro)
	
	//Variáveis.
	Local aArea	:= GetArea()
	Local cUpda	:= ""
	Local cPed 	:= ""
	Local i		:= 1
	Local nAux	:= 0
	
	//
	If Len(oCheckPro:aCols) <= 0 .Or. Alltrim(cValToChar(oCheckPro:aCols[1][1])) = ""
		MsgAlert("Não há registros a serem reprocessados.","Função reprocSC9")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	For i := 1 To Len(oCheckPro:aCols)
	
		//Everson - 05/08/2019. Chamado TI.
		If Alltrim(cValToChar(oCheckPro:aCols[i,Ascan(aHCK,{|x| AllTrim(x[2]) == "TPERR" })])) == "1"
		
			cPed += "'" + Alltrim(cValToChar(oCheckPro:aCols[i,Ascan(aHCK,{|x| AllTrim(x[2]) == "PEDPT" })])) + "',"
			nAux++
			
		EndIf
	
	Next i
	
	//Everson - 05/08/2019. Chamado TI.
	If nAux <= 0
		MsgAlert("Não há registros a serem reprocessados.","Função reprocSC9")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If ! MsgYesNo("Deseja voltar os registros para reprocessamento?" + Chr(13) + Chr(10) + Chr(13) + Chr(10) + cPed,"Função reprocSC9")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	cPed := Substr(cPed,1,Len(cPed) -1)
	
	//
	cUpda += " UPDATE " + RetSqlName("ZCI") + " SET ZCI_TMPR = 'PENDPROC', ZCI_TPALT = 'R'  WHERE R_E_C_N_O_ IN "
	cUpda += " ( "
	cUpda += " SELECT FONTE.REC FROM "
	cUpda += " ( "
	cUpda += " 	SELECT ZCI_NUMP, MAX(R_E_C_N_O_) AS REC FROM " + RetSqlName("ZCI") + " WHERE ZCI_METD = 'PUT' AND ZCI_NUMP IN ( "
					
	cUpda +=  cPed
					
	cUpda += " ) "
	cUpda += " GROUP BY ZCI_NUMP "
	cUpda += " ) AS FONTE "
	cUpda += " ) "
	
	If (TCSqlExec(cUpda)) < 0
		MsgAlert("Não foi possível retornar os regitros para reprocessamento TCSQLError() " + TCSQLError(),"Função reprocSC9")
    
    EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} getZCI
	Abre o registro na tabe ZCI.
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function getZCI(oObjeto,aCabec)
	
	//Variáveis.
	Local aArea := GetArea()
	Local cIDSF := Alltrim(cValToChar(oObjeto:aCols[oObjeto:nAt,Ascan(aCabec,{|x| AllTrim(x[2]) == "IDSF" })]))
	Local cQuery:= ""
	
	Private cCadastro := "Registro ZCI" 
	
	//
	If Empty(cIDSF)
		MsgStop("Não possível obter o Id do SF.","Função getZCI")
		RestArea(aArea)
		Return Nil
		
	EndIf	
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZCI_IDSF, MAX(ZCI.R_E_C_N_O_) AS REC " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZCI") + " (NOLOCK) AS ZCI " 
	cQuery += " WHERE " 
	cQuery += " ZCI_FILIAL = '" + xFilial("ZCI") + "' " 
	cQuery += " AND ZCI_IDSF = '" + cIDSF + "' " 
	cQuery += " AND (SUBSTRING(RTRIM(LTRIM(ISNULL(CONVERT(VARCHAR(MAX),ZCI_ERRO),''))),1,32) <> 'Alteração enviada em duplicidade') "
	cQuery += " AND ZCI.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY ZCI_IDSF " 
	
	//
	If Select("REG_ZCI") > 0
		REG_ZCI->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "REG_ZCI"
	DbSelectArea("REG_ZCI")
	REG_ZCI->(DbGoTop())
	If ! REG_ZCI->(Eof())
		DbSelectArea("ZCI")
		ZCI->(DbGoTo(Val(cValToChar( REG_ZCI->REC ))))
		AxAltera("ZCI",Val(cValToChar( REG_ZCI->REC )),4)
	
	Else
		MsgStop("Não possível localizar o registro na tabela ZCI.","Função getZCI")
		
	EndIf
	
	//
	REG_ZCI->(DbCloseArea())
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} solicIndPed
	Solicitação de reenvio de pedido de venda.
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function solicIndPed(cIDSF)
	
	//Variáveis.
	Local aArea := GetArea()
	Local cJson	:= ""
	Local aId   := {}
	
	//
	If ! MsgYesNo("Deseja realizar a solicitação de reenvio de pedido?","Função solicIndPed")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	cIDSF := Alltrim(cValToChar(cIDSF))
	
	//
	If Empty(cIDSF)
		MsgStop("Não possível obter o Id do SF.","Função solicIndPed")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	Aadd(aId,cIDSF)
	cJson := FWJsonSerialize(aId,.F.,.F.)
	MsAguarde({|| envSolic(cJson) },"Aguarde","Enviando solicitação...")

	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} atuaVetor
	Atualiza informações. 
	@type  Static Function
	@author Everson 
	@since 18/06/2018
	@version 01
	/*/
Static Function atuaVetor(oPedidos,aHPv,oTotPT,oTotSF,oTotEr,oBandVer,aHBV,oTotBV,oSay1,oSay2,oCheckPro,aHCK,oSay3,oTotErr)
	
	//Variáveis.
	Local aArea	   	:= GetArea()
	Local lRetP		:= .T.
	Local oError	:= ErrorBlock({|e| lRetP := .F., MsgStop("Houve erro ao obter os dados do Salesforce " + Chr(10) + Chr(13) + e:Description,"Função atuaVetor(ADVEN097P)") }) ////Everson - 18/06/2020. Chamado 059048.
	
	//Everson - 18/06/2020. Chamado 059048.
	MsAguarde({|| getVetorPv(@oError,@lRetP,oPedidos,aHPv,oTotPT,oTotSF,oTotEr)},"Aguarde","Obtendo dados de pedidos de venda...")
		
	//Everson - 18/06/2020. Chamado 059048.
	MsAguarde({|| getVetorBV(@oError,@lRetP,oBandVer,aHBV,oTotBV)},"Aguarde","Obtendo bandeiras vermelhas...")

	//
	MsAguarde({|| getCheckPro(oCheckPro,aHCK,oTotErr)},"Aguarde","Carregando check do Protheus...")

	//
	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} getVetorPv
	Query de consulta de pedidos no SalesForce. 
	@type  Static Function
	@author Everson 
	@since 15/06/2018
	@version 01
	/*/
Static Function getVetorPv(oError,lRetP,oPedidos,aHPv,oTotPT,oTotSF,oTotEr)
	
	//Variáveis.
	Local aArea	   	:= GetArea()
	Local i		   	:= 1
	Local aDadosSF 	:= {}
	Local cQuery   	:= ""
	Local cPedProth	:= ""
	Local cErro    	:= ""
	Local oParseJSON:= Nil
	Local lRetSF	:= .F.

	//Everson - 18/06/2020. Chamado 059048.
	Begin Sequence

		//
		oPedidos:aCols := {}
		oPedidos:Refresh()
		
		//
		MsAguarde({|| acessaSF(@oParseJSON,@lRetSF)},"Aguarde","Obtendo dados do SalesForce...")
		If ! lRetSF
			Aadd(oPedidos:aCols , Array(Len(aHPv) + 1) )
			oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.	
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDPT" })] := ""
			oPedidos:Refresh()
			RestArea(aArea)
			Return Nil
			
		EndIf
		
		//
		nTotSF := 0
		
		//
		nTotEr := 0
		oTotEr:Refresh()
	
		//
		For i := 1 To Len(oParseJSON:records)
			
			If ! (Empty(Alltrim(cValToChar(oParseJSON:records[i]:Codigo_Protheus__c)))) .Or.;
			( Empty(Alltrim(cValToChar(oParseJSON:records[i]:Codigo_Protheus__c))) .And. Upper(Alltrim(cValToChar(DecodeUTF8(oParseJSON:records[i]:Status)))) <> "CANCELADO" .And. Upper(Alltrim(cValToChar(DecodeUTF8(oParseJSON:records[i]:Status)))) <> "COTAÇÃO" )

				//Everson, 18/02/2020. Chamado TI.
				oVend := oParseJSON:RECORDS[i]:VENDEDOR__R
				oSup  := oParseJSON:RECORDS[i]:SUPERVISOR__R

				Aadd(aDadosSF,{;
							"",;
							oParseJSON:records[i]:Codigo_Protheus__c,;
							oParseJSON:records[i]:OrderNumber,;
							StrTran(cValToChar(oParseJSON:records[i]:Data__c),"-",""),;
							DecodeUTF8(oParseJSON:records[i]:Status),;
							oParseJSON:records[i]:Codigo_Cliente__c,;
							oParseJSON:records[i]:Rede__c,;
							oParseJSON:records[i]:Volume_total_de_Caixas__c,;
							oParseJSON:records[i]:TotalAmount,;
							oParseJSON:records[i]:Id,;
							oVend:FIRSTNAME,;//oVend["CODIGO_VENDEDOR_C"];
							oSup:FIRSTNAME;//oSup["FIRSTNAME"]; //Everson, 18/02/2020. Chamado TI.
						})
			
				//		
				If !(Upper(Alltrim(cValToChar(DecodeUTF8(oParseJSON:records[i]:Status)))) == "CANCELADO" .Or. Upper(Alltrim(cValToChar(DecodeUTF8(oParseJSON:records[i]:Status)))) == "REPROVADO FINANCEIRO" )
					nTotSF++
				
				EndIf
			
			EndIf
		
		Next i

		//
		oTotSF:Refresh()
		
		//
		cQuery := sqlSC5()
		
		If Select("DADOS_SC5") > 0
			DADOS_SC5->(DbCloseArea())
			
		EndIf
		
		//
		TcQuery cQuery New Alias "DADOS_SC5"
		DbSelectArea("DADOS_SC5")
		DADOS_SC5->(DbGoTop())
		
		//
		nTotPT  := 0
		nTBlqP  := 0
		nTBlqS	:= 0
		oTBlqP:Refresh()
		oTBlqS:Refresh()
		While ! DADOS_SC5->(Eof())
		
			//
			nTotPT++
		
			//
			cPedProth := Alltrim(cValToChar(DADOS_SC5->C5_NUM))
		
			//
			nPosSF := 0
			nPosSF := Ascan(aDadosSF,{|x| AllTrim(cValToChar(x[2])) == cPedProth })
			
			cErro := ""
			If nPosSF > 0
				
				//
				If Val(cValToChar(DADOS_SC5->VALOR)) <> Round(Val(cValToChar(aDadosSF[nPosSF][9])),2)
				
					If (Val(cValToChar(DADOS_SC5->VALOR)) - Round(Val(cValToChar(aDadosSF[nPosSF][9])),2)) > 0.01 .Or.;
					(Val(cValToChar(DADOS_SC5->VALOR)) - Round(Val(cValToChar(aDadosSF[nPosSF][9])),2)) < -0.01
						cErro := "Valores divergentes"
					
					EndIf
					
				ElseIf Alltrim(cValToChar(DADOS_SC5->ENTREGA)) <> Alltrim(cValToChar(aDadosSF[nPosSF][4]))
					cErro := "Datas de entrega divergentes"
					
				//ElseIf (Alltrim(cValToChar(DADOS_SC5->LIB)) == "N") .And. ("PENDENTE" $(Upper(Alltrim(cValToChar(aDadosSF[nPosSF][5])))) )
					//cErro := "Pedido liberado Protheus, bloqueado SalesForce"
				
				ElseIf (Alltrim(cValToChar(DADOS_SC5->LIB)) == "S") .And. ("APROVADO" $( Upper(Alltrim(cValToChar(aDadosSF[nPosSF][5]))) ) )
					cErro := "Pedido bloqueado Protheus, liberado SalesForce"

				ElseIf ("COTA" $( Upper(Alltrim(cValToChar(aDadosSF[nPosSF][5]))) ) )
					cErro := "Pedido está como cotação no SalesForce"
													
				Else
					cErro := ""
					
				EndIf
				
				//
				If (Alltrim(cValToChar(DADOS_SC5->LIB)) == "S")
					nTBlqP++
				
				EndIf
				
				//
				If ("PENDENTE" $(Upper(Alltrim(cValToChar(aDadosSF[nPosSF][5])))))
					nTBlqS++
					
				EndIf
				
				//Conout( "APROVADO " + cValToChar("APROVADO" $( Upper(Alltrim(cValToChar(aDadosSF[nPosSF][5]))) )) + " - " + Upper(Alltrim(cValToChar(aDadosSF[nPosSF][5])))  )
				
				//
				If ! Empty(cErro)
					Aadd(oPedidos:aCols , Array(Len(aHPv) + 1) )
					oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDPT" })]    := cPedProth
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VLRPT" })]    := Val(cValToChar(DADOS_SC5->VALOR))
					
					//Everson, 18/02/2020. Chamado TI.
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VEND" })]     := Alltrim(cValToChar(DADOS_SC5->C5_VEND1))
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "SUPER" })]     := Alltrim(cValToChar(DADOS_SC5->A3_SUPER))
					
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDSF" })]    := Alltrim(cValToChar(aDadosSF[nPosSF][3]))
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VLRSF" })]    := Val(cValToChar(aDadosSF[nPosSF][9]))
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "SFSTATUS" })] := Alltrim(cValToChar(aDadosSF[nPosSF][5]))
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ERRO" })]     := cErro
					
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ENTPT" })]    := DToC(SToD(DADOS_SC5->ENTREGA)) 
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ENTSF" })]    := DToC(SToD(aDadosSF[nPosSF][4])) 
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "IDSF" })]     := Alltrim(cValToChar(aDadosSF[nPosSF][10]))
					
					nTotEr++
					
				EndIf
				
				aDadosSF[nPosSF][1] := "X"
				
			Else
			
				Aadd(oPedidos:aCols , Array(Len(aHPv) + 1) )
				oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.

				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDPT" })] := cPedProth
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VLRPT" })] := Val(cValToChar(DADOS_SC5->VALOR))
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDSF" })] := Alltrim(cValToChar(C5_XSFPED))
				
				//Everson, 18/02/2020. Chamado TI.
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VEND" })]  := Alltrim(cValToChar(DADOS_SC5->C5_VEND1))
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "SUPER" })] := Alltrim(cValToChar(DADOS_SC5->A3_SUPER))

				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ERRO" })]  := "Pedido não localizado no SalesForce"

				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ENTPT" })] := DToC(SToD(DADOS_SC5->ENTREGA)) 
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "IDSF" })]  := Alltrim(cValToChar(C5_XPEDSAL))
								
				nTotEr++
				
			EndIf
		
			DADOS_SC5->(DbSkip())
			
		EndDo
		
		DADOS_SC5->(DbCloseArea())
		
		//Preenche o aCols com os pedidos do SalesForce que não foram encontrados no Protheus.
		For i := 1 To Len(aDadosSF)
			lEncPed := .F.
			SET DELETED off //mostra os registros excluidos.
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			SC5->(DbGoTop())
			If SC5->(DbSeek( xFilial("SC5") + Alltrim(cValToChar(aDadosSF[i][2])) ))
			If Deleted() 
				lEncPed := .T.
				If (Upper(Alltrim(cValToChar(aDadosSF[i][5]))) == "CANCELADO" .Or. Upper(Alltrim(cValToChar(aDadosSF[i][5]))) == "REPROVADO FINANCEIRO" )
					lEncPed := .T.
					aDadosSF[i][1] := "X"
				
				EndIf
				
			EndIf
			
			EndIf
			
			SET DELETED On
		
			//Conout( "APROVADO " + cValToChar("APROVADO" $( Upper(Alltrim(cValToChar(aDadosSF[i][5]))) )) + " - " + Upper(Alltrim(cValToChar(aDadosSF[i][5])))  )
		
			If Empty(Alltrim(cValToChar(aDadosSF[i][1]))) .And. ! lEncPed
			
				Aadd(oPedidos:aCols , Array(Len(aHPv) + 1) )
				oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.			

				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDPT" })]    := Alltrim(cValToChar(aDadosSF[i][2]))
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VLRPT" })]    := 0
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDSF" })]    := Alltrim(cValToChar(aDadosSF[i][3]))
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VLRSF" })]    := Val(cValToChar(aDadosSF[i][9]))
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "SFSTATUS" })] := Alltrim(cValToChar(aDadosSF[i][5]))
				
				//Everson, 18/02/2020. Chamado TI.
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "VEND" })] 	   := Alltrim(cValToChar(aDadosSF[i][11]))
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "SUPER" })]    := Alltrim(cValToChar(aDadosSF[i][12]))
				
				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ENTSF" })]    := Alltrim(cValToChar(aDadosSF[i][4])) 
				
				If lEncPed
					//oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ERRO" })]     := "Pedido excluído do Protheus"
					
				Else
					oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "ERRO" })]     := "Pedido não localizado no Protheus"
				
				EndIf

				oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "IDSF" })]     := Alltrim(cValToChar(aDadosSF[i][10]))
				
				nTotEr++
							
			EndIf
		
		Next i
		
		//Se não houver dados, é inserida uma linha no objeto para não haver erro.
		If Len(oPedidos:aCols) <= 0
			Aadd(oPedidos:aCols , Array(Len(aHPv) + 1) )
			oPedidos:aCols[Len(oPedidos:aCols), Len(oPedidos:aCols[1]) ] := .F.	
			oPedidos:aCols[Len(oPedidos:aCols),Ascan(aHPv,{|x| AllTrim(x[2]) == "PEDPT" })] := ""
						
		EndIf
		
		//
		oPedidos:Refresh()
		oTotPT:Refresh()
		oTotEr:Refresh()
		oTBlqP:Refresh()
		oTBlqS:Refresh()

	End Sequence

	//
	ErrorBlock(oError) //Everson - 18/06/2020. Chamado 059048.
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} getVetorBV
	Query de consulta de bandeira vermelha no SalesForce.  
	@type  Static Function
	@author Everson 
	@since 18/06/2018
	@version 01
	/*/
Static Function getVetorBV(oError,lRetP,oBandVer,aHBV,oTotBV)
	
	//Variáveis.
	Local aArea	   	:= GetArea()
	Local i		   	:= 1
	Local oParseJSON:= Nil
	Local lRetSF	:= .F.
	
	//Everson - 18/06/2020. Chamado 059048.
	Begin Sequence

		//
		oBandVer:aCols := {}
		oBandVer:Refresh()
		
		nTotBV := 0
		oTotBV:Refresh()
		
		//
		MsAguarde({|| acessaSF(@oParseJSON,@lRetSF,2)},"Aguarde","Obtendo dados do SalesForce (BV)...")
		If ! lRetSF
			Aadd(oBandVer:aCols , Array(Len(aHBV) + 1) )
			oBandVer:aCols[Len(oBandVer:aCols), Len(oBandVer:aCols[1]) ] := .F.	
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "PEDPT" })] := ""
			oBandVer:Refresh()
			RestArea(aArea)
			Return Nil
			
		EndIf
		
		//
		nTotBV := Len(oParseJSON:records)
		oTotBV:Refresh()
		
		//
		For i := 1 To Len(oParseJSON:records)
			
			Aadd(oBandVer:aCols , Array(Len(aHBV) + 1) )
			oBandVer:aCols[Len(oBandVer:aCols), Len(oBandVer:aCols[1]) ] := .F.
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "IDSF" })]    := Alltrim(cValToChar(oParseJSON:records[i]:Id))
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "PEDPT" })]   := Alltrim(cValToChar(oParseJSON:records[i]:Codigo_Protheus__c))
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "ENTSF" })]   := DToC(SToD(StrTran(cValToChar(oParseJSON:records[i]:Data__c),"-","")))
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "SFSTATUS" })]:= Alltrim(cValToChar(oParseJSON:records[i]:Status))
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "PEDSF" })]   := Alltrim(cValToChar(oParseJSON:records[i]:OrderNumber))
					
		Next i

		//Se não houver dados, é inserida uma linha no objeto para não haver erro.
		If Len(oBandVer:aCols) <= 0
			Aadd(oBandVer:aCols , Array(Len(aHBV) + 1) )
			oBandVer:aCols[Len(oBandVer:aCols), Len(oBandVer:aCols[1]) ] := .F.	
			oBandVer:aCols[Len(oBandVer:aCols),Ascan(aHBV,{|x| AllTrim(x[2]) == "PEDPT" })] := ""
						
		EndIf
			
		//
		oBandVer:Refresh()

	//
	End Sequence

	//
	ErrorBlock(oError) //Everson - 18/06/2020. Chamado 059048.
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} getCheckPro
	Carrega erros do Protheus.  
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function getCheckPro(oCheckPro,aHCK,oTotErr)

	//Variáveis.
	Local aArea	   	:= GetArea()
	Local i		   	:= 1
	Local cQuery 	:= scriptChkProth()

	//
	oCheckPro:aCols := {}
	oCheckPro:Refresh()
	nTotErr := 0
	oTotErr:Refresh()
	
	//
	If Select("CHK_PRO") > 0
		CHK_PRO->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "CHK_PRO"
	DbSelectArea("CHK_PRO")
	CHK_PRO->(DbGoTop())
	While ! CHK_PRO->(Eof())

		Aadd(oCheckPro:aCols , Array(Len(aHCK) + 1) )
		oCheckPro:aCols[Len(oCheckPro:aCols), Len(oCheckPro:aCols[1]) ] := .F.
			
		oCheckPro:aCols[Len(oCheckPro:aCols),Ascan(aHCK,{|x| AllTrim(x[2]) == "IDSF" })]  := Alltrim(cValToChar(CHK_PRO->C5_XPEDSAL))
		oCheckPro:aCols[Len(oCheckPro:aCols),Ascan(aHCK,{|x| AllTrim(x[2]) == "PEDSF" })] := Alltrim(cValToChar(CHK_PRO->C5_XSFPED))
		oCheckPro:aCols[Len(oCheckPro:aCols),Ascan(aHCK,{|x| AllTrim(x[2]) == "PEDPT" })] := Alltrim(cValToChar(CHK_PRO->C5_NUM))
		oCheckPro:aCols[Len(oCheckPro:aCols),Ascan(aHCK,{|x| AllTrim(x[2]) == "ERRO" })]  := Alltrim(cValToChar(CHK_PRO->ERRO))
		oCheckPro:aCols[Len(oCheckPro:aCols),Ascan(aHCK,{|x| AllTrim(x[2]) == "TPERR" })] := Alltrim(cValToChar(CHK_PRO->TIPO))
		nTotErr++
				
		CHK_PRO->(DbSkip())
		
	EndDo

	//Se não houver dados, é inserida uma linha no objeto para não haver erro.
	If Len(oCheckPro:aCols) <= 0
		Aadd(oCheckPro:aCols , Array(Len(aHCK) + 1) )
		oCheckPro:aCols[Len(oCheckPro:aCols), Len(oCheckPro:aCols[1]) ] := .F.	
		oCheckPro:aCols[Len(oCheckPro:aCols),Ascan(aHCK,{|x| AllTrim(x[2]) == "PEDPT" })] := ""
					
	EndIf
		
	//
	oCheckPro:Refresh()
	oTotErr:Refresh()
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} acessaSF
	Rotina para obter dados no SalesForce.  
	@type  Static Function
	@author Everson 
	@since 15/06/2018
	@version 01
	/*/
Static Function acessaSF(oParseJSON,lRetSF,nOpc,lAut,cPedS)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aResponse	:= {}
	Local cMsg		:= ""
	Local lLogin	:= .F.
	Local cQuery	:= ""
	Local cqueryPVSF	:= ""
	Local cServTab	:= "/services/data/v45.0/query?q="
	
	Default nOpc	:= 1
	Default lAut	:= .F.
	Default cPedS	:= ""
	
	Conout("ADVEN097P - Início rotina acessaSF / nOpc " + cValToChar(nOpc))

	//Efetura login no SalesForce.
	lLogin := StaticCall(ADVEN075P,loginSF,@aResponse,@cMsg,lAut)

	//
	If ! lLogin
	
		//
		If ! lAut
			MsgStop("Não foi possível efetuar login no SalesForce.","Função acessaSF - ADVEN097P")
		
		Else
			Conout("ADVEN097P - Não foi possível efetuar login no SalesForce.")
			
		EndIf
		
		RestArea(aArea)
		lRetSF := .F.
		Return lRetSF

	EndIf
	
	//
	If nOpc == 1
		cqueryPVSF := queryPVSF()
	
	ElseIf nOpc == 2
		cqueryPVSF := queryBVSF()
		
	ElseIf nOpc == 3
		cqueryPVSF := queryPVDP(cPedS)
		
	EndIf
	
	//
	If ! U_ADVEN075P(cServTab + cqueryPVSF,"GET","",@cMsg,aResponse)
		cMsg :=  Alltrim(cValToChar(cMsg))
		If ! lAut
			MsgStop("Ocorreu erro na consulta no SalesForce:" + Chr(13) + Chr(10) + cMsg,"Função acessaSF - ADVEN097P")
		
		Else
			Conout("ADVEN097P - Ocorreu erro na consulta no SalesForce:" + Chr(13) + Chr(10) + cMsg)
			
		EndIf
		
		RestArea(aArea)
		lRetSF := .F.
		Return lRetSF
	
	EndIf
	
	//
	If ! FWJsonDeserialize(cMsg, @oParseJSON)
		cMsg := "Ocorreu erro na desserialização do json com os dados de login (Função acessaSF - ADVEN097P)." + Chr(13) + Chr(10) + "Json: " + Chr(13) + Chr(10) + cMsg
		If ! lAut
			StaticCall(ADVEN075P,TelErro,"Consulta SalesForce - acessaSF - ADVEN097P",cValToChar(cMsg),"Arial",10,,.F.,.T.)
		
		Else
			Conout("ADVEN097P - " + cMsg)
			
		EndIF
		
		RestArea(aArea)
		lRetSF := .F.
		Return lRetSF
			
	EndIf

	//
	RestArea(aArea)
	
	//
	lRetSF := .T.
		
Return lRetSF
/*/{Protheus.doc} queryPVSF
	Query de consulta de pedidos no SalesForce. 
	@type  Static Function
	@author Everson 
	@since 15/06/2018
	@version 01
	/*/
Static Function queryPVSF()
	
	//Variáveis.
	Local aArea	 := GetArea()	
	Local cQuery := ""
	
	Local cDtDe  := DtoS(MV_PAR01)
	Local cDtAte := DtoS(MV_PAR02)
	
	//
	cDtDe  := Substr(cDtDe ,1,4) + "-" + Substr(cDtDe ,5,2) + "-" + Substr(cDtDe ,7,2)
	cDtAte := Substr(cDtAte,1,4) + "-" + Substr(cDtAte,5,2) + "-" + Substr(cDtAte,7,2)
	
	//
	cQuery := ""
	cQuery += "Select+Id,+"
	cQuery += "OrderNumber,+Codigo_Protheus__c,+Data__c,+Status,+Codigo_Cliente__c,+Rede__c,+Volume_total_de_Caixas__c,+TotalAmount,+Vendedor__r.FirstName,+Vendedor__r.Codigo_Vendedor__c,"
	cQuery += "+Supervisor__r.FirstName+From+Order+WHERE+Data__c+>=+" + cDtDe + "+AND+Data__c+<=+" + cDtAte

	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} queryBVSF
	Query de consulta de bandeira vermelha no SalesForce. 
	@type  Static Function
	@author Everson 
	@since 19/06/2018
	@version 01
	/*/
Static Function queryBVSF()
	
	//Variáveis.
	Local aArea	 := GetArea()	
	Local cQuery := ""
	
	Local cDtDe  := DtoS(MV_PAR01)
	Local cDtAte := DtoS(MV_PAR02)
	
	//
	cDtDe  := Substr(cDtDe ,1,4) + "-" + Substr(cDtDe ,5,2) + "-" + Substr(cDtDe ,7,2)
	cDtAte := Substr(cDtAte,1,4) + "-" + Substr(cDtAte,5,2) + "-" + Substr(cDtAte,7,2)
	
	//
	cQuery := ""
	cQuery += "Select+Id,+"
	cQuery += "OrderNumber,+Codigo_Protheus__c,+Data__c,+Status,+Codigo_Cliente__c,+Rede__c,+Volume_total_de_Caixas__c,+TotalAmount,+Vendedor__r.FirstName,"
	cQuery += "+Supervisor__r.FirstName+From+Order+WHERE+Data__c+>=+" + cDtDe + "+AND+Data__c+<=+" + cDtAte + "+AND+Codigo_Protheus__c+<>+''+AND+Integracao_Protheus__c+like+'%25red%25' "
	
	
	//cQuery := ""
	//cQuery += "Select+Id,+OrderNumber,+Codigo_Protheus__c,+Data__c,+Status,+Codigo_Cliente__c,+Rede__c,+Volume_total_de_Caixas__c,+TotalAmount,+" 
	//cQuery += "Integracao_Protheus__c+From+Order+WHERE+Data__c+>=+" + cDtDe + "+AND+Data__c+<=" + cDtAte + "+AND+Integracao_Protheus__c+like+'%red%'AND+Status+<>+'Cancelado'+AND+Codigo_Protheus__c+<>+''"
	
	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} queryPVDP
	Query de consulta de pedido  no SalesForce.
	@type  Static Function
	@author Everson 
	@since 05/08/2019
	@version 01
	/*/
Static Function queryPVDP(cPedS)
	
	//Variáveis.
	Local aArea	 := GetArea()	
	Local cQuery := ""
	
	//
	cQuery := "SELECT+Codigo_Protheus__c+FROM+Order+WHERE+OrderNumber+=+'" + cPedS + "'"

	//
	RestArea(aArea)
	
Return cQuery
/*/{Protheus.doc} sqlSC5
	Query de consulta de pedidos no Protheus. 
	@type  Static Function
	@author Everson 
	@since 18/06/2018
	@version 01
	/*/
Static Function sqlSC5()
	
	//Variáveis.
	Local cQuery := ""
	
	cQuery := ""
	cQuery += " SELECT " 
		cQuery += " C5_NUM,   " 
		cQuery += " CASE WHEN C5_BLQ = '1' THEN 'S' ELSE 'N' END AS LIB, SC5.D_E_L_E_T_ AS DEL, " 
		cQuery += " C5_EMISSAO AS EMISSAO,   " 
		cQuery += " C5_DTENTR  AS ENTREGA,   " 
		cQuery += " C5_CLIENT,   " 
		cQuery += " C5_XPEDSAL,   " 
		cQuery += " C5_XSFPED, " 
		cQuery += " ACUMU.CX AS CX,   " 
		cQuery += " ACUMU.KG AS KG,   " 
		cQuery += " ACUMU.VALORT AS VALOR, C5_VEND1, A3_SUPER  " //Everson, 18/02/2020. Chamado TI.

	cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN  " 
		cQuery += " (    " 
		cQuery += " SELECT C6_FILIAL AS FIL, C6_NUM AS NUM, C6_CLI, C6_LOJA,SUM(C6_VALOR) AS VALORT, SUM(C6_QTDVEN) AS KG, SUM(C6_UNSVEN) AS CX FROM  " + RetSqlName("SC6") + "  (NOLOCK) WHERE D_E_L_E_T_ = ''  GROUP BY C6_FILIAL, C6_NUM, C6_CLI, C6_LOJA  " 
		cQuery += " ) AS ACUMU   " 
		cQuery += " ON C5_FILIAL = ACUMU.FIL   " 
		cQuery += " AND C5_NUM = ACUMU.NUM  " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("SA3") + " (NOLOCK)  AS SA3   " 
		cQuery += " ON C5_VEND1 = A3_COD  " 

	cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + xFilial("SC5") + "'   " 
		cQuery += " AND C5_DTENTR >= " + DtoS(MV_PAR01) + "   " 
		cQuery += " AND C5_DTENTR <= " + DtoS(MV_PAR02) + "   " 
		cQuery += " AND (C5_XGERSF = '2' OR (C5_XGERSF = '1' AND C5_XPEDSAL <> '' AND C5_NOTA NOT IN ('XXXXXXXXX','') AND C5_SERIE <> '' ) )   " 
		cQuery += " AND C5_NUM <> ''   " 
		//cQuery += " AND SC5.D_E_L_E_T_ ='' " 
		cQuery += " AND SA3.D_E_L_E_T_ = '' " 

	cQuery += " ORDER BY C5_FILIAL, C5_NUM " 
	
Return cQuery
/*/{Protheus.doc} gerarReenv
	Gera arquivo com código SalesForce para reenvio de pedidos.
	@type  Static Function
	@author Everson 
	@since 18/06/2018
	@version 01
	/*/
Static Function gerarReenv(oObjeto,aHeader)
	
	//Variáveis.
	Local aArea	  := GetArea()
	Local cString := ""
	Local i		  := 1
	Local nRet	  := 32
	Local cDir	  := "C:\TEMP\"
	Local cArq	  := "SFCODIGO" + DToS(Date()) + ".TXT"
	Local aAux	  := 0
	
	//
	If Len(oObjeto:aCols) <= 0
		MsgStop("Não há dados para gerar o arquivo.","Função gerarReenv")
		Return Nil
		
	EndIf
	
	//
	cString += "List<Id> PedidosIntegrar = new List<Id>();" + Chr(13) + Chr(10)
	aAux := 0
	For i := 1 To Len(oObjeto:aCols)
		
		If Alltrim(cValToChar(oObjeto:aCols[i,Ascan(aHeader,{|x| AllTrim(x[2]) == "IDSF" })] )) <> ""
			cString += "PedidosIntegrar.add('" + Alltrim(cValToChar(oObjeto:aCols[i,Ascan(aHeader,{|x| AllTrim(x[2]) == "IDSF" })] )) + "');" + Chr(13) + Chr(10)
			aAux++
			
		EndIf
		
	Next i
	cString += "BatchEnviaPedido bep= new BatchEnviaPedido();" + Chr(13) + Chr(10)
	cString += "bep.BatchEnviaPedido(PedidosIntegrar);" + Chr(13) + Chr(10)               
	cString += "database.executeBatch(bep, 1);" + Chr(13) + Chr(10)
	
	//
	If aAux <= 0
		MsgStop("Não há registros com o código do SalesForce para gerar o bloco de código.","Função gerarReenv")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	Memowrite( cDir + cArq,cString)
		
	//Tenta abrir o arquivo.
    nRet := ShellExecute("open", cArq, "", cDir, 1)
     
    //Se houver algum erro.
    If nRet <= 32
        MsgStop("Não foi possível abrir o arquivo " +cDirP+cNomeArqP+ ".","Função gerarReenv")
        
    EndIf
    
    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} gerarReenv
	Solicitação de reenvio de pedidos de venda os SalesForce.
	@type  Static Function
	@author Everson 
	@since 25/07/2018
	@version 01
	/*/
Static Function carSolic(oObjeto,aHeader)
	
	//Variáveis.
	Local aArea	    := GetArea()
	Local i			:= 1
	Local aIds		:= {}
	Local cJson	    := ""
	
	//
	If Len(oObjeto:aCols) <= 0
		MsgStop("Não há dados a serem enviados.","Função carSolic")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	For i := 1 To Len(oObjeto:aCols)
		
		If Alltrim(cValToChar(oObjeto:aCols[i,Ascan(aHeader,{|x| AllTrim(x[2]) == "IDSF" })] )) <> ""
			Aadd(aIds,Alltrim(cValToChar(oObjeto:aCols[i,Ascan(aHeader,{|x| AllTrim(x[2]) == "IDSF" })] )))
		
		EndIf
		
	Next i

	//
	If Len(aIds) <= 0
		MsgStop("Não há dados a serem enviados.","Função carSolic")
		RestArea(aArea)
		Return Nil
		
	EndIf

	//
	cJson := FWJsonSerialize(aIds,.F.,.F.)
	MsAguarde({|| envSolic(cJson) } ,"Aguarde","Enviando solicitação...")
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} envSolic
	Envia solicitação de reenvio de pedidos de venda os 
	SalesForce.
	@type  Static Function
	@author Everson 
	@since 25/07/2018
	@version 01
	/*/
Static Function envSolic(cString,lAut)
	
	//Variáveis.
	Local aArea	   := GetArea()
	Local cServico := "/services/apexrest/bandeiravermelha"
	Local cMetodo  := "POST"
	Local cBody    := cString
	Local cMsg	   := ""
	Local lRet	   := .F.
	
	Default lAut   := .F.
	
	//
	lRet := U_ADVEN075P(cServico,cMetodo,cBody,@cMsg,{})
	
	//
	If lRet 
		If ! lAut
			MsgInfo("Requesição enviada com suscesso. Id: " + cValToChar(cMsg) ,"Função cString ")
		
		Else
			Conout("ADVEN097P - Requesição enviada com suscesso. Id: " + cValToChar(cMsg))
			
		EndIf
		
	Else
		If ! lAut
			MsgInfo("Houve falha no envio da requisição. Erro: " + Chr(13) + Chr(10) + cValToChar(cMsg),"Função cString ")
		
		Else
			Conout("ADVEN097P - Houve falha no envio da requisição. Erro: " + Chr(13) + Chr(10) + cValToChar(cMsg))
			
		EndIf
				
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} impCSVLV
	Função para importação de CSV. 
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function impCSVLV()
	
	//
	Processa({|| procCSV() },"Aguarde","Processando registros...")
	
Return Nil
/*/{Protheus.doc} procCSV
	Função processa importação de CSV. 
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function procCSV()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cArq		:= ""
	Local nHdl  	:= 0
	Local nTotLinhas:= 0
	Local cBuffer	:= ""
	Local cPedido   := ""
	Local nQtdPed	:= 0
	Local aIDSF		:= {}
	Local cJson     := ""
	
	//
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		MsgStop( "Não foi possível obter o arquivo.","Função procCSV (ADVEN097P)")
		Return Nil

	Endif
	
	//Abre o arquivo.
	nHdl := FT_FUse(cArq)

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq,"Função lerArquivo")
		Return Nil

	Endif
	
	//
	FT_FGoTop()

	//Obtém a quantidade de linhas.
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da régua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	FT_FGoto(1)

	//Percorre arquivo.
	While ! FT_FEof()
	
		//
		cBuffer  := Alltrim(cValToChar(DecodeUTF8(FT_FReadln())))

		If ! Empty(cBuffer)

			cPedido	 += "'" + Alltrim(cValToChar(cBuffer)) + "',"
			nQtdPed++
			
		EndIf

		FT_FSkip()

	EndDo
	
	//
	If nQtdPed <= 0
		If nHdl <> -1
			FT_FUse(cArq)

		EndIf
		
		MsgStop("Não há dados a serem processados.","Função procCSV (ADVEN097P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If ! MsgYesNo("Serão processados " + cValToChar(nQtdPed) + " registros.Deseja prosseguir?","Função procCSV (ADVEN097P)")
		If nHdl <> -1
			FT_FUse(cArq)

		EndIf
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If nHdl <> -1
		FT_FUse(cArq)

	EndIf
	
	//
	aIDSF := getIdSF(cPedido)
	If Len(aIDSF) <= 0		
		MsgStop("Não há dados a serem processados.","Função procCSV (ADVEN097P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	cJson := FWJsonSerialize(aIDSF,.F.,.F.)
	
	//
	MsAguarde({|| envSolic(cJson) },"Aguarde","Enviando solicitação...")
	
	//
	MsgInfo("Processamento concluído.","Função procCSV (ADVEN097P)")
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} getIdSF
	Obtém os Ids do SalesForce.
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function getIdSF(cPedido)

	//Variáveis.	
	Local aArea := GetArea()
	Local cQuery:= ""
	Local aIDSF := {}
	
	//
	cPedido := Substr(cPedido,1,Len(cPedido) -1)
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " C5_XPEDSAL " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + cFilAnt + "' " 
	cQuery += " AND C5_XGERSF = '2' " 
	cQuery += " AND C5_XPEDSAL <> '' " 
	cQuery += " AND C5_NUM IN (" + cPedido + ") " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	
	//
	If Select("ID_SF") > 0
		ID_SF->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "ID_SF"
	DbSelectArea("ID_SF")
	ID_SF->(DbGoTop())
	While ! ID_SF->(Eof())
		
		Aadd(aIDSF, Alltrim(cValToChar(ID_SF->C5_XPEDSAL)) )
		
		ID_SF->(DbSkip())
	EndDo
	
	//
	RestArea(aArea)
	
Return aIDSF
/*/{Protheus.doc} scriptChkProth
	Checa divergências no Protheus.
	@type  Static Function
	@author Everson 
	@since 26/07/2018
	@version 01
	/*/
Static Function scriptChkProth()

	//Variáveis.
	Local cQuery := ""
	
	cQuery += " SELECT " 
	cQuery += " FONTE.C5_NUM, FONTE.C5_XSFPED, FONTE.C5_XPEDSAL, FONTE.ERRO, '1' AS TIPO " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " C5_NUM, C5_XPEDSAL, C5_XSFPED, SC6.C6_PRODUTO AS PRODSC6, SC9.C9_PRODUTO AS PRODSC9, " 
	cQuery += " CASE WHEN SC6.C6_PRODUTO <> SC9.C9_PRODUTO  THEN 'ERRO' ELSE 'OK' END LOG, " 
	cQuery += " 'DIVERGÊNCIA Nº SC6 e SC9' AS 'ERRO', '1' AS TIPO " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT C6_FILIAL, C6_NUM, COUNT(C6_PRODUTO) AS C6_PRODUTO FROM " + RetSqlName("SC6") + " (NOLOCK) AS SC6 WHERE SC6.C6_FILIAL = '" + cFilAnt + "' AND SC6.D_E_L_E_T_ = '' GROUP BY C6_FILIAL, C6_NUM) AS SC6 " 
	cQuery += " ON C5_FILIAL = C6_FILIAL " 
	cQuery += " AND C5_NUM = C6_NUM  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT C9_FILIAL, C9_PEDIDO, COUNT(C9_PRODUTO) AS C9_PRODUTO FROM " + RetSqlName("SC9") + " (NOLOCK) AS SC9 WHERE SC9.C9_FILIAL = '" + cFilAnt + "' AND SC9.D_E_L_E_T_ = '' GROUP BY C9_FILIAL, C9_PEDIDO) AS SC9 " 
	cQuery += " ON SC6.C6_FILIAL = SC9.C9_FILIAL " 
	cQuery += " AND SC6.C6_NUM = SC9.C9_PEDIDO " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + cFilAnt + "' " 
	cQuery += " AND C5_DTENTR >= '" + DtoS(MV_PAR01) + "' " 
	cQuery += " AND C5_DTENTR <= '" + DtoS(MV_PAR02) + "' " 
	cQuery += " AND C5_XGERSF = '2' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE FONTE.LOG = 'ERRO' " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT  " 
	cQuery += " (SELECT TOP 1 C5_NUM FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 WHERE C5_FILIAL = '" + cFilAnt + "' AND C5_XPEDSAL = FONTE.C5_XPEDSAL), FONTE.C5_XSFPED, FONTE.C5_XPEDSAL,'Pedido em duplicidade no Protheus' AS ERRO, '2' AS TIPO " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " C5_XPEDSAL, C5_XSFPED, COUNT( C5_NUM) AS TOT " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + cFilAnt + "' " 
	cQuery += " AND C5_XGERSF = '2' " 
	cQuery += " AND C5_DTENTR >= '" + DtoS(MV_PAR01) + "' " 
	cQuery += " AND C5_DTENTR <= '" + DtoS(MV_PAR02) + "' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY C5_XPEDSAL, C5_XSFPED " 
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE " 
	cQuery += " FONTE.TOT > 1 " 

Return cQuery
/*/{Protheus.doc} geraCSV
	(long_description)
	@type  Static Function
	@author Everson
	@since 18/02/2021
	@version 01
	/*/
Static Function geraCSV(oRegistros,aHReg)

	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	Local cArq      := "erros_sf_" + DToS(Date()) + "_" + StrTran(Time(),":","") + ".csv"

	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grLRCCSV")
		Return Nil

	EndIf

	//
	cLin := ""
	For i := 1 To Len(aHReg)
		cLin += cValToChar(aHReg[i][1]) + ";"

	Next i

	cLin += cEof

	For i := 1 To Len(oRegistros:aCols)

		For w := 1 To Len(aHReg)

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

	MsgInfo("Arquivo gerado.","Função grLRCCSV")

	RestArea(aArea)

Return Nil
