#Include "Protheus.ch"  

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �GP010VALPE� Autor � William Costa      � Data �  21/09/2017 ���
//�������������������������������������������������������������������������͹��
//���Descricao � Ponto de Entrada para checar os dados de inclus�o          ���
//���          � /altera��o de funcion�rios.                                ���
//�������������������������������������������������������������������������͹��
//���Uso       � Chamado 033868 / SIGAGPE                                   ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

User Function GP010VALPE() 

	Local aArea	:= GetArea()
	Local lRet  := .T.
	
	IF FUNNAME()      == 'GPEA010' .AND. ;
	   CEMPANT        == '01'      .AND. ;
	   XFILIAL("SRA") == '02'      .AND. ;
	   M->RA_XCREDEN  == 0
	   
	   MsgStop("OL� " + Alltrim(cUserName) + ", necess�rio informar a Credencial do Funcion�rio aba Controle de Ponto, favor verificar!!!", "GP010VALPE - Verifica Credencial")
	   
	   lRet  := .F.
	   
	ENDIF  	   
	
	IF FUNNAME()      == 'GPEA010' .AND. ;
	   CEMPANT        == '02'      .AND. ;
	   XFILIAL("SRA") == '01'      .AND. ;
	   M->RA_XCREDEN  == 0
	   
	   MsgStop("OL� " + Alltrim(cUserName) + ", necess�rio informar a Credencial do Funcion�rio aba Controle de Ponto, favor verificar!!!", "GP010VALPE - Verifica Credencial")
	   
	   lRet  := .F.
	   
	ENDIF  	   
	 
	//Restaura �reas de trabalho.
	RestArea(aArea)

RETURN(lRet)