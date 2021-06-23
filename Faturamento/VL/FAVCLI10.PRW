//к---------Т------------------Т------Т----------------------------------------Т----Т-----------П
//|PROGRAMA |FAVCLI10          |AUTOR | DANIEL PITTHAN SILVEIRA                |DATA| 09.05.07  |
//У---------+------------------С------С----------------------------------------С----С-----------Д
//|DESCRICAO|  Valida se ja ha pedido lancado para o cliente na database                        |
//|         |                                                                                   |
//|         |                                                                                   |
//|         |                                                                                   |
//У---------+----------------------Т-----Т------------------------------------------------------Д
//|MODULO   | FATURAMENTO          |TIPO | [ ] - PROCESSAMENTO          [ ] - TRANSACAO         |
//|         |                      |     | [ ] - PONTO DE ENTRADA       [X] - VALIDACAO         |
//|         |                      |     | [ ] - GATILHO                [ ] - CONSULTA          |
//|         |                      |     | [ ] - RELATORIO                                      |
//У---------+--------------Т-------С-----С----Т-------------------------------------------------Д
//|MANUT.   |DATA          | AUTOR            |DESCRICAO                                        |
//У---------+--------------+------------------+-------------------------------------------------Д
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//Р---------С--------------С------------------С-------------------------------------------------й
USER FUNCTION FAVCLI10(cCod)    

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida se ja ha pedido lancado para o cliente na database')

//+-----------------------------------------------------+
//|Declaracao de Variaveis                              |
//+-----------------------------------------------------+
//+--------------------------------------+
//|Ambiente                              |
//+--------------------------------------+
Private aAreaSC5:=SC5->(GetArea())
Private aAreaSC6:=SC6->(GetArea())
Private aAreaSA1:=SA1->(GetArea())
Private aAreaSA2:=SA2->(GetArea())

Private cFilSC5:=xFilial("SC5")

IF SM0->M0_FILIAL == '02'

	DbSelectArea("SC5")
	//DbSetOrder(11) 															//C5_FILIAL+C5_EMISSAO+C5_CLIENTE+C5_LOJACLI
	SC5->(DBORDERNICKNAME("SC5_B")) //atualizaчуo protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032

	//+--------------------------------------+
	//|Procurando Cliente                    |
	//+--------------------------------------+

	If DbSeek(cFilSC5+DTOS(DDATABASE)+cCod,.T.) 
			MsgInfo("Ja ha pedido para o cliente."+;
			CHR(13)+"Data:    "+DTOC(DDATABASE)+;
			CHR(13)+"Pedido:  "+SC5->C5_NUM+;
			CHR(13)+"Roteiro: "+SC5->C5_ROTEIRO)
	EndIf
	
ENDIF


//+--------------------------------------+
//|Restaurando Ambiente                  |
//+--------------------------------------+
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSA1)
RestArea(aAreaSA2)

RETURN(.T.) 