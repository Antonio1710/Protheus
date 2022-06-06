#Include "Totvs.ch"
#Include "Restful.ch"
#Include "Topconn.ch"

User Function ADVEN053P()
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณconsultafinanceira บAutor  ณEverson  บ Data ณ  22/09/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณServi็o REST para consulta de informa็๕es financeiras de    บฑฑ
ฑฑ           ณclientes.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WsRestFul consultafinanceira Description "Servi็o REST para consulta de informa็๕es financeiras de clientes."

WsMethod Get Description "Retorna dados financeiros de clientes."   WsSyntax "/consultafinanceira/{codigoloja}"

End WsRestFul

WsMethod Get WsService consultafinanceira

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea			:= GetArea()
	Local cFormatAceito := "application/json"
	Local cFormato		:= Alltrim(cValToChar(Self:GetAccept()))
	Local aParametros	:= Self:aURLParms
	Local cCodLoja		:= ""
	Local cTempIni		:= cValToChar(Time())
	Local cResJson		:= ""
	Local cErro			:= ""
	Local nErro			:= 400
	Local nRecno		:= 0
	Local cCodUsuario	:= Self:GetHeader("UsrVend")
	Local cUrlServ		:= Self:GetPath()
	Private cHoraExec	:= Time()

	U_ADINF009P('ADVEN053P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Servi็o REST para consulta de informa็๕es financeiras de clientes')

	//
	Self:SetContentType(cFormatAceito)

	//
	If Len(aParametros) == 0

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","Obrigat๓rio informar c๓digo e loja do cliente.",cUrlServ,"GET")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"","Obrigat๓rio informar c๓digo e loja do cliente.",cUrlServ,"GET")

		SetRestFault(400,EncodeUtf8("Obrigat๓rio informar c๓digo e loja do cliente."))
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","",cUrlServ,"GET","")
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	u_VEN075A0(cCodUsuario,"",cCodLoja,"","",cUrlServ,"GET","")

	//Obt้m o c๓digo e loja do cliente.
	cCodLoja := Alltrim(cValToChar(aParametros[1]))

	//
	If Empty(cCodUsuario)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","C๓digo de usuแrio nใo informado (UsrVend).",cUrlServ,"GET")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"","C๓digo de usuแrio nใo informado (UsrVend).",cUrlServ,"GET")

		SetRestFault(403,EncodeUtf8("C๓digo de usuแrio nใo informado (UsrVend)."))
		RestArea(aArea)
		Return .F.

	EndIf

	//Atribui usuแrio.
	__cUserId := cCodUsuario

	//
	If cFormato <> cFormatAceito

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","Formato de dados " + cFormato + ", no Accept do cabe็alho da requisi็ใo, nใo suportado.",cUrlServ,"GET")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"","Formato de dados " + cFormato + ", no Accept do cabe็alho da requisi็ใo, nใo suportado.",cUrlServ,"GET")
		
		SetRestFault(400,EncodeUtf8("Formato de dados " + cFormato + ", no Accept do cabe็alho da requisi็ใo, nใo suportado."))
		RestArea(aArea)
		Return .F.

	EndIf

	//
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If ! SA1->(DbSeek(xFilial("SA1") + cCodLoja))
	
		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","Cliente " + cCodLoja + " nใo encontrado.",cUrlServ,"GET")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"","Cliente " + cCodLoja + " nใo encontrado.",cUrlServ,"GET")

		SetRestFault(404,EncodeUtf8("Cliente " + cCodLoja + " nใo encontrado."))
		SA1->(DbCloseArea())
		RestArea(aArea)
		Return .F.

	EndIf

	//
	If (Alltrim(cValToChar(SA1->A1_COD)) + Alltrim(cValToChar(SA1->A1_LOJA))) <> cCodLoja .Or.;
	Len(Alltrim(cValToChar(SA1->A1_COD)) + Alltrim(cValToChar(SA1->A1_LOJA))) <> Len(cCodLoja)

		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","Cliente " + cCodLoja + " nใo encontrado.",cUrlServ,"GET")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"","Cliente " + cCodLoja + " nใo encontrado.",cUrlServ,"GET")

		SetRestFault(404,EncodeUtf8("Cliente " + cCodLoja + " nใo encontrado."))
		SA1->(DbCloseArea())
		RestArea(aArea)
		Return .F.

	EndIf
	nRecno := SA1->(Recno())
	SA1->(DbCloseArea())

	//
	If ! obtDadosFin(cCodLoja,@cResJson,@cErro,@nErro,@nRecno)
	
		//
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"",cErro,cUrlServ,"GET")
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"",cErro,cUrlServ,"GET")

		SetRestFault(nErro,cErro)
		RestArea(aArea)
		Return .F.		

	Else
	
		//
		cHoraExec := ELAPTIME(cHoraExec, Time())
		//Static Call(ADVEN075P,grvLog,cCodUsuario,"",cCodLoja,"","",cUrlServ,"GET",cHoraExec)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		u_VEN075A0(cCodUsuario,"",cCodLoja,"","",cUrlServ,"GET",cHoraExec)

		Self:SetResponse(EncodeUtf8(cResJson))

	EndIf

	//
	RestArea(aArea)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobtDadosFin        บAutor  ณEverson  บ Data ณ  29/09/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObt้m dados financeiros.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function obtDadosFin(cCodLoja,cResJson,cErro,nErro)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cQuery	:= ""

	//
	cCodLoja := Alltrim(cValToChar(cCodLoja))

	//
	cQuery := scriptSql(cCodLoja)
	If Select("DADOS") > 0
		DADOS->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "DADOS"
	DbSelectArea("DADOS")

	cResJson := '{'
	cResJson += '"cliente":"'   + Substr(cCodLoja,1,6)                + '",'
	cResJson += '"loja":"'      + Substr(cCodLoja,7,2)                + '",'
	cResJson += '"rede":"'      + Alltrim(cValToChar(DADOS->CODREDE)) + '",'
	cResJson += '"lmtTotal":'   + cValToChar(DADOS->LM_T)        + ','
	cResJson += '"lmtDisp":'    + cValToChar(DADOS->LM_DISP)     + ','
	cResJson += '"titPend":'    + cValToChar(DADOS->TIT_T_AB)    + ','
	cResJson += '"vlrTitPend":' + cValToChar(DADOS->VLR_T_AB)    + ''
	cResJson += '}'

	DADOS->(DbCloseArea())

	//
	RestArea(aArea)

	Return .T.
	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณscriptSql          บAutor  ณEverson  บ Data ณ  30/09/2017   บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDesc.     ณScript Sql.                                                 บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบUso       ณChamado 037261.                                             บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	*/
	Static Functio scriptSql(cCodLoja)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cQuery	:= ""

	//
	cQuery := ""	
	cQuery += " SELECT    " 
	cQuery += " ISNULL(B_REDE.ZF_REDE,'') AS CODREDE, " 
	cQuery += " ISNULL(MAX(B_REDE.ZF_LCREDE),0) +    " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' AND ISNULL(B_REDE.ZF_REDE,'') = '' THEN ISNULL(B_CLIENTE.A1_LC,0) ELSE 0 END) AS LM_T,  " 
	cQuery += "   " 
	cQuery += " (   " 
	cQuery += " ISNULL(MAX(B_REDE.ZF_LCREDE),0) +    " 
	cQuery += " SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' AND ISNULL(B_REDE.ZF_REDE,'') = '' THEN ISNULL(B_CLIENTE.A1_LC,0) ELSE 0 END)   " 
	cQuery += " ) - SUM(CASE WHEN B_CLIENTE.A1_MSBLQL = '2' THEN ISNULL(B_TITULO.E1_SALDO,0) ELSE 0 END) AS LM_DISP,    " 
	cQuery += "  " 
	cQuery += " ISNULL(SUM(B_TABERTO.E1_SALDO),0) AS VLR_T_AB,   " 
	cQuery += " ISNULL(SUM(B_TABERTO.TOTTIT),0) AS TIT_T_AB " 
	cQuery += "  " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_VEND, A1_CGC, LEFT(A1_CGC,8) AS RAIZ_CGC, A1_LC, A1_MSBLQL, A1_DTCAD, A1_DTREAT, A1_COND, A1_REDE, A1_SATIV1   " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) SA1   " 
	cQuery += " WHERE    " 
	cQuery += " SA1.D_E_L_E_T_=''   " 
	cQuery += " AND RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) = '" + cCodLoja + "'  " 
	cQuery += " UNION " 
	cQuery += " SELECT " 
	cQuery += " A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_VEND, A1_CGC, LEFT(A1_CGC,8) AS RAIZ_CGC, A1_LC, A1_MSBLQL, A1_DTCAD, A1_DTREAT, A1_COND, A1_REDE, A1_SATIV1   " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 " 
	cQuery += " WHERE  " 
	cQuery += " LEFT(A1_CGC,8) " 
	cQuery += " IN ( " 
	cQuery += " SELECT ZF_CGCMAT FROM " + RetSqlName("SZF") + " (NOLOCK) AS SZF WHERE SZF.D_E_L_E_T_ = '' AND ZF_REDE IN " 
	cQuery += " ( " 
	cQuery += " SELECT   " 
	cQuery += " SZF.ZF_REDE " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) SA1 " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF " 
	cQuery += " ON  LEFT(A1_CGC,8)  = ZF_CGCMAT " 
	cQuery += " WHERE    " 
	cQuery += " SA1.D_E_L_E_T_=''   " 
	cQuery += " AND SZF.D_E_L_E_T_ = '' " 
	cQuery += " AND RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA)) = '" + cCodLoja + "'   " 
	cQuery += " ) " 
	cQuery += " GROUP BY       " 
	cQuery += " ZF_CGCMAT, ZF_REDE  " 
	cQuery += " )   " 
	cQuery += " ) AS B_CLIENTE   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT      " 
	cQuery += " E1_CLIENTE, E1_LOJA, SUM(E1_SALDO) AS E1_SALDO     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1     " 
	cQuery += " WHERE      " 
	cQuery += " SE1.D_E_L_E_T_ = ''     " 
	cQuery += " AND E1_SALDO > 0   " 
	cQuery += " AND E1_PORTADO <>'P13'   " 
	cQuery += " AND E1_TIPO IN ('NF ', 'NCI', 'NDC')   " 
	cQuery += " GROUP BY      " 
	cQuery += " E1_CLIENTE, E1_LOJA   " 
	cQuery += " ) AS B_TITULO   " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TITULO.E1_CLIENTE   " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TITULO.E1_LOJA   " 
	cQuery += " LEFT OUTER JOIN      " 
	cQuery += " (       " 
	cQuery += " SELECT        " 
	cQuery += " ZF_CGCMAT, ZF_REDE, SUM(ZF_LCREDE) AS ZF_LCREDE       " 
	cQuery += " FROM        " 
	cQuery += " " + RetSqlName("SZF") + " (NOLOCK) SZF       " 
	cQuery += " WHERE        " 
	cQuery += " SZF.D_E_L_E_T_=''       " 
	cQuery += " GROUP BY       " 
	cQuery += " ZF_CGCMAT, ZF_REDE       " 
	cQuery += " ) AS B_REDE     " 
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT    " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT    " 
	cQuery += " E1_CLIENTE,E1_LOJA, SUM(E1_SALDO) AS E1_SALDO,  COUNT(DISTINCT E1_NUM + E1_PREFIXO) AS TOTTIT, " 
	cQuery += " SUM(CASE WHEN CAST(E1_VENCREA AS DATE) < CAST(GETDATE() AS DATE) THEN E1_SALDO ELSE 0 END) AS ATRASO   " 
	cQuery += " FROM    " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) SE1   " 
	cQuery += " WHERE    " 
	cQuery += " (SE1.D_E_L_E_T_=' ')    " 
	cQuery += " AND E1_SALDO > 0   " 
	cQuery += " AND E1_PORTADO <> 'P13'   " 
	cQuery += " AND E1_TIPO IN ('NF')   " 
	cQuery += " GROUP BY E1_CLIENTE,E1_LOJA   " 
	cQuery += " ) AS B_TABERTO   " 
	cQuery += " ON B_CLIENTE.A1_COD = B_TABERTO.E1_CLIENTE   " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_TABERTO.E1_LOJA  " 
	cQuery += " GROUP BY " 
	cQuery += " B_REDE.ZF_REDE " 

	//
	RestArea(aArea)

Return cQuery
