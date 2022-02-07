#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "Topconn.ch"

#define ZI1EXCLUS  '|ZI1_FILIAL|' // Registro de produtos.
#define ZHKEXCLUS  '|ZHK_FILIAL|ZHK_MAT|' // Embalagens.

/*/{Protheus.doc} User Function U_ADGPE081P()
    Cadastro de elegíveis para o controle de uniformes/armários/linhas de transportes.
    Chamado 16833
    @type  Function
    @author Leonardo P. Monteiro
    @since 21/01/2022
    @version 01
    @history Chamado 16833 - Leonardo P. Monteiro - 24/01/2022- Desenvolvimento inicial.
    
/*/

Static cTitulo := "..:: Cadastro de Colaboradores (Uniformes) ::.."

User Function ADGPE081P()
    Local   aArea       := GetArea()
    Local   oBrowse
    Private oADOGPE     := ADOGPE():new()
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE081P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZI1")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( " Empty(ZI1->ZI1_DEMISS) .AND. ZI1->ZI1_CODSIT == 'A' .AND. (ZI1->ZI1_STNVCO == '1' .OR. ZI1->ZI1_STDEMI =='1' .OR. ZI1->ZI1_STSITU=='1' .OR. ZI1->ZI1_STFUNC=='1' .OR. ZI1->ZI1_STSECA == '1' .OR. ZI1->ZI1_STHORA =='1') ", "BR_AZUL"     ,  "Status Ativo (aguardando revisão cadastral)." )
    oBrowse:AddLegend( " Empty(ZI1->ZI1_DEMISS) .AND. ZI1->ZI1_CODSIT == 'A' ", "BR_VERDE"    ,  "Status Ativo." )
    oBrowse:AddLegend( " Empty(ZI1->ZI1_DEMISS) .AND. ZI1->ZI1_CODSIT == 'Z' ", "BR_WHITE"    ,  "Admissão Próx. Mês." )
    oBrowse:AddLegend( " Empty(ZI1->ZI1_DEMISS) .AND. ZI1->ZI1_CODSIT == 'F' ", "BR_LARANJA"  ,  "Férias." )
    oBrowse:AddLegend( " Empty(ZI1->ZI1_DEMISS) .AND. ZI1->ZI1_CODSIT == 'E' ", "BR_AMARELO"  ,  "Lic. Maternidade." )
    oBrowse:AddLegend( " Empty(ZI1->ZI1_DEMISS) .AND. ZI1->ZI1_CODSIT$'I,P,T,U,R,C' ", "BR_VIOLETA"  ,  "Status Afastado." )
    oBrowse:AddLegend( "!Empty(ZI1->ZI1_DEMISS) .OR.  ZI1->ZI1_CODSIT$'D,V' ", "BR_BLACK" ,  "Status Desligado." )
    
    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE081P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE081P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE081P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE081P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Importar RM'  ACTION 'MsAguarde({|| U_ADGPE082P() },"Função ADGPE082P","Importando os dados do RM, aguarde...")' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel		:= MPFormModel():New("mdlADGPE081P",, {|| .T.})
    Local oStrutZI1	:= FWFormStruct(1,"ZI1")
    Local oStrutZHK	:= FWFormStruct(1,"ZHK")
    Local aZI1ZHK   := {}
    
    oModel:SetDescription(cTitulo)
    
    oModel:addFields("CABEC_ZI1",nil,oStrutZI1)
    oModel:addGrid("DETAL_ZHK","CABEC_ZI1",oStrutZHK)

    oModel:SetDescription(cTitulo)
    oModel:GetModel("CABEC_ZI1"):SetDescription("Cadastro do Colaborador")
    oModel:GetModel("DETAL_ZHK"):SetDescription("Cadastro de Uniformes")
    oModel:GetModel("DETAL_ZHK"):SetOptional(.T.)
    oModel:GetModel("DETAL_ZHK"):SetOnlyQuery(.T.)
    oModel:GetModel("DETAL_ZHK"):SetNoInsertLine(.T.)
    oModel:GetModel("DETAL_ZHK"):SetNoUpdateLine(.T.)
    oModel:GetModel("DETAL_ZHK"):SetNoDeleteLine(.T.)

    oStrutZI1:SetProperty( "ZI1_CODZHL"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )

    aAdd( aZI1ZHK, {"ZHK_FILIAL", "xFilial('ZHK')"} )
    aAdd( aZI1ZHK, {"ZHK_CODZI5", "ZI1_SECAO"} )

    oModel:SetRelation("DETAL_ZHK", aZI1ZHK, ZHK->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
    oModel:GetModel("DETAL_ZHK"):SetUniqueLine({"ZHK_CODZHH"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}

    oModel:setPrimaryKey({"ZI1_FILIAL","ZI1_MAT","ZI1_PERIOD","ZI1_PRODUT"})

return oModel


Static Function viewDef()
    Local oView		:= Nil
    Local oModel		:= FWLoadModel("ADGPE081P")
    Local oStrutZI1	:= FWFormStruct(2,"ZI1",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZI1EXCLUS)  })
    Local oStrutZHK	:= FWFormStruct(2,"ZHK",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZHKEXCLUS)  })
    
    DbSelectArea("ZI1")
    
    ZI1->(DbSetOrder(1))
    
    oView	:= FWFormView():New()
    oView:setModel(oModel)
    
    oView:GetProgressBar(.T.)
    
    oView:addField("V_CABEC_ZI1",oStrutZI1,"CABEC_ZI1")
    oView:AddGrid("V_DETAIL_ZHK",oStrutZHK, "DETAL_ZHK")
    
    oView:createHorizontalBox("H_CABEC",60)
    oView:createHorizontalBox("H_DETAI",40)
    
    oView:setOwnerView("V_CABEC_ZI1","H_CABEC")
    oView:setOwnerView("V_DETAIL_ZHK","H_DETAI")
  
Return oView


Static Function fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue)
	Local lRet          := .T.
	Local oModel		:= FWModelActive()
	Local oModZI1		:= oModel:getModel("CABEC_ZI1")
    //Local oModZHK		:= oModel:getModel("DETAL_ZHK")
	Local aSaveLines 	:= FWSaveRows()
    //Local cQuery        := ""
    Local cMat      := ""
    Local cCodArm   := ""
    
    if oModelSit:cId == "CABEC_ZI1"

        If cField == "ZI1_CODZHL"    
           
            // Posiciona no registro do uniforme vinculado ao departamento.
            cMat       := Alltrim(oModZI1:GetValue("ZI1_MAT"))
            cCodArm    := Alltrim(oModZI1:GetValue("ZI1_CODZHL"))
            
            IF !Empty(cCodArm)
                cQuery := " SELECT ZI1_MAT, ZI1_NOME "
                cQuery += " FROM "+ RetSqlName("ZI1") +" (NOLOCK) "
                cQuery += " WHERE D_E_L_E_T_='' AND ZI1_MAT !='"+ cMat +"' AND ZI1_CODZHL='"+ cCodArm +"'; "
                
                Tcquery cQuery ALIAS "QZHL" NEW

                if QZHL->(!EOF())
                    lRet := .F.
                    Help( ,, 'HELP',, 'Armário já vinculado ao colaborador '+ Alltrim(QZHL->ZI1_MAT) +'-'+ Alltrim(QZHL->ZI1_NOME) +'!.', 1, 0)
                ELSE
                    lRet := .T.
                endif

                QZHL->(DBCLOSEAREA())

            endif
        endif

    Endif

   FWRestRows( aSaveLines )
Return lRet 
