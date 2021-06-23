#Include "Totvs.ch"
#Include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณU_ADVEN078P    บAutor  ณEverson      บ Data ณ  14/02/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณParโmetros SalesForce.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN078P() // U_ADVEN078P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local oConfig := Nil
	Local oGroup1 := Nil
	Local oSalvar := Nil
	Local oFechar := Nil
	
	Local aTab	  := {}
	Local oTTabs  := Nil
	
	//Login.
	Private oPAba1    := Nil
	Private oAba1Tit  := Nil
	Private cAba1Url  := GetMv("MV_#SFURL") + Space(200)
	Private oAba1Url  := Nil
	Private cAba1CliId:= GetMv("MV_#SFCID") + Space(200)
	Private oAba1CliId:= Nil
	Private cAba1CliSe:= GetMv("MV_#SFCSE") + Space(200)
	Private oAba1CliSe:= Nil
	Private cAba1Usuar:= GetMv("MV_#SFUSR") + Space(200)
	Private oAba1Usuar:= Nil
	Private cAba1Token:= Alltrim(cValToChar( GetMv("MV_#SFTKN") )) + Space(200)
	Private oAba1Token:= Nil
	Private cAba1Senha:= GetMv("MV_#SFSHN") + Space(200)
	Private oAba1Senha:= Nil
	Private oAba1Email:= Nil
	Private cAba1Email:= GetMv("MV_#SFERRO") + Space(200)
	
	//
	Private oPAba2	  := Nil
	Private oAba2Tit  := Nil
	Private oAba2ExIt := Nil
	Private cAba2ExIt := GetMv("MV_#SFEXIN")
	Private oAba2TbIP := Nil
	Private cAba2TbIP := GetMv("MV_#SFTBIP") + Space(200)
	Private oAba2DtPd := Nil
	Private cAba2DtPd := GetMv("MV_#SFDTPD") + Space(200)
	Private oAba2EvMt := Nil
	Private cAba2EvMt := GetMv("MV_#SFEVFT") 
	Private oAba2StFin := Nil
	Private cAba2StFin := GetMv("MV_#SFATUF")
	Private oAba2StLog := Nil
	Private cAba2StLog := GetMv("MV_#SFATUL")
	
	//
	Private oPAba3	   := Nil
	Private oAba3Tit   := Nil
	Private oAba3Qthr  := Nil
	Private nAba3Qthr  := cValToChar(GetMv("MV_#SFQTHR")) + Space(3)
	Private oAba3Rthr  := Nil
	Private nAba3Rthr  := cValToChar(GetMv("MV_#SFRTHR")) + Space(3)
	Private oAba3UAlt  := Nil
	Private cAba3UAlt  := GetMv("MV_#SFUSAL")
	Private oAba3UDse  := Nil
	Private oAba3UHde  := Nil
	Private oAba3UHat  := Nil
	
	Private cAba3UDse  := cValToChar(GetMv("MV_#SFDSEM")) + Space(14)
	Private cAba3UHde  := cValToChar(GetMv("MV_#SFHDE"))  + Space(5)
	Private cAba3UHat  := cValToChar(GetMv("MV_#SFHATE")) + Space(5)	
	
	Private bMudaAba := {|| oPAba1:lVisibleControl := (oTTabs:nOption == 1), oPAba2:lVisibleControl := (oTTabs:nOption == 2), oPAba3:lVisibleControl := (oTTabs:nOption == 3) }
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Parโmetros SalesForce')

	//
	oConfig			:= MsDialog():Create()
	oConfig:cName     := "oConfig"
	oConfig:cCaption  := "Parโmetros SalesForce"
	oConfig:nLeft     := 34
	oConfig:nTop      := 222
	oConfig:nWidth    := 820
	oConfig:nHeight   := 550
	oConfig:lShowHint := .F.
	oConfig:lCentered := .T.
	
		//Abas.
		aTab   := {'Login','Hab Integracao','Altera็ใo PV'}
		oTTabs := TTabs():New(001,005,aTab,Nil,oConfig,Nil,CLR_HRED,Nil,.T.,Nil,400,240,Nil)
		oTTabs:SetOption(1)
			
			//Painel com dados de login.
			oPAba1 := TPanel():New(005,005,'',oTTabs,,,,,,390,205,,.T.)
			
				oAba1Tit := TSay():New(001,010,{|| "Dados de Login do SalesForce" },oPAba1,,,,,,.T.,CLR_RED,CLR_WHITE,150,10)
				
				oAba1Url   := TGet():New(015,010,{|u|If(PCount() == 0,cAba1Url,cAba1Url     := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1Url"  ,,,,.T.,,,"URL:",1) 
				oAba1CliId := TGet():New(040,010,{|u|If(PCount() == 0,cAba1CliId,cAba1CliId := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1CliId",,,,.T.,,,"Client Id:",1) 
				oAba1CliSe := TGet():New(065,010,{|u|If(PCount() == 0,cAba1CliSe,cAba1CliSe := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1CliSe",,,,.T.,,,"Client Secret:",1)
				oAba1Usuar := TGet():New(090,010,{|u|If(PCount() == 0,cAba1Usuar,cAba1Usuar := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1Usuar",,,,.T.,,,"Usuแrio:",1)
				oAba1Token := TGet():New(115,010,{|u|If(PCount() == 0,cAba1Token,cAba1Token := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1Token",,,,.T.,,,"Token:",1)
				oAba1Senha := TGet():New(140,010,{|u|If(PCount() == 0,cAba1Senha,cAba1Senha := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1Senha",,,,.T.,,,"Senha:",1)	
				oAba1Email := TGet():New(165,010,{|u|If(PCount() == 0,cAba1Email,cAba1Email := u)},oPAba1,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba1Email",,,,.T.,,,"E-mail para envio de erro:",1)		
			
			oPAba2 := TPanel():New(005,005,'',oTTabs,,,,,,390,205,,.T.)
				
				oAba2Tit := TSay():New(001,010,{|| "Parโmetros" },oPAba2,,,,,,.T.,CLR_RED,CLR_WHITE,150,10)

				oAba2ExIt := TGet():New(015,010,{|u|If(PCount() == 0,cAba2ExIt,cAba2ExIt := u)},oPAba2,010,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba2ExIt",,,,.T.,,,"Integra็ใo habilitada:",1)
				oAba2DtPd := TGet():New(040,010,{|u|If(PCount() == 0,cAba2DtPd,cAba2DtPd := u)},oPAba2,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba2DtPd",,,,.T.,,,"Data inํcio integra็ใo:",1)
				oAba2TbIP := TGet():New(065,010,{|u|If(PCount() == 0,cAba2TbIP,cAba2TbIP := u)},oPAba2,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba2TbIP",,,,.T.,,,"Tabela IP:",1)
				oAba2EvMt := TGet():New(090,010,{|u|If(PCount() == 0,cAba2EvMt,cAba2EvMt := u)},oPAba2,010,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba2EvMt",,,,.T.,,,"Enviar faturamento com meta:",1)
				oAba2StFin := TGet():New(115,010,{|u|If(PCount() == 0,cAba2StFin,cAba2StFin := u)},oPAba2,010,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba2StFin",,,,.T.,,,"Status Financeiro online:",1)
				oAba2StLog := TGet():New(140,010,{|u|If(PCount() == 0,cAba2StLog,cAba2StLog := u)},oPAba2,010,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba2StLog",,,,.T.,,,"Status Logํstica online:",1)
			
			oPAba3 := TPanel():New(005,005,'',oTTabs,,,,,,390,205,,.T.)
				
				oAba3Tit := TSay():New(001,010,{|| "Parโmetros Rotina de altera็ใo de pedido de venda" },oPAba3,,,,,,.T.,CLR_RED,CLR_WHITE,150,10)
				
				oAba3Qthr := TGet():New(015,010,{|u|If(PCount() == 0,nAba3Qthr,nAba3Qthr := u)},oPAba3,025,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nAba3Qthr",,,,.T.,,,"Qtd. de Threads:",1)
				oAba3Rthr := TGet():New(040,010,{|u|If(PCount() == 0,nAba3Rthr,nAba3Rthr := u)},oPAba3,025,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nAba3Rthr",,,,.T.,,,"Qtd. registros por thread:",1)
				oAba3UAlt := TGet():New(065,010,{|u|If(PCount() == 0,cAba3UAlt,cAba3UAlt := u)},oPAba3,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba3UAlt",,,,.T.,,,"Usuแrios que podem alterar pedidos de venda SF no Protheus:",1)
				
				//
				oAba3UDse := TGet():New(090,010,{|u|If(PCount() == 0,cAba3UDse,cAba3UDse := u)},oPAba3,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba3UDse",,,,.T.,,,"Dias da semana de execu็ใo da rotina ADVEN090P:",1)
				oAba3UHde := TGet():New(115,010,{|u|If(PCount() == 0,cAba3UHde,cAba3UHde := u)},oPAba3,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba3UHde",,,,.T.,,,"Hora de inํcio de execu็ใo da rotina ADVEN090P:",1)
				oAba3UHat := TGet():New(140,010,{|u|If(PCount() == 0,cAba3UHat,cAba3UHat := u)},oPAba3,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba3UHat",,,,.T.,,,"Hora final de execu็ใo da rotina ADVEN090P:",1)
				
				//oAba3RCus := TGet():New(090,010,{|u|If(PCount() == 0,cAba3RCus,cAba3RCus := u)},oPAba3,350,010,"",{||},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cAba3RCus",,,,.T.,,,"Utiliza rotina customizada de libera็ใo de PV:",1)
				
		oGroup1	 := TGroup():Create(oConfig,239,005,260,405,"",,,.T.)
		
		oSalvar	 := TButton():New(245,310,"Salvar",oConfig,{|| svlDLogin(), oConfig:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oFechar	 := TButton():New(245,355,"Fechar",oConfig,{||oConfig:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oTTabs:bAction := bMudaAba
		Eval(bMudaAba)
	
	oConfig:Activate(,,,.T.,{||.T.},,{||  })

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsvlDLogin      บAutor  ณEverson      บ Data ณ  26/03/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSalva dados de login.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 037261.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function svlDLogin()

	PutMv("MV_#SFURL",cAba1Url)   //URL SalesForce - ADVEN078P.
	PutMv("MV_#SFCID",cAba1CliId) //ID usuario integrador SalesForce - ADVEN78P. 
	PutMv("MV_#SFCSE",cAba1CliSe) //Security usuario integrador SalesForce - ADVEN78P.
	PutMv("MV_#SFUSR",cAba1Usuar) //Usuario integrador SalesForce - ADVEN078P.
	PutMv("MV_#SFTKN",cAba1Token) //Token usuario integrador SalesForce - ADVEN078P.
	PutMv("MV_#SFSHN",cAba1Senha) //Senha usuario integrador SalesForce - ADEVEN078P.
	PutMv("MV_#SFERRO",cAba1Email)//Endere็o de e-mail para envio de erro de integra็ใo.
	PutMv("MV_#SFTBIP",cAba2TbIP) //Tabela IP SalesForce - ADEVEN078P.
	PutMv("MV_#SFDTPD",cAba2DtPd) //Data inํcio integra็ใo - ADEVEN078P.
	PutMv("MV_#SFEVFT",cAba2EvMt) //Envia faturamento com meta de vendedor? - ADEVEN078P.
	PutMv("MV_#SFEXIN",cAba2ExIt) //Integracao SalesForce habilitada - ADVEN078P.

	PutMv("MV_#SFATUF",cAba2StFin) //Atualiza status financeiro online.
	PutMv("MV_#SFATUL",cAba2StLog) //Atualiza status logํstica online.
	
	PutMv("MV_#SFQTHR",Val( cValToChar(nAba3Qthr) ) ) //Quantidade de threads utilizadas no processamento de atualiza็๕es de pedidos de venda.
	PutMv("MV_#SFRTHR",Val( cValToChar(nAba3Rthr) ) ) //Quantidade de registros por threads.
	
	PutMv("MV_#SFUSAL",cAba3UAlt) //Usuแrios que podem alterar no Protheus pedidos de venda gerados no SalesForce.
	
	PutMv("MV_#SFDSEM",cAba3UDse)
	PutMv("MV_#SFHDE" ,cAba3UHde)
	PutMv("MV_#SFHATE",cAba3UHat)
	
	MsgInfo("Parโmetros salvos.","Fun็ใo svlDLogin - ADVEN078P")

Return Nil