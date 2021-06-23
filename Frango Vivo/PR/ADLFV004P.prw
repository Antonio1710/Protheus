#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADLFV004P º Autor ³ Fernando Sigoli     º Data ³  31/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Granjas                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADLFV004P()


Private cCadastro := "Cadastro de Granjas"


Private aRotina := {{"Pesquisar","AxPesqui"		,0,1},;
					{"Visualizar","AxVisual"	,0,2},;
					{"Incluir","U_ZF3_inclui"	,0,3},;
					{"Alterar","U_ZF3_Altera"	,0,4},;
					{"Excluir","U_ZF3_Deleta"	,0,5},;
					{"Legenda","U_Leg010"		,0,6} }

Private aCores := {{'ZF3->ZF3_MSBLQL = "2"','BR_VERDE'},;
				   {'ZF3->ZF3_MSBLQL = "1"','BR_VERMELHO'}}

Private aCampos := {}
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString := "ZF3"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Granjas')

ChKFile("ZF3")

dbSelectArea("ZF3")
dbSetOrder(1)
dbSelectArea(cString)
mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return

USER Function Leg010()
	Local aCores := {{'BR_VERDE'   ,"Ativo"},{'BR_VERMELHO'   ,"Inativo"}}

	U_ADINF009P('ADFL004P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Granjas')
	BrwLegenda("Lotes","Legenda",aCores)
Return Nil


//----------========= validação do código da granja campo ZF3_GRJCOD. =========----------
User Function ZF3_PK(cCod)   

	Local lRet		:= .T.

	U_ADINF009P('ADFL004P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Granjas')

	DbSelectArea("ZF3")
	ZF3->(DbSetOrder(1))
	ZF3->(DbGoTop())
	If DbSeek(xFilial("ZF3")+Alltrim(cValToChar(cCod)))
		MsgStop("Código de granja já existente.")
		lRet := .F.
	EndIf
Return lRet


//----------========= Função para alteração de registro na tabela ZF3. =========----------
User Function ZF3_Altera()
	
	Local aCpos  	:= {;
	"ZF3_GRADES",;
	"ZF3_GRAFAN",;
	"ZF3_FORCOD",;
	"ZF3_FORLOJ",;
	"ZF3_GRJREG",;
	"ZF3_TECCOD",;
	"ZF3_TECLOJ",;
	"ZF3_POSRAN",;
	"ZF3_MOD"	,;
	"ZF3_OBS"	,;
	"ZF3_MSBLQL",;
	"ZF3_LATITU",;
	"ZF3_LONGIT",;
	"ZF3_EDA"}

Local cFORCOD := ZF3->ZF3_FORCOD 
Local cFORLOJ := ZF3->ZF3_FORLOJ
Local cTECCOD := ZF3->ZF3_TECCOD
Local cMSBLQL := ZF3->ZF3_MSBLQL

Private aButtons  := {}

U_ADINF009P('ADFL004P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Granjas')


If AxAltera("ZF3",ZF3->(Recno()),4,,aCpos,,,,,,aButtons,,,,.T.,,,,,)== 1

	dbSelectArea("ZBE")
	RecLock("ZBE",.T.)                          
	Replace ZBE_FILIAL    WITH xFilial("ZBE")
	Replace ZBE_DATA      WITH dDataBase
	Replace ZBE_HORA      WITH TIME()
	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
	Replace ZBE_PARAME    WITH "ALTERAR - CODIGO" +ZF3->ZF3_FORCOD+" NOME: "+ZF3->ZF3_GRADES+" RECNO: "+cvaltochar(ZF3->(Recno()))
	
	If !Alltrim(cFORCOD) == Alltrim(ZF3->ZF3_FORCOD) .or. !Alltrim(cFORLOJ) == Alltrim(ZF3->ZF3_FORLOJ)  
	
		Replace ZBE_LOG	WITH "FORNCEDOR: DE:"+Alltrim(cFORCOD)+'-'+cFORLOJ+" PARA: "+Alltrim(ZF3->ZF3_FORCOD)+"-"+Alltrim(ZF3->ZF3_FORLOJ) 
		
	ElseIf !Alltrim(cTECCOD) == Alltrim(ZF3->ZF3_TECCOD) 
		
		Replace ZBE_LOG WITH "TECNICO: DE:"+Alltrim(cTECCOD)+" PARA: "+Alltrim(ZF3->ZF3_TECCOD)
		
	ElseIf !Alltrim(cMSBLQL) == Alltrim(ZF3->ZF3_MSBLQL) 
		
		Replace ZBE_LOG WITH "BLOQUEADO: DE:"+Alltrim(cMSBLQL)+" PARA: "+Alltrim(ZF3->ZF3_MSBLQL)
	
	EndIf
	Replace ZBE_MODULO  WITH "FRANGOVIVO"
	Replace ZBE_ROTINA  WITH "ADLFV004P"            
	 
	MsgInfo("Alterado com sucesso!")  	
	
EndIF

Return Nil


//----------========= Função para exclusão de registro na tabela ZF3 . =========----------
User Function ZF3_Deleta()

	Local cCodGranja	:= Alltrim(cValToChar(ZF3->ZF3_GRACOD))

	U_ADINF009P('ADFL004P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Granjas')

	DbSelectArea("ZF4")
	ZF4->(DbSetOrder(1))
	ZF4->(DbGoTop())
	If ZF4->(DbSeek(xFilial("ZF4")+cCodGranja))
		MsgStop("Este registro não pode ser excluído, pois está vinculado a cadastro(s) de Distancias X Pedagios.")
	Else
		
		If AxDeleta("ZF3",ZF3->(Recno()),5) == 1
		
			dbSelectArea("ZBE")
		   	RecLock("ZBE",.T.)                          
		   	Replace ZBE_FILIAL    WITH xFilial("ZBE")
		   	Replace ZBE_DATA      WITH dDataBase
		   	Replace ZBE_HORA      WITH TIME()
		   	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
		   	Replace ZBE_PARAME    WITH "EXCLUIR"
		   	Replace ZBE_LOG       WITH "GRANJA: "+ZF3->ZF3_GRACOD+" NOME: "+ZF3->ZF3_GRADES+" RECNO: "+cvaltochar(ZF3->(Recno()))
		   	Replace ZBE_MODULO    WITH "FRANGOVIVO"
		  	Replace ZBE_ROTINA    WITH "ADLFV004P" 
		
			MsgInfo("Excluido com sucesso!")  	
		
		EndIf
			
		
	EndIf

	DbCloseArea("ZF4")

Return Nil


//----------========= Função para incluir de registro na tabela ZF3 . =========----------
User Function ZF3_inclui()

	Private aButtons  := {}

	U_ADINF009P('ADFL004P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Granjas')

	dbSelectArea("ZF3")
	
	If AxInclui("ZF3",ZF3->(Recno()), 3,,,,,.F.,,aButtons,,,,.T.,,,,,) == 1
	 
		dbSelectArea("ZBE")
	   	RecLock("ZBE",.T.)                          
	   	Replace ZBE_FILIAL    WITH xFilial("ZBE")
	   	Replace ZBE_DATA      WITH dDataBase
	   	Replace ZBE_HORA      WITH TIME()
	   	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
	   	Replace ZBE_PARAME    WITH "INCLUIR"
	   	Replace ZBE_LOG       WITH "GRANJA: "+ZF3->ZF3_GRACOD+" NOME: "+ZF3->ZF3_GRADES+" RECNO: "+cvaltochar(ZF3->(Recno()))
	   	Replace ZBE_MODULO    WITH "FRANGOVIVO"
	  	Replace ZBE_ROTINA    WITH "ADLFV004P" 
	    
		MsgInfo("Cadastrado com sucesso!") 	

	EndIf
	   
Return Nil
