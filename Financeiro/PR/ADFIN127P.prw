#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWCOMMAND.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'RPTDEF.CH'

/*/{Protheus.doc} u_ADFIN127P
    ADFIN127P
    Funcao de processamento via schedule para verificacao dos pagamentos recebidos via Super Link Cielo.
    @type function
    @version  
    @author Rodrigo Mello - Flek Solutions
    @since 11/01/2022
/*/

function u_ADFIN127P( aParms, nE1Id )

    local cEmp := ""
    local cFil := ""
    private nIdE1 := 0

    default aParms := {"","","01","02","",""}
    default nE1Id  := 0

    nIdE1 := nE1Id
    
    cEmp := aParms[len(aParms)-3]
    cFil := aParms[len(aParms)-2]
    
    PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO 'FAT'
        Execute()
    RESET ENVIRONMENT

    aParms := Nil
    cEmp := Nil
    cFil := Nil

return

return

static function Execute()
    local cAlias    := GetNextAlias()
    private oReq    := JsonObject():new()
    private oRes
    private oLnk    := ADFIN124P():New()

    dbSelectArea("SE1")
    dbSelectArea("SC5")
    dbSelectArea("SC9")

    beginSQL Alias cAlias
        select
            E1.R_E_C_N_O_ AS [E1_RECNO],
            C5.R_E_C_N_O_ AS [C5_RECNO]
        from %table:SE1% E1
        inner join %table:SC5% C5
        on C5.%notdel%
            and C5_FILIAL   = %xFilial:SC5%
            and C5_NUM      = E1_NUM
            AND C5_CLIENTE  = E1_CLIENTE
            AND C5_LOJACLI  = E1_LOJA
        where E1.%notdel%
            and E1_FILIAL   = %xFilial:SE1%
            and E1_XLOGLNK  IN ( 'GER', 'EML' )
            and E1_SALDO    > 0
        order by E1.R_E_C_N_O_
    endSQL

    while (cAlias)->(!eof())
        SE1->(dbGoTo( (cAlias)->E1_RECNO ))
        SC5->(dbGoTo( (cAlias)->C5_RECNO ))
        if oReq:fromJson( SE1->E1_XMEMLNK ) == Nil .and. ;
            oLnk:getLink( oReq['id'], .T., @oRes ) .and. ;
            len( oRes['orders'] ) > 0
            fProcessa(oRes)
        endif
        (cAlias)->(dbSkip())
    enddo

    (cAlias)->(dbCloseArea())

    FreeObj(oReq)
    FreeObj(oRes)
    FreeObj(oLnk)

return

//----------------------------------------------------------
Static Function fProcessa(oRes)
//----------------------------------------------------------
    local lBxPROk 
    private dDataCred := dDataBase // TODO verificar data de credito para o link de pagamento

    lBxPROk := u_BxWSPR(.F., SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)

    If lBxPROk

        recLock("SC5", .f.)
            SC5->C5_XWSPAGO := "S"
            SC5->C5_XPREAPR := "L"
        SC5->( msUnLock() )

        SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
        If SC9->( dbSeek(SC5->(C5_FILIAL+C5_NUM)) )
            Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM 
                a450Grava(1,.T.,.T.)
                SC9->( dbSkip() )
            EndDo
        EndIf

    Else
        
        //logZBE( SC5->C5_NUM + " NAO GEROU RA! FATURAMENTO NAO LIBERADO PELO RETORNO API LINK CIELO" )
    
    EndIf

return
