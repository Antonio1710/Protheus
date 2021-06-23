#include "protheus.ch"
#include "topconn.ch"

#DEFINE  ENTER 		Chr(13)+Chr(10)

/*/{Protheus.doc} User Function ADCOM032P
    Rotina para corrigir os PC que ficam encerrados mesmo quando NF estornada/excluída
    @type  Function
    @author FWNM
    @since 18/11/2019
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @Chamado 052275 || OS 053616 || FISCAL || VERUSKA || 8394 || SALDO DE PEDIDO
/*/
User Function ADCOM032P()

    Local nArea    := 0
    Local bProcess := { |oSelf| RunProcess(oSelf) }
    Local cTitulo  := "ADCOM032P" + " - PC selecionado n. " + SC7->C7_NUM
	Local cDescri  := "Esta rotina faz o acerto dos PC encerrado mesmo quando a NF foi estornada/excluida." + ENTER + ENTER +;
    " (Filtro: C7_QTDACLA negativo). " + ENTER + ENTER
	
	Private oProcess, lAuto

    // Define lAuto
	nArea := Select()
	If nArea > 0
		lAuto := .f.
	Else
		lAuto := .t.
	EndIf
	
	// Inicializo ambiente
	If lAuto
		rpcClearEnv()
		rpcSetType(3)
		
		If !rpcSetEnv("01", "02",,,,,{"SM0"})
			ConOut( " ADCOM032P - Não foi possível inicializar o ambiente, empresa 01, filial 02" )
			Return
		EndIf
	EndIf

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para corrigir os PC que ficam encerrados mesmo quando NF estornada/excluída')

    	// Garanto uma única thread sendo executada
	If !LockByName("ADCOM032P", .T., .F.)
		If lAuto
			ConOut(" ADCOM032P - Existe outro processamento sendo executado! Verifique...")
			apMsgStop("Existe outro processamento sendo executado! Verifique...", "Atenção")
		Else
			Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		EndIf
		
		Return
	EndIf

    // Executa processamento
    If lAuto
		RunProcess(oProcess)
	Else
		oProcess := tNewProcess():New("ADCOM32",cTitulo,bProcess,cDescri,/*cPerg*/,, .T.,5, "RUNADCOM032P", .T.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
    UnLockByName("ADCOM032P")
    
    If lAuto
        conout("ADCOM032P - Processamento finalizado")
    Else
        msgInfo("ADCOM032P - Processamento finalizado!")
    EndIf

Return

/*/{Protheus.doc} Static Function RunProcess
    Rotina para corrigir os PC que ficam encerrados mesmo quando NF estornada/excluída
    @type  Function
    @author FWNM
    @since 18/11/2019
    @version 01
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 052275 || OS 053616 || FISCAL || VERUSKA || 8394 || SALDO DE PEDIDO
/*/
Static Function RunProcess(oProcess)

    Local nQuje    := 0
    Local nQtdacla := 0
    Local cQuery   := ""
    Local cEncer   := ""
    
    If lAuto
        ConOut( " Inicializando ambiente... " )
    Else
        oProcess:SetRegua1( 20 )
        oProcess:IncRegua1( " Processando... " )
        
        oProcess:SetRegua2( 20 )
        oProcess:IncRegua2( " Buscando PCs com problemas... " )
    EndIf
    
    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 (NOLOCK) "
    cQuery += " WHERE C7_QTDACLA < 0 "
    cQuery += " AND C7_RESIDUO<>'S' "
    cQuery += " AND C7_CONAPRO<>'R' "
    cQuery += " AND D_E_L_E_T_='' "

    If !lAuto
        cQuery += " AND C7_FILIAL='"+SC7->C7_FILIAL+"' "
        cQuery += " AND C7_NUM='"+SC7->C7_NUM+"' "
        //cQuery += " AND C7_ITEM='"+SC7->C7_ITEM+"' "
    EndIf

    tcquery cQuery New Alias "Work"

    Work->( dbGoTop() )

    Do While Work->( !EOF() )

        If lAuto
            ConOut("Filial " + Work->C7_FILIAL + " PC " + Work->C7_NUM + " ITEM " + Work->C7_ITEM)
        Else
            oProcess:IncRegua2("Filial " + Work->C7_FILIAL + " PC " + Work->C7_NUM + " ITEM " + Work->C7_ITEM)
        EndIf

        nQuje    := SumNFClass(Work->C7_FILIAL, Work->C7_NUM, Work->C7_ITEM)
        nQtdacla := SumPreNota(Work->C7_FILIAL, Work->C7_NUM, Work->C7_ITEM)

        SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
        If SC7->( dbSeek( Work->(C7_FILIAL+C7_NUM+C7_ITEM) ) )

            // Gravar ZBE - LOG
			u_GrLogZBE (msDate(),;
				TIME(),;
				cUserName,;
				"ACERTO PC ENCERRADO COM NF EST/EXC","COMPRAS","ADCOM032P",;
                "FIL/PC/IT: " + SC7->(C7_FILIAL+"/"+C7_NUM+"/"+C7_ITEM) + " USR: " +__cUserId +;
                    " ANTERIOR: C7_QTDACLA = " + AllTrim(Str(SC7->C7_QTDACLA))+;
                    " C7_QUJE = " + AllTrim(Str(SC7->C7_QUJE))+;
                    " C7_ENCER = " + AllTrim(SC7->C7_ENCER),;
				ComputerName(),;
				LogUserName())		
            //

            cEncer := Iif(nQuje >= SC7->C7_QUANT, "E", "")
            RecLock("SC7", .f.)
                SC7->C7_QTDACLA := nQtdacla
                SC7->C7_QUJE    := nQuje
                SC7->C7_ENCER   := cEncer
            SC7->( msUnLock() )
        EndIf

        Work->( dbSkip() )
    EndDo

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} Static Function SumNFClass
    Soma quantidade das Notas Fiscais classificadas 
    @type  Static Function
    @author FWNM
    @since 18/11/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @Chamado n. 052275 || OS 053616 || FISCAL || VERUSKA || 8394 || SALDO DE PEDIDO
/*/
Static Function SumNFClass(cC7_FILIAL, cC7_NUM, cC7_ITEM)

    Local nQtd := 0
    Local cQuery := ""

    If Select("WorkNF") > 0
        WorkNF->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ISNULL(SUM(D1_QUANT),0) TT "
    cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
    cQuery += " WHERE D1_FILIAL='"+cC7_FILIAL+"' "
    cQuery += " AND D1_PEDIDO='"+cC7_NUM+"' "
    cQuery += " AND D1_ITEMPC='"+cC7_ITEM+"' "
    cQuery += " AND D1_TES<>'' "
    cQuery += " AND D_E_L_E_T_='' "

    tcquery cQuery New Alias "WorkNF"

    aTamSX3 := TamSX3("D1_QUANT")
    tcSetField("WorkNF", "TT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    WorkNF->( dbGoTop() )
    If WorkNF->( !EOF() )
        nQtd := WorkNF->TT
    EndIf

    If Select("WorkNF") > 0
        WorkNF->( dbCloseArea() )
    EndIf

Return nQtd

/*/{Protheus.doc} Static Function SumPreNota
    Soma quantidade das Notas Fiscais pendentes de classificacao (PRE-NOTAS) 
    @type  Static Function
    @author FWNM
    @since 18/11/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @Chamado n. 052275 || OS 053616 || FISCAL || VERUSKA || 8394 || SALDO DE PEDIDO
/*/
Static Function SumPreNota(cC7_FILIAL, cC7_NUM, cC7_ITEM)

    Local nQtd := 0
    Local cQuery := ""

    If Select("WorkNF") > 0
        WorkNF->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ISNULL(SUM(D1_QUANT),0) TT "
    cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK) "
    cQuery += " WHERE D1_FILIAL='"+cC7_FILIAL+"' "
    cQuery += " AND D1_PEDIDO='"+cC7_NUM+"' "
    cQuery += " AND D1_ITEMPC='"+cC7_ITEM+"' "
    cQuery += " AND D1_TES='' "
    cQuery += " AND D_E_L_E_T_='' "

    tcquery cQuery New Alias "WorkNF"

    aTamSX3 := TamSX3("D1_QUANT")
    tcSetField("WorkNF", "TT", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    WorkNF->( dbGoTop() )
    If WorkNF->( !EOF() )
        nQtd := WorkNF->TT
    EndIf

    If Select("WorkNF") > 0
        WorkNF->( dbCloseArea() )
    EndIf

Return nQtd