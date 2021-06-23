#Include "Protheus.ch"   

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �ADFIN063P   �Autor  �Fernando Sigoli   � Data �  03/08/19   ���
//�������������������������������������������������������������������������͹��
//���Desc.     �Cadastro de CEP                                             ���
//�������������������������������������������������������������������������͹��
//���Uso       � Adoro                                                      ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������

User Function ADFIN063P()                                                   
 
	Private cCadastro 	:= "Cadasto CEP"
	Private aRotina 	:= {{"Pesquisar","",0,1} ,;
							{"Visualizar","AxVisual",0,2} ,;
							{"Incluir","AxInclui",0,3}    ,;
							{"Alterar","AxAltera",0,4}} 
						

	//���������������������������������������������������������������������Ŀ
	//� Monta array com os campos para o Browse                             �
	//�����������������������������������������������������������������������

	Private aCampos := {{"CEP"		 , "JC2_CEP"	, "C" ,08,00,""} ,;
						{"Logradouro", "JC2_LOGRAD"	, "C" ,66,00,""} ,; 
						{"Bairro"    , "JC2_BAIRRO"	, "C" ,50,00,""} ,; 
						{"Cidade"	 , "JC2_CODCID" , "C" ,05,00,""} ,;
						{"Descricao" , "JC2_CIDADE" , "C" ,40,00,""} ,;
						{"Estado"	 , "JC2_ESTADO" , "C" ,02,00,""}} 
						

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "JC2"  

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de CEP')

	// VERIFICA SE AS TABELAS EXISTE, CASO NAO AS CRIA.
	ChKFile("JC2")

	DbSelectArea("JC2")
	DbSetOrder(1)

	DbSelectArea(cString)
	MBrowse( 6,1,22,75,cString,aCampos,)

Return    
