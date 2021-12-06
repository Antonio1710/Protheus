#include "protheus.ch"
#include "topconn.ch"

#DEFINE  ENTER 		Chr(13)+Chr(10)

/*/{Protheus.doc} User Function CT270DLB
    Botão Rateio Off-Line
    @type  Function
    @author FWNM
    @since 12/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 055674 || OS 057082 || CONTROLADORIA || THIAGO || 8439 || RATEIO OFF - LINE
    @history ticket 5530  - Fernando Macieira - 25/11/2020 - Inclusão Regra de Rateio - Safeeg
    @history ticket 5566  - Fernando Macieira - 25/11/2020 - Bloqueio Rateio - RNX2
    @history ticket 9548  - Fernando Macieira - 16/02/2021 - Rotina Copia regra de rateio (Rateio off line) - Não está limpando a flag para importação no novo Sig
    @history ticket 64246 - Fernando Macieira - 03/12/2021 - coloquei asterisco nas rotinas para identificar que são customizadas
/*/
User Function CT270BUT()

    Local aCT270BUT := {}

    aAdd(aCT270BUT,{"* Copia regra rateio" , "U_RunCT270DLB()"   , 0, 6, 0, NIL})
    aAdd(aCT270BUT,{"* Importa regras XLS" , "U_ADCON018P('I')"  , 0, 7, 0, NIL}) // @history ticket 5530 - Fernando Macieira - 25/11/2020 - Inclusão Regra de Rateio - Safeeg
    aAdd(aCT270BUT,{"* Bloqueia regras XLS", "U_ADCON018P('E')"  , 0, 8, 0, NIL}) // @history ticket 5566 - Fernando Macieira - 25/11/2020 - Bloqueio Rateio - RNX2

Return aCT270BUT

/*/{Protheus.doc} User Function RunCT270DLB
    Efetua copia CTQ de acordo com filtros do usuário
    @type  Function
    @author FWNM
    @since 12/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 055674 || OS 057082 || CONTROLADORIA || THIAGO || 8439 || RATEIO OFF - LINE
/*/
User Function RunCT270DLB()

	Local bProcess := { |oSelf| RunDePara(oSelf) }
	Local cDescri  := "Esta rotina copiará as regras contábeis de rateio off-line. " + ENTER + ENTER +;
	" Exemplo da sequência que será utilizada: Pintinho 01XXXX, RAÇÃO: 02XXXX etc." + ENTER + ENTER +;
	" Campo de filtro (De): CTQ_CCORI" + ENTER + ENTER +;
    " Campos que serão alterados (Para): CTQ_CCORI + CTQ_CCPAR" + ENTER + ENTER
	
    Local cTitulo  := "Copia regra contábil off-line"

	Private oProcess
	Private cPerg   := "RunCT270DLB"
    Private nTotReg := 0
    Private cFirst := cLast := ""
      
    // Garanto uma única thread sendo executada
	If !LockByName("RUNCT270DLB", .T., .F.)
		Aviso("Atenção", "Existe outro processamento sendo executado! Verifique...", {"OK"}, 3)
		Return
	EndIf

	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	MontaPerg()

	oProcess := tNewProcess():New("CT270DL",cTitulo,bProcess,cDescri,cPerg,, .T.,5, "RUNCT270DLB", .T. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("RUNCT270DLB")

    Aviso("Fim", "Cópias realizadas com sucesso!" + ENTER + ENTER + "Total de registros copiados: " + AllTrim(Str(nTotReg)) + ENTER + "Primeira regra incluída: " + cFirst + ENTER + "Última regra incluída: " + cLast, {"OK"}, 3)

Return

/*/{Protheus.doc} Static Function RunDePara
    Efetua cópia de/para
    @type  Static Function
    @author user
    @since 12/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function RunDePara(oProcess)

    Local cQuery := ""

    oProcess:SetRegua1( 20 )
    oProcess:IncRegua1( " Inicializando ambiente... " )
			
	oProcess:SetRegua2( 20 )
	oProcess:IncRegua2( " Inicializando ambiente... " )

    // Consisto CTT informados
    CTT->( dbSetOrder(1) ) // CTT_FILIAL+CTT_CUSTO                                                                                                                                            

    If CTT->( !dbSeek(FWxFilial("CTT")+MV_PAR01))
        msgAlert("Centro de custo " + MV_PAR01 + " não cadastrado!")
        Return
    EndIf

    If CTT->( !dbSeek(FWxFilial("CTT")+MV_PAR02))
        msgAlert("CentroTHIAG de custo " + MV_PAR02 + " não cadastrado!")
        Return
    EndIf

    If !msgYesNo("Confirma o processamento com os parâmetros informados foram: (de) " + MV_PAR01 + " (para) " + MV_PAR02 + " ?")
        Return
    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT * 
    cQuery += " FROM " + RetSqlName("CTQ") + " (NOLOCK)
    cQuery += " WHERE CTQ_FILIAL='"+FWxFilial("CTQ")+"'
    cQuery += " AND CTQ_CCORI='"+MV_PAR01+"'
    cQuery += " AND D_E_L_E_T_=''
    cQuery += " ORDER BY CTQ_RATEIO "

    tcQuery cQuery New Alias "Work"

    // Compatibilizo campos numericos e data
	Work->( dbGoTop() )
	aEval( CTQ->( dbStruct() ) ,{ |x| If( x[2] != "C" , tcSetField( "Work" , AllTrim( x[1] ), x[2] , x[3] , x[4] ) , Nil ) } )

    Begin Transaction

	Work->( dbGoTop() )
    Do While Work->( !EOF() )

		nTotReg++
        
        oProcess:IncRegua1("Criando novos registros...")
		oProcess:IncRegua2("Rateio " + Work->CTQ_RATEIO + " - " + Work->CTQ_DESC)

        RecLock("CTQ", .T.)
						
            For nIndx := 1 to Work->( FCount() )
							
				If CTQ->( FieldPos( Work->( FieldName( nIndx ) ) ) ) > 0
								
					cNomCpo := Work->( FieldName( nIndx ) )
					cVlrCpo := Work->( FieldGet( FieldPos( cNomCpo ) ) )

                    // Pego código sequencial
                    If AllTrim(cNomCpo) == "CTQ_RATEIO"
                        cVlrCpo := NextCod(cVlrCpo)
                    EndIf 

					// Pego o conteúdo do PARA informado pelo usuário
                    If AllTrim(cNomCpo) == "CTQ_CCORI" .or. AllTrim(cNomCpo) == "CTQ_CCPAR"
						cVlrCpo := MV_PAR02
					EndIf

					CTQ->( FieldPut( FieldPos( cNomCpo ), cVlrCpo ) )
								
				EndIf
							
			Next nIndx

            // @history ticket 9548 - Fernando Macieira - 16/02/2021 - Rotina Copia regra de rateio (Rateio off line) - Não está limpando a flag para importação no novo Sig
            CTQ->CTQ_MSEXP := ""
            //
						
		CTQ->( msUnLock() )

        If nTotReg == 1
            cFirst := CTQ->CTQ_RATEIO
        EndIf

        Work->( dbSkip() )

    EndDo

    cLast := CTQ->CTQ_RATEIO

    End Transaction

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} Static Function MontaPerg
    Monta Grupo Perguntas
    @type  Static Function
    @author user
    @since 12/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MontaPerg()

	Private bValid := Nil
	Private cF3	   := "CTT"
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','CCusto de           ?','','','mv_ch01','C',TamSX3("CTT_CUSTO")[1],0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','CCusto para         ?','','','mv_ch02','C',TamSX3("CTT_CUSTO")[1],0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	
	Pergunte(cPerg,.F.)

Return

/*/{Protheus.doc} Static Function NextCod
    Busco próximo código
    @type  Static Function
    @author FWNM
    @since 12/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function NextCod(cVlrCpo)

    Local cNextCod := ""
    Local cQuery   := ""
    Local cPrefix  := Left(AllTrim(cVlrCpo),2)
    Local cSufix   := ""

    If Select("WorkCTQ") > 0
        WorkCTQ->( dbCloseArea() )
    EndIf

    cQuery := " SELECT MAX(CTQ_RATEIO) AS NEXT_COD
    cQuery += " FROM " + RetSqlName("CTQ") + " (NOLOCK)
    cQuery += " WHERE CTQ_FILIAL='"+FWxFilial("CTQ")+"'
    cQuery += " AND CTQ_RATEIO LIKE '"+cPrefix+"%'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkCTQ"

    cNextCod := Soma1(WorkCTQ->NEXT_COD)

    If Left(AllTrim(cNextCod),2) <> cPrefix
        cSufix := Right(WorkCTQ->NEXT_COD,4)
        cSufix := Soma1(cSufix)
        
        cNextCod := cPrefix + cSufix
    EndIf

    If Select("WorkCTQ") > 0
        WorkCTQ->( dbCloseArea() )
    EndIf

Return cNextCod
