#include "protheus.ch" 
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADPMS006P ³ Autor ³ Fernando Macieira  ³ Data ³  19/07/18   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Popula campos AF8_XCONSU e AF8_XDTCON                       ³±±
±±³          ³Utilizados no painel gerencial da diretoria                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³08/03/2019³Adriana        ³Ajustar MSG Console/LOG                     ³±±
±±³11/03/2019³Adriana        ³Retirar CONOUT pois a funcao APMSGSTOP ja   ³±±
±±³          ³               ³apresenta a mensagem no console.log         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADPMS006P()

Local nConsumo := 0

	// Inicializa ambiente
	RpcClearEnv()
	RpcSetType(3)
	
	//rpcSetEnv("01", "02",,,,,{"SM0"})

	If !RpcSetEnv( "01", "02" )
	
		ApMsgStop( '[ADPMS006P] - JOB - NAO FOI POSSIVEL INICIALIZAR O AMBIENTE 01/02 !!! ' )
		Return .F.
	Else
	
		ApMsgStop( '[ADPMS006P] - JOB - CONSUMOS INICIADO EM ' + DtoC(msDate())+" "+TIME() ) //Incluida hora de inicio por Adriana em 08/03/2019
		
	EndIf

	// Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
	If !LockByName("ADPMS006P", .T., .F.)
		ConOut("[ADPMS006P] - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Popula campos AF8_XCONSU e AF8_XDTCON Utilizados no painel gerencial da diretoria')

	// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	//FWMonitorMsg(ALLTRIM(PROCNAME()))
	
	dbSelectArea("AF8")
	AF8->( dbGoTop() )
	Do While AF8->( !EOF() )
	
		/*
		// Projeto Encerrado
		If AF8->AF8_ENCPRJ == "1"
			AF8->( dbSkip() )
			Loop
		EndIf
		
		// Projeto sem valor
		If AF8->AF8_XVALOR == 0
			AF8->( dbSkip() )
			Loop
		EndIf
		*/
	
		nConsumo := 0
		nConsumo := u_ADCOM017P(AF8->AF8_PROJET,"BROWSE")
		
		RecLock("AF8", .f.)
		
			AF8->AF8_XCONSU := nConsumo
			AF8->AF8_XDTCON := msDate()
		
		AF8->( msUnLock() )
	
		AF8->( dbSkip() )
	
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//³Destrava a rotina para o usuário	    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	UnLockByName("ADPMS006P")

	ApMsgStop( '[ADPMS006P] - JOB - CONSUMOS GRAVADOS COM SUCESSO - FINALIZADO EM ' + DtoC(msDate()) +" "+TIME())  //Incluida hora fim por Adriana em 08/03/2019

	//Fecha o ambiente.
	RpcClearEnv()

Return
