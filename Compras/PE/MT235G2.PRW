#Include 'Protheus.ch'
#Include 'FwMvcDef.ch'
#Include 'Parmtype.ch'
#Include "Topconn.ch"
#INCLUDE 'FILEIO.CH'
#INCLUDE "rwmake.ch"
#Include "MSMGADD.CH" 

/*{Protheus.doc} User Function MT235G2
	Antes de processar a eliminação de cada Pedido de Compra, por residuo. Trava para não deixar excluir pedido de venda que tenha uma P.A com saldo no finaceiro
	@type  Function
	@author WILLIAM COSTA
	@since 11/03/2020
	@version 01
	
*/    

USER FUNCTION MT235G2()

    Local lRet := .T.

    SqlBuscaPA(SC7->C7_FILIAL,SC7->C7_NUM)
    While TRB->(!EOF())       

        IF TRB->E2_SALDO > 0

            MsgAlert("OLÁ " + ALLTRIM(cUserName) + ", Pedido não pode ser eliminado resíduo, existe títulos em aberto no financeiro, favor verificar com o financeiro para baixar ou excluir o titulo de P.A"  + CHR(13) + CHR(10) + ;
            "Filial: "     + TRB->E2_FILIAL            + CHR(13) + CHR(10) + ;
            "Prefixo: "    + TRB->E2_PREFIXO           + CHR(13) + CHR(10) + ;
            "Numero: "     + TRB->E2_NUM               + CHR(13) + CHR(10) + ;
            "Parcela: "    + TRB->E2_PARCELA           + CHR(13) + CHR(10) + ;
            "Tipo: "       + TRB->E2_TIPO              + CHR(13) + CHR(10) + ;
            "Natureza: "   + TRB->E2_NATUREZ           + CHR(13) + CHR(10) + ;
            "Fornecedor: " + TRB->E2_FORNECE           + CHR(13) + CHR(10) + ;
            "Loja: "       + TRB->E2_LOJA              + CHR(13) + CHR(10) + ;
            "Valor: "      + CVALTOCHAR(TRB->E2_VALOR) + CHR(13) + CHR(10) + ;
            "Saldo: "      + CVALTOCHAR(TRB->E2_SALDO) + CHR(13) + CHR(10) + ;
            "Num Pedido: " + TRB->ZFQ_NUM              + CHR(13) + CHR(10), "MT235G2 - Ponto de Entrada Eliminação de Residuo")

            lRet := .F.

        ENDIF
        
        TRB->(dbSkip())
                
    ENDDO
    TRB->(dbCloseArea())

RETURN(lRet)

Static Function SqlBuscaPA(cFilAtu,cNum)    

    Local cTeste := ''

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT E2_FILIAL,
                   E2_PREFIXO,
                   E2_NUM,
                   E2_PARCELA,
                   E2_TIPO,
                   E2_NATUREZ,
                   E2_TIPO,
                   E2_VALOR,
                   E2_NATUREZ,
                   E2_FORNECE,
                   E2_SALDO,
                   E2_LOJA,
                   ZFQ_NUM
              FROM %TABLE:ZFQ%
        INNER JOIN %TABLE:SE2%
                ON E2_FILIAL               = ZFQ_FILIAL
               AND E2_PREFIXO              = ZFQ_PREFIX
               AND E2_NUM                  = ZFQ_NUM
               AND E2_PARCELA              = ZFQ_PARCEL
               AND E2_TIPO                 = ZFQ_TIPO
               AND E2_NATUREZ              = ZFQ_NATURE
               AND E2_FORNECE              = ZFQ_FORNEC
               AND E2_LOJA                 = ZFQ_LOJA
               AND E2_SALDO                > 0
               AND %TABLE:SE2%.D_E_L_E_T_ <> '*'
             WHERE ZFQ_FILIAL              = %EXP:cFilAtu%
               AND ZFQ_NUM                 = %EXP:cNum%
               AND %TABLE:ZFQ%.D_E_L_E_T_ <> '*'

 	EndSQl      

RETURN(NIL) 