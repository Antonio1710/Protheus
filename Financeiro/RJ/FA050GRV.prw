#Include "RWMAKE.CH"
#Include "TOPCONN.CH"

/*/{Protheus.doc} User Function FA050GRV
	O ponto de entrada FA050GRV sera utilizado apos a gravacao de todos os dados (na inclusão do título) e antes da sua contabilização.
	@type  Function
	@author user
	@since 05/07/2013
	@version 01
	@history Ticket 051833 -  FWNM		        - 27/09/2019 - LP'S 590/012
	@history Ticket 4220   -  William Costa	    - 16/11/2020 - Gravar o campo E2_LOGDTHR 
	@history Ticket 6541   -  Fernando Macieira	- 11/12/2020 - Projeto RM - Gravar dados bancários do título buscando do fornecedor
	@history Ticket 9247   -  Fernando Macieira	- 11/02/2021 - PA COM VENCIMENTO 07.02 (FINAL DE SEMANA) - ALTERAÇÃO AUTOMÁTICA PARA SEGUNDA-FEIRA (DIA ÚTIL)
	@history ticket 11556  -  Fernando Macieira - 27/04/2021 - Processo Trabalhista - Títulos
	@history ticket 11556  -  Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consistência ambiente)
/*/
USER FUNCTION FA050GRV()

	Local lRet       := .T.
	Local aArea      := GetArea() 
	Local cE2_ORIGEM := GetMV("MV_#RMORIP",,"FINI050") // @history Ticket 6541   -  Fernando Macieira	- 11/12/2020 - Projeto RM - Gravar dados bancários do título buscando do fornecedor
	Local aAreaSA2   := {}
	Local nDiasAdd   := 0 // @history Ticket 9247   -  Fernando Macieira	- 11/02/2021 - PA COM VENCIMENTO 07.02 (FINAL DE SEMANA) - ALTERAÇÃO AUTOMÁTICA PARA SEGUNDA-FEIRA (DIA ÚTIL)
    Local cForAcordo := GetMV("MV_#RC1FOR",,"001901")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	// @history Ticket 6541   -  Fernando Macieira	- 11/12/2020 - Projeto RM - Gravar dados bancários do título buscando do fornecedor
	If AllTrim(SE2->E2_ORIGEM) == AllTrim(cE2_ORIGEM)

		aAreaSA2   := SA2->( GetArea() )

		SA2->( dbSetOrder(1) ) // A2_FILIAL+A2_COD+A2_LOJA
		If SA2->( dbSeek(FWxFilial("SA2")+SE2->(E2_FORNECE+E2_LOJA)) )

			// Banco
			If AllTrim(SA2->A2_BANCO) <> AllTrim(SE2->E2_BANCO)
				RecLock("SE2", .F.)
					SE2->E2_BANCO := SA2->A2_BANCO
				SE2->( msUnLock() )
			EndIf

			// Agencia
			If AllTrim(SA2->A2_AGENCIA) <> AllTrim(SE2->E2_AGEN)
				RecLock("SE2", .F.)
					SE2->E2_AGEN := SA2->A2_AGENCIA
				SE2->( msUnLock() )
			EndIf

			// Dig Agencia
			If AllTrim(SA2->A2_DIGAG) <> AllTrim(SE2->E2_DIGAG)
				RecLock("SE2", .F.)
					SE2->E2_DIGAG := SA2->A2_DIGAG
				SE2->( msUnLock() )
			EndIf

			// Conta
			If AllTrim(SA2->A2_NUMCON) <> AllTrim(SE2->E2_NOCTA)
				RecLock("SE2", .F.)
					SE2->E2_NOCTA := SA2->A2_NUMCON
				SE2->( msUnLock() )
			EndIf

			// Dig Conta
			If AllTrim(SA2->A2_DIGCTA) <> AllTrim(SE2->E2_DIGCTA)
				RecLock("SE2", .F.)
					SE2->E2_DIGCTA := SA2->A2_DIGCTA
				SE2->( msUnLock() )
			EndIf

		EndIf

		RestArea( aAreaSA2 )

	EndIf
	//
	
	// REALIZADO O IF PELO WILLIAM COSTA PARA AJUSTE DE BAIXA DE TITULOS RJ PELO CNAB CHAMADO 022641
	IF cEmpAnt                  == "01"  .AND. ;
	   FWxFilial("SE5")         == '01'  .AND. ;
	   ALLTRIM(SE5->E5_PREFIXO) == "ADR" .AND. ;
	   ALLTRIM(SE5->E5_TIPO)    == "RJ"
	
		cQuery := " UPDATE " + RETSQLNAME("ZAF")              + " "
		cQuery += " SET ZAF_BAIXA  = '" + DTOS(SE2->E2_BAIXA) + "'," 
		cQuery += "     ZAF_LEGEND = 'B'  "     
		cQuery += " WHERE D_E_L_E_T_ <> '*' " 
		cQuery += "   AND ZAF_FILIAL  = '" + FWXFILIAL("ZAF") + "'" 
		cQuery += "   AND ZAF_NUMERO  = '" + SE2->E2_NUM      + "'"
		cQuery += "   AND ZAF_PARCEL  = '" + SE2->E2_PARCELA  + "'" 
		cQuery += "   AND ZAF_PREFIX  = 'ADR' "
		cQuery += "   AND ZAF_SALDO   > 0  "
		
		TCSQLEXEC(cQuery)
		TCSQLEXEC('commit')  

	ENDIF 
	
	// Chamado n. 051833 || OS 053189 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP'S 590/012 - FWNM - 27/09/2019
	IF ALLTRIM(M->E2_TIPO) == "PA"   .AND. ;
	   !IsInCallStack("U_ADFIN053P") .AND. ;
	   !IsInCallStack("U_ADFIN054P")

		cE2_CREDIT := Posicione("SA6",1,FWxFilial("SA6")+cBancoAdt+cAgenciaAdt+cNumCon,"A6_CONTA")

		RECLOCK("SE2", .F.)

			SE2->E2_CREDIT := cE2_CREDIT

		SE2->(MSUNLOCK())

	ENDIF

	IF FUNNAME() == 'FINA050' .OR. ;
	   FUNNAME() == 'FINA750'

		RECLOCK("SE2", .F.)

			SE2->E2_LOGDTHR	:= IIF(EMPTY(SE2->E2_LOGDTHR),DTOC(DATE()) + ' ' + TIME(),SE2->E2_LOGDTHR)

		SE2->(MSUNLOCK())

	ENDIF

	RESTAREA(aArea)

	// @history Ticket 9247   -  Fernando Macieira	- 11/02/2021 - PA COM VENCIMENTO 07.02 (FINAL DE SEMANA) - ALTERAÇÃO AUTOMÁTICA PARA SEGUNDA-FEIRA (DIA ÚTIL)
	nDiasAdd := DiaUtil()
	If nDiasAdd >= 1
		RecLock("SE2", .F.)
			SE2->E2_VENCREA := SE2->E2_VENCREA + nDiasAdd
		SE2->( msUnLock() )
	EndIf
	//

    // @history ticket 11556  -  Fernando Macieira - 27/04/2021 - Processo Trabalhista - Títulos
    If ( AllTrim(GetEnvServer()) <> "PCONTROLADORIA" ) .or. ( DtoS(msDate()) >= '20210501' ) // @history ticket 11556  -  Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consistência ambiente)
		
		If AllTrim(SE2->E2_ORIGEM) == "GPEM670" .and. AllTrim(SE2->E2_FORNECE) == cForAcordo
			
			RecLock("SE2", .F.)
				SE2->E2_XDIVERG := 'S'
			SE2->( msUnLock() )
			
			MsAguarde({|| GeraZC7rc1() },"Acordo Trabalhista","Enviando para Central Aprovação...")

		EndIf
		
	EndIf

RETURN(lRet)


/*/{Protheus.doc} Static Function DiasUteis
	Função que retorna a quantidade de dias que serão adicionados no vencimento real
	Dow = Retorna o número (entre 0 e 7) do dia da semana. Sendo, Domingo=1 e Sábado=7. No entanto, se o parâmetro dDtReal estiver vazio, a função retornará zero (0).
	@type  Static Function
	@author Fernando Macieira
	@since 11/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@ticket 9247 - PA COM VENCIMENTO 07.02 (FINAL DE SEMANA) - ALTERAÇÃO AUTOMÁTICA PARA SEGUNDA-FEIRA (DIA ÚTIL)
/*/
Static Function DiaUtil()
    
  	Local nDiasAdd   := 0
    Local dDtReal    := SE2->E2_VENCREA
    Local dDtValida  := DataValida(dDtReal) 

    Do While dDtReal < dDtValida
        nDiasAdd++
        dDtReal := DaySum(dDtReal, 1)
    EndDo

Return nDiasAdd

/*/{Protheus.doc} Static Function GeraZC7rc1()
    Gera Central Aprovação para títulos acordos trabalhistas
    @type  Static Function
    @author Fernando Macieira
    @since 27/04/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 11556 - Processo Trabalhista - Títulos
/*/
Static Function GeraZC7rc1()

	Local aAreaAtu  := GetArea()
    Local cQuery    := ""
	Local cCodSX5   := "Z9"
	Local cCodBlq   := GetMV("MV_#ZC7RC1",,"000013")
	Local cDscBlq   := AllTrim(Posicione("SX5",1,xFilial("SX5")+cCodSX5+cCodBlq,"X5_DESCRI"))
    Local cAssunto	:= "[ Acordos Trabalhistas ] - Central de Aprovação"
	Local cMensagem	:= ""
	Local cmaildest := SuperGetMv( "MV_#ADCOM1" , .F. , "sistemas@adoro.com.br" ,  )

	// gera registro para aprovacao		
	RecLock("ZC7",.T.)
	
    	ZC7->ZC7_FILIAL := FwxFilial("SE2")
		ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
		ZC7->ZC7_NUM   	:= SE2->E2_NUM
		ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
		ZC7->ZC7_TIPO   := SE2->E2_TIPO
		ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
		ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
		ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
		ZC7->ZC7_TPBLQ 	:= cCodBlq
		ZC7->ZC7_DSCBLQ	:= cDscBlq
		ZC7->ZC7_RECPAG := "P"
		//ZC7->ZC7_NIVSEG := '03'
		ZC7->ZC7_USRALT := __cUserID

	ZC7->( msUnLock() )

	// Envio de Pendencia Para o Aprovador não Ausente
	If Select("TMPZC3") > 0
		TMPZC3->( dbCloseArea() )
	EndIf

	cQuery := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV 
	cQuery += " FROM " + RetSqlName("ZC3") + " ZC3 (NOLOCK)
	cQuery += " INNER JOIN " + RetSqlName("ZCF") + " ZCF (NOLOCK) ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ''
	cQuery += " WHERE ZCF_CODIGO = '"+cCodBlq+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ''
	cQuery += " ORDER BY ZCF_NIVEL

	TcQuery cQuery New Alias "TMPZC3"

	If !Empty(TMPZC3->ZC3_CODUSU)
		cmaildest := AllTrim(UsrRetMail(TMPZC3->ZC3_CODUSU))
	EndIf

	cMensagem := u_WGFA050FIN( FwxFilial("SE2"), SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_VALOR, Alltrim(SX5->X5_DESCRI), 'F' )
  	
    If !Empty(cmaildest)
	  u_F050EnvWF( cAssunto, cMensagem, cmaildest, '' )
	Endif

	If Select("TMPZC3") > 0
		TMPZC3->( dbCloseArea() )
	EndIf

	RestArea( aAreaAtu ) 
	
Return
