#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ADFIN022P³ Rev.  ³ MAURICIO - MDS TEC    ³ Data ³ 01.11.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Liberacao de pedidos Pre Aprovados(SC5)        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADFIN022P()

Local aArea     := GetArea()
Local cFilSC5   := ""
Local cCondicao := ""
Local cCondBlk  := ""
Local aIndSC5   := {}
Local aCores    := {{"C5_XPREAPR=='L'",'ENABLE' },;		//Pedido Liberado
	{ "C5_XPREAPR=='B'",'DISABLE'}}	                	//Pedido bloqueado

Private bFiltraBrw := {|| Nil}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de Liberacao de pedidos Pre Aprovados(SC5)')

If VerSenha(136)

	Private cCadastro := "Pré liberação de Pedidos"
	Private aRotina   := MenuDef()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ So Ped. Bloqueados   mv_par01          Sim Nao               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PutSX1("ADF22P","01","Somente Bloqueados?","Somente Bloqueados?"	,"Somente Bloqueados?","mv_ch1"   ,"N",01,0,01,"C","","","","","mv_par01" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")
	PutSX1("ADF22P","02","Dt Entrega De "          ,"Dt Entrega De "      ,"Dt Entrega De "      ,"mv_ch2","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
	PutSX1("ADF22P","03","Dt Entrega Ate "         ,"Dt Entrega Ate "     ,"Dt Entrega Ate "     ,"mv_ch3","D",08,0,0,"G",""         ,"","","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
			
	If Pergunte("ADF22P",.T.)
	
	    If ( mv_par01 == 1 )
				cCondicao:='C5_FILIAL=="'+xFilial("SC5")+'" .And. Empty(C5_NOTA) .And. '
				cCondicao+='C5_XPREAPR=="B" .And. (DTOS(C5_DTENTR) >= "' + Dtos(MV_PAR02) + '" .and. DTOS(C5_DTENTR) <= "' + Dtos(MV_PAR03)  + '")'    //.And.'
		Else
				cCondicao:='C5_FILIAL=="'+xFilial("SC5")+'" .And. Empty(C5_NOTA) .And. '
				cCondicao+='(C5_XPREAPR=="L".Or.C5_XPREAPR=="B").And. (DTOS(C5_DTENTR) >= "' + Dtos(MV_PAR02) + '" .and. DTOS(C5_DTENTR) <= "' + Dtos(MV_PAR03)  + '")'  //.And.'
	    Endif
					
		bFiltraBrw := {|| FilBrowse("SC5",@aIndSC5,@cCondicao) }
		Eval(bFiltraBrw)
		
		dbSelectArea("SC5")
		mBrowse( 7, 4,20,74,"SC5",,,,,,aCores)
			
		dbSelectArea("SC5")
		RetIndex("SC5")
		dbClearFilter()
		aEval(aIndSc5,{|x| Ferase(x[1]+OrdBagExt())})
		RestArea(aArea)
	EndIf
	
Else
	HELP(" ",1,"SEMPERM")
Endif

Return(.T.)


Static Function MenuDef()

Private	aRotina := {	{"Pesquisar","PesqBrw"	, 0 , 1,0,.F.},;	// "Pesquisar"
                        {"Pre Aprova Rede","U_ADFIN024P", 0 , 0,0,NIL},;
                        {"Pre Aprova Varejo","U_ADFIN023P", 0 , 0,0,NIL},;
                        {"Legenda","U_ADF22PLG()", 0 , 3,0,.F.}}	// "Legenda" 
						//{STR0003,"A450LibAut", 0 , 0,0,NIL},;	// "Autom tica"
						//{STR0004,"A450LibMan", 0 , 0,0,NIL},;	// "Manual"					

Return(aRotina)


User Function ADF22PLG()
Local aLegenda := {}

U_ADINF009P('ADFIN022P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de Liberacao de pedidos Pre Aprovados(SC5)')

Aadd(aLegenda, {"ENABLE"    ,"Pre Aprovado"}) 
Aadd(aLegenda, {"DISABLE"   ,"Pre Bloqueado"})

BrwLegenda(cCadastro,"Legenda", aLegenda)

Return(.T.)