#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIV"
Static cTitulo := "Consumo de Ração"
Static cTiMast := "Dados do consumo de ração"

/*/{Protheus.doc} User Function ADFAT043P
    Cadastro consumo de ração.
    Cad Consumo Racao
    Chamado 18465.
    @type  Function
    @author Everson
    @since 01/04/2022
    @version 01
    /*/
User Function ADFAT043P() // U_ADFAT043P()

    //VariÃ¡veis.
    Local oBrowse := FwLoadBrw("ADFAT043P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 01/04/2022
    @version 01
/*/
Static Function BrowseDef()

    //VariÃ¡veis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetMenuDef("ADFAT043P")

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 01/04/2022
    @version 01
/*/
Static Function MenuDef()

    //VariÃ¡veis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT043P" 	OPERATION MODEL_OPERATION_VIEW      ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "VIEWDEF.ADFAT043P" 	OPERATION MODEL_OPERATION_INSERT    ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.ADFAT043P" 	OPERATION MODEL_OPERATION_UPDATE    ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "VIEWDEF.ADFAT043P" 	OPERATION MODEL_OPERATION_DELETE    ACCESS 0
    // ADD OPTION aRotina TITLE "Proc Integr." ACTION "U_ADFAT43A()"       OPERATION 10  ACCESS 0

Return aRotina
/*/{Protheus.doc} ModelDef
    @type  Static Function
    @author Everson
    @since 01/04/2022
    @version 01
/*/
Static Function ModelDef()
    
    //Variáveis.
    Local oModel    := Nil
    Local oStrMast  := FWFormStruct(1, cTbMast, {|cCampo| AllTRim(cCampo) $ "ZIV_FILIAL;ZIV_NUMERO;ZIV_TPTAB;ZIV_GRUPO;"})
    Local oStrGrid  := FWFormStruct(1, cTbMast)
    Local bPost     := Nil

    bPost := {|oModel| .T.}

    oModel := MPFormModel():New("ADFAT43", /*bPreValidacao*/, bPost, /*bCommit*/, /*bCancel*/ )
    
    //AddFields(<cId >, <cOwner >, <oModelStruct >, <bPre >, <bPost >, <bLoad >)
    oModel:AddFields("MD_MASTER", Nil, oStrMast)
    oModel:AddGrid("MD_GRID", "MD_MASTER", oStrGrid,,,,,)
 
    oModel:SetRelation("MD_GRID", {;
            {"ZIV_FILIAL", 'FWxFilial("' + cTbMast + '")'},;
            {"ZIV_NUMERO", "ZIV_NUMERO"},;
            {"ZIV_TPTAB", "ZIV_TPTAB"},;
            {"ZIV_GRUPO", "ZIV_GRUPO"};
        }, (cTbMast)->(IndexKey(1)))

    oModel:GetModel("MD_GRID")
    oModel:SetDescription(cTiMast)
    oModel:SetPrimaryKey({})

Return oModel
/*/{Protheus.doc} vldPos
    Pós validação.
    @type  Static Function
    @author Everson
    @since 04/04/2022
    @version 01
/*/
Static Function vldPos(oModel)

    //Variáveis.
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cNmTab     := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIV_TPTAB")))
    Local cGrupo     := Alltrim(cValToChar(oModel:GetValue("MD_MASTER", "ZIV_GRUPO")))

    If lRet .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )
        
        If Empty(cNmTab) .Or. Empty(cGrupo)
            lRet := .F.
            Help(Nil, Nil, "Função vldPos(ADFAT043P)", Nil, "Necessário informar o nome da tabela e o grupo.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ViewDef
    @type  Static Function
    @author Everson
    @since 01/04/2022
    @version 01
/*/
Static Function ViewDef()
    
    //VariÃ¡veis.
    Local oView     := FwFormView():New()
    Local oModel    := FwLoadModel("ADFAT043P")
    Local cCampos   := "ZIV_FILIAL;ZIV_NUMERO;ZIV_TPTAB;ZIV_GRUPO;"
    Local oStrMast  := FWFormStruct(2, cTbMast, {|cCampo| AllTRim(cCampo) $ cCampos})
    Local oStrGrid  := FWFormStruct(2, cTbMast, {|cCampo| !(Alltrim(cCampo) $ cCampos)})

    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    oView:AddField("VW_MASTER", oStrMast, "MD_MASTER")
    oView:AddGrid("VW_GRID",    oStrGrid, "MD_GRID")
 
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)

    oView:SetOwnerView("VW_MASTER", 'MAIN')
    oView:SetOwnerView("VW_GRID", 'GRID')
    oView:EnableControlBar(.T.)

Return oView
/*/{Protheus.doc} ADFAT18A
    Processa registros pendentes de integração vindos do barramento.
    @type  Static Function
    @author Everson
    @since 04/04/2022
    @version 01
/*/
User Function ADFAT43A()

    //Variáveis.
    Local aArea := GetArea()

    MsAguarde({|| U_ADFAT29I() }, "Aguarde", "Processando...", .F.)

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT43B
    Posiciona no registro pelo nome da tabela pelo nome da tabela.
    @type  Static Function
    @author Everson
    @since 04/04/2022
    @version 01
/*/
User Function ADFAT43B(cNmTab)

    //Variáveis.
    
    DbSelectArea("ZIV")
    ZIV->(DbSetOrder(5))
    If ! ZIV->( DbSeek( FWxFilial("ZIV") + cNmTab ) )
        Return .F.

    EndIf

Return .T.
/*/{Protheus.doc} ADFAT43C
    Retonar a fase do produto.
    @type  Static Function
    @author Everson
    @since 04/04/2022
    @version 01
/*/
User Function ADFAT43C(cProdSAG, cCodGrj, nIdade) //Iif(cFilAnt = "03",U_ADFAT43C(ZIM->ZIM_PRDSAG,M->ZIR_CODGRJ,M->ZIR_IDALOT),.T.)
Return .T.
/*/{Protheus.doc} ADFAT43D
    Consulta padrão específica.
    @type  User Function
    @author Everson
    @since 04/04/2022
    @version 01
/*/
User Function ADFAT43D(cCodGrj, nIdade, cFiltro) // U_ADFAT43D(M->ZIR_CODGRJ,M->ZIR_IDALOT)

    //Variáveis.
    Local oDlg, oLbx
    Local aCpos  := {}
    Local aRet   := {}
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local lRet   := .F.
    Local cCodTab := Posicione("ZIS", 1, FWxFilial("ZIS") + cCodGrj, "ZIS_TPCONS")

    Default cFiltro := ""

    cQuery += " SELECT  " 
    cQuery += " DISTINCT ZIM_PRDSAG, ZIM_DESSAG " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIM") + " (NOLOCK) AS ZIM " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZI8") + " (NOLOCK) AS ZI8 ON " 
    cQuery += " ZIM_PRDSAG = ZI8_PRDSAG " 
    cQuery += " WHERE " 
    cQuery += " ZIM_FILIAL = '" + FWxFilial("ZIM") + "' " 
    cQuery += " AND ZIM_ATIVO = '1' " 
    cQuery += " AND ZIM_GRPSAG LIKE '%RACAO%' " 
    cQuery += " AND ZI8_STATUS IN ('1','2') "

    If ! Empty(cFiltro)
        cQuery += " AND UPPER(ZIM_DESSAG) LIKE '%" + Upper(Alltrim(cValToChar(cFiltro))) + "%' "

    EndIf

    cQuery += " AND ZIM.D_E_L_E_T_ = '' " 
    cQuery += " AND ZI8.D_E_L_E_T_ = '' " 

    If cFilAnt == "03"

        cQuery += " AND ZIM_SGPSAG IN  " 
        cQuery += " (SELECT ZIV_SGRUPO FROM  " + RetSqlName("ZIV") + " (NOLOCK) AS ZIV WHERE ZIV_FILIAL = '" + FWxFilial("ZIV") + "' AND ZIV_NUMERO = '" + cCodTab + "' AND ZIV_INICIA <= " + cValToChar(nIdade) + " AND ZIV_FINAL >= " + cValToChar(nIdade) + " AND ZIV.D_E_L_E_T_ = '') " 
        
    EndIf
    
    cQuery += " ORDER BY " 
    cQuery += " ZIM_PRDSAG " 

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

    While (cAlias)->(!Eof())

        Aadd(aCpos,{(cAlias)->(ZIM_PRDSAG), (cAlias)->(ZIM_DESSAG), (cAlias)->(ZIM_DESSAG)})

        (cAlias)->(DbSkip())

    End
    (cAlias)->(DbCloseArea())

    If Len(aCpos) < 1
        Aadd(aCpos,{" "," "," "})

    EndIf

    DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Produtos" FROM 0,0 TO 240,500 PIXEL

        @ 10,10 LISTBOX oLbx FIELDS HEADER 'Produto', 'Descrição', 'Protheus' SIZE 230,95 OF oDlg PIXEL

        oLbx:SetArray( aCpos )
        oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2] }}
        oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2] }}}

    DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2] })  ENABLE OF oDlg
    ACTIVATE MSDIALOG oDlg CENTER

    If Len(aRet) > 0 .And. lRet
        If Empty(aRet[1])
            lRet := .F.

        Else
            ZIM->(DbSetOrder(1))
            ZIM->(DbSeek( FWxFilial("ZIM")+aRet[1]) )

        EndIf

    EndIf

Return lRet
