#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LSAFAT06  º Autor ³ HC CONSYS          º Data ³  30/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MBrowse principal Compensacao de Comissao                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LSAFAT06()

Private cCadastro := "Controle de Comissôes"


Private aRotina := { 	{"Pesquisar"			,"AxPesqui"		,0,1} ,;
						{"Compensação"			,"U_LSAFAT6A()"	,0,2} }

Private cDelFunc := ".T." && Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SA3"

U_ADINF009P('ADAFIN06' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MBrowse principal Compensacao de Comissao ')

dbSelectArea("SA3")
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return()                                       


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LSAFAT6A  º Autor ³ HC CONSYS          º Data ³  30/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamada da Modelo2()						                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8		                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LSAFAT6A()

Local lRet			:= .T.
Local aArea			:= GetArea()

Private aHeader		:= {}
Private aCols		:= {}
Private nOpcx		:= 6							   						&& 3 e 4 Permitem alterar e incluir Linhas, 
Private nUsado		:= 0                                					&& 6 permite alterar e nao inclui linhas, qq. outro so visualiza
Private cCond		:= "E1_PREFIXO/E1_NUM/E1_PARCELA/E1_VENCTO/E1_VALOR"	&& Campo que fazem parte do Aheader da Modelo2()
Private cVendedor 	:= SA3->A3_COD											&& Cabecalho da Modelo2()
Private cNome    	:= SA3->A3_NOME											&& Cabecalho da Modelo2()
Private nLinGetD	:= 0													&& Variavel do Rodape da Modelo2()
Private cTitulo		:= "Compensação do Representante"						&& Titulo da Janela da Modelo2()
Private aC			:= fCabec()												&& Retorna array com a Descricao dos Campos do Cabecalo Modelo2()
Private aR			:= fRodape()											&& Array com descricao dos campos do Rodape da Modelo2()
Private aCGD		:= {50,3,135,315}										&& Array com coordenadas da Getdados Modelo2()
Private cLinhaOk	:= "ExecBlock('fl06OK',.f.,.f.)" 						&& Funcao para validacao dos dados da linha da Modelo2()
Private cTudoOK		:= "ExecBlock('fT06OK',.f.,.f.)" 						&& Funcao para validacao de toda a Modelo2()
Private lRetMod2	:= .T.													&& Utilizada para validar retorno da Getdados

U_ADINF009P('ADAFIN06' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MBrowse principal Compensacao de Comissao ')

fMonta()																	&& Monta estrutura Aheader e preenche o Acols.

dbSelectArea("SA3")

lRetMod2:= 	Modelo2( cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,{100,100,370,735} )

If lRetMod2		&& Testa o resultado do Retorno da Modelo2()
    /* 			&& Executa processamento valido
	For i:=1 To Len(aCols)

		If aCols[i][Len(aHeader)+1] == .F.		// aCols[i , 1]

		EndIf
    Next i
    */
    
Endif


RestArea(aArea)
Return()


/* Funcao que retorna Array com o Cabecalho da Modelo2() */
Static Function fCabec()
Local aRet	:= {}

&& Composicao do Array 
&& aC[n,1] = Nome da Variavel Ex.:"cCliente"
&& aC[n,2] = Array com coordenadas do Get [x,y] em Pixel
&& aC[n,3] = Titulo do Campo
&& aC[n,4] = Picture
&& aC[n,5] = Validacao
&& aC[n,6] = F3
&& aC[n,7] = Se campo e' editavel .T. ou .F.

AADD( aRet,{"cVendedor"	, {020,002}  ,"Codigo"   ,"@!",	,	,.F.} )
AADD( aRet,{"cNome"		, {020,065}  ,"Vendedor"	,"@!",	,	,.F.} ) 

Return(aRet)

/* Funcao para Criar/Carregar aHeader/aCols */

Static Function fMonta() 

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SE1")

While !Eof() .And. (x3_arquivo == "SE1")
	If ALLTRIM(X3_CAMPO) $ cCond

		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
	    	nUsado:=nUsado+1
	        AADD(aHeader,{ Trim(x3_titulo), x3_campo, x3_picture,;
	            	x3_tamanho, x3_decimal,,;
	        	   	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	        	   	
	    Endif

    Endif
    
    dbSkip()

Enddo

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SE1")
While !Eof() .And. (x3_arquivo == "SE1")
	If ALLTRIM(X3_CAMPO) $ "E1_VALOR"

		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
	    	nUsado:=nUsado+1
	        AADD(aHeader,{ "Valor a Debitar", x3_campo, x3_picture,;
	            	x3_tamanho, x3_decimal,,;
	        	   	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	        	   	
	    Endif

    Endif
    
    dbSkip()

Enddo        

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SE1")

While !Eof() .And. (x3_arquivo == "SE1")
	If ALLTRIM(X3_CAMPO) $ "E1_VALOR"

		If X3USO(x3_usado) .AND. cNivel >= x3_nivel
	    	nUsado:=nUsado+1
	        AADD(aHeader,{ "Valor a Creditar", x3_campo, x3_picture,;
	            	x3_tamanho, x3_decimal,,;
	        	   	x3_usado, x3_tipo, x3_arquivo, x3_context } )
	        	   	
	    Endif

    Endif
    
    dbSkip()

Enddo
 
cQuery := "SELECT E1_PREFIXO,E1_NUM,E1_PARCELA,E1_VENCTO,E1_VALOR FROM " + RETSQLNAME("SE1") + "  "
cQuery += "WHERE D_E_L_E_T_ = ' ' AND E1_FILIAL = '" + XFILIAL("SE1") + "' AND " 
cQuery += "(E1_VEND1 = '" + SA3->A3_COD + "' OR E1_VEND2 = '" + SA3->A3_COD + "' OR E1_VEND3 = '" + SA3->A3_COD + "' OR E1_VEND4 = '" + SA3->A3_COD + "' OR E1_VEND5 = '" + SA3->A3_COD + "' ) "
cQuery += "ORDER BY E1_PREFIXO,E1_NUM,E1_PARCELA "

TcQuery cQuery New Alias "TSE1" 
TCSetField("TSE1","E1_VENCTO","D") 	      

TSE1->(dbGoTop())

While TSE1->(!Eof())				&& Preenche aCols

	aAux	:= {}					&& Array temporario

	AAdd(aAux, TSE1->E1_PREFIXO)	&& Prefixo
	AAdd(aAux, TSE1->E1_NUM)		&& Numero
	AAdd(aAux, TSE1->E1_PARCELA)	&& Parcela
	AAdd(aAux, TSE1->E1_VENCTO)		&& Vencimento
	AAdd(aAux, TSE1->E1_VALOR)		&& Valor
	AAdd(aAux, 0)					&& Debito
	AAdd(aAux, 0)					&& Credito
	AAdd(aAux, .F.)					&& Indica que o registro nao foi deletado
	AAdd(aCols, aAux)       		&& incrementa Acols
	
	TSE1->(DbSkip())

EndDo

TSE1->(dbCloseArea())

Return()

/* Funcao que retorna Array com descricao dos campos do Rodape do Modelo2()  */
Static Function fRodape()
Local aRet	:= {}

&& aRet[n,1] = Nome da Variavel Ex.:"cCliente"
&& aRet[n,2] = Array com coordenadas do Get [x,y] em PIXEL
&& aRet[n,3] = Titulo do Campo
&& aRet[n,4] = Picture
&& aRet[n,5] = Validacao
&& aRet[n,6] = F3
&& aRet[n,7] = Se campo e' editavel .t. se nao .f.
&&	AADD(aR,{"nLinGetD"	,{120,10},"Linha na GetDados"	,"@E 999",,,.F.})

Return(aRet)          


/* Funcao para validacao da Linha */
User Function fl06OK()
Local lRet	:= .T.

U_ADINF009P('ADAFIN06' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MBrowse principal Compensacao de Comissao ')

Return(lRet)

/* Funcao para validacao da Getdados() */
User Function fT06OK()

Local lRet	:= .T.

U_ADINF009P('ADAFIN06' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'MBrowse principal Compensacao de Comissao ')

Return(lRet)