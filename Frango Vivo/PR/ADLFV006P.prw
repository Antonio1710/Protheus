#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"
Static cTitulo := "Tabela de Fretes"
Static cEst	  := Nil

/*/{Protheus.doc} User Function ADLFV006P
    (long_description)
    @type  Function
    @author Everson
    @since 11/03/2019
    @version 01
    @history Everson, 14/03/2019, Ch: 044314 valida��o de campo obrigat�rio.
    @history Everson, 08/08/2019, Ch: 044314 tratamento para cria��o de tabela de frete por regi�o.
    @history Everson, 09/08/2019, Ch: 044314 adicionado tratamento para frete exporta��o.
    @history Everson, 17/02/2020, Ch: 054941 tratamento para informar km rodado quando a tabela for por regi�o ou regi�o x produto.
    @history Everson, 01/02/2022. Chamado 65860.  Adicionado novo c�lculo de frete.
    @history Everson, 02/02/2022. Chamado 66403.  Adicionado para exportar dados em XLS.
    @history Adriano Savoine, 14/03/2022. Ticket: 68841 Adicionado bloquei as a��es de Inclus�o, Alterar e excluir.
    /*/
User Function ADLFV006P()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������
    Local aArea		:= GetArea()
    Local oBrowse	:= Nil

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')
     
    //
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZF5")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
    
    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} MenuDef
    Menu MVC. Chamado 044314.
    @type  Static Function
    @author Everson
    @since 11/03/2019
    @version 01
    /*/
Static Function MenuDef()
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������
    Local aRot    := {}
    Local cCodUsr := RetCodUsr()
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'U_ADLF6_8()'       OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //Adriano Savoine, 14/03/2022. Ticket: 68841 
    IF cCodUsr $ SuperGetMV("MV_#USUFRT",.F.,"000000")
        ADD OPTION aRot TITLE 'Incluir'    ACTION 'U_ADLF6_1()'       OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
        ADD OPTION aRot TITLE 'Alterar'    ACTION 'U_ADLF6_6()'		  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
        ADD OPTION aRot TITLE 'Excluir'    ACTION 'U_ADLF6_7()'		  OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ENDIF

Return aRot
/*/{Protheus.doc} User Function ADLF6_1
    Inclus�o de registro. Chamado 044314.
    @type  Function
    @author Everson
    @since 06/08/2019
    @version 01
    /*/
User Function ADLF6_1()
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea := GetArea()

    U_ADINF009P('ADLFV006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')
    
    //
    If ! Pergunte("ADLF61",.T.)
    	RestArea(aArea)
    	Return Nil
    	
    EndIf
    
    //
    FWExecView("",'ADLFV006P', 3, , { || .T. }, , , , , , , ModelDef() )

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} User Function ADLF6_6
    Altera��o de registro. Chamado 044314. 
    @type  Function
    @author Everson
    @since 06/08/2019
    @version 01
    /*/
User Function ADLF6_6()
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea := GetArea()

    U_ADINF009P('ADLFV006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')
    
    //
    FWExecView("",'ADLFV006P', 4, , { || .T. }, , , , , , , ModelDef() )

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} User Function ADLF6_7
    Exclus�o de registro. Chamado 044314. 
    @type  Function
    @author Everson
    @since 06/08/2019
    @version 01
    /*/
User Function ADLF6_7()
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea := GetArea()

    U_ADINF009P('ADLFV006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')
    
    //
    FWExecView("",'ADLFV006P', 5, , { || .T. }, , , , , , , ModelDef() )

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} User Function ADLF6_8
    Visualiza��o de registro. Chamado 044314.
    @type  Function
    @author Everson
    @since 06/08/2019
    @version 01
    /*/
User Function ADLF6_8()
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea := GetArea()

    U_ADINF009P('ADLFV006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')
    
    //
    FWExecView("",'ADLFV006P', 1, , { || .T. }, , , , , , , ModelDef() )

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} ModelDef
    Modelo MVC. Chamado 044314. 
    @type  Static Function
    @author Everson 
    @since 11/03/2019
    @version 01
    /*/
Static Function ModelDef()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������
	Local oModel	:= Nil
    Local oStPai	:= FWFormStruct(1, 'ZF5')
    Local oStFilho	:= FWFormStruct(1, 'ZF6')
    Local aZF6Rel	:= {}
    Local bPosVal	:= {|oModel| ADLFVP01(oModel)}
    Local cValid	:= ""
    Local bValid	:= Nil
    Local bLinePre	:= {|oModel| ADLF6_4(oModel) }
    Local bLinePost	:= {|oModel| ADLF6_5( oModel, M->ZF5_TPFRPG, M->ZF5_TABSAI,M->ZF5_TABTDE ) }
     
    //Valida��es de campos.
    //oStPai:SetProperty('ZF5_TABCOD',  MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edi��o
    //oStPai:SetProperty('ZF5_TABCOD',  MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZF5", "ZF5_TABCOD")'))      //Ini Padr�o
    //oStPai:SetProperty('ZF5_TABDES',  MODEL_FIELD_OBRIGAT, .T. ) //Everson-044314|14/03/2019. 
         
    //Cria modelos e relacionamentos.
    oModel := MPFormModel():New('TABFRETE', /*bPreVld*/ , bPosVal, /**/, /*bCancel*/ )
    oModel:AddFields('ZF5MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('ZF6DETAIL','ZF5MASTER',oStFilho, bLinePre, bLinePost,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner � para quem pertence
     
    //Fazendo o relacionamento entre o Pai e Filho.
    Aadd(aZF6Rel, {'ZF6_FILIAL','ZF5_FILIAL'})
    Aadd(aZF6Rel, {'ZF6_TABCOD','ZF5_TABCOD'}) 
    
    //
    oModel:SetRelation('ZF6DETAIL', aZF6Rel, ZF6->(IndexKey(1))) //IndexKey -> quero a ordena��o e depois filtrado.
    oModel:SetPrimaryKey({'ZF5_FILIAL','ZF5_TABCOD'})
    
    //
    cValid := "U_ADLF6_3(M->ZF6_UF)"
    bValid := FWBuildFeature( STRUCT_FEATURE_VALID, cValid )
    oStFilho:SetProperty('ZF6_UF',MODEL_FIELD_VALID,bValid)
    
    //
     
    //Seta as descri��es.
    oModel:SetDescription("Tabela de Frete")
    oModel:GetModel('ZF5MASTER'):SetDescription('Tabela de Frete')
    oModel:GetModel('ZF6DETAIL'):SetDescription('Km x R$')
    
Return oModel
/*/{Protheus.doc} ADLFVP01
    P�s valida��o. Chamado 044314.
    @type  Static Function
    @author Everson
    @since 11/03/2019
    @version 01
    /*/
Static Function ADLFVP01(oModel)
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea			:= GetArea()
    Local lRet 			:= .T.
    Local nOperation 	:= oModel:GetOperation()
    Local cCodigo 		:= oModel:GetValue("ZF5MASTER","ZF5_TABCOD")
    
    Local cTpFrt		:= oModel:GetValue("ZF5MASTER","ZF5_TPFRPG")
    Local nVlrTonel		:= oModel:GetValue("ZF5MASTER","ZF5_TABTDE")
    Local nSaidMin		:= oModel:GetValue("ZF5MASTER","ZF5_TABSAI")
    
    Local cQuery		:= "SELECT COUNT(ZV4_XFRET) AS TOT FROM " + RetSqlName("ZV4") + " AS ZV4	 WHERE ZV4_FILIAL = '" + FwFilial("ZV4") + "' AND ZV4_XFRET = '" + cCodigo + "' AND ZV4.D_E_L_E_T_ = ''"
    Local nTotReg		:= 0
    
    //Valida frete fixo.
    If nOperation <> 5 //Everson - 17/02/2020. Chamado 054941.

        //
        If lRet .And. cTpFrt = "F" .And. nSaidMin <= 0
            lRet := .F.
            Help(Nil, Nil, "Valida��o de cabe�alho", Nil, 'Necess�rio informar valor da sa�da m�nima para frete fixo.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 
            
        EndIf

        //Valida frete tonelada.
        If lRet .And. cTpFrt = "T" .And. nVlrTonel <= 0
            lRet := .F.
            Help(Nil, Nil, "Valida��o de cabe�alho", Nil, 'Necess�rio informar valor por tonelada para frete tonelada.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 
                    
        EndIf

    EndIf
        
    //Valida��o de exclus�o.
    If nOperation == 5 .And. lRet
    	
    	//
    	If Select("D_TAB") > 0
    		D_TAB->(DbCloseArea())
    		
    	EndIf
    	
    	//
    	TcQuery cQuery New Alias "D_TAB"
    	DbSelectArea("D_TAB")
    		If ! D_TAB->(Eof())
    			nTotReg := Val(cValToChar(D_TAB->TOT))
    			
    		EndIf
    	
    	D_TAB->(DbCloseArea())
    	
    	//
    	If nTotReg > 0
    		lRet := .F.
    		Help(Nil, Nil, "N�o � poss�vel excluir a tabela.", Nil, "H� " + cValToChar(nTotReg) + " cadastros de ve�culos vinculados a esta tabela.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    		
    	EndIf
	                
    EndIf
    
    //
    RestArea(aArea)
    
Return lRet
/*/{Protheus.doc} ViewDef
    View MVC. Chamado 044314. 
    @type  Static Function
    @author Everson
    @since 11/03/2019
    @version 01
    /*/
Static Function ViewDef()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������
    Local oView		:= Nil
    Local oModel	:= ModelDef()//FWLoadModel('TABFRETE')
    Local oStPai	:= FWFormStruct(2, 'ZF5')
    Local oStFilho	:= FWFormStruct(2, 'ZF6')
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabe�alho e o grid dos filhos
    oView:AddField('VIEW_ZF5',oStPai  ,'ZF5MASTER')
    oView:AddGrid('VIEW_ZF6' ,oStFilho,'ZF6DETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',50)
    oView:CreateHorizontalBox('GRID',50)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZF5','CABEC')
    oView:SetOwnerView('VIEW_ZF6','GRID')
     
    //For�a o fechamento da janela na confirma��o
    oView:SetCloseOnOk({||.T.})
     
    //Remove o campo de c�digo da tabela.
    oStFilho:RemoveField('ZF6_TABCOD')
    
    //
    If ( INCLUI .And. MV_PAR01 == 2 ) .Or. ( ! INCLUI .And. Alltrim(ZF5->ZF5_TPFRPG) = "R" )
    	oStFilho:RemoveField('ZF6_TABKMI')
    	//oStFilho:RemoveField('ZF6_TABKMF')
    	oStFilho:RemoveField('ZF6_TABPRC')
    	oStFilho:RemoveField('ZF6_PRODUT')

    ElseIf ( INCLUI .And. MV_PAR01 == 3 ) .Or. ( ! INCLUI .And. Alltrim(ZF5->ZF5_TPFRPG) = "P" )
     	oStFilho:RemoveField('ZF6_TABKMI')
    	//oStFilho:RemoveField('ZF6_TABKMF')
    	oStFilho:RemoveField('ZF6_TABPRC')
    
    ElseIf ( INCLUI .And. MV_PAR01 == 4 ) .Or. ( ! INCLUI .And. Alltrim(ZF5->ZF5_TPFRPG) = "X" ) //Everson - 01/02/2022. Chamado 65860.
        oStFilho:RemoveField('ZF6_UF')
    	oStFilho:RemoveField('ZF6_CIDADE')
    	oStFilho:RemoveField('ZF6_NUMCID')
    	oStFilho:RemoveField('ZF6_VLRREG')
    	oStFilho:RemoveField('ZF6_PRODUT')
    	
    Else
        oStFilho:RemoveField('ZF6_UF')
    	oStFilho:RemoveField('ZF6_CIDADE')
    	oStFilho:RemoveField('ZF6_NUMCID')
    	oStFilho:RemoveField('ZF6_VLRREG')
    	oStFilho:RemoveField('ZF6_PRODUT')
    	    	   
    EndIf
    
    //Adiciona campo auto incremento.
    oView:addIncrementField("ZF6DETAIL","ZF6_ITESEQ")

    oView:AddUserButton("Exportar","",{|oView| MSAguarde({|| gerXLS(oView) } , "Aguarde", "Gerando arquivo...") } ,"",, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW} , .T. ) //Everson - 02/02/2022. Chamado 66403.
    
Return oView
/*/{Protheus.doc} User Function gerXLS
    Gera arquivo XLS.
    Chamado 66403.
    @type  Function
    @author Everson  
    @since 02/02/2022
    @version 01
    /*/
Static Function gerXLS(oView)

    //Vari�veis.
    Local aArea	    := GetArea()
    Local oStPai    := FWFormStruct(1, 'ZF5')
    Local oCabec    := oView:GetModel("ZF5MASTER")
    Local oGrid     := oView:GetModel("ZF6DETAIL")
    Local aCampos   := oView:GetListFields()
    Local aData     := oGrid:GetOldData()
    Local aHeader   := aData[1]
    Local cCmp	    := ""
    Local aCmpCab   := {}
    Local aCmpItem  := {}
    Local nAux      := 1
    Local nAux2     := 1
    Local oExcel    := FWMsExcelEx():New()
    Local cArq      := "\tabfrt_"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".xls"
    Local cWkS1     := "Cabe�alho"
    Local cTab1     := "Cabe�alho"
    Local cWkS2     := "Itens"
    Local cTab2     := "Itens"
    Local cPath     := AllTrim(GetTempPath())
    Local aLinhas   := {}
    Local cNmCel    := ""
    Local nLength   := oGrid:length()
    Local xVlr      := Nil
    Local aInner    := {}

    For nAux := 1 To Len(aCampos)

        cCmp := Alltrim(cValToChar(aCampos[nAux][2]))

        nPos := 0

        If aCampos[nAux][1] == "VIEW_ZF5"
            cNmCel := oStPai:GetProperty(cCmp, MODEL_FIELD_TITULO)
            Aadd(aCmpCab, {cNmCel, aCampos[nAux][2], Nil})

        ElseIf aCampos[nAux][1] == "VIEW_ZF6"
            nPos := Ascan(aHeader,{|x| x[2] == cCmp} )
            Aadd(aCmpItem, { aHeader[nPos][1], aHeader[nPos][2], aHeader[nPos][8] })

        EndIf

    Next nAux

    //Cabe�alho.
    oExcel:AddworkSheet(cWkS1)
	oExcel:AddTable(cWkS1,cTab1)
    For nAux := 1 To Len(aCmpCab)
        cNmCel := aCmpCab[nAux][1]
        oExcel:AddColumn(cWkS1, cTab1, cNmCel, 1, 1)

    Next nAux

    aInner := {}
    For nAux := 1 To Len(aCmpCab)
        xVlr := oCabec:GetValue(aCmpCab[nAux][2])
        Aadd(aInner, xVlr)

    Next nAux

    oExcel:AddRow(cWkS1, cTab1, aInner)

    //Itens.
    aLinhas := {}
    aInner  := {}
    oExcel:AddworkSheet(cWkS2)
	oExcel:AddTable(cWkS2,cTab2)
    For nAux := 1 To Len(aCmpItem)
        cNmCel := aCmpItem[nAux][1]
        oExcel:AddColumn(cWkS2, cTab2, cNmCel, 1, 1)

    Next nAux

    For nAux := 1 To nLength

        aInner := {}
        For nAux2 := 1 To Len(aCmpItem)
            Aadd(aInner,"")

        Next nAux2

        Aadd(aLinhas, aInner)

        oGrid:GoLine(nAux)

        For nAux2 := 1 To Len(aCmpItem)

            xVlr := oGrid:GetValue(aCmpItem[nAux2][2], nAux)

            aLinhas[nAux][nAux2] := xVlr

        Next nAux2

    Next nLength

	For nAux := 1 to nLength

        aInner := {}
        For nAux2 := 1 To Len(aCmpItem)

            Aadd(aInner, aLinhas[nAux][nAux2])

        Next nAux2

       	oExcel:AddRow(cWkS2,cTab2,aInner)

    Next nAux 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)

	If ! ApOleClient("MsExcel")
		MsgStop("Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo n? est?instalado. Por favor, tente novamente." )
		RestArea(aArea)
        Return Nil

	EndIf

	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open( cPath + cArq )
	oExcelApp:SetVisible(.T.)
    
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADLF6_2
    Retorna valor de UF selecionado. Chamado 044314. 
    @type  Function
    @author Everson  
    @since 08/08/2019
    @version 01
    /*/
User Function ADLF6_2() // U_ADLF6_2()

    U_ADINF009P('ADLFV006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')

Return cEst
/*/{Protheus.doc} User Function ADLF6_3
    Valida��o de estado. Chamado 044314.
    @type  Function
    @author Everson
    @since 08/08/2019
    @version 01
    /*/
User Function ADLF6_3(cUF) // U_ADLF6_3(M->ZF6_UF)
	
	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea		:= GetArea()
    Local lRet		:= .T.
    Local cSiglas	:= "AC/AL/AP/AM/BA/CE/DF/ES/GO/MA/MT/MS/MG/PA/PB/PR/PE/PI/RJ/RN/RS/RO/RR/SC/SP/SE/TO/EX" //Everson - 09/08/2019. Chamado 044314.

    U_ADINF009P('ADLFV006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun��o para cadastro de tabela de frete.')
    
    //
    cUF := Alltrim(cUF)
    
    //
    If ! Empty(cUF)
    	lRet := Alltrim(cUF) $cSiglas 
    
    EndIf
    
    //
    If lRet
    	cEst:= cUF
    	
    Else
    	cEst:= ""
    	
    EndIf 
    	
    //
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADLF6_4
    Verifica UF da linha. Chamado 044314. 
    @type  Static Function
    @author Everson
    @since 08/08/2019
    @version 01
    /*/
Static Function ADLF6_4(oModel)

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea		:= GetArea()
    Local lRet		:= .T.
    
	cEst := oModel:GetValue( 'ZF6_UF')
    
    //
    RestArea(aArea)
    
Return lRet
/*/{Protheus.doc} ADLF6_5
    Valida��o de linha. Chamado 044314.
    @type  Static Function
    @author Everson
    @since  08/08/2019
    @version 01
    /*/
Static Function ADLF6_5(oModel,cTpFrt,nTabSai,nVlrTonel)

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.                                            |
	//�����������������������������������������������������������������������    
    Local aArea		:= GetArea()
    Local lRet		:= .T.
  
	//			
	If ( INCLUI .And. MV_PAR01 == 2 ) .Or. ( ! INCLUI .And. Alltrim(ZF5->ZF5_TPFRPG) = "R" )

        //
		If Empty(Alltrim(oModel:GetValue( 'ZF6_UF'))) .Or.;
		   	oModel:GetValue( 'ZF6_VLRREG') <= 0       .Or.;
            oModel:GetValue( 'ZF6_TABKMF') <= 0 //Everson - 17/02/2020. Chamado 054941.
			lRet := .F.
			Help(Nil, Nil, "Valida��o de linha", Nil, 'Necess�rio informar valor, estado e Km percorrido.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) //Everson - 17/02/2020. Chamado 054941.
			
		EndIf

    ElseIf ( INCLUI .And. MV_PAR01 == 4 ) .Or. ( ! INCLUI .And. Alltrim(ZF5->ZF5_TPFRPG) = "X" ) //Everson - 01/02/2022. Chamado 65860.

		If 	oModel:GetValue( 'ZF6_TABPRC') <= 0 .Or.;
            oModel:GetValue( 'ZF6_TABKMF') <= 0
			lRet := .F.
			Help(Nil, Nil, "Valida��o de linha", Nil, 'Necess�rio informar Km percorrido e valor.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''})
			
		EndIf

    ElseIf ( INCLUI .And. MV_PAR01 == 3 ) .Or. ( ! INCLUI .And. Alltrim(ZF5->ZF5_TPFRPG) = "P" )

        //
		If Empty(Alltrim(oModel:GetValue( 'ZF6_UF')))		.Or.;
		   Empty(Alltrim(oModel:GetValue( 'ZF6_CIDADE'))) 	.Or.;
		   Empty(Alltrim(oModel:GetValue( 'ZF6_NUMCID')))	.Or.;
		   Empty(Alltrim(oModel:GetValue( 'ZF6_PRODUT')))	.Or.;
		   oModel:GetValue( 'ZF6_VLRREG') <= 0              .Or.;
           oModel:GetValue( 'ZF6_TABKMF')  <= 0 //Everson - 17/02/2020. Chamado 054941.
		    lRet := .F.
			Help(Nil, Nil, "Valida��o de linha", Nil, 'Necess�rio informar valor,estado, cidade, produto e Km percorrido.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) //Everson - 17/02/2020. Chamado 054941.
			
		EndIf
		
	Else
		
		//
		If Alltrim(cTpFrt) = "V" .And. ( oModel:GetValue( 'ZF6_TABPRC') <= 0 .Or. oModel:GetValue( 'ZF6_TABKMF') <= oModel:GetValue( 'ZF6_TABKMI') )
			lRet := .F.
			Help(Nil, Nil, "Valida��o de linha", Nil, 'Necess�rio informar Km final maior que Km inicial e valor.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 
			
		EndIf

		//
		If Alltrim(cTpFrt) = "F" .And. nTabSai <= 0 
			lRet := .F.
			Help(Nil, Nil, "Valida��o de linha", Nil, 'Necess�rio informar valor da sa�da m�nima para frete fixo.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 
			
		EndIf
		
		//
		If Alltrim(cTpFrt) = "T" .And. nVlrTonel <= 0 
			lRet := .F.
			Help(Nil, Nil, "Valida��o de linha", Nil, 'Necess�rio informar valor pago por tonelada para frete por tonelada.', 1, 0, Nil, Nil, Nil, Nil, Nil, {''}) 
			
		EndIf
		    	    	   
    EndIf
    
    //
    RestArea(aArea)
    
Return lRet
