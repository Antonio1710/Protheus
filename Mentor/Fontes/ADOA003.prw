#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} User Function ADOA003
	(Cadastro de Alcadas, conforme as regras estabelecidas pelo cliente.)
	@type  Function
	@author Vogas Junior
	@since 08/09/2009
	@version 01
	@history 059748 - ADRIANO SAVOINE - 16/07/2020 - Incluido parametro para bloquear acesso indevido MV_CADALC.
	/*/


User Function ADOA003()

Local aArea			:= GetArea()
Private cCadastro	:= "Cadastro de Alçadas"
Private cString		:= "PB7"

Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"							,0,1} ,;
								{"Visualizar"	,"AxVisual(cString, RecNo(), 2)"	,0,2} ,;
								{"Incluir"		,"AxInclui(cString, RecNo(), 3)"	,0,3} ,;
								{"Alterar"		,"AxAltera(cString, RecNo(), 4)"	,0,4} ,;
								{"Excluir"		,"u_ADOA3EXC(cString, RecNo(), 5)"	,0,5} }

IF __cUserid $ GetMv( "MV_CADALC", .F.,'000000')

	lRet := .T.
	
ELSE

	lRet := .F.

	MSGALERT("OLÁ "+ Alltrim(cUserName) + CHR(10) + CHR(13)+"Identificamos que você não tem permissão para utilizar essa função" + CHR(10) + CHR(13)+" Nesse caso você tem que solicitar para seu gerente efetuar essa alteração ou solicitar a inclusão do seu usuario do Protheus no parâmetro <FONT color= red><b>MV_CADALC</b></FONT> ." , "<b>ADOA003</b>")

ENDIF

IF lRet = .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Alcadas, conforme as regras estabelecidas pelo cliente. ')

	dbSelectArea(cString)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cString)
	RestArea( aArea )

ENDIF

Return Nil       


/*/{Protheus.doc} User Function ADOA1EXC
	(Rotina para validar a exclusao do departamento, Adoro - Cadastro espelho de ciente e aprovacao de credito)
	@type  Function
	@author Microsiga
	@since 22/07/2009
	@version 01
	/*/

User Function ADOA3EXC(cString, nReg, nOpc)

Local lVal		:= .T.
Local aArea		:= GetArea()
Local aAreaPB7	:= PB7->( GetArea() )

U_ADINF009P('ADOA003' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Alcadas, conforme as regras estabelecidas pelo cliente. ')

//------------------------------------------
//Valida se a alcada pode ser excluida
//------------------------------------------
DbSelectArea("PB1") // Amarracao Depto x Usuario x Nivel
DbSetorder(3) //FILIAL + Nivel de alcada
If DbSeek( xFilial("PB1") + PB7->PB7_CODNIV ) 
	lVal := .F.
EndIf

DbSelectArea("PB7")
RestArea( aAreaPB7 )
RestArea( aArea )

If !lVal
	MsgAlert('Esta Alcada está sendo utilizada por algum usuário. Não pode ser excluída.')
	Return Nil
Else
	AxDeleta(cString,nReg,nOpc)
	Return Nil
EndIf

Return Nil
