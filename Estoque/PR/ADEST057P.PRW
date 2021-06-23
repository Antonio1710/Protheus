#include "TOTVS.CH"
#Include "Topconn.ch"
#Include "FWMVCDEF.CH"
#include "fileio.ch"

/*/{Protheus.doc} User Function ADEST057P
    Modelo MVC para manutenção do cadastro dos Requisitos de Mercado.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 23/02/2021
    @version 01
    @history Chamado T.I. - Leonardo P. Monteiro - 19/04/2021 - Pequena validação na quantidade de dígito no campo ZE1_REGIST (Núm Registro) e permitir o cadastro do mesmo Partnumber várias vezes.
    @history Chamado 8465 - Leonardo P. Monteiro - 30/04/2021 - Melhoria na rotina para criação da sub-categoria do PGA.
    @history Chamado 8465 - Leonardo P. Monteiro - 05/05/2021 - Ajuste no cadastro das categorias.
    /*/

#define ZE1VISUAL  '|ZE1_FILIAL|ZE1_ARQB64|' // Registro de produtos.
#define ZE5VISUAL  '|ZE5_FILIAL|ZE5_ZE1REG|' // Embalagens.
#define ZE6VISUAL  '|ZE6_FILIAL|ZE6_ZE1REG|' // Rótulos.
#define ZE7AVISUAL '|ZE7_FILIAL|ZE7_ZE1REG|ZE7_NIVEL|ZE7_ITESUP|' // Ingredientes nível 1.
#define ZE7BVISUAL '|ZE7_FILIAL|ZE7_ZE1REG|ZE7_NIVEL|' // Ingredientes nível 2.
#define ZE8VISUAL  '|ZE8_FILIAL|ZE8_ZE1REG|' // Arquivos de imagens.
#define ZE9VISUAL  '|ZE9_FILIAL|ZE9_REGZE1|' // Aributos Específicos.
#define ZEDVISUAL  '|ZED_FILIAL|ZED_REGZE1|ZED_ITEM|' // Categoria.

// --------------------------------------------------------------------------------------------------------
// InÃ­cio da ViewDef e ModelDef.
// --------------------------------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel		:= MPFormModel():New("mdlADEST057P",, {|| .T.})
    Local oStrutZE1	    := FWFormStruct(1,"ZE1")
    Local oStrutZE5	    := FWFormStruct(1,"ZE5")
    Local oStrutZE6	    := FWFormStruct(1,"ZE6")
    Local oStruZE7A	    := FWFormStruct(1,"ZE7")
    Local oStruZE7B	    := FWFormStruct(1,"ZE7")
    Local oStrutZE8	    := FWFormStruct(1,"ZE8")
    Local oStrutZE9	    := FWFormStruct(1,"ZE9")
    Local oStrutZED	    := FWFormStruct(1,"ZED")

    Local aZE5Rel       := {}
    Local aZE6Rel       := {}
    Local aZE7ARel      := {}
    Local aZE7BRel      := {}
    Local aZE8Rel       := {}
    Local aZE9Rel       := {}
    Local aZEDRel       := {}
    
    //SetProperty
    oStruZE7A:SetProperty( "ZE7_CODING"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
    oStruZE7A:SetProperty( "ZE7_PORCEN"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
    //oStruZE7B:SetProperty( "ZE7_CODING"   , MODEL_FIELD_WHEN, {|| fWhenFld("ZE7_CODING") } )
    
    oStruZE7B:SetProperty( "ZE7_CODING"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
    oStruZE7B:SetProperty( "ZE7_PORCEN"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
    oStrutZED:SetProperty(  "ZED_CODCAT"   , MODEL_FIELD_VALID, {|oModelSit, cField, xValue, nLine, xCurrentValue| fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue) } )
    
    oModel:SetDescription("..:: Cadastro Requisitos de Mercado ::..")
    
    // CabeÃ§alho ZT3 (Pedidos)
    oModel:addFields("CABEC_ZE1",nil,oStrutZE1)
    oModel:addGrid("DETAIL_ZE5" ,"CABEC_ZE1",oStrutZE5)
    oModel:addGrid("DETAIL_ZE6" ,"CABEC_ZE1",oStrutZE6)
    oModel:addGrid("DETAI_ZE7A" ,"CABEC_ZE1",oStruZE7A)
    oModel:addGrid("DETAI_ZE7B" ,"CABEC_ZE1",oStruZE7B)
    oModel:addGrid("DETAIL_ZE8" ,"CABEC_ZE1",oStrutZE8)
    oModel:addGrid("DETAIL_ZE9" ,"CABEC_ZE1",oStrutZE9)
    oModel:addGrid("DETAIL_ZED" ,"CABEC_ZE1",oStrutZED)

    aAdd( aZE5Rel, {"ZE5_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZE5Rel, {"ZE5_ZE1REG", "ZE1_REGIST"} )

    aAdd( aZE6Rel, {"ZE6_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZE6Rel, {"ZE6_ZE1REG", "ZE1_REGIST"} )

    aAdd( aZE7ARel, {"ZE7_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZE7ARel, {"ZE7_ZE1REG", "ZE1_REGIST"} )
    aAdd( aZE7ARel, {"ZE7_NIVEL", "'0'"} )
    
    aAdd( aZE7BRel, {"ZE7_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZE7BRel, {"ZE7_ZE1REG", "ZE1_REGIST"} )
    aAdd( aZE7BRel, {"ZE7_NIVEL", "'1'"} )

    aAdd( aZE8Rel, {"ZE8_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZE8Rel, {"ZE8_REGZE1", "ZE1_REGIST"} )

    aAdd( aZE9Rel, {"ZE9_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZE9Rel, {"ZE9_REGZE1", "ZE1_REGIST"} )

    aAdd( aZEDRel, {"ZED_FILIAL", "ZE1_FILIAL"} )
    aAdd( aZEDRel, {"ZED_REGZE1", "ZE1_REGIST"} )

    oModel:SetRelation("DETAIL_ZE5"  , aZE5Rel  , ZE5->(IndexKey(1)) )
    oModel:SetRelation("DETAIL_ZE6"  , aZE6Rel  , ZE6->(IndexKey(1)) )
    oModel:SetRelation("DETAI_ZE7A"  , aZE7ARel , ZE7->(IndexKey(1)) )
    oModel:SetRelation("DETAI_ZE7B"  , aZE7BRel , ZE7->(IndexKey(1)) )
    oModel:SetRelation("DETAIL_ZE8"  , aZE8Rel  , ZE8->(IndexKey(1)) )
    oModel:SetRelation("DETAIL_ZE9"  , aZE9Rel  , ZE9->(IndexKey(1)) )
    oModel:SetRelation("DETAIL_ZED"  , aZEDRel  , ZED->(IndexKey(1)) )
    
    oModel:GetModel("DETAIL_ZED"):SetUniqueLine({"ZED_CODCAT"})
    
    oModel:getModel("DETAI_ZE7B"):setOptional(.T.)
    oModel:getModel("DETAIL_ZE8"):setOptional(.T.)
    oModel:GetModel("DETAI_ZE7B"):SetUniqueLine({"ZE7_CODING","ZE7_ITESUP"})
    oModel:setPrimaryKey({"ZE1_FILIAL","ZE1_REGIST"})

return oModel


Static Function viewDef()
    Local oView		    := Nil
    //Local nOper         := 2
    Local oModel	    := FWLoadModel("ADEST057P")
    Local oStrutZE1	    := FWFormStruct(2,"ZE1",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE1VISUAL)  })
    Local oStrutZE5	    := FWFormStruct(2,"ZE5",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE5VISUAL)  })
    Local oStrutZE6	    := FWFormStruct(2,"ZE6",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE6VISUAL)  })
    Local oStruZE7A	    := FWFormStruct(2,"ZE7",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE7AVISUAL) })
    Local oStruZE7B	    := FWFormStruct(2,"ZE7",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE7BVISUAL) })
    Local oStrutZE8	    := FWFormStruct(2,"ZE8",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE8VISUAL)  })
    Local oStrutZE9	    := FWFormStruct(2,"ZE9",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZE9VISUAL)  })
    Local oStrutZED	    := FWFormStruct(2,"ZED",{| cCampo | !(AllTrim( cCampo ) + '|' $ ZEDVISUAL)  })
    
    DbSelectArea("ZE1")
    
    ZE1->(DbSetOrder(1))
    
    oView	:= FWFormView():New()
    oView:setModel(oModel)
    
    oView:GetProgressBar(.T.)
    
    oView:addField("V_CABEC_ZE1"   , oStrutZE1 , "CABEC_ZE1")
    oView:addGrid("V_DETAIL_ZE5"   , oStrutZE5 , "DETAIL_ZE5")
    oView:addGrid("V_DETAIL_ZE6"   , oStrutZE6 , "DETAIL_ZE6")
    oView:addGrid("V_DETAI_ZE7A"   , oStruZE7A , "DETAI_ZE7A")
    oView:addGrid("V_DETAI_ZE7B"   , oStruZE7B , "DETAI_ZE7B")
    oView:addGrid("V_DETAIL_ZE8"   , oStrutZE8 , "DETAIL_ZE8")
    oView:addGrid("V_DETAIL_ZE9"   , oStrutZE9 , "DETAIL_ZE9")
    oView:addGrid("V_DETAIL_ZED"   , oStrutZED , "DETAIL_ZED")
    
    oView:createHorizontalBox("H_GERAL"    ,100)
    
    oView:CreateFolder("PASTAS","H_GERAL")
    oView:AddSheet("PASTAS","ABA01","Registro de Produtos")
    oView:AddSheet("PASTAS","ABA02","Categorias")
    oView:AddSheet("PASTAS","ABA03","Rótulos/Embalagens")
    oView:AddSheet("PASTAS","ABA04","Ingredientes")
    oView:AddSheet("PASTAS","ABA05","Arquivos")
    
    //ABA01
    oView:createHorizontalBox("H_CABEC",100, , , "PASTAS", "ABA01")
    oView:createVerticalBox("V_CABEC"  ,100	,"H_CABEC", , "PASTAS", "ABA01")
    //ABA02
    oView:createHorizontalBox("H_DETAIL7",100, , , "PASTAS", "ABA02")
    //ABA03
    oView:createHorizontalBox("H_DETAIL1",030, , , "PASTAS", "ABA03")
    oView:createHorizontalBox("H_DETAIL2",030, , , "PASTAS", "ABA03")
    oView:createHorizontalBox("H_DETAIL3",040, , , "PASTAS", "ABA03")
    //ABA04
    oView:createHorizontalBox("H_DETAIL4",050, , , "PASTAS", "ABA04")
    oView:createHorizontalBox("H_DETAIL5",050, , , "PASTAS", "ABA04")
    //ABA05
    oView:createHorizontalBox("H_DETAIL6",100, , , "PASTAS", "ABA05")
    
    //ABA01
    oView:setOwnerView("V_CABEC_ZE1"   ,"V_CABEC")
    //ABA02
    oView:setOwnerView("V_DETAIL_ZED"  ,"H_DETAIL7")
    //ABA03
    oView:setOwnerView("V_DETAIL_ZE6"  ,"H_DETAIL1")
    oView:setOwnerView("V_DETAIL_ZE5"  ,"H_DETAIL2")
    oView:setOwnerView("V_DETAIL_ZE9"  ,"H_DETAIL3")
    //ABA04
    oView:setOwnerView("V_DETAI_ZE7A"  ,"H_DETAIL4")
    oView:setOwnerView("V_DETAI_ZE7B"  ,"H_DETAIL5")
    //ABA05
    oView:setOwnerView("V_DETAIL_ZE8"  ,"H_DETAIL6")

    oView:EnableTitleView("V_DETAIL_ZE5"   , "Embalagens")
    oView:EnableTitleView("V_DETAIL_ZE6"   , "Rótulos")
    oView:EnableTitleView("V_DETAIL_ZE9"   , "Atributos Específicos")
    oView:EnableTitleView("V_DETAI_ZE7A"   , "Ingredientes")
    oView:EnableTitleView("V_DETAI_ZE7B"   , "Sub-itens Ingredientes")
    oView:EnableTitleView("V_DETAIL_ZE8"   , "Arquivos de Imagens")


    oView:AddIncrementField( 'V_DETAIL_ZE5' , 'ZE5_ITEM')
    oView:AddIncrementField( 'V_DETAIL_ZE6' , 'ZE6_ITEM')
    oView:AddIncrementField( 'V_DETAIL_ZE9' , 'ZE9_ITEM')
    oView:AddIncrementField( 'V_DETAI_ZE7A' , 'ZE7_ITEM')
    oView:AddIncrementField( 'V_DETAI_ZE7B' , 'ZE7_ITEM')
    oView:AddIncrementField( 'V_DETAIL_ZE8' , 'ZE8_ITEM')
    oView:AddIncrementField( 'V_DETAIL_ZED' , 'ZED_CODCAT')

    //:SetViewProperty( 'V_DETAI_ZE7B', "CHANGELINE", {{ |oView, cViewID| fChgLine(oView, cViewID) }} )
    oView:SetViewAction( 'DELETELINE'   , { |oView,cIdView,nNumLine| fDelLine( oView,cIdView,nNumLine, "DELETELINE") } )
    oView:SetViewAction( 'UNDELETELINE' , { |oView,cIdView,nNumLine| fDelLine( oView,cIdView,nNumLine, "UNDELETELINE") } )

    oView:AddUserButton( 'Inclui/Alterar Imagens', 'CLIPS', {|oView| fsetImage(oView, nil)} )
    
    oView:AddUserButton( 'Exportar Imagens', 'CLIPS', {|oView| fgetImage(oView, nil)} )
    
    //oView:SetAfterOkButton({|oView|  fButAftAc(oView)})
    oView:SetViewAction("BUTTONOK"		, {|oView| fVldModel(oView)}) 
Return oView

Static Function fWhenFld(cField)
	Local lRet := .T.
	Local oModel		:= FWModelActive()
	Local oModZE7a		:= oModel:getModel("DETAI_ZE7A")
    //Local oModZE7b		:= oModel:getModel("DETAI_ZE7B")
	//Local aSaveLines 	:= FWSaveRows()
    
   If cField == "ZE7_CODING"	
        If oModZE7a:Length() > 0
            If (oModZE7a:GetValue("ZE7_TIPING")$"U") .OR. Empty(oModZE7a:GetValue("ZE7_TIPING"))
                lRet := .F.
                Help( ,, 'HELP',, 'Não é possível incluir itens filhos em ingredientes do tipo U-Único.', 1, 0)
            endif
        else
            lRet := .F.
            
        endif
   EndIf

return lRet

Static Function fDelLine( oView, cIdView, nNumLine, cAcao)
    Local lRet := .T.
    Local oModel		:= FWModelActive()
	Local oModZE7a		:= oModel:getModel("DETAI_ZE7A")
    Local oModZE7b		:= oModel:getModel("DETAI_ZE7B")
	Local aSaveLines 	:= FWSaveRows()
    Local nLinAtu		:= 1

    if cIdView == "DETAI_ZE7A"
        nLinAtu		:= oModZE7b:nLine

        if msgYesNo("A "+ IIF(cAcao == "DELETELINE","EXCLUSÃO","ESTORNO DA EXCLUSÃO") +" do registro irá "+ IIF(cAcao == "DELETELINE","EXCLUIR","RESTAURAR") +" todos os itens filhos, deseja prosseguir? ")
        //if oModelSit:IsDeleted()
            For nI := 1 To oModZE7b:Length()
                oModZE7b:GoLine( nI )

                If oModZE7b:getValue("ZE7_ITESUP") == oModZE7a:getValue("ZE7_ITEM")
                    IF cAcao == "DELETELINE"
                        oModZE7b:DeleteLine()
                    ELSE
                        oModZE7b:UnDeleteLine()
                    endif
                EndIf
            next nI
        endif

        oModZE7b:goLine(nLinAtu)
        oView:REFRESH("DETAI_ZE7B")
    if cIdView == "DETAI_ZE7B"
        nLinAtu		:= oModZE7b:nLine

        IF cAcao == "DELETELINE"
            For nI := 1 To oModZE7a:Length()
                    oModZE7a:GoLine( nI )

                    If oModZE7b:getValue("ZE7_ITESUP") == oModZE7a:getValue("ZE7_ITEM")
                        if oModelSit:IsDeleted()
                            Help( ,, 'HELP',, 'O ingrediente PAI estão deletado. Por isso, a exclusão não pode ser cancelada.', 1, 0)
                            lRet := .F.
                        endif
                    EndIf
                next nI
            endif

            oModZE7a:goLine(nLinAtu)
        endif
    endif

    
return lRet


Static Function fieldValidPos(oModelSit, cField, xValue, nLine, xCurrentValue)
	Local lRet          := .T.
	Local oModel		:= FWModelActive()
	Local oModZE7a		:= oModel:getModel("DETAI_ZE7A")
    Local oModZE7b		:= oModel:getModel("DETAI_ZE7B")
    Local oModZED		:= oModel:getModel("DETAIL_ZED")
	Local aSaveLines 	:= FWSaveRows()
	Local nLinAtu		:= oModZE7b:nLine
    Local cIteSup       := ""
    Local cQuery        := ""
    Local nPorcTot      := 0

    if oModelSit:cId == "DETAI_ZE7A"
    
        If cField == "ZE7_CODING"    
            
            DbSelectArea("ZEC")
            ZEC->(DbSetOrder(1))
            
            if ZEC->(DbSeek(xFilial("ZEC")+xValue,.F.))
                oModelSit:setValue("ZE7_NOMING",ZEC->ZEC_DESCRI)
                oModelSit:setValue("ZE7_TIPING",ZEC->ZEC_TIPO)
            else
                lRet := .F.
            endif
            
            if !Empty(xCurrentValue)
                nLinAtu		:= oModZE7b:nLine

                For nI := 1 To oModZE7b:Length()
                        oModZE7b:GoLine( nI )

                        IF oModZE7b:getValue("ZE7_ITESUP") == xCurrentValue .AND. !oModZE7b:IsDeleted()
                            lRet := .F.
                        endif
                next nI
                
                oModZE7b:goLine(nLinAtu)

                if !lRet
                    Help( ,, 'HELP',, 'O registro não pode ser alterado, pois existem itens filhos associados ao mesmo.', 1, 0)
                endif
            endif

        ElseIf cField == "ZE7_PORCEN"
            
            nLinAtu		:= oModZE7a:nLine

            For nI := 1 To oModZE7a:Length()
                    oModZE7a:GoLine( nI )

                    IF oModZE7a:nLine != nLinAtu
                        nPorcTot += oModZE7a:getValue("ZE7_PORCEN")
                    else
                        nPorcTot += xValue
                    endif
            next nI
            
            if nPorcTot > 100
                lRet := .F.
                Help( ,, 'HELP',, 'Percentual calculado '+ Transform(nPorcTot,"@E 999.99") +'% ultrpassa o valor máximo de 100%.', 1, 0)
            endif
            
            oModZE7a:goLine(nLinAtu)

        endif

    elseif oModelSit:cId == "DETAI_ZE7B"

        If cField == "ZE7_CODING"
            
            
            
            If oModZE7a:Length() > 0
                If (oModZE7a:GetValue("ZE7_TIPING") != "M") .OR. Empty(oModZE7a:GetValue("ZE7_TIPING"))
                    lRet := .F.
                    Help( ,, 'HELP',, 'Somente produtos do tipo M-Mix podem ter ingredientes filhos.', 1, 0)
                Elseif Empty(oModZE7b:getValue("ZE7_ITESUP"))
                    oModZE7b:setValue("ZE7_ITESUP",oModZE7a:GetValue("ZE7_ITEM"))

                    DbSelectArea("ZEC")
                    ZEC->(DbSetOrder(1))
                    
                    if ZEC->(DbSeek(xFilial("ZEC")+xValue,.F.))
                        oModelSit:setValue("ZE7_NOMING",ZEC->ZEC_DESCRI)
                        oModelSit:setValue("ZE7_TIPING",ZEC->ZEC_TIPO)
                    else
                        lRet := .F.
                    endif

                endif
            else
                lRet := .F.
                Help( ,, 'HELP',, 'Somente produtos do tipo M-Mix podem ter ingredientes filhos.', 1, 0)
            endif
        
        ElseIf cField == "ZE7_PORCEN"
            
            nLinAtu		:= oModZE7b:nLine
            cIteSup     := oModZE7b:getValue("ZE7_ITESUP")

            For nI := 1 To oModZE7b:Length()
                    oModZE7b:GoLine( nI )
                    
                    if oModZE7b:getValue("ZE7_ITESUP") == cIteSup
                        IF oModZE7b:nLine != nLinAtu
                            nPorcTot += oModZE7b:getValue("ZE7_PORCEN")
                        else
                            nPorcTot += xValue
                        endif
                    endif
            next nI
            
            if nPorcTot > 100
                lRet := .F.
                Help( ,, 'HELP',, 'Percentual calculado '+ Transform(nPorcTot,"@E 999.99") +'% ultrpassa o valor máximo de 100%.', 1, 0)
            endif
            
            oModZE7b:goLine(nLinAtu)
        
        EndIf
    
    elseif oModelSit:cId == "DETAIL_ZED"
        /*
        If cField == "ZED_CODCAT"

            cQuery := " SELECT X5_CHAVE, X5_DESCRI "
            cQuery += " FROM "+ RetSqlName("SX5") +" "
            cQuery += " WHERE D_E_L_E_T_='' AND X5_FILIAL='02' AND X5_TABELA='_H' AND LTRIM(RTRIM(X5_CHAVE))='"+ oModZED:GetValue("ZED_CODCAT") +"'; "

            TcQuery cQuery ALIAS "QX5H" New

            if QX5H->(!eof())
                oModZED:setValue("ZED_DESCAT",Alltrim(QX5H->X5_DESCRI))
            else
                Help( ,, 'HELP',, 'Código de categoria inválido!.', 1, 0)
            endif

            QX5H->(DbCloseArea())

        endif
        */
    Endif

   FWRestRows( aSaveLines )
Return lRet 

Static Function fSetImage(oView)
    Local oEST57P   := ADEST057P():new()
    Local nOper     := oView:getOperation()

    if nOper == 3 .or. nOper == 4
        oEST57P:setImage(oView, nil)
    else
        Msginfo("Operação permitida somente na inclusão ou alteração do registro!")
    endif
    FreeObj(oEST57P)
return

Static Function fGetImage(oView)
    Local oEST57P    := ADEST057P():new()

    oEST57P:getImage(oView, nil)

    FreeObj(oEST57P)
return

Static Function fVldModel(oView)

	Local lRet			:= .T.
	Local oModel		:= FWModelActive()
	Local oModCAB		:= oModel:getModel("CABEC_ZE1")
    Local nOperation	:= oModel:GetOperation()
	//Local cReqMerc		:= oModCAB:getValue("ZE1_REGIST")
    Local nOper         := oView:getOperation()
    Local cStatus       := ""
    
    // Operação de exclusão.
    //Chamado T.I. - Leonardo P. Monteiro - 19/04/2021 - Pequena validação na quantidade de dígito no campo ZE1_REGIST (Núm Registro).
    if nOper == 3    
        if Len(Alltrim(oModCAB:getValue("ZE1_REGIST"))) < 6
			MsgAlert("O campo 'Núm Registro' deve conter 6 caracteres numéricos.")
			lRet := .F.
		endif
    Elseif nOper == 5

        If MsgYesNo("A exclusão desse requisito de mercado irá excluir todos os relacionamentos de Mercados, Países e produtos."+chr(13)+chr(10)+;
        " Deseja confirmar essa ação?","Confirmação de Exclusão")
            lRet := .T.
            
            cStatus := oModCAB:getValue("ZE1_STATUS")
            
            if cStatus != "I"
                if nOperation == 3
                    cStatus := "I"
                elseif nOperation == 4
                    cStatus := "A"
                endif

                oModCAB:setValue("ZE1_STATUS",cStatus)
            endif
        else
            lRet := .F.
        EndIF

    endif

Return lRet


Class ADEST057P

    Data cEOL  			AS String            && character of line end
    //Data cPath

    Method New() Constructor
    Method setImage()
    Method getImage()

    Method Destroy()  && Inline Super:Destroy()

EndClass

&& Metodo construtor
Method New() Class ADEST057P
	//::cPath   := SUPERGETMV("MV_XPGAPCR",,"\SYSTEM\AD_ESPEC_TECNICA\")
	::cEOL   	:= CHR(13)+CHR(10)

Return

METHOD getImage(oView, nReqPrd) CLASS ADEST057P
    Local cPath     := ""
    Local cArq      := ""
    Local cEncode64 := ""
    Local nE        := 0
    Default oView   := ""
    
    cPath  := cGetFile('Arquivo|*.*|Arquivo *|*.*','Selecione o arquivo',0,'C:\temp\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

    if lIsDir(cPath)
    
        if Valtype(oView) == "O"
            oModel		:= FWModelActive()
            oModArq		:= oModel:getModel("DETAIL_ZE8")

            for nE := 1 to oModArq:Length()
                oModArq:Goline(nE)
                cArq        := Alltrim(oModArq:getValue("ZE8_ARQUIV"))
                cEncode64   := Alltrim(oModArq:getValue("ZE8_ARQB64"))

                Decode64(cEncode64,cPath+cArq,.T.)
            next nE

        else

        endif
        oModArq:Goline(1)
        ShellExecute("open",cPath,"","",1) 
    else
        Msginfo("Operção cancelada pelo usuário ou arquivo inválido!")
    endif

Return

METHOD setImage(oView, cReqPrd) CLASS ADEST057P
    Local aOk       := {}
    Local aNo       := {}
    Local cPath     := ""
    Local cArq      := ""
    Local cDiret    := ""
    Local lValid    := .T.
    Local cEncode64 := ""
    Local nLimite   := 1048576
    Local cMens     := ""
    Default oView   := ""
    
    if Valtype(oView) == "O"
        oModel		:= FWModelActive()
	    oModArq		:= oModel:getModel("DETAIL_ZE8")
        
    endif

    if msgYesNo("Deseja confirmar as importações dos arquivos?")
        cDiret  := Alltrim(cGetFile('Arquivo|*.*|Arquivo *|*.*','Selecione o arquivo',0,'C:\temp\',.T.,GETF_RETDIRECTORY+GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.))
        aArq    := Directory(cDiret+"*.jpg")
        nArq    := Len(aArq)

        for nA := 1 To nArq
            cArq    := Alltrim(aArq[nA][01])
            cPath   := cDiret + cArq
            
            if file(cPath) .AND. aArq[nA][05] == "A"
                
                if fGetLin(oModArq, aArq[nA], nLimite, aOk, aNo)

                    oModArq:setValue("ZE8_ARQUIV",aArq[na][01])
                    oModArq:setValue("ZE8_TAMANH",aArq[na][02])
                    oModArq:setValue("ZE8_DATA",aArq[na][03])
                    oModArq:setValue("ZE8_HORA",aArq[na][04])

                    cEncode64 := Encode64(,cPath,.T.,.T.)
                    oModArq:setValue("ZE8_ARQB64",cEncode64)
                ENDIF
            else
                AADD(nNo,{"Arquivo "+aArq[na][01]+" não encontrado no diretório."})
            endif
        next nA
        cMens := "Arquivos importados: "+chr(13)+chr(10)
        
        for nE := 1 to Len(aOk)
            cMens += Alltrim(aOk[nE][01])+chr(13)+chr(10)
        next nE

        cMens := "Arquivos não importados: "+chr(13)+chr(10)
        
        for nE := 1 to Len(aNo)
            cMens += Alltrim(aNo[nE][01])+chr(13)+chr(10)
        next nE

        MsgInfo(cMens)

    else
        Msginfo("Operção cancelada pelo usuário ou arquivo inválido!")
    endif

return lValid

Static Function fGetLin(oModArq, aArquivo, nLimite, aOk, aNo)
    Local lRet      := .T.
    Local nPos      := 0
    
    IF nLimite > aArquivo[2]
        for nE := 1 to oModArq:Length()
            oModArq:Goline(nE)
            cArqTmp := Alltrim(oModArq:getValue("ZE8_ARQUIV"))

            if cArqTmp == aArquivo[01]
                if DTOS(oModArq:getValue("ZE8_DATA"))+oModArq:getValue("ZE8_HORA") <= Dtos(aArquivo[03])+aArquivo[04]
                    nPos        := nE
                    lRet        := .T.

                    AADD(aOk,{"Arquivo "+ cArqTmp +" atualizado."})
                else
                    nPos    := 0
                    lRet    := .F.
                    AADD(aNo,{"Arquivo "+ cArqTmp +" com data anterior ao atual."})
                ENDIF
            endif
        next nE

        if lRet
            if nPos == 0
                IF oModArq:Length() == 1 .and. eMPTY(cArqTmp)
                    nPos := 1
                else
                    oModArq:AddLine()
                    nPos := oModArq:Length()
                endif   
            Endif    

            oModArq:Goline(nPos)
        endif
    else
        lRet := .F.
        AADD(aNo,{"Arquivo "+ Alltrim(aArquivo[01])+"-Tamanho não permitido."})
    endif
return lRet
