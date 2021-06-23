#INCLUDE    "PROTHEUS.CH"
#INCLUDE    "TOPCONN.CH"
#INCLUDE    "RWMAKE.ch"
#INCLUDE    "TBICONN.CH"
#DEFINE CRLF CHR(13)+CHR(10)

//+------------------------------------------------------------------------------|
//ROTINA PARA ENVIO EM MASSA DOS ARQUIVOS XML       			                 |
//Data 18/06/2014 - EVERSON DANIEL  - T.I BR-AVES SÃO CARLOS			         | 
//+------------------------------------------------------------------------------|                    


User Function ADFIS003R()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'ROTINA PARA ENVIO EM MASSA DOS ARQUIVOS XML')
	
    Private cPerg           := "ADFIS003R"
    ValidPerg(cPerg)
    
    If  Pergunte(cPerg,.T.)
         Msaguarde({||SpedExport()},"Envio de XML","Aguarde, processando...",.T.)
    Else
        Return
    Endif
            
Return


Static Function SpedExport()

    //Variáveis de parâmetro
    Local cSerieIni := Alltrim(mv_par01)
    Local cSerieFim := Alltrim(mv_par02)
    Local cNotaIni  := Alltrim(mv_par03)
    Local cNotaFim  := Alltrim(mv_par04)
    Local cEmiIni   := DTOS(mv_par05)
    Local cEmiFin   := DTOS(mv_par06)
    Local cCliLojaI := Alltrim(mv_par07)
    Local cCliLojaF := Alltrim(mv_par08)
    Local cBanco    := Alltrim(cValToChar(mv_par09))
    Local cAgencia  := Alltrim(cValToChar(mv_par10))
    Local cConta    := Alltrim(cValToChar(mv_par11))
    Local cPasta    := ""

    //Variáveis auxiliares
    Local cSerie2   := ""
    Local cIdEnt    := ""
    Local cEmailCli := ""
    Local cQuery    := ""
    Local nFilial   := xFilial("SF3")     
    
    
    
    cFile := cGetFile('Arquivo *|*.*|Arquivo TXT|*.txt','Retorna Diretorio',0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.F.)
    If !Empty(cFile)
        cPasta := cFile

        cIdEnt := GetIdEnt()
        If !Empty(cIdEnt)
            cQuery +=  " SELECT "
            cQuery +=  " F3_SERIE AS SERIE, "
            cQuery +=  " F3_NFISCAL AS NOTA, "
            cQuery +=  " F3_EMISSAO AS EMISSAO "
            cQuery +=  " FROM "+RetSqlName("SF3")+"  SF3 "
            cQuery +=  " WHERE SF3.D_E_L_E_T_ <> '*' "
            cQuery +=  "   AND F3_FILIAL       = '"+nFilial+"' "
            cQuery +=  "   AND F3_EMISSAO     >= '"+cEmiIni+"' "
            cQuery +=  "   AND F3_EMISSAO     <= '"+cEmiFin+"' "
            cQuery +=  "   AND F3_SERIE       >= '"+cSerieIni+"' "
            cQuery +=  "   AND F3_SERIE       <= '"+cSerieFim+"' "
            cQuery +=  "   AND F3_NFISCAL     >= '"+cNotaIni+"' "
            cQuery +=  "   AND F3_NFISCAL     <= '"+cNotaFim+"' "
            cQuery +=  "   AND ((F3_CFO       >= '5000') "
		    cQuery +=  "    OR (F3_CFO         < '5000' AND F3_FORMUL = 'S')) " 
            cQuery +=  " ORDER BY "
            cQuery +=  " F3_EMISSAO,F3_NFISCAL"
            
            Tcquery cQuery New Alias "DADOS"
    
            dbSelectArea("DADOS")
            dbGoTop()   
            While !DADOS->(Eof())
                cSerie2 :=  cValToChar(DADOS->SERIE)
                cNota   :=  cValToChar(DADOS->NOTA)
                dData   :=  Stod(DADOS->EMISSAO)
                cCNPJ   :=  ""
                
                DADOS->(Dbskip())
               
                DelClassIntF() //comando que limpa a memoria
                Processa({|lEnd| SpedPExp(cIdEnt,cSerie2,cNota,cNota,cPasta,lEnd,STod("20110101"),STod("21001231"),cCNPJ,cCNPJ)},"Processando","Aguarde, exportando arquivos",.F.)
                       
            Enddo
            dbCloseArea("DADOS")  
        Else
            Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{""},3)   //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
        EndIf
    Else
        Msginfo("Diretório não selecionado!")    
    Endif
    
    Msginfo("Processo Finalizado!")    
         
Return

Static Function SpedPExp(cIdEnt,cSerie,cNotaIni,cNotaFim,cPasta,lEnd,dDataDe,dDataAte,cCnpjDIni,cCnpjDFim)

    Local aDeleta  := {}
    Local nHandle  := 0
    Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cChvNFe  := ""
    Local cDestino := ""
    Local cDrive   := ""
    Local cModelo  := ""
    Local cPrefixo := ""
    Local cCNPJDEST := Space(14)                
    Local cNFes     := ""
    Local cIdflush  := cSerie+cNotaIni
    Local cXmlInut  := ""
    Local cAnoInut  := ""
    Local cAnoInut1 := ""
    Local nX        := 0
    Local oWS
    Local oRetorno
    Local oXML
    Local lOk      := .F.
    Local lFlush   := .T.
    Local lFinal   := .F.
    
    ProcRegua(Val(cNotaFim)-Val(cNotaIni))
    
    cDestino := cPasta

    Do While lFlush
            oWS:= WSNFeSBRA():New()
            oWS:cUSERTOKEN        := "TOTVS"
            oWS:cID_ENT           := cIdEnt 
            oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
            oWS:cIdInicial        := cIdflush // cNotaIni
            oWS:cIdFinal          := cSerie+cNotaFim
            oWS:dDataDe           := dDataDe
            oWS:dDataAte          := dDataAte
            oWS:cCNPJDESTInicial  := cCnpjDIni
            oWS:cCNPJDESTFinal    := cCnpjDFim
            oWS:nDiasparaExclusao := 0
            lOk := oWS:RETORNAFX()
            oRetorno := oWS:oWsRetornaFxResult
        
            If lOk
                ProcRegua(Len(oRetorno:OWSNOTAS:OWSNFES3))
        
                For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)
                    oXml := oRetorno:OWSNOTAS:OWSNFES3[nX]
                    oXmlExp   := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
                    If Type("oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ")<>"U" 
                        cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
                    ElseIF Type("oXmlExp:_NFE:_INFNFE:_DEST:_CPF")<>"U"
                        cCNPJDEST := AllTrim(oXmlExp:_NFE:_INFNFE:_DEST:_CPF:TEXT)              
                    Else
                        cCNPJDEST := ""
                    EndIf   
    
                    If !Empty(oXml:oWSNFe:cProtocolo)
                        cNotaIni := oXml:cID            
                        cIdflush := cNotaIni
                        cNFes := cNFes+cNotaIni+CRLF
                        cChvNFe  := NfeIdSPED(oXml:oWSNFe:cXML,"Id") //SpedNfeId(oXml:oWSNFe:cXML,"Id")                
                        cModelo := cChvNFe
                        cModelo := StrTran(cModelo,"NFe","")
                        cModelo := StrTran(cModelo,"CTe","")
                        cModelo := SubStr(cModelo,21,02)
                        
                        Do Case
                            Case cModelo == "57"
                                cPrefixo := "CTe"
                            OtherWise
                                cPrefixo := "NFe"
                        EndCase                 
                        
                        nHandle := FCreate(cDestino+SubStr(cChvNFe,4,44)+"-"+cPrefixo+".xml")
                        If nHandle > 0
                            //cCab1 := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.portalfiscal.inf.br/nfe procNFe_v1.00.xsd" versao="2.0">'
                            //cCab1 := 'xmlns="http://www.portalfiscal.inf.br/nfe" versao="2.00">'
							   //cCab1 := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="2.00">'                            
                           cCab1 := '<?xml version="1.0" encoding="UTF-8"?><nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="3.10">'
                            
                            cRodap:= '</nfeProc>'
                            FWrite(nHandle,AllTrim(cCab1))                          
                            FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
                            FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
                            FWrite(nHandle,AllTrim(cRodap))                         
                            FClose(nHandle)
                            aadd(aDeleta,oXml:cID)
                        EndIf                   
                    EndIf
                    
                    If oXml:OWSNFECANCELADA<>Nil .And. !Empty(oXml:oWSNFeCancelada:cProtocolo)
                        cChvNFe  := NfeIdSPED(oXml:oWSNFeCancelada:cXML,"Id") //SpedNfeId(oXml:oWSNFeCancelada:cXML,"Id")
                        cNotaIni := oXml:cID            
                        cIdflush := cNotaIni
                        cNFes := cNFes+cNotaIni+CRLF
                        If !"INUT"$oXml:oWSNFeCancelada:cXML
                            nHandle := FCreate(cDestino+SubStr(cChvNFe,3,44)+"-ped-can.xml")
                            If nHandle > 0
                                FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
                                FClose(nHandle)
                                aadd(aDeleta,oXml:cID)
                            EndIf
                            nHandle := FCreate(cDestino+"\"+SubStr(cChvNFe,3,44)+"-can.xml")
                            If nHandle > 0
                                FWrite(nHandle,oXml:oWSNFeCancelada:cXMLPROT)
                                FClose(nHandle)
                            EndIf
                        Else 
                            
    //                      If Type("oXml:OWSNFECANCELADA:CXML")<>"U"
                                cXmlInut  := oXml:OWSNFECANCELADA:CXML
                                cAnoInut1 := At("<ano>",cXmlInut)+5
                                cAnoInut  := SubStr(cXmlInut,cAnoInut1,2)
    //                      EndIf
                            nHandle := FCreate(cDestino+SubStr(cChvNFe,3,2)+cAnoInut+SubStr(cChvNFe,5,38)+"-ped-inu.xml")
                            If nHandle > 0
                                FWrite(nHandle,oXml:oWSNFeCancelada:cXML)
                                FClose(nHandle)
                                aadd(aDeleta,oXml:cID)
                            EndIf
                            nHandle := FCreate(cDestino+"\"+cAnoInut+SubStr(cChvNFe,5,38)+"-inu.xml")
                            If nHandle > 0
                                FWrite(nHandle,oXml:oWSNFeCancelada:cXMLPROT)
                                FClose(nHandle)
                            EndIf           
                        EndIf
                    EndIf
                    IncProc()
                Next nX
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Exclui as notas                                                        ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                If !Empty(aDeleta) .And. GetNewPar("MV_SPEDEXP",0)<>0
                    oWS:= WSNFeSBRA():New()
                    oWS:cUSERTOKEN        := "TOTVS"
                    oWS:cID_ENT           := cIdEnt
                    oWS:nDIASPARAEXCLUSAO := GetNewPar("MV_SPEDEXP",0)
                    oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"       
                    oWS:oWSNFEID          := NFESBRA_NFES2():New()
                    oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
                    For nX := 1 To Len(aDeleta)     
                        aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
                        Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aDeleta[nX]
                    Next nX
                    If !oWS:RETORNANOTAS()
                        Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{""},3)
                        lFlush := .F.   
                    EndIf
                EndIf
                aDeleta  := {}
                If Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .And. Empty(cNfes)
                    //Aviso("SPED","Não há dados",{"Ok"})    // "Não há dados"
                    lFlush := .F.   
                EndIf
            Else
                Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+"Erro",{"OK"},3)
                lFinal := .T.
            EndIf
    
            cIdflush := AllTrim(Substr(cIdflush,1,3) + StrZero((Val( Substr(cIdflush,4,Len(AllTrim(mv_par03))))) + 1 ,Len(AllTrim(mv_par03))))
            If cIdflush <= AllTrim(cNotaIni) .Or. Len(oRetorno:OWSNOTAS:OWSNFES3) == 0 .Or. Empty(cNfes) .Or. ;
               cIdflush <= Substr(cNotaIni,1,3)+Replicate('0',Len(AllTrim(mv_par03))-Len(Substr(Rtrim(cNotaIni),4)))+Substr(Rtrim(cNotaIni),4)// Importou o range completo
                lFlush := .F.
               // If !Empty(cNfes)    
               //     If Aviso("SPED","Solicitação processada com sucesso.",{"Sim","Não"}) == 1 //"Solicitação processada com sucesso."
              //          Aviso(STR0126,STR0151+" "+Upper(cDestino)+CRLF+CRLF+cNFes,{"Ok"})
              //      EndIf
              //  EndIf
            EndIf
    EndDo
    
Return 

Static Function GetIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtem o codigo da entidade                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oWS := WsSPEDAdm():New()
    oWS:cUSERTOKEN := "TOTVS"
        
    oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")  
    oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
    oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
    oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM     
    oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
    oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
    oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
    oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
    oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
    oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
    oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
    oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
    oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
    oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
    oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
    oWS:oWSEMPRESA:cCEP_CP     := Nil
    oWS:oWSEMPRESA:cCP         := Nil
    oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
    oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
    oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
    oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
    oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
    oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
    oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
    oWS:oWSEMPRESA:cINDSITESP  := ""
    oWS:oWSEMPRESA:cID_MATRIZ  := ""
    oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
    oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
    If oWs:ADMEMPRESAS()
        cIdEnt  := oWs:cADMEMPRESASRESULT
    Else
        Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{""},3)
    EndIf
    
    RestArea(aArea)
Return(cIdEnt)

//----------------------|
// Valid Perg           | 
//----------------------|

Static Function ValidPerg(cPerg)
    _sAlias = ALIAS()
    aRegs := {}
    cPerg:= PADR(cPerg,10)
    
    DBSELECTAREA("SX1")
    DBSETORDER(1)
    
    AADD(aRegs,{cPerg,"01", "Série Inicial?"    ,"","","mv_ch01","C",03,00,00,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"02", "Série Final?"      ,"","","mv_ch02","C",03,00,00,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"03", "NF Inicial?"       ,"","","mv_ch03","C",09,00,00,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"04", "NF Final?"         ,"","","mv_ch04","C",09,00,00,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"05", "Emissão Inicial?"  ,"","","mv_ch05","D",08,00,00,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"06", "Emissão Final?"    ,"","","mv_ch06","D",08,00,00,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"07", "Cliente/Loja de?"  ,"","","mv_ch07","C",08,00,00,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"08", "Cliente/Loja até?" ,"","","mv_ch08","C",08,00,00,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"09", "Banco?"            ,"","","mv_ch09","C",03,00,00,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"10", "Agência?"          ,"","","mv_ch10","C",05,00,00,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"11", "Conta?"            ,"","","mv_ch11","C",10,00,00,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

    
    For i := 1 To LEN(aRegs)
        If !Dbseek(cPerg+aRegs[i,2])
            Reclock("SX1", .T.)
            For j := 1 To FCount()
                If j <= Len(aRegs[i])
                    Fieldput(j, aRegs[i,j])
                Endif
            Next
            Msunlock()
        Endif
    Next
    Dbselectarea(_sAlias)
Return

