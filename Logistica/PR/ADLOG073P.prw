#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*/{Protheus.doc} User Function ADLOG073P
	(Cadastro de Manobristas para a Logistica)
	@type  Function
	@author ADRIANO SAVOINE
	@since 25/03/2021
	@version 01
	@history Ticket: 11427 - 25/03/2021 - ADRIANO SAVOINE - Solicitado pela Logistica para utilizar nas pesagens os manobristas entre DIMEP x Edata.
	@history Ticket: T.I.  - 10/06/2021 - LEONARDO MONTEIRO - Ajuste na alteração do registro que estava posicionando no primeiro registro.
	@history Ticket: T.I.  - 22/07/2021 - LEONARDO MONTEIRO - Inclusão de validações para não deixar que manobristas sejam vinculados a veículos e a transportadoras.
	@history Ticket: 18822 - 24/08/2021 - LEONARDO MONTEIRO - Correção de error.log relacionado ao ticket 18822.
	/*/

User Function ADLOG073P()

	Local aCores      	:= {{'TRIM(ZEB_MSBLQL) == "1"','BR_VERMELHO'},{'TRIM(ZEB_MSBLQL)== "2"','BR_VERDE'}}  
	Private bLegenda    := {|| Legenda()}
	Private cCadastro 	:= "Cadastro de Manobristas"


	Private aRotina := {{"Pesquisar" ,"",0,1},;
		            {"Visualizar","AxVisual",0,2},;
		            {"Incluir"   ,"U_INCLUI()",0,3},;
		            {"Alterar"   ,"U_ALTERA()",0,4},;
		            {"Excluir"   ,"AxDeleta",0,5},;
		            {"Legenda"   ,"Eval(bLegenda)",0,8}} 
             
                            
	Private aCampos := {}
		aadd(aCampos,       {"Codigo","ZEB_CODIGO","C",06,00,"@!"})
		aadd(aCampos,	  	{"Nome Manobra","ZEB_NOME","C",10,00,"@!"})
		aadd(aCampos,		{"Apelido","ZEB_APELID","C",10,00,"@!"})
		aadd(aCampos,		{"CPF","ZEB_CPF","C",11,00,"@R 999.999.999-99"})					
		aadd(aCampos,		{"Tel Fixo","ZEB_TELEFO","C",11,00,"@!"})
		aadd(aCampos,		{"Celular","ZEB_CELULA","C",11,00,"@!"})
				

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Manobristas ')


	dbSelectArea("ZEB")
	dbSetOrder(1)

	mBrowse(06,01,22,75,"ZEB",aCampos, , , , ,aCores) 

Return

Static Function Legenda()

	Local aCores := {{ 'BR_VERDE'   , "MANOBRISTA ATIVO"},{ 'BR_VERMELHO', "MANOBRISTA INATIVO"}}
	BrwLegenda("Ocorrencia","Legenda",aCores)

Return Nil  


USER Function INCLUI()

	Local nOpca := ""
   
    dbSelectArea("ZEB")
    nOpca := AxInclui("ZEB",ZEB->(Recno()), 3,,"u_CARREZEB()",,"U_VLDZEB()",.T.,,,,,,.T.,,,.T.,,)

Return 

User Function VldZEB()
	Local lRet 		:= .T.
	Local cQuery 	:= ""
	Local cMens		:= ""

	cQuery := " SELECT ZV4_PLACA, ZV4_NOMFOR "
	cQuery += " FROM "+ RetSqlName("ZV4") +" "
	cQuery += " WHERE D_E_L_E_T_='' AND ZV4_FILIAL='"+ xFilial("ZV4") +"' AND "
	cQuery += "  (   ZV4_CPF  ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF1 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF2 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF3 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF4 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF5 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF6 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF7 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF8 ='"+ M->ZEB_CPF +"' "
	cQuery += "   OR ZV4_CPF9 ='"+ M->ZEB_CPF +"'); "

	TcQuery cQuery ALIAS "QZV4" NEW

	if QZV4->(!eof())

		cMens := "O CPF cadastrado tem vínculo com as seguintes placas e transportadoras:"+CHR(13)+CHR(10)+CHR(13)+CHR(10)
		
		while QZV4->(!eof())
			cMens += " - Fornecedor: "+QZV4->ZV4_NOMFOR +", Placa: "+ QZV4->ZV4_PLACA +""+CHR(13)+CHR(10)
			QZV4->(Dbskip())
		end
		MsgInfo(cMens, "Alerta")
		lRet := .F.
	endif
	
	QZV4->(DbCloseArea())

return lRet

USER Function CARREZEB()


Local cQuery := ""
   
	// Correção de error.log relacionado ao ticket 18822.
    cQuery := "SELECT MAX ((ZEB.ZEB_CODIGO) + 1)MX FROM "+RetSqlName("ZEB")+" ZEB WHERE  ZEB.D_E_L_E_T_ = '' AND ZEB.ZEB_FILIAL = '"+xFilial("ZEB")+"';"
    cQuery := changequery(cQuery)

    dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQuery), "TMPQRY")

		IF !EMPTY(TMPQRY->MX)

			M->ZEB_CODIGO  := PADL(TMPQRY->MX,6,'0')

		ELSE

			M->ZEB_CODIGO  := '001'

		ENDIF
		

    DBCloseArea()


Return


USER Function ALTERA()

Local aArea       := GetArea()
    Local aArea1     := ZEB->(GetArea())
    Local nOpcao      := 0
    Private cCadastro := "Cadastro de Manobrista - ALTERAR"
     
    DbSelectArea('ZEB')
    ZEB->(DbSetOrder(1)) 
    //@history Ticket: T.I.  - 10/06/2021 - LEONARDO MONTEIRO - Ajuste na alteração do registro que estava posicionando no primeiro registro.
	//ZEB->(DbGoTop())
     
    //Se conseguir posicionar no produto
    If ZEB->(DbSeek(FWxFilial('ZEB') + ZEB->ZEB_CODIGO))
        nOpcao := AxAltera('ZEB', ZEB->(RecNo()), 4,,,,,"U_VldZEB()")
        If nOpcao == 1
            MsgInfo("CADASTRO ALTERADO.", "Atenção")
        EndIf
    EndIf
     
    RestArea(aArea1)
    RestArea(aArea)


Return

