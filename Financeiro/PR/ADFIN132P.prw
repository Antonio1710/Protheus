#include "protheus.ch"
#include "topconn.ch"
#Include "TbiConn.ch"
#Include "AP5MAIL.CH"      
#Include "Rwmake.ch" 

// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"
#INCLUDE "XMLXFUN.CH"

// BARRA DE SEPARAÇÃO DE DIRETÓRIOS
#Define BAR IIf(IsSrvUnix(), "/", "\")
#DEFINE ENTER Chr(13)+Chr(10)

// Variaveis estaticas
Static cRotina  := "ADFIN132P"
Static cTitulo  := "Acordos Trabalhistas"
Static lAuto    := .t.

/*/{Protheus.doc} User Function ADFIN132P
    Job acordos trabalhistas
    . despesas que estão pendentes de aprovação e seus respectivos vencimentos;
    . despesas que foram aprovadas mas não geraram suas respectivas parcelas;
    @type  Function
    @author Fernando Macieira
    @since 18/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 72346
/*/
User Function ADFIN132P()

    Local cEmpJob    := "01"
    Local cFilJob    := "02"
    Local cEmpRun    := ""
    Local cFilRun    := ""
    Local cQuery     := ""
    Local aEmpresas  := {}
	Local i
    Local cFilNum    := ""
    Local cPrefixo   := "GPE"
    Local cTipoPR    := "PR"
    Local cNaturez   := "22326"
    Local cFornece   := "001901"
    Local cLoja      := "01"
    Local cTipoNDI   := "NDI"
    Local lTipoPR    := .f.
    Local lTipoNDI   := .f.
    Local nVlrPR     := 0
    Local nTotNDI    := 0
    Local aCampos    := {}

	// Inicializo ambiente
	rpcClearEnv()
	rpcSetType(3)
		
	If !rpcSetEnv(cEmpJob, cFilJob,,,,,{"SM0"})
		ConOut( cRotina + " Não foi possível inicializar o ambiente, empresa " + cEmpJob + ", filial " + cFilJob )
		Return
	EndIf

	// Garanto uma única thread sendo executada
	/*
	If !LockByName(cRotina, .T., .F.)
		ConOut(cRotina + " - Existe outro processamento sendo executado! Verifique...")
		apMsgStop("Existe outro processamento sendo executado! Verifique...", "Atenção")
		Return
	EndIf
	*/
	PtInternal(1,ALLTRIM(PROCNAME()))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina job para acordos trabalhistas')

    cEmpRun := GetMV("MV_#RMJEMP",,"01")
    cFilRun := GetMV("MV_#RMJFIL",,"02|03")

	// Carrega Empresas para processamentos
	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbGoTop())
	Do While SM0->(!EOF())
		If (SM0->M0_CODIGO $ cEmpRun) .and. (SM0->M0_CODFIL $ cFilRun)
			aAdd(aEmpresas, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
		SM0->( dbSkip() )
	EndDo

    // Processa empresas
    For i:=1 to Len(aEmpresas)
	
    	RpcClearEnv()
		RpcSetType(3)
		RpcSetEnv( aEmpresas[ i,1 ] , aEmpresas[ i,2 ] )

        If Select("TRB") > 0
            TRB->( dbCloseArea() )
        EndIf
            
        // Crio TRB para impressão
        // https://tdn.totvs.com.br/display/framework/FWTemporaryTable
        oTempTable := FWTemporaryTable():New("TRB")
        
        // Arquivo TRB - CONSISTÊNCIAS
        aAdd( aCampos, {'TITULO'     ,"C"    ,TamSX3("E2_NUM")[1] , 0} )
        aAdd( aCampos, {'STATUS'     ,"C"    ,254, 0} )

        oTempTable:SetFields(aCampos)
        oTempTable:AddIndex("01", {"TITULO"} )
        oTempTable:Create()

        // Dados necessários para central aprovação
        cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
        cTipoPR   := GetMV("MV_#ZC7TIP",,"PR")
        cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
        cFornece  := GetMV("MV_#ZC7SA2",,"001901")
        cLoja     := GetMV("MV_#ZC7LOJ",,"01")
        cTipoNDI  := GetMV("MV_#ACOTIP",,"NDI")

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT R_E_C_N_O_ RECNO
        cQuery += " FROM " + RetSqlName("ZHB") + " ZHB (NOLOCK)
        cQuery += " WHERE ZHB_FILIAL='"+FWxFilial("ZHB")+"' 
        cQuery += " AND ZHB_NUM<>''
		cQuery += " AND ZHB.D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        Work->( dbGoTop() )
        Do While Work->( !EOF() )

            lTipoPR    := .f.
            lTipoNDI   := .f.
            nVlrPR     := 0
            nTotNDI    := 0

            ZHB->( dbGoTo(Work->RECNO) )
            
            cFilNum := ZHB->ZHB_FILNUM
            If Empty(cFilNum)
                cFilNum := FWxFilial("SE2")
            EndIf

            SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
            If SE2->( dbSeek(cFilNum+cPrefixo+ZHB->ZHB_NUM) )

                Do While SE2->( !EOF() ) .and. SE2->E2_FILIAL==cFilNum .and. SE2->E2_NUM==ZHB->ZHB_NUM

                    // pr
                    If AllTrim(SE2->E2_TIPO) == AllTrim(cTipoPR)
                        lTipoPR := .t.
                        nVlrPR  += SE2->E2_VALOR
                    EndIf

                    // ndi
                    If AllTrim(SE2->E2_TIPO) == AllTrim(cTipoNDI)
                        
                        lTipoNDI := .t.
                        nTotNDI  += SE2->E2_VALOR

                        If SE2->E2_VENCREA >= msDate() .and. Empty(SE2->E2_BAIXA)
                            GrvTRB(4) // Parcela aberta vencida
                        EndIf
                    
                    EndIf

                    SE2->( dbSkip() )

                EndDo

                // Grava TRB para enviar email
                If lTipoPR .and. !lTipoNDI
                    GrvTRB(1) // Possui PR mas não possui NDI (Parcelas não foram geradas)
                EndIf

                If !lTipoPR .and. !lTipoNDI
                    GrvTRB(2) // Não foi gerado PR nem NDI mas gerou numeração de título nas despesas 
                EndIf

                If lTipoPR .and. lTipoNDI
                    If nVlrPR <> nTotNDI
                        GrvTRB(3) // Total das parcelas não bate com o total que foi aprovado
                    EndIf
                EndIf

            EndIf

		    Work->( dbSkip() )

        EndDo

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

    Next i

	//UnLockByName(cRotina)

	//Fecha o ambiente.
	RpcClearEnv()
    
Return

/*/{Protheus.doc} Static Function GrvTRB
    Popula TRB para listagem
    @type  Static Function
    @author FWNM
    @since 23/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvTRB(nCodLog)

    Local cStatus := ""
    Local cNumTit := ZHB->ZHB_NUM

    Default nCodLog := 0

    If nCodLog == 1
        cStatus := "Parcelas não foram geradas"
    ElseIf nCodLog == 2
        cStatus := "Não foi gerado PR nem NDI desta despesa"
    EndIf

    RecLock("TRB", .T.)
        TRB->TITULO   := cNumTit
		TRB->STATUS   := cStatus
	TRB->( msUnLock() )
	
Return
