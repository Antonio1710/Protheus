#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include 'Topconn.ch'

/*/{Protheus.doc} User Function IMPRDNET
	@Rotina para importa็ใo dos pedidos roteirizados do RoadNet
    @type  Function
    @author Ricardo Lima 
    @since 10/01/2019
    @version 01
    @history Chamado 044314 - Ricardo Lima - 10/01/2019 - Gera carga de entrega para gera็ใo de frete no faturamento.
	@history Chamado 044314 - Everson      - 28/02/2019 - Adicionado o Km percorrido no log.
	@history Chamado 044314 - Everson      - 23/05/2019 - Removida a fun็ใo StartJob e adiciona c๓pia do arquivo roadnet  para o servidor
	@history Chamado 044314 - Everson      - 28/05/2019 - Removida valida็ใo de placa. 
	@history Chamado 044314 - Everson      - 10/07/2019 - Tratamento para informar a placa do cavalo mecโnico para gera็ใo do MDF-e
	@history Tkt     63034  - Sigoli       - 01/11/2021 - Adicionado fClose(nHdl)no final do fun็ใo  - "fechar o arquivo"
/*/

User Function IMPRDNET() // U_IMPRDNET()

	Local oChk1
	Local lChk1
	
	Local oBtnConfig //ษverson - 13/09/2016, chamado 029242.
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa็ใo Roadnet')
	
	Define MsDialog oTxtTela Title OemToAnsi("IMPPRDNET - Importa็ใo de Arquivos Roadnet") From 20, 1 To 271, 345 COLORS 0, 16777215 Pixel Style 128
	@ 010,005 Say " Esse programa tem o objetivo de importar arquivos magn้ticos "
	@ 024,005 Say " de acordo com o Layout RoadNet e conforme os parโmetros "
	@ 038,005 Say " abaixo "
	@ 064,005 Say " Marque os arquivos que deseja importar: "
	
	@ 076,08 CheckBox oChk1 Var lChk1 Prompt "Pedido de Vendas    " Size 65,9  Pixel Of oTxtTela
	
	@ 105,005 Button oBtnConfig Prompt "Config. Emplac." Size 050, 010 Of oTxtTela Action (configParam()) Pixel //ษverson - 13/09/2016, chamado 029242.
	
	@ 105,110 BMPBUTTON TYPE 01 ACTION (Processa({||LERoadNet(lChk1)},"Processando","Aguarde, importando arquivo..."), Iif(lChk1,Close(oTxtTela),))
	@ 105,140 BMPBUTTON TYPE 02 ACTION Close(oTxtTela)
	
	Activate Dialog oTxtTela Centered

Return 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณconfigParam       บ Autor ณ Everson    บ Data ณ  13/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo configurar a tabela de frete e tipo de frete por    บฑฑ
ฑฑบ          ณ faixa de roteiros.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function configParam()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oDlgConfig
	Local aAltParam	:= {'ROTDE','ROTAT','TAFRT','TIFRT'}
	Local aHParam		:= {}
	Local aColsParam	:= {}
	Local oSBtn01
	Local oSBtn02
	Local oParametros
	Local cTab			:= "EA"
	
	//Cria objeto MsDialog.
	oDlgConfig:= MsDialog():Create()
	oDlgConfig:cName     := "oDlgConfig"
	oDlgConfig:cCaption  := "Parโmetros da Rotina de Emplacamento"
	oDlgConfig:nLeft     := 34
	oDlgConfig:nTop      := 222
	oDlgConfig:nWidth    := 900
	oDlgConfig:nHeight   := 450
	oDlgConfig:lShowHint := .F.
	oDlgConfig:lCentered := .T.
	
	//Cria botใo de confirma็ใo.
	oSBtn01:= SBUTTON():Create(oDlgConfig)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "OK"
	oSBtn01:nLeft := 765
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
	oSBtn01:lVisibleControl := .T.
	oSBtn01:bAction := {|| grvParametros(oParametros,aHParam,oDlgConfig,cTab)}
	
	//Cria botใo de cancelamento.
	oSBtn02:= SBUTTON():Create(oDlgConfig)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Cancelar"
	oSBtn02:nLeft := 833
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 50
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {||oDlgConfig:End()}
	
	//Cria Header.
	Aadd(aHParam,{"Rota de" 		,"ROTDE"	,""	, 10,0,"","" ,"C","",""})
	Aadd(aHParam,{"Rota ate" 		,"ROTAT"	,""	, 10,0,"","" ,"C","",""})
	Aadd(aHParam,{"Tabela de Frete"	,"TAFRT"	,""	, 04,0,"","" ,"C","ZV8",""})
	Aadd(aHParam,{"Desc. Tab Frt"	,"DESCTA"	,""	, 30,0,"","" ,"C","",""})
	Aadd(aHParam,{"Tipo de Frete"	,"TIFRT"	,""	, 04,0,"","" ,"C","SZH",""})
	Aadd(aHParam,{"Desc. de Frete"	,"DESCTI"	,""	, 30,0,"","" ,"C","",""})
	
	oParametros := MsNewGetDados():New(005,004,180,445,GD_UPDATE + GD_INSERT + GD_DELETE,"Allwaystrue()","Allwaystrue()","",aAltParam,Nil,999,Nil,Nil,Nil,oDlgConfig,aHParam,@aColsParam)
	
	oDlgConfig:Activate(,,,.T.,{||.T.},,{|| cargaConfPara(oParametros,aHParam,cTab)})
	
Return Nil                           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณconfigParam       บ Autor ณ Everson    บ Data ณ  13/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para gravar as configura็๕es de emplacamento        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function grvParametros(oParametros,aHParam,oDlgConfig,cTab)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	Local cUpdate	:= "UPDATE " + RetSqlName("SX5") + " SET D_E_L_E_T_ = '*' WHERE X5_TABELA = '" + cTab + "' AND X5_FILIAL = '" + xFilial("SX5") + "'"
	Local i		:= 1
	Local cChave	:= ""
	Local cDados	:= ""
	
	//Valida dados no aCols.
	If Len(oParametros:aCols) <= 0
		MsgStop("Nใo hแ dados a serem salvos.","Fun็ใo grvParametros(IMPRDNET)")
		Return Nil
		
	EndIf
	
	//Solicita confirma็ใo do usuแrio.
	If ! MsgYesNo("Deseja salvar o(s) registro(s)?","Fun็ใo grvParametros(IMPRDNET)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Apaga registros existentes.
	If TcSqlExec(cUpdate) < 0
		MsgStop("Nใo foi possํvel atualizar os registros.","Fun็ใo grvParametros(IMPRDNET)")
		Return Nil
		
	EndIf
	
	//Grava os novos registros.
	For i := 1 To Len(oParametros:aCols)
		
		If ! oParametros:aCols[i][Len(oParametros:aCols[1])]
		
			cChave	:= Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"})]))
			
			cDados	:= Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"})])) + "/" +;
					   Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTAT"})])) + "/" +;
					   Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "TAFRT"})])) + "/" +;
					   Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "TIFRT"})]))
		
			DbSelectArea("SX5")
			Reclock("SX5",.T.)
				SX5->X5_FILIAL	:= xFilial("SX5")
				SX5->X5_TABELA	:= cTab
				SX5->X5_CHAVE		:= cChave
				SX5->X5_DESCRI	:= cDados
				SX5->X5_DESCSPA	:= cDados
				SX5->X5_DESCENG	:= cDados
			MsUnlock()
		
		EndIf
	
	Next i
	
	MsgInfo("Processo relizado.","Fun็ใo grvParametros(IMPRDNET)")
	
	//Fecha janela.
	oDlgConfig:End()
	
	RestArea(aArea)
	
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcargaConfPara       บ Autor ณ Everson    บ Data ณ  13/09/16 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para carregar as configura็๕es de emplacamento      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function cargaConfPara(oParametros,aHParam,cTab)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea()
	Local aDados	:= {}
	Local i		:= 1
	Local cRotaDe := ""
	Local cRotaAte:= ""
	Local cTaFrt	:= ""
	Local cDescTa	:= ""
	Local cTiFrt	:= ""
	Local cDescTi	:= ""
	
	//Zera aCols.
	oParametros:aCols := {}
	
	//Obt้m dados de parโmetros.
	aDados := dadosParametros(cTab)
	
	If Len(aDados) > 0
		
		For i := 1 To Len(aDados)
			
			cRotaDe 	:= aDados[i][1]
			cRotaAte	:= aDados[i][2]
			cTaFrt		:= aDados[i][3]
			cDescTa	:= aDados[i][4]
			cTiFrt		:= aDados[i][5]
			cDescTi	:= aDados[i][6]
			
			Aadd(oParametros:aCols , Array(Len(aHParam)+1) )
			oParametros:aCols[Len(oParametros:aCols), Len(oParametros:aCols[1]) ] := .F.
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"  })] := Alltrim(cValToChar(cRotaDe)) + Space(10)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTAT"  })] := Alltrim(cValToChar(cRotaAte)) + Space(10)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TAFRT"  })] := Alltrim(cValToChar(cTaFrt)) + Space(04)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTA" })] := Alltrim(cValToChar(cDescTa)) + Space(30)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TIFRT"  })] := Alltrim(cValToChar(cTiFrt)) + Space(04)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTI" })] := Alltrim(cValToChar(cDescTi)) + Space(30)
		
		Next i
	
	Else
		Aadd(oParametros:aCols , Array(Len(aHParam)+1) )
		oParametros:aCols[Len(oParametros:aCols), Len(oParametros:aCols[1]) ] := .F.
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"  })] := Space(10)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTAT"  })] := Space(10)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TAFRT"  })] := Space(04)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTA" })] := Space(30)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TIFRT"  })] := Space(04)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTI" })] := Space(30)
	
	EndIf
	
	oParametros:Refresh()
	
	RestArea(aArea)
			
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdadosParametros     บ Autor ณ Everson    บ Data ณ  13/09/16 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo obt้m dados de parโmetros						       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function dadosParametros(cTab)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aDados	:= {}
	Local cQuery	:= ""
	Local cRotaDe := ""
	Local cRotaAte:= ""
	Local cTaFrt	:= ""
	Local cDescTa	:= ""
	Local cTiFrt	:= ""
	Local cDescTi	:= ""
	Local aRetorno:= {}

	cQuery := ""
	cQuery += " SELECT *  "
	cQuery += " FROM  " + RetSqlName("SX5") + "  AS SX5 "
	cQuery += " WHERE  "
	cQuery += " X5_TABELA = '" + cTab + "'  "
	cQuery += " AND SX5.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY X5_CHAVE "
	
	If Select("PARAMETROS") > 0
		PARAMETROS->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery new Alias "PARAMETROS"
	DbSelectArea("PARAMETROS")
	PARAMETROS->(DbGoTop())
	
	While ! PARAMETROS->(Eof())
		
		aDados := StrToKarr(Alltrim(cValToChar(PARAMETROS->X5_DESCRI)),"/")
		
		If Len(aDados) == 4
		
			cRotaDe 	:= Alltrim(cValToChar(aDados[1]))
			cRotaAte	:= Alltrim(cValToChar(aDados[2]))
			cTaFrt		:= Alltrim(cValToChar(aDados[3]))
			cTiFrt		:= Alltrim(cValToChar(aDados[4]))
			
			cDescTa	:= Posicione("ZV8",1,xFilial("ZV8") + cTaFrt,"ZV8_CIDADE")
			cDescTi	:= Posicione("SZH",1,xFilial("SZH") + cTiFrt,"ZH_DESCRIC")
			
			Aadd(aRetorno,{cRotaDe,cRotaAte,cTaFrt,cDescTa,cTiFrt,cDescTi})
			
		EndIf
		
		PARAMETROS->(DbSkip())
		
	EndDo

Return aRetorno

Static Function LERoadNet(lChk1)
	
	//Valida op็ใo selecionada.
	If lChk1 
		importarPV(lChk1)
		
	Else
		MsgStop("Selecione ao menos uma op็ใo para continuar!","LERoadNet(IMPRDNET)")
		
	EndIf

Return Nil

Static Function importarPV(lChk1) //ษverson - 13/09/2016, chamado 029242.
	
	Local nTamLin  := SuperGetMv( "MV_#ROAD01" , .F. , 162 , ) // 162 // Tamanho da linha no arquivo texto //Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para gera็ใo de frete no faturamento
	Local cTipo    := "Todos(*.*) |*.* | "  
	Local _cArq    := ""			// Arquivo texto a importar com codigo+loja
	Local nHdl     := NIL              	// Handle para abertura do arquivo
	Local cBuffer  := Space(160)	// Variavel para leitura
	Local nBytes   := 0					// Variavel para verificacao do fim de arquivo
	Local _cCodCli, _cLoja, _cPedNum, _cProduto, _cRoteiro, _cSeqNum, _cPlaca  
	
	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Relat๓rio de Erros de Importa็ใo"
	Local titulo       	:= "Relat๓rio de Erros de Importa็ใo"
	Local nLin         	:= 80
	Local Cabec1       	:= " ATENDIMENTO TELEVENDAS "
	Local Cabec2       	:= ""
	Local aOrd 			:= {} 
	
	//ษverson - 13/09/2016, chamado 029242.
	Local aDadosRoteiro	:= {} 
	Local nPos				:= 0
	Local lRel				:= .T.
	Local nTotLinhas		:= 0
	Local nTamArquivo		:= 0
	Local cTabela			:= ""
	Local aLinhaErro		:= {}
	Local nTipoErro		:= 0
	//
	//Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para gera็ใo de frete no faturamento
	Local aCargaFt    := {}
	Local lPedInc     := .T.
	Local p           := 0
	Local _KmTotal	   := ""
	Local lGeraCrg    := SuperGetMv( "MV_#ROAD02" , .F. , .F. , )
	
	//Everson-23/05/2019-Ch:044314.
	Local cDrive		:= ""
	Local cDir			:= ""
	Local cNome			:= ""
	Local cExt			:= ""
	Local lArqRod		:= GetMv("MV_#ARQROD",,.F.)
	
	Private _cLinhalva  := ""
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private tamanho     := "M"
	Private nomeprog    := "IMPRDNET" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbcont     	:= 00
	Private CONTFL     	:= 01
	Private m_pag      	:= 01
	Private wnrel      	:= "IMPRDNET" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString     := ""
	
	//Obt้m arquivo.
	_cArq := cGetFile( cTipo , "IMPRDNET - Selecione o arquivo")
	
	//Valida arquivo.  
	If Empty(_cArq)
       MsgStop( "Selecione um arquivo.","importarPV(IMPRDNET)")
       Return Nil
       
    Endif
 
    //
	nHdl := fOpen(_cArq,2) // Abre o arquivo
	
	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Nใo foi possํvel abrir o arquivo " + Chr(13) + Chr(13) +_cArq,"importarPV(IMPRDNET)")
		Return Nil		
	Endif
	
	//Everson-23/05/2019-Ch:044314.
	If lArqRod
	    SplitPath(_cArq, @cDrive, @cDir, @cNome, @cExt )
	    CpyT2S(_cArq, "\arq_roadnet", .F. ) 
	    frename("\arq_roadnet\" + cValToChar(cNome) + cValToChar(cExt)  , "\arq_roadnet\" + Alltrim(cValToChar(cUserName)) + "_" + DToS(Date()) + "_" + StrTran(Time(),":","") + ".TXT" )
		
	EndIf
	//
	
	//log de inicio de importa็ใo de pedidos roteirizados
	u_GrLogZBE (Date(),TIME(),cUserName," INICIO IMPORTACAO PED.VENDAS","LOGISTICA","IMPORTARPV","ROADNET - IMPORTAR-PEDIDOS",ComputerName(),LogUserName()) 
	
	nBytes := fRead(nHdl,@cBuffer,nTamLin) // Le uma linha
	
	//ษverson - 13/09/2016, chamado 029242.
		//Obt้m o tamanho do arquivo.
		nTamArquivo := FSeek(nHdl,0,2)
		
		//Obt้m a quantidade de linhas.
		nTotLinhas := nTamArquivo/nTamLin

		//Atribui o tamanho da r้gua.
		ProcRegua(nTotLinhas)
		
		//Posiciona no inํcio do arquivo.
		FSeek(nHdl,0,0)
	//
	
	//Percorre arquivo.
	While nBytes == nTamLin
	
		_cCodCli  := Substr(cBuffer,1,6)
		_cLoja    := Substr(cBuffer,7,2)
		_cPedNum  := Substr(cBuffer,16,6)
		_cProduto := Substr(cBuffer,61,6)
		_cRoteiro := Substr(cBuffer,118,3)
		_cSeqNum  := StrZero(Val(Substr(cBuffer,139,2)),2,0)
		_cPlaca   := Substr(cBuffer,154,7)
		_KmTotal  := Substr(cBuffer,180,8)  //Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para gera็ใo de frete no faturamento
		_bOkC5    := .F.
		_bOkC6    := .F.
		_bOkC9	  := .F.
		
		IncProc("PV " + Alltrim(cValToChar(_cPedNum)) + "|" + _cCodCli + _cLoja + "|" + _cRoteiro + "|") //ษverson - 13/09/2016, chamado 029242.
		
		//14/01/14 - Ana
		//_RotEnt - Controle para verificar se o pedido jแ foi enviado para o Edata, sendo necessario o Estorno antes de modificar o pedido
		_RotEnt   := .F.
		
		//Verifica se o pedido jแ foi enviado ao Edata.
		DbSelectArea("SC5")
		SC5->(DbSetOrder(3))
		SC5->(DbGoTop())
		If SC5->(DbSeek(xFilial("SC5") + _cCodCli + _cLoja + _cPedNum))
		
			If Alltrim(SC5->C5_XINT) == "3"
				MsgStop("O pedido " + Alltrim(cValToChar(SC5->C5_NUM)) +;
				 	   " jแ enviado para o Edata, para altera-lo ้ necessแrio o Estorno.","importarPV(IMPRDNET)")
				_RotEnt := .T.
				
			ElseIf !Empty(SC5->C5_NOTA) //incluido por Adriana para nao roteirizar pedido faturado
				MsgStop("Processo interrompido, pedido jแ faturado, nใo pode ser roteirizado "+_cPedNum,"importarPV(IMPRDNET)")
				_RotEnt := .T.
			
			Else
			
				// *** INICIO CHAMADO 040504 WILLIAM COSTA 21/03/2018 *** //	
				IF Empty(_cRoteiro) .OR. Empty(SC5->C5_ROTEIRO)
			
					u_GrLogZBE (Date(),TIME(),cUserName,"IMPORTACAO ROADNET","LOGISTICA","IMPRDNET",;
	         	               "PEDIDO: "+SC5->C5_NUM +'||' + _cPedNum +" ROTEIRO BRANCO: "+SC5->C5_ROTEIRO+"||"+_cRoteiro,;
	           	               ComputerName(),LogUserName())
	           	ENDIF
	           	// *** FINAL CHAMADO 040504 WILLIAM COSTA 21/03/2018 *** //
				
			
				_dtEntr := SC5->C5_DTENTR
				
				//Verifica se hแ pedido no roteiro que jแ tenha sido enviado ao Edata.
				DbSelectArea("SC5")
				//SC5->(dbSetOrder(9))
				SC5->(DBORDERNICKNAME("SC5_9")) //atualiza็ใo protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
				SC5->(DbGoTop())
				SC5->(dbSeek(xFilial("SC5") + DTOS(_dtEntr) + Alltrim(_cRoteiro)))						
	   			Do While ! SC5->(Eof()) .And. _dtEntr == SC5->C5_DTENTR .And. Alltrim(_cRoteiro) == Alltrim(SC5->C5_ROTEIRO)
	   			
					If Alltrim(SC5->C5_XINT) == "3"
						If !_RotEnt
   							MsgAlert("Processo interrompido, o roteiro " + Alltrim(SC5->C5_ROTEIRO) + " (" + DToC(CToD(cValToChar(_dtEntr))) +;
   							 		  "-" + Alltrim(SC5->C5_NUM) + ")" +;
   							         " jแ foi enviado ao Edata! Verifique!","importarPV(IMPRDNET)")
   							
   						Endif	
   						
						_RotEnt := .T.
						
		   			Endif
		   			
					DbSelectArea("SC5")
					SC5->(DbSkip())
						
	   			EndDo
				
			Endif	
			
		Endif				
		
		//Salva as informa็๕es de retorno do RoadNet no cabe็alho (SC5), nos itens (SC6) e itens liberados (SC9) do pedido de venda.
		If !_RotEnt
		
			//Salva as informa็๕es de retorno do RoadNet no cabe็alho do pedido de venda.
			DbSelectArea("SC5")
			SC5->(dbSetOrder(3))
			SC5->(DbGotop())
			If SC5->(dbSeek(xFilial("SC5") + _cCodCli + _cLoja + _cPedNum))
			    _c_RotA := SC5->C5_ROTEIRO   &&Mauricio - 11/08/17 - Chamado 036566
			    _c_SeqA := SC5->C5_SEQUENC   &&Mauricio - 11/08/17 - Chamado 036566
			    _c_PlcA := SC5->C5_PLACA     &&Mauricio - 11/08/17 - Chamado 036566
			
				SC5->(recLock("SC5",.F.))
				SC5->C5_ROTEIRO := _cRoteiro
				SC5->C5_SEQUENC := _cSeqNum
				SC5->C5_PLACA   := _cPlaca           
				SC5->C5_UFPLACA := "  " //Incluido para obrigar a roteiriza็ใo pelo Protheus  em 18/11/14 por adriana  - chamado 020095
				_bOkC5 := .T.
				SC5->(msUnlock())
				//Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para gera็ใo de frete no faturamento
				//If !Empty( _cPlaca) //Everson-28/05/2019-Ch:044314
					For p:=1 to Len(aCargaFt)
						if _cPedNum = aCargaFt[p][3]
							lPedInc := .F.
						Endif
					Next
					If lPedInc = .T.
						Aadd( aCargaFt , { _cCodCli , _cLoja , _cPedNum , _cProduto , _cRoteiro , _cSeqNum , _cPlaca, _KmTotal, DToS(SC5->C5_DTENTR) } ) //Everson-28/05/2019-Ch:044314.
					Endif
					lPedInc := .T.
				//Endif
				
				_dtEntr := SC5->C5_DTENTR
				
				&&Mauricio - 11/08/17 - Chamado 036566 - Inclusใo de log para troca de roteiro, placa, sequencia quando retornado pelo
		        &&roadnet. Efetuado apenas para a SC5 para nao poluir o log, mas estende-se as tabelas abaixo.
				u_GrLogZBE (Date(),TIME(),cUserName,"IMPORTACAO ROADNET","LOGISTICA","IMPRDNET",;
         	               "PEDIDO: "+SC5->C5_NUM+" ROTEIRO/SEQ/PLACA DE: "+_c_RotA+" "+_c_SeqA+" "+_c_PlcA+" " + cValToChar(_KmTotal) + " PARA: "+_cRoteiro+" "+_cSeqNum+" "+_cPlaca,; //Everson - 28/02/2019. Chamado 044314. Adicionado o Km percorrido.
           	               ComputerName(),LogUserName())
			
			EndIf
						
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			SC6->(DbGoTop())
			If SC6->(DbSeek(xFilial("SC6") + _cPedNum)) .And. _bOkC5 .And. ! Empty(Alltrim(cValToChar(_cRoteiro))) .And. ! Empty(Alltrim(cValToChar(_cSeqNum)))
				
				While Alltrim(SC6->C6_NUM) == Alltrim(_cPedNum) .And. ! SC6->(Eof())
					
					If (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0 //Valida se a quantidade entregue ้ menor que a quantidade do pedido.
						
						SC6->(recLock("SC6",.F.))
						SC6->C6_ROTEIRO 	:= _cRoteiro
						SC6->C6_SEQUENC 	:= _cSeqNum
						_bOkC6 			:= .T.
						
						SC6->(msUnlock())
						
					Endif
					
					SC6->(dbSkip())
					
				Enddo
				
			Endif	
								
	       //Incluido para gravar SC9 em 18/11/14 por adriana - chamado 020095
			DbSelectArea("SC9")
			SC9->(DbSetOrder(1))
			SC9->(DbGoTop())
			If SC9->(DbSeek( xFilial("SC9") + _cPedNum )) .And. _bOkC6	
			
				While ! SC9->(Eof()) .and. SC9->C9_PEDIDO == _cPedNum .And. xFilial("SC9") == SC9->C9_FILIAL			
					
					If Reclock("SC9",.F.) //Valida se foi possํvel "travar" o registro.
						SC9->C9_PLACA 		:= _cPlaca  
						SC9->C9_ROTEIRO 		:= _cRoteiro
						SC9->C9_SEQUENC      := _cSeqNum
						SC9->C9_DTENTR 		:= _dtEntr 
						_bOkC9					:= .T.
						
						SC9->(MsUnlock())

					Endif
			
					SC9->(dbSkip())
					
				EndDo
				
			Endif
			
			&&Mauricio - 11/08/17 - Chamado 036566 - Fernando informou que no retorno do roadnet ha pedidos com roteiros trocados
			&&sendo assim necessario atualizar tambem o roteiro na tabela de controle de frete SZK se existir registro com os dados anteriores da SC5.
			IF _bOkC5  &&Atualizou o SC5
			   dbSelectArea("SZK")
               dbSetOrder(4)     // ZK_FILIAL + ZK_DTENTR  + ZK_PLACA + ZK_ROTEIRO )
               If dbSeek(xFilial("SZK")+ DTOS(_dtEntr) + _c_PlcA + _c_RotA)  
               
               	  //grava log chamado 041202 - WILLIAM COSTA 23/04/2018
				  u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.F.)","LOGISTICA","IMPRDNET",;
				  "Filial: "+xFilial("SZK")+" Data: "+DTOS(_dtEntr)+" Placa: "+_c_PlcA+" Roteiro: "+_c_RotA,ComputerName(),LogUserName())	
                               
	              RecLock("SZK",.F.)
	              Replace ZK_FILIAL   With xFilial("SZK")	              
	              Replace ZK_PLACA    With _cPlaca
	              Replace ZK_PLACAPG  With _cPlaca             
	              Replace ZK_ROTEIRO  With _cRoteiro 
	              Replace ZK_PLCCAV   With "" //Everson - 10/07/2019.   	
	              SZK->(MsUnlock())
	           ELSE
	           
	              //grava log chamado 041202 - WILLIAM COSTA 23/04/2018
				  u_GrLogZBE (Date(),TIME(),cUserName," ELSE RecLock(SZK,.F.)","LOGISTICA","IMPRDNET",;
				  "Filial: "+xFilial("SZK")+" Data: "+DTOS(_dtEntr)+" Placa: "+_c_PlcA+" Roteiro: "+_c_RotA,ComputerName(),LogUserName())
				  
               Endif												
            Endif
            
		Endif
		
		//ษverson - 12/09/2016, chamado 029242.
		If !_RotEnt .And. _bOkC5 .And.  _bOkC6 .And. _bOkC9
			
			//Verifica se o o roteiro estแ no array.
			nPos := 0
			nPos := Ascan(aDadosRoteiro,{|x| Alltrim(cValtoChar(x[3])) == Alltrim(cValToChar(_cRoteiro))})
			
			//O dados sใo adicionados ao array para emplacamento automแtico.
			If nPos == 0
			
				Aadd(aDadosRoteiro,{_cPlaca,_dtEntr,_cRoteiro})
			
			EndIf
		
		EndIf
		
		If _RotEnt .Or. ! _bOkC5 .Or.  ! _bOkC6 .Or. ! _bOkC9 //ษverson - 13/09/2016, chamado 029242.
			
			//ษverson - 13/09/2016, chamado 029242.
			If _RotEnt
				cTabela	:= "Erro pedido jแ faturado e/ou enviado para o Edata"
				nTipoErro	:= 1
				
			ElseIf ! _bOkC5 .Or.  ! _bOkC6 .Or. ! _bOkC9
				cTabela	:= "Tabela SC5"
				nTipoErro	:= 2
				
			ElseIf _bOkC5 .Or.  ! _bOkC6 .Or. ! _bOkC9
				cTabela	:= "Tabela SC6"
				nTipoErro	:= 3
				
			ElseIf _bOkC5 .Or. _bOkC6 .Or. ! _bOkC9
				cTabela	:= "Tabela SC9"
				nTipoErro	:= 4
				
			EndIf
			
			Aadd(aLinhaErro,{_cPedNum + " - Roteiro: " + cValToChar(_cRoteiro) + Space(12) + cTabela,nTipoErro})//ษverson - 13/09/2016, chamado 029242.
			
		EndIf
		
		nBytes := fRead(nHdl,@cBuffer,nTamLin) // Le uma linha
		
	EndDo
	
	//Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para gera็ใo de frete no faturamento
	If lGeraCrg
		If Len(aCargaFt) > 0
			ConOut('Inicio StartJob para Gera็ใo de Carga')
				//StartJob( "U_ADLOG049P" , GetEnvServer() , .F. , cEmpAnt , cFilAnt , aCargaFt )
				MsAguarde( {|| U_ADLOG049P(cEmpAnt , cFilAnt , aCargaFt ) }, "Aguarde", "Gerando cargas..." ) //Everson-23/05/2019-Ch:044314.
			ConOut('Fim StartJob para Gera็ใo de Carga')
		Endif
	Endif

	
	//log de fim de importa็ใo de pedidos roteirizados
	u_GrLogZBE (Date(),TIME(),cUserName," FINAL IMPORTACAO PED.VENDAS","LOGISTICA","IMPORTARPV","ROADNET - IMPORTAR-PEDIDOS",ComputerName(),LogUserName()) 
	
	If Len(aLinhaErro) > 0	// Deseja imprimir o relat๓rio de erros gerados na importa็ใo?
		If Msgbox("Deseja imprimir o relat๓rio de erros gerados na importa็ใo?", "IMPRDNET-001", "YESNO")
			wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
			
			If nLastKey == 27
				lRel := .F.
				
			Endif
			
			If lRel
				SetDefault(aReturn,cString)
			
			EndIf
			
			If nLastKey == 27
				lRel := .F.
				
			Endif
			
			If lRel
				nTipo := If(aReturn[4]==1,15,18)
				RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,aLinhaErro) },Titulo)
				
			EndIf
			
		Endif
		
	Endif
	
	//ษverson - 12/09/2016, chamado 029242.
	If Len(aDadosRoteiro) > 0 .And. MsgYesNo("Hแ " + cValToChar(Len(aDadosRoteiro)) + " roteiro(s) para ser(em) emplacado(s). Deseja efetuar o emplacamento automแtico?",;
												  "importarPV(IMPRDNET)")
		
		telaEmplacamento(aDadosRoteiro)
		
	EndIf
	//
	fClose(nHdl)//fechar o arquivo
				
Return Nil      

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,aLinhaErro)

	Local _nCaminha := 1
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	@ nLin,001 PSAY "A importa็ใo e o emplacamento automแtico nใo serใo realizados para os registros que possuem as ocorr๊ncias listadas abaixo: "
	nLin := nLin + 1 // Avanca a linha de impressao
	
	For _nCaminha := 1 To Len(aLinhaErro) //ษverson - 12/09/2016, chamado 029242.
	
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
			
		Endif
		
		If nLin > 64 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...		
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			
		Endif
		
		//If Substr(_cLinhalva, _nCaminha + 6, 1) = "f" .Or. Substr(_cLinhalva, _nCaminha + 7, 1) = "f"
		
			//@ nLin,001 PSAY Substr(_cLinhalva, _nCaminha, 6)  + Space(63) + ;
					   //"Imp. Pedidos - Pedido nใo encontrado!"
					   
			@ nLin,001 PSAY Alltrim(cValToChar(aLinhaErro[_nCaminha][1])) +;
			 Space(30) + Iif(aLinhaErro[_nCaminha][2] == 2,"Imp. Pedidos - Pedido nใo encontrado!","") //ษverson - 12/09/2016, chamado 029242.
			 
			nLin := nLin + 1 // Avanca a linha de impressao
			
		//Endif
		
	Next _nCaminha
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
	
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtelaEmplacamento  บ Autor ณ Everson    บ Data ณ  13/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para sele็ใo dos roteiros que serใo emplacados      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function telaEmplacamento(aDadosRoteiro)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oTelaRotas
	Local oMark
	Local i			:= 1
	Local w			:= 1
	Local aDados		:= {}
	
	Local cRotaDe 	:= ""
	Local cRotaAte	:= ""
	Local cTaFrt		:= ""
	Local cDescTa		:= ""
	Local cTiFrt		:= ""
	Local cDescTi		:= ""
	Local nReg			:= 0
	
	Private cMark   	:= GetMark()   
	Private lInverte 	:= .F.
	Private _stru		:= {}
	Private aCpoBro	:= {}
	Private _carq
	
	If Len(aDadosRoteiro) <= 0
		Return Nil
		
	EndIf
	
	Aadd(_stru,{"OK" 		   ,"C",02,0})
	Aadd(_stru,{"TMP_DATA"  ,"C",10,0})
	Aadd(_stru,{"TMP_ROT"   ,"C",10,0})
	Aadd(_stru,{"TMP_PLACA" ,"C",08,0})
	Aadd(_stru,{"TMP_TBFRT" ,"C",04,0})
	Aadd(_stru,{"TMP_DSTA"  ,"C",30,0})
	Aadd(_stru,{"TMP_TIFRT" ,"C",04,0})
	Aadd(_stru,{"TMP_DSTI"  ,"C",30,0})
	
	//Cria arquivo temporแrio.
	_carq := "T_" + Criatrab(,.F.)
	MsCreate(_carq,_stru,"DBFCDX")
	Sleep(1000)
	
	//Atribui a tabela temporแria ao alias TRB.
	DbUseArea(.T.,"DBFCDX",_carq,"TTEMP",.T.,.F.)
	
	//Define quais colunas (campos da TTEMP) serao exibidas na MsSelect.
	Aadd(aCpoBro,{"OK"			,, ""})		
	Aadd(aCpoBro,{"TMP_DATA"		,,"Data Entrega"})		
	Aadd(aCpoBro,{"TMP_ROT"		,,"Roteiro"})
	Aadd(aCpoBro,{"TMP_PLACA"	,,"Veํculo"})	
	Aadd(aCpoBro,{"TMP_TBFRT" 	,,"Tabela Frete"})
	Aadd(aCpoBro,{"TMP_DSTA"  	,,"Desc. Tabela"})
	Aadd(aCpoBro,{"TMP_TIFRT" 	,,"Tipo Frete"})
	Aadd(aCpoBro,{"TMP_DSTI"  	,,"Desc. Tipo"})
	
	//Obt้m dados de parโmetros.
	aDados := dadosParametros("EA")
	
	//Preenche o arquivo temporแrio.
	DbSelectArea("TTEMP")
	
	For i := 1 To Len(aDadosRoteiro)
	
		If Empty(Alltrim(cValToChar(aDadosRoteiro[i][1])))
			MsgAlert("Por favor, verifique o roteiro " + Alltrim(cValToChar(aDadosRoteiro[i][3])) +;
			 		  ", pois nใo hแ veํculo definido para o mesmo.","Fun็ใo telaEmplacamento(IMPRDNET)")
			
		EndIf
		
		nReg := 0
		
		For w := 1 To Len(aDados)
			
			//Roteiro
			If Alltrim(cValToChar(aDadosRoteiro[i][3])) >= Alltrim(cValToChar(aDados[w][1])) .And.;
			   Alltrim(cValToChar(aDadosRoteiro[i][3])) <= Alltrim(cValToChar(aDados[w][2]))
				
				cRotaDe 	:= aDados[w][1]
				cRotaAte	:= aDados[w][2]
				cTaFrt		:= aDados[w][3]
				cDescTa	:= aDados[w][4]
				cTiFrt		:= aDados[w][5]
				cDescTi	:= aDados[w][6]
				
				nReg++
				
			EndIf
			
		Next w
		
		//Valida se hแ tabela de frete e tipo de frete para a rota.
		If nReg == 0
			MsgAlert("Por favor, verifique o roteiro " + Alltrim(cValToChar(aDadosRoteiro[i][3])) + ",pois nใo hแ tabela de frete e/ou tipo de frete para o mesmo.",;
					 "Fun็ใo telaEmplacamento(IMPRDNET)")
		
		EndIf
		
		RecLock("TTEMP",.T.)		
			TTEMP->OK				:= cMark
			TTEMP->TMP_DATA		:= DToC(CToD(cValToChar(aDadosRoteiro[i][2])))
			TTEMP->TMP_ROT 		:= Alltrim(cValToChar(aDadosRoteiro[i][3]))
			TTEMP->TMP_PLACA		:= Alltrim(cValToChar(aDadosRoteiro[i][1]))
			TTEMP->TMP_TBFRT		:= cTaFrt
			TTEMP->TMP_DSTA		:= cDescTa
			TTEMP->TMP_TIFRT		:= cTiFrt
			TTEMP->TMP_DSTI		:= cDescTi
		MsunLock()
		
	
	Next i
		
	Define MsDialog oTelaRotas Title "Processamento da Rotina de Emplacamento" From 000, 000  To 400, 950 COLORS 0, 16777215 Pixel Style 128
		
	@ 006, 130 Say oSay1 PROMPT "Serใo gerados os emplacamentos para as rotas selecionadas abaixo. Deseja prosseguir?" Size 300, 014 Of oTelaRotas COLORS 0, 16777215 Pixel
			
	oMark := MsSelect():New("TTEMP","OK","",aCpoBro ,@lInverte,@cMark ,{017,003,170,475},,,oTelaRotas,,)
	Eval(oMark:oBrowse:bGoTop)
	oMark:oBrowse:Refresh()
	
	@ 180, 006 Button oButton2 PROMPT "Editar Roteiro"  Size 060, 013 Of oTelaRotas Action (editarRota(oMark)) Pixel
	@ 180, 360 Button oButton2 PROMPT "Ok"       		   Size 048, 013 Of oTelaRotas Action (oTelaRotas:End(),Processa({||OK_Emplacamento()} ,"Processando","Aguarde...")) Pixel
	@ 180, 420 Button oButton3 PROMPT "Cancelar" 		   Size 048, 013 Of oTelaRotas Action (oTelaRotas:End()) Pixel
    
  	Activate MsDialog oTelaRotas Centered
  	
	//Fecha alias.
  	If Select("TTEMP") > 0
  		TTEMP->(DbCloseArea())
  	
  	EndIf
	
	//Apaga arquivo temporแrio.
	Iif(File(_carq + GetDBExtension()),FErase(_carq  + GetDBExtension()) ,Nil)
	
	MsgInfo("Processamento finalizado.","Fun็ใo telaEmplacamento(IMPRDNET)")

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณeditarRota   บ Autor ณ Everson    บ Data ณ  15/09/16   		บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para edi็ใo de rota na MSSelect                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function editarRota(oMark)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oEdicao
	
	Local oPlaca
	Local cPlaca	:= Alltrim(cValToChar(TTEMP->TMP_PLACA)) + Space(8)
	
	Local oCodTab	
	Local cCodTab	:= Alltrim(cValToChar(TTEMP->TMP_TBFRT))
	
	Local oDestino
	Local cDestino:= Alltrim(cValToChar(TTEMP->TMP_DSTA)) + Space(30)
	
	Local oTipoFrt
	Local cTipoFrt := Alltrim(cValToChar(TTEMP->TMP_TIFRT))
	
	Local oDescFrt
	Local cDescFrt := Alltrim(cValToChar(TTEMP->TMP_DSTI)) + Space(30)
	
	DbSelectArea("TTEMP")
	
	Define MsDialog oEdicao Title "Edi็ใo de Roteiro" From (235),(480) To (470),(919) Pixel Style 128
	
		@ (002),(001) To (090),(218) Label "Dados do roteiro" Pixel Of oEdicao
		
		@ (010),(004) Say "Roteiro               Entrega                                         " Size (193),(008) COLOR CLR_BLACK Pixel Of oEdicao
		@ (020),(005) Say Alltrim(cValToChar9(TTEMP->TMP_ROT))											Size (018),(008) COLOR CLR_RED   Pixel Of oEdicao
		@ (020),(045) Say CToD(cValToChar(TTEMP->TMP_DATA))												Size (032),(008) COLOR CLR_RED   Pixel Of oEdicao
		
		@ (040),(005) Say "Placa:" 																			Size (017),(008) COLOR CLR_BLACK Pixel Of oEdicao
		@ (040),(037) MsGet oPlaca 	 Var cPlaca   Valid U_UfPlaca(cPlaca) F3 "A05"					Size (030),(009) COLOR CLR_BLACK Pixel Of oEdicao
		@ (040),(082) MsGet oCodTab  Var cCodTab  Valid ExistCpo("ZV8",cCodTab) F3 "ZV8"				Size (040),(009) COLOR CLR_BLACK Pixel Of oEdicao
		@ (040),(127) MsGet oDestino Var cDestino Valid ! Empty(cDestino)							    Size (090),(009) COLOR CLR_BLACK Pixel Of oEdicao When .F.
		
		@ (060),(005) Say "Tipo de Frt:" 																   Size (035),(008) COLOR CLR_BLACK Pixel Of oEdicao
		@ (060),(037) MsGet oTipoFrt Var cTipoFrt Valid ExistCpo("SZH" ,cTipoFrt) F3 "SZH"  		Size (030),(009) COLOR CLR_BLACK Pixel Of oEdicao
		@ (060),(082) MsGet oDescFrt Var cDescFrt Valid ! Empty(cDescFrt)								Size (135),(009) COLOR CLR_BLACK Pixel Of oEdicao When .F.
		
		Define SButton From (100),(150) Type 1 Enable Of oEdicao Action (Ok_Edicao(oEdicao,oMark,cPlaca,cCodTab,cDestino,cTipoFrt,cDescFrt))
		Define SButton From (100),(185) Type 2 Enable Of oEdicao Action (oEdicao:End())
	
	Activate MsDialog oEdicao Centered
	
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOk_Edicao   บ Autor ณ Everson    บ Data ณ  15/09/16         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo de confirma็ใo de edi็ใo de roteiro                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Ok_Edicao(oEdicao,oMark,cPlaca,cCodTab,cDestino,cTipoFrt,cDescFrt)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	:= GetArea("TTEMP")
	
	//Remove espa็os em branco.
	cPlaca 	:= Alltrim(cValToChar(cPlaca))
	cCodTab	:= Alltrim(cValToChar(cCodTab))
	cDestino	:= Alltrim(cValToChar(cDestino))
	cTipoFrt	:= Alltrim(cValToChar(cTipoFrt))
	cDescFrt	:= Alltrim(cValToChar(cDescFrt))
	
	//Verifica os argumentos da fun็ใo.
	If Empty(cPlaca) .Or. Empty(cCodTab) .Or. Empty(cDestino) .Or. Empty(cTipoFrt) .Or. Empty(cDescFrt)
		MsgStop("Por favor, reveja se todos os campos estใo preenchidos.","Fun็ใo Ok_Edicao(IMPRDNET)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Grava novos dados informados.
	DbSelectArea("TTEMP")
	RecLock("TTEMP",.F.)
		TTEMP->TMP_PLACA		:= cPlaca
		TTEMP->TMP_TBFRT		:= cCodTab
		TTEMP->TMP_DSTA		:= cDestino
		TTEMP->TMP_TIFRT		:= cTipoFrt
		TTEMP->TMP_DSTI		:= cDescFrt
	MsUnlock()
	
	//Refresh MSSelect.
	oMark:oBrowse:Refresh()
	
	//Fecha janela de edi็ใo.
	oEdicao:End()
	
	RestArea(aArea)

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOK_Emplacamento   บ Autor ณ Everson    บ Data ณ  13/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo de confirma็ใo do emplacamento                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function OK_Emplacamento()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local nTotRot	:= 0
	Local nAux		:= 1

	DbSelectArea("TTEMP")
	TTEMP->(DbGoTop())
	
	//Obt้m o total de registros.
	nTotRot := Contar("TTEMP","!Eof() .And. ! Empty(TTEMP->OK)")
	
	//Atribui a quantidade de registros เ r้gua de processamento.
	ProcRegua(nTotRot)
	
	TTEMP->(DbGoTop())
	While ! TTEMP->(Eof())
		
		If ! Empty(TTEMP->OK)
		
			//Incrementa a r้gua de processamento.
			IncProc("Processando Roteiro " + Alltrim(cValToChar(TTEMP->TMP_ROT)) + " (" + cValtoChar(nAux) + "/" + cValToChar(nTotRot) + ").") 
		
			If Empty(Alltrim(cValToChar(TTEMP->TMP_PLACA))) .Or. Empty(Alltrim(cValToChar(TTEMP->TMP_DATA))) .Or.;
			Empty(Alltrim(cValToChar(TTEMP->TMP_ROT))) .Or. Empty(Alltrim(cValToChar(TTEMP->TMP_TBFRT))) .Or. Empty(Alltrim(cValToChar(TTEMP->TMP_TIFRT)))
				
				MsgStop("Hแ dados nใo definidos para o roteiro abaixo. O emplacamento nใo poderแ ser efetuado." + Chr(13) + Chr(10) +;
				"Roteiro: "         + Alltrim(cValToChar(TTEMP->TMP_ROT))   + "" + Chr(13) + Chr(10) +;
				"Placa: "           + Alltrim(cValToChar(TTEMP->TMP_PLACA)) + "" + Chr(13) + Chr(10) +;
				"Dt. Entrega: "     + DToC(SToD(cValToChar(TTEMP->TMP_DATA)))     + "" + Chr(13) + Chr(10) +;
				"Tabela de frete: " + Alltrim(cValToChar(TTEMP->TMP_TBFRT)) + "" + Chr(13) + Chr(10) +;
				"Tipo de frete: "   + Alltrim(cValToChar(TTEMP->TMP_TIFRT)) + "" + Chr(13) + Chr(10) ,"Fun็ใo OK_Emplacamento(IMPRDNET)")
				
			Else
			
				//Gera o emplacamento.
				gerarGravaDados(TTEMP->TMP_PLACA, CToD(cValToChar(TTEMP->TMP_DATA)), TTEMP->TMP_ROT, TTEMP->TMP_TBFRT, TTEMP->TMP_TIFRT)
				
				nAux++
				
			EndIf
			
		EndIf
		
		TTEMP->(DbSkip())
		
	EndDo

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgerarGravaDados   บ Autor ณ Everson    บ Data ณ  12/09/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para emplacamento no momento da importa็ใo do       บฑฑ
ฑฑบ          ณ arquivo de retorno no RoadNet.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ  Chamado 029242                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function gerarGravaDados(cPlaca, dDataEntrega, cRoteiro, cTabFrt, cTipoFrt)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea	 	:= GetArea()
	Local cContMsg	:= " Serแ necessแrio efetuar o emplacamento manual."
	Local cGuia	 	:= Space(6)
	Local cCodigo		:= ""
	Local cDestino 	:= ""
	Local cDescFrt	:= ""

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Remove espa็os em branco.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	cPlaca		:= Alltrim(cValToChar(cPlaca))
	cRoteiro 	:= Alltrim(cValToChar(cRoteiro))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida placa informada.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	If ! U_UfPlaca(cPlaca) //Fun็ใo disponํvel no fonte AD0055.
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida argumentos da fun็ใo.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	If Empty(cPlaca)
		MsgStop("Fun็ใo nใo recebeu a placa do veํculo." + cContMsg,"Fun็ใo gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
		
	ElseIf Empty(Alltrim(cValToChar(dDataEntrega)))
		MsgStop("Fun็ใo nใo recebeu a data de entrega dos pedidos." + cContMsg,"Fun็ใo gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
		
	ElseIf Empty(cRoteiro)
		MsgStop("Fun็ใo nใo recebeu o n๚mero do roteiro." + cContMsg,"Fun็ใo gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Obt้m o c๓digo da tabela de frete.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cCodigo := cTabFrt
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Obt้m a descri็ใo da tabela de frete.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cDestino := Posicione("ZV8",1,xFilial("ZV8") + cCodigo, "ZV8_CIDADE")
	cDestino := Alltrim(cValToChar(cDestino))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida o retorno da fun็ใo Posicione.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty(cDestino)
		MsgStop("Nใo foi possํvel obter a descria็ใo da tabela de frete referente ao c๓digo " + cCodigo + "." + cContMsg,;
		"Fun็ใo gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
				
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Obt้m a descri็ใo do tipo de frete.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cDescFrt := Posicione("SZH",1,xFilial("SZH") + cTipoFrt, "ZH_DESCRIC")
	cDescFrt := Alltrim(cValToChar(cDescFrt))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida o retorno da fun็ใo Posicione.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty(cDescFrt)
		MsgStop("Nใo foi possํvel obter a descria็ใo do tipo de frete referente ao c๓digo " + cTipoFrt + "." + cContMsg,;
		"Fun็ใo gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
				
	EndIf	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Utilizada a fun็ใo estแtica GravaPLACA disponํvel no fonte AD0055.PRW.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If Empty(Alltrim(cValToChar(cPlaca))) .Or. Empty(Alltrim(cValToChar(cCodigo))) .Or.;
	   Empty(Alltrim(cValToChar(cDestino))) .Or. Empty(Alltrim(cValToChar(cTipoFrt))) .Or.;
	   Empty(Alltrim(cValToChar(cRoteiro))) .Or. Empty(Alltrim(cValToChar(dDataEntrega))) .Or. Empty(Alltrim(cValToChar(cDescFrt)))
		MsgStop("Fun็ใo gerarGravaDados nใo recebeu todos os argumentos.","Fun็ใo gerarGravaDados(IMPRDNET)")
		
	Else
		StaticCall(AD0055,GravaPLACA,cPlaca,cCodigo,cDestino,cTipoFrt,cRoteiro,cGuia,dDataEntrega,cDescFrt,.F.,.T.)
	
	EndIf
	
	RestArea(aArea)
	
Return Nil
