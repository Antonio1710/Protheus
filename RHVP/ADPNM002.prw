#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#DEFINE          cEol         CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADPNM002 บAutor  ณ Adilson Silva      บ Data ณ 01/04/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Acerto das Marcacoes Impares na Tabela SP8.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADPNM002()

 Local bProcesso  := {|oSelf| fProcessa( oSelf )}

 Private cCadastro  := "Acerto de Marca็๕es อmpares"
 Private cPerg      := "ADPNM002"
 Private cDescricao
 
 U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para Acerto das Marcacoes Impares na Tabela SP8.')

 fAsrPerg()
 Pergunte(cPerg,.F.)
 
 cDescricao := "Rotina para ajustar as marca็๕es ํmpares na tabela do   " + Chr(13) + Chr(10)
 cDescricao += "movimento aberto (SP8). Serใo acrescentadas marca็๕es   " + Chr(13) + Chr(10)
 cDescricao += "conforme o horแrio padrใo, complementando em 1 minuto.  "

 tNewProcess():New( "SRA" , cCadastro , bProcesso , cDescricao , cPerg,,,,,.T.,.f.  ) 	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ACPONM90 บAutor  ณMicrosiga           บ Data ณ  10/05/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fProcessa( oSelf )

Local cSeqTurn   := ""
Local aTurnos    := {}
Local cTurno     := ""
Local aTabPadrao := {}
Local aTabCalend := {}
Local aMarcacoes := {}
Local aImpares   := {}
Local aNewMarc   := {}
Local nPosCalend := 0
Local nPosMarca  := 0
Local nContad    := 0
Local cOrdemAnt  := ""
Local nTotFunc   := 0
Local nTotMarc   := 0
Local lNewMarc   := .F.
Local lRet
Local nX

Private dPerDe, dPerAte
Private nHdl

Pergunte(cPerg,.F.)
 dPerDe   := mv_par01
 dPerAte  := mv_par02
 
//-- Carga da tabela de horario padrao
MsAguarde( {|| lRet := fTabTurno(aTabPadrao)}, "Processando...", "Carga das Tabelas de Horแrio Padrใo..." )
If !lRet
   Return
EndIf

dbSelectArea( "SRA" )
dbSetOrder( 1 )
dbGoTop()
//dbSeek( "01000934" )
oSelf:SetRegua1( RecCount() )
Do While !Eof() 	//.And. SRA->(RA_FILIAL + RA_MAT) == "01000934"
   oSelf:IncRegua1( SRA->(RA_FILIAL + " - " + RA_MAT + " - " + RA_NOME) )
   
   cTurno   := ""
   cSeqTurn := ""
   //-- Chamada a fTrocaTno() para identificar o turno correto a ser passado para retseq.
   fTrocaTno(dPerDe, dPerAte, @aTurnos)
   cSeqTurn := SRA->RA_SEQTURN
   cTurno   := If(Len(aTurnos)==0,SRA->RA_TNOTRAB,aTurnos[1,1])
   
   //-- Monta calendario com horarios de trabalho
   If !CriaCalend( dPerDe,dPerAte,cTurno,cSeqTurn,aTabPadrao,@aTabCalend,SRA->RA_FILIAL,SRA->RA_MAT,SRA->RA_CC,@aTurnos,NIL,NIL,.F.)
      dbSelectArea( "SRA" )
      dbSkip()
      Loop
   EndIf
   
   GetMarcacoes(@aMarcacoes, @aTabCalend, @aTabPadrao, 	@aTurnos, dPerDe, dPerAte, SRA->RA_FILIAL, 	SRA->RA_MAT, Nil, Nil, SRA->RA_CC, "SP8", Nil, .T., .T., .F.)
  
   lNewMarc := .F.
   If Len( aMarcacoes ) > 0
      nContad := 1
      cOrdemAnt := aMarcacoes[1,3]
      For nX := 2 To Len( aMarcacoes )
          If aMarcacoes[nX,3] <> cOrdemAnt //.Or. nX == Len( aMarcacoes )
             If ( nContad % 2 ) > 0
                aImpares := {}
                aNewMarc := {}
                Aeval(aMarcacoes,{|x| If(x[3]==cOrdemAnt,Aadd(aImpares,x),"")})
                fAcertaMarc(@aImpares, @aNewMarc, aTabCalend, cOrdemAnt)
                Aeval(aNewMarc,{|x| Aadd(aImpares,aClone(x))})
                Asort(aImpares,,,{|x,y| Dtos(x[1])+x[12] < Dtos(y[1])+y[12]})

                lNewMarc := .T.
                nTotMarc++
                PutMarcacoes(	aImpares		,;	//01 -> Array contendo as Marcacoes do Funcionario
		             			SRA->RA_FILIAL	,;	//02 -> Filial do Funcionario
								SRA->RA_MAT		,;	//03 -> Matricula do Funcionario
								"SP8"			,;	//04 -> Arquivo para Gravacao ( "SP8" ou "SPG" )
								.F.				,;	//05 -> Se Forca a Inclusao de Novo Registro
								.F.				,;	//06 -> Se Forca a Substituicao da Data/Hora
								1				,;	//07 -> Posicao Inicial para o aMarcacoes
								.F.				,;	//08 -> Se Forca a Substituicao de Tudo
								.F.				 )	//09 -> Se eh executado via workflow

             EndIf
             cOrdemAnt := aMarcacoes[nX,3]
             nContad  := 0
          EndIf
          nContad++
      Next nX					 
      // Processa o Ultimo Registro
      If ( nContad % 2 ) > 0
         aImpares := {}
         aNewMarc := {}
         Aeval(aMarcacoes,{|x| If(x[3]==cOrdemAnt,Aadd(aImpares,x),"")})
         fAcertaMarc(@aImpares, @aNewMarc, aTabCalend, cOrdemAnt)
         Aeval(aNewMarc,{|x| Aadd(aImpares,aClone(x))})
         Asort(aImpares,,,{|x,y| Dtos(x[1])+x[12] < Dtos(y[1])+y[12]})

         lNewMarc := .T.
         nTotMarc++
         PutMarcacoes(	aImpares		,;	//01 -> Array contendo as Marcacoes do Funcionario
		      			SRA->RA_FILIAL	,;	//02 -> Filial do Funcionario
						SRA->RA_MAT		,;	//03 -> Matricula do Funcionario
						"SP8"			,;	//04 -> Arquivo para Gravacao ( "SP8" ou "SPG" )
						.F.				,;	//05 -> Se Forca a Inclusao de Novo Registro
						.F.				,;	//06 -> Se Forca a Substituicao da Data/Hora
						1				,;	//07 -> Posicao Inicial para o aMarcacoes
						.F.				,;	//08 -> Se Forca a Substituicao de Tudo
						.F.				 )	//09 -> Se eh executado via workflow

      EndIf
   EndIf
   
   nTotFunc += If(lNewMarc,1,0)

   dbSelectArea( "SRA" )
   dbSkip()
EndDo

Aviso("ATENCAO","Funcionแrios Processados: " + Alltrim(Str(nTotFunc,10)) + " - Marca็๕es Incluํdas: " + Alltrim(Str(nTotMarc,10)),{"Ok"})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณACPONM90  บAutor  ณMicrosiga           บ Data ณ  10/02/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP11                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fAcertaMarc(aImpares, aNewMarc, aTabCalend, cOrdemAnt)

 Local aOldAtu   := GETAREA()
 Local aTabPad   := {}
 Local cTipMarc  := ""
 Local cNextMarc := "1E"
 Local nLen      := 0
 Local cChave    := ""
 Local nX
 
 Aeval(aTabCalend,{|x| If(x[2]==cOrdemAnt,Aadd(aTabPad,x),"")})

 nLen := Len( aImpares )
 For nX := 1 To nLen
     If     nX == 1		; cTipMarc := "1E"	; cNextMarc := "1S"
     ElseIf nX == 2		; cTipMarc := "1S"	; cNextMarc := "2E"
     ElseIf nX == 3		; cTipMarc := "2E"	; cNextMarc := "2S"
     ElseIf nX == 4		; cTipMarc := "2S"	; cNextMarc := "3E"
     ElseIf nX == 5		; cTipMarc := "3E"	; cNextMarc := "3S"
     ElseIf nX == 6		; cTipMarc := "3S"	; cNextMarc := "4E"
     ElseIf nX == 7		; cTipMarc := "4E"	; cNextMarc := "4S"
     ElseIf nX == 8		; cTipMarc := "4S"	; cNextMarc := "5E"
     ElseIf nX == 9		; cTipMarc := "5E"	; cNextMarc := "5S"
     ElseIf nX == 10	; cTipMarc := "5S"	; cNextMarc := "6E"
     EndIf
     aImpares[nX,12] := cTipMarc
 Next nX
 Aadd(aNewMarc,Aclone(aImpares[nLen]))
 aNewMarc[Len(aNewMarc),01] := If(aImpares[nLen,2]==23.59,aImpares[nLen,1]+1,aImpares[nLen,1])
 aNewMarc[Len(aNewMarc),02] := SomaHoras(aImpares[nLen,2],0.01)
 aNewMarc[Len(aNewMarc),04] := "M"
 aNewMarc[Len(aNewMarc),05] := 0
 aNewMarc[Len(aNewMarc),12] := cNextMarc
 aNewMarc[Len(aNewMarc),10] := "N"
 aNewMarc[Len(aNewMarc),28] := "I"
 aNewMarc[Len(aNewMarc),29] := "AJUSTE MARCACAO IMPAR"
 aNewMarc[Len(aNewMarc),31] := ""
 aNewMarc[Len(aNewMarc),32] := ""
 aNewMarc[Len(aNewMarc),33] := ""
 aNewMarc[Len(aNewMarc),34] := ""
 aNewMarc[Len(aNewMarc),35] := ""
 
 dbSelectArea( "SP8" )
 dbSetOrder( 2 )
 For nX := 1 To Len( aNewMarc )
     cChave := ( SRA->RA_FILIAL + SRA->RA_MAT + Dtos(aNewMarc[nX,1]) + Str(aNewMarc[nX,2],5,2) )
     If dbSeek( cChave )
        RecLock("SP8",.F.)
         SP8->P8_TPMCREP := ""
         SP8->P8_TIPOREG := ""
         SP8->P8_MOTIVRG := ""
        MsUnlock()
     EndIf
 Next nX

 RESTAREA( aOldAtu )
 
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUNGPEM01  บAutor  ณMicrosiga           บ Data ณ  02/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fMtaQuery()

 Local cQuery  := ""

 cQuery += " SELECT SRA.RA_FILIAL,"
 cQuery += "        SRA.RA_MAT,"
 cQuery += "        SRA.RA_NOME,"
 cQuery += "        SRA.R_E_C_N_O_ AS RA_RECNO"
 cQuery += " FROM " + RetSqlName( "SRA" )  + " SRA"
 cQuery += " WHERE SRA.D_E_L_E_T_ <> '*'"
    
 // Executa a Query
 cQuery := ChangeQuery( cQuery )
 TCQuery cQuery New Alias "WSRA"
 TcSetField( "WSRA" , "RA_RECNO" , "N" , 10 , 0 )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  27/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fAsrPerg()

Local aRegs := {}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{ cPerg,'01','Periodo De ?               ','','','mv_ch1','D',08,0,0,'G','NaoVazio   ','mv_par01',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''      ,'','','' ,'      ','' })
aAdd(aRegs,{ cPerg,'02','Periodo Ate ?              ','','','mv_ch2','D',08,0,0,'G','NaoVazio   ','mv_par02',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''      ,'','','' ,'      ','' })

ValidPerg(aRegs,cPerg)

Return
