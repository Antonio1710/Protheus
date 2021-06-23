#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} User Function LP520007
	Excblock utilizado para retornar o Conta Contabil debito
	@type  Function
	@author WILLIAM COSTA
	@since 27/01/2017
	@version 01
	@history Chamado 049561 - William Costa - 06/06/2019 - Tratamento para quando o motivo da Baixa foir BCF ou BPQ, pular e nao gravar Lancamento. 
	@history Chamado 3284   - William Costa - 13/10/2020 - Adicionado regra de exceção para titulos com tipo PR não serem contabilizados.

*/	
User Function LP520007()

	Local cConta := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	             
    cConta:= IIF(ALLTRIM(SE1->E1_TIPO)=="NDC","111720002",IIF(ALLTRIM(SE1->E1_TIPO)=="JP","191110097",IIF(ALLTRIM(SE1->E1_TIPO)=="CH","111230001",IIF(!EMPTY(SA1->A1_CONTA),SA1->A1_CONTA,IIF(SA1->A1_EST<>"EX",TABELA("Z@","A00",.F.),TABELA("Z@","A01",.F.)))))) 

RETURN(cConta) 

User Function LP520VLR()

	Local nValor := 0
	
	U_ADINF009P('LP520007' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//Ajuste William Costa 06/06/2019 chamado 049561
 	nValor:= IF(SE1->E1_NATUREZ="10150",0,IF(!SE5->E5_MOTBX$"DAC,LIQ,DEV,SIN,DEA,JPN,SDD,BCF,BPQ".AND.!SE5->E5_TIPO$"RA /NCC/BON/PR " .AND. !SE5->E5_TIPODOC $ "J2",SE5->E5_VALOR-SE5->E5_VLJUROS-SE5->E5_VLMULTA+SE5->E5_VLDESCO-SE5->E5_VLCORRE,0))

Return (nValor) 
