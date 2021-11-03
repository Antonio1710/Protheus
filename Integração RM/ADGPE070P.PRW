#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADGPE070P
    Cadastro de monitores para o Kit Adoro (Frango).
    @type  Function
    @author Leonardo P. Monteiro
    @since 21/07/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

    U_ADGPE070P()
/*/

#define ZI1_VISUAL  '|ZI1_MAT|ZI1_NOME|ZI1_MONITO|ZI1_MONATV|'

Static cTitulo := "..:: Cadastro de Monitores ::.."

User Function ADGPE070P()
    Local aArea   := GetArea()
    Private oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE070P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
    oBrowse:SetFilterDefault("ZI1->ZI1_MONITO='1'")

    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZI1")
    
    oBrowse:SetX3Tela("|ZI1_MAT|ZI1_NOME|ZI1_MONITO|ZI1_MONATV|")
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetFieldMark('ZI1_OK')
    //Legendas
    oBrowse:AddLegend( "ZI1->ZI1_MONATV == '1' ", "BR_VERDE"        ,  "Registro ativo." )
    oBrowse:AddLegend( "ZI1->ZI1_MONATV == '2' ", "BR_VERMELHO"     ,  "Registro inativo." )
    
    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE070P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Incluir'     ACTION 'MsAguarde({|| U_ADGPE071P() },"Função ADGPE071P","Novos monitores, aguarde...")' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE070P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'MsAguarde({|| U_GPE070PA("EXCLUI") },"Função GPE070PA","Excluindo monitor, aguarde...")' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Ativar'       ACTION 'MsAguarde({|| U_GPE070PA("ATIVAR") },"Função GPE070PA","Ativando monitor, aguarde...")' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Desativar'    ACTION 'MsAguarde({|| U_GPE070PA("DESATIVAR") },"Função GPE070PA","Desativando monitor, aguarde...")' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
 Local oModel		:= MPFormModel():New("mdlADGPE070P", {| cCampo |   '|' + AllTrim( cCampo ) + '|' $ ZI1_VISUAL	}, {|| .T.})
 Local oStrutZI1	:= FWFormStruct(1,"ZI1")
 
 oModel:SetDescription(cTitulo)
 
 oModel:addFields("CABEC_ZI1",nil,oStrutZI1)

 oModel:setPrimaryKey({"ZI1_FILIAL","ZI1_MAT","ZI1_PERIOD","ZI1_PRODUT"})

return oModel


Static Function viewDef()
 Local oView		:= Nil
 Local oModel		:= FWLoadModel("ADGPE070P")
 Local oStrutZI1	:= FWFormStruct(2,"ZI1",  {| cCampo |   '|' + AllTrim( cCampo ) + '|' $ ZI1_VISUAL	})
  
 DbSelectArea("ZI1")
 
 ZI1->(DbSetOrder(1))
  
 oView	:= FWFormView():New()
 oView:setModel(oModel)
 
 oView:GetProgressBar(.T.)
 
 oView:addField("V_CABEC_ZI1",oStrutZI1,"CABEC_ZI1")
   
 oView:createHorizontalBox("H_CABEC",100)
 oView:createVerticalBox("V_CABEC",100	,"H_CABEC")
 
 oView:setOwnerView("V_CABEC_ZI1","V_CABEC")
  
Return oView

User Function GPE070PA(cAcao)
    Local aArea     := GetArea()
    Local cMark     := oBrowse:Mark()
    Local cTexto    := ""
    
    ZI1->(Dbgotop())

    if cAcao == "EXCLUI"
        cTexto  := "exclusão"
    elseif cAcao == "ATIVAR"
        cTexto  := "ativação"
    elseif cAcao == "DESATIVAR"
        cTexto  := "inativar"
    ENDIF

    if MsgYesNo("Confirma a ação selecionada de "+cTexto+"?", "Exclusão")
        While ZI1->(!Eof())
            if oBrowse:Ismark(cMark)
                
                if cAcao == "EXCLUI"
                        
                    if RecLock("ZI1", .F.)
                        ZI1_MONITO	:= "2"
                        ZI1_MONATV	:= "2"
                        ZI1->(MsUnlock())
                    endif
                
                ElseIF cAcao$"ATIVA,DESATIVAR"
                    if RecLock("ZI1", .F.)
                        ZI1_MONATV	:= IIF(cAcao=="ATIVAR","1","2")
                        ZI1->(MsUnlock())
                    endif
                ENdif
            endif
            ZI1->(Dbskip())
        enddo

        MsgInfo("Rotina finalizada com sucesso", "Finalizada")
    else
        MsgAlert("Ação cancelada pelo operador.", "..:: Alerta ::..")
    endif

    RestArea(aArea)

    oBrowse:refresh()
return
