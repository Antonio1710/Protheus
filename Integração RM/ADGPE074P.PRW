#INCLUDE "totvs.ch"
#INCLUDE "FWMVCDef.ch"
#INCLUDE "Topconn.ch"

#define ZI5EXCLUS  '|ZHH_FILIAL|' // Registro de produtos.
#define ZHKEXCLUS  '|ZHI_FILIAL|ZHK_CODZI5|' // Embalagens.

/*/{Protheus.doc} User Function ADGPE074P
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
    @history chamado  - Leonardo P. Monteiro - 14/02/2022 - Adição do relacionamento com os uniformes.
/*/

Static cTitulo := "..:: Cadastro Seção ::.."

User Function ADGPE074P()
    Local aArea   := GetArea()
    Local oBrowse
    //Local cFunBkp := FunName()
     
    SetFunName("ADGPE074P")

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Grupo de inspeção Relacionado na tabela de clientes SA1 e SC5')
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMarkBrowse():New()
     
    //Setando a tabela de cadastro de grupo de inspeção
    oBrowse:SetAlias("ZI5")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()
     
    //SetFunName(cFunBkp)
    RestArea(aArea)
Return .T.

Static Function MenuDef() 

	Local aRotina := {}  
	
	ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 DISABLE MENU
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.ADGPE074P' OPERATION MODEL_OPERATION_DELETE ACCESS 0 DISABLE MENU
    
Return aRotina

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel		:= MPFormModel():New("mdlADGPE074P",, {|| .T.})
    Local oStrutZI5	    := FWFormStruct(1,"ZI5")
    Local oStrutZHK     := FWFormStruct(1,"ZHK")
    Local aZI5ZHK       := {}
    
    oModel:addFields("CABECZI5",nil,oStrutZI5)
    oModel:addGrid("DETAIZHK","CABECZI5", oStrutZHK)

    oModel:SetDescription(cTitulo)
    oModel:GetModel("CABECZI5"):SetDescription("Cadastro da Seção/Departamento")
    oModel:GetModel("DETAIZHK"):SetDescription("Unidades de Uniformes")
    oModel:GetModel("DETAIZHK"):SetOptional(.T.)
    
    oStrutZHK:SetProperty( "ZHK_CODZHH"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )

    aAdd( aZI5ZHK, {"ZHK_FILIAL", "ZI5_FILIAL"} )
    aAdd( aZI5ZHK, {"ZHK_CODZI5", "ZI5_CODIGO"} )

    oModel:SetRelation("DETAIZHK", aZI5ZHK, ZHK->(IndexKey(1)) ) // IndexKey -> quero a ordenacao e depois filtrado
    oModel:GetModel("DETAIZHK"):SetUniqueLine({"ZHK_CODZHH","ZHK_NUMKIT"}) // Nao repetir informacoes ou combinacoes {"CAMPO1", "CAMPO2", "CAMPON"}

    oModel:setPrimaryKey({"ZI5_FILIAL","ZI5_CODIGO"})

return oModel


Static Function viewDef()
    Local oView		:= Nil
    Local oModel		:= FWLoadModel("ADGPE074P")
    Local oStrutZI5	:= FWFormStruct(2,"ZI5",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZI5EXCLUS)  })
    Local oStrutZHK	:= FWFormStruct(2,"ZHK",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZHKEXCLUS)  })
    
    DbSelectArea("ZI5")
    
    ZI5->(DbSetOrder(1))
    
    oView	:= FWFormView():New()
    oView:setModel(oModel)
    
    oView:AddUserButton( 'Inclui Kits', 'CLIPS', {|oView| BUTTON1()} )
    
    oView:GetProgressBar(.T.)
    
    oView:addField("CABEC_ZI5",oStrutZI5, "CABECZI5")
    oView:AddGrid("DETAIL_ZHI",oStrutZHK, "DETAIZHK")
    
    oView:createHorizontalBox("H_CABEC",30)
    oView:createHorizontalBox("H_DETAI",70)
    
    
    oView:setOwnerView("CABEC_ZI5","H_CABEC")
    oView:setOwnerView("DETAIL_ZHI","H_DETAI")
  
Return oView

Static Function BUTTON1()
    Local nI        := 1
    Local cNumKit   := ""
	Local oModel		:= FWModelActive()
	Local oModZI5		:= oModel:getModel("CABECZI5")
    Local oModZHK		:= oModel:getModel("DETAIZHK")
	//Local aSaveLines 	:= FWSaveRows()

    cNumKit := U_ADGPE091P()

    if !Empty(cNumKit)

        For nI := 1 To oModZHK:Length()
            oModZHK:GoLine( nI )

            IF !oModZHK:IsDeleted() .AND. Alltrim(oModZHK:getValue("ZHK_NUMKIT"))$cNumKit
                oModZHK:DeleteLine()
            endif
        next nI

        cQuery := " SELECT ZHH_CODIGO, ZHH_DESCRI, ZHH_TIPO, ZHN_CODIGO "
        cQuery += " FROM "+ Retsqlname("ZHN") +" ZHN INNER JOIN "+ Retsqlname("ZHM") +" ZHM ON ZHN.D_E_L_E_T_='' AND ZHM.D_E_L_E_T_='' AND ZHN.ZHN_FILIAL=ZHM.ZHM_FILIAL AND ZHN.ZHN_CODIGO=ZHM.ZHM_CODZHN " 
        cQuery += "       INNER JOIN "+ Retsqlname("ZHH") +" ZHH ON ZHH.D_E_L_E_T_='' AND ZHH.ZHH_FILIAL=ZHM.ZHM_FILIAL AND ZHH.ZHH_CODIGO=ZHM.ZHM_CODZHH "
        cQuery += " WHERE ZHN.D_E_L_E_T_='' AND ZHN_FILIAL='"+ xFilial("ZHN") +"' AND ltrim(rtrim(ZHN.ZHN_CODIGO)) IN ("+ cNumKit+"); "
        
        Tcquery cQuery ALIAS "QZHH" NEW

        IF QZHH->(!EOF())
            

            while QZHH->(!EOF())
                
                oModZHK:goLine(oModZHK:Length())

                if !Empty(oModZHK:getValue("ZHK_CODZHH"))
                    oModZHK:addLine()
                endif

                oModZHK:LoadValue("ZHK_CODZI5"  ,oModZI5:GetValue("ZI5_CODIGO") )
                oModZHK:LoadValue("ZHK_CODZHH"  ,QZHH->ZHH_CODIGO)
                oModZHK:LoadValue("ZHK_DESCRI"  ,QZHH->ZHH_DESCRI)
                oModZHK:LoadValue("ZHK_TIPO"    ,QZHH->ZHH_TIPO)
                oModZHK:LoadValue("ZHK_NUMKIT"  ,QZHH->ZHN_CODIGO)
                oModZHK:LoadValue("ZHK_OBRIGA"  ,"S")

                QZHH->(DBSKIP())
            enddo

        Endif

        IF select("QZHH") > 0
            QZHH->(Dbclosearea())
        endif

        oModZHK:goLine(1)
    endif

return

Static Function fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue)
	Local lRet          := .T.
	Local oModel		:= FWModelActive()
	Local oModZI5		:= oModel:getModel("CABECZI5")
    Local oModZHK		:= oModel:getModel("DETAIZHK")
	Local aSaveLines 	:= FWSaveRows()


    if oModelSit:cId == "DETAIZHK"

        If cField == "ZHK_CODZHH"    
           
            DbSelectArea("ZHH")
            ZHH->(DbSetOrder(1))
            
            if ZHH->(DbSeek(xFilial("ZHH")+Alltrim(xValue),.F.))
                
                oModZHK:LoadValue("ZHK_CODZI5"  ,oModZI5:GetValue("ZI5_CODIGO") )
                oModZHK:LoadValue("ZHK_CODZHH"  ,ZHH->ZHH_CODIGO)
                oModZHK:LoadValue("ZHK_DESCRI"  ,ZHH->ZHH_DESCRI)
                oModZHK:LoadValue("ZHK_TIPO"    ,ZHH->ZHH_TIPO)
                //oModZHK:LoadValue("ZHK_NUMKIT"  ,ZHH->ZHH_NUMKIT)
                oModZHK:LoadValue("ZHK_OBRIGA"  ,"S")
                
                /*
                cNumKit := ZHH->ZHH_NUMKIT
                
                cValGrid    := Alltrim(xValue)

                For nI := 1 To oModZHK:Length()
                    oModZHK:GoLine( nI )

                    IF !oModZHK:IsDeleted() .AND. !Empty(oModZHK:getValue("ZHK_CODZHH"))
                        cValGrid += ","+Alltrim(oModZHK:getValue("ZHK_CODZHH"))
                    endif
                next nI

                cValGrid    := Formatin(cValGrid,",")

                cQuery := " SELECT * FROM "+ Retsqlname("ZHH") +" WHERE D_E_L_E_T_='' AND ZHH_FILIAL='"+ xFilial("ZHH") +"' AND ZHH_NUMKIT='"+cNumKit+"' AND ZHH_CODIGO NOT IN "+ cValGrid +" "
                
                Tcquery cQuery ALIAS "QZHH" NEW

                IF QZHH->(!EOF())
                    
                    if MsgYesNo("Existem outros uniformes que fazem parte do Kit. Deseja importar os demais itens?", "..:: ")
                        while QZHH->(!EOF())
                            
                            oModZHK:goLine(oModZHK:Length())

                            if !Empty(oModZHK:getValue("ZHK_CODZHH"))
                                oModZHK:addLine()
                            endif

                            oModZHK:LoadValue("ZHK_CODZI5"  ,oModZI5:GetValue("ZI5_CODIGO") )
                            oModZHK:LoadValue("ZHK_CODZHH"  ,QZHH->ZHH_CODIGO)
                            oModZHK:LoadValue("ZHK_DESCRI"  ,QZHH->ZHH_DESCRI)
                            oModZHK:LoadValue("ZHK_TIPO"    ,QZHH->ZHH_TIPO)
                            oModZHK:LoadValue("ZHK_NUMKIT"  ,QZHH->ZHH_NUMKIT)
                            oModZHK:LoadValue("ZHK_OBRIGA"  ,"S")

                            QZHH->(DBSKIP())
                        enddo

                    endif

                Endif

                IF select("QZHH") > 0
                    QZHH->(Dbclosearea())
                endif
                */

                lRet := .T.
            else
                lRet := .F.
                Help( ,, 'HELP',, 'Não xistem uniformes cadastrados com esse código!.', 1, 0)
            endif
        
        endif

    Endif

   FWRestRows( aSaveLines )
Return lRet 
