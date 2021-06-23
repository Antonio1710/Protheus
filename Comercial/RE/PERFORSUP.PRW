#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
/*                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERFORSUP³ Autor ³ Mauricio - MDS TEC      ³ Data ³ 22/10/2014 ³±±               
±±³          ³          ³       ³ 						  ³      ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Performance dos Supervisores em periodo maximo de ³±±
±±³          ³ 12 meses.                                                      ³±±
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
User Function PERFORSUP()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Impressao de relatorio de performance de supervisores "
Local cDesc2         := "com periodo maximo de 12 meses e "
Local cDesc3         := "conforme parametros."
Local cPict          := ""
Local titulo         := "Performance de Supervisores - maximo 12 meses"
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
Private nomeprog     := "PERFORSUP"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "PERFORSUP"
Private cString 	 := "SD2"
Private cPerg   	 := "PERFSUP"
Private nOrdem
Private cArq
Private oExcelApp
Private _Eof 	:= Chr(13) + Chr(10)
Private cLin := ""
Private cLin1 := ""
Private cLin2 := ""
Private _cSUPPAI   := ""
Private _cDESCPAI  := ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Performance dos Supervisores em periodo maximo de 12 meses')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PutSX1(cPerg,"01","Data De ","Data De ","Data De ","mv_ch1","D",8,0,0,"G","","   ","","","mv_par01" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"02","Data Ate","Data Ate","Data Ate","mv_ch2","D",8,0,0,"G","","   ","","","mv_par02" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"03","Supervisor De" ,"Supervisor De","Supervisor De","mv_ch3","C",6,0,0,"G","","A06","","","mv_par03" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"04","Supervisor Ate","Supervisor Ate","Supervisor Ate","mv_ch4","C",6,0,0,"G","","A06","","","mv_par04" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
//PutSX1(cPerg,"05","Escolha tipo Cliente","Escolha tipo Cliente"	,"Escolha tipo Cliente","mv_ch5","N",01,0,01,"C","","","","","mv_par05" ,"Rede","Rede","Rede","","Varejo","Varejo","Varejo","","","","","","","",""," ")
PutSx1(cPerg,"05","Imprime?"       ,"Imprime?"          ,"Imprime?"       ,"mv_ch5","N",01,0,01,"C","","","","","mv_par05" ,"Tudo","Tudo","Tudo","","Volume","Volume","Volume","Valor","Valor","Valor","Preco Medio","Preco Medio","Preco Medio","","","")
PutSX1(cPerg,"06","Gera em Excel ?","Gera em Excel ?"	,"Gera em Excel ?","mv_ch6","N",01,0,01,"C","","","","","mv_par06" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")
PutSx1(cPerg,"07","Seleciona filiais"  ,"Seleciona filiais"  ,"Seleciona filiais"  ,"mv_ch7","C",50,0,0,"G","U_FXFIL()","","","","mv_par07","","","","","","","","","","","","","","","","","","","")

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

aCampos := {}

If Select("TEMP") > 0
	DbSelectArea("TEMP")
	DbCloseArea("TEMP")
Endif

AADD(aCampos,{"CLIENTE"   , "C", 006,0})
AADD(aCampos,{"LOJA"      , "C", 002,0})
AADD(aCampos,{"AGRUP"     , "C", 002,0})
AADD(aCampos,{"PRODUTO"   , "C", 015,0})
AADD(aCampos,{"DESCRICAO" , "C", 040,0})
AADD(aCampos,{"TIPDADO"   , "C", 010,0})
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

If Select("TEMM") > 0
	DbSelectArea("TEMM")
	DbCloseArea("TEMM")
Endif

aCampos := {}
      
AADD(aCampos,{"CLIENTE"   , "C", 006,0})
AADD(aCampos,{"LOJA"      , "C", 002,0})
AADD(aCampos,{"AGRUP"     , "C", 002,0})
AADD(aCampos,{"PRODUTO"   , "C", 015,0})
AADD(aCampos,{"DESCRICAO" , "C", 040,0})
AADD(aCampos,{"TIPDADO"   , "C", 010,0})
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
AADD(aCampos,{"TOTALV"    , "N", 014,4})
AADD(aCampos,{"TOTALF"    , "N", 014,4})
_cNomTrb2 := CriaTrab(aCampos)
dbUseArea(.T.,,_cNomTrb2,"TEMM",.F.,.F.)

cIndex2   := "CLIENTE+TIPDADO+AGRUP+PRODUTO"
IndRegua( "TEMM", _cNomTrb2, cIndex2,,,"Criando Indice ..." )

dbSelectArea("TEMM")
dbSetOrder(1)

&&Apuração do Range de vendedores a serem considerados baseado nos parametros dos supervisores...
_aUsuSup := {}
_aCodSup := {}
_cSupVends := ""
_cSUPPAI   := ""
_cDESCPAI  := ""
IF Empty(MV_PAR03)  &&se primeiro parametro em branco, so pode ser DE/Ate todos...
   MsgInfo("Parametro de supervisor não pode ser deixado em branco!","Atençao")
   Return()
Else
   DbSelectArea("SZR")         &&por limitação do ADVPL com query considerado apenas o codigo contido no primeiro parametro(apenas um supervisor)
   DbSetOrder(1)
   DbGotop()
   If dbSeek(xFilial("SZR")+MV_PAR03)
      _cSUPPAI  := SZR->ZR_CODIGO
      _cDESCPAI := SZR->ZR_DESCRIC
      While SZR->(!Eof()) .And. SZR->ZR_CODIGO == MV_PAR03
         AADD(_aUsuSup,{SZR->ZR_USER})
         SZR->(DbSkip())
      Enddo
   Endif
Endif
_cSupV := ""
If len(_aUsuSup) > 0
   For _ni := 1 to len(_aUsuSup)
       dbSelectArea("SA3")
	   dbSetOrder(7)       
	   If dbSeek( xFilial("SA3")+_aUsuSup[_ni][1] )			    
		 While SA3->(!Eof()) .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
			   _aUsuSup[_ni][1]       == SA3->A3_CODUSR
			   AADD(_aCodSup,{SA3->A3_SUPER})							
			   SA3->(dbSkip())
		 Enddo
	  Endif   	 				  
   Next _ni
   _cSupV  := ""
   For _ni := 1 to len(_aCodSup)
	   dbSelectArea("SA3")
       dbSetOrder(5)        // A3_FILIAL+A3_SUPER
	   If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )			    
	      Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
				 				  _aCodSup[_ni][1]       == SA3->A3_SUPER
		     _cSupV  :=  _cSupV + SA3->A3_COD+";" 							
	         SA3->(dbSkip())
	      Enddo
	  Endif   	 				  
   Next _ni
Else
   MsgInfo("Verifique os parametros dos supervisores pois não houve retorno correto!","Atenção")
   Return()
Endif

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

Cabec1 := "Grupo Produto          Descricao                                   "+Substr(MesExtenso(month(_dPer1)),1,3)+"/"+RIGHT(Alltrim(STR(year(_dPer1))),2)+Space(6)+;
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
			fBsc12Mes(_dPer1,Lastday(_dPer1),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer1 >= MV_PAR01 .AND. Lastday(_dPer1) > MV_PAR02
			fBsc12Mes(_dPer1,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer1 < MV_PAR01 .AND. Lastday(_dPer1) >= MV_PAR01
			If Lastday(_dPer1) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer1),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer1 < MV_PAR01 .And. Lastday(_dPer1) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 2
		If _dPer2 >= MV_PAR01 .AND. Lastday(_dPer2) <= MV_PAR02
			fBsc12Mes(_dPer2,Lastday(_dPer2),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer2 >= MV_PAR01 .AND. Lastday(_dPer2) > MV_PAR02
			fBsc12Mes(_dPer2,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer2 < MV_PAR01 .AND. Lastday(_dPer2) >= MV_PAR01
			If Lastday(_dPer2) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer2),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer2 < MV_PAR01 .And. Lastday(_dPer2) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
		
	elseif _nPer == 3
		If _dPer3 >= MV_PAR01 .AND. Lastday(_dPer3) <= MV_PAR02
			fBsc12Mes(_dPer3,Lastday(_dPer3),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer3 >= MV_PAR01 .AND. Lastday(_dPer3) > MV_PAR02
			fBsc12Mes(_dPer3,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer3 < MV_PAR01 .AND. Lastday(_dPer3) >= MV_PAR01
			If Lastday(_dPer3) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer3),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer3 < MV_PAR01 .And. Lastday(_dPer3) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 4
		If _dPer4 >= MV_PAR01 .AND. Lastday(_dPer4) <= MV_PAR02
			fBsc12Mes(_dPer4,Lastday(_dPer4),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer4 >= MV_PAR01 .AND. Lastday(_dPer4) > MV_PAR02
			fBsc12Mes(_dPer4,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer4 < MV_PAR01 .AND. Lastday(_dPer4) >= MV_PAR01
			If Lastday(_dPer4) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer4),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer4 < MV_PAR01 .And. Lastday(_dPer4) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 5
		If _dPer5 >= MV_PAR01 .AND. Lastday(_dPer5) <= MV_PAR02
			fBsc12Mes(_dPer5,Lastday(_dPer5),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer5 >= MV_PAR01 .AND. Lastday(_dPer5) > MV_PAR02
			fBsc12Mes(_dPer5,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer5 < MV_PAR01 .AND. Lastday(_dPer5) >= MV_PAR01
			If Lastday(_dPer5) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer5),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer5 < MV_PAR01 .And. Lastday(_dPer5) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 6
		If _dPer6 >= MV_PAR01 .AND. Lastday(_dPer6) <= MV_PAR02
			fBsc12Mes(_dPer6,Lastday(_dPer6),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer6 >= MV_PAR01 .AND. Lastday(_dPer6) > MV_PAR02
			fBsc12Mes(_dPer6,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer6 < MV_PAR01 .AND. Lastday(_dPer6) >= MV_PAR01
			If Lastday(_dPer6) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer6),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer6 < MV_PAR01 .And. Lastday(_dPer6) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 7
		If _dPer7 >= MV_PAR01 .AND. Lastday(_dPer7) <= MV_PAR02
			fBsc12Mes(_dPer7,Lastday(_dPer7),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer7 >= MV_PAR01 .AND. Lastday(_dPer7) > MV_PAR02
			fBsc12Mes(_dPer7,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer7 < MV_PAR01 .AND. Lastday(_dPer7) >= MV_PAR01
			If Lastday(_dPer7) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer7),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer7 < MV_PAR01 .And. Lastday(_dPer7) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 8
		If _dPer8 >= MV_PAR01 .AND. Lastday(_dPer8) <= MV_PAR02
			fBsc12Mes(_dPer8,Lastday(_dPer8),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer8 >= MV_PAR01 .AND. Lastday(_dPer8) > MV_PAR02
			fBsc12Mes(_dPer8,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer8 < MV_PAR01 .AND. Lastday(_dPer8) >= MV_PAR01
			If Lastday(_dPer8) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer8),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer8 < MV_PAR01 .And. Lastday(_dPer8) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 9
		If _dPer9 >= MV_PAR01 .AND. Lastday(_dPer9) <= MV_PAR02
			fBsc12Mes(_dPer9,Lastday(_dPer9),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer9 >= MV_PAR01 .AND. Lastday(_dPer9) > MV_PAR02
			fBsc12Mes(_dPer9,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer9 < MV_PAR01 .AND. Lastday(_dPer9) >= MV_PAR01
			If Lastday(_dPer9) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer9),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer9 < MV_PAR01 .And. Lastday(_dPer9) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 10
		If _dPer10 >= MV_PAR01 .AND. Lastday(_dPer10) <= MV_PAR02
			fBsc12Mes(_dPer10,Lastday(_dPer10),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer10 >= MV_PAR01 .AND. Lastday(_dPer10) > MV_PAR02
			fBsc12Mes(_dPer10,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer10 < MV_PAR01 .AND. Lastday(_dPer10) >= MV_PAR01
			If Lastday(_dPer10) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer10),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer10 < MV_PAR01 .And. Lastday(_dPer10) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 11
		If _dPer11 >= MV_PAR01 .AND. Lastday(_dPer11) <= MV_PAR02
			fBsc12Mes(_dPer11,Lastday(_dPer11),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer11 >= MV_PAR01 .AND. Lastday(_dPer11) > MV_PAR02
			fBsc12Mes(_dPer11,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer11 < MV_PAR01 .AND. Lastday(_dPer11) >= MV_PAR01
			If Lastday(_dPer11) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer11),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer11 < MV_PAR01 .And. Lastday(_dPer11) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	elseif _nPer == 12
		If _dPer12 >= MV_PAR01 .AND. Lastday(_dPer12) <= MV_PAR02
			fBsc12Mes(_dPer12,Lastday(_dPer12),_nPer,_cSupV,MV_PAR04)
		Elseif _dPer12 >= MV_PAR01 .AND. Lastday(_dPer12) > MV_PAR02
			fBsc12Mes(_dPer12,MV_PAR02,_nPer,_cSupV,MV_PAR04)
		Elseif _dPer12 < MV_PAR01 .AND. Lastday(_dPer12) >= MV_PAR01
			If Lastday(_dPer12) <= MV_PAR02
				fBsc12Mes(MV_PAR01,Lastday(_dPer12),_nPer,_cSupV,MV_PAR04)
			Else
				fBsc12Mes(MV_PAR01,MV_PAR02,_nPer,_cSupV,MV_PAR04)
			Endif
		Elseif _dPer12 < MV_PAR01 .And. Lastday(_dPer12) < MV_PAR01
			&&nesse caso o valor é zero.....preciso ver melhor forma de integrar ao arquivo..ou aqui ou na função fBSC12mes...avaliando.
		Endif
	Endif
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER01 += _aProdP1[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER01
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER01     := _aProdP1[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP1[_ni,3]
		TEMP->LOJA      := _aProdP1[_ni,4]
		TEMP->AGRUP     := _aProdP1[_ni,2]
		TEMP->PRODUTO   := _aProdP1[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP1[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER02 += _aProdP2[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER02
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER02     := _aProdP2[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP2[_ni,3]
		TEMP->LOJA      := _aProdP2[_ni,4]
		TEMP->AGRUP     := _aProdP2[_ni,2]
		TEMP->PRODUTO   := _aProdP2[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP2[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER03 += _aProdP3[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER03
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER03     := _aProdP3[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP3[_ni,3]
		TEMP->LOJA      := _aProdP3[_ni,4]
		TEMP->AGRUP     := _aProdP3[_ni,2]
		TEMP->PRODUTO   := _aProdP3[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP3[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER04 += _aProdP4[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER04
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER04     := _aProdP4[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP4[_ni,3]
		TEMP->LOJA      := _aProdP4[_ni,4]
		TEMP->AGRUP     := _aProdP4[_ni,2]
		TEMP->PRODUTO   := _aProdP4[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP4[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER05 += _aProdP5[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER05
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER05     := _aProdP5[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP5[_ni,3]
		TEMP->LOJA      := _aProdP5[_ni,4]
		TEMP->AGRUP     := _aProdP5[_ni,2]
		TEMP->PRODUTO   := _aProdP5[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP5[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER06 += _aProdP6[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER06
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER06     := _aProdP6[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP6[_ni,3]
		TEMP->LOJA      := _aProdP6[_ni,4]
		TEMP->AGRUP     := _aProdP6[_ni,2]
		TEMP->PRODUTO   := _aProdP6[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP6[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER07 += _aProdP7[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER07
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER07     := _aProdP7[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP7[_ni,3]
		TEMP->LOJA      := _aProdP7[_ni,4]
		TEMP->AGRUP     := _aProdP7[_ni,2]
		TEMP->PRODUTO   := _aProdP7[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP7[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER08 += _aProdP8[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER08
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER08     := _aProdP8[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP8[_ni,3]
		TEMP->LOJA      := _aProdP8[_ni,4]
		TEMP->AGRUP     := _aProdP8[_ni,2]
		TEMP->PRODUTO   := _aProdP8[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP8[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER09 += _aProdP9[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER09
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER09     := _aProdP9[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP9[_ni,3]
		TEMP->LOJA      := _aProdP9[_ni,4]
		TEMP->AGRUP     := _aProdP9[_ni,2]
		TEMP->PRODUTO   := _aProdP9[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP9[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER10 += _aProdP10[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER10
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER10     := _aProdP10[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP10[_ni,3]
		TEMP->LOJA      := _aProdP10[_ni,4]
		TEMP->AGRUP     := _aProdP10[_ni,2]
		TEMP->PRODUTO   := _aProdP10[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP10[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER11 += _aProdP11[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER11
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER11     := _aProdP11[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP11[_ni,3]
		TEMP->LOJA      := _aProdP11[_ni,4]
		TEMP->AGRUP     := _aProdP11[_ni,2]
		TEMP->PRODUTO   := _aProdP11[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP11[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
			IF Alltrim(TEMP->TIPDADO) == "2VALOR"
				RecLock("TEMP",.F.)
				TEMP->PER12 += _aProdP12[_ni,5]
				TEMP->(MsUnlock())
				_nValMed += TEMP->PER12
			Elseif Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
		TEMP->TIPDADO   := "2VALOR"
		TEMP->PER12     := _aProdP12[_ni,5]
		TEMP->(MsUnlock())
		RecLock("TEMP",.T.)
		TEMP->CLIENTE   := _aProdP12[_ni,3]
		TEMP->LOJA      := _aProdP12[_ni,4]
		TEMP->AGRUP     := _aProdP12[_ni,2]
		TEMP->PRODUTO   := _aProdP12[_ni,1]
		TEMP->DESCRICAO := Posicione("SB1",1,xFilial("SB1")+_aProdP12[_ni,1],"B1_DESC")
		TEMP->TIPDADO   := "1VOLUME"
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
	IF Alltrim(TEMP->TIPDADO) == "1VOLUME"
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
	Elseif Alltrim(TEMP->TIPDADO) == "2VALOR"
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
	DbSelectArea("TEMM")
	Reclock("TEMM",.T.)
	TEMM->CLIENTE   := TEMP->CLIENTE
	TEMM->LOJA      := TEMP->LOJA
	TEMM->AGRUP     := TEMP->AGRUP
	TEMM->PRODUTO   := TEMP->PRODUTO
	TEMM->DESCRICAO := TEMP->DESCRICAO
	TEMM->TIPDADO   := TEMP->TIPDADO
	TEMM->PER01     := TEMP->PER01
	TEMM->PER02     := TEMP->PER02
	TEMM->PER03     := TEMP->PER03
	TEMM->PER04     := TEMP->PER04
	TEMM->PER05     := TEMP->PER05
	TEMM->PER06     := TEMP->PER06
	TEMM->PER07     := TEMP->PER07
	TEMM->PER08     := TEMP->PER08
	TEMM->PER09     := TEMP->PER09
	TEMM->PER10     := TEMP->PER10
	TEMM->PER11     := TEMP->PER11
	TEMM->PER12     := TEMP->PER12
	if Alltrim(TEMP->TIPDADO) == "3MEDIO"
	   TEMM->TOTALV    := _cVol1+_cVol2+_cVol3+_cVol4+_cVol5+_cVol6+_cVol7+_cVol8+_cVol9+_cVol10+_cVol11+_cVol12
	   TEMM->TOTALF    := _cVal1+_cVal2+_cVal3+_cVal4+_cVal5+_cVal6+_cVal7+_cVal8+_cVal9+_cVal10+_cVal11+_cVal12
	Endif   
	TEMM->(MsUnlock())
	DbSelectArea("TEMP")
	TEMP->(DbSkip())
Enddo

&&Mauricio - 08/08/14 - tratamento para saida em excel..
cPath    := AllTrim(GetTempPath())
cArq     := "PERFORSUP.CSV"
            
if file("C:\PERFORSUP.CSV")
	FErase("C:\PERFORSUP.CSV")		
endif

if file(cPath+"\PERFORSUP.CSV")
	FErase(cPath+"\PERFORSUP.CSV")		
endif

if file("\SYSTEM\PERFORSUP.CSV")
	FErase("\SYSTEM\PERFORSUP.CSV")
endif

nHdl := fCreate(cArq,0)
_Vazia := ";;;;;;;;;;;;;;;;"+_Eof

fWrite(nHdl,cLin1,Len(cLin1))
fWrite(nHdl,_Vazia,Len(_Vazia))

_nTTGerV1  := 0
_nTTGerV2  := 0
_nTTGerV3  := 0
_nTTGerV4  := 0
_nTTGerV5  := 0
_nTTGerV6  := 0
_nTTGerV7  := 0
_nTTGerV8  := 0
_nTTGERV9  := 0
_nTTGERV10 := 0
_nTTGERV11 := 0
_nTTGERV12 := 0
_nTTGERVT  := 0

_nTTGerF1  := 0
_nTTGerF2  := 0
_nTTGerF3  := 0
_nTTGerF4  := 0
_nTTGerF5  := 0
_nTTGerF6  := 0
_nTTGerF7  := 0
_nTTGerF8  := 0
_nTTGERF9  := 0
_nTTGERF10 := 0
_nTTGERF11 := 0
_nTTGERF12 := 0
_nTTGERFT  := 0

DbSelectArea("TEMM")
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
_nCli  := ""

_aTTGrupV := {}
_aTTGrupF := {}
While TEMM->(!Eof())
	_cIMPCLI := TEMM->CLIENTE
	_cIMPLOJ := TEMM->LOJA
	_cIMPNOM := ""  //Alltrim(Posicione("SA3",1,xfilial("SA3")+_cIMPCLI,"A3_NOME"))
	DbSelectArea("TEMM")
	If lAbortPrint
		@nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	IF Empty(TEMM->CLIENTE)
	   TEMM->(DbSkip())
	   loop
	Endif
	     
	If nLin > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	//IF _cIMPCLI <> _nCli  //_nVez == 1
	cLin := ""
	@nLin,000 Psay "Supervisor: "+_cIMPCLI +"-"+" "+_cDESCPAI
	cLin += "SUPERVISOR:;"+_cIMPCLI+";"+_cDESCPAI+";"+_Eof
	fWrite(nHdl,cLin,Len(cLin))
	fWrite(nHdl,_Vazia,Len(_Vazia))
	nLin ++
	nLin ++
	_nVez ++
	//IF _cIMPCLI == "000002"
	//   Msgalert("Parei")
	//ENdif
	//ENDIF
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
_aTTGrupV := {}
_aTTGrupF := {}		
	While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ
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
		
		IF (MV_PAR05 == 1 .Or. MV_PAR05 == 2)  .And. Alltrim(TEMM->TIPDADO)  == "1VOLUME"  &&tudo ou volume apenas
			_cTpDado := TEMM->TIPDADO
			//If _nImpV == 1
			@nLin,070 Psay "---------------------------  V O L U M E  ------------------------------------"
			cLin := ""
			cLin += "VOLUME:"+";"+_Eof
			fWrite(nHdl,cLin,Len(cLin))
			fWrite(nHdl,_Vazia,Len(_Vazia))
			nLin ++
			//nLin ++
			_nImpV ++
			//Endif
			
			While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ .And. _cTpDado == TEMM->TIPDADO
				_cAGrupo := TEMM->AGRUP
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
				While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ .And. _cTpDado == TEMM->TIPDADO .And. _cAgrupo == TEMM->AGRUP  &&quebra por agrupamento
					_nTotLin := 0
					If lAbortPrint
						@nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
						Exit
					Endif
					
					If nLin > 60
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 8
					Endif
					
					_nTotal := 0
					cLin := ""
					@ nLin, 000			PSAY TEMM->AGRUP
					cLin += TEMM->AGRUP+";"
					@ nLin, Pcol()+002	PSAY TEMM->PRODUTO
					cLin += TEMM->PRODUTO+";"
					@ nLin, Pcol()+002	PSAY TEMM->DESCRICAO
					cLin += TEMM->DESCRICAO+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER01 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER01,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER02 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER02,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER03 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER03,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER04 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER04,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER05 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER05,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER06 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER06,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER07 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER07,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER08 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER08,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER09 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER09,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER10 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER10,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER11 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER11,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER12 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER12,"@E 99,999,999")+";"
					
					_nToTlin += TEMM->PER01
					_nToTlin += TEMM->PER02
					_nToTlin += TEMM->PER03
					_nToTlin += TEMM->PER04
					_nToTlin += TEMM->PER05
					_nToTlin += TEMM->PER06
					_nToTlin += TEMM->PER07
					_nToTlin += TEMM->PER08
					_nToTlin += TEMM->PER09
					_nToTlin += TEMM->PER10
					_nToTlin += TEMM->PER11
					_nToTlin += TEMM->PER12
					
					_nTotCol1  += TEMM->PER01
					_nTotCol2  += TEMM->PER02
					_nTotCol3  += TEMM->PER03
					_nTotCol4  += TEMM->PER04
					_nTotCol5  += TEMM->PER05
					_nTotCol6  += TEMM->PER06
					_nTotCol7  += TEMM->PER07
					_nTotCol8  += TEMM->PER08
					_nTotCol9  += TEMM->PER09
					_nTotCol10 += TEMM->PER10
					_nTotCol11 += TEMM->PER11
					_nTotCol12 += TEMM->PER12
					_nTotColT  += _nTotLin
					@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
					
					_nAscan := Ascan( _aTTGrupV, { |x|x[01] == TEMM->AGRUP})
					
					If _nAscan <= 0
					   AADD(_aTTGrupV,{TEMM->AGRUP,TEMM->PER01,TEMM->PER02,TEMM->PER03,TEMM->PER04,TEMM->PER05,TEMM->PER06,TEMM->PER07,TEMM->PER08,TEMM->PER09,TEMM->PER10,TEMM->PER11,TEMM->PER12,_nTotLin})
					Else
					   _aTTGrupV[_nAscan][02] += TEMM->PER01
					   _aTTGrupV[_nAscan][03] += TEMM->PER02
					   _aTTGrupV[_nAscan][04] += TEMM->PER03
					   _aTTGrupV[_nAscan][05] += TEMM->PER04
					   _aTTGrupV[_nAscan][06] += TEMM->PER05
					   _aTTGrupV[_nAscan][07] += TEMM->PER06
					   _aTTGrupV[_nAscan][08] += TEMM->PER07
					   _aTTGrupV[_nAscan][09] += TEMM->PER08
					   _aTTGrupV[_nAscan][10] += TEMM->PER09
					   _aTTGrupV[_nAscan][11] += TEMM->PER10
					   _aTTGrupV[_nAscan][12] += TEMM->PER11
					   _aTTGrupV[_nAscan][13] += TEMM->PER12
					   _aTTGrupV[_nAscan][14] += _nTotLin
					Endif       
					    
					cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof
					fWrite(nHdl,cLin,Len(cLin))
					nLin++
					TEMM->(dbSkip())
				Enddo
				_nCli := _cIMpCLI
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
				@ nLin, Pcol()+054	PSAY _nTotCol1 Picture "@E 99,999,999"	  //45
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
			@ nLin, Pcol()+044	PSAY _nTotVol1 Picture "@E 99,999,999"
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
			
			_nTTGERV1 += _nTotVol1
			_nTTGERV2 += _nTotVol2
			_nTTGERV3 += _nTotVol3
			_nTTGERV4 += _nTotVol4
			_nTTGERV5 += _nTotVol5
			_nTTGERV6 += _nTotVol6
			_nTTGERV7 += _nTotVol7
			_nTTGERV8 += _nTotVol8
			_nTTGERV9 += _nTotVol9
			_nTTGERV10 += _nTotVol10
			_nTTGERV11 += _nTotVol11
			_nTTGERV12 += _nTotVol12
			_nTTGERVT  += _nTotLin
			@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
			cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof
			fWrite(nHdl,cLin,Len(cLin))
			nLin++
		Elseif (MV_PAR05 == 1 .Or. MV_PAR05 == 3) .And. Alltrim(TEMM->TIPDADO)  == "2VALOR"
			_cTpDado := TEMM->TIPDADO
			//If _nImpV == 1
			@nLin,070 Psay "-----------------------  F A T U R A M E N T O  ------------------------------"
			cLin := ""
			cLin += "FATURAMENTO:"+";"+_Eof
			fWrite(nHdl,cLin,Len(cLin))
			fWrite(nHdl,_Vazia,Len(_Vazia))
			nLin ++
			
			_nVez ++
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
			While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ .And. _cTpDado == TEMM->TIPDADO
				_cAGrupo := TEMM->AGRUP
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
				While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ .And. _cTpDado == TEMM->TIPDADO .And. _cAgrupo == TEMM->AGRUP  &&quebra por agrupamento
					_nTotLin := 0
					If lAbortPrint
						@nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
						Exit
					Endif
					
					If nLin > 60
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 8
					Endif
					
					_nTotal := 0
					cLin := ""
					@ nLin, 000			PSAY TEMM->AGRUP
					cLin += TEMM->AGRUP+";"
					@ nLin, Pcol()+002	PSAY TEMM->PRODUTO
					cLin += TEMM->PRODUTO+";"
					@ nLin, Pcol()+002	PSAY TEMM->DESCRICAO
					cLin += TEMM->DESCRICAO+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER01 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER01,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER02 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER02,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER03 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER03,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER04 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER04,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER05 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER05,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER06 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER06,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER07 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER07,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER08 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER08,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER09 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER09,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER10 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER10,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER11 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER11,"@E 99,999,999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER12 Picture "@E 99,999,999"
					cLin += Transform(TEMM->PER12,"@E 99,999,999")+";"
					
					_nToTlin += TEMM->PER01
					_nToTlin += TEMM->PER02
					_nToTlin += TEMM->PER03
					_nToTlin += TEMM->PER04
					_nToTlin += TEMM->PER05
					_nToTlin += TEMM->PER06
					_nToTlin += TEMM->PER07
					_nToTlin += TEMM->PER08
					_nToTlin += TEMM->PER09
					_nToTlin += TEMM->PER10
					_nToTlin += TEMM->PER11
					_nToTlin += TEMM->PER12
					
					_nTotCol1  += TEMM->PER01
					_nTotCol2  += TEMM->PER02
					_nTotCol3  += TEMM->PER03
					_nTotCol4  += TEMM->PER04
					_nTotCol5  += TEMM->PER05
					_nTotCol6  += TEMM->PER06
					_nTotCol7  += TEMM->PER07
					_nTotCol8  += TEMM->PER08
					_nTotCol9  += TEMM->PER09
					_nTotCol10 += TEMM->PER10
					_nTotCol11 += TEMM->PER11
					_nTotCol12 += TEMM->PER12
					_nTotColT  += _nTotLin
					@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
					
					_nAscan := Ascan( _aTTGrupF, { |x|x[01] == TEMM->AGRUP})
					
					If _nAscan <= 0
					   AADD(_aTTGrupF,{TEMM->AGRUP,TEMM->PER01,TEMM->PER02,TEMM->PER03,TEMM->PER04,TEMM->PER05,TEMM->PER06,TEMM->PER07,TEMM->PER08,TEMM->PER09,TEMM->PER10,TEMM->PER11,TEMM->PER12,_nTotLin})
					Else
					   _aTTGrupF[_nAscan][02] += TEMM->PER01
					   _aTTGrupF[_nAscan][03] += TEMM->PER02
					   _aTTGrupF[_nAscan][04] += TEMM->PER03
					   _aTTGrupF[_nAscan][05] += TEMM->PER04
					   _aTTGrupF[_nAscan][06] += TEMM->PER05
					   _aTTGrupF[_nAscan][07] += TEMM->PER06
					   _aTTGrupF[_nAscan][08] += TEMM->PER07
					   _aTTGrupF[_nAscan][09] += TEMM->PER08
					   _aTTGrupF[_nAscan][10] += TEMM->PER09
					   _aTTGrupF[_nAscan][11] += TEMM->PER10
					   _aTTGrupF[_nAscan][12] += TEMM->PER11
					   _aTTGrupF[_nAscan][13] += TEMM->PER12
					   _aTTGrupF[_nAscan][14] += _nTotLin
					Endif
					cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof
					fWrite(nHdl,cLin,Len(cLin))
					nLin++
					TEMM->(dbSkip())
				Enddo
				_nCli := _cIMpCLI
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
				@ nLin, Pcol()+054	PSAY _nTotCol1 Picture "@E 99,999,999"	  //45
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
			If nLin > 60
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif
			_nTotLin := 0
			cLin := ""
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
			@ nLin, Pcol()+039	PSAY _nTotVol1 Picture "@E 99,999,999"
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
			
			_nTTGERF1  += _nTotVol1
			_nTTGERF2  += _nTotVol2
			_nTTGERF3  += _nTotVol3
			_nTTGERF4  += _nTotVol4
			_nTTGERF5  += _nTotVol5
			_nTTGERF6  += _nTotVol6
			_nTTGERF7  += _nTotVol7
			_nTTGERF8  += _nTotVol8
			_nTTGERF9  += _nTotVol9
			_nTTGERF10 += _nTotVol10
			_nTTGERF11 += _nTotVol11
			_nTTGERF12 += _nTotVol12
			_nTTGERFT  += _nTotLin
			@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
			cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof
			fWrite(nHdl,cLin,Len(cLin))
			nLin++
		Elseif (MV_PAR05 == 1 .Or. MV_PAR05 == 4) .And. Alltrim(TEMM->TIPDADO)  == "3MEDIO"
			_cTpDado := TEMM->TIPDADO
			
			@nLin,070 Psay "-----------------------  P R E C O   M E D I O  ------------------------------"
			cLin := ""
			cLin += "PRECO MEDIO:"+";"+_Eof
			fWrite(nHdl,cLin,Len(cLin))
			fWrite(nHdl,_Vazia,Len(_Vazia))
			nLin ++
			
			_nVez ++
			
			While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ .And. _cTpDado == TEMM->TIPDADO
				_cAGrupo := TEMM->AGRUP
				
				While TEMM->(!Eof()) .And. TEMM->CLIENTE+TEMM->LOJA == _cIMPCLI+_cIMPLOJ .And. _cTpDado == TEMM->TIPDADO .And. _cAgrupo == TEMM->AGRUP  &&quebra por agrupamento
					_nTotLin := 0
					If lAbortPrint
						@nLin,000		 PSAY "*** CANCELADO PELO OPERADOR ***"
						Exit
					Endif
					
					If nLin > 60
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 8
					Endif
										
					_nTotal := 0
					cLin := ""
					@ nLin, 000			PSAY TEMM->AGRUP
					cLin += TEMM->AGRUP+";"
					@ nLin, Pcol()+002	PSAY TEMM->PRODUTO
					cLin += TEMM->PRODUTO+";"
					@ nLin, Pcol()+002	PSAY TEMM->DESCRICAO
					cLin += TEMM->DESCRICAO+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER01 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER01,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER02 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER02,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER03 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER03,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER04 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER04,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER05 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER05,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER06 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER06,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER07 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER07,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER08 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER08,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER09 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER09,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER10 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER10,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER11 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER11,"@E 99,999.999")+";"
					@ nLin, Pcol()+002	PSAY TEMM->PER12 Picture "@E 99,999.999"
					cLin += Transform(TEMM->PER12,"@E 99,999.999")+";"
					//_nAscan := Ascan( _aTTGrupV, { |x|x[01] == _cAgrupo})
					_nTotQTT := TEMM->TOTALV
					//_nAscan := Ascan( _aTTGrupF, { |x|x[01] == _cAgrupo})
					_nTotVLT := TEMM->TOTALF
					_nToTlin := (_nTotVLT/_nTotQTT)
					
					_nTotCol1  += TEMM->PER01
					_nTotCol2  += TEMM->PER02
					_nTotCol3  += TEMM->PER03
					_nTotCol4  += TEMM->PER04
					_nTotCol5  += TEMM->PER05
					_nTotCol6  += TEMM->PER06
					_nTotCol7  += TEMM->PER07
					_nTotCol8  += TEMM->PER08
					_nTotCol9  += TEMM->PER09
					_nTotCol10 += TEMM->PER10
					_nTotCol11 += TEMM->PER11
					_nTotCol12 += TEMM->PER12
					_nTotColT  += _nTotLin
					@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999.999"
					cLin += Transform(_nTotlin,"@E 99,999.999")+";"+_Eof
					fWrite(nHdl,cLin,Len(cLin))
					nLin++
					TEMM->(dbSkip())
				Enddo
				_nTotLin := 0
				//nLin++
				If nLin > 60
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 8
				Endif
				
				//If _cImpCLi == "000002"
				//   Msgalert("parei")
				//Endif
				
				_nAscan := Ascan( _aTTGrupV, { |x|x[01] == _cAgrupo})
					
			    _nTotQT1  := _aTTGrupV[_nAscan][02]					  
				_nTotQT2  := _aTTGrupV[_nAscan][03]
				_nTotQT3  := _aTTGrupV[_nAscan][04]					  
				_nTotQT4  := _aTTGrupV[_nAscan][05]	   
	            _nTotQT5  := _aTTGrupV[_nAscan][06]					  
				_nTotQT6  := _aTTGrupV[_nAscan][07]
				_nTotQT7  := _aTTGrupV[_nAscan][08]					  
				_nTotQT8  := _aTTGrupV[_nAscan][09]
				_nTotQT9  := _aTTGrupV[_nAscan][10]					  
				_nTotQT10 := _aTTGrupV[_nAscan][11]
				_nTotQT11 := _aTTGrupV[_nAscan][12]					  
				_nTotQT12 := _aTTGrupV[_nAscan][13]
				
				_nAscan := Ascan( _aTTGrupF, { |x|x[01] == _cAgrupo})
					
			    _nTotVL1  := _aTTGrupF[_nAscan][02]					  
				_nTotVL2  := _aTTGrupF[_nAscan][03]
				_nTotVL3  := _aTTGrupF[_nAscan][04]					  
				_nTotVL4  := _aTTGrupF[_nAscan][05]	   
	            _nTotVL5  := _aTTGrupF[_nAscan][06]					  
				_nTotVL6  := _aTTGrupF[_nAscan][07]
				_nTotVL7  := _aTTGrupF[_nAscan][08]					  
				_nTotVL8  := _aTTGrupF[_nAscan][09]
				_nTotVL9  := _aTTGrupF[_nAscan][10]					  
				_nTotVL10 := _aTTGrupF[_nAscan][11]
				_nTotVL11 := _aTTGrupF[_nAscan][12]					  
				_nTotVL12 := _aTTGrupF[_nAscan][13]
																
				cLin := ""
				@ nLin, 000			PSAY "Total: "+_cAgrupo
				cLin += "Total: "+_cAgrupo+";"
				cLin += ";"
				cLin += ";"
				@ nLin, Pcol()+054	PSAY _nTotVL1/_nTotQT1 Picture "@E 99,999.999"	  //43
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
			cLin += "Preco;"
			cLin += "Medio;"
			@ nLin, Pcol()+039	PSAY _nTotVol1/_nTotQtd1 Picture "@E 99,999.999"	//28
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
			_nTotLin := (_nTotVoL1+_nTotVol2+_nTotVoL3+_nTotVoL4+_nTotVol5+_nTotVoL6+_nTotVoL7+_nTotVol8+_nTotVoL9+_nTotVoL10+_nTotVol11+_nTotVoL12)/;
			(_nTotQTd1+_nTotQTd2+_nTotQTd3+_nTotQTd4+_nTotQTd5+_nTotQTd6+_nTotQTd7+_nTotQTd8+_nTotQTd9+_nTotQTd10+_nTotQTd11+_nTotQTd12)
					
			@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999.999"
			cLin += Transform(_nTotlin,"@E 99,999.999")+";"+_Eof
			fWrite(nHdl,cLin,Len(cLin))
			nLin++
			nLin++
		Else
			TEMM->(dbSkip())
		Endif
	Enddo
Enddo

&&impressão do total geral....(volume, faturamento, medio)
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
@ nLin, Pcol()+044	PSAY _nTTGerV1 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV1,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV2 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV2,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV3 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV3,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV4 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV4,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV5 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV5,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV6 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV6,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV7 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV7,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV8 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV8,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV9 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV9,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV10 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV10,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV11 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV11,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerV12 Picture "@E 99,999,999"
cLin += Transform(_nTTGerV12,"@E 99,999,999")+";"
_nTotLin += _nTTGerV1+_nTTGerV2+_nTTGerV3+_nTTGerV4+_nTTGerV5+_nTTGerV6+_nTTGerV7+_nTTGerV8+_nTTGerV9+_nTTGerV10+_nTTGerV11+_nTTGerV12
@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof
fWrite(nHdl,cLin,Len(cLin))
nLin++
&&&&&&&
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
@ nLin, Pcol()+039	PSAY _nTTGerF1 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF1,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF2 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF2,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF3 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF3,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF4 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF4,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF5 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF5,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF6 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF6,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF7 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF7,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF8 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF8,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF9 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF9,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF10 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF10,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF11 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF11,"@E 99,999,999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF12 Picture "@E 99,999,999"
cLin += Transform(_nTTGerF12,"@E 99,999,999")+";"
_nTotLin += _nTTGerF1+_nTTGerF2+_nTTGerF3+_nTTGerF4+_nTTGerF5+_nTTGerF6+_nTTGerF7+_nTTGerF8+_nTTGerF9+_nTTGerF10+_nTTGerF11+_nTTGerF12
@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999,999"
cLin += Transform(_nTotlin,"@E 99,999,999")+";"+_Eof
fWrite(nHdl,cLin,Len(cLin))
nLin++
&&&&&&&&&
If nLin > 60
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
Endif
_nTotLin := 0
cLin := ""
@ nLin, 000			PSAY "Total Geral Preco Medio "
cLin += "Total;"
cLin += "Preco;"
cLin += "Medio;"
@ nLin, Pcol()+039	PSAY _nTTGerF1/_nTTGerV1 Picture "@E 99,999.999"	//28
cLin += Transform(_nTTGerF1/_nTTGerV1,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF2/_nTTGerV2 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF2/_nTTGerV2,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF3/_nTTGerV3 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF3/_nTTGerV3,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF4/_nTTGerV4 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF4/_nTTGerV4,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF5/_nTTGerV5 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF5/_nTTGerV5,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF6/_nTTGerV6 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF6/_nTTGerV6,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF7/_nTTGerV7 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF7/_nTTGerV7,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF8/_nTTGerV8 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF8/_nTTGerV8,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF9/_nTTGerV9 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF9/_nTTGerV9,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF10/_nTTGerV10 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF10/_nTTGerV10,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF11/_nTTGerV11 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF11/_nTTGerV11,"@E 99,999.999")+";"
@ nLin, Pcol()+002	PSAY _nTTGerF12/_nTTGerV12 Picture "@E 99,999.999"
cLin += Transform(_nTTGerF12/_nTTGerV12,"@E 99,999.999")+";"
_nTotLin := (_nTTGerF1+_nTTGerF2+_nTTGerF3+_nTTGerF4+_nTTGerF5+_nTTGerF6+_nTTGerF7+_nTTGerF8+_nTTGerF9+_nTTGerF10+_nTTGerF11+_nTTGerF12)/;
(_nTTGerV1+_nTTGerV2+_nTTGerV3+_nTTGerV4+_nTTGerV5+_nTTGerV6+_nTTGerV7+_nTTGerV8+_nTTGerV9+_nTTGerV10+_nTTGerV11+_nTTGerV12)

@ nLin, Pcol()+002	PSAY _nTotLin Picture "@E 99,999.999"
cLin += Transform(_nTotlin,"@E 99,999.999")+";"+_Eof
fWrite(nHdl,cLin,Len(cLin))

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

fClose(nHdl)

//----> GERAR PLANILHA EXCEL
If MV_PAR06 == 1
	bBloco:={|| _fOpenExcel()}
	MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)
EndIf

Return()



Static Function _fOpenExcel()

CpyS2T("\SYSTEM\PERFORSUP.CSV",cPath,.T.)

FerasE("\SYSTEM\PERFORSUP.CSV")

//_cArquivo := "\SYSTEM\MPFAT12.CSV"

//__COPYFILE (_cArquivo,"C:\MPFAT12.CSV")

//Copy File &_cArquivo To &cArqSai 
   
//------------------------------
// Abre MS-EXCEL
//------------------------------
If ! ApOleClient( 'MsExcel' )
	MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou o mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
	Return
EndIf
oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
//oExcelApp:WorkBooks:Open(cArqSai)
oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
oExcelApp:SetVisible(.T.)

Return()

Static function fBsc12Mes(_dI,_dF,_nPos,_cVDi,_cVDf)
_TempMP		:= ""
_Temp		:= ""
aProduto 	:= {}
aQtde		:= {}
    
&&query e tratamento abaixo vindo igual dos demais relatorios em uso pela ADoro.
If Select("XF2") > 0
   DbSelectArea("XF2")
   DbCloseArea("XF2")
Endif

	cQuery:="select F2_FILIAL, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , F2_VEND1, A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
	"from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
	"WHERE F2_TIPO='N' and "+;
	"F2_EMISSAO between '"+dtos(_dI)+"' and '"+dtos(_dF)+"' and "+;
	"F2_FILIAL IN ("+ALLTRIM(MV_PAR07)+") and  "+;
	"F2_VEND1 IN " + FormatIn(_cVDi,";") +" AND "+;
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
		_cVendedor 	:=	XF2->F2_VEND1
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
			   aAdd(aProduto,{_cProduto,_cAgrup,_cSUPPAI,"",_nValorT,_nQtd,(_nValorT/_nQtd)})				   			   			   			   			   			   					
			Endif
			
			dbSelectArea("SD2")
			SD2->(DbSkip())
		Enddo
		
		dbSelectArea("XF2")
		XF2->(dbskip())
	ENDDO
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