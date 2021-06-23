#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "GPEWORD.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ADINF005R ³ Autor ³ Adriana Oliveira     ³ Data ³02/01/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao de OS de servico                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_ADINF005R()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADINF005R()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Impressao de OS de servico')

//+-------------------------------------------------------------------------+
//|Monta grupo de perguntas                                                 |
//+-------------------------------------------------------------------------+
_cPerg := "ADINF005R "

ValidPerg()

if Pergunte(_cPerg,.T.)
	WordImp()
endif

Return()

Static Function WordImp()
Local cPathDot		:= MV_PAR05     
Local cPath 		:= GETTEMPPATH()
Local cQry			:= ""
Local wcOS			:= ""
Local wcTECNICO		:= ""
Local wcCHAMADO		:= ""
Local wcUNIDADE   	:= ""
Local wcDATA		:= ""
Local wcDEPART		:= ""
Local wcSOLICIT  	:= ""
Local wcRAMAL		:= ""
Local wcESCOPO		:= ""
Local wcDESCRI		:= ""
Private	hWord

// Inicializa o WinWord
hWord	:= OLE_CreateLink()
// seto a propriedade de visibilidade do word
OLE_SetProperty( hWord, oleWdVisible,   .T. )
// seto a propriedade de impressão (segundo plano .T. ou .F.)
OLE_SetProperty( hWord, oleWdPrintBack, .F. )

DbSelectArea("PAA")
DbSetOrder(1)

_cOs := Alltrim(MV_PAR04)

// Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario, busca o nome do arquivo de modelo,  copia para o diretorio temporario  
// do windows e ajusta o caminho completo do arquivo a ser impresso.

If substr(cPathDot,2,1) <> ":"
	cAux 	:= cPathDot
	nAT		:= 1
	for nx := 1 to len(cPathDot)
		cAux := substr(cAux,If(nx==1,nAt,nAt+1),len(cAux))
		nAt := at("\",cAux)
		If nAt == 0
			Exit
		Endif
	next nx
	CpyS2T(cPathDot,cPath, .T.)
	cPathDot	:= cPath+cAux
Endif

for _i := 1 to len(_cOs)/7
	if DbSeek(xFilial("PAA")+Substr(MV_PAR04,(7*(_i-1)+1),7) )
		
		// Cria uma Nova Página
		OLE_NewFile(hWord, cPathDot )
	
		wcOS		:= PAA_CODIGO 
		wcTECNICO	:= PAA_NOMTEC 
		wcCHAMADO	:= PAA_CHAMAD 
		wcUNIDADE   := PAA_DUNID 
		wcDATA		:= dtoc(PAA_SOLICI) 
		wcDEPART	:= PAA_CCDESC 
		wcSOLICIT  	:= PAA_USUARI 
		wcRAMAL		:= PAA_RAMAL 
		wcESCOPO	:= PAA_ESCOPO
		wcDESCRI	:= PAA_DESCRI 
		
		//Montagem das variaveis do cabecalho
		OLE_SetDocumentVar(hWord, 'OS'		, wcOS)
		OLE_SetDocumentVar(hWord, 'TECNICO'	, wcTECNICO)
		OLE_SetDocumentVar(hWord, 'CHAMADO'	, wcCHAMADO)
		OLE_SetDocumentVar(hWord, 'UNIDADE'	, wcUNIDADE)
		OLE_SetDocumentVar(hWord, 'DATA'	, wcDATA   )
		OLE_SetDocumentVar(hWord, 'DEPARTAMENTO'	, wcDEPART)
		OLE_SetDocumentVar(hWord, 'SOLICITANTE'	, wcSOLICIT)
		OLE_SetDocumentVar(hWord, 'RAMAL'	, wcRAMAL)
		OLE_SetDocumentVar(hWord, 'ESCOPO'	, wcESCOPO)
		OLE_SetDocumentVar(hWord, 'DESCRICAO'	, wcDESCRI)
		
		OLE_UpdateFields(hWord)	// Atualizando as variaveis do documento do Word
	Endif
	
next

DbClosearea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Encerrando o Link com o Documento                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
alert("Clique aqui para Fechar o Word")
OLE_CloseFile( hWord )//fecha o arquivo do word
OLE_CloseLink( hWord )
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³ADRIANA OLIVEIRA    º Data ³  02/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta as perguntas no SX1                                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg

Local _aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)

// Grupo/Ordem/Pergunta/Perg Spanish/Question English/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(_aRegs,{_cPerg,"01","Tecnico De            ?","","","mv_ch1","C",06 ,0,0,"G",""			,"mv_par01",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","AA1"	,""})
aAdd(_aRegs,{_cPerg,"02","Tecnico Ate           ?","","","mv_ch2","C",06 ,0,0,"G",""			,"mv_par02",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","","AA1"	,""})
aAdd(_aRegs,{_cPerg,"03","Somente NAO Encerradas?","","","mv_ch3","C",1  ,0,1,"C",""			,"mv_par03","Sim"		,"","","","","Nao"		,"","","","","","","","","","","","","","","","","","",""		,""})
aAdd(_aRegs,{_cPerg,"04","Seleciona OS's        ?","","","mv_ch4","C",69 ,0,0,"G","U_ADSEL()"	,"mv_par04",""			,"","","","",""			,"","","","","","","","","","","","","","","","","","",""		,""})
aAdd(_aRegs,{_cPerg,"05","Arquivo Modelo Word   ?","","","mv_ch5","C",30 ,0,0,"G",""			,"mv_par05",""		 	,"","","","",""			,"","","","","","","","","","","","","","","","","","",""		,""})

For i:=1 to Len(_aRegs)
	If !dbSeek(_cPerg+_aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(_aRegs[i])
				FieldPut(j,_aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ADSel  	³ Autor ³ Adriana Oliveira		³ Data ³ 02/01/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Selecionar OS´S				           	  				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ADSel()   					    	  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Chamado grupo de perguntas ADINF005R         		 		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User Function ADSel()

Local 	_cTitulo	:=	"Selecione OS's para Imprimir"
Local 	_MvPar		:=	&(Alltrim(ReadVar()))    	// Carrega Nome da Variavel do Get em Questao
Local 	_MvParDef	:=	""
Local  	_cAlias 	:= 	Alias() 			// Salva Alias Anterior
Private _aGrupos 	:=	{}

U_ADINF009P('ADINF005R' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Impressao de OS de servico')

mvRet			:=	Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno

_cQuery := "SELECT * FROM "+RetSqlName("PAA")+ " WHERE PAA_TECNIC >= '"+MV_PAR01+"' AND PAA_TECNIC <= '"+MV_PAR02+"' AND "+IIF(MV_PAR03 = 1, "PAA_FIM = '' AND ","")+" D_E_L_E_T_ = '' ORDER BY PAA_CODIGO"

TCQUERY _cQuery new alias "XPAA"
XPAA->(dbgotop())


dbSelectArea("XPAA")
dbgotop()

While !Eof()
	Aadd(_aGrupos,XPAA->PAA_CODIGO + " - Chamado: "+XPAA->PAA_CHAMAD+" "+Alltrim(XPAA->PAA_DSRVAC)+" de "+XPAA->PAA_USUARI)
	_MvParDef		+=	XPAA->PAA_CODIGO+"/"
	dbSkip()
End
/*
f_Opcoes(			uVarRet			,;	//Variavel de Retorno
cTitulo			,;	//Titulo da Coluna com as opcoes
aOpcoes			,;	//Opcoes de Escolha (Array de Opcoes)
cOpcoes			,;	//String de Opcoes para Retorno
nLin1			,;	//Nao Utilizado
nCol1			,;	//Nao Utilizado
l1Elem			,;	//Se a Selecao sera de apenas 1 Elemento por vez
nTam			,;	//Tamanho da Chave
nElemRet		,;	//No maximo de elementos na variavel de retorno
lMultSelect		,;	//Inclui Botoes para Selecao de Multiplos Itens
lComboBox		,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
cCampo			,;	//Qual o Campo para a Montagem do aOpcoes
lNotOrdena		,;	//Nao Permite a Ordenacao
lNotPesq		,;	//Nao Permite a Pesquisa
lForceRetArr    ,;	//Forca o Retorno Como Array
cF3				 ;	//Consulta F3
)*/
If f_Opcoes(@_MvPar,_cTitulo,_aGrupos,_MvParDef,12,49,.F.,7,11)  	// Chama funcao f_Opcoes
	&MvRet := StrTran(_Mvpar,"*","")                       		// Devolve Resultado
EndIf

dbclosearea()

dbSelectArea(_cAlias) 								 // Retorna Alias

Return(.T.)
