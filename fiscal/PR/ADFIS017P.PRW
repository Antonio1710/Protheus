#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADFIS017P บAutor  ณEverson           บ Data ณ  28/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para confer๊ncia de recebimento de canhoto.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAdriana     ณ24/05/2019ณTI-Devido a substituicao email para shared     บฑฑ
ฑฑบ            ณ          ณrelay, substituido MV_RELACNT p/ MV_RELFROM    บฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADFIS017P() // U_ADFIS017P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	Local oConfCnt
	Local oFechar
	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oAtul
	Local oLeng
	Local oFechar
	
	Local cNFDe 	:= Space(9)
	Local cNFAt 	:= Space(9)
	
	//
	Private oCanhotos
	Private aAltCanhotos	:= {}
	Private aHCanhotos		:= {}
	Private aColsCanhotos	:= {}
	
	//
	Private aOpcCb := {"1=Todos","2=Baixado","3=Pendente"}
	Private cOpcCb := aOpcCb[1]
	Private oOpcCb
	
	//
	Private oTBx
	Private nTBx	:= 0
	Private oTPe
	Private nTPe	:= 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para confer๊ncia de recebimento de canhoto.')
	
	//
	logAcesso("PENDENCIA CANHOTO")
	
	//
	oConfCnt			:= MsDialog():Create()
	oConfCnt:cName     := "oConfCnt"
	oConfCnt:cCaption  := "Cobran็a Diแria"
	oConfCnt:nLeft     := 34
	oConfCnt:nTop      := 222
	oConfCnt:nWidth    := 1200
	oConfCnt:nHeight   := 560
	oConfCnt:lShowHint := .F.
	oConfCnt:lCentered := .T.
		
		//
		oGroup2 := TGroup():Create(oConfCnt,001,005,025,540,"",,,.T.)
			
			//
			oNFDe := TGet():New(002,010,{|u|If(PCount() == 0,cNFDe,cNFDe := u)},oConfCnt,040,010,"@ 999999999",Nil,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNFDe",,,,.T.,,,"NF de:",1) 
			
			//
			oNFAt := TGet():New(002,065,{|u|If(PCount() == 0,cNFAt,cNFAt := u)},oConfCnt,040,010,"@ 999999999",Nil,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cNFAt",,,,.T.,,,"NF At้:",1) 
			
			//
			oAtul := TButton():New(010,110,"Carregar"   ,oConfCnt,{|| MsAguarde({|| MsAguarde({|| carrCanhotos(@oCanhotos,@aHCanhotos,@cNFDe,@cNFAt,1) },"Aguarde","Carregando dados...") },"Aguarde","Atualizando registros...") } ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			//
			aSelBusca := {"2=NF","6=C๓digo Cliente"}
			cSelBusca := aSelBusca[1]
	        oSelBusca := TComboBox():New(002,167,{|u|if(PCount()>0,cSelBusca:=u,cSelBusca)},;
	        aSelBusca,050,22,oConfCnt,,,,,,.T.,,,,,,,,,'cSelBusca',"Localizar registro:",1)
			
			nBusca := 0
			cBusca := Space(10)
			oBusca   := TGet():New(008,219,{|u|If(PCount() == 0,cBusca,cBusca := u)},oConfCnt,100,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"",2) 
			oBtnBusca:= TButton():New(008,322,"Ok",oConfCnt,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
			oBtnBusca:bAction := {|| nBusca := Ascan(oCanhotos:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[Val(cValToChar(cSelBusca))])}),;
									Iif(nBusca > 0,Eval({||oCanhotos:ForceRefresh(),oCanhotos:GoTo(nBusca),oCanhotos:Refresh()}),;
									MsgAlert("Nใo foi possํvel localizar o registro","Fun็ใo confcanhoto"))}
									
			//
			aOpcCb := {"1=Todos","2=Baixado","3=Pendente"}
			cOpcCb := aOpcCb[1]
	        oOpcCb := TComboBox():New(002,435,{|u|if(PCount() > 0,cOpcCb := u,cOpcCb)},;
	        aOpcCb,100,20,oConfCnt,,{|| MsAguarde({|| MsAguarde({|| carrCanhotos(@oCanhotos,@aHCanhotos,@cNFDe,@cNFAt,Val(cValToChar(cOpcCb))) },"Aguarde","Carregando dados...") },"Aguarde","Atualizando registros...")  };
	        ,,,,.T.,,,,,,,,,'cOpcCb',"Filtro",1)
									
			
		//
		//Aadd(aHCanhotos,{" "			  ,"LEG"    , "@BMP",01,0,.T.,"","","","R","","",.F.,"V","","","",""})
		Aadd(aHCanhotos,{"Filial"     	  ,"FILIAL" ,"" ,TamSX3("C5_FILIAL")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Nota"       	  ,"NF"     ,"" ,10, 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"S้rie"      	  ,"SERIE"  ,"" ,TamSX3("C5_SERIE")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Dt. Entrega"	  ,"DTENT"  ,"" ,10, 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Placa"          ,"PLACA"  ,"" ,TamSX3("C5_PLACA")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Cod. Cliente"   ,"CODCLI" ,"" ,TamSX3("C5_CLIENTE")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Loja Cliente"   ,"LOJCLI" ,"" ,TamSX3("C5_LOJACLI")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Nm. Cliente"    ,"NMCLI"  ,"" ,TamSX3("C5_NOMECLI")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Cidade"         ,"CIDADE" ,"" ,TamSX3("C5_CIDADE")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Estado"         ,"ESTADO" ,"" ,TamSX3("C5_EST")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Roteiro"        ,"ROTEIR" ,"" ,TamSX3("C5_ROTEIRO")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Canhoto"        ,"CANHOT" ,"" ,TamSX3("C5_CANHOTO")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Mot. Canhoto"   ,"MOTCAN" ,"" ,TamSX3("C5_CANHMOT")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Baixa Usr."     ,"BXCANH" ,"" ,TamSX3("C5_CANHUSU")[1], 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Dt. Baixa"      ,"DTBAIX" ,"" ,10, 0,"","" ,"C","",""})
		Aadd(aHCanhotos,{"Hr. Baixa"      ,"HRBAIX" ,"" ,TamSX3("C5_CANHHOR")[1], 0,"","" ,"C","",""})
		//
		oCanhotos :=  MsNewGetDados():New(030,005,234,540,,"Allwaystrue()","Allwaystrue()","",aAltCanhotos,1,999,Nil,Nil,Nil,oConfCnt,aHCanhotos,@aColsCanhotos)
		
		//
		oGroup1  := TGroup():Create(oConfCnt,001,545,235,595,"",,,.T.)
			
			oCadE := TButton():New(006,550,"Cad. E-mail" ,oConfCnt,{|| cadEmail() } ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			oEvRel:= TButton():New(036,550,"Env. Rel."   ,oConfCnt,{|| intEnvRel() }   ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			//oGrRel:= TButton():New(051,550,"Ger. Rel."   ,oConfCnt,{|| gerRel() }   ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			oGrCSV:= TButton():New(051,550,"Ger. CSV"    ,oConfCnt,{|| MsAguarde({|| grLRCCSV(oCanhotos,aHCanhotos,"CANHOTOS_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando arquivo CSV...") }   ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		//
		oGroup3 := TGroup():Create(oConfCnt,239,005,265,540,"",,,.T.)
			
		//
		//oLeng	 := TButton():New(245,495,"Legenda",oConfCnt,{|| legenda() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oFechar	 := TButton():New(245,550,"Fechar",oConfCnt,{|| oConfCnt:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
		
		//
		oTBx  := TGet():New(240,010,{|u|If(PCount() == 0,nTBx,nTBx := u)},oConfCnt,040,010,"@E 999,999,999",Nil,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTBx",,,,.T.,,,"Total Baixado",1) 
			
		//
		oTPe  := TGet():New(240,065,{|u|If(PCount() == 0,nTPe,nTPe := u)},oConfCnt,040,010,"@E 999,999,999",Nil,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTPe",,,,.T.,,,"Total Pendente",1) 
		
	oConfCnt:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlegenda        บ Autor ณ Everson บ Data ณ  28/06/2017       บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLegenda.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 035993.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function legenda()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
     Local cTitulo := "Legenda"
     Local aLegenda:= {}
     
     Aadd(aLegenda, {"BR_VERDE"    ,"Baixado"  })
     Aadd(aLegenda, {"BR_VERMELHO" ,"Pendente" })
     
     BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcadEmail  บAutor  ณEverson           บ Data ณ  29/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de e-mail para recebimento de relat๓rio.           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cadEmail()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	Local oOk
	Local oFechar
	Local oTexto
	Local cEmail	:= Alltrim(cValToChar(GetMv("MV_#CHNEML")))
	
	//
	cEmail := cEmail + Space(Iif((200 - Len(cEmail)) > 0,200 - Len(cEmail),0))
	
	//
	oCadEmail			:= MsDialog():Create()
	oCadEmail:cName     := "oCadEmail"
	oCadEmail:cCaption  := "Cadastro de E-mail"
	oCadEmail:nLeft     := 34
	oCadEmail:nTop      := 222
	oCadEmail:nWidth    := 300
	oCadEmail:nHeight   := 250
	oCadEmail:lShowHint := .F.
	oCadEmail:lCentered := .T.
		
		//
		oTexto := TSay():New(010,005,{|| "Informe os e-mail's separados por ';' ." },oCadEmail,,,,,,.T.,CLR_RED,CLR_WHITE,150,10)
		
		//
		oNFDe := TGet():New(030,005,{|u|If(PCount() == 0,cEmail,cEmail := u)},oCadEmail,140,010,"@",Nil,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cEmail",,,,.T.,,,"E-mail's':",1) 
		
		//
		oOk  	 := TButton():New(095,060,"Ok"    ,oCadEmail,{|| PutMv("MV_#CHNEML",Alltrim(cValToChar(cEmail))), MsgInfo("E-mail's salvos","Fun็ใo cadEmail"), oCadEmail:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar	 := TButton():New(095,105,"Fechar",oCadEmail,{|| oCadEmail:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oCadEmail:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณintEnvRel    บAutor  ณEverson           บ Data ณ  29/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnvia relat๓rio por e-mail.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function intEnvRel()
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	Local oOk
	Local oFechar
	Local oTexto
	Local cEmail	:= Alltrim(cValToChar(GetMv("MV_#CHNEML")))
	Local aRDtCalc 	:= {"Enviar relat๓rio em Html","Enviar arquivo CSV"}
	Local nRDtCalc	:= 1
	Local oRDtCalc
	Local oTexto
	
	//
	If Empty(cEmail)
		MsgStop("Nใo hแ e-mail cadastrado.","Fun็ใo intEnvRel")
		RestArea(aArea)
		Return Nil
	
	EndIf
	
	//
	oEnvRel			:= MsDialog():Create()
	oEnvRel:cName     := "oEnvRel"
	oEnvRel:cCaption  := "Cadastro de E-mail"
	oEnvRel:nLeft     := 34
	oEnvRel:nTop      := 222
	oEnvRel:nWidth    := 300
	oEnvRel:nHeight   := 250
	oEnvRel:lShowHint := .F.
	oEnvRel:lCentered := .T.
	
		//
		oTexto := TSay():New(010,005,{|| "Selecione o arquivo que serแ enviado." },oEnvRel,,,,,,.T.,CLR_RED,CLR_WHITE,150,10)
		
		//
		oRDtCalc := TRadMenu():New (025,010,aRDtCalc,,oEnvRel,,,,,,,,100,12,,,,.T.)     
		oRDtCalc:bSetGet := {|u| Iif (PCount() == 0, nRDtCalc, nRDtCalc := u)}
		
		//
		oOk  	 := TButton():New(095,060,"Ok"    ,oEnvRel,{|| MsAguarde({|| envRel(cEmail,nRDtCalc,oCanhotos,aHCanhotos) },"Aguarde","Gerando arquivo..."), oEnvRel:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar	 := TButton():New(095,105,"Cancelar",oEnvRel,{|| oEnvRel:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oEnvRel:Activate(,,,.T.,{||.T.},,{|| })
	
	//
	RestArea(aArea)
 
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvRel    บAutor  ณEverson           บ Data ณ  29/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEnviar arquivo por e-mail.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envRel(cEmail,nOpc,oRegistros,aHReg)
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	Local nHdl	 	:= 0
	Local cAtach	:= "\rel_fin\canhotos_"  + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") 
	Local nHandle 	:= 0
	Local cHtml		:= ""
	Local cLin		:= ""
	Local i			:= 1
	Local w			:= 1
	Local cEof		:= Chr(13) + Chr(10)
	Local cHtml		:= ""
	Local nAux		:= 0
	
	Local cAssunto	:= "Relat๓rio - Canhotos Pendentes"
	Local cMensagem := "Seque anexo relat๓rio - Canhotos Pendentes."
	
	//
	If nOpc == 1
		cAtach += ".html"
		
	Else
		cAtach += ".csv"
		
	EndIf
	
	//
	If File(cAtach)
		FErase(cAtach)
	
	Endif
	
	//Cria o arquivo no disco.
	nHdl := FCreate(cAtach)
	
	//Verifica se foi possํvel criar o arquivo.
	If nHdl == -1
    	MsgAlert("O Arquivo nใo " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Fun็ใo envRel")
		Return Nil
		
	EndIf
	
	If nOpc == 1 //Gera Html.

		//
		cHtml := ""
		cHtml += " <!DOCTYPE html> "
		cHtml += " <html> "
		cHtml += " <head> "
		cHtml += " <meta charset='UTF-8'> "
		cHtml += " <style> "
		cHtml += " p{margin: 0} "
		cHtml += " </style> "
		cHtml += " </head> "
		cHtml += " <body> "
		cHtml += " <h2>Canhotos Pendentes</h2> "
		cHtml += " <p><strong>Gerado em:</strong> " + DToC(Date()) + " | " + cValToChar(Time()) + "</p> "
		cHtml += " <p><strong>Usuario:</strong> " + cUserName + "</p> "
		cHtml += " <p><strong>Qtd Baixado:</strong> "  + Transform(Val(cValToChar(nTBx)),"@E 999,999,999") + "</p> "
		cHtml += " <p><strong>Qtd Pendente:</strong> " + Transform(Val(cValToChar(nTPe)),"@E 999,999,999") + "</p> "
		cHtml += " <br/> "
		cHtml += " <table> "
		cHtml += " <tr> "
		
		//
		For i := 1 To Len(aHReg)
		
			cHtml += " <th style='background-color: #A9A9A9'>" + NoAcento(cValToChar(aHReg[i][1])) + "</th> "
		
		Next i
		
		FWrite(nHdl,cHtml)
		cHtml := ""
		
		cHtml += " </tr> "
		

		For i := 1 To Len(oRegistros:aCols)
		
			If (i%2) = 0
				cHtml += " <tr style='background-color: #DCDCDC'> "
			
			Else
				cHtml += " <tr> "
				
			EndIf
		
			For w := 1 To Len(aHReg)
				
				If Alltrim(cValToChar(aHReg[w][8])) == "N"
				
					cHtml += " <td>" + Transform(Val(cValToChar(oRegistros:aCols[i][w])),"@E 999,999,999.99") + "</td> "
					
				Else
					cHtml += " <td>" +  cValToChar(oRegistros:aCols[i][w]) + "</td> "
				
				EndIf
			
			Next w
			
			cHtml += " </tr> "
			
			FWrite(nHdl,cHtml)
			cHtml := ""
		
		Next i
		
		//
		cHtml += " </table> "
		cHtml += " </body> "
		cHtml += " </html> "
		
		FWrite(nHdl,cHtml)
		cHtml := ""
			
	Else //Gera CSV.
	
		//
		cLin := ""
		For i := 1 To Len(aHReg)
			cLin += cValToChar(aHReg[i][1]) + ";"
		
		Next i
		
		//
		cLin += cEof
		
		For i := 1 To Len(oRegistros:aCols)
		
			For w := 1 To Len(aHReg)
				
				If Alltrim(cValToChar(aHReg[w][8])) == "N"
				
					cLin += Transform(Val(cValToChar(oRegistros:aCols[i][w])),"@E 999,999,999.99") + ";"
					
				Else
					cLin += cValToChar(oRegistros:aCols[i][w]) + ";"
				
				EndIf
			
			Next w
			
			cLin += cEof
			
			FWrite(nHdl,cLin,Len(cLin))
			
			cLin := ""
		
		Next i
	
	EndIf
	
	//
	FClose(nHdl)
	
	//
	MsAguarde({|| enviarEmail(cAssunto,cMensagem,cEmail,cAtach) },"Aguarde","Enviando arquivo...")
	
	//
	FErase(cAtach)
	
	//
	MsgInfo("Arquivo enviado.","Fun็ใo envRel")
	
	//
	RestArea(aArea)
		
Return Nil

Static Function CSVEnv(nHandle)

	Local cBuffer := ""


	FWrite(nHandle,cBuffer)
	cBuffer := ""

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgerRel    บAutor  ณEverson           บ Data ณ  29/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera relat๓rio.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function gerRel()
 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcarrCanhotos บAutor  ณEverson        บ Data ณ  28/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega objeto msnewgetdados com os registros da SC5.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function carrCanhotos(oCanhotos,aHCanhotos,cNFDe,cNFAt,nOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local oVermelho := LoadBitmap(GetResources(), "BR_VERMELHO")
	Local oVerde 	:= LoadBitmap(GetResources(), "BR_VERDE")
	
	//
	oCanhotos:aCols := {}
	oCanhotos:Refresh()
	
	
	//
	If Empty(Alltrim(cValToChar(cNFAt)))
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	nTBx	:= 0
	nTPe	:= 0
	
	//
	cQuery := scriptCanhotos(cNFDe,cNFAt)
	
	//
	If nOpc == 2
		cQuery += " AND C5_CANHOTO = 'X' "
		
	ElseIf nOpc == 3
		cQuery += " AND C5_CANHOTO = '' "
		
	EndIf
	
	//
	cQuery += " ORDER BY C5_FILIAL, C5_NOTA, C5_SERIE "
	
	If Select("D_CANHOTO") > 0
		D_CANHOTO->(DbCloseArea())
		
	EndIf
	
	//
	MsAguarde({|| DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "D_CANHOTO", .F., .T.)  },"Aguarde","Obtendo dados...")
	DbSelectArea("D_CANHOTO")
	D_CANHOTO->(DbGoTop())
	If D_CANHOTO->(Eof())
	
		Aadd(oCanhotos:aCols , Array(Len(aHCanhotos)+1) )
		
		oCanhotos:aCols[Len(oCanhotos:aCols), Len(oCanhotos:aCols[1]) ] := .F.
		
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "FILIAL"	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "NF"     	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "SERIE"	    })] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "DTENT" 	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "PLACA" 	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "CODCLI"	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "LOJCLI" 	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "NMCLI"	    })] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "CIDADE" 	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "ESTADO"	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "ROTEIR" 	})] := ""		
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "CANHOT"	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "MOTCAN" 	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "BXCANH"	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "DTBAIX" 	})] := ""
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "HRBAIX" 	})] := ""
		
	EndIf
	
	//
	While ! D_CANHOTO->(Eof())
	
		Aadd(oCanhotos:aCols , Array(Len(aHCanhotos)+1) )
		
		oCanhotos:aCols[Len(oCanhotos:aCols), Len(oCanhotos:aCols[1]) ] := .F.
		
		//oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "LEG"	   })] := Iif(! Empty(Alltrim(cValToChar(D_CANHOTO->C5_CANHOTO))),oVerde,oVermelho)
		
		//
		If ! Empty(Alltrim(cValToChar(D_CANHOTO->C5_CANHOTO)))
			nTBx++
			
		Else
			nTPe++
			
		EndIf
		
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "FILIAL"	})] := Alltrim(cValToChar(D_CANHOTO->C5_FILIAL))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "NF"     	})] := Alltrim(cValToChar(D_CANHOTO->C5_NOTA))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "SERIE"	    })] := Alltrim(cValToChar(D_CANHOTO->C5_SERIE))

		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "DTENT" 	})] := Alltrim(DToC(SToD(cValToChar(D_CANHOTO->C5_DTENTR))))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "PLACA" 	})] := Alltrim(cValToChar(D_CANHOTO->C5_PLACA))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "CODCLI"	})] := Alltrim(cValToChar(D_CANHOTO->C5_CLIENTE))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "LOJCLI" 	})] := Alltrim(cValToChar(D_CANHOTO->C5_LOJACLI))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "NMCLI"	    })] := Alltrim(cValToChar(D_CANHOTO->C5_NOMECLI))
		
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "CIDADE" 	})] := Alltrim(cValToChar(D_CANHOTO->C5_CIDADE))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "ESTADO"	})] := Alltrim(cValToChar(D_CANHOTO->C5_EST))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "ROTEIR" 	})] := Alltrim(cValToChar(D_CANHOTO->C5_ROTEIRO))		
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "CANHOT"	})] := Alltrim(cValToChar(D_CANHOTO->C5_CANHOTO))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "MOTCAN" 	})] := Alltrim(cValToChar(D_CANHOTO->C5_CANHMOT))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "BXCANH"	})] := Alltrim(cValToChar(D_CANHOTO->C5_CANHUSU))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "DTBAIX" 	})] := Alltrim(DToC(SToD(cValToChar(D_CANHOTO->C5_CANHDAT))))
		oCanhotos:aCols[Len(oCanhotos:aCols),Ascan(aHCanhotos,{|x| AllTrim(x[2]) == "HRBAIX" 	})] := Alltrim(cValToChar(D_CANHOTO->C5_CANHHOR))	
		
		D_CANHOTO->(DbSkip())
		
	EndDo	
	
	//
	oCanhotos:Refresh()
	
	//
	oTBx:Refresh()
	oTPe:Refresh()
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptCanhotos บAutor  ณEverson      บ Data ณ  28/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณScript sql.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptCanhotos(cNFDe,cNFAt)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	
	//
	cNFDe := Alltrim(cValToChar(cNFDe))
	cNFAt:= Alltrim(cValToChar(cNFAt))
	
	cQuery += " SELECT  " 
	cQuery += " C5_FILIAL,  " 
	cQuery += " C5_NOTA,  " 
	cQuery += " C5_SERIE,  " 
	cQuery += " C5_DTENTR,  " 
	cQuery += " C5_PLACA,  " 
	cQuery += " C5_CLIENTE, "
	cQuery += " C5_LOJACLI, "
	cQuery += " C5_NOMECLI,  " 
	cQuery += " C5_CIDADE,  " 
	cQuery += " C5_EST,  " 
	cQuery += " C5_ROTEIRO,  " 
	cQuery += " C5_CANHOTO,  " 
	cQuery += " C5_CANHMOT,  " 
	cQuery += " C5_CANHUSU,  " 
	cQuery += " C5_CANHDAT,  " 
	cQuery += " C5_CANHHOR " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " WHERE  " 
	cQuery += " SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND RIGHT('000000000' + C5_NOTA,9) >= '" + cNFDe + "'  " 
	cQuery += " AND RIGHT('000000000' + C5_NOTA,9) <= '" + cNFAt + "' " 
	
	//
	RestArea(aArea)
	
Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrLRCCSV    บAutor  ณEverson         บ Data ณ  28/06/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera aquivo CSV para objeto msnewgetdados.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Chamado 035993.                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grLRCCSV(oRegistros,aHReg,cArq)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	
	//
	cDir := cGetFile("Arquivo CSV.", "Selecione o diret๓rio para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil
		
	EndIf
	
	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)
	
	//Verifica se foi possํvel criar o arquivo.
	If nHdl == -1
    	MsgAlert("O Arquivo nใo " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Fun็ใo grLRCCSV")
		Return Nil
		
	EndIf
	
	//
	cLin := ""
	For i := 1 To Len(aHReg)
		cLin += cValToChar(aHReg[i][1]) + ";"
	
	Next i
	
	cLin += cEof
	
	For i := 1 To Len(oRegistros:aCols)
	
		For w := 1 To Len(aHReg)
			
			If Alltrim(cValToChar(aHReg[w][8])) == "N"
			
				cLin += Transform(Val(cValToChar(oRegistros:aCols[i][w])),"@E 999,999,999.99") + ";"
				
			Else
				cLin += cValToChar(oRegistros:aCols[i][w]) + ";"
			
			EndIf
		
		Next w
		
		cLin += cEof
		
		FWrite(nHdl,cLin,Len(cLin))
		
		cLin := ""
	
	Next i
	
	//Fecha o arquivo.
	FClose(nHdl)
	
	WinExec("Explorer.exe" + Space(1) + cDir )
	
	MsgInfo("Arquivo gerado.","Fun็ใo grLRCCSV")
	
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenviarEmail       บ Autor ณ Everson บ Data ณ  26/06/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEnvia e-mail.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 035993.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function enviarEmail(cAssunto,cMensagem,cEmail,cAtach)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแvies.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea			 := GetArea()
	 Local lOk           := .T.
	 Local cBody         := cMensagem
	 Local cErrorMsg     := ""
	 Local aFiles        := {}
	 Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	 Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	 Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	 Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	 Local cTo           := cEmail
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
	       ConOut("Nใo foi possํvel enviar o e-mail ao comprador. 3 - " + cErrorMsg)
	       
	    EndIf
	    
	 Else
	    Get Mail Error cErrorMsg
	    ConOut("Nใo foi possํvel enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	    
	 EndIf
	 
	 If lOk
	    Disconnect Smtp Server
	    
	 EndIf
	 
	 RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogAcesso         บ Autor ณ Everson บ Data ณ  29/06/2017    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLog de acesso de rotina.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 035993.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logAcesso(cRotina)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local aArea		:= GetArea()
	
	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL := xFilial("SE1")
		ZBE->ZBE_DATA	:= Date()
		ZBE->ZBE_HORA	:= cValToChar(Time())
		ZBE->ZBE_USUARI	:= cUserName
		ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
		ZBE->ZBE_MODULO	:= "FISCAL"
		ZBE->ZBE_ROTINA	:= "ADFIN017P"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil