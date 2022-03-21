#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function nomeFunction
	Manutencao  Tabela ZV1 do Frango Vivo
	@type  Function
	@author Daniel Pitthan Silveira
	@since 11/07/2005
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
/*/
User Function AD0135 ()
                        
	Local _cRet := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������

	Private cCadastro := "Manutencao Frango Vivo"
	//���������������������������������������������������������������������Ŀ
	//� Array (tambem deve ser aRotina sempre) com as definicoes das opcoes �
	//� que apareceram disponiveis para o usuario. Segue o padrao:          �
	//� aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      �
	//�              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      �
	//�              . . .                                                  �
	//�              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      �
	//� Onde: <DESCRICAO> - Descricao da opcao do menu                      �
	//�       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  �
	//�                     duplas e pode ser uma das funcoes pre-definidas �
	//�                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA �
	//�                     e AXDELETA) ou a chamada de um EXECBLOCK.       �
	//�                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-�
	//�                     clarar uma variavel chamada CDELFUNC contendo   �
	//�                     uma expressao logica que define se o usuario po-�
	//�                     dera ou nao excluir o registro, por exemplo:    �
	//�                     cDelFunc := 'ExecBlock("TESTE")'  ou            �
	//�                     cDelFunc := ".T."                               �
	//�                     Note que ao se utilizar chamada de EXECBLOCKs,  �
	//�                     as aspas simples devem estar SEMPRE por fora da �
	//�                     sintaxe.                                        �
	//�       <TIPO>      - Identifica o tipo de rotina que sera executada. �
	//�                     Por exemplo, 1 identifica que sera uma rotina de�
	//�                     pesquisa, portando alteracoes nao podem ser efe-�
	//�                     tuadas. 3 indica que a rotina e de inclusao, por�
	//�                     tanto, a rotina sera chamada continuamente ao   �
	//�                     final do processamento, ate o pressionamento de �
	//�                     <ESC>. Geralmente ao se usar uma chamada de     �
	//�                     EXECBLOCK, usa-se o tipo 4, de alteracao.       �
	//�����������������������������������������������������������������������

	//���������������������������������������������������������������������Ŀ
	//� aRotina padrao. Utilizando a declaracao a seguir, a execucao da     �
	//� MBROWSE sera identica a da AXCADASTRO:                              �
	//�                                                                     �
	//� cDelFunc  := ".T."                                                  �
	//� aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               �
	//�                { "Visualizar"   ,"AxVisual" , 0, 2},;               �
	//�                { "Incluir"      ,"AxInclui" , 0, 3},;               �
	//�                { "Alterar"      ,"AxAltera" , 0, 4},;               �
	//�                { "Excluir"      ,"AxDeleta" , 0, 5} }               �
	//�                                                                     �
	//�����������������������������������������������������������������������

	//������������������������������������������������������������Ŀ
	//�SEMAFORO                                                    �
	//��������������������������������������������������������������

	aCores            := {{"ZV1_STATUS='I'"  	,"BR_AZUL" },;
						{"ZV1_STATUS='R'"  	,"BR_LARANJA"},;
						{"ZV1_STATUS='M'"  	,"BR_MARRON"},;
						{"ZV1_STATUS='G'"  	,"BR_VERDE"},;
						{"ALLTRIM(ZV1_STATUS)=''"  	,"BR_PRETO"}}
						

	//���������������������������������������������������������������������Ŀ
	//� Monta um aRotina proprio                                            �
	//�����������������������������������������������������������������������
	/*
	Private aRotina := {{"Pesquisar"  ,"AxPesqui"    ,0,1},;
						{"Visualizar" ,"AxVisual"    ,0,2},; 
						{"Alterar "   ,'ExecBlock("AltFv1")' ,0,3},;
						{"Excluir"    ,'ExecBlock("DelFv1")' ,0,4},;                         
						{"Mnt Frete"  ,'ExecBlock("MntFrt")' ,0,5},;
						{"Pesagem Manual   " ,'ExecBlock("AD0144")' ,0,6},; 
						{"Guia Cupom       " ,'ExecBlock("AD0145")' ,0,7},;                    
						{"Gerar Frete      " ,'ExecBlocK("AD0153")' ,0,8},;
						{"Ajuste de Pesos  " ,'ExecBlocK("AD0167")' ,0,9},; 
						{"Legenda"           ,'ExecBlock("LgdFV1")' ,0,10}}                  
	*/                     

	// Nova a Rotina chamado 037812 William Costa
	Private aRotina := {{"Pesquisar"  ,"AxPesqui"    ,0,1},;
						{"Mnt Frete"  ,'ExecBlock("MntFrt")' ,0,5},;
						{"Legenda"           ,'ExecBlock("LgdFV1")' ,0,10}}                     

	Private cDelFunc:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "ZV1"        
	/*Criado parametro MV_#BLQFV onde o valor ser� subtraido a database do sistema e comparado com a data do ZV1 para total bloqueio do registro - HC */
	Private dDtCorte :=(dDataBase-GetMV("MV_#BLQFV"))
	Private lControl := .F.
	/**********************************************************************************/
	dbSelectArea("ZV1")
	dbSetOrder(1)

	//���������������������������������������������������������������������Ŀ
	//� Executa a funcao MBROWSE. Sintaxe:                                  �
	//�                                                                     �
	//� mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              �
	//� Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   �
	//�                        exibido. Para seguir o padrao da AXCADASTRO  �
	//�                        use sempre 6,1,22,75 (o que nao impede de    �
	//�                        criar o browse no lugar desejado da tela).   �
	//�                        Obs.: Na versao Windows, o browse sera exibi-�
	//�                        do sempre na janela ativa. Caso nenhuma este-�
	//�                        ja ativa no momento, o browse sera exibido na�
	//�                        janela do proprio SYSTEM.                   �
	//� Alias                - Alias do arquivo a ser "Browseado".          �
	//� aCampos              - Array multidimensional com os campos a serem �
	//�                        exibidos no browse. Se nao informado, os cam-�
	//�                        pos serao obtidos do dicionario de dados.    �
	//�                        E util para o uso com arquivos de trabalho.  �
	//�                        Segue o padrao:                              �
	//�                        aCampos := { {<CAMPO>,<DESCRICAO>},;         �
	//�                                     {<CAMPO>,<DESCRICAO>},;         �
	//�                                     . . .                           �
	//�                                     {<CAMPO>,<DESCRICAO>} }         �
	//�                        Como por exemplo:                            �
	//�                        aCampos := { {"TRB_DATA","Data  "},;         �
	//�                                     {"TRB_COD" ,"Codigo"} }         �
	//� cCampo               - Nome de um campo (entre aspas) que sera usado�
	//�                        como "flag". Se o campo estiver vazio, o re- �
	//�                        gistro ficara de uma cor no browse, senao fi-�
	//�                        cara de outra cor.                           �
	//�����������������������������������������������������������������������

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,2,aCores)

Return()                             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LgdFV1    �Autor  �DANIEL              � Data �  06/21/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �MONTA A LEGENDA PARA O USU�RIO NO MENU                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AD0135()                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function LgdFV1()

U_ADINF009P('AD0135' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')

BrwLegenda(cCadastro,"Valores",{{"BR_AZUL"   	,"PRIMEIRA PESAGEM" },;
								{"BR_LARANJA"	,"SEGUNDA PESAGEM" },;
								{"BR_MARRON"   	,"PESAGEM MANUAL" },;
								{"BR_VERDE"   	,"GERADO FRETE" },;
								{"BR_PRETO"   	,"ORDEM NAO UTILIZADA" }})
Return(.T.)      


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AltFv1    �Autor  �DANIEL              � Data �  06/21/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �FAZ A VALIDACAO PARA ALTERACAO DOS REGISTROS EM ZV1010      ���
���          �VERIFICA O STATUS PARA PERMITIR A ALTERACAO                 ���
�������������������������������������������������������������������������͹��
���Uso       � AD0135()                                                   ���
�������������������������������������������������������������������������͹��
���Manut     �ExecBlock Ante ALTERACAO   PALTFV01                         ���
���          �ExecBlock POS  ALTERACAO   PALTFV02                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function AltFv1()

Local Reg:=Recno()       
Local Opc:=3  

U_ADINF009P('AD0135' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')

/*Incluir variaval com  o campo ZV1_DTABAT */
lControl := fValAlt(ZV1->ZV1_DTABAT)  // Criado em 21/07  -  HC para travar por data os registros
                     
	If  ExistBlock("PALTFV01")
 	     ExecBlock("PALTFV01")
 	EndIf
  &&Chamado 006739 em 11/05/10 e corrigido (forcado return) para nao efetuar nenhuma alteracao.
  &&If lControl .Or. (!EMPTY(ZV1_STATUS=''))
  If lControl .Or. ZV1->ZV1_STATUS=='G'
  	MsgInfo("Guia Processada,Nao posso alterar")
  	return()
  Else                  
    //Abre o AxAltera, alias, Recno e OPC
    //OPC = 1 Vizualiza
    //OPC = 3 Altera com validacao 
  	AxAltera("ZV1",Reg,Opc)	
  EndIf     
 	If  ExistBlock("PALTFV02")
 	     ExecBlock("PALTFV02")
 	EndIf
  
Return()  
          
/************************************************************************/
/* Fun��o para validar alteracoes de registros    */
Static Function fValAlt(dPar)
if dPar < dDtCorte
   lControl := .T.
Else
   lControl := .F.
Endif
Return(lControl)                                   
/************************************************************************/

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PALTFV02  �Autor  �Daniel              � Data �  07/24/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada apos Alteracao das Ordens de Carregamento ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AD0135 - MANUTENCAO FRANGO VIVO							  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER FUNCTION PALTFV02()

//����������������������������������������������������Ŀ
//�Retorno                                             �
//������������������������������������������������������
Local _lRet:=.F.
Local _aArea:=GetArea()
//�����������������������������������������������Ŀ
//�Variaves de atualizacao                        �
//�������������������������������������������������
//ZV5
Local ZV1NUMOC	:=ZV1_NUMOC
Local ZV1QTDAPN :=ZV1_QTDAPN
Local ZV1DTAREA :=ZV1_DTAREA
//ZV2
/*Local ZV11PESO :=ZV1->ZV1_1PESO
Local ZV12PESO :=ZV1->ZV1_2PESO 
Local ZV1GUIA  :=ZV1->ZV1_GUIAPE
*/ 

U_ADINF009P('AD0135' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')

//�����������������������������������������������Ŀ
//�PROCURO EM ZV5 A QTD DE APN, SE ENCONTRO ALTERO�
//�SE NAO ENCONTRO CRIO REC EM ZV5                �
//�������������������������������������������������
IF  ZV1QTDAPN <>0
	DbSelectArea("ZV5")
	DbGoTop()
	DbSetOrder(1)
	If DbSeek(xFilial("ZV5")+ZV1NUMOC,.T.)
		RecLock("ZV5",.F.)
		REPLACE ZV5_QTDAVE WITH ZV1QTDAPN
		MsUnlock()
	Else  
		Reclock("ZV5",.T.)
			ZV5->ZV5_FILIAL := FWxFilial("ZV5") // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
			REPLACE ZV5_NUMOC 	WITH ZV1NUMOC
			REPLACE ZV5_QTDAVE  WITH ZV1QTDAPN
			REPLACE ZV5_DTABAT	WITH ZV1DTAREA
	   MsUnlock() 
	EndIf                       
ENDIF

//������������������������������������������
//�ATUALIZA ZV2010  COM OS PESOS           �
//������������������������������������������
/*DbSelectArea("ZV2")
DbSetOrder(1)
IF 	DbSeek(xFilial("ZV2")+ZV1GUIA,.T.) 
	RECLOCK("ZV2",.F.)
	REPLACE ZV2_1PESO WITH ZV11PESO
	REPLACE ZV2_2PESO WITH ZV12PESO
	MSUNLOCK()	
Else
	
EndIf*/
	RestArea(_aArea)
Return(_lRet)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DelFv1    �Autor  �DANIEL              � Data �  06/21/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �VALIDACAO DE EXCLUSAO DAS ORDENS DE CARREGAMENTO            ���
���          �VERIFICA SE A ORDEM NAO ESTA RELACIONADA COM ZV2010         ���
�������������������������������������������������������������������������͹��
���Uso       � AD0135()                                                   ���
�������������������������������������������������������������������������͹��
���Manut     �ExecBlock Ante Delecao   PDELFV01                           ���
���          �ExecBlock POS  Delecao   PDELFV02                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������


*/

User Function DelFv1()	

//�������������������������������������������������Ŀ
//�Verificar se FV1 n�o possui relacionamento em Fv2�
//�Caso tenha Perguntar se deve excluir FV2 e FV1   �
//���������������������������������������������������  
//�������������������������������������������Ŀ
//�DECLARACAO DE VARIAVEIS                    �
//���������������������������������������������
Local _aArea:=GetArea()
Local _cChave                          
Local _dtaExOc:=GETMV("MV_DTAEXOC")

U_ADINF009P('AD0135' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')
    
//����������������Ŀ
//�PONTO DE ENTRADA�
//������������������
  
	If  ExistBlock("PDELFV01")
    	ExecBlock("PDELFV01")
  	EndIf
//����������������������������������������������������������Ŀ
//�VALIDACAO DA DATA                                         �
//|GETMV("MV_DTAEXOC") PARAMETROS DOS DIAS DE EXCLUSAO       |
//������������������������������������������������������������

IF !(DTOS(ZV1->ZV1_DTABAT)>=DTOS(DATE()-_dtaExOc))
  MsgInfo("Data Abate "+DTOC(ZV1_DTABAT)+" Inferior a data "+DTOC(DATE()-_dtaExOc))
  RestArea(_aArea)
  Return() 	
EndIf      
//��������������������������������������������������������Ŀ
//�VALIDACAO DO FRETE                                      �
//����������������������������������������������������������
lControl := fValAlt(ZV1->ZV1_DTABAT) 
IF lControl .Or. !ALLTRIM(ZV1_STATUS)=''
  MsgInfo("Frete ja gerado para esse registro.")
  RestArea(_aArea)
  Return() 	
ENDIF 
//��������������������������������������������������������������Ŀ
//�VALIDACAO EM ZV2                                              �
//����������������������������������������������������������������  
//ZV2_FILIAL+ZV2_GUIA+ZV2_PLACA
	_cChave:=xFilial("ZV1")+ZV1->ZV1_GUIAPE+ZV1_PPLACA

/*SUBSTITUIDO PELAS INSTRU��ES ABAIXO, POIS QDO TEM PESAGEM N�O DEIXA EXCLUIR A ORDEM.
//POR ADRIANA EM 13/05/2008
	dbselectArea("ZV2") 
	DbSetOrder(2)
	IF DBSEEK(_cChave,.T.)	
		//�������������������������������������������Ŀ
		//�SE ENCONTREI RELACIONAMENTO EM ZV2 PERGUNTO�
		//�SE DEVO EXCLUIR EM ZV1  E ZV2              �
		//���������������������������������������������		
		MsgInfo("Registro Relacionado Com ZV2(Pesagens). Nao posso Apagar")
		RestArea(_aArea)
	Return() 	
	Else   
	  RestArea(_aArea)
	  RecLock("ZV1",.F.)     
        DbDelete()
      MsUnLock()          		  
      RestArea(_aArea)
      Return()
	EndIf	      
RestArea(_aArea)
*/
dbselectArea("ZV2")
DbSetOrder(2)
IF DBSEEK(_cChave,.T.)
	//�������������������������������������������Ŀ
	//�SE ENCONTREI RELACIONAMENTO EM ZV2 PERGUNTO�
	//�SE DEVO EXCLUIR EM ZV1  E ZV2              �
	//���������������������������������������������
	if !MsgBox("Registro Relacionado Com ZV2(Pesagens). Confirma Exclusao da Ordem e pesagem?","ATEN��O","YESNO")
		RestArea(_aArea)
		Return()
	endif
   MsgInfo("ATEN��O!!! EXCLUINDO ORDEM E PESAGEM NO PROTHEUS, INFORMAR LOGISTICA QUE A PESAGEM REFERENTE A ORDEM "+ZV1->ZV1_NUMOC+" DEVER� TAMBEM SER EXCLUIDA NO MICRA.")
	while ZV2_FILIAL+ZV2_GUIA+ZV2_PLACA = _cChave
		RecLock("ZV2",.F.)
		DbDelete()
		msUnLock()
		dbskip()
	enddo
endif
RecLock("ZV1",.F.)
DbDelete()
msUnLock()
RestArea(_aArea)

//����������������Ŀ
//�PONTO DE ENTRADA�
//�����������������
 	If  ExistBlock("PDELFV02")
 	     ExecBlock("PDELFV02")
    EndIf
Return()  
         


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MntFrt    �Autor  �DANIEL              � Data �  06/21/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �LIBERA A ORDEM APOS GERADO O FRETE.						  ���
���          �VERIFICA RELACIONAMENTO EM SZK.							  ���
���          �EXCLUI REGESTRO EM SZK. 									  ���
���          �LIMPA STATUS EM ZV1 PARA MANUTENCAO DA ORDEM                ���
�������������������������������������������������������������������������͹��
���Uso       � AD0135                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                      
User Function MntFrt()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local _aArea:=GetArea()
Local _NumOc:=ZV1_NUMOC
Local _Guia :=ZV1_GUIAPE
Local _DtaBt:=ZV1_DTABAT
Local _Plac :=UPPER(ZV1_PPLACA)
Local _Sts  :=ZV1_STATUS
Private _Chave 

U_ADINF009P('AD0135' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')

lControl := fValAlt(ZV1->ZV1_DTABAT)  // Criado em 21/07  -  HC para travar por data os registros

if lControl
  	MsgInfo("Guia Processada,Nao posso alterar")
   RestArea(_aArea)
   Return
Endif   

// inicio chamado 037812 WILLIAM COSTA, GARANTE QUE A GUIA N�O E EM BRANCO
if ALLTRIM(_Guia) == ''
	MsgStop("OL� " + Alltrim(cUserName) + CHR(10) + CHR(13) + ;
			"A Guia n�o pode estar em branco, favor verificar!!!", "AD0135")
	RestArea(_aArea)
    Return
Endif   
// final chamado 037812 WILLIAM COSTA, GARANTE QUE A GUIA N�O E EM BRANCO

//Pergunto se devo fazer manutencao do frete
If !MsgBox("Manutencao de Frete","Faz Manutencao?","YESNO") 
	RestArea(_aArea)
	Return
EndIf

//______________________________
//Verifico se foi Gerado Frete
//______________________________
If !Empty(_Sts)
  //___________________________________________
  //Monto a Chave                           
  //ZK_FILIAL+ZK_GUIA+DTOS(ZK_DTENTR)+ZK_PLACA
  //___________________________________________    
  _Chave:=xFilial("ZV1")+_Guia+DTOS(_DtaBt) //+_Plac chamado 037812 retirado o _PLAC da chave, pois indiferente da placa tem que encontrar o frete baseado na guia para deletar e voltar a ajustar a ordem de carregamento William Costa 26/10/2017  
  DbSelectArea("SZK")  
  DbSetOrder(2) 
  //____________________________________
  //Se encontro o registro em SZk
  //Apago o Registro 
  //e limpo o status em ZV1
  //____________________________________  
  If DbSeek(_Chave,.T.)
  	
  	//grava log chamado 041202 - WILLIAM COSTA 23/04/2018
  	u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.T.)","LOGISTICA","AD0135",;
  	"Filial: "+xFilial("ZV1")+" Data: "+DTOS(_DtaBt)+" GUIA: "+CVALTOCHAR(_Guia),ComputerName(),LogUserName())
  
    RecLock("SZK",.F.)
    DbDelete()
    MsUnlock()   
    RestArea(_aArea)
    //Replace ZV1_STATUS WITH ''  Chamado 005562 - HC Consys Mauricio 18/12/09.
    IF ZV1_STATUS == "G"
       RecLock("ZV1",.F.)
          Replace ZV1_STATUS WITH 'R'
       MsUnlock()
    ENDIF          
    MsgInfo("Registro pronto para manutencao")
  Else
  	//____________________________________________________
  	//Se nao encontro o registro em SZK 
  	//pergunto se ele quer gerar o frete 
  	//para esse registro 
  	//limpo o status em ZV1
  	//____________________________________________________
  	
  	//grava log chamado 041202 - WILLIAM COSTA 23/04/2018
  	u_GrLogZBE (Date(),TIME(),cUserName," ELSE RecLock(SZK,.T.)","LOGISTICA","AD0135",;
  	"Filial: "+xFilial("ZV1")+" Data: "+DTOS(_DtaBt)+" GUIA: "+CVALTOCHAR(_Guia),ComputerName(),LogUserName())
  	  	
    If !MsgBox("Gerar frete?","Gerar frete para esse registro?","YESNO")
	    RestArea(_aArea)
		 Return 
    Else       
      RestArea(_aArea)
      //Replace ZV1_STATUS WITH ''   Chamado 005562 - HC Consys Mauricio 18/12/09.
      IF ZV1_STATUS == "G"
         RecLock("ZV1",.F.)
            Replace ZV1_STATUS WITH 'R'
         MsUnlock()
      ENDIF         
      U_AD0153()
      MsgInfo ("Frete processado.")
    EndIf    
  EndIf
Else
  //____________________________________
  //Verifico se esta relacionado com ZV2
  //____________________________________  
  If (Empty(_Guia))
    //___________________________________________________
    //Caso nao esteja pergunto se deve apagar o registro
    //chamo a rotina de exclusao
    //___________________________________________________
	If !MsgInfo ("Registro Sem Guia.")	 
		RestArea(_aArea)
		Return 
	Else		
		U_DelFv1()
		MsgInfo("Ordem Excluida.")
	EndIf         
  Else
    MsgInfo("Registro Relacionado Com ZV2(Pesagens). Nao Posso Apagar")
	RestArea(_aArea)
	Return 
  EndIf		
EndIf 
RestArea(_aArea)
Return 
