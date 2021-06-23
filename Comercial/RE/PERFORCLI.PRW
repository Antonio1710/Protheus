#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
/*                         
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERFORCLI³ Autor ³ Mauricio - MDS TEC      ³ Data ³ 03/09/2014 ³±±               
±±³          ³          ³       ³ 						  ³      ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Performance dos Clientes(Varejo ou Rede) em       ³±±
±±³          ³ periodo maximo de 12 meses                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ADORO                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³  Data  ³              Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PERFORCLI()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Impressao de relatorio de performance de clientes "
Local cDesc2         := "(Rede ou Varejo) com periodo maximo de 12 meses e "
Local cDesc3         := "conforme parametros."
Local cPict          := ""
Local titulo         := "Performance de Clientes - maximo 12 meses"
Local nLin         	 := 80
Local Cabec1       	 := ""
Local Cabec2       	 := ""
Local imprime      	 := .T.
Local aOrd 			 := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "PERFORCLI"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "PERFORCLI"
Private cString 	 := "SD2"
Private cPerg   	 := "PERFCLI"
Private nOrdem
Private cArq
Private oExcelApp
Private _Eof 	:= Chr(13) + Chr(10)
Private cLin := ""
Private cLin1 := ""
Private cLin2 := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Performance dos Clientes(Varejo ou Rede) em periodo maximo de 12 meses')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PutSX1(cPerg,"01","Data De ","Data De ","Data De ","mv_ch1","D",8,0,0,"G","","   ","","","mv_par01" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"02","Data Ate","Data Ate","Data Ate","mv_ch2","D",8,0,0,"G","","   ","","","mv_par02" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"03","Cliente ","Cliente ","Cliente ","mv_ch3","C",6,0,0,"G","","SA1","","","mv_par03" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"04","Loja    ","Loja    ","Loja    ","mv_ch4","C",2,0,0,"G","",""   ,"","","mv_par04" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"05","Escolha tipo Cliente","Escolha tipo Cliente"	,"Escolha tipo Cliente","mv_ch5","N",01,0,01,"C","","","","","mv_par05" ,"Rede","Rede","Rede","","Varejo","Varejo","Varejo","","","","","","","",""," ")
PutSx1(cPerg,"06","Imprime?"       ,"Imprime?"          ,"Imprime?"       ,"mv_ch6","N",01,0,01,"C","","","","","mv_par06" ,"Tudo","Tudo","Tudo","","Volume","Volume","Volume","Valor","Valor","Valor","Preco Medio","Preco Medio","Preco Medio","","","")
PutSX1(cPerg,"07","Gera em Excel ?","Gera em Excel ?"	,"Gera em Excel ?","mv_ch7","N",01,0,01,"C","","","","","mv_par07" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")
PutSx1(cPerg,"08","Seleciona filiais"  ,"Seleciona filiais"  ,"Seleciona filiais"  ,"mv_ch8","C",50,0,0,"G","U_FXFIL()","","","","mv_par08","","","","","","","","","","","","","","","","","","","")

Pergunte(cPerg,.F.)

dbSelectArea(cString)
dbSetOrder(1)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)
nOrdem:= aReturn[8]

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local lFlag		:= .T.
Local cAliasMP  := ""

_dDTCORTE := MV_PAR02

If (Empty(MV_PAR01) .Or. Empty(MV_PAR02)) .Or. (MV_PAR02 <= MV_PAR01) .OR. ((MV_PAR02 - MV_PAR01) > 366)
   MsgInfo("Parametro data incorretos ou maior que 12 meses","Atenção")
   return()
Endif

&&arquivo temporario para saida impressa...
aCampos := {}

If Select("TEMP") > 0
   DbSelectArea("TEMP")
   DbCloseArea("TEMP")
Endif

AADD(aCampos,{"CLIENTE"   , "C", 006,0})
AADD(aCampos,{"LOJA"      , "C", 002,0})
AADD(aCampos,{"AGRUP"     , "C", 002,0})
AADD(aCampos,{"PRODUTO"   , "C", 015,0})
AADD(aCampos,{"DESCRICAO" , "C", 030,0})
AADD(aCampos,{"TIPDADO"   , "C", 010,0})   &&VALOR / VOLUME / MEDIO usar estes tipos somente
AADD(aCampos,{"PER01"     , "N", 014,4})
AADD(aCampos,{"PER02"     , "N", 014,4})
AADD(aCampos,{"PER03"     , "N", 014,4})
AADD(aCampos,{"PER04"     , "N", 014,4})
AADD(aCampos,{"PER05"     , "N", 014,4})
AADD(aCampos,{"PER06"     , "N", 014,4})
AADD(aCampos,{"PER07"     , "N", 014,4})
AADD(aCampos,{"PER08"     , "N", 014,4})
AADD(aCampos,{"PER09"     , "N", 014,4})
AADD(aCampos,{"PER10"     , "N", 014,4})
AADD(aCampos,{"PER11"     , "N", 014,4})
AADD(aCampos,{"PER12"     , "N", 014,4})
AADD(aCampos,{"TOTAL"     , "N", 014,4})

_cNomTrb := CriaTrab(aCampos)
dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)

cIndex   := "CLIENTE+AGRUP+PRODUTO+TIPDADO"
IndRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )

dbSelectArea("TEMP")
dbSetOrder(1)
		   
_dDiaFim := _dDTCORTE         &&Data final
_dDiaIni := FirstDay(MonthSub(_dDTCORTE , 11 ))  &&Data inicial para um periodo de 12 meses..... 

&&calculo as datas para os periodos
_dPer1  := _dDiaIni
_dPer2  := (LastDay(_dDiaIni))+1
_dPer3  := (LastDay(_dPer2))+1
_dPer4  := (LastDay(_dPer3))+1
_dPer5  := (LastDay(_dPer4))+1
_dPer6  := (LastDay(_dPer5))+1
_dPer7  := (LastDay(_dPer6))+1
_dPer8  := (LastDay(_dPer7))+1
_dPer9  := (LastDay(_dPer8))+1
_dPer10 := (LastDay(_dPer9))+1
_dPer11 := (LastDay(_dPer10))+1
_dPer12 := (LastDay(_dPer11))+1

Titulo := TITULO+SPACE(10) + "Data de : " +DTOC(_dDiaIni)+SPACE(05) + "até : " + DTOC(_dDiaFim)
           
Cabec1 := "Grupo Produto          Descricao                        "+Substr(MesExtenso(month(_dPer1)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer1))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer2)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer2))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer3)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer3))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer4)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer4))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer5)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer5))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer6)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer6))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer7)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer7))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer8)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer8))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer9)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer9))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer10)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer10))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer11)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer11))),2)+Space(6)+;
       Substr(MesExtenso(month(_dPer12)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer12))),2)+Space(6)+"Total" 
       
       
       
       cLin1 := "Grupo;Produto;Descricao;"+Substr(MesExtenso(month(_dPer1)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer1))),2)+";"+;
       Substr(MesExtenso(month(_dPer2)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer2))),2)+";"+;
       Substr(MesExtenso(month(_dPer3)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer3))),2)+";"+;
       Substr(MesExtenso(month(_dPer4)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer4))),2)+";"+;
       Substr(MesExtenso(month(_dPer5)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer5))),2)+";"+;
       Substr(MesExtenso(month(_dPer6)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer6))),2)+";"+;
       Substr(MesExtenso(month(_dPer7)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer7))),2)+";"+;
       Substr(MesExtenso(month(_dPer8)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer8))),2)+";"+;
       Substr(MesExtenso(month(_dPer9)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer9))),2)+";"+;
       Substr(MesExtenso(month(_dPer10)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer10))),2)+";"+;
       Substr(MesExtenso(month(_dPer11)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer11))),2)+";"+;
       Substr(MesExtenso(month(_dPer12)),1,3)+"_"+RIGHT(Alltrim(STR(year(_dPer12))),2)+";TOTAL"+_Eof
       
Cabec2 := ""
      

_aProdP1 := {}
_aProdP2 := {}
_aProdP3 := {}
_aProdP4 := {}
_aProdP5 := {}
_aProdP6 := {}
_aProdP7 := {}
_aProdP8 := {}
_aProdP9 := {}
_aProdP10 := {}
_aProdP11 := {}
_aProdP12 := {}

&&tratamento para cada periodo do relatorio(mes a mes, 12 meses)
For _nPer := 1 to 12

    If _nPer == 1
       /*
       If MV_PAR01 >= _dPer1 .AND. MV_PAR01 <= Lastday(_dPer1)
          IF MV_PAR02 <= Lastday(_dPer1)       
             fBsc12Mes(MV_PAR01,MV_PAR02,_nPer)
          Else
             fBsc12Mes(MV_PAR01,Lastday(_dPer1),_nPer)
          Endif
       Else
          &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
       Endif
       */
       If _dPer1 >= MV_PAR01 .AND. Lastday(_dPer1) <= MV_PAR02
          fBsc12Mes(_dPer1,Lastday(_dPer1),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer1 >= MV_PAR01 .AND. Lastday(_dPer1) > MV_PAR02
              fBsc12Mes(_dPer1,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer1 < MV_PAR01 .AND. Lastday(_dPer1) >= MV_PAR01
              If Lastday(_dPer1) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer1),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer1 < MV_PAR01 .And. Lastday(_dPer1) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif          
    elseif _nPer == 2
       If _dPer2 >= MV_PAR01 .AND. Lastday(_dPer2) <= MV_PAR02
          fBsc12Mes(_dPer2,Lastday(_dPer2),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer2 >= MV_PAR01 .AND. Lastday(_dPer2) > MV_PAR02
              fBsc12Mes(_dPer2,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer2 < MV_PAR01 .AND. Lastday(_dPer2) >= MV_PAR01
              If Lastday(_dPer2) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer2),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer2 < MV_PAR01 .And. Lastday(_dPer2) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif  
    
    elseif _nPer == 3
       If _dPer3 >= MV_PAR01 .AND. Lastday(_dPer3) <= MV_PAR02
          fBsc12Mes(_dPer3,Lastday(_dPer3),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer3 >= MV_PAR01 .AND. Lastday(_dPer3) > MV_PAR02
              fBsc12Mes(_dPer3,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer3 < MV_PAR01 .AND. Lastday(_dPer3) >= MV_PAR01
              If Lastday(_dPer3) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer3),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer3 < MV_PAR01 .And. Lastday(_dPer3) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif 
    elseif _nPer == 4
       If _dPer4 >= MV_PAR01 .AND. Lastday(_dPer4) <= MV_PAR02
          fBsc12Mes(_dPer4,Lastday(_dPer4),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer4 >= MV_PAR01 .AND. Lastday(_dPer4) > MV_PAR02
              fBsc12Mes(_dPer4,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer4 < MV_PAR01 .AND. Lastday(_dPer4) >= MV_PAR01
              If Lastday(_dPer4) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer4),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer4 < MV_PAR01 .And. Lastday(_dPer4) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif  
    elseif _nPer == 5
       If _dPer5 >= MV_PAR01 .AND. Lastday(_dPer5) <= MV_PAR02
          fBsc12Mes(_dPer5,Lastday(_dPer5),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer5 >= MV_PAR01 .AND. Lastday(_dPer5) > MV_PAR02
              fBsc12Mes(_dPer5,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer5 < MV_PAR01 .AND. Lastday(_dPer5) >= MV_PAR01
              If Lastday(_dPer5) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer5),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer5 < MV_PAR01 .And. Lastday(_dPer5) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif 
    elseif _nPer == 6
       If _dPer6 >= MV_PAR01 .AND. Lastday(_dPer6) <= MV_PAR02
          fBsc12Mes(_dPer6,Lastday(_dPer6),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer6 >= MV_PAR01 .AND. Lastday(_dPer6) > MV_PAR02
              fBsc12Mes(_dPer6,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer6 < MV_PAR01 .AND. Lastday(_dPer6) >= MV_PAR01
              If Lastday(_dPer6) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer6),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer6 < MV_PAR01 .And. Lastday(_dPer6) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif  
    elseif _nPer == 7
       If _dPer7 >= MV_PAR01 .AND. Lastday(_dPer7) <= MV_PAR02
          fBsc12Mes(_dPer7,Lastday(_dPer7),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer7 >= MV_PAR01 .AND. Lastday(_dPer7) > MV_PAR02
              fBsc12Mes(_dPer7,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer7 < MV_PAR01 .AND. Lastday(_dPer7) >= MV_PAR01
              If Lastday(_dPer7) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer7),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer7 < MV_PAR01 .And. Lastday(_dPer7) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif 
    elseif _nPer == 8
       If _dPer8 >= MV_PAR01 .AND. Lastday(_dPer8) <= MV_PAR02
          fBsc12Mes(_dPer8,Lastday(_dPer8),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer8 >= MV_PAR01 .AND. Lastday(_dPer8) > MV_PAR02
              fBsc12Mes(_dPer8,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer8 < MV_PAR01 .AND. Lastday(_dPer8) >= MV_PAR01
              If Lastday(_dPer8) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer8),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer8 < MV_PAR01 .And. Lastday(_dPer8) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif 
    elseif _nPer == 9
       If _dPer9 >= MV_PAR01 .AND. Lastday(_dPer9) <= MV_PAR02
          fBsc12Mes(_dPer9,Lastday(_dPer9),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer9 >= MV_PAR01 .AND. Lastday(_dPer9) > MV_PAR02
              fBsc12Mes(_dPer9,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer9 < MV_PAR01 .AND. Lastday(_dPer9) >= MV_PAR01
              If Lastday(_dPer9) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer9),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer9 < MV_PAR01 .And. Lastday(_dPer9) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif   
    elseif _nPer == 10
       If _dPer10 >= MV_PAR01 .AND. Lastday(_dPer10) <= MV_PAR02
          fBsc12Mes(_dPer10,Lastday(_dPer10),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer10 >= MV_PAR01 .AND. Lastday(_dPer10) > MV_PAR02
              fBsc12Mes(_dPer10,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer10 < MV_PAR01 .AND. Lastday(_dPer10) >= MV_PAR01
              If Lastday(_dPer10) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer10),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer10 < MV_PAR01 .And. Lastday(_dPer10) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif 
    elseif _nPer == 11
       If _dPer11 >= MV_PAR01 .AND. Lastday(_dPer11) <= MV_PAR02
          fBsc12Mes(_dPer11,Lastday(_dPer11),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer11 >= MV_PAR01 .AND. Lastday(_dPer11) > MV_PAR02
              fBsc12Mes(_dPer11,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)   
       Elseif _dPer11 < MV_PAR01 .AND. Lastday(_dPer11) >= MV_PAR01
              If Lastday(_dPer11) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer11),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer11 < MV_PAR01 .And. Lastday(_dPer11) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif
    elseif _nPer == 12
       If _dPer12 >= MV_PAR01 .AND. Lastday(_dPer12) <= MV_PAR02
          fBsc12Mes(_dPer12,Lastday(_dPer12),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer12 >= MV_PAR01 .AND. Lastday(_dPer12) > MV_PAR02
              fBsc12Mes(_dPer12,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
       Elseif _dPer12 < MV_PAR01 .AND. Lastday(_dPer12) >= MV_PAR01
              If Lastday(_dPer12) <= MV_PAR02
                 fBsc12Mes(MV_PAR01,Lastday(_dPer12),_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Else
                 fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,MV_PAR03,MV_PAR04,MV_PAR05)
              Endif   
       Elseif _dPer12 < MV_PAR01 .And. Lastday(_dPer12) < MV_PAR01
             &&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.       
       Endif
    Endif 
    &&Mauricio - 03/09/14 -...definida logica para apuração dos periodos conforme IF em _nPer´s acima..faltando avaliar quando o valor para o
    &&mes é zero(mes sem apuração)...se passo na funçao ou se trato aqui mesmo(acima).
    &&Falta tratar a query de busca dos valores(FBSC12mes e buscados ao final) conforme parametros adoro e gravar o retorno em array _aProdP...para gravar os
    &&dados na tabela temporaria criada acima e fazer saida em relatorio e excel... 
Next _nPer 

&&Atualizo arquivo temporario com os periodos apurados....
for _ni := 1 to len(_aProdP1)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP1[_ni,3]+_aProdP1[_ni,2]+_aProdP1[_ni,1])       
       _nValMed := 0                                                 
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP1[_ni,3] .And. TEMP->AGRUP == _aProdP1[_ni,2] .And. TEMP->PRODUTO == _aProdP1[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER01 += _aProdP1[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER01
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER01 += _aProdP1[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER01 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER01 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP1[_ni,3]
          TEMP->LOJA      := _aProdP1[_ni,4]
          TEMP->AGRUP     := _aProdP1[_ni,2]
          TEMP->PRODUTO   := _aProdP1[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP1[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER01     := _aProdP1[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP1[_ni,3]
          TEMP->LOJA      := _aProdP1[_ni,4]
          TEMP->AGRUP     := _aProdP1[_ni,2]
          TEMP->PRODUTO   := _aProdP1[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP1[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER01     := _aProdP1[_ni,6]                      
       TEMP->(MsUnlock())                            
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP1[_ni,3]
          TEMP->LOJA      := _aProdP1[_ni,4]
          TEMP->AGRUP     := _aProdP1[_ni,2]
          TEMP->PRODUTO   := _aProdP1[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP1[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER01     := _aProdP1[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP2)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP2[_ni,3]+_aProdP2[_ni,2]+_aProdP2[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP2[_ni,3] .And. TEMP->AGRUP == _aProdP2[_ni,2] .And. TEMP->PRODUTO == _aProdP2[_ni,1]
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER02 += _aProdP2[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER02
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER02 += _aProdP2[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER02  
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER02 += (_nValMEd / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP2[_ni,3]
          TEMP->LOJA      := _aProdP2[_ni,4]
          TEMP->AGRUP     := _aProdP2[_ni,2]
          TEMP->PRODUTO   := _aProdP2[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP2[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER02     := _aProdP2[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP2[_ni,3]
          TEMP->LOJA      := _aProdP2[_ni,4]
          TEMP->AGRUP     := _aProdP2[_ni,2]
          TEMP->PRODUTO   := _aProdP2[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP2[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER02     := _aProdP2[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP2[_ni,3]
          TEMP->LOJA      := _aProdP2[_ni,4]
          TEMP->AGRUP     := _aProdP2[_ni,2]
          TEMP->PRODUTO   := _aProdP2[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP2[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER02     := _aProdP2[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP3)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP3[_ni,3]+_aProdP3[_ni,2]+_aProdP3[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP3[_ni,3] .And. TEMP->AGRUP == _aProdP3[_ni,2] .And. TEMP->PRODUTO == _aProdP3[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER03 += _aProdP3[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER03
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER03 += _aProdP3[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER03 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER03 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP3[_ni,3]
          TEMP->LOJA      := _aProdP3[_ni,4]
          TEMP->AGRUP     := _aProdP3[_ni,2]
          TEMP->PRODUTO   := _aProdP3[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP3[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER03     := _aProdP3[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP3[_ni,3]
          TEMP->LOJA      := _aProdP3[_ni,4]
          TEMP->AGRUP     := _aProdP3[_ni,2]
          TEMP->PRODUTO   := _aProdP3[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP3[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER03     := _aProdP3[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP3[_ni,3]
          TEMP->LOJA      := _aProdP3[_ni,4]
          TEMP->AGRUP     := _aProdP3[_ni,2]
          TEMP->PRODUTO   := _aProdP3[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP3[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER03     := _aProdP3[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP4)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP4[_ni,3]+_aProdP4[_ni,2]+_aProdP4[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP4[_ni,3] .And. TEMP->AGRUP == _aProdP4[_ni,2] .And. TEMP->PRODUTO == _aProdP4[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER04 += _aProdP4[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER04
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER04 += _aProdP4[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER04 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER04 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP4[_ni,3]
          TEMP->LOJA      := _aProdP4[_ni,4]
          TEMP->AGRUP     := _aProdP4[_ni,2]
          TEMP->PRODUTO   := _aProdP4[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP4[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER04     := _aProdP4[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP4[_ni,3]
          TEMP->LOJA      := _aProdP4[_ni,4]
          TEMP->AGRUP     := _aProdP4[_ni,2]
          TEMP->PRODUTO   := _aProdP4[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP4[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER04     := _aProdP4[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP4[_ni,3]
          TEMP->LOJA      := _aProdP4[_ni,4]
          TEMP->AGRUP     := _aProdP4[_ni,2]
          TEMP->PRODUTO   := _aProdP4[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP4[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER04     := _aProdP4[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP5)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP5[_ni,3]+_aProdP5[_ni,2]+_aProdP5[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP5[_ni,3] .And. TEMP->AGRUP == _aProdP5[_ni,2] .And. TEMP->PRODUTO == _aProdP5[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER05 += _aProdP5[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER05
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER05 += _aProdP5[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER05 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER05 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP5[_ni,3]
          TEMP->LOJA      := _aProdP5[_ni,4]
          TEMP->AGRUP     := _aProdP5[_ni,2]
          TEMP->PRODUTO   := _aProdP5[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP5[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER05     := _aProdP5[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP5[_ni,3]
          TEMP->LOJA      := _aProdP5[_ni,4]
          TEMP->AGRUP     := _aProdP5[_ni,2]
          TEMP->PRODUTO   := _aProdP5[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP5[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER05     := _aProdP5[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP5[_ni,3]
          TEMP->LOJA      := _aProdP5[_ni,4]
          TEMP->AGRUP     := _aProdP5[_ni,2]
          TEMP->PRODUTO   := _aProdP5[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP5[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER05     := _aProdP5[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP6)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP6[_ni,3]+_aProdP6[_ni,2]+_aProdP6[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP6[_ni,3] .And. TEMP->AGRUP == _aProdP6[_ni,2] .And. TEMP->PRODUTO == _aProdP6[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER06 += _aProdP6[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER06
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER06 += _aProdP6[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER06 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER06 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP6[_ni,3]
          TEMP->LOJA      := _aProdP6[_ni,4]
          TEMP->AGRUP     := _aProdP6[_ni,2]
          TEMP->PRODUTO   := _aProdP6[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP6[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER06     := _aProdP6[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP6[_ni,3]
          TEMP->LOJA      := _aProdP6[_ni,4]
          TEMP->AGRUP     := _aProdP6[_ni,2]
          TEMP->PRODUTO   := _aProdP6[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP6[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER06     := _aProdP6[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP6[_ni,3]
          TEMP->LOJA      := _aProdP6[_ni,4]
          TEMP->AGRUP     := _aProdP6[_ni,2]
          TEMP->PRODUTO   := _aProdP6[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP6[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER06     := _aProdP6[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP7)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP7[_ni,3]+_aProdP7[_ni,2]+_aProdP7[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP7[_ni,3] .And. TEMP->AGRUP == _aProdP7[_ni,2] .And. TEMP->PRODUTO == _aProdP7[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER07 += _aProdP7[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER07
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER07 += _aProdP7[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER07 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER07 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP7[_ni,3]
          TEMP->LOJA      := _aProdP7[_ni,4]
          TEMP->AGRUP     := _aProdP7[_ni,2]
          TEMP->PRODUTO   := _aProdP7[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP7[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER07     := _aProdP7[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP7[_ni,3]
          TEMP->LOJA      := _aProdP7[_ni,4]
          TEMP->AGRUP     := _aProdP7[_ni,2]
          TEMP->PRODUTO   := _aProdP7[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP7[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER07     := _aProdP7[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP7[_ni,3]
          TEMP->LOJA      := _aProdP7[_ni,4]
          TEMP->AGRUP     := _aProdP7[_ni,2]
          TEMP->PRODUTO   := _aProdP7[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP7[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER07     := _aProdP7[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP8)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP8[_ni,3]+_aProdP8[_ni,2]+_aProdP8[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP8[_ni,3] .And. TEMP->AGRUP == _aProdP8[_ni,2] .And. TEMP->PRODUTO == _aProdP8[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER08 += _aProdP8[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER08
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER08 += _aProdP8[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER08 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER08 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP8[_ni,3]
          TEMP->LOJA      := _aProdP8[_ni,4]
          TEMP->AGRUP     := _aProdP8[_ni,2]
          TEMP->PRODUTO   := _aProdP8[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP8[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER08     := _aProdP8[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP8[_ni,3]
          TEMP->LOJA      := _aProdP8[_ni,4]
          TEMP->AGRUP     := _aProdP8[_ni,2]
          TEMP->PRODUTO   := _aProdP8[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP8[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER08     := _aProdP8[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP8[_ni,3]
          TEMP->LOJA      := _aProdP8[_ni,4]
          TEMP->AGRUP     := _aProdP8[_ni,2]
          TEMP->PRODUTO   := _aProdP8[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP8[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER08     := _aProdP8[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP9)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP9[_ni,3]+_aProdP9[_ni,2]+_aProdP9[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP9[_ni,3] .And. TEMP->AGRUP == _aProdP9[_ni,2] .And. TEMP->PRODUTO == _aProdP9[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER09 += _aProdP9[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER09
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER09 += _aProdP9[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER09 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER09 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP9[_ni,3]
          TEMP->LOJA      := _aProdP9[_ni,4]
          TEMP->AGRUP     := _aProdP9[_ni,2]
          TEMP->PRODUTO   := _aProdP9[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP9[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER09     := _aProdP9[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP9[_ni,3]
          TEMP->LOJA      := _aProdP9[_ni,4]
          TEMP->AGRUP     := _aProdP9[_ni,2]
          TEMP->PRODUTO   := _aProdP9[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP9[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER09     := _aProdP9[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP9[_ni,3]
          TEMP->LOJA      := _aProdP9[_ni,4]
          TEMP->AGRUP     := _aProdP9[_ni,2]
          TEMP->PRODUTO   := _aProdP9[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP9[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER09     := _aProdP9[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP10)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP10[_ni,3]+_aProdP10[_ni,2]+_aProdP10[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP10[_ni,3] .And. TEMP->AGRUP == _aProdP10[_ni,2] .And. TEMP->PRODUTO == _aProdP10[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER10 += _aProdP10[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER10
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER10 += _aProdP10[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER10 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER10 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP10[_ni,3]
          TEMP->LOJA      := _aProdP10[_ni,4]
          TEMP->AGRUP     := _aProdP10[_ni,2]
          TEMP->PRODUTO   := _aProdP10[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP10[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER10     := _aProdP10[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP10[_ni,3]
          TEMP->LOJA      := _aProdP10[_ni,4]
          TEMP->AGRUP     := _aProdP10[_ni,2]
          TEMP->PRODUTO   := _aProdP10[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP10[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER10    := _aProdP10[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP10[_ni,3]
          TEMP->LOJA      := _aProdP10[_ni,4]
          TEMP->AGRUP     := _aProdP10[_ni,2]
          TEMP->PRODUTO   := _aProdP10[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP10[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER10     := _aProdP10[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP11)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP11[_ni,3]+_aProdP11[_ni,2]+_aProdP11[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP11[_ni,3] .And. TEMP->AGRUP == _aProdP11[_ni,2] .And. TEMP->PRODUTO == _aProdP11[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER11 += _aProdP11[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER11
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER11 += _aProdP11[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER11 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER11 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP11[_ni,3]
          TEMP->LOJA      := _aProdP11[_ni,4]
          TEMP->AGRUP     := _aProdP11[_ni,2]
          TEMP->PRODUTO   := _aProdP11[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP11[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER11     := _aProdP11[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP11[_ni,3]
          TEMP->LOJA      := _aProdP11[_ni,4]
          TEMP->AGRUP     := _aProdP11[_ni,2]
          TEMP->PRODUTO   := _aProdP11[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP11[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER11     := _aProdP11[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP11[_ni,3]
          TEMP->LOJA      := _aProdP11[_ni,4]
          TEMP->AGRUP     := _aProdP11[_ni,2]
          TEMP->PRODUTO   := _aProdP11[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP11[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER11     := _aProdP11[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni
for _ni := 1 to len(_aProdP12)
    DbSelectArea("TEMP")
    DbSetOrder(1)
    dbGotop()
    If dbSeek(_aProdP12[_ni,3]+_aProdP12[_ni,2]+_aProdP12[_ni,1])
       _nValMed := 0
       _nVolMed := 0
       While TEMP->(!Eof()) .AND. TEMP->CLIENTE == _aProdP12[_ni,3] .And. TEMP->AGRUP == _aProdP12[_ni,2] .And. TEMP->PRODUTO == _aProdP12[_ni,1]              
             IF Alltrim(TEMP->TIPDADO) == "1VALOR"  
                RecLock("TEMP",.F.)
                   TEMP->PER12 += _aProdP12[_ni,5]                                      
                TEMP->(MsUnlock())
                _nValMed += TEMP->PER12
             Elseif Alltrim(TEMP->TIPDADO) == "2VOLUME"  
                RecLock("TEMP",.F.)
                   TEMP->PER12 += _aProdP12[_ni,6]                                      
                TEMP->(MsUnlock())
                _nVolMed += TEMP->PER12 
             Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"  
                RecLock("TEMP",.F.)
                   TEMP->PER12 += (_nValMed / _nVolMed)                                      
                TEMP->(MsUnlock())   
             Endif   
             TEMP->(dbSkip()) 
       Enddo
    Else   
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP12[_ni,3]
          TEMP->LOJA      := _aProdP12[_ni,4]
          TEMP->AGRUP     := _aProdP12[_ni,2]
          TEMP->PRODUTO   := _aProdP12[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP12[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "1VALOR"
          TEMP->PER12     := _aProdP12[_ni,5]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP12[_ni,3]
          TEMP->LOJA      := _aProdP12[_ni,4]
          TEMP->AGRUP     := _aProdP12[_ni,2]
          TEMP->PRODUTO   := _aProdP12[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP12[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "2VOLUME"
          TEMP->PER12     := _aProdP12[_ni,6]                      
       TEMP->(MsUnlock())
       RecLock("TEMP",.T.)
          TEMP->CLIENTE   := _aProdP12[_ni,3]
          TEMP->LOJA      := _aProdP12[_ni,4]
          TEMP->AGRUP     := _aProdP12[_ni,2]
          TEMP->PRODUTO   := _aProdP12[_ni,1]
          TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP12[_ni,1],"B1_DESC")
          TEMP->TIPDADO   := "3MEDIO"
          TEMP->PER12     := _aProdP12[_ni,7]                      
       TEMP->(MsUnlock())
    Endif
Next _ni

DbSelectArea("TEMP")
DbGotop()
While TEMP->(!Eof())
      IF Alltrim(TEMP->TIPDADO) == "2VOLUME"
         _cVol1 := TEMP->PER01
         _cVol2 := TEMP->PER02
         _cVol3 := TEMP->PER03
         _cVol4 := TEMP->PER04
         _cVol5 := TEMP->PER05
         _cVol6 := TEMP->PER06
         _cVol7 := TEMP->PER07
         _cVol8 := TEMP->PER08
         _cVol9 := TEMP->PER09
         _cVol10 := TEMP->PER10
         _cVol11 := TEMP->PER11
         _cVol12 := TEMP->PER12
      Elseif Alltrim(TEMP->TIPDADO) == "1VALOR"
         _cVal1 := TEMP->PER01
         _cVal2 := TEMP->PER02
         _cVal3 := TEMP->PER03
         _cVal4 := TEMP->PER04
         _cVal5 := TEMP->PER05
         _cVal6 := TEMP->PER06
         _cVal7 := TEMP->PER07
         _cVal8 := TEMP->PER08
         _cVal9 := TEMP->PER09
         _cVal10 := TEMP->PER10
         _cVal11 := TEMP->PER11
         _cVal12 := TEMP->PER12
      Elseif Alltrim(TEMP->TIPDADO) == "3MEDIO"
         Reclock("TEMP",.F.)
            TEMP->PER01 := _cVal1/_cVol1
            TEMP->PER02 := _cVal2/_cVol2
            TEMP->PER03 := _cVal3/_cVol3
            TEMP->PER04 := _cVal4/_cVol4
            TEMP->PER05 := _cVal5/_cVol5
            TEMP->PER06 := _cVal6/_cVol6
            TEMP->PER07 := _cVal7/_cVol7
            TEMP->PER08 := _cVal8/_cVol8
            TEMP->PER09 := _cVal9/_cVol9
            TEMP->PER10 := _cVal10/_cVol10
            TEMP->PER11 := _cVal11/_cVol11
            TEMP->PER12 := _cVal12/_cVol12              
         TEMP->(MsUnlock())
      ENDIF
      TEMP->(DbSkip())   
Enddo

 
&&Mauricio - 08/08/14 - tratamento para saida em excel..
&&Mauricio 20/02/13 - tratamento para saida Excel solicitada pelo Sr. Vagner.
cPath    := AllTrim(GetTempPath())
cArq     := "PERFORCLI.CSV"
            
if file("C:\PERFORCLI.CSV")
	FErase("C:\PERFORCLI.CSV")		
endif

if file(cPath+"\PERFORCLI.CSV")
	FErase(cPath+"\PERFORCLI.CSV")		
endif

if file("\SYSTEM\PERFORCLI.CSV")
	FErase("\SYSTEM\PERFORCLI.CSV")
endif

nHdl := fCreate(cArq,0)
_Vazia := ";;;;;;;;;;;;;;;;"+_Eof

fWrite(nHdl,cLin1,Len(cLin1))
fWrite(nHdl,_Vazia,Len(_Vazia))

_nTotGer1  := 0
_nTotGer2  := 0
_nTotGer3  := 0
_nTotGer4  := 0
_nTotGer5  := 0
_nTotGer6  := 0
_nTotGer7  := 0
_nTotGer8  := 0
_nTotGer9  := 0
_nTotGer10 := 0
_nTotGer11 := 0
_nTotGer12 := 0
_nTotGerT  := 0

&&Na impressao do relatorio, vou ter de imprimir 3 partes distintas...valor, volume e preco medio....
&&primeiro parte é o volume acompanhando desenho do Vagner...
DbSelectArea("TEMP")
DbGotop()
_nTotVol1  := 0
_nTotVol2  := 0
_nTotVol3  := 0
_nTotVol4  := 0
_nTotVol5  := 0
_nTotVol6  := 0
_nTotVol7  := 0
_nTotVol8  := 0
_nTotVol9  := 0
_nTotVol10 := 0
_nTotVol11 := 0
_nTotVol12 := 0
_nTotQtd1  := 0
_nTotQtd2  := 0
_nTotQtd3  := 0
_nTotQtd4  := 0
_nTotQtd5  := 0
_nTotQtd6  := 0
_nTotQtd7  := 0
_nTotQtd8  := 0
_nTotQtd9  := 0
_nTotQtd10 := 0
_nTotQtd11 := 0
_nTotQtd12 := 0
_nTotVolT  := 0
_nVez := 1
_nImpV := 1
While TEMP->(!Eof())
      _cIMPCLI := TEMP->CLIENTE
      _cIMPLOJ := TEMP->LOJA
      _cAGrupo := TEMP->AGRUP
      _cTpDado := TEMP->TIPDADO  
      _cIMPNOM := Alltrim(Posicione("SA1",1,xfilial("SA1")+_cIMPCLI+_cIMPLOJ,"A1_NOME"))      
      DbSelectArea("TEMP")
	  If lAbortPrint
		 @nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		 Exit
	  Endif
	  	 
	  If nLin > 60
		 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 nLin := 8
	  Endif
	  IF _nVez == 1
	     cLin := ""	    
	     @nLin,000 Psay "Cliente: "+_cIMPCLI+"-"+_cIMPLOJ+" "+_cIMPNOM 
	     cLin += "CLIENTE:;"+_cIMPCLI+"-"+_cIMPLOJ+";"+_cIMPNOM+";"+_Eof
	     fWrite(nHdl,cLin,Len(cLin))
	     fWrite(nHdl,_Vazia,Len(_Vazia))  
	     nLin ++
	     nLin ++ 
	     _nVez ++
	  ENDIF   
	  _nTotLin   := 0
	  _nTotCol1  := 0
	  _nTotCol2  := 0
	  _nTotCol3  := 0
	  _nTotCol4  := 0
	  _nTotCol5  := 0
	  _nTotCol6  := 0
	  _nTotCol7  := 0
	  _nTotCol8  := 0
	  _nTotCol9  := 0
	  _nTotCol10 := 0
	  _nTotCol11 := 0
	  _nTotCol12 := 0
	  _nTotColT  := 0
	  
	  IF MV_PAR06 == 1 .Or. MV_PAR06 == 2  &&tudo ou volume apenas
	     	     
	     If _nImpV == 1 
	        @nLin,070 Psay "---------------------------  V O L U M E  ------------------------------------"
	        cLin := ""
	       cLin += "VOLUME:"+";"+_Eof
	       fWrite(nHdl,cLin,Len(cLin))
	       fWrite(nHdl,_Vazia,Len(_Vazia)) 
	       nLin ++
	       //nLin ++
	       _nImpV ++
	  	 Endif
	  	  	  	  
	     While TEMP->(!Eof()) .And. TEMP->CLIENTE+TEMP->LOJA == _cIMPCLI+_cIMPLOJ .And. _cAgrupo == TEMP->AGRUP  &&quebra por agrupamento
	           _nTotLin := 0
	           If lAbortPrint
		          @nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		          Exit
	           Endif
	  	 
	           If nLin > 60
		          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		          nLin := 8
	           Endif
	  
	           If Alltrim(TEMP->TIPDADO) == "2VOLUME"   &&volume primeiro
	              _nTotal := 0
	              cLin := ""
	              @ nLin, 000			PSAY TEMP->AGRUP
	              cLin += TEMP->AGRUP+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PRODUTO
	              cLin += TEMP->PRODUTO+";"
	              @ nLin, Pcol()+001	PSAY TEMP->DESCRICAO
	              cLin += TEMP->DESCRICAO+";"	           	           
	              @ nLin, Pcol()+002	PSAY TEMP->PER01 Picture "@E 99,999,999"	  
	              cLin += Transform(TEMP->PER01,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER02 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER02,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER03 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER03,"@E 99,999,999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER04 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER04,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER05 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER05,"@E 99,999,999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER06 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER06,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER07 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER07,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER08 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER08,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER09 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER09,"@E 99,999,999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER10 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER10,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER11 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER11,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER12 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER12,"@E 99,999,999")+";" 	  
	  
	              _nToTlin += TEMP->PER01
	              _nToTlin += TEMP->PER02
	              _nToTlin += TEMP->PER03
	              _nToTlin += TEMP->PER04
	              _nToTlin += TEMP->PER05
	              _nToTlin += TEMP->PER06
	              _nToTlin += TEMP->PER07
	              _nToTlin += TEMP->PER08
	              _nToTlin += TEMP->PER09
	              _nToTlin += TEMP->PER10
	              _nToTlin += TEMP->PER11
	              _nToTlin += TEMP->PER12 
	           
	              _nTotCol1  += TEMP->PER01
	              _nTotCol2  += TEMP->PER02
	              _nTotCol3  += TEMP->PER03
	              _nTotCol4  += TEMP->PER04
	              _nTotCol5  += TEMP->PER05
	              _nTotCol6  += TEMP->PER06
	              _nTotCol7  += TEMP->PER07
	              _nTotCol8  += TEMP->PER08
	              _nTotCol9  += TEMP->PER09
	              _nTotCol10 += TEMP->PER10
	              _nTotCol11 += TEMP->PER11
	              _nTotCol12 += TEMP->PER12
	              _nTotColT  += _nTotLin
	              @ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
	              cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof  	 	
	              fWrite(nHdl,cLin,Len(cLin))	  	  	  
	              nLin++	 
	  	  	   Endif  	  	
               TEMP->(dbSkip())
         Enddo           	  
         _nTotLin := 0
         //nLin++
         If nLin > 60
		    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		    nLin := 8
	     Endif
      
         cLin := ""
	     @ nLin, 000			PSAY "Total: "+_cAgrupo
	     cLin += "Total: "+_cAgrupo+";"
         //@ nLin, Pcol()+002	PSAY TEMP->PRODUTO
	     cLin += ";"
	     //@ nLin, Pcol()+002	PSAY TEMP->DESCRICAO
	     cLin += ";"	           	           
	     @ nLin, Pcol()+043	PSAY _nTotCol1 Picture "@E 99,999,999"	  //54
	     cLin += Transform(_nTotCol1,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol2 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol2,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol3 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol3,"@E 99,999,999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotCol4 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol4,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol5 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol5,"@E 99,999,999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotCol6 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol6,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol7 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol7,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol8 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol8,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol9 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol9,"@E 99,999,999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotCol10 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol10,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol11 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol11,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol12 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol12,"@E 99,999,999")+";" 	  
	  
	     _nToTlin += _nTotCol1
	     _nToTlin += _nTotCol2
	     _nToTlin += _nTotCol3
	     _nToTlin += _nTotCol4
	     _nToTlin += _nTotCol5
	     _nToTlin += _nTotCol6
	     _nToTlin += _nTotCol7
	     _nToTlin += _nTotCol8
	     _nToTlin += _nTotCol9
	     _nToTlin += _nTotCol10
	     _nToTlin += _nTotCol11
	     _nToTlin += _nTotCol12
	           
	     _nTotVol1  += _nTotCol1
	     _nTotVol2  += _nTotCol2
	     _nTotVol3  += _nTotCol3
	     _nTotVol4  += _nTotCol4
	     _nTotVol5  += _nTotCol5
	     _nTotVol6  += _nTotCol6
	     _nTotVol7  += _nTotCol7
	     _nTotVol8  += _nTotCol8
	     _nTotVol9  += _nTotCol9
	     _nTotVol10 += _nTotCol10
	     _nTotVol11 += _nTotCol11
	     _nTotVol12 += _nTotCol12
	     _nTotVolT  += _nTotLin
	     @ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
	     cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof  	 	
	     fWrite(nHdl,cLin,Len(cLin))	  	  	  
	     nLin++      
         //nLin++
      Else
        DbSelectArea("TEMP")
        exit    
      Endif         
Enddo

IF MV_PAR06 == 1 .OR. MV_PAR06 == 2

&&Impressao do total geral do VOLUME...
If nLin > 60
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 8
Endif
_nTotLin := 0
cLin := ""
@ nLin, 000			PSAY "Total Geral Volume "
cLin += "Total;"
//@ nLin, Pcol()+002	PSAY TEMP->PRODUTO
cLin += "Geral;"
//@ nLin, Pcol()+002	PSAY TEMP->DESCRICAO
cLin += "Volume;"	           	           
@ nLin, Pcol()+033	PSAY _nTotVol1 Picture "@E 99,999,999"	    //44
cLin += Transform(_nTotVol1,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol2 Picture "@E 99,999,999"
cLin += Transform(_nTotVol2,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol3 Picture "@E 99,999,999"
cLin += Transform(_nTotVol3,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol4 Picture "@E 99,999,999"
cLin += Transform(_nTotVol4,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol5 Picture "@E 99,999,999"
cLin += Transform(_nTotVol5,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol6 Picture "@E 99,999,999"
cLin += Transform(_nTotVol6,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol7 Picture "@E 99,999,999"
cLin += Transform(_nTotVol7,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol8 Picture "@E 99,999,999"
cLin += Transform(_nTotVol8,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol9 Picture "@E 99,999,999"
cLin += Transform(_nTotVol9,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol10 Picture "@E 99,999,999"
cLin += Transform(_nTotVol10,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol11 Picture "@E 99,999,999"
cLin += Transform(_nTotVol11,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol12 Picture "@E 99,999,999"
cLin += Transform(_nTotVol12,"@E 99,999,999")+";" 	  
	  
_nToTlin += _nTotVol1
_nToTlin += _nTotVol2
_nToTlin += _nTotVol3
_nToTlin += _nTotVol4
_nToTlin += _nTotVol5
_nToTlin += _nTotVol6
_nToTlin += _nTotVol7
_nToTlin += _nTotVol8
_nToTlin += _nTotVol9
_nToTlin += _nTotVol10
_nToTlin += _nTotVol11
_nToTlin += _nTotVol12
	           
_nTotGer1  += _nTotVol1
_nTotGer2  += _nTotVol2
_nTotGer3  += _nTotVol3
_nTotGer4  += _nTotVol4
_nTotGer5  += _nTotVol5
_nTotGer6  += _nTotVol6
_nTotGer7  += _nTotVol7
_nTotGer8  += _nTotVol8
_nTotGer9  += _nTotVol9
_nTotGer10 += _nTotVol10
_nTotGer11 += _nTotVol11
_nTotGer12 += _nTotVol12
_nTotGerT  += _nTotLin
@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof  	 	
fWrite(nHdl,cLin,Len(cLin))	  	  	  
nLin++
//nLin++
ENDIF

//nLin := 80

IF MV_PAR06 == 1 .Or. MV_PAR06 == 3    &&Impressao do VALOR

DbSelectArea("TEMP")
DbGotop()
_nTotVol1  := 0
_nTotVol2  := 0
_nTotVol3  := 0
_nTotVol4  := 0
_nTotVol5  := 0
_nTotVol6  := 0
_nTotVol7  := 0
_nTotVol8  := 0
_nTotVol9  := 0
_nTotVol10 := 0
_nTotVol11 := 0
_nTotVol12 := 0
_nTotVolT  := 0
_nVez := 1
While TEMP->(!Eof())
      _cIMPCLI := TEMP->CLIENTE
      _cIMPLOJ := TEMP->LOJA
      _cAGrupo := TEMP->AGRUP
      _cTpDado := TEMP->TIPDADO  
      _cIMPNOM := Alltrim(Posicione("SA1",1,xfilial("SA1")+_cIMPCLI+_cIMPLOJ,"A1_NOME"))      
      DbSelectArea("TEMP")
	  If lAbortPrint
		 @nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		 Exit
	  Endif
	  	 
	  If nLin > 60
		 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 nLin := 8
	  Endif
	     
	  _nTotLin   := 0
	  _nTotCol1  := 0
	  _nTotCol2  := 0
	  _nTotCol3  := 0
	  _nTotCol4  := 0
	  _nTotCol5  := 0
	  _nTotCol6  := 0
	  _nTotCol7  := 0
	  _nTotCol8  := 0
	  _nTotCol9  := 0
	  _nTotCol10 := 0
	  _nTotCol11 := 0
	  _nTotCol12 := 0
	  _nTotColT  := 0
	  	  
	  If _nVez == 1 	    
	     @nLin,070 Psay "-----------------------  F A T U R A M E N T O  ------------------------------"
	     cLin := ""
	     cLin += "FATURAMENTO:"+";"+_Eof
	     fWrite(nHdl,cLin,Len(cLin))
	     fWrite(nHdl,_Vazia,Len(_Vazia)) 
	     nLin ++
	     //nLin ++
	     _nVez ++
	  ENDIF   
	  	  	  	  
	     While TEMP->(!Eof()) .And. TEMP->CLIENTE+TEMP->LOJA == _cIMPCLI+_cIMPLOJ .And. _cAgrupo == TEMP->AGRUP  &&quebra por agrupamento
	           _nTotLin := 0
	           If lAbortPrint
		          @nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		          Exit
	           Endif
	  	 
	           If nLin > 60
		          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		          nLin := 8
	           Endif
	  
	           If Alltrim(TEMP->TIPDADO) == "1VALOR"   &&valores
	              _nTotal := 0
	              cLin := ""
	              @ nLin, 000			PSAY TEMP->AGRUP
	              cLin += TEMP->AGRUP+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PRODUTO
	              cLin += TEMP->PRODUTO+";"
	              @ nLin, Pcol()+001	PSAY TEMP->DESCRICAO
	              cLin += TEMP->DESCRICAO+";"	           	           
	              @ nLin, Pcol()+002	PSAY TEMP->PER01 Picture "@E 99,999,999"	  
	              cLin += Transform(TEMP->PER01,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER02 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER02,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER03 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER03,"@E 99,999,999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER04 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER04,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER05 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER05,"@E 99,999,999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER06 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER06,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER07 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER07,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER08 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER08,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER09 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER09,"@E 99,999,999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER10 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER10,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER11 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER11,"@E 99,999,999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER12 Picture "@E 99,999,999"
	              cLin += Transform(TEMP->PER12,"@E 99,999,999")+";" 	  
	  
	              _nToTlin += TEMP->PER01
	              _nToTlin += TEMP->PER02
	              _nToTlin += TEMP->PER03
	              _nToTlin += TEMP->PER04
	              _nToTlin += TEMP->PER05
	              _nToTlin += TEMP->PER06
	              _nToTlin += TEMP->PER07
	              _nToTlin += TEMP->PER08
	              _nToTlin += TEMP->PER09
	              _nToTlin += TEMP->PER10
	              _nToTlin += TEMP->PER11
	              _nToTlin += TEMP->PER12 
	           
	              _nTotCol1  += TEMP->PER01
	              _nTotCol2  += TEMP->PER02
	              _nTotCol3  += TEMP->PER03
	              _nTotCol4  += TEMP->PER04
	              _nTotCol5  += TEMP->PER05
	              _nTotCol6  += TEMP->PER06
	              _nTotCol7  += TEMP->PER07
	              _nTotCol8  += TEMP->PER08
	              _nTotCol9  += TEMP->PER09
	              _nTotCol10 += TEMP->PER10
	              _nTotCol11 += TEMP->PER11
	              _nTotCol12 += TEMP->PER12
	              _nTotColT  += _nTotLin
	              @ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
	              cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof  	 	
	              fWrite(nHdl,cLin,Len(cLin))	  	  	  
	              nLin++	 
	  	  	   Endif  	  	
               TEMP->(dbSkip())
         Enddo           	  
         _nTotLin := 0
         //nLin++
         If nLin > 60
		    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		    nLin := 8
	     Endif
      
         cLin := ""
	     @ nLin, 000			PSAY "Total: "+_cAgrupo
	     cLin += "Total: "+_cAgrupo+";"
         //@ nLin, Pcol()+002	PSAY TEMP->PRODUTO
	     cLin += ";"
	     //@ nLin, Pcol()+002	PSAY TEMP->DESCRICAO
	     cLin += ";"	           	           
	     @ nLin, Pcol()+043	PSAY _nTotCol1 Picture "@E 99,999,999"	  //54
	     cLin += Transform(_nTotCol1,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol2 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol2,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol3 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol3,"@E 99,999,999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotCol4 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol4,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol5 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol5,"@E 99,999,999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotCol6 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol6,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol7 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol7,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol8 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol8,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol9 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol9,"@E 99,999,999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotCol10 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol10,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol11 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol11,"@E 99,999,999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotCol12 Picture "@E 99,999,999"
	     cLin += Transform(_nTotCol12,"@E 99,999,999")+";" 	  
	  
	     _nToTlin += _nTotCol1
	     _nToTlin += _nTotCol2
	     _nToTlin += _nTotCol3
	     _nToTlin += _nTotCol4
	     _nToTlin += _nTotCol5
	     _nToTlin += _nTotCol6
	     _nToTlin += _nTotCol7
	     _nToTlin += _nTotCol8
	     _nToTlin += _nTotCol9
	     _nToTlin += _nTotCol10
	     _nToTlin += _nTotCol11
	     _nToTlin += _nTotCol12
	           
	     _nTotVol1  += _nTotCol1
	     _nTotVol2  += _nTotCol2
	     _nTotVol3  += _nTotCol3
	     _nTotVol4  += _nTotCol4
	     _nTotVol5  += _nTotCol5
	     _nTotVol6  += _nTotCol6
	     _nTotVol7  += _nTotCol7
	     _nTotVol8  += _nTotCol8
	     _nTotVol9  += _nTotCol9
	     _nTotVol10 += _nTotCol10
	     _nTotVol11 += _nTotCol11
	     _nTotVol12 += _nTotCol12
	     _nTotVolT  += _nTotLin
	     @ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
	     cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof  	 	
	     fWrite(nHdl,cLin,Len(cLin))	  	  	  
	     nLin++
         //nLin++      
Enddo

&&Impressao do total geral do VALOR...
If nLin > 60
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 8
Endif
_nTotLin := 0
cLin := ""               
@ nLin, 000			PSAY "Total Geral Faturamento "
cLin += "Total;"
//@ nLin, Pcol()+002	PSAY TEMP->PRODUTO
cLin += "Geral;"
//@ nLin, Pcol()+002	PSAY TEMP->DESCRICAO
cLin += "Faturamento;"	           	           
@ nLin, Pcol()+028	PSAY _nTotVol1 Picture "@E 99,999,999"	    //39
cLin += Transform(_nTotVol1,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol2 Picture "@E 99,999,999"
cLin += Transform(_nTotVol2,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol3 Picture "@E 99,999,999"
cLin += Transform(_nTotVol3,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol4 Picture "@E 99,999,999"
cLin += Transform(_nTotVol4,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol5 Picture "@E 99,999,999"
cLin += Transform(_nTotVol5,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol6 Picture "@E 99,999,999"
cLin += Transform(_nTotVol6,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol7 Picture "@E 99,999,999"
cLin += Transform(_nTotVol7,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol8 Picture "@E 99,999,999"
cLin += Transform(_nTotVol8,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol9 Picture "@E 99,999,999"
cLin += Transform(_nTotVol9,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol10 Picture "@E 99,999,999"
cLin += Transform(_nTotVol10,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol11 Picture "@E 99,999,999"
cLin += Transform(_nTotVol11,"@E 99,999,999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol12 Picture "@E 99,999,999"
cLin += Transform(_nTotVol12,"@E 99,999,999")+";" 	  
	  
_nToTlin += _nTotVol1
_nToTlin += _nTotVol2
_nToTlin += _nTotVol3
_nToTlin += _nTotVol4
_nToTlin += _nTotVol5
_nToTlin += _nTotVol6
_nToTlin += _nTotVol7
_nToTlin += _nTotVol8
_nToTlin += _nTotVol9
_nToTlin += _nTotVol10
_nToTlin += _nTotVol11
_nToTlin += _nTotVol12
	           
_nTotGer1  += _nTotVol1
_nTotGer2  += _nTotVol2
_nTotGer3  += _nTotVol3
_nTotGer4  += _nTotVol4
_nTotGer5  += _nTotVol5
_nTotGer6  += _nTotVol6
_nTotGer7  += _nTotVol7
_nTotGer8  += _nTotVol8
_nTotGer9  += _nTotVol9
_nTotGer10 += _nTotVol10
_nTotGer11 += _nTotVol11
_nTotGer12 += _nTotVol12
_nTotGerT  += _nTotLin
@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof  	 	
fWrite(nHdl,cLin,Len(cLin))	  	  	  
nLin++
//nLin++

//nLin := 80

ENDIF

IF MV_PAR06 == 1 .Or. MV_PAR06 == 4    &&Impressao do Preco medio

DbSelectArea("TEMP")
DbGotop()
_nTotVol1  := 0
_nTotVol2  := 0
_nTotVol3  := 0
_nTotVol4  := 0
_nTotVol5  := 0
_nTotVol6  := 0
_nTotVol7  := 0
_nTotVol8  := 0
_nTotVol9  := 0
_nTotVol10 := 0
_nTotVol11 := 0
_nTotVol12 := 0
_nTotVolT  := 0
_nVez := 1
_nTGERMED := 0
While TEMP->(!Eof())
      _cIMPCLI := TEMP->CLIENTE
      _cIMPLOJ := TEMP->LOJA
      _cAGrupo := TEMP->AGRUP
      _cTpDado := TEMP->TIPDADO  
      _cIMPNOM := Alltrim(Posicione("SA1",1,xfilial("SA1")+_cIMPCLI+_cIMPLOJ,"A1_NOME"))      
      DbSelectArea("TEMP")
	  If lAbortPrint
		 @nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		 Exit
	  Endif
	  	 
	  If nLin > 60
		 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		 nLin := 8
	  Endif
	     
	  _nTotLin   := 0
	  _nTotCol1  := 0
	  _nTotCol2  := 0
	  _nTotCol3  := 0
	  _nTotCol4  := 0
	  _nTotCol5  := 0
	  _nTotCol6  := 0
	  _nTotCol7  := 0
	  _nTotCol8  := 0
	  _nTotCol9  := 0
	  _nTotCol10 := 0
	  _nTotCol11 := 0
	  _nTotCol12 := 0
	  _nTotColT  := 0
	  
	  If _nVez == 1 	 	   	     
	     @nLin,070 Psay "-----------------------  P R E C O   M E D I O  ------------------------------"
	     cLin := ""
	     cLin += "PRECO MEDIO:"+";"+_Eof
	     fWrite(nHdl,cLin,Len(cLin))
	     fWrite(nHdl,_Vazia,Len(_Vazia)) 
	     nLin ++
	     //nLin ++
	  	 _nVez ++
	 Endif
	  	 _nCountLin := 0
	  	 _nTotQT1   := 0
	  	 _nTotVL1   := 0
	  	 _nTotQT2   := 0
	  	 _nTotVL2   := 0
	  	 _nTotQT3   := 0
	  	 _nTotVL3   := 0
	  	 _nTotQT4   := 0
	  	 _nTotVL4   := 0 
	  	 _nTotQT5   := 0
	  	 _nTotVL5   := 0
	  	 _nTotQT6   := 0
	  	 _nTotVL6   := 0
	  	 _nTotQT7   := 0
	  	 _nTotVL7   := 0
	  	 _nTotQT8   := 0
	  	 _nTotVL8   := 0       	  	  
	  	 _nTotQT9   := 0
	  	 _nTotVL9   := 0
	  	 _nTotQT10   := 0
	  	 _nTotVL10   := 0
	  	 _nTotQT11   := 0
	  	 _nTotVL11   := 0
	  	 _nTotQT12   := 0
	  	 _nTotVL12   := 0
	  	 _nTotQTT    := 0
	  	 _nTotVLT    := 0   
	     While TEMP->(!Eof()) .And. TEMP->CLIENTE+TEMP->LOJA == _cIMPCLI+_cIMPLOJ .And. _cAgrupo == TEMP->AGRUP  &&quebra por agrupamento
	           _nTotLin := 0
	           If lAbortPrint
		          @nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		          Exit
	           Endif
	  	 
	           If nLin > 60
		          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		          nLin := 8
	           Endif
	           
	           If Alltrim(TEMP->TIPDADO) == "2VOLUME"
	              _nTotQT1   += TEMP->PER01	  	         
	  	          _nTotQT2   += TEMP->PER02	  	        
	  	          _nTotQT3   += TEMP->PER03	  	         
	  	          _nTotQT4   += TEMP->PER04
	  	          _nTotQT5   += TEMP->PER05	  	          
	  	          _nTotQT6   += TEMP->PER06	  	         
	  	          _nTotQT7   += TEMP->PER07	  	         
	  	          _nTotQT8   += TEMP->PER08	  	         	  	  
	  	          _nTotQT9   += TEMP->PER09	  	         
	  	          _nTotQT10  += TEMP->PER10	  	          
	  	          _nTotQT11  += TEMP->PER11	  	        
	  	          _nTotQT12  += TEMP->PER12
	  	          _nTotQTT   += (TEMP->PER01+TEMP->PER02+TEMP->PER03+TEMP->PER04+TEMP->PER05+TEMP->PER06+TEMP->PER07+TEMP->PER08+TEMP->PER09+;
	  	                        TEMP->PER10+TEMP->PER11+TEMP->PER12)	  	         	  	 
	           Endif
	           
	           If Alltrim(TEMP->TIPDADO) == "1VALOR"
	              _nTotVL1   += TEMP->PER01	  	         
	  	          _nTotVL2   += TEMP->PER02	  	        
	  	          _nTotVL3   += TEMP->PER03	  	         
	  	          _nTotVL4   += TEMP->PER04
	  	          _nTotVL5   += TEMP->PER05	  	          
	  	          _nTotVL6   += TEMP->PER06	  	         
	  	          _nTotVL7   += TEMP->PER07	  	         
	  	          _nTotVL8   += TEMP->PER08	  	         	  	  
	  	          _nTotVL9   += TEMP->PER09	  	         
	  	          _nTotVL10  += TEMP->PER10	  	          
	  	          _nTotVL11  += TEMP->PER11	  	        
	  	          _nTotVL12  += TEMP->PER12
	  	          _nTotVLT   += (TEMP->PER01+TEMP->PER02+TEMP->PER03+TEMP->PER04+TEMP->PER05+TEMP->PER06+TEMP->PER07+TEMP->PER08+TEMP->PER09+;
	  	                        TEMP->PER10+TEMP->PER11+TEMP->PER12)
	           Endif
	            	  
	           If Alltrim(TEMP->TIPDADO) == "3MEDIO"   &&valores
	              _nTotal := 0
	              cLin := ""
	              @ nLin, 000			PSAY TEMP->AGRUP
	              cLin += TEMP->AGRUP+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PRODUTO
	              cLin += TEMP->PRODUTO+";"
	              @ nLin, Pcol()+001	PSAY TEMP->DESCRICAO
	              cLin += TEMP->DESCRICAO+";"	           	           
	              @ nLin, Pcol()+002	PSAY TEMP->PER01 Picture "@E 99,999.999"	  
	              cLin += Transform(TEMP->PER01,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER02 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER02,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER03 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER03,"@E 99,999.999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER04 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER04,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER05 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER05,"@E 99,999.999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER06 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER06,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER07 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER07,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER08 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER08,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER09 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER09,"@E 99,999.999")+";"
	              @ nLin, Pcol()+002	PSAY TEMP->PER10 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER10,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER11 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER11,"@E 99,999.999")+";" 
	              @ nLin, Pcol()+002	PSAY TEMP->PER12 Picture "@E 99,999.999"
	              cLin += Transform(TEMP->PER12,"@E 99,999.999")+";" 	  
	              /*
	              _nToTlin += TEMP->PER01
	              _nToTlin += TEMP->PER02
	              _nToTlin += TEMP->PER03
	              _nToTlin += TEMP->PER04
	              _nToTlin += TEMP->PER05
	              _nToTlin += TEMP->PER06
	              _nToTlin += TEMP->PER07
	              _nToTlin += TEMP->PER08
	              _nToTlin += TEMP->PER09
	              _nToTlin += TEMP->PER10
	              _nToTlin += TEMP->PER11
	              _nToTlin += TEMP->PER12 
	              */
	              _nToTlin := (_nTotVLT/_nTotQTT)
	              	              	              
	              _nTotCol1  += TEMP->PER01
	              _nTotCol2  += TEMP->PER02
	              _nTotCol3  += TEMP->PER03
	              _nTotCol4  += TEMP->PER04
	              _nTotCol5  += TEMP->PER05
	              _nTotCol6  += TEMP->PER06
	              _nTotCol7  += TEMP->PER07
	              _nTotCol8  += TEMP->PER08
	              _nTotCol9  += TEMP->PER09
	              _nTotCol10 += TEMP->PER10
	              _nTotCol11 += TEMP->PER11
	              _nTotCol12 += TEMP->PER12
	              _nTotColT  += _nTotLin
	              @ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999.999"
	              cLin += Transform(_nTotlin,"@E 99,999.999")+";"+_Eof  	 	
	              fWrite(nHdl,cLin,Len(cLin))	  	  	  
	              nLin++	 
	  	  	   Endif  	  	
               TEMP->(dbSkip())
         Enddo           	  
         _nTotLin := 0
         //nLin++
         If nLin > 60
		    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		    nLin := 8
	     Endif
      
         cLin := ""
	     @ nLin, 000			PSAY "Total: "+_cAgrupo
	     cLin += "Total: "+_cAgrupo+";"
         //@ nLin, Pcol()+002	PSAY TEMP->PRODUTO
	     cLin += ";"
	     //@ nLin, Pcol()+002	PSAY TEMP->DESCRICAO
	     cLin += ";"	           	           
	     @ nLin, Pcol()+043	PSAY _nTotVL1/_nTotQT1 Picture "@E 99,999.999"	  //54
	     cLin += Transform(_nTotVL1/_nTotQT1,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL2/_nTotQT2 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL2/_nTotQT2,"@E 99,999.999")+";"         
	     @ nLin, Pcol()+002	PSAY _nTotVL3/_nTotQT3 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL3/_nTotQT3,"@E 99,999.999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotVL4/_nTotQT4 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL4/_nTotQT4,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL5/_nTotQT5 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL5/_nTotQT5,"@E 99,999.999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotVL6/_nTotQT6 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL6/_nTotQT6,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL7/_nTotQT7 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL7/_nTotQT7,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL8/_nTotQT8 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL8/_nTotQT8,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL9/_nTotQT9 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL9/_nTotQT9,"@E 99,999.999")+";"
	     @ nLin, Pcol()+002	PSAY _nTotVL10/_nTotQT10 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL10/_nTotQT10,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL11/_nTotQT11 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL11/_nTotQT11,"@E 99,999.999")+";" 
	     @ nLin, Pcol()+002	PSAY _nTotVL12/_nTotQT12 Picture "@E 99,999.999"
	     cLin += Transform(_nTotVL12/_nTotQT12,"@E 99,999.999")+";" 	  
	     /*
	     _nToTlin += _nTotCol1
	     _nToTlin += _nTotCol2
	     _nToTlin += _nTotCol3
	     _nToTlin += _nTotCol4
	     _nToTlin += _nTotCol5
	     _nToTlin += _nTotCol6
	     _nToTlin += _nTotCol7
	     _nToTlin += _nTotCol8
	     _nToTlin += _nTotCol9
	     _nToTlin += _nTotCol10
	     _nToTlin += _nTotCol11
	     _nToTlin += _nTotCol12
	     */
	     _nTotLin := (_nTotVL1+_nTotVl2+_nTotVL3+_nTotVL4+_nTotVl5+_nTotVL6+_nTotVL7+_nTotVl8+_nTotVL9+_nTotVL10+_nTotVl11+_nTotVL12)/;
	                 (_nTotQT1+_nTotQT2+_nTotQT3+_nTotQT4+_nTotQT5+_nTotQT6+_nTotQT7+_nTotQT8+_nTotQT9+_nTotQT10+_nTotQT11+_nTotQT12)
	           
	     _nTotVol1  += _nTotVL1
	     _nTotQtd1  += _nTotQT1
	     _nTotVol2  += _nTotVL2
	     _nTotQtd2  += _nTotQT2
	     _nTotVol3  += _nTotVL3
	     _nTotQtd3  += _nTotQT3
	     _nTotVol4  += _nTotVL4
	     _nTotQtd4  += _nTotQT4
	     _nTotVol5  += _nTotVL5
	     _nTotQtd5  += _nTotQT5
	     _nTotVol6  += _nTotVL6
	     _nTotQtd6  += _nTotQT6
	     _nTotVol7  += _nTotVL7
	     _nTotQtd7  += _nTotQT7
	     _nTotVol8  += _nTotVL8
	     _nTotQtd8  += _nTotQT8
	     _nTotVol9  += _nTotVL9
	     _nTotQtd9  += _nTotQT9
	     _nTotVol10 += _nTotVL10
	     _nTotQtd10 += _nTotQT10
	     _nTotVol11 += _nTotVL11
	     _nTotQtd11 += _nTotQT11
	     _nTotVol12 += _nTotVL12
	     _nTotQtd12 += _nTotQT12
	     _nTotVolT  += _nTotLin
	     @ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999.999"
	     cLin += Transform(_nTotlin,"@E 99,999.999")+";"+_Eof  	 	
	     fWrite(nHdl,cLin,Len(cLin))	  	  	  
	     nLin++
         //nLin++      
Enddo

&&Impressao do total geral do VALOR...
If nLin > 60
   Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin := 8
Endif
_nTotLin := 0
cLin := ""               
@ nLin, 000			PSAY "Total Geral Preco Medio "
cLin += "Total;"
//@ nLin, Pcol()+002	PSAY TEMP->PRODUTO
cLin += "Preco;"
//@ nLin, Pcol()+002	PSAY TEMP->DESCRICAO
cLin += "Medio;"	           	           
@ nLin, Pcol()+028	PSAY _nTotVol1/_nTotQtd1 Picture "@E 99,999.999"	//39  
cLin += Transform(_nTotVol1/_nTotQtd1,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol2/_nTotQtd2 Picture "@E 99,999.999"
cLin += Transform(_nTotVol2/_nTotQtd2,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol3/_nTotQtd3 Picture "@E 99,999.999"
cLin += Transform(_nTotVol3/_nTotQtd3,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol4/_nTotQtd4 Picture "@E 99,999.999"
cLin += Transform(_nTotVol4/_nTotQtd4,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol5/_nTotQtd5 Picture "@E 99,999.999"
cLin += Transform(_nTotVol5/_nTotQtd5,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol6/_nTotQtd6 Picture "@E 99,999.999"
cLin += Transform(_nTotVol6/_nTotQtd6,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol7/_nTotQtd7 Picture "@E 99,999.999"
cLin += Transform(_nTotVol7/_nTotQtd7,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol8/_nTotQtd8 Picture "@E 99,999.999"
cLin += Transform(_nTotVol8/_nTotQtd8,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol9/_nTotQtd9 Picture "@E 99,999.999"
cLin += Transform(_nTotVol9/_nTotQtd9,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTotVol10/_nTotQtd10 Picture "@E 99,999.999"
cLin += Transform(_nTotVol10/_nTotQtd10,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol11/_nTotQtd11 Picture "@E 99,999.999"
cLin += Transform(_nTotVol11/_nTotQtd11,"@E 99,999.999")+";" 
@ nLin, Pcol()+002	PSAY _nTotVol12/_nTotQtd12 Picture "@E 99,999.999"
cLin += Transform(_nTotVol12/_nTotQtd12,"@E 99,999.999")+";" 	  
/*	  
_nToTlin += _nTotVol1
_nToTlin += _nTotVol2
_nToTlin += _nTotVol3
_nToTlin += _nTotVol4
_nToTlin += _nTotVol5
_nToTlin += _nTotVol6
_nToTlin += _nTotVol7
_nToTlin += _nTotVol8
_nToTlin += _nTotVol9
_nToTlin += _nTotVol10
_nToTlin += _nTotVol11
_nToTlin += _nTotVol12
*/
_nTotLin := (_nTotVoL1+_nTotVol2+_nTotVoL3+_nTotVoL4+_nTotVol5+_nTotVoL6+_nTotVoL7+_nTotVol8+_nTotVoL9+_nTotVoL10+_nTotVol11+_nTotVoL12)/;
	                 (_nTotQTd1+_nTotQTd2+_nTotQTd3+_nTotQTd4+_nTotQTd5+_nTotQTd6+_nTotQTd7+_nTotQTd8+_nTotQTd9+_nTotQTd10+_nTotQTd11+_nTotQTd12)
	           
_nTotGer1  += _nTotVol1
_nTotGer2  += _nTotVol2
_nTotGer3  += _nTotVol3
_nTotGer4  += _nTotVol4
_nTotGer5  += _nTotVol5
_nTotGer6  += _nTotVol6
_nTotGer7  += _nTotVol7
_nTotGer8  += _nTotVol8
_nTotGer9  += _nTotVol9
_nTotGer10 += _nTotVol10
_nTotGer11 += _nTotVol11
_nTotGer12 += _nTotVol12
_nTotGerT  += _nTotLin
@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999.999"
cLin += Transform(_nTotlin,"@E 99,999.999")+";"+_Eof  	 	
fWrite(nHdl,cLin,Len(cLin))	  	  	  
nLin++
//nLin++

//nLin := 80

ENDIF

//cArqSai := "C:\MPFAT12.CSV"      // Arquivo de Saida

//If File(cArqSai)
//   FErase(cArqSai)
//Endif 

/*
//----> GERA PLANILHA EXCEL
If MV_PAR05 == 1
	_cArquivo := __RELDIR+"RPCPR17.DBF"
	
	dbSelectArea("XLS")
	Copy To &(_cArquivo)
	__COPYFILE (_cArquivo,"C:\RPCPR17.XLS")
	MSGAlert("Planilha gerada: C:\RPCPR17.XLS")
	
	dbCloseArea("XLS")
EndIf
*/
SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH() 

fClose(nHdl)

//----> GERAR PLANILHA EXCEL
If MV_PAR07 == 1
   bBloco:={|| _fOpenExcel()}
   MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)
EndIf

Return()

Static Function _fOpenExcel()

CpyS2T("\SYSTEM\PERFORCLI.CSV",cPath,.T.)

FerasE("\SYSTEM\PERFORCLI.CSV")

//_cArquivo := "\SYSTEM\MPFAT12.CSV"

//__COPYFILE (_cArquivo,"C:\MPFAT12.CSV")

//Copy File &_cArquivo To &cArqSai 
   
//------------------------------
// Abre MS-EXCEL
//------------------------------
If ! ApOleClient( 'MsExcel' )
	MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
	Return
EndIf
oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
//oExcelApp:WorkBooks:Open(cArqSai)
oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
oExcelApp:SetVisible(.T.)

Return()

Static function fBsc12Mes(_dI,_dF,_nPos,_cCli,_cLoj,_nVarej)
_TempMP		:= ""
_Temp		:= ""
aProduto 	:= {}
aQtde		:= {}

&&query e tratamento abaixo vindo igual dos demais relatorios em uso pela ADoro.
If Select("XF2") > 0
   DbSelectArea("XF2")
   DbCloseArea("XF2")
Endif

If _nVarej == 2
	&&Varejo somente
	cQuery:="select F2_FILIAL, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_VEND, A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
	"from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
	"WHERE F2_TIPO='N' and "+;
	"F2_EMISSAO between '"+dtos(_dI)+"' and '"+dtos(_dF)+"' and "+;
	"F2_FILIAL IN ("+ALLTRIM(MV_PAR08)+") and  "+;
	"F2_CLIENTE = '"+_cCli+"' AND F2_LOJA = '"+_cLoj+"' AND "+;
	"F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
	"SF2.D_E_L_E_T_= '' "+;
	"AND SA1.D_E_L_E_T_= '' "+;
	"ORDER BY F2_CLIENTE,F2_LOJA,F2_EMISSAO"
	
	TCQUERY cQuery new alias "XF2"
	DBSELECTAREA("XF2")
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	dbSelectArea("XF2")
	ProcRegua(RecCount())
	XF2->(dbgotop())
	
	_dDataOut	:=	""
	_xPrima		:=	.T.
	DO WHILE !EOF()
		
		IncProc()
		_cVendedor 	:=	XF2->A1_VEND
		_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_CODSUP")
		_cSupUsu    := Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_SUPER")
		_cEmissao 	:=	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
		_cCliente	:=	XF2->F2_CLIENTE
		_nValor		:=	XF2->F2_VALBRUT
		_cFIL       :=  XF2->F2_FILIAL
		_cDOC      	:= 	XF2->F2_DOC
		_cSERIE    	:= 	XF2->F2_SERIE
		_cCLIENTE  	:= 	XF2->F2_CLIENTE
		_cLOJA     	:= 	XF2->F2_LOJA
		
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(_cFil + _cDOC + _cSERIE + _cCLIENTE + _cLOJA)	
		DO WHILE SD2->(!EOF()) .AND. 	SD2->D2_DOC		  	== _cDOC     	.AND. ;
			SD2->D2_FILIAL      == _cFIL     .AND. ;
			SD2->D2_SERIE	  	== _cSERIE  	.AND. ;
			SD2->D2_CLIENTE		== _cCLIENTE .AND. ;
			SD2->D2_LOJA		== _cLOJA
			&&trecho vindo do META05 -Inicio-
			If SD2->D2_TP != "PA"		// se nao for produto acabado desconsidera
				dbSelectArea("SD2")
				SD2->(dbskip())
				LOOP
			Endif
			
			If (LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69" .OR. ;
				LEFT(SD2->D2_CF,4) == "5116" .OR. LEFT(SD2->D2_CF,4) == "6116") .AND. ;
				!(LEFT(SD2->D2_CF,4) $ '5922 6922')
				//REMESSA DESCONSIDERA, POREM CONSIDERA VENDA ENTREGA FUTURA 5922 E 6922
				//REMESSA PARA ENTREGA FUTURA 5116 e 6116 DESCONSIDERA
				dbSelectArea("SD2")
				SD2->(dbskip())
				LOOP
			Endif
			&&Trecho -Fim-		
			_nQtd      		:=	SD2->D2_QUANT
			_cProduto  		:=	SD2->D2_COD
			_nPrecoU		:=	SD2->D2_PRCVEN
			_nValorT		:=	SD2->D2_TOTAL
			_dEmissao		:=	SD2->D2_EMISSAO
			
			//INCLUIDO DANIEL 25/01/07
			//+---------------------+
			//|DEVOLUCAO            |
			//+---------------------+
			_nQtddev		:= SD2->D2_QTDEDEV *(-1)
			_nValdev		:= SD2->D2_VALDEV *(-1)
			_nValorT		+=_nValDev
			_nQtd			+=_nQtdDev
			
			//ALTERADO DANIEL 25/01/07
			//+--------------------------------------------+
			//| Verificando se existe desconto financeiro  |
			//+--------------------------------------------+
			/*
			If (XF2->A1_DESC > 0) .and. (_nValorT>0)
				_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100)
			Endif
			
			// Alex Borges 01/12/11
			_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO)
			_nValorT := _nValorT - ( _Frete * _nQtd )
			*/
			dbSelectArea("SB1") // PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cProduto)
			_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO
			
			dbSelectArea("SBM") // GRUPO DE PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cGrupo)
			_cNivel := SBM->BM_NIVEL
			_cAgrup := SBM->BM_QBRNVL+" "
			If Empty(_cAgrup)
			   _cAgrup := "9 "
			Endif
		    		
			If _cNivel == "3"			   			  		
			   aAdd(aProduto,{_cProduto,_cAgrup,_cCliente,_cLoja,_nValorT,_nQtd,(_nValorT/_nQtd)})				   			   			   			   			   			   					
			Endif
			
			dbSelectArea("SD2")
			SD2->(DbSkip())
		Enddo
		
		dbSelectArea("XF2")
		XF2->(dbskip())
	ENDDO
Else   &&rede
	cQuery:="select F2_FILIAL, F2_VEND1, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
	"from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
	"WHERE F2_TIPO='N' and "+;
	"F2_EMISSAO between '"+dtos(_dI)+"' and '"+dtos(_dF)+"' and "+;
	"F2_FILIAL IN ("+ALLTRIM(MV_PAR08)+") and  "+;
	"A1_REDE = '"+_cCLI+"' AND "+;
	"F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND "+;
	"SF2.D_E_L_E_T_= '' "+;
	"AND SA1.D_E_L_E_T_= '' "+;
	"order by A1_REDE, F2_EMISSAO"
	
	TCQUERY cQuery new alias "XF2"
	DBSELECTAREA("XF2")
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	dbSelectArea("XF2")
	ProcRegua(RecCount())
	XF2->(dbgotop())
	
	_dDataOut	:=	""
	_xPrima		:=	.T.
	DO WHILE !EOF()
		
		IncProc("RD Filial-NFiscal: "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC )
		_cVendedor 	:=	Posicione("SA1",1,xFilial("SA1")+XF2->A1_REDE,"A1_VEND")  && REDE vendedor e supervisor vem do CLIENTE PAI da REDE conf. Vagner e MArcus.  XF2->A1_VEND
		_cSuperv    :=  Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_CODSUP")
		_cSupUsu    :=  Posicione("SA3",1,xFilial("SA3")+_cVendedor,"A3_SUPER")
		_cEmissao 	:=	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
		_nValor		:=	XF2->F2_VALBRUT
		_cFIL       :=  XF2->F2_FILIAL
		_cDOC      	:= 	XF2->F2_DOC
		_cSERIE    	:= 	XF2->F2_SERIE
		_cCLIENTE  	:= 	XF2->F2_CLIENTE
		_cLOJA     	:= 	XF2->F2_LOJA
		_cRede      :=  XF2->A1_REDE
		
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek(_cFil + _cDOC + _cSERIE + _cCLIENTE + _cLOJA)
	      
		DO WHILE SD2->(!EOF()) .AND. 	SD2->D2_DOC		  	== _cDOC     	.AND. ;
			SD2->D2_FILIAL      == _cFIL     .AND. ;
			SD2->D2_SERIE	  	== _cSERIE  	.AND. ;
			SD2->D2_CLIENTE		== _cCLIENTE .AND. ;
			SD2->D2_LOJA		== _cLOJA
			&&trecho vindo do META05 -Inicio-
			If SD2->D2_TP != "PA"		// se nao for produto acabado desconsidera
				dbSelectArea("SD2")
				SD2->(dbskip())
				LOOP
			Endif
			
			If (LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69" .OR. ;
				LEFT(SD2->D2_CF,4) == "5116" .OR. LEFT(SD2->D2_CF,4) == "6116") .AND. ;
				!(LEFT(SD2->D2_CF,4) $ '5922 6922')
				//REMESSA DESCONSIDERA, POREM CONSIDERA VENDA ENTREGA FUTURA 5922 E 6922
				//REMESSA PARA ENTREGA FUTURA 5116 e 6116 DESCONSIDERA
				dbSelectArea("SD2")
				SD2->(dbskip())
				LOOP
			Endif
			&&Trecho -Fim-
		                  
			_nQtd      		:=	SD2->D2_QUANT
			_cProduto  		:=	SD2->D2_COD
			_nPrecoU		:=	SD2->D2_PRCVEN
			_nValorT		:=	SD2->D2_TOTAL
			_dEmissao		:=	SD2->D2_EMISSAO
		      	      
			//INCLUIDO DANIEL 25/01/07
			//+---------------------+               
			//|DEVOLUCAO            |
			//+---------------------+
		   	_nQtddev		:= SD2->D2_QTDEDEV *(-1)
			_nValdev		:= SD2->D2_VALDEV *(-1)
			_nValorT		+=_nValDev
			_nQtd			+=_nQtdDev
			
			//ALTERADO DANIEL 25/01/07
			//+--------------------------------------------+
			//| Verificando se existe desconto financeiro  |
			//+--------------------------------------------+
			/*
			If (XF2->A1_DESC > 0) .and. (_nValorT>0)
				_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100)
			Endif
			
			// Alex Borges 01/12/11
			_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO)
			_nValorT := _nValorT - ( _Frete * _nQtd )
			*/
			dbSelectArea("SB1") // PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cProduto)
			_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO
			
			dbSelectArea("SBM") // GRUPO DE PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cGrupo)
			_cNivel := SBM->BM_NIVEL
			_cAgrup := SBM->BM_QBRNVL+" "
			If Empty(_cAgrup)
			   _cAgrup := "9 "
			Endif
		    		
			If _cNivel == "3"			   			  		
			   aAdd(aProduto,{_cProduto,_cAgrup,_cCli,_cLoj,_nValorT,_nQtd,(_nValorT/_nQtd)})				   			   			   			   			   			   					
			Endif    		
			
			dbSelectArea("SD2")
			SD2->(DbSkip())
		Enddo
		
		dbSelectArea("XF2")
		XF2->(dbskip())
	ENDDO
Endif

dbCloseArea("XF2")

If _nPos == 1
   _aProdP1 := aProduto
Elseif _nPos == 2
   _aProdP2 := aProduto
Elseif _nPos == 3
   _aProdP3 := aProduto
Elseif _nPos == 4
   _aProdP4 := aProduto
Elseif _nPos == 5
   _aProdP5 := aProduto        
Elseif _nPos == 6
   _aProdP6 := aProduto   
Elseif _nPos == 7
   _aProdP7 := aProduto
Elseif _nPos == 8
   _aProdP8 := aProduto
Elseif _nPos == 9
   _aProdP9 := aProduto
Elseif _nPos == 10
   _aProdP10 := aProduto
Elseif _nPos == 11
   _aProdP11 := aProduto
Elseif _nPos == 12
   _aProdP12 := aProduto
Endif   

Return()

static function fbuscafrt(_cF,_cPedido)

Local _cPedido
Local _cF
Local _nFrete := 0

DbSelectArea("SC5")
DbSetOrder(1)
if dbSeek(_cF+_cPedido)
      if (ALLTRIM(SC5->C5_TPFRETE) = "C")    // ALEX BORGES    16/12/11    Para considerar frete caso o pedido for CIF
      		_nFrete := SC5->C5_FRETAPV
      Else
       		_nFrete := 0
      End If
      
Endif

Return(_nFrete) 