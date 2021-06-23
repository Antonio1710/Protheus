#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*{Protheus.doc} User Function ADFIN067P
	Rotina para criar a string com dados para o SISPAG ITAU
	@type  Function
	@author WILLIAM COSTA
	@since 19/09/2018
	@version 01
	@history Chamado 051041 - WILIAM COSTA - 13/08/2019 - REMESSA ITAU Identificado que quando precisa ser trocado o cnpj no titulo nao levava para o arquivo CNAB SISPAG, ajustado.
	@history Chamado 051653 - WILIAM COSTA - 09/09/2019 - RPA Identificado que existia um fornecedor que nao tem cnpj e nem cpf, foi adicionado para carregar o campo do SE2.
	@history Chamado 053432 - WILIAM COSTA - 18/11/2019 - Não pagaram titulos de acordo, identificado que o campo de Tipo de Inscrição não contemplava um fornecedor generalista onde ele é Juridico e estava mandando pessoa fisica, e o campo de CNPJ do titulo estava com . e - usando função para retirar.
	@history Chamado 054089 - WILIAM COSTA - 12/12/2019 - Identificado que no campo E2_CNPJ, quando vai contar o LEN do campo é necessário dar um ALLTRIM antes porque o tamanho do campo é 14 e os espaços fazem erram a contagem para quando o campo está com CPF, após ajuste o CNAB foi gerado corretamente.
	
*/

USER FUNCTION ADFIN067P(nParam)

	Local cRet := ''

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina para criar a string com dados para o SISPAG ITAU')
	
	IF nParam == 1 //Agencia Debitar
	
		cRet := STRZERO(VAL(ALLTRIM(SA6->A6_AGENCIA)),5,0)
		        
	ENDIF
	
	IF nParam == 2 //C/C Debitar
	
		cRet := STRZERO(VAL(ALLTRIM(SA6->A6_NUMCON)),12)

	ENDIF
	
	IF nParam == 3 //Camara Concentr
	
		cRet := IIF(ALLTRIM(SEA->EA_MODELO) == '41', '018',IIF(ALLTRIM(SEA->EA_MODELO) == '03', '700','000'))

	ENDIF
	
	// *** INICIO WILIAM COSTA 13/08/2019 CHAMADO 051041 || OS 052351 || FINANCAS || JENNIFER || 8499 || REMESSA ITAU *** //  
	
	IF nParam == 4 //CNPJ/CPF Favore 14 POSICOES
		
		  cRet := IIF(EMPTY(SA2->A2_CPF),IIF(SA2->A2_TIPO=='J',IIF(EMPTY(SE2->E2_CNPJ),SUBS(SA2->A2_CGC,1,14),SUBS(SE2->E2_CNPJ,1,14)),IIF(EMPTY(SA2->A2_CGC),STRZERO(VAL(SE2->E2_CNPJ),14),STRZERO(VAL(SA2->A2_CGC),14))),IIF(EMPTY(SE2->E2_CNPJ),STRZERO(VAL(SA2->A2_CPF),14),SUBS(SE2->E2_CNPJ,1,14))) // INICIO WILLIAM COSTA 10/09/2019 - CHAMADO 051653 || OS 052972 || FINANCAS || FLAVIA || 8461 || SISPAG ITAU - RPA
		  cRet := STRTRAN(STRTRAN(cRet,'.',''),'-','')
		  cRet := STRZERO(VAL(cRet),14)
		  
	ENDIF
	
 	IF nParam == 5 //CNPJ/CPF Favore 15 POSICOES
	
		  cRet := '0' + IIF(EMPTY(SA2->A2_CPF),IIF(SA2->A2_TIPO=='J',IIF(EMPTY(SE2->E2_CNPJ),SUBS(SA2->A2_CGC,1,14),SUBS(SE2->E2_CNPJ,1,14)),IIF(EMPTY(SA2->A2_CGC),STRZERO(VAL(SE2->E2_CNPJ),14),STRZERO(VAL(SA2->A2_CGC),14))),IIF(EMPTY(SE2->E2_CNPJ),STRZERO(VAL(SA2->A2_CPF),14),SUBS(SE2->E2_CNPJ,1,14))) // INICIO WILLIAM COSTA 10/09/2019 - CHAMADO 051653 || OS 052972 || FINANCAS || FLAVIA || 8461 || SISPAG ITAU - RPA
		  cRet := STRTRAN(STRTRAN(cRet,'.',''),'-','')
		  cRet := STRZERO(VAL(cRet),15)
	ENDIF
	
	IF nParam == 6 //Nome da empresa que estamos pagando 
	
		cRet := IIF(EMPTY(SE2->E2_NOMCTA),SUBS(ALLTRIM(SA2->A2_NOME),1,30),SUBS(ALLTRIM(SE2->E2_NOMCTA),1,30))

	ENDIF
	
	// *** FINAL WILIAM COSTA 13/08/2019 CHAMADO 051041 || OS 052351 || FINANCAS || JENNIFER || 8499 || REMESSA ITAU *** //

	// *** INICIO WILIAM COSTA 22/10/2019 051979 || OS 053348 || FINANCAS || DRIELE || 8376 || SISPAG ITAU - CERES

	IF nParam == 7 //CNPJ das Empresas 14 digitos
	
		IF CEMPANT = '01' //ADORO

			cRet := '60037058000131'
			       
			        
		ELSEIF CEMPANT = '02' //CERES
		
			cRet := '02090384000106'

		ELSEIF CEMPANT = '07' //RNX2
		
			cRet := '12097672000146'	
		
		ELSEIF CEMPANT = '09' //SAFEGG
		
			cRet := '20052541000170'

		ELSE 
		
			cRet := STRZERO(SUBSTR(SM0->M0_CGC,1,14),14)

		ENDIF
	ENDIF

	IF nParam == 8 //CNPJ das Empresas 15 digitos

		IF CEMPANT = '01' //ADORO

			cRet := '60037058000131'
				
					
		ELSEIF CEMPANT = '02' //CERES

			cRet := '02090384000106'

		ELSEIF CEMPANT = '07' //RNX2

			cRet := '12097672000146'	

		ELSEIF CEMPANT = '09' //SAFEGG

			cRet := '20052541000170'

		ELSE 

			cRet := STRZERO(SUBSTR(SM0->M0_CGC,1,14),14)

		ENDIF

		cRet := '0' + cRet

	ENDIF

	// *** FINAL WILIAM COSTA 22/10/2019 CHAMADO 051979 || OS 053348 || FINANCAS || DRIELE || 8376 || SISPAG ITAU - CERES

	IF nParam == 9 //Regra de Tipo de INSCRICAO

		cRet:= IIF(SA2->A2_TIPO=='J',IIF(EMPTY(SA2->A2_CPF),'2','1'),'1') //REGRA ANTERIOR 

		cRet:= IIF(ALLTRIM(SE2->E2_CNPJ) <> '' .AND. LEN(ALLTRIM(STRTRAN(STRTRAN(SE2->E2_CNPJ,'.',''),'-',''))) == 11,'1',cRet) //CPF Chamado 054089 - WILIAM COSTA         - 12/12/2019

		cRet:= IIF(ALLTRIM(SE2->E2_CNPJ) <> '' .AND. LEN(ALLTRIM(STRTRAN(STRTRAN(SE2->E2_CNPJ,'.',''),'-',''))) == 14,'2',cRet) //CNPJ Chamado 054089 - WILIAM COSTA         - 12/12/2019

	ENDIF

Return(cRet)