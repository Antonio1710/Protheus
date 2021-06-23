#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"  
#INCLUDE "AP5MAIL.CH"                                   
/*/{Protheus.doc} ADLOG030P
	Programa de WebService - desenvolvido para Fazer a leitura
	do Webservice CTAPLUS e gravar na tabela ZBB do protheus.  
	Realizar a Leitura Manualmente.                           
	@type  Static Function
	@author WILLIAM COSTA
	@since 20/06/2016
	@version 01
	@history Everson, 27/02/2020. Tratamento para marcação do sistema origem do lançamento.
	@history Everson, 11/03/2020. Ch. 053926 Alterado o índice de busca da rotina.
	@history Everson, 17/06/2020. Ch. 058732 Tratamento para o fonte utilizar a mesma função que está no fonte ADLOG022P.
	/*/
User Function ADLOG030P() // U_ADLOG030P()

	//Variáveis.       
	Local aSays		    := {}
	Local aButtons	    := {}   
	Local cCadastro	    := "ADLOG030P - Leitura Manual de Oléo CTAPLUS"    
	Local cPerg		    := 'ADLOG030P' 

	//	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de WebService - desenvolvido para Fazer a leitura do Webservice CTAPLUS e gravar na tabela ZBB do protheus Realizar a Leitura Manualmente.')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg(cPerg)
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	Aadd(aSays,"Leitura Manual de Oléo CTAPLUS. " )
	
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| o:oWnd:End(), MsAguarde({|| StaticCall(ADLOG022P,impDados,MV_PAR01,MV_PAR02) },"Função ADLOG030P(LERCTAPLUS)","Obtendo registros...")}})
	Aadd(aButtons, { 2,.T.,{|o| o:oWnd:End() }})
	  
	FormBatch( cCadastro, aSays, aButtons )  

Return Nil     
/*/{Protheus.doc} MontaPerg
	(long_description)
	@type  Static Function
	@author 
	@since
	@version 01
	/*/
Static Function MontaPerg(cPerg) 

	//Variáveis.                             
	Local bValid := Nil                                                                                                                    
	Local cF3	 := Nil
	Local cSXG	 := Nil
	Local cPyme	 := Nil
	
	//
    PutSx1(cPerg,'01','Data Fechamento Ini ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
    PutSx1(cPerg,'02','Data Fechamento Fim ?','','','mv_ch02','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	Pergunte(cPerg,.T.)
	
Return Nil