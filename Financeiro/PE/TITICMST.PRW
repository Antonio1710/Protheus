#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function TITICMST
	Atualiza Data de Vencimento do Titulo de ICMS ST gerado pela rotina de Apuração de ICMS - Ch.028952
	@type  Function
	@author ABEL BABINI FILHO
	@since 12/11/2019
	@version version
	@history Chamado Interno - Abel Babini   - 20/04/2020 - Títulos gerados pela rotina de apuração de ICMS devem nascer liberados conforme solicitado pelo Financeiro
	@history Ticket  4220    - William Costa - 16/11/2020 - Gravar o campo E2_LOGDTHR  
/*/

User Function TITICMST()

	Local cOrigem := PARAMIXB[1]
	Local cTipoImp := PARAMIXB[2] 
	Private oDlg
	Private oVEnc
	Private dVEnc := DATE()+30
	Private oButton1
	Private oGroup1
	Private oSay1

	IF  AllTrim(cOrigem)=='MATA953' //Apuracao de ICMS
		//cTipoImp := SF6->F6_TIPOIMP  
		
		IF AllTrim(cTipoImp)=='3' //ICMS ST

			DEFINE MSDIALOG oDlg TITLE "Informações complementares" FROM 000, 000  TO 100, 400 COLORS 0, 16777215 PIXEL

				@002, 006 GROUP oGroup1 TO 045, 191 PROMPT "DIGITE O VENCIMENTO PARA TITULO ST" OF oDlg COLOR 0, 16777215 PIXEL
				@020, 011 SAY oSay1 PROMPT "Vencimento: " SIZE 035, 008 OF oDlg COLORS 0, 16777215 PIXEL
				@018, 042 MSGET oVEnc VAR dVEnc SIZE 054, 010 OF oDlg COLORS 0, 16777215 PIXEL
				@014, 117 BUTTON oButton1 PROMPT "Ok" SIZE 052, 016 Action (oDlg:End())  OF oDlg PIXEL

			ACTIVATE MSDIALOG oDlg CENTERED   
				
				SE2->E2_VENCTO 	:= DataValida(dVEnc,.T.)
				SE2->E2_VENCREA := DataValida(dVEnc,.T.)
				SE2->E2_DATALIB	:= dDatabase //Chamado Interno - Abel Babini - 20/04/2020 - Títulos gerados pela rotina de apuração de ICMS devem nascer liberados conforme solicitado pelo Financeiro
				
				
		ELSEIF  AllTrim(cTipoImp)=='1' //ICMS //Chamado Interno - Abel Babini - 20/04/2020 - Títulos gerados pela rotina de apuração de ICMS devem nascer liberados conforme solicitado pelo Financeiro

			SE2->E2_DATALIB	:= dDatabase //Chamado Interno - Abel Babini - 20/04/2020 - Títulos gerados pela rotina de apuração de ICMS devem nascer liberados conforme solicitado pelo Financeiro

		ENDIF

		SE2->E2_LOGDTHR	:= IIF(EMPTY(SE2->E2_LOGDTHR),DTOC(DATE()) + ' ' + TIME(),SE2->E2_LOGDTHR)

	ENDIF 

RETURN{SE2->E2_NUM,SE2->E2_VENCTO}
