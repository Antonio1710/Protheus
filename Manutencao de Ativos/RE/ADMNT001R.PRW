#INCLUDE "ADMNT001R.ch"            
#INCLUDE "PROTHEUS.CH"     
/*                               
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ADMNT001R ³ Autor ³ LUCIANO MAFRA      ³ Data ³ 28/05/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Utilizacao da equipe de manutencao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function ADMNT001R()

Local cString    := "ST1"
Local cDesc1     := STR0001 //"Relatorio de utilizacao da equipe de manutencao. A equipe de manutencao"
Local cDesc2     := STR0002 //"e identificada pelo Centro de Custo a quem pertence. As ocorrencias"
Local cDesc3     := STR0003 //"desejadas poderao ser selecionadas atraves da opcao de parametro"
Local wnrel      := "ADMNT001R"

Private aReturn  := { STR0004, 1,STR0005, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private nLastKey := 0
Private cPerg    := "MNT790"
Private Titulo   := STR0006 //"Utilizacao da Equipe de Manutencao"
Private Tamanho  := "M"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para qarametros!                        ³
//³ mv_par01     // De centro da aplicacao                       ³
//³ mv_par02     // Ate centro da aplicacao                      ³
//³ mv_par03     // De Data Aplicacao                            ³
//³ mv_par04     // Ate Data Aplicacao                           ³
//| mv_par05     // Ocorrencias                                  ³ 
//| mv_par06     // Etapas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Utilizacao da equipe de manutencao')

pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,"")
If nLastKey = 27
   Set Filter To
   DbselectArea("STI")
   Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
   Set Filter To
   DbselectArea("STI")
   Return
Endif

RptStatus({|lEnd| R790Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

DbselectArea("STI")
Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R790Imp  ³ Autor ³ Inacio Luiz Kolling   ³ Data ³ 26/06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR790                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R790Imp(lEnd,wnRel,titulo,tamanho)
Local cRodaTxt := ""
Local nCntImpr := 0
Private li := 80 ,m_pag := 1
Private Cabec1     := STR0011 //"O.S.   Plano  Bem             Nome                 Serv   Nome                 Seq.Quantidade Uni ....Inicio.... ......Fim..... Rpr"
Private Cabec2     := STR0014 //"       Ocorr. Descricao da Ocorrencia"
Private nomeprog   := "ADMNT001R"
Private novocentro := .f.
Private quebracab  := .f.

nTipo := IIF(aReturn[4]==1,15,18)

/*
************************************************************************************************************************************
*<empresa>                                                                                                        Folha..: xxxxx   *
*SIGA /<nome .04                                 <     titulo do relatorio    >                                   DT.Ref.: dd/mm/aa*
*Hora...: xx:xx:xx                                                                                                Emissao: dd/mm/aa*
*************************************************************************************************************************************
O.S.   Plano  Bem             Nome               Serv   Nome                Seq.Quantidade Uni ....Inicio....   ......Fim.....   Rpr
*************************************************************************************************************************************
               1         2         3         4         5         6         7         8         9         0         1         2     3
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

C.Custo de Aplicacao..: xxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Funcionario...........: xxxxxx    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xxxxxx xxxxxx xxxxxxxxxxxxxxxx xxxxxxxxxxx19xxxx xxxxxx xxxxxxxxxxx19xxxxxx 999 999.999,99 xxx 99/99/9999 99:99 99/99/9999 99:99 xxx
       Pai==> xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
*/
   
aDBF := {}
Aadd(aDBF,{"CUSTO"  ,"C",Len(st1->t1_ccusto),0})
Aadd(aDBF,{"CODFUNC","C",06, 0 })
Aadd(aDBF,{"TURNO"  ,"C",03, 0 })
Aadd(aDBF,{"ORDEM"  ,"C",06, 0 })
Aadd(aDBF,{"PLANO"  ,"C",06, 0 })
Aadd(aDBF,{"CODBEM" ,"C",16, 0 })
Aadd(aDBF,{"SERVICO","C",06, 0 })
Aadd(aDBF,{"SEQRELA","C",03, 0 })
Aadd(aDBF,{"QUANT"  ,"N",09, 2 })
Aadd(aDBF,{"UNIDADE","C",03, 0 })
Aadd(aDBF,{"DTINICI","D",08, 0 })
Aadd(aDBF,{"HOINICI","C",05, 0 })
Aadd(aDBF,{"DTFIM"  ,"D",08, 0 })
Aadd(aDBF,{"HOFIM"  ,"C",05, 0 })
Aadd(aDBF,{"TAREFA" ,"C",06, 0 })
Aadd(aDBF,{"REPFIM" ,"C",03, 0 })
Aadd(aDBF,{"DTPREV" ,"D",08, 0 })

cArqTrab := CriaTrab(aDBF)
dbUseArea(.T.,,cArqTrab,"TRB",.f.)  
cIndR790 := CriaTrab(Nil, .F.)

IndRegua("TRB",cIndR790,"CUSTO+CODFUNC+ORDEM+PLANO",,,STR0018) //"Selecionando Registros..."

dbClearIndex()
dbSetIndex(cIndR790 + OrdBagExt())

PROCESSA({|lEND| MNTR790ST1()},STR0017) //"Processando Arquivo..."

nTot_do_Func := 0
nTot_FGeral  := 0
nTot_HGeral  := 0
nHoraAll     := 0
nMinuAll     := 0
DbselectArea("TRB")
Dbgotop()
SetRegua(LastRec())
While !Eof()
   ccusto := TRB->CUSTO
   novocentro := .t.
   While !Eof() .And. TRB->CUSTO == ccusto
      nTot_do_Func := 0
      nHORATBFIM   := 0
      nMINTBFIM    := 0
      nfuncio      := TRB->CODFUNC
      novofuncio   := .t.
      While !Eof() .And. TRB->CUSTO == ccusto .And. TRB->CODFUNC == nfuncio
         cOrdem := TRB->ORDEM
         cPlano := TRB->PLANO
         lDiff  := .t.     

         While !Eof() .And. TRB->CUSTO == ccusto .And. TRB->CODFUNC == nfuncio  .And.;
            cOrdem == TRB->ORDEM .And. cPlano == TRB->PLANO
            INCREGUA()
            cChave := TRB->CODBEM
            DbselectArea("STC")
            DbSetOrder(03)
            While .T.
               DbSeek(xFilial('STC')+cChave)
               If found()
                  cChave := STC->TC_CODBEM       
                  Dbskip()
                  Loop
                Endif
                Exit
            End                                                     

            DbselectArea("STF")
            DbSetOrder(03)
            DbSeek(xFilial('STF')+TRB->SERVICO+TRB->CODBEM)
            _cDtPrev := CTOD('')            
            If found()   
               _cDtPrev := STF->TF_DTULTMA
            Endif                                           
                
            DbselectArea("STG")                                        
            DbSetOrder(01)
            DbSeek(xFilial('STG')+TRB->CODBEM+TRB->SERVICO)
            _cHrPrev  := ' '             
            _cHrPrev1 := ' '                         
            If found()   
               _cHrPrev := STG->TG_QUANTID
               _cHrPrev1:= SUBSTR(STRZERO(STG->TG_QUANTID,09,02),05,02) + ':' + SUBSTR(STRZERO(STG->TG_QUANTID,09,02),08,02)
            Endif
          
            DbselectArea("TRB")
            nSOMA := 0
            nINI  := HTOM(TRB->HOINICI)
            nFIM  := HTOM(TRB->HOFIM)
//
            If TRB->DTFIM > TRB->DTINICI
               nSOMA := ((TRB->DTFIM - TRB->DTINICI)*1440)
            Endif
//
            cHoraa := NTOH(((nFIM+nSOMA) - nINI)/60)
//
            cHORAI := Alltrim (cHoraa)
            nPOSTI := At (':',cHORAI)
            cHORI  := Substr(cHORAI,1,nPOSTI-1)
            cMINI  := Substr(cHORAI,nPOSTI+1,2)
            nHORI  := Val(cHORI)
            nMINI  := Val(cMINI)

            nHORATBFIM := nHORATBFIM + nHORI
            nMINTBFIM  := nMINTBFIM  + nMINI
            nHoraAll += nHORI
            nMinuAll += nMINI

            If nMINTBFIM >= 60
               nHORATBFIM := nHORATBFIM + 1
               nMINTBFIM  := nMINTBFIM - 60
            Endif

            If nMinuAll >= 60
               nHoraAll := nHoraAll + 1
               nMinuAll := nMinuAll - 60
            Endif

            cTHORATRAB := Alltrim(Str(nHORATBFIM,4)) + ':' + strzero(nMINTBFIM,2)
            cAllTrab   := Alltrim(Str(nHoraAll,4)) + ':' + strzero(nMinuAll,2)

            Ngsomali(58)
            cabec22()
            cabec33()
            If lDiff
               nTot_do_Func++
               @li,000 Psay TRB->ORDEM
               @li,007 Psay TRB->PLANO
            Endif
            lDiff := .f.
            @li,014 Psay TRB->CODBEM
            @li,031 Psay substr(NGSEEK('ST9',TRB->CODBEM,1,'T9_NOME'),1,16)
            @li,048 Psay TRB->SERVICO
            @li,055 Psay substr(NGSEEK('ST4',TRB->SERVICO,1,'T4_NOME'),1,14)
            @li,070 Psay TRB->SEQRELA Picture '@!'
            
            nCOLI := If(nHORI < 100,73,72)
                        
            @LI,nCOLI PSAY cHORAA

            @li,079 Psay 'H'
            @li,082 Psay TRB->DTINICI Picture '99/99/99'
            @li,093 Psay TRB->HOINICI Picture '99:99'
            @li,099 Psay TRB->DTFIM   Picture '99/99/99'
            @li,110 Psay TRB->HOFIM   Picture '99:99'
            @li,116 Psay TRB->REPFIM 
            
            @li,120 Psay _cDTPrev     Picture '99/99/99'
            @li,131 Psay _cHrPrev1              

// **************************************  INICIO ALTERAÇÃO CHAMADO 023734 **********************************
     
            If mv_par06 = 1  // Imprimir as Etapas

               _nCont := 0
               DbselectArea("STH")   // ETAPAS DA MANUTENÇÃO                                     
               DbSetOrder(01)        //  filial + bem + servico + seqrela + tarefa
               if DbSeek(xFilial('STH')+TRB->CODBEM+TRB->SERVICO+TRB->SEQRELA) 
                  Do While STH->TH_FILIAL = xFilial('STH') .and. STH->TH_CODBEM = TRB->CODBEM .and. STH->TH_SERVICO = TRB->SERVICO .AND. STH->TH_SEQRELA = TRB->SEQRELA
                     Ngsomali(58)                                                       
                     _nCont++
                     @Li,007 PSay 'Etapa.:' 
                     @Li,015 PSay sth->th_etapa 

                     DbselectArea("TPA") // CAPTURAR A DESCRIÇÃO DA ETAPA   
                     DbSetOrder(01)        //  filial + etapa
                     if DbSeek(xFilial('TPA')+STH->TH_ETAPA) 
                        @Li,021 PSay SUBSTR(TPA->TPA_DESCRI,1,70)                   
                     Endif                      
                      
                     @Li,093 PSay 'Tarefa.:' + sth->TH_TAREFA
     
                     DbselectArea("TT9")   
                     DbSetOrder(01)        //  filial + etapa
                     if DbSeek(xFilial('TT9')+STH->TH_TAREFA) 
                        @Li,107 PSay TT9->TT9_DESCRI                   
                     Endif                                            
 
                     DbselectArea("STH")                              
                     Dbskip()
                  ENDDO   
               endif              
               DbselectArea("TRB")                                                      
            
            Endif
            
// **************************************    FIM ALTERAÇÃO CHAMADO 023734  **********************************                    
                                    
            If TRB->CODBEM != cChave                                                
               Ngsomali(58)
               @Li,007 PSay STR0010 //"Pai==>"
               @Li,014 Psay cChave
               @li,031 Psay NGSEEK('ST9',cChave,1,'T9_NOME')
            Endif

            // IMPRIME AS OCORRENCIAS   
            
            If mv_par05 = 1
               DbselectArea("STN")
               Dbsetorder(1)
               If Dbseek(xFilial('STN')+TRB->ORDEM+TRB->PLANO+TRB->TAREFA+TRB->SEQRELA)
    	          While !Eof() .And. xFilial('STN') == stn->tn_filial .And. ;
        	         stn->tn_ordem == TRB->ORDEM .And.  stn->tn_plano == TRB->PLANO .And. ;
                     stn->tn_tarefa == TRB->TAREFA .And. stn->tn_seqrela == TRB->SEQRELA

               	     Ngsomali(58)
                   	 @ Li,007 Psay STN->TN_CODOCOR
	                 @ li,014 Psay NGSEEK('ST8',STN->TN_CODOCOR,1,'T8_NOME')

    	             DbselectArea("STN")
        	         Dbskip()
                  End
               Endif
            Endif
                                                                                        
            Ngsomali(58)                                                       
            
            DbselectArea("TRB")
            Dbskip()
         End
      End

      If nTot_do_Func > 0
         nTot_FGeral += nTot_do_Func
         Ngsomali(58)
         @ li,02 Psay STR0015 //"Total de O.S.:"
         @ li,17 Psay nTot_do_Func
         If nHORATBFIM < 100
            nCOLI := If(nHORATBFIM < 10,74,73)
            @LI,nCOLI PSAY cTHORATRAB
         Else
            nCOLI := If(nHORATBFIM < 1000,73,74)
            @LI,nCOLI PSAY cTHORATRAB
         Endif
         @ li,79 Psay "H"
      Endif
   End
End  
If nTot_FGeral > 0  
   Ngsomali(58)
   Ngsomali(58)
   @li,02 Psay STR0016 //"Total Geral.:"
   @li,17 Psay nTot_FGeral
   If nHoraAll < 100
      nCOLI := If(nHoraAll < 10,84,83)
      @LI,nCOLI PSAY cAllTrab
   Else
      nCOLI := If(nHoraAll < 1000,82,81)
      @LI,nCOLI PSAY cAllTrab
   Endif
   @li,91 Psay "H"
Endif
Roda(nCntImpr,cRodaTxt,Tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principam             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("STJ")
DbselectArea("TRB")
Use    
FErase(cArqTrab + GetDbExtension())
FErase(cIndR790 + OrdBagExt()) 

Set Filter To
Set device to Screen

If aReturn[5] = 1
   Set Printer To
   dbCommitAll()
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Cabec2   ³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cabecalho de quebra                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR790        !                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Cabec22()
If novocentro
   Ngsomali(58)
   @li,000 Psay STR0012 //"C.Custo de Aplicacao..:"
   @li,024 Psay Alltrim(TRB->CUSTO)+" "+ NGSEEK('SI3',TRB->CUSTO,1,'I3_DESC')
   Ngsomali(58)
   novocentro := .f.
Endif
Return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Cabec3   ³ Autor ³ Inacio Luiz Kolling   ³ Data ³   /06/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cabecalho de quebra                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR790        !                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Cabec33()
If novofuncio
   Ngsomali(58)
   @li,000 Psay STR0013 //"Funcionario.:"
   @li,014 Psay TRB->CODFUNC
   @ li,023 Psay NGSEEK('ST1',TRB->CODFUNC,1,'T1_NOME')
   novofuncio := .f.
   Ngsomali(58)
   nTot_do_Func := 0
Endif
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MNTR790ST1³ Autor ³Denis Hyroshi de Souza ³ Data ³11/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa arquivo de funcionarios                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MNTR790                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MNTR790ST1()

cCONDSTL := 'Val(stl->tl_seqrela) > 0 .And. (STL->TL_DTINICI >= mv_par03 .And. STL->TL_DTINICI <= mv_par04)'
cCONDSTT := 'Val(stt->tt_seqrela) > 0 .And. (STT->TT_DTINICI >= mv_par03 .And. STT->TT_DTINICI <= mv_par04)'
DbselectArea("ST1")
Dbsetorder(03)
Dbseek(xFilial('ST1')+MV_PAR01,.T.)
SetRegua(LastRec())
While !Eof() .And. xFilial('ST1') == st1->t1_filial .And. st1->t1_ccusto <= mv_par02
   INCREGUA()
   DbselectArea("STL")
   Dbsetorder(8)
   sCODFUNC := ST1->T1_CODFUNC+REPLICATE(' ',LEN(STL->TL_CODIGO)-LEN(ST1->T1_CODFUNC))
   Dbseek(xFILIAL("STL")+"M"+sCODFUNC)
   While !Eof() .And. xFILIAL("STL") == STL->TL_FILIAL .And.;
      STL->TL_TIPOREG == "M" .And. STL->TL_CODIGO == sCODFUNC

      If &(cCONDSTL)
         DbselectArea("STJ")
         Dbsetorder(1)
         If Dbseek(xFILIAL("STJ")+STL->TL_ORDEM+STL->TL_PLANO)
            If stj->tj_tipoos = "B"
               DbselectArea("TRB")
               TRB->(DbAppend())
               TRB->CUSTO   := ST1->T1_CCUSTO
               TRB->CODFUNC := ST1->T1_CODFUNC
               TRB->TURNO   := ST1->T1_TURNO
               TRB->ORDEM   := STJ->TJ_ORDEM
               TRB->PLANO   := STJ->TJ_PLANO
               TRB->CODBEM  := STJ->TJ_CODBEM
               TRB->SERVICO := STJ->TJ_SERVICO
               TRB->QUANT   := STL->TL_QUANTID
               TRB->UNIDADE := STL->TL_UNIDADE
               TRB->DTINICI := STL->TL_DTINICI
               TRB->HOINICI := STL->TL_HOINICI
               TRB->DTFIM   := STL->TL_DTFIM
               TRB->HOFIM   := STL->TL_HOFIM
               TRB->TAREFA  := STL->TL_TAREFA
               TRB->REPFIM  := If(STL->TL_REPFIM = 'N' .Or.;
                                 Empty(STL->TL_REPFIM),'Nao','Sim')
               TRB->SEQRELA := STJ->TJ_SEQRELA
	        EndIf
         Endif
      Endif
      DbselectArea("STL")
      Dbskip()
   End

   DbselectArea("STT")
   Dbsetorder(3)
   sCODFUNC := ST1->T1_CODFUNC+REPLICATE(' ',LEN(STT->TT_CODIGO)-LEN(ST1->T1_CODFUNC))
   Dbseek(xFILIAL("STT")+"M"+sCODFUNC)
   While !Eof() .And. xFILIAL("STT") == STT->TT_FILIAL .And.;
      STT->TT_TIPOREG == "M" .And. STT->TT_CODIGO == sCODFUNC

      If &(cCONDSTT)
         DbselectArea("STS")
         Dbsetorder(1)
         If Dbseek(xFILIAL("STS")+STT->TT_ORDEM+STT->TT_PLANO)
            If sts->ts_tipoos = "B"
               DbselectArea("TRB")
               TRB->(DbAppend())
               TRB->CUSTO   := ST1->T1_CCUSTO
               TRB->CODFUNC := ST1->T1_CODFUNC
               TRB->TURNO   := ST1->T1_TURNO
               TRB->ORDEM   := STS->TS_ORDEM
               TRB->PLANO   := STS->TS_PLANO
               TRB->CODBEM  := STS->TS_CODBEM
               TRB->SERVICO := STS->TS_SERVICO
               TRB->QUANT   := STT->TT_QUANTID
               TRB->UNIDADE := STT->TT_UNIDADE
               TRB->DTINICI := STT->TT_DTINICI
               TRB->HOINICI := STT->TT_HOINICI
               TRB->DTFIM   := STT->TT_DTFIM
               TRB->HOFIM   := STT->TT_HOFIM
               TRB->TAREFA  := STT->TT_TAREFA
               TRB->REPFIM  := If(STT->TT_REPFIM = 'N' .Or.;
                                 Empty(STT->TT_REPFIM),'Nao','Sim')
               TRB->SEQRELA := STS->TS_SEQRELA
	        EndIf
         Endif
      Endif
      DbselectArea("STT")
      Dbskip()
   End
   DbselectArea("ST1")
   Dbskip()
End
Return .t.
