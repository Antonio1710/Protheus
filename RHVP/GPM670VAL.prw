#INCLUDE 'PROTHEUS.CH'
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � GPM670VAL� Autor �Adriana Oliveira       � Data � 22/08/18 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada do GPM670VAL (Integracao Financeiro)      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para ADORO - chamado 043309                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function GPM670VAL()

Local lRet 	:= .T.                                 
Local cFunc 	:= ""

If RC1->RC1_CODTIT $ "901 025 "  //Se titulos de Pagamento Autonomo ou Rescisao verifica filial + matricula               
	If .not. Empty(RC1->RC1_FILTIT) .and. .not. Empty(RC1->RC1_MAT) 
		cFunc := posicione("SRA",1,RC1->RC1_FILTIT+RC1->RC1_MAT,"RA_NOME") //Existe Funcionario?
		If	.not. Empty(cFunc)
			lRet := .T.   //Se encontrou, gera o titulo
		Else   
	   		MsgInfo("Titulo 901 ou 025 nao sera Incluido, Filial+Matricula (RC1) nao encontrados (SRA)","GPM670VAL")
			lRet := .F.   //Se nao encontrou, nao gera o titulo
		Endif          
	Else
   		MsgInfo("Titulo 901 ou 025 nao sera Incluido, obrigatorio informar Filial+Matricula (RC1)","GPM670VAL")
		lRet := .F.       //Se n�o preencheu filial + matricula, nao gera o titulo 
	Endif
EndIf                     //Demais tipos de titulo, gera 

Return (lRet)