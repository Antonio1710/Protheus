#Include "Protheus.ch"
/*/{Protheus.doc} User Function ADFIS045R
    Job para envio de relatório de CT-es cancelados e escriturados.
    @type  Function
    @author Everson
    @since 10/11/2020
    @version 01
    @history Chamado 4672 - Everson - 13/11/2020 - Tratamento para envio de relatório de todas as empresas ativas.
    @history Chamado 4672 - Everson - 17/11/2020 - Tratamento para executar o relatório via job.
    @history Ticket 10892 - Abel B. - 12/03/2021 - Ajuste para execução por
    /*/
User Function ADFIS045R() // U_ADFIS045R()

    //Variáveis.

    //Inicia o ambiente. 
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

        //
        gerRel()

    //Fecha o ambiente.
	RpcClearEnv()

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rel. de CT-es cancelados e escriturados')
    //

Return Nil
/*/{Protheus.doc} gerRel
    (long_description)
    @type  Static Function
    @author Everson
    @since 10/11/2020
    @version 01
    /*/
Static Function gerRel()

    //Variáveis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local aEmp      := FWLoadSM0()
    Local cProc     := ""

    //Everson, 13/11/2020, Chamado 4672.
    For nAux = 1 To Len(aEmp)

        //Ticket 10892 - Abel B. - 12/03/2021 - Ajuste para execução por
        If aEmp[nAux][16] == "0" .And. ! aEmp[nAux][1]+aEmp[nAux][2] $cProc
            cProc += aEmp[nAux][1] + aEmp[nAux][2] + "/"
            startjob("U_ADFIS450",getenvserver(),.T.,aEmp[nAux][1],aEmp[nAux][2])
            // U_ADFIS450(aEmp[nAux][1],aEmp[nAux][2])
        EndIf

    Next nAux

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADFIS450
    Processa o envio dos relatórios.
    @type  Function
    @author user
    @since 13/11/2020
    @version 01
    /*/
User Function ADFIS450(cEmp,cFilLog)

    //Variáveis.
    Local cArq  := ""
    Local cEmail:= ""
    Local aNmLin:= {} 
    
    //Everson - 17/11/2020. Chamado 4672.
    Local cMsg  := ""
    Local nAux  := 1
    //

    //Everson, 13/11/2020, Chamado 4672.
    //Inicia o ambiente. 
	RPCSetType(3)
	RpcSetEnv(cEmp,cFilLog,,,,GetEnvServer(),{ })

        //
        cArq  := "/rel_fin/RCTE_CANC_" + DTos(Date()) + StrTran(Time(),":","") + ".XML"
        cEmail:= GetMv("MV_#CTECAN",,"rosangela@adoro.com.br")

        //
        aNmLin := StaticCall(ADFIS041R,UFIS041R, Date() -40, Date(), cArq)

        //Everson - 17/11/2020. Chamado 4672.
        If ValType(aNmLin) == "A" .And. Len(aNmLin) > 0

            //
            cMsg += "<html>"
            cMsg += "<head>"
            cMsg += "</head>"
            cMsg += "<body>"
            cMsg := "<p>Olá, segue arquivo anexo com os registros de CT-es cancelados e escriturados da empresa " + cEmpAnt + ".</p><br/>"
            cMsg += "<table border='1'>"
            cMsg += "<tr style='background-color: black;color:white'>"
            cMsg += "<td>Empresa</td>"
            cMsg += "<td>Filial</td>"
            cMsg += "<td>Dt. Emissao</td>"
            cMsg += "<td>Dt. Digit.</td>"
            cMsg += "<td>Série</td>"
            cMsg += "<td>Nota Fiscal</td>"
            cMsg += "<td>Codigo</td>"
            cMsg += "<td>Loja</td>"
            cMsg += "<td>Fornecedor</td>"
            cMsg += "<td>Valor Total</td>"
            cMsg += "<td>Chave XML</td>"
            cMsg += "</tr>"
            For nAux := 1 To Len(aNmLin)

                //
                cMsg += "<tr>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][1])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][2])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][3])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][4])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][5])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][6])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][7])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][8])  + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][9])  + "</td>"
                cMsg += "<td>" + Transform(aNmLin[nAux][10],"@E 999,999,999.99") + "</td>"
                cMsg += "<td>" + cValToChar(aNmLin[nAux][11]) + "</td>"
                cMsg += "</tr>"

            Next nAux
            cMsg += "</table>"
            cMsg += "</body>"
            cMsg += "</html>"

            //cEmail := "everson.silva@adoro.com.br"
            U_enviaremail(cEmail, "CT-es cancelados e escriturados - Empresa " + cEmpAnt + ".", cMsg, cArq)

        EndIf

        //
        FErase(cArq)

    //Fecha o ambiente.
	RpcClearEnv()

Return Nil
