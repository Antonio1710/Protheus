#Include "Topconn.ch"       
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "Fileio.ch"
#Include "WFHttp.ch" 
#Include "Protheus.ch"
/*/{Protheus.doc} User Function WFPE007
    Ponto de entrada.
    Permite customizar a mensagem de processamento do workflow por link.
    @type  Function
    @author Everson
    @since 11/05/2020
    @version 01
    @history Everson, 18/05/2020. Chamado 058244 - No recebimento da cotação, informar o comprador via e-mail.
    /*/
User Function WFPE007()
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local cHTML         := ""
    Local plSuccess     := ParamIXB[1] 
    Local pcMessage     := ParamIXB[2] 
    Local pcProcessID   := ParamIXB[3]

    //
    If ( plSuccess )

        //
        altArq(pcProcessID)

        //
        StartJob("U_WFPEAD01",getenvserver(),.F.,FwCodEmp(),FWxFilial(),pcProcessID,.T.) //Everson, 18/05/2020. Chamado 058244.

    EndIf 

    // Mensagem em retorno.
    cHtml := MemoRead("\workflow\workflowcompras\cotacao\final\recebido.html")
    cHtml := StrTran(cHtml,"#TEXTO#",pcMessage)

Return cHTML
/*/{Protheus.doc} altArq
    Altera o arquivo na pasta do Nginx.
    @type  Static Function
    @author Everson
    @since 11/05/2020
    @version 01
    /*/
Static Function altArq(pcProcessID)
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local cHtml := MemoRead("\workflow\workflowcompras\cotacao\final\ignorado.html")

    //
    MemoWrite("\workflow\workflowcompras\cotacao\final\" + pcProcessID +".htm",cHtml)

    //
    WaitRunSrv('xcopy "D:\TOTVS\Protheus12\protheus_data\workflow\workflowcompras\cotacao\final\' + pcProcessID + '.htm"  "D:\nginx\html\workflowcompras\processos\cotacao\" /c /q /y ',.T.,"C:\WINDOWS\system32\")

    //
    Ferase("\workflow\workflowcompras\cotacao\final\" + pcProcessID +".htm")

Return Nil
/*/{Protheus.doc} User Function WFPEAD01
    Envia e-mail ao comprador, informando o recebimento da cotação.
    Chamado 058244
    @type  Function
    @author Everson
    @since 18/05/2020
    @version 01
    /*/
User Function WFPEAD01(cEmp,cFil,pcProcessID,lRecebe)
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local oWF           := Nil
    Local cValFile      := ""
    Local aValues       := {}
    Local nPos          := 0
    Local aHtml         := {}
    Local aListValues   := {}
    Local nPosNum       := 0
    Local nPosComp      := 0
    Local nPosNome      := 0
    Local nPosCod       := 0
    Local nPosLoja      := 0
    Local aComp         := {}
    Local cComp         := ""
    Local cEmail        := ""
    Local cFornec       := ""
    Local cCotacao      := ""
    Local cBody         := ""

    //
    Default lRecebe     := .T.
    
    //Inicia o ambiente.
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

        //
        oWF := TWFObj()
        cValFile := lower( oWF:cProcessDir + pcProcessID + ".val" )
        aValues := WFLoadValFile( cValFile )

        //
        If ! ( ( nPos := AScan( aValues, { |x| Upper( AllTrim( x[1] ) ) == "OHTML"  } ) ) > 0 )
			Return Nil

        EndIf

        //
        aHtml := aValues[ nPos,3 ]

        //
        If ! ( ( nPos := AScan( aHtml, { |x| Upper( AllTrim( x[1] ) ) == "ALISTVALUES"  } ) ) > 0 )
			Return Nil

        EndIf

        //
        aListValues := aHtml[ nPos,3 ]
        aListValues := aListValues[1]
     
        //
        If ! ( ( nPosNum  := AScan( aListValues, { |x| Upper( AllTrim( x[1] ) ) == "C8_NUM"  } ) ) > 0 ) .Or.;
           ! ( ( nPosComp := AScan( aListValues, { |x| Upper( AllTrim( x[1] ) ) == "COMPRADOR"  } ) ) > 0 ) .Or.;
           ! ( ( nPosNome := AScan( aListValues, { |x| Upper( AllTrim( x[1] ) ) == "A2_NOME"  } ) ) > 0 ) .Or.;
           ! ( ( nPosCod  := AScan( aListValues, { |x| Upper( AllTrim( x[1] ) ) == "C8_FORNECE"  } ) ) > 0 ) .Or.;
           ! ( ( nPosLoja := AScan( aListValues, { |x| Upper( AllTrim( x[1] ) ) == "C8_LOJA"  } ) ) > 0 )

			Return Nil

        EndIf

        //
        aComp   := Separa(StrTran(aListValues[nPosComp][2],"<br>",";"),";",.T.)
 
        //
        If Len(aComp) <> 2
            Return Nil

        EndIf 

        //
        cComp   := aComp[1]
        cEmail  := aComp[2]
        cFornec := aListValues[nPosCod][2] + "/" + aListValues[nPosLoja][2] + "-" + aListValues[nPosNome][2]
        cCotacao:= aListValues[nPosNum][2]
        
        //
        cBody := '<!DOCTYPE html>'
        cBody += '<html lang="pt-br"> 
        cBody += '<head>'
        cBody += '</head>'
        cBody += '<body>'
        cBody += '<p>Olá, ' + cComp + '.</p>'

        //
        If lRecebe
            cBody += '<p>O fornecedor ' + cFornec + ' atualizou a cotação ' + cCotacao + '.</p>'

        Else
            cBody += '<p>O fornecedor ' + cFornec + ' não respondeu a solicitação da cotação ' + cCotacao + '.</p>'
            cBody += '<p>O processo de cotação foi encerrado.</p>'

        EndIf

        //
        cBody += '<br>'
        cBody += '<p>E-mail automático. Por favor, não responda.</p>'
        cBody += '</body>'
        cBody += '</html>'

        //
        U_enviarEmail(cEmail,"Cotação para compra (" + cCotacao + ")",cBody,,.F.)

    //Fecha o ambiente.
	RpcClearEnv()

Return Nil