#Include 'protheus.ch'
#Include "RwMake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADFIN061P
	Consulta status de Aprovação do título - Central Aprovação
	@type  Function
	@author Ricardo Lima
	@since 12/07/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado ??????
	@history chamado 058216 - FWNM     - 15/05/2020 - OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
/*/
User Function ADFIN061P( E2FILIAL, E2FORNECE, E2LOJA, E2PREFIXO, E2NUM, E2PARCELA, E2TIPO ) 

	Local aArea	  := GetArea()
	Local cAliasZC7 := "TMP"
	Local cComprador:= ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""

	Local lBloq     := .F.

	Local nUsado	:= 0
	Local nX   		:= 0
	Local nY        := 0

	Local oDlg
	Local oGet
	Local oBold
				
	Local cQuery   := ""
	Local aStruZC7 := {}
	Local sUsrAlt  := ""

	Private aCols   := {}
	Private aHeader := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	dbSelectArea("ZC7")
	dbSetOrder( 2 ) // ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_TIPO
	If MsSeek( E2FILIAL + E2FORNECE + E2LOJA + E2PREFIXO + E2NUM + E2PARCELA + E2TIPO )

		cTitle    := OemToAnsi("Aprovacao do Titulo")
		cTitDoc   := OemToAnsi("Titulo")
		cNumDoc   := ZC7->ZC7_NUM
		cComprador:= UsrRetName(ZC7->ZC7_USRALT)
		cStatus   := IIF( !EMPTY(ZC7->ZC7_USRAPR) , OemToAnsi( "TITULO APROVADO" ), OemToAnsi( "AGUARDANDO APROVAÇÃO" ) )

	Endif

	If !Empty(cNumDoc)
		
		aHeader:= {}
		aCols  := {}

		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("ZC7")

		While !Eof() .And. (SX3->X3_ARQUIVO == "ZC7")

			IF AllTrim(X3_CAMPO)$"ZC7_NIVEL/ZC7_OBS/ZC7_DTAPR"
				nUsado++
				AADD(aHeader,{	TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
				
				If AllTrim(x3_campo) == "ZC7_NIVEL"
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Usuário" ),"bCR_NOME",   "",20,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Situação" ),"bCR_SITUACA","",20,0,"","","C","",""} )
					nUsado++
					AADD(aHeader,{ OemToAnsi( "Tp.Aprovação" ),"bCR_TPAPROV","",15,0,"","","C","",""} )
				EndIf
				
			Endif
			
			dbSelectArea("SX3")
			dbSkip()

		EndDo

		aStruZC7 := ZC7->(dbStruct())
		cAliasZC7 := GetNextAlias()
		cQuery := " SELECT * "
		cQuery += " FROM "+RetSqlName("ZC7")+" ZC7 "
		cQuery += " WHERE ZC7_FILIAL = '"+E2FILIAL+"' "
		cQuery += " AND ZC7_CLIFOR = '"+E2FORNECE+"' AND ZC7_LOJA = '"+E2LOJA+"' " 
		cQuery += " AND ZC7_PREFIX = '"+E2PREFIXO+"' AND ZC7_NUM = '"+E2NUM+"' AND ZC7_PARCEL = '"+E2PARCELA+"' AND ZC7_TIPO = '"+E2TIPO+"' "
		cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZC7)
					
		For nX := 1 To Len(aStruZC7)
			If aStruZC7[nX][2]<>"C"
				TcSetField(cAliasZC7,aStruZC7[nX][1],aStruZC7[nX][2],aStruZC7[nX][3],aStruZC7[nX][4])
			EndIf
		Next nX
		
		dbSelectArea(cAliasZC7)
		
		While (cAliasZC7)->(!Eof())
			
            sUsrAlt := UsrRetName((cAliasZC7)->ZC7_USRALT)
			aadd(aCols,Array(nUsado+1))
			nY++
			
            For nX := 1 to Len(aHeader)
			
            	If aHeader[nX][02] == "bCR_NOME"
			
            		IF !EMPTY((cAliasZC7)->ZC7_USRAPR)
						aCols[nY][nX] := UsrRetName((cAliasZC7)->ZC7_USRAPR)
					Else
						aCols[nY][nX] := POSAPR( (cAliasZC7)->ZC7_TPBLQ , (cAliasZC7)->ZC7_NIVEL )
					EndIf
			
            		IF EMPTY((cAliasZC7)->ZC7_USRAPR)
						lBloq := .T.					
					EndIF
			
            	ElseIf aHeader[nX][02] == "bCR_SITUACA"
			
            		Do Case
			
            			Case EMPTY((cAliasZC7)->ZC7_USRAPR)
							cSituaca := OemToAnsi("Aguardando")
						//Case !EMPTY((cAliasZC7)->ZC7_USRAPR)
                        Case !EMPTY((cAliasZC7)->ZC7_USRAPR) .and. EMPTY((cAliasZC7)->ZC7_REPROV) // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 15/05/2020
							cSituaca := OemToAnsi("Aprovado")
						Case !EMPTY((cAliasZC7)->ZC7_USRAPR) .and. !EMPTY((cAliasZC7)->ZC7_REPROV)
							cSituaca := OemToAnsi("Reprovado")
					EndCase
			
            		aCols[nY][nX] := cSituaca
			
            	ElseIf aHeader[nX][02] == "bCR_TPAPROV"
					aCols[nY][nX] := If( EMPTY((cAliasZC7)->ZC7_EFEAPR) , IIF(!EMPTY((cAliasZC7)->ZC7_USRAPR), "Vistador",""), "Aprovador" )
			
            	ElseIf Alltrim(aHeader[nX][02]) == "ZC7_NIVEL"
					aCols[nY][nX] := If( EMPTY((cAliasZC7)->ZC7_NIVEL) , "01", (cAliasZC7)->ZC7_NIVEL )
			
            	ElseIf ( aHeader[nX][10] != "V")
					aCols[nY][nX] := FieldGet(FieldPos(aHeader[nX][2]))
			
            	EndIf
			
            Next nX
			
            aCols[nY][nUsado+1] := .F.
			dbSelectArea(cAliasZC7)
			cStatus := IIF( EMPTY((cAliasZC7)->ZC7_USRAPR) , OemToAnsi("AGUARDANDO APROVAÇÃO") , IIF(!EMPTY((cAliasZC7)->ZC7_REPROV), OemToAnsi("REJEITADO"),OemToAnsi("APROVADO")) )
			dbSkip()
		
        EndDo
		
		If !Empty(aCols)
		
        	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
			DEFINE MSDIALOG oDlg TITLE cTitle From 109,095 To 400,600 OF oMainWnd PIXEL
			@ 005,003 TO 032,250 LABEL "" OF oDlg PIXEL
			@ 015,007 SAY cTitDoc OF oDlg FONT oBold PIXEL SIZE 046,009
			@ 014,041 MSGET cNumDoc PICTURE "" WHEN .F. PIXEL SIZE 050,009 OF oDlg FONT oBold
			If !Empty(sUsrAlt)
				@ 015,103 SAY OemToAnsi("Analista:") OF oDlg PIXEL SIZE 033,009 FONT oBold
				@ 014,138 MSGET sUsrAlt PICTURE "" WHEN .F. of oDlg PIXEL SIZE 103,009 FONT oBold
			EndIF
			@ 132,008 SAY 'Situacao :' OF oDlg PIXEL SIZE 052,009
			If lBloq
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HRED
			Else
				@ 132,038 SAY cStatus OF oDlg PIXEL SIZE 120,009 FONT oBold COLOR CLR_HBLUE
			EndIf
			IF cStatus = "AGUARDANDO APROVAÇÃO"
				@ 132,140 BUTTON 'Solicitar Aprovação' SIZE 065 ,010  FONT oDlg:oFont ACTION (SOLAPR(E2FILIAL , E2FORNECE, E2LOJA, E2PREFIXO, E2NUM, E2PARCELA, E2TIPO),oDlg:End()) OF oDlg PIXEL
			EndIf
			@ 132,210 BUTTON 'Fechar' SIZE 035 ,010  FONT oDlg:oFont ACTION (oDlg:End()) OF oDlg PIXEL
			oGet:= MSGetDados():New(038,003,120,250,2,,,"")
			oGet:Refresh()
			@ 126,002 TO 127,250 LABEL "" OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED
	
    	Else
			ApMsgInfo("Este Titulo nao possui controle de aprovacao.")
	
    	EndIf
	
    Else
		ApMsgInfo("Este Titulo nao possui controle de aprovacao.")
	
    EndIf

	RestArea(aArea)

Return(.T.)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Ricardo Lima
    @since 15/05/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function POSAPR( ZC7TPBLQ , ZC7NIVEL )

	Local cQuery := ""
	Local sRet   := ""
	Local aArea	  := GetArea()

	cQuery := " SELECT ZCF_CODIGO, ZCF_APROVA "
	cQuery += " FROM "+RetSqlName("ZCF")+" "
	cQuery += " WHERE ZCF_CODIGO = '"+ZC7TPBLQ+"' AND ZCF_NIVEL >= '"+ZC7NIVEL+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZCF_NIVEL "

	If Select("ADFINB61") > 0
    	ADFINB61->(DbCloseArea())		
    EndIf	

    TcQuery cQuery New Alias "ADFINB61"

	sRet := ADFINB61->ZCF_APROVA+"-"+UsrRetName(ADFINB61->ZCF_APROVA)

	RestArea(aArea)

Return(sRet)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Ricardo Lima
    @since 15/05/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function SOLAPR(E2FILIAL , E2FORNECE, E2LOJA, E2PREFIXO, E2NUM, E2PARCELA, E2TIPO)

	Local cQuery := ""
	Local cMensagem := ""

	cQuery := " SELECT ZC3_SUPAPR FROM "+RetSqlName("ZC3")+" "
	cQuery += " WHERE ZC3_CODUSU IN ( "
	cQuery += " SELECT TOP 1 ZC7_USRAPR "
	cQuery += " FROM "+RetSqlName("ZC7")+" ZC7 "
	cQuery += " WHERE ZC7_FILIAL = '"+E2FILIAL+"' "
	cQuery += " AND ZC7_CLIFOR = '"+E2FORNECE+"' AND ZC7_LOJA = '"+E2LOJA+"' "
	cQuery += " AND ZC7_PREFIX = '"+E2PREFIXO+"' AND ZC7_NUM = '"+E2NUM+"' AND ZC7_PARCEL = '"+E2PARCELA+"' AND ZC7_TIPO = '"+E2TIPO+"' "
	cQuery += " AND ZC7_USRAPR <> ' ' "
	cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZC7_NIVEL DESC) "
	
    If Select("ADFINB61") > 0
    	ADFINB61->(DbCloseArea())		
    EndIf	
    
    TcQuery cQuery New Alias "ADFINB61"

	cMensagem := u_ADFINW46(  E2PREFIXO , E2NUM , E2PARCELA , E2FORNECE , E2LOJA , 0.0 , '' , '999999' , .F. , 'A' , '' )
	
    u_F050EnvWF( 'Central de Aprovação - Solicitação de Aprovação' , cMensagem , UsrRetMail(ADFINB61->ZC3_SUPAPR) , '' )

Return(.T.)