#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 10/10/01
#IFDEF  WINDOWS
        #DEFINE SAY PSAY
#ENDIF

User Function ADGPE09()        // incluido pelo assistente de conversao do AP5 IDE em 10/10/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CALIAS_,NREC_,CSAVIND1,NVCES_,NPCES_,NDESC_")
SetPrvt("NFALT_,CHDIA_,ATABREF,BBLOCK,IX,APD,nPerc_")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Calcula o desconto da Cesta Basica Visa Vale (checa faltas)')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ADGPE09  ³ Autor ³ Isamu Kawakami        ³ Data ³ 07/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula o desconto da Cesta Basica Visa Vale (checa faltas)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RDMake ( DOS e Windows )                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para AD'ORO                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

#IFDEF  WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 10/10/01 ==>         #DEFINE SAY PSAY
#ENDIF

// Verifica se funcionario possui Visa Vale
If Sra->Ra_CestaB # "V"
        Return
End
    
// Verifica Filial Deve ser Processada (Parte da Reconstrucao do Roteiro de Calculo) - By Asr
If cEmpAnt == "01"
   If !( SRA->RA_FILIAL $ "01*02*06" )
      Return("")
   EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva Ambiente                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias_  := Alias()
nRec_    := Recno()
cSavInd1 := IndexOrd()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando Variaveis de Trabalho                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPerc_  := 0
nVces_  := 0
nPces_  := 0  
nDesc_  := 0
nFalt_  := 0
cHdia_  := ' '
aTabref := {}
bBlock  := {|X,Y| X[1] < Y[1]} //Classificacao do array

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Verifica Dias de Falta
nFalt_ := Abs(fBuscaPD(aCodFol[054][1],"H"))
nFalt_ := Int(nFalt_/7.10)   //Alterado de 8.90 para 8.80 em 21.07.00
                                     //Alterado de 8.80 para 7.20 em 04.04.02
                                     // em decorencia da mudanca de horario  
                                     //Alterado de 7.20 para 7.10 em 03.08.2011 porque para os funcionarios que trabalham em turnos
                                     //que a carga horaria e 7.18 o sistema nao considerava um dia de faltas para abatimento da cesta basica
                                     
// Valor da Cesta Basica e percentual desconto
If cEmpAnt == "01"
   RCC->(dbSeek(xFilial("RCC")+"U004"))
   nVces_ := Val(Subs(Rcc->Rcc_Conteu,1,12))
   nPerc_ := Val(Subs(Rcc->Rcc_Conteu,13,6))
ElseIf cEmpAnt == "02"
   RCC->(dbSeek(xFilial("RCC")+"U003"))
   nVces_ := Val(Subs(Rcc->Rcc_Conteu,1,12))
   nPerc_ := Val(Subs(Rcc->Rcc_Conteu,13,6))
Endif

If nVces_ == 0
        nVces_ := Val(Subst(GetAdvFval("SRX","RX_TXT","  35" + xFilial()+"1",1,"       "),1,11))
Endif

If nFalt_ > 0
  // Percentual de Desconto
  dbSelectArea("SZ1")

  If SZ1->(dbSeek(xFilial()+"04"))
        
        while SZ1->Z1_COD == '04'
                aadd(aTabref,{SZ1->Z1_VAL01,SZ1->Z1_VAL02})
                SZ1->(dbSkip())
        end

        // Classifica Array
        aSort(aTabref,,,bBlock)

        For ix := 1 to Len(aTabref) 
                If aTabref[ix][1] >= nFalt_
                        nPces_ := aTabref[ix][2]
                        Exit
                End
        Next

  Else
        //Exibe Help
        Help(' ',1,'SEMTAB04')

        //Retorna Ambiente
        dbSelectArea(cAlias_) 
        dbSetOrder(cSavInd1)
        dbGoto(nRec_)
                        
        Return
  end

// Calculo do Desconto
  nDesc_ := nVces_ * nPces_/100

Else  
  nDesc_ := nVces_ * nPerc_/100
Endif
  
// Verifica Se Verba Nao Informada e Gera Valor e Valor Desconto Maior que Zero
If Sra->Ra_CestaB == "V"
   fGeraVerba(aCodFol[156][1],nDesc_,,,,,,,,,.T.)
   If nDesc_ < nVces_
      fGeraVerba(aCodFol[211][1],nVces_-nDesc_,,,,,,,,,.T.)
   Endif   
End

//Retorna Ambiente
dbSelectArea(cAlias_)
dbSetOrder(cSavInd1)
dbGoto(nRec_)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                          Fim do Programa                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
