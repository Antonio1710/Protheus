#include 'rwmake.ch'
#Include "Protheus.CH"
#Include "TopConn.CH"
#Include "TbiConn.CH"
#include "ap5mail.ch"
/*/{Protheus.doc} User Function ADFIN011P
	Rotina para envio de email aos clientes sobre titulos a
	vencidos  Cobranca 1.
	@type  Function
	@author Mauricio-MDS TEC
	@since 20/07/2016
	@version 01
	@history Adriana, 29/05/2019³TI-Devido a substituicao email para shared relay, substituido pelos parametros padroes e voltamos a versao de 31/07/2019
	@history Adriana, 30/05/2019³TI-Ajuste para execucao via ADFIN030P.
	@history Everson, 20/04/2020, 057434 - Removidas as colunas de portador e número bancário e adicionado dizeres.
	/*/       
User Function ADFIN011P()

	// ****************************INICIO PARA RODAR COM SCHEDULE**************************************** //	//	Desabilitado por Adriana em 30/05/2019
	//RPCSetType(3)  //Nao consome licensas
	//RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	// ****************************FINAL PARA RODAR COM SCHEDULE**************************************** //				
		
	ConOut("INICIO ADFIN011P" + '||' + DTOC(DATE()) + '||' + TIME())
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para envio de email aos clientes sobre titulos a vencidos  Cobranca 1 ')

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	//logZBN("1") //Log início. //	Desabilitado por Adriana em 30/05/2019
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule


	//CARTA DE COBRANÇA 1
	//Regras do título

	//Portador banco (E1 banco) – Portadores: 237, 341, 422, 104, 001, 033
	//Saldo do título = valor do documento
	//Título vencido + 2 dias úteis        &&Regra dois vencidos mais de 4 dias....


	_dDtlimI := (Date() - 2)
	_dDtlimI := DataValida(_dDtlimI,.F.)

	_dDtlimF := (Date() - 4)
	_dDtlimF := DataValida(_dDtlimF,.F.)

	If Select("TSE1") > 0
	DbSelectArea("TSE1")
	DbCloseArea("TSE1")
	Endif

	_cQuery := ""
	_cQuery += "SELECT E1_FILIAL, E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VENCREA,E1_VALOR,E1_BANCO,E1_PORTADO,E1_NUMBCO,E1_SALDO, E1_CLIENTE, E1_LOJA FROM "+RetSqlName("SE1")+" SE1 "
	//_cQuery += " WHERE (SE1.E1_SALDO = SE1.E1_VALOR) AND E1_TIPO NOT IN ('NCC','RA') AND E1_BANCO IN ('237','341','422','104','001','033') "    //alterado por Adriana chamado 030980 em 21/10/16
	_cQuery += " WHERE (SE1.E1_SALDO = SE1.E1_VALOR) AND E1_TIPO = 'NF' AND E1_PORTADO IN ('237','341','422','104','001','033') "
	//_cQuery += " AND E1_VENCREA < '"+DTOS(_dDtLimI)+"' AND E1_SITUACA <> 'F' "
	//_cQuery += " AND E1_VENCREA < '"+DTOS(_dDtLimI)+"' AND E1_VENCREA >= '"+DTOS(_dDtLimF)+"' AND E1_SITUACA <> 'F' AND SE1.D_E_L_E_T_ <> '*' " //alterado por Adriana chamado 030980 em 21/10/16
	_cQuery += " AND E1_VENCREA BETWEEN '"+DTOS(_dDtLimF)+"' AND '"+DTOS(_dDtLimI)+"' AND E1_SITUACA <> 'F' AND SE1.D_E_L_E_T_ = '' "
	_cQuery += " ORDER BY E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA "
					
	TCQUERY _cQuery NEW ALIAS "TSE1"

	dbSelectArea("TSE1")
	dbGoTop()
	_nTotEnv := 0
	While TSE1->(!Eof()) //.And. _nTotEnv < 6 &&numero maximo de emails a enviar
		_cClie := TSE1->E1_CLIENTE
		_cLoja := TSE1->E1_LOJA
		_aTit := {}  
		cPara   := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_EMAICO")     
		_cNome  := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_NOME") 
		_cEnvio := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_EMLVCD")
		_cVend  := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_VEND") //Everson - 20/04/2020. Chamado 057434.
		_cEmVd	:= Posicione("SA3",1,xfilial("SA3")+_cVend,"A3_EMAIL") //Everson - 20/04/2020. Chamado 057434.
		While TSE1->(!EOF()) .And. TSE1->(E1_CLIENTE+TSE1->E1_LOJA) == _cClie+_cLoja                 
		
	//	        _cEnvio := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_EMLVCD")
				dbSelectArea("TSE1")
				If _cEnvio == "N" .Or. Empty(_cEnvio) .or. Empty(cPara)
				TSE1->(dbSkip())
				Loop
				EndIf
				
				_nDias := DATE() - STOD(TSE1->E1_VENCREA)
				AADD(_aTit,{TSE1->E1_FILIAL,TSE1->E1_NUM,TSE1->E1_PARCELA,TSE1->E1_TIPO,DTOC(STOD(TSE1->E1_EMISSAO)),DTOC(STOD(TSE1->E1_VENCREA)),Transform(TSE1->E1_VALOR,"@E 999,999,999,999.99"),TSE1->E1_BANCO,TSE1->E1_NUMBCO,Transform(_nDias,"@E 99999")})
				//                  1             2           3                4                      5                          6                                     7                                  8              9                   10
				TSE1->(dbSkip())
		Enddo
		If Len(_aTit) > 0
		_nTotEnv += 1 &&contador de emails enviados..
	//	  cPara  := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_EMAICO")     
	//	  _cNome := Posicione("SA1",1,xfilial("SA1")+_cClie+_cLoja,"A1_NOME") 
		dbSelectArea("TSE1")	  
		cDe         := AllTrim(GetMv("MV_#MAILVC")) 
		cBcc        := ""
		cCC         := AllTrim(GetMv("MV_#MAILCC")) + Iif(Empty(_cEmVd),"",";"+_cEmVd) //Everson - 20/04/2020. Chamado 057434.
		cSubject    := "Titulos Contas a Receber("+_cClie+"-"+_cLoja+" "+Alltrim(_cNome)+")"
		_cMens  :=  '<html>'
		_cMens  +=  '<head>'
		_cMens  +=  '<meta http-equiv="Content-Language" content="pt-br">'
		_cMens  +=  '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		_cMens  +=  '<title>Consulta Títulos em Aberto do Cl</title>'
		_cMens  +=  '</head>'
		_cMens  +=  '<body>'
		_cMens  +=  '<p>Bom Dia</p>'
		_cMens  +=  '<p>A/C Contas a Pagar,</p>'
		_cMens  +=  '<p>Não identificamos em nossos controles o pagamento do(s) títulos(s) abaixo.'
		_cMens  +=  '</p>'
		_cMens  +=  '<p>Pedimos a gentileza de nos enviar o(s) comprovante(s) o mais rápido possível, '
		_cMens  +=  'para as devidas baixas</p>'
		_cMens  +=  '<table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse; width: 660px">'
		_cMens  +=  '	<colgroup>'
		_cMens  +=  '		<col width="64" span="8" style="width:48pt">' //Everson - 20/04/2020. Chamado 057434.
		_cMens  +=  '	</colgroup>'
		_cMens  +=  '	<tr height="21" style="height:15.75pt">'

		//Everson - 20/04/2020. Chamado 057434.
		_cMens  +=  '		<td colspan="8" height="21" style="height: 15.75pt; width: 656px; text-align: center; color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; vertical-align: bottom; white-space: nowrap; border-left: 1.0pt solid windowtext; border-right: 1.0pt solid black; border-top: 1.0pt solid windowtext; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		&nbsp;C<b>onsulta Títulos em Aberto do Cliente - '+_cClie+'-'+_cLoja+' '+Alltrim(_cNome)+'</b><p>&nbsp;</td>'
		_cMens  +=  '	</tr>'
		_cMens  +=  '	<tr height="21" style="height:15.75pt">'
		_cMens  +=  '		<td height="21" style="height: 15.75pt; color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: 1.0pt solid windowtext; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		<b>&nbsp;Empresa&nbsp;</b></td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		<b>No Título&nbsp;</b></td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		<b>&nbsp;Parcela</b></td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		<b>Tipo&nbsp;</b></td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="61">'
		_cMens  +=  '		<b>&nbsp;Dt. Emissão</b></td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="79">'
		_cMens  +=  '		<b>&nbsp;Vencimento</b></td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="71">'
		_cMens  +=  '		<b>&nbsp;Vlr. Titulo</b></td>'
		
		//Everson - 20/04/2020. Chamado 057434.
		/*  
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="53">'
		_cMens  +=  '		<b>&nbsp;Portador</b></td>' //Everson - 20/04/2020. Chamado 057434.
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="73">'
		_cMens  +=  '		<b>No. Banco&nbsp;</b></td>'
		*/
		//
		
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="51">'
		_cMens  +=  '		<b>&nbsp;Atraso (dias)</b></td>'
		_cMens  +=  '	</tr>'
								
		For _n := 1 to len(_aTit)
			_cMens += '<tr height="20" style="height:15.0pt">'
			_cMens += '		<td height="20" style="height: 15.0pt; color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: 1.0pt solid windowtext; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
			_cMens += '		ADORO SA &nbsp;</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
			_cMens += '		&nbsp;'+_aTit[_n][2]+'</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
			_cMens += '		&nbsp;'+_aTit[_n][3]+'</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
			_cMens += '		&nbsp;'+_aTit[_n][4]+'</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="61">'
			_cMens += '		&nbsp;'+_aTit[_n][5]+'</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="79">'
			_cMens += '		&nbsp;'+_aTit[_n][6]+'</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="71">'
			_cMens += '		&nbsp;'+_aTit[_n][7]+'</td>'
			
			//Everson - 20/04/2020. Chamado 057434.
			/*
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="53">'
			_cMens += '		&nbsp;'+_aTit[_n][8]+'</td>'
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="73">'
			_cMens += '		&nbsp;'+_aTit[_n][9]+'</td>'
			*/
			//
			
			_cMens += '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="51">'
			_cMens += '		&nbsp;'+_aTit[_n][10]+'</td>'
			
			_cMens += '	</tr>'	 

		next _n
		_cMens  +=  '	  <tr height="21" style="height:15.75pt">'
		_cMens  +=  '		<td height="21" style="height: 15.75pt; color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: 1.0pt solid windowtext; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="61">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="79">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="71">'
		_cMens  +=  '		&nbsp;</td>'
		
		//Everson - 20/04/2020. Chamado 057434.
		/*
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="53">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="73">'
		_cMens  +=  '		&nbsp;</td>'
		*/
		//
		
		_cMens  +=  '		<td style="color: black; font-size: 11.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Calibri, sans-serif; text-align: general; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: 1.0pt solid windowtext; border-top: medium none; border-bottom: 1.0pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="51">'
		_cMens  +=  '		&nbsp;</td>'
		_cMens  +=  '	</tr>'
		_cMens  +=  '</table>'
		
		//Everson - 20/04/2020. Chamado 057434.
		_cMens  +=  '<p>Como a instrução de protesto é automática, após 2 dias o(s) título(s) poderá(ão) ser enviado(s) ao(s) serviço(s) de proteção de crédito.'
		_cMens  +=  '</p>'
		//

		_cMens  +=  '<p>Contamos com a habitual compreensão e providências e desde já agradecemos.'
		_cMens  +=  '</p>'

		_cMens  +=  '<p>Quaisquer dúvidas, favor entrar em contato.</p>'
		_cMens  +=  '<p>Telefone: (11) 4596.8450 / (11) '      
		_cMens  +=  '4596.8376 </p>'
		_cMens  +=  '<p>Email: cobranca@adoro.com.br </p>'
		_cMens  +=  '<p><span style="background-color: #FFFF00">****ESTE É UM E-MAIL AUTOMÁTICO, '
		_cMens  +=  'FAVOR NÃO RESPONDER**** </span></p>'
		_cMens  +=  '</body>'
		_cMens  +=  '</html>'
				
		Dispara(cPara,cBcc,cCC,cSubject,_cMens,.t.,cDe)
		Endif		
		//Sleep(10000) 
			
	enddo

	//INICIO CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule
	//logZBN("2") //Log fim. //	Desabilitado por Adriana em 30/05/2019
	//FINAL CHAMADO 033882 - WILLIAM COSTA - Grava log de Execucao Schedule

	ConOut("FIM ADFIN011P" + '||' + DTOC(DATE()) + '||' + TIME())  

	// ***********INICIO Limpa o ambiente, liberando a licença e fechando as conexões********************* //	        
	//RpcClearEnv() //	Desabilitado por Adriana em 30/05/2019
	// ***********FINAL Limpa o ambiente, liberando a licença e fechando as conexões********************** //	

Return()
/*/{Protheus.doc} Dispara
	Envia e-mail.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function Dispara(cTo,cBcc,cCC,cSubject,cHtml,lMens,cFrom)
	Local lOk       	:= .T.
	Local cBody			:= cHtml
	Local cErrorMsg		:=	""
	Local aFiles 		:= {} 
	Local cServer      := Alltrim(GetMv("MV_RELSERV")) 
	Local cAccount      := AllTrim(GetMv("MV_RELACNT")) //Por Adriana em 29/05/2019 substituido MV_#MAILVC por MV_RELACNT
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))  //Por Adriana em 29/05/2019 substituido MV_#PSWCOB por MV_RELPSW
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 29/05/2019 substituido MV_#MAILVC por MV_RELFROM
	Local lSmtpAuth  	:= GetMv("MV_RELAUTH",,.F.)
	Local lAutOk     	:= .F.
	Local cAtach 		:= ""

	Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk

	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lOk .And. lAutOk
		
		Send Mail From cFrom To cTo CC cCC Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		EndIf
	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)
	EndIf

	If lOk
		Disconnect Smtp Server
	Endif

Return 
/*/{Protheus.doc} logZBN
	Gera log na tabela ZBN.
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/
Static Function logZBN(cStatus)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIN011P'))
	
		RecLock("ZBN",.F.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN011P'
			ZBN_DESCRI  := 'Email cobrança 2 dias atraso - Financeiro'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '14:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '14:00:00'
			ZBN_STATUS	:= cStatus
			
		MsUnlock() 
		
	Else
	
		RecLock("ZBN",.T.)
		
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_ROTINA	:= 'ADFIN011P'
			ZBN_DESCRI  := 'Email cobrança 2 dias atraso - Financeiro'
			ZBN_DATA    := dDataBase
			ZBN_HORA    := TIME()
			ZBN_PERIOD  := '1'
			ZBN_PERDES  := 'DIA'
			ZBN_QTDVEZ  := 1
			ZBN_HORAIN  := '14:00:00'
			ZBN_DATAPR  := dDataBase + 1
			ZBN_HORAPR  := '14:00:00'
			ZBN_STATUS	:= cStatus
	
		MsUnlock() 	
	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)

Return Nil