#Include "RwMake.ch"    
#Include "Protheus.ch"
#Include "Topconn.ch"                               
#Include "TbiConn.ch"                                             
#Include "TbiCode.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS014P บ Autor ณ Everson            บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta de pend๊ncias Protheus x SAG.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function  ADFIS014P() // U_ADFIS014P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oButton1
	Local oButton2
	Local oButton3
	Local oSay1
	Static oDlg
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta de pend๊ncias Protheus x SAG.')

	DEFINE MSDIALOG oDlg TITLE "Monitor" FROM 000, 000  TO 250, 195 COLORS 0, 16777215 PIXEL Style 128
	@ 003, 009 SAY oSay1 PROMPT "Monitor Integra็ใo Protheus x SAG" SIZE 085, 008 OF oDlg COLORS 0, 16777215 PIXEL
	
    @ 020, 004 BUTTON oButton1 PROMPT "Entradas" SIZE 092, 026 OF oDlg PIXEL Action(interEntrada())
    @ 065, 004 BUTTON oButton2 PROMPT "Saํdas" SIZE 092, 026 OF oDlg PIXEL Action(interSaida())
    
    @ 100, 052 BUTTON oButton3 PROMPT "Fechar" SIZE 044, 018 OF oDlg PIXEL Action(oDlg:End())
    

    ACTIVATE MSDIALOG oDlg CENTERED
	
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณinterEntrada  บ Autor ณ Everson        บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Interface de entradas.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function interEntrada()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oInterface
	Local aAltInterface	:= {}
	Local aHInterface		:= {}
	Local aColsInterface	:= {}
	Local oSBtn01
	Local oSBtn02
	Local oSBtn03
	Local oSBtn04
	Local oRegistros
	
	//Cria objeto MsDialog.
	oInterface:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Entradas - Processamentos Pendentes Protheus x SAG"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 900
	oInterface:nHeight   := 450
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
	//Cria botใo de confirma็ใo.
	oSBtn01:= SBUTTON():Create(oInterface)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "Legenda"
	oSBtn01:nLeft := 765
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
	oSBtn01:lVisibleControl := .T.
	oSBtn01:bAction := {||lngEntrada()}
	
	//Cria botใo de cancelamento.
	oSBtn02:= SBUTTON():Create(oInterface)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Fechar"
	oSBtn02:nLeft := 833
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 50
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {||oInterface:End()}
	
/*	//Importa็ใo.
	oSBtn04:= SBUTTON():Create(oInterface)
	oSBtn04:cName := "oSBtn04"
	oSBtn04:cCaption := "Imp"
	oSBtn04:nLeft := 080
	oSBtn04:nTop := 390
	oSBtn04:nWidth := 50
	oSBtn04:nHeight := 20
	oSBtn04:lShowHint := .F.
	oSBtn04:lReadOnly := .F.
	oSBtn04:Align := 0
	oSBtn04:lVisibleControl := .T.
	oSBtn04:bAction := {||U_INTNFEB()}*/
	
	//Cria Header.
	Aadd(aHInterface,{" ","LEG"    	  ,"@BMP"    ,01     , 00,.T.,"","","","R","","",.F.,"V","","","",""})
	Aadd(aHInterface,{"DT Emissใo"    ,"DTEMIS"	 ,""	 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"DT Digita็ใo"  ,"DTDIG"	 ,""	 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Opera็ใo"  	  ,"OPER"	 ,""	 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Fornec"        ,"FOR"     ,""	 , 06,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Loja"          ,"LOJ"     ,""	 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Nome"          ,"NOM"     ,""	 , 40,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Num Doc"       ,"DOC"     ,""	 , 09,0,"","" ,"C","",""})
	Aadd(aHInterface,{"S้rie"         ,"SER"     ,""	 , 03,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Form. Prop."   ,"FPR"     ,""	 , 01,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Valor"         ,"VLR"     ,"@E 999,999,999.99"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Erro"          ,"ERR"     ,""	 , 60,0,"","" ,"C","",""})
	
	oRegistros := MsNewGetDados():New(005,004,180,445,,"Allwaystrue()","Allwaystrue()","",aAltInterface,Nil,999,Nil,Nil,Nil,oInterface,aHInterface,@aColsInterface)
	
	//Cria para recarregar dados.
	oSBtn03:= SBUTTON():Create(oInterface)
	oSBtn03:cName := "oSBtn03"
	oSBtn03:cCaption := "Recarr."
	oSBtn03:nLeft := 011
	oSBtn03:nTop := 390
	oSBtn03:nWidth := 80
	oSBtn03:nHeight := 20
	oSBtn03:lShowHint := .F.
	oSBtn03:lReadOnly := .F.
	oSBtn03:Align := 0
	oSBtn03:lVisibleControl := .T.
	oSBtn03:bAction := {||entrCargaDados(oRegistros,aHInterface)}
	
	oInterface:Activate(,,,.T.,{||.T.},,{|| entrCargaDados(oRegistros,aHInterface)})

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlngEntrada        บ Autor ณ Everson       บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Legenda.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lngEntrada()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Local cTitulo := "Legenda"
     Local aLegenda:= {}
     
     Aadd(aLegenda, {"BR_VERMELHO" ,"Entr. por compra"})
     Aadd(aLegenda, {"BR_VERDE"    ,"Entr. por devolu็ใo"})
     Aadd(aLegenda, {"BR_AMARELO"  ,"Entr. trans. empresa" })
     
     Aadd(aLegenda, {"BR_AZUL"     ,"Notas de servi็o"})
     Aadd(aLegenda, {"BR_BRANCO"   ,"Entr. por trans. Integr."    	})
     Aadd(aLegenda, {"BR_PRETO"    ,"Entr. frango vivo apanha" })

     Aadd(aLegenda, {"BR_PINK"     ,"Frango 1 ret. cria็ใo"})
     Aadd(aLegenda, {"BR_LARANJA"  ,"Frango 2 ret. simbol cria็ใo"})
     Aadd(aLegenda, {"BR_VIOLETA"  ,"Frango 4 compra frango vivo"})
     
     BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณentrCargaDados  บ Autor ณ Everson       บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carregar dados.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function entrCargaDados(oRegistros,aHInterface,cOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	//Local nTcConn1	:= advConnection()
	// Local cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// Local cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// Local cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	//Local nTcConn2  := 0
	Local nTotReg	:= 0
	
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
	
	Local oAzul		 := LoadBitmap( GetResources(), "BR_AZUL")
	Local oBranco 	 := LoadBitmap( GetResources(), "BR_BRANCO")
	Local oPreto	 := LoadBitmap( GetResources(), "BR_PRETO")
	
	Local oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA")
	Local oVioleta  := LoadBitmap( GetResources(), "BR_VIOLETA")
	
	Local cNome		:= ""
	Local cOper		:= ""
	Local lChkNf	:= .F.
	
	TcConType("TCPIP")
	
	// If (nTcConn2 := TcLink(cNomBco2,cSrvBco2,cPortBco2)) < 0
	// 	MsgAlert("Nใo foi possํvel  conectar ao banco integra็ใo.","Fun็ใo entrCargaDados")
	// 	Return Nil
		
	// EndIf
	
	////TcSetConn(nTcConn2)
	
	oRegistros:aCols := {}
	
	cQuery := sqlEntrada()
	
	If Select("DADOSINT") > 0
		DADOSINT->(DbCloseArea())
		
	EndIf
	
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DADOSINT", .F., .T.)},"Aguarde","Obtendo dados...")
	
	////TcSetConn(nTcConn1)
	
	DbSelectArea("DADOSINT")
	DADOSINT->(DbGoTop())
	
	nTotReg := Contar("DADOSINT","!EOF()")
	
	If nTotReg <= 0
       
		Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
		oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTDIG"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FOR"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"})]  	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DOC"})]    	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SER"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FPR"})]   	:= ""
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"})]   	:= 0
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"})]   	:= ""
        
    	oRegistros:Refresh()
	
	Else
		
		DADOSINT->(DbGoTop())
		While ! DADOSINT->(Eof())
		
			If Alltrim(cValToChar(DADOSINT->OPERACAO_INT)) == "I" .And. Alltrim(cValToChar(DADOSINT->F1_FORMUL)) <> 'S'
				
				MsAguarde({|| lChkNf := checarDoc(Rtrim(DADOSINT->F1_DOC),Rtrim(DADOSINT->F1_FORNECE),Rtrim(DADOSINT->F1_Loja))},"Aguarde","Checando nota fiscal.")
				
				//Verifica se a nota jแ existe na base do Protheus.
				If lChkNf
					DADOSINT->(DbSkip())
					Loop
					
				EndIf
				
				cOper := "Inclusใo"
				
			Else
				cOper := "Exclusใo"
				
			EndIf
			
			If Alltrim(cValToChar(DADOSINT->F1_TIPO)) == "B"
				cNome	:=  Posicione("SA1",1,xFilial("SA1")+DADOSINT->F1_FORNECE+DADOSINT->F1_LOJA,"A1_NOME")
			Else
				cNome	:=  Posicione("SA2",1,xFilial("SA2")+DADOSINT->F1_FORNECE+DADOSINT->F1_LOJA,"A2_NOME")
				
			EndIf
			
			Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
			oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= Alltrim(cValToChar(DADOSINT->F1_EMISSAO))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTDIG"})]   := Alltrim(cValToChar(DADOSINT->F1_DTDIGIT))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"})]   	:= cOper
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FOR"})]   	:= Alltrim(cValToChar(DADOSINT->F1_FORNECE))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"})]  	:= Alltrim(cValToChar(DADOSINT->F1_LOJA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"})]   	:= Alltrim(cValToChar(cNome))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DOC"})]    	:= Alltrim(cValToChar(DADOSINT->F1_DOC))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "SER"})]   	:= Alltrim(cValToChar(DADOSINT->F1_SERIE))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "FPR"})]   	:= Alltrim(cValToChar(DADOSINT->F1_FORMUL))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"})]   	:= Val(cValToChar(DADOSINT->D1_TOTAL))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"})]   	:= Alltrim(cValToChar(DADOSINT->MENSAGEM_INT))
	    	
	    	If DADOSINT->TP = "1"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVermelho
	    		
	    	ElseIf DADOSINT->TP = "2"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVerde
	    		
	    	ElseIf DADOSINT->TP = "3"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oAmarelo
	    		
	    	ElseIf DADOSINT->TP = "4"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oAzul
	    		
	    	ElseIf DADOSINT->TP = "5"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oBranco
	    		
	    	ElseIf DADOSINT->TP = "6"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oPreto
	    		
	    	ElseIf DADOSINT->TP = "7"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oPink
	    		
	    	ElseIf DADOSINT->TP = "8"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oLaranja
	    		
	    	ElseIf DADOSINT->TP = "9"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVioleta
	    		
	    	EndIf
		
			DADOSINT->(DbSkip())
			
			oRegistros:Refresh()
			
		EndDo
	
	EndIf
	
	DbCloseArea("DADOSINT")
	
	oRegistros:Refresh()
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsqlEntrada  บ Autor ณ Everson          บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql de documentos de entrada.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function sqlEntrada()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery	:= ""
	
	cQuery += " SELECT '1' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL) AS D1_TOTAL, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' AND substring(F1_DOC,1,2) <> '0 ' AND F1_DOC <> '999999') AND (TABEGENE = 'PO01MVES' OR TABEGENE = 'POCAMVES') GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '2' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' AND substring(F1_DOC,1,2) <> '0 ' AND F1_DOC <> '999999') AND TABEGENE = 'PO02MVES' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '3' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' AND substring(F1_DOC,1,2) <> '0 ' AND F1_DOC <> '999999') AND TABEGENE = 'PO03MVES' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '4' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' ) AND TABEGENE = 'POCAFINA' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '5' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' ) AND TABEGENE = 'POCAMVTP' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '6' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' ) AND TABEGENE = 'FCCAMVAP' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '7' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' AND F1_FORMUL = 'S' ) AND TABEGENE = 'EC01LOTE' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '8' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' AND F1_FORMUL = 'S' ) AND TABEGENE = 'EC02LOTE' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '9' AS TP, F1_EMISSAO AS DATA, CASE WHEN F1_EMISSAO = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_EMISSAO AS DATE),103) END AS F1_EMISSAO, CASE WHEN F1_DTDIGIT = '' THEN '' ELSE CONVERT(VARCHAR(10),CAST(F1_DTDIGIT AS DATE),103) END AS F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, SUM(D1_TOTAL), F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL FROM SGNFE010 WHERE ((D1_MSEXP=' ' OR (D1_MSEXP <> ' ' AND STATUS_INT ='E' )) AND F1_FILIAL = '" + cFilAnt  + "' AND F1_FORMUL = 'S' ) AND TABEGENE = 'EC04LOTE' GROUP BY F1_EMISSAO, F1_DTDIGIT, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, F1_TIPO, MENSAGEM_INT, OPERACAO_INT, F1_FORMUL " 
	cQuery += " ORDER BY DATA, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE " 
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchecarDoc   บ Autor ณ Everson          บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Checar se o documento jแ existe nos documentos de entrada. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function checarDoc (cNotaSag,cFornec,cLoja)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local lRet		:= .F.
	Local cQuery	:= ""
	
	If Select("CHECANF") > 0
		CHECANF->(DbCloseArea())
	
	EndIf

	cQuery := " SELECT F1_FILIAL FROM " + RetSqlName("SF1") + " WHERE D_E_L_E_T_ = ' ' AND F1_FILIAL = '" + cFilAnt + "' AND F1_NOTASAG = '" + RTrim(cNotaSag) + "' AND F1_FORNECE = '" + RTrim(cFornec)+ "' AND F1_LOJA = '" + RTrim(cLoja) + "'"
	
	TcQuery cQuery New Alias "CHECANF"

	CHECANF->(DbGotop())
	If ! CHECANF->(Eof())
		lRet := .T.
		
	EndIf
	
	CHECANF->(DbCloseArea())

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณinterSaida    บ Autor ณ Everson        บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Interface de entradas.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function interSaida()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oInterface
	Local aAltInterface	:= {}
	Local aHInterface		:= {}
	Local aColsInterface	:= {}
	Local oSBtn01
	Local oSBtn02
	Local oSBtn03
	Local oSBtn04
	Local oRegistros
	
	//Cria objeto MsDialog.
	oInterface:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Saํdas - Processamentos Pendentes Protheus x SAG"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 900
	oInterface:nHeight   := 450
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
	//Cria botใo de confirma็ใo.
	oSBtn01:= SBUTTON():Create(oInterface)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "Legenda"
	oSBtn01:nLeft := 765
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
	oSBtn01:lVisibleControl := .T.
	oSBtn01:bAction := {||lngSaida()}
	
	//Cria botใo de cancelamento.
	oSBtn02:= SBUTTON():Create(oInterface)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Fechar"
	oSBtn02:nLeft := 833
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 50
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {||oInterface:End()}
	
/*	//Importa็ใo.
	oSBtn04:= SBUTTON():Create(oInterface)
	oSBtn04:cName := "oSBtn04"
	oSBtn04:cCaption := "Imp"
	oSBtn04:nLeft := 080
	oSBtn04:nTop := 390
	oSBtn04:nWidth := 50
	oSBtn04:nHeight := 20
	oSBtn04:lShowHint := .F.
	oSBtn04:lReadOnly := .F.
	oSBtn04:Align := 0
	oSBtn04:lVisibleControl := .T.
	oSBtn04:bAction := {||U_PED001B()}*/
	
	//Cria Header.
	Aadd(aHInterface,{" ","LEG"    	  ,"@BMP"    ,01     , 00,.T.,"","","","R","","",.F.,"V","","","",""})
	Aadd(aHInterface,{"DT Emissใo"    ,"DTEMIS"	 ,""	 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Opera็ใo"  	  ,"OPER"	 ,""	 , 10,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Cliente"       ,"CLI"     ,""	 , 06,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Loja"          ,"LOJ"     ,""	 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Nome"          ,"NOM"     ,""	 , 40,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Pedido"        ,"PED"     ,""	 , 12,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Tipo Ped"      ,"TPPED"     ,""	 , 02,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Placa"         ,"PLC"     ,""	 , 07,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Granja"        ,"GRJ"     ,""	 , 06,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Granjada"      ,"GRJD"    ,""	 , 04,0,"","" ,"C","",""})
	Aadd(aHInterface,{"Valor"         ,"VLR"     ,"@E 999,999,999.99"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Qtd"           ,"QTD"     ,"@E 999,999,999.999"	 , 15,2,"","" ,"N","",""})
	Aadd(aHInterface,{"Erro"          ,"ERR"     ,""	 , 60,0,"","" ,"C","",""})
	
	oRegistros := MsNewGetDados():New(005,004,180,445,,"Allwaystrue()","Allwaystrue()","",aAltInterface,Nil,999,Nil,Nil,Nil,oInterface,aHInterface,@aColsInterface)
	
	//Cria para recarregar dados.
	oSBtn03:= SBUTTON():Create(oInterface)
	oSBtn03:cName := "oSBtn03"
	oSBtn03:cCaption := "Recarr."
	oSBtn03:nLeft := 011
	oSBtn03:nTop := 390
	oSBtn03:nWidth := 80
	oSBtn03:nHeight := 20
	oSBtn03:lShowHint := .F.
	oSBtn03:lReadOnly := .F.
	oSBtn03:Align := 0
	oSBtn03:lVisibleControl := .T.
	oSBtn03:bAction := {||saidaCargaDados(oRegistros,aHInterface)}
	
	oInterface:Activate(,,,.T.,{||.T.},,{|| saidaCargaDados(oRegistros,aHInterface)})

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlngSaida  	   บ Autor ณ Everson     บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Lengenda de saํdas.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function lngSaida()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Local cTitulo := "Legenda"
     Local aLegenda:= {}
     
     Aadd(aLegenda, {"BR_VERMELHO" ,"Saํda por devolu็ใo"})
     Aadd(aLegenda, {"BR_VERDE"    ,"Saํda por trans. empresa"})
     Aadd(aLegenda, {"BR_AMARELO"  ,"Saํda por trans. integrado" })
     
     Aadd(aLegenda, {"BR_AZUL"     ,"Saํda por venda"})
     Aadd(aLegenda, {"BR_BRANCO"   ,"Frango 3 transmissใo propriedade"    	})
     Aadd(aLegenda, {"BR_PRETO"    ,"Saํda frango vivo apanha" })
     
     BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsaidaCargaDados  บ Autor ณ Everson     บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carregar dados.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function saidaCargaDados(oRegistros,aHInterface,cOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	//Local nTcConn1	:= advConnection()
	// Local cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	// Local cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	// Local cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	//Local nTcConn2  := 0
	Local nTotReg	:= 0
	
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
	
	Local oAzul		 := LoadBitmap( GetResources(), "BR_AZUL")
	Local oBranco 	 := LoadBitmap( GetResources(), "BR_BRANCO")
	Local oPreto	 := LoadBitmap( GetResources(), "BR_PRETO")
	
	Local oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA")
	Local oVioleta  := LoadBitmap( GetResources(), "BR_VIOLETA")
	
	Local cNome		:= ""
	Local cOper		:= ""
	Local lChkPed	:= .F.
	
	TcConType("TCPIP")
	
	// If (nTcConn2 := TcLink(cNomBco2,cSrvBco2,cPortBco2)) < 0
	// 	MsgAlert("Nใo foi possํvel  conectar ao banco integra็ใo.","Fun็ใo entrCargaDados")
	// 	Return Nil
		
	// EndIf
	
	////TcSetConn(nTcConn2)
	
	oRegistros:aCols := {}
	
	cQuery := sqlPedidos()
	
	If Select("DADOSINT") > 0
		DADOSINT->(DbCloseArea())
		
	EndIf
	
	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "DADOSINT", .F., .T.)},"Aguarde","Obtendo dados...")
	
	////TcSetConn(nTcConn1)
	
	DbSelectArea("DADOSINT")
	DADOSINT->(DbGoTop())
	
	nTotReg := Contar("DADOSINT","!EOF()")
	
	If nTotReg <= 0
       
		Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
		oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"})]  	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]    	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED"})]   := ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"})]   	:= ""
		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"})]   	:= ""
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"})]   	:= 0
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"})]   	:= 0
    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"})]   	:= ""
        
    	oRegistros:Refresh()
	
	Else
		
		DADOSINT->(DbGoTop())
		While ! DADOSINT->(Eof())
		
			If Alltrim(cValToChar(DADOSINT->STATUS_INT)) <> "E"
				
				MsAguarde({|| lChkPed := checarPed(Alltrim(cValToChar(DADOSINT->C5_NUM)),Alltrim(cValToChar(DADOSINT->C5_CLIENTE)))},"Aguarde","Checando pedido.")
				
				//Verifica se a nota jแ existe na base do Protheus.
				If lChkPed
					DADOSINT->(DbSkip())
					Loop
					
				EndIf
	
			EndIf
			
			If Alltrim(cValToChar(DADOSINT->OPERACAO_INT)) == "I" // ษverson - 09/03/2017. Chamado 033959.
				cOper := "Inclusใo"
				
			Else
				cOper := "Exclusใo"
				
			EndIf
			

			If Alltrim(cValToChar(DADOSINT->C5_TIPO)) == "B"
				cNome	:=  Posicione("SA2",1,xFilial("SA2") + Alltrim(cValToChar(DADOSINT->C5_CLIENTE)) + Alltrim(cValToChar(DADOSINT->C5_LOJACLI)),"A2_NOME")
				
			Else
				cNome	:=  Posicione("SA1",1,xFilial("SA1") + Alltrim(cValToChar(DADOSINT->C5_CLIENTE)) + Alltrim(cValToChar(DADOSINT->C5_LOJACLI)),"A1_NOME")
				
			EndIf

			Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
			oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	:= Alltrim(cValToChar(DADOSINT->C5_EMISSAO))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"})]   	:= cOper
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"})]   	:= Alltrim(cValToChar(DADOSINT->C5_CLIENTE))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"})]  	:= Alltrim(cValToChar(DADOSINT->C5_LOJACLI))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"})]   	:= Alltrim(cValToChar(cNome))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]    	:= Alltrim(cValToChar(DADOSINT->C5_NUM))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED"})]   := Alltrim(cValToChar(DADOSINT->C5_TIPO))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"})]   	:= Alltrim(cValToChar(DADOSINT->C5_PLACA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"})]   	:= Alltrim(cValToChar(DADOSINT->C5_GRANJA))
			oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"})]   	:= Alltrim(cValToChar(DADOSINT->C5_GRANJDA))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"})]   	:= Val(cValToChar(DADOSINT->C6_VALOR))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"})]   	:= Val(cValToChar(DADOSINT->C6_QTDVEN))
	    	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ERR"})]   	:= Alltrim(cValToChar(DADOSINT->MENSAGEM_INT))
	    	
	    	If DADOSINT->TP = "1"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVermelho
	    		
	    	ElseIf DADOSINT->TP = "2"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oVerde
	    		
	    	ElseIf DADOSINT->TP = "3"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oAmarelo
	    		
	    	ElseIf DADOSINT->TP = "4"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oAzul
	    		
	    	ElseIf DADOSINT->TP = "5"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oBranco
	    		
	    	ElseIf DADOSINT->TP = "6"
	    		oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG" })]	:= oPreto
	    		
	    	EndIf
		
			DADOSINT->(DbSkip())
			
			oRegistros:Refresh()
			
		EndDo
	
	EndIf
	
	DbCloseArea("DADOSINT")
	
	oRegistros:Refresh()
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsqlErroSaida    บ Autor ณ Everson          บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql de saํda.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function sqlPedidos()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery	:= ""
	
	cQuery += " SELECT '1' AS TP, MENSAGEM_INT, C5_EMISSAO AS DATA,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, SUM(C6_VALOR) AS C6_VALOR, SUM(C6_QTDVEN) AS C6_QTDVEN, C5_TIPO, STATUS_INT, OPERACAO_INT FROM SGPED010 A WHERE TABEGENE = 'PO02MVES' AND ((C5_MSEXP='' AND OPERACAO_INT = 'I') OR (C5_MSEXP <> ' ' and MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + cFilAnt  + "'  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='E' AND A.OPERACAO_INT='I')  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='I' AND A.OPERACAO_INT='E') " 
	cQuery += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_TIPO, STATUS_INT, MENSAGEM_INT, OPERACAO_INT  " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '2' AS TP, MENSAGEM_INT, C5_EMISSAO AS DATA,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, SUM(C6_VALOR) AS C6_VALOR, SUM(C6_QTDVEN) AS C6_QTDVEN, C5_TIPO, STATUS_INT, OPERACAO_INT  FROM SGPED010 A WHERE TABEGENE = 'PO03MVES' AND ((C5_MSEXP='' AND OPERACAO_INT = 'I') OR (C5_MSEXP <> ' ' and MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + cFilAnt  + "'  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='E' AND A.OPERACAO_INT='I')  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='I' AND A.OPERACAO_INT='E') " 
	cQuery += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_TIPO, STATUS_INT, MENSAGEM_INT, OPERACAO_INT  " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '3' AS TP, MENSAGEM_INT, C5_EMISSAO AS DATA,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, SUM(C6_VALOR) AS C6_VALOR, SUM(C6_QTDVEN) AS C6_QTDVEN, C5_TIPO, STATUS_INT, OPERACAO_INT  FROM SGPED010 A WHERE TABEGENE = 'POCAMVTP' AND ((C5_MSEXP='' AND OPERACAO_INT = 'I') OR (C5_MSEXP <> ' ' and MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + cFilAnt  + "'  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='E' AND A.OPERACAO_INT='I')  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='I' AND A.OPERACAO_INT='E') " 
	cQuery += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_TIPO, STATUS_INT, MENSAGEM_INT, OPERACAO_INT  " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '4' AS TP, MENSAGEM_INT, C5_EMISSAO AS DATA,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, SUM(C6_VALOR) AS C6_VALOR, SUM(C6_QTDVEN) AS C6_QTDVEN, C5_TIPO, STATUS_INT, OPERACAO_INT  FROM SGPED010 A WHERE (TABEGENE = 'PO01MVES' OR TABEGENE = 'POCAMVES') AND ((C5_MSEXP='' AND OPERACAO_INT = 'I') OR (C5_MSEXP <> ' ' and MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + cFilAnt  + "'  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='E' AND A.OPERACAO_INT='I')  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='I' AND A.OPERACAO_INT='E') " 
	cQuery += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_TIPO, STATUS_INT, MENSAGEM_INT, OPERACAO_INT  " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '5' AS TP, MENSAGEM_INT, C5_EMISSAO AS DATA,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, SUM(C6_VALOR) AS C6_VALOR, SUM(C6_QTDVEN) AS C6_QTDVEN, C5_TIPO, STATUS_INT, OPERACAO_INT  FROM SGPED010 A WHERE TABEGENE = 'EC03LOTE' AND ((C5_MSEXP='' AND OPERACAO_INT = 'I') OR (C5_MSEXP <> ' ' and MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + cFilAnt  + "'  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='E' AND A.OPERACAO_INT='I')  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='I' AND A.OPERACAO_INT='E') " 
	cQuery += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_TIPO, STATUS_INT, MENSAGEM_INT, OPERACAO_INT " 
	cQuery += " UNION ALL " 
	cQuery += " SELECT '6' AS TP, MENSAGEM_INT, C5_EMISSAO AS DATA,CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, SUM(C6_VALOR) AS C6_VALOR, SUM(C6_QTDVEN) AS C6_QTDVEN, C5_TIPO, STATUS_INT, OPERACAO_INT  FROM SGPED010 A WHERE TABEGENE = 'FCCAORAP' AND ((C5_MSEXP='' AND OPERACAO_INT = 'I') OR (C5_MSEXP <> ' ' and MENSAGEM_INT <> ' ' AND STATUS_INT='E')) AND C5_FILIAL = '" + cFilAnt  + "'  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='E' AND A.OPERACAO_INT='I')  " 
	cQuery += " AND NOT EXISTS (SELECT 1 FROM SGPED010 B WHERE A.C5_FILIAL=B.C5_FILIAL AND A.C5_NUM=B.C5_NUM AND A.TABEGENE=B.TABEGENE AND A.CODIGENE=B.CODIGENE AND B.OPERACAO_INT='I' AND A.OPERACAO_INT='E') " 
	cQuery += " GROUP BY C5_EMISSAO, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_TIPO, STATUS_INT, MENSAGEM_INT, OPERACAO_INT  " 
	cQuery += " ORDER BY DATA " 

Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณchecarPed   บ Autor ณ Everson          บ Data ณ  03/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Checar se o pedido jแ existe.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 033737.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function checarPed(cNum,cCli2)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local lRet		:= .F.
	Local cQuery	:= ""
	
	If Select("CHECAPED") > 0
		CHECAPED->(DbCloseArea())
	
	EndIf

	cQuery := " SELECT * FROM " + RetSqlName("SC5") + " WHERE D_E_L_E_T_ = ' ' AND C5_FILIAL = '" + cFilAnt + "' AND C5_PEDXML = '" + cNum + "' AND C5_CLIENTE = '" + cCli2 + "' "
	
	TcQuery cQuery New Alias "CHECAPED"

	CHECAPED->(DbGotop())
	If ! CHECAPED->(Eof())
		lRet := .T.
		
	EndIf
	
	CHECAPED->(DbCloseArea())

Return lRet
