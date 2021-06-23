#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADGPEE17 ºAutor  ³Microsiga           º Data ³  04/16/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera Desconto de Emprestimos no Calculo das Ferias.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADGPEE17()

 Local aOld    := GETAREA()
 Local nSrcOrd := SRC->(IndexOrd())
 Local nSrcRec := SRC->(Recno())
 Local nValor  := 0
 Local cIniFer := MesAno( M->RH_DATAINI )
 Local nMesSeg := Val( cIniFer ) - Val( cFolMes )
 
 U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera Desconto de Emprestimos no Calculo das Ferias.')
 
 dbSelectArea( "SRC" )
 dbSetOrder( 1 )
 dbSeek( SRA->(RA_FILIAL + RA_MAT) + "446" )
 Do While !Eof() .And. SRC->(RC_FILIAL + RC_MAT + RC_PD) == SRA->(RA_FILIAL + RA_MAT) + "446"
    If SRC->RC_PARCELA > 0
       If SRC->RC_PARCELA <= nMesSeg
          dbSkip()
          Loop
       EndIf
    EndIf
    
    nValor += SRC->RC_VALOR
    
    dbSkip()
 EndDo

 If nValor > 0
    fGeraVerba("446",nValor,,,,,,,,,.T.)
 EndIf

 SRC->(dbSetOrder( nSrcOrd ))
 SRC->(dbGoTo( nSrcRec ))
 RESTAREA( aOld )

Return( "" )
