#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"   
#Include "FINC030.CH"
#Include "AP5mail.ch"
#Include "Fileio.ch"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG060R º Autor ³ Ricardo Lima - Ch:044314                             º Data ³  02/08/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³Relatório de fechamento de frete enviado as transportadores por e-mail.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ Everson-14/08/20129.Ch 044314. Tratamento no script sql para que o relatório de fechamento   º±±
±±º          ³ considere apenas os registros fechados.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ Everson-26/08/20129.Ch 044314. Filtro para determinar o envio de relatório para a            º±±
±±º          ³ transportadora.                                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ Everson-02/10/2019.Ch 044314. Correção do informativo da data do período.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteração ³ Everson-08/10/2019.Ch 044314. Alterado e-mail no cadastro do fornecedor por e-mail no        º±±
±±ºcadastro da transportadora.                                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ADLOG060R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea 	:= GetArea()
	Local cFornece	:= ""
	Local cLoja		:= ""
	Local cNmForc	:= ""
	Local cEmail	:= ""
	Local cAssunto	:= ""
	Local cHtml  	:= ""
	Local cPlaca	:= ""
	Local cDir		:= "\cte_log\"
	Local cArq		:= ""
	Local cMensagem	:= ""
	
	Local nTotFret	:= 0
	Local nTotPeso 	:= 0
	Local ntTKmpag 	:= 0
	Local nTotEntr 	:= 0
	Local nViag    	:= 0
	Local nTotAcres	:= 0
	Local nTotDesc 	:= 0
	Local nTotRec	:= 0
	Local cEmailC	:= Alltrim(GetMv("MV_#CELFFT"))

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de fechamento de frete enviado as transportadores por e-mail.')
				
	//Everson-26/08/20129.Ch 044314.
	If ! Pergunte("ADLOG060R",.T.)
		RestArea(aArea)
		Return Nil

	EndIf
	
	//Everson-26/08/20129.Ch 044314.
	If Select("xZFA") > 0
		xZFA->(DbCloseArea())
		
	EndIf
	
	//
	//Static Call(ADLOG045R,QryZFA,.T.) //Everson-14/08/20129.Ch 044314.
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	u_LOG045A0(.T.)

	//
	If xZFA->(Eof())
		xZFA->(DbCloseArea())
		MsgStop("Não há dados a serem enviados.","Função ADLOG060R")
		RestArea(aArea)
		Return Nil
		
	EndIf

	//
	While ! xZFA->(Eof())

		//
		cFornece:= Alltrim(cValToChar(xZFA->ZFA_TRANPA))
		cLoja	:= Alltrim(cValToChar(xZFA->ZFA_LJPPAG))
		cNmForc	:= Alltrim(cValToChar( Posicione("SA2",1, FWxFilial("SA2") + cFornece + cLoja ,"A2_NOME") ))
		
		//Everson-26/08/20129.Ch 044314.
		If MV_PAR05 == 1
			cEmail := cEmailC
			
		Else
			cEmail := Alltrim(cValToChar( Posicione("SA4",1, FWxFilial("SA4") + cFornece  ,"A4_EMAIL") )) //Everson - 08/10/2019. Chamado 044314.
			//cEmail := Alltrim(cValToChar( Posicione("SA2",1, FWxFilial("SA2") + cFornece + cLoja ,"A2_EMAIL") )) //Everson - 26/08/2019. Chamado 044314.
		
		EndIf
		
		cArq    := "FchFrt_"+cFornece+cLoja+"_"+DToS(MV_PAR01)+"_"+DToS(MV_PAR02)+".html"
		
		//
		cAssunto  := "Fechamento de Frete de " + DToC(MV_PAR01) + " até " + DToC(MV_PAR02) + " " + cFornece + "/" + cLoja + "-" + cNmForc + "."
		
		//
		cMensagem := "<html>"
		cMensagem += "<body>"
		cMensagem += "<div style='text-align: left;'> "
			cMensagem += "<p>Olá, " + cFornece + "/" + cLoja + "-" + cNmForc + ".</p>"
			cMensagem += "<p>Segue fechamento de frete anexo do período de " + DToC(MV_PAR01) + " até " + DToC(MV_PAR02) + ".</p>"
		cMensagem += "</div> "
		
		cMensagem += "<div style='text-align: left;'> "
			cMensagem += "<span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Sistema de Frete - Ad&#39;oro - e-mail enviado automaticamente. Por favor, não responda.</span></span>" 
		cMensagem += "</div> "
		cMensagem += "</body>"
		cMensagem += "</html>"
		
		//
		cHtml := ''
		cHtml += ' <!DOCTYPE html> '
		cHtml += ' <html> '
		cHtml += ' <head> '
		cHtml += ' <style> '
		
		cHtml += ' table{ border-collapse: collapse; width: 100%; } '
		cHtml += ' td{ text-align: left; font-size: 12px; padding: 5px; border: 1px solid #dddddd; } '
		cHtml += ' th{ font-size: 12px; padding: 5px; border: 1px solid #dddddd; } '
		cHtml += ' tr:nth-child(even){background-color: #f2f2f2;} '		
		cHtml += ' @media print{ tr:nth-child(even) td{background-color: #f2f2f2 !important; -webkit-print-color-adjust: exact; } '		
		cHtml += ' </style> '
		cHtml += ' </head> '
		cHtml += ' <body> '

		//
		While ! xZFA->(Eof()) .And. cFornece == Alltrim(cValToChar(xZFA->ZFA_TRANPA)) .And.;
		       cLoja == Alltrim(cValToChar(xZFA->ZFA_LJPPAG)) 
		       
		    //
		    cPlaca := Alltrim(xZFA->ZFA_VEICPG)
		    
		    //
		    cHtml += ' <div style="display:table;">
		    
		    cHtml += ' <div style="border: 1px solid #dddddd; padding: 5px">
				cHtml += ' <h5 class="pageHeader">Fechamento Veículo/Transportadora</h5> '
				cHtml += ' <h5>Período de: ' +  DToC(MV_PAR01) + ' Até: ' +  DToC(MV_PAR02) + '</h5> ' //Everson - 02/10/2019. Chamado 044314.
				cHtml += ' <h5>Trans.: ' + cFornece + ' ' + cLoja + ' ' + cNmForc + ' Veículo: ' + cPlaca + '</h5> '
			cHtml += ' </div>
			
			cHtml += ' <table> '
			cHtml += ' <thead> '
			cHtml += ' <th>DATA</th> '
			cHtml += ' <th>INTEGRADO</th> '
			cHtml += ' <th>ENT.</th> '
			cHtml += ' <th>KM</th> '
			cHtml += ' <th>PESO</th> '
			cHtml += ' <th>TOTAL FRETE</th> '
			cHtml += ' <th>DESCRICAO</th> '
			cHtml += ' <th>** DESCONTO E ACRESCIMO ** <br/>OBSERVAÇÃO</th> '
			cHtml += ' <th>ACRESCIMO</th> '
			cHtml += ' <th>DESCONTO</th> '
			cHtml += ' </thead> '
			cHtml += ' <tbody> '
			
			//
			nTotFret := 0
			nTotPeso := 0
			ntTKmpag := 0
			nTotEntr := 0
			nViag    := 0
			nTotAcres:= 0
			nTotDesc := 0
			
			//	
			While ! xZFA->(Eof()) .And. cPlaca == Alltrim(xZFA->ZFA_VEICPG)
				
				//
				cHtml += ' <tr> '
				cHtml += ' <td> ' + Alltrim( DToC( SToD(xZFA->ZFA_DATA) ) ) + ' </td> '
				cHtml += ' <td> </td> ' //Integrado.
				
				//
				If Alltrim(cValToChar(xZFA->ZF7_TOTCOD)) == "S"
					
					//
					cHtml += ' <td> ' + Alltrim( Transform(xZFA->ZFA_NUMENT,"@E 999,999,999") )    + ' </td> '
					cHtml += ' <td> ' + Alltrim( Transform(xZFA->ZFA_KMTOT ,"@E 999,999,999") )    + ' </td> '
					cHtml += ' <td> ' + Alltrim( Transform(xZFA->ZFA_KGBT  ,"@E 999,999,999.999")) + ' </td> '
					cHtml += ' <td> ' + Alltrim( Transform(xZFA->ZFA_VALOR ,"@E 999,999,999.99"))  + ' </td> '
					cHtml += ' <td> ' + Alltrim(cValToChar(xZFA->ZFA_OCORRE)) +"-"+ Alltrim(cValToChar(xZFA->ZFA_DESCOC)) + ' </td> '
					cHtml += ' <td> ' + Alltrim(cValToChar(xZFA->OBS)) + ' </td> '
					cHtml += ' <td></td> '
					cHtml += ' <td></td> '
					
					//
					ntTKmpag   += xZFA->ZFA_KMTOT
					nTotPeso   += xZFA->ZFA_KGBT
					nTotFret   += xZFA->ZFA_VALOR
					nTotEntr   += xZFA->ZFA_NUMENT
					nViag      += 1
				
				Else
					
					//
					cHtml += ' <td></td> '
					cHtml += ' <td></td> '
					cHtml += ' <td></td> '
					cHtml += ' <td></td> '
					cHtml += ' <td> ' + Alltrim(cValToChar(xZFA->ZFA_OCORRE)) +"-"+ Alltrim(cValToChar(xZFA->ZFA_DESCOC)) + ' </td> '
					cHtml += ' <td> ' + Alltrim(cValToChar(xZFA->OBS)) + ' </td> 
				
					If xZFA->ZFA_DC == "C"
						nTotAcres += xZFA->ZFA_VALOR 
						cHtml += ' <td> ' + Alltrim( Transform(xZFA->ZFA_VALOR,"@E 999,999,999.99")) + ' </td> '
						cHtml += ' <td></td> '
						
					Else
						nTotDesc  += xZFA->ZFA_VALOR
						cHtml += ' <td></td> '
						cHtml += ' <td> ' + Alltrim( Transform(xZFA->ZFA_VALOR,"@E 999,999,999.99")) + ' </td> '  
						
					EndIf
					
				EndIf
				
				//
				cHtml += ' </tr> '
				
				//
				xZFA->(DbSkip())
			
			End
			
			//
			cHtml += ' <tr style="font-weight: bold;"> '
				cHtml += ' <td>TOTAL</td> '
				cHtml += ' <td></td> '
				cHtml += ' <td> ' + Transform(nTotEntr ,"999,999,999") + '</td> '
				cHtml += ' <td> ' + Alltrim( Transform(ntTKmpag  ,"@E 999,999,999") )    + ' </td> '
				cHtml += ' <td> ' + Alltrim( Transform(nTotPeso  ,"@E 999,999,999.999")) + ' </td> '
				cHtml += ' <td> ' + Alltrim( Transform(nTotFret  ,"@E 999,999,999.99"))  + ' </td> '
				cHtml += ' <td></td> '
				cHtml += ' <td></td> '
				cHtml += ' <td> ' + Alltrim( Transform(nTotAcres  ,"@E 999,999,999.99") ) + ' </td> '
				cHtml += ' <td> ' + Alltrim( Transform(nTotDesc   ,"@E 999,999,999.99") ) + ' </td> '
			cHtml += ' </tr> '
			
			//
			cHtml += ' <tr> '
				cHtml += ' <td colspan="10" style="font-weight: bold;">TOTAL DE VIAGENS: ' + Alltrim(Transform(nViag ,"999,999,999")) + '</td> '
			cHtml += ' </tr> '
			
			//
			nTotRec := nTotFret + nTotAcres - nTotDesc
			cHtml += ' <tr> '
				cHtml += ' <td colspan="10" style="font-weight: bold;">TOTAL A PAGAR: ' + Alltrim( Transform(nTotRec   ,"@E 999,999,999.99") ) + '</td> '
			cHtml += ' </tr> '
				
			//
			cHtml += ' </tbody> '
			cHtml += ' </table> '
			cHtml += ' <hr> '
			cHtml += ' </div>
			cHtml += ' <br/><br/><br/><br/> '
			
			//
			If cFornece == Alltrim(cValToChar(xZFA->ZFA_TRANPA)) .And. cLoja == Alltrim(cValToChar(xZFA->ZFA_LJPPAG)) 
				cHtml += ' <p style="page-break-before:always"> '
			
			EndIf

		End			
		
		//
		cHtml += ' </body> '
		cHtml += ' </html> '

		//
		If MemoWrite(cDir + cArq, Alltrim(cValToChar(cHtml)) )
			
			//
			MsAguarde({|| U_F50En2WF(cEmail,cEmailC,cAssunto,cMensagem,cDir + cArq)  } ,"Aguarde","Env para " + cFornece + "-" + cLoja + "/" + cNmForc + "(" + cEmail + ")")
			
			//
			FErase(cDir + cArq)
		
		EndIf
		
		//
		cHtml := ""
		cEmail:= ""
			
	End
	
	//
	xZFA->(DbCloseArea())

	//
	MsgInfo("Processo concluído.","Função ADLG40D(ADLOG040P)")

	//
	RestArea(aArea)
	
Return Nil
