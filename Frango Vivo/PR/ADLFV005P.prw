#include "rwmake.ch"  
#include "topconn.ch"
#include "Protheus.ch"
#include "FILEIO.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADLFV005P º Autor ³ Fernando Sigoli     º Data ³  31/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Manutenção/Cadastro de Distancias de Granjas               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADLFV005P()

Private cCadastro := "Manutenção/Cadastro de Distancias de Granjas"

Private aRotina	:= {{"Pesquisar",	"AxPesqui",0,1} ,;
                    {"Visualizar",	"AxVisual",0,2} ,;
                    {"Incluir",		"U_ZF4_Incl",0,3} ,; 
                    {"Alterar",		"U_ZF4_Alte",0,4} ,;         
                    {"Excluir",		"U_ZF4_Dele",0,5},;           
                    {"Legenda",		"U_Leg",0,6} }
             
Private aCores := {{'ZF4->ZF4_MSBQL = "1"','BR_VERMELHO'},;
                   {'ZF4->ZF4_MSBQL = "2"','BR_VERDE' }}

Private aCampos := {}

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "ZF4"  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutenção/Cadastro de Distancias de Granjas')

// Verificar se a Tabela Existe, caso não as cria.
ChKFile("ZF4")

dbSelectArea("ZF4")
dbSetOrder(1)


	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,,,,,,aCores)

Return

STATIC Function Leg()
Local aCores := {{'BR_VERDE'   	,"Ativo"},;
                 {'BR_VERMELHO' ,"Inativo"}}
                 
	BrwLegenda("Lotes","Legenda",aCores)
Return Nil
 
//--------------------------==================== Incluir ====================-------------------------- 
User Function ZF4_Incl()
	
	Local aArea 	  := GetArea()
	Private aButtons  := {}

	U_ADINF009P('ADLFV005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutenção/Cadastro de Distancias de Granjas')
	
	//adiciona botoes na Enchoice                       
	aAdd( aButtons, { "TABPEDAG", {|| U_TABPEDAG()}, "* Pedágio", "* Pedágio" } )
	
	If 	AxInclui("ZF4",ZF4->(Recno()), 3,,,,"U_ValGrLocal(M->ZF4_GRCOD,M->ZF4_LOCAL)",.F.,,aButtons,,,,.T.,,,,,) == 1                                                                      

		dbSelectArea("ZBE")
	   	RecLock("ZBE",.T.)                          
	   	Replace ZBE_FILIAL    WITH xFilial("ZBE")
	   	Replace ZBE_DATA      WITH dDataBase
	   	Replace ZBE_HORA      WITH TIME()
	   	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
	   	Replace ZBE_PARAME    WITH "INCLUIR"
	   	Replace ZBE_LOG       WITH "GRANJA: "+ZF4->ZF4_GRCOD+" DESTINO: "+ZF4->ZF4_LOCAL+"KM: "+cvaltochar(ZF4->ZF4_KM)+" QTD PEDAG."+cvaltochar(ZF4->ZF4_QTDPED)+" RECNO: "+cvaltochar(ZF4->(Recno()))
	   	Replace ZBE_MODULO    WITH "FRANGOVIVO"
	  	Replace ZBE_ROTINA    WITH "ADLFV005P" 
			
		MsgInfo("Cadastrado com sucesso!")
		
	EndIf
	RestArea(aArea)
	
Return

//----------========= Função para exclusão de registro na tabela ZF3 . =========----------
User Function ZF4_Dele()

	U_ADINF009P('ADLFV005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutenção/Cadastro de Distancias de Granjas')

	If AxDeleta("ZF4",ZF4->(Recno()),5) == 1
		
		MsgInfo("Excluido com sucesso!")  	
		
	EndIf

Return Nil


//--------------------------==================== Alterar ====================-------------------------- 
User Function ZF4_Alte()
	
	Local aArea  	:= GetArea()
	Local aAcho  	:= {"NOUSER","ZF4_KM","ZF4_QTDPED","ZF4_TOTPED","ZF4_TEMPO","ZF4_ACRESC","ZF4_TREVO","ZF4_ATV"}
	Local cTempo 	:= ZF4->ZF4_TEMPO
	Local nTotPed   := ZF4->ZF4_TOTPED
	Local cAcrec    := ZF4->ZF4_ACRESC
	Local cTrevo    := ZF4->ZF4_TREVO
	
	Private aButtons  := {}

	U_ADINF009P('ADLFV005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutenção/Cadastro de Distancias de Granjas')
	
	//adiciona botoes na Enchoice                       
	aAdd( aButtons, { "TABPEDAG", {|| U_TABPEDAG()}, "* Pedágio", "* Pedágio" } )
	                      
	If  AxAltera("ZF4",ZF4->(Recno()),4,,aAcho,,,,,,aButtons,,,,.T.,) == 1    
	
		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)                          
		Replace ZBE_FILIAL    WITH xFilial("ZBE")
		Replace ZBE_DATA      WITH dDataBase
		Replace ZBE_HORA      WITH TIME()
		Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
		Replace ZBE_PARAME    WITH "ALTERAR - CODIGO" +ZF3->ZF3_FORCOD+" NOME: "+ZF3->ZF3_GRADES+" RECNO: "+cvaltochar(ZF3->(Recno()))
	
   		If !Alltrim(cTempo) == Alltrim(ZF4->ZF4_TEMPO) 
	
			Replace ZBE_LOG       WITH "TEMPO DE VIAGEM DE:"+Cvaltochar(cTempo)+" PARA: "+cvaltochar(ZF4->ZF4_TEMPO)
	
   		ElseIf !Alltrim(nTotPed) == Alltrim(ZF4->ZF4_TOTPED) 
		
			Replace ZBE_LOG       WITH "QTD PEDAGIOS DE: "+Cvaltochar(nTotPed)+" PARA: "+cvaltochar(ZF4->ZF4_TOTPED)
		
		ElseIf !Alltrim(nAcrec) == Alltrim(ZF4->ZF4_ACRESC)     
		
			Replace ZBE_LOG       WITH "ACRESCIMO DE: "+cAcrec+" PARA: "+ZF4->ZF4_ACRESC
		
   		ElseIf !Alltrim(cTrevo) == Alltrim(ZF4->ZF4_TREVO) 
		
			Replace ZBE_LOG       WITH "ULTILIZA TREVO DE: "+Alltrim(cTrevo)+" PARA: "+Alltrim(ZF4->ZF4_TREVO)
	
		EndIf
		Replace ZBE_MODULO    WITH "FRANGOVIVO"
		Replace ZBE_ROTINA    WITH "ADLFV005P"           
	
		MsgInfo("Alterado com sucesso!")  
		
	EndIf
	
	RestArea(aArea)

Return

//----------========= Validador do AxFunction se já existe cadastro do Local para Granja. =========----------
User Function ValGrLocal(GrCod,LocalCod)

	U_ADINF009P('ADLFV005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutenção/Cadastro de Distancias de Granjas')

	DBSelectArea('ZF4')
	DBSetOrder(1)
	DBGoTop()
	If DBSeek(xFilial('ZF4')+ GrCod + LocalCod)
		MsgInfo("Já existe cadastro desse Local para esta Granja! Por favor, insira um codigo válido.")
		Return .F.
	EndIf
Return .T. 



//----------========= Incluir as praças de Pedagio selecionada para  a granja. =========----------
User Function TABPEDAG() 

	SetPrvt("_OMARK,_STRU,CARQ,_CINDEX,_CCHAVE,ACAMPOS")
	SetPrvt("LREFRESH,") 

	PRIVATE nVZDSM := 0

	U_ADINF009P('ADLFV005P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Manutenção/Cadastro de Distancias de Granjas')


	_stru:={}
	AADD(_stru,{"RB_OK","C",2,0})
	AADD(_stru,{"RB_CODIGO","C",6,0})
	AADD(_stru,{"RB_CODROD","C",06,0})
	AADD(_stru,{"RB_DESROD","C",20,0})
	AADD(_stru,{"RB_MUNIC","C",20,0})
	AADD(_stru,{"RB_KM","N",3,0})
	AADD(_stru,{"RB_VALOR","N",6,2})
	

	cArq:=Criatrab(_stru,.T.)

	DBUSEAREA(.t.,,carq,"TRB")
	
	INDEX ON RB_CODIGO TO TESTE
	
	cMarca := GetMark()  
	
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName('DU0')+" DU0 "
	cQuery += " WHERE DU0_FILIAL = '"+xFilial("DU0")+"' "
 	cQuery += " AND  DU0.D_E_L_E_T_ = '' "  
	
	TCQUERY cQuery new alias "QDU0"
	
	DBSELECTAREA("QDU0")
	DBGOTOP()
	WHILE !EOF()
		DBSELECTAREA("TRB")
	  	RECLOCK("TRB",.T.) 
	  	TRB->RB_CODIGO := QDU0->DU0_CODROD
	   	TRB->RB_CODROD := QDU0->DU0_SEQPDG
	   	TRB->RB_DESROD := POSICIONE("DTZ",1,XFILIAL("DTZ")+QDU0->DU0_CODROD,"DTZ_NOMROD")
	   	TRB->RB_MUNIC  := QDU0->DU0_MUNPDG
	   	TRB->RB_KM     := QDU0->DU0_KM 
	   	TRB->RB_VALOR  := QDU0->DU0_VALEIX
	   	TRB->RB_OK     := cMarca
	 	MSUNLOCK()
	DBSELECTAREA("QDU0")
	DBSKIP()
	ENDDO
	
	_cIndex:=Criatrab(Nil,.F.)
	_cChave:="RB_CODIGO+RB_CODROD"

	Indregua("TRB",_cIndex,_cchave,,,"Selecionando Registros...")

 	dBSETINDEX(_cIndex+ordbagext())
 

	DEFINE MSDIALOG oDlg2 FROM 200,1 TO 500,590 TITLE "Praça Pedágio" PIXEL

	aCampos := {}
	AADD(aCampos,{"RB_OK","","@!","2","0"})
	AADD(aCampos,{"RB_CODIGO","Codigo","@!","6","0"}) 
	AADD(aCampos,{"RB_DESROD","Rodovia","@!","20","0"}) 
	AADD(aCampos,{"RB_CODROD","Pedagio","@!","6","0"})
	AADD(aCampos,{"RB_MUNIC","Municipio","@!","20","0"}) 
	AADD(aCampos,{"RB_KM","KM","@E 999.99","06","2"})
	AADD(aCampos,{"RB_VALOR","Valor EIXO","@E 999.99","6","2"})

	@ 6,5 TO 93,290 BROWSE "TRB" FIELDS acampos MARK "RB_OK" object _oMark
	@ 096,010 SAY "Cadastros de Pedagio, Selecione o Desejado e Confirme."  SIZE 142, 007 OF oDlg2 COLORS 0, 16777215 PIXEL
	@ 110,010 BUTTON "Ok" SIZE 40,15 ACTION (CONFOK(),Close(oDlg2)) SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,060 BUTTON "MARCA TUDO" SIZE 40,15 ACTION Marca() SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,110 BUTTON "DESMARCA TUDO" SIZE 50,15 ACTION Desmarca() SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,170 BUTTON "LIMPA" SIZE 40,15 ACTION (CONFCLS(),Close(oDlg2)) SIZE 037, 012 OF oDlg2 PIXEL
	@ 110,220 BUTTON "SAIR" SIZE 40,15 ACTION Close(oDlg2) SIZE 037, 012 OF oDlg2 PIXEL

	IF nVZDSM = 0
  		Desmarca()
 		nVZDSM := 1
	ENDIF

	ACTIVATE MSDIALOG oDlg2 CENTERED

	DBSELECTAREA("TRB")
 	DBCLOSEAREA()
  	FERASE(cArq)   

	QDU0->(dbclosearea()) 
  
Return
   
//----------========= atualiza campo ZF4->ZF4_PRCPDG. =========----------
STATIC FUNCTION CONFOK() 
    
   	Private nVez 	:= 0
	Private nVlrPdg := 0
	//
	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		IF Marked("RB_OK") //Registro nao esta marcado
	    	IF nVez = 0
	      		M->ZF4_TOTPED := TRB->RB_VALOR
	    		M->ZF4_PRCPDG := ALLTRIM(TRB->RB_CODIGO)+ALLTRIM(TRB->RB_CODROD)
				M->ZF4_PEDAGI := ALLTRIM(TRB->RB_CODIGO)+" "+ALLTRIM(TRB->RB_CODROD)+" "+TRB->RB_DESROD+" "+chr(9)+SUBSTR(TRB->RB_MUNIC,1,10)+chr(9)+" KM: "+cvaltochar(transform(TRB->RB_KM,"@E 999.99"))+" R$:"+cvaltochar(transform(TRB->RB_VALOR,"@E 999.99"))+ chr(13) + chr(10)
	    		M->ZF4_QTDPED := 1
	    	ELSE
	    		M->ZF4_PRCPDG += "/"
	    		M->ZF4_TOTPED += TRB->RB_VALOR
				M->ZF4_PRCPDG += ALLTRIM(TRB->RB_CODIGO)+ALLTRIM(TRB->RB_CODROD)
	    		M->ZF4_PEDAGI += ALLTRIM(TRB->RB_CODIGO)+" "+ALLTRIM(TRB->RB_CODROD)+" "+TRB->RB_DESROD+" "+chr(9)+SUBSTR(TRB->RB_MUNIC,1,10)+chr(9)+" KM: "+cvaltochar(transform(TRB->RB_KM,"@E 999.99"))+" R$:"+cvaltochar(transform(TRB->RB_VALOR,"@E 999.99"))+ chr(13) + chr(10)
	    		M->ZF4_QTDPED += 1
	    	ENDIF
			nVez := 1
	  	EndIf 
	  	DbSkip()
	 ENDDO 
Return

//----------========= marca itens a serem considerados. =========----------
Static Function Marca() 

	cMarca := GetMark()

	DbSelectArea("TRB")
	DbGoTop()
	While !EOF()
		If !Marked("RB_OK") //Registro nao esta marcado
    		Reclock("TRB",.F.)
     		TRB->RB_OK := cMarca
    		MsUnlock()
  		EndIf
		DbSkip()
	End
	DbGoTop()
	_oMark:oBrowse:Refresh()

Return

//----------========= Desmarca todos os itens. =========----------
Static Function DesMarca() 

	DbSelectArea("TRB")
	DbGoTop()
		While !EOF()
			If Marked("RB_OK") //Registro esta marcado
  				Reclock("TRB",.F.)
    			TRB->RB_OK := ThisMark()
  				MsUnlock()
			EndIf
			DbSkip()
  		End
	DbGoTop()
	_oMark:oBrowse:Refresh()
Return                                                 
                                               
//----------========= limpa o campo ZF4->ZF4_PRCPDG. =========----------
Static Function CONFCLS()
	M->ZF4_PRCPDG := ""
	M->ZF4_PEDAGI := ""
	M->ZF4_TOTPED := 0
	M->ZF4_QTDPED := 0
Return() 
