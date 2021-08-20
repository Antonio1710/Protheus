#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "DBTREE.CH"
// #INCLUDE "ADFIS028R.CH"

#DEFINE T00PARAM	000
#DEFINE T01GIA		010
#DEFINE T02GIAST	020

#DEFINE T05DEMON	050
#DEFINE T06DIFNA	060
#DEFINE T06CFNCT	061

#DEFINE T08OUT01	080
#DEFINE T08OUT02	081
#DEFINE T08OUT03	082

#DEFINE T09OUT01	090
#DEFINE T09OUT02	091

#DEFINE T14GRAXA	140

#DEFINE T20NFCAN	200

#DEFINE T22REVTR	220
#DEFINE T22RVTRR	221

#DEFINE T26OUT01	090 //VALOR IGUAL T09OUT01
#DEFINE T26OUT02	091 //VALOR IGUAL T09OUT02

#DEFINE T27IVA		270
#DEFINE T27DETMP  271

#DEFINE T28CIAP   280

#DEFINE T29COMMP  300

#DEFINE T30VENFV  300

#DEFINE T31APICM	270
#DEFINE T31DETAI  271

#DEFINE T32NFSER  300

#DEFINE T33ENTSA  310

#DEFINE T36RESUM  320
#DEFINE T36DETAL  330
/**********************
//DEFINIÇÃO DE CAMPOS
000 000000
 |     |-> SEQUENCIAL DOS CAMPOS COM INTERVALO DE 10 EM 10 PARA PERMITIR CRIAR CAMPOS ENTRE AS LINHAS JÁ CRIADAS
 |-> NUMERO DA TABELA EX: 000 PARAMETROS, 001 ABERTURA GIA, 011 POLENTA
**********************/
#DEFINE C00100		'000000100' //DATA INICIAL
#DEFINE C00110		'000000110' //DATA FINAL
#DEFINE C00120		'000000120' //PERIODO
#DEFINE C00130		'000000130' //USUARIO
#DEFINE C00140		'000000140' //DATA FECHAMENTO
#DEFINE C00150		'000000150' //HORA FECHAMENTO
#DEFINE C00160		'000000160' //DATA REABERTURA
#DEFINE C00170		'000000170' //HORA REABERTURA

#DEFINE C05100		'005000100' //SALDO MES ANTERIOR
#DEFINE C05200		'005000200' //ESTORNO DEBITO
#DEFINE C05250		'005000250' //OUTROS DEBITOS
#DEFINE C05300		'005000300' //ESTORNO CREDITO
#DEFINE C05350		'005000350' //OUTROS CREDITOS
#DEFINE C05351		'005000351' //APROPR CRED ACUMUL OUTROS DEBITOS
#DEFINE C05352		'005000352' //APROPR CRED ACUMUL OUTROS CREDITOS
#DEFINE C05500		'005000500' //APROPRIAÇÃO MÊS ANTERIOR
#DEFINE C05600		'005000600' //SOLICITAÇÃO DGCA
#DEFINE C05999		'005000999' //SALDO MES ATUAL

#DEFINE C06100		'006000100' //% UF DESTINO
#DEFINE C06110		'006000110' //% UF ORIGEM

#DEFINE C09990		'009009900' //REGISTROS CLASSIFICADOS OUTRAS SAIDAS
#DEFINE C11110		'011001100' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11111		'Outras Entr. Cesta Básica' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11112		'Outras Entr. Remessa p Teste' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11113		'Outras Entr. Retorno Criação' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11114		'Outras Entr. 4' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11115		'Outras Entr. 5' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11116		'Outras Entr. 6' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11117		'Outras Entr. 7' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11118		'Outras Entr. 8' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11119		'Outras Entr. 9' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11120		'Outras Entr. 10' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11121		'Outras Entr. 11' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11122		'Outras Entr. 12' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11123		'Outras Entr. 13' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS
#DEFINE C11124		'*** Sem Classificação ***' //REGISTROS CLASSIFICADOS OUTRAS ENTRADAS

#DEFINE P90000    '999999999' //PARAMETROS UTILIZADOS NO FECHAMENTO


/*/{Protheus.doc} User Function ADFIS038R
  Painel Fiscal ICMS São Carlos
  @type  Function
  @author Abel Babini
  @since 04/02/2020
  @version 1
  @history Chamado n.055548 - OS n.056953 - Abel Babini - 04/02/2020 - Painel Fiscal ICMS São Carlos
	@history Chamado n.055548 - OS n.057312 - Abel Babini - 10/02/2020 - Painel Fiscal ICMS SC - Relatório IVA
	@history Chamado n.055548 - OS n.057704 - Abel Babini - 24/03/2020 - Painel Fiscal ICMS SC - Relatório Compra MP
	@history Chamado n.055548 - OS n.057705 - Abel Babini - 17/03/2020 - Painel Fiscal ICMS SC - Relatório Ind Uso e Consumo
	@history Chamado Interno TI - OS        - Abel Babini - 29/05/2020 - Painel Fiscal ICMS - Ajuste de Error.log no Modelo2
	@history Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	@history Ticket 751                     - Abel Babini - 01/09/2020 - Painel Fiscal ICMS - Correção na soma do campo 57
	@history Ticket 10535			              - Abel Babini - 09/03/2021 - Criar relatório de conferência de faturamento por tipo de cliente e regime de apuração.
  /*/

User Function ADFIS038R()
	//LOG DE EXECUÇÃO DA ROTINA
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Painel Fiscal de Apuracao do ICMS Continuacao')

Return

/*/{Protheus.doc} Static Function xABrw27
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 11/02/2020
	@version 01
	/*/
Static Function xABrw27
	Local n5208:=n6208:=n5949:=n6949:=n5934:=n6934:=n5101:=n6101:=n5102:=n6102:=0
	Local n5118:=n6118:=n5901:=n6901:=n5206:=n6206:=n5201:=n6201:=n5553:=n6553:=0
	Local n5556:=n6556:=n5551:=n6551:=n1604:=n2604:=n7101:=n1252:=n2252:=n1101:=n2101:=0
	Local n1102:=n2102:=n1118:=n2118:=n1122:=n2122:=n1910:=n2910:=n5913:=n6913:=0 //Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	//Chamado Interno TI - OS        - Abel Babini - 29/05/2020 - Painel Fiscal ICMS - Ajuste de Error.log no Modelo2 - Criação de variáveis
	Local nTtFat:=nTotMes:=nTtCom:=nCp51:=nCp52:=nCp55:=nCp56:=nCp57:=nCp60:=nCp61:=nCp62:=nCp66:=0
	//Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	Local aICMCFO := {}
	Local aBrw3D	:= {}
	Local aBrw3C	:= {}
	Local nTotCFAd:=nTotCFAc	:= 0
	Local _i := 0	
	If Select(cAlB27Br) > 0
		(cAlB27Br)->(dbCloseArea())
	Endif
	cAlB27Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T27IVA)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T27IVA)
	oAlB27D1	:= StaticCall(ADFIS028R,CriaTmpT,cAlB27Br,_aFields,_aIndex)

	If Select(cAlB27Rs) > 0
		(cAlB27Rs)->(dbCloseArea())
	Endif
	cAlB27Rs:=GetNextAlias()
	BeginSQL  Alias cAlB27Rs
		SELECT
			SF3.F3_CFO AS CFOP,
			SF3.F3_ALIQICM AS ALIQICM,
			SUM(SF3.F3_VALCONT) AS VALCONT,
			SUM(SF3.F3_BASEICM) AS BASEICMS,
			SUM(SF3.F3_VALICM) AS VALICMS,
			SUM(SF3.F3_ISENICM) AS ISENTO,
			SUM(SF3.F3_OUTRICM) AS OUTRAS,
			SUM(SF3.F3_VALCONT - SF3.F3_BASEICM - SF3.F3_ISENICM - SF3.F3_OUTRICM - SF3.F3_IPIOBS)  AS DESCONT,
			SUM(SF3.F3_IPIOBS) AS VALIPI
		FROM %TABLE:SF3% SF3
		WHERE SF3.F3_FILIAL = %xFilial:SF3%
		AND F3_CFO NOT IN ('1126','2126','3126')
		AND SF3.F3_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.%notDel%
		GROUP BY SF3.F3_CFO, SF3.F3_ALIQICM
		ORDER BY 1, 2		
	EndSQL

	DbSelectArea(cAlB27Rs)
	(cAlB27Rs)->(DbGoTop())
	While !(cAlB27Rs)->(eof())

		RECLOCK(cAlB27Br,.T.)
			(cAlB27Br)->FILIAL 		:= cFilAnt
			(cAlB27Br)->CFOP 			:= (cAlB27Rs)->CFOP
			(cAlB27Br)->ALIQUOTA	:= (cAlB27Rs)->ALIQICM
			(cAlB27Br)->VALCONT 	:= (cAlB27Rs)->VALCONT
			(cAlB27Br)->BASEICMS 	:= (cAlB27Rs)->BASEICMS
			(cAlB27Br)->VALICMS 	:= (cAlB27Rs)->VALICMS
			(cAlB27Br)->ISENTO 		:= (cAlB27Rs)->ISENTO
			(cAlB27Br)->OUTRAS 		:= (cAlB27Rs)->OUTRAS
			(cAlB27Br)->DESCONT 	:= (cAlB27Rs)->DESCONT
			(cAlB27Br)->VALIPI 		:= (cAlB27Rs)->VALIPI
		MSUNLOCK()	
	
		//
		IF ALLTRIM((cAlB27Rs)->CFOP) < '5000'
			nTtCom	+= (cAlB27Rs)->VALICMS
		ENDIF

		IF ALLTRIM((cAlB27Rs)->CFOP) == '1604'
			n1604	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2604'
			n2604	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '1252'
			n1252	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '1101'
			n1101	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2101'
			n2101	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '1102'
			n1102	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2102'
			n2102	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '1118'
			n1118 += (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2118'
			n2118	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '1122'
			n1122	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2122'
			n2122	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2252'
			n2252	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '1910'
			n1910	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '2910'
			n2910	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5208'
			n5208	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6208'
			n6208	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5949'
			n5949	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6949'
			n6949	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5913'
			n5913	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6913'
			n6913	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5934'
			n5934	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6934'
			n6934	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5101'
			n5101	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6101'
			n6101	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '7101'
			n7101	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5102'
			n5102	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6102'
			n6102	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5118'
			n5118	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6118'
			n6118	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5901'
			n5901	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6901'
			n6901	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5206'
			n5206	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6206'
			n6206	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5201'
			n5201	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6201'
			n6201	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5551'
			n5551	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6551'
			n6551	+= (cAlB27Rs)->VALICMS
			nTtFat += (cAlB27Rs)->VALCONT
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5553'
			n5553	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6553'
			n6553	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '5556'
			n5556	+= (cAlB27Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB27Rs)->CFOP) == '6556'
			n6556	+= (cAlB27Rs)->VALICMS
		ENDIF

		//INICIO Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
		IF (cAlB27Rs)->VALICMS > 0
			
			nPos := ASCAN(aICMCFO, {|X| X[1] == ALLTRIM((cAlB27Rs)->CFOP)})
			
			If nPos == 0
				AADD(aICMCFO,{	ALLTRIM((cAlB27Rs)->CFOP),;
												(cAlB27Rs)->VALICMS})
			Else
				aICMCFO[nPos,2] += (cAlB27Rs)->VALICMS
			Endif
		ENDIF
		//FIM Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal

		(cAlB27Rs)->(DbSkip())
	EndDo

	(cAlB27Br)->(dbGoTop())
	(cAlB27Rs)->(dbCloseArea())	


	//INICIO Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	FOR _i := 1 to len(aICMCFO)
		//IF !aICMCFO[_i,1]$'5208/6208/5949/6949/5934/6934/5101/6101/5102/6102/5118/6118/5901/6901/5206/6206/5201/6201/5553/6553/5556/6556/5913/6913'
		IF !aICMCFO[_i,1]$'5208/6208/5949/6949/5934/6934/5101/6101/5102/6102/5118/6118/5901/6901/5206/6206/5201/6201/5553/6553/5556/6556/' .AND. substr(aICMCFO[_i,1],1,1)$'5/6/7'
			AADD(aBrw3D,{''		,'00245'+Alltrim(Str(_i)), aICMCFO[_i,1] + ' - ' + Alltrim(Posicione("SX5",1,xFilial("SX5")+"13"+Alltrim(aICMCFO[_i,1]),"X5_DESCRI")) , aICMCFO[_i,2]})
			nTotCFAd += aICMCFO[_i,2]

		ELSE
			IF nOpMdl == 4

				IF !aICMCFO[_i,1]$'1101,2101,1102,2102,1118,2118,1122,2122,1949,2949,1252,2252' .AND. ;
					 !aICMCFO[_i,1] $ _cCfBoni .AND. ;
					 !aICMCFO[_i,1] $ _cCFDVVD .AND. ;
					 !aICMCFO[_i,1] $ _cCFCIAP .AND. ;
					 substr(aICMCFO[_i,1],1,1)$'1/2/3'

					AADD(aBrw3C,{''		,'00520'+Alltrim(Str(_i)), aICMCFO[_i,1] + ' - ' + Alltrim(Posicione("SX5",1,xFilial("SX5")+"13"+Alltrim(aICMCFO[_i,1]),"X5_DESCRI")) , aICMCFO[_i,2]})
					nTotCFAc += aICMCFO[_i,2]
				ENDIF
			ELSE
				IF	!aICMCFO[_i,1]$'1101,2101,1949,2949,1252,2252' .AND. ;
						!aICMCFO[_i,1] $ _cCFDVVD .AND. ;
						!aICMCFO[_i,1] $ _cCFCIAP .AND. ;
						substr(aICMCFO[_i,1],1,1)$'1/2/3'

					AADD(aBrw3C,{''		,'00520'+Alltrim(Str(_i)), aICMCFO[_i,1] + ' - ' + Alltrim(Posicione("SX5",1,xFilial("SX5")+"13"+Alltrim(aICMCFO[_i,1]),"X5_DESCRI")) , aICMCFO[_i,2]})
					nTotCFAc += aICMCFO[_i,2]
				ENDIF
			ENDIF
		ENDIF	
	NEXT _i

	//FIM Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal


	If Select(cAlB27Nf) > 0
		(cAlB27Nf)->(dbCloseArea())
	Endif
	cAlB27Nf:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T27DETMP)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T27DETMP)
	oAlB27D2	:= StaticCall(ADFIS028R,CriaTmpT,cAlB27Nf,_aFields,_aIndex)

	If Select(cAlB27Dt) > 0
		(cAlB27Dt)->(dbCloseArea())
	Endif
	cAlB27Dt:=GetNextAlias()
	BeginSQL  Alias cAlB27Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SF3.F3_FILIAL		AS FILIAL,
			SF3.F3_SERIE		AS NFSERIE,
			SF3.F3_NFISCAL	AS NFISCAL,
			SF3.F3_CLIEFOR	AS CLIEFOR,
			SF3.F3_LOJA			AS LOJA,
			CASE WHEN (SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			SF3.F3_CFO			AS CFOP,
			SF3.F3_VALCONT	AS VALCONT,
			SF3.F3_BASEICM	AS BASEICMS,
			SF3.F3_ALIQICM	AS ALIQICM,
			SF3.F3_VALICM		AS VALICMS,
			SF3.F3_ISENICM 	AS ISENTO,
			SF3.F3_OUTRICM 	AS OUTRAS,
			SF3.F3_IPIOBS		AS VALIPI,
			(SF3.F3_VALCONT - SF3.F3_BASEICM - SF3.F3_ISENICM - SF3.F3_OUTRICM - SF3.F3_IPIOBS) AS VERIFIC,
			SF3.F3_ICMSRET	AS ICMSRET,
			SF3.F3_ICMSCOM	AS ICMSCOM,
			SF3.F3_ENTRADA	AS DTENTRADA,
			SF3.F3_EMISSAO	AS DTEMISSAO,
			SF3.F3_ESTADO		AS ESTADO,
			SF3.F3_CODRSEF	AS CODRSEF,
			SF3.F3_FORMUL		AS FORMUL
		FROM %TABLE:SF3% SF3
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.%notDel%
		AND SA2.A2_COD = SF3.F3_CLIEFOR
		AND SA2.A2_LOJA = SF3.F3_LOJA
		AND ( (SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') ) )
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.%notDel%
		AND SA1.A1_COD = SF3.F3_CLIEFOR
		AND SA1.A1_LOJA = SF3.F3_LOJA
		AND ( (SF3.F3_CFO > '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO < '5000' AND SF3.F3_TIPO IN ('D','B') ) )

		WHERE SF3.F3_FILIAL = %xFilial:SF3%
		AND F3_CFO NOT IN ('1126','2126','3126')
		AND SF3.F3_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.%notDel%
		ORDER BY 1, 2, 3	
	EndSQL
	DbSelectArea(cAlB27Dt)
	(cAlB27Dt)->(DbGoTop())
	While !(cAlB27Dt)->(eof())

		RECLOCK(cAlB27Nf,.T.)
			(cAlB27Nf)->FILIAL 		:= cFilAnt
			(cAlB27Nf)->NFSERIE 	:= (cAlB27Dt)->NFSERIE
			(cAlB27Nf)->NFISCAL 	:= (cAlB27Dt)->NFISCAL
			(cAlB27Nf)->CLIEFOR 	:= (cAlB27Dt)->CLIEFOR
			(cAlB27Nf)->LOJA 			:= (cAlB27Dt)->LOJA
			(cAlB27Nf)->NOME 			:= (cAlB27Dt)->NOME
			(cAlB27Nf)->CFOP 			:= (cAlB27Dt)->CFOP
			(cAlB27Nf)->VALCONT 	:= (cAlB27Dt)->VALCONT
			(cAlB27Nf)->BASEICMS 	:= (cAlB27Dt)->BASEICMS
			(cAlB27Nf)->ALIQICM		:= (cAlB27Dt)->ALIQICM
			(cAlB27Nf)->VALICMS 	:= (cAlB27Dt)->VALICMS
			(cAlB27Nf)->ISENTO 		:= (cAlB27Dt)->ISENTO
			(cAlB27Nf)->OUTRAS 		:= (cAlB27Dt)->OUTRAS
			(cAlB27Nf)->VERIFIC 	:= (cAlB27Dt)->VERIFIC
			(cAlB27Nf)->VALIPI 		:= (cAlB27Dt)->VALIPI
			(cAlB27Nf)->ICMSRET 	:= (cAlB27Dt)->ICMSRET
			(cAlB27Nf)->ICMSCOM 	:= (cAlB27Dt)->ICMSCOM
			(cAlB27Nf)->ESTADO 		:= (cAlB27Dt)->ESTADO
			(cAlB27Nf)->DTENTRADA := (cAlB27Dt)->DTENTRADA
			(cAlB27Nf)->DTEMISSAO := (cAlB27Dt)->DTEMISSAO
			(cAlB27Nf)->CODRSEF 	:= (cAlB27Dt)->CODRSEF
			(cAlB27Nf)->FORMUL 		:= (cAlB27Dt)->FORMUL
		MSUNLOCK()	
		(cAlB27Dt)->(DbSkip())
	EndDo

	(cAlB27Nf)->(dbGoTop())
	(cAlB27Dt)->(dbCloseArea())	

	//	
	//Preenche Array da abertura da Gia
	aBrw03Rs := {} //Linha;Descrição;Valor
	nCp51 :=	n5208+n6208+n6949+n5934+n6934+n5101+n6101+n5102+n6102+n5118+n6118+n5949+;
						n5901+n6901+n5206+n6206+n5201+n6201+n5553+n6553+n5556+n6556+nTotCFAd //Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal

	//Chamado n.060517 - OS n.062030 - Abel Babini - 17/08/2020 - Altera regra de calculo do ICMS sobre Frete para os modelos 2 e 4
	IF _lMVCrFt			
		nVFrt := nA24T06
	ELSE
		nVFrt	:= Round(nA24T05 * 0.12,2)
	ENDIF
	//24T01
	//24T17

	nCp52	:= nVFrt+nA07T91+nA05T03+nA05T07+(nA15T06 - nA15T03)
	nCp55	:= nCp51+nCp52

	IF nOpMdl == 4
		nCp56 := n1101+n2101+n1102+n2102+n1118+n2118+n1122+n2122+nVDVVen+nA26T022+nA26T032+nA26T042+nA26T052+nA26T062+nA26T072+nA26T082+nA26T092+nA26T102+nA26T112+nA26T122+nA26T132+nA26T142+nA26T152+n1252+n2252+_nVlBoni+nTotCFAc //Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	ELSE
		nCp56 := n1101+n2101+nVDVVen+nA26T022+nA26T032+nA26T042+nA26T052+nA26T062+nA26T072+nA26T082+nA26T092+nA26T102+nA26T112+nA26T122+nA26T132+nA26T142+nA26T152+n1252+n2252+nTotCFAc //Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	ENDIF

	//INICIO @history Ticket 751 - Abel Babini - 01/09/2020 - Painel Fiscal ICMS - Correção na soma do campo 57
	nCp57	:= IIF(!_lMVCrFt,nVFrt,0)+nA07T92+nA05T10+nA05T08+nA05T02+n5556+n6556+nA07T25
	nCp60	:= nCp56+nCp57

	If _lMsUser	.or. _lPerFch
		aRecSd05	:= xRecSd05()
		cMV05T01	:= aRecSd05[1] //Max Versao
		nA05T01		:= aRecSd05[2] //Vl. Saldo Credor Mês Anterior
		nA05T02		:= aRecSd05[3] //Vl. Estorno de Débitos
		cA05T02		:= aRecSd05[4] 
		nA05T03		:= aRecSd05[5] //Vl. Estorno de Créditos
		cA05T03		:= aRecSd05[6] 
		nA05T04		:= aRecSd05[7] //Apropriação de Crédito Acumulado
		nA05T05		:= aRecSd05[8] //Vl. Saldo Credor Mês Atual
		nA05T06		:= aRecSd05[9] //Solicitação DGCA
		nA05T07		:= aRecSd05[10] //Outros Débitos
		cA05T04		:= aRecSd05[11] 
		nA05T08		:= aRecSd05[12] //Outros Créditos
		cA05T05		:= aRecSd05[13] 
		nA05T09		:= aRecSd05[14] //Aprop Cred Acum Outros Débitos
		nA05T10		:= aRecSd05[15] //Aprop Cred Acum Outros Créditos
	Endif

	nCp61	:= nA05T01
	nCp62	:= nCp60+nCp61
	nCp66	:= nCp62-nCp55
	nTotMes := nCp60-nCp55

	AADD(aBrw03Rs,{'TIT','000100','074-FATURAMENTO MES',nTtFat} )
	AADD(aBrw03Rs,{'SUB','001000','051-POR SAIDAS C/DEBITO DO IMPOSTO',nCp51} )
	AADD(aBrw03Rs,{''		,'001100','5.208 /6.208 - DEVOLUÇÃO TRANSFERÊNCIA',n5208+n6208} )
	AADD(aBrw03Rs,{''		,'001200','6.949 -REMESSA PARA INTEGRADO',n6949} )
	AADD(aBrw03Rs,{''		,'001300','6.934 - REMESSA SIMBÓLICA ARMAZENAGEM',n5934+n6934} )
	AADD(aBrw03Rs,{''		,'001400','5.101/6.101 -VENDA MERC. PROD PROPRIA',n5101+n6101} )
	AADD(aBrw03Rs,{''		,'001500','5.102/6.102 -VENDA MERC. ADQUIRIDA TERC.',n5102+n6102} )
	AADD(aBrw03Rs,{''		,'001600','5.118 / 6.118 - VENDA A ORDEM',n5118+n6118} )
	AADD(aBrw03Rs,{''		,'001700','5.949 - CESTA BASICA',nA09T022} )
	AADD(aBrw03Rs,{''		,'001800','5.949 - FRANGO',nA09T032} )
	AADD(aBrw03Rs,{''		,'001900','5.949 - DESCARTE DE MATERIAL',0} )
	AADD(aBrw03Rs,{''		,'001901','5.949 - REMESSA ANÁLISE',nA09T052+nA09T062} )
	AADD(aBrw03Rs,{''		,'001901','5.949 - REMESSA GARANTIA',nA09T072+nA09T082} )
	AADD(aBrw03Rs,{''		,'001901','5.949 - OUTRAS SAÍDAS',nA09T042+nA09T092+nA09T102+nA09T112+nA09T122+nA09T132+nA09T142+nA09T152} )
	AADD(aBrw03Rs,{''		,'002000','5.901 - REMESSA INDUSTRIALIZAÇÃO ',n5901+n6901} )
	AADD(aBrw03Rs,{''		,'002100','5.206/6.206 - ANULAÇÃO FRETE',n5206+n6206} )
	AADD(aBrw03Rs,{''		,'002200','5.201/6.201 - DEVOLUÇÃO DE MAT. PRIMA',n5201+n6201} )
	AADD(aBrw03Rs,{''		,'002300','5.553/6.553 - DEVOLUÇÃO IMOBILIZADO',n5553+n6553} )
	AADD(aBrw03Rs,{''		,'002400','5.556/6.556 - DEVOLUCAO MAT USO E CONSUMO',n5556+n6556} )
	//AADD(aBrw03Rs,{''		,'002450','5.913/6.913 - RETORNO DEMONSTRAÇÃO',n5913+n6913} )

	//INICIO @history Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	IF Len(aBrw3D) > 0
		For _i := 1 to Len(aBrw3D)
			AADD(aBrw03Rs,{ '',aBrw3D[_i,2],aBrw3D[_i,3],aBrw3D[_i,4] })
		Next _i
	ENDIF

	AADD(aBrw03Rs,{'SUB','003000','052-OUTROS DEBITOS',nCp52} )
	AADD(aBrw03Rs,{''		,'003100','002.06 - Frete substituição',nVFrt} )
	AADD(aBrw03Rs,{''		,'003200','002.07 - Diferencial de aliquota ',nA07T91} )

	//Chamado n.060037 - OS n.061528 - Abel Babini - 27/07/2020 - Excluir filtro de Formulário próprio do relatório de Lenha e incluir informação no Demonstrativo e Abertura da Gia
	AADD(aBrw03Rs,{''		,'003205','002.99 - Lenha ',nA15T06 - nA15T03} )

	AADD(aBrw03Rs,{'MAN','003210','002.21 - Outros Débitos Apropr. de Créd. Acumulado - ***MANUAL***',nA05T09} )
	//AADD(aBrw03Rs,{''		,'003400','002.19 - Recebimento Saldo Devedor Rio Claro',0} )
	//AADD(aBrw03Rs,{''		,'003500','002.19 - Recebimento Saldo Devedor Matriz',0} )
	AADD(aBrw03Rs,{'MAN','003600','***MANUAL*** '+IIF(Alltrim(cA05T03) <> '', Alltrim(cA05T03), '003.99 - Estorno de Créditos '),nA05T03} )
	AADD(aBrw03Rs,{'MAN','003700','***MANUAL*** '+IIF(Alltrim(cA05T04) <> '', Alltrim(cA05T04), '002.99 - Outros Débitos '),nA05T07} )
	AADD(aBrw03Rs,{'TOT','004000','055-TOTAL DEBITO',nCp55} )
	AADD(aBrw03Rs,{''		,'004100','',0} )
	AADD(aBrw03Rs,{'TOT','005000','056-POR ENTRADAS C/CRÉDITO DO IMPOSTO',nCp56} )
	
	//AADD(aBrw03Rs,{''		,'005010','ENTRADAS C/ CRÉDITO NÃO DETALHADAS',nTtCom-(n1252+n2252+nA26T022+nA26T032+nA26T042+nA26T052+nA26T062+nA26T072+nA26T082+nA26T092+nA26T102+nA26T112+nA26T122+nA26T132+nA26T142+nA26T152+n1101+n2101+nVDVVen)} )
	IF nOpMdl == 4
		AADD(aBrw03Rs,{''		,'005020','INSUMOS',n1101+n2101+n1102+n2102+n1118+n2118+n1122+n2122} )
		AADD(aBrw03Rs,{''		,'005025','BONIFICAÇÃO PINTOS DE 1 DIA MACHO/FÊMEA',_nVlBoni} )
	ELSE
		AADD(aBrw03Rs,{''		,'005020','INSUMOS',n1101+n2101} )
	ENDIF

	AADD(aBrw03Rs,{''		,'005030','DEVOLUÇÃO DE VENDAS',nVDVVen} )
	// AADD(aBrw03Rs,{''		,'005040','FRETE',0} )
	AADD(aBrw03Rs,{''		,'005050','ENTRADA DE CESTA BÁSICA',nA26T022} )
	AADD(aBrw03Rs,{''		,'005051','1949 - OUTRAS ENTRADAS',nA26T032+nA26T042+nA26T052+nA26T062+nA26T072+nA26T082+nA26T092+nA26T102+nA26T112+nA26T122+nA26T132+nA26T142+nA26T152} )
	AADD(aBrw03Rs,{''		,'005060','ENERGIA ELÉTRICA',n1252+n2252} )

	AADD(aBrw03Rs,{''		,'005100','',0} )
	//INICIO @history Chamado Interno TI - OS        - Abel Babini - 05/06/2020 - Painel Fiscal ICMS - Ajuste no Painel Fiscal trazer CFOP´s com valores destacados de ICMS sem definição anterior no Painel Fiscal
	IF Len(aBrw3C) > 0
		For _i := 1 to Len(aBrw3C)
			AADD(aBrw03Rs, { '',aBrw3C[_i,2],aBrw3C[_i,3],aBrw3C[_i,4] })
		Next _i
	ENDIF
	AADD(aBrw03Rs,{''		,'006100','',0} )
	//AADD(aBrw03Rs,{'SUB','006000','SUB-TOTAL',0} )
	AADD(aBrw03Rs,{'TIT','007000','DIVERSOS ',0} )
	AADD(aBrw03Rs,{''		,'007100','Credito ICMS - Ativo Imobilizado',nVCiap/*n1604+n2604*/} )
	AADD(aBrw03Rs,{''		,'007200','',0} )
	AADD(aBrw03Rs,{'SUB','008000','SUB-TOTAL',nVCiap/*n1604+n2604*/} )
	AADD(aBrw03Rs,{''		,'008100','',0} )
	//AADD(aBrw03Rs,{'TOT','009000','TOTAL POR ENTRADAS C/ CREDITO',nTtCom} )
	AADD(aBrw03Rs,{''		,'009100','',0} )
	AADD(aBrw03Rs,{'SUB','010000','057- OUTROS CRÉDITOS',nCp57} )
	//Chamado n.060517 - OS n.062030 - Abel Babini - 17/08/2020 - Altera regra de calculo do ICMS sobre Frete para os modelos 2 e 4
	IF !_lMVCrFt
		AADD(aBrw03Rs,{''	,'010100','007.99 - Frete substituição ',nVFrt} )
	ENDIF
	AADD(aBrw03Rs,{''		,'010200','007.18 - Diferencial de aliquota',nA07T92} )
	AADD(aBrw03Rs,{'MAN','010300','007.40 - Outros Créditos Apropr. de Créd. Acumulado - ***MANUAL***',nA05T10} )
	AADD(aBrw03Rs,{'MAN','010310','***MANUAL*** - '+IIF(Alltrim(cA05T05) <> '', Alltrim(cA05T05), '007.99 - Outros creditos '),nA05T08} )
	AADD(aBrw03Rs,{'MAN','010320','***MANUAL*** - '+IIF(Alltrim(cA05T02) <> '', Alltrim(cA05T02), '007.99 - Estorno debitos '),nA05T02} )
	AADD(aBrw03Rs,{''		,'010400','007.99 - Devolução Mat. Consumo ',n5556+n6556} )
	//AADD(aBrw03Rs,{''		,'010500','007.99 - Aquisição de material de uso/consumo (frango Dez/19)',nA09T032} )
	AADD(aBrw03Rs,{''		,'010600','008.01 - Estorno Diferencial de Aliquota(Dev Uso e Consumo)',nA07T25} )
  AADD(aBrw03Rs,{''		,'010700','',0} )
	AADD(aBrw03Rs,{'SUB','011000','060-SUBTOTAL',nCp60} )
	AADD(aBrw03Rs,{'SUB','012000','061-SALDO CREDOR MES ANTERIOR ',nCp61} )
	AADD(aBrw03Rs,{'TOT','015000','062-TOTAL GERAL DE CRÉDITOS',nCp62} )
	AADD(aBrw03Rs,{'TOT','020000','063-SALDO DO MÊS '+IIF(nTotMes >=0,'CREDOR','DEVEDOR'),nTotMes} )
	AADD(aBrw03Rs,{'TOT','050000','066-SALDO'+IIF(nCp66>=0,' CREDOR ',' DEVEDOR ')+'À TRANSPORTAR',nCp66} )



Return

/*/{Protheus.doc} Static Function xRelBr27
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xRelBr27()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel ")
	AADD(aSays,"Relatorio IVA")
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr27b()},"Gerando arquivo","Aguarde...") }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr27b
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xRelBr27b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RIVA_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo Saídas
		Cab27P1()
		GEx27P1()

		//Planilha1 - Resumo Entradas
		Cab27P2()
		GEx27P2()

		//Planilha1 - Detalhe Saídas
		Cab27P3()
		GEx27P3()

		//Planilha1 - Detalhe Entradas
		Cab27P4()
		GEx27P4()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab27P1
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab27P1()
	oExcel:AddworkSheet(cFld271)
	oExcel:AddTable(cFld271,cFld27t1)
	oExcel:AddColumn(cFld271,cFld27t1,"Filial",1,1)
	oExcel:AddColumn(cFld271,cFld27t1,"CFOP",1,1)
	oExcel:AddColumn(cFld271,cFld27t1,"Alíquota",1,1)
	oExcel:AddColumn(cFld271,cFld27t1,"Valor Cont.",2,3)
	oExcel:AddColumn(cFld271,cFld27t1,"Base ICMS",2,3)
	oExcel:AddColumn(cFld271,cFld27t1,"Vl. ICMS",2,3)
	oExcel:AddColumn(cFld271,cFld27t1,"Isentas",2,3)
	oExcel:AddColumn(cFld271,cFld27t1,"Outras",2,3)
	oExcel:AddColumn(cFld271,cFld27t1,"Descontos.",2,3)
	oExcel:AddColumn(cFld271,cFld27t1,"Vl. IPI",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab27P2
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab27P2()
	oExcel:AddworkSheet(cFld272)
	oExcel:AddTable(cFld272,cFld27t2)
	oExcel:AddColumn(cFld272,cFld27t2,"Filial",1,1)
	oExcel:AddColumn(cFld272,cFld27t2,"CFOP",1,1)
	oExcel:AddColumn(cFld272,cFld27t2,"Alíquota",1,1)
	oExcel:AddColumn(cFld272,cFld27t2,"Valor Cont.",2,3)
	oExcel:AddColumn(cFld272,cFld27t2,"Base ICMS",2,3)
	oExcel:AddColumn(cFld272,cFld27t2,"Vl. ICMS",2,3)
	oExcel:AddColumn(cFld272,cFld27t2,"Isentas",2,3)
	oExcel:AddColumn(cFld272,cFld27t2,"Outras",2,3)
	oExcel:AddColumn(cFld272,cFld27t2,"Descontos.",2,3)
	oExcel:AddColumn(cFld272,cFld27t2,"Vl. IPI",2,3)
RETURN(NIL) 

/*/{Protheus.doc} Static Function Cab27P3
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab27P3()
	oExcel:AddworkSheet(cFld273)
	oExcel:AddTable(cFld273,cFld27t3)
	oExcel:AddColumn(cFld273,cFld27t3,"Filial",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Série",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Código",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Loja",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Nome",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"CFOP",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Valor Cont.",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Base ICMS",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Alíquota",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Vl. ICMS",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Isentas",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Outras",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Verific.",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Vl. IPI",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"ICMS Ret.",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"ICMS Com.",2,3,.t.)
	oExcel:AddColumn(cFld273,cFld27t3,"Estado",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Cod.Ret.SEF",1,1)
	oExcel:AddColumn(cFld273,cFld27t3,"Formul.",1,1)
RETURN(NIL) 

/*/{Protheus.doc} Static Function Cab27P4
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab27P4()
	oExcel:AddworkSheet(cFld274)
	oExcel:AddTable(cFld274,cFld27t4)
	oExcel:AddColumn(cFld274,cFld27t4,"Filial",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Série",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Código",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Loja",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Nome",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"CFOP",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Valor Cont.",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Base ICMS",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Alíquota",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Vl. ICMS",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Isentas",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Outras",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Verific.",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Vl. IPI",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"ICMS Ret.",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"ICMS Com.",2,3,.t.)
	oExcel:AddColumn(cFld274,cFld27t4,"Estado",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Cod.Ret.SEF",1,1)
	oExcel:AddColumn(cFld274,cFld27t4,"Formul.",1,1)
RETURN(NIL)

/*/{Protheus.doc} Static Function GEx27P1  
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/

Static Function GEx27P1()
	Local nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
	Local nTTCont:=nTTBase:=nTTICMS:=nTTIsen:=nTTOutr:=nTTDesc:=nTTIPI:=0
	Local cAuxCFOP:=""
	//
	(cAlB27Br)->(dbGoTop())
	While !(cAlB27Br)->(Eof())
		IF Substr((cAlB27Br)->CFOP,1,1) >= '5'
			IF Substr(cAuxCFOP,1,1) <> Substr((cAlB27Br)->CFOP,1,1) .AND. !cAuxCFOP==""
				oExcel:AddRow(cFld271,cFld27t1,{(cAlB27Br)->FILIAL,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
				oExcel:AddRow(cFld271,cFld27t1,{"","","","","","","","","",""})
				nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
			ENDIF
			oExcel:AddRow(cFld271,cFld27t1,{(cAlB27Br)->FILIAL,;
																			(cAlB27Br)->CFOP,;
																			(cAlB27Br)->ALIQUOTA,;
																			(cAlB27Br)->VALCONT,;
																			(cAlB27Br)->BASEICMS,;
																			(cAlB27Br)->VALICMS,;
																			(cAlB27Br)->ISENTO,;
																			(cAlB27Br)->OUTRAS,;
																			(cAlB27Br)->DESCONT,;
																			(cAlB27Br)->VALIPI})
			nTVlCont+=	(cAlB27Br)->VALCONT
			nTVlBase+=	(cAlB27Br)->BASEICMS
			nTVlICMS+=	(cAlB27Br)->VALICMS
			nTVlIsen+=	(cAlB27Br)->ISENTO
			nTVlOutr+=	(cAlB27Br)->OUTRAS
			nTVlDesc+=	(cAlB27Br)->DESCONT
			nTVlIPI	+=	(cAlB27Br)->VALIPI
			cAuxCFOP:=	(cAlB27Br)->CFOP

			nTTCont	+=	(cAlB27Br)->VALCONT
			nTTBase	+=	(cAlB27Br)->BASEICMS
			nTTICMS	+=	(cAlB27Br)->VALICMS
			nTTIsen	+=	(cAlB27Br)->ISENTO
			nTTOutr	+=	(cAlB27Br)->OUTRAS
			nTTDesc	+=	(cAlB27Br)->DESCONT
			nTTIPI	+=	(cAlB27Br)->VALIPI
		ENDIF
		(cAlB27Br)->(dbSkip())
	ENDDO
	(cAlB27Br)->(dbGoTop())
	oExcel:AddRow(cFld271,cFld27t1,{cFilAnt,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
	oExcel:AddRow(cFld271,cFld27t1,{"","","","","","","","","",""})
	oExcel:AddRow(cFld271,cFld27t1,{"","","","","","","","","",""})
	oExcel:AddRow(cFld271,cFld27t1,{cFilAnt,"TOTAL GERAL","",nTTCont,nTTBase,nTTICMS,nTTIsen,nTTOutr,nTTDesc,nTTIPI})
Return

/*/{Protheus.doc} Static Function GEx27P2
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/

Static Function GEx27P2()
	Local nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
	Local nTTCont:=nTTBase:=nTTICMS:=nTTIsen:=nTTOutr:=nTTDesc:=nTTIPI:=0
	Local cAuxCFOP:=""
	//
	(cAlB27Br)->(dbGoTop())
	While !(cAlB27Br)->(Eof())
		IF Substr((cAlB27Br)->CFOP,1,1) < '5'
			IF Substr(cAuxCFOP,1,1) <> Substr((cAlB27Br)->CFOP,1,1) .AND. !cAuxCFOP==""
				oExcel:AddRow(cFld272,cFld27t2,{(cAlB27Br)->FILIAL,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
				oExcel:AddRow(cFld272,cFld27t2,{"","","","","","","","","",""})
				nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
			ENDIF
			oExcel:AddRow(cFld272,cFld27t2,{(cAlB27Br)->FILIAL,;
																			(cAlB27Br)->CFOP,;
																			(cAlB27Br)->ALIQUOTA,;
																			(cAlB27Br)->VALCONT,;
																			(cAlB27Br)->BASEICMS,;
																			(cAlB27Br)->VALICMS,;
																			(cAlB27Br)->ISENTO,;
																			(cAlB27Br)->OUTRAS,;
																			(cAlB27Br)->DESCONT,;
																			(cAlB27Br)->VALIPI})
			nTVlCont+=	(cAlB27Br)->VALCONT
			nTVlBase+=	(cAlB27Br)->BASEICMS
			nTVlICMS+=	(cAlB27Br)->VALICMS
			nTVlIsen+=	(cAlB27Br)->ISENTO
			nTVlOutr+=	(cAlB27Br)->OUTRAS
			nTVlDesc+=	(cAlB27Br)->DESCONT
			nTVlIPI	+=	(cAlB27Br)->VALIPI
			cAuxCFOP:=	(cAlB27Br)->CFOP

			nTTCont	+=	(cAlB27Br)->VALCONT
			nTTBase	+=	(cAlB27Br)->BASEICMS
			nTTICMS	+=	(cAlB27Br)->VALICMS
			nTTIsen	+=	(cAlB27Br)->ISENTO
			nTTOutr	+=	(cAlB27Br)->OUTRAS
			nTTDesc	+=	(cAlB27Br)->DESCONT
			nTTIPI	+=	(cAlB27Br)->VALIPI
		ENDIF
		(cAlB27Br)->(dbSkip())
	ENDDO
	(cAlB27Br)->(dbGoTop())
	oExcel:AddRow(cFld272,cFld27t2,{cFilAnt,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
	oExcel:AddRow(cFld272,cFld27t2,{"","","","","","","","","",""})
	oExcel:AddRow(cFld272,cFld27t2,{"","","","","","","","","",""})
	oExcel:AddRow(cFld272,cFld27t2,{cFilAnt,"TOTAL GERAL","",nTTCont,nTTBase,nTTICMS,nTTIsen,nTTOutr,nTTDesc,nTTIPI})
Return

/*/{Protheus.doc} Static Function GEx27P3
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/

Static Function GEx27P3()
	//
	(cAlB27Nf)->(dbGoTop())
	While !(cAlB27Nf)->(Eof())
		IF Substr((cAlB27Nf)->CFOP,1,1) >= '5'
			oExcel:AddRow(cFld273,cFld27t3,{(cAlB27Nf)->FILIAL,;
																			(cAlB27Nf)->NFSERIE,;
																			(cAlB27Nf)->NFISCAL,;
																			(cAlB27Nf)->DTENTRADA,;
																			(cAlB27Nf)->DTEMISSAO,;
																			(cAlB27Nf)->CLIEFOR,;
																			(cAlB27Nf)->LOJA,;
																			(cAlB27Nf)->NOME,;
																			(cAlB27Nf)->CFOP,;
																			(cAlB27Nf)->VALCONT,;
																			(cAlB27Nf)->BASEICMS,;
																			(cAlB27Nf)->ALIQICM,;
																			(cAlB27Nf)->VALICMS,;
																			(cAlB27Nf)->ISENTO,;
																			(cAlB27Nf)->OUTRAS,;
																			(cAlB27Nf)->VERIFIC,;
																			(cAlB27Nf)->VALIPI,;
																			(cAlB27Nf)->ICMSRET,;
																			(cAlB27Nf)->ICMSCOM,;
																			(cAlB27Nf)->ESTADO,;
																			(cAlB27Nf)->CODRSEF,;
																			(cAlB27Nf)->FORMUL})
		ENDIF
		(cAlB27Nf)->(dbSkip())
	ENDDO
	(cAlB27Nf)->(dbGoTop())
	oExcel:AddRow(cFld273,cFld27t3,{"","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx27P4
	Gera Relatório Ref. IVA
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/

Static Function GEx27P4()
	//
	(cAlB27Nf)->(dbGoTop())
	While !(cAlB27Nf)->(Eof())
		IF Substr((cAlB27Nf)->CFOP,1,1) < '5'
			oExcel:AddRow(cFld274,cFld27t4,{(cAlB27Nf)->FILIAL,;
																			(cAlB27Nf)->NFSERIE,;
																			(cAlB27Nf)->NFISCAL,;
																			(cAlB27Nf)->DTENTRADA,;
																			(cAlB27Nf)->DTEMISSAO,;
																			(cAlB27Nf)->CLIEFOR,;
																			(cAlB27Nf)->LOJA,;
																			(cAlB27Nf)->NOME,;
																			(cAlB27Nf)->CFOP,;
																			(cAlB27Nf)->VALCONT,;
																			(cAlB27Nf)->BASEICMS,;
																			(cAlB27Nf)->ALIQICM,;
																			(cAlB27Nf)->VALICMS,;
																			(cAlB27Nf)->ISENTO,;
																			(cAlB27Nf)->OUTRAS,;
																			(cAlB27Nf)->VERIFIC,;
																			(cAlB27Nf)->VALIPI,;
																			(cAlB27Nf)->ICMSRET,;
																			(cAlB27Nf)->ICMSCOM,;
																			(cAlB27Nf)->ESTADO,;
																			(cAlB27Nf)->CODRSEF,;
																			(cAlB27Nf)->FORMUL})
		ENDIF
		(cAlB27Nf)->(dbSkip())
	ENDDO
	(cAlB27Nf)->(dbGoTop())
	oExcel:AddRow(cFld274,cFld27t4,{"","","","","","","","","","","","","","","","","","","","","",""})
Return

// INICIO Chamado n.050629 - OS n. - Relatorio Abertura GIA - Abel Babini - 28/10/2019
/*/{Protheus.doc} Static Function xABrw03
	Gera Relatório Ref. ABERTURA GIA
	@type  Static Function
	@author Abel Babini Filho
	@since 28/10/2019
	@version version
	/*/
Static Function xABrw03()
	Local _aFields := {}
	Local i := 0
	If Select(cAlB03Rs) > 0
		(cAlB03Rs)->(dbCloseArea())
	Endif
	//cAlB03Rs:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T01GIA)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T01GIA)
	oAlB03Rs	:= StaticCall(ADFIS028R,CriaTmpT,cAlB03Rs,_aFields,_aIndex)

	FOR i:=1 to Len(aBrw03Rs)
		RECLOCK(cAlB03Rs,.T.)
			(cAlB03Rs)->LINHA	:= i
			(cAlB03Rs)->FILIAL:= cFilAnt
			(cAlB03Rs)->TPLIN:= aBrw03Rs[i,1]
			(cAlB03Rs)->LNGIA	:= aBrw03Rs[i,2]
			(cAlB03Rs)->DESCR	:= aBrw03Rs[i,3]
			IF ValType(aBrw03Rs[i,4]) == 'N'
				(cAlB03Rs)->VALOR	:= Round(aBrw03Rs[i,4],2)
			ELSEIF ValType(aBrw03Rs[i,4]) == 'C'
				(cAlB03Rs)->VALOR	:= Val(aBrw03Rs[i,4])
			ELSE
				(cAlB03Rs)->VALOR	:= 0
			ENDIF
		MSUNLOCK()	
	NEXT i
	(cAlB03Rs)->(dbGoTOP())

	FreeObj(aBrw03Rs)
	SysRefresh()
Return

/*/{Protheus.doc} Static Function xRelBr03
	Gera Relatório Ref. Abertura GIA
	@author Abel Babini Filho
	@since 19/11/2019
	@version 01
	/*/
Static Function xRelBr03()
	Local aSays			:= {}
	Local aButtons	:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Abertura GIA" )
		
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr03b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return
	
/*/{Protheus.doc} Static Function xRelBr05b  
	Gera Relatório Ref. Abertura GIA
	@author Abel Babini Filho
	@since 19/11/2019
	@version 01
	/*/
Static Function xRelBr03b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'ABERTURAGIA_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//		Alert("Nao Existe Excel Instalado")
		//				BREAK
		//EndIF
					
		//Planilha1 - Detalhamento
		Cab03P1()             
		GEx03P1()					

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return
	
/*/{Protheus.doc} Static Function Cab03P1  
	Gera Relatório Ref. Abertura GIA
	@author Abel Babini Filho
	@since 19/11/2019
	@version 01
	/*/
Static Function Cab03P1()
	oExcel:AddworkSheet(cFld031)
	oExcel:AddTable(cFld031,cFld03t1)
	oExcel:AddColumn(cFld031,cFld03t1,"Filial",1,1)
	oExcel:AddColumn(cFld031,cFld03t1,"Linha",1,1)
	oExcel:AddColumn(cFld031,cFld03t1,"Descrição",1,1)
	oExcel:AddColumn(cFld031,cFld03t1,"Valor",2,3)
RETURN(NIL)  
	


/*/{Protheus.doc} Static Function GEx03P1
	Gera Relatório Ref. Abertura GIA
	@author Abel Babini Filho
	@since 19/11/2019
	@version 01
	/*/
Static Function GEx03P1()
	//
	(cAlB03Rs)->(dbGoTop())
	While !(cAlB03Rs)->(Eof())
		ExForCel(Alltrim((cAlB03Rs)->TPLIN))
		IF Alltrim((cAlB03Rs)->TPLIN) == 'TIT'
			oExcel:AddRow(cFld031,cFld03t1,{'',;
																			(cAlB03Rs)->LNGIA,;
																			(cAlB03Rs)->DESCR,;
																			''},{1,2,3,4})
		ELSE
			oExcel:AddRow(cFld031,cFld03t1,{(cAlB03Rs)->FILIAL,;
																			(cAlB03Rs)->LNGIA,;
																			(cAlB03Rs)->DESCR,;
																			(cAlB03Rs)->VALOR},{1,2,3,4})
		ENDIF

		(cAlB03Rs)->(dbSkip())
	ENDDO
	oExcel:AddRow(cFld031,cFld03t1,{"","","",""})
	(cAlB03Rs)->(dbGoTop())
Return
// FIM Chamado n.050629 - OS n. - Relatorio Abertura GIA - Abel Babini - 28/10/2019


/*/{Protheus.doc} Static Function ExForCel
	Formata Células do Exce/l
	@type  Static Function
	@author Abel Babini Filho
	@since 11/02/2020
	@version version
	/*/
Static Function ExForCel(cFormato)
	DEFAULT cFormato := ''
	//Formatos possíveis
	//TIT - Título
	//SUB - SubTotal
	//TOT - Total
	//MAN - Valores Manuais
	FWMsExcelEx():SetFontSize(12)
	IF cFormato == 'TIT'
		oExcel:SetCelBold(.T.)
		oExcel:SetCelFont('Calibri')
		oExcel:SetCelItalic(.F.)
		oExcel:SetCelUnderLine(.F.)
		oExcel:SetCelSizeFont(14)
		oExcel:SetCelFrColor("#FFFFFF")
		oExcel:SetCelBgColor("#000000")
	ELSEIF cFormato == 'TOT'
		oExcel:SetCelBold(.T.)
		oExcel:SetCelFont('Calibri')
		oExcel:SetCelItalic(.F.)
		oExcel:SetCelUnderLine(.F.)
		oExcel:SetCelSizeFont(12)
		oExcel:SetCelFrColor("#FFFFFF")
		oExcel:SetCelBgColor("#070777")
	ELSEIF cFormato == 'MAN'
		oExcel:SetCelBold(.F.)
		oExcel:SetCelFont('Calibri')
		oExcel:SetCelItalic(.F.)
		oExcel:SetCelUnderLine(.F.)
		oExcel:SetCelSizeFont(10)
		oExcel:SetCelFrColor("#000000")
		oExcel:SetCelBgColor("#FFFF00")
	ELSEIF cFormato == 'SUB'
		oExcel:SetCelBold(.T.)
		oExcel:SetCelFont('Calibri')
		oExcel:SetCelItalic(.F.)
		oExcel:SetCelUnderLine(.F.)
		oExcel:SetCelSizeFont(10)
		oExcel:SetCelFrColor("#FFFFFF")
		oExcel:SetCelBgColor("#0000FF")	
	ELSE
		oExcel:SetCelFont('Calibri')
		oExcel:SetCelSizeFont(10)
		oExcel:SetCelBold(.F.)
		oExcel:SetCelItalic(.F.)
		oExcel:SetCelUnderLine(.F.)
		oExcel:SetCelFrColor("#000000")
		oExcel:SetCelBgColor("#FFFFFF")
	ENDIF
Return

/*/{Protheus.doc} Static Function xABrw20
	Gera Relatório Ref. NF CANCELADAS
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xABrw20
	If Select(cAlB20Br) > 0
		(cAlB20Br)->(dbCloseArea())
	Endif
	cAlB20Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T20NFCAN)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T20NFCAN)
	oAlB20D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB20Br, _aFields, _aIndex)

	If Select(cAlB20Dt) > 0
		(cAlB20Dt)->(dbCloseArea())
	Endif
	cAlB20Dt:=GetNextAlias()

	BeginSQL  Alias cAlB20Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		column DTCANC	as Date
		SELECT 
			SF3.F3_FILIAL		AS FILIAL, 
			SF3.F3_ENTRADA	AS DTENTRADA, 
			SF3.F3_EMISSAO	AS DTEMISSAO, 
			SF3.F3_SERIE 		AS NFSERIE, 
			SF3.F3_NFISCAL 	AS NFISCAL, 
			SF3.F3_CFO			AS CFOP, 
			SF3.F3_ESTADO 	AS UF, 
			SF3.F3_VALCONT	AS VALCONT, 
			SF3.F3_DTCANC		AS DTCANC,
			SF3.F3_OBSERV		AS OBSERV
		FROM 
			%TABLE:SF3% SF3 (NOLOCK)
		WHERE SF3.F3_FILIAL = %xFilial:SF3%
		AND SF3.F3_EMISSAO BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC <> ''
		AND SF3.%notDel%
	ENDSQL

	DbSelectArea(cAlB20Dt)
	(cAlB20Dt)->(DbGoTop())
	While !(cAlB20Dt)->(eof())

		RECLOCK(cAlB20Br,.T.)
			(cAlB20Br)->FILIAL 		:= (cAlB20Dt)->FILIAL
			(cAlB20Br)->DTENTRADA := (cAlB20Dt)->DTENTRADA
			(cAlB20Br)->DTEMISSAO := (cAlB20Dt)->DTEMISSAO
			(cAlB20Br)->NFSERIE 	:= (cAlB20Dt)->NFSERIE
			(cAlB20Br)->NFISCAL 	:= (cAlB20Dt)->NFISCAL
			(cAlB20Br)->CFOP 			:= (cAlB20Dt)->CFOP
			(cAlB20Br)->UF 				:= (cAlB20Dt)->UF
			(cAlB20Br)->VALCONT 	:= (cAlB20Dt)->VALCONT
			(cAlB20Br)->DTCANC 		:= (cAlB20Dt)->DTCANC
			(cAlB20Br)->OBSERV 		:= (cAlB20Dt)->OBSERV	
		MSUNLOCK()	
	
		(cAlB20Dt)->(DbSkip())
	EndDo

	(cAlB20Br)->(dbGoTop())
	(cAlB20Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr20
	Gera Relatório Ref. NF Canceladas
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xRelBr20()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de NF Canceladas" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr20b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr20b
	Gera Relatório Ref. NF Canceladas
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xRelBr20b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RNFCANCEL_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab20P1()
		GEx20P1()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab20P1
	Gera Relatório Ref. NF Canceladas
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab20P1()
	oExcel:AddworkSheet(cFld201)
	oExcel:AddTable(cFld201,cFld20t1)
	oExcel:AddColumn(cFld201,cFld20t1,"Filial",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Dt. Emissão",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Série",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"CFOP",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Estado",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld201,cFld20t1,"Dt. Cancel.",1,1)
	oExcel:AddColumn(cFld201,cFld20t1,"Observação",1,1)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx20P1  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx20P1()
	//
	(cAlB20Br)->(dbGoTop())
	While !(cAlB20Br)->(Eof())
		oExcel:AddRow(cFld201,cFld20t1,{(cAlB20Br)->FILIAL,;
																		(cAlB20Br)->DTENTRADA,;
																		(cAlB20Br)->DTEMISSAO,;
																		(cAlB20Br)->NFSERIE,;
																		(cAlB20Br)->NFISCAL,;
																		(cAlB20Br)->CFOP,;
																		(cAlB20Br)->UF,;
																		(cAlB20Br)->VALCONT,;
																		IIF(Alltrim(DTOS((cAlB20Br)->DTCANC))=="","",(cAlB20Br)->DTCANC),;
																		(cAlB20Br)->OBSERV})
		(cAlB20Br)->(dbSkip())
	ENDDO
	(cAlB20Br)->(dbGoTop())
	oExcel:AddRow(cFld201,cFld20t1,{"","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function xABrw28  
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xABrw28
	If Select(cAlB28Br) > 0
		(cAlB28Br)->(dbCloseArea())
	Endif
	cAlB28Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T28CIAP)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T28CIAP)
	oAlB28D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB28Br, _aFields, _aIndex) 

	If Select(cAlB28Dt) > 0
		(cAlB28Dt)->(dbCloseArea())
	Endif
	cAlB28Dt:=GetNextAlias()

	BeginSQL  Alias cAlB28Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		column DTCANC	as Date
		SELECT 
			SF3.F3_FILIAL		AS FILIAL, 
			SF3.F3_ENTRADA	AS DTENTRADA, 
			SF3.F3_EMISSAO	AS DTEMISSAO, 
			SF3.F3_SERIE 		AS NFSERIE, 
			SF3.F3_NFISCAL 	AS NFISCAL, 
			SF3.F3_CFO			AS CFOP, 
			SF3.F3_ESTADO 	AS UF, 
			SF3.F3_VALCONT	AS VALCONT, 
			SF3.F3_VALICM 	AS VALICMS,
			SF3.F3_DTCANC		AS DTCANC,
			SF3.F3_OBSERV		AS OBSERV
		FROM 
			%TABLE:SF3% SF3 (NOLOCK)
		WHERE SF3.F3_FILIAL = %xFilial:SF3%
		AND SF3.F3_EMISSAO BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.F3_CFO IN %Exp:_cCFCIAP% 
		AND SF3.%notDel%
	ENDSQL

	DbSelectArea(cAlB28Dt)
	(cAlB28Dt)->(DbGoTop())
	While !(cAlB28Dt)->(eof())

		RECLOCK(cAlB28Br,.T.)
			(cAlB28Br)->FILIAL 		:= (cAlB28Dt)->FILIAL
			(cAlB28Br)->DTENTRADA := (cAlB28Dt)->DTENTRADA
			(cAlB28Br)->DTEMISSAO := (cAlB28Dt)->DTEMISSAO
			(cAlB28Br)->NFSERIE 	:= (cAlB28Dt)->NFSERIE
			(cAlB28Br)->NFISCAL 	:= (cAlB28Dt)->NFISCAL
			(cAlB28Br)->CFOP 			:= (cAlB28Dt)->CFOP
			(cAlB28Br)->UF 				:= (cAlB28Dt)->UF
			(cAlB28Br)->VALCONT 	:= (cAlB28Dt)->VALCONT
			(cAlB28Br)->VALICMS 	:= (cAlB28Dt)->VALICMS
			(cAlB28Br)->OBSERV 		:= (cAlB28Dt)->OBSERV	
		MSUNLOCK()	
		nVCiap := nVCiap + (cAlB28Dt)->VALICMS
		(cAlB28Dt)->(DbSkip())
	EndDo

	(cAlB28Br)->(dbGoTop())
	(cAlB28Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr28
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xRelBr28()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio CIAP" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr28b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr28b
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xRelBr28b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RCIAP_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab28P1()
		GEx28P1()

		//Planilha1 - Detalhes
		Cab28P2()
		GEx28P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab28P1
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab28P1()
	oExcel:AddworkSheet(cFld281)
	oExcel:AddTable(cFld281,cFld28t1)
	oExcel:AddColumn(cFld281,cFld28t1,"Filial",1,1)
	oExcel:AddColumn(cFld281,cFld28t1,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx28P1  
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function GEx28P1()
	//
	oExcel:AddRow(cFld281,cFld28t1,{cFilAnt,nVCiap})
	oExcel:AddRow(cFld281,cFld28t1,{"",""})
Return

/*/{Protheus.doc} Static Function Cab28P2
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab28P2()
	oExcel:AddworkSheet(cFld282)
	oExcel:AddTable(cFld282,cFld28t2)
	oExcel:AddColumn(cFld282,cFld28t2,"Filial",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"Dt. Emissão",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"Série",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"CFOP",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"Estado",1,1)
	oExcel:AddColumn(cFld282,cFld28t2,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld282,cFld28t2,"Vl. ICMS",2,3,.t.)
	oExcel:AddColumn(cFld282,cFld28t2,"Observação",1,1)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx28P2
	Gera Relatório Ref. CIAP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function GEx28P2()
	//
	(cAlB28Br)->(dbGoTop())
	While !(cAlB28Br)->(Eof())
		oExcel:AddRow(cFld282,cFld28t2,{(cAlB28Br)->FILIAL,;
																		(cAlB28Br)->DTENTRADA,;
																		(cAlB28Br)->DTEMISSAO,;
																		(cAlB28Br)->NFSERIE,;
																		(cAlB28Br)->NFISCAL,;
																		(cAlB28Br)->CFOP,;
																		(cAlB28Br)->UF,;
																		(cAlB28Br)->VALCONT,;
																		(cAlB28Br)->VALICMS,;
																		(cAlB28Br)->OBSERV})
		(cAlB28Br)->(dbSkip())
	ENDDO
	(cAlB28Br)->(dbGoTop())
	oExcel:AddRow(cFld282,cFld28t2,{"","","","","","","","","",""})
Return

//INICIO Chamado n.055157 - OS n.056585 - Relatório Outras Entradas - Abel Babini - 28/01/2020
/*/{Protheus.doc} Static Function xABrw26
	Carrega da dados Ref. Outras Entradas
	@author Abel Babini Filho
	@since 02/09/2019
	@version 01
	/*/
Static Function xABrw26()
	Local cClass:=''
	Local _i

	//Cria array utilizado como legenda e como classificação na tabela temporária de Totais de Outras Saidas
	//Nao alterar a ordem de criação do array abaixo
	AAdd(aClassOE,"01- "+C11111)
	AAdd(aClassOE,"02- "+C11112)
	AAdd(aClassOE,"03- "+C11113)
	AAdd(aClassOE,"04- "+C11114)
	AAdd(aClassOE,"05- "+C11115)
	AAdd(aClassOE,"06- "+C11116)
	AAdd(aClassOE,"07- "+C11117)
	AAdd(aClassOE,"08- "+C11118)
	AAdd(aClassOE,"09- "+C11119)
	AAdd(aClassOE,"10- "+C11120)
	AAdd(aClassOE,"11- "+C11121)
	AAdd(aClassOE,"12- "+C11122)
	AAdd(aClassOE,"13- "+C11123)
	AAdd(aClassOE,"14- "+C11124)

	If Select(cAlB26Dt) > 0
		(cAlB26Dt)->(dbCloseArea())
	Endif
	cAlB26Dt:=GetNextAlias()

	nA26T001 := 0
	nA26T002 := 0
	nA26T003 := 0
		
	nA26T021 := 0
	nA26T022 := 0
	nA26T023 := 0

	nA26T031 := 0
	nA26T032 := 0
	nA26T033 := 0

	nA26T041 := 0
	nA26T042 := 0
	nA26T043 := 0

	nA26T051 := 0
	nA26T052 := 0
	nA26T053 := 0

	nA26T061 := 0
	nA26T062 := 0
	nA26T063 := 0

	nA26T071 := 0
	nA26T072 := 0
	nA26T073 := 0

	nA26T081 := 0
	nA26T082 := 0
	nA26T083 := 0

	nA26T091 := 0
	nA26T092 := 0
	nA26T093 := 0

	nA26T101 := 0
	nA26T102 := 0
	nA26T103 := 0

	nA26T111 := 0
	nA26T112 := 0
	nA26T113 := 0

	nA26T121 := 0
	nA26T122 := 0
	nA26T123 := 0

	nA26T131 := 0
	nA26T132 := 0
	nA26T133 := 0

	nA26T141 := 0
	nA26T142 := 0
	nA26T143 := 0

	nA26T151 := 0
	nA26T152 := 0
	nA26T153 := 0


	BeginSQL  Alias cAlB26Dt
		column DTENTRADA as Date
		column DTENTRADAORI as Date
		column DTCANC	as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL, 
			SFT.FT_ENTRADA		AS DTENTRADA, 
			SFT.FT_SERIE		AS SERIE,
			SFT.FT_NFISCAL		AS NFISCAL, 
			SFT.FT_ITEM			AS ITEM,
			SFT.FT_CLIEFOR		AS CLIEFOR, 
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CGC,
			SFT.FT_PRODUTO		AS CODPROD, 
			SB1.B1_DESC			AS PRODUTO,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT		AS PRCUNIT,
			SFT.FT_TOTAL		AS TOTAL,
			SFT.FT_VALCONT		AS VALCONT,
			SFT.FT_BASEICM		AS ICMSBASE,
			SFT.FT_ALIQICM		AS ICMSALIQ,
			SFT.FT_VALICM		AS ICMSVAL,
			SFT.FT_ICMSRET		AS ICMSRET,
			SFT.FT_OUTRICM		AS ICMSOUTR,
			SFT.FT_DESCONT		AS DESCONT,
			SFT.FT_SEGURO		AS SEGURO,
			SFT.FT_DESPESA		AS DESPESA,
			SFT.FT_FRETE		AS FRETE,
			SFT.FT_VALPIS		AS VALPIS,
			SFT.FT_VALCOF		AS VALCOF,
			SFT.FT_DTCANC		AS DTCANC,
			SFT.FT_OBSERV		AS OBSERV,
			SFT.FT_CONTA		AS CONTACONT,
			SFT.FT_TES			AS TES, 
			SFT.FT_CFOP			AS CFOP, 
			SFT.FT_TIPOMOV		AS TIPOMOV,
			SFT.FT_TIPO			AS TIPO,
			SFT.FT_NFORI		AS NFORI,
			SFT.FT_SERORI		AS SERORI,
			SFT.FT_ITEMORI		AS ITEMORI,
			SFT.FT_ESPECIE		AS ESPECIE,
			SF4.F4_ICM			AS CALCICMS,
			CASE WHEN SF4.F4_CREDICM = 'S' THEN 'SIM' ELSE 'NAO' END AS CREDICMS,
			SF4.F4_PISCOF		AS CALCPIS,
			CASE WHEN SF4.F4_PISCOF = '3' AND SF4.F4_PISCRED IN ('1','2') THEN 'SIM' ELSE 'NAO' END AS CREDPIS
		FROM %TABLE:SFT% SFT (NOLOCK)
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.%notDel%
		AND SB1.B1_COD = SFT.FT_PRODUTO
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.%notDel%
		AND SA2.A2_COD = SFT.FT_CLIEFOR
		AND SA2.A2_LOJA = SFT.FT_LOJA
		AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.%notDel%
		AND SA1.A1_COD = SFT.FT_CLIEFOR
		AND SA1.A1_LOJA = SFT.FT_LOJA
		AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
		LEFT JOIN %TABLE:SF4% SF4 (NOLOCK) ON
			SF4.%notDel%
		AND SF4.F4_CODIGO = SFT.FT_TES
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
		AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SFT.FT_CFOP IN ('1949','2949','3949')
		AND SFT.FT_DTCANC = ''
		AND SF4.F4_CREDICM = 'S'
		AND SFT.%notDel%
	EndSQL

	//Tabela Detalhe a Classificar - Completa
	If Select(cAlB26Z1) > 0
		(cAlB26Z1)->(dbCloseArea())
	Endif
	cAlB26Z1:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R, CriaExtr, T26OUT01)
	_aIndex		:= StaticCall(ADFIS028R, CriaInd, T26OUT01)
	oAlB26D1	:= StaticCall(ADFIS028R, CriaTmpT, cAlB26Z1, _aFields, _aIndex)

	//Tabela Cesta Basiica
	If Select(cAlB26Z2) > 0
		(cAlB26Z2)->(dbCloseArea())
	Endif
	cAlB26Z2:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R, CriaExtr, T26OUT02)
	_aIndex		:= StaticCall(ADFIS028R, CriaInd, T26OUT02)
	oAlB26D2	:= StaticCall(ADFIS028R, CriaTmpT, cAlB26Z2, _aFields, _aIndex)

	DbSelectArea(cAlB26Dt)
	(cAlB26Dt)->(DbGoTop())
	While !(cAlB26Dt)->(eof())
		cClass	:= xRecCl26((cAlB26Dt)->FILIAL+(cAlB26Dt)->CLIEFOR+(cAlB26Dt)->LOJA+DTOS((cAlB26Dt)->DTENTRADA)+(cAlB26Dt)->SERIE+(cAlB26Dt)->NFISCAL+(cAlB26Dt)->ITEM)//' 8'
		If Alltrim(cClass) == ''
			If  Alltrim((cAlB26Dt)->CLIEFOR) $ Alltrim(_cMVOEFC)
				cClass:=' 1'
				nA26T021 += (cAlB26Dt)->VALCONT
				nA26T022 += (cAlB26Dt)->ICMSVAL
				nA26T023 += (cAlB26Dt)->QUANT
			Else
				cClass:='14'
				nA26T151 += (cAlB26Dt)->VALCONT
				nA26T152 += (cAlB26Dt)->ICMSVAL
				nA26T153 += (cAlB26Dt)->QUANT
			Endif
		ELSE
			If cClass ==' 1'
				nA26T021 += (cAlB26Dt)->VALCONT
				nA26T022 += (cAlB26Dt)->ICMSVAL
				nA26T023 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 2'
				nA26T031 += (cAlB26Dt)->VALCONT
				nA26T032 += (cAlB26Dt)->ICMSVAL
				nA26T033 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 3'
				nA26T041 += (cAlB26Dt)->VALCONT
				nA26T042 += (cAlB26Dt)->ICMSVAL
				nA26T043 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 4'
				nA26T051 += (cAlB26Dt)->VALCONT
				nA26T052 += (cAlB26Dt)->ICMSVAL
				nA26T053 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 5'
				nA26T061 += (cAlB26Dt)->VALCONT
				nA26T062 += (cAlB26Dt)->ICMSVAL
				nA26T063 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 6'
				nA26T071 += (cAlB26Dt)->VALCONT
				nA26T072 += (cAlB26Dt)->ICMSVAL
				nA26T073 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 7'
				nA26T081 += (cAlB26Dt)->VALCONT
				nA26T082 += (cAlB26Dt)->ICMSVAL
				nA26T083 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 8'
				nA26T091 += (cAlB26Dt)->VALCONT
				nA26T092 += (cAlB26Dt)->ICMSVAL
				nA26T093 += (cAlB26Dt)->QUANT
			ElseIf  cClass ==' 9'
				nA26T101 += (cAlB26Dt)->VALCONT
				nA26T102 += (cAlB26Dt)->ICMSVAL
				nA26T103 += (cAlB26Dt)->QUANT
			ElseIf  cClass =='10'
				nA26T111 += (cAlB26Dt)->VALCONT
				nA26T112 += (cAlB26Dt)->ICMSVAL
				nA26T113 += (cAlB26Dt)->QUANT
			ElseIf  cClass =='11'
				nA26T121 += (cAlB26Dt)->VALCONT
				nA26T122 += (cAlB26Dt)->ICMSVAL
				nA26T123 += (cAlB26Dt)->QUANT
			ElseIf  cClass =='12'
				nA26T131 += (cAlB26Dt)->VALCONT
				nA26T132 += (cAlB26Dt)->ICMSVAL
				nA26T133 += (cAlB26Dt)->QUANT
			ElseIf  cClass =='13'
				nA26T141 += (cAlB26Dt)->VALCONT
				nA26T142 += (cAlB26Dt)->ICMSVAL
				nA26T143 += (cAlB26Dt)->QUANT
			Else
				nA26T151 += (cAlB26Dt)->VALCONT
				nA26T152 += (cAlB26Dt)->ICMSVAL
				nA26T153 += (cAlB26Dt)->QUANT
			Endif
			
		Endif
		//TOTAIS
		nA26T001 += (cAlB26Dt)->VALCONT
		nA26T002 += (cAlB26Dt)->ICMSVAL
		nA26T003 += (cAlB26Dt)->QUANT

		RECLOCK(cAlB26Z1,.T.)
			(cAlB26Z1)->CLASSIF 	:= cClass
			(cAlB26Z1)->FILIAL 		:= (cAlB26Dt)->FILIAL
			(cAlB26Z1)->DTENTRADA := (cAlB26Dt)->DTENTRADA
			(cAlB26Z1)->NFSERIE 	:= (cAlB26Dt)->SERIE
			(cAlB26Z1)->NF 				:= (cAlB26Dt)->NFISCAL
			(cAlB26Z1)->NFITEM 		:= (cAlB26Dt)->ITEM
			(cAlB26Z1)->CLIEFOR 	:= (cAlB26Dt)->CLIEFOR
			(cAlB26Z1)->LOJA 			:= (cAlB26Dt)->LOJA
			(cAlB26Z1)->NOME 			:= (cAlB26Dt)->NOME
			(cAlB26Z1)->CNPJ 			:= (cAlB26Dt)->CGC
			(cAlB26Z1)->CODPROD 	:= (cAlB26Dt)->CODPROD
			(cAlB26Z1)->DESCPROD	:= (cAlB26Dt)->PRODUTO
			(cAlB26Z1)->CFOP 			:= (cAlB26Dt)->CFOP
			(cAlB26Z1)->QUANT			:= (cAlB26Dt)->QUANT
			(cAlB26Z1)->PRCUNIT 	:= (cAlB26Dt)->PRCUNIT
			(cAlB26Z1)->TOTAL			:= (cAlB26Dt)->TOTAL
			(cAlB26Z1)->VLCONT 		:= (cAlB26Dt)->VALCONT
			(cAlB26Z1)->ICMSBASE	:= (cAlB26Dt)->ICMSBASE
			(cAlB26Z1)->ICMSALIQ	:= (cAlB26Dt)->ICMSALIQ
			(cAlB26Z1)->ICMSVAL		:= (cAlB26Dt)->ICMSVAL
			(cAlB26Z1)->ICMSRET		:= (cAlB26Dt)->ICMSRET
			(cAlB26Z1)->ICMSOUTR	:= (cAlB26Dt)->ICMSOUTR
			(cAlB26Z1)->DESCONT		:= (cAlB26Dt)->DESCONT
			(cAlB26Z1)->SEGURO		:= (cAlB26Dt)->SEGURO
			(cAlB26Z1)->DESPESA		:= (cAlB26Dt)->DESPESA
			(cAlB26Z1)->FRETE			:= (cAlB26Dt)->FRETE
			(cAlB26Z1)->DTCANC		:= (cAlB26Dt)->DTCANC
			(cAlB26Z1)->OBSERV		:= (cAlB26Dt)->OBSERV
			(cAlB26Z1)->CONTACONT	:= (cAlB26Dt)->CONTACONT
			(cAlB26Z1)->TES				:= (cAlB26Dt)->TES
			(cAlB26Z1)->TIPOMOV		:= (cAlB26Dt)->TIPOMOV
			(cAlB26Z1)->TIPO			:= (cAlB26Dt)->TIPO
			(cAlB26Z1)->ESPECIE		:= (cAlB26Dt)->ESPECIE
			(cAlB26Z1)->CALCICMS	:= (cAlB26Dt)->CALCICMS
			(cAlB26Z1)->CREDICMS	:= (cAlB26Dt)->CREDICMS
			(cAlB26Z1)->CALCPIS		:= (cAlB26Dt)->CALCPIS
			(cAlB26Z1)->CREDPIS		:= (cAlB26Dt)->CREDPIS
			(cAlB26Z1)->VALPIS		:= (cAlB26Dt)->VALPIS
			(cAlB26Z1)->VALCOF		:= (cAlB26Dt)->VALCOF
		MSUNLOCK()	
	
		(cAlB26Dt)->(DbSkip())
	EndDo
	For _i:=1 to 15
		RECLOCK(cAlB26Z2,.T.)
			(cAlB26Z2)->FILIAL := xFilial('SFT')
			IF _i < 15
				(cAlB26Z2)->CLASSIF := aClassif[_i]
				(cAlB26Z2)->QUANT := &('nA26T'+StrZero(_i+1,2)+'3')
				(cAlB26Z2)->VLCONT := &('nA26T'+StrZero(_i+1,2)+'1')
				(cAlB26Z2)->ICMSVAL := &('nA26T'+StrZero(_i+1,2)+'2')
			ELSE
				(cAlB26Z2)->CLASSIF := "TOTAL"
				(cAlB26Z2)->QUANT := nA26T003
				(cAlB26Z2)->VLCONT := nA26T001
				(cAlB26Z2)->ICMSVAL := nA26T002
			ENDIF
		MSUNLOCK()
	Next _i
	(cAlB26Z2)->(dbGoTop())
	(cAlB26Dt)->(dbCloseArea())	
	
	IF nOpMdl	== 1
		MsgRun( "Atualizando dados - Demonstrativo, aguarde...",,{ || StaticCall(ADFIS028R, xABrw05) } ) //DEMONSTRATIVO
	ELSEIF nOpMdl	== 2 .or. nOpMdl	== 4
		MsgRun( "Atualizando dados - Abertura GIA, aguarde...",,{ || StaticCall(ADFIS038R,xABrw27) } ) //DEMONSTRATIVO
	ENDIF

	SysRefresh()
Return

/*/{Protheus.doc} Static Function xBr26Clf  
	Aplica classificação dos itens do Rel. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function xBr26Clf(nClassOE)
	Local cMarca
	Local _i

	nA26T001 := 0
	nA26T002 := 0
	nA26T003 := 0
		
	nA26T021 := 0
	nA26T022 := 0
	nA26T023 := 0

	nA26T031 := 0
	nA26T032 := 0
	nA26T033 := 0

	nA26T041 := 0
	nA26T042 := 0
	nA26T043 := 0

	nA26T051 := 0
	nA26T052 := 0
	nA26T053 := 0

	nA26T061 := 0
	nA26T062 := 0
	nA26T063 := 0

	nA26T071 := 0
	nA26T072 := 0
	nA26T073 := 0

	nA26T081 := 0
	nA26T082 := 0
	nA26T083 := 0

	nA26T091 := 0
	nA26T092 := 0
	nA26T093 := 0

	nA26T101 := 0
	nA26T102 := 0
	nA26T103 := 0

	nA26T111 := 0
	nA26T112 := 0
	nA26T113 := 0

	nA26T121 := 0
	nA26T122 := 0
	nA26T123 := 0

	nA26T131 := 0
	nA26T132 := 0
	nA26T133 := 0

	nA26T141 := 0
	nA26T142 := 0
	nA26T143 := 0

	dbSelectArea(cAlB26Z1)
	(cAlB26Z1)->( dbGoTop() )
	ProcRegua((cAlB26Z1)->(RecCount()))
	(cAlB26Z1)->( dbGoTop() )
	cMarca := oBrw26Dt:Mark()

	While !(cAlB26Z1)->(Eof())
		IncProc()	
		
		IF oBrw26Dt:IsMark(cMarca)
			RECLOCK(cAlB26Z1,.F.)
				(cAlB26Z1)->CLASSIF 	:= PadL(nClassOE,2)
				(cAlB26Z1)->OMARK			:= ''
			MSUNLOCK()	
		ENDIF

		//REFAZ OS TOTAIS
		If  (cAlB26Z1)->CLASSIF == ' 1'
			nA26T021 += (cAlB26Z1)->VLCONT
			nA26T022 += (cAlB26Z1)->ICMSVAL
			nA26T023 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 2'
			nA26T031 += (cAlB26Z1)->VLCONT
			nA26T032 += (cAlB26Z1)->ICMSVAL
			nA26T033 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 3'
			nA26T041 += (cAlB26Z1)->VLCONT
			nA26T042 += (cAlB26Z1)->ICMSVAL
			nA26T043 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 4'
			nA26T051 += (cAlB26Z1)->VLCONT
			nA26T052 += (cAlB26Z1)->ICMSVAL
			nA26T053 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 5'
			nA26T061 += (cAlB26Z1)->VLCONT
			nA26T062 += (cAlB26Z1)->ICMSVAL
			nA26T063 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 6'
			nA26T071 += (cAlB26Z1)->VLCONT
			nA26T072 += (cAlB26Z1)->ICMSVAL
			nA26T073 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 7'
			nA26T081 += (cAlB26Z1)->VLCONT
			nA26T082 += (cAlB26Z1)->ICMSVAL
			nA26T083 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 8'
			nA26T091 += (cAlB26Z1)->VLCONT
			nA26T092 += (cAlB26Z1)->ICMSVAL
			nA26T093 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == ' 9'
			nA26T101 += (cAlB26Z1)->VLCONT
			nA26T102 += (cAlB26Z1)->ICMSVAL
			nA26T103 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == '10'
			nA26T111 += (cAlB26Z1)->VLCONT
			nA26T112 += (cAlB26Z1)->ICMSVAL
			nA26T113 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == '11'
			nA26T121 += (cAlB26Z1)->VLCONT
			nA26T122 += (cAlB26Z1)->ICMSVAL
			nA26T123 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == '12'
			nA26T131 += (cAlB26Z1)->VLCONT
			nA26T132 += (cAlB26Z1)->ICMSVAL
			nA26T133 += (cAlB26Z1)->QUANT
		ElseIf  (cAlB26Z1)->CLASSIF == '13'
			nA26T141 += (cAlB26Z1)->VLCONT
			nA26T142 += (cAlB26Z1)->ICMSVAL
			nA26T143 += (cAlB26Z1)->QUANT
		Else
			nA26T151 += (cAlB26Z1)->VLCONT
			nA26T152 += (cAlB26Z1)->ICMSVAL
			nA26T153 += (cAlB26Z1)->QUANT
		Endif
		//TOTAIS
		nA26T001 += (cAlB26Z1)->VLCONT
		nA26T002 += (cAlB26Z1)->ICMSVAL
		nA26T003 += (cAlB26Z1)->QUANT

		(cAlB26Z1)->( dbSkip() )
	EndDo

	(cAlB26Z2)->(dbGoTop())
	While !(cAlB26Z2)->(Eof())
		RECLOCK(cAlB26Z2,.F.)
		(cAlB26Z2)->(dbDelete())
		MSUNLOCK()
		(cAlB26Z2)->(dbSkip())
	ENDDO
	For _i:=1 to 15
		RECLOCK(cAlB26Z2,.T.)
			(cAlB26Z2)->FILIAL := xFilial('SFT')
			IF _i < 15
				(cAlB26Z2)->CLASSIF := aClassOE[_i]
				(cAlB26Z2)->QUANT := &('nA26T'+StrZero(_i+1,2)+'3')
				(cAlB26Z2)->VLCONT := &('nA26T'+StrZero(_i+1,2)+'1')
				(cAlB26Z2)->ICMSVAL := &('nA26T'+StrZero(_i+1,2)+'2')
			ELSE
				(cAlB26Z2)->CLASSIF := "TOTAL"
				(cAlB26Z2)->QUANT := nA26T003
				(cAlB26Z2)->VLCONT := nA26T001
				(cAlB26Z2)->ICMSVAL := nA26T002
			ENDIF
		MSUNLOCK()
	Next _i
	(cAlB26Z2)->(dbGoTop())
	(cAlB26Z1)->(dbGoTop())
	oBrw26Dt:Refresh(.T.)
	oBrw26Z2:Refresh(.T.)
Return

/*/{Protheus.doc} Static Function xRecCl26
	Recupera classificação de Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
/*/
Static Function xRecCl26(cKeyDoc)
	Local cVerAnt	:= StaticCall(ADFIS028R, xRecVer, '26')
	Local cClass	:= ''
	Local cQuery	:= GetNextAlias()
	Local cTabSZU	:= C11110
	IF Alltrim(cVerAnt) <> ''
		BeginSQL  Alias cQuery
			SELECT
				ZFU.ZFU_STSDOC			AS CLASSIF
			FROM %TABLE:ZFU% ZFU (NOLOCK)
			WHERE
					ZFU.ZFU_FILIAL = %xFilial:ZFU%
			AND ZFU.ZFU_PERIOD = %Exp:_cAnoI+_cMesI%
			AND ZFU.ZFU_STATUS <> '3'
			AND ZFU.ZFU_TABELA	= '26'
			AND ZFU.ZFU_CHAVE	= %Exp:cTabSZU%
			AND ZFU.ZFU_KEYDOC = %Exp:cKeyDoc%
			AND ZFU.ZFU_VERSAO = %Exp:cVerAnt%
			AND ZFU.%notDel%
		EndSQL
		cClass := PadL((cQuery)->CLASSIF,2)
		(cQuery)->(dbCloseArea())
	ENDIF
Return cClass

/*/{Protheus.doc} Static Function xGrvCl26
	Grava classificação de Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
/*/
Static Function xGrvCl26(cNewVers)
	Local cVerAnt := StrZero(Val(cNewVers)-1,3)
	//Grava uma nova versão
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(eof())
		RECLOCK('ZFU',.T.)
			ZFU->ZFU_FILIAL	:= xFilial()
			ZFU->ZFU_PERIOD	:= _cAnoI+_cMesI
			ZFU->ZFU_VERSAO	:= cNewVers
			ZFU->ZFU_DTGRV	:= dDATABASE
			ZFU->ZFU_TABELA	:= '26'
			ZFU->ZFU_CHAVE	:= C11110
			ZFU->ZFU_USUARI	:= _cNomUse
			ZFU->ZFU_STATUS	:= '1' //1-Aberto | 2-Fechado e Exportado | 3-Cancelado
			ZFU->ZFU_KEYDOC	:= (cAlB26Z1)->FILIAL+(cAlB26Z1)->CLIEFOR+(cAlB26Z1)->LOJA+DTOS((cAlB26Z1)->DTENTRADA)+(cAlB26Z1)->NFSERIE+(cAlB26Z1)->NF+(cAlB26Z1)->NFITEM
			ZFU->ZFU_STSDOC	:= PadL((cAlB26Z1)->CLASSIF,2)
		MSUNLOCK()
		(cAlB26Z1)->(dbSkip())
	EndDo
	//Altera o status da última versão

	IF cNewVers <> '001' .AND. ZFU->(dbSeek(xFilial()+_cAnoI+_cMesI+cVerAnt))
	
		While !ZFU->(eof()) .AND. ;
					ZFU->ZFU_FILIAL == xFilial() .AND. ;
					ZFU->ZFU_PERIOD == _cAnoI+_cMesI .AND. ;
					ZFU->ZFU_VERSAO == cVerAnt
			
			IncProc()
			RECLOCK('ZFU',.F.)
				ZFU->ZFU_STATUS	:= '3' //1-Aberto | 2-Fechado e Exportado | 3-Cancelado
			MSUNLOCK()
			ZFU->(dbSkip())

		EndDo
	ENDIF

Return

/*/{Protheus.doc} Static Function xVrfGr26
	Verifica se precisa gravar nova versão da tabela 26 - Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
/*/
Static Function xVrfGr26
	Local lGrvZFU := .F.
	Local cClass := ''
	Local cVerAnt := Alltrim(StaticCall(ADFIS028R, xRecVer, '26'))
	oBrw26Dt:CleanFilter()
	(cAlB26Z1)->(dbGoTop())

	While !(cAlB26Z1)->(eof())
		cClass := xRecCl26((cAlB26Z1)->FILIAL+(cAlB26Z1)->CLIEFOR+(cAlB26Z1)->LOJA+DTOS((cAlB26Z1)->DTENTRADA)+(cAlB26Z1)->NFSERIE+(cAlB26Z1)->NF+(cAlB26Z1)->NFITEM)
		IF (cAlB26Z1)->CLASSIF != PadL(cClass,2)
			lGrvZFU	:= .T.
			exit
		ENDIF
		(cAlB26Z1)->(dbSkip())
	EndDo
	(cAlB26Z1)->(dbGoTop())

	IF lGrvZFU
		IF cVerAnt = ''
			xGrvCl26('001')
		ELSE
			xGrvCl26(StrZero(Val(cVerAnt)+1,3))
		ENDIF
	ENDIF
	(cAlB26Z1)->(dbGoTop())
Return

/*/{Protheus.doc} Static Function xRelBr26
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function xRelBr26()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Outras Entradas" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr26b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr26b
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function xRelBr26b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	//Limpa Filtros aplicados
	oBrw26Dt:CleanFilter()

	//Verifica se houve alteração na classificação e grava versão antes de gerar relatorio.
	xVrfGr26()

	cArquivo := cPathRel +  'ROUTENTRADAS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab26P1()
		GEx26P1()
        
		//Planilha2 - Detalhamento
		Cab26P2()
		GEx26P2()

		//Planilha2 - Cesta Basica
		Cab26P3()
		GEx26P3()

		Cab26P4()
		GEx26P4()

		Cab26P5()
		GEx26P5()

		Cab26P6()
		GEx26P6()

		Cab26P7()
		GEx26P7()

		Cab26P8()
		GEx26P8()
			
		Cab26P9()
		GEx26P9()

		Cab26P0()
		GEx26P0()

		Cab26PA()
		GEx26PA()

		Cab26PB()
		GEx26PB()

		Cab26PC()
		GEx26PC()

		Cab26PD()
		GEx26PD()

		Cab26PE()
		GEx26PE()

		Cab26PZ()
		GEx26PZ()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab26P1  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P1()
	oExcel:AddworkSheet(cFld261)
	oExcel:AddTable(cFld261,cFld26t1)
	oExcel:AddColumn(cFld261,cFld26t1,"Filial",1,1)
	oExcel:AddColumn(cFld261,cFld26t1,"Classificação",1,1)
	oExcel:AddColumn(cFld261,cFld26t1,"Quant.",2,2)
	oExcel:AddColumn(cFld261,cFld26t1,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld261,cFld26t1,"Vl. ICMS",2,3)
	//oExcel:AddRow(cFld261,cFld26t1,{ "", "","" ,"" ,"" })
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx26P1  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P1()
	//
	(cAlB26Z2)->(dbGoTop())
	While !(cAlB26Z2)->(Eof())
		oExcel:AddRow(cFld261,cFld26t1,{(cAlB26Z2)->FILIAL,;
																		(cAlB26Z2)->CLASSIF,;
																		(cAlB26Z2)->QUANT,;
																		(cAlB26Z2)->VLCONT,;
																		(cAlB26Z2)->ICMSVAL})

		(cAlB26Z2)->(dbSkip())
	ENDDO
Return

/*/{Protheus.doc} Static Function Cab26P2  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P2()
	oExcel:AddworkSheet(cFld262)
	oExcel:AddTable(cFld262,cFld26t2)
	oExcel:AddColumn(cFld262,cFld26t2,"Classif.",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Filial",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Série",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Item NF",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Forn.",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Loja",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"CNPJ",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Produto",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"CFOP",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Quant",2,2)
	oExcel:AddColumn(cFld262,cFld26t2,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Vl.Total",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Base ICMS",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Desconto",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Seguro",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Despesas",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Frete",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Observações",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"TES",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Espécie",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld262,cFld26t2,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Vl Pis",2,3)
	oExcel:AddColumn(cFld262,cFld26t2,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P3  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P3()
	oExcel:AddworkSheet(cFld263)
	oExcel:AddTable(cFld263,cFld26t3)
	oExcel:AddColumn(cFld263,cFld26t3,"Classif.",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Filial",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Série",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Item NF",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Forn.",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Loja",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"CNPJ",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Produto",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"CFOP",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Quant",2,2)
	oExcel:AddColumn(cFld263,cFld26t3,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Vl.Total",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Base ICMS",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Desconto",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Seguro",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Despesas",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Frete",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Observações",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"TES",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Espécie",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld263,cFld26t3,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Vl Pis",2,3)
	oExcel:AddColumn(cFld263,cFld26t3,"Vl Cofins",2,3)
	
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P4  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P4()
  oExcel:AddworkSheet(cFld264)
  oExcel:AddTable(cFld264,cFld26t4)
	oExcel:AddColumn(cFld264,cFld26t4,"Classif.",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Filial",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Série",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Item NF",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Forn.",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Loja",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"CNPJ",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Produto",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"CFOP",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Quant",2,2)
	oExcel:AddColumn(cFld264,cFld26t4,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Vl.Total",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Base ICMS",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Desconto",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Seguro",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Despesas",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Frete",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Observações",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"TES",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Espécie",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld264,cFld26t4,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Vl Pis",2,3)
	oExcel:AddColumn(cFld264,cFld26t4,"Vl Cofins",2,3)
	RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P5  
	Gera Relatório Ref. Outras Entradas 
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P5()
	oExcel:AddworkSheet(cFld265)
	oExcel:AddTable(cFld265,cFld26t5)
	oExcel:AddColumn(cFld265,cFld26t5,"Classif.",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Filial",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Série",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Item NF",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Forn.",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Loja",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"CNPJ",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Produto",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"CFOP",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Quant",2,2)
	oExcel:AddColumn(cFld265,cFld26t5,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Vl.Total",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Base ICMS",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Desconto",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Seguro",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Despesas",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Frete",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Observações",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"TES",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Espécie",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld265,cFld26t5,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Vl Pis",2,3)
	oExcel:AddColumn(cFld265,cFld26t5,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P6  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P6()
	oExcel:AddworkSheet(cFld266)
	oExcel:AddTable(cFld266,cFld26t6)
	oExcel:AddColumn(cFld266,cFld26t6,"Classif.",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Filial",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Série",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Item NF",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Forn.",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Loja",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"CNPJ",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Produto",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"CFOP",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Quant",2,2)
	oExcel:AddColumn(cFld266,cFld26t6,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Vl.Total",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Base ICMS",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Desconto",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Seguro",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Despesas",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Frete",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Observações",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"TES",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Espécie",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld266,cFld26t6,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Vl Pis",2,3)
	oExcel:AddColumn(cFld266,cFld26t6,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P7  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P7()
	oExcel:AddworkSheet(cFld267)
	oExcel:AddTable(cFld267,cFld26t7)
	oExcel:AddColumn(cFld267,cFld26t7,"Classif.",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Filial",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Série",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Item NF",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Forn.",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Loja",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"CNPJ",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Produto",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"CFOP",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Quant",2,2)
	oExcel:AddColumn(cFld267,cFld26t7,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Vl.Total",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Base ICMS",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Desconto",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Seguro",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Despesas",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Frete",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Observações",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"TES",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Espécie",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld267,cFld26t7,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Vl Pis",2,3)
	oExcel:AddColumn(cFld267,cFld26t7,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P8  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P8()
	oExcel:AddworkSheet(cFld268)
	oExcel:AddTable(cFld268,cFld26t8)
	oExcel:AddColumn(cFld268,cFld26t8,"Classif.",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Filial",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Série",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Item NF",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Forn.",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Loja",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"CNPJ",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Produto",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"CFOP",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Quant",2,2)
	oExcel:AddColumn(cFld268,cFld26t8,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Vl.Total",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Base ICMS",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Desconto",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Seguro",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Despesas",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Frete",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Observações",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"TES",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Espécie",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld268,cFld26t8,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Vl Pis",2,3)
	oExcel:AddColumn(cFld268,cFld26t8,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P9  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P9()
	oExcel:AddworkSheet(cFld269)
	oExcel:AddTable(cFld269,cFld26t9)
	oExcel:AddColumn(cFld269,cFld26t9,"Classif.",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Filial",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Série",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Item NF",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Forn.",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Loja",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"CNPJ",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Produto",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"CFOP",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Quant",2,2)
	oExcel:AddColumn(cFld269,cFld26t9,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Vl.Total",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Base ICMS",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Desconto",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Seguro",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Despesas",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Frete",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Observações",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"TES",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Espécie",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld269,cFld26t9,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Vl Pis",2,3)
	oExcel:AddColumn(cFld269,cFld26t9,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P0
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26P0()
	oExcel:AddworkSheet(cFld260)
	oExcel:AddTable(cFld260,cFld26t0)
	oExcel:AddColumn(cFld260,cFld26t0,"Classif.",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Filial",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Série",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Item NF",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Forn.",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Loja",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"CNPJ",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Produto",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"CFOP",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Quant",2,2)
	oExcel:AddColumn(cFld260,cFld26t0,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Vl.Total",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Base ICMS",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Desconto",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Seguro",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Despesas",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Frete",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Observações",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"TES",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Espécie",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld260,cFld26t0,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Vl Pis",2,3)
	oExcel:AddColumn(cFld260,cFld26t0,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26PA
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26PA()
	oExcel:AddworkSheet(cFld26A)
	oExcel:AddTable(cFld26A,cFld26tA)
	oExcel:AddColumn(cFld26A,cFld26tA,"Classif.",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Filial",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Série",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Item NF",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Forn.",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Loja",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"CNPJ",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Produto",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"CFOP",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Quant",2,2)
	oExcel:AddColumn(cFld26A,cFld26tA,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Vl.Total",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Base ICMS",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Desconto",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Seguro",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Despesas",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Frete",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Observações",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"TES",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Espécie",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld26A,cFld26tA,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Vl Pis",2,3)
	oExcel:AddColumn(cFld26A,cFld26tA,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26PB
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26PB()
	oExcel:AddworkSheet(cFld26B)
	oExcel:AddTable(cFld26B,cFld26tB)
	oExcel:AddColumn(cFld26B,cFld26tB,"Classif.",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Filial",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Série",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Item NF",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Forn.",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Loja",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"CNPJ",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Produto",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"CFOP",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Quant",2,2)
	oExcel:AddColumn(cFld26B,cFld26tB,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Vl.Total",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Base ICMS",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Desconto",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Seguro",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Despesas",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Frete",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Observações",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"TES",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Espécie",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld26B,cFld26tB,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Vl Pis",2,3)
	oExcel:AddColumn(cFld26B,cFld26tB,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26PC
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26PC()
	oExcel:AddworkSheet(cFld26C)
	oExcel:AddTable(cFld26C,cFld26tC)
	oExcel:AddColumn(cFld26C,cFld26tC,"Classif.",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Filial",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Série",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Item NF",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Forn.",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Loja",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"CNPJ",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Produto",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"CFOP",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Quant",2,2)
	oExcel:AddColumn(cFld26C,cFld26tC,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Vl.Total",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Base ICMS",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Desconto",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Seguro",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Despesas",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Frete",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Observações",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"TES",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Espécie",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld26C,cFld26tC,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Vl Pis",2,3)
	oExcel:AddColumn(cFld26C,cFld26tC,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26PD
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26PD()
	oExcel:AddworkSheet(cFld26D)
	oExcel:AddTable(cFld26D,cFld26tD)
	oExcel:AddColumn(cFld26D,cFld26tD,"Classif.",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Filial",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Série",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Item NF",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Forn.",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Loja",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"CNPJ",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Produto",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"CFOP",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Quant",2,2)
	oExcel:AddColumn(cFld26D,cFld26tD,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Vl.Total",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Base ICMS",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Desconto",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Seguro",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Despesas",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Frete",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Observações",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"TES",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Espécie",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld26D,cFld26tD,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Vl Pis",2,3)
	oExcel:AddColumn(cFld26D,cFld26tD,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26PE
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26PE()
	oExcel:AddworkSheet(cFld26E)
	oExcel:AddTable(cFld26E,cFld26tE)
	oExcel:AddColumn(cFld26E,cFld26tE,"Classif.",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Filial",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Série",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Item NF",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Forn.",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Loja",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"CNPJ",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Produto",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"CFOP",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Quant",2,2)
	oExcel:AddColumn(cFld26E,cFld26tE,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Vl.Total",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Base ICMS",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Desconto",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Seguro",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Despesas",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Frete",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Observações",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"TES",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Espécie",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld26E,cFld26tE,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Vl Pis",2,3)
	oExcel:AddColumn(cFld26E,cFld26tE,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26PZ
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function Cab26PZ()
	oExcel:AddworkSheet(cFld26Z)
	oExcel:AddTable(cFld26Z,cFld26tZ)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Classif.",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Filial",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Dt. Entrada",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Série",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Item NF",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Forn.",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Loja",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Nome Forn.",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"CNPJ",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Produto",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"CFOP",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Quant",2,2)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Prc.Unit.",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Vl.Total",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Vl.Contabil",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Base ICMS",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Aliq ICMS",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Valor ICMS",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"ICMS Retido",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"ICMS Outras",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Desconto",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Seguro",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Despesas",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Frete",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Observações",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Conta Contabil",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"TES",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Tipo Mov",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Tipo Doc",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Espécie",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Calc. ICMS",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Créd ICMS",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Calc. Pis/Cof",1,1)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Créd Pis/Cof",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Vl Pis",2,3)
	oExcel:AddColumn(cFld26Z,cFld26tZ,"Vl Cofins",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx26P2  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P2()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		oExcel:AddRow(cFld262,cFld26t2,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld262,cFld26t2,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26P3  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P3()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 1'
		oExcel:AddRow(cFld263,cFld26t3,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld263,cFld26t3,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26P4  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P4()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 2'
		oExcel:AddRow(cFld264,cFld26t4,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld264,cFld26t4,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})	
Return

/*/{Protheus.doc} Static Function GEx26P5  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P5()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 3'
		oExcel:AddRow(cFld265,cFld26t5,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld265,cFld26t5,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26P6  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P6()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 4'
		oExcel:AddRow(cFld266,cFld26t6,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld266,cFld26t6,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26P7  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P7()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 5'
		oExcel:AddRow(cFld267,cFld26t7,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld267,cFld26t7,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26P8  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P8()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 6'
		oExcel:AddRow(cFld268,cFld26t8,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld268,cFld26t8,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26P9  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P9()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 7'
		oExcel:AddRow(cFld269,cFld26t9,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld269,cFld26t9,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return


/*/{Protheus.doc} Static Function GEx26P0
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26P0()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 8'
		oExcel:AddRow(cFld260,cFld26t0,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld260,cFld26t0,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26PA
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26PA()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == ' 9'
		oExcel:AddRow(cFld26A,cFld26tA,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld26A,cFld26tA,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26PB
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26PB()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == '10'
		oExcel:AddRow(cFld26B,cFld26tB,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld26B,cFld26tB,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26PC
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26PC()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == '11'
		oExcel:AddRow(cFld26C,cFld26tC,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld26C,cFld26tC,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26PD
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26PD()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == '12'
		oExcel:AddRow(cFld26D,cFld26tD,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld26D,cFld26tD,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26PE
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26PE()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == '13'
		oExcel:AddRow(cFld26E,cFld26tE,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld26E,cFld26tE,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx26PZ  
	Gera Relatório Ref. Outras Entradas
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx26PZ()
	(cAlB26Z1)->(dbGoTop())
	While !(cAlB26Z1)->(Eof())
		IF (cAlB26Z1)->CLASSIF == '14'
		oExcel:AddRow(cFld26Z,cFld26tZ,{(cAlB26Z1)->CLASSIF,;
																		(cAlB26Z1)->FILIAL,;
																		(cAlB26Z1)->DTENTRADA,;
																		(cAlB26Z1)->NFSERIE,;
																		(cAlB26Z1)->NF,;
																		(cAlB26Z1)->NFITEM,;
																		(cAlB26Z1)->CLIEFOR,;
																		(cAlB26Z1)->LOJA,;
																		(cAlB26Z1)->NOME,;
																		(cAlB26Z1)->CNPJ,;
																		(cAlB26Z1)->CODPROD,;
																		(cAlB26Z1)->DESCPROD,;
																		(cAlB26Z1)->CFOP,;
																		(cAlB26Z1)->QUANT,;
																		(cAlB26Z1)->PRCUNIT,;
																		(cAlB26Z1)->TOTAL,;
																		(cAlB26Z1)->VLCONT,;
																		(cAlB26Z1)->ICMSBASE,;
																		(cAlB26Z1)->ICMSALIQ,;
																		(cAlB26Z1)->ICMSVAL,;
																		(cAlB26Z1)->ICMSRET,;
																		(cAlB26Z1)->ICMSOUTR,;
																		(cAlB26Z1)->DESCONT,;
																		(cAlB26Z1)->SEGURO,;
																		(cAlB26Z1)->DESPESA,;
																		(cAlB26Z1)->FRETE,;
																		(cAlB26Z1)->OBSERV,;
																		(cAlB26Z1)->CONTACONT,;
																		(cAlB26Z1)->TES,;
																		(cAlB26Z1)->TIPOMOV,;
																		(cAlB26Z1)->TIPO,;
																		(cAlB26Z1)->ESPECIE,;
																		(cAlB26Z1)->CALCICMS,;
																		(cAlB26Z1)->CREDICMS,;
																		(cAlB26Z1)->CALCPIS,;
																		(cAlB26Z1)->CREDPIS,;
																		(cAlB26Z1)->VALPIS,;
																		(cAlB26Z1)->VALCOF})
		ENDIF
		(cAlB26Z1)->(dbSkip())
	ENDDO																
	//Linha Em branco
	oExcel:AddRow(cFld26Z,cFld26tZ,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

//FIM Chamado n.055157 - OS n.056585 - Relatório Outras Entradas - Abel Babini - 28/01/2020

//INICIO Chamado n.055548 - OS n.057704 - Abel Babini - 24/03/2020 - Painel Fiscal ICMS SC - Relatório Compra MP
/*/{Protheus.doc} Static Function xABrw29
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xABrw29
	If Select(cAlB29Br) > 0
		(cAlB29Br)->(dbCloseArea())
	Endif
	cAlB29Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T29COMMP)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T29COMMP)
	oAlB29D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB29Br, _aFields, _aIndex) 

	If Select(cAlB29Dt) > 0
		(cAlB29Dt)->(dbCloseArea())
	Endif
	cAlB29Dt:=GetNextAlias()

	BeginSQL  Alias cAlB29Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_ENTRADA	AS DTENTRADA,
			SFT.FT_EMISSAO	AS DTEMISSAO,
			SFT.FT_SERIE		AS NFSERIE,
			SFT.FT_NFISCAL	AS NF,
			SFT.FT_ITEM			AS NFITEM,
			SFT.FT_CLIEFOR	AS CLIEFOR,
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,
			SFT.FT_PRODUTO	AS CODPROD,
			SB1.B1_DESC			AS DESCPROD,
			SFT.FT_POSIPI		AS NCM,
			SFT.FT_CFOP 		AS CFOP,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT	AS PRCUNIT,
			SFT.FT_VALCONT	AS VLCONT,
			SFT.FT_VALICM		AS VLICMS,
			SFT.FT_CSTPIS 	AS CSTPIS
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA2.%notDel%
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_CFOP IN %Exp:_cCFCPMP%
			AND SFT.FT_POSIPI NOT IN %Exp:_cGraxar%
			
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel%			
	EndSQL
//AND SFT.FT_VALICM > 0
	DbSelectArea(cAlB29Dt)
	(cAlB29Dt)->(DbGoTop())
	While !(cAlB29Dt)->(eof())

		RECLOCK(cAlB29Br,.T.)
			(cAlB29Br)->FILIAL := (cAlB29Dt)->FILIAL
			(cAlB29Br)->DTENTRADA := (cAlB29Dt)->DTENTRADA
			(cAlB29Br)->DTEMISSAO := (cAlB29Dt)->DTEMISSAO
			(cAlB29Br)->NFSERIE := (cAlB29Dt)->NFSERIE
			(cAlB29Br)->NF := (cAlB29Dt)->NF
			(cAlB29Br)->NFITEM := (cAlB29Dt)->NFITEM
			(cAlB29Br)->CLIEFOR := (cAlB29Dt)->CLIEFOR
			(cAlB29Br)->NOME := (cAlB29Dt)->NOME
			(cAlB29Br)->CNPJ := (cAlB29Dt)->CNPJ
			(cAlB29Br)->LOJA := (cAlB29Dt)->LOJA
			(cAlB29Br)->CFOP := (cAlB29Dt)->CFOP
			(cAlB29Br)->CODPROD := (cAlB29Dt)->CODPROD
			(cAlB29Br)->DESCPROD := (cAlB29Dt)->DESCPROD
			(cAlB29Br)->NCM := (cAlB29Dt)->NCM
			(cAlB29Br)->QUANT := (cAlB29Dt)->QUANT
			(cAlB29Br)->PRCUNIT := (cAlB29Dt)->PRCUNIT
			(cAlB29Br)->VLCONT := (cAlB29Dt)->VLCONT
			(cAlB29Br)->VLICMS := (cAlB29Dt)->VLICMS
			(cAlB29Br)->CSTPIS := (cAlB29Dt)->CSTPIS
		MSUNLOCK()	
		nVCOMMP += (cAlB29Dt)->VLICMS
		(cAlB29Dt)->(DbSkip())
	EndDo

	(cAlB29Br)->(dbGoTop())
	(cAlB29Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr29
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xRelBr29()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Compra MP" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr29b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr29b
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xRelBr29b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RCOMPRAMP_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo CFOP
		Cab29P1()
		GEx29P1()

		//Planilha1 - Detalhes
		Cab29P2()
		GEx29P2()

		//Planilha1 - Resumo CST
		Cab29P3()
		GEx29P3()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab29P1
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab29P1()
	//
	oExcel:AddworkSheet(cFld291)
	oExcel:AddTable(cFld291,cFld29t1)
	oExcel:AddColumn(cFld291,cFld29t1,"Filial",1,1)
	oExcel:AddColumn(cFld291,cFld29t1,"Código",1,1)
	oExcel:AddColumn(cFld291,cFld29t1,"Produto",1,1)
	oExcel:AddColumn(cFld291,cFld29t1,"NCM",1,1)
	oExcel:AddColumn(cFld291,cFld29t1,"CFOP",1,1)
	oExcel:AddColumn(cFld291,cFld29t1,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld291,cFld29t1,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx29P1
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx29P1()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''
	Local nVlCont		:= 0
	Local nVlICMS		:= 0
	//
	(cAlB29Br)->(dbSetOrder(2))
	(cAlB29Br)->(dbGoTop())
	While !(cAlB29Br)->(Eof())
		IF ( (cAlB29Br)->CFOP <> cCFOPAux .or. (cAlB29Br)->CODPROD <> cProdAux) .and. cCFOPAux <> ''
			oExcel:AddRow(cFld291,cFld29t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
		ENDIF

		nVlCont		+= (cAlB29Br)->VLCONT
		nVlICMS		+= (cAlB29Br)->VLICMS
		cProdAux	:= (cAlB29Br)->CODPROD
		cDPrdAux	:= (cAlB29Br)->DESCPROD
		cNCMAux		:= (cAlB29Br)->NCM
		cCFOPAux	:= (cAlB29Br)->CFOP
		(cAlB29Br)->(dbSkip())
	ENDDO
	oExcel:AddRow(cFld291,cFld29t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})

	(cAlB29Br)->(dbSetOrder(1))
	(cAlB29Br)->(dbGoTop())

	oExcel:AddRow(cFld291,cFld29t1,{"","","","","","",""})
Return

/*/{Protheus.doc} Static Function Cab29P2
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function Cab29P2()
	oExcel:AddworkSheet(cFld292)
	oExcel:AddTable(cFld292,cFld29t2)
	oExcel:AddColumn(cFld292,cFld29t2,"Filial",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Série",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Item",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Cod.Cliente",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Loja Cliente",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Cliente",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"CNPJ",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"CFOP",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"CSTPIS",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Produto",1,1)
	oExcel:AddColumn(cFld292,cFld29t2,"Quant.",2,2)
	oExcel:AddColumn(cFld292,cFld29t2,"Preço Unit.",2,3)
	oExcel:AddColumn(cFld292,cFld29t2,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld292,cFld29t2,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx29P2
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx29P2()
	//
	(cAlB29Br)->(dbGoTop())
	While !(cAlB29Br)->(Eof())
		oExcel:AddRow(cFld292,cFld29t2,{(cAlB29Br)->FILIAL,;
																		(cAlB29Br)->DTENTRADA,;
																		(cAlB29Br)->DTEMISSAO,;
																		(cAlB29Br)->NFSERIE,;
																		(cAlB29Br)->NF,;
																		(cAlB29Br)->NFITEM,;
																		(cAlB29Br)->CLIEFOR,;
																		(cAlB29Br)->LOJA,;
																		(cAlB29Br)->NOME,;
																		(cAlB29Br)->CNPJ,;
																		(cAlB29Br)->CFOP,;
																		(cAlB29Br)->CSTPIS,;
																		(cAlB29Br)->CODPROD,;
																		(cAlB29Br)->DESCPROD,;
																		(cAlB29Br)->QUANT,;
																		(cAlB29Br)->PRCUNIT,;
																		(cAlB29Br)->VLCONT,;
																		(cAlB29Br)->VLICMS})
		(cAlB29Br)->(dbSkip())
	ENDDO
	(cAlB29Br)->(dbGoTop())
	oExcel:AddRow(cFld292,cFld29t2,{"","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function Cab29P3
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab29P3()
	//
	oExcel:AddworkSheet(cFld293)
	oExcel:AddTable(cFld293,cFld29t3)
	oExcel:AddColumn(cFld293,cFld29t3,"Filial",1,1)
	oExcel:AddColumn(cFld293,cFld29t3,"CST Pis",1,1)
	oExcel:AddColumn(cFld293,cFld29t3,"Código",1,1)
	oExcel:AddColumn(cFld293,cFld29t3,"Produto",1,1)
	oExcel:AddColumn(cFld293,cFld29t3,"NCM",1,1)
	oExcel:AddColumn(cFld293,cFld29t3,"CFOP",1,1)
	oExcel:AddColumn(cFld293,cFld29t3,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld293,cFld29t3,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx29P3
	Gera Relatório Ref. Compra MP
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx29P3()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cCSTPis		:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''
	Local nVlCont		:= 0
	Local nVlICMS		:= 0

	Local nTtCont		:= 0
	Local nTtICMS		:= 0
	//
	(cAlB29Br)->(dbSetOrder(2))
	(cAlB29Br)->(dbGoTop())
	While !(cAlB29Br)->(Eof())
		IF (cAlB29Br)->CODPROD <> cProdAux .and. cProdAux <> ''
			oExcel:AddRow(cFld293,cFld29t3,{cFilAnt, cCSTPis, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
		ENDIF

		IF (cAlB29Br)->CSTPIS <> cCSTPis .and. cCSTPis <> ''
			oExcel:AddRow(cFld293,cFld29t3,{cFilAnt, cCSTPis, '', '', '', '', nTtCont, nTtICMS})
			oExcel:AddRow(cFld293,cFld29t3,{"","","","","","","",""})
			nTtCont		:= 0
			nTtICMS		:= 0
			//cProdAux	:= ''
		ENDIF


		nVlCont		+= (cAlB29Br)->VLCONT
		nVlICMS		+= (cAlB29Br)->VLICMS

		nTtCont		+= (cAlB29Br)->VLCONT
		nTtICMS		+= (cAlB29Br)->VLICMS

		cProdAux	:= (cAlB29Br)->CODPROD
		cDPrdAux	:= (cAlB29Br)->DESCPROD
		cNCMAux		:= (cAlB29Br)->NCM
		cCFOPAux	:= (cAlB29Br)->CFOP
		cCSTPis		:= (cAlB29Br)->CSTPIS
		(cAlB29Br)->(dbSkip())
	ENDDO
	oExcel:AddRow(cFld293,cFld29t3,{cFilAnt, cCSTPis, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})
	oExcel:AddRow(cFld293,cFld29t3,{cFilAnt, cCSTPis, '', '', '', '', nTtCont, nTtICMS})
	oExcel:AddRow(cFld293,cFld29t3,{"","","","","","","",""})

	(cAlB29Br)->(dbSetOrder(1))
	(cAlB29Br)->(dbGoTop())

Return
//FIM Chamado n.055548 - OS n.057704 - Abel Babini - 24/03/2020 - Painel Fiscal ICMS SC - Relatório Compra MP

/*/{Protheus.doc} Static Function xABrw30
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xABrw30
	If Select(cAlB30Br) > 0
		(cAlB30Br)->(dbCloseArea())
	Endif
	cAlB30Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T30VENFV)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T30VENFV)
	oAlB30D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB30Br, _aFields, _aIndex) 

	If Select(cAlB30Dt) > 0
		(cAlB30Dt)->(dbCloseArea())
	Endif
	cAlB30Dt:=GetNextAlias()

	BeginSQL  Alias cAlB30Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_ENTRADA	AS DTENTRADA,
			SFT.FT_EMISSAO	AS DTEMISSAO,
			SFT.FT_SERIE		AS NFSERIE,
			SFT.FT_NFISCAL	AS NF,
			SFT.FT_ITEM			AS NFITEM,
			SFT.FT_CLIEFOR	AS CLIEFOR,
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,
			SFT.FT_PRODUTO	AS CODPROD,
			SB1.B1_DESC		AS DESCPROD,
			SFT.FT_POSIPI	AS NCM,
			SFT.FT_CFOP 	AS CFOP,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT	AS PRCUNIT,
			SFT.FT_VALCONT	AS VLCONT,
			SFT.FT_VALICM		AS VLICMS,
			SFT.R_E_C_N_O_ AS R_E_C_N_O_
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA2.%notDel%
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_CFOP IN %Exp:_cCFVDFV%
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel%			
	EndSQL
//AND SFT.FT_VALICM > 0
//AND SFT.FT_POSIPI NOT IN %Exp:_cGraxar%
	DbSelectArea(cAlB30Dt)
	(cAlB30Dt)->(DbGoTop())
	While !(cAlB30Dt)->(eof())

		RECLOCK(cAlB30Br,.T.)
			(cAlB30Br)->FILIAL 		:= (cAlB30Dt)->FILIAL
			(cAlB30Br)->DTENTRADA := (cAlB30Dt)->DTENTRADA
			(cAlB30Br)->DTEMISSAO := (cAlB30Dt)->DTEMISSAO
			(cAlB30Br)->NFSERIE 	:= (cAlB30Dt)->NFSERIE
			(cAlB30Br)->NF 				:= (cAlB30Dt)->NF
			(cAlB30Br)->NFITEM 		:= (cAlB30Dt)->NFITEM
			(cAlB30Br)->CLIEFOR 	:= (cAlB30Dt)->CLIEFOR
			(cAlB30Br)->NOME 			:= (cAlB30Dt)->NOME
			(cAlB30Br)->CNPJ 			:= (cAlB30Dt)->CNPJ
			(cAlB30Br)->LOJA 			:= (cAlB30Dt)->LOJA
			(cAlB30Br)->CFOP 			:= (cAlB30Dt)->CFOP
			(cAlB30Br)->CODPROD 	:= (cAlB30Dt)->CODPROD
			(cAlB30Br)->DESCPROD 	:= (cAlB30Dt)->DESCPROD
			(cAlB30Br)->NCM 			:= (cAlB30Dt)->NCM
			(cAlB30Br)->QUANT 		:= (cAlB30Dt)->QUANT
			(cAlB30Br)->PRCUNIT 	:= (cAlB30Dt)->PRCUNIT
			(cAlB30Br)->VLCONT 		:= (cAlB30Dt)->VLCONT
			(cAlB30Br)->VLICMS 		:= (cAlB30Dt)->VLICMS
		MSUNLOCK()	
		nVVenFV += (cAlB30Dt)->VLICMS
		(cAlB30Dt)->(DbSkip())
	EndDo

	(cAlB30Br)->(dbGoTop())
	(cAlB30Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr30
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xRelBr30()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Vendas" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr30b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr30b
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xRelBr30b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RVENDAS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab30P1()
		GEx30P1()

		//Planilha1 - Detalhes
		Cab30P2()
		GEx30P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab30P1
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab30P1()
	oExcel:AddworkSheet(cFld301)
	oExcel:AddTable(cFld301,cFld30t1)
	oExcel:AddColumn(cFld301,cFld30t1,"Filial",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"Código",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"Produto",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"NCM",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"CFOP",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld301,cFld30t1,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx30P1
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx30P1()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''
	Local nVlCont		:= 0
	Local nVlICMS		:= 0
	//
	(cAlB30Br)->(dbSetOrder(2))
	(cAlB30Br)->(dbGoTop())
	While !(cAlB30Br)->(Eof())
		IF ( (cAlB30Br)->CFOP <> cCFOPAux .or. (cAlB30Br)->CODPROD <> cProdAux) .and. cCFOPAux <> ''
			oExcel:AddRow(cFld301,cFld30t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
		ENDIF

		nVlCont		+= (cAlB30Br)->VLCONT
		nVlICMS		+= (cAlB30Br)->VLICMS
		cProdAux	:= (cAlB30Br)->CODPROD
		cDPrdAux	:= (cAlB30Br)->DESCPROD
		cNCMAux		:= (cAlB30Br)->NCM
		cCFOPAux	:= (cAlB30Br)->CFOP
		(cAlB30Br)->(dbSkip())
	ENDDO
	oExcel:AddRow(cFld301,cFld30t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})

	(cAlB30Br)->(dbSetOrder(1))
	(cAlB30Br)->(dbGoTop())

	oExcel:AddRow(cFld301,cFld30t1,{"","","","","","",""})
Return

/*/{Protheus.doc} Static Function Cab30P2
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function Cab30P2()
	oExcel:AddworkSheet(cFld302)
	oExcel:AddTable(cFld302,cFld30t2)
	oExcel:AddColumn(cFld302,cFld30t2,"Filial",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Série",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Item",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Cod.Cliente",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Loja Cliente",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Cliente",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"CNPJ",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"CFOP",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Produto",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Quant.",2,2)
	oExcel:AddColumn(cFld302,cFld30t2,"Preço Unit.",2,3)
	oExcel:AddColumn(cFld302,cFld30t2,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld302,cFld30t2,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx30P2
	Gera Relatório Ref. Vendas
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx30P2()
	//
	(cAlB30Br)->(dbGoTop())
	While !(cAlB30Br)->(Eof())
		oExcel:AddRow(cFld302,cFld30t2,{(cAlB30Br)->FILIAL,;
																		(cAlB30Br)->DTENTRADA,;
																		(cAlB30Br)->DTEMISSAO,;
																		(cAlB30Br)->NFSERIE,;
																		(cAlB30Br)->NF,;
																		(cAlB30Br)->NFITEM,;
																		(cAlB30Br)->CLIEFOR,;
																		(cAlB30Br)->LOJA,;
																		(cAlB30Br)->NOME,;
																		(cAlB30Br)->CNPJ,;
																		(cAlB30Br)->CFOP,;
																		(cAlB30Br)->CODPROD,;
																		(cAlB30Br)->DESCPROD,;
																		(cAlB30Br)->QUANT,;
																		(cAlB30Br)->PRCUNIT,;
																		(cAlB30Br)->VLCONT,;
																		(cAlB30Br)->VLICMS})
		(cAlB30Br)->(dbSkip())
	ENDDO
	(cAlB30Br)->(dbGoTop())
	oExcel:AddRow(cFld302,cFld30t2,{"","","","","","","","","","","","","","","","",""})
Return

//INICIO Chamado n.055548 - OS n.058176 - Abel Babini - 27/03/2020 - Painel Fiscal ICMS GO - Ajustes na Apuração de ICMS GO
/*/{Protheus.doc} Static Function xABrw31
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 11/02/2020
	@version 01
	/*/
Static Function xABrw31
	Local n5208:=n6208:=n5949:=n6949:=n5934:=n6934:=n5101:=n6101:=n5102:=n6102:=0
	Local n5118:=n6118:=n5901:=n6901:=n5206:=n6206:=n5201:=n6201:=n5553:=n6553:=0
	Local n5556:=n6556:=n5551:=n6551:=n1604:=n2604:=n7101:=n1208:=n2208:=0
	Local nTtFat:=nTtCom:=nVendas:=nV20130:=nVTransf:=nDTransf:=0

	If Select(cAlB31Br) > 0
		(cAlB31Br)->(dbCloseArea())
	Endif
	cAlB31Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T31APICM)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T31APICM)
	oAlB31D1	:= StaticCall(ADFIS028R,CriaTmpT,cAlB31Br,_aFields,_aIndex)

	If Select(cAlB31Rs) > 0
		(cAlB31Rs)->(dbCloseArea())
	Endif
	cAlB31Rs:=GetNextAlias()
	BeginSQL  Alias cAlB31Rs
		SELECT
			SF3.F3_CFO AS CFOP,
			SF3.F3_ALIQICM AS ALIQICM,
			SUM(SF3.F3_VALCONT) AS VALCONT,
			SUM(SF3.F3_BASEICM) AS BASEICMS,
			SUM(SF3.F3_VALICM) AS VALICMS,
			SUM(SF3.F3_ISENICM) AS ISENTO,
			SUM(SF3.F3_OUTRICM) AS OUTRAS,
			SUM(SF3.F3_VALCONT - SF3.F3_BASEICM - SF3.F3_ISENICM - SF3.F3_OUTRICM - SF3.F3_IPIOBS)  AS DESCONT,
			SUM(SF3.F3_IPIOBS) AS VALIPI
		FROM %TABLE:SF3% SF3
		WHERE SF3.F3_FILIAL = %xFilial:SF3%
		AND SF3.F3_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.F3_CFO > '5000'
		AND SF3.F3_CLIEFOR IN %Exp:_cCliSd%
		AND SF3.%notDel%
		GROUP BY SF3.F3_CFO, SF3.F3_ALIQICM

		UNION

		SELECT
			SF3.F3_CFO AS CFOP,
			SF3.F3_ALIQICM AS ALIQICM,
			SUM(SF3.F3_VALCONT) AS VALCONT,
			SUM(SF3.F3_BASEICM) AS BASEICMS,
			SUM(SF3.F3_VALICM) AS VALICMS,
			SUM(SF3.F3_ISENICM) AS ISENTO,
			SUM(SF3.F3_OUTRICM) AS OUTRAS,
			SUM(SF3.F3_VALCONT - SF3.F3_BASEICM - SF3.F3_ISENICM - SF3.F3_OUTRICM - SF3.F3_IPIOBS)  AS DESCONT,
			SUM(SF3.F3_IPIOBS) AS VALIPI
		FROM %TABLE:SF3% SF3
		WHERE SF3.F3_FILIAL IN %Exp:_cFilEn%
		AND SF3.F3_CFO NOT IN ('1126','2126','3126')
		AND SF3.F3_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.F3_CFO < '5000'
		AND SF3.F3_CLIEFOR IN %Exp:_cForEn%
		AND SF3.%notDel%
		GROUP BY SF3.F3_CFO, SF3.F3_ALIQICM
		ORDER BY 1, 2		
	EndSQL

	DbSelectArea(cAlB31Rs)
	(cAlB31Rs)->(DbGoTop())
	While !(cAlB31Rs)->(eof())

		RECLOCK(cAlB31Br,.T.)
			(cAlB31Br)->FILIAL 		:= cFilAnt
			(cAlB31Br)->CFOP 			:= (cAlB31Rs)->CFOP
			(cAlB31Br)->ALIQUOTA	:= (cAlB31Rs)->ALIQICM
			(cAlB31Br)->VALCONT 	:= (cAlB31Rs)->VALCONT
			(cAlB31Br)->BASEICMS 	:= (cAlB31Rs)->BASEICMS
			(cAlB31Br)->VALICMS 	:= (cAlB31Rs)->VALICMS
			(cAlB31Br)->ISENTO 		:= (cAlB31Rs)->ISENTO
			(cAlB31Br)->OUTRAS 		:= (cAlB31Rs)->OUTRAS
			(cAlB31Br)->DESCONT 	:= (cAlB31Rs)->DESCONT
			(cAlB31Br)->VALIPI 		:= (cAlB31Rs)->VALIPI
		MSUNLOCK()	
	
		//
		IF ALLTRIM((cAlB31Rs)->CFOP) < '5000'
			nTtCom	+= (cAlB31Rs)->VALICMS
		ENDIF

		IF ALLTRIM((cAlB31Rs)->CFOP) == '1604'
			n1604	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '2604'
			n2604	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '1208'
			n1258	+= (cAlB31Rs)->VALICMS
			nDTransf += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '2208'
			n2258	+= (cAlB31Rs)->VALICMS
			nDTransf += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5151'
			n5208	+= (cAlB31Rs)->VALICMS
			nVTransf += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6151'
			n5208	+= (cAlB31Rs)->VALICMS
			nVTransf += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5208'
			n5208	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6208'
			n6208	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5949'
			n5949	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6949'
			n6949	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5934'
			n5934	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6934'
			n6934	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5101'
			n5101	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6101'
			n6101	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '7101'
			n7101	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5102'
			n5102	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6102'
			n6102	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5118'
			n5118	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6118'
			n6118	+= (cAlB31Rs)->VALICMS
			nVendas += (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5901'
			n5901	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6901'
			n6901	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5206'
			n5206	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6206'
			n6206	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5201'
			n5201	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6201'
			n6201	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5551'
			n5551	+= (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6551'
			n6551	+= (cAlB31Rs)->VALICMS
			nTtFat += (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5553'
			n5553	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6553'
			n6553	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '5556'
			n5556	+= (cAlB31Rs)->VALICMS
		ELSEIF ALLTRIM((cAlB31Rs)->CFOP) == '6556'
			n6556	+= (cAlB31Rs)->VALICMS
		ENDIF

		(cAlB31Rs)->(DbSkip())
	EndDo

	(cAlB31Br)->(dbGoTop())
	(cAlB31Rs)->(dbCloseArea())	


	If Select(cAlB31Nf) > 0
		(cAlB31Nf)->(dbCloseArea())
	Endif
	cAlB31Nf:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T31DETAI)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T31DETAI)
	oAlB27D2	:= StaticCall(ADFIS028R,CriaTmpT,cAlB31Nf,_aFields,_aIndex)

	If Select(cAlB31Dt) > 0
		(cAlB31Dt)->(dbCloseArea())
	Endif
	cAlB31Dt:=GetNextAlias()
	BeginSQL  Alias cAlB31Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SF3.F3_FILIAL		AS FILIAL,
			SF3.F3_SERIE		AS NFSERIE,
			SF3.F3_NFISCAL	AS NFISCAL,
			SF3.F3_CLIEFOR	AS CLIEFOR,
			SF3.F3_LOJA			AS LOJA,
			CASE WHEN (SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			SF3.F3_CFO			AS CFOP,
			SF3.F3_VALCONT	AS VALCONT,
			SF3.F3_BASEICM	AS BASEICMS,
			SF3.F3_ALIQICM	AS ALIQICM,
			SF3.F3_VALICM		AS VALICMS,
			SF3.F3_ISENICM 	AS ISENTO,
			SF3.F3_OUTRICM 	AS OUTRAS,
			SF3.F3_IPIOBS		AS VALIPI,
			(SF3.F3_VALCONT - SF3.F3_BASEICM - SF3.F3_ISENICM - SF3.F3_OUTRICM - SF3.F3_IPIOBS) AS VERIFIC,
			SF3.F3_ICMSRET	AS ICMSRET,
			SF3.F3_ICMSCOM	AS ICMSCOM,
			SF3.F3_ENTRADA	AS DTENTRADA,
			SF3.F3_EMISSAO	AS DTEMISSAO,
			SF3.F3_ESTADO		AS ESTADO,
			SF3.F3_CODRSEF	AS CODRSEF,
			SF3.F3_FORMUL		AS FORMUL
		FROM %TABLE:SF3% SF3
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.%notDel%
		AND SA2.A2_COD = SF3.F3_CLIEFOR
		AND SA2.A2_LOJA = SF3.F3_LOJA
		AND ( (SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') ) )
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.%notDel%
		AND SA1.A1_COD = SF3.F3_CLIEFOR
		AND SA1.A1_LOJA = SF3.F3_LOJA
		AND ( (SF3.F3_CFO > '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO < '5000' AND SF3.F3_TIPO IN ('D','B') ) )

		WHERE SF3.F3_FILIAL = %xFilial:SF3%
		AND F3_CFO NOT IN ('1126','2126','3126')
		AND SF3.F3_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.F3_CFO > '5000'
		AND SF3.F3_CLIEFOR IN %Exp:_cCliSd%
		AND SF3.%notDel%

		UNION

		SELECT
			SF3.F3_FILIAL		AS FILIAL,
			SF3.F3_SERIE		AS NFSERIE,
			SF3.F3_NFISCAL	AS NFISCAL,
			SF3.F3_CLIEFOR	AS CLIEFOR,
			SF3.F3_LOJA			AS LOJA,
			CASE WHEN (SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			SF3.F3_CFO			AS CFOP,
			SF3.F3_VALCONT	AS VALCONT,
			SF3.F3_BASEICM	AS BASEICMS,
			SF3.F3_ALIQICM	AS ALIQICM,
			SF3.F3_VALICM		AS VALICMS,
			SF3.F3_ISENICM 	AS ISENTO,
			SF3.F3_OUTRICM 	AS OUTRAS,
			SF3.F3_IPIOBS		AS VALIPI,
			(SF3.F3_VALCONT - SF3.F3_BASEICM - SF3.F3_ISENICM - SF3.F3_OUTRICM - SF3.F3_IPIOBS) AS VERIFIC,
			SF3.F3_ICMSRET	AS ICMSRET,
			SF3.F3_ICMSCOM	AS ICMSCOM,
			SF3.F3_ENTRADA	AS DTENTRADA,
			SF3.F3_EMISSAO	AS DTEMISSAO,
			SF3.F3_ESTADO		AS ESTADO,
			SF3.F3_CODRSEF	AS CODRSEF,
			SF3.F3_FORMUL		AS FORMUL
		FROM %TABLE:SF3% SF3
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.%notDel%
		AND SA2.A2_COD = SF3.F3_CLIEFOR
		AND SA2.A2_LOJA = SF3.F3_LOJA
		AND ( (SF3.F3_CFO < '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO > '5000' AND SF3.F3_TIPO IN ('D','B') ) )
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.%notDel%
		AND SA1.A1_COD = SF3.F3_CLIEFOR
		AND SA1.A1_LOJA = SF3.F3_LOJA
		AND ( (SF3.F3_CFO > '5000' AND SF3.F3_TIPO NOT IN ('D','B') ) OR (SF3.F3_CFO < '5000' AND SF3.F3_TIPO IN ('D','B') ) )

		WHERE SF3.F3_FILIAL IN %Exp:_cFilEn%
		AND F3_CFO NOT IN ('1126','2126','3126')
		AND SF3.F3_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
		AND SF3.F3_DTCANC = ''
		AND SF3.F3_CFO < '5000'
		AND SF3.F3_CLIEFOR IN %Exp:_cForEn%
		AND SF3.%notDel%		

		ORDER BY 1, 2, 3	
	EndSQL
	DbSelectArea(cAlB31Dt)
	(cAlB31Dt)->(DbGoTop())
	While !(cAlB31Dt)->(eof())

		RECLOCK(cAlB31Nf,.T.)
			(cAlB31Nf)->FILIAL 		:= cFilAnt
			(cAlB31Nf)->NFSERIE 	:= (cAlB31Dt)->NFSERIE
			(cAlB31Nf)->NFISCAL 	:= (cAlB31Dt)->NFISCAL
			(cAlB31Nf)->CLIEFOR 	:= (cAlB31Dt)->CLIEFOR
			(cAlB31Nf)->LOJA 			:= (cAlB31Dt)->LOJA
			(cAlB31Nf)->NOME 			:= (cAlB31Dt)->NOME
			(cAlB31Nf)->CFOP 			:= (cAlB31Dt)->CFOP
			(cAlB31Nf)->VALCONT 	:= (cAlB31Dt)->VALCONT
			(cAlB31Nf)->BASEICMS 	:= (cAlB31Dt)->BASEICMS
			(cAlB31Nf)->ALIQICM		:= (cAlB31Dt)->ALIQICM
			(cAlB31Nf)->VALICMS 	:= (cAlB31Dt)->VALICMS
			(cAlB31Nf)->ISENTO 		:= (cAlB31Dt)->ISENTO
			(cAlB31Nf)->OUTRAS 		:= (cAlB31Dt)->OUTRAS
			(cAlB31Nf)->VERIFIC 	:= (cAlB31Dt)->VERIFIC
			(cAlB31Nf)->VALIPI 		:= (cAlB31Dt)->VALIPI
			(cAlB31Nf)->ICMSRET 	:= (cAlB31Dt)->ICMSRET
			(cAlB31Nf)->ICMSCOM 	:= (cAlB31Dt)->ICMSCOM
			(cAlB31Nf)->ESTADO 		:= (cAlB31Dt)->ESTADO
			(cAlB31Nf)->DTENTRADA := (cAlB31Dt)->DTENTRADA
			(cAlB31Nf)->DTEMISSAO := (cAlB31Dt)->DTEMISSAO
			(cAlB31Nf)->CODRSEF 	:= (cAlB31Dt)->CODRSEF
			(cAlB31Nf)->FORMUL 		:= (cAlB31Dt)->FORMUL
		MSUNLOCK()	
		(cAlB31Dt)->(DbSkip())
	EndDo

	(cAlB31Nf)->(dbGoTop())
	(cAlB31Dt)->(dbCloseArea())	


	//Preenche Array da abertura da Gia
	aBrw03Rs := {} //Linha;Descrição;Valor
	If _lMsUser	.or. _lPerFch
		aRecSd05	:= xRecSd05()
		cMV05T01	:= aRecSd05[1] //Max Versao
		nA05T01		:= aRecSd05[2] //Vl. Saldo Credor Mês Anterior
		nA05T02		:= aRecSd05[3] //Vl. Estorno de Débitos
		cA05T02		:= aRecSd05[4] 
		nA05T03		:= aRecSd05[5] //Vl. Estorno de Créditos
		cA05T03		:= aRecSd05[6] 
		nA05T04		:= aRecSd05[7] //Apropriação de Crédito Acumulado
		nA05T05		:= aRecSd05[8] //Vl. Saldo Credor Mês Atual
		nA05T06		:= aRecSd05[9] //Solicitação DGCA
		nA05T07		:= aRecSd05[10] //Outros Débitos
		cA05T04		:= aRecSd05[11] 
		nA05T08		:= aRecSd05[12] //Outros Créditos
		cA05T05		:= aRecSd05[13] 
		nA05T09		:= aRecSd05[14] //Aprop Cred Acum Outros Débitos
		nA05T10		:= aRecSd05[15] //Aprop Cred Acum Outros Créditos
	Endif

	nV20130 := nTtFat - nVMILHO - nVSORGO - nVPROTE - nDTransf
	nVSldMes := nVMILHO + nVSORGO + nVPROTE
	nVAjus	:= nV20130 + nDTransf
	nVGuia	:= nVMILHO + nVSORGO

	AADD(aBrw03Rs,{'TIT','000100','APURAÇÃO DO ICMS NO MÊS',0} )
	AADD(aBrw03Rs,{'SUB','001000','POR SAIDAS C/DEBITO DO IMPOSTO',nTtFat} )
	AADD(aBrw03Rs,{''		,'001100','VENDAS',nVendas} )
	AADD(aBrw03Rs,{''		,'001200','TRANSFERÊNCIA INTERESTADUAL',nVTransf} )
	AADD(aBrw03Rs,{''		,'001300','',0} )
	AADD(aBrw03Rs,{'TOT','001400','TOTAL DÉBITO',nTtFat} )
	AADD(aBrw03Rs,{'SUB','001500','POR ENTRADAS C/ CRÉDITO IMPOSTO',0} )
	AADD(aBrw03Rs,{''		,'001600','DEVOLUÇÃO TRANSFERÊNCIA',nDTransf} )
	AADD(aBrw03Rs,{''		,'001700','',0} )
	AADD(aBrw03Rs,{'TOT','001800','TOTAL POR ENTRADAS C/ CRÉDITO',0} )
	AADD(aBrw03Rs,{''		,'001900','',0} )
	AADD(aBrw03Rs,{'SUB','002000','AJUSTE DE APURAÇÃO/DEDUÇÃO',0} )
	AADD(aBrw03Rs,{''		,'002100','GO040012 - Pagto Antecipado ICMS Saída Interestadual - Milho',nVMILHO} )
	AADD(aBrw03Rs,{''		,'002200','GO040012 - Pagto Antecipado ICMS Saída Interestadual - Sorgo',nVSORGO} )
	AADD(aBrw03Rs,{''		,'002300','GO050005 - Débito Especial ref. Pagto Antecipado',nVMILHO} )
	AADD(aBrw03Rs,{''		,'002400','GO050005 - Débito Especial ref. Pagto Antecipado - Sorgo',nVSORGO} )
	AADD(aBrw03Rs,{''		,'002500','GO040027 - ICMS média - PROTEGE apoio financeiro',nVPROTE} )
	AADD(aBrw03Rs,{''		,'002600','GO020130 - Credito Outorgado',nV20130} )
	AADD(aBrw03Rs,{''		,'002700','Crédito Devolução Transferência',nDTransf} )
	AADD(aBrw03Rs,{''		,'003000','',0} )

	//AADD(aBrw03Rs,{'MAN','005000','Outros créditos - ***MANUAL*** - '+Alltrim(cA05T05),nA05T08} )
	//AADD(aBrw03Rs,{'MAN','005100','Estorno debitos - ***MANUAL*** - '+Alltrim(cA05T02),nA05T02} )
	//AADD(aBrw03Rs,{'MAN','005200','Outros débitos - ***MANUAL*** - '+Alltrim(cA05T04),nA05T07} )
	//AADD(aBrw03Rs,{'MAN','005300','Estorno créditos - ***MANUAL*** - '+Alltrim(cA05T03),nA05T03} )

	AADD(aBrw03Rs,{'SUB','010000','SALDO CREDOR DO PERIODO ANTERIOR',0} )
	AADD(aBrw03Rs,{'TOT','011000','SALDO DEVEDOR DO MÊS',nVSldMes} )
	AADD(aBrw03Rs,{'TOT','012000','SALDO DEDUÇÕES',nVSldMes} )
	AADD(aBrw03Rs,{'TOT','013000','SALDO AJUSTES CRÉDITO DE IMPOSTO TARE SAIDA 174/2017',nVAjus} )
	AADD(aBrw03Rs,{'TOT','014000','GUIAS RECOLHIDAS CONF. TARE ENTRADA 217/2017',nVGuia} )

Return

/*/{Protheus.doc} Static Function xRelBr31
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xRelBr31()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Apuração ICMS Modelo GO" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr31b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr31b
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function xRelBr31b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RAPICMSGO_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo Saídas
		Cab31P1()
		GEx31P1()

		//Planilha1 - Resumo Entradas
		Cab31P2()
		GEx31P2()

		//Planilha1 - Detalhe Saídas
		Cab31P3()
		GEx31P3()

		//Planilha1 - Detalhe Entradas
		Cab31P4()
		GEx31P4()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab31P1
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab31P1()
	oExcel:AddworkSheet(cFld311)
	oExcel:AddTable(cFld311,cFld31t1)
	oExcel:AddColumn(cFld311,cFld31t1,"Filial",1,1)
	oExcel:AddColumn(cFld311,cFld31t1,"CFOP",1,1)
	oExcel:AddColumn(cFld311,cFld31t1,"Alíquota",1,1)
	oExcel:AddColumn(cFld311,cFld31t1,"Valor Cont.",2,3)
	oExcel:AddColumn(cFld311,cFld31t1,"Base ICMS",2,3)
	oExcel:AddColumn(cFld311,cFld31t1,"Vl. ICMS",2,3)
	oExcel:AddColumn(cFld311,cFld31t1,"Isentas",2,3)
	oExcel:AddColumn(cFld311,cFld31t1,"Outras",2,3)
	oExcel:AddColumn(cFld311,cFld31t1,"Descontos.",2,3)
	oExcel:AddColumn(cFld311,cFld31t1,"Vl. IPI",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab31P2
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab31P2()
	oExcel:AddworkSheet(cFld312)
	oExcel:AddTable(cFld312,cFld31t2)
	oExcel:AddColumn(cFld312,cFld31t2,"Filial",1,1)
	oExcel:AddColumn(cFld312,cFld31t2,"CFOP",1,1)
	oExcel:AddColumn(cFld312,cFld31t2,"Alíquota",1,1)
	oExcel:AddColumn(cFld312,cFld31t2,"Valor Cont.",2,3)
	oExcel:AddColumn(cFld312,cFld31t2,"Base ICMS",2,3)
	oExcel:AddColumn(cFld312,cFld31t2,"Vl. ICMS",2,3)
	oExcel:AddColumn(cFld312,cFld31t2,"Isentas",2,3)
	oExcel:AddColumn(cFld312,cFld31t2,"Outras",2,3)
	oExcel:AddColumn(cFld312,cFld31t2,"Descontos.",2,3)
	oExcel:AddColumn(cFld312,cFld31t2,"Vl. IPI",2,3)
RETURN(NIL) 

/*/{Protheus.doc} Static Function Cab31P3
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab31P3()
	oExcel:AddworkSheet(cFld313)
	oExcel:AddTable(cFld313,cFld31t3)
	oExcel:AddColumn(cFld313,cFld31t3,"Filial",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Série",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Código",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Loja",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Nome",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"CFOP",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Valor Cont.",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Base ICMS",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Alíquota",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Vl. ICMS",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Isentas",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Outras",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Verific.",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Vl. IPI",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"ICMS Ret.",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"ICMS Com.",2,3,.t.)
	oExcel:AddColumn(cFld313,cFld31t3,"Estado",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Cod.Ret.SEF",1,1)
	oExcel:AddColumn(cFld313,cFld31t3,"Formul.",1,1)
RETURN(NIL) 

/*/{Protheus.doc} Static Function Cab31P4
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 10/02/2020
	@version 01
	/*/
Static Function Cab31P4()
	oExcel:AddworkSheet(cFld314)
	oExcel:AddTable(cFld314,cFld31t4)
	oExcel:AddColumn(cFld314,cFld31t4,"Filial",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Série",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Código",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Loja",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Nome",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"CFOP",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Valor Cont.",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Base ICMS",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Alíquota",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Vl. ICMS",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Isentas",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Outras",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Verific.",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Vl. IPI",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"ICMS Ret.",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"ICMS Com.",2,3,.t.)
	oExcel:AddColumn(cFld314,cFld31t4,"Estado",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Cod.Ret.SEF",1,1)
	oExcel:AddColumn(cFld314,cFld31t4,"Formul.",1,1)
RETURN(NIL)

/*/{Protheus.doc} Static Function GEx31P1  
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/

Static Function GEx31P1()
	Local nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
	Local nTTCont:=nTTBase:=nTTICMS:=nTTIsen:=nTTOutr:=nTTDesc:=nTTIPI:=0
	Local cAuxCFOP:=""
	//
	(cAlB31Br)->(dbGoTop())
	While !(cAlB31Br)->(Eof())
		IF Substr((cAlB31Br)->CFOP,1,1) >= '5'
			IF Substr(cAuxCFOP,1,1) <> Substr((cAlB31Br)->CFOP,1,1) .AND. !cAuxCFOP==""
				oExcel:AddRow(cFld311,cFld31t1,{(cAlB31Br)->FILIAL,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
				oExcel:AddRow(cFld311,cFld31t1,{"","","","","","","","","",""})
				nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
			ENDIF
			oExcel:AddRow(cFld311,cFld31t1,{(cAlB31Br)->FILIAL,;
																			(cAlB31Br)->CFOP,;
																			(cAlB31Br)->ALIQUOTA,;
																			(cAlB31Br)->VALCONT,;
																			(cAlB31Br)->BASEICMS,;
																			(cAlB31Br)->VALICMS,;
																			(cAlB31Br)->ISENTO,;
																			(cAlB31Br)->OUTRAS,;
																			(cAlB31Br)->DESCONT,;
																			(cAlB31Br)->VALIPI})
			nTVlCont+=	(cAlB31Br)->VALCONT
			nTVlBase+=	(cAlB31Br)->BASEICMS
			nTVlICMS+=	(cAlB31Br)->VALICMS
			nTVlIsen+=	(cAlB31Br)->ISENTO
			nTVlOutr+=	(cAlB31Br)->OUTRAS
			nTVlDesc+=	(cAlB31Br)->DESCONT
			nTVlIPI	+=	(cAlB31Br)->VALIPI
			cAuxCFOP:=	(cAlB31Br)->CFOP

			nTTCont	+=	(cAlB31Br)->VALCONT
			nTTBase	+=	(cAlB31Br)->BASEICMS
			nTTICMS	+=	(cAlB31Br)->VALICMS
			nTTIsen	+=	(cAlB31Br)->ISENTO
			nTTOutr	+=	(cAlB31Br)->OUTRAS
			nTTDesc	+=	(cAlB31Br)->DESCONT
			nTTIPI	+=	(cAlB31Br)->VALIPI
		ENDIF
		(cAlB31Br)->(dbSkip())
	ENDDO
	(cAlB31Br)->(dbGoTop())
	oExcel:AddRow(cFld311,cFld31t1,{cFilAnt,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
	oExcel:AddRow(cFld311,cFld31t1,{"","","","","","","","","",""})
	oExcel:AddRow(cFld311,cFld31t1,{"","","","","","","","","",""})
	oExcel:AddRow(cFld311,cFld31t1,{cFilAnt,"TOTAL GERAL","",nTTCont,nTTBase,nTTICMS,nTTIsen,nTTOutr,nTTDesc,nTTIPI})
Return

/*/{Protheus.doc} Static Function GEx31P2
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/

Static Function GEx31P2()
	Local nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
	Local nTTCont:=nTTBase:=nTTICMS:=nTTIsen:=nTTOutr:=nTTDesc:=nTTIPI:=0
	Local cAuxCFOP:=""
	//
	(cAlB31Br)->(dbGoTop())
	While !(cAlB31Br)->(Eof())
		IF Substr((cAlB31Br)->CFOP,1,1) < '5'
			IF Substr(cAuxCFOP,1,1) <> Substr((cAlB31Br)->CFOP,1,1) .AND. !cAuxCFOP==""
				oExcel:AddRow(cFld312,cFld31t2,{(cAlB31Br)->FILIAL,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
				oExcel:AddRow(cFld312,cFld31t2,{"","","","","","","","","",""})
				nTVlCont:=nTVlBase:=nTVlICMS:=nTVlIsen:=nTVlOutr:=nTVlDesc:=nTVlIPI:=0
			ENDIF
			oExcel:AddRow(cFld312,cFld31t2,{(cAlB31Br)->FILIAL,;
																			(cAlB31Br)->CFOP,;
																			(cAlB31Br)->ALIQUOTA,;
																			(cAlB31Br)->VALCONT,;
																			(cAlB31Br)->BASEICMS,;
																			(cAlB31Br)->VALICMS,;
																			(cAlB31Br)->ISENTO,;
																			(cAlB31Br)->OUTRAS,;
																			(cAlB31Br)->DESCONT,;
																			(cAlB31Br)->VALIPI})
			nTVlCont+=	(cAlB31Br)->VALCONT
			nTVlBase+=	(cAlB31Br)->BASEICMS
			nTVlICMS+=	(cAlB31Br)->VALICMS
			nTVlIsen+=	(cAlB31Br)->ISENTO
			nTVlOutr+=	(cAlB31Br)->OUTRAS
			nTVlDesc+=	(cAlB31Br)->DESCONT
			nTVlIPI	+=	(cAlB31Br)->VALIPI
			cAuxCFOP:=	(cAlB31Br)->CFOP

			nTTCont	+=	(cAlB31Br)->VALCONT
			nTTBase	+=	(cAlB31Br)->BASEICMS
			nTTICMS	+=	(cAlB31Br)->VALICMS
			nTTIsen	+=	(cAlB31Br)->ISENTO
			nTTOutr	+=	(cAlB31Br)->OUTRAS
			nTTDesc	+=	(cAlB31Br)->DESCONT
			nTTIPI	+=	(cAlB31Br)->VALIPI
		ENDIF
		(cAlB31Br)->(dbSkip())
	ENDDO
	(cAlB31Br)->(dbGoTop())
	oExcel:AddRow(cFld312,cFld31t2,{cFilAnt,"","",nTVlCont,nTVlBase,nTVlICMS,nTVlIsen,nTVlOutr,nTVlDesc,nTVlIPI})
	oExcel:AddRow(cFld312,cFld31t2,{"","","","","","","","","",""})
	oExcel:AddRow(cFld312,cFld31t2,{"","","","","","","","","",""})
	oExcel:AddRow(cFld312,cFld31t2,{cFilAnt,"TOTAL GERAL","",nTTCont,nTTBase,nTTICMS,nTTIsen,nTTOutr,nTTDesc,nTTIPI})
Return

/*/{Protheus.doc} Static Function GEx31P3
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx31P3()
	//
	(cAlB31Nf)->(dbGoTop())
	While !(cAlB31Nf)->(Eof())
		IF Substr((cAlB31Nf)->CFOP,1,1) >= '5'
			oExcel:AddRow(cFld313,cFld31t3,{(cAlB31Nf)->FILIAL,;
																			(cAlB31Nf)->NFSERIE,;
																			(cAlB31Nf)->NFISCAL,;
																			(cAlB31Nf)->DTENTRADA,;
																			(cAlB31Nf)->DTEMISSAO,;
																			(cAlB31Nf)->CLIEFOR,;
																			(cAlB31Nf)->LOJA,;
																			(cAlB31Nf)->NOME,;
																			(cAlB31Nf)->CFOP,;
																			(cAlB31Nf)->VALCONT,;
																			(cAlB31Nf)->BASEICMS,;
																			(cAlB31Nf)->ALIQICM,;
																			(cAlB31Nf)->VALICMS,;
																			(cAlB31Nf)->ISENTO,;
																			(cAlB31Nf)->OUTRAS,;
																			(cAlB31Nf)->VERIFIC,;
																			(cAlB31Nf)->VALIPI,;
																			(cAlB31Nf)->ICMSRET,;
																			(cAlB31Nf)->ICMSCOM,;
																			(cAlB31Nf)->ESTADO,;
																			(cAlB31Nf)->CODRSEF,;
																			(cAlB31Nf)->FORMUL})
		ENDIF
		(cAlB31Nf)->(dbSkip())
	ENDDO
	(cAlB31Nf)->(dbGoTop())
	oExcel:AddRow(cFld313,cFld31t3,{"","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function GEx31P4
	Gera Relatório Ref. Apuração ICMS Modelo GO
	@author Abel Babini Filho
	@since 28/01/2020
	@version 01
	/*/
Static Function GEx31P4()
	//
	(cAlB31Nf)->(dbGoTop())
	While !(cAlB31Nf)->(Eof())
		IF Substr((cAlB31Nf)->CFOP,1,1) < '5'
			oExcel:AddRow(cFld314,cFld31t4,{(cAlB31Nf)->FILIAL,;
																			(cAlB31Nf)->NFSERIE,;
																			(cAlB31Nf)->NFISCAL,;
																			(cAlB31Nf)->DTENTRADA,;
																			(cAlB31Nf)->DTEMISSAO,;
																			(cAlB31Nf)->CLIEFOR,;
																			(cAlB31Nf)->LOJA,;
																			(cAlB31Nf)->NOME,;
																			(cAlB31Nf)->CFOP,;
																			(cAlB31Nf)->VALCONT,;
																			(cAlB31Nf)->BASEICMS,;
																			(cAlB31Nf)->ALIQICM,;
																			(cAlB31Nf)->VALICMS,;
																			(cAlB31Nf)->ISENTO,;
																			(cAlB31Nf)->OUTRAS,;
																			(cAlB31Nf)->VERIFIC,;
																			(cAlB31Nf)->VALIPI,;
																			(cAlB31Nf)->ICMSRET,;
																			(cAlB31Nf)->ICMSCOM,;
																			(cAlB31Nf)->ESTADO,;
																			(cAlB31Nf)->CODRSEF,;
																			(cAlB31Nf)->FORMUL})
		ENDIF
		(cAlB31Nf)->(dbSkip())
	ENDDO
	(cAlB31Nf)->(dbGoTop())
	oExcel:AddRow(cFld314,cFld31t4,{"","","","","","","","","","","","","","","","","","","","","",""})
Return
//FIM Chamado n.055548 - OS n.058176 - Abel Babini - 27/03/2020 - Painel Fiscal ICMS GO - Ajustes na Apuração de ICMS GO

/*/{Protheus.doc} Static Function xABrw32
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xABrw32
	If Select(cAlB32Br) > 0
		(cAlB32Br)->(dbCloseArea())
	Endif
	cAlB32Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T32NFSER)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T32NFSER)
	oAlB32D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB32Br, _aFields, _aIndex) 

	If Select(cAlB32Dt) > 0
		(cAlB32Dt)->(dbCloseArea())
	Endif
	cAlB32Dt:=GetNextAlias()

	BeginSQL  Alias cAlB32Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_ENTRADA	AS DTENTRADA,
			SFT.FT_EMISSAO	AS DTEMISSAO,
			SFT.FT_SERIE		AS NFSERIE,
			SFT.FT_NFISCAL	AS NF,
			SFT.FT_ITEM			AS NFITEM,
			SFT.FT_CLIEFOR	AS CLIEFOR,
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,
			SFT.FT_PRODUTO	AS CODPROD,
			SB1.B1_DESC		AS DESCPROD,
			SFT.FT_POSIPI	AS NCM,
			SFT.FT_CFOP 	AS CFOP,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT	AS PRCUNIT,
			SFT.FT_VALCONT	AS VLCONT,
			SFT.FT_VALICM		AS VLICMS,
			SFT.R_E_C_N_O_ AS R_E_C_N_O_
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA2.%notDel%
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_TES IN %Exp:_cTESNFS%
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel%			
	EndSQL
//AND SFT.FT_CFOP IN %Exp:_cCFVDFV%
//AND SFT.FT_VALICM > 0
//AND SFT.FT_POSIPI NOT IN %Exp:_cGraxar%
	DbSelectArea(cAlB32Dt)
	(cAlB32Dt)->(DbGoTop())
	While !(cAlB32Dt)->(eof())

		RECLOCK(cAlB32Br,.T.)
			(cAlB32Br)->FILIAL 		:= (cAlB32Dt)->FILIAL
			(cAlB32Br)->DTENTRADA := (cAlB32Dt)->DTENTRADA
			(cAlB32Br)->DTEMISSAO := (cAlB32Dt)->DTEMISSAO
			(cAlB32Br)->NFSERIE 	:= (cAlB32Dt)->NFSERIE
			(cAlB32Br)->NF 				:= (cAlB32Dt)->NF
			(cAlB32Br)->NFITEM 		:= (cAlB32Dt)->NFITEM
			(cAlB32Br)->CLIEFOR 	:= (cAlB32Dt)->CLIEFOR
			(cAlB32Br)->NOME 			:= (cAlB32Dt)->NOME
			(cAlB32Br)->CNPJ 			:= (cAlB32Dt)->CNPJ
			(cAlB32Br)->LOJA 			:= (cAlB32Dt)->LOJA
			(cAlB32Br)->CFOP 			:= (cAlB32Dt)->CFOP
			(cAlB32Br)->CODPROD 	:= (cAlB32Dt)->CODPROD
			(cAlB32Br)->DESCPROD 	:= (cAlB32Dt)->DESCPROD
			(cAlB32Br)->NCM 			:= (cAlB32Dt)->NCM
			(cAlB32Br)->QUANT 		:= (cAlB32Dt)->QUANT
			(cAlB32Br)->PRCUNIT 	:= (cAlB32Dt)->PRCUNIT
			(cAlB32Br)->VLCONT 		:= (cAlB32Dt)->VLCONT
			(cAlB32Br)->VLICMS 		:= (cAlB32Dt)->VLICMS
		MSUNLOCK()	
		nVNFS += (cAlB32Dt)->VLICMS

		IF Alltrim((cAlB32Dt)->CODPROD) $ _cMVPMIL
			nVMILHO	+= (cAlB32Dt)->VLCONT
		ELSEIF Alltrim((cAlB32Dt)->CODPROD) $ _cMVPSOR
			nVSORGO += (cAlB32Dt)->VLCONT
		ELSEIF Alltrim((cAlB32Dt)->CODPROD) $ _cMVPPRO
			nVPROTE += (cAlB32Dt)->VLCONT
		ENDIF
		(cAlB32Dt)->(DbSkip())
	EndDo

	(cAlB32Br)->(dbGoTop())
	(cAlB32Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr32
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xRelBr32()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Conferência NFS" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr32b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr32b
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xRelBr32b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RCONFNFS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab32P1()
		GEx32P1()

		//Planilha1 - Detalhes
		Cab32P2()
		GEx32P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab32P1
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab32P1()
	oExcel:AddworkSheet(cFld301)
	oExcel:AddTable(cFld301,cFld30t1)
	oExcel:AddColumn(cFld301,cFld30t1,"Filial",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"Código",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"Produto",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"NCM",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"CFOP",1,1)
	oExcel:AddColumn(cFld301,cFld30t1,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld301,cFld30t1,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx32P1
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx32P1()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''
	Local nVlCont		:= 0
	Local nVlICMS		:= 0
	//
	(cAlB32Br)->(dbSetOrder(2))
	(cAlB32Br)->(dbGoTop())
	While !(cAlB32Br)->(Eof())
		IF ( (cAlB32Br)->CFOP <> cCFOPAux .or. (cAlB32Br)->CODPROD <> cProdAux) .and. cCFOPAux <> ''
			oExcel:AddRow(cFld301,cFld30t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
		ENDIF

		nVlCont		+= (cAlB32Br)->VLCONT
		nVlICMS		+= (cAlB32Br)->VLICMS
		cProdAux	:= (cAlB32Br)->CODPROD
		cDPrdAux	:= (cAlB32Br)->DESCPROD
		cNCMAux		:= (cAlB32Br)->NCM
		cCFOPAux	:= (cAlB32Br)->CFOP
		(cAlB32Br)->(dbSkip())
	ENDDO
	oExcel:AddRow(cFld301,cFld30t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})

	(cAlB32Br)->(dbSetOrder(1))
	(cAlB32Br)->(dbGoTop())

	oExcel:AddRow(cFld301,cFld30t1,{"","","","","","",""})
Return

/*/{Protheus.doc} Static Function Cab32P2
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function Cab32P2()
	oExcel:AddworkSheet(cFld302)
	oExcel:AddTable(cFld302,cFld30t2)
	oExcel:AddColumn(cFld302,cFld30t2,"Filial",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Série",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Item",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Cod.Cliente",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Loja Cliente",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Cliente",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"CNPJ",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"CFOP",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Produto",1,1)
	oExcel:AddColumn(cFld302,cFld30t2,"Quant.",2,2)
	oExcel:AddColumn(cFld302,cFld30t2,"Preço Unit.",2,3)
	oExcel:AddColumn(cFld302,cFld30t2,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld302,cFld30t2,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx32P2
	Gera Relatório Ref. Conferência NF Serviço
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx32P2()
	//
	(cAlB32Br)->(dbGoTop())
	While !(cAlB32Br)->(Eof())
		oExcel:AddRow(cFld302,cFld30t2,{(cAlB32Br)->FILIAL,;
																		(cAlB32Br)->DTENTRADA,;
																		(cAlB32Br)->DTEMISSAO,;
																		(cAlB32Br)->NFSERIE,;
																		(cAlB32Br)->NF,;
																		(cAlB32Br)->NFITEM,;
																		(cAlB32Br)->CLIEFOR,;
																		(cAlB32Br)->LOJA,;
																		(cAlB32Br)->NOME,;
																		(cAlB32Br)->CNPJ,;
																		(cAlB32Br)->CFOP,;
																		(cAlB32Br)->CODPROD,;
																		(cAlB32Br)->DESCPROD,;
																		(cAlB32Br)->QUANT,;
																		(cAlB32Br)->PRCUNIT,;
																		(cAlB32Br)->VLCONT,;
																		(cAlB32Br)->VLICMS})
		(cAlB32Br)->(dbSkip())
	ENDDO
	(cAlB32Br)->(dbGoTop())
	oExcel:AddRow(cFld302,cFld30t2,{"","","","","","","","","","","","","","","","",""})
Return

//INICIO Chamado n.040935 - OS n.042015 - Abel Babini - 03/04/2020 - Rel. Resumo Ceres - Entradas e Saidas por produto 
/*/{Protheus.doc} Static Function xABrw33
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xABrw33
	If Select(cAlB33Br) > 0
		(cAlB33Br)->(dbCloseArea())
	Endif
	cAlB33Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T33ENTSA)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T33ENTSA)
	oAlB33D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB33Br, _aFields, _aIndex) 

	If Select(cAlB33Dt) > 0
		(cAlB33Dt)->(dbCloseArea())
	Endif
	cAlB33Dt:=GetNextAlias()

	BeginSQL  Alias cAlB33Dt
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_CFOP 	AS CFOP,
			SFT.FT_PRODUTO	AS CODPROD,
			SB1.B1_DESC		AS DESCPROD,
			SFT.FT_POSIPI	AS NCM,
			SUM(SFT.FT_QUANT)		AS QUANT,
			SUM(SFT.FT_VALCONT)	AS VLCONT,
			SUM(SFT.FT_VALICM)		AS VLICMS
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_DTCANC = ''
			AND SFT.FT_CFOP NOT IN %Exp:_cInCfES%
			AND SFT.FT_ESPECIE NOT IN %Exp:_cInTPES% 
			AND SFT.%notDel%			
		GROUP BY SFT.FT_FILIAL, SFT.FT_CFOP, SFT.FT_PRODUTO, SB1.B1_DESC, SFT.FT_POSIPI
	EndSQL
//AND SFT.FT_TES IN %Exp:_cTESNFS%
//AND SFT.FT_CFOP IN %Exp:_cCFVDFV%
//AND SFT.FT_VALICM > 0
//AND SFT.FT_POSIPI NOT IN %Exp:_cGraxar%
	DbSelectArea(cAlB33Dt)
	(cAlB33Dt)->(DbGoTop())
	While !(cAlB33Dt)->(eof())
		//Condição para identificar Bonificação de pintos de 1 dia macho / fêmea
		IF cEmpAnt == '07' .AND. Alltrim((cAlB33Dt)->CFOP) $ _cCfBoni .AND. alltrim((cAlB33Dt)->CODPROD) $ _cPrBoni
			_nVlBoni += (cAlB33Dt)->VLICMS
		ENDIF

		RECLOCK(cAlB33Br,.T.)
			(cAlB33Br)->FILIAL 		:= (cAlB33Dt)->FILIAL
			(cAlB33Br)->CFOP 			:= (cAlB33Dt)->CFOP
			(cAlB33Br)->CODPROD 	:= (cAlB33Dt)->CODPROD
			(cAlB33Br)->DESCPROD 	:= (cAlB33Dt)->DESCPROD
			(cAlB33Br)->NCM 			:= (cAlB33Dt)->NCM
			(cAlB33Br)->QUANT 		:= (cAlB33Dt)->QUANT
			(cAlB33Br)->VLCONT 		:= (cAlB33Dt)->VLCONT
			(cAlB33Br)->VLICMS 		:= (cAlB33Dt)->VLICMS
		MSUNLOCK()	

		(cAlB33Dt)->(DbSkip())
	EndDo

	(cAlB33Br)->(dbGoTop())
	(cAlB33Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr33
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function xRelBr33()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Entradas e Saídas por CFOP e Produto" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr33b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr33b
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function xRelBr33b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RENTSAICFPR_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab33P1()
		GEx33P1()

		//Planilha1 - Detalhes
		Cab33P2()
		GEx33P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab33P1
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 02/03/2020
	@version 01
	/*/
Static Function Cab33P1()
	oExcel:AddworkSheet(cFld331)
	oExcel:AddTable(cFld331,cFld33t1)
	oExcel:AddColumn(cFld331,cFld33t1,"Filial",1,1)
	oExcel:AddColumn(cFld331,cFld33t1,"Código",1,1)
	oExcel:AddColumn(cFld331,cFld33t1,"Produto",1,1)
	oExcel:AddColumn(cFld331,cFld33t1,"NCM",1,1)
	oExcel:AddColumn(cFld331,cFld33t1,"CFOP",1,1)
	oExcel:AddColumn(cFld331,cFld33t1,"Quant.",2,2)
	oExcel:AddColumn(cFld331,cFld33t1,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld331,cFld33t1,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx33P1
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx33P1()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''

	Local nQuant		:= 0
	Local nVlCont		:= 0
	Local nVlICMS		:= 0
	
	Local nTQuant		:= 0
	Local nTVlCont	:= 0
	Local nTVlICMS	:= 0

	Local nGQuant		:= 0
	Local nGVlCont	:= 0
	Local nGVlICMS	:= 0
	//
	//(cAlB33Br)->(dbSetOrder(2))
	(cAlB33Br)->(dbSeek(cFilAnt+'1000',.t.))
	While !(cAlB33Br)->(Eof()) .AND. (cAlB33Br)->CFOP < '5000'
		IF ( (cAlB33Br)->CODPROD <> cProdAux) .and. cCFOPAux <> ''
			oExcel:AddRow(cFld331,cFld33t1,{cFilAnt, cCFOPAux, cProdAux, cDPrdAux, cNCMAux, nQuant, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
			nQuant		:= 0
		ENDIF

		IF (cAlB33Br)->CFOP <> cCFOPAux .and. cCFOPAux <> ''
			oExcel:AddRow(cFld331,cFld33t1,{cFilAnt, cCFOPAux, '', '', '', nTQuant, nTVlCont, nTVlICMS})
			oExcel:AddRow(cFld331,cFld33t1,{"","","","","","","",""})

			nTVlCont	:= 0
			nTVlICMS	:= 0
			nTQuant		:= 0
		ENDIF

		nVlCont		+= (cAlB33Br)->VLCONT
		nVlICMS		+= (cAlB33Br)->VLICMS
		nQuant		+= (cAlB33Br)->QUANT

		nTVlCont	+= (cAlB33Br)->VLCONT
		nTVlICMS	+= (cAlB33Br)->VLICMS
		nTQuant		+= (cAlB33Br)->QUANT

		nGVlCont	+= (cAlB33Br)->VLCONT
		nGVlICMS	+= (cAlB33Br)->VLICMS
		nGQuant		+= (cAlB33Br)->QUANT

		cProdAux	:= (cAlB33Br)->CODPROD
		cDPrdAux	:= (cAlB33Br)->DESCPROD
		cNCMAux		:= (cAlB33Br)->NCM
		cCFOPAux	:= (cAlB33Br)->CFOP
		(cAlB33Br)->(dbSkip())
	ENDDO
	IF nGVlCont > 0 .or. nGVlICMS > 0 .or. nGQuant > 0
		oExcel:AddRow(cFld331,cFld33t1,{cFilAnt, cCFOPAux, cProdAux, cDPrdAux, cNCMAux, nQuant, nVlCont, nVlICMS})
		oExcel:AddRow(cFld331,cFld33t1,{cFilAnt, cCFOPAux, '', '', '', nTQuant, nTVlCont, nTVlICMS})
		oExcel:AddRow(cFld331,cFld33t1,{"","","","","","","",""})
		oExcel:AddRow(cFld331,cFld33t1,{cFilAnt, cCFOPAux, '', '', '', nGQuant, nGVlCont, nGVlICMS})
	ENDIF
	(cAlB33Br)->(dbGoTop())

	oExcel:AddRow(cFld331,cFld33t1,{"","","","","","","",""})
Return

/*/{Protheus.doc} Static Function Cab33P2
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function Cab33P2()
	oExcel:AddworkSheet(cFld332)
	oExcel:AddTable(cFld332,cFld33t2)
	oExcel:AddColumn(cFld332,cFld33t2,"Filial",1,1)
	oExcel:AddColumn(cFld332,cFld33t2,"Código",1,1)
	oExcel:AddColumn(cFld332,cFld33t2,"Produto",1,1)
	oExcel:AddColumn(cFld332,cFld33t2,"NCM",1,1)
	oExcel:AddColumn(cFld332,cFld33t2,"CFOP",1,1)
	oExcel:AddColumn(cFld332,cFld33t2,"Quant.",2,2)
	oExcel:AddColumn(cFld332,cFld33t2,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld332,cFld33t2,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx33P2
	Gera Relatório Ref. Rel. Resumo Ceres - Entradas e Saidas por produto 
	@author Abel Babini Filho
	@since 09/03/2020
	@version 01
	/*/
Static Function GEx33P2()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''

	Local nQuant		:= 0
	Local nVlCont		:= 0
	Local nVlICMS		:= 0
	
	Local nTQuant		:= 0
	Local nTVlCont	:= 0
	Local nTVlICMS	:= 0

	Local nGQuant		:= 0
	Local nGVlCont	:= 0
	Local nGVlICMS	:= 0
	//
	//(cAlB33Br)->(dbSetOrder(2))
	(cAlB33Br)->(dbSeek(cFilAnt+'5000',.t.))
	While !(cAlB33Br)->(Eof()) .AND. (cAlB33Br)->CFOP > '5000'
		IF ( (cAlB33Br)->CODPROD <> cProdAux) .and. cCFOPAux <> ''
			oExcel:AddRow(cFld332,cFld33t2,{cFilAnt, cCFOPAux, cProdAux, cDPrdAux, cNCMAux, nQuant, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
			nQuant		:= 0
		ENDIF

		IF (cAlB33Br)->CFOP <> cCFOPAux .and. cCFOPAux <> ''
			oExcel:AddRow(cFld332,cFld33t2,{cFilAnt, cCFOPAux, '', '', '', nTQuant, nTVlCont, nTVlICMS})
			oExcel:AddRow(cFld332,cFld33t2,{"","","","","","","",""})

			nTVlCont	:= 0
			nTVlICMS	:= 0
			nTQuant		:= 0
		ENDIF

		nVlCont		+= (cAlB33Br)->VLCONT
		nVlICMS		+= (cAlB33Br)->VLICMS
		nQuant		+= (cAlB33Br)->QUANT

		nTVlCont	+= (cAlB33Br)->VLCONT
		nTVlICMS	+= (cAlB33Br)->VLICMS
		nTQuant		+= (cAlB33Br)->QUANT

		nGVlCont	+= (cAlB33Br)->VLCONT
		nGVlICMS	+= (cAlB33Br)->VLICMS
		nGQuant		+= (cAlB33Br)->QUANT

		cProdAux	:= (cAlB33Br)->CODPROD
		cDPrdAux	:= (cAlB33Br)->DESCPROD
		cNCMAux		:= (cAlB33Br)->NCM
		cCFOPAux	:= (cAlB33Br)->CFOP
		(cAlB33Br)->(dbSkip())
	ENDDO
	IF nGVlCont > 0 .or. nGVlICMS > 0 .or. nGQuant > 0
		oExcel:AddRow(cFld332,cFld33t2,{cFilAnt, cCFOPAux, cProdAux, cDPrdAux, cNCMAux, nQuant, nVlCont, nVlICMS})
		oExcel:AddRow(cFld332,cFld33t2,{cFilAnt, cCFOPAux, '', '', '', nTQuant, nTVlCont, nTVlICMS})
		oExcel:AddRow(cFld332,cFld33t2,{"","","","","","","",""})
		oExcel:AddRow(cFld332,cFld33t2,{cFilAnt, cCFOPAux, '', '', '', nGQuant, nGVlCont, nGVlICMS})
	ENDIF
	(cAlB33Br)->(dbGoTop())

	oExcel:AddRow(cFld332,cFld33t2,{"","","","","","","",""})
Return
//FIM Chamado n.040935 - OS n.042015 - Abel Babini - 03/04/2020 - Rel. Resumo Ceres - Entradas e Saidas por produto

//INICIO Chamado n.040935 - OS n.042015 - Abel Babini - 19/05/2020 - Rel. Resumo Ceres - Entradas e Saidas por produto
/*/{Protheus.doc} Static Function xABrw34
	Gera Relatório Ref. Dev. Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function xABrw34
	If Select(cAlB34Br) > 0
		(cAlB34Br)->(dbCloseArea())
	Endif
	cAlB34Br:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T30VENFV)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T30VENFV)
	oAlB34D1	:= StaticCall(ADFIS028R,CriaTmpT, cAlB34Br, _aFields, _aIndex) 

	If Select(cAlB34Dt) > 0
		(cAlB34Dt)->(dbCloseArea())
	Endif
	cAlB34Dt:=GetNextAlias()

	BeginSQL  Alias cAlB34Dt
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_ENTRADA	AS DTENTRADA,
			SFT.FT_EMISSAO	AS DTEMISSAO,
			SFT.FT_SERIE		AS NFSERIE,
			SFT.FT_NFISCAL	AS NF,
			SFT.FT_ITEM			AS NFITEM,
			SFT.FT_CLIEFOR	AS CLIEFOR,
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,
			SFT.FT_PRODUTO	AS CODPROD,
			SB1.B1_DESC		AS DESCPROD,
			SFT.FT_POSIPI	AS NCM,
			SFT.FT_CFOP 	AS CFOP,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT	AS PRCUNIT,
			SFT.FT_VALCONT	AS VLCONT,
			SFT.FT_VALICM		AS VLICMS,
			SFT.R_E_C_N_O_ AS R_E_C_N_O_
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA2.%notDel%
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_CFOP IN %Exp:_cCFDVVD%
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel%			
	EndSQL
//AND SFT.FT_VALICM > 0
//AND SFT.FT_POSIPI NOT IN %Exp:_cGraxar%
	DbSelectArea(cAlB34Dt)
	(cAlB34Dt)->(DbGoTop())
	While !(cAlB34Dt)->(eof())

		RECLOCK(cAlB34Br,.T.)
			(cAlB34Br)->FILIAL 		:= (cAlB34Dt)->FILIAL
			(cAlB34Br)->DTENTRADA := (cAlB34Dt)->DTENTRADA
			(cAlB34Br)->DTEMISSAO := (cAlB34Dt)->DTEMISSAO
			(cAlB34Br)->NFSERIE 	:= (cAlB34Dt)->NFSERIE
			(cAlB34Br)->NF 				:= (cAlB34Dt)->NF
			(cAlB34Br)->NFITEM 		:= (cAlB34Dt)->NFITEM
			(cAlB34Br)->CLIEFOR 	:= (cAlB34Dt)->CLIEFOR
			(cAlB34Br)->NOME 			:= (cAlB34Dt)->NOME
			(cAlB34Br)->CNPJ 			:= (cAlB34Dt)->CNPJ
			(cAlB34Br)->LOJA 			:= (cAlB34Dt)->LOJA
			(cAlB34Br)->CFOP 			:= (cAlB34Dt)->CFOP
			(cAlB34Br)->CODPROD 	:= (cAlB34Dt)->CODPROD
			(cAlB34Br)->DESCPROD 	:= (cAlB34Dt)->DESCPROD
			(cAlB34Br)->NCM 			:= (cAlB34Dt)->NCM
			(cAlB34Br)->QUANT 		:= (cAlB34Dt)->QUANT
			(cAlB34Br)->PRCUNIT 	:= (cAlB34Dt)->PRCUNIT
			(cAlB34Br)->VLCONT 		:= (cAlB34Dt)->VLCONT
			(cAlB34Br)->VLICMS 		:= (cAlB34Dt)->VLICMS
		MSUNLOCK()	
		nVDVVen += (cAlB34Dt)->VLICMS
		(cAlB34Dt)->(DbSkip())
	EndDo

	(cAlB34Br)->(dbGoTop())
	(cAlB34Dt)->(dbCloseArea())	

Return

/*/{Protheus.doc} Static Function xRelBr34
	Gera Relatório Ref. Devolução Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function xRelBr34()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Devolução de Vendas" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr34b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr34b
	Gera Relatório Ref. Devolução Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function xRelBr34b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RDEVOLVENDAS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab34P1()
		GEx34P1()

		//Planilha1 - Detalhes
		Cab34P2()
		GEx34P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab34P1
	Gera Relatório Ref. Devolução Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function Cab34P1()
	oExcel:AddworkSheet(cFld341)
	oExcel:AddTable(cFld341,cFld34t1)
	oExcel:AddColumn(cFld341,cFld34t1,"Filial",1,1)
	oExcel:AddColumn(cFld341,cFld34t1,"Código",1,1)
	oExcel:AddColumn(cFld341,cFld34t1,"Produto",1,1)
	oExcel:AddColumn(cFld341,cFld34t1,"NCM",1,1)
	oExcel:AddColumn(cFld341,cFld34t1,"CFOP",1,1)
	oExcel:AddColumn(cFld341,cFld34t1,"Vl. Cont.",2,3)
	oExcel:AddColumn(cFld341,cFld34t1,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx34P1
	Gera Relatório Ref. Devolução Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function GEx34P1()
	Local cProdAux	:= ''
	Local cDPrdAux	:= ''
	Local cNCMAux		:= ''
	Local cCFOPAux	:= ''
	Local nVlCont		:= 0
	Local nVlICMS		:= 0
	//
	(cAlB34Br)->(dbSetOrder(2))
	(cAlB34Br)->(dbGoTop())
	While !(cAlB34Br)->(Eof())
		IF ( (cAlB34Br)->CFOP <> cCFOPAux .or. (cAlB34Br)->CODPROD <> cProdAux) .and. cCFOPAux <> ''
			oExcel:AddRow(cFld341,cFld34t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})
			nVlCont		:= 0
			nVlICMS		:= 0
		ENDIF

		nVlCont		+= (cAlB34Br)->VLCONT
		nVlICMS		+= (cAlB34Br)->VLICMS
		cProdAux	:= (cAlB34Br)->CODPROD
		cDPrdAux	:= (cAlB34Br)->DESCPROD
		cNCMAux		:= (cAlB34Br)->NCM
		cCFOPAux	:= (cAlB34Br)->CFOP
		(cAlB34Br)->(dbSkip())
	ENDDO
	oExcel:AddRow(cFld341,cFld34t1,{cFilAnt, cProdAux, cDPrdAux, cNCMAux, cCFOPAux, nVlCont, nVlICMS})

	(cAlB34Br)->(dbSetOrder(1))
	(cAlB34Br)->(dbGoTop())

	oExcel:AddRow(cFld341,cFld34t1,{"","","","","","",""})
Return

/*/{Protheus.doc} Static Function Cab34P2
	Gera Relatório Ref. Devolução Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function Cab34P2()
	oExcel:AddworkSheet(cFld342)
	oExcel:AddTable(cFld342,cFld34t2)
	oExcel:AddColumn(cFld342,cFld34t2,"Filial",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Dt.Entrada",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Dt.Emissão",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Série",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Nota Fiscal",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Item",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Cod.Cliente",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Loja Cliente",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Cliente",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"CNPJ",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"CFOP",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Cod. Produto",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Produto",1,1)
	oExcel:AddColumn(cFld342,cFld34t2,"Quant.",2,2)
	oExcel:AddColumn(cFld342,cFld34t2,"Preço Unit.",2,3)
	oExcel:AddColumn(cFld342,cFld34t2,"Vl. Contábil",2,3)
	oExcel:AddColumn(cFld342,cFld34t2,"Vl. ICMS",2,3)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx34P2
	Gera Relatório Ref. Devolução Vendas
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function GEx34P2()
	//
	(cAlB34Br)->(dbGoTop())
	While !(cAlB34Br)->(Eof())
		oExcel:AddRow(cFld342,cFld34t2,{(cAlB34Br)->FILIAL,;
																		(cAlB34Br)->DTENTRADA,;
																		(cAlB34Br)->DTEMISSAO,;
																		(cAlB34Br)->NFSERIE,;
																		(cAlB34Br)->NF,;
																		(cAlB34Br)->NFITEM,;
																		(cAlB34Br)->CLIEFOR,;
																		(cAlB34Br)->LOJA,;
																		(cAlB34Br)->NOME,;
																		(cAlB34Br)->CNPJ,;
																		(cAlB34Br)->CFOP,;
																		(cAlB34Br)->CODPROD,;
																		(cAlB34Br)->DESCPROD,;
																		(cAlB34Br)->QUANT,;
																		(cAlB34Br)->PRCUNIT,;
																		(cAlB34Br)->VLCONT,;
																		(cAlB34Br)->VLICMS})
		(cAlB34Br)->(dbSkip())
	ENDDO
	(cAlB34Br)->(dbGoTop())
	oExcel:AddRow(cFld342,cFld34t2,{"","","","","","","","","","","","","","","","",""})
Return
//FIM Chamado n.040935 - OS n.042015 - Abel Babini - 19/05/2020 - Rel. Resumo Ceres - Entradas e Saidas por produto

//INICIO Ticket 10535										- Abel Babini - 09/03/2021 - Criar relatório de conferência de faturamento por tipo de cliente e regime de apuração.
/*/{Protheus.doc} Static Function xABrw36
	Carrega da dados Ref. Conferência de Faturamento por Tipo de Cliente e Regime Tributário
	@type  Static Function
	@author Abel Babini Filho
	@since 09/03/2021
	@version 01
	/*/
Static Function xABrw36()
	Local nPCFO := 0
	Local nPNCM 
	Local _PNCM
	Local _PCFO
	Local lNCM := .F. 
	aBrw36Nc	:= {}
	aBrw36Cf	:= {}

	// If Select(cAlB36Rs) > 0
	// 	(cAlB36Rs)->(dbCloseArea())
	// Endif
	// cAlB36Rs:=GetNextAlias()

	// _aFields	:= StaticCall(ADFIS028R,CriaExtr,T36RESUM)
	// _aIndex		:= StaticCall(ADFIS028R,CriaInd,T36RESUM)
	// oAlB36Rs	:= StaticCall(ADFIS028R,CriaTmpT, cAlB36Rs, _aFields, _aIndex) 

	If Select(cAlB36Dt) > 0
		(cAlB36Dt)->(dbCloseArea())
	Endif
	cAlB36Dt:=GetNextAlias()

	_aFields	:= StaticCall(ADFIS028R,CriaExtr,T36DETAL)
	_aIndex		:= StaticCall(ADFIS028R,CriaInd,T36DETAL)
	oAlB36Dt	:= StaticCall(ADFIS028R,CriaTmpT, cAlB36Dt, _aFields, _aIndex) 


	If Select(cAlB36Qr) > 0
		(cAlB36Qr)->(dbCloseArea())
	Endif
	cAlB36Qr:=GetNextAlias()

	//Inicializa Variáveis
	aBrw36Rs	:= {}
	aBrw36Dt	:= {}

	BeginSQL  Alias cAlB36Qr
		column DTENTRADA as Date
		column DTEMISSAO as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_ENTRADA	AS DTENTRADA,
			SFT.FT_EMISSAO	AS DTEMISSAO,
			SFT.FT_SERIE		AS SERIE,
			SFT.FT_NFISCAL	AS NFISCAL,
			SFT.FT_ITEM			AS ITEM,
			SFT.FT_CLIEFOR	AS CLIEFOR,
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CNPJ,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_EST ELSE SA1.A1_EST END AS EST,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN (CASE WHEN SA2.A2_SIMPNAC = '1' THEN 'SIM' ELSE 'NÃO' END) ELSE (CASE WHEN SA1.A1_SIMPNAC = '1' THEN 'SIM' ELSE 'NÃO' END) END AS SIMPLESNAC,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_TIPO ELSE SA1.A1_TIPO END AS TIPOCLI,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_GRPTRIB ELSE SA1.A1_GRPTRIB END AS GRPTRCLI,
			SFT.FT_PRODUTO		AS CODPROD,
			SB1.B1_DESC			AS PRODUTO,
			SB1.B1_PICMRET			AS PICMRET,
			SB1.B1_PICM			AS PICM,
			SB1.B1_GRTRIB			AS GRTRIB,
			SB1.B1_TS				AS TESPADRAO,
			SB1.B1_XD65255 AS XD65255,
			SFT.FT_POSIPI		AS POSIPI,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT		AS PRCUNIT,
			SFT.FT_TOTAL		AS TOTAL,
			SFT.FT_VALCONT		AS VALCONT,
			SFT.FT_BASEICM		AS ICMSBASE,
			SFT.FT_ALIQICM		AS ICMSALIQ,
			SFT.FT_VALICM		AS ICMSVAL,
			SFT.FT_ICMSRET		AS ICMSRET,
			SFT.FT_OUTRICM		AS ICMSOUTR,
			SFT.FT_DESCONT		AS DESCONT,
			SFT.FT_SEGURO		AS SEGURO,
			SFT.FT_DESPESA		AS DESPESA,
			SFT.FT_FRETE		AS FRETE,
			SFT.FT_OBSERV		AS OBSERV,
			SFT.FT_TES			AS TES,
			SFT.FT_CFOP			AS CFOP,
			SFT.FT_TIPO			AS TIPO,
			SFT.FT_ESPECIE		AS ESPECIE
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA2.%notDel%
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_CFOP IN %Exp:_cINCFFT%
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel%
		ORDER BY SFT.FT_FILIAL, SFT.FT_CFOP
	EndSQL

	nVSNCTot := 0
	nVSNCIcm := 0
	nVOCTot  := 0
	nVOCIcm  := 0
	nVCFLTot := 0
	nVCFLIcm := 0
	nVTPCTot := 0
	nVTPCIcm := 0
	nQNCM36  := 0

	DbSelectArea(cAlB36Qr)
	(cAlB36Qr)->(DbGoTop())
	While !(cAlB36Qr)->(eof())

		lNCM := .F.
		For _PNCM = 1 to Len(aBrw36Nc)
			If Substr(Alltrim((cAlB36Qr)->POSIPI),1,4) == Alltrim(aBrw36Nc[_PNCM])
				lNCM := .T.
				Exit
			Endif
		Next _PNCM
		If !lNCM
			AADD(aBrw36Nc,Substr(Alltrim((cAlB36Qr)->POSIPI),1,4))
			nQNCM36 += 1
		Endif
		
		lCFO := .F.
		For _PCFO = 1 to Len(aBrw36Cf)
			If Alltrim((cAlB36Qr)->CFOP) == Alltrim(aBrw36Cf[_PCFO])
				lCFO := .T.
				Exit
			Endif
		Next _PCFO
		If !lCFO
			AADD(aBrw36Cf,Alltrim((cAlB36Qr)->CFOP))
			nQCFO36 += 1
		Endif

		RecLock(cAlB36Dt,.T.)
			(cAlB36Dt)->FILIAL		:= (cAlB36Qr)->FILIAL
			(cAlB36Dt)->DTENTRADA	:= (cAlB36Qr)->DTENTRADA
			(cAlB36Dt)->DTEMISSAO	:= (cAlB36Qr)->DTEMISSAO
			(cAlB36Dt)->NFSERIE		:= (cAlB36Qr)->SERIE
			(cAlB36Dt)->NF				:= (cAlB36Qr)->NFISCAL
			(cAlB36Dt)->NFITEM		:= (cAlB36Qr)->ITEM
			(cAlB36Dt)->CLIEFOR		:= (cAlB36Qr)->CLIEFOR
			(cAlB36Dt)->LOJA			:= (cAlB36Qr)->LOJA
			(cAlB36Dt)->NOME			:= (cAlB36Qr)->NOME
			(cAlB36Dt)->CNPJ			:= (cAlB36Qr)->CNPJ
			(cAlB36Dt)->EST				:= (cAlB36Qr)->EST
			(cAlB36Dt)->SIMPLESNAC:= (cAlB36Qr)->SIMPLESNAC
			(cAlB36Dt)->TIPOCLI		:= (cAlB36Qr)->TIPOCLI
			(cAlB36Dt)->GRPTRCLI	:= (cAlB36Qr)->GRPTRCLI
			(cAlB36Dt)->CODPROD		:= (cAlB36Qr)->CODPROD
			(cAlB36Dt)->DESCPROD	:= (cAlB36Qr)->PRODUTO
			(cAlB36Dt)->PICMRET		:= (cAlB36Qr)->PICMRET
			(cAlB36Dt)->PICM			:= (cAlB36Qr)->PICM
			(cAlB36Dt)->GRTRIB		:= (cAlB36Qr)->GRTRIB
			(cAlB36Dt)->TESPADRAO	:= (cAlB36Qr)->TESPADRAO
			(cAlB36Dt)->XD65255		:= (cAlB36Qr)->XD65255
			(cAlB36Dt)->NCM				:= (cAlB36Qr)->POSIPI
			(cAlB36Dt)->QUANT			:= (cAlB36Qr)->QUANT
			(cAlB36Dt)->PRCUNIT		:= (cAlB36Qr)->PRCUNIT
			(cAlB36Dt)->TOTAL			:= (cAlB36Qr)->TOTAL
			(cAlB36Dt)->VLCONT		:= (cAlB36Qr)->VALCONT
			(cAlB36Dt)->ICMSBASE	:= (cAlB36Qr)->ICMSBASE
			(cAlB36Dt)->ICMSALIQ	:= (cAlB36Qr)->ICMSALIQ
			(cAlB36Dt)->ICMSVAL		:= (cAlB36Qr)->ICMSVAL

			(cAlB36Dt)->CARGATRI	:= IIF((cAlB36Qr)->TOTAL > 0, Round((cAlB36Qr)->ICMSVAL / (cAlB36Qr)->TOTAL * 100,2), 0 )
			(cAlB36Dt)->CONFALQ		:= IIF((cAlB36Qr)->ICMSBASE > 0, Round((cAlB36Qr)->ICMSVAL / (cAlB36Qr)->ICMSBASE * 100,2), 0 )
			(cAlB36Dt)->CONFBASC	:= IIF((cAlB36Qr)->TOTAL > 0 .AND. (cAlB36Qr)->ICMSBASE > 0, Round(((cAlB36Qr)->ICMSVAL / (cAlB36Qr)->TOTAL) / ((cAlB36Qr)->ICMSVAL / (cAlB36Qr)->ICMSBASE) * 100,2), 0)

			(cAlB36Dt)->ICMSRET		:= (cAlB36Qr)->ICMSRET
			(cAlB36Dt)->ICMSOUTR	:= (cAlB36Qr)->ICMSOUTR
			(cAlB36Dt)->DESCONT		:= (cAlB36Qr)->DESCONT
			(cAlB36Dt)->SEGURO		:= (cAlB36Qr)->SEGURO
			(cAlB36Dt)->DESPESA		:= (cAlB36Qr)->DESPESA
			(cAlB36Dt)->FRETE			:= (cAlB36Qr)->FRETE
			(cAlB36Dt)->OBSERV		:= (cAlB36Qr)->OBSERV
			(cAlB36Dt)->TES				:= (cAlB36Qr)->TES
			(cAlB36Dt)->CFOP			:= (cAlB36Qr)->CFOP
			(cAlB36Dt)->TIPO			:= (cAlB36Qr)->TIPO
			(cAlB36Dt)->ESPECIE		:= (cAlB36Qr)->ESPECIE
		(cAlB36Dt)->(MsUnlock())

		(cAlB36Qr)->(DbSkip())
	EndDo

	ASORT(aBrw36Cf)
	ASORT(aBrw36Nc)
	aBrw36R1 := {}
	aBrw36R2 := {}
	aBrw36R3 := {}

	aBrw36R4 := {}
	aBrw36R5 := {}
	aBrw36R6 := {}

	//Monta Arrays para Browser
	aBrw36R1 := Array(nQCFO36,nQNCM36+3) // Cria o Array do tamanho necessário (Linha x Coluna), acrescentando 2 colunas para filial e o próprio CFOP, e mais uma para o total por CFOP
	aBrw36R2 := Array(nQCFO36,nQNCM36+3) // Cria o Array do tamanho necessário (Linha x Coluna), acrescentando 2 colunas para filial e o próprio CFOP, e mais uma para o total por CFOP
	aBrw36R3 := Array(nQCFO36,nQNCM36+3) // Cria o Array do tamanho necessário (Linha x Coluna), acrescentando 2 colunas para filial e o próprio CFOP, e mais uma para o total por CFOP

	aBrw36R4 := Array(nQCFO36,nQNCM36+3) // Cria o Array do tamanho necessário (Linha x Coluna), acrescentando 2 colunas para filial e o próprio CFOP, e mais uma para o total por CFOP
	aBrw36R5 := Array(nQCFO36,nQNCM36+3) // Cria o Array do tamanho necessário (Linha x Coluna), acrescentando 2 colunas para filial e o próprio CFOP, e mais uma para o total por CFOP
	aBrw36R6 := Array(nQCFO36,nQNCM36+3) // Cria o Array do tamanho necessário (Linha x Coluna), acrescentando 2 colunas para filial e o próprio CFOP, e mais uma para o total por CFOP

	//Inicializa Array
	For nPCFO := 1 to nQCFO36

		//Inicializa Campo Filial
		aBrw36R1[nPCFO,1]:= cFilAnt
		aBrw36R2[nPCFO,1]:= cFilAnt
		aBrw36R3[nPCFO,1]:= cFilAnt
		aBrw36R4[nPCFO,1]:= cFilAnt
		aBrw36R5[nPCFO,1]:= cFilAnt
		aBrw36R6[nPCFO,1]:= cFilAnt


		//Inicializa Campo CFOP
		aBrw36R1[nPCFO,2]:= aBrw36Cf[nPCFO]
		aBrw36R2[nPCFO,2]:= aBrw36Cf[nPCFO]
		aBrw36R3[nPCFO,2]:= aBrw36Cf[nPCFO]
		aBrw36R4[nPCFO,2]:= aBrw36Cf[nPCFO]
		aBrw36R5[nPCFO,2]:= aBrw36Cf[nPCFO]
		aBrw36R6[nPCFO,2]:= aBrw36Cf[nPCFO]

		//Campos de Valor Contábil inicializa com zero
		For nPNCM = 3 to nQNCM36+3
			aBrw36R1[nPCFO,nPNCM]:= 0
			aBrw36R2[nPCFO,nPNCM]:= 0
			aBrw36R3[nPCFO,nPNCM]:= 0
			aBrw36R4[nPCFO,nPNCM]:= 0
			aBrw36R5[nPCFO,nPNCM]:= 0
			aBrw36R6[nPCFO,nPNCM]:= 0
		Next nPNCM
	Next nPCFO

	(cAlB36Qr)->(DbGoTop())
	While !(cAlB36Qr)->(eof())
		nPCFO := ASCAN(aBrw36Cf,Alltrim((cAlB36Qr)->CFOP))
		nPNCM := ASCAN(aBrw36Nc,Substr(Alltrim((cAlB36Qr)->POSIPI),1,4))

		If nPCFO <> 0 .OR. nPNCM <> 0

		/*
		nVTPCTot += (cAlB36Qr)->TOTAL
		nVTPCIcm += (cAlB36Qr)->ICMSVAL
		*/
			IF (cAlB36Qr)->TIPOCLI == 'F' //CONSUMIDOR FINAL
				// aBrw36R1[nPCFO,1]		:= (cAlB36Qr)->FILIAL
				// aBrw36R1[nPCFO,2]		:= (cAlB36Qr)->CFOP
				aBrw36R1[nPCFO,nPNCM+2]	+= (cAlB36Qr)->VALCONT
				aBrw36R1[nPCFO,nQNCM36+3]	+= (cAlB36Qr)->VALCONT
				aBrw36R4[nPCFO,nPNCM+2]	+= (cAlB36Qr)->ICMSVAL
				aBrw36R4[nPCFO,nQNCM36+3]	+= (cAlB36Qr)->ICMSVAL
				nVCFLTot += (cAlB36Qr)->VALCONT
				nVCFLIcm += (cAlB36Qr)->ICMSVAL
			ELSEIF (cAlB36Qr)->SIMPLESNAC == 'SIM' //OPTANTE PELO SIMPLES NACIONAL
				// aBrw36R2[nPCFO,1]		:= (cAlB36Qr)->FILIAL
				// aBrw36R2[nPCFO,2]		:= (cAlB36Qr)->CFOP
				aBrw36R2[nPCFO,nPNCM+2]	+= (cAlB36Qr)->VALCONT
				aBrw36R2[nPCFO,nQNCM36+3]	+= (cAlB36Qr)->VALCONT
				aBrw36R5[nPCFO,nPNCM+2]	+= (cAlB36Qr)->ICMSVAL
				aBrw36R5[nPCFO,nQNCM36+3]	+= (cAlB36Qr)->ICMSVAL
				nVSNCTot += (cAlB36Qr)->VALCONT
				nVSNCIcm += (cAlB36Qr)->ICMSVAL
			ELSE
				// aBrw36R3[nPCFO,1]		:= (cAlB36Qr)->FILIAL
				// aBrw36R3[nPCFO,2]		:= (cAlB36Qr)->CFOP
				aBrw36R3[nPCFO,nPNCM+2]	+= (cAlB36Qr)->VALCONT
				aBrw36R3[nPCFO,nQNCM36+3]	+= (cAlB36Qr)->VALCONT
				aBrw36R6[nPCFO,nPNCM+2]	+= (cAlB36Qr)->ICMSVAL
				aBrw36R6[nPCFO,nQNCM36+3]	+= (cAlB36Qr)->ICMSVAL
				nVOCTot += (cAlB36Qr)->VALCONT
				nVOCIcm += (cAlB36Qr)->ICMSVAL
			ENDIF
		ENDIF

		(cAlB36Qr)->(DbSkip())
	EndDo

	(cAlB36Qr)->(dbCloseArea())
	SysRefresh()
Return

/*/{Protheus.doc} Static Function xRelBr36
	Gera Relatório Ref. Conferência de Faturamento
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function xRelBr36()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Devolução de Vendas" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({|| xRelBr36b() /*StaticCall(ADFIS038R,xRelBr28b)*/ },"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
	MsgInfo("Arquivo Excel gerado!")        
	
Return

/*/{Protheus.doc} Static Function xRelBr36b
	Gera Relatório Ref. Conferência de Faturamento
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function xRelBr36b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RCONFFATTPCLI_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE
		
		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//    Alert("Nao Existe Excel Instalado")
    //        BREAK
		//EndIF
        	
		//Planilha1 - Resumo
		Cab36P1()
		GEx36P1()

		//Planilha1 - Detalhes
		Cab36P2()
		GEx36P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)
	
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab36P1
	Gera Relatório Ref. Conferência de Faturamento
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function Cab36P1()
	Local nColBr36 := 0

	oExcel:AddworkSheet(cFld361)
	oExcel:AddTable(cFld361,cFld36t1)
	oExcel:AddColumn(cFld361,cFld36t1,"Categoria"	,1,1)
	oExcel:AddColumn(cFld361,cFld36t1,"Filial"	,1,1)
	oExcel:AddColumn(cFld361,cFld36t1,"CFOP"		,1,1)
	
	For nColBr36 := 1 To nQNCM36
		oExcel:AddColumn(cFld361,cFld36t1,aBrw36Nc[nColBr36]+' - Vl. Cont',2,2)
		oExcel:AddColumn(cFld361,cFld36t1,aBrw36Nc[nColBr36]+' - Vl. ICMS',2,2)
	Next nColBr36
	
	oExcel:AddColumn(cFld361,cFld36t1,"Total - Vl. Cont"	,2,2)
	oExcel:AddColumn(cFld361,cFld36t1,"Total - Vl. ICMS"	,2,2)
RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx36P1
	Gera Relatório Ref. Conferência de Faturamento
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function GEx36P1()
	Local aLinha := {}
	Local aLinhaTT := {}
	Local aLinhaBr := {}

	Local nColBr36 := 0
	Local i := 0
	Local j := 0
	Local aTotEstT := Array(nQNCM36)
	Local aTotEstI := Array(nQNCM36)
	Local nTotEstT := 0
	Local nTotEstI := 0

	Local aTotIntT := Array(nQNCM36)
	Local aTotIntI := Array(nQNCM36)
	Local nTotIntT := 0
	Local nTotIntI := 0

	Local aTotExpT := Array(nQNCM36)
	Local aTotExpI := Array(nQNCM36)
	Local nTotExpT := 0
	Local nTotExpI := 0

	Local nTotGerT := 0
	Local nTotGerI := 0

	Local lTotEst := .F.
	Local lTotInt := .F.
	Local lTotExp := .F.

	Local cGCFOP := ''

	//**************************************
	//Cliente Consumidor Final
	//**************************************
	For i:=1 to nQNCM36
		aTotEstT[i] := 0
		aTotIntT[i] := 0
		aTotExpT[i] := 0
		aTotEstI[i] := 0
		aTotIntI[i] := 0
		aTotExpI[i] := 0
	Next i

	aAdd(aLinha,"Cliente Consumidor Final")
	aAdd(aLinha,"")
	aAdd(aLinha,"")
	For nColBr36 := 1 To nQNCM36
		aAdd(aLinha,"")
		aAdd(aLinha,"")
	Next nColBr36
	aAdd(aLinha,"")
	aAdd(aLinha,"")
	oExcel:AddRow(cFld361,cFld36t1,aLinha)

	For i := 1 to len(aBrw36R1)

		aLinha := {}
		aAdd(aLinha,"")
		aAdd(aLinha,cFilAnt)
		aAdd(aLinha,aBrw36R1[i,2])
		For nColBr36 := 1 To nQNCM36
			aAdd(aLinha,aBrw36R1[i,nColBr36+2])
			aAdd(aLinha,aBrw36R4[i,nColBr36+2])

			IF Substr(Alltrim(aBrw36R1[i,2]),1,1) == '5'
				aTotEstT[nColBr36] += aBrw36R1[i,nColBr36+2]
				aTotEstI[nColBr36] += aBrw36R4[i,nColBr36+2]
			ELSEIF Substr(Alltrim(aBrw36R1[i,2]),1,1) == '6'
				aTotIntT[nColBr36] += aBrw36R1[i,nColBr36+2]
				aTotIntI[nColBr36] += aBrw36R4[i,nColBr36+2]
			ELSEIF Substr(Alltrim(aBrw36R1[i,2]),1,1) == '7'
				aTotExpT[nColBr36] += aBrw36R1[i,nColBr36+2]
				aTotExpI[nColBr36] += aBrw36R4[i,nColBr36+2]
			ENDIF

		Next nColBr36
		aAdd(aLinha,aBrw36R1[i,nQNCM36+3])
		aAdd(aLinha,aBrw36R4[i,nQNCM36+3])

		//IMPRIME TOTAL ESTADUAL
		IF (Substr(Alltrim(aBrw36R1[i,2]),1,1) == '6' .OR. Substr(Alltrim(aBrw36R1[i,2]),1,1) == '7') .AND. (i == 1 .OR. cGCFOP == '5')
			lTotEst := .T.
			aLinhaTT := {}
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"TOTAL ESTADUAL")
			For j := 1 To nQNCM36
				aAdd(aLinhaTT,aTotEstT[j])
				aAdd(aLinhaTT,aTotEstI[j])
				nTotEstT += aTotEstT[j]
				nTotEstI += aTotEstI[j]
			Next j
			aAdd(aLinhaTT,nTotEstT)
			aAdd(aLinhaTT,nTotEstI)
			oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
		ENDIF

		//IMPRIME TOTAL INTERESTADUAL
		IF Substr(Alltrim(aBrw36R1[i,2]),1,1) == '7' .AND. (i == 1 .OR. cGCFOP == '6' .OR. cGCFOP == '5')
			lTotInt := .T.
			aLinhaTT := {}
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"TOTAL INTERESTADUAL")
			For j := 1 To nQNCM36
				aAdd(aLinhaTT,aTotIntT[j])
				aAdd(aLinhaTT,aTotIntI[j])
				nTotIntT += aTotIntT[j]
				nTotIntI += aTotIntI[j]
			Next j
			aAdd(aLinhaTT,nTotEstT)
			aAdd(aLinhaTT,nTotEstI)
			oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
		ENDIF
		IF aBrw36R1[i,nQNCM36+3] > 0 .AND. aBrw36R4[i,nQNCM36+3] > 0
			oExcel:AddRow(cFld361,cFld36t1,aLinha)
		ENDIF
		
		cGCFOP := Substr(Alltrim(aBrw36R1[i,2]),1,1)
	Next i


	IF !lTotEst
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL ESTADUAL")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotEstT[j])
			aAdd(aLinhaTT,aTotEstI[j])
			nTotEstT += aTotEstT[j]
			nTotEstI += aTotEstI[j]
		Next j
		aAdd(aLinhaTT,nTotEstT)
		aAdd(aLinhaTT,nTotEstI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	IF !lTotInt
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL INTERESTADUAL")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotIntT[j])
			aAdd(aLinhaTT,aTotIntI[j])
			nTotIntT += aTotIntT[j]
			nTotIntI += aTotIntI[j]
		Next j
		aAdd(aLinhaTT,nTotIntT)
		aAdd(aLinhaTT,nTotIntI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	IF !lTotExp
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL EXPORTAÇÃO")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotExpT[j])
			aAdd(aLinhaTT,aTotExpI[j])
			nTotExpT += aTotExpT[j]
			nTotExpI += aTotExpI[j]
		Next j
		aAdd(aLinhaTT,nTotExpT)
		aAdd(aLinhaTT,nTotExpI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	aLinhaTT := {}
	aAdd(aLinhaTT,"Cliente Consumidor Final")
	aAdd(aLinhaTT,"")
	aAdd(aLinhaTT,"TOTAL")
	For j := 1 To nQNCM36
		aAdd(aLinhaTT,aTotEstT[j]+aTotIntT[j]+aTotExpT[j])
		aAdd(aLinhaTT,aTotEstI[j]+aTotIntI[j]+aTotExpI[j])
		nTotGerT += aTotEstT[j]+aTotIntT[j]+aTotExpT[j]
		nTotGerI += aTotEstI[j]+aTotIntI[j]+aTotExpI[j]
	Next j
	aAdd(aLinhaTT,nTotGerT)
	aAdd(aLinhaTT,nTotGerI)
	oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)

	//******************
	// Linha em Branco
	//******************
	aLinhaBr := {}
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	For j := 1 To nQNCM36
		aAdd(aLinhaBr,"")
		aAdd(aLinhaBr,"")
	Next j
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	oExcel:AddRow(cFld361,cFld36t1,aLinhaBr)


	//**************************************
	//Cliente Optante pelo Simples Nacional
	//**************************************
	aTotEstT := Array(nQNCM36)
	aTotEstI := Array(nQNCM36)
	nTotEstT := 0
	nTotEstI := 0

	aTotIntT := Array(nQNCM36)
	aTotIntI := Array(nQNCM36)
	nTotIntT := 0
	nTotIntI := 0

	aTotExpT := Array(nQNCM36)
	aTotExpI := Array(nQNCM36)
	nTotExpT := 0
	nTotExpI := 0

	nTotGerT := 0
	nTotGerI := 0

	lTotEst := .F.
	lTotInt := .F.
	lTotExp := .F.

	cGCFOP := ''
	aLinha := {}
	aLinhaTT := {}
	aLinhaBr := {}

	For i:=1 to nQNCM36
		aTotEstT[i] := 0
		aTotIntT[i] := 0
		aTotExpT[i] := 0
		aTotEstI[i] := 0
		aTotIntI[i] := 0
		aTotExpI[i] := 0
	Next i
	
	aAdd(aLinha,"Cliente Optante pelo Simples Nacional")
	aAdd(aLinha,"")
	aAdd(aLinha,"")
	For nColBr36 := 1 To nQNCM36
		aAdd(aLinha,"")
		aAdd(aLinha,"")
	Next nColBr36
	aAdd(aLinha,"")
	aAdd(aLinha,"")
	oExcel:AddRow(cFld361,cFld36t1,aLinha)

	For i := 1 to len(aBrw36R2)

		aLinha := {}
		aAdd(aLinha,"")
		aAdd(aLinha,cFilAnt)
		aAdd(aLinha,aBrw36R2[i,2])
		For nColBr36 := 1 To nQNCM36
			aAdd(aLinha,aBrw36R2[i,nColBr36+2])
			aAdd(aLinha,aBrw36R5[i,nColBr36+2])

			IF Substr(Alltrim(aBrw36R2[i,2]),1,1) == '5'
				aTotEstT[nColBr36] += aBrw36R2[i,nColBr36+2]
				aTotEstI[nColBr36] += aBrw36R5[i,nColBr36+2]
			ELSEIF Substr(Alltrim(aBrw36R2[i,2]),1,1) == '6'
				aTotIntT[nColBr36] += aBrw36R2[i,nColBr36+2]
				aTotIntI[nColBr36] += aBrw36R5[i,nColBr36+2]
			ELSEIF Substr(Alltrim(aBrw36R2[i,2]),1,1) == '7'
				aTotExpT[nColBr36] += aBrw36R2[i,nColBr36+2]
				aTotExpI[nColBr36] += aBrw36R5[i,nColBr36+2]
			ENDIF

		Next nColBr36
		aAdd(aLinha,aBrw36R2[i,nQNCM36+3])
		aAdd(aLinha,aBrw36R5[i,nQNCM36+3])

		//IMPRIME TOTAL ESTADUAL
		IF (Substr(Alltrim(aBrw36R2[i,2]),1,1) == '6' .OR. Substr(Alltrim(aBrw36R2[i,2]),1,1) == '7') .AND. (i == 1 .OR. cGCFOP == '5')
			lTotEst := .T.
			aLinhaTT := {}
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"TOTAL ESTADUAL")
			For j := 1 To nQNCM36
				aAdd(aLinhaTT,aTotEstT[j])
				aAdd(aLinhaTT,aTotEstI[j])
				nTotEstT += aTotEstT[j]
				nTotEstI += aTotEstI[j]
			Next j
			aAdd(aLinhaTT,nTotEstT)
			aAdd(aLinhaTT,nTotEstI)
			oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
		ENDIF

		//IMPRIME TOTAL INTERESTADUAL
		IF Substr(Alltrim(aBrw36R2[i,2]),1,1) == '7' .AND. (i == 1 .OR. cGCFOP == '6' .OR. cGCFOP == '5')
			lTotInt := .T.
			aLinhaTT := {}
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"TOTAL INTERESTADUAL")
			For j := 1 To nQNCM36
				aAdd(aLinhaTT,aTotIntT[j])
				aAdd(aLinhaTT,aTotIntI[j])
				nTotIntT += aTotIntT[j]
				nTotIntI += aTotIntI[j]
			Next j
			aAdd(aLinhaTT,nTotEstT)
			aAdd(aLinhaTT,nTotEstI)
			oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
		ENDIF
		IF aBrw36R2[i,nQNCM36+3] > 0 .AND. aBrw36R5[i,nQNCM36+3] > 0
			oExcel:AddRow(cFld361,cFld36t1,aLinha)
		ENDIF
		
		cGCFOP := Substr(Alltrim(aBrw36R2[i,2]),1,1)
	Next i


	IF !lTotEst
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL ESTADUAL")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotEstT[j])
			aAdd(aLinhaTT,aTotEstI[j])
			nTotEstT += aTotEstT[j]
			nTotEstI += aTotEstI[j]
		Next j
		aAdd(aLinhaTT,nTotEstT)
		aAdd(aLinhaTT,nTotEstI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	IF !lTotInt
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL INTERESTADUAL")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotIntT[j])
			aAdd(aLinhaTT,aTotIntI[j])
			nTotIntT += aTotIntT[j]
			nTotIntI += aTotIntI[j]
		Next j
		aAdd(aLinhaTT,nTotIntT)
		aAdd(aLinhaTT,nTotIntI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	IF !lTotExp
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL EXPORTAÇÃO")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotExpT[j])
			aAdd(aLinhaTT,aTotExpI[j])
			nTotExpT += aTotExpT[j]
			nTotExpI += aTotExpI[j]
		Next j
		aAdd(aLinhaTT,nTotExpT)
		aAdd(aLinhaTT,nTotExpI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	aLinhaTT := {}
	aAdd(aLinhaTT,"Cliente Optante pelo Simples Nacional")
	aAdd(aLinhaTT,"")
	aAdd(aLinhaTT,"TOTAL")
	For j := 1 To nQNCM36
		aAdd(aLinhaTT,aTotEstT[j]+aTotIntT[j]+aTotExpT[j])
		aAdd(aLinhaTT,aTotEstI[j]+aTotIntI[j]+aTotExpI[j])
		nTotGerT += aTotEstT[j]+aTotIntT[j]+aTotExpT[j]
		nTotGerI += aTotEstI[j]+aTotIntI[j]+aTotExpI[j]
	Next j
	aAdd(aLinhaTT,nTotGerT)
	aAdd(aLinhaTT,nTotGerI)
	oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)

	//******************
	// Linha em Branco
	//******************
	aLinhaBr := {}
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	For j := 1 To nQNCM36
		aAdd(aLinhaBr,"")
		aAdd(aLinhaBr,"")
	Next j
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	oExcel:AddRow(cFld361,cFld36t1,aLinhaBr)


	//**************************************
	//Cliente NÃO Optante pelo Simples ou Consumidor Final
	//**************************************
	aTotEstT := Array(nQNCM36)
	aTotEstI := Array(nQNCM36)
	nTotEstT := 0
	nTotEstI := 0

	aTotIntT := Array(nQNCM36)
	aTotIntI := Array(nQNCM36)
	nTotIntT := 0
	nTotIntI := 0

	aTotExpT := Array(nQNCM36)
	aTotExpI := Array(nQNCM36)
	nTotExpT := 0
	nTotExpI := 0

	nTotGerT := 0
	nTotGerI := 0

	lTotEst := .F.
	lTotInt := .F.
	lTotExp := .F.

	cGCFOP := ''
	aLinha := {}
	aLinhaTT := {}
	aLinhaBr := {}

	For i:=1 to nQNCM36
		aTotEstT[i] := 0
		aTotIntT[i] := 0
		aTotExpT[i] := 0
		aTotEstI[i] := 0
		aTotIntI[i] := 0
		aTotExpI[i] := 0
	Next i

	aAdd(aLinha,"Cliente NÃO Optante pelo Simples ou Consumidor Final")
	aAdd(aLinha,"")
	aAdd(aLinha,"")
	For nColBr36 := 1 To nQNCM36
		aAdd(aLinha,"")
		aAdd(aLinha,"")
	Next nColBr36
	aAdd(aLinha,"")
	aAdd(aLinha,"")
	oExcel:AddRow(cFld361,cFld36t1,aLinha)

	For i := 1 to len(aBrw36R3)

		aLinha := {}
		aAdd(aLinha,"")
		aAdd(aLinha,cFilAnt)
		aAdd(aLinha,aBrw36R3[i,2])
		For nColBr36 := 1 To nQNCM36
			aAdd(aLinha,aBrw36R3[i,nColBr36+2])
			aAdd(aLinha,aBrw36R6[i,nColBr36+2])

			IF Substr(Alltrim(aBrw36R3[i,2]),1,1) == '5'
				aTotEstT[nColBr36] += aBrw36R3[i,nColBr36+2]
				aTotEstI[nColBr36] += aBrw36R6[i,nColBr36+2]
			ELSEIF Substr(Alltrim(aBrw36R3[i,2]),1,1) == '6'
				aTotIntT[nColBr36] += aBrw36R3[i,nColBr36+2]
				aTotIntI[nColBr36] += aBrw36R6[i,nColBr36+2]
			ELSEIF Substr(Alltrim(aBrw36R3[i,2]),1,1) == '7'
				aTotExpT[nColBr36] += aBrw36R3[i,nColBr36+2]
				aTotExpI[nColBr36] += aBrw36R6[i,nColBr36+2]
			ENDIF

		Next nColBr36
		aAdd(aLinha,aBrw36R3[i,nQNCM36+3])
		aAdd(aLinha,aBrw36R6[i,nQNCM36+3])

		//IMPRIME TOTAL ESTADUAL
		IF (Substr(Alltrim(aBrw36R3[i,2]),1,1) == '6' .OR. Substr(Alltrim(aBrw36R3[i,2]),1,1) == '7') .AND. (i == 1 .OR. cGCFOP == '5')
			lTotEst := .T.
			aLinhaTT := {}
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"TOTAL ESTADUAL")
			For j := 1 To nQNCM36
				aAdd(aLinhaTT,aTotEstT[j])
				aAdd(aLinhaTT,aTotEstI[j])
				nTotEstT += aTotEstT[j]
				nTotEstI += aTotEstI[j]
			Next j
			aAdd(aLinhaTT,nTotEstT)
			aAdd(aLinhaTT,nTotEstI)
			oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
		ENDIF

		//IMPRIME TOTAL INTERESTADUAL
		IF Substr(Alltrim(aBrw36R3[i,2]),1,1) == '7' .AND. (i == 1 .OR. cGCFOP == '6' .OR. cGCFOP == '5')
			lTotInt := .T.
			aLinhaTT := {}
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"")
			aAdd(aLinhaTT,"TOTAL INTERESTADUAL")
			For j := 1 To nQNCM36
				aAdd(aLinhaTT,aTotIntT[j])
				aAdd(aLinhaTT,aTotIntI[j])
				nTotIntT += aTotIntT[j]
				nTotIntI += aTotIntI[j]
			Next j
			aAdd(aLinhaTT,nTotEstT)
			aAdd(aLinhaTT,nTotEstI)
			oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
		ENDIF
		IF aBrw36R3[i,nQNCM36+3] > 0 .AND. aBrw36R6[i,nQNCM36+3] > 0
			oExcel:AddRow(cFld361,cFld36t1,aLinha)
		ENDIF
		
		cGCFOP := Substr(Alltrim(aBrw36R3[i,2]),1,1)
	Next i


	IF !lTotEst
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL ESTADUAL")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotEstT[j])
			aAdd(aLinhaTT,aTotEstI[j])
			nTotEstT += aTotEstT[j]
			nTotEstI += aTotEstI[j]
		Next j
		aAdd(aLinhaTT,nTotEstT)
		aAdd(aLinhaTT,nTotEstI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	IF !lTotInt
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL INTERESTADUAL")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotIntT[j])
			aAdd(aLinhaTT,aTotIntI[j])
			nTotIntT += aTotIntT[j]
			nTotIntI += aTotIntI[j]
		Next j
		aAdd(aLinhaTT,nTotIntT)
		aAdd(aLinhaTT,nTotIntI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	IF !lTotExp
		aLinhaTT := {}
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"")
		aAdd(aLinhaTT,"TOTAL EXPORTAÇÃO")
		For j := 1 To nQNCM36
			aAdd(aLinhaTT,aTotExpT[j])
			aAdd(aLinhaTT,aTotExpI[j])
			nTotExpT += aTotExpT[j]
			nTotExpI += aTotExpI[j]
		Next j
		aAdd(aLinhaTT,nTotExpT)
		aAdd(aLinhaTT,nTotExpI)
		oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)
	ENDIF

	aLinhaTT := {}
	aAdd(aLinhaTT,"Cliente NÃO Optante pelo Simples ou Consumidor Final")
	aAdd(aLinhaTT,"")
	aAdd(aLinhaTT,"TOTAL")
	For j := 1 To nQNCM36
		aAdd(aLinhaTT,aTotEstT[j]+aTotIntT[j]+aTotExpT[j])
		aAdd(aLinhaTT,aTotEstI[j]+aTotIntI[j]+aTotExpI[j])
		nTotGerT += aTotEstT[j]+aTotIntT[j]+aTotExpT[j]
		nTotGerI += aTotEstI[j]+aTotIntI[j]+aTotExpI[j]
	Next j
	aAdd(aLinhaTT,nTotGerT)
	aAdd(aLinhaTT,nTotGerI)
	oExcel:AddRow(cFld361,cFld36t1,aLinhaTT)

	//******************
	// Linha em Branco
	//******************
	aLinhaBr := {}
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	For j := 1 To nQNCM36
		aAdd(aLinhaBr,"")
		aAdd(aLinhaBr,"")
	Next j
	aAdd(aLinhaBr,"")
	aAdd(aLinhaBr,"")
	oExcel:AddRow(cFld361,cFld36t1,aLinhaBr)

	// oExcel:AddRow(cFld361,cFld36t1,{, nVCFLTot, nVCFLIcm })
	// oExcel:AddRow(cFld361,cFld36t1,{" ", nVSNCTot, nVSNCIcm })
	// oExcel:AddRow(cFld361,cFld36t1,{" ", nVOCTot, nVOCIcm })

	// oExcel:AddRow(cFld361,cFld36t1,{"","",""})


	// oExcel:AddRow(cFld361,cFld36t1,{"","",""})
Return

/*/{Protheus.doc} Static Function Cab36P2
	Gera Relatório Ref. Conferência de Faturamento
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function Cab36P2()
	oExcel:AddworkSheet(cFld362)
	oExcel:AddTable(cFld362,cFld36t2)
	oExcel:AddColumn(cFld362,cFld36t2, "Filial"				,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Dt. Entrada"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Dt. Emissão"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Série"				,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Nota Fiscal"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Item NF"			,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Cod.Forn"			,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Loja"					,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Fornecedor"		,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "CNPJ"					,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "UF"						,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Opt Simp Nac"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Tipo Cliente"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Grupo Client"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Produto"			,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Desc.Prod"		,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "GrpTrib Prd"	,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "TS Prd"				,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Op SN Prd "		,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Quant"				,2,2)
	oExcel:AddColumn(cFld362,cFld36t2, "PrcUnit"			,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Vl. Total"		,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Vl. Cont"			,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Base ICMS"		,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Aliq ICMS"		,2,2)
	oExcel:AddColumn(cFld362,cFld36t2, "Vl. ICMS"			,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Carga Trib"		,2,2)
	oExcel:AddColumn(cFld362,cFld36t2, "Conf.Aliq"		,2,2)
	oExcel:AddColumn(cFld362,cFld36t2, "Conf.Base"		,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "ICMS Ret"			,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "ICMS Outras"	,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Desconto"			,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Seguro"				,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Despesas"			,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "Frete"				,2,3)
	oExcel:AddColumn(cFld362,cFld36t2, "CFOP"					,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "TES"					,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "Observação"		,1,1)
	oExcel:AddColumn(cFld362,cFld36t2, "NCM"					,1,1)

RETURN(NIL)  

/*/{Protheus.doc} Static Function GEx36P2
	Gera Relatório Ref. Conferência de Faturamento
	@author Abel Babini Filho
	@since 19/05/2020
	@version 01
	/*/
Static Function GEx36P2()
	//
	ProcRegua((cAlB36Dt)->(RecCount()))
	(cAlB36Dt)->(dbGoTop())
	While !(cAlB36Dt)->(Eof())
		IncProc()
		oExcel:AddRow(cFld362,cFld36t2,{(cAlB36Dt)->FILIAL,;
																		(cAlB36Dt)->DTENTRADA,;
																		(cAlB36Dt)->DTEMISSAO,;
																		(cAlB36Dt)->NFSERIE,;
																		(cAlB36Dt)->NF,;
																		(cAlB36Dt)->NFITEM,;
																		(cAlB36Dt)->CLIEFOR,;
																		(cAlB36Dt)->LOJA,;
																		(cAlB36Dt)->NOME,;
																		(cAlB36Dt)->CNPJ,;
																		(cAlB36Dt)->EST,;
																		(cAlB36Dt)->SIMPLESNAC,;
																		(cAlB36Dt)->TIPOCLI,;
																		(cAlB36Dt)->GRPTRCLI,;
																		(cAlB36Dt)->CODPROD,;
																		(cAlB36Dt)->DESCPROD,;
																		(cAlB36Dt)->GRTRIB,;
																		(cAlB36Dt)->TESPADRAO,;
																		(cAlB36Dt)->XD65255,;
																		(cAlB36Dt)->QUANT,;
																		(cAlB36Dt)->PRCUNIT,;
																		(cAlB36Dt)->TOTAL,;
																		(cAlB36Dt)->VLCONT,;
																		(cAlB36Dt)->ICMSBASE,;
																		(cAlB36Dt)->ICMSALIQ,;
																		(cAlB36Dt)->ICMSVAL,;
																		(cAlB36Dt)->CARGATRI,;
																		(cAlB36Dt)->CONFALQ,;
																		(cAlB36Dt)->CONFBASC,;
																		(cAlB36Dt)->ICMSRET,;
																		(cAlB36Dt)->ICMSOUTR,;
																		(cAlB36Dt)->DESCONT,;
																		(cAlB36Dt)->SEGURO,;
																		(cAlB36Dt)->DESPESA,;
																		(cAlB36Dt)->FRETE,;
																		(cAlB36Dt)->CFOP,;
																		(cAlB36Dt)->TES,;
																		(cAlB36Dt)->OBSERV,;
																		(cAlB36Dt)->NCM})
		(cAlB36Dt)->(dbSkip())
	ENDDO
	(cAlB36Dt)->(dbGoTop())

	oExcel:AddRow(cFld362,cFld36t2,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Return

/*/{Protheus.doc} Static Function fAddCl36
	Cria colunas no Browser Cred. Outorgado dinamicamente 
	@author Abel Babini Filho
	@since 14/04/2019
	@version 01
	/*/
Static Function fAddCl36( pLin , cBrw)
	// If cBrw == "08"
	// 	oBrw08Rs:AddColumn( TcColumn():New( aBrw08Nc[pLin]	, {|| aBrw08Rs[oBrw08Rs:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	// ElseIf cBrw == "23"
	// 	oBrw23R2:AddColumn( TcColumn():New( aBrw23Em[pLin][1]	, {|| aBrw23R2[oBrw23R2:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	// Else
	If cBrw == "361"
		oBrw36R1:AddColumn( TcColumn():New( aBrw36Nc[pLin]	, {|| aBrw36R1[oBrw36R1:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	ElseIf cBrw == "362"
		oBrw36R2:AddColumn( TcColumn():New( aBrw36Nc[pLin]	, {|| aBrw36R2[oBrw36R2:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	ElseIf cBrw == "363"
		oBrw36R3:AddColumn( TcColumn():New( aBrw36Nc[pLin]	, {|| aBrw36R3[oBrw36R3:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	ElseIf cBrw == "364"
		oBrw36R4:AddColumn( TcColumn():New( aBrw36Nc[pLin]	, {|| aBrw36R4[oBrw36R4:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	ElseIf cBrw == "365"
		oBrw36R5:AddColumn( TcColumn():New( aBrw36Nc[pLin]	, {|| aBrw36R5[oBrw36R5:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	ElseIf cBrw == "366"
		oBrw36R6:AddColumn( TcColumn():New( aBrw36Nc[pLin]	, {|| aBrw36R6[oBrw36R6:nAt,pLin+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	Endif
Return( NIL )

//FIM Ticket 10535										- Abel Babini - 09/03/2021 - Criar relatório de conferência de faturamento por tipo de cliente e regime de apuração.

//INICIO Ticket 18004                   - Abel Babini - 17/08/2021 - Alterações no Painel Fiscal - Apuração de Frete e criação do relatório Débito Serv. Industrialização
/*/{Protheus.doc} Static Function xABrw37
	Carrega da dados Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 17/08/2021
	@version 01
	/*/
Static Function xABrw37()
	If Select(cAlB37Rs) > 0
		(cAlB37Rs)->(dbCloseArea())
	Endif
	cAlB37Rs:=GetNextAlias()

	//Inicializa Variáveis
	aBrw37Rs	:= {}
	aBrw37Dt	:= {}
	nA37T01		:= 0
	nA37T02		:= 0
	nA37T03		:= 0
	nA37T04		:= 0
	nA37T05		:= 0
	nA37T06		:= 0

	BeginSQL  Alias cAlB37Rs
		column DTENTRADA as Date
		SELECT
			SFT.FT_FILIAL		AS FILIAL,
			SFT.FT_ENTRADA		AS DTENTRADA,
			SFT.FT_SERIE		AS SERIE,
			SFT.FT_NFISCAL		AS NFISCAL,
			SFT.FT_ITEM			AS ITEM,
			SFT.FT_CLIEFOR		AS CLIEFOR,
			SFT.FT_LOJA			AS LOJA,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_NOME ELSE SA1.A1_NOME END AS NOME,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN SA2.A2_CGC ELSE SA1.A1_CGC END AS CGC,
			CASE WHEN (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) THEN (CASE WHEN SA2.A2_SIMPNAC = '1' THEN 'SIM' ELSE 'NÃO' END) ELSE (CASE WHEN SA1.A1_SIMPNAC = '1' THEN 'SIM' ELSE 'NÃO' END) END AS SIMPLESNAC,
			SFT.FT_PRODUTO		AS CODPROD,
			SB1.B1_DESC			AS PRODUTO,
			SFT.FT_QUANT		AS QUANT,
			SFT.FT_PRCUNIT		AS PRCUNIT,
			SFT.FT_TOTAL		AS TOTAL,
			SFT.FT_VALCONT		AS VALCONT,
			SFT.FT_BASEICM		AS ICMSBASE,
			SFT.FT_ALIQICM		AS ICMSALIQ,
			SFT.FT_VALICM		AS ICMSVAL,
			SFT.FT_ICMSRET		AS ICMSRET,
			SFT.FT_OUTRICM		AS ICMSOUTR,
			SFT.FT_DESCONT		AS DESCONT,
			SFT.FT_SEGURO		AS SEGURO,
			SFT.FT_DESPESA		AS DESPESA,
			SFT.FT_FRETE		AS FRETE,
			SFT.FT_DTCANC		AS DTCANC,
			SFT.FT_OBSERV		AS OBSERV,
			SFT.FT_TES			AS TES,
			SFT.FT_CFOP			AS CFOP,
			SFT.FT_TIPO			AS TIPO,
			SFT.FT_ESPECIE		AS ESPECIE,
			SFT.FT_FORMUL		AS FORMULARIO,
			SD1.D1_CC			AS CCUSTO
		FROM %TABLE:SFT% SFT (NOLOCK) 
		LEFT JOIN %TABLE:SB1% SB1 (NOLOCK) ON
			SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SFT.FT_PRODUTO
			AND SB1.%notDel%
		LEFT JOIN %TABLE:SA2% SA2 (NOLOCK) ON
			SA2.A2_FILIAL = %xFilial:SA2%
			AND SA2.A2_COD = SFT.FT_CLIEFOR
			AND SA2.A2_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA2.%notDel%
		LEFT JOIN %TABLE:SA1% SA1 (NOLOCK) ON
			SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SFT.FT_CLIEFOR
			AND SA1.A1_LOJA = SFT.FT_LOJA
			AND ( (SFT.FT_TIPOMOV = 'S' AND SFT.FT_TIPO NOT IN ('D','B') ) OR (SFT.FT_TIPOMOV = 'E' AND SFT.FT_TIPO IN ('D','B') ) )
			AND SA1.%notDel%
		LEFT JOIN %TABLE:SD1% SD1 (NOLOCK) ON
			SD1.D1_FILIAL = SFT.FT_FILIAL
			AND SD1.D1_SERIE = SFT.FT_SERIE
			AND SD1.D1_DOC = SFT.FT_NFISCAL
			AND SD1.D1_FORNECE = SFT.FT_CLIEFOR
			AND SD1.D1_LOJA = SFT.FT_LOJA
			AND SD1.D1_ITEM = SFT.FT_ITEM
			AND SD1.%notDel%
		WHERE SFT.FT_FILIAL = %xFilial:SFT%
			AND SFT.FT_ENTRADA BETWEEN %Exp:DToS(_mvpr01)% AND %Exp:DToS(_mvpr02)%
			AND SFT.FT_PRODUTO IN %Exp:_cInPrSI%
			AND SFT.FT_CFOP IN %Exp:_cInCfDS%
			AND SFT.FT_DTCANC = ''
			AND SFT.%notDel%
	EndSQL
	DbSelectArea(cAlB37Rs)
	(cAlB37Rs)->(DbGoTop())
	While !(cAlB37Rs)->(eof())
		nPos := ASCAN(aBrw37Rs, {|X| X[1] == Alltrim((cAlB37Rs)->CFOP)+Alltrim((cAlB37Rs)->CODPROD)})
		IF nPos == 0
			aAdd(aBrw37Rs,{Alltrim((cAlB37Rs)->CFOP)+Alltrim((cAlB37Rs)->CODPROD),;
										(cAlB37Rs)->FILIAL,;							
										(cAlB37Rs)->CFOP,;
										(cAlB37Rs)->CODPROD+' - '+(cAlB37Rs)->PRODUTO,;
										(cAlB37Rs)->QUANT,;
										(cAlB37Rs)->VALCONT,;
										(cAlB37Rs)->ICMSVAL,;
										Round((cAlB37Rs)->VALCONT/(cAlB37Rs)->QUANT,2)})
		ELSE
			aBrw37Rs[nPos,05] += (cAlB37Rs)->QUANT
			aBrw37Rs[nPos,06] += (cAlB37Rs)->VALCONT
			aBrw37Rs[nPos,07] += (cAlB37Rs)->ICMSVAL
			aBrw37Rs[nPos,08] += Round(aBrw37Rs[nPos,06]/aBrw37Rs[nPos,05],2)
		ENDIF
		IF (cAlB37Rs)->CFOP > '5000'
			nA37T01 += (cAlB37Rs)->QUANT
			nA37T02 += (cAlB37Rs)->VALCONT
			nA37T03 += (cAlB37Rs)->ICMSVAL
		ELSE
			nA37T04 += (cAlB37Rs)->QUANT
			nA37T05 += (cAlB37Rs)->VALCONT
			// nA37T06 += (cAlB37Rs)->ICMSVAL
		ENDIF
		aAdd(aBrw37Dt,{	(cAlB37Rs)->FILIAL,;
										(cAlB37Rs)->DTENTRADA,;
										(cAlB37Rs)->SERIE,;
										(cAlB37Rs)->NFISCAL,;
										(cAlB37Rs)->ITEM,;
										(cAlB37Rs)->CLIEFOR,;
										(cAlB37Rs)->LOJA,;
										(cAlB37Rs)->NOME,;
										(cAlB37Rs)->CGC,;
										(cAlB37Rs)->SIMPLESNAC,;
										(cAlB37Rs)->CODPROD,;
										(cAlB37Rs)->PRODUTO,;
										(cAlB37Rs)->QUANT,;
										(cAlB37Rs)->PRCUNIT,;
										(cAlB37Rs)->TOTAL,;
										(cAlB37Rs)->VALCONT,;
										(cAlB37Rs)->ICMSBASE,;
										(cAlB37Rs)->ICMSALIQ,;
										(cAlB37Rs)->ICMSVAL,;
										(cAlB37Rs)->ICMSRET,;
										(cAlB37Rs)->ICMSOUTR,;
										(cAlB37Rs)->DESCONT,;
										(cAlB37Rs)->SEGURO,;
										(cAlB37Rs)->DESPESA,;
										(cAlB37Rs)->FRETE,;
										(cAlB37Rs)->DTCANC,;
										(cAlB37Rs)->OBSERV,;
										(cAlB37Rs)->TES,;
										(cAlB37Rs)->CFOP,;
										(cAlB37Rs)->TIPO,;
										(cAlB37Rs)->ESPECIE,;
										(cAlB37Rs)->CCUSTO})
		(cAlB37Rs)->(DbSkip())
	EndDo

	nA37T06 := Round(nA37T05*0.18,2)

	(cAlB37Rs)->(dbCloseArea())
	SysRefresh()
Return

/*/{Protheus.doc} Static Function xRelBr37
	Gera Relatório Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 17/08/2021
	@version version
	/*/
Static Function xRelBr37()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Débito Serv. Industrialização" )

	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr37b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	FormBatch( cCadastr, aSays, aButtons )

	MsgInfo("Arquivo Excel gerado!")

Return

/*/{Protheus.doc} Static Function xRelBr37b
	Gera Relatório Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 28/10/2019
	@version version
	/*/
Static Function xRelBr37b()
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	Private oMsExcel   := NIL

	cArquivo := cPathRel +  'RDSRVIND_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	BEGIN SEQUENCE

		//IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		//	Alert("Nao Existe Excel Instalado")
		//	BREAK
		//EndIF

		//Planilha1 - Resumo
		Cab37P1()
		GEx37P1()

		//Planilha2 - Detalhe
		Cab37P2()
		GEx37P2()

		StaticCall(ADFIS028R,SalvaXml)
		StaticCall(ADFIS028R,CriaExcel)

	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab15P1
	Gera Relatório Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 17/08/2021
	@version version
	/*/
Static Function Cab37P1()
	oExcel:AddworkSheet(cFld371)
	oExcel:AddTable(cFld371,cFld37t1)
	oExcel:AddColumn(cFld371,cFld37t1,"Filial",1,1)
	oExcel:AddColumn(cFld371,cFld37t1,"CFOP",1,1)
	oExcel:AddColumn(cFld371,cFld37t1,"Produto",1,1)
	oExcel:AddColumn(cFld371,cFld37t1,"Quantidade",2,3,.t.)
	oExcel:AddColumn(cFld371,cFld37t1,"Vl. Contábil",2,3,.t.)
	oExcel:AddColumn(cFld371,cFld37t1,"Vl. ICMS",2,3,.t.)
	oExcel:AddColumn(cFld371,cFld37t1,"Média Preço Unit.",2,3)
RETURN(NIL)

/*/{Protheus.doc} Static Function GEx37P1
	Gera Relatório Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 17/08/2021
	@version version
	/*/
Static Function GEx37P1()
	Local i
	For i:=1 to Len(aBrw37Rs)
		oExcel:AddRow(cFld371,cFld37t1,{	aBrw37Rs[i,2],;
																			aBrw37Rs[i,3],;
																			aBrw37Rs[i,4],;
																			aBrw37Rs[i,5],;
																			aBrw37Rs[i,6],;
																			aBrw37Rs[i,7],;
																			aBrw37Rs[i,8]})
	Next i

	oExcel:AddRow(cFld371,cFld37t1,{"","","","","","",""})
	//
Return

/*/{Protheus.doc} Static Function Cab37P2
	Gera Relatório Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 17/08/2021
	@version version
	/*/
Static Function Cab37P2()
	oExcel:AddworkSheet(cFld372)
	oExcel:AddTable(cFld372,cFld37t2)
	oExcel:AddColumn(cFld372,cFld37t2,"Filial"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Dt.Entrada"	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Série"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"NF"			,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Item"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Cod.Forn."	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Loja.Forn."	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Fornecedor"	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"CNPJ"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Opt.Simples"	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Cod.Prod."	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Produto"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Quant."		,2,2,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Prc.Unit"	,2,3)
	oExcel:AddColumn(cFld372,cFld37t2,"Total"		,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Vl.Cont."	,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Base ICMS"	,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Aliq.ICMS"	,2,3)
	oExcel:AddColumn(cFld372,cFld37t2,"Vl.ICMS"		,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Vl.ICMS Ret.",2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Vl.ICMS Out.",2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Desconto"	,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Seguro"		,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Despesa"		,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Frete"		,2,3,.T.)
	oExcel:AddColumn(cFld372,cFld37t2,"Dt.Canc."	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Observações"	,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"TES"			,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"CFOP"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Tipo"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Espécie"		,1,1)
	oExcel:AddColumn(cFld372,cFld37t2,"Centro Custo",1,1)

RETURN(NIL)

/*/{Protheus.doc} Static Function GEx37P2
	Gera Relatório Ref. Débito Serv. Industrialização
	@type  Static Function
	@author Abel Babini Filho
	@since 17/08/2021
	@version version
	/*/
Static Function GEx37P2()
	Local nExcel1
	FOR nExcel1 := 1 TO Len(aBrw37Dt)
		oExcel:AddRow(cFld372,cFld37t2,{aBrw37Dt[nExcel1,01],;
			aBrw37Dt[nExcel1,02],;
			aBrw37Dt[nExcel1,03],;
			aBrw37Dt[nExcel1,04],;
			aBrw37Dt[nExcel1,05],;
			aBrw37Dt[nExcel1,06],;
			aBrw37Dt[nExcel1,07],;
			aBrw37Dt[nExcel1,08],;
			aBrw37Dt[nExcel1,09],;
			aBrw37Dt[nExcel1,10],;
			aBrw37Dt[nExcel1,11],;
			aBrw37Dt[nExcel1,12],;
			aBrw37Dt[nExcel1,13],;
			aBrw37Dt[nExcel1,14],;
			aBrw37Dt[nExcel1,15],;
			aBrw37Dt[nExcel1,15],;
			aBrw37Dt[nExcel1,17],;
			aBrw37Dt[nExcel1,18],;
			aBrw37Dt[nExcel1,19],;
			aBrw37Dt[nExcel1,20],;
			aBrw37Dt[nExcel1,21],;
			aBrw37Dt[nExcel1,22],;
			aBrw37Dt[nExcel1,23],;
			aBrw37Dt[nExcel1,24],;
			aBrw37Dt[nExcel1,25],;
			aBrw37Dt[nExcel1,26],;
			aBrw37Dt[nExcel1,27],;
			aBrw37Dt[nExcel1,28],;
			aBrw37Dt[nExcel1,29],;
			aBrw37Dt[nExcel1,30],;
			aBrw37Dt[nExcel1,31],;
			aBrw37Dt[nExcel1,32]})
	Next nExcel1
	//Linha Em branco
	oExcel:AddRow(cFld372,cFld37t2,{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
RETURN
//FIM Ticket 18004                   - Abel Babini - 17/08/2021 - Alterações no Painel Fiscal - Apuração de Frete e criação do relatório Débito Serv. Industrialização
