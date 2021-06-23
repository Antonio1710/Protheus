#include "rwmake.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M410FSQL ³ Autor ³ Mauricio - MDS TEC  ³ Data ³ 17/09/14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtro para pedidos de venda para que cada supervisor veja ³±±
±±³          ³ somente os seus pedidos de venda. Baseado no AD0079.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Comercial                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³                                                            ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao : 23/11/18 chamado 045404 Fernando Sigoli	              ³±±
±±³              Alterado Filtro de pedidos para usaurio que incluir PV   ³±±
±±³				 bonificação                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION M410FSQL()

Local aArea		:= Getarea()
Local cFiltro 	:= ""
Local _aCodSup 	:= {}
Local _cSupV 	:= ""
Local cVisBon   := Alltrim(GETMV("MV_#VISUAP"))

VAR_IXB := {"","",""}   //Limpa variavel publica

_cUserName := Alltrim(cUsername)

//Incluido por Adriana para tratamento de pedido de bonificacao pela qualidade em 20/05/2015
If Alltrim(cEmpAnt) == "01"    //Incluido por Adriana devido ao error.log quando empresa <> 01 - chamado 032804	
	if __cuserid $ GETMV("MV_#USUBON")
		//cFiltro := "(C5_APRVDOA =  '"+Alltrim(GETMV("MV_#APRBON"))+"')" // Ricardo Lima - 07/12/17 - Novo padrao protheus 12 sql
		//cFiltro := "C5_APRVDOA =  '"+Alltrim(GETMV("MV_#APRBON"))+"'" 
		
		cFiltro := "C5_APRVDOA $ '"+ cVisBon +"'" //chamado 045404 - Fernando Sigoli	
		
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 1a. Verificacao - E' Gerente ?                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Alltrim(_cUserName) $ GetMV("MV_GERENTE")         // Se for gerente nao tem Filtro
		//Mauricio - 02/07/04 - novo processo citado acima....
		_cCodUs := __cUserID
				
		dbSelectArea("SA3")
		dbSetOrder(7)
		If dbSeek( xFilial("SA3")+_cCodUs )
			If SA3->A3_NIVETAB == "2"  //Supervisor
				_aCodSup := {}
				While SA3->(!Eof()) .And. SA3->A3_CODUSR == _cCodUs
					AADD(_aCodSup,{SA3->A3_SUPER})
					SA3->(dbSkip())
				Enddo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Armazena em _cSupVends todos os Vendedores do Supervisor     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_cSupV  := ""
				
				For _ni := 1 to len(_aCodSup)
					dbSelectArea("SA3")
					dbSetOrder(5)        // A3_FILIAL+A3_SUPER
					If dbSeek( xFilial("SA3")+_aCodSup[_ni][1] )
						Do While !Eof() .and. xFilial("SA3") == SA3->A3_FILIAL	.and. ;
							_aCodSup[_ni][1]       == SA3->A3_SUPER
							//_cSupV  :=  _cSupV + SA3->A3_COD+";"
							IF ! SA3->A3_COD $ _cSupV 
							 _cSupV  += SA3->A3_COD + "|"  //atualização da V12. fernando Sigoli 21/11/2017  http://tdn.totvs.com/display/public/PROT/ADV0012_PE_M410FSQL
							ENDIF
							SA3->(dbSkip())
						Enddo
					Endif
				Next _ni
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra PV's e Clientes pelos Vendedores do Supervisor        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(_cSupV)
					//cFiltro := "C5_VEND1 IN " + FormatIn(_cSupV,";")//atualização da V12. fernando Sigoli 21/11/2017  http://tdn.totvs.com/display/public/PROT/ADV0012_PE_M410FSQL
					cFiltro := "C5_VEND1 $ '"+ _cSupV +"'"					  
					//cFiltro := "@(C5_VEND1 IN " + FormatIn(_cSupV,";") + ")" // Ricardo Lima - 07/12/17 - Novo padrao protheus 12 sql
										
					//Incluido por Adriana para substituir o ponto de entrada MT410BRW  em 20/05/2015
					VAR_IXB[3] := _cSupV      //variavel publica
					dbSelectArea("SA1")
					Set Filter to A1_VEND  $ VAR_IXB[3]
				Endif
			Elseif SA3->A3_NIVETAB == "1"  //Vendedor
				_cCodVen := SA3->A3_COD              // Busca Codigo Vendedor				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra PV's e Clientes pelo Codigo do Vendedor               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SC5")
				//cFiltro := "(C5_VEND1  = '"+ _cCodVen + "')" // Ricardo Lima - 07/12/17 - Novo padrao protheus 12 sql 
				cFiltro := " C5_VEND1  = '"+ _cCodVen + "'"
				//Incluido por Adriana para substituir o ponto de entrada MT410BRW  em 20/05/2015
				VAR_IXB[3] := _cCodVen    //variavel publica
				dbSelectArea("SA1")
				Set Filter to A1_VEND  == VAR_IXB[3]
			Endif
		Endif
	Endif	
Endif  

RestArea(aArea)	
Return(cFiltro)