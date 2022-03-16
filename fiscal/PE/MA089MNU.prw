
#include "protheus.ch"
#include "topconn.ch"
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} User Function MA089MNU
	Rotina para replicar TES Inteligente para demais UFs
	@type  Function
	@author Fernando Macieira
	@since 28/08/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 69883 - Fernando Macieira - 16/03/2022 - U_REPSFMUF(MA089MNU.PRW) 28/08/2018 21:54:07 line : 122 - Cadastro de TES Inteligente
/*/
User Function MA089MNU()

	Local aArea := GetArea()

	ADD OPTION aRotina TITLE "Relica UF" ACTION "U_REPSFMUF()" OPERATION 9 ACCESS 0

	RestArea(aArea)

Return aRotina

/*/{Protheus.doc} User Function REPSFMUF()
	Rotina para replicar um TES Inteligente para demais UFs
	@type  Function
	@author Fernando Macieira
	@since 28/08/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 
/*/
User Function REPSFMUF()

	Local aCampos		:= {}
	Local aColumns		:= {}
	Local nX			:= 0
	Local cAliasX5		:= GetNextAlias()
	Local oDialogMK	 	:= Nil
	Local oMrkBrowse 	:= Nil
	Local cAliasTemp	:= GetNextAlias() //" "
	Local cSlctSX5		:= "% "
	Local lMarcar  		:= .F.
	Local aStructTrb 	:= SX5->(DbStruct())
	Local aCampoGrid 	:= {"X5_CHAVE","X5_DESCRI"}
	Local cIndice1		:= ""
	Local aFiltro		:= {}
	Local aRetCopy   	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})

	Local nRecNoSFM := SFM->( Recno() )

	//Default lMark := .F.

	Private oTempTable // @history ticket 69883 - Fernando Macieira - 16/03/2022 - U_REPSFMUF(MA089MNU.PRW) 28/08/2018 21:54:07 line : 122 - Cadastro de TES Inteligente

	SFM->( dbGoto( nRecNoSFM ) )

	If !msgYesNo("Confirma replicação do TES Inteligente " + Iif(Empty(AllTrim(SFM->FM_TE)),AllTrim(SFM->FM_TS),AllTrim(SFM->FM_TE)) + ", " + AllTrim(SFM->FM_TIPO) + ", " + AllTrim(SFM->FM_PRODUTO) + ", " + AllTrim(SFM->FM_EST) + " ?")
		Return
	EndIf

	//Define Menu
	aRotina := {}

	For nX:=1 To Len(aStructTrb)  //Colunas que serão exibidas no browse
		
		If !aStructTrb[nX][1]=="MARK" .And. Ascan(aCampoGrid,aStructTrb[nX][1])>0
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStructTrb[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructTrb[nX][1]))
			aColumns[Len(aColumns)]:SetSize(aStructTrb[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStructTrb[nX][4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SX5",aStructTrb[nX][1]))
			
			aAdd(aFiltro	,{aStructTrb[nX][1];
			,aStructTrb[nX][1];
			,aStructTrb[nX][2];
			,aStructTrb[nX][3];
			,aStructTrb[nX][4];
			,PesqPict("SX5",aStructTrb[nX][1])})
		EndIf
		
		//Query SX5
		cSlctSX5 += aStructTrb[nX,1]+", "
		
	Next nX

	//Query SX5
	cSlctSX5 += " SX5.*,' ' AS MARK "
	cSlctSX5 +='%'

	BeginSql Alias cAliasX5
		SELECT
		%Exp:cSlctSX5%
		FROM
		%Table:SX5% SX5
		WHERE
		SX5.X5_FILIAL=%xFilial:SX5% AND
		SX5.X5_TABELA='12' AND
		SX5.%NotDel%
		ORDER BY SX5.X5_CHAVE
	EndSql

	//@history ticket 69883 - Fernando Macieira - 16/03/2022 - U_REPSFMUF(MA089MNU.PRW) 28/08/2018 21:54:07 line : 122 - Cadastro de TES Inteligente

	//Cria arquivo temporário
	/*
	cAliasTemp := CriaTrab(aStructTrb,.T.)
	Copy To &cAliasTemp

	//Criar indices
	cIndice1 := Alltrim(CriaTrab(,.F.))

	//Se indice existir excluir
	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	DbUseArea( .T.,,cAliasTemp,cAliasTemp, .T., .F. )

	//índice temporário
	IndRegua(cAliasTemp, cIndice1, "X5_FILIAL+X5_CHAVE",,, "Estados")

	//Acrescenta índice
	dbSetIndex(cIndice1+OrdBagExt())
	*/

	// https://tdn.totvs.com.br/display/framework/FWTemporaryTable
	oTempTable := FWTemporaryTable():New(cAliasTemp)
	
	aAdd( aCampos, {'X5_FILIAL'    ,TamSX3("X5_FILIAL")[3]    ,TamSX3("X5_FILIAL")[1], 0} )
	aAdd( aCampos, {'X5_TABELA'    ,TamSX3("X5_TABELA")[3]    ,TamSX3("X5_TABELA")[1], 0} )
	aAdd( aCampos, {'X5_CHAVE'     ,TamSX3("X5_CHAVE")[3]     ,TamSX3("X5_CHAVE")[1],  0} )
	aAdd( aCampos, {'X5_DESCRI'    ,TamSX3("X5_DESCRI")[3]    ,TamSX3("X5_DESCRI")[1], 0} )
	aAdd( aCampos, {'MARK'         ,"C"                       ,1,                      0} )

	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"X5_FILIAL","X5_CHAVE"} )
	oTempTable:Create()

	// Populo arquivo trb para markbrowse
	( cAliasX5 )->( dbGoTop() )
	Do While (cAliasX5)->( !EOF() )

		RecLock(cAliasTemp, .T.)
		
			(cAliasTemp)->X5_FILIAL := (cAliasX5)->X5_FILIAL
			(cAliasTemp)->X5_TABELA := (cAliasX5)->X5_TABELA
			(cAliasTemp)->X5_CHAVE  := (cAliasX5)->X5_CHAVE
			(cAliasTemp)->X5_DESCRI := (cAliasX5)->X5_DESCRI

		(cAliasTemp)->( msUnLock() )

		(cAliasX5)->( dbSkip() )

	EndDo
	//

	//Fecha query
	If Select(cAliasX5) > 0
		DbSelectArea(cAliasX5)
		DbCloseArea()
	EndIf

	//Inicia Browse
	If !(cAliasTemp)->( EOF() )
		
		oMrkBrowse := FWMarkBrowse():New()
		oMrkBrowse:SetOwner(oDialogMK)
		oMrkBrowse:SetDescription("Replicar TES Inteligente para estados selecionados")
		
		oMrkBrowse:SetMenuDef("")
		oMrkBrowse:ForceQuitButton()
		oMrkBrowse:DisableConfig(.F.)
		oMrkBrowse:DisableReport(.F.)
		oMrkBrowse:DisableDetails(.T.)
		oMrkBrowse:SetWalkThru(.F.)
		
		oMrkBrowse:oBrowse:SetUseFilter(.T.)
		oMrkBrowse:oBrowse:SetDBFFilter()
		oMrkBrowse:oBrowse:SetFieldFilter(aFiltro)
		
		oMrkBrowse:SetAlias(cAliasTemp)
		oMrkBrowse:SetColumns(aColumns)
		
		oMrkBrowse:SetFieldMark("MARK")
		oMrkBrowse:SetMark('X', cAliasTemp, "MARK")
		oMrkBrowse:SetAllMark( { || .T. } )
		oMrkBrowse:bAllMark := { || InvertSel(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.F. ), oMrkBrowse:Refresh(.T.)  }
		
		oMrkBrowse:AddButton("Copiar", { || FwMsgRun(,{|oSay| CopySFM(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.T.)},'Aguarde',"Replicando TES Inteligente " + AllTrim(SFM->FM_TIPO) + ", " + AllTrim(SFM->FM_PRODUTO) + ", " + AllTrim(SFM->FM_EST) + "["+Time()+"] ...",),msgInfo("Replica UF finalizado!"),oMrkBrowse:GetOwner():End()},,2 )
		oMrkBrowse:AddButton("Inverter Seleção", { || InvertSel(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.T. ),oMrkBrowse:Refresh(.T.)},,2 )
		oMrkBrowse:AddButton("Cancelar", { || oMrkBrowse:GetOwner():End()},,2 )
		
		oMrkBrowse:Activate()
		
	Else
		Help(" ",1,"RECNO")
	EndIf

	//@history ticket 69883 - Fernando Macieira - 16/03/2022 - U_REPSFMUF(MA089MNU.PRW) 28/08/2018 21:54:07 line : 122 - Cadastro de TES Inteligente
	/*
	//Se indice existir excluir
	If File(cIndice1+OrdBagExt())
		FErase(cIndice1+OrdBagExt())
	EndIf

	//Limpar o arquivo temporário
	If !Empty(cAliasTemp)
		Ferase(cAliasTemp+GetDBExtension())
		Ferase(cAliasTemp+OrdBagExt())
		(cAliasTemp)->(DbCloseArea())
		cAliasTemp:=""
	Endif
	*/

	oTempTable:Delete()

	If Select(cAliasTemp) > 0
		(cAliasTemp)->( dbCloseArea() )
	EndIf
	//

	//Restaura Menu
	aRotina:=AClone(aRetCopy)

Return

/*/{Protheus.doc} Static Function InvertSel
	Rotina para replicar um TES Inteligente para demais UFs
	@type  Function
	@author Fernando Macieira
	@since 28/08/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 
/*/
Static Function InvertSel(cAlias,cMarca,lMarcar, lInvert)

	Local aAreaSX5  := (cAlias)->( GetArea() )

	(cAlias)->( dbGoTop() )

	Do While !(cAlias)->( EOF() )
		
		RecLock( (cAlias), .F. )
		
		If lInvert
			(cAlias)->MARK := IIf( (cAlias)->MARK == cMarca , '  ',cMarca )
		Else
			(cAlias)->MARK := IIf( lMarcar, cMarca, '  ' )
		Endif
		
		MsUnlock()
		
		(cAlias)->( dbSkip() )
		
	EndDo

	RestArea( aAreaSX5 )

Return .T.

/*/{Protheus.doc} Static Function CopySFM
	Rotina para replicar um TES Inteligente para demais UFs
	@type  Function
	@author Fernando Macieira
	@since 28/08/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 
/*/
Static Function CopySFM(cAliasQry,lMark)

	Local aDados	:= {}
	Local aEstrut	:= SFM->(dbStruct()) //Monta estrutura da SFM
	Local cTabela	:= 'SFM'
	Local cFilCad	:= cFilAnt
	Local cEmpCad	:= cEmpAnt
	Local nCont		:= 0
	Local cMensagem	:= ''
	Local lProc		:= .T.
	Local nRecNoSFM := SFM->( Recno() )
	Local cUFOrigem := ""

	Default lMark := .F.

	SFM->( dbGoto( nRecNoSFM ) )
	cUFOrigem := SFM->FM_EST

	//Inicia transação
	Begin Transaction
		
		(cAliasQry)->( DbGoTop() )
		Do While !(cAliasQry)->( EOF() )
			
			RegToMemory("SFM",.F.)
			
			//Função que realizar cópia para filial de destino
			GrvTab(aEstrut, cAliasQry, cTabela, lMark, cUFOrigem)
			
			(cAliasQry)->(dbSkip())
			
		EndDo
		
		//Limpa Objeto e Arquivo Temporario
		If !Empty(cAliasQry)
			Ferase(cAliasQry+GetDBExtension())
			Ferase(cAliasQry+OrdBagExt())
			cAliasQry := ""
		Endif
		
	//Fecha transação
	End Transaction

Return

/*/{Protheus.doc} Static Function GrvTab
	Rotina para replicar um TES Inteligente para demais UFs
	@type  Function
	@author Fernando Macieira
	@since 28/08/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 
/*/
Static Function GrvTab(aEstrut, cAliasQry, cTabela, lMark, cUFOrigem)

	Local nCont		:= 0
	Local cLinha	:= ''

	//Ignora estado nao marcado
	If Empty( (cAliasQry)->MARK )
		Return
	Endif

	// Não duplica UF já existente caso o usuário remarque no mark
	If AllTrim((cAliasQry)->X5_CHAVE) == AllTrim(cUFOrigem)
		Return
	EndIf

	//Inclui nova linha na tabela
	RecLock(cTabela,.T.)

	//Gravação do campo _FILIAL será sempre com retorno do xFilial()
	&(cTabela + "->" + Iif(Substr(cTabela,1,1) == 'S', Substr(cTabela,2,2) ,cTabela )   + "_FILIAL" ) := xFilial(cTabela)

	//Laço nos campos da tabela estrutura do SX3
	For nCont := 1 to Len(aEstrut)
		
		If aEstrut[nCont][2] <> 'M'
			
			//Campo Filial não será copiado, já foi gravado anteriormente com conteúdo do xFilial
			If !"FILIAL" $ aEstrut[nCont][1]
				
				//Para campo tipo Date preciso utilizar a função TcSetField para que não ocorra erro de Type Mismatch
				If aEstrut[nCont][2] == 'D'
					&(cTabela + "->" +aEstrut[nCont][1] ) := StoD((cAliasQry)->&(aEstrut[nCont][1]))
					
				Else
					
					If aEstrut[nCont][2] == 'L'
						
						If (cAliasQry)->&(aEstrut[nCont][1]) == "T"
							&(cTabela + "->" +aEstrut[nCont][1] ) := .T.
						Else
							&(cTabela + "->" +aEstrut[nCont][1] ) := .F.
						EndIf
						
					Else
						
						// Campo Estado será gravado com o conteúdo selecionado do markbrowse
						If AllTrim(aEstrut[nCont][1]) == "FM_EST"
							&(cTabela + "->" +aEstrut[nCont][1] ) := AllTrim((cAliasQry)->X5_CHAVE)
						Else
							&(cTabela + "->" +aEstrut[nCont][1] ) := (cAliasQry)->&(aEstrut[nCont][1])
						EndIf
						
					EndIF
					
				EndIF
				
			EndIf
			
		EndIf
		
		
	Next nCont

	MsUnLock()

Return
