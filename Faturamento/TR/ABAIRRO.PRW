#include "rwmake.ch"

User Function ABAIRRO()    

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Informar BAIRRO para aglutinar Roteiro de entrega')

SetPrvt("_CALIAS,_NINDEX,_NRECNO")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ABAIRRO  ³ Autor ³ Marcos Bido           ³ Data ³ 20/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Informar BAIRRO para aglutinar Roteiro de entrega          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ABAIRRO Sub-Funcao de AltRote                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda ambiente inicial                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAlias := Alias()
_nIndex := IndexOrd()
_nRecno := Recno()
                                                        

_cRote  := SC5->C5_ROTEIRO
_cBair  := SC5->C5_BAIRRO
_cCida  := SC5->C5_CIDADE  

@ 00,000 TO 250,450 DIALOG oDlg1 TITLE "AGLUTINAR BAIRRO A ROTEIRO "

@ 10,050 TO 87,180 TITLE "Dados do Roteiro "

@ 35,065 SAY " BAIRRO  " 
@ 55,065 SAY " ROTEIRO " 

@ 35,100 GET _cBair Valid !Vazio()
@ 55,100 GET _cRote Valid !Vazio()

@ 100,100 BMPBUTTON TYPE 01 ACTION GravaBAIRRO()
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

Static Function GravaBAIRRO()

_cSequ := 5

dbSelectArea("SC5")
        dbSetorder(01)
dbGotop()

Do While !eof()

        If C5_BAIRRO+C5_CIDADE == _cBair+_cCida

                RecLock("SC5",.F.)
                Replace C5_ROTEIRO With _cRote
                Replace C5_SEQUENC With StrZero(_cSequ,2)
                MsUnlock()
                _cSequ := _cSequ + 5
                _cPedido := C5_NUM

                dbSelectArea("SC6")
                dbSetOrder(1)
                if dbSeek( xFilial("SC6")+_cPedido )
                        Do While !Eof() .and. SC6->C6_FILIAL==xFilial("SC6") .and. SC6->C6_NUM =_cPedido
                                RecLock("SC6",.F.)
                                Replace C6_ROTEIRO With _cRote
                                Replace C6_ROTEIRO With _cRote
                                MsUnlock()
                                dbSkip()
                        Enddo
                Endif
                
                //grava log/alteracao de bairro	
                u_GrLogZBE (Date(),TIME(),cUserName,"ROTINA PARA AGLUTINAR ROTEIRO DE ENTREGA /BAIRRO ","LOGISTICA","ABAIRRO",;
                	       "PEDIDO: "+SC5->C5_NUM+" ROTEIRO: "+_cRote+" BAIRRO: "+_cBair+_cCida,;
                	       ComputerName(),LogUserName())  
        Endif

 
        DbSelectArea("SC5")
        DbSkip()
        
Enddo

DbSelectArea("SC5")
DbSetOrder(07)

Close(oDlg1)


Return

