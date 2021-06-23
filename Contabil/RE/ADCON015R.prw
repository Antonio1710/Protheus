#Include "Protheus.ch"
#Include "Fileio.ch"
#Include "TopConn.ch"
#Include "Rwmake.ch"

/*/{Protheus.doc} User Function ADCON015R
	(Relatorio Cadastro Usuario X Centro de Custo)
	@type  Function
	@author ADRIANO SAVOINE
	@since 23/06/2020
	@version 01
	@history Chamado: 058771 - 23/06/2020 - ADRIANO SAVOINE - VERIFICAR OS USUARIOS QUE TEM ACESSO PARA GERAR REQUISIÇÃO NO ALMOXARIFADO CADASTRADOS PELA ROTINA ADCON008P() QUE PERMITE GERAR PRE REQUISIÇÕES.
	@history Chamado:  12350 - 06/05/2021 - Rodrigo Romao - Nova coluna para mostrar se o usuario esta ativo ou inativo

	/*/

User Function ADCON015R()

	// Declaração de variáveis.

	Private aSays			:={}
	Private aButtons		:={}
	Private cCadastro		:="Relatório Cadastro Usuario X Centro de Custo"
	Private nOpca			:=0
	Private cPerg			:= 'ADCON015R'
	Private aUsrStatus		:= {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	MontaPerg()

	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio Cadastro Usuario X Centro de Custo" )

	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADCON015R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})

	FormBatch(cCadastro, aSays, aButtons)

Return Nil

Static Function ComADCON015R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private oExcel      := FWMSEXCEL():New()
	Private oMsExcel
	Private cPlanilha   := "Relatorio Cadastro Usuario X Centro de Custo"
	Private cTitulo     := "Relatorio Cadastro Usuario X Centro de Custo"
	Private aLinhas     := {}

	Begin Sequence

		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") )

			MsgStop("Não Existe Excel Instalado","Função ComADCON015R(ADCON015R)")
			Break

		EndIF

		//Gera o cabeçalho.
		Cabec()

		If ! GeraExcel()
			Break

		EndIf

		Sleep(2000)
		SalvaXml()

		Sleep(2000)
		CriaExcel()

		MsgInfo("Arquivo Excel gerado!","Função ComADCON015R(ADCON015R)")

	End Sequence

Return Nil

Static Function Cabec()

	oExcel:AddworkSheet(cPlanilha)

	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Filial "						,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Colaborador  "	,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Status  "						,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Usuario "		,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Item "		        	,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"CC Inicial "        ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"CC Final"    				,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Item Inicial  " 		,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Item Final "        ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Grup. Inicial "			,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Grup. Final "	    	,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Bloqueado "		    	,1,1) // 12 L

Return Nil


Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel    := 0
	Local nTotReg		:= 0

	SqlUser()
	DBSELECTAREA("TRB")
	DBGOTOP()
	//Conta o Total de registros.
	nTotReg := Contar("TRB","!Eof()")

	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCON015R)")
		Return .F.

	EndIf

	//Atribui a quantidade de registros à régua de processamento.
	DBSELECTAREA("TRB")
	DBGOTOP()
	ProcRegua(nTotReg)
	TRB->(DbGoTop())
	While !TRB->(Eof())

		cCodUsu := Alltrim(cValToChar(TRB->PAE_CODUSR))
		IncProc("Processando Usuarios " + cCodUsu)

		nLinha  := nLinha + 1

		//===================== INICIO CRIA VETOR COM POSICAO VAZIA
		Aadd(aLinhas,{ "", ; // 01 A
		"", ; // 02 B
		"", ; // 03 C
		"", ; // 04 D
		"", ; // 05 E
		"", ; // 06 F
		"", ; // 07 G
		"", ; // 08 H
		"", ; // 09 I
		"", ; // 10 J
		"", ; // 11 K
		"" ;  // 12 L
		})
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA

		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================

		lAtivo := verificaStatusUser(TRB->PAE_CODUSR)

		aLinhas[nLinha][01] := TRB->PAE_FILIAL
		aLinhas[nLinha][02] := UsrRetName(TRB->PAE_CODUSR)
		aLinhas[nLinha][03] := IIF(lAtivo, "ATIVO","BLOQUEADO")
		aLinhas[nLinha][04] := TRB->PAE_CODUSR
		aLinhas[nLinha][05] := TRB->PAE_ITEM
		aLinhas[nLinha][06] := TRB->PAE_CCINI
		aLinhas[nLinha][07] := TRB->PAE_CCFIM
		aLinhas[nLinha][08] := TRB->PAE_ITINI
		aLinhas[nLinha][09] := TRB->PAE_ITFIM
		aLinhas[nLinha][10] := TRB->PAE_GRPINI
		aLinhas[nLinha][11] := TRB->PAE_GRPFIM
		aLinhas[nLinha][12] := TRB->PAE_MSBLQL2

		TRB->(DBSKIP())

	ENDDO

	TRB->(DbCloseArea())

	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha

		IncProc("Carregando Dados para a Planilha1 de: " + cValtochar(nExcel) + ' até: ' + cValtochar(nLinha))

		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A
		aLinhas[nExcel][02],;  // 02 B
		aLinhas[nExcel][03],;  // 03 C
		aLinhas[nExcel][04],;  // 04 D
		aLinhas[nExcel][05],;  // 05 E
		aLinhas[nExcel][06],;  // 06 F
		aLinhas[nExcel][07],;  // 07 G
		aLinhas[nExcel][08],;  // 08 H
		aLinhas[nExcel][09],;  // 09 I
		aLinhas[nExcel][10],;  // 09 J
		aLinhas[nExcel][11],;  // 10 K
		aLinhas[nExcel][12];   // 11 L
		})

	Next nExcel
	//============================== FINAL IMPRIME LINHA NO EXCEL



Return .T.


Static Function SqlUser()

	BeginSQL Alias "TRB"
			%NoPARSER%
		        SELECT PAE_FILIAL,
				PAE_CODUSR,
				PAE_ITEM,
				PAE_CCINI,
				PAE_CCFIM,
				PAE_ITINI,
				PAE_ITFIM,
				PAE_GRPINI,
				PAE_GRPFIM,
	CASE WHEN PAE_MSBLQL = '1' THEN 'SIM' ELSE 'NAO' END PAE_MSBLQL2
				FROM %Table:PAE% WITH(NOLOCK) 
				WHERE PAE_CCINI >= %EXP:MV_PAR01%
				AND PAE_CCINI <= %EXP:MV_PAR02%
				AND %Table:PAE%.D_E_L_E_T_ <> '*'
				ORDER BY PAE_CODUSR ASC

	EndSQl

Return (NIL)


Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_USUARIO_CENTRO_DE_CUSTO.XML")

Return Nil

Static Function CriaExcel()

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_USUARIO_CENTRO_DE_CUSTO.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil


/*/{Protheus.doc} verificaStatusUser
	verifica se o usuáro está ativo ou não
	@type  Static Function
	@author Rodrigo Romao
	@since 06/05/2021
	@version : 12350
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function verificaStatusUser(cUsr)
	local lAtivo 	:= .F.
	local aUser 	:= {}

	nPos := Ascan(aUsrStatus,{|x| Alltrim(x[1]) == Alltrim(cUsr)} )

	if nPos == 0
		PswOrder(1)
		If (PswSeek( Alltrim(cUsr),.T.))
			aUser		:= Pswret()
			lAtivo	:= !aUser[1][17]
			aAdd(aUsrStatus, {cUsr, lAtivo})
		EndIf
	else
		lAtivo := aUsrStatus[nPos][2]
	endif

Return lAtivo


Static Function MontaPerg()

	Private bValid := Nil
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil

	U_xPutSx1(cPerg,'01','Centro de Custo de 	           ?','','','mv_ch01','C',04,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Centro de Custo até               ?','','','mv_ch02','C',04,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	Pergunte(cPerg,.F.)

Return Nil
