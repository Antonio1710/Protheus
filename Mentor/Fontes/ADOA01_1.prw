#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function ADOA01_1
	(Cadastro de Usuarios, Adoro - Cadastro espelho de ciente e aprovacao de credito)
	@type  Function
	@author Vogas Junior
	@since 08/09/2009
	@version 01
	@history 059748 - ADRIANO SAVOINE - 16/07/2020 - Incluido parametro para bloquear acesso indevido MV_CADALC.
	/*/


User Function ADOA01_1

Local aArea			:= GetArea()

Private cCadastro	:= "Cadastro de Usuarios"
Private cString		:= "PB1"

Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"							,0,1} ,;
							{"Visualizar"	,"AxVisual(cString, RecNo(), 2)"	,0,2} ,;
							{"Incluir"		,"AxInclui(cString, RecNo(), 3)"	,0,3} ,;
							{"Alterar"		,"AxAltera(cString, RecNo(), 4)"	,0,4} ,;
							{"Excluir"		,"AxDeleta(cString, RecNo(), 5)"	,0,5} }

IF __cUserid $ GetMv( "MV_CADALC", .F.,'000000')

	lRet := .T.
	
ELSE

	lRet := .F.

	MSGALERT("OLÁ "+ Alltrim(cUserName) + CHR(10) + CHR(13)+"Identificamos que você não tem permissão para utilizar essa função" + CHR(10) + CHR(13)+" Nesse caso você tem que solicitar para seu gerente efetuar essa alteração ou solicitar a inclusão do seu usuario do Protheus no parâmetro <FONT color= red><b>MV_CADALC</b></FONT> ." , "<b>ADOA01_1</b>")

ENDIF

IF lRet = .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Usuarios.')

	dbSelectArea(cString)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cString)
	RestArea( aArea )

ENDIF

Return Nil       

