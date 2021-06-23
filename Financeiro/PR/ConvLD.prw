#INCLUDE 'RWMAKE.CH'
/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
��� Programa � CONVLD() � Autor � Flavio Novaes      � Data � 19/10/2003 ���
������������������������������������������������������������������������͹��
��� Descricao� Rotina para Conversao da Representacao Numerica do Codigo ���
���          � de Barras (Linha Digitavel (LD)) em Codigo de Barra (CB). ���
���          � Para utilizacao dessa rotina deve-se criar um gatilho para���
���          � o campo E2_CODBAR, Conta Dominio: E2_CODBAR, Tipo: Prima- ���
���          � rio, Regra: EXECBLOCK('CONVLD',.T.), Posiciona: Nao.      ���
���          � Utilize tambem a Validacao do Usuario para o Cpo.E2_CODBAR���
���          � EXECBLOCK('CODBAR',.T.) para Validar a LD ou o CB.        ���
������������������������������������������������������������������������͹��
��� Uso      � CNAB a Pagar do Banco ITAU (SISPAG.PAG) Posicoes 30 a 43. ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
USER FUNCTION ConvLD()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para Conversao da Representacao Numerica do Codigo de Barras (Linha Digitavel (LD)) em Codigo de Barra (CB).')

SETPRVT('_cStr')
_cStr := LTRIM(RTRIM(M->E2_CODBAR))
IF VALTYPE(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
	// Se o Campo esta em Branco nao Converte nada.
	_cStr := ''
ELSE
	// Se o Tamanho do String for menor que 44, completa com zeros ate 47 digitos. Isso e
	// necessario para Bloquetos que NAO tem o vencimento e/ou o valor informados na LD.
	_cStr := IF(LEN(_cStr)<44,_cStr+REPL('0',47-LEN(_cStr)),_cStr)
ENDIF
DO CASE
CASE LEN(_cStr) == 47
	_cStr := SUBSTR(_cStr,1,4)+SUBSTR(_cStr,33,15)+SUBSTR(_cStr,5,5)+SUBSTR(_cStr,11,10)+SUBSTR(_cStr,22,10)
CASE LEN(_cStr) == 48
	IF U_FCHECA()
		_cStr := SUBSTR(_cStr,1,11)+SUBSTR(_cStr,13,11)+SUBSTR(_cStr,25,11)+SUBSTR(_cStr,37,11)
	ELSE
		_cStr := _cStr+SPACE(48-LEN(_cStr))
	ENDIF
OTHERWISE
	_cStr := _cStr+SPACE(48-LEN(_cStr))
ENDCASE
RETURN(_cStr)
/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
��� Programa � FCheca() � Autor � Flavio Novaes      � Data � 03/01/2007 ���
������������������������������������������������������������������������͹��
��� Descricao� Rotina para checar se a Linha Digitavel/Codigo de Barras e���
���          � Valido.                                                   ���
������������������������������������������������������������������������͹��
��� Uso      � CNAB a Pagar do Banco ITAU (SISPAG.PAG) Posicoes 30 a 43. ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
USER FUNCTION FCheca()

SETPRVT('cStr,lRet,cTipo,nConta,nMult,nVal,nDV,cCampo,i,nMod,nDVCalc')

U_ADINF009P('CONVLD' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para Conversao da Representacao Numerica do Codigo de Barras (Linha Digitavel (LD)) em Codigo de Barra (CB).')

// Retorna .T. se o Campo estiver em Branco.
IF VALTYPE(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
	RETURN(.T.)
ENDIF
cStr := LTRIM(RTRIM(M->E2_CODBAR))
// Se o Tamanho do String for 45 ou 46 est� errado! Retornar� .F.
lRet := IF(LEN(cStr)==45 .OR. LEN(cStr)==46,.F.,.T.)
// Se o Tamanho do String for menor que 44, completa com zeros at� 47 d�gitos. Isso �
// necess�rio para Bloquetos que N�O t�m o vencimento e/ou o valor informados na LD.
cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
// Verifica se a LD � de (B)loquetos ou (C)oncession�rias/IPTU. Se for CB retorna (I)ndefinido.
cTipo := IF(LEN(cStr)==47,"B",IF(LEN(cStr)==48,"C","I"))
// Verifica se todos os d�gitos s�o num�rios.
FOR i := LEN(cStr) TO 1 STEP -1
	lRet := IF(SUBSTR(cStr,i,1) $ "0123456789",lRet,.F.)
NEXT
IF LEN(cStr) == 47 .AND. lRet
	// Consiste os tr�s DV�s de Bloquetos pelo M�dulo 10.
	nConta  := 1
	WHILE nConta <= 3
		nMult  := 2
		nVal   := 0
		nDV    := VAL(SUBSTR(cStr,IF(nConta==1,10,IF(nConta==2,21,32)),1))
		cCampo := SUBSTR(cStr,IF(nConta==1,1,IF(nConta==2,11,22)),IF(nConta==1,9,10))
		FOR i := LEN(cCampo) TO 1 STEP -1
			nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
			nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
			nMult := IF(nMult==2,1,2)
		NEXT
		nDVCalc := 10-MOD(nVal,10)
		// Se o DV Calculado for 10 � assumido 0 (Zero).
		nDVCalc := IF(nDVCalc==10,0,nDVCalc)
		lRet    := IF(lRet,(nDVCalc==nDV),.F.)
		nConta  := nConta + 1			
	ENDDO
	// Se os DV�s foram consistidos com sucesso (lRet=.T.), converte o n�mero para CB para consistir o DVG. 
  	cStr := IF(lRet,SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10),cStr)
ENDIF
IF LEN(cStr) == 48 .AND. lRet
	// Consiste os quatro DV�s de T�tulos de Concession�rias de Servi�o P�blico e IPTU pelo M�dulo 10.
	nConta  := 1
	WHILE nConta <= 4
		nMult  := 2
		nVal   := 0
		nDV    := VAL(SUBSTR(cStr,IF(nConta==1,12,IF(nConta==2,24,IF(nConta==3,36,48))),1))
		cCampo := SUBSTR(cStr,IF(nConta==1,1,IF(nConta==2,13,IF(nConta==3,25,37))),11)
		FOR i := 11 TO 1 STEP -1
			nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
			nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
			nMult := IF(nMult==2,1,2)
		NEXT
		nDVCalc := 10-MOD(nVal,10)
		// Se o DV Calculado for 10 � assumido 0 (Zero).
		nDVCalc := IF(nDVCalc==10,0,nDVCalc)
		lRet    := IF(lRet,(nDVCalc==nDV),.F.)
		nConta  := nConta + 1			
	ENDDO
	// Se os DV�s foram consistidos com sucesso (lRet=.T.), converte o n�mero para CB para consistir o DVG. 
  	cStr := IF(lRet,SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11),cStr)
ENDIF
IF LEN(cStr) == 44 .AND. lRet
	IF cTipo $ "BI"
		// Consiste o DVG do CB de Bloquetos pelo M�dulo 11.
		nMult  := 2
		nVal   := 0
		nDV    := VAL(SUBSTR(cStr,5,1))
		cCampo := SUBSTR(cStr,1,4)+SUBSTR(cStr,6,39)
		FOR i := 43 TO 1 STEP -1
			nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
			nVal  := nVal + nMod
			nMult := IF(nMult==9,2,nMult+1)
		NEXT
		nDVCalc := 11-MOD(nVal,11)
		// Se o DV Calculado for 0,10 ou 11 � assumido 1 (Um).
		nDVCalc := IF(nDVCalc==0 .OR. nDVCalc==10 .OR. nDVCalc==11,1,nDVCalc)		
		lRet    := IF(lRet,(nDVCalc==nDV),.F.)
		// Se o Tipo � (I)ndefinido E o DVG N�O foi consistido com sucesso (lRet=.F.), tentar�
		// consistir como CB de T�tulo de Concession�rias/IPTU no IF abaixo.  
	ENDIF
	IF cTipo == "C" .OR. (cTipo == "I" .AND. !lRet)
		// Consiste o DVG do CB de T�tulos de Concession�rias pelo M�dulo 10.
		lRet   := .T.
		nMult  := 2
		nVal   := 0
		nDV    := VAL(SUBSTR(cStr,4,1))
		cCampo := SUBSTR(cStr,1,3)+SUBSTR(cStr,5,40)
		FOR i := 43 TO 1 STEP -1
			nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
			nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
			nMult := IF(nMult==2,1,2)
		NEXT
		nDVCalc := 10-MOD(nVal,10)
		// Se o DV Calculado for 10 � assumido 0 (Zero).
		nDVCalc := IF(nDVCalc==10,0,nDVCalc)
		lRet    := IF(lRet,(nDVCalc==nDV),.F.)
	ENDIF
ENDIF
RETURN(lRet)