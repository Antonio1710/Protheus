#Include "Protheus.Ch"
#INCLUDE "Matr925.ch"
#define SAY PSAY

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё MATR925  Ё Autor Ё Gilson do Nascimento  Ё Data Ё 15.09.93 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Mapa para Declaracao para o Indice de Participacao dos Mu- Ё╠╠
╠╠Ё          Ё nicipios (DIPAM-B)                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Generico                                                   Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     Ё╠╠
╠╠цддддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё PROGRAMADOR  Ё DATA   Ё BOPS Ё  MOTIVO DA ALTERACAO                   Ё╠╠
╠╠цддддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Marcos SimiduЁ03/11/98ЁXXXXXXЁAcertos no ano com 4 bytes.             Ё╠╠
╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
User Function ADMATR925()  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local	nomeprog	:= "MATR925"
Local   aFilsCalc 	:= {}
Local	aAreaSM0	:= SM0->(GetArea())

Private	Tamanho		:= "G"
Private	titulo		:= STR0001	//"Mapa para preenchimento da DIPAM-B"
Private cDesc1		:= STR0002	//"Este programa emite um mapa, para que com ele o usu═rio preencha"
Private cDesc2		:= STR0003	//"a DIPAM-B (Declara┤└o p/ o Indice de Participa┤└o dos Munic║pios),"
Private cDesc3		:= STR0004	//"fornecendo os principais dados processsados pelo Sistema."

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis tipo Private padrao de todos os relatorios         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private wnRel
Private aReturn		:= {STR0005, 1,STR0006, 2, 2, 1, "",1} //"Zebrado"###"Administra┤└o"
Private cPerg		:= "MTR925"
Private cString		:= "SF3"
Private cPict		:= "@E 999,999,999,999.99"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Contadores de linha e pagina                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private lEnd		:= .F.

Pergunte(cPerg,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLastKey	:= 0
wnRel		:= SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

If nLastKey==27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)
If nLastKey==27
	dbClearFilter()
	Return
Endif

RptStatus( { |lEnd| R925Imp( @lEnd, wnRel, cString, Tamanho ) }, titulo )

If aReturn[5]==1
	Set Printer To
	ourspool(wnRel)
Endif
MS_FLUSH()

SM0->(RestArea(aAreaSM0))
cFilAnt	:= SM0->M0_CODFIL
Return    

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё R925Imp  Ё Autor Ё Juan Jose Pereira     Ё Data Ё 08.12.95 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Funcao chamadora do Matr925 (Windows)                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё R925Imp()                                                  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
*/
Static Function R925Imp( lEnd, WnRel, cString, Tamanho )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aArea			:= GetArea()
Local cIndSF3
Local cChave
Local cFiltro
Local cSeek
Local cMunic		:= ""
Local cCfoNCons 	:= ""
Local cAliasSF3		:= "SF3"
Local nPos
Local nLin			:= 1
Local nTotCamposE	:= 0
Local nCodigo		:= 0
Local aCamposD		:= Array(33)
Local aCamposE
Local aCamposA		:= Array(5)
Local lR925db 		:= ExistBlock("MTR925DB")
Local lExecBlock
Local i
Local aEstado		:= {}
Local aTotEst		:= Array(10)
Local cUF			:= ""
Local lTotal		:= .F.
Local cMvUF    		:= GetMV("MV_ESTADO")

#IFDEF TOP
	Local aStruSF3	:= {}
	Local cQuery	:= ""
	Local nX		:= 0
#ELSE
	Local cIndex    := ""
	Local cCondicao := ""
#ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Parametro utilizado para informar os Cfop's do Item [09] Compras do Estado, exceto o Codigo(11)Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cCfopUf	:= GetNewPar("MV_DIPAMB1","112/1102")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Parametro utilizado para informar os Cfop's do Item [11] Compras a Produtor Rural do Estado    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cCfopPR	:= GetNewPar("MV_DIPAMB2","111/162/163/1101/1352/1353")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas para Tratamento da impressao por FiliaisЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nForFilial := 0
Local cFilBack   := cFilAnt
Local cAlias	 := Alias()
Local aAreaSM0   := SM0->(GetArea())
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Execblock para analise alternativa do codigo da DIPAM-B      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cCFO
Private nValNota	:= 0
Private nCPO		:= 0 // <= Codigo da DIPAM-B a ser tratado
Private cArqDIPAM	:= ""
Private cArqTemp	:= ""

lExecBlock	:= (existblock("DIPAM"))
aCamposD	:= Afill(aCamposD,0)
aCamposE	:= {}
aCamposA	:= Afill(aCamposA,0)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas para parametros                         Ё
//Ё mv_par01     // Data Inicial                                 Ё
//Ё mv_par02     // Data Final                                   Ё
//Ё mv_par03     // Livro selecionado                            Ё
//Ё mv_par04     // Lista p/ conferencia                         Ё
//Ё mv_par05     // Filial De?                                   Ё
//Ё mv_par06     // Filial Ate?                                  Ё
//Ё mv_par07     // Gera com base Nova GIA?                      Ё
//Ё mv_par08     // VersЦo layout Nova GIA?                      Ё
//Ё mv_par09     // NF Transf. Filiais                           Ё
//Ё mv_par10     // Imprime DIPAM-A ?                            Ё
//Ё mv_par11     // Seleciona Filiais ?                          Ё
//Ё mv_par12     // Aglutina por CNPJ + I.E. ?                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
Private dDtIni		:= mv_par01
Private	dDtFim		:= mv_par02
Private	cNrLivro	:= mv_par03
Private	lImpLista	:= (mv_par04==1)
Private cFilterUser	:= aReturn[7]
Private lNovaGia	:= (mv_par07==1)
Private lDipamA		:= (mv_par10==1)
Private aL			:= R925LayOut(lNovaGia,lDipamA)
Private cVLayOut	:= mv_par08
Private nGeraTransp	:= mv_par09
Private nTipoReg	:= 0
Private cArqCabec   := ""

//VariАveis cArqCFO, cArqInt, cArqZFM, cArqOcor, cArqIE, cArqIeSt, cArqIeSd, cCredAcum e cArqExpt 
//criadas para corrigir nЦo conformidade apontada na issue DSERFIS2-2887
Private cArqCFO		:= ""
Private cArqInt		:= ""
Private cArqZFM		:= ""
Private cArqOcor	:= ""
Private cArqIE		:= ""
Private cArqIeSt	:= ""
Private cArqIeSd	:= ""
Private cCredAcum	:= ""
Private cArqExpt	:= ""

#IFDEF TOP
	Private lSelFil		:= (MV_PAR11 == 1) 
	Private lAglFil		:= (MV_PAR12 == 1)  
	Private nPosEmp		:= 0
	Private	cFilDe		:= Space(FWGETTAMFILIAL)
	Private	cFilAte		:= Replicate('z',FWGETTAMFILIAL)
	aFilsCalc			:= {}
#ELSE   
	Private lSelFil		:= .T.
	Private lAglFil		:= .F.
	Private	cFilDe		:= Iif(Empty(mv_par05+mv_par06), cFilAnt, mv_par05)
	Private	cFilAte		:= Iif(Empty(mv_par06), cFilAnt, mv_par06)
#ENDIF

If lNovaGia .And. !lDipamA
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava arquivo texto                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	// Travada a opГЦo do lAglFil somente funcionar se o lSelFil estiver ativo
	cArqDIPAM := a972MontTrab({},.T.,dDtIni,dDtFim,cNrLivro,1,cFilDe,cFilAte,cVLayOut,lSelFil,(lSelFil .and. lAglFil) )
	DbSelectArea(cArqDIPAM)
	(cArqDIPAM)->(DbGoTop())
     
	cFilAnt	:=	cFilDe
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria arquivo temporario para guardar dados para conferencia  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lImpLista
		cArqTemp	:= R925CriaTemp()
	Endif
	
	aCamposD	:= Afill(aCamposD,0)
	aCamposE	:= {}     
	
	While !(cArqDIPAM)->(Eof())
		cFil		:=	(cArqDIPAM)->FILIAL
		lTotal		:= .F.
		nCpo		:= Val((cArqDIPAM)->CODDIP)
	 	nValNota	:= (cArqDIPAM)->VALOR
		cCFO		:= Alltrim((cArqDIPAM)->CFOP)
		cUF			:= (cArqDIPAM)->ESTADO	
		cMunic		:= (cArqDIPAM)->MUNICIP 
		cTipo		:= (cArqDIPAM)->ENT_SAI
		
	 	#IFDEF TOP
			If lSelFil .and. !lAglFil
		#ENDIF
		
		If Empty(cFilDe) //Arrumo as filiais para que nЦo apresente tudo em uma unica pagina caso a opcao seja de ""(branco) a "ZZ"
			cFilDe := cFil
		Endif
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprimo o total caso a filial seja diferente                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		If cFil <> cFilDe
			lTotal	:= .T.     	
			R925ImpTot(aCamposD,lEnd,aL,@nLin,cPict,aCamposE,cArqTemp,aEstado)
			cFilAnt := (cArqDIPAM)->FILIAL   
			
			//здддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁQuando mudar a filial, reinicia os totalizadoresЁ
			//юдддддддддддддддддддддддддддддддддддддддддддддддды
			aCamposD := Afill(aCamposD,0)
			aCamposE := {}  
			aEstado  := {}  
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Cria arquivo temporario para guardar dados para conferencia  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lImpLista
				cArqTemp	:= R925CriaTemp()
			Endif
		Endif
		
		#IFDEF TOP
			EndIf
		#ENDIF
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁTratamento alternativo ao codigo do DIPAM                             Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lExecBlock
			ExecBlock("DIPAM",.F.,.F.)
		Endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Acumula valor da nota no campo da DIPAM                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		Do Case
			//Entrada
			Case nCpo==11; nColuna:=09
			Case nCpo==13; nColuna:=10
			//Saida
			Case nCpo==22; nColuna:=01
			Case nCpo==23; nColuna:=02
			Case nCpo==24; nColuna:=03
			Case nCpo==25; nColuna:=04												 
		EndCase
		If nCpo==24 
		    If Substr(cCFO,1,1) < "5"
		        aCamposD[nColuna] -= nValNota
		    Else
		        aCamposD[nColuna] += nValNota
		    EndIf  
		Else
		    aCamposD[nColuna] += nValNota	    
		EndIf   
			
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Acumula por municipio                                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Alltrim(Upper(cMunic))==Alltrim(Upper(SM0->M0_CIDENT))
			cMunic	:=	STR0008 //"DO PROPRIO MUNICIPIO"
		Endif
		nPos	:=	Ascan(aCamposE,{|x|x[1]==cMunic .And. x[18]==cUF .And. x[19]==cTipo})
		If nPos==0
			AADD(aCamposE,{cMunic,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,(cArqDIPAM)->ESTADO,(cArqDIPAM)->ENT_SAI})
			nPos	:=	Len(aCamposE)
		Endif
		Do Case
			Case nCpo==22; nColuna:=2
			Case nCpo==23; nColuna:=3 
			Case nCpo==24; nColuna:=4
			Case nCpo==25; nColuna:=5 
			Case nCpo==11; nColuna:=9
			Case nCpo==13; nColuna:=10 
		EndCase
		If nCpo<>24 .Or. (nCpo==24 .And. Substr(cCFO,1,1) >= "5") 
		    aCamposE[nPos,nColuna]	+=	nValNota
	    EndIf
			
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Acumula por Estado                                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nPos :=	Ascan(aEstado,{|x|x[1]==cUF .And. x[18]==cTipo})
		If nPos==0
			AADD(aEstado,{(cArqDIPAM)->ESTADO,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,(cArqDIPAM)->ENT_SAI})
			nPos	:=	Len(aEstado)
		Endif
		If nCpo==24 
		    If Substr(cCFO,1,1) < "5"
		        aEstado[nPos,nColuna] -= nValNota
		    Else
		        aEstado[nPos,nColuna] += nValNota
		    EndIf
		Else		
		    aEstado[nPos,nColuna]	+=	nValNota
	    EndIf
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava em arquivo temporario para conferencia                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		If nCpo<>24 .Or. (nCpo==24 .And. Substr(cCFO,1,1) >= "5") 
       		R925GravaConf(cArqTemp,(cArqDIPAM)->ENT_SAI,(cArqDIPAM)->NOTA,(cArqDIPAM)->SERIE,(cArqDIPAM)->CLIFOR,(cArqDIPAM)->LOJA,cMunic,(cArqDIPAM)->CODDIP,nValNota,(cArqDIPAM)->TIPO,cUF)
        EndIf
		(cArqDIPAM)->(DbSkip())
	Enddo

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprimir o total caso ainda nao tenha sido impresso               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	If !lTotal
		R925ImpTot(aCamposD,lEnd,aL,@nLin,cPict,aCamposE,cArqTemp,aEstado)
	Endif
	//здддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apaga arquivos temporarios               Ё
	//юдддддддддддддддддддддддддддддддддддддддддды
	If File(cArqTemp+GetDBExtension())
		dbSelectArea(cArqTemp)
		dbCloseArea()
		Ferase(cArqTemp+GetDBExtension())
		Ferase(cArqTemp+OrdBagExt())
	Endif     	

	If File(cArqDIPAM+GetDBExtension())
		dbSelectArea(cArqDIPAM)
		dbCloseArea()
		Ferase(cArqDIPAM+GetDBExtension())
		Ferase(cArqDIPAM+OrdBagExt())
	Endif     	
	RestArea(aArea)

	
ElseIf lDipamA //impressЦo do relatСrio auxiliar para preenchimento DIPAM-A (produtor rural pessoa fМsica)
	aCamposA	:= Afill(aCamposA,0) 
	#IFDEF TOP
		cFilDe	:= Space(FWGETTAMFILIAL)
		cFilAte	:= Replicate('z',FWGETTAMFILIAL)   
		aFilsCalc := MatFilCalc( lSelFil, , , (lSelfil .and. lAglFil), , 2 )			// Aglutina por CNPJ + I.E.	
	#ENDIF
	DbSelectArea("SM0")
	SM0->(DbSeek(cEmpAnt+cFilDe, .T.))
    
	Do While !SM0->(Eof()) .And. (SM0->M0_CODIGO==cEmpAnt) .And. (SM0->M0_CODFIL<=cFilAte)
		cFilAnt		:=	SM0->M0_CODFIL
		#IFDEF TOP   
			If ( nPosEmp := aScan(aFilsCalc, {|x| Alltrim(x[2]) == Alltrim(SM0->M0_CODFIL)} ) ) == 0 .or. !aFilsCalc[nPosEmp][1]
				SM0->(dbSkip())
				Loop
			EndIf
		#ENDIF
    
		//зддддддддддддддддддддддддддд©
		//Ё Filtra SF3                Ё
		//юддддддддддддддддддддддддддды
		dbSelectArea("SF3")
		dbSetOrder(1)
		ProcRegua(LastRec())

		#IFDEF TOP
		    If TcSrvType()<>"AS/400"
			    lQuery 		:= .T.
				cAliasSF3	:= "SF3_MTR925"
				aStruSF3	:= SF3->(dbStruct())
				cQuery		:= "SELECT * "
				cQuery 		+= "FROM " + RetSqlName("SF3") + " SF3 "
				cQuery 		+= "WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
				cQuery 		+= "SF3.F3_EMISSAO >= '" + Dtos(dDtIni) + "' AND "
				cQuery 		+= "SF3.F3_EMISSAO <= '" + Dtos(dDtFim) + "' AND "
       		    cQuery      += "SF3.F3_CFO >= '5' AND SF3.F3_TIPO <> 'S' AND "
				cQuery 		+= "SF3.F3_DTCANC = '" + Dtos(Ctod("")) + "' AND "
				If cNrLivro <> "*"
					cQuery	+= "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "
				Endif
				cQuery 		+= "SF3.D_E_L_E_T_ = ' ' "
				cQuery 		+= "ORDER BY " + SqlOrder(SF3->(IndexKey()))
				cQuery 		:= ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)
				For nX := 1 To len(aStruSF3)
					If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
						TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
					EndIf
				Next nX
		
				dbSelectArea(cAliasSF3)	
			Else
		#ENDIF
	    		cIndex    		:= CriaTrab(NIL,.F.)
		    	cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			   	cCondicao 		+= 'DTOS(F3_EMISSAO) >= "' + DTOS(dDtIni) + '" .And. DTOS(F3_EMISSAO) <= "' + DTOS(dDtFim) + '" .And. '
				cCondicao 		+= 'F3_CFO >= "5" .And. '
				cCondicao 		+= 'F3_TIPO <> "S" .And. '
				cCondicao		+= 'Empty(F3_DTCANC) '
				If cNrLivro <> "*"
					cCondicao 	+= '.And. F3_NRLIVRO == "' + cNrLivro + '" '
				EndIf	                                                        
		    	IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    	dbSelectArea(cAliasSF3)
		    	ProcRegua(LastRec())
		    	dbGoTop()
		#IFDEF TOP
			Endif
		#ENDIF

		cIndSF3	:=	CriaTrab(NIL,.F.)
		SetRegua(LastRec())

		While !((cAliasSF3)->(Eof()))
		    IncProc(STR0007) // Filtrando lancamentos fiscais...
			If Interrupcao(@lEnd)
				Exit
			Endif
		    
		    DbSelectArea(cAliasSF3)
		         
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Considera filtro do usuario                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty(cFilterUser).And.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
		
			nCpo		:= 0
		 	nValNota	:= (cAliasSF3)->F3_VALCONT
			cCFO		:= Alltrim((cAliasSF3)->F3_CFO)
			cSeek		:= (cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
			cUF			:= (cAliasSF3)->F3_ESTADO	

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define campo da DIPAM que seja lancado o valor da nota       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Do Case
				Case cCfo$"5101/5102/5103/5104/5105/5109/5110/5111/5112/5113/5114/5116/5117/5118/5119/5120/5122/5123/5124/5125/"
       			     SA1->(dbSeek(xFilial()+cSeek))
   			         If SA1->A1_TIPO=="L" .And. SA1->A1_PESSOA=="F"
						 nCpo := 20
			         ElseIf SA1->A1_TIPO<>"L" .And. (SA1->A1_CONTRIB=="2" .Or. Alltrim(SA1->A1_INSCR)=="" .or. SA1->A1_INSCR=="ISENTO")  
			             nCpo := 30 
			         EndIf
				Case cCfo$"6101/6102/6103/6104/6105/6109/6110/6111/6112/6113/6114/6116/6117/6118/6119/6120/6122/6123/6124/6125/"
			         nCpo := 40
				Case cCfo$"7101/7102/7105/7106/7127/"
					 nCpo := 50
			EndCase
			Do Case
				Case nCpo==20; nColuna:=1
				Case nCpo==30; nColuna:=2
				Case nCpo==40; nColuna:=3
				Case nCpo==50; nColuna:=4
			EndCase        
			If nCpo<>0
			    aCamposA[nColuna]	+=	nValNota
			EndIf
			(cAliasSF3)->(dbSkip())
		Enddo
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Totaliza valores da DIPAM                                    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aCamposA[5]:=aCamposA[1]+aCamposA[2]+aCamposA[3]+aCamposA[4]
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao                                                    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(aCamposA) 
			While !lEnd
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Cabecalho do formulario                                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				R925Cab(aL,@nLin)
				FmtLin(,{aL[8],aL[9],aL[10],aL[11],aL[12],aL[13],aL[14]},,,@nLin)

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Quadro [ E ]                                                 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				FmtLin({aCamposA[1]},aL[15],cPict,,@nLin)
				FmtLin({aCamposA[2]},aL[16],cPict,,@nLin)
				FmtLin({aCamposA[3]},aL[17],cPict,,@nLin)
				FmtLin({aCamposA[4]},aL[18],cPict,,@nLin)
				FmtLin(,aL[19],,,@nLin)             
				FmtLin({aCamposA[5]},aL[20],cPict,,@nLin)
				Exit
			Enddo
		Endif	
		//здддддддддддддддддддддддддддддддд©
		//ЁExcluindo as areas de trabalho  Ё
		//юдддддддддддддддддддддддддддддддды
		If lQuery
			dbSelectArea(cAliasSF3)
			dbCloseArea()
		Else
			dbSelectArea("SF3")
			RetIndex("SF3")
			dbClearFilter()
			Ferase(cIndSF3+OrdBagExt())
		Endif	
		
		RestArea(aArea)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁQuando mudar a filial, reinicia os totalizadoresЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддды
		aCamposD := Afill(aCamposD,0)
	    aCamposE := {}  
	    aEstado  := {}
		
		SM0->(DbSkip ())
	EndDo
	// Restaura filial original apos processamento
	SM0->(RestArea(aAreaSM0) )
	cFilAnt		:=	SM0->M0_CODFIL		

Else
	#IFDEF TOP
		cFilDe	:= Space(FWGETTAMFILIAL)
		cFilAte	:= Replicate('z',FWGETTAMFILIAL)   
		aFilsCalc := MatFilCalc( lSelFil, , , (lSelfil .and. lAglFil), , 2 )			// Aglutina por CNPJ + I.E.	
	#ENDIF
	DbSelectArea("SM0")
	SM0->(DbSeek(cEmpAnt+cFilDe, .T.))

	Do While !SM0->(Eof()) .And. (SM0->M0_CODIGO==cEmpAnt) .And. (SM0->M0_CODFIL<=cFilAte)
		cFilAnt		:=	SM0->M0_CODFIL
		#IFDEF TOP   
			If ( nPosEmp := aScan(aFilsCalc, {|x| Alltrim(x[2]) == Alltrim(SM0->M0_CODFIL)}  ) ) == 0 .or. !aFilsCalc[nPosEmp][1]
				SM0->(dbSkip())
				Loop
			EndIf
		#ENDIF

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cria arquivo temporario para guardar dados para conferencia  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lImpLista
			cArqTemp	:= R925CriaTemp()
		Endif

		// Parametro que contem os CFOp's que nao devem ser considerados na geracao do relatorio.
		DbSelectArea ("SX6")
		SX6->(DbSetOrder (1))
		SX6->(DbSeek (xFilial ("SX6")+"MV_CFODP"))
		//
		Do While !SX6->(Eof ()) .And. "MV_CFODP"$SX6->X6_VAR
			cCfoNCons	+=	AllTrim (SX6->X6_CONTEUD)
		//
			SX6->(DbSkip ())
		EndDo

		//зддддддддддддддддддддддддддд©
		//Ё Filtra SF3                Ё
		//юддддддддддддддддддддддддддды
		dbSelectArea("SF3")
		dbSetOrder(1)
		ProcRegua(LastRec())

		#IFDEF TOP
		    If TcSrvType()<>"AS/400"
			    lQuery 		:= .T.
				cAliasSF3	:= "SF3_MTR925"
				aStruSF3	:= SF3->(dbStruct())
				cQuery		:= "SELECT * "
				cQuery 		+= "FROM " + RetSqlName("SF3") + " SF3 "
				cQuery 		+= "WHERE SF3.F3_FILIAL = '" + xFilial("SF3") + "' AND "
				cQuery 		+= "SF3.F3_ENTRADA >= '" + Dtos(dDtIni) + "' AND "
				cQuery 		+= "SF3.F3_ENTRADA <= '" + Dtos(dDtFim) + "' AND "
				cQuery 		+= "SF3.F3_TIPO <> 'S' AND "
				cQuery 		+= "SF3.F3_DTCANC = '" + Dtos(Ctod("")) + "' AND "
				If cNrLivro <> "*"
					cQuery	+= "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "
				Endif
				cQuery 		+= "SF3.D_E_L_E_T_ = ' ' "
				cQuery 		+= "ORDER BY " + SqlOrder(SF3->(IndexKey()))
				cQuery 		:= ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)
				For nX := 1 To len(aStruSF3)
					If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
						TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
					EndIf
				Next nX
		
				dbSelectArea(cAliasSF3)	
			Else
		#ENDIF
	    		cIndex    		:= CriaTrab(NIL,.F.)
		    	cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			   	cCondicao 		+= 'DTOS(F3_ENTRADA) >= "' + DTOS(dDtIni) + '" .And. DTOS(F3_ENTRADA) <= "' + DTOS(dDtFim) + '" .And. '
				cCondicao 		+= 'F3_TIPO <> "S" .And. '
				cCondicao		+= 'Empty(F3_DTCANC) '
				If cNrLivro <> "*"
					cCondicao 	+= '.And. F3_NRLIVRO == "' + cNrLivro + '" '
				EndIf	                                                        
		    	IndRegua(cAliasSF3,cIndex,SF3->(IndexKey()),,cCondicao)
		    	dbSelectArea(cAliasSF3)
		    	ProcRegua(LastRec())
		    	dbGoTop()
		#IFDEF TOP
			Endif
		#ENDIF

		cIndSF3	:=	CriaTrab(NIL,.F.)
		SetRegua(LastRec())

		While !((cAliasSF3)->(Eof()))
		    IncProc(STR0007) // Filtrando lancamentos fiscais...
			If Interrupcao(@lEnd)
				Exit
			Endif
					      
		  	If IntTMS() //Tem integraГЦo com TMS?
				If DT6->(MsSeek(xFilial("DT6")+(cAliasSF3)->(F3_FILIAL+F3_NFISCAL+F3_SERIE)))
					If DUY->(MsSeek(XFilial("DUY")+DT6->DT6_CDRORI))
			    		cUF := DUY->DUY_EST
			    		If DUY->DUY_EST <> cMvUF  			    			
			    			(cAliasSF3)->(dbSkip())
							Loop
						EndIf 
					EndIf
				EndIf			
			EndIf 
					    
		    DbSelectArea(cAliasSF3)
		         
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Considera filtro do usuario                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty(cFilterUser).And.!(&cFilterUser)
				dbSkip()
				Loop
			Endif
		
			If Alltrim((cAliasSF3)->F3_CFO)$cCfoNCons
				dbSkip()
				Loop
			EndIf
		
			nCpo		:= 0
		 	nValNota	:= (cAliasSF3)->F3_VALCONT
			cCFO		:= Alltrim((cAliasSF3)->F3_CFO)
			cSeek		:= (cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
			
			//IrА considerar F3_ESTADO somente quando nЦo houver integraГЦo com TMS.
			If !IntTMS()			
				cUF	:= (cAliasSF3)->F3_ESTADO
			EndIf
			
			If (Substr(cCFO,1,1)>="5" .And. (cAliasSF3)->F3_TIPO$"DB").Or.(Substr(cCFO,1,1)<"5" .And. !(cAliasSF3)->F3_TIPO$"DB")
				SA2->(dbSeek(xFilial()+cSeek))
				cMunic	:=	Substr(SA2->A2_MUN,1,26)
			Else
				If IntTMS()
					cMunic := IIf(lR925db,ExecBlock ("MTR925DB", .F., .F., {(cAliasSF3)->F3_FILIAL, (cAliasSF3)->F3_NFISCAL, (cAliasSF3)->F3_SERIE}),"")
					If Empty(cMunic)
						//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Integracao com TMS                                 Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
						DTC->(DbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
						If DTC->(MsSeek (xFilial("DTC")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
							If !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3" //--Origem e Local de Coleta
								//--Posiciona na Ordem de Coleta
								DT5->(DbSetOrder (1))
								If DT5->(MsSeek (xFilial ("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
									//--Verifica se o Solicitante tem Sequencias de Endereco
									If Empty (DT5->DT5_SEQEND)
										DUE->(dbSetOrder(1))
										DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))										
										cMunic	:=	SubStr (DUE->DUE_MUN, 1, 26)	//(Cod. Municipio para imprimir no DIPAM)
										cUF		:=  DUE->DUE_EST
									Else                                                               
										DUL->(dbSetOrder(3))
										DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
										cMunic	:=	SubStr (DUL->DUL_MUN, 1, 26)	//(Cod. Municipio para imprimir no DIPAM)
										cUF		:=  DUL->DUL_EST
									EndIf
								EndIf
							EndIf
						EndIf

						If Empty(cMunic)
							DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
							If (DT6->(MsSeek (xFilial ("DT6")+(cAliasSF3)->F3_FILIAL+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE)))
								If DT6->DT6_DOCTMS == StrZero( 8, Len( DT6->DT6_DOCTMS ) )  //-- Conhecimento Complementar
									If DT6->(MsSeek(xFilial('DT6') + DT6->(DT6_FILDCO+DT6_DOCDCO+DT6_SERDCO))) //-- Busca o Conhecimento Original
										DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC+DTC_NUMSOL
										If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILORI + DT6_LOTNFC)))
											If !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3" //--Origem e Local de Coleta
												//-- Posiciona na Ordem de Coleta
												DT5->(DbSetOrder (1)) 
												If DT5->(MsSeek(xFilial("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
													//--Verifica se o Solicitante tem Sequencias de Endereco
													If Empty (DT5->DT5_SEQEND)
														DUE->(dbSetOrder(1)) 
														DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))
														cMunic	:=	SubStr (DUE->DUE_MUN, 1, 26)	//(Cod. Municipio para imprimir no DIPAM)
														cUF		:=  DUE->DUE_EST
													Else   
														DUL->(dbSetOrder(3))
														DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
														cMunic	:=	SubStr (DUL->DUL_MUN, 1, 26)	//(Cod. Municipio para imprimir no DIPAM)
														cUF		:=  DUL->DUL_EST
													EndIf
												EndIf
											ElseIf DTC->DTC_SELORI == "2" //--Origem Cliente Remetente
												SA1->(DbSetOrder(1))
												If SA1->(MsSeek (xFilial ("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
													cMunic := Substr(SA1->A1_MUN,1,26)
													cUF    := SA1->A1_EST
												Else
													cMunic := ''
												EndIf
											ElseIf DTC->DTC_SELORI == "1" //--Origem Transportadora
												If SM0->(MsSeek(cEmpAnt+cFilAnt))
													cMunic := Substr(SM0->M0_CIDENT,1,26)
												EndIf
											EndIf
										Else
											SA1->(DbSetOrder(1))
											If SA1->(MsSeek(xFilial("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
												cMunic := Substr(SA1->A1_MUN,1,26)
												cUF    := SA1->A1_EST
											Else
												cMunic := ''
											EndIf
										EndIf
									EndIf
								Else
									DTC->(DbSetOrder(1)) //DTC_FILIAL+DTC_FILORI+DTC_LOTNFC+DTC_CLIREM+DTC_LOJREM+DTC_CLIDES+DTC_LOJDES+DTC_SERVIC+DTC_CODPRO+DTC_NUMNFC+DTC_SERNFC+DTC_NUMSOL
									If DTC->(MsSeek(xFilial('DTC') + DT6->(DT6_FILORI + DT6_LOTNFC)))
										If !Empty(DTC->DTC_NUMSOL) .And. DTC->DTC_SELORI == "3" //--Origem e Local de Coleta
											//-- Posiciona na Ordem de Coleta
											DT5->(DbSetOrder (1))
											If DT5->(MsSeek (xFilial ("DT5")+DTC->DTC_FILORI+DTC->DTC_NUMSOL))
												//--Verifica se o Solicitante tem Sequencias de Endereco
												If Empty (DT5->DT5_SEQEND)
													DUE->(dbSetOrder(1))    
													DUE->(MsSeek(xFilial("DUE")+DT5->DT5_CODSOL))													
													cMunic	:=	SubStr (DUE->DUE_MUN, 1, 26)	//(Cod. Municipio para imprimir no DIPAM)
													cUF		:=  DUE->DUE_EST
												Else                                      
													DUL->(dbSetOrder(3))
													DUL->(MsSeek(xFilial("DUL")+DT5->(DT5_CODSOL+DT5_SEQEND)))
													cMunic	:=	SubStr (DUL->DUL_MUN, 1, 26)	//(Cod. Municipio para imprimir no DIPAM)
													cUF		:=  DUL->DUL_EST
												EndIf
											EndIf
										ElseIf DTC->DTC_SELORI == "2" //--Origem Cliente Remetente
											SA1->(DbSetOrder (1))
											If SA1->(MsSeek (xFilial ("SA1")+DT6->(DT6_CLIREM+DT6_LOJREM)))
												cMunic := Substr(SA1->A1_MUN,1,26)
												cUF    := SA1->A1_EST
											Else
												cMunic := ''
											EndIf
										ElseIf DTC->DTC_SELORI == "1" //--Origem Transportadora
											If SM0->(MsSeek(cEmpAnt+cFilAnt))
												cMunic := Substr(SM0->M0_CIDENT,1,26)
												cUF    := SM0->M0_ESTENT
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					SA1->(dbSeek(xFilial()+cSeek))
					cMunic	:=	Substr(SA1->A1_MUN,1,26)
				EndIf
			EndIf

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define campo da DIPAM que seja lancado o valor da nota       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If substr(cCFO,1,1)>="5"
				Do Case
					Case cCfo$"511/611/5101/6101/512/612/5102/6102/514/614/5103/6103/515/615/5104/6104/516/616/5105/6105/517/617/5106/6106/618/6107/619/6108/513/613/5124/6124"
						nCpo	:=	10+If(Substr(cCFO,1,1)=="5",1,2)
					Case cCfo$"710/7100/711/7101/712/7102/716/7105/717/7106/730/7200/731/7201/732/7202/733/7205/733/7205/7206/734/7207/740/7250/741/7251/750/7300/760/7350/761/7358/790/7900"
						nCpo	:=	13
					Case cCfo$"597/697/5414/6414/5415/6415/591/691/5551/6551/592/692/5552/6552/595/695/5553/6553/595/695/5556/6556/592/692/5557/6557/590/690/5900/6900/593/693/5901/6901/594/694/5902/6902/596/696/5904/6904"
						nCpo	:=	10+IIF(Subs(cCfo,1,1)=="5",4,5)
					Case cCfo$"521/522/523/524/5151/5152/5153"
						nCpo	:=	14
					Case cCfo$"621/622/623/624/6151/6152/6153"
						nCpo	:=	15
					Otherwise
						nCpo	:=	17
				EndCase
			Else
				Do Case
		            Case cCFO$cCfopUf .And. Empty(SA2->A2_TIPORUR)	//Compras do Estado, exceto Codigo (11)
						nCpo	:=	20
					Case cCFO$cCfopPR .And. !Empty(SA2->A2_TIPORUR)//Compras a Produtor Rural do Estado
						nCpo	:=	22
					Case cCfo$"121/122/123/124/1151/1152/1153/1154"
						nCpo	:=	24
					Case cCfo$"221/222/223/224/2151/2152/2153/2154"
						nCpo	:=	25
					Case cCfo$"196/296/1414/2414/1415/2415/191/291/1551/2551/192/292/1552/2552/197/297/1556/2556/198/298/1557/2557/190/290/1900/2900/193/293/1901/2901/194/294/1902/2902/195/295/1904/2904"
						nCpo	:=	20+If(Subs(cCfo,1,1)=="1",4,5)
					Case cCfo$"310/3100/311/3101/312/3102/313/3126/394/3127/320/3200/321/3201/322/3202/323/3205/3206/324/3207/330/3250/331/3251/340/3300/341/3301/350/3350/351/3351/352/3352/353/3353/354/3354/391/3551/397/3556/390/3900"
						nCpo	:=	23
					Case cCfo$"210/2100/211/2101/212/2102/213/2124/214/2126"
						nCpo	:=	21
					Otherwise
						nCpo	:=	28
				EndCase
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁTratamento alternativo ao codigo do DIPAM                             Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lExecBlock
				ExecBlock("DIPAM",.F.,.F.)
			Endif
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula valor da nota no campo da DIPAM definido acima       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aCamposD[nCpo]	+=	nValNota
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula por municipio                                        Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If Alltrim(Upper(cMunic))==Alltrim(Upper(SM0->M0_CIDENT))
				cMunic	:=	STR0008 //"DO PROPRIO MUNICIPIO"
			Endif
			nPos	:=	Ascan(aCamposE,{|x|x[1]==cMunic .And. x[18]==cUF})
			If nPos==0
				AADD(aCamposE,{cMunic,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,IIf(IntTMS(),cUF,(cAliasSF3)->F3_ESTADO)})
				nPos	:=	Len(aCamposE)
			Endif
			Do Case
				Case nCpo==11; nColuna:=2
				Case nCpo==12; nColuna:=3
				Case nCpo==13; nColuna:=4
				Case nCpo==14; nColuna:=5
				Case nCpo==15; nColuna:=6
				Case nCpo==16; nColuna:=7
				Case nCpo==17; nColuna:=8
					
				Case nCpo==20; nColuna:=9
				Case nCpo==21; nColuna:=10
				Case nCpo==22; nColuna:=11
				Case nCpo==23; nColuna:=12
				Case nCpo==24; nColuna:=13
				Case nCpo==25; nColuna:=14
				Case nCpo==26; nColuna:=15
				Case nCpo==27; nColuna:=16
				Case nCpo==28; nColuna:=17
			EndCase
			aCamposE[nPos,nColuna]	+=	nValNota
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula por Estado                                           Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nPos :=	Ascan(aEstado,{|x|x[1]==cUF})
			If nPos==0
				AADD(aEstado,{IIf(IntTMS(),cUF,(cAliasSF3)->F3_ESTADO),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
				nPos	:=	Len(aEstado)
			Endif
			aEstado[nPos,nColuna] += nValNota
		
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava em arquivo temporario para conferencia                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nCodigo	:=	If(nCpo>=20,nColuna,(nColuna-1))
			
			R925GravaConf(cArqTemp,If(Val(Substr((cAliasSF3)->F3_CFO,1,1))<5,"E","S"),(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,cMunic,Str(nCodigo,2),nValNota,(cAliasSF3)->F3_TIPO,cUF)
			
			(cAliasSF3)->(dbSkip())
		Enddo
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Totaliza valores da DIPAM                                    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aCamposD[19]:=aCamposD[11]+aCamposD[12]+aCamposD[13]+aCamposD[14]+aCamposD[15]+aCamposD[16]+aCamposD[17]
		aCamposD[30]:=aCamposD[20]+aCamposD[21]+aCamposD[22]+aCamposD[23]+aCamposD[24]+aCamposD[25]+aCamposD[26]+aCamposD[27]+aCamposD[28]
		aCamposD[33]:=aCamposD[19]-aCamposD[30]
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao                                                    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(aCamposD) .And. !Empty(aCamposE) .And. !Empty(aEstado)
			While !lEnd
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Cabecalho do formulario                                      Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				R925Cab(aL,@nLin)
				FmtLin(,{aL[8],aL[9],aL[10],aL[11],aL[12],aL[13],aL[14],aL[15],aL[16]},,,@nLin)
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Quadro [ E ]                                                 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				FmtLin({aCamposD[11],aCamposD[20]},aL[17],cPict,,@nLin)
				FmtLin({aCamposD[12],aCamposD[21]},aL[18],cPict,,@nLin)
				FmtLin({aCamposD[13],aCamposD[22]},aL[19],cPict,,@nLin)
				FmtLin({aCamposD[14],aCamposD[23]},aL[20],cPict,,@nLin)
				FmtLin({aCamposD[15],aCamposD[24]},aL[21],cPict,,@nLin)
				FmtLin({aCamposD[16],aCamposD[25]},aL[22],cPict,,@nLin)
				FmtLin({aCamposD[17],aCamposD[26]},aL[23],cPict,,@nLin)
				
				FmtLin({aCamposD[27]},aL[24],cPict,,@nLin)
				FmtLin({aCamposD[19],aCamposD[28]},aL[25],cPict,,@nLin)
				FmtLin(,aL[26],cPict,,@nLin)
				FmtLin({aCamposD[30]},aL[27],cPict,,@nLin)
				FmtLin(,aL[28],cPict,,@nLin)
				FmtLin({aCamposD[33]},aL[29],cPict,,@nLin)
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Quadro detalhado                                             Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				aCamposE	:=	Asort(aCamposE,,,{|x,y|x[1]<y[1]})
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Saidas 11 a 17                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				FmtLin(,{aL[30],aL[31],aL[32],aL[33],aL[34]},,,@nLin)
				aTotCamposE	:=	Array(7)
				aTotCamposE	:=	Afill(aTotCamposE,0)
				For i:=1 to Len(aCamposE)
					If aCamposE[i,2]+aCamposE[i,3]+aCamposE[i,4]+aCamposE[i,5]+aCamposE[i,6]+aCamposE[i,7]+aCamposE[i,8]==0
						Loop
					Endif
					If nLin>60
						FmtLin(,aL[01],,,@nLin)
						R925Cab(aL,@nLin)
						FmtLin(,{aL[30],aL[31],aL[32],aL[33],aL[34]},,,@nLin)
					Endif
					FmtLin({Left(aCamposE[i,1],63),aCamposE[i,18],aCamposE[i,2],aCamposE[i,3],aCamposE[i,4],aCamposE[i,5],aCamposE[i,6],aCamposE[i,7],aCamposE[i,8]},aL[35],cPict,,@nLin)
					aTotCamposE[1]	+=	aCamposE[i,2]
					aTotCamposE[2]	+=	aCamposE[i,3]
					aTotCamposE[3]	+=	aCamposE[i,4]
					aTotCamposE[4]	+=	aCamposE[i,5]
					aTotCamposE[5]	+=	aCamposE[i,6]
					aTotCamposE[6]	+=	aCamposE[i,7]
					aTotCamposE[7]	+=	aCamposE[i,8]
				Next i
				FmtLin(,aL[36],,,@nLin)
				FmtLin({aTotCamposE[1],aTotCamposE[2],aTotCamposE[3],aTotCamposE[4],aTotCamposE[5],aTotCamposE[6],aTotCamposE[7]},aL[37],cPict,,@nLin)
				nLin:=nLin+1
				FmtLin(,aL[38],,,@nLin)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Saidas 20 a 20                                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				FmtLin(,{aL[39],aL[40],aL[41],aL[42]},,,@nLin)
				aTotCamposE	:=	Array(9)
				aTotCamposE	:=	Afill(aTotCamposE,0)
				For i:=1 to Len(aCamposE)
					If aCamposE[i,9]+aCamposE[i,10]+aCamposE[i,11]+aCamposE[i,12]+aCamposE[i,13]+aCamposE[i,14]+aCamposE[i,15]+aCamposE[i,16]+aCamposE[i,17]==0
						Loop
					Endif
					If nLin>60
						FmtLin(,aL[01],,,@nLin)
						R925Cab(aL,@nLin)
						FmtLin(,{aL[38],aL[39],aL[40],aL[41],aL[42]},,,@nLin)
					Endif
					FmtLin({Left(aCamposE[i,1],25),aCamposE[i,18],aCamposE[i,9],aCamposE[i,10],aCamposE[i,11],aCamposE[i,12],aCamposE[i,13],aCamposE[i,14],aCamposE[i,15],aCamposE[i,16],aCamposE[i,17]},aL[43],cPict,,@nLin)
					aTotCamposE[1]	+=	aCamposE[i,9]
					aTotCamposE[2]	+=	aCamposE[i,10]
					aTotCamposE[3]	+=	aCamposE[i,11]
					aTotCamposE[4]	+=	aCamposE[i,12]
					aTotCamposE[5]	+=	aCamposE[i,13]
					aTotCamposE[6]	+=	aCamposE[i,14]
					aTotCamposE[7]	+=	aCamposE[i,15]
					aTotCamposE[8]	+=	aCamposE[i,16]
					aTotCamposE[9]	+=	aCamposE[i,17]
				Next i
				While nLin<57
					FmtLin(Array(11),aL[43],,,@nLin)
				End
				FmtLin(,aL[44],,,@nLin)
				FmtLin({aTotCamposE[1],aTotCamposE[2],aTotCamposE[3],aTotCamposE[4],aTotCamposE[5],aTotCamposE[6],aTotCamposE[7],aTotCamposE[8],aTotCamposE[9]},aL[45],cPict,,@nLin)
				nLin:=nLin+1
				FmtLin(,aL[46],,,@nLin)
				
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprime lista para conferencia                               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				R925ImpConf(@lEnd,cArqTemp,nLin)
			
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprime Resumo por Estado - em uma nova pagina               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				// Saidas
				nLin := 61
				R925Cab(aL,@nLin)
				aTotEst := AFill(aTotEst,0)
				FmtLin(,aL[64],,,@nLin)
				FmtLin(,aL[54],,,@nLin)
				FmtLin(,aL[65],,,@nLin)
				FmtLin(,aL[56],,,@nLin)	
				FmtLin(,aL[57],,,@nLin)	
				For i := 1 to Len(aEstado)
					If aEstado[i][02] + aEstado[i][03] + aEstado[i][04] + aEstado[i][05] + aEstado[i][06] + aEstado[i][07] + aEstado[i][08] > 0
						If nLin>60
							R925Cab(aL,@nLin)
						Endif    
						FmtLin({aEstado[i][01],aEstado[i][02],aEstado[i][03],aEstado[i][04],aEstado[i][05],aEstado[i][06],aEstado[i][07],aEstado[i][08]},aL[58],,,@nLin)	
						aTotEst[01] += aEstado[i][02]
						aTotEst[02] += aEstado[i][03]
						aTotEst[03] += aEstado[i][04]
						aTotEst[04] += aEstado[i][05]
						aTotEst[05] += aEstado[i][06]
						aTotEst[06] += aEstado[i][07]
						aTotEst[07] += aEstado[i][08]
					Endif
				Next                    
				FmtLin(,aL[57],,,@nLin)
				FmtLin({aTotEst[01],aTotEst[02],aTotEst[03],aTotEst[04],aTotEst[05],aTotEst[06],aTotEst[07]},aL[63],,,@nLin)	
				FmtLin(,aL[65],,,@nLin)
			
				// Entradas
				aTotEst := AFill(aTotEst,0)
				nLin:=nLin+1           
				FmtLin(,aL[55],,,@nLin)
				FmtLin(,aL[64],,,@nLin)
				FmtLin(,aL[59],,,@nLin)	
				FmtLin(,aL[60],,,@nLin)	
				For i := 1 to Len(aEstado) 
					If aEstado[i][09] + aEstado[i][10] + aEstado[i][11] + aEstado[i][12] + aEstado[i][13] + aEstado[i][14] + aEstado[i][15] + aEstado[i][16] + aEstado[i][17] > 0
						If nLin>60
							R925Cab(aL,@nLin)
						Endif    
						FmtLin({aEstado[i][01],aEstado[i][09],aEstado[i][10],aEstado[i][11],aEstado[i][12],aEstado[i][13],aEstado[i][14],aEstado[i][15],aEstado[i][16],aEstado[i][17]},aL[61],,,@nLin)	
						aTotEst[01] += aEstado[i][09]
						aTotEst[02] += aEstado[i][10]
						aTotEst[03] += aEstado[i][11]
						aTotEst[04] += aEstado[i][12]
						aTotEst[05] += aEstado[i][13]
						aTotEst[06] += aEstado[i][14]
						aTotEst[07] += aEstado[i][15]
						aTotEst[08] += aEstado[i][16]
						aTotEst[09] += aEstado[i][17]
					Endif
				Next                    
				FmtLin(,aL[60],,,@nLin)
				FmtLin({aTotEst[01],aTotEst[02],aTotEst[03],aTotEst[04],aTotEst[05],aTotEst[06],aTotEst[07],aTotEst[08],aTotEst[09]},aL[62],,,@nLin)	
				FmtLin(,aL[64],,,@nLin)
				Exit
			Enddo
		Endif	
		//здддддддддддддддддддддддддддддддд©
		//ЁExcluindo as areas de trabalho  Ё
		//юдддддддддддддддддддддддддддддддды
		If lQuery
			dbSelectArea(cAliasSF3)
			dbCloseArea()
		Else
			dbSelectArea("SF3")
			RetIndex("SF3")
			dbClearFilter()
			Ferase(cIndSF3+OrdBagExt())
		Endif	
		
		RestArea(aArea)
		
		//здддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁQuando mudar a filial, reinicia os totalizadoresЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддды
		aCamposD := Afill(aCamposD,0)
	    aCamposE := {}  
	    aEstado  := {}
		
		SM0->(DbSkip ())
	EndDo
	// Restaura filial original apos processamento
	SM0->(RestArea(aAreaSM0) )
	cFilAnt		:=	SM0->M0_CODFIL		
Endif
	
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁR925ImpTotЁ Autor Ё Luciana Pires         Ё Data Ё 15.05.08 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Imprime Totalizadores do relatorio                         Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
*/

Static Function R925ImpTot(aCamposD,lEnd,aL,nLin,cPict,aCamposE,cArqTemp,aEstado)
Local aTotCamposE 	:= {}    
Local aTotEst		:= {}
Local i				:= 1
Local nTotAntes     := 0
Local nTotApos      := 0
Local nPercent      := 0        

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Totaliza valores da DIPAM                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCamposD[08]:=aCamposD[01]+aCamposD[02]+aCamposD[03]+aCamposD[04]+aCamposD[05]+aCamposD[06]+aCamposD[07]
aCamposD[18]:=aCamposD[09]+aCamposD[10]+aCamposD[11]+aCamposD[12]+aCamposD[13]+aCamposD[14]+aCamposD[15]+aCamposD[16]+aCamposD[17]
aCamposD[19]:=aCamposD[08]-aCamposD[18]
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Impressao                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While !lEnd
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cabecalho do formulario                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	R925Cab(aL,@nLin)
	FmtLin(,{aL[8],aL[9],aL[10],aL[11],aL[12],aL[13],aL[14],aL[15],aL[16]},,,@nLin)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Quadro [ E ]                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FmtLin({aCamposD[01],aCamposD[09]},aL[17],cPict,,@nLin)
	FmtLin({aCamposD[02],aCamposD[10]},aL[18],cPict,,@nLin)
	FmtLin({aCamposD[03],aCamposD[11]},aL[19],cPict,,@nLin)
	FmtLin({aCamposD[04],aCamposD[12]},aL[20],cPict,,@nLin)
	FmtLin({aCamposD[05],aCamposD[13]},aL[21],cPict,,@nLin)
	FmtLin({aCamposD[06],aCamposD[14]},aL[22],cPict,,@nLin)
	FmtLin({aCamposD[07],aCamposD[15]},aL[23],cPict,,@nLin)

	FmtLin({aCamposD[16]},aL[24],cPict,,@nLin)
	FmtLin({aCamposD[08],aCamposD[17]},aL[25],cPict,,@nLin)
	FmtLin(,aL[26],cPict,,@nLin)
	FmtLin({aCamposD[18]},aL[27],cPict,,@nLin)
	FmtLin(,aL[28],cPict,,@nLin)
	FmtLin({aCamposD[19]},aL[29],cPict,,@nLin)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Quadro detalhado                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aCamposE	:=	Asort(aCamposE,,,{|x,y|x[1]<y[1]})

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Saidas 01 A 07                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FmtLin(,{aL[30],aL[31],aL[32],aL[33],aL[34]},,,@nLin)
	aTotCamposE	:=	Array(7)
	aTotCamposE	:=	Afill(aTotCamposE,0)
	For i:=1 to Len(aCamposE)
	    nTotAntes +=aCamposE[i,4]
	Next i                  
    nTotApos +=aCamposD[3]
	For i:=1 to Len(aCamposE)
	    nPercent := aCamposE[i,4]/nTotAntes
	    aCamposE[i,4] := nTotApos*nPercent
	Next i       
	
	For i:=1 to Len(aCamposE)
		If aCamposE[i,19]<>"S" 
			If aCamposE[i,2]+aCamposE[i,3]+aCamposE[i,4]+aCamposE[i,5]+aCamposE[i,6]+aCamposE[i,7]+aCamposE[i,8]==0
				Loop
			Endif
			Loop
		Endif
		If nLin>60
			FmtLin(,aL[01],,,@nLin)
			R925Cab(aL,@nLin)
			FmtLin(,{aL[30],aL[31],aL[32],aL[33],aL[34]},,,@nLin)
		Endif
		FmtLin({Left(aCamposE[i,1],63),aCamposE[i,18],aCamposE[i,2],aCamposE[i,3],aCamposE[i,4],aCamposE[i,5],aCamposE[i,6],aCamposE[i,7],aCamposE[i,8]},aL[35],cPict,,@nLin)
		aTotCamposE[1]	+=	aCamposE[i,2]
		aTotCamposE[2]	+=	aCamposE[i,3]
		aTotCamposE[3]	+=	aCamposE[i,4]
		aTotCamposE[4]	+=	aCamposE[i,5]
		aTotCamposE[5]	+=	aCamposE[i,6]
		aTotCamposE[6]	+=	aCamposE[i,7]
		aTotCamposE[7]	+=	aCamposE[i,8]
	Next i
	FmtLin(,aL[36],,,@nLin)
	FmtLin({aTotCamposE[1],aTotCamposE[2],aTotCamposE[3],aTotCamposE[4],aTotCamposE[5],aTotCamposE[6],aTotCamposE[7]},aL[37],cPict,,@nLin)
	nLin:=nLin+1
	FmtLin(,aL[38],,,@nLin)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Entradas 09 a 17                                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FmtLin(,{aL[39],aL[40],aL[41],aL[42]},,,@nLin)
	aTotCamposE	:=	Array(9)
	aTotCamposE	:=	Afill(aTotCamposE,0)
	For i:=1 to Len(aCamposE)
		If aCamposE[i,19]<>"E" 
			If aCamposE[i,9]+aCamposE[i,10]+aCamposE[i,11]+aCamposE[i,12]+aCamposE[i,13]+aCamposE[i,14]+aCamposE[i,15]+aCamposE[i,16]+aCamposE[i,17]==0
				Loop
			Endif
			Loop
		Endif
		If nLin>60
			FmtLin(,aL[01],,,@nLin)
			R925Cab(aL,@nLin)
			FmtLin(,{aL[38],aL[39],aL[40],aL[41],aL[42]},,,@nLin)
		Endif
		FmtLin({Left(aCamposE[i,1],25),aCamposE[i,18],aCamposE[i,09],aCamposE[i,10],aCamposE[i,11],aCamposE[i,12],aCamposE[i,13],aCamposE[i,14],aCamposE[i,15],aCamposE[i,16],aCamposE[i,17]},aL[43],cPict,,@nLin)
		aTotCamposE[1]	+=	aCamposE[i,9]
		aTotCamposE[2]	+=	aCamposE[i,10]
		aTotCamposE[3]	+=	aCamposE[i,11]
		aTotCamposE[4]	+=	aCamposE[i,12]
		aTotCamposE[5]	+=	aCamposE[i,13]
		aTotCamposE[6]	+=	aCamposE[i,14]
		aTotCamposE[7]	+=	aCamposE[i,15]
		aTotCamposE[8]	+=	aCamposE[i,16]
		aTotCamposE[9]	+=	aCamposE[i,17]
	Next i
	FmtLin(,aL[44],,,@nLin)
	FmtLin({aTotCamposE[1],aTotCamposE[2],aTotCamposE[3],aTotCamposE[4],aTotCamposE[5],aTotCamposE[6],aTotCamposE[7],aTotCamposE[8],aTotCamposE[9]},aL[45],cPict,,@nLin)
	nLin:=nLin+1
	FmtLin(,aL[46],,,@nLin)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime lista para conferencia - em um nova pagina           Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//Entradas e Saidas
	R925ImpConf(@lEnd,cArqTemp,nLin)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime Resumo por Estado - em uma nova pagina               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	// Saidas
	nLin := 61
	R925Cab(aL,@nLin)
	aTotEst	:=	Array(7)
	aTotEst := AFill(aTotEst,0)
	FmtLin(,aL[64],,,@nLin)
	FmtLin(,aL[54],,,@nLin)
	FmtLin(,aL[65],,,@nLin)
	FmtLin(,aL[56],,,@nLin)
	FmtLin(,aL[57],,,@nLin)
	For i := 1 to Len(aEstado)
		If aEstado[i][18] == "S"
			If aEstado[i][02] + aEstado[i][03] + aEstado[i][04] + aEstado[i][05] + aEstado[i][06] + aEstado[i][07] + aEstado[i][08] > 0
				If nLin>60
					R925Cab(aL,@nLin)
				Endif    
				FmtLin({aEstado[i][01],aEstado[i][02],aEstado[i][03],aEstado[i][04],aEstado[i][05],aEstado[i][06],aEstado[i][07],aEstado[i][08]},aL[58],,,@nLin)	
				aTotEst[01] += aEstado[i][02]
				aTotEst[02] += aEstado[i][03]
				aTotEst[03] += aEstado[i][04]
				aTotEst[04] += aEstado[i][05]
				aTotEst[05] += aEstado[i][06]
				aTotEst[06] += aEstado[i][07]
				aTotEst[07] += aEstado[i][08]
			Endif
		Endif
	Next                    
	FmtLin(,aL[57],,,@nLin)
	FmtLin({aTotEst[01],aTotEst[02],aTotEst[03],aTotEst[04],aTotEst[05],aTotEst[06],aTotEst[07]},aL[63],,,@nLin)	
	FmtLin(,aL[65],,,@nLin)

	// Entradas
	aTotEst	:=	Array(9)
	aTotEst := AFill(aTotEst,0)
	nLin:=nLin+1           
	FmtLin(,aL[55],,,@nLin)
	FmtLin(,aL[64],,,@nLin)
	FmtLin(,aL[59],,,@nLin)	
	FmtLin(,aL[60],,,@nLin)	
	For i := 1 to Len(aEstado) 
		If aEstado[i][18] == "E"
			If aEstado[i][09] + aEstado[i][10] + aEstado[i][11] + aEstado[i][12] + aEstado[i][13] + aEstado[i][14] + aEstado[i][15] + aEstado[i][16] + aEstado[i][17] > 0
				If nLin>60
					R925Cab(aL,@nLin)
				Endif    
				FmtLin({aEstado[i][01],aEstado[i][09],aEstado[i][10],aEstado[i][11],aEstado[i][12],aEstado[i][13],aEstado[i][14],aEstado[i][15],aEstado[i][16],aEstado[i][17]},aL[61],,,@nLin)	
				aTotEst[01] += aEstado[i][09]
				aTotEst[02] += aEstado[i][10]
				aTotEst[03] += aEstado[i][11]
				aTotEst[04] += aEstado[i][12]
				aTotEst[05] += aEstado[i][13]
				aTotEst[06] += aEstado[i][14]
				aTotEst[07] += aEstado[i][15]
				aTotEst[08] += aEstado[i][16]
				aTotEst[09] += aEstado[i][17]
			Endif
		Endif
	Next                    
	FmtLin(,aL[60],,,@nLin)
	FmtLin({aTotEst[01],aTotEst[02],aTotEst[03],aTotEst[04],aTotEst[05],aTotEst[06],aTotEst[07],aTotEst[08],aTotEst[09]},aL[62],,,@nLin)	
	FmtLin(,aL[64],,,@nLin)
	FmtLin(,aL[66],,,@nLin)
	FmtLin(,aL[67],,,@nLin)	
	Exit
Enddo			

Return()

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё R925Cab  Ё Autor Ё Juan Jose Pereira     Ё Data Ё 08.12.95 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Cabecalho do relat╒rio                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
*/

Static Function R925Cab(aL,nLin)
Local cAno	:=	Alltrim(Str(Year(dDtIni))),cDtIni:=Dtoc(dDtIni),cDtFim:=Dtoc(dDtFim)

nLin		:=	0
@nLin,0 PSAY AvalImp(220)
FmtLin(,{aL[1],aL[2],aL[3]},,,@nLin)
FmtLin({Alltrim(SM0->M0_NOMECOM),cAno,cDtIni,cDtFim},aL[4],,,@nLin)
FmtLin({Alltrim(SM0->M0_ENDENT),Alltrim(SM0->M0_CGC),cFilAnt},aL[5],,,@nLin)
FmtLin({Alltrim(SM0->M0_CIDENT),InscrEst()},aL[6],,,@nLin)
FmtLin(,{aL[7]},,,@nLin)

Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    ЁR925LayOutЁ Autor Ё Juan Jose Pereira     Ё Data Ё 08.12.95 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao ЁLay-Out do relatorio                                        Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static Function R925LayOut(lNovaGia,lImpDipamA)

Local aL           :=	Array(67)

If lImpDipamA
	aL[01]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[02]:=STR0052 //"                                                              RELATORIO AUXILIAR P/ PREENCHIMENTO DA DIPAM-A                                                                    "
	aL[03]:="                                                                                                                                                                                                         "
	aL[04]:=STR0010 //"  CONTRIBUINTE: ######################################################             ANO BASE...........: ####                                                           PERIODO: ########## A ##########  "
	aL[05]:=STR0011 //"  ENDERECO....: ######################################################             C.N.P.J............: ##############                                                 FILIAL.: ##                       "
	aL[06]:=STR0012 //"  MUNICIPIO...: ######################################################             INSCRICAO ESTADUAL : #############                                                                                    "
	aL[07]:="                                                                                                                                                                                                         "
	aL[08]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[09]:="                                                                                                                                                                                                         "
	aL[10]:=STR0013 //"                                                                                      APURACAO DO VALOR ADICIONADO                                                                                       "
	aL[11]:="                                                                                                                                                                                                         "
	aL[12]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[13]:=STR0053 //"  SAIDAS DA PRODUгцO                                                      CсD.                VALOR                                                                                                             "
	aL[14]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[15]:=STR0054 //"  PRODUTOR NO ESTADO                                                      [02]   ##################                                                                                                      "
	aL[16]:=STR0055 //"  NцO CONTRIBUINTE NO ESTADO                                              [03]   ##################                                                                                                      "
	aL[17]:=STR0056 //"  OUTRO ESTADO                                                            [04]   ##################                                                                                                      "
	aL[18]:=STR0057 //"  EXTERIOR                                                                [05]   ##################                                                                                                      "
	aL[19]:=STR0058 //"                                                                                                                                                                                                         "
	aL[20]:=STR0059 //"  TOTAL (02 A 05)                                                                ##################                                                                                                      "
Else
	aL[01]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[02]:=STR0009 //"                                                              MAPA DA DECLARACAO P/ O INDICE DE PARTICIPACAO DOS MUNICIPIOS (DIPAM-B)                                                                    "
	aL[03]:="                                                                                                                                                                                                         "
	aL[04]:=STR0010 //"  CONTRIBUINTE: ######################################################             ANO BASE...........: ####                                                           PERIODO: ########## A ##########  "
	aL[05]:=STR0011 //"  ENDERECO....: ######################################################             C.N.P.J............: ##############                                                 FILIAL.: ##                       "
	aL[06]:=STR0012 //"  MUNICIPIO...: ######################################################             INSCRICAO ESTADUAL : #############                                                                                    "
	aL[07]:="                                                                                                                                                                                                         "
	aL[08]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[09]:="                                                                                                                                                                                                         "
	aL[10]:=STR0013 //"                                                                                      APURACAO DO VALOR ADICIONADO                                                                                       "
	aL[11]:="                                                                                                                                                                                                         "
	aL[12]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[13]:=STR0014 //"                              S A I D A S                                                           |                            E N T R A D A S                                                         "
	aL[14]:="----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------"
	aL[15]:=STR0015 //"  OPERACAO                                                                ITEM         VALOR        | OPERACAO                                                                ITEM          VALOR        "
	aL[16]:="------------------------------------------------------------------------ ------ --------------------|----------------------------------------------------------------------- ------ ---------------------"
	If !lNovaGia
		aL[17]:=STR0016 //"  VENDAS PARA O ESTADO                                                    [01]   ################## | COMPRAS DO ESTADO , EXCETO CODIGO (11)                                  [09]   ##################  "
		aL[18]:=STR0017 //"  VENDAS PARA OUTROS ESTADOS                                              [02]   ################## | COMPRAS DE OUTROS ESTADOS                                               [10]   ##################  "
		aL[19]:=STR0018 //"  VENDAS PARA O EXTERIOR                                                  [03]   ################## | COMPRAS A PRODUTOR RURAL do ESTADO                                      [11]   ##################  "
		aL[20]:=STR0019 //"  TRANSFERENCIAS PARA O ESTADO                                            [04]   ################## | IMPORTACOES DO EXTERIOR                                                 [12]   ##################  "
		aL[21]:=STR0020 //"  TRANSFERENCIAS PARA OUTROS ESTADOS                                      [05]   ################## | TRANSFERENCIAS DO ESTADO                                                [13]   ##################  "
		aL[22]:=STR0021 //"  NAO ESCRITURADAS                                                        [06]   ################## | TRANSFERENCIAS DE OUTROS ESTADOS                                        [14]   ##################  "
		aL[23]:=STR0022 //"  OUTRAS                                                                  [07]   ################## | NAO ESCRITURADAS, EXCETO CODIGO (16)                                    [15]   ##################  "
		aL[24]:=STR0023 //"                                                                                                    | NAO ESCRITURADAS. COMPRAS DE PROD.DO EST.                               [16]   ##################  "
		aL[25]:=STR0024 //"  SOMA (01 A 07)                                                          [08]   ################## | OUTRAS                                                                  [17]   ##################  "
	Else
		aL[17]:=STR0043 //"  VENDAS PROD./MERC.DO ESTAB. E FORA DO ESTAB. (CсD.22)                   [01]   ################## | COMPRA ESCRITURADA DE MERC. DE PRODUTOS AGROPECUаRIOS (CсD.11)          [09]   ##################  "
		aL[18]:=STR0044 //"  PRESTAгцO SERVIгO TRANSPORTE (CсD.23)                                   [02]   ################## | RECEB. POR COOPERATIVA DE MERC. REMETIDAS POR PROD. AGROP. (CсD.13)     [10]   ##################  "
		aL[19]:=STR0045 //"  PRESTAгцO SERVIгO COMUNICAгцO (CсD.24)                                  [03]   ################## |                                                                         [11]   ##################  "
		aL[20]:=STR0046 //"  VENDA ENERGIA ELиTRICA (CсD.25)                                         [04]   ################## |                                                                         [12]   ##################  "
		aL[21]:=STR0047 //"                                                                          [05]   ################## |                                                                         [13]   ##################  "
		aL[22]:=STR0048 //"                                                                          [06]   ################## |                                                                         [14]   ##################  "
		aL[23]:=STR0049 //"                                                                          [07]   ################## |                                                                         [15]   ##################  "
		aL[24]:=STR0050 //"                                                                                                    |                                                                         [16]   ##################  "
		aL[25]:=STR0051 //"  SOMA (01 A 07)                                                          [08]   ################## |                                                                         [17]   ##################  "
	Endif
	aL[26]:="                                                                                                    |                                                                                                    "
	aL[27]:=STR0025 //"                                                                                                    | SOMA (09 A 17)                                                          [18]   ##################  "
	aL[28]:="                                                                                                    |                                                                                                    "
	aL[29]:=STR0026 //"                                                                                                    | VALOR ADICIONADO (08-18)                                                [19]   ##################  "
	aL[30]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[31]:=STR0027 //"  DESDOBRAMENTO DOS CODIGOS DE 01 A 07                                                                                                                                                                   "
	aL[32]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[33]:=STR0028 //"                          MUNICIPIO                              UF    CODIGO [01]        CODIGO [02]        CODIGO [03]        CODIGO [04]        CODIGO [05]        CODIGO [06]        CODIGO [07]     "
	aL[34]:="---------------------------------------------------------------- -- ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ -------------------"
	aL[35]:=" ############################################################### ## ################## ################## ################## ################## ################## ################## ################## "
	aL[36]:="---------------------------------------------------------------- -- ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ "
	aL[37]:=STR0029 //"  TOTAL                                                             ################## ################## ################## ################## ################## ################## ################## "
	aL[38]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[39]:=STR0030 //"  DESDOBRAMENTO DOS CODIGOS DE 09 A 17                                                                                                                                                                   "
	aL[40]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[41]:=STR0031 //"        MUNICIPIO          UF    CODIGO [09]        CODIGO [10]        CODIGO [11]        CODIGO [12]        CODIGO [13]        CODIGO [14]        CODIGO [15]        CODIGO [16]        CODIGO [17]     "
	aL[42]:="-------------------------- -- ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ -------------------"
	aL[43]:=" ######################### ## ################## ################## ################## ################## ################## ################## ################## ################## ################## "
	aL[44]:="-------------------------- -- ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ ------------------ "
	aL[45]:="  TOTAL                       ################## ################## ################## ################## ################## ################## ################## ################## ################## "
	aL[46]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[47]:=STR0033 //"  LISTAGEM PARA CONFERENCIA - SAIDAS   (CODIGOS 09 A 17)                                                                                                                                                 "
	aL[48]:=STR0034 //"  LISTAGEM PARA CONFERENCIA - ENTRADAS (CODIGOS 01 A 07)                                                                                                                                                 "
	aL[49]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[50]:=STR0035 //"                   CLIENTE / FORNECEDOR                               MUNICIPIO            UF   NOTA FISCAL      CODIGO                                      VALOR                                       "
	aL[51]:="------------------------------------------------------------ ---------------------------- ---- ---------------- -------- --------------------------------------------------------------------------------"
	aL[52]:="  ###########   ###########################################   ##########################   ##   ######### ###      ##                                                                 ################## "
	aL[53]:="---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[54]:=STR0037 //"  RESUMO POR ESTADO - SAIDAS   (CODIGOS 01 A 07)                                                                                                                                                 "
	aL[55]:=STR0038 //"  RESUMO POR ESTADO - ENTRADAS (CODIGOS 09 A 17)                                                                                                                                                 "
	aL[56]:=STR0039 //"  ESTADO           CODIGO [01]          CODIGO [02]          CODIGO [03]          CODIGO [04]          CODIGO [05]          CODIGO [06]          CODIGO [07]                                              "
	aL[57]:="----------    -------------------- -------------------- -------------------- -------------------- -------------------- -------------------- --------------------"
	aL[58]:="    ##        #################### #################### #################### #################### #################### #################### ####################"
	aL[59]:=STR0040 //"  ESTADO           CODIGO [09]          CODIGO [10]          CODIGO [11]          CODIGO [12]          CODIGO [13]          CODIGO [14]          CODIGO [15]          CODIGO [16]          CODIGO [17]    "
	aL[60]:="----------    -------------------- -------------------- -------------------- -------------------- -------------------- -------------------- -------------------- -------------------- --------------------"
	aL[61]:="    ##        #################### #################### #################### #################### #################### #################### #################### #################### ####################"
	aL[62]:=STR0041 //"   TOTAL      #################### #################### #################### #################### #################### #################### #################### #################### ####################"
	aL[63]:=STR0042 //"   TOTAL      #################### #################### #################### #################### #################### #################### ####################"
	aL[64]:="----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[65]:="----------------------------------------------------------------------------------------------------------------------------------------------------------------"
	aL[66]:=STR0060 
	aL[67]:=STR0061 
EndIf
//            0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x0123456789x
//                       1          2          3          4          5          6          7          8          9          10         11         12         130        140        150        160        170        180        190

Return (aL)
/*/                                                                                

эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбддддддбддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё R925CriaTemp ЁAutor Ё Juan Jose Pereira    ЁDataЁ 17/04/97 Ё╠╠
╠╠цддддддддддеддддддддддддддаддддддаддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Cria arquivo temporario para armazenar dados de conferenciaЁ╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function R925CriaTemp()
Local cAlias	:= Alias()
Local aCampos	:= Array(10)

aCampos[1]:={"ENT_SAI"	,"C",01,0}   					// [E]ntradas / [S]Saidas
aCampos[3]:={"SERIE"	,"C",03,0}						// Serie
aCampos[2]:={"NOTA"		,"C",TamSX3("F2_DOC")[1],0}	// Numero da Nota
aCampos[4]:={"CLIFOR"	,"C",TamSX3("F3_CLIEFOR")[1],0}// Cliente / Fornecedor
aCampos[5]:={"LOJA"		,"C",TamSX3("F3_LOJA")[1],0}	// Loja
aCampos[6]:={"MUNICIPIO","C",26,0} 					// Municipio
aCampos[7]:={"CODIGO"	,"C",02,0}						// Codigo da Dipam
aCampos[8]:={"VALOR"	,"N",18,2}						// Valor da Nota
aCampos[9]:={"TIPO"		,"C",01,0}						// Tipo da NF
aCampos[10]:={"ESTADO"	,"C",02,0}						// Estado

cArqTemp		:= CriaTrab(aCampos)
dbUseArea(.T.,,cArqTemp,cArqTemp,.T.,.F.)
cChave			:= "ENT_SAI+MUNICIPIO+ESTADO+CLIFOR+LOJA+SERIE+NOTA+CODIGO"
IndRegua(cArqTemp,cArqTemp,cChave,,,STR0036) //"Indexando arq.conferencia"
dbSetOrder(1)

dbSelectArea(cAlias)

Return (cArqTemp)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбддддддбддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё R925GravaConfЁAutor Ё Juan Jose Pereira    ЁDataЁ 17/04/97 Ё╠╠
╠╠цддддддддддеддддддддддддддаддддддаддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Grava registro no arquivo de conferencia                   Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function R925GravaConf(cArqTemp,cTipo,cNota,cSerie,cCliFor,cLoja,cMunicipio,cCodigo,nValor,cTpNF,cEstado)

Local cAlias	:=	Alias()

If lImpLista
	dbSelectArea(cArqTemp)
	dbSetOrder(1)

	dbSeek(cTipo+cMunicipio+cCliFor+cLoja+cSerie+cNota+cCodigo)
	If !Found()
		RecLock(cArqTemp,.T.)
		(cArqTemp)->VALOR		:= nValor
		(cArqTemp)->ENT_SAI 	:= cTipo
		(cArqTemp)->TIPO		:= cTpNF	//Tipo da NF: N-Normal, D-Devolucao, B-Beneficiamento
		(cArqTemp)->SERIE		:= cSerie
		(cArqTemp)->NOTA		:= cNota
		(cArqTemp)->CLIFOR		:= cCliFor
		(cArqTemp)->LOJA		:= cLoja
		(cArqTemp)->MUNICIPIO	:= cMunicipio
		(cArqTemp)->CODIGO 		:= cCodigo
		(cArqTemp)->ESTADO 		:= cEstado		
	Else
		RecLock(cArqTemp,.F.)
		(cArqTemp)->VALOR += nValor
	Endif	
	MsUnlock()                     

Endif

dbSelectArea(cAlias)

Return (NIL)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддддбддддддбддддддддддддддддддддддбддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё R925ImpConf  ЁAutor Ё Juan Jose Pereira    ЁDataЁ 17/04/97 Ё╠╠
╠╠цддддддддддеддддддддддддддаддддддаддддддддддддддддддддддаддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Imprime listagem de conferencia                            Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function R925ImpConf(lEnd,cArqTemp,nLin)

Local aDados
Local cCliFor
Local cLoja
Local cAlias	:=	Alias()
Local cCliAnt	:=	""
Local cLojAnt	:=	""
Local cNotaAnt	:=	""
Local cMovAnt	:=	""
Local cTES 		:= 	""
Local cTESAnt 	:= 	""
nLin			:=	80

If lImpLista
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime arquivo temporario                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea(cArqTemp)
	dbGotop()
	SetRegua(LastRec())
	cMovAnt	:=	ENT_SAI
	While !eof()
		IncRegua()
		If Interrupcao(@lEnd)
			Exit
		Endif
		
		If nLin>55.or.!(cMovAnt==ENT_SAI)
			nLin	:=	nLin+1
			If nLin>55
				R925Cab(aL,@nLin)
			Endif
			If ENT_SAI=="S"
				FmtLin(,{aL[46],aL[47]},,,@nLin)
			Else
				FmtLin(,{aL[46],aL[48]},,,@nLin)
			Endif
			FmtLin(,{aL[49],aL[50],aL[51]},,,@nLin)
			cMovAnt	:=	ENT_SAI
		Endif
		
		cCliFor	:=	CLIFOR
		cLoja	:=	LOJA
		cTES	:=	ENT_SAI
		
		aDados	:=	Array(8)
		If !cCliFor+cLoja+cTES==cCliAnt+cLojAnt+cTESAnt
			aDados[1]	:=	cCliFor+" - "+cLoja
			If ENT_SAI=="S"
				If IntTms()
					//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
				    //Ё Integracao com TMS                                 Ё
				    //юдддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !(PosTms (NOTA, SERIE))
					    If (cArqTemp)->TIPO $ "DB"	//Devolucao ou Beneficiamento
							SA2->(dbSeek(F3Filial("SA2")+cCliFor+cLoja))
						Else
							SA1->(dbSeek(F3Filial("SA1")+cCliFor+cLoja))
						Endif
					EndIf
				Else
				    If (cArqTemp)->TIPO $ "DB"	//Devolucao ou Beneficiamento
						SA2->(dbSeek(F3Filial("SA2")+cCliFor+cLoja))
					Else
						SA1->(dbSeek(F3Filial("SA1")+cCliFor+cLoja))
					Endif
				EndIf
				
				SA1->(dbSeek(F3Filial("SA1")+cCliFor+cLoja))				
				aDados[2]	:=	IIf((cArqTemp)->TIPO$"DB",SA2->A2_NOME,SA1->A1_NOME)
			Else
			    If (cArqTemp)->TIPO $ "DB"	//Devolucao ou Beneficiamento
					SA1->(dbSeek(F3Filial("SA1")+cCliFor+cLoja))
				Else
					SA2->(dbSeek(F3Filial("SA2")+cCliFor+cLoja))
				Endif
				aDados[2]	:=	IIf((cArqTemp)->TIPO$"DB",SA1->A1_NOME,SA2->A2_NOME)
			Endif
			aDados[2] := PadR (aDados[2], 43)
			
			aDados[3] := MUNICIPIO
			aDados[4] := ESTADO
			cCliAnt	:=	cCliFor
			cTESAnt :=	cTES
			cLojAnt :=	cLoja
		Endif
		If !NOTA+SERIE==cNotaAnt
			aDados[5]	:=	NOTA
			aDados[6]	:=	SERIE
		Endif
		aDados[7]	:=	CODIGO
		aDados[8]	:=	VALOR
		
		FmtLin(aDados,aL[52],cPict,,@nLin)
		
		dbSkip()
	End
	nLin:=nLin+1
	FmtLin(,aL[53],cPict,,@nLin)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Apaga Arquivo temporario                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	dbSelectArea(cArqTemp)
	dbCloseArea()
	Ferase(cArqTemp+GetDBExtension())
	Ferase(cArqTemp+OrdBagExt())
Endif

dbSelectArea(cAlias)

Return (lEnd)
