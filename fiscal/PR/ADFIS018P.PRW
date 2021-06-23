#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS018P บAutor  ณEverson             บ Data ณ30/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Indicador de devolu็ใo de venda.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADFIS018P() // U_ADFIS018P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local oDlg  
	
	Local oRegistros
	Local aAltReg	:= {}
	Local aHReg		:= {}
	Local aColsReg	:= {}
	
	Local oScroll
	Local oPnl 
	Local oChart   
	Local oGroup1
	
	Local bMudaAba	:= {|| oScroll:lVisibleControl    := (oTTabs:nOption == 1);
					   }
					   
	Local nBusca	:= 0
	Local cBusca 	:= Space(200)
	Local oBtnBusca
					  
	Local oCSV
	Local oFechar
	
	Private dDtDe := Date()
	Private dDtAt := Date()
	
	Private oGraph
	
	Private cGrvChart1	:= "C:\TEMP\chart1" + cUserName + ".png"
	Private cGrvChart2	:= "C:\TEMP\chart2" + cUserName + ".png"
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Indicador de devolu็ใo de venda.')
	
	//
	logAcesso("INDICADOR DE DEVOLUCAO DE VENDA")
	
	//
    FErase(cGrvChart1) 
    FErase(cGrvChart2)
	
	//
	oDlg		   := MsDialog():Create()
	oDlg:cName     := "oDlg"
	oDlg:cCaption  := "Indicador de Devolu็ใo de Venda"
	oDlg:nLeft     := 34
	oDlg:nTop      := 222
	oDlg:nWidth    := 1200
	oDlg:nHeight   := 560
	oDlg:lShowHint := .F.
	oDlg:lCentered := .T.
	
		//
		aTab   := {'Anแlise'}
		oTTabs := TTabs():New(001,005,aTab,Nil,oDlg,Nil,CLR_HRED,Nil,.T.,Nil,590,245,Nil)
		oTTabs:SetOption(1)
	
		//
		Aadd(aHReg,{"Mot. Dev.","MOTDEV" ,"",20, 0,"","" ,"C","",""})
		Aadd(aHReg,{"Vlr (R$)" ,"VLRDEV" ,"@E 999,999,999.99",15, 2,"","" ,"N","",""})
		Aadd(aHReg,{"Qtd"      ,"QTDDEV" ,"@E 999,999",07, 0,"","" ,"N","",""})
		
		//
		
		oDtDe   := TGet():New(002,005,{|u|If(PCount() == 0,dDtDe,dDtDe := u)},oTTabs,030,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtDe",,,,.T.,,,"Data De:",1) 
		oDtAt   := TGet():New(002,050,{|u|If(PCount() == 0,dDtAt,dDtAt := u)},oTTabs,030,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDtAt",,,,.T.,,,"Data At้:",1) 
		oAtlBtn := TButton():New(009,090,"Atualizar",oTTabs,,30,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		oAtlBtn:bAction := {|| MsAguarde({|| carrGrid(@oRegistros,@aHReg,@oPnl,1)},"Aguarde","Carregando dados...") }
		
		//
		oBusca   := TGet():New(025,005,{|u|If(PCount() == 0,cBusca,cBusca := u)},oTTabs,100,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"Motivo:",1) 
		oBtnBusca:= TButton():New(032,105,"Ok",oTTabs,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnBusca:bAction := {|| nBusca := Ascan(oRegistros:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[1])}),;
								Iif(nBusca > 0,Eval({||oRegistros:ForceRefresh(),oRegistros:GoTo(nBusca),oRegistros:Refresh()}),;
								MsgAlert("Nใo foi possํvel localizar o registro","Fun็ใo ADFIS018P"))}
		
		//						
		oGrfVlr:= TButton():New(032,137,"G-R$",oTTabs,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		oGrfVlr:bAction := {|| MsAguarde({|| carrGrid(@oRegistros,@aHReg,@oPnl,1) },"Aguarde","Carregando dados...") }
		oGrfVlr:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #3232CD, stop: 1 #23238E);color: white}")
		
		//
		oGrfQtd:= TButton():New(032,159,"G-Qtd",oTTabs,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		oGrfQtd:bAction := {|| MsAguarde({|| carrGrid(@oRegistros,@aHReg,@oPnl,2) },"Aguarde","Carregando dados...") }
		oGrfQtd:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #3232CD, stop: 1 #23238E);color: white}")
		
		//
		oRegistros := MsNewGetDados():New(050,005,235,180,,"Allwaystrue()","Allwaystrue()","",aAltReg,1,999,Nil,Nil,Nil,oTTabs,aHReg,@aColsReg)
		oRegistros:oBrowse:bLDblClick := {|| obterDetalhe(oRegistros,aHReg) }
	
		oScroll := TScrollArea():New(oTTabs,005,185,230,400)
		oPnl := TPanel():New(020,000,"",oScroll,,.T.,,CLR_BLACK,CLR_WHITE,500,200)
		
		oScroll:SetFrame(oPnl)
		
		//
		oGroup1  := TGroup():Create(oDlg,250,001,265,595,"",,,.T.)
	
		//
		oCSV	 := TButton():New(253,006,"CSV",oDlg,{|| grLRCCSV(oRegistros,aHReg,"inddevvd_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oBase	 := TButton():New(253,051,"Base",oDlg,{|| MsAguarde({|| obterBase(oRegistros,aHReg) },"Aguarde","Carregando dados...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oRela	 := TButton():New(253,096,"Relat๓rio",oDlg,{|| MsAguarde({|| gerRel(@oRegistros,@aHReg,@oPnl) },"Aguarde","Gerando relat๓rio...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oFechar	 := TButton():New(253,550,"Fechar",oDlg,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
		
		//
		Eval(bMudaAba)
		
	oDlg:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| carrGrid(@oRegistros,@aHReg,@oPnl,1) },"Aguarde","Carregando dados...") })
	
	//
    FErase(cGrvChart1) 
    FErase(cGrvChart2)
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobterBase   บAutor  ณEverson         บ Data ณ  03/07/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obt้m os registros dentro do range de datas.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function gerRel(oRegistros,aHReg,oPnl)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	Local cGrvChart	:= ""
	Local i			:= 1
	Local nColuna	:= 2300
	Local nLinhas	:= 200
	Local nQtdLinha := 0
	Local oFont1 	:= TFont():New('Courier new',,-18,.T.)
	Local oFont2 	:= TFont():New('Courier new',,-10,.T.)
	Local oFont3 	:= TFont():New('Courier new',,-13,.T.)
	
	//
	oFont1:Bold := .T.
	oFont3:Bold := .T.
	
	//
	FErase(cGrvChart1)
	carrGrid(@oRegistros,@aHReg,@oPnl,1)
	oGraph:saveToPng(000,000,985,400,cGrvChart1)
	
	//
	FErase(cGrvChart2)
	carrGrid(@oRegistros,@aHReg,@oPnl,2)
	oGraph:saveToPng(000,000,985,400,cGrvChart2)	

    // Monta objeto para impressใo
    oPrint := TMSPrinter():New("Indicador de Devolu็ใo de Venda")

    // Define orienta็ใo da pแgina para Retrato
    oPrint:SetLandscape()

    // Inicia pแgina
    oPrint:StartPage() 
    
    //
    oPrint:Say(100,50,"Relat๓rio - Indicador de Devolu็ใo de Venda - ( de " + DToC(dDtDe) + " at้ " + DToC(dDtAt) + " )" ,oFont1)  
    oPrint:Say(175,50,"Emitido por " + cUserName + " em " + DToC(Date()) + " - " + cValToChar(Time()) ,oFont2)          
    
    // Insere imagem
    oPrint:SayBitmap(350,10,cGrvChart1,2200,1000,,.T.)
    
    // Insere imagem
    oPrint:SayBitmap(1400,10,cGrvChart2,2200,1000,,.T.)

    //
    oPrint:Say(nLinhas,2300,Alltrim(cValToChar(aHReg[1][1])),oFont3)
    oPrint:Say(nLinhas,3000,Alltrim(cValToChar(aHReg[2][1])),oFont3,,,,1)
    oPrint:Say(nLinhas,3300,Alltrim(cValToChar(aHReg[3][1])),oFont3,,,,1)
    
    //
    nLinhas += 100
        
    //
    For i := 1 To Len(oRegistros:aCols)
    	
    	nQtdLinha++
    	
    	oPrint:Say(nLinhas,2300,Alltrim(cValToChar(oRegistros:aCols[i][1])),oFont2)
    	oPrint:Say(nLinhas,3000,Alltrim(Transform(oRegistros:aCols[i][2],"@E 999,999,999.99")),oFont2)
    	oPrint:Say(nLinhas,3300,Alltrim(Transform(oRegistros:aCols[i][3],"@E 999,999,999")),oFont2)
    	
    	nLinhas += 50
    	
    	If nQtdLinha >= 42
    	
		    // Termina a pแgina
		    oPrint:EndPage()
		    
		    // Inicia pแgina
		    oPrint:StartPage()
		    
		    //
		    oPrint:Say(100,50,"Relat๓rio - Indicador de Devolu็ใo de Venda - ( de " + DToC(dDtDe) + " at้ " + DToC(dDtAt) + " )" ,oFont1)  
		    oPrint:Say(175,50,"Emitido por " + cUserName + " em " + DToC(Date()) + " - " + cValToChar(Time()) ,oFont2) 
		    
		    //
		    nLinhas := 200
		    
		    //
		    oPrint:Say(nLinhas,2300,Alltrim(cValToChar(aHReg[1][1])),oFont3)
		    oPrint:Say(nLinhas,3000,Alltrim(cValToChar(aHReg[2][1])),oFont3,,,,1)
		    oPrint:Say(nLinhas,3300,Alltrim(cValToChar(aHReg[3][1])),oFont3,,,,1)
		    
		    //
		    nLinhas += 100
		    
		    nQtdLinha := 0
    	
    	EndIf
    
    Next i
    
    // Termina a pแgina
    oPrint:EndPage()
                       
    // Mostra tela de visualiza็ใo de impressใo
    oPrint:Preview() 
    
    //
    FErase(cGrvChart1) 
    FErase(cGrvChart2)
    
    MS_Flush() 
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaddJQuery         บ Autor ณ Everson   บ Data ณ  03/07/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณadiciona jquery.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 036020.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function addJQuery(nHandle)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	Local cJquery	:= "\\10.5.1.1\Totvs\Protheus11\Protheus_Data\rel_fin\jquery\jquery.txt.txt"
	Local cBuffer	:= ""
	
	//
	If ! File(cJquery)
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	nHdl := FT_FUse(cJquery)
	
	//Valida abertura do arquivo.
	If nHdl == -1
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	FT_FGoTop()
	
	cBuffer := "<script type='text/javascript'>" 
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	//Percorre arquivo.
	While !FT_FEof()
		
		cBuffer := FT_FReadln()
		
		FWrite(nHandle,cBuffer)
		
		FT_FSkip()
		
	EndDo
	cBuffer := ""
	cBuffer += " </script> "
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	
	//
	RestArea(aArea)	

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaddChart          บ Autor ณ Everson   บ Data ณ  30/06/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณadiciona Chart.js.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 036020.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function addChart(nHandle)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	Local cChart	:= "\\10.5.1.1\Totvs\Protheus11\Protheus_Data\rel_fin\chart\chart.txt"
	Local cBuffer	:= ""
	
	//
	If ! File(cChart)
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	nHdl := FT_FUse(cChart)
	
	//Valida abertura do arquivo.
	If nHdl == -1
		RestArea(aArea)
		Return .F.
		
	Endif
	
	//
	FT_FGoTop()
	
	cBuffer := "<script type='text/javascript'>" 
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	//Percorre arquivo.
	While !FT_FEof()
		
		cBuffer := FT_FReadln()
		
		FWrite(nHandle,cBuffer)
		
		FT_FSkip()
		
	EndDo
	cBuffer := ""
	cBuffer += " </script> "
	FWrite(nHandle,cBuffer) 
	cBuffer := ""
	
	//
	RestArea(aArea)	

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobterBase   บAutor  ณEverson         บ Data ณ  30/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obt้m os registros dentro do range de datas.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obterBase(oRegistros,aHReg)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local oDltDt
	Local oRegDt
	Local oGroup1
	Local oFechar
	
	Local aAltRegDt	:= {}
	Local aHRegDt	:= {}
	Local aColsRegDt:= {}
	
	Local nLinha	:= oRegistros:nAt
	Local cColuna	:= aScan(aHReg,{|x| Alltrim(cValToChar(x[2])) == "MOTDEV" })
	Local cMotivo	:= Alltrim(cValToChar(oRegistros:aCols[nLinha][cColuna]))
	
	Local cQuery	:= ""
	
	//
	cQuery := scriptSql(dDtDe,dDtAt,"")
	cQuery += " ORDER BY ZD_DESCMOT, D1_DOC, D1_SERIE "
	
	//
	If Select("D_DEVDET") > 0
		D_DEVDET->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "D_DEVDET", .F., .T.)  },"Aguarde","Obtendo dados...")
	DbSelectArea("D_DEVDET")
	D_DEVDET->(DbGoTop())
	If D_DEVDET->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	oDltDt		   := MsDialog():Create()
	oDltDt:cName     := "oDltDt"
	oDltDt:cCaption  := "Base"
	oDltDt:nLeft     := 34
	oDltDt:nTop      := 222
	oDltDt:nWidth    := 1200
	oDltDt:nHeight   := 560
	oDltDt:lShowHint := .F.
	oDltDt:lCentered := .T.

		//
		Aadd(aHRegDt,{"D1_FILIAL" ,"D1_FILIAL"  ,"",TamSX3("D1_FILIAL")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_DTDIGIT","D1_DTDIGIT" ,"",10, 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_EMISSAO","D1_EMISSAO" ,"",10, 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_DOC"    ,"D1_DOC"     ,"",TamSX3("D1_DOC")[1]  , 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_SERIE"  ,"D1_SERIE"   ,"",TamSX3("D1_SERIE")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_NFORI"  ,"D1_NFORI"   ,"",TamSX3("D1_NFORI")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_SERIORI","D1_SERIORI" ,"",TamSX3("D1_SERIORI")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_TOTAL"  ,"D1_TOTAL"   ,"@E 999,999,999.99",15, 2,"","" ,"N","",""})
		Aadd(aHRegDt,{"D1_CF"     ,"D1_CF"      ,"",TamSX3("D1_CF")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_ICMSRET","D1_ICMSRET" ,"",TamSX3("D1_ICMSRET")[1], TamSX3("D1_ICMSRET")[2],"","" ,"C","",""})
		Aadd(aHRegDt,{"TOTAL"     ,"TOTAL"      ,"@E 999,999,999.99",15, 2,"","" ,"C","",""})
		Aadd(aHRegDt,{"ZD_DESCMOT","ZD_DESCMOT" ,"",TamSX3("ZD_DESCMOT")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"ZD_DTDEV"  ,"ZD_DTDEV"   ,"",10, 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"ZD_FILIAL" ,"ZD_FILIAL"  ,"",TamSX3("ZD_FILIAL")[1], 2,"","" ,"C","",""})
		
		//
		oRegDt := MsNewGetDados():New(001,001,235,595,,"Allwaystrue()","Allwaystrue()","",aAltRegDt,1,999,Nil,Nil,Nil,oDltDt,aHRegDt,@aColsRegDt)
		oRegDt:aCols := {}
		
		//
		While ! D_DEVDET->(Eof())
		
			Aadd(oRegDt:aCols , Array(Len(aHRegDt) + 1) )
			oRegDt:aCols[Len(oRegDt:aCols), Len(oRegDt:aCols[1]) ] := .F.
			
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_FILIAL"   })] := Alltrim(cValToChar(D_DEVDET->D1_FILIAL))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DTDIGIT"  })] := DToC(SToD(cValToChar(D_DEVDET->D1_DTDIGIT)))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_EMISSAO"  })] := DToC(SToD(cValToChar(D_DEVDET->D1_EMISSAO)))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DOC"      })] := Alltrim(cValToChar(D_DEVDET->D1_DOC))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIE"    })] := Alltrim(cValToChar(D_DEVDET->D1_SERIE))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_NFORI"    })] := Alltrim(cValToChar(D_DEVDET->D1_NFORI))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIORI"  })] := Alltrim(cValToChar(D_DEVDET->D1_SERIORI))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_TOTAL"    })] := Val(cValToChar(D_DEVDET->D1_TOTAL))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_CF"       })] := Alltrim(cValToChar(D_DEVDET->D1_CF))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_ICMSRET"  })] := Val(cValToChar(D_DEVDET->D1_ICMSRET))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "TOTAL"       })] := Val(cValToChar(D_DEVDET->TOTCIMP))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DESCMOT"  })] := Alltrim(cValToChar(D_DEVDET->ZD_DESCMOT))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DTDEV"    })] := DToC(SToD(cValToChar(D_DEVDET->ZD_DTDEV)))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_FILIAL"   })] := Alltrim(cValToChar(D_DEVDET->ZD_FILIAL))
			
			D_DEVDET->(DbSkip())
			
		EndDo
		
		//
		If Len(oRegDt:aCols) == 0
			
			Aadd(oRegDt:aCols , Array(Len(aHRegDt) + 1) )
			oRegDt:aCols[Len(oRegDt:aCols), Len(oRegDt:aCols[1]) ] := .F.
			
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_FILIAL"   })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DTDIGIT"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_EMISSAO"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DOC"      })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIE"    })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_NFORI"    })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIORI"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_TOTAL"    })] := 0
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_CF"       })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_ICMSRET"  })] := 0
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "TOTAL"       })] := 0
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DESCMOT"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DTDEV"    })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_FILIAL"   })] := ""		
			
		
		EndIf
		
		//
		oGroup1  := TGroup():Create(oDltDt,250,001,265,595,"",,,.T.)
		
		oCSV	 := TButton():New(253,006,"CSV",oDltDt,{|| grLRCCSV(oRegDt,aHRegDt,"det_inddevvd_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar	 := TButton():New(253,550,"Fechar",oDltDt,{|| oDltDt:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oDltDt:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| },"Aguarde","Carregando dados...") })

	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobterDetalhe   บAutor  ณEverson      บ Data ณ  30/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obt้m detalhes dos motivos.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obterDetalhe(oRegistros,aHReg)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local oDltDt
	Local oRegDt
	Local oGroup1
	Local oFechar
	
	Local aAltRegDt	:= {}
	Local aHRegDt	:= {}
	Local aColsRegDt:= {}
	
	Local nLinha	:= oRegistros:nAt
	Local cColuna	:= aScan(aHReg,{|x| Alltrim(cValToChar(x[2])) == "MOTDEV" })
	Local cMotivo	:= Alltrim(cValToChar(oRegistros:aCols[nLinha][cColuna]))
	
	Local cQuery	:= ""
	
	//
	cQuery := scriptSql(dDtDe,dDtAt,cMotivo)
	cQuery += " ORDER BY ZD_DESCMOT, D1_DOC, D1_SERIE "
	
	//
	If Select("D_DEVDET") > 0
		D_DEVDET->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "D_DEVDET", .F., .T.)  },"Aguarde","Obtendo dados...")
	DbSelectArea("D_DEVDET")
	D_DEVDET->(DbGoTop())
	If D_DEVDET->(Eof())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	oDltDt		   := MsDialog():Create()
	oDltDt:cName     := "oDltDt"
	oDltDt:cCaption  := "Indicador de Devolu็ใo de Venda - Detalhes"
	oDltDt:nLeft     := 34
	oDltDt:nTop      := 222
	oDltDt:nWidth    := 1200
	oDltDt:nHeight   := 560
	oDltDt:lShowHint := .F.
	oDltDt:lCentered := .T.

		//
		Aadd(aHRegDt,{"D1_FILIAL" ,"D1_FILIAL"  ,"",TamSX3("D1_FILIAL")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_DTDIGIT","D1_DTDIGIT" ,"",10, 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_EMISSAO","D1_EMISSAO" ,"",10, 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_DOC"    ,"D1_DOC"     ,"",TamSX3("D1_DOC")[1]  , 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_SERIE"  ,"D1_SERIE"   ,"",TamSX3("D1_SERIE")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_NFORI"  ,"D1_NFORI"   ,"",TamSX3("D1_NFORI")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_SERIORI","D1_SERIORI" ,"",TamSX3("D1_SERIORI")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_TOTAL"  ,"D1_TOTAL"   ,"@E 999,999,999.99",15, 2,"","" ,"N","",""})
		Aadd(aHRegDt,{"D1_CF"     ,"D1_CF"      ,"",TamSX3("D1_CF")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"D1_ICMSRET","D1_ICMSRET" ,"",TamSX3("D1_ICMSRET")[1], TamSX3("D1_ICMSRET")[2],"","" ,"C","",""})
		Aadd(aHRegDt,{"TOTAL"     ,"TOTAL"      ,"@E 999,999,999.99",15, 2,"","" ,"C","",""})
		Aadd(aHRegDt,{"ZD_DESCMOT","ZD_DESCMOT" ,"",TamSX3("ZD_DESCMOT")[1], 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"ZD_DTDEV"  ,"ZD_DTDEV"   ,"",10, 0,"","" ,"C","",""})
		Aadd(aHRegDt,{"ZD_FILIAL" ,"ZD_FILIAL"  ,"",TamSX3("ZD_FILIAL")[1], 2,"","" ,"C","",""})
		
		//
		oRegDt := MsNewGetDados():New(001,001,235,595,,"Allwaystrue()","Allwaystrue()","",aAltRegDt,1,999,Nil,Nil,Nil,oDltDt,aHRegDt,@aColsRegDt)
		oRegDt:aCols := {}
		
		//
		While ! D_DEVDET->(Eof())
		
			Aadd(oRegDt:aCols , Array(Len(aHRegDt) + 1) )
			oRegDt:aCols[Len(oRegDt:aCols), Len(oRegDt:aCols[1]) ] := .F.
			
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_FILIAL"   })] := Alltrim(cValToChar(D_DEVDET->D1_FILIAL))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DTDIGIT"  })] := DToC(SToD(cValToChar(D_DEVDET->D1_DTDIGIT)))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_EMISSAO"  })] := DToC(SToD(cValToChar(D_DEVDET->D1_EMISSAO)))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DOC"      })] := Alltrim(cValToChar(D_DEVDET->D1_DOC))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIE"    })] := Alltrim(cValToChar(D_DEVDET->D1_SERIE))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_NFORI"    })] := Alltrim(cValToChar(D_DEVDET->D1_NFORI))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIORI"  })] := Alltrim(cValToChar(D_DEVDET->D1_SERIORI))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_TOTAL"    })] := Val(cValToChar(D_DEVDET->D1_TOTAL))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_CF"       })] := Alltrim(cValToChar(D_DEVDET->D1_CF))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_ICMSRET"  })] := Val(cValToChar(D_DEVDET->D1_ICMSRET))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "TOTAL"       })] := Val(cValToChar(D_DEVDET->TOTCIMP))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DESCMOT"  })] := Alltrim(cValToChar(D_DEVDET->ZD_DESCMOT))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DTDEV"    })] := DToC(SToD(cValToChar(D_DEVDET->ZD_DTDEV)))
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_FILIAL"   })] := Alltrim(cValToChar(D_DEVDET->ZD_FILIAL))
			
			D_DEVDET->(DbSkip())
			
		EndDo
		
		//
		If Len(oRegDt:aCols) == 0
			
			Aadd(oRegDt:aCols , Array(Len(aHRegDt) + 1) )
			oRegDt:aCols[Len(oRegDt:aCols), Len(oRegDt:aCols[1]) ] := .F.
			
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_FILIAL"   })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DTDIGIT"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_EMISSAO"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_DOC"      })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIE"    })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_NFORI"    })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_SERIORI"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_TOTAL"    })] := 0
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_CF"       })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "D1_ICMSRET"  })] := 0
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "TOTAL"       })] := 0
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DESCMOT"  })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_DTDEV"    })] := ""
			oRegDt:aCols[Len(oRegDt:aCols),Ascan(aHRegDt,{|x| AllTrim(x[2]) == "ZD_FILIAL"   })] := ""		
			
		
		EndIf
		
		//
		oGroup1  := TGroup():Create(oDltDt,250,001,265,595,"",,,.T.)
		
		oCSV	 := TButton():New(253,006,"CSV",oDltDt,{|| grLRCCSV(oRegDt,aHRegDt,"det_inddevvd_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar	 := TButton():New(253,550,"Fechar",oDltDt,{|| oDltDt:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	oDltDt:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| },"Aguarde","Carregando dados...") })

	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcarrGrid       บAutor  ณEverson      บ Data ณ  30/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega grid.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function carrGrid(oGrid,aHeader,oPnl,nOrdem)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nTotVlr	:= 0
	Local nTotQtd	:= 0
	
	//
	If ValType(oGraph) == "O"
		FreeObj(oGraph)
		
	EndIf
	
	//
	oGrid:aCols := {}
	oGrid:Refresh()
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " FONTE.ZD_DESCMOT AS MOT, SUM(FONTE.TOTCIMP) AS TOTAL, COUNT(D1_DOC+D1_SERIE) AS QTD "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += scriptSql(dDtDe,dDtAt,"")
	
	cQuery += " ) AS FONTE "
	cQuery += " GROUP BY "
	cQuery += " FONTE.ZD_DESCMOT ORDER BY FONTE.ZD_DESCMOT "
	
	//
	If Select("D_DEV") > 0
		D_DEV->(DbCloseArea())
		
	EndIf

	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "D_DEV", .F., .T.)  },"Aguarde","Obtendo dados...")
	DbSelectArea("D_DEV")
	D_DEV->(DbGoTop())
	
	//
	If ! D_DEV->(Eof())
	
		oGraph := FWChartBar():New()
		oGraph:init(oPnl, .t., .t. )
		oGraph:SetTitle( Iif(nOrdem == 1,"Motivo de Devolu็ใo x Valores","Motivo de Devolu็ใo x Quantidade"), CONTROL_ALIGN_CENTER)
		
		//
		If nOrdem == 1
			oGraph:cPicture := "@E 999,999,999,999,999.99"
		
		Else
			oGraph:cPicture := "@E 999,999,999,999,999"
			
		EndIf
		
	EndIf
	
	//
	While ! D_DEV->(Eof())
		
		Aadd(oGrid:aCols , Array(Len(aHeader) + 1) )
		oGrid:aCols[Len(oGrid:aCols), Len(oGrid:aCols[1]) ] := .F.
		
		oGrid:aCols[Len(oGrid:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "MOTDEV"  })] := Alltrim(cValToChar(D_DEV->MOT))
		oGrid:aCols[Len(oGrid:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "VLRDEV"  })] := Val(cValToChar(D_DEV->TOTAL))
		oGrid:aCols[Len(oGrid:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "QTDDEV"  })] := Val(cValToChar(D_DEV->QTD))
		
		//
		If nOrdem == 1
			oGraph:addSerie(Alltrim(cValToChar(D_DEV->MOT)), Val(cValToChar(D_DEV->TOTAL)))
		
		Else
			oGraph:addSerie(Alltrim(cValToChar(D_DEV->MOT)), Val(cValToChar(D_DEV->QTD)))
			
		EndIf
		
		//
		nTotVlr += Val(cValToChar(D_DEV->TOTAL))
		nTotQtd += Val(cValToChar(D_DEV->QTD))
			
		D_DEV->(DbSkip())
		
	EndDo
	
	//
	If nTotVlr > 0
		
		//
		oGraph:Build()

		//
		Aadd(oGrid:aCols , Array(Len(aHeader) + 1) )
		oGrid:aCols[Len(oGrid:aCols), Len(oGrid:aCols[1]) ] := .F.
		oGrid:aCols[Len(oGrid:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "MOTDEV"  })] := "Total"
		oGrid:aCols[Len(oGrid:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "VLRDEV"  })] := nTotVlr
		oGrid:aCols[Len(oGrid:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "QTDDEV"  })] := nTotQtd
	
	EndIf
	
	//
	oGrid:Refresh()
	
	//
	D_DEV->(DbCloseArea())
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptSql      บAutor  ณEverson      บ Data ณ  30/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Script sql.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptSql(dDtDe,dDtAt,cMotivo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//
	cMotivo := Alltrim(cValToChar(cMotivo))
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " D1_FILIAL,D1_DTDIGIT, D1_EMISSAO, D1_DOC, D1_SERIE, D1_NFORI, D1_SERIORI, D1_TOTAL, 
	cQuery += " D1_CF, D1_ICMSRET, D1_ICMSRET + D1_TOTAL AS TOTCIMP , ZD_DESCMOT, ZD_DTDEV, ZD_FILIAL " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SD1") + " (NOLOCK) AS SD1 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SZD") + " (NOLOCK) AS SZD " 
	cQuery += " ON D1_FILIAL = ZD_FILIAL  " 
	cQuery += " AND D1_NFORI = ZD_NUMNF " 
	cQuery += " AND D1_SERIORI = ZD_SERIE " 
	cQuery += " WHERE  " 
	cQuery += " D1_CF IN ('1201','2201','1410','2410')  " 
	cQuery += " AND D1_DTDIGIT >= '" + DToS(dDtDe) + "'  " 
	cQuery += " AND D1_DTDIGIT <= '" + DToS(dDtAt) + "'  " 
	cQuery += " AND SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND ZD_DTDEV >= '20130101' " 
	cQuery += " AND ZD_DESCMOT NOT IN('SEQUENCIA ENTREGUE','') " 
	cQuery += " AND SZD.D_E_L_E_T_ = '' " 
	
	//
	If ! Empty(cMotivo) .And. cMotivo <> "Todos"
		cQuery += " AND ZD_DESCMOT = '" + cMotivo + "' "
	
	EndIf
	
	//
	RestArea(aArea)

Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrLRCCSV    บAutor  ณEverson         บ Data ณ  30/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera aquivo CSV para objeto msnewgetdados.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 036020.                                            บฑฑ
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
	
	MsgInfo("Arquivo gerado.","Fun็ใo grLRCCSV")
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogAcesso         บ Autor ณ Everson บ Data ณ  03/07/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLog de acesso de rotina.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 036020.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logAcesso(cRotina)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	
	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL := xFilial()
		ZBE->ZBE_DATA	:= Date()
		ZBE->ZBE_HORA	:= cValToChar(Time())
		ZBE->ZBE_USUARI	:= cUserName
		ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
		ZBE->ZBE_MODULO	:= "FISCAL"
		ZBE->ZBE_ROTINA	:= "ADFIS018P"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil