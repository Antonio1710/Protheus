//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "topconn.ch"

//Variáveis Estáticas
Static cTitulo := "RM Acordos Trabalhistas - Favorecidos"
  
/*/{Protheus.doc} ADFI119
    Rotina para cadastrar os favorecidos dos processos de acordos trabalhistas
    @author Fernando Macieira
    @since 17/12/2021
    @version 1.0
    @return Nil, Função não tem retorno
    @example
    @ticket 18141 - Fernando Macieira - 17/12/2021 - RM - Acordos - Integração Protheus
    @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    @ticket 18141 - Fernando Macieira - 10/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirado campo ZHC_TIPDES e ZHC_NOMDES
    @ticket 18141 - Fernando Macieira - 10/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirado campo ZHC_TIPDES e ZHC_NOMDES
    @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Remodelagem tabela ZHC e ZHD
/*/
User Function ADFI119()

    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
      
    // @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    Private cLinked :=  GetMV("MV_#RMLINK",,"RM") // DEBUG - "LKD_PRT_RM" 
	Private cSGBD   :=  GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD") // DEBUG - "CCZERN_119205_RM_DE"

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RM Acordos Trabalhistas - Favorecidos.')

    SetFunName("ADFI119")
      
    //Cria um browse para a ZHC
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZHC")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
      
    SetFunName(cFunBkp)
    RestArea(aArea)

Return
 
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 17/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()

    Local aRot := {}
      
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.ADFI119' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.ADFI119' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.ADFI119' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.ADFI119' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

Return aRot
 
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 17/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()

    // Criacao do objeto do modelo de dados
    Local oModel     := Nil                   
    Local aPaiFilRel := {}

    // Criacao da estrutura de dados utilizada na interface
    Local oStPai   := FWFormStruct(1, "ZHC")
    Local oStFilho := FWFormStruct(1, "ZHD")

    Local bPosVld  := {|oModel| fValid(oModel)}

    oStPai:SetProperty("ZHC_CODIGO", MODEL_FIELD_INIT,  FWBuildFeature(STRUCT_FEATURE_INIPAD, 'u_SXESXF("ZHC")')) // INI PADRAO

    // Criando o modelo e os relacionamentos
    oModel := MPFormModel():New("MVCFI119", /*bPreVld*/ , bPosVld, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields("ZHCMASTER", /*cOwner*/, oStPai)
    oModel:AddGrid("ZHDDETAIL", "ZHCMASTER", oStFilho, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga Modelo*/)

    // Fazendo relacionamento entre pai e filho
    aAdd( aPaiFilRel, {"ZHD_FILIAL", "ZHC_FILIAL"} )
    aAdd( aPaiFilRel, {"ZHD_CODIGO", "ZHC_CODIGO"} )

    oModel:SetRelation("ZHDDETAIL", aPaiFilRel, ZHD->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
    oModel:GetModel("ZHDDETAIL"):SetUniqueLine({"ZHD_PROCES"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}
    oModel:SetPrimaryKey({"ZHC_CODIGO"})

    // Setando as descricoes
    oModel:SetDescription("Favorecidos - RM Acordos Trabalhistas")
    oModel:GetModel("ZHCMASTER"):SetDescription("Dados Bancários")
    oModel:GetModel("ZHDDETAIL"):SetDescription("Processos RM")
 
Return oModel
 
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 17/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()

    // Criacao do objeto do modelo de dados da interface do cadastro
    Local oModel := FWLoadModel("ADFI119")

    // Criacao da estrutura de dados utilizada na interface do cadastro
    Local oStPai   := FWFormStruct(2, "ZHC") 
    Local oStFilho := FWFormStruct(2, "ZHD") 

    // Criando oView como nulo
    Local oView := Nil

    // Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
                        
    // Adicionando os campos do cabecalho e o grid dos filhos
    oView:AddField("VIEW_ZHC", oStPai, "ZHCMASTER")
    oView:AddGrid("VIEW_ZHD", oStFilho, "ZHDDETAIL")

    // Criando container com nome tela 100%
    oView:CreateHorizontalBox("CABEC", 40)
    oView:CreateHorizontalBox("GRID", 60)
                                    
    // Amarrando a VIEW com as BOX
    oView:SetOwnerView("VIEW_ZHC", "CABEC")
    oView:SetOwnerView("VIEW_ZHD", "GRID")

    // Habilitando titulo
    oView:EnableTitleView("VIEW_ZHC", "Dados Bancários")
    oView:EnableTitleView("VIEW_ZHD", "Processos RM")

    // Forca o fechamento da janela na confirmacao
    oView:SetCloseOnOK( {|| .t.} )
                            
    // Remove os campos de codigo 
    //oStFilho:RemoveField("ZHD_FILIAL")
    oStFilho:RemoveField("ZHD_CODIGO")

    //Define o campo incremental da grid como o ZHC_ITEM
    oView:AddIncrementField('VIEW_ZHD', 'ZHD_ITEM')

Return oView
 
/*/{Protheus.doc} nomeStaticFunction
    //Função que faz a validação da grid
    @type  Static Function
    @author FWNM
    @since 17/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fValid(oModel)

    Local lRet       := .T.
    Local nDeletados := 0
    Local nLinAtual  := 0

    //Local nOperation := oModel:GetOperation()
    Local oModelMain := oModel:GetModel('ZHCMASTER')
    Local oModelGRID := oModel:GetModel("ZHDDETAIL")

    Local cCPFCGC    := ""
    Local cFavorec   := ""
    Local cBanco     := ""
    Local cAgencia   := ""
    Local cConta     := ""
    Local cDigCta    := ""
    Local cCodFavor  := ""
    Local cProcesso  := ""

    If oModel:nOperation == 3 .or.;
       oModel:nOperation == 4 .or.;
       oModel:nOperation == 5

        cCPFCGC    := oModelMain:GetValue("ZHC_CPFCGC")
        cFavorec   := oModelMain:GetValue("ZHC_FAVORE")
        cBanco     := oModelMain:GetValue("ZHC_BANCO")
        cAgencia   := oModelMain:GetValue("ZHC_AGENCI")
        cConta     := oModelMain:GetValue("ZHC_CONTA")
        cDigCta    := oModelMain:GetValue("ZHC_DIGCTA")
        cCodFavor  := oModelMain:GetValue("ZHC_CODIGO")
    
        If Empty(cCodFavor)
            lRet := .f.
            Alert("Código do Favorecido não preenchido! Verifique...")
        Else
            If oModel:nOperation == 3
                ZHC->( dbSetOrder(1) ) // ZHC_FILIAL+ZHC_CODIGO // @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Remodelagem tabela ZHC e ZHD
                If ZHC->( dbSeek(FWxFilial("ZHC")+cCodFavor) )
                    lRet := .f.
                    Alert("Código Favorecido já cadastrado! Verifique...")
                EndIf
            EndIf
        EndIf

        If lRet
            If Empty(cCPFCGC)
                lRet := .f.
                Alert("CPF/CNPJ não preenchido! Verifique...")
            Else
                If oModel:nOperation == 3 .or. oModel:nOperation == 4
                    ZHC->( dbSetOrder(2) ) // ZHC_FILIAL+ZHC_CPFCGC // @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Remodelagem tabela ZHC e ZHD
                    If ZHC->( dbSeek(FWxFilial("ZHC")+cCPFCGC) ) .and. AllTrim(cCodFavor) <> AllTrim(ZHC->ZHC_CODIGO)
                        lRet := .f.
                        Alert("CPF/CNPJ já cadastrado! Verifique...")
                    EndIf
                EndIf
            EndIf

            If lRet
                If Empty(cFavorec)
                    lRet := .f.
                    Alert("Nome do favorecido não preenchido! Verifique...")
                EndIf
            EndIf
        EndIf

        If lRet
            If Empty(cBanco)
                lRet := .f.
                Alert("Código do banco não preenchido! Verifique...")
            EndIf
        EndIf

        If lRet
            If Empty(cAgencia)
                lRet := .f.
                Alert("Agência não preenchida! Verifique...")
            EndIf
        EndIf

        If lRet
            If Empty(cConta)
                lRet := .f.
                Alert("Conta não preenchida! Verifique...")
            EndIf
        EndIf

        If lRet
            If Empty(cDigCta)
                lRet := .f.
                Alert("Dígito da conta não preenchida! Verifique...")
            EndIf
        EndIf

        If lRet .and. !Empty(cBanco) .and. !Empty(cConta) .and. !Empty(cDigCta)
            lRet := ChkDadBco(cCPFCGC, cBanco, cAgencia, cConta, cDigCta)
            If !lRet
                Alert("Dados bancários já cadastrados para outro favorecido! Verifique...")
            EndIf
        EndIf

        If lRet

            //Percorrendo todos os itens da grid
            For nLinAtual := 1 To oModelGRID:Length()

                //Posiciona na linha
                oModelGRID:GoLine(nLinAtual)
                
                //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
                If oModelGRID:IsDeleted()
                    nDeletados++
                Else

                    cProcesso := oModelGRID:GetValue("ZHD_PROCES")

                    If Empty(cProcesso)

                        lRet := .f.
                        Alert("N. do processo na linha " + AllTrim(Str(nLinAtual)) + " não preenchido! Verifique...")
                        Exit

                    Else

                        // Checo se o n. do processo existe no RM
                        If Select("WorkRM") > 0
                            WorkRM->( dbCloseArea() )
                        EndIf

                        cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '
                        cQuery += "	    SELECT NUMPROCESSO
                        cQuery += "		FROM [" + cSGBD + "].[DBO].[VPROCESSOS] (NOLOCK)
                        cQuery += "		WHERE NUMPROCESSO=''"+cProcesso+"''
                        cQuery += " ')

                        tcQuery cQuery New Alias "WorkRM"

                        WorkRM->( dbGoTop() )
                        If WorkRM->(EOF())
                            lRet := .f.
                            Alert("N. do processo na linha " + AllTrim(Str(nLinAtual)) + " não existe no RM! Verifique...")
                            Exit
                        EndIf

                    EndIf

                EndIf

                If oModel:nOperation == 5
                    ZHB->( dbSetOrder(1) ) // ZHB_FILIAL, ZHB_PROCES, ZHB_TIPDES, R_E_C_N_O_, D_E_L_E_T_
                    //If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cTipDes)) // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirado campo ZHC_TIPDES e ZHC_NOMDES
                    If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso)) // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirado campo ZHC_TIPDES e ZHC_NOMDES
                        If ZHB->ZHB_GERSE2 .or. !Empty(ZHB->ZHB_NUM)
                            lRet := .f.
                            Alert("Exclusão não permitida pois favorecido possui título integrado no financeiro! Verifique as despesas do processo referente linha " + AllTrim(Str(nLinAtual)) + " ...")
                            Exit
                        EndIf
                    EndIf
                EndIf

            Next nLinAtual

        EndIf

    EndIf
 
    //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
    If lRet
        If oModelGRID:Length()==nDeletados
            lRet :=.F.
            Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
        EndIf
    EndIf
 
    /*
    If lRet
        //Se o valor digitado no cabeçalho (valor da NF), não bater com o valor de todos os abastecimentos digitados (valor dos itens da Grid), irá mostrar uma mensagem alertando, porém irá permitir salvar (do contrário, seria necessário alterar lRet para falso)
        If cProcesso != nValorGrid
            //lRet := .F.
            MsgAlert("O valor do cabeçalho (" + Alltrim(Transform(cProcesso, cPictVlr)) + ") tem que ser igual o valor dos itens (" + Alltrim(Transform(nValorGrid, cPictVlr)) + ")!", "Atenção")
        EndIf
    EndIf
    */
 
Return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 31/03/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkDadBco(cCPFCGC, cBanco, cAgencia, cConta, cDigCta)

    Local lRet   := .t.
    Local cQuery := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT TOP 1 *
    cQuery += " FROM " + RetSqlName("ZHC") + " ZHC (NOLOCK)
    cQuery += " WHERE ZHC_FILIAL='"+FWxFilial("ZHC")+"'
    cQuery += " AND ZHC_BANCO='"+cBanco+"'
    cQuery += " AND ZHC_AGENCI='"+cAgencia+"'
    cQuery += " AND ZHC_CONTA='"+cConta+"'
    cQuery += " AND ZHC_DIGCTA='"+cDigCta+"'
    cQuery += " AND ZHC_CPFCGC<>'"+cCPFCGC+"'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->( !EOF() )
        lRet := .f.
    EndIf
    
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return lRet

/*/{Protheus.doc} User Function FixZHCZHD
    Saneia registros existentes na tabela ZHC para a ZHD - Rotina descartável
    @type  Function
    @author user
    @since 01/04/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 18141 - Fernando Macieira - 01/04/2022 - RM - Acordos - Remodelagem tabela ZHC e ZHD
/*/
User Function FixZHCZHD()

    Local lLock := .t.
    Local cStartPath := GetSrvProfString("Startpath","")

    dbUseArea(.T., __LocalDriver, cStartPath+"ZHC010_ORI"+GetDbExtension(), "ZHCORI", .T., .F.)

    ZHCORI->( dbGoTop() )
    Do While ZHCORI->( !EOF() )

        // ZHC - Cabeçalho
        lLock := .t.
        ZHC->( dbSetOrder(1) ) // ZHC_FILIAL, ZHC_CODIGO, R_E_C_N_O_, D_E_L_E_T_ 
        If ZHC->( dbSeek(FWxFilial("ZHC")+ZHCORI->ZHC_CODIGO) )
            lLock := .f.
        EndIf

        RecLock("ZHC", lLock)
            ZHC->ZHC_FILIAL := FWxFilial("ZHC")
            ZHC->ZHC_CODIGO := ZHCORI->ZHC_CODIGO
            ZHC->ZHC_CPFCGC := ZHCORI->ZHC_CPFCGC
            ZHC->ZHC_FAVORE := ZHCORI->ZHC_FAVORE
            ZHC->ZHC_BANCO  := ZHCORI->ZHC_BANCO
            ZHC->ZHC_AGENCI := ZHCORI->ZHC_AGENCI
            ZHC->ZHC_CONTA  := ZHCORI->ZHC_CONTA
            ZHC->ZHC_DIGCTA := ZHCORI->ZHC_DIGCTA
        ZHC->( msUnLock() )


        // ZHD - Itens
        lLock := .t.
        ZHD->( dbSetOrder(1) ) // ZHD_FILIAL+ZHD_CODIGO+ZHD_PROCES
        If ZHD->( dbSeek(FWxFilial("ZHD")+ZHCORI->ZHC_CODIGO+ZHCORI->ZHC_PROCES) )
            lLock := .f.
        EndIf

        RecLock("ZHD", lLock)
            ZHD->ZHD_FILIAL := FWxFilial("ZHD")
            ZHD->ZHD_CODIGO := ZHCORI->ZHC_CODIGO
            ZHD->ZHD_ITEM   := ZHCORI->ZHC_ITEM
            ZHD->ZHD_PROCES := ZHCORI->ZHC_PROCES
        ZHD->( msUnLock() )

        ZHCORI->( dbSkip() )

    EndDo
    
Return 
