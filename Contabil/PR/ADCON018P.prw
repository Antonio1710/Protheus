#include "protheus.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} User Function ADCON018P
    Gera regra de rateio off-line a partir de um excel
    @type  Function
    @author FWNM
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 5530 - Inclusão Regra de Rateio - Safeeg
    @history ticket 64246 - Fernando Macieira - 24/11/2021 - Correções rotina importação Rateio Off Line
/*/
User Function ADCON018P(cAcao)

    Local lOk		:= .F.
    Local alSay		:= {}
    Local alButton	:= {}
    Local clTitulo	:= 'Gera novas regras de rateio off-line a partir de um excel'
    Local clDesc1   := 'Leiaute: '
    Local clDesc2   := 'CTQ_FILIAL;CTQ_RATEIO;CTQ_DESC;CTQ_TIPO;CTQ_PERBAS;CTQ_CTORI;CTQ_CCORI;'
    Local clDesc3   := 'CTQ_ITORI;CTQ_CLORI;CTQ_CTPAR;CTQ_CCPAR;CTQ_ITPAR;CTQ_CLPAR;CTQ_SEQUEN;'
    Local clDesc4   := 'CTQ_CTCPAR;CTQ_CCCPAR;CTQ_ITCPAR;CTQ_CLCPAR;CTQ_PERCEN'
    Local clDesc5   := '( Necessário converter, previamente, esta planilha em arquivo CSV = Separado por ";" )'
	Local aCampos   := {}

    Default cAcao := ""

    Private oTempTable
    Private lAbortPrint := .F.

    Private cCTQ_RATEIO := ""
    Private cCTQ_DESC   := ""
    Private cCTQ_TIPO   := ""
    Private nCTQ_PERBAS := 0
    Private cCTQ_CTORI  := ""
    Private cCTQ_CCORI  := ""
    Private cCTQ_ITORI  := ""
    Private cCTQ_CLORI  := ""
    Private cCTQ_CTPAR  := ""
    Private cCTQ_CCPAR  := ""
    Private cCTQ_ITPAR  := ""
    Private cCTQ_CLPAR  := ""
    Private cCTQ_SEQUEN := ""
    Private cCTQ_CTCPAR := ""
    Private cCTQ_CCCPAR := ""
    Private cCTQ_ITCPAR := ""
    Private cCTQ_CLCPAR := ""
    Private nCTQ_PERCEN := 0

    If cAcao == "E"
        clTitulo	:= 'Bloqueia regras de rateio off-line a partir de um excel'
    EndIf

    // Mensagens de Tela Inicial
    AADD(alSay, clDesc1)
    AADD(alSay, clDesc2)
    AADD(alSay, clDesc3)
    AADD(alSay, clDesc4)
    AADD(alSay, clDesc5)

    // Botoes do Formatch
    AADD(alButton, {1, .T., {|| lOk := .T., FechaBatch()}})
    AADD(alButton, {2, .T., {|| lOk := .F., FechaBatch()}})

    FormBatch(clTitulo, alSay, alButton)

    If lOk

        If Select("TRB") > 0
            TRB->( dbCloseArea() )
        EndIf
		
        // Crio TRB para impressão
        // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
        oTempTable := FWTemporaryTable():New("TRB")
	
        // Arquivo TRB
        aAdd( aCampos, {'CTQ_RATEIO'     ,TamSX3("CTQ_RATEIO")[3] ,TamSX3("CTQ_RATEIO")[1], 0} )
        aAdd( aCampos, {'LOG'            ,"C" ,100, 0} )
        aAdd( aCampos, {'LINHA'          ,"C" ,250, 0} )

        oTempTable:SetFields(aCampos)
        oTempTable:AddIndex("01", {"CTQ_RATEIO"} )
        oTempTable:Create()

        Processa( {|| RunImpCTQ(cAcao) }, "Aguarde...", Iif(cAcao=="E", "Bloqueando regras de rateio off-line...","Gerando novas regras de rateio off-line..."),.T.)

        oTempTable:Delete()  

    EndIf

Return

/*/{Protheus.doc} Static Function RunImpCTQ
    (long_description)
    @type  Function
    @author user
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunImpCTQ(cAcao)

    Local lFile     := .f.
    Local cTxt      := ""
    Local nCount    := 0
    Local aDadCTQ   := {}
    Local lRet      := .t.

    cFile := cGetFile("Arquivos CSV (Separados por Vírgula) | *.CSV",;
    ("Selecione o diretorio onde encontra-se o arquivo a ser processado"), 0, "Servidor\", .t., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)// + GETF_RETDIRECTORY)

    If At(".CSV", upper(cFile)) > 0
        lFile := .t.
        ft_fUse(cFile)
    Else
        Aviso("ADCON018P-01", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")
    EndIf

    // Arquivo TXT
    If lFile
        
        ft_fGoTop()
        //ft_fSkip() // Pula primeira linha = ;SEQUENCIA RATEIO;DESCRIÇÃO RATEIO;TIPO (FIXO);PERCENTUAL BASE(FIXO);CONTA ORIGEM (MOVIMENTO MÊS);;;;CONTA REDUTORA (CRÉDITO);;;;;CONTA TRANSITÓRIA (DÉBITO);;;;;;;

        cVerTab := "CTQ_FILIAL;CTQ_RATEIO;CTQ_DESC;CTQ_TIPO;CTQ_PERBAS;CTQ_CTORI;CTQ_CCORI;CTQ_ITORI;CTQ_CLORI;CTQ_CTPAR;CTQ_CCPAR;CTQ_ITPAR;CTQ_CLPAR;CTQ_SEQUEN;CTQ_CTCPAR;CTQ_CCCPAR;CTQ_ITCPAR;CTQ_CLCPAR;CTQ_PERCEN"
        
        cTxt := AllTrim(ft_fReadLn())
        
        If cVerTab <> cTXT
            Aviso("ADCON018P-02", "A importação ou bloqueio não poderá ser realizada! Contate o Administrador do sistema...", {"&Ok"},, "Versão/Leiaute da planilha divergente!")
            Aviso("Ajustar para o leiaute: ", "CTQ_FILIAL;CTQ_RATEIO;CTQ_DESC;CTQ_TIPO;CTQ_PERBAS;CTQ_CTORI;CTQ_CCORI;CTQ_ITORI;CTQ_CLORI;CTQ_CTPAR;CTQ_CCPAR;CTQ_ITPAR;CTQ_CLPAR;CTQ_SEQUEN;CTQ_CTCPAR;CTQ_CCCPAR;CTQ_ITCPAR;CTQ_CLCPAR;CTQ_PERCEN")

        Else

            ProcRegua(0)
            ft_fSkip() // Pula linha do cabeçalho
            
            If cAcao == "I"

                // Processamento
                nCount := 0
                Do While !ft_fEOF() //.and. !lAbortPrint
                    
                    //IncProc( "Consistindo novas regras de rateio off-line... " + StrZero(nCount++, 9) )
                    MsAguarde({||  },"Consistindo arquivo txt","Linha: " + StrZero(nCount++, 9) )
                    
                    cTxt     := ft_fReadLn()
                    aDadCTQ  := Separa(cTxt, ";")

                    cCTQ_RATEIO := AllTrim(aDadCTQ[2])
                    cCTQ_DESC   := AllTrim(aDadCTQ[3])
                    cCTQ_TIPO   := AllTrim(aDadCTQ[4])
                    nCTQ_PERBAS := Val(StrTran(AllTrim(aDadCTQ[5]),",","."))
                    cCTQ_CTORI  := AllTrim(aDadCTQ[6])
                    cCTQ_CCORI  := AllTrim(aDadCTQ[7])
                    cCTQ_ITORI  := AllTrim(aDadCTQ[8])
                    cCTQ_CLORI  := AllTrim(aDadCTQ[9])
                    cCTQ_CTPAR  := AllTrim(aDadCTQ[10])
                    cCTQ_CCPAR  := AllTrim(aDadCTQ[11])
                    cCTQ_ITPAR  := AllTrim(aDadCTQ[12])
                    cCTQ_CLPAR  := AllTrim(aDadCTQ[13])
                    cCTQ_SEQUEN := AllTrim(aDadCTQ[14])
                    cCTQ_CTCPAR := AllTrim(aDadCTQ[15])
                    cCTQ_CCCPAR := AllTrim(aDadCTQ[16])
                    cCTQ_ITCPAR := AllTrim(aDadCTQ[17])
                    cCTQ_CLCPAR := AllTrim(aDadCTQ[18])
                    nCTQ_PERCEN := Val(StrTran(AllTrim(aDadCTQ[19]),",","."))

                    // Efetuo consistência CTQ
                    cLog := ""
                    CTQ->( dbSetOrder(1) ) // CTQ_FILIAL, CTQ_RATEIO, CTQ_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
                    If CTQ->( dbSeek(FWxFilial("CTQ")+PadR(cCTQ_RATEIO,TamSX3("CTQ_RATEIO")[1])+PadR(cCTQ_SEQUEN,TamSX3("CTQ_SEQUEN")[1])) )
                        cLog := "RATEIO+SEQUENCIA já existente " + cCTQ_RATEIO + "/" + cCTQ_SEQUEN
                        GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                    EndIf

                    cLog := ""
                    If Len(cCTQ_RATEIO) <> TamSX3("CTQ_RATEIO")[1]
                        cLog := "RATEIO precisa ser preenchido com zeros a esquerda ou ter tamanho de " + AllTrim(Str(Len(cCTQ_RATEIO)))
                        GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                    EndIf

                    cLog := ""
                    If Len(cCTQ_SEQUEN) <> TamSX3("CTQ_SEQUEN")[1]
                        cLog := "SEQUÊNCIA precisa ser preenchido com zeros a esquerda ou ter tamanho de " + AllTrim(Str(Len(cCTQ_SEQUEN)))
                        GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                    EndIf

                    // Efetuo consistência CT1
                    cLog := ""
                    CT1->( dbSetOrder(1) ) // CT1_FILIAL, CT1_CONTA, R_E_C_N_O_, D_E_L_E_T_
                    
                    cLog := ""
                    If !Empty(cCTQ_CTORI)
                        If CT1->( !dbSeek(FWxFilial("CT1")+PadR(cCTQ_CTORI,TamSX3("CT1_CONTA")[1])) )
                            cLog := " Conta não cadastrada " + cCTQ_CTORI
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_CTPAR)
                        If CT1->( !dbSeek(FWxFilial("CT1")+PadR(cCTQ_CTPAR,TamSX3("CT1_CONTA")[1])) )
                            cLog := " Conta não cadastrada " + cCTQ_CTPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_CTCPAR)
                        If CT1->( !dbSeek(FWxFilial("CT1")+PadR(cCTQ_CTCPAR,TamSX3("CT1_CONTA")[1])) )
                            cLog := " Conta não cadastrada " + cCTQ_CTCPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    // Efetuo consistência CTT
                    cLog := ""
                    CTT->( dbSetOrder(1) ) // CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
                    
                    cLog := ""
                    If !Empty(cCTQ_CCORI)
                        If CTT->( !dbSeek(FWxFilial("CTT")+PadR(cCTQ_CCORI,TamSX3("CTT_CUSTO")[1])) )
                            cLog := " CCusto não cadastrado " + cCTQ_CCORI
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_CCPAR)
                        If CTT->( !dbSeek(FWxFilial("CTT")+PadR(cCTQ_CCPAR,TamSX3("CTT_CUSTO")[1])) )
                            cLog := " CCusto não cadastrado " + cCTQ_CCPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_CCCPAR)
                        If CTT->( !dbSeek(FWxFilial("CTT")+PadR(cCTQ_CCCPAR,TamSX3("CTT_CUSTO")[1])) )
                            cLog := " CCusto não cadastrado " + cCTQ_CCCPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    // Efetuo consistência CTD
                    cLog := ""
                    CTD->( dbSetOrder(1) ) // CTD_FILIAL, CTD_ITEM, R_E_C_N_O_, D_E_L_E_T_
                    
                    cLog := ""
                    If !Empty(cCTQ_ITORI)
                        If CTD->( !dbSeek(FWxFilial("CTD")+PadR(cCTQ_ITORI,TamSX3("CTD_ITEM")[1])) )
                            cLog := " Item Contábil não cadastrado " + cCTQ_ITORI
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_ITPAR)
                        If CTD->( !dbSeek(FWxFilial("CTD")+PadR(cCTQ_ITPAR,TamSX3("CTD_ITEM")[1])) )
                            cLog := " Item Contábil não cadastrado " + cCTQ_ITPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_ITCPAR)
                        If CTD->( !dbSeek(FWxFilial("CTD")+PadR(cCTQ_ITCPAR,TamSX3("CTD_ITEM")[1])) )
                            cLog := " Item Contábil não cadastrado " + cCTQ_ITCPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    // Efetuo consistência CTH
                    cLog := ""
                    CTH->( dbSetOrder(1) ) // CTH_FILIAL, CTH_CLVL, R_E_C_N_O_, D_E_L_E_T_
                    
                    cLog := ""
                    If !Empty(cCTQ_CLORI)
                        If CTH->( !dbSeek(FWxFilial("CTH")+PadR(cCTQ_CLORI,TamSX3("CTH_CLVL")[1])) )
                            cLog := " Classe Valor não cadastrada " + cCTQ_CLORI
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_CLPAR)
                        If CTH->( !dbSeek(FWxFilial("CTH")+PadR(cCTQ_CLPAR,TamSX3("CTH_CLVL")[1])) )
                            cLog := " Classe Valor não cadastrada " + cCTQ_CLPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    cLog := ""
                    If !Empty(cCTQ_CLCPAR)
                        If CTH->( !dbSeek(FWxFilial("CTH")+PadR(cCTQ_CLCPAR,TamSX3("CTH_CLVL")[1])) )
                            cLog := " Classe Valor não cadastrada " + cCTQ_CLCPAR
                            GrvTRB(cCTQ_RATEIO, cLog, cTxt)
                        EndIf
                    EndIf

                    aDadCTQ := {}
                    
                    ft_fSkip()
                    
                EndDo

            EndIf
            
            // 
            TRB->( dbGoTop() )
            If TRB->( !EOF() )
                
                If msgYesNo("Nenhuma regra foi gerada, pois existem inconsistências! Deseja listá-las agora?")
                    ReportCTQ()
                EndIf
            
            Else
            
                ProcRegua(0)
                aDadCTQ := {}

                ft_fGoTop()
                //ft_fSkip() // Pula primeira linha = ;SEQUENCIA RATEIO;DESCRIÇÃO RATEIO;TIPO (FIXO);PERCENTUAL BASE(FIXO);CONTA ORIGEM (MOVIMENTO MÊS);;;;CONTA REDUTORA (CRÉDITO);;;;;CONTA TRANSITÓRIA (DÉBITO);;;;;;;
                ft_fSkip() // Pula linha do SEGUNDO cabeçalho
            
                // Processamento
                nCount := 0
                Begin Transaction

                    Do While !ft_fEOF() //.and. !lAbortPrint
                        
                        //IncProc( "Importando novas regras de rateio off-line... " + StrZero(nCount++, 9) )
                        MsAguarde({||  },"Processando arquivo txt","Linha: " + StrZero(nCount++, 9) )

                        cTxt     := ft_fReadLn()
                        aDadCTQ  := Separa(cTxt, ";")

                        cCTQ_RATEIO := AllTrim(aDadCTQ[2])
                        cCTQ_DESC   := AllTrim(aDadCTQ[3])
                        cCTQ_TIPO   := AllTrim(aDadCTQ[4])
                        nCTQ_PERBAS := Val(StrTran(AllTrim(aDadCTQ[5]),",","."))
                        cCTQ_CTORI  := AllTrim(aDadCTQ[6])
                        cCTQ_CCORI  := AllTrim(aDadCTQ[7])
                        cCTQ_ITORI  := AllTrim(aDadCTQ[8])
                        cCTQ_CLORI  := AllTrim(aDadCTQ[9])
                        cCTQ_CTPAR  := AllTrim(aDadCTQ[10])
                        cCTQ_CCPAR  := AllTrim(aDadCTQ[11])
                        cCTQ_ITPAR  := AllTrim(aDadCTQ[12])
                        cCTQ_CLPAR  := AllTrim(aDadCTQ[13])
                        cCTQ_SEQUEN := AllTrim(aDadCTQ[14])
                        cCTQ_CTCPAR := AllTrim(aDadCTQ[15])
                        cCTQ_CCCPAR := AllTrim(aDadCTQ[16])
                        cCTQ_ITCPAR := AllTrim(aDadCTQ[17])
                        cCTQ_CLCPAR := AllTrim(aDadCTQ[18])
                        nCTQ_PERCEN := Val(StrTran(AllTrim(aDadCTQ[19]),",","."))

                        // Gravo nova regra off-line
                        If !GrvCTQ(cAcao)
                            lRet := .f.
                            DisarmTransaction()
                            msUnLockAll()
                            BREAK
                            Exit
                        EndIf

                        aDadCTQ := {}
                    
                        ft_fSkip()
                    
                    EndDo

                End Transaction

                If lRet
                    If cAcao == "I"
                        msgInfo("Novas regras geradas com sucesso!")
                    ElseIf cAcao == "E"
                        msgInfo("Regras bloqueadas com sucesso!")
                    EndIf
                Else
                    Alert("Nenhuma regra foi gerada/bloqueada! Verifique...")
                EndIf
            
            EndIf
        
        EndIf
    
    EndIf

Return

/*/{Protheus.doc} Static Function GrvTRB(cCTQ_RATEIO, cLog, cTxt)
    (long_description)
    @type  Function
    @author user
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTRB(cCTQ_RATEIO, StaticLog, cTxt)

    RecLock("TRB", .T.)

        TRB->CTQ_RATEIO := cCTQ_RATEIO
        TRB->LOG        := cLog
        TRB->LINHA      := cTxt

    TRB->( msUnLock() )

Return

/*/{Protheus.doc} Static Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportCTQ()

    Private oReport     := Nil
    Private oCabCTQ     := Nil

    ReportDef()
    oReport:PrintDialog()

Return

/*/{Protheus.doc} Static Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ReportDef()

    Local cTitulo 	:= "Inconsistências Rateio Off-Line "

    oReport := TReport():New("ReportCTQ",cTitulo,"",{|oReport| PrintReport(oReport)},cTitulo)

    oReport:nFontBody := 9.5
    //oReport:lBold := .T.

    DEFINE SECTION oCabCTQ OF oReport TABLES "TRB"  TITLE cTitulo

    DEFINE CELL NAME "CTQ_RATEIO" OF oCabCTQ ALIAS "TRB" SIZE 20  TITLE "Rateio"     BLOCK {|| TRB->CTQ_RATEIO }
    DEFINE CELL NAME "LOG"        OF oCabCTQ ALIAS "TRB" SIZE 100 TITLE "Log"        BLOCK {|| TRB->LOG }
    DEFINE CELL NAME "LINHA"      OF oCabCTQ ALIAS "TRB" SIZE 250 TITLE "Linha TXT"  BLOCK {|| TRB->LINHA }

Return Nil

/*/{Protheus.doc} Static Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function PrintReport(oReport)

    Local cQuery := ""

    DbSelectArea("TRB")
    TRB->(dbGoTop())
    Do While TRB->( !EOF() )
	
        If oReport:Cancel()
            Exit
        EndIf
	
	    TRB->( dbSkip() )
	
        oReport:IncMeter()
        oCabCTQ:PrintLine()
	
    Enddo

    oCabCTQ:BeginQuery()
    //oCabCTQ:EndQuery({{"TRB"},cQuery})
    oCabCTQ:Print()

    TRB->( dbCloseArea() )

Return

/*/{Protheus.doc} Static Function GrvCTQ
    (long_description)
    @type  Function
    @author user
    @since 25/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvCTQ(cAcao)

    Local lRet := .t.
    Local cSql := ""
    Default cAcao := ""

    If cAcao == "I"

        RecLock("CTQ", .T.)

            CTQ->CTQ_FILIAL := FWxFilial("CTQ")
            CTQ->CTQ_RATEIO := cCTQ_RATEIO
            CTQ->CTQ_DESC   := cCTQ_DESC
            CTQ->CTQ_TIPO   := cCTQ_TIPO
            CTQ->CTQ_PERBAS := nCTQ_PERBAS
            CTQ->CTQ_CTORI  := cCTQ_CTORI
            CTQ->CTQ_CCORI  := cCTQ_CCORI
            CTQ->CTQ_ITORI  := cCTQ_ITORI
            CTQ->CTQ_CLORI  := cCTQ_CLORI
            CTQ->CTQ_CTPAR  := cCTQ_CTPAR
            CTQ->CTQ_CCPAR  := cCTQ_CCPAR
            CTQ->CTQ_ITPAR  := cCTQ_ITPAR
            CTQ->CTQ_CLPAR  := cCTQ_CLPAR
            CTQ->CTQ_SEQUEN := cCTQ_SEQUEN
            CTQ->CTQ_CTCPAR := cCTQ_CTCPAR
            CTQ->CTQ_CCCPAR := cCTQ_CCCPAR
            CTQ->CTQ_ITCPAR := cCTQ_ITCPAR
            CTQ->CTQ_CLCPAR := cCTQ_CLCPAR
            CTQ->CTQ_PERCEN := nCTQ_PERCEN
            CTQ->CTQ_STATUS := "1"

        CTQ->( msUnLock() )

    ElseIf cAcao == "E"

        CTQ->( dbSetOrder(1) ) // CTQ_FILIAL, CTQ_RATEIO, CTQ_SEQUEN, R_E_C_N_O_, D_E_L_E_T_
        If CTQ->( dbSeek(FWxFilial("CTQ")+PadR(cCTQ_RATEIO,TamSX3("CTQ_RATEIO")[1])+PadR(cCTQ_SEQUEN,TamSX3("CTQ_SEQUEN")[1])) )

            RecLock("CTQ", .F.)
                CTQ->CTQ_MSEXP  := ""
                CTQ->CTQ_MSBLQL := "1"
                CTQ->CTQ_STATUS := "3"
            CTQ->( msUnLock() )

        Else

            // @history ticket 64246 - Fernando Macieira - 24/11/2021 - Correções rotina importação Rateio Off Line
            cSql := " UPDATE " + RetSqlName("CTQ")
            cSql += " SET CTQ_MSEXP='', CTQ_MSBLQL='1', CTQ_STATUS='3'
            cSql += " WHERE CTQ_FILIAL='"+FWxFilial("CTQ")+"' 
            cSql += " AND CTQ_RATEIO='"+cCTQ_RATEIO+"' 
            cSql += " AND CTQ_SEQUEN='"+cCTQ_SEQUEN+"' 
            cSql += " AND D_E_L_E_T_=''

            If tcSqlExec(cSql) < 0
                lRet := .f.
                Alert("Bloqueio da regra/sequência " + cCTQ_RATEIO + "/" + cCTQ_SEQUEN + " não foi realizado! Envie o erro que será mostrado na próxima tela ao TI... A rotina será abortada e não será finalizada!")
                MessageBox(tcSqlError(),"",16)
            EndIf
        
        EndIf

    EndIf
    
Return lRet
