#Include "Protheus.ch"
#Include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³          º Autor ³ EVERALDO CASAROLI  º Data ³  19/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºItem      ³ U_LP590002                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz verificação se o tipo do titulo vinculado ao cheque e  º±±
±±º          ³ do Tipo PA, e retorna o valor do cheque.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 051833 || OS 053189 || CONTROLADORIA || MONIK_MACEDO ||    º±±
±±º          ³ || 8956 || LP'S 590/012 - fwnm - 30/09/2019                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Chamado n. 051833
https://tdn.totvs.com.br/pages/releaseview.action?pageId=6070665

Lançamento padrão 590 - geração de cheques FINA190
A segunda perna do lançamento padrao 590, realizada pelo total (Cheque Aglutinador), 
é executada desposicionando-se os arquivos SE2 e SEF, 
sendo disponibilizadas as seguintes variáveis para serem utilizadas no lançamento padrao :

VALOR Corresponde ao Valor do Cheque aglutinador (EF_VALOR)
STRLCTPAD Corresponde ao histórico do Cheque aglutinador (EF_HIST) 
NUMCHEQUE Corresponde ao numero do cheque aglutinador (EF_NUM)
ORIGCHEQ Corresponde à origem do cheque aglutinador (EF_ORIGEM)

/*/

USER FUNCTION LP590002()

	// Chamado n. 051833 || OS 053189 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP'S 590/012 - fwnm - 30/09/2019
	Local nVlr		:= VALOR 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	/*
	Local _aArea	:= GetArea()
	Local _Bco		:= SEF->EF_BANCO
	Local _Ag		:= SEF->EF_AGENCIA
	Local _Cta		:= SEF->EF_CONTA
	Local _Chq		:= SEF->EF_NUM 
	Local cNotFor   := GetMV("MV_#LP59FO",,"'000217','002922','006460','015513'")

	IF ALLTRIM(SEF->EF_TIPO)=="PA"
		
		cQuery := "SELECT * FROM " + RetSqlName("SEF")+;
		" WHERE EF_BANCO = '" + _Bco + "'"+;
		" AND EF_AGENCIA = '" + _Ag + "'"+;
		" AND EF_CONTA = '" + _Cta + "'"+;
		" AND EF_NUM = '" + _Chq + "'"+;
		" AND EF_TIPO = 'PA'"+;
		" AND EF_FORNECE NOT IN (" + cNotFor + ")"+;
		" AND D_E_L_E_T_ = ''"+;
		" AND R_E_C_N_O_=(SELECT MIN(R_E_C_N_O_) FROM " + RetSqlName("SEF")+;
		" WHERE EF_BANCO	= '" + _Bco + "'"+;
		" AND EF_AGENCIA = '" + _Ag + "'"+;
		" AND EF_CONTA = '" + _Cta + "'"+;
		" AND EF_NUM = '" + _Chq + "'"+;
		" AND EF_TIPO = 'PA'"+;
		" AND EF_FORNECE NOT IN (" + cNotFor + ")"+;
		" AND D_E_L_E_T_ = '')"

		TCQUERY cQuery new alias "XEF"
		
		dbSelectArea("XEF")
		
		If SEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA) == XEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA)
			
			cQuery := 	"SELECT EF_VALOR FROM " + RetSqlName("SEF")+;
			" WHERE EF_BANCO ='" + _Bco + "'"+;
			" AND EF_AGENCIA ='" + _Ag +"'"+;
			" AND EF_CONTA ='" + _Cta + "'"+;
			" AND EF_NUM ='" + _Chq + "'"+;
			" AND EF_TIPO =''"+;
			" AND D_E_L_E_T_ = ''"

			TCQUERY cQuery new alias "YEF"
			
			dbSelectArea("YEF")
			
			nVlr := YEF->EF_VALOR
			
			dbCloseArea()
			
		Endif
		
		dbSelectArea("XEF")
		dbCloseArea()
		
	Endif
	
	RestArea( _aArea )
	*/

RETURN(nVlr)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³          º Autor ³ EVERALDO CASAROLI  º Data ³  19/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºItem      ³ U_LP590CTA                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Retorna a conta contabil                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION LP590CTA()

	// Chamado n. 051833 || OS 053189 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP'S 590/012 - fwnm - 30/09/2019
	Local _cCtb		:= ""
	Local aAreaSA6 := SA6->( GetArea() )

	U_ADINF009P('LP590002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	/*
	Local _aArea	:= GetArea()
	Local _Bco		:= SEF->EF_BANCO
	Local _Ag		:= SEF->EF_AGENCIA
	Local _Cta		:= SEF->EF_CONTA
	Local	_Chq		:= SEF->EF_NUM
	Local nVlr		:= 0
	
	
	cQuery := "SELECT * FROM " + RetSqlName("SEF")+;
	" WHERE EF_BANCO = '" + _Bco + "'"+;
	" AND EF_AGENCIA = '" + _Ag + "'"+;
	" AND EF_CONTA = '" + _Cta + "'"+;
	" AND EF_NUM = '" + _Chq + "'"+;
	" AND EF_TIPO = 'PA'"+;
	" AND D_E_L_E_T_ = ''"+;
	" AND R_E_C_N_O_=(SELECT MIN(R_E_C_N_O_) FROM " + RetSqlName("SEF")+;
	" WHERE EF_BANCO	= '" + _Bco + "'"+;
	" AND EF_AGENCIA = '" + _Ag + "'"+;
	" AND EF_CONTA = '" + _Cta + "'"+;
	" AND EF_NUM = '" + _Chq + "'"+;
	" AND EF_TIPO = 'PA'"+;
	" AND D_E_L_E_T_ = '')"
	TCQUERY cQuery new alias "VEF"
	
	dbSelectArea("VEF")
	
	If SEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA) == VEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA)
		
		IF !EMPTY(VEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA))
			
			dbSelectArea("SE2")
			dbSetOrder(1)
			dbSeek( xFilial("SE2")+ VEF->(EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO) )
			
			_cCtb := SE2->E2_DEBITO
			
		ENDIF
	
			dbCloseArea()
		
	ENDIF
	
	dbSelectArea("VEF")
	dbCloseArea()
	
	RestArea( _aArea )
	*/
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT EF_FILIAL, EF_PREFIXO, EF_TITULO, EF_PARCELA, EF_TIPO, EF_NUM, EF_BENEF, EF_FORNECE, EF_LOJA, EF_BANCO, EF_AGENCIA, EF_CONTA "
	cQuery += " FROM " + RetSqlName("SEF") + " SEF (NOLOCK) "
	cQuery += " WHERE EF_NUM='"+NUMCHEQUE+"' "
	cQuery += " AND EF_SEQUENC='01' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( !EOF() )
		SA6->( dbSetOrder(1) ) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON                                                                                                                           
		If SA6->( dbSeek(FWxFilial("SA6")+Work->(EF_BANCO+EF_AGENCIA+EF_CONTA)) )
			_cCtb := SA6->A6_CONTA
		EndIf
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	RestArea( aAreaSA6 )
	//
	
RETURN(_cCtb)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³          º Autor ³ EVERALDO CASAROLI  º Data ³  19/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºItem      ³ U_LP590NCC                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz verificação se o tipo do titulo vinculado ao cheque e  º±±
±±º          ³ do Tipo PA, e retorna o valor do cheque.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION LP590NCC()

	Local _aArea	:= GetArea()
	Local _Bco		:= SEF->EF_BANCO
	Local _Ag		:= SEF->EF_AGENCIA
	Local _Cta		:= SEF->EF_CONTA
	Local	_Chq		:= SEF->EF_NUM
	Local nVlr		:= 0

	U_ADINF009P('LP590002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF ALLTRIM(SEF->EF_TIPO)=="NCC"
		
		cQuery := "SELECT * FROM " + RetSqlName("SEF")+;
		" WHERE EF_BANCO = '" + _Bco + "'"+;
		" AND EF_AGENCIA = '" + _Ag + "'"+;
		" AND EF_CONTA = '" + _Cta + "'"+;
		" AND EF_NUM = '" + _Chq + "'"+;
		" AND EF_TIPO = 'NCC'"+;
		" AND D_E_L_E_T_ = ''"+;
		" AND R_E_C_N_O_=(SELECT MIN(R_E_C_N_O_) FROM " + RetSqlName("SEF")+;
		" WHERE EF_BANCO	= '" + _Bco + "'"+;
		" AND EF_AGENCIA = '" + _Ag + "'"+;
		" AND EF_CONTA = '" + _Cta + "'"+;
		" AND EF_NUM = '" + _Chq + "'"+;
		" AND EF_TIPO = 'NCC'"+;
		" AND D_E_L_E_T_ = '')"
		TCQUERY cQuery new alias "WEF"
		
		
		dbSelectArea("WEF")
		
		If SEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA) == WEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA)
			
			
			cQuery := 	"SELECT EF_VALOR FROM " + RetSqlName("SEF")+;
			" WHERE EF_BANCO ='" + _Bco + "'"+;
			" AND EF_AGENCIA ='" + _Ag +"'"+;
			" AND EF_CONTA ='" + _Cta + "'"+;
			" AND EF_NUM ='" + _Chq + "'"+;
			" AND EF_TIPO =''"+;
			" AND D_E_L_E_T_ = ''"
			TCQUERY cQuery new alias "YEF"
			
			dbSelectArea("YEF")
			
			nVlr := YEF->EF_VALOR
			
			dbCloseArea()
			
		Endif
		
		dbSelectArea("WEF")
		dbCloseArea()
		
	Endif
	
	RestArea( _aArea )

RETURN(nVlr)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³          º Autor ³ EVERALDO CASAROLI  º Data ³  19/06/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºItem      ³ U_LP590BON                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz verificação se o tipo do titulo vinculado ao cheque e  º±±
±±º          ³ do Tipo PA, e retorna o valor do cheque.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION LP590BON()

	Local _aArea	:= GetArea()
	Local _Bco		:= SEF->EF_BANCO
	Local _Ag		:= SEF->EF_AGENCIA
	Local _Cta		:= SEF->EF_CONTA
	Local	_Chq		:= SEF->EF_NUM
	Local nVlr		:= 0

	U_ADINF009P('LP590002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF ALLTRIM(SEF->EF_TIPO)=="BON"
		
		cQuery := "SELECT * FROM " + RetSqlName("SEF")+;
		" WHERE EF_BANCO = '" + _Bco + "'"+;
		" AND EF_AGENCIA = '" + _Ag + "'"+;
		" AND EF_CONTA = '" + _Cta + "'"+;
		" AND EF_NUM = '" + _Chq + "'"+;
		" AND EF_TIPO = 'BON'"+;
		" AND D_E_L_E_T_ = ''"+;
		" AND R_E_C_N_O_=(SELECT MIN(R_E_C_N_O_) FROM " + RetSqlName("SEF")+;
		" WHERE EF_BANCO	= '" + _Bco + "'"+;
		" AND EF_AGENCIA = '" + _Ag + "'"+;
		" AND EF_CONTA = '" + _Cta + "'"+;
		" AND EF_NUM = '" + _Chq + "'"+;
		" AND EF_TIPO = 'BON'"+;
		" AND D_E_L_E_T_ = '')"
		TCQUERY cQuery new alias "KEF"
		
		
		dbSelectArea("KEF")
		
		If SEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA) == KEF->(EF_PREFIXO + EF_TITULO + EF_PARCELA)
			
			
			cQuery := 	"SELECT EF_VALOR FROM " + RetSqlName("SEF")+;
			" WHERE EF_BANCO ='" + _Bco + "'"+;
			" AND EF_AGENCIA ='" + _Ag +"'"+;
			" AND EF_CONTA ='" + _Cta + "'"+;
			" AND EF_NUM ='" + _Chq + "'"+;
			" AND EF_TIPO =''"+;
			" AND D_E_L_E_T_ = ''"
			TCQUERY cQuery new alias "YEF"
			
			dbSelectArea("YEF")
			
			nVlr := YEF->EF_VALOR
			
			dbCloseArea()
			
		Endif
		
		dbSelectArea("KEF")
		dbCloseArea()
	
	Endif
	
	RestArea( _aArea )

RETURN(nVlr)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºChamado   ³ 051833 || OS 053189 || CONTROLADORIA || MONIK_MACEDO ||    º±±
±±º          ³ || 8956 || LP'S 590/012 - fwnm - 30/09/2019                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP590HIST()

	Local cHist  := ""
	Local cQuery := ""

	U_ADINF009P('LP590002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT EF_FILIAL, EF_PREFIXO, EF_TITULO, EF_PARCELA, EF_TIPO, EF_NUM, EF_BENEF, EF_FORNECE, EF_LOJA "
	cQuery += " FROM " + RetSqlName("SEF") + " SEF (NOLOCK) "
	cQuery += " WHERE EF_NUM='"+NUMCHEQUE+"' "
	cQuery += " AND EF_SEQUENC='01' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	If Work->( !EOF() )
		cHist := "PAGTO PA " + Work->(EF_PREFIXO+EF_TITULO+EF_PARCELA) + " FORNECEDOR " + Work->(EF_FORNECE+EF_LOJA)
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return cHist