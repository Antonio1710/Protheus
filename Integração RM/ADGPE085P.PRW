#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "Topconn.ch"

#define ZHNEXCLUS  '|ZHH_FILIAL|'
#define ZHMEXCLUS  '|ZHM_FILIAL|ZHM_CODZHN|'

/*/{Protheus.doc} User Function ADGPE085P
    Cadastro de elegíveis para o Kit Adoro (Frango).
    @type  Function
    @author Leonardo P. Monteiro
    @since 21/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 16833 - Leonardo P. Monteiro - 14/02/2022 - Adição do relacionamento com os uniformes.
/*/

Static cTitulo := "..:: Cadastro Grupos de Uniformes ::.."

User Function ADGPE085P()
    Local aArea   := GetArea()
    Local oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE085P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZHN")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE085P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE085P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE085P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE085P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel		:= MPFormModel():New("mdlADGPE085P",, {|| .T.})
    Local oStrutZHN	    := FWFormStruct(1,"ZHN")
    Local oStrutZHM     := FWFormStruct(1,"ZHM")
    Local aZHNZHM       := {}
    
    oModel:addFields("CABECZHN",nil,oStrutZHN)
    oModel:addGrid("DETAIZHM","CABECZHN", oStrutZHM)

    oModel:SetDescription(cTitulo)
    oModel:GetModel("CABECZHN"):SetDescription("Grupo de Uniformes")
    oModel:GetModel("DETAIZHM"):SetDescription("Cadastros dos Uniformes")
    oModel:GetModel("DETAIZHM"):SetOptional(.F.)
    
    oStrutZHM:SetProperty( "ZHM_CODZHH"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )

    aAdd( aZHNZHM, {"ZHM_FILIAL", "ZHN_FILIAL"} )
    aAdd( aZHNZHM, {"ZHM_CODZHN", "ZHN_CODIGO"} )

    oModel:SetRelation("DETAIZHM", aZHNZHM, ZHM->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
    oModel:GetModel("DETAIZHM"):SetUniqueLine({"ZHM_CODZHH"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}

    oModel:setPrimaryKey({"ZHN_FILIAL","ZHN_CODIGO"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE085P")
 Local oStrutZHN	:= FWFormStruct(2,"ZHN",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZHNEXCLUS)  })
 Local oStrutZHM	:= FWFormStruct(2,"ZHM",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZHMEXCLUS)  })
  
 DbSelectArea("ZHN")
 
 ZHN->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("CABEC_ZHN",oStrutZHN, "CABECZHN")
 oView:AddGrid("DETAIL_ZHM",oStrutZHM, "DETAIZHM")
   
 oView:createHorizontalBox("H_CABEC",30)
 oView:createHorizontalBox("H_DETAI",70)
 
 
 oView:setOwnerView("CABEC_ZHN","H_CABEC")
 oView:setOwnerView("DETAIL_ZHM","H_DETAI")
  
Return oView

Static Function fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue)
	Local lRet          := .T.
	Local oModel		:= FWModelActive()
	Local oModZHN		:= oModel:getModel("CABECZHN")
    Local oModZHM		:= oModel:getModel("DETAIZHM")
	Local aSaveLines 	:= FWSaveRows()


    if oModelSit:cId == "DETAIZHM"

        If cField == "ZHM_CODZHH"    
           
            DbSelectArea("ZHH")
            ZHH->(DbSetOrder(1))
            
            if ZHH->(DbSeek(xFilial("ZHH")+Alltrim(xValue),.F.))
                
                oModZHM:LoadValue("ZHM_CODZHN"  ,oModZHN:GetValue("ZHN_CODIGO") )
                oModZHM:LoadValue("ZHM_CODZHH"  ,ZHH->ZHH_CODIGO)
                oModZHM:LoadValue("ZHM_DESCRI"  ,ZHH->ZHH_DESCRI)
                //oModZHM:LoadValue("ZHM_TIPO"    ,ZHH->ZHH_TIPO)
                //oModZHM:LoadValue("ZHM_NUMKIT"  ,ZHH->ZHH_NUMKIT)
                //oModZHM:LoadValue("ZHM_OBRIGA"  ,"S")

                if select("QZHH") > 0
                    QZHH->(Dbclosearea())
                endif

                lRet := .T.
            else
                lRet := .F.
                Help( ,, 'HELP',, 'Não Existem uniformes cadastrados com esse código!.', 1, 0)
            endif
        
        endif

    Endif

   FWRestRows( aSaveLines )
Return lRet 
