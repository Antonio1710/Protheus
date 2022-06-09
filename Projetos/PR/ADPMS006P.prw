#include "protheus.ch" 
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ADPMS006P � Autor � Fernando Macieira  � Data �  19/07/18   ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Popula campos AF8_XCONSU e AF8_XDTCON                       ���
���          �Utilizados no painel gerencial da diretoria                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���08/03/2019�Adriana        �Ajustar MSG Console/LOG                     ���
���11/03/2019�Adriana        �Retirar CONOUT pois a funcao APMSGSTOP ja   ���
���          �               �apresenta a mensagem no console.log         ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
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

	// Garanto uma �nica thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
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

	//��������������������������������������?
	//�Destrava a rotina para o usu�rio	    ?
	//��������������������������������������?
	UnLockByName("ADPMS006P")

	ApMsgStop( '[ADPMS006P] - JOB - CONSUMOS GRAVADOS COM SUCESSO - FINALIZADO EM ' + DtoC(msDate()) +" "+TIME())  //Incluida hora fim por Adriana em 08/03/2019

	//Fecha o ambiente.
	RpcClearEnv()

Return
