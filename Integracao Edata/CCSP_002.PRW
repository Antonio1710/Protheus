#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "ParmType.ch"
#Include "rwmake.ch"

Static nQtdePerg := 4

/*/{Protheus.doc} User Function CCSP_002
	Rotina para fechamento de carga do edata
	@type  Function
	@author CCSKF
	@since 04/06/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 039977 - Ricardo Lima - 10/01/2018 - Ajuste para conseguir continuar o faturamento do ponto de interrupcao, em casos de queda do sistema por perda de conexao ou outro motivo
	@history chamado 044314 - Everson      - 30/05/2019 - Adicionada rotina para gera็ใo de frete.  
	@history chamado 044314 - Everson      - 03/06/2019 - Alterada a chamada do cแlculo de frete para considerar o roteiro posicionado e nใo os parโmetros da pergunta.
	@history chamado 044314 - Everson      - 05/06/2019 - Alterado log
	@history chamado 044314 - Everson      - 12/06/2019 - Alterada a data passada para gera็ใo de frete.
	@history chamado 044314 - Everson      - 01/07/2019 - Adicionada chamada para gera็ใo de CT-e.
	@history chamado 044314 - Everson      - 06/08/2019 - Adicionado valida็ใo de empresa para gera็ใo de CT-e. 
	@history chamado 056247 - FWNM         - 08/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history chamado 056247 - FWNM         - 29/05/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
	@history Chamado 059415 - FWNM         - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consist๊ncias por indefini็๕es de implanta็ใo.
	@history chamado 8465   - LeonardoMont - 02/06/2021 - Corre็ใo no fonte para nใo gravas as informa็๕es do lacre SIF no retorno da integra็ใo com eData.
	@history chamado     ti - Fernando Maci- 24/08/2021 - Consist๊ncias Integra็ใo EDATA devido RECNO com CAST na view [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01]
/*/
User Function CCSP_002()

	LOCAL oSay,oSay2,oSay3
	LOCAL oBtn1,oBtn2,oBtn3
	LOCAL oDlg            
	PRIVATE cPerg:="CCSP02" 
	Private cRotDesc := "Integra็ใo Protheus x Edata"

	Private cCadastro:="Fechamento Carga Edata"

	Private cFilGFrt := Alltrim(SuperGetMv( "MV_#M46F5" , .F. , '' ,  ))
	Private cEmpFrt	  := Alltrim(SuperGetMv( "MV_#M46F6" , .F. , '' ,  )) //Everson-CH:044314-06/08/19.    
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para fechamento de carga do edata')

	AjustaSX1(cPerg)         

	Pergunte(cPerg,.T.)

	ProcLogIni( {},"CCSP02")

	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi(cCadastro) PIXEL
	@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
	@ 16, 15 SAY OemToAnsi("Este programa efetua o retorno para o protheus do fechamento de carga do EDATA") SIZE 268, 8 OF oDlg PIXEL			   									

	DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView() ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| CCSP_002S()},OemToAnsi("Fechamento Carga Edata"),OemToAnsi("Selecionando Registros..."),.F.),oDlg:End()),) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED  

Return       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCCSP_002S บAutor  ณHermes Ferreira     บ Data ณ  18/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a pesquisa de dados  para exibir a tela de monitorar    บฑฑ
ฑฑบ          ณa o retorno do edata                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CCSP_002S()    

	Local cSql := ""
	Local clAlias	:= GetNextAlias()

	Pergunte(cPerg,.F.)

	cSql := FQRY002()

	TcQuery cSql New Alias &(clAlias)

	TCSetField((clAlias),"C5_DTENTR"	,"D",TamSx3("C5_DTENTR")[1]		,TamSx3("C5_DTENTR")[2]	)

	(clAlias)->(dbGoTop())	
	If (clAlias)->(!Eof()) .And. (clAlias)->(!Bof())
		E001Proces((clAlias))
	Else
		Aviso("CCSP_002","Nใo foram localizados registros, com os parโmetros informados.",{"OK"},3)
	EndIf		

	IIF ( Select(clAlias) > 0, (clAlias)->(dbCloseArea()),NIL)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณE001ProcesบAutor  ณHermes Ferreira     บ Data ณ  18/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a tela de monitorar retorno edata                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function E001Proces(clAlias)

	Local alCoord		:=	MsAdvSize(.F.,.F.,0)
	Local nlResoluc		:= oMainWnd:nClientWidth
	Local alPrcPrinc	:= {0,0,0}
	Local alPrcLeft		:= {0}
	Local alPrcCenter	:= {0}
	Local alPrcright	:= {0}
	Local oButton1		:= NIL
	Local oButton2		:= NIL
	Local oButton3		:= NIL
	Local oButton4		:= NIL
	Local oButton5		:= NIL
	Local oButton6		:= NIL
	Local oButton7		:= NIL
	Local oButton8		:= NIL //Eversonณ01/07/19ณ044314.
	Local lGrCte		:= GetMv("MV_#HABCTE",,.F.)//Eversonณ01/07/19ณ044314.
	Local oButtonP		:= NIL
	Local oGetEnD		:= Nil
	Local oGetEnA		:= Nil
	Local oComboTp		:= Nil
	Local oGetCliD		:= Nil
	Local oGetLojD		:= Nil
	Local oGetCliA		:= Nil
	Local oGetLojA		:= Nil
	Local oComboSt 		:= Nil
	Local alComboTP		:= {"1=Venda","2=Beneficiamento","3=OP"}
	Local alComboST		:= {"1=Pendente","2=Liberado","3=Todos"}
	Local nTimeATU		:= SuperGetMV("MV_XTIMEAT",,5000)
	Local oTemporizador	:= Nil
	Private apHeader	:= {}
	Private apCols		:= {}
	Private opOdlg		:= Nil
	Private opLayer		:= FWLayer():New()
	Private opTfont		:= Nil
	Private opOdlgPar	:= Nil
	Private opOdlgLote	:= Nil
	Private opOdlgFun	:= Nil
	Private opGridSC5	:= Nil

	FAHECOLS(clAlias)

	Private nPosStat	:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_XFLAGE"		})
	Private nPosEntr	:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_DTENTR"		})
	Private nPosRot		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_ROTEIRO"	})
	Private nPosPla		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_PLACA"		})	
	Private nPosPed		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_NUM"		})
	Private nPosCli		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_CLIENTE"	})
	Private nPosNom		:= AScan(apHeader,{|x| AllTrim(x[2]) == "A1_NREDUZ"		})
	Private nPosSeq		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_X_SQED"		})
	Private nPosTP		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_XTIPO"		})
	Private nPosFat		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_XFATANT"	})	
	// RICARDO LIMA - 10/01/18
	Private nPosNF		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_NOTA"   	})
	Private nPosSNF		:= AScan(apHeader,{|x| AllTrim(x[2]) == "C5_SERIE"   	})
	Private nPosPVRA    := AScan(apHeader,{|x| AllTrim(x[2]) == "C5_XWSPAGO"   	}) // Chamado n. 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FWNM - 12/08/2020

	Pergunte(cPerg,.F.)

	opOdlg := TDialog():New(alCoord[1],alCoord[2],alCoord[6],alCoord[5],"Monitoramento Roteiros Liberados",,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	opLayer:Init(opOdlg,.F.)

	If nlResoluc <= 800

		alPrcPrinc 		:= {012,081,007}
		alPrcLeft		:= {100}
		alPrcCenter		:= {100}
		alPrcright		:= {100}

	ElseIf nlResoluc >= 1024 .And. nlResoluc < 1280

		alPrcPrinc 		:= {018,69,013} //{018,69,013}
		alPrcLeft		:= {100}
		alPrcCenter		:= {100}
		alPrcright		:= {100}

	ElseIf nlResoluc >= 1280 .And. nlResoluc < 1300

		alPrcPrinc 		:= {015,075,010}
		alPrcLeft		:= {100}
		alPrcCenter		:= {100}
		alPrcright		:= {100}

	ElseIf 	nlResoluc >= 1300

		alPrcPrinc 		:= {015,075,010}
		alPrcLeft		:= {100}
		alPrcCenter		:= {100}
		alPrcright		:= {100}

	EndIf

	opTfont := TFont():New("COURIER NEW",,-15,.T.)

	opLayer:AddCollumn("ESQUERDO"	,alPrcPrinc[1],.F.)
	opLayer:AddCollumn("CENTRO"		,alPrcPrinc[2],.F.)
	opLayer:AddCollumn("DIREITO"	,alPrcPrinc[3],.F.)

	opLayer:AddWindow("ESQUERDO","PARAMETRO"			,"Parametros Selec็ใo"		,alPrcLeft[1]	,.T.,.T.,{||},,{||})
	opLayer:AddWindow("CENTRO"	,"ROTEIROS"	   			,"Roteiros"		   			,alPrcCenter[1]	,.T.,.T.,{||},,{||})
	opLayer:AddWindow("DIREITO"	,"FUNCOES"	   			,"Fun็oes"		   			,alPrcright[1]	,.T.,.T.,{||},,{||})

	opOdlgPar	:= opLayer:GetWinPanel("ESQUERDO"	,"PARAMETRO")
	opOdlgLote	:= opLayer:GetWinPanel("CENTRO"		,"ROTEIROS"	)
	opOdlgFun	:= opLayer:GetWinPanel("DIREITO"	,"FUNCOES"	)

	// Esquerda
	oSayROTD := TSay():New(alCoord[1]+5,alCoord[2]+5		,{|| "Roteiro de: "}  	  				,opOdlgPar,,,,,,.T.)
	oGetROTD := TGet():New(alCoord[1]+15,alCoord[2]+5		,{|u| Iif(PCount()>0,MV_PAR01:=u,MV_PAR01)}	,opOdlgPar, 0050, 0010,"@!",,,,,,,.T.,,,, .F., .F.,, .F., .F. ,,("MV_PAR01"))

	oSayROTA := TSay():New(alCoord[1]+32,alCoord[2]+5		,{|| "Roteiro at้: "} 	  				,opOdlgPar,,,,,,.T.)
	oGetROTA := TGet():New(alCoord[1]+42,alCoord[2]+5		,{|u| Iif(PCount()>0,MV_PAR02:=u,MV_PAR02)}	,opOdlgPar, 0050, 0010,"@!",,,,,,,.T.,,,, .F., .F.,, .F., .F. ,,("MV_PAR02"))

	oSayDat := TSay():New(alCoord[1]+59,alCoord[2]+5		,{|| "Data de Entrega : "} 	  				,opOdlgPar,,,,,,.T.)
	oGetDat := TGet():New(alCoord[1]+69,alCoord[2]+5		,{|u| Iif(PCount()>0,MV_PAR03:=u,MV_PAR03)}	,opOdlgPar, 0050, 0010,AllTrim(GetSX3Cache("C5_DTENTR", "X3_PICTURE")),{||},/*CLR_WHITE*/,,,,,.T.,,,{|| })

	oSaySt 	 := TSay():New(alCoord[1]+86,alCoord[2]+5		,{|| "Status: "} 			  					,opOdlgPar,,,,,,.T.)
	oComboSt := tComboBox():New(alCoord[1]+96,alCoord[2]+5,{|u|if(PCount()>0,MV_PAR04:=u,MV_PAR04)}		,alComboST,0050,0010,opOdlgPar,,{||},,,,.T.,,,,,,,,,"MV_PAR04")

	oButtonP := tButton():New(alCoord[1]+225 ,alCoord[2]+5	,  "Pesquisar"  ,opOdlgPar,{|| FPESQ(clAlias) },80,10,,,,.T.)

	// Centro
	opGridSC5:= MsNewGetDados():New(000,000,000,000,GD_UPDATE,"AllWaysTrue()","AllWaysTrue()","",{},0,999,"AllWaysTrue()",,,opOdlgLote	,apHeader	,apCols)
	opGridSC5:lInsert 				:= .F.
	opGridSC5:oBrowse:Align 		:= CONTROL_ALIGN_ALLCLIENT

	// Direita
	oButton1 := tButton():New(alCoord[1]+005 ,alCoord[2]+5	,  "Processa" 	 		,opOdlgFun,{|| CCS_002P(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04),FPESQ(clAlias)		},45,10,,,,.T.)
	oButton2 := tButton():New(alCoord[1]+020 ,alCoord[2]+5	,  "Legenda"  			,opOdlgFun,{|| CCS_LEG()						},45,10,,,,.T.)
	oButton8 := tButton():New(alCoord[1]+035 ,alCoord[2]+5	,  "CT-e"  				,opOdlgFun,{|| geraCTE()						},45,10,,,,.T.)//Eversonณ01/07/19ณ044314.
	
	//Eversonณ01/07/19ณ044314.
	If ! lGrCte
		oButton8:Disable()
		
	EndIf
	//
	
	oButton3 := tButton():New(alCoord[1]+050 ,alCoord[2]+5	,  "Sair"			  	,opOdlgFun,{|| opOdlg:End()						},45,10,,,,.T.)		
	oTemporizador := TTimer():New( nTimeATU,{|| FPESQ(clAlias) },opOdlg)
	oTemporizador:Activate()
	Activate Msdialog opOdlg Centered

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgeraCTE   บAutor  ณEverson		     บ Data ณ  01/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera CT-e.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function geraCTE()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cData	 	:= AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr]))
	Local cRoteiro	:= AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot])
	
	//
	If ! MsgYesNo("Deseja iniciar a rotina de CT-e para o roteiro " + cRoteiro + " " + DToC(SToD(cData)) + "?","Fun็ใo geraCTE(CCSP_002)")
		RestArea(aArea)
		Return Nil
	
	EndIf
	
	Startjob("U_ADLOG058P()",getenvserver(),.F.,cRoteiro,cData)
	
	MsgInfo("Processo iniciado.","Fun็ใo geraCTE(CCSP_002)")
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณCCS_001P   บAutor  ณPablo Gollan Carreras บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de processamento de registros selecionados                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPACE                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CCS_002P(Par1,Par2,Par3,Par4)

	// Chamado n. 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FWNM - 12/08/2020
	Local lPVRAOK  := .t.
	Local _cRot    := ""
	Local cNumPVRA := ""
	//

	Pergunte(cPerg,.F.)

	MV_PAR01:=Par1
	MV_PAR02:=Par2
	MV_PAR03:=Par3
	If  ValType(Par4) == "N"
		MV_PAR04:=Alltrim(Str(Par4))
	Else
		MV_PAR04:=Par4
	EndIf

	if ddatabase <> date() //incluido por Adriana para validar data - chamado 036749
		Aviso("CCSP_002","Data base incorreta !!!",{"OK"},3)
		Return
	endif

	if time() >= "23:55:00" //incluido por Adriana para validar data - chamado 036749
		Aviso("CCSP_002","Aguarde at้ 00:01hs, e altere Data base !!!",{"OK"},3)
		Return
	endif

	// RICRADO LIMA - 10/01/18
	If !Empty( opGridSC5:aCols[opGridSC5:NAT,nPosNF] )
		Aviso("CCSP_002","Pedido jแ Faturado!"+chr(13)+chr(10)+"Seleciona um pedido nใo Faturado.",{"OK"},3)
		Return
	ENDIF

	//tratamento de apenas liberados
	If opGridSC5:aCols[opGridSC5:NAT,nPosStat] <> "BR_VERDE"
		Aviso("CCSP_002","Essa op็ใo nใo ้ permitida para itens que nใo estejam em liberados!.",{"OK"},3)
		Return
	EndIf

	// Chamado n. 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FWNM - 12/08/2020
	// Se tiver um ๚nico PV de adiantamento nใo recebido (C5_XWSPAGO=S), roteiro inteiro nใo serแ faturado!
	lPVRAOK := .t.
	_cRot := opGridSC5:aCols[opGridSC5:NAT,nPosRot]
	cNumPVRA := ""

	For i:=1 to Len(opGridSC5:aCols)
		
		If _cRot == opGridSC5:aCols[i,nPosRot]

			cNumPVRA := opGridSC5:aCols[i,nPosPed]
			
			FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
			If FIE->( msSeek(FWxFilial("FIE")+"R"+cNumPVRA) )

				SE1->( dbSetOrder(2) ) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
				If SE1->( msSeek(FIE->(FIE_FILIAL+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )

					SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
					If SC5->( msSeek(FWxFilial("SC5")+cNumPVRA) )

						If Empty(SC5->C5_XWSPAGO)
						//If Empty(opGridSC5:aCols[i,nPosPVRA])
							lPVRAOK := .f.
							Exit
						EndIf

						SC9->( dbGoTop() )
						SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
						If SC9->( msSeek(SC5->(C5_FILIAL+C5_NUM)) )
							
							Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM

								If !Empty(SC9->C9_BLCRED) //.or. !Empty(SC9->C9_BLEST)
									lPVRAOK := .f.
									Exit
								EndIf

								SC9->( dbSkip() )

							EndDo

							If !lPVRAOK
								Exit
							EndIf

						EndIf
					
					EndIf
				
				EndIf
				
			EndIf

		EndIf
		
	Next i

	If !lPVRAOK
		Alert("Roteiro " + _cRot + " possui PV de adiantamento (n. " + cNumPVRA + ") que nใo foi recebido pela empresa! Faturamento nใo permitido...")
		Return
	EndIf
	//

	//define fun็ใo normal ou diversa -  
	//If opGridSC5:aCols[opGridSC5:NAT,nPosTp] == "1"
	If opGridSC5:aCols[opGridSC5:NAT,nPosTp] $ "1/3" // Chamado: 039001 - Fernando Sigoli 28/12/2017 - Adicionado tipo 3 para tratamento de cargas de transferencia.
		If opGridSC5:aCols[opGridSC5:NAT,nPosFat]=="1" //faturamento antecipado
			CCS_002PF()
		Else	
			CCS_002PN()
		EndIf
	ElseIf opGridSC5:aCols[opGridSC5:NAT,nPosTp] == "2"
		//Aviso("CCSP_002","Diversos em homologa็ใo!",{"OK"},3)
		//Return
		CCS_002PD()
	Else
		Aviso("CCSP_002","Pedido nใo classificado em Normal/Diverso, verifique campo C5_XTIPO!",{"OK"},3)
		Return
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณCCS_001PN  บAutor  ณPablo Gollan Carreras บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de processamento de registros selecionados - Normal        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CCS_002PN()

	Local ni				:= 0
	Local ni2				:= 0
	Local cChave			:= ""
	Local cMens				:= ""
	Local cMensok			:= ""
	Local cRest01			:= ""
	Local cQuery 			:= ""
	Local cAliasSC9	    	:= CriaTrab(NIL,.F.)	
	Local lContinua			:= .T.
	Local aPedidos			:= {}
	Local nReg				:= 0
	Local lPedAb            := .T.
	Local lContfat          := .F.
	
	Local lRetFat			:= .F. //Everson - 30/05/2019. Chamado 044314.
	Local dDtPed			:= Nil //Everson - 12/06/19. Chamado 044314.

	Private __Rot 			:= ""
	Private __dDtEnt

	cData	 := ""
	cRoteiro := ""
	cPlaca	 := ""

	For ni := opGridSC5:NAT to Len(opGridSC5:aCols)
		IF opGridSC5:aCols[ni][11] = ' ' // ricardo lima - 21/09/18
			If cData+cRoteiro+cPlaca <> AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr])) + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot]) + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosPla])
				//Salva Roteiro em processamento
				cData	 := AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr]))
				cRoteiro := AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot])
				cPlaca	 := AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosPla])
				
				dDtPed 	 := SToD(cData) //Everson - 12/06/19. Chamado 044314.

				cQuery := "SELECT COUNT(*) AS REC FROM [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01] WHERE ID_CARGEXPE = " + Str(Val(AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosSeq]))) + " "		
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.F.)

				nReg:=(cAliasSC9)->(REC)
				DbSelectArea(cAliasSC9)
				dbCloseArea()

				If nReg==0
					Aviso("CCSP_002","Problema - Carga nใo liberada no eData - Verificar!!!",{"OK"},3)
					Return
				EndIf

				cQuery := "SELECT * FROM [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01] WHERE ID_CARGEXPE = " + Str(Val(AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosSeq]))) + " "
				cQuery += "ORDER BY FILIAL+ID_PEDIVEND"	

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC9,.T.,.F.)			
				DbSelectArea(cAliasSC9)
				Dbgotop()				
				//ProcRegua(nReg)			
				// Ricardo Lima - 10/01/18
				//BeginTran()
				BEGIN TRANSACTION				
					cChave:= ""				
					While (cAliasSC9)->(!EOF())

						// desconsidera liberacoes jแ feitas quando nใo houve carregamento
						If (cAliasSC9)->C9_RECNO == 0
							(cAliasSC9)->(DbSkip())
							Loop
						EndIf

						IncProc("Processando cortes..." + str(nReg))	  						
						dbSelectArea("SC9")
						dbGoto((cAliasSC9)->C9_RECNO)        				

						// @history chamado ti - Fernando Maci- 24/08/2021 - Consist๊ncias Integra็ใo EDATA devido RECNO com CAST na view [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01]
						If SC9->( EOF() ) .or. ( AllTrim(SC9->C9_PRODUTO) <> AllTrim((cAliasSC9)->IE_MATEEMBA) ) .or. ( SC9->(RecNo()) <> (cAliasSC9)->C9_RECNO )

							u_GrLogZBE( msDate(), TIME(), cUserName, "CCSP_002", "FATURAMENTO", "CCSP_002",;
							"C9_RECNO: " + AllTrim(Str((cAliasSC9)->C9_RECNO)) + " DA VW_EXPECARG_01 DIVERGENTE NA SC9 PROTHEUS - Produto: " + AllTrim((cAliasSC9)->IE_MATEEMBA) + " da carga: " + AllTrim((cAliasSC9)->ID_CARGEXPE),;
							ComputerName(), LogUserName() )

							Alert("[CCSP_002-01] - Dados da Integra็ใo com problema entre EDATA e Protheus! Contate o TI...")
							Alert("[CCSP_002-02] - Produto: " + AllTrim((cAliasSC9)->IE_MATEEMBA) + " da carga: " + AllTrim((cAliasSC9)->ID_CARGEXPE) + " nใo serแ processado! Verifique...")
							Alert("[CCSP_002-03] - C9_RECNO: " + AllTrim(Str((cAliasSC9)->C9_RECNO)) )

							(cAliasSC9)->(DbSkip())
							Loop

						EndIf
						//

						// acerto do lacre no SC5
						SC5->(dbSetOrder(1))                                
						If SC5->(dbSeek(SC9->(C9_FILIAL+C9_PEDIDO)))												
							If cChave <> SC9->(C9_FILIAL+C9_PEDIDO) .AND. Empty(SC5->C5_NOTA) // Ricardo Lima - 09/10/18
								AADD(aPedidos,{SC9->(C9_FILIAL+C9_PEDIDO),.f.})
								cChave:= SC9->(C9_FILIAL+C9_PEDIDO)       
								//zera o volume caso haja corte
								RecLock("SC5",.F.)
									SC5->C5_VOLUME1:= 0
									SC5->C5_PESOL  := 0
									SC5->C5_PBRUTO := 0
								MsUnLock()
							EndIf 
							
							//Everson - 12/06/2019. Chamado 044314.
							dDtPed := SC5->C5_DTENTR 
							
							//@history chamado 8465   - LeonardoMont - 02/06/2021 - Corre็ใo no fonte para nใo gravas as informa็๕es do lacre SIF no retorno da integra็ใo com eData.
							if SC5->C5_EST !="EX"
								//grava o lacre
								RecLock("SC5",.F.)
									SC5->C5_NLACRE1	:= (cAliasSC9)->NR_LACRCARGEXPE
								MsUnLock()
							ENDIF
							//Posiciona no SC9
							dbSelectArea("SC9")
							dbGoto((cAliasSC9)->C9_RECNO)        				

							// @history chamado ti - Fernando Maci- 24/08/2021 - Consist๊ncias Integra็ใo EDATA devido RECNO com CAST na view [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01]
							If SC9->( EOF() ) .or. ( AllTrim(SC9->C9_PRODUTO) <> AllTrim((cAliasSC9)->IE_MATEEMBA) ) .or. ( SC9->(RecNo()) <> (cAliasSC9)->C9_RECNO )

								u_GrLogZBE( msDate(), TIME(), cUserName, "CCSP_002", "FATURAMENTO", "CCSP_002",;
								"C9_RECNO: " + AllTrim(Str((cAliasSC9)->C9_RECNO)) + " DA VW_EXPECARG_01 DIVERGENTE NA SC9 PROTHEUS - Produto: " + AllTrim((cAliasSC9)->IE_MATEEMBA) + " da carga: " + AllTrim((cAliasSC9)->ID_CARGEXPE),;
								ComputerName(), LogUserName() )

								Alert("[CCSP_002-04] - Dados da Integra็ใo com problema entre EDATA e Protheus! Contate o TI...")
								Alert("[CCSP_002-05] - Produto: " + AllTrim((cAliasSC9)->IE_MATEEMBA) + " da carga: " + AllTrim((cAliasSC9)->ID_CARGEXPE) + " nใo serแ processado! Verifique...")
								Alert("[CCSP_002-06] - C9_RECNO: " + AllTrim(Str((cAliasSC9)->C9_RECNO)) )

								(cAliasSC9)->(DbSkip())
								Loop

							EndIf
							//

							_cLacre:= ""                         			
							If Empty(SC9->C9_BLCRED)	        										
								If (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND <> SC9->C9_QTDLIB // compara quantidade de caixas do pedido com as caixas expedidas								
									aPedidos[Len(aPedidos)][2]:=.T.
									If (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND == 0
										Reclock("SC9",.F.)
											dbdelete()
										Msunlock()
									Else
										_cLacre:=(cAliasSC9)->NR_LACRCARGEXPE                									
										Reclock("SC9",.F.)
										If Alltrim(SC9->C9_PRODUTO) $ GETMV("MV_PRDREAL")   // fernando Sigoli 16/02/2017										
											Replace C9_QTDLIB With (cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND // pegamos o peso real									
										Else
											Replace C9_QTDLIB    With iif(Alltrim((Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_SEGUM")))="BS",;
											(cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND,;
											(cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND)  //alterado por Adriana, se bolsa nao soma 1a unidade como peso
										EndIf									
										Replace C9_QTDLIB2   With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
										Replace C9_LACRE1    With (cAliasSC9)->NR_LACRCARGEXPE									
										Msunlock()
									Endif								
									//ajusta SC6
									dbSelectArea("SC6")
									dbSetOrder(1)
									dbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)									
									If (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND == 0								
										If Alltrim(C6_UM) == "KG"							
											Reclock("SC6",.F.)
											Replace C6_QTDORI   With C6_QTDVEN
											Replace C6_QTDORI2  With C6_UNSVEN
											Replace C6_UNSVEN   With 0
											Replace C6_QTDVEN   With 0
											Replace C6_UNSVEN   With 0
											Replace C6_QTDLIB   With 0
											Replace C6_QTDLIB2  With 0
											Replace C6_VALOR    With 0
											Replace C6_QTDEMP   With 0
											Replace C6_QTDEMP2  With 0
											Msunlock()
										Endif	
									Else									
										If Alltrim(C6_UM) == "KG"										
											// Inicio: fernando Sigoli 16/02/2017 
											If Alltrim(SC9->C9_PRODUTO) $ GETMV("MV_PRDREAL") 									
												Reclock("SC6",.F.)
												Replace C6_QTDORI  With C6_QTDVEN
												Replace C6_QTDORI2 With C6_UNSVEN
												Replace C6_QTDVEN  With (cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND // peso real expedido
												Replace C6_UNSVEN  With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
												Replace C6_QTDLIB  With (cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND // peso real expedido
												Replace C6_QTDLIB2 With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
												Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
												Replace C6_QTDEMP  With (cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND // peso real expedido
												Replace C6_QTDEMP2 With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
												Msunlock() 										
											Else // Fim: fernando Sigoli 16/02/2017 									
												Reclock("SC6",.F.)
												Replace C6_QTDORI  With C6_QTDVEN
												Replace C6_QTDORI2 With C6_UNSVEN
												Replace C6_QTDVEN  With (cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND // peso padrao expedido
												Replace C6_UNSVEN  With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
												Replace C6_QTDLIB  With (cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND // peso padrao expedido
												Replace C6_QTDLIB2 With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
												Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
												Replace C6_QTDEMP  With (cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND // peso padrao expedido
												Replace C6_QTDEMP2 With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
												Msunlock() 									
											Endif									
										Elseif Alltrim(C6_SEGUM) == "BS"    //alterado por Adriana, se bolsa nao grava peso, e sim unidade									
											Reclock("SC6",.F.)
											Replace C6_QTDORI  With C6_QTDVEN
											Replace C6_QTDORI2 With C6_UNSVEN
											Replace C6_QTDVEN  With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
											Replace C6_UNSVEN  With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
											Replace C6_QTDLIB  With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
											Replace C6_QTDLIB2 With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
											Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
											Replace C6_QTDEMP  With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
											Replace C6_QTDEMP2 With (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
											Msunlock() 									
										Endif									
									EndIf												
									//grava o lacre
									RecLock("SC5",.F.)								
									SC5->C5_VOLUME1:= SC5->C5_VOLUME1 + (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND								
									// Inicio: fernando Sigoli 16/02/2017 
									If Alltrim(SC6->C6_PRODUTO) $ GETMV("MV_PRDREAL") 								
										SC5->C5_PESOL  := SC5->C5_PESOL + iif(SC6->C6_SEGUM="BS",0,(cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND) // peso real expedido								
									Else // Fim: fernando Sigoli 16/02/2017 								
										SC5->C5_PESOL  := SC5->C5_PESOL + iif(SC6->C6_SEGUM="BS",0,(cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND) //alterado por Adriana, se bolsa nao soma 1a unidade como peso								
									EndIf							
									dbSelectArea("SZC")
									dbSetOrder(1)
									dbGoTop()
									If dbSeek(xFilial("SZC")+SC6->C6_SEGUM)
										// Inicio: fernando Sigoli 16/02/2017 
										If Alltrim(SC6->C6_PRODUTO) $ GETMV("MV_PRDREAL") 									
											SC5->C5_PBRUTO := SC5->C5_PBRUTO + ((cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND * SZC->ZC_TARA) + iif(SC6->C6_SEGUM="BS",0,(cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND) // peso real expedido									
										Else // Fim: fernando Sigoli 16/02/2017 									
											SC5->C5_PBRUTO := SC5->C5_PBRUTO + ((cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND * SZC->ZC_TARA) + iif(SC6->C6_SEGUM="BS",0,(cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND) //alterado por Adriana, se bolsa nao soma 1a unidade como peso									
										EndIf
									Else 
										// Inicio: fernando Sigoli 16/02/2017 
										If Alltrim(SC6->C6_PRODUTO) $ GETMV("MV_PRDREAL") 								
											SC5->C5_PBRUTO := SC5->C5_PBRUTO + (cAliasSC9)->QN_PESOREALEXPEITEMPEDIVEND // peso real expedido																
										Else // Fim: fernando Sigoli 16/02/2017 								
											SC5->C5_PBRUTO := SC5->C5_PBRUTO + (cAliasSC9)->QN_PESOPADREXPEITEMPEDIVEND	 // peso padrao expedido									
										EndIf								
									Endif	
									MsUnLock()    											
								Else //Incluido por Adriana 
									dbSelectArea("SC6")
									dbSetOrder(1)
									dbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)	
									If SC6->C6_SEGUM = "BS"   
										//alterado por Adriana, se bolsa grava quantidade origem
										Reclock("SC6",.F.)
										Replace C6_QTDORI  With C6_QTDVEN
										Replace C6_QTDORI2 With C6_UNSVEN
										Msunlock()
										//grava o lacre
										RecLock("SC5",.F.)
										SC5->C5_VOLUME1:= SC5->C5_VOLUME1 + (cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND
										dbSelectArea("SZC")
										dbSetOrder(1)
										dbGoTop()
										If dbSeek(xFilial("SZC")+SC6->C6_SEGUM)
											SC5->C5_PBRUTO := SC5->C5_PBRUTO + ((cAliasSC9)->QN_EMBAEXPEITEMPEDIVEND * SZC->ZC_TARA)
										Endif	
										MsUnLock()    				
									Endif
								EndIf	                        
								lPedAb := .F.
							Else 
								if lPedAb
									If SC9->C9_BLCRED == "10"
										cMens += "- Pedido jแ faturado: [" + AllTrim(SC9->C9_PEDIDO) + "]" + CRLF
									Else
										cMens += "- Pedido Bloqueado por cr้dito: [" + AllTrim(SC9->C9_PEDIDO) + "]" + CRLF
									Endif
									lContinua := .F.
								Else
									cMens := ""
									lContfat := .T.
								Endif
							EndIf
						Else
							cMens += "- Pedido Nใo Encontrado: [" + AllTrim(SC9->C9_PEDIDO) + "]" + CRLF				
							lContinua:=.F.
						EndIf
						if !lPedAb 
							If !Empty(cMens)
								cMens     := ""
								lContfat  := .T.
								lContinua := .T.
							Endif
						Endif					
						nReg := nReg - 1	
						DbSelectArea(cAliasSC9)		
						(cAliasSC9)->(DbSkip())					
					EndDo		
					If lContinua							
						// envia wf
						For ni2:=1 to Len(aPedidos)				
							If aPedidos[ni2][2]
								U_CCSKFWF(aPedidos[ni2][1])	
							EndIf
						Next ni					
						// Rotina para ajustar os pedidos de venda ordem
						// Sigoli 10/03/2017 Chamado: 034029 
						For nIX:=1 to Len(aPedidos)				
							If aPedidos[nIX][2]							
								DbSelectArea("SC5")
								If dbseek(xFilial("SC5")+Alltrim(substr(aPedidos[nIX][1],3,6)))
									If !Empty(SC5->C5_XPEDORD)		
										AtuaPedVend(Alltrim(substr(aPedidos[nIX][1],3,6)),Alltrim(SC5->C5_XPEDORD)) // chamada da fun็ใo para verificar se o pedido de remessa esta atrelado a um pedido venda เ ordem
									EndIF
								EndIf							
							EndIf					
						Next ni
						//Sigoli 10/03/2017 Chamado: 034029 					
						// salva variแveis globais
						__Rot:=cRoteiro
						__dDtEnt:=STOD(cData)

					Else
						DisarmTransaction()		    	
						cMens += "- Roteiro nใo processado: [" + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot]) + "]" + CRLF + cMens + CRLF + "-------------------------"
					EndIf				
					// Ricardo Lima - 10/01/18
					//EndTran() 
				END TRANSACTION					
				DbSelectArea(cAliasSC9)
				dbCloseArea()
			EndIf

			// *** INICIO WILLIAM COSTA 22/10/2018 CHAMADO 044537 || OS 045675 || ADM.LOG || MARCEL || 8492 || REL.FRETE ANALITICO  *** // 
			SqlSomaPesos(cData,cRoteiro)
			While TRB->(!EOF())

				IF TRB->C5_PESOL  > 0 .AND. ;
				TRB->C5_PBRUTO > 0

					DBSELECTAREA("SZK")
					DBSETORDER(8)
					IF DBSEEK(FWFilial("SZK") + cData + cRoteiro,.T.)

						RecLock("SZK",.F.)
						SZK->ZK_PESOL  := TRB->C5_PESOL
						SZK->ZK_PBRUTO := TRB->C5_PBRUTO
						MsUnLock()

					ENDIF
				ENDIF

				TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())
			// *** FINAL WILLIAM COSTA 22/10/2018 CHAMADO 044537 || OS 045675 || ADM.LOG || MARCEL || 8492 || REL.FRETE ANALITICO  *** //

		Endif	
	Next ni   

	If !Empty(cMens)
		cMens := "Roteiro/Pedidos que nใo foram processados : " + CRLF + cMens
		U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)
	Else
		// executa a fun็ใo de faturamento
		if lContfat
			Aviso("CCSP_002","****Continua็ใo do Faturamento****"+chr(13)+chr(10)+"Ajuste dos pedidos finalizado com sucesso!"+chr(13)+chr(10)+"Serแ iniciado o Faturamento!",{"OK"},3)	
		Else
			Aviso("CCSP_002","Ajuste dos pedidos finalizado com sucesso!"+chr(13)+chr(10)+"Serแ iniciado o Faturamento!",{"OK"},3)	
		Endif
		lRetFat := MATA460() //Everson - 30/05/2019. Chamado 044314.		          		   
		Pergunte(cPerg,.F.)

		//Everson - 30/05/2019. Chamado 044314.
		If cEmpAnt $ cEmpFrt .And. cFilAnt $ cFilGFrt //Everson-CH:044314-06/08/19.
			logZBE("Gera็ใo de frete CCS_002PN","Dt Entrega|roteiro|roteiro " + cValToChar(dDtPed) + "|" + cValToChar(cRoteiro) + "|" + cValToChar(cRoteiro) ) //Everson - 05/06/19. Chamado 044314.
			StaticCall(ADLOG042P,sptEst,dDtPed,dDtPed,cRoteiro,cRoteiro) //Everson - 03/06/19. Chamado 044314.//Everson - 12/06/2019. Chamado 044314.

		EndIf

	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณCCS_001PF  บAutor  ณPablo Gollan Carreras บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de processamento de registros selecionados  Faturamento Antบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณAdoro                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CCS_002PF()

	Local ni				:= 0
	Local ni2				:= 0
	Local cChave			:= ""
	Local cMens				:= ""
	Local cMensok			:= ""
	Local cRest01			:= ""
	Local cQuery 			:= ""
	Local cAliasSC9	    	:= CriaTrab(NIL,.F.)	
	Local lContinua			:= .T.
	Local aPedidos			:= {}
	Local nReg				:= 0
	Local lRetFat			:= .F. //Everson - 30/05/2019. Chamado 044314.
	Private __Rot 			:= ""
	Private __dDtEnt		

	cData	 := ""
	cRoteiro := ""
	cPlaca	 := ""

	For ni := opGridSC5:NAT to Len(opGridSC5:aCols)

		If cData+cRoteiro+cPlaca <> AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr])) + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot]) + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosPla])
			//Salva Roteiro em processamento
			cData	 := AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr]))
			cRoteiro := AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot])
			cPlaca	 := AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosPla])

			// salva variแveis globais
			__Rot:=cRoteiro
			__dDtEnt:=STOD(cData)

		EndIf

		// *** INICIO WILLIAM COSTA 22/10/2018 CHAMADO 044537 || OS 045675 || ADM.LOG || MARCEL || 8492 || REL.FRETE ANALITICO  *** // 
		SqlSomaPesos(cData,cRoteiro)
		While TRB->(!EOF())

			IF TRB->C5_PESOL  > 0 .AND. ;
			TRB->C5_PBRUTO > 0

				DBSELECTAREA("SZK")
				DBSETORDER(8)
				IF DBSEEK(FWFilial("SZK") + cData + cRoteiro,.T.)

					RecLock("SZK",.F.)
					SZK->ZK_PESOL  := TRB->C5_PESOL
					SZK->ZK_PBRUTO := TRB->C5_PBRUTO
					MsUnLock()

				ENDIF
			ENDIF

			TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())
		// *** FINAL WILLIAM COSTA 22/10/2018 CHAMADO 044537 || OS 045675 || ADM.LOG || MARCEL || 8492 || REL.FRETE ANALITICO  *** //

	Next ni   

	// executa a fun็ใo de faturamento
	Aviso("CCSP_002","Ajuste dos pedidos finalizado com sucesso! Serแ iniciado o Faturamento!",{"OK"},3)	
	lRetFat := MATA460() //Everson - 30/05/2019. Chamado 044314.		          		   
	Pergunte(cPerg,.F.)

	//Everson - 30/05/2019. Chamado 044314.
	If cEmpAnt $ cEmpFrt .And. cFilAnt $ cFilGFrt //Everson-CH:044314-06/08/19.
		logZBE("Gera็ใo de frete CCS_002PF","Dt Entrega|roteiro|roteiro " + cValToChar(cData) + "|" + cValToChar(cRoteiro) + "|" + cValToChar(cRoteiro) ) //Everson - 05/06/19. Chamado 044314.
		StaticCall(ADLOG042P,sptEst,SToD(cData),SToD(cData),cRoteiro,cRoteiro) //Everson - 03/06/2019. Chamado 044314.

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณCCS_001PD  บAutor  ณPablo Gollan Carreras บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de processamento de registros selecionados - Diversos      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณADORO                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CCS_002PD()

	Local ni				:= 0
	Local ni2				:= 0
	Local cChave			:= ""
	Local cMens				:= ""
	Local cMensok			:= ""
	Local cRest01			:= ""
	Local cQuery 			:= ""
	Local cAliasSC5	    	:= CriaTrab(NIL,.F.)	
	Local lContinua			:= .T.
	Local aPedidos			:= {}
	Local nReg				:= 0
	Local lRetFat			:= .F. //Everson - 30/05/2019. Chamado 044314.
	Local dDtPed			:= Nil  //Everson - 12/06/19. Chamado 044314.
	Private __Rot 			:= ""
	Private __dDtEnt		

	cData	 := ""
	cRoteiro := ""
	cPlaca	 := ""

	For ni := opGridSC5:NAT to Len(opGridSC5:aCols)

		If cData+cRoteiro+cPlaca <> AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr])) + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot]) + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosPla])
			//Salva Roteiro em processamento
			cData	 := AllTrim(Dtos(opGridSC5:aCols[opGridSC5:NAT,nPosEntr]))
			cRoteiro := AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot])
			cPlaca	 := AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosPla])
			
			dDtPed   := SToD(cData) //Everson - 12/06/19. Chamado 044314.

			DbSelectArea("SC5")
			DBORDERNICKNAME("SC5_9")
			DbSeek(xFilial("SC5")+cData+cRoteiro+cPlaca)

			cQuery := "SELECT COUNT(*) AS REC FROM [LNKMIMS].[SMART].[dbo].[VW_PESADIVE_01] WHERE ID_PEDIVEND = " + Str(SC5->(RECNO())) + " "		

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.F.)

			nReg:=(cAliasSC5)->(REC)

			DbSelectArea(cAliasSC5)
			dbCloseArea()

			// debug
			//nReg := 1
			//

			If nReg==0
				Aviso("CCSP_002","Problema - Carga nใo liberada no eData - Verificar!!!",{"OK"},3)
				Return
			EndIf

			cQuery := "SELECT * FROM [LNKMIMS].[SMART].[dbo].[VW_PESADIVE_01] WHERE ID_PEDIVEND = " + Str(SC5->(RECNO()))  + " "
			cQuery += "ORDER BY FILIAL+ID_PEDIVEND"	

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC5,.T.,.F.)

			DbSelectArea(cAliasSC5)
			Dbgotop()


			//ProcRegua(nReg)

			// Ricardo Lima - 10/01/18
			//BeginTran()
			BEGIN TRANSACTION

				cChave:= ""

				While (cAliasSC5)->(!EOF())

					//IncProc("Processando cortes..." + str(nReg))	  

					dbSelectArea("SC5")
					dbGoto((cAliasSC5)->ID_PEDIVEND)        				

					// @history chamado ti - Fernando Maci- 24/08/2021 - Consist๊ncias Integra็ใo EDATA devido RECNO com CAST na view [LNKMIMS].[SMART].[dbo].[VW_EXPECARG_01]
					If SC5->( EOF() ) .or. ( SC5->(RecNo()) <> (cAliasSC5)->ID_PEDIVEND )

						u_GrLogZBE( msDate(), TIME(), cUserName, "CCSP_002", "FATURAMENTO", "CCSP_002",;
						"ID_PEDIVEND (RECNO DA SC5) DA VW_EXPECARG_01 DIVERGENTE NA SC5 PROTHEUS - PV (C5_RECNO): " + AllTrim(Str((cAliasSC5)->ID_PEDIVEND)),;
						ComputerName(), LogUserName() )

						Alert("[CCSP_002-07] - Dados da Integra็ใo com problema entre EDATA e Protheus! Contate o TI...")
						Alert("[CCSP_002-08] - PV (C5_RECNO): " + AllTrim(Str((cAliasSC5)->ID_PEDIVEND)) )

						(cAliasSC5)->(DbSkip())
						Loop

					EndIf
					//

					_AntVolume1 := SC5->C5_VOLUME1
					_AntPesol   := SC5->C5_PESOL
					_AntPbruto  := SC5->C5_PBRUTO
					//grava o lacre
					RecLock("SC5",.F.)
						//@history chamado 8465   - LeonardoMont - 02/06/2021 - Corre็ใo no fonte para nใo gravas as informa็๕es do lacre SIF no retorno da integra็ใo com eData.
						if SC5->C5_EST !='EX'	
							SC5->C5_NLACRE1	:= ALLTRIM(str((cAliasSC5)->ID_TICKPESA))
						endif

						SC5->C5_VOLUME1:= 0
						SC5->C5_PESOL  := 0
						SC5->C5_PBRUTO := 0
					MsUnLock()    				
					
					//
					dDtPed := SC5->C5_DTENTR //Everson - 12/06/19. Chamado 044314.

					// acerto do lacre no SC5
					SC9->(dbSetOrder(1))                                
					If SC9->(dbSeek(SC5->(C5_FILIAL+C5_NUM)))

						If cChave <> SC5->(C5_FILIAL+C5_NUM)
							AADD(aPedidos,{SC5->(C5_FILIAL+C5_NUM),.f.})
							cChave:= SC5->(C5_FILIAL+C5_NUM)
						EndIf

						If Empty(SC9->C9_BLCRED)	        			

							nPeso:= (cAliasSC5)->QN_SEGUPESATICKPESA - (cAliasSC5)->QN_PRIMPESATICKPESA 

							If nPeso <> SC9->C9_QTDLIB

								aPedidos[Len(aPedidos)][2]:=.T.

								//ajusta SC6
								dbSelectArea("SC6")
								dbSetOrder(1)
								dbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)

								If Alltrim(C6_UM) == "KG"							

									Reclock("SC9",.F.)

									// *** INICIO CHAMADO 037061 WILLIAM COSTA VOLTAR O BLOQUEIO DE CREDITO E ESTOQUE SE O PESO FOR DIFERENTE *** //

									IF nPeso > SC9->C9_QTDLIB //se o peso da balanca for maior bloqueia credito e estoque

										IF ALLTRIM(Posicione("SF4",1,XFilial("SF4")+SC6->C6_TES,"F4_DUPLIC")) = 'S'

											Replace C9_BLCRED  With '01'
											Replace C9_BLEST   With '02'

											cMens += "- Pedido Bloqueado por cr้dito e Estoque: [" + AllTrim(SC5->C5_NUM) + "]" + CRLF

										ENDIF
									ENDIF 

									// *** FINAL CHAMADO 037061 WILLIAM COSTA VOLTAR O BLOQUEIO DE CREDITO E ESTOQUE SE O PESO FOR DIFERENTE *** //

									Replace C9_QTDLIB  With nPeso
									Replace C9_QTDLIB2 With nPeso

									Msunlock()								
								Endif	

								dbSelectArea("SC6")
								dbSetOrder(1)
								dbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
								If Alltrim(C6_UM) == "KG"
									Reclock("SC6",.F.)
									Replace C6_QTDORI  With C6_QTDVEN
									Replace C6_QTDORI2 With C6_UNSVEN
									Replace C6_QTDVEN  With nPeso
									Replace C6_UNSVEN  With nPeso
									Replace C6_QTDLIB  With nPeso
									Replace C6_QTDLIB2 With nPeso
									Replace C6_VALOR   With C6_QTDVEN * C6_PRCVEN
									Replace C6_QTDEMP   With nPeso
									Replace C6_QTDEMP2  With nPeso
									Msunlock()

									RecLock("SC5",.F.)
									SC5->C5_VOLUME1:= SC5->C5_VOLUME1 + nPeso
									SC5->C5_PESOL  := SC5->C5_PESOL  + nPeso
									SC5->C5_PBRUTO := SC5->C5_PBRUTO + nPeso						
									MsUnLock()								
								Else							
									RecLock("SC5",.F.)
									SC5->C5_VOLUME1:= _AntVolume1
									SC5->C5_PESOL  := _AntPesol
									SC5->C5_PBRUTO := _AntPbruto
									MsUnLock()														
								Endif								
							Else
								RecLock("SC5",.F.)
								SC5->C5_VOLUME1:= _AntVolume1
								SC5->C5_PESOL  := _AntPesol
								SC5->C5_PBRUTO := _AntPbruto
								MsUnLock()														
							EndIf	                        
						Else
							If SC9->C9_BLCRED == "10"
								cMens += "- Pedido jแ faturado: [" + AllTrim(SC5->C5_NUM) + "]" + CRLF
							Else
								cMens += "- Pedido Bloqueado por cr้dito: [" + AllTrim(SC5->C5_NUM) + "]" + CRLF
							Endif					
							lContinua:=.F.
						EndIf
					Else
						cMens += "- Pedido Nใo Encontrado: [" + AllTrim(SC5->C5_NUM) + "]" + CRLF				
						lContinua:=.F.
					EndIf

					nReg:=nReg -1	
					DbSelectArea(cAliasSC5)		
					(cAliasSC5)->(DbSkip())
				EndDo

				If lContinua

					// envia wf
					For ni2:=1 to Len(aPedidos)				
						If aPedidos[ni2][2]
							U_CCSKFWF(aPedidos[ni2][1])	
						EndIf
					Next ni

					// salva variแveis globais
					__Rot:=cRoteiro
					__dDtEnt:=STOD(cData)

				Else
					DisarmTransaction()
					cMens += "- Roteiro nใo processado: [" + AllTrim(opGridSC5:aCols[opGridSC5:NAT,nPosRot]) + "]" + CRLF + cMens + CRLF + "-------------------------"
				EndIf

				// Ricardo Lima - 10/01/18
				//EndTran()
			END TRANSACTION					
			DbSelectArea(cAliasSC5)
			dbCloseArea()
		EndIf

		// *** INICIO WILLIAM COSTA 22/10/2018 CHAMADO 044537 || OS 045675 || ADM.LOG || MARCEL || 8492 || REL.FRETE ANALITICO  *** // 
		SqlSomaPesos(cData,cRoteiro)
		While TRB->(!EOF())

			IF TRB->C5_PESOL  > 0 .AND. ;
			TRB->C5_PBRUTO > 0

				DBSELECTAREA("SZK")
				DBSETORDER(8)
				IF DBSEEK(FWFilial("SZK") + cData + cRoteiro,.T.)

					RecLock("SZK",.F.)
					SZK->ZK_PESOL  := TRB->C5_PESOL
					SZK->ZK_PBRUTO := TRB->C5_PBRUTO
					MsUnLock()

				ENDIF
			ENDIF

			TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())
		// *** FINAL WILLIAM COSTA 22/10/2018 CHAMADO 044537 || OS 045675 || ADM.LOG || MARCEL || 8492 || REL.FRETE ANALITICO  *** //

	Next ni   

	If !Empty(cMens)
		cMens := "Roteiro/Pedidos que nใo foram processados : " + CRLF + cMens
		U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)
	Else
		// executa a fun็ใo de faturamento
		Aviso("CCSP_002","Ajuste dos pedidos finalizado com sucesso! Serแ iniciado o Faturamento!",{"OK"},3)	
		lRetFat := MATA460() //Everson - 30/05/2019. Chamado 044314.		          		   
		Pergunte(cPerg,.F.)

		//Everson - 30/05/2019. Chamado 044314.
		If cEmpAnt $ cEmpFrt .And. cFilAnt $ cFilGFrt //Everson-CH:044314-06/08/19.
			logZBE("Gera็ใo de frete CCS_002PD","Dt Entrega|roteiro|roteiro " + cValToChar(dDtPed) + "|" + cValToChar(cRoteiro) + "|" + cValToChar(cRoteiro) ) //Everson - 05/06/19. Chamado 044314.
			StaticCall(ADLOG042P,sptEst,dDtPed,dDtPed,cRoteiro,cRoteiro) //Everson - 03/06/2019. Chamado 044314. //Everson - 12/06/19. Chamado 044314.
			
		EndIf

	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFPESQ     บAutor  ณHermes Ferreira     บ Data ณ  18/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo Pesquisa da tela                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FPESQ(clAlias)

	Local cSql := ""  // RICARDO LIMA - 10/01/18

	clAlias := GetNextAlias()

	cSql := FQRY002()

	TcQuery cSql New Alias &(clAlias)
	TCSetField((clAlias),"C5_DTENTR"	,"D",TamSx3("C5_DTENTR")[1]		,TamSx3("C5_DTENTR")[2]	)

	(clAlias)->(dbGoTop())	
	If (clAlias)->(!Eof()) .And. (clAlias)->(!Bof())
		FAHECOLS(clAlias)

		opGridSC5:aCols := aClone(apCols)
		opGridSC5:Refresh()

	Else
		opGridSC5:aCols := {}
		opGridSC5:Refresh()
		Aviso("CCSP_002","Nใo foram localizados registros, com os parโmetros informados.",{"OK"},3)
	EndIf		

	IIF ( Select(clAlias) > 0, (clAlias)->(dbCloseArea()),NIL)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAHECOLS  บAutor  ณHermes Ferreira     บ Data ณ  18/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria o aheader e acols da tela SZX, separar lotes           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FAHECOLS(clAlias)

	Local aCmpHeader	:= {}
	Local nI			:= 0
	Local i				:= 0

	If Len(apHeader) == 0

		AADD(aCmpHeader,"C5_DTENTR")
		AADD(aCmpHeader,"C5_ROTEIRO")
		AADD(aCmpHeader,"C5_PLACA")
		AADD(aCmpHeader,"C5_NUM")
		AADD(aCmpHeader,"C5_CLIENTE")
		AADD(aCmpHeader,"A1_NREDUZ")
		AADD(aCmpHeader,"C5_X_SQED")
		AADD(aCmpHeader,"C5_XTIPO")		
		AADD(aCmpHeader,"C5_XFATANT")
		// RICARDO LIMA - 10/01/18
		AADD(aCmpHeader,"C5_NOTA")
		AADD(aCmpHeader,"C5_SERIE")		
		//AADD(aCmpHeader,"C5_XWSPAGO")	// 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FWNM - 12/08/2020	

		Aadd(apHeader,	{	"","C5_XFLAGE","@BMP",;
		10,0,"",;
		"","C",	;
		"","","",,"",	;
		"","","",""	})	

		SX3->(DbSetOrder(2))
		For nI := 1 to Len(aCmpHeader)
			If SX3->(DbSeek(aCmpHeader[nI]))
				Aadd(apHeader,	{	Trim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,	;
				SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,,SX3->X3_WHEN,	;
				SX3->X3_VISUAL,SX3->X3_VLDUSER, SX3->X3_PICTVAR,SX3->X3_OBRIGAT	})
			EndIf
		Next nI

	Else

		apCols:= {}
		opGridSC5:aCols:= {}

	EndIf

	(clAlias)->(dbGoTop())
	While (clAlias)->(!Eof())

		AAdd(apCols,Array(Len(apHeader)+1))

		For i := 1 To Len(apHeader)

			If Alltrim(apHeader[i,2]) == "C5_XFLAGE" 

				If (clAlias)->(&(apHeader[i,2])) == "1" 
					apCols[Len(apCols)][i] := "BR_VERMELHO"
				ElseIf  (clAlias)->(&(apHeader[i,2])) == "2"
					apCols[Len(apCols)][i] := "BR_VERDE"								
				EndIf 
				
				// RICARDO LIMA - 10/01/18
				If !EMPTY( (clAlias)->(&(apHeader[11,2])) )
					apCols[Len(apCols)][i] := "BR_AZUL"
				ENDIF	

				// Chamado n. 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - FWNM - 12/08/2020
				/*
				FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
				If FIE->( msSeek(FWxFilial("FIE")+"R"+(clAlias)->C5_NUM) )

					SE1->( dbSetOrder(2) ) //E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
					If SE1->( msSeek(FIE->(FIE_FILIAL+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO)) )
					
						If Empty((clAlias)->C5_XWSPAGO)
							apCols[Len(apCols)][i] := "BR_AMARELO"
						EndIf
					
					EndIf
				
				EndIf
				*/
				//
				
			ElseIf  apHeader[i,10] <> "V"

				apCols[Len(apCols)][i] := (clAlias)->(&(apHeader[i,2]))

			Else

				apCols[Len(apCols)][i] := CriaVar(apHeader[i,2])

			EndIf
		Next i

		apCols[Len(apCols)][Len(apHeader)+1] := .F.

		(clAlias)->(dbSkip())
	EndDo

	(clAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} FQRY002
	Executa query pesquisa
	@type  Static Function
	@author CCSKF
	@since 18/07/2012
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function FQRY002()

	Local cSql := ""
	Local cWh  := ""
	Local cFIEFiltro := "" 

	If  ValType(MV_PAR04) == "N"

		If MV_PAR04 == 1		
			cWh := " AND C5_XFLAGE IN ('1') " //Pendentes
		ElseIf MV_PAR04 == 2		
			cWh := " AND C5_XFLAGE IN ('2') AND C5_NOTA = '' " //Liberados //ADD NA CONDIวรO DE NOTAS EM BANCO QUANDO LEGENDA LIBERADOS CHAMADO:044699 23/10/2018 - FERNANDO SIGOLI
		Else
			cWh := "AND C5_XFLAGE IN ('1','2')" // todos
		EndIf

	Else

		If MV_PAR04 == "1"		
			cWh := " AND C5_XFLAGE IN ('1') " //Pendentes
		ElseIf MV_PAR04 == "2"		
			cWh := " AND C5_XFLAGE IN ('2') AND C5_NOTA = '' " //Liberados //ADD NA CONDIวรO DE NOTAS EM BANCO QUANDO LEGENDA LIBERADOS CHAMADO:044699 23/10/2018 - FERNANDO SIGOLI
		Else
			cWh := "AND C5_XFLAGE IN ('1','2')" // todos
		EndIf	

	EndIf

	//cSql:= "SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A1_NREDUZ,C5_X_SQED,C5_XFLAGE,C5_XTIPO,C5_XFATANT, C5_NOTA, C5_SERIE "
	cSql:= "SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A1_NREDUZ,C5_X_SQED,C5_XFLAGE,C5_XTIPO,C5_XFATANT, C5_NOTA, C5_SERIE, C5_XWSPAGO, C5_XWSBOLG "
	cSql+= " FROM " + RetSqlName("SC5") + " SC5 , " + RetSqlName("SA1") + " SA1 "
	cSql+= " WHERE SC5.D_E_L_E_T_ =' ' AND SA1.D_E_L_E_T_ =' ' AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cSql+= " AND SC5.C5_CLIENTE = SA1.A1_COD "
	cSql+= " AND SC5.C5_LOJACLI = SA1.A1_LOJA "
	cSql+= " AND SC5.C5_TIPO = 'N' "
	cSql+= " AND SC5.C5_LIBEROK = 'S'  "
	cSql+= " AND SC5.C5_XINT = '3' " // APENAS OS QUE FORAM INTEGRADOS
	cSql+= " AND SC5.C5_ROTEIRO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cSql+= " AND SC5.C5_DTENTR = '" + DTOS(MV_PAR03) +"' "
	cSql+= " AND SC5.C5_X_SQED <> ' ' "
	cSql+= cWh
	cSql+= " UNION ALL	"
	//cSql+= "SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A2_NREDUZ,C5_X_SQED,C5_XFLAGE,C5_XTIPO, C5_XFATANT, C5_NOTA, C5_SERIE "
	cSql+= "SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A2_NREDUZ,C5_X_SQED,C5_XFLAGE,C5_XTIPO, C5_XFATANT, C5_NOTA, C5_SERIE, C5_XWSPAGO, C5_XWSBOLG "
	cSql+= " FROM " + RetSqlName("SC5") + " SC5 , " + RetSqlName("SA2") + " SA2 "
	cSql+= " WHERE SC5.D_E_L_E_T_ =' ' AND SA2.D_E_L_E_T_ =' ' AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
	cSql+= " AND SC5.C5_CLIENTE = SA2.A2_COD "
	cSql+= " AND SC5.C5_LOJACLI = SA2.A2_LOJA "
	cSql+= " AND SC5.C5_TIPO = 'B' "
	cSql+= " AND SC5.C5_LIBEROK = 'S'  "
	cSql+= " AND SC5.C5_XINT = '3' " // APENAS OS QUE FORAM INTEGRADOS
	cSql+= " AND SC5.C5_ROTEIRO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	cSql+= " AND SC5.C5_DTENTR = '" + DTOS(MV_PAR03) +"' "
	cSql+= " AND SC5.C5_X_SQED <> ' ' "
	cSql+= cWh
	cSql+= " ORDER BY SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_PLACA,SC5.C5_NUM "

	//@history Chamado 059415 - FWNM          - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consist๊ncias por indefini็๕es de implanta็ใo
	/*
	// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 29/05/2020
	If Select("WorkFIE") > 0
		WorkFIE->( dbCloseArea() )
	EndIf

	tcQuery cSql New Alias "WorkFIE"

	WorkFIE->( dbGoTop() )

	Do While WorkFIE->( !EOF() )

		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+WorkFIE->C5_NUM) )

			SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
			If SC5->( dbSeek(FWxFilial("SC5")+WorkFIE->C5_NUM) )
			
				If AllTrim(SC5->C5_XWSPAGO) <> "S"

					cFIEFiltro += SC5->C5_NUM + "|"

				EndIf

			EndIf

		EndIf

		WorkFIE->( dbSkip() )

	EndDo

	If Select("WorkFIE") > 0
		WorkFIE->( dbCloseArea() )
	EndIf

	If !Empty(cFIEFiltro)

		cSql := "SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A1_NREDUZ,C5_X_SQED,C5_XFLAGE,C5_XTIPO,C5_XFATANT, C5_NOTA, C5_SERIE "
		cSql += " FROM " + RetSqlName("SC5") + " SC5 , " + RetSqlName("SA1") + " SA1 "
		cSql += " WHERE SC5.D_E_L_E_T_ =' ' AND SA1.D_E_L_E_T_ =' ' AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cSql += " AND SC5.C5_CLIENTE = SA1.A1_COD "
		cSql += " AND SC5.C5_LOJACLI = SA1.A1_LOJA "
		cSql += " AND SC5.C5_TIPO = 'N' "
		cSql += " AND SC5.C5_LIBEROK = 'S'  "
		cSql += " AND SC5.C5_XINT = '3' " // APENAS OS QUE FORAM INTEGRADOS
		cSql += " AND SC5.C5_ROTEIRO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		cSql += " AND SC5.C5_DTENTR = '" + DTOS(MV_PAR03) +"' "
		cSql += " AND SC5.C5_X_SQED <> ' ' "
		cSql += cWh
		cSql += " AND C5_NUM NOT IN " + FormatIn(cFIEFiltro,"|")

		cSql += " UNION ALL	"

		cSql += "SELECT C5_DTENTR,C5_ROTEIRO,C5_PLACA,C5_NUM,C5_CLIENTE,A2_NREDUZ,C5_X_SQED,C5_XFLAGE,C5_XTIPO, C5_XFATANT, C5_NOTA, C5_SERIE "
		cSql += " FROM " + RetSqlName("SC5") + " SC5 , " + RetSqlName("SA2") + " SA2 "
		cSql += " WHERE SC5.D_E_L_E_T_ =' ' AND SA2.D_E_L_E_T_ =' ' AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cSql += " AND SC5.C5_CLIENTE = SA2.A2_COD "
		cSql += " AND SC5.C5_LOJACLI = SA2.A2_LOJA "
		cSql += " AND SC5.C5_TIPO = 'B' "
		cSql += " AND SC5.C5_LIBEROK = 'S'  "
		cSql += " AND SC5.C5_XINT = '3' " // APENAS OS QUE FORAM INTEGRADOS
		cSql += " AND SC5.C5_ROTEIRO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		cSql += " AND SC5.C5_DTENTR = '" + DTOS(MV_PAR03) +"' "
		cSql += " AND SC5.C5_X_SQED <> ' ' "
		cSql += cWh
		cSql += " AND C5_NUM NOT IN " + FormatIn(cFIEFiltro,"|")

		cSql += " ORDER BY SC5.C5_DTENTR,SC5.C5_ROTEIRO,SC5.C5_PLACA,SC5.C5_NUM "

	EndIf
	*/
	//

Return cSql

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCCS_LEG   บAutor  ณHermes Ferreira     บ Data ณ  18/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria a legenda a tela da SZX,monitor separa็ao de lotes     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CCS_LEG()

	Local aCor := {}
	// RICARDO LIMA - 10/01/18
	aAdd(aCor,{"BR_VERMELHO","Pendente"     })
	aAdd(aCor,{"BR_VERDE"	,"Liberado"  	})
	aAdd(aCor,{"BR_AZUL"	,"Faturado"  	})
	//aAdd(aCor,{"BR_AMARELO"	,"PV com Adiantamento nใo recebido" }) //@history Chamado 059415 - FWNM          - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consist๊ncias por indefini็๕es de implanta็ใo
	
	BrwLegenda(,"Status",aCor)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณPFAT2Val   บAutor  ณPablo Gollan Carreras บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que atribui dinamicamente a validacao de cada pergunta     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPACE                                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CCSPVal1()

	Local lRet				:= .T.
	Local cVarAt			:= Upper(AllTrim(ReadVar()))
	Local nPos				:= 0
	Local aLstVld			:= {	{1,{|| Vazio() }},;
	{2,{|| Empty(StrTran(Upper(&(cVarAt)),"Z","")) }},;
	{3,{|| NaoVazio()}}}
	Local bConvNum			:= {|x| x := GetDToVal(x)}

	U_ADINF009P('CCSP_002' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para fechamento de carga do edata')

	If "MV_PAR" $ cVarAt
		If !Empty(nPos := aScan(aLstVld,{|x| x[1] == Eval(bConvNum,Right(cVarAt,2))}))
			lRet := Eval(aTail(aLstVld[nPos]))
		Endif
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1  บAutor  ณCCSKF		    	    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para ajuste do SX1 da rotina                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณADORO                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaSX1(cPerg)

	Local aMensHlp			:= Array(nQtdePerg)
	Local cRotVld			:= ""
	Local aOpc				:= Array(2,5)
	Local ni				:= 0

	For ni := 1 to Len(aOpc)
		aFill(aOpc[ni],"")
	Next ni                           

	aOpc[2][1] := "Pendente"
	aOpc[2][2] := "Liberado"
	aOpc[2][3] := "Todos"

	//				PERGUNTA					TIPO	TAM							DEC	OBJETO	PS	COMBO		SXG		F3		VALID				HELP
	aMensHlp[01] := {"Roteiro de?"				,"C"	,TamSX3("C5_ROTEIRO")[1]	,00	,"G"	,0	,aOpc[1]	,"001"	,""		,cRotVld	,"Informe o ROTEIRO inicial do intervalo"}
	aMensHlp[02] := {"Roteiro ate?"				,"C"	,TamSX3("C5_ROTEIRO")[1]	,00	,"G"	,0	,aOpc[1]	,"002"	,""		,cRotVld	,"Informe o ROTEIRO final do intervalo"}
	aMensHlp[03] := {"Entrega Entrega?"			,"D"	,008						,00	,"G"	,0	,aOpc[1]	,""		,""		,cRotVld	,"Informe a data inicial de entrega."}
	aMensHlp[04] := {"Status?"					,"N"	,001						,00	,"C"	,1	,aOpc[2]	,""		,""		,cRotVld	,"Informe as op็๕es para o filtro."}

	U_GravaSX1(cPerg,aMensHlp)

Return Nil  



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// Fun็ใo para atualizar o pedido venda เ ordem que esta amarrado a um pedido de remessa
// Sigoli 10/03/2017 Chamado: 034029 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
Static Function AtuaPedVend(cPedRemessa,cPedOrdem)

	Local aArea		:= GetArea() 
	Local aAreaSC5  := SC5->(GetArea())
	Local aAreaSC6  := SC6->(GetArea())
	Local aAreaSC9  := SC9->(GetArea())                                             

	Local cQysc5 	:= "" 
	Local cQysc9 	:= "" 
	Local nVolume1  := ""
	Local nPesol    := ""
	Local nLacre1   := ""
	Local nPbruto   := ""
	Local cProduto  := ""
	Local lAchou 	:= .F.	  		 


	DbSelectArea("SC5")
	dbSetOrder(1) 
	If dbseek(xFilial("SC5")+Alltrim(cPedOrdem))
		If !Empty(SC5->C5_NOTA) 
			MsgAlert(" Pedido de venda เ ordem  "+cPedOrdem+" ja faturado ou eliminado. Por favor, verifique!" )
			Return
		EndIf
	Else
		MsgAlert(" Pedido de venda "+cPedOrdem+" เ orderm nใo localizado" )
		Return
	EndIf

	// monta a query da SC9
	cQysc9 := " SELECT " 
	cQysc9 += " C9_ITEM,C9_PRODUTO,C9_QTDLIB, C9_QTDLIB2 
	cQysc9 += " FROM "+retSqlName("SC9")+" WITH (NOLOCK)"
	cQysc9 += " WHERE  D_E_L_E_T_ = ' ' AND C9_FILIAL = '" + xFilial("SC9") + "' AND C9_PEDIDO = '"+cPedRemessa+"'"  
	TcQuery cQysc9 new alias "QRYC9" 


	// SC6->verifico se o item do pedido nao sofreu corte total
	dbSelectArea("SC6")
	If dbSeek(SC6->C6_FILIAL+Alltrim(cPedOrdem))
		While !Eof() .and. SC6->C6_NUM == Alltrim(cPedOrdem)	

			//@history Chamado 059415 - FWNM         - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consist๊ncias por indefini็๕es de implanta็ใo
			/*
			// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 08/05/2020
			FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
			If FIE->( dbSeek(FWxFilial("FIE")+"R"+SC6->C6_NUM) )

				If AllTrim(Posicione("SC5",1,FWxFilial("SC5")+SC6->C6_NUM,"C5_XWSPAGO")) <> "S"

					QRYC9->( dbSkip() )
					Loop

				EndIf

			EndIf
			*/
			//

			cProduto := SC6->C6_PRODUTO
			lAchou 	 := .F.	  		

			dbSelectArea( "QRYC9" )
			QRYC9->(dbgotop())
			Do While !eof()
				If Alltrim(QRYC9->C9_PRODUTO) == Alltrim(cProduto)
					lAchou := .T.	  		
				EndIf
				dbSelectArea("QRYC9")
				QRYC9->( DbSkip())
			Enddo
			dbSelectArea("SC6")

			If lAchou == .F. //se nao achou o registro/item do pedido delete
				Reclock("SC6",.F.)
				dbdelete()
				Msunlock()
			EndIf  

			SC6->(dbskip())
		Enddo    
	EndIf   

	// SC9->verifico se o o item do pedido nao sofreu corte total
	dbSelectArea("SC9")
	If dbSeek(SC9->C9_FILIAL+Alltrim(cPedOrdem))
		While !Eof() .and. SC9->C9_PEDIDO == Alltrim(cPedOrdem)	
		
			//@history Chamado 059415 - FWNM         - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consist๊ncias por indefini็๕es de implanta็ใo
			/*
			// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 08/05/2020
			FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
			If FIE->( dbSeek(FWxFilial("FIE")+"R"+SC9->C9_PEDIDO) )

				If AllTrim(Posicione("SC5",1,FWxFilial("SC5")+SC9->C9_PEDIDO,"C5_XWSPAGO")) <> "S"

					QRYC9->( dbSkip() )
					Loop

				EndIf

			EndIf
			*/
			//

			cProduto := SC9->C9_PRODUTO
			lAchou 	 := .F.	  		

			dbSelectArea( "QRYC9" )
			QRYC9->(dbgotop())
			Do While !eof()
				If Alltrim(QRYC9->C9_PRODUTO) == Alltrim(cProduto)
					lAchou := .T.	  		
				EndIf
				dbSelectArea("QRYC9")
				QRYC9->( DbSkip())
			Enddo
			dbSelectArea("SC9")

			If lAchou == .F. //se nao achou o registro/item do pedido delete
				Reclock("SC9",.F.)
				dbdelete()
				Msunlock()
			EndIf  

			SC9->(dbskip())
		Enddo    
	EndIf

	//inicio da atuliza็ใo do pedido venda a ordem SC5 E SC6
	dbSelectArea( "QRYC9" )
	QRYC9->(dbgotop())
	Do While !eof()
		
		//@history Chamado 059415 - FWNM         - 12/08/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO - Desfazer consist๊ncias por indefini็๕es de implanta็ใo
		/*
		// Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 08/05/2020
		FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
		If FIE->( dbSeek(FWxFilial("FIE")+"R"+Alltrim(cPedOrdem)) )

			If AllTrim(Posicione("SC5",1,FWxFilial("SC5")+Alltrim(cPedOrdem),"C5_XWSPAGO")) <> "S"

				QRYC9->( dbSkip() )
				Loop

			EndIf

		EndIf
		*/
		//
		
		//atualiza sc6
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(SC6->C6_FILIAL+Alltrim(cPedOrdem))
			While !Eof() .And. SC6->C6_NUM == Alltrim(cPedOrdem)	
				If Alltrim(SC6->C6_PRODUTO) == Alltrim(QRYC9->C9_PRODUTO)
					Reclock("SC6",.F.)
					Replace C6_QTDORI  	With C6_QTDVEN 
					Replace C6_QTDORI2	With C6_UNSVEN
					Replace C6_QTDVEN 	With QRYC9->C9_QTDLIB
					Replace C6_UNSVEN  	With QRYC9->C9_QTDLIB2 
					Replace C6_QTDLIB  	With QRYC9->C9_QTDLIB
					Replace C6_QTDLIB2 	With QRYC9->C9_QTDLIB2
					Replace C6_VALOR   	With C6_QTDVEN * C6_PRCVEN
					Replace C6_QTDEMP   With QRYC9->C9_QTDLIB
					Replace C6_QTDEMP2  With QRYC9->C9_QTDLIB2
					Msunlock()  
				EndIf
				SC6->(dbskip())
			Enddo    
		EndIf

		//atualiza sc9
		dbSelectArea("SC9")
		dbSetOrder(1)
		If dbSeek(SC9->C9_FILIAL+Alltrim(cPedOrdem))
			While !Eof() .And. SC9->C9_PEDIDO == Alltrim(cPedOrdem)	

				If Alltrim(SC9->C9_PRODUTO) == Alltrim(QRYC9->C9_PRODUTO)
					Reclock("SC9",.F.)
					Replace C9_QTDLIB  	With QRYC9->C9_QTDLIB
					Replace C9_QTDLIB2 	With QRYC9->C9_QTDLIB2
					Msunlock()
				EndIf

				SC9->(dbskip())
			Enddo    
		EndIf 

		dbSelectArea("QRYC9")
		QRYC9->( DbSkip())
	Enddo

	dbclosearea( "QRYC9" )

	//atualizar SC5 no final 
	cQysc5 := " SELECT "
	cQysc5 += " C5_VOLUME1,C5_PESOL,C5_NLACRE1,C5_PBRUTO "
	cQysc5 += " FROM "+retSqlName("SC5")+" WITH (NOLOCK)"
	cQysc5 += " WHERE  D_E_L_E_T_ = ' ' AND C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '"+cPedRemessa+"'"  
	TcQuery cQysc5 new alias "QRYC5" 

	dbGoTop()
	dbSelectArea( "QRYC5" )     

	nVolume1 := QRYC5->C5_VOLUME1
	nPesol   := QRYC5->C5_PESOL
	nLacre1  := QRYC5->C5_NLACRE1
	nPbruto  := QRYC5->C5_PBRUTO

	dbclosearea("C5QRY")

	DbSelectArea("SC5")
	dbSetOrder(1) 
	If dbseek(xFilial("SC5")+Alltrim(cPedOrdem))
		RecLock("SC5",.F.)
		Replace C5_VOLUME1 With nVolume1 
		Replace C5_PESOL   With nPesol
		Replace C5_NLACRE1 With nLacre1
		Replace C5_PBRUTO  With nPbruto 
		MsUnlock()
	EndIf


	RestArea(aArea)					    
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSC9)

Return

STATIC FUNCTION SqlSomaPesos(cData,cRoteiro)



	BeginSQL Alias "TRB"
		%NoPARSER%
		SELECT SUM(C5_PESOL) AS C5_PESOL, 
		SUM(C5_PBRUTO) AS C5_PBRUTO
		FROM %Table:SC5%
		WHERE C5_FILIAL   = %EXP:FWFILIAL("SC5")%
		AND C5_DTENTR   = %EXP:cData%
		AND C5_ROTEIRO  = %EXP:cRoteiro%
		AND D_E_L_E_T_ <> '*'

	EndSQl  


RETURN(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlogZBE    บAutor  ณEverson             บ Data ณ  30/05/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gerar log na tabela ZBE.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 044314.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function logZBE(cLog,cParam)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis.                                            |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
	Replace ZBE_FILIAL 	   	With xFilial("ZBE")
	Replace ZBE_DATA 	   	With dDataBase
	Replace ZBE_HORA 	   	With Time()
	Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
	Replace ZBE_LOG	        With cLog
	Replace ZBE->ZBE_PARAME With cParam
	Replace ZBE_MODULO	    With "LOGISTICA"
	Replace ZBE_ROTINA	    With "CCSP_002" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil
