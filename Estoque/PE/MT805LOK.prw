#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH" 
#INCLUDE "AP5MAIL.CH" 
#INCLUDE "FWBROWSE.CH"   
#Include "TCBrowse.ch"

/*/{Protheus.doc} User Function MT805LOK
    Este ponto de entrada tem o objetivo personalizar a validação no momento em que se cria um endereço para o produto. LOCALIZAÇÃO: Function A805LinOk - Função de validação no momento da criação de endereços, no final da Função, após ter executado todos os processos de validação do sistema e antes do retorno lógico.
    @author William Costa
    @since 20/01/2020
    @version 01
    @history Chamado T.I    - WILLIAM COSTA - 08/06/2020     - Quando precisa adicionar saldo no endereço a menor do que precisa o ponto de entrada não deixa, então coloquei esse parametro para permitir.
    @history Chamado 059319 - 01/07/2020 - ADRIANO SAVOINE   - Ajuste no IF para verificar o parametro.
    @history ticket  6752   - Fernando Macieira - 16/12/2020 - Equalizar SB2 vs SBF
    @history ticket 75276   - Antonio Domingos - 30/06/2022 - Transferencia - Desvincular produto do endereço
/*/
User Function MT805LOK()

    Local lRet        := .T.    
    Local nPosProduto := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "DA_PRODUTO"})
    Local nPosLocal   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "DA_LOCAL"})
    Local nPosLocaliz := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "DB_LOCALIZ"})
    Local nPosQuant   := aScan( aHeader, {|x| UPPER(AllTrim(x[2])) == "DB_QUANT"})
    Local nBF_QUANT   := 0

    IF __cUserid $ GETMV("MV_#ESTPUL", .F.,"001439") // Chamado 059319 - 01/07/2020 - ADRIANO SAVOINE - Ajuste no IF para verificar o parametro.

        RETURN(lRet)

    ENDIF

    IF aCols[n] [LEN(aHeader) + 1] == .F.
       
        SqlProduto(aCols[n][nPosProduto],aCols[n][nPosLocal])
        WHILE TRB->(!EOF())
            
             IF ALLTRIM(aCols[n][nPosProduto]) == ALLTRIM(TRB->B1_COD)

                IF ALLTRIM(TRB->B1_LOCALIZ) == 'N' .OR. ALLTRIM(TRB->B1_LOCALIZ) == ''

                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", o Campo B1_LOCALIZ está como Não, não é permitido favor corrigir para Sim, para continuar com o endereçamento. " , "MT805LOK-01")
                    lRet := .F.

                ENDIF

                IF ALLTRIM(TRB->BZ_LOCALIZ) == 'N' .OR. ALLTRIM(TRB->BZ_LOCALIZ) == ''
                
                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", o Campo BZ_LOCALIZ está como Não, não é permitido favor corrigir Sim, para continuar com o endereçamento. " , "MT805LOK-02")
                    lRet := .F.

                ENDIF

                IF TRB->B2_QACLASS > 0
                
                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", o Campo B2_QACLASS está maior que zero, não é permitido favor entrar em contato com a T.I para correção. " , "MT805LOK-03")
                    lRet := .F.

                ENDIF

                IF TRB->B2_QEMPSA > 0
                
                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", o Campo B2_QEMPSA está maior que zero, não é permitido favor entrar em contato com a T.I para correção. " , "MT805LOK-04")
                    lRet := .F.

                ENDIF

                IF TRB->B2_RESERVA > 0
                
                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", o Campo B2_RESERVA está maior que zero, não é permitido favor entrar em contato com a T.I para correção. " , "MT805LOK-05")
                    lRet := .F.

                ENDIF

                IF TRB->B2_QEMP > 0
                
                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", o Campo B2_QEMP está maior que zero, não é permitido favor entrar em contato com a T.I para correção. " , "MT805LOK-06")
                    lRet := .F.

                ENDIF

                IF TRB->B2_QATU <> aCols[n][nPosQuant]
                
                    nBF_QUANT := GetBFQUANT() // @history ticket  6752   - Fernando Macieira - 16/12/2020 - Equalizar SB2 vs SBF

                    If ( Abs(TRB->B2_QATU) - Abs(nBF_QUANT) ) <> aCols[n][nPosQuant]
                    
                        MsgAlert("OLÁ " + Alltrim(cUserName) + ", a quantidade que você está tentando enviar para o Endereço está diferente do que tem a Quantidade Atual, Verifique " , "MT805LOK-07")
                        lRet := .F.
                    
                    EndIf

                ENDIF

                IF ALLTRIM(aCols[n][nPosLocaliz]) <> '' .AND. UPPER(ALLTRIM(aCols[n][nPosLocaliz])) <> 'PROD'

                    IF TRB->BF_LOCALIZ <> aCols[n][nPosLocaliz]
                
                        MsgAlert("OLÁ " + Alltrim(cUserName) + ", Verifique o Cadastro de Endereços, produto não foi encontrado no Endereço correto BE_PRODUTO " , "MT805LOK-08")
                        lRet := .F.

                    ENDIF
                    /*
                    IF TRB->BF_QUANT > 0
                
                        MsgAlert("OLÁ " + Alltrim(cUserName) + ", Já existe Saldo de Endereço para esse produto não é permitido. " , "MT805LOK-09")
                        lRet := .F.

                    ENDIF
                    */
                ENDIF
            ENDIF
            TRB->(dbSkip())
            
        ENDDO
        TRB->(dbCloseArea())
    ENDIF
    
RETURN(lRet)

STATIC FUNCTION SqlProduto(cProduto,cLocal)

    Local cFilAtu := FWXFILIAL("SDA")

    BeginSQL Alias "TRB"
		%NoPARSER%
		  SELECT B1_COD,
                 B1_DESC,
                 B1_LOCALIZ,
                 BZ_LOCALIZ,
                 BZ_COD,
                 B1_CODBAR,
                 B2_QATU,
                 B2_QACLASS,
                 B2_QEMPSA,
                 B2_RESERVA,
                 B2_QEMP,
                 B2_DINVENT,
                 BE_LOCALIZ,
                 BE_DTINV, 
                 BF_LOCALIZ,
                 BF_QUANT,
                 BF_EMPENHO
            FROM %Table:SB2% WITH(NOLOCK),%Table:SB1% WITH(NOLOCK)
            LEFT JOIN %Table:SBE% WITH(NOLOCK)
                   ON BE_FILIAL               = %EXP:cFilAtu%
                  AND BE_CODPRO               = B1_COD
                  AND BE_LOCAL                = %EXP:cLocal%
                  AND %Table:SBE%.D_E_L_E_T_ <> '*' 
            LEFT JOIN %Table:SBF% WITH(NOLOCK)
                   ON BF_FILIAL               = %EXP:cFilAtu%
                  AND BF_LOCALIZ              = BE_LOCALIZ 
                  AND %Table:SBF%.D_E_L_E_T_ <> '*' 
            LEFT JOIN %Table:SBZ% WITH(NOLOCK)
                   ON BZ_FILIAL               = %EXP:cFilAtu%
                  AND BZ_COD                  = B1_COD
                  AND %Table:SBZ%.D_E_L_E_T_ <> '*' 
                WHERE B2_COD                  = %EXP:cProduto%
                  AND B2_FILIAL               = %EXP:cFilAtu%
                  AND B2_LOCAL                = %EXP:cLocal%
                  AND %Table:SB2%.D_E_L_E_T_ <> '*'
                  AND B1_COD                  = B2_COD
                  AND B1_MSBLQL               = '2'
                  AND %Table:SB1%.D_E_L_E_T_ <> '*'

            ORDER BY %Table:SB1%.B1_COD
		
	EndSQl
    If !TRB->(Eof()) .AND. !Empty(TRB->BE_CODPRO)
        BeginSQL Alias "TRB"
            %NoPARSER%
            SELECT B1_COD,
                    B1_DESC,
                    B1_LOCALIZ,
                    BZ_LOCALIZ,
                    BZ_COD,
                    B1_CODBAR,
                    B2_QATU,
                    B2_QACLASS,
                    B2_QEMPSA,
                    B2_RESERVA,
                    B2_QEMP,
                    B2_DINVENT,
                    BE_LOCALIZ,
                    BE_DTINV, 
                    BF_LOCALIZ,
                    BF_QUANT,
                    BF_EMPENHO
                FROM %Table:SB2% WITH(NOLOCK),%Table:SB1% WITH(NOLOCK)
                LEFT JOIN %Table:SBF% WITH(NOLOCK)
                    ON BF_FILIAL               = %EXP:cFilAtu%
                    AND BF_PRODUTO             = B1_COD 
                    AND %Table:SBF%.D_E_L_E_T_ <> '*' 
                LEFT JOIN %Table:SBZ% WITH(NOLOCK)
                    ON BZ_FILIAL               = %EXP:cFilAtu%
                    AND BZ_COD                  = B1_COD
                    AND %Table:SBZ%.D_E_L_E_T_ <> '*' 
                    WHERE B2_COD                  = %EXP:cProduto%
                    AND B2_FILIAL               = %EXP:cFilAtu%
                    AND B2_LOCAL                = %EXP:cLocal%
                    AND %Table:SB2%.D_E_L_E_T_ <> '*'
                    AND B1_COD                  = B2_COD
                    AND B1_MSBLQL               = '2'
                    AND %Table:SB1%.D_E_L_E_T_ <> '*'

                ORDER BY %Table:SB1%.B1_COD
            
        EndSQl
    EndIf
RETURN(NIL)

/*/{Protheus.doc} Static Function GetBFQUANT()
    Busca quantidade da tabela SBF = Saldos por endereço
    @type  Static Function
    @author Fernando Macieira
    @since 16/12/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetBFQUANT()

    Local nBF_QUANT := 0
    Local cQuery    := ""
    Local cCodProd  := gdFieldGet("DA_PRODUTO", n)
    Local cArmazem  := gdFieldGet("DA_LOCAL", n)
    Local cLocaliz  := gdFieldGet("DB_LOCALIZ", n)

    If Select ("WorkBF") > 0
        WorkBF->( dbCloseArea() )
    EndIf

    cQuery := " SELECT BF_QUANT
    cQuery += " FROM " + RetSqlName("SBF") + " (NOLOCK)
    cQuery += " WHERE BF_FILIAL='"+FWxFilial("SBF")+"' 
    cQuery += " AND BF_PRODUTO='"+cCodProd+"' 
    cQuery += " AND BF_LOCAL='"+cArmazem+"' 
    cQuery += " AND BF_LOCALIZ='"+cLocaliz+"' 
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkBF"

    aTamSX3	:= TamSX3("BF_QUANT")
    tcSetField("WorkBF", "BF_QUANT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    WorkBF->( dbGoTop() )
    If WorkBF->( !EOF() )
       nBF_QUANT := WorkBF->BF_QUANT 
    EndIf

    If Select ("WorkBF") > 0
        WorkBF->( dbCloseArea() )
    EndIf
    
Return nBF_QUANT
