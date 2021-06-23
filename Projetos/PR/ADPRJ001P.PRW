#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADPRJ001P º Autor ³ Mauricio - MDS TEC º Data ³  29/09/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa chamado por gatilho a partir da tabela AF8        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADPRJ001P(_cUN,_cAno,_cTipo,_cCod)

Local _cCodPrj := _cCod

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa chamado por gatilho a partir da tabela AF8 ')

If !Empty(_cUN) .And. Empty(_cAno) .And. Empty(_cTipo)
   _cCodPrj := _cUN
Elseif !Empty(_cUN) .And. !Empty(_cAno) .And. Empty(_cTipo)
   _cCodPrj := _cUN + _cAno   
Elseif !Empty(_cUN) .And. !Empty(_cAno) .And. !Empty(_cTipo)
   _cCodPrj := _cUN+_cAno+_cTipo
   
   If Select("TAF8") > 0
		DbSelectArea("TAF8")
		DbCloseArea("TAF8")
   Endif
	
   _cQuery  := "SELECT AF8_PROJET "
   _cQuery  += "FROM "+RetSqlName("AF8")+" F8 "
   _cQuery  += "WHERE F8.D_E_L_E_T_ <> '*'  AND SUBSTRING(F8.AF8_PROJET,1,6) = '"+_cCodPrj+"' "   
   _cQuery  += "ORDER BY AF8_PROJET DESC"
	
   TCQUERY _cQuery NEW ALIAS "TAF8"
   
   DBSELECTAREA("TAF8")
   DbGotop()
   _cProjet := ""
   While TAF8->(!Eof())
        _cProjet := Alltrim(TAF8->AF8_PROJET)
        exit
   Enddo     
   
   _cSeq := "001"
   If !Empty(_cProjet)
      _cSeq := Soma1(RIGHT(Alltrim(_cProjet),3))
   endif
   
   _cCodPrj := _cCodPrj+_cSeq
Else
   _cCodPrj := ""   
Endif

Return(_cCodPrj)
