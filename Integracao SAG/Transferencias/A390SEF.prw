/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A390SEF   �Autor  �                    � Data �  04/19/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE Grava��o complementar                                   ���
���          � Cheque sobre titulo                                        ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A390SEF

//����������������������Ŀ
//�Retorno interface SAG.�
//������������������������

If Alltrim(cEmpAnt) == "01"
	If !Empty(SE2->E2_XRECORI)
		A390INTS(SE2->E2_XRECORI)	
	EndIf                      
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO5     �Autor  �Microsiga           � Data �  04/19/16   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A390INTS(cRec)

Local   aTables		:={"SE2","SA2"}

//Private _nTcConn1	:= advConnection()
Private _cNomBco1  	:= ""
Private _cSrvBco1   := ""
Private _cPortBco1  := ""
Private _cNomBco2   := ""
Private _cSrvBco2   := ""
Private _cPortBco2  := ""

// define link com a base da Interface
// _cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
// _cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
// _cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))

//BeginTran()
	
	// //TESTA CONEXAO COM O BANCO DE INTEGRA��O
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	_lRet     := .F.
	// 	cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
	// 	MsgInfo("N�o foi poss�vel  conectar ao banco integra��o, verifique com administrador","ERROR")	
	// EndIf
	
	//TcSetConn(_nTcConn2) 
	
	TcSqlExec("UPDATE SGFIN010 SET STATUS_INT='', STATUS_PRC='S', MENSAGEM_PRC='BAIXADO', E2_DTBAIXA='"+ DTOS(DDATABASE) + "' WHERE R_E_C_N_O_="+AllTrim(Str(val(cRec)))+" ")
	
	//TcSetConn(_nTcConn1) 		

//EndTran()

Return
