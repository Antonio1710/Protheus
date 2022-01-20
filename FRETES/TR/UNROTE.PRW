#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function UNROTE
	Remove placa do pedido de vendas para exclusao do pedido
	@type  Function
	@author DANIEL PITTHAN SILVEIRA
	@since 04/04/2007
	@history Chamado 4992 - William Costa   - 24/11/2020 - Adicionado no Filtro para ver notas que estão com 'XXXXXX' que são notas denegadas ou Canceladas, e conseguir limpar a Placa delas.
	@history Chamado 5657 - William Costa   - 26/11/2020 - Voltado versão de limpa placa, pq não deu certo o jeito que foi pensado será feito na tela de Ocorrências de Devoluções.
	@history Ticket 64881 - Fernando Sigoli - 04/01/2022 - Adicionado Função LIMPAZCI, para quando limpar placa , liberar a msg do ZCI, com isso liberar a intergação novamente do pedido
	@history Ticket 64881 - Fernando Sigoli - 14/01/2022 - Adicionado tratamento da LIMPAZCI, apenas para a empresa 01/02 que em salesforce
	@history Ticket 66691 - Leonardo P. Monteiro - 19/01/2022 - Correção de error.log.

/*/

USER FUNCTION UNROTE() 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Remove placa do pedido de vendas para exclusao do pedido')

	IF ALLTRIM(SC5->C5_XINT)  == "3" 

		ALERT("Roteiro já enviado para o Edata, para altera-lo é necessario o Estorno")

	ELSE 

		IF !Empty(SC5->C5_PLACA)                    .AND. ;
		   EMPTY(SC5->C5_NOTA)	                    .AND. ;
		   APMsgNoYes("Remover a Placa?","Atenção")

			RecLock("SC5",.F.)

				REPLACE SC5->C5_PLACA 	WITH '' 
				REPLACE SC5->C5_UFPLACA WITH ''	  

			MsUnlock()

			//grava log/alteracao de bairro	
			u_GrLogZBE (Date(),TIME(),cUserName," LIMPAR PLACA 2","LOGISTICA","UNROTE",;
			"PEDIDO: "+SC5->C5_NUM+" PLACA DE: "+SC5->C5_PLACA+" PARA: VAZIO",ComputerName(),LogUserName()) 


			//Ticket 64881 - Fernando Sigoli - 04/01/2022.
			//Ticket 66691 - Leonardo P. Monteiro - 19/01/2022.
			IF cEmpAnt == "01" .And. cFilAnt == "02"
				IF 	SC5->C5_XSFPED <> ''
					LIMPAZCI(SC5->C5_NUM)
				ENDIF
			Endif

			//Everson - 02/04/2018. Chamado 037261.
			IF FindFunction("U_ADVEN050P") .And. cEmpAnt == "01" .And. cFilAnt == "02"

				IF Upper(Alltrim(cValToChar(GetMv("MV_#SFATUL")))) == "S"
				
					U_ADVEN050P("",,," AND C5_NUM = '" + Alltrim(cValToChar(SC5->C5_NUM)) + "' AND C5_XPEDSAL <> '' ",,,,,,.T.)
				
				ENDIF
			ENDIF
		ENDIF
	ENDIF

RETURN(NIL) 

//LIMPA ERRO DE PLACA DA ZCI
//Fernando Sigoli - 04/01/2022 
STATIC FUNCTION LIMPAZCI(cPedido)
	
	Local cUpda := ""

	cUpda := " UPDATE " + RetSqlName("ZCI") + " SET ZCI_ERRO = CONVERT(VARBINARY, '')  WHERE R_E_C_N_O_ = " 
	cUpda += " ( "
	cUpda += " SELECT  "
	cUpda += " TOP 1 R_E_C_N_O_ "
	cUpda += " FROM " + RetSqlName("ZCI") + " WHERE "
	cUpda += " ISNULL(CAST(CAST(ZCI_ERRO AS VARBINARY(8000)) AS VARCHAR(8000)),'')  like ('%(placa)%') "
	cUpda += " AND ZCI_METD = 'PUT' "
	cUpda += " AND ZCI_NUMP = '" + cPedido + "' "  
	cUpda += " ORDER BY R_E_C_N_O_ DESC) "
	
	If (TCSqlExec(cUpda)) < 0
		MsgAlert("Não foi possível retornar os regitros para reprocessamento TCSQLError() " + TCSQLError(),"Função LIMPAZCI")
    
    EndIf

RETURN(NIL)
