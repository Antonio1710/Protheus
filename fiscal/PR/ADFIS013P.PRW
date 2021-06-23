#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "fileio.ch"
#include "FWMVCDef.ch"

/*/{Protheus.doc} User Function ADFIS013P
	Efetua leitura de arquivo CSV e grava na tabela ZBL referente ao bloco K200 do SPED Fiscal 
	Leiaute:FILIAL;CODIGO PRODUTO;SALDO;CODIGO FORNECEDOR;LOJA
	Exemplo:     
	Filial;CODIGO;QTD.SALDO;FORN.;LOJA
	02;307096;359.550;;
	02;307096;6000.000;018435;01
	02;307098;133666.200;;
	02;308285;1363.930;;
	02;308285;100.100;018435;01
	A rotina dá opção de apenas validar as informações para posteriormente serem gravadas.
	@type  Function
	@author Adriana Oliveira
	@since 26/01/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 5157 - Fernando Macieira - 26/11/2020 - Alteração rotina BLOCO K
/*/
User Function ADFIS013P()

	//memowrite("\LOGRDM\"+ALLTRIM(PROCNAME())+".LOG",Dtoc(date()) + " - " + time() + " - " +alltrim(cusername)) // Everson - 17/07/2017. Chamado 036032.

	_nHdl    	:= Nil             // Handle para abertura do arquivo
	_cBuffer	:= ""		       // Variavel para leitura
	_cDelimit	:= ";"             // Delimitador do arquivo CSV
	_cArq    	:= space(40)
	_nLin     	:= 0
	cFileLog 	:= ""
	_cPath 		:= ""
	nOpc 		:= 0
	cChar		:= "N"
	_lAbortado	:= .F.
	_dDtRef     := LastDate(date()-30)
	_cQueryD 	:= ""
	_nCampo		:= 0
	_cFilial 	:= ''
	_cProduto 	:= ''
	_nSaldo 	:= 0
	_cIndEst	:= ''
	_cCodFor 	:= ''
	_cLojaFor 	:= ''
	_nLinImp	:= 0

	// @history ticket 5157 - Fernando Macieira - 26/11/2020 - Alteração rotina BLOCO K
	cUsrAut  := GetMV("MV_#USRZBL",,"000000#001428#002160#002090") // Usuarios autorizados

	_cArq := cGetFile("Arquivos TXT | *.TXT",;
    ("Bloco K - Selecione o arquivo que será importado"), 0, "Servidor\", .t., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)// + GETF_RETDIRECTORY)

    If !At(".TXT", upper(_cArq)) > 0

        Aviso("ADFIS013P-01", "Não foi possível abrir o arquivo...", {"&Ok"},, "Arquivo não identificado!")

    Else

		DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Carrega dados para Bloco K200 SPED Fiscal") From 100,0 To 225,575 PIXEL
		@ 05,20 SAY "Importar Arquivo:"	SIZE 200,007 OF _oDlg PIXEL
		@ 03,100 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL
		@ 20,20 SAY "Data Referencia ?        "	SIZE 200,007 OF _oDlg PIXEL
		@ 18,100 MSGet odDtRef VAR _dDtRef Size 080,10 OF _oDlg PIXEL
		@ 35,20 SAY "Atualiza cadastro (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
		@ 33,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

		DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
		DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

		ACTIVATE MSDIALOG  _oDlg CENTERED

		if nOpc = 1
			
			Processa({||U_ImpK200()},"Importando TXT para Protheus (ZBL)","Processando aguarde...", .F.)
			
			// @history ticket 5157 - Fernando Macieira - 26/11/2020 - Alteração rotina BLOCO K
			If RetCodUsr() $ cUsrAut
				axCadastro("ZBL")
			EndIf
			//

		endif
	
	EndIf

Return Nil

/*/{Protheus.doc} User Function IMPK200
	Processa importacao K200 para tabela ZBL	
	@type  Function
	@author Adriana Oliveira
	@since 26/01/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 5157 - Fernando Macieira - 26/11/2020 - Alteração rotina BLOCO K
/*/
User Function ImpK200()

	dbSelectArea("ZBL")
	dbSetOrder(1)
	If dbSeek(xFilial("ZBL") + cFilAnt + DtoS(_dDtRef)  )
		
		If !MsgBox("Já existem dados para esta data. Reimporta Período?","ADFIS013P","YESNO")
			return
		else
			_cQueryD := "DELETE FROM " + RETSQLNAME("ZBL") + " WHERE ZBL_DT_EST = '" + DtoS(_dDtRef) + "'" //+ "' AND ZBL_UNIDAD = '" + cFilAnt + "'"
			TCSQLExec(_cQueryD)
		endif
		
	Endif

	lArqOK := .t.

	_nHdl := fOpen(_cArq,2) // Abre o arquivo
	fClose(_nHdl)

	If _nHdl = -1
		Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
		
	else
		
		ft_fUse(_cArq) 	//Abre o arquivo
		ProcRegua(FT_FLastRec(_nHdl))
		ft_fGoTop()		//Posiciona no inicio do arquivo
		
		Do While !ft_fEOF()

			_cBuffer := ft_fReadLn()
			_cBuffer := _cBuffer + ";"     //incluido para considerar ultimo campo
			
			_nCampo		:= 0
			
			_cFilial 	:= ''
			_cProduto 	:= ''
			_nSaldo 	:= 0
			_cIndEst	:= ''
			_cCodFor 	:= ''
			_cLojaFor 	:= ''
			
			_nLin ++
			
			if _nLin > 1

				Do While Rat(_cDelimit, _cBuffer) > 0
					
					_nCampo ++
					
					if _nCampo = 1
						_cFilial := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
					elseif _nCampo = 2
						_cProduto := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
					elseif _nCampo = 3
						_nSaldo := Val(Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1))
					elseif _nCampo = 4
						_cCodFor := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
					elseif _nCampo = 5
						_cLojaFor := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
					endif
					
					_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
					
				EndDo
				
				if _nSaldo < 0
					AutoGrLog("Linha "+strzero(_nlin,10)+" Saldo Neg. "+Str(_nSaldo,13,3)+"   nao permitido")
					lArqOk := .f.
				endif

				dbselectarea("SB1")
				dbsetorder(1)
				if !dbseek(xfilial("SB1")+_cProduto)
					AutoGrLog("Linha "+strzero(_nlin,10)+" Produto    "+_cProduto+"   nao encontrado")
					lArqOk := .f.
				elseif !(Alltrim(SB1->B1_TIPO) $ "MP PA PI")
					AutoGrLog("Linha "+strzero(_nlin,10)+" Produto    "+_cProduto+"   B1_TIPO <> MP PA PI ("+SB1->B1_TIPO+")")
					lArqOk := .f.
				endif       
				
				if _cCodFor <> ""
					dbselectarea("SA2")
					dbsetorder(1)
					if !dbseek(xfilial("SA2")+_cCodFor+_cLojaFor)
						AutoGrLog("Linha "+strzero(_nlin,10)+" Fornecedor "+_cCodFor+_cLojaFor+" nao encontrado")
						lArqOk := .f.
					else
						_cIndEst := "1"
					endif
				else
					_cIndEst := "0"
					
				endif

				// @history ticket 5157 - Fernando Macieira - 26/11/2020 - Alteração rotina BLOCO K
				If _cIndEst == "1"
					ChkSB6(@_cIndEst)
				EndIf
				//
				
				dbSelectArea("ZBL")
				dbSetOrder(1)
				If dbSeek(xFilial("ZBL") + 	_cFilial + DtoS(_dDtRef) + _cProduto + _cIndEst +_cCodFor+_cLojaFor )
					AutoGrLog("Linha "+strzero(_nlin,10)+" Filial+Data+Produto+Ind.Estoque+Fornecedor+Loja "+_cFilial + DtoS(_dDtRef) + _cProduto + _cIndEst +_cCodFor+_cLojaFor+" Duplicada")
					lArqOk := .f.
				Endif
				
				if lArqOk
					
					if cChar = 'S'
						
						if Reclock("ZBL",.t.)
	
								ZBL->ZBL_FILIAL 	:= ""
								ZBL->ZBL_UNIDAD		:= _cFilial
								ZBL->ZBL_DT_EST		:= _dDtRef
								ZBL->ZBL_COD_IT		:= _cProduto
								ZBL->ZBL_QTD		:= _nSaldo
								ZBL->ZBL_IND_ES		:= _cIndEst
								ZBL->ZBL_COD_PA		:= iif(_cIndEst="1","SA2"+_cCodFor+_cLojaFor,"")      //"SA2"+_cFilial+_cCodFor+_cLojaFor,"") Alterado por Adriana em 15/03/17

							ZBL->( Msunlock() )
							
							_nLinImp ++

						endif
						
					endif
					
				endif
				
			Endif
			
			If LastKey() == 27
				_lAbortado := .T.
				Exit
			Endif
			
			IncProc()
			
			ft_fSkip()		//Pula linha
			
		end

	endif

	_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
	_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
	_cPath    := Substr(_cArq,1,RAt("\",_cArq))

	MostraErro(_cPath,_cFileLog)
	Aviso( OemToAnsi("IMPORTAÇÃO "+iif(_lAbortado,"INTERROMPIDA","CONCLUÍDA")+" !!!"),;
	OemToAnsi("Lidos: "+Strzero(_nLin,10)+" Importados: "+Strzero(_nLinImp,10))+;
	CHR(13)+CHR(10)+iif(_lAbortado,"Processamento Abortado pelo Operador","")+;
	CHR(13)+CHR(10)+iif(_nLin-_nLinImp>0,"Verifique LOG em "+_cPath+_cFileLog,"");
	,{"Sair"} )

	If _nHdl <> -1
		fClose(_nHdl)
	endif

Return

/*/{Protheus.doc} Static Function ChkSB6(@_cIndEst)
	Define se o produto é da Adoro em poder de terceiro, campo B6_TIPO (E=Em Terceiros;D=De Terceiros)
	@type  Static Function
	@author Fernando Macieira
	@since 26/11/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ChkSB6(_cIndEst)

	Local cQuery  := ""

	If Select("WorkB6") > 0
		WorkB6->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT
	cQuery += " FROM " + RetSqlName("SB6") + " (NOLOCK)
	cQuery += " WHERE B6_FILIAL='"+_cFilial+"'
	cQuery += " AND B6_PRODUTO='"+_cProduto+"' 
	cQuery += " AND B6_DTDIGIT LIKE '"+Left(DtoS(_dDtRef),6)+"' 
	cQuery += " AND B6_TIPO='E'
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "WorkB6"

	
	WorkB6->( dbGoTop() )
	If WorkB6->TT >= 1
		_cIndEst := "2" // Estoque de propriedade da Adoro em posse de terceiro
	EndIf

	If Select("WorkB6") > 0
		WorkB6->( dbCloseArea() )
	EndIf

Return
