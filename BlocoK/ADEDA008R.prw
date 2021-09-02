#INCLUDE "Protheus.ch"
#INCLUDE "Report.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "FWCommand.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "MntTRCell.ch"

Static nQtdePerg		:= 7
Static nTamFil			:= 0

/*/{Protheus.doc} User Function ADEDA008R
	(long_description)
	@type  Function
	@author Leonardo Rios
	@since 04/11/2015
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
    @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa��o/Beneficiamento
/*/
User Function ADEDA008R()

	Local cPerg			:= "ADEDA008R"
	Local ni			:= 0
	Local lTROk			:= .F.
	Local aFuncAux		:= {"MntTRCell","GravaSX1","FecArTMP"}
	Local cSession		:= ""
	Local nOrientation	:= 0

	//����������������������?
	//�Celulas da secao 01  ?
	//����������������������?
	//						CAMPO			TIPO	TAMANHO		TITULO						ALINHA	 PICT				OCULTA	QUEBRA	AUTODIM	BOLD
	Local aCabOPR010	:={	{"FILIAL"		,"C"	,2			,"Filial do Lan�amento"		,""		,					,.F.	,		,.T.},;
							{"PRODUTO"		,"C"	,15			,"C�digo do Produto"		,""		,					,.F.	,		,.T.},;
							{"DESCRICAO"	,"C"	,30			,"Descria��o do Produto"	,""		,					,.F.	,		,.T.},;
							{"QUANT"		,"N"	,12			,"Quantidade Produzida"		,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"UNITPROTH"	,"C"	,2			,"Unidade PROTHEUS"			,""		,					,.F.	,		,.T.},;
							{"DATA"			,"C"	,10			,"Data de Produ��o"			,""		,					,.F.	,		,.T.},;
							{"OPEDATA"		,"N"	,10			,"Ordem de Produ��o EDATA"	,""		,"@E 999,999,999"	,.F.	,		,.T.},;
							{"MSEXP"		,"C"	,8			,"Campo Exporta��o"			,""		,					,.F.	,		,.T.},;
							{"STATUS"		,"C"	,1			,"Status Integra��o"		,""		,					,.F.	,		,.T.},;
							{"OPERACAO"		,"C"	,1			,"Opera��o Integra��o"		,""		,					,.F.	,		,.T.},;
							{"MSG"			,"C"	,100		,"Mensagem Integra��o"		,""		,					,.F.	,		,.T.},;
							{"REC"			,"N"	,10			,"Num Registro"				,""		,					,.F.	,		,.T.},;
							{"LOCAL"	    ,"C"	,6		    ,"Armaz�m Terceiro"		    ,""		,					,.F.	,		,.T.},;
                            {"PRODUCAO"		,"C"	,1		    ,"Pr�prio/Terceiro"		    ,""		,					,.F.	,		,.T.} ;
                            						}
	Local aCabMOV010	:={	{"FILIAL"		,"C"	,2			,"Filial do Lan�amento"		,""		,					,.F.	,		,.T.},;
							{"TM"			,"C"	,3			,"Tipo de Movimenta��o"		,""		,					,.F.	,		,.T.},;
							{"TMDESC"		,"C"	,30			,"Descri��o Tp Movimenta��o",""		,					,.F.	,		,.T.},;
							{"PRODUTO"		,"C"	,15			,"C�digo do Produto"		,""		,					,.F.	,		,.T.},;
							{"DESCRICAO"	,"C"	,30			,"Descria��o do Produto"	,""		,					,.F.	,		,.T.},;
							{"QUANT"		,"N"	,12			,"Quantidade Movimentada"	,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"UNITPROTH"	,"C"	,2			,"Unidade PROTHEUS"			,""		,					,.F.	,		,.T.},;
							{"DATA"			,"C"	,10			,"Data do Movimento"		,""		,					,.F.	,		,.T.},;
							{"LOTEEDATA"	,"C"	,10			,"Lote Aglutinado Edata"	,""		,					,.F.	,		,.T.},;
							{"MSEXP"		,"C"	,8			,"Campo Exporta��o"			,""		,					,.F.	,		,.T.},;
							{"STATUS"		,"C"	,1			,"Status Integra��o"		,""		,					,.F.	,		,.T.},;
							{"OPERACAO"		,"C"	,1			,"Opera��o Integra��o"		,""		,					,.F.	,		,.T.},;
							{"MSG"			,"C"	,100		,"Mensagem Integra��o"		,""		,					,.F.	,		,.T.},; 
							{"REC"			,"N"	,10			,"Num Registro"				,""		,					,.F.	,		,.T.} ;
						}
	Local aCabINV010	:={	{"FILIAL"		,"C"	,2			,"Filial do Lan�amento"		,""		,					,.F.	,		,.T.},;
							{"PRODUTO"		,"C"	,15			,"C�digo do Produto"		,""		,					,.F.	,		,.T.},;
							{"DESCRICAO"	,"C"	,30			,"Descria��o do Produto"	,""		,					,.F.	,		,.T.},;
							{"DOC"			,"C"	,9			,"Documento de Invent�rio"	,""		,					,.F.	,		,.T.},;
							{"QUANT"		,"N"	,12			,"Quantidade Inventariada"	,""		,"@E 999,999,999.99",.F.	,		,.T.},;
							{"UNITPROTH"	,"C"	,2			,"Unidade PROTHEUS"			,""		,					,.F.	,		,.T.},;
							{"DATA"			,"C"	,10			,"Data do Invent�rio"		,""		,					,.F.	,		,.T.},;
							{"MSEXP"		,"C"	,8			,"Campo Exporta��o"			,""		,					,.F.	,		,.T.},;
							{"STATUS"		,"C"	,1			,"Status Integra��o"		,""		,					,.F.	,		,.T.},;
							{"OPERACAO"		,"C"	,1			,"Opera��o Integra��o"		,""		,					,.F.	,		,.T.},;
							{"MSG"			,"C"	,100		,"Mensagem Integra��o"		,""		,					,.F.	,		,.T.},;
							{"REC"			,"N"	,10			,"Num Registro"				,""		,					,.F.	,		,.T.} ;
						}

	Private aAlias		:= {"OPR","MOV","INV"}
	Private cRotina		:= "[" + StrTran(ProcName(0),"U_","") + "] "
	Private cNomeUs		:= ""
	Private oReport
	Private oSection1

	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
	/*
	Private _cNomBco1  := GetPvProfString("INTEDTBD","BCO1","ERROR",GetADV97())
	Private _cSrvBco1  := GetPvProfString("INTEDTBD","SRV1","ERROR",GetADV97())
	Private _cPortBco1 := Val(GetPvProfString("INTEDTBD","PRT1","ERROR",GetADV97()) )
	Private _cNomBco2  := GetPvProfString("INTEDTBD","BCO2","ERROR",GetADV97())
	Private _cSrvBco2  := GetPvProfString("INTEDTBD","SRV2","ERROR",GetADV97())
	Private _cPortBco2 := Val(GetPvProfString("INTEDTBD","PRT2","ERROR",GetADV97()))
	Private _nTcConn1  := AdvConnection()
	Private _nTcConn2  := 0
	*/

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
	/*
	If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
		_lRet     := .F.
		cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
		MsgInfo("N�o foi poss�vel  conectar ao banco integra��o, verifique com administrador","ERROR")	
	EndIf

	TcSetConn(_nTcConn1) //fernando sigoli 01/05/2018
	*/
		
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
			//�Interface de impressao  ?
			//��������������������������
			If ADEDA008Def( cPerg,nOrientation, IIF(mv_par01==1, aCabOPR010, IIF(mv_par01==2, aCabMOV010, aCabINV010)) ) .AND. ValType(oReport) == "O"
				oReport:PrintDialog()
			Endif
		Else
			Processa( {|| GerarArq( aCabOPR010, aCabMOV010, aCabINV010 )}, "Relat�rio Pr?processamento", "Processando arquivo, aguarde...", .F. )
		EndIf

Return Nil

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ADEDA008Def  �Autor  �Leonardo Rios		?Data ?4/11/15     ��?
����������������������������������������������������������������������������͹��
���Desc.     �Cria o cabe�alho e as configura��es do layout do relat�rio     ��?
����������������������������������������������������������������������������͹��
���Parametros?									                         ��?
��			 �cPerg		:	Nome do grupo de perguntas                       ��?
��			 �nOrienta	:	Orienta��o do layout do relat�rio                ��?
����������������������������������������������������������������������������͹��
���Uso       �Adoro			                                                 ��?
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ADEDA008Def(cPerg,nOrienta, aCab)

    Local cTitulo			:= OemToAnsi("Relat�rio")

    PARAMTYPE 0	VAR cPerg		AS Character	OPTIONAL	DEFAULT ""
    PARAMTYPE 1	VAR nOrienta	AS Numeric		OPTIONAL	DEFAULT 1

    //��������������������Ŀ
    //�Dados do relatorio  ?
    //����������������������
    oReport := tReport():New(U_RemCarac(cRotina,{"[","]"," "}),cTitulo,cPerg,{|oReport| ADEDA008Imp(oReport,cPerg,aCab)})

    //��������������������������������������Ŀ
    //�Definicoes do relatorio e parametros  ?
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
    //�Dados do secao 01   ?
    //����������������������
    oSection1 := tRSection():New(oReport,cTitulo,,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,/*uTotalText*/,/*lTotalInLine*/,.F./*lHeaderPage*/)
    oSection1:SetLineStyle(.F.)
    U_MntTRCell(@oSection1,aCab,.T.)

Return .T.

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa  �ADEDA008Imp  �Autor  �Leonardo Rios	    ?Data ?4/11/15     ��?
����������������������������������������������������������������������������͹��
���Desc.     �Rotina para geracao e montagem de dados do relatorio para 	 ��?
��?         �impressao                                                      ��?
����������������������������������������������������������������������������͹��
���Parametros�Exp01[O] : Objeto do relatorio                                 ��?
��?         �Exp02[C] : Grupo de perguntas                                  ��?
��?         �Exp04[C] : Nome da filial de destino                           ��?
����������������������������������������������������������������������������͹��
���Uso       �Adoro	  	                                                     ��?
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ADEDA008Imp(oReport,cPerg,aCab)

    Local nTotREG		:= 0
    Local nz			:= 0
    Local aErros		:= {}
    Local cErro			:= ""
    Local cAliasT		:= GetNextAlias()

    PARAMTYPE 0	VAR oReport		AS Object		OPTIONAL	DEFAULT Nil
    PARAMTYPE 1	VAR cPerg		AS Character	OPTIONAL	DEFAULT ""
    PARAMTYPE 2	VAR cAliasT		AS Character	OPTIONAL	DEFAULT ""
    PARAMTYPE 3	VAR aCab		AS Array		OPTIONAL	DEFAULT Array(0)

    If (Empty(ALLTRIM(DTOS(mv_par02))) .OR. mv_par02 == Nil) .AND. (Empty(ALLTRIM(DTOS(mv_par03))) .OR. mv_par03 == Nil)
        AADD(aErros, "N�o ?permitido as perguntas dos per�odos estarem vazias!")
    EndIf

    If (Empty(ALLTRIM(mv_par04)) .OR. mv_par04 == Nil) .AND. (Empty(ALLTRIM(mv_par05)) .OR. mv_par05 == Nil)
        AADD(aErros, "N�o ?permitido as perguntas dos produtos estarem vazias!")
    EndIf

    For nz := 1 To Len(aErros)
        cErro += aErros[nz] + Chr(13) + Chr(10)
    Next nz 

    If !Empty(ALLTRIM(cErro))
        MsgAlert("Problemas", cErro)
        Return Nil
    EndIf

    //TcSetConn(_nTcConn2) // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA

    //��������������������������������������������������������?
    //?												      ?
    //��������������������������������������������������������?
    oSection1:BeginQuery()

    ADORXQry(@cAliasT, mv_par01)

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
        
        //������������?
        //�Impressao  ?
        //������������?
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
                    //TcSetConn(_nTcConn1)// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
                
                    SB1->(DbSetOrder(1))				
                    If SB1->(DBSeek( xFilial("SB1") + (cAliasT)->PRODUTO ))
                        oSection1:Cell(aCab[x,1]):SetValue( SB1->B1_DESC )
                    Else
                        oSection1:Cell(aCab[x,1]):SetValue( "" )
                    EndIf
                    
                    //TcSetConn(_nTcConn2)// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
                    
                ElseIf aCab[x,1] == "UNITPROTH"
                    //TcSetConn(_nTcConn1)// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
                
                    oSection1:Cell(aCab[x,1]):SetValue( ConvUM( (cAliasT)->PRODUTO, (cAliasT)->QUANT, 0, 2) )

                    //TcSetConn(_nTcConn2)// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
                
                Else
                    /* se for a tabela de movimenta��es MOV010 (mv_par == 2) */
                    If mv_par01 == 2 .AND. aCab[x,1] == "TMDESC"
                        
                        //TcSetConn(_nTcConn1)// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
                        
                        SF5->(DbSetOrder(1))
                        If SF5->( DbSeek( xFilial("SF5") + ALLTRIM((cAliasT)->TM) ) )
                            oSection1:Cell(aCab[x,1]):SetValue( SF5->F5_TEXTO )
                        Else
                            oSection1:Cell(aCab[x,1]):SetValue( "" )
                        EndIf
                        
                        //TcSetConn(_nTcConn2)// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
                    Else
                        oSection1:Cell(aCab[x,1]):SetValue( (cAliasT)->&(aCab[x,1]) )	
                    EndIf 
                    
                EndIf
                
            Next x
                    
            oSection1:PrintLine()
            
            (cAliasT)->(dbSkip())

        EndDo

        oSection1:Finish()
        
        
    Endif

    // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
    /*
    TcUnLink(_nTcConn1)
    TcUnLink(_nTcConn2)
    */

    oReport:SkipLine()
    U_FecArTMP(cAliasT)

Return Nil

/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �GerarArq  �Autor  �Microsiga           ?Data ? 12/15/15   ��?
�������������������������������������������������������������������������͹�?
���Desc.     ?                                                           ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       �ADEDA008R                                                    ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Static Function GerarArq(aCabOPR010, aCabMOV010, aCabINV010)

    Local oFwMsEx 	:= NIL

    Local cArq		:= ""
    Local cDir 		:= GetSrvProfString("Startpath","")
    Local cDirTmp 	:= GetTempPath()
    Local aTabelas 	:= {{1, "OPR", "Produ��o"}, {2, "MOV", "Movimenta��o"}, {3, "INV", "Invent�rio"}}
    Local aCabs		:= {aCabOPR010, aCabMOV010, aCabINV010}
    Local cAliasT	:= GetNextAlias()
    Local aItens	:= {}

    Default aCabOPR010:= {}
    Default aCabMOV010:= {}
    Default aCabINV010:= {}

	oFwMsEx := FWMsExcel():New()
	
	For z:=1 To Len(aTabelas)
		cAliasT	:= GetNextAlias()
		
		oFwMsEx:AddWorkSheet( aTabelas[z,2] )
	    oFwMsEx:AddTable( aTabelas[z,2], aTabelas[z,3] )
	    
	    For x:=1 To Len(aCabs[z])
		    oFwMsEx:AddColumn( aTabelas[z,2], aTabelas[z,3], aCabs[z,x,4], 1, 1)
		Next x

		// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
		/*
		TcConType("TCPIP")
		If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
			_lRet     := .F.
			cMsgError := "N�o foi poss�vel  conectar ao banco Protheus"
			MsgInfo("N�o foi poss�vel  conectar ao banco produ��o, verifique com administrador","ERROR")	
			
			Return Nil
		EndIf
		
		If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
			_lRet     := .F.
			cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
			MsgInfo("N�o foi poss�vel  conectar ao banco integra��o, verifique com administrador","ERROR")	
			
			Return Nil
		EndIf
		     
		TcSetConn(_nTcConn2)
		*/
		
//		cAliasT := ADORXQry(@cAliasT, aTabelas[z,1])
		ADORXQry(@cAliasT, aTabelas[z,1])
		
		(cAliasT)->(dbGoTop())
		
		//������������?
		//�Impressao  ?
		//������������?
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
                
					//TcSetConn(_nTcConn1) // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA

					SB1->(DbSetOrder(1))				
					If SB1->(DBSeek( xFilial("SB1") + (cAliasT)->PRODUTO ))
						AADD(aItens, SB1->B1_DESC )
					Else
						AADD(aItens, "" )
					EndIf
					
					//TcSetConn(_nTcConn2) // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA

				ElseIf aCabs[z,y,1] == "UNITPROTH"
					//TcSetConn(_nTcConn1) // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
				
					AADD(aItens,  ConvUM( (cAliasT)->PRODUTO, (cAliasT)->QUANT, 0, 2) )
					
					//TcSetConn(_nTcConn2) // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
					
				Else
					
					/* Se for a tabela MOV010 (z == 2)*/
					If z == 2 .AND. aCabs[z,y,1] == "TMDESC"
						//TcSetConn(_nTcConn1) // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
	
						SF5->(DbSetOrder(1))				
						If SF5->( DbSeek( xFilial("SF5") + ALLTRIM((cAliasT)->TM) ) )
							AADD(aItens, SF5->F5_TEXTO )
						Else
							AADD(aItens, "" )
						EndIf
						
						//TcSetConn(_nTcConn2)					 // @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
					
					Else
						AADD(aItens,  (cAliasT)->&(aCabs[z,y,1]) )
					EndIf
				EndIf				
				
		    Next y
		    
		    oFwMsEx:AddRow( aTabelas[z,2], aTabelas[z,3], aItens )
		    
			(cAliasT)->(dbSkip())
	
		EndDo
		
		// @history ticket 12048 - Fernando Macieira - 07/04/2021 - Revis�o das integra��es e gera��o das OPS - Banco DBINTEREDATA
		/*
		TcUnLink(_nTcConn1)
		TcUnLink(_nTcConn2)
		*/
		
		U_FecArTMP(cAliasT)
				
	Next z
	
//	cArq := CriaTrab( NIL, .F. ) + ".xml"
	cArq := "ADEDA008R.xml"
//	LjMsgRun( "Gerando o arquivo, aguarde...", "Relat�rio Pr?Processamento", {|| oFwMsEx:GetXMLFile( cArq ) } )
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

/*
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
�������������������������������������������������������������������������ͻ�?
���Programa  �ADORXQry  �Autor  �Microsiga           ?Data ? 12/15/15   ��?
�������������������������������������������������������������������������͹�?
���Desc.     �Query do relat�rio                                          ��?
��?         ?                                                           ��?
�������������������������������������������������������������������������͹�?
���Uso       �ADEDA008R                                                    ��?
�������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������?
����������������������������������������������������������������������������?
*/
Static Function ADORXQry(cAliasT, nOpc)

    Local cCampos 	:= "*"
    Local cSTATUS 	:= ""
    Local cOPERACAO	:= ""

    DO CASE
        CASE mv_par06 == 1
            cSTATUS := "I"
        CASE mv_par06 == 2
            cSTATUS := "S"
        OTHERWISE
            cSTATUS := "E"
    ENDCASE

    DO CASE
        CASE mv_par07 == 1
            cOPERACAO := "I"
        CASE mv_par07 == 2
            cOPERACAO := "A"
        OTHERWISE
            cOPERACAO := "E"
    ENDCASE

    If nOpc == 1

        BeginSQL Alias cAliasT

            //SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, OPEDATA, MSEXP, STATUS, OPERACAO, MSG, REC
            SELECT FILIAL, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, OPEDATA, MSEXP, STATUS, OPERACAO, MSG, REC, LOCAL, PRODUCAO // @history ticket 11639 - Fernando Macieira - 26/05/2021 - Projeto - OPS Documento de entrada - Industrializa��o/Beneficiamento
            FROM OPR010 (NOLOCK)
            WHERE DATA BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%
                AND PRODUTO BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
                AND STATUS = %Exp:cSTATUS%
                AND OPERACAO = %Exp:cOPERACAO%
                AND D_E_L_E_T_=''

        EndSQL
        
    ElseIf nOpc == 2

        BeginSQL Alias cAliasT

            SELECT FILIAL, TM, PRODUTO, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, LOTEEDATA, MSEXP, STATUS, OPERACAO, MSG, REC, '' LOCAL, '' PRODUCAO
            FROM MOV010 (NOLOCK)
            WHERE DATA BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%
                AND PRODUTO BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
                AND STATUS = %Exp:cSTATUS%
                AND OPERACAO = %Exp:cOPERACAO%
                AND D_E_L_E_T_=''

        EndSQL
        
    ElseIf nOpc == 3

        BeginSQL Alias cAliasT

            SELECT FILIAL, PRODUTO, DOC, QUANT, (SUBSTRING(DATA,7,2)+'/'+SUBSTRING(DATA,5,2)+'/'+SUBSTRING(DATA,1,4)) AS DATA, MSEXP, STATUS, OPERACAO, MSG, REC, '' LOCAL, '' PRODUCAO
            FROM INV010 (NOLOCK)
            WHERE DATA BETWEEN %Exp:mv_par02% AND %Exp:mv_par03%
                AND PRODUTO BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
                AND STATUS = %Exp:cSTATUS%
                AND OPERACAO = %Exp:cOPERACAO%
                AND D_E_L_E_T_=''

        EndSQL

    EndIf

Return cAliasT

/*
����������������������������������������������������������������������������������?
����������������������������������������������������������������������������������?
�������������������������������������������������������������������������������ͻ�?
���Programa  �ADEDA008SX1  �Autor  �Leonardo Rios	 	?Data ?4/11/2015      ��?
�������������������������������������������������������������������������������͹�?
���Desc.     �Rotina para ajuste do SX1 da rotina                               ��?
�������������������������������������������������������������������������������͹�?
���Parametros?                                                                 ��?
��			 ?cPerg	:	Nome do grupo das perguntas                         ��?
�������������������������������������������������������������������������������͹�?
���Uso       �Adoro	 	                                                        ��?
�������������������������������������������������������������������������������ͼ�?
����������������������������������������������������������������������������������?
����������������������������������������������������������������������������������?
*/
Static Function ADEDA008SX1(cPerg)

    Local aMensSX1 := {}

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
