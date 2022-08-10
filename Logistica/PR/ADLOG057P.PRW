#Include "Protheus.ch"
#Include "Xmlxfun.ch"
#Include "Topconn.ch"
#Include "Totvs.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} User Function ADLOG057P
	Emissão de CT-e/MDF-e. Chamado 044314.
	@type  Function
	@author Everson
	@since 22/05/2019
	@version 01
	@history 01/07/19,   Everson, Chamado 044314 Adicionado gravação da averbação da carga.
	@history 25/07/19,   Everson, Chamado 044314 Alterada lógica de complemento de frete.
	@history 25/07/19,   Everson, Chamado 044314 Alterada lógica de reenvio de averbação.
	@history 30/07/19,   Everson, Chamado 044314 Tratamento para baixar PDF do CT-e para anexar no e-mail.
	@history 31/07/19,   Everson, Chamado 044314 Tratamento para geração de CT-e complementar.
	@history 01/08/19,   Everson, Chamado 044314 Adicionada função para emitir CT-e em lote.
	@history 02/08/19,   Everson, Chamado 044314 Corrigido checagem de ICMS.
	@history 08/08/19,   Everson, Chamado 044314 Tratamento para emissão de MDF-e portaria CAT-121.
	@history 12/08/19,   Everson, Chamado 044314 Ajuste na legenda.
	@history 14/08/19,   Everson, Chamado 044314 Adicionado valor do ICMS.
	@history 21/08/19,   Everson, Chamado 044314 Tratamento para verificar ICMS em que o valor do imposto não integra o valor total a ser pago a transportadora.
	@history 04/09/2019, Everson, Chamado 044314 Tratamento envio de código IBGE de início fim do roteiro.
	@history 04/09/2019, Everson, Chamado 044314 (2) Tratamento para clientes sem endereço de entrega cadastrado.
	@history 06/09/2019, Everson, Chamado 044314 Incluída informação de valor de frete na interface de geração de CT-e.
	@history 19/09/2019, Everson, Chamado 044314 Removida opção de reenvio de documentos.
	@history 25/09/2019, Everson, Chamado 044314 Adicionada opção de reenvio de documentos.
	@history 26/09/2019, Everson, Chamado 044314 Adicionado tratamento para quando houver mais de 4 notas na carga e para um único cliente.
	@history 02/10/2019, Everson, Chamado 044314 Tratamento para notas com roteiro mas sem placa.
	@history 14/10/2019, Everson, Chamado 044314 Ordenar registros por transportadora e placa.
	@history 18/10/2019, Everson, Chamado 052772 Tratamento para emissão de MDF-e para estados específicos, mesmo com CT-e emitido pela CAT-121.
	@history 06/11/2019, Everson, Chamado 029058 Tratamento para emissão de CT-e de frango vivo.
	@history 03/12/2019, Everson, Chamado 029058 Tratamento para emissão de CT-e de frango vivo.
	@history 09/12/2019, Everson, Ch:029058 Adicionados checagem se há transação aberta e logs. 
	@history 09/12/2019, Everson, Ch:029058 Adicionados checagem se há transação aberta e logs. 
	@history 11/12/2019, Everson, Ch:029058 Tratamento para emissão de CT-es para estados diferentes de SP. 
	@history 12/12/2019, Everson, Ch:029058 Criada rotina para devolver o percentual aplicado em cima do valor de frete de
								  acordo com o tipo de frete para geração de CT-e.
	@history 16/01/2020, Everson, Ch:054941 - Tratamento para emissão de CT-e de carga de ovos e pintinhos.
	@history 22/01/2020, Everson, Ch:054941 - Tratamento para quando houver erro de comunição (Http invalid).
	@history 24/01/2020, Everson, Ch:054941 - Tratamento para quando houver erro de comunição (Http invalid).
	@history 27/01/2020, Everson, Ch:054941 - Implementação CIOT.
	@history 06/02/2020, Everson, Ch:055434 - Adicionada exportação de arquivo CSV.
	@history 10/02/2020, Everson, Ch:054941 - Tratamento para geração de CT-e de frete de ovos e pintinhos.
	@history 12/02/2020, Everson, Ch:054941 - Tratamento para validar se existe apólice de seguro.
	@history 17/02/2020, Everson, Ch:054941 - Tratamento para validar se existe apólice de seguro, tratamento para geração de documentos para carga de ração.
	@history 02/03/2020, Everson, Ch:053926 - Tratamento para emissão do CIOT.
	@hisotry 06/03/2020, Everson, Ch:054941 - Tratamento para emissão de CT-e para carga de ovos e emissão de CIOT.
	@histoty 09/03/2020, Everson, Ch:054941 - Tratamento obter código da cidade quando o pedido for para fornecedor.
	@history 13/03/2020, Everson, Ch:054941 - Tratamento para obter a posição no array do local de partida do frete. 
	@history 16/03/2020, Everson, Ch:054941 - Correção na obtenção do código IBGE quando a emissão do CT-e utilizar nota de fornecedor.
	@history 12/05/2020, Everson, Ch:054941 - Correção na obtenção de NF quando a emissão do CT-e utilizar nota de fornecedor.
	@history 03/06/2020, Everson, Ch:TI - Tratamento para obter a apólice de seguro de acordo com o tipo de carga.
	@history 14/04/2021, Everson, Ch:12355  - Tratamento para não emitir CT-e globalizado quando a UF da transportadora não estiver no parâmetro MV_#UFTCAT.
	@history 05/05/2021, Everson, Ch:13434  - Limpeza de objeto instanciados.
	@history 20/09/2021, Everson, Ch:15138  - Tratamento para emissão de CT-e adicional.
	@history 12/11/2021, Everson, Ch:63590  - Tratamento para emissão de CT-e adicional.
	@history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
	@history Ticket 70142 - Edvar / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history ticket 71619 - Everson - 20/04/2022 - Tratamento para emissão de MDF-e para transportadoras com CNPJ (SC) mesmo quando há mais de 4 notas na carga.
	@history ticket 70593 - Everson - 20/04/2022 - Adicionado MVs na interface de configuração.
    @history ticket 77749 - Antonio Domingos - 09/08/2022 - invalid property _AMBIENTE on RETCONSCTE(ADLOG057P.PRW) 
/*/
User Function ADLOG057P(nOPc,nTpVa) // U_ADLOG057P()

	//Variáveis.		
	Local aArea	  	:= GetArea()
	Local oInterface 	:= Nil
	Local oPnl1			:= Nil
	Local oPnl2			:= Nil
	Local oPnl3			:= Nil
	Local oPnl4			:= Nil
	Local oPnl5			:= Nil
	Local oPnl6			:= Nil
	Local oPnl7			:= Nil
	Local aTab			:= {}
	Local oTTabs		:= Nil
	Local oGroup1		:= Nil
	Local oConfig		:= Nil
	Local oAtua			:= Nil
	Local oFechar		:= Nil

	Local bMudaAba	 	:= {||	oPnl1:lVisibleControl := (oTTabs:nOption == 1),;
	 					    	oPnl2:lVisibleControl := (oTTabs:nOption == 2),;
	 					    	oPnl3:lVisibleControl := (oTTabs:nOption == 4),;
	 					    	oPnl4:lVisibleControl := (oTTabs:nOption == 3),;
	 					    	oPnl5:lVisibleControl := (oTTabs:nOption == 6),;
	 					    	oPnl6:lVisibleControl := (oTTabs:nOption == 7),;
	 					    	oPnl7:lVisibleControl := (oTTabs:nOption == 5),;
								oPnl8:lVisibleControl := (oTTabs:nOption == 8),;
								oPnl9:lVisibleControl := (oTTabs:nOption == 9),; //Everson - 06/03/2020. Chamado 054941.
	 					    	oLeg:lVisibleControl  := (oTTabs:nOption == 1 .Or. oTTabs:nOption == 2 .Or. oTTabs:nOption == 4 .Or. oTTabs:nOption == 6 .Or. oTTabs:nOption == 8 ),;
								oCSV:lVisibleControl  := (oTTabs:nOption == 1),; //Everson - 06/02/2020. Chamado 055434. 
	 					    	oAtua:lVisibleControl := (oTTabs:nOption == 1),;
	 					    	oConfig:lVisibleControl := (oTTabs:nOption == 1),;
	 					    	Iif(oTTabs:nOption == 1,Eval({|| carInter1("1"), Iif(nPosCarga > 0,oCargas:GoTo(nPosCarga),Nil), oCargas:Refresh() }),Nil),;
	 					    	Iif(;
								 	oTTabs:nOption == 2,carDocs(oTTabs:nOption == 2,"1"),;
									 	Iif(oTTabs:nOption == 4,carDocs(oTTabs:nOption == 4,"2"),;
	 					    				Iif(oTTabs:nOption == 3,carDocs(oTTabs:nOption == 3,"3"),;
											 	Iif(oTTabs:nOption == 7,carDocs(oTTabs:nOption == 7,"4"),;
	 					    						Iif(oTTabs:nOption == 5,carInter1("2"),;
														Iif(oTTabs:nOption == 6,carPedCC(),;
															Iif(oTTabs:nOption == 8,carDocs(oTTabs:nOption == 8,"5"),;
																Iif(oTTabs:nOption == 9,carDocs(oTTabs:nOption == 9,"6"),;
																	Nil;
																	);
																);
															);
														);
													);
								 				);
										 	);
								 	);
	 					    }

	Local oLeg			:= Nil

	Local oCSV			:= Nil //Everson - 06/02/2020. Chamado 055434.
	
	Private oCargas	 	:= Nil
	Private aHCr	    := {}
	Private aColsCr	 	:= {} 	
	Private oDocs		:= Nil
	Private aHDc		:= {}
	Private aColsDc		:= {}	
	Private oDocsM		:= Nil
	Private aHDcM		:= {}
	Private aColsDcM	:= {}	
	Private oVerb		:= Nil
	Private aHAv		:= {}
	Private aColsAv		:= {}	
	Private oTxtCTe		:= Nil
	Private oTxtAveb	:= Nil
	Private oTxTMDF		:= Nil
	Private oPendMDF	:= Nil
	Private aHDcMP		:= {}
	Private aColsDcMP	:= {}
	Private oEmitMP		:= Nil
	Private aHDcPEM		:= {}
	Private aColsDcME	:= {}
	Private aFilDocs	:= {}
	Private cFilDocs	:= ""
	Private oFilDocs	:= Nil
	Private aHCrCC		:= {}
	Private oEmitCC		:= Nil
	Private aColsEmCC	:= {}
	Private nPosCarga	:= 0
	Private oPnl8		:= Nil
	Private oTxTMCIO	:= Nil
	Private aHDcC		:= {}
	Private oDocsC		:= Nil
	Private aColsDcC	:= {}

	//Everson - 06/03/2020. Chamado 054941.
	Private oPnl9		:= Nil
	Private aHDcCI		:= {}
	Private oPendCIO	:= Nil
	Private aColsDCI	:= {}
	//

	Private cTpVa 		:= Alltrim(cValToChar(nTpVa)) //Everson - 06/11/2019. Chamado 029058.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')

	//Everson - 06/11/2019. Chamado 029058.
	If Empty(cTpVa) .Or. cTpVa == "0"
		MsgStop("Não foi possível obter o tipo de carga.","Função ADLOG057P")
		RestArea(aArea)
		Return Nil 

	EndIf

	//Seleciona o tipo de frete Abatido, Ração, etc...
	If ! Pergunte("OPHOS1",.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf
			
	//
	oInterface			 := MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Emissão de Documentos Fiscais de Transporte"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1200
	oInterface:nHeight   := 550
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.
	
		//
		aTab   := {"Cargas","CT-e","Averbação","MDF-e","Pendência Gerar MDF-e","CT-e Adicional","Pendência Encerrar MDF-e","CIOT","Pendência Encerrar CIOT"}
		oTTabs := TTabs():New(001,001,aTab,Nil,oInterface,Nil,CLR_HRED,Nil,.T.,Nil,595,235,Nil)
		oTTabs:SetOption(1)
			oPnl1 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.) //Cargas.
				
				//
				Aadd(aHCr,{" ","LEG"    	,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})		
				Aadd(aHCr,{"DT Entrega" 	,"CRDTE","" ,008, 0,"","" ,"D","",""})
				Aadd(aHCr,{"Roteiro"   		,"CRROT","" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})
				Aadd(aHCr,{"Veículo" 		,"CRVEI","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Qtd. NF"    	,"CRNNF"	,"@E 999" ,3, 0,"","" ,"N","",""})
				Aadd(aHCr,{"Cód Transp" 	,"CRTRA","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Lj Transp" 		,"CRLOJ","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Nm Transp" 		,"CRNMT","" ,025, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Ocorrência" 	,"CROCO","" ,003, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Desc Ocorr" 	,"CRDES","" ,025, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Valor"          ,"CRVALOR"	,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""}) //Everson   ³06/09/2019³044314³.
				Aadd(aHCr,{"CT-e"   		,"CRCTE","" ,010, 0,"","" ,"C","",""})
				Aadd(aHCr,{"MDF-e"   		,"CRMDF","" ,010, 0,"","" ,"C","",""})
				Aadd(aHCr,{"CIOT"   		,"CRCIO","" ,010, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Cod ZFA" 		,"CRZFA","" ,010, 0,"","" ,"C","",""})
				Aadd(aHCr,{"Carga" 			,"CRCAR","" ,006, 0,"","" ,"C","",""})
				
				oCargas := MsNewGetDados():New(001,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl1,aHCr,@aColsCr)
				
				aFilDocs:= {'1=Todos','2=Pendente CT-e','3=Pendente MDF-e','4=Pendente CIOT'}
				cFilDocs:= aFilDocs[1]
		        oFilDocs := TComboBox():New(010,508,{|u|if(PCount()>0,cFilDocs:=u,cFilDocs)},;
		        aFilDocs,80,15,oPnl1,,{|| MsAguarde({ || carInter1("1") },"Aguarde","Carregando dados...") };
		        ,,,,.T.,,,,,,,,,'cFilDocs')
        
				//
				TButton():New(030,508,"Gerar CT-e"         ,oPnl1,{|| nPosCarga := oCargas:nAt, Iif(nPosCarga > 0,oCargas:GoTo(nPosCarga),Nil), gerCte(aHCr,oCargas), carInter1("1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(050,508,"Gerar CT-e em Lote" ,oPnl1,{||;
																	gerCteLT(aHCr, oCargas),; //Gera CT-e em lote.
																	carInter1("1"),; //Atualiza grid.
																	oCargas:Refresh(); //Atualiza o objeto grid.
																   },80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson   ³01/08/19³044314.
				
				TButton():New(070,508,"Gerar MDF-e"        ,oPnl1,{|| nPosCarga := oCargas:nAt, Iif(nPosCarga > 0,oCargas:GoTo(nPosCarga),Nil), gerMDFE(aHCr,oCargas), carInter1("1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 27/01/2020. Chamado 054941.
				
				//TButton():New(090,508,"Gerar CIOT"         ,oPnl1,{|| nPosCarga := oCargas:nAt, carInter1("1"), Iif(nPosCarga > 0,oCargas:GoTo(nPosCarga),Nil), gerCIOT(aHCr,oCargas), carInter1("1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 27/01/2020. Chamado 054941.
				//TButton():New(110,508,"Gerar CIOT em Lote" ,oPnl1,{|| gerCioL() },80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson - 27/01/2020. Chamado 054941.

				TButton():New(130,508,"Consultar Empresa",oPnl1,{|| conEmpresa(oCargas,aHCr) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) 
				
				TButton():New(150,508,"Reenv. Rot (CT-e)" ,oPnl1, {|| nPosCarga := oCargas:nAt, Iif(nPosCarga > 0,oCargas:GoTo(nPosCarga),Nil), reenvRot(aHCr,oCargas,"1"), carInter1("1") } ,80, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //Everson - 25/09/2019. Chamado 044314.
				TButton():New(170,508,"Reenv. Rot (MDF-e)",oPnl1, {|| nPosCarga := oCargas:nAt, Iif(nPosCarga > 0,oCargas:GoTo(nPosCarga),Nil), reenvRot(aHCr,oCargas,"2"), carInter1("1") } ,80, 15,,,.F.,.T.,.F.,,.F.,,,.F.) //Everson - 25/09/2019. Chamado 044314.

			oPnl2 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.) //CT-e.
				
				//
				oTxtCTe := TSay():New(001,002,{||'Funções do CT-e'},oPnl2,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
				
				//
				Aadd(aHDc,{" ","LEG"    	,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})
				Aadd(aHDc,{"DT Entrega" 	,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
				Aadd(aHDc,{"Roteiro"   		,"CRROT"    ,"" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})

				//Everson - 20/09/2021. Chamado 15138.
				Aadd(aHDc,{"Cód Transp"   	,"CRTRA" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Lj Transp"   	,"CRLOJ" 	,"" ,002, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Nm Transp" 		,"CRNMT","" ,025, 0,"","" ,"C","",""})
				//

				Aadd(aHDc,{"Tipo Doc"   	,"CRTPDOC" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Num Doc" 		,"CRNUMDOC"	,"" ,009, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Série" 			,"CRSRDOC" 	,"" ,003, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Seq Env" 		,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Valor"    		,"CRVALOR"	,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})	
				Aadd(aHDc,{"ICMS"    		,"CRICMS"	,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""}) //Everson³14/08/19³044314.			
				Aadd(aHDc,{"Mensagem" 		,"CROPHOS"	,"" ,100, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Hash" 			,"CRHASH"	,""  ,030, 0,"","" ,"C","",""})				
				Aadd(aHDc,{"Chave"   		,"CRCHAVE"	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Prot Emissão"	,"CRPEMI" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Prot Cancela"	,"CRPCAN" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Prot Encerra"	,"CRPENC"	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDc,{"Ped Compra"		,"CRPEDC"	,"" ,006, 0,"","" ,"C","",""})
			
				oDocs := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl2,aHDc,@aColsDc)
				
				//
				TButton():New(010,508,"Consultar/Atualizar CT-e"	,oPnl2,{|| funcHash(1,"1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(030,508,"Download DACTE"    			,oPnl2,{|| funcHash(2,"1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(050,508,"Download XML"    			,oPnl2,{|| funcHash(3,"1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(070,508,"Cancelar CT-e"    			,oPnl2,{|| funcHash(4,"1") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(090,508,"Reenviar averbação" 			,oPnl2,{|| reenAvb( ) },80,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //Everson   ³25/07/19³044314.
				
			oPnl4 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.) //Averbação.

				//
				oTxtAveb := TSay():New(001,002,{||'Averbação'},oPnl4,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
								
				//
				Aadd(aHAv,{"DT Entrega" 	,"CRDTE"	,"" ,008, 0,"","" ,"D","",""})
				Aadd(aHAv,{"Roteiro"   		,"CRROT"	,"" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})

				//Everson - 20/09/2021. Chamado 15138.
				Aadd(aHAv,{"Cód Transp"   	,"CRTRA" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Lj Transp"   	,"CRLOJ" 	,"" ,002, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Nm Transp" 		,"CRNMT"    ,"" ,025, 0,"","" ,"C","",""})
				//

				Aadd(aHAv,{"Tipo Doc"   	,"CRTPDOC" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Nota Fiscal" 	,"CRNUMDOC"	,"" ,009, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Série" 			,"CRSRDOC" 	,"" ,003, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})			
				Aadd(aHAv,{"Mensagem" 		,"CROPHOS"	,"" ,050, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Num Averba"		,"CRPENC"	,"" ,050, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Prot Averba"	,"CRPAVE"	,"" ,050, 0,"","" ,"C","",""})
				Aadd(aHAv,{"Hash CT-e" 		,"CRHASH"	,"" ,030, 0,"","" ,"C","",""})
				
				oVerb := MsNewGetDados():New(010,002,205,590,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl4,aHAv,@aColsAv)
											
			oPnl3 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)	//MDF-e.

				//
				oTxTMDF := TSay():New(001,002,{||'Funções do MDF-e'},oPnl3,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
							
				//
				Aadd(aHDcM,{" ","LEG"    	,"@BMP"     ,001,  0,.T.,"","","","R","","",.F.,"V","","","",""})
				Aadd(aHDcM,{"DT Entrega" 	,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
				Aadd(aHDcM,{"Roteiro"   	,"CRROT"    ,"" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})

				//Everson - 20/09/2021. Chamado 15138.
				Aadd(aHDcM,{"Cód Transp"   	,"CRTRA" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Lj Transp"   	,"CRLOJ" 	,"" ,002, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Nm Transp" 		,"CRNMT"    ,"" ,025, 0,"","" ,"C","",""})
				//

				Aadd(aHDcM,{"Tipo Doc"   	,"CRTPDOC" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Num Doc" 		,"CRNUMDOC"	,"" ,009, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Série" 		,"CRSRDOC" 	,"" ,003, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Seq Env" 		,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})		
				Aadd(aHDcM,{"Mensagem" 		,"CROPHOS"	,"" ,100, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Hash" 			,"CRHASH"	,"" ,030, 0,"","" ,"C","",""})				
				Aadd(aHDcM,{"Chave"   		,"CRCHAVE"	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Prot Emissão"	,"CRPEMI" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Prot Cancela"	,"CRPCAN" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcM,{"Prot Encerra"	,"CRPENC"	,"" ,030, 0,"","" ,"C","",""})
				
				oDocsM := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl3,aHDcM,@aColsDcM)
							
				//
				TButton():New(010,508,"Consultar/Atualizar MDF-e" 	,oPnl3,{|| funcHash(5,"2") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(030,508,"Encerrar MDF-e"    			,oPnl3,{|| funcHash(6,"2") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(050,508,"Download DAMDFE"    			,oPnl3,{|| funcHash(7,"2") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(070,508,"Download XML"    			,oPnl3,{|| funcHash(8,"2") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(090,508,"Cancelar MDF-e"    			,oPnl3,{|| funcHash(9,"2") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				
			oPnl7 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)
				
				//
				TSay():New(001,002,{||'Pendências de emissão de MDF-e'},oPnl7,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)

				//
				Aadd(aHDcPEM,{" ","LEG"    		,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})		
				Aadd(aHDcPEM,{"DT Entrega" 		,"CRDTE","" ,008, 0,"","" ,"D","",""})
				Aadd(aHDcPEM,{"Roteiro"   		,"CRROT","" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Veículo" 		,"CRVEI","" ,008, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Cód Transp" 		,"CRTRA","" ,008, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Lj Transp" 		,"CRLOJ","" ,008, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Nm Transp" 		,"CRNMT","" ,025, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Ocorrência" 		,"CROCO","" ,003, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Desc Ocorr" 		,"CRDES","" ,025, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"CT-e"   			,"CRCTE","" ,010, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"MDF-e"   		,"CRMDF","" ,010, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Cod ZFA" 		,"CRZFA","" ,010, 0,"","" ,"C","",""})
				Aadd(aHDcPEM,{"Carga" 			,"CRCAR","" ,006, 0,"","" ,"C","",""})
				
				oEmitMP := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl7,aHDcPEM,@aColsDcME)				
				
				//
				TButton():New(010,508,"Gerar MDF-e Lote"  ,oPnl7,{|| carDocs( .T.,"2"), emiMDFL(), carInter1("2") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				
			oPnl5 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)

				//
				TSay():New(001,002,{||'Pendências de geração de CT-e adicional'},oPnl5,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
							
				//	
				Aadd(aHCrCC,{" ","LEG"    	,"@BMP"     ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})
				Aadd(aHCrCC,{"Data" 	    ,"CRDTA","" ,008, 0,"","" ,"D","",""})
				Aadd(aHCrCC,{"Carga" 		,"CRCAR","" ,006, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Cód Transp" 	,"CRTRA","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Lj Transp" 	,"CRLOJ","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Nm Transp" 	,"CRNMT","" ,025, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Veículo" 		,"CRVEI","" ,008, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"DT Entrega" 	,"CRDTE","" ,008, 0,"","" ,"D","",""})
				Aadd(aHCrCC,{"Roteiro"   	,"CRROT","" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Ocorrência" 	,"CROCO","" ,003, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Desc Ocorr" 	,"CRDES","" ,025, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Valor"    	,"CRVALOR"	,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
				Aadd(aHCrCC,{"Qtd CT-e"    	,"CRQTDC"	,"@E 999,999,999"    ,03, 0,"","" ,"N","",""})	
				Aadd(aHCrCC,{"Cod ZFA" 		,"CRZFA","" ,010, 0,"","" ,"C","",""})
				Aadd(aHCrCC,{"Emitido?"     ,"CRCTE","" ,002, 0,"","" ,"C","",""})
				
				//				
				oEmitCC := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl5,aHCrCC,@aColsEmCC)
								
				//Everson - 20/09/2021. Chamado 15138.
				TButton():New(010,508,"Gerar CT-e"         , oPnl5,{|| nPosCarga := oEmitCC:nAt, Iif(nPosCarga > 0,oEmitCC:GoTo(nPosCarga),Nil), gerCte(aHCrCC,oEmitCC), carPedCC() },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				TButton():New(030,508,"Gerar CT-e em Lote" , oPnl5,{||;
																	gerCteLT(aHCrCC, oEmitCC),;
																	carPedCC(),;
																	oEmitCC:Refresh();
																   },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				//
			
			oPnl6 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)
				
				//
				TSay():New(001,002,{||'MDF-e pendente de encerramento'},oPnl6,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)

				//
				Aadd(aHDcMP,{"DT Entrega" 	,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
				Aadd(aHDcMP,{"Roteiro"   	,"CRROT"    ,"" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})
				Aadd(aHDcMP,{"Veículo" 		,"CRVEI"    ,"" ,008, 0,"","" ,"C","",""})
				Aadd(aHDcMP,{"Num Doc" 		,"CRNUMDOC"	,"" ,009, 0,"","" ,"C","",""})
				Aadd(aHDcMP,{"Série" 		,"CRSRDOC" 	,"" ,003, 0,"","" ,"C","",""})
				Aadd(aHDcMP,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDcMP,{"Seq Env" 		,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})		
				Aadd(aHDcMP,{"Mensagem" 	,"CROPHOS"	,"" ,100, 0,"","" ,"C","",""})
				Aadd(aHDcMP,{"Hash" 		,"CRHASH"	,"" ,030, 0,"","" ,"C","",""})
				
				oPendMDF := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl6,aHDcMP,@aColsDcMP)
								
				//
				TButton():New(010,508,"Encerrar MDF-e em Lote" ,oPnl6,{|| encMDFL(), carDocs(.T.,"4") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )

			oPnl8 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)	

				//
				oTxTMCIO := TSay():New(001,002,{||'Funções do CIOT'},oPnl8,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
							
				//
				Aadd(aHDcC,{" ","LEG"    	,"@BMP"     ,001,  0,.T.,"","","","R","","",.F.,"V","","","",""})
				Aadd(aHDcC,{"DT Entrega" 	,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
				Aadd(aHDcC,{"Roteiro"   	,"CRROT"    ,"" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})

				//Everson - 20/09/2021. Chamado 15138.
				Aadd(aHDcC,{"Cód Transp"    ,"CRTRA" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Lj Transp"   	,"CRLOJ" 	,"" ,002, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Nm Transp" 	,"CRNMT"    ,"" ,025, 0,"","" ,"C","",""})
				//

				Aadd(aHDcC,{"Tipo Doc"   	,"CRTPDOC" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Num Doc" 		,"CRNUMDOC"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Seq Env" 		,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})		
				Aadd(aHDcC,{"Mensagem" 		,"CROPHOS"	,"" ,100, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Hash" 			,"CRHASH"	,"" ,030, 0,"","" ,"C","",""})				
				Aadd(aHDcC,{"Prot Emissão"	,"CRPEMI" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Prot Cancela"	,"CRPCAN" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcC,{"Prot Encerra"	,"CRPENC"	,"" ,030, 0,"","" ,"C","",""})
				
				oDocsC := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl8,aHDcC,@aColsDcC)
							
				//
				//TButton():New(010,508,"Consultar/Atualizar CIOT" 	,oPnl8,{|| funcHash(10,"5") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				//TButton():New(030,508,"Encerrar CIOT"    			,oPnl8,{|| funcHash(14,"5") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				//TButton():New(050,508,"Download PDF"    			,oPnl8,{|| funcHash(11,"5") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				//TButton():New(070,508,"Download XML"    			,oPnl8,{|| funcHash(12,"5") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
				//TButton():New(070,508,"Cancelar CIOT"    			,oPnl8,{|| funcHash(13,"5") },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )

			oPnl9 := TPanel():New(001,001,,oTTabs,,.T.,,CLR_BLACK,CLR_WHITE,593,210,,.T.)
				
				//
				TSay():New(001,002,{||'CIOT pendente de encerramento'},oPnl9,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)

				//
				Aadd(aHDcCI,{" ","LEG"    	,"@BMP"     ,001,  0,.T.,"","","","R","","",.F.,"V","","","",""})
				Aadd(aHDcCI,{"DT Entrega" 	,"CRDTE"    ,"" ,008, 0,"","" ,"D","",""})
				Aadd(aHDcCI,{"Roteiro"   	,"CRROT"    ,"" ,TamSX3("ZFK_ROTEIR")[1], 0,"","" ,"C","",""})

				//Everson - 20/09/2021. Chamado 15138.
				Aadd(aHDcCI,{"Cód Transp"   ,"CRTRA" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Lj Transp"   	,"CRLOJ" 	,"" ,002, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Nm Transp" 	,"CRNMT"    ,"" ,025, 0,"","" ,"C","",""})
				//

				Aadd(aHDcCI,{"Tipo Doc"   	,"CRTPDOC" 	,"" ,006, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Num Doc" 		,"CRNUMDOC"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Status" 		,"CRSTATUS"	,"" ,020, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Seq Env" 		,"CRSEQENV"	,"" ,004, 0,"","" ,"C","",""})		
				Aadd(aHDcCI,{"Mensagem" 	,"CROPHOS"	,"" ,100, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Hash" 		,"CRHASH"	,"" ,030, 0,"","" ,"C","",""})				
				Aadd(aHDcCI,{"Prot Emissão"	,"CRPEMI" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Prot Cancela"	,"CRPCAN" 	,"" ,030, 0,"","" ,"C","",""})
				Aadd(aHDcCI,{"Prot Encerra"	,"CRPENC"	,"" ,030, 0,"","" ,"C","",""})
				
				oPendCIO := MsNewGetDados():New(010,002,205,505,,"Allwaystrue()","Allwaystrue()","",{},Nil,999,Nil,Nil,Nil,oPnl9,aHDcCI,@aColsDCI)
								
				//
				//TButton():New(010,508,"Encerrar CIOT em Lote" ,oPnl9,{|| encCIOL() },80,15,,,.F.,.T.,.F.,,.F.,,,.F. )
								
		//
		oGroup1	 := TGroup():Create(oInterface,239,005,260,595,"",,,.T.)
		
			//
			oLeg := TButton():New(245,010,"Legenda"    ,oInterface,{|| U_adlog574(oTTabs:nOption) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )	
			oLeg:lVisibleControl := (oTTabs:nOption == 1 .Or. oTTabs:nOption == 2 .Or. oTTabs:nOption == 4 .Or. oTTabs:nOption == 6 .Or. oTTabs:nOption == 8) //Everson - 06/03/2020. Chamado 054941.

			//Everson - 06/02/2020. Chamado 055434.
			oCSV := TButton():New(245,055,"CSV"    ,oInterface,{|| MsAguarde({|| grCSV(oCargas,aHCr)},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )	
			oCSV:lVisibleControl := (oTTabs:nOption == 1)
							
			//
			oAtua    := TButton():New(245,460,"Atualizar" ,oInterface,{|| Iif( Pergunte("OPHOS1",.T.), carInter1("1"), Nil) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			oAtua:lVisibleControl := (oTTabs:nOption == 1)
			oConfig	 := TButton():New(245,505,"Config"    ,oInterface,{|| cfgMV() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			If ! FWIsAdmin()
				oConfig:Disable()
			
			EndIf 
			oConfig:lVisibleControl := (oTTabs:nOption == 1)
			oFechar	 := TButton():New(245,550,"Fechar"    ,oInterface,{||oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
				oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
	
		//
		oTTabs:bAction := bMudaAba
		Eval(bMudaAba)
		
	oInterface:Activate(,,,.T.,{||.T.},,{|| carInter1("1") })

	//
	RestArea(aArea)
		
Return Nil
/*/{Protheus.doc} carInter1  
	Carrega dados de roteiros para emissão de documentos. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   18/06/2019
	@version 01
	/*/
Static Function carInter1(cOPc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nPorc		:= getPorEm(cTpVa)/100//Val(cValToChar(GetMv("MV_#CTEPOR")))/100 //Everson - 12/12/2019 - Chamado 029058.
	Local cDataIni	:= DToS(MV_PAR01)
	Local cDataFim	:= DToS(MV_PAR02)
	Local cTransIni	:= Alltrim(cValToChar(MV_PAR03))
	Local cLojaDe	:= Alltrim(cValToChar(MV_PAR04))
	Local cTransFim	:= Alltrim(cValToChar(MV_PAR05))
	Local cLojaAte	:= Alltrim(cValToChar(MV_PAR06))
	Local cVecIni	:= Alltrim(cValToChar(MV_PAR07))
	Local cVecFim	:= Alltrim(cValToChar(MV_PAR08))
	Local cRotIni	:= Alltrim(cValToChar(MV_PAR09))
	Local cRotFim	:= Alltrim(cValToChar(MV_PAR10))
	Local oCor		:= Nil
	Local cCte		:= ""
	Local cMDF		:= ""
	Local nTopPend	:= 0
	Local nTotNf	:= GetMv("MV_#QTDNFE") //Everson-08/08/19-044314.
	
	Local oVerme	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oVerde	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")
	Local cEstado	:= Alltrim(cValToChar(GetMv("MV_#ESTMDF",,"'RJ'")))

	Local cGerMDF	:= Separa(Alltrim(GetMv("MV_#ESGRMD",,"S/N/N/N/N")),"/",.T.)[Val(cTpVa)] //Everson - 03/12/2019 - Chamado 029058.
	Local cCiot		:= "" //Everson - 06/03/2020. Chamado 054941.
	Local lNRegMDF	:= .T. //Everson - 06/03/2020. Chamado 054941.
	Local cGerCIO	:= Separa(Alltrim(GetMv("MV_#ESGRCI",,"S/S/S/S/S")),"/",.T.)[Val(cTpVa)] //Everson - 06/03/2020. Chamado 054941.
	Local lNRegCio	:= .T.//Everson - 06/03/2020. Chamado 054941.
	Local cGerCCT	:= Separa(Alltrim(GetMv("MV_#ESGRCT",,"S/S/S/S/S")),"/",.T.)[Val(cTpVa)] //Everson - 06/03/2020. Chamado 054941.
	Local lNRegCCT	:= .T.//Everson - 06/03/2020. Chamado 054941.

	//Everson - 20/04/2022 - Chamado 71619.
	Local cEstTran	:= ""
	Local cTrapMDF  := GetMv("MV_#UFTCAM",,"SC") 
	Local lGerMDF   := .F.
	//
	
	//
	If cOPc == "1" //Dados de CT-e.
		
		//
		oCargas:aCols := {}
		Aadd(oCargas:aCols , Array(Len(aHCr) + 1) )
		oCargas:aCols[Len(oCargas:aCols), Len(oCargas:aCols[1]) ] := .F.	
		oCargas:Refresh()
		
		//Valida o percentual do valor de frete.
		If nPorc <= 0
			MsgStop("Não foi possível carregar o percentual do valor de frete que será considerado na geração do CT-e (MV MV_#CTEPOR)","Função carInter1(ADLOG057P)")
			logZBE("Função carInter1: NAO OBTEVE O PERCENTUAL DO VALOR DE FRETE QUE SERA CONSIDERADO NA GERACAO DO CT-E MV MV_#CTEPOR")
			RestArea(aArea)
			Return Nil
	
		EndIf
		
	ElseIf cOPc == "2" //Dados MDF-e. 

		//
		oEmitMP:aCols := {}
		Aadd(oEmitMP:aCols , Array(Len(aHCr) + 1) )
		oEmitMP:aCols[Len(oEmitMP:aCols), Len(oEmitMP:aCols[1]) ] := .F.	
		oEmitMP:Refresh()
			
	EndIf

	//
	cQuery := "" 
	cQuery += " SELECT  " 
	cQuery += " ZFA_FILIAL, ZFA_VA, ZFA_DTENTR, ZFA_ROTEIR,  " 
	cQuery += " ZFA_TRANPA, ZFA_LJPPAG,  " 
	cQuery += " ZFA_NMTPAG, ZFA_VEICUL, ZFA_OCORRE,  " 
	cQuery += " ZFA_DESCOC, ZFA_VALOR, ZFA_COD, ZFA_CARGA, " 
	cQuery += " LTRIM(RTRIM(ZFA_CTE))  +' '+ LTRIM(RTRIM(ZFA_SRCTE))  AS CTE, " 
	cQuery += " LTRIM(RTRIM(ZFA_MDFE)) +' '+ LTRIM(RTRIM(ZFA_SRMDFE)) AS MDF, CHKNF.QTD_NOTA, CHKNF.CHKCLI, CHKEST.CHKEST "
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
		
	//Everson - 17/02/2020. Chamado 054941.
	If cTpVa == "1"
		cQuery += " LEFT OUTER JOIN "
		//Everson   ³26/09/2019³044314.
		cQuery += " ( SELECT COUNT(DISTINCT RTRIM(LTRIM(C5_CLIENTE))+RTRIM(LTRIM(C5_LOJACLI)))  AS CHKCLI , C5_FILIAL, C5_DTENTR, C5_ROTEIRO, COUNT(DISTINCT C5_NOTA + C5_SERIE) AS QTD_NOTA FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND C5_DTENTR BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND C5_NOTA <> '' AND C5_SERIE <> '' AND SC5.D_E_L_E_T_ = '' GROUP BY C5_FILIAL, C5_DTENTR, C5_ROTEIRO ) AS CHKNF ON "
		cQuery += " ZFA_FILIAL = CHKNF.C5_FILIAL "
		cQuery += " AND ZFA_DTENTR = CHKNF.C5_DTENTR "
		cQuery += " AND ZFA_ROTEIR = CHKNF.C5_ROTEIRO "

	ElseIf cTpVa == "2"
		
		//
		cQuery += " LEFT OUTER JOIN "
		cQuery += " ( "
		cQuery += " SELECT   " 
			cQuery += " ZFC_FILIAL, ZFC_DTAPRE, ZFC_NUMERO, COUNT(DISTINCT F2_DOC + F2_SERIE) AS QTD_NOTA, COUNT(DISTINCT F2_CLIENTE + F2_LOJA)  AS CHKCLI " //Everson - 17/02/2020. Chamado 054941.
			cQuery += " FROM   " 
			cQuery += " " + RetSqlName("ZV1") + " (NOLOCK) AS ZV1   " 
			cQuery += " INNER JOIN " 
			cQuery += " " + RetSqlName("ZFC") + " (NOLOCK) AS ZFC ON " 
			cQuery += " ZV1_NUMOC = ZFC_NUMERO " 
			cQuery += " INNER JOIN   " 
			cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 ON   " 
			cQuery += " RIGHT('000000000' + RTRIM(LTRIM(ZFC_NF)),9) = F2_DOC   " 
			cQuery += " AND RIGHT('00' + RTRIM(LTRIM(ZFC_SERIE)),2) = F2_SERIE   " 
			cQuery += " INNER JOIN  " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON   " 
			cQuery += " F2_FILIAL = C5_FILIAL   " 
			cQuery += " AND F2_DOC = C5_NOTA   " 
			cQuery += " AND F2_SERIE = C5_SERIE   " 
			cQuery += " WHERE   " 
			//cQuery += " ZV1_FILIAL = '  '   " 
			cQuery += " ZV1_FILIAL = '"+FWxFilial("ZV1")+"' " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
			cQuery += " AND F2_FILIAL = '" + FWxFilial("SF2") + "'   " 
			cQuery += " AND ZFC_NUMERO  BETWEEN'"  + cRotIni  + "' AND '" + cRotFim  + "' " 
			cQuery += " AND ZFC_DTAPRE  BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' " 
			cQuery += " AND ZV1.D_E_L_E_T_ = ''   " 
			cQuery += " AND SF2.D_E_L_E_T_ = ''   " 
			cQuery += " AND SC5.D_E_L_E_T_ = '' " 
			cQuery += " AND ZFC.D_E_L_E_T_ = '' 
			cQuery += " GROUP BY ZFC_FILIAL, ZFC_DTAPRE, ZFC_NUMERO "
		cQuery += " )AS CHKNF ON "
		cQuery += " ZFA_CARGA = CHKNF.ZFC_NUMERO "

	ElseIf cTpVa == "3" .Or. cTpVa == "4" .Or. cTpVa == "5"

		//
		cQuery += " LEFT OUTER JOIN "
		cQuery += " ( " 
			cQuery += " SELECT ZFD_FILIAL, ZFD_COD,COUNT(DISTINCT RTRIM(LTRIM(C5_CLIENTE))+RTRIM(LTRIM(C5_LOJACLI)))  AS CHKCLI , "
			cQuery += " C5_FILIAL, C5_DTENTR, C5_ROTEIRO, COUNT(DISTINCT C5_NOTA + C5_SERIE) AS QTD_NOTA "
			cQuery += " FROM " 
			cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
			cQuery += " INNER JOIN "
			cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD ON "
			cQuery += " C5_FILIAL = ZFD_FILIAL "
			cQuery += " AND C5_NUM = ZFD_PEDIDO "
			cQuery += " WHERE "
			cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' "
			cQuery += " AND ZFD_DTENTR BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
			cQuery += " AND ZFD_COD    BETWEEN'"  + cRotIni  + "' AND '" + cRotFim  + "' "
			cQuery += " AND C5_NOTA <> '' "
			cQuery += " AND C5_SERIE <> '' "
			cQuery += " AND SC5.D_E_L_E_T_ = '' "
			cQuery += " AND ZFD.D_E_L_E_T_ = '' "
			cQuery += " GROUP BY C5_FILIAL, C5_DTENTR, C5_ROTEIRO, ZFD_FILIAL, ZFD_COD " 
		cQuery += " ) AS CHKNF ON "
		cQuery += " ZFA_FILIAL = CHKNF.ZFD_FILIAL "
		cQuery += " AND ZFA_CARGA = CHKNF.ZFD_COD "

	EndIf
	//
	
	//Everson   ³18/10/2019³052772.
	cQuery += " LEFT OUTER JOIN "
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " COUNT(DISTINCT RTRIM(LTRIM(C5_CLIENTE))+RTRIM(LTRIM(C5_LOJACLI)))  AS CHKEST , " 
	cQuery += " C5_FILIAL, C5_DTENTR, C5_ROTEIRO, " 
	cQuery += " COUNT(DISTINCT C5_NOTA + C5_SERIE) AS QTD_NOTA " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 "
	cQuery += " LEFT OUTER JOIN "
	cQuery += " (SELECT A1_COD, A1_LOJA, CASE WHEN A1_ESTE = '' OR A1_ESTE IS NULL THEN A1_EST ELSE A1_ESTE END AS A1_EST FROM " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE A1_FILIAL = '" + FWxFilial("SA1") + "' AND SA1.D_E_L_E_T_ = '') AS SA1 ON "
	cQuery += " SC5.C5_CLIENTE = SA1.A1_COD "
	cQuery += " AND SC5.C5_LOJACLI = SA1.A1_LOJA " 
	cQuery += " WHERE " 
	cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	cQuery += " AND C5_DTENTR BETWEEN '" + cDataIni  + "' AND '" + cDataFim  + "' " 
	cQuery += " AND C5_NOTA <> '' AND C5_SERIE <> '' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " AND SA1.A1_EST IN (" + cEstado + ") "
	cQuery += " GROUP BY " 
	cQuery += " C5_FILIAL, C5_DTENTR, C5_ROTEIRO " 
	cQuery += " ) AS CHKEST ON " 
	cQuery += " ZFA_FILIAL = CHKEST.C5_FILIAL " 
	cQuery += " AND ZFA_DTENTR = CHKEST.C5_DTENTR " 
	cQuery += " AND ZFA_ROTEIR = CHKEST.C5_ROTEIRO " 
	//
	
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
	cQuery += " AND ZFA_DTENTR >= '" + cDataIni  + "' " 
	cQuery += " AND ZFA_DTENTR <= '" + cDataFim  + "' " 
	cQuery += " AND ZFA_TRANPA >= '" + cTransIni + "' " 
	cQuery += " AND ZFA_TRANPA <= '" + cTransFim + "' " 
	cQuery += " AND ZFA_LJPPAG >= '" + cLojaDe   + "' " 
	cQuery += " AND ZFA_LJPPAG <= '" + cLojaAte  + "' " 
	cQuery += " AND ZFA_VEICPG >= '" + cVecIni   + "' " 
	cQuery += " AND ZFA_VEICPG <= '" + cVecFim   + "' " 
	cQuery += " AND ZFA_ROTEIR >= '" + cRotIni   + "' " 
	cQuery += " AND ZFA_ROTEIR <= '" + cRotFim   + "' " 
	cQuery += " AND ZFA_VA = '" + cTpVa + "' " //Everson - 06/11/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFA_OCORRE IN  " 
	cQuery += " (SELECT ZF7_CODIGO FROM " + RetSqlName("ZF7") + " (NOLOCK) AS ZF7 WHERE ZF7_FILIAL = '" + FWxFilial("ZF7") + "' AND ZF7_TOTCOD = 'S' AND ZF7.D_E_L_E_T_ = '') " 
	cQuery += " ORDER BY ZFA_TRANPA, ZFA_LJPPAG, ZFA_VEICPG, ZFA_DTENTR, ZFA_ROTEIR " // Everson - 14/10/2019 - Chamado 044314.

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - carInter1 - cQuery " + cQuery )
	
	//
	If Select("DD_CR") > 0
		DD_CR->(DbCloseArea())
		
	EndIf 
		
	//
	TcQuery cQuery New Alias "DD_CR"
	DbSelectArea("DD_CR")
	DD_CR->(DbGoTop())
	
	//
	If DD_CR->(Eof())
		DD_CR->(DbCloseArea())
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If cOPc == "1"
		oCargas:aCols := {}
		
	ElseIf cOPc == "2"
		oEmitMP:aCols := {}
	
	EndIf
	
	//
	While ! DD_CR->(Eof())

		//
		cCte := ""
		cMDF := ""
		cCiot:= "" //Everson  - 06/03/2020. Chamado 054941
		chkDocEmit("1/2/3",Alltrim(DD_CR->ZFA_ROTEIR),Alltrim(DD_CR->ZFA_DTENTR),.F.,@cCTE,@cMDF,@cCiot,Alltrim(DD_CR->ZFA_VA)) //Everson  - 06/03/2020. Chamado 054941


		//Everson - 20/04/2022 - Chamado 71619.
		cEstTran	:= Posicione("SA4",1,FWxFilial("SA4") + DD_CR->ZFA_TRANPA,"A4_EST")
		lGerMDF     := cEstTran $cTrapMDF
		//

		//
		lNRegMDF := !Empty(cMDF)  .Or. cGerMDF = "N" .Or. ( Val(cValToChar(DD_CR->QTD_NOTA)) >= nTotNf .And. Val(cValToChar(DD_CR->CHKEST)) = 0 .And. !lGerMDF ) //Everson  - 06/03/2020. Chamado 054941
		lNRegCio := !Empty(cCiot) .Or. cGerCIO = "N" //Everson  - 06/03/2020. Chamado 054941
		lNRegCCT := !Empty(cCte)  .Or. cGerCCT = "N" //Everson  - 06/03/2020. Chamado 054941
		
		//
		If lNRegMDF .And. lNRegCCT .And. lNRegCio  //Everson - 03/12/2019 - Chamado 029058. //Everson - 06/03/2020 - Chamado 054941.
			oCor := oVerde

		ElseIf ! lNRegCio .And. ! lNRegCCT .And. ! lNRegMDF //Everson   ³18/10/2019³052772. //Everson - 06/03/2020 - Chamado 054941.
			oCor := oVerme

		ElseIf ! lNRegCCT .Or. ! lNRegCio .Or. ! lNRegMDF  //Everson - 03/12/2019 - Chamado 029058. //Everson - 06/03/2020 - Chamado 054941.
			oCor := oAmarelo

		EndIf
		
		//
		If cOPc == "1"
			
			//
			If cFilDocs == "1" .Or.;
			   ( cFilDocs == "2" .And. ! lNRegCCT ) .Or.;
			   ( cFilDocs == "3" .And. ! lNRegMDF ) .Or.; //Everson - 06/03/2020. Chamado 054941.
			   ( cFilDocs == "4" .And. ! lNRegCio) //Everson - 06/03/2020. Chamado 054941.

			   	//
				nTopPend++
				Aadd(oCargas:aCols , Array(Len(aHCr) + 1) )
				oCargas:aCols[Len(oCargas:aCols), Len(oCargas:aCols[1]) ] := .F.
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "LEG" })]   := oCor
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDTE" })] := SToD(DD_CR->ZFA_DTENTR)	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRROT" })] := DD_CR->ZFA_ROTEIR	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRNNF" })] := DD_CR->QTD_NOTA	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRTRA" })] := DD_CR->ZFA_TRANPA	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRLOJ" })] := DD_CR->ZFA_LJPPAG	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRNMT" })] := DD_CR->ZFA_NMTPAG	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRVEI" })] := DD_CR->ZFA_VEICUL	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CROCO" })] := DD_CR->ZFA_OCORRE	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDES" })] := DD_CR->ZFA_DESCOC	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRVALOR"})]:= Round(DD_CR->ZFA_VALOR * nPorc,2)	//Everson ³06/09/2019³044314³.
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRZFA" })] := DD_CR->ZFA_COD	
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCAR" })] := DD_CR->ZFA_CARGA
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCTE" })] := IIf(lNRegCCT ,"Ok","")
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRMDF" })] := IIf(lNRegMDF ,"Ok","") //Everson³08/08/19³044314. //Everson   ³18/10/2019³052772. //Everson - 03/12/2019 - Chamado 029058.
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCIO" })] := IIf(lNRegCio ,"Ok","") //Everson  - 06/03/2020. Chamado 054941

			EndIf
		
		ElseIf cOPc == "2"
			
			                         
			If ! lNRegMDF .And. lNRegCCT//Everson - 08/08/19³044314. //Everson - 03/12/2019 - Chamado 029058. //Everson - 06/03/2020. Chamado 054941.
				nTopPend++
				Aadd(oEmitMP:aCols , Array(Len(aHDcPEM) + 1) )
				oEmitMP:aCols[Len(oEmitMP:aCols), Len(oEmitMP:aCols[1]) ] := .F.
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "LEG" })]   := oCor
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRDTE" })] := SToD(DD_CR->ZFA_DTENTR)	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRROT" })] := DD_CR->ZFA_ROTEIR	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRTRA" })] := DD_CR->ZFA_TRANPA	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRLOJ" })] := DD_CR->ZFA_LJPPAG	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRNMT" })] := DD_CR->ZFA_NMTPAG	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRVEI" })] := DD_CR->ZFA_VEICUL	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CROCO" })] := DD_CR->ZFA_OCORRE	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRDES" })] := DD_CR->ZFA_DESCOC	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRZFA" })] := DD_CR->ZFA_COD	
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRCAR" })] := DD_CR->ZFA_CARGA
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRCTE" })] := IIf(lNRegCCT,"Ok","")
				oEmitMP:aCols[Len(oEmitMP:aCols),Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRMDF" })] := IIf(lNRegMDF ,"Ok","")	//Everson³08/08/19³044314.	//Everson   ³18/10/2019³052772. //Everson - 03/12/2019 - Chamado 029058.
				oCargas:aCols[Len(oCargas:aCols),Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCIO" })]    := IIf(lNRegCio ,"Ok","") //Everson  - 06/03/2020. Chamado 054941

			EndIf
		
		EndIf
		
		DD_CR->(DbSkip())
		
	End
	
	//
	DD_CR->(DbCloseArea())
	
	//
	If cOPc == "1"
		
		//
		If nTopPend <= 0
			oCargas:aCols := {}
			Aadd(oCargas:aCols , Array(Len(aHCr) + 1) )
			oCargas:aCols[Len(oCargas:aCols), Len(oCargas:aCols[1]) ] := .F.	
			oCargas:Refresh()		
		
		EndIf
		
		oCargas:Refresh()
		
	ElseIf cOPc == "2"	
		
		//
		If nTopPend <= 0
			oEmitMP:aCols := {}
			Aadd(oEmitMP:aCols , Array(Len(aHCr) + 1) )
			oEmitMP:aCols[Len(oEmitMP:aCols), Len(oEmitMP:aCols[1]) ] := .F.	
			oEmitMP:Refresh()	
				
		EndIf
		
		//
		oEmitMP:Refresh()
	
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} gerCteLT 
	Gera CT-e em lote. Chamado 044314.
	@type  Static Function
	@author Everson
	@since  01/08/2019
	@version 01
	/*/
Static Function gerCteLT(aHReg, oRegs)
	
	//Variáveis.	
	Local aArea	 := GetArea()
	Local i		 := 1
	
	//
	If ! MsgYesNo("Deseja emitir CT-e em lote?","Função gerCteLT(ADLOG057P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	For i := 1 To Len(oRegs:aCols)
	
		//
		If Empty( Alltrim(oRegs:aCols[i,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRCTE" })]) )
			
			//
			oRegs:GoTo(i) 
			
			Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerCteLT - gerando CT-e para roteiro " + Alltrim(cValToChar(oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRROT" })])) )
			gerCte(aHReg, oRegs, .T.)
		
		EndIf
	
	Next i

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} gerCte  
	Gera CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   18/06/2019
	@version 01
	/*/
Static Function gerCte(aHReg, oRegs, lLote)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cDtEntr	:= ""
	Local cRoteiro	:= Alltrim(cValToChar(oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRROT" })]))
	Local cCTE		:= Alltrim(cValToChar(oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRCTE" })]))
	Local nVlrFrt	:= oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRVALOR" })]
	
	Private cCodZFA		:= Alltrim(cValToChar(oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRZFA" })]))
	Private cCodOcorr	:= Alltrim(cValToChar(oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CROCO" })]))
	
	Default lLote		:= .F.
	
	//
	If Empty(cRoteiro)
		RestArea(aArea)
		Return Nil
			
	EndIf

	//Everson - 24/01/2020. Chamado 054941.
	If ! chkBloqueio(cCodZFA)
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	cDtEntr	:= DToS(oRegs:aCols[oRegs:nAt,Ascan(aHReg,{|x| AllTrim(x[2]) == "CRDTE" })])
	
	//
	If ! Empty(cCTE)
		MsgStop("Já há CT-e emitido para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função gerCte(ADLOG057P)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If ! lLote
		If ! MsgYesNo("Deseja emitir CT-e para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + "?","Função gerCte(ADLOG057P)")
			RestArea(aArea)
			Return Nil
			
		EndIf
	
	EndIf
	
	//Gera CT-e por roteiro.
	MsAguarde({|| gerCteRot(cRoteiro,cDtEntr,,,nVlrFrt)} ,"Aguarde...","Gerando CT-e do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) ,.F.)

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} chkBloqueio
	Checa bloqueio de registro.
	@type  Static Function
	@author Everson
	@since 24/01/2020
	@version 01
	/*/
Static Function chkBloqueio(cCodZFA)

	//Variáveis.
	Local aArea 	:= GetArea()
	//Local lRet 		:= .T.
	Local nMinutos	:= GetMv("MV_#TMPBLQ")//5
	Local nDif		:= 0
	Local cCmp		:= ""
	Local cQuery	:= ""

	//
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(13))
	ZFA->(DbGoTop())
	If ! ZFA->( DbSeek( FWxFilial("ZFA") + cCodZFA ) ) 
		MsgStop("Registro ZFA " + cCodZFA + " não localizado.","Função chkBloqueio(ADLOG057P)")
		RestArea(aArea)
		Return .F.

	EndIf

	//
	cCmp := Alltrim(cValToChar(ZFA->ZFA_TMPBLQ))

	//
	If Empty(cCmp)
		RestArea(aArea)
		Return .T.

	EndIf

	//
	If Select("CHKBLQ") > 0
		CHKBLQ->(DbCloseArea())

	EndIf

	//
	cQuery := "SELECT DATEDIFF(MINUTE,CAST('" + cCmp + "' AS DATETIME),CAST('" + DToS(Date()) + " " + Time() + "' AS DATETIME)) AS DIF"
	TcQuery cQuery New Alias "CHKBLQ"
	DbSelectArea("CHKBLQ")
		nDif := Val(cValToChar(CHKBLQ->DIF))
	CHKBLQ->(DbCloseArea())

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - chkBloqueio - nDif " + cValToChar(nDif) )

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - chkBloqueio - nMinutos " + cValToChar(nMinutos) )

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - chkBloqueio - nDif < nMinutos " + cValToChar(nDif < nMinutos) )

	//
	If nDif < nMinutos
		logZBE("BLOQUEIO chkBloqueio - entrega/roteiro/carga " + DToS(ZFA->ZFA_DTENTR) + " / " + Alltrim(cValToChar(ZFA->ZFA_ROTEIR)) + " / " + Alltrim(cValToChar(ZFA->ZFA_CARGA)) )
		MsgStop("Necessário aguardar " + cValToChar(nMinutos) + " minutos, para emissão de documento referente ao roteiro " + Alltrim(cValToChar(ZFA->ZFA_ROTEIR)) + ".","Função chkBloqueio(ADLOG057P)")
		RestArea(aArea)
		Return .F.

	Else
		RecLock("ZFA")
			ZFA->ZFA_TMPBLQ := ""
		ZFA->(MsUnlock())

	EndIf

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} blqReg
	Registra bloqueio do registro na tabela ZFA.
	@type  Static Function
	@author Everson
	@since 24/01/2020
	@version 01
	/*/
Static Function blqReg(cCodZFA)

	//Variáveis.
	Local aArea := GetArea()

	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(13))
	ZFA->(DbGoTop())
	If ! ZFA->( DbSeek( FWxFilial("ZFA") + cCodZFA ) ) 
		RestArea(aArea)
		Return .F.

	EndIf

	//
	RecLock("ZFA")
		ZFA->ZFA_TMPBLQ := DToS(Date()) + " " + Time()
	ZFA->(MsUnlock())

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} gerCteRot  
	Emissão de CT-e por roteiro. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	/*/
Static Function gerCteRot(cRoteiro,cDtEntr,cSeq,lUpdate,nVlrFrt)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local aNotas	:= {}
	Local aNotaInd	:= {}
	Local i			:= 1
	Local cSerie	:= ""
	Local cNF		:= ""
	//Local cHash		:= ""
	//Local cVlParc	:= ""
	Local nTotalNF	:= Val(cValToChar(GetMv("MV_#QTDNFE")))
	Local nParc		:= 0
	Local nTotEnv	:= 0
	Local lCliDif	:= .F.
	Local lRetEnv	:= .F.
	Local lEstDif	:= .F. //Everson - 11/12/2019 - Chamado 029058.
	
	//Everson - 15/04/2021 - Chamado 12355.
	Local cTransp 	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_TRANPA")))
	Local cEstTran	:= Posicione("SA4",1,FWxFilial("SA4") + cTransp,"A4_EST")
	Local lTransEst := cEstTran $GetMv("MV_#UFTCAT",,"") 
	//
	
	Default cSeq	:= ""
	Default nVlrFrt	:= 0	
	Default	lUpdate	:= .F.

	//
	If IsInCallStack("U_ADLOG058P")

		//
		cQuery := ""
		cQuery += " SELECT  " 
		cQuery += " TOP 1 ZFA_COD  " 
		cQuery += " FROM " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF7") + " (NOLOCK) AS ZF7 ON " 
		cQuery += " ZFA_OCORRE = ZF7_CODIGO " 
		cQuery += " WHERE  " 
		cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "'  " 
		cQuery += " AND ZFA_DTENTR = '" + cDtEntr + "'  " 
		cQuery += " AND ZFA_ROTEIR = '" + cRoteiro + "'  " 
		cQuery += " AND ZFA_VA = '" + cTpVa + "' " //Everson - 06/11/2019. Chamado 029058.
		cQuery += " AND ZF7_TOTCOD = 'S'  " 
		cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF7.D_E_L_E_T_ = '' " 
		cQuery += " ORDER BY " 
		cQuery += " ZFA.R_E_C_N_O_  " 
		
		//
		If Select("D_CODZFA") > 0
			D_CODZFA->(DbCloseArea())
			
		EndIf
		
		TcQuery cQuery New Alias "D_CODZFA"
		DbSelectArea("D_CODZFA")
		D_CODZFA->(DbGoTop())
			cCodZFA := Alltrim(cValToChar(D_CODZFA->ZFA_COD))
		D_CODZFA->(DbCloseArea())

		//
		If Empty(cCodZFA)
			RestArea(aArea)
			Return Nil 
			
		EndIf
		
	EndIf

	//Obtém as notas fiscais que estão vinculadas ao roteiro.
	aNotas 	:= obtNF(cRoteiro,cDtEntr,,@lCliDif,@lEstDif) //Everson - 11/12/2019 - Chamado 029058.
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerCteRot - lCliDif " + cValToChar(lCliDif) )

	//Verifica se há notas fiscais vinculadas ao roteiro.
	If Len(aNotas) = 0
		RestArea(aArea)
		Return Nil
		
	EndIf

	//Percorre o array com os números das notas fiscais.
	If (Len(aNotas) < nTotalNF) .Or. lEstDif .Or. cTpVa == "3" .Or. ! lTransEst //Everson - 11/12/2019 - Chamado 029058. //Everson - 06/03/2020. Chamado 054941. //Everson - 15/04/2021 - Chamado 12355.

		//
		nParc := Round( nVlrFrt  / Len(aNotas), 2 )

		//
		For i := 1 To Len(aNotas)

			//
			cSerie  := Alltrim(cValToChar(aNotas[i][1]))
			cNF     := Alltrim(cValToChar(aNotas[i][2]))

			//Everson - 03/12/2019.
			aNotaInd := {}
			Aadd(aNotaInd,{aNotas[i][1],aNotas[i][2],aNotas[i][3],aNotas[i][4]})

			//
			If i = Len(aNotas)
				nParc := Round(nVlrFrt - nTotEnv,2)

			EndIf

			//Valida valor de retorno da função valorFrete.
			If nParc <= 0
				Loop

			EndIf

			//
			nTotEnv += nParc
			lRetEnv := procGerCTE(aNotaInd,"00","00",cRoteiro,cDtEntr,,cSeq,lUpdate,,,,,,nParc) //Emissão por nota fiscal.

			//
			If ! lRetEnv
				MsgStop("Ocorreu erro na emissão do CT-e.","Função gerCteRot(ADLOG057P)")
				RestArea(aArea)
				Return lRetEnv

			EndIf

		Next i

	Else
		//Everson - 26/09/2019 - 044314.
		lRetEnv := procGerCTE(aNotas,"00",Iif(lCliDif,"01","00"),cRoteiro,cDtEntr,,cSeq,lUpdate,,,,,,nVlrFrt) //Emissão agrupada.

	EndIf
	
	//
	RestArea(aArea)

Return lRetEnv
/*/{Protheus.doc} obtNF  
	Obtém informações das notas fiscais de saída. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 22/05/2019
	@version 01
	/*/
Static Function obtNF(cRoteiro,cDtEntr,cDocFilt,lCliDif,lEstDif,cCTE) //Everson 26/09/2019 044314. //Everson - 11/12/2019 - Chamado 029058.

	//Variáveis.
	Local aArea			:= GetArea()
	Local cQuery       	:= ""
	Local aSeriaNota   	:= {}
	//Local cDoc			:= ""
	Local cCliAnt		:= ""
	Local cUFLibCat		:= Alltrim(GetMv("MV_#UFLCAT"))
	
	Default cDocFilt	:= ""
	Default lCliDif		:= .F.
	Default lEstDif		:= .F. //Everson - 11/12/2019 - Chamado 029058.
	Default cCTE		:= ""  //Everson - 24/01/2020 - Chamado 054941.
	
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtNF - iniciada por " + cValToChar(ProcName(1)) )
	
	//
	cRoteiro	:= Alltrim(cValToChar(cRoteiro))
	cDtEntr		:= Alltrim(cValToChar(cDtEntr))

	//
	If Empty(cRoteiro) .And. Empty(cDtEntr)
		MsgStop("Função obtNF não recebeu o código do roteiro como argumento.","Função obtNF(ADLOG057P)")
		logZBE("FUNCAO obtNF: NAO RECEBEU O ROTEIRO COMO ARGUMENTO")
		RestArea(aArea)
		Return aSeriaNota
		
	EndIf

	//
	If cTpVa == "1" //Frt. Abatido.

		//
		cQuery := " "
		cQuery += " SELECT   " 
		cQuery += " DISTINCT C5_NOTA AS NOTA, C5_SERIE AS SERIE, F2_CHVNFE AS DOC_CHV, C5_SEQUENC AS SEQ, F2_EST, " //Everson - 17/02/2020. Chamado 054941.
		cQuery += " LTRIM(RTRIM(C5_CLIENTE))+LTRIM(RTRIM(C5_LOJACLI)) CHKCLI   "  //Everson   ³26/09/2019³044314.
		cQuery += " FROM   " 
		cQuery += " " + RetSqlName("SC5") + "  (NOLOCK) AS SC5   " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 ON " 
		cQuery += " C5_FILIAL = F2_FILIAL " 
		cQuery += " AND C5_NOTA = F2_DOC " 
		cQuery += " AND C5_SERIE = F2_SERIE   " 
		cQuery += " AND C5_CLIENTE = F2_CLIENTE " 
		cQuery += " AND C5_LOJACLI = F2_LOJA " 

		//Everson - 27/01/2020. Chamado 054941.
		If ! Empty(cCTE)

			//
			cQuery += " INNER JOIN "
			cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK ON "
			cQuery += " C5_FILIAL = ZFK_FILIAL "
			cQuery += " AND C5_NUM = ZFK_PEDVEN "
			cQuery += " AND ZFK_CHAVE = '" + cCTE + "' "
			cQuery += " AND ZFK.D_E_L_E_T_ = ''  "

		EndIf

		//
		cQuery += " WHERE   " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "'   " 
		cQuery += " AND C5_ROTEIRO = '" + cValToChar(cRoteiro) + "'   " 
		cQuery += " AND C5_DTENTR = '" + cValToChar(cDtEntr) + "'   " 
		cQuery += " AND C5_PLACA  <> ''  " //Everson - 02/10/2019. Chamado 044314.
		cQuery += " AND C5_TRANSP <> ''  " //Everson - 02/10/2019. Chamado 044314.
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SF2.D_E_L_E_T_ = ''  " 
		cQuery += " AND SC5.D_E_L_E_T_ = ''   " 
		
		//
		If ! Empty(cDocFilt)
			cQuery += " AND RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) = '" + cValToChar(cDocFilt) + "' " 
		
		EndIf
		
		cQuery += " ORDER BY SEQ " 

	ElseIf cTpVa == "2" //Frt. Frango Vivo.

		cQuery := ""
		cQuery += " SELECT   " 
		cQuery += " DISTINCT F2_DOC    AS NOTA,   F2_SERIE  AS SERIE,   F2_CHVNFE AS DOC_CHV,   " //Everson - 17/02/2020. Chamado 054941.
		cQuery += " LTRIM(RTRIM(F2_CLIENTE))+LTRIM(RTRIM(F2_LOJA)) CHKCLI, F2_EST,  C5_SEQUENC AS SEQ   " 
		cQuery += " FROM   " 
		cQuery += " " + RetSqlName("ZV1") + " (NOLOCK) AS ZV1   " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZFC") + " (NOLOCK) AS ZFC ON " 
		cQuery += " ZV1_NUMOC = ZFC_NUMERO " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 ON   " 
		cQuery += " RIGHT('000000000' + RTRIM(LTRIM(ZFC_NF)),9) = F2_DOC   " 
		cQuery += " AND RIGHT('00' + RTRIM(LTRIM(ZFC_SERIE)),2) = F2_SERIE   " 
		cQuery += " INNER JOIN  " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON   " 
		cQuery += " F2_FILIAL = C5_FILIAL   " 
		cQuery += " AND F2_DOC = C5_NOTA   " 
		cQuery += " AND F2_SERIE = C5_SERIE   " 
		cQuery += " WHERE   " 
		//cQuery += " ZV1_FILIAL = '  '   " 
		cQuery += " ZV1_FILIAL = '"+FWxFilial("ZV1")+"' " // @history ticket 69945 - Fernando Macieira - 21/03/2022 - Projeto FAI - Ordens Carregamento - Frango vivo
		cQuery += " AND F2_FILIAL = '" + FWxFilial("SF2") + "'   " 
		cQuery += " AND ZFC_NUMERO  = '" + cValToChar(cRoteiro) + "'   " 
		cQuery += " AND ZFC_DTAPRE = '" + cValToChar(cDtEntr) + "'   " 
		cQuery += " AND ZV1.D_E_L_E_T_ = ''   " 
		cQuery += " AND SF2.D_E_L_E_T_ = ''   " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery +=  " AND C5_NOTA <> '' "
		cQuery += " AND ZFC.D_E_L_E_T_ = ''   " 
		cQuery += " ORDER BY F2_SERIE, F2_DOC   " 

	ElseIf cTpVa == "3" //Frt. Ovo. //16/01/2020, Everson, Ch:054941 

		//
		cQuery := ""
		cQuery +=  " SELECT      " 
		cQuery +=  " DISTINCT C5_NOTA AS NOTA, C5_SERIE AS SERIE, F2_CHVNFE AS DOC_CHV, ZFD_SEQCAR AS SEQ, F2_EST, " //Everson - 17/02/2020. Chamado 054941.
		cQuery +=  " LTRIM(RTRIM(C5_CLIENTE))+LTRIM(RTRIM(C5_LOJACLI)) CHKCLI " 
		cQuery +=  " FROM   " 
		cQuery +=  " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD ON " 
		cQuery +=  " ZFA_FILIAL = ZFD_FILIAL " 
		cQuery +=  " AND ZFA_CARGA = ZFD_COD  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON   " 
		cQuery +=  " ZFD_FILIAL = C5_FILIAL   " 
		cQuery +=  " AND ZFD_PEDIDO = C5_NUM  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SF2") + "  (NOLOCK) AS SF2 ON   " 
		cQuery +=  " C5_FILIAL = F2_FILIAL   " 
		cQuery +=  " AND C5_NOTA = F2_DOC   " 
		cQuery +=  " AND C5_SERIE = F2_SERIE     " 
		cQuery +=  " AND C5_CLIENTE = F2_CLIENTE   " 
		cQuery +=  " AND C5_LOJACLI = F2_LOJA      " 
		cQuery +=  " WHERE     " 
		cQuery +=  " ZFD_FILIAL = '" + FWxFilial("ZFD") + "'     " 
		cQuery +=  " AND ZFA_ROTEIR  = '" + cValToChar(cRoteiro) + "'   " 
		cQuery +=  " AND ZFA_DTENTR  = '" + cValToChar(cDtEntr) + "'   " 
		cQuery +=  " AND ZFD_VA = '3'   " 
		cQuery +=  " AND ZFD_FEZNF = 'S'  " 
		cQuery +=  " AND C5_NOTA <> '' "
		cQuery +=  " AND ZFA.D_E_L_E_T_ = '' " 
		cQuery +=  " AND ZFD.D_E_L_E_T_ = ''   " 
		cQuery +=  " AND SC5.D_E_L_E_T_ = ''  " 
		cQuery +=  " AND SF2.D_E_L_E_T_ = '' " 
 
		//
		If ! Empty(cDocFilt)
			cQuery += " AND RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) = '" + cValToChar(cDocFilt) + "' " 
		
		EndIf
		
		cQuery += " ORDER BY SEQ " 

	ElseIf cTpVa == "4" //Frt. Pintinho. //16/01/2020, Everson, Ch:054941.
		
		//
		cQuery := ""
		cQuery +=  " SELECT      " 
		cQuery +=  " DISTINCT C5_NOTA AS NOTA, C5_SERIE AS SERIE, F2_CHVNFE AS DOC_CHV, ZFD_SEQCAR AS SEQ, F2_EST, " //Everson - 17/02/2020. Chamado 054941.
		cQuery +=  " LTRIM(RTRIM(C5_CLIENTE))+LTRIM(RTRIM(C5_LOJACLI)) CHKCLI " 
		cQuery +=  " FROM   " 
		cQuery +=  " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD ON " 
		cQuery +=  " ZFA_FILIAL = ZFD_FILIAL " 
		cQuery +=  " AND ZFA_CARGA = ZFD_COD  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON   " 
		cQuery +=  " ZFD_FILIAL = C5_FILIAL   " 
		cQuery +=  " AND ZFD_PEDIDO = C5_NUM  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SF2") + "  (NOLOCK) AS SF2 ON   " 
		cQuery +=  " C5_FILIAL = F2_FILIAL   " 
		cQuery +=  " AND C5_NOTA = F2_DOC   " 
		cQuery +=  " AND C5_SERIE = F2_SERIE     " 
		cQuery +=  " AND C5_CLIENTE = F2_CLIENTE   " 
		cQuery +=  " AND C5_LOJACLI = F2_LOJA      " 
		cQuery +=  " WHERE     " 
		cQuery +=  " ZFD_FILIAL = '" + fWxFilial("ZFD") + "'     " 
		cQuery +=  " AND ZFA_ROTEIR  = '" + cValToChar(cRoteiro) + "'   " 
		cQuery +=  " AND ZFA_DTENTR  = '" + cValToChar(cDtEntr) + "'   " 
		cQuery +=  " AND ZFD_VA = '4'   " 
		cQuery +=  " AND ZFD_FEZNF = 'S'  " 
		cQuery +=  " AND C5_NOTA <> '' "
		cQuery +=  " AND ZFA.D_E_L_E_T_ = '' " 
		cQuery +=  " AND ZFD.D_E_L_E_T_ = ''   " 
		cQuery +=  " AND SC5.D_E_L_E_T_ = ''  " 
		cQuery +=  " AND SF2.D_E_L_E_T_ = '' " 
 
		//
		If ! Empty(cDocFilt)
			cQuery += " AND RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) = '" + cValToChar(cDocFilt) + "' " 
		
		EndIf
		
		cQuery += " ORDER BY SEQ " 

	ElseIf cTpVa == "5"  //Frt. Ração. //Everson - 17/02/2020. Chamado 054941.

		//
		cQuery := ""
		cQuery +=  " SELECT      " 
		cQuery +=  " DISTINCT C5_NOTA AS NOTA, C5_SERIE AS SERIE, F2_CHVNFE AS DOC_CHV, ZFD_SEQCAR AS SEQ, F2_EST, " //Everson - 17/02/2020. Chamado 054941.
		cQuery +=  " LTRIM(RTRIM(C5_CLIENTE))+LTRIM(RTRIM(C5_LOJACLI)) CHKCLI " 
		cQuery +=  " FROM   " 
		cQuery +=  " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD ON " 
		cQuery +=  " ZFA_FILIAL = ZFD_FILIAL " 
		cQuery +=  " AND ZFA_CARGA = ZFD_COD  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON   " 
		cQuery +=  " ZFD_FILIAL = C5_FILIAL   " 
		cQuery +=  " AND ZFD_PEDIDO = C5_NUM  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SF2") + "  (NOLOCK) AS SF2 ON   " 
		cQuery +=  " C5_FILIAL = F2_FILIAL   " 
		cQuery +=  " AND C5_NOTA = F2_DOC   " 
		cQuery +=  " AND C5_SERIE = F2_SERIE     " 
		cQuery +=  " AND C5_CLIENTE = F2_CLIENTE   " 
		cQuery +=  " AND C5_LOJACLI = F2_LOJA      " 
		cQuery +=  " WHERE     " 
		cQuery +=  " ZFD_FILIAL = '" + fWxFilial("ZFD") + "'     " 
		cQuery +=  " AND ZFA_ROTEIR  = '" + cValToChar(cRoteiro) + "'   " 
		cQuery +=  " AND ZFA_DTENTR  = '" + cValToChar(cDtEntr) + "'   " 
		cQuery +=  " AND ZFD_VA = '5'   " 
		cQuery +=  " AND ZFD_FEZNF = 'S'  " 
		cQuery +=  " AND C5_NOTA <> '' "
		cQuery +=  " AND ZFA.D_E_L_E_T_ = '' " 
		cQuery +=  " AND ZFD.D_E_L_E_T_ = ''   " 
		cQuery +=  " AND SC5.D_E_L_E_T_ = ''  " 
		cQuery +=  " AND SF2.D_E_L_E_T_ = '' " 
 
		//
		If ! Empty(cDocFilt)
			cQuery += " AND RTRIM(LTRIM(C5_NOTA)) + RTRIM(LTRIM(C5_SERIE)) = '" + cValToChar(cDocFilt) + "' " 
		
		EndIf
		
		cQuery += " ORDER BY SEQ " 

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057 - obtNF " + cQuery )

	//Everson - 09/12/2019 - Chamado 029058.
	logZBE("Obter notas fiscais obtNF(ADLOG057P) cQuery ",cQuery)

	//Verifica se o alias existe.
	If Select("NOTASFISCAIS") > 0
		NOTASFISCAIS->(DbCloseArea())
		
	EndIf

	//Executa a consulta no banco.
	TcQuery cQuery New Alias "NOTASFISCAIS"
	DbSelectArea("NOTASFISCAIS")
	NOTASFISCAIS->(DbGoTop())
	While !NOTASFISCAIS->(Eof())

		//
		cCliAnt := NOTASFISCAIS->CHKCLI
	
		//
		If Empty(Alltrim(cValToChar(NOTASFISCAIS->DOC_CHV)))
			aSeriaNota := {}
			Exit
			
		EndIf
		
		//
		Aadd(aSeriaNota,{;
			NOTASFISCAIS->SERIE,; 				//Série.
			NOTASFISCAIS->NOTA,; 				//Nota Fiscal.
			NOTASFISCAIS->DOC_CHV,; 			//Chave da nota fiscal.
			Substr(NOTASFISCAIS->DOC_CHV,7,28); //
		})

		//Everson - 11/12/2019 - Chamado 029058.
		If !(Alltrim(cValToChar(NOTASFISCAIS->F2_EST)) $cUFLibCat)
			lEstDif := .T.

		EndIf

		NOTASFISCAIS->(DbSkip())

		//Everson   ³26/09/2019³044314.
		If ! lCliDif .And. cCliAnt <> NOTASFISCAIS->CHKCLI .And. !NOTASFISCAIS->(Eof())
			Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtNF - cCliAnt <> NOTASFISCAIS->CHKCLI " + cValToChar(cCliAnt <> NOTASFISCAIS->CHKCLI) )
			lCliDif := .T.

		EndIf

	EndDo
	NOTASFISCAIS->(DbCloseArea())

	//Valida consulta ao BD.
	If Len(aSeriaNota) = 0
		MsgStop("Consulta não retornou nota fiscal referente à carga " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ". Por favor, verifique se as notas fiscais já foram transmitidas à SEFAZ e o Danfe já foi impresso.","Função obtNF(ADLOG057P)")
		logZBE("FUNCAO obtNF: NAO RETORNOU NOTA FISCAL REFERENTE A CARGA " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )

	Endif
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtNF - lCliDif " + cValToChar(lCliDif) )

	//Everson - 09/12/2019 - Chamado 029058.
	logZBE("Obter notas fiscais obtNF(ADLOG057P) retorno aSeriaNota ",ArrTokStr(aSeriaNota) )

	//
	RestArea(aArea)
	
Return aSeriaNota
/*/{Protheus.doc} procGerCTE  
	Função para envio do XML da NF-e para geração do CT-e em
	lote. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 29/05/2019
	@version 01
	/*/
Static Function procGerCTE(aNotas,cTipoEmiss,cAgrupa,cRoteiro,cDtEntr,nVlrCompl,cSeqCarAtu,;
	                      lUpdate,cCTECompl,cSCTECompl,cChvCTECom,lCmpDia,aPorcOco,nVlrFrt)

	//Variáveis.
	Local aArea			:= GetArea()
	//Local nNumNF		:= Val(cValToChar(GetMv("MV_#QTDNFE")))
	Local aDadosTrp		:= {}
	Local aItinerario	:= {}
	Local cTrpCNPJ		:= ""
	Local cTrpInsEst	:= ""
	Local cAdoroCNPJ	:= ""
	Local cLocalEmiss	:= ""
	Local cLocalInic	:= ""
	Local cLocalTerm	:= ""
	Local alocPad		:= locPad()
	Local cXmlNF		:= ""
	Local aXml			:= {}
	Local oXml			:= Nil
	Local i				:= 1
	Local cXml			:= ""
	Local cCabec		:= obtCabec()
	Local cSerie		:= ""
	Local cNF			:= ""
	//Local cVlParc		:= ""
	Local aDados		:= {}
	//Local cStringXML	:= ""
	Local cXml64		:= ""
	//Local cHash			:= ""
	Local nPorc			:= getPorEm(cTpVa) //Val(cValToChar(GetMv("MV_#CTEPOR"))) //Everson - 12/12/2019 - Chamado 029058.
	Local cEmissTp		:= ""
	//Local cTpcarga		:= ""
	Local cNumRef		:= ""
	Local cUrl			:= ""
	Local aCabec		:= {}
	Local oRestClient	:= Nil
	Local cRetPost		:= ""
	Local cErroWS		:= ""
	Local aRet			:= {}

	//Obtém código da transportadora.
	Private cCodCrg  	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_CARGA")))
	Private cLoja 		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_LJPPAG")))
	Private cVeiculo 	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_VEICPG")))
	Private cTransp 	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_TRANPA")))
	Private cNmT		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_NMTPAG")))
	Private cPlcCv		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_PLCCAV")))
	Private cMotorista 	:= ""

	Default cSeqCarAtu	:= ""
	Default cTipoEmiss	:= "00" //00->Normal, 01->Complementar.
	Default cAgrupa		:= "01" //00->Não agrupado, 01->Agrupado (CAT 121/13-SP).
	Default lUpdate		:= .F.
	Default nVlrFrt		:= 0
	Default nVlrCompl	:= 0

	//Valida o percentual do valor de frete.
	If nPorc <= 0
		MsgStop("Não foi possível carregar o percentual do valor de frete que será considerado na geração do CT-e (MV MV_#CTEPOR)","Função procGerCTE(ADLOG057P)")
		logZBE("Função procGerCTE: NAO OBTEVE O PERCENTUAL DO VALOR DE FRETE QUE SERA CONSIDERADO NA GERACAO DO CT-E MV MV_#CTEPOR")
		RestArea(aArea)
		Return .F.

	EndIf

	//Everson - 03/12/2019 - Chamado 029058.
	aVeiculo := ddVeiculo(cVeiculo)
	If Len(aVeiculo) <= 0
		RestArea(aArea)
		Return .F.

	EndIf

	//Recupera dados da transportadora.
	aDadosTrp := ddTransp(cTransp,cLoja)
	If Len(aDadosTrp) == 0
		RestArea(aArea)
		Return .F.
		
	Endif

	//Atribui dados da transportadora e CNPJ da Ad'oro às variáveis.
	cTrpCNPJ 	:= Alltrim(cValToChar(aDadosTrp[1][1]))
	cTrpCNPJ	:= StrTran(cTrpCNPJ,".","")
	cTrpCNPJ	:= StrTran(cTrpCNPJ,",","")
	cTrpCNPJ	:= StrTran(cTrpCNPJ,"/","")
	cTrpCNPJ	:= StrTran(cTrpCNPJ,"-","")

	cTrpInsEst	:= Alltrim(cValToChar(aDadosTrp[1][2]))
	cTrpInsEst	:= StrTran(cTrpInsEst,".","")
	cTrpInsEst	:= StrTran(cTrpInsEst,",","")
	cTrpInsEst	:= StrTran(cTrpInsEst,"/","")	
	cTrpInsEst	:= StrTran(cTrpInsEst,"-","")

	cAdoroCNPJ	:= Alltrim(cValToChar(aDadosTrp[1][3]))

	//Recupera informações sobre o itinerário do veículo.
	aItinerario := itinerario(cRoteiro,cDtEntr)
	If Len(aItinerario) == 0
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	cLocalEmiss	:= Alltrim(cValToChar(alocPad[1]))	      // Local de emissão do CT-e.
	cLocalInic	:= Alltrim(cValToChar(aItinerario[1][1])) // Local de início do itinerário.
	cLocalTerm	:= Alltrim(cValToChar(aItinerario[1][2])) // Local de termino do itinerário.

	//Obtém sequêncial do roteiro.
	If lUpdate .Or. ! Empty(cSeqCarAtu)
		cSeq := cSeqCarAtu

	Else
		cSeq := seqZFK(cRoteiro,cDtEntr,"1")
		
	EndIF
	If Empty(cSeq)
		RestArea(aArea)
		Return .F.

	EndIf

	//
	Iif(cTipoEmiss == "01",cEmissTp := "C", cEmissTp := "N")
	
	//
	cNumRef	:=  gerRefCTe(cRoteiro,cDtEntr,cSeq,cEmissTp,cTpVa)

	//
	cXml := ""
	cXml += "<envCTe>"
	cXml += "<cnpjTransportador>" + cTrpCNPJ + "</cnpjTransportador>"
	cXml += "<ieTransportador>" + cTrpInsEst + "</ieTransportador>"
	cXml += "<cnpjTomador>" + cAdoroCNPJ + "</cnpjTomador>"
	cXml += "<tipoEmissao>" + cTipoEmiss + "</tipoEmissao>"
	cXml += "<nrReferencia>" + cNumRef + "</nrReferencia>"
	cXml += "<nrIbgeEmissao>" + cLocalEmiss + "</nrIbgeEmissao>"
	cXml += "<nrIbgeInicio>" + cLocalInic + "</nrIbgeInicio>"
	cXml += "<nrIbgeTermino>" + cLocalTerm + "</nrIbgeTermino>"
	cXml += "<componente>"
	cXml += "<descricao>FRETE</descricao>"
	cXml += "<valor>" + cValToChar( Iif(nVlrCompl > 0, nVlrCompl, nVlrFrt) ) + "</valor>"
	cXml += "</componente>"
	
	//
	If cTipoEmiss == "01" //Se for complemento de CT-e.
		cString += "<chaveAcessoComp>" + cChvCTECom + "</chaveAcessoComp>"
		
	EndIf
	
	//
	cXml += "<agrupaNFe>" + cAgrupa + "</agrupaNFe>"
	
	//Adiciona descrição, valor e xml(Base64).
	For i := 1 To Len(aNotas)

		//Carrega variáveis (série e nota fiscal).
		cSerie	:= Alltrim(cValToChar(aNotas[i][1]))
		cNF		:= Alltrim(cValToChar(aNotas[i][2]))

		//Realiza pesquisa no banco de dados para recuperar o xml.
		aDados	:= obtStrXML(cSerie,cNF)

		//Verifica se a função obtStrXML retornou dados.
		If Len(aDados) == 0
			RestArea(aArea)
			Return .F.

		EndIf

		//Extrai a string xml.
		cXmlNF := Alltrim(cValToChar(aDados[1][2]))

		//XML da NF-e em array de bytes codificados em base64.
		cXml64 := Encode64(cXmlNF)

		//Salva encode64.
		//gravarTXT(cTexto,cNome,cExt,cPasta,lParam)
		gravarTXT(cXml64,"Encode64","txt",,.T.)
		
		//
		cXml += "<nfe>"
		cXml += "<arquivoXML>" + cXml64 + "</arquivoXML>"
		cXml += "</nfe>"

	Next i
	
	//
	cXml += "</envCTe>"

	//Adiciona cabeçalho ao xml.
	cXml := cCabec + cXml

	//Salva arquivo que está sendo enviado.
	gravarTXT(cXml,"Env_CTE_Agrup","xml",,.T.)

	//
	cUrl := Lower(Alltrim(GetMv("MV_#CUSCTE")))

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)
	oRestClient:nTimeOut := 120

	//Everson - 03/12/2019 - 029058.
	logZBE("Geração de CT-e chave " + cNumRef + " " + cValToChar(cRoteiro) + " " + cValToChar(cDtEntr) + " " + cValToChar(cSeq),cXml )

	//Atribui parâmetro post.
	oRestClient:SetPostParams(cXml)

	//Atribui path.
	oRestClient:setPath("")
	varinfo("cXml",cXml)
	
	//Executa consulta web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno 200 ou 201.
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerarCTE - cRetPost " + cValToChar(cRetPost) )
		
	Else
		blqReg(cCodZFA) //Everson - 24/01/2020. Chamado 054941.
		cErroWS := oRestClient:GetLastError()//Retorno com erro.
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerarCTE - cErroWS " + cValToChar(cErroWS) )
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS + Iif(Empty(cErroWS),"Possível erro de certificado SSL/TLS","") ,"Função gerarCTE(ADLOG057P)")
		logZBE("FUNCAO enviarXML: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS + Iif(Empty(cErroWS)," Possívle erro de certificado SSL/TLS",""),cXml)
		Final() //Everson - 22/01/2020. Chamado 054941.
		//RestArea(aArea)
		//Return .F.

	Endif

	//Salva retorno do web service.
	gravarTXT(cRetPost,"Ret_GerarCTE","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetPost)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		Return .F.

	EndIf

	//Atribui o objeto à variável oXml.
	oXml := aXml[1][2]
	
	//
	aRet := obtRet(5,oXml,,,,cRoteiro,,aNotas,cSeq,,cTipoEmiss,lUpdate,nVlrCompl,cDtEntr,;
	               cNumRef,cCTECompl,cSCTECompl,lCmpDia,aPorcOco,,cAgrupa) //Everson - 04/09/2019. Chamado 044314.

	//
	If ValType(aRet) <> "A" .Or. Len(aRet) <= 0
		RestArea(aArea)
		Return .F.

	EndIf

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.

	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} ddTransp  
	Retorna dados da transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function ddTransp(cCodTrp,cLojaTrp)

	//Variáveis.
	Local aArea			:= GetARea()
	Local aDados		:= {}
	//Local cQuery		:= ""
	Local cAdoroCNPJ	:= Alltrim(cValToChar(GetMv("MV_#CTECNP")))
	Local cAdoroIE		:= Alltrim(cValToChar(GetMv("MV_#CTEIES")))
	Local cCNPJTrans	:= ""
	Local cIeTrans		:= ""

	//Retira espaços em branco.
	cCodTrp := Alltrim(cValToChar(cCodTrp))
	cLojaTrp:= Alltrim(cValToChar(cLojaTrp))

	//Verifica o argumento da função.
	If Empty(cCodTrp) .Or. Empty(cLojaTrp)
		MsgStop("A função ddTransp não recebeu o código da transportadora.","Função ddTransp(ADLOG057P)")
		logZBE("FUNCAO ddTransp: NAO RECEBEU O CODIGO DA TRANSPORTADORA")
		RestArea(aArea)
		Return aDados

	EndIf

	//Verifica se carregou o CNPJ da Adoro.
	If Empty(cAdoroCNPJ)
		MsgStop("A função ddTransp não recuperou o CNPJ da empresa tomadora do serviço parâmetro MV_#CTECNP.","Função ddTransp(ADLOG057P)")
		logZBE("FUNCAO ddTransp: NAO RECUPEROU O CNPJ ADORO")
		RestArea(aArea)
		Return aDados

	EndIf

	//Verifica se carregou o I.E. da Adoro.
	If Empty(cAdoroCNPJ)
		MsgStop("A função ddTransp não recuperou a inscrição estadual da empresa tomadora do serviço parâmetro MV_#CTEIES.","Função ddTransp(ADLOG057P)")
		logZBE("FUNCAO ddTransp: NAO RECUPEROU O CNPJ ADORO")
		RestArea(aArea)
		Return aDados

	EndIf

	//
	cCNPJTrans	:= Posicione("SA4",1,FWxFilial("SA4") + cCodTrp,"A4_CGC")
	cIeTrans	:= StrTran(Posicione("SA4",1,FWxFilial("SA4") + cCodTrp,"A4_INSEST"),".","")

	//
	Aadd(aDados,{cCNPJTrans,cIeTrans,cAdoroCNPJ,cAdoroIE})

	//Verifica o preenchimento do array.
	If Len(aDados) == 0
		MsgStop("Consulta ao banco de dados não retornou informações para transportadora " + cCodTrp + ".","Função ddTransp(ADLOG057P)")
		logZBE("FUNCAO ddTransp: CONSULTA AO BANCO DE DADOS NAO RETORNOU INFORMACOES")
		RestArea(aArea)
		Return aDados

	EndIf
	
	//
	RestArea(aArea)

Return aDados
/*/{Protheus.doc} itinerario  
	Função retorna o código IBGE da cidade em que foi emitido
	o conhecimento de transporte, da cidade de início
	do itinerário e a última cidade do itinerário. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 07/06/2019
	@version 01
	/*/
Static Function itinerario(cRoteiro,cDtEntr,lFinLocSai)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aDados		:= {}
	Local cQuery		:= ""
	Local aRetorno		:= {}
	//Local cCidadeIni	:= ""
	Local cCidadeFim	:= ""
	Local cEstFim		:= ""
	//Local cEstIni		:= "" //Everson - 04/09/2019. Chamado 044314.
	Local cPadrLoc		:= Alltrim(cValToChar(GetMv("MV_#CTELOC")))
	Local aPadrLoc		:= {}
	Local cEstado 		:= ""
	Local cCodMuni		:= ""
	Local cNmMuni		:= ""
	Local cTpPed		:= "" //10/02/2020, Everson, Ch:054941.

	Default lFinLocSai	:= .F. //Locais de emissão, início e fim não mudam.

	//Remove espaços em branco.
	cRoteiro := Alltrim(cValToChar(cRoteiro))

	//Valida argumentos da função.
	If Empty(cRoteiro)
		MsgStop("Função itinerario não recebeu o número do roteiro como argumento.","Função itinerario(ADLOG057P)")
		logZBE("FUNCAO itinerario: NAO RECEBEU O NUMERO DO ROTEIRO COMO ARGUMENTO")
		RestArea(aArea)
		Return aRetorno

	EndIf

	//Valida o valor da Mv.
	If Empty(cPadrLoc)
		MsgStop("Não foi possível carrega os valores do parâmetro (Mv) MV_#CTELOC.","Função itinerario(ADLOG057P)")
		logZBE("FUNCAO itinerario: NAO FOI POSSIVEL CARREGA O VALOR DA MV MV_#CTELOC")
		RestArea(aArea)
		Return aRetorno

	EndIf

	//Transforma a string em array.
	aPadrLoc := Separa(cPadrLoc,"|",.T.)

	//Valida a quantidade de dados da Mv MV_#CTELOC.
	If Len(aPadrLoc) <> 3
		MsgStop("Não há dados suficientes no parâmetro (Mv) MV_#CTELOC. É necessário informar a cidade de emissão, cidade de início e cidade de término das entregas.","Função itinerario(ADLOG057P)")
		logZBE("FUNCAO itinerario: NAO HA DADOS SUFICIENTES NA MV MV_#CTELOC")
		RestArea(aArea)
		Return aRetorno

	EndIF

	//
	If lFinLocSai
		//Cidade de início e cidade de término.
		Aadd(aRetorno,{Alltrim(cValToChar(aPadrLoc[2])),Alltrim(cValToChar(aPadrLoc[3]))})
		RestArea(aArea)
		Return aRetorno

	EndIf

	//Everson - 04/09/2019. Chamado 044314.
	//Monta script sql.
	If cTpVa = "1" //Frt. Abatido.

		//
		cQuery := ""
		cQuery += " SELECT    " 
		cQuery += " A1_ESTE AS ESTE, A1_CODMUNE AS CODMUNE, A1_MUNE AS MUNE, C5_SEQUENC AS SEQ, A1_EST AS EST, A1_COD_MUN AS COD_MUN, A1_MUN AS MUN " 
		cQuery += " FROM    " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN    " 
		cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON " 
		cQuery += " C5_CLIENTE = A1_COD    " 
		cQuery += " AND C5_LOJACLI = A1_LOJA   " 
		cQuery += " WHERE    " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "'    " 
		cQuery += " AND C5_ROTEIRO = '" + cValToChar(cRoteiro) + "'  " 
		cQuery += " AND C5_DTENTR =  '" + cValToChar(cDtEntr)  + "' " 
		cQuery += " AND SA1.D_E_L_E_T_ = ''   " 
		cQuery += " AND SC5.D_E_L_E_T_ = ''  "  
		cQuery += " ORDER BY SEQ "

	ElseIf cTpVa = "2" //Frt. Frango Vivo.

		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " A1_ESTE AS ESTE, A1_CODMUNE AS CODMUNE, A1_MUNE AS MUNE, ZFC_SEQUEN AS SEQ, A1_EST AS EST, A1_COD_MUN AS COD_MUN, A1_MUN AS MUN "
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZV1") + " (NOLOCK) AS ZV1 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZFC") + " (NOLOCK) AS ZFC ON " 
		cQuery += " ZV1_NUMOC = ZFC_NUMERO " 
		cQuery += " INNER JOIN   " 
		cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 ON   " 
		cQuery += " RIGHT('000000000' + RTRIM(LTRIM(ZFC_NF)),9) = F2_DOC   " 
		cQuery += " AND RIGHT('00' + RTRIM(LTRIM(ZFC_SERIE)),2) = F2_SERIE   " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
		cQuery += " F2_FILIAL = C5_FILIAL " 
		cQuery += " AND F2_DOC = C5_NOTA " 
		cQuery += " AND F2_SERIE = C5_SERIE " 
		cQuery += " INNER JOIN "
		cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON " 
		cQuery += " F2_CLIENTE = A1_COD "
		cQuery += " AND F2_LOJA = A1_LOJA "
		cQuery += " WHERE " 
		cQuery += " ZV1_FILIAL = '" + FWxFilial("ZV1") + "' " 
		cQuery += " AND F2_FILIAL = '" + FWxFilial("SF2") + "' " 
		cQuery += " AND ZFC_NUMERO  = '" + cValToChar(cRoteiro) + "'   " 
		cQuery += " AND ZFC_DTAPRE = '" + cValToChar(cDtEntr) + "'   " 
		cQuery += " AND ZV1.D_E_L_E_T_ = '' " 
		cQuery += " AND SF2.D_E_L_E_T_ = '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SA1.D_E_L_E_T_ = '' " 
		cQuery += " ORDER BY SEQ "

	ElseIf cTpVa == "3" .Or. cTpVa == "4" .Or. cTpVa == "5" //Frt. Ovo. //16/01/2020, Everson, Ch:054941. //10/02/2020, Everson, Ch:054941.//Everson 17/02/2020. Ch:054941.

		//
		cTpPed := getTpPed(cCodZFA) //10/02/2020, Everson, Ch:054941.

		//
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " CLIFOR.ESTE, CLIFOR.CODMUNE, CLIFOR.MUNE, ZFD_SEQCAR AS SEQ, CLIFOR.EST, CLIFOR.COD_MUN, CLIFOR.MUN "
		cQuery +=  " FROM   " 
		cQuery +=  " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD ON " 
		cQuery +=  " ZFA_FILIAL = ZFD_FILIAL " 
		cQuery +=  " AND ZFA_CARGA = ZFD_COD  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON   " 
		cQuery +=  " ZFD_FILIAL = C5_FILIAL   " 
		cQuery +=  " AND ZFD_PEDIDO = C5_NUM  " 
		cQuery +=  " INNER JOIN   " 
		cQuery +=  " " + RetSqlName("SF2") + "  (NOLOCK) AS SF2 ON   " 
		cQuery +=  " C5_FILIAL = F2_FILIAL   " 
		cQuery +=  " AND C5_NOTA = F2_DOC   " 
		cQuery +=  " AND C5_SERIE = F2_SERIE     " 
		cQuery +=  " AND C5_CLIENTE = F2_CLIENTE   " 
		cQuery +=  " AND C5_LOJACLI = F2_LOJA  " 
		cQuery +=  " INNER JOIN " 
		
		//
		If cTpPed == "B"

			//
			cQuery += " ( "
			cQuery += " SELECT A2_COD AS COD, A2_LOJA AS LOJA, '' AS ESTE, " //Everson - 16/03/2020. Chamado 054941.
			cQuery += " '' AS CODMUNE, A2_MUN AS MUNE, A2_EST AS EST, " //Everson - 16/03/2020. Chamado 054941.
			cQuery += " A2_COD_MUN AS COD_MUN, A2_MUN AS MUN "  
			cQuery += " FROM "  
			cQuery += " " + RetSqlName("SA2") + "  (NOLOCK) AS SA2 WHERE SA2.D_E_L_E_T_ = '' " 
			cQuery += ") AS CLIFOR ON " 

		Else

			//
			cQuery += " ( "
			cQuery += " SELECT A1_COD AS COD, A1_LOJA AS LOJA, A1_ESTE AS ESTE, " 
			cQuery += " A1_CODMUNE AS CODMUNE, A1_MUNE AS MUNE, A1_EST AS EST, "
			cQuery += " A1_COD_MUN AS COD_MUN, A1_MUN AS MUN " 
			cQuery += " FROM " 
			cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE SA1.D_E_L_E_T_ = '' "
			cQuery += ") AS CLIFOR ON " 
		
		EndIf

		//
		cQuery +=  " C5_CLIENTE = CLIFOR.COD " 
		cQuery +=  " AND C5_LOJACLI = CLIFOR.LOJA "
		cQuery +=  " WHERE     " 
		cQuery +=  " ZFD_FILIAL = '" + FWxFilial("ZFD") + "'     " 
		cQuery +=  " AND ZFA_ROTEIR  = '" + cValToChar(cRoteiro) + "'   " 
		cQuery +=  " AND ZFA_DTENTR  = '" + cValToChar(cDtEntr) + "'   " 
		cQuery +=  " AND ZFD_VA = '" + cTpVa + "'   " 
		cQuery +=  " AND ZFD_FEZNF = 'S'  " 
		cQuery +=  " AND ZFA.D_E_L_E_T_ = '' " 
		cQuery +=  " AND ZFD.D_E_L_E_T_ = ''   " 
		cQuery +=  " AND SC5.D_E_L_E_T_ = ''  " 
		cQuery +=  " AND SF2.D_E_L_E_T_ = '' " 
		cQuery +=  " ORDER BY SEQ " 

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - itinerario - cQuery " + cQuery )

	//Verifica se o alias existe.
	If Select("ITINERARIO") > 0
		ITINERARIO->(DbCloseArea())
		
	EndIf

	//Executa consulta no BD.
	TcQuery cQuery New Alias "ITINERARIO"
	DbSelectArea("ITINERARIO")
	ITINERARIO->(DbGoTop())
	While ! ITINERARIO->(Eof())

		//Everson-04/09/2019 044314 (2).
		If ! Empty(Alltrim(cValToChar(ITINERARIO->CODMUNE))) .And. ! Empty(Alltrim(cValToChar(ITINERARIO->ESTE)))
			cEstado := Alltrim(cValToChar(ITINERARIO->ESTE))
			cCodMuni:= Alltrim(cValToChar(ITINERARIO->CODMUNE))
			cNmMuni	:= Alltrim(cValToChar(ITINERARIO->MUNE))

		Else 
			cEstado := Alltrim(cValToChar(ITINERARIO->EST))
			cCodMuni:= Alltrim(cValToChar(ITINERARIO->COD_MUN))
			cNmMuni	:= Alltrim(cValToChar(ITINERARIO->MUN))

		EndIf 

		//Everson - 04/09/2019. Chamado 044314.
		Aadd(aDados,{cEstado,cCodMuni,cNmMuni,ITINERARIO->SEQ})

		ITINERARIO->(DbSkip())

	EndDo

	//
	ITINERARIO->(DbCloseArea())

	//Valida retorno da consulta no BD.
	If 	Len(aDados) == 0
		MsgStop("Função itinerario não recuperou dados do itinerário do veículo referente à carga " + cRoteiro + "." ,"Função itinerario(ADLOG057P)")
		logZBE("FUNCAO itinerario: NAO RECUPEROU DADOS DO ITINERARIO REFERENTE A CARGA " + cRoteiro)
		RestArea(aArea)
		Return aDados

	EndIf
	
	//Everson - 04/09/2019. Chamado 044314.
	//Início do itinerário.
	//cEstIni := codIBGEEst(Alltrim(cValToChar(aDados[1][1])),cRoteiro,cDtEntr)

	//Valida retorno da função codIBGEEst.
	/*If Empty(cEstIni)
		MsgStop("Não recuperou o estado da cidade de início do itinerário.","Função itinerario(ADLOG057P)")
		logZBE("FUNCAO itinerario: NAO RECUPEROU O ESTADO DE INICIO DO ITINERARIO")
		RestArea(aArea)
		Return aRetorno

	EndIf

	//Everson - 04/09/2019. Chamado 044314.
	cCidadeIni := cEstIni + Alltrim(cValToChar( aDados[1][2] ))
	*/
	//
	cEstFim :=  codIBGEEst(Alltrim(cValToChar(aDados[Len(aDados)][1])),cRoteiro,cDtEntr)

	//Valida retorno da função codIBGEEst.
	If Empty(cEstFim)
		MsgStop("Não recuperou o estado da cidade de fim do itinerário.","Função itinerario(ADLOG057P)")
		logZBE("FUNCAO itinerario: NAO RECUPEROU A UF FIM DO ITINERARIO")
		RestArea(aArea)
		Return aRetorno
		
	EndIf

	//Fim do itinerário.
	cCidadeFim := cEstFim + Alltrim(cValToChar( aDados[Len(aDados)][2] ))

	//Adiciona retorno ao array.
	Aadd(aRetorno,{aPadrLoc[2],cCidadeFim}) //Everson - 13/03/2020. Chamado 054941.
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} getTpPed
	Obtém tipo do pedido de saída.
	@type  Static Function
	@author Everson
	@since 10/02/2020
	@version 01
	/*/
Static Function getTpPed(cZFA)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cTpPed	:= "N"
	//Local cCarga	:= ""
	Local cQuery	:= ""

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " TOP 1 C5_TIPO " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD ON " 
	cQuery += " ZFA_FILIAL = ZFD_FILIAL " 
	cQuery += " AND ZFA_CARGA = ZFD_COD " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
	cQuery += " ZFD_FILIAL = C5_FILIAL " 
	cQuery += " AND ZFD_PEDIDO = C5_NUM " 
	cQuery += " WHERE " 
	cQuery += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "' " 
	cQuery += " AND ZFA_COD = '" + cZFA + "' "  
	cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFD.D_E_L_E_T_ = '' " 
	cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY " 
	cQuery += " SC5.C5_NUM " 

	//
	If Select("D_CHKTPPED") > 0
		D_CHKTPPED->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_CHKTPPED"
	DbSelectArea("D_CHKTPPED")
	D_CHKTPPED->(DbGoTop())
	If ! D_CHKTPPED->(Eof())
		cTpPed := Alltrim(D_CHKTPPED->C5_TIPO)

	EndIf
	D_CHKTPPED->(DbCloseArea())

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - cTpPed - " + cValToChar(cTpPed) )

	//
	RestArea(aArea)

Return cTpPed
/*/{Protheus.doc} seqZFK  
	Retorna a sequencia númerica de envio do documento. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function seqZFK(cRoteiro,cDtEntr,nTipo)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cRet		:= ""
	Local cTipo		:= cValtoChar(nTipo)
	Local cQuery	:= ""

	//Remove espaços em branco.
	cRoteiro := Alltrim(cValToChar(cRoteiro))
	cTipo  	 := Alltrim(cValToChar(cTipo))

	//Valida argumentos da função.
	If Empty(cRoteiro)
		MsgStop("Função seqZFK não recebeu o código do roteiro.","Função seqZFK")
		logZBE("FUNCAO seqZFK: NAO RECEBEU O CODIGO DO ROTEIRO")
		RestArea(aArea)
		Return cRet

	ElseIf Empty(cTipo)
		MsgStop("Função seqZFK não recebeu o tipo de documento","Função seqZFK")
		logZBE("FUNCAO seqZFK: NAO RECEBEU O TIPO DE DOCUMENTO")
		RestArea(aArea)
		Return cRet

	EndIf

	//Busca carga na tabela ZFK.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " MAX(CAST(ZFK_SEQENV AS INTEGER)) AS MAX " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " AS ZFK " 
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_ROTEIR = '" + cRoteiro + "' " 
	cQuery += " AND ZFK_DTENTR = '" + cDtEntr  + "' " 
	cQuery += " AND ZFK_TPDOC  = '" + cTipo + "' " 
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	
	//Verifica se o alias já existe.
	If Select("SEQ_ZFK") > 0
		SEQ_ZFK->(DbCloseArea())
	EndIf

	//Executa consulta no BD.
	TcQuery cQuery New Alias "SEQ_ZFK"
	DbSelectArea("SEQ_ZFK")
	cRet := Alltrim(cValToChar(SEQ_ZFK->MAX))
	SEQ_ZFK->(DbCloseArea())

	//Valida retorno do BD.
	If Empty(cRet)
		cRet := "1"

	Else
		//Incrementa sequencial.
		cRet := cValToChar(Val(cRet) + 1)

	EndIf
	
	//
	RestArea(aArea)

Return cRet
/*/{Protheus.doc} obtRet  
	Obtém o retorno do webservice gerado de CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function obtRet(nTipo,oXml,cNF,cSerie,cHash,cRoteiro,cCodTransp,aNotas,cSeq,;
					   lVecPrTrans,cTipoEmiss,lUpdate,nVlrCompl,cDtEntr,cNumRef,cCTECompl,;
					   cSCTECompl,lCmpDia,aPorcOco,lExibMsg,cAgrupa)

	//Variáveis.
	Local aArea			:= GetArea()
	Local xRet			:= .F.
	Local cXml			:= ""
	Local cArqErro		:= ""
	
	Default lExibMsg 	:= .T.
	Default cAgrupa	 	:= "" //Everson - 04/09/2019. Chamado 044314.

	//Retira espaços em branco.
	cNF			:= Alltrim(cValToChar(cNF))
	cSerie		:= Alltrim(cValToChar(cSerie))
	cHash		:= Alltrim(cValToChar(cHash))
	cRoteiro	:= Alltrim(cValToChar(cRoteiro))
	cCodTransp	:= Alltrim(cValToChar(cCodTransp))

	//Gera string a partir do objeto.
	SAVE oXml XMLSTRING cXml
	
	//Verifica se o retorno está previsto no tratamento da rotina.
	If  "<retConsulta>" <> Alltrim(cValToChar(Substr(cXml,1,13))) .And.;			//Consulta CT-e.
	"<retEnvio>" <> Alltrim(cValToChar(Substr(cXml,1,10)))        .And.;			//Emissão de CT-e.
	"<retCancelamento>" <> Alltrim(cValToChar(Substr(cXml,1,17))) .And.;			//Cancelamento de CT-e.
	"<retConsultaTransportador>" <> Alltrim(cValToChar(Substr(cXml,1,26))) .And.;	//Consulta empresa.
	"<retConversaoCTe>"     <> Alltrim(cValToChar(Substr(cXml,1,17))) .And.;			//Emissão de CT-e.
	"<RetConsultaMdfe>"     <> Alltrim(cValToChar(Substr(cXml,1,17))) .And.;			//Consulta de CT-e.
	"<RetEncerramento>"     <> Alltrim(cValToChar(Substr(cXml,1,17))) .And.;	    	//Encerramento MDF-e.
	"<retPadrao>"           <> Alltrim(cValToChar(Substr(cXml,1,11))) .And.;	    	//Reenvio averbação.
	"<retConversaoCiot>"    <> Alltrim(cValToChar(Substr(cXml,1,18)))    .And.;		//Emissão CIOT.
	"<retConsultaCiot>"     <> Alltrim(cValToChar(Substr(cXml,1,17)))     .And.;		//Consulta CIOT.
	"<RetEncerramentoCiot>" <> Alltrim(cValToChar(Substr(cXml,1,17)))     .And.;		//Emissão CIOT.
	"<RetCancelamentoCiot>" <> Alltrim(cValToChar(Substr(cXml,1,21)))       		//Emissão CIOT.

		//Everson - 24/01/2020. Chamado 054941.
		If nTipo == 5 .Or. nTipo == 6
			blqReg(cCodZFA)

		EndIf 

		//
		logZBE("Função obtRet(ADLOG057P). Retorno inesperado do web service Ophos. Tipo " + cValToChar(nTipo) ,cXml ) //Everson - 05/12/2019 - Chamado 029058.
		MsgStop("Retorno inesperado do web service Ophos." + Chr(13) + Chr(10) + cXml,"Função obtRet(ADLOG057P)")
		cArqErro := gravarTXT(cXml,"Ret_Inesp_","html")
		fVisualiza(cArqErro)
		RestArea(aArea)
		Return xRet

	EndIf

	//
	logZBE("Função obtRet(ADLOG057P). Retorno Ophos" + cValToChar(nTipo)  ,cXml ) //Everson - 05/12/2019 - Chamado 029058.

	//Seleciona a função para tratamento do retorno.
	If nTipo == 2 //Consultar CT-e.
		xRet := retConsCTE(oXml,cHash,lExibMsg)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 3 //Cancelar CT-e.
		xRet := retCancCTE(oXml,cHash)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 4 //Consulta empresa.
		xRet := retConsEmp(oXml)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 5 //Geração de CT-e agrupado.
		xRet := retEnvGrp(oXml,aNotas,cSeq,lVecPrTrans,cTipoEmiss,cRoteiro,lUpdate,nVlrCompl,cDtEntr,;
	                      cNumRef,cCTECompl,cSCTECompl,lCmpDia,aPorcOco,cAgrupa) //Everson - 04/09/2019. Chamado 044314.
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 6 //Emitir MDF-e.
		xRet := retEnvMDFE(oXml,cRoteiro,lVecPrTrans,cSeq,lUpdate,cDtEntr)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 7 //Consultar MDF-e.
		xRet := retConsMDF(oXml,cHash)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 8 //Encerramento MDF-e.
		xRet := retEncMDFE(oXml,cHash)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 9 //Cancelar MDF-e.
		xRet := retCancMDF(oXml,cHash)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 10 //Reenvio de averbação.
		xRet := retReeAvb(oXml,cHash)
		RestArea(aArea)
		Return xRet

		ElseIf nTipo == 11 //Emissão CIOT.
		xRet := retEnvCI(oXml,cRoteiro,cDtEntr,cSeq,cCTECompl,cSCTECompl,aNotas)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 12 //Consulta CIOT.
		xRet := retCoCIO(oXml,cHash)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 13 //Encerramento CIOT.
		xRet := retEcCIO(oXml,cHash)
		RestArea(aArea)
		Return xRet

	ElseIf nTipo == 14 //Cancelamento CIOT.
		xRet := retCCIO(oXml,cHash)
		RestArea(aArea)
		Return xRet
		
	EndIf
	
	//
	RestArea(aArea)
	
Return xRet
/*/{Protheus.doc} chkDocEmit  
	Checa se há documento emitido para o roteiro. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	/*/
Static Function chkDocEmit(cTipos,cRoteiro,cDtEntr,lPerg,cCTE,cMDF,cCiot,cTpVa)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	//Local cString	:= ""
	Local lRet		:= .T.
	Local cTipoDoc	:= ""

	//Everson - 03/12/2019. Chamado 029058.
	Local aStatus   := Separa(GetMv("MV_#STSEMI",,"0/1/4/7"),"/",.T.)
	Local cStatus	:= ""
	Local nAux		:= 1
	Local aTipos    := Separa(Alltrim(cTipos),"/",.T.)
	Local cTipoAg	:= ""

	//
	Default lPerg	:= .T.
	Default cCTE	:= ""
	Default cMDF	:= ""

	//Verifica o tipo de documento.
	If cTipos == "1"
		cTipoDoc := "CT-e"
		
	ElseIf cTipos == "2"
		cTipoDoc := "MDF-e"
		
	Endif

	//
	For nAux := 1 To Len(aStatus)
		cStatus += "'" + cValToChar(aStatus[nAux]) + "',"

	Next nAux

	//
	cStatus := Substr(cStatus,1,Len(cStatus)-1)

	//
	For nAux := 1 To Len(aTipos)
		cTipoAg += "'" + cValToChar(aTipos[nAux]) + "',"

	Next nAux

	//
	cTipoAg := Substr(cTipoAg,1,Len(cTipoAg)-1)
	
	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " DISTINCT ZFK_TPDOC, ZFK_NUMDOC, ZFK_SERDOC, ZFK_OPHOS, ZFK_NUMCIO " //Everson - 06/03/2020. Chamado 054941.
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_ROTEIR = '" + cValToChar(cRoteiro) + "' " 
	cQuery += " AND ZFK_DTENTR = '" + cValToChar(cDtEntr) + "' "
	cQuery += " AND ZFK_TPDOC IN (" + cValToChar(cTipoAg) + ") " 
	cQuery += " AND ZFK_STATUS IN (" + cStatus + ") " 
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY ZFK_TPDOC "

	//
	If Select("DOCEMIT") > 0
		DOCEMIT->(DbCloseArea())
		
	Endif
	
	//
	TcQuery cQuery New Alias "DOCEMIT"
	DbSelectArea("DOCEMIT")
	DOCEMIT->(DbGoTop())
	While ! DOCEMIT->(Eof())

		//
		If Alltrim(cValToChar(DOCEMIT->ZFK_TPDOC)) == "1"
			cCTE +=  "Doc/Série: " + Alltrim( cValToChar(DOCEMIT->ZFK_NUMDOC)) + "/" + Alltrim(cValToChar(DOCEMIT->ZFK_SERDOC)) + " Msg. Ophos: " +;
			Alltrim(cValToChar(DOCEMIT->ZFK_OPHOS) + Chr(13) + Chr(10)) + ";"
			
		ElseIf Alltrim(cValToChar(DOCEMIT->ZFK_TPDOC)) == "2"
			cMDF +=  "Doc/Série: " + Alltrim( cValToChar(DOCEMIT->ZFK_NUMDOC)) + "/" + Alltrim(cValToChar(DOCEMIT->ZFK_SERDOC)) + " Msg. Ophos: " +;
			Alltrim(cValToChar(DOCEMIT->ZFK_OPHOS) + Chr(13) + Chr(10)) + ";"

		ElseIf Alltrim(cValToChar(DOCEMIT->ZFK_TPDOC)) == "3" //Everson - 06/03/2020. Chamado 054941.
			cCiot +=  "Doc/Série: " + Alltrim( cValToChar(DOCEMIT->ZFK_NUMCIO)) + " Msg. Ophos: " +;
			Alltrim(cValToChar(DOCEMIT->ZFK_OPHOS) + Chr(13) + Chr(10)) + ";"
						
		EndIf	

		DOCEMIT->(DbSkip())
		
	EndDo

	//
	DOCEMIT->(DbCloseArea())
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} reenvRot
	Importa documentos da carga posicionada. Chamado 044314.
	@type  Static Function
	@author Everson
	@since  25/09/2019
	@version 01
	/*/
Static Function reenvRot(aHCr,oCargas,nTpDoc)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cDtEntr	:= ""
	Local cRoteiro	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRROT" })]))
	Local cCTE		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCTE" })]))
	Local cMDFe		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRMDF" })]))
	Local nNumNF	:= Val(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRNNF" })]))
	Local nVlrFrt	:= oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRVALOR" })]
	Local lReenv	:= .T.
	Local nTotNF	:= GetMv("MV_#QTDNFE")
	Local nAux		:= 0
	Local cStatus   := Alltrim(GetMv("MV_#STSEMI",,"0/1/4/7"))
	Local lRetEnv	:= .T.


	
	Private cCodZFA		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRZFA" })]))

	//
	If nTpDoc = "1"
		Private cCodOcorr	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CROCO" })]))

	EndIf

	//
	If Empty(cRoteiro)
		RestArea(aArea)
		Return Nil
			
	EndIf

	//
	If (nTpDoc = "1" .And. Empty(cCTE)) .Or.;
	   (nTpDoc = "2" .And. Empty(cMDFe)) .Or.;
	   (nTpDoc = "2" .And. nNumNF >= nTotNF) //Everson - 03/12/2019. Chamado 029058.
		RestArea(aArea)
		Return Nil
			
	EndIf

	//
	cDtEntr	:= DToS(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDTE" })])

	//
	If ! MsgYesNo("Deseja reenviar o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + "?","Função reenvRot(ADLOG057P)")
		RestArea(aArea)
		Return Nil
		
	EndIf

	//Everson - 09/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função reenvRot(ADLOG057P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função reenvRot(ADLOG057P) ")
		final()

	EndIf  

	//Everson - 03/12/2019 - Chamado 029058.
	Begin Transaction

		//
		DbSelectArea("ZFK")
		ZFK->(DbSetOrder(2))
		ZFK->(DbGoTop())
		If ZFK->(DbSeek( FWxFilial("ZFK") + cDtEntr + Padr(Alltrim(cRoteiro),TamSX3("ZFK_ROTEIR")[1]," ") )) //Everson - 09/12/2019 - Chamado 029058.

			//
			While ! ZFK->(Eof()) .And.;
				DToS(ZFK->ZFK_DTENTR) = cDtEntr .And.;
				Alltrim(cValToChar(ZFK->ZFK_ROTEIR)) = cRoteiro 
				
					//
					If Alltrim(cValToChar(ZFK->ZFK_TPDOC)) = nTpDoc  .And.;
					   Alltrim(cValToChar(ZFK->ZFK_STATUS)) $cStatus .And.;
					   Alltrim(cValToChar(ZFK->ZFK_TPCARG)) = cTpVa .And.;
					   Empty(Alltrim(cValToChar(ZFK->ZFK_CTECOM))) .And.;
					   Empty( Alltrim(cValToChar(ZFK->ZFK_PEDCOM)) )

						//
						RecLock("ZFK",.F.)
							ZFK->(DbDelete())
						ZFK->(MsUnlock())

						//
						nAux++
						
					EndIf

				//
				ZFK->(DbSkip())

			End

		Else 
			lReenv := .F.
			MsgStop("Não foi possível localizar o roteiro.","Função reenvRot(ADLOG057P)")
			DisarmTransaction() //Everson - 09/12/2019 - Chamado 029058.
			Break //Everson - 09/12/2019 - Chamado 029058.

		EndIf

		//
		If nAux <= 0
			lReenv := .F.

		EndIf

		//
		If lReenv
			If nTpDoc = "1"
				MsAguarde({|| lRetEnv := gerCteRot(cRoteiro,cDtEntr,"",.F.,nVlrFrt) } ,"Aguarde...","Reenviando roteiro (CT-e) " + cRoteiro + "-" + DToC(SToD(cDtEntr)) ,.F.)		
			
			ElseIf nTpDoc = "2"
				MsAguarde({|| lRetEnv := geraMDFE(cRoteiro,cDtEntr,,,.F.)}             ,"Aguarde...","Reenviando roteiro (MDF-e) " + cRoteiro + "-" + DToC(SToD(cDtEntr)) ,.F.)

			EndIf

			//Everson - 03/12/2019 - Chamado 029058.
			If ! lRetEnv
				MsgStop("Não foi possível realizar o reenvio do documento.","Função reenvRot(ADLOG057P)")
				DisarmTransaction()
				Break 

			EndIf

		Else
			MsgStop("Não foi possível reenviar o documento pois há documento de fechamento de período para o roteiro e/ou o documento já possui pedido de compra vinculado e/ou está encerrado.","Função reenvRot(ADLOG057P)")

		EndIf

	End Transaction

	//Everson - 09/12/2019 - Chamado 029058.
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função reenvRot(ADLOG057P)")
		logZBE("Sistema está em transação ou TTSBreak - abortando operação. Função reenvRot(ADLOG057P) ")
		final()

	EndIf 

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} reenAvb 
	Reenviar averbação. Chamado 044314.
	@type  Static Function
	@author Everson
	@since  11/07/2019
	@version 01
	/*/
Static Function reenAvb()
	
	//Variáveis.	
	Local aArea	 		:= GetArea()
	//Local cApolic		:= Alltrim(Static Call(NfeSefaz,getApolic,cTpVa)) //Everson - 03/06/2020. Chamado TI.
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	Local cApolic		:= Alltrim(u_ESEFAZA0(cTpVa)) //Everson - 03/06/2020. Chamado TI.
	Local cXml	 		:= ""
	//Local aDados		:= {}
	//Local nAux			:= 1
	Local aCabec		:= {}
	Local oRestClient	:= Nil
	Local cUrl			:= GetMv("MV_#REEAVB")
	Local cRetPost		:= ""
	Local cErroWS		:= ""
	Local cHash			:= Alltrim(cValToChar(oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRHASH" })]))

	//Everson - 03/06/2020. Chamado TI.
	If Empty(cApolic)
		MsgStop("Número da apólice não configurada.","Função reenAvb(ADLOG057P)")
		RestArea(aArea)
		Return .F.

	EndIf
	
	//Everson   ³25/07/19³044314.
	If Empty(cHash)
		MsgStop("Não há dados a serem processados.","Função reenAvb(ADLOG057P)")
		carDocs(.T.,"3")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	If ! MsgYesNo("Será feito o reenvio da averbação. Deseja prosseguir?","Função reenAvb(ADLOG057P)")
		carDocs(.T.,"3")
		RestArea(aArea)
		Return .F.
		
	EndIf	
	
	//
	cXml := ""
	cXml += " <envAverbacao> "
	cXml += " <hash>" + cHash + "</hash> "   
    cXml += " <nrApolice>" + cApolic + "</nrApolice> " 
    cXml += " <tipoDocOrigem>1</tipoDocOrigem> "
    cXml += " </envAverbacao> "

    //Salva arquivo que está sendo enviado.
	gravarTXT(cXml, cHash + "_Env_ReenvAverb","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui parâmetros.
	oRestClient:SetPostParams(cXml)
	conout(cXml)
	//Atribui path.
	oRestClient:setPath("")

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função reenAvb(ADLOG057P)")
		logZBE("FUNCAO reenAvb: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cXml)
		Final() //Everson - 22/01/2020. Chamado 054941.
		//RestArea(aArea)
		//Return .F.
		
	Endif

	//Salva arquivo de retorno do cancelamento.
	gravarTXT(cRetPost, cHash + "_Ret_ReenvAverb","xml",,.T.)

	//Gera objeto xml.
	aXml  := geraObjXML(cRetPost)
	If ! aXml[1][1] //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de geração do CT-e.
	If obtRet(10,oXml,,,cHash)
		Sleep(2000)
		MsAguarde({||consulCTE(cHash,1,.F.)},"Aguarde...","Processando consulta...",.F.)
	
	EndIf

	//
	carDocs(.T.,"3")

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
				
	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} selCTECC 
	Reenviar averbação. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   19/07/2019
	@version 01
	/*/
// Static Function selCTECC()
	
//	//Variáveis.	
// 	Local aArea	  	:= GetArea()
// 	Local cRoteiro	:= Alltrim(cValToChar(oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRROT" }) ]))
// 	Local dDtEntr	:= oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRDTE" }) ]
// 	Local cTransp	:= oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRTRA" }) ]
// 	Local cLoja		:= oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRLOJ" }) ]
// 	Local cPlaca	:= oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRVEI" }) ]
// 	Local aDados	:= 0
// 	Local cPerg 	:= "OPHOS1"
	
// 	//
// 	If Empty(cRoteiro)
// 		MsgStop("Roteiro não definido.","Função selCTECC(ADLOG057P)")
// 		RestArea(aArea)
// 		Return Nil
		
// 	EndIf
	
// 	//
// 	MV_PAR01 := dDtEntr
// 	MV_PAR02 := dDtEntr
// 	MV_PAR03 := cTransp
// 	MV_PAR04 := cLoja
// 	MV_PAR05 := cTransp
// 	MV_PAR06 := cLoja
// 	MV_PAR07 := cPlaca
// 	MV_PAR08 := cPlaca
// 	//MV_PAR09 := cRoteiro
// 	//MV_PAR10 := cRoteiro
	
// 	//
// 	MsAguarde({|| aDados := MkBrwWF(3,,"Selec. CT-e Compl.",.T.,,.F.,.F.) },"Aguarde","Obtendo registros...")
// 	If Len(aDados) > 0
		
// 		//
// 		If Len(aDados) > 1
// 			MsgStop("É necessário selecionar apenas 1 CT-e para ser complementado.","Função selCTECC(ADLOG057P)")
			
// 		Else
		
// 			//
// 			oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "LEG" })   ] := LoadBitmap( GetResources(), "BR_VERDE")
// 			oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRCTE" }) ] := aDados[1][5]
// 			oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRSCTE" })] := aDados[1][6]
// 			oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRACHV" })] := aDados[1][13]
// 			oEmitCC:aCols[oEmitCC:nAt][ Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRAGRP" })] := aDados[1][14]
			
// 		EndIf
	
// 	EndIf
	
// 	//
// 	oEmitCC:Refresh()
	
// 	//
// 	Pergunte(cPerg,.F.)
	
// 	//
// 	RestArea(aArea)
	
// Return Nil
/*/{Protheus.doc} gerCTEALT 
	Gera CT-e complementar. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   04/07/2019
	@version 01
	/*/
// Static Function gerCTEALT(aHCrCC, oEmitCC)
	
// 	//Variáveis.	
// 	Local aArea			:= GetArea()
// 	Local nAux			:= 1
// 	Local aDados		:= {}

// 	//
// 	Private cCodZFA		:= ""
// 	Private cCodOcorr	:= ""
			
// 	//Everson   ³25/07/19³044314
// 	If Len(oEmitCC:aCols) <= 0 .Or. (  Len(oEmitCC:aCols) > 0 .And. Empty(Alltrim(cValToChar(oEmitCC:aCols[oEmitCC:nAt,Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRROT" })]))) )
// 		MsgStop("Não há CT-e a ser emitido.","Função gerCTEALT(ADLOG057P)")
// 		carPedCC()
// 		RestArea(aArea)
// 		Return Nil
		
// 	EndIf
	
// 	//
// 	For nAux := 1 To Len(oEmitCC:aCols)

// 		//
// 		If Empty( Alltrim(cValToChar( oEmitCC:aCols[nAux,Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRCTE" })] )) )  .And.;
// 			oEmitCC:aCols[nAux,Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRVALOR" })] > 0
// 			Aadd(aDados,oEmitCC:aCols[nAux])
			
// 		EndIf
	
// 	Next nAux

// 	//
// 	If Len(aDados) <= 0
// 		MsgStop("Não há registros a serem processados.","Função gerCTEALT(ADLOG057P)")
// 		carPedCC()
// 		RestArea(aArea)
// 		Return Nil
	
// 	EndIf
		
// 	//
// 	If ! MsgYesNo("Será(ão) processado(s) " + cValToChar(Len(aDados)) + " registro(s). Deseja prosseguir?","Função gerCTEALT(ADLOG057P)")
// 		RestArea(aArea)
// 		Return Nil
	
// 	EndIf
	
// 	//
// 	For nAux := 1 To Len(aDados)
	
// 		//
// 		oEmitCC:GoTo(nAux) 

// 		//
// 		MsAguarde({|| gerCte(aHCrCC, oEmitCC, .T.) } ,"Aguarde...","Gerando CT-e..." ,.F.)

// 	Next nAux

// 	//
// 	RestArea(aArea)
	
// Return Nil
/*/{Protheus.doc} carPedCC 
	Carrega registros pendentes de CT-e complementar. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   03/07/2019
	@version 01
	/*/
Static Function carPedCC()
	
	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""
	Local oCor		:= Nil
	Local cDataIni	:= DToS(MV_PAR01)
	Local cDataFim	:= DToS(MV_PAR02)
	Local cTransIni	:= Alltrim(cValToChar(MV_PAR03))
	Local cLojaDe	:= Alltrim(cValToChar(MV_PAR04))
	Local cTransFim	:= Alltrim(cValToChar(MV_PAR05))
	Local cLojaAte	:= Alltrim(cValToChar(MV_PAR06))
	Local cVecIni	:= Alltrim(cValToChar(MV_PAR07))
	Local cVecFim	:= Alltrim(cValToChar(MV_PAR08))
	Local cRotIni	:= Alltrim(cValToChar(MV_PAR09))
	Local cRotFim	:= Alltrim(cValToChar(MV_PAR10))
	
	//
	cQuery := ""
	cQuery += " SELECT DISTINCT * "
	cQuery += " FROM ( "
	cQuery += " SELECT   " 
	cQuery += " '1' AS TAB, ZFA_DATA, ZFA_CARGA, ZFA_DTENTR, ZFA_ROTEIR, ZFA_TRANPA, ZFA_LJPPAG,  " 
	cQuery += " ZFA_NMTPAG, ZFA_VEICPG, ZFA_OCORRE, ZFA_DESCOC, ZFA_VALOR,  " 
	cQuery += " ZFA_COD, ZF7_AGRCTE ,  " 
	cQuery += " ZFKCTE.NUM_REC, ZFKCTE.QTD_CTE, " 
	cQuery += " CASE WHEN ZFKCTE.NUM_REC IS NOT NULL THEN (SELECT ZFK_NUMDOC FROM " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK WHERE ZFK.R_E_C_N_O_ = ZFKCTE.NUM_REC AND ZFK.D_E_L_E_T_ = '') ELSE NULL END AS NUM_CTE, " 
	cQuery += " CASE WHEN ZFKCTE.NUM_REC IS NOT NULL THEN (SELECT ZFK_SERDOC FROM " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK WHERE ZFK.R_E_C_N_O_ = ZFKCTE.NUM_REC AND ZFK.D_E_L_E_T_ = '') ELSE NULL END AS SER_CTE, " 
	
	cQuery += " CASE WHEN ZFKCTE.NUM_REC IS NOT NULL THEN (SELECT ZFK_TPENVC FROM " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK WHERE ZFK.R_E_C_N_O_ = ZFKCTE.NUM_REC AND ZFK.D_E_L_E_T_ = '') ELSE NULL END AS AGR_CTE, " 
	cQuery += " CASE WHEN ZFKCTE.NUM_REC IS NOT NULL THEN (SELECT ZFK_CHAVE  FROM " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK WHERE ZFK.R_E_C_N_O_ = ZFKCTE.NUM_REC AND ZFK.D_E_L_E_T_ = '') ELSE NULL END AS CHV_CTE  " 
	
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA   " 
	cQuery += " INNER JOIN   " 
	cQuery += " " + RetSqlName("ZF7") + " (NOLOCK) AS ZF7 ON   " 
	cQuery += " ZFA_OCORRE = ZF7_CODIGO   " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZFK_FILIAL, ZFK_CODZFA FROM " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' AND ZFK_TPDOC = '1' AND ZFK_STATUS = '1' AND ZFK_TPCARG = '" + cTpVa + "'  AND ZFK.D_E_L_E_T_ = '' ) AS ZFKCHK " 
	cQuery += " ON ZFA_FILIAL = ZFKCHK.ZFK_FILIAL " 
	cQuery += " AND ZFA_COD = ZFKCHK.ZFK_CODZFA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZFK_FILIAL, ZFK_CARGA, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, MIN(R_E_C_N_O_) AS NUM_REC, COUNT(DISTINCT ZFK_NUMDOC + ZFK_SERDOC ) AS QTD_CTE " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK  " 
	cQuery += " WHERE  " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "'  " 
	cQuery += " AND ZFK_TPDOC  = '1'  " 
	cQuery += " AND ZFK_STATUS = '1'  " 
	cQuery += " AND ZFK_TMEMIS = 'N' " 
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = ''  " 
	cQuery += " GROUP BY " 
	cQuery += " ZFK_FILIAL, ZFK_CARGA, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA " 
	cQuery += " ) AS ZFKCTE " 
	cQuery += " ON ZFA_FILIAL = ZFKCTE.ZFK_FILIAL "
	cQuery += " AND ZFA_CARGA = ZFKCTE.ZFK_CARGA "
	cQuery += " AND ZFA_TRANPA = ZFKCTE.ZFK_TRANSP "
	cQuery += " AND ZFA_LJPPAG = ZFKCTE.ZFK_LOJA "
	cQuery += " AND ZFA_VEICPG = ZFKCTE.ZFK_PLACA " 
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "'   " 
	
	cQuery += " AND ZFA_DTENTR >= '" + cDataIni  + "' " 
	cQuery += " AND ZFA_DTENTR <= '" + cDataFim  + "' " 
	cQuery += " AND ZFA_TRANPA >= '" + cTransIni + "' " 
	cQuery += " AND ZFA_TRANPA <= '" + cTransFim + "' " 
	cQuery += " AND ZFA_LJPPAG >= '" + cLojaDe   + "' " 
	cQuery += " AND ZFA_LJPPAG <= '" + cLojaAte  + "' " 
	cQuery += " AND ZFA_VEICPG >= '" + cVecIni   + "' " 
	cQuery += " AND ZFA_VEICPG <= '" + cVecFim   + "' " 
	cQuery += " AND ZFA_ROTEIR >= '" + cRotIni   + "' " 
	cQuery += " AND ZFA_ROTEIR <= '" + cRotFim   + "' " 
	
	cQuery += " AND ZF7_GERCTE = '2' " 
	cQuery += " AND ZFA_DC     = 'C'   " 
	cQuery += " AND ZF7_TOTCOD = 'N' " 
	cQuery += " AND ZFA_APRMOV = 'S' "
	cQuery += " AND ZFA_FECHA  = 'N' "
	cQuery += " AND ZFA_VALOR  >  0 "
	cQuery += " AND ZFA_VA = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFA.D_E_L_E_T_ = ''   " 
	cQuery += " AND ZF7.D_E_L_E_T_ = '' " 
	
	cQuery += " AND ZFKCHK.ZFK_CODZFA IS NULL " //Everson - 12/11/2021. Chamado 63590.
	
	cQuery += " ) AS FONTE "
	
	 
	cQuery += " ORDER BY   " 
	cQuery += " CHV_CTE, ZFA_OCORRE " 
	
	//
	If Select("D_GERCC") > 0
		D_GERCC->(DbCloseArea())
	
	EndIf
	
	//
	TcQuery cQuery New Alias "D_GERCC"
	DbSelectArea("D_GERCC")
	D_GERCC->(DbGoTop())
	
	//
	oEmitCC:aCols := {}
	If ! D_GERCC->(Eof())
		While ! D_GERCC->(Eof())
			
			//
			//If D_GERCC->QTD_CTE > 0
				//oCor := LoadBitmap( GetResources(), "BR_VERDE")
			
			//Else
				oCor := LoadBitmap( GetResources(), "BR_AMARELO")
			
			//EndIf
			
			//
			Aadd(oEmitCC:aCols , Array(Len(aHCrCC) + 1) )
			oEmitCC:aCols[Len(oEmitCC:aCols), Len(oEmitCC:aCols[1]) ] := .F.
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "LEG" })]		:= oCor
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRDTA" })]		:= SToD(D_GERCC->ZFA_DATA)
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRDTE" })]		:= SToD(D_GERCC->ZFA_DTENTR)
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRROT" })]		:= D_GERCC->ZFA_ROTEIR
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRVEI" })]		:= D_GERCC->ZFA_VEICPG		
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRTRA" })]		:= D_GERCC->ZFA_TRANPA
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRLOJ" })]		:= D_GERCC->ZFA_LJPPAG
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRNMT" })]		:= D_GERCC->ZFA_NMTPAG
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CROCO" })]		:= D_GERCC->ZFA_OCORRE
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRDES" })]		:= D_GERCC->ZFA_DESCOC
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRVALOR" })]	:= D_GERCC->ZFA_VALOR
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRZFA" })]		:= D_GERCC->ZFA_COD
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRCAR" })]		:= D_GERCC->ZFA_CARGA
			oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRCTE" })]	    := ""//Iif(D_GERCC->QTD_CTE > 0,"Ok","") //Everson - 12/11/2021. Chamado 63590.
			
			// oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRCTE" })]		:= Iif(D_GERCC->QTD_CTE > 1,"+1",D_GERCC->NUM_CTE)
			// oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRSCTE"})]		:= Iif(D_GERCC->QTD_CTE > 1,"+1",D_GERCC->SER_CTE)
			// oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRAGP" })]		:= D_GERCC->ZF7_AGRCTE
			// oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRAGRP"})]		:= D_GERCC->AGR_CTE
			// oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRACHV"})]		:= D_GERCC->CHV_CTE
			// oEmitCC:aCols[Len(oEmitCC:aCols),Ascan(aHCrCC,{|x| AllTrim(x[2]) == "CRQTDC"})]		:= D_GERCC->QTD_CTE
					
			D_GERCC->(DbSkip())
			
		End
	
	Else
		Aadd(oEmitCC:aCols , Array(Len(aHCrCC) + 1) )
		oEmitCC:aCols[Len(oEmitCC:aCols), Len(oEmitCC:aCols[1]) ] := .F.		
	
	EndIf
	
	D_GERCC->(DbCloseArea())
	
	//
	oEmitCC:Refresh()
	
	//
	RestArea(aArea)
		
Return Nil
/*/{Protheus.doc} emiMDFL  
	Emite MDF-e em lote. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   03/07/2019
	@version 01
	/*/
Static Function emiMDFL()
	
	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local i		 	:= 1
	//Local cHash	 	:= ""
	//Local cDoc	 	:= ""
	//Local cDocSr	:= ""
	//Local cDateTime	:= ""
	Local cRoteiro	:= ""
	Local cDtEntr	:= ""
	//Local cIBGE		:= ""
	
	Private cCodZFA:= ""
	
	//
	If Len(oEmitMP:aCols) <= 0 .Or. (  Len(oEmitMP:aCols) > 0 .And. Empty(Alltrim(cValToChar(oEmitMP:aCols[oEmitMP:nAt,Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRROT" })]))) )
		MsgStop("Não há MDF-e a ser emitido.","Função emiMDFL(ADLOG057P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If ! MsgYesNo("Será(ão) emitido(s) " + cValToChar(Len(oEmitMP:aCols)) + " documento(s). Deseja prosseguir?","Função emiMDFL(ADLOG057P)")
		RestArea(aArea)
		Return Nil
	
	EndIf
	
	//
	For i := 1 To Len(oEmitMP:aCols)
	
		//
		cRoteiro:= Alltrim(cValToChar(oEmitMP:aCols[i,Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRROT" })]))
		cCodZFA	:= Alltrim(cValToChar(oEmitMP:aCols[i,Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRZFA" })]))
		
		//
		cDtEntr	:= DToS(oEmitMP:aCols[oEmitMP:nAt,Ascan(aHDcPEM,{|x| AllTrim(x[2]) == "CRDTE" })])	
	
		//
		MsAguarde({|| geraMDFE(cRoteiro,cDtEntr,,,.F.)},"Aguarde...","Emitindo MDF-e do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) ,.F.)
	
	Next i

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} encMDFL  
	Encerra MDF-e em lote. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   03/07/2019
	@version 01
	/*/
Static Function encMDFL()
	
	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local i		 	:= 1
	Local cHash	 	:= ""
	Local cDoc	 	:= ""
	Local cDocSr	:= ""
	Local cDateTime	:= ""
	Local cRoteiro	:= ""
	Local cDtEntr	:= ""
	Local cIBGE		:= ""
	
	//
	If Len(oPendMDF:aCols) <= 0 .Or. (  Len(oPendMDF:aCols) > 0 .And. Empty(Alltrim(cValToChar(oPendMDF:aCols[oPendMDF:nAt,Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRHASH" })]))) )
		MsgStop("Não há MDF-e a ser encerrado.","Função encMDFL(ADLOG057P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If ! MsgYesNo("Será(ão) encerrado(s) " + cValToChar(Len(oPendMDF:aCols)) + " documento(s). Deseja prosseguir?","Função encMDFL(ADLOG057P)")
		RestArea(aArea)
		Return Nil
	
	EndIf
	
	//
	aRetEnc := telaGen4()
			
	//
	If Len(aRetEnc) > 0
		cDateTime 	:= Alltrim(cValToChar(aRetEnc[1][1])) + Alltrim(cValToChar(aRetEnc[1][2]))
	
	Else
		RestArea(aArea)
		Return Nil		
	
	EndIf
	
	//
	For i := 1 To Len(oPendMDF:aCols)
		
		//
		cDoc  	:= Alltrim(cValToChar(oPendMDF:aCols[i,Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRNUMDOC" })]))
		cDocSr	:= Alltrim(cValToChar(oPendMDF:aCols[i,Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRSRDOC" })]))
		cHash 	:= Alltrim(cValToChar(oPendMDF:aCols[i,Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRHASH" })]))
		cRoteiro:= Alltrim(cValToChar(oPendMDF:aCols[i,Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRROT" })]))
		cDtEntr	:= DToS(oPendMDF:aCols[i,Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRDTE" })])
		
		//
		aItinierario:= itinerario(cRoteiro,cDtEntr)//Recupera o itinerário do veículo.
		
		//
		If Len(aItinierario) > 0
			cIBGE := Alltrim(cValToChar(aItinierario[1][2]))
			MsAguarde({||encerraMDF(cHash,cDateTime,cIBGE)} ,"Aguarde...","Processando MDF-e " + cDoc + "/" + cDocSr ,.F.)

		Else
			MsgStop("Não foi possível carregar o itinerário do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função encMDFL(ADLOG057P)")
			logZBE("FUNCAO encMDFL: NAO FOI POSSÍVEL CARREGAR O ITINERARIO DO ROTEIRO " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )

		EndIf
	
	Next i

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} conEmpresa  
	Consulta empresa. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   21/06/2019
	@version 01
	/*/
Static Function conEmpresa(oCargas,aHCr)
	
	//Variáveis.	
	Local aArea	 	:= GetArea()
	Local cTransp	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRTRA" })]))
	Local cLoja		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRLOJ" })]))
	
	//
	If Empty(cTransp) .Or. Empty(cLoja)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	MV_PAR01 := cTransp
	MV_PAR03 := cTransp
	MV_PAR02 := cLoja
	MV_PAR04 := cLoja
	consEmpres(.F.)
	Pergunte("OPHOS1",.F.)
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} funcHash  
	Opções documentos fiscais. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   19/06/2019
	@version 01
	/*/
Static Function funcHash(nOpc,cTpDoc)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	Local cDtEntr		:= ""
	Local cHash			:= Alltrim(cValToChar(oDocs:aCols[oDocs:nAt,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRHASH" })]))
	Local cDoc			:= Alltrim(cValToChar(oDocs:aCols[oDocs:nAt,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNUMDOC" })]))
	Local cDocSr		:= Alltrim(cValToChar(oDocs:aCols[oDocs:nAt,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSRDOC" })]))
	//Local cRoteiro		:= Alltrim(cValToChar(oDocs:aCols[oDocs:nAt,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRROT" })]))
	
	Local cHashM		:= Alltrim(cValToChar(oDocsM:aCols[oDocsM:nAt,Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRHASH" })]))
	Local cDocM			:= Alltrim(cValToChar(oDocsM:aCols[oDocsM:nAt,Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRNUMDOC" })]))
	Local cDocSrM		:= Alltrim(cValToChar(oDocsM:aCols[oDocsM:nAt,Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRSRDOC" })]))
	Local cRoteiroM		:= Alltrim(cValToChar(oDocsM:aCols[oDocsM:nAt,Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRROT" })]))

	//Everson - 27/01/2020. Chamado 054941.
	Local cHashC		:= Alltrim(cValToChar(oDocsC:aCols[oDocsC:nAt,Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRHASH" })]))
	Local cDocC			:= Alltrim(cValToChar(oDocsC:aCols[oDocsC:nAt,Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRNUMDOC" })]))
	//
	
	Local cJust			:= ""
	Local cDateTime		:= ""
	Local aItinierario	:= {}
	Local aRetEnc		:= {}
	Local cIBGE			:= ""

	//
	If (Empty(cHash) .And. cTpDoc == "1") .Or. (Empty(cHashM) .And. cTpDoc == "2") .Or. (Empty(cHashC) .And. cTpDoc == "5") //Everson - 27/01/2020. Chamado 054941.
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Obtém data de entrega do CT-e.
	If  cTpDoc == "1"
		cDtEntr	:= DToS(oDocs:aCols[oDocs:nAt,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTE" })])
	
	ElseIf  cTpDoc == "2"
		cDtEntr	:= DToS(oDocsM:aCols[oDocsM:nAt,Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRDTE" })])
		
	EndIf
	
	//
	If nOpc == 1     //Consulta CT-e.
		MsAguarde({||consulCTE(cHash,1)},"Aguarde...","Processando CT-e " + cDoc + "/" + cDocSr ,.F.)
					
	ElseIf nOpc == 2 //Download pdf do CT-e.
		MsAguarde({||pdfCTEdow(cHash)}  ,"Aguarde...","Processando CT-e " + cDoc + "/" + cDocSr ,.F.)
		
	ElseIf nOpc == 3 //Download xml do CT-e.
		MsAguarde({||xmlCTEdow(cHash)}  ,"Aguarde...","Processando CT-e " + cDoc + "/" + cDocSr ,.F.)
		
	ElseIf nOpc == 4 //Cancela CT-e.
		
		//
		If ! Empty(Alltrim(cValToChar(oDocs:aCols[oDocs:nAt,Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPEDC" })])))
			MsgStop("Não é possível cancelar o documento, pois há pedido de compra vinculado.","Função funcHash(ADLOG057P)")
			
		Else
			cJust :=  Alltrim(cValToChar(telGen2(1)))
			If ! Empty(cJust)
				MsAguarde({||cancCTE(cHash,cJust)}  ,"Aguarde...","Processando CT-e " + cDoc + "/" + cDocSr ,.F.)
		
			EndIf
		
		EndIf
				
	ElseIf nOpc == 5 //Consulta MDF-e.
		MsAguarde({||consulMDF(cHashM,1)},"Aguarde...","Processando MDF-e " + cDoc + "/" + cDocSr ,.F.)
		
	ElseIf nOpc == 6 //Encerra MDF-e.
		
		//
		aRetEnc := telaGen4()
				
		//
		If Len(aRetEnc) > 0

			//
			cDateTime 	:= Alltrim(cValToChar(aRetEnc[1][1])) + Alltrim(cValToChar(aRetEnc[1][2]))
			aItinierario:= itinerario(cRoteiroM,cDtEntr)//Recupera o itinerário do veículo.
			
			//
			If Len(aItinierario) > 0
				
				//
				cIBGE := Alltrim(cValToChar(aItinierario[1][2]))
				MsAguarde({||encerraMDF(cHashM,cDateTime,cIBGE)} ,"Aguarde...","Processando MDF-e " + cDocM + "/" + cDocSrM ,.F.)
	
			Else
				MsgStop("Não foi possível carregar o itinerário do roteiro " + cRoteiroM + "-" + DToC(SToD(cDtEntr)) + ".","Função selMDFEFun(ADLOG057P)")
				logZBE("FUNCAO selMDFEFun: NAO FOI POSSÍVEL CARREGAR O ITINERARIO DO ROTEIRO " + cRoteiroM + "-" + DToC(SToD(cDtEntr)) )
	
			EndIf
		
		EndIf

	
	ElseIf nOpc == 7 //Download pdf MDF-e.
		MsAguarde({||pdfMDFdow(cHashM)} ,"Aguarde...","Processando MDF-e " + cDocM + "/" + cDocSrM ,.F.)
		
	ElseIf nOpc == 8 //Download xml MDF-e.
		MsAguarde({||xmlMDFDow(cHashM)} ,"Aguarde...","Processando MDF-e " + cDocM + "/" + cDocSrM ,.F.)
		
	ElseIf nOpc == 9 //Cancela MDF-e.
		cJust :=  Alltrim(cValToChar(telGen2(2)))
		If ! Empty(cJust)
			MsAguarde({||cancMDF(cHashM,cJust)}  ,"Aguarde...","Processando MDF-e " + cDocM + "/" + cDocSrM ,.F.)
	
		EndIf

	//Everson - 27/01/2020.
	ElseIf nOpc == 10 //Consulta de CIOT.
		MsAguarde({||consCIOT(cHashC,1)}  ,"Aguarde...","Processando CIOT " + cDocC,.F.)

	ElseIf nOpc == 11 //Download pdf de CIOT.
		MsAguarde({||pdfCIOdow(cHashC)}  ,"Aguarde...","Processando CIOT " + cDocC,.F.)

	ElseIf nOpc == 12 //Download xml de CIOT.
		MsAguarde({||xmlCIOdow(cHashC)}  ,"Aguarde...","Processando CIOT " + cDocC,.F.)

	ElseIf nOpc == 13 //Cancela CIOT.
		cJust :=  Alltrim(cValToChar(telGen2(3)))
		If ! Empty(cJust)
			MsAguarde({||cancCIOT(cHashC,cJust)}  ,"Aguarde...","Processando CIOT " + cDocC,.F.)
	
		EndIf

	ElseIf nOpc == 14 //Encerra CIOT.
		MsAguarde({||encCIOT(cHashC)}  ,"Aguarde...","Processando CIOT " + cDocC,.F.)
					
	EndIf
	//
	
	//
	carDocs(.T.,cTpDoc)
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} carDocs  
	Carrega informações dos CT-es. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   19/06/2019
	@version 01
	/*/
Static Function carDocs(lCarrega,cTipo)
	
	//Variáveis.	
	Local aArea			:= GetArea()
	Local cRoteiro		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRROT" })]))
	Local cDtEntr		:= ""
	Local cQuery		:= ""
	Local cStatus		:= ""
	Local cMsgStatus 	:= ""
	Local cTipoDoc		:= ""
	Local oCor   		:= Nil
	
	Default lCarrega 	:= .F.
	Default cTipo		:= "1"
	
	//
	nPosCarga := oCargas:nAt
				
	//
	If ! lCarrega
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If cTipo == "1"
		oDocs:aCols := {}
		Aadd(oDocs:aCols , Array(Len(aHDc) + 1) )
		oDocs:aCols[Len(oDocs:aCols), Len(oDocs:aCols[1]) ] := .F.
		oDocs:Refresh()
	
	ElseIf cTipo == "2"
		oDocsM:aCols := {}
		Aadd(oDocsM:aCols , Array(Len(aHDcM) + 1) )
		oDocsM:aCols[Len(oDocsM:aCols), Len(oDocsM:aCols[1]) ] := .F.
		oDocsM:Refresh()
		
	ElseIf cTipo == "3"	
		oVerb:aCols := {}
		Aadd(oVerb:aCols , Array(Len(aHAv) + 1) )
		oVerb:aCols[Len(oVerb:aCols), Len(oVerb:aCols[1]) ] := .F.
		oVerb:Refresh()
		
	ElseIf cTipo == "4"
		oPendMDF:aCols := {}
		Aadd(oPendMDF:aCols , Array(Len(aHDcMP) + 1) )
		oPendMDF:aCols[Len(oPendMDF:aCols), Len(oPendMDF:aCols[1]) ] := .F.
		oPendMDF:Refresh()

	ElseIf cTipo == "5" //Everson - 06/03/2020. Chamado 054941.
		oDocsC:aCols := {}
		Aadd(oDocsC:aCols , Array(Len(aHDcC) + 1) )
		oDocsC:aCols[Len(oDocsC:aCols), Len(oDocsC:aCols[1]) ] := .F.
		oDocsC:Refresh()

	ElseIf cTipo == "6" //Everson - 06/03/2020. Chamado 054941.
		oPendCIO:aCols := {}
		Aadd(oPendCIO:aCols , Array(Len(aHDcCI) + 1) )
		oPendCIO:aCols[Len(oPendCIO:aCols), Len(oPendCIO:aCols[1]) ] := .F.
		oPendCIO:Refresh()

	EndIf
	
	//
	If Empty(cRoteiro) .And. cTipo <> "4" .And. cTipo <> "6"
		MsgStop("Não há roteiro selecionado","Função carDocs(ADLOG057P)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If Empty( Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDTE" })] )))
		RestArea(aArea)
		Return Nil
			
	EndIf

	//
	cDtEntr	:= DToS(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDTE" })])
	oTxtCTe:SetText("Funções do CT-e | Roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )
	oTxTMDF:SetText("Funções do MDF-e | Roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )
	oTxtAveb:SetText("Averbação | Roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )
	oTxTMCIO:SetText("Funções do CIOT | Roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr))) //Everson - 06/03/2020. Chamado 054941.

	//Monta script sql.
	cQuery := ""
	
	//
	If cTipo <> "4" .And. cTipo <> "5" .And. cTipo <> "6"
		cQuery += " SELECT " 
		cQuery += " ZFK_TRANSP " 
		cQuery += " ,ZFK_LOJA " 
		cQuery += " ,ZFK_NMTRAN " 
		cQuery += " ,ZFK_CARGA " 
		cQuery += " ,ZFK_DTENTR " 
		cQuery += " ,ZFK_ROTEIR " 
		cQuery += " ,ZFK_SEQENV " 
		cQuery += " ,ZFK_TPDOC " 
		cQuery += " ,ZFK_NUMDOC " 
		cQuery += " ,ZFK_SERDOC " 
		cQuery += " ,ZFK_STATUS " 
		cQuery += " ,ZFK_HASH " 
		cQuery += " ,ZFK_DATA " 
		cQuery += " ,ZFK_PLACA " 
		cQuery += " ,ZFK_OPHOS "  
		cQuery += " ,ZFK_CHAVE " 
		cQuery += " ,ZFK_PROTEM " 
		cQuery += " ,ZFK_PROTCA " 
		cQuery += " ,ZFK_REBOQU " 
		cQuery += " ,ZFK_PROENC "
		cQuery += " ,ZFK_PEDCOM "
	
	EndIf
	
	//
	If cTipo == "1" .Or. cTipo == "2"
		cQuery += " ,SUM(ZFK_VALOR) AS ZFK_VALOR, AVG(ZFK_VLRICM) AS  ZFK_VLRICM " //Everson³14/08/19³044314.
		
	ElseIf cTipo == "3"
		cQuery += " ,ZFK_NOTA, ZFK_SERIE, ZFK_PRTAVE, ZFK_MSGAVE, ZFK_STAAVE, ZFK_TPDAVE,ZFK_TPAVER "
		
	ElseIf cTipo == "4"
		cQuery += " SELECT DISTINCT ZFK_DTENTR, ZFK_ROTEIR, ZFK_NUMDOC, ZFK_SERDOC, ZFK_SEQENV, ZFK_OPHOS, ZFK_HASH, ZFK_STATUS, ZFK_TPDOC, ZFK_PLACA "

	ElseIf cTipo == "5" .Or. cTipo == "6"//Everson - 06/03/2020. Chamado 054941.
		
		cQuery += " SELECT " 
		cQuery += " ZFK_TRANSP " 
		cQuery += " ,ZFK_LOJA " 
		cQuery += " ,ZFK_NMTRAN " 
		cQuery += " ,ZFK_CARGA " 
		cQuery += " ,ZFK_DTENTR " 
		cQuery += " ,ZFK_ROTEIR " 
		cQuery += " ,ZFK_SEQENV " 
		cQuery += " ,ZFK_TPDOC " 
		cQuery += " ,ZFK_NUMDOC " 
		cQuery += " ,ZFK_SERDOC " 
		cQuery += " ,ZFK_STATUS " 
		cQuery += " ,ZFK_HASH " 
		cQuery += " ,ZFK_DATA " 
		cQuery += " ,ZFK_PLACA " 
		cQuery += " ,ZFK_OPHOS "  
		cQuery += " ,ZFK_CHAVE " 
		cQuery += " ,ZFK_PROTEM " 
		cQuery += " ,ZFK_PROTCA " 
		cQuery += " ,ZFK_REBOQU " 
		cQuery += " ,ZFK_PROENC "
		cQuery += " ,ZFK_PEDCOM "
		cQuery += " ,ZFK_NUMCIO "

	EndIf
	
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
	
	cQuery += " WHERE " 
		cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
		cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
		
		//
		If cTipo == "3" 
			cQuery += " AND ZFK_STAAVE <> '' "
		
		EndIf
		
		//
		If cTipo <> "4" .And. cTipo <> "6"
			cQuery += " AND ZFK_DTENTR = '" + cDtEntr  + "' " 
			cQuery += " AND ZFK_ROTEIR = '" + cRoteiro   + "' " 
			
		Else
			cQuery += " AND ZFK_DTENTR BETWEEN '" + DToS(MV_PAR01)  + "' AND '" + DToS(MV_PAR02) + "' " 
			cQuery += " AND ZFK_STATUS = '1' "
			
		EndIf
		
		//
		cQuery += " AND ZFK_TPDOC = '" + Iif(cTipo == "3","1",Iif(cTipo == "4","2",Iif(cTipo == "5" .Or. cTipo == "6","3",cTipo))) + "' " //Everson - 06/03/2020. Chamado 054941.
		cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	
	//
	If cTipo == "1" .Or. cTipo == "2"
		cQuery += " GROUP BY "
			cQuery += " ZFK_TRANSP, " 
			cQuery += " ZFK_LOJA, " 
			cQuery += " ZFK_NMTRAN, " 
			cQuery += " ZFK_CARGA, " 
			cQuery += " ZFK_DTENTR, " 
			cQuery += " ZFK_ROTEIR, " 
			cQuery += " ZFK_SEQENV, " 
			cQuery += " ZFK_TPDOC, " 
			cQuery += " ZFK_NUMDOC, " 
			cQuery += " ZFK_SERDOC, " 
			cQuery += " ZFK_STATUS, " 
			cQuery += " ZFK_HASH, " 
			cQuery += " ZFK_DATA, " 
			cQuery += " ZFK_PLACA, " 
			cQuery += " ZFK_OPHOS, "  
			cQuery += " ZFK_CHAVE, " 
			cQuery += " ZFK_PROTEM, " 
			cQuery += " ZFK_PROTCA, " 
			cQuery += " ZFK_REBOQU, " 
			cQuery += " ZFK_PROENC, ZFK_PEDCOM "
			cQuery += " ORDER BY ZFK_DTENTR, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, CAST(ZFK_SEQENV AS INTEGER) "
	
	ElseIf 	cTipo == "3"
		cQuery += " ORDER BY ZFK_DTENTR, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, ZFK_NOTA, ZFK_SERIE "
		
	ElseIf cTipo == "4"
		cQuery += " ORDER BY ZFK_DTENTR, ZFK_ROTEIR, ZFK_PLACA, ZFK_NUMDOC, ZFK_SERDOC, ZFK_SEQENV, ZFK_OPHOS, ZFK_HASH, ZFK_STATUS, ZFK_TPDOC "

	ElseIf cTipo == "6"
		cQuery += " ORDER BY ZFK_DTENTR, ZFK_ROTEIR, ZFK_PLACA, ZFK_NUMCIO, ZFK_SERDOC, ZFK_SEQENV, ZFK_OPHOS, ZFK_HASH, ZFK_STATUS, ZFK_TPDOC "

	EndIf 
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - carDocs - cQuery " + cQuery )
	
	//
	If Select("D_DOCS") > 0
		D_DOCS->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_DOCS"
	DbSelectArea("D_DOCS")
	D_DOCS->(DbGoTop())
	
	//
	If D_DOCS->(Eof())
		//MsgStop("Não há " + tabelaDoc(cTipo) + " emitido para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + "." ,"Função carDocs(ADLOG057P)")
		D_DOCS->(DbCloseArea())
		RestArea(aArea)
		Return Nil
		
	EndIf
					
	//
	If cTipo == "1"
		oDocs:aCols := {}
	
	ElseIf cTipo == "2"
		oDocsM:aCols:= {}
	
	ElseIf cTipo == "3"
		oVerb:aCols:= {}

	ElseIf cTipo == "4"
		oPendMDF:aCols:= {}

	ElseIf cTipo == "5"
		oDocsC:aCols:= {}

	ElseIf cTipo == "6"
		oPendCIO:aCols:= {}

	EndIf
	
	//
	While ! D_DOCS->(Eof())
		
		//
		cStatus := Alltrim(cValToChar(D_DOCS->ZFK_STATUS))
		cMsgStatus := tlbStatus(cStatus,1)
		cTipoDoc := tabelaDoc(Alltrim(cValtoChar(D_DOCS->ZFK_TPDOC)))
		
		If cMsgStatus == 'Processando'
			oCor := LoadBitmap( GetResources(), "BR_AMARELO")
			
		ElseIf cMsgStatus == 'Emitido'
			oCor := LoadBitmap( GetResources(), "BR_VERDE")
		    
		ElseIf cMsgStatus == 'Cancelado'
			oCor := LoadBitmap( GetResources(), "BR_CANCEL")
	
		ElseIf cMsgStatus == 'Rejeitado'
			oCor := LoadBitmap( GetResources(), "BR_PINK")
			
		ElseIf cMsgStatus == 'Contingência'
			oCor := LoadBitmap( GetResources(), "BR_MARROM")
		
		ElseIf cMsgStatus == 'Hash não localizado'
			oCor := LoadBitmap( GetResources(), "BR_VIOLETA")
		
		ElseIf cMsgStatus == 'Denegado'
			oCor := LoadBitmap( GetResources(), "BR_PRETO")
		
		ElseIf cMsgStatus == 'Encerrado' 
			oCor := LoadBitmap( GetResources(), "BR_AZUL")
		 
		ElseIf cMsgStatus == 'Não emitido' 
			oCor := LoadBitmap( GetResources(), "BR_VERMELHO")
		
		Else
			oCor := LoadBitmap( GetResources(), "BR_LARANJA")
			
		EndIf
		
		//
		If cTipo == "1" //CT-e.
			Aadd(oDocs:aCols , Array(Len(aHDc) + 1) )
			oDocs:aCols[Len(oDocs:aCols), Len(oDocs:aCols[1]) ] := .F.
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "LEG" })]			:= oCor
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRDTE" })]		:= SToD(cDtEntr)
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRROT" })]		:= cRoteiro

			//Everson - 20/09/2021. Chamado 15138.
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTRA" })]		:= D_DOCS->ZFK_TRANSP
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRLOJ" })]		:= D_DOCS->ZFK_LOJA
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNMT" })]		:= D_DOCS->ZFK_NMTRAN
			//

			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSTATUS" })]	:= cMsgStatus
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRTPDOC" })] 	:= cTipoDoc
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRNUMDOC" })] 	:= D_DOCS->ZFK_NUMDOC
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSRDOC" })] 	:= D_DOCS->ZFK_SERDOC
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRSEQENV" })] 	:= D_DOCS->ZFK_SEQENV
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRVALOR" })] 	:= D_DOCS->ZFK_VALOR
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRICMS" })]		:= D_DOCS->ZFK_VLRICM //Everson³14/08/19³044314.
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_OPHOS
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRHASH" })] 		:= D_DOCS->ZFK_HASH
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRCHAVE" })] 	:= D_DOCS->ZFK_CHAVE
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPEMI" })] 		:= D_DOCS->ZFK_PROTEM
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPCAN" })] 		:= D_DOCS->ZFK_PROTCA
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPENC" })] 		:= D_DOCS->ZFK_PROENC
			oDocs:aCols[Len(oDocs:aCols),Ascan(aHDc,{|x| AllTrim(x[2]) == "CRPEDC" })] 		:= D_DOCS->ZFK_PEDCOM
		
		ElseIf cTipo == "2" //MDF-e.
			Aadd(oDocsM:aCols , Array(Len(aHDcM) + 1) )
			oDocsM:aCols[Len(oDocsM:aCols), Len(oDocsM:aCols[1]) ] := .F.
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "LEG" })]		:= oCor
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRDTE" })]	:= SToD(cDtEntr)
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRROT" })]	:= cRoteiro

			//Everson - 20/09/2021. Chamado 15138
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRTRA" })]	:= D_DOCS->ZFK_TRANSP
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRLOJ" })]	:= D_DOCS->ZFK_LOJA
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRNMT" })]	:= D_DOCS->ZFK_NMTRAN
			//

			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRSTATUS" })]	:= cMsgStatus
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRTPDOC" })] 	:= cTipoDoc
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRNUMDOC" })]	:= D_DOCS->ZFK_NUMDOC
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRSRDOC" })] 	:= D_DOCS->ZFK_SERDOC
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRSEQENV" })]	:= D_DOCS->ZFK_SEQENV
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_OPHOS
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRHASH" })] 	:= D_DOCS->ZFK_HASH
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRCHAVE" })] 	:= D_DOCS->ZFK_CHAVE
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRPEMI" })] 	:= D_DOCS->ZFK_PROTEM
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRPCAN" })] 	:= D_DOCS->ZFK_PROTCA
			oDocsM:aCols[Len(oDocsM:aCols),Ascan(aHDcM,{|x| AllTrim(x[2]) == "CRPENC" })] 	:= D_DOCS->ZFK_PROENC
			
		ElseIf cTipo == "3"		
			Aadd(oVerb:aCols , Array(Len(aHAv) + 1) )
			oVerb:aCols[Len(oVerb:aCols), Len(oVerb:aCols[1]) ] := .F.
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRDTE" })]		:= SToD(cDtEntr)
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRROT" })]		:= cRoteiro

			//Everson - 20/09/2021. Chamado 15138
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRTRA" })]		:= D_DOCS->ZFK_TRANSP
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRLOJ" })]		:= D_DOCS->ZFK_LOJA
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRNMT" })]		:= D_DOCS->ZFK_NMTRAN
			//

			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRSTATUS" })]	:= D_DOCS->ZFK_STAAVE
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRTPDOC" })] 	:= D_DOCS->ZFK_TPDAVE
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRNUMDOC" })]	:= D_DOCS->ZFK_NOTA
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRSRDOC" })] 	:= D_DOCS->ZFK_SERIE
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_MSGAVE
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRPENC" })]		:= D_DOCS->ZFK_TPAVER
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRPAVE" })]		:= D_DOCS->ZFK_PRTAVE
			oVerb:aCols[Len(oVerb:aCols),Ascan(aHAv,{|x| AllTrim(x[2]) == "CRHASH" })]		:= D_DOCS->ZFK_HASH	
		
		ElseIf cTipo == "4"					
			Aadd(oPendMDF:aCols , Array(Len(aHDcMP) + 1) )
			oPendMDF:aCols[Len(oPendMDF:aCols), Len(oPendMDF:aCols[1]) ] := .F.
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRDTE" })]		:= SToD(D_DOCS->ZFK_DTENTR)
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRROT" })]		:= D_DOCS->ZFK_ROTEIR
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRVEI" })] 		:= D_DOCS->ZFK_PLACA	
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRNUMDOC" })]	:= D_DOCS->ZFK_NUMDOC
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRSRDOC" })] 	:= D_DOCS->ZFK_SERDOC			
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRSTATUS" })]	:= cMsgStatus
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRSEQENV" })]	:= D_DOCS->ZFK_SEQENV			
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_OPHOS
			oPendMDF:aCols[Len(oPendMDF:aCols),Ascan(aHDcMP,{|x| AllTrim(x[2]) == "CRHASH" })] 		:= D_DOCS->ZFK_HASH
		
		ElseIf cTipo == "5"	 //Everson - 06/03/2020. Chamado 053296.
			Aadd(oDocsC:aCols , Array(Len(aHDcC) + 1) )
			oDocsC:aCols[Len(oDocsC:aCols), Len(oDocsC:aCols[1]) ] := .F.
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "LEG" })]		:= oCor
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRDTE" })]	:= SToD(cDtEntr)
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRROT" })]	:= cRoteiro
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRSTATUS" })]	:= cMsgStatus
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRTPDOC" })] 	:= cTipoDoc
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRNUMDOC" })] := D_DOCS->ZFK_NUMCIO
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRSEQENV" })] := D_DOCS->ZFK_SEQENV
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CROPHOS" })] 	:= D_DOCS->ZFK_OPHOS
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRHASH" })] 	:= D_DOCS->ZFK_HASH
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRPEMI" })] 	:= D_DOCS->ZFK_PROTEM
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRPCAN" })] 	:= D_DOCS->ZFK_PROTCA
			oDocsC:aCols[Len(oDocsC:aCols),Ascan(aHDcC,{|x| AllTrim(x[2]) == "CRPENC" })] 	:= D_DOCS->ZFK_PROENC

		ElseIf cTipo == "6"	 //Everson - 06/03/2020. Chamado 053296.
			Aadd(oPendCIO:aCols , Array(Len(aHDcCI) + 1) )
			oPendCIO:aCols[Len(oPendCIO:aCols), Len(oPendCIO:aCols[1]) ] := .F.
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "LEG" })]		 := oCor
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRDTE" })]	 := SToD(cDtEntr)
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRROT" })]	 := cRoteiro
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRSTATUS" })] := cMsgStatus
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRTPDOC" })]  := cTipoDoc
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRNUMDOC" })] := D_DOCS->ZFK_NUMCIO
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRSEQENV" })] := D_DOCS->ZFK_SEQENV
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CROPHOS" })]  := D_DOCS->ZFK_OPHOS
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRHASH" })] 	 := D_DOCS->ZFK_HASH
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRPEMI" })] 	 := D_DOCS->ZFK_PROTEM
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRPCAN" })] 	 := D_DOCS->ZFK_PROTCA
			oPendCIO:aCols[Len(oPendCIO:aCols),Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRPENC" })] 	 := D_DOCS->ZFK_PROENC
						
		EndIf
		
		D_DOCS->(DbSkip())
		
	End
	D_DOCS->(DbCloseArea())
	
	//
	If cTipo == "1"
		oDocs:Refresh()
	
	ElseIf cTipo == "2"
		oDocsM:Refresh()
		
	ElseIf cTipo == "3"
		oVerb:Refresh()

	ElseIf cTipo == "4"
		oPendMDF:Refresh()

	ElseIf cTipo == "5" //Everson - 06/03/2020. Chamado 053296.
		oDocsC:Refresh()

	ElseIf cTipo == "6" //Everson - 06/03/2020. Chamado 053296.
		oPendCIO:Refresh()

	EndIf
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} gerMDFE  
	Gera MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   18/06/2019
	@version 01
	/*/
Static Function gerMDFE(aHCr,oCargas)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local cDtEntr	:= ""
	Local cRoteiro	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRROT" })]))
	Local cMDF		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRMDF" })]))
	
	Private cCodZFA		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRZFA" })]))
	Private cCodOcorr	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CROCO" })]))
	
	//
	If Empty(cRoteiro)
		RestArea(aArea)
		Return Nil
			
	EndIf

	//Everson - 24/01/2020. Chamado 054941.
	If ! chkBloqueio(cCodZFA)
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	cDtEntr	:= DToS(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDTE" })])
	
	//
	If ! Empty(cMDF)
		MsgStop("Já há MDF-e emitido para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ", ou não é necessária a emissão.","Função gerMDFE(ADLOG057P)")
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If ! MsgYesNo("Deseja emitir MDF-e para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + "?","Função gerMDFE(ADLOG057P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	MsAguarde({|| geraMDFE(cRoteiro,cDtEntr)},"Aguarde...","Emitindo MDF-e do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) ,.F.)

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} cfgMV  
	Emissão de CT-e/MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   23/05/2019
	@version 01
	/*/
Static Function cfgMV()

	//Variáveis.
	Local aArea			:= GetArea()
	//Local oSay1			:= Nil
	Local oSBtn01		:= Nil
	Local oSBtn02		:= Nil

	Private oTelMV		:= Nil
	Private oGetDados	:= Nil
	Private aAltera		:= {}
	Private aHeader		:= {}
	Private aCols		:= {}

	//Cria o objeto MSDialog.
	oTelMV:= MSDIALOG():Create()
	oTelMV:cName     := "oTelMV"
	oTelMV:cCaption  := "Configurações de Parâmetros"
	oTelMV:nLeft     := 34
	oTelMV:nTop      := 222
	oTelMV:nWidth    := 800
	oTelMV:nHeight   := 400
	oTelMV:lShowHint := .F.
	oTelMV:lCentered := .T.
		
		//Criação de botões.
		oSBtn01:= SBUTTON():Create(oTelMV)
		oSBtn01:cName		:= "oSBtn01"
		oSBtn01:cCaption 	:= "Gravar"
		oSBtn01:nLeft 		:= 675
		oSBtn01:nTop 		:= 330
		oSBtn01:nWidth 		:= 50
		oSBtn01:nHeight 	:= 20
		oSBtn01:lShowHint 	:= .F.
		oSBtn01:lReadOnly 	:= .F.
		oSBtn01:Align 		:= 0
		oSBtn01:lVisibleControl := .T.
		oSBtn01:bAction := {|| MsgRun("Gravando Informações...","Aguarde",{|| GravarMV() }) }
	
		//Criação de botões.
		oSBtn02:= SBUTTON():Create(oTelMV)
		oSBtn02:cName		:= "oSBtn02"
		oSBtn02:cCaption 	:= "Cancelar"
		oSBtn02:nLeft 		:= 735
		oSBtn02:nTop 		:= 330
		oSBtn02:nWidth 		:= 50
		oSBtn02:nHeight 	:= 20
		oSBtn02:lShowHint 	:= .F.
		oSBtn02:lReadOnly 	:= .F.
		oSBtn02:Align 		:= 0
		oSBtn02:lVisibleControl := .T.
		oSBtn02:bAction := {||oTelMV:End()}
	
		//Cria o aHeader.
		Aadd(aHeader,{"Parâmetro" ,"MV"       ,""	, 010,0,"","","C","",""})
		Aadd(aHeader,{"Descrição" ,"DESC"     ,""	, 050,0,"","","C","",""})
		Aadd(aHeader,{"Conteúdo"  ,"CONTEUDO" ,""	, 200,0,"","","C","",""})
	
		//Campo que pode ser alterado.
		aAltera := {"CONTEUDO"}
	
		//Criar objeto MsNewGetDados.
		oGetDados := MsNewGetDados():New(005,002,151,397,GD_UPDATE,"Allwaystrue()","Allwaystrue()","",aAltera,Nil,999,Nil,Nil,Nil,oTelMV,aHeader,@aCols) 

		//
		TGroup():Create(oTelMV,156,002,185,397,"",,,.T.)

	//Ativa a janela e preencher o aCols.
	oTelMV:Activate(,,,.T.,{||.T.},,{||prConfigMV()})
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} prConfigMV  
	Preenche os parâmetros da integração. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   23/05/2019
	@version 01
	/*/
Static Function prConfigMV()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cCNPJ 	:= GetMv("MV_#CTECNP")  //CNPJ Ad'oro.
	Local cIE		:= GetMv("MV_#CTEIES")  //I.E. Ad'oro.
	Local cConsEmp 	:= GetMv("MV_#CONEMP")  //Consulta Empresa.
	Local cChvConEm	:= GetMv("MV_#CONSEM")  //Chave consulta empresa.
	Local cAmbConEm	:= GetMv("MV_#AMBCEM")  //Ambiente consulta empresa.
	Local cPrazo	:= GetMv("MV_#TEMPOP")  //Prazo da consulta empresa.
	Local nTotNf	:= GetMv("MV_#QTDNFE")  //Quantidade mínima de notas fiscais para utilização da portaria CAT-121.
	Local nPorc		:= GetMv("MV_#CTEPOR")  //Porcentagem a ser aplicada sobre o valor do frete para geração do CT-e.
	Local cGERCTE	:= GetMv("MV_#ENVCTE")  //Envio para Geração de Ct-e.
	Local cGERCUS	:= GetMv("MV_#CUSCTE")  //Envio CT-e emissão em lote.
	Local cTpComp	:= GetMv("MV_#TPEMCO")  //Tipo de emissão de complemento.
	Local cConsCTE 	:= GetMv("MV_#CONCTE")  //Consulta CT-e.
	Local cXMLCTE  	:= GetMv("MV_#XMLCTE")  //Download XML Ct-e.
	Local cPDFCTE  	:= GetMv("MV_#PDFCTE")  //Download PDF Ct-e.
	Local cCancCTE 	:= GetMv("MV_#CANCTE")  //Cancelar CT-e.
	Local cReeAvb	:= GetMv("MV_#REEAVB")  //Reenvio de averbação.
	Local cGERMDF  	:= GetMv("MV_#ENVMDF")  //Envio geração de MDF-e.
	Local cConsMDF 	:= GetMv("MV_#CONMDF")  //Consulta MDF-e.
	Local cXMLMDF  	:= GetMv("MV_#XMLMDF")  //Download XML MDF-e.
	Local cPDFMDF  	:= GetMv("MV_#PDFMDF")  //Download PDF MDF-e.
	Local cEncMDF	:= GetMv("MV_#ENCMDF")  //Encerrar MDF-e.
	Local cCancMDF 	:= GetMv("MV_#CANMDF")  //Cancelar MDF-e.
	Local lGravar 	:= GetMv("MV_#GRVTXT")  //Gerar TXT.
	Local cLocais	:= GetMv("MV_#CTELOC")  //Local Padrão de emissão de CT-e customizado.
	Local cCabNFE	:= GetMv("MV_#CABNF")   //Cabeçalho da NF-e.
	Local cRodNFE	:= GetMv("MV_#RODNF")   //Rodapé da NF-e.
	Local cCamin	:= GetMv("MV_#ARQCP")   //Caminho para salvar arquivo PDF e XML.
	Local nNumProc	:= GetMv("MV_#NVPROC")	//Número de vezes para consulta de status do documento.
	Local lAbrArq	:= GetMv("MV_#DOWARQ")	//Faz download e abre o arquivo.
	Local cApolic	:= GetMv("MV_#CTEAVB")	//Apólice do seguro.
	Local cPstXML	:= GetMv("MV_#SLVCTE")	//Pasta para salvar XML de CT-e.
	Local cUFHab	:= GetMv("MV_#UFLCAT")  //UF habilitada CAT-121.
	Local cUFHabT	:= GetMv("MV_#UFTCAT")  //UF habilitada CAT-121 transportadora. //Everson - 15/04/2021 - Chamado 12355.
	Local cEstOMDF  := GetMv("MV_#ESTMDF")  //UF de clientes em que é necessário a emissão de MDF-e, mesmo com CT-e emitido pela CAT-121. //Everson - 28/04/2022 - Chamado 70593.
	Local cTranOMDF := GetMv("MV_#UFTCAM")  //UF de transportadora em que é necessário a emissão de MDF-e, mesmo com quantidade de notas permitada pela CAT-121. //Everson - 28/04/2022 - Chamado 70593.
	
	
	Local nTmpBlq	:= GetMv("MV_#TMPBLQ")  //Tempo de espera para envio, após ocorrer erro. //Everson - 24/01/2020. Chamado 054941.

	//Everson - 27/01/2020. Chamado 054941.
	Local cGERCIO  	:= GetMv("MV_#ENVCIO")  //Envio geração de CIOT.
	Local cConsCIO 	:= GetMv("MV_#CONCIO")  //Consulta CIOT.
	Local cXMLCIO  	:= GetMv("MV_#XMLCIO")  //Download XML CIOT.
	Local cPDFCIO  	:= GetMv("MV_#PDFCIO")  //Download PDF CIOT.
	Local cEncCIO	:= GetMv("MV_#ENCCIO")  //Encerrar CIOT.
	Local cCancCIO 	:= GetMv("MV_#CANCIO")  //Cancelar CIOT.
	Local cAlDes	:= GetMv("MV_#DSPCIO")  //Carga de alto desempenho? //Everson - 02/03/2020. Chamado 053926.
	Local cEmtMDF	:= GetMv("MV_#ESGRMD")  //Emite MDF-e? //Everson - 12/02/2020. Chamado 054941.
	//

	////Everson - 06/03/2020. Chamado 054941.
	Local cEmtCIO	:= GetMv("MV_#ESGRCI")
	Local cEmtCTE	:= GetMv("MV_#ESGRCT") 
	//

	Local aDados	:= {}
	Local i			:= 0
	
	//Consulta empresa.
	Aadd(aDados,{"MV_#CTECNP","CNPJ Empresa",cCNPJ})
	Aadd(aDados,{"MV_#CTEIES","I.E. Empresa",cIE  })
	Aadd(aDados,{"MV_#CONEMP","Consulta Empresa",cConsEmp})
	Aadd(aDados,{"MV_#CONSEM","Chave consulta Empresa",cChvConEm})
	Aadd(aDados,{"MV_#AMBCEM","Ambiente consulta Empresa",cAmbConEm})
	Aadd(aDados,{"MV_#TEMPOP","Prazo da consulta empresa",cPrazo})
	
	//CT-e
	Aadd(aDados,{"MV_#ESGRCT","Emite CT-e Frt Abatido,Frt Frango Vivo,Frt Ovo,Frt Pintinho,Frt Racao",cEmtCTE}) //Everson - 06/03/2020. Chamado 054941.
	Aadd(aDados,{"MV_#QTDNFE","Quantidade mínima de notas fiscais para utilização da portaria CAT-121",cValToChar(nTotNf)})
	Aadd(aDados,{"MV_#UFLCAT","UF habilitada CAT-121",cUFHab})
	Aadd(aDados,{"MV_#UFTCAT","UF habilitada CAT-121 transportadora",cUFHabT}) //Everson - 15/04/2021 - Chamado 12355.
	Aadd(aDados,{"MV_#ESTMD" ,"UF de clientes em que é necessário a emissão de MDF-e, mesmo com CT-e emitido pela CAT-121",cEstOMDF}) //Everson - 28/04/2022 - Chamado 70593.
	Aadd(aDados,{"MV_#UFTCAM","UF de transportadora em que é necessário a emissão de MDF-e, mesmo com quantidade de notas permitada pela CAT-121",cTranOMDF}) //Everson - 28/04/2022 - Chamado 70593.
	
	Aadd(aDados,{"MV_#CTEPOR","Porc Frt Abatido,Frt Frango Vivo,Frt Ovo,Frt Pintinho,Frt Racao",nPorc})
	Aadd(aDados,{"MV_#ENVCTE","Envio para Geração de Ct-e",cGERCTE})
	Aadd(aDados,{"MV_#CUSCTE","Envio CT-e para lote de notas",cGERCUS})	
	Aadd(aDados,{"MV_#TPEMCO","Tipo de emissão de complemento",cTpComp})	
	Aadd(aDados,{"MV_#CONCTE","Consulta CT-e",cConsCTE})
	Aadd(aDados,{"MV_#XMLCTE","Download XML Ct-e",cXMLCTE })
	Aadd(aDados,{"MV_#PDFCTE","Download PDF Ct-e",cPDFCTE })
	Aadd(aDados,{"MV_#CANCTE","Cancelar CT-e",cCancCTE})
	Aadd(aDados,{"MV_#SLVCTE","Pasta para salvar XML de CT-e",cPstXML})
	Aadd(aDados,{"MV_#CTELOC","Local Padrão de emissão de CT-e para lote de notas",cLocais})

	//Seguro.
	Aadd(aDados,{"MV_#CTEAVB","Apólice do seguro",cApolic})
	Aadd(aDados,{"MV_#REEAVB","Reenvio de averbação",cReeAvb})

	//Mdf-e
	Aadd(aDados,{"MV_#ESGRMD","Emite MDF Frt Abatido,Frt Frango Vivo,Frt Ovo,Frt Pintinho,Frt Racao",cEmtMDF}) //Everson - 12/02/2020. Chamado 054941.
	Aadd(aDados,{"MV_#ENVMDF","Envio geração de MDF-e",cGERMDF})
	Aadd(aDados,{"MV_#CONMDF","Consulta MDF-e",cConsMDF})
	Aadd(aDados,{"MV_#XMLMDF","Download XML MDF-e",cXMLMDF})
	Aadd(aDados,{"MV_#PDFMDF","Download PDF MDF-e",cPDFMDF})
	Aadd(aDados,{"MV_#ENCMDF","Encerrar MDF-e",cEncMDF})
	Aadd(aDados,{"MV_#CANMDF","Cancelar MDF-e",cCancMDF})

	//Everson - 27/01/2020. Chamado 054941.
	Aadd(aDados,{"MV_#ESGRCI","Emite CIOT Frt Abatido,Frt Frango Vivo,Frt Ovo,Frt Pintinho,Frt Racao",cEmtCIO}) //Everson - 06/03/2020. Chamado 054941.
	Aadd(aDados,{"MV_#ENVCIO" ,"Envio geração de CIOT",cGERCIO})
	Aadd(aDados,{"MV_#CONCIO","Consulta CIOT",cConsCIO})
	Aadd(aDados,{"MV_#XMLCIO","Download XML CIOT",cXMLCIO})
	Aadd(aDados,{"MV_#PDFCIO","Download PDF CIOT",cPDFCIO})
	Aadd(aDados,{"MV_#ENCCIO","Encerrar CIOT",cEncCIO})
	Aadd(aDados,{"MV_#CANCIO","Cancelar CIOT",cCancCIO})
	Aadd(aDados,{"MV_#DSPCIO","Carga de alto desempenho?",cAlDes})

	//Configurações gerais.
	Aadd(aDados,{"MV_#GRVTXT","Gerar TXT",cValToChar(lGravar)})
	Aadd(aDados,{"MV_#CABNF" ,"Cabeçalho da NF-e",cCabNFE})
	Aadd(aDados,{"MV_#RODNF" ,"Rodapé da NF-e",cRodNFE})
	Aadd(aDados,{"MV_#ARQCP" ,"Caminho para salvar arquivo PDF e XML",cCamin})
	Aadd(aDados,{"MV_#NVPROC","Número de vezes para consulta de status do documento",nNumProc})
	Aadd(aDados,{"MV_#DOWARQ","Faz download e abre o documento",lAbrArq})
	Aadd(aDados,{"MV_#TMPBLQ","Tempo de espera para envio, após ocorrer erro (minutos)",nTmpBlq}) //Everson - 24/01/2020. Chamado 054941.
	
	//Apaga registros da aCols.
	oGetDados:aCols := {}

	//Preenche aCols.
	For i := 1 To Len(aDados)
		Aadd(oGetDados:aCols , Array(Len(aHeader)+1) )
		oGetDados:aCols[Len(oGetDados:aCols), Len(oGetDados:aCols[1]) ] := .F.
		oGetDados:aCols[Len(oGetDados:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "MV"	   })] := Alltrim(cValToChar(aDados[i][1])) + Space(100)
		oGetDados:aCols[Len(oGetDados:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "DESC"	   })] := Alltrim(cValToChar(aDados[i][2])) + Space(100)
		oGetDados:aCols[Len(oGetDados:aCols),Ascan(aHeader,{|x| AllTrim(x[2]) == "CONTEUDO"})] := Alltrim(cValToChar(aDados[i][3])) + Space(100)

	Next i
	
	//
	oGetDados:Refresh()
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} GravarMV   
	Preenche os parâmetros da integração. Chamado 044314.
	@type  Static Function
	@author Everson
	@since   24/05/2019
	@version 01
	/*/
Static Function GravarMV()

	//Variáveis.
	Local aArea	:= GetArea()
	Local i		:= 0
	Local cMv	:= ""
	Local cCont	:= ""

	//Gera log de alteração de parâmetro.
	logZBE("FUNCAO GravarMV: ALTERACOES DE PARAMETROS")

	//Itera sobre a aCols da MsNewGetDados.
	For i := 1 To Len(oGetDados:aCols)
		cMv 	:= Alltrim(cValToChar(oGetDados:aCols[i][1])) //Nome da MV.
		cCont	:= Alltrim(cValToChar(oGetDados:aCols[i][3])) //Conteúdo da MV.

		PUTMV(cMv,cCont) //Altera o valor da MV.

	Next i
	
	//
	oTelMV:End() //Fecha o objeto MSDialog.
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} gerRefCTe  
	Monta número sequencial de envio. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 06/11/2019
	@version 01
	/*/
Static Function gerRefCTe(cRoteiro,cDtEntr,cSeq,cEmissTp,cTpVa)
	
	//Variáveis.
	Local aArea := GetArea()
	Local cRef  := ""
	Local dData := GetMv("MV_#DTGDOC",,Date())

	//
	If dData <= SToD(cDtEntr)
		//cRef := Alltrim(cRoteiro) + "-" + Alltrim(cDtEntr) +"-"+ cSeq + "-" + cEmissTp
		cRef := Alltrim(cEmpAnt) + Alltrim(cFilAnt) + Alltrim(cCodZFA)  + Alltrim(cEmissTp) + "-1-" + Alltrim(cSeq) + "-" + Alltrim(cTpVa)
		
	Else
		cRef := Alltrim(cRoteiro) + "-" + Alltrim(cDtEntr) +"-"+ cSeq + "-" + cEmissTp

	EndIf

	//
	RestArea(aArea)

Return cRef
/*/{Protheus.doc} obtInfCTE  
	Função retorna informações de CT-e por NF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/06/2019
	@version 01
	/*/
Static Function obtInfCTE(aNF,cRoteiro,cDtEntr,cTipo,cSeq,lSelectCTE,cVeiculo)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local cQuery	:= ""
	Local cHash		:= ""
	Local cNum		:= ""
	Local cSerie	:= ""
	Local cValor	:= ""
	Local cChaveAce	:= ""
	//Local oXml		:= Nil
	Local cVeic		:= ""
	Local cMsgOphos	:= ""
	Local cTpDoc	:= ""

	//Valida argumentos da função.
	If Empty(cRoteiro)
		MsgStop("Função obtInfCTE não recebe o argumento o número do roteiro.","Função obtInfCTE(ADLOG057P)")
		logZBE("FUNCAO obtInfCTE: NAO RECEBEU O ARGUMENTO cRoteiro")
		RestArea(aArea)
		Return aRetorno

	EndIf

	//Remove espaços em branco.
	cTipo 	:= Alltrim(cValToChar(cTipo))
	cSeq	:= Alltrim(cValToChar(cSeq))

	cQuery  := ""
	cQuery  += " SELECT " 
	cQuery  += " ZFK_ROTEIR, ZFK_DTENTR, ZFK_CARGA, ZFK_SEQENV, ZFK_HASH, ZFK_NUMDOC, ZFK_SERDOC, ZFK_PLACA, ZFK_OPHOS, ZFK_TPDOC, ZFK_CHAVE, SUM(ZFK_VALOR) AS ZFK_VALOR  "
	cQuery  += " FROM "
	cQuery  += " " + RetSqlName("ZFK") + " AS ZFK "
	cQuery  += " WHERE "
	cQuery  += " ZFK_FILIAL =  '" + FWxFilial("ZFK") + "' "
	cQuery  += " AND ZFK_TPDOC  = '1' "
	cQuery  += " AND ZFK_STATUS = '1' "
	cQuery  += " AND ZFK_TMEMIS = 'N' "	
	cQuery  += " AND ZFK_ROTEIR = '" + cRoteiro + "' "
	cQuery  += " AND ZFK_DTENTR = '" + cDtEntr + "' "
	cQuery  += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery  += " AND ZFK_PLACA = '" + cVeiculo + "' " //Everson - 09/12/2019. Chamado 029058.
	
	//
	If cTipo == "1"
		cQuery  += " AND ZFK_SEQENV = '" + cSeq + "' "

	EndIf

	cQuery  += " AND ZFK_HASH <> '' "
	cQuery  += " AND ZFK.D_E_L_E_T_ = '' "
	cQuery  += " GROUP BY ZFK_ROTEIR, ZFK_DTENTR, ZFK_CARGA, ZFK_SEQENV, ZFK_HASH, ZFK_NUMDOC, ZFK_SERDOC, ZFK_PLACA, ZFK_OPHOS, ZFK_TPDOC, ZFK_CHAVE "
	cQuery  += " ORDER BY ZFK_NUMDOC, ZFK_SERDOC "

	//
	logZBE("cQuery Função obtInfCTE(ADLOG057P) " + cValToChar(cRoteiro) + " " + cValToChar(cDtEntr) + " " + cValToChar(FWxFilial("ZFK")) ,cQuery)
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtInfCTE - cQuery " + cQuery )

	//Verifica se o alias existe.
	If Select("ZFKDADOS") > 0
		ZFKDADOS->(DbCloseArea())
		
	EndIf

	//Executa consulta no BD.
	TcQuery cQuery New Alias "ZFKDADOS"
	DbSelectArea("ZFKDADOS")
	ZFKDADOS->(DbGoTop())
	While ! ZFKDADOS->(Eof())

		cHash		:= Alltrim(cValToChar(ZFKDADOS->ZFK_HASH))		//1
		cNum		:= Alltrim(cValToChar(ZFKDADOS->ZFK_NUMDOC))	//2
		cSerie		:= Alltrim(cValToChar(ZFKDADOS->ZFK_SERDOC))	//3
		cValor		:= Alltrim(cValToChar(ZFKDADOS->ZFK_VALOR))		//4
		cChaveAce   := Alltrim(cValToChar(ZFKDADOS->ZFK_CHAVE))		//5
		cVeic		:= Alltrim(cValToChar(ZFKDADOS->ZFK_PLACA))		//6
		cMsgOphos	:= Alltrim(cValToChar(ZFKDADOS->ZFK_OPHOS))		//7
		cTpDoc		:= Alltrim(cValToChar(ZFKDADOS->ZFK_TPDOC))		//8
		

		//Válida o hash para efetuar consulta do CT-e.
		If ! Empty(cChaveAce)

			//Adiciona valores ao array de retorno.
			Aadd(aRetorno,{cHash,cNum,cSerie,cValor,cChaveAce,cRoteiro,cVeic,cMsgOphos,cTpDoc,cDtEntr})

		Else
			
			//
			If !Empty(cNum)

				MsgStop("Função obtInfCTE não obteve a chave de acesso referente ao CT-e " + cNum + "/" + cSerie + ".","Função obtInfCTE(ADLOG057P)")
				logZBE("FUNCAO obtInfCTE: NAO OBTEVE A CHAVE DE ACESSO DO CT-E  "+ cNum + "/" + cSerie + " CARGA " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )

			Else
				MsgAlert("Não há CT-e válido vinculado à carga " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função obtInfCTE(ADLOG057P)")
				logZBE("FUNCAO obtInfCTE: NAO HA CT-E VINCULADO A CARGA " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )
				aRetorno := {}
				RestArea(aArea)
				Return aRetorno
				
			EndIf

		EndIf

		ZFKDADOS->(DbSkip())

	EndDo
	
	//
	ZFKDADOS->(DbCloseArea())

	If Len(aRetorno) > 0

		//Criação de tela para seleção dos CT-e's que irão compor o MDF-e.
		If cTipo == "1"
			RestArea(aArea)
			Return aRetorno

		ElseIf cTipo == "2" .And. ! lSelectCTE //Everson - 05/12/2019 - Chamado 029058.
			RestArea(aArea)
			Return aRetorno

		ElseIf cTipo == "2"
			aRetorno := selectCTE(aRetorno,lSelectCTE)

		EndIf

	Else
		MsgStop("A busca no banco de dados não retornou CT-e válido (status emitido) vinculado à carga " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função obtInfCTE(ADLOG057P)")
		logZBE("FUNCA obtInfCTE: A BUSCA NO BD NAO RETORNOU CT-E VALIDO REFERENTE A CARGA " + cRoteiro)

	EndIf
	
	//
	RestArea(aArea)
	
Return aRetorno
/*/{Protheus.doc} slvXML  
	Salva XML do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 17/07/2019
	@version 01
	/*/
Static Function slvXML(aRet)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cPFis		:= GetMv("MV_#SLVCTE")	
	Local cArqXml	:= ""
	Local lAbreArq	:= .F.
	Local nAux		:= 1
	Local cHash		:= ""
	Local lRet		:= .F.
	Local cChave	:= ""
	
	//Valida argumentos da função.
	If Len(aRet) == 0
		logZBE("FUNCAO slvXML: NAO RECEBEU O ARGUMENTO O HASH PARA FAZER DOWNLOAD DOS DOCUMENTOS")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	For nAux := 1 To Len(aRet)
		
		//
		cHash := aRet[nAux][7]
		cChave:= aRet[nAux][8]
		cArqXml := ""
		Sleep(1000)
		lRet := .F.
		lRet := xmlCTEdow(cHash,cPFis,@cArqXml,lAbreArq,cChave)
		
		//
		If ! Empty(cArqXml)
			uptICMS(cHash,cArqXml)
		
		EndIf
		
		//
		If lRet
			Exit
			
		EndIf
		
	Next nAux
		
	//
	RestArea(aArea)
		
Return Nil
/*/{Protheus.doc} uptICMS  
	Atualiza valor de ICMS. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 17/07/2019
	@version 01
	/*/
Static Function uptICMS(cHash,cArqXml)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aXml		:= {}
	Local oXml		:= Nil
	Local cUpdt		:= ""
	Local lICMS		:= .F.
	Local i			:= 1
	Local nVlrICMS	:= 0
	Local nVlrAliq	:= 0
	Local oICMS		:= Nil
	Local oICMSAl	:= Nil
	
	//Valida o retorno.
	aXml := geraObjXML(cArqXml)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]
	
	//
	oICMSAl	:= XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE, "_IMP")
	If ValType(oICMSAl) <> "U"

		//Everson³14/08/19³044314.
		oICMSAl := XmlChildEx(oICMSAl, "_ICMS")
		
		//
		If ValType(oICMSAl) <> "U"
	
			//
			oICMSAl := XmlChildEx(oICMSAl, "_ICMS00")
			
			//
			If ValType(oICMSAl) <> "U"
				
				//
				oICMSA2 := XmlChildEx(oICMSAl, "_VICMS")
				oICMSAl := XmlChildEx(oICMSAl, "_PICMS")
				
				
				//
				If ValType(oICMSAl) <> "U"
					
					//
					nVlrAliq := Val(cValToChar(oICMSAl:Text))
				
				EndIf
				
				//
				If ValType(oICMSA2) <> "U"
					
					//
					//nVlrICMS := Val(cValToChar(oICMSA2:Text))
				
				EndIf
				
			EndIf
			
		EndIf
	
	EndIf 
	
	//Everson³21/08/19³044314.
	If nVlrAliq > 0
		lICMS := .T.
		
	EndIf

	//
	oICMS 	:= XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE, "_VPREST") //Everson   ³02/08/19³044314.

	//
	If ValType(oICMS) <> "U"
	
		//
		oICMS := XmlChildEx(oICMS, "_COMP") //Everson   ³02/08/19³044314.
	
		//
		If ValType(oICMS) <> "U"
		
			//
			If ValType(oICMS) == "A" //Everson   ³02/08/19³044314.
				
				//
				For i := 1 To Len(oICMS) //Everson   ³02/08/19³044314.
				
					//
					If Alltrim(oICMS[i]:_XNOME:Text) = "ICMS" //Everson   ³02/08/19³044314.
					
						If Val(cValToChar(oICMS[i]:_VCOMP:Text)) > 0
							nVlrICMS := Val(cValToChar(oICMS[i]:_VCOMP:Text))
							lICMS := .T.
						
						EndIf
					
					EndIf
					
				Next i
			
			
			ElseIf ValType(oICMS) == "O" //Everson   ³02/08/19³044314.

				//
				If Alltrim(oICMS:_XNOME:Text) = "ICMS" //Everson   ³02/08/19³044314.
				
					If Val(cValToChar(oICMS:_VCOMP:Text)) > 0 //Everson   ³02/08/19³044314.
						nVlrICMS := Val(cValToChar(oICMS:_VCOMP:Text))
						lICMS := .T.
					
					EndIf
				
				EndIf				
			
			EndIf
			
		EndIf
	
	EndIf
	
	//Everson³21/08/19³044314.
	//Everson³14/08/19³044314.
	//Everson³02/08/19³044314.
	cUpdt := " UPDATE " + RetSqlName("ZFK") + " SET ZFK_ICMS = '" + Iif(lICMS,"2","1") + "', ZFK_VLRICM = " + cValToChar(nVlrICMS) + ", ZFK_ALQICM = '" + cValToChar(nVlrAliq) + "' WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' AND ZFK_HASH = '" + cHash + "' AND ZFK_TPDOC = '1' AND D_E_L_E_T_ = '' "

	//
	If TCSqlExec(cUpdt) < 0
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - uptICMS - TCSQLError() " + TCSQLError() )
		
	EndIf
	
	//
	RestArea(aArea)	
	
Return .T.
/*/{Protheus.doc} dowArq  
	Efetua download do arquivo. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function dowArq(aRet,nTipo,cDtEntr)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cHash		:= ""
	Local lAbrArq	:= GetMv("MV_#DOWARQ")

	//Valida argumentos da função.
	If Len(aRet) == 0
		logZBE("FUNCAO dowArq: NAO RECEBEU O ARGUMENTO O HASH PARA FAZER DOWNLOAD DOS DOCUMENTOS")
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o código Hash.
	cHash := obtHash(aRet[1][1],aRet[1][2],aRet[1][3],aRet[1][4],aRet[1][5],cDtEntr)
	If Empty(cHash)
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Valida argumentos da função.
	If ! lAbrArq
		logZBE("FUNCAO dowArq: PARÂMETRO lAbrArq(MV_#DOWARQ) = .F. ")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	If nTipo == 1 //CT-e

		//Faz download do arquivo pdf.
		pdfCTEdow(cHash)

	ElseIf nTipo == 2 //MDF-e

		//Faz download do arquivo pdf.
		pdfMDFdow(cHash)

	ElseIf nTipo == 3 //CIOT //Everson - 06/03/2020 - Chamado 054941.
		pdfCIOdow(cHash)

	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} pdfCTEdow  
	Obtém PDF do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function pdfCTEdow(cHash,cPFis,cArqPdf,lAbreArq,cChave,cRetCamin) //Everson   ³30/07/19³044314.

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUrl		:= GetMv("MV_#PDFCTE")
	Local cCaminho	:= ""
	Local cArq		:= ""
	Local lRet 		:= .T.
	
	Default cPFis		:= ""
	Default cArqPdf		:= ""
	Default lAbreArq	:= .T.
	Default cChave		:= ""
	Default cRetCamin	:= ""

	//Remove espaços em branco.
	cHash 	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função pdfCTEdow não recebeu o hash do CT-e.","Função pdfCTEdow(ADLOG057P)")
		logZBE("FUNCAO pdfCTEdow: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("Função pdfCTEdow não obteve a URL para efetuar o download do arquivo pdf do CT-e (MV MV_#PDFCTE).","Função pdfCTEdow(ADLOG057P)")
		logZBE("FUNCAO pdfCTEdow: NAO RECEBEU A URL PARA EFETUAR O DOWNLOAD DO ARQUIVO PDF DO CT-E MV MV_#PDFCTE")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Nome do arquivo.
	//Everson   ³30/07/19³044314.
	If ! Empty(cChave)
		cArq := cChave
		
	Else
		cArq := cHash + "CTE"
	
	EndIf

	//Adiciona o hash à URL.
	cUrl := StrTran(cUrl,"{hash}",cHash)

	//Faz o download do arquivo.
	cCaminho := obtArquivo(cUrl,cArq,"pdf",cPFis,cArqPdf)

	//Verifica o retorno da função obtArquivo.
	If Empty(cCaminho)
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	cRetCamin := cCaminho //Everson   ³30/07/19³044314.
	
	//
	lRet := fVisualiza(cCaminho,lAbreArq)
	
	//
	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} obtArquivo  
	Obtém arquivos. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function obtArquivo(cUrl,cArq,cExt,cPFis,cArqXml)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cHtml			:= ""
	Local cErroWS		:= ""
	//Local cStatus		:= ""
	Local cArquivo		:= ""
	Local cCaminho		:= ""
	Local oRestClient	:= ""
	Local cPasta		:= GetMv("MV_#ARQCP")
	
	Default cPFis		:= ""
	Default cArqXml		:= ""
	
	//
	If ! Empty(cPFis)
		cPasta := cPFis
	
	EndIf

	//Retira os espaços em branco.
	cUrl	:= Alltrim(cValToChar(cUrl))
	cArq	:= Alltrim(cValToChar(cArq))
	cExt	:= Alltrim(cValToChar(cExt))

	//Verifica se a URL foi informada.
	If 	Empty(cUrl)
		MsgStop("A função obtArquivo não recebeu a URL (argumento) para efetuar o download do arquivo.","Função obtArquivo(ADLOG057P)")
		logZBE("FUNCAO obtArquivo: URL NAO INFORMADA")
		RestArea(aArea)
		Return cCaminho

	ElseIf	Empty(cArq)
		MsgStop("A função obtArquivo não recebeu o nome do arquivo (argumento) para salvar o arquivo.","Função obtArquivo(ADLOG057P)")
		logZBE("FUNCAO obtArquivo: NOME DO ARQUIVO NAO INFORMADO")
		RestArea(aArea)
		Return cCaminho

	ElseIF Empty(cExt)
		MsgStop("A função obtArquivo não recebeu a extensão do arquivo (argumento) para salvar o arquivo.","Função obtArquivo(ADLOG057P)")
		logZBE("FUNCAO obtArquivo: EXTENSAO DO ARQUIVO NAO INFORMADO")
		RestArea(aArea)
		Return cCaminho

	EndIf

	//Defini o nome do arquivo.
	cArquivo := cArq

	//Cria o objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui o path.
	oRestClient:setPath("")

	//Executa a chamada no web service.
	If oRestClient:Get()
		cHtml   := oRestClient:GetResult()		//Retorno sem erros.

	Else
		cErroWS := oRestClient:GetLastError()	//Retorno com erros.
		
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtArquivo - cUrl " + cUrl )
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtArquivo - cArq " + cArq )
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtArquivo - cErroWS " + cErroWS )
		
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) +;
		cErroWS + Chr(13) + Chr(10) +;
		"URL Acessada: " + cUrl + Chr(13) + Chr(10) +;
		"Arquivo solicitado: " + cArq + Chr(13) + Chr(10) +;
		"Extensão: " + cExt,"Função obtArquivo(ADLOG057P)")
		logZBE("FUNCAO obtArquivo: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS)
		
		RestArea(aArea)
		Return cCaminho

	Endif
	
	//
	cArqXml := cHtml

	//Grava o arquivo no caminho específicado.
	cCaminho := gravarTXT(cHtml,cArq,cExt,cPasta,.F.)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
	
	//
	RestArea(aArea)

Return cCaminho
/*/{Protheus.doc} fVisualiza  
	Visualiza arquivo. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function fVisualiza(cArquivo,lAbreArq)

	//Variáveis.
	Local aArea	:= GetArea()
	
	Default lAbreArq := .T.
	
	//
	If ! lAbreArq
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//Remove espaços em branco.
	cArquivo	:= Alltrim(cValToChar(cArquivo))

	//Executa o programa definido como padrão do windows para abrir o arquivo específico.
	ShellExecute("open",cArquivo,"","",5)
	
	//
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} obtHash  
	Retorna hash. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function obtHash(cRoteiro,cSeq,cTpDoc,cNF,cSerie,cDtEntr)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cHash		:= ""

	//Retira espaços em branco.
	cRoteiro:= Alltrim(cValToChar(cRoteiro))
	cSeq	:= Alltrim(cValToChar(cSeq))
	cSerie	:= Alltrim(cValToChar(cSerie))
	cNF		:= Alltrim(cValToChar(cNF))

	//Verifica se os argumentos não estão em branco.
	If Empty(cSerie)
		MsgStop("A função obtHash não recebeu a série da nota fiscal.","Função obtHash(ADLOG057P)")
		logZBE("FUNCAO obtHash: NAO RECEBEU A SERIE DA NOTA FISCAL")
		RestArea(aArea)
		Return cHash

	ElseIf Empty(cNF)
		MsgStop("A função obtHash não recebeu o número da nota fiscal.","Função obtHash(ADLOG057P)")
		logZBE("FUNCAO obtHash: NAO RECEBEU O NUMERO DA NOTA FISCAL")
		RestArea(aArea)
		Return cHash

	ElseIf Empty(cRoteiro)
		MsgStop("A função obtHash não recebeu o número do roteiro.","Função obtHash(ADLOG057P)")
		logZBE("FUNCAO obtHash: NAO RECEBEU O NUMERO DO ROTEIRO")
		RestArea(aArea)
		Return cHash

	ElseIf Empty(cSeq)
		MsgStop("A função obtHash não recebeu o número sequencial do roteiro.","Função obtHash(ADLOG057P)")
		logZBE("FUNCAO obtHash: NAO RECEBEU O NUMERO SEQUENCIAL DO ROTEIRO.")
		RestArea(aArea)
		Return cHash

	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " ZFK_HASH "
	cQuery += " FROM "
	cQuery += " " + RetSqlName("ZFK") + " AS ZFK "
	cQuery += " WHERE "
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' "
	cQuery += " AND ZFK_ROTEIR = '" + cRoteiro + "' "
	cQuery += " AND ZFK_DTENTR = '" + cDtEntr  + "' "
	cQuery += " AND ZFK_SEQENV = '" + cSeq     + "' "
	cQuery += " AND ZFK_NOTA   = '" + cNF      + "' "
	cQuery += " AND ZFK_SERIE  = '" + cSerie   + "' "
	cQuery += " AND ZFK_TPDOC  = '" + cTpDoc   + "' "
	cQuery += " AND ZFK_TPCARG = '" + cTpVa    + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = '' "
	
	//
	If Select("ZFK_HASH") > 0
		ZFK_HASH->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "ZFK_HASH"
	DbSelectArea("ZFK_HASH")
		cHash := ZFK_HASH->ZFK_HASH
	ZFK_HASH->(DbCloseArea())

	//Verifica se a consulta retornou resultado.
	If Empty(cHash)
		MsgStop("Não foi possível encontrar o hash na tabela ZFK referete à nota fiscal " + cNF + "/" + cSerie + ".","Função obtHash(ADLOG057P)")
		logZBE("FUNCAO obtHash: NAO ENCONTROU HASH NA TABELA ZFK")
		
	EndIf
	
	//
	RestArea(aArea)

Return cHash
/*/{Protheus.doc} obtStrXML  
	Obtém o XML da nota fiscal. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	/*/
Static Function obtStrXML(cSerie,cNF)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aString   	:= {}
	Local cSerieNota	:= ""
	Local cXml			:= ""
	Local cIdEnt	:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cCNPJ		:= ""
	
	Local cTipo			:= "" //Everson - 12/05/2020. Chamado 058135.

	//Remove espaços em branco.
	cSerie  := Alltrim(cValToChar(cSerie))
	cNF     := Alltrim(cValToChar(cNF))

	//
	cSerieNota := cSerie+cNF

	//Recupera código do cliente e loja.
	cCliente := Alltrim(cValToChar(Posicione("SF2",1,xFilial("SF2") + cNF + cSerie, "F2_CLIENTE")))
	cLoja	 := Alltrim(cValToChar(Posicione("SF2",1,xFilial("SF2") + cNF + cSerie, "F2_LOJA")))
	
	
	//Everson - 12/05/2020. Chamado 058135.
	cTipo    := Alltrim(cValToChar(Posicione("SF2",1,xFilial("SF2") + cNF + cSerie, "F2_TIPO")))
	If cTipo = "B"
		cCNPJ	 := Posicione("SA2",1,xFilial("SA2") + cCliente + cLoja,"A2_CGC")

	Else
		cCNPJ	 := Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja,"A1_CGC")

	EndIf

	//Recupera código.
	cIdEnt := Alltrim(GetMv("MV_#IDCIE"))

	//Chama função para gerar o xml.
	cXml := Alltrim(SpedPExp(cIdEnt,Padr(cSerie,TamSx3("F2_SERIE")[1]," "),cNF,cCnpj))

	//Salva arquivo.
	gravarTXT(cXml,"nota_fiscal","xml",,.T.)
	
	//Verifica retorno da função recupXML.
	If Empty(cXml)
		MsgStop("A consulta no Protheus referente à nota fiscal " + cSerieNota + " não retornou resultado." + Chr(13) + Chr(10) +;
		"Por favor, verifique se a nota não está com o status de cancelada e se já foi liberada pela SEFAZ.","Função(1) obtStrXML")
		logZBE("FUNCAO obtStrXML: CONSULTA AO BANCO DE DADOS NAO RETORNOU RESULTADOS PARA NF " + cSerieNota)
		RestArea(aArea)
		Return aString

	EndIf

	Aadd(aString,{cSerieNota,cXml})

	//Checa se o retorno com a string xml não está fazia.
	cStringXML := Alltrim(cValToChar(aString[1][2]))
	If cStringXML == "XXX" .Or. Empty(cStringXML)

		MsgStop("A consulta no Protheus referente à nota fiscal " + cSerieNota + " não retornou o XML." + Chr(13) + Chr(10) +;
		"Por favor, verifique se a nota não está com o status de cancelada e se já foi liberada pela SEFAZ.","Função(2) obtStrXML")
		aString := {}
		logZBE("FUNCAO obtStrXML: CONSULTA AO BANCO DE DADOS NAO RETORNOU A STRING CONTENDO O XML DA NF " + cSerieNota)
		RestArea(aArea)
		Return aString

	EndIf
	
	//
	RestArea(aArea)
	
Return aString
/*/{Protheus.doc} SpedPExp  
	Função para gerar o arquivo Xml. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	/*/
Static Function SpedPExp(cIdEnt,cSerie,cNota,cCnpj)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cURL     	:= Alltrim(PadR(GetNewPar("MV_SPEDURL","http://"),250)) + "/NFeSBRA.apw"
	Local nX		:= 0
	Local oWS		:= Nil
	Local oRetorno	:= Nil
	Local lOk      	:= .F.
	Local cXml		:= ""
	Local cCab1 	:= Alltrim(obtCbNFE()) //Cabeçalho da NF-e.
	Local cRodap	:= Alltrim(obtRodNFE()) //Rodapé da NF-e.

	//Cria objeto.
	oWS:= WSNFeSBRA():New()

	//Seta atribuitos.
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:_URL              := cURL
	oWS:cIdInicial        := cSerie+cNota
	oWS:cIdFinal          := cSerie+cNota
	oWS:dDataDe           := SToD("20120101")
	oWS:dDataAte          := SToD("31001231")
	oWS:cCNPJDESTInicial  := cCnpj
	oWS:cCNPJDESTFinal    := cCnpj
	oWS:nDiasparaExclusao := 0

	//Recupera retorno.
	lOk := oWS:RETORNAFX()

	//Verifica retorno.
	If ! lOk
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+CRLF+"Erro",{"OK"},3)
		RestArea(aArea)
		Return cXml

	EndIf

	//Resultado do retorno.
	oRetorno := oWS:oWsRetornaFxResult

	//Itera sobre retorno.
	For nX := 1 To Len(oRetorno:OWSNOTAS:OWSNFES3)

		//Recupera item do array.
		oXml	:= oRetorno:OWSNOTAS:OWSNFES3[nX]

		//Verifica protocolo.
		If !Empty(oXml:oWSNFe:cProtocolo)

			//Concatena informações do xml.
			cXml += cCab1
			cXml += AllTrim(oXml:oWSNFe:cXML)
			cXml += AllTrim(oXml:oWSNFe:cXMLPROT)
			cXml += cRodap

		EndIf

	Next nX
	
	//
	RestArea(aArea)

Return cXml
/*/{Protheus.doc} obtCbNFE  
	Função retorna o cabeçalho da NF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function obtCbNFE()

	//Variáveis.
	Local aArea	:= GetArea()
	Local cRet	:= GetMv("MV_#CABNF")

	//Remove espaços em branco.
	cRet := Alltrim(cValToChar(cRet))

	//Valida retorno.
	If Empty(cRet)
		MsgStop("Não foi possível obter o cabeçalho da NF-e (MV MV_#CABNF)","Função obtCbNFE")
		logZBE("FUNCAO obtCbNFE: NAO FOI POSSIVEL OBTER O CABECALHO DA NF-E MV MV_#CABNF")
		RestArea(aArea)
		Return ""
		
	EndIf
	
	//
	RestArea(aArea)

Return cRet
/*/{Protheus.doc} obtRodNFE  
	Função retorna o rodapé da NF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function obtRodNFE()

	//Variáveis.
	Local aArea	:= GetArea()
	Local cRet	:= GetMv("MV_#RODNF")

	//Remove espaços em branco.
	cRet := Alltrim(cValToChar(cRet))

	//Valida retorno.
	If Empty(cRet)
		MsgStop("Não foi possível obter o rodapé da NF-e (MV MV_#RODNF)","Função obtRodNFE")
		logZBE("FUNCAO obtRodNFE: NAO FOI POSSIVEL OBTER O RODAPE DA NF-E MV MV_#RODNF")
		RestArea(aArea)
		Return ""
		
	EndIf
	
	//
	RestArea(aArea)

Return cRet
/*/{Protheus.doc} retReeAvb  
	Reenvio de averbação. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 11/07/2019
	@version 01
	/*/
Static Function retReeAvb(oXml,cHash)

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local cRetorno	:= ""
	Local cMensagem	:= ""
	Local lRet		:= .F.

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_retPadrao:_status:Text))
	cMensagem:= Alltrim(cValToChar(oXml:_retPadrao:_mensagem:Text))
	
	//
	If cRetorno == "100"
		MsgInfo("O serviço de emissão de Averbação retornou: " + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem ,"Função retReeAvb(ADLOG057P)")
		lRet := .T.
		
	Else
		MsgAlert("O serviço de emissão de Averbação retornou: " + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem ,"Função retReeAvb(ADLOG057P)")	
		lRet := .F.
		
	EndIf
		
	//
	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} statusCTE  
	Obtém status do retorno. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function statusCTE(cHash)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aRetorno		:= {}
	Local oXml			:= Nil
	Local cRetorno		:= ""
	Local cMensagem 	:= ""
	Local cMsgOphos 	:= ""
	Local cStatus		:= ""
	Local aRetCons		:= {}
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	Local cProtCance	:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	Local cValor		:= ""
	Local xDdAverb		:= Nil //Everson³01/07/19³044314.
	Local cDataEmis		:= ""
	
	//
	Sleep(2000)

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))

	//Executa consulta do CT-e.
	aRetCons := consulCTE(cHash,2)

	//Valida retorno da função consulCTE.
	If ! aRetCons[1][1]
		Aadd(aRetorno,{"",""})
		RestArea(aArea)
		Return aRetorno
		
	EndIf

	//Recupera objeto xml.
	oXml	:= aRetCons[1][2]

	cRetorno 	:= Alltrim(cValToChar(oXml:_retConsulta:_status:Text))
	cMensagem	:= Alltrim(cValToChar(oXml:_retConsulta:_mensagem:Text))
	cMsgOphos	:= cRetorno + "-" + cMensagem

	//Número e série do CT-e.
	cNumDoc := Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_numero:Text))
	cSerDoc := Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_serie:Text))
	
	//
	xDdAverb := XmlChildEx(oXml:_retConsulta, "_DADOSAVERBACAO") //Everson³01/07/19³044314.

	//Protocolo de emissão e chave de acesso.
	If cRetorno == "101" .Or. cRetorno == "102"
		cProtEmis	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_protocolo:Text))
		cChaveAces	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_chaveAcesso:Text))
		cValor		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_valor:Text))
		cDataEmis	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_dataEmissao:Text))
		cDataEmis   := StrTran(Substr(cDataEmis,1,10),"-","")
		
	EndIf

	//Protocolo de cancelamento.
	If cRetorno == "102"
		cProtCance	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCancelamento:_protocolo:Text))

	EndIf

	//Define o status do documento.
	cStatus := tlbStatus(cRetorno,2)

	Aadd(aRetorno,{cStatus,cMsgOphos,cProtEmis,cChaveAces,cProtCance,oXml,cNumDoc,cSerDoc,cValor,cRetorno,xDdAverb,cDataEmis}) //Everson³01/07/19³044314.
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} consulCTE  
	Efetua consulta do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function consulCTE(cHash,nTipo,lExibMsg)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUrl  		:= ""
	Local oRestClient	:= Nil
	Local cErroWS		:= ""
	Local cRetGet		:= ""
	Local aXml			:= {}
	Local aRet			:= {}
	Local lRet 			:= .T.

	Default nTipo		:= 1
	Default lExibMsg	:= .T.

	//Retira espacos em branco.
	cHash	:= Alltrim(cValToChar(cHash))

	//Verifica se os argumentos estão em branco.
	If Empty(cHash)
		MsgStop("Função consulCTE não recebeu o hash.","Função consulCTE(ADLOG057P)")
		logZBE("FUNCAO consulCTE: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf
		
	EndIf

	//URL de acesso.
	cUrl   	:= GetMv("MV_#CONCTE")
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida retorno.
	If Empty(cUrl)
		MsgStop("Não foi possível obter a URL de consulta de CT-e (MV )","Função consulCTE(ADLOG057P)")
		logZBE("FUNCAO consulCTE: NAO FOI POSSIVEL OBTER A URL DE CONSULTA DE CT-E MV ")
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf
		
	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl := StrTran(cUrl,"{hash}",cHash)

	//Cria o objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui o path.
	oRestClient:setPath("")

	//Executa chamada no web service.
	If oRestClient:Get()
		cRetGet := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função consulCTE(ADLOG057P)")
		logZBE("FUNCAO consulCTE: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS)

		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	Endif

	//Salva retorno do web service.

	gravarTXT(cRetGet, cHash + "Ret_Consulta_CTE","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetGet)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	If nTipo == 2
		Aadd(aRet,{.T.,oXml})
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Verifica o status de retorno de geração do CT-e.
	lRet := obtRet(2,oXml,,,cHash,,,,,,,,,,,,,,,lExibMsg)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} cancCTE  
	Grava retorno da emissão do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function cancCTE(cHash,cJust)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local cUrl			:= GetMv("MV_#CANCTE")
	Local cTemplate		:= ""
	Local aXml			:= {}
	Local oXml			:= Nil
	Local cXml			:= ""
	Local cCabec		:= obtCabec()
	Local cRetPost		:= ""
	Local cErroWS		:= ""
	Local aCabec		:= {}
	Local oRestClient	:= Nil

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cJust	:= Alltrim(cValToChar(cJust))
	cUrl	:= Alltrim(cValToChar(cUrl))
	
	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função cancCTE não recebeu o hash como argumento.","Função cancCTE(ADLOG057P)")
		logZBE("FUNCAO cancCTE: NAO RECEBEU A cHash COMO ARGUMENTO")
		RestArea(aArea)
		Return .F.

	ElseIf	Empty(cJust)
		MsgStop("Função cancCTE não recebeu a justificativa do cancelamento.","Função cancCTE(ADLOG057P)")
		logZBE("FUNCAO cancCTE: NAO RECEBEU A JUSTIFICATIVA DO CANCELAMENTO")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("Função cancCTE não foi possível obter a URL de envio para cancelamento de CT-e (MV MV_#CANCTE).","Função cancCTE(ADLOG057P)")
		logZBE("FUNCAO cancCTE: NAO RECEBEU OBTEVE A URL DE CANCELAMENTO DE CT-E MV MV_#CANCTE")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Carrega template de cancelamento de CT-e.
	cTemplate   := canXmlTemp()

	//Verifica se o template foi carregado.
	If Empty(Alltrim(cValToChar(cTemplate)))
		MsgStop("Não foi possível carregar o template xml para cancelamento do CT-e.","Função cancCTE(ADLOG057P)")
		logZBE("Função cancCTE: NAO FOI POSSIVEL CARREGA O TEMPLATE")
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Gera objeto xml.
	aXml  := geraObjXML(cTemplate)
	If ! aXml[1][1] //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Adiciona hash e motivo.
	oXml:_EnvCancelamento:_hash:Text         := cHash
	oXml:_EnvCancelamento:_justificativa:Text:= cJust

	//Salva objeto como string.
	SAVE oXml XMLSTRING cXml

	//Adiciona cabeçalho ao xml.
	cXml := cCabec + cXml

	//Salva arquivo que está sendo enviado.
	gravarTXT(cXml, cHash + "_Env_CancelCTE","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui parâmetros.
	oRestClient:SetPostParams(cXml)

	//Atribui path.
	oRestClient:setPath("")

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função cancCTE")
		logZBE("FUNCAO cancCTE: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cXml)
		Final() //Everson - 22/01/2020. Chamado 054941.
		//RestArea(aArea)
		//Return .F.
		
	Endif

	//Salva arquivo de retorno do cancelamento.
	gravarTXT(cRetPost, cHash + "_Ret_CancelCTE","xml",,.T.)

	//Gera objeto xml.
	aXml  := geraObjXML(cRetPost)
	If ! aXml[1][1] //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de geração do CT-e.
	lRet := obtRet(3,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} canXmlTemp  
	Template xml para cancelamento de CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
Static Function canXmlTemp()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cString	:= ""

	//Monta string.
	cString += '<EnvCancelamento>'
	cString += '<hash></hash>'
	cString += '<justificativa></justificativa>'
	cString += '</EnvCancelamento>'
	
	//
	RestArea(aArea)
	
Return cString
/*/{Protheus.doc} retCancCTE  
	Tratamento para retorno de cancelamento de CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
Static Function retCancCTE(oXml,cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cRetorno	:= ""
	Local cMensagem	:= ""
	Local lRet		:= .F.

	//Retira espaços em branco.
	cHash := Alltrim(cValToChar(cHash))

	//Valida argumentos.
	If 	Empty(cHash)
		MsgStop("Função retCancCTE não recebeu o hash como argumento.","Função retCancCTE(ADLOG057P)")
		logZBE("FUNCAO retCancCTE: NAO RECEBEU cHash COMO ARGUMENTO")
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_retCancelamento:_status:Text))

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_retCancelamento:_mensagem:Text))

	//Tratamento por status de retorno.
	If  cRetorno == "102" //Cancelado.
		MsgInfo("Ct-e cancelado." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem,"Função retCancCTE(ADLOG057P)")
		logZBE("FUNCAO retCancCTE: RECEBEU STATUS " + cRetorno)
		lRet := .T.

	ElseIf	cRetorno == "105" //Hash não encontrado.
		MsgStop("Ct-e não pode ser cancelado." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem,"Função retCancCTE(ADLOG057P)")
		logZBE("FUNCAO retCancCTE: RECEBEU STATUS " + cRetorno)
		lRet := .F.

	ElseIf	cRetorno == "999" //Erro geral.
		MsgStop("Ct-e não pode ser cancelado." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem,"Função retCancCTE(ADLOG057P)")
		logZBE("FUNCAO retCancCTE: RECEBEU STATUS " + cRetorno)
		lRet :=  .F.

	Else //Status de retorno inesperado.
		MsgStop("Status de retorno inesperado." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno,"Função retCancCTE(ADLOG057P)")
		logZBE("FUNCAO retCancCTE: RECEBEU STATUS " + cRetorno)
		lRet :=  .F.

	EndIf

	//Marcar documento como cancelado.
	If lRet
		lRet := cancDoc(cHash,"1")
		
	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} cancDoc  
	Tratamento para retorno de cancelamento de documento. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
Static Function cancDoc(cHash,cTpDoc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUpdate 	:= ""
	Local cErroUp 	:= ""
	//Local oXml	  	:= ""
	Local cStatus 	:= ""
	//Local cRetorno	:= ""
	//Local cMensagem	:= ""
	Local cMsgOphos	:= ""
	Local aStatus	:= {}
	Local cProtCanc	:= ""

	//Remove espaços em branco.
	cHash 	:= Alltrim(cValToChar(cHash))
	cTpDoc	:= Alltrim(cValToChar(cTpDoc))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função cancDoc não recebeu o hash. ","Função cancDoc")
		logZBE("FUNCAO cancDoc: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cTpDoc)
		MsgStop("Função cancDoc não recebeu o tipo de documento. ","Função cancDoc")
		logZBE("FUNCAO cancDoc: NAO RECEBEU O ARGUMENTO cTpDoc")
		RestArea(aArea)
		Return .F.

	EndIf

	//Realiza consulta do documento no sistema Ophos.
	If cTpDoc == "1" //CT-e.

		//Executa função de status do CT-e.
		aStatus := statusCTE(cHash)
		
		//Valida o retorno da função statusCTE.
		If Len(aStatus) == 0 
			MsgStop("Não foi possível obter o status do CT-e.","Função cancDoc(ADLOG057P)")
			RestArea(aArea)
			Return .F.
	
		EndIF
		
		//
		If Len(aStatus[1]) <> 12
			MsgStop("Não foi possível obter o status do CT-e.","Função cancDoc(ADLOG057P)")
			RestArea(aArea)
			Return .F.
	
		EndIF
		
		//
		cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
		cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
		cProtCanc	:= Alltrim(cValToChar(aStatus[1][5]))	

	ElseIf cTpDoc == "2" //MDF-e.

		//Executa função de status do MDF-e.
		aStatus := statusMDFE(cHash)
		
		//Valida o retorno da função statusMDFE.
		If Len(aStatus) == 0 
			MsgStop("Não foi possível obter o status do MDF-e.","Função cancDoc(ADLOG057P)")
			RestArea(aArea)
			Return .F.
	
		EndIF
		
		//
		If Len(aStatus[1]) <> 11
			MsgStop("Não foi possível obter o status do MDF-e.","Função cancDoc(ADLOG057P)")
			RestArea(aArea)
			Return .F.
	
		EndIF
		
		cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
		cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
		cProtCanc	:= Alltrim(cValToChar(aStatus[1][6]))

	ElseIf cTpDoc == "3" //CIOT. //Everson-27/01/2020. Chamado 054941.
		
		//Executa função de status do CIOT.
		aStatus := statusCIOT(cHash)
		
		//Valida o retorno da função statusCIOT.
		If Len(aStatus) == 0 
			MsgStop("Não foi possível obter o status do CIOT.","Função cancDoc(ADLOG057P)")
			RestArea(aArea)
			Return .F.
	
		EndIF
		
		//
		If Len(aStatus[1]) <> 11
			MsgStop("Não foi possível obter o status do CIOT.","Função cancDoc(ADLOG057P)")
			RestArea(aArea)
			Return .F.
	
		EndIF
		
		cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
		cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
		cProtCanc	:= Alltrim(cValToChar(aStatus[1][6]))

	EndIf

	//Monta script sql.
	cUpdate := "UPDATE " + RetSqlName("ZFK") + " SET ZFK_STATUS = '" + cStatus +;
	"', ZFK_OPHOS ='" + cMsgOphos + "', ZFK_PROTCA='" + cProtCanc + "' WHERE ZFK_HASH = '" + cHash + "' AND ZFK_TPDOC = '" + cTpDoc + "'"

	//Executa script.
	If TCSQLExec(cUpdate) < 0 //Verifica se retornou erro.

		cErroUp := Alltrim(cValToChar(TCSQLError()))
		MsgStop("Função cancDoc não removeu o CT-e da base do sistema protheus." + Chr(13) + Chr(10) +;
		"TCSQLError " + cErroUp,"Função excluirCTE(ADLOG057P)")
		logZBE("FUNCAO cancDoc: NAO RECEBEU EXCLUIU O CT-e de hash " + cHash + " ERRO " + cErroUp)
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} retConsEmp  
	Função para tratamento de retorno da consulta de transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 11/06/2019
	@version 01
	/*/
Static Function retConsEmp(oXml)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cCodTransp	:= ""
	Local cLoja			:= ""
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local cTrpCNPJ		:= ""
	Local cTrpInsEst	:= ""
	Local cTrpAmbien	:= ""
	Local cTrpProt		:= ""
	Local cTrpSitua		:= ""
	//Local i				:= 1
	Local cDadosRes		:= ""
	Local chaveConsulta	:= ""
	Local lRet			:= .F.
	Local cNomeTransp	:= ""
	Local cXml			:= ""
	Local nPosAt		:= 0

	//Obtém o retorno e a mensagem.
	cRetorno		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_status:Text))	
	cMensagem 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_mensagem:Text))

	//Tratamento do retorno.
	If cRetorno == "100" //Consulta realizada com sucesso.

		//Salva objeto como string.
		SAVE oXml XMLSTRING cXml

		//Verifica se há ressalvas.
		nPosAt := At("<resalva>",cXml)

		If nPosAt > 0
			cDadosRes := Substr(cXml,nPosAt,Len(cXml))
			cDadosRes := StrTran(cDadosRes,"<resalva>","")
			cDadosRes := StrTran(cDadosRes,"</resalva>","" + Chr(13) + Chr(10))
			cDadosRes := StrTran(cDadosRes,"</retConsultaTransportador>","")
			cDadosRes := StrTran(cDadosRes,"<descricao>"," Ocorrência: ")
			cDadosRes := StrTran(cDadosRes,"</descricao>","")
			cDadosRes := StrTran(cDadosRes,"<dataLimite>","Dt. Limite: ")
			cDadosRes := StrTran(cDadosRes,"</dataLimite>","")

		EndIf

		//Recupera protocolo.
		cTrpProt := Alltrim(cValToChar(oXml:_retConsultaTransportador:_protocolo:Text))

		//Recupera situação.
		cTrpSitua := Alltrim(cValToChar(oXml:_retConsultaTransportador:_situacao:Text))

		//Recupera CNPJ.
		cTrpCNPJ 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_cnpjTransportador:Text))

		//Recupera Inscrição Estadual.
		cTrpInsEst 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_ieTransportador:Text))

		//Recupera ambiente.
		cTrpAmbien 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_ambiente:Text))

		//Recupera chave da consulta.
		chaveConsulta	:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_chaveConsulta:Text))

		//Recupera nome da transportadora.
		cCodTransp	:= Posicione("SA4",3,xFilial("SA4") + cTrpCNPJ, "A4_COD")
		cLoja		:= Posicione("SA4",3,xFilial("SA4") + cTrpCNPJ, "A4_LOJTRA")
		cNomeTransp := Posicione("SA4",3,xFilial("SA4") + cTrpCNPJ, "A4_NOME")

		If cTrpSitua == "1"
			cTrpSitua += " - APTO"

		ElseIf 	cTrpSitua == "0"
			cTrpSitua += " - INAPTO *******************"

		EndIf

		MsgInfo("Consulta transportadora " 		+ Chr(13) + Chr(10) +;
		"Retorno: "			+ cRetorno		+ Chr(13) + Chr(10) +;
		"Mensagem: "		+ cMensagem		+ Chr(13) + Chr(10) +;
		"Chave consulta: "	+ chaveConsulta + Chr(13) + Chr(10) +;
		"CNPJ: " 			+ cTrpCNPJ 		+ Chr(13) + Chr(10) +;
		"Inscr. Est: " 		+ cTrpInsEst 	+ Chr(13) + Chr(10) +;
		"Cod. Transp: "		+ cCodTransp 	+ Chr(13) + Chr(10) +;
		"Nome: " 			+ cNomeTransp	+ Chr(13) + Chr(10) +;
		"Ambiente: " 		+ cTrpAmbien 	+ Chr(13) + Chr(10) +;
		"Protocolo: " 		+ cTrpProt 		+ Chr(13) + Chr(10) +;
		"Situação: " 		+ cTrpSitua 	+ Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
		"Ressalva(s)"  		+ cDadosRes		,"Função retConsEmp(ADLOG057P)")

		lRet := .T.

	ElseIf	cRetorno == "501" //Transportadora não cadastrada no sistema Ophos.

		//Recupera CNPJ.
		cTrpCNPJ 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_cnpjTransportador:Text))

		//Recupera Inscrição Estadual.
		cTrpInsEst 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_ieTransportador:Text))

		//Recupera ambiente.
		cTrpAmbien 		:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_ambiente:Text))

		//Recupera chave da consulta.
		chaveConsulta	:= Alltrim(cValToChar(oXml:_retConsultaTransportador:_chaveConsulta:Text))

		//Recupera nome da transportadora.
		cCodTransp	:= Posicione("SA4",3,xFilial("SA4") + cTrpCNPJ, "A4_COD")
		cLoja		:= Posicione("SA4",3,xFilial("SA4") + cTrpCNPJ, "A4_LOJTRA")
		cNomeTransp := Posicione("SA4",3,xFilial("SA4") + cTrpCNPJ, "A4_NOME")

		MsgAlert(	"Consulta transportadora " 		+ Chr(13) + Chr(10) +;
		"Retorno: "			+ cRetorno		+ Chr(13) + Chr(10) +;
		"Mensagem: "		+ cMensagem		+ Chr(13) + Chr(10) +;
		"Chave consulta: "	+ chaveConsulta + Chr(13) + Chr(10) +;
		"CNPJ: " 			+ cTrpCNPJ 		+ Chr(13) + Chr(10) +;
		"Inscr. Est: " 		+ cTrpInsEst 	+ Chr(13) + Chr(10) +;
		"Cod. Transp: "		+ cCodTransp 	+ Chr(13) + Chr(10) +;
		"Nome: " 			+ cNomeTransp	+ Chr(13) + Chr(10) +;
		"Ambiente: " 		+ cTrpAmbien 	+ Chr(13) + Chr(10) ,"Função retConsEmp(ADLOG057P)")
		lRet := .T.

	Else

		MsgStop(	"Consulta transportadora " 		+ Chr(13) + Chr(10) +;
		"Retorno: "		+ cRetorno		+ Chr(13) + Chr(10) +;
		"Mensagem"		+ cMensagem ,"Função retConsEmp(ADLOG057P)")
		lRet := .F.

	Endif

	//Grava o status no cadastro da transportadora.
	If lRet
		grvStatTrp(cTrpCNPJ,cRetorno,cMensagem,cTrpSitua)

	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} grvStatTrp  
	Grava status no cadastro da transportadora. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 11/06/2019
	@version 01
	/*/
Static Function grvStatTrp(cTrpCNPJ,cRetorno,cMensagem,cTrpSitua)

	//Variáveis.
	Local aArea	:= GetArea()

	//Remove espaços em branco.
	cTrpCNPJ	:= Alltrim(cValToChar(cTrpCNPJ))
	cRetorno	:= Alltrim(cValToChar(cRetorno))
	cMensagem	:= Alltrim(cValToChar(cMensagem))

	//Valida argumentos da função.
	If Empty(cTrpCNPJ)
		MsgStop("Função não recebeu o CNPJ da transportadora.","Função grvStatTrp(ADLOG057P)")
		logZBE("FUNCAO Função grvStatTrp:")
		RestArea(aArea)
		Return Nil

	ElseIf	Empty(cRetorno)
		MsgStop("Função não recebeu o status de retorno do sistema Ophos.","Função grvStatTrp(ADLOG057P)")
		logZBE("FUNCAO Função grvStatTrp:")
		RestArea(aArea)
		Return Nil

	ElseIf	Empty(cMensagem)
		MsgStop("Função não recebeu a mensagem do sistema Ophos.","Função grvStatTrp(ADLOG057P)")
		logZBE("FUNCAO Função grvStatTrp:")
		RestArea(aArea)
		Return Nil

	EndIf

	//Seleciona a tabela SA4.
	DbSelectArea("SA4")
	SA4->(DbSetOrder(3))
	SA4->(DbGoTop())

	//Efetua a busca da transportadora pelo CNPJ.
	If SA4->( DbSeek( xFilial("SA4") + cTrpCNPJ) )
		/*RecLock("SA4",.F.)
		Replace A4_X_OPHOS With cTrpSitua + " / " + cRetorno + "-" + cMensagem + " / HORA " + cValToChar(Time()) + " DATA " + DToC(Date()) //Salva status de retorno do sistema Ophos.
		MsUnLock()*/

	Else
		MsgStop("Não foi possível atualizar o status da transportadora de CNPJ " + cTrpCNPJ + ".","Função grvStatTrp(ADLOG057P)")
		logZBE("FUNCAO grvStatTrp: NAO ATUALIZOU O STATUS DA TRANSPORTADORA DE CNPJ " + cTrpCNPJ)

	EndiF

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} retEnvMDFE  
	Tratamento de retorno do web service para emissão de MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function retEnvMDFE(oXml,cRoteiro,lTransbordo,cSeq,lUpdate,cDtEntr)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local lRet			:= .F.
	Local aRet			:= {}
	Local lImport		:= .F.
	Local nPosHash		:= 0
	Local cStringXML	:= ""
	Local cHash			:= ""
	Local cDtEmiss		:= ""

	//Valida argumentos.
	If 	Empty(cRoteiro)
		MsgStop("Função retEnvMDFE não recebeu o hash como argumento.","Função retEnvMDFE(ADLOG057P)")
		logZBE("FUNCAO retEnvMDFE: NAO RECEBEU cRoteiro COMO ARGUMENTO")
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_retConversaoCTe:_status:Text))
	logZBE("FUNCAO retEnvMDFE: RECEBEU STATUS " + cRetorno)

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_retConversaoCTe:_mensagem:Text))

	//Tratamento por status de retorno.
	If cRetorno == "100" ///Gerando
		lRet := .T.
		
	ElseIf cRetorno == "101"//Autorizado.
		lRet := .T.

	Else //Status de retorno inesperado.
		MsgStop("Status de retorno" + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem,"Função retEnvMDFE(ADLOG057P)")
		lRet :=  .F.

		//Salva o objeto em string.
		SAVE oXml XMLSTRING cStringXML

		//Busca o texto hash.
		nPosHash := At("<hash>",cStringXML)

		//Se achou o texto <hash> .
		If nPosHash > 0 .And. cRetorno == "999"
			cHash := Alltrim(cValToChar(oXml:_retConversaoCTe:_hash:Text))
			lImport := .T.

		EndIf

	EndIf

	//Salva registro na tabela ZFK.
	If lRet
		aRet := grvMDFHash(cRetorno,oXml,cRoteiro,lTransbordo,cSeq,lUpdate,cDtEntr,@cDtEmiss)

	EndIf

	//Importa o MDF-e.
	If lImport
		aRet := impMDF(cHash,oXml,cRoteiro,cSeq,cStringXML,lTransbordo,cDtEntr)

	EndIf

	//Obtém hash do MDF-e.
	If Len(aRet) > 0
		dowArq(aRet,2,cDtEntr)

	EndIf
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} grvMDFHash  
	Função para gravar o hash do MDF-e na tabela ZFK. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function grvMDFHash(cRetorno,oXml,cRoteiro,lTransbordo,cSeq,lUpdate,cDtEntr,cDtEmiss)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lGrv			:= .T.
	Local cTpDoc		:= "2"
	local cHash			:= ""
	Local cNumMDF		:= ""
	Local cSerMDF		:= ""
	Local aRet			:= {}
	Local aNotas		:= {}
	Local nValor		:= 0
	Local i				:= 1
	//Local cQuery		:= ""
	Local cStatus		:= ""
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	//Local aXmlCons		:= {}
	//Local oXmlCons		:= Nil
	//Local cRetoConst	:= ""	
	//Local aDadReb		:= {}	
	Local cDtEnt		:= ""
	Local nVezesP		:= GetMv("MV_#NVPROC")//Criar variável.
	Local nAux			:= 0
	Local cMsgOphos		:= ""
	Local cProtCan		:= ""
	
	Default lUpdate		:= .F.

	//Verifica o status do retorno.
	If cRetorno <> "100" .And. cRetorno <> "101"
		RestArea(aArea)
		Return aRet
		
	EndIf
	
	//Remove espaços em branco.
	cRoteiro := Alltrim(cRoteiro)	
	
	//Válida argumentos da função.
	If Empty(cRoteiro)
		MsgStop("Função grvMDFHash não recebeu o argumento cRoteiro.","Função grvMDFHash(ADLOG057)")
		logZBE("FUNCAO cRoteiro: NAO RECEBEU O ARGUMENTO cRoteiro")
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Obtém o número, série e hash do CT-e.
	cHash	:= Alltrim(cValToChar(oXml:_retConversaoCTe:_hash:Text))
	cSerMDF := Alltrim(cValToChar(oXml:_retConversaoCTe:_dadosMDFe:_serie:Text))
	cNumMDF := Alltrim(cValToChar(oXml:_retConversaoCTe:_dadosMDFe:_numero:Text))
	
	//
	While cRetorno == "100" .And. nVezesP > nAux
		
		//Atribui valores as variáveis.
		//Executa função de status do MDF-e.
		aStatus := statusMDFE(cHash)
		
		//
		If Len(aStatus) > 0
			
			//
			If Len(aStatus[1]) == 11
				cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
				cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
				cProtEmis	:= Alltrim(cValToChar(aStatus[1][3]))
				cChaveAces	:= Alltrim(cValToChar(aStatus[1][4]))
				cRetorno    := Alltrim(cValToChar(aStatus[1][9]))
				cSerMDF 	:= Alltrim(cValToChar(aStatus[1][8]))
				cNumMDF 	:= Alltrim(cValToChar(aStatus[1][7]))
				cProtCan	:= Alltrim(cValToChar(aStatus[1][6]))
				cDtEmiss	:= Alltrim(cValToChar(aStatus[1][11]))
			
			EndIf
	
		EndIf
		
		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - grvMDFHash - cRetorno " + cValToChar(cRetorno) )
		
		//Verifica o status do retorno.
		If cRetorno <> "100" .And. cRetorno <> "101"
			consulMDF(cHash,1)
			aRet := {}
			RestArea(aArea)
			Return aRet
			
		EndIf	
		
		//
		Sleep(1000)
		nAux++	
	
	End
	
	//
	If cRetorno == "100"
		MsgInfo("MDF-e." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMsgOphos + Chr(13) + Chr(10) + "Necessário verificar na consulta de MDF-e o status do documento " + cNumMDF + "/" + cSerMDF + ".","Função grvMDFHash(ADLOG057P)")
	
	EndIf

	//Obtém notas fiscais do roteiro.
	aNotas:= obtNF(cRoteiro,cDtEntr)
	
	//
	If Len(aNotas) <= 0
		RestArea(aArea)
		Return aRet
		
	EndIf
	
	//Obtém sequência do roteiro.
	If Empty(Alltrim(cValToChar(cSeq)))
		cSeq := seqZFK(cRoteiro,cDtEntr,"2")
		
	EndIf

	//Valida retorno da função seqZFK.
	If Empty(cSeq)
		MsgStop("Não foi possível obter a sequência de envio do roteiro " + cCarga + ".","Função grvMDFHash(ADLOG057)")
		RestArea(aArea)
		Return aRet
		
	EndIf
	
	//
	For i := 1 To Len(aNotas)

		//
		cDtEnt := cDtEntr

		//Grava dados na tabela ZFK.
		grvZFK(lGrv,cTpDoc,cRoteiro,cSeq,cTransp,cLoja,cVeiculo,cMotorista,aNotas[i][2],aNotas[i][1],cHash,cNumMDF,cSerMDF,nValor,;
			   cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEnt,"N",cCodCrg,cProtCan,,,,cDtEmiss,0)

				Aadd(aRet,{cRoteiro,cSeq,cTpDoc,aNotas[i][2],aNotas[i][1]})

	Next i
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} statusMDFE  
	Retorna status do MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function statusMDFE(cHash)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aRetorno		:= {}
	Local oXml			:= Nil
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local cMsgOphos		:= ""
	Local cStatus		:= ""
	Local aRetCons		:= {}

	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	Local cProtCance	:= ""
	Local cProtEnce 	:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	Local cDtEmiss		:= ""

	//Remove espaços em branco.
	cHash := Alltrim(cValToChar(cHash))

	//Executa consulta do MDF-e.
	aRetCons := consulMDF(cHash,2)

	//Valida retorno da função consulMDF.
	If ! aRetCons[1][1]
		Aadd(aRetorno,{"",""})
		RestArea(aArea)
		Return aRetorno
		
	EndIf

	//Recupera objeto xml.
	oXml := aRetCons[1][2]

	//Recupera retorno e mensagem Ophos.
	cRetorno  	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_status:Text))
	cMensagem 	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_mensagem:Text))
	cMsgOphos	:= cRetorno + "-" + cMensagem

	//Protocolo de emissão e chave de acesso.
	If cRetorno == "101" .Or. cRetorno == "102" .Or. cRetorno == "107"
		cProtEmis	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_protocolo:Text))
		cChaveAces	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_chaveAcesso:Text))
		cNumDoc		:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_numero:Text))
		cSerDoc		:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_serie:Text))
		cDtEmiss	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_dataAutorizacao:Text))
		cDtEmiss    := StrTran(Substr(cDtEmiss,1,10),"-","")
		
	EndIf

	//Protocolo de cancelamento.
	If cRetorno == "102"
		cProtCance	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosCancelamento:_protocolo:Text))
		
	EndIf
	
	//Protocolo de encerramento.
	If cRetorno == "107"
		cProtEnce 	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosEncerramento:_protocolo:Text))
		
	EndIf

	//Define o status do documento.
	cStatus := tlbStatus(cRetorno,2)
	
	//
	Aadd(aRetorno,{cStatus,cMsgOphos,cProtEmis,cChaveAces,cProtEnce,cProtCance,cNumDoc,cSerDoc,cRetorno,oXml,cDtEmiss})
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} consulMDF  
	Função para consultar MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function consulMDF(cHash,nTipo)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUrl  		:= GetMv("MV_#CONMDF")
	Local oRestClient	:= Nil
	Local cErroWS		:= ""
	Local cRetGet		:= ""
	Local aXml			:= {}
	Local lRet			:= .T.
	Local aRet			:= {}

	//Retira espacos em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Verifica se os argumentos estão em branco.
	If Empty(cHash)
		MsgStop("Função consulMDF não recebeu o hash.","Função consulMDF(ADLOG057P)")
		logZBE("FUNCAO consulMDF: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	ElseIf Empty(cUrl)
		MsgStop("Função consulMDF não obteve a URL para consulta do MDF-e (MV MV_#CONMDF).","Função consulMDF(ADLOG057P)")
		logZBE("FUNCAO consulMDF: NAO OBTEVE A URL PARA CONSULTA DO MDF-E MV MV_#CONMDF")
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl   	:= StrTran(cUrl,"{hash}",cHash)

	//Cria o objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui o path.
	oRestClient:setPath("")

	//Executa chamada no web service.
	If oRestClient:Get()
		cRetGet := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função consulMDF(ADLOG057P)")
		logZBE("FUNCAO consulMDF: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS)

		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	Endif

	//Salva retorno do web service.
	gravarTXT(cRetGet, cHash + "Ret_Consulta_MDFE","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetGet)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//
	If nTipo == 2
		Aadd(aRet,{.T.,oXml})
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Verifica o status de retorno de geração do CT-e.
	lRet := obtRet(7,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} retConsMDF  
	Tratamento de retorno do web service para consulta de MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function retConsMDF(oXml,cHash)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet			:= .T.
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	Local cChaveAc		:= ""
	Local cDataAut		:= ""
	Local cProtocolo	:= ""
	Local cStatus		:= ""
	//Local Update		:= ""
	Local cMsgOphos		:= ""
	//Local aStatus		:= {}
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	Local cProtCance	:= ""
	Local cDataEnce		:= ""
	Local cProtEnce		:= ""
	Local cDataCanc		:= ""
	Local cProtCanc		:= ""
	Local cJustiCanc	:= ""

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_RetConsultaMdfe:_status:Text))

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_mensagem:Text))

	//Recupera mensagem da Ophos.
	cMsgOphos := cRetorno + "-" + cMensagem

	If cRetorno == "107"

		//Número e série do MDF-e.
		cNumDoc 	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_numero:Text))
		cSerDoc		:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_serie:Text))

		cChaveAc	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_chaveAcesso:Text))
		cDataAut	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_dataAutorizacao:Text))
		cProtocolo	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_protocolo:Text))
		cDataEnce	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosEncerramento:_dataEncerramento:Text))
		cProtEnce	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosEncerramento:_protocolo:Text))

		MsgInfo("Consulta MDF-e."		+ Chr(13) + Chr(10) +;
		"Retorno: " 			+ cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " 			+ cMensagem + Chr(13) + Chr(10) +;
		"Número MDF-e: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Série MDF-e: " 		+ cSerDoc + Chr(13) + Chr(10) +;
		"Chave acesso:" 		+ cChaveAc + Chr(13) + Chr(10) +;
		"Data Autorização: " 	+ cDataAut + Chr(13) + Chr(10) +;
		"Protocolo: " 			+ cProtocolo + Chr(13) + Chr(10) +;
		"Data Encer.:" + cDataEnce + Chr(13) + Chr(10) +;
		"Protocolo Encer.:" + cProtEnce ,"Função retConsMDF(ADLOG057P)")

		lRet 	:=  .T.
		cStatus :=  "T"

	ElseIf cRetorno == "101"

		//Número e série do MDF-e.
		cNumDoc 	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_numero:Text))
		cSerDoc		:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_serie:Text))

		cChaveAc	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_chaveAcesso:Text))
		cDataAut	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_dataAutorizacao:Text))
		cProtocolo	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_protocolo:Text))

		MsgInfo("Consulta MDF-e."		+ Chr(13) + Chr(10) +;
		"Retorno: " 			+ cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " 			+ cMensagem + Chr(13) + Chr(10) +;
		"Número MDF-e: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Série MDF-e: " 		+ cSerDoc + Chr(13) + Chr(10) +;
		"Chave acesso:" 		+ cChaveAc + Chr(13) + Chr(10) +;
		"Data Autorização: " 	+ cDataAut + Chr(13) + Chr(10) +;
		"Protocolo: " 			+ cProtocolo ,"Função retConsMDF(ADLOG057P)")

		lRet :=  .T.
		cStatus := "E"

	ElseIf cRetorno == "100"
		MsgInfo("Consulta MDF-e." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem ,"Função retConsMDF(ADLOG057P)")

		lRet :=  .T.
		cStatus := "D"

	ElseIf cRetorno == "102"

		//Número e série do MDF-e.
		cNumDoc 	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_numero:Text))
		cSerDoc		:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosMdfe:_serie:Text))

		cChaveAc	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_chaveAcesso:Text))
		cDataAut	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_dataAutorizacao:Text))
		cProtocolo	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_protocolo:Text))
		cDataCanc	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosCancelamento:_dataCancelamento:Text))
		cProtCanc	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosCancelamento:_protocolo:Text))
		cJustiCanc	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosCancelamento:_justificativa:Text))

		MsgAlert("Consulta MDF-e."		+ Chr(13) + Chr(10) +;
		"Retorno: " 			+ cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " 			+ cMensagem + Chr(13) + Chr(10) +;
		"Número MDF-e: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Série MDF-e: " 		+ cSerDoc + Chr(13) + Chr(10) +;
		"Chave acesso:" 		+ cChaveAc + Chr(13) + Chr(10) +;
		"Data Autorização: " 	+ cDataAut + Chr(13) + Chr(10) +;
		"Protocolo: " 			+ cProtocolo + Chr(13) + Chr(10) +;
		"Data Canc.:" + cDataCanc + Chr(13) + Chr(10) +;
		"Protocolo Canc.:" + cProtCanc + Chr(13) + Chr(10) +;
		"Just. Canc:" + cJustiCanc ,"Função retConsMDF(ADLOG057P)")

		lRet 	:=  .T.
		cStatus :=  "C"

	Else //Demais status.

		MsgStop("Consulta MDF-e." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + Chr(13) + Chr(10) +;
		"Número MDF-e: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Série MDF-e: " + cSerDoc ,"Função retConsMDF(ADLOG057P)")
		lRet :=  .F.
		cStatus := "N"

	EndIf

	//Executa função de status do MDF-e.
	cStatus  	:= tlbStatus(cRetorno,2)
	cMsgOphos	:= cRetorno + "-" + cMensagem

	//Protocolo de emissão e chave de acesso.
	If cRetorno == "101" .Or. cRetorno == "102" .Or. cRetorno == "107"
		cProtEmis	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_protocolo:Text))
		cChaveAces	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosAutorizacao:_chaveAcesso:Text))

	EndIf

	//Protocolo de cancelamento.
	If cRetorno == "102"
		cProtCance	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosCancelamento:_protocolo:Text))
		
	EndIf
	
	//
	If cRetorno == "107"
		cProtEnce	:= Alltrim(cValToChar(oXml:_RetConsultaMdfe:_dadosEncerramento:_protocolo:Text))
		
	EndIf
	
	//
	If ! Empty(cDataAut)
		cDataAut := Substr(cDataAut,1,10)
		cDataAut := StrTran(cDataAut,"-","")
		
	EndIf
	
	//
	lRet := updateMDF(cNumDoc,cSerDoc,cStatus,cMsgOphos,cProtEmis,cProtCance,cChaveAces,cProtEnce,cHash,cDataAut)
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} updateMDF  
	Update MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function updateMDF(cNumDoc,cSerDoc,cStatus,cMsgOphos,cProtEmis,cProtCance,cChaveAces,cProtEnce,cHash,cDataAut)

	//Variáveis.
	Local aArea		:= GetArea()
	Local Update	:= ""
	Local lRet 		:= .T.
	
	//Monta script sql.
	Update := "UPDATE " + RetSqlName("ZFK") + " SET " + Iif(Empty(cDataAut),""," ZFK_DTEMIS = '" + cDataAut + "', ") + " ZFK_NUMDOC = '" + cNumDoc + "', ZFK_SERDOC = '" + cSerDoc + "', ZFK_STATUS = '" + cStatus + "', ZFK_OPHOS ='" + cMsgOphos + "', " + ;
	" ZFK_PROTEM='" + cProtEmis + "', ZFK_PROTCA='" + cProtCance + "', ZFK_CHAVE='" + cChaveAces + "', ZFK_PROENC='" + cProtEnce + "' WHERE ZFK_HASH ='" + cHash + "' AND ZFK_TPDOC = '2'"

	//Atualiza status do MDF-e.
	If TcSqlExec(Update) < 0
		MsgStop("Não foi possível atualizar o status do MDF-e " + cNumDoc + "/" + cSerDoc + "." + Chr(13) + Chr(10) + "TCSQLError " + TCSQLError() ,"Função updateMDF(ADLOG057P)")
		logZBE("FUNCAO updateMDF: NAO FOI POSSIVEL ATUALIZAR O STATUS DO MDF-E " + cNumDoc + "/" + cSerDoc + " ERRO " + TCSQLError())
		lRet := .F.

	EndIf
	
	//
	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} impMDF  
	Realiza a importação do MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function impMDF(cHash,oXml,cRoteiro,cSeq,cStringXML,lTransbordo,cDtEntr)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cQuery		:= ""
	Local cDadosZFK		:= ""
	Local aNotas		:= {}
	Local i				:= 0
	Local lGrv			:= .T.
	Local cTpDoc		:= "2"
	//Local aDadReb		:= {}
	Local cNota			:= ""
	Local cSerie		:= ""
	Local aStatus		:= {}
	Local cStatus		:= ""
	Local cMsgOphos 	:= ""
	Local cProtEmis 	:= ""
	Local cChaveAces	:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	//Local cValor		:= ""
	Local nValor		:= 0
	Local cEmissTp		:= "N"
	//Local cRetorno		:= ""
	Local cProtCan		:= ""
	Local cDtEmiss		:= ""
	Local aRet			:= {}

	//Remove espaços em branco.
	cHash 		:= Alltrim(cValToChar(cHash))
	cRoteiro	:= Alltrim(cValToChar(cRoteiro))
	lTransbordo	:= Alltrim(cValToChar(lTransbordo))

	//Valida o hash.
	If Empty(cHash)
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Valida se o documento já não está lançado no sistema.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFK_ROTEIR + '-' + ZFK_SEQENV + '-' + ZFK_HASH  AS ZFK_HASH " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " AS ZFK " 
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL =    '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_HASH =  '" + cHash + "' "  
	cQuery += " AND ZFK_TPDOC = '2' " //MDF-e 
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	
	//
	If Select("MDFE_EMITIDO") > 0
		MDFE_EMITIDO->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "MDFE_EMITIDO"
	DbSelectArea("MDFE_EMITIDO")
		cDadosZFK := Alltrim(cValToChar(MDFE_EMITIDO->ZFK_HASH))
	MDFE_EMITIDO->(DbCloseArea())

	//Valida se não há o registro na tabela ZFK.
	If ! Empty(cDadosZFK)
		logZBE("FUNCAO impMDF: JA HA REGISTRO NA TABELA ZFK PARA A CARGA/SEQUENCIA " + cDadosZFK + "-" + DToC(SToD(cDtEntr)) )
		RestArea(aArea)
		Return aRet

	EndIf
	
	//Obtém status do CT-e.
	aStatus := statusMDFE(cHash)	

	//Valida o retorno da função statusMDFE.
	If Len(aStatus) <= 0
		MsgStop("Não foi possível obter o status do MDF-e.","Função impMDF(ADLOG057P)")
		RestArea(aArea)
		Return aRet

	EndIF

	//Valida o retorno da função statusMDFE.
	If Len(aStatus[1]) <> 11
		MsgStop("Não foi possível obter o status do MDF-e.","Função impMDF(ADLOG057P)")
		RestArea(aArea)
		Return aRet

	EndIF

	//Obtém as notas fiscais que estão vinculadas à carga.	
	aNotas 	:= obtNF(cRoteiro,cDtEntr)

	//Verifica se há notas fiscais vinculadas à carga.
	If Len(aNotas) <= 0
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Itera sobre as notas.
	For i := 1 To Len(aNotas)

		//Recupera nota e série do roteiro.
		cNota := Alltrim(cValToChar(aNotas[i][2]))
		cSerie:= Alltrim(cValToChar(aNotas[i][1]))

		//Grava dados na tabela ZFK.
		grvZFK(lGrv,cTpDoc,cRoteiro,cSeq,cTransp,cLoja,cVeiculo,cMotorista,cNota,cSerie,cHash,cNumDoc,;
		       cSerDoc,nValor,cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEntr,cEmissTp,cCodCrg,cProtCan,,,,cDtEmiss,0)

		//Adiciona dados ao array de retorno.
		Aadd(aRet,{cRoteiro,cSeq,cTpDoc,cNota,cSerie})

	Next i
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} retCancMDF  
	Função para tratamento do retorno do web service para
	cancelamento de MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function retCancMDF(oXml,cHash,cDtEntr)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cRetorno	:= ""
	Local cMensagem	:= ""
	Local lRet		:= .F.

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_RetCancelamentoMdfe:_status:Text))

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_RetCancelamentoMdfe:_mensagem:Text))

	If cRetorno == "102" // Cancelado.

		MsgInfo("Cancelamento MDF-e." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + ".","Função retCancMDF")

		lRet :=  .T.

	Else //Demais status.

		MsgAlert("Cancelamento MDF-e." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + ".","Função retCancMDF")
		lRet :=  .F.

	EndIf

	//Marcar documento como cancelado.
	If lRet
		lRet := cancDoc(cHash,"2")
		
	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} xmlCTEdow  
	Função para download do xml do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function xmlCTEdow(cHash,cPFis,cArqXml,lAbreArq,cChave)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUrl		:= GetMv("MV_#XMLCTE")
	Local cCaminho	:= ""
	Local cArq		:= ""
	Local lRet 		:= .T.
	
	Default cPFis		:= ""
	Default cArqXml		:= ""
	Default lAbreArq	:= .T.
	Default cChave		:= ""

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função xmlCTEdow não recebeu o hash do CT-e.","Função xmlCTEdow(ADLOG057P)")
		logZBE("FUNCAO xmlCTEdow: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("Função xmlCTEdow não obteve a URL para efetuar download do xml do CT-e (MV MV_#XMLCTE).","Função xmlCTEdow(ADLOG057P)")
		logZBE("FUNCAO xmlCTEdow: NAO OBTEVE A URL PARA EFETUAR O DOWNLOAD DO XML DO CT-E MV MV_#XMLCTE")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Nome do arquivo.
	If ! Empty(cChave)
		cArq := cChave
	Else
		cArq := cHash + "CTE"
	
	EndIf

	//Adiciona o hash à URL.
	cUrl := StrTran(cUrl,"{hash}",cHash)

	//Faz o download do arquivo.
	cCaminho := obtArquivo(cUrl,cArq,"xml",cPFis,@cArqXml)

	//Verifica o retorno da função obtArquivo.
	If Empty(cCaminho)
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	lRet := fVisualiza(cCaminho,lAbreArq)
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} retEnvGrp  
	Tratamento de retorno do web service para emissão de CT-e
	agrupado. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/06/2019
	@version 01
	/*/
Static Function retEnvGrp(oXml,aNotas,cSeq,lVecPrTrans,cTipoEmiss,cRoteiro,lUpdate,nVlrCompl,cDtEntr,;
	                      cNumRef,cCTECompl,cSCTECompl,lCmpDia,aPorcOco,cAgrupa) //Everson - 04/09/2019. Chamado 044314.

	//Variáveis.
	Local aArea			:= GetArea()
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local i				:= 0
	Local x				:= 0
	Local cNota			:= ""
	Local lRet			:= .F.
	Local aRet			:= {}
	Local cSerie		:= ""
	Local cNumCTE		:= ""
	Local cSerCTE		:= ""
	//Local cQuery		:= ""
	Local nPontEnt		:= 0
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	//Local cTpDoc		:= "1"
	Local lChkStatus	:= .F.
	Local cMsgOphos		:= ""
	Local cProtCan		:= ""
	Local xDdAverb		:= Nil //Everson³01/07/19³044314.
	Local cHash			:= ""
	Local aStatus		:= ""
	Local nValor		:= 0
	Local nVlrOco		:= 0
	Local nVlrOcoT		:= 0
	Local cDtEmiss		:= ""
	Local lImport		:= .F.

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_retEnvio:_status:Text))
	cMensagem:= Alltrim(cValToChar(oXml:_retEnvio:_mensagem:Text))

	//Recupera mensagem Ophos.
	cMsgOphos:= cRetorno + "-" + cMensagem	

	//Informa o status de retorno ao usuário.
	If cRetorno == "100"
		cNumCTE := Alltrim(cValToChar(oXml:_retEnvio:_dadosCTe:_numero:Text))
		cSerCTE := Alltrim(cValToChar(oXml:_retEnvio:_dadosCTe:_serie:Text))
		lRet := .T.

	ElseIf cRetorno == "101"
		cNumCTE := Alltrim(cValToChar(oXml:_retEnvio:_dadosCTe:_numero:Text))
		cSerCTE := Alltrim(cValToChar(oXml:_retEnvio:_dadosCTe:_serie:Text))
		lRet := .T.
		
	ElseIf cRetorno == "503"
		lImport := .T.
		
	Else
		MsgAlert("O serviço de emissão de CT-e retornou: " + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + Chr(13) + Chr(10) + Chr(13) + Chr(10) +;
		"Carga: " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + Chr(13) + Chr(10) +;
		"Veículo: " +  cVeiculo,"Função retEnvGrp(ADLOG057P)")

	EndIf

	//
	If lRet

		//
		nPontEnt := Len(aNotas)
				
		//
		nValor := Val(cValToChar(oXml:_retEnvio:_dadosCTe:_valor:Text))
		
		//
		If ! lCmpDia
		
			//
			For i := 1 To Len(aNotas)
			
				//
				cSerie	:= Alltrim(cValToChar(aNotas[i][1]))
				cNota	:= Alltrim(cValToChar(aNotas[i][2]))
				
				aRet := grvCTEHash(@cRetorno,@oXml,cNota,cSerie,cNumCTE,cSerCTE,cSeq,lVecPrTrans,cTipoEmiss,cRoteiro,cVeiculo,cTransp,cLoja,cMotorista,;
								   nPontEnt,@cProtEmis,@cChaveAces,cDtEntr,lUpdate,nVlrCompl,cCodCrg,@lChkStatus,@cMsgOphos,@cProtCan,@cHash,cCTECompl,;
								   cSCTECompl,cAgrupa,nValor,@cDtEmiss) //Everson - 04/09/2019. Chamado 044314.
			
			Next i
		
		Else
			
			//
			nVlrOcoT := 0
			For x := 1 To Len(aPorcOco)
				
				//
				cCodOcorr	:= aPorcOco[x][1]
				nVlrOco 	:= nValor * aPorcOco[x][3]
				cCodZFA		:= aPorcOco[x][4]
				
				//
				If x == Len(aPorcOco) .And. nVlrOcoT > 0
					nVlrOco := nValor - nVlrOcoT
					
				EndIf
				
				//
				For i := 1 To Len(aNotas)
				
					//
					cSerie	:= Alltrim(cValToChar(aNotas[i][1]))
					cNota	:= Alltrim(cValToChar(aNotas[i][2]))
					
					aRet := grvCTEHash(@cRetorno,@oXml,cNota,cSerie,cNumCTE,cSerCTE,cSeq,lVecPrTrans,cTipoEmiss,cRoteiro,cVeiculo,cTransp,cLoja,cMotorista,;
									   nPontEnt,@cProtEmis,@cChaveAces,cDtEntr,lUpdate,nVlrCompl,cCodCrg,@lChkStatus,@cMsgOphos,@cProtCan,@cHash,cCTECompl,;
									   cSCTECompl,cAgrupa,nVlrOco,@cDtEmiss) //Everson - 04/09/2019. Chamado 044314.
				
				Next i
				
				//
				nVlrOcoT += nVlrOco
	
			Next x
			
		EndIf

	EndIf

	//Everson - 04/09/2019. Chamado 044314.
	If lImport
		MsAguarde({|| aRet := impAgrCTE(oXml,cRetorno,cMensagem,cRoteiro,cDtEntr,cCodCrg,cNumRef,cTransp,cLoja,;
					  cMotorista,cVeiculo,@cHash,cCTECompl,cSCTECompl,lCmpDia,aPorcOco,cAgrupa,aNotas,cSeq,cTipoEmiss) },;
					  "Aguarde...","Importando CT-e referente à carga " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".",.F.)

	EndIf
	
	//Everson 01/07/19 044314.
	//Grava averbação.
	If ! Empty(cHash)
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - retEnvGrp - atualização da averbação " )
		aStatus := statusCTE(cHash)

		//
		If Len(aStatus) > 0
	
			//
			If Len(aStatus[1]) == 12
				xDdAverb := aStatus[1][11]
				
			EndIf
			
		EndIf
		
		//
		If ValType(xDdAverb) <> "U"
			ddAverb(xDdAverb,cHash)
			
		EndIf
	
	EndIf

	//
	If Len(aRet) > 0

		//
		If Type("aRetCFch") <> "U"
			aRetCFch := aRet
			
		EndIf

		//Salva arquivo xml e grava valor de ICMS.
		slvXML(aRet)

		//Download de arquivos.
		dowArq(aRet,1,cDtEntr)
		
	EndIf
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} grvCTEHash  
	Grava retorno da emissão do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function grvCTEHash(cRetorno,oXml,cNota,cSerie,cNumDoc,cSerDoc,cSeq,lVecPrTrans,;
		cTipoEmiss,cRoteiro,cVeiculo,cTransp,cLoja,cMotorista,nPontEnt,;
		cProtEmis,cChaveAces,cDtEntr,lUpdate,nVlrCompl,cCodCrg,lChkStatus,;
		cMsgOphos,cProtCan,cRetHash,cCTECompl,cSCTECompl,cTpEnvCTE,nVlrCC,cDtEmiss)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aRet			:= {}
	Local lGrv			:= .T.
	Local cTpDoc		:= "1"
	Local cHash			:= ""
	//Local cMensagem		:= ""
	Local cStatus		:= ""
	Local aStatus		:= {}
	Local cEmissTp		:= ""
	Local nVezesP		:= GetMv("MV_#NVPROC")
	Local nAux			:= 0
	Local nValor		:= 0
	Local nPorc			:= getPorEm(cTpVa) //GetMv("MV_#CTEPOR") //Everson - 12/12/2019 - Chamado 029058.

	Default cMsgOphos	:= ""
	Default cProtCan	:= ""
	Default lChkStatus	:= .F.
	Default nVlrCompl	:= 0
	Default cRetHash	:= ""
	Default nVlrCC		:= 0

	//Verifica o status do retorno.
	If	cRetorno <> "100" .And. cRetorno <> "101"
		RestArea(aArea)
		Return aRet

	EndIf

	//Obtém o hash e protocolo do CT-e.
	cHash := Alltrim(cValToChar(oXml:_retEnvio:_hash:Text))

	//
	If ! lChkStatus
		cMsgOphos	:= cRetorno + "-" + Alltrim(cValToChar(oXml:_retEnvio:_mensagem:Text))

	EndIf

	//
	While ! lChkStatus .And. cRetorno == "100" .And. nVezesP > nAux

		//
		aStatus := statusCTE(cHash)

		//
		If Len(aStatus) > 0

			//
			If Len(aStatus[1]) == 12
				cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
				cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
				cProtEmis	:= Alltrim(cValToChar(aStatus[1][3]))
				cChaveAces	:= Alltrim(cValToChar(aStatus[1][4]))
				cRetorno    := Alltrim(cValToChar(aStatus[1][10]))
				nValor		:= Val(cValToChar(aStatus[1][9]))
				cProtCan	:= Alltrim(cValToChar(aStatus[1][5]))
				cDtEmiss	:= Alltrim(cValToChar(aStatus[1][12]))

			EndIf

		EndIf

		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - grvCTEHash - " + cValToChar(cRetorno) )

		//Verifica o status do retorno.
		If cRetorno <> "100" .And. cRetorno <> "101"
			consulCTE(cHash,1)
			aRet := {}
			lChkStatus := .T.
			RestArea(aArea)
			Return aRet

		EndIf

		//
		Sleep(2000)
		nAux++	

	End	

	//
	If cRetorno == "100"
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - grvCTEHash - cRetorno - " + cValToChar(cRetorno) )
		MsgInfo("CT-e." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMsgOphos + Chr(13) + Chr(10) + "Necessário verificar na consulta de CT-e o status do documento " + cNumDoc + "/" + cSerDoc + ".","Função grvCTEHash(ADLOG057P)")

	EndIf

	//Recupera status e mensagem da Ophos.
	cStatus := tlbStatus(cRetorno,2)

	//Obtém sequêncial do roteiro.
	If Empty(cSeq)
		cSeq := seqZFK(cRoteiro,cDtEntr,"1")

	EndIf

	//Valida retorno da função seqZFK.
	If Empty(cSeq)
		MsgStop("Não foi possível localizar obter a sequência de envio do roteiro " + cRoteiro + ".","Função grvCTEHash(ADLOG057P)")
		RestArea(aArea)
		lChkStatus := .T.
		Return aRet

	EndIf

	//Obtém o valor da nota fiscal.
	Iif(cTipoEmiss == "01",cEmissTp:= "C",cEmissTp:= "N")

	//
	If nVlrCC > 0
		nValor := nVlrCC

	EndIf

	//
	nValor := ajusteVlNF(nValor,cRoteiro,cDtEntr,cSeq,nPontEnt,cNumDoc,cSerDoc)

	//Define o tipo de emissão.
	Iif(cTipoEmiss == "01",cEmissTp:= "C",cEmissTp:= "N")

	//
	If ! lUpdate

		//Everson - 06/11/2019. Chamado 029058.
		If nValor <= 0 .And. cTpDoc = "1"
			MsgStop("O CT-e " + cValToChar(cNumDoc) + "/" + cValToChar(cSerDoc) + " do veículo " + cValToChar(cVeiculo) + " está sem valor." ,"Função grvCTEHash(ADLOG057P)")
			aRet := {}
			RestArea(aArea)
			Return aRet 

		EndIf
		//

		//
		grvZFK(lGrv,cTpDoc,cRoteiro,cSeq,cTransp,cLoja,cVeiculo,cMotorista,cNota,cSerie,;
		       cHash,cNumDoc,cSerDoc,nValor,cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEntr,cEmissTp,;
		       cCodCrg,cProtCan,cCTECompl,cSCTECompl,cTpEnvCTE,cDtEmiss,nPorc)

		//
		cRetHash := cHash

	Else
		//Realiza update referente a CT-e.
		updateCTE(cHash,cStatus,cMsgOphos,cProtEmis,cChaveAces)

	EndIf

	//Verifica status para atribuir retorno para download do arquivo.			
	If cRetorno == "101" .Or. cRetorno == "102"
		//Adiciona dados ao array de retorno.
		aRet := {}
		Aadd(aRet,{cRoteiro,cSeq,cTpDoc,cNota,cSerie,cRetorno,cHash,cChaveAces,nVlrCC,cNumDoc,cSerDoc,cDtEmiss})

	EndIf

	//
	lChkStatus := .T.

	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} ajusteVlNF  
	Grava retorno da emissão do CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/06/2019
	@version 01
	/*/
Static Function ajusteVlNF(nValor,cRoteiro,cDtEntr,cSeq,nPontEnt,cNumDoc,cSerDoc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local nVlParc	:= 0
	Local cQuery	:= ""
	Local nValorTot	:= nValor
	Local nVlrZFK	:= 0
	Local nNrZFK	:= 0
	
	Default cNumDoc	:= ""
	Default cSerDoc	:= ""

	//Remove espaços em branco.
	cRoteiro := Alltrim(cValToChar(cRoteiro))
	cSeq	 := Alltrim(cValToChar(cSeq))

	//Verifica se a função recebeu argumentos.
	If Empty(cRoteiro)
		MsgStop("A função ajusteVlNF não recebeu o número do roteiro.","Função ajusteVlNF")
		logZBE("FUNCAO ajusteVlNF: NAO RECEBEU O NUMERO DO ROTEIRO")
		RestArea(aArea)
		Return nVlParc

	ElseIf nValor <= 0
		MsgStop("A função ajusteVlNF não recebeu o valor do frete.","Função ajusteVlNF")
		logZBE("FUNCAO ajusteVlNF: NAO RECEBEU O VALOR DO FRETE")
		RestArea(aArea)
		Return nVlParc

	EndIf
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " SUM(ZFK_VALOR) AS VALOR, COUNT(DISTINCT ZFK_NOTA) AS NR_NOTA "
	cQuery += " FROM "
	cQuery += " " + RetSqlName("ZFK") + " AS ZFK "
	cQuery += " WHERE "
	cQuery += " ZFK_FILIAL = '" + xFilial("ZFK") + "' "
	cQuery += " AND ZFK_ROTEIR = '" + cRoteiro + "' "
	cQuery += " AND ZFK_DTENTR = '" + cDtEntr  + "' "
	cQuery += " AND ZFK_TPDOC  = '1' "
	cQuery += " AND ZFK_SEQENV = '" + cSeq + "' "
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK_CODZFA = '" + cCodZFA + "' "
	
	//
	If ! Empty(cNumDoc) .And. ! Empty(cSerDoc)
		cQuery += " AND ZFK_NUMDOC  = '" + cNumDoc + "' "
		cQuery += " AND ZFK_SERDOC  = '" + cSerDoc + "' "
		
	EndIf
	
	//
	If Type("cCodOcorr") <> "U"
		cQuery += " AND ZFK_OCORRE  = '" + cValToChar(cCodOcorr) + "' "
		
	EndIf
		
	cQuery += " AND ZFK.D_E_L_E_T_ = '' "

	//Verifica se o alias existe.
	If Select("VLRZFK") > 0
		VLRZFK->(DbCloseArea())
		
	EndIf

	//Executa consulta no BD.
	TcQuery cQuery new Alias "VLRZFK"
	DbSelectArea("VLRZFK")
		nVlrZFK := Val(cValToChar(VLRZFK->VALOR))
		nNrZFK	:= Val(cValToChar(VLRZFK->NR_NOTA))
	VLRZFK->(DbCloseArea())
	
	//Verifica o número da parcela do lançamento e atribuir a porcentagem estabelecida.
	If (nPontEnt-1) > nNrZFK
		nVlParc := Round((nValorTot/nPontEnt),2)
		
	Else
		nVlParc := nValor - nVlrZFK
	
	EndIf
	
	//
	RestArea(aArea)

Return nVlParc
/*/{Protheus.doc} impAgrCTE  
	Gerar registro de CT-e não constante na base Protheus. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/06/2019
	@version 01
	/*/
Static Function impAgrCTE(oXml,cRetorno,cMensagem,cRoteiro,cDtEntr,cCodCrg,cNumRef,cTransp,;
						  cLoja,cMotorista,cVeiculo,cRetHash,cCTECompl,cSCTECompl,lCmpDia,;
						  aPorcOco,cAgrupa,aNotas,cSeq,cTipoEmiss) //Everson - 04/09/2019. Chamado 044314.

	//Variáveis.
	Local aArea			:= GetArea()
	Local cHash			:= ""
	Local cRotReg		:= ""
	Local cSeqCarga		:= ""
	Local cQuery		:= ""
	Local cDadosZFK		:= ""
	Local aStatus		:= {}
	Local lGrv			:= .T.
	Local cTpDoc		:= "1"
	Local cNota			:= ""
	Local cSerie		:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	Local nValor		:= 0
	Local cStatus		:= ""
	Local cMsgOphos		:= ""
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	Local i				:= 0
	Local x				:= 0
	//Local aDadReb		:= {}
	Local cValor		:= "0"
	Local cEmissTp		:= ""
	Local aRet			:= {}
	Local nPontEnt		:= 0
	Local cProtCan		:= ""
	Local nVlrOco		:= 0
	Local nVlrOcoT		:= 0
	Local nVlrPrc		:= 0
	Local cDtEmiss		:= ""
	Local nPorc			:= getPorEm(cTpVa) //GetMv("MV_#CTEPOR") //Everson - 12/12/2019 - Chamado 029058.
	//Local dData 		:= GetMv("MV_#DTGDOC",,Date())

	//
	Default cRetHash	:= ""
	Default lCmpDia		:= .F.

	//Obtém o hash.
	cHash := Alltrim(cValToChar(oXml:_retEnvio:_hash:Text))

	//
	If Empty(cHash)
		MsgStop("Não foi possível recuperar o hash do objeto xm.", "Função impAgrCTE(ADLOG057P)")
		logZBE("FUNCAO impAgrCTE: NAO RECUPEROU HASH DO OBJETO XML")
		RestArea(aArea)
		Return aRet

	EndIf
	
	//
	cRetHash := cHash
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - impAgrCTE - cNumRef " + cValToChar(cNumRef) )

	//Remove espaços em branco.
	cRotReg	  := cRoteiro
	cSeqCarga := cSeq
	Iif(cTipoEmiss == "01",cEmissTp := "C", cEmissTp := "N")

	//Verifica se realmente a carga não existe na base do sistema Protheus.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFK_ROTEIR + '-' + ZFK_SEQENV + '-' + ZFK_HASH  AS ZFK_HASH " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " AS ZFK " 
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL =    '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_HASH =  '" + cHash + "' "  
	cQuery += " AND ZFK_TPDOC = '1' " //CT-e 
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	
	//
	If Select("CTE_EMITIDO") > 0
		CTE_EMITIDO->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CTE_EMITIDO"
	DbSelectArea("CTE_EMITIDO")
		cDadosZFK := Alltrim(cValToChar(CTE_EMITIDO->ZFK_HASH))
	CTE_EMITIDO->(DbCloseArea())

	//Valida se não há o registro na tabela ZFK.
	If ! Empty(cDadosZFK)
		//MsgStop("Já há registro de CT-e para a carga " + cDadosZFK + ".", "Função impAgrCTE(ADLOG057P)")
		logZBE("FUNCAO impAgrCTE: JA HA REGISTRO NA TABELA ZFK PARA A CARGA/SEQUENCIA " + cDadosZFK + "-" + DToC(SToD(cDtEntr)))
		RestArea(aArea)
		Return aRet

	EndIf

	//Valida consulta ao BD.
	If Empty(cVeiculo)
		MsgStop("Não foi possível recuperar o veículo vinculado a carga " + cRotReg + "-" + DToC(SToD(cDtEntr)) + ".", "Função impAgrCTE(ADLOG057P)")
		logZBE("FUNCAO impAgrCTE: NAO FOI POSSIVEL RECUPERAR O VEICULO VINCULADO A CARGA " + cRotReg)
		RestArea(aArea)
		Return aRet

	EndIf

	//Recupera status do CT-e.
	aStatus := statusCTE(cHash)

	//Valida retorno da função statusCTE.
	If Len(aStatus) == 0
		MsgStop("Não foi possível obter status do CT-e referente à carga " + cRotReg +;
		" sequência " + cSeqCarga + Chr(13) + Chr(10) + ". Hash " + cHash + "", "Função impAgrCTE(ADLOG057P)")
		logZBE("FUNCAO impAgrCTE: NAO OBTEVE RETORNO DO WEB SERVICE REFERENTE AO HASH " + cHash + " CARGA " + cRotReg + "-" + DToC(SToD(cDtEntr)) )
		RestArea(aArea)
		Return aRet

	EndIf

	//Recupera status do CT-e.
	aStatus 	:= statusCTE(cHash)

	//Valida retorno da função statusCTE.
	If Len(aStatus) > 0
		
		//
		If Len(aStatus[1]) == 12
			cProtEmis	:= Alltrim(cValToChar(aStatus[1][3]))
			cChaveAces	:= Alltrim(cValToChar(aStatus[1][4]))
			cStatus		:= Alltrim(cValToChar(aStatus[1][1]))
			cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
			cNumDoc		:= Alltrim(cValToChar(aStatus[1][7]))
			cSerDoc		:= Alltrim(cValToChar(aStatus[1][8]))
			oXml		:= aStatus[1][6]
			cValor		:= Alltrim(cValToChar(aStatus[1][9]))
			cProtCan	:= Alltrim(cValToChar(aStatus[1][5]))
			cDtEmiss	:= Alltrim(cValToChar(aStatus[1][12]))
		
		EndIf
		
	EndIf

	//
	If Len(aNotas) == 0
		MsgStop("Consulta ao banco de dados não retornou nota fiscal referente à carga " + cRotReg + "-" + DToC(SToD(cDtEntr)) + ".", "Função impAgrCTE(ADLOG057P)")
		RestArea(aArea)
		Return aRet

	EndIf

	//Número de pontos de entrega.
	nPontEnt := Len(aNotas)

	//Itera sobre as notas.
	If ! lCmpDia
	
		//
		For i := 1 To Len(aNotas)
	
			//Recupera nota e série do roteiro.
			cNota := Alltrim(cValToChar(aNotas[i][2]))
			cSerie:= Alltrim(cValToChar(aNotas[i][1]))
			
			//Obtém o valor da nota fiscal.
			nValor := ajusteVlNF(Val(cValor),cRoteiro,cDtEntr,cSeq,nPontEnt,cNumDoc,cSerDoc)
			
			//
			//Everson - 04/09/2019. Chamado 044314.
			grvZFK(lGrv,cTpDoc,cRotReg,cSeqCarga,cTransp,cLoja,cVeiculo,cMotorista,cNota,cSerie,;
				   cHash,cNumDoc,cSerDoc,nValor,cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEntr,;
				   cEmissTp,cCodCrg,cProtCan,cCTECompl,cSCTECompl,cAgrupa,cDtEmiss,nPorc)
		
			//Verifica status para atribuir retorno para download do arquivo.			
			If cRetorno == "101" .Or. cRetorno == "503"
				
				//Adiciona dados ao array de retorno.
				Aadd(aRet,{cRotReg,cSeqCarga,cTpDoc,cNota,cSerie,cRetorno,cHash,cChaveAces,nValor,cNumDoc,cSerDoc,cDtEmiss})
	
			EndIf  
	
		Next i
	
	Else
		
		//
		nVlrOcoT := 0
		nValor   := Val(cValor)
		
		//
		For x := 1 To Len(aPorcOco)
			
			//
			cCodOcorr	:= aPorcOco[x][1]
			nVlrOco 	:= nValor * aPorcOco[x][3]
			cCodZFA		:= aPorcOco[x][4]
			
			//
			If x == Len(aPorcOco) .And. nVlrOcoT > 0
				nVlrOco := nValor - nVlrOcoT
				
			EndIf
			
			//
			For i := 1 To Len(aNotas)
		
				//Recupera nota e série do roteiro.
				cNota := Alltrim(cValToChar(aNotas[i][2]))
				cSerie:= Alltrim(cValToChar(aNotas[i][1]))
				
				//Obtém o valor da nota fiscal.
				nVlrPrc := ajusteVlNF(nVlrOco,cRoteiro,cDtEntr,cSeq,nPontEnt,cNumDoc,cSerDoc)
				
				//Everson - 04/09/2019. Chamado 044314.
				grvZFK(lGrv,cTpDoc,cRotReg,cSeqCarga,cTransp,cLoja,cVeiculo,cMotorista,cNota,cSerie,;
					   cHash,cNumDoc,cSerDoc,nVlrPrc,cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEntr,;
					   cEmissTp,cCodCrg,cProtCan,cCTECompl,cSCTECompl,cAgrupa,cDtEmiss,nPorc)
			
				//
				Aadd(aRet,{cRotReg,cSeqCarga,cTpDoc,cNota,cSerie,cRetorno,cHash,cChaveAces,nValor,cNumDoc,cSerDoc,cDtEmiss}) 
		
			Next i
			
			//
			nVlrOcoT += nVlrOco

		Next x	
	
	EndIf
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} retConsCTE  
	Tratamento de retorno do web service para consulta de CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/06/2019
	@version 01
	/*/
Static Function retConsCTE(oXml,cHash,lExibMsg)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet			:= .F.
	Local cRetorno		:= ""
	Local cMensagem		:= ""

	//Variáveis para os retornos 101 e 102. Autorizado/Cancelado.
	Local cAmbiente		:= ""
	Local cNumCte		:= ""
	Local cSerieCte		:= ""
	Local cDataEmis		:= ""
	Local cCFOP			:= ""
	Local cNatureza		:= ""
	Local cValor		:= ""
	Local cDataAut		:= ""
	Local cProtocol		:= ""
	Local cChaveAces	:= ""
	//Local aStatus		:= ""
	Local cStatus		:= ""
	Local cMsgOphos		:= ""
	Local cProtEmis		:= ""
	Local cProtCance	:= ""

	//Variáveis para o retorno 102. Cancelado.
	Local cDataCanc		:= ""
	Local cProtoCanc	:= ""
	Local cJustif		:= ""
	Local xDdAverb		:= Nil //Everson³01/07/19³044314.
	Local aRet			:= {}

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_retConsulta:_status:Text))

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_retConsulta:_mensagem:Text))

	//Recupera a mensagem da Ophos.
	cMsgOphos := cRetorno + "-" + cMensagem
	
	//
	If	cRetorno == "100" //Fila.

		//Número e série do CT-e.
		cNumCte		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_numero:Text))
		cSerieCte	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_serie:Text))

		//cAmbiente	:= Alltrim(cValToChar(oXml:_retConsulta:_ambiente:Text))
		cDataEmis	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_dataEmissao:Text))
		cCFOP		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_cfop:Text))
		cNatureza	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_natureza:Text))
		cValor		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_valor:Text))
		
		//
		If lExibMsg
			MsgInfo("Seguem abaixo dados de retorno do CT-e: No." + cNumCte + " Série " + cSerieCte + Chr(13) + Chr(10) +;
			"Ambiente de emissão: " + cAmbiente + Chr(13) + Chr(10) +;
			"Mensagem: " + cMensagem + Chr(13) + Chr(10) +;
			"Data de emissão: " + cDataEmis + Chr(13) + Chr(10) +;
			"CFOP: " + cCFOP + Chr(13) + Chr(10) +;
			"Natureza: " + cNatureza + Chr(13) + Chr(10) +;
			"Valor: R$" + Alltrim(cValToChar(Transform(Val(cValor),"@E 999,999.99"))) + Chr(13) + Chr(10) +;
			"Data de autorização: " + cDataAut + Chr(13) + Chr(10) +;
			"Protocolo: " + cProtocol + Chr(13) + Chr(10) +;
			"Chave de Acesso: " + cChaveAces,"Função retConsCTE(ADLOG057P)")
		
		EndIf
		
		lRet :=  .T.

	ElseIf	cRetorno == "101" //Autorizado.

		//Número e série do CT-e.
		cNumCte		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_numero:Text))
		cSerieCte	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_serie:Text))

		cAmbiente	:= Alltrim(cValToChar(oXml:_retConsulta:_ambiente:Text))
		cDataEmis	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_dataEmissao:Text))
		cCFOP		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_cfop:Text))
		cNatureza	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_natureza:Text))
		cValor		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_valor:Text))
		cDataAut	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_dataAutorizacao:Text))
		cProtocol	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_protocolo:Text))
		cChaveAces	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_chaveAcesso:Text))

		//
		If lExibMsg
			MsgInfo("Seguem abaixo dados de retorno do CT-e: No." + cNumCte + " Série " + cSerieCte + Chr(13) + Chr(10) +;
			"Ambiente de emissão: " + cAmbiente + Chr(13) + Chr(10) +;
			"Mensagem: " + cMensagem + Chr(13) + Chr(10) +;
			"Data de emissão: " + cDataEmis + Chr(13) + Chr(10) +;
			"CFOP: " + cCFOP + Chr(13) + Chr(10) +;
			"Natureza: " + cNatureza + Chr(13) + Chr(10) +;
			"Valor: R$" + Alltrim(cValToChar(Transform(Val(cValor),"@E 999,999.99"))) + Chr(13) + Chr(10) +;
			"Data de autorização: " + cDataAut + Chr(13) + Chr(10) +;
			"Protocolo: " + cProtocol + Chr(13) + Chr(10) +;
			"Chave de Acesso: " + cChaveAces,"Função retConsCTE(ADLOG057P)")

		EndIf
		
		//
		xDdAverb := XmlChildEx(oXml:_RETCONSULTA, "_DADOSAVERBACAO") //Everson³01/07/19³044314.
		lRet :=  .T.
		
	ElseIf cRetorno == "102" //Cancelado.

		//Número e série do CT-e.
		cNumCte		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_numero:Text))
		cSerieCte	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_serie:Text))
		//ticket 77749 - Antonio Domingos - 09/08/2022 - invalid property _AMBIENTE on RETCONSCTE(ADLOG057P.PRW) 
		If Type("oXml:_retConsulta:_ambiente:Text")<>"U"
			cAmbiente	:= Alltrim(cValToChar(oXml:_retConsulta:_ambiente:Text))
		EndIf
		cDataEmis	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_dataEmissao:Text))
		cCFOP		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_cfop:Text))
		cNatureza	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_natureza:Text))
		cValor		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCTe:_valor:Text))
		cDataAut	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_dataAutorizacao:Text))
		cProtocol	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_protocolo:Text))
		cChaveAces	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_chaveAcesso:Text))

		cDataCanc	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCancelamento:_dataCancelamento:Text))
		cProtoCanc	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCancelamento:_protocolo:Text))
		cJustif		:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCancelamento:_justificativa:Text))
		
		//
		If lExibMsg
			MsgAlert("Seguem abaixo dados de retorno do CT-e: No." + cNumCte + " Série " + cSerieCte + Chr(13) + Chr(10) +;
			"Ambiente de emissão: " + cAmbiente + Chr(13) + Chr(10) +;
			"Mensagem: " + cMensagem + Chr(13) + Chr(10) +;
			"Data de emissão: " + cDataEmis + Chr(13) + Chr(10) +;
			"CFOP: " + cCFOP + Chr(13) + Chr(10) +;
			"Natureza: " + cNatureza + Chr(13) + Chr(10) +;
			"Valor: R$" + Alltrim(cValToChar(Transform(Val(cValor),"@E 999,999.99"))) + Chr(13) + Chr(10) +;
			"Data de autorização: " + cDataAut + Chr(13) + Chr(10) +;
			"Protocolo: " + cProtocol + Chr(13) + Chr(10) +;
			"Chave de Acesso: " + cChaveAces + Chr(13) + Chr(10) +;
			"Data cancelamento: " + cDataCanc + Chr(13) + Chr(10) +;
			"Protocolo: " + cProtoCanc + cDataCanc + Chr(13) + Chr(10) +;
			"Justificativa: " + cJustif, "Função retConsCTE(ADLOG057P)")
		
		EndIf
		
		lRet :=  .T.

	Else //Demais status.
		
		//
		If lExibMsg
			MsgStop("Seguem abaixo dados de retorno do CT-e: No." + cNumCte + " Série " + cSerieCte + Chr(13) + Chr(10) +;
			"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
			"Mensagem: " + cMensagem + "." + Chr(13) + Chr(10) +;
			"Hash: " + cHash,"Função retConsCTE(ADLOG057P)")
		
		EndIf
		
		lRet := .F.

	EndIf

	//Executa função de status do CT-e.
	cStatus  	:= tlbStatus(cRetorno,2)//Alltrim(cValToChar(aStatus[1][1]))
	cMsgOphos	:= cRetorno + "-" + cMensagem//Alltrim(cValToChar(aStatus[1][2]))

	//Protocolo de emissão e chave de acesso.
	If cRetorno == "101" .Or. cRetorno == "102"
		cProtEmis	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_protocolo:Text))
		cChaveAces	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosAutorizacao:_chaveAcesso:Text))
		
	EndIf

	//Protocolo de cancelamento.
	If cRetorno == "102"
		cProtCance	:= Alltrim(cValToChar(oXml:_retConsulta:_dadosCancelamento:_protocolo:Text))
		
	EndIf
	
	//
	If ! Empty(cDataEmis)
		cDataEmis := Substr(cDataEmis,1,10)
		cDataEmis := StrTran(cDataEmis,"-","")
		
	EndIf

	//Monta script sql.
	Update := 	"UPDATE " + RetSqlName("ZFK") + " SET " + Iif(Empty(cDataAut),""," ZFK_DTEMIS = '" + cDataEmis + "', ") + " ZFK_STATUS = '" + cStatus + "', ZFK_OPHOS = '" + cMsgOphos + "', ZFK_PROTEM ='" +;
	cProtEmis + "', ZFK_PROTCA='" + cProtCance + "', ZFK_CHAVE='" + cChaveAces + "' WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") +  "' AND ZFK_HASH ='" + cHash + "'  AND ZFK_TPDOC ='1'"
	
	//Atualiza status do MDF-e.
	If TcSqlExec(Update) < 0
		
		//
		lRet := .F.
		MsgStop("Não foi possível atualizar o status do CTE-e " + cNumCte + "/" + cSerieCte + "." + Chr(13) + Chr(10) + "TCSQLError " + TCSQLError(),"Função retConsCTE(ADLOG057P)")
		logZBE("FUNCAO retConsCTE: NAO FOI POSSIVEL ATUALIZAR O STATUS DO CTE-E " + cNumCte + "/" + cSerieCte + " ERRO " + TCSQLError())
	
	Else
	
		//
		If ! Empty(cHash)
		
			//Everson³01/07/19³044314.
			If ValType(xDdAverb) <> "U" 
				ddAverb(xDdAverb,cHash)
				
			EndIf
			
			//
			If cRetorno == "101" .Or. cRetorno == "102"	
				Aadd(aRet,{,,,,,cRetorno,cHash,cChaveAces})
				
				//Salva arquivo xml.
				slvXML(aRet)
			
			EndIf
		
		EndIf
	
	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} ddAverb  
	Preenche dados da averbação das notas fiscais. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 01/07/2019
	@version 01
	/*/
Static Function ddAverb(xDdAverb,cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local nAux		:= 1
	Local cMsg		:= ""
	Local cStat		:= ""
	Local cNum		:= ""
	Local cTpD		:= ""
	Local cDoc		:= ""
	Local cProt		:= ""	
	Local cError	:= ""
	Local cApolice	:= ""

	//Everson - 12/02/2020. Chamado 054941.
	//cApolice := Alltrim(cValToChar(Static Call(NfeSefaz,getApolic,cTpVa)))
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	cApolice := Alltrim(cValToChar(u_ESEFAZA0(cTpVa)))
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - ddAverb - cApolice " + cApolice )
	If Empty(cApolice) .Or. cApolice == "0"
		RestArea(aArea)
		Return Nil
		
	EndIf
	//
	
	//
	bError := ErrorBlock( {|e| cError := e:Description } )
	Begin Sequence
	
		//
		If ValType(xDdAverb) == "A"
			
			//
			For nAux := 1 To Len(xDdAverb)
				
				//
				cStat:= Alltrim(cValToChar(xDdAverb[nAux]:_STATUS:TEXT))
				cMsg := Alltrim(cValToChar(xDdAverb[nAux]:_MENSAGEM:TEXT))
				
				//
				If cStat == "201"
				
					//
		            cNum := Alltrim(cValToChar(xDdAverb[nAux]:_NUMEROAVERBACAO:TEXT))
		            cTpD := Alltrim(cValToChar(xDdAverb[nAux]:_TIPODOCORIGEM:TEXT))
		            cDoc := Substr(cNum,26,12)
		            cProt:= Alltrim(cValToChar(xDdAverb[nAux]:_PROTOCOLO:TEXT))
		            	            
		            updAverb(cNum,cProt,cMsg,cStat,cTpD,cDoc,cHash)
		            
	            EndIf		
							
			Next nAux
		
		ElseIf ValType(xDdAverb) == "O"
			
			//
			cStat:= Alltrim(cValToChar(xDdAverb:_STATUS:TEXT))
			cMsg := Alltrim(cValToChar(xDdAverb:_MENSAGEM:TEXT))
						
			//
			If cStat == "201"
			
				//
	            cNum := Alltrim(cValToChar(xDdAverb:_NUMEROAVERBACAO:TEXT))
	            cTpD := Alltrim(cValToChar(xDdAverb:_TIPODOCORIGEM:TEXT))
	            cDoc := Substr(cNum,26,12)
	            cProt:= Alltrim(cValToChar(xDdAverb:_PROTOCOLO:TEXT))
	                       
	            updAverb(cNum,cProt,cMsg,cStat,cTpD,cDoc,cHash)
	            
	        EndIf
	            	
		EndIf

	Recover
		
		//
		ErrorBlock( bError )
		MsgStop( "Ocorreu erro na gravação da averbação da nota fiscal " + cDoc + "." + Chr(13) + Chr(10) +  cError,"Função ddAverb(ADLOG057P)")
		
	End Sequence
		
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} updAverb  
	Update com dados de averbação. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 28/06/2019
	@version 01
	/*/
Static Function updAverb(cNum,cProt,cMsg,cStat,cTpD,cDoc,cHash,cNumCte)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUpdate	:= ""

	//Monta script sql.
	cUpdate := " UPDATE " + RetSqlName("ZFK") + " "
	cUpdate += " SET ZFK_TPAVER = '" + cNum + "', ZFK_PRTAVE = '" + cProt + "', ZFK_MSGAVE = '" + cMsg + "', ZFK_STAAVE = '" + cStat + "', ZFK_TPDAVE = '" + cTpD + "' "
	cUpdate += " WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
	cUpdate += " AND RIGHT('000' + RTRIM(LTRIM(ZFK_SERIE)),3) + RTRIM(LTRIM(ZFK_NOTA)) = '" + cDoc + "' "
	cUpdate += " AND ZFK_HASH ='" + cHash + "'  AND ZFK_TPDOC ='1' AND D_E_L_E_T_ = '' AND D_E_L_E_T_ = '' "
	
	//Atualiza status do MDF-e.
	If TcSqlExec(cUpdate) < 0
		MsgStop("Não foi possível atualizar o status da averbação para nota fiscal." + cDoc + "." + Chr(13) + Chr(10) + "TCSQLError " + TCSQLError(),"Função ddAverb(ADLOG057P)")
		logZBE("FUNCAO retConsCTE: NAO FOI POSSIVEL ATUALIZAR O STATUS DA NFE " + cDoc + " ERRO " + TCSQLError())
	
	EndIf

	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} tabelaDoc  
	Tratamento de retorno do web service para consulta de CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/06/2019
	@version 01
	/*/
Static Function tabelaDoc(cTpDoc)

	//Variáveis.
	Local aArea	:= GetArea()
	Local cDoc	:= ""

	//Remove espaços em branco.
	cTpDoc	:= Alltrim(cValToChar(cTpDoc))
	
	//
	If cTpDoc == "1"
		cDoc := "CT-e"

	ElseIf	cTpDoc == "2"
		cDoc := "MDF-e"

	ElseIf	cTpDoc == "3"
		cDoc := "CIOT"

	EndIf
	
	//
	RestArea(aArea)

Return cDoc
/*/{Protheus.doc} updateCTE  
	Update em CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
Static Function updateCTE(cHash,cStatus,cMsgOphos,cProtEmis,cChaveAces,cProtCance)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUpdate	:= ""

	//Remove espaços em branco.
	cHash		:= Alltrim(cValToChar(cHash))
	cStatus		:= Alltrim(cValToChar(cStatus))
	cMsgOphos	:= Alltrim(cValToChar(cMsgOphos))
	cProtEmis	:= Alltrim(cValToChar(cProtEmis))
	cChaveAces	:= Alltrim(cValToChar(cChaveAces))
	cProtCance  := Alltrim(cValToChar(cProtCance))

	cUpdate := "UPDATE " + RetSqlName("ZFK") + " SET ZFK_STATUS = '" + cStatus + "' , ZFK_OPHOS = '" + cMsgOphos +;
	"', ZFK_PROTEM = '" + cProtEmis + "', ZFK_CHAVE = '" + cChaveAces + "' WHERE ZFK_HASH = '" + cHash + "' AND ZFK_TPDOC = '1' "

	If TCSQLExec(cUpdate) < 0
		MsgStop("Não foi possivel atualizar o registro de CT-e referente ao hash " + cHash, "Função updateCTE")
		logZBE("FUNCAO updateCTE: NAO ATUALIZOU REGISTRO DO CT-E HASH " + cHash)
		
	EndIf
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} grvZFK  
	Grava dados na tabela ZFK. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function grvZFK(lGrv,cTpDoc,cRoteiro,cSeq,cTransp,cLoja,cVeiculo,cMotorista,cNota,cSerie,cHash,cNumDoc,cSerDoc,nValor,;
					   cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEnt,cEmissTp,cCodCrg,cProtCan,cCTECompl,cSCTECompl,;
					   cTpEnvCTE,cDtEmiss,nPorc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cPedido	:= Alltrim(cValToChar(Posicione("SC5",15 ,FWxFilial("SC5") + cNota  , "C5_NUM"    )))
	Local cSeqEntr	:= Alltrim(cValToChar(Posicione("SC5",1  ,FWxFilial("SC5") + cPedido, "C5_SEQUENC")))
	Local cCliente	:= Alltrim(cValToChar(Posicione("SC5",1  ,FWxFilial("SC5") + cPedido, "C5_CLIENTE")))
	Local cLojaCli	:= Alltrim(cValToChar(Posicione("SC5",1  ,FWxFilial("SC5") + cPedido, "C5_LOJACLI")))
	Local cNomeCli	:= Alltrim(cValToChar(Posicione("SC5",1  ,FWxFilial("SC5") + cPedido, "C5_NOMECLI")))
	Local cTpPed	:= Alltrim(cValToChar(Posicione("SC5",1  ,FWxFilial("SC5") + cPedido, "C5_TIPO")))
	Local cEstCli	:= ""
	Local cMunicip	:= ""

	//Everson - 09/03/2020. Chamado 054941.
	If cTpPed == "B"
		cEstCli	:= Alltrim(cValToChar(Posicione("SA2",1  ,FWxFilial("SA2") + cCliente + cLojaCli, "A2_EST")))
		cMunicip:= Alltrim(cValToChar(Posicione("SA2",1  ,FWxFilial("SA2") + cCliente + cLojaCli, "A2_COD_MUN")))
	
	Else
		cEstCli	:= Alltrim(cValToChar(Posicione("SA1",1  ,FWxFilial("SA1") + cCliente + cLojaCli, "A1_EST")))
		cMunicip:= Alltrim(cValToChar(Posicione("SA1",1  ,FWxFilial("SA1") + cCliente + cLojaCli, "A1_COD_MUN")))

	EndIf

	Default cCTECompl 	:= ""
	Default cSCTECompl	:= ""
	Default cTpEnvCTE	:= ""
	
	//
	DbSelectArea("SM0")

	//
	RecLock("ZFK",lGrv)
		Replace ZFK_FILIAL		With FWxFilial("ZFK")
		Replace ZFK_COD			With GetSXEnum("ZFK","ZFK_COD")
		Replace ZFK_DATA		With Date() 
		Replace ZFK_HORA		With Alltrim(cValToChar(Time()))
		Replace ZFK_TPDOC		With cTpDoc
		Replace ZFK_CARGA		With cCodCrg
		Replace ZFK_DTENTR		With SToD(cDtEnt)
		Replace ZFK_ROTEIR		With cRoteiro
		Replace ZFK_SEQENV		With cSeq
		Replace ZFK_TRANSPO		With cTransp
		Replace ZFK_LOJA		With cLoja
		Replace ZFK_NMTRAN		With cNmT
		Replace ZFK_PLACA		With cVeiculo
		Replace ZFK_MOTORI		With cMotorista
		Replace ZFK_NOTA		With cNota
		Replace ZFK_SERIE		With cSerie
		Replace ZFK_HASH		With cHash
		Replace ZFK_NUMDOC		With Iif(cTpDoc == "3","",cNumDoc)
		Replace ZFK_SERDOC		With cSerDoc
		Replace ZFK_VALOR		With nValor
		Replace ZFK_STATUS		With Iif(Empty(cStatus),"X",cStatus)
		Replace ZFK_OPHOS		With cMsgOphos
		Replace ZFK_PROTEMI 	With cProtEmis
		Replace ZFK_CHAVE		With cChaveAces
		Replace ZFK_USUARIO		With Alltrim(cUserName)
		Replace ZFK_TMEMIS		With cEmissTp
		Replace ZFK_PROTCA		With cProtCan
		Replace ZFK_PLCCAV		With cPlcCv
		Replace ZFK_CTECOM		With cCTECompl
		Replace ZFK_SERCOM		With cSCTECompl
		Replace ZFK_TPENVC		With cTpEnvCTE
		Replace ZFK_PORCVL		With nPorc
		Replace ZFK_PEDVEN		With cPedido
		Replace ZFK_SEQENT		With cSeqEntr
		Replace ZFK_ENTRAD		With "1"				
		Replace ZFK_CLIENT		With cCliente
		Replace ZFK_LOJACL		With cLojaCli
		Replace ZFK_NMCLIE		With cNomeCli		
		Replace ZFK_ESTCLI		With cEstCli
		Replace ZFK_CODMUN		With cMunicip
		Replace ZFK_ESTORI		With SM0->M0_ESTCOB
		Replace ZFK_MUNORI		With Substr(Alltrim(cValToChar(SM0->M0_CODMUN)),3,10)
		Replace ZFK_ADIANT		With "1"
		Replace ZFK_CODZFA 		With cCodZFA
		Replace ZFK_TPCARG 		With cTpVa //Everson - 03/12/2019. Chamado 029058.
		Replace ZFK_NUMCIO		With Iif(cTpDoc == "3",cNumDoc,"") //Everson - 06/03/2020. Chamado 054941.
		
		//
		If ! Empty(cDtEmiss)
			Replace ZFK_DTEMIS	With SToD(cDtEmiss)
		
		EndIf
		
		//
		If cTpDoc == "1"
			Replace ZFK_OCORRE With cCodOcorr
			
		EndIf
		
	MsUnlock()
	
	//
	ConfirmSX8()
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} encerraMDF  
	Função para encerrar MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function encerraMDF(cHash,cDateTime,cIBGE)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUrl			:= GetMv("MV_#ENCMDF")
	Local cCabec    	:= obtCabec()
	Local cTemplate		:= ""
	Local oRestClient	:= Nil
	Local cErroWS		:= ""
	Local cRetPost		:= ""
	Local aCabec		:= {}

	//Retira espacos em branco.
	cHash		:= Alltrim(cValToChar(cHash))
	cDateTime	:= Alltrim(cValToChar(cDateTime))

	//Verifica se os argumentos estão em branco.
	If Empty(cHash)
		MsgStop("Função encerraMDF não recebeu o argumento hash.","Função encerraMDF(ADLOG057P)")
		logZBE("FUNCAO encerraMDF: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf	Empty(cDateTime)
		MsgStop("Função encerraMDF não recebeu o argumento cDateTime.","Função encerraMDF(ADLOG057P)")
		logZBE("FUNCAO encerraMDF: NAO RECEBEU O ARGUMENTO cDateTime")
		RestArea(aArea)
		Return .F.

	ElseIf	Empty(cIBGE)
		MsgStop("Função encerraMDF não recebeu o argumento cIBGE.","Função encerraMDF(ADLOG057P)")
		logZBE("FUNCAO encerraMDF: NAO RECEBEU O ARGUMENTO cIBGE")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("Função encerraMDF não obteve a URL para encerramento do MDF-e (MV MV_#ENCMDF).","Função encerraMDF(ADLOG057P)")
		logZBE("FUNCAO encerraMDF: NAO OBTEVE A URL PARA ENCERRAMENTO DO MDF-E MV MV_#ENCMDF")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Carrega template.
	cTemplate := Alltrim(cValToChar(xmlMDFEnce(cHash,cDateTime,cIBGE)))

	//
	If Empty(cTemplate)
		MsgStop("Função encerraMDF não carregou template.","Função encerraMDF(ADLOG057P)")
		logZBE("FUNCAO encerraMDF: NAO CARREGOU TEMPLANTE")
		RestArea(aArea)
		Return .F.
		
	EndIf

	cTemplate := cCabec + cTemplate

	//Salva xml de envio.
	gravarTXT(cTemplate, cHash + "Env_Encerrar_MDFE","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui path.
	oRestClient:setPath("")

	//Atribui parâmetros.
	oRestClient:SetPostParams(cTemplate)

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função encerraMDF(ADLOG057P)")
		logZBE("FUNCAO encerraMDF: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cTemplate)
		Final() //Everson - 22/01/2020. Chamado 054941.
		//RestArea(aArea)
		//Return .F.
		
	Endif

	//Salva retorno do web service.
	gravarTXT(cRetPost, cHash + "Ret_Encerrar_MDFE","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetPost)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de encerramento do MDF-e.
	obtRet(8,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} xmlMDFEnce  
	Função retorna template de encerramento do MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function xmlMDFEnce(cHash,cDateTime,cIBGE)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cTemplate	:= ""

	//Remove espaços em branco.
	cHash		:= Alltrim(cValToChar(cHash))
	cDateTime	:= Alltrim(cValToChar(cDateTime))
	cIBGE		:= Alltrim (cValToChar(cIBGE))
	
	//
	cTemplate := "<EnvEncerramentoMdfe>"
	cTemplate += "<hash>" + cHash + "</hash> "
	cTemplate += "<data>" + cDateTime + "</data> "
	cTemplate += "<nrIbge>" + cIBGE + "</nrIbge> "
	cTemplate += "</EnvEncerramentoMdfe> "
	
	//
	RestArea(aArea)
	
Return cTemplate
/*/{Protheus.doc} geraMDFE  
	Função para converter o CT-e para MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 11/06/2019
	@version 01
	/*/
Static Function geraMDFE(cRoteiro,cDtEntr,cSeq,lUpdate,lSelectCTE)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUrl      	:= Lower(Alltrim(GetMv("MV_#ENVMDF")))
	//Local cQuery		:= ""
	Local aTransp		:= {}
	Local aVeiculo		:= {}
	Local aPropVec		:= {}
	//Local aDadReb		:= {}
	Local aReboque		:= {}
	Local aPropReb		:= {}
	Local aMotorista	:= {}
	Local aNF			:= {}
	Local aCTE			:= {}
	Local cCabec    	:= obtCabec()
	Local cTemplate 	:= ""
	Local aCabec		:= {}
	Local oRestClient	:= Nil
	Local cRetPost		:= ""
	Local cErroWS		:= ""
	//Local i				:= 0
	//Local cHash			:= ""
	Local aRet			:= {}
	Local cTpcarga		:= ""
	Local nTipo			:= 1
	Local cTranCv		:= ""
	Local cLjCv			:= ""
	Local cNumRef		:= ""

	//Everson - 03/12/2019 - Chamado 029058.
	Private cCodCrg		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_CARGA")))
	Private cTransp		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_TRANPA")))
	Private cLoja		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_LJPPAG")))
	Private cVeiculo	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_VEICPG"))) 
	Private cNmT		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_NMTRAN")))
	Private cPlcCv		:= ""//Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_PLCCAV")))
	Private cMotorista	:= ""
	//
	
	Default lSelectCTE	:= .T.

	//Everson - 24/01/2020. Chamado 054941.
	If ! chkBloqueio(cCodZFA)
		RestArea(aArea)
		Return Nil

	EndIf

	//Recupera dados da transportadora.
	aTransp := ddTransp(cTransp,cLoja)
	If Len(aTransp) <= 0
		RestArea(aArea)
		Return .F.

	EndIf
	
	//Everson - 01/07/2019. Chamado 044314.
	//Recupera dados do veículo e reboque.
	If ! Empty(cPlcCv)
		
		//
		aVeiculo := ddVeiculo(cPlcCv)
		aReboque := ddVeiculo(cVeiculo)

		//
		cTranCv	 := Alltrim(aVeiculo[1][9])
		cLjCv	 := Alltrim(aVeiculo[1][10])

		//
		aPropVec := dadosProp(cTranCv,cLjCv)
		aPropReb := dadosProp(cTransp,cLoja)
		
	Else

		//
		aVeiculo := ddVeiculo(cVeiculo)
		aPropVec := dadosProp(cTransp,cLoja)
	
	EndIf

	//
	cMotorista := Alltrim(aVeiculo[1][11])
	If Empty(cMotorista)
		MsgStop("Não foi possível recuperar o código do motorista vinculado ao veículo " + cVeiculo + ".","Função geraMDFE(ADLOG057P)")
		logZBE("FUNCAO geraMDFE: NAO FOI POSSIVEL RECUPERAR O CODIGO DO MOTORISTA VINCULADO A CARGA " + cVeiculo)
		RestArea(aArea)
		Return .F.

	EndIf
	aMotorista := dadosMot(cMotorista)
	If Len(aMotorista) <= 0
		RestArea(aArea)
		Return .F.

	EndIf

	//
	aNF := obtNF(cRoteiro,cDtEntr)
	If Len(aNF) <= 0
		RestArea(aArea)
		Return .F.
		
	EndIf

	//
	aCTE := obtInfCTE(aNF,cRoteiro,cDtEntr,2,,lSelectCTE,cVeiculo)
	If Len(aCTE) <= 0
		RestArea(aArea)
		Return .F.

	EndIf

	//
	If Empty(cSeq)
		cSeq := seqZFK(cRoteiro,cDtEntr,"2")
	
	EndIf

	//
	Iif ( nTipo == 2 , cTpcarga := "AGR", cTpcarga := "NOR" )
	
	//
	cTemplate := MDFxmlTemp(aTransp,aVeiculo,aPropVec,aReboque,aPropReb,aMotorista,aCTE,cSeq,cRoteiro,cTpcarga,cDtEntr,@cNumRef)
	If Empty(Alltrim(cValToChar(cTemplate)))
		MsgStop("Não foi possível carregar o template xml para geração do MDF-e."," Função CTE_To_MDF.")
		logZBE("FUNCAO CTE_To_MDF: NAO CARREGOU O cTemplate")
		RestArea(aArea)
		Return .F.
	
	EndIf

	//Everson - 09/12/2019 - Chamado 029058.
	logZBE("Geração de MDF-e chave " + cNumRef + " " + cValToChar(cRoteiro) + " " + cValToChar(cDtEntr) + " " + cValToChar(cSeq) + " aCTE ",ArrTokStr(aCTE) )

	//Adiciona o cabeçalho ao arquivo xml.
	cTemplate := cCabec + cTemplate

	//Salva xml de envio.
	gravarTXT(cTemplate,cRoteiro + "_Env_MDFE","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui parâmetro post.
	oRestClient:SetPostParams(cTemplate)

	//Atribui path.
	oRestClient:setPath("")

	//Everson - 03/12/2019 - 029058.
	logZBE("Geração de MDF-e chave " + cNumRef + " " + cValToChar(cRoteiro) + " " + cValToChar(cDtEntr) + " " + cValToChar(cSeq),cTemplate )

	//Executa consulta web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno 200 ou 201.
		
	Else
		blqReg(cCodZFA) //Everson - 24/01/2020. Chamado 054941.
		cErroWS := oRestClient:GetLastError()//Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS)
		logZBE("FUNCAO enviarXML: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cTemplate)
		Final() //Everson - 22/01/2020. Chamado 054941.
		//RestArea(aArea)
		//Return .F.
	
	Endif

	//Salva retorno do web service.
	gravarTXT(cRetPost,cRoteiro + "_Ret_MDFE","xml",,.T.)

	//Gera objeto xml.
	aXml  := geraObjXML(cRetPost)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
	
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//
	aRet := obtRet(6,oXml,,,,cRoteiro,,,cSeq,Iif(nTipo == 2,.T.,.F.),,lUpdate,,cDtEntr)

	//Everson - 03/12/2019 - Chamado 029058.
	If ValType(aRet) <> "A" .Or. Len(aRet) <= 0
		RestArea(aArea)
		Return .F.

	EndIf

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} MDFxmlTemp  
	Função que retorna template xml para conversão do CT-e
	para MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/06/2019
	@version 01
	/*/
Static Function MDFxmlTemp(aTransp,aVeiculo,aPropVec,aReboque,aPropReb,;
						   aMotorista,aCTE,cSeq,cCodCarga,cTpcarga,cDtEntr,cNumRef)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cString   	:= ""
	Local i				:= 1
	Local cIeTransp		:= ""
	Local cCnpjTransp	:= ""
	Local cCnpjADORO	:= ""
	Local cIeProVec		:= ""
	Local cCnpjVec		:= ""
	Local cAnTTVec		:= ""
	Local cIeProRev		:= ""
	Local cCnpjReb		:= ""
	Local cAnTTReb		:= ""

	//Retira pontuação da inscrição estadual da transportadora.
	cIeTransp	:= Alltrim(cValToChar(aTransp[1][2]))
	cIeTransp	:= StrTran(cIeTransp,".","")
	cIeTransp	:= StrTran(cIeTransp,",","")
	cIeTransp	:= StrTran(cIeTransp,"/","")

	//Retira pontuação do CNPJ da transportadora.
	cCnpjTransp	:= Alltrim(cValToChar(aTransp[1][1]))
	cCnpjTransp	:= StrTran(cCnpjTransp,".","")
	cCnpjTransp	:= StrTran(cCnpjTransp,",","")
	cCnpjTransp	:= StrTran(cCnpjTransp,"/","")

	//Retira pontuação do CNPJ da Ad'oro.
	cCnpjADORO := Alltrim(cValToChar(aTransp[1][3]))
	cCnpjADORO := StrTran(cCnpjADORO,".","")
	cCnpjADORO := StrTran(cCnpjADORO,",","")
	cCnpjADORO := StrTran(cCnpjADORO,"/","")

	//Monta string do xml.
	//Informações do transportador.
	cString += "<converterCteMdfe>"
	cString += "<cnpjTransportador>" + cCnpjTransp + "</cnpjTransportador>"
	cString += "<ieTransportador>"   + Iif(Empty(cIeTransp),"ISENTO",cIeTransp) + "</ieTransportador>"
	cString += "<cnpjSolicitante>"   + cCnpjADORO + "</cnpjSolicitante>"

	//Everson - 06/11/2019 - Chamado 029058.
	cNumRef := gerRefMDF(cCodCarga,cDtEntr,cSeq,"N",cTpcarga)
	cString += "<nrReferencia>" + cNumRef + "</nrReferencia>"

	//Informações do veículo.
	cString += "<veiculo>"
	cString +=      "<placa>"           + Alltrim(cValToChar(aVeiculo[1][1])) + "</placa>"
	cString +=      "<tipoRodado>"      + Alltrim(cValToChar(aVeiculo[1][2])) + "</tipoRodado>"
	cString +=      "<tipoCarroceria>"  + Padl(Alltrim(cValToChar(aVeiculo[1][3])),2,"0") + "</tipoCarroceria>"
	cString +=      "<ufLicenciamento>" + Alltrim(cValToChar(aVeiculo[1][4])) + "</ufLicenciamento>"
	cString +=      "<tara>"            + Alltrim(cValToChar(aVeiculo[1][5])) + "</tara>"
	cString +=      "<capacidadeM3>"    + Alltrim(cValToChar(aVeiculo[1][6])) + "</capacidadeM3>"
	cString +=      "<capacidadeKG>"    + Alltrim(cValToChar(aVeiculo[1][7])) + "</capacidadeKG>"
	cString +=      "<nrInterno>"       + Alltrim(cValToChar(aVeiculo[1][8])) + "</nrInterno>"

	//Somente preenchido se o proprietário não for o emitente do MDF-e.
	If Alltrim(cValToChar(aTransp[1][1])) <> Alltrim(cValToChar(aPropVec[1][1]))

		cIeProVec := Alltrim(cValToChar(aPropVec[1][2]))
		cIeProVec	:= StrTran(cIeProVec,".","")
		cIeProVec	:= StrTran(cIeProVec,",","")
		cIeProVec	:= StrTran(cIeProVec,"/","")

		cCnpjVec	:= Alltrim(cValToChar(aPropVec[1][1]))
		cCnpjVec	:= StrTran(cCnpjVec,".","")
		cCnpjVec	:= StrTran(cCnpjVec,",","")
		cCnpjVec	:= StrTran(cCnpjVec,"/","")

		cAnTTVec	:= Alltrim(cValToChar(aPropVec[1][4]))
		cAnTTVec	:= StrTran(cAnTTVec,".","")
		cAnTTVec	:= StrTran(cAnTTVec,",","")
		cAnTTVec	:= StrTran(cAnTTVec,"/","")

		cString +=      "<proprietarioVeiculo>"
		cString +=          "<cnpjCpf>" + cCnpjVec + "</cnpjCpf>
		cString +=          "<ie>" + cIeProVec + "</ie>"
		cString +=          "<nome>" + Alltrim(cValToChar(aPropVec[1][3])) + "</nome>"
		cString +=          "<nrRNTRC>" + cAnTTVec + "</nrRNTRC>"
		cString +=          "<ufProprietario>" + Alltrim(cValToChar(aPropVec[1][5])) + "</ufProprietario>"
		cString +=          "<tipoProprietario>" + Alltrim(cValToChar(aPropVec[1][6])) + "</tipoProprietario>"
		cString +=      "</proprietarioVeiculo>"

	EndIf

	cString += "</veiculo>"

	//Informações do reboque (somente preenchido se houver reboque vinculado ao veículo).
	If Len(aReboque) > 0 .And. Len(aPropReb) > 0

		cString += "<reboque>"
		cString +=      "<placa>" + Alltrim(cValToChar(aReboque[1][1])) + "</placa>"
		cString +=      "<tipoRodado>" + Alltrim(cValToChar(aReboque[1][2])) + "</tipoRodado>"
		cString +=      "<tipoCarroceria>" + Alltrim(cValToChar(aReboque[1][3])) + "</tipoCarroceria>"
		cString +=      "<ufLicenciamento>" + Alltrim(cValToChar(aReboque[1][4])) + "</ufLicenciamento>"
		cString +=      "<tara>" + Alltrim(cValToChar(aReboque[1][5])) + "</tara>"
		cString +=      "<capacidadeM3>" + Alltrim(cValToChar(aReboque[1][6])) + "</capacidadeM3>"
		cString +=      "<capacidadeKG>" + Alltrim(cValToChar(aReboque[1][7])) + "</capacidadeKG>"
		cString +=      "<nrInterno>" + Alltrim(cValToChar(aReboque[1][8])) + "</nrInterno>"

		//Somente preenchido se o proprietário não for o emitente do MDF-e.
		If Alltrim(cValToChar(aPropReb[1][1])) <> Alltrim(cValToChar(aTransp[1][1]))

			//Retira pontuação da inscrição estadual do proprietário do reboque.
			cIeProRev 	:= Alltrim(cValToChar(aPropReb[1][2]))
			cIeProRev	:= StrTran(cIeProRev,".","")
			cIeProRev	:= StrTran(cIeProRev,",","")
			cIeProRev	:= StrTran(cIeProRev,"/","")

			//Retira pontuação do CNPJ do proprietário do reboque.
			cCnpjReb	:= Alltrim(cValToChar(aPropReb[1][1]))
			cCnpjReb	:= StrTran(cCnpjReb,".","")
			cCnpjReb	:= StrTran(cCnpjReb,",","")
			cCnpjReb	:= StrTran(cCnpjReb,"/","")

			//Retira pontuação do ANTT do proprietário do reboque.
			cAnTTReb	:= Alltrim(cValToChar(aPropReb[1][4]))
			cAnTTReb	:= StrTran(cAnTTReb,".","")
			cAnTTReb	:= StrTran(cAnTTReb,",","")
			cAnTTReb	:= StrTran(cAnTTReb,"/","")			

			cString +=      "<proprietarioVeiculo>"
			cString +=          "<cnpjCpf>" + cCnpjReb + "</cnpjCpf>"
			cString +=          "<ie>" + cIeProRev + "</ie>"
			cString +=          "<nome>" + Alltrim(cValToChar(aPropReb[1][3])) + "</nome>"
			cString +=          "<nrRNTRC>" + cAnTTReb + "</nrRNTRC>"
			cString +=          "<ufProprietario>" + Alltrim(cValToChar(aPropReb[1][5])) + "</ufProprietario>"
			cString +=          "<tipoProprietario>" + Alltrim(cValToChar(aPropReb[1][6])) + "</tipoProprietario>"
			cString +=      "</proprietarioVeiculo>"

		EndIf

		cString += "</reboque>"

	EndIf

	//Informações do motorista.
	cString += "<motorista>"
	cString +=      "<cpf>" + Alltrim(cValToChar(aMotorista[1][2])) + "</cpf>"
	cString +=      "<nome>" + Alltrim(cValToChar(aMotorista[1][1])) + "</nome>"
	cString += "</motorista>"

	//Adiciona tags dos documentos.
	For i := 1 To Len(aCTE)
		cString += "<documento>"
		cString +=      "<nrChaveAcesso>" + Alltrim(cValToChar(aCTE[i][5])) + "</nrChaveAcesso>"
		cString += "</documento>"

	Next i

	cString += "</converterCteMdfe>"

	//
	RestArea(aArea)

Return cString
/*/{Protheus.doc} gerRefMDF  
	Monta número sequencial de envio. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 06/11/2019
	@version 01
	/*/
Static Function gerRefMDF(cRoteiro,cDtEntr,cSeq,cEmissTp,cTpcarga)

	//Variáveis.
	Local aArea := GetArea()
	Local cRef  := ""
	Local dData := GetMv("MV_#DTGDOC",,Date())

	//
	If dData <= SToD(cDtEntr)
		//cRef := Alltrim(cValToChar(cRoteiro)) + "-" + Alltrim(cValToChar(cDtEntr)) + "-" + Alltrim(cValToChar(cSeq)) + "-" + cEmissTp + "-" + cTpcarga
		cRef := Alltrim(cEmpAnt) + Alltrim(cFilAnt) + Alltrim(cCodZFA)  + Alltrim(cEmissTp) + "-2-" + Alltrim(cSeq) + "-" + Alltrim(cTpVa)

	Else
		cRef := Alltrim(cValToChar(cRoteiro)) + "-" + Alltrim(cValToChar(cDtEntr)) + "-" + Alltrim(cValToChar(cSeq)) + "-" + cEmissTp + "-" + cTpcarga

	EndIf

	//
	RestArea(aArea)

Return cRef
/*/{Protheus.doc} ddVeiculo  
	Função retorna dados do veículo. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 11/06/2019
	@version 01
	/*/
Static Function ddVeiculo(cVeic,nOpc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local cQuery	:= ""
	Local cTipoRod	:= ""
	Local aTabVeic	:= Separa(Alltrim(GetMv("MV_#TABVEC",,"ZV4/ZV4/ZV4/ZV4/ZV4")),"/",.T.)
	Local cTabVeic	:= aTabVeic[Val(cTpVa)]
	Local cCodIbge	:= ""

	Default nOpc	:= 1 //Everson - 02/03/2020. Chamado 053926.

	//Valida argumentos da função.
	If Empty(cVeic)
		MsgStop("Função ddVeiculo não recebeu o argumento cVeic.","Função ddVeiculo(ADLOG057P)")
		logZBE("FUNCAO cVeic: NAO RECEBEU O ARGUMENTO cVeic")
		RestArea(aArea)
		Return aRetorno
		
	EndIf
	
	//Everson - 03/12/2019 - chamado 029058.
	If cTabVeic == "ZV4"
		cQuery := ""
		cQuery += " SELECT ZV4_PLACA AS PLACA, ZV4_TPCARR AS TPCARR, ZV4_EST AS EST, ZV4_PESO AS PESO, "
		cQuery += " ZV4_CAPM3 AS CAPM3, ZV4_CAPACI AS CAPACI, ZV4_TIPVEI AS TIPVEI, ZV4_FORNEC AS FORNEC, ZV4_LOJFOR AS LOJFOR, ZV4_CPF AS MOTORISTA, " 
		cQuery += " ZV4_ANO AS ANO_F, ZV4_CHASSI AS CHASSI, ZV4_COR AS COR, ZV4_MARCA AS MARCA, ZV4_MODELO AS MODELO, ZV4_RENAV AS RENAV, " 
		cQuery += " ZV4_ANOM AS ANO_M, ZV4_CODCID AS COD_CID, ZV7_QTEIXO AS NR_EIXO "
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZV4") + " (NOLOCK) AS ZV4 " 

		//
		cQuery += " LEFT OUTER JOIN "
		cQuery += " " + RetSqlName("ZV7") + " (NOLOCK) AS ZV7 ON "
		cQuery += " ZV4_TIPVEI = ZV7_TIPVEI "

		cQuery += " WHERE " 
		cQuery += " ZV4_FILIAL = '" + FWxFilial("ZV4") + "' " 
		cQuery += " AND ZV4_PLACA = '" + cVeic + "' " 
		cQuery += " AND ZV4.D_E_L_E_T_ = '' " 
		cQuery += " AND ZV7.D_E_L_E_T_ = '' "

	Else
		

	EndIf

	//Verifica se alias existe.
	If Select("VEICULO") > 0
		VEICULO->(DbCloseArea())
		
	EndIf

	//Executa consulta no BD.
	TcQuery cQuery New Alias "VEICULO"
	DbSelectArea("VEICULO")
	VEICULO->(DbGoTop())

	//Tipo de rodado de acordo com o sistema Ophos.
	cTipoRod := tipoRodado(VEICULO->TIPVEI,nOpc)

	//Valida retorno da função tipoRodado.
	If Empty(cTipoRod)	
		RestArea(aArea)
		Return aRetorno
		
	EndIf

	//
	cCodIbge := codIBGEEst(Alltrim(cValToChar(VEICULO->EST)),"","")
	cCodIbge := cCodIbge + Alltrim(cValToChar(VEICULO->COD_CID))

	//Adiciona valores ao array de retorno.
	Aadd(aRetorno,{;
		VEICULO->PLACA ,; 	 //1-Placa do veículo.
		cTipoRod,;		   	 //2-Tipo rodado (Toco, 3/4, etc...).
		VEICULO->TPCARR,;    //3-Tipo de carroceria.
		VEICULO->EST   ,;	 //4-UF da licenciamento.
		VEICULO->PESO  ,;	 //5-Tara do veículo.
		VEICULO->CAPM3,;	 //6-Capacidade M3.
		VEICULO->CAPACI ,;	 //7-Capacidade Kg.
		VEICULO->PLACA,;	 //8-Número interno.
		VEICULO->FORNEC,;	 //9-Código transportadora.
		VEICULO->LOJFOR,;	 //10-Loja transportadora.
		VEICULO->MOTORISTA,; //11-Motorista.
		VEICULO->ANO_F,;	 //12-Ano de fabricação.
		VEICULO->ANO_M	,;	 //13-Ano modelo.
		VEICULO->CHASSI,;    //14-Chassi.
		cCodIbge,;			 //15-Código IBGE.
		VEICULO->COR,;       //16-Cor.
		VEICULO->MARCA ,;    //17-Marca.
		VEICULO->MODELO,;    //18-Modelo.
		cValToChar(VEICULO->NR_EIXO) ,;//19-Qtd. de eixos.
		VEICULO->RENAV;      //20-Renavam.
	})

	VEICULO->(DbCloseArea())

	//Valida retorno de consulta ao BD.
	If Empty(aRetorno)
		MsgStop("Funçao ddVeiculo não obteve resultados na consulta ao BD referente a veículo " + cVeic + ".","Função ddVeiculo(ADLOG057P)")
		logZBE("FUNCAO ddVeiculo: NAO OBTEVE RESULTADO NA CONSULTA AO BD REFERENTE A TRANSPORTADORA VINCULADA AO VEICULO " + cVeic )
		RestArea(aArea)
		Return aRetorno
		
	EndIf
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} tipoRodado  
	Função que retorna o tipo de rodado de acordo com a tabela
	do sistema Ophos. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/06/2019
	@version 01
	/*/
Static Function tipoRodado(cTipo,nOpc)

	//Variáveis.
	Local aArea	:= GetArea()
	Local cRet	:= ""

	Default nOpc := 1

	//Remove espaços em branco.
	cTipo := Alltrim(cValToChar(cTipo))

	//Valida argumento da função.
	If Empty(cTipo)
		MsgAlert("Função tipoRodado não recebeu o argumento cTipo.","Função tipoRodado(ADLOG057P)")
		logZBE("FUNCAO tipoRodado: NAO RECEBEU O ARGUMENTO cTipo")
		RestArea(aArea)
		Return cRet
		
	EndIf
	
	//Everson - 02/03/2020. Chamado 053926.
	If nOpc == 1

		//
		If	cTipo == "TK" 		//Truck.
			cRet := "01"

		ElseIf	cTipo == "TC"	//Toco.
			cRet := "02"

		ElseIf	cTipo == "UT" 	//Utilitário.
			cRet := "05"

		Else					//Outros.
			cRet := "06"

		EndIf

	Else
		
		//Everson - 02/03/2020. Chamado 053926.
		If	cTipo == "TK" 		//Truck.
			cRet := "1"

		ElseIf	cTipo == "TC"	//Toco.
			cRet := "2"

		ElseIf	cTipo == "CV" 	//Utilitário.
			cRet := "3"

		Else					//Outros.
			cRet := "0"

		EndIf

	EndIf 

	//
	RestArea(aArea)

Return cRet
/*/{Protheus.doc} dadosProp  
	Função retorna dados do proprietário do veículo. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/06/2019
	@version 01
	/*/
Static Function dadosProp(cCodTrp,cLojaTrp)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aRetorno	:= {}
	Local cQuery	:= ""
	Local cNumEnd	:= ""
	Local cTelef 	:= ""
	Local cCodIbge	:= ""
	Local nPosV		:= 0
	Local cEnd 		:= ""

	//Remove espaços em branco.
	cCodTrp := Alltrim(cValToChar(cCodTrp))
	cLojaTrp:= Alltrim(cValToChar(cLojaTrp))

	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " A4_CGC, A4_INSEST, A4_NOME, A4_XRNTRC, A4_EST, A4_XTPPROP,  " 
	cQuery += " A4_CEP, A4_END, A4_BAIRRO, A2_DDD, A4_TEL, " 
	cQuery += " RTRIM(LTRIM(A2_BANCO)) AS A2_BANCO, RTRIM(LTRIM(A2_AGENCIA)) AS A2_AGENCIA, "
	cQuery += " RTRIM(LTRIM(A2_NUMCON)) AS A2_NUMCON, RTRIM(LTRIM(A2_COD_MUN)) AS A2_COD_MUN, "
	cQuery += " RTRIM(LTRIM(A2_DIGCTA)) AS A2_DIGCTA, RTRIM(LTRIM(A2_DIGAG)) AS A2_DIGAG " 
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("SA4") + " (NOLOCK) AS SA4 " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SA2") + " (NOLOCK) AS SA2 ON " 
	cQuery += " A4_COD =  A2_COD " 
	cQuery += " AND A4_LOJTRA = A2_LOJA  " 
	cQuery += " WHERE  " 
	cQuery += " A4_COD    = '" + cCodTrp + "'  " 
	cQuery += " AND A4_LOJTRA = '" + cLojaTrp + "' " 
	cQuery += " AND SA4.D_E_L_E_T_ = ''  " 
	cQuery += " AND SA2.D_E_L_E_T_ = ''  " 

	//Verifica se alias existe.
	If Select("PROPDADOS") > 0
		PROPDADOS->(DbCloseArea())

	EndIf

	//Executa consulta no BD.
	TcQuery cQuery New Alias "PROPDADOS"
	DbSelectArea("PROPDADOS")

	//
	cEnd    := Alltrim(cValToChar(PROPDADOS->A4_END))
	nPosV	:= At(",",cEnd)

	//
	If nPosV > 0

		//
		cNumEnd := StrTran(StrTran(Substr(cEnd,nPosV+1,5),"Nº",""),"N","")
		cEnd   	:= Substr(cEnd,1,nPosV-1)

	EndIf

	//
	cTelef	 := Right(StrTran(StrTran(StrTran(Alltrim(cValToChar(PROPDADOS->A4_TEL)),"-",""),".","")," ",""),10)
	cCodIbge := codIBGEEst(Alltrim(cValToChar(PROPDADOS->A4_EST)),"","")
	cCodIbge := cCodIbge + Alltrim(cValToChar(PROPDADOS->A2_COD_MUN))

	//Adiciona valores ao array de retorno.
	Aadd(aRetorno,{;
		PROPDADOS->A4_CGC,;		//1-CNPJ da empresa.
		StrTran(StrTran(StrTran(Alltrim(PROPDADOS->A4_INSEST),".",""),"-",""),"/",""),;	//2-Inscrição estadual.
		PROPDADOS->A4_NOME,;	//3-Nome do transportador.
		PROPDADOS->A4_XRNTRC,;	//4-Registro ANTT.
		PROPDADOS->A4_EST,;		//5-UF.
		PROPDADOS->A4_XTPPROP,; //6-Tipo transportador.
		PROPDADOS->A4_CEP    ,;	//7-CEP.
		cCodIbge			 ,; //8-IBGE.
		cEnd			     ,;	//9-Logradouro.
		cNumEnd 		     ,;	//10-Número.
		PROPDADOS->A4_BAIRRO ,;	//11-Bairro.
		"" 					 ,;	//12-Complemento.
		cTelef          	 ,; //13-Telefone.
		""					 ,; //14-Celular.
		StrTran(PROPDADOS->A2_BANCO," " ,"")	 ,; //15-Código Banco.
		StrTran(PROPDADOS->A2_AGENCIA + Iif(!Empty(PROPDADOS->A2_DIGAG),  "-" + PROPDADOS->A2_DIGAG , "")," " ,""),; //16-Agência.
		StrTran(PROPDADOS->A2_NUMCON  + Iif(!Empty(PROPDADOS->A2_DIGCTA), "-" + PROPDADOS->A2_DIGCTA, "")," " ,"")  ;//17-Número da conta.
		})	

	PROPDADOS->(DbCloseArea())

	//Valida retorno.
	If Len(aRetorno) == 0
		MsgStop("Função dadosProp não obteve retorno da consulta ao BD referente ao fornecedor " + cCodFor + "/" + cLoja + ".","Função dadosProp(ADLOG057P)")
		logZBE("FUNCAO dadosProp: NAO OBTEVE RETORNO DO BD REFERENTE AO FORNECEDOR " + cCodFor + "/" + cLoja)
		
	EndIf
	
	//
	RestArea(aArea)
	
Return aRetorno
/*/{Protheus.doc} dadosMot  
	Função que retorna dados do motorista. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 12/06/2019
	@version 01
	/*/
Static Function dadosMot(cCodMot)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cNome		:= ""
	Local aRetorno	:= {}
	Local cCNH		:= ""
	Local cDTNasc	:= ""
	Local cCodIbge	:= ""
	Local cLograd	:= ""
	Local cNumero	:= ""
	Local cBairro	:= ""
	Local cComplem	:= ""
	Local cCEP		:= ""
	Local cCelular	:= ""
	Local cTelFixo	:= ""
	Local nPosV		:= 0

	//Remove espaços em branco.
	cCodMot	:= Alltrim(cValToChar(cCodMot))

	//
	If Empty(cCodMot)
		MsgStop("Função não recebeu o código do motorista " + cCodMot + ".","Função dadosMot(ADLOG057P)")
		logZBE("FUNCAO dadosMot: FUNCAO NAO RECEBEU O CODIGO DO MOTORISTA " + cCodMot)
		RestArea(aArea)
		Return aRetorno

	EndIf

	//
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ZVC_CPF, " 
	cQuery += " ZVC_MOTORI, " 
	cQuery += " ZVC_DTNASC, " 
	cQuery += " ZVC_CNH, " 
	cQuery += " ZVC_ENDER, " 
	cQuery += " ZVC_BAIRRO, " 
	cQuery += " ZVC_ESTRES, " 
	cQuery += " ZVC_CEP, " 
	cQuery += " ZVC_TELPRI, "
	cQuery += " ZVC_TELEFS, "
	cQuery += " ZVC_CODMUN "
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZVC") + " (NOLOCK) AS ZVC " 
	cQuery += " WHERE " 
	cQuery += " ZVC_FILIAL = '" + FWxFilial("ZVC") + "' " 
	cQuery += " AND ZVC_CPF = '" + cCodMot + "' " 
	cQuery += " AND ZVC.D_E_L_E_T_ = '' "

	//
	If Select("D_MOTORI") > 0
		D_MOTORI->(DbCloseArea())

	EndIf 

	//
	TcQuery cQuery New Alias "D_MOTORI"
	DbSelectArea("D_MOTORI")
	D_MOTORI->(DbGoTop())

		//
		If D_MOTORI->(Eof())
			MsgStop("Cadastro de motorista não localizado " + cCodMot + ".","Função dadosMot(ADLOG057P)")
			logZBE("FUNCAO dadosMot: CADASTRO DE MOTORISTA NAO LOCALIZADO " + cCodMot)
			D_MOTORI->(DbCloseArea())
			RestArea(aArea)
			Return aRetorno

		EndIf

		//
		cNome 	:= Alltrim(cValToChar(D_MOTORI->ZVC_MOTORI))
		cCNH  	:= Alltrim(cValToChar(D_MOTORI->ZVC_CNH))	
		cDTNasc	:= Alltrim(cValToChar(D_MOTORI->ZVC_DTNASC))
		cDTNasc := Substr(cDTNasc,7,2) + "/" + Substr(cDTNasc,5,2) + "/" + Substr(cDTNasc,1,4)

		//
		cLograd	:= Alltrim(cValToChar(D_MOTORI->ZVC_ENDER))
		nPosV	:= At(",",cLograd)

		//
		If nPosV > 0

			//
			cNumero := StrTran(StrTran(Substr(cLograd,nPosV+1,5),"Nº",""),"N","")
			cLograd := Substr(cLograd,1,nPosV-1)

		EndIf

		//
		cBairro		:= Alltrim(cValToChar(D_MOTORI->ZVC_BAIRRO))
		cCodIbge 	:= codIBGEEst(Alltrim(cValToChar(D_MOTORI->ZVC_ESTRES)),"","")
		cCodIbge 	:= cCodIbge + Alltrim(cValToChar(D_MOTORI->ZVC_CODMUN))
		cCEP		:= Alltrim(cValToChar(D_MOTORI->ZVC_CEP))
		cCelular	:= StrTran(StrTran(Alltrim(cValToChar(D_MOTORI->ZVC_TELPRI)),"-","")," ","")
		cCelular	:= Right(cCelular,11)
		cTelFixo	:= StrTran(StrTran(Alltrim(cValToChar(D_MOTORI->ZVC_TELEFS)),"-","")," ","")
		cTelFixo	:= Right(cTelFixo,10)

	D_MOTORI->(DbCloseArea())

	//Preenche array.
	Aadd(aRetorno,{cNome,cCodMot,cCNH,cDTNasc,cCodIbge,cLograd,cNumero,cBairro,cComplem,cCEP,cCelular,cTelFixo})
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} cancMDF  
	Função para cancelar MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function cancMDF(cHash,cJust)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet          := .T.
	Local cUrl   		:= GetMv("MV_#CANMDF")
	Local cTemplate		:= ""
	Local cCabec    	:= obtCabec()
	Local oRestClient	:= Nil
	Local aCabec		:= {}
	Local cRetPost		:= ""
	Local cErroWS		:= ""

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl  	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("A função cancMDF não recebeu o argumento cHash.","Função cancMDF(ADLOG057P)")
		logZBE("FUNCAO cancMDF: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cJust)
		MsgStop("A função cancMDF não recebeu o argumento cJust.","Função cancMDF(ADLOG057P)")
		logZBE("FUNCAO cancMDF: NAO RECEBEU O ARGUMENTO cJust")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("A função cancMDF não obteve a URL para cancelamento do MDF-e (MV MV_#CANMDF).","Função cancMDF(ADLOG057P)")
		logZBE("FUNCAO cancMDF: NAO OBTEVE A URL PARA CANCELAMENTO DO MDF-E MV MV_#CANMDF")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Carrega template.
	cTemplate :=  Alltrim(cValToChar(xmlMDFCanc(cHash,cJust)))
	
	//
	If Empty(cTemplate)
		MsgStop("Função cancMDF não carregou template.","Função cancMDF(ADLOG057P)")
		logZBE("FUNCAO cancMDF: NAO CARREGOU TEMPLANTE")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	cTemplate := cCabec + cTemplate

	//Salva xml de envio.
	gravarTXT(cTemplate, cHash + "Env_Cancelar_MDFE","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui path.
	oRestClient:setPath("")

	//Atribui parâmetros.
	oRestClient:SetPostParams(cTemplate)

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função cancMDF(ADLOG057P)")
		logZBE("FUNCAO cancMDF: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cTemplate)
		Final() //Everson - 22/01/2020. Chamado 054941.
		//RestArea(aArea)
		//Return .F.
		
	Endif

	//Salva retorno do web service.
	gravarTXT(cRetPost, cHash + "Ret_Cancelamento_MDFE","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetPost)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de cancelamento do MDF-e.
	lRet := obtRet(9,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} xmlMDFCanc  
	Função retorna template de cancelamento do MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function xmlMDFCanc(cHash,cJustif)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cTemplate	:= ""

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cJustif	:= Alltrim(cValToChar(cJustif))

	cTemplate := "<EnvCancelamentoMdfe>"
	cTemplate += "<hash>" + cHash + "</hash>"
	cTemplate += "<justificativa>" + cJustif + "</justificativa>"
	cTemplate += "</EnvCancelamentoMdfe>"
	
	//
	RestArea(aArea)

Return cTemplate
/*/{Protheus.doc} retEncMDFE  
	Função de tratamento do retorno do web service para
	encerramento de MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function retEncMDFE(oXml,cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local cRetorno	:= ""
	Local cMensagem	:= ""
	Local cRet		:= ""
	Local cXml		:= ""
	Local nPosDados	:= 0
	Local cNumDoc	:= ""
	Local cSerDoc	:= ""

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_RetEncerramento:_status:Text))

	//Transforma objeto XML em string XML.
	SAVE oXml XMLSTRING cXml

	//Verifica se há o retorno com dados do CT-e.
	nPosDados := At("<numero>",cXml)
	If nPosDados > 0
		cNumDoc := Alltrim(cValToChar(oXml:_RetEncerramento:_dadosMDFe:_numero:Text))
		cSerDoc := Alltrim(cValToChar(oXml:_RetEncerramento:_dadosMDFe:_serie:Text))

	EndIf
	
	//
	If 	cRetorno == "107" // Encerrado.
		cMensagem:= Alltrim(cValToChar(oXml:_RetEncerramento:_dadosEncerramento:_mensagem:Text))
		MsgInfo("Encerramento MDF-e." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem  + Chr(13) + Chr(10) +;
		"Número MDF-e: " + cNumDoc  + Chr(13) + Chr(10) +;
		"Série: " + cSerDoc,"Função retEncMDFE(ADLOG057P)")

		cRet :=  .T.

	Else //Demais status.
		cMensagem:= Alltrim(cValToChar(oXml:_RetEncerramento:_mensagem:Text))
		MsgStop("Encerramento MDF-e." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem  + Chr(13) + Chr(10) +;
		"Número MDF-e: " + cNumDoc  + Chr(13) + Chr(10) +;
		"Série: " + cSerDoc,"Função retEncMDFE(ADLOG057P)")

		cRet :=  .F.

	EndIf

	//Flaga registros como terminados.
	If cRet
		lRet := encerraDoc(cHash,"2",oXml)
		
	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} encerraDoc  
	Função para marcar os registros de MDF-e como encerrados. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function encerraDoc(cHash,cTpDoc,oXml)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUpdate 		:= ""
	Local cErroUp 		:= ""
	//Local cMensagem		:= ""
	Local cMsgOphos		:= ""
	Local aStatus		:= {}
	Local cStatus		:= ""
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	//Local aXmlCons		:= {}
	//Local oXmlCons		:= Nil
	//Local cRetoConst	:= ""	
	Local cProtEnce		:= ""

	//Remove espaços em branco.
	cHash 	:= Alltrim(cValToChar(cHash))
	cTpDoc	:= Alltrim(cValToChar(cTpDoc))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função encerraDoc não recebeu o hash. ","Função encerraDoc(ADLOG057P)")
		logZBE("FUNCAO encerraDoc: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cTpDoc)
		MsgStop("Função encerraDoc não recebeu o tipo de documento. ","Função encerraDoc(ADLOG057P)")
		logZBE("FUNCAO encerraDoc: NAO RECEBEU O ARGUMENTO cTpDoc")
		RestArea(aArea)
		Return .F.

	EndIf

	//Everson - 27/01/2020. Chamado 0541941.
	If cTpDoc == "2"
		
		//
		aStatus := statusMDFE(cHash) //Executa função de status do MDF-e.

	ElseIf cTpDoc == "3"

		//
		aStatus := statusCIOT(cHash) //Executa função de status do MDF-e.

	EndIf
	
	//Valida o retorno da função de status.
	If Len(aStatus[1]) <> 11
		MsgStop("Não foi possível obter o status do documento.","Função encerraDoc(ADLOG057P)")
		RestArea(aArea)
		Return .F.

	EndIF

	//Status Protheus e mensagem do sistema Ophos.
	cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
	cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))

	//Informações de encerramento.
	cProtEmis	:= Alltrim(cValToChar(aStatus[1][3]))
	cChaveAces	:= Alltrim(cValToChar(aStatus[1][4]))
	cProtEnce	:= Alltrim(cValToChar(aStatus[1][5]))

	//Monta script sql.
	cUpdate := "UPDATE " + RetSqlName("ZFK") + " SET ZFK_STATUS = '" + cStatus +;
	"', ZFK_OPHOS='" + cMsgOphos + "', ZFK_PROENC='" + cProtEnce + "', ZFK_PROTEM='" + cProtEmis +;
	"', ZFK_CHAVE='" + cChaveAces + "' WHERE ZFK_HASH = '" + cHash + "' AND ZFK_TPDOC = '" + cTpDoc + "'"

	//Executa script.
	If TCSQLExec(cUpdate) < 0 //Verifica se retornou erro.

		cErroUp := Alltrim(cValToChar(TCSQLError()))
		MsgStop("Função encerraDoc não atualizadou o registro do documento na base do sistema protheus." + Chr(13) + Chr(10) +;
		"TCSQLError " + cErroUp,"Função encerraDoc(ADLOG057P)")
		logZBE("FUNCAO encerraDoc: NAO RECEBEU ATUALIZOU O REGISTRO DO DOCUMENTO " + cHash + " ERRO " + cErroUp)
		RestArea(aArea)
		Return .F.

	EndIf
	
	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} ADLOG576  
	Finalizar MDF-e não registrado. Chamado 044314.
	@type  Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
User Function ADLOG576()

	//Variáveis.
	Local aArea			:= GetArea()
	Local aDados		:= {}
	Local cHash			:= ""
	//Local aItinierario	:= {}
	Local cDateTime		:= ""
	Local cIBGE			:= ""

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')

	//Executa chamada de tela.
	aDados := telaGen4(2)

	//Valida o retorno da função telaGen4.
	If Len(aDados) == 0
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	cDateTime	:= Alltrim(cValToChar(aDados[1][1])) + Alltrim(cValToChar(aDados[1][2]))
	cHash		:= Alltrim(cValToChar(aDados[1][3])) 	//Recupera o hash do MDF-e
	cIBGE   	:= Alltrim(cValToChar(aDados[1][4])) 	//Recupera o código do roteiro.

	//Executa a chamada da função para encerrar o MDF-e.
	encerraMDF(cHash,cDateTime,cIBGE)
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} selectCTE  
	Interface para selecionar os CT-es para emissão de MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function selectCTE(aDados,lSelectCTE)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aStruct		:={}
	Local aFields		:={}
	//Local _carq			:= ""
	//Local oMarkPrivate	:= Nil
	Local aRetorno		:={}
	Local i				:= 1
	Local cDoc			:= ""
	Local oTab2			:= Nil

	Private aRotina    := {}
	Private cCadastro	:= ""
	Private cMark		:= GetMark()
	Private lProcess 	:= .F.
	Private cAlias2	:= GetNextAlias()

	//Valida retorno da função obtDDGrid.
	If Len(aDados) == 0
		RestArea(aArea)
		Return aRetorno
		
	EndIf
	
	//
	cCadastro	:= "Selecione CT-e para geração de MDF-e"

	//Aadd(aRetorno,{cHash,cNum,cSerie,cValor,cProtocolo})
	Aadd(aStruct,{"TP_OK"      	,"C"    ,   2,0})
	Aadd(aStruct,{"TP_TPDOC"   	,"C"    ,   6,0})
	Aadd(aStruct,{"TP_CARGA"   	,"C"    ,   6,0})
	Aadd(aStruct,{"TP_DTENTRE"	,"C"    ,  10,0})
	Aadd(aStruct,{"TP_VEICULO" 	,"C"    ,   7,0})
	Aadd(aStruct,{"TP_NUMDOC"  	,"C"    ,   9,0})
	Aadd(aStruct,{"TP_SERDOC"  	,"C"    ,   3,0})
	Aadd(aStruct,{"TP_VALOR"   	,"N"    ,  15,2})
	Aadd(aStruct,{"TP_OPHOS"   	,"C"    , 150,0})
	Aadd(aStruct,{"TP_PROT"	  	,"C"    , 150,0})
	Aadd(aStruct,{"TP_HASH"    	,"C"    , 200,0})

	//Cria tabela temporária.
	oTab2 := FWTemporaryTable():New(cAlias2)

	//Configura campos e índices.
	oTab2:SetFields(aStruct)
	oTab2:AddIndex("indice1", {"TP_CARGA"} )
	oTab2:AddIndex("indice2", {"TP_DTENTRE","TP_CARGA"} )
	
	//
	oTab2:Create()

	//Atribui valores ao arquivo temporário.
	For i := 1 To Len(aDados)
		
		RecLock(cAlias2,.T.)

			cDoc := tabelaDoc(Alltrim(cValToChar(aDados[i][9])))
			(cAlias2)->TP_OK		:= cMark
			(cAlias2)->TP_TPDOC		:= cDoc
			(cAlias2)->TP_CARGA		:= Alltrim(cValToChar(aDados[i][6]))
			(cAlias2)->TP_VEICULO	:= Alltrim(cValToChar(aDados[i][7]))
			(cAlias2)->TP_NUMDOC  	:= Alltrim(cValToChar(aDados[i][2]))
			(cAlias2)->TP_SERDOC 	:= Alltrim(cValToChar(aDados[i][3]))
			(cAlias2)->TP_VALOR		:= Val(Alltrim(cValToChar(aDados[i][4])))
			(cAlias2)->TP_OPHOS		:= Alltrim(cValToChar(aDados[i][8]))
			(cAlias2)->TP_PROT		:= Alltrim(cValToChar(aDados[i][5]))
			(cAlias2)->TP_HASH 		:= Alltrim(cValToChar(aDados[i][1]))
			(cAlias2)->TP_DTENTRE 	:= DToC(SToD(aDados[i][10]))

		MsUnlock()

	Next i

	//Campos que serão exibidos na MarkBrowse.
	Aadd(aFields,{"TP_OK"		,"" ,""})
	Aadd(aFields,{"TP_TPDOC"	,"","Tipo Doc."})
	Aadd(aFields,{"TP_CARGA"	,"","Roteiro"})
	Aadd(aFields,{"TP_DTENTRE"	,"","Dt Entrega"})
	Aadd(aFields,{"TP_VEICULO"	,"","Veículo"})
	Aadd(aFields,{"TP_NUMDOC"	,"","Num. Doc."})
	Aadd(aFields,{"TP_SERDOC"	,"","Série Doc."})
	Aadd(aFields,{"TP_VALOR"	,"","Valor","@E 999,999.99"})
	Aadd(aFields,{"TP_OPHOS"	,"","Msg. Ophos"})
	Aadd(aFields,{"TP_PROT"	    ,"","Protocolo"})
	Aadd(aFields,{"TP_HASH"		,"","Hash"})

	DbSelectArea(cAlias2)
	(cAlias2)->(DbGotop())

	//Opções no menu da tela
	Aadd(aRotina,{"Emitir MDF-e"      ,"U_adlog575()"	,0,5})
	Aadd(aRotina,{"Inverter Seleção"  ,"U_adlog573()"	,0,7})
	
	//
	If lSelectCTE
		//Função MarkBrowse.
		MarkBrow(cAlias2, 'TP_OK',,aFields,, cMark,'U_adlog573()',,,,'U_adlog577()')
	
	Else
		lProcess := .T.
		
	EndIf

	//Verifica se há registros marcados.
	If lProcess
		DbSelectArea(cAlias2)
		(cAlias2)->(DbGoTop())
		While !(cAlias2)->(Eof())
			If !Empty(Alltrim((cAlias2)->TP_OK))
	
				//{cHash,cNum,cSerie,cValor,cProtocolo,cCodCarga,cVeic,cMsgOphos,cTpDoc}
				Aadd(aRetorno, {;
				(cAlias2)->TP_HASH	,;
				(cAlias2)->TP_NUMDOC	,;
				(cAlias2)->TP_SERDOC	,;
				(cAlias2)->TP_VALOR	,;
				(cAlias2)->TP_PROT	,;
				(cAlias2)->TP_CARGA	,;
				(cAlias2)->TP_VEICULO,;
				(cAlias2)->TP_OPHOS	,;
				(cAlias2)->TP_TPDOC	 ;
				})
			EndIf
			(cAlias2)->(DbSkip())
		End
	
	EndIf
	
	(cAlias2)->(DbCloseArea())

	//Apaga a tabela temporária.
	oTab2:Delete()
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} xmlMDFDow  
	Função para download do xml do MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function xmlMDFDow(cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUrl		:= GetMv("MV_#XMLMDF")
	Local cCaminho	:= ""
	Local cArq		:= cHash + "MDFE"

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função xmlMDFDow não recebeu o hash do MDF-e.","Função xmlMDFDow(ADLOG057P)")
		logZBE("FUNCAO xmlMDFDow: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return Nil

	ElseIf Empty(cUrl)
		MsgStop("Função xmlMDFDow não obteve a URL para download do arquivo xml do MDF-e (MV MV_#XMLMDF).","Função xmlMDFDow(ADLOG057P)")
		logZBE("FUNCAO xmlMDFDow: NAO OBTEVE A URL PARA EFETUAR O DOWNLOAD DO ARQUIVO XML MV MV_#XMLMDF")
		RestArea(aArea)
		Return Nil

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl 	:= StrTran(cUrl,"{hash}",cHash)

	//Faz o download do arquivo.
	cCaminho := obtArquivo(cUrl,cArq,"xml")

	//Verifica o retorno da função obtArquivo.
	If Empty(cCaminho)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	fVisualiza(cCaminho)
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} pdfMDFdow  
	Função para download do pdf do MDF-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function pdfMDFdow(cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cUrl		:= GetMv("MV_#PDFMDF")
	Local cCaminho 	:= ""
	Local cArq		:= cHash + "MDFE"

	//Remove espaços em branco.
	cHash 	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função pdfMDFdow não recebeu o hash do MDF-e.","Função pdfMDFdow(ADLOG057P)")
		logZBE("FUNCAO pdfMDFdow: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return Nil

	ElseIf Empty(cUrl)
		MsgStop("Função pdfMDFdow não obteve a URL para efetuar o download do arquivo pdf do MDF-e (MV MV_#PDFMDF).","Função pdfMDFdow(ADLOG057P)")
		logZBE("FUNCAO pdfMDFdow: NAO OBTEVE A URL PARA EFETUAR O DOWNLOAD DO ARQUIVO PDF MV MV_#PDFMDF")
		RestArea(aArea)
		Return Nil

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl := Strtran(cUrl,"{hash}",cHash)

	//Faz o download do arquivo.
	cCaminho := obtArquivo(cUrl,cArq,"pdf")

	//Verifica o retorno da função obtArquivo.
	If Empty(cCaminho)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	fVisualiza(cCaminho)
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraObjXML  
	Função que gerar objeto XML. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function geraObjXML(cStringXML)

	//Variáveis.
	Local aArea		:= GetArea()
	Local aRet  	:= {}
	Local oXml		:= Nil
	Local cError	:= ""
	Local cWarning	:= ""

	//Remove espaços em branco.
	cStringXML := Alltrim(cValToChar(cStringXML))

	//Verifica o argumento da função.
	If Empty(cStringXML)
		MsgStop("Função geraObjXML não recebeu o argumento cStringXML.","Função geraObjXML(ADLOG057P)")
		Aadd(aRet,{.F.,oXml})
		logZBE("FUNCAO geraObjXML: NAO RECEBEU ARGUMENTO cStringXML" )
		RestArea(aArea)
		Return aRet

	EndIf

	//Cria um objeto XML.
	oXml := XMLParser(cStringXML,"_",@cError,@cWarning)

	//Verifica se a geração do objeto xml apresentou erro.
	If cError # ""
		MsgStop("A conversão da string xml para o objeto xml apresentou ERRO! Erro: " + cError,"Função geraObjXML(ADLOG057P)")
		Aadd(aRet,{.F.,oXml})
		logZBE("FUNCAO geraObjXML: FALHA NA GERACAO DO XML (ERRO) " + cError )
		RestArea(aArea)
		Return aRet

	EndIf

	//Verifica se a geração do objeto xml apresentou alerta.
	If cWarning # ""
		MsgStop("A conversão da string xml para o objeto xml apontou ALERTA! Alerta: " + cWarning,"Função geraObjXML(ADLOG057P)")
		Aadd(aRet,{.F.,oXml})
		logZBE("FUNCAO Função geraObjXML: FALHA NA GERACAO DO XML (ALERTA) " + cWarning)
		RestArea(aArea)
		Return aRet

	EndIf
	
	//
	Aadd(aRet,{.T.,oXml})
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} consEmpres  
	Função para chamada consultar se empresa pode emitir CT-e. Chamado 044314.
	@type Static Function
	@author Everson
	@since 10/06/2019
	@version 01
	/*/
Static Function consEmpres(lPerg)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cAdoroCNPJ	:= Alltrim(cValToChar(GetMv("MV_#CTECNP")))
	Local cQuery		:= ""
	//Local cCodTransp	:= ""
	Local aTransport	:= {}
	Local i				:= 0
	
	Default lPerg		:= .T.

	//
	If lPerg
		If ! Pergunte("CTE02",.T.)
			RestArea(aArea)
			Return Nil
			
		EndIf
	
	EndIf

	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT A4_COD, A4_LOJTRA, A4_CGC, A4_INSEST " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SA4") + " (NOLOCK) AS SA4 " 
	cQuery += " WHERE " 
	cQuery += " A4_FILIAL = '" + FWxFilial("SA4") + "' " 
	cQuery += " AND A4_COD BETWEEN '" + cValToChar(MV_PAR01) + "' AND '" + cValToChar(MV_PAR03) + "' " 
	cQuery += " AND A4_LOJTRA  BETWEEN '" + cValToChar(MV_PAR02) + "' AND '" + cValToChar(MV_PAR04) + "' " 
	cQuery += " AND SA4.D_E_L_E_T_ = '' " 
	cQuery += " ORDER BY A4_COD, A4_LOJTRA "
	
	//
	If Select("TRP_STATUS") > 0
		TRP_STATUS->(DbCloseArea())
		
	EndIf

	TcQuery cQuery New Alias "TRP_STATUS"

	DbSelectArea("TRP_STATUS")
	TRP_STATUS->(DbGoTop())

	While ! TRP_STATUS->(Eof())
		Aadd(aTransport,{ { Alltrim(cValToChar(TRP_STATUS->A4_COD)),Alltrim(cValToChar(TRP_STATUS->A4_LOJTRA)), Alltrim(cValToChar(TRP_STATUS->A4_CGC)), Alltrim(cValToChar(TRP_STATUS->A4_INSEST)),cAdoroCNPJ }  })

		TRP_STATUS->(DbSkip())
		
	End
		
	//
	TRP_STATUS->(DbCloseArea())

	//Valida o retorno do bando de dados.
	If Len(aTransport) == 0
		MsgStop("Não houve retorno no banco de dados para os parâmetros informados.","Função consEmpres(ADLOG057P)")
		RestArea(aArea)
		Return Nil

	EndIf
	
	//Solicita confirmação do usuário.
	If lPerg
		If ! MsgYesNo("Será efetuada consulta para " + cValToChar(Len(aTransport)) + " empresa(s). Deseja prosseguir?","Função consEmpres(ADLOG057P)")
			RestArea(aArea)
			Return Nil
	
		EndIf
	
	EndIf

	//Itera sobre o array.
	For i := 1 To Len(aTransport)
		procConEmp(aTransport[i][1]) //Executa consulta da transportadora.

	Next i
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} procConEmp  
	Processa consulta Empresa. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 10/06/2019
	@version 01
	/*/
Static Function procConEmp(aDadosTr)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUrl      	:= GetMv("MV_#CONEMP")
	Local cTransp		:= ""
	Local cCabec    	:= obtCabec()
	Local aXml			:= {}
	Local oXml			:= Nil
	Local cXml      	:= ""
	//Local cTemplate 	:= ""
	Local cPrazo		:= GetMv("MV_#TEMPOP")
	Local cTrpCNPJ		:= ""
	Local cTrpInsEst	:= ""
	Local cAdoroCNPJ	:= ""
	Local cChvCons		:= Alltrim(GetMv("MV_#CONSEM")) //"C-M-F-CD"
	Local cAmbCons		:= Alltrim(GetMv("MV_#AMBCEM"))
	Local cRetPost		:= ""
	Local cErroWS		:= ""
	Local aCabec		:= {}
	Local oRestClient	:= Nil
	
	//
	If Empty(cUrl)
		MsgStop("Função procConEmp não obteve a URL para consulta de empresa (MV MV_#CONEMP).","Função procConEmp(ADLOG057P)")
		logZBE("FUNCAO procConEmp: NAO OBTEVE A URL PARA CONSULTA DE EMPRESA MV MV_#CONEMP")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona valores às variáveis.
	cTrpCNPJ	:= Alltrim(cValToChar(aDadosTr[3]))
	cTrpCNPJ	:= StrTran(cTrpCNPJ,".","")

	cTrpInsEst	:= Alltrim(cValToChar(aDadosTr[4]))
	cTrpInsEst	:= StrTran(cTrpInsEst,".","")

	cAdoroCNPJ	:= Alltrim(cValToChar(aDadosTr[5]))
	cAdoroCNPJ := StrTran(cAdoroCNPJ,".","")

	//Template de consulta de empresa.
	cXml := ""
	cXml += "<consultaTransportador>"
	cXml += "<cnpjTransportador>" + cTrpCNPJ + "</cnpjTransportador>
	cXml += "<ieTransportador>" + cTrpInsEst + "</ieTransportador>
	cXml += "<cnpjSolicitante>" + cAdoroCNPJ + "</cnpjSolicitante>
	cXml += "<ambiente>" + cAmbCons + "</ambiente>
	cXml += "<prazoAnalise>" + cPrazo + "</prazoAnalise>
	cXml += "<chaveConsulta>" + cChvCons + "</chaveConsulta>
	cXml += "</consultaTransportador>

	//Adiciona cabeçalho ao xml.
	cXml := cCabec + cXml

	//Salva arquivo que está sendo enviado.
	gravarTXT(cXml,cTransp + "Env_Consulta_Empresa","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Application/xml')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)
	oRestClient:nTimeOut := 120

	//Atribui parâmetros.
	oRestClient:SetPostParams(cXml)

	//Atribui path.
	oRestClient:setPath("")

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função procConEmp(ADLOG057P)")
		logZBE("FUNCAO cancCTE: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cXml)
		RestArea(aArea)
		Return .F.
		
	Endif
		
	//Salva arquivo de retorno do cancelamento.
	gravarTXT(cRetPost,cTransp + "Ret_Consulta_Empresa","xml",,.T.)

	//Gera objeto xml.
	aXml  := geraObjXML(cRetPost)
	If ! aXml[1][1] //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de geração do CT-e.
	obtRet(4,oXml,,,,,cTransp)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.

	//
	RestArea(aArea)

Return .T.
/*/{Protheus.doc} obtCabec  
	Função que retorna cabecalho para envio de xml. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function obtCabec()

	//Variáveis.
	Local cRet	:= '<?xml version="1.0" encoding="UTF-8"?>'

Return cRet
/*/{Protheus.doc} gravarTXT  
	Grava aquivo log. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function gravarTXT(cTexto,cNome,cExt,cPasta,lParam)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cData		:= StrTran(Alltrim(cValToChar(Date())),"/","_")
	Local cHora		:= StrTran(Alltrim(cValToChar(Time())),":","")
	Local cCamArq	:= ""
	Local lGravar 	:= GetMv("MV_#GRVTXT")

	//Padrões dos argumentos da função.
	Default cNome 	:= "arquivo"
	Default cExt	:= "txt"
	Default cExt	:= "txt"
	Default cPasta	:= "\cte_log\"
	Default lParam	:= .F.

	//Verifica parâmetro da MV.
	If ! lGravar  .And. lParam
		Return cCamArq
		
	EndIf

	//Cria arquivo.
	cCamArq	:= cPasta + Alltrim(cValToChar(cNome)) + cData + cHora + "." + cExt
	If MemoWrite(cCamArq,Alltrim(cValToChar(cTexto)))
	Else
		Return ""

	EndIf
	
	//
	RestArea(aArea)

Return cCamArq
/*/{Protheus.doc} codIBGEEst  
	Função retorna o código IBGE do estado. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function codIBGEEst(cUF,cRoteiro,cDtEntr)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cCodIBGE	:= ""

	//Remove espaços em branco.
	cUF 	:= Alltrim(cValToChar(cUF))
	cRoteiro:= Alltrim(cValToChar(cRoteiro))

	//Verifica argumentos da função.
	If Empty(cUF)
		MsgStop("Função codIBGEEst não recebeu a sigla do estado referente a carga " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função codIBGEEst(ADLOG057P)")
		logZBE("FUNCAO codIBGEEst NAO RECEBEU A SIGLA DO ESTADO REFERENTE a carga " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )
		RestArea(aArea)
		Return cCodIBGE
		
	EndIf
	
	//
	If cUF =="RO"
		cCodIBGE := "11"

	ElseIf	cUF =="AC"
		cCodIBGE := "12"

	ElseIf	cUF =="AM"
		cCodIBGE := "13"

	ElseIf	cUF =="RR"
		cCodIBGE := "14"

	ElseIf	cUF =="PA"
		cCodIBGE := "15"

	ElseIf	cUF =="AP"
		cCodIBGE := "16"

	ElseIf	cUF =="TO"
		cCodIBGE := "17"

	ElseIf	cUF =="MA"
		cCodIBGE := "21"

	ElseIf	cUF =="PI"
		cCodIBGE := "22"

	ElseIf	cUF =="CE"
		cCodIBGE := "23"

	ElseIf	cUF =="RN"
		cCodIBGE := "24"

	ElseIf	cUF =="PB"
		cCodIBGE := "25"

	ElseIf	cUF =="PE"
		cCodIBGE := "26"

	ElseIf	cUF =="AL"
		cCodIBGE := "27"

	ElseIf	cUF =="SE"
		cCodIBGE := "28"

	ElseIf	cUF =="BA"
		cCodIBGE := "29"

	ElseIf	cUF =="MG"
		cCodIBGE := "31"

	ElseIf	cUF =="ES"
		cCodIBGE := "32"

	ElseIf	cUF =="RJ"
		cCodIBGE := "33"

	ElseIf	cUF =="SP"
		cCodIBGE := "35"

	ElseIf	cUF =="PR"
		cCodIBGE := "41"

	ElseIf	cUF =="SC"
		cCodIBGE := "42"

	ElseIf	cUF =="RS"
		cCodIBGE := "43"

	ElseIf	cUF =="MS"
		cCodIBGE := "50"

	ElseIf	cUF =="MT"
		cCodIBGE := "51"

	ElseIf	cUF =="GO"
		cCodIBGE := "52"

	ElseIf	cUF =="DF"
		cCodIBGE := "53"

	EndIf

	//Verifica retorno.
	If Empty(cCodIBGE)
		MsgStop("Função codIBGEEst não localizou código do IBGE referente ao estado  " + cUF + ".","Função codIBGEEst(ADLOG057P)")
		logZBE("FUNCAO codIBGEEst NAO LOCALIZOU CODIGO DO IBGE REFERENTE AO ESTADO " + cUF)
		
	EndIf
	
	//
	RestArea(aArea)
	
Return cCodIBGE
/*/{Protheus.doc} MkBrwWF  
	MarkBrowse. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
// Static Function MkBrwWF(nTipo,lRenvMDF,cTxtBnt,lFilCanc,lFilEnce,lPerg,lIniMark)

//	//Variáveis.
// 	Local aStruct		:={}
// 	Local oTab1			:= Nil
// 	Local _afields		:={}
// 	//Local _carq			:= ""			
// 	//Local oMarkPrivate	:= Nil
// 	Local aRetorno		:={}
// 	Local i				:= 1
// 	Local cStatus		:= ""
// 	Local cMsgStatus	:= ""
// 	Local aDados		:= {}
// 	Local cTipoDoc		:= ""
// 	Local aCores		:= {}

// 	Private lProcess	:= .F.
// 	Private aRotina		:= {}
// 	Private cCadastro	:= ""
// 	Private cMark		:= GetMark()
	
// 	Private cAlTab1		:= GetNextAlias()
	
// 	Default cTxtBnt		:= "Processar"
// 	Default lRenvMDF	:= .F.
// 	Default lFilCanc	:= .F.
// 	Default lFilEnce	:= .F.
// 	Default lPerg		:= .T.
// 	Default lIniMark	:= .T.

// 	//Obtém dados.
// 	aDados := obtDDGrid(nTipo,lFilCanc,lFilEnce,lPerg)
	
// 	//
// 	If nTipo == 3
// 		nTipo := 1
		
// 	EndIf
	
// 	//Valida retorno da função obtDDGrid.
// 	If Len(aDados) == 0
// 		Return aRetorno
		
// 	EndIf
	
// 	//Título
// 	If nTipo == 1
// 		cCadastro := "Conhecimento de Transporte Eletrônico"
		
// 	ElseIf nTipo == 2
// 		cCadastro := "Manifesto Eletrônico de Documentos"
		
// 	EndIf
	
// 	//Cria tabela temporária.
// 	oTab1 := FWTemporaryTable():New(cAlTab1)
	
// 	//
// 	Aadd(aStruct,{"TP_OK"       ,"C"    ,   2,0})
// 	Aadd(aStruct,{"TP_DATA"     ,"C"    ,  10,0})
// 	Aadd(aStruct,{"TP_DTENTRE"  ,"C"    ,  10,0})
// 	Aadd(aStruct,{"TP_ROTEIR"   ,"C"    ,   4,0})
// 	Aadd(aStruct,{"TP_STATUS"   ,"C"    ,  20,0})
// 	Aadd(aStruct,{"TP_TRANSPO"  ,"C"    ,   6,0})
// 	Aadd(aStruct,{"TP_LOJA"     ,"C"    ,   2,0})
// 	Aadd(aStruct,{"TP_NMTRA"    ,"C"    ,  50,0})
// 	Aadd(aStruct,{"TP_VEICULO"  ,"C"    ,   8,0})
// 	Aadd(aStruct,{"TP_REBOQUE"  ,"C"    ,   8,0})
// 	Aadd(aStruct,{"TP_CARGA"    ,"C"    ,   6,0})
// 	Aadd(aStruct,{"TP_SEQENV"   ,"C"    ,   3,0})
// 	Aadd(aStruct,{"TP_TPDOC"    ,"C"    ,   6,0})
// 	Aadd(aStruct,{"TP_NUMDOC"   ,"C"    ,   9,0})
// 	Aadd(aStruct,{"TP_SERDOC"   ,"C"    ,   3,0})

// 	//Valor do CT-e.
// 	If nTipo == 1
// 		Aadd(aStruct,{"TP_VALOR"    ,"N"    ,   15,2})
		
// 	EndIf

// 	Aadd(aStruct,{"TP_OPHOS"    ,"C"    , 100,0})
// 	Aadd(aStruct,{"TP_HASH"     ,"C"    , 100,0})

// 	Aadd(aStruct,{"TP_CHAVE"    ,"C"    , 100,0})
// 	Aadd(aStruct,{"TP_PROTEMI"  ,"C"    , 100,0})
// 	Aadd(aStruct,{"TP_PROTCAN"  ,"C"    , 100,0})
// 	Aadd(aStruct,{"TP_ENVIO"    ,"C"    , 2,0})

// 	//Encerramento do MDF-e.
// 	If nTipo == 2
// 		Aadd(aStruct,{"TP_PROTENC"  ,"C"    , 100,0})
		
// 	EndIf

// 	//Configura campos e índices.
// 	oTab1:SetFields(aStruct)
// 	oTab1:AddIndex("indice1", {"TP_CARGA"} )
// 	oTab1:AddIndex("indice2", {"TP_DTENTRE","TP_ROTEIR"} )
	
// 	//
// 	oTab1:Create()

// 	//Atribui valores ao arquivo temporário.
// 	For i := 1 To Len(aDados)

// 		cStatus := Alltrim(cValToChar(aDados[i][10]))

// 		cMsgStatus := tlbStatus(cStatus,1)

// 		//Verifica o tipo de documento.
// 		cTipoDoc := tabelaDoc(Alltrim(cValtoChar(aDados[i][7])))

// 		RecLock(cAlTab1,.T.)
// 			(cAlTab1)->TP_OK		:= Iif(lIniMark,cMark,"")
// 			(cAlTab1)->TP_DATA		:= DToC(SToD(Alltrim(cValtoChar(aDados[i][12]))))
// 			(cAlTab1)->TP_DTENTRE	:= DToC(SToD(Alltrim(cValtoChar(aDados[i][4]))))
// 			(cAlTab1)->TP_ROTEIR	:= Alltrim(cValtoChar(aDados[i][5]))	
// 			(cAlTab1)->TP_STATUS 	:= cMsgStatus
// 			(cAlTab1)->TP_TRANSPO	:= Alltrim(cValtoChar(aDados[i][1]))
// 			(cAlTab1)->TP_LOJA		:= Alltrim(cValtoChar(aDados[i][2]))
// 			(cAlTab1)->TP_NMTRA		:= Alltrim(cValtoChar(aDados[i][21]))		
// 			(cAlTab1)->TP_VEICULO	:= Alltrim(cValtoChar(aDados[i][13]))
// 			(cAlTab1)->TP_REBOQUE	:= Alltrim(cValtoChar(aDados[i][20]))
// 			(cAlTab1)->TP_CARGA   	:= Alltrim(cValToChar(aDados[i][3]))
// 			(cAlTab1)->TP_SEQENV  	:= Alltrim(cValtoChar(aDados[i][6]))
// 			(cAlTab1)->TP_TPDOC  	:= cTipoDoc
// 			(cAlTab1)->TP_NUMDOC  	:= Alltrim(cValToChar(aDados[i][8]))	
// 			(cAlTab1)->TP_SERDOC 	:= Alltrim(cValToChar(aDados[i][9]))
	
// 			If nTipo == 1 //Valor do CT-e.
// 				(cAlTab1)->TP_VALOR 	:= Val(Alltrim(cValToChar(aDados[i][15])))
				
// 			EndIf
	
// 			//
// 			(cAlTab1)->TP_OPHOS		:= Alltrim(cValToChar(aDados[i][14]))
// 			(cAlTab1)->TP_HASH 		:= Alltrim(cValToChar(aDados[i][11]))
	
// 			(cAlTab1)->TP_CHAVE		:= Alltrim(cValToChar(aDados[i][16]))
// 			(cAlTab1)->TP_PROTEMI	:= Alltrim(cValToChar(aDados[i][17]))
// 			(cAlTab1)->TP_PROTCAN	:= Alltrim(cValToChar(aDados[i][18]))
	
// 			If nTipo == 2 //Encerramento do MDF-e.
// 				(cAlTab1)->TP_PROTENC	:= Alltrim(cValToChar(aDados[i][19]))
				
// 			EndIf
			
// 			(cAlTab1)->TP_ENVIO := Alltrim(cValToChar(aDados[i][22]))

// 		MsUnlock()

// 	Next i

// 	//Campos que serão exibidos na MarkBrowse.
// 	Aadd(_afields,{"TP_OK"		,"",""})
// 	Aadd(_afields,{"TP_DATA"	,"","Dt Emissão"})
// 	Aadd(_afields,{"TP_DTENTRE"	,"","Dt Entrega"})
// 	Aadd(_afields,{"TP_ROTEIR"	,"","Roteiro"})
// 	Aadd(_afields,{"TP_STATUS"	,"","Status"})
// 	Aadd(_afields,{"TP_TRANSPO"	,"","Tranportadora"})
// 	Aadd(_afields,{"TP_LOJA"	,"","Loja"})
// 	Aadd(_afields,{"TP_NMTRA"	,"","Nome"})
// 	Aadd(_afields,{"TP_VEICULO"	,"","Placa"})
// 	Aadd(_afields,{"TP_REBOQUE"	,"","Reboque"})
// 	Aadd(_afields,{"TP_CARGA"	,"","Carga"})
// 	Aadd(_afields,{"TP_SEQENV"	,"","Seq. Envio"})
// 	Aadd(_afields,{"TP_TPDOC"	,"","Tipo Doc"})
// 	Aadd(_afields,{"TP_NUMDOC"	,"","Num. Doc."})
// 	Aadd(_afields,{"TP_SERDOC"	,"","Série Doc."})

// 	If nTipo == 1
// 		Aadd(_afields,{"TP_VALOR"	,"","Valor","@E 999,999.99"})
		
// 	EndIf

// 	Aadd(_afields,{"TP_OPHOS"	,"","Msg. Ophos"})
// 	Aadd(_afields,{"TP_HASH"	,"","Hash"})

// 	Aadd(_afields,{"TP_CHAVE"	,"","Chave de Acesso"})
// 	Aadd(_afields,{"TP_PROTEMI"	,"","Protocolo de Emissão"})
// 	Aadd(_afields,{"TP_PROTCAN"	,"","Protocolo de Cancelamento"})

// 	If nTipo == 2
// 		Aadd(_afields,{"TP_PROTENC"	,"","Protocolo Encerramento"})
		
// 	EndIf
	
// 	Aadd(_afields,{"TP_ENVIO"	,"","Tipo de envio"})

// 	DbSelectArea(cAlTab1)
// 	(cAlTab1)->(DbGotop())

// 	//Opções no menu da tela.
// 	Aadd(aRotina,{cTxtBnt             ,"U_adlog575()"	,0,5})
// 	Aadd(aRotina,{"Legenda"           ,"U_adlog574()"	,0,6})   
// 	Aadd(aRotina,{"Inverter Seleção"  ,"U_adlog571()"	,0,7})

// 	//Legenda.
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Processando'"			,"BR_AMARELO" }) 
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Emitido'"				,"BR_VERDE" })     
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Cancelado'" 			,"BR_CANCEL" })  
	
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Rejeitado'" 			,"BR_PINK" }) 
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Contingência'" 		,"BR_MARROM" })
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Hash não localizado'"	,"BR_VIOLETA" })
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Denegado'" 			,"BR_PRETO" })
	
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Encerrado'" 			,"BR_AZUL" })  
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Não emitido'" 		,"BR_VERMELHO" })  
// 	Aadd(aCores,{"Alltrim((cAlTab1)->TP_STATUS)=='Não definido!!!'" 	,"BR_LARANJA" })   

// 	//Função MarkBrowse.
// 	MarkBrow( cAlTab1, 'TP_OK',,_afields,,cMark,'U_adlog571()',,,,'U_adlog572()',,,,aCores)

// 	//Verifica se há registros marcados.
// 	DbSelectArea(cAlTab1)
// 	If lProcess

// 		(cAlTab1)->(DbGoTop())
// 		While !(cAlTab1)->(Eof())
// 			If ! Empty(Alltrim((cAlTab1)->TP_OK))
// 				Aadd(aRetorno, {;
// 					(cAlTab1)->TP_TRANSPO	,; //1
// 					(cAlTab1)->TP_CARGA		,; //2
// 					(cAlTab1)->TP_SEQENV	,; //3
// 					(cAlTab1)->TP_TPDOC		,; //4
// 					(cAlTab1)->TP_NUMDOC	,; //5
// 					(cAlTab1)->TP_SERDOC	,; //6
// 					(cAlTab1)->TP_STATUS	,; //7
// 					(cAlTab1)->TP_HASH		,; //8
// 					(cAlTab1)->TP_VEICULO	,; //9
// 					(cAlTab1)->TP_REBOQUE 	,; //10
// 					(cAlTab1)->TP_ROTEIR  	,; //11
// 					(cAlTab1)->TP_DTENTRE   ,; //12
// 					(cAlTab1)->TP_CHAVE		,; //13
// 					(cAlTab1)->TP_ENVIO})	   //14
// 			EndIf
			
// 			(cAlTab1)->(DbSkip())
			
// 		EndDo

// 	EndIf
	
// 	//
// 	(cAlTab1)->(DbCloseArea())

// 	//Apaga a tabela temporária.
// 	oTab1:Delete()

// Return aRetorno
/*/{Protheus.doc} tlbStatus  
	Retorna o status do documento. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
Static Function tlbStatus(cRetorno,nTipo)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cStatus	:= ""

	//Remove espaços em branco.
	cRetorno	:= Alltrim(cValToChar(cRetorno))
	nTipo		:= Alltrim(cValToChar(nTipo))

	If nTipo == "1"

		If cRetorno == "0"
			cStatus := "Processando"

		ElseIf cRetorno == "1"
			cStatus := "Emitido"

		ElseIf cRetorno == "2"
			cStatus := "Cancelado"

		ElseIf cRetorno == "3"
			cStatus := "Rejeitado"

		ElseIf cRetorno == "4"
			cStatus := "Contingência" 
			
		ElseIf cRetorno == "5"
			cStatus := "Hash não localizado"

		ElseIf cRetorno == "6"
			cStatus := "Denegado"

		ElseIf cRetorno == "7"
			cStatus := "Encerrado"
			
		ElseIf cRetorno == "8"
			cStatus := "Não emitido"
									
		Else
			cStatus := "Não definido!!!"

		EndIf	


	ElseIf nTipo == "2"

		If cRetorno == "100"
			cStatus := "0"

		ElseIf cRetorno == "101"
			cStatus := "1"

		ElseIf cRetorno == "102"
			cStatus := "2"

		ElseIf cRetorno == "103"
			cStatus := "3"
			
		ElseIf cRetorno == "104"
			cStatus := "4"

		ElseIf cRetorno == "105"
			cStatus := "5"

		ElseIf cRetorno == "106"
			cStatus := "6"
									
		ElseIf cRetorno == "107"
			cStatus := "7"

		Else
			cStatus := "8"

		EndIf

	EndIf
	
	//
	RestArea(aArea)

Return cStatus
/*/{Protheus.doc} adlog574  
	Legenda markbrowse 1. Chamado 044314.
	@type  Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
User Function adlog574(nOpc)

	//Variáveis.
	Local cTitulo := "Legenda"
	Local aLegenda:= {}

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')

	//
	If nOpc == 1
		Aadd(aLegenda,{"BR_VERMELHO" ,"Pendente CT-e e MFD-e"})
		Aadd(aLegenda,{"BR_AMARELO"  ,"Pendente MDF-e ou CT-e"}) //Everson - 12/08/19. Chamado 044314.
		Aadd(aLegenda,{"BR_VERDE"    ,"Documentos emitidos"}) 
		
	ElseIf nOpc == 6 
		Aadd(aLegenda,{"BR_AMARELO" ,"CT-e não emitido"})
		//Aadd(aLegenda,{"BR_VERDE"   ,"CT-e emitido"})
		 	
	Else 
		Aadd(aLegenda,{"BR_AMARELO"  ,"Processando"		}) 
		Aadd(aLegenda,{"BR_VERDE"    ,"Emitido"	  		})     
		Aadd(aLegenda,{"BR_CANCEL"   ,"Cancelado"   	})  
		
		Aadd(aLegenda,{"BR_PINK"     ,"Rejeitado"	    }) 
		Aadd(aLegenda,{"BR_MARROM"   ,"Contingência"	})
		Aadd(aLegenda,{"BR_VIOLETA"  ,"Hash não localizado"})
		Aadd(aLegenda,{"BR_PRETO"    ,"Denegado"		})
		
		Aadd(aLegenda,{"BR_AZUL"     , "Encerrado"		})  
		Aadd(aLegenda,{"BR_VERMELHO" ,"Não emitido"		})  
		Aadd(aLegenda,{"BR_LARANJA"  ,"Não definido!!!"	})   
	
	EndIf

	BrwLegenda("Legenda",cTitulo,aLegenda)

Return Nil
/*/{Protheus.doc} adlog575  
	Processa selecção markbrowse 1. Chamado 044314.
	@type  Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
User function adlog575()

	//Variáveis.

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')
	
	//Atribui valor à variável de processamento.
	lProcess := .T.

	//Fecha MarkBrowse
	CloseBrowse()

Return Nil
/*/{Protheus.doc} adlog571  
	Marca todos os registros da  markbrowse 1. Chamado 044314.
	@type  Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
User Function adlog571()

	//Variáveis.
	Local oMark	 := GetMarkBrow()

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')
	
	DbSelectArea(cAlTab1)
	(cAlTab1)->(DbGotop())
	While ! (cAlTab1)->(Eof())
		
		U_adlog572()
		
		(cAlTab1)->(DbSkip())
		
	End
	
	//Força o posicionamento do browse no primeiro registro.
	oMark:oBrowse:Gotop()
	MarkBRefresh()

Return Nil
/*/{Protheus.doc} adlog572  
	Marca registro do arquivo temporário. Chamado 044314.
	@type  Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
User Function adlog572()

	//Variáveis.

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')
	
	If IsMark( 'TP_OK', cMark )

		RecLock( cAlTab1, .F. )

			Replace TP_OK With Space(2)

		MsUnLock()

	Else

		RecLock( cAlTab1, .F. )

			Replace TP_OK With cMark

		MsUnLock()

	EndIf

Return Nil
/*/{Protheus.doc} adlog573  
	Marca todos os registros da  markbrowse 2. Chamado 044314.
	@type  Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
User Function adlog573()

	//Variáveis.
	Local oMark := GetMarkBrow()

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')
	
	//
	DbSelectArea(cAlias2)
	(cAlias2)->(DbGotop())
	While ! (cAlias2)->(Eof())
	
		U_adlog577()
		
		(cAlias2)->(DbSkip())
	End
	
	// força o posicionamento do browse no primeiro registro
	oMark:oBrowse:Gotop()
	MarkBRefresh()

Return Nil
/*/{Protheus.doc} adlog577  
	Marca registro do arquivo temporário. Chamado 044314.
	@type  Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
User Function adlog577()

	U_ADINF009P('ADLOG057P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissão de CT-e/MDF-e')
	
	//
	If IsMark('TP_OK', cMark )

		RecLock(cAlias2, .F. )

			Replace TP_OK With Space(2)

		MsUnLock()

	Else

		RecLock(cAlias2, .F. )

			Replace TP_OK With cMark

		MsUnLock()

	EndIf

Return Nil
/*/{Protheus.doc} obtDDGrid  
	Retorna dados da grid. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 05/06/2019
	@version 01
	/*/
// Static Function obtDDGrid(nTipo,lFilCanc,lFilEnce,lPerg)

//	//Variáveis.
// 	Local aArea		:= GetArea()
// 	Local aRetorno	:= {}
// 	Local cTipo		:= Alltrim(cValToChar(nTipo))
// 	Local cQuery	:= ""
// 	Local cTransIni	:= ""
// 	Local cTransFim	:= ""
// 	Local cLojaDe	:= ""
// 	Local cLojaAte	:= ""
// 	Local cVecIni	:= ""
// 	Local cVecFim	:= ""
// 	Local cDataIni	:= ""
// 	Local cDataFim	:= ""
// 	Local cRotIni	:= ""
// 	Local cRotFim	:= ""
// 	Local cPerg 	:= "OPHOS1"
	
// 	Default lFilCanc := .F.
// 	Default lFilEnce := .F.
// 	Default lPerg	  := .T.

// 	//Valida escolha do usuário em prosseguir ou não.
// 	If lPerg
// 		If ! Pergunte(cPerg,.T.)
// 			Return aRetorno
			
// 		EndIf
	
// 	EndIf
	
// 	//
// 	cDataIni	:= DToS(MV_PAR01)
// 	cDataFim	:= DToS(MV_PAR02)
// 	cTransIni 	:= Alltrim(cValToChar(MV_PAR03))
// 	cLojaDe		:= Alltrim(cValToChar(MV_PAR04))
// 	cTransFim	:= Alltrim(cValToChar(MV_PAR05))
// 	cLojaAte	:= Alltrim(cValToChar(MV_PAR06))
// 	cVecIni		:= Alltrim(cValToChar(MV_PAR07))
// 	cVecFim		:= Alltrim(cValToChar(MV_PAR08))
// 	cRotIni		:= Alltrim(cValToChar(MV_PAR09))
// 	cRotFim		:= Alltrim(cValToChar(MV_PAR10))	

// 	//Monta script sql.
// 	cQuery := ""
// 	cQuery += " SELECT " 
// 	cQuery += " ZFK_TRANSP, " 
// 	cQuery += " ZFK_LOJA, " 
// 	cQuery += " ZFK_NMTRAN, " 
// 	cQuery += " ZFK_CARGA, " 
// 	cQuery += " ZFK_DTENTR, " 
// 	cQuery += " ZFK_ROTEIR, " 
// 	cQuery += " ZFK_SEQENV, " 
// 	cQuery += " ZFK_TPDOC, " 
// 	cQuery += " ZFK_NUMDOC, " 
// 	cQuery += " ZFK_SERDOC, " 
// 	cQuery += " ZFK_STATUS, " 
// 	cQuery += " ZFK_HASH, " 
// 	cQuery += " ZFK_DATA, " 
// 	cQuery += " ZFK_PLACA, " 
// 	cQuery += " ZFK_OPHOS, "  
// 	cQuery += " ZFK_CHAVE, " 
// 	cQuery += " ZFK_PROTEM, " 
// 	cQuery += " ZFK_PROTCA, " 
// 	cQuery += " ZFK_REBOQU, " 
// 	cQuery += " ZFK_PROENC, "
// 	cQuery += " ZFK_TPENVC, "
// 	cQuery += " SUM(ZFK_VALOR) AS ZFK_VALOR "
// 	cQuery += " FROM " 
// 	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
// 	cQuery += " WHERE " 
// 	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
// 	cQuery += " AND ZFK_DTENTR >= '" + cDataIni  + "' " 
// 	cQuery += " AND ZFK_DTENTR <= '" + cDataFim  + "' " 
// 	cQuery += " AND ZFK_TRANSP >= '" + cTransIni + "' " 
// 	cQuery += " AND ZFK_TRANSP <= '" + cTransFim + "' " 
// 	cQuery += " AND ZFK_LOJA   >= '" + cLojaDe   + "' " 
// 	cQuery += " AND ZFK_LOJA   <= '" + cLojaAte  + "' " 
// 	cQuery += " AND ZFK_PLACA  >= '" + cVecIni   + "' " 
// 	cQuery += " AND ZFK_PLACA  <= '" + cVecFim   + "'  " 

// 	cQuery += " AND ZFK_ROTEIR  >= '" + cRotIni   + "' " 
// 	cQuery += " AND ZFK_ROTEIR  <= '" + cRotFim   + "'  " 
	
// 	//
// 	If cTipo == "3"
// 		cQuery += " AND ZFK_TMEMIS = 'N' "
// 		cTipo := "1"
		
// 	EndIf
	
// 	cQuery += " AND ZFK_TPDOC = '" + cTipo + "' "
// 	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' " //Everson - 03/12/2019. Chamado 029058.
	
// 	//
// 	If lFilCanc //Filtra documentos cancelados.
// 		cQuery += " AND ZFK_STATUS <> '2'  " 
		
// 	EndIf
	
// 	//
// 	If lFilEnce
// 		cQuery += " AND ZFK_PROENC = ''  " 
	
// 	EndIf
	
// 	//
// 	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	
// 	cQuery += " GROUP BY "
// 	cQuery += " ZFK_TRANSP, " 
// 	cQuery += " ZFK_LOJA, " 
// 	cQuery += " ZFK_NMTRAN, " 
// 	cQuery += " ZFK_CARGA, " 
// 	cQuery += " ZFK_DTENTR, " 
// 	cQuery += " ZFK_ROTEIR, " 
// 	cQuery += " ZFK_SEQENV, " 
// 	cQuery += " ZFK_TPDOC, " 
// 	cQuery += " ZFK_NUMDOC, " 
// 	cQuery += " ZFK_SERDOC, " 
// 	cQuery += " ZFK_STATUS, " 
// 	cQuery += " ZFK_HASH, " 
// 	cQuery += " ZFK_DATA, " 
// 	cQuery += " ZFK_PLACA, " 
// 	cQuery += " ZFK_OPHOS, "  
// 	cQuery += " ZFK_CHAVE, " 
// 	cQuery += " ZFK_PROTEM, " 
// 	cQuery += " ZFK_PROTCA, " 
// 	cQuery += " ZFK_REBOQU, " 
// 	cQuery += " ZFK_PROENC, ZFK_TPENVC "	
// 	cQuery += " ORDER BY ZFK_DTENTR, ZFK_TRANSP, ZFK_LOJA, ZFK_PLACA, CAST(ZFK_SEQENV AS INTEGER) " 
	
// 	//Verifica se alias existe.
// 	If Select("DADOSZFK") > 0
// 		DADOSZFK->(DbCloseArea())
		
// 	Endif

// 	TcQuery cQuery New Alias "DADOSZFK"
// 	DbSelectArea("DADOSZFK")
// 	DADOSZFK->(DbGoTop())
// 	While ! DADOSZFK->(Eof())

// 		Aadd(aRetorno,{;
// 		DADOSZFK->ZFK_TRANSP ,; //1
// 		DADOSZFK->ZFK_LOJA   ,; //2
// 		DADOSZFK->ZFK_CARGA  ,; //3
// 		DADOSZFK->ZFK_DTENTR ,; //4
// 		DADOSZFK->ZFK_ROTEIR ,; //5
// 		DADOSZFK->ZFK_SEQENV ,; //6
// 		DADOSZFK->ZFK_TPDOC  ,; //7
// 		DADOSZFK->ZFK_NUMDOC ,; //8
// 		DADOSZFK->ZFK_SERDOC ,; //9
// 		DADOSZFK->ZFK_STATUS ,; //10
// 		DADOSZFK->ZFK_HASH   ,; //11
// 		DADOSZFK->ZFK_DATA	 ,; //12
// 		DADOSZFK->ZFK_PLACA  ,; //13
// 		DADOSZFK->ZFK_OPHOS	 ,; //14
// 		DADOSZFK->ZFK_VALOR	 ,; //15
// 		DADOSZFK->ZFK_CHAVE	 ,; //16
// 		DADOSZFK->ZFK_PROTEM ,; //17
// 		DADOSZFK->ZFK_PROTCA ,; //18
// 		DADOSZFK->ZFK_PROENC ,; //19
// 		DADOSZFK->ZFK_REBOQU ,; //20  
// 		DADOSZFK->ZFK_NMTRAN ,; //21
// 		DADOSZFK->ZFK_TPENVC})  //22

// 		DADOSZFK->(DbSkip())
		
// 	EndDo
	
// 	//
// 	DADOSZFK->(DbCloseArea())

// 	//Valida consulta ao BD.
// 	If Len(aRetorno) == 0
// 		MsgStop("A consulta ao banco de dados não retornou resultados.","Função obtDDGrid(ADLOG057P)")
// 		logZBE("FUNCAO obtDDGrid: CONSULTA AO BANDO DE DADOS NÃO RETORNOU RESULTADOS")
		
// 	EndIf
	
// 	//
// 	RestArea(aArea)

// Return aRetorno
/*/{Protheus.doc} telGen2  
	Tela genérica 2. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/06/2019
	@version 01
	/*/
Static Function telGen2(nTipo)

	//Variáveis.
	Local aArea		:= GetArea()
	Local oButton1	:= Nil
	Local oButton2	:= Nil
	Local cGet1 	:= Space(200)
	Local oSay1		:= Nil
	Local cTitulo	:= ""
	Local oTelGen2	:= Nil
	Local oGroup	:= Nil

	//Define o tipo de documento para o título da janela.
	If nTipo == 1
		cTitulo := "CT-e"

	ElseIf nTipo == 2
		cTitulo := "MDF-e"

	ElseIf nTipo == 3
		cTitulo := "CIOT" //Everson - 27/01/2020. Chamado 054941.

	EndIf
	
	//
	Define Msdialog oTelGen2 Title "Cancelamento de " + cTitulo From 000, 000  To 290, 405 COLORS 0, 16777215 Pixel STYLE DS_MODALFRAME
			
		@ 002, 001 Say oSay1 PROMPT "Por favor, informe o motivo do cancelamento (obrigatório)." SIZE 196, 012 Of oTelGen2 Pixel
		
		oEdit := tSimpleEditor():New(010,001, oTelGen2, 203, 100,,,,,.T.)
		oEdit:TextFormat(2)
		
		@ 120, 001 Group oGroup To 142, 205 Prompt "" Of oTelGen2 Pixel
	
		@ 125, 123 Button oButton1 Prompt "Ok" 			Size 036, 012 ACTION (oTelGen2:End(), cGet1 := Alltrim(cValToChar(oEdit:RetText()))) Of oTelGen2 Pixel
		@ 125, 164 Button oButton2 Prompt "Cancelar" 	Size 036, 012 ACTION (oTelGen2:End())	Of oTelGen2 Pixel

	Activate MSDIALOG oTelGen2 Centered
	
	//
	RestArea(aArea)

Return cGet1
/*/{Protheus.doc} grCTECompl  
	Gera CT-e complementar. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 07/06/2019
	@version 01
	*****Função chamada no Fonte ADLOG040P*****
	/*/
Static Function grCTECompl(cRoteiro,cDtEntr,nVlrCompl,cSeqCarAtu,cTipoEmiss,cAgrupa,cCTECompl,cSCTECompl,cChvCTECom,lCmpDia,aPorcOco)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aNotas		:= {}
	Local aNotasComple	:= {}
	//Local nNumNF		:= GetMv("MV_#QTDNFE")
	Local cNota			:= ""
	Local cSerie		:= ""

	Default cTipoEmiss	:= "01"
	Default cAgrupa		:= "00"
	Default lCmpDia		:= .F.

	//Remove espaços em branco.
	cRoteiro	:= Alltrim(cRoteiro)

	//Valida argumentos da função.
	If Empty(cRoteiro)
		MsgStop("Função grCTECompl não recebeu o código do roteiro.","Função grCTECompl(ADLOG057P)")
		logZBE("FUNCAO grCTECompl: NAO RECEBEU O CODIGO DO ROTEIRO")
		RestArea(aArea)
		Return Nil

	ElseIf nVlrCompl <= 0
		MsgStop("Função grCTECompl não recebeu o valor de complemento do frete.","Função grCTECompl(ADLOG057P)")
		logZBE("FUNCAO grCTECompl: NAO RECEBEU O VALOR DE COMPLEMENTO DO FRETE")
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If cAgrupa == "00"
		cNota	:= Alltrim(cValToChar(Posicione("ZFK",4,FWxFilial("ZFK") + cChvCTECom,"ZFK_NOTA")))
		cSerie	:= Alltrim(cValToChar(Posicione("ZFK",4,FWxFilial("ZFK") + cChvCTECom,"ZFK_SERIE")))
		
	EndIf

	//Obtém notas fiscais.
	aNotas	:= obtNF(cRoteiro,cDtEntr,cNota+cSerie)

	//Verifica o retorno da função obtNF.
	If Len(aNotas) <= 0
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	aNotasComple := aNotas

	//Executa função para gerar o CT-e complementar.
	procGerCTE(aNotasComple,cTipoEmiss,cAgrupa,cRoteiro,cDtEntr,nVlrCompl,cSeqCarAtu,,cCTECompl,cSCTECompl,cChvCTECom,lCmpDia,aPorcOco)
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} telaGen4  
	Tela genérica 4. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 13/06/2019
	@version 01
	/*/
Static Function telaGen4(nTipo)

	//Variáveis.
	Local aArea		:= GetArea()
	Local oButton1	:= Nil
	Local oButton2	:= Nil
	Local oGet1		:= Nil
	Local cGet1 	:= Date()
	Local oGet2		:= Nil
	Local cGet2 	:= Alltrim(cValToChar(Time()))
	Local oSay1		:= Nil
	Local oSay2		:= Nil
	Local oSay3		:= Nil
	Local oSay4		:= Nil
	Local oGet3		:= Nil
	Local cGet3		:= Space(200)
	Local oSay5		:= Nil
	Local oGet4		:= Nil
	Local cGet4		:= Space(5)
	Local oGet5		:= Nil
	Local cGet5		:= Space(2)
	Local oTelGen4	:= Nil
	Local aHora		:= {}
	Local lCancel	:= .F.
	Local cUF		:= ""
	Local aRetorno	:= {}

	//Remove espaços em branco.
	nTipo := Alltrim(cValToChar(nTipo))

	//
	Define Msdialog oTelGen4 Title "Encerramento de MDF-e" From 000, 000  To 290, 405 COLORS 0, 16777215 Pixel STYLE DS_MODALFRAME
		
		//
		@ 001, 001 Group oGroup To 115, 205 Prompt "" Of oTelGen4 Pixel
		
		//
		@ 004, 004 SAY oSay3 PROMPT "Por favor, informe a data e hora de encerramento do MDF-e." SIZE 156, 012 OF oTelGen4 COLORS 0, 16777215 Pixel

		@ 021, 050 MSGET oGet1 VAR cGet1 					SIZE 063, 010 OF oTelGen4 COLORS 0, 16777215 PIXEL
		@ 036, 050 MSGET oGet2 VAR cGet2 					SIZE 063, 010 OF oTelGen4 COLORS 0, 16777215 PIXEL Picture "99:99:99"
		@ 023, 017 SAY oSay1 PROMPT "Data" 					SIZE 025, 007 OF oTelGen4 COLORS 0, 16777215 PIXEL
		@ 039, 018 SAY oSay2 PROMPT "Hora" 					SIZE 019, 010 OF oTelGen4 COLORS 0, 16777215 PIXEL
			
		If nTipo == "2"
	
			@ 055, 017 SAY oSay4 PROMPT "Hash" 				SIZE 025, 007 OF oTelGen4 COLORS 0, 16777215 Pixel
			@ 052, 050 MSGET oGet3 Var cGet3 				SIZE 063, 010 OF oTelGen4 COLORS 0, 16777215 Pixel
	
			@ 071, 017 SAY oSay5 PROMPT "Cod.IBGE" 			SIZE 025, 007 OF oTelGen4 COLORS 0, 16777215 Pixel
			@ 069, 050 MSGET oGet4 Var cGet4 				SIZE 040, 010 OF oTelGen4 COLORS 0, 16777215 Pixel F3 "CTE_MD"
	
			@ 069, 098 MSGET oGet5 Var cGet5 				SIZE 010, 010 OF oTelGen4 COLORS 0, 16777215 Pixel When .F.
			
			//
			@ 125, 123 BUTTON oButton1 PROMPT "Ok" 			SIZE 036, 012 OF oTelGen4 ACTION (oTelGen4:End()) Pixel
			@ 125, 164 BUTTON oButton2 PROMPT "Cancelar" 	SIZE 036, 012 OF oTelGen4 ACTION (oTelGen4:End(),lCancel := .T.) Pixel
	
		Else
		
			//@ 125, 164 Button oButton8 Prompt "Cancelar"	  Size 036, 012 ACTION (oTelaMDF:End()) 		  Of oTelaMDF Pixel
			@ 125, 123 BUTTON oButton1 PROMPT "Ok" 			SIZE 036, 012 OF oTelGen4 ACTION (oTelGen4:End()) Pixel
			@ 125, 164 BUTTON oButton2 PROMPT "Cancelar" 	SIZE 036, 012 OF oTelGen4 ACTION (oTelGen4:End(),lCancel := .T.) Pixel
	
		EndIf	
	
		@ 120, 001 Group oGroup1 To 142, 205 Prompt "" Of oTelGen4 Pixel

	Activate MSDIALOG oTelGen4 Centered
	
	//
	If lCancel
		aRetorno := {}
		RestArea(aArea)
		Return aRetorno
		
	EndIf

	//
	If !Empty(cGet1) .And. !Empty(cGet2)

		cGet1 := DToS(cGet1)
		cGet1 := Substr(cGet1,1,4) + "-" + Substr(cGet1,5,2) + "-" + Substr(cGet1,7,2)
	
		aHora := StrTokArr(cGet2,":")

		If Len(aHora) <> 3 .Or. Empty(Alltrim(cValToChar(aHora[1]))) .Or. Empty(Alltrim(cValToChar(aHora[2]))) .Or. Empty(Alltrim(cValToChar(aHora[3])))
			MsgStop("Por favor, reveja o campo hora.","Função telaGen4","Função telaGen4(ADLOG057P)")
			RestArea(aArea)
			Return aRetorno
		
		EndIf

		cGet2 := "T" + cGet2 + "Z"
		cGet3 := Alltrim(cValToChar(cGet3))
		cGet4 := Alltrim(cValToChar(cGet4))

	EndIf

	If nTipo == "2"

		cGet4 := Alltrim(cValToChar(cGet4))

		//Valida código IBGE da cidade e UF.
		If Empty(cGet4)
			MsgStop("É necessário informar o código do município.","Função telaGen4(ADLOG057P)")
			RestArea(aArea)
			Return aRetorno
		
		ElseIf Empty(cGet5)
			MsgStop("É necessário informar a UF do município.","Função telaGen4(ADLOG057P)")
			RestArea(aArea)
			Return aRetorno
		
		EndIf

		cUF := codIBGEEst(cGet5,"Função telaGen4(ADLOG057P)")

		//Valida retorno da função codIBGEEst.
		If Empty(cUF)
			RestArea(aArea)
			Return aRetorno
		
		EndIf

	EndIf
	
	//
	Aadd(aRetorno,{cGet1,cGet2,cGet3,cUF + cGet4})
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} locPad  
	Obtém o código IBGE de Várzea Paulista. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 04/06/2019
	@version 01
	/*/
Static Function locPad()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cLocais	:= GetMv("MV_#CTELOC")
	Local aLocais	:= {}
	
	//
	aLocais	:= StrTokarr(cLocais,"|")

	//Valida retorno da função Strtokarr.
	If Len(aLocais) <> 3
		MsgStop("Não foi possível recuperar os códigos do IBGE das cidades de emissão do CT-e, início e término do itinerário do veículo." + Chr(13) + Chr(10) +;
		"Por favor, verifique a MV_#CTELOC e se está sendo utilizado o separado '|' .","Função locPad(ADLOG057P)")
		logZBE("FUNCAO locPad: NA RECUPEROU CODIGO IBGE DAS CIDADES MV MV_#CTELOC")
		aLocais := {}
		Return aLocais

	EndIf
	
	//
	RestArea(aArea)

Return aLocais
/*/{Protheus.doc} logZBE 
	Gera log na tabela ZBE. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	/*/
Static Function logZBE(cMensagem,cMemo)

	//Variáveis.	
	Local aArea	:= GetArea()

	Default cMensagem	:= ""
	Default cMemo 		:= ""

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With Date()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_LOGMEM		With cMemo
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG057P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} getPorEm 
	Retorna o percentual a ser aplicado sobre o valor de frete. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 12/12/2019
	@version 01
	/*/
Static Function getPorEm(cTpVa)

	//Variáveis.
	Local aArea	:= GetArea()
	Local nTpVa := Val(cValToChar(cTpVa))
	Local aPorc := Separa(cValToChar(GetMv("MV_#CTEPOR")),"/",.T.)
	Local nPorc := 0

	//
	If nTpVa > 0 .And. Len(aPorc) >= nTpVa
		nPorc := Val(cValToChar(aPorc[nTpVa]))

	EndIf

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - getPorEm - nPorc " + cValToChar(nPorc) )
	
	//
	RestArea(aArea)

Return nPorc
/*/{Protheus.doc} gerCioL
	Gera CIOT em lote.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
// Static Function gerCioL()
		
//	//Variáveis.	
// 	Local aArea	 := GetArea()
// 	Local i		 := 1
	
// 	//
// 	If ! MsgYesNo("Deseja emitir CIOT em lote?","Função gerCioL(ADLOG057P)")
// 		RestArea(aArea)
// 		Return Nil
		
// 	EndIf
	
// 	//
// 	carInter1()
	
// 	//
// 	For i := 1 To Len(oCargas:aCols)
	
// 		//
// 		If Empty( Alltrim(oCargas:aCols[i,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCIO" })]) )
			
// 			//
// 			oCargas:GoTo(i) 
			
// 			Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerCioL - gerando CIOT para roteiro " + Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRROT" })])) )
// 			gerCIOT(aHCr,oCargas,.T.)
		
// 		EndIf
	
// 	Next i
	
// 	//
// 	carInter1()
	
// 	//
// 	If nPosCarga > 0
// 		oCargas:GoTo(nPosCarga)
		
// 	EndIf
	
// 	//
// 	oCargas:Refresh()

// 	//
// 	RestArea(aArea)

// Return Nil
/*/{Protheus.doc} gerCIOT
	Gera CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
// Static Function gerCIOT(aHCr,oCargas,lLote)
	
//	//Variáveis.
// 	Local aArea		:= GetArea()
// 	Local cDtEntr	:= ""
// 	Local cRoteiro	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRROT"  })]))
// 	Local cCiot		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRCIO"  })]))
// 	Local cVlrFrt	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRVALOR"})]))
// 	Local cCTE		:= ""
// 	Local aTransp	:= {}
// 	Local aMotorista:= {}
// 	Local aVeiculo	:= {}
// 	Local aReboque	:= {}
// 	Local aPropVec	:= {}
// 	//Local lSelectCTE:= .F.
// 	Local cTranCv	:= ""
// 	Local cLjCv		:= ""
// 	//Local nAux		:= 1
// 	Local aNotas	:= {}
// 	Local aPropReb	:= {}
// 	//Local aCTE		:= {}
// 	Local cCTECompl	:= ""
// 	Local cSCTECompl:= ""
	
// 	//
// 	Private cCodZFA		:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRZFA" })]))
// 	Private cCodOcorr	:= Alltrim(cValToChar(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CROCO" })]))
// 	Private cCodCrg  	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_CARGA")))
// 	Private cLoja 		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_LJPPAG")))
// 	Private cVeiculo 	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_VEICPG")))
// 	Private cTransp 	:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_TRANPA")))
// 	Private cNmT		:= Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_NMTRAN")))
// 	Private cPlcCv		:= ""//Alltrim(cValToChar(Posicione("ZFA",13,FWxFilial("ZFA") + cCodZFA, "ZFA_PLCCAV")))
// 	Private cMotorista 	:= ""
	
// 	Default lLote		:= .F.
	
// 	//
// 	If Empty(cRoteiro)
// 		RestArea(aArea)
// 		Return Nil
			
// 	EndIf
	
// 	//
// 	cDtEntr	:= DToS(oCargas:aCols[oCargas:nAt,Ascan(aHCr,{|x| AllTrim(x[2]) == "CRDTE" })])
	
// 	//
// 	If ! Empty(cCiot)
// 		MsgStop("Já há CIOT emitido para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função gerCIOT(ADLOG057P)")
// 		RestArea(aArea)
// 		Return Nil
			
// 	EndIf
	
// 	//
// 	If ! lLote
// 		If ! MsgYesNo("Deseja emitir CIOT para o roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + "?","Função gerCIOT(ADLOG057P)")
// 			RestArea(aArea)
// 			Return Nil
			
// 		EndIf

// 	EndIf

// 	//Recupera dados da transportadora.
// 	aTransp := ddTransp(cTransp,cLoja)
// 	If Len(aTransp) <= 0
// 		RestArea(aArea)
// 		Return .F.

// 	EndIf
	
// 	//Everson - 01/07/2019. Chamado 044314.
// 	//Recupera dados do veículo e reboque.
// 	If ! Empty(cPlcCv)
		
// 		//
// 		aVeiculo := ddVeiculo(cPlcCv,2)
// 		aReboque := ddVeiculo(cVeiculo)

// 		//
// 		cTranCv	 := Alltrim(aVeiculo[1][9])
// 		cLjCv	 := Alltrim(aVeiculo[1][10])

// 		//
// 		aPropVec := dadosProp(cTranCv,cLjCv)
// 		aPropReb := dadosProp(cTransp,cLoja)
		
// 	Else

// 		//
// 		aVeiculo := ddVeiculo(cVeiculo,2)
// 		aPropVec := dadosProp(cTransp,cLoja)
	
// 	EndIf

// 	//
// 	cMotorista := Alltrim(aVeiculo[1][11])
// 	If Empty(cMotorista)
// 		MsgStop("Não foi possível recuperar o código do motorista vinculado ao veículo " + cVeiculo + ".","Função geraCIOT(ADLOG057P)")
// 		logZBE("FUNCAO geraCIOT: NAO FOI POSSIVEL RECUPERAR O CODIGO DO MOTORISTA VINCULADO A CARGA " + cVeiculo)
// 		RestArea(aArea)
// 		Return .F.

// 	EndIf

// 	//
// 	aMotorista := dadosMot(cMotorista)
// 	If Len(aMotorista) <= 0
// 		RestArea(aArea)
// 		Return .F.

// 	EndIf
		
// 	//
// 	aNotas := obtNF(cRoteiro,cDtEntr,,,,cCTE)
// 	If Len(aNotas) <= 0
// 		MsgStop("Não foi possível recuperar as notas fiscais referentes ao CT-e " + cCTECompl + "/" + cSCTECompl + ".","Função gerCIOT(ADLOG057P)")
// 		logZBE("FUNCAO gerCIOT: NAO FOI POSSIVEL RECUPERAR AS NOTAS FISCAIS REFERENTES AO CT-E " + cCTECompl + "/" + cSCTECompl)			
// 		RestArea(aArea)
// 		Return Nil

// 	EndIf

// 	//
// 	MsAguarde({|| geraCIOT(cCTE,aTransp,aMotorista,aVeiculo,aPropVec,aReboque,aPropReb,aNotas,;
// 							cRoteiro,cDtEntr,cCTECompl,cSCTECompl,cVlrFrt) },"Aguarde...","Emitindo CIOT do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) ,.F.)

// 	//
// 	carInter1("1")

// 	//
// 	RestArea(aArea)
	
// Return Nil
/*/{Protheus.doc} gerCIOT
	Gerar CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
// Static Function geraCIOT(cCTE,aTransp,aMotorista,aVeiculo,aPropVec,aReboque,aPropReb,aNotas,;
//                          cRoteiro,cDtEntr,cCTECompl,cSCTECompl,cVlrFrt)

//	//Variáveis.
// 	Local aArea			:= GetArea()
// 	Local cXml			:= ""
// 	Local cCabec		:= obtCabec()
// 	Local aCabec		:= {}
// 	Local oRestClient	:= Nil
// 	Local cSeq			:= ""
// 	//Local cNumRef		:= ""
// 	//Local cCodNCM		:= ""
// 	Local cTpCrg		:= ""
// 	Local cDist			:= ""
// 	//Local cEmissTp		:= "N"
// 	Local cSerie		:= ""
// 	Local cNF			:= ""
// 	Local aDados		:= {}
// 	Local cXmlNF		:= ""
// 	Local cXml64		:= ""
// 	Local oXML 			:= Nil
// 	Local xRet			:= Nil
// 	Local aDiaFim		:= {} //Everson - 02/03/2020. Chamado 053926.
// 	Local cCond			:= "" //Everson - 02/03/2020. Chamado 053926.
// 	Local aCond			:= {} //Everson - 02/03/2020. Chamado 053926.
// 	Local aVec 			:= {} //Everson - 02/03/2020. Chamado 053926.
// 	Local cDtPag		:= "" //Everson - 02/03/2020. Chamado 053926.
// 	Local cDesemp		:= "" //Everson - 02/03/2020. Chamado 053926.
// 	Local aRet 			:= {} //Everson - 02/03/2020. Chamado 053926.

// 	//Everson - 24/01/2020. Chamado 054941.
// 	If ! chkBloqueio(cCodZFA)
// 		RestArea(aArea)
// 		Return .F.

// 	EndIf

// 	//
// 	aDiaFim := Static Call(ADLOG040P,getDiasF,Val(cTpVa)) //Everson - 02/03/2020. Chamado 053926.
// 	aCond	:= Static Call(ADLOG040P,getConPg,Val(cTpVa)) //Everson - 02/03/2020. Chamado 053926.

// 	//
// 	//cCodNCM := obtCodNCM(cCTE)

// 	//
// 	cTpCrg	:= obtCodCrg(cRoteiro,cDtEntr,cTpVa)

// 	//
// 	cSeq 	:= seqZFK(cRoteiro,cDtEntr,"3")

// 	//
// 	cDist	:= getDist(cRoteiro,cDtEntr,cTpVa,cCodZFA)

// 	//
// 	//cNumRef	:= gerRefCIO(cRoteiro,cDtEntr,cSeq,cEmissTp,cTpVa)

// 	//Everson - 02/03/2020. Chamado 053926.
// 	If Day(SToD(cDtEntr)) >= Val(aDiaFim[1]) .And. Day(SToD(cDtEntr)) <= Val(aDiaFim[2])
// 		cCond := aCond[1]

// 	Else
// 		cCond := aCond[2]

// 	EndIf
// 	//

// 	//Everson - 02/03/2020. Chamado 053926.
// 	aVec   := Condicao(Val(cVlrFrt),cCond,0,SToD(cDtEntr),0)
// 	cDtPag := DToS(aVec[1][1])

// 	//Everson - 02/03/2020. Chamado 053926.
// 	cDesemp := getDesemp(Val(cTpVa))

// 	//
// 	cXml := ""
// 	cXMl += "<envCiot>" + CRLF

// 		//
// 		cXMl += "<cnpjContratante>" + Alltrim(cValToChar(aTransp[1][3])) + "</cnpjContratante>" + CRLF
// 		cXMl += "<nrIeContratante>"	+ Alltrim(cValToChar(aTransp[1][4])) + "</nrIeContratante>" + CRLF
// 		cXMl += "<codTipoCarga>" 	+ cTpCrg + "</codTipoCarga>" + CRLF
// 		cXMl += "<altoDesempenho>"   + cDesemp + "</altoDesempenho>" + CRLF
// 		cXMl += "<destinacaoComercial>1</destinacaoComercial>" + CRLF
// 		cXMl += "<freteRetorno>0</freteRetorno>" + CRLF

// 		//
// 		cXMl += "<contratado>"
// 			cXMl += "<cnpjContratado>"  + Alltrim(cValToChar(aPropVec[1][1]))  + "</cnpjContratado>" + CRLF
// 			cXMl += "<ieContratado>"    + Alltrim(cValToChar(aPropVec[1][2]))  + "</ieContratado>" + CRLF
// 			cXMl += "<nrAgencia>"       + Alltrim(cValToChar(aPropVec[1][16])) + "</nrAgencia>" + CRLF
// 			cXMl += "<nrContaCorrente>" + Alltrim(cValToChar(aPropVec[1][17])) + "</nrContaCorrente>" + CRLF
// 			cXMl += "<codigoBanco>"     + Alltrim(cValToChar(aPropVec[1][15])) + "</codigoBanco>" + CRLF
// 			cXMl += "<tipoConta>0</tipoConta>" + CRLF
// 		cXMl += "</contratado>" + CRLF

// 		//Carrega variáveis (série e nota fiscal).
// 		cSerie	:= Alltrim(cValToChar(aNotas[Len(aNotas)][1]))
// 		cNF		:= Alltrim(cValToChar(aNotas[Len(aNotas)][2]))

// 		//
// 		aNotas := {}
// 		Aadd(aNotas,{cSerie,cNF})

// 		//Realiza pesquisa no banco de dados para recuperar o xml.
// 		aDados	:= obtStrXML(cSerie,cNF)

// 		//Verifica se a função obtStrXML retornou dados.
// 		If Len(aDados) == 0
// 			MsgStop("Não foi possível obter o XML da nota fiscal " + cNF + "/" + cSerie + ".","Função geraCIOT(ADLOG057P)")
// 			RestArea(aArea)
// 			Return .F.

// 		EndIf

// 		//Extrai a string xml.
// 		cXmlNF := Alltrim(cValToChar(aDados[1][2]))

// 		//XML da NF-e em array de bytes codificados em base64.
// 		cXml64 := Encode64(cXmlNF)

// 		//Salva encode64.
// 		//gravarTXT(cTexto,cNome,cExt,cPasta,lParam)
// 		gravarTXT(cXml64,"Encode64_NF_CIOT","txt",,.T.)

// 		//
// 		cXMl += "<nfe>" + CRLF
// 			cXMl += "<arquivoXML>" + cXml64 + "</arquivoXML>" + CRLF
// 		cXMl += "</nfe>" + CRLF

// 		//
// 		cXMl += "<viagem>" + CRLF
// 			cXMl += "<distancia>" + cDist   + "</distancia>" + CRLF
// 			cXMl += "<dataPrevista>" + Substr(cDtEntr,7,2) + "/" + Substr(cDtEntr,5,2) + "/" + Substr(cDtEntr,1,4) + "</dataPrevista>" + CRLF
// 			cXMl += "<tipoPagamento>0</tipoPagamento>" + CRLF
// 			cXMl += "<valores>" + CRLF
// 				cXMl += "<adiantamento>0</adiantamento>" + CRLF
// 				cXMl += "<quitacao>" + cVlrFrt + "</quitacao>" + CRLF
// 				cXMl += "<combustivel>0</combustivel>" + CRLF
// 				cXMl += "<pedagio>0</pedagio>" + CRLF
// 				cXMl += "<seguro>0</seguro>" + CRLF
// 			cXMl += "</valores>" + CRLF
// 		cXMl += "</viagem>" + CRLF

// 		//
// 		cXMl += "<pagamento>" + CRLF
// 			cXMl += "<data>" + Substr(cDtPag,7,2) + "/" + Substr(cDtPag,5,2) + "/" + Substr(cDtPag,1,4) + "</data>" + CRLF
// 			cXMl += "<valor>" + cVlrFrt + "</valor>" + CRLF
// 			cXMl += "<tipoCategoria>0</tipoCategoria>" + CRLF
// 		cXMl += "</pagamento>" + CRLF

// 		//Dados do veículo.
// 		cXMl += "<veiculo>" + CRLF
// 			cXMl += "<placa>" + Alltrim(cValToChar(aVeiculo[1][1])) + "</placa>" + CRLF
// 			cXMl += "<incluirAlterar>S</incluirAlterar>" + CRLF

// 			//
// 			If .T. //Alltrim(cValToChar(aVeiculo[1][1])) == "S"
// 				cXMl += "<anoFabricacao>"  + Alltrim(cValToChar(aVeiculo[1][12])) + "</anoFabricacao>" + CRLF
// 				cXMl += "<anoModelo>" 	   + Alltrim(cValToChar(aVeiculo[1][13])) + "</anoModelo>" + CRLF
// 				cXMl += "<capcidadeKg>"    + Alltrim(cValToChar(aVeiculo[1][7]))  + "</capcidadeKg>" + CRLF
// 				cXMl += "<capacidadeM3>"   + Alltrim(cValToChar(aVeiculo[1][6]))  + "</capacidadeM3>" + CRLF //"    + Alltrim(cValToChar(aVeiculo[1][6]))  + "
// 				cXMl += "<chassi>" 		   + Alltrim(cValToChar(aVeiculo[1][14])) + "</chassi>" + CRLF
// 				cXMl += "<nrIbge>" 	       + Alltrim(cValToChar(aVeiculo[1][15])) + "</nrIbge>" + CRLF
// 				cXMl += "<cor>" 		   + Alltrim(cValToChar(aVeiculo[1][16])) + "</cor>" + CRLF
// 				cXMl += "<marca>" 		   + trtCEsp(Alltrim(cValToChar(aVeiculo[1][17]))) + "</marca>" + CRLF
// 				cXMl += "<modelo>" 		   + trtCEsp(Alltrim(cValToChar(aVeiculo[1][18]))) + "</modelo>" + CRLF
// 				cXMl += "<nrEixos>" 	   + Alltrim(cValToChar(aVeiculo[1][19])) + "</nrEixos>" + CRLF
// 				cXMl += "<nrRntrc>" 	   + Alltrim(cValToChar(aPropVec[1][4]))  + "</nrRntrc>" + CRLF
// 				cXMl += "<nrRenavam>" 	   + Alltrim(cValToChar(aVeiculo[1][20])) + "</nrRenavam>" + CRLF
// 				cXMl += "<tara>" 		   + Alltrim(cValToChar(aVeiculo[1][5]))  + "</tara>" + CRLF
// 				cXMl += "<tipoCarroceria>" + Alltrim(cValToChar(aVeiculo[1][3]))  + "</tipoCarroceria>" + CRLF
// 				cXMl += "<tipoRodado>"     + Alltrim(cValToChar(aVeiculo[1][2]))  + "</tipoRodado>" + CRLF

// 			EndIf 

// 			//Dados do proprietário do veículo.
// 			cXMl += "<proprietario>" + CRLF
// 			cXMl += "<cnpjCpf>" + Alltrim(cValToChar(aPropVec[1][1])) + "</cnpjCpf>" + CRLF
// 			cXMl += "<incluirAlterar>S</incluirAlterar>" + CRLF

// 			//
// 			If .T. //Alltrim(cValToChar(aPropVec[1][1])) == "S"
// 				cXMl += "<bairro>" 	    + trtCEsp(Alltrim(cValToChar(aPropVec[1][11]))) + "</bairro>" + CRLF
// 				cXMl += "<cep>"    	    + Alltrim(cValToChar(aPropVec[1][7]))  + "</cep>" + CRLF
// 				cXMl += "<nrIbge>" 	    + Alltrim(cValToChar(aPropVec[1][8]))  + "</nrIbge>" + CRLF
// 				cXMl += "<rua>"         + trtCEsp(Alltrim(cValToChar(aPropVec[1][9])))  + "</rua>" + CRLF
// 				cXMl += "<numero>" 	    + Alltrim(cValToChar(aPropVec[1][10])) + "</numero>" + CRLF
// 				cXMl += "<complemento>" + trtCEsp(Alltrim(cValToChar(aPropVec[1][12]))) + "</complemento>" + CRLF
// 				cXMl += "<nrRntrc>" 	+ Alltrim(cValToChar(aPropVec[1][4]))  + "</nrRntrc>" + CRLF
// 				cXMl += "<razaoSocial>" + trtCEsp(Alltrim(cValToChar(aPropVec[1][3])))  + "</razaoSocial>" + CRLF
// 				cXMl += "<telefone>" 	+ Alltrim(cValToChar(aPropVec[1][13])) + "</telefone>" + CRLF
// 				cXMl += "<celular>" 	+ Alltrim(cValToChar(aPropVec[1][14])) + "</celular>" + CRLF

// 			EndIf 

// 			cXMl += "</proprietario>" + CRLF

// 		cXMl += "</veiculo>" + CRLF


// 		//Dados do reboque.
// 		If Len(aReboque) > 0 .And. Len(aPropReb) > 0

// 			//
// 			cXMl += "<veiculo>" + CRLF
// 				cXMl += "<placa>" + Alltrim(cValToChar(aReboque[1][1])) + "</placa>" + CRLF
// 				cXMl += "<incluirAlterar>S</incluirAlterar>" + CRLF

// 				//
// 				If Alltrim(cValToChar(aReboque[1][1])) == "S"
// 					cXMl += "<tipoRodado>"     + Alltrim(cValToChar(aReboque[1][2]))  + "</tipoRodado>" + CRLF
// 					cXMl += "<tipoCarroceria>" + Alltrim(cValToChar(aReboque[1][3]))  + "</tipoCarroceria>" + CRLF
// 					cXMl += "<tara>" 		   + Alltrim(cValToChar(aReboque[1][5]))  + "</tara>" + CRLF
// 					cXMl += "<capacidadeM3>"   + Alltrim(cValToChar(aReboque[1][6]))  + "</capacidadeM3>" + CRLF
// 					cXMl += "<capcidadeKg>"    + Alltrim(cValToChar(aReboque[1][7]))  + "</capcidadeKg>" + CRLF
// 					cXMl += "<anoFabricacao>"  + Alltrim(cValToChar(aReboque[1][12])) + "</anoFabricacao>" + CRLF
// 					cXMl += "<anoModelo>" 	   + Alltrim(cValToChar(aReboque[1][13])) + "</anoModelo>" + CRLF
// 					cXMl += "<chassi>" 		   + Alltrim(cValToChar(aReboque[1][14])) + "</chassi>" + CRLF
// 					cXMl += "<nrIbge>" 	       + Alltrim(cValToChar(aPropVec[1][15])) + "</nrIbge>" + CRLF
// 					cXMl += "<cor>" 		   + trtCEsp(Alltrim(cValToChar(aReboque[1][16]))) + "</cor>" + CRLF
// 					cXMl += "<marca>" 		   + trtCEsp(Alltrim(cValToChar(aReboque[1][17]))) + "</marca>" + CRLF
// 					cXMl += "<modelo>" 		   + trtCEsp(Alltrim(cValToChar(aReboque[1][18]))) + "</modelo>" + CRLF
// 					cXMl += "<nrEixos>" 	   + Alltrim(cValToChar(aReboque[1][19])) + "</nrEixos>" + CRLF
// 					cXMl += "<nrRntrc>" 	   + Alltrim(cValToChar(aPropVec[1][4]))  + "</nrRntrc>" + CRLF
// 					cXMl += "<nrRenavam>" 	   + Alltrim(cValToChar(aReboque[1][20])) + "</nrRenavam>" + CRLF

// 				EndIf 

// 				//Dados do proprietário do veículo.
// 				cXMl += "<proprietario>" + CRLF
// 				cXMl += "<cnpjCpf>" + Alltrim(cValToChar(aPropReb[1][1])) + "</cnpjCpf>" + CRLF
// 				cXMl += "<incluirAlterar>S</incluirAlterar>" + CRLF

// 				//
// 				If Alltrim(cValToChar(aPropReb[1][1])) == "S"
// 					cXMl += "<razaoSocial>" + trtCEsp(Alltrim(cValToChar(aPropReb[1][3])))  + "</razaoSocial>" + CRLF
// 					cXMl += "<nrRntrc>" 	+ Alltrim(cValToChar(aPropReb[1][4]))  + "</nrRntrc>" + CRLF
// 					cXMl += "<cep>"    	    + Alltrim(cValToChar(aPropReb[1][7]))  + "</cep>" + CRLF
// 					cXMl += "<nrIbge>" 	    + Alltrim(cValToChar(aPropReb[1][8]))  + "</nrIbge>" + CRLF
// 					cXMl += "<rua>"         + trtCEsp(Alltrim(cValToChar(aPropReb[1][9])))  + "</rua>" + CRLF
// 					cXMl += "<numero>" 	    + Alltrim(cValToChar(aPropReb[1][10])) + "</numero>" + CRLF
// 					cXMl += "<bairro>" 	    + trtCEsp(Alltrim(cValToChar(aPropReb[1][11]))) + "</bairro>" + CRLF
// 					cXMl += "<complemento>" + trtCEsp(Alltrim(cValToChar(aPropReb[1][12]))) + "</complemento>" + CRLF
// 					cXMl += "<telefone>" 	+ Alltrim(cValToChar(aPropReb[1][13])) + "</telefone>" + CRLF
// 					cXMl += "<celular>" 	+ Alltrim(cValToChar(aPropReb[1][14])) + "</celular>" + CRLF

// 				EndIf 

// 				cXMl += "</proprietario>" + CRLF

// 			cXMl += "</veiculo>" + CRLF

// 		EndIf

// 		//Dados do motorista.
// 		cXMl += "<motorista>" + CRLF
// 			cXMl += "<cpf>" + Alltrim(cValToChar(aMotorista[1][2])) + "</cpf>" + CRLF
// 			cXMl += "<incluirAlterar>S</incluirAlterar>" + CRLF

// 			//
// 			If .T. //Alltrim(cValToChar(aMotorista[1][2])) == "S"
// 				cXMl += "<cnh>"				+ Alltrim(cValToChar(aMotorista[1][3]))  + "</cnh>" + CRLF
// 				cXMl += "<dataNascimento>"	+ Alltrim(cValToChar(aMotorista[1][4]))  + "</dataNascimento>" + CRLF
// 				cXMl += "<cep>" 			+ Alltrim(cValToChar(aMotorista[1][10])) + "</cep>" + CRLF
// 				cXMl += "<nrIbgeMunicipio >"+ Alltrim(cValToChar(aMotorista[1][5]))  + "</nrIbgeMunicipio>" + CRLF
// 				cXMl += "<rua>" 			+ trtCEsp(Alltrim(cValToChar(aMotorista[1][6])))  + "</rua>" + CRLF
// 				cXMl += "<numero>" 			+ Alltrim(cValToChar(aMotorista[1][7]))  + "</numero>" + CRLF
// 				cXMl += "<bairro>" 			+ Alltrim(cValToChar(aMotorista[1][8]))  + "</bairro>" + CRLF
// 				cXMl += "<complemento>" 	+ trtCEsp(Alltrim(cValToChar(aMotorista[1][9])))	 + "</complemento>" + CRLF
// 				cXMl += "<nome>"			+ trtCEsp(Alltrim(cValToChar(aMotorista[1][1])))  + "</nome>" + CRLF
// 				cXMl += "<celular>" 		+ Alltrim(cValToChar(aMotorista[1][11])) + "</celular>" + CRLF
// 				cXMl += "<telefone>" 		+ Alltrim(cValToChar(aMotorista[1][12])) + "</telefone>" + CRLF

// 			EndIf 

// 		cXMl += "</motorista>" + CRLF

// 	cXMl += "</envCiot>" + CRLF
	
// 	//Adiciona cabeçalho ao xml.
// 	cXml := cCabec + CRLF + cXml

// 	//Everson - 17/02/2020. Chamado 054941.
// 	oXML := TXmlManager():New()
// 	xRet := oXML:Parse( cXml )
//   	If  xRet == .F.
// 		MsgStop("Ocorreu erro ao fazer o parser do XML." + oXML:Error() ,"Função geraCIOT(ADLOG057P)")
// 		RestArea(aArea)
//     	Return Nil 

//   	EndIf

// 	//Salva arquivo que está sendo enviado.
// 	gravarTXT(cXml,"Env_CIOT","xml",,.T.)

// 	//
// 	cUrl := Lower(Alltrim(GetMv("MV_#ENVCIO")))

// 	//Gera o cabeçalho para função HttpPost.
// 	Aadd(aCabec,'Content-Type: Text/plain')

// 	//Cria objeto FWRest.
// 	oRestClient := FWRest():New(cUrl)
// 	oRestClient:nTimeOut := 120

// 	//Atribui parâmetro post.
// 	oRestClient:SetPostParams(cXml)

// 	//Atribui path.
// 	oRestClient:setPath("")
// 	varinfo("cXml",cXml)

// 	//
// 	logZBE("Geração de CIOT " + cValToChar(cRoteiro) + " " + cValToChar(cDtEntr) ,cXml )

// 	//Executa consulta web service.
// 	If oRestClient:Post(aCabec)
// 		cRetPost := oRestClient:GetResult() //Retorno 200 ou 201.
// 		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerCIOT - cRetPost " + cValToChar(cRetPost) )
		
// 	Else
// 		blqReg(cCodZFA) //Everson - 24/01/2020. Chamado 054941.
// 		cErroWS := oRestClient:GetLastError()//Retorno com erro.
// 		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - gerCIOT - cErroWS " + cValToChar(cErroWS) )
// 		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS + Iif(Empty(cErroWS),"Possível erro de certificado SSL/TLS","") ,"Função gerCIOT(ADLOG057P)")
// 		logZBE("FUNCAO enviarXML: gerCIOT WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS + Iif(Empty(cErroWS)," Possível erro de certificado SSL/TLS",""),cXml)
// 		Final()

// 	Endif

// 	//Salva retorno do web service.
// 	gravarTXT(cRetPost,"Ret_CIOT","xml",,.T.)

// 	//Valida o retorno.
// 	aXml := geraObjXML(cRetPost)
// 	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
// 		Return .F.

// 	EndIf

// 	//Atribui o objeto à variável oXml.
// 	oXml := aXml[1][2]
	
// 	//      
// 	aRet := obtRet(11,oXml,,,,cRoteiro,,aNotas,cSeq,,,,,cDtEntr,,cCTECompl,cSCTECompl,,,,)

// 	//
// 	If ValType(aRet) <> "A" .Or. Len(aRet) <= 0
// 		RestArea(aArea)
// 		Return .F.

// 	EndIf

// 	//
// 	FreeObj(oRestClient) //Everson - 05/05/2021.

// 	//
// 	RestArea(aArea)

// Return .T.
/*/{Protheus.doc} trtCEsp
	(long_description)
	@type  Static Function
	@author Everson
	@since 17/02/2020
	@version 01
	/*/
// Static Function trtCEsp(cTexto)

//	//Variáveis.
// 	Local aArea := GetArea()

// 	//
// 	cTexto := StrTran(cTexto,"&","&amp;")
// 	cTexto := StrTran(cTexto,'"',"&quot;")
// 	cTexto := StrTran(cTexto,"'","&apos;")
// 	cTexto := StrTran(cTexto,"<","&lt;")
// 	cTexto := StrTran(cTexto,">","&gt;")

// 	//
// 	RestArea(aArea)

// Return cTexto
/*/{Protheus.doc} retEnvCI
	Trata retorno da emissão de CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function retEnvCI(oXml,cRoteiro,cDtEntr,cSeq,cCTECompl,cSCTECompl,aNotas)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local lRet			:= .F.
	Local aRet			:= {}
	Local lImport		:= .F.
	Local nPosHash		:= 0
	Local cStringXML	:= ""
	Local cHash			:= ""
	Local cDtEmiss		:= ""

	//Valida argumentos.
	If 	Empty(cRoteiro)
		MsgStop("Função retEnvCI não recebeu o roteiro como argumento.","Função retEnvCI(ADLOG057P)")
		logZBE("FUNCAO retEnvCI: NAO RECEBEU cRoteiro COMO ARGUMENTO")
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_retConversaoCiot:_status:Text))
	logZBE("FUNCAO retEnvCI: RECEBEU STATUS " + cRetorno)

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_retConversaoCiot:_mensagem:Text))

	//Tratamento por status de retorno.
	If cRetorno == "100" ///Gerando
		lRet := .T.
		
	ElseIf cRetorno == "101"//Autorizado.
		lRet := .T.

	ElseIf cRetorno == "502" 
		cHash := Alltrim(cValToChar(oXml:_retConversaoCiot:_hash:Text))
		lImport := .T.
		lRet :=  .F.

	Else //Status de retorno inesperado.
		MsgStop("Status de retorno" + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem,"Função retEnvCI(ADLOG057P)")
		lRet :=  .F.

		//Salva o objeto em string.
		SAVE oXml XMLSTRING cStringXML

		//Busca o texto hash.
		nPosHash := At("<hash>",cStringXML)

		//Se achou o texto <hash> .
		If nPosHash > 0 .And. cRetorno == "999"
			cHash := Alltrim(cValToChar(oXml:_retConversaoCiot:_hash:Text))
			lImport := .T.

		EndIf

	EndIf

	//Salva registro na tabela ZFK.
	If lRet
		aRet := grvCIOHash(cRetorno,oXml,cRoteiro,cDtEntr,@cDtEmiss,cSeq,cCTECompl,cSCTECompl,aNotas)

	EndIf

	//Importa o CIOT.
	If lImport
		aRet := impCIO(cHash,oXml,cRoteiro,cStringXML,cDtEntr,cSeq,cCTECompl,cSCTECompl,aNotas)

	EndIf

	//Obtém hash do CIOT.
	If Len(aRet) > 0
		dowArq(aRet,3,cDtEntr)

	EndIf
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} grvCIOHash
	Grava dados do CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function grvCIOHash(cRetorno,oXml,cRoteiro,cDtEntr,cDtEmiss,cSeq,cCTECompl,cSCTECompl,aNotas)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lGrv			:= .T.
	Local cTpDoc		:= "3"
	local cHash			:= ""
	Local cNum  		:= ""
	Local cSer  		:= ""
	Local aRet			:= {}
	Local nValor		:= 0
	Local i				:= 1
	//Local cQuery		:= ""
	Local cStatus		:= ""
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	//Local aXmlCons		:= {}
	//Local oXmlCons		:= Nil
	//Local cRetoConst	:= ""	
	//Local aDadReb		:= {}	
	Local nVezesP		:= GetMv("MV_#NVPROC")
	Local nAux			:= 0
	Local cMsgOphos		:= ""
	Local cProtCan		:= ""
	Local cStringXML	:= ""

	//Verifica o status do retorno.
	If cRetorno <> "100" .And. cRetorno <> "101"
		RestArea(aArea)
		Return aRet
		
	EndIf
	
	//Remove espaços em branco.
	cRoteiro := Alltrim(cRoteiro)	
	
	//Válida argumentos da função.
	If Empty(cRoteiro)
		MsgStop("Função grvCIOHash não recebeu o argumento cRoteiro.","Função grvCIOHash(ADLOG057)")
		logZBE("FUNCAO grvCIOHash: NAO RECEBEU O ARGUMENTO cRoteiro")
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Obtém o número, série e hash do CT-e.
	cHash	  := Alltrim(cValToChar(oXml:_RetConversaoCiot:_hash:Text))
		
	//
	While cRetorno == "100" .And. nVezesP > nAux
		
		//Atribui valores as variáveis.
		//Executa função de status do CIOT.
		aStatus := statusCIOT(cHash)
		
		//
		If Len(aStatus) > 0
			
			//
			If Len(aStatus[1]) == 11
				cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
				cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))
				cProtEmis	:= Alltrim(cValToChar(aStatus[1][3]))
				cChaveAces	:= Alltrim(cValToChar(aStatus[1][4]))
				cRetorno    := Alltrim(cValToChar(aStatus[1][9]))
				cSer     	:= Alltrim(cValToChar(aStatus[1][8]))
				cNum    	:= Alltrim(cValToChar(aStatus[1][7]))
				cProtCan	:= Alltrim(cValToChar(aStatus[1][6]))
				cDtEmiss	:= Alltrim(cValToChar(aStatus[1][11]))
			
			EndIf
	
		EndIf
		
		//
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - grvCIOHash - cRetorno " + cValToChar(cRetorno) )
		Conout( DToC(Date()) + " " + Time() + " ADLOG057P - grvCIOHash - cNum " + cValToChar(cNum) )
		
		//Verifica o status do retorno.
		If cRetorno <> "100" .And. cRetorno <> "101" .And. cRetorno <> "502"
			consCIOT(cHash,1)
			aRet := {}
			RestArea(aArea)
			Return aRet
			
		EndIf	
		
		//
		Sleep(1000)
		nAux++	
	
	End
	
	//
	If cRetorno == "100"
		MsgInfo("CIOT." + Chr(13) + Chr(10) +;
		"Status: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMsgOphos + Chr(13) + Chr(10) + "Necessário verificar na consulta de CIOT o status do documento " + cProtEmis + ".","Função grvMDFHash(ADLOG057P)")
	
	EndIf
	
	//
	If cRetorno == "101"
	
		//
		For i := 1 To Len(aNotas)

			//Grava dados na tabela ZFK.
			grvZFK(lGrv,cTpDoc,cRoteiro,cSeq,cTransp,cLoja,cVeiculo,cMotorista,aNotas[i][2],aNotas[i][1],cHash,cNum,cSer,nValor,;
				cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEntr,"N",cCodCrg,cProtCan,cCTECompl,cSCTECompl,,cDtEmiss,0)

					Aadd(aRet,{cRoteiro,cSeq,cTpDoc,aNotas[i][2],aNotas[i][1]})

		Next i

	ElseIf cRetorno == "502"

		//
		SAVE oXml XMLSTRING cStringXML

		//
		aRet := impCIO(cHash,oXml,cRoteiro,cStringXML,cDtEntr,cSeq,cCTECompl,cSCTECompl,aNotas)

	EndIf
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} impCIO
	Importa CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function impCIO(cHash,oXml,cRoteiro,cStringXML,cDtEntr,cSeq,cCTECompl,cSCTECompl,aNotas)
	
	//Variáveis.
	Local aArea			:= GetArea()
	Local cQuery		:= ""
	Local cDadosZFK		:= ""
	Local i				:= 0
	Local lGrv			:= .T.
	Local cTpDoc		:= "3"
	//Local aDadReb		:= {}
	Local cNota			:= ""
	Local cSerie		:= ""
	Local aStatus		:= {}
	Local cStatus		:= ""
	Local cMsgOphos 	:= ""
	Local cProtEmis 	:= ""
	Local cChaveAces	:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	//Local cValor		:= ""
	Local nValor		:= 0
	Local cEmissTp		:= "N"
	//Local cRetorno		:= ""
	Local cProtCan		:= ""
	Local cDtEmiss		:= ""
	Local aRet			:= {}

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - impCIO - cHash/cRoteiro " + cHash + " / " +  cRoteiro )

	//Remove espaços em branco.
	cHash 		:= Alltrim(cValToChar(cHash))
	cRoteiro	:= Alltrim(cValToChar(cRoteiro))

	//Valida o hash.
	If Empty(cHash)
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Valida se o documento já não está lançado no sistema.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFK_ROTEIR + '-' + ZFK_SEQENV + '-' + ZFK_HASH  AS ZFK_HASH " 
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " AS ZFK " 
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL =    '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_HASH =  '" + cHash + "' "  
	cQuery += " AND ZFK_TPDOC = '3' " //CIOT.
	cQuery += " AND ZFK_TPCARG = '" + cTpVa + "' "
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - impCIO - cQuery " + cQuery )
	
	//
	If Select("CIOT_EMITIDO") > 0
		CIOT_EMITIDO->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "CIOT_EMITIDO"
	DbSelectArea("CIOT_EMITIDO")
		cDadosZFK := Alltrim(cValToChar(CIOT_EMITIDO->ZFK_HASH))
	CIOT_EMITIDO->(DbCloseArea())

	//Valida se não há o registro na tabela ZFK.
	If ! Empty(cDadosZFK)
		logZBE("FUNCAO impCIO: JA HA REGISTRO NA TABELA ZFK PARA A CARGA/SEQUENCIA " + cDadosZFK + "-" + DToC(SToD(cDtEntr)) )
		RestArea(aArea)
		Return aRet

	EndIf
	
	//Obtém status.
	aStatus := statusCIOT(cHash)	

	//Valida o retorno da função statusCIOT.
	If Len(aStatus) <= 0
		MsgStop("Não foi possível obter o status do CIOT.","Função impCIO(ADLOG057P)")
		RestArea(aArea)
		Return aRet

	EndIF

	//Valida o retorno da função statusMDFE.
	If Len(aStatus[1]) <> 11
		MsgStop("Não foi possível obter o status do CIOT.","Função impCIO(ADLOG057P)")
		RestArea(aArea)
		Return aRet

	EndIF
	
	//Status Protheus e mensagem do sistema Ophos.
	cStatus  	:= Alltrim(cValToChar(aStatus[1][1]))
	cMsgOphos	:= Alltrim(cValToChar(aStatus[1][2]))

	//Informações de encerramento.
	cProtEmis	:= Alltrim(cValToChar(aStatus[1][3]))
	cChaveAces	:= Alltrim(cValToChar(aStatus[1][4]))
	cProtEnce	:= Alltrim(cValToChar(aStatus[1][5]))
	cProtCan	:= Alltrim(cValToChar(aStatus[1][6]))
	cDtEmiss	:= Alltrim(cValToChar(aStatus[1][11]))
	cNumDoc     := Alltrim(cValToChar(aStatus[1][7]))

	//Itera sobre as notas.
	For i := 1 To Len(aNotas)

		//Recupera nota e série do roteiro.
		cNota    := Alltrim(cValToChar(aNotas[i][2]))
		cSerie   := Alltrim(cValToChar(aNotas[i][1]))
	
		//Grava dados na tabela ZFK.
		grvZFK(lGrv,cTpDoc,cRoteiro,cSeq,cTransp,cLoja,cVeiculo,cMotorista,cNota,cSerie,cHash,cNumDoc,;
		       cSerDoc,nValor,cStatus,cMsgOphos,cProtEmis,cChaveAces,cDtEntr,cEmissTp,cCodCrg,cProtCan,;
			   cCTECompl,cSCTECompl,,cDtEmiss,0)

		//Adiciona dados ao array de retorno.
		Aadd(aRet,{cRoteiro,cSeq,cTpDoc,cNota,cSerie})

	Next i
	
	//
	RestArea(aArea)

Return aRet
/*/{Protheus.doc} consCIOT
	Consultar CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function consCIOT(cHash,nTipo)

	//Variáveis.
	Local aArea			:= GetArea()
	Local cUrl  		:= GetMv("MV_#CONCIO")
	Local oRestClient	:= Nil
	Local cErroWS		:= ""
	Local cRetGet		:= ""
	Local aXml			:= {}
	Local lRet			:= .T.
	Local aRet			:= {}

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - consCIOT " )

	//Retira espacos em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Verifica se os argumentos estão em branco.
	If Empty(cHash)
		MsgStop("Função consCIOT não recebeu o hash.","Função consCIOT(ADLOG057P)")
		logZBE("FUNCAO consCIOT: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	ElseIf Empty(cUrl)
		MsgStop("Função consCIOT não obteve a URL para consulta do CIOT (MV MV_#CONCIO).","Função consCIOT(ADLOG057P)")
		logZBE("FUNCAO consCIOT: NAO OBTEVE A URL PARA CONSULTA DO CIOT MV MV_#CONCIO")
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	EndIf

	//Retira espacos em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl   	:= StrTran(cUrl,"{hash}",cHash)

	//Cria o objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui o path.
	oRestClient:setPath("")

	//Executa chamada no web service.
	If oRestClient:Get()
		cRetGet := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função consCIOT(ADLOG057P)")
		logZBE("FUNCAO consCIOT: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS)

		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf

	Endif

	//Salva retorno do web service.
	gravarTXT(cRetGet, cHash + "Ret_Consulta_CIOT","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetGet)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		
		//
		If nTipo == 2
			Aadd(aRet,{.F.,""})
			RestArea(aArea)
			Return aRet
			
		Else
			RestArea(aArea)
			Return .F.
			
		EndIf
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//
	If nTipo == 2
		Aadd(aRet,{.T.,oXml})
		RestArea(aArea)
		Return aRet
		
	EndIf

	//Verifica o status de retorno de geração do CIOT.
	lRet := obtRet(12,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} retCoCIO
	Trata retorno consulta CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function retCoCIO(oXml,cHash)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet			:= .T.
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	Local cChaveAc		:= ""
	Local cDataAut		:= ""
	Local cProtocolo	:= ""
	Local cStatus		:= ""
	//Local Update		:= ""
	Local cMsgOphos		:= ""
	//Local aStatus		:= {}
	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	Local cProtCance	:= ""
	Local cDataEnce		:= ""
	Local cProtEnce		:= ""
	Local cDataCanc		:= ""
	Local cProtCanc		:= ""
	Local cJustiCanc	:= ""
	
	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_RetConsultaCiot:_status:Text))

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_mensagem:Text))

	//Recupera mensagem da Ophos.
	cMsgOphos := cRetorno + "-" + cMensagem

	If cRetorno == "107"

		//Número e série do CIOT.
		cNumDoc 	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_numeroCiot:Text))
		cSerDoc		:= ""

		cChaveAc	:= ""
		cDataAut	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_data:Text))
		cProtocolo	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_protocolo:Text))
		cDataEnce	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Encerramento:_data:Text))
		cProtEnce	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Encerramento:_protocolo:Text))

		MsgInfo("Consulta CIOT."		+ Chr(13) + Chr(10) +;
		"Retorno: " 			+ cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " 			+ cMensagem + Chr(13) + Chr(10) +;
		"Número CIOT: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Data Autorização: " 	+ cDataAut + Chr(13) + Chr(10) +;
		"Protocolo: " 			+ cProtocolo + Chr(13) + Chr(10) +;
		"Data Encer.:" + cDataEnce + Chr(13) + Chr(10) +;
		"Protocolo Encer.:" + cProtEnce ,"Função retCoCIO(ADLOG057P)")

		lRet 	:=  .T.
		cStatus :=  "T"

	ElseIf cRetorno == "101"

		//Número e série do CIOT.
		cNumDoc 	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_numeroCiot:Text))
		cSerDoc		:= ""

		cChaveAc	:= ""
		cDataAut	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_data:Text))
		cProtocolo	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_protocolo:Text))

		MsgInfo("Consulta CIOT."		+ Chr(13) + Chr(10) +;
		"Retorno: " 			+ cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " 			+ cMensagem + Chr(13) + Chr(10) +;
		"Número CIOT: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Data Autorização: " 	+ cDataAut + Chr(13) + Chr(10) +;
		"Protocolo: " 			+ cProtocolo ,"Função retCoCIO(ADLOG057P)")

		lRet :=  .T.
		cStatus := "E"

	ElseIf cRetorno == "100"
		MsgInfo("Consulta CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem ,"Função retCoCIO(ADLOG057P)")

		lRet :=  .T.
		cStatus := "D"

	ElseIf cRetorno == "102"

		//Número e série do CIOT.
		cNumDoc 	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_numeroCiot:Text))
		cSerDoc		:= ""

		cChaveAc	:= ""
		cDataAut	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_data:Text))
		cProtocolo	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_protocolo:Text))
		cDataCanc	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Cancelamento:_data:Text))
		cProtCanc	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Cancelamento:_protocolo:Text))
		cJustiCanc	:= ""

		MsgAlert("Consulta CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " 			  + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " 			+ cMensagem + Chr(13) + Chr(10) +;
		"Número CIOT: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Data Autorização: " 	+ cDataAut + Chr(13) + Chr(10) +;
		"Protocolo: " 			+ cProtocolo + Chr(13) + Chr(10) +;
		"Data Canc.:" + cDataCanc + Chr(13) + Chr(10) +;
		"Protocolo Canc.:" + cProtCanc + Chr(13) + Chr(10) +;
		"Just. Canc:" + cJustiCanc ,"Função retCoCIO(ADLOG057P)")

		lRet 	:=  .T.
		cStatus :=  "C"

	Else //Demais status.

		MsgStop("Consulta CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + Chr(13) + Chr(10) +;
		"Número CIOT: " 		+ cNumDoc + Chr(13) + Chr(10) +;
		"Série CIOT: " + cSerDoc ,"Função retCoCIO(ADLOG057P)")
		lRet :=  .F.
		cStatus := "N"

	EndIf

	//Executa função de status do CIOT.
	cStatus  	:= tlbStatus(cRetorno,2)
	cMsgOphos	:= cRetorno + "-" + cMensagem

	//Protocolo de emissão e chave de acesso.
	If cRetorno == "101" .Or. cRetorno == "102" .Or. cRetorno == "107"
		cProtEmis	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_protocolo:Text))

	EndIf

	//Protocolo de cancelamento.
	If cRetorno == "102"
		cProtCance	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Cancelamento:_protocolo:Text))
		
	EndIf
	
	//
	If cRetorno == "107"
		cProtEnce	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Encerramento:_protocolo:Text))
		
	EndIf
	
	//
	If ! Empty(cDataAut)
		cDataAut := Substr(cDataAut,1,10)
		cDataAut := StrTran(cDataAut,"-","")
		
	EndIf
	
	//
	lRet := updateCIOT(cNumDoc,cSerDoc,cStatus,cMsgOphos,cProtEmis,cProtCance,cChaveAces,cProtEnce,cHash,cDataAut)
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} updateCIOT
	Update CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function updateCIOT(cNumDoc,cSerDoc,cStatus,cMsgOphos,cProtEmis,cProtCance,cChaveAces,cProtEnce,cHash,cDataAut)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local Update	:= ""
	Local lRet 		:= .T.
	
	//Monta script sql.
	Update := "UPDATE " + RetSqlName("ZFK") + " SET " + Iif(Empty(cDataAut),""," ZFK_DTEMIS = '" + cDataAut + "', ") + " ZFK_NUMCIO = '" + cNumDoc + "', ZFK_SERDOC = '" + cSerDoc + "', ZFK_STATUS = '" + cStatus + "', ZFK_OPHOS ='" + cMsgOphos + "', " + ;
	" ZFK_PROTEM='" + cProtEmis + "', ZFK_PROTCA='" + cProtCance + "', ZFK_CHAVE='" + cChaveAces + "', ZFK_PROENC='" + cProtEnce + "' WHERE ZFK_HASH ='" + cHash + "' AND ZFK_TPDOC = '3'"

	//Atualiza status do CIOT.
	If TcSqlExec(Update) < 0
		MsgStop("Não foi possível atualizar o status do CIOT " + cNumDoc + "/" + cSerDoc + "." + Chr(13) + Chr(10) + "TCSQLError " + TCSQLError() ,"Função updateCIOT(ADLOG057P)")
		logZBE("FUNCAO updateCIOT: NAO FOI POSSIVEL ATUALIZAR O STATUS DO CIOT " + cNumDoc + "/" + cSerDoc + " ERRO " + TCSQLError())
		lRet := .F.

	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} pdfCIOdow
	Download PDF CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function pdfCIOdow(cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local cUrl		:= GetMv("MV_#PDFCIO")
	Local cCaminho 	:= ""
	Local cArq		:= cHash + "CIOT"

	//Remove espaços em branco.
	cHash 	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função pdfCIOdow não recebeu o hash do CIOT.","Função pdfCIOdow(ADLOG057P)")
		logZBE("FUNCAO pdfCIOdow: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("Função pdfCIOdow não obteve a URL para efetuar o download do arquivo pdf do CIOT (MV MV_#PDFCIO).","Função pdfCIOdow(ADLOG057P)")
		logZBE("FUNCAO pdfCIOdow: NAO OBTEVE A URL PARA EFETUAR O DOWNLOAD DO ARQUIVO PDF MV MV_#PDFCIO")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl := Strtran(cUrl,"{hash}",cHash)

	//Faz o download do arquivo.
	cCaminho := obtArquivo(cUrl,cArq,"pdf")

	//Verifica o retorno da função obtArquivo.
	If Empty(cCaminho)
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	//
	lRet := fVisualiza(cCaminho)
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} xmlCIOdow
	Download XML CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function xmlCIOdow(cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cUrl		:= GetMv("MV_#XMLCIO")
	Local cCaminho	:= ""
	Local cArq		:= cHash + "CIOT"

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("Função xmlCIOdow não recebeu o hash do CIOT.","Função xmlCIOdow(ADLOG057P)")
		logZBE("FUNCAO xmlCIOdow: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return Nil

	ElseIf Empty(cUrl)
		MsgStop("Função xmlCIOdow não obteve a URL para download do arquivo xml do CIOT (MV MV_#XMLCIO).","Função xmlCIOdow(ADLOG057P)")
		logZBE("FUNCAO xmlCIOdow: NAO OBTEVE A URL PARA EFETUAR O DOWNLOAD DO ARQUIVO XML MV MV_#XMLCIO")
		RestArea(aArea)
		Return Nil

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//Adiciona o hash à URL.
	cUrl 	:= StrTran(cUrl,"{hash}",cHash)

	//Faz o download do arquivo.
	cCaminho := obtArquivo(cUrl,cArq,"xml")

	//Verifica o retorno da função obtArquivo.
	If Empty(cCaminho)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	lRet := fVisualiza(cCaminho)
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} cancCIOT
	Cancelar CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function cancCIOT(cHash,cJust)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local cUrl   		:= GetMv("MV_#CANCIO")
	Local cXml			:= ""
	Local cCabec    	:= obtCabec()
	Local oRestClient	:= Nil
	Local aCabec		:= {}
	Local cRetPost		:= ""
	Local cErroWS		:= ""

	//Remove espaços em branco.
	cHash	:= Alltrim(cValToChar(cHash))
	cUrl  	:= Alltrim(cValToChar(cUrl))

	//Valida argumentos da função.
	If Empty(cHash)
		MsgStop("A função cancCIOT não recebeu o argumento cHash.","Função cancCIOT(ADLOG057P)")
		logZBE("FUNCAO cancCIOT: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cJust)
		MsgStop("A função cancCIOT não recebeu o argumento cJust.","Função cancCIOT(ADLOG057P)")
		logZBE("FUNCAO cancCIOT: NAO RECEBEU O ARGUMENTO cJust")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("A função cancCIOT não obteve a URL para cancelamento do MDF-e (MV MV_#CANCIO).","Função cancCIOT(ADLOG057P)")
		logZBE("FUNCAO cancCIOT: NAO OBTEVE A URL PARA CANCELAMENTO DO MDF-E MV MV_#CANCIO")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//
	cXml := ""
	cXml += "<EnvCancelamentoCiot>"
		cXml += "<hash>" + cHash + "</hash>"
		cXml += "<justificativa>" + cJust + "</justificativa>"
	cXml += "</EnvCancelamentoCiot>"
	
	//
	cXml := cCabec + cXml

	//Salva xml de envio.
	gravarTXT(cXml, cHash + "Env_Cancelar_CIOT","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui path.
	oRestClient:setPath("")

	//Atribui parâmetros.
	oRestClient:SetPostParams(cXml)

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função cancCIOT(ADLOG057P)")
		logZBE("FUNCAO cancCIOT: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cXml)
		Final()
		
	Endif

	//Salva retorno do web service.
	gravarTXT(cRetPost, cHash + "Ret_Cancelamento_CIOT","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetPost)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de cancelamento do CIOT.
	lRet := obtRet(14,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} retCCIO
	Trata retorno cancelamento CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function retCCIO(oXml,cHash)

	//Variáveis.
	Local aArea		:= GetArea()
	Local cRetorno	:= ""
	Local cMensagem	:= ""
	Local lRet		:= .F.

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_RetCancelamentoCiot:_status:Text))

	//Recupera a mensagem de retorno.
	cMensagem:= Alltrim(cValToChar(oXml:_RetCancelamentoCiot:_mensagem:Text))

	If cRetorno == "102" // Cancelado.

		MsgInfo("Cancelamento CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + ".","Função retCCIO")

		lRet :=  .T.

	Else //Demais status.

		MsgAlert("Cancelamento CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem + ".","Função retCCIO")
		lRet :=  .F.

	EndIf

	//Marcar documento como cancelado.
	If lRet
		lRet := cancDoc(cHash,"3")
		
	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} encCIOT
	Encerrar CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function encCIOT(cHash)

	//Variáveis.
	Local aArea			:= GetArea()
	Local lRet 			:= .T.
	Local cUrl			:= GetMv("MV_#ENCCIO")
	Local cCabec    	:= obtCabec()
	Local cXml			:= ""
	Local oRestClient	:= Nil
	Local cErroWS		:= ""
	Local cRetPost		:= ""
	Local aCabec		:= {}

	//Retira espacos em branco.
	cHash		:= Alltrim(cValToChar(cHash))
	cDateTime	:= Alltrim(cValToChar(cDateTime))

	//Verifica se os argumentos estão em branco.
	If Empty(cHash)
		MsgStop("Função encCIOT não recebeu o argumento hash.","Função encCIOT(ADLOG057P)")
		logZBE("FUNCAO encCIOT: NAO RECEBEU O ARGUMENTO cHash")
		RestArea(aArea)
		Return .F.

	ElseIf Empty(cUrl)
		MsgStop("Função encCIOT não obteve a URL para encerramento do CIOT (MV MV_#ENCCIO).","Função encCIOT(ADLOG057P)")
		logZBE("FUNCAO encCIOT: NAO OBTEVE A URL PARA ENCERRAMENTO DO CIOT MV MV_#ENCCIO")
		RestArea(aArea)
		Return .F.

	EndIf

	//Caracter em caixa baixa.
	cUrl := Lower(cUrl)

	//
	cXml := ""
	cXml += "<EnvEncerramentoCiot>"
		cXml += "<hash>" + cHash + "</hash>"
	cXml += "</EnvEncerramentoCiot>"

	//
	cXml := cCabec + cXml

	//
	Conout(cXml)
	Conout(cUrl)

	//Salva xml de envio.
	gravarTXT(cXml, cHash + "Env_Encerrar_CIOT","xml",,.T.)

	//Gera o cabeçalho para função HttpPost.
	Aadd(aCabec,'Content-Type: Text/plain')

	//Cria objeto FWRest.
	oRestClient := FWRest():New(cUrl)

	//Atribui path.
	oRestClient:setPath("")

	//Atribui parâmetros.
	oRestClient:SetPostParams(cXml)

	//Executa chamada no web service.
	If oRestClient:Post(aCabec)
		cRetPost := oRestClient:GetResult() //Retorno sem erro.
		
	Else
		cErroWS := oRestClient:GetLastError() //Retorno com erro.
		MsgStop("Web Service Ophos retornou o seguinte erro: " + Chr(13) + Chr(10) + cErroWS,"Função encCIOT(ADLOG057P)")
		logZBE("FUNCAO encCIOT: WEB SERVICE OPHOS RETORNOU ERRO " + cErroWS,cXml)
		Final()
		
	Endif

	//Salva retorno do web service.
	gravarTXT(cRetPost, cHash + "Ret_Encerrar_CIOT","xml",,.T.)

	//Valida o retorno.
	aXml := geraObjXML(cRetPost)
	If Alltrim(cValToChar(aXml[1][1])) == ".F." //Se for falso, não gerou o objeto xml.
		RestArea(aArea)
		Return .F.
		
	EndIf

	//Obtém o objeto xml.
	oXml := aXml[1][2]

	//Verifica o status de retorno de encerramento do CIOT.
	lRet := obtRet(13,oXml,,,cHash)

	//
	FreeObj(oRestClient) //Everson - 05/05/2021.

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} retEcCIO
	Trata retorno eEncerramento CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function retEcCIO(oXml,cHash)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local cRetorno	:= ""
	Local cMensagem	:= ""
	Local cRet		:= ""
	Local cXml		:= ""
	Local nPosDados	:= 0
	Local cNumDoc	:= ""
	Local cSerDoc	:= ""

	//Recupera o status de retorno do objeto xml.
	cRetorno := Alltrim(cValToChar(oXml:_RetEncerramentoCiot:_status:Text))

	//Transforma objeto XML em string XML.
	SAVE oXml XMLSTRING cXml

	//Verifica se há o retorno com dados do CIOT.
	nPosDados := At("<numero>",cXml)
	If nPosDados > 0
		cNumDoc := Alltrim(cValToChar(oXml:_RetEncerramentoCiot:_dadosCiot:_numero:Text))
		cSerDoc := ""

	EndIf
	
	//
	If 	cRetorno == "107" // Encerrado.
		cMensagem:= Alltrim(cValToChar(oXml:_RetEncerramentoCiot:_mensagem:Text))
		MsgInfo("Encerramento CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem  + Chr(13) + Chr(10) +;
		"Número CIOT: " + cNumDoc  + Chr(13) + Chr(10) +;
		"Série: " + cSerDoc,"Função retEcCIO(ADLOG057P)")

		cRet :=  .T.

	Else //Demais status.
		cMensagem:= Alltrim(cValToChar(oXml:_RetEncerramentoCiot:_mensagem:Text))
		MsgStop("Encerramento CIOT." + Chr(13) + Chr(10) +;
		"Retorno: " + cRetorno + Chr(13) + Chr(10) +;
		"Mensagem: " + cMensagem  + Chr(13) + Chr(10) +;
		"Número CIOT: " + cNumDoc  + Chr(13) + Chr(10) +;
		"Série: " + cSerDoc,"Função retEcCIO(ADLOG057P)")

		cRet :=  .F.

	EndIf

	//Flaga registros como terminados.
	If cRet
		lRet := encerraDoc(cHash,"3",oXml)
		
	EndIf
	
	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} statusCIOT
	Retorna status do CIOT.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
Static Function statusCIOT(cHash)

	//Variáveis.
	Local aArea			:= GetArea()
	Local aRetorno		:= {}
	Local oXml			:= Nil
	Local cRetorno		:= ""
	Local cMensagem		:= ""
	Local cMsgOphos		:= ""
	Local cStatus		:= ""
	Local aRetCons		:= {}

	Local cProtEmis		:= ""
	Local cChaveAces	:= ""
	Local cProtCance	:= ""
	Local cProtEnce 	:= ""
	Local cNumDoc		:= ""
	Local cSerDoc		:= ""
	Local cDtEmiss		:= ""

	//Remove espaços em branco.
	cHash := Alltrim(cValToChar(cHash))

	//Executa consulta do CIOT.
	aRetCons := consCIOT(cHash,2)

	//Valida retorno da função consCIOT.
	If ! aRetCons[1][1]
		Aadd(aRetorno,{"",""})
		RestArea(aArea)
		Return aRetorno
		
	EndIf

	//Recupera objeto xml.
	oXml := aRetCons[1][2]

	//Recupera retorno e mensagem Ophos.
	cRetorno  	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_status:Text))
	cMensagem 	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_mensagem:Text))
	cMsgOphos	:= cRetorno + "-" + cMensagem

	//Protocolo de emissão e chave de acesso.
	If cRetorno == "101" .Or. cRetorno == "102" .Or. cRetorno == "107"
		cProtEmis	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_Protocolo:Text))
		cChaveAces	:= ""
		cNumDoc		:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_NumeroCiot:Text))
		cSerDoc		:= ""
		cDtEmiss	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Autorizacao:_data:Text))
		cDtEmiss    := StrTran(Substr(cDtEmiss,1,10),"-","")
		
	EndIf

	//Protocolo de cancelamento.
	If cRetorno == "102"
		cProtCance	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Cancelamento:_protocolo:Text))
		
	EndIf
	
	//Protocolo de encerramento.
	If cRetorno == "107"
		cProtEnce 	:= Alltrim(cValToChar(oXml:_RetConsultaCiot:_Encerramento:_protocolo:Text))
		
	EndIf

	//Define o status do documento.
	cStatus := tlbStatus(cRetorno,2)
	
	//
	Aadd(aRetorno,{cStatus,cMsgOphos,cProtEmis,cChaveAces,cProtEnce,cProtCance,cNumDoc,cSerDoc,cRetorno,oXml,cDtEmiss})
	
	//
	RestArea(aArea)

Return aRetorno
/*/{Protheus.doc} gerRefCIO
	Monta número sequencial de envio. Chamado 054941.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
// Static Function gerRefCIO(cRoteiro,cDtEntr,cSeq,cEmissTp,cTpVa)
	
//	//Variáveis.
// 	Local aArea := GetArea()
// 	Local cRef  := ""

// 	//
// 	cRef := Alltrim(cEmpAnt) + Alltrim(cFilAnt) + Alltrim(cCodZFA)  + Alltrim(cEmissTp) + "-3-" + Alltrim(cSeq) + "-" + Alltrim(cTpVa)

// 	//
// 	RestArea(aArea)

// Return cRef
/*/{Protheus.doc} obtCodNCM
	Obtém código NCM.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
// Static Function obtCodNCM(cCTE)
	
//	//Variáveis.
// 	Local aArea := GetArea()
// 	Local cQuery:= ""
// 	Local cCod	:= ""

// 	//
// 	cQuery := ""
// 	cQuery += " SELECT " 
// 	cQuery += " TOP 1 D2_COD, B1_POSIPI, SUM(D2_QUANT) AS D2_QUANT " 
// 	cQuery += " FROM " 
// 	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
// 	cQuery += " INNER JOIN " 
// 	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
// 	cQuery += " ZFK_FILIAL = C5_FILIAL " 
// 	cQuery += " AND ZFK_PEDVEN = C5_NUM " 
// 	cQuery += " INNER JOIN " 
// 	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 ON " 
// 	cQuery += " C5_FILIAL = D2_FILIAL " 
// 	cQuery += " AND C5_NUM = D2_PEDIDO " 
// 	cQuery += " INNER JOIN " 
// 	cQuery += " SB1010 (NOLOCK) AS SB1 ON " 
// 	cQuery += " D2_COD = B1_COD " 
// 	cQuery += " WHERE " 
// 	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") + "' " 
// 	cQuery += " AND ZFK_CHAVE = '" + cCTE + "' " 
// 	cQuery += " AND ZFK_TPDOC = '1' " 
// 	cQuery += " AND ZFK_STATUS = '1' " 
// 	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
// 	cQuery += " GROUP BY D2_COD, B1_POSIPI " 
// 	cQuery += " ORDER BY D2_QUANT DESC " 

// 	//
// 	If Select("D_NCM") > 0
// 		D_NCM->(DbCloseArea())

// 	EndIf

// 	//
// 	TcQuery cQuery New Alias "D_NCM"
// 	DbSelectArea("D_NCM")
// 	D_NCM->(DbGoTop())
// 		cCod := Alltrim(cValToChar(D_NCM->B1_POSIPI))
// 	D_NCM->(DbCloseArea())

// 	//
// 	RestArea(aArea)

// Return cCod
/*/{Protheus.doc} obtCodCrg
	Obtém código da carga.
	@type  Static Function
	@author Everson
	@since 27/01/2020
	@version 01
	/*/
// Static Function obtCodCrg(cRoteiro,cDtEntr,cTpVa)

//	//Variáveis.
// 	Local aArea := GetArea()
// 	Local aCod 	:= Separa(GetMv("MV_#TPCRGC",,"3////"),"/",.T.)
// 	Local cCod	:= aCod[Val(cTpVa)]

// 	//
// 	Conout( DToC(Date()) + " " + Time() + " ADLOG057P - obtCodCrg - cCod " + cValToChar(cCod) )

// 	//
// 	RestArea(aArea)

// Return cCod
/*/{Protheus.doc} getDist
	Obtém distância do roteiro.
	@type  Static Function
	@author user
	@since 27/01/2020
	@version 01
	/*/
// Static Function getDist(cRoteiro,cDtEntr,cTpVa,cZFA)
	
//	//Variáveis.
// 	Local aArea := GetArea()
// 	Local cDist	:= "0"

// 	//
// 	DbSelectArea("ZFA")
// 	ZFA->(DbSetOrder(13))
// 	ZFA->(DbGoTop())

// 	//
// 	ZFA->(DbSeek( FWxFilial("ZFA") + cZFA ))
// 	cDist := Alltrim(cValToChar(ZFA->ZFA_KMTOT))

// 	//
// 	RestArea(aArea)

// Return cDist
/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author Everson
	@since 06/02/2020
	@version 01
	/*/
Static Function grCSV(oObj,aCabec)
	
	//Variáveis.
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local cArq  	:= "ROTEIROS_"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""

	//
	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o arquivo CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil

	EndIf

	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCSV(ADLOG057P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cLin := ""
	For i := 1 To Len(aCabec)

		//
		If ! Empty(Alltrim(cValToChar(aCabec[i][1])))
			cLin += cValToChar(aCabec[i][1]) + ";"

		EndIf

	Next i

	cLin += cEof

	For i := 1 To Len(oObj:aCols)

		For w := 1 To Len(aCabec)
			conout(Alltrim(cValToChar(aCabec[w][8])))
			//
			If Alltrim(cValToChar(aCabec[w][8])) == "N"
				cLin += Transform(Val(cValToChar(oObj:aCols[i][w])),"@E 999,999,999.99") + ";"

			ElseIf Alltrim(cValToChar(aCabec[w][8])) == "D"
				cLin += DToC(oObj:aCols[i][w]) + ";"

			ElseIf Alltrim(cValToChar(aCabec[w][8])) == "C"
				cLin += cValToChar(oObj:aCols[i][w]) + ";"

			EndIf

		Next w

		cLin += cEof

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

	Next i

	//Fecha o arquivo.
	FClose(nHdl)

	WinExec("Explorer.exe" + Space(1) + cDir )

	MsgInfo("Arquivo gerado.","Função grCSV(ADLOG057P)")

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} getDesemp
	Obtém o desempenho para geração do CIOT
	@type  Static Function
	@author Everson
	@since 02/03/2020
	@version 01
	/*/
// Static Function getDesemp(nTpCrg)
	
//	//Variáveis.
// 	Local aArea		:= GetArea()
// 	Local aDesemp	:= StrToKarr(Alltrim(GetMV("MV_#DSPCIO")),"/")
// 	Local cDesemp	:= aDesemp[nTpCrg]

// 	//
// 	RestArea(aArea)

// Return cDesemp
/*/{Protheus.doc} encCIOL
	Encerrar CIOT em lote.
	@type  Static Function
	@author Everson
	@since 06/03/2020
	@version 01
	/*/
// Static Function encCIOL()

// 	//Variáveis.
// 	Local aArea	 	:= GetArea()
// 	Local i		 	:= 1
// 	Local cHash	 	:= ""
// 	Local cDoc	 	:= ""
// 	Local cDateTime	:= ""
// 	Local cRoteiro	:= ""
// 	Local cDtEntr	:= ""
// 	Local cIBGE		:= ""
	
// 	//
// 	If Len(oPendCIO:aCols) <= 0 .Or. (  Len(oPendCIO:aCols) > 0 .And. Empty(Alltrim(cValToChar(oPendCIO:aCols[oPendCIO:nAt,Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRHASH" })]))) )
// 		MsgStop("Não há CIOT a ser encerrado.","Função encCIOL(ADLOG057P)")
// 		RestArea(aArea)
// 		Return Nil
		
// 	EndIf
	
// 	//
// 	If ! MsgYesNo("Será(ão) encerrado(s) " + cValToChar(Len(oPendCIO:aCols)) + " documento(s). Deseja prosseguir?","Função encCIOL(ADLOG057P)")
// 		RestArea(aArea)
// 		Return Nil
	
// 	EndIf
	
// 	//
// 	aRetEnc := telaGen4()
			
// 	//
// 	If Len(aRetEnc) > 0
// 		cDateTime 	:= Alltrim(cValToChar(aRetEnc[1][1])) + Alltrim(cValToChar(aRetEnc[1][2]))
	
// 	Else
// 		RestArea(aArea)
// 		Return Nil		
	
// 	EndIf
	
// 	//
// 	For i := 1 To Len(oPendCIO:aCols)
		
// 		//
// 		cDoc  	:= Alltrim(cValToChar(oPendCIO:aCols[i,Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRNUMDOC" })]))
// 		cHash 	:= Alltrim(cValToChar(oPendCIO:aCols[i,Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRHASH" })]))
// 		cRoteiro:= Alltrim(cValToChar(oPendCIO:aCols[i,Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRROT" })]))
// 		cDtEntr	:= DToS( oPendCIO:aCols[i,Ascan(aHDcCI,{|x| AllTrim(x[2]) == "CRDTE" })] )
		
// 		//
// 		aItinierario:= itinerario(cRoteiro,cDtEntr)//Recupera o itinerário do veículo.
		
// 		//
// 		If Len(aItinierario) > 0
// 			cIBGE := Alltrim(cValToChar(aItinierario[1][2]))
// 			MsAguarde({|| encCIOT(cHash) } ,"Aguarde...","Processando MDF-e " + cDoc  ,.F.)

// 		Else
// 			MsgStop("Não foi possível carregar o itinerário do roteiro " + cRoteiro + "-" + DToC(SToD(cDtEntr)) + ".","Função encCIOL(ADLOG057P)")
// 			logZBE("FUNCAO encCIOL: NAO FOI POSSÍVEL CARREGAR O ITINERARIO DO ROTEIRO " + cRoteiro + "-" + DToC(SToD(cDtEntr)) )

// 		EndIf
	
// 	Next i
	
// 	//
// 	carDocs(.T.,"6")

// Return Nil

/*/{Protheus.doc} u_LOG057A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A0( uPar1, uPar2, uPar3, uPar4, uPar5, uPar6 )
Return( pdfCTEdow( uPar1, uPar2, uPar3, uPar4, uPar5, uPar6 ) )

/*/{Protheus.doc} u_LOG057A1
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A1( uPar1 )
Return( getPorEm( uPar1 ) )

/*/{Protheus.doc} u_LOG057A2
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A2( uPar1, uPar2 )
Return( consulCTE( uPar1, uPar2 ) )

/*/{Protheus.doc} u_LOG057A3
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A3( uPar1 )
Return( xmlCTEdow( uPar1 ) )

/*/{Protheus.doc} u_LOG057A4
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A4( uPar1, uPar2 )
Return( tlbStatus( uPar1, uPar2 ) )

/*/{Protheus.doc} u_LOG057A5
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A5( uPar1 )
Return( tabelaDoc( uPar1 ) )

/*/{Protheus.doc} u_LOG057A6
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG057A6( uPar01, uPar02, uPar03, uPar04, uPar05, uPar06, uPar07, uPar08, uPar09, uPar10, uPar11 )
Return( grCTECompl( uPar01, uPar02, uPar03, uPar04, uPar05, uPar06, uPar07, uPar08, uPar09, uPar10, uPar11 ) )
