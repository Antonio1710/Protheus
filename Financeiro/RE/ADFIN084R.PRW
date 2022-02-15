#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function ADFIN084R
    Relatório Faturamento x Kg. Chamado 054162.
	@type  Function
	@author Everson
	@since 10/03/2020
	@version 01
	@history Chamado 057150 - Abel Babini - 03/04/2020 - Error.log na query. Ajuste na query para corrigir error.log 
	/*/
User Function ADFIN084R() // U_ADFIN084R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cAtach	:= "\rel_fin\relposclifat" + StrTran(FWUUID( cValToChar(Randomize(-2000,2000)) + DToS(Date()) + StrTran(cValToChar( Time()),":","") ),"-","") + ".html"
	Local nHandle 	:= 0
	Local cHtml		:= ""
	Local cCredito  := Alltrim(GetMv("MV_#LISTPD"))
	Local cAssunto	:= "Relatório - Faturamento/Kg"
	Local cMensagem := "Segue relatório Faturamento/Kg anexo."

	Private cCorLn	:= "#f2f2f2"
	
	//
	If File(cAtach)
		FErase(cAtach)
	
	Endif
	
  	//
	nHandle := FCreate(cAtach)
    If nHandle == -1
		RestArea(aArea)
        Return Nil

    EndIf
	
	//
	cHtml := html1()
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cHtml := html2()
	FWrite(nHandle, cHtml)

	//
	grDados(nHandle)
	
	cHtml := html3()
	FWrite(nHandle, cHtml)
	FClose(nHandle)

	//
	If ! Empty(cCredito)
		enviarEmail(cAssunto,cMensagem,cCredito,cAtach)
	
	EndIf

	FErase(cAtach)

	//
	RestArea(aArea)

	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),' Relatório Faturamento x Kg.')

	
Return Nil
/*/{Protheus.doc} grDados
	Gera aba Faturamento Kg/R$.
	@type  Static Function
	@author Everson
	@since 10/03/2020
	@version 01
	/*/
Static Function grDados(nHandle)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cHtml		:= ""
	Local cQuery	:= ""
	Local nAux		:= 0
	Local nVar2		:= 0
	Local nVar1		:= 0
	Local nVar0		:= 0
    
    //
	cHtml := ""
	cHtml += " <div class='conteudo'> " 
	cHtml += " <h2 class='tituloAba'>Faturamento Kg/R$ | Mês atual + 3 meses anteriores</span></h2> " 
	cHtml += " <table class='tabConteudo'> " 
	cHtml += " <tr> " 

	cHtml += " <th style='background-color: #96191d; color: white;'>Supervisor</th> " 
	cHtml += " <th style='background-color: #96191d; color: white;'>Vendedor</th> " 
	cHtml += " <th style='background-color: #96191d; color: white;'>Rede</th> " 
	cHtml += " <th style='background-color: #96191d; color: white;'>Cliente</th> " 
	cHtml += " <th style='background-color: #96191d; color: white;'>Bloqueado</th> " 

	cHtml += " <th style='background-color: #ffb236; color: white;'>" + Substr(MesExtenso( Month(MonthSub( Date(),3 )) ),1,3) + "/" + Year2Str( MonthSub( Date(),3 ) ) + " - Kg</th> " 
	//cHtml += " <th style='background-color: #ffb236; color: white;'>" + MesExtenso( Month(MonthSub( Date(),3 )) ) + "/" + Year2Str( MonthSub( Date(),3 ) ) + " - R$</th> " 
	
	cHtml += " <th style='background-color: #ffb236; color: white;'>" + Substr(MesExtenso( Month(MonthSub( Date(),2 )) ),1,3) + "/" + Year2Str( MonthSub( Date(),2 ) ) + " - Kg</th> "
	cHtml += " <th style='background-color: #96191d; color: white;'>Var %</th> " 
	
	cHtml += " <th style='background-color: #ffb236; color: white;'>" + Substr(MesExtenso( Month(MonthSub( Date(),1 )) ),1,3) + "/" + Year2Str( MonthSub( Date(),1 ) ) + " - Kg</th> " 
	cHtml += " <th style='background-color: #96191d; color: white;'>Var %</th> " 
	
	cHtml += " <th style='background-color: #ffb236; color: white;'>" + Substr(MesExtenso(Month(Date())),1,3) + "/" + cValToChar(Year(Date())) + " - Kg</th> "
	cHtml += " <th style='background-color: #96191d; color: white;'>Var %</th> "
	
	cHtml += " </tr> " 
	
	//
	FWrite(nHandle, cHtml)
	cHtml := ""
	
	//
	cQuery := scriptSql()
	
	//
	If Select("D_VLR6") > 0
		D_VLR6->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_VLR6"
	DbSelectArea("D_VLR6")
	D_VLR6->(DbGoTop())
	
	While ! D_VLR6->(Eof())

		nAux++
		If (nAux%2) = 0
			cHtml += " <tr style='background-color: " + cCorLn + "'> "
		
		Else
			cHtml += " <tr> "
			
		EndIf
		
		//
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR6->A3_SUPER))  + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR6->A1_VEND))   + "</td> " 
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR6->ZF_REDE))   + "</td> "
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR6->CLIENTE))   + "</td> "  
		cHtml += " <td>" + Alltrim(cValToChar(D_VLR6->A1_MSBLQL)) + "</td> " 

		//
		cHtml += " <td align='right'>" + Alltrim( Transform(Val(cValToChar(D_VLR6->PER3k))  ,"@E 999,999,999.999") ) + "</td> "
		//cHtml += " <td align='right'>" + Alltrim( Transform(Val(cValToChar(D_VLR6->PER3R)),"@E 999,999,999.99") )  + "</td> " 
		
		//
		cHtml += " <td align='right'>" + Alltrim( Transform(Val(cValToChar(D_VLR6->PER2k))  ,"@E 999,999,999.999") ) + "</td> "
		nVar2 := Iif( Val(cValToChar(D_VLR6->PER3k)) <= 0,0, ( Val(cValToChar(D_VLR6->PER2k)) - Val(cValToChar(D_VLR6->PER3k)))/Val(cValToChar(D_VLR6->PER3k)) ) *100
		cHtml += " <td align='right'>" + Alltrim( Transform(nVar2 ,"@E 999,999,999.99") )  + "</td> " 
		
		//
		cHtml += " <td align='right'>" + Alltrim( Transform(Val(cValToChar(D_VLR6->PER1k))  ,"@E 999,999,999.999") ) + "</td> "
		nVar1 := Iif( Val(cValToChar(D_VLR6->PER2k)) <= 0,0, ( Val(cValToChar(D_VLR6->PER1k)) - Val(cValToChar(D_VLR6->PER2k)))/Val(cValToChar(D_VLR6->PER2k)) ) *100
		cHtml += " <td align='right'>" + Alltrim( Transform(nVar1 ,"@E 999,999,999.99") )  + "</td> " 
		
		//
		cHtml += " <td align='right'>" + Alltrim( Transform(Val(cValToChar(D_VLR6->PER0k))  ,"@E 999,999,999.999") ) + "</td> "
		nVar0 := Iif( Val(cValToChar(D_VLR6->PER1k)) <= 0,0, ( Val(cValToChar(D_VLR6->PER0k)) - Val(cValToChar(D_VLR6->PER1k)))/Val(cValToChar(D_VLR6->PER1k)) ) *100
		cHtml += " <td align='right'>" + Alltrim( Transform(nVar0 ,"@E 999,999,999.99") )  + "</td> " 

		//
		cHtml += " </tr> " 	
		
		D_VLR6->(DbSkip())
		
		//
		FWrite(nHandle, cHtml)
		cHtml := ""	
		
	End
	
	D_VLR6->(DbCloseArea())
	
	//
	cHtml += " </table> " 
	cHtml += " </div> " 
	FWrite(nHandle, cHtml)
	cHtml := ""
		
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptSql
	Script sql aba Faturamento Kg/R$.
	@type  Static Function
	@author Everson
	@since 10/03/2020
	@version 01
	/*/
Static Function scriptSql()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local cQuery:= ""

	//
	cQuery := ""
	
	cQuery += " SELECT * FROM ( "

	cQuery += " SELECT " 
	cQuery += " RTRIM(LTRIM(B_CLIENTE.A1_COD)) +'-'+ RTRIM(LTRIM(B_CLIENTE.A1_LOJA)) +'-'+ RTRIM(LTRIM(B_CLIENTE.A1_NOME)) AS CLIENTE, B_REDE.ZF_REDE, B_CLIENTE.A1_VEND, B_CLIENTE.A3_SUPER, "
	cQuery += " CASE WHEN A1_MSBLQL = '1' THEN 'Sim' ELSE 'Não' END AS A1_MSBLQL, "
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.E1_SALDO  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.E1_SALDO  " 
	cQuery += " ELSE 0 END) AS PER3R, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.F2_PLIQUI  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-3,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.D1_QUANT  " 
	cQuery += " ELSE 0 END) AS PER3K, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.E1_SALDO  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.E1_SALDO  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " AS PER2R, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.F2_PLIQUI  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-2,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.D1_QUANT  " 
	cQuery += " ELSE 0 END) AS PER2K, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.E1_SALDO  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.E1_SALDO  " 
	cQuery += " ELSE 0 END) " 
	cQuery += " AS PER1R, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.F2_PLIQUI  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,-1,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.D1_QUANT  " 
	cQuery += " ELSE 0 END) AS PER1K, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,0,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,0,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.E1_SALDO  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,0,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,0,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.E1_SALDO  " 
	cQuery += " ELSE 0 END) AS PER0R, " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_FATURAMENTO.PER = CAST(YEAR( DATEADD(MONTH,0,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,0,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_FATURAMENTO.F2_PLIQUI  " 
	cQuery += " ELSE 0 END)  " 
	cQuery += " - " 
	cQuery += " SUM(CASE WHEN   " 
	cQuery += " B_DEVOLUCAO.PER = CAST(YEAR( DATEADD(MONTH,0,GETDATE())) AS VARCHAR) + RIGHT('00' + CAST(MONTH( DATEADD(MONTH,0,GETDATE())) AS VARCHAR),2)  " 
	cQuery += " THEN B_DEVOLUCAO.D1_QUANT  " 
	cQuery += " ELSE 0 END) AS PER0K " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_VEND, LEFT(A1_CGC,8) AS RAIZ_CGC,A1_MSBLQL, A3_SUPER " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("SA1") + " (NOLOCK) SA1   " 
	cQuery += " LEFT OUTER JOIN "
	cQuery += " " + RetSqlName("SA3") + " (NOLOCK) AS SA3 ON "
	cQuery += " A1_VEND = A3_COD "
	cQuery += " WHERE    " 
	cQuery += " SA1.D_E_L_E_T_=''   " 
	cQuery += " AND SA3.D_E_L_E_T_ = '' "
	cQuery += " ) AS B_CLIENTE   " 
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
	cQuery += " ON B_CLIENTE.RAIZ_CGC =  B_REDE.ZF_CGCMAT   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT " 
	cQuery += " BSE1F.E1_FILIAL,BSE1F.E1_CLIENTE,BSE1F.E1_LOJA,BSE1F.PER,SUM(BSE1F.E1_SALDO) AS E1_SALDO,SUM(BSF2.F2_PLIQUI) AS F2_PLIQUI " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT    " 
	cQuery += " E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NUM,E1_PREFIXO, " 
	cQuery += " CAST(YEAR(E1_EMISSAO) AS VARCHAR)+RIGHT('00'+CAST(MONTH(E1_EMISSAO) AS VARCHAR),2) AS PER, E1_VALOR AS E1_SALDO   " 
	cQuery += " FROM    " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1  " 
	cQuery += " WHERE    " 
	cQuery += " SE1.D_E_L_E_T_ = ''   " 
	cQuery += " AND E1_TIPO IN ('NF ','NCI','NDC')   " 
	
	//Chamado 057150 - Abel Babini - 03/04/2020 - Error.log na query. Ajuste na query para corrigir error.log 
	cQuery += " AND CAST(E1_EMISSAO AS DATE) >= CAST(CAST(DATEPART(YEAR,DATEADD(MONTH,-3,GETDATE())) AS VARCHAR) +RIGHT('00' + CAST(DATEPART(MONTH,DATEADD(MONTH,-3,GETDATE())) AS VARCHAR), 2) + '01' AS DATE)    " 
	
	cQuery += " ) AS BSE1F  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT F2_FILIAL,F2_DUPL, F2_SERIE, SUM(F2_PLIQUI) AS F2_PLIQUI  " 
	cQuery += " FROM " + RetSqlName("SF2") + " (NOLOCK) AS SF2  " 
	cQuery += " WHERE F2_DUPL <> '' AND SF2.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY F2_FILIAL,F2_DUPL, F2_SERIE " 
	cQuery += " ) BSF2 ON " 
	cQuery += " BSE1F.E1_FILIAL = BSF2.F2_FILIAL " 
	cQuery += " AND BSE1F.E1_NUM = BSF2.F2_DUPL " 
	cQuery += " AND BSE1F.E1_PREFIXO = BSF2.F2_SERIE " 
	cQuery += " GROUP BY " 
	cQuery += " BSE1F.E1_FILIAL, " 
	cQuery += " BSE1F.E1_CLIENTE, " 
	cQuery += " BSE1F.E1_LOJA, " 
	cQuery += " BSE1F.PER " 
	cQuery += " ) AS B_FATURAMENTO   " 
	cQuery += " ON B_CLIENTE.A1_COD = B_FATURAMENTO.E1_CLIENTE   " 
	cQuery += " AND B_CLIENTE.A1_LOJA = B_FATURAMENTO.E1_LOJA   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT " 
	cQuery += " BSE1D.E1_FILIAL,BSE1D.E1_CLIENTE,BSE1D.E1_LOJA,BSE1D.E1_NUM,BSE1D.PER, SUM(BSE1D.E1_SALDO) AS E1_SALDO, " 
	cQuery += " SUM(BSD1.D1_QUANT) AS D1_QUANT  " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT    " 
	cQuery += " E1_FILIAL,E1_CLIENTE,E1_LOJA,E1_NUM,E1_PREFIXO, " 
	cQuery += " CAST(YEAR(E1_EMISSAO) AS VARCHAR)+RIGHT('00'+CAST(MONTH(E1_EMISSAO) AS VARCHAR),2) AS PER,E1_VALOR AS E1_SALDO  " 
	cQuery += " FROM    " 
	cQuery += " " + RetSqlName("SE1") + " (NOLOCK) AS SE1   " 
	cQuery += " WHERE    " 
	cQuery += " SE1.D_E_L_E_T_ = ''   " 
	cQuery += " AND E1_TIPO IN ('NCC')   " 
	
	//Chamado 057150 - Abel Babini - 03/04/2020 - Error.log na query. Ajuste na query para corrigir error.log 
	cQuery += " AND CAST(E1_EMISSAO AS DATE) >= CAST(CAST(DATEPART(YEAR,DATEADD(MONTH,-3,GETDATE())) AS VARCHAR) +RIGHT('00' + CAST(DATEPART(MONTH,DATEADD(MONTH,-3,GETDATE())) AS VARCHAR), 2) + '01' AS DATE)    " 
	
	cQuery += " ) AS BSE1D " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, SUM(D1_QUANT) AS D1_QUANT  " 
	cQuery += " FROM " + RetSqlName("SD1") + " (NOLOCK) AS SD1 WHERE SD1.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA " 
	cQuery += " ) BSD1 ON " 
	cQuery += " BSE1D.E1_FILIAL = BSD1.D1_FILIAL " 
	cQuery += " AND BSE1D.E1_NUM = BSD1.D1_DOC " 
	cQuery += " AND BSE1D.E1_PREFIXO = BSD1.D1_SERIE " 
	cQuery += " AND BSE1D.E1_CLIENTE = BSD1.D1_FORNECE " 
	cQuery += " AND BSE1D.E1_LOJA = BSD1.D1_LOJA " 
	cQuery += " GROUP BY " 
	cQuery += " BSE1D.E1_FILIAL,BSE1D.E1_CLIENTE,BSE1D.E1_LOJA,BSE1D.E1_NUM,BSE1D.PER " 
	cQuery += " ) AS B_DEVOLUCAO   " 
	cQuery += " ON  " 
	cQuery += " B_FATURAMENTO.E1_FILIAL = B_DEVOLUCAO.E1_FILIAL " 
	cQuery += " AND B_FATURAMENTO.E1_CLIENTE = B_DEVOLUCAO.E1_CLIENTE   " 
	cQuery += " AND B_FATURAMENTO.E1_LOJA = B_DEVOLUCAO.E1_LOJA   " 
	cQuery += " AND B_FATURAMENTO.PER = B_DEVOLUCAO.PER " 
	cQuery += " GROUP BY " 
	cQuery += " B_CLIENTE.A1_COD, B_CLIENTE.A1_LOJA, B_REDE.ZF_REDE,B_CLIENTE.A1_NOME, B_CLIENTE.A1_VEND, B_CLIENTE.A3_SUPER, B_CLIENTE.A1_MSBLQL " 

	cQuery += " ) AS FONTE "
	cQuery += " WHERE "
	cQuery += " ( FONTE.PER3R+FONTE.PER3K + FONTE.PER2R+FONTE.PER2K + FONTE.PER1R+FONTE.PER1K + FONTE.PER0R+FONTE.PER0K ) > 0 "

	cQuery += " ORDER BY " 
	cQuery += " FONTE.A3_SUPER, FONTE.A1_VEND, FONTE.ZF_REDE, FONTE.CLIENTE " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADFIN084P - scriptSql - cQuery " + cQuery )

	//
	RestArea(aArea)

Return cQuery
/*/{Protheus.doc} html1
	Template do relatório.
	@type  Static Function
	@author Everson
	@since 10/03/2020
	@version 01
	/*/
Static Function html1()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea := GetArea()
	Local cHtml	:= ""
	
	cHtml := ""
	cHtml += " <html> " 
	cHtml += " <head> " 
	cHtml += " </head> " 
	//
	RestArea(aArea)
	
Return cHtml
/*/{Protheus.doc} html2
	Template do relatório.
	@type  Static Function
	@author Everson
	@since 10/03/2020
	@version 01
	/*/
Static Function html2()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea := GetArea()
	Local cHtml	:= ""
	
	cHtml := ""
	cHtml += " <body> " 
	cHtml += " <h2 style='margin-bottom: 5px; color:#28377c'>Relatório - Faturamento/Kg</h2> " 
	cHtml += " <hr> "
	cHtml += " <p style='margin: 0'>Gerado em: " + DToC(Date()) + "-" + cValToChar(Time()) + "</p> "
	cHtml += " <p style='margin: 0'>ADFIN084P</p> " 
	
	//
	RestArea(aArea)
	
Return cHtml
/*/{Protheus.doc} html3
	Template do relatório.
	@type  Static Function
	@author Everson
	@since 10/03/2020
	@version 01
	/*/
Static Function html3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea	:= GetArea()
	Local cHtml	:= ""

	//		
	cHtml := ""
	cHtml += " </div> " 
	cHtml += " </div> " 
	cHtml += " </body> " 
	cHtml += " </html> " 
	
	//
	RestArea(aArea)
	
Return cHtml
/*/{Protheus.doc} enviarEmail
	Envia e-mail. 
	@type  Static Function
	@author Everson
	@since 10/03/2020
	@version 01
	/*/
Static Function enviarEmail(cAssunto,cMensagem,cCredito,cAtach)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local lOk           := .T.
	Local cBody         := cMensagem
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cTo           := cCredito
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.  
	Local cSubject      := ""
	
	//Assunto do e-mail.
	 cSubject := cAssunto
	 
	 //Conecta ao servidor SMTP.
	 Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	 
	 If !lAutOk
	    If ( lSmtpAuth )
	       lAutOk := MailAuth(cAccount,cPassword)
	       
	    Else
	       lAutOk := .T.
	       
	    EndIf
	    
	 EndIf
	 
	 If lOk .And. lAutOk   
	    
	    //Envia o e-mail.     
	    Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  
	     
	    //Tratamento de erro no envio do e-mail.          
	    If !lOk
	       Get Mail Error cErrorMsg
	       ConOut("Não foi possível enviar o e-mail ao comprador. 3 - " + cErrorMsg)
	       
	    EndIf
	    
	 Else
	    Get Mail Error cErrorMsg
	    ConOut("Não foi possível enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	    
	 EndIf
	 
	 If lOk
	    Disconnect Smtp Server
	    
	 EndIf
	 
	 //
	 RestArea(aArea)
	
Return Nil
