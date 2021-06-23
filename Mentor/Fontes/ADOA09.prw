#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADOA09    ºAutor  ³Ana Helena           º Data ³  14/01/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina com base na ADOA06, para alteração do campo vendedor º±±
±±º          ³na PB3, mesmo que não tenha os campos de vinculo do SA1     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADOA09()

Local aArea			:= GetArea()

Private cCadastro	:= "Cadastro de Clientes PB3"
Private cString		:= "PB3"

Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"		,0,1} ,;
							{"Visualizar"	,"U_AD09CLI"	,0,2} ,;
							{"Alterar"		,"U_AD09CLI"	,0,4}}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina com base na ADOA06, para alteração do campo vendedor na PB3, mesmo que não tenha os campos de vinculo do SA1')

dbSelectArea(cString)
dbSetOrder(1)
mBrowse( 6,1,22,75,cString)
RestArea( aArea )

Return Nil       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADOA06    ºAutor  ³Microsiga           º Data ³  03/26/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³manutenção em campo especificos no cadastro de clientes     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AD09Cli(cAlias, nRec, nOpc)

&&Mauricio - 25/04/2017 - chamado 034796 - incluido XVEND2 na tela e gravação

Local aCampos 	:= {'PB3_CODSA1', 'PB3_COD' , 'PB3_LOJA', 'PB3_CGC',;
                    'PB3_NOME', 'PB3_VEND', 'PB3_CODVEN', 'PB3_EMAICO',;
                    'PB3_TEL2','PB3_TEL3','PB3_TEL4','PB3_XTELCO',;
                    'PB3_XVEND2'}
                    
Local aAlter := {'PB3_VEND', 'PB3_CODVEN','PB3_XVEND2','PB3_EMAICO','PB3_TEL2',;
                 'PB3_TEL3','PB3_TEL4','PB3_XTELCO','PB3_CENTRA',;
                 'PB3_PROMOT'}  

U_ADINF009P('ADOA09' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina com base na ADOA06, para alteração do campo vendedor na PB3, mesmo que não tenha os campos de vinculo do SA1')
                                                          

// ***** INICIO CHAMADO 024256 - WILLIAM COSTA - LIBERA O CAMPO PB3_REGCOB PARA GERENTE DE VENDAS 
SqlGerenteVendas()
While TRB->(!EOF())
    				
	IF TRB->PB1_NIVEL = '3'
	
		AADD(aAlter,"PB3_REGCOB")  
	
	ENDIF
       	
	TRB->(dbSkip())
ENDDO
TRB->(dbCloseArea())                     
                    
// ***** FINAL CHAMADO 024256 - WILLIAM COSTA - LIBERA O CAMPO PB3_REGCOB PARA GERENTE DE VENDAS 

if nOpc = 3 // Alterar
	AxAltera(cAlias  , nRec  , nOpc  , aCampos, aAlter ,           ,            ,          , 'U_ATUPB309' ) 
else 
	AxVisual(cAlias, nRec, nOpc, aCampos)
endif	                 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_ATUPB3  ºAutor  ³Alexandre Circenis  º Data ³  04/28/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Atualiza Pb3 com os dados Alterados                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AtuPB309()

Local aArea := GetArea()
Local cVend := M->PB3_VEND
Local cCodVen   := Posicione("SA3",7,xFilial("SA3")+M->PB3_VEND, "A3_COD")
Local cChavePB3 := M->PB3_COD+M->PB3_LOJA
Local _cVend2   := M->PB3_XVEND2

U_ADINF009P('ADOA09' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina com base na ADOA06, para alteração do campo vendedor na PB3, mesmo que não tenha os campos de vinculo do SA1')

dbSelectArea("PB3")
dbSetOrder(1)
If dbSeek(xFilial("PB3")+cChavePB3)
	RecLock("PB3",.F.)
	PB3->PB3_VEND   := cVend    //ID
	PB3->PB3_CODVEN := cCodVen  //Codido de vendedor
	PB3->PB3_XVEND2 := _cVend2  &&Mauricio - 25/04/2017 - chamado 034796
	msUnlock()
Endif
dbSetOrder(1)
	                            
RestArea(aArea)

Return 


Static Function SqlGerenteVendas()                          

	BeginSQL Alias "TRB"
			%NoPARSER%   
			SELECT PB1_NIVEL FROM %Table:PB1%
	         WHERE PB1_CODIGO  = %EXP:__cUserID%
               AND D_E_L_E_T_ <> '*'
			
	EndSQl             
RETURN(NIL) 