#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function MSD2460
	Grava campos da estrutura do SB1 na Tabela SD2
	@type  Function
	@author Wagner - HC
	@since 15/12/2006
	@version 01
	@history Chamado T.I    - DANIEL        - 16/03/2007 - Corrigido Posicionamento de gravacao Inserido o salvamento do ambiente
	@history Chamado 045778 - WILLIAM COSTA - 18/12/2018 - Adicionado Regra de Centro de Custo para produtos novos
	@history Chamado 050238 - FWNM          - 31/07/2019 - D2_CONTA E D2_CCUSTO
	@history Chamado 050115 - FWNM          - 05/08/2019 - INTEGRACAO KASSAI
	@history Chamado 051066 - ABEL BABINI   - 13/08/2019 - DEV. ITEM CONTA
	@history Chamado 051619 - ABEL BABINI   - 09/09/2019 - SPED PIS COFINS
	@history Chamado 053754 - William Costa - 11/12/2019 - Ajuste no item contabil 112 para o produto 386914
	@history ticket   11814 - Fernando Maci - 09/04/2021 - Verificar Regra de Centro de Custo
/*/

User Function MSD2460()

	Local 	_aArea  := GetArea() //Salvando Ambiente
	Private xCCUSTO := '' //C. Custo
	
	IF SM0->M0_CODIGO = '01'
		
		RecLock("SD2",.F.)

			SD2->D2_XGRUPO  := SB1->B1_XGRUPO
			SD2->D2_XCATEG  := SB1->B1_XCATEG
			SD2->D2_XFAMILI := SB1->B1_XFAMILI
			SD2->D2_XPREPAR := SB1->B1_XPREPAR
			SD2->D2_XEMBALA := SB1->B1_XEMBALA
			SD2->D2_XPARTES := SB1->B1_XPARTES
			
			// FWNM - 06/04/2018
			SD2->D2_XPROJET := SC6->C6_XPROJET // PRJ INVESTIMENTO - DEV COMPRA

		MsUnlock()
		
		// Inicio do novo tratamento do centro de custo quando for a filial 03, conforme tabela passada pela Luciana
		
		xCCUSTO := ""
		
		If SM0->M0_CODIGO == "01" .AND. SM0->M0_CODFIL != "03"
			
			IF SD2->D2_EST == SM0->M0_ESTENT
			
				// *** INICIO CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
			
				IF SD2->D2_GRUPO $ '0541/0542/0543'
				
					xCCUSTO:='6120 '
					
				ELSEIF	SD2->D2_GRUPO $ '0911/0912/0913'
				
					xCCUSTO:='6130'
					
				ELSEIF	SD2->D2_GRUPO $ '0921/0922/0923/0924/0925/0926/0927/0928'
				
					xCCUSTO:='6180'
				
				// *** INICIO WILLIAM COSTA 18/12/2018 045778 || OS 047092 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || FATURAMENTO/CUSTO   	
				ELSEIF ALLTRIM(SD2->D2_COD) $ "113069/113071/113081/113093/142476" 
				
						xCCUSTO:='6190'
				
				// *** FINAL WILLIAM COSTA 18/12/2018 045778 || OS 047092 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || FATURAMENTO/CUSTO
					
				ELSE
					
					xCCUSTO:='6110'
				
				ENDIF
				
				// *** FINAL CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
				
			ELSE
			
				IF SD2->D2_EST == 'EX'
					xCCUSTO := '6910'
				ELSE
				
					// *** INICIO CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
			
					IF SD2->D2_GRUPO $ '0541/0542/0543'
					
						xCCUSTO:='6220 '
						
					ELSEIF	SD2->D2_GRUPO $ '0911/0912/0913'
					
						xCCUSTO:='6230'
						
					ELSEIF	SD2->D2_GRUPO $ '0921/0922/0923/0924/0925/0926/0927/0928'
					
						xCCUSTO:='6280'	
						
					// *** INICIO WILLIAM COSTA 18/12/2018 045778 || OS 047092 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || FATURAMENTO/CUSTO   	
					ELSEIF ALLTRIM(SD2->D2_COD) $ "113069/113071/113081/113093/142476" 
					
							xCCUSTO:='6290'
					
					// *** FINAL WILLIAM COSTA 18/12/2018 045778 || OS 047092 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || FATURAMENTO/CUSTO
						
					ELSE
						
						xCCUSTO:='6210'
					
					ENDIF
					
					// *** FINAL CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
					
				ENDIF
			ENDIF
		Endif
			
		If SM0->M0_CODIGO == "01" .AND. SM0->M0_CODFIL $ "03 04 05"
			
			If Alltrim(SD2->D2_COD) $ "300042/384413" .AND. SD2->D2_EST == "SP"
				xCCUSTO:= "6110"
			Endif
			If Alltrim(SD2->D2_COD) $ "300042/384413" /*CHAMADO 042794 */ .AND. SD2->D2_EST != "SP" .AND. SD2->D2_EST != "EX" /*CHAMADO 044479 */
				xCCUSTO:= "6210"
			Endif
			If Alltrim(SD2->D2_COD) $ "100096/100097/100098"
			
				// *** INICIO CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
				
				IF SD2->D2_EST = SM0->M0_ESTENT
				
					xCCUSTO := "6130"	
				
				ELSE
				
					xCCUSTO := "6230"
					
				ENDIF
				
				// *** FINAL CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
				
			Endif
			If Alltrim(SD2->D2_COD) $ "391650/190590/112800/190589/812674/588546/492577/592727/592728/492730/592729"
				xCCUSTO := "6140"
			Endif

			// *** INICIO WILLIAM COSTA 11/12/2019 CHAMADO 053754 || OS 055137 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || LP -610
			IF ALLTRIM(SD2->D2_COD) $ "386914"

				IF LEFT(ALLTRIM(SD2->D2_CF),1) == "5"  

					xCCUSTO := "6141"

				ELSEIF LEFT(ALLTRIM(SD2->D2_CF),1) == "6"

					xCCUSTO := "6241"

				ENDIF
			ENDIF
			// *** FINAL WILLIAM COSTA 11/12/2019 CHAMADO 053754 || OS 055137 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || LP -610
			
			// *** INICIO CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
			
			If Alltrim(SD2->D2_GRUPO) $ "9008"
			
				IF SD2->D2_EST = SM0->M0_ESTENT
				
					xCCUSTO := "6150"	
				
				ELSE
				
					xCCUSTO := "6250"
					
				ENDIF
				
			Endif
			
			// *** FINAL CHAMADO 042794 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || LP 678-012 - WILLIAM COSTA 31/07/2018 *** //
			
		Endif
		// Fim do Tratamento da Filial 03 conforme pedido pela Luciana
		SD2->D2_CCUSTO := xCCUSTO
		
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+SD2->D2_CLIENTE+SD2->D2_LOJA)
		
		SD2->D2_CLVL 	:= SUBSTR(SB1->B1_XGRUPO,2,1)+SA1->A1_SATIV1
		
		//+-----------------------------------------------------------------+
		//| FIM DO TRATAMENTO                                               |
		//+-----------------------------------------------------------------+
		
		// Acrescentado / Sugerido por Silas - HC - 18/12/06
		DO CASE
			CASE 	SD2->D2_FILIAL="02"
				SD2->D2_ITEMCC:="121"
				
				// ALTERADO POR HCCONSYS em 12/02/2010 para tratar filial 06
				
			CASE 	SD2->D2_FILIAL="06"
				SD2->D2_ITEMCC:="122"
				
				// FIM DA ALTERACAO DA HCCONSYS
				
			CASE 	SD2->D2_FILIAL="04"
				SD2->D2_ITEMCC:="112"
				
			CASE 	SD2->D2_FILIAL = "03" .AND. SB1->B1_XCATEG $ "53/55"
				IF ALLTRIM(SB1->B1_COD) == "300042"
					SD2->D2_ITEMCC:="113"
				ELSE
					SD2->D2_ITEMCC:="111"
				ENDIF
			CASE 	SD2->D2_FILIAL = "03" .AND. SB1->B1_XCATEG = "56"
				SD2->D2_ITEMCC:="112"
				
			CASE 	SD2->D2_FILIAL = "03" .AND. SB1->B1_XCATEG = "54"
				SD2->D2_ITEMCC:= "114"
				
			OTHERWISE
				SD2->D2_ITEMCC:=""
		ENDCASE
	ENDIF                                
	
	//chamado 037659 - Adriana 09/11/17  para gravar conta contabil D2_CONTA e FT_CONTA
	ContaNfs()
	
	// Chamado n. ³ 050238 || OS 051527 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || D2_CONTA E D2_CCUSTO - FWNM - 31/07/2019
	UpCtb()
	
	RestArea(_aArea)						//Daniel - 16/03/07 Retornando o ambiente
	
Return
  
Static Function ContaNfs()

	//chamado 037659 - Adriana 09/11/17
	Local _cConta 		:= ''
	Local _aAreaAnt		:= GetArea()
	
	// *** INICIO 03/10/2018 - WILLIAM COSTA - CHAMADO 041210 || CONTROLADORIA || TAMIRES_OLIVEIRA || 8464 || DOC SAIDA C CONTABIL  *** //
	 
	IF SD2->D2_TIPO == "D" 
	
		//atualizar a conta contabil de acordo com a regra de contabilização
		Dbselectarea("SF4")
		Dbsetorder(1)	
		SF4->(dbseek(xFilial("SF4") + SD2->D2_TES,.t. ))	
		
		_cConta := IIF(SF4->F4_ESTOQUE == 'S',Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CONTA"),Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_CONTAR"))
	
		Reclock("SD2",.F.)                                                                                                     
		SD2->D2_CONTA 	:= iif(!Empty(_cConta),_cConta, SD2->D2_CONTA)
		MsUnlock("SD2")
	
	ELSE
		    
		//atualizar a conta contabil de acordo com a regra de contabilização
		Dbselectarea("SF4")
		Dbsetorder(1)	
		SF4->(dbseek(xFilial("SF4") + SD2->D2_TES,.t. ))	
		
		_cConta := U_LP610Cta()
	
		Reclock("SD2",.F.)                                                                                                     
		SD2->D2_CONTA 	:= iif(!Empty(_cConta),_cConta, SD2->D2_CONTA)
		MsUnlock("SD2")	
	
	ENDIF
	
	// *** FINAL 03/10/2018 - WILLIAM COSTA - CHAMADO 041210 || CONTROLADORIA || TAMIRES_OLIVEIRA || 8464 || DOC SAIDA C CONTABIL  *** //
	//Fim Chamado: 037659 - Adriana 09/11/17

	RestArea(_aAreaAnt)

Return Nil

Static Function UpCtb()
      
	Local cConta   := ""
	Local cCCusto  := ""
	Local cItemCC  := ""
	Local aAreaSF4 := SF4->( GetArea() )

	// Posiciono SF4
	SF4->( dbSetOrder(1) ) // F4_FILIAL+F4_CODIGO
	SF4->( dbSeek(FWxFilial("SF4")+SD2->D2_TES) )
	
	// Chamado n. 050115 || OS 051421 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || INTEGRACAO KASSAI - FWNM - 05/08/2019
	// Empresa Adoro 
	If cEmpAnt == "01"
		If SF4->F4_XCTB == "S" .and. SF4->F4_XTM $ "S01,S14" .and. Alltrim(SD2->D2_CF) $ "5102/6102" .and. (SD2->D2_FILIAL == "03" .or. SD2->D2_FILIAL == "04" .or. SD2->D2_FILIAL == "05")
			cConta := "337110003"
		EndIf
		
		//INICIO Ch.051066 - Abel Babini - 13/08/2019 - Dev. item Conta
		DO CASE
			CASE 	SD2->D2_FILIAL="02"
				cItemCC:="121"
			CASE 	SD2->D2_FILIAL="06"
				cItemCC:="122"
			CASE 	SD2->D2_FILIAL="04"
				cItemCC:="112"
			CASE 	SD2->D2_FILIAL = "03" .AND. SB1->B1_XCATEG $ "53/55"
				IF ALLTRIM(SB1->B1_COD) == "300042"
					cItemCC:="113"
				ELSE
					cItemCC:="111"
				ENDIF
			CASE 	SD2->D2_FILIAL = "03" .AND. SB1->B1_XCATEG = "56"
				cItemCC:="112"
			CASE 	SD2->D2_FILIAL = "03" .AND. SB1->B1_XCATEG = "54"
				cItemCC:= "114"
			OTHERWISE
				cItemCC:=""
		ENDCASE
		//FIM Ch.051066 - Abel Babini - 13/08/2019 - Dev. item Conta
	EndIf
	//
	
	// Empresa CERES
	If cEmpAnt == "02"
		
		// Item
		cItemCC := "124"  
		
		// Conta
		If AllTrim(SD2->D2_GRUPO) $ "0911/0912/0913"
			cConta := "311110001"
		EndIf
		
		// CCusto
		If Left(AllTrim(SD2->D2_CF),1) == "5"  
			cCCusto := "6130"
		ElseIf Left(AllTrim(SD2->D2_CF),1) == "6"
			cCCusto := "6230"
		EndIf
		
	EndIf
	   
	// Empresa RNX2
	//If cEmpAnt == "07"
	If cEmpAnt == "07" .or. cEmpAnt == "09" //@history ticket   11814 - Fernando Maci - 09/04/2021 - Verificar Regra de Centro de Custo
		
		// Item
		cItemCC := "111"  
		
		// Conta
		If AllTrim(SD2->D2_COD) == "112191"
			cConta := "337110003"
		EndIf
		
		// CCusto
		If Left(AllTrim(SD2->D2_CF),1) == "5"  
			cCCusto := "6140"
		ElseIf Left(AllTrim(SD2->D2_CF),1) == "6"
			cCCusto := "6240"
		EndIf
		
		If AllTrim(SD2->D2_COD) == "384413" 
			cConta := "311110001"
			If Left(AllTrim(SD2->D2_CF),1) == "5"  
				cCCusto := "6110"
			ElseIf Left(AllTrim(SD2->D2_CF),1) == "6"
				cCCusto := "6210"
			EndIf
			
			// Exterior
			If Left(AllTrim(SD2->D2_CF),1) == "7"
				cConta  := "312110001"
				cCCusto := "6910"
			EndIf
			
		EndIf
		
		If AllTrim(SD2->D2_COD) $ "384837/384838" 
			cConta := "411120001"
			If Left(AllTrim(SD2->D2_CF),1) == "5"  
				cCCusto := "6110"
			ElseIf Left(AllTrim(SD2->D2_CF),1) == "6"
				cCCusto := "6210"
			EndIf
		EndIf

	EndIf
	   
	// INICIO 051619 || OS 052945 || FISCAL || VALERIA || 8389 || SPED PIS COFINS - ABEL BABINI - 09/09/2019
	IF EMPTY(ALLTRIM(cConta)) .OR. EMPTY(ALLTRIM(SD2->D2_CONTA)) //ALTERADA CONDIÇÃO "AND" PARA "OR"
	  cConta := U_LP610Cta()
	ENDIF
	// FIM 051619 || OS 052945 || FISCAL || VALERIA || 8389 || SPED PIS COFINS - ABEL BABINI - 09/09/2019

	// Grava campos 
	
	Reclock("SD2", .F.)
		// INICIO 051619 || OS 052945 || FISCAL || VALERIA || 8389 || SPED PIS COFINS - ABEL BABINI - 09/09/2019
		IF EMPTY(ALLTRIM(SD2->D2_CONTA))
			SD2->D2_CONTA  := IIF(ALLTRIM(cConta) <> '',cConta,SD2->D2_CONTA)
		ENDIF
		// FIM 051619 || OS 052945 || FISCAL || VALERIA || 8389 || SPED PIS COFINS - ABEL BABINI - 09/09/2019
		SD2->D2_CCUSTO := IIF(ALLTRIM(cCCusto) <> '',cCCusto,SD2->D2_CCUSTO)
		SD2->D2_ITEMCC := IIF(ALLTRIM(cItemCC) <> '',cItemCC,SD2->D2_ITEMCC)
	SD2->( msUnlock() )

	RestArea(aAreaSF4)

Return
