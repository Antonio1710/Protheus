//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "topconn.ch"
  
//Variáveis Estáticas
Static cTitulo := "RM Acordos Trabalhistas - Despesas de Processos"
  
/*/{Protheus.doc} ADFI118
    Rotina para incluir as despesas dos processos de acordos trabalhistas
    @author Fernando Macieira
    @since 17/12/2021
    @version 1.0
    @return Nil, Função não tem retorno
    @example
    @ticket 18141 - Fernando Macieira - 17/12/2021 - RM - Acordos - Integração Protheus
    @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    @ticket 18141 - Fernando Macieira - 27/01/2022 - RM - Acordos - Integração Protheus - Novos tipos de despesas
    @ticket 18141 - Fernando Macieira - 08/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
/*/
User Function ADFI118()

    Local aArea   := GetArea()
    Local oBrowse
    Local cFunBkp := FunName()
      
    // @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    Private cLinked :=  GetMV("MV_#RMLINK",,"RM") // DEBUG - "LKD_PRT_RM" 
	Private cSGBD   :=  GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD") // DEBUG - "CCZERN_119205_RM_DE"

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gerando acordos trabalhistas para aprovação.')

    // @history ticket 18141   - Fernando Macieira - 21/12/2021 - RM - Acordos - Integração Protheus
	FWMsgRun(, {|| u_ADFIN120P() }, "Aguarde", "Gerando acordos trabalhistas para aprovação ["+Time()+"] ...")
    u_Run121P(.f.)

    SetFunName("ADFI118")
      
    //Cria um browse para a ZHB
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZHB")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
      
    SetFunName(cFunBkp)
    RestArea(aArea)

    // @history ticket 18141   - Fernando Macieira - 21/12/2021 - RM - Acordos - Integração Protheus
	FWMsgRun(, {|| u_ADFIN120P() }, "Aguarde", "Gerando acordos trabalhistas para aprovação ["+Time()+"] ...")
    u_Run121P(.f.)

Return Nil
 
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
    ADD OPTION aRot TITLE 'Visualizar'               ACTION 'VIEWDEF.ADFI118' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'                  ACTION 'VIEWDEF.ADFI118' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'                  ACTION 'VIEWDEF.ADFI118' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'                  ACTION 'VIEWDEF.ADFI118' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '*Favorecidos'             ACTION 'u_ADFI119'       OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '*Manutenção das Parcelas' ACTION 'u_FWSE2'         OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 5
    ADD OPTION aRot TITLE '*Gera Parcelas'           ACTION 'u_Run121P(.F.)'  OPERATION MODEL_OPERATION_VIEW ACCESS 0 //OPERATION 5
    //ADD OPTION aRot TITLE '*Aprovadores' ACTION 'u_GetZC7(ZHB->ZHB_NUM, ZHB->ZHB_PARCEL)'         OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 5

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

    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 3 campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel    := NIL
    Local oStruCab  := FWFormStruct(1, 'ZHB', {|cCampo| AllTRim(cCampo) $ "ZHB_PROCES;"})
    Local oStruGrid := fModStruct()
    //Local bCommit   := {|oModel| FWMsgRun(, {|| u_ADFIN120P(oModel) }, "Aguarde", "Checando acordos trabalhistas no RM ["+Time()+"] ...")}
 
    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('ADFI118M', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )
 
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZHB', NIL, oStruCab)
    oModel:AddGrid('MdGridZHB', 'MdFieldZHB', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZHB', {;
            {'ZHB_FILIAL', 'FWxFilial("ZHB")'},;
            {"ZHB_PROCES",  "ZHB_PROCES"};
        }, ZHB->(IndexKey(2)))
     
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZHB"):SetMaxLine(9999)
    oModel:SetDescription("Despesas dos processos")
    oModel:SetPrimaryKey({"ZHB_FILIAL", "ZHB_PROCES"})
 
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

    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView     := NIL
    Local oModel    := FWLoadModel('ADFI118')
    Local oStruCab  := FWFormStruct(2, "ZHB", {|cCampo| AllTRim(cCampo) $ "ZHB_PROCES;"})
    Local oStruGRID := fViewStruct()
 
    //Define que no cabeçalho não terá separação de abas (SXA)
    oStruCab:SetNoFolder()
 
    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZHB, e uma Grid vinculando com MdGridZHB
    oView:AddField('VIEW_ZHB', oStruCab, 'MdFieldZHB')
    oView:AddGrid ('GRID_ZHB', oStruGRID, 'MdGridZHB' )
 
    //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 15)
    oView:CreateHorizontalBox("GRID", 85)
 
    //Vincula o MAIN com a VIEW_ZHB e a GRID com a GRID_ZHB
    oView:SetOwnerView('VIEW_ZHB', 'MAIN')
    oView:SetOwnerView('GRID_ZHB', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZHB_ITEM
    oView:AddIncrementField('GRID_ZHB', 'ZHB_ITEM')

Return oView
 
/*/{Protheus.doc} nomeStaticFunction
    //Função chamada para montar o modelo de dados da Grid
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
Static Function fModStruct()
    
    Local oStruct
    oStruct := FWFormStruct(1, 'ZHB')

Return oStruct
 
/*/{Protheus.doc} nomeStaticFunction
    //Função chamada para montar a visualização de dados da Grid
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
Static Function fViewStruct()

    Local cCampoCom := "ZHB_PROCES;"
    Local oStruct
 
    //Irá filtrar, e trazer todos os campos, menos os que tiverem na variável cCampoCom
    oStruct := FWFormStruct(2, "ZHB", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})

Return oStruct
 
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
Static Function fValidGrid(oModel)

    Local lRet       := .T.
    Local nDeletados := 0
    Local nLinAtual  := 0
    Local oModelGRID := oModel:GetModel('MdGridZHB')
    Local oModelMain := oModel:GetModel('MdFieldZHB')
    Local cProcesso  := oModelMain:GetValue("ZHB_PROCES")
    Local cTipDes    := ""
    Local nVlrDes    := 0
    Local nQtdPar    := 0
    Local dVencto1   := CtoD("//")
    Local cItem      := ""
    Local cDespFavor := GetMV("MV_#RMFAVO",,"ACORDO#PERITO") // @ticket 18141 - Fernando Macieira - 27/01/2022 - RM - Acordos - Integração Protheus - Novos tipos de despesas
    Local cCodFav    := ""
    //Local cPictVlr   := PesqPict('ZHB', 'ZHB_VALOR')
 
    // N. Processo Trabalhista obrigatório
    If oModel:nOperation <> 5

        If Empty(cProcesso)

            lRet := .f.
            Alert("N. do Processo não preenchido! Informe um processo existente no RM...")

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
                Alert("N. do Processo informado não existe no RM! Verifique...")
            Else
                // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirada do campo ZHC_TIPDES
                /*
                ZHC->( dbSetOrder(2) ) // ZHC_FILIAL+ZHC_PROCES+ZHC_TIPDES
                If ZHC->( !dbSeek(FWxFilial("ZHC")+cProcesso) )
                    lRet := .f.
                    Alert("Processo não possui nenhum favorecido! Verifique...")
                EndIf
                */
            EndIf

            If Select("WorkRM") > 0
                WorkRM->( dbCloseArea() )
            EndIf
        
        EndIf
    
    EndIf
    
    If lRet

        // Inclusões
        If oModel:nOperation == 3
            ZHB->( dbSetOrder(1) ) // ZHB_FILIAL, ZHB_PROCES, ZHB_TIPDES, R_E_C_N_O_, D_E_L_E_T_
            If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso) )
                lRet := .f.
                Alert("O processo já está cadastrado! Utilize 'alterar' caso deseje incluir novas despesas...")
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

                    cItem   := oModelGRID:GetValue("ZHB_ITEM")
                    cTipDes := oModelGRID:GetValue("ZHB_TIPDES")
                    nQtdPar := oModelGRID:GetValue("ZHB_PARCEL")

                    ZHB->( dbSetOrder(2) ) //ZHB_FILIAL+ZHB_PROCES+ZHB_ITEM+ZHB_TIPDES
                    ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cItem+cTipDes) )

                    // Aprovado e PR gerado
                    If (oModelGRID:GetValue("ZHB_GERSE2") .and. oModelGRID:GetValue("ZHB_APROVA")) .or. oModelGRID:GetValue("ZHB_GERPAR")
                        lRet := .f.
                        Alert("Exclusão não permitida! Despesa da linha " + AllTrim(Str(nLinAtual)) + " já foi aprovada e está no financeiro para pagamento...")
                        Exit
                    EndIf

                    // PR gerado mas ainda não aprovado
                    If oModelGRID:GetValue("ZHB_GERSE2") .and. !oModelGRID:GetValue("ZHB_APROVA") .and. !oModelGRID:GetValue("ZHB_GERPAR")
                        lRet := ExcPR(cProcesso, cTipDes, nQtdPar, oModelGrid:GetValue("ZHB_NUM"))
                        If !lRet
                            Exit
                        EndIf
                    EndIf

                Else

                    // @ticket 18141 - Fernando Macieira - 08/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos                    
                    // Cod Favorecido - checo se existe o código informado no cadastro ZHC
                    cCodFav := oModelGRID:GetValue("ZHB_FAVORE")
                    If !Empty(cCodFav)
                        ZHC->( dbSetOrder(3) ) // ZHC_FILIAL, ZHC_CODIGO, R_E_C_N_O_, D_E_L_E_T_
                        If ZHC->( !dbSeek(FWxFilial("ZHC")+cCodFav) )
                            lRet := .f.
                            Alert("Favorecido informado na linha " + AllTrim(Str(nLinAtual)) + " não existe! Verifique...")
                            Exit
                        Else
                            // Checo se o favorecido está amarrado a este processo
                            If AllTrim(cProcesso) <> AllTrim(ZHC->ZHC_PROCES)
                                lRet := .f.
                                Alert("Este favorecido informado na linha " + AllTrim(Str(nLinAtual)) + " não está autorizado para este processo! Verifique...")
                                Exit
                            EndIf
                        EndIf
                    EndIf
                    //

                    // Tipo Despesa
                    cTipDes := oModelGRID:GetValue("ZHB_TIPDES")
                    SX5->( dbSetOrder(1) )
                    If SX5->( !dbSeek(FWxFilial("SX5")+"_R"+cTipDes) )
                        lRet := .f.
                        Alert("Tipo de despesa informado na linha " + AllTrim(Str(nLinAtual)) + " não existe! Verifique...")
                        Exit
                    Else
                        // @ticket 18141 - Fernando Macieira - 27/01/2022 - RM - Acordos - Integração Protheus - Novos tipos de despesas
                        If AllTrim(cTipDes) $ AllTrim(cDespFavor)
                            
                            // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirada do campo ZHC_TIPDES
                            /*
                            ZHC->( dbSetOrder(2) ) // ZHC_FILIAL+ZHC_PROCES+ZHC_TIPDES
                            If ZHC->( !dbSeek(FWxFilial("ZHC")+cProcesso+cTipDes) )
                                lRet := .f.
                                Alert("Tipo de despesa informado na linha " + AllTrim(Str(nLinAtual)) + " não possui nenhum favorecido! Verifique...")
                                Exit
                            EndIf
                            */

                            // Cod Favorecido
                            If Empty(cCodFav)
                                lRet := .f.
                                Alert("Tipo de despesa informado na linha " + AllTrim(Str(nLinAtual)) + " exige um favorecido! Verifique...")
                                Exit
                            EndIf
                            //
                        EndIf

                        // Inclusões
                        If oModel:nOperation == 3
                            ZHB->( dbSetOrder(1) ) // ZHB_FILIAL, ZHB_PROCES, ZHB_TIPDES, R_E_C_N_O_, D_E_L_E_T_
                            If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cTipDes) )
                                lRet := .f.
                                Alert("O processo/despesa contido na linha " + AllTrim(Str(nLinAtual)) + " já está cadastrado! Verifique...")
                                Exit
                            EndIf
                        EndIf

                    EndIf

                    // @ticket 18141 - Fernando Macieira - 27/01/2022 - RM - Acordos - Integração Protheus - Novos tipos de despesas
                    If AllTrim(cTipDes) $ AllTrim(cDespFavor)
                        
                        If oModel:nOperation <> 5

                            // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos - Retirada do campo ZHC_TIPDES
                            /*
                            ZHC->( dbSetOrder(2) ) // ZHC_FILIAL+ZHC_PROCES+ZHC_TIPDES
                            If ZHC->( !dbSeek(FWxFilial("ZHC")+cProcesso+cTipDes) )
                                lRet := .f.
                                Alert("O processo/despesa contido na linha " + AllTrim(Str(nLinAtual)) + " não possui nenhum favorecido! Verifique parâmetro MV_#RMFAVO...")
                                Exit
                            EndIf
                            */

                            // Cod Favorecido
                            If Empty(cCodFav)
                                lRet := .f.
                                Alert("Tipo de despesa informado na linha " + AllTrim(Str(nLinAtual)) + " exige um favorecido! Verifique...")
                                Exit
                            EndIf
                            //

                        EndIf

                    EndIf
                
                    // Valor
                    nVlrDes := oModelGRID:GetValue("ZHB_VALOR")
                    If nVlrDes <= 0
                        lRet := .f.
                        Alert("O valor da despesa na linha " + AllTrim(Str(nLinAtual)) + " não foi informado! Verifique...")
                        Exit
                    EndIf

                    // Parcelas
                    nQtdPar := oModelGRID:GetValue("ZHB_PARCEL")
                    If nQtdPar <= 0
                        lRet := .f.
                        Alert("A quantidade de parcelas na linha " + AllTrim(Str(nLinAtual)) + " não foi informada! Verifique...")
                        Exit
                    EndIf

                    // Primeiro Vencimento
                    dVencto1 := oModelGRID:GetValue("ZHB_VENCTO")
                    If dVencto1 < msDate()
                        lRet := .f.
                        Alert("A data do vencimento da primeira parcela na linha " + AllTrim(Str(nLinAtual)) + " não foi informada ou precisa ser superior que a data de hoje! Verifique...")
                        Exit
                    EndIf

                    // Alterações
                    If oModel:nOperation == 4

                        cItem := oModelGRID:GetValue("ZHB_ITEM")

                        ZHB->( dbSetOrder(2) ) //ZHB_FILIAL+ZHB_PROCES+ZHB_ITEM+ZHB_TIPDES
                        ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cItem) )

                        If oModelGRID:GetValue("ZHB_GERSE2")
                            //If ZHB->ZHB_TIPDES <> cTipDes .or. ZHB->ZHB_VALOR <> nVlrDes .or. ZHB->ZHB_PARCEL <> nQtdPar .or. ZHB->ZHB_VENCTO <> dVencto1
                            If ZHB->ZHB_TIPDES <> cTipDes .or. ZHB->ZHB_VALOR <> nVlrDes .or. ZHB->ZHB_PARCEL <> nQtdPar .or. ZHB->ZHB_VENCTO <> dVencto1 .or. ZHB->ZHB_FAVORE <> cCodFav // @ticket 18141 - Fernando Macieira - 08/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
                                lRet := .f.
                                Alert("Alteração não permitida! Despesa da linha " + AllTrim(Str(nLinAtual)) + " já está no financeiro para pagamento... Delete a linha para que o título PR seja excluído e refaça a inclusão do item desejado...")
                                Exit
                            EndIf
                        EndIf

                        If oModelGRID:GetValue("ZHB_APROVA")
                            //If ZHB->ZHB_TIPDES <> cTipDes .or. ZHB->ZHB_VALOR <> nVlrDes .or. ZHB->ZHB_PARCEL <> nQtdPar .or. ZHB->ZHB_VENCTO <> dVencto1
                            If ZHB->ZHB_TIPDES <> cTipDes .or. ZHB->ZHB_VALOR <> nVlrDes .or. ZHB->ZHB_PARCEL <> nQtdPar .or. ZHB->ZHB_VENCTO <> dVencto1 .or. ZHB->ZHB_FAVORE <> cCodFav // @ticket 18141 - Fernando Macieira - 08/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
                                lRet := .f.
                                Alert("Alteração não permitida! Despesa da linha " + AllTrim(Str(nLinAtual)) + " já foi aprovado...")
                                Exit
                            EndIf
                        EndIf

                    EndIf

                    // Exclusão
                    If oModel:nOperation == 5
                        
                        // Aprovado e PR gerado
                        If (oModelGRID:GetValue("ZHB_GERSE2") .and. oModelGRID:GetValue("ZHB_APROVA")) .or. oModelGRID:GetValue("ZHB_GERPAR")
                            lRet := .f.
                            Alert("Exclusão não permitida! Despesa da linha " + AllTrim(Str(nLinAtual)) + " já foi aprovada e está no financeiro para pagamento...")
                            Exit
                        EndIf

                        // PR gerado mas ainda não aprovado
                        If oModelGRID:GetValue("ZHB_GERSE2") .and. !oModelGRID:GetValue("ZHB_APROVA") .and. !oModelGRID:GetValue("ZHB_GERPAR")
                            lRet := ExcPR(cProcesso, cTipDes, nQtdPar, oModelGrid:GetValue("ZHB_NUM"))
                            If !lRet
                                Exit
                            EndIf
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

    /*If lRet
        FWMsgRun(, {|| u_ADFIN120P() }, "Aguarde", "Gerando títulos para aprovação dos acordos trabalhistas ["+Time()+"] ...")
    EndIf*/
 
Return lRet

/*/{Protheus.doc} User Function FWSE2
    Visualiza/Altera parcelas dos títulos gerados após aprovação
    @type  Function
    @author Fernando Macieira
    @since 23/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function FWSE2()

    Local aArea   := GetArea()
    Local cFunBkp := FunName()
      
    SetFunName("FWSE2")

	FWMsgRun(, {|| RunFWSE2() }, "Aguarde", "Carregando títulos ["+Time()+"] ...") 

    SetFunName(cFunBkp)
    RestArea(aArea)

Return

/*/{Protheus.doc} RunFWSE2
    (long_description)
    @type  Static Function
    @author FWNM
    @since 23/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunFWSE2()
    
    Local aArea := GetArea()

    //Fontes
    Local cFontUti    := "Tahoma"
    Local oFontAno    := TFont():New(cFontUti,,-38)
    Local oFontSub    := TFont():New(cFontUti,,-20)
    Local oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
    Local oFontBtn    := TFont():New(cFontUti,,-14)

    //Janela e componentes
    Private oDlgGrp
    Private oPanGrid
    Private oGetGrid
    Private aHeaderGrid := {}
    Private aColsGrid := {}
    
    //Tamanho da janela
    Private    aTamanho := MsAdvSize()
    Private    nJanLarg := aTamanho[5]
    Private    nJanAltu := aTamanho[6]
 
    //Monta o cabecalho
    fMontaHead()
 
    //Criando a janela
    DEFINE MSDIALOG oDlgGrp TITLE "Parcelas dos títulos" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

        //Labels gerais
        @ 004, 003 SAY "RM"                       SIZE 200, 030 FONT oFontAno  OF oDlgGrp COLORS RGB(149,179,215) PIXEL
        @ 004, 050 SAY "Despesas"                 SIZE 200, 030 FONT oFontSub  OF oDlgGrp COLORS RGB(031,073,125) PIXEL
        @ 014, 050 SAY "Processos trabalhistas"   SIZE 200, 030 FONT oFontSubN OF oDlgGrp COLORS RGB(031,073,125) PIXEL
 
        //Botões 
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnLege  PROMPT "Efetivar"            SIZE 050, 018 OF oDlgGrp ACTION (FWMsgRun(, {|| fEfetiva() }, "Aguarde", "Efetivando alterações ["+Time()+"] ...")) FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnFech  PROMPT "Excluir Parcelas"    SIZE 050, 018 OF oDlgGrp ACTION (FWMsgRun(, {|| fExcluir() }, "Aguarde", "Excluindo parcelas ["+Time()+"] ..."))               PIXEL
        @ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnFech  PROMPT "Fechar"              SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End())            PIXEL
 
        //Dados
        @ 024, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "Edição (Para editar as colunas Vencimento/Valor basta clicar duas vezes ou posicionar e apertar <ENTER>" OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
            oPanGrid := tPanel():New(033, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
            oGetGrid := FWBrowse():New()
            oGetGrid:DisableFilter()
            oGetGrid:DisableConfig()
            oGetGrid:DisableReport()
            oGetGrid:DisableSeek()
            oGetGrid:DisableSaveConfig()
            oGetGrid:SetFontBrowse(oFontBtn)
            oGetGrid:SetDataArray()
            oGetGrid:lHeaderClick :=.f.

            /*
            oGetGrid:AddLegend("!Empty(oGetGrid:oData:aArray[oGetGrid:At(), 11])", "RED",    "Parcela possui baixa")
            oGetGrid:AddLegend("Empty(oGetGrid:oData:aArray[oGetGrid:At(), 11])" , "GREEN",  "Parcela não possui baixa")
            //oGetGrid:AddLegend("Empty(oGetGrid:oData:aArray[oGetGrid:At(), 4])", "BLACK",  "Sem Classificacao")            
            */

            oGetGrid:SetColumns(aHeaderGrid)
            oGetGrid:SetArray(aColsGrid)

            oGetGrid:SetEditCell(.T.) 	                                  // indica que o grid é editavel

            // Vencto
            oGetGrid:acolumns[09]:lEdit	:= .T.                            // Habilita a coluna 10 como editável
            oGetGrid:acolumns[09]:cReadVar:= 'aColsGrid[oGetGrid:nAt,09]' // Cria variavel de memoria
            //oGetGrid:bValidEdit := {|| fVldCmp() } // valida e move o valor para o array

            // Valor
            oGetGrid:acolumns[10]:lEdit	:= .T.                            // Habilita a coluna 11 como editável
            oGetGrid:acolumns[10]:cReadVar:= 'aColsGrid[oGetGrid:nAt,10]' // Cria variavel de memoria

            oGetGrid:bValidEdit := {|| fVldCmp() } // valida e move o valor para o array

            oGetGrid:SetOwner(oPanGrid)
            oGetGrid:Activate()
 
        FWMsgRun(, {|oSay| fMontDados(oSay) }, "Processando", "Carregando parcelas dos títulos...")    

    ACTIVATE MsDialog oDlgGrp CENTERED
 
    RestArea(aArea)

Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 23/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMontaHead()

    Local nAtual
    Local aHeadAux := {}
 
    //Adicionando colunas
    //[1] - Titulo
    //[2] - Tipo
    //[3] - Tamanho
    //[4] - Decimais
    //[5] - Máscara
    aAdd(aHeadAux, {"Prefixo"    , "C", TamSX3('E2_PREFIXO')[01],  0, ""})
    aAdd(aHeadAux, {"Numero"     , "C", TamSX3('E2_NUM')[01]    ,  0, ""})
    aAdd(aHeadAux, {"Parcela"    , "C", TamSX3('E2_PARCELA')[01],  0, ""})
    aAdd(aHeadAux, {"Tipo"       , "C", TamSX3('E2_TIPO')[01]   ,  0, ""})
    aAdd(aHeadAux, {"Fornecedor" , "C", TamSX3('E2_FORNECE')[01],  0, ""})
    aAdd(aHeadAux, {"Loja"       , "C", TamSX3('E2_LOJA')[01]   ,  0, ""})
    aAdd(aHeadAux, {"Fantasia"   , "C", TamSX3('E2_NOMFOR')[01] ,  0, ""})
    aAdd(aHeadAux, {"Natureza"   , "C", TamSX3('E2_NATUREZ')[01],  0, ""})
    aAdd(aHeadAux, {"Vencimento" , "D", TamSX3('E2_VENCTO')[01] ,  0, ""})
    aAdd(aHeadAux, {"Valor"      , "N", TamSX3('E2_VALOR')[01]  ,  TamSX3('E2_VALOR')[02], X3Picture('E2_VALOR')})
    aAdd(aHeadAux, {"Saldo"      , "N", TamSX3('E2_SALDO')[01]  ,  TamSX3('E2_SALDO')[02], X3Picture('E2_SALDO')})
    aAdd(aHeadAux, {"Ult Baixa"  , "D", TamSX3('E2_BAIXA')[01]  ,  0, ""})

    //Percorrendo e criando as colunas
    For nAtual := 1 To Len(aHeadAux)

        aAdd(aHeaderGrid, FWBrwColumn():New())
        
        aHeaderGrid[nAtual]:SetData(&("{||oGetGrid:oData:aArray[oGetGrid:At(),"+Str(nAtual)+"]}"))
        aHeaderGrid[nAtual]:SetTitle( aHeadAux[nAtual][1] )
        aHeaderGrid[nAtual]:SetType(aHeadAux[nAtual][2] )
        aHeaderGrid[nAtual]:SetSize( aHeadAux[nAtual][3] )
        aHeaderGrid[nAtual]:SetDecimal( aHeadAux[nAtual][4] )
        aHeaderGrid[nAtual]:SetPicture( aHeadAux[nAtual][5] )

    Next

Return
 
/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 23/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMontDados(oSay)

    Local aArea := GetArea()
    Local cQry  := ""
    Local nAtual := 0
    Local nTotal := 0
    
    // Dados necessários para central aprovação
    Local cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
    Local cTipoPR   := GetMV("MV_#ZC7TIP",,"PR")
    Local cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
    Local cFornece  := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja     := GetMV("MV_#ZC7LOJ",,"01")
    Local cTipoNDI  := GetMV("MV_#ACOTIP",,"NDI")

    //Zera a grid
    aColsGrid := {}
     
    //Montando a query
    oSay:SetText("Consultando...")

    cQry := " SELECT E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_NATUREZ, E2_VENCTO, E2_VALOR, E2_BAIXA, E2_SALDO "                                                  + CRLF
    cQry += " FROM "                                                    + CRLF
    cQry += "     " + RetSQLName('SE2') + " SE2 (NOLOCK)"               + CRLF
    cQry += " WHERE "                                                   + CRLF
    cQry += "     E2_FILIAL = '" + FWxFilial('SE2') + "' "              + CRLF
    cQry += "     AND E2_PREFIXO='"+cPrefixo+"' "                       + CRLF
    cQry += "     AND E2_NUM='"+ZHB->ZHB_NUM+"' "                       + CRLF
    cQry += "     AND E2_TIPO='"+cTipoNDI+"' "                          + CRLF
    cQry += "     AND E2_TIPO<>'"+cTipoPR+"' "                          + CRLF
    cQry += "     AND E2_FORNECE='"+cFornece+"' "                       + CRLF
    cQry += "     AND E2_LOJA='"+cLoja+"' "                             + CRLF
    cQry += "     AND E2_NATUREZ='"+cNaturez+"' "                       + CRLF
    cQry += "     AND SE2.D_E_L_E_T_ = ' ' "                            + CRLF
    cQry += " ORDER BY "                                                + CRLF
    cQry += "     3 "                                                   + CRLF
 
    //Executando a query
    oSay:SetText("Executando a consulta")
    PLSQuery(cQry, "QRY_SE2")
 
    //Se houve dados
    If QRY_SE2->(!EOF())
    
        //Pegando o total de registros
        DbSelectArea("QRY_SE2")
        Count To nTotal
        QRY_SE2->(DbGoTop())
 
        //Enquanto houver dados
        Do While QRY_SE2->(!EOF())
 
            //Muda a mensagem na regua
            nAtual++
            oSay:SetText("Adicionando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

            aAdd(aColsGrid, {   QRY_SE2->E2_PREFIXO,;
                                QRY_SE2->E2_NUM,;
                                QRY_SE2->E2_PARCELA,;
                                QRY_SE2->E2_TIPO,;
                                QRY_SE2->E2_FORNECE,;
                                QRY_SE2->E2_LOJA,;
                                QRY_SE2->E2_NOMFOR,;
                                QRY_SE2->E2_NATUREZ,;
                                QRY_SE2->E2_VENCTO,;
                                QRY_SE2->E2_VALOR,;
                                QRY_SE2->E2_SALDO,;
                                QRY_SE2->E2_BAIXA,;
                                .F. })
 
            QRY_SE2->(DbSkip())

        EndDo
 
    Else

        MsgStop("As parcelas do título " + ZHB->ZHB_NUM + " referente ao processo " + ZHB->ZHB_PROCES + " ainda não foram geradas!", "Atenção")
 
        aAdd(aColsGrid, { "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        "",;
                        CtoD("//"),;
                        0,;
                        0,;
                        CtoD("//"),;
                        .F. })

    EndIf
    
    QRY_SE2->(DbCloseArea())

    //Define o array
    oSay:SetText("Atribuindo os dados na tela")
    oGetGrid:SetArray(aColsGrid)
    oGetGrid:Refresh()
 
    RestArea(aArea)

Return
 
/*/{Protheus.doc} nomeStaticFunction
    Efetiva alterações/exclusões
    @type  Static Function
    @author FWNM
    @since 27/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fEfetiva()

    Local lRet := .t.
    Local nTotal := 0
    Local nTtZHB := 0
    Local i
    Local aDadNDI := {}
    Local lExecOK := .t.
    Local cParcAlt := ""

    If msgYesNo("Tem certeza de que deseja confirmar efetivação no financeiro das alterações realizadas?")
    
        For i:=1 to Len(acolsGrid)

            nTotal += aColsGrid[i,10]

            SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
            If SE2->( dbSeek(FWxFilial("SE2")+aColsGrid[i,1]+aColsGrid[i,2]+aColsGrid[i,3]+aColsGrid[i,4]+aColsGrid[i,5]+aColsGrid[i,6]) )
                If !Empty(SE2->E2_NUMBOR)
                    lRet := .f.
                    msgAlert("A parcela " + aColsGrid[i,3] + " está em borderô! Verifique...")
                    Exit
                EndIf
            EndIf

        Next i

        // Consisto valor total aprovado
        If lRet

            ZHB->( dbSetOrder(3) ) // ZHB_FILIAL, ZHB_NUM, R_E_C_N_O_, D_E_L_E_T_
            If ZHB->( dbSeek(FWxFilial("ZHB")+aColsGrid[1,2]) )
                nTtZHB := ZHB->ZHB_VALOR
            EndIf
            
            If nTotal <> nTtZHB
                lRet := .f.
                msgAlert("O total das parcelas não pode ser diferente do total aprovado! Verifique...")
            EndIf
        
        EndIf

        If lRet

            Begin Transaction

            For i:=1 to Len(acolsGrid)

                SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
                If SE2->( dbSeek(FWxFilial("SE2")+aColsGrid[i,1]+aColsGrid[i,2]+aColsGrid[i,3]+aColsGrid[i,4]+aColsGrid[i,5]+aColsGrid[i,6]) )

                    If aColsGrid[i,9] <> SE2->E2_VENCTO .or. aColsGrid[i,10] <> SE2->E2_VALOR // Houve alteração pelo usuário 

                        cParcAlt += SE2->E2_PARCELA + ", "

                        //gera log
                        u_GrLogZBE( msDate(), TIME(), cUserName, "EFETIVOU ALTERACOES TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFI118",;
                        "DATA/VALOR ANTES ALTERACAO " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                        RecLock("SE2", .F.)
                            SE2->E2_ORIGEM  := "FINA050" // Em função das customizações existentes
                        SE2->( msUnLock() )

                        aDadNDI := {}
                        aDadNDI := {{ "E2_FILIAL" , SE2->E2_FILIAL     , NIL },;
                                    { "E2_PREFIXO", SE2->E2_PREFIXO    , NIL },;
                                    { "E2_NUM"    , SE2->E2_NUM	       , NIL },;
                                    { "E2_PARCELA", SE2->E2_PARCELA    , NIL },;
                                    { "E2_TIPO"   , SE2->E2_TIPO       , NIL },;
                                    { "E2_FORNECE", SE2->E2_FORNECE    , NIL },;
                                    { "E2_LOJA"   , SE2->E2_LOJA       , NIL },;
                                    { "E2_VENCTO" , aColsGrid[i,9]        , NIL },;
                                    { "E2_VENCREA", aColsGrid[i,9]        , NIL },;
                                    { "E2_VALOR"  , aColsGrid[i,10]       , NIL }}

                        // Altero no Contas a Pagar
                        lMsErroAuto := .f.
                        msExecAuto( { |x,y,z| FINA050(x,y,z)},aDadNDI,, 4) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

                        If lMsErroAuto

                            lExecOK := .f.
                            lRet := .f.
                            DisarmTransaction()
                            MostraErro()
                            Break

                        Else

                            RecLock("SE2", .F.)
                                SE2->E2_ORIGEM  := "GPEM670" // Em função das customizações existentes
                                //SE2->E2_XDIVERG := "N" // Pois já foi aprovado anteriormente
                            SE2->( msUnLock() )

                            //gera log
							u_GrLogZBE( msDate(), TIME(), cUserName, "EFETIVOU ALTERACOES TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFI118",;
							"DATA/VALOR APOS ALTERACAO " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                        EndIf

                    EndIf

                EndIf

            Next i

            End Transaction

        EndIf

        If lExecOK .and. lRet
            msgInfo("Alterações efetivadas com sucesso no financeiro!" + CHR(13) + CHR(10) + "Parcelas alteradas: " + cParcAlt)
        Else
            Alert("Alterações não foram efetivadas! Verifique...")
        EndIf

    Else

        msgAlert("Você não confirmou a efetivação...")
    
    EndIf

Return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 23/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fVldCmp()

    Local lRet := .T.
    Local dDatafin := GetMV("MV_DATAFIN")
    
    Local dVencto := aColsGrid[oGetGrid:nAt,09]
    Local nValor  := aColsGrid[oGetGrid:nAt,10]
    Local nSaldo  := aColsGrid[oGetGrid:nAt,11]
    Local dBaixa  := aColsGrid[oGetGrid:nAt,12]
    
     // se o saldo for diferente do valor, título já possui baixas
    If !Empty(dBaixa) .or. nSaldo == 0
        lRet := .f.
        msgAlert("A parcela " + aColsGrid[oGetGrid:nAt,3] + " não pode ser alterada pois já sofreu baixa no financeiro! Verifique...")
    EndIf

    // Vencimento
    If lRet
        If dVencto < dDataFin
            lRet := .f.
            msgAlert("A parcela " + aColsGrid[oGetGrid:nAt,3] + " não pode ter vencimento inferior ao parâmetro MV_DATAFIN! Verifique...")
        EndIf
    EndIf

    // Vencimento / database
    If lRet
        If dVencto < dDataBase
            lRet := .f.
            msgAlert("A parcela " + aColsGrid[oGetGrid:nAt,3] + " não pode ter vencimento inferior a database! Verifique...")
        EndIf
    EndIf

    // Valor
    If lRet
        If nValor <= 0
            lRet := .f.
            msgAlert("A parcela " + aColsGrid[oGetGrid:nAt,3] + " não pode ter valor zero/negativo! Verifique...")
        EndIf
    EndIf

    If lRet
        oGetGrid:setArray(aColsGrid)	// Forço o Browse a ler os novos valores informados.
        oGetGrid:Refresh()			// Refresh do Grid
    EndIf

Return lRet

/*/{Protheus.doc} nomeStaticFunction
    Exclui contas pagar tipo PR (ainda não aprovado)
    @type  Static Function
    @author FWNM
    @since 27/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ExcPR(cProcesso, cTipDes, nQtdPar, cZHB_NUM, lDelAprova)

    Local lRet := .t.
    Local aDadPR := {}
    Local lExecOK := .t.
    Local cQtdPar := AllTrim(Str(nQtdPar))

    // Dados necessários para central aprovação
    Local cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
    Local cTipo     := GetMV("MV_#ZC7TIP",,"PR")
    Local cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
    Local cFornece  := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja     := GetMV("MV_#ZC7LOJ",,"01")
    Local cCodBlq   := GetMV("MV_#ZC7RC1",,"000013")

    Default lDelAprova := .f.

    Begin Transaction

        SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
        If SE2->( dbSeek(FWxFilial("SE2")+PadR(cPrefixo,TamSX3("E2_PREFIXO")[1])+cZHB_NUM+PadR(cQtdPar,TamSX3("E2_PARCELA")[1])+PadR(cTipo,TamSX3("E2_TIPO")[1])+cFornece+cLoja) )

            //gera log
            u_GrLogZBE( msDate(), TIME(), cUserName, "EXCLUIU TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFI118",;
            "DATA/VALOR ANTES EXCLUSAO " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )
            
            RecLock("SE2", .F.)
                SE2->E2_ORIGEM  := "FINA050" // Em função das customizações existentes
            SE2->( msUnLock() )

            aDadPR := {}
            aDadPR := { { "E2_FILIAL" , SE2->E2_FILIAL     , NIL },;
                        { "E2_PREFIXO", SE2->E2_PREFIXO    , NIL },;
                        { "E2_NUM"    , SE2->E2_NUM	       , NIL },;
                        { "E2_PARCELA", SE2->E2_PARCELA    , NIL },;
                        { "E2_TIPO"   , SE2->E2_TIPO       , NIL },;
                        { "E2_FORNECE", SE2->E2_FORNECE    , NIL },;
                        { "E2_LOJA"   , SE2->E2_LOJA       , NIL } }

            // Altero no Contas a Pagar
            lMsErroAuto := .f.
            msExecAuto( { |x,y,z| FINA050(x,y,z)},aDadPR,, 5) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

            If lMsErroAuto

                lExecOK := .f.
                lRet := .f.
                DisarmTransaction()
                MostraErro()
                Break

            Else

                ZC7->( dbSetOrder(1) ) // ZC7_FILIAL, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_CLIFOR, ZC7_LOJA, R_E_C_N_O_, D_E_L_E_T_
                If ZC7->( dbSeek(FWxFilial("ZC7")+PadR(cPrefixo,TamSX3("ZC7_PREFIX")[1])+PadR(cZHB_NUM,TamSX3("ZC7_NUM")[1])+PadR(cQtdPar,TamSX3("ZC7_PARCEL")[1])+cFornece+cLoja))
                    Do While ZC7->( !EOF() ) .and. ZC7->ZC7_FILIAL==FWxFilial("ZC7") .and. AllTrim(ZC7->ZC7_PREFIX)==AllTrim(cPrefixo) .and. AllTrim(ZC7->ZC7_NUM)==AllTrim(cZHB_NUM) .and. AllTrim(ZC7->ZC7_PARCEL)==AllTrim(cQtdPar) .and. AllTrim(ZC7->ZC7_CLIFOR)==AllTrim(cFornece) .and. AllTrim(ZC7->ZC7_LOJA)==AllTrim(cLoja)
                        RecLock("ZC7",.F.)
                            ZC7->( dbDelete() )
                        ZC7->( msUnLock() )
                        
                        ZC7->( dbSkip() )
                    EndDo
                EndIf
                
                ZHB->( dbSetOrder(1) ) // ZHB_FILIAL, ZHB_PROCES, ZHB_TIPDES, R_E_C_N_O_, D_E_L_E_T_
                If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cTipDes) )
                    RecLock("ZHB",.F.)
                        If lDelAprova
                            ZHB->ZHB_APROVA := .F.
                            ZHB->ZHB_GERPAR := .F.
                        EndIf
                        ZHB->ZHB_GERSE2 := .F.
                        ZHB->ZHB_NUM    := ""
                        ZHB->ZHB_STATUS := ""
                    ZHB->( msUnLock() )
                EndIf
            
            EndIf

        EndIf

    End Transaction
    
Return lRet

/*/{Protheus.doc} nomeStaticFunction
    Exclui parcelas geradas
    @type  Static Function
    @author FWNM
    @since 27/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fExcluir()

    Local lRet := .t.
    Local i
    Local aDadNDI  := {}
    Local aDadPR   := {}
    Local lExecOK  := .t.
    Local cParcExc := ""

    // Dados necessários para central aprovação
    Local cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
    Local cTipo     := GetMV("MV_#ZC7TIP",,"PR")
    Local cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
    Local cFornece  := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja     := GetMV("MV_#ZC7LOJ",,"01")
    Local lExibeLanc   := .f.
    Local lOnline      := .f.
    Local nSeqBx       := 1

    If msgYesNo("Tem certeza de que deseja excluir todas as parcelas geradas?")
    
        For i:=1 to Len(acolsGrid)

            SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
            If SE2->( dbSeek(FWxFilial("SE2")+aColsGrid[i,1]+aColsGrid[i,2]+aColsGrid[i,3]+aColsGrid[i,4]+aColsGrid[i,5]+aColsGrid[i,6]) )

                If !Empty(SE2->E2_NUMBOR)
                    lRet := .f.
                    msgAlert("A parcela " + aColsGrid[i,3] + " está em borderô! Verifique...")
                    Exit
                EndIf

                If !Empty(SE2->E2_BAIXA) .or. SE2->E2_SALDO == 0
                    lRet := .f.
                    msgAlert("A parcela " + aColsGrid[i,3] + " possui baixa! Verifique...")
                    Exit
                EndIf

            EndIf

        Next i

        If lRet

            Begin Transaction

            For i:=1 to Len(acolsGrid)

                cNumZHB := aColsGrid[i,2]
                
                SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
                If SE2->( dbSeek(FWxFilial("SE2")+aColsGrid[i,1]+cNumZHB+aColsGrid[i,3]+aColsGrid[i,4]+aColsGrid[i,5]+aColsGrid[i,6]) )

                    cParcExc += SE2->E2_PARCELA + ", "

                    //gera log
                    u_GrLogZBE( msDate(), TIME(), cUserName, "EXCLUIU PARCELAS TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFI118",;
                    "DATA/VALOR ANTES EXCLUSAO " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                    RecLock("SE2", .F.)
                        SE2->E2_ORIGEM  := "FINA050" // Em função das customizações existentes
                    SE2->( msUnLock() )

                    aDadNDI := {}
                    aDadNDI := {{ "E2_FILIAL" , SE2->E2_FILIAL     , NIL },;
                                { "E2_PREFIXO", SE2->E2_PREFIXO    , NIL },;
                                { "E2_NUM"    , SE2->E2_NUM	       , NIL },;
                                { "E2_PARCELA", SE2->E2_PARCELA    , NIL },;
                                { "E2_TIPO"   , SE2->E2_TIPO       , NIL },;
                                { "E2_FORNECE", SE2->E2_FORNECE    , NIL },;
                                { "E2_LOJA"   , SE2->E2_LOJA       , NIL } }

                    // Excluo no Contas a Pagar
                    lMsErroAuto := .f.
                    msExecAuto( { |x,y,z| FINA050(x,y,z)},aDadNDI,, 5) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

                    If lMsErroAuto

                        lExecOK := .f.
                        lRet := .f.
                        DisarmTransaction()
                        MostraErro()
                        Break

                    Else
                        
                        ZHB->( dbSetOrder(3) ) // ZHB_FILIAL, ZHB_NUM, R_E_C_N_O_, D_E_L_E_T_
                        If ZHB->( dbSeek(FWxFilial("ZHB")+cNumZHB))
                        
                            // Estorna baixa PR
                            SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
                            If SE2->( dbSeek(FWxFilial("SE2")+PadR(cPrefixo,TamSX3("E2_PREFIXO")[1])+ZHB->ZHB_NUM+PadR(ZHB->ZHB_PARCEL,TamSX3("E2_PARCELA")[1])+PadR(cTipo,TamSX3("E2_TIPO")[1])+cFornece+cLoja) )

                                //gera log
                                u_GrLogZBE( msDate(), TIME(), cUserName, "ESTORNOU BAIXA PR TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFI118",;
                                "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                                RecLock("SE2", .F.)
                                    SE2->E2_ORIGEM  := "FINA050" // Em função das customizações existentes
                                SE2->( msUnLock() )

                                aDadPR := {}
                                aDadPR := { { "E2_FILIAL" , SE2->E2_FILIAL     , NIL },;
                                            { "E2_PREFIXO", SE2->E2_PREFIXO    , NIL },;
                                            { "E2_NUM"    , SE2->E2_NUM	       , NIL },;
                                            { "E2_PARCELA", SE2->E2_PARCELA    , NIL },;
                                            { "E2_TIPO"   , SE2->E2_TIPO       , NIL },;
                                            { "E2_FORNECE", SE2->E2_FORNECE    , NIL },;
                                            { "E2_LOJA"   , SE2->E2_LOJA       , NIL } }

                                //Pergunte da rotina
                                AcessaPerg("FINA080", .F.)                  
                    
                                //Chama a execauto da rotina de baixa manual (FINA080)
                                lMsErroAuto := .F.
                                MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aDadPR, 5, .F., nSeqBx, lExibeLanc, lOnline)
                    
                                //Em caso de erro no estorno da baixa
                                If lMsErroAuto
                                    DisarmTransaction()
                                    MostraErro()
                                    Break
                                Else
                                    lRet := ExcPR(ZHB->ZHB_PROCES, ZHB->ZHB_TIPDES, ZHB->ZHB_PARCEL, ZHB->ZHB_NUM, .t.)
                                    If !lRet
                                        DisarmTransaction()
                                        Break
                                    EndIf
                                EndIf

                            EndIf

                        EndIf

                    EndIf

                EndIf

            Next i

            End Transaction

        EndIf

        If lExecOK .and. lRet
            msgInfo("Exclusões realizadas com sucesso no financeiro!" + CHR(13) + CHR(10) + "Parcelas excluídas: " + cParcExc)

            aColsGrid := {}
            aAdd(aColsGrid, { "",;
                "",;
                "",;
                "",;
                "",;
                "",;
                "",;
                "",;
                CtoD("//"),;
                0,;
                0,;
                CtoD("//"),;
                .F. })

            oGetGrid:SetArray(aColsGrid)
            oGetGrid:Refresh()

        Else
            Alert("Exclusões não foram realizadas! Verifique...")
        EndIf

    Else

        msgAlert("Você não confirmou a exclusão...")
    
    EndIf

Return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 28/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function GetZC7(E2NUM, E2PARCELA)
    
    // Dados necessários para central aprovação
    Local E2FILIAL  := FWxFilial("ZC7")
    Local E2PREFIXO := GetMV("MV_#ZC7PRE",,"GPE")
    Local E2TIPO    := GetMV("MV_#ZC7TIP",,"PR")
    Local E2FORNECE := GetMV("MV_#ZC7SA2",,"001901")
    Local E2LOJA    := GetMV("MV_#ZC7LOJ",,"01")

	Local aArea	  := GetArea()
	Local cAliasZC7 := "TMP"
	Local cComprador:= ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""
	Local lBloq     := .F.
	Local nUsado	:= 0
	Local nX   		:= 0
	Local nY        := 0
	Local oDlg
	Local oGet
	Local oBold
	Local cQuery   := ""
	Local aStruZC7 := {}
	Local sUsrAlt  := ""

    Default E2NUM := ""
    Default E2PARCELA := ""

	Private aCols   := {}
	Private aHeader := {}

	E2PARCELA := PadR(AllTrim(Str(E2PARCELA)),TamSX3("ZC7_PARCEL")[1])
    
    dbSelectArea("ZC7")
	dbSetOrder( 2 ) // ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_TIPO
	If MsSeek( E2FILIAL + E2FORNECE + E2LOJA + E2PREFIXO + E2NUM + E2PARCELA + E2TIPO )

		cTitle    := OemToAnsi("Aprovacao do Titulo")
		cTitDoc   := OemToAnsi("Titulo")
		cNumDoc   := ZC7->ZC7_NUM
		cComprador:= UsrRetName(ZC7->ZC7_USRALT)
		cStatus   := IIF( !EMPTY(ZC7->ZC7_USRAPR) , OemToAnsi( "TITULO APROVADO" ), OemToAnsi( "AGUARDANDO APROVAÇÃO" ) )

	Endif

	If !Empty(cNumDoc)
		
		aHeader:= {}
		aCols  := {}

		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("ZC7")

		While !Eof() .And. (SX3->X3_ARQUIVO == "ZC7")

			IF AllTrim(X3_CAMPO)$"ZC7_NIVEL/ZC7_OBS/ZC7_DTAPR"
				nUsado++
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
				
				If AllTrim(x3_campo) == "ZC7_NIVEL"
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Usuário" ),"bCR_NOME",   "",20,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Situação" ),"bCR_SITUACA","",20,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Tp.Aprovação" ),"bCR_TPAPROV","",15,0,"","","C","",""} )
				EndIf
				
			Endif
			
			dbSelectArea("SX3")
			dbSkip()

		EndDo

		aStruZC7 := ZC7->(dbStruct())
		cAliasZC7 := GetNextAlias()
		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("ZC7")+" ZC7 "
		cQuery += " WHERE ZC7_FILIAL = '"+E2FILIAL+"' "
		cQuery += " AND ZC7_CLIFOR = '"+E2FORNECE+"' AND ZC7_LOJA = '"+E2LOJA+"' " 
		cQuery += " AND ZC7_PREFIX = '"+E2PREFIXO+"' AND ZC7_NUM = '"+E2NUM+"' AND ZC7_PARCEL = '"+E2PARCELA+"' AND ZC7_TIPO = '"+E2TIPO+"' "
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZC7)
					
		For nX := 1 To Len(aStruZC7)
			If aStruZC7[nX][2]<>"C"
				TcSetField(cAliasZC7,aStruZC7[nX][1],aStruZC7[nX][2],aStruZC7[nX][3],aStruZC7[nX][4])
			EndIf
		Next nX
		
		dbSelectArea(cAliasZC7)
		
		While (cAliasZC7)->(!Eof())
			
            sUsrAlt := UsrRetName((cAliasZC7)->ZC7_USRALT)
			aadd(aCols,Array(nUsado+1))
			nY++
			
            For nX := 1 to Len(aHeader)
			
            	If aHeader[nX][02] == "bCR_NOME"
			
            		IF !EMPTY((cAliasZC7)->ZC7_USRAPR)
						aCols[nY][nX] := UsrRetName((cAliasZC7)->ZC7_USRAPR)
					Else
						aCols[nY][nX] := POSAPR( (cAliasZC7)->ZC7_TPBLQ , (cAliasZC7)->ZC7_NIVEL )
					EndIf
			
            		IF EMPTY((cAliasZC7)->ZC7_USRAPR)
						lBloq := .T.					
					EndIF
			
            	ElseIf aHeader[nX][02] == "bCR_SITUACA"
			
            		Do Case
			
            			Case EMPTY((cAliasZC7)->ZC7_USRAPR)
							cSituaca := OemToAnsi("Aguardando")
						//Case !EMPTY((cAliasZC7)->ZC7_USRAPR)
                        Case !EMPTY((cAliasZC7)->ZC7_USRAPR) .and. EMPTY((cAliasZC7)->ZC7_REPROV) // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 15/05/2020
							cSituaca := OemToAnsi("Aprovado")
						Case !EMPTY((cAliasZC7)->ZC7_USRAPR) .and. !EMPTY((cAliasZC7)->ZC7_REPROV)
							cSituaca := OemToAnsi("Reprovado")
					EndCase
			
            		aCols[nY][nX] := cSituaca
			
            	ElseIf aHeader[nX][02] == "bCR_TPAPROV"
					aCols[nY][nX] := If( EMPTY((cAliasZC7)->ZC7_EFEAPR) , IIF(!EMPTY((cAliasZC7)->ZC7_USRAPR), "Vistador",""), "Aprovador" )
			
            	ElseIf Alltrim(aHeader[nX][02]) == "ZC7_NIVEL"
					aCols[nY][nX] := If( EMPTY((cAliasZC7)->ZC7_NIVEL) , "01", (cAliasZC7)->ZC7_NIVEL )
			
            	ElseIf ( aHeader[nX][10] != "V")
					aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			
            	EndIf
			
            Next nX
			
            aCols[nY][nUsado+1] := .F.
			dbSelectArea(cAliasZC7)
			cStatus := IIF( EMPTY((cAliasZC7)->ZC7_USRAPR) , OemToAnsi("AGUARDANDO APROVAÇÃO") , IIF(!EMPTY((cAliasZC7)->ZC7_REPROV), OemToAnsi("REJEITADO"),OemToAnsi("APROVADO")) )
			dbSkip()
		
        EndDo
		
		If !Empty(aCols)
		
        	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
			If !Empty(sUsrAlt)
				@ 015,103 SAY OemToAnsi("Analista:") OF oDlg PIXEL SIZE 033,009 FONT oBold
				@ 014,138 MSGET sUsrAlt PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
			EndIF
			@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009
			If lBloq
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HRED
			Else
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HBLUE
			EndIf
			IF cStatus = "AGUARDANDO APROVAÇÃO"
				@ 132,140 BUTTON 'Solicitar Aprovação' SIZE 065 ,010  FONT oDlg:oFont ACTION (SOLAPR(E2FILIAL , E2FORNECE, E2LOJA, E2PREFIXO, E2NUM, E2PARCELA, E2TIPO),oDlg:End()) OF oDlg PIXEL
			EndIf
			@ 132,210 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL
			oGet:= MSGetDados():New(038,003,120,250,2,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED
	
    	Else
			ApMsgInfo("Este Titulo nao possui controle de aprovacao.")
	
    	EndIf
	
    Else
		ApMsgInfo("Este Titulo nao possui controle de aprovacao.")
	
    EndIf

	RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Ricardo Lima
    @since 15/05/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function POSAPR( ZC7TPBLQ , ZC7NIVEL )

	Local cQuery := ""
	Local sRet   := ""
	Local aArea	  := GetArea()

	cQuery := " SELECT ZCF_CODIGO, ZCF_APROVA "
	cQuery += " FROM "+RetSqlName("ZCF")+" "
	cQuery += " WHERE ZCF_CODIGO = '"+ZC7TPBLQ+"' AND ZCF_NIVEL >= '"+ZC7NIVEL+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZCF_NIVEL "

	If Select("ADFINB61") > 0
    	ADFINB61->(DbCloseArea())		
    EndIf	

    TcQuery cQuery New Alias "ADFINB61"

	sRet := ADFINB61->ZCF_APROVA+"-"+UsrRetName(ADFINB61->ZCF_APROVA)

	RestArea(aArea)

Return(sRet)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Ricardo Lima
    @since 15/05/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function SOLAPR(E2FILIAL , E2FORNECE, E2LOJA, E2PREFIXO, E2NUM, E2PARCELA, E2TIPO)

	Local cQuery := ""
	Local cMensagem := ""

	cQuery := " SELECT ZC3_SUPAPR FROM "+RetSqlName("ZC3")+" "
	cQuery += " WHERE ZC3_CODUSU IN ( "
	cQuery += " SELECT TOP 1 ZC7_USRAPR "
	cQuery += " FROM "+RetSqlName("ZC7")+" ZC7 "
	cQuery += " WHERE ZC7_FILIAL = '"+E2FILIAL+"' "
	cQuery += " AND ZC7_CLIFOR = '"+E2FORNECE+"' AND ZC7_LOJA = '"+E2LOJA+"' "
	cQuery += " AND ZC7_PREFIX = '"+E2PREFIXO+"' AND ZC7_NUM = '"+E2NUM+"' AND ZC7_PARCEL = '"+E2PARCELA+"' AND ZC7_TIPO = '"+E2TIPO+"' "
	cQuery += " AND ZC7_USRAPR <> ' ' "
	cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZC7_NIVEL DESC) "
	
    If Select("ADFINB61") > 0
    	ADFINB61->(DbCloseArea())		
    EndIf	
    
    TcQuery cQuery New Alias "ADFINB61"

	cMensagem := u_ADFINW46(  E2PREFIXO , E2NUM , E2PARCELA , E2FORNECE , E2LOJA , 0.0 , '' , '999999' , .F. , 'A' , '' )
	
    u_F050EnvWF( 'Central de Aprovação - Solicitação de Aprovação' , cMensagem , UsrRetMail(ADFINB61->ZC3_SUPAPR) , '' )

Return(.T.)

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 28/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function Run121P(lAuto)

    Default lAuto := .f.

	FWMsgRun(, {|| u_ADFIN121P(lAuto) }, "Aguarde", "Gerando parcelas das despesas aprovadas ["+Time()+"] ...")
    
Return
