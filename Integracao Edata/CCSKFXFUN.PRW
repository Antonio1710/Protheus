#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "MntTRCell.ch"
#Include "Topconn.ch"

//Estrutura de arquivo
#DEFINE POS_CMP		1
#DEFINE POS_TIP		2
#DEFINE POS_TAM		3
#DEFINE POS_DEC		4

//Estrutura de campos para formar arquivo HTML
#DEFINE POS_HT_CMP		1
#DEFINE POS_HT_TAM		2
#DEFINE POS_HT_TIT		3
#DEFINE POS_HT_PIC		4

#DEFINE nTAMSX1H		35	//Tamanho da descricao help SX1

Static nEsqCont			:= 001
Static nAltCont			:= 009
Static nDistPad			:= 002
Static nAltBot			:= 013
Static nDistAPad		:= 004
Static nDistEtq			:= 001
Static nAltEtq			:= 007
Static nLargEtq			:= 035 
Static nLargBot			:= 040
Static cHK				:= "&"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntTRCell บAutor  ณPablo Gollan Carreras บ Data ณ10/04/12         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para montar estrutura de celulas dentro de uma secao       บฑฑ
ฑฑบ          ณTRSection.                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Objeto TRSection                                       บฑฑ
ฑฑบ          ณExp02[A] : Array contendo informacoes das celulas. Estrutura :    บฑฑ
ฑฑบ          ณ           1. CAMPO                                               บฑฑ
ฑฑบ          ณ           2. TIPO                                                บฑฑ
ฑฑบ          ณ           3. TAMANHO                                             บฑฑ
ฑฑบ          ณ           4. TITULO                                              บฑฑ
ฑฑบ          ณ           5. ALINHAMENTO DA CELULA                               บฑฑ
ฑฑบ          ณ           6. PICTURE DE FORMATACAO                               บฑฑ
ฑฑบ          ณ           7. OCULTAR CELULA?                                     บฑฑ
ฑฑบ          ณ           8. QUEBRA DE LINHA POR ESTOURO DE CONTEUDO             บฑฑ
ฑฑบ          ณ           9. AUTODIMENSIONAMENTO                                 บฑฑ
ฑฑบ          ณ           10.NEGRITO                                             บฑฑ
ฑฑบ          ณExp03[L] : Auto dimensionar as colunas?                           บฑฑ
ฑฑบ          ณExp04[L] : Desconsiderar colunas ocultas da estrutura da section  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAdriana   ณ24/05/2019ณTI      ณDevido a substituicao email para shared       บฑฑ
ฑฑบ          ณ          ณ        ณrelay, substituido MV_RELACNT p/ MV_RELFROM   บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MntTRCell(oSecao,aLstCS,lAutoDim,lDesCO)

Local lRet				:= .F.
Local nTamEstr			:= 10
Local ni				:= 0
Local nx				:= 0
Local aAreaSX3			:= SX3->(GetArea())
Local cCampo			:= ""
Local cTipo				:= ""
Local nTam				:= ""
Local cTitulo			:= ""
Local cAlinha			:= ""
Local cPict				:= ""
Local cAliasC			:= ""
Local lQuebraC			:= .F.
Local lAutoSize			:= .F.
Local lNegrito			:= .F.
Local bOk 				:= {|| !Empty(cTipo) .AND. !Empty(nTam) .AND. !Empty(cTitulo)}
Local aTMP				:= {}

PARAMTYPE 0	VAR oSecao		AS Object		OPTIONAL	DEFAULT Nil
PARAMTYPE 1	VAR aLstCS		AS Array					DEFAULT {}
PARAMTYPE 2	VAR lAutoDim	AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 3	VAR lDesCO		AS Logical		OPTIONAL	DEFAULT .F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If oSecao == Nil .OR. Empty(aLstCS)
	Return lRet
Endif
dbSelectArea("SX3")
SX3->(dbSetOrder(2))	//X3_CAMPO
For ni := 1 to Len(aLstCS)
	If Len(aLstCS[ni]) > nTamEstr
		Loop
	Endif
	aTMP := Array(nTamEstr)
	For nx := 1 to Len(aLstCS[ni])
		aTMP[nx] := aLstCS[ni][nx]
	Next nx
	//Reiniciar variaveis
	cCampo		:= IIf(!Empty(aTMP[POS_CMP]),AllTrim(AllToChar(aTMP[POS_CMP])),"")
	cTipo		:= IIf(!Empty(aTMP[POS_TIP]) .AND. aTMP[POS_TIP] $ "C|N|D|M|L",aTMP[POS_TIP],"")
	nTam		:= IIf(!Empty(aTMP[POS_TAM]),GetDToVal(AllToChar(aTMP[POS_TAM])),0)
	cTitulo		:= IIf(!Empty(aTMP[POS_TIT]),AllTrim(AllToChar(aTMP[POS_TIT])),"")
	cAlinha		:= IIf(!Empty(aTMP[POS_ALI]) .AND. aTMP[POS_ALI] $ "L|C|R",aTMP[POS_ALI],"")
	cPict		:= IIf(!Empty(aTMP[POS_PIC]),AllTrim(AllToChar(aTMP[POS_PIC])),"")
	lOculta		:= IIf(!Empty(aTMP[POS_OCU]),aTMP[POS_OCU],.F.)
	lQuebraC	:= IIf(!Empty(aTMP[POS_QBL]),aTMP[POS_QBL],.F.)
	lAutoSize	:= IIf(!Empty(aTMP[POS_ATS]),aTMP[POS_ATS],lAutoDim)
	lNegrito	:= IIf(!Empty(aTMP[POS_NEG]),aTMP[POS_NEG],.F.)
	cAliasC		:= ""
	//Verificar se eh um campo valido do dicionario de dados e carregar as informacoes nao declaradas
	If Empty(cCampo)
		Loop
	Endif
	//Caso o parametro de desconsiderar colunas ocultas esteja ativo, desconsiderar
	If lDesCO .AND. lOculta
		Loop
	Endif
	If SX3->(dbSeek(PadR(AllTrim(cCampo),Len(SX3->X3_CAMPO))))
		cAliasC := SX3->X3_ARQUIVO
		If Empty(cTipo)
			cTipo := SX3->X3_TIPO
		Endif
		If Empty(nTam)
			nTam := SX3->X3_TAMANHO
		Endif
		If Empty(cTitulo)
			cTitulo := X3Titulo()
		Endif
		If Empty(cPict)
			cPict := SX3->X3_PICTURE
		Endif
	Endif
	//Validar campos logicos
	aTMP := {@lOculta,@lQuebraC,@lAutoSize,@lNegrito}
	For nx := 1 to Len(aTMP)
		If ValType(aTMP[nx]) # "L"
			If ValType(aTMP[nx]) == "C" .AND. (AllTrim(aTMP[nx]) == ".T." .OR. AllTrim(aTMP[nx]) == ".F.")
				aTMP[nx] := &(aTMP[nx])
			Else
				aTMP[nx] := .F.
			Endif
		Endif	
	Next nx
	//Caso as informacoes necessarias estejam disponiveis
	If Eval(bOk)
		lRet := .T.
		//Tratamento para alinhamento, caso nao definido
		If Empty(cAlinha)
			Do Case 
				Case cTipo $ "M|C"
					cAlinha := "L"
				Case cTipo $ "D|L"
					cAlinha := "C"
				Case cTipo $ "N"
					cAlinha := "R"
				Otherwise
					cAlinha := "C"
			EndCase
		Endif
		//Gravacao da celula na secao
		tRCell():New(	oSecao,;																//Objeto TRSection
						cCampo,;																//Nome da celula - Campo
						cAliasC,;																//Tabela da celula
						IIf(!lOculta,cTitulo,""),;												//Titulo
						cPict,;																	//Mascara de formatacao
						nTam,;																	//Tamanho do campo
						.T.,;																	//Pixels
						{|| },;																	//Bloco de codigo com o retorno do campo
						IIf(cAlinha == "L","LEFT",IIf(cAlinha == "C","CENTER","RIGHT")),;		//Alinhamento
						lQuebraC,;																//Quebrar linha?
						"LEFT",;																//Alinhamento cabecalho
						,;																		//Compatibilidade
						0,;																		//Espacamento entre as celulas
						lAutoSize,;																//Auto dimensionamento?
						,;																		//Cor de fundo da celula
						,;																		//Cor da fonte da celula
						lNegrito)																//Imprimir em negrito
		//Tratamento de ocultacao
		If lOculta
			oSecao:Cell(cCampo):Hide()
		Endif
	Endif
Next ni

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTCriar    บAutor  ณPablo Gollan Carreras บ Data ณ16/04/12     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para criar tabela temporaria, declara os campos numeri- บฑฑ
ฑฑบ          ณcos, de data e memorando no TOP_FIELD, criacao de indices e    บฑฑ
ฑฑบ          ณdeclaracao na workarea, inclusive de uma alias clone.          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome da tabela                                      บฑฑ
ฑฑบ          ณExp02[C] : Nome do schema utilizado no SGBD                    บฑฑ
ฑฑบ          ณExp03[A] : Lista de campos a criar                             บฑฑ
ฑฑบ          ณExp04[A] : Lista de indices a criar                            บฑฑ
ฑฑบ          ณExp05[A] : Array de LOG (Opcional)                             บฑฑ
ฑฑบ          ณExp06[L] : Determina se os campos de controle interno devem    บฑฑ
ฑฑบ          ณ           ser criados                                         บฑฑ
ฑฑบ          ณExp07[C] : Alias do clone da tab. temporaria jah que o ChkFile บฑฑ
ฑฑบ          ณ           nao funciona para tabelas que nao estejam no dicio. บฑฑ
ฑฑบ          ณExp08[L] : Em ambiente com interface, exibir mensagens?        บฑฑ
ฑฑบ          ณExp09[L] : Determina se um alias deve ser aberto automaticamen-บฑฑ
ฑฑบ          ณ           para tabela temporaria criada (Opcional)            บฑฑ
ฑฑบ          ณExp10[L] : Exibir mensagem de exclusao de tabela jah existente?บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcRet[C] : Nome do alias criado para tabela temporaria criada   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TTCriar(cTabPr,cSchema,aCampos,aIndice,aLOG,lCriaCC,_cAliasPr,lMens,lAbAlias,lMenExc,lCriaNova)

Local cRet				:= ""
Local cQry				:= ""
Local lAtLog			:= Type("aLOG") == "A" .AND. FindFunction("U_AtuLog")
Local lExMens			:= .T.
Local ni				:= 0
Local nx				:= 0
Local cTMP				:= ""
Local cTabela			:= ""
Local cAliasPr			:= GetNextAlias()
Local cAliasT			:= GetNextAlias()
Local aLstInd			:= {}
Local cRotNome			:= "[" + Upper(AllTrim(StrTran(ProcName(0),"U_",""))) + "] "
Local aTMP				:= {}
Local cSGBD				:= Upper(AllTrim(TcGetDB()))
Local lSGBDOra			:= cSGBD == "ORACLE"
Local lAtIdx			:= .F.
Local nTotEnt			:= 1
Local cAliasVar			:= ""
Local lClone			:= !Empty(_cAliasPr)
Local cArqIdx			:= ""
Local cASCBase			:= 65
Local bValida			:= {|| }

PARAMTYPE 0 	VAR cTabPr		AS Character	OPTIONAL	DEFAULT IIf(!IsBlind(),Upper(AllTrim(FunName())) + "_" + Right(__cUserID,3),"")
PARAMTYPE 1 	VAR cSchema		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 2 	VAR aCampos		AS Array					DEFAULT Array(0)
PARAMTYPE 3 	VAR aIndice		AS Array		OPTIONAL	DEFAULT Array(0)
PARAMTYPE 4 	VAR aLOG		AS Array		OPTIONAL	DEFAULT Array(0)
PARAMTYPE 5		VAR lCriaCC		AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 6		VAR _cAliasPr	AS Character 	OPTIONAL	DEFAULT ""
PARAMTYPE 7		VAR lMens		AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 8 	VAR lAbAlias	AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 9		VAR lMenExc		AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 10	VAR lCriaNova	AS Logical		OPTIONAL	DEFAULT .F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValidacoes  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
#IFNDEF TOP
	Return cRet
#ENDIF
If Empty(cTabPr)
	Return cRet
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinicoes iniciais  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aLstInd	:= Array(Len(aIndice))
aFill(aLstInd,"")
lAtIdx	:= !Empty(aIndice) .AND. ValType(aIndice) == "A" .AND. ValType(aIndice[1]) == "A"
lExMens	:= !IsBlind() .AND. lMens
If !lAbAlias
	lClone 	:= .F.
	lAtIdx	:= .F.
Else
	If lClone
		nTotEnt++
	Endif
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso nao informado, levantar o schema  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("U_Pesquisa")
	cSchema := U_Pesquisa("TOP_FIELD",{"MIN(FIELD_TABLE)"},"",,,,.T.,.T.,"",.T.)
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao da tabela temporaria  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAtLog
	U_AtuLog(cRotNome + "Criacao da tabela temporaria",@aLOG,,,,2)
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso definido que o sistema deve procurar uma nova tabela     ณ
//ณcaso a existente jah exista, criar novas combinacoes de nome  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCriaNova
	bValida := {|| AllwaysTrue()}
	ni := 0
	Do While MsFile(cTabPr + IIf(ni == 0,"",CHR(cASCBase + ni)),Nil,__cRDD)
		ni++	
	EndDo
	cTabPr += IIf(ni == 0,"",CHR(cASCBase + ni))
Else
	bValida := {|| MsFile(cTabPr,Nil,__cRDD)}
Endif
If Eval(bValida)
	If lExMens .AND. lMenExc .AND. !ApMsgYesNo(cNomeUs + ", a tabela temporแria de processamento foi encontrada no banco de dados e precisa ser apagada." + CRLF + "Deseja continuar?")
		Return cRet
	Endif
	If !U_TTExcluir(cTabPr)
		cTMP := cRotNome + "Erro na exclusใo da tabela temporaria " + AllTrim(cTabPr) + CRLF + TCSqlError()
		If lExMens
			MsgStop(cTMP)
		Else
			ConOut(cTMP)
		Endif
		If lAtLog
			U_AtuLog(cTMP,@aLOG,,,,2)
		Endif
		Return cRet
	Endif
Endif
cQry := "CREATE TABLE "  + cTabPr + " ("
For ni := 1 to Len(aCampos)
	cQry += aCampos[ni][POS_CMP] + Space(1)
	Do Case
		Case aCampos[ni][POS_TIP] $ "C|D|M"
			cQry += "VARCHAR(" + cValToChar(aCampos[ni][POS_TAM]) + ") "
			cQry += "DEFAULT '" + Space(aCampos[ni][POS_TAM]) + "' "
		Case aCampos[ni][POS_TIP] == "N"
			//No SQL Server campos definidos como NUMERIC nao sao retornados ao abrir a tabela com o dbUseArea, por motivo desconhecido, aplicar entao o tipo float
			Do Case
				Case cSGBD $ "MSSQL|MSSQL7|SYBASE"
					cQry += "FLOAT "
				Otherwise
					cQry += "NUMERIC(" + cValToChar(aCampos[ni][POS_TAM]) + "," + cValToChar(aCampos[ni][POS_DEC]) + ") "
			EndCase
			cQry += "DEFAULT 0 "
	EndCase
	//Aplicar regra de nao nulo aos campos
	cQry += "CONSTRAINT " + aCampos[ni][POS_CMP] + " NOT NULL "
	cQry += IIf(ni < Len(aCampos),", ", " ")
Next ni
//Campos de controle, sem os quais o dbUseArea nao funcionaria
If lCriaCC
	cQry += ", "
	cQry += "D_E_L_E_T_ VARCHAR(1) DEFAULT ' ' CONSTRAINT D_E_L_E_T_ NOT NULL, "
	cQry += "R_E_C_N_O_ INTEGER DEFAULT 0 CONSTRAINT R_E_C_N_O_ NOT NULL, "
	cQry += "R_E_C_D_E_L_ INTEGER DEFAULT 0 CONSTRAINT R_E_C_D_E_L_ NOT NULL "
Endif
cQry += ") "
If TcSQLExec(cQry) < 0
	cTMP := cRotNome + "Erro na cria็ใo da tabela temporaria " + AllTrim(cTabPr) + CRLF + TCSqlError()
	If lExMens
		MsgStop(cTMP)
	Else
		ConOut(cTMP)
	Endif
	If lAtLog
		U_AtuLog(cTMP,@aLOG,,,,2)
	Endif
	Return cRet
Endif
If lSGBDOra
	TcSQLExec("COMMIT")
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeclarar campos TOP_FIELD  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cSchema) .AND. !Empty(cSchema := Substr(cSchema,1,At(".",cSchema) - 1))
	cTabela := cSchema + "." + cTabPr
	For ni := 1 to Len(aCampos)
		If aCampos[ni][POS_TIP] $ "N|D|M"
			//Validar a existencia do registro
			cQry := "SELECT DISTINCT FIELD_NAME "
			cQry += "FROM TOP_FIELD "
			cQry += "WHERE EXISTS("
			cQry += "SELECT 1 FROM TOP_FIELD TF02 "
			cQry += "WHERE TF02.FIELD_TABLE = '" + cTabela + "' AND TF02.FIELD_NAME = '" + AllTrim(aCampos[ni][POS_CMP]) + "') "
			dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAliasT,.T.,.F.)
			(cAliasT)->(dbGoTop())
			If (cAliasT)->(Eof()) .OR. Empty((cAliasT)->FIELD_NAME)
				cQry := "INSERT INTO TOP_FIELD (FIELD_TABLE,FIELD_NAME,FIELD_TYPE,FIELD_PREC,FIELD_DEC) "
				cQry += "VALUES ('" + cTabela + "','" + AllTrim(aCampos[ni][POS_CMP]) + "',"
				cQry += "'" + IIf(aCampos[ni][POS_TIP] == "N","P",aCampos[ni][POS_TIP]) + "',"
				cQry += "'" + cValToChar(aCampos[ni][POS_TAM]) + "','" + cValToChar(aCampos[ni][POS_DEC]) + "')"
				If TcSQLExec(cQry) < 0
					U_TTExcluir(cTabPr,cSchema)
					cTMP := cRotNome + "Erro na declara็ใo de campos da tabela temporaria " + AllTrim(cTabPr) + " no TOP." + CRLF + TCSqlError()
					If lExMens
						MsgStop(cTMP)
					Else
						ConOut(cTMP)
					Endif
					If lAtLog
						U_AtuLog(cTMP,@aLOG,,,,2)
					Endif
					Return cRet
				Endif
				If lSGBDOra
					TcSQLExec("COMMIT")
				Endif
			Endif
			U_FecArTMP(cAliasT)
		Endif
	Next ni
Endif
If lAtLog
	aAdd(aLog,"")
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriacao dos indices da tabela temporaria  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAtLog
	U_AtuLog(cRotNome + "Criacao dos indices da tabela temporaria",@aLOG,,,,2)
Endif
If lAtIdx
	For ni := 1 to Len(aIndice)
		aTMP := aClone(aIndice[ni])
		cQry := "CREATE INDEX " + cTabPr + Soma1(cValToChar(ni - 1),1) + " " 
		cQry += "ON " + cTabPr + " ("
		For nx := 1 to Len(aTMP)
			cQry += aTMP[nx] + IIf(nx < Len(aTMP),", "," ")
			//Alimentar a variavel que compoe a chave dos indices
			aLstInd[ni] += aTMP[nx] + IIf(nx < Len(aTMP),"+","")
		Next nx
		cQry += ")"
		If TcSQLExec(cQry) < 0
			U_TTExcluir(cTabPr,cSchema)	
			cTMP := cRotNome + "Erro na cria็ใo do indice " + StrZero(ni,2) + " da tabela temporaria " + AllTrim(cTabPr) + "." + CRLF + TCSqlError()
			If lExMens
				MsgStop(cTMP)
			Else
				ConOut(cTMP)
			Endif
			If lAtLog
				U_AtuLog(cTMP,@aLOG,,,,2)
			Endif
			Return cRet
		Endif
		If lSGBDOra
			TcSQLExec("COMMIT")
		Endif
	Next ni
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณColocar a tabela criada na workarea  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lAbAlias
	For ni := 1 to nTotEnt
		Do Case
			Case ni == 1
				cAliasVar := cAliasPr
			Case ni == 2
				cAliasVar := _cAliasPr
		EndCase
		TcSetDummy(.T.)
		dbUseArea(.T.,__cRDD,cTabPr,cAliasVar,.T.,.F.)
		TcSetDummy(.F.)
		If Select(cAliasVar) == 0
			U_TTExcluir(cTabPr,cSchema)
			cTMP := cRotNome + "Erro na abertura da tabela temporaria " + AllTrim(cAliasVar) + "."
			If lExMens
				MsgStop(cTMP)
			Else
				ConOut(cTMP)
			Endif
			If lAtLog
				U_AtuLog(cTMP,@aLOG,,,,2)
			Endif
			Return cRet	
		Endif
		dbSelectArea(cAliasVar)
		If lAtIdx
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCriar os indices a serem utilizados  ณ
			//ณpela tabela temporaria               ณ
			//ณA partir do 2o alias, todos devem    ณ
			//ณutilizar o indice criado para o 1o   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ni == 1
				For nx := 1 To Len(aLstInd)
					cArqIdx := (cAliasPr + StrZero(nx,2))
					If File(cArqIdx + OrdBagExt())
						fErase(cArqIdx + OrdBagExt())
					Endif
					dbCreateIndex(cArqIdx,aLstInd[nx],{|| &(aLstInd[nx])},.F.)
				Next nx
			Endif
			(cAliasVar)->(dbClearIndex())
			For nx := 1 To Len(aLstInd)
				(cAliasVar)->(dbSetIndex(cAliasPr + StrZero(nx,2)))
			Next nx
		Endif
	Next ni	
	cRet := cAliasPr
Else
	If MsFile(cTabPr,Nil,__cRDD)
		cRet := "OK"
	Else
		cTMP := cRotNome + "Erro na valida็ใo da tabela temporaria " + AllTrim(cTabPr) + CRLF + TCSqlError()
		If lExMens
			MsgStop(cTMP)
		Else
			ConOut(cTMP)
		Endif
		If lAtLog
			U_AtuLog(cTMP,@aLOG,,,,2)
		Endif
	Endif
Endif

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTExcluir  บAutor  ณPablo Gollan Carreras บ Data ณ16/04/12     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para excluir a tabela temporaria e a referencia tabela  บฑฑ
ฑฑบ          ณtemporaria de dados.                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome da tabela                                      บฑฑ
ฑฑบ          ณExp01[C] : Nome do schema utilizado no SGBD                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TTExcluir(cTabela,cSchema,cAliasPr,_cAliasPr)

Local lRet				:= .T.
Local cQry				:= ""
Local lSGBDOra			:= Upper(AllTrim(TcGetDB())) == "ORACLE"
Local lFuncFT			:= FindFunction("U_FecArTMP")

PARAMTYPE 0	VAR cTabela		AS Character				DEFAULT ""
PARAMTYPE 1	VAR cSchema		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 2	VAR cAliasPr	AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 3	VAR _cAliasPr	AS Character	OPTIONAL	DEFAULT ""

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

#IFNDEF TOP
	Return !lRet
#ENDIF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso nao informado, levantar o schema  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("U_Pesquisa")
	cSchema := U_Pesquisa("TOP_FIELD",{"MIN(FIELD_TABLE)"},"",,,,.T.,.T.,"",.T.)
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso informado, fechar aliases que estejam utilizando a tab. temporaria  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lFuncFT .AND. !Empty(cAliasPr)
	U_FecArTMP(cAliasPr)
Endif
If lFuncFT .AND. !Empty(_cAliasPr)
	U_FecArTMP(_cAliasPr)
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณApagar a tabela  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQry := "DROP TABLE " + cTabela + " "
If TcSQLExec(cQry) < 0
	Return !lRet
Endif
If lSGBDOra
	TcSQLExec("COMMIT")
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRemover campos do TOP_FIELD  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cSchema)
	cQry := "DELETE TOP_FIELD "
	cQry += "WHERE FIELD_TABLE = '" + AllTrim(cSchema) + "." + AllTrim(cTabela) + "' "
	If TcSQLExec(cQry) < 0
		Return !lRet
	Endif
	If lSGBDOra
		TcSQLExec("COMMIT")
	Endif
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtuLog    บAutor ณPablo Gollan Carrerasบ Data ณ16/04/12     บฑฑ
ฑฑฬออออออออออุออออออออออสออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza Array de Log                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AtuLog(cMsg,aLog,nAtu,nAtREG,nLimite,nModelo)

Local cTMP				:= ""
Local aTMP				:= ""

PARAMTYPE 0 VAR	cMsg		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1 VAR	aLog		AS Array		OPTIONAL	DEFAULT {}
PARAMTYPE 2 VAR	nAtu		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 3 VAR nAtREG		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 4	VAR nLimite		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 5	VAR nModelo		AS Numeric		OPTIONAL	DEFAULT 1

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If !Empty(nLimite) .AND. Len(RTrim(cMsg)) > nLimite .AND. FindFunction("FormataHlp")
	aTMP := FormataHlp(RTrim(cMsg),nLimite)
	aEval(aTMP,{|x| cTMP += x + CRLF})
Else
	cTMP := RTrim(cMsg)
Endif
Do Case 
	Case nModelo == 1
		aAdd(aLog," [L" + StrZero(nAtu,10) + "] LOG = " + cTMP +  IIf(!Empty(nAtREG)," [REG " + AllTrim(AllToChar(nAtREG)) + "]",""))
	Otherwise
		aAdd(aLog,cTMP +  IIf(!Empty(nAtREG)," [REG " + AllTrim(AllToChar(nAtREG)) + "]",""))
EndCase

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณQryGoTo    บAutor  ณPablo Gollan Carreras บ Data ณ19/04/12     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para substituir a funcao DBGOTO que nao funciona em     บฑฑ
ฑฑบ          ณresultado de querys.                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Alias                                               บฑฑ
ฑฑบ          ณExp02[C] : Posicao do registro                                 บฑฑ
ฑฑบ          ณExp03[C] : Total de registros da query                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function QryGoTo(cAlias,nPosREG,nTotREG)

Local nPosOri			:= 0
Local nTpMov			:= 0
Local nSalto			:= 1
Local nTotSal			:= 0
Local aCatSal			:= {10,100,1000,10000}
Local nDifPos			:= 0
Local bValida			:= {|| }
Local ni				:= 0

PARAMTYPE 0	VAR cAlias		AS Character				DEFAULT ""
PARAMTYPE 1	VAR nPosREG		AS Numeric 					DEFAULT 0
PARAMTYPE 2	VAR nTotREG		AS Numeric 		OPTIONAL	DEFAULT 0

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Select(cAlias) == 0 .OR. Empty(nPosREG) .OR. (!Empty(nTotREG) .AND. nTotREG < nPosREG)
	Return Nil
Endif
nPosOri := (cAlias)->(Recno())
If Empty(nDifPos := (nPosREG - nPosOri))
	Return Nil
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeterminar o movimento  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nDifPos < 0
	//DESCENDENTE
	nTpMov := 2
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณComo o DBSKIP negativo nao funciona (!) com resultado de   ณ
	//ณquery tampouco, temos que posicionar no primeiro registro  ณ
	//ณpara posicionar um registro anterior ao atual.             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	(cAlias)->(dbGoTop())
	nDifPos := (nPosREG - 1)
	bValida := {|| !(cAlias)->(Eof()) .AND. (cAlias)->(Recno()) # nPosREG .AND. !Empty(nDifPos)}
Else
	//ASCENDENTE
	nTpMov := 1
	bValida := {|| !(cAlias)->(Eof()) .AND. (cAlias)->(Recno()) # nPosREG}
Endif
nDifPos := Abs(nDifPos)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDeterminar categoria de salto acelerado  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For ni := 1 to Len(aCatSal)
	If nDifPos < aCatSal[ni]
		If ni > 1
			nSalto := aCatSal[ni - 1]
			nTotSal := 	Int(nDifPos / nSalto)
		Endif
		Exit
	Else
		If ni == Len(aCatSal) .AND. nDifPos > aCatSal[ni]
			nSalto := aCatSal[ni - 1]
			nTotSal := 	Int(nDifPos / nSalto)		
		Endif
	Endif
Next ni
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSalto de registros  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ni := 0
Do While Eval(bValida)
	If nSalto # 1 .AND. (Empty(nTotSal) .OR. (++ni > nTotSal))
		//Desacelerar o salto para apenas um
		nSalto := 1
	Endif
	(cAlias)->(dbSkip(nSalto))
EndDo

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAjValSX3   บAutor  ณPablo Gollan Carreras บ Data ณ25/04/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para converter um valor em qualquer formato para o tipo    บฑฑ
ฑฑบ          ณcorrespondente ao tipo de dados de um campo do dic. de dados.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do campo SX3                                      บฑฑ
ฑฑบ          ณExp02[U] : Valor                                                  บฑฑ
ฑฑบ          ณExp03[L] : Ajustar tamanho do campo                               บฑฑ
ฑฑบ          ณExp04[C] : Formato da data : DMA ou MDA (para datas com separador)บฑฑ
ฑฑบ          ณExp05[L] : Para conversoes numericas Truncar ao inves de Arredond.บฑฑ
ฑฑบ          ณExp06[L] : Para conversoes de texto, passar para maiuscula        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณuRet[U] : Retorno de acordo com o tipo de dados do campo          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function AjValSX3(cCampo,uValor,lAjTam,cFrmtDt,lTrunca,lMaiusc,nDec)

Local uRet				:= uValor
Local aAreaSX3			:= SX3->(GetArea())
Local cTipo				:= ""
Local nTamData			:= 0
Local aEstrData			:= Array(3)
Local aPosDelDt			:= Array(2)

Default cCampo			:= ""
Default lAjTam			:= .F.
Default cFrmtDt		:= "DMA"
Default lTrunca		:= .F.
Default lMaiusc		:= .F.
Default nDec			:= 0

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Empty(cCampo) .OR. ValType(lAjTam) # "L" .OR. ValType(cFrmtDt) # "C" .OR. ValType(lTrunca) # "L" .OR. ValType(lMaiusc) # "L"
	Return uRet
Endif
dbSelectArea("SX3")
SX3->(dbSetOrder(2))		//X3_CAMPO
cCampo := PadR(cCampo,Len(SX3->X3_CAMPO))
If !SX3->(dbSeek(cCampo))
	RestArea(aAreaSX3)
	Return uRet
Endif
cTipo := AllTrim(SX3->X3_TIPO)
Do Case
	Case cTipo $ "C|M"
		If uRet == Nil
			uRet := ""
		Else
			If ValType(uRet) # "C"
				uRet := AllTrim(AllToChar(uRet))
			Endif
		Endif
		If lAjTam
			uRet := PadR(uRet,SX3->X3_TAMANHO)
		Endif
		If lMaiusc
			uRet := Upper(uRet)
		Endif
	Case cTipo == "D"
		aFill(aEstrData,"")
		If uRet == Nil
			uRet := CtoD("")
		Else
			If ValType(uRet) # "D"
				uRet := AllTrim(AllToChar(uRet))
				If !Empty(U_RemCarac(uRet,{"/","0","1","2","3","4","5","6","7","8","9",".",","}))
					uRet := CtoD("")
				Else
					nTamData := Len(uRet)
					If At("/",uRet) == 0
						If nTamData # 8 .OR. At(".",uRet) > 0 .OR. At(",",uRet) > 0
							//Validar se o campo eh numerico e trata-se de uma data que deve ser formada a partir de um numero inteiro
							If Empty(uRet := U_Num2Date(U_Cnv2Num(uRet))) .OR. ValType(uRet) # "D"
								uRet := CtoD("")
							Endif
						Else
							aEstrData[1] := Substr(uRet,7,2)
							aEstrData[2] := Substr(uRet,5,2)
							aEstrData[3] := Substr(uRet,1,4)
							uRet := CtoD(aEstrData[1] + "/" + aEstrData[2] + "/" + aEstrData[3])
						Endif
					Else
						aPosDelDt[1] := At("/",uRet)
						aPosDelDt[2] := RAt("/",uRet)
						If !Empty(aPosDelDt[1]) .AND. !Empty(aPosDelDt[2]) .AND. aPosDelDt[1] # aPosDelDt[2]
							Do Case
								Case nTamData >= 6
									aEstrData[1] := Substr(uRet,1,aPosDelDt[1] - 1)
									aEstrData[2] := Substr(uRet,aPosDelDt[1]  + 1 ,(aPosDelDt[2] - aPosDelDt[1]) - 1)
									aEstrData[3] := Substr(uRet,aPosDelDt[2] + 1,Len(uRet))
									If !Empty(aEstrData[1]) .AND. !Empty(aEstrData[2]) .AND. !Empty(aEstrData[3])
										If cFrmtDt == "DMA"
											uRet := CtoD(aEstrData[1] + "/" + aEstrData[2] + "/" + aEstrData[3])
										Else
											uRet := CtoD(aEstrData[2] + "/" + aEstrData[1] + "/" + aEstrData[3])
										Endif
									Else
										uRet := CtoD("")
									Endif
								Otherwise
									uRet := CtoD("")
							EndCase
						Else
							uRet := CtoD("")
						Endif
					Endif
				Endif
			Endif
		Endif
	Case cTipo == "N"
		If uRet == Nil
			uRet := 0
		Else
			If ValType(uRet) # "N"
				uRet := AllTrim(AllToChar(uRet))
				If !Empty(U_RemCarac(uRet,{"-",",",".","0","1","2","3","4","5","6","7","8","9"}))
					uRet := 0
				Else
					nSeparaV := Rat(",",uRet)
					nSeparaP := Rat(".",uRet)
					cSepDec := IIf(nSeparaV > nSeparaP,",",".")
					Do Case
						Case cSepDec == ","
							uRet := U_RemCarac(uRet,{"."})
						Case cSepDec == "."
							uRet := U_RemCarac(uRet,{","})
					EndCase
					If At("-",uRet) == 0
						uRet := GetDToVal(uRet)
					Else
						If !Empty(uRet := GetDToVal(uRet))
							uRet := uRet * -1
						Endif
					Endif
					If lAjTam .AND. SX3->X3_DECIMAL > 0
						If !lTrunca
							uRet := Round(uRet,IIf(!Empty(nDec),nDec,SX3->X3_DECIMAL))
						Else
							uRet := NoRound(uRet,IIf(!Empty(nDec),nDec,SX3->X3_DECIMAL))
						Endif
					Endif
				Endif
			Endif
		Endif
	Case cTipo == "L"
	
EndCase
RestArea(aAreaSX3)

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณRemCarac   บAutor  ณPablo Gollan Carreras บ Data ณ25/04/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para remover todos ou alguns caracteres definidos de uma   บฑฑ
ฑฑบ          ณstring.                                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : String original                                        บฑฑ
ฑฑบ          ณExp02[A] : Array de caracteres determinados pelo usuario          บฑฑ
ฑฑบ          ณExp03[L] : Fazer as comparacoes c/carac.determ. como maiusculas?  บฑฑ
ฑฑบ          ณExp04[N] : Tipo 1.Remov.caracter lista 2.Cons.apenas carac.lista  บฑฑ
ฑฑบ          ณExp05[L] : Desconsiderar redundancia de caracteres (jah existen.) บฑฑ
ฑฑบ          ณExp06[L] : Para caracteres, remover acentuacao                    บฑฑ
ฑฑบ          ณExp07[L] : Para caracteres, converter para maiuscula              บฑฑ
ฑฑบ          ณExp08[L] : Para caracteres, remover espacos                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RemCarac(cValor,aCarDef,lMaiusc,nTipo,lDescRed,lRemAcentua,lCvMaius,lRemEsp)

Local cRet				:= ""
Local ni				:= 0
Local lCarDef			:= .F.
Local cCarAt			:= ""
Local lSaltar			:= .F.
Local aPosDel			:= {}
Local cAcent			:= "มษอำฺยสฮิÛภศฬาูฤหฯึÜรีัว"		//Acentuacoes
Local cAcentC			:= "AEIOUAEIOUAEIOUAEIOUAONC"		//Correspondentes
Local cAcentM			:= "แ้ํ๓๚โ๊๎๔๛เ่์๒๙ไ๋๏๖üใ๕๑็"		//Acentuacoes minusculas
Local cAcentCM			:= "aeiouaeiouaeiouaeiouaonc"		//Correspondentes minusculas
Local cTMP				:= ""
Local cTMP02			:= ""
Local nx				:= 0
Local nPos				:= 0

PARAMTYPE 0	VAR cValor		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1	VAR aCarDef		AS Array		OPTIONAL	DEFAULT {}
PARAMTYPE 2	VAR lMaiusc		AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 3	VAR nTipo		AS Numeric		OPTIONAL	DEFAULT 1
PARAMTYPE 4 VAR	lDescRed	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 5 VAR	lRemAcentua	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 6 VAR	lCvMaius	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 7 VAR	lRemEsp		AS Logical		OPTIONAL	DEFAULT .F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Empty(cValor)
	Return cRet
Endif
//Validar os caracteres enviados
If Len(aCarDef) > 0
	For ni := 1 to Len(aCarDef)
		If ValType(aCarDef[ni]) # "C" .OR. (ValType(aCarDef[ni]) == "A" .AND. Len(aCarDef[ni]) > 1)
			aAdd(aPosDel,ni)
		Endif
	Next ni
	If !Empty(aPosDel)
		For ni := Len(aPosDel) to 1 Step -1
			aDel(aCarDef,aPosDel[ni])
			aSize(aCarDef,Len(aCarDef) - 1)
		Next ni
	Endif
Endif
lCarDef := Len(aCarDef) > 0
For ni := 1 to Len(cValor)
	lSaltar	:= .F.
	cCarAt	:= Substr(cValor,ni,1)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento de acentuacoes  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRemAcentua
		If lMaiusc
			If (nPos := At(Upper(cCarAt),cAcent)) > 0
				cCarAt := Substr(cAcentC,nPos,1)
			Endif
		Else
			If (nPos := At(cCarAt,cAcentM)) > 0
				cCarAt := Substr(cAcentCM,nPos,1)
			Else
				If (nPos := At(cCarAt,cAcent)) > 0
					cCarAt := Substr(cAcentC,nPos,1)
				Endif
			Endif
		Endif
	Endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCaso nao tenha sido informado nenhum caracter para remover ou   ณ
	//ณmanter E nao tenha sido solicitada nenhuma formatacao de texto, ณ
	//ณrealizar caso :                                                 ณ
	//ณ- TIPO = 1 : Remover os caracteres nao numericos                ณ
	//ณ- TIPO = 2 : Remover os caracteres numericos                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lCarDef .AND. !lRemAcentua .AND. !lCvMaius .AND. !lRemEsp
		If nTipo == 1
			//Remover todos os caracteres nao numericos
			If !IsDigit(cCarAt)
				lSaltar := .T.
			Endif
		Else
			//Considerar apenas caracteres nao numericos
			If IsDigit(cCarAt)
				lSaltar := .T.
			Endif		
		Endif
	Else
		If lCarDef
			If nTipo == 1
				//Remover apenas a lista de caracteres determinados pela chamada
				If lMaiusc
					lSaltar := !(aScan(aCarDef,{|x| Upper(x) == Upper(cCarAt)}) == 0)
				Else
					lSaltar := !(aScan(aCarDef,{|x| x == cCarAt}) == 0)
				Endif
			Else
				//Considerar apenas a lista de caracteres determinados pela chamada
				If lMaiusc
					lSaltar := aScan(aCarDef,{|x| Upper(x) == Upper(cCarAt)}) == 0
				Else
					lSaltar := aScan(aCarDef,{|x| x == cCarAt}) == 0
				Endif		
			Endif
		Endif
	Endif
	If lSaltar .OR. (lDescRed .AND. cCarAt $ cRet)
		Loop
	Endif
	cRet += cCarAt
Next ni
If lCvMaius
	cRet := Upper(cRet)
Endif
If lRemEsp
	cRet := AllTrim(cRet)
Endif

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณNum2Date  บAutor  ณPablo Gollan Carreras บ Data ณ25/04/12         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para converter numeros inteiros para data.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Valor inteiro representando dias                       บฑฑ
ฑฑบ          ณExp02[N] : Valor padrao de database :                             บฑฑ
ฑฑบ          ณ           1. EXCEL                                               บฑฑ
ฑฑบ          ณ           2. DELPHI                                              บฑฑ
ฑฑบ          ณExp03[N] : Valor digitado da data base                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Num2Date(nValor,nOpcDtBase,dDtBaseDig)

Local dRet				:= Nil
Local dDtBase 			:= CtoD("30/12/1899")

PARAMTYPE 0	VAR nValor		AS Numeric					DEFAULT 0
PARAMTYPE 1	VAR nOpcDtBase	AS Numeric		OPTIONAL	DEFAULT 1
PARAMTYPE 2	VAR dDtBaseDig	AS Date			OPTIONAL	DEFAULT Nil

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If dDtBaseDig # Nil .AND. ValType(dDtBaseDig) == "D"
	dDtBase := dDtBaseDig
Else
	Do Case 
		Case nOpcDtBase == 1	//EXCEL
			dDtBase := CtoD("30/12/1899")
		Case nOpcDtBase == 2	//DELPHI
			dDtBase := CtoD("01/01/1800")
		Otherwise
			Return dRet
	EndCase
Endif
dRet := dDtBase + nValor
						
Return dRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณCnv2Num   บAutor  ณPablo Gollan Carreras บ Data ณ25/04/12         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para converter uma string em seu correspondente numerico   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : String com conteudo numerico, mesmo com separadores    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function Cnv2Num(uValor)

Local uRet				:= uValor
Local nSeparaV			:= 0
Local nSeparaP			:= 0

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If uRet == Nil
	uRet := 0
Else
	If ValType(uRet) # "N"
		uRet := AllTrim(AllToChar(uRet))
		If !Empty(U_RemCarac(uRet,{"-",",",".","0","1","2","3","4","5","6","7","8","9"}))
			uRet := 0
		Else
			nSeparaV := Rat(",",uRet)
			nSeparaP := Rat(".",uRet)
			cSepDec := IIf(nSeparaV > nSeparaP,",",".")
			Do Case
				Case cSepDec == ","
					uRet := U_RemCarac(uRet,{"."})
				Case cSepDec == "."
					uRet := U_RemCarac(uRet,{","})
			EndCase
			If At("-",uRet) == 0
				uRet := GetDToVal(uRet)
			Else
				If !Empty(uRet := GetDToVal(uRet))
					uRet := uRet * -1
				Endif
			Endif
		Endif
	Endif
Endif

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณEnvEML    บAutor  ณPablo Gollan Carreras บ Data ณ25/04/12         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao de envio de e-mail utilizando as classe tMailManager e     บฑฑ
ฑฑบ          ณtMailMessage.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[L] : Conexao SSL                                            บฑฑ
ฑฑบ          ณExp02[L] : Conexao TLS                                            บฑฑ
ฑฑบ          ณExp03[L] : Autenticar para envio                                  บฑฑ
ฑฑบ          ณExp04[C] : E-mail do remetente                                    บฑฑ
ฑฑบ          ณExp05[C] : E-mail de destino                                      บฑฑ
ฑฑบ          ณExp06[C] : E-mail com copia                                       บฑฑ
ฑฑบ          ณExp07[C] : E-mail com copia oculta                                บฑฑ
ฑฑบ          ณExp08[C] : Assunto (subject)                                      บฑฑ
ฑฑบ          ณExp09[C] : Mensagem (body)                                        บฑฑ
ฑฑบ          ณExp10[C] : Servidor SMTP                                          บฑฑ
ฑฑบ          ณExp11[C] : Senha da conta / usuario                               บฑฑ
ฑฑบ          ณExp12[C] : Porta do servidor SMTP (padrao 25)                     บฑฑ
ฑฑบ          ณExp13[C] : Nome do usuario (para autenticacao)                    บฑฑ
ฑฑบ          ณExp14[N] : Time-out                                               บฑฑ
ฑฑบ          ณExp15[L] : Gerar arquivo EML?                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EnvEML(lSSL,lTLS,lAuth,cEmissor,cDest,cCC,cBCC,cAssunto,cMens,cServ,cPWD,cPorta,cUsuario,nTOUT,lGeraArq)

Local lRet				:= .T.
Local cPath 			:= ""
Local nPos				:= 0
Local nStatusCode 		:= 0
Local MailServer 		:= tMailManager():New()
Local MailMessage 		:= tMailMessage():New()
Local cRotina			:= "[PCTBXFUN:EnvEML] "

Default cEmissor		:= ""
Default cDest			:= ""
Default cCC			:= ""
Default cBCC			:= ""
Default cAssunto		:= ""
Default cMens			:= ""
Default cServ			:= ""
Default cPWD			:= ""
Default cPorta			:= "25"
Default cUsuario		:= cEmissor
Default nTOUT			:= 30
Default lGeraArq		:= .T.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Empty(cEmissor) .OR. Empty(cDest) .OR. Empty(cServ) .OR. Empty(cPWD)
	ConOut(cRotina + "Falha no envio da mensagem SMTP por inconsistencia nos parametros.")
	Return !lRet
Endif
lSSL 	:= IIf(lSSL == Nil,.F.,lSSL)
lTLS 	:= IIf(lTLS == Nil,.F.,lTLS)
lAuth 	:= IIf(lAuth == Nil,.F.,lAuth)
cPorta	:= IIf(!Empty(cPorta),Val(cPorta),Nil)
If lGeraArq
	cPath	:= GetSrvProfString("RootPath","")
	cPath 	+= IIf(!(Left(cPath,1) == IIf(IsSrvUnix(),"/","\")),IIf(IsSrvUnix(),"/","\"),"")
Endif
// Redefine a chave Protocol com o valor POP3 na se็ใo Mail
WritePProString("Mail","Protocol","POP3",GetSrvIniName())
//Define o servidor de e-mails
If lSSL
	MailServer:SetUseSSL(.T.)
	nStatusCode := MailServer:Init("",cServ,cUsuario,cPWD,,cPorta)
ElseIf lTLS
	MailServer:SetUseTLS(.T.)
	nStatusCode := MailServer:Init("",cServ,cUsuario,cPWD,,cPorta)
Else
	nStatusCode := MailServer:Init("",cServ,cUsuario,cPWD,,cPorta)
Endif
If nStatusCode # 0
	ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
	Return !lRet
Endif
MailServer:SetSMTPTimeout(nTOUT)
//Conecta com o servidor de e-mails
ConOut(cRotina + "Tentando conexao usuario " + cUsuario)
nStatusCode := MailServer:SMTPConnect()
If nStatusCode # 0
	ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
	//Desconectar
	MailServer:SMTPDisconnect()	
	//Se o usuario possuir @, tentar conectar sem
	If (nPos := At("@",cUsuario)) > 0
		cUsuario := Substr(cUsuario,1,nPos - 1)
		nStatusCode := MailServer:Init("",cServ,cUsuario,cPWD,,cPorta)
		If nStatusCode # 0
			ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
			Return !lRet
		Endif
		ConOut(cRotina + "Tentando conexao usuario " + cUsuario)
		nStatusCode := MailServer:SMTPConnect()
	Else
		cUsuario := cEmissor
		nStatusCode := MailServer:Init("",cServ,cUsuario,cPWD,,cPorta)
		If nStatusCode # 0
			ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
			Return !lRet
		Endif
		ConOut(cRotina + "Tentando conexao usuario " + cUsuario)
		nStatusCode := MailServer:SMTPConnect()		
	Endif
	If nStatusCode # 0
		ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
		//Desconectar
		MailServer:SMTPDisconnect()
		If lGeraArq
			MailMessage:Clear()
			MailMessage:cFrom    := cEmissor
			MailMessage:cTo      := cDest
			MailMessage:cCC      := cCC
			MailMessage:cBcc     := cBCC
			MailMessage:cSubject := cAssunto
			MailMessage:cBody    := cMens
			MailMessage:Save(IIf(lSSL,cPath,cPath) + "mensagem.eml")		
		Endif
		Return !lRet
	Endif	
Endif
//O servidor de e-mails requer autentica็ใo
If lAuth
	nStatusCode := MailServer:SMTPAuth(cUsuario,cPWD)
	If nStatusCode # 0
		ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
		//Desconectar
		MailServer:SMTPDisconnect()		
		Return !lRet
  	Endif
Endif
MailMessage:Clear()
MailMessage:cFrom    := cEmissor	//Conta SMTP
MailMessage:cTo      := cDest
MailMessage:cCC      := cCC
MailMessage:cBcc     := cBCC
MailMessage:cSubject := cAssunto
MailMessage:cBody    := cMens
//Salvar
If lGeraArq
	MailMessage:Save(IIf(lSSL,cPath,cPath) + "mensagem.eml")
Endif
//Enviar
nStatusCode := MailMessage:Send(MailServer)
If nStatusCode # 0
	ConOut(cRotina + MailServer:GetErrorString(nStatusCode))
	lRet := !lRet
Else
	ConOut(cRotina + "E-mail enviado com sucesso!")
Endif
// Desconecta
MailServer:SMTPDisconnect()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณRtCT1xZ1  บAutor  ณPablo Gollan Carreras บ Data ณ29/05/12         บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para retornar contas da CT1 relacionadas com um codigo de  บฑฑ
ฑฑบ          ณcontas orcamentarias aglutinadoras (SZ1) que estao vinculadas com บฑฑ
ฑฑบ          ณuma determinada conta informada.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[O] : Codigo da conta contabil                               บฑฑ
ฑฑบ          ณExp02[A] : Opcao que determina quais os campos de retorno da CT1  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPACE                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RtCT1xZ1(cCtaOrig,nOpcRet)

Local aRet				:= {}
Local cAliasT			:= GetNextAlias()
Local cAliasT02			:= GetNextAlias()
Local cLstCCT1			:= ""
Local aTMP				:= {}
Local nQtdCR			:= 0
Local ni				:= 0

PARAMTYPE 0	VAR cCtaOrig	AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1	VAR nOpcRet		AS Numeric		OPTIONAL	DEFAULT 1

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Empty(cCtaOrig) .OR. !AliasInDic("SZ1")
	Return aRet
Endif
cCtaOrig := PadR(cCtaOrig,TamSX3("CT1_CONTA")[1])
Do Case
	Case nOpcRet == 1
		cLstCCT1 := "CT1.CT1_CONTA"
	Case nOpcRet == 2
		cLstCCT1 := "CT1.CT1_CONTA, CT1.CT1_DESC01"
	Otherwise
		cLstCCT1 := "CT1.CT1_CONTA, CT1.CT1_DESC01"
EndCase
cLstCCT1 := "%" + cLstCCT1 + "%"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPesquisar conta aglutinadora relacionada com a conta informada  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
BeginSQL Alias cAliasT
	SELECT DISTINCT SZ1.Z1_COD 
	FROM %table:SZ1% SZ1 
	WHERE SZ1.%notDel% 
	AND SZ1.Z1_FILIAL = %xFilial:SZ1% 
	AND SZ1.Z1_CONTA = %exp:cCtaOrig% 
	ORDER BY SZ1.Z1_COD ASC
EndSQL
(cAliasT)->(dbGoTop())
If !(cAliasT)->(Eof())
	Do While !(cAliasT)->(Eof())
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEncontrar contas contabeis relacionado ao codigo aglutinador  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
		BeginSQL Alias cAliasT02
			SELECT DISTINCT %exp:cLstCCT1%  
			FROM %table:CT1% CT1 
			WHERE CT1.%notDel% 
			AND CT1.CT1_FILIAL = %xFilial:CT1% 
			AND CT1.CT1_XAGLT = %exp:(cAliasT)->Z1_COD% 
			AND CT1.CT1_CLASSE = '2' AND  CT1.CT1_BLOQ <> '1' 
			ORDER BY CT1.CT1_CONTA ASC 
		EndSQL
		(cAliasT02)->(dbGoTop())
		If !(cAliasT02)->(Eof())
			Do While !(cAliasT02)->(Eof())
				nQtdCR := (cAliasT02)->(FCount())
				aTMP := Array(nQtdCR)
				For ni := 1 to nQtdCR
					aTMP[ni] := (cAliasT02)->(FieldGet(ni))
				Next ni
				aAdd(aRet,aClone(aTMP))
				(cAliasT02)->(dbSkip())
			EndDo
		Endif
		U_FecArTMP(cAliasT02)
		(cAliasT)->(dbSkip())
	EndDo
Endif
U_FecArTMP(cAliasT)

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณGDField    บAutor  ณPablo Gollan Carreras บ Data ณ07/02/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar para retorno da posicao de um determinado campo   บฑฑ
ฑฑบ          ณdentro de um header de dados.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[N] : Opcao : 1=Posicao 2=Valor dos campos solicitados       บฑฑ
ฑฑบ          ณExp02[A] : Array do header                                        บฑฑ
ฑฑบ          ณExp03[A] : Array de dados da GD                                   บฑฑ
ฑฑบ          ณExp04[N] : Posicao da coluna com o nome do campo no header        บฑฑ
ฑฑบ          ณExp05[U] : Alvo de pesquisa (Pode ser um campo ou array de campos)บฑฑ
ฑฑบ          ณExp06[N] : Linha onde os dados devem ser recuperados              บฑฑ
ฑฑบ          ณExp07[N] : Coluna de dados utilizada legenda?                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณuRet[N] : Retorno [1] Posicao campo [2] Valor do campo            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GDField(nOpc,aHead,aDados,nPosCmp,cAlvo,nLinha,lUsaLeg)

Local uRet				:= Nil
Local ni				:= 0
Local nx				:= 0
Local aCMP				:= {}
Local aPos				:= {}
Local cTMP				:= ""

Default nOpc			:= 1
Default aHead			:= {}
Default aDados			:= {}
Default nPosCmp		:= 1
Default cAlvo			:= ""
Default nLinha			:= IIf(Type("n") == "U" .OR. Empty(n),1,n)
Default lUsaLeg		:= .F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If !cValToChar(nOpc) $ "1|2" .OR. ValType(aHead) # "A" .OR. Len(aHead) == 0 .OR. ValType(nPosCmp) # "N" .OR. Empty(nPosCmp) .OR. nPosCmp > Len(aHead[1]) .OR. ;
	(ValType(cAlvo) # "C" .AND. ValType(cAlvo) # "A") .OR. Empty(cAlvo)
	
	Return uRet
Else
	If nOpc == 2 .AND. (ValType(aDados) # "A" .OR. Len(aDados) == 0 .OR. Empty(nLinha))
		Return uRet
	Endif
Endif
//Alimentar a lista de campos de retorno
Do Case
	Case ValType(cAlvo) == "A"
		For ni := 1 to Len(cAlvo)
			aAdd(aCMP,cAlvo[ni])
		Next ni
	Otherwise
		aAdd(aCMP,cAlvo)
EndCase
//Configurar o tamanho do array de posicoes de acordo com o tamanho do da lista de campos
aPos := Array(Len(aCMP))
For ni := 1 to Len(aPos)
	aPos[ni] := 0
Next ni
//Pesquisa posicao dos campos
For nx := 1 to Len(aCMP)
	For ni := 1 to Len(aHead)
		//Validar se o nome do campo esta dentro de uma estrutura ou declarado diretamente
		If ValType(aHead[1]) == "A"
			cTMP := PadR(aHead[ni][nPosCmp],10)
		Else
			cTMP := PadR(aHead[ni],10)
		Endif
		//Comparar nome dos campos
		If PadR(aCMP[nx],10) == cTMP
			aPos[nx] := ni + IIf(lUsaLeg,1,0)
			Exit
		Endif
	Next ni
Next nx
If Len(aCMP) == 1
	//Apenas um campo retornar posicao ou valor fora de array
	If nOpc == 2 .AND. aPos[1] # 0
		If ValType(aDados[nLinha]) == "A"
			uRet := aDados[nLinha][aPos[1]]
		Else
			uRet := aDados[aPos[1]]
		Endif
	Else
		uRet := aPos[1]
	Endif
Else
	//Mais de um campo, retornar posicoes ou valores atraves de um array
	uRet := Array(Len(aCMP))
	For ni := 1 to Len(aCMP)
		If nOpc == 2 .AND. aPos[ni] # 0
			If ValType(aDados[nLinha]) == "A"
				uRet[ni] := aDados[nLinha][aPos[ni]]
			Else
				uRet[ni] := aDados[aPos[ni]]
			Endif		
		Else
			uRet[ni] := aPos[ni]
		Endif
	Next ni
Endif

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntHTMCb   บAutor  ณPablo Gollan Carreras บ Data ณ25/05/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta um cabecalho de um arquivo HTML                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Titulo do arquivo                                      บฑฑ
ฑฑบ          ณExp02[C] : Link do logo da empresa ou o desejado                  บฑฑ
ฑฑบ          ณExp03[L] : Imprimir dados da empresa                              บฑฑ
ฑฑบ          ณExp04[L] : Imprimir linha de quebra                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcCabec[C] : Cabecalho em formato HTML                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MntHTMCb(cTituloM,cLinkLOGO,lEmpresa,lQuebra)

Local cCabec			:= ""

PARAMTYPE 0	VAR cTituloM	AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1	VAR cLinkLOGO	AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 2	VAR lEmpresa	AS Logical		OPTIONAL	DEFAULT .T.
PARAMTYPE 3	VAR lQuebra		AS Logical		OPTIONAL	DEFAULT .T.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cCabec := '<html><head>' + CRLF
cCabec += '<title>' + Upper(cTituloM) + '</title>' + CRLF
cCabec += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CRLF
cCabec += '</head>' + CRLF
//FORM
cCabec += '<form name="FORM">' + CRLF
cCabec += '<div align="center">' + CRLF
cCabec += '<table background="" border="0" cellpadding="0" cellspacing="0" width="100%">' + CRLF
cCabec += '<tbody>' + CRLF
cCabec += '<tr>' + CRLF
cCabec += '<td height="84">' + CRLF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCABECALHO PRINCIPAL  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCabec += '<table border="0" cellpadding="0" cellspacing="0" width="100%">' + CRLF
cCabec += '<tbody>' + CRLF
cCabec += '<tr>' + CRLF
cCabec += '<td height="16" width="33%">' + CRLF
cCabec += '<div align="left">' + IIf(!Empty(cLinkLOGO),'<img src="' + RTrim(cLinkLOGO) + '" height="65" width="170">','') + '</div>' + CRLF
cCabec += '</td>' + CRLF
cCabec += '<td height="16" width="33%">' + CRLF
cCabec += '<div align="center"><font face="Arial, Helvetica, sans-serif" size="2"><b><font size="4">' + cTituloM + '</font></b></font></div>' + CRLF
cCabec += '</td>' + CRLF
cCabec += '<td height="16" valign="top" width="34%"> <br>' + CRLF
cCabec += '</td>' + CRLF
cCabec += '</tr>' + CRLF
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDADOS DA EMPRESA  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lEmpresa
	cCabec += '<tr>' + CRLF
	cCabec += '<td colspan="2" height="41"><b><font face="Arial, Helvetica, sans-serif" size="1">' + SM0->M0_NOMECOM + '<br></font></b>' + CRLF
	cCabec += '<font face="Arial, Helvetica, sans-serif" size="1">' + "CNPJ : " + SM0->M0_CGC + '<br>' + CRLF
	cCabec += SM0->M0_ENDENT + '<br>' + CRLF
	cCabec += "CEP: " + RTrim(SM0->M0_CEPENT) + "- Tel. " + RTrim(SM0->M0_TEL) + '<br>' + CRLF
	cCabec += '</font></td>' + CRLF
	cCabec += '<td height="41" valign="top" width="34%"> <br>' + CRLF
	cCabec += '</td>' + CRLF
	cCabec += '</tr>' + CRLF
Endif
cCabec += '</tbody>' + CRLF
cCabec += '</table>' + CRLF
//QUEBRA DE LINHA
If lQuebra
	cCabec += '<tr>' + CRLF
	cCabec += '<td>' + CRLF
	cCabec += '<hr noshade="noshade">' + CRLF
	cCabec += '</td>' + CRLF
	cCabec += '</tr>' + CRLF
Endif

Return cCabec

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntHTMIt   บAutor  ณPablo Gollan Carreras บ Data ณ25/05/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta cabecalho e conteudo de uma lista de itens                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Lista de campos, com a seguinte estrutura :            บฑฑ
ฑฑบ          ณ           [1] Nome do campo                                      บฑฑ
ฑฑบ          ณ           [2] Tamanho do campo                                   บฑฑ
ฑฑบ          ณ           [3] Titulo                                             บฑฑ
ฑฑบ          ณ           [4] Picture de formatacao de dados                     บฑฑ
ฑฑบ          ณExp02[A] : Array com a lista de valores                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcMens[C] : Bloco de itens em formato HTML                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MntHTMIt(aLstC,aLstVal,cTitulo,cRodape,lQuebra)

Local cMens				:= ""
Local nEspTotH			:= 0
Local ni				:= 0
Local nx				:= 0
Local nz				:= 0
Local cMasc				:= ""

PARAMTYPE 0	VAR aLstC		AS Array
PARAMTYPE 1	VAR aLstVal		AS Array
PARAMTYPE 2	VAR cTitulo		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 3	VAR cRodape		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 4	VAR lQuebra		AS Logical		OPTIONAL	DEFAULT .F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Len(aLstC) # Len(aLstVal[1])
	Return cMens
Endif
If !Empty(cTitulo)
	cMens += '<table style="width: 100%;" nowrap="1" background="" border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0">' + CRLF
	cMens += '<tr><td>' + CRLF
	cMens += '<font face="Arial, Helvetica, sans-serif" size="4"><b>' + cTitulo + '</b></font>' + CRLF
	cMens += '</td></tr>'
	cMens += '</table>'
Endif
cMens += '<table style="width: 100%;" nowrap="1" background="" border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0">' + CRLF
cMens += '<thead> <tr bgcolor="#cccccc">' + CRLF
//Levantar o espacamento total das colunas
nEspTotH := 0
aEval(aLstC,{|x| nEspTotH += x[POS_HT_TAM]})
For ni := 1 to Len(aLstC)
	cMens += '<td height="' + cValToChar(Int((aLstC[ni][POS_HT_TAM] / nEspTotH) * 100)) + '">' + CRLF
	cMens += '<div align="left"><b><font face="Arial, Helvetica, sans-serif" size="1">' + Capital(AllTrim(aLstC[ni][POS_HT_TIT])) + '</font></b></div>' + CRLF
	cMens += '</td>' + CRLF
Next ni	
//ฺฤฤฤฤฤฤฤฟ
//ณITENS  ณ
//ภฤฤฤฤฤฤฤู
cMens += '<tbody>' + CRLF
For nx := 1 to Len(aLstVal)
	cMens += '<tr>' + CRLF
	For ni := 1 to Len(aLstC)
		cCmpAt := aLstC[ni][POS_HT_CMP]
		If Empty(cMasc := aLstC[ni][POS_HT_PIC])
			If Empty(cMasc := GetSX3Cache(cCmpAt,"X3_PICTURE"))
				cMasc := "@!"
			Endif
		Endif
		cMens += '<td>&nbsp;<font face="Verdana" size="1">' + Transform(aLstVal[nx][ni],cMasc) + '</font></td>' + CRLF
	Next ni
	cMens += '</tr>' + CRLF
Next nx
cMens += '</tbody>' + CRLF
cMens += '</table>'
//ฺฤฤฤฤฤฤฤฤฟ
//ณQUEBRA  ณ
//ภฤฤฤฤฤฤฤฤู
If lQuebra
	cMens += '<tr>' + CRLF
	cMens += '<td>' + CRLF
	cMens += '<hr noshade="noshade">' + CRLF
	cMens += '</td>' + CRLF
	cMens += '</tr>' + CRLF
Endif
//ฺฤฤฤฤฤฤฤฤฟ
//ณRODAPE  ณ
//ภฤฤฤฤฤฤฤฤู
If !Empty(cTitulo)
	If !lQuebra
		cMens += "<p>" + CRLF
	Endif
	cMens += '<table style="width: 100%;" nowrap="1" background="" border="0" bordercolor="#cccccc" cellpadding="0" cellspacing="0">' + CRLF
	cMens += '<tr><td>' + CRLF
	cMens += '<font face="Arial, Helvetica, sans-serif" size="1">' + cRodape + '</font><p>' + CRLF
	cMens += '</td></tr>'
	cMens += '</table>'
Endif

Return cMens

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณMntHTMRd   บAutor  ณPablo Gollan Carreras บ Data ณ25/05/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMonta o rodape do arquivo HTML, deve trabalhar c/ os outros comp. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcRodape[C] : Cabecalho em formato HTML                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MntHTMRd()

Local cRodape 			:= ""

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cRodape := '</tbody>' + CRLF
cRodape += '</tbody>' + CRLF
cRodape += '</table>' + CRLF
cRodape += '</div>' + CRLF
cRodape += '</form>' + CRLF
cRodape += '</body></html>' + CRLF

Return cRodape



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO2     บAutor  ณMicrosiga           บ Data ณ  10/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCaptura o proximo numero de fornecedores e cliente em detri บฑฑ
ฑฑบ          ณmento da funcao padrao getsx8num, devido a cadastros que    บฑฑ
ฑฑบ          ณinicia com F ou C (expense)                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADP - Protheus 11                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function NextNum(cAlias,cCampo,lValid)

Local cNum       	 :=StrZero(1,TamSx3(cCampo)[1])
Local cAliasTop  	 := GetNextAlias()
Local cQuery                              

Default lValid		:=.F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cQuery := "SELECT MAX(" + cCampo + ") AS NUM" 
cQuery += "FROM   " + RetSqlName(cAlias) + " "
cQuery += "WHERE " + Substring(cAlias,2,2) + "_FILIAL = '" + XFILIAL(cAlias) + "' " 
If cAlias<>"SF1"
	cQuery += "AND D_E_L_E_T_ =' ' "
EndIf


cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasTop, .F., .T.)

If (cAliasTop)->(!EOF()) .and. !Empty((cAliasTop)->NUM)
	cNum	:= Soma1(Alltrim((cAliasTop)->NUM))
EndIF

(cAliasTop)->(dbCloseArea())

If lValid

	M->&(cCampo) := cNum
	
EndIf
	
Return cNum

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCCSKFXFUN บAutor  ณMicrosiga           บ Data ณ  11/20/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CCSKFWF(cChave)

Local _nTotSC6:= 0

DBSelectArea("SC5")
DBSetOrder(1)
DbSeek(cChave)

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_cMens2 := " "
_cMens1 := '<html>'
_cMens1 += '<head>'
_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
_cMens1 += '<title>Pedido Cortado</title>'
_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
_cMens1 += '</head>'
_cMens1 += '<body bgcolor="#C0C0C0">'
_cMens1 += '<center>'
_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
_cMens1 += '<tr height="80">'
_cMens1 += '</tr>'
_cMens1 += '</center>'
_cMens1 += '<tr>'
_cMens1 += '<td width="100%" bgcolor="#386079">'
_cMens1 += '<div align="left">'
_cMens1 += '<table border="1" width="100%">'
_cMens1 += '<tr>'
_cMens1 += '<td width="982" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
_cMens1 += '<b><font face="Arial" color="#FFFFFF" size="4">Pedido: '+SC5->C5_NUM+'</font></b>'
_cMens1 += '</td></tr>'
_cMens1 += '</table>'
_cMens1 += '</div>'
_cMens1 += '</td>'
_cMens1 += '</tr>'
_cMens1 += '<center>'
_cMens1 += '<tr>'
_cMens1 += '<td width="100%">'
_cMens1 += '<table border="1" width="982">'
_cMens1 += '<tr>'
_cMens1 += '<td width="87" bgcolor="#FAA21B"><font face="Arial" size="1">Cod.Cliente:</font></td>'
_cMens1 += '<td width="38" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CLIENTE+'</font></td>'
_cMens1 += '</center>'
_cMens1 += '<td width="25" bgcolor="#FAA21B">'
_cMens1 += '<p align="right"><font face="Arial" size="1">Loja:</font></td>'
_cMens1 += '<center>'
_cMens1 += '<td width="17" bgcolor="#FFFFFF">'
_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_LOJACLI+'</font></td>'
_cMens1 += '</center>'
_cMens1 += '<td width="36" bgcolor="#FAA21B">'
_cMens1 += '<p align="right"><font face="Arial" size="1">Nome:</font></td>'
_cMens1 += '<center>'
_cMens1 += '<td width="751" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_NOMECLI+'</font></td>'
_cMens1 += '</tr>'
_cMens1 += '</table>'
_cMens1 += '<table border="1" width="982">'
_cMens1 += '<tr>'
_cMens1 += '<td width="8%" bgcolor="#FAA21B"><font face="Arial" size="1">Endere็o:</font></td>'
_cMens1 += '<td width="41%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ENDERE+'</font></td>'
_cMens1 += '<td width="4%" bgcolor="#FAA21B"><font face="Arial" size="1">Bairro:</font></td>'
_cMens1 += '<td width="17%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_BAIRRO+'</font></td>'
_cMens1 += '<td width="5%" bgcolor="#FAA21B"><font face="Arial" size="1">Cidade:</font></td>'
_cMens1 += '<td width="40%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CIDADE+'</font></td>'
_cMens1 += '</tr>'
_cMens1 += '</table>'
_cMens1 += '</tr>'
_cMens1 += '</table>'
_cMens1 += '<center><table border="1" width="982">'
_cMens1 += '<tr>'
_cMens1 += '<td width="6%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Roteiro:</font></td>'
_cMens1 += '<td width="44%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ROTEIRO+'</font></td>'
_cMens1 += '<td width="7%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Sequ๊ncia:</font></td>'
_cMens1 += '<td width="43%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_SEQUENC+'</font></td>'
_cMens1 += '</tr>'
_cMens1 += '</table>'
_cMens1 += '<table border="1" width="982">'
_cMens1 += '<tr>'
_cMens1 += '<td width="170" bgcolor="#FAA21B"><font face="Arial" size="1">Condi็ใo de Pagamento:</font></td>'
_cMens1 += '<td width="81" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CONDPAG+'</font></td>'
_cMens1 += '<td width="84" bgcolor="#FAA21B"><font face="Arial" size="1">Vencimento:</font></td>'
_cMens1 += '<td width="168" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DATA1)+'</font></td>'
_cMens1 += '<td width="46" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Emissใo:</font></td>'
_cMens1 += '<td width="393" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DTENTR)+'</font></td>'
_cMens1 += '</tr>'
_cMens1 += '</table>'
_cMens1 += '<table border="1" width="982">'
_cMens1 += '<tr>'
_cMens1 += '<td width="7%" bgcolor="#FAA21B">'
_cMens1 += '<p align="center"><font size="1" face="Arial">Vendedor:</font></p>'
_cMens1 += '</td>'
_cMens1 += '<td width="12%" bgcolor="#FFFFFF">'
_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_VEND1+'</font></p>'
_cMens1 += '</td>'
_cMens1 += '<td width="15%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Carteira:</font></td>'
_cMens1 += '</center>'
_cMens1 += '<td width="66%" bgcolor="#FFFFFF">'


DBSelectArea("SA3")
DBSetOrder(1)
DBSeek(XFilial("SA3")+SC5->C5_VEND1)
_cMens1 += '<p align="left"><font face="Arial" size="1">'+UPPER(ALLTRIM(SA3->A3_NOME))+'</font></p>'
_cMens1 += '</td></tr></table><center>'
_cMens1 += '<table border="1" width="982">'
_cMens1 += '<tr>'
_cMens1 += '</table></center>'
_cMens1 += '<table border="1" cellpadding="0" cellspacing="2" width="982">'
_cMens1 += '<tr>'
_cMens1 += '<td align="center" bgcolor="#FAA21B" width="1468" colspan="9">'
_cMens1 += '<p align="center"><font face="Arial" size="1">Itens com corte no Pedido</font></td>'
_cMens1 += '</tr></center>'
_cMens1 += '<tr>'
_cMens1 += '<td width="14" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Item</b></font></td>'
_cMens1 += '<td width="50" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Produto</b></font></td>'
_cMens1 += '<td width="544" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1" color="#FFFFFF"><b>Descri็ใo</b></font></td>'
_cMens1 += '<td width="57" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial"  color="#FFFFFF"><b>TES</b></font></p></td>'
_cMens1 += '<td width="192" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Opera็ใo</b></font></p></td>'
_cMens1 += '<td width="42" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>UM</b></font></td>'
_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Qtde orig </b></font></td>'
_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Quantidade</b></font></td>'
_cMens1 += '<td width="244" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor Unitแrio</b></font></td>'
_cMens1 += '<td width="263" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor</b></font></td>'
_cMens1 += '</tr>'


DBSelectArea("SC6")
DBSetOrder(1)
DbSeek(XFilial("SC6")+SC5->C5_NUM)
If found()
Endif

_lEntrCrt := .F.
//WHILE SC6->C6_NUM == SC5->C5_NUM - Marcelo Vicente - 20100619
WHILE SC6->(!Eof()) .And. xFilial("SC6")==SC6->C6_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
	iF SC6->C6_QTDORI == SC6->C6_QTDVEN
		DBSKIP()
		LOOP
	Endif
	_lEntrCrt := .T.
	_cMens2  += '<tr>'
	_cMens2  += '<td width="14"  bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC6->C6_ITEM+'</font></td>'
	_cMens2  += '<td width="50"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_PRODUTO+'</font></td>'
	_cMens2  += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_DESCRI+'</font></td>'
	_cMens2  += '<td width="57"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_TES+'</font></p></td>'
	_cMens2  += '<td width="192" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+SC6->C6_TES,"F4_TEXTO")+'</font></td>'
	_cMens2  += '<td width="42"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_UM+'</font></p></td>'
	_cMens2  += '<td width="91"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_QTDORI,"@!")+'</font></p></td>'
	_cMens2  += '<td width="91"  bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_QTDVEN,"@!")+'</font></p></td>'
	_cMens2  += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</font></p></td>'
	_cMens2  += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_VALOR,"@E 999,999,999.99")+'</font></p></td>'
	_cMens2  += '</tr>'
	_nTotSC6 += SC6->C6_VALOR
	DBSKIP()
END

If _nTotSC6>0

	_cMens3 := '<tr>'
	_cMens3 += '<td width="1325" bgcolor="#386079" colspan="8">'
	_cMens3	+= '<p align="right"><font face="Arial" size="1" color="#FFFFFF"><b>TOTAL DO PEDIDO</b></font></td>'
	_cMens3	+= '<td width="263" bgcolor="#FFFFFF"><font face="Arial" size="1">'+TRANSFORM(_nTotSC6,"@E 999,999,999.99")+'</font></td>'
	_cMens3	+= '</tr>'
	_cMens3	+= '</table>'
	_cMens3	+= '</td>'
	_cMens3	+= '</tr>'
	_cMens3	+= '<center>'
	_cMens3	+= '<tr>'
	_cMens3	+= '<td width="100%" bgcolor="#386079" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
	_cMens3	+= '<p align="center">'
	_cMens3	+= '<font face="Arial" size="1" color="#FFFFFF"><b>Email Enviado Automaticamente pelo Sistema Protheus by Adoro Informแtica</b></font>'
	_cMens3	+= '</p>'
	_cMens3	+= '</td>'
	_cMens3	+= '</tr>'
	_cMens3	+= '</table>'
	_cMens3	+= '</center>'
	_cMens3	+= '</body>'
	_cMens3	+= '</html>'
	
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
	_eMailVend := SA3->A3_EMAIL
	
	DbSelectArea("SZR")
	DbSetOrder(1)
	DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
	_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))
	
	IF !Empty(Getmv("mv_mailtst"))
		cEmail := Alltrim(Getmv("mv_mailtst"))
	ELSE
//		cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))
		cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))+';'+Alltrim(GetMv("mv_emails2"))	// Em 25/09/2014 incluido o parโmetro MV_EMAILS2
	ENDIF
	
	
	_cMens    := _cMens1+_cMens2+_cMens3
	_cData    := transform(MsDate(),"@!")
	_cHora    := transform(Time(),"@!")
	_cPedMail := SC5->C5_NUM
	
	
	lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+_cPedMail+" ,PEDIDO CORTADO - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
Else
	If _lEntrCrt

		_cMens3 := '<tr>'
		_cMens3 += '<td width="1325" bgcolor="#386079" colspan="8">'
		_cMens3	+= '<p align="right"><font face="Arial" size="1" color="#FFFFFF"><b>TOTAL DO PEDIDO</b></font></td>'
		_cMens3	+= '<td width="263" bgcolor="#FFFFFF"><font face="Arial" size="1">'+TRANSFORM(_nTotSC6,"@E 999,999,999.99")+'</font></td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '</table>'
		_cMens3	+= '</td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '<center>'
		_cMens3	+= '<tr>'
		_cMens3	+= '<td width="100%" bgcolor="#386079" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
		_cMens3	+= '<p align="center">'
		_cMens3	+= '<font face="Arial" size="1" color="#FFFFFF"><b>Email Enviado Automaticamente pelo Sistema Protheus by Adoro Informแtica</b></font>'
		_cMens3	+= '</p>'
		_cMens3	+= '</td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '</table>'
		_cMens3	+= '</center>'
		_cMens3	+= '</body>'
		_cMens3	+= '</html>'
		
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
		_eMailVend := SA3->A3_EMAIL
	
		DbSelectArea("SZR")
		DbSetOrder(1)
		DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
		_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))
	
		IF !Empty(Getmv("mv_mailtst"))
			cEmail := Alltrim(Getmv("mv_mailtst"))
		ELSE
//			cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))
			cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))+';'+Alltrim(GetMv("mv_emails2")) // Em 24/09/2014			
		ENDIF	
	
		_cMens    := _cMens1+_cMens2+_cMens3
		_cData    := transform(MsDate(),"@!")
		_cHora    := transform(Time(),"@!")
		_cPedMail := SC5->C5_NUM
	
		lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+_cPedMail+" ,PEDIDO CORTADO - "+_cData+" - "+_cHora,"") //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
		
	Endif		
EndIf
			
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetErro  บAutor  ณMicrosiga           บ Data ณ  11/21/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna erro na integra็ใo com Edata                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


User Function RetErroED()

Local cQuery 			:= ""
Local cAliasERR	    	:= CriaTrab(NIL,.F.)	
Local cErro				:= ""

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')


	cQuery := "SELECT * FROM [LNKMIMS].[SMART].[dbo].[VW_ERRO_01] "
	cQuery := ChangeQuery(cQuery)		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasERR,.T.,.F.)
	
	DbSelectArea(cAliasERR)
	Dbgotop()
	
	While (cAliasERR)->(!EOF())

		cErro += "- Erro : [" + AllTrim((cAliasERR)->MENSAGEM) + "]"  + CRLF			
				
		DbSelectArea(cAliasERR)		
		(cAliasERR)->(DbSkip())
	EndDo

	
Return cErro 

/*/{Protheus.doc} User Function SelNfDev
	Mostra tela para pesquisa de Notas de Remessa.
	@type  Function
	@author 
	@since 31/07/2010
	@version 01
	@history chamado 12079 - Leonardo P. Monteiro - 09/04/2021 - Atualiza็ใo da rotina para preenchimento dos campo D1_UM, D1_SEGUM, D1_CTRDEVO e D1_XPLACAS.
	@history chamado 12079 - Leonardo P. Monteiro - 14/04/2021 - Adi็ใo do campo Placa Substitutiva para edi็ใo.
/*/

User Function SelNfDev()

Local aArea			:= GetArea()
Local cTitulo 		:= "Sele็ใo Item Nota Fiscal Devolu็ใo"
Local cAliasTmp		:= GetNextAlias()
Local oDlg    		:= Nil
Local nOpc    		:= 0
Local nSelect 		:= 0
Local aRet			:= {}
Local nPosSerie		:= 2
Local nPosItem		:= 3
Local nPosCod		:= 4
Local nPosSegum		:= 5
Local nPosUm		:= 6
Local nPosQuant		:= 7
Local nPosPrc		:= 8
Local nPosEmiss		:= 9
Local nPosRegis		:= 10
Local cOcorrenc		:= Space(16)

Local aSays			:= Array(1)
Local aGets			:= Array(1)
Local cProduto		:= aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_COD"		} 	)]
Private cPlacas		:= Space(08)
Private aArray		:= {}
Private nPosDoc		:= 1

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If cTipo <> "D"
	Aviso("CCSKFXFUN","Fun็ใo permitida apenas para notas de devolu็ใo!",{"OK"},3)
	RestArea( aArea )
	Return
EndIf


cQuery := " SELECT "
cQuery += "    SD2.D2_DOC, "
cQuery += "    SD2.D2_SERIE, "
cQuery += "    SD2.D2_CLIENTE, "
cQuery += "    SD2.D2_LOJA, "
cQuery += "    SD2.D2_ITEM, "
cQuery += "    SD2.D2_COD, "
cQuery += "    SD2.D2_PRCVEN, "
cQuery += "    SD2.D2_EMISSAO, "
cQuery += "    SD2.D2_SEGUM, "
cQuery += "    SD2.D2_UM, "
cQuery += "    SD2.R_E_C_N_O_ AS SD2REC, "
cQuery += "    SD2.D2_QUANT-SD2.D2_QTDEDEV SALDO "
cQuery += " FROM "
cQuery +=      RetSqlname( "SD2" ) + " SD2, "	
cQuery +=      RetSqlname( "SF4" ) + " SF4 "	
cQuery += " WHERE
cQuery += "	       SD2.D_E_L_E_T_  <> '*' "
cQuery += "	   AND SF4.D_E_L_E_T_  <> '*' "
cQuery += "	   AND SD2.D2_FILIAL    = '" + xFilial( "SD2" ) + "'"
cQuery += "	   AND SF4.F4_FILIAL    = '" + xFilial( "SF4" ) + "'"
cQuery += "	   AND SD2.D2_TES       = SF4.F4_CODIGO " 
//cQuery += "	   AND SF4.F4_TESDEV    = '" + cTesDev  + "'"
cQuery += "	   AND SF4.F4_ESTOQUE   = 'S' "
cQuery += "	   AND SD2.D2_CLIENTE   = '" + cA100For + "'"
cQuery += "	   AND SD2.D2_LOJA      = '" + cLoja    + "'"
cQuery += "	   AND SD2.D2_COD       = '" + cProduto + "'"
cQuery += "	   AND SD2.D2_TIPO='N' " 
cQuery += "	   AND SD2.D2_QUANT-SD2.D2_QTDEDEV>0 " 
cQuery += "	   AND NOT EXISTS (SELECT 1 FROM " + RetSqlname( "SD1" ) + " SD1 WHERE SD1.D1_TIPO='D' AND SD1.D1_TES='' AND SD1.D1_COD=SD2.D2_COD AND SD1.D1_NFORI=SD2.D2_DOC "      
cQuery += "	   AND SD1.D1_ITEMORI=SD2.D2_ITEM AND SD1.D1_FORNECE=SD2.D2_CLIENTE AND SD1.D1_LOJA=SD2.D2_LOJA AND SD1.D1_QUANT=SD2.D2_QUANT-SD2.D2_QTDEDEV "
cQuery += "	   AND SD1.D_E_L_E_T_='') "
cQuery += " ORDER BY SD2.R_E_C_N_O_ DESC "
cQuery := ChangeQuery( cQuery )
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

TCSetField((cAliasTmp),"D2_EMISSAO"	,"D",TamSx3("D2_EMISSAO")[1]		,TamSx3("D2_EMISSAO")[2]	)

	
If (cAliasTmp)->( !Eof() )

	Do While (cAliasTmp)->( !Eof() ) 

		aAdd(	aArray,	{ 	(cAliasTmp)->D2_DOC,;
                   			(cAliasTmp)->D2_SERIE,;
                   			(cAliasTmp)->D2_ITEM,;
                   			(cAliasTmp)->D2_COD,;
							(cAliasTmp)->D2_UM,;
							(cAliasTmp)->D2_SEGUM,;
                   			(cAliasTmp)->SALDO,;
							(cAliasTmp)->D2_PRCVEN,;                   			
							(cAliasTmp)->D2_EMISSAO,;
							(cAliasTmp)->SD2REC } )                        

		(cAliasTmp)->( DBSkip() ) 	
	
	Enddo
	
Endif	

(cAliasTmp)->( DBCloseArea() )

If Len( aArray ) > 0 

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,00 TO 370, 600 OF oMainWnd PIXEL

//	@ 005, 003 TO 100, 290 Label "Nota a ser Devolvida" OF oDlg PIXEL
//	@ 015, 007 LISTBOX  oListXml VAR cList FIELDS HEADER "N๚mero","S้rie","Item","Produto","Saldo","Pre็o", "RECNO" SIZE 280, 080 OF oDlg PIXEL
//	oListXml:SetArray( aNfXml )
//	oListXml:bLine	:= { || aNfXml[oListBox:nAt] }
	
	@ 005, 003 TO 100, 290 Label "Item da Nota Original de Remessa ( Selecionar o item )" OF oDlg PIXEL
	@ 015, 007 LISTBOX  oListBox VAR cList FIELDS HEADER "N๚mero","S้rie","Item","Produto","Saldo","Pre็o", "Emissao", "RECNO" SIZE 280, 080 OF oDlg PIXEL

	oListBox:SetArray( aArray )
	oListBox:bLine	:= { || aArray[oListBox:nAt] }                                 
	
	@ 105, 003 TO 140, 290 Label "Op็๕es Adicionais" OF oDlg PIXEL
	
	@ 115,010 SAY OemToAnsi('Ocorr๊ncia:')		SIZE 030,025 	OF oDlg COLORS 0 PIXEL
	@ 125,010 MSGET cOcorrenc					SIZE 080,008	OF oDlg PIXEL When .T. F3 "SZD3" VALID fVldOc(cOcorrenc, .T.) .OR. VAZIO()

	@ 115,140 SAY OemToAnsi('Placa Substitutiva:')		SIZE 060,025 	OF oDlg COLORS 0 PIXEL
	@ 125,140 MSGET cPlacas					SIZE 080,008	OF oDlg PIXEL When .T. F3 "ZV4" VALID ExistCpo("ZV4") .OR. VAZIO()

	DEFINE SBUTTON FROM 145, 228 TYPE 1 ACTION ( nOpc := 1 , nSelect := oListBox:nAt, oDlg:End()) ENABLE Of oDlg
	DEFINE SBUTTON FROM 145, 258 TYPE 2 ACTION oDlg:End() ENABLE Of oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc == 1 .And. nSelect > 0 .and. fVldOc(cOcorrenc, .F.)
		/*
		Local nPosDoc		:= 1
		Local nPosSerie		:= 2
		Local nPosItem		:= 3
		Local nPosCod		:= 4
		Local nPosUM		:= 5
		Local nPosSegum		:= 6
		Local nPosQuant		:= 7
		Local nPosPrc		:= 8
		Local nPosEmiss		:= 9
		Local nPosRegis		:= 10
		*/
		/*
		If !Empty(cOcorrenc)
			cPlacas	:= Posicione("SZD",4,xFilial("SZD")+cOcorrenc,"ZD_XPLACAS")
		Endif
		*/

		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_NFORI"		} 	)] := aArray[ nSelect, nPosDoc   ]
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_SERIORI"	} 	)]     := aArray[ nSelect, nPosSerie ]
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_ITEMORI"		} 	)] := aArray[ nSelect, nPosItem  ]
		//@history chamado 12079 - Leonardo P. Monteiro - 09/04/2021 - Atualiza็ใo da rotina para preenchimento dos campo D1_UM, D1_SEGUM, D1_CTRDEVO e D1_XPLACAS.
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_UM"			} 	)] := aArray[ nSelect, nPosUM 	 ]
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_SEGUM"		} 	)] := aArray[ nSelect, nPosSegum ]
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_XPLACAS"		} 	)] := cPlacas
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_CTRDEVO"		} 	)] := cOcorrenc
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_QUANT"		} 	)] := aArray[ nSelect, nPosQuant ]	
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_VUNIT"		} 	)] := aArray[ nSelect, nPosPrc   ]	
		aCols[N][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_TOTAL"		} 	)] := aArray[ nSelect, nPosQuant ]	* aArray[ nSelect, nPosPrc ]	
	
	Endif	              

Else

	Aviso("CCSKFXFUN","Nใo existem notas pendentes de devolu็ใo!!!",{"OK"},3)
	RestArea( aArea )
	
Endif

RestArea( aArea )

Return()

/*/{Protheus.doc} User Function SelDevT
	Mostra tela para pesquisa de Notas de Remessa.
	@type  Function
	@author 
	@since 31/07/2010
	@version 01
	@history chamado 12079 - Leonardo P. Monteiro - 09/04/2021 - Atualiza็ใo da rotina para preenchimento dos campo D1_UM, D1_SEGUM, D1_CTRDEVO e D1_XPLACAS.
	@history chamado 12079 - Leonardo P. Monteiro - 14/04/2021 - Adi็ใo do campo Placa Substitutiva para edi็ใo.
	
/*/
User Function SelDevT()

Local aArea			:= GetArea()
Local cTitulo 		:= "Sele็ใo Nota Fiscal Devolu็ใo Total"
Local cAliasTmp		:= GetNextAlias()
Local oDlg    		:= Nil
Local nOpc    		:= 0
Local nSelect 		:= 0
Local aRet			:= {}
Local cOcorrenc		:= Space(16)
Local cItem		 	:= StrZero(1,TAMSX3("C6_ITEM")[1])

Local aSays			:=Array(1)
Local aGets			:=Array(1)
Local nX
Private cPlacas		:= Space(8)
Private aArray		:= {}
Private nPosDoc		:= 1
Private nPosSerie	:= 2
Private nPosCli		:= 3
Private nPosLoja	:= 4
Private nPosEmis	:= 5
Private nPosRec		:= 6


U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If cTipo <> "D"
	Aviso("CCSKFXFUN","Fun็ใo permitida apenas para notas de devolu็ใo!",{"OK"},3)
	RestArea( aArea )
	Return
EndIf


// FWNM - 16/04/2018 - CHAMADO 041019

// QUERY OTIMIZADA - FWNM
//cQuery := " SELECT DISTINCT SF2.F2_DOC,     SF2.F2_SERIE,     SF2.F2_CLIENTE,     SF2.F2_LOJA,     SF2.F2_EMISSAO,     SF2.R_E_C_N_O_ AS SF2REC "  
cQuery := " SELECT DISTINCT SF2.F2_DOC,     SF2.F2_SERIE,     SF2.F2_CLIENTE,     SF2.F2_LOJA,     SF2.F2_EMISSAO,     SF2.R_E_C_N_O_ AS SF2REC "
cQuery += "	FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4 "
cQuery += "	WHERE F2_FILIAL=D2_FILIAL "
cQuery += "	AND F2_DOC=D2_DOC "
cQuery += "	AND F2_SERIE=D2_SERIE "
cQuery += "	AND F2_CLIENTE=D2_CLIENTE "
cQuery += "	AND F2_LOJA=D2_LOJA "
cQuery += "	AND D2_TES=F4_CODIGO "
cQuery += "	AND F2_FILIAL='"+xFilial("SF2")+"' "
cQuery += "	AND F2_CLIENTE='"+cA100For+"' "
cQuery += "	AND F2_LOJA='"+cLoja+"' "
cQuery += "	AND F2_TIPO='N' "
cQuery += "	AND SF2.D_E_L_E_T_='' "
cQuery += "	AND SD2.D_E_L_E_T_='' "
cQuery += "	AND F4_ESTOQUE='S' "
cQuery += "	AND SF4.D_E_L_E_T_='' "
cQuery += "	AND NOT EXISTS ( "
cQuery += "	SELECT 1 "
cQuery += "	FROM " + RetSqlName("SD1") + " SD1 "
cQuery += "	WHERE D1_FILIAL=D2_FILIAL "
cQuery += "	AND D1_NFORI=D2_DOC "
cQuery += "	AND D1_ITEMORI=D2_ITEM "
cQuery += "	AND D1_FORNECE=D2_CLIENTE "
cQuery += "	AND D1_LOJA=D2_LOJA "
cQuery += "	AND D1_COD=D2_COD "
cQuery += "	AND D1_QUANT=D2_QUANT-D2_QTDEDEV "
cQuery += "	AND D1_TIPO='D' "
cQuery += "	AND D1_TES='' "
cQuery += "	AND SD1.D_E_L_E_T_='' "
cQuery += "	) "
cQuery += "	ORDER BY SF2.R_E_C_N_O_ DESC "

//cQuery := ChangeQuery( cQuery )

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

TCSetField((cAliasTmp),"D2_EMISSAO"	,"D",TamSx3("D2_EMISSAO")[1]		,TamSx3("D2_EMISSAO")[2]	)

	
If (cAliasTmp)->( !Eof() )

	Do While (cAliasTmp)->( !Eof() ) 

		aAdd(	aArray,	{ 	(cAliasTmp)->F2_DOC,;
                   			(cAliasTmp)->F2_SERIE,;
                   			(cAliasTmp)->F2_CLIENTE,;
                   			(cAliasTmp)->F2_LOJA,;
							Stod((cAliasTmp)->F2_EMISSAO),;
                   			(cAliasTmp)->SF2REC } )                        

		(cAliasTmp)->( DBSkip() ) 	
	
	Enddo
	
Endif	

(cAliasTmp)->( DBCloseArea() )

If Len( aArray ) > 0 

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,00 TO 370, 600 OF oMainWnd PIXEL

	@ 005, 003 TO 100, 290 Label "Nota Original de Remessa ( Selecionar a nota )" OF oDlg PIXEL
	@ 015, 007 LISTBOX  oListBox VAR cList FIELDS HEADER "N๚mero","S้rie","Cliente","Loja","Emissao", "RECNO" SIZE 280, 080 OF oDlg PIXEL

	oListBox:SetArray( aArray )
	oListBox:bLine	:= { || aArray[oListBox:nAt] }                                 
	
	@ 105, 003 TO 140, 290 Label "Op็๕es Adicionais" OF oDlg PIXEL
	
	@ 115,010 SAY OemToAnsi('Ocorr๊ncia:')		SIZE 030,025 	OF oDlg COLORS 0 PIXEL
	@ 125,010 MSGET cOcorrenc					SIZE 080,008	OF oDlg PIXEL When .T. F3 "SZD3" VALID fVldOc(cOcorrenc, .T.)
	
	@ 115,140 SAY OemToAnsi('Placa Substitutiva:')		SIZE 060,025 	OF oDlg COLORS 0 PIXEL
	@ 125,140 MSGET cPlacas					SIZE 080,008	OF oDlg PIXEL When .T. F3 "ZV4" VALID ExistCpo("ZV4") .OR. VAZIO()
	
	DEFINE SBUTTON FROM 150, 228 TYPE 1 ACTION ( nOpc := 1 , nSelect := oListBox:nAt, oDlg:End()) ENABLE Of oDlg
	DEFINE SBUTTON FROM 150, 258 TYPE 2 ACTION oDlg:End() ENABLE Of oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpc == 1 .And. nSelect > 0 .and. fVldOc(cOcorrenc, .F.)
        
		SF2->(DbGoto(aArray[ nSelect, nPosRec ]))
		
		/*
		If !Empty(cOcorrenc)
			cPlacas	:= Posicione("SZD",4,xFilial("SZD")+cOcorrenc,"ZD_XPLACAS")
		Endif
		*/
		
		nItem	:=n
		
		SD2->(DbSetOrder(3))
		SD2->(DbSeek( SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))	
		While SD2->(!EOF()) .and. SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SD2->(D2_FILIAL+ D2_DOC+ D2_SERIE+ D2_CLIENTE+ D2_LOJA)
	                      
			If SD2->D2_QUANT-SD2->D2_QTDEDEV>0 .and. ValSD1(SD2->D2_COD,SD2->D2_DOC,SD2->D2_ITEM,SD2->D2_CLIENTE,SD2->D2_LOJA,SD2->D2_QUANT-SD2->D2_QTDEDEV)

			    If nItem > Len(aCols)
				    aadd(aCols,Array(Len(aHeader)+1))
				   	For nX := 1 to Len(aHeader)
						If IsHeadRec(aHeader[nX][2])
						    aCols[Len(aCols)][nX] := 0
						ElseIf IsHeadAlias(aHeader[nX][2])
						    aCols[Len(aCols)][nX] := "SD1"
						ElseIf Trim(aHeader[nX][2]) == "D1_ITEM"
							aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,TAMSX3(D1_ITEM)[1]))
						Else
							aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
						EndIf
						aCols[Len(aCols)][Len(aHeader)+1] := .F.
					Next nX
					nItem := Len(aCols)
			    EndIf
				
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_ITEM"		} 	)] := Strzero(nItem,TaMsx3("D1_ITEM")[1])
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_COD"	 		} 	)] := SD2->D2_COD
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_NFORI"		} 	)] := SD2->D2_DOC
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_SERIORI"	    } 	)] := SD2->D2_SERIE
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_ITEMORI"		} 	)] := SD2->D2_ITEM
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_QUANT"		} 	)] := SD2->D2_QUANT-SD2->D2_QTDEDEV
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_VUNIT"		} 	)] := SD2->D2_PRCVEN
				//@history chamado 12079 - Leonardo P. Monteiro - 09/04/2021 - Atualiza็ใo da rotina para preenchimento dos campo D1_UM, D1_SEGUM, D1_CTRDEVO e D1_XPLACAS.
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_CTRDEVO"		} 	)] := cOcorrenc
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_XPLACAS"		} 	)] := cPlacas
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_UM"			} 	)] := SD2->D2_UM
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_SEGUM"		} 	)] := SD2->D2_SEGUM
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_TOTAL"		} 	)] := (SD2->D2_QUANT-SD2->D2_QTDEDEV) * SD2->D2_PRCVEN
				aCols[nItem][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_LOCAL"		} 	)] := SD2->D2_LOCAL
		
				cItem := SomaIt(cItem)
				nItem := nItem + 1  
			
			EndIf

	        SD2->(DbSkip())
		EndDo
		
		Eval(bRefresh)
		
	Endif	              

Else

	Aviso("CCSKFXFUN","Nใo existem notas pendentes de devolu็ใo!!!",{"OK"},3)
	RestArea( aArea )
	
Endif

RestArea( aArea )

Return()

Static Function fVldOc(cOcorrenc, lGatilho)
	Local lRet := .T.
	//Local cRet := Posicione("SZD",4,xFilial("SZD")+cOcorrenc,"ZD_CONTROL")
	Local aAreaA := GetArea()

	DbSelectarea("SZD")
	SZD->(DbSetOrder(4))

	if SZD->(Dbseek(xFilial("SZD")+cOcorrenc))
		if lGatilho
			cPlacas := SZD->ZD_XPLACAS
		endif

		lRet 	:= .T.
	else
		msgAlert("C๓digo de ocorr๊ncia nใo encontrado!")
		lRet := .F.
	endif

	RestArea(aAreaA)
return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCCSKFXFUN บAutor  ณMicrosiga           บ Data ณ  02/19/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValSD1(pCOD,pDOC,pITEM,pCLIENTE,pLOJA,pQUANT)

Local lRet:=.T.  
Local cAliasTmp	:= GetNextAlias()
Local cQuery:=""

cQuery += "	   SELECT COUNT(*) AS QTDE FROM " + RetSqlname( "SD1" ) + " SD1 WHERE SD1.D1_TIPO='D' AND SD1.D1_TES='' "
cQuery += "	   AND SD1.D1_COD = '" + pCOD + "' " 
cQuery += "	   AND SD1.D1_NFORI = '" + pDOC + "' " 
cQuery += "	   AND SD1.D1_ITEMORI = '" + pITEM + "' " 
cQuery += "	   AND SD1.D1_FORNECE = '" + pCLIENTE + "' "   
cQuery += "	   AND SD1.D1_LOJA = '" + pLOJA + "' "   
cQuery += "	   AND SD1.D1_QUANT = " + Str(pQUANT)
cQuery += "	   AND SD1.D_E_L_E_T_='' "   

cQuery := ChangeQuery( cQuery )
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery), cAliasTmp, .F., .T.)

nReg:= (cAliasTmp)->QTDE       
DbSelectArea(cAliasTmp)
dbCloseArea()

If nReg>0
	lRet:=.F.
EndIf
	
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณDefTamObj  บAutor  ณPablo Gollan Carreras บ Data ณ09/02/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para alimentar variavel de definicao de tamanho e posicio- บฑฑ
ฑฑบ          ณnamento de objeto.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Array de tamanho e posicionamento                      บฑฑ
ฑฑบ          ณExp02[N] : TOP                                                    บฑฑ
ฑฑบ          ณExp03[N] : LEFT                                                   บฑฑ
ฑฑบ          ณExp04[N] : WIDTH                                                  บฑฑ
ฑฑบ          ณExp05[N] : HEIGHT                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
User Function DefTamObj(aTamObj,nTOP,nLEFT,nWIDTH,nBOTTOM,lAcVlZr)

PARAMTYPE 0	VAR aTamObj		AS Array		OPTIONAL	DEFAULT Array(4)
PARAMTYPE 1	VAR nTOP		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 2	VAR nLEFT		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 3	VAR nWIDTH		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 4	VAR nBOTTOM		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 5	VAR	lAcVlZr		AS Logical		OPTIONAL	DEFAULT .F.

If Len(aTamObj) # 4
	aTamObj := Array(4)
Endif
If lAcVlZr .OR. (!lAcVlZr .AND. !Empty(nTOP))
	aTamObj[1] := nTOP
Endif
If lAcVlZr .OR. (!lAcVlZr .AND. !Empty(nLEFT))
	aTamObj[2] := nLEFT
Endif
If lAcVlZr .OR. (!lAcVlZr .AND. !Empty(nWIDTH))
	aTamObj[3] := nWIDTH
Endif
If lAcVlZr .OR. (!lAcVlZr .AND. !Empty(nBOTTOM))
	aTamObj[4] := nBOTTOM
Endif

Return Nil  */


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออ7ออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT140TOK  บAutor  ณMicrosiga           บ Data ณ  02/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus 11 - Adp                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function PLACASUB(dDataEnt,cRoteiro,cPlaca)

Local oDlg
Local oCombo
Local cAtencao:= "Aten็ใo"       
Local cFornece:= ""      
Local lOk	  := .F.      
Local lSair	  := .F.
Local lRet	  := .F.	                        
Local aCombo  := {}

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_xcPlaca:=Space(tamSx3("C5_XPLACAS")[1]) //

While !lRet
	DEFINE MSDIALOG oDlg TITLE "Troca de Placa" FROM 0,0 TO 180,250 OF oDlg PIXEL
	
	@ 06,06 TO 85,120 LABEL "Preencha as Informa็๕es:" OF oDlg PIXEL
	
	@ 15, 15 SAY   "Roteiro/Placa: " + cRoteiro + "/" + cPlaca SIZE 230,8 PIXEL OF oDlg
	@ 25, 15 SAY   "Data de Entrega: " + dtoc(stod(dDataEnt)) SIZE 230,8 PIXEL OF oDlg
	
	@ 35, 15 SAY "Nova Placa"             SIZE  65, 8 PIXEL
	@ 45, 15 MSGET _xcPlaca SIZE 80,10 PICTURE PesqPict("SC5","C5_PLACA")  PIXEL
	
	//+-------------------
	//| Botoes da MSDialog
	//+-------------------
	@ 65,15 BUTTON "Cancela"   SIZE 36,16 PIXEL ACTION EVAL({|| lSair:=.T.,oDlg:End()}) 
	@ 65,65 BUTTON "Confirma"   SIZE 36,16 PIXEL ACTION EVAL({|| lOk:=.T.,oDlg:End()}) 
	
	ACTIVATE MSDIALOG oDlg CENTER
	
	If lOk .and. !Empty(_xcPlaca)
	        lRet:=.T.	
	ElseIf lSair
		lRet:=.T.
	Else
		Aviso("Nova Placa", "Defina a nova placa e clique confirma!", {" Ok "})
	EndIf
EndDo		
Return _xcPlaca



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTBC100    บAutor  ณHermes Ferreira     บ Data ณ  12/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o Pedido de Venda e Nota de Saida                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADR100(cFil,arraySC5,arraySC6,nOpc)	

Local cErro		:= ""
Local cErroAux  := ""
Local lRetorno	:= .F.	
Private lMsErroAuto := .F.

U_ADINF009P('CCSKFXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If Len( arraySC5 ) > 0 .And. Len( arraySC6 ) > 0
		
		Begin Transaction
		    
			MSExecAuto( { |x,y,z| Mata410( x, y, z ) }, arraySC5, arraySC6,nOpc)
			
			If lMsErroAuto

				MostraErro()  			
				
				DisarmTransaction()				
				Break				
			Else				
				ConfirmSx8()
				lRetorno	:= .T.				
			EndIf
		
		End Transaction
	
	EndIf
			
Return lRetorno
