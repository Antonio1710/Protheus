#INCLUDE 'RWMAKE.CH'
/*
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
��� Programa � CODBAR   � Autor � Flavio Novaes      � Data � 19/10/2003 ���
������������������������������������������������������������������������͹��
��� Descricao� Essa rotina foi desenvolvida com base no Manual do B.Itau ���
���          � e na Rotina CODBARVL de Vicente Sementilli de 26/02/1997. ���
���          � Rotina para Validacao de Codigo de Barras (CB) e Represen-���
���          � tacao Numerica do Codigo de Barras (Linha Digitavel (CB)).���
���          � A LD de Bloquetos possui tres Digitos Verificadores (DV)  ���
���          � que sao consistidos pelo Modulo 10, alem do Digito Verifi-���
���          � cador Geral (DVG) que e consistido pelo Modulo 11. Essa LD���
���          � tem 47 caracteres.                                        ���
���          � A LD de Titulos de Concessionarias de Servico Publico e   ���
���          � IPTU possui quatro Digitos Verificadores (DV) que sao con-���
���          � sistidos pelo Modulo 10. Essa LD tem 48 caracteres.       ���
���          � O CB de Bloquetos e de Titulos de Concessionarias de Ser- ���
���          � vico Publico e IPTU possui apenas o Digito Verificador Ge-���
���          � ral (DVG), sendo que a unica diferenca e que o CB de Blo- ���
���          � quetos e consistido pelo Modulo 11 enquanto que o CB de   ���
���          � Titulos de Concessionarias e consistido pelo Modulo 10.   ���
���          � Todos os CB's tem 44 caracteres.                          ���
���          � Para utilizacao dessa rotina, deve-se criar o campo       ���
���          � E2_CODBAR, Tipo Caracter, Tamanho 48 e colocar na valida- ���
���          � cao do usuario: EXECBLOCK('CODBAR',.T.)                   ���
���          � Utilize tambem o gatilho com a rotina CONVLD() para con-  ���
���          � verter a LD em CB.                                        ���
������������������������������������������������������������������������͹��
��� Uso      � CNAB a Pagar do Banco ITAU (SISPAG.PAG) Posicoes 30 a 43. ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
*/
USER FUNCTION CodBar()     

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para Validacao de Codigo de Barras (CB)')

SETPRVT('cStr,lRet,cTipo,nConta,nMult,nVal,nDV,cCampo,i,nMod,nDVCalc')
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
IF !lRet
	MsgInfo('Esta Linha Digit�vel / C�digo de Barras n�o � valido(a), favor corrigir!','Aten��o !')
	lRet := .T.
ENDIF
RETURN(lRet)