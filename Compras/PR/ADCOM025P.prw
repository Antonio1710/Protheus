#Include 'protheus.ch'
#Include "RwMake.ch"

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �MA103BUT  �Autor  �WILLIAM COSTA       � Data �16/08/2017   ���
//�������������������������������������������������������������������������͹��
//���Desc.     �O Ponto de Entrada MA103BUTm chamado a partir do codigo     ���
//���          �fonte MATA103.PRW, permite ao usu�rio adiciona op��es na    ���
//���          �barra de menus EnchoiceBar                                  ���
//�������������������������������������������������������������������������͹��
//���Uso       � SIGACOM - DOCUMENTO DE ENTRADA                             ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

//User Function MA103BUT() 
//Funcao alterada de nome (Central XML) - Central fara a chamada desse P.E.
User Function MX103BUT()

	Local aButtons := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//chamado 036682 em 16/08/2017 William Costa
	aAdd( aButtons, { "Responsavel", { || U_RespDocEntrada() }, "Responsavel"})
	//chamado 036682 em 16/08/2017 William Costa
	
	
Return (aButtons) 