#Include "Protheus.ch"
#include "TopConn.CH"

/*/{Protheus.doc} User Function ADVEN111R
	Relatorio AgriStats.
	@type  Function
	@author Jonathan
	@since 30/07/2022
	@version version
	@history, Jonathan 30/07/2022, ticket 10921 - Relatorio Agristas
/*/
User Function ADVEN111R() 

    //Variáveis.
    Local aArea := GetArea()
	Local oReport := Nil
	Local cPerg := "ADVEN111R" 
	
	If ! Pergunte(cPerg,.T.)
        RestArea(aArea)
        Return Nil

    EndIf
	
	oReport := RptStruc(cPerg)
	oReport:PrintDialog()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} RPTStruc
    Gera estrutura do relatório.
    @type  Static Function
    @author Jonathan
    @since 30/07/2022
    @version 01
/*/
Static Function RPTStruc(cPerg)

    //Variáveis.
    Local cNome     := "ADVEN111R"
    Local cTitulo   := "Relatorio AgriStats"
	Local oReport   := Nil
	Local oSection1 := Nil
	
	oReport := TReport():New(cNome,cTitulo, cPerg,{|oReport| RPTPRINT(oReport)},cTitulo)
	oReport:SetLandscape(.T.)
	
	oSection1 := TRSection():New(oReport, "Produtos",{"SC5"}, ,.F.,.T.)
	
	TRCell():New(oSection1,"EMPRESA"          ,"D_LISTA","Empresa"          ,"@!",15)
	TRCell():New(oSection1,"DATA_PEDIDO"      ,"D_LISTA","Data Pedido"      ,"@!",15)
	TRCell():New(oSection1,"DATA_EXPEDIDO"    ,"D_LISTA","Data ExPedido"    ,"@!",15)
	TRCell():New(oSection1,"DATA_ENTREGA"     ,"D_LISTA","Data Entrega"     ,"@!",15)
	TRCell():New(oSection1,"DT_FATURA"        ,"D_LISTA","Data Fatura"      ,"@!",15)
	TRCell():New(oSection1,"N_DA_FATURA"      ,"D_LISTA","Nº da Fatura"     ,"@!",15)
	TRCell():New(oSection1,"N_PLANTA"         ,"D_LISTA","Nº Planta"        ,"@!",15)
	TRCell():New(oSection1,"COD_CLIENTE"      ,"D_LISTA","Cod.Cliente"      ,"@!",15)
	TRCell():New(oSection1,"NOME_CLIENTE"     ,"D_LISTA","Nome Cliente"     ,"@!",15)
	TRCell():New(oSection1,"CEP_CLIENTE"      ,"D_LISTA","Cep Cliente"      ,"@!",15)
	TRCell():New(oSection1,"UF"               ,"D_LISTA","UF"               ,"@!",15)
	TRCell():New(oSection1,"CANAL_DE_VENDA"   ,"D_LISTA","Canal de Venda"   ,"@!",15)
	TRCell():New(oSection1,"TIPO_NEGOCIO"     ,"D_LISTA","Tipo Negocio"     ,"@!",15)
	TRCell():New(oSection1,"COD"              ,"D_LISTA","Codigo"           ,"@!",15)
	TRCell():New(oSection1,"DESC_PRODUTO"     ,"D_LISTA","Desc. Produto"    ,"@!",15)
	TRCell():New(oSection1,"QTD_VENDIDA"      ,"D_LISTA","Qtd Vendida"      ,"@!",15)
	TRCell():New(oSection1,"CXS_VENDIDA"      ,"D_LISTA","Cxs Vendida"      ,"@!",15)
	TRCell():New(oSection1,"PRECO_VD_UNIDADE" ,"D_LISTA","Preço Vd Unid"    ,"@!",15)
	TRCell():New(oSection1,"FATURA_P/_PROD"   ,"D_LISTA","Fatura p/ Prod"   ,"@!",15)
	TRCell():New(oSection1,"CST_ENTREGA"      ,"D_LISTA","Cst Entrega"      ,"@!",15)
	TRCell():New(oSection1,"TP_ENTREGA"       ,"D_LISTA","Tp Entrega"       ,"@!",15)
	TRCell():New(oSection1,"DESP_VD_DIRETA"   ,"D_LISTA","Desp Vd Direta"   ,"@!",15)
	TRCell():New(oSection1,"COLUNA_VAZIA"     ,"D_LISTA","Coluna Vazia"     ,"@!",15)
	TRCell():New(oSection1,"COD_AJUSTE"       ,"D_LISTA","Cod Ajuste"       ,"@!",15)
	TRCell():New(oSection1,"UNID_MEDIDA_VD"   ,"D_LISTA","Unid. Medida VD"  ,"@!",15)
	TRCell():New(oSection1,"UNID_MONET"       ,"D_LISTA","Unid Monet"       ,"@!",15)
	TRCell():New(oSection1,"PAIS_DEST"        ,"D_LISTA","Pais Destino"     ,"@!",15)	


Return (oReport)
/*/{Protheus.doc} RPTPrint
    Gera relatório AgriStas.
    @type  Static Function
    @author Jonathan
    @since 30/07/2022
    @version 01
/*/
Static Function RPTPrint(oReport)

    //Variáveis.
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""

	cQuery += " SELECT " 
	cQuery += " EMPRESA = '965', "
	cQuery += " DATA_PEDIDO = '',"
	cQuery += " DATA_EXPEDIDO = '', "
	cQuery += " DATA_ENTREGA = '', "
	cQuery += " SD2.D2_EMISSAO AS DT_FATURA, "
	cQuery += " SD2.D2_DOC AS N_DA_FATURA, "
	cQuery += " N_PLANTA = '915', "
	cQuery += " REPLICATE('0', 6 - LEN(SD2.D2_CLIENTE+1234)) + RTrim(SD2.D2_CLIENTE+1234) AS 'COD_CLIENTE', "        
	cQuery += " NOME_CLIENTE = '', "
	cQuery += " CEP_CLIENTE = '', "
	cQuery += " SA1.A1_EST AS UF, "
	cQuery += " CASE WHEN SA1.A1_VEND = '000800' THEN '2' WHEN SA1.A1_SATIV2 IN ('11','31','32','33','81') THEN '5' WHEN SA1.A1_SATIV2 IN ('21','22','23','24','25','61','62','63','64','41','42','43','44','45','46','47','48','49','51','52','53','71','72','73','74') THEN '7' WHEN SA1.A1_SATIV2 IN ('91','92','93','94','95','96','99') THEN '8' END AS CANAL_DE_VENDA, "
	cQuery += " TIPO_NEGOCIO = '01', "
	cQuery += " SD2.D2_COD * 1 AS COD, "
	cQuery += " (CASE WHEN SB1.B1_DESC IN ('FGO RESF (C/ PES,PESCOCO,CABEC') THEN 'FGO RESF (C/ PES_PESCOCO_CABEC' WHEN SB1.B1_DESC IN ('FILE COXA C/ PELE - (PCT 2,5)') THEN 'FILE COXA C/ PELE - (PCT 2.5)' ELSE SB1.B1_DESC END) AS DESC_PRODUTO, "
	cQuery += " REPLACE(SD2.D2_QUANT, ',', '.') AS QTD_VENDIDA, "
	cQuery += " REPLACE(SD2.D2_QTSEGUM * 1, ',', '.')  AS CXS_VENDIDAS, "
	cQuery += " REPLACE(round((SD2.D2_PRUNIT * (1-(SA1.A1_DESC/100))),3), ',', '.') AS PRECO_VD_UNIDADE, "
	cQuery += " REPLACE(round((SD2.D2_QUANT-SD2.D2_QTDEDEV) * (SD2.D2_PRUNIT * (1-(SA1.A1_DESC/100))),2), ',', '.') AS FATURA_P_PROD, "
	cQuery += " REPLACE((SC5.C5_FRETAPV*(SD2.D2_QUANT-SD2.D2_QTDEDEV)*1), ',', '.')  AS CST_ENTREGA, " 
	cQuery += " (CASE WHEN SC5.C5_TPFRETE = 'C' THEN '1' ELSE '0' END) AS TP_ENTREGA, "
	cQuery += " DESP_VD_DIRETA='', "
	cQuery += " COLUNA_VAZIA = '', "
	cQuery += " (CASE WHEN (SD2.D2_QUANT-SD2.D2_QTDEDEV)*1 >0 THEN '0' ELSE '1' END) AS COD_AJUSTE, "
	cQuery += " SB1.B1_UM AS 'UNID_MEDIDA_VD', "
	cQuery += " UNID_MONET = 'BRA',	"
	cQuery += " CASE WHEN SA1.A1_EST  = 'EX' THEN (SELECT YA_SIGLA FROM SYA010 SYA (NOLOCK) WHERE  SYA.D_E_L_E_T_ = '' AND YA_CODGI = (SELECT EEC_PAISET FROM EEC010 EEC (NOLOCK) WHERE EEC.D_E_L_E_T_ = '' AND EEC_PREEMB = (SELECT EE7_PEDIDO FROM EE7010 EE7 (NOLOCK) WHERE EE7.D_E_L_E_T_ = '' AND EE7_PEDFAT = SD2.D2_PEDIDO))) ELSE 'BRA' END AS PAIS_DEST "
	
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
	cQuery += " INNER JOIN " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " ON C5_NUM = D2_PEDIDO AND C5_CLIENTE  = D2_CLIENTE AND C5_LOJACLI = D2_LOJA   AND C5_FILIAL = D2_FILIAL " 
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " (NOLOCK) AS SA1 " 
	cQuery += "	ON SD2.D2_CLIENTE = SA1.A1_COD  AND SD2.D2_LOJA = SA1.A1_LOJA "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) AS SB1 " 
	cQuery += "	ON SB1.B1_COD = SD2.D2_COD "

	cQuery += " WHERE " 
	cQuery += " SD2.D2_EMISSAO >='20200902' " 
	cQuery += " AND SA1.A1_COD NOT LIKE '%A%' "
	cQuery += " AND SA1.A1_XVEND2 NOT LIKE '%A%' "
	cQuery += " AND (SD2.D2_QUANT-SD2.D2_QTDEDEV) > 0 "
	cQuery += " AND SD2.D2_CF IN ('7105','7101','5101','5109','5105','5107','5116','5122','6101','6105','6107','6116','6122','5118','6118','5401','6401','6109','6501','5501') "
	cQuery += " AND SD2.D_E_L_E_T_='' "
	cQuery += " AND SA1.D_E_L_E_T_ = '' "
	cQuery += " AND SC5.D_E_L_E_T_ = '' "
	cQuery += " AND SD2.D2_FILIAL in ('02','06','07') "
	cQuery += " AND SD2.D2_GRUPO IN ('0111','0121','0122','0123','0131','0151','0152','0153','0154','0171','0175','0212','0213','0214','0215','0322','0324','0331','0332','0333','0335','0341','0345','0346','0351','0352','0353','0355','0356','0357','0358','0359','0363','0453','0459','0471','0473','0621','0622','0623','0628','0629','0632','0633','0635','0636','0722','0723','0724','0731','0732','0733','0734','0735','0738','0739','0744','0745','0746','0751','0752','0762','0764','0765','0766','0767','0771','0773') "
	cQuery += " AND (SD2.D2_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' ) "
	cQuery += " ORDER BY SD2.D2_EMISSAO "
	
	If Select("D_LISTA") > 0
		D_LISTA->(DbCloseArea())

	EndIf
			
	TcQuery cQuery New Alias "D_LISTA"
			
	DbSelectArea("D_LISTA")
	D_LISTA->(DbGoTop())

	oReport:SetMeter(Contar("D_LISTA","!Eof()"))

    D_LISTA->(DbGoTop())

    oSection1:Init()
			
	While ! D_LISTA->(Eof())
        
		If oReport:Cancel()
			Exit

		EndIf

		oReport:IncMeter()		

		oSection1:Cell("EMPRESA"):SetValue(D_LISTA->EMPRESA)	
		oSection1:Cell("DATA_PEDIDO"):SetValue(D_LISTA->DATA_PEDIDO)
		oSection1:Cell("DATA_EXPEDIDO"):SetValue(D_LISTA->DATA_EXPEDIDO)	
		oSection1:Cell("DATA_ENTREGA"):SetValue(D_LISTA->DATA_ENTREGA)
		oSection1:Cell("DT_FATURA"):SetValue(D_LISTA->DT_FATURA)	
		oSection1:Cell("N_DA_FATURA"):SetValue(D_LISTA->N_DA_FATURA)
		oSection1:Cell("N_PLANTA"):SetValue(D_LISTA->N_PLANTA)		
		oSection1:Cell("COD_CLIENTE"):SetValue(D_LISTA->COD_CLIENTE)
		oSection1:Cell("NOME_CLIENTE"):SetValue(D_LISTA->NOME_CLIENTE)
		oSection1:Cell("CEP_CLIENTE"):SetValue(D_LISTA->CEP_CLIENTE)	
		oSection1:Cell("UF"):SetValue(D_LISTA->UF)
		oSection1:Cell("CANAL_DE_VENDA"):SetValue(D_LISTA->CANAL_DE_VENDA)
		oSection1:Cell("TIPO_NEGOCIO"):SetValue(D_LISTA->TIPO_NEGOCIO)
		oSection1:Cell("COD"):SetValue(D_LISTA->COD)
		oSection1:Cell("DESC_PRODUTO"):SetValue(D_LISTA->DESC_PRODUTO)	
		oSection1:Cell("QTD_VENDIDA"):SetValue(D_LISTA->QTD_VENDIDA)	
		oSection1:Cell("CXS_VENDIDA"):SetValue(D_LISTA->CXS_VENDIDAS)	
		oSection1:Cell("PRECO_VD_UNIDADE"):SetValue(D_LISTA->PRECO_VD_UNIDADE)	
		oSection1:Cell("FATURA_P/_PROD"):SetValue(D_LISTA->FATURA_P_PRODUTO)
		oSection1:Cell("CST_ENTREGA"):SetValue(D_LISTA->CST_ENTREGA)
		oSection1:Cell("TP_ENTREGA"):SetValue(D_LISTA->TP_ENTREGA)	
		oSection1:Cell("DESP_VD_DIRETA"):SetValue(D_LISTA->DESP_VD_DIRETA)
		oSection1:Cell("COLUNA_VAZIA"):SetValue(D_LISTA->COLUNA_VAZIA)		
		oSection1:Cell("COD_AJUSTE"):SetValue(D_LISTA->COD_AJUSTE)
		oSection1:Cell("UNID_MEDIDA_VD"):SetValue(D_LISTA->UNID_MEDIDA_VD)
		oSection1:Cell("UNID_MONET"):SetValue(D_LISTA->UNID_MONET)	
		oSection1:Cell("PAIS_DEST"):SetValue(D_LISTA->PAIS_DEST)							
		
		oSection1:Printline()	

        D_LISTA->(DbSkip())	
			
	End

    oSection1:Finish()	
			
Return Nil
