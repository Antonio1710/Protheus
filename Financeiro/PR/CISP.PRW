#Include "Protheus.CH"
#Include "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CISP      ³ Autor ³ Celso Costa          ³ Data ³26/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerador de dados para CISP                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_CISP()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CISP()      

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gerador de dados para CISP')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Private                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Private _cPerg		:= "CISP  "
	Private _cPerg		:= PADR("CISP",10," ")
	Private oGeraTXT
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oGeraTxt Title OemToAnsi( "CISP - GERACAO DE ARQUIVO TEXTO" ) From 03, 00 To 126, 417 Pixel //340, 417
	
	@ 05, 01 To 25, 412
	@ 10, 05 Say "Este programa gera arquivos texto dentro dos padroes de layout da" Of oGeraTXT Pixel
	@ 20, 05 Say "Central de Informacoes Sao Paulo (CISP)." Of oGeraTXT Pixel
	
	Define SButton From 043, 105 Type 05 Action PergCISP()		Enable Of oGeraTXT Pixel
	Define SButton From 043, 140 Type 01 Action OKGeraTXT()		Enable Of oGeraTXT Pixel
	Define SButton From 043, 175 Type 02 Action oGeraTXT:End()	Enable Of oGeraTXT Pixel
	
	Activate MsDialog oGeraTXT Centered

Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PergCISP  ³ Autor ³ Celso Costa          ³ Data ³26/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pergunte                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PergCISP()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PergCISP()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida/cria Pergunte                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ValidPerg()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pergunte                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte( _cPerg, .T. )
	
Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OKGeraTXT ³ Autor ³ Celso Costa          ³ Data ³26/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerador arquivo texto                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OKGeraTXT()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function OKGeraTXT()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _cQuery	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private _nHdl	:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona registros                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	             
	
	If mv_par01 == 01
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Clientes                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		
		_cQuery := "SELECT CASE WHEN A1_PESSOA = 'J' THEN '1' ELSE '2' END TIPO, "
		_cQuery += "'0138' ASSOCIADO, "
		_cQuery += "RIGHT(('00000000000000000000'+RTRIM(A1_CGC)),20) CPFCNPJOUTROS, "
		_cQuery += "LEFT((A1_NOME+SPACE(60)),60) RZSOCNOME, "
		_cQuery += "SPACE(1) SEXO, "
		_cQuery += "'00000000' DTNASCFUND, "
		_cQuery += "SPACE(10) ESTADOCIVIL, "
		_cQuery += "LEFT((A1_END+SPACE(60)),60) ENDERECO, "
		_cQuery += "LEFT((A1_BAIRRO+SPACE(30)),30) BAIRRO, "
		_cQuery += "LEFT((A1_MUN+SPACE(40)),40) CIDADE, "
		_cQuery += "A1_EST UF, "
		_cQuery += "SPACE(20) PAIS, "
		_cQuery += "SPACE(20) REGIAO, "
		_cQuery += "A1_CEP CEP, "
		_cQuery += "LEFT((RTRIM(A1_DDD)+A1_TEL+SPACE(30)),30) TELEFONE, "
		_cQuery += "LEFT((A1_FAX+SPACE(30)),30) FAX, "
		_cQuery += "LEFT((RTRIM((CONVERT(CHAR,(YEAR(GETDATE())))))+RIGHT(('00'+RTRIM(CONVERT(CHAR,MONTH(GETDATE())))),2)+RIGHT('00'+RTRIM(CONVERT(CHAR,DAY(GETDATE()))),2)),8) DATAGERACAO, "
		_cQuery += "'00000000' ATIVECONMICA, "
		_cQuery += "LEFT((A1_EMAIL+SPACE(50)),50) EMAIL, "
		_cQuery += "SPACE(60) ORGEMISSOR, "
		_cQuery += "'00000000' DTEXPEDICAO, "
		_cQuery += "SPACE(60) FILIACAO "
		_cQuery += "FROM " + RetSqlName( "SA1" ) + " "
		_cQuery += "WHERE "
	//	_cQuery += "A1_MSBLQL = '2' AND "
		_cQuery += "A1_EST <> 'EX' AND D_E_L_E_T_ = ' ' "
		_cQuery += iif(MV_PAR03 = 3,"","AND A1_PESSOA = '"+iif(MV_PAR03=1,"J","F")+"'")
		
	ElseIf mv_par01 == 02
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fornecedores                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		_cQuery := "SELECT RIGHT(('00000000000000'+RTRIM((A2_CGC))),14) CPFCNPJOUTROS, "
		_cQuery += "'|' PIPELINE, A2_EST UF "
		_cQuery += "FROM " + RetSqlName( "SA2" ) + " "
		_cQuery += "WHERE A2_MSBLQL = '2' "
		//incluido por Adriana para retirar fornecedores com CNPJ zerado e exterior 
		_cQuery += "AND A2_EST <> 'EX' AND A2_CGC >= '00000000281182' AND D_E_L_E_T_ = ' '" //00000000281182 cnpj do bb o primeiro valido
		_cQuery += "AND A2_ULTCOM  >= CONVERT(VARCHAR(4),(YEAR((GETDATE() - 180)))) + CASE WHEN LEN(MONTH((GETDATE() - 180))) = 1 then '0' + CONVERT(VARCHAR(2),(MONTH((GETDATE() - 180))))  else CONVERT(VARCHAR(2),(MONTH((GETDATE() - 180)))) END + '01'" // WiLL chamado 030162
	
	// **************************************** INICIO ALTERACAO WILL CHAMADO 015630 *************** //
	ElseIf mv_par01 == 03
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Positivas                                                    ³	_cQuery += "WHERE E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND E1_CLIENTE = UCCLI AND E1_LOJA = UCLJ " luciano 16 10 2014
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		ALERT("Geração do arquivo positivas foi desativa, favor contactar o administrador do sistema")
		RETURN(NIL)
		
		SQLGERAL()
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo temporario                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	If mv_par01 < 03
	
		_cQuery := ChangeQuery( _cQuery )
		
		MsAguarde( {|| dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "TMPCISP", .F., .T. ) }, "Selecionando registros ..." )
		
	ENDIF
	// **************************************** FINAL ALTERACAO WILL CHAMADO 015630 *************** //
	dbSelectArea( "TMPCISP" )   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nHdl := FCreate( AllTrim( mv_par02 ) )
	
	If _nHdl == -1
		MsgAlert( "O Arquivo de nome " + AllTrim( mv_par02 ) + " nao pode ser executado! Verifique os parametros.", "Atencao" )
		Return ( Nil )
	EndIf
	
	Processa( {|| RunCont() }, "Processando..." )

Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RunCont   ³ Autor ³ Celso Costa          ³ Data ³26/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerador arquivo texto                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RunCont()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunCont()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nTamLin
	Local cLin
	Local cCPO
	Local TempCampos	:= TMPCISP->( dbStruct() )
	Local _nCountStr	:= 00
	Local ValCampo		:= ""
	Local _cEOL 	   := Chr( 13 ) + Chr( 10 )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua( TMPCISP->( LastRec() ) )
	
	While TMPCISP->( !Eof() )
	
		IncProc()
		
		cLin := ""
		
		For _nCountStr := 01 To Len( TempCampos )
	
			ValCampo := TempCampos[ _nCountStr, 01 ]
	
			cLin += &ValCampo
	
		Next
	
		cLin += _cEOL
	
		If FWrite( _nHdl, cLin, Len( cLin ) ) != Len( cLin )
	
			If !MsgAlert( "Ocorreu um erro na gravacao do arquivo. Continua?", "Atencao" )
				Exit
			EndIf
			
		EndIf
	
		TMPCISP->( dbSkip() )
	
	EndDo
	
	TMPCISP->( dbCloseArea() )
	
	FClose( _nHdl )
	
	oGeraTXT:End()

Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ValidPerg ³ Autor ³ Celso Costa          ³ Data ³26/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Pergunte                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ValidPerg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea	:= GetArea()
	Local _aRegs	:= {}
	Local i,j
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria registros de pergunta                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( _aRegs, {_cPerg,"01","LayOut"		,"","","mv_ch1","N",01,00,00,"C","","","Clientes","","","","","Fornecedores","","","","","Positivas","","","","","","","","","","","","","","","S","","",""} )
	Aadd( _aRegs, {_cPerg,"02","Arquivo"	,"","","mv_ch2","C",30,00,00,"G","","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""} )
	Aadd( _aRegs, {_cPerg,"03","Tipo"		,"","","mv_ch3","N",01,00,00,"C","","","Pessoa Juridica","","","","","Pessoa Fisica","","","","","Ambos","","","","","","","","","","","","","","","S","","",""} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida/Cria Pergunte                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SX1" )
	dbSetOrder( 01 )
	
	For i := 01 To Len( _aRegs )
	
		If !dbSeek( _cPerg + _aRegs[ i, 02 ] )
	
			RecLock( "SX1", .T. )
	
			For j := 01 To FCount()
			
				If j <= Len( _aRegs[ i ] )
					FieldPut( j, _aRegs[ i, j ] )
				EndIf
	
			Next
	
			SX1->( MsUnlock() )
	
		EndIf
	
	Next
	
	RestArea( _aArea )

Return ( Nil ) 

Static Function SQLGERAL()

    BeginSQL Alias "TMPCISP"
			%NoPARSER%
			SELECT * FROM 
			( 
			SELECT CASE WHEN A1_PESSOA = 'J' THEN '1' ELSE '2' END AA , //TIPO
			       '0138' AB , //ASSOCIADO
			       CASE WHEN A1_PESSOA = 'J' THEN (RIGHT(('00000000000000000000'+RTRIM((LEFT(A1_CGC,8)))),20)) ELSE (RIGHT(('00000000000000000000'+RTRIM((A1_CGC))),20)) END AC, //CPFCNPJOUTROS
			       //LEFT((RTRIM((CONVERT(CHAR,(YEAR(GETDATE())))))+RIGHT(('00'+RTRIM(CONVERT(CHAR,MONTH(GETDATE())))),2)+RIGHT('00'+RTRIM(CONVERT(CHAR,DAY(GETDATE()))),2)),8) AD , //DATAINFO
			       CONVERT(VARCHAR(8), (GETDATE()), 112) AD , //DATAINFO
			       MIN(RIGHT('00000000'+RTRIM(A1_DTCAD),8)) AE, //DATACAD
			       MAX(RIGHT('00000000'+RTRIM(A1_ULTCOM),8)) AF, //ULTCOM 
			       RIGHT(('0000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))))))),13) + '00'  AG, //VALULTCOM                                      
			       //CASE when SUM(E1_SALDO) >= SUM(A1_VLACUMU) AND MAX(A1_ULTCOM) >= MAX(A1_DTACUMU) then MAX(RIGHT('00000000'+RTRIM(A1_ULTCOM),8)) Else MAX(RIGHT('00000000'+RTRIM(A1_DTACUMU),8)) END AS AH , //DTMAIORACUM
			       RIGHT('00000000'+RTRIM((CASE WHEN (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END)  <= CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(SUM(E1_SALDO),0))) THEN /*VLDEBTOTAL*/ CONVERT(VARCHAR(8), (GETDATE()), 112) /*VLDEBTOTAL*/ ELSE (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN MAX(A1_ULTCOM) ELSE MAX(A1_DTACUMU) END) END)),8) AS AH,
			       //CASE WHEN MAX(A1_VLACUMU) = 0 THEN '000000000000000' ELSE (RIGHT('0000000000000'+RTRIM((CASE WHEN (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END)  <= CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(SUM(E1_SALDO),0))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(SUM(E1_SALDO),0))) ELSE (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END) END)),13) + '00') END AS AI,
			       //CASE WHEN MAX(A1_VLACUMU) = 0 THEN '000000000000000' ELSE (RIGHT('0000000000000'+RTRIM((CASE WHEN (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END)  <= CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(SUM(E1_SALDO),0))) THEN /*VLDEBTOTAL*/ RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(((ROUND(SUM(CASE WHEN E1_VENCREA >= (RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2)) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))+((ROUND(SUM(CASE WHEN E1_VENCREA <= ((RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2))-5) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))) ))*100)))))),13) /*VLDEBTOTAL*/ ELSE (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END) END)),13) + '00') END AS AI,
			       CASE WHEN MAX(A1_VLACUMU) = 0 THEN '000000000000000' ELSE (RIGHT('0000000000000'+RTRIM((CASE WHEN (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END)  <= CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(SUM(E1_SALDO),0))) THEN /*VLDEBTOTAL*/ RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(((ROUND(SUM(CASE WHEN E1_VENCREA >= CONVERT(VARCHAR(8), (GETDATE()), 112) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))+((ROUND(SUM(CASE WHEN E1_VENCREA <= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))) ))*100)))))),13) /*VLDEBTOTAL*/ ELSE (CASE WHEN CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) <=  CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) THEN CONVERT(NUMERIC,CONVERT(NUMERIC,(ROUND(MAX((CASE WHEN E1_EMISSAO = A1_ULTCOM THEN E1_VALOR ELSE 0 END)),0)))) ELSE CONVERT(NUMERIC,CONVERT(NUMERIC,ROUND(MAX(A1_VLACUMU),0))) END) END)),13) + '00') END AS AI,
			       //RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(((ROUND(SUM(CASE WHEN E1_VENCREA >= (RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2)) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))+((ROUND(SUM(CASE WHEN E1_VENCREA <= ((RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2))-5) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))) ))*100)))))),15) AJ, //VLDEBTOTAL
			       RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(((ROUND(SUM(CASE WHEN E1_VENCREA >= CONVERT(VARCHAR(8), (GETDATE()), 112) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))+((ROUND(SUM(CASE WHEN E1_VENCREA <= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))) ))*100)))))),15) AJ, //VLDEBTOTAL
			       RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(MAX(A1_LC))*100)))))),15) AK, //LIMITE
			       CASE WHEN SUM(CONVERT(INT,E1_SALDO)) = 0 THEN '000000' ELSE (RIGHT('0000'+RTRIM(CONVERT(INT,SUM(E1_SALDO * CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_BAIXA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_BAIXA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_BAIXA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_BAIXA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103))) END  ) / SUM(CONVERT(INT,E1_SALDO)))),4)  + '00') END AS AL, //MEDIAPONDERATRASO	
				   CASE WHEN SUM(CONVERT(INT,E1_SALDO)) = 0 THEN '000000' ELSE (RIGHT('0000'+RTRIM(CONVERT(INT,SUM(E1_SALDO * CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_BAIXA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_BAIXA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_BAIXA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_BAIXA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103))) END  ) / SUM(CONVERT(INT,E1_SALDO)))),4)  + '00') END AS AM, //MEDIAPONDERATRASO
				   //RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA >= (RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2)) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))*100)))))),15) AN, //AVENCER
				   RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA >= CONVERT(VARCHAR(8), (GETDATE()), 112) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))*100)))))),15) AN, //AVENCER
                   //CASE WHEN RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA >= (RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2)) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))*100)))))),15) = '000000000000000' THEN '000000' ELSE (CASE WHEN RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(E1_VALOR * CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  )) / SUM(CONVERT(INT,E1_VALOR))),'.','')),4)  = '0000' AND RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  ))  / CONVERT(INT,COUNT(E1_NUM))),'.','')),4) > '0000' THEN RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  ))  / CONVERT(INT,COUNT(E1_NUM))),'.','')),4) ELSE  RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(E1_VALOR * CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  )) / SUM(CONVERT(INT,E1_VALOR))),'.','')),4) END  + '00') END  AS AO, //MEDIAPONDERAVENCER
				   CASE WHEN RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA >= CONVERT(VARCHAR(8), (GETDATE()), 112) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))*100)))))),15) = '000000000000000' THEN '000000' ELSE (CASE WHEN RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(E1_VALOR * CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  )) / SUM(CONVERT(INT,E1_VALOR))),'.','')),4)  = '0000' AND RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  ))  / CONVERT(INT,COUNT(E1_NUM))),'.','')),4) > '0000' THEN RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  ))  / CONVERT(INT,COUNT(E1_NUM))),'.','')),4) ELSE  RIGHT('0000'+RTRIM(REPLACE(CONVERT(INT,(SUM(E1_VALOR * CASE WHEN  CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) < 0 THEN CONVERT(INT, '0') ELSE CONVERT(INT,CONVERT(DATETIME,(CASE WHEN E1_VENCREA = '' THEN CONVERT(VARCHAR(8), (GETDATE()), 112) ELSE E1_VENCREA END),103) - CONVERT(INT,CONVERT(DATETIME,E1_EMISSAO,103))) END  )) / SUM(CONVERT(INT,E1_VALOR))),'.','')),4) END  + '00') END  AS AO, //MEDIAPONDERAVENCER
                   //RIGHT('0000'+RTRIM(CONVERT(CHAR,CASE WHEN (SUM(CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103) - CONVERT(DATETIME,E1_EMISSAO,103))) / CONVERT(INT,COUNT(E1_NUM))) <= 0 THEN '0' ELSE CASE WHEN (RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(((ROUND(SUM(CASE WHEN E1_VENCREA >= (RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2)) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))+((ROUND(SUM(CASE WHEN E1_VENCREA <= ((RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2))-5) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))) ))*100)))))),15))  = '000000000000000' OR RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA >= (RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2)) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))*100)))))),15) = '000000000000000' THEN '0' ELSE(SUM(CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103) - CONVERT(DATETIME,E1_EMISSAO,103))) / CONVERT(INT,COUNT(E1_NUM))) END END  )),4) + '00' AS AP , //PRAZOMEDIOVENDA
                   RIGHT('0000'+RTRIM(CONVERT(CHAR,CASE WHEN (SUM(CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103) - CONVERT(DATETIME,E1_EMISSAO,103))) / CONVERT(INT,COUNT(E1_NUM))) <= 0 THEN '0' ELSE CASE WHEN (RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(((ROUND(SUM(CASE WHEN E1_VENCREA >= CONVERT(VARCHAR(8), (GETDATE()), 112) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))+((ROUND(SUM(CASE WHEN E1_VENCREA <= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))) ))*100)))))),15))  = '000000000000000' OR RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA >= CONVERT(VARCHAR(8), (GETDATE()), 112) AND E1_SALDO > 0 THEN E1_SALDO ELSE 0 END),0))*100)))))),15) = '000000000000000' THEN '0' ELSE(SUM(CONVERT(INT,CONVERT(DATETIME,E1_VENCREA,103) - CONVERT(DATETIME,E1_EMISSAO,103))) / CONVERT(INT,COUNT(E1_NUM))) END END  )),4) + '00' AS AP , //PRAZOMEDIOVENDA
			       //RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA <= ((RTRIM(CONVERT(CHAR,YEAR(getdate())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()))),2))-5) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_SALDO ELSE 0 END),0))*100)))))),15) AQ, //VALVENC5
			       RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN E1_VENCREA <= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_SALDO ELSE 0 END),0))*100)))))),15) AQ, //VALVENC5
                   //CASE WHEN RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,ROUND((SUM(CASE WHEN (E1_VENCREA <= (RTRIM(CONVERT(CHAR,YEAR(getdate()-5)))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(getdate()-5))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(getdate()-5))),2))) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(CONVERT(DATETIME,((RTRIM(CONVERT(CHAR,YEAR(GETDATE())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()))),2))),103)- CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)),0)/ROUND(SUM(CASE WHEN (E1_VENCREA <=(RTRIM(CONVERT(CHAR,YEAR(GETDATE()-5)))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()-5))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()-5))),2))) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END),0))))))),4) < '0005' AND RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,ROUND(SUM(CASE WHEN (E1_VENCREA)<= (RTRIM(CONVERT(CHAR,YEAR(GETDATE()-5)))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()-5))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()-5))),2))AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(CONVERT(DATETIME,((RTRIM(CONVERT(CHAR,YEAR(GETDATE())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()))),2))),103)-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END),0)/ROUND(SUM(CASE WHEN (E1_VENCREA<=(RTRIM(CONVERT(CHAR,YEAR(GETDATE()-5)))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()-5))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()-5))),2))) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END),0))))))),4) <> '0000' THEN '0005' ELSE RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,ROUND(SUM(CASE WHEN (E1_VENCREA<=(RTRIM(CONVERT(CHAR,YEAR(GETDATE()-5)))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()-5))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()-5))),2))) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR *             CONVERT(NUMERIC,(CONVERT(DATETIME,((RTRIM(CONVERT(CHAR,YEAR(GETDATE())))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()))),2))),103)-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END),0)/ROUND(SUM(CASE WHEN (E1_VENCREA<=(RTRIM(CONVERT(CHAR,YEAR(GETDATE()-5)))+RIGHT('0'+RTRIM(CONVERT(CHAR,MONTH(GETDATE()-5))),2)+RIGHT('0'+RTRIM(CONVERT(CHAR,DAY(GETDATE()-5))),2))) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END),0))))))),4)  END AS AR, //MEDIAPONDERAVENCER5
                   CASE WHEN RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,ROUND((SUM(CASE WHEN (E1_VENCREA <= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5)) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(CONVERT(DATETIME,CONVERT(VARCHAR(8), (GETDATE()), 112),103)- CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)),0)/ROUND(SUM(CASE WHEN (E1_VENCREA <= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5)) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END),0))))))),4) < '0005' AND RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,ROUND(SUM(CASE WHEN (E1_VENCREA)<= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(CONVERT(DATETIME,(CONVERT(VARCHAR(8), (GETDATE()), 112)),103)-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END),0)/ROUND(SUM(CASE WHEN (E1_VENCREA<=(CONVERT(VARCHAR(8), (GETDATE()), 112)-5)) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END),0))))))),4) <> '0000' THEN '0005' ELSE RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,ROUND(SUM(CASE WHEN (E1_VENCREA<=(CONVERT(VARCHAR(8), (GETDATE()), 112)-5)) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(CONVERT(DATETIME,(CONVERT(VARCHAR(8), (GETDATE()), 112)),103)-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END),0)/ROUND(SUM(CASE WHEN (E1_VENCREA<= (CONVERT(VARCHAR(8), (GETDATE()), 112)-5)) AND E1_SALDO > 0  AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END),0))))))),4)  END AS AR, //MEDIAPONDERAVENCER5
			       RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(ROUND(SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_SALDO ELSE 0 END),0))*100)))))),15) AT, //VALVENC15
			       CASE WHEN RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(GETDATE()-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)/SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END))))))),4) < '0015' AND RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(GETDATE()-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)/SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END))))))),4) <> '0000' THEN '0015' ELSE RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(GETDATE()-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)/SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-15)AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END))))))),4)  END AS AU, //MEDIAPONDERAVENCER15
                   RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT, ROUND((SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30) AND E1_SALDO >0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_SALDO ELSE 0 END)),0)*100)))))),15) AV, //VALVENC30
			       CASE WHEN RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(GETDATE()-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)/SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END))))))),4) < '0030' AND RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(GETDATE()-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)/SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END))))))),4) <> '0000' THEN '0030' ELSE RIGHT(('0000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30) AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR * CONVERT(NUMERIC,(GETDATE()-CONVERT(DATETIME,E1_VENCREA,103)))ELSE 0 END)/SUM(CASE WHEN (CONVERT(DATETIME,E1_VENCREA,103) <=GETDATE()-30)AND E1_SALDO > 0 AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') THEN E1_VALOR ELSE 1 END))))))),4)  END AS AX, //MEDIAPONDERAVENCER30
			       CASE WHEN MAX(RIGHT('00000000'+RTRIM(A1_ULTCOM),8)) <= (RIGHT('00000000'+RTRIM(MAX(PENULTCOM) ),8)) THEN '00000000' ELSE (RIGHT('00000000'+RTRIM(MAX(PENULTCOM) ),8)) END AZ, //DTPENULTCOM
			       CASE WHEN (CASE WHEN MAX(RIGHT('00000000'+RTRIM(A1_ULTCOM),8)) <= (RIGHT('00000000'+RTRIM(MAX(PENULTCOM) ),8)) THEN '00000000' ELSE (RIGHT('00000000'+RTRIM(MAX(PENULTCOM) ),8)) END) = '00000000' THEN '000000000000000' ELSE RIGHT(('000000000000000'+RTRIM((CONVERT(CHAR,(CONVERT(INT,(MIN(E1_VALOR))*100)))))),15) END BA, //VLPENULTCOM
			       '1' BB, //SITCALLC
			       '0' BC, //TPGARANTIA
			       '00' BD, //GRAUGARANTIA 
			       '00000000' BE, //VALIDGARANTIA
			       '000000000000000' BF, //VALGARANTIA
			       '000000000000000' BG, //VLVENDPGANTEC 
			       SPACE(2) BH  //ANTECIPADO 
			     FROM %Table:SA1% , %Table:SE1% , 
			     (SELECT %Table:SE1%.E1_CLIENTE UCCLI, 
			             /*%Table:SE1%.E1_LOJA UCLJ, */
			             MAX(E1_EMISSAO) PENULTCOM 
			        FROM %Table:SE1%, %Table:SA1% 
			       WHERE E1_CLIENTE = A1_COD 
			         /*AND E1_LOJA = A1_LOJA */
			         AND A1_ULTCOM <> E1_EMISSAO 
			         AND %Table:SE1%.D_E_L_E_T_ <> '*' 
			         AND %Table:SE1%.E1_CLIENTE+/*%Table:SE1%.E1_LOJA+*/%Table:SE1%.E1_EMISSAO NOT IN (
			                                                                         SELECT E1_CLIENTE+/*E1_LOJA*/+MAX(E1_EMISSAO) 
			                                                                           FROM %Table:SE1% 
			                                                                          WHERE %Table:SE1%.D_E_L_E_T_ <> '*' 	
			                                                                       GROUP BY E1_CLIENTE/*, E1_LOJA*/) 
			                                                                             AND E1_TIPO = 'NF' 
			                                                                        GROUP BY %Table:SE1%.E1_CLIENTE/*, %Table:SE1%.E1_LOJA*/ UNION 
			                                                                                                                         SELECT E1_CLIENTE UCCLI, 
			                                                                                                                                /*E1_LOJA UCLJ, */
			                                                                                                                                E1_EMISSAO PENULTCOM 
			                                                                                                                          FROM (
			                                                                                                                                 SELECT E1_CLIENTE, 
			                                                                                                                                        /*E1_LOJA, */
			                                                                                                                                        MAX(E1_EMISSAO) E1_EMISSAO, 
			                                                                                                                                        COUNT(*) REGS 
			                                                                                                                                   FROM %Table:SE1% 
			                                                                                                                                   WHERE E1_TIPO = 'NF' 
			                                                                                                                                     AND %Table:SE1%.D_E_L_E_T_ <> '*'
			                                                                                                                                GROUP BY E1_CLIENTE/*, E1_LOJA*/) UMACOMPRA 
			                                                                                                                                   WHERE REGS = 1 ) PENULTCOM WHERE E1_CLIENTE = A1_COD 
			                                                                                                                                                                /*AND E1_LOJA    = A1_LOJA */
			                                                                                                                                                                AND E1_CLIENTE = UCCLI 
			                                                                                                                                                                /*AND E1_LOJA = UCLJ */
			                                                                                                                                                                AND A1_EST <> 'EX' 
			                                                                                                                                                                //AND CONVERT(DATETIME,A1_ULTCOM,103) >= GETDATE()-365 
			                                                                                                                                                                AND (SELECT MAX(CONVERT(DATETIME,SA1ULTCOM.A1_ULTCOM,103)) FROM %Table:SA1% SA1ULTCOM WHERE LEFT(SA1ULTCOM.A1_CGC,8) =  LEFT(%Table:SA1%.A1_CGC,8) AND SA1ULTCOM.A1_ULTCOM <> '' AND SA1ULTCOM.D_E_L_E_T_ <> '*') >= GETDATE()-365
			                                                                                                                                                                AND A1_ULTCOM <> '' 
			                                                                                                                                                                AND E1_TIPO = 'NF' 
			                                                                                                                                                                AND %Table:SE1%.D_E_L_E_T_ <> '*'
			                                                                                                                                                           GROUP BY A1_PESSOA, CASE WHEN A1_PESSOA = 'J' THEN (RIGHT(('00000000000000000000'+RTRIM((LEFT(A1_CGC,8)))),20))  ELSE (RIGHT(('00000000000000000000'+RTRIM((A1_CGC))),20)) END ) TABELA WHERE AI /*VALULTCOM*/ <> '000000000000000' 
    EndSQl
RETURN()       