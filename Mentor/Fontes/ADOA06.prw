#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} User Function ³ADOA06
	Interface de alteração de dados do cliente.
	@type  Function
	@author Microsiga
	@since 03/26/2010
	@history Ticket 49882 || OS 051171 || FINANCAS || ANDREA || 8319 || PB3 X SZF - WILLIAM COSTA 18/06/2019 - Campo PB3_CODRED Salvando errado onde salvava o campo A1_REDE o correto e o A1_CODRED.
	@history Ticket T.I - Fernando Sigoli - 04/05/2019 Adicionado novos campos 'A1_XSFLFDS' ,'A1_XPALETE'.
	@history Ticket T.I - Leonardo P. Monteiro - 10/02/2021 - Correção na gravação do campo A1_DESC para A1_ZZDESCB.
/*/

User Function ADOA06()

Local aArea			:= GetArea()
Private cCadastro	:= "Cadastro de Clientes"
Private cString		:= "SA1"
Private aRotina		:= {{"Pesquisar"	,"AxPesqui"		,0,1} ,;
				        {"Visualizar"	,"U_AD06CLI"	,0,2} ,;
						{"Alterar"		,"U_AD06CLI"	,0,4}}
                                                                                                                                                         
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Interface de alteração de dados do cliente ')

DbSelectArea(cString)
DbSetOrder(1)
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
User Function AD06Cli(cAlias, nRec, nOpc)

Local aCampos 	:= {'NOUSER', 'A1_COD', 'A1_NOME' , 'A1_SATIV1', 'A1_SATIV2','A1_ULTCOM',;
                    'A1_VEND', 'A1_GRPVEN', 'A1_TABELA', 'A1_REDE', 'A1_DESC',;
                    'A1_DDD','A1_DDI','A1_TEL','A1_TEL1','A1_FAX','A1_CONTATO','A1_EMAIL',;
                    'A1_SHELFLF','A1_PERSHEL','A1_PALLETZ','A1_TEL2','A1_TEL3','A1_TEL4',;
                    'A1_TEL5','A1_TEL6','A1_XVEND2','A1_XSFLFDS' ,'A1_XPALETE'}			   //Chamado: T.I - Fernando Sigoli 04/05/2019


Local aAlter := {'A1_SATIV1', 'A1_SATIV2','A1_VEND','A1_XVEND2', 'A1_GRPVEN', 'A1_TABELA',;
                 'A1_REDE', 'A1_DESC','A1_DDD','A1_DDI','A1_TEL','A1_TEL1','A1_FAX',;
                 'A1_CONTATO','A1_EMAIL','A1_SHELFLF','A1_PERSHEL','A1_PALLETZ','A1_TEL2',;
                 'A1_TEL3','A1_TEL4','A1_TEL5','A1_TEL6','A1_XSFLFDS' ,'A1_XPALETE' }       //Chamado: T.I - Fernando Sigoli 04/05/2019	

U_ADINF009P('ADOA06' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Interface de alteração de dados do cliente ')				 

If nOpc = 3 // Alterar
	AxAltera(cAlias  , nRec  , nOpc  , aCampos, aAlter ,           ,            ,          , 'U_ATUPB3' ) 
Else 
	AxVisual(cAlias, nRec, nOpc, aCampos)
Endif	                 

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

User Function AtuPB3()

Local aArea := GetArea()
Local cVend := Posicione("SA3",1,xFilial("SA3")+M->A1_VEND, "A3_CODUSR")

U_ADINF009P('ADOA06' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Interface de alteração de dados do cliente ')

DbSelectArea("PB3")
DbSetOrder(11)
If dbSeek(xFilial("PB3")+M->A1_COD+M->A1_LOJA)
	RecLock("PB3",.F.)

	PB3->PB3_VEND   := cVend
	PB3->PB3_CODVEN := M->A1_VEND
	PB3->PB3_XVEND2 := M->A1_XVEND2
	PB3->PB3_SEGTO  := M->A1_SATIV1
	PB3->PB3_SUBSEG := M->A1_SATIV2
	PB3->PB3_TABELA := M->A1_TABELA
	PB3->PB3_GRPVEN := M->A1_GRPVEN
	PB3->PB3_CODRED := M->A1_CODRED  // William Costa 18/06/2019 049882 || OS 051171 || FINANCAS || ANDREA || 8319 || PB3 X SZF
	//PB3->PB3_DESC   := M->A1_DESC // Leonardo P. Monteiro - 10/02/2021 - Correção na gravação do campo A1_DESC para A1_ZZDESCB.
	PB3->PB3_DDD    := M->A1_DDD
	PB3->PB3_DDI    := M->A1_DDI
	PB3->PB3_TEL    := M->A1_DDD+M->A1_TEL
	PB3->PB3_FAX    := M->A1_DDD+M->A1_FAX
	PB3->PB3_CONTAT := M->A1_CONTATO
	PB3->PB3_EMAIL  := M->A1_EMAIL	
	msUnlock()
Endif
DbSetOrder(1)
	
RestArea(aArea)

Return
