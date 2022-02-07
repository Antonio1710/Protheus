#include "Protheus.ch"
#include "Apwebsrv.ch"

User Function tstGuardian()

    Local oGuardian := WSWS_GUARDIAN():New()
    Local cUrl      := "http://186.224.100.105:48883/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx"
    Local nIdFoto   := 0
    Local oRetSolic := Nil
    Local lRetSolic := .F.
    Local nRetSolic := 0
    Local cErro     := ""
    Local aRet      := {}

    Local cTicketTst := "0080203"
    Local cTag1      := "E2004074951102222030461C"
    Local cTag2      := "E200001B2115014413707070"

    //
    Conout("Chamadas Guardian")
    WSDLDbgLevel(3)

    //Solicita foto avulsa.
    //solicFoto(oGuardian,cUrl,@nIdFoto,@cErro,"PONTO_PESAGEM","P2","","TESTE20190911","WS G"  ,"01")

    //Solicita retorno da foto avulsa.
    //solicRFoto(oGuardian,cUrl,@oRetSolic,@cErro,184102,"WS G","01")

    //Efetua pr้-cadastro.
    // If cadTicket(oGuardian,cUrl,@oRetSolic,@cErro,"FUB4847","FUB4847",cTag2,"F1","000056",0,"","")
    //     Conout("Ticket " + cValToChar(oRetSolic:cCodigo) )
    //     VarInfo("oRetSolic",oRetSolic)

    // Else
    //     Conout("cErro " + cErro)

    // EndIf

    //Efetua pr้-cadastro com peso inicial maior que 0.
    /*If cadTicket(oGuardian,cUrl,@oRetSolic,@cErro,"ETL-5051","ETL-5051",cTag1,"F1","PT0001",10000,"","")
        Conout("Ticket " + cValToChar(oRetSolic:cCodigo) )
        VarInfo("oRetSolic",oRetSolic)

    Else
        Conout("cErro " + cErro)

    EndIf*/

    //Altera tag.
    If altTag(oGuardian,cUrl,@oRetSolic,@cErro,"ETL-5051","ETL-5051",cTag2,"F1","0080375")
        Conout("Ticket " + cValToChar(oRetSolic:cCodigo) )
        VarInfo("oRetSolic",oRetSolic)

    Else
        Conout("cErro " + cErro)

    EndIf
    
    //Remonta ticket.
    /*lRetSolic := remontFlux(oGuardian,cUrl,@cErro,cTicketTst,"F8","WS G","01") //Remonta fluxo para F8.
    Conout( "lRetSolic " + cValToChar(lRetSolic) )
    Conout( "cErro " + cErro )*/

    /*lRetSolic := remontFlux(oGuardian,cUrl,@cErro,cTicketTst,"F3","WS G","01") //Remonta fluxo para F3.
    Conout( "lRetSolic " + cValToChar(lRetSolic) )
    Conout( "cErro " + cErro )*/

    //Solicita exporta็ใo de tickets marcados
    // While .T.
    //     If expTicket(Nil,cUrl,@oRetSolic,@cErro)
    //         aRet := oRetSolic:OWSTICKET

    //     Else
    //         Conout("cErro " + cErro)

    //     EndIf

    //     //
    //     //If Len(aRet) > 0
    //         //Exit 

    //     //EndIf

    //     //
    //     slvPesa(aRet)

    //     //
    //     Sleep(3000)

    //     //
    //     oRetSolic := NIL

    // End

    //Envia mensagem
    /*If enviaMsg(oGuardian,cUrl,@nRetSolic,@cErro,"PONTO_PESAGEM",0,"TESTE",3)
        Conout( "nRetSolic " + cValToChar(nRetSolic) )

    Else 
        Conout( "cErro " + cErro )

    EndIf*/

    //Manuten็ใo de ticket.
    /*lRetSolic := mntTicket(oGuardian,cUrl,@cErro,cTicketTst,4,"WS G","01") //Cancelar ticket.
    Conout( "lRetSolic " + cValToChar(lRetSolic) )
    Conout( "cErro " + cErro )*/

    /*lRetSolic := mntTicket(oGuardian,cUrl,@cErro,cTicketTst,3,"WS G","01") //Encerrar ticket.
    Conout( "lRetSolic " + cValToChar(lRetSolic) )
    Conout( "cErro " + cErro )*/

    //Cancela ๚ltima opera็ใo ativa.
    /*lRetSolic := cancUlOpe(oGuardian,cUrl,@cErro,cTicketTst,"WS G","01") //Cancela ๚ltima opera็ใo ativa.
    Conout( "lRetSolic " + cValToChar(lRetSolic) )
    Conout( "cErro " + cErro )*/

    //
    /*lRetSolic := rfazUlOpe(oGuardian,cUrl,@cErro,cTicketTst,"WS G","01") //Refaz ๚ltima opera็ใo ativa.
    Conout( "lRetSolic " + cValToChar(lRetSolic) )
    Conout( "cErro " + cErro )*/

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ cadTicketบ Autor ณ Everson - 051527                                     บ Data ณ  12/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Cadastro de ticket de pesagem no Guardian.                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function cadTicket(oGuardian,cUrl,oRetSolic,cErro,cPlcCarret,cPlcVeic,cTag,cFluxo,cTickProth,nPesIni,cPerifIni,cOpPesIni)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:OWSDADOSTICKET:cCodigo := cTickProth
    oGuardian:OWSDADOSTICKET:cPlacaCarreta  := cPlcCarret
    oGuardian:OWSDADOSTICKET:cPlacaVeiculo  := cPlcVeic
    oGuardian:OWSDADOSTICKET:cTagAssociado  := cTag
    oGuardian:OWSDADOSTICKET:cFluxo := cFluxo
    oGuardian:OWSDADOSTICKET:cReferenciaIntegracao := cTickProth

    //
    If nPesIni > 0
        oGuardian:OWSDADOSTICKET:nPesoDaPesagemInicial := nPesIni
        oGuardian:OWSDADOSTICKET:cPerifericoDaPesagemInicial := cPerifIni
        oGuardian:OWSDADOSTICKET:cOperacaoDaPesagemInicial := cOpPesIni

    EndIf
    
    //
    If oGuardian:CadastraTicketGuardian()
        
        //
        If oGuardian:nErro = 303221
            lRet := .T.
            oRetSolic := oGuardian:oWSCadastraTicketGuardianResult

        Else
            lRet := .F.
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ expTicketบ Autor ณ Everson - 051527                                     บ Data ณ  12/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Exporta tickets marcados.                                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function expTicket(oGuardian,cUrl,oRetSolic,cErro)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    
    //
    If oGuardian:ExportaTicketsMarcados()
        
        //
        If oGuardian:nErro = 0
            lRet := .T.
            oRetSolic := oGuardian:oWSExportaTicketsMarcadosResult

        Else
            lRet := .F.
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ coLTicketบ Autor ณ Everson - 051527                                     บ Data ณ  10/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Confirma leitura dos tickets exportados.                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function coLTicket()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    
    //
    RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ remontFluxบ Autor ณ Everson - 051527                                    บ Data ณ  12/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Remonta fluxo.                                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function remontFlux(oGuardian,cUrl,cErro,cCodTicket,cFluxo,cProduto,cCodigo)

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:cfluxoCodigo  := cFluxo
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    //
    If oGuardian:RemontaFluxo()
        lRet := oGuardian:lRemontaFluxoResult

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ cancUlOpeบ Autor ณ Everson - 051527                                     บ Data ณ  10/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Cancela ๚ltima opera็ใo.                                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cancUlOpe(oGuardian,cUrl,cErro,cCodTicket,cProduto,cCodigo)

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    //
    If oGuardian:CancelaUltimaOperacaoAtiva()

        //
        If oGuardian:nSaiErro = 0
            lRet := oGuardian:lCancelaUltimaOperacaoAtivaResult

        Else 
            lRet := .F.
            cErro := Alltrim(cValToChar(oGuardian:nSaiErro)) + " " + Alltrim(cValToChar(oGuardian:cSaiErroMSG))

        EndIf 

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ rfazUlOpeบ Autor ณ Everson - 051527                                     บ Data ณ  12/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Refaz ๚ltima opera็ใo.                                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function rfazUlOpe(oGuardian,cUrl,cErro,cCodTicket,cProduto,cCodigo)

    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    //
    If oGuardian:RefazUltimaOperacaoAtiva()

        //
        If oGuardian:nSaiErro = 0
            lRet := oGuardian:lRefazUltimaOperacaoAtivaResult

        Else 
            lRet := .F.
            cErro := Alltrim(cValToChar(oGuardian:nSaiErro)) + " " + Alltrim(cValToChar(oGuardian:cSaiErroMSG))

        EndIf 

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ enviaMsgบ Autor ณ Everson - 051527                                      บ Data ณ  10/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Envia mensagem para o display.                                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function enviaMsg(oGuardian,cUrl,nRetSolic,cErro,cPontoCont,nPosicao,cMensagem,nTempo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:cPontoControle := cPontoCont
    oGuardian:nPosicao := nPosicao
    oGuardian:cMensagem := cMensagem
    oGuardian:nTempo := nTempo

    //
    If oGuardian:EnviaMensagemDisplay()

        //
        If oGuardian:nErro = 0
            lRet := .T.
            nRetSolic := oGuardian:nEnviaMensagemDisplayResult

        Else
            lRet := .F.
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()

    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณaltTicket บ Autor ณ Everson - 051527                                     บ Data ณ  13/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Altera informa็๕es do Ticket do Guardian.                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function altTag(oGuardian,cUrl,oRetSolic,cErro,cPlcCarret,cPlcVeic,cTag,cFluxo,cTickProth)
    
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.

    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:OWSDADOSTICKET:cCodigo := cTickProth
    oGuardian:OWSDADOSTICKET:cPlacaCarreta  := ""//cPlcCarret
    oGuardian:OWSDADOSTICKET:cPlacaVeiculo  := ""//cPlcVeic
    oGuardian:OWSDADOSTICKET:cTagAssociado  := cTag
    oGuardian:OWSDADOSTICKET:nPesoTotalOrigem := 0
    //oGuardian:OWSDADOSTICKET:cFluxo := cFluxo
    //oGuardian:OWSDADOSTICKET:cReferenciaIntegracao := cTickProth

    //
    oGuardian:oWSCFGALTERACAO:lIgnoraTransportadora := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraEmissor := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraItens := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraMotorista := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraDocumentos := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraCamposAdicionais := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraFatorCorrecao := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraConteineres := .T.
    oGuardian:oWSCFGALTERACAO:lIgnoraFluxo := .T.
    Conout(">>>>>>>>>>>>>>>> AlteraTicketGuardian")
    
    //
    If oGuardian:AlteraTicketGuardian()
    
        //
        If oGuardian:nErro = 303221
            lRet := .T.
            oRetSolic := oGuardian:oWSAlteraTicketGuardianResult

        Else
            lRet := .F.
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmntTicketบ Autor ณ Everson - 051527                                      บ Data ณ  10/09/2019 บฑฑ
ฑฑ 1 = Bloquear, 2 = Desbloquear, 3 = Encerrar, 4 = Cancelar                                                 ฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Manuten็ใo de ticket.                                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function mntTicket(oGuardian,cUrl,cErro,cCodTicket,nNumOp,cProduto,cCodigo)
    
    //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:cticketCodigo := cCodTicket
    oGuardian:nnumOperacao  := nNumOp
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo
    
    //
    If oGuardian:ManutencaoTicket()
        lRet := oGuardian:lManutencaoTicketResult

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()
        
    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsolicFotoบ Autor ณ Everson - 051527                                      บ Data ณ  10/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Solicita foto avulsa.                                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function solicFoto(oGuardian,cUrl,nNumRet,cErro,cCodPonCont,cPosCam,cCaminho,cNmFoto,cProduto,cCodigo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local lRet  := .F.
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:ccodigoPontoControle := cCodPonCont
    oGuardian:cposicaoCamera := cPosCam
    oGuardian:ccaminhoFoto := cCaminho
    oGuardian:cnomeFoto := cNmFoto
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo

    //
    If oGuardian:SolicitaFotoAvulsa()

        //
        If oGuardian:nErro = 0
            lRet := .T.
            nNumRet := Val(cValToChar(oGuardian:nSolicitaFotoAvulsaResult))

        Else
            lRet := .F.
            cErro := cValToChar(oGuardian:nErro) + " " + Alltrim(cValToChar(oGuardian:cErroMSG))

        EndIf

    Else
        lRet := .F.
        cErro := "GetWSCError " + GetWSCError()

    EndIf 

    //
    RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsolicRFotoบ Autor ณ Everson - 051527                                     บ Data ณ  10/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Solicita retorno da foto avulsa.                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function solicRFoto(oGuardian,cUrl,oRetSolic,nIdSolic,cProduto,cCodigo)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    
    Default oGuardian   := Nil

    //
    If ValType(oGuardian) <> "O"
        oGuardian := WSWS_GUARDIAN():New()
        
    EndIf

    //Carrega parโmetros.
    oGuardian:_URL := cUrl
    oGuardian:nidSolicitacaoAvulsa := nIdSolic
    oGuardian:cproduto := cProduto
    oGuardian:ccodigo := cCodigo

    //
    If oGuardian:SolicitaRetornoFotoAvulsa()
        oRetSolic := oGuardian:oWSSolicitaRetornoFotoAvulsaResult

    Else
        cErro := "GetWSCError " + GetWSCError()

    EndIf 

    //
    RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณslvPesa   บ Autor ณ Everson - 051527                                     บ Data ณ  12/09/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Solicita retorno da foto avulsa.                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function slvPesa(aRet)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
    //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    Local aArea := GetArea()
    Local cTpReg:= "2/3" //2= Peso inicial / 3= Peso final.
    Local nAux  := 1
    Local oReg  := Nil
    Local nAux2 := 1

    //
    For nAux := 1 To Len(aRet)

        //
        oReg := aRet[nAux]:OWSOPERACAOTICKET:OWSOPERACAOTICKET

        //
        For nAux2 := 1 To Len(oReg)

            //
            cTpOp  := Alltrim(cValToChar(oReg[nAux2]:NTIPOOPERACAOCODIGO))

            //
            If cTpOp $cTpReg

                //
                cCod   := Alltrim(cValToChar(oReg[nAux2]:CCODIGO))
                cPlaca := Alltrim(cValToChar(oReg[nAux2]:CPLACAVEICULO))
                cDTPesa:= Alltrim(cValToChar(oReg[nAux2]:CDATAPESAGEM))

                //
                If cTpOp = "2"
                    nPeso   := Val(cValToChar(oReg[nAux2]:NPESO))

                Else
                    nPeso   := Val(cValToChar(oReg[nAux2]:NPESOLIQOBTIDO))
                
                EndIf

                //
                Conout( "oReg[nAux2]:NTIPOOPERACAOCODIGO " + cTpOp + " " + cCod + " " + cPlaca + " " + cDTPesa + " " + cValToChar(nPeso) )

                //
                VarInfo("aRet[nAux]",aRet[nAux])

            EndIf 

        Next nAux2

    Next nAux

    //
    RestArea(aArea)

Return Nil
