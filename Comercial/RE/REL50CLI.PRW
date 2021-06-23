#include "rwmake.ch"
#include "topconn.ch"
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³REL50CLI  ³ Autor ³Mauricio-MDS TEC       ³ Data ³ 26/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio acompanhamento 50 maiores clientes p/supervisores³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Adoro Alimenticia                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function REL50CLI() 
  
SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,")
Private cArq
Private oExcelApp   
Private _cTes := ""
Private _nMeta1 := 0
Private _nReal1 := 0
Private _nFat1  := 0
Private _nMeta2 := 0
Private _nReal2 := 0
Private _nFat2  := 0
Private _nMeta3 := 0
Private _nReal3 := 0
Private _nFat3  := 0
Private _nMeta4 := 0
Private _nReal4 := 0
Private _nFat4  := 0
Private _nMeta5 := 0
Private _nReal5 := 0
Private _nFat5  := 0
Private _Eof 	:= Chr(13) + Chr(10)
Private _nMTPRC:=0
Private _aTotPed := {}
Private _lDiret := .F.
Private _cUsuCod    := GetMV("MV_#USUTPR")  &&criar parametro caso este ja não exista..verificar com vagner/Ti.

aOrd             := {}
tamanho          := "G"
limite           := 220
nomeprog         := "REL50CLI"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 80
nItem            := 1
lContinua        := .T.
cPerg            := "BIGCLI"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio acompanhamento 50 maiores clientes p/supervisores')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T. 

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

aHelpGrp := {}
aHelpGrS := {}
aHelpGri := {}

PutSX1(cPerg,"01","Supervisor De "        ,"Supervisor De "          ,"Supervisor De "          ,"mv_ch1","C",06,0,0,"G",""          ,"A06","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
PutSX1(cPerg,"02","Supervisor Ate"        ,"Supervisor Ate"          ,"Supervisor Ate"          ,"mv_ch2","C",06,0,0,"G",""          ,"A06","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")
PutSx1(cPerg,"03","Nr.dias corridos"      ,"Nr.dias corridos"        ,"Nr.dias corridos"        ,"mv_ch3","N",02,0,0,"G",""          ,""   ,"","","mv_par03" ,"","","","","","","","","","","","","","",""," ")
//PutSx1(cPerg,"04","Dias totais periodo"   ,"Dias totais periodo"     ,"Dias totais periodo"     ,"mv_ch4","N",03,0,0,"G",""          ,""   ,"","","mv_par04" ,"","","","","","","","","","","","","","",""," ")
Pergunte(cPerg,.F.)

cString := "ZZY"
titulo  := "ACOMPANHAMENTO 50 MAIORES CLIENTES "
cDesc1  := "Este programa tem como objetivo gerar planilha excel do relatorio"
cDesc2  := "de acompanhamento aos 50 maiores clientes por supervisores."
cDesc3  := "By Ad'Oro"
NomeRel := "R50MAIOR"

nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|| GeraPlan() },Titulo)

Return
	
Static Function GeraPlan()
 
&&Verifica se o usuario emissor do relatório é Diretor ou Não.
_cCodUsua := __cUserID
//if _cCodUsua $ "000460/000798"  &&Mauricio 16/01/13 - Vagner solicitou liberar para usuarios Thaina e Dyogenes uso do relatorio
if _cCodUsua $ "000460/000798/001294"  &&Mafra 03/12/13 - Vagner solicitou liberar para usuario Back_Office uso do relatorio
   _lDiret := .T.
Else   
   DbSelectArea("SA3")
   DbSetOrder(7)
   if dbseek(xFilial("SA3")+_cCodUsua)
      If _cCodUsua $ _cUsuCod    //If SA3->A3_NIVETAB == "4"
         _lDiret := .T.
        //Elseif SA3->A3_NIVETAB == "3"
        //   _lGerent := .T.
        //   _cCodigo := SA3->A3_COD
        //Elseif SA3->A3_NIVETAB == "2"
        //   _lSuperv := .T.
        //   _cCodigo := SA3->A3_CODSUP
        //Else
        //   _lVended := .T.
        //   _cCodigo := SA3->A3_COD        
      Endif
   Else
      MsgInfo("Seu usuario não possui cadastro na tabela de vendedores e não podera emitir este relatorio.","Atenção")
      Return()
   Endif
Endif

fSeleciona()

cPath    := AllTrim(GetTempPath())
cArq     := "REL50CLI.CSV"

if file(cPath+"\REL50CLI.CSV")
	FErase(cPath+"\REL50CLI.CSV")		
endif

if file("\SYSTEM\REL50CLI.CSV")
	FErase("\SYSTEM\REL50CLI.CSV")
endif

nHdl := fCreate(cArq,0)
_Vazia := ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"+_eof
cLin := ""
&&33 colunas
cLin := ";;;;;;;;;SEM 1;;;SEM 2;;;SEM 3;;;SEM 4;;;SEM 5;;;;;;;;;Dias Corr.:;"+Transform(MV_PAR03,"@E 999")+";"+_eof
fWrite(nHdl,cLin,Len(cLin))                                                  
cLin := "Cliente;Loja;Nome Cliente;Cart;Nome Vend;LJS;Fat Periodo;Vol Periodo;Meta;Real;Saldo;Meta;Real;Saldo;Meta;Real;Saldo;Meta;Real;Saldo;Meta;Real;Saldo;Meta Mes;Real Mes;Saldo Mes;% Meta;Proj.Mes;Dif. Meta;IPM Hist.;IPM Mes;Vol/Ped;N.Ped"+_eof
fWrite(nHdl,cLin,Len(cLin))
fWrite(nHdl,_Vazia,Len(_vazia))    &&inclui 1 linha em branco

DbSelectArea("xZZY")
DbGotop()
ProcRegua(RecCount())

_xTotFatP := 0
_xTotVolP := 0
_xTotMSM1 := 0
_xTotRSM1 := 0
_xTotMSM2 := 0
_xTotRSM2 := 0
_xTotMSM3 := 0
_xTotRSM3 := 0
_xTotMSM4 := 0
_xTotRSM4 := 0
_xTotMSM5 := 0
_xTotRSM5 := 0
_xTotMMes := 0
_xTotRMes := 0
_xTotRPrj := 0
_xTotMPrj := 0
 
While xZZY->(!EOF())
	cLin := ""
	_cSuper  := xZZY->ZZY_SUPERV
	_cNomSup := Posicione("SZR",1,xFilial("SZR")+_cSuper,"ZR_DESCRIC")
	DbSelectArea("ZZY")
	cLin += _cSuper+";"
	cLin += _cNomSup+";"+_eof
	fWrite(nHdl,cLin,Len(cLin))
	IncProc("Gerando relatorio para supervisor "+_cSuper)
	
	_nTotFatP := 0
	_nTotVolP := 0
	_nTotMSM1 := 0
	_nTotRSM1 := 0
	_nTotMSM2 := 0
	_nTotRSM2 := 0
	_nTotMSM3 := 0
	_nTotRSM3 := 0
	_nTotMSM4 := 0
	_nTotRSM4 := 0
	_nTotMSM5 := 0
	_nTotRSM5 := 0
	_nTotMMes := 0
	_nTotRMes := 0
	_nTotRPrj := 0
	_nTotMPrj := 0
	clin := ""
	While _cSuper == xZZY->ZZY_SUPERV
		_cNomVd := Posicione("SA3",1,xFilial("SA3")+xZZY->ZZY_VEND,"A3_NREDUZ")
		DbSelectArea("ZZY")
		cLin += xZZY->ZZY_CLIENT+";"
		cLin += xZZY->ZZY_LOJA+";"
		cLin += xZZY->ZZY_NOME+";"
		cLin += xZZY->ZZY_VEND+";"
		cLin += _cNomVd+";"
		&&apuro a quantidade de lojas desse cliente caso REDE.
		If xZZY->ZZY_REDVAR == "R"
			_nLojas := fcontloj(xZZY->ZZY_CLIENT)
		Else
			_nLojas := 1
		Endif
		cLin += Transform(_nLojas,"@E 999")+";"
		cLin += Transform(xZZY->ZZY_FATURA,"@E 999,999,999,999.99")+";"
		cLin += Transform(xZZY->ZZY_VOLUME,"@E 999,999,999")+";"
		 
		&&apuracao da BASE DA META VOLUME CONFORME O PERIODO.
		_nVolTot := xZZY->ZZY_VOLUME
		_nDiaTot := xZZY->ZZY_DIATOT   //xZZY->ZZY_PERFIM - xZZY->ZZY_PERINI
		_nDiaMes := xZZY->ZZY_SEM5FN - xZZY->ZZY_SEM1IN
		_nFator  := xZZY->ZZY_FATOR
		_nDiaCor := MV_PAR03
		_nMetaT  := (((_nVolTot/_nDiaTot)*25))*_nFator &&Meta volume para todo o periodo(mes)
		&&apuração valores semanais Reais e Meta por cliente
		_nMeta1 := 0
		_nReal1 := 0
		_nFat1  := 0
		_nMeta2 := 0
		_nReal2 := 0
		_nFat2  := 0
		_nMeta3 := 0
		_nReal3 := 0
		_nFat3  := 0
		_nMeta4 := 0
		_nReal4 := 0
		_nFat4  := 0
		_nMeta5 := 0
		_nReal5 := 0
		_nFat5  := 0
		&&como o mes é definido por dias corridos informado em parametro, para apurar a META SEMANAL, divido a META TOTAL por uma razão
		&& calculada proporcionalmente por semana.
		If !Empty(xZZY->ZZY_SEM5FN)    &&se tem 5 semanas
			_nMesTodo := (xZZY->ZZY_SEM5FN - xZZY->ZZY_SEM1IN)
		Else   &&senao é 4 semanas
			_nMesTodo := (xZZY->ZZY_SEM4FN - xZZY->ZZY_SEM1IN)
		Endif
		_nFatSem1 := (xZZY->ZZY_SEM1FN - xZZY->ZZY_SEM1IN)/_nMesTodo
		_nFatSem2 := (xZZY->ZZY_SEM2FN - xZZY->ZZY_SEM2IN)/_nMesTodo
		_nFatSem3 := (xZZY->ZZY_SEM3FN - xZZY->ZZY_SEM3IN)/_nMesTodo
		If !Empty(xZZY->ZZY_SEM5FN)
			_nFatSem4 := (xZZY->ZZY_SEM4FN - xZZY->ZZY_SEM4IN)/_nMesTodo
			_nFatSem5 := 1  - (_nFatSem1 + _nFatsem2 + _nFatSem3 + _nFatSem4)
		Else
			_nFatSem4 := 1 - (_nFatSem1 + _nFatsem2 + _nFatSem3)
		Endif
		
		&&1 semana Meta e Real
		_nMeta1 := _nMetaT * _nFatSem1
		fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM1IN,xZZY->ZZY_SEM1FN,xZZY->ZZY_REDVAR,1)
		&&2 semana Meta e Real ...
		If !empty(xZZY->ZZY_SEM2IN)
			_nMeta2 := _nMetaT * _nFatSem2
			fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM2IN,xZZY->ZZY_SEM2FN,xZZY->ZZY_REDVAR,2)
		Endif
		&&3 semana Meta e Real
		If !empty(xZZY->ZZY_SEM3IN)
			_nMeta3 := _nMetaT * _nFatSem3
			fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM3IN,xZZY->ZZY_SEM3FN,xZZY->ZZY_REDVAR,3)
		Endif
		&&4 semana Meta e Real
		If !empty(xZZY->ZZY_SEM4IN)
			_nMeta4 := _nMetaT * _nFatSem4
			fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM4IN,xZZY->ZZY_SEM4FN,xZZY->ZZY_REDVAR,4)
		Endif
		&&5 semana Meta e Real
		If !empty(xZZY->ZZY_SEM5IN)
			_nMeta5 := _nMetaT * _nFatSem5
			fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM5IN,xZZY->ZZY_SEM5FN,xZZY->ZZY_REDVAR,5)
		Endif
		clin += Transform(_nMeta1,"@E 999,999,999")+";"
		clin += Transform(_nReal1,"@E 999,999,999")+";"
		cLin += Transform(_nReal1 - _nMeta1,"@E 999,999,999")+";"
		clin += Transform(_nMeta2,"@E 999,999,999")+";"
		clin += Transform(_nReal2,"@E 999,999,999")+";"
		cLin += Transform(_nReal2 - _nMeta2,"@E 999,999,999")+";"
		clin += Transform(_nMeta3,"@E 999,999,999")+";"
		clin += Transform(_nReal3,"@E 999,999,999")+";"
		cLin += Transform(_nReal3 - _nMeta3,"@E 999,999,999")+";"
		clin += Transform(_nMeta4,"@E 999,999,999")+";"
		clin += Transform(_nReal4,"@E 999,999,999")+";"
		cLin += Transform(_nReal4 - _nMeta4,"@E 999,999,999")+";"
		clin += Transform(_nMeta5,"@E 999,999,999")+";"
		clin += Transform(_nReal5,"@E 999,999,999")+";"
		cLin += Transform(_nReal5 - _nMeta5,"@E 999,999,999")+";"
		//clin += Transform((_nMeta1+_nMeta2+_nMeta3+_nMeta4+_nMeta5),"@E 999,999,999")+";"
		clin += Transform(_nMetaT,"@E 999,999,999")+";"
		clin += Transform((_nReal1+_nReal2+_nReal3+_nReal4+_nReal5),"@E 999,999,999")+";"
		//cLin += Transform((_nReal1+_nReal2+_nReal3+_nReal4+_nReal5) - (_nMeta1+_nMeta2+_nMeta3+_nMeta4+_nMeta5),"@E 999,999,999")+";"
		cLin += Transform((_nReal1+_nReal2+_nReal3+_nReal4+_nReal5) - _nMetaT,"@E 999,999,999")+";"
		cLin += Transform(((_nReal1+_nReal2+_nReal3+_nReal4+_nReal5) / _nMetaT)* 100,"@E 999 %")+";"
		&&Calculo projetado MEs
		_nVolMes := _nReal1+_nReal2+_nReal3+_nReal4+_nReal5
		If !Empty(xZZY->ZZY_SEM5IN)
			_nDiaMes := (xZZY->ZZY_SEM5FN - xZZY->ZZY_SEM1IN)
		Else
			_nDiaMes := (xZZY->ZZY_SEM4FN - xZZY->ZZY_SEM1IN)
		Endif
		_nProjR     := (_nVolMes/_nDiaCor)*25
		_nProjM     := _nProjR - _nMetaT
		cLin += Transform(_nProjR,"@E 999,999,999")+";"
		cLin += Transform(_nProjM,"@E 999,999,999")+";"
		cLin += Transform(xZZY->ZZY_IPM,"@E 999.999")+";"
		&& IPM mes
		&&IPM é o valor faturado/ volume * meta do supervisor
		&&este ultimo fapursem pega todo o periodo e traz(total META MES, FATURADO TOTAL MES e QUANTIDADE PEDIDO MES)
		_aTotPed := {}
		If !Empty(xZZY->ZZY_SEM5IN) &&so uso a variavel _nFat5 para controle.		
			fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM1IN,xZZY->ZZY_SEM5FN,xZZY->ZZY_REDVAR,0) &&só para a Meta do Mes valor
		Else
			fapurSem(xZZY->ZZY_CLIENT,xZZY->ZZY_LOJA,xZZY->ZZY_SEM1IN,xZZY->ZZY_SEM4FN,xZZY->ZZY_REDVAR,0) &&só para a Meta do Mes valor
		Endif
		_nIPMMES := _nFat5/(_nVolMes*_nMTPRC)
		cLin += Transform(_nIPMMES,"@E 999.999")+";"
		cLin += Transform((_nVolMes/Len(_aTotPed)),"@E 999,999.999")+";"
		cLin += Transform(Len(_aTotPed),"@E 999,999.999")+_eof
		fWrite(nHdl,cLin,Len(cLin))
		cLin := ""
		_nTotFatP += xZZY->ZZY_FATURA
		_nTotVolP += xZZY->ZZY_VOLUME
		_nTotMSM1 += _nMeta1
		_nTotRSM1 += _nReal1
		_nTotMSM2 += _nMeta2
		_nTotRSM2 += _nReal2
		_nTotMSM3 += _nMeta3
		_nTotRSM3 += _nReal3
		_nTotMSM4 += _nMeta4
		_nTotRSM4 += _nReal4
		_nTotMSM5 += _nMeta5
		_nTotRSM5 += _nReal5
		_nTotMMes += (_nMeta1+_nMeta2+_nMeta3+_nMeta4+_nMeta5)
		_nTotRMes += _NvolMes
		_nTotRPrj += _nProjR
		_nTotMPrj += _nProjM
		
		_xTotFatP += xZZY->ZZY_FATURA
		_xTotVolP += xZZY->ZZY_VOLUME
		_xTotMSM1 += _nMeta1
		_xTotRSM1 += _nReal1
		_xTotMSM2 += _nMeta2
		_xTotRSM2 += _nReal2
		_xTotMSM3 += _nMeta3
		_xTotRSM3 += _nReal3
		_xTotMSM4 += _nMeta4
		_xTotRSM4 += _nReal4
		_xTotMSM5 += _nMeta5
		_xTotRSM5 += _nReal5
		_xTotMMes += (_nMeta1+_nMeta2+_nMeta3+_nMeta4+_nMeta5)
		_xTotRMes += _NvolMes
		_xTotRPrj += _nProjR
		_xTotMPrj += _nProjM
		xZZY->(dbskip())
	Enddo
	cLin := "Total Supervisor;"+_cNomSup+";;;;;"+Transform(_nTotFatP,"@E 999,999,999,999.99")+";"+Transform(_nTotVolP,"@E 999,999,999,999.99")+";"+;
	Transform(_nTotMSM1,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM1,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM1-_nTotMSM1,"@E 999,999,999,999.99")+";"+;
	Transform(_nTotMSM2,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM2,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM2-_nTotMSM2,"@E 999,999,999,999.99")+";"+;
	Transform(_nTotMSM3,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM3,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM3-_nTotMSM3,"@E 999,999,999,999.99")+";"+;
	Transform(_nTotMSM4,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM4,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM4-_nTotMSM4,"@E 999,999,999,999.99")+";"+;
	Transform(_nTotMSM5,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM5,"@E 999,999,999,999.99")+";"+Transform(_nTotRSM5-_nTotMSM5,"@E 999,999,999,999.99")+";"+;
	Transform(_nTotMMes,"@E 999,999,999,999.99")+";"+Transform(_nTotRMes,"@E 999,999,999,999.99")+";"+Transform(_nTotRMes-_nTotMMes,"@E 999,999,999,999.99")+";"+;
	Transform((_nTotRMes/_nTotMMes)*100,"@E 999 %")+";"+Transform(_nTotRPrj,"@E 999,999,999,999.99")+";"+Transform(_nTotMPrj,"@E 999,999,999,999.99")+";"+_eof
	fWrite(nHdl,cLin,Len(cLin))
	fWrite(nHdl,_Vazia,Len(_vazia))    &&pula 1 linha
Enddo
	cLin := "Total Geral;;;;;;"+Transform(_xTotFatP,"@E 999,999,999,999.99")+";"+Transform(_xTotVolP,"@E 999,999,999,999.99")+";"+;
	Transform(_xTotMSM1,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM1,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM1-_xTotMSM1,"@E 999,999,999,999.99")+";"+;
	Transform(_xTotMSM2,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM2,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM2-_xTotMSM2,"@E 999,999,999,999.99")+";"+;
	Transform(_xTotMSM3,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM3,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM3-_xTotMSM3,"@E 999,999,999,999.99")+";"+;
	Transform(_xTotMSM4,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM4,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM4-_xTotMSM4,"@E 999,999,999,999.99")+";"+;
	Transform(_xTotMSM5,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM5,"@E 999,999,999,999.99")+";"+Transform(_xTotRSM5-_xTotMSM5,"@E 999,999,999,999.99")+";"+;
	Transform(_xTotMMes,"@E 999,999,999,999.99")+";"+Transform(_xTotRMes,"@E 999,999,999,999.99")+";"+Transform(_xTotRMes-_xTotMMes,"@E 999,999,999,999.99")+";"+;
	Transform((_xTotRMes/_xTotMMes)*100,"@E 999 %")+";"+Transform(_xTotRPrj,"@E 999,999,999,999.99")+";"+Transform(_xTotMPrj,"@E 999,999,999,999.99")+";"+_eof
	fWrite(nHdl,cLin,Len(cLin))                 
 
//Set Device to Screen

//If aReturn[5]==1
//	Set Printer to
//	OurSpool(NomeRel)
//endif

Ms_Flush()

fClose(nHdl)

bBloco:={|| _fOpenExcel()}
MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)

DbCloseArea("xZZY")

return()

Static Function fSeleciona()
Local cQuery:=""

If Select("xZZY") > 0
   DbSelectArea("xZZY")
   DbCloseArea("xZZY")
Endif
        
cQuery := "SELECT * "
cQuery += "FROM "+retsqlname("ZZY") +" ZZY "
cQuery += "WHERE ZZY.ZZY_SUPERV >= '"+mv_par01+"' AND ZZY.ZZY_SUPERV <= '"+mv_par02+"' AND ZZY.ZZY_VALIDO = 'X' "
If _lDiret
   cQuery += " AND ZZY.D_E_L_E_T_ <> '*' "
else
   cQuery += " AND ZZY.ZZY_CDUSSP = '"+__cUserID+"' AND ZZY.D_E_L_E_T_ <> '*' "   &&se nao for diretor só enxerga os proprios registros.
Endif       
cQuery += "ORDER BY ZZY.ZZY_SUPERV, ZZY.ZZY_RANK " 

TCQUERY cQuery NEW ALIAS "xZZY" 

TcSetField("xZZY", "ZZY_SEM1IN", "D")
TcSetField("xZZY", "ZZY_SEM1FN", "D")
TcSetField("xZZY", "ZZY_SEM2IN", "D")
TcSetField("xZZY", "ZZY_SEM2FN", "D")
TcSetField("xZZY", "ZZY_SEM3IN", "D")
TcSetField("xZZY", "ZZY_SEM3FN", "D")
TcSetField("xZZY", "ZZY_SEM4IN", "D")
TcSetField("xZZY", "ZZY_SEM4FN", "D")
TcSetField("xZZY", "ZZY_SEM5IN", "D")
TcSetField("xZZY", "ZZY_SEM5FN", "D")
TcSetField("xZZY", "ZZY_PERFIM", "D")
TcSetField("xZZY", "ZZY_PERINI", "D")

dbselectArea("xZZY")
DbgoTop()                            

Return()

Static Function _fOpenExcel()

CpyS2T("\SYSTEM\REL50CLI.CSV",cPath,.T.)

FerasE("\SYSTEM\REL50CLI.CSV")

//------------------------------
// Abre MS-EXCEL
//------------------------------
If ! ApOleClient( 'MsExcel' )
	MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
	Return
EndIf
oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
oExcelApp:SetVisible(.T.)

Return()


static function fcontloj(_cRede)
Local _cRede
Local _nQtd := 0

If Select("XSA1") > 0
   DbSelectArea("XSA1")
   DbCloseArea("XSA1")
Endif

_cQuery := ""
_cQuery += "SELECT COUNT(*) AS 'QTD'" 
_cQuery += "  FROM "+RetSqlName("SA1")+ " A1 "
_cQuery += " WHERE A1.D_E_L_E_T_ = ''"
_cQuery += "   AND A1.A1_REDE = '"+_cRede+"'"

TCQUERY _cQuery new alias "XSA1"
DbSelectarea("XSA1")
XSA1->(dbgotop())
_nQtd := XSA1->QTD
   
XSA1->(dbclosearea())

If _nQtd <= 0
   _nQtd := 1
endif   

return(_nQtd)

static function fapurSem(_cCodc,_cLojc,_dDin,_dFim,_cVarej,_nSemana)

If Select("XF2") > 0
   DbSelectArea("XF2")
   DbCloseArea("XF2")
Endif

If _cVarej == "V"
	&&Varejo somente
	cQuery:="select F2_FILIAL, F2_EMISSAO, F2_CLIENTE, F2_DOC, F2_SERIE, F2_LOJA, F2_VALBRUT , A1_NOME , A1_VEND, A1_DESC, A1_REDE, A1_EST, A1_COD_MUN "+; 			// Query incluida por Heraldo 29/10/02
	"from "+retsqlname("SF2")+" SF2, "+retsqlname("SA1")+" SA1 "+;
	"WHERE F2_TIPO='N' and "+;
	"F2_EMISSAO between '"+dtos(_dDin)+"' and '"+dtos(_dFim)+"' and "+;
	"F2_CLIENTE = '"+_cCodc+"' AND F2_LOJA = '"+_cLojc+"' AND "+;
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
		
		IncProc("VJ Filial-NFiscal: "+ XF2->F2_FILIAL+"-"+ XF2->F2_DOC )
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
			&&conto pedidos....
			_nAscan := Ascan( _aTotPed, { |x|x[ 01 ] == SD2->D2_PEDIDO } )
            If _nAscan <= 00
               Aadd( _aTotPed, { SD2->D2_PEDIDO } )          
            EndIf
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
			
			If (XF2->A1_DESC > 0) .and. (_nValorT>0)
				_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100)
			Endif
			
			// Alex Borges 01/12/11
			_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO)
			_nValorT := _nValorT - ( _Frete * _nQtd )
			
			dbSelectArea("SB1") // PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cProduto)
			_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO
			
			dbSelectArea("SBM") // GRUPO DE PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cGrupo)
			_cNivel := SBM->BM_NIVEL
					
			If _cNivel == "3"			   
			   If _nSemana == 1	
					//ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta1		:= 0 //_nMTPRC
					_nReal1		+=	_nQtd
			   Elseif _nSemana == 2
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta2		:=  0 //_nMTPRC
					_nReal2		+=	_nQtd
			   Elseif _nSemana == 3
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta3		:=  0 //_nMTPRC
					_nReal3		+=	_nQtd
			   Elseif _nSemana == 4
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta4		:=  0 //_nMTPRC
					_nReal4		+=	_nQtd
			   Elseif _nSemana == 5
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta5		:=  0 //_nMTPRC
					_nReal5		+=	_nQtd
			   Elseif _nSemana == 0
			        ACHAMETA(_dDin,_dFim)
			        _nFat5 += _nValorT	
			   Endif					
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
	"F2_EMISSAO between '"+dtos(_dDin)+"' and '"+dtos(_dFIm)+"' and "+;
	"A1_REDE = '"+_cCodc+"' AND "+;
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
			&&conto pedidos....
			_nAscan := Ascan( _aTotPed, { |x|x[ 01 ] == SD2->D2_PEDIDO } )
            If _nAscan <= 00
               Aadd( _aTotPed, { SD2->D2_PEDIDO } )          
            EndIf
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
			
			If (XF2->A1_DESC > 0) .and. (_nValorT>0)
				_nValorT := _nValorT-((_nValorT * XF2->A1_DESC) / 100)
			Endif
			
			// Alex Borges 01/12/11
			_Frete   := fBuscaFrt(_cFil,SD2->D2_PEDIDO)
			_nValorT := _nValorT - ( _Frete * _nQtd )
			
			dbSelectArea("SB1") // PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cProduto)
			_cGrupo		:= SB1->B1_GRUPO    //ALTERADO EM 28/12/06 - GRPANT PRESERVA O VALOR DE GRUPO
			
			dbSelectArea("SBM") // GRUPO DE PRODUTO
			DbSetOrder(1)
			dbSeek(xfilial() + _cGrupo)
			_cNivel := SBM->BM_NIVEL
			    		
			If _cNivel == "3"			
			   If _nSemana == 1	
					//ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta1		:= 0 //_nMTPRC
					_nReal1		+=	_nQtd
			   Elseif _nSemana == 2
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta2		:=  0 //_nMTPRC
					_nReal2		+=	_nQtd
			   Elseif _nSemana == 3
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta3		:=  0 //_nMTPRC
					_nReal3		+=	_nQtd
			   Elseif _nSemana == 4
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta4		:=  0 //_nMTPRC
					_nReal4		+=	_nQtd
			   Elseif _nSemana == 5
			        //ACHAMETA() 	 &&meta para calculo do IPM				
					//_nMeta5		:=  0 //_nMTPRC
					_nReal5		+=	_nQtd
			   Elseif _nSemana == 0
			        ACHAMETA(_dDin,_dFim)
			        _nFat5 += _nValorT	
			   Endif					   
			Endif
			dbSelectArea("SD2")
			SD2->(DbSkip())
		Enddo
		
		dbSelectArea("XF2")
		XF2->(dbskip())
	ENDDO
Endif

dbCloseArea("XF2")
return()

STATIC FUNCTION ACHAMETA(_d1,_d2)
&&para clientes _nMTVOL sempre é zero(condicao passada por vagner)

_nMTPRC:=0
//_nMTVOL:=0

dbSelectArea("SZL")
dbSetOrder(1)
             
dbSeek(xfilial("SZL") + _cSuperv	+ _cGrupo + DTOS(_d1))

_nContDias	:=	0
Do while !EOF()
		
	IF (dtos(SZL->ZL_DATA) > DTOS(_d2)) .or. _cGrupo != SZL->ZL_grupo
		exit
	Endif

	IF dtos(SZL->ZL_DATA) >= DTOS(_d1)
		If SZL->ZL_VALOR > 0		// incluido
			_nMTPRC	:=	_nMTPRC + SZL->ZL_VALOR
			_nContDias++			
		Endif		
		//If SZL->ZL_PESMETA > 0		// incluido
		//	_nMTVOL	:=	_nMTVOL + SZL->ZL_PESMETA
		//Endif
	Endif
	dbskip()                    
Enddo
_nMTPRC	:=	_nMTPRC / _nContDias
Return

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