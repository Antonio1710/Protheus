#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ADLFV001P º Autor ³ Fernando Sigoli     º Data ³  31/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tabela Genérica de Avicultura                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADLFV001P()

Private cCadastro 	:= "Tabela Genérica de Avicultura"
	
Private aRotina := { {"Pesquisar",""			,0,1} ,;
					 {"Visualizar","AxVisual"	,0,2} ,;
					 {"Incluir","AxInclui"		,0,3} ,;
					 {"Alterar","U_ZF0_Altera"	,0,4} ,;
					 {"Excluir","AxDeleta"		,0,5} }

Private aCampos := { {"Tabela",		"ZF0_TABCOD","C",02,00,""},;
					 {"Chave",		"ZF0_CHVCOD","C",02,00,""},;
                     {"Descricao",	"ZF0_CHVDES","C",20,00,""} }

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString  := "ZF0"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Genérica de Avicultura')

ChKFile("ZF0") // verificar se a tabela existe, caso nao as cria

dbSelectArea("ZF0")
dbSetOrder(1)


	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString,aCampos,)

Return

//----------========= Função que retorna o sequencial da tabela. =========----------
User Function ZF0_CODTAB(cCodTab)

	Local aArea		:= GetArea()
	Local cRet		:= ""
	Local cQuery    := ""

	U_ADINF009P('ADLFV001P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Genérica de Avicultura')

	cQuery += " SELECT "
	cQuery += " MAX(ZF0_CHVCOD) AS COD "

	cQuery += " FROM "
	cQuery += " " + RetSqlName("ZF0") + " AS ZF0 "
	cQuery += " WHERE "
	cQuery += " ZF0_FILIAL = '" + xFilial("ZF0") + "' "
	cQuery += " AND  ZF0_TABCOD = '" + cCodTab + "' AND ZF0.D_E_L_E_T_ = '' "

	If Select("ZF0COD") > 0
		ZF0COD->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "ZF0COD"

	DbSelectArea("ZF0COD")
	ZF0COD->(DbGoTop())
		cRet := ZF0COD->COD
	DbCloseArea("ZF0COD")

	If Empty(Alltrim(cValToChar(cRet)))
		cRet := "01"
	Else
		cRet := RIGHT("0"+cValToChar(Val(cValToChar(cRet)) + 1),2)
	EndIf

	RestArea(aArea)

Return cRet

//----------========= Função para alteração de registro na tabela ZF0. =========----------
User Function ZF0_Altera()
    
    Local cChvdes   := ""
    Local cPalavr   := ""
	Local aCpos  	:= {;
						"ZF0_CHVDES"	,;
						"ZF0_PALAVR";
						}

	U_ADINF009P('ADLFV001P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Genérica de Avicultura')						
     
    cChvdes := Alltrim(ZF0->ZF0_CHVDES)
    cPalavr := Alltrim(ZF0->ZF0_PALAVR)               
                          
                          
	AxAltera("ZF0",Recno(),4,,aCpos) 
	
	//-----------------------|
    //log de registro        |
    //-----------------------| 
    If !cChvdes == Alltrim(ZF0->ZF0_CHVDES) .or. !cPalavr == Alltrim(ZF0->ZF0_PALAVR)   
    
    	dbSelectArea("ZBE")
    	RecLock("ZBE",.T.)                          
    	Replace ZBE_FILIAL    WITH xFilial("ZBE")
    	Replace ZBE_DATA      WITH dDataBase
    	Replace ZBE_HORA      WITH TIME()
    	Replace ZBE_USUARI    WITH UPPER(Alltrim(cUserName))
    	Replace ZBE_PARAME    WITH ("ALTERAR - TABELA: "+Alltrim(ZF0->ZF0_TABCOD)+" CHAVE: "+Alltrim(ZF0->ZF0_CHVCOD)) 
    	Replace ZBE_LOG       WITH ("DESCR: " +Alltrim(ZF0->ZF0_CHVDES)+" PALAVRA: "+Alltrim(ZF0->ZF0_PALAVR))  
    	Replace ZBE_MODULO    WITH "FRANGOVIVO"
    	Replace ZBE_ROTINA    WITH "ADLFV001P" 
    
    EndIf
    
Return Nil


//----------========= Função para validação da descrição da tabela. =========----------
User Function ZF0_ValidaCod(cCodTab,cTabDes)

    Local cDesc

	U_ADINF009P('ADLFV001P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Genérica de Avicultura')

    cDesc := Alltrim(cValToChar(U_ZF0_TABDES(cCodTab)))

    If !Empty(cDesc) .And. cDesc <> Alltrim(cValToChar(cTabDes))
        M->ZF0_TABDES := cDesc
        MsgStop("Tabela já possui descrição.")
        Return .F.
    EndIf

Return .T.


//----------========= Função que retorna a descrição da tabela. =========----------
User Function ZF0_TABDES(cCodTab)

    Local aArea     := GetArea()
    Local cRet      := ""
    Local cQuery    := ""

	U_ADINF009P('ADLFV001P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Genérica de Avicultura')

    cQuery += " SELECT "
    cQuery += " ZF0_TABDES AS DESCRI "

    cQuery += " FROM "
    cQuery += " " + RetSqlName("ZF0") + " AS ZF0 "
    cQuery += " WHERE "
    cQuery += " ZF0_FILIAL = '" + xFilial("ZF0") + "' "
    cQuery += " AND  ZF0_TABCOD = '" + cCodTab + "' AND ZF0.D_E_L_E_T_ = '' "

    If Select("ZF0DES") > 0
        ZF0DES->(DbCloseArea())
    EndIf

    TcQuery cQuery New Alias "ZF0DES"

    DbSelectArea("ZF0DES")
    ZF0DES->(DbGoTop())
        cRet := ZF0DES->DESCRI
    DbCloseArea("ZF0DES")

    RestArea(aArea)

Return cRet