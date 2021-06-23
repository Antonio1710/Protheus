#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CadReg    º Autor ³ Sandra Ribeiro     º Data ³  31/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para cadastro das Regioes                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ad'oro                                                     º±±
±±ºversionamento                                                          º±±
±±ºEverson - 05/12/2018. Chamado 045582. Comentado o código que envia     º±±
±±ºas alterações ao Salesforce.                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CadReg() // U_CadReg()

	Private cCadastro := "Cadastro de Frete x Regiao"
	Private aRotina := { {"Pesquisar" ,"AxPesqui",0,1} ,;
						 {"Visualizar","AxVisual",0,2} ,;
						 {"Incluir"   ,"U_FV9INC",0,3} ,;
						 {"Alterar"   ,"U_FV9ALT",0,4} ,;
						 {"Excluir"   ,"AxDeleta",0,5} }

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro das Regioes')

	dbSelectArea("ZZI")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"ZZI")

Return

User function FV9INC()

	_nOpca := AxInclui( "ZZI", ZZI->( Recno() ), 03,,,,,, )

	U_ADINF009P('CADREG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro das Regioes')

	DbSelectArea("ZZI")
	DbGoto(ZZI->(Recno()))

	_cEst := ZZI->ZZI_ESTADO
	_cReg := ZZI->ZZI_REGIAO
	_nVal := ZZI->ZZI_VALOR * 1000  &&Sempre 1 tonelada
	_cDRg := ZZI->ZZI_DESCRG
	_dDTV := ZZI->ZZI_VIGENC

	DbSelectArea("ZV9")
	DbSetOrder(1)
	_cCod := GETSX8NUM("ZV9","ZV9_COD")
	RecLock("ZV9",.T.)
	Replace ZV9_COD     With _cCod
	Replace ZV9_REGIAO  With _cReg
	Replace ZV9_DTVAL   With _dDTV
	Replace ZV9_VLTON   With _nVal
	Replace ZV9_VLTK    With _nVal
	Replace ZV9_VLTC    With _nVal
	ZV9->(MsUnLock())
	ConfirmSX8()
	
	//Everson - 05/12/2018. Chamado 045582.
	//Everson - 08/03/2018. Chamado 037261. SalesForce.
	//If FindFunction("U_ADVEN076P") .And. _nOpca == 1
		//U_ADVEN076P("","",.F.," AND VLRFRT.CC2_XREGIA = '" + Alltrim(cValToChar(_cReg)) + "' ","FRT",.T.," Alt - Valor de frete ")

	//EndIf

	DbSelectArea("ZZI")
	DbGotop()

Return()

User function FV9ALT()

	Local _aAlter := {}

	U_ADINF009P('CADREG' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro das Regioes')

	dbSelectArea( "SX3" )
	dbSetOrder( 01 )
	dbSeek( "ZZI" )

	While SX3->( !Eof() ) .And. SX3->X3_ARQUIVO == "ZZI"

		If	AllTrim( Upper( SX3->X3_CAMPO ) ) != "ZZI_USUARI"		.And. ;
		AllTrim( Upper( SX3->X3_CAMPO ) ) != "ZZI_DATA"	.And. ;
		AllTrim( Upper( SX3->X3_CAMPO ) ) != "ZZI_HORA"

			Aadd( _aAlter, SX3->X3_CAMPO )

		EndIf

		SX3->( dbSkip() )

	EndDo

	_nOpca := AxAltera( "ZZI", ZZI->( Recno() ), 04,, _aAlter ,,,,,, )

	DbSelectArea("ZZI")
	DbGoto(ZZI->(Recno()))

	_cEst := ZZI->ZZI_ESTADO
	_cReg := ZZI->ZZI_REGIAO
	_nVal := ZZI->ZZI_VALOR * 1000  &&Sempre 1 tonelada
	_cDRg := ZZI->ZZI_DESCRG
	_dDTV := ZZI->ZZI_VIGENC

	DbSelectArea("ZV9")
	DbSetOrder(5)
	If dbseek(xFilial("ZV9")+_cReg+Dtos(ZZI->ZZI_VIGENC))
		RecLock("ZV9",.F.)   
		Replace ZV9_REGIAO  With _cReg   
		Replace ZV9_VLTON   With _nVal
		Replace ZV9_VLTK    With _nVal
		Replace ZV9_VLTC    With _nVal
		ZV9->(MsUnlock())
	Else
		_cCod := GETSX8NUM("ZV9","ZV9_COD")
		RecLock("ZV9",.T.)
		Replace ZV9_COD     With _cCod
		Replace ZV9_REGIAO  With _cReg
		Replace ZV9_DTVAL   With _dDTV
		Replace ZV9_VLTON   With _nVal
		Replace ZV9_VLTK    With _nVal
		Replace ZV9_VLTC    With _nVal
		ZV9->(MsUnLock())
		ConfirmSX8()
	Endif
	
	//Everson - 05/12/2018. Chamado 045582.
	//Everson - 08/03/2018. Chamado 037261. SalesForce.
	//If FindFunction("U_ADVEN076P") .And. _nOpca == 1
		//U_ADVEN076P("","",.F.," AND VLRFRT.CC2_XREGIA = '" + Alltrim(cValToChar(_cReg)) + "' ","FRT",.T.," Alt - Valor de frete ")

	//EndIf

Return()