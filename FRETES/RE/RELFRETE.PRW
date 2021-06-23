#INCLUDE "rwmake.ch"   
#INCLUDE "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RELFRETE º Autor ³ Mauricio da Silva  º Data ³  02/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de fretes conforme chamado 008746                º±±
±±º          ³                                                            º±±
±±º          ³ 20/05/11                                                   º±±
±±º          ³ - Ajustes efetuados por Ana Helena conforme chamado 010082 º±±
±±º          ³ - Geracao tambem em excel                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RELFRETE()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de fretes conforme chamado 008746')

cPerg   := PADR('RELFRT',10," ")
&&Cria os parametros do relatorio.
PutSX1(cPerg,"01","Data de","Data de","Data de"         ,"mv_ch1","D",8,0,0,"G","","   ","","","mv_par01" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"02","Data ate","Data ate","Data ate"      ,"mv_ch2","D",8,0,0,"G","","   ","","","mv_par02" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"03","Tipo Frete","Tipo Frete","Tipo Frete","mv_ch3","C",02,0,0,"G","","  ","","","mv_par03" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(cPerg,"04","Ordem ?","Ordem ?","Ordem ?"         ,"mv_ch4","N",1,0,1,"C","","   ","","","mv_par04" ,"Placa","Placa","Placa","","Data","Data","Data","","","","","","","",""," ")
PutSX1(cPerg,"05","Frete(separar por ,)","Frete(separar por ,)","Frete(separar por ,)","mv_ch5","C",50,0,0,"G","","  ","","","mv_par05" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
//PutSX1(cPerg,"06","Sintetico por placa?","Sintetico por placa?","Sintetico por placa?","mv_ch6","N",1,0,1,"C","","   ","","","mv_par06" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")
PutSX1(cPerg,"06","Destino:","Destino:","Destino:","mv_ch6","C",50,0,0,"G","","   ","","","mv_par06" ,"Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","",""," ")

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cDesc1       := "Este programa tem como objetivo imprimir relatorio "
cDesc2       := "dos fretes por periodo."
cDesc3       := "Relação de Fretes por Placa/Data"
cPict        := ""
titulo       := "Relação de Fretes por Placa/Data"
nLin         := 65
Cabec1       := ""
Cabec2       := ""
imprime      := .T.
aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "RELFRETE" 
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "RELFRETE"
Private nLin         := 80

Private cString := "SZK"

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)
dbSetOrder(1)

SetRegua(RecCount())

_nTotFret   := 0
_nTotPeso   := 0
_nViag      := 0
_nTotViag   := 0
_nTotEntr   := 0
_ntTKmpag   := 0
_TTotFret   := 0
_TTotPeso   := 0
_TTotEntr   := 0
_TtTKmpag   := 0
_nTotAcres  := 0
_nTotDesc   := 0
_nTotFret   := 0                                                                                                                       
_nTotPeso   := 0
_nTotEntr   := 0
_ntTKmpag   := 0

//Cabec1  := "Placa    Data        Tp Veic.   Viag.   Vlr. Frete     Peso bruto       Peso Liq. Nr.Entreg.   Km Entrada       Descricao decrescimos            Descontos   Descricao acrescimos            Acrescimos     Frete Liquido "
//Cabec1  := "Placa                Tp Veic.           Vlr. Frete     Peso bruto       Peso Liq. Nr.Entreg.   Km Entrada       Descricao decrescimos            Descontos   Descricao acrescimos            Acrescimos     Frete Liquido "
Cabec1  := "Placa                Tp Veic.   Viag.   Vlr. Frete     Peso bruto       Peso Liq. Nr.Entreg.   Km Entrada       Descricao decrescimos            Descontos   Descricao acrescimos            Acrescimos     Frete Liquido "
//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17       18        19        20
//          012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456780123456789012345678901234567890

//Incluido para gerar tambem em Excel
aCampos := {}

AADD(aCampos,{"PLACA"     ,  	"C", 010,0})
AADD(aCampos,{"TPVEIC"    ,   	"C", 010,0})
AADD(aCampos,{"VIAGEM "   ,     "N", 005,0})
AADD(aCampos,{"VLFRETE"   ,     "N", 012,2})
AADD(aCampos,{"PBRUTO"    ,     "N", 012,2})
AADD(aCampos,{"PLIQ"      ,  	"N", 012,2})
AADD(aCampos,{"NENTREG"   ,  	"N", 012,2})
AADD(aCampos,{"KMENTRADA" ,  	"N", 012,2})
AADD(aCampos,{"DECRESCIMO",  	"C", 025,0})
AADD(aCampos,{"VL_DECR"   ,  	"N", 012,2})
AADD(aCampos,{"ACRESCIMO" ,  	"C", 025,0})
AADD(aCampos,{"VL_ACRESC" ,   	"N", 012,2})
AADD(aCampos,{"FRETELIQ"  ,   	"N", 012,2})
		
cArqEXC := CriaTrab(aCampos,.t.)
dbUseArea(.T.,,cArqEXC,"EXC",.F.,.F.)
	
dbSelectArea("EXC")
dbGotop()

fDados()

dbselectArea("xSZK")
DbgoTop()

_nViagem   := 1
_nTotDvlr  := 0
_nTotAvlr  := 0
_nTotFret  := 0
_nTotPeso  := 0
_nTotPL    := 0
_nTotEntr  := 0
_ntTKmpag  := 0
_nViag	   := 0
_lEntrou   := .F.
_cPlacaAnt := ""

While xSZK->(!EOF ())
	_cPlaca := xSZK->ZK_PLACAPG
	_sData  := xSZK->ZK_DTENTR
	If nLin > 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif   	
	
	If ALLTRIM(xSZK->ZK_PLACAPG) <> ALLTRIM(_cPlacaAnt)  
					                    
		nLin += 1
		_lEntrou := .T.
		_cPlacaAnt := xSZK->ZK_PLACAPG
		_nDvlr     := 0
		_nAvlr     := 0
		_nVlFrete  := 0
		_nVlPbruto := 0
		_nVlPsol   := 0
		_nVlEntreg := 0
		_nVlKm     := 0
		@nLin,000 Psay xSZK->ZK_PLACAPG
		@nLin,021 Psay Alltrim(posicione("ZV4",1,xfilial("ZV4")+xSZK->ZK_PLACAPG,"ZV4_DESCRI"))
		//@nLin,034 Psay _nViagem
		_nViagem := SomaVlr(xSZK->ZK_PLACAPG,6)		
		@nLin,034 Psay _nViagem   
		_nVlFrete  := SomaVlr(xSZK->ZK_PLACAPG,1)
		@nLin,038 Psay _nVlFrete  Picture "@E 9,999,999.99"
		_nVlPbruto := SomaVlr(xSZK->ZK_PLACAPG,2)		
		@nLin,052 Psay _nVlPbruto Picture "@E 99,999,999.99"
		_nVlPsol   := SomaVlr(xSZK->ZK_PLACAPG,3)		
		@nLin,067 Psay _nVlPsol   Picture "@E 99,999,999.99"
		_nVlEntreg := SomaVlr(xSZK->ZK_PLACAPG,4)		
		@nLIn,083 Psay _nVlEntreg Picture "@E 99999"
		_nVlKm     := SomaVlr(xSZK->ZK_PLACAPG,5)		
		@nLin,095 Psay _nVlKm     Picture "@E 999,999.99" 		
		nLin += 1
		
		_nTotFret   += _nVlFrete
		_nTotPeso   += _nVlPbruto
		_nTotPL     += _nVlPsol
		_ntTKmpag   += _nVlKm
		_nTotEntr   += _nVlEntreg
		_nTotViag   += _nViagem		
		
		Reclock("EXC",.T.)
		EXC->PLACA     := xSZK->ZK_PLACAPG
		EXC->TPVEIC    := Alltrim(posicione("ZV4",1,xfilial("ZV4")+xSZK->ZK_PLACAPG,"ZV4_DESCRI"))
		EXC->VLFRETE   := _nVlFrete
		EXC->PBRUTO    := _nVlPbruto
		EXC->PLIQ      := _nVlPsol
		EXC->NENTREG   := _nVlEntreg
		EXC->KMENTRADA := _nVlKm
		EXC->VIAGEM    := _nViagem		
		//EXC->VL_DECR := _nDvlr
		//EXC->VL_ACRESC := _nAvlr                   
		//EXC->FRETELIQ := _nVlFrete - _nDvlr + _nAvlr             
		MsUnlock()			
			
	Endif	         
               
	dbSelectArea("SZI")
	dbSetOrder(2)
	dbSeek(xFilial("SZI")+xSZK->ZK_GUIA+xSZK->ZK_DTENTR+xSZK->ZK_PLACAPG)
	While !Eof() .And. xFilial() == SZI->ZI_FILIAL .And. ;
	SZI->ZI_GUIA == xSZK->ZK_GUIA .And. SZI->ZI_DATALAN == STOD(xSZK->ZK_DTENTR) .And. xSZK->ZK_PLACAPG == SZI->ZI_PLACA
		
		If nLin > 60
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)                                                          			
			nLin := 9
		Endif		                                                                                                    
		
		//nLin += 1		
		
		If SZI->ZI_TIPO == "D "
			nLin += 1
			@nLin,112 Psay SZI->ZI_CODIGO+"-"+Alltrim(Substr(SZI->ZI_DESCRIC,1,25))
			@nLin,142 Psay Transform(SZI->ZI_VALOR,"@E 9,999,999.99") 
			_nDvlr    += SZI->ZI_VALOR
			_nTotDvlr += SZI->ZI_VALOR
			//nLin += 1
		Elseif SZI->ZI_TIPO == "A "   
			nLin += 1
			@nLin,157 Psay SZI->ZI_CODIGO+"-"+Alltrim(Substr(SZI->ZI_DESCRIC,1,25))
			@nLin,187 Psay Transform(SZI->ZI_VALOR,"@E 9,999,999.99")
			_nAvlr    += SZI->ZI_VALOR
			_nTotAvlr += SZI->ZI_VALOR
			//nLin += 1
		Endif		 
		  			            	
		Reclock("EXC",.T.)
		If SZI->ZI_TIPO == "D "
			EXC->DECRESCIMO := SZI->ZI_CODIGO+"-"+Alltrim(Substr(SZI->ZI_DESCRIC,1,25))
			EXC->VL_DECR    := SZI->ZI_VALOR
		Elseif SZI->ZI_TIPO == "A "	
			EXC->ACRESCIMO  := SZI->ZI_CODIGO+"-"+Alltrim(Substr(SZI->ZI_DESCRIC,1,25))
			EXC->VL_ACRESC  := SZI->ZI_VALOR
		Endif	
		MsUnlock()		  		
		 			
		SZI->(DbSkip())
	Enddo	               	
	
	xSZK->(DbSkip())		
	
	If ALLTRIM(xSZK->ZK_PLACAPG) <> ALLTRIM(_cPlacaAnt) .and. _lEntrou
		_lEntrou := .F.
		nLin += 1
		@nLin,000 Psay Replicate("-",220)
		nLin += 1
		@nLin,142 Psay _nDvlr Picture "@E 9,999,999.99"
		@nLin,187 Psay _nAvlr Picture "@E 9,999,999.99"
		@nLin,205 Psay (_nVlFrete - _nDvlr + _nAvlr) Picture "@E 9,999,999.99"
		nLin += 1 
		@nLin,000 Psay Replicate("-",220)
		//nLin += 1  
		             
		//dbSelectArea("EXC")
		Reclock("EXC",.T.)
		EXC->VL_DECR := _nDvlr
		EXC->VL_ACRESC := _nAvlr                   
		EXC->FRETELIQ := _nVlFrete - _nDvlr + _nAvlr             
		MsUnlock()				
				
		_nDvlr := 0
		_nAvlr := 0
		
	Endif	
Enddo

nLin += 2
@nLin,000 Psay "Total Geral --->"
@nLin,030 Psay _nTotViag Picture "@E 999,999"
@nLin,038 Psay _nTotFret Picture "@E 9,999,999.99"
@nLin,052 Psay _nTotPeso Picture "@E 99,999,999.99"
@nLin,067 Psay _nTotPL   Picture "@E 99,999,999.99"
@nLIn,083 Psay _nTotEntr Picture "@E 99999"
@nLin,095 Psay _ntTKmpag Picture "@E 999,999.99"
@nLin,142 Psay _nTotDvlr Picture "@E 9,999,999.99"
@nLin,187 Psay _nTotAvlr Picture "@E 9,999,999.99"
@nLin,205 Psay (_nTotFret - _nTotDvlr + _nTotAvlr) Picture "@E 9,999,999.99"

dbCloseArea("xSZK")

IncProc("Gerando Planilha......")

//EXC->(dbclosearea())

Processa({||_fOpenExcel(cArqEXC)},"Abrindo Excel.....")			

fErase(cArqEXC+".dbf") 

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH() 

Return

Static Function fDados()
Local cQuery:=""

If Select("xSZK") > 0
   DbSelectArea("xSZK")
   DbCloseArea("xSZK")
Endif   

cQuery+=" SELECT "
cQuery+=" 	ZK_TIPFRT, "
cQuery+=" 	ZK_PLACAPG, "
cQuery+=" 	ZK_DTENTR, "
cQuery+=" 	ZK_FORNEC, "
cQuery+=" 	ZK_VALFRET, "
cQuery+=" 	ZK_PBRUTO, "
cQuery+=" 	ZK_PESOL, "
cQuery+=" 	ZK_GUIA, "
cQuery+=" 	ZK_ENTREGA-ZK_ENTRDEV AS ENTREGAS, "
cQuery+=" 	ZK_KMPAG, "
//cQuery+=" ZI_GUIA, ZI_PLACA, ZI_DATALAN, ZI_TIPO, ZI_VALOR,ZI_CODIGO, ZI_DESCRIC " 
//cQuery+=" FROM "+RETSQLNAME("SZK")+", "+RETSQLNAME("SZI")+" "
cQuery+=" ZK_NOMFOR "
cQuery+=" FROM "+RETSQLNAME("SZK")+" "
cQuery+=" WHERE "
cQuery+=" 	(ZK_DTENTR BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND "
cQuery+=" 	ZK_TIPFRT='"+MV_PAR03+"' AND "
If !Empty(MV_PAR05)
   &&Tratamento para automatizar o maximo possivel a digitação do parametro Mauricio 09/02/11. 
   _cPar05 := StrTran(mv_par05, ";", ",")
   _cPar05 := StrTran(mv_par05, "/", ",")
   _cPar05 := Alltrim(_cPar05)
   _cTpFret := ""
   _n2 := 0
   For i:=1 to len(_cPar05)
		If substr(Alltrim(_cPar05),i,1) == ","
		   If _n2 == 0
			  _cTpFret += "'"+Substr(_cPar05,i+1,2)+"',"
			  i += 3
			  _n2 += 1
		   Else
		      _cTpFret += "'"+substr(_cPar05,i,2)+"',"
			  i += 2
		   Endif	           
		Else 
			_cTpFret += "'"+substr(_cPar05,i,2)+"',"
			i += 2		
		Endif
   Next
   if substr(_cTpFret,Len(_cTpFret),1) == ","
      _cTpFret := Substr(_cTpFret,1,Len(_cTpFret)-1)
   endif   
   cQuery+=" ZK_TPFRETE IN ("+Alltrim(_cTpFret)+") AND "
Endif
/*
cQuery+=" ZI_GUIA=ZK_GUIA "
cQuery+=" AND ZI_DATALAN=ZK_DTENTR "
cQuery+=" AND ZI_PLACA=ZK_PLACAPG AND"   
*/
//cQuery+=" SZI010.D_E_L_E_T_=''"
cQuery+=" "+RetSqlName("SZK")+ ".D_E_L_E_T_='' "
if mv_par04 == 1
   //if mv_par06 == 1
      cQuery+=" ORDER BY "
      //cQuery+=" ZK_PLACAPG,ZK_DTENTR, ZI_TIPO "      
      cQuery+=" ZK_PLACAPG,ZK_DTENTR"
   /*
   Else
      cQuery+=" ORDER BY "
      cQuery+=" ZK_PLACAPG,ZK_DTENTR "
   Endif
   */
Else
   //If mv_par06 == 1
      cQuery+=" ORDER BY "
      //cQuery+=" ZK_PLACAPG,ZK_DTENTR, ZI_TIPO "
      cQuery+=" ZK_PLACAPG,ZK_DTENTR"
   /*
   Else
      cQuery+=" ORDER BY "
      cQuery+=" ZK_DTENTR, ZK_PLACAPG "
   Endif
   */
Endif
TCQUERY cQuery NEW ALIAS "xSZK"
dbselectArea("xSZK")
DbgoTop()                            

Return()
                       
//Incluido 12/04/11 - Ana - Para totalizar o campo Vlr. Frete
//Alterado 04/05/11 - Ana - Para realizar o mesmo processo com os campos ZK_PBRUTO , ZK_PESOL , ZK_ENTREGAS , ZK_KMPAG. Solicitacao do chamado 010082           
Static function SomaVlr(_cPlaca,_nCampo)  

/*
_nCampo se:
1 - ZK_VALFRET
2 - ZK_PBRUTO
3 - ZK_PESOL
4 - ZK_ENTREGAS
5 - ZK_KMPAG
*/

Local cQueryTF:=""
Local _cPlaca
Local _nVal := 0  
Local _cTpFret := ""

If Select("xSZK2") > 0
   DbSelectArea("xSZK2")
   DbCloseArea("xSZK2")
Endif   

//cQueryTF := " SELECT SUM (ZK_VALFRET) AS TOTFRETE, SUM (ZK_PBRUTO) AS TOTPBRUT, SUM (ZK_PESOL) AS TOTPSOL, SUM (ZK_ENTREGA-ZK_ENTRDEV) AS TOTENTR, SUM (ZK_KMPAG) AS TOTKM "
cQueryTF := " SELECT SUM (ZK_VALFRET) AS TOTFRETE, SUM (ZK_PBRUTO) AS TOTPBRUT, SUM (ZK_PESOL) AS TOTPSOL, SUM (ZK_ENTREGA) AS TOTENTR, SUM (ZK_KMPAG) AS TOTKM ,COUNT(*) AS QTDVIAG"
cQueryTF += " FROM "+RETSQLNAME("SZK")+" "  
cQueryTF += " WHERE "
cQueryTF += " (ZK_DTENTR BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND "

If !Empty(MV_PAR05)
   &&Tratamento para automatizar o maximo possivel a digitação do parametro Mauricio 09/02/11. 
   _cPar05 := StrTran(mv_par05, ";", ",")
   _cPar05 := StrTran(mv_par05, "/", ",")
   _cPar05 := Alltrim(_cPar05)
   _cTpFret := ""
   _n2 := 0
   For i:=1 to len(_cPar05)
		If substr(Alltrim(_cPar05),i,1) == ","
		   If _n2 == 0
			  _cTpFret += "'"+Substr(_cPar05,i+1,2)+"',"
			  i += 3
			  _n2 += 1
		   Else
		      _cTpFret += "'"+substr(_cPar05,i,2)+"',"
			  i += 2
		   Endif	           
		Else 
			_cTpFret += "'"+substr(_cPar05,i,2)+"',"
			i += 2		
		Endif
   Next
   if substr(_cTpFret,Len(_cTpFret),1) == ","
      _cTpFret := Substr(_cTpFret,1,Len(_cTpFret)-1)
   endif   
Endif                                                               
cQueryTF+=" ZK_TPFRETE IN ("+Alltrim(_cTpFret)+") AND "
cQueryTF+=" 	ZK_TIPFRT='"+MV_PAR03+"' AND "
cQueryTF += " D_E_L_E_T_='' AND ZK_PLACAPG ='" + _cPlaca + "' "   

TCQUERY cQueryTF NEW ALIAS "xSZK2"
dbselectArea("xSZK2")    
                     
If _nCampo == 1
	_nVal := xSZK2->TOTFRETE
Elseif _nCampo == 2      
	_nVal := xSZK2->TOTPBRUT
Elseif _nCampo == 3
	_nVal := xSZK2->TOTPSOL
Elseif _nCampo == 4
	_nVal := xSZK2->TOTENTR
Elseif _nCampo == 5
	_nVal := xSZK2->TOTKM
Elseif _nCampo == 6
	_nVal := xSZK2->QTDVIAG	
Endif
 	
dbCloseArea("xSZK2")
DbSelectArea("xSZK")

Return(_nVal)            

Static Function _fOpenExcel(cArqTRC)

Local cDirDocs	:= MsDocPath()
Local cPath		:= AllTrim(GetTempPath())

//³Copia DBF para pasta TEMP do sistema operacional da estacao ³

If FILE(cArqTRC+".DBF")
	COPY FILE (cArqTRC+".DBF") TO (ALLTRIM(mv_par06)+cArqTRC+".DBF")
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