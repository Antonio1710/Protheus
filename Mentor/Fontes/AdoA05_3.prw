#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function ADOA05_3
	(Cadastro dos valores de aprovacao e prazos por nivel do usuario)
	@type  Function
	@author Vogas Junior
	@since 13/10/2009
	@version 02
	@history Chamado 058738 - 05/06/2020 - ADRIANO SAVOINE - Corrigido as dimenções da janela pois estava sobrepondo o primeiro campo.
	@history Chamado 058850 - 19/06/2020 - ADRIANO SAVOINE - Bloqueio para somente o Caio e o Reginaldo alterar esses valores da função, parametro MV_ALCLCRE.
	/*/


User Function AdoA05_3()

Local nopcao	:= 0
Local oDlg		:= NIL
Local oFont		:= NIL
Local oGrupo1	:= Nil
Local oGrupo2	:= Nil
Local oGrupo3	:= Nil
Local oGrupo4	:= Nil
Local oGrupo5	:= Nil
Local oGrupo6	:= Nil
Local oNivel1	:= NIl
Local oNivel2	:= NIl
Local oNivel3	:= NIl
Local oNivel4	:= NIl
Local oNivel5	:= NIl
Local oNivel6	:= NIl
Local oPrazo1	:= Nil
Local oPrazo2	:= Nil
Local oPrazo3	:= Nil
Local oPrazo4	:= Nil
Local oPrazo5	:= Nil
Local oPrazo6	:= Nil
Local nValor1	:= SuperGetMv( "FS_CREDI01", .T., 0 ) 
Local nValor2	:= SuperGetMv( "FS_CREDI02", .T., 0 )
Local nValor3	:= SuperGetMv( "FS_CREDI03", .T., 0 )
Local nValor4	:= SuperGetMv( "FS_CREDI04", .T., 0 )
Local nValor5	:= SuperGetMv( "FS_CREDI05", .T., 0 )
Local nValor6	:= SuperGetMv( "FS_CREDI06", .T., 0 )
Local nPrazo1	:= SuperGetMv( "FS_PRZMED1", .T., 0 )
Local nPrazo2	:= SuperGetMv( "FS_PRZMED2", .T., 0 )
Local nPrazo3	:= SuperGetMv( "FS_PRZMED3", .T., 0 )
Local nPrazo4	:= SuperGetMv( "FS_PRZMED4", .T., 0 )
Local nPrazo5	:= SuperGetMv( "FS_PRZMED5", .T., 0 )
Local nPrazo6	:= SuperGetMv( "FS_PRZMED6", .T., 0 )
Local lRet := .F.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro dos valores de aprovacao e prazos por nivel do usuario')

//Inicio Chamado 058850 - 19/06/2020 - ADRIANO SAVOINE



IF __cUserid $ GetMv( "MV_ALCLCRE", .F.,'000000')

	lRet := .T.
	
ELSE

	lRet := .F.

	MSGALERT("OLÁ "+ Alltrim(cUserName) + CHR(10) + CHR(13)+"Identificamos que você não tem permissão para utilizar essa função" + CHR(10) + CHR(13)+" Nesse caso você tem que solicitar para seu gerente efetuar essa alteração ou solicitar a inclusão do seu usuario do Protheus no parâmetro <FONT color= red><b>MV_ALCLCRE</b></FONT> ." , "<b>ADOA05_3</b>")

ENDIF

IF lRet = .T.

	//Fim Chamado 058850 - 19/06/2020 - ADRIANO SAVOINE
		
	//Inicio Chamado 058738 - 05/06/2020 - ADRIANO SAVOINE

	DEFINE MSDIALOG oDlg TITLE "Valores de Aprovação por Nivel" FROM 05,05 To 500,390 OF oMainWnd PIXEL 

		@ 035, 015 Group oGrupo1 To 60, 187 Label ' Nível 1 ' Of oDlg Pixel
		@ 045, 020 Say 'Valor ' Font oFont Size 118,010 Of oDlg Pixel
		@ 045, 045 MsGet oNivel1 Var nValor1 Picture '@e 999,999,999.99' of oDlg Pixel 
		@ 045, 120 Say 'Prazo Médio ' Font oFont Size 118,010 Of oDlg Pixel
		@ 045, 154 MsGet oPrazo1 Var nPrazo1 Picture '999' of oDlg Pixel 	 

		@ 065, 015 Group oGrupo2 To 90, 187 Label ' Nível 2 ' Of oDlg Pixel
		@ 075, 020 Say 'Valor ' Font oFont Size 118,010 Of oDlg Pixel      
		@ 075, 045 MsGet oNivel2 Var nValor2 Picture '@e 999,999,999.99' of oDlg Pixel 	
		@ 075, 120 Say 'Prazo Médio ' Font oFont Size 118,010 Of oDlg Pixel
		@ 075, 154 MsGet oPrazo2 Var nPrazo2 Picture '999' of oDlg Pixel 	 		
		
		@ 095, 015 Group oGrupo3 To 120, 187 Label ' Nível 3 ' Of oDlg Pixel
		@ 105, 020 Say 'Valor ' Font oFont Size 118,010 Of oDlg Pixel       
		@ 105, 045 MsGet oNivel3 Var nValor3 Picture '@e 999,999,999.99' of oDlg Pixel 	
		@ 105, 120 Say 'Prazo Médio ' Font oFont Size 118,010 Of oDlg Pixel	
		@ 105, 154 MsGet oPrazo3 Var nPrazo3 Picture '999' of oDlg Pixel 	 

		@ 125, 015 Group oGrupo4 To 150, 187 Label ' Nível 4 ' Of oDlg Pixel	
		@ 135, 020 Say 'Valor ' Font oFont Size 118,010 Of oDlg Pixel       
		@ 135, 045 MsGet oNivel4 Var nValor4 Picture '@e 999,999,999.99' of oDlg Pixel 
		@ 135, 120 Say 'Prazo Médio ' Font oFont Size 118,010 Of oDlg Pixel	
		@ 135, 154 MsGet oPrazo4 Var nPrazo4 Picture '999' of oDlg Pixel 	 

		@ 155, 015 Group oGrupo5 To 180, 187 Label ' Nível 5 ' Of oDlg Pixel		
		@ 165, 020 Say 'Valor ' Font oFont Size 118,010 Of oDlg Pixel       
		@ 165, 045 MsGet oNivel5 Var nValor5 Picture '@e 999,999,999.99' of oDlg Pixel 
		@ 165, 120 Say 'Prazo Médio ' Font oFont Size 118,010 Of oDlg Pixel	
		@ 165, 154 MsGet oPrazo5 Var nPrazo5 Picture '999' of oDlg Pixel 	 

		@ 185, 015 Group oGrupo6 To 210, 187 Label ' Nível 6 ' Of oDlg Pixel		
		@ 195, 020 Say 'Valor ' Font oFont Size 118,010 Of oDlg Pixel       
		@ 195, 045 MsGet oNivel6 Var nValor6 Picture '@e 999,999,999.99' of oDlg Pixel 
		@ 195, 120 Say 'Prazo Médio ' Font oFont Size 118,010 Of oDlg Pixel	
		@ 195, 154 MsGet oPrazo6 Var nPrazo6 Picture '999' of oDlg Pixel 	 

	//Fim Chamado 058738 - 05/06/2020 - ADRIANO SAVOINE

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, oDlg:End()},{||nOpcao:=0,oDlg:End()})

	If nOpcao == 1

		PutMv( "FS_CREDI01", nValor1 )
		PutMv( "FS_CREDI02", nValor2 )
		PutMv( "FS_CREDI03", nValor3 )
		PutMv( "FS_CREDI04", nValor4 )
		PutMv( "FS_CREDI05", nValor5 )
		PutMv( "FS_CREDI06", nValor6 )
		PutMv( "FS_PRZMED1", nPrazo1 )
		PutMv( "FS_PRZMED2", nPrazo2 )
		PutMv( "FS_PRZMED3", nPrazo3 )
		PutMv( "FS_PRZMED4", nPrazo4 )
		PutMv( "FS_PRZMED5", nPrazo5 )
		PutMv( "FS_PRZMED6", nPrazo6 )

	Endif

	
ENDIF

Return Nil
