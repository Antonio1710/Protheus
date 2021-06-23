#include "rwmake.ch"
#Include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RETVALE3  ³ WILLIAM COSTA       ³ Data ³ 18/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna valor total de duplicata da nf de entrada³±±
±±³          |  para LP 665                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB E SIGACOM                                ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamados  ³ 047566 - FWNM - 06/03/2019 - LP 665/001          º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function RETVALE3()

	Local _nValorSE2 :=0
	Local _aArea := GetArea()
	Local _aAreaSE2 := SE2->(GetArea())
	Local _aAreaSF1 := SF1->(GetArea())
	Local _aAreaSF4 := SF4->(GetArea()) // Chamado n. 047566 - FWNM - 06/03/2019 
	Local _cEspecie := IF(EMPTY(SF1->F1_ESPECIE),"NF",SF1->F1_ESPECIE)  
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Retorna valor total de duplicata da nf de entrada para LP 665 ')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Todos os Indices Necessarios                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Chamado n. 047566 - FWNM - 06/03/2019
	// Posiciono TES
	SF4->( dbSetOrder(1) ) // F4_FILIAL + F4_CODIGO 
	If SF4->( dbSeek( FWxFilial("SF4")+SD1->D1_TES ) )
	                                                                                       &&Chamado 006837 - Mauricio - 24/05/10.
		If SF4->F4_XCTB == "S" .AND. SF4->F4_XTM $ "E01/E04" .AND. SD1->D1_TIPO <> "D" .AND. !(ALLTRIM(SD1->D1_SERIE)=="ST" .Or. ALLTRIM(SD1->D1_SERIE)== "ICM" .Or. ALLTRIM(SD1->D1_SERIE)== "PAR")  //!ALLTRIM(SD1->D1_SERIE)$"ST/ICM"   &&Chamado 004850 - HC Consys Mauricio.
		
			// ***************** INICIO ALTERACAO CHAMADO 024322 ********************************************** //
		    SqlTitPag(Xfilial("SE2"),SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_SERIE,SF1->F1_DOC)
		        
			/*BEGINDOC
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³apos a atualizacao do sistema protheus no dia 03/08/2015, passou-se no momento do estorno da classificacao³
			//³da nota de entrada foi alterado pela totvs, anteriormente fazia o seguinte processo:                      ³
			//³ESTORNO NF COMPRAS -> LANCAMENTOS PADROES -> EXCLUSAO DO TITULO                                           ³
			//³agora com a alteracao ficou assim                                                                         ³
			//³ESTORNO NF COMPRAS -> EXCLUSAO DO TITULO -> LANCAMENTOS PADROES                                           ³
			//³portanto foi refeito esse select para ler arquivos do SE2 deletados mais ordenado por R_E_C_N_O_          ³
			//³para garantir que pegue o ultimo excluido.                                                                ³
			//³EXPLICACAO POR WILLIAM COSTA                                                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ENDDOC*/
		    
		    While TRB->(!EOF())
		    
		    	IF TRB->E2_VALOR <= TRB->F1_VALBRUT
		    				
		    		_nValorSE2:= _nValorSE2 + TRB->E2_VALOR 
				
				ELSE
				
					_nValorSE2:= _nValorSE2 + TRB->F1_VALBRUT
				
				ENDIF       	
		        TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea()) 
			// ***************** INICIO ALTERACAO CHAMADO 024322 ********************************************** //
			
		Endif
	EndIf
	
	RestArea(_aAreaSF4)  // Chamado n. 047566 - FWNM - 06/03/2019
	RestArea(_aAreaSE2)
	RestArea(_aAreaSF1)
	RestArea(_aArea)

Return(_nValorSE2)

Static Function SqlTitPag(cFil,cFornece,cLoja,cPrefixo,cDoc)                        

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT TOP(1) SE2.E2_VALOR,SF1.F1_VALBRUT
			  FROM %Table:SE2% SE2 WITH(NOLOCK) ,%Table:SF1% SF1 WITH(NOLOCK) 
			WHERE SE2.E2_FILIAL  = %EXP:cFil%
			  AND SE2.E2_FORNECE = %EXP:cFornece%
			  AND SE2.E2_LOJA    = %EXP:cLoja%
			  AND SE2.E2_PREFIXO = %EXP:cPrefixo%
			  AND SE2.E2_NUM     = %EXP:cDoc%
			  AND SE2.E2_FILIAL  = SF1.F1_FILIAL
			  AND SE2.E2_NUM     = SF1.F1_DOC
			  AND SE2.E2_PREFIXO = SF1.F1_SERIE
			  AND SE2.E2_FORNECE = SF1.F1_FORNECE
			  AND SE2.E2_LOJA    = SF1.F1_LOJA 
			  
			  ORDER BY SE2.R_E_C_N_O_ DESC
  
    EndSQl             
RETURN(NIL) 