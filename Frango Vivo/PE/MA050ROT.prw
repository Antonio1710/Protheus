#include "PROTHEUS.CH"
#include "rwmake.ch"  
#include "topconn.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA050ROT  º Autor ³Fernando Sigoli       Data ³  02/07/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se e grava log de campos alterados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO  - Chamado:029467                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MA050ROT()

Local ARotUser := {}  

//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Verifica se e grava log de campos alterados')


aAdd(ARotUser , { '* LOGS','U_SA4LOG', 0 , 2} )

Return ARotUser


//rotina de log
User Function SA4LOG()

Local aArea		:= GetArea()
Local oDlg
Local Query     := ""
Local nx 		:= 0
Local aSize    	:= MsAdvSize()
Local aPosObj  	:= {}
Local aObjects 	:= {}
Local aInfo		:= {}
Local aCpos		:= {}
Local nOpcao	:= 0
Local aListBox	:= {}
Local oTik		:= LoadBitMap(GetResources(), 'LBTIK')
Local oNo		:= LoadBitMap(GetResources(), 'LBNO' )
Local oMarca	:= LoadBitMap(GetResources(), 's4wb018n.png')
Local cCampos 	:= ''

Private aTela	[0][0]
Private aGets	[0]

memowrite("\LOGRDM\"+ALLTRIM(PROCNAME())+".LOG",Dtoc(date()) + " - " + time() + " - " +alltrim(cusername)) // Everson - 17/07/2017. Chamado 036032.

//Tamanho da tela
aObjects := {}
aAdd( aObjects, { 100,  20, .t., .f. } )
aAdd( aObjects, { 100,  80, .t., .t. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )


Query := " SELECT ZBE_DATA,ZBE_HORA,ZBE_USUARI,ZBE_LOG,ZBE_PARAME FROM "+retsqlname("ZBE")+" ZBE WHERE ZBE_ROTINA = 'M050TOK' and ZBE_PARAME LIKE '%"+SA4->A4_COD+"%'   ORDER BY ZBE.ZBE_DATA DESC, ZBE.ZBE_HORA DESC  "
TCQUERY Query new alias "LOG1"    

// Adiciona elementos ao Array da ListBox
LOG1->(dbgotop())
While !EOF()  
	aAdd( aListBox,{ LOG1->ZBE_USUARI, LOG1->ZBE_DATA, LOG1->ZBE_HORA, LOG1->ZBE_LOG,  })
DbSkip()
End  

DbCloseArea("LOG1")
   
If Empty( aListBox )

	Alert( 'Nenhuma ocorrencia de Log para a transportadora' )

Else

	
	DEFINE MSDIALOG oDlg TITLE "Histórico/Log" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
	
	@ 010,10 Say 'Veiculo: '+Alltrim(SA4->A4_NOME) SIZE 200,15 OF oDlg PIXEL
	
	@ aPosObj[2,1],aPosObj[2,2] ListBox oListBox Fields HEADER "Usuario", "Data", "Hora", "LOG/Alteracao";
	Size aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] Of oDlg Pixel ColSizes 50,50,50,70,100
	
	oListBox:SetArray(aListBox)
	
	oListBox:bLine := {|| {	aListBox[oListBox:nAT,01], DTOC(STOD(aListBox[oListBox:nAT,02])) ,aListBox[oListBox:nAT,03], aListBox[oListBox:nAT,04]}}
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, If( Obrigatorio( aGets, aTela) ,oDlg:End(),Nil)},{||nOpcao:=0,oDlg:End()},.F.,)

Endif

RestArea( aArea )

Return Nil 
