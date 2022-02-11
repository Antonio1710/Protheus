#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWCOMMAND.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'RPTDEF.CH'

/*/{Protheus.doc} u_ADFIN130P
	ADFIN130P
	Funcao de processamento via schedule para registro de cobranca via PIX Banco Bradesco
	@type function
	@version 12.1.25
	@author Rodrigo Mello - Flek Solutions
	@since 11/01/2022
/*/

function u_ADFIN130P( aParms, nE1Id, lRpc )

    local cEmp := ""
    local cFil := ""
    private nIdE1 := 0

    default aParms := {"","","01","02","",""}
    default nE1Id  := 0
    default lRpc := .T.

    nIdE1 := nE1Id
    
    cEmp := aParms[len(aParms)-3]
    cFil := aParms[len(aParms)-2]
    
    if lRpc
        PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil MODULO 'FAT'
    endif
            Execute()
    if lRpc
        RESET ENVIRONMENT
    endif

    aParms := Nil
    cEmp := Nil
    cFil := Nil

return

static function Execute()
    local cAlias    := GetNextAlias()
    local oRes
    local cIdPix
    local oPayLoad 
    local cChave    := getNewPar( "MV_#PIXKEY", "4581f4b7-957f-4aba-9ae8-c1c174e9452c")
    local nExpKey   := 0
	local cCondPix  := GetNewPar("MV_#CONPIX", "PIX")
    local dDataPrc  := dDataBase
    local cFilE1    := iif( nIdE1 > 0, '% and SE1.R_E_C_N_O_ = '+str(nIdE1)+' %', '%%')

    private oPix      := ADFIN123P():New()
    
    dbSelectArea("FIE")
    dbSelectArea("SE1")
    dbSelectArea("SC5")
    dbSelectArea("SA1")

    beginSQL Alias cAlias

        SELECT
                FIE.R_E_C_N_O_ AS [FIE_RECNO], 
                SE1.R_E_C_N_O_ AS [E1_RECNO], 
                SC5.R_E_C_N_O_ AS [C5_RECNO],
                SA1.R_E_C_N_O_ AS [A1_RECNO]
        FROM 
            %table:FIE% FIE
            INNER JOIN %table:SC5% SC5  (NOLOCK)
                ON SC5.%notdel%
                AND FIE_FILIAL  = C5_FILIAL
                AND FIE_CART 	= 'R'
                AND FIE_PEDIDO  = C5_NUM
                AND FIE_CLIENT  = C5_CLIENTE
                AND FIE_LOJA    = C5_LOJACLI
                AND C5_EST		<> 'EX'
                AND C5_TIPO 	= 'N'
                AND C5_CONDPAG  = %exp:cCondPix%
                AND C5_EMISSAO  = %exp:dDataPrc%
            INNER JOIN %table:SE1% SE1  (NOLOCK)
                ON SE1.%notdel%
                AND FIE_FILIAL  = E1_FILIAL
                AND FIE_PREFIX  = E1_PREFIXO
                AND FIE_NUM		= E1_NUM
                AND FIE_PARCEL  = E1_PARCELA
                AND FIE_TIPO    = E1_TIPO
                AND FIE_CLIENT  = E1_CLIENTE
                AND FIE_LOJA    = E1_LOJA
                AND E1_XLOGPIX  IN ( '', '000', 'GER', 'ERR')
                AND E1_TIPO     = 'PR '
                AND E1_SALDO    > 0
                %exp:cFilE1%
            INNER JOIN %table:SA1% SA1  (NOLOCK)
                ON SA1.%notdel%
                AND A1_FILIAL   = %xFilial:SA1%
                AND FIE_CLIENT  = A1_COD
                AND FIE_LOJA    = A1_LOJA
        WHERE 
                FIE.%notdel%
            AND FIE.FIE_FILIAL  = %xFilial:FIE%
    endSQL

    while (cAlias)->(!eof())
        
        FIE->(dbGoTo((cAlias)->FIE_RECNO))
        SE1->(dbGoTo((cAlias)->E1_RECNO))
        SC5->(dbGoTo((cAlias)->C5_RECNO))
        SA1->(dbGoTo((cAlias)->A1_RECNO))

        nExpKey := fCalcExp()

        if SE1->E1_XLOGPIX != 'GER'
            cIdPix    := alltrim(FWArrFilAtu()[SM0_CGC]) + fwtimestamp(4) + alltrim(cValtoChar(SE1->(Recno())))
            
            oPayLoad := JsonObject():New()
            oPayLoad['chave'] := cChave
            oPayLoad['txid']  := cIdPix
            oPayLoad['solicitacaoPagador'] := alltrim("PEDIDO " + SC5->C5_NUM)
            oPayLoad['calendario']   := JsonObject():New()
            oPayLoad['calendario']['criacao']   := FWTimeStamp(3)
            oPayLoad['calendario']['expiracao'] := nExpKey
            oPayLoad['devedor'] := JsonObject():New()
            oPayLoad['devedor']['cnpj'] := alltrim(SA1->A1_CGC)
            oPayLoad['devedor']['nome'] := alltrim(left(SA1->A1_NOME, 25)) // TAM 25 PADRAO FIX
            oPayLoad['valor'] := JsonObject():New()
            oPayLoad['valor']['original'] := alltrim(str( SE1->E1_VALOR,,2))
            //oPayLoad['valor']['modalidadeAlteracao'] := 0

            if oPix:putPix( cIdPix, oPayLoad, @oRes )
                oPix:setEMV( oRes )
                oPix:setQrCode( oRes )

                recLock("SC5", .f.)
                    SC5->C5_XWSBOLG := "S"
                SC5->( msUnLock() )

            else
                fLogRes('ERR', oRes:toJson())
            endif

            FreeObj( oPayLoad )

        else
            oRes := JsonObject():new()
            oRes:fromJson(SE1->E1_XMEMPIX)            
            oPix:setEMV( oRes )
            oPix:setQrCode( oRes )
        endif

        if oRes != Nil .and. SE1->E1_XLOGPIX != 'ERR' .and. fMailPix( oRes['cob']['txid'])
            fLogRes('EML', oRes:toJson())
        endif

        (cAlias)->(dbSkip())

        FreeObj(oRes)

    enddo

    (cAlias)->(dbCloseArea())

    FreeObj(oPix)

return

static function fMailPix( cIdPix )
    local cHtml := ""
    local aAttach := {}
    local lRet := .F.
    local cArqLogo  := GetNewPar("MV_#ADLOGO", "/system/logo_cc.png" )
    local cMail     := AllTrim(IIF(!EMPTY(SA1->A1_EMAIL),SA1->A1_EMAIL,SA1->A1_EMAICO))
    local cMailCc   := AllTrim(Posicione( "SA3", 1, FWFilial("SA3") + SC5->C5_VEND1, "A3_EMAIL" ))
    local cMailBcc  := GetNewPar("MV_#EPIXTI", "" )

    cHtml := fHtmlBody()

    AAdd( aAttach, {cArqLogo, 'logo'})
    AAdd( aAttach, {'/qrcode/'+cIdPix+'.png', 'qrcode'})

    lRet := u_ADFIN126P(,cMail,cMailCc,cMailBcc, "Pedido AD'ORO - " + SC5->C5_NUM, cHtml, aAttach)    

    FErase( '/qrcode/'+cIdPix+'.png' ) 

return lRet

static function fHtmlBody()
    local cBody     := ""
    local cItensDef := ""
    local cItensRet := ""
    local cItensTmp := ""
    local aArrFilAtu := FWArrFilAtu()
    local cAlias    := GetNextAlias()
    local nQtdPed   := 0
    local n2QtdPed  := 0    
    local nVlrPed   := 0
    local nDescont  := 0
    local cEmvB64   := ""

    BeginContent var cBody
        <!doctype html>
        <html>

        <head>
            <meta charset="cp-1252">
        </head>

        <body>
            <div
                style="max-width: auto;margin: auto;padding: 30px;border: 1px solid #eee;font-size: 11px;line-height: 18px;font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;color: #555;">
                <table cellpadding="0" cellspacing="0" style="width: 100%;line-height: inherit;text-align: left;padding-bottom: 20px;">
                    <tr align="center">
                        <td colspan="2" 
                            style="padding: 10px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            <img style="display:table-cell; vertical-align:middle; text-align:center;width: 10%;height: auto;"
                                src="cid:logo"
                                alt="logo da empresa">
                        </td>
                        <td colspan="2"
                            style="padding: 10px;vertical-align: middle;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            <strong>
                                #NOMEEMP</br>
                            </strong>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            <strong>DADOS DO PEDIDO: </strong>
                        </td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            #NUMPED 
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;width: 10%;">
                            <strong>Código:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;width: 40%;">
                            #CODCLI-#LOJACLI
                        </td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;width: 10%;">
                            <strong>Data Emissão:</strong>
                        </td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;width: 40%;">
                            #EMISSAOPED
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Nome:</strong>
                        </td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #NOMECLI
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>CNPJ/CPF:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #CNPJCLI </td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Vendedor:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #VENDENOME</td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Telefone:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #FONECLI </td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Tipo Pessoa:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #TPCLI</td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Endereço:</strong>
                        </td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #ENDCLI
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Município:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #MUNCLI</td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Estado:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #UFCLI</td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Tipo do frete:</strong></td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #TPFRETE </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Transportadora:</strong>
                        </td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #TRANSPORT
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Peso Bruto:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #PESOBRU</td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Peso Líquido:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #PESOLIQ</td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Mens.Pedido:</strong>
                        </td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #MENSCLI
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>Mens.NFe:</strong> 
                        </td>
                        <td colspan="3" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            #MENSNF
                        </td>
                    </tr>
                </table>
                <table cellpadding="0" cellspacing="0" style="width: 100%;line-height: inherit;text-align: left;padding-bottom: 20px;">
                    <tr>
                        <td colspan="10"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            <strong>ITENS DO PEDIDO</strong>
                        </td>
                    </tr>
                    <tr>
                        <td width="5%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Código</td>
                        <td width="30%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Descrição</td>
                        <td align="center" width="10%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            UM</td>
                        <td align="right" width="5%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Qtde</td>
                        <td align="center" width="10%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Seg.UM</td>
                        <td align="right" width="5%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Qtde Seg.UM</td>
                        <td align="right" width="10%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Vl.Unit.</td>
                        <td align="right" width="5%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Descont.</td>
                        <td align="right" width="10%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Vl.Unit.Liq</td>
                        <td align="right" width="10%"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            Vl.Total Liq.</td>
                    </tr>

                    #ITENS
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td align="center"
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;">#QTDTOTAL</td>
                        <td align="center"
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td align="right"
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;">#2QTDTOTAL</td>
                        <td align="right"
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td align="right" 
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td align="right" 
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;"></td>
                        <td align="right"
                            style="padding: 5px;vertical-align: top;border-top: 2px solid #eee;font-weight: bold;">#VALORTOTAL
                        </td>
                    </tr>
                </table>
                <table cellpadding="0" cellspacing="0" style="width: 100%;line-height: inherit;text-align: left;padding-bottom: 20px;">
                    <tr>
                        <td colspan="2"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            <strong>DETALHES PARA PAGAMENTO</strong>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>PIX - QRCode:</strong></td>
                        <td 
                            style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <img style="display:table-cell; vertical-align:middle; text-align:center;width: 20%;height: auto;"
                                src="cid:qrcode">
                            </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>PIX - Copia/Cola:</strong></td>
                        <td style="padding: 5px; text-align: left; vertical-align: top;border-bottom: 1px solid #eee;">
                            <a  href="https://www.adoro.com.br/pix?emv=#EMVBASE64"
                                target="_blank"
                                type="text">
                                <strong>Click aqui para copiar a chave PIX</strong>
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            <strong>EMV PIX:</strong></td>
                        <td 
                            style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;text-decoration: none;pointer-events: none;">
                            <a href='#' style="color:#000; text-decoration:none">#EMVSTRING</a>
                        </td>
                    </tr>
                </table>
                <table cellpadding="0" cellspacing="0" style="width: 100%;line-height: inherit;text-align: left;padding-bottom: 20px;">
                    <tr>
                        <td colspan="2"
                            style="padding: 5px;vertical-align: top;background: #eee;border-bottom: 1px solid #ddd;font-weight: bold;">
                            <strong>ALGUMA DÚVIDA?</strong>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;width: 10%;">
                            <strong>Telefone:</strong></td>
                        <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">
                            (11) 4596.8400</td>
                    </tr>
                </table>
            </div>
        </body>

        </html>
    endContent

    BeginContent var cItensDef
        <tr>
            <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#CODITEM</td>
            <td style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#DESCITEM</td>
            <td align="center" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#UMITEM</td>
            <td align="right" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#QUANTITEM</td>
            <td align="center" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#2UMITEM</td>
            <td align="right" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#2QUANTITEM</td>
            <td align="right" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#PRCITEM</td>
            <td align="right" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#DESCONTOITEM</td>
            <td align="right" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#PRCVITEM</td>
            <td align="right" style="padding: 5px;vertical-align: top;border-bottom: 1px solid #eee;">#TOTALITEM</td>
        </tr>
    endContent

    cBody := StrTran( cBody, "#NOMEEMP" , aArrFilAtu[SM0_NOMECOM])
    //cBody := StrTran( cBody, "#ENDEMP"  , aArrFilAtu['SM0_NOMECOM'])
    //cBody := StrTran( cBody, "#MUNEMP"  , aArrFilAtu['SM0_NOMECOM'])
    //cBody := StrTran( cBody, "#UFEMP"   , aArrFilAtu['SM0_NOMECOM'])
    cBody := StrTran( cBody, "#NUMPED"      , SC5->C5_NUM )
    cBody := StrTran( cBody, "#CODCLI"      , SA1->A1_COD )
    cBody := StrTran( cBody, "#LOJACLI"     , SA1->A1_LOJA )
    cBody := StrTran( cBody, "#EMISSAOPED"  , DtoC(SE1->E1_EMISSAO) )
    cBody := StrTran( cBody, "#NOMECLI"     , SA1->A1_NOME )
    if SA1->A1_PESSOA == "F"
        cCnpj := Transform( SA1->A1_CGC, "@R 999.999.999-99")
    else
        cCnpj := Transform( SA1->A1_CGC, "@R 99.999.999/9999-99")
    endif

    cBody := StrTran( cBody, "#TRANSPORT"   , "" )

    cBody := StrTran( cBody, "#CNPJCLI"     , cCnpj )
    cBody := StrTran( cBody, "#VENDENOME"   , posicione("SA3",1, xFilial("SA3") + SC5->C5_VEND1, "A3_NOME") )
    cBody := StrTran( cBody, "#FONECLI"     , SA1->A1_TEL )
    cBody := StrTran( cBody, "#TPCLI"       , iif(SA1->A1_PESSOA == "F", "Física", "Jurídica") )
    cBody := StrTran( cBody, "#ENDCLI"      , SA1->A1_END )
    cBody := StrTran( cBody, "#MUNCLI"      , SA1->A1_MUN )
    cBody := StrTran( cBody, "#UFCLI"       , SA1->A1_EST )
    cBody := StrTran( cBody, "#PESOBRU"     , transform( SC5->C5_PBRUTO, "@E 999,999,999.99") )
    cBody := StrTran( cBody, "#PESOLIQ"     , transform( SC5->C5_PESOL , "@E 999,999,999.99") )
    cBody := StrTran( cBody, "#TPFRETE"     , iif( SC5->C5_TPFRETE == "C", "CIF", "FOB" ) )
    cBody := StrTran( cBody, "#MENSCLI"     , SC5->C5_MENNOTA )
    cBody := StrTran( cBody, "#MENSNF"      , SC5->C5_MENNOTA )
    cBody := StrTran( cBody, "#EMVSTRING"   , oPix:getEMV() )

    cEmvB64 := ENCODE64( oPix:getEMV() )
    cBody := StrTran( cBody, "#EMVBASE64"    ,  cEmvB64 )

    beginSQL Alias cAlias
        SELECT 
            SC6.R_E_C_N_O_ AS [C6_RECNO]
        FROM 
            %table:SC6% SC6
        WHERE
                SC6.%notdel%
            AND C6_FILIAL   = %xFilial:SC6%
            and C6_NUM      = %exp:SC5->C5_NUM%
        ORDER BY
            C6_ITEM
    endSQL
    
    while (cAlias)->(!eof())

        SC6->( dbGoTo( (cAlias)->C6_RECNO ) ) 

        nQtdPed += SC6->C6_QTDVEN
        n2QtdPed += SC6->C6_UNSVEN
        nVlrPed += SC6->C6_VALOR
        nDescont := SC6->(C6_PRCVEN-C6_VALDESC)

        cItensTmp := cItensDef
        cItensTmp := StrTran( cItensTmp, "#CODITEM"     , SC6->C6_PRODUTO   )
        cItensTmp := StrTran( cItensTmp, "#DESCITEM"    , SC6->C6_DESCRI    )
        cItensTmp := StrTran( cItensTmp, "#UMITEM"      , SC6->C6_UM        )
        cItensTmp := StrTran( cItensTmp, "#QUANTITEM"   , transform( SC6->C6_QTDVEN, PesqPict( "SC6", "C6_QTDVEN" ))      )
        cItensTmp := StrTran( cItensTmp, "#2UMITEM"     , SC6->C6_SEGUM     )
        cItensTmp := StrTran( cItensTmp, "#2QUANTITEM"  , transform( SC6->C6_UNSVEN, PesqPict( "SC6", "C6_UNSVEN" ))      )
        cItensTmp := StrTran( cItensTmp, "#PRCITEM"     , transform( SC6->C6_PRCVEN, PesqPict( "SC6", "C6_PRCVEN" ))  )
        cItensTmp := StrTran( cItensTmp, "#DESCONTOITEM", iif(nDescont>0,transform( SC6->C6_VALDESC, PesqPict( "SC6", "C6_VALDESC" )),"") )
        cItensTmp := StrTran( cItensTmp, "#PRCVITEM"    , transform( SC6->(C6_PRCVEN-C6_VALDESC), PesqPict( "SC6", "C6_PRCVEN" ))   )
        cItensTmp := StrTran( cItensTmp, "#TOTALITEM"   , transform( SC6->C6_VALOR, PesqPict( "SC6", "C6_VALOR" ))   )
        cItensRet += cItensTmp
        (cAlias)->(dbSkip())
    enddo

    (cAlias)->(dbCloseArea())
    cBody := StrTran( cBody, "#ITENS"       , cItensRet )
    cBody := StrTran( cBody, "#QTDTOTAL"    , transform( nQtdPed , PesqPict( "SC6", "C6_QTDVEN" )) )
    cBody := StrTran( cBody, "#2QTDTOTAL"   , transform( n2QtdPed, PesqPict( "SC6", "C6_UNSVEN" )) )
    cBody := StrTran( cBody, "#VALORTOTAL"  , transform( nVlrPed , PesqPict( "SC6", "C6_VALOR"  )) )


return cBody

static function fLogRes(cCodRes, cLogRes)

    recLock("SE1", .F.)
    SE1->E1_XLOGPIX := cCodRes
    SE1->E1_XMEMPIX := cLogRes
    SE1->(MsUnLock())

    u_GrLogZBE (Date(),TIME(),cUserName, "PROCESSAMENTO PIX","TI","ADFIN130P",cLogRes,ComputerName(),LogUserName())

return

static function fCalcExp()

    local nRet := 0
    local nExpPix := getNewPar("MV_#PIXEXP", 21.00)

    nRet := DataHora2Val( date() , TimeToFloat( Time() ) , date() , nExpPix ) * 60

return nRet


