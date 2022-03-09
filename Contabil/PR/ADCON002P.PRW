#INCLUDE "rwmake.ch"   
#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
/*/{Protheus.doc} User Function ADCON002P
	Efetua leitura de arquivo CSV (com delimitador ;) e importa 
	para tabelas inventario padrão .dbf gerado pela rotina 
	"Registro de Inventário-Modelo 7" (MATR460) p/Sped bloco H
	Obs.: Este programa copia dados de um arquivo CSV (delimitado) e importa para 
	tabelas 2017123101_08.CSV para 2017123101_08.DBF, onde 20171231 identifica ano+mes+dia, 01 empresa e 08 filial na pasta SYSTEM.
	Segue layout CSV (padrão CSV MSDOS), tem que ser exatamente este :

	FILIAL;SITUACAO;PRODUTO;UM;QUANTIDADE;VALOR_UNIT;TOTAL;ARMAZEM;CLIFOR;LOJA;TPCF;

	Exemplo:
	03;1;100098;KG;570;1,52459649122807;869,02;05;      ;  ; 
	08;1;383369;KG;1109640;0,406332999891857;450883,35;13;      ;  ; 
	08;5;383369;KG;2518060;0,32;805779,2;99;022641;42;1
	08;5;383369;KG;5114060;0,322166613219243;1647579,39;99;009506;01;1
	08;5;383369;KG;2100000;0,32;672000;99;022750;01;1

	Estes DBF´s serão utilizados na rotina de geração do Sped Fiscal, parâmetro Wizard:
	Gera Inventário = Sim// Selecione se deseja gerar os registros de inventário (bloco H).
	Data de fechamento do estoque= Informe a data em que foi feito o fechamento do estoque, caso queira gerar os registros de inventário. 
	Onde fonte irá buscar na sua pasta /SYSTEM/ .DBF com a mesma data gerado pelo Relatório Reg. Invent. Mod. 7 (MATR460).
	Motivo do Inventário - Selecione qual o motivo do inventário: 01 – No final no período;

	@type  Function
	@author ADRIANA OLIVEIRA
	@since 05/03/15
	@version version
	@history Ticket 069236 - Abel Babini - 07/03/2022 - Ajuste para substituir DBF por tabela no Banco de Dados.
	/*/
User Function ADCON002P()

	Local	_cDBF		:= ""                                   
	Local _cFim		:= ""
	Local _j			:= 0
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	_nHdl    	:= Nil             // Handle para abertura do arquivo
	_cBuffer	:= ""		       // Variavel para leitura
	_cDelimit	:= ";"             // Delimitador do arquivo CSV
	_cArq    	:= space(80)
	_nLin     	:= 1
	_cPath 		:= ""
	nOpc 		:= 0
	_aCampos	:= {}
	_aConteudo 	:= {}
	_cCampos	:= ""

	DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Gera tabela DBF padrão Registro de Inventário-Modelo 7 para Bloco H - Sped Fiscal") From 100,0 To 225,575 PIXEL
	@ 03,20 SAY "Nome Arquivo CSV (AAAAMMDDEE_FF):"	SIZE 130,007 OF _oDlg PIXEL
	@ 20,20 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL

	DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
	DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

	ACTIVATE MSDIALOG  _oDlg CENTERED

	if nOpc <> 1
		return()
	endif

	//estrutura da tabela padrão Protheus igual a gerada pela rotina "Registro de Inventário - Modelo 7" (MATR460)
	//FILIAL;SITUACAO;PRODUTO;UM;QUANTIDADE;VALOR_UNIT;TOTAL;ARMAZEM;CLIFOR;LOJA;TPCF;
	_aDBF :=	{{"FILIAL"			, "C", 02,0},;
					{"SITUACAO"		, "C", 01,0},;
					{"PRODUTO"			, "C", 15,0},;
					{"UM"				, "C", 02,0},;
					{"QUANTIDADE"		, "N", 14,2},;
					{"VALOR_UNIT"		, "N", 18,4},;
					{"TOTAL"			, "N", 18,4},;
					{"ARMAZEM"			, "C", 02,0},;
					{"CLIFOR"			, "C", 06,0},;
					{"LOJA"			, "C", 02,0},;
					{"TPCF"			, "C", 01,0}}

	//INICIO Ticket 069236 - Abel Babini - 07/03/2022 - Ajuste para substituir DBF por tabela no Banco de Dados.
	_cArq := Alltrim(_cArq)
	_cDBF := "H_"+Alltrim(_cArq)+Alltrim(cEmpAnt)+Alltrim(cFilAnt)
	cNomeArq := "H_"+_cArq
	dbUseArea(.T.,"TOPCONN" ,cNomeArq ,"TRB_R460" ,.F. ,.F.)

	_nHdl := fOpen(alltrim(_cArq)+".CSV",2) // Abre o arquivo
	fClose(_nHdl)
	If _nHdl = -1
		Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq+".CSV"),{"Sair"} )
	else
		ft_fUse(_cArq+".CSV") 	//Abre o arquivo
		ft_fGoTop()		//Posiciona no inicio do arquivo

		Do While !ft_fEOF()
			_cBuffer := ft_fReadLn()
			IncProc(" Linha: " + STR(_nlin,10,0) )
			_cBuffer := _cBuffer + _cDelimit     //incluido para considerar ultimo campo
			
			if _nLin = 1
				Do While Rat(_cDelimit, _cBuffer) > 0
					_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
					AADD(_aCampos,Alltrim(_cTxtPos))
					_cBuffer := Substr(_cBuffer,At(_cDelimit, _cBuffer)+1)
				EndDo
				_msgCampos	:= ""
				
				ft_fSkip()		//Pula linha
				_nLin ++
				_cBuffer := ft_fReadLn()
			Endif
			
			_aConteudo :={}
			_Seq := 1
			Do While Rat(_cDelimit, _cBuffer) > 0
				_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
							if _Seq >= 5 .and. _Seq <= 7      
								_cTxtPos := StrTran(_cTxtPos,",",".")
					AADD(_aConteudo,Val(_cTxtPos))
				else
					AADD(_aConteudo,Alltrim(_cTxtPos))
				endif
				_cBuffer := Substr(_cBuffer,At(_cDelimit, _cBuffer)+1)
				_Seq++
				
			EndDo

			//Grava na tabela de Inventario para a filial correspondente
			cSituac	:= IIF(Alltrim(_aConteudo[2])=="0","1","5")
			cTpCF		:= ""
			RecLock("TRB_R460",.T.)
				TRB_R460->FILIAL		:= _aConteudo[1]
				TRB_R460->SITUACAO	:= cSituac
				TRB_R460->PRODUTO		:= _aConteudo[3]
				TRB_R460->UM				:= UPPER(_aConteudo[4])
				TRB_R460->QUANTIDADE:= _aConteudo[5]
				TRB_R460->VALOR_UNIT:= _aConteudo[6]
				TRB_R460->TOTAL			:= _aConteudo[7]
				TRB_R460->ARMAZEM		:= _aConteudo[8]
				TRB_R460->CLIFOR		:= ""//_aConteudo[9]
				TRB_R460->LOJA			:= ""//_aConteudo[10]
				TRB_R460->TPCF			:= cTpCF

			// for _j := 1 to len(_aCampos)
					// TRB_R460->&(_aCampos[_j])	:= _aConteudo[_j]
			// next
				
			TRB_R460->(MsUnlock())
				
			ft_fSkip()		//Pula linha
			_nLin ++
		EndDo

	endif
	// else
	// 	Aviso( "AVISO",OemToAnsi("Não foi possível abrir a tabela "+_cDBF+".CSV . Gere o relatório Reg. Inventário Mod P7 antes de prosseguir."),{"Sair"} )
	// endif
	//FIM Ticket 069236 - Abel Babini - 07/03/2022 - Ajuste para substituir DBF por tabela no Banco de Dados.

	lArqOK := .t.
	_cDBF->(DBCloseArea())
			

	If _nHdl <> -1
		fClose(_nHdl) // Fecha o arquivo
	endif     

	_cFim += _cDBF+" - "+Str(Reccount())+" registros."+chr(13)
	Msgbox( _cFim,"FIM","INFO" )

Return()
