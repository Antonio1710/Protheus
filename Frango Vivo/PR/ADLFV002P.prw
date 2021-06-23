#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADLFV002P º Autor ³ Fernando Sigoli     º Data ³  31/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Equipe de Carregamento/Apanha                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADLFV002P()

Local aCores      	:= {{'TRIM(ZF1_MSBLQL) == "1"','BR_VERMELHO'},{'TRIM(ZF1_MSBLQL)== "2"','BR_VERDE'}}  
Private bLegenda    := {|| Legenda()}
Private cCadastro 	:= "Cadastro Equipe Carregamento"


Private aRotina := {{"Pesquisar" ,"",0,1},;
		            {"Visualizar","AxVisual",0,2},;
		            {"Incluir"   ,"AxInclui",0,3},;
		            {"Alterar"   ,"u_ZF1_Alt()",0,4},;
		            {"Excluir"   ,"u_ZF1_Del()",0,5},;
		            {"Legenda"   ,"Eval(bLegenda)",0,8}} 
             
                            
Private aCampos := {{"Codigo","ZF1_CODIGO","C",06,00,""},;
					{"Equipe","ZF1_NOME  ","C",30,00,""},;
	                {"Data Cadastro","ZF1_DATINC","D",08,""}}
			       
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString  := "ZF1"  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Equipe de Carregamento/Apanha ')

// Verifica se a tabela existe, caso nao as cria.
ChKFile("ZF1")

dbSelectArea("ZF1")
dbSetOrder(1)

	dbSelectArea(cString)
	mBrowse(06,01,22,75,cString,aCampos, , , , ,aCores) 

Return

Static Function Legenda()

	Local aCores := {{ 'BR_VERDE'   , "EQUIPE ATIVA"},{ 'BR_VERMELHO', "EQUIPE INATIVA"}}
	BrwLegenda("Ocorrencia","Legenda",aCores)

Return Nil  

//----------========= Função para alteração. =========----------
User Function ZF1_Alt()
    
    Local cNome   := ""
    Local cAtivo  := ""
	Local aCpos   := {;
						"ZF1_NOME"	,;
						"ZF1_MSBLQL";
						}

	U_ADINF009P('ADLFV002P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Equipe de Carregamento/Apanha ')					
						
    cNome  := Alltrim(ZF1->ZF1_NOME)
    cAtivo := Alltrim(ZF1->ZF1_MSBLQL)               
                          
                          
	AxAltera("ZF1",Recno(),4,,aCpos) 
	
	//-----------------------|
    //log de registro        |
    //-----------------------| 
    If !cNome == Alltrim(ZF1->ZF1_NOME) .or. !cAtivo == Alltrim(ZF1->ZF1_MSBLQL)  
       
        dbSelectArea("ZBE")
    	RecLock("ZBE",.T.)                          
    	Replace ZBE_FILIAL    WITH xFilial("ZBE")
    	Replace ZBE_DATA      WITH dDataBase
    	Replace ZBE_HORA      WITH TIME()
    	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
    	Replace ZBE_PARAME    WITH ("ALTERAR - "+cvaltochar(ZF1->ZF1_CODIGO)+" EQUIPE: "+ZF1->ZF1_NOME )
		Replace ZBE_LOG       WITH ("EQUIPE: "+cvaltochar(ZF1->ZF1_CODIGO)+" EQUIPE: "+Alltrim(ZF1->ZF1_NOME)+ " ATIVO: " +ZF1->ZF1_MSBLQL)  
    	Replace ZBE_MODULO    WITH "FRANGOVIVO"
    	Replace ZBE_ROTINA    WITH "ADLFV002P" 
        
    EndIf
    
Return Nil
                     
//----------========= Validação de exclusão. =========----------
User Function ZF1_Del()

	Local cEquipe := Alltrim(cValToChar(ZF1->ZF1_CODIGO))

	U_ADINF009P('ADLFV002P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Equipe de Carregamento/Apanha ')					

	DbSelectArea("ZF8")
	ZF8->(DbSetOrder(3))
	ZF8->(DbGoTop())
	If ZF8->(DbSeek(xFilial("ZF8")+cEquipe))      
		MsgStop("Este registro não pode ser excluído, pois está vinculado a programação de Carregamento de Aves.")
	Else
		
		AxDeleta("ZF1",ZF1->(Recno()),5)
	
		//-----------------------|
    	//log de registro        |
    	//-----------------------| 
        dbSelectArea("ZBE")
    	RecLock("ZBE",.T.)                          
    	Replace ZBE_FILIAL    WITH xFilial("ZBE")
    	Replace ZBE_DATA      WITH dDataBase
    	Replace ZBE_HORA      WITH TIME()
    	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
    	Replace ZBE_PARAME    WITH ("EXCLUIR - CODIGO: "+cvaltochar(ZF1->ZF1_CODIGO)+" EQUIPE: "+ZF1->ZF1_NOME )
		Replace ZBE_LOG       WITH ("CODIGO: "+cvaltochar(ZF1->ZF1_CODIGO)+" EQUIPE: "+Alltrim(ZF1->ZF1_NOME)+ " ATIVO: " +ZF1->ZF1_MSBLQL)  
    	Replace ZBE_MODULO    WITH "FRANGOVIVO"
    	Replace ZBE_ROTINA    WITH "ADLFV002P" 
       
		
	EndIf

	DbCloseArea("ZZK")
	
Return Nil