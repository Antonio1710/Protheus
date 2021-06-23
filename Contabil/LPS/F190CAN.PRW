#Include "Protheus.ch"
#Include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ          บ Autor ณ EVERALDO CASAROLI  บ Data ณ  19/06/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบItem      ณ U_LP590002                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescrio ณ Faz verifica็ใo se o tipo do titulo vinculado ao cheque e  บฑฑ
ฑฑบ          ณ do Tipo PA, e retorna o valor do cheque.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especกfico Ad'oro                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

//STATIC _xTipo	:= ""

USER FUNCTION F190CAN()

Local _aArea	:= GetArea()
Local _Bco		:= SEF->EF_BANCO
Local _Ag		:= SEF->EF_AGENCIA
Local _Cta		:= SEF->EF_CONTA
Local	_Chq		:= SEF->EF_NUM

STATIC _xTipo	:= ""
STATIC _cContab:= ""

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cQuery := "SELECT * FROM " + RetSqlName("SEF")+;
" WHERE EF_BANCO = '" + _Bco + "'"+;
" AND EF_AGENCIA = '" + _Ag + "'"+;
" AND EF_CONTA = '" + _Cta + "'"+;
" AND EF_NUM = '" + _Chq + "'"+;
" AND EF_TIPO IN ('NCC','BON','PA')"+;
" AND D_E_L_E_T_ = ''"+;
" AND R_E_C_N_O_=(SELECT MIN(R_E_C_N_O_) FROM " + RetSqlName("SEF")+;
" WHERE EF_BANCO	= '" + _Bco + "'"+;
" AND EF_AGENCIA = '" + _Ag + "'"+;
" AND EF_CONTA = '" + _Cta + "'"+;
" AND EF_NUM = '" + _Chq + "'"+;
" AND EF_TIPO IN ('NCC','BON','PA')"+;
" AND D_E_L_E_T_ = '')"
TCQUERY cQuery new alias "ZEF"

dbSelectArea("ZEF")



If SEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA) == ZEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA)
	
	IF !EMPTY(ZEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA))
		
		_xTipo := alltrim(ZEF->EF_TIPO)
		
		IF Alltrim(_xTipo) == "PA"
			
			dbSelectArea("SE2")
			dbSetOrder(1)
			dbSeek( xFilial("SE2")+ZEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO) )
			
			_cContab := SE2->E2_DEBITO
			
		ENDIF
		
	ENDIF
	
Endif

dbSelectArea("ZEF")
dbCloseArea()
                                             
//Incluido trecho do ponto de entrada \TOTVS\Protheus11\FontesAd.oro\Financeiro\PE\F190CAN.PRW
dbSelectAreA('SEF')
//--- Cheque jแ Impresso e com N๚mero de Cheque; Grava Data de Cancelamento 
If Alltrim(SEF->EF_IMPRESS)="S"  .And. !Empty(SEF->EF_NUM) 	
   RecLock("SEF",.F.)    
   SEF->EF_XDTCANC:= DDATABASE   
   SEF->EF_XDTCANS:= DATE()
   MsUnlock()
Endif
//
	  	
RestArea( _aArea )

RETURN (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ          บ Autor ณ EVERALDO CASAROLI  บ Data ณ  19/06/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบItem      ณ U_LP590002                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescrio ณ Faz verifica็ใo se o tipo do titulo vinculado ao cheque e  บฑฑ
ฑฑบ          ณ do Tipo PA, e retorna o valor do cheque.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especกfico Ad'oro                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CANLP591(cTipo)

Local _aArea	:= GetArea()
Local nVlr		:= 0
//cTipo := Paramixb

U_ADINF009P('F190CAN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

IF _xTipo == cTipo
	
	nVlr := SE5->E5_VALOR
	
ENDIF

RestArea( _aArea )

RETURN (nVlr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ          บ Autor ณ EVERALDO CASAROLI  บ Data ณ  19/06/2008 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบItem      ณ U_LP590002                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescrio ณ Faz verifica็ใo se o tipo do titulo vinculado ao cheque e  บฑฑ
ฑฑบ          ณ do Tipo PA, e retorna o valor do cheque.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especกfico Ad'oro                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CAN591PA()

Local _aArea	:= GetArea()
Local _cCtadeb	:= ""

U_ADINF009P('F190CAN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

IF ALLTRIM(_xTipo) == "PA"
	
	_cCtadeb := _cContab
	
ENDIF

RestArea( _aArea )

RETURN (_cCtadeb)
