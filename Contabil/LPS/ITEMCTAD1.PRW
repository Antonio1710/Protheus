#Include "Protheus.ch"

/*/{Protheus.doc} User Function ITEMCTA()
	Retorna item contabil - utilizado no LP 610 e 620
	@type  Function
	@author Cellvla
	@since 16/04/2014
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 053445 - FWNM          - 19/11/2019 - 053445 || OS 054828 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || ACERTO LPS
	@history Chamado 053754 - William Costa - 11/12/2019 - Ajuste no item contabil 112 para o produto 386914
	@history Chamado 055820 - William Costa - 19/02/2020 - Ajuste no item contabil 112 para o produto 384413
	@history Chamado 057395 - William Costa - 15/04/2020 - Ajuste no item contabil 112 para o produto 342977
	@history Chamado 073213 - Antonio Domingos - 20/05/2022 - Ajuste no item ccusto 5113 e item contabil 113 para o produto 190590 qdo a filial for 03/05
/*/
User Function ITEMCTAD1()

	Local aArea       := SD1->(GetArea())
	Local cItemCta    := ""  
	Local cConta      := "" 
	Local cCusto      := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If SM0->M0_CODIGO == "01" .And. SD1->D1_FILIAL == "03"   // Somente será executado quando for filial de São Carlos

		cConta:= U_LP610CTA()   // Pego o retorno da Conta que esta sendo usada no lançamento padrão, pois nao posso considerar o que esta no SD1->D1_CONTA
		If Alltrim(SD1->D1_COD) $ "190590"
			cCusto:= "5131"
		Else
			cCusto:= U_LP610CC()   // Pego o retorno da Centro de Custo que esta sendo usada no lançamento padrão, pois nao posso considerar o que esta no SD1->D1_CCUSTO
		EndIf
		
		// Produto Ovos Industrializados
		If Alltrim(SD1->D1_COD) $ "391650" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "112"
		Endif
		
		// Produto Quirera
		If Alltrim(SD1->D1_COD) == "190590" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		ElseIf Alltrim(SD1->D1_COD) $ "190590" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "5131"
			cItemCta := "113"
		Endif         
		
		// Produto Varredura
		If Alltrim(SD1->D1_COD) $ "112800" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		Endif  
		
		// Produto Impureza
		If Alltrim(SD1->D1_COD) $ "190589" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		Endif      
		
		// Produto Sucata Embalagem
		If Alltrim(SD1->D1_COD) $ "812674" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		Endif
		
		// Produto Bombona Plastica 50 Litros - Azul
		If Alltrim(SD1->D1_COD) $ "588546" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		Endif       
		
		// Produto Container
		If Alltrim(SD1->D1_COD) $ "492577" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		Endif
		
		// Produto Material de Limpeza Matrizes
		If Alltrim(SD1->D1_COD) $ "592727" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "111"
		Endif
		
		// Produto Material Vestuario Matrizes
		If Alltrim(SD1->D1_COD) $ "592728" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "111"
		Endif
		
		// Produto Material Construção Matrizes
		If Alltrim(SD1->D1_COD) $ "492730" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "111"
		Endif
		
		// Produto Racao Suinos Gestacao
		If Alltrim(SD1->D1_COD) $ "191660" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif
		
		//Producao Ração Matriz Pico de Producao // Chamado: 038690 Fernando 13/12/2017
		If Alltrim(SD1->D1_COD) $ "191427" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150" 
			cItemCta := "111"
		Endif
			
		// Produto Racao Suinos Lactacao
		If Alltrim(SD1->D1_COD) $ "191661" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif
		
		// Produto Racao Suinos Terminacao
		If Alltrim(SD1->D1_COD) $ "191662" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif

		// Produto Racao Suinos Recria
		If Alltrim(SD1->D1_COD) $ "191663" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif
		
		// Produto Racao Suinos Inicial I
		If Alltrim(SD1->D1_COD) $ "191664" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif	

		// Produto Racao Suinos Inicial II
		If Alltrim(SD1->D1_COD) $ "191665" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif

		// Produto Racao Suinos Pre Inicial II
		If Alltrim(SD1->D1_COD) $ "191666" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif

		// Produto Milho
		If Alltrim(SD1->D1_COD) $ "383369" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif

		// Produto Farelho de Soja
		If Alltrim(SD1->D1_COD) $ "384885" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif

		// Produto Frango Vivo
		If Alltrim(SD1->D1_COD) $ "300042" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6110#6210" //fernando sigoli 17/08/2018 - Chamado: 043244  
			cItemCta := "113"
		Endif

		// Produto Racao Matriz Inicial
		If Alltrim(SD1->D1_COD) $ "110358" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif

		// Produto Racao Matriz Crescimento
		If Alltrim(SD1->D1_COD) $ "110483" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif

		// Produto Racao Matriz Pre-Inicial
		If Alltrim(SD1->D1_COD) $ "187015" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif
		
		// Produto Racao Galo 1
		If Alltrim(SD1->D1_COD) $ "381534" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif	

		// Produto Racao Matriz Pre Postura
		If Alltrim(SD1->D1_COD) $ "381536" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif
		
		// Produto Racao Matriz Postura I
		If Alltrim(SD1->D1_COD) $ "381537" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif	
		
		// Produto Racao Matriz Postura II
		If Alltrim(SD1->D1_COD) $ "381538" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif	

		// Produto Racao Matriz Postura III
		If Alltrim(SD1->D1_COD) $ "381539" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif		

		// Produto Ovos Ferteis
		If Alltrim(SD1->D1_COD) $ "384413" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6110"
			cItemCta := "112"
		Endif

		// Produto Ovos Ferteis
		If Alltrim(SD1->D1_COD) $ "384413" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6210"
			cItemCta := "112"
		Endif

		// Produto Oleo de Frango
		If Alltrim(SD1->D1_COD) $ "100096" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6130"
			cItemCta := "114"
		Endif	 

		// Produto Farinha de Pena
		If Alltrim(SD1->D1_COD) $ "100097" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6130"
			cItemCta := "114"
		Endif		

		// Produto Farinha de Visceras
		If Alltrim(SD1->D1_COD) $ "100098" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6130"
			cItemCta := "114"
		Endif		
		
		// Variavel Retornar Vazio
		If Empty(cItemCta)
			cItemCta := "114" //SD1->D1_ITEMCC - Alterado por Adriana para preenchimento do Item Contábil em 06/04/15 chamado 022508
		Endif

		// Chamado n. 053445 || OS 054828 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || ACERTO LPS - fwnm - 19/11/2019
		If Alltrim(SD1->D1_COD) $ "391650/386914/384413/342977 " //chamado WILLIAM COSTA 11/12/2019 CHAMADO 053754 e chamado 055820 e chamado 057395 
			cItemCta := "112"
		Endif

	Endif	

	// Tratamento para a Filial 05 conforme solicitado pelo Alan Contabildiade chamado 018349
	If SM0->M0_CODIGO == "01" .And. SD1->D1_FILIAL == "05"   // Somente será executado quando for filial 05

		cConta:= U_LP610CTA()   // Pego o retorno da Conta que esta sendo usada no lançamento padrão, pois nao posso considerar o que esta no SD1->D1_CONTA
		If Alltrim(SD1->D1_COD) $ "190590"
			cCusto:= "5131"
		Else
			cCusto:= U_LP610CC()   // Pego o retorno da Centro de Custo que esta sendo usada no lançamento padrão, pois nao posso considerar o que esta no SD1->D1_CCUSTO
		ENDIF

		// Produto Quirera
		If Alltrim(SD1->D1_COD) == "190590" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "6140"
			cItemCta := "114"
		ElseIf Alltrim(SD1->D1_COD) == "190590" .And. Alltrim(cConta) $ "337110003" .And. Alltrim(cCusto) $ "5131"
			cItemCta := "113"		
		Endif  	
		
		If Alltrim(SD1->D1_COD) $ "191660/191661/191662/191663/191664/191665/191666/383369/384885" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "114"
		Endif
			
		If Alltrim(SD1->D1_COD) $ "196326/110358/110483/187015/381534/381536/381537/381538/381539/381153/381539" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150"
			cItemCta := "111"
		Endif
		
		// Chamado: 043260 
		If Alltrim(SD1->D1_COD) $ "191427" .And. Alltrim(cConta) $ "311110001" .And. Alltrim(cCusto) $ "6150" 
			cItemCta := "111"
		Endif

		// Variavel Retornar Vazio
		If Empty(cItemCta)
			cItemCta := SD1->D1_ITEMCC
		Endif
	Endif	

	If Empty(cItemCta) .AND. SM0->M0_CODIGO == "01" .And. SD1->D1_FILIAL == "05"  
			cItemCta := "114"
	Endif

	If Empty(cItemCta)
		cItemCta := SD1->D1_ITEMCC
	Endif	

	// Chamado n. 053445 || OS 054828 || CONTROLADORIA || TAMIRES_SERAFIM || 8503 || ACERTO LPS - fwnm - 19/11/2019
	If cEmpAnt == "01" .and. SD1->D1_FILIAL == "03"
		If Alltrim(SD1->D1_COD) == "391650"
			cItemCta := "112"
		Endif
	EndIf

	RestArea(aArea)

Return cItemCta


