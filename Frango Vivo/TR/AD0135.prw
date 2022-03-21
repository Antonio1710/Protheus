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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cCadastro := "Manutencao Frango Vivo"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array (tambem deve ser aRotina sempre) com as definicoes das opcoes ³
	//³ que apareceram disponiveis para o usuario. Segue o padrao:          ³
	//³ aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
	//³              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
	//³              . . .                                                  ³
	//³              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      ³
	//³ Onde: <DESCRICAO> - Descricao da opcao do menu                      ³
	//³       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  ³
	//³                     duplas e pode ser uma das funcoes pre-definidas ³
	//³                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA ³
	//³                     e AXDELETA) ou a chamada de um EXECBLOCK.       ³
	//³                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-³
	//³                     clarar uma variavel chamada CDELFUNC contendo   ³
	//³                     uma expressao logica que define se o usuario po-³
	//³                     dera ou nao excluir o registro, por exemplo:    ³
	//³                     cDelFunc := 'ExecBlock("TESTE")'  ou            ³
	//³                     cDelFunc := ".T."                               ³
	//³                     Note que ao se utilizar chamada de EXECBLOCKs,  ³
	//³                     as aspas simples devem estar SEMPRE por fora da ³
	//³                     sintaxe.                                        ³
	//³       <TIPO>      - Identifica o tipo de rotina que sera executada. ³
	//³                     Por exemplo, 1 identifica que sera uma rotina de³
	//³                     pesquisa, portando alteracoes nao podem ser efe-³
	//³                     tuadas. 3 indica que a rotina e de inclusao, por³
	//³                     tanto, a rotina sera chamada continuamente ao   ³
	//³                     final do processamento, ate o pressionamento de ³
	//³                     <ESC>. Geralmente ao se usar uma chamada de     ³
	//³                     EXECBLOCK, usa-se o tipo 4, de alteracao.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ³
	//³ MBROWSE sera identica a da AXCADASTRO:                              ³
	//³                                                                     ³
	//³ cDelFunc  := ".T."                                                  ³
	//³ aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ³
	//³                { "Visualizar"   ,"AxVisual" , 0, 2},;               ³
	//³                { "Incluir"      ,"AxInclui" , 0, 3},;               ³
	//³                { "Alterar"      ,"AxAltera" , 0, 4},;               ³
	//³                { "Excluir"      ,"AxDeleta" , 0, 5} }               ³
	//³                                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SEMAFORO                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aCores            := {{"ZV1_STATUS='I'"  	,"BR_AZUL" },;
						{"ZV1_STATUS='R'"  	,"BR_LARANJA"},;
						{"ZV1_STATUS='M'"  	,"BR_MARRON"},;
						{"ZV1_STATUS='G'"  	,"BR_VERDE"},;
						{"ALLTRIM(ZV1_STATUS)=''"  	,"BR_PRETO"}}
						

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta um aRotina proprio                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	/*Criado parametro MV_#BLQFV onde o valor será subtraido a database do sistema e comparado com a data do ZV1 para total bloqueio do registro - HC */
	Private dDtCorte :=(dDataBase-GetMV("MV_#BLQFV"))
	Private lControl := .F.
	/**********************************************************************************/
	dbSelectArea("ZV1")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a funcao MBROWSE. Sintaxe:                                  ³
	//³                                                                     ³
	//³ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ³
	//³ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ³
	//³                        exibido. Para seguir o padrao da AXCADASTRO  ³
	//³                        use sempre 6,1,22,75 (o que nao impede de    ³
	//³                        criar o browse no lugar desejado da tela).   ³
	//³                        Obs.: Na versao Windows, o browse sera exibi-³
	//³                        do sempre na janela ativa. Caso nenhuma este-³
	//³                        ja ativa no momento, o browse sera exibido na³
	//³                        janela do proprio SYSTEM.                   ³
	//³ Alias                - Alias do arquivo a ser "Browseado".          ³
	//³ aCampos              - Array multidimensional com os campos a serem ³
	//³                        exibidos no browse. Se nao informado, os cam-³
	//³                        pos serao obtidos do dicionario de dados.    ³
	//³                        E util para o uso com arquivos de trabalho.  ³
	//³                        Segue o padrao:                              ³
	//³                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ³
	//³                                     {<CAMPO>,<DESCRICAO>},;         ³
	//³                                     . . .                           ³
	//³                                     {<CAMPO>,<DESCRICAO>} }         ³
	//³                        Como por exemplo:                            ³
	//³                        aCampos := { {"TRB_DATA","Data  "},;         ³
	//³                                     {"TRB_COD" ,"Codigo"} }         ³
	//³ cCampo               - Nome de um campo (entre aspas) que sera usado³
	//³                        como "flag". Se o campo estiver vazio, o re- ³
	//³                        gistro ficara de uma cor no browse, senao fi-³
	//³                        cara de outra cor.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,2,aCores)

Return()                             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LgdFV1    ºAutor  ³DANIEL              º Data ³  06/21/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³MONTA A LEGENDA PARA O USUÁRIO NO MENU                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AD0135()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AltFv1    ºAutor  ³DANIEL              º Data ³  06/21/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³FAZ A VALIDACAO PARA ALTERACAO DOS REGISTROS EM ZV1010      º±±
±±º          ³VERIFICA O STATUS PARA PERMITIR A ALTERACAO                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AD0135()                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºManut     ³ExecBlock Ante ALTERACAO   PALTFV01                         º±±
±±º          ³ExecBlock POS  ALTERACAO   PALTFV02                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
/* Função para validar alteracoes de registros    */
Static Function fValAlt(dPar)
if dPar < dDtCorte
   lControl := .T.
Else
   lControl := .F.
Endif
Return(lControl)                                   
/************************************************************************/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PALTFV02  ºAutor  ³Daniel              º Data ³  07/24/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada apos Alteracao das Ordens de Carregamento º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AD0135 - MANUTENCAO FRANGO VIVO							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION PALTFV02()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorno                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _lRet:=.F.
Local _aArea:=GetArea()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaves de atualizacao                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PROCURO EM ZV5 A QTD DE APN, SE ENCONTRO ALTERO³
//³SE NAO ENCONTRO CRIO REC EM ZV5                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATUALIZA ZV2010  COM OS PESOS           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DelFv1    ºAutor  ³DANIEL              º Data ³  06/21/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³VALIDACAO DE EXCLUSAO DAS ORDENS DE CARREGAMENTO            º±±
±±º          ³VERIFICA SE A ORDEM NAO ESTA RELACIONADA COM ZV2010         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AD0135()                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºManut     ³ExecBlock Ante Delecao   PDELFV01                           º±±
±±º          ³ExecBlock POS  Delecao   PDELFV02                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


*/

User Function DelFv1()	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se FV1 não possui relacionamento em Fv2³
//³Caso tenha Perguntar se deve excluir FV2 e FV1   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³DECLARACAO DE VARIAVEIS                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea:=GetArea()
Local _cChave                          
Local _dtaExOc:=GETMV("MV_DTAEXOC")

U_ADINF009P('AD0135' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutencao  Tabela ZV1 do Frango Vivo')
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PONTO DE ENTRADA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  
	If  ExistBlock("PDELFV01")
    	ExecBlock("PDELFV01")
  	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VALIDACAO DA DATA                                         ³
//|GETMV("MV_DTAEXOC") PARAMETROS DOS DIAS DE EXCLUSAO       |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF !(DTOS(ZV1->ZV1_DTABAT)>=DTOS(DATE()-_dtaExOc))
  MsgInfo("Data Abate "+DTOC(ZV1_DTABAT)+" Inferior a data "+DTOC(DATE()-_dtaExOc))
  RestArea(_aArea)
  Return() 	
EndIf      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VALIDACAO DO FRETE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lControl := fValAlt(ZV1->ZV1_DTABAT) 
IF lControl .Or. !ALLTRIM(ZV1_STATUS)=''
  MsgInfo("Frete ja gerado para esse registro.")
  RestArea(_aArea)
  Return() 	
ENDIF 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³VALIDACAO EM ZV2                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
//ZV2_FILIAL+ZV2_GUIA+ZV2_PLACA
	_cChave:=xFilial("ZV1")+ZV1->ZV1_GUIAPE+ZV1_PPLACA

/*SUBSTITUIDO PELAS INSTRUÇÕES ABAIXO, POIS QDO TEM PESAGEM NÃO DEIXA EXCLUIR A ORDEM.
//POR ADRIANA EM 13/05/2008
	dbselectArea("ZV2") 
	DbSetOrder(2)
	IF DBSEEK(_cChave,.T.)	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³SE ENCONTREI RELACIONAMENTO EM ZV2 PERGUNTO³
		//³SE DEVO EXCLUIR EM ZV1  E ZV2              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SE ENCONTREI RELACIONAMENTO EM ZV2 PERGUNTO³
	//³SE DEVO EXCLUIR EM ZV1  E ZV2              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !MsgBox("Registro Relacionado Com ZV2(Pesagens). Confirma Exclusao da Ordem e pesagem?","ATENÇÃO","YESNO")
		RestArea(_aArea)
		Return()
	endif
   MsgInfo("ATENÇÃO!!! EXCLUINDO ORDEM E PESAGEM NO PROTHEUS, INFORMAR LOGISTICA QUE A PESAGEM REFERENTE A ORDEM "+ZV1->ZV1_NUMOC+" DEVERÁ TAMBEM SER EXCLUIDA NO MICRA.")
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³PONTO DE ENTRADA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 	If  ExistBlock("PDELFV02")
 	     ExecBlock("PDELFV02")
    EndIf
Return()  
         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MntFrt    ºAutor  ³DANIEL              º Data ³  06/21/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³LIBERA A ORDEM APOS GERADO O FRETE.						  º±±
±±º          ³VERIFICA RELACIONAMENTO EM SZK.							  º±±
±±º          ³EXCLUI REGESTRO EM SZK. 									  º±±
±±º          ³LIMPA STATUS EM ZV1 PARA MANUTENCAO DA ORDEM                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AD0135                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                      
User Function MntFrt()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

// inicio chamado 037812 WILLIAM COSTA, GARANTE QUE A GUIA NÃO E EM BRANCO
if ALLTRIM(_Guia) == ''
	MsgStop("OLÁ " + Alltrim(cUserName) + CHR(10) + CHR(13) + ;
			"A Guia não pode estar em branco, favor verificar!!!", "AD0135")
	RestArea(_aArea)
    Return
Endif   
// final chamado 037812 WILLIAM COSTA, GARANTE QUE A GUIA NÃO E EM BRANCO

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
