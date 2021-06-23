#Include 'Protheus.ch'

/*
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Fun��o	 ?FA430LRM     ?Autor ?Leonardo Rios	     ?Data ?13.04.16 	  	   ��?
����������������������������������������������������������������������������������Ĵ��
���Descri��o ?Regra de neg�cio criada para o t�tulo do tipo PA/NDF atualizar o    ��?
��?		 ?valor do campo STATUS_PRC como 'P' da tabela SGFIN010 intermedi�ria   ��?
��?		 ?entre Protheus X Edata utilizando como chave o campo E2_XRECORI do  ��?
��?		 ?SE2(T�tulos)com o CODIGENE(SGFIN010) 	 							   ��?
����������������������������������������������������������������������������������Ĵ��
���Uso		 ?FINA340 - T�tulo				     				      	  		   ��?
��?		 ?O ponto de entrada tem como finalidade gravar complemento das baixas��?
��?		 ?CNAB a pagar do retorno bancario.	     						   ��?
��?		 ?Projeto SAG II													   ��?
����������������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
*/
User Function FA430LRM()

// Local _cNomBco2 := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
// Local _cSrvBco2 := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
// Local _cPortBco2:= Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
// Local _nTcConn1 := advConnection()
// Local _nTcConn2 := 0

If Alltrim(cEmpAnt) == "01"

	If !EMPTY(ALLTRIM(SE2->E2_XRECORI))  //Alterado por Adriana em 29/08/2017 chamado 036906
		
		// TcConType("TCPIP")
		// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
		// 	_lRet     := .F.
		// 	cMsgError := "N�o foi poss�vel  conectar ao banco integra��o"
		// 	MsgInfo("N�o foi poss�vel  conectar ao banco integra��o para ajustar a tabela SGNFE010, verifique com administrador","ERROR")
			
		// EndIf 
		
		Alert(ALLTRIM(SE2->E2_XRECORI))
		
		//TcSetConn(_nTcConn2)
		TcSqlExec("UPDATE SGFIN010 SET STATUS_INT='S', STATUS_PRC = 'P', STATUS_LIB='4', MENSAGEM_PRC ='BAIXADO' WHERE CODIGENE= '" + ALLTRIM(SE2->E2_XRECORI) + "' " )
		
		//TcUnLink(_nTcConn2)

		//TcSetConn(_nTcConn1)

	EndIf

Endif
	
Return

