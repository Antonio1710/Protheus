#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GP650CPO ºAutor  ³ Adilson Silva      º Data ³ 30/09/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Determinar os Dados das Pensionistas no Titulo.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP11                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GP650CPO()

 Local aOldAtu   := GETAREA()
 Local aOldRc0   := RC0->(GETAREA())
 Local aOldSra   := SRA->(GETAREA())
 Local cAliasAtu := Alias()
 Local cTemp     := ""
 Local cVerbas   := ""
 Local cQuery    := ""
 Local nSrqRec   := 0
 Local cChvFil   := ""
 Local cChvMat   := ""
 Local aDados    := Afill(Array( 08 ),"")
 Local nX
 
 aDados[08] := .F.	// Controle para Identificar se Encontrou a Beneficiaria
 
 RC0->(dbSetOrder( 1 ))
 If RC0->(dbSeek( xFilial("RC0") + RC1->RC1_CODTIT ))
    If RC0->RC0_TPTIT == "1"	// Pensao Alimenticia
       cTemp := Alltrim( RC0->RC0_VERBAS )
       For nX := 1 To Len( cTemp ) Step 4
           cVerbas += "'" + SubStr(cTemp,nX,3) + "',"
       Next nX
       cVerbas := Left(cVerbas,Len(cVerbas)-1)

       // Testa a Existencia dos Campos
       If &( RC0->RC0_ALIAS+"->(FieldPos(cFilLan))" ) > 0 .And. &( RC0->RC0_ALIAS+"->(FieldPos(cMatLan))" ) > 0
          // Determina a Chave do Funcionario
          cChvFil := &( RC0->RC0_ALIAS + "->" + cFilLan )
          cChvMat := &( RC0->RC0_ALIAS + "->" + cMatLan )

          // Query para Buscar o Beneficiario
          cQuery := " SELECT SRQ.R_E_C_N_O_ AS RQ_RECNO"
          cQuery += " FROM " + RetSqlName( "SRQ" ) + " SRQ"
          cQuery += " WHERE SRQ.D_E_L_E_T_ <> '*'"
          cQuery += "   AND SRQ.RQ_FILIAL = '" + cChvFil + "'"
          cQuery += "   AND SRQ.RQ_MAT = '" + cChvMat + "'"
          cQuery += "   AND SRQ.RQ_SEQUENC = '01'"
          cQuery += "   AND (    SRQ.RQ_VERBADT IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERBFOL IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERBFER IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERB131 IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERB132 IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERBPLR IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERBDFE IN (" + cVerbas + ")"
          cQuery += "         OR SRQ.RQ_VERBRRA IN (" + cVerbas + ")"
          cQuery += "       )"
          TCQuery cQuery New Alias "WSRQ"
          TcSetField( "WSRQ" , "RQ_RECNO"  , "N", 10, 0 )
          dbSelectArea( "WSRQ" )
          If !Eof() .And. !Bof()
             nSrqRec := WSRQ->RQ_RECNO
          EndIf
          WSRQ->(dbCloseArea())
          dbSelectArea( cAliasAtu )
          If nSrqRec > 0
             SRQ->(dbGoTo( nSrqRec ))
             aDados[01] := SRQ->RQ_NOME
             aDados[02] := Substr(SRQ->RQ_BCDEPBE,1,3)
             aDados[03] := Substr(SRQ->RQ_BCDEPBE,4,4)
             aDados[04] := Substr(SRQ->RQ_BCDEPBE,8,1)
             aDados[05] := Alltrim(SRQ->RQ_CTDEPBE)
             aDados[06] := Alltrim(SRQ->RQ_DIGCTA)
             aDados[07] := SRQ->RQ_CIC
             aDados[08] := .T.
          EndIf
       EndIf      
       // Se Encontrou a Beneficiaria Grava os Dados no RC1
       If aDados[08]
          RC1->RC1_NOMCTA := aDados[01]				// - 30 - RC1_NOMCTA - Nome Benefic
          RC1->RC1_BANCO  := aDados[02]				// - 3  - RC1_BANCO  - Banco
          RC1->RC1_AGEN   := aDados[03] 			// - 5  - RC1_AGEN   - Agencia
          RC1->RC1_DIGAG  := aDados[04] 			// - 1  - RC1_DIGAG  - Digito Agenc
          RC1->RC1_NOCTA  := aDados[05]				// - 13 - RC1_NOCTA  - Conta Corren
          RC1->RC1_DIGCTA := aDados[06]				// - 2  - RC1_DIGCTA - Digito Conta
          RC1->RC1_CNPJ   := aDados[07]				// - 14 - RC1_CNPJ   - CNPJ/CPF
       EndIf
    EndIf
 EndIf
 
 RESTAREA( aOldSra )
 RESTAREA( aOldRc0 )
 RESTAREA( aOldAtu )

Return
