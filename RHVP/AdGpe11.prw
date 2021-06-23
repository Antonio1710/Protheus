#INCLUDE "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AdGpe11   ³ Autor ³Isamu Kawakami         ³Data  ³ 21/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa p/ Gerar Planilha com informacoes de Afastamentos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico Adoro                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³              Alteracao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function AdGpe11()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa p/ Gerar Planilha com informacoes de Afastamentos')

SetPrvt("cPerg,nOpc_,cCad_,aSay_,aButt_,aCampos,lAbortPrint")
SetPrvt("cFilAtu,cCCAtu,cTurma,cMatAtu,dDtAfas,dDtinicio,dDtFinal,cTipoAf ")
 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cPerg       := "ADGP11" // Nome do arquivo de perguntas do SX1
cPerg       := PADR("ADGP11",10," ") // Nome do arquivo de perguntas do SX1
cCad_		:= ""
nOpc_		:= 0
aSay_		:= {}
aButt_		:= {}
aCampos 	:= {}
lAbortPrint := .F. 

//Processamento
cCad_		:= "Posicao de Quadro em "+Dtoc(dDataBase)

aAdd( aSay_, "Este programa tem como objetivo gerar uma planilha em Excel " )
aAdd( aSay_, "com informacoes de Funcionarios Afastados, totalizados por" )
aAdd( aSay_, "Centro Custo, Turma e por Tipo" )

aAdd( aButt_, { 5,.T.,{|| Pergunte(cPerg,.T.)    }})
aAdd( aButt_, { 1,.T.,{|| FechaBatch(),nOpc_ := 1 }})
aAdd( aButt_, { 2,.T.,{|| FechaBatch()            }})

//Verifica Perguntas
ValidPerg(cPerg)
Pergunte(cPerg,.F.)
                    
//Monta Tela Inicial
FormBatch( cCad_, aSay_, aButt_ )

If nOpc_ == 1
	Processa( {|| RunReport() }, "Processando..." )
Endif
        
Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RunReport ³ Autor ³Isamu Kawakami/JCGouveia³Data ³ 15.03.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Geracao da Planilha                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem  

	aCampos := {}

	AADD(aCampos,{"FILIAL"   ,  	"C", 002,0})
	AADD(aCampos,{"CCUSTO"   ,   	"C", 009,0})
	AADD(aCampos,{"DESCCC" , "C"	, 025,0})
	AADD(aCampos,{"TURMA" , "C"	, 006,0})
	AADD(aCampos,{"APROVADO" , "C"	, 006,0})
	AADD(aCampos,{"POSICEFET" ,  	"N", 009,0})
	AADD(aCampos,{"TEMP" ,  	"N", 005,0})
	AADD(aCampos,{"FERIAS" ,  	"N", 007,0})
   AADD(aCampos,{"DOENCA"  ,  	"N", 005,0})
   AADD(aCampos,{"ACIDENTE" ,  	"N", 006,0})
	AADD(aCampos,{"MATERN" ,  	"N", 008,0})
	AADD(aCampos,{"OUTROS",   	"N", 008,0})
	AADD(aCampos,{"ATIVPRES",   	"N", 007,0})
	AADD(aCampos,{"POSICFIN",   	"C", 008,0})
		
	cArqEXC := CriaTrab(aCampos,.t.)
	dbUseArea(.T.,,cArqEXC,"EXC",.F.,.F.)
	
	dbSelectArea("EXC")
	dbGotop()

   FilIni		:=	mv_par01
   FilAte		:=	mv_par02
  //MatIni		:=	mv_par03
  //MatAte	:=	mv_par04
   CcuIni		:=	mv_par03
   CcuAte	:=	mv_par04

dbSelectArea("SRA")
cIndex := CriaTrab(nil,.f.)
cChave  := "RA_FILIAL+RA_CC+RA_TURMA"
IndRegua("SRA",cIndex,cChave,,,"Selecionando Registros...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSeek(FilIni)
//SetRegua(RecCount())
ProcRegua(SRA->(RecCount()))

While !EOF()           

   Private cFilAtu  := SRA->RA_FILIAL
   Private cCCAtu   := Sra->Ra_CC
   Private cTurma   := Sra->Ra_Turma
  //cMatAtu := Sra->Ra_Mat  
   Private nQtNormal:= 0     
   Private nQtTemp := 0
   Private nQtFerias:= 0
   Private nQtDoenca:= 0
   Private nQtAcidente := 0
   Private nQtMater := 0
   Private nQtOutros := 0 
   Private cSitAdoro := {}      
  

While !Eof() .AND. cFilAtu+cCCAtu+cTurma == Sra->Ra_Filial+Sra->Ra_CC+Sra->Ra_Turma

    IncProc("Processando: " + sra->ra_filial+ "-"+sra->ra_mat )
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Filtra os parametros selecionados......                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   /*If Sra->Ra_Filial =="02" 
      If Sra->Ra_CatFunc $ "E/A" .or.;
       SRA->RA_FILIAL < FilIni .or. SRA->RA_FILIAL > FilAte .or.;
       SRA->RA_CC < cCuIni .or. SRA->RA_CC > cCuAte .or.; 
       SRA->RA_SITFOLH == "D"
        dbSkip()
        Loop
      Endif
   Endif   

   //chamado 003551 by isamu
   If Sra->Ra_Filial $ "03/04" 
      If Sra->Ra_CatFunc $ "E/A" .or.;
       SRA->RA_FILIAL < FilIni .or. SRA->RA_FILIAL > FilAte .or.;
       SRA->RA_CC < cCuIni .or. SRA->RA_CC > cCuAte .or.; 
       SRA->RA_SITFOLH == "D"
        dbSkip()
        Loop
      Endif
   Endif   

   If SRA->RA_FILIAL $ "98/99" 
      If Sra->Ra_CatFunc # "A" .or.;
      SRA->RA_CC < cCuIni .or. SRA->RA_CC > cCuAte .or.;
      SRA->RA_SITFOLH == "D"
        dbskip()
        loop
      Endif
   Endif 
   */             
   
	If Sra->Ra_CatFunc $ "E/A/G" .or.;
       SRA->RA_FILIAL < FilIni .or. SRA->RA_FILIAL > FilAte .OR.;
       SRA->RA_CC < cCuIni .or. SRA->RA_CC > cCuAte .OR.; 
       SRA->RA_SITFOLH == "D"
        dbSkip()
        Loop
      Endif
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		Exit
	Endif
   
	cSitAdoro := RetSituacao(SRA->RA_FILIAL, SRA->RA_MAT, .F., DDATABASE)
			
							
	/* If Sra->Ra_SitFolh == " " .and. !(cFilAtu $ "98/99") 
	   nQtNormal := nQtNormal+1
       ElseIf Sra->Ra_SitFolh == " " .and. cFilAtu $ "98/99"
      nQtTemp := nQtTemp +1
	 */
	   
	  If cSitAdoro[1] == " " .and. !(cFilAtu $ "98/99") 
	     nQtNormal := nQtNormal+1
      ElseIf cSitAdoro[1] == " " .and. cFilAtu $ "98/99"
             nQtTemp := nQtTemp +1
      Else  

            dDtinicio := cTod("  /  /    ")
	         dDtFinal := cTod("  /  /    ")
	         cTipoAf  := ""
            dDtAfas := {}

 	   Sr8->(dbSeek(Sra->Ra_Filial+Sra->Ra_Mat))
      
      While !eof() .and. Sra->Ra_Filial+Sra->Ra_Mat == SR8->R8_FILIAL+SR8->R8_MAT
  				AADD(dDtAfas,{SR8->R8_DATAINI,SR8->R8_DATAFIM,SR8->R8_TIPO})
            Sr8->(dbSkip())
       EndDo     
          
       //Ordena o Array pela data de inicio da estabilidade. Assim a maior estabilidade sera o ultimo elemento do array
       aSort(dDtAfas,,,{|x,y|x[1] > y[1]}) 

		//Se existir afastamentos , checa a data em relação a data base
		If Len(dDtAfas) > 0
		   dDtinicio := dDtAfas[1,1]
		   dDtFinal := dDtAfas[1,2]
		   cTipoAf  := dDtAfas[1,3]
         
         If (dDataBase >= dDtinicio .and. dDtFinal == Ctod("  /  /  ")) .or.;
         (dDataBase >= dDtInicio .and. dDataBase <= dDtFinal)
      	    If cTipoAf == "F" 
      	           nQtFerias += 1
      	    ElseIf cTipoAf == "P"
               		nQtDoenca += 1
             ElseIf cTipoAf == "O"
                     nQtAcidente += 1
             ElseIf cTipoAf == "Q"
                     nQtMater += 1
             ElseIf !(cTipoAF  $ "O/F/P/Q")
                     nQtOutros += 1
             Endif
              
          ElseIf dDataBase > dDtInicio .and. dDataBase > dDtFinal
              If !(cFilAtu $ "98/99") 
              		nQtNormal := nQtNormal+1   
              Else
              		nQtTemp := nQtTemp+1
              Endif  
        	
        	ElseIf dDataBase < dDtInicio .and. dDataBase < dDtFinal
              If !(cFilAtu $ "98/99") 
              		nQtNormal := nQtNormal+1   
              Else
              		nQtTemp := nQtTemp+1
              Endif
        	
        	Endif     
   		
      
   		Endif        
             
   Endif          

     
dbSkip()

EndDo

If (nQtNormal+nQtTemp+nQtFerias+nQtDoenca+nQtMater+nQtOutros) > 0
          
             Reclock("EXC",.T.)
               EXC->Filial := cFilAtu
               EXC->CCusto := cCCAtu
               EXC->DescCC:= Posicione("CTT",1,xFilial("CTT")+cCCAtu,"CTT_DESC01")
               EXC->Turma := cTurma
               EXC->Aprovado := Space(6)
               EXC->PosicEfet := nQtNormal+nQtFerias+nQtDoenca+nQtAcidente+nQtMater+nQtOutros
               EXC->Temp := nQtTemp
               EXC->Ferias := nQtFerias
               EXC->Doenca := nQtDoenca
               EXC->Acidente := nQtAcidente
               EXC->Matern := nQtMater
               EXC->Outros := nQtOutros
               EXC->AtivPres := nQtNormal
               EXC->PosicFin := Space(8)
    
             MsUnlock()
  
EndIf

dbselectarea("SRA")
//dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

//Atualiza Regua	
IncProc("Gerando Planilha......")

EXC->(dbclosearea())

Processa({||_fOpenExcel(cArqEXC)},"Abrindo Excel.....")			

fErase(cArqEXC+".dbf")  

Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fOpemExcel³ Autor ³Claudio Torres          ³ Data ³ 11.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Chamada da Planilha Excell                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _fOpenExcel(cArqTRC)

Local cDirDocs	:= MsDocPath()
Local cPath		:= AllTrim(GetTempPath())

//³Copia DBF para pasta TEMP do sistema operacional da estacao ³

If FILE(cArqTRC+".DBF")
	COPY FILE (cArqTRC+".DBF") TO (cPath+cArqTRC+".DBF")
EndIf

If !ApOleClient("MsExcel")
	MsgStop("MsExcel nao instalado.")
	Return
EndIf

//³Cria link com o excel³
oExcelApp := MsExcel():New()

//³Abre uma planilha³
oExcelApp:WorkBooks:Open(cPath+cArqTRC+".DBF")
oExcelApp:SetVisible(.T.)

Ferase(cPath+cArqTRC+".DBF")  

Return

//Fim da Rotina

  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValidPerg ³ Autor ³Claudio Torres         ³ Data ³ 11.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina de Verificacao de Perguntas                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidPerg()

_sAlias := Alias()
	
dbSelectArea("SX1") // abre arquivo sx1 de perguntas
dbSetOrder(1)       // coloca na ordem 1 do sindex
cPerg := PADR(cPerg,10," ")
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/        Cnt05
aAdd(aRegs,{cPerg,'01','Filial De              ?','','','mv_ch1','C',02,0,0,'G','           ','mv_par01','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SM0',''})
aAdd(aRegs,{cPerg,'02','Filial Ate             ?','','','mv_ch2','C',02,0,0,'G','NaoVazio   ','mv_par02','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SM0',''})
//aAdd(aRegs,{cPerg,'03','Matricula De           ?','','','mv_ch3','C',06,0,0,'G','           ','mv_par03','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SRA',''})
//aAdd(aRegs,{cPerg,'04','Matricula Ate          ?','','','mv_ch4','C',06,0,0,'G','NaoVazio   ','mv_par04','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SRA',''})
aAdd(aRegs,{cPerg,'03','Centro de Custo De     ?','','','mv_ch3','C',20,0,0,'G','           ','mv_par03','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SI3',''})
aAdd(aRegs,{cPerg,'04','Centro de Custo Ate    ?','','','mv_ch4','C',20,0,0,'G','NaoVazio   ','mv_par04','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SI3',''})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)
Pergunte(cPerg,.F.)
Return


//Fim da Rotina

//Fim do Programa

