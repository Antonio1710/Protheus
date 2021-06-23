#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Avende   ³ Autor ³ Marcos Bido           ³ Data ³ 20/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informar vendedor para aglutinar Roteiro de entrega        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Avende Sub-Funcao de AltRote                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Avende()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Informar vendedor para aglutinar Roteiro de entrega')

SetPrvt("_CALIAS,_NINDEX,_NRECNO")
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda ambiente inicial                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_cAlias := Alias()
_nIndex := IndexOrd()
_nRecno := Recno()
_cRote  := SC5->C5_ROTEIRO
_cVend  := SC5->C5_ROTEIRO

@ 00,000 TO 250,450 DIALOG oDlg1 TITLE "AGLUTINAR VENDEDOR AO ROTEIRO "
@ 10,050 TO 87,180 TITLE "Dados do Roteiro : "

@ 35,070 SAY " DE      " 
@ 55,070 SAY " PARA    " 

@ 35,100 GET _cVend // Valid Vazio()
@ 55,100 GET _cRote // Valid !Vazio()

@ 100,100 BMPBUTTON TYPE 01 ACTION Gravavende()
@ 100,130 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
ACTIVATE DIALOG oDlg1 CENTER

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente inicial                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(_cAlias)
dbSetOrder(_nIndex)
dbGoto(_nRecno)

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function Gravavende()

//If MsgYesNo("Confirma a Associacao do Vendedor ao Roteiro ")

dbSelectArea("SC5")
dbSetOrder(01)
dbGotop()

Do While !eof()
	if C5_ROTEIRO == _cVend
		RecLock("SC5",.F.)
		Replace C5_ROTEIRO   With _cRote
		MsUnlock()
	Endif
	dbSkip()
Enddo


dbSelectArea("SC5")
//dbSetOrder(6)
SC5->(DBORDERNICKNAME("SC5_6")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
//dbSetOrder(7)
SC5->(DBORDERNICKNAME("SC5_7")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
_cSequ    := 5

dbSeek( xFilial("SC5")+_cRote ,.T. )

Do While !Eof() .and. SC5->C5_FILIAL==xFilial("SC5") .and. SC5->C5_ROTEIRO==_cRote
	
	RecLock("SC5",.F.)
	Replace C5_SEQUENC With StrZero(_cSequ,2)
	MsUnlock()
	_cSequ := _cSequ + 5
	_cPedido := C5_NUM
	
	dbSelectArea("SC6")
	if dbSeek( xFilial("SC6")+_cPedido )
		Do While !Eof() .and. SC6->C6_FILIAL==xFilial("SC6") .and. SC6->C6_NUM =_cPedido
			RecLock("SC6",.F.)
			Replace C6_ROTEIRO With _cRote
			Replace C6_ROTEIRO With _cRote
			MsUnlock()
			dbSkip()
		Enddo
		
	Endif
	
	//---------------------------------------------------------
   // Altera roteiro no arquivo de pedidos liberados ( SC9 ) 
   // HC CONSYS - 03/02/2009 
 	//---------------------------------------------------------
 	dbSelectArea("SC9") 
 	dbSetOrder(1)
	if dbSeek( xFilial("SC9")+_cPedido )
		do While !Eof() .and. SC9->C9_FILIAL==xFilial("SC9") .and. SC9->C9_PEDIDO =_cPedido
			RecLock("SC9",.F.)
			Replace C9_ROTEIRO With _cRote
			MsUnlock()
			dbSkip()
		enddo
	endif
 	
 	//grava log/alteracao de bairro	
 	u_GrLogZBE (Date(),TIME(),cUserName," AGLUTINA VENDEDOR ROTEIRO ENTREGA","LOGISTICA","AD0055",;
         	"PEDIDO: "+SC5->C5_NUM+" ROTEIRO/SEQ DE: "+SC5->C5_ROTEIRO+" "+SC5->C5_SEQUENC+" PARA: "+_cRote+" "+_cSequ,;
         	ComputerName(),LogUserName()) 
 	
 	
	dbSelectArea("SC5")
	dbskip()
Enddo

//dbSetOrder(06)
SC5->(DBORDERNICKNAME("SC5_6")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032

Close(oDlg1)

Return