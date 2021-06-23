#Include "Protheus.CH"
#include "TbiConn.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#include "rwmake.ch"
                                             
#Define CRLF  Chr( 13 ) + Chr( 10 )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraCISP  ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera informacoes para envio a CISP                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_GeraCISP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Alteração em 17/10/2014 por Luciano em atendimento ao chamado 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºAdriana     ³24/05/2019³TI-Devido a substituicao email para shared     º±±
±±º            ³          ³relay, substituido MV_RELACNT p/ MV_RELFROM    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

/*/

User Function GERACISP(nPar)

Private _lExec 		:= Iif(ValType(nPar) == 'N',.T.,.F.)	&& Verifica chamada de Menu
Private aClin		:= {}

Conout(Iif(_lExec, "Execucao por JOB", "Execucao Manual"))

If _lExec
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "02" MODULO "FAT" 
	
		U_ADRCISPB()	&& Execucao da Funcao de Processamento
	
	RESET ENVIRONMENT
Else
	Processa( { ||U_ADRCISPB() } )
EndIf

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera informacoes para envio a CISP ')

Return()
                           
/* Funcao de Execucao do CISP de acordo com definicao do chamado */
User Function ADRCISPB()

Local aArea 	:= GetArea()
Local _aPositiva:= fCriaArq()	&& Definicao de Estrutura CISP

U_ADINF009P('GERACISP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera informacoes para envio a CISP ')

If _lExec	&& Execucao via JOB

	conout("Processamento CISP via JOB")
	Positivas( _aPositiva )
	conout("Gerando TXT CISP via JOB")
	TXTPositiva( _aPositiva )
Else

	If MsgYesNo( "Deseja gerar informacoes (POSITIVA) ?" )
		
		conout("Processamento CISP MANUAL")
		Processa( { ||Positivas( _aPositiva ) } )
		conout("Gerando TXT CISP MANUAL")
		Processa( { ||TXTPositiva( _aPositiva ) } )
		
	Else
		
		If MsgYesNo( "Deseja gerar arquivo com inf. existentes (POSITIVA) ?" )
			
			conout("Gerando TXT CISP MANUAL, sem o Processamento do CISP")
			Processa( { ||TXTPositiva( _aPositiva ) } )
			
		EndIf
		
	EndIf
	
Endif

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Positivas ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera informacoes Comerciais - Positivas                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Positivas()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Layout de registros (Positivas)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Positivas( _aPositiva )


Local _nCtDados		:= 00

Private _cCGC		:= CriaVar("A1_CGC",.F.)
Private _cCodCli	:= ""
Private _aDados		:= {}
Private _nTotReg	:= 00
Private _nContaRegs	:= 00

Conout("Inicio processamento Funcao POSITIVAS() ")
For _nCtDados := 01 To Len( _aPositiva )
	Aadd( _aDados, { _aPositiva[ _nCtDados, 01 ], _aPositiva[ _nCtDados, 02 ], Iif( _aPositiva[ _nCtDados, 03 ] == "C", "", Iif( _aPositiva[ _nCtDados, 03 ] == "N", 00, CtoD( "" ) ) ) } )
Next
                                                    
fSelect()	&& Execucao de Query Principal 

ProcRegua( _nTotReg )

While ARQT->( !Eof() )
	
	If Val(ARQT->CGC) == 0
		ARQT->(dbSkip())
		Loop
	EndIf
	
	IncProc( "Positivas Cliente: " + Alltrim(ARQT->A1_NREDUZ ))    
	
	_nContaRegs ++

	_cCGC 		:= ARQT->CGC						&& Codigo CNPJ/CPF
	_cCodCli 	:= ARQT->CODCLI						&& Codigo Cliente
	dDTCad		:= fDtCad(_cCGC)					&& Data Cadastral		//StoD( ARQT->A1_DTCAD )
	
	fRetCad(@_aDados,@_aPositiva,@dDTCad)			&& Atualiza informacoes cadastrais
	fRetfin(@_cCGC,@_aDados,@_aPositiva)			&& Retorno Calculos Financeiros
		
	dbSelectArea( "ARQT" )
			
EndDo

ARQT->( dbCloseArea() )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fRetFin    ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna informacoes financeiras do cliente                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ 		                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRetFin( _cCGC,_aDados,_aPositiva )

Local _aArea		:= GetArea()
Local _cQuery		:= ""
Local _aCC			:= {}
Local _nDif			:= 00
Local _nSaldo		:= 00
Local _nMaiorAcm	:= 00
Local _dMaiorAcm	:= StoD( "" )
Local _nCtCC		:= 00
Local _nTotNF		:= 00
Local _nPonderada	:= 00
Local _nAritmetic	:= 00
Local _aMedAtr		:= {}
Local _aMedVnc		:= {}
Local _nCtMd		:= 00
Local _nDiasAtr		:= 00
Local _nVlrCalc		:= 00
Local _nVlrFat		:= 00
Local _nAVencer		:= 00
Local _nCtVnc		:= 00
Local _nVlrVnc		:= 00
Local _nDiaVnc		:= 00
Local _nClcVnc		:= 00
Local _nVncMedia	:= 00
Local _nVncPrazo	:= 00
Local _nVenc5dias	:= 00
Local _aMed5Npg		:= {}
Local _nCt5Npg		:= 00
Local _n5NpgVlr		:= 00
Local _n5NpgClc		:= 00
Local _nMed5Vnc		:= 00
Local _nVen15dias	:= 00
Local _aMed15Npg	:= {}
Local _n15NpgVlr	:= 00
Local _n15NpgClc	:= 00
Local _nMed15Vnc	:= 00
Local _nCt15Npg		:= 00
Local _nVen30dias	:= 00
Local _aMed30Npg	:= {}
Local _n30NpgVlr	:= 00
Local _n30NpgClc	:= 00
Local _nMed30Vnc	:= 00
Local _nCt30Npg		:= 00
Local _lSE5			:= .F.
Local _aUltimaNF	:= { StoD( "" ), 00, StoD( "" ), 00 }
Local _nCtLenACC	:= 00
Local _nValorTit	:= 00

While ARQT->( !Eof() ) .AND. ARQT->CGC == _cCGC
		
	IncProc( "Positivas Cliente: " + Alltrim(ARQT->A1_NREDUZ ))    
	
	_lSE5		:= .F.
		
	dbSelectArea( "SE1" )
	SE1->( dbGoTo( ARQT->E1_REG ) )

	_nTotNF += SE1->E1_SALDO
	
	&&Mauricio HC Consys - Chamado 004696 para nao considerar portador P00,P01,P02 e P03 a nao ser no saldo acumulado(acima).
	&&Luciano Mafra - AD´oro - Chamado 0020720 - Títulos com portador P14 também não devem ser enviados
	If SE1->E1_PORTADO $ "P00/P01/P02/P03/P13/P14" 
		dbSelectArea( "ARQT" )
		ARQT->( dbSkip() )
		Loop
	EndIf
	
	&& Creditos
	_nAscan		:= aScan( _aCC, { |x| x[ 01 ] == SE1->E1_EMISSAO } )
	_nValorTit	:= ( SE1->E1_VALOR + SE1->E1_JUROS + SE1->E1_MULTA ) - SE1->E1_DESCONT
		
	If _nAscan <= 00
		Aadd( _aCC, { SE1->E1_EMISSAO, _nValorTit, 00 } )
	Else
		_aCC[ _nAscan, 02 ] += _nValorTit
	EndIf
	            
	If !Empty(ARQT->E5_NUMERO+ARQT->E5_PREFIXO+ARQT->E5_PARCELA)
	
		cNumAux := ARQT->E1_NUM+ARQT->E1_PREFIXO+ARQT->E1_PARCELA + ARQT->E5_NUMERO+ARQT->E5_PREFIXO+ARQT->E5_PARCELA
	
		While ARQT->( !Eof() ) .AND. cNumAux == ARQT->E1_NUM+ARQT->E1_PREFIXO+ARQT->E1_PARCELA + ARQT->E5_NUMERO+ARQT->E5_PREFIXO+ARQT->E5_PARCELA
			
			IncProc( "Positivas Cliente: " + Alltrim(ARQT->A1_NREDUZ ))    
		
			_lSE5		:= .T.
			_nAscan	:= aScan( _aCC, { |x| x[ 01 ] == Stod(ARQT->E5_DTDISPO) } )
		
			If _nAscan <= 00
				Aadd( _aCC, { Stod(ARQT->E5_DTDISPO), 00, ARQT->E5_VALOR } )
			Else
				_aCC[ _nAscan, 03 ] += ARQT->E5_VALOR
			EndIf
			
			ARQT->( dbSkip() )
				
		EndDo
	
	EndIf		
	
	dbSelectArea("SE1")
	
	&& Medias de titulos em atraso (Ponderada/Aritmetica)         
	If !Empty( SE1->E1_BAIXA ) .And. SE1->E1_BAIXA <= dDataBase
		Aadd( _aMedAtr, { _nValorTit, SE1->E1_VENCTO, SE1->E1_BAIXA, ( SE1->E1_BAIXA - SE1->E1_VENCTO ), ( SE1->E1_BAIXA - SE1->E1_VENCTO ) * _nValorTit } )
	EndIf
		
	&& Debitos atuais a Vencer
	If Empty( SE1->E1_BAIXA ) .And. SE1->E1_VENCTO >= dDataBase
		_nAVencer += _nValorTit
	EndIf
		
	&& Media ponderada de titulos a vencer e prazo medio de vendas 
	If Empty( SE1->E1_BAIXA ) .And. SE1->E1_VENCTO >= dDataBase
		Aadd( _aMedVnc, { _nValorTit, SE1->E1_EMISSAO, SE1->E1_VENCTO, SE1->E1_VENCTO - SE1->E1_EMISSAO, _nValorTit * Iif( ( SE1->E1_VENCTO - SE1->E1_EMISSAO ) > 00, ( SE1->E1_VENCTO - SE1->E1_EMISSAO ), 01 ) } )
	EndIf
		
	&& Valor Debito atual vencido a + 5 dias
	If Empty( SE1->E1_BAIXA ) .And. SE1->E1_VENCTO <= ( dDataBase - 05 )
		_nVenc5dias += _nValorTit
		Aadd( _aMed5Npg, { _nValorTit, dDataBase - SE1->E1_VENCTO, _nValorTit * Iif( ( dDataBase - SE1->E1_VENCTO ) > 00, ( dDataBase - SE1->E1_VENCTO ), 01 ) } )
	EndIf
		
	&& Valor Debito atual vencido a + 15 dias
	If Empty( SE1->E1_BAIXA ) .And. SE1->E1_VENCTO <= ( dDataBase - 15 )
		_nVen15dias += _nValorTit
		Aadd( _aMed15Npg, { _nValorTit, dDataBase - SE1->E1_VENCTO, _nValorTit * Iif( ( dDataBase - SE1->E1_VENCTO ) > 00, ( dDataBase - SE1->E1_VENCTO ), 01 ) } )
	EndIf
	
	&& Valor Debito atual vencido a + 30 dias
	If Empty( SE1->E1_BAIXA ) .And. SE1->E1_VENCTO <= ( dDataBase - 30 )
		_nVen30dias += _nValorTit
		Aadd( _aMed30Npg, { _nValorTit, dDataBase - SE1->E1_VENCTO, _nValorTit * Iif( ( dDataBase - SE1->E1_VENCTO ) > 00, ( dDataBase - SE1->E1_VENCTO ), 01 ) } )
	EndIf	
	
	dbSelectArea( "ARQT" )
	
	If !_lSE5	
		ARQT->( dbSkip() )
	EndIf	
		
EndDo
	

&& Utimo e penultimo titulo emitido para o Cliente
&& Ordena por data de movimento

_aCC := ASort( _aCC,,, {|x,y| x[ 01 ] < y[ 01 ] } )
For _nCtLenACC := 01 To Len( _aCC )
	
	If _aCC[ _nCtLenACC, 02 ] > 00
		
		If _aCC[ _nCtLenACC, 01 ] > _aUltimaNF[ 01 ]
			_aUltimaNF[ 03 ] := _aUltimaNF[ 01 ]
			_aUltimaNF[ 04 ] := _aUltimaNF[ 02 ]
			_aUltimaNF[ 01 ] := _aCC[ _nCtLenACC, 01 ]
			_aUltimaNF[ 02 ] := _aCC[ _nCtLenACC, 02 ]
		EndIf
		
	EndIf
	
Next

&& Ordena por data de movimento
_aCC := ASort( _aCC,,, {|x,y| x[ 01 ] < y[ 01 ] } )

&& Calcula o Maior Acumulo do Cliente
dPerAcm1	:= 	Stod(Str( ( Year( dDataBase ) - 01 ), 04 ) + SubStr( DtoS( dDataBase ), 05, 04 ) )
dPerAcm2	:= 	dDataBase 
For _nCtCC := 01 To Len( _aCC )
	
	_nSaldo	:= ( _nSaldo + _aCC[ _nCtCC, 02 ] ) - _aCC[ _nCtCC, 03 ]
	If _nSaldo > _nMaiorAcm
		_nMaiorAcm := _nSaldo
		_dMaiorAcm := _aCC[ _nCtCC, 01 ]
	EndIf
Next

If _nMaiorAcm <= 00 .And. _lSE5 .And. Len( _aCC ) > 00
	_aCC			:= ASort( _aCC,,, {|x,y| x[ 02 ] > y[ 02 ] } )
	_nMaiorAcm	:= _aCC[ 01, 02 ]
	_dMaiorAcm	:= _aCC[ 01, 01 ]
EndIf
&& Nova condicao para atender exigencia CISP - Valor Maior Acumulo < Debito Atual Total
If _nMaiorAcm < _nTotNF
	_nMaiorAcm := _nTotNF
EndIf

&& Calcula Medias de atraso (ponderada e aritmetica) do cliente
For _nCtMd := 01 To Len( _aMedAtr )
	_nVlrFat		+= _aMedAtr[ _nCtMd, 01 ]
	_nDiasAtr	+= _aMedAtr[ _nCtMd, 04 ]
	_nVlrCalc	+= _aMedAtr[ _nCtMd, 05 ]
Next

If Len( _aMedAtr ) > 00
	
	_nPonderada	:= _nVlrCalc / _nVlrFat
	_nAritmetic	:= _nDiasAtr / Len( _aMedAtr )
	
	_nPonderada := Iif( _nPonderada < 0.01 .And. _nPonderada > 0.00, 0.01, Iif( _nPonderada < 00, 00, _nPonderada ) )
	_nAritmetic := Iif( _nAritmetic < 0.01 .And. _nAritmetic > 0.00, 0.01, Iif( _nAritmetic < 00, 00, _nAritmetic ) )
	
	If _nPonderada <= 00 .Or. _nAritmetic <= 00
		_nPonderada := 00
		_nAritmetic := 00
	EndIf
	
EndIf

&& Calcula Media ponderada de tit. a vencer e prz med. de vendas
For _nCtVnc := 01 To Len( _aMedVnc )
	_nVlrVnc	+= _aMedVnc[ _nCtVnc, 01 ]
	_nDiaVnc	+= _aMedVnc[ _nCtVnc, 04 ]
	_nClcVnc	+= _aMedVnc[ _nCtVnc, 05 ]
Next

If Len( _aMedVnc ) > 00
	_nVncMedia	:= _nClcVnc / _nVlrVnc
	_nVncPrazo	:= _nDiaVnc / Len( _aMedVnc )
	_nVncPrazo	:= iif(_nVncPrazo<=0,1,_nVncPrazo)
EndIf

&& Calcula Media ponderada atraso tit.venc. e nao pagos +5 dias
For _nCt5Npg := 01 To Len( _aMed5Npg )
	_n5NpgVlr += _aMed5Npg[ _nCt5Npg, 01 ]
	_n5NpgClc += _aMed5Npg[ _nCt5Npg, 03 ]
Next

If Len( _aMed5Npg ) > 00    
	
	_nMed5Vnc := _n5NpgClc / _n5NpgVlr
	
EndIf

&& Calcula Media ponderada atraso tit.venc. e nao pagos +15 dias
For _nCt15Npg := 01 To Len( _aMed15Npg )
	_n15NpgVlr += _aMed15Npg[ _nCt15Npg, 01 ]
	_n15NpgClc += _aMed15Npg[ _nCt15Npg, 03 ]
Next

If Len( _aMed15Npg ) > 00
	_nMed15Vnc := _n15NpgClc / _n15NpgVlr
EndIf

&& Calcula Media ponderada atraso tit.venc. e nao pagos +30 dias
For _nCt30Npg := 01 To Len( _aMed30Npg )
	_n30NpgVlr += _aMed30Npg[ _nCt30Npg, 01 ]
	_n30NpgClc += _aMed30Npg[ _nCt30Npg, 03 ]
Next

If Len( _aMed30Npg ) > 00
	_nMed30Vnc := _n30NpgClc / _n30NpgVlr
EndIf

&& Atualiza valor de maior acumulo ref. ultima compra
If _aUltimaNF[ 02 ] > _nMaiorAcm
	_dMaiorAcm := _aUltimaNF[ 01 ]
	_nMaiorAcm := _aUltimaNF[ 02 ]
EndIf

_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "08" } ), 03 ] := _dMaiorAcm
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "09" } ), 03 ] := _nMaiorAcm
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "10" } ), 03 ] := Iif( _nTotNF < 00, 00, _nTotNF )
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "12" } ), 03 ] := _nPonderada
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "13" } ), 03 ] := _nAritmetic
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "14" } ), 03 ] := _nAVencer
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "15" } ), 03 ] := _nVncMedia
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "16" } ), 03 ] := _nVncPrazo
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "17" } ), 03 ] := _nVenc5dias
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "18" } ), 03 ] := _nMed5Vnc
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "19" } ), 03 ] := _nVen15dias
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "20" } ), 03 ] := _nMed15Vnc
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "21" } ), 03 ] := _nVen30dias
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "22" } ), 03 ] := _nMed30Vnc
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "06" } ), 03 ] := _aUltimaNF[ 01 ]
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "07" } ), 03 ] := _aUltimaNF[ 02 ]
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "23" } ), 03 ] := _aUltimaNF[ 03 ]
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "24" } ), 03 ] := _aUltimaNF[ 04 ]
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "30" } ), 03 ] := PgtoAnt( _cCGC )
	
dDataCad := dDTCad
dUltComp := _aUltimaNF[ 01 ]
If dUltComp < dDataCad
	_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "05" } ), 03 ] := dUltComp
Endif
	
GrvPstva( @_cCGC, @_aDados, @_cCodCli )

RestArea( _aArea )

Return ( )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PgtoAnt    ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna valor total das vendas com pagamentos antecipados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PgtoAnt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PgtoAnt( _cCGC )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _nValor	:= 00
Local _cQuery	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona registro                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cQuery := "SELECT SUM( ( ( E1_VALOR + E1_JUROS + E1_MULTA ) - E1_DESCONT ) ) AS ANTECIPADOS "
_cQuery += "FROM "
_cQuery += RetSqlName( "SE1" ) + " E1, "
_cQuery += RetSqlName( "SA1" ) + " A1 "
_cQuery += "WHERE (CASE WHEN A1_PESSOA = 'J' THEN SUBSTRING( A1_CGC, 01, 08 ) ELSE A1_CGC END) = '" + _cCGC + "' "
_cQuery += "AND E1.E1_EMISSAO BETWEEN '" + Str( ( Year( dDataBase ) - 01 ), 04 ) + SubStr( DtoS( dDataBase ), 05, 04 ) + "' AND '" + DtoS( dDataBase ) + "' "
_cQuery += "AND E1.E1_TIPO = 'RA' "
_cQuery += "AND E1.E1_CLIENTE = A1.A1_COD "
_cQuery += "AND E1.E1_LOJA = A1.A1_LOJA "
_cQuery += "AND E1.D_E_L_E_T_ = '' "

//_cQuery := ChangeQuery( _cQuery )

dbUseArea( .T., "TopConn", TCGenQry( ,, _cQuery ), "ATCPD", .F., .T. )

dbSelectArea( "ATCPD" )

_nValor := ATCPD->ANTECIPADOS

ATCPD->( dbCloseArea() )

RestArea( _aArea )

Return ( _nValor )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GrvPstva  ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava arquivo temporario                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GrvPstva()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GrvPstva( _cCGC, _aDados, _cCodCli )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _nCtCpo	:= 00
Local _nAscan	:= 00
Local _lPCDTPC	:= .T.
Local _lPCDUCM	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza arquivo de Positivas (PAB)                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "PAB" )
dbSetOrder( 01 )

If PAB->(!dbSeek(_cCGC))

	If Len(_cCGC) > 8	&& Somente Clientes Pessoa Fisica
		aAdd(aCliN, { _cCodCli } )
	Endif

Endif		

RecLock( "PAB", !dbSeek( _cCGC ) )

PAB->PAB_FILIAL := xFilial( "PAB" )

For _nCtCpo := 01 To Len( _aDados )
	
	_nAscan := aScan( _aDados, { |x| AllTrim( Upper( x[ 01 ] ) ) == StrZero( _nCtCpo, 02 ) } )
	
	If _nAscan > 00
		
		If _nAscan == 08 // Data do maior acumulo
			
			If PAB->PAB_PCDMAC < _aDados[ _nAscan, 03 ]
				PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
			EndIf
			
		ElseIf _nAscan == 09 // Valor do maior acumulo
			
			If PAB->PAB_PCVMAC < _aDados[ _nAscan, 03 ]	
				PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
			EndIf
			
		ElseIf _nAscan == 23 // Data da Penultima Compra
			
			If PAB->PAB_PCDTPC < _aDados[ _nAscan, 03 ]
				PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
			Else
				_lPCDTPC := .F.
			EndIf
			
		ElseIf _nAscan == 24 // Valor da Penultima Compra
			
			If _lPCDTPC
				PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
			EndIf
			
		ElseIf _nAscan == 06 // Data da Ultima Compra
			
			If PAB->PAB_PCDUCM < _aDados[ _nAscan, 03 ]
				PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
			Else
				_lPCDUCM := .F.
			EndIf
			
		ElseIf _nAscan == 07 // Valor da Ultima Compra
			
			If _lPCDUCM
				PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
			EndIf
			
		Else
			PAB->&( PrefixoCpo( "PAB" ) + "_" + _aDados[ _nAscan, 02 ] ) := _aDados[ _nAscan, 03 ]
		EndIf
		
	EndIf
	
Next

PAB->( MsUnLock() )

RestArea( _aArea )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TXTPositiva³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera arquivo TXT - Positivas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TXTPositiva()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TXTPositiva( _aPositiva )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _cLinha			:= ""
Local _nCtStruct		:= 00
Local _nAscan			:= 00
Local _aStruct			:= MntArraySX3( "PAB" )
Local _nCtPositiva		:= 00
Local _nHdl				:= ""
Local _cValor			:= ""
Local _cPath			:= "\CISP\"

&& Verifica se serao encaminhados Novos Registros de Pessoa Fisica a CISP
	&& Desabilitado em 04/05/09 por Michel

Conout("Processamento funcao TXTPOSITIVA ")
/*
If Len(aCliN) > 0
	
	OKGeraTXT(aCliN)
	conout("Envio de email clientes novos Pessoa Fisica. CISP " + Iif(_lExec, " VIA JOB", "MANUAL") )
	If !_lExec
		If MsgYesNo( "Deseja enviar email de Novos Clientes Pessoa Fisica à CISP ?" )                
			conout("Envio de email Pessoa Fisica - CISP MANUAL")
			SendMail("Inclusão Pessoa Física ",.T.)	&& Envio de email para analise CISP
		Endif	
	Else 	
		conout("Envio de email Pessoa Fisica - CISP JOB")	
		SendMail("Inclusão Pessoa Física ",.T.)		&& Envio de email para analise CISP	
	Endif	
	
Endif 
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera arquivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File( _cPath+"PFJ_0138.TXT" )
	FErase( _cPath+"PFJ_0138.TXT" )
EndIf

_nHdl := FCreate( _cPath+"PFJ_0138.TXT" )

If _nHdl == -1
	MsgAlert( "O Arquivo "+_cPath+"PFJ_0138.TXT nao pode ser executado! Verifique os parametros.", "Atencao" )
	Return ( Nil )
EndIf
              
dbSelectArea( "PAB" )
dbSetOrder( 01 )

ProcRegua( PAB->( RecCount() ) )

PAB->( dbGoTop() )

While PAB->( !Eof() )
	
	_cLinha := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconsidera registros conforme determinacao do LayOut CISP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	Empty( PAB->&( "PAB_" + _aPositiva[ 01, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 02, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 04, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 05, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 06, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 07, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 08, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 09, 02 ] ) ) .Or.;
		Empty( PAB->&( "PAB_" + _aPositiva[ 25, 02 ] ) )
		
		PAB->( dbSkip() )
		Loop
		
	EndIf
   
	&& Somente para testes
    /*
	If  PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 67590778
	//	.AND. PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 45827425 .AND. PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 59809277;
	//	.AND. PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 8753249 .AND. PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 902382 .AND. PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 9145595
	
	//If  PAB->&( "PAB_" + _aPositiva[ 03, 02 ] ) != 54582150
		PAB->( dbSkip() )
		Loop
   
	EndIf
    */                                                                
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconsidera regs. data da informação não esteja dentro do mes do processamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If Month(PAB->&( "PAB_" + _aPositiva[ 04, 02 ])) <> Month(Date())//incluido por Adriana em 16/10/08
	If Month(PAB->&( "PAB_" + _aPositiva[ 04, 02 ])) <> Month(dDataBase)//incluido por Adriana em 16/10/08
		PAB->( dbSkip() )
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconsidera regs. data da informação não esteja dentro do ano do processamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Year(PAB->&( "PAB_" + _aPositiva[ 04, 02 ])) <> Year(dDataBase)//&&Chamado 007464 - Mauricio
		PAB->( dbSkip() )
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconsidera regs. que (Deb.Vencer+Deb.Venc+5ds) > Deb.Atual ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( PAB->&( "PAB_" + _aPositiva[ 14, 02 ] ) + PAB->&( "PAB_" + _aPositiva[ 17, 02 ] ) ) > PAB->&( "PAB_" + _aPositiva[ 10, 02 ] )
		PAB->( dbSkip() )
		Loop
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconsidera regs. que Data Ult. Compra > 12 meses S/Deb Atual Total  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If (  PAB->&( "PAB_" + _aPositiva[ 06, 02 ] ) < ;
		ctod(StrZero(Day(dDataBase),2)+"/"+StrZero(Month(dDataBase),2)+"/"+StrZero(Year(dDataBase)-1,4));
		.and. PAB->&( "PAB_" + _aPositiva[ 10, 02 ] ) == 0  )
		PAB->( dbSkip() )
		Loop
	EndIf	
	
	IncProc( "Gerando arquivo texto ..." )
	
	For _nCtPositiva := 01 To Len( _aPositiva )
		
		_nAscan := aScan( _aStruct, { |x| AllTrim( Upper( x[ 01 ] ) ) == AllTrim( Upper( "PAB_" + _aPositiva[ _nCtPositiva, 02 ] ) ) } )
		
		If _nAscan > 00
			
			If _aPositiva[ _nCtPositiva, 03 ] == "N"
				
				If _aPositiva[ _nCtPositiva, 05 ] == 00
					_cLinha += StrZero( &( _aStruct[ _nAscan, 01 ] ), Len( _aPositiva[ _nCtPositiva, 08 ] ) )
				Else
					_cValor := StrZero( Int( &( _aStruct[ _nAscan, 01 ] ) ), _aPositiva[ _nCtPositiva, 04 ] ) + AllTrim( StrTran( Str( &( _aStruct[ _nAscan, 01 ] ) - Int( &( _aStruct[ _nAscan, 01 ] ) ) ), "0.", "" ) )
					_cLinha += _cValor + Iif( Len( _cValor ) == ( _aPositivas[ _nCtPositiva, 04 ] + _aPositivas[ _nCtPositiva, 05 ] ), "", Replicate( "0", ( ( _aPositivas[ _nCtPositiva, 04 ] + _aPositivas[ _nCtPositiva, 05 ] ) - Len( _cValor ) ) ) )
				EndIf
				
			ElseIf _aPositiva[ _nCtPositiva, 03 ] == "D"
				_cLinha += Iif( Empty( &( _aStruct[ _nAscan, 01 ] ) ), "00000000", DtoS( &( _aStruct[ _nAscan, 01 ] ) ) )
			Else
				_cLinha += &( _aStruct[ _nAscan, 01 ] )
			EndIf
			
		EndIf
		
	Next
	
	_cLinha += CRLF
	
	If FWrite( _nHdl, _cLinha, Len( _cLinha ) ) != Len( _cLinha )
		
		If !MsgAlert( "Ocorreu um erro na gravacao do arquivo. Continua?", "Atencao" )
			Exit
		EndIf
		
	EndIf
	
	PAB->( dbSkip() )
	
EndDo

FClose( _nHdl )

conout("Envio de email Arquivo CISP " + Iif(_lExec, " VIA JOB", "MANUAL") )

If !_lExec//voltar aqui
	//If MsgYesNo( "Deseja enviar email do arquivo CISP ?" )
		conout("Envio de email CISP MANUAL " )
		SendMail("Arquivo CISP",.F.)	&& Envio de email para analise CISP
	//Endif
Else  
	conout("Envio de email CISP JOB " )
	SendMail("Arquivo CISP",.F.)	&& Envio de email para analise CISP
Endif

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MntArraySX3 ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta array com os campos SX3 obrigatorios em ordem        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MntArraySX3( _cTabela )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MntArraySX3( _cArquivo )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _aArray	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta array                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SX3" )
dbSetOrder( 01 )

If !dbSeek( _cArquivo )
	Return( _aArray )
EndIf

While SX3->( !Eof() ) .And. AllTrim( SX3->X3_ARQUIVO ) == AllTrim( _cArquivo )
	
	aAdd( _aArray, { SX3->X3_CAMPO, Iif( SX3->X3_TIPO == "C", "", Iif( SX3->X3_TIPO == "N", 00, Iif( SX3->X3_TIPO == "D", StoD( "" ), "" ) ) ), Nil } )
	
	SX3->( dbSkip() )
	
EndDo

RestArea( _aArea )

Return ( _aArray )

/* Tratamento de SendMail */
Static Function SendMail(cSubject,lTipo)   
Local lOk       	:= .T.
Local cBody			:=	Iif( lTipo, fHTMLCN() , RetHTML() )
Local cErrorMsg		:=	""
Local aFiles 		:= {}
Local cServer     	:=	Alltrim(GetMv("MV_RELSERV"))
Local cAccount    	:=	AllTrim(GetMv("MV_RELACNT"))
Local cPassword   	:=	AllTrim(GetMv("MV_RELPSW"))
Local cFrom       	:=	AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
Local cTo         	:=	AllTrim(GetMv("ZZ_CISP"))									&& Conta de email que recebera o arquivo EDI anexo.
Local cCC         	:=	AllTrim(GetMv("ZZ_CISPCC"))									&& Conta de email que recebera copia do arquivo EDI anexo.

// Local cTo         	:=	"luciano.mafra@adoro.com.br" 
// Local cCC         	:=	"luciano.mafra@outlook.com"	

Local lSmtpAuth  	:= GetMv("MV_RELAUTH",,.F.)
Local lAutOk     	:= .F.
Local cAtach 		:= Iif(lTipo,"\CISP\NPF_0138.TXT","\CISP\PFJ_0138.TXT")			&& Verdadeiro -> Novos Clientes Pessoa Fisica
																					&& Falso -> Movimento CISP

Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk

If !lAutOk
	If ( lSmtpAuth )
		lAutOk := MailAuth(cAccount,cPassword)
	Else
		lAutOk := .T.
	EndIf
EndIf

//cTo := "michel@visualbusiness.com.br"
//cCC := "ilaine@adoro.com.br"

If lOk .And. lAutOk
	
	If !Empty(cCC)
		//Send Mail From cFrom 	To cTo 	CC cCC 			 Subject cSubject Body cBody 	Result lOk
		Send Mail From cFrom To cTo CC cCC Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
	Else
		//Send Mail From cFrom To cTo Subject cSubject Body cBody Result lOk
		Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
	EndIf
	
	If !lOk
		Get Mail Error cErrorMsg
		ConOut("3 - " + cErrorMsg)
	EndIf
Else
	Get Mail Error cErrorMsg
	ConOut("4 - " + cErrorMsg)
EndIf

If lOk
	Disconnect Smtp Server
Endif

Return(.t.)

&& Funcoes para compor HTML */
//Static Function RetHTML(cDoc,cOP,cProduto)
Static Function RetHTML()
Local cRet	:=	""

cRet		+=	'<html>'
cRet		+=	'<head>'
cRet		+=	'	<meta http-equiv="content-type"'
cRet		+=	'	content="text/html; charset=ISO-8859-1">'
cRet		+=	'	<title>ADORO S/A</title>'
cRet		+=	'</head>'
cRet		+=	'<body>'
cRet		+=	'<br>'

//&& Detalhes campos do corpo Email Mauricio

cRet := "<p <span style='"
cRet += 'font-family:"Arial Narrow";color:#333399'
cRet += "'>Segue arquivo<b> </b><strong><span style='font-family:"
cRet += '"Arial Narrow";font-weight:normal'
cRet += "'>de Informações Comerciais (Positivas) para validação CISP - </span></strong>Associada 138 Ad'oro S/A.<b><o:p></o:p></b></span></p>"

cRet += "<p style='mso-outline-level:1'><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>Atenciosamente,<o:p></o:p></span></p>"

cRet += "<p style='margin:0cm;margin-bottom:.0001pt'><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>Departamento de Crédito<o:p></o:p></span></p>"

cRet += "<p style='margin:0cm;margin-bottom:.0001pt'><b style='mso-bidi-font-weight:normal'><span style='font-family:"
cRet += '"Arial Narrow";color:#FF9900'
cRet += "'>AD'ORO S/A<o:p></o:p></span></b></p>"

cRet += "<p style='margin:0cm;margin-bottom:.0001pt'><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>Tel.: 11 4596-8351<o:p></o:p></span></p>"

cRet += "<p class=MsoNormal><i><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>(Email enviado automaticamente pelo ERP-Protheus)<o:p></o:p></span></i></p>"
 
cRet		+=	'<br>'
cRet		+=	'</body>'
cRet		+=	'</html>'

Return(cRet)

&& Funcoes para compor HTML Novos Clientes Pessoa Fisica*/
Static Function fHTMLCN()
Local cRet	:=	""

cRet		+=	'<html>'
cRet		+=	'<head>'
cRet		+=	'	<meta http-equiv="content-type"'
cRet		+=	'	content="text/html; charset=ISO-8859-1">'
cRet		+=	'	<title>ADORO S/A</title>'
cRet		+=	'</head>'
cRet		+=	'<body>'
cRet		+=	'<br>'

//&& Detalhes campos do corpo Email

cRet := "<p <span style='"
cRet += 'font-family:"Arial Narrow";color:#333399'
cRet += "'>Segue arquivo com informações para inclusão de clientes pessoa física.<b> </b><strong><span style='font-family:"
cRet += '"Arial Narrow";font-weight:normal'
cRet += "'>Favor processar antes do arquivo de positivas - </span></strong>Associada 138 Ad'oro S/A.<b><o:p></o:p></b></span></p>"

cRet += "<p style='mso-outline-level:1'><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>Atenciosamente,<o:p></o:p></span></p>"

cRet += "<p style='margin:0cm;margin-bottom:.0001pt'><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>Departamento de Crédito<o:p></o:p></span></p>"

cRet += "<p style='margin:0cm;margin-bottom:.0001pt'><b style='mso-bidi-font-weight:normal'><span style='font-family:"
cRet += '"Arial Narrow";color:#FF9900'
cRet += "'>AD'ORO S/A<o:p></o:p></span></b></p>"

cRet += "<p style='margin:0cm;margin-bottom:.0001pt'><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>Tel.: 11 4596-8351<o:p></o:p></span></p>"

cRet += "<p class=MsoNormal><i><span style='font-family:"
cRet += '"Arial Narrow";color:#333399'
cRet += "'>(Email enviado automaticamente pelo ERP-Protheus)<o:p></o:p></span></i></p>"
 
cRet		+=	'<br>'
cRet		+=	'</body>'
cRet		+=	'</html>'

Return(cRet)

&& Funcao de Tratamento de Novos Clientes Pessoa Fisica */
Static Function OKGeraTXT(aCliN)

Local _cQuery	:= ""
Local _cPath	:= "\CISP\"
Local _cArq		:= "NPF_0138.TXT"

Local  _nHdlZ	:= ""

	_cQuery := "SELECT CASE WHEN A1_PESSOA = 'J' THEN '1' ELSE '2' END TIPO, "
	_cQuery += "'0138' ASSOCIADO, "
	_cQuery += "RIGHT(('00000000000000000000'+RTRIM(A1_CGC)),20) CPFCNPJOUTROS, "
	_cQuery += "LEFT((A1_NOME+SPACE(60)),60) RZSOCNOME, "
	_cQuery += "SPACE(1) SEXO, "
	_cQuery += "'00000000' DTNASCFUND, "
	_cQuery += "SPACE(10) ESTADOCIVIL, "
	_cQuery += "LEFT((A1_END+SPACE(60)),60) ENDERECO, "
	_cQuery += "LEFT((A1_BAIRRO+SPACE(30)),30) BAIRRO, "
	_cQuery += "LEFT((A1_MUN+SPACE(40)),40) CIDADE, "
	_cQuery += "A1_EST UF, "
	_cQuery += "SPACE(20) PAIS, "
	_cQuery += "SPACE(20) REGIAO, "
	_cQuery += "A1_CEP CEP, "
	_cQuery += "LEFT((A1_TEL+SPACE(30)),30) TELEFONE, "
	_cQuery += "LEFT((A1_FAX+SPACE(30)),30) FAX, "
	_cQuery += "LEFT((RTRIM((CONVERT(CHAR,(YEAR(GETDATE())))))+RIGHT(('00'+RTRIM(CONVERT(CHAR,MONTH(GETDATE())))),2)+RIGHT('00'+RTRIM(CONVERT(CHAR,DAY(GETDATE()))),2)),8) DATAGERACAO, "
	_cQuery += "'00000000' ATIVECONMICA, "
	_cQuery += "LEFT((A1_EMAIL+SPACE(50)),50) EMAIL, "
	_cQuery += "SPACE(60) ORGEMISSOR, "
	_cQuery += "'00000000' DTEXPEDICAO, "
	_cQuery += "SPACE(60) FILIACAO "
	_cQuery += "FROM " + RetSqlName( "SA1" ) + " "
	_cQuery += "WHERE A1_MSBLQL = '2' AND A1_EST <> 'EX' "
	If Len(aCliN) >0
		For n1 := 1 to Len(aCliN)
			If n1 == 1 
				_cQuery += " AND "	
			Else
				_cQuery += " OR  "	
			Endif	
			_cQuery += " A1_COD+A1_LOJA = '" + aCliN[n1,01] + "'  "
		Next n1
	Endif                          
	
//MsAguarde( {|| dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "TMPCISP", .F., .T. ) }, "Selecionando registros ..." )

TcQuery _cQuery New Alias "TMPCISP"

dbSelectArea( "TMPCISP" )
Count to nReg 
Conout( "Registros encontrados:" + Str(nReg ) )

TMPCISP->(dbGoTop())

If nReg > 0

	If File( _cPath+_cArq )
		FErase( _cPath+_cArq )
	EndIf
	
	_nHdlZ := FCreate( AllTrim( _cPath+_cArq ) )
	
	/*
	If _nHdl == -1
		MsgAlert( "O Arquivo de nome " + AllTrim( _cPath+_cArq ) + " nao pode ser executado! Verifique os parametros.", "Atencao" )
		Return ( Nil )
	EndIf
	*/
	
	//Processa( {|| RunCont() }, "Processando..." )
	
	RunCont(@_nHdlZ)
	
Endif

TMPCISP->( dbCloseArea() )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RunCont   ³ Autor ³ Visual Business      ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerador arquivo texto                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RunCont()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunCont(_nHdlZ)

Local nTamLin
Local cLin
Local cCPO
Local TempCampos	:= TMPCISP->( dbStruct() )
Local _nCountStr	:= 00
Local ValCampo		:= ""
Local _cEOL 	   := Chr( 13 ) + Chr( 10 )

//ProcRegua( TMPCISP->( LastRec() ) )

While TMPCISP->( !Eof() )

	//IncProc()
	
	cLin := ""
	
	For _nCountStr := 01 To Len( TempCampos )

		ValCampo := TempCampos[ _nCountStr, 01 ]

		cLin += &ValCampo

	Next

	cLin += _cEOL

	If FWrite( _nHdlZ, cLin, Len( cLin ) ) != Len( cLin )

		//If !MsgAlert( "Ocorreu um erro na gravacao do arquivo. Continua?", "Atencao" )
			Conout("Ocorreu um erro na gravacao do arquivo")
			Exit
		//EndIf
		
	EndIf

	Conout( "Conteudo " + cLin )
	
	TMPCISP->( dbSkip() )

EndDo

FClose( _nHdlZ )

Return ( Nil )

Static Function fCriaArq()
Local aRet := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LayOut das Informacoes Comerciais - Positivas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   Positivas      Sq ,  Campo		, Tp , Tm, Dc, PIn,  Pfi, Formato					, Descricao											                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aRet, { "01", "PCTIPO"	, "N", 01, 00, 001, 001, "9"					, "Identif. (1-CNPJ/2-CPF/3-RG/4-Export./5-Insc.Prod./9-Outros)"		} )
Aadd( aRet, { "02", "PCCASS"	, "N", 04, 00, 002, 005, "9999"					, "Codigo do Associado"																} )
Aadd( aRet, { "03", "PCCCLI"	, "N", 20, 00, 006, 025, "99999999999999999999"	, "Identificacao. (CNPJ/CPF/RG/Export/Insc.Prod./(Outros)"				} )
Aadd( aRet, { "04", "PCDDAT"	, "D", 08, 00, 026, 033, "99999999(AAAAMMDD)"	, "Data da Informacao"																} )
Aadd( aRet, { "05", "PCDCDD"	, "D", 08, 00, 034, 041, "99999999(AAAAMMDD)"	, "Data  Cadastramento do Cliente"												} )
Aadd( aRet, { "06", "PCDUCM"	, "D", 08, 00, 042, 049, "99999999(AAAAMMDD)"	, "Data da Ultima Compra"															} )
Aadd( aRet, { "07", "PCVULC"	, "N", 13, 02, 050, 064, "999999999999999"		, "Valor da Ultima Compra"															} )
Aadd( aRet, { "08", "PCDMAC"	, "D", 08, 00, 065, 072, "99999999(AAAAMMDD)"	, "Data  do Maior Acumulo"															} )
Aadd( aRet, { "09", "PCVMAC"	, "N", 13, 02, 073, 087, "999999999999999"		, "Valor Maior Acumulo"																} )
Aadd( aRet, { "10", "PCVSAT"	, "N", 13, 02, 088, 102, "999999999999999"		, "Valor Debito Atual Total"														} )
Aadd( aRet, { "11", "PCVLCR"	, "N", 13, 02, 103, 117, "999999999999999"		, "Valor Limite de Credito"														} )
Aadd( aRet, { "12", "PCQPAG"	, "N", 04, 02, 118, 123, "999999"				, "Media Ponderada de Atraso nos Pagamentos (Titulos Pagos)"			} )
Aadd( aRet, { "13", "PCQDAP"	, "N", 04, 02, 124, 129, "999999"				, "Media Aritm.Dias de Atraso Pagamento"										} )
Aadd( aRet, { "14", "PCVDAV"	, "N", 13, 02, 130, 144, "999999999999999"		, "Valor Debito Atual a Vencer"													} )
Aadd( aRet, { "15", "PCMDAV"	, "N", 04, 02, 145, 150, "999999"				, "Media Ponderada de Titulos a Vencer"										} )
Aadd( aRet, { "16", "PCMPMV"	, "N", 04, 02, 151, 156, "999999"				, "Prazo Medio de Vendas"															} )
Aadd( aRet, { "17", "PCDATV"	, "N", 13, 02, 157, 171, "999999999999999"		, "Valor Debito Atual Vencido + 5 Dias"										} )
Aadd( aRet, { "18", "PCMPTV"	, "N", 04, 00, 172, 175, "9999"					, "Media Ponderada de Atraso Titulos Vencidos e nao Pagos + 5 Dias"	} )
Aadd( aRet, { "19", "PCV15D"	, "N", 13, 02, 176, 190, "999999999999999"		, "Valor Debito Atual Vencido + 15 Dias"										} )
Aadd( aRet, { "20", "PCM15D"	, "N", 04, 00, 191, 194, "9999"					, "Media Ponderada de Atraso Titulos Vencidos e nao Pagos + 15 Dias"	} )
Aadd( aRet, { "21", "PCV30D"	, "N", 13, 02, 195, 209, "999999999999999"		, "Valor Debito Atual Vencido + 30 Dias"										} )
Aadd( aRet, { "22", "PCM30D"	, "N", 04, 00, 210, 213, "9999"					, "Media Ponderada de Atraso Titulos Vencidos e nao Pagos + 30 Dias"	} )
Aadd( aRet, { "23", "PCDTPC"	, "D", 08, 00, 214, 221, "99999999(AAAAMMDD)"	, "Data da Penultima Compra"														} )
Aadd( aRet, { "24", "PCVPCO"	, "N", 13, 02, 222, 236, "999999999999999"		, "Valor da Penultima Compra"														} )
Aadd( aRet, { "25", "PCVSIT"	, "N", 01, 00, 237, 237, "9"					, "Situacao do Calculo Limite de Credito"										} )
Aadd( aRet, { "26", "PCTIPG"	, "N", 01, 00, 238, 238, "9"					, "Tipo de Garantia"																	} )
Aadd( aRet, { "27", "PCGGA"	, "N", 02, 00, 239, 240, "99"						, "Grau da Garantia - Hipoteca"													} )
Aadd( aRet, { "28", "PCDTG"	, "D", 08, 00, 241, 248, "99999999(AAAAMMDD)"		, "Data Validade da Garantia"														} )
Aadd( aRet, { "29", "PCVLG"	, "N", 13, 02, 249, 263, "999999999999999"			, "Valor da Garantia"																} )
Aadd( aRet, { "30", "PCVPA"	, "N", 13, 02, 264, 278, "999999999999999"			, "Valor da Venda Pagamento Antecipado"										} )
Aadd( aRet, { "31", "PCSVV"	, "C", 02, 00, 279, 280, "VV ou BRANCO"				, "Venda sem Credito (ANTECIPADO)"												} )

Return(aRet)

/* Atualiza informacoes cadastrais */
Static Function fRetCad(_aDados,_aPositiva,dDTCad)

_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "02" } ), 03 ] := 0138
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "25" } ), 03 ] := 01
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "26" } ), 03 ] := 0
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "27" } ), 03 ] := 00
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "28" } ), 03 ] := CtoD( "" )
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "29" } ), 03 ] := 00
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "01" } ), 03 ] := Iif(ARQT->A1_PESSOA=='J',01,02)
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "03" } ), 03 ] := Val( _cCGC )
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "04" } ), 03 ] := (dDataBase )
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "05" } ), 03 ] := dDTCad
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "11" } ), 03 ] := ARQT->A1_LC
_aDados[ aScan( _aPositiva, { |x| AllTrim( Upper( x[ 01 ] ) ) == "31" } ), 03 ] := Iif( AllTrim( ARQT->A1_COND ) == "00", "VV", "  " ) 

Return()

/* Funcao de Selecao principal dos Registros */
Static Function fSelect()
Local cQuery := ""

cQuery := "SELECT DISTINCT (CASE WHEN A1_PESSOA = 'J' THEN SUBSTRING( A1_CGC, 01, 08 ) ELSE A1_CGC END) AS CGC, "
cQuery += "		A1_COD+A1_LOJA AS CODCLI, "+RetSqlName("SE1")+ ".R_E_C_N_O_ AS E1_REG, "+RetSqlName("SE1")+ ".E1_PORTADO AS E1_PTD, E5_DTDISPO, E5_VALOR,"
cQuery += "		A1_NREDUZ,A1_DTCAD,A1_PESSOA,A1_LC,A1_COND,E1_NUM,E1_PREFIXO,E1_PARCELA,E5_NUMERO,E5_PREFIXO,E5_PARCELA "
cQuery += "FROM " + RETSQLNAME("SA1") + " INNER JOIN	" + RETSQLNAME("SE1") + " ON E1_CLIENTE+E1_LOJA = A1_COD+A1_LOJA "
cQuery += "	LEFT OUTER JOIN	" + RETSQLNAME("SE5") + "  ON "
cQuery += "				E5_NUMERO 		= E1_NUM 		AND E5_PREFIXO 	= E1_PREFIXO "
cQuery += "				AND E5_PARCELA	= E1_PARCELA 	AND E5_TIPO 	= E1_TIPO "
cQuery += "				AND E5_CLIFOR 	= E1_CLIENTE  	AND E5_LOJA 	= E1_LOJA "
cQuery += " 			AND E5_RECPAG = 'R' "
cQuery += "				AND E5_TIPODOC IN ( 'BA', 'VL', 'ES', 'CP' ) "
cQuery += " 			AND " + RETSQLNAME("SE5") + ".D_E_L_E_T_ = ' '  " 	
cQuery += " WHERE A1_CGC <> '' "
cQuery += " AND A1_DTCAD <> '' "
cQuery += " AND " + RETSQLNAME("SA1") + ".D_E_L_E_T_ = ' '  " 	
cQuery += " AND " + RETSQLNAME("SE1") + ".D_E_L_E_T_ = ' '  " 	
cQuery += " AND E1_TIPO = 'NF' "
cQuery += " AND ((E1_EMISSAO BETWEEN '" + Str( ( Year( dDataBase ) - 01 ), 04 ) + SubStr( DtoS( dDataBase ), 05, 04 ) + "' AND '" + DtoS( dDataBase ) + "' )"
cQuery += " OR  E1_SALDO > 0 ) "
cQuery += " AND A1_CGC <> ' ' "   
//cQuery += " AND A1_COD = '010114' "		&& Testes
cQuery += " ORDER BY CGC,E5_DTDISPO "

tcQuery cQuery New Alias "ARQT"
dbSelectArea( "ARQT" )
Count to _nTotReg
ARQT->(dbGoTop())

Return()

/* Funcao para retornar data mais antiga do cadastro quando houver mais do que 01 Loja */
Static Function fDtCad( _cCGC )

Local aArea		:= GetArea()
Local cQuery	:= ""
Local dData		:= CtoD( "" )

cQuery := "SELECT MIN( A1_DTCAD ) AS CADASTRO "
cQuery += "FROM "
cQuery += RetSqlName( "SA1" ) + " "
cQuery += "WHERE (CASE WHEN A1_PESSOA = 'J' THEN SUBSTRING( A1_CGC, 01, 08 ) ELSE A1_CGC END) = '" + _cCGC + "' "

tcQuery cQuery New Alias "TTA1"

dbSelectArea( "TTA1" )

dData := StoD( TTA1->CADASTRO )

TTA1->( dbCloseArea() )

RestArea( aArea )

Return ( dData )