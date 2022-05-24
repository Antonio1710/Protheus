#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include 'Topconn.ch'

//Variแveis Estแticas.
Static cTitulo := "Composi็ใo do Desconto"

/*/{Protheus.doc} User Function ADVEN062P
	Composi็ใo do Desconto. - Chamado 037261.
	@type  Function
	@author Everson
	@since 15/11/17
	@history Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	/*/
User Function ADVEN062P() // U_ADVEN062P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	   	 := GetArea()
	Local oCadPrin
	Local oComposicao
	Local oFechar
	Local oOk
	Local oApg
	Local aAltCdAp	 := {'PERC'}
	Local aHCdAp	 := {}
	Local aColsCdAp	 := {}
	Local lComercial := .F.
	Local lFinanceiro:= .F.
	Local cUsrCom	 := Alltrim(cValToChar(GetMv("MV_#COMPDC")))
	Local cUsrFim	 := Alltrim(cValToChar(GetMv("MV_#COMPDF")))
	Local cEmpSF:= GetMv("MV_#SFEMP",,"01|") 		//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI

	Private oCodigo
	Private cCodigo	:= Alltrim(cValToChar(SA1->A1_COD))
	Private oLoja
	Private cLoja	:= Alltrim(cValToChar(SA1->A1_LOJA))
	Private oNome
	Private cNome	:= Alltrim(cValToChar(SA1->A1_NOME))
	Private oPerc
	Private nPerc	:= 0
	Private oTxtDesc
	Private cTxtDesc:= ""
	
	//
	If !Alltrim(cEmpAnt) $ cEmpSF
		Return Nil
		
	EndIf
	
	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Composi็ใo do Desconto')
	
	//
	If Alltrim(cValToChar(__cUserId)) $ cUsrCom
		lComercial := .T.
		
	EndIf
	
	//
	If Alltrim(cValToChar(__cUserId)) $ cUsrFim
		lFinanceiro := .T.
		
	EndIF
	
	//
	If ! lComercial .And. ! lFinanceiro
		MsgStop("Usuแrio nใo possui acesso para alterar a composi็ใo do desconto comercial ou financeiro.","Fun็ใo ADVEN062P")
		RestArea(aArea)
		Return Nil
				
	EndIf	
	
	//
	If lComercial .And. lFinanceiro
		MsgStop("Usuแrio possui acesso para alterar a composi็ใo do desconto comercial e financeiro.","Fun็ใo ADVEN062P")
		RestArea(aArea)
		Return Nil
				
	EndIf
	
	//
	If Alltrim(cValToChar(SA1->A1_MSBLQL)) == "1"
		MsgStop("O registro estแ bloqueado.","Fun็ใo ADVEN062P")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
/*	If lComercial .And. Val(cValToChar(SA1->A1_DESC)) <= 0
		MsgStop("Nใo hแ percentual de desconto cadastrado para o cliente.","Fun็ใo ADVEN062P")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If lFinanceiro .And. Val(cValToChar(SA1->A1_ZZDESCB)) <= 0
		MsgStop("Nใo hแ percentual de desconto cadastrado para o cliente.","Fun็ใo ADVEN062P")
		RestArea(aArea)
		Return Nil
			
	EndIf*/
	
	//
	If lComercial
		nPerc := Val(cValToChar(SA1->A1_DESC))
		cTxtDesc := "comercial"
		
	ElseIf lFinanceiro
		nPerc := Val(cValToChar(SA1->A1_ZZDESCB))
		cTxtDesc := "financeiro"
		
	EndIf

	//
	oCadPrin		   := MsDialog():Create()
	oCadPrin:cName     := "oCadPrin"
	oCadPrin:cCaption  := cTitulo
	oCadPrin:nLeft     := 34
	oCadPrin:nTop      := 222
	oCadPrin:nWidth    := 530
	oCadPrin:nHeight   := 480
	oCadPrin:lShowHint := .F.
	oCadPrin:lCentered := .T.
	
		//
		oTxtDesc:= TSay():New(010,005,{|| "Composi็ใo do desconto " + cTxtDesc + "." },oCadPrin,,,,,,.T.,,,100,10)
		
		//
		oCodigo := TGet():New(025,003,{|u|If(PCount() == 0,cCodigo,cCodigo := u)},oCadPrin,020,010,"@!",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cCodigo",,,,.T.,,,"Cod:",1) 
		oLoja   := TGet():New(025,028,{|u|If(PCount() == 0,cLoja,cLoja := u)},oCadPrin,020,010,"@!",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cLoja",,,,.T.,,,"Loja:",1) 
		oNome   := TGet():New(025,053,{|u|If(PCount() == 0,cNome,cNome := u)},oCadPrin,150,010,"@!",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cNome",,,,.T.,,,"Nome:",1) 
		oPerc   := TGet():New(025,210,{|u|If(PCount() == 0,nPerc,nPerc := u)},oCadPrin,040,010,"@E 999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nPerc",,,,.T.,,,"% Desc:",1) 
		
		//
		aAdd(aHCdAp,{"Descri็ใo" ,"DESC","@!"       ,40,0,"","","C","",""})
		aAdd(aHCdAp,{"Percentual","PERC","@E 999.99",06,2,"","","N","",""})		
		
		//
		oComposicao := MsNewGetDados():New(050,001,200,260,GD_UPDATE,"Allwaystrue()","Allwaystrue()","",aAltCdAp,,10,Nil,Nil,Nil,oCadPrin,aHCdAp,@aColsCdAp)
		
		//
		//oApg := TButton():New(210,003,"Apg. Comp.",oCadPrin,{|| MsAguarde({|| apgComp(@cTxtDesc,@lComercial,@lFinanceiro) },"Aguarde","Apagar composi็ใo..."), oCadPrin:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oOk := TButton():New(210,170,"Ok",oCadPrin,{|| MsAguarde({||grvComp(@oComposicao,@lComercial,@lFinanceiro,@aHCdAp,@oCadPrin)},"Aguarde","Salvando dados...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oFechar	 := TButton():New(210,215,"Fechar",oCadPrin,{|| oCadPrin:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

	oCadPrin:Activate(,,,.T.,{||.T.},,{|| carrDados(@lComercial,@lFinanceiro,@oComposicao,@aHCdAp) })
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrvComp     บ Autor ณ Everson          บ Data ณ  15/11/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGrava composi็ใo do desconto.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grvComp(oComposicao,lComercial,lFinanceiro,aHCdAp,oCadPrin)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()
	Local i 	:= 1
	Local cComp	:= ""
	Local aCols	:= aClone(oComposicao:aCols)
	Local cDesc	:= ""
	Local nPerc	:= 0
	Local nVlr	:= 0
	
	//
	For i := 1 To Len(aCols)
		
		If ! (aCols[i,Len(aHCdAp)+1]) 
			
			//
			cDesc := Alltrim(cValToChar(aCols[i][aScan(aHCdAp,{|x| Alltrim(x[2]) == "DESC"})]))
			nPerc := Val(cValToChar(aCols[i][aScan(aHCdAp,{|x| Alltrim(x[2]) == "PERC"})]))
			
			//
/*			If Empty(cDesc)
				MsgStop("Hแ registro sem descri็ใo.","Fun็ใo grvComp")
				RestArea(aArea)
				Return Nil
							
			EndIf

			//
			If nPerc <= 0
				MsgStop("Hแ registro sem percentual.","Fun็ใo grvComp")
				RestArea(aArea)
				Return Nil
							
			EndIf*/
						
			cComp += cDesc + ": " + cValToChar(nPerc) + " %" + Chr(13) + Chr(10)
			
			nVlr += Val(cValToChar(aCols[i][aScan(aHCdAp,{|x| Alltrim(x[2]) == "PERC"})]))
			
		EndIf
	
	Next i
	
	//
	If lComercial .And. nVlr <> Val(cValToChar(SA1->A1_DESC)) //.And. ! Empty(cComp)
		MsgStop("Percentual informado diverge do percentual cadastrado.","Fun็ใo grvComp")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If lFinanceiro .And. nVlr <> Val(cValToChar(SA1->A1_ZZDESCB)) //.And. ! Empty(cComp)
		MsgStop("Percentual informado diverge do percentual cadastrado.","Fun็ใo grvComp")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If Len(cComp) > 0
		cComp := Substr(cComp,1, Len(cComp) -1)
		
	EndIf
	
	//
	If lComercial
	
		RecLock("SA1",.F.)
			Replace SA1->A1_XCCUSTC With cComp
		MsUnLock()
	
	ElseIf lFinanceiro
	
		RecLock("SA1",.F.)
			Replace SA1->A1_XCCUSTF With cComp
		MsUnLock()	
	
	EndIf
	
	//
	oCadPrin:End()
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณapgComp     บ Autor ณ Everson          บ Data ณ  15/11/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCarrega composi็ใo do desconto no MsNewGetDados.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function apgComp(cTxtDesc,lComercial,lFinanceiro)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	  := GetArea()
	
	//
	If ! MsgYesNo("Deseja apagar a composi็ใo do desconto " + cTxtDesc + "?","Fun็ใo apgComp")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If lComercial
	
		RecLock("SA1",.F.)
			SA1->A1_XCCUSTC := ""
		MsUnLock()
	
	ElseIf lFinanceiro
	
		RecLock("SA1",.F.)
			SA1->A1_XCCUSTF := ""
		MsUnLock()	
	
	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcarrDados   บ Autor ณ Everson          บ Data ณ  15/11/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCarrega composi็ใo do desconto no MsNewGetDados.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function carrDados(lComercial,lFinanceiro,oComposicao,aHCdAp)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	  := GetArea()
	Local cDados1 := ""
	Local aDados1 := {}
	Local cDados2 := ""
	Local aDados2 := {}
	Local i		  := 1
	Local x		  := 1
	Local cDesc	  := ""
	Local aOpcs	  := {}
	
	Aadd(aOpcs,"Aniversแrio")
	Aadd(aOpcs,"Inaugura็ใo")
	Aadd(aOpcs,"Fornecimento")
	Aadd(aOpcs,"Logํstica")
	Aadd(aOpcs,"Reinaugura็ใo")
	Aadd(aOpcs,"Quebra/Troca")
	Aadd(aOpcs,"Associa็ใo")
	Aadd(aOpcs,"Crescimento")
	Aadd(aOpcs,"Verba Inv. Coorp.")
	Aadd(aOpcs,"Web")
	
	//
	If lComercial
		cDados1 := SA1->A1_XCCUSTC
		
	ElseIf lFinanceiro
		cDados1 := SA1->A1_XCCUSTF
		
	EndIf
	
/*	//
	If Empty(Alltrim(cValToChar(cDados1)))
		RestArea(aArea)
		Return Nil
		
	EndIf*/
	
	//
	oComposicao:aCols := {}
	For i := 1 To Len(aOpcs)
	
		Aadd(oComposicao:aCols , Array(Len(aHCdAp)+1) )
		oComposicao:aCols[Len(oComposicao:aCols), Len(oComposicao:aCols[1]) ] := .F.
		oComposicao:aCols[Len(oComposicao:aCols),Ascan(aHCdAp,{|x| AllTrim(x[2]) == "DESC"  })] := aOpcs[i]
		oComposicao:aCols[Len(oComposicao:aCols),Ascan(aHCdAp,{|x| AllTrim(x[2]) == "PERC"  })] := 0
	
	
	Next i
	
	//
	If Empty(cDados1)
		oComposicao:Refresh()
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	aDados1 := StrToKarr(cDados1,"%")

	//
	For i := 1 To Len(aDados1)
		
		If At(":",Alltrim(aDados1[i])) > 0
			aDados2 := StrToKarr(Alltrim(aDados1[i]),":")
			oComposicao:aCols[i,Ascan(aHCdAp,{|x| AllTrim(x[2]) == "PERC"  })] := Val(cValToChar(aDados2[2]))
		
		EndIf
			
	Next i
	
	//
	oComposicao:Refresh()

	//
	RestArea(aArea)
	
Return Nil      
