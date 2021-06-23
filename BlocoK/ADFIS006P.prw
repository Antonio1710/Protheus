#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} User Function ADFIS006P
	Função para integração do estoque
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@version 01
	@history Chamado 053423 - William Costa         - 19/11/2019 - Identificado falha que não existia centro de custo para o produto com erro e existia movimentos com quantidade zero isso não pode ocasionando error log.  
	@history Chamado 054188 - FWNM                  - 16/12/2019 - OS 055594 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ADFIS005P
	@history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
/*/
User Function ADFIS006P(cEmp, cFil, cJobFile, lJOb)

	Local   aTables		:={"SB1", "SC2", "SD3", "SB2", "SD4", "SF5", "ZA1", "SD1", "SD2", "SD5", "TD9", "QP6"}
	Local	cPerg		:= "ADFIS006P"

	/* Variáveis para conexão entre os banco do Protheus e o banco intermediário */
	Private _cNomBco1   := ""
	Private _cSrvBco1   := ""
	Private _cPortBco1  := ""
	Private _nTcConn1	:= advConnection()
	Private _cNomBco2   := ""
	Private _cSrvBco2   := ""
	Private _cPortBco2  := ""
	Private _nTcConn2

	/*Variáveis com as informações para serem usadas no envio de e-mail*/
	Private _cAssunto   := ""
	Private _cCopia     := ""
	Private _cCpOcul    := ""
	Private _cDe        := ""
	Private _cPara      := ""

	Private _xJob		:= .F.

	Default cEmp		:= "01"
	Default cFil		:= "03"
	Default cJobFile	:= "ADFIS006P"
	Default lJob		:= .F.

	_xJob := lJob
		
	If lJob
		
		/*
			TRATAMENTO DO JOB
		*/
		
		/*Apaga arquivo caso já exista*/
		If File(cJobFile)
			fErase(cJobFile)
		EndIf
		
		/*Criação do arquivo de controle de jobs*/
		nHd1 := MSFCreate(cJobFile)
		
		/*STATUS 1 - Iniciando execucao do Job*/
		PutGlbValue("ADFIS006P", "1" )
		GlbUnLock()
		
		
		/*Seta job para nao consumir licensas*/
		RpcSetType(3)
		
		/*Seta job para empresa filial desejada*/		
		RpcSetEnv( cEmp, cFil,,,"PCP","MATA650",aTables, , , ,   )

		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para integração do estoque')
		
		/*Dados e variáveis para controle de conexão entre o banco de dados do Protheus e o banco intermediário*/
		_cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97())
		_cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97())
		_cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
		_cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
		_cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
		_cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
		
		/*Variáveis com as informações de parâmetros do Protheus para serem usadas no envio de e-mail*/
		_cPara      := SuperGetMV("MV_XMPARA" ,,"")
		_cCopia     := SuperGetMV("MV_XMCOPIA",,"")
		_cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
		_cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
		_cDe        := SuperGetMV("MV_XMAILDE",,"")
		
		/*STATUS 2 - Conexao efetuada com sucesso*/
		PutGlbValue("ADFIS006P", "2" )
		GlbUnLock()
		
		ConOut( DTOC(Date()) + " " + Time() + "Inicio Job Integrações Estoque " + cJobFile)
		
		cEmail		:= GetMV("MV_XEMAIL",.F.,"fabricio.kfranca@gmail.com")
		cExt		:= GetMv("MV_XEXT",.F.,"*.CSV")		
		
		
		/*
			PROCESSAMENTO DAS INTERFACES
		*/
		
		/* movimentos de produção de ração e incubatório - Função U_ADFIS015P() e Fonte ADFIS015P.PRW */
		U_ADFIS015P(cFil, cFil)  
		
		/* movimentos de estoque */
		U_ADFIS007P() 
		
		/* exclusao de movimento de requisição */
		U_ADFIS008P(cEmp,cFil,cJobFile) 
		
		/* movimentos de produção de frango - PROGRAMA A PARTE DESTE */
//		U_InOPFrango() //FUNÇÃO FORA DE USO
		
		/* integra OP's - PROGRAMA A PARTE DESTE */
//		InterOPr() //FUNÇÃO FORA DE USO
		
		/* Integra Movimentos de Inventário */
		U_ADFIS009P() //COLOCAR UM GROUP BY PARA AGLUTINAR PRODUTO + LOCAL
		
		/* exclusao da produção da OP */
//		U_InterOPE(cEmp,cFil,cJobFile)   //FUNÇÃO FORA DE USO 
		
		/* exclusao de requisições de MP para OPs */
//		U_ADFIS010P(cEmp,cFil,cJobFile)	//FUNÇÃO FORA DE USO  
		
		/* Cancelamento da OP toda a interface ja foi executada apenas vai rodar o SC2 pelo C2_FLCANC */
//		U_ICancOP(cEmp,cFil,cJobFile) // FUNÇÃO FORA DE USO
		
		ConOut( DTOC(Date()) + " " + Time() + "Final do Job Integrações Estoque " + cJobFile)
	
		PutGlbValue("ADFIS006P","3")
		GlbUnLock()
		
	Else
	
		/*Cria as perguntas no SX1*/
		AjustaSX1(cPerg)
	
		/*Mostra a tela de perguntas*/
		Pergunte(cPerg,.T.)
		
		
		DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Integrações Estoque") PIXEL		
			@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
			@ 16, 15 SAY OemToAnsi("Este programa efetua as integrações do estoque") SIZE 268, 8 OF oDlg PIXEL
			
			DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
			DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| ADFIS006PA()},"Integrações Estoque","Criando Integrações....",.F.),oDlg:End()),) ENABLE OF oDlg
			DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

	
Return

/*{Protheus.doc} User Function ADFIS006PA
	Função para executar as funções de integração de estoque para a opção manual(não job)
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@version 01
*/

Static Function ADFIS006PA()

	Local cPergFilIni := mv_par01 /* Filial De */
	Local cPergFilFim := mv_par02 /* Filial Até */

	Private _aDatas := { DTOS(mv_par03), DTOS(mv_par04) } /* mv_par03 = Período De; 	mv_par04 = Período Até */
	
	
	/* STATUS 1 - Iniciando execucao do Job */
	PutGlbValue("ADFIS006P", "1" )
	GlbUnLock()
	
	
	/* Seta job para nao consumir licensas */
	//	RpcSetType(3)
	
	/* Seta job para empresa filial desejada */	
	//	RpcSetEnv( cEmp, cFil,,,"PCP","MATA650",aTables, , , ,   )
	
	/*Dados e variáveis para controle de conexão entre o banco de dados do Protheus e o banco intermediário*/
	_cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97())
	_cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97())
	_cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
	_cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	_cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	_cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
	
	/*Variáveis com as informações para serem usadas no envio de e-mail*/
	_cPara      := SuperGetMV("MV_XMPARA" ,,"")
	_cCopia     := SuperGetMV("MV_XMCOPIA",,"")
	_cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
	_cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
	_cDe        := SuperGetMV("MV_XMAILDE",,"")
	
	/* STATUS 2 - Conexao efetuada com sucesso */
	PutGlbValue("ADFIS006P", "2" )
	GlbUnLock()
	
	ConOut( DTOC(Date()) + " " + Time() + "Inicio Job Integrações Estoque ADFIS006P" )
	
	cEmail		:= GetMV("MV_XEMAIL",.F.,"fabricio.kfranca@gmail.com")
	cExt		:= GetMv("MV_XEXT",.F.,"*.CSV")
		
	/* 
		PROCESSAMENTO DA INTERFACE 
	*/
	
	/* movimentos de produção de ração e incubatório - Função U_ADFIS015P() e Fonte ADFIS015P.PRW */
	U_ADFIS015P(cPergFilIni, cPergFilFim, .F., _aDatas)  
	
	/* movimentos de estoque */
	U_ADFIS007P(cPergFilIni, cPergFilFim)
	
	/* exclusao de movimento de requisição */
	U_ADFIS008P(cPergFilIni, cPergFilFim)
	//	U_ADFIS008P(cEmp,cFil,cJobFile, mv_par01, mv_par02)
 
	/* movimentos de produção de frango - PROGRAMA A PARTE DESTE */
	//	U_InOPFrango() //FUNÇÃO FORA DE USO
	
	/* integra OP's - PROGRAMA A PARTE DESTE */
	//	InterOPr() //FUNÇÃO FORA DE USO
	
	/* Integra Movimentos de Inventário */
	U_ADFIS009P(cPergFilIni, cPergFilFim)  //COLOCAR UM GROUP BY PARA AGLUTINAR PRODUTO + LOCAL
	
	//FORA DE USO 
	/* exclusao da produção da OP */
	//	U_InterOPE(cEmp,cFil,cJobFile) //FUNÇÃO FORA DE USO 
	
	/* exclusao de requisições de MP para OPs */
	//	U_ADFIS010P(cEmp,cFil,cJobFile)	//FUNÇÃO FORA DE USO   
	
	/* Cancelamento da OP toda a interface ja foi executada apenas vai rodar o SC2 pelo C2_FLCANC */
	//	U_ICancOP(cEmp,cFil,cJobFile) // FUNÇÃO FORA DE USO
	
	ConOut( DTOC(Date()) + " " + Time() + "Final do Job Integrações Estoque ADFIS006P" )
	                                   
	PutGlbValue("ADFIS006P","3")
	GlbUnLock()
	
Return .T.

/*{Protheus.doc} User Function ADFIS007P
	Função usada para integração do movimentos(SGMOV010) de devolução/requisição
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@param aParam[1]  	:[C] cIniFil    - Filial inicial para ser analisado a movimentação
	@param aParam[2]  	:[C] cFimFil    - Filial inicial para ser analisado a movimentação
	@param aParam[3]  	:[A] aParams	- Array com as informações a serem processadas do item
	@param aParam[3,1] 	:[C] aParams[1]	- Filial do movimento	
	@param aParam[3,2] 	:[C] aParams[2]	- Tipo de movimentação do movimento
	@param aParam[3,3] 	:[C] aParams[3]	- Produto do movimento
	@param aParam[3,4] 	:[N] aParams[4]	- Quantidade do produto do movimento
	@param aParam[3,5] 	:[C] aParams[5]	- Local do produto do movimento
	@param aParam[3,6] 	:[C] aParams[6]	- Centro de Custo do movimento
	@param aParam[3,7] 	:[D] aParams[7]	- Data de Emissão do movimento	
	@param aParam[3,8] 	:[C] aParams[8]	- Código do RECNO de origem do movimento
	@param aParam[3,9]	:[C] aParams[9] - Código da OP do movimento
	@param aParam[3,10] :[C] aParams[10]- Número da sequência do movimento
	@param aParam[3,11]	:[C] aParams[11]- Código CODIGENE
	@param aParam[3,12]	:[N] aParams[12]- Valor do custo do movimento
	@param aParam[3,13]	:[N] aParams[13]- Valor do total de parcelas do movimento	
	@param aParam[3,8] 	:[C] aParams[8]	- Código do RECNO de origem do movimento
	@param aParam[3,9]	:[C] aParams[9] - Código da OP do movimento
	@version 01
*/

User Function ADFIS007P(cIniFil, cFimFil, aParams)


	Local aArea     := GetArea()	/* Pega a Area corrente das posiçoes nas tabelas do Protheus */
	Local aCampos	:= {}			/* Variável para guardar os valores corrente da tabela MOV para serem processados no ExecAuto */
	Local aErroLog	:= {}			/* Variável para guardar o array com log de erro corrente caso o ExecAuto não tenha funcionado */

	Local cCod		:= ""			/* Variável auxiliar para guardar o valor do código do produto corrente da tabela MOV */
	Local cErro		:= ""			/* Variável para guardar o texto com log de erro corrente caso o ExecAuto não tenha funcionado */
	Local cFil		:= ""			/* Variável auxiliar para guardar o valor da filial corrente da tabela MOV */
	Local cFilBck 	:= cFilAnt		/* Guarda a filial corrente no sistema para backup já que será alterado a variável publica cFilAnt */
	Local cLoc		:= ""			/* Variável auxiliar para guardar o valor do local do produto corrente da tabela MOV */
	Local cFilMOV	:= ""			/* Variável auxiliar para guardar o valor da filial corrente da tabela MOV para ser gravado no log de processamento */
	Local cMsgError := ""			/* Variável para guardar a mensagem de erro caso não consiga criar a conexão no banco do Protheus e o intermediário */
	Local cQry		:= ""			/* Variável para guardar a query criada*/

	Local dData		:= DDATABASE	/* Data corrente no sistema no formato yyyymmdd */

	Local lRet      := .T.			/* Guarda se conseguiu criar a conexão no banco do Protheus e o intermediário ou não */

	Local nRecMOV	:= ""			/* Variável auxiliar para guardar o valor do recno do item corrente da tabela MOV */
	Local _aCab1 := {}
	Local _aItem := {}
	Local _atotitem:={}

	Private lMsErroAuto := .F. 		/* Variável padrão do execauto para captura de processamento efetuado com sucesso ou não */
	Private _nTcConn1	:= AdvConnection()

	Default cIniFil := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cFimFil := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default aParams := {}	/*Descrição do parâmetro conforme cabeçalho*/
	Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADFIS005P como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADFIS005P*/


	If Len(aParams) > 0
		_aDatas := {DTOS(CTOD(aParams[7])), DTOS(CTOD(aParams[7]))}
		_xJob	:= .F.
	EndIf
	

	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	lRet     := .F.
	// 	cMsgError := "Não foi possível  conectar ao banco integração"
	// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
		
	// EndIf
	
	/* Conecta no banco intermediário SGMOV010 e gera a query para ser executada e pegar os valores */
	//TcSetConn(_nTcConn2)
	
	// Chamado n. 054188 || OS 055594 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || ADFIS005P - FWNM - 16/12/2019
	If MV_PAR06 == 3 // STATUS = ERRO
	  	cQry := "SELECT * FROM SGMOV010 (NOLOCK) WHERE STATUS_INT = 'E' " 
	//
	Else
		cQry := "SELECT * FROM SGMOV010 (NOLOCK) WHERE OPERACAO_INT <> 'E' AND D3_MSEXP = '' " 	//STATUS_INT <> 'S' " 
	EndIf

  	If Len(aParams) > 0
		cQry += " AND D3_TM='" + aParams[2] + "' AND D3_COD='" + aParams[3] + "' AND D3_CC='" + aParams[6] + "' " // AND D3_RECORI'" + aParams[8] + "' "
	EndIf
	
	
	If !_xJob
		cQry += " AND D3_FILIAL BETWEEN '" + cIniFil + "' AND '" + cFimFil + "' AND D3_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
	EndIf
	
	cQry += " AND D_E_L_E_T_=' ' "

	cQry += "ORDER BY D3_FILIAL"
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "MOV", .F., .T.)
	TcSetField( "MOV", "D3_EMISSAO", "D", 8, 0 )
	TcSetField( "MOV", "D3_DTLANC" , "D", 8, 0 )
	TcSetField( "MOV", "D3_DTVALID", "D", 8, 0 )
	
	/*backup da filial corrente*/
	cFilBck := cFilAnt
	
	While !MOV->(Eof())
		
		DbSelectArea("MOV")

		IF MOV->D3_QUANT > 0 // chamado 053423 - WILLIAM COSTA - 19/11/2019
		
			cFilAnt	:= MOV->D3_FILIAL
			cCod 	:= MOV->D3_COD
			cFil 	:= MOV->D3_FILIAL
			cLoc 	:= MOV->D3_LOCAL
			
			DDATABASE := MOV->D3_EMISSAO
			
			/*vai determinar o local pelo centro de custos 21 22 23 24 ou 05 se nao tiver CC informado*/
	//		cLocal  := iIf((AllTrim(MOV->D3_FILIAL)) == "04",SubStr(AllTrim(MOV->D3_CC),3,2),RetFldProd(MOV->D3_COD,"B1_LOCPAD"))
	//		cLocal  := iIf(Empty(cLocal),"05",cLocal)
			
			_aCab1	:= {}
			_aItem	:= {}
			_atotitem := {}
		
			_aCab1 := {{"D3_TM" ,MOV->D3_TM , NIL},;
						{"D3_EMISSAO" ,DDATABASE, NIL}} 
		
			_aItem := {{"D3_COD"     , 	MOV->D3_COD ,NIL},;
						{"D3_QUANT"   ,	MOV->D3_QUANT ,NIL},;
						{"D3_LOCAL"   ,	MOV->D3_LOCAL ,NIL},;
						{"D3_CC" 	   ,	MOV->D3_CC ,NIL},;
						{"D3_RECORI"  ,	StrZero(MOV->R_E_C_N_O_,10) ,NIL}}
			
			aadd(_atotitem,_aitem)
			
			cFilMOV := MOV->D3_FILIAL
			nRecMOV := MOV->R_E_C_N_O_
			
			//TcSetConn(_nTcConn1)
			
			/* O Mata240 nao executa um criasb2 e se isso nao for feito a interface vai gerar um log */
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1") + MOV->D3_COD)
			If !Eof()			
				/*Se existir o produto, crio ele no armazem do movimento com saldo zero*/
				DbSelectArea("SB2")
				DbSetOrder(1)
				If !DbSeek(cFilAnt + cCod + cLoc)
					CriaSb2(cCod, cLoc)
				EndIf
			EndIf
			
			lMsErroAuto:=.F.
			
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

				//Begin Transaction // analiseFWNM
					
					//MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
					MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3) },"Execauto MATA241","Incluindo movimentações... " + cCod )
								
					If lMsErroAuto
			
						lRet := .F.
						
						aErroLog := GetAutoGrLog()
						cErro := IIF(LEN(aErrolog) > 1,Alltrim(aErrolog[1]),MOSTRAERRO("\SYSTEM\ADFIS007P.log")) // chamado 053423 - WILLIAM COSTA - 19/11/2019
						For k := 1 to Len(aErroLog)
							If "INVALIDO" $ UPPER (aErroLog[k])
								cErro+= Alltrim(aErroLog[k]) + Chr(13)+Chr(10)
							EndIf
						Next
						U_CCSGrvLog(cErro, "MOV", nRecMOV, 3, cFilMOV)
						
						_MsgMotivo += cErro
						
						//TcSetConn(_nTcConn2)
						TcSqlExec("UPDATE SGMOV010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(Str(nRecMOV)) + " ")

						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
						DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado! 
						//

					Else
						//TcSetConn(_nTcConn2)
						TcSqlExec("UPDATE SGMOV010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecMOV)) + " ")
					EndIf
				
				//End Transaction // analiseFWNM

				MsUnLockAll() 							// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

			EndIf

		ENDIF

		//TcSetConn(_nTcConn2)
		
		MOV->(DbSkip())
		
	EndDo
	
	MOV->(DbCloseArea())

	//TcUnLinknk(_nTcConn2)

	//TcSetConn(_nTcConn1) //ajuste fabricio 06/03/18
	
	MsUnlockAll() //ajuste fabricio 06/03/18
		
	/*restaura filial corrente*/
	cFilAnt		:= cFilBck           
	DDATABASE 	:= dData
		
	RestArea(aArea)
	
Return lRet

/*{Protheus.doc} User Function ADFIS008P
	Função para integração de cancelamento dos movimentos de devolução/requisição
	@type  Function
	@author Leonardo Rios
	@since 15/12/16
	@param aParam[1]  	:[C] cIniFil    - Filial inicial para ser analisado a movimentação
	@param aParam[2]  	:[C] cFimFil    - Filial inicial para ser analisado a movimentação
	@param aParam[3]  	:[A] aParams	- Array com as informações a serem processadas do item
	@param aParam[3,1] 	:[C] aParams[1]	- Filial do movimento	
	@param aParam[3,2] 	:[C] aParams[2]	- Tipo de movimentação do movimento
	@param aParam[3,3] 	:[C] aParams[3]	- Produto do movimento
	@param aParam[3,4] 	:[N] aParams[4]	- Quantidade do produto do movimento
	@param aParam[3,5] 	:[C] aParams[5]	- Local do produto do movimento
	@param aParam[3,6] 	:[C] aParams[6]	- Centro de Custo do movimento
	@param aParam[3,7] 	:[D] aParams[7]	- Data de Emissão do movimento	
	@param aParam[3,8] 	:[C] aParams[8]	- Código do RECNO de origem do movimento
	@param aParam[3,9]	:[C] aParams[9] - Código da OP do movimento
	@param aParam[3,10] :[C] aParams[10]- Número da sequência do movimento
	@param aParam[3,11]	:[C] aParams[11]- Código CODIGENE
	@param aParam[3,12]	:[N] aParams[12]- Valor do custo do movimento
	@param aParam[3,13]	:[N] aParams[13]- Valor do total de parcelas do movimento	
	@version 01
*/

User Function ADFIS008P(cIniFil, cFimFil, aParams, lEstorno)

	Local aArea     := GetArea()	/* Pega a Area corrente das posiçoes nas tabelas do Protheus */
	Local aCampos	:= {}			/* Variável para guardar os valores corrente da tabela MOV para serem processados no ExecAuto */
	Local aErroLog	:= {}			/* Variável para guardar o array com log de erro corrente caso o ExecAuto não tenha funcionado */

	Local cErro		:= ""			/* Variável para guardar o texto com log de erro corrente caso o ExecAuto não tenha funcionado */
	Local cFilBkp 	:= ""		/* Guarda a filial corrente no sistema para backup já que será alterado a variável publica cFilAnt */
	Local cFilMOV	:= ""			/* Variável auxiliar para guardar o valor da filial corrente da tabela MOV para ser gravado no log de processamento */
	Local cMsgError := ""
	Local cQry		:= ""			/* Variável para guardar a query criada*/
	Local cRecMov	:= ""			/* Variável auxiliar para guardar o valor do recno do item corrente da tabela MOV */

	Local lRet      := .T.	/* Guarda se conseguiu criar a conexão no banco do Protheus e o intermediário ou não */

	Local nRecMOV	:= 0			/* Variável auxiliar para guardar o valor do recno do item corrente da tabela MOV */
	Local aItens	 := {}
	Local aCabec   := {}  
	Local aTotitem := {}

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.

	Private _nTcConn1	:= AdvConnection()

	Default cIniFil := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cFimFil := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default aParams := {}	/*Descrição do parâmetro conforme cabeçalho*/
	Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADFIS005P como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADFIS005P*/

	If Len(aParams) > 0
		_aDatas := {DTOS(CTOD(aParams[7])), DTOS(CTOD(aParams[7]))}
		_xJob	:= .F.
	EndIf

	
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	lRet      := .F.
	// 	cMsgError := "Não foi possível  conectar ao banco integração"
	// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
		
	// EndIf
	
	/* Conecta no banco intermediário SGMOV010 e gera a query para ser executada e pegar os valores */
	//TcSetConn(_nTcConn2)
	
	//TODO: VERIFICAR O MOTIVO DE ESTAR FIXO A DATA
//	cQry := "SELECT * FROM SGMOV010 WHERE SUBSTRING(D3_EMISSAO,1,6) = '201507' AND D3_MSEXP='' AND OPERACAO_INT = 'E' "
  	cQry := "SELECT * FROM SGMOV010 (NOLOCK) WHERE "
  	
  	If lEstorno
  		cQry += " STATUS_INT = 'S' AND D3_MSEXP <> '' "	
  	Else
  		cQry += " OPERACAO_INT = 'E' AND D3_MSEXP = '' "
  	EndIf
  	
  	If Len(aParams) > 0
		cQry += " AND D3_TM='" + aParams[2] + "' AND D3_COD='" + aParams[3] + "' AND D3_CC='" + aParams[6] + "' AND R_E_C_N_O_ = " + alltrim(str(aParams[14]))
	EndIf
	
	If !_xJob
		cQry += " AND D3_FILIAL BETWEEN '" + cIniFil + "' AND '" + cFimFil + "' AND D3_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
	EndIf
	
	cQry += " AND D_E_L_E_T_=' ' "

	cQry += "ORDER BY D3_FILIAL"
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), "MOV", .F., .T.)
	TcSetField( "MOV", "D3_EMISSAO", "D", 8, 0 )
	TcSetField( "MOV", "D3_DTLANC", "D", 8, 0 )
	TcSetField( "MOV", "D3_DTVALID", "D", 8, 0 )
	
	cFilBkp := cFilAnt
	
	While !MOV->(Eof())
		
		cFilMOV := MOV->D3_Filial
		
		nRecMOV := MOV->R_E_C_N_O_
		
		cRecMov := StrZero(MOV->R_E_C_N_O_,10) /*foi setado como caracter pois indices numericos dao problema no protheus*/
		
		cFilAnt := MOV->D3_FILIAL
		
		//TcSetConn(_nTcConn1)
		
		dbSelectArea("SD3")
		dbOrderNickname("RECORI")
		dbSeek(cFilMov+cRecMov)
		If !Eof()
			
			aCabec	:= {}
		 	aItens	:= {}
		 	aTotitem := {}
							
		 	aCabec := { {"D3_DOC" ,SD3->D3_DOC , NIL},;
						{"D3_TM" ,SD3->D3_TM , NIL},;		 	
						{"D3_CC" ,SD3->D3_CC , NIL},;		 							
		   			    {"D3_EMISSAO" ,SD3->D3_EMISSAO, NIL}} 
		
			AADD(aItens, {"D3_COD"		,SD3->D3_COD			, Nil})
			AADD(aItens, {"D3_QUANT"	,SD3->D3_QUANT		, Nil})
			AADD(aItens, {"D3_LOCAL"	,SD3->D3_LOCAL		, Nil})
			AADD(aItens, {"D3_OP"		,SD3->D3_OP	  		, Nil})
			AADD(aItens, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ		, Nil})				
			AADD(aItens, {"D3_ESTORNO"	,"S"		, Nil})				
		
			aadd(aTotitem,aItens) 
			
			lMsErroAuto:=.F.
			
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
			
				//Begin Transaction // analiseFWNM
				
					MsAguarde({|| MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6) },"Execauto MATA241","Estornado movimentações... " + SD3->D3_OP + " " + SD3->D3_COD)
					//MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabec,aTotitem,6) //estorno 
					//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5)
			
					If lMsErroAuto
			
						lRet := .F.
						
						aErroLog := GetAutoGrLog()
						cErro := Alltrim(aErrolog[1])
						
						For k:=1 to Len(aErroLog)
							If "INVALIDO" $ UPPER (aErroLog[k])
								cErro += Alltrim(aErroLog[k]) + Chr(13) + Chr(10)
							EndIf
						Next

						U_CCSGrvLog(cErro, "MOV", nRecMOV, 5, cFilMOV)
						
						_MsgMotivo := cErro
						
						////TcSetConn(_nTcConn2)
						//TcSqlExec("UPDATE SGMOV010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecMOV) ) + " ")

						// @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
						DisarmTransaction()
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado!
						//

					Else
						
						//TcSetConn(_nTcConn2)
						
						If lEstorno
							TcSqlExec("UPDATE SGMOV010 SET D3_MSEXP=' ' ,STATUS_INT='I' , D_E_L_E_T_='*' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecMOV) ) + " ")
						Else
							TcSqlExec("UPDATE SGMOV010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecMOV) ) + " ")
						EndIf

					EndIf
				
				//End Transaction // analiseFWNM

			EndIf

			MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

		Else
			
			cErro := "HELP: Requisição de MP nao Encontrada para ser Cancelada."
			lRet := .F.
			U_CCSGrvLog(cErro, "MOV", nRecMOV, 5, cFilMOV)
			
			_MsgMotivo += cErro
			
		    ////TcSetConn(_nTcConn2)
			//TcSqlExec("UPDATE SGMOV010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecMOV) ) + " ")

		EndIf
		
		//TcSetConn(_nTcConn2)
		
		MOV->(DbSkip())
		
	EndDo
	
	MOV->(DbCloseArea())
	
	RestArea(aArea)
	
	//TcUnLinknk(_nTcConn2)
	
	//TcSetConn(_nTcConn1) //ajuste fabricio 06/03/18
	
	MsUnlockAll() //ajuste fabricio 06/03/18
	
	cFilAnt := cFilBkp

Return lRet

/*{Protheus.doc} User Function ADFIS009P
	Função usada para integração dos movimentos de inventário
	@type  Function
	@author Leonardo Rios
	@since 15/12/16
	@version 01
*/

User Function ADFIS009P(cIniFil, cFimFil, aParams, nOpc, lEstorno)

	Local aArea 	:= GetArea()	/* Pega a Area corrente das posiçoes nas tabelas do Protheus */
	Local aCabSD3	:= {}			/*Array do cabecalho do SD3 que será utilzado quando for necessário o estorno do inventário e estornar os movimentos do inventário*/
	Local aInvent	:= {}			/* Variável para guardar os valores corrente da tabela INV para serem processados no ExecAuto */
	Local aItemSD3	:= {}			/*Array do item do SD3 que será utilzado quando for necessário o estorno do inventário e estornar os movimentos do inventário*/
	Local aItensSD3	:= {}			/*Array final dos itens do SD3 que será utilzado quando for necessário o estorno do inventário e estornar os movimentos do inventário*/
	Local aErroLog	:= {}			/* Variável para guardar o array com log de erro corrente caso o ExecAuto não tenha funcionado */

	Local cCodAux	:= ""			/*Código do produto auxiliar para usar nos processamentos*/
	Local cDocAux	:= ""			/*Código do documento auxiliar para usar nos processamentos*/
	Local cErro		:= ""			/*Variável para guardar o texto com log de erro corrente caso o ExecAuto não tenha funcionado */
	Local cFil		:= ""			/*Variável auxiliar para guardar o valor da filial corrente da tabela INV */
	Local cFilBkp 	:= cFilAnt		/*Guarda a filial corrente no sistema para backup já que será alterado a variável publica cFilAnt */
	Local cLocAux	:= ""			/*Local do produto auxiliar para usar nos processamentos*/
	Local cFilINV	:= ""			/*Variável auxiliar para guardar o valor da filial corrente da tabela INV para ser gravado no log de processamento */
	Local cMsgError := ""			/*Variável para guardar a mensagem de erro caso não consiga criar a conexão no banco do Protheus e o intermediário */
	Local cNumSeqAux:= ""			/*Número da sequência do movimento auxiliar para usar nos processamentos*/
	Local cOperacao	:= ""			/*Tipo de operação que está sendo executada*/
	Local cQry		:= ""			/* Variável para guardar a query criada*/

	Local dData		:= dDataBase	/* Data corrente no sistema no formato yyyymmdd */
	Local dDtaAux	:= dDataBase	/* Data auxiliar para uso nos processamentos */

	Local lRet      := .T.			/* Guarda se conseguiu criar a conexão no banco do Protheus e o intermediário ou não */

	Local nRecINV	:= ""			/* Variável auxiliar para guardar o valor do recno do item corrente da tabela MOV */

	Private lMsErroAuto := .F.		/* Variável padrão do execauto para captura de processamento efetuado com sucesso ou não */
	Private _nTcConn1	:= AdvConnection()

	Default cIniFil := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cFimFil := ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default aParams := {}	/*Descrição do parâmetro conforme cabeçalho*/
	Default nOpc 	:= 3	/*Descrição do parâmetro conforme cabeçalho*/
	Default lEstorno:= .F.
	Default _MsgMotivo 	:= "" /*Esta variável está criada no fonte ADFIS005P como privada e por precaução está sendo criada caso este fonte tenha sido chamado por outro fonte que não seja o ADFIS005P*/


	
	If Len(aParams) > 0
		_aDatas := { DTOS(CTOD(aParams[5])), DTOS(CTOD(aParams[5]))}
		_xJob 	:= .F.
	EndIf


	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	lRet     := .F.
	// 	cMsgError := "Não foi possível  conectar ao banco integração"
	// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
		
	// EndIf
	
	/* Conecta no banco intermediário SGINV010 e gera a query para ser executada e pegar os valores */
	//TcSetConn(_nTcConn2)
	
	If Len(aParams) < 1
		cQry := "SELECT * FROM SGINV010 (NOLOCK) WHERE B7_MSEXP='' OR (B7_MSEXP<>'' AND STATUS_INT='E') " 
	Else
		cQry := "SELECT * FROM SGINV010 (NOLOCK) WHERE "
		
		If nOpc == 5
			If lEstorno
				cQry += " B7_MSEXP <> '' "
			Else
				cQry += " OPERACAO_INT='E' AND B7_MSEXP = '' "
			EndIf			
		Else
			cQry += " (B7_MSEXP='' OR (B7_MSEXP<>'' AND STATUS_INT='E'))  "
		EndIf
	EndIf
	
	If !_xJob
		cQry += " AND B7_FILIAL BETWEEN '" + cIniFil + "' AND '" + cFimFil + "' AND B7_DATA BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
		cQry += " AND B7_COD='" + aParams[2] + "' AND B7_LOCAL='" + aParams[4] + "' "
	EndIf
	
	cQry += " AND D_E_L_E_T_=' ' "
	
	cQry += " ORDER BY B7_FILIAL "
	
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), "INV", .F., .T.)
	TcSetField( "INV", "B7_DATA", "D", 8, 0 )
	TcSetField( "INV", "B7_DTVALID", "D", 8, 0 )
	
	While !INV->(Eof())
		aInvent := {}
		Aadd(aInvent,{"B7_FILIAL"  ,INV->B7_FILIAL	,Nil})
		Aadd(aInvent,{"B7_COD"     ,INV->B7_COD		,Nil})
		Aadd(aInvent,{"B7_LOCAL"   ,INV->B7_LOCAL  	,Nil})
		Aadd(aInvent,{"B7_DOC"     ,INV->B7_DOC		,Nil})
		Aadd(aInvent,{"B7_QUANT"   ,INV->B7_QUANT  	,Nil})
		Aadd(aInvent,{"B7_DATA"    ,INV->B7_DATA   	,Nil})
	
		cFilINV 	:= INV->B7_FILIAL
		nRecINV 	:= INV->R_E_C_N_O_
		
		cFilAnt 	:= INV->B7_FILIAL
		
		dDtaAux 	:= INV->B7_DATA
		cCodAux		:= INV->B7_COD
		cLocAux 	:= INV->B7_LOCAL
		cDocAux		:= INV->B7_DOC
		cOperacao	:= INV->OPERACAO_INT
		//TcSetConn(_nTcConn1)
		
		lMsErroAuto := .f.
		
		If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

			//Begin Transaction // analiseFWNM
		
				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek( xFilial("SB2") + cCodAux + cLocAux ))
					CriaSB2(cCodAux, cLocAux)
				Else
					dbSelectArea("SB2")
					RecLock("SB2",.F.)
						Replace B2_DINVENT With dDtaAux
					// @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
					//MsUnlockAll() 
					SB2->( MsUnlock() ) 
					SB2->( fkCommit() )
					//
				EndIf
				
				/*
					Efetua o processamento de todos os movimentos relacionados ao inventário (Estorno do Acerto de Inventário)
				*/
				If lEstorno .OR. cOperacao == "E"				
					
					/*Verifica se o Alias da query já está sendo usado para fechar*/
					
					/*Posiciona no item para buscar os movimentos relacionados ao inventário que deverá ser estornado*/
					/*
						SD3 - Index RECORI
						D3_FILIAL, D3_RECORI, R_E_C_N_O_, D_E_L_E_T_
					*/				
					dbSelectArea("SD3")
					SD3->(DbOrderNickName("RECORI"))

					If SD3->( dbSeek( cFilINV + ALLTRIM(StrZero(nRecINV, 10)) ) )
					
						While SD3->D3_RECORI == ALLTRIM(StrZero(nRecINV, 10)) .AND. SD3->D3_ESTORNO == "S"
							SD3->(DbSkip())
						EndDo

						If SD3->D3_RECORI == ALLTRIM(StrZero(nRecINV, 10))

							AADD(aCabSD3, {"D3_FILIAL"	,SD3->D3_FILIAL	, Nil})
							AADD(aCabSD3, {"D3_TM"		,SD3->D3_TM		, Nil})
							AADD(aCabSD3, {"D3_COD"		,SD3->D3_COD	, Nil})
							AADD(aCabSD3, {"D3_QUANT"	,SD3->D3_QUANT	, Nil})
							AADD(aCabSD3, {"D3_LOCAL"	,SD3->D3_LOCAL	, Nil})
							AADD(aCabSD3, {"D3_EMISSAO"	,SD3->D3_EMISSAO, Nil})
							AADD(aCabSD3, {"D3_CC"		,SD3->D3_CC 	, Nil})
							AADD(aCabSD3, {"D3_OP"		,SD3->D3_OP	  	, Nil})
							AADD(aCabSD3, {"D3_DOC" 	,SD3->D3_DOC 	, NIL})
							AADD(aCabSD3, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ	, Nil})
							AADD(aCabSD3, {"INDEX"		,4				, Nil})
							
							lMsErroAuto := .F.
							
							/*
								SD3 - Index 07
								D3_FILIAL, D3_COD, D3_LOCAL, D3_EMISSAO, D3_NUMSEQ, R_E_C_N_O_, D_E_L_E_T_
							*/
							/*Posiciona no item do SD3 para que no execauto não se perca*/
		//					SD3->(DbSetOrder(7))
		//					SD3->(DbSeek( Padr(cFilINV, TamSX3("D3_FILIAL")[1]) + Padr(cCodAux, TamSX3("D3_COD")[1]) + Padr(cLocAux, TamSX3("D3_LOCAL")[1]) + Padr(DTOS(dDtaAux), TamSX3("D3_EMISSAO")[1]) + Padr(cNumSeqAux, TamSX3("D3_NUMSEQ")[1]) ))
							
							
							/*Efetua o estorno dos movimentos relacionados ao inventário que foi estornado*/
		//					MSExecAuto({|x,y,z| MATA241(x,y,z)}, aCabSD3, aItemSD3, 6)
							
							If SD3->D3_TM == "499" .OR. SD3->D3_TM == "999"
								SB2->(DbSetOrder(1))
								If SB2->(DbSeek( Padr(cFilINV, TamSX3("D3_FILIAL")[1]) + Padr(cCodAux, TamSX3("D3_COD")[1]) + Padr(cLocAux, TamSX3("D3_LOCAL")[1]) ))
									RecLock("SB2", .F.)
										SB2->B2_DINVENT := STOD("//")
									SB2->( MsUnlock() ) // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
									SB2->( fkCommit() ) // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								EndIf
							EndIf 
							
							SD3->( dbSeek( cFilINV + ALLTRIM(StrZero(nRecINV, 10)) ) )
							While SD3->D3_RECORI == ALLTRIM(StrZero(nRecINV, 10)) .AND. SD3->D3_ESTORNO == "S"
								SD3->(DbSkip())
							EndDo
							
							/*Efetua o estorno das requisições relacionados ao inventário que foi estornado*/
							//MSExecAuto({|x,y| MATA240(x,y)}, aCabSD3, 5)
							MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCabSD3, 5) },"Execauto MATA240","Incluindo movimentações... " + SD3->D3_OP + " " + SD3->D3_COD )
		
							If lMsErroAuto

								lRet := .F.
		
								aErroLog:=GetAutoGrLog()
								For k:=1 to Len(aErroLog)
									If "INVALIDO" $ UPPER (aErroLog[k])
										cErro+= Alltrim(aErroLog[k])
									EndIf
								Next
		
								U_CCSGrvLog(cErro, "INV", nRecINV, 3, cFilINV)
								
								_MsgMotivo += cErro
		
								//TcSetConn(_nTcConn2)
								TcSqlExec("UPDATE SGINV010 SET B7_MSEXP='" + DTOS(dData) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + AllTrim(Str(nRecINV)) + " ")

								// @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								DisarmTransaction()
								//Break // Reabilitar apenas se o Begin Transaction estiver habilitado!
								//
							
							Else
		
								//TcSetConn(_nTcConn2)

								If cOperacao == "E"	
									TcSqlExec("UPDATE SGINV010 SET B7_MSEXP='" + DTOS(dData) + "' ,STATUS_INT='S',  MENSAGEM_INT='' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecINV)) + " ")
								Else
									TcSqlExec("UPDATE SGINV010 SET B7_MSEXP=' ' ,STATUS_INT='I',  MENSAGEM_INT='' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecINV)) + " ")
								EndIf
								
								//TcSetConn(_nTcConn1)
								
								SB2->(DbSetOrder(1))
								If SB2->(DbSeek( Padr(cFilINV, TamSX3("D3_FILIAL")[1]) + Padr(cCodAux, TamSX3("D3_COD")[1]) + Padr(cLocAux, TamSX3("D3_LOCAL")[1]) ))
									RecLock("SB2", .F.)
										SB2->B2_DINVENT := dDtaAux - 1
									SB2->( MsUnlock() ) // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
									SB2->( fkCommit() ) // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								EndIf
		
							EndIf
						
						EndIf

						//TcSetConn(_nTcConn1)

					EndIf

					/*Fecha o Alias da query após já utilizá-la*/
					
				EndIf
				
				/*
					SB7 - Index 01
					B7_FILIAL, B7_DATA, B7_COD, B7_LOCAL, B7_LOCALIZ, B7_NUMSERI, B7_LOTECTL, B7_NUMLOTE, B7_CONTAGE, R_E_C_N_O_, D_E_L_E_T_
				*/
				/*Posiciona no item do SB7 para que no execauto não se perca*/			
				SB7->(dbSetOrder(1))
				SB7->(dbSeek( Padr(cFilINV, TamSX3("B7_FILIAL")[1]) + Padr(DTOS(dDtaAux), TamSX3("B7_DATA")[1]) + Padr(cCodAux, TamSX3("B7_COD")[1]) + Padr(cLocAux, TamSX3("B7_LOCAL")[1]) ))
				
				//MSExecAuto({|x,y,z| mata270(x,y,z)}, aInvent, .T., nOpc)
				MsAguarde({|| MSExecAuto({|x,y,z| mata270(x,y,z)}, aInvent, .T., nOpc) },"Execauto MATA270","Efetuando inventário... " + cCodAux )

				If lMsErroAuto
	
					lRet := .F.

					aErroLog:=GetAutoGrLog()
	//				cErro:=Alltrim(aErrolog[1])
					For k:=1 to Len(aErroLog)
						If "INVALIDO" $ UPPER (aErroLog[k])
							cErro+= Alltrim(aErroLog[k])
						EndIf
					Next
					
					U_CCSGrvLog(cErro, "INV", nRecINV, 3, cFilINV)
					
					_MsgMotivo += cErro
					
					//TcSetConn(_nTcConn2)
					If lEstorno
						TcSqlExec("UPDATE SGINV010 SET B7_MSEXP='" + DTOS(dData) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecINV)) + " ")
					Else
						TcSqlExec("UPDATE SGINV010 SET B7_MSEXP='" + DTOS(dData) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecINV)) + " ")
					EndIf

					// @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
					DisarmTransaction()
					//Break // Reabilitar apenas se o Begin Transaction estiver habilitado!
					//
					
				Else
					
					If !lEstorno

						/*Efetua o processamento de todos os movimentos relacionados ao inventário (Acerto de Inventário)*/
						dDataBase := dDtaAux
						
						lMsErroAuto := .F.
						
						/*
							MATA340 - Processa Acerto de Inventário ( < ExpL01>, < ExpC01>, < ExpL02> )
						
							- ExpL01: Lógico - Variável lógica que determina se a execução da função é originada de rotina automática. Conteúdo deve ser (.T.)	X	
							- ExpC01: Caracter - Variável do tipo caracter que informa o código do inventário que deverá ser processado o acerto (B7_DOC)	X	
							- ExpL02: Lógico - Variável lógica para definir se o processamento deverá ser executado apenas para o registro previamente 
												posicionado na tabela SB7, correspondente ao código de inventário desejado (.T.) ou se deverá ser processada 
												para todos os itens que compreedem o código de inventário informado (.F.)
						*/
						//MSExecAuto({|x,y,z| mata340(x,y,z)}, .T., cDocAux, .T.)
						MsAguarde({|| MSExecAuto({|x,y,z| mata340(x,y,z)}, .T., cDocAux, .T.) },"Execauto MATA340","Processando inventário... " + cDocAux )
						
						If lMsErroAuto
				
							lRet := .F.
						
							aErroLog:=GetAutoGrLog()
							cErro:=Alltrim(aErrolog[1])
							For k:=1 to Len(aErroLog)
								If "INVALIDO" $ UPPER (aErroLog[k])
									cErro+= Alltrim(aErroLog[k])
								EndIf
							Next
						
							U_CCSGrvLog(cErro, "INV", nRecINV, 3, cFilINV)
							
							_MsgMotivo += cErro
							
							//TcSetConn(_nTcConn2)
							TcSqlExec("UPDATE SGINV010 SET B7_MSEXP='" + DTOS(dData) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + AllTrim(Str(nRecINV)) + " ")			

							// @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
							DisarmTransaction()
							//Break // Reabilitar apenas se o Begin Transaction estiver habilitado!
							//

						Else
						
							/*Amarra o item do SD3 ao inventário devido ao acerto de inventário(mata340) ter sido gerado*/
							If DTOS(SD3->D3_EMISSAO) == DTOS(dDtaAux) .AND. ALLTRIM(SD3->D3_DOC) == 'INVENT' .AND. ALLTRIM(SD3->D3_COD) == ALLTRIM(cCodAux) .AND.; 
								ALLTRIM(SD3->D3_LOCAL) == ALLTRIM(cLocAux) .AND. SD3->D3_FILIAL == cFilINV
								
								RecLock("SD3", .F.)
									SD3->D3_RECORI := ALLTRIM( StrZero(nRecINV, 10) )
								SD3->( MsUnlock() ) // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								SD3->( fkCommit() ) // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

							EndIf
	//						TcSqlExec("UPDATE " + RetSqlName("SD3") + " SET D3_RECORI='" + ALLTRIM( StrZero(nRecINV, 10) ) + "'  WHERE D3_EMISSAO='" + DTOS(dDtaAux) + "' AND D3_DOC='INVENT' AND D3_COD='" + cCodAux + "' AND D3_LOCAL ='" + cLocAux + "' AND D3_FILIAL='" + cFilINV + "' ")

							//TcSetConn(_nTcConn2)
							TcSqlExec("UPDATE SGINV010 SET B7_MSEXP='" + DTOS(dData) + "' ,STATUS_INT='S',  MENSAGEM_INT='' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecINV)) + " ")

						EndIf
						
					EndIf

				EndIf
			
			//End Transaction // analiseFWNM

		EndIf

		MsUnlockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

		//TcSetConn(_nTcConn2)
		INV->(DbSkip())

	EndDo
	
	INV->(DbCloseArea())
	
	////TcUnLinknknk(_nTcConn2)
	
	//TcSetConn(_nTcConn1) //ajuste fabricio 06/03/18
	
	MsUnlockAll() //ajuste fabricio 06/03/18

	cFilAnt := cFilBkp

	RestArea(aArea)
	
Return lRet

//					 F	U	N	Ç	Ã	O			F	O	R	A		D	E		U	S	O 
/*{Protheus.doc} User Function ADFIS010P
	Função usada para integração de OP/Consumo/Produção – Exclusão e cancelamento
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@version 01
*/

User Function ADFIS010P(cEmp, cFil, cJobFile)

	Local aArea 	:= GetArea()	/* Pega a Area corrente das posiçoes nas tabelas do Protheus */
	Local aCampos	:= {}			/* Variável para guardar os valores corrente da tabela REQ para serem processados no ExecAuto */
	Local aErroLog  := ""			/* Variável para guardar o array com log de erro corrente caso o ExecAuto não tenha funcionado */

	Local cCod		:= ""			/* Variável auxiliar para guardar o valor do código do produto corrente da tabela REQ */
	Local cErro		:= ""			/* Variável para guardar o texto com log de erro corrente caso o ExecAuto não tenha funcionado */
	Local cFil		:= ""			/* Variável auxiliar para guardar o valor da filial corrente da tabela REQ */
	Local cFilBck 	:= cFilAnt		/* Guarda a filial corrente no sistema para backup já que será alterado a variável publica cFilAnt */
	Local cLocal	:= ""			/* Variável auxiliar para guardar o valor do local do produto corrente da tabela REQ */
	Local cFilREQ	:= ""			/* Variável auxiliar para guardar o valor da filial corrente da tabela REQ para ser gravado no log de processamento */
	Local cMsgError := ""			/* Variável para guardar a mensagem de erro caso não consiga criar a conexão no banco do Protheus e o intermediário */
	Local cOp		:= ""			/* Variável auxiliar para guardar o valor do código da OP corrente da tabela REQ */
	Local cQry		:= ""			/* Variável para guardar a query criada*/

	Local dData		:= DDATABASE	/* Data corrente no sistema no formato yyyymmdd */

	Local lLogCanc  := .F.
	Local lRet     	:= .T.			/* Guarda se conseguiu criar a conexão no banco do Protheus e o intermediário ou não */
	Local lTemOp	:= .F.			/* Variável auxiliar para guardar o possue OP na tabela SD3 do Protheus */

	Local nRecReq	:= ""			/* Variável auxiliar para guardar o valor do recno do item corrente da tabela REQ */

	Private lMsErroAuto := .F. 		/* Variável padrão do execauto para captura de processamento efetuado com sucesso ou não */

	Default cEmp 	:= ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cFil 	:= ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cJobFile:= ""	/*Descrição do parâmetro conforme cabeçalho*/

	/*Cria a conexão no banco intermediário e Protheus para ser usada posteriormente*/
	// TcConType("TCPIP")
	// If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
	// 	lRet     := .F.
	// 	cMsgError := "Não foi possível  conectar ao banco Protheus"
	// 	MsgInfo("Não foi possível  conectar ao banco produção, verifique com administrador","ERROR")
		
	// EndIf
	
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	lRet     := .F.
	// 	cMsgError := "Não foi possível  conectar ao banco integração"
	// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")
		
	// EndIf
	
	//TcSetConn(_nTcConn2)
	
	/* Conecta no banco intermediário SGMOV010 e gera a query para ser executada e pegar os valores */
	cQry:="SELECT * FROM SGREQ010 (NOLOCK) WHERE D3_MSEXP='' AND OPERACAO_INT = 'E' "
//	cQry:="SELECT * FROM SGREQ010 WHERE D3_MSEXP='' AND OPERACAO_INT = 'E' AND D3_FILIAL= '" + cFil + "' ORDER BY D3_FILIAL, D3_OP"
	
	If !_xJob
		cQry += " AND D3_FILIAL BETWEEN '" + cFil + "' AND '" + cFil + "' AND D3_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
//		cQry += " AND D3_FILIAL BETWEEN '" + cIniFil + "' AND '" + cFimFil + "' AND D3_EMISSAO BETWEEN '" + _aDatas[1] + "' AND '" + _aDatas[2] + "' "
	EndIf
	
	cQry += " ORDER BY D3_FILIAL, D3_OP"
	
	DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), "REQSD3", .F., .T.)
	TcSetField( "REQSD3", "D3_EMISSAO"	, "D", 8, 0 )
	TcSetField( "REQSD3", "D3_DTLANC"	, "D", 8, 0 )
	TcSetField( "REQSD3", "D3_DTVALID"	, "D", 8, 0 )
	
	
	DbSelectArea("REQSD3")
	While !Eof()
		
		lLogCanc := .T.
		cOp    	 := REQSD3->D3_OP
		
		While !Eof() .And. REQSD3->D3_OP == cOp
			
			cFilREQ := REQSD3->D3_FILIAL
			nRecREQ := REQSD3->R_E_C_N_O_
			cCod   	:= REQSD3->D3_COD
			cLocal  := IIf( ALLTRIM(REQSD3->D3_FILIAL) == "04", SubStr(ALLTRIM(REQSD3->D3_CC),3,2), RetFldProd(REQSD3->D3_COD, "B1_LOCPAD"))
			cLocal  := IIf(Empty(cLocal), "05", cLocal)
			
			/* muda de filial 04 para 03 pq o matarial esta na 03 */
			If REQSD3->D3_FILIAL == "04"
				cFilAnt := "03"
			Else
				cFilAnt := REQSD3->D3_FILIAL
			EndIf
			
			cFilReq := cFilAnt
			
			//TcSetConn(_nTcConn1)
			
			DbSelectArea("SD3")
			DbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
			DbSeek(cFilREQ + cOp + cCod + cLocal)
			If Eof()
				cErro := "HELP: Requisição de MP nao Encontrada para ser Cancelada D3_FILIAL+D3_OP+D3_COD+D3_LOCAL->" + cFilREQ + "-" + cOp + "-" + cCod +"-" + cLocal
				
				U_CCSGrvLog(cErro, "REQ", nRecREQ, 5, cFilREQ)
				
				//TcSetConn(_nTcConn2)
				TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " ")
			
			Else
				lTemOp := .F.
				If SD3->D3_ESTORNO == 'S'
					While !Eof() .And. (xFilial("SD3") + cOp + cCod + cLocal) == D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
						If SD3->D3_ESTORNO <> 'S'
							ltemOp := .T.
							Exit
						EndIf
						dbSkip()
					EndDo
				Else
					lTemOp := .T.
				EndIf
				
				If !lTemOP
		
					cErro := "HELP: Requisição de MP nao Encontrada para ser Cancelada D3_FILIAL+D3_OP+D3_COD+D3_LOCAL->" + cFilREQ + "-" + cOp + "-" + cCod + "-" + cLocal
				
					U_CCSGrvLog(cErro, "REQ", nRecREQ, 5, cFilREQ)
				
					//TcSetConn(_nTcConn2)
					TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM(STR(nRecREQ)) + " ")
		
				Else
		
					aCampos:={}
					AADD(aCampos, {"D3_FILIAL"	,SD3->D3_FILIAL		, Nil})
					AADD(aCampos, {"D3_COD"		,SD3->D3_COD		, Nil})
					AADD(aCampos, {"D3_DOC"		,SD3->D3_DOC		, Nil})
					AADD(aCampos, {"D3_QUANT"	,SD3->D3_QUANT		, Nil})
					AADD(aCampos, {"D3_LOCAL"	,SD3->D3_LOCAL		, Nil})
					AADD(aCampos, {"D3_EMISSAO"	,SD3->D3_EMISSAO	, Nil})
					AADD(aCampos, {"D3_CC"		,SD3->D3_CC			, Nil})
					AADD(aCampos, {"D3_OP"		,SD3->D3_OP			, Nil})
					AADD(aCampos, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ		, Nil})
					
					lMsErroAuto:=.f.

					If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s				
					
						//Begin Transaction // analiseFWNM
						
							//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5) // Cancelamento
							MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5) },"Execauto MATA240","Estornando movimentos... " + SD3->D3_OP + " " + SD3->D3_COD )
							
							If lMsErroAuto
						
								lLogCanc := .F.
								
								aErroLog:=GetAutoGrLog()
								cErro:=Alltrim(aErrolog[1])
								For k:=1 to Len(aErroLog)
									If "INVALIDO" $ UPPER (aErroLog[k])
										cErro+= Alltrim(aErroLog[k])
									EndIf
								Next
								U_CCSGrvLog(cErro, "REQ", nRecREQ, 5, cFilREQ)
								
								//TcSetConn(_nTcConn2)
								TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecREQ))+" ")
							
								// @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
								DisarmTransaction() 
								//Break // Reabilitar apenas se o Begin Transaction estiver habilitado!
								//

							Else
							
								//TcSetConn(_nTcConn2)
								TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_="+AllTrim(Str(nRecREQ))+" ")
							
							EndIf
						
						//End Transaction // analiseFWNM

						MsUnLockAll() // @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
					
					EndIf

				EndIf

			EndIf

			//TcSetConn(_nTcConn2)
			DbSelectArea("REQSD3")
			DbSkip()

		EndDo
		
		/* Varre os movimentos de Requisição de MOD para a OP e os Cancela */
		lLogCanc := InterMODe(cOp, cEmp, cFilAnt, cJobFile)
		
		If lLogCanc
//			 Ver se vai fazer mais alguma coisa "poderia varre o D3 para ver se sobrou algum movimento de requisição" 
		EndIf
		
		/* ja esta posicionado no Skip do cAliasReq */
		//TcSetConn(_nTcConn2)
		DbSelectArea("REQSD3")

	EndDo
	
	dbSelectArea("REQSD3")
	DbCloseArea()
	
	RestArea(aArea)
	
	////TcUnLinknknk(_nTcConn1)
	////TcUnLinknknk(_nTcConn2)

Return lRet

//					 F	U	N	Ç	Ã	O			F	O	R	A		D	E		U	S	O
/*{Protheus.doc} User Function ADFIS006PB
	Função usada para integração da OP/Consumo/Producao - Exclusao e Cancelamento MOD
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@version 01
*/

Static Function ADFIS006PB(cOp, cEmp, cFil, cJobFile)

	Local aCampos	:= {} 	/* Variável para guardar os valores corrente da tabela REQ para serem processados no ExecAuto */
	Local aErroLog	:= {} 	/* Variável para guardar o array com log de erro corrente caso o ExecAuto não tenha funcionado */

	Local cErro		:= ""	/* Variável para guardar o texto com log de erro corrente caso o ExecAuto não tenha funcionado */
	Local cFilBkp   := ""	/* Guarda a filial corrente no sistema para backup já que será alterado a variável publica cFilAnt */

	Local lLogCanc  := .T.	/* Variável para controle se o processo ocorreu corretamente ou não */

	Local nRecSD3	:= 0	/* Código do RECNO no SD3 que será posicionado */

	Private lMsErroAuto := .F.	/* Variável padrão do execauto para captura de processamento efetuado com sucesso ou não */

	Default cOP 	:= "" 	/*Descrição do parâmetro conforme cabeçalho*/
	Default cEmp 	:= ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cFil 	:= ""	/*Descrição do parâmetro conforme cabeçalho*/
	Default cJobFile:= ""	/*Descrição do parâmetro conforme cabeçalho*/

	//TcSetConn(_nTcConn1)
	
	cFilBkp := cFilAnt
	cFilAnt := cFil
	
	dbSelectArea("SD3")
	dbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
	dbSeek(cFil + cOp )
	If Eof()
	//		Não vai fazer nada pois pode nao ter requisições de MOD	e todas as requisições para a OP podem ja ter sido canceladas
	Else
	
		While !Eof() .And. cFil == SD3->D3_FILIAL .And. SD3->D3_OP == cOp
			
			If !IsProdMOD(SD3->D3_COD) .Or. SD3->D3_ESTORNO == "S" .Or. SubStr(SD3->D3_CF,1,2) == "PR"
				dbSkip()
				Loop
			EndIf
			
			nRecSD3 := Recno()
			aCampos:={}
			
			AADD(aCampos, {"D3_FILIAL"	,SD3->D3_FILIAL		, Nil})
			AADD(aCampos, {"D3_COD"		,SD3->D3_COD		, Nil})
			AADD(aCampos, {"D3_QUANT"	,SD3->D3_QUANT		, Nil})
			AADD(aCampos, {"D3_LOCAL"	,SD3->D3_LOCAL		, Nil})
			AADD(aCampos, {"D3_EMISSAO"	,SD3->D3_EMISSAO	, Nil})
			AADD(aCampos, {"D3_CC"		,SD3->D3_CC			, Nil})
			AADD(aCampos, {"D3_OP"		,SD3->D3_OP			, Nil})
			AADD(aCampos, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ		, Nil})
			
			lMsErroAuto:=.f.
			
			If !FwInTTSBreak() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
			
				//Begin Transaction // analiseFWNM
				
					//MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5) // Cancelamento
					MsAguarde({|| MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5) },"Execauto MATA240","Estornando movimentos... " + SD3->D3_OP + " " + SD3->D3_COD )

					If lMsErroAuto

						lLogCanc := .F.
						
						aErroLog := GetAutoGrLog()
						cErro := Alltrim(aErrolog[1])
						
						For k:=1 to Len(aErroLog)
							If "INVALIDO" $ UPPER (aErroLog[k])
								cErro += ALLTRIM(aErroLog[k])
							EndIf
						Next
						U_CCSGrvLog(cErro, "REQ", nRecREQ, 5, cFilREQ) //TODO: VERIFICAR PORQUE EXISTEM VARIÁVEIS QUE NÃO EXISTEM NA FUNÇÃO 
						
						//TcSetConn(_nTcConn2)
						TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='" + cErro + "' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecREQ) ) + " ") //TODO: VERIFICAR PORQUE EXISTEM VARIÁVEIS QUE NÃO EXISTEM NA FUNÇÃO 

						// @history ticket   10248 - Fernando Macieira     - 02/03/2021 - Revisão das rotinas de apontamento de OP´s
						DisarmTransaction() 
						//Break // Reabilitar apenas se o Begin Transaction estiver habilitado!
						//

					Else
				
						//TcSetConn(_nTcConn2)
						TcSqlExec("UPDATE SGREQ010 SET D3_MSEXP='" + DTOS(DDATABASE) + "' ,STATUS_INT='S' WHERE R_E_C_N_O_=" + ALLTRIM( STR(nRecREQ) ) + " ") //TODO: VERIFICAR PORQUE EXISTEM VARIÁVEIS QUE NÃO EXISTEM NA FUNÇÃO 
				
					EndIf
			
				//End Transaction // analiseFWNM

				MsUnLockAll() // @history ticket 10248 - Fernando Macieira - 02/03/2021 - Revisão das rotinas de apontamento de OP´s

			EndIf
			
			dbSelectArea("SD3")
			go nRecSD3
			dbSkip()

		EndDo

	EndIf
	
	cFilAnt := cFilBkp

Return(lLogCanc)

/*{Protheus.doc} User Function AjustaSX1
	Função para criar as perguntas que serão apresentadas em tela no SX1
	@type  Function
	@author Leonardo Rios
	@since 14/12/16
	@version 01
*/

Static Function AjustaSX1(cPerg)

	/* < cGrupo>, < cOrdem> , < cPergunt>     	, < cPergSpa>	, < cPergEng>	, < cVar> , < cTipo>, < nTamanho>, [ nDecimal], [ nPreSel]	, < cGSC>, [ cValid], [ cF3], [ cGrpSXG], [ cPyme]	, < cVar01> , [ cDef01]  , [ cDefSpa1], [ cDefEng1] , [ cCnt01] , [ cDef02] , [ cDefSpa2], [cDefEng2], [cDef03] , [cDefSpa3], [cDefEng3], [cDef04]	, [cDefSpa4], [cDefEng4], [cDef05]  , [cDefSpa5], [cDefEng5]  , [aHelpPor], [aHelpEng], [aHelpSpa], [cHelp] ) */
	PutSx1( cPerg	,  "01"		, "Filial de   "	, "Filial de   ", "Filial de   ", "mv_cha",  "C"	, 	 2		 , 	 0		  , 	1		, 	"G"	 , 	 ""		, 	""	, 	 ""		, 	 ""		, "mv_par01", ""		 , 	""		  , ""			, 	""		,  ""		,  ""		 ,  ""		 ,  ""		, ""		, ""		, ""		, ""		, ""		, ""		, ""		, "")
	PutSx1( cPerg	,  "02"		, "Filial ate  "	, "Filial ate  ", "Filial ate  ", "mv_chb",  "C"	, 	 2		 , 	 0		  , 	1		, 	"G"	 , 	 ""		, 	""	, 	 ""		, 	 ""		, "mv_par02", ""		 , ""		  , ""			, 	""		,  ""		,  ""		 ,  ""		 ,  ""		, ""		, ""		, ""		, ""		, ""		, ""		, ""		, "")
	PutSx1( cPerg	,  "03"		, "Periodo de  "	, "Periodo de  ", "Periodo de  ", "mv_chc",  "D"	, 	 8		 , 	 0		  , 	1		, 	"G"	 , 	 ""		, 	""	, 	 ""		, 	 ""		, "mv_par03", ""		 , ""		  , ""			, 	""		,  ""		,  ""		 ,  ""		 ,  ""		, ""		, ""		, ""		, ""		, ""		, ""		, ""		, "")
	PutSx1( cPerg	,  "04"		, "Periodo ate "	, "Periodo ate ", "Periodo ate ", "mv_chd",  "D"	, 	 8		 , 	 0		  , 	1		, 	"G"	 , 	 ""		, 	""	, 	 ""		, 	 ""		, "mv_par04", ""		 , ""		  , ""			, 	""		,  ""		,  ""		 ,  ""		 ,  ""		, ""		, ""		, ""		, ""		, ""		, ""		, ""		, "")

Return
