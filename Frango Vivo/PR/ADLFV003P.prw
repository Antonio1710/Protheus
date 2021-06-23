#include "rwmake.ch"  
#include "topconn.ch"
#include 'totvs.ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  ADLFV003P � Autor � Fernando Sigoli     � Data �  31/03/17   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Regiao de Integra��o                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ADLFV003P()
	
Private cCadastro := "Cadastro Regiao de Integra��o"

Private aRotina := { {"Pesquisar","",0,1} ,;
					 {"Visualizar","AxVisual",0,2} ,;
		             {"Incluir","AxInclui",0,3} ,;
		             {"Alterar","AxAltera",0,4} ,;
		             {"Excluir","U_AxDeleta",0,5} } 
		             

Private aCampos := {{"Codigo","ZF2_REGNUM"		,"C",03,00,""},;
                    {"Descri��o","ZF2_REGDES"	,"C",10,00,""}} 


Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "ZF2"  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Regiao de Integra��o')

// Verifica se a tabela existe, caso nao as cria.
ChKFile("ZF2")

dbSelectArea("ZF2")
dbSetOrder(1)

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,aCampos,)

Return   

//----------========= Valida��o de exclus�o. =========----------       					
User Function AxDeleta()

	Local cCodReg := Alltrim(cValToChar(ZF2->ZF2_REGNUM))
	Local cRegiao := Alltrim(ZF2->ZF2_REGNUM)

	U_ADINF009P('ADLFV003P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Regiao de Integra��o')

	DbSelectArea("ZF3")
	ZF3->(DbSetOrder(3))
	ZF3->(DbGoTop())
	If ZF3->(DbSeek(xFilial("ZF3")+cCodReg))      
		MsgStop("Este registro n�o pode ser exclu�do, pois est� vinculado a cadastro(s) de Granja(s).")
	Else 
	 
		AxDeleta("ZF2",ZF2->(Recno()),5)
	 	
	 	//-----------------------|
    	//log de registro        |
    	//-----------------------| 
	   	dbSelectArea("ZBE")
	   	RecLock("ZBE",.T.)                          
	   	Replace ZBE_FILIAL    WITH xFilial("ZBE")
	   	Replace ZBE_DATA      WITH dDataBase
	   	Replace ZBE_HORA      WITH TIME()
	   	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
	   	Replace ZBE_LOG       WITH ("EXCLUIDO: "+cCodReg+" REGIAO: "+cRegiao)  
	   	Replace ZBE_MODULO    WITH "FRANGOVIVO"
	  	Replace ZBE_ROTINA    WITH "ADLFV003P" 
	
	EndIf

	DbCloseArea("ZF3")

Return Nil                                                                                                                                