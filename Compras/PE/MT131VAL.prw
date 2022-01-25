#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MT131VAL
    Verificar se a cotação pode ser gerada
    @type  Function
    @author FWNM
    @since 20/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 056479 - FWNM                    - 20/03/2020 - || OS 057949 || CONTROLADORIA || DAIANE || 3549 || PEDIDO COMPRA
    @chamado T.I. - Leonardo P. Monteiro      - 01/09/2021 - Inclusão do comando RestArea.
    @history ticket 65456 - Fernando Macieira - 29/12/2021 - Cotação diferentes com a mesma SC gerando compras indevidas
    @history ticket 66599 - Fernando Macieira - 24/01/2022 - Evolução ticket 65456
/*/
User Function MT131VAL()

    Local aArea     := GetArea()
	Local aAreaSC1  := SC1->( GetArea() )
	Local aAreaSC8  := SC8->( GetArea() )
    Local cMarca    := PARAMIXB[1]
    Local cQuerySC1 := PARAMIXB[2]
    Local cQuery    := ''
    Local cMy1Alias := GetNextAlias()
    Local cMy2Alias := GetNextAlias()
    Local lRet      := .t.
    Local nTotal    := 0
    Local cCusto    := ""
    Local cItemCta  := ""
    Local cProduto  := ""
    Local aAprov    := {}
    Local lExistSC8 := .f.
    Local lItemSC   := .f.
    Local cNumC8    := ""

    dbSelectArea("SC1")
    dbSetOrder(1)
   
    // Restringe o uso do produto 1163101
    cQuery := " SELECT DISTINCT C1_FILIAL, C1_CC, C1_ITEMCTA, C1_OK
    cQuery += " FROM " + RetSqlName("SC1") + " SC1 (NOLOCK)
    cQuery += " WHERE SC1.D_E_L_E_T_=''
    cQuery += " AND C1_OK<>''
    cQuery += " AND " + cQuerySC1

    //cQuery := ChangeQuery(cQuery)
    Iif( Select(cMy1Alias) > 0,(cMy1Alias)->(dbCloseArea()),Nil )
    dbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cMy1Alias, .F., .T. )

    Do While (cMy1Alias)->(!Eof())

        If IsMark("C1_OK",cMarca)

            //Verifica se todos os itens tem o mesmo grupo de aprovação em função do centro de custo e item contábil
            cCusto   := (cMy1Alias)->C1_CC
            cItemCta := (cMy1Alias)->C1_ITEMCTA
            aAprov := U_GetAprov( cCusto, cItemCta, nTotal, cProduto )
			
			//³ Se não encontrar aprovador, não deixa colocar o pedido                          ³
			If Len( aAprov ) == 0

				lRet	:= .F.
				Aviso(	"MT131VAL-01",;
				"Não foi localizado controle de alçada para o centro de custo/Item Contábil.",;
				{ "&Retorna" },,;
				"C.Custo/Item: " + cCusto + "/" + cItemCta )

			Else

                cQuery := " SELECT DISTINCT C1_FILIAL, C1_CC, C1_ITEMCTA, C1_OK
                cQuery += " FROM " + RetSqlName("SC1") + " SC1 (NOLOCK)
                cQuery += " WHERE SC1.D_E_L_E_T_=''
                cQuery += " AND C1_OK<>''
                cQuery += " AND C1_CC<>'"+cCusto+"' 
                cQuery += " AND " + cQuerySC1

                //cQuery := ChangeQuery(cQuery)
                Iif( Select(cMy2Alias) > 0,(cMy2Alias)->(dbCloseArea()),Nil )
                dbUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cMy2Alias, .F., .T. )

				Do While (cMy2Alias)->(!Eof())
					
					If IsMark("C1_OK",cMarca)
                        If cCusto+cItemCta <> (cMy2Alias)->C1_CC+C1_ITEMCTA
                            lRet := StaticCall(MT120LOK, VldCCusto, (cMy2Alias)->C1_CC, cCusto, (cMy2Alias)->C1_ITEMCTA, cItemCta, aAprov, nTotal)
                        EndIf
                    EndIf
					
					If !lRet
						Exit
					EndIf

                    (cMy2Alias)->( dbSkip() )
					
				EndDo 
				
			EndIf
			
		EndIf
		
        (cMy1Alias)->(DbSkip())

    EndDo    

    // @history ticket 65456 - Fernando Macieira - 29/12/2021 - Cotação diferentes com a mesma SC gerando compras indevidas
    If lRet
        
        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT C1_FILIAL, C1_NUM, C1_PRODUTO, C1_ITEM
        cQuery += " FROM " + RetSqlName("SC1") + " SC1 (NOLOCK)
        cQuery += " WHERE " + cQuerySC1
        cQuery += " AND C1_OK<>''
        cQuery += " AND SC1.D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        Work->( dbGoTop() )
        Do While Work->( !EOF() )

            lExistSC8 := GetSC8(Work->C1_FILIAL, Work->C1_NUM, Work->C1_PRODUTO, @cNumC8)
            If lExistSC8
                
                // @history ticket 66599 - Fernando Macieira - 24/01/2022 - Evolução ticket 65456
                lItemSC := ChkItemSC(Work->C1_FILIAL, Work->C1_NUM, Work->C1_ITEM, Work->C1_PRODUTO)

                If lItemSC
                    lRet := .f.
                    msgAlert("Já existe uma cotação n. " + cNumC8 + " para a SC n. " + Work->C1_NUM + " para este produto " + AllTrim(Work->C1_PRODUTO) + " nesta filial! Verifique...")
                    Exit
                Else
                    // @history ticket 66599 - Fernando Macieira - 24/01/2022 - Evolução ticket 65456
                    If msgYesNo("Já existe uma cotação n. " + cNumC8 + " para a SC n. " + Work->C1_NUM + " para este produto " + AllTrim(Work->C1_PRODUTO) + " nesta filial! Deseja realmente continuar?")
                        //gera log
                        u_GrLogZBE( msDate(), TIME(), cUserName, "AUTORIZOU NOVA GERACAO COTACAO PARA O MESMO PRODUTO  " + AllTrim(Work->C1_PRODUTO),"COTACAO","MT131VAL",;
                        "COTACAO/SC " + cNumC8 + " / " + Work->C1_NUM, ComputerName(), LogUserName() )
                    Else
                        lRet := .f.
                        Exit
                    EndIf
                EndIf
            
            EndIf

            Work->( dbSkip() )

        EndDo

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

    EndIf

    RestArea( aArea )
    RestArea( aAreaSC1 )
	RestArea( aAreaSC8 ) 

Return lRet

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 29/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetSC8(cC1_FILIAL, cC1_NUM, cC1_PRODUTO, cNumC8)

    Local lTemC8 := .F.
    Local cQuery := ""

    If Select("WorkC8") > 0
        WorkC8->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DISTINCT C8_FILIAL, C8_NUM, C8_PRODUTO
    cQuery += " FROM " + RetSqlName("SC8") + " SC8 (NOLOCK)
    cQuery += " WHERE C8_FILIAL='"+FWxFilial("SC8")+"' 
    cQuery += " AND C8_NUMSC='"+cC1_NUM+"' 
    cQuery += " AND C8_PRODUTO='"+cC1_PRODUTO+"' 
    cQuery += " AND SC8.D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkC8"

    WorkC8->( dbGoTop() )
    If WorkC8->( !EOF() )
        cNumC8 := WorkC8->C8_NUM
        lTemC8 := .T.
    EndIf

    If Select("WorkC8") > 0
        WorkC8->( dbCloseArea() )
    EndIf

Return lTemC8

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author FWNM
    @since 24/01/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 66599 - Fernando Macieira - 24/01/2022 - Evolução ticket 65456
/*/
Static Function ChkItemSC(cC1_FILIAL, cC1_NUM, cC1_ITEM, cC1_PRODUTO)

    Local lTemC8 := .F.
    Local cQuery := ""

    If Select("WorkC8") > 0
        WorkC8->( dbCloseArea() )
    EndIf

    cQuery := " SELECT DISTINCT C8_FILIAL, C8_NUM, C8_PRODUTO
    cQuery += " FROM " + RetSqlName("SC8") + " SC8 (NOLOCK)
    cQuery += " WHERE C8_FILIAL='"+FWxFilial("SC8")+"' 
    cQuery += " AND C8_NUMSC='"+cC1_NUM+"' 
    cQuery += " AND C8_ITEMSC='"+cC1_ITEM+"' 
    cQuery += " AND C8_PRODUTO='"+cC1_PRODUTO+"' 
    cQuery += " AND SC8.D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkC8"

    WorkC8->( dbGoTop() )
    If WorkC8->( !EOF() )
        lTemC8 := .T.
    EndIf

    If Select("WorkC8") > 0
        WorkC8->( dbCloseArea() )
    EndIf

Return lTemC8
