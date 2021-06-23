#INCLUDE "Protheus.ch"
#INCLUDE "Report.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "FWCommand.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "MntTRCell.ch"

Static nQtdePerg		:= 7
Static nTamFil			:= 0

/*/{Protheus.doc} User Function nomeFunction
	Relat�rio com o banco intermedi�rio com as tabelas
	OPR/REQ , MOV , INV.
	@type  Function
	@author Michel Fernandes
	@since 12/12/2016
	@version 01
	@history Everson, 04/09/2020, Chamado 1018. Tratamento para filtrar os registros por empresa.
	/*/
User function ADFIS016R() // U_ADFIS016R()

	Local cPerg			:= "ADFIS016R"
	Local ni			:= 0
	Local lTROk			:= .F.
	Local aFuncAux		:= {"MntTRCell","GravaSX1","FecArTMP"}
	Local cSession		:= ""
	Local nOrientation	:= 0

	//���������������������Ŀ
	//�Celulas da secao 01  �
	//����������������������� 
	//						CAMPO			TIPO	TAMANHO		TITULO						ALINHA	 PICT				OCULTA	QUEBRA	AUTODIM	BOLD
	Local aCabSGOPR010	:={	{"FILIAL"		,"C"	,2			,"Filial do Lan�amento"		,""		,					,.F.	,		,.T.},;
							{"PRODUTO"		,"C"	,15			,"C�digo do Produto"		,""		,					,.F.	,		,.T.},;
							{"DESCRICAO"	,"C"	,30			,"Descria��o do Produto"	,""		,					,.F.	,		,.T.},;
							{"QUANT"		,"N"	,12			,"Quantidade Produzida"		,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"OP"			,"C"	,10			,"Ordem de Produ��o"		,""		,					,.F.	,		,.T.},;
							{"LOCAL"		,"C"	,3			,"Local"					,""		,					,.F.	,		,.T.},;
							{"CUSTO"		,"N"	,12			,"Custo"					,""		,					,.F.	,		,.T.},;
							{"DATA"			,"C"	,10			,"Data de Movimenta��o"		,""		,					,.F.	,		,.T.},;
							{"TIPO"			,"C"	,3			,"Tipo de Movimenta��o"		,""		,					,.F.	,		,.T.},;
							{"REQOPR"		,"N"	,12			,"REQ/OPR"					,""		,					,.F.	,		,.T.} }
									
	Local aCabSGMOV010	:={	{"D3_FILIAL"		,"C"	,2			,"Filial do Lan�amento"		,""		,					,.F.	,		,.T.},;
							{"D3_TM"			,"C"	,3			,"Tipo de Movimenta��o"		,""		,					,.F.	,		,.T.},;
							{"PRODUTO"			,"C"	,15			,"C�digo do Produto"		,""		,					,.F.	,		,.T.},;
							{"DESCRICAO"		,"C"	,30			,"Descria��o do Produto"	,""		,					,.F.	,		,.T.},;
							{"D3_QUANT"			,"N"	,12			,"Quantidade Movimentada"	,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"D3_LOCAL"			,"C"	,2			,"Unidade PROTHEUS"			,""		,					,.F.	,		,.T.},;
							{"D3_CC"			,"C"	,10			,"Data do Movimento"		,""		,					,.F.	,		,.T.},;
							{"D3_OP"			,"C"	,10			,"Lote Aglutinado Edata"	,""		,					,.F.	,		,.T.},;
							{"D3_NUMSEQ"		,"C"	,8			,"Campo Exporta��o"			,""		,					,.F.	,		,.T.},;
							{"D3_CUSTO1"		,"N"	,12			,"Quantidade Movimentada"	,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"D3_PARCTOT"		,"C"	,8			,"D3_PARCTOT"				,""		,					,.F.	,		,.T.},;
							{"D3_EMISSAO"		,"C"	,10			,"Data do Movimento"		,""		,					,.F.	,		,.T.},;
							{"STATUS"			,"C"	,1			,"Status Integra��o"		,""		,					,.F.	,		,.T.},;
							{"OPERACAO"			,"C"	,1			,"Opera��o Integra��o"		,""		,					,.F.	,		,.T.} }
						
	Local aCabSGINV010	:={	{"B7_FILIAL"		,"C"	,2			,"Filial do Lan�amento"		,""		,					,.F.	,		,.T.},;
							{"PRODUTO"			,"C"	,15			,"C�digo do Produto"		,""		,					,.F.	,		,.T.},;
							{"DESCRICAO"		,"C"	,30			,"Descria��o do Produto"	,""		,					,.F.	,		,.T.},;
							{"B7_DOC"			,"C"	,9			,"Documento de Invent�rio"	,""		,					,.F.	,		,.T.},;
							{"B7_QUANT"			,"N"	,12			,"Quantidade Inventariada"	,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"B7_DATA"			,"C"	,10			,"Data do Invent�rio"		,""		,					,.F.	,		,.T.},;
							{"B7_LOCAL"			,"C"	,8			,"Campo Exporta��o"			,""		,					,.F.	,		,.T.} }

	Private aAlias		:= {"OPR","MOV","INV"}
	Private cRotina		:= "[" + StrTran(ProcName(0),"U_","") + "] "
	Private cNomeUs		:= ""
	Private oReport
	Private oSection1  
	Private _cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97()) // Banco do Protheus
	Private _cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97()) 
	Private _cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
	Private _cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97()) // Banco Intermediario 
	Private _cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	Private _cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))   

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relat�rio com o banco intermedi�rio com as tabelas OPR/REQ , MOV , INV.')
		
	//Montar o grupo de perguntas
	ADEDA008SX1(cPerg)
	
	If !Pergunte(cPerg,.T.)
		Return Nil
	EndIf
	
	If mv_par01 <> 4
		#IFNDEF TOP
			MsgAlert(cNomeUs + ", este relat�rio exige que o banco de dados seja relacional!")
			Return Nil
		#ENDIF                                  
		
		nTamFil	:= IIf(FindFunction("FWSizeFilial"),FWSizeFilial(),2)
		cNomeUs	:= Capital(AllTrim(UsrRetName(__cUserID)))
		lTROk	:= IIf(FindFunction("TRepInUse"),TRepInUse(),.F.)
		
		If !lTROk
			MsgAlert(cNomeUs + ", este relat�rio exige que esteja ativo o suporte a impress�o no modelo 4!")
			Return Nil
		Endif
		
		For ni := 1 to Len(aFuncAux)
			If !ExistBlock(aFuncAux[ni])
				MsgAlert(cNomeUs + ", a fun��o " + StrTran(aFuncAux[ni],"U_","") + " necess�ria para a execu��o desta rotina, n�o pode ser encontrada!")
				Return Nil
			Endif
		Next ni
		
		
		cSession := GetPrinterSession()
		nOrientation := IIf(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.) == "PORTRAIT",1,2)
		
		//������������������������Ŀ
		//�Interface de impressao  �
		//��������������������������
		If ADEDA008Def( cPerg,nOrientation, IIF(mv_par01==1, aCabSGOPR010, IIF(mv_par01==2, aCabSGMOV010, aCabSGINV010)) ) .AND. ValType(oReport) == "O"
			oReport:PrintDialog()
		Endif
	Else
		Processa( {|| GerarArq( aCabSGOPR010, aCabSGMOV010, aCabSGINV010 )}, "Relat�rio Pr�-processamento", "Processando arquivo, aguarde...", .F. )
	EndIf
		
Return
/*/{Protheus.doc} ADEDA008Def
	Cria o cabe�alho e as configura��es do layout do relat�rio.
	cPerg		:	Nome do grupo de perguntas                  
	nOrienta	:	Orienta��o do layout do relat�rio   
	@type  Static Function
	@author Leonardo Rios
	@since 04/11/2015
	@version 01
	/*/
Static Function ADEDA008Def(cPerg,nOrienta, aCab)

	Local cTitulo			:= OemToAnsi("Relat�rio")

	PARAMTYPE 0	VAR cPerg		AS Character	OPTIONAL	DEFAULT ""
	PARAMTYPE 1	VAR nOrienta	AS Numeric		OPTIONAL	DEFAULT 1

	//��������������������Ŀ
	//�Dados do relatorio  �
	//����������������������
	oReport := tReport():New(U_RemCarac(cRotina,{"[","]"," "}),cTitulo,cPerg,{|oReport| ADEDA008Imp(oReport,cPerg,aCab)})

	//��������������������������������������Ŀ
	//�Definicoes do relatorio e parametros  �
	//����������������������������������������
	oReport:lParamPage := .T.
	oReport:lPrtParamPage := .F.
	oReport:ParamReadOnly(.F.)
	oReport:ShowParamPage()
	oReport:SetLandscape()
	oReport:nFontBody := 7
	oReport:nLineHeight := 40
	oReport:DisableOrientation(.F.)
	oReport:SetTotalInLine(.F.)
	oReport:PageTotalInLine(.F.)

	//��������������������Ŀ
	//�Dados do secao 01   �
	//����������������������
	oSection1 := tRSection():New(oReport,cTitulo,,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,/*uTotalText*/,/*lTotalInLine*/,.F./*lHeaderPage*/)
	oSection1:SetLineStyle(.F.)
	U_MntTRCell(@oSection1,aCab,.T.)

Return .T.
/*/{Protheus.doc} ADEDA008Imp
	Rotina para geracao e montagem de dados do relatorio para 	 
	impressao                                                    
	Exp01[O] : Objeto do relatorio                               
	Exp02[C] : Grupo de perguntas                                
	Exp04[C] : Nome da filial de destino                         
			   				�Michel Fernandes	� Data �13/12/16 
	 Inclus�o de op��o de tratamento da tabela REQ junto com OPR  
	@type  Static Function
	@author Leonardo Rios
	@since 04/11/2015
	@version 01
	/*/
Static Function ADEDA008Imp(oReport,cPerg,aCab)

	Local nTotREG		:= 0
	Local nz			:= 0
	Local aErros		:= {}
	Local cErro			:= ""
	Local cAliasT		:= GetNextAlias()
	Local cAlias		:= GetNextAlias()

	PARAMTYPE 0	VAR oReport		AS Object		OPTIONAL	DEFAULT Nil
	PARAMTYPE 1	VAR cPerg		AS Character	OPTIONAL	DEFAULT ""
	PARAMTYPE 2	VAR cAliasT		AS Character	OPTIONAL	DEFAULT ""
	PARAMTYPE 3	VAR aCab		AS Array		OPTIONAL	DEFAULT Array(0)

	If (Empty(ALLTRIM(DTOS(mv_par02))) .OR. mv_par02 == Nil) .AND. (Empty(ALLTRIM(DTOS(mv_par03))) .OR. mv_par03 == Nil)
		AADD(aErros, "N�o � permitido as perguntas dos per�odos estarem vazias!")
	EndIf

	If (Empty(ALLTRIM(mv_par04)) .OR. mv_par04 == Nil) .AND. (Empty(ALLTRIM(mv_par05)) .OR. mv_par05 == Nil)
		AADD(aErros, "N�o � permitido as perguntas dos produtos estarem vazias!")
	EndIf

	For nz := 1 To Len(aErros)
		cErro += aErros[nz] + Chr(13) + Chr(10)
	Next nz 

	If !Empty(ALLTRIM(cErro))
		MsgAlert("Problemas", cErro)
		Return Nil
	EndIf

	// TcConType("TCPIP")
	// If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
	// 	_lRet     := .F.
	// 	cMsgError := "N�o foi poss�vel  conectar ao banco Protheus"
	// 	MsgInfo("N�o foi poss�vel  conectar ao banco produ��o, verifique com administrador","ERROR")	
	// EndIf

	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	_lRet     := .F.
	// 	cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
	// 	MsgInfo("N�o foi poss�vel  conectar ao banco integra��o, verifique com administrador","ERROR")	
	// EndIf
		
	// //TcSetConn(_nTcConn2)

	oSection1:BeginQuery()

	//���������������������������������������������������������������������������������Ŀ
	//�	Fun��o que selecionara a query de acordo com o mv_par01 escolhido pelo usu�rios �
	//�����������������������������������������������������������������������������������

	ADORXQry(@cAliasT,@cAlias, mv_par01)

	oSection1:EndQuery() 

	(cAliasT)->(dbGoTop())
	Eval({|| nTotREG := 0,(cAliasT)->(dbEval({|| nTotREG++})),(cAliasT)->(dbGoTop())})

	oReport:SetMeter(nTotREG)
	oReport:nMeter := 0

	oReport:SetMeter((cAliasT)->(RecCount()))

	If (cAliasT)->(Eof())
		
		If Select(cAliasT) > 0
			dbSelectArea(cAliasT)
			(cAliasT)->(dbCloseArea())
		EndIf
		
		Return Nil
	Else
		
		//�����������Ŀ
		//�Impressao  �
		//�������������
		oSection1:Init()
		
		Do While !(cAliasT)->(Eof())

			oReport:IncMeter()
			
			For x:=1 To Len(aCab)
				cValue := ""
				If aCab[x,1] == "STATUS"
					cValue := (cAliasT)->&(aCab[x,1])
					DO CASE
						CASE cValue == "I"
							oSection1:Cell(aCab[x,1]):SetValue( "Integrado" )
						CASE cValue == "P"
							oSection1:Cell(aCab[x,1]):SetValue( "Processado" )
						CASE cValue == "E"
							oSection1:Cell(aCab[x,1]):SetValue( "Erro" )
						OTHERWISE
							oSection1:Cell(aCab[x,1]):SetValue( "" )
					ENDCASE
					
				ElseIf aCab[x,1] == "OPERACAO"
					cValue := (cAliasT)->&(aCab[x,1])
					DO CASE
						CASE cValue == "I"
							oSection1:Cell(aCab[x,1]):SetValue( "Inclus�o" )
						CASE cValue == "A"
							oSection1:Cell(aCab[x,1]):SetValue( "Altera��o" )
						CASE cValue == "E"
							oSection1:Cell(aCab[x,1]):SetValue( "Exclus�o" )
						OTHERWISE
							oSection1:Cell(aCab[x,1]):SetValue( "" )
					ENDCASE

				ElseIf aCab[x,1] == "DESCRICAO"
					//TcSetConn(_nTcConn1)
				
					SB1->(DbSetOrder(1))				
					If SB1->(DBSeek( xFilial("SB1") + (cAliasT)->PRODUTO ))
						oSection1:Cell(aCab[x,1]):SetValue( SB1->B1_DESC )
					Else
						oSection1:Cell(aCab[x,1]):SetValue( "" )
					EndIf
					
					//TcSetConn(_nTcConn2)

				Elseif aCab[x,1] == "REQOPR"
					oSection1:Cell(aCab[x,1]):SetValue( "Produc�o" )

				Elseif aCab[x,1] == "TIPO" .OR. aCab[x,1] == "DATA"
					oSection1:Cell(aCab[x,1]):SetValue( "" )

				Else
					oSection1:Cell(aCab[x,1]):SetValue( (cAliasT)->&(aCab[x,1]) )
				EndIf
				
			Next x
					
			oSection1:PrintLine()
			
			//�����������������������������������������������������������������������������������Ŀ
			//�	Caso seja escolhido a tabela OPR, ser� chamado mais um alias relacionado a tabela �
			//�	REQ e enviado para a fun��o que ir� tratar os valores para ser imprimido 		  �
			//�������������������������������������������������������������������������������������
			If  mv_par01 == 1

				ADORXQry(@cAliasT,@cAlias,6)
				ADFIS016R1(cAlias,aCab)
			Endif
			
			(cAliasT)->(dbSkip())

		EndDo

		oSection1:Finish()
			
	Endif

	//TcUnLink(_nTcConn1)
	//TcUnLink(_nTcConn2)

	oReport:SkipLine()
	U_FecArTMP(cAliasT)

Return Nil
/*/{Protheus.doc} GerarArq
	Inclus�o de op��o de tratamento da tabela REQ junto com OPR
	@type  Static Function
	@author Michel Fernandes
	@since 13/12/2016
	@version 01
	/*/
Static Function GerarArq(aCabSGOPR010, aCabSGMOV010, aCabSGINV010)

	Local oFwMsEx 	:= NIL

	Local cArq		:= ""
	Local cDir 		:= GetSrvProfString("Startpath","")
	Local cDirTmp 	:= GetTempPath()
	Local aTabelas 	:= {{1, "OPR", "Produ��o"}, {2, "MOV", "Movimenta��o"}, {3, "INV", "Invent�rio"}}
	Local aCabs		:= {aCabSGOPR010, aCabSGMOV010, aCabSGINV010}
	Local cAliasT	:= GetNextAlias()
	Local cAlias	:= GetNextAlias()
	Local aItens	:= {}

	Default aCabSGOPR010:= {}
	Default aCabSGMOV010:= {}
	Default aCabSGINV010:= {}

		oFwMsEx := FWMsExcel():New()
		
		For z:=1 To Len(aTabelas)
			cAliasT	:= GetNextAlias()
			
			oFwMsEx:AddWorkSheet( aTabelas[z,2] )
			oFwMsEx:AddTable( aTabelas[z,2], aTabelas[z,3] )
			
			For x:=1 To Len(aCabs[z])
				oFwMsEx:AddColumn( aTabelas[z,2], aTabelas[z,3], aCabs[z,x,4], 1, 1)
			Next x

			// TcConType("TCPIP")
			// If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
			// 	_lRet     := .F.
			// 	cMsgError := "N�o foi poss�vel  conectar ao banco Protheus"
			// 	MsgInfo("N�o foi poss�vel  conectar ao banco produ��o, verifique com administrador","ERROR")	
				
			// 	Return Nil
			// EndIf
			
			// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
			// 	_lRet     := .F.
			// 	cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
			// 	MsgInfo("N�o foi poss�vel  conectar ao banco integra��o, verifique com administrador","ERROR")	
				
			// 	Return Nil
			// EndIf
				
			//TcSetConn(_nTcConn2)
			
			ADORXQry(@cAliasT,, aTabelas[z,1])

			(cAliasT)->(dbGoTop())
			
			//�����������Ŀ
			//�Impressao  �
			//�������������
			Do While !(cAliasT)->(Eof())
				aItens := {}
				
				For y:=1 To Len(aCabs[z])
					

					If aCabs[z,y,1] == "STATUS"
						cValue := (cAliasT)->STATUS
						DO CASE
							CASE cValue == "I"
								AADD(aItens,  "Integrado" )
							CASE cValue == "P"
								AADD(aItens,  "Processado" )
							CASE cValue == "E"
								AADD(aItens,  "Erro")
							OTHERWISE
								AADD(aItens,  "" )
						ENDCASE
						
					ElseIf aCabs[z,y,1] == "OPERACAO"
						cValue := (cAliasT)->OPERACAO
						DO CASE
							CASE cValue == "I"
								AADD(aItens,  "Inclus�o" )
							CASE cValue == "A"
								AADD(aItens,  "Altera��o" )
							CASE cValue == "E"
								AADD(aItens,  "Exclus�o" )
							OTHERWISE
								AADD(aItens,  "" )
						ENDCASE				
					
					
					ElseIf aCabs[z,y,1] == "DESCRICAO"
					
						//TcSetConn(_nTcConn1)

						SB1->(DbSetOrder(1))				
						If SB1->(DBSeek( xFilial("SB1") + (cAliasT)->PRODUTO ))
							AADD(aItens, SB1->B1_DESC )
						Else
							AADD(aItens, "" )
						EndIf
						
						//TcSetConn(_nTcConn2)
					Elseif aCabs[z,y,1]== "REQOPR"
						AADD(aItens,  "Produc�o" )
					
					Elseif aCabs[z,y,1] == "DATA" .OR. aCabs[z,y,1] == "TIPO"
						AADD(aItens,  "" )
					Else
						AADD(aItens,  (cAliasT)->&(aCabs[z,y,1]) )
					EndIf				
					
				Next y
				
				oFwMsEx:AddRow( aTabelas[z,2], aTabelas[z,3], aItens )
			
			//�����������������������������������������������������������������������������������Ŀ
			//�	Caso seja a tabela OPR, ser� chamado mais um alias relacionado a tabela REQ		  �
			//�	e enviado para a fun��o que ir� tratar os valores para ser inclu�do no arquivo	  �
			//�������������������������������������������������������������������������������������		    
				If  aTabelas[z,2] == "OPR" 
					ADORXQry(@cAliasT,@cAlias,6)
					ADFIS016R2(cAlias,aTabelas,aItens,aCabs,oFwMsEx)		       	
				Endif
				(cAliasT)->(dbSkip())
		
			EndDo
			
			//TcUnLink(_nTcConn1)
			//TcUnLink(_nTcConn2)
			
			U_FecArTMP(cAliasT)
					
		Next z
		
	//	cArq := CriaTrab( NIL, .F. ) + ".xml"
		cArq := "ADEDA008R.xml"
	//	LjMsgRun( "Gerando o arquivo, aguarde...", "Relat�rio Pr�-Processamento", {|| oFwMsEx:GetXMLFile( cArq ) } )
		oFwMsEx:Activate()
		oFwMsEx:GetXMLFile(cArq)
		If __CopyFile( cArq, cDirTmp + cArq )
			If ApOleClient("MsExcel")
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( cDirTmp + cArq )
				oExcelApp:SetVisible(.T.)
			Else
				MsgInfo( "Arquivo " + cArq + " gerado com sucesso no diret�rio " + cDirTmp )
			Endif
		Else
			MsgInfo( "Arquivo n�o copiado para tempor�rio do usu�rio." )
		Endif

Return
/*/{Protheus.doc} GerarArq
	Query do relat�rio   
	@type  Static Function
	@author Michel Fernandes
	@since 13/12/2016
	@version 01
	/*/
Static Function ADORXQry(cAliasT,cAlias, nOpc)

	Local cSTATUS 	:= ""
	Local cOPERACAO	:= ""
	Local nOP		:= 0 

	DO CASE
		CASE mv_par07 == 1
			cOPERACAO := "I"
		CASE mv_par07 == 2
			cOPERACAO := "A"
		OTHERWISE
			cOPERACAO := "E"
	ENDCASE

	If nOpc == 1

		DO CASE
			CASE mv_par06 == 1
				cSTATUS := "% C2_MSEXP = ' ' %"
			CASE mv_par06 == 2
				cSTATUS := "% SGOPR010.STATUS_INT = 'S' AND SGOPR010.C2_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% SGOPR010.STATUS_INT = 'E' AND SGOPR010.C2_MSEXP <> ' ' %"
		ENDCASE
			
		BeginSQL Alias cAliasT
			SELECT C2_FILIAL AS FILIAL, C2_PRODUTO AS PRODUTO, C2_QUANT AS QUANT, C2_NUM+C2_ITEM+C2_SEQUEN AS OP, C2_LOCAL AS LOCAL
			FROM SGOPR010		
			WHERE C2_EMISSAO BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%
			AND C2_PRODUTO BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%		
			AND OPERACAO_INT = %Exp:cOPERACAO%
			AND EMPRESA = %Exp:cEmpAnt% //Everson - 04/09/2020. Chamado 1018.
			AND %Exp:cSTATUS%
			AND D_E_L_E_T_ = ' '
		EndSQL
		
	ElseIf nOpc == 2

		DO CASE
			CASE mv_par06 == 1
				cSTATUS := "% D3_MSEXP = ' ' %"
			CASE mv_par06 == 2
				cSTATUS := "% SGMOV010.STATUS_INT = 'S' AND D3_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% SGMOV010.STATUS_INT = 'E' AND D3_MSEXP <> ' ' %"
		ENDCASE

		BeginSQL Alias cAliasT
		
			SELECT D3_FILIAL,D3_TM,D3_COD AS PRODUTO,D3_QUANT,D3_LOCAL,D3_CC,D3_OP,D3_NUMSEQ,D3_CUSTO1,D3_PARCTOT,R_E_C_N_O_,CODIGENE,
				(SUBSTRING(D3_EMISSAO,7,2)+'/'+SUBSTRING(D3_EMISSAO,5,2)+'/'+SUBSTRING(D3_EMISSAO,1,4)) AS D3_EMISSAO, STATUS_INT AS STATUS, OPERACAO_INT AS OPERACAO
			FROM SGMOV010
			WHERE D3_EMISSAO BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%
			AND D3_COD BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
			AND OPERACAO_INT = %Exp:cOPERACAO%
			AND EMPRESA = %Exp:cEmpAnt% //Everson - 04/09/2020. Chamado 1018.
			AND %Exp:cSTATUS%
			AND D_E_L_E_T_ = ' '
		EndSQL
		
	ElseIf nOpc == 3

		DO CASE
			CASE mv_par06 == 1
				cSTATUS := "% B7_MSEXP = ' ' %"
			CASE mv_par06 == 2
				cSTATUS := "% SGINV010.STATUS_INT = 'S' AND B7_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% SGINV010.STATUS_INT = 'E' AND B7_MSEXP <> ' ' %"
		ENDCASE

		BeginSQL Alias cAliasT
			SELECT B7_FILIAL, B7_COD AS PRODUTO, B7_QUANT, B7_LOCAL, 
				(SUBSTRING(B7_DOC,7,2)+'/'+SUBSTRING(B7_DOC,5,2)+'/'+SUBSTRING(B7_DOC,1,4)) AS B7_DOC, 
				(SUBSTRING(B7_DATA,7,2)+'/'+SUBSTRING(B7_DATA,5,2)+'/'+SUBSTRING(B7_DATA,1,4)) AS B7_DATA
			FROM SGINV010		
			WHERE B7_DATA BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%
				AND B7_COD BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
				AND OPERACAO_INT = %Exp:cOPERACAO%
				AND EMPRESA = %Exp:cEmpAnt% //Everson - 04/09/2020. Chamado 1018.
				AND %Exp:cSTATUS%
				AND D_E_L_E_T_ = ' '
		EndSQL
		
	Elseif nOpc == 6

		DO CASE
			CASE mv_par06 == 1
				cSTATUS := "% D3_MSEXP = ' ' %"
			CASE mv_par06 == 2
				cSTATUS := "% SGREQ010.STATUS_INT = 'S' AND SGREQ010.D3_MSEXP <> ' ' %"
			OTHERWISE
				cSTATUS := "% SGREQ010.STATUS_INT = 'E' %" //AND SGREQ010.D3_MSEXP <> ' ' %"
		ENDCASE

		cAlias:= GetnextAlias()
		nOP := (cAliasT)->OP 
		BeginSQL Alias cAlias	
			SELECT D3_FILIAL AS FILIAL ,D3_COD AS PRODUTO, /*+ DESCRICAO*/ D3_QUANT AS QUANT, D3_OP AS OP, D3_LOCAL AS LOCAL, D3_CUSTO1 AS CUSTO, D3_EMISSAO AS DATA, D3_TM AS TIPO
			FROM SGREQ010		
			WHERE D3_EMISSAO BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%		
				AND D3_OP  = %Exp:nOP% 
				AND OPERACAO_INT = %Exp:cOPERACAO%
				AND %Exp:cSTATUS%
				AND EMPRESA = %Exp:cEmpAnt% //Everson - 04/09/2020. Chamado 1018.
				AND D_E_L_E_T_ = ' '
		EndSQL
	EndIf

	If nOpc == 6
		Return cAlias
	EndIf

Return cAliasT
/*/{Protheus.doc} GerarArq
	Rotina de cria��o dos registros da tabela REQ - Quando a op��o 
	do usu�rio � de imprimir apenas a tabela OPR.                  
	@type  Static Function
	@author Michel Fernandes
	@since 13/12/2016
	@version 01
	/*/
Static Function ADFIS016R1(cAlias,aCab)

	(cAlias)->(dbGoTop())
	Eval({|| nTotREG := 0,(cAlias)->(dbEval({|| nTotREG++})),(cAlias)->(dbGoTop())})
	
	oReport:SetMeter(nTotREG)
	oReport:nMeter := 0
	
	oReport:SetMeter((cAlias)->(RecCount()))
		
	If (cAlias)->(Eof())
		
		If Select(cAlias) > 0
			dbSelectArea(cAlias)
		    (cAlias)->(dbCloseArea())
		EndIf
		
		Return Nil
	Else
		
		//�����������Ŀ
		//�Impressao  �
		//�������������
		oSection1:Init()
		
		Do While !(cAlias)->(Eof())
	
			oReport:IncMeter()
			
			For x:=1 To Len(aCab)
				cValue := ""
							
				If aCab[x,1] == "DESCRICAO"
					//TcSetConn(_nTcConn1)
				
					SB1->(DbSetOrder(1))				
					If SB1->(DBSeek( xFilial("SB1") + (cAlias)->PRODUTO ))
						oSection1:Cell(aCab[x,1]):SetValue( SB1->B1_DESC )
					Else
						oSection1:Cell(aCab[x,1]):SetValue( "" )
					EndIf
					
					////TcSetConn(_nTcConn2)
				Elseif aCab[x,1]== "REQOPR"
					oSection1:Cell(aCab[x,1]):SetValue( "Requisic�o" )

				Elseif aCab[x,1] == "DATA"
					oSection1:Cell(aCab[x,1]):SetValue( DTOC( STOD( (cAlias)->&(aCab[x,1]) ) ) )

				Else				
					oSection1:Cell(aCab[x,1]):SetValue( (cAlias)->&(aCab[x,1]) )
				EndIf
				
		    Next x
		            
			oSection1:PrintLine()
		
			(cAlias)->(dbSkip())
	
		EndDo
	Endif

Return
/*/{Protheus.doc} GerarArq
	Rotina de cria��o dos registros da tabela REQ - Quando a op��o 
	do usu�rio � de imprimir todas as tabelas. 						                
	@type  Static Function
	@author Michel Fernandes
	@since 13/12/2016
	@version 01
	/*/
Static Function ADFIS016R2(cAlias,aTabelas,aItens,aCabs,oFwMsEx)

	(cAlias)->(dbGoTop())
			
			//�����������Ŀ
			//�Impressao  �
			//�������������
			Do While !(cAlias)->(Eof())
				aItens := {}
				
				For y:=1 To Len(aCabs[z])		
					
					If aCabs[z,y,1] == "DESCRICAO"
	                
						////TcSetConn(_nTcConn1)
	
						SB1->(DbSetOrder(1))				
						If SB1->(DBSeek( xFilial("SB1") + (cAlias)->PRODUTO ))
							AADD(aItens, SB1->B1_DESC )
						Else
							AADD(aItens, "" )
						EndIf
						
						////TcSetConn(_nTcConn2)
					Elseif aCabs[z,y,1]== "REQOPR"
						AADD(aItens, "Requisi��es" )

					Elseif aCabs[z,y,1] == "DATA"
						AADD(aItens,  DTOC( STOD( (cAlias)->&(aCabs[z,y,1]) ) ) )

					Else
						AADD(aItens,  (cAlias)->&(aCabs[z,y,1]) )
					EndIf							
					
			    Next y
			    oFwMsEx:AddRow( aTabelas[z,2], aTabelas[z,3], aItens )
			    
			    (cAlias)->(dbSkip())  
		Enddo

	(cAlias)-> (dbCloseArea())

Return 
/*/{Protheus.doc} GerarArq
	Rotina para ajuste do SX1 da rotina  						                
	@type  Static Function
	@author Leonardo Rios
	@since 04/11/2015
	@version 01
	/*/
Static Function ADEDA008SX1(cPerg)

	Local aMensSX1 := {}

	// //			 	PERGUNTA			 TIPO	TAM						   	DEC					OBJETO	PS	COMBO							  				SXG		F3		VALID	HELP
	// aMensHlp[01] := {"Tipo"				,"N"	,1							,00					,"C"	,0	,{"OPR/REQ","MOV","INV","Todos",""}	   				,""		,""	 	,""		,"Tipo de Consulta"}
	// aMensHlp[02] := {"Per�odo De"		,"D"	,8	 						,00					,"G"	,0	,{"","","","",""}				   				,""		,""	 	,""		,"Per�odo Inicial"}
	// aMensHlp[03] := {"Per�odo Ate"		,"D"	,8	 						,00					,"G"	,0	,{"","","","",""}				   				,""		,""	 	,""		,"Per�odo final"}
	// aMensHlp[04] := {"Produto De"		,"C"	,TamSX3("B2_COD")[1]		,00					,"G"	,0	,{"","","","",""}				   				,""		,"SB1"	,""		,"Produto inicial"}
	// aMensHlp[05] := {"Produto Ate"		,"C"	,TamSX3("B2_COD")[1]		,00					,"G"	,0	,{"","","","",""}								,""		,"SB1"	,""		,"Produto final"}
	// aMensHlp[06] := {"Status"			,"C"	,1							,00					,"C"	,0	,{"Integrado","Processado","Erro","",""}		,""		,""		,""		,"Status de Integra��o"}
	// aMensHlp[07] := {"Opera��o"	   		,"C"	,1							,00					,"C"	,0	,{"Inclus�o","Altera��o","Exclus�o","",""}		,""		,""		,""		,"Tipo de Opera��o"}

	// U_GravaSX1(cPerg,aMensHlp)



	//					1					2				3					4				5						6					7				8					9					10					11						12					13				14						15					16					17					18				19						20					21					22					23				24						25					26					27					28				29						30					31					32					33				34					35					36						37						38				39
		// AADD(/* 'X1_ORDEM' */, /* 'X1_PERGUNT'*/, /* 'X1_PERSPA' */, /* 'X1_PERENG' */, /* 'X1_TIPO' 	*/, /* 'X1_TAMANHO'*/, /* 'X1_DECIMAL'*/, /* 'X1_PRESEL' */, /* 'X1_GSC' 	*/, /* 'X1_VALID' 	*/	, /* 'X1_DEF01' 	*/, /* 'X1_DEFSPA1'*/, /* 'X1_DEFENG1'*/, /* 'X1_CNT01' 	*/, /* 'X1_VAR02' 	*/, /* 'X1_DEF02' 	*/, /* 'X1_DEFSPA2'*/, /* 'X1_DEFENG2'*/, /* 'X1_CNT02' 	*/, /* 'X1_VAR03' 	*/, /* 'X1_DEF03' 	*/, /* 'X1_DEFSPA3'*/, /* 'X1_DEFENG3'*/, /* 'X1_CNT03' 	*/, /* 'X1_VAR04' 	*/, /* 'X1_DEF04' 	*/, /* 'X1_DEFSPA4'*/, /* 'X1_DEFENG4'*/, /* 'X1_CNT04' 	*/, /* 'X1_VAR05' 	*/, /* 'X1_DEF05' 	*/, /* 'X1_DEFSPA5'*/, /* 'X1_DEFENG5'*/, /* 'X1_CNT05' 	*/, /* 'X1_F3'		*/, /* 'X1_PYME' 	*/, /* 'X1_GRPSXG' */	, /* 'X1_PICTURE'*/, /* 'X1_IDFIL' 	*/)

	//					  1				2						3						4				  5			6						  7	 8		  9   10	 11	   		12  		13	  	  	  14  	  15  	 16  	 		17   	  		18   	  	  19  	  20  21  	  	  22  	  	 23  	  	  24  25  26  		27  	28  	  29  30  31  32  33  34  35      36   37  38  39	
    AADD( aMensSX1, {"01", "Tipo?"				, "Tipo?"				, "Tipo?"					,"N"	,001						,00, 0		,"C", ""	,"OPR"		,"OPR" 		,"OPR"		, ""	, ""	, "MOV"			, "MOV" 	 , "MOV"		, ""	, "", "INV"		, "INV"		, "INV" 	, "", "", "Todos", "Todos", "Todos"	, "", "", "", "", "", "", ""    , "S", "", "", "" })
    AADD( aMensSX1, {"02", "Per�odo De?"		, "Per�odo De?"			, "Per�odo De?"				,"D"	,008						,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"03", "Per�odo Ate?"		, "Per�odo Ate?"		, "Per�odo Ate?"	    	,"D"	,008						,00, 0		,"G", ""	,""			,""			,""			, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"04", "Produto De?"		, "Produto De?"	    	, "Produto De?"		   		,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 		 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", "SB1" , "S", "", "", "" })
	AADD( aMensSX1, {"05", "Produto Ate?"		, "Produto Ate?"		, "Produto Ate?"			,"C"	,TamSX3("B1_COD")[1]		,00, 0		,"G", ""	,""			,""			,"" 		, ""	, ""	, ""			, "" 	 	 , "" 			, ""	, "", ""		, ""		, ""		, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", "SB1" , "S", "", "", "" })
	AADD( aMensSX1, {"06", "Status?"			, "Status?"				, "Status?"	    			,"C"	,001						,00, 0		,"C", ""	,"Integrado","Integrado","Integrado", ""	, ""	, "Processado" 	,"Processado", "Processado"	, ""	, "", "Erro"	, "Erro"	, "Erro"	, "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	AADD( aMensSX1, {"07", "Opera��o?"			, "Opera��o?"			, "Lista C�lculo ?"	    	,"C"	,001						,00, 0		,"C", ""	,"Inclus�o"	,"Inclus�o"	,"Inclus�o"	, ""	, ""	, "Altera��o" 	,"Altera��o" , "Altera��o"	, ""	, "", "Exclus�o", "Exclus�o", "Exclus�o", "", "", ""	 , ""	  , ""		, "", "", "", "", "", "", ""    , "S", "", "", "" })
	

    U_newGrSX1(cPerg, aMensSX1)	



Return Nil
