#INCLUDE "rwmake.ch"


/*/{Protheus.doc} User Function ADLOG073P
	(Cadastro de Manobristas para a Logistica)
	@type  Function
	@author ADRIANO SAVOINE
	@since 25/03/2021
	@version 01
	@history Ticket: 11427 - 25/03/2021 - ADRIANO SAVOINE - Solicitado pela Logistica para utilizar nas pesagens os manobristas entre DIMEP x Edata.
	@history Ticket: T.I.  - 10/06/2021 - LEONARDO MONTEIRO - Ajuste na altera��o do registro que estava posicionando no primeiro registro.
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
    nOpca := AxInclui("ZEB",ZEB->(Recno()), 3,,"u_CARREZEB()",,,.T.,,,,,,.T.,,,.T.,,)

Return 


USER Function CARREZEB()


Local cQuery := ""
   

    cQuery := "SELECT MAX ((ZEB.ZEB_CODIGO) + 1)MX FROM "+RetSqlName("ZEB")+" ZEB, WHERE  ZEB.D_E_L_E_T_ = '' AND ZEB.ZEB_FILIAL = "+xFilial("ZEB")+" 
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
    //@history Ticket: T.I.  - 10/06/2021 - LEONARDO MONTEIRO - Ajuste na altera��o do registro que estava posicionando no primeiro registro.
	//ZEB->(DbGoTop())
     
    //Se conseguir posicionar no produto
    If ZEB->(DbSeek(FWxFilial('ZEB') + ZEB->ZEB_CODIGO))
        nOpcao := AxAltera('ZEB', ZEB->(RecNo()), 4)
        If nOpcao == 1
            MsgInfo("CADASTRO ALTERADO.", "Aten��o")
        EndIf
    EndIf
     
    RestArea(aArea1)
    RestArea(aArea)


Return

