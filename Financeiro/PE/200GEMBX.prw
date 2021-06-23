#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function 200GEMBX
    Tratar Valores dos Titulos

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ o array aValores ir  permitir ³
			//³ que qualquer exce‡„o ou neces-³
			//³ sidade seja tratado no ponto  ³
			//³ de entrada em PARAMIXB        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Estrutura de aValores
			//	Numero do T¡tulo	- 01
			//	data da Baixa		- 02
			// Tipo do T¡tulo		- 03
			// Nosso Numero			- 04
			// Valor da Despesa		- 05
			// Valor do Desconto	- 06
			// Valor do Abatiment	- 07
			// Valor Recebido    	- 08
			// Juros				- 09
			// Multa				- 10
			// Outras Despesas		- 11
			// Valor do Credito		- 12
			// Data Credito			- 13
			// Ocorrencia			- 14
			// Motivo da Baixa 		- 15
			// Linha Inteira		- 16
			// Data de Vencto	   	- 17

			aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValRec, nJuros, nMulta, nOutrDesp, nValCc, dDataCred, cOcorr, cMotBan, xBuffer,dDtVc,{} })

    @type  Function
    @author FWNM
    @since 19/05/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
/*/
User Function 200GEMBX()

    Local lAchouTit  := .f.
    Local aPARAMIXB  := PARAMIXB[1]
    Local cKey1SE1WS := Subs(AllTrim(PARAMIXB[1,16]),71,11)  // E1_NUMBCO
    Local cKey2SE1WS := Subs(AllTrim(PARAMIXB[1,16]),135,11) // E1_NUMBCO
    Local cKey3SE1WS := Subs(AllTrim(PARAMIXB[1,16]),117,10) // E1_IDCNAB // @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    Local cQuery     := ""
    Local lBradWS    := AllTrim(MV_PAR06) == "237"
    Local aAreaSE1   := SE1->( GetArea() )

    //@history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    Pergunte("AFI200", .F.)
    lBradWS    := AllTrim(MV_PAR06) == "237"
    //

    If lBradWS

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
    
Return lAchouTit
