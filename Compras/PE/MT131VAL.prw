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
    @chamado 056479 - FWNM              - 20/03/2020 - || OS 057949 || CONTROLADORIA || DAIANE || 3549 || PEDIDO COMPRA
/*/
User Function MT131VAL()

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

    dbSelectArea("SC1")
    dbSetOrder(1)
   
    // Restringe o uso do produto 1163101
    cQuery := " SELECT DISTINCT C1_FILIAL, C1_CC, C1_ITEMCTA, C1_OK
    cQuery += " FROM " + RetSqlName("SC1") + " SC1 (NOLOCK)
    cQuery += " WHERE SC1.D_E_L_E_T_=''
    cQuery += " AND C1_OK<>''
    cQuery += " AND " + cQuerySC1

    cQuery := ChangeQuery(cQuery)
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

                cQuery := ChangeQuery(cQuery)
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
    
Return lRet