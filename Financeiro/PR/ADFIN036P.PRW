#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'

/*{Protheus.doc} User Function ADFIN036P
	Cadastros pendentes.
	@type  Function
	@author Everson
	@since 19/06/2017
	@version 01
	@history Chamado TI     - Adriana         - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Chamado 051104 - William Costa   - 22/11/2019 - ADICIONADO CAMPO PB3_MOTREJ e ajustado o select para não somar varias vezes a reijeição, ajustado também a aprovação para contar corretamente.
	@history Chamado 053928 - Fernando sigoli - 10/12/2019 - TRATAMENTO DE ERROR LOG NO GERAÇÃO DO RELATORIO COMPLETO
	@history Chamado 053485 - Everson  - 07/01/2020 - Adicionado tratamento na data limite de análise de cadastro para quando houver solicitações ao sábados e/ou domingos.  
	@history Chamado 058439 - Everson  - 11/06/2020 - Alterado o tratamento feito no chamado 053485 para data limite de análise de cadastro (Wagner financeiro deu ok nesta nova regra no e-mail enviado em 09/06/2020).
	@history Chamado 8550   - Everson  - 01/02/2021 - Adicionado parâmetros para cálculo de data de vencimento de cadastros.
	@history Chamado 13976  - Everson  - 13/05/2021 - Adicionado tratamento para cadastros inseridos após às 18:00.
*/
User Function ADFIN036P() // U_ADFIN036P()

	//Variáveis.
	Local aArea		:= GetArea()
	Local oCadPrin	:= Nil
	Local oTTabs	:= Nil
	Local aTab		:= {}
	Local bMudaAba	:= {|| oPB9PnlDt:lVisibleControl := (oTTabs:nOption == 1),;
	 					   oPB9PnlSp:lVisibleControl := (oTTabs:nOption == 2),;
	 					   oPB9PnlAn:lVisibleControl := (oTTabs:nOption == 3),;
	 					   oPB9PnlAp:lVisibleControl := (oTTabs:nOption == 4),;
	 					   oLeng:lVisibleControl	 := ((oTTabs:nOption == 1) .Or. (oTTabs:nOption == 2) .Or. (oTTabs:nOption == 3)),;
	 					   oCSV:lVisibleControl	 	 := ((oTTabs:nOption == 1) .Or. (oTTabs:nOption == 2) .Or. (oTTabs:nOption == 3)),;
	 					   aDadosImp := {},;
						   cDadosImp := "";
	 				   }
	
	
	Local oPB9PnlDt	:= Nil
	Local oPB9TxtDt	:= Nil
	Local oSplDt	:= Nil
	Local oBrwDt	:= Nil
	Local oTreeDt	:= Nil
	Local aColsDt	:= {}
	Local oPB9PnlSp	:= Nil
	Local oPB9TxtSp	:= Nil
	Local oSplSp	:= Nil
	Local oTreeSp	:= Nil
	Local oBrwSp	:= Nil
	Local aColSp	:= {}
	Local oPB9PnlAn	:= Nil
	Local oPB9TxtAn	:= Nil
	Local oSplAn	:= Nil
	Local oTreeAn	:= Nil
	Local oBrwAn	:= Nil
	Local oAtlz		:= Nil
	Local oCSV		:= Nil
	Local oGerRel	:= Nil
	Local oDtDe		:= Nil
	Local oOK   	:= LoadBitmap(GetResources(),'br_verde')
	Local oNO   	:= LoadBitmap(GetResources(),'br_vermelho')
	Local oNE   	:= LoadBitmap(GetResources(),'br_azul')
	Local oFont 	:= TFont():New(,,-14,.T.)
	Local aDados	:= {}
	Local oLeng		:= Nil
	Local oPB9PnlAp	:= Nil
	Local aAltCdAp  := {}
	Local aColsCdAp := {}
	Local aAltCdRp  := {}
	Local aColsCdRp := {}
	Local oTxtAprv	:= Nil
	Local oTxtRep	:= Nil
	Local oGerRelR	:= Nil

	Local oTemp		:= Nil //Everson - 11/06/2020. Chamado 058439.

	//
	Private oCSVAp		:= Nil
	Private oCSVRp		:= Nil
	Private dDtDe	 	:= SToD(Alltrim(cValToChar(GetMv("MV_#CADDAT"))))
	Private oPB9TotDt	:= Nil
	Private nTotRegDt	:= 0
	Private nTotRegSp	:= 0
	Private oPB9TotSp	:= Nil
	Private nTotRegAn	:= 0
	Private oPB9TotAn	:= Nil
	Private aDadosDt	:= {}
	Private aDadosSp	:= {}
	Private aDadosAn	:= {}
	Private cPB9FilDt	:= ""
	Private oPB9FilDt	:= Nil
	Private nDias		:= Val(cValToChar(GetMv("MV_#CADDAN")))
	Private aDadosImp	:= {}
	Private cDadosImp	:= ""
	Private oRegAp		:= Nil
	Private aHCdAp 		:= {}
	Private oRegRp		:= Nil
	Private aHCdRp 		:= {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastros pendentes.')

	logAcesso("CADASTRO PENDENTE")
	
	oCadPrin		   := MsDialog():Create()
	oCadPrin:cName     := "oCadPrin"
	oCadPrin:cCaption  := "Cadastros Pendentes"
	oCadPrin:nLeft     := 34
	oCadPrin:nTop      := 200 // 222 // Ricardo Lima - 02/02/18
	oCadPrin:nWidth    := 1200
	oCadPrin:nHeight   := 600 // 550 // Ricardo Lima - 02/02/18
	oCadPrin:lShowHint := .F.
	oCadPrin:lCentered := .T.
		
		//
		oFont:Bold := .T.
		
		//
		oDtDe   := TGet():New(010,550,{|u|If(PCount() == 0,dDtDe,dDtDe   := u)},oCadPrin,040,010,"@D",{||NaoVazio()},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtDe",,,,.T.,,,"Data de:",1) 
		
		//
		oAtlz  	:= TButton():New(040,550,"Atualizar" ,oCadPrin, {|| MsAguarde({|| oTemp := sqlPB9Pen(dDtDe), carrTreeDt(oTemp,dDtDe,oTreeDt), carrTreeSp(oTemp,dDtDe,oTreeSp), carrTreeAn(oTemp,dDtDe,oTreeAn),oTemp:Delete(),; //Everson - 11/06/2020. Chamado 058439.
																					 aDados := {} ,;
																					 Aadd(aDados,{0,"","","","","","","","","","","","",""}),;
																					 oBrwDt:SetArray(aDados),;
																					 oBrwSp:SetArray(aDados),;
																					 oBrwAn:SetArray(aDados),;
																					 oBrwDt:bLine := {||{ Iif(Val(cValToChar(aDados[oBrwDt:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDados[oBrwDt:nAt,01])) == 3,oNE,oNO)),;
																                             aDados[oBrwDt:nAt,02],;
																                             aDados[oBrwDt:nAt,03],;
																                             aDados[oBrwDt:nAt,04],;
																                             aDados[oBrwDt:nAt,05],;
																                             aDados[oBrwDt:nAt,06],;
																                             aDados[oBrwDt:nAt,07],;
																                             aDados[oBrwDt:nAt,08],;
																                             aDados[oBrwDt:nAt,09],;
																                             aDados[oBrwDt:nAt,10],;
																                             aDados[oBrwDt:nAt,11],;
																                             aDados[oBrwDt:nAt,12],;
																                             aDados[oBrwDt:nAt,13],;  
																                             aDados[oBrwDt:nAt,14]; 
																                      } },;
																					 oBrwSp:bLine := {||{ Iif(Val(cValToChar(aDados[oBrwDt:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDados[oBrwDt:nAt,01])) == 3,oNE,oNO)),;
																                             aDados[oBrwSp:nAt,02],;
																                             aDados[oBrwSp:nAt,03],;
																                             aDados[oBrwSp:nAt,04],;
																                             aDados[oBrwSp:nAt,05],;
																                             aDados[oBrwSp:nAt,06],;
																                             aDados[oBrwSp:nAt,07],;
																                             aDados[oBrwSp:nAt,08],;
																                             aDados[oBrwSp:nAt,09],;
																                             aDados[oBrwSp:nAt,10],;
																                             aDados[oBrwSp:nAt,11],;
																                             aDados[oBrwSp:nAt,12],;
																                             aDados[oBrwSp:nAt,13],;   
																                             aDados[oBrwSp:nAt,14]; 
																                      } },;
																					 oBrwAn:bLine := {||{ Iif(Val(cValToChar(aDados[oBrwDt:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDados[oBrwDt:nAt,01])) == 3,oNE,oNO)),;
																                             aDados[oBrwAn:nAt,02],;
																                             aDados[oBrwAn:nAt,03],;
																                             aDados[oBrwAn:nAt,04],;
																                             aDados[oBrwAn:nAt,05],;
																                             aDados[oBrwAn:nAt,06],;
																                             aDados[oBrwAn:nAt,07],;
																                             aDados[oBrwAn:nAt,08],;
																                             aDados[oBrwAn:nAt,09],;
																                             aDados[oBrwAn:nAt,10],;
																                             aDados[oBrwAn:nAt,11],;
																                             aDados[oBrwAn:nAt,12],;
																                             aDados[oBrwAn:nAt,13],;   
																                             aDados[oBrwAn:nAt,14];
																                      } },;																                      
																					 oBrwDt:DrawSelect(),;
																					 oBrwSp:DrawSelect(),;
																					 oBrwAn:DrawSelect(),;
																					 oBrwDt:GoTop(),;
																					 oBrwSp:GoTop(),;
																					 oBrwAn:GoTop(),;
																					 nTotRegDt := 0,;
																					 nTotRegSp := 0,;
																					 nTotRegAn := 0,;
																					 oPB9TotDt:Refresh(),;
																					 oPB9TotSp:Refresh(),;
																					 oPB9TotAn:Refresh(),;
																					 cPB9FilDt := "",;
																					 oPB9FilDt:Refresh(),;
																					 cPB9FilSp := "",;
																					 oPB9FilSp:Refresh(),;
																					 cPB9FilAn := "",;
																					 oPB9FilAn:Refresh(),;
																					 aDadosImp := {},;
																					 cDadosImp := "",;
																					 carrAprv(dDtDe,oPB9PnlAp,oRegAp),;
																					 carrRep(dDtDe,oPB9PnlAp,oRegRp);
		 														   },"Aguarde","Atualizando...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oCSV    := TButton():New(055,550,"CSV" ,oCadPrin, {|| MsAguarde({||;
																			grCSV(aDadosImp,"CAD_PENDENTES_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV",oTTabs);
																		},"Aguarde","Exportando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
																		
		oGerRel  := TButton():New(070,550,"Rel. Compl." ,oCadPrin, {|| MsAguarde({|| gerRelatorio(.F.,1) },"Aguarde","Gerando relatório...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oGerRelR := TButton():New(085,550,"Rel. Resumo" ,oCadPrin, {|| MsAguarde({|| gerRelatorio(.F.,2) },"Aguarde","Gerando relatório...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oGerRelR := TButton():New(100,550,"Cons. Rejeitos" ,oCadPrin, {|| MsAguarde({|| ConsultaRej(.F.,3) },"Aguarde","Gerando relatório...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
													
		//
		oParam := TButton():New(220,550,"Parâmetros" ,oCadPrin, {|| cfgParam() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		aTab   := {'Pendentes Por Data','Pendentes Por Supervisor','Pendentes Por Analista','Status Cadastros'}
		oTTabs := TTabs():New(001,005,aTab,Nil,oCadPrin,Nil,CLR_HRED,Nil,.T.,Nil,536,259,Nil)// Ricardo Lima - 02/02/18
		oTTabs:SetOption(1)
		
		//
		oPB9PnlDt := TPanel():New(001,001,'',oTTabs,,,,,,534,234,,.T.)
			
			oPB9TxtDt := TSay():New(003,001,{|| "Pendências Por Data" },oPB9PnlDt,,oFont,,,,.T.,CLR_RED,CLR_WHITE,150,10)
			
			cPB9FilDt := ""
			oPB9FilDt := TSay():New(003,180,{|| "Filtro: " + cPB9FilDt },oPB9PnlDt,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,10)
			
			nTotRegDt := 0
			oPB9TotDt := TGet():New(001,430,{|u|If(PCount() == 0,nTotRegDt,nTotRegDt := u)},oPB9PnlDt,050,010,"@E 999,999,999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotRegDt",,,,.F.,,,"Total de Registros:",2) 
			
			oSplDt := tSplitter():New(015,001,oPB9PnlDt,532,216)
			oTreeDt := DbTree():New(001,001,233,090,oSplDt,,,.T.,,,"Datas")
			oTreeDt:SetScroll (1,.T.) 
			oTreeDt:SetScroll (2,.T.) 
			oTreeDt:bLClicked := {|| Iif( oTreeDt:IsEmpty(), MsgStop("Não há dados a serem exibidos.","Função cadpend"), carrDetalhe(@oBrwDt,dDtDe,oTTabs:nOption,  Alltrim(cValToChar(oTreeDt:GetPrompt(.T.))) )) }
			oTreeDt:SetCss("QTreeWidget{background-color: #F9F9F9}")
 
	        // Cria Browse.
	        aColsDt := colunaBrw()
	        oBrwDt := TCBrowse():New(000,000, 260, 156,, aColsDt,{20,50,50,50}, oSplDt,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	        
	        // Seta vetor para a browse
	        aDadosDt := {}
	        Aadd(aDadosDt,{0,"","","","","","","","","","","","",""})
	        oBrwDt:SetArray(aDadosDt)
	        oBrwDt:bLine := {||{ Iif(Val(cValToChar(aDadosDt[oBrwDt:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDadosDt[oBrwDt:nAt,01])) == 3,oNE,oNO)),;
                             aDadosDt[oBrwDt:nAt,02],;
                             aDadosDt[oBrwDt:nAt,03],;
                             aDadosDt[oBrwDt:nAt,04],;
                             aDadosDt[oBrwDt:nAt,05],;
                             aDadosDt[oBrwDt:nAt,06],;
                             aDadosDt[oBrwDt:nAt,07],;
                             aDadosDt[oBrwDt:nAt,08],;
                             aDadosDt[oBrwDt:nAt,09],;
                             aDadosDt[oBrwDt:nAt,10],;
                             aDadosDt[oBrwDt:nAt,11],;
                             aDadosDt[oBrwDt:nAt,12],;
                             aDadosDt[oBrwDt:nAt,13],;  
                             aDadosDt[oBrwDt:nAt,14];  
                      } }
			
		//
		oPB9PnlSp := TPanel():New(001,001,'',oTTabs,,,,,,534,234,,.T.)
			
			oPB9TxtSp := TSay():New(003,001,{|| "Pendências Por Supervisor" },oPB9PnlSp,,oFont,,,,.T.,CLR_RED,CLR_WHITE,150,10)
			
			cPB9FilSp := ""
			oPB9FilSp := TSay():New(003,180,{|| "Filtro: " + cPB9FilSp },oPB9PnlSp,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,10)
			
			nTotRegSp := 0
			oPB9TotSp := TGet():New(001,430,{|u|If(PCount() == 0,nTotRegSp,nTotRegSp := u)},oPB9PnlSp,050,010,"@E 999,999,999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotRegSp",,,,.F.,,,"Total de Registros:",2) 
			
			oSplSp := tSplitter():New(015,001,oPB9PnlSp,532,216)
			oTreeSp := DbTree():New(001,001,233,090,oSplSp,,,.T.,,,"Supervisores")
			oTreeSp:SetScroll (1,.T.) 
			oTreeSp:SetScroll (2,.T.) 
			oTreeSp:bLClicked := {|| Iif( oTreeSp:IsEmpty(), MsgStop("Não há dados a serem exibidos.","Função cadpend"), carrDetalhe(@oBrwSp,dDtDe,oTTabs:nOption,  Alltrim(cValToChar(oTreeSp:GetPrompt(.T.)))) ) }
			oTreeSp:SetCss("QTreeWidget{background-color: #F9F9F9}")
 
	        // Cria Browse.
	        aColSp := colunaBrw()
	        oBrwSp := TCBrowse():New(000,000, 260, 156,, aColSp,{20,50,50,50}, oSplSp,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	        
	        // Seta vetor para a browse
	        aDadosSp := {}
	        Aadd(aDadosSp,{0,"","","","","","","","","","","","",""})
	        oBrwSp:SetArray(aDadosSp)
	        oBrwSp:bLine := {||{ Iif(Val(cValToChar(aDadosSp[oBrwDt:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDadosSp[oBrwDt:nAt,01])) == 3,oNE,oNO)),;
                             aDadosSp[oBrwSp:nAt,02],;
                             aDadosSp[oBrwSp:nAt,03],;
                             aDadosSp[oBrwSp:nAt,04],;
                             aDadosSp[oBrwSp:nAt,05],;
                             aDadosSp[oBrwSp:nAt,06],;
                             aDadosSp[oBrwSp:nAt,07],;
                             aDadosSp[oBrwSp:nAt,08],;
                             aDadosSp[oBrwSp:nAt,09],;
                             aDadosSp[oBrwSp:nAt,10],;
                             aDadosSp[oBrwSp:nAt,11],;
                             aDadosSp[oBrwSp:nAt,12],;
                             aDadosSp[oBrwSp:nAt,13],;   
                             aDadosSp[oBrwSp:nAt,14];
                      } }
			
		//
		oPB9PnlAn := TPanel():New(001,001,'',oTTabs,,,,,,534,234,,.T.)
			
			oPB9TxtAn := TSay():New(003,001,{|| "Pendências Por Analista" },oPB9PnlAn,,oFont,,,,.T.,CLR_RED,CLR_WHITE,150,10)
			
			cPB9FilAn := ""
			oPB9FilAn := TSay():New(003,180,{|| "Filtro: " + cPB9FilAn },oPB9PnlAn,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,10)
			
			nTotRegAn := 0
			oPB9TotAn := TGet():New(001,430,{|u|If(PCount() == 0,nTotRegAn,nTotRegAn := u)},oPB9PnlAn,050,010,"@E 999,999,999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotRegAn",,,,.F.,,,"Total de Registros:",2) 
			
			oSplAn := tSplitter():New(015,001,oPB9PnlAn,532,216)
			oTreeAn := DbTree():New(001,001,233,090,oSplAn,,,.T.,,,"Analistas")
			oTreeAn:SetScroll (1,.T.) 
			oTreeAn:SetScroll (2,.T.) 
			oTreeAn:bLClicked := {|| Iif( oTreeAn:IsEmpty(), MsgStop("Não há dados a serem exibidos.","Função cadpend"), carrDetalhe(@oBrwAn,dDtDe,oTTabs:nOption,  Alltrim(cValToChar(oTreeAn:GetPrompt(.T.)))) ) }
			oTreeAn:SetCss("QTreeWidget{background-color: #F9F9F9}")
 
	        // Cria Browse.
	        aColsAn := colunaBrw()
	        oBrwAn := TCBrowse():New(000,000, 260, 156,, aColsAn,{20,50,50,50}, oSplAn,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	        
	        // Seta vetor para a browse
	        aDadosAn := {}
	        Aadd(aDadosAn,{0,"","","","","","","","","","","","",""})
	        oBrwAn:SetArray(aDadosAn)
	        oBrwAn:bLine := {||{ Iif(Val(cValToChar(aDadosAn[oBrwDt:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDadosAn[oBrwDt:nAt,01])) == 3,oNE,oNO)),;
                             aDadosAn[oBrwAn:nAt,02],;
                             aDadosAn[oBrwAn:nAt,03],;
                             aDadosAn[oBrwAn:nAt,04],;
                             aDadosAn[oBrwAn:nAt,05],;
                             aDadosAn[oBrwAn:nAt,06],;
                             aDadosAn[oBrwAn:nAt,07],;
                             aDadosAn[oBrwAn:nAt,08],;
                             aDadosAn[oBrwAn:nAt,09],;
                             aDadosAn[oBrwAn:nAt,10],;
                             aDadosAn[oBrwAn:nAt,11],;
                             aDadosAn[oBrwAn:nAt,12],;
                             aDadosAn[oBrwAn:nAt,13],;   
                             aDadosAn[oBrwAn:nAt,14];
                      } }
			
		
		//
		oPB9PnlAp := TPanel():New(001,001,'',oTTabs,,,,,,534,234,,.T.)
			oTxtAprv := TSay():New(005,001,{|| "Cadastros Aprovados" },oPB9PnlAp,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,10)
			aAltCdAp  := {}
			aHCdAp    := {}
			aColsCdAp := {}
			oRegAp    := MsNewGetDados():New(020,001,210,260,,"Allwaystrue()","Allwaystrue()","",aAltCdAp,1,999,Nil,Nil,Nil,oPB9PnlAp,aHCdAp,@aColsCdAp)
			
			oTxtRep := TSay():New(005,270,{|| "Cadastros Reprovados" },oPB9PnlAp,,oFont,,,,.T.,CLR_RED,CLR_WHITE,250,10)
			aAltCdRp  := {}
			aHCdRp    := {}
			aColsCdRp := {}
			oRegRp    := MsNewGetDados():New(020,270,210,530,,"Allwaystrue()","Allwaystrue()","",aAltCdRp,1,999,Nil,Nil,Nil,oPB9PnlAp,aHCdRp,@aColsCdRp)
		
		//
		oGroup1  := TGroup():Create(oCadPrin,001,545,236,595,"",,,.T.)
		
		//
		oLeng   := TButton():New(238,492,"Legenda",oCadPrin,{|| legenda() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oLeng:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #3232CD, stop: 1 #23238E);color: white}")
		
		//
		oFechar	 := TButton():New(245,550,"Fechar",oCadPrin,{|| oCadPrin:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
		
		//
		oTTabs:bAction := bMudaAba
		Eval(bMudaAba)
		
	oCadPrin:Activate(,,,.T.,{||.T.},,{||  oTemp := sqlPB9Pen(dDtDe), carrTreeDt(oTemp, dDtDe,oTreeDt), carrTreeSp(oTemp,dDtDe,oTreeSp), carrTreeAn(oTemp,dDtDe,oTreeAn), oTemp:Delete(), carrAprv(dDtDe,oPB9PnlAp,oRegAp), carrRep(dDtDe,oPB9PnlAp,oRegRp) }) //Everson - 11/06/2020. Chamado 058439.
	
	//
	RestArea(aArea)
	
Return Nil
/*{Protheus.doc} Static Function gerRelatorio
	Gera relatório
	@type  Function
	@author Everson
	@since 23/06/2017
	@version 01	
*/
Static Function gerRelatorio(lAut,nOpc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cRel		:= ""
	Local cEmail	:= Iif(nOpc == 1,Alltrim(cValToChar(GetMv("MV_#CADEML"))),Alltrim(cValToChar(GetMv("MV_#CADEMR"))))
	Local cMsg		:= Iif(nOpc == 1,"Deseja enviar o relatóro completo de análise de cadastro?","Deseja enviar o relatóro resumo de análise de cadastro?")
	
	//
	If ! lAut
		
		If ! MsgYesNo(cMsg,"Função gerRelatorio")
			RestArea(aArea)	
			Return Nil
			
		EndIf
		
	EndIf
	
	//
	If Empty(cEmail)
	
		If ! lAut
			MsgInfo("Não há e-mail cadastrado.","Função gerRelatorio")
		
		EndIf	
		
		RestArea(aArea)	
		Return Nil
		
	EndIf
	
	//Gera relatório.
	cRel := templateHtml(nOpc)
	
	//Envia o relatório.

	enviarEmail("Relatório - Cadastros Pendentes",cRel,cEmail,"")
	
	If ! lAut
		MsgInfo("Relatório enviado.","Função gerRelatorio")
	
	EndIf
	
	//
	RestArea(aArea)	
	
Return Nil
/*{Protheus.doc} Static Function templateHtml
	Template html
	@type  Function
	@author Everson
	@since 23/06/2017
	@version 01	
*/
Static Function templateHtml(nOPc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cHtml		:= ""
	Local dData		:= SToD(Alltrim(cValToChar(GetMv("MV_#CADDAT"))))
	Local nTotApv	:= 0
	Local nTotGer   := 0
	Local nDias		:= Val(cValToChar(GetMv("MV_#CADDAN")))
	Local oTemp		:= sqlPB9Pen(dData)
	
	//
	cHtml := ""
	cHtml += " <!DOCTYPE html> "
	cHtml += " <html> "
	cHtml += " <head> "
	cHtml += " <meta charset='UTF-8'> "
	cHtml += " <style> "
	cHtml += " body{background-color: #fdfdfd; color:black;} "
	cHtml += " td {border-bottom: 1px solid white;padding-left:5px;padding-right:5px;padding-top:2px;} "
	cHtml += " .container { "
	cHtml += " margin: auto; "
	cHtml += " width: 95%; "
	cHtml += " background: #fff; "
	cHtml += " padding: 10px; "
	cHtml += " height: 550px; "
	cHtml += " overflow: scroll; "
	cHtml += " } "
	cHtml += " .container1 { "
	cHtml += " margin: auto; "
	cHtml += " width: 80%; "
	cHtml += " background: #fff; "
	cHtml += " padding: 10px; "
	//cHtml += " overflow: scroll; "
	cHtml += " } "
	cHtml += " h3{ "
	cHtml += " color:#28377c; "
	cHtml += " } "
	cHtml += " h4{ "
	cHtml += " color:#28377c; margin: 0px;"
	cHtml += " } "
	cHtml += " p{ "
	cHtml += " margin: 0px;"
	cHtml += " } "
	cHtml += " </style> "
	cHtml += " </head> "
	cHtml += " <body> "
	
	//
	cHtml += " <div class='container1'> "
	cHtml += " <h3>Cadastros Pendentes</h3> "
	cHtml += " <p>Gerado em: " + DToC(Date()) + "</p> "
	cHtml += " <p>Data inicial: " + DToC(dData) + "</p> "
	cHtml += " <p>Prazo para análise: " + cValToChar(nDias) + " dias</p> "
	
	//
	If nOpc == 2
		cHtml += " <br/> "
		cHtml += " <p>Segue a posição de cadastros a serem analisados pelo Depto. de Crédito:</p> "
		
	EndIf
	
	cHtml += " <hr> "
	cHtml += " <div class='container'> "
	cHtml += " <br/> "
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " B_SUPER.A3_NOMSUP, "
	cQuery += " SUM(CASE WHEN B_SUPER.ATRASO = '0' THEN 1 ELSE 0 END) AS NORMAL, "
	cQuery += " SUM(CASE WHEN B_SUPER.ATRASO = '1' THEN 1 ELSE 0 END) AS ATRASO, "
	cQuery += " SUM(CASE WHEN B_SUPER.ATRASO = '3' THEN 1 ELSE 0 END) AS ATRASO, COUNT(B_SUPER.ATRASO) AS TOTAL "
	cQuery += " FROM ( "
	
	//Everson - 11/06/2020. Chamado 058439.
	cQuery += " SELECT * FROM " + oTemp:GetRealName()
	//
	
	cQuery += " ) AS B_SUPER "
	cQuery += " GROUP BY "
	cQuery += " B_SUPER.A3_NOMSUP "
	cQuery += " ORDER BY TOTAL DESC "	
	
	//
	If Select("B_SUPER") > 0
		B_SUPER->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "B_SUPER"
	DbSelectArea("B_SUPER")
	B_SUPER->(DbGoTop())
	
	//
	cHtml += " <h4>Pendentes Por Supervisor</h4> "
	cHtml += " <table style='width:900px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'> "
	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d; color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Supervisor</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Normal</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Atraso</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Total</td> "
	cHtml += " </tr> "
	cHtml += " <tbody> "
	
	nTotN := 0
	nTotA := 0
	nTotG := 0
	While ! B_SUPER->(Eof())
	
		cHtml += " <tr> "
		cHtml += " <td style='border-right: 1px solid white' align='left'>"  + cValToChar(B_SUPER->A3_NOMSUP) + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_SUPER->NORMAL)   + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_SUPER->ATRASO)   + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_SUPER->TOTAL)    + "</td> "
		cHtml += " </tr> "
		
		nTotN += Val(cValToChar(B_SUPER->NORMAL))
		nTotA += Val(cValToChar(B_SUPER->ATRASO))
		nTotG += Val(cValToChar(B_SUPER->TOTAL))
		
		B_SUPER->(DbSkip())
		
	EndDo
	
	cHtml += " <tr style='background-color:#ffb236;'> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>Total</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotN) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotA) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotG) + "</td> "
	cHtml += " </tr> "
	
	cHtml += " <tr style='background-color:#ffb236;'> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>Percentuais</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(Iif(nTotG > 0,Transform(Round((nTotN/nTotG)*100,2),"@E 999.99"),0)) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(Iif(nTotG > 0,Transform(Round((nTotA/nTotG)*100,2),"@E 999.99"),0)) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(Iif(nTotG > 0,Transform(Round((nTotG/nTotG)*100,2),"@E 999.99"),0)) + "</td> "
	cHtml += " </tr> "
	
	cHtml += " </tbody> "
	cHtml += " </table> "
	cHtml += " <br/> "
	//
	//
	If nOpc == 2
	
		cHtml += " </div> "
		cHtml += " </div> "
		cHtml += " </body> "
		cHtml += " </html> "
		RestArea(aArea)	
		Return cHtml
	
	EndIf
	
	B_SUPER->(DbCloseArea())
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " FONTE.DT_ENVIO, FONTE.PB9_USUARI, COUNT(*) AS TT "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += sqlAprov(1,dData)
	
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY "
	cQuery += " FONTE.DT_ENVIO, "
	cQuery += " FONTE.PB9_USUARI "
	cQuery += " ORDER BY "
	cQuery += " FONTE.DT_ENVIO, "
	cQuery += " FONTE.PB9_USUARI "
	
	If Select("D_APRVR") > 0
		D_APRVR->(DbCloseArea())
	EndIf
	
	//
	TcQuery cQuery New Alias "D_APRVR"

	D_APRVR->(DbGoTop())
	
	//
	nPosAn    := 0
	aAnalista := {}
	aDatas    := {}
	aDados    := {}
	nTotGer	  := 0
	While ! D_APRVR->(Eof())
		
		//
		nPosAn := aScan(aAnalista,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_APRVR->PB9_USUARI)) })
		If nPosAn == 0
			
			Aadd(aAnalista,{Alltrim(cValToChar(D_APRVR->PB9_USUARI)),Val(cValToChar(D_APRVR->TT))})
			
		Else
			
			aAnalista[nPosAn][2] += Val(cValToChar(D_APRVR->TT))
		
		EndIf		
		
		//
		nPosAn := aScan(aDatas,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_APRVR->DT_ENVIO)) })
		If nPosAn == 0
			
			Aadd(aDatas,{Alltrim(cValToChar(D_APRVR->DT_ENVIO)),Val(cValToChar(D_APRVR->TT))})
			
		Else
			
			aDatas[nPosAn][2] += Val(cValToChar(D_APRVR->TT))
			
		EndIf
		
		//
		Aadd(aDados,{Alltrim(cValToChar(D_APRVR->DT_ENVIO)),Alltrim(cValToChar(D_APRVR->PB9_USUARI)),Val(cValToChar(D_APRVR->TT))})
		
		nTotGer += Val(cValToChar(D_APRVR->TT))
		
		D_APRVR->(DbSkip())
		
	EndDo

	//
	cHtml += " <h4>Cadastros Aprovados</h4> "
	cHtml += " <table style='width:900px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'> "
	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d; color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Data</td> "
	
	For i := 1 To Len(aAnalista)
	
		cHtml += " <td style='border-right: 1px solid white' align='center'>" + Alltrim(cValToChar(aAnalista[i][1])) + "</td> "
	
	Next i
	
	cHtml += " <td style='border-right: 1px solid white' align='center'>Total</td> "
	cHtml += " </tr> "
	cHtml += " <tbody> "
	
	For i := 1 To Len(aDatas)
	
		cHtml += " <tr> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + DToC(SToD(aDatas[i][1])) + "</td> "
		
		For w := 1 To Len(aAnalista)
			
			nPosAn := aScan(aDados,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(aDatas[i][1])) .And.  Alltrim(cValToChar(x[2])) == Alltrim(cValToChar(aAnalista[w][1])) })
			If nPosAn > 0
				
				cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(aDados[nPosAn][3]) + "</td> "
				
			Else
				
				cHtml += " <td style='border-right: 1px solid white' align='right'>0</td> "
			
			EndIf
		
		Next w
		
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(aDatas[i][2]) + "</td> "
		cHtml += " </tr> "
	
	Next i
	
	//
	cHtml += " <tr style='background-color:#ffb236;'> "
	cHtml += " <td style='border-right: 1px solid white' align='left'>Total</td> "
	For i := 1 To Len(aAnalista)
		
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(aAnalista[i][2]) + "</td> "
		
	Next i
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotGer) + "</td> "
	cHtml += " </tr> "
	
	//
	cHtml += " </tbody> "
	cHtml += " </table> "
	cHtml += " <br/> "
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " FONTE.DT_ENVIO, COUNT(FONTE.PB9_CODIGO) AS QTD "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += sqlReprov(dData,9) //aqui é o problema
	
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY FONTE.DT_ENVIO "
	cQuery += " ORDER BY FONTE.DT_ENVIO "
	
	//
	If Select("D_RELREPROV") > 0
		D_REPROV->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_RELREPROV"
	DbSelectArea("D_RELREPROV")
	D_RELREPROV->(DbGoTop())
	
	cHtml += " <h4>Cadastros Reprovados</h4> "
	cHtml += " <table style='width:900px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'> "
	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d; color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Data</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Total</td> "
	cHtml += " </tr> "
	cHtml += " <tbody> "
	
	While ! D_RELREPROV->(Eof())
	
		cHtml += " <tr> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + DToC(SToD(cValToChar(D_RELREPROV->DT_ENVIO))) + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(D_RELREPROV->QTD) + "</td> "
		cHtml += " </tr> "
		
		nTotApv += Val(cValToChar(D_RELREPROV->QTD))
		
		D_RELREPROV->(DbSkip())
		
	EndDo
	
	cHtml += " <tr style='background-color:#ffb236;'> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>Total</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotApv) + "</td> "
	cHtml += " </tr> "
	
	D_RELREPROV->(DbCloseArea())
	
	cHtml += " </tbody> "
	cHtml += " </table> "
	cHtml += " <br/> "
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " B_DATA.DT_AJUST, "
	cQuery += " SUM(CASE WHEN B_DATA.ATRASO = '0' THEN 1 ELSE 0 END) AS NORMAL, "
	cQuery += " SUM(CASE WHEN B_DATA.ATRASO = '1' THEN 1 ELSE 0 END) AS ATRASO, "
	cQuery += " SUM(CASE WHEN B_DATA.ATRASO = '3' THEN 1 ELSE 0 END) AS ATRASO, COUNT(B_DATA.ATRASO) AS TOTAL "
	cQuery += " FROM ( "

	//Everson - 11/06/2020. Chamado 058439.
	cQuery += " SELECT * FROM " + oTemp:GetRealName()
	//
	
	cQuery += " ) AS B_DATA "
	cQuery += " GROUP BY "
	cQuery += " B_DATA.DT_AJUST "
	cQuery += " ORDER BY B_DATA.DT_AJUST "	
	
	//
	If Select("B_DATA") > 0
		B_DATA->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "B_DATA"
	DbSelectArea("B_DATA")
	B_DATA->(DbGoTop())
	
	//
	cHtml += " <h4>Pendentes Por Data</h4> "
	cHtml += " <table style='width:900px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'> "
	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d; color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Data</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Normal</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Atraso</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Total</td> "
	cHtml += " </tr> "
	cHtml += " <tbody> "
	
	nTotN := 0
	nTotA := 0
	nTotG := 0
	While ! B_DATA->(Eof())
	
		cHtml += " <tr> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + DToC(SToD(B_DATA->DT_AJUST)) + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_DATA->NORMAL)   + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_DATA->ATRASO)   + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_DATA->TOTAL)    + "</td> "
		cHtml += " </tr> "
		
		nTotN += Val(cValToChar(B_DATA->NORMAL))
		nTotA += Val(cValToChar(B_DATA->ATRASO))
		nTotG += Val(cValToChar(B_DATA->TOTAL))
		
		B_DATA->(DbSkip())
		
	EndDo
	
	cHtml += " <tr style='background-color:#ffb236;'> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>Total</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotN) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotA) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotG) + "</td> "
	cHtml += " </tr> "
	
	cHtml += " </tbody> "
	cHtml += " </table> "
	cHtml += " <br/> "
	
	B_DATA->(DbCloseArea())
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " B_ANALISTA.NOME, "
	cQuery += " SUM(CASE WHEN B_ANALISTA.ATRASO = '0' THEN 1 ELSE 0 END) AS NORMAL, "
	cQuery += " SUM(CASE WHEN B_ANALISTA.ATRASO = '1' THEN 1 ELSE 0 END) AS ATRASO, "
	cQuery += " SUM(CASE WHEN B_ANALISTA.ATRASO = '3' THEN 1 ELSE 0 END) AS ATRASO, COUNT(B_ANALISTA.ATRASO) AS TOTAL "
	cQuery += " FROM ( "

	//Everson - 11/06/2020. Chamado 058439.
	cQuery += " SELECT * FROM " + oTemp:GetRealName()
	//
	
	cQuery += " ) AS B_ANALISTA "
	cQuery += " GROUP BY "
	cQuery += " B_ANALISTA.NOME "
	cQuery += " ORDER BY TOTAL DESC "	
	
	//
	If Select("B_ANALISTA") > 0
		B_ANALISTA->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "B_ANALISTA"
	DbSelectArea("B_ANALISTA")
	B_ANALISTA->(DbGoTop())
	
	cHtml += " <h4>Pendentes Por Analista</h4> "
	cHtml += " <table style='width:900px;border-collapse: collapse;padding:10px;background-color:#f7be62;border: 1px solid white;border-radius: 10px 15px 0 0;'> "
	cHtml += " <tr style='border-collapse: collapse;background-color: #96191d; color: white;border-radius: 15px 15px 0 0;'> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Analista</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Normal</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Atraso</td> "
	cHtml += " <td style='border-right: 1px solid white' align='center'>Total</td> "
	cHtml += " </tr> "
	cHtml += " <tbody> "
	
	nTotN := 0
	nTotA := 0
	nTotG := 0
	While ! B_ANALISTA->(Eof())
	
		cHtml += " <tr> "
		cHtml += " <td style='border-right: 1px solid white' align='left'>" + cValToChar(B_ANALISTA->NOME) + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_ANALISTA->NORMAL)   + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_ANALISTA->ATRASO)   + "</td> "
		cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(B_ANALISTA->TOTAL)    + "</td> "
		cHtml += " </tr> "
		
		nTotN += Val(cValToChar(B_ANALISTA->NORMAL))
		nTotA += Val(cValToChar(B_ANALISTA->ATRASO))
		nTotG += Val(cValToChar(B_ANALISTA->TOTAL))
		
		B_ANALISTA->(DbSkip())
		
	EndDo
	
	cHtml += " <tr style='background-color:#ffb236;'> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>Total</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotN) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotA) + "</td> "
	cHtml += " <td style='border-right: 1px solid white' align='right'>" + cValToChar(nTotG) + "</td> "
	cHtml += " </tr> "
	
	cHtml += " </tbody> "
	cHtml += " </table> "
	cHtml += " <br/> "
	
	B_ANALISTA->(DbCloseArea())
	
	//
	cHtml += " </div> "
	cHtml += " </div> "
	cHtml += " </body> "
	cHtml += " </html> "
	
	//
	oTemp:Delete() 

	//
	RestArea(aArea)	
	
Return cHtml
/*{Protheus.doc} Static Function enviarEmail
	Envia e-mail.
	@type  Function
	@author Everson
	@since 23/06/2017
	@version 01	
*/
Static Function enviarEmail(cAssunto,cMensagem,cEmail,cAtach)
	
	//Variáveis.
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local aFiles        := {}
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := cEmail
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.  
	Local cSubject      := ""
	
	//Assunto do e-mail.
	cSubject := cAssunto
	 
	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	
	If !lAutOk
	   If ( lSmtpAuth )
	      lAutOk := MailAuth(cAccount,cPassword)
	      
	   Else
	      lAutOk := .T.
	      
	   EndIf
	   
	EndIf
	
	If lOk .And. lAutOk   
	   
	   //Envia o e-mail.     
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  
	    
	   //Tratamento de erro no envio do e-mail.          
	   If !lOk
	      Get Mail Error cErrorMsg
	      ConOut("Não foi possível enviar o e-mail ao comprador. 3 - " + cErrorMsg)
	      
	   EndIf
	   
	Else
	   Get Mail Error cErrorMsg
	   ConOut("Não foi possível enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	  
	EndIf
	
	If lOk
	   Disconnect Smtp Server
	   
	EndIf
	
	RestArea(aArea)
	
Return Nil
/*{Protheus.doc} Static Function cfgParam
	Configuração de parâmetros.
	@type  Function
	@author Everson
	@since 23/06/2017
	@version 01	
*/
Static Function cfgParam()

	//Variáveis.
	Local aArea			:= GetArea()
	Local oIntParam		:= Nil
	Local oGroup1		:= Nil
	Local nDiasAtra	 	:= GetMv("MV_#CADDAN") //Space(200)
	Local oDiasAtra		:= Nil
	Local cPB3VENENC 	:= Alltrim(cValToChar(GetMv("MV_#CADVER"))) + Space(200) //Space(200)
	Local oPB3VENENC	:= Nil
	Local cPB9CPODEP 	:= Alltrim(cValToChar(GetMv("MV_#CADCAP"))) + Space(200) //Space(200) 
	Local oPB9CPODEP	:= Nil
	Local cPB9CPOANT 	:= Alltrim(cValToChar(GetMv("MV_#CADCAN"))) + Space(200) //Space(200)
	Local oPB9CPOANT	:= Nil
	Local oEmail		:= Nil
	Local cEmail		:= Alltrim(cValToChar(GetMv("MV_#CADEML"))) + Space(200)
	Local oEmailR		:= Nil
	Local cEmailR		:= Alltrim(cValToChar(GetMv("MV_#CADEMR"))) + Space(200)
	Local oEmailConR	:= Nil
	Local cEmailConR 	:= Alltrim(cValToChar(GetMv("MV_#CONREJ"))) + Space(200)
	Local oAFin			:= Nil
	Local cAFin			:= Alltrim(cValToChar(GetMv("MV_#URJCAD"))) + Space(200)
	Local oDtDeR		:= Nil

	//
	Private dDtDeR	 	:= Alltrim(cValToChar(GetMv("MV_#CADDAT"))) // Date()
	
	//
	If ! Empty(dDtDeR)
		dDtDeR := SToD(dDtDeR)
		
	EndIf
	
	oIntParam		   := MsDialog():Create()
	oIntParam:cName     := "oIntParam"
	oIntParam:cCaption  := "Configuração de Parâmetros"
	oIntParam:nLeft     := 34
	oIntParam:nTop      := 222
	oIntParam:nWidth    := 600
	oIntParam:nHeight   := 600
	oIntParam:lShowHint := .F.
	oIntParam:lCentered := .T.
		
		//
		oDtDe      := TGet():New(010,010,{|u|If(PCount() == 0,dDtDeR,dDtDeR := u)},oIntParam,040,010,"@D",{||NaoVazio()},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtDeR",,,,.T.,,,"Data inicial para geração do relatório:",1) 
		
		//
		oDiasAtra  := TGet():New(040,010,{|u|If(PCount() == 0,nDiasAtra,nDiasAtra := u)},oIntParam,040,010,"@E 999,999",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nDiasAtra",,,,.T.,,,"Dias para análise:",1) 
		
		//
		oPB3VENENC := TGet():New(070,010,{|u|If(PCount() == 0,cPB3VENENC,cPB3VENENC := u)},oIntParam,280,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPB3VENENC",,,,.T.,,,"Incluir vendedores responsáveis (PB3_VENENC):",1) 
		
		//
		oPB9CPODEP := TGet():New(100,010,{|u|If(PCount() == 0,cPB9CPODEP,cPB9CPODEP := u)},oIntParam,280,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPB9CPODEP",,,,.T.,,,"Incluir usuários após alteração do cadastro (PB9_CPODEP):",1) 
		
		//
		oPB9CPOANT := TGet():New(130,010,{|u|If(PCount() == 0,cPB9CPOANT,cPB9CPOANT := u)},oIntParam,280,010,"@!",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cPB9CPOANT",,,,.T.,,,"Não considerar usuários antes da alteração (PB9_CPOANT):",1) 
		
		//
		oEmail := TGet():New(160,010,{|u|If(PCount() == 0,cEmail,cEmail := u)},oIntParam,280,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmail",,,,.T.,,,"E-mail's - Relatório Completo:",1) 
		
		//
		oEmailR := TGet():New(190,010,{|u|If(PCount() == 0,cEmailR,cEmailR := u)},oIntParam,280,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmailR",,,,.T.,,,"E-mail's - Relatório Resumo:",1) 
		
		//
		oAFin	:= TGet():New(220,010,{|u|If(PCount() == 0,cAFin,cAFin := u)},oIntParam,280,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAFin",,,,.T.,,,"Usuários a serem considerados na rejeição de cadastros:",1) 
		
        oEmailConR := TGet():New(250,010,{|u|If(PCount() == 0,cEmailConR,cEmailConR := u)},oIntParam,280,010,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmailConR",,,,.T.,,,"E-mail's - Relatório Consolidação Rejeitos:",1)   

		//
		//oGroup1  := TGroup():Create(oIntParam,270,005,290,295,"",,,.T.)
		
		oOk  	 := TButton():New(275,205,"Ok",oIntParam,{|| slvParam(dDtDeR,nDiasAtra,cPB3VENENC,cPB9CPOANT,cPB9CPODEP,cEmail,cEmailR,cAFin,cEmailConR), oIntParam:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oFechar	 := TButton():New(275,250,"Cancelar",oIntParam,{|| oIntParam:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oIntParam:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)	
	
Return Nil
/*{Protheus.doc} Static Function slvParam
	Retorna colunas do objeto TCBrowse.
	@type  Function
	@author Everson
	@since 23/06/2017
	@version 01	
*/
Static Function slvParam(dData,nDias,cVenResp,cUserAnt,cUserDep,cEmail,cEmailR,cAFin,cEmailConR)

	//Variáveis.
	Local aArea		:= GetArea()
	
	//
	cVenResp := Alltrim(cValToChar(cVenResp))
	cUserAnt := Alltrim(cValToChar(cUserAnt))
	cUserDep := Alltrim(cValToChar(cUserDep))
	cEmail	 := Alltrim(cValToChar(cEmail))
	cAFin	 := Alltrim(cValToChar(cAFin))
	
	PutMv("MV_#CADDAN",Val(cValToChar(nDias)))
	PutMv("MV_#CADVER",cVenResp) 
	PutMv("MV_#CADCAN",cUserAnt)
	PutMv("MV_#CADCAP",cUserDep)
	PutMv("MV_#CADDAT",DToS(dData))
	PutMv("MV_#CADEML",cEmail)
	PutMv("MV_#CADEMR",cEmailR)
	PutMv("MV_#CONREJ",cEmailConR)
	PutMv("MV_#URJCAD",cAFin)
	
	//
	MsgInfo("Parâmetros alterados.","Função slvParam")
	
	//
	RestArea(aArea)
		
Return Nil
/*{Protheus.doc} Static Function legenda
	Retorna colunas do objeto TCBrowse.
	@type  Function
	@author Everson
	@since 21/06/2017
	@version 01	
*/
Static Function legenda()

	//Variáveis.
	Local cTitulo := "Legenda"
	Local aLegenda:= {}
     
	Aadd(aLegenda, {"BR_AZUL"     ,"Sem data de envio"})
	Aadd(aLegenda, {"BR_VERDE"    ,"Normal" })
	Aadd(aLegenda, {"BR_VERMELHO" ,"Atraso" })
     
	BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil
/*{Protheus.doc} Static Function colunaBrw
	Retorna colunas do objeto TCBrowse.
	@type  Function
	@author Everson
	@since 20/06/2017
	@version 01	
*/
Static Function colunaBrw()

	//Variáveis.
	Local aArea		:= GetArea()
	Local aColunas	:= {}
	
	//
	aColunas := {'Status','Código SA1','Loja SA1','Código PB3','Loja PB3','Nome PB3','Vendedor PB3','Código Sup.','Nome Sup.','Analista','PB3_VENENC','Data Envio','Data Limite','Hora'}
	
	//
	RestArea(aArea)
	
Return aColunas
/*{Protheus.doc} Static Function carrDetalhe
	Carrega dados no objeto DbTree.
	@type  Function
	@author Everson
	@since 20/06/2017
	@version 01	
*/
Static Function carrDetalhe(oBrowse,dData,nOpc,cString)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aDados	:= {}
	Local cQuery	:= ""
	Local aFiltro	:= {}
	Local cFiltro	:= ""
	Local cFilSp	:= ""
	Local cFilData	:= ""
	Local oOK 		:= LoadBitmap(GetResources(),'br_verde')
	Local oNO 		:= LoadBitmap(GetResources(),'br_vermelho')
	Local oNE 		:= LoadBitmap(GetResources(),'br_azul')
	Local oTemp		:= sqlPB9Pen(dData) //Everson - 11/06/2020. Chamado 058439.

	//
	If nOpc == 1 // Por data.
		
		If At("Data",cString) > 0 .And. At("Datas",cString) == 0
			
			aFiltro := StrToKarr(cString,"|")
			
			If Len(aFiltro) >= 2
			
				cFilData:= Alltrim(cValToChar(aFiltro[2]))
			
			EndIf
			
			//
			If ! Empty(cFilData)
			
				cFilData:= DToS(CToD(Alltrim(cValToChar(cFilData))))
				cFiltro := " WHERE DT_AJUST = '" + cFilData + "' "
				
			Else
			
				cFiltro := " WHERE (DT_AJUST = '' OR DT_AJUST IS NULL) "
				
			EndIf
		
		ElseIf At("Supervisor",cString) > 0 .And. At("Supervisores",cString) == 0
			
			aFiltro := StrToKarr(cString,"|")
			
			If Len(aFiltro) >= 3
				cFilData:= Alltrim(cValToChar(aFiltro[3]))
			
			EndIf
			
			//
			If ! Empty(cFilData)
			
				cFilData:= DToS(CToD(Alltrim(cValToChar(cFilData))))
				cFiltro := " WHERE DT_AJUST = '" + cFilData + "' "
				
			Else
			
				cFiltro := " WHERE (DT_AJUST = '' OR DT_AJUST IS NULL) "
				
			EndIf
			
			cFilSp  := Alltrim(cValToChar(aFiltro[2]))
			cFilSp	:= Alltrim(cValToChar(Substr(cFilSp,1,At("-",cFilSp) - 1)))
			
			If Empty(cFilSp)
				
				cFiltro += " AND (A3_SUPER IS NULL OR A3_SUPER = '') "
				
			Else
				cFiltro += " AND A3_SUPER = '" + cFilSp + "' "
				
			EndIf
			
		EndIf
		
	ElseIf nOpc == 2 // Por supervisor.
	
		If At("Supervisor",cString) > 0 .And. At("Supervisores",cString) == 0
		
			aFiltro := StrToKarr(cString,"|")
			
			cFilSp  := Alltrim(cValToChar(aFiltro[2]))
			cFilSp	:= Alltrim(cValToChar(Substr(cFilSp,1,At("-",cFilSp) - 1)))
			
			If Empty(cFilSp)
				
				cFiltro += " WHERE (A3_SUPER IS NULL OR A3_SUPER = '') "
				
			Else
				cFiltro += " WHERE A3_SUPER = '" + cFilSp + "' "
				
			EndIf
					
		ElseIf At("Data",cString) > 0 .And. At("Datas",cString) == 0
		
			aFiltro := StrToKarr(cString,"|")
			
			If Len(aFiltro) >= 2
			
				cFilData:= Alltrim(cValToChar(aFiltro[2]))
			
			EndIf
			
			//
			If ! Empty(cFilData)
			
				cFilData:= DToS(CToD(Alltrim(cValToChar(cFilData))))
				cFiltro := " WHERE DT_AJUST = '" + cFilData + "' "
				
			Else
			
				cFiltro := " WHERE (DT_AJUST = '' OR DT_AJUST IS NULL) "
				
			EndIf
			
			cFilSp  := Alltrim(cValToChar(aFiltro[3]))
			cFilSp	:= Alltrim(cValToChar(Substr(cFilSp,1,At("-",cFilSp) - 1)))
			
			If Empty(cFilSp)
				
				cFiltro += " AND (A3_SUPER IS NULL OR A3_SUPER = '') "
				
			Else
				cFiltro += " AND A3_SUPER = '" + cFilSp + "' "
				
			EndIf
			
		EndIf
	
	ElseIf nOpc == 3 // Por analista.
	
		If At("Analista",cString) > 0 .And. At("Analistas",cString) == 0
		
			aFiltro := StrToKarr(cString,"|")
			
			cFilSp  := Alltrim(cValToChar(aFiltro[2]))
			
			If Empty(cFilSp)
				
				cFiltro += " WHERE (NOME IS NULL OR NOME = '') "
				
			Else
				cFiltro += " WHERE NOME = '" + cFilSp + "' "
				
			EndIf
					
		ElseIf At("Data",cString) > 0 .And. At("Datas",cString) == 0
		
			aFiltro := StrToKarr(cString,"|")
			
			If Len(aFiltro) >= 2
			
				cFilData:= Alltrim(cValToChar(aFiltro[2]))
			
			EndIf
			
			//
			If ! Empty(cFilData)
			
				cFilData:= DToS(CToD(Alltrim(cValToChar(cFilData))))
				cFiltro := " WHERE DT_AJUST = '" + cFilData + "' "
				
			Else
			
				cFiltro := " WHERE (DT_AJUST = '' OR DT_AJUST IS NULL) "
				
			EndIf
			
			cFilSp  := Alltrim(cValToChar(aFiltro[3]))
			
			If Empty(cFilSp)
				
				cFiltro += " AND (NOME IS NULL OR NOME = '') "
				
			Else
				cFiltro += " AND NOME = '" + cFilSp + "' "
				
			EndIf
			
		EndIf
		
	EndIf
	
	//
	cQuery := " SELECT * FROM " + oTemp:GetRealName() //Everson - 11/06/2020. Chamado 058439.
	cQuery += cFiltro
	cQuery += " ORDER BY DT_AJUST, PB9_HORA, A3_SUPER, PB3_COD, PB3_LOJA "
	
	//
	If Select("PB9DT_D") > 0
		PB9DT_D->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "PB9DT_D", .F., .T.)  },"Aguarde","Consultando BD (aba " + cValToChar(nOpc) + ")...")
	DbSelectArea("PB9DT_D")
	PB9DT_D->(DbGoTop())
	If PB9DT_D->(Eof())
	
		Aadd(aDados,{0,"","","","","","","","","","","","",""})
		
	EndIf

	//
	If nOpc == 1
		nTotRegDt := 0
		cPB9FilDt := cString
		
	ElseIf nOpc == 2
		nTotRegSp := 0
		cPB9FilSp := cString
		
	ElseIf nOpc == 3
		nTotRegAn := 0
		cPB9FilAn := cString
		
	EndIf
		
	While ! PB9DT_D->(Eof())
		
		If nOpc == 1
			nTotRegDt++
			
		ElseIf nOpc == 2
			nTotRegSp++
			
		ElseIf nOpc == 3
			nTotRegAn++
			
		EndIf
		
		//'','PB3_CODSA1','PB3_LOJSA1','PB3_COD','PB3_LOJA','PB3_NOME','PB3_CODVEN','A3_SUPER','SUPERV','NOME','PB3_VENENC','DT ENVIO','HORA'
		
		Aadd(aDados,{;
					 PB9DT_D->ATRASO,;
					 PB9DT_D->PB3_CODSA1,;
					 PB9DT_D->PB3_LOJSA1,;
					 PB9DT_D->PB3_COD,;
					 PB9DT_D->PB3_LOJA,;
					 PB9DT_D->PB3_NOME,;
					 PB9DT_D->PB3_CODVEN,;
					 PB9DT_D->A3_SUPER,;
					 PB9DT_D->A3_NOMSUP,;
					 PB9DT_D->NOME,;
					 PB9DT_D->PB3_VENENC,;
					 DToC(SToD(PB9DT_D->DT_ENVIO)),;
					 DToC(SToD(PB9DT_D->DT_AJUST)),;
					 PB9DT_D->PB9_HORA;
					 })
		
		PB9DT_D->(DbSkip())
		
	EndDo
	
	//
	aDadosImp := aClone(aDados)
	cDadosImp := "Será gerado o arquivo CSV da aba " + cValToChar(nOpc) + " aplicado o filtro " + cString + ". Deseja prosseguir?"
	 
    // Seta vetor para a browse
    oBrowse:SetArray(aDados)

    // Monta a linha a ser exibina no Browse.
    oBrowse:bLine := {||{ Iif(Val(cValToChar(aDados[oBrowse:nAt,01])) == 0,oOK,Iif(Val(cValToChar(aDados[oBrowse:nAt,01])) == 3,oNE,oNO)),;
                             aDados[oBrowse:nAt,02],;
                             aDados[oBrowse:nAt,03],;
                             aDados[oBrowse:nAt,04],;
                             aDados[oBrowse:nAt,05],;
                             aDados[oBrowse:nAt,06],;
                             aDados[oBrowse:nAt,07],;
                             aDados[oBrowse:nAt,08],;
                             aDados[oBrowse:nAt,09],;
                             aDados[oBrowse:nAt,10],;
                             aDados[oBrowse:nAt,11],;
                             aDados[oBrowse:nAt,12],;
                             aDados[oBrowse:nAt,13],;   
                             aDados[oBrowse:nAt,14];  
                      } }
	
	
	
	//
	oBrowse:DrawSelect()
	oBrowse:GoTop()
	
	oPB9TotDt:Refresh()
	oPB9TotSp:Refresh()
	oPB9TotAn:Refresh()
	
	oPB9FilDt:Refresh()
	oPB9FilSp:Refresh()
	oPB9FilAn:Refresh()

	//Everson - 11/06/2020. Chamado 058439.
	oTemp:Delete()
	
	//
	RestArea(aArea)
	
Return Nil
/*{Protheus.doc} Static Function carrTreeAn
	Carrega dados no objeto DbTree.
	@type  Function
	@author Everson
	@since 21/06/2017
	@version 01	
*/
Static Function carrTreeAn(oTemp, dData,oTree)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aDados	:= {}
	Local cNVDt		:= "02"
	Local cNVSp		:= "01"
	Local nID		:= 0	
	Local imgNv0Abt := "FOLDER5"
	Local imgNv0Fch := "FOLDER6"	
	Local imgNv1Abt := Nil
	Local imgNv1Fch	:= Nil 			
	Local imgAn 	:= "BMPUSER"	
	Local cAnalista	:= ""
	Local cData		:= ""
	
	//Reinicia objetos DBTree.
	oTree:Reset()
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " DISTINCT FONTE.DT_AJUST AS PB9_DATA, FONTE.NOME "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += " SELECT * FROM " + oTemp:GetRealName() //Everson - 11/06/2020. Chamado 058439.
	
	cQuery += " ) AS FONTE "
	cQuery += "ORDER BY NOME, DT_AJUST "
	
	//
	If Select("PB9DT") > 0
		PB9DT->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "PB9DT", .F., .T.)  },"Aguarde","Consultando BD (aba Analista)...")
	DbSelectArea("PB9DT")
	PB9DT->(DbGoTop())
	If PB9DT->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	Aadd(aDados,{'00',"001","","Analistas" ,imgNv0Abt,imgNv0Fch}) 
	
	//
	While ! PB9DT->(Eof())
		
		//
		cAnalista := Alltrim(cValToChar(PB9DT->NOME))
		nID++
		
		//
		Aadd(aDados,{cNVSp,Padl(Alltrim(cValToChar(nID)),6,"0"),"","Analista|" + cAnalista ,imgAn,imgAn})
		
		While ! PB9DT->(Eof()) .And. cAnalista == Alltrim(cValToChar(PB9DT->NOME))
			
			cData := Alltrim(cValToChar(PB9DT->PB9_DATA))
			
			If Empty(cData)
				imgNv1Abt := "FOLDER12"
				imgNv1Fch := "FOLDER13"
							
			ElseIf (Date() - SToD(cData)) > 0
				imgNv1Abt := "FOLDER7"
				imgNv1Fch := "FOLDER8"
				
			Else
				imgNv1Abt := "FOLDER10"
				imgNv1Fch := "FOLDER11"
			
			EndIf
			
			//
			Aadd(aDados,{cNVDt,Padl(Alltrim(cValToChar(nID)),6,"0"),"","Data | " + Iif(! Empty(cData),DToC(SToD(cData)),"") + " | "+ Alltrim(cValToChar(PB9DT->NOME)) ,imgNv1Abt,imgNv1Fch})
			
			//
			PB9DT->(DbSkip())
		
		EndDo
		
	EndDo
	
	//
	oTree:BeginUpdate()
	oTree:PTSendTree(aDados)
	oTree:EndUpdate()
	
	//
	oTree:PTRefresh()
	
	//
	RestArea(aArea)
	
Return Nil
/*{Protheus.doc} Static Function carrTreeSp
	Carrega dados no objeto DbTree.
	@type  Function
	@author Everson
	@since 21/06/2017
	@version 01	
*/
Static Function carrTreeSp(oTemp,dData,oTree)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aDados	:= {}
	Local cNVDt		:= "02"
	Local cNVSp		:= "01"
	Local nID		:= 0
	Local imgNv0Abt := "FOLDER5"
	Local imgNv0Fch := "FOLDER6"
	Local imgNv1Abt := Nil
	Local imgNv1Fch := Nil	
	Local imgSup 	:= "CLIENTE"
	Local cSuper	:= ""
	Local cData		:= ""
	
	//Reinicia objetos DBTree.
	oTree:Reset()
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " DISTINCT FONTE.DT_AJUST AS PB9_DATA, FONTE.A3_SUPER, FONTE.A3_NOMSUP "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += " SELECT * FROM " + oTemp:GetRealName() //Everson - 11/06/2020. Chamado 058439.
	
	cQuery += " ) AS FONTE "
	cQuery += " ORDER BY A3_SUPER, PB9_DATA  "
	
	//
	If Select("PB9DT") > 0
		PB9DT->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "PB9DT", .F., .T.)  },"Aguarde","Consultando BD (aba Supervisor)...")
	DbSelectArea("PB9DT")
	PB9DT->(DbGoTop())
	If PB9DT->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	Aadd(aDados,{'00',"001","","Supervisores" ,imgNv0Abt,imgNv0Fch}) 
	
	//
	While ! PB9DT->(Eof())
		
		//
		cSuper := Alltrim(cValToChar(PB9DT->A3_SUPER)) + "-" + Alltrim(cValToChar(PB9DT->A3_NOMSUP))
		nID++
		
		//
		Aadd(aDados,{cNVSp,Padl(Alltrim(cValToChar(nID)),6,"0"),"","Supervisor|" + cSuper ,imgSup,imgSup})
		
		While ! PB9DT->(Eof()) .And. cSuper == Alltrim(cValToChar(PB9DT->A3_SUPER)) + "-" + Alltrim(cValToChar(PB9DT->A3_NOMSUP))
			
			cData := Alltrim(cValToChar(PB9DT->PB9_DATA))
			
			If Empty(cData)
				imgNv1Abt := "FOLDER12"
				imgNv1Fch := "FOLDER13"
							
			ElseIf (Date() - SToD(cData)) > 0
				imgNv1Abt := "FOLDER7"
				imgNv1Fch := "FOLDER8"
				
			Else
				imgNv1Abt := "FOLDER10"
				imgNv1Fch := "FOLDER11"
			
			EndIf
			
			//
			Aadd(aDados,{cNVDt,Padl(Alltrim(cValToChar(nID)),6,"0"),"","Data | " + Iif(! Empty(cData),DToC(SToD(cData)),"") + " | "+ Alltrim(cValToChar(PB9DT->A3_SUPER)) + "-" +;
			             Alltrim(cValToChar(PB9DT->A3_NOMSUP)) ,imgNv1Abt,imgNv1Fch})
			
			//
			PB9DT->(DbSkip())
		
		EndDo
		
	EndDo
	
	//
	oTree:BeginUpdate()
	oTree:PTSendTree(aDados)
	oTree:EndUpdate()
	
	//
	oTree:PTRefresh()
	
	//
	RestArea(aArea)
	
Return Nil
/*{Protheus.doc} Static Function carrTreeDt
	Carrega dados no objeto DbTree.
	@type  Function
	@author Everson
	@since 21/06/2017
	@version 01	
*/
Static Function carrTreeDt(oTemp,dData,oTree)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aDados	:= {}
	Local cNVDt		:= "01"
	Local cNVSp		:= "02"
	Local nID		:= 0
	Local imgNv0Abt := "FOLDER5"
	Local imgNv0Fch := "FOLDER6"
	Local imgNv1Abt	:= Nil 
	Local imgNv1Fch	:= Nil 	
	Local imgSup 	:= "CLIENTE"
	Local cData		:= ""
	
	//Reinicia objetos DBTree.
	oTree:Reset()
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " DISTINCT FONTE.DT_AJUST AS PB9_DATA, FONTE.A3_SUPER, FONTE.A3_NOMSUP "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += " SELECT * FROM " + oTemp:GetRealName() //Everson - 11/06/2020. Chamado 058439.
	
	cQuery += " ) AS FONTE "
	cQuery += " ORDER BY PB9_DATA, A3_SUPER "
	
	//
	If Select("PB9DT") > 0
		PB9DT->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "PB9DT", .F., .T.)  },"Aguarde","Consultando BD (aba Datas)...")
	DbSelectArea("PB9DT")
	PB9DT->(DbGoTop())
	If PB9DT->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	Aadd(aDados,{'00',"001","","Datas" ,imgNv0Abt,imgNv0Fch}) 
	
	//
	While ! PB9DT->(Eof())
		
		//
		cData := Alltrim(cValToChar(PB9DT->PB9_DATA))
		nID++
		
		If Empty(cData)
			imgNv1Abt := "FOLDER12"
			imgNv1Fch := "FOLDER13"
						
		ElseIf (Date() - SToD(cData)) > 0
			imgNv1Abt := "FOLDER7"
			imgNv1Fch := "FOLDER8"
			
		Else
			imgNv1Abt := "FOLDER10"
			imgNv1Fch := "FOLDER11"
		
		EndIf
		
		//
		Aadd(aDados,{cNVDt,Padl(Alltrim(cValToChar(nID)),6,"0"),"","Data|" + If(! Empty(cData),DToC(SToD(cData)),"") ,imgNv1Abt,imgNv1Fch})
		
		While ! PB9DT->(Eof()) .And. cData == Alltrim(cValToChar(PB9DT->PB9_DATA))
			
			//
			Aadd(aDados,{cNVSp,Padl(Alltrim(cValToChar(nID)),6,"0"),"","Supervisor | " + Alltrim(cValToChar(PB9DT->A3_SUPER)) + "-" +;
			             Alltrim(cValToChar(PB9DT->A3_NOMSUP)) + " | " + If(! Empty(cData),DToC(SToD(cData)),"")  ,imgSup,imgSup})
			
			//
			PB9DT->(DbSkip())
		
		EndDo
		
	EndDo
	
	//
	oTree:BeginUpdate()
	oTree:PTSendTree(aDados)
	oTree:EndUpdate()
	
	//
	oTree:PTRefresh()
	
	//
	RestArea(aArea)
	
Return Nil
/*{Protheus.doc} Static Function grCSV
	Gera arquivo CSV.
	@type  Function
	@author Everson
	@since 19/06/2017
	@version 01	
*/
Static Function grCSV(aDados,cArq,oTTabs)

	//Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl		:= 0
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	Local aHReg		:= colunaBrw()
	
	//
	If Empty(cDadosImp)
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If ! MsgYesNo(cDadosImp,"Função grCSV")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	//
	If Empty(Alltrim(cValToChar(cDir)))
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)
	
	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSV")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	cLin := ""
	For i := 1 To Len(aHReg)
		cLin += cValToChar(aHReg[i]) + ";"
	
	Next i
	
	cLin += cEof
	
	For i := 1 To Len(aDados)
	
		For w := 1 To Len(aHReg)
			
			cLin += cValToChar(aDados[i][w]) + ";"
		
		Next w
		
		cLin += cEof
		
		FWrite(nHdl,cLin,Len(cLin))
		
		cLin := ""
	
	Next i
	
	//Fecha o arquivo.
	FClose(nHdl)
	
	//
	WinExec("Explorer.exe" + Space(1) + cDir )
	
	//
	MsgInfo("Arquivo gerado.","Função grCSV")
	
	//
	RestArea(aArea)

Return Nil
/*{Protheus.doc} Static Function sqlPB9Pen
	Retorna script de arquivos pendentes.
	@type  Function
	@author Everson
	@since 20/06/2017
	@version 01	
*/
Static Function sqlPB9Pen(dData)

	//Variáveis.
	Local aArea		 := GetArea()
	Local cQuery 	 := ""
	Local cPB3VENENC := Alltrim(cValToChar(GetMv("MV_#CADVER")))
	Local aVendR	 := {}
	Local cVendRUs	 := ""
	//Local nDias		 := Val(cValToChar(GetMv("MV_#CADDAN")))

	//Everson - 11/06/2020. Chamado 058439.
	Local oTempTable := Nil
	Local aFields 	 := {}
	Local cAliasT 	 := ""
	Local cAlsBase	 := ""
	Local cData 	 := ""
	Local nAtrs 	 := 3
	//

	//Everson - 01/02/2021. Chamado 8550.
	Local cDiaVnc 	 := Separa(Alltrim(cValToChar(GetMv("MV_#FNVC",,"3,2,2,2,4,4,4"))),",",.F.)
	Local i 		 := 1
	//
	
	//
	If ! Empty(cPB3VENENC)
		
		aVendR := StrToKarr(cPB3VENENC,"/")
		
		For i := 1 To Len(aVendR)
			
			cVendRUs += "'" + Alltrim(cValToChar(aVendR[i])) + "',"
			
		Next i
		
		cVendRUs := Substr(cVendRUs,1,Len(cVendRUs) -1 )
		
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " * " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += "  " 
	cQuery += " SELECT   " 
	cQuery += " PB3_CODSA1,  " 
	cQuery += " PB3_LOJSA1,  " 
	cQuery += " PB3_COD,  " 
	cQuery += " PB3_LOJA,  " 
	cQuery += " PB3_NOME,  " 
	cQuery += " PB3_CODVEN,  " 
	cQuery += " FUNC.PB2_NOME AS 'NOME',  " 
	cQuery += " VEN.A3_SUPER,  " 
	cQuery += " CAD.PB3_VENENC, " 
	cQuery += " SUP.ZR_DESCRIC AS A3_NOMSUP, " 
	cQuery += " CONVERT(VARCHAR,CAST(B_LOG.[DT.ENVIO] AS DATE),112) AS DT_ENVIO, "
	cQuery += " CONVERT(VARCHAR,CAST(B_LOG.DT_TESTE AS DATE),112) AS DT_AJUST, "
	cQuery += " B_LOG.PB9_HORA " 
	cQuery += " FROM  " 
	
	cQuery += " " + RetSqlName("PB3") + " (NOLOCK) AS CAD " 
	cQuery += " LEFT OUTER JOIN ( SELECT PB2_CODIGO, PB2_NOME FROM " + RetSqlName("PB2") + " (NOLOCK) AS FUNC WHERE FUNC.D_E_L_E_T_ = '' ) AS FUNC ON CAD.PB3_VENENC = FUNC.PB2_CODIGO " 
	cQuery += " LEFT OUTER JOIN ( SELECT A3_COD, A3_NOMSUP, A3_SUPER, A3_CODSUP FROM " + RetSqlName("SA3") + " (NOLOCK) AS VEN  WHERE VEN.D_E_L_E_T_ = '') AS VEN ON CAD.PB3_CODVEN = VEN.A3_COD "
	cQuery += " LEFT OUTER JOIN ( SELECT ZR_CODIGO, ZR_DESCRIC FROM " + RetSqlName("SZR") + " (NOLOCK) AS SUP  WHERE SUP.D_E_L_E_T_ = '') AS SUP ON VEN.A3_CODSUP = SUP.ZR_CODIGO "  
	cQuery += " LEFT OUTER JOIN " 
	
	cQuery += " ( " 
	cQuery += " SELECT "
	cQuery += " FONTE.PB9_CODIGO, "
	cQuery += " FONTE.PB9_LOJA, "
	cQuery += " SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIO],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS [DT.ENVIO], "
	cQuery += " SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIO],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),9,5) AS PB9_HORA, "
	
	cQuery += " CAST( "

		cQuery += " CASE "

			//Domingo. Everson - 07/01/2020. Chamado 053485. 
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 1 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[1] + "  " //Everson - 01/02/2021. Chamado 8550.

			//Segunda. Everson - 11/06/2020. Chamado 058854 .
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 2 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[2] + "  " //Everson - 01/02/2021. Chamado 8550.

			//Terça. Everson - 11/06/2020. Chamado 058854 .
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 3 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[3] + "  " //Everson - 01/02/2021. Chamado 8550.

			//Quarta. Everson - 11/06/2020. Chamado 058854 .
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 4 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[4] + "  " //Everson - 01/02/2021. Chamado 8550.

			//Quinta. Everson - 11/06/2020. Chamado 058854 .
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 5 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[5] + "  " //Everson - 01/02/2021. Chamado 8550.

			//Sexta. Everson - 11/06/2020. Chamado 058854 .
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 6 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[6] + "  " //Everson - 01/02/2021. Chamado 8550.

			//Sábado. Everson - 07/01/2020. Chamado 053485.
			cQuery += " WHEN DATEPART(DW,CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME)) = 7 " //Everson - 13/05/2021. Chamado 13976.
				cQuery += " THEN CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) + " + cDiaVnc[7] + "  " //Everson - 01/02/2021. Chamado 8550.

			//
			cQuery += " ELSE CAST(SUBSTRING(MAX(CONVERT(VARCHAR,FONTE.[DT.ENVIOC],112) + CAST(FONTE.PB9_HORA AS VARCHAR)),1,8) AS DATETIME) " //Everson - 13/05/2021. Chamado 13976.

		cQuery += " END "

	cQuery += " AS DATETIME) AS DT_TESTE "
	
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += sqlBLog(dData)
	
	cQuery += " ) AS FONTE  "

	cQuery += " GROUP BY "
	cQuery += " FONTE.PB9_CODIGO, "
	cQuery += " FONTE.PB9_LOJA "
	
	cQuery += " ) AS B_LOG ON " 
	cQuery += " CAD.PB3_COD = B_LOG.PB9_CODIGO " 
	cQuery += " AND CAD.PB3_LOJA = B_LOG.PB9_LOJA " 
	cQuery += " WHERE  " 
	cQuery += " CAD.D_E_L_E_T_ = ''  " 
	
	//
	If ! Empty(cVendRUs)	
		cQuery += " AND CAD.PB3_VENENC IN  " 
		cQuery += " (" + cVendRUs + ") " 
	
	EndIf
	
	cQuery += "  " 
	cQuery += " ) AS FONTE " 

	//
	cAlsBase := GetNextAlias()
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQuery), cAlsBase, .F., .T.)
	(cAlsBase)->(DbGoTop())

	//
	cAliasT := GetNextAlias()
	oTempTable := FWTemporaryTable():New( cAliasT )

	//
	Aadd(aFields,{"PB3_CODSA1","C",TamSX3("PB3_CODSA1")[1],0})
	Aadd(aFields,{"PB3_LOJSA1","C",TamSX3("PB3_LOJSA1")[1],0})
	Aadd(aFields,{"PB3_COD"   ,"C",TamSX3("PB3_COD")[1]   ,0})
	Aadd(aFields,{"PB3_LOJA"  ,"C",TamSX3("PB3_LOJA")[1]   ,0})
	Aadd(aFields,{"PB3_NOME"  ,"C",TamSX3("PB3_NOME")[1]  ,0})
	Aadd(aFields,{"PB3_CODVEN","C",TamSX3("PB3_CODVEN")[1],0})

	Aadd(aFields,{"NOME"      ,"C",TamSX3("PB2_NOME")[1],0})
	Aadd(aFields,{"A3_SUPER"  ,"C",TamSX3("A3_SUPER")[1],0})
	Aadd(aFields,{"PB3_VENENC","C",TamSX3("PB3_VENENC")[1],0})
	Aadd(aFields,{"A3_NOMSUP" ,"C",TamSX3("A3_NOMSUP")[1],0})
	Aadd(aFields,{"DT_ENVIO"  ,"C",TamSX3("PB9_DATA")[1],0})
	Aadd(aFields,{"DT_AJUST"  ,"C",TamSX3("PB9_DATA")[1],0})
	Aadd(aFields,{"PB9_HORA"  ,"C",TamSX3("PB9_HORA")[1],0})
	Aadd(aFields,{"ATRASO"    ,"N",1,0})

	//
	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("indice1", {"PB3_CODSA1","PB3_LOJSA1"} )
	oTempTable:AddIndex("indice2", {"PB3_COD", "PB3_LOJA"} )
	oTempTable:AddIndex("indice3", {"PB3_CODVEN"} )

	//
	oTempTable:Create()

	//
	While ! (cAlsBase)->(Eof())

		//
		cData := ""
		nAtrs := 3
		vldData((cAlsBase)->DT_ENVIO, (cAlsBase)->DT_AJUST,@cData,@nAtrs)
		
		//
		RecLock(cAliasT,.T.)
			(cAliasT)->PB3_CODSA1 	:= (cAlsBase)->PB3_CODSA1
			(cAliasT)->PB3_LOJSA1	:= (cAlsBase)->PB3_LOJSA1
			(cAliasT)->PB3_COD		:= (cAlsBase)->PB3_COD
			(cAliasT)->PB3_LOJA		:= (cAlsBase)->PB3_LOJA
			(cAliasT)->PB3_NOME		:= (cAlsBase)->PB3_NOME
			(cAliasT)->PB3_CODVEN	:= (cAlsBase)->PB3_CODVEN
			(cAliasT)->NOME			:= (cAlsBase)->NOME
			(cAliasT)->A3_SUPER		:= (cAlsBase)->A3_SUPER
			(cAliasT)->PB3_VENENC	:= (cAlsBase)->PB3_VENENC
			(cAliasT)->A3_NOMSUP	:= (cAlsBase)->A3_NOMSUP
			(cAliasT)->DT_ENVIO		:= (cAlsBase)->DT_ENVIO
			(cAliasT)->DT_AJUST		:= cData
			(cAliasT)->PB9_HORA		:= (cAlsBase)->PB9_HORA
			(cAliasT)->ATRASO		:= nAtrs
		(cAliasT)->(MsUnlock())

		(cAlsBase)->(DbSkip())
	End 

	//
	RestArea(aArea)	
	
Return oTempTable
/*/{Protheus.doc} vldData
	Valida data limite de avaliação de cadastro.
	@type  Static Function
	@author user
	@since 11/06/2020
	@version 01
	/*/
Static Function vldData(cDtEnv,cDtVl,cData,nAtrs)

	//Variáveis.
	Local dDtLoop := Nil
	Local dDtLim  := Nil
	Local nDiasF  := 0

	//
	If ! Empty(cDtEnv) .And. ! Empty(cDtVl)
		
		//
		dDtLoop := SToD(cDtEnv)
		dDtLim  := SToD(cDtVl)
		dDtLoop := DaySum(dDtLoop, 1) //Começa a contar a partir da data seguinte.

		//Verifica se há ferido entre as datas de envio de data limite estipulada.
		While dDtLoop <= dDtLim
			//
			If DataValida(dDtLoop) <> dDtLoop .And. DoW(dDtLoop) <> 7 .And. Dow(dDtLoop) <> 1 //Feriado que não seja sábado nem domingo.
				nDiasF++

			EndIf

			//
			dDtLoop := DaySum(dDtLoop, 1)

		End

		//
		If nDiasF > 0
			dDtLim := DaySum(dDtLim, nDiasF)
			
		EndIf

		//
		dDtLim := DataValida(dDtLim)
		cData  := DToS(dDtLim)

		//
		If (Date() - dDtLim) > 0
			nAtrs := 1

		Else
			nAtrs := 0

		EndIf

	Else
		nAtrs := 3
		cData := ""

	EndIf

Return Nil
/*{Protheus.doc} Static Function sqlBLog
	Retorna script base log.
	@type  Function
	@author Everson
	@since 21/06/2017
	@version 01	
*/
Static Function sqlBLog(dData)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""	
	Local cPB9CPODEP:= Alltrim(cValToChar(GetMv("MV_#CADCAP")))
	Local aDep		:= {}
	Local cDepUs	:= ""
	Local cPB9CPOANT:= Alltrim(cValToChar(GetMv("MV_#CADCAN")))
	Local aAnt		:= {}
	Local cAntUs	:= ""
	Local i 		:= 1
	Local cHrLim    := Alltrim(cValToChar(GetMv("MV_#HRLCAD",,"18:00"))) //Everson - 13/05/2021. Chamado 13976.
	
	//
	If ! Empty(cPB9CPODEP)
		
		aDep := StrToKarr(cPB9CPODEP,"/")
		
		For i := 1 To Len(aDep)
			
			cDepUs += "'" + Alltrim(cValToChar(aDep[i])) + "',"
			
		Next i
		
		cDepUs := Substr(cDepUs,1,Len(cDepUs) -1 )
		
	EndIf
	
	//
	If ! Empty(cPB9CPOANT)
	
		aAnt := StrToKarr(cPB9CPOANT,"/")
		
		For i := 1 To Len(aAnt)
		
			cAntUs += "'" + Alltrim(cValToChar(aAnt[i])) + "',"
		
		Next i
		
		cAntUs := Substr(cAntUs,1,Len(cAntUs) -1 )
	
	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " MAX(CAST(LOG.PB9_DATA AS DATETIME)) AS 'DT.ENVIO', " //Chamado 8550 - Everson  - 01/02/2021.
	cQuery += " CASE WHEN PB9_HORA > '" + cHrLim + "' THEN MAX(CAST(LOG.PB9_DATA AS DATETIME)) + 1 ELSE MAX(CAST(LOG.PB9_DATA AS DATETIME)) END AS 'DT.ENVIOC', " //Everson - 13/05/2021. Chamado 13976.
	cQuery += " MAX(LOG.PB9_DATA) AS DTTEXTO, "
	cQuery += " VEN.A3_SUPER,  " 
	cQuery += " LOG.PB9_CODIGO,  " 
	cQuery += " LOG.PB9_LOJA,  " 
	cQuery += " LOG.PB9_USUARI,  " 
	cQuery += " LOG.PB9_CPOALT,  " 
	cQuery += " LOG.PB9_CPOANT,  " 
	cQuery += " LOG.PB9_CPODEP,  " 
	cQuery += " LOG.PB9_HORA " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("PB9") + " (NOLOCK) LOG " 
	cQuery += " INNER JOIN " + RetSqlName("PB3") + " (NOLOCK) AS CAD ON (CAD.PB3_COD=LOG.PB9_CODIGO) AND (CAD.PB3_LOJA=LOG.PB9_LOJA) AND (CAD.D_E_L_E_T_ = '') " 
	cQuery += " LEFT  JOIN " + RetSqlName("SA3") + " (NOLOCK) AS VEN ON (VEN.A3_COD=CAD.PB3_CODVEN) AND (VEN.D_E_L_E_T_ = '') " 
	cQuery += " WHERE  " 
	cQuery += " LOG.D_E_L_E_T_ = ''  " 
	cQuery += " AND LOG.PB9_CPOALT = 'Vend. Encami'  "
	
	If ! Empty(cDepUs)
		cQuery += " AND (LEFT(LOG.PB9_CPODEP,6))  " 
		cQuery += " IN (" + cDepUs + ")  " 
	
	EndIf
	
	If ! Empty(cAntUs)
		cQuery += " AND (LEFT(LOG.PB9_CPOANT,6)) NOT IN  " 
		cQuery += " (" + cAntUs + ")  " 
	
	EndIf
	
	cQuery += " AND PB9_DATA >= '" + DToS(dData) + "' " 
	cQuery += " GROUP BY  " 
	cQuery += " LOG.PB9_DATA, " 
	cQuery += " VEN.A3_SUPER,  " 
	cQuery += " LOG.PB9_CODIGO,  " 
	cQuery += " LOG.PB9_LOJA,  " 
	cQuery += " LOG.PB9_USUARI,  " 
	cQuery += " LOG.PB9_CPOALT,  " 
	cQuery += " LOG.PB9_CPOANT,  " 
	cQuery += " LOG.PB9_CPODEP,  " 
	cQuery += " LOG.PB9_HORA " 

	//
	RestArea(aArea)	
	
Return cQuery 
/*{Protheus.doc} Static Function carrAprv
	Carrega registros aprovados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function carrAprv(dData,oPB9PnlAp,oRegAp)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aAnalista	:= {}
	Local nPosAn	:= 0
	Local aAltCdAp  := {}
	Local aColsCdAp := {}
	Local aDados	:= {}
	Local i			:= 0
	Local aDatas	:= {}
	Local nTotGer	:= 0
	
	//
	If ValType(oRegAp) == "O"
		FreeObj(oRegAp:oBrowse)
		FreeObj(oRegAp)
		
	EndIf
	
	//
	If ValType(oCSVAp) == "O"
		FreeObj(oCSVAp)
		
	EndIf
	
	//
	cQuery += " SELECT "
	cQuery += " FONTE.DT_ENVIO, FONTE.PB9_USUARI, COUNT(*) AS TT "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += sqlAprov(1,dData)
	
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY "
	cQuery += " FONTE.DT_ENVIO, "
	cQuery += " FONTE.PB9_USUARI "
	cQuery += " ORDER BY "
	cQuery += " FONTE.DT_ENVIO, "
	cQuery += " FONTE.PB9_USUARI "
	
	If Select("D_APRV") > 0
		D_APRV->(DbCloseArea())
		
	EndIf
	
	aHCdAp := {}
	Aadd(aHCdAp,{"Data","DATA" ,"",08, 0,"","" ,"D","",""})
	
	//
	TcQuery cQuery New Alias "D_APRV"

	D_APRV->(DbGoTop())
	
	//
	While ! D_APRV->(Eof())
		
		//
		If aScan(aHCdAp,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_APRV->PB9_USUARI)) }) == 0
			
			Aadd(aHCdAp,{Alltrim(cValToChar(D_APRV->PB9_USUARI)),Alltrim(cValToChar(D_APRV->PB9_USUARI)),"@E 999,999,999" ,11, 0,"","" ,"N","",""})
		
		EndIf
		
		//
		nPosAn := aScan(aAnalista,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_APRV->PB9_USUARI)) })
		If nPosAn == 0
			
			Aadd(aAnalista,{Alltrim(cValToChar(D_APRV->PB9_USUARI)),Val(cValToChar(D_APRV->TT))})
			
		Else
			
			aAnalista[nPosAn][2] += Val(cValToChar(D_APRV->TT))
		
		EndIf		
		
		//
		nPosAn := aScan(aDatas,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_APRV->DT_ENVIO)) })
		If nPosAn == 0
			
			Aadd(aDatas,{Alltrim(cValToChar(D_APRV->DT_ENVIO)),Val(cValToChar(D_APRV->TT))})
			
		Else
			
			aDatas[nPosAn][2] += Val(cValToChar(D_APRV->TT))
			
		EndIf
		
		//
		Aadd(aDados,{Alltrim(cValToChar(D_APRV->DT_ENVIO)),Alltrim(cValToChar(D_APRV->PB9_USUARI)),Val(cValToChar(D_APRV->TT))})
		
		nTotGer += Val(cValToChar(D_APRV->TT))
		
		D_APRV->(DbSkip())
		
	EndDo
	
	//
	Aadd(aDatas,{"Total",nTotGer})
	
	//
	Aadd(aHCdAp,{"Total" ,"TOTAL" ,"@E 999,999,999" ,11, 0,"","" ,"N","",""})
	
	//
	oRegAp := MsNewGetDados():New(020,001,210,260,,"Allwaystrue()","Allwaystrue()","",aAltCdAp,1,999,Nil,Nil,Nil,oPB9PnlAp,aHCdAp,@aColsCdAp)
	oRegAp:oBrowse:bLDblClick := {|| detApr(oRegAp,aHCdAp,dData) }
	
	//
	If Len(aDatas) > 0
		oRegAp:aCols := {}
		
	EndIf
	
	//
	For i := 1 To Len(aDatas)
		
		Aadd(oRegAp:aCols , Array(Len(aHCdAp) + 1) )
		oRegAp:aCols[Len(oRegAp:aCols), Len(oRegAp:aCols[1]) ] := .F.
	
		oRegAp:aCols[Len(oRegAp:aCols),Ascan(aHCdAp,{|x| AllTrim(x[2]) == "DATA" })] := Iif(cValToChar(aDatas[i][1]) == "Total",cValToChar(aDatas[i][1]),DToC(SToD(aDatas[i][1])))
		
		oRegAp:aCols[Len(oRegAp:aCols),Ascan(aHCdAp,{|x| AllTrim(x[2]) == "TOTAL"})] := Val(cValToChar(aDatas[i][2]))
		
	Next i
	
	//
	For i := 1 To Len(oRegAp:aCols)
		
		For w := 1 To Len(aHCdAp)
		
			For y := 1 To Len(aDados)
			
				If cValToChar(oRegAp:aCols[i,Ascan(aHCdAp,{|x| AllTrim(x[2]) == "DATA" })]) == Iif(cValToChar(aDados[y][1]) == "Total",cValToChar(aDados[y][1]),DToC(SToD(aDados[y][1]))) .And.;
				   Alltrim(cValToChar(aHCdAp[w][2])) == Alltrim(cValToChar(aDados[y][2]))
					
					oRegAp:aCols[i,Ascan(aHCdAp,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aDados[y][2])) })] := Val(cValToChar(aDados[y][3]))
					
				EndIf
			
			Next y
		
		Next w
	
	Next i
	
	//
	If nTotGer > 0
			
		For w := 1  To Len(aHCdAp)
			
			For y := 1 To Len(aAnalista)
			
				If Alltrim(cValToChar(aAnalista[y][1])) == Alltrim(cValToChar(aHCdAp[w][2]))
				
					oRegAp:aCols[Len(oRegAp:aCols),Ascan(aHCdAp,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aHCdAp[w][2]))})] := Val(cValToChar(aAnalista[y][2]))
				
				EndIf
			
			Next y
			
		Next w
	
	EndIf
	
	//
	oCSVAp := TButton():New(215,220,"CSV" ,oPB9PnlAp, {|| MsAguarde({||;
																			grLRCCSV(oRegAp,aHCdAp,"CAD_APROV_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV");
																			},"Aguarde","Exportando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//
	oRegAp:Refresh()
	
	//
	RestArea(aArea)	
	
Return Nil
/*{Protheus.doc} Static Function detApr
	Detalhe de registros aprovados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function detApr(oRegAp,aHCdAp,dData)

	//Variáveis.
	Local aArea		:= GetArea()
	Local oIntAp	:= Nil	
	Local oRegsAp	:= Nil
	Local aAltRgRp	:= {}
	Local aHRgAp	:= {}
	Local aColsRgRp	:= {}
	Local oCSV		:= Nil
	Local cQuery	:= ""
	Local nPosCol	:= oRegAp:oBrowse:ColPos
	Local cColun	:= Alltrim(cValToChar(aHCdAp[nPosCol][2]))
	Local cData		:= Alltrim(cValToChar(oRegAp:aCols[oRegAp:nAt][Ascan(aHCdAp,{|x| AllTrim(x[2]) == "DATA" })]))
	Local dDtQ		:= dData
	
	//
	If cData <> "Total"
		dDtQ := CToD(cData)
		
	EndIf
	
	//
	If cColun == "TOTAL"
		cColun := ""
		
	EndIf
	
	//
	If (Empty(cColun) .And. cData == "Total") .Or. cData == "Total"
		cQuery := sqlAprov(3,dDtQ,cColun)
		
	Else
		cQuery := sqlAprov(2,dDtQ,cColun)
	
	EndIf
	
	cQuery += " ORDER BY DT_ENVIO,PB3_CODSA1,PB3_LOJSA1 "
	
	//
	If Select("DET_APR") > 0
		DET_APR->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "DET_APR", .F., .T.)  },"Aguarde","Consultando BD(detalhe aprovado)...")
	DbSelectArea("DET_APR")
	DET_APR->(DbGoTop())
	If DET_APR->(Eof())
		MsgStop("Não há dados a serem exibidos.","Função detApr")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	oIntAp		   := MsDialog():Create()
	oIntAp:cName     := "oIntAp"
	oIntAp:cCaption  := "Registros Aprovados"
	oIntAp:nLeft     := 34
	oIntAp:nTop      := 222
	oIntAp:nWidth    := 1200
	oIntAp:nHeight   := 550
	oIntAp:lShowHint := .F.
	oIntAp:lCentered := .T.
	

		Aadd(aHRgAp,{"PB9_USUARI","PB9_USUARI" ,"" ,TamSX3("PB9_USUARI")[1],, 0,"","" ,"C","",""})		
		Aadd(aHRgAp,{"PB9_CPODEP","PB9_CPODEP" ,"" ,TamSX3("PB9_CPODEP")[1],, 0,"","" ,"C","",""})		
		Aadd(aHRgAp,{"PB3_CODSA1","PB3_CODSA1" ,"" ,TamSX3("PB3_CODSA1")[1],, 0,"","" ,"C","",""})		
		Aadd(aHRgAp,{"PB3_LOJSA1","PB3_LOJSA1" ,"" ,TamSX3("PB3_LOJSA1")[1],, 0,"","" ,"C","",""})		
		Aadd(aHRgAp,{"PB3_NOME"  ,"PB3_NOME"   ,"" ,TamSX3("PB3_NOME")[1],, 0,"","" ,"C","",""})	
	
		oRegsAp := MsNewGetDados():New(001,005,234,595,,"Allwaystrue()","Allwaystrue()","",aAltRgRp,1,999,Nil,Nil,Nil,oIntAp,aHRgAp,@aColsRgRp)
		oRegsAp:aCols := {}
		
		While ! DET_APR->(Eof())
		
			Aadd(oRegsAp:aCols , Array(Len(aHRgAp) + 1) )
			oRegsAp:aCols[Len(oRegsAp:aCols), Len(oRegsAp:aCols[1]) ] := .F.

			oRegsAp:aCols[Len(oRegsAp:aCols),Ascan(aHRgAp,{|x| AllTrim(x[2]) == "PB9_USUARI" })] := DET_APR->PB9_USUARI
			oRegsAp:aCols[Len(oRegsAp:aCols),Ascan(aHRgAp,{|x| AllTrim(x[2]) == "PB9_CPODEP" })] := DET_APR->PB9_CPODEP
			oRegsAp:aCols[Len(oRegsAp:aCols),Ascan(aHRgAp,{|x| AllTrim(x[2]) == "PB3_CODSA1" })] := DET_APR->PB3_CODSA1
			oRegsAp:aCols[Len(oRegsAp:aCols),Ascan(aHRgAp,{|x| AllTrim(x[2]) == "PB3_LOJSA1" })] := DET_APR->PB3_LOJSA1
			oRegsAp:aCols[Len(oRegsAp:aCols),Ascan(aHRgAp,{|x| AllTrim(x[2]) == "PB3_NOME"   })] := DET_APR->PB3_NOME
			

		    DET_APR->(DbSkip())
			
		EndDo
		
		//
		oRegsAp:Refresh()
		
		oCSV := TButton():New(245,505,"CSV",oIntAp,{|| grLRCCSV(oRegsAp,aHRgAp,"CAD_DET_APROV_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oFechar	 := TButton():New(245,550,"Fechar",oIntAp,{|| oIntAp:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oIntAp:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)	

Return Nil
/*{Protheus.doc} Static Function sqlAprov
	Retorna script de registros aprovados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function sqlAprov(nOPc,dData,cUsuario)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//
	cUsuario := Alltrim(cValToChar(cUsuario))

	cQuery := ""
	cQuery += " SELECT CONVERT(varchar, PB9_DATA, 112) AS DT_ENVIO,PB9_USUARI,PB9_CPODEP,PB3_CODSA1,PB3_LOJSA1,PB3_NOME"
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("PB9") + " (NOLOCK) LOG " 
	cQuery += " INNER JOIN " + RetSqlName("PB3") + " (NOLOCK) CAD  ON (CAD.PB3_COD = LOG.PB9_CODIGO) AND (CAD.PB3_LOJA = LOG.PB9_LOJA) " 
	cQuery += " LEFT  JOIN " + RetSqlName("PB2") + " (NOLOCK) FUNC ON (CAD.PB3_VENENC=FUNC.PB2_CODIGO) AND (FUNC.D_E_L_E_T_ = '') " 
	cQuery += " LEFT  JOIN " + RetSqlName("SA3") + " (NOLOCK) VEN  ON (VEN.A3_COD=CAD.PB3_CODVEN) AND (VEN.D_E_L_E_T_ = '') " 
	
	cQuery += " WHERE  " 
	cQuery += " CAD.D_E_L_E_T_ = '' " 
	cQuery += " AND LOG.D_E_L_E_T_ = '' " 
	cQuery += " AND PB9_CPOALT LIKE '%Integracao%' " 
	cQuery += " AND YEAR(CAST(PB9_DATA AS DATE)) = YEAR(CAST(GETDATE() AS DATE)) " 
	cQuery += " AND MONTH(CAST(PB9_DATA AS DATE)) = MONTH(CAST(GETDATE() AS DATE)) " 
	
	If nOPc == 1
		
		cQuery += " AND PB9_DATA >= '" + DToS(dData) + "' " 
	
	ElseIf nOPc == 2
	
		cQuery += " AND PB9_DATA = '" + DToS(dData) + "' "
		
	ElseIf nOPc == 3
	
		cQuery += " AND PB9_DATA >= '" + DToS(dData) + "' "
	
	EndIf 
	
	//
	If ! Empty(cUsuario)
		
		cQuery += " AND PB9_USUARI = '" + cUsuario + "' "
		
	EndIf

	cQuery += " GROUP BY CONVERT(varchar, PB9_DATA, 112),PB9_USUARI,PB9_CPODEP,PB3_CODSA1,PB3_LOJSA1,PB3_NOME"
	
	//
	RestArea(aArea)	
	
Return cQuery
/*{Protheus.doc} Static Function carrRep
	Carrega de registros reprovados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function carrRep(dData,oPB9PnlAp,oRegRp)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aAnalista	:= {}
	Local nPosAn	:= 0
	Local aAltCdRp  := {}
	Local aColsCdRp := {}
	Local aDados	:= {}
	Local i			:= 0
	Local aDatas	:= {}
	Local nTotReg	:= 0
	Local nTotGer	:= 0
	
	//
	If ValType(oRegRp) == "O"
		FreeObj(oRegRp:oBrowse)
		FreeObj(oRegRp)
		
	EndIf
	
	//
	If ValType(oCSVRp) == "O"
		FreeObj(oCSVRp)
		
	EndIf

	//
	cQuery += " SELECT "
	cQuery += " FONTE.DT_ENVIO, FONTE.PB9_USUARI, COUNT(*) AS TT "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += sqlReprov(dData,1)
	
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY "
	cQuery += " FONTE.DT_ENVIO, "
	cQuery += " FONTE.PB9_USUARI "
	cQuery += " ORDER BY "
	cQuery += " FONTE.DT_ENVIO, "
	cQuery += " FONTE.PB9_USUARI "
	
	//
	If Select("D_REPROV") > 0
		D_REPROV->(DbCloseArea())
		
	EndIf
	
	aHCdRp := {}
	Aadd(aHCdRp,{"Data","DATA" ,"",08,  0,"","" ,"D","",""})
	
	//
	TcQuery cQuery New Alias "D_REPROV"

	D_REPROV->(DbGoTop())
	
	//
	While ! D_REPROV->(Eof())
		
		//
		If aScan(aHCdRp,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_REPROV->PB9_USUARI)) }) == 0
			
			Aadd(aHCdRp,{Alltrim(cValToChar(D_REPROV->PB9_USUARI)),Alltrim(cValToChar(D_REPROV->PB9_USUARI)),"@E 999,999,999" ,11, 0,"","" ,"N","",""})
		
		EndIf
		
		//
		nPosAn := aScan(aAnalista,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_REPROV->PB9_USUARI)) })
		If nPosAn == 0
			
			Aadd(aAnalista,{Alltrim(cValToChar(D_REPROV->PB9_USUARI)),Val(cValToChar(D_REPROV->TT))})
			
		Else
			
			aAnalista[nPosAn][2] += Val(cValToChar(D_REPROV->TT))
		
		EndIf		
		
		//
		nPosAn := aScan(aDatas,{|x| Alltrim(cValToChar(x[1])) ==  Alltrim(cValToChar(D_REPROV->DT_ENVIO)) })
		If nPosAn == 0
			
			Aadd(aDatas,{Alltrim(cValToChar(D_REPROV->DT_ENVIO)),Val(cValToChar(D_REPROV->TT))})
			
		Else
			
			aDatas[nPosAn][2] += Val(cValToChar(D_REPROV->TT))
			
		EndIf
		
		//
		Aadd(aDados,{Alltrim(cValToChar(D_REPROV->DT_ENVIO)),Alltrim(cValToChar(D_REPROV->PB9_USUARI)),Val(cValToChar(D_REPROV->TT))})
		
		nTotGer += Val(cValToChar(D_REPROV->TT))
		
		D_REPROV->(DbSkip())
		
	EndDo
	
	//
	Aadd(aDatas,{"Total",nTotGer})
	
	//
	Aadd(aHCdRp,{"Total" ,"TOTAL" ,"@E 999,999,999" ,11, 0,"","" ,"N","",""})
	
	//
	oRegRp := MsNewGetDados():New(020,270,210,530,,"Allwaystrue()","Allwaystrue()","",aAltCdRp,1,999,Nil,Nil,Nil,oPB9PnlAp,aHCdRp,@aColsCdRp)
	oRegRp:oBrowse:bLDblClick := {|| detRep(oRegRp,aHCdRp,dData) }
	
	If Len(aDatas) > 0
		oRegRp:aCols := {}
		
	EndIf
	
	For i := 1 To Len(aDatas)
		
		Aadd(oRegRp:aCols , Array(Len(aHCdRp) + 1) )
		oRegRp:aCols[Len(oRegRp:aCols), Len(oRegRp:aCols[1]) ] := .F.
	
		oRegRp:aCols[Len(oRegRp:aCols),Ascan(aHCdRp,{|x| AllTrim(x[2]) == "DATA" })] := Iif(cValToChar(aDatas[i][1]) == "Total",cValToChar(aDatas[i][1]),DToC(SToD(aDatas[i][1])))
		
		oRegRp:aCols[Len(oRegRp:aCols),Ascan(aHCdRp,{|x| AllTrim(x[2]) == "TOTAL"})] := Val(cValToChar(aDatas[i][2]))
		
	Next i
	
	//
	For i := 1 To Len(oRegRp:aCols)
		
		For w := 1 To Len(aHCdRp)
		
			For y := 1 To Len(aDados)
			
				If cValToChar(oRegRp:aCols[i,Ascan(aHCdRp,{|x| AllTrim(x[2]) == "DATA" })]) == Iif(cValToChar(aDados[y][1]) == "Total",cValToChar(aDados[y][1]),DToC(SToD(aDados[y][1]))) .And.;
				   Alltrim(cValToChar(aHCdRp[w][2])) == Alltrim(cValToChar(aDados[y][2]))
					
					oRegRp:aCols[i,Ascan(aHCdRp,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aDados[y][2])) })] := Val(cValToChar(aDados[y][3]))
					
				EndIf
			
			Next y
		
		Next w
	
	Next i
	
	//
	If nTotGer > 0
			
		For w := 1  To Len(aHCdRp)
			
			For y := 1 To Len(aAnalista)
			
				If Alltrim(cValToChar(aAnalista[y][1])) == Alltrim(cValToChar(aHCdRp[w][2]))
				
					oRegRp:aCols[Len(oRegRp:aCols),Ascan(aHCdRp,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aHCdRp[w][2]))})] := Val(cValToChar(aAnalista[y][2]))
				
				EndIf
			
			Next y
			
		Next w
	
	EndIf
	
	//
	oCSVRp := TButton():New(215,489,"CSV" ,oPB9PnlAp, {|| MsAguarde({||;
																			grLRCCSV(oRegRp,aHCdRp,"CAD_REPROV_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV");
																			},"Aguarde","Exportando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//
	oRegRp:Refresh()
	
	//
	RestArea(aArea)	
	
Return Nil
/*{Protheus.doc} Static Function sqlReprov
	Retorna script de registros reprovados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function sqlReprov(dData,nOPc,cUsuario)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cAFin		:= Alltrim(cValToChar(GetMv("MV_#URJCAD")))
	Local aAFin		:= {}
	Local i			:= 1
	
	//
	cUsuario := Alltrim(cValToChar(cUsuario))
	aAFin := StrToKarr(cAFin,"/")
	cAFin := ""
	For i := 1 To Len(aAFin)
		
		cAFin += "'" + Alltrim(cValToChar(aAFin[i])) + "',"
		
	Next i
	cAFin := Substr(cAFin,1,Len(cAFin) - 1)
		
	cQuery := ""
	
	If nOPc == 9 //053928 || OS 055314 || FINANCAS || LIGIA || 8479 || REL. PENDENCIAS
		cQuery += " SELECT CONVERT(varchar, PB9_DATA, 112) AS DT_ENVIO,PB9_USUARI,PB9_CODIGO,PB9_CPODEP,PB3_CODSA1,PB3_LOJSA1,PB3_NOME,PB3_MOTREJ" // CHAMADO 049048 WILLIAM COSTA - 14/11/2019 - ADICIONADO CAMPO PB3_MOTREJ
	Else
		cQuery += " SELECT CONVERT(varchar, PB9_DATA, 112) AS DT_ENVIO,PB9_USUARI,PB9_CPODEP,PB3_CODSA1,PB3_LOJSA1,PB3_NOME,PB3_MOTREJ" // CHAMADO 049048 WILLIAM COSTA - 14/11/2019 - ADICIONADO CAMPO PB3_MOTREJ
	EndIf
	
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("PB9") + " (NOLOCK) LOG " 
	cQuery += " INNER JOIN " + RetSqlName("PB3") + " (NOLOCK) CAD  ON (CAD.PB3_COD = LOG.PB9_CODIGO) AND (CAD.PB3_LOJA = LOG.PB9_LOJA) " 
	cQuery += " LEFT  JOIN " + RetSqlName("PB2") + " (NOLOCK) FUNC ON (CAD.PB3_VENENC=FUNC.PB2_CODIGO) AND (FUNC.D_E_L_E_T_ = '') " 
	cQuery += " LEFT  JOIN " + RetSqlName("SA3") + " (NOLOCK) VEN  ON (VEN.A3_COD=CAD.PB3_CODVEN) AND (VEN.D_E_L_E_T_ = '') " 
	
	cQuery += " WHERE  " 
	cQuery += " LOG.D_E_L_E_T_ = '' "
	
	//If nOPc == 1
	If nOPc == 1 .OR. nOPc == 9  //053928 || OS 055314 || FINANCAS || LIGIA || 8479 || REL. PENDENCIAS
		
		cQuery += " AND PB9_DATA >= '" + DToS(dData) + "' " 
	
	ElseIf nOPc == 2
	
		cQuery += " AND PB9_DATA = '" + DToS(dData) + "' "
		
	ElseIf nOPc == 3
	
		cQuery += " AND PB9_DATA >= '" + DToS(dData) + "' "
	
	EndIf 
	
	//
	If ! Empty(cUsuario)
		
		cQuery += " AND PB9_USUARI = '" + cUsuario + "' "
		
	EndIf
	
	cQuery += " AND LOG.PB9_CPOALT = 'Situacao'  " 
	cQuery += " AND LOG.PB9_CPODEP = 'Rejeitado' " 
	cQuery += " AND YEAR(CAST(PB9_DATA AS DATE)) = YEAR(CAST(GETDATE() AS DATE))  " 
	cQuery += " AND MONTH(CAST(PB9_DATA AS DATE)) = MONTH(CAST(GETDATE() AS DATE)) " 
    cQuery += "	AND PB3_MOTREJ <> '' "
	
	If ! Empty(cAFin)
		cQuery += " AND PB9_USUARI IN (" + cAFin + ") "
	
	EndIf
	
	If nOPc == 9  //053928 || OS 055314 || FINANCAS || LIGIA || 8479 || REL. PENDENCIAS
		cQuery += " GROUP BY CONVERT(varchar, PB9_DATA, 112),PB9_USUARI,PB9_CODIGO,PB9_CPODEP,PB3_CODSA1,PB3_LOJSA1,PB3_NOME,PB3_MOTREJ "
	Else
		cQuery += " GROUP BY CONVERT(varchar, PB9_DATA, 112),PB9_USUARI,PB9_CPODEP,PB3_CODSA1,PB3_LOJSA1,PB3_NOME,PB3_MOTREJ "
	EndIF
	
	RestArea(aArea)	
	
Return cQuery
/*{Protheus.doc} Static Function detRep
	Detalhde de registros reprovados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function detRep(oRegRp,aHCdRp,dData)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local oIntRp	:= Nil	
	Local oRegsRep	:= Nil
	Local aAltRgRp	:= {}
	Local aHCddRp	:= {}
	Local aColsRgRp	:= {}
	Local oCSV		:= Nil
	Local cQuery	:= ""
	Local nPosCol	:= oRegRp:oBrowse:ColPos
	Local cColun	:= Alltrim(cValToChar(aHCdRp[nPosCol][2]))
	Local cData		:= Alltrim(cValToChar(oRegRp:aCols[oRegRp:nAt][Ascan(aHCdRp,{|x| AllTrim(x[2]) == "DATA" })]))
	
	dDtQ		:= dData
	
	//
	If cData <> "Total"
		dDtQ := CToD(cData)
		
	EndIf
	
	//
	If cColun == "TOTAL"
		cColun := ""
		
	EndIf
	
	//
	If (Empty(cColun) .And. cData == "Total") .Or. cData == "Total"
		cQuery := sqlReprov(dDtQ,3,cColun)
		
	Else
		cQuery := sqlReprov(dDtQ,2,cColun)
	
	EndIf
	
	cQuery += " ORDER BY DT_ENVIO "
	
	//
	If Select("DET_REP") > 0
		DET_REP->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "DET_REP", .F., .T.)  },"Aguarde","Consultando BD(detalhe reprovado)...")
	DbSelectArea("DET_REP")
	DET_REP->(DbGoTop())
	If DET_REP->(Eof())
		MsgStop("Não há dados a serem exibidos.","Função detRep")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	oIntRp		   := MsDialog():Create()
	oIntRp:cName     := "oIntRp"
	oIntRp:cCaption  := "Registros Reprovados"
	oIntRp:nLeft     := 34
	oIntRp:nTop      := 222
	oIntRp:nWidth    := 1200
	oIntRp:nHeight   := 550
	oIntRp:lShowHint := .F.
	oIntRp:lCentered := .T.

		Aadd(aHCddRp,{"PB9_USUARI","PB9_USUARI" ,"" ,TamSX3("PB9_USUARI")[1],, 0,"","" ,"C","",""})		
		Aadd(aHCddRp,{"PB9_CPODEP","PB9_CPODEP" ,"" ,TamSX3("PB9_CPODEP")[1],, 0,"","" ,"C","",""})		
		Aadd(aHCddRp,{"PB3_CODSA1","PB3_CODSA1" ,"" ,TamSX3("PB3_CODSA1")[1],, 0,"","" ,"C","",""})		
        Aadd(aHCddRp,{"PB3_LOJSA1","PB3_LOJSA1" ,"" ,TamSX3("PB3_LOJSA1")[1],, 0,"","" ,"C","",""})		
		Aadd(aHCddRp,{"PB3_NOME"  ,"PB3_NOME"   ,"" ,TamSX3("PB3_NOME")[1],, 0,"","" ,"C","",""})	
		Aadd(aHCddRp,{"PB3_MOTREJ","PB3_MOTREJ" ,"" ,TamSX3("PB3_MOTREJ")[1],, 0,"","" ,"C","",""})	// CHAMADO 049048 WILLIAM COSTA - 14/11/2019 - ADICIONADO CAMPO PB3_MOTREJ	
		Aadd(aHCddRp,{"PB5_DESCRI","PB5_DESCRI" ,"" ,TamSX3("PB5_DESCRI")[1],, 0,"","" ,"C","",""})	// CHAMADO 049048 WILLIAM COSTA - 14/11/2019 - ADICIONADO CAMPO PB3_MOTREJ	
		
		//
		oRegsRep := MsNewGetDados():New(001,005,234,595,,"Allwaystrue()","Allwaystrue()","",aAltRgRp,1,999,Nil,Nil,Nil,oIntRp,aHCddRp,@aColsRgRp)
		oRegsRep:aCols := {}
		
		While ! DET_REP->(Eof())
		
			Aadd(oRegsRep:aCols , Array(Len(aHCddRp) + 1) )
			oRegsRep:aCols[Len(oRegsRep:aCols), Len(oRegsRep:aCols[1]) ] := .F.

			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB9_USUARI" })] := DET_REP->PB9_USUARI
			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB9_CPODEP" })] := DET_REP->PB9_CPODEP
			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB3_CODSA1" })] := DET_REP->PB3_CODSA1
			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB3_LOJSA1" })] := DET_REP->PB3_LOJSA1
			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB3_NOME"   })] := DET_REP->PB3_NOME
			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB3_MOTREJ" })] := DET_REP->PB3_MOTREJ // CHAMADO 049048 WILLIAM COSTA - 14/11/2019 - ADICIONADO CAMPO PB3_MOTREJ
			oRegsRep:aCols[Len(oRegsRep:aCols),Ascan(aHCddRp,{|x| AllTrim(x[2]) == "PB5_DESCRI" })] := ALLTRIM(POSICIONE("PB5",1,xFilial("PB5")+DET_REP->PB3_MOTREJ,"PB5_DESCRI")) // CHAMADO 049048 WILLIAM COSTA - 14/11/2019 - ADICIONADO CAMPO PB3_MOTREJ
			
			DET_REP->(DbSkip())
			
		EndDo
		
		//
		oRegsRep:Refresh()
		
		oCSV := TButton():New(245,505,"CSV",oIntRp,{|| grLRCCSV(oRegsRep,aHCddRp,"CAD_DET_REPROV_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oFechar	 := TButton():New(245,550,"Fechar",oIntRp,{|| oIntRp:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oIntRp:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)	
	
Return Nil
/*{Protheus.doc} Static Function grLRCCSV
	Gera aquivo CSV para objeto msnewgetdados.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function grLRCCSV(oRegistros,aHReg,cArq)

	//Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	
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
/*{Protheus.doc} Static Function logAcesso
	Log de acesso de rotina.
	@type  Function
	@author Everson
	@since 22/06/2017
	@version 01	
*/
Static Function logAcesso(cRotina)

	Local aArea		:= GetArea()
	
	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL := xFilial("SE1")
		ZBE->ZBE_DATA	:= Date()
		ZBE->ZBE_HORA	:= cValToChar(Time())
		ZBE->ZBE_USUARI	:= cUserName
		ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
		ZBE->ZBE_MODULO	:= "FINANCEIRO"
		ZBE->ZBE_ROTINA	:= "ADFIN036P"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil

Static Function ConsultaRej(lAut,nOpc)

	Local aArea		:= GetArea()
	Local cRel		:= ""
	Local cEmail	:= Alltrim(cValToChar(GetMv("MV_#CONREJ")))
	Local cMsg		:= "Deseja enviar o relatório Consulta Rejeitados?"
	
	If ! lAut
		
		If ! MsgYesNo(cMsg,"Função gerRelatorio")
			RestArea(aArea)	
			Return Nil
			
		EndIf
		
	EndIf
	
	//
	If Empty(cEmail)
	
		If ! lAut
			MsgInfo("Não há e-mail cadastrado.","Função ConsultaRej")
		
		EndIf	
		
		RestArea(aArea)	
		Return Nil
		
	EndIf
	
	//Gera relatório.
	cRel := HtmlConsRej(nOpc)
	
	//Envia o relatório.
	enviarEmail("Relatório - Consolidação de Rejeitados",cRel,cEmail,"")
	
	If ! lAut
		MsgInfo("Relatório enviado.","Função ConsultaRej")
	
	EndIf
	
	//
	RestArea(aArea)	
	
Return Nil
/*{Protheus.doc} Static Function HtmlConsRej
	Template html
	@type  Function
	@author Everson
	@since 23/06/2017
	@version 01	
*/
Static Function HtmlConsRej(nOPc)

	Local aArea		:= GetArea()
	Local cRet		:= ""
	
	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>Consolidação de Rejeitados............: " + DTOC(DATE()) + ' '+ TIME() + " </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	cRet += " Motivos de Rejeição"
	cRet += "<br>"
	cRet += "<br>" 
	   
	    cRet += "<table border='1'>" 
	    
	    cRet += "<tr>"
		cRet += "<td>Cod&nbsp;Rejeito</td>"
		cRet += "<td>Descrição</td>"
		cRet += "<td>Quantidade</td>"
		cRet += "</tr>"
		
		SqlConRejeitos()
		While TRB->(!EOF())  
		
			cRet += "<tr>"
			cRet += "<td>" + TRB->PB3_MOTREJ      + "</td>"
			cRet += "<td>" + TRB->PB5_DESCRI      + "</td>"
			cRet += "<td>" + CVALTOCHAR(TRB->QTD) + "</td>"
			cRet += "</tr>"
			
	        TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())  
		
	   	cRet += "</table>"   
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
	
	//
	RestArea(aArea)	
	
Return(cRet)

Static Function SqlConRejeitos()

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT PB3_MOTREJ,PB5_DESCRI,COUNT(PB3_MOTREJ) AS QTD
			  FROM %Table:PB3% WITH (NOLOCK)
		 LEFT JOIN %Table:PB5% WITH (NOLOCK)
		    	ON PB5_CODIGO = PB3_MOTREJ
			 WHERE PB3_MOTREJ <> ''
		  GROUP BY PB3_MOTREJ,PB5_DESCRI
		  ORDER BY PB3_MOTREJ
			  
	EndSQl             
RETURN(NIL)
