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

    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 3 campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel    := NIL
    Local oStruCab  := FWFormStruct(1, 'ZHC', {|cCampo| AllTRim(cCampo) $ "ZHC_FAVORE;ZHC_CPFCGC;ZHC_BANCO;ZHC_AGENCI;ZHC_CONTA;ZHC_DIGCTA;ZHC_TIPDES;ZHC_NOMDES;ZHC_CODIGO;"})
    Local oStruGrid := fModStruct()
 
    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('ADFI119M', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )
 
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZHC', NIL, oStruCab)
    oModel:AddGrid('MdGridZHC', 'MdFieldZHC', oStruGrid, , )
 
    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZHC', {;
            {'ZHC_FILIAL',  'FWxFilial("ZHC")'},;
            {"ZHC_CODIGO",  "ZHC_CODIGO"},;
            {"ZHC_CPFCGC",  "ZHC_CPFCGC"},;
            {"ZHC_FAVORE",  "ZHC_FAVORE"},;
            {"ZHC_BANCO" ,  "ZHC_BANCO"},;
            {"ZHC_AGENCI",  "ZHC_AGENCI"},;
            {"ZHC_CONTA" ,  "ZHC_CONTA"},;
            {"ZHC_DIGCTA",  "ZHC_DIGCTA"},;
            {"ZHC_TIPDES",  "ZHC_TIPDES"};
        }, ZHC->(IndexKey(3)))
     
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZHC"):SetMaxLine(9999)
    oModel:SetDescription("Processos do favorecido")
    oModel:SetPrimaryKey({"ZHC_FILIAL", "ZHC_CPFCGC"})
 
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
    Local oModel    := FWLoadModel('ADFI119')
    Local oStruCab  := FWFormStruct(2, "ZHC", {|cCampo| AllTRim(cCampo) $ "ZHC_FAVORE;ZHC_CPFCGC;ZHC_BANCO;ZHC_AGENCI;ZHC_CONTA;ZHC_DIGCTA;ZHC_TIPDES;ZHC_NOMDES;ZHC_CODIGO;"})
    Local oStruGRID := fViewStruct()
 
    //Define que no cabeçalho não terá separação de abas (SXA)
    oStruCab:SetNoFolder()
 
    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
 
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZHC, e uma Grid vinculando com MdGridZHC
    oView:AddField('VIEW_ZHC', oStruCab, 'MdFieldZHC')
    oView:AddGrid ('GRID_ZHC', oStruGRID, 'MdGridZHC' )
 
    //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 35)
    oView:CreateHorizontalBox("GRID", 65)
 
    //Vincula o MAIN com a VIEW_ZHC e a GRID com a GRID_ZHC
    oView:SetOwnerView('VIEW_ZHC', 'MAIN')
    oView:SetOwnerView('GRID_ZHC', 'GRID')
    oView:EnableControlBar(.T.)
 
    //Define o campo incremental da grid como o ZHC_ITEM
    oView:AddIncrementField('GRID_ZHC', 'ZHC_ITEM')

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
    oStruct := FWFormStruct(1, 'ZHC')

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

    Local cCampoCom := "ZHC_FAVORE;ZHC_CPFCGC;ZHC_BANCO;ZHC_AGENCI;ZHC_CONTA;ZHC_DIGCTA;ZHC_TIPDES;ZHC_NOMDES;ZHC_CODIGO;"
    Local oStruct
 
    //Irá filtrar, e trazer todos os campos, menos os que tiverem na variável cCampoCom
    oStruct := FWFormStruct(2, "ZHC", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})

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
    Local oModelGRID := oModel:GetModel('MdGridZHC')
    Local oModelMain := oModel:GetModel('MdFieldZHC')
    Local cCPFCGC    := oModelMain:GetValue("ZHC_CPFCGC")
    Local cFavorec   := oModelMain:GetValue("ZHC_FAVORE")
    Local cBanco     := oModelMain:GetValue("ZHC_BANCO")
    Local cAgencia   := oModelMain:GetValue("ZHC_AGENCI")
    Local cConta     := oModelMain:GetValue("ZHC_CONTA")
    Local cDigCta    := oModelMain:GetValue("ZHC_DIGCTA")
    Local cTipDes    := oModelMain:GetValue("ZHC_TIPDES")
    Local cCodFavor  := oModelMain:GetValue("ZHC_CODIGO")
    Local cProcesso  := ""

    If Empty(cCodFavor)
        lRet := .f.
        Alert("Código do Favorecido não preenchido! Verifique...")
    Else
        If oModel:nOperation == 3
            ZHC->( dbSetOrder(3) ) // ZHC_FILIAL+ZHC_CODIGO
            If ZHC->( dbSeek(FWxFilial("ZHC")+cCodFavor) )
                lRet := .f.
                Alert("Código Favorecido já cadastrado! Verifique...")
            EndIf
        EndIf
    EndIf

    If Empty(cCPFCGC)
        lRet := .f.
        Alert("CPF/CNPJ não preenchido! Verifique...")
    Else
        If oModel:nOperation == 3 .or. oModel:nOperation == 4
            ZHC->( dbSetOrder(1) ) // ZHC_FILIAL+ZHC_CPFCGC+ZHC_PROCES
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

    If lRet
        If Empty(cTipDes)
            lRet := .f.
            Alert("Tipo da Despesa não preenchido! Verifique...")
        Else
            SX5->( dbSetOrder(1) )
            If SX5->( !dbSeek(FWxFilial("SX5")+"_R"+cTipDes) )
                lRet := .f.
                Alert("Tipo de despesa informado não existe! Verifique...")
            EndIf
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

                cProcesso := oModelGRID:GetValue("ZHC_PROCES")

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
                If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cTipDes))
                    If ZHB->ZHB_GERSE2 .or. !Empty(ZHB->ZHB_NUM)
                        lRet := .f.
                        Alert("Exclusão não permitida pois favorecido possui título integrado no financeiro! Verifique as despesas do processo da linha " + AllTrim(Str(nLinAtual)) + " ...")
                        Exit
                    EndIf
                EndIf
            EndIf

        Next nLinAtual

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
