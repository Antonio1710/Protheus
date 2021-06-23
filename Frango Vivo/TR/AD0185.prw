#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AD0185    � Autor � DANIEL             � Data �  03/07/06   ���
�������������������������������������������������������������������������͹��
���Descricao � MANUTENCAO DAS APANAHAS                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AD0185     

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MANUTENCAO DAS APANAHAS')


	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	
	Private cString := "ZV5"
	
	dbSelectArea("ZV5")
	dbSetOrder(1)
	
	AxCadastro(cString,"APANHA","U_DelFV5()","U_AltFV5()")

Return                                            

USER FUNCTION AltFV5()

	Local _lRet:=.F.
	Local _aArea:=GetArea()  
	Local _cChave:=xFilial("ZV1")+ZV5->ZV5_NUMOC	                   
	Local _nApnNew:=M->ZV5_QTDAVE	
	Local _nApnOld:=ZV5->ZV5_QTDAVE		
	Local _nDif:=ABS(_nApnNew-_nApnOld)
	Local _nApn:=_nDif
	
	U_ADINF009P('AD0185' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MANUTENCAO DAS APANAHAS')
	
//���������������������������Ŀ
//�Verifica o tipo de operacao�
//�����������������������������
	if _nApnNew<_nApnOld 
		_nApn:=(-1)*_nDif  		
	EndIf		
	
//������������������Ŀ
//�Consiste Alteracao�
//��������������������
	DbSelectArea("ZV1")
	DbSetOrder(3)
	If DbSeek(_cChave,.T.)
  		RecLock("ZV1",.F.)
  		REPLACE ZV1_QTDAPN WITH ZV1_QTDAPN+_nApn
  		MsUnlock()      
  		_lRet:=.T.
	Else                                 
		RestArea(_aArea)
		MsgInfo("Ordem "+ZV5->ZV5_NUMOC+" nao encontrada","Inconsistente")
		_lRet:=.F.
	EndIf		
	RestArea(_aArea)
Return(_lRet)


//���������������������Ŀ
//�Validacao da Exclusao�
//�����������������������
USER FUNCTION DelFV5()

	Local _lRet:=.F.
	Local _aArea:=GetArea()                     
	Local _cChave:=xFilial("ZV5")+ZV5->ZV5_NUMOC	
	Local _nApn :=ZV5_QTDAVE

	U_ADINF009P('AD0185' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MANUTENCAO DAS APANAHAS')
					  

//�����������������Ŀ
//�Consiste Exclusao�
//�������������������
	DbSelectArea("ZV1")
	DbSetOrder(3)
	If DbSeek(_cChave,.T.)
  		RecLock("ZV1",.F.)
  		REPLACE ZV1_QTDAPN WITH ZV1_QTDAPN-_nApn
  		MsUnlock()      
  		_lRet:=.T.
	Else                                 
		RestArea(_aArea)
		MsgInfo("Ordem "+ZV5->ZV5_NUMOC+" nao encontrada","Inconsistente")
		_lRet:=.T.
	EndIf		
	RestArea(_aArea)
RETURN(_lRet)
