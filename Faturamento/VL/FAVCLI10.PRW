//Ú---------Â------------------Â------Â----------------------------------------Â----Â-----------¿
//|PROGRAMA |FAVCLI10          |AUTOR | DANIEL PITTHAN SILVEIRA                |DATA| 09.05.07  |
//Ã---------+------------------Á------Á----------------------------------------Á----Á-----------´
//|DESCRICAO|  Valida se ja ha pedido lancado para o cliente na database                        |
//|         |                                                                                   |
//|         |                                                                                   |
//|         |                                                                                   |
//Ã---------+----------------------Â-----Â------------------------------------------------------´
//|MODULO   | FATURAMENTO          |TIPO | [ ] - PROCESSAMENTO          [ ] - TRANSACAO         |
//|         |                      |     | [ ] - PONTO DE ENTRADA       [X] - VALIDACAO         |
//|         |                      |     | [ ] - GATILHO                [ ] - CONSULTA          |
//|         |                      |     | [ ] - RELATORIO                                      |
//Ã---------+--------------Â-------Á-----Á----Â-------------------------------------------------´
//|MANUT.   |DATA          | AUTOR            |DESCRICAO                                        |
//Ã---------+--------------+------------------+-------------------------------------------------´
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//À---------Á--------------Á------------------Á-------------------------------------------------Ù
// @history Ticket  TI    - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 

USER FUNCTION FAVCLI10(cCod)
	Private aAreaSC5	:= {}
	Private aAreaSC6	:= {}
	Private aAreaSA1	:= {}
	Private aAreaSA2	:= {}
	Private cFilSC5		:= ""
	Private lSfInt		:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

	//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida se ja ha pedido lancado para o cliente na database')

	//Conout( DToC(Date()) + " " + Time() + " FAVCLI10 >>> INICIO PE" )

	if !lSfInt
	

		aAreaSC5	:= SC5->(GetArea())
		aAreaSC6	:= SC6->(GetArea())
		aAreaSA1	:= SA1->(GetArea())
		aAreaSA2	:= SA2->(GetArea())
		cFilSC5		:= xFilial("SC5")

		//+-----------------------------------------------------+
		//|Declaracao de Variaveis                              |
		//+-----------------------------------------------------+
		//+--------------------------------------+
		//|Ambiente                              |
		//+--------------------------------------+
		

		IF SM0->M0_FILIAL == '02'

			DbSelectArea("SC5")
			//DbSetOrder(11) 															//C5_FILIAL+C5_EMISSAO+C5_CLIENTE+C5_LOJACLI
			SC5->(DBORDERNICKNAME("SC5_B")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032

			//+--------------------------------------+
			//|Procurando Cliente                    |
			//+--------------------------------------+

			If DbSeek(cFilSC5+DTOS(DDATABASE)+cCod,.T.) 
					MsgInfo("Ja ha pedido para o cliente."+;
					CHR(13)+"Data:    "+DTOC(DDATABASE)+;
					CHR(13)+"Pedido:  "+SC5->C5_NUM+;
					CHR(13)+"Roteiro: "+SC5->C5_ROTEIRO,"Alerta")
			EndIf
			
		ENDIF


		//+--------------------------------------+
		//|Restaurando Ambiente                  |
		//+--------------------------------------+
		RestArea(aAreaSC5)
		RestArea(aAreaSC6)
		RestArea(aAreaSA1)
		RestArea(aAreaSA2)
	
	endif

	//Conout( DToC(Date()) + " " + Time() + " FAVCLI10 >>> FINAL PE" )

RETURN(.T.) 
