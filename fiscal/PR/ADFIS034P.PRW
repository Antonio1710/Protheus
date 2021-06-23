#INCLUDE "rwmake.ch"
#include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณ          บ Autor ณ ADRIANO SAVOINE    บ Data ณ  29/07/2019 	 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDescrio ณ Programa para alteracao do parametro MV_#QTDREF               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado:  ณ Chamado: 050739                                               บฑฑ
ฑฑบ				Foi desenvolvido para a Rosangela alterar a Qtd de Referenciaบฑฑ
ฑฑบ          | de caixas para os pedidos de venda, hoje ้ obrigatorio 15 cx  บฑฑ
ฑฑบ          | porem ela pode alterar para uma quantidade menor.             บฑฑ                                             
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ADFIS034P()

Local aAreaAnt := GetArea()
Local cUsr     := Alltrim(SuperGetMv("MV_#QTREFU", .F. , '',))
Local cCaixa   := Alltrim(cValToChar(GetMv("MV_#QTDREF")))

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para alteracao do parametro MV_#QTDREF ')

IF Alltrim(cValToChar(__cUserId))$ cUsr
	IF MsgBox("A Quantidade Atual Obrigatoria de Caixas para Pedidos de Venda ้ de: " + CVALTOCHAR(GETMV("MV_#QTDREF")) +"."+ CHR(13)+ CHR(13)+ "Deseja alterar o parโmetro?"," Altera parโmetro MV_#QTDREF ","YESNO")

		IF(PERGUNTE("ADFIS034P"))
		PutMv("MV_#QTDREF",(MV_PAR01)) 
		ENDIF
		
		//gera log de reprogramacao
		u_GrLogZBE (Date(),TIME(),cUserName," REPROGRAMACAO","FISCAL","ADFIS034P",;
	    "REFATURAMENTO CAIXAS - De "+ cCaixa + " Para " + CVALTOCHAR(GETMV("MV_#QTDREF")),ComputerName(),LogUserName())
									

	ENDIF
ELSEIF Alert("Seu Usuario do Protheus nใo pode alterar a Quantidade de Caixas Obrigatoria para Pedidos de Venda.")
	
ENDIF
	

RestArea(aAreaAnt)


Return 