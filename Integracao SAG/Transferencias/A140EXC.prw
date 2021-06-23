#Include "Rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A140EXC   ºAutor  ³WILLIAM COSTA       º Data ³  01/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PONTO DE ENTRADA SUBSTITUTO DO A100DEL POIS NO PROTHEUS 12  º±±
±±º          ³PAROU DE FUNCIONAR.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function A140EXC()

	Local cAliasSD1	:= GetNextAlias()
	Local lRet 		:= .T.  
	
	If cEmpAnt == "01" .And. SF1->F1_TIPO=="D"   // Alterado por Adriana em 08/06/2017 chamado 035626 - restringir faturamento transportador apenas para Adoro
	
		cQuery := " SELECT D1_XPVDEV AS XPVDEV "
		cQuery += " FROM " + RetSQLName("SD1") + " SD1 "
		cQuery += " WHERE SD1.D_E_L_E_T_ = ' ' "
		cQuery += " AND D1_FILIAL = '"+ SF1->F1_FILIAL + "' AND D1_DOC = '"+ SF1->F1_DOC +"' AND D1_SERIE = '"+ SF1->F1_SERIE +"' "
		cQuery += " AND D1_FORNECE = '"+ SF1->F1_FORNECE +"' AND D1_LOJA = '"+ SF1->F1_LOJA + "' "
		
		If Select(cAliasSD1) > 0
			(cAliasSD1)->(dbCloseArea())
		EndIf
	
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
		dbSelectArea(cAliasSD1)

		(cAliasSD1)->(dbGoTop())
	
		While (cAliasSD1)->(!Eof())

			If(ALLTRIM((cAliasSD1)->XPVDEV) == '1')
				lRet := .F.
				Exit
			EndIf         

			(cAliasSD1)->(dbSkip())
		Enddo
	
		(cAliasSD1)->(dbCloseArea())
		
		If(!lRet) 
			U_ExTelaMen("Faturamento contra Transportador", "Não é possivel deletar a Nota porque existe um Pedido de Venda relacionado a esta Nota!", "Arial", 10, , .F., .T.)
		EndIf
	
		// INICIO CHAMADO 024498 - WILLIAM COSTA - Apos implantacao desse chamado foi ativado novamente essa validacao
		//  Incluido por Adriana para validar Exclusão quando nota já enviada para o eData
	
		if !Empty(SF1->F1_X_SQED)
		
			IF FUNNAME() == 'MATA140' .AND. __cUserID $ GETMV("MV_#USUDEL")

				IF MSGYESNO("Olá " + cUserName + CHR(10) + CHR(13) + " Documento já enviado para o eData. Deseja modificar a nota " + SF1->F1_DOC + "? ","A100DEL-1")

					lRet := .T.
					
				ELSE
				
					lRet := .F.
					
				ENDIF
	
			ELSE
			
				MsgBox("Olá " + cUserName + CHR(10)+ CHR(13) + " Documento já enviado para o eData. Não é possivel deletar a Nota porque já existe registro da carga no eData " + SF1->F1_DOC + ".","A100DEL-2")
				lRet := .F.
			
			ENDIF
		Endif   
		
		// Retirado devido aos problemas no cancelamento/ estorno de notas de devolução
		// FINAL CHAMADO 024498 - WILLIAM COSTA - Apos implantacao desse chamado foi ativado novamente essa validacao

	EndIf
	
	
	// *** Inicio chamado 035867 - Se for uma nota de compra ordem não pode excluir se tiver amarrado a uma remessa ordem *** //
	
	IF cEmpAnt == "01"
		
		SqlBuscaProdutoNota(SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA)  
		
		//nota encontrada
		While TRB->(!EOF())

			IF (ALLTRIM(TRB->D1_CF) $ GETMV("MV_#CFCORD"))

				//busca nota compra ordem
				SQLVerNotaCompraOrdem(TRB->D1_FILIAL,TRB->D1_DOC,TRB->D1_SERIE,TRB->D1_ITEM,TRB->D1_FORNECE,TRB->D1_LOJA)  

			    //nota encontrada
				IF TRC->(!EOF()) 

			    	// Verifica se os campos foram prenchidos
				    IF ALLTRIM(TRC->D1_FILNFOR) <> '' .OR. ; 
				       ALLTRIM(TRC->D1_NFORDEM) <> '' .OR. ; 
				       ALLTRIM(TRC->D1_SERIORD) <> '' .OR. ; 
				       ALLTRIM(TRC->D1_ITEMORD) <> '' .OR. ; 
				       ALLTRIM(TRC->D1_FORORDE) <> '' .OR. ; 
				       ALLTRIM(TRC->D1_LOJAORD) <> ''       
			    		
				    	MsgStop("OLÁ " + Alltrim(cUserName) + CHR(10) + CHR(13) + ;
				       		    "Nota de compra ordem encontrada amarrada a Remessa Ordem, Exclua primeiro a Remessa Ordem!!!" + CHR(10) + CHR(13) + ;
				       		    "Filial: " + TRC->D1_FILIAL + " Nota Remessa:"+ TRC->D1_DOC + " Serie:" + TRC->D1_SERIE + " Fornecedor: " + TRC->D1_FORNECE , "A100DEL")
				       		    
				        lRet = .F.  
				        
			    	ENDIF   				
				ENDIF 
				TRC->(dbCloseArea())  
			ENDIF   
			TRB->(dbSkip())
				            
		ENDDO
		TRB->(dbCloseArea())
		 
	ENDIF	
	// *** Final chamado 035867 - Se for uma nota de compra ordem não pode excluir se tiver amarrado a uma remessa ordem *** //
	
	// *** INICIO DA TRAVA DO SAG FEITO PELO LEONARDO RIOS WILLIAM COSTA 01/10/2018 *** //
	If Alltrim(cEmpAnt) == "01"
		If !(SF1->F1_CODIGEN<1)
			lRet := .F. 
			cMensErro := "Não será possíel executar a exclusão desta pré-nota porque ela foi gerada a partir da tabela intermediáia SGNFE010"
			U_ExTelaMen("Tratamento de exclusão da pré-nota!", cMensErro, "Arial", 12, , .F., .T.)
		
		EndIf                  
	Endif	
	
	// *** INICIO DA TRAVA DO SAG FEITO PELO LEONARDO RIOS WILLIAM COSTA 01/10/2018 *** //

Return(lRet)

Static Function SqlBuscaProdutoNota(cFil,cDoc,cSerie,cFornece,cLoja)  
     
	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT D1_DOC,
			       D1_CF,
				   D1_TES,
				   D1_LOJA, 
			       D1_FILIAL,
	               D1_SERIE,
	               D1_ITEM,
	               D1_FORNECE,
	               D1_LOJA
 		      FROM SD1010
			  WHERE D1_FILIAL               = %EXP:cFil%
			    AND D1_DOC                  = %EXP:cDoc%
			    AND D1_SERIE                = %EXP:cSerie%
			    AND D1_FORNECE              = %EXP:cFornece%
				AND D1_LOJA                 = %EXP:cLoja%   
				AND %Table:SD1%.D_E_L_E_T_ <> '*'
			    
	EndSQl             
RETURN(NIL)

Static Function SQLVerNotaCompraOrdem(cFil,cDocOrdem,cSerieOrdem,cItemOrdem,cFornece,cLoja)  

	Local cCfopRemessa:= GETMV("MV_#CFRORD")
     
	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT D1_FILIAL,
			       D1_DOC,
			       D1_SERIE,
			       D1_FORNECE,
			       D1_CF,
				   D1_TES,
				   D1_LOJA, 
				   D1_FILNFOR,
				   D1_NFORDEM, 
				   D1_SERIORD,
				   D1_FORORDE,
				   D1_LOJAORD,
				   D1_ITEMORD
			  FROM SD1010
			  WHERE D1_EMISSAO             >= CONVERT(VARCHAR(8),(GETDATE()-60),112)
			    AND D1_CF                  IN ('1923','2923')
			    AND D1_FILNFOR              = %EXP:cFil%
			    AND D1_NFORDEM              = %EXP:cDocOrdem%
			    AND D1_SERIORD              = %EXP:cSerieOrdem%
			    AND D1_FORORDE              = %EXP:cFornece%   
				AND D1_LOJAORD              = %EXP:cLoja%   
				AND D1_ITEMORD              = %EXP:cItemOrdem%
                AND %Table:SD1%.D_E_L_E_T_ <> '*'
			    
	EndSQl             
RETURN(NIL)
