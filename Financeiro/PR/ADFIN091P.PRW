#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADFIN091P
    Envio de relatório com dados de contratos
    de desconto que irão vencer.
    @type  Function
    @author Everson
    @since 04/08/2020
    @version 01
    /*/
User Function ADFIN091P() // U_ADFIN091P()

    //Variáveis.
    
    //Inícia o ambiente. 
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        //
        geraRel()

	//Fecha o ambiente.
	RpcClearEnv()

Return Nil
/*/{Protheus.doc} geraRel
    Processa a geração do relatório
    @type  Static Function
    @author Everson
    @since 04/08/2020
    @version 01
    /*/
Static Function geraRel()
    
    //Variáveis.
    Local aArea  := GetArea()
    Local dDtVenc:= Date() + 1 
    Local cQuery := script(dDtVenc)
    Local cEmail := GetMv("MV_#VNCCOT",,"everson.silva@adoro.com.br")
    Local cMsg   := ""

    //
    If Select("D_DADOS") > 0
        D_DADOS->(DbCloseArea())

    EndIf

    cMsg += ' <!DOCTYPE html> '
    cMsg += ' <html lang="pt-br"> '
    cMsg += ' <head> '
    cMsg += ' <meta charset="UTF-8"> '
    cMsg += ' <meta name="viewport" content="width=device-width, initial-scale=1.0"> '
    cMsg += ' <title>Contratos de Desconto com Vencendo em ' + DToC(dDtVenc) + '</title> '
    cMsg += ' </head> '
    cMsg += ' <body> '
    cMsg += ' <div style="width: 60%;margin: auto;background-color: rgb(253, 253, 253);"> '
    cMsg += ' <p style="text-align: center;background-color: lightgray;padding: 10px;">Olá, seguem abaixo os contratos de desconto vencendo em ' + DToC(dDtVenc) + '.</p> ' 
    cMsg += ' <br> '
    cMsg += ' <table align="center" style="width: 100%;text-align: center; margin: 10px;"> '
    cMsg += ' <thead> '
    cMsg += ' <tr> '
    cMsg += ' <th>Código SA1</th> '
    cMsg += ' <th>Loja SA1</th> '
    cMsg += ' <th>Nome</th> '
    cMsg += ' <th>Desc(%)</th> '
    cMsg += ' <th>Vencimento</th> '
    cMsg += ' </tr> '
    cMsg += ' </thead> '
    cMsg += ' <tbody> '

    //
    TcQuery cQuery New Alias "D_DADOS"
    DbSelectArea("D_DADOS")
    D_DADOS->(DbGoTop())

        //
        cMsg += ' <tr> '
        cMsg += ' <td>' + Alltrim(cValToChar(D_DADOS->PB3_CODSA1)) + '</td> '
        cMsg += ' <td>' + Alltrim(cValToChar(D_DADOS->PB3_LOJSA1)) + '</td> '
        cMsg += ' <td>' + Alltrim(cValToChar(D_DADOS->PB3_NOME))   + '</td> '
        cMsg += ' <td>' + Alltrim(Transform(Val(cValToChar(D_DADOS->PB3_DESC)), '@E 999,99'))   + '</td> '
        cMsg += ' <td>' + Alltrim(DToC(SToD(D_DADOS->PB3_DTVLDE))) + '</td> '
        cMsg += ' </tr> '

    //
    D_DADOS->(DbCloseArea())

    //
    cMsg += ' </tbody> '
    cMsg += ' </table> '
    cMsg += ' <div style="padding: 10px;"> '
    cMsg += ' <hr/> '
    cMsg += ' <br/> '
    cMsg += ' <p>Fonte: ADFIN091P</p> '
    cMsg += ' <p>Gerado em: ' + DToC(Date()) + ' às ' + Time() + '</p> '
    cMsg += ' </div> '
    cMsg += ' </div> '
    cMsg += ' </body> '
    cMsg += ' </html> '

    //
    U_enviarEmail(cEmail,"Contratos de Desconto com Vencendo em " + DToC(dDtVenc),cMsg,,.F.)

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} script
    Script sql com os dados de contratos
    de desconto.
    @type  Static Function
    @author Everson
    @since 04/08/2020
    @version 01
    /*/
Static Function script(dDtVenc)
    
    //Variáveis.
    local cQuery := ""

    //
    cQuery += " SELECT " 
    cQuery += " PB3_CODSA1, PB3_LOJSA1, PB3_NOME, PB3_DESC, PB3_DTVLDE " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("PB3") + " (NOLOCK) AS PB3 " 
    cQuery += " WHERE " 
    cQuery += " PB3_DTVLDE <> '' " 
    cQuery += " AND PB3_DTVLDE = '" + DToS(dDtVenc) + "' " 
    cQuery += " AND PB3.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY " 
    cQuery += " PB3_CODSA1, " 
    cQuery += " PB3_LOJSA1 " 

Return cQuery
