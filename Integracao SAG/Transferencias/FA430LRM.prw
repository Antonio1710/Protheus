#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função	 ?FA430LRM     ?Autor ?Leonardo Rios	     ?Data ?13.04.16 	  	   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ?Regra de negócio criada para o título do tipo PA/NDF atualizar o    ³±?
±±?		 ?valor do campo STATUS_PRC como 'P' da tabela SGFIN010 intermediária   ³±?
±±?		 ?entre Protheus X Edata utilizando como chave o campo E2_XRECORI do  ³±?
±±?		 ?SE2(Títulos)com o CODIGENE(SGFIN010) 	 							   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ?FINA340 - Título				     				      	  		   ³±?
±±?		 ?O ponto de entrada tem como finalidade gravar complemento das baixas³±?
±±?		 ?CNAB a pagar do retorno bancario.	     						   ³±?
±±?		 ?Projeto SAG II													   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
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
		// 	cMsgError := "Não foi possível  conectar ao banco integração"
		// 	MsgInfo("Não foi possível  conectar ao banco integração para ajustar a tabela SGNFE010, verifique com administrador","ERROR")
			
		// EndIf 
		
		Alert(ALLTRIM(SE2->E2_XRECORI))
		
		//TcSetConn(_nTcConn2)
		TcSqlExec("UPDATE SGFIN010 SET STATUS_INT='S', STATUS_PRC = 'P', STATUS_LIB='4', MENSAGEM_PRC ='BAIXADO' WHERE CODIGENE= '" + ALLTRIM(SE2->E2_XRECORI) + "' " )
		
		//TcUnLink(_nTcConn2)

		//TcSetConn(_nTcConn1)

	EndIf

Endif
	
Return

