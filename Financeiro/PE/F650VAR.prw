#INCLUDE "PROTHEUS.CH"        
#include "topconn.ch"
#INCLUDE "APWEBEX.CH"

/*/{Protheus.doc} User Function F650VAR
	Ponto Entrada Retorno Cobrança
	@type  Function
	@author ?
	@since ?
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 056247 - FWNM - 19/05/2020 - OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
/*/
User Function F650VAR()

	Local cQuery := {}
	Local _area  := GetArea() 

    // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 19/05/2020
	Local lAchouTit  := .f.
    Local aPARAMIXB  := PARAMIXB[1]
    Local cKey1SE1WS := Subs(AllTrim(PARAMIXB[1,14]),71,11)
    Local cKey2SE1WS := Subs(AllTrim(PARAMIXB[1,14]),135,11)
    Local cKey3SE1WS := Subs(AllTrim(PARAMIXB[1,14]),117,10) // E1_IDCNAB // @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    Local cQuery     := ""
    Local lBradWS    := AllTrim(MV_PAR03) == "237"
    Local aAreaSE1   := SE1->( GetArea() )

    If lBradWS .and. mv_par07 == 1	// Receber

        // Chave 1
        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
        cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
        cQuery += " WHERE E1_NUMBCO='"+cKey1SE1WS+"'
        cQuery += " AND E1_NUMBCO<>''
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
        If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )
            
            lAchouTit := .t.
			
			cNossoNum := SE1->E1_NUMBCO
			ParamIXB[1,4] := cNossoNum
			
			cNumTit   := SE1->E1_IDCNAB
			ParamIXB[1,1] := cNumTit

        EndIf

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        If !lAchouTit

            // Chave 2
            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

            cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
            cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
            cQuery += " WHERE E1_NUMBCO='"+cKey2SE1WS+"'
            cQuery += " AND E1_NUMBCO<>''
            cQuery += " AND D_E_L_E_T_=''

            tcQuery cQuery New Alias "Work"

            SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )
                
                lAchouTit := .t.

                cNossoNum := SE1->E1_NUMBCO
			    ParamIXB[1,4] := cNossoNum
			
			    cNumTit   := SE1->E1_IDCNAB
			    ParamIXB[1,1] := cNumTit

            EndIf

            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

        EndIf

        // @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
        If !lAchouTit

            // Chave 3 - E1_IDCNAB
            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

            cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
            cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
            cQuery += " WHERE E1_IDCNAB='"+cKey3SE1WS+"'
            cQuery += " AND E1_IDCNAB<>''
            cQuery += " AND D_E_L_E_T_=''

            tcQuery cQuery New Alias "Work"

            SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )

                lAchouTit := .t.

                cNossoNum := SE1->E1_NUMBCO
                ParamIXB[1,4] := cNossoNum
                
                cNumTit   := SE1->E1_IDCNAB
                ParamIXB[1,1] := cNumTit

            EndIf

            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

        EndIf

        If !lAchouTit
            RestArea( aAreaSE1 )
        EndIf
    
    EndIf
	//

	// TRATA APENAS O BANCO DO BRASIL
	If MV_PAR07 == 2 .AND. substr(XBUFFER,1,3) == "001"

		cQuery	:= "SELECT * FROM "+ RetSqlName("SA2") 
		cQuery	+= " WHERE A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery	+= "   AND D_E_L_E_T_ <> '*' "  
		cQuery	+= "   AND SUBSTRING(A2_NOME,1,30) = '"+STRTRAN(SUBSTR(PARAMIXB[1,14],44,30),"'","''" )+"' "
	
		Open Query cQuery Alias "TRXA2"

		cQuery	:= "SELECT * FROM "+ RetSqlName("SE2") 
		cQuery	+= " WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cQuery	+= "   AND E2_NUM = '"+ALLTRIM(CNUMTIT)+"' "
	//	cQuery	+= "   AND E2_SALDO > 0 "
		cQuery	+= "   AND D_E_L_E_T_ <> '*' "  
		cQuery	+= "   AND E2_FORNECE = '"+TRXA2->A2_COD+"' "

		Open Query cQuery Alias "TRXE2"

		If !EMPTY(TRXE2->E2_IDCNAB)
			CNUMTIT        := TRXE2->E2_IDCNAB
			PARAMIXB[1][1]:= TRXE2->E2_IDCNAB
		Endif
	
	Endif

	Close Query "TRXE2"
	Close Query "TRXA2"
	RestArea(_Area)

Return
