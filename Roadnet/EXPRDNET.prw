#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#include "Topconn.ch"

/*/{Protheus.doc} User Function ExprdNet
	(long_description)
	@type  Function
	@author user
	@since 17/02/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 9573 - 17/02/2021 - Fernando Macieira - Error LOG - Create error: C:\Roadnet\cli_rdnet.txt
/*/
User Function EXPRDNET()

	Local oChk1, lChk1, oChk2, lChk2, oChk3, lChk3, oChk4, lChk4, lChk5

	Private cCFOP  := "( "+Alltrim(GETMV("MV_#CFOPRD"))+" )"  //fernando chamado 036388 - fernando 20/07/2017

	Private cPath := "C:\Roadnet\" //@history ticket 9573 - 17/02/2021 - Fernando Macieira - Error LOG - Create error: C:\Roadnet\cli_rdnet.txt

	//@history ticket 9573 - 17/02/2021 - Fernando Macieira - Error LOG - Create error: C:\Roadnet\cli_rdnet.txt
	If !ExistDir( cPath )
		MakeDir(cPath)
	EndIf
	//

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Exportação Roadnet')

	@ 20,1 TO 349,362 DIALOG oTxtTela TITLE OemToAnsi("EXPPRDNET - Exportação de Arquivos Roadnet")
	@ 010,005 Say " Esse programa tem o objetivo de exportar arquivos magnéticos "
	@ 024,005 Say " de acordo com o Layout RoadNet e conforme os parâmetros "
	@ 038,005 Say " abaixo."
	@ 064,005 Say " Marque os arquivos que deseja exportar: "

	@ 076,08 CheckBox oChk1 Var lChk1 Prompt "Cadastro de Clientes" Size 65,9  Pixel Of oTxtTela
	@ 091,08 CheckBox oChk2 Var lChk2 Prompt "Pedidos de Vendas   " Size 65,9  Pixel Of oTxtTela
	@ 106,08 CheckBox oChk3 Var lChk3 Prompt "Cadastro de Veículos" Size 65,9  Pixel Of oTxtTela
	@ 122,08 CheckBox oChk4 Var lChk4 Prompt "Cadastro de Produtos" Size 65,9  Pixel Of oTxtTela
	@ 137,08 CheckBox oChk4 Var lChk5 Prompt "Pedidos por TES     " Size 65,9  Pixel Of oTxtTela

	@ 150,110 BMPBUTTON TYPE 01 ACTION ( TxtRdNet(lChk1,lChk2,lChk3,lChk4,lChk5), Iif(lChk1 .Or. lChk2 .Or. lChk3 .Or. lChk4 .Or. lChk5, Close(oTxtTela),) )
	@ 150,140 BMPBUTTON TYPE 02 ACTION Close(oTxtTela)

	Activate Dialog oTxtTela Centered ON INIT ()

Return                            

Static Function TxtRdNet( lChk1, lChk2, lChk3, lChk4, lChk5 )

	Private cMensag := ''

	If lChk1  
		pergunte("GERABO",.T.)
		MsgRun("Aguarde, Exportando Cadastro de Clientes ...","ROADNET",{|| CursorWait(), ExpClien(), CursorArrow()})
		cMensag := cMensag + Chr(13) + ' - Exportou Cadastro de Clientes para:   C:\Roadnet\cli_rdnet.txt' + Chr(13) + Chr(13)
	Endif
	If lChk2	
		pergunte("GERABO",.T.)
		MsgRun("Aguarde, Exportando Pedidos ...","ROADNET",{|| CursorWait(), ExpPedid(), CursorArrow()})
	Endif
	If lChk3
		MsgRun("Aguarde, Exportando Cadastro de Veículos ...","ROADNET",{|| CursorWait(), ExpVeic(), CursorArrow()})
		cMensag := cMensag + Chr(13) + ' - Exportou Cadastro de Veículos para:   C:\Roadnet\vei_rdnet.txt' + Chr(13) + Chr(13)
	Endif
	If lChk4
		MsgRun("Aguarde, Exportando Cadastro de Produtos ...","ROADNET",{|| CursorWait(), ExpProdu(), CursorArrow()})
		cMensag := cMensag + Chr(13) + ' - Exportou Cadastro de Produtos para:   C:\Roadnet\prd_rdnet.txt' + Chr(13) + Chr(13)
	Endif
	If lChk5
		pergunte("GERABP",.T.)
		MsgRun("Aguarde, Exportando Pedidos por TES ...","ROADNET",{|| CursorWait(), ExpPedi1(), CursorArrow()})
	Endif
	If !lChk1 .And. !lChk2 .And. !lChk3 .And. !lChk4 .And. !lChk5
		Alert('Selecione ao menos uma opção para continuar !')
	End
	If cMensag <> ''
		MsgInfo(cMensag)
	Endif

Return

//exportação de clientes
Static Function ExpClien()

Local cQuery  
	  _cRoteiI  := MV_PAR01
	  _cRoteiF  := MV_PAR02
	  _dDtaIni  := MV_PAR03
	  _dDtaFim  := MV_PAR04
	
	//incio exportação clientes
	u_GrLogZBE (Date(),TIME(),cUserName," INICIO EXPORT CLIENTES","LOGISTICA","EXPCLIEN","ROADNET - EXPORT-CLIENTES",ComputerName(),LogUserName()) 
	  
	Delete File C:\Roadnet\cli_rdnet.txt
	cQuery := " SELECT A1_COD, "                 + ;
			         " A1_LOJA    + SPACE(07), " + ;
			         " A1_NOME    + SPACE(20), " + ; 
			         " LEFT(RTRIM(A1_MUNE),30), " + ; 
			         " A1_ESTE    + SPACE(03), " + ; 
			         " A1_BAIRROE, " + ; 
			         " A1_CEPE    + SPACE(02), " + ; 
			         " LEFT(RTRIM(A1_ENDENT),50), " + ; 
			         " LEFT(RTRIM(A1_HRINIM),05), " + ;
			         " LEFT(RTRIM(A1_HRFINT),05), " + ;
			         " LEFT(RTRIM(A1_HRINIM),05), " + ;
			         " LEFT(RTRIM(A1_HRFINM),05), " + ;
			         " LEFT(RTRIM(A1_HRINIT),05), " + ;
			         " LEFT(RTRIM(A1_HRFINT),05), " + ;
			         " A1_VEND "                 + ; 
			    " FROM " + RetSQLName("SC5") +  " SC5, " + RetSQLName("SA1") + " SA1 " + ; 
			   " WHERE SC5.C5_FILIAL   = '" + cFilAnt        + "' " + ; 
			     " AND SC5.C5_ROTEIRO >= '" + _cRoteiI       + "' " + ; 
			     " AND SC5.C5_ROTEIRO <= '" + _cRoteiF       + "' " + ; 
			     " AND SC5.C5_DTENTR  >= '" + DTOS(_dDtaIni) + "' " + ; 
			     " AND SC5.C5_DTENTR  <= '" + DTOS(_dDtaFim) + "' " + ; 
			     " AND C5_XINT        <> '3' " + ; //Controle para verificar se o pedido já foi enviado para o Edata, sendo necessario o Estorno antes de modificar o pedido
			     " AND C5_NOTA         = ' ' " + ; 
			     " AND SC5.D_E_L_E_T_ <> '*' " + ;
			     " AND SC5.C5_CLIENT   = SA1.A1_COD " + ;
			     " AND SC5.C5_LOJACLI  = SA1.A1_LOJA " + ;
			     " AND SA1.A1_MSBLQL   = '2' " + ;
			     " AND SA1.A1_COD     <> '' " + ;
			     " AND SA1.D_E_L_E_T_ <> '*' " + ; 
			  " ORDER BY  A1_COD, A1_LOJA "
	TCQUERY cQuery new alias "FRT"
	DbSelectArea("FRT")
	Dbgotop()
    COPY To C:\Roadnet\cli_rdnet.txt SDF
    DbCloseArea("FRT") 
    _cRoteiI  := ''
	_cRoteiF  := ''
	_dDtaIni  := ''
	_dDtaFim  := ''
	
	//fim exportação de clientes
	u_GrLogZBE (Date(),TIME(),cUserName," FIM EXPORT CLIENTES","LOGISTICA","EXPCLIEN","ROADNET - EXPORT-CLIENTES",ComputerName(),LogUserName()) 
	
Return


//exportação de pedidos
Static Function ExpPedid()

Local cQuer1, _cRoteiI, _cRoteiF, _dDtaIni, _dDtaFim, _cCaminho
	_cRoteiI  := MV_PAR01
	_cRoteiF  := MV_PAR02
	_dDtaIni  := MV_PAR03
	_dDtaFim  := MV_PAR04          //_dDtaEnt  := MV_PAR05 não estava servindo para nada ...
	
	//incio exportação pedidos
	u_GrLogZBE (Date(),TIME(),cUserName," INICIO EXPORT PEDIDOS","LOGISTICA","EXPPEDID","ROADNET - EXPORT-PEDIDOS",ComputerName(),LogUserName()) 
	
	_cCaminho := "C:\Roadnet\ped" + DTOS(DDATABASE) + LEFT(TIME(),2)  + SUBSTR(TIME(),4,2) + RIGHT(TIME(),2) + ".txt"
	cQuer1 := "SELECT C5_CLIENTE, C5_LOJACLI+SPACE(7), C5_NUM+SPACE(9), SPACE(20), " + ;
			  " CONVERT(VARCHAR(10),CONVERT(SMALLDATETIME, C6_ENTREG),3), C6_PRODUTO, " + ;
			  " LEFT(REPLACE(CONVERT(VARCHAR(10), CASE " + ;
			  " WHEN (SELECT TOP 1 ZC_TARA FROM "+RetSQLName("SZC")+" WITH(NOLOCK) WHERE ZC_UNIDADE = C6_SEGUM) IS NOT NULL " + ;
			  " THEN (C6_UNSVEN * (SELECT TOP 1 ZC_TARA FROM "+RetSQLName("SZC")+" WITH(NOLOCK) WHERE ZC_UNIDADE = C6_SEGUM)) " + ;
			  " ELSE 0 END + C6_QTDVEN),'.',','),10) + SPACE(5), " + ;
			  " CONVERT(VARCHAR(8),C6_UNSVEN) " + " FROM " + RetSQLName("SC5") + ;
			  " WITH(NOLOCK) INNER JOIN " + RetSQLName("SC6") + " WITH(NOLOCK) ON C5_NUM = C6_NUM INNER JOIN " + RetSQLName("SB1") + ;
			  " WITH(NOLOCK) ON C6_PRODUTO = B1_COD WHERE  C5_FILIAL = '" + cFilAnt + "' AND B1_FILIAL = '  ' AND C6_FILIAL = '" + cFilAnt + "'" + ;
			  " AND (C6_QTDVEN - C6_QTDENT) > 0 AND C5_ROTEIRO BETWEEN '" + _cRoteiI + "' AND '" + _cRoteiF + "' " + ;
			  " AND C5_DTENTR BETWEEN '"+DTOS(_dDtaIni)+"' AND '"+DTOS(_dDtaFim)+"' " + ;
			  " AND C5_XINT <> '3' " +; //Controle para verificar se o pedido já foi enviado para o Edata, sendo necessario o Estorno antes de modificar o pedido
	          " AND C5_NOTA = ' ' AND "+RetSqlName("SC5")+ ".D_E_L_E_T_ <> '*' AND "+RetSqlName("SC6")+ ".D_E_L_E_T_ <> '*' AND "+RetSqlName("SB1")+ ".D_E_L_E_T_ <> '*' " + ;
			  " AND C6_CF NOT IN " +cCFOP+; //fernando chamado 036388 - fernando 20/07/2017
			  " ORDER BY  C5_NUM " 
			  
	TCQUERY cQuer1 new alias "FRU"
	
	DbSelectArea("FRU")
	Dbgotop()
    COPY To &_cCaminho SDF
    DbCloseArea("FRU")
	cMensag   := cMensag + Chr(13) + ' - Exportou Pedidos para:   ' +  _cCaminho + chr(13) + Chr(13)
    _cRoteiI  := ''
	_cRoteiF  := ''
	_dDtaIni  := ''
	_dDtaFim  := ''
	
	//Fim exportação pedidos
	u_GrLogZBE (Date(),TIME(),cUserName," FIM EXPORT PEDIDOS","LOGISTICA","EXPPEDID","ROADNET - EXPORT-PEDIDOS",ComputerName(),LogUserName()) 
	
	
Return

//exportção de veiculos
Static Function ExpVeic()
Local cQuer2
	
	//incio exportação veiculos
	u_GrLogZBE (Date(),TIME(),cUserName," INICIO EXPORT VEICULOS","LOGISTICA","EXPVEIC","ROADNET - EXPORT-VEICULOS",ComputerName(),LogUserName()) 

	Delete File C:\Roadnet\vei_rdnet.txt
	cQuer2 := "SELECT ZV4_PLACA+SPACE(8),ZV4_DESCRI FROM "+RetSqlName("ZV4")+ " ZV4 WHERE  ZV4_FILIAL = '  ' AND D_E_L_E_T_ <> '*'  ORDER BY  ZV4_PLACA  "
	TCQUERY cQuer2 new alias "FRV"
	DbSelectArea("FRV")
	Dbgotop()
    COPY To C:\Roadnet\vei_rdnet.txt SDF
    DbCloseArea("FRV")

    //fim exportação veiculos
	u_GrLogZBE (Date(),TIME(),cUserName," FIM EXPORT VEICULOS","LOGISTICA","EXPVEIC","ROADNET - EXPORT-VEICULOS",ComputerName(),LogUserName()) 
    

Return


//exportação de produtos
Static Function ExpProdu()

Local cQuer3
	
	//incio exportação produtos
	u_GrLogZBE (Date(),TIME(),cUserName," INICIO EXPORT PRODUTOS","LOGISTICA","EXPPRODU","ROADNET - EXPORT-PRODUTOS",ComputerName(),LogUserName()) 
	
	Delete File C:\Roadnet\prd_rdnet.txt
	cQuer3 := "SELECT B1_COD,B1_DESC FROM "+RetSqlName("SB1")+ " SB1 WHERE  B1_FILIAL = '  ' AND B1_MSBLQL = '2' AND D_E_L_E_T_ <> '*'  ORDER BY  B1_COD "
	TCQUERY cQuer3 new alias "FRX"
	DbSelectArea("FRX")
	Dbgotop()
    COPY To C:\Roadnet\prd_rdnet.txt SDF
    DbCloseArea("FRX")

    //fim exportação produtos
	u_GrLogZBE (Date(),TIME(),cUserName," FIM EXPORT PRODUTOS","LOGISTICA","EXPPRODU","ROADNET - EXPORT-PRODUTOS",ComputerName(),LogUserName()) 
    
Return
	
//exportaçao de pedidos filtrando por tes
Static Function ExpPedi1()


Local cQuer4, _cRoteiI, _cRoteiF, _dDtaIni, _dDtaFim, _cCaminh1
	_cRoteiI  := MV_PAR01
	_cRoteiF  := MV_PAR02
	_dDtaIni  := MV_PAR03 
	_dDtaFim  := MV_PAR04          //_dDtaEnt  := MV_PAR05 não estava servindo para nada ...
	_cTes_In  := MV_PAR05
	_cTes_Fn  := MV_PAR06
	_cCaminh1 := "C:\Roadnet\ped" + DTOS(DDATABASE) + LEFT(TIME(),2)  + SUBSTR(TIME(),4,2) + RIGHT(TIME(),2) + ".txt"
	
	//incio exportação  Pedidos por TES
	u_GrLogZBE (Date(),TIME(),cUserName," INICIO EXPORT PEDIDOS POR TES","LOGISTICA","EXPPEDI1","ROADNET - EXPORT-PEDIDOS/TES",ComputerName(),LogUserName()) 
	
	
	cQuer4 := "SELECT C5_CLIENTE, C5_LOJACLI+SPACE(7), C5_NUM+SPACE(9), SPACE(20), " + ;
			  " CONVERT(VARCHAR(10),CONVERT(SMALLDATETIME, C6_ENTREG),3), C6_PRODUTO, " + ;
			  " LEFT(REPLACE(CONVERT(VARCHAR(10), CASE " + ;
			  " WHEN (SELECT TOP 1 ZC_TARA FROM "+RetSQLName("SZC")+" WITH(NOLOCK) WHERE ZC_UNIDADE = C6_SEGUM) IS NOT NULL " + ;
			  " THEN (C6_UNSVEN * (SELECT TOP 1 ZC_TARA FROM "+RetSQLName("SZC")+" WITH(NOLOCK) WHERE ZC_UNIDADE = C6_SEGUM)) " + ;
			  " ELSE 0 END + C6_QTDVEN),'.',','),10) + SPACE(5), " + ;
			  " CONVERT(VARCHAR(8),C6_UNSVEN) " + " FROM " + RetSQLName("SC5") + ;
			  " WITH(NOLOCK) INNER JOIN " + RetSQLName("SC6") + " WITH(NOLOCK) ON C5_NUM = C6_NUM INNER JOIN " + RetSQLName("SB1") + ;
			  " WITH(NOLOCK) ON C6_PRODUTO = B1_COD WHERE  C5_FILIAL = '" + cFilAnt + "' AND B1_FILIAL = '  ' AND C6_FILIAL = '" + cFilAnt + "'" + ;
			  " AND (C6_QTDVEN - C6_QTDENT) > 0 AND C5_ROTEIRO BETWEEN '" + _cRoteiI + "' AND '" + _cRoteiF + "' " + ;
			  " AND C5_DTENTR BETWEEN '"+DTOS(_dDtaIni)+"' AND '"+DTOS(_dDtaFim)+"' " + ;
			  " AND C6_TES BETWEEN '" + _cTes_In + "' AND '" + _cTes_Fn + "' " + ;
			  " AND C5_NOTA = ' ' AND "+RetSqlName("SC5")+ ".D_E_L_E_T_ <> '*' AND "+RetSqlName("SC6")+ ".D_E_L_E_T_ <> '*' AND "+RetSqlName("SB1")+ ".D_E_L_E_T_ <> '*' " + ;
			  " AND C6_CF NOT IN " +cCFOP+; //fernando chamado 036388 - fernando 20/07/2017
			  " ORDER BY  C5_NUM "
	TCQUERY cQuer4 new alias "FRY"
	
	DbSelectArea("FRY")
	Dbgotop()
    COPY To &_cCaminh1 SDF
    DbCloseArea("FRY")
    
    //fim exportação  Pedidos por TES
	u_GrLogZBE (Date(),TIME(),cUserName," FIM EXPORT PEDIDOS POR TES","LOGISTICA","EXPPEDI1","ROADNET - EXPORT-PEDIDOS/TES",ComputerName(),LogUserName()) 
    
	cMensag := cMensag + Chr(13) + ' - Exportou Pedidos por TES para:   ' +  _cCaminh1 + chr(13) + Chr(13)

Return	
