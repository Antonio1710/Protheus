#include "protheus.ch"
#include "totvs.ch"

/*/{Protheus.doc} User Function PMA210OK
	Ponto Entrada na finalização da revisão do projeto para consistir o preenchimento da suplementação
	@type  Function
	@author Fernando Macieira
	@since 12/08/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado TI
	@history Chamado 046284 - FWNM       - 08/01/2019 - Novas regras alteração valor
	@history Chamado 047440 - FWNM       - 07/05/2019 - 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS
	@history Chamado TI     - FWNM       - 14/05/2019 - Adequação revisão do projeto quando vistador reprovar 
	@history Chamado 053839 - FWNM       - 06/12/2019 - 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ
	@history Chamado 056937 - FWNM       - 26/03/2020 - || OS 058425 || CONTROLADORIA || DAIANE || (16)99701-3500 || REVISAO PROJETO
/*/
User Function PMA210Ok()

	Local lTudoOk   := .t.
	Local cFaseRej  := GetMV("MV_#FASREJ",,"01")
	Local cFaseApr  := GetMV("MV_#FASEOK",,"03")
	Local cFaseIni  := GetMV("MV_PRJINIC",,"05")
	Local nLimite   := GetMV("MV_#ZC7LIM",,1000000)
	Local nConsumo  := 0
	Local nVlFuturo := 0


	// Consiste filial do projeto para não gravar a central de aprovação(ZC7) incorretamente, impactando a diretoria!
	If Left(AllTrim(AF8->AF8_PROJET),2) <> cFilAnt
		lTudoOk := .f.
		Aviso("PMA210OK-04", "Este projeto não pertence a esta filial... Faça a revisão dentro da filial correta! ", {"OK"}, 3, "Suplementação - Projetos Investimentos")
	EndIf

	// Consiste se esta na central de aprovacao
	If IsInCallStack("PMS210Rvs") // Inicializacao da Revisao
		//If AF8->AF8_FASE == cFaseIni // Bloqueado // Chamado n. 046284
		//If AllTrim(AF8->AF8_FASE) <> AllTrim(cFaseApr) // Se fase diferente de aprovada // Chamado n. 046284
		If AllTrim(AF8->AF8_FASE) == AllTrim(cFaseIni) // Chamado ³ TI || Adequacao revisao do projeto quando vistador reprovar - FWNM - 14/05/2019
			lTudoOk := .f.
			Aviso("PMA210OK-03", "Projeto bloqueado! " + chr(13) + chr(10) + "Necessário aprovação antes de uma revisão para suplementação...", {"OK"}, 3, "Suplementação - Projetos Investimentos")
		EndIf
		msgAlert("Lembre-se: Necessário executar a Finalização da Revisão. Somente após a execução da 'Finalização da Revisão' é que esta revisão será enviada para a Central de Aprovação. Este valor informado nesta revisão será acrescido ao valor atual somente se aprovado pela diretoria.", "[ PMA210OK-05 ] - Lembrete - Revisão Projetos Investimentos")
		//Aviso("PMA210OK-05", "Lembre-se: " + chr(13) + chr(10) + "- Necessário executar a Finalização da Revisão." + chr(13) + chr(10) + "- Somente após a execução da Finalização da Revisão é que esta revisão será enviada para a Central de Aprovação." +;
		//	chr(13) + chr(10) + "- Este valor informado nesta revisão será acrescido ao valor atual somente se aprovado pela diretoria.", {"OK"}, 3, "Lembrete - Revisão Projetos Investimentos")
	EndIf
	
	If lTudoOk

		// Valor Suplementacao
		If IsInCallStack("PMS210Frv") // Finalizacao da Revisao

			//If M->AFE_XVLRNV <= 0
			If M->AFE_XVLRNV == 0 // Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ - FWNM - 04/12/2019
				lTudoOk := .f.
				Aviso("PMA210OK-01", "Valor da suplementação não informado! " + chr(13) + chr(10) + "Informe um valor para ser adicionado nesta revisão do projeto...", {"OK"}, 3, "Suplementação - Projetos Investimentos")
			EndIf

			If lTudoOk
				// Comentario resumido / completo
				If Empty(M->AFE_MEMO) .or. Empty(M->AFE_COMENT)
					lTudoOk := .f.
					Aviso("PMA210OK-02", "Comentários RESUMIDO e COMPLETO não preenchidos! " + chr(13) + chr(10) + "Detalhe para os gestores as justificativas para a suplementação deste projeto...", {"OK"}, 3, "Suplementação - Projetos Investimentos")
				EndIf
			EndIf

			// Chamado n. 053839 || OS 055224 || CONTROLADORIA || DAIANE || (16) || REDUCAO VLR PRJ - fwnm - 06/12/2019
			If lTudoOk
				If M->AFE_XVLRNV < 0 // Suplementaçao negativa
					nVlFuturo := AF8->AF8_XVALOR - Abs(M->AFE_XVLRNV)
					nConsumo  := u_ADCOM017P(AF8->AF8_PROJET,"BROWSE") 
					If nVlFuturo < nConsumo
						lTudoOk := .f.
						Aviso( "PMA210OK-07",;
						 		"Esta suplementação negativa deixará o projeto negativo (Consumo maior que valor projeto)! Valor informado não permitido..." + chr(13) + CHR(10) +;
								"Valor Projeto: R$" + Transform(AF8->AF8_XVALOR,"@E 999,999,999,999.99") + chr(13) + chr(10) +;
								"Consumo Projeto: R$" + Transform(nConsumo,"@E 999,999,999,999.99") + chr(13) + chr(10) +;
								"Saldo Atual: R$" + Transform(AF8->AF8_XVALOR-nConsumo,"@E 999,999,999,999.99") + chr(13) + chr(10) +;
								"Valor Futuro Projeto: R$" + Transform(nVlFuturo,"@E 999,999,999,999.99"),;
						{"&OK"}, 3,;
						"Suplementação Negativa- Redução valor projeto")
					EndIf
				EndIf
			EndIf
			//

			If lTudoOk
				If IsInCallStack("PMS210Frv") // Finalizacao da Revisao
				
					// Chamado n. 056937 || OS 058425 || CONTROLADORIA || DAIANE || (16)99701-3500 || REVISAO PROJETO - FWNM - 26/03/2020
					// Popula a central de aprovaçao
					u_GeraZC7(1, M->AFE_XVLRNV) 

					RecLock("AFE", .F.)
						AFE->AFE_XVLROR := AF8->AF8_XVALOR
						AFE->AFE_XVLRNV := M->AFE_XVLRNV
					AFE->( msUnLock() )

					RecLock("ZBE", .T.)
						ZBE->ZBE_FILIAL := FWxFilial("ZBE")
						ZBE->ZBE_DATA 	:= msDate()
						ZBE->ZBE_HORA 	:= Time()
						ZBE->ZBE_USUARI	:= Upper(Alltrim(cUserName))
						ZBE->ZBE_LOG	:= "1-Gerou ZC7 Central Aprovacao"
						ZBE->ZBE_PARAME := "AFE_PROJET/AFE_REVISA " + Alltrim(cValToChar(AFE->AFE_PROJET)) +"/"+ Alltrim(cValToChar(AFE->AFE_REVISA)) + " AF8_PROJET/REVISA " + Alltrim(cValToChar(AF8->AF8_PROJET)) +"/"+ Alltrim(cValToChar(AF8->AF8_REVISA))
						ZBE->ZBE_MODULO	:= "PROJETO"
						ZBE->ZBE_ROTINA	:= "PMA210OK" 
					ZBE->( msUnlock() )
					//

					// Envia email de aviso para aprovador
					aDadWF  := {}
					cMail   := UsrRetMail(AF8->AF8_XCODAP)
					cUsrSol := AllTrim( __cUserID )
					cNomSol := AllTrim(UsrRetName(__cUserID))
					dDatSol := msDate()
					cHorSol := TIME()

					aAdd( aDadWF, { AF8->AF8_PROJET, AF8->AF8_REVISA, cUsrSol, cNomSol, dDatSol, cHorSol, M->AFE_XVLRNV, cMail, AF8->AF8_DESCRI, AF8->AF8_XCODAP } )
					u_ADPRJ004P(aDadWF, "REVISAO") //ERRO ENVIA WF WILLIAM COSTA 12/03/2018

					// Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 06/05/2019
					nVlrRev := M->AFE_XVLRNV + AF8->AF8_XVALOR
					If nVlrRev >= nLimite
						Aviso(	"PMA210OK-06",;
							"Limite de alçada do Projeto alcançado! A alçada de aprovação será gerada para todos os aprovadores, além do vistador amarrado ao aprovador principal do projeto... Veja na rotina de Gerenciamento de Projetos, no botão Outras Ações -> Aprovações...",;
							{ "&Ok" },3,;
							"Limite atual (MV_#ZC7LIM): " + Transform(nLimite,"@E 999,999,999.99") )
					EndIf
				EndIf
			EndIf

		EndIf

	EndIf

Return lTudoOk