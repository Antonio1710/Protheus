#include "Protheus.ch"
#include "FWMVCDef.ch"

#define ZHHEXCLUS  '|ZHH_FILIAL|' // Registro de produtos.
#define ZHIEXCLUS  '|ZHI_FILIAL|ZHI_CODIGO|' // Embalagens.

// Variaveis estaticas
Static cRotina  := "ADGPE083P"
Static cTitulo  := "..:: Cadastro de Uniformes ::.. "

/*/{Protheus.doc} User Function U_ADGPE083P()
    Cadastro de Uniformes.
    Chamado 16833
    @type  Function
    @author Leonardo P. Monteiro
    @since 24/01/2022
    @version 01
    @history Chamado 16833 - Leonardo P. Monteiro - 24/01/2022- Desenvolvimento inicial.
    @history Chamado 16833 - Leonardo P. Monteiro - 08/03/2022- Ajustes e adequações nos fontes conforme novas regras propostas e inconsistências encontradas.
    @history Chamado 16833 - Leonardo P. Monteiro - 08/03/2022- Ajustes e adequações nos fontes conforme novas regras propostas e inconsistências encontradas.
/*/

User Function ADGPE083P()

Local oBrowse
Local aAreaAtu := GetArea()          
Local cFunBkp  := FunName()


SetFunName("ADGPE083P")


// Instanciando FWMBROWSE - Somente com dicionario de dados
oBrowse := FWMBrowse():New()

// Setando a tabela de cadastros 
oBrowse:SetAlias("ZHH")

// Setando a descricao da rotina
oBrowse:SetDescription(cTitulo)

// Ativa o browse
oBrowse:Activate()

SetFunName(cFunBkp)
RestArea(aAreaAtu)   

Return


Static Function MenuDef()

    Local aRot := {}

    // Adicionando opcoes
    ADD OPTION aRot TITLE "Visualizar"    ACTION "VIEWDEF.ADGPE083P" OPERATION MODEL_OPERATION_VIEW   ACCESS 0 // OPERACAO 1
    ADD OPTION aRot TITLE "Incluir"       ACTION "VIEWDEF.ADGPE083P" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // OPERACAO 3
    ADD OPTION aRot TITLE "Alterar"       ACTION "VIEWDEF.ADGPE083P" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // OPERACAO 4
    ADD OPTION aRot TITLE "Excluir"    	  ACTION "VIEWDEF.ADGPE083P" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // OPERACAO 5

Return aRot


Static Function ModelDef()

// Criacao do objeto do modelo de dados
Local oModel  := Nil                   
Local aZHHZHI := {}

//Local bVldPre := {|| .T.} // Antes de abrir a tela
Local bVldPos := {|| TOKINC() } // Validacao ao clicar no botao confirmar
//Local bVldCom := {|| .T.} // Funcao chamada no commit
//Local bVldCan := {|| .T.} // Funcao chamada no cancelar

// Criacao da estrutura de dados utilizada na interface
Local oStPai   := FWFormStruct(1, "ZHH")
Local oStFilho := FWFormStruct(1, "ZHI")

oStPai:SetProperty( "ZHH_TIPO"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
oStPai:SetProperty( "ZHH_TIPO"   , MODEL_FIELD_WHEN, {|| Empty(FWFldGet("ZHH_TIPO")) } )

// Criando o modelo e os relacionamentos
oModel := MPFormModel():New("MODELDEF_MVC")

oModel:AddFields("ZHHMASTER", /*cOwner*/, oStPai)

oModel:AddGrid( "ZHIDETAIL",;
                "ZHHMASTER",; 
                oStFilho,; 
                /*bLinePre*/,; 
                /*bLinePost*/,; 
                /*bPre - Grid Inteiro*/,; 
                bVldPos,; 
                /*bLoad - Carga Modelo*/)



// Fazendo relacionamento entre pai e filho
aAdd( aZHHZHI, {"ZHI_FILIAL", "ZHH_FILIAL"} )
aAdd( aZHHZHI, {"ZHI_CODIGO", "ZHH_CODIGO"} )

oModel:SetRelation("ZHIDETAIL", aZHHZHI, ZHI->(IndexKey(3)) ) // IndexKey -> quero a ordenacao e depois filtrado
oModel:GetModel("ZHIDETAIL"):SetUniqueLine({"ZHI_UM"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}
oModel:SetPrimaryKey( {} )

// Setando as descricoes
oModel:SetDescription(cTitulo)
oModel:GetModel("ZHHMASTER"):SetDescription("Cadastro de Uniformes")
oModel:GetModel("ZHIDETAIL"):SetDescription("Unidades de Medida")

oModel:GetModel("ZHIDETAIL"):setNoInsertLine(.T.)
oModel:GetModel("ZHIDETAIL"):setNoDeleteLine(.T.)

Return oModel


Static Function ViewDef()

// Criacao do objeto do modelo de dados da interface do cadastro
Local oModel := FWLoadModel("ADGPE083P")

// Criacao da estrutura de dados utilizada na interface do cadastro
Local oStPai   := FWFormStruct(2, "ZHH",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZHHEXCLUS)  }) // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_
Local oStFilho := FWFormStruct(2, "ZHI",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZHIEXCLUS)  }) // pode se usar um terceiro parametro para filtrar os campos exibidos [ |cCampo| cCampo $ "SZZ1_NOME|SZZ1_

// Criando oView como nulo
Local oView := Nil

// Criando a VIEW que sera o retorno da funcao e setando o modelo da rotina
oView := FWFormView():New()
oView:SetModel(oModel)
                      
// Adicionando os campos do cabecalho e o grid dos filhos
oView:AddField("VIEW_ZHH", oStPai, "ZHHMASTER")
oView:AddGrid("DETAIL_ZHI", oStFilho, "ZHIDETAIL")

// Criando container com nome tela 100%
oView:CreateHorizontalBox("CABEC", 30)
oView:CreateHorizontalBox("GRID", 70)
                                   
// Amarrando a VIEW com as BOX
oView:SetOwnerView("VIEW_ZHH", "CABEC")
oView:SetOwnerView("DETAIL_ZHI", "GRID")

// Habilitando titulo
oView:EnableTitleView("VIEW_ZHH", "Tipos de Unidades de Medida")
oView:EnableTitleView("DETAIL_ZHI", "Unidades de Medida")

oView:AddIncrementField( 'DETAIL_ZHI' , 'ZHI_ORDEM')

// Forca o fechamento da janela na confirmacao
oView:SetCloseOnOK( {|| .t.} )
                        
// Remove os campos da grid
//oStFilho:RemoveField("HH_CODIGO")

Return oView
            


Static Function TOKINC()

//Local oModelPad := FWModelActive()
//Local nOpc      := oModelPad:GetOperation()
Local lRet      := .t.
                      
// Se a descricao estiver em branco
// Inibido conforme diretriz da KU Danielle
/*
If nOpc == 4 // Alteracao
	If AllTrim(ZS7->ZS7_STATUS) == "F"
		lRet := .f.
		Aviso("Atenção", "Período já fechado! Alteração não permitda...", {"OK"}, 03)
	EndIf
EndIf
*/

Return lRet


Static Function TokExc()

//Local oModelPad := FWModelActive()
Local lRet      := .t.
                      
// Se a descricao estiver em branco
If AllTrim(ZS7->ZS7_STATUS) == "F"
	lRet := .f.
	Aviso("Atenção", "Período já fechado! Exclusão não permitda...", {"OK"}, 03)
EndIf

Return lRet

Static Function fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue)
	Local lRet          := .T.
	Local oModel		:= FWModelActive()
	//Local oModZHH		:= oModel:getModel("VIEW_ZHH")
    Local oModZHI		:= oModel:getModel("ZHIDETAIL")
	Local aSaveLines 	:= FWSaveRows()
    //Local cQuery        := ""
    Local cValGrid      := ""
    Local nI            := 1

    if oModelSit:cId == "ZHHMASTER"

        If cField == "ZHH_TIPO"    
           
            DbSelectArea("ZHJ")
            ZHJ->(DbSetOrder(1))
            
            if ZHJ->(DbSeek(xFilial("ZHJ")+Left(xValue,2),.F.))

                oModZHI:setNoInsertLine(.F.)
                oModZHI:setNoDeleteLine(.F.)

                For nI := 1 To oModZHI:Length()
                    oModZHI:GoLine( nI )

                    IF !oModZHI:IsDeleted() .AND. !Empty(oModZHI:getValue("ZHI_UM"))
                        cValGrid += ","+oModZHI:getValue("ZHI_UM")
                    endif
                next nI

                while ZHJ->(!EOF()) .AND. ZHJ->ZHJ_TIPO==xValue
                    if !ZHJ->ZHJ_UM$cValGrid
                        oModZHI:goLine(oModZHI:Length())

                        if !Empty(oModZHI:getValue("ZHI_UM"))
                            oModZHI:addLine()
                        endif

                        oModZHI:setValue("ZHI_UM", ZHJ->ZHJ_UM)

                    endif

                    ZHJ->(DBSKIP())
                enddo

                oModZHI:setNoInsertLine(.T.)
                oModZHI:setNoDeleteLine(.T.)

            else
                lRet := .F.
                Help( ,, 'HELP',, 'Não existem unidades de medida cadastrados para esse uniforme!.', 1, 0)
            endif
        
        endif

    Endif

   FWRestRows( aSaveLines )
Return lRet 
