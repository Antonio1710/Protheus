#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"

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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGravaSX1   บAutor  ณPablo Gollan Carreras บ Data ณ10/04/12     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para criar o grupo de perguntas                         บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Nome do grupo de perguntas                          บฑฑ
ฑฑบ          ณExp02[A] : Array com as perguntas (estrutura)                  บฑฑ
ฑฑบ          ณ           01. PERGUNTA                                        บฑฑ
ฑฑบ          ณ           02. TIPO                                            บฑฑ
ฑฑบ          ณ           03. TAM                                             บฑฑ
ฑฑบ          ณ           04. DECIMAL (POSICAO OPCIONAL PODE SER INIBIDA)     บฑฑ
ฑฑบ          ณ           05. OBJETO                                          บฑฑ
ฑฑบ          ณ           06. PS                                              บฑฑ
ฑฑบ          ณ           07. COMBO                                           บฑฑ
ฑฑบ          ณ           08. SXG                                             บฑฑ
ฑฑบ          ณ           09. SX3                                             บฑฑ
ฑฑบ          ณ           10. VALID                                           บฑฑ
ฑฑบ          ณ           11. HELP                                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function GravaSX1(cPerg,aMensHlp)

Local lRet				:= .T.
Local aHelpPor 			:= {}				 									//Mensagem help portugues
Local aHelpEng 			:= {}				 									//Mensagem help ingles
Local aHelpSpa			:= {}													//Mensagem help espanhol
Local ni				:= 0													//Contador
Local cPos				:= ""													//Posicao da pergunta
Local lOk				:= .T.
Local nNumColsMn		:= 10
Local nNumColsMx		:= 11
Local nDesloca			:= 0

PARAMTYPE 0	VAR cPerg		AS Character	DEFAULT ""
PARAMTYPE 1	VAR aMensHlp	AS Array		DEFAULT Array(0)

//U_ADINF009P('PGCXFUNA' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Empty(cPerg) .OR. Empty(aMensHlp)
	Return Nil
Endif
Do Case
	Case Len(aMensHlp[1]) > 10
		nDesloca := 1
	Otherwise
		nDesloca := 0
EndCase
//Validar estrutura do array de perguntas enviado
aEval(aMensHlp,{|x| IIf(Len(x) < nNumColsMn .AND. Len(x) > nNumColsMx,lOk := .F.,.T.)})
If !lOk
	Return !lRet
Endif
For ni := 1 to Len(aMensHlp)
	aHelpSpa := aHelpEng := aHelpPor := U_FrmtHelp(aTail(aMensHlp[ni]))
	cPos := StrZero(ni,2)
	PutSX1(cPerg,;												//Grupo
			cPos,;												//Ordem
			aMensHlp[ni][1],;									//Desc. portugues
			aMensHlp[ni][1],;									//Desc. espanhol
			aMensHlp[ni][1],;									//Desc. ingles
			"mv_ch" + Lower(Soma1(cValToChar(ni - 1),1)),;	//Variavel do item
			aMensHlp[ni][2],;									//Tipo
			aMensHlp[ni][3],;									//Tamanho
			IIf(nDesloca == 0,0,aMensHlp[ni][4]),;			//Decimal
			aMensHlp[ni][5 + nDesloca],;						//Pre-selecao
			aMensHlp[ni][4 + nDesloca],;						//Estilo campo
			aMensHlp[ni][9 + nDesloca],;						//Validacao
			aMensHlp[ni][8 + nDesloca],;						//F3
			aMensHlp[ni][7 + nDesloca],;						//Grupo SXG
			"",;              									//PYME
			"mv_par" + cPos,;									//MV_PAR
			aMensHlp[ni][6 + nDesloca][1],;					//CMB DEF01
			aMensHlp[ni][6 + nDesloca][1],;					//CMB DEF01 SPA
			aMensHlp[ni][6 + nDesloca][1],;					//CMB DEF01 ENG
			"",;												//CONTEUDO PADRAO DA PERGUNTA
			aMensHlp[ni][6 + nDesloca][2],;					//CMB DEF02
			aMensHlp[ni][6 + nDesloca][2],;					//CMB DEF02 SPA
			aMensHlp[ni][6 + nDesloca][2],;					//CMB DEF02 ENG
			aMensHlp[ni][6 + nDesloca][3],;					//CMB DEF03
			aMensHlp[ni][6 + nDesloca][3],;					//CMB DEF03 SPA
			aMensHlp[ni][6 + nDesloca][3],;					//CMB DEF03 ENG			
			aMensHlp[ni][6 + nDesloca][4],;					//CMB DEF04
			aMensHlp[ni][6 + nDesloca][4],;					//CMB DEF04 SPA
			aMensHlp[ni][6 + nDesloca][4],;					//CMB DEF04 ENG			
			aMensHlp[ni][6 + nDesloca][5],;					//CMB DEF05
			aMensHlp[ni][6 + nDesloca][5],;					//CMB DEF05 SPA
			aMensHlp[ni][6 + nDesloca][5],;					//CMB DEF05 ENG
			aHelpPor,;											//HELP DESC POR
			aHelpEng,;											//HELP DESC SPA
			aHelpSpa,;											//HELP DESC ENG
			"")
Next ni

Return Nil

/*                                                  	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFecArTMP  บAutor  ณPablo Gollan Carreras บ Data ณ17/04/12     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para encerrar alias e arquivos temporarios criados a   บฑฑ
ฑฑบ          ณpartir de uma query.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FecArTMP(cAlias,lExTT,cTabTT)

PARAMTYPE 0	VAR cAlias		AS Character				DEFAULT ""
PARAMTYPE 1	VAR lExTT		AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 2	VAR cTabTT		AS Character	OPTIONAL	DEFAULT ""

If Empty(cAlias)
	Return Nil
Endif
If Select(cAlias) > 0
	dbSelectArea(cAlias)
	dbCloseArea()
	If File(cAlias + OrdBagExt())
		fErase(cAlias + OrdBagExt())
	Endif
	If File(cAlias + GetDbExtension())
		fErase(cAlias + GetDbExtension())
	Endif
Endif
If lExTT .AND. !Empty(cTabTT) .AND. FindFunction("U_TTExcluir")
	If MsFile(cTabTT,,__cRDD)
		U_TTExcluir(cTabTT)
	Endif
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออออออปฑฑ
ฑฑบPrograma  ณApRedFWL  บAutor  ณPablo Gollan Carreras บ Data ณ03/02/2012       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออออออนฑฑ
ฑฑบDesc.     ณDefine se deve ser aplicado reducao de tamanho para a classe      บฑฑ
ฑฑบ          ณFWLayer nas janelas, em interface MDI e/ou com tema TEMAP10.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[A] : Considerar a versao do FWLayer                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ApRedFWL(lConsVer)

Local lRet				:= .F.
Local bCond				:= {|| }

//U_ADINF009P('PGCXFUNA' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

PARAMTYPE 0	VAR lConsVer	AS Logical	OPTIONAL	DEFAULT .F.

If !lConsVer
	bCond := &('{|| (AllTrim(PtGetTheme()) == "MDI" .OR. AllTrim(GetTheme()) == "TEMAP10")}')
Else
	bCond := &('{|| (AllTrim(PtGetTheme()) == "MDI" .OR. AllTrim(GetTheme()) == "TEMAP10") .AND. AllTrim(GetVersao(.F.)) # "11" .AND. ' + ;
		'CtoD(DtoC(GetAPOInfo("FWLAYER.PRW")[4])) < CtoD("1/1/2011")}')
Endif
If Eval(bCond)
	lRet := .T.
Endif

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

User Function DefTamObj(aTamObj,nTOP,nLEFT,nWIDTH,nBOTTOM,lAcVlZr)

PARAMTYPE 0	VAR aTamObj		AS Array		OPTIONAL	DEFAULT Array(4)
PARAMTYPE 1	VAR nTOP		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 2	VAR nLEFT		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 3	VAR nWIDTH		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 4	VAR nBOTTOM		AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 5	VAR	lAcVlZr		AS Logical		OPTIONAL	DEFAULT .F.

//U_ADINF009P('PGCXFUNA' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

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

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFrmtHelp   บAutor  ณPablo Gollan Carreras บ Data ณ03/02/12     บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para formatar uma string em uma array respeitando       บฑฑ
ฑฑบ          ณum tamanho maximo para visualizacao de help de campo           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Texto do help                                       บฑฑ
ฑฑบ          ณExp02[N} : Tamanho maximo do texto por linha                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FrmtHelp(cTexto,nLimite)

Local aRet			:= {}
Local ni			:= 0
Local nTam			:= 0
Local nCont			:= 1
Local nPos			:= 0
Local cVogais		:= "AEIOUมษอำฺยสฮิÛภศฬาูรีฤหฯึÜ"
Local cConsoa		:= "BCDFGHJKLMNPQRSTVXWYZวั"
Local cPontua		:= "(){}[]:.,;"
Local cNum			:= "0123456789"
Local cEspaco		:= " " + CRLF
Local lPontua 		:= .F.
Local lUltVog		:= .F.
Local lEncVoc		:= .F.
Local lEncCon		:= .F.
Local lTritongo 	:= .F.
Local lEspaco		:= .F.
Local lConEsp		:= .F.
Local lPalDuas		:= .F.
Local lPalTres		:= .F.

//U_ADINF009P('PGCXFUNA' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

PARAMTYPE 0	VAR cTexto		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1	VAR	nLimite		AS Numeric		OPTIONAL	DEFAULT nTAMSX1H

If Empty(cTexto)
	Return aRet
Endif
cTexto	:= AllTrim(cTexto)
nTam 	:= Len(cTexto)
aRet	:= Array(1)
nPos	:= Len(aRet)
If nTam > nLimite
	aRet[nPos] := ""
	For ni := 1 to nTam 
		If ni > 1
			lPontua := Upper(Substr(cTexto,ni,1)) $ (cPontua + cNum)
			lUltVog	:= Upper(Right(aRet[nPos],1)) $ cVogais
			lEncVoc	:= Upper(Substr(cTexto,ni,1)) $ cVogais .AND. lUltVog
			lEncCon	:= Upper(Substr(cTexto,ni,1)) $ cConsoa .AND. Upper(Substr(cTexto,ni + 1,1)) $ cConsoa
			If lEncCon
				If Upper(Substr(cTexto,ni + 2,1)) $ "LR"
					lTritongo := .T.
				Else
					lTritongo := .F.
				Endif
			Else
				lTritongo := .F.
			Endif
			lEspaco	:= Upper(Substr(cTexto,ni,1)) $ cEspaco
			lConEsp	:= Upper(Substr(cTexto,ni,1)) $ cConsoa .AND. Upper(Substr(cTexto,ni + 1,1)) $ cEspaco 
			//Palavra duas letras, que nao deve ser quebrada
			If ni > 2
				lPalDuas := Upper(Substr(cTexto,ni - 2,1)) $ cEspaco .AND. Upper(Substr(cTexto,ni,1)) $ (cConsoa + cVogais) .AND. ;
					Upper(Substr(cTexto,ni + 2,1)) $ (cEspaco + cPontua)
			Else
				lPalDuas := .F.
			Endif			
			//Palavra tres letras, que nao deve ser quebrada
			If !lPalDuas .AND. ni > 2
				lPalTres := Upper(Substr(cTexto,ni - 2,1)) $ cEspaco .AND. Upper(Substr(cTexto,ni,1)) $ (cConsoa + cVogais) .AND. ;
					Upper(Substr(cTexto,ni + 1,1)) $ (cConsoa + cVogais) .AND. Upper(Substr(cTexto,ni + 2,1)) $ (cEspaco + cPontua)
			Else
				lPalTres := .F.
			Endif
			If nCont > nLimite .AND. ((!lPontua .AND. lUltVog .AND. !lEncVoc .AND. (!lEncCon .OR. lTritongo) .AND. !lConEsp .AND. !lPalDuas .AND. !lPalTres) .OR. (lEspaco))
				nCont := 0
				//Se nao for o ultimo caracter
				If ni < nTam
					//Se o caracter processado for uma consoante ou vogal e nao for um tritongo inserir o separador
					If Upper(Substr(cTexto,ni,1)) $ (cVogais + cConsoa)
						If lTritongo
							aRet[nPos] += Substr(cTexto,ni,1) + "-"
						Else
							aRet[nPos] += "-"
						Endif
					Endif
				Endif
				aAdd(aRet,"")
				nPos := Len(aRet)
			Else
				//Negar o tritongo, pois nao havera necessidade de quebra e a letra precisa ser adicionada
				lTritongo := .F.
			Endif
		Endif
		If !lTritongo
			aRet[nPos] += Substr(cTexto,ni,1)
		Endif
		nCont++
	Next ni
	For ni := 1 to Len(aRet)
		aRet[ni] := LTrim(aRet[ni])
	Next ni	
Else
	aRet[nPos] := cTexto
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณExTelaMen  บAutor  ณPablo Gollan Carreras บ Data ณ03/02/2012      บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para montar uma tela para apresentacao de mensagem         บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExp01[C] : Titulo da janela                                       บฑฑ
ฑฑบ          ณExp02[C] : Texto a ser apresentado                                บฑฑ
ฑฑบ          ณExp03[C] : Nome da fonte                                          บฑฑ
ฑฑบ          ณExp04[N] : Tamanho da fonte                                       บฑฑ
ฑฑบ          ณExp05[L] : Dar foco no botao fechar                               บฑฑ
ฑฑบ          ณExp06[L] : Dar foco no botao cancelar                             บฑฑ
ฑฑบ          ณExp07[L] : Exibir a combinacao de botoes : OK e Cancelar          บฑฑ
ฑฑบ          ณExp08[C] : Acao a ser executada pelo Timer da rotina (opcional)   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ExTelaMen(cTitulo,cTexto,cFonte,nTamFonte,lFocoFec,lFocoCanc,lOkCanc,cAcaoTimer, nParSeg)

Local lRet				:= .T.
Local aCoord			:= FWGetDialogSize(oMainWnd)
Local aTamObj			:= Array(4)
Local nCoefDif			:= 1
Local cLOGArq			:= ""
Local cTipoArq    		:= "Arquivos Texto (*.TXT) |*.txt|"
Local cAcao				:= "oMemo:SetFocus()"
Local cGET01	
Local cGET02
Local bAcao01			:= {|| }
Local bAcao02			:= {|| }
//Objetos graficos
Local oDlg
Local oEtq01
Local oFont
Local oTimerTE

Private oMemo
Private oBot01
Private oBot02

Default nParSeg			:= 3000

PARAMTYPE 0 VAR cTitulo		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 1 VAR cTexto		AS Character	OPTIONAL	DEFAULT ""
PARAMTYPE 2 VAR cFonte		AS Character	OPTIONAL	DEFAULT "Mono AS"
PARAMTYPE 3 VAR nTamFonte	AS Numeric		OPTIONAL	DEFAULT 0
PARAMTYPE 4	VAR lFocoFec	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 5	VAR lFocoCanc	AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 6	VAR lOkCanc		AS Logical		OPTIONAL	DEFAULT .F.
PARAMTYPE 7	VAR cAcaoTimer	AS Character	OPTIONAL	DEFAULT ""

//U_ADINF009P('PGCXFUNA' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If lFocoFec .OR. lFocoCanc
	cAcao := "oBot02:SetFocus()"
Endif
oFont := tFont():New(cFonte,,IIf(!Empty(nTamFonte),Abs(nTamFonte),8) * -1,.T.)
If FindFunction("U_ApRedFWL") .AND. U_ApRedFWL(.F.)
	nCoefDif := 0.95
Endif
aCoord[3] := aCoord[3] * 0.6
aCoord[4] := aCoord[4] * 0.4
DEFINE MSDIALOG oTela TITLE cTitulo FROM aCoord[1],aCoord[2] To aCoord[3],aCoord[4] PIXEL 

aTamObj[1] := 005
aTamObj[2] := 005
aTamObj[3] := (oTela:nWidth / 2) - aTamObj[2] * 2
aTamObj[4] := ((oTela:nHeight * nCoefDif) / 2) - ((aTamObj[1] * 2) + nDistAPad + nAltBot + aTamObj[1])
oMemo := tMultiGet():New(aTamObj[1],aTamObj[2],{|x| IIf(PCount() > 0,cTexto := x,cTexto)},oTela,aTamObj[3],aTamObj[4],oFont,.T.,,,,.T.,,,{|| .T.},,,.T.,/*bValid*/,,,.F.,.F.)
oMemo:bRClicked := {|| AllwaysTrue()}
If !lOkCanc
	bAcao01	:= {|| cArqLOG := cGetFile(cTipoArq,""),IIf(Empty(cArqLOG),.T.,MemoWrite(cArqLOG,cTexto))} 
	bAcao02	:= {|| oTela:End()}
	cTAG01	:= "Gravar"
	cTAG02	:= "Fechar"
Else
	bAcao01	:= {|| lRet := .T.,oTela:End()}
	bAcao02	:= {|| lRet := .F.,oTela:End()}
	cTAG01	:= "Ok"
	cTAG02	:= "Cancelar"
Endif
aTamObj[1] := ((oMemo:nTop + oMemo:nHeight) / 2) + nDistAPad
aTamObj[2] := 005
aTamObj[3] := ((oTela:nWidth / 2) - ((aTamObj[2] * 2) + nDistAPad)) / 2
aTamObj[4] := nAltBot
oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + cTAG01,oTela,bAcao01,aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
aTamObj[2] := ((oBot01:nLeft + oBot01:nWidth) / 2) + nDistAPad
oBot02 := tButton():New(aTamObj[1],aTamObj[2],cHK + cTAG02,oTela,bAcao02,aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
If !Empty(cAcaoTimer)
	oTimerTE := tTimer():New(nParSeg,&("{|| " + cAcaoTimer + "}"),oTela)
	oTimerTE:Activate() 
Endif

oTela:Activate(,,,.T.,/*valid*/,,&("{|| " + cAcao + "}"))

Return lRet
