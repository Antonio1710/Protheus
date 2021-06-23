#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADOA05_2  ºAutor  ³Vogas Junior        º Data ³  17/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz as gravacoes na tabela de historico/log PA9             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Ado05Log( cCodvend, cLoja, cNomeUsr, dData, cCampo, CampoAnt, CampoDep )	

Local aArea := GetArea()
Local cMensagem	:= '' 

Default cloja := '  ' 

U_ADINF009P('ADOA05_2' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Faz as gravacoes na tabela de historico/log PA9')

// Filtra os tipos de campos que serao logados.
If !ValType( CampoAnt ) $'ABMOU'.And. !Valtype( CampoDep ) $'ABMOU'

	// compatibiliza tipo dos campos para gravar char.
	If ValType( CampoAnt ) == 'N'
		CampoAnt := Str( CampoAnt )
	Endif
	
	If ValType( CampoAnt ) == 'D'
		CampoAnt := DtoC( CampoAnt )
	Endif
	
	If ValType( CampoAnt ) == 'L'
		If CampoAnt 
			CampoAnt := 'Verdadeiro'
		Else
			CampoAnt := 'Falso'
		Endif
	Endif
	
	If ValType( CampoDep ) == 'N'
		CampoDep := Str( CampoDep )
	Endif
	
	If ValType( CampoDep ) == 'D'
		CampoDep := DtoC( CampoDep )
	Endif
	
	If ValType( CampoDep ) == 'L'
		If CampoDep 
			CampoDep := 'Verdadeiro'
		Else
			CampoDep := 'Falso'
		Endif		
	EndIf
	
	DbSelectArea( 'PB9' )
	RecLock('PB9',.T.)
	
	PB9->PB9_FILIAL	:= XFILIAL('PB9')
	PB9->PB9_CODIGO := cCodvend
	PB9->PB9_LOJA	:= cLoja
	PB9->PB9_USUARI	:= cNomeUsr	
	PB9->PB9_DATA	:= dData
	PB9->PB9_HORA	:= Time()
	PB9->PB9_CPOALT := cCampo
	PB9->PB9_CPOANT	:= CampoAnt
	PB9->PB9_CPODEP	:= CampoDep
	
	PB9->( MsUnLock())

	cMensagem	:= 'Cliente '+cCodvend+'-'+cLoja+ " Usuario: "+__cUserId+ '-' + cNomeUsr +', em '  +DtoC( dData ) + ' as ' + Time() + ' Alterou campo ' +;
 					cCampo + ' De: '+ CampoAnt + 'Para: ' + CampoDep	
	
Endif
RestArea( aArea)
Return ( cMensagem )
