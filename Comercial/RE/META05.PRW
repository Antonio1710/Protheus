#include "rwmake.ch"
#include "topconn.ch"
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

/*/{Protheus.doc} User Function META05
	Relatorio Semanal de Faturamento de Produtos ( COMERCIAL  ).
	@type  Function
	@author Marcos Bido 
	@since 24/09/02
	@version version
	@history Chamado 045773 - Heraldo  - 25/10/02  Incluido a leitura dos Arquivos SF1/SD1, para se calcular as devolucoes. 
	Retirado o calculo tipo=D do SF2. Aplicado novos conceitos referente a grupos de produtos 
	@history Ticket   049194 - William Costa - Incluido exceção para impressao dos produtos 384413 e 342977 Ovos Ferteis 
	que não são P.A e querem gerar no relatório 
	@history Ticket   15553  - Abel Babini - 14/06/2021 - Correção de error log no retorno das filiais selecionadas.
	@history Ticket   70435  - Adriano Savoine - 28/03/2022 - Ajustado o tratamento devido ao mesmo não ser mais necessario para este parametro.
	@history Ticket   70851  - ADRIANO SAVOINE - 05/04/2022 - Realizado ajuste para o usuario não deixar de preencher as filiais.
/*/

User Function META05()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio Semanal de Faturamento de Produtos ( COMERCIAL  )')

SetPrvt("AORD,TAMANHO,LIMITE,NOMEPROG,MV_TABPR,NTIPO")
SetPrvt("ARETURN,NLASTKEY,NLIN,NITEM,LCONTINUA,M_PAG")
SetPrvt("IMPRIME,CPERG,CSTRING,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,NOMEREL,CABEC1,CABEC2,CABEC3,CABEC5")
SetPrvt("CABEC6,CABEC7,ATRASO,POSICA,CVEND,ASTRU")
SetPrvt("_CNOMTRB,CINDEX,_TOTSAL,_TOTDEV,_CLIENTE,_NOME")
SetPrvt("_LOJA,_REGVEND,_VENDE,_PREFIXO,CABEC4,")
Public _DESGRPP
Public _DESGRPF
Public _DESGRPN
Public _cGrupoP
Public _cGrupoF
Public _cGrupoN
Public _cProdBase,_V1,_V2,_V3,_V4,_V5,_V6

_nTGPP1		:=	0
_nTGPP2		:=	0
_nTGPP3		:=	0
_nTGPP4		:=	0
_nTGPP5		:=	0
_nTGPPa		:=	0

_nTGPV1		:=	0
_nTGPV2		:=	0
_nTGPV3		:=	0
_nTGPV4		:=	0
_nTGPV5		:=	0
_nTGPVa		:=	0

_nTGPM1		:=	0
_nTGPM2		:=	0
_nTGPM3		:=	0
_nTGPM4		:=	0
_nTGPM5		:=	0
_nTGPMa		:=	0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // De Data Entrega                      ³
//³ mv_par02             // Ate a data entrega                   ³
//³ mv_par03             // PRODUTO RAIZ                         ³
//³ mv_par04             // GRUPO DE                             ³
//³ mv_par05             // GRUPO ATE                            ³
//³ mv_par06             // SEGMENTO DE                          ³
//³ mv_par07             // SEGMENTO ATE                         ³
//³ mv_par08             // SUPERVISOR DE                        ³
//³ mv_par09             // SUPERVISOR ATE                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOrd             := {}
tamanho          := "G"
limite           := 220
nomeprog         := "META05"
mv_tabpr         := ""
nTipo            := 15
aReturn := { "LandScap", 1,"Administracao", 1, 2, 1, "",0 }

nLastKey         := 0
nlin             := 80
nItem            := 1
lContinua        := .T.
_cCFDev			 := Alltrim(GetMV("MV_#CFDEV"))   //Incluido por Adriana em 01/08/16

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
m_pag	   := 01
imprime    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg   := "META05"
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis de Cabecalho do Relatorio         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo		:="FATURAMENTO SEMANAL DE PRODUTOS"
cCabec1		:=""
cCabec2		:=""
cPrograma	:="META05"
cTamanho	:="G"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela padrao de impressao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cString := "SD2"
titulo  := "FATURAMENTO SEMANAL DE PRODUTOS  "
cDesc1  := "Este programa tem como objetivo imprimir o faturamento semanal "
cDesc2  := "de produtos "
cDesc3  := "Equipe Protheus"
NomeRel := "META05"


	//Ticket:70851 - 05/04/2022 - ADRIANO SAVOINE
	IF TYPE(MV_PAR10) == "N" .OR. TYPE(MV_PAR10) == "U"

		MsgAlert("SELECIONE NOS PARAMETROS AS FILIAIS, PARA GERAR ESTE RELATORIO.", "ATENCAO!!!")

		nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

		U_META05()

		ELSE

		nomerel := SetPrint(cString,Nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho)

	ENDIF  




If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

//Ticket   70435  - Adriano Savoine - 28/03/2022
//MV_PAR10 := formatIn(ALLTRIM(MV_PAR10),',')
//MV_PAR10 := substring(MV_PAR10, 2, len(alltrim(MV_PAR10))-2)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo   := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o cabecalho padrao para o relatorio                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Cabec04 := "|=================================================================================================================================================================================================="
Cabec05 := "|                                     |      1a. Semana         |      2a. Semana         |       3a. Semana        |      4a. Semana         |      5a. Semana         |       ACUMULADO         |"
Cabec06 := "|          P R O D U T O S            | 99/99/9999 a 99/99/9999 | 99/99/9999 a 99/99/9999 | 99/99/9999 a 99/99/9999 | 99/99/9999 a 99/99/9999 | 99/99/9999 a 99/99/9999 |       DO PERIODO        |"
Cabec07 := "|                                     |  Total   Total  % Rel.  |  Total   Total  % Rel.  |   Total   Total  % Rel. |  Total   Total  % Rel.  |  Total   Total  % Rel.  |   Total   Total  % Rel. |"
Cabec08 := "|                                     |  Kilos   Valor  Frango  |  Kilos   Valor  Frango  |   Kilos   Valor  Frango |  Kilos   Valor  Frango  |  Kilos   Valor  Frango  |   Kilos   Valor  Frango |"
Cabec09 := "|=================================================================================================================================================================================================="
//          1 3   7                                40      48        58       67      75        85      93      101       111     118     127       137     145     153       163     171     179       189   195
//|                                     |999,999 999,999   99.99  | 999,999 999,999   99.99 | 999,999 999,999   99.99 | 999,999 999,999   99.99 | 999,999 999,999   99.99 | 999,999 999,999   99.99 |
//1 3   7                                40      48        58       67      75        85      93      101       111     118     127       137     145     153       163     171     179       189   195
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

#IFDEF WINDOWS
	Processa({|| RunCont()},Titulo )
	Return
	Static Function RunCont()
	ProcRegua(RecCount())
#ELSE
	SetRegua(RecCount())
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo Temporario para totalizacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aStru := {}
AADD (aStru,{"TR_CODVEND" , "C",06,0})
AADD (aStru,{"TR_SUPERVI" , "C",12,0})
AADD (aStru,{"TR_GRUPOP"  , "C",04,0})
AADD (aStru,{"TR_GRUPOF"  , "C",04,0})
AADD (aStru,{"TR_GRUPON"  , "C",04,0})
AADD (aStru,{"TR_DESGRPP" , "C",20,0})
AADD (aStru,{"TR_DESGRPF" , "C",20,0})
AADD (aStru,{"TR_DESGRPN" , "C",20,0})
AADD (aStru,{"TR_CODPROD" , "C",15,0})
AADD (aStru,{"TR_DESPROD" , "C",40,0})
AADD (aStru,{"TR_VSEMA01" , "N",11,2})
AADD (aStru,{"TR_VSEMA02" , "N",11,2})
AADD (aStru,{"TR_VSEMA03" , "N",11,2})
AADD (aStru,{"TR_VSEMA04" , "N",11,2})
AADD (aStru,{"TR_VSEMA05" , "N",11,2})
AADD (aStru,{"TR_PSEMA01" , "N",09,0})
AADD (aStru,{"TR_PSEMA02" , "N",09,0})
AADD (aStru,{"TR_PSEMA03" , "N",09,0})
AADD (aStru,{"TR_PSEMA04" , "N",09,0})
AADD (aStru,{"TR_PSEMA05" , "N",09,0})
AADD (aStru,{"TR_MSEMA01" , "N",13,3})
AADD (aStru,{"TR_MSEMA02" , "N",13,3})
AADD (aStru,{"TR_MSEMA03" , "N",13,3})
AADD (aStru,{"TR_MSEMA04" , "N",13,3})
AADD (aStru,{"TR_MSEMA05" , "N",13,3})
AADD (aStru,{"TR_MACUMUL" , "N",13,2})
AADD (aStru,{"TR_VACUMUL" , "N",13,2})
AADD (aStru,{"TR_PACUMUL" , "N",11,0})
_cNomTrb := CriaTrab(aStru)

dbUseArea(.T.,,_cNomTrb,"TEMP",.F.,.F.)

cIndex   	:=	 "TR_GRUPOP + TR_GRUPOF + TR_GRUPON + TR_CODPROD"
IndRegua( "TEMP", _cNomTrb, cIndex,,,"Criando Indice ..." )

dbSelectArea("SBM")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SF2")
dbSetOrder(1)

dbSelectArea("SD2")
dbSetOrder(3)

dbSelectArea("SA3")
dbSetOrder(1)

dbSelectArea("SF1")
dbSetOrder(1)

dbSelectArea("SD1")
dbSetOrder(1)

// DEFININDO OS LIMITES DE SEMANA
_Resp := .t.

_ISEMA01 := MV_PAR01
_fsema01 := _Isema01

While _Resp
	
	_Fsema01 := _Fsema01 + 1
	
	if Dow(_FSEMA01) == 1  // DOMINGO
		
		_ISema02 := _fSema01 + 1
		_FSema02 := _fSema01 + 7
		
		_ISema03 := _fSema02 + 1
		_FSema03 := _fSema02 + 7
		
		_ISema04 := _fSema03 + 1
		_FSema04 := _fSema03 + 7
		
		_ISema05 := _fSema04 + 1
		_FSema05 := _fSema04 + 7
		
		_Resp := .f.
	endif
enddo

Cabec06 := "|        P R O D U T O S              |  "+;
substr(dtos(_ISema01),7,2)+"/"+substr(dtos(_ISema01),5,2)+"/"+substr(dtos(_ISema01),3,2) +"  a  "+;
substr(dtos(_Fsema01),7,2)+"/"+substr(dtos(_Fsema01),5,2)+"/"+substr(dtos(_Fsema01),3,2) +"  |  "+;
substr(dtos(_ISema02),7,2)+"/"+substr(dtos(_ISema02),5,2)+"/"+substr(dtos(_ISema02),3,2) +"  a  "+;
substr(dtos(_Fsema02),7,2)+"/"+substr(dtos(_Fsema02),5,2)+"/"+substr(dtos(_Fsema02),3,2) +"  |  "+;
substr(dtos(_ISema03),7,2)+"/"+substr(dtos(_ISema03),5,2)+"/"+substr(dtos(_ISema03),3,2) +"  a  "+;
substr(dtos(_Fsema03),7,2)+"/"+substr(dtos(_Fsema03),5,2)+"/"+substr(dtos(_Fsema03),3,2) +"  |  "+;
substr(dtos(_ISema04),7,2)+"/"+substr(dtos(_ISema04),5,2)+"/"+substr(dtos(_ISema04),3,2) +"  a  "+;
substr(dtos(_Fsema04),7,2)+"/"+substr(dtos(_Fsema04),5,2)+"/"+substr(dtos(_Fsema04),3,2) +"  |  "+;
substr(dtos(_ISema05),7,2)+"/"+substr(dtos(_ISema05),5,2)+"/"+substr(dtos(_ISema05),3,2) +"  a  "+;
substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),3,2) +"  |  "+;
"    DO  PERIODO        |"

cQuery:="SELECT * "+; 			// Query incluida por Heraldo 29/10/02
"FROM "+retsqlname("SF2")+" "+;
"WHERE F2_FILIAL IN ("+ALLTRIM(MV_PAR10)+") AND "+;
"F2_TIPO='N' AND "+;
"F2_EMISSAO BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND "+;
"D_E_L_E_T_= '' "+;
"ORDER BY F2_EMISSAO,F2_DOC,F2_SERIE"

TCQUERY cQuery new alias "XF2"
XF2->(dbgotop())

ProcRegua(RecCount())

While !eof()
	
	//  INCREMENTA A BARRA DE EVOLUCAO
	IncProc()
	IF XF2->F2_TIPO == "N"
	
		_cFIL           :=  XF2->F2_FILIAL
		_VENDEDOR	 	:= 	XF2->F2_VEND1
		_DOC      		:= 	XF2->F2_DOC
		_SERIE    		:= 	XF2->F2_SERIE
		_CLIENTE  		:= 	XF2->F2_CLIENTE
		_LOJA       	:= 	XF2->F2_LOJA
		_EMISSAO 		:= 	ctod(RIGHT(XF2->F2_EMISSAO,2)+"/"+SUBSTR(XF2->F2_EMISSAO,5,2)+"/"+LEFT(XF2->F2_EMISSAO,4))
		
		dbSelectArea("SA3")
		dbSeek(xfilial() + _Vendedor)
		_Supervis 	:= SA3->A3_CODSUP
		
		IF _Supervis >= mv_par08 .AND. _Supervis <= mv_par09
			dbSelectArea("SZR")
			dbSeek(xfilial() + _Supervis)
			_Segmento	:=	SZR->ZR_SEGMERC
			IF _Segmento >= mv_par06 .AND. _Segmento <= mv_par07
				
				dbSelectArea("SD2")
				//dbSeek(xfilial("SD2") + XF2->F2_DOC + XF2->F2_SERIE + XF2->F2_CLIENTE + XF2->F2_LOJA)
				dbSeek(XF2->F2_FILIAL + XF2->F2_DOC + XF2->F2_SERIE + XF2->F2_CLIENTE + XF2->F2_LOJA)
				DO WHILE !EOF() .AND. 	SD2->D2_DOC		  	== _DOC     	.AND. ;
				    SD2->D2_FILIAL      == _cFIL    .AND. ;
					SD2->D2_SERIE	  	== _SERIE  	.AND. ;
					SD2->D2_CLIENTE		== _CLIENTE .AND. ;
					SD2->D2_LOJA		== _LOJA
					//IF alltrim(SD2->D2_COD) <> "100096" 
					//   SD2->(DBSKIP())					
					//   LOOP
					//Endif
					If SD2->D2_TP != "PA" .AND. !(ALLTRIM(SD2->D2_COD) $  GetMv('MV_#PRODME',,"384413/342977"))	// se nao for produto acabado desconsidera //Adicionado excecao de produto 04/07/2019 - William Costa - 049194 || OS 050467 || EXPORTACAO || CICERO || 8360 || REL. META05  
						dbskip()
						LOOP
					Endif
				   	If (LEFT(SD2->D2_CF,2) == "59" .OR. LEFT(SD2->D2_CF,2) == "69" .OR. ;
					   	LEFT(SD2->D2_CF,4) == "5116" .OR. LEFT(SD2->D2_CF,4) == "6116" .OR.;
					   	LEFT(SD2->D2_CF,4) == "5151" .OR. LEFT(SD2->D2_CF,4) == "6151") .AND. ;
					   !(LEFT(SD2->D2_CF,4) $ '5922 6922')    
                       //INCLUIDA TRANSFERENCIA CFOP 5151 - PARA NAO CONSIDERAR NO RELATORIO
					   //REMESSA DESCONSIDERA, POREM CONSIDERA VENDA ENTREGA FUTURA 5922 E 6922 
					   //REMESSA PARA ENTREGA FUTURA 5116 e 6116 DESCONSIDERA 
						dbSelectArea("SD2")
						dbskip()
						LOOP
					Endif 
					//Posiciono no Cliente para pegar o valor financeiro
					dbSelectArea("SA1")
					dbSetOrder(1)
					DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,.T.)
					If SA1->A1_DESC > 0
						_Val := SD2->D2_TOTAL-(SD2->D2_TOTAL * SA1->A1_DESC / 100)
					Else													
						_Val := SD2->D2_TOTAL
					Endif 
					dbSelectArea("SD2")					
					_Qtd      		:= SD2->D2_QUANT
					_Desprod  		:= SPACE(30)
					_Produto  		:= SD2->D2_COD
					
					//......
					dbSelectArea("SB1")
					dbSeek(xfilial() + _Produto)
					
					//IF Alltrim(_Produto) == "189400" .AND. (_emissao >= _ISema05 .and.  _emissao <= mv_par02)
					//   MsgAlert("prod")
					//Endif   
					
					_cgrupoN	:= SB1->B1_GRUPO      //ALTERADO EM  28/12/06 XGRPANT PRESERVA GRUPO
//					_cgrupoN	:= SB1->B1_XGRPANT					
					_desprod 	:= SB1->B1_DESC
					If _cgrupoN < MV_PAR04 .OR. _cgrupoN	> MV_PAR05
						dbSelectArea("SD2")
						dbskip()
						LOOP
					Endif
					
					ProcuraGrupo()  
				
					dbSelectArea("TEMP")
					IF !dbSeek(_cGrupoP +_cGrupoF +_cGrupoN + _Produto)
						
						RecLock("TEMP",.T.)
						Repl TR_SUPERVI  	with _SuperviS
						Repl TR_CODVEND  	with SA3->A3_COD
						Repl TR_CODPROD  	with _produto
						Repl TR_DESPROD 	with _desprod
						Repl TR_DESGRPP 	with _DesGrpP
						Repl TR_DESGRPF 	with _DesGrpF
						Repl TR_DESGRPN 	with _DesGrpN
						Repl TR_GRUPOP    	with _cGrupoP
						Repl TR_GRUPOF    	with _cGrupoF
						Repl TR_GRUPON    	with _cGrupoN
						
						MsUnLock()
					endif
					
					RecLock("TEMP",.f.)
					Do Case
						
						Case _emissao >= _ISema01 .and. ; // semana 01
							_emissao <= _FSema01
							
							Repl TR_PSEMA01  	with TR_PSEMA01 + _Qtd
							Repl TR_VSEMA01  	with TR_VSEMA01 + _Val
							Repl TR_MSEMA01  	with TR_VSEMA01 / TR_PSEMA01 * 1000
							
						Case 	_emissao >= _ISema02 .and. ; // semana 02
							_emissao <= _FSema02
							
							Repl TR_PSEMA02  	with TR_PSEMA02 + _Qtd
							Repl TR_VSEMA02  	with TR_VSEMA02 + _Val
							Repl TR_MSEMA02  	with TR_VSEMA02 / TR_PSEMA02 * 1000
							
						Case 	_emissao >= _ISema03 .and. ; // semana 03
							_emissao <= _FSema03
							
							Repl TR_PSEMA03  	with TR_PSEMA03 + _Qtd
							Repl TR_VSEMA03  	with TR_VSEMA03 + _Val
							Repl TR_MSEMA03  	with TR_VSEMA03 / TR_PSEMA03 * 1000
							
						Case 	_emissao >= _ISema04 .and. ; // semana 04
							_emissao <= _FSema04
							
							Repl TR_PSEMA04  	with TR_PSEMA04 + _Qtd
							Repl TR_VSEMA04  	with TR_VSEMA04 + _Val
							Repl TR_MSEMA04  	with TR_VSEMA04 / TR_PSEMA04 * 1000
							
						Case 	_emissao >= _ISema05 .and.  ; // semana 05
							_emissao <= mv_par02
							//							_emissao <= _FSema05
							
							Repl TR_PSEMA05  	with TR_PSEMA05 + _Qtd
							Repl TR_VSEMA05  	with TR_VSEMA05 + _Val
							Repl TR_MSEMA05  	with TR_VSEMA05 / TR_PSEMA05 * 1000
							
					EndCase
					Repl TR_PACUMUL  	with TR_PACUMUL + _Qtd
					Repl TR_VACUMUL  	with TR_VACUMUL + _Val
					Repl TR_MACUMUL 	with TR_VACUMUL / TR_PACUMUL * 1000
					MsUnLock()
					//					ENDIF
					dbSelectArea("SD2")
					dbskip()
				ENDDO
			Endif
		Endif
	ENDIF
	dbSelectArea("XF2")
	dbskip()
ENDDO
dbclosearea("XF2")

//
// REGISTRA AS DEVOLUCOES OCORRIDAS NO PERIODO
// HERALDO C. HEBLING 14/11/02

cQuery:="SELECT * "+;
"FROM "+retsqlname("SF1")+" "+;
"WHERE F1_FILIAL IN ("+ALLTRIM(MV_PAR10)+") AND "+;
"F1_TIPO='D' AND "+;
"F1_DTDIGIT BETWEEN '"+dtos(mv_par01)+"' AND '"+dtos(mv_par02)+"' AND "+;
"D_E_L_E_T_= '' "+;
"ORDER BY F1_DTDIGIT,F1_DOC,F1_SERIE"

TCQUERY cQuery new alias "XF1"

XF1->(dbgotop())
//set century On
//ProcRegua(RecCount())
do while !XF1->(Eof())
	
	IF XF1->F1_TIPO == "D"                    
		
		_cFIL       := XF1->F1_FILIAL
		_DOC      	:= 	XF1->F1_DOC
		_SERIE    	:= 	XF1->F1_SERIE
		_CLIENTE  	:= 	XF1->F1_FORNECE
		_LOJA     	:= 	XF1->F1_LOJA
		_emissao  	:= 	CTOD(RIGHT(XF1->F1_DTDIGIT,2)+"/"+SUBSTR(XF1->F1_DTDIGIT,5,2)+"/"+LEFT(XF1->F1_DTDIGIT,4))
				
		&&Mauricio 29/02/12 - Solicitado alocar as devolucoes para o vendedor do faturamento original e nao vendedor do cadastro do cliente atual
		&&Conforme combinado com Sr. Alex sera alocado somente a um unico vendedor independente do numero de itens da NF, pois do contrario se mudaria
		&&toda a logica do programa atual.		
		dbSelectArea("SD1")
		dbSetOrder(1)
		If dbSeek(_cFIL + _DOC + _SERIE + _CLIENTE +_LOJA)
		   _cNFori  := SD1->D1_NFORI
		   _cSerOri :=  SD1->D1_SERIORI
		   DbSelectArea("SF2")
		   DbSetOrder(1) 
		   If dbseek(_cFIL+_cNFori+_cSerOri+_CLIENTE+_LOJA)
		   //If dbseek(xFilial("SF2")+_cNFori+_cSerOri+_CLIENTE+_LOJA)      ALEX BORGES 09/03/12
	 	      _vendedor	:=	SF2->F2_VEND1
	 	   Else   	 	      	 	      	 	      
		      dbselectArea("SA1")
		      dbSeek(xfilial() + _Cliente)
		      _vendedor	:=	SA1->A1_VEND
		   Endif
		Endif
		    
		dbSelectArea("SA3")
		dbSeek(xfilial() + _Vendedor)
		_Supervis := A3_CODSUP
		
		IF _Supervis >= mv_par08 .AND. _Supervis <= mv_par09
			dbSelectArea("SZR")
			dbSeek(xfilial() + _Supervis)
			_Segmento	:=	SZR->ZR_SEGMERC
			IF _Segmento >= mv_par06 .AND. _Segmento <= mv_par07
				dbSelectArea("SD1")
				dbSetOrder(1)
				dbSeek(_cFIL + _DOC + _SERIE + _CLIENTE +_LOJA)
				
				DO WHILE !EOF() .AND. 	SD1->D1_DOC 		== _DOC     	.AND. ;
				    SD1->D1_FILIAL      == _cFIL        .AND. ;
					SD1->D1_SERIE    	== _SERIE   	.AND. ;
					SD1->D1_FORNECE  	== _CLIENTE .AND. ;
					SD1->D1_LOJA		== _LOJA
					
					If SD1->D1_TP != "PA"	.AND. !(ALLTRIM(SD1->D1_COD) $  GetMv('MV_#PRODME',,"384413/342977"))	// se nao for produto acabado desconsidera //Adicionado excecao de produto 04/07/2019 - William Costa - 049194 || OS 050467 || EXPORTACAO || CICERO || 8360 || REL. META05
						dbskip()
						LOOP
					Endif                               
					
					IF !(Alltrim(SD1->D1_CF) $ _cCFDev) //Acrescentado cfop 3201 por Adriana em 01/08/16 conforme chamado 029916 
					   SD1->(DBSKIP())
					   loop
					ENDIF
					
					//IF Alltrim(SD1->D1_COD) <> "100096" //.AND. (_emissao >= _ISema05 .and.  _emissao <= mv_par02)
				    //   SD1->(DBsKIP())
				    //   LOOP
					//Endif 
					
					_Qtd      	:= SD1->D1_QUANT	* (-1)
					_Val      	:= SD1->D1_TOTAL	* (-1)
					
					_Grupo    	:= SPACE(12)
					_DesGrupo 	:= SPACE(12)
					_Desprod  	:= SPACE(30)
					_Produto  	:= SD1->D1_COD

					
					dbSelectArea("SB1")
					IF dbSeek(xfilial() + _Produto)
						_cgrupoN	:= SB1->B1_GRUPO   //ALTERADO EM  28/12/06 XGRPANT PRESERVA GRUPO
					  //	_cgrupoN	:= SB1->B1_XGRPANT   
						_desprod 	:= SB1->B1_DESC
					Endif
					 
					If _cgrupoN >= MV_PAR04 .AND. _cgrupoN	<= MV_PAR05
						PROCURAGRUPO()
						dbSelectArea("TEMP")
						IF !dbSeek(_cGrupoP +_cGrupoF +_cGrupoN + _Produto)
							
							RecLock("TEMP",.T.)
							TEMP->TR_SUPERVI  := _SuperviS
							TEMP->TR_CODVEND  := SA3->A3_COD
							TEMP->TR_CODPROD  := _produto
							TEMP->TR_DESPROD  := _desprod
							TEMP->TR_DESGRPP 	:= _DesGrpP
							TEMP->TR_DESGRPF 	:= _DesGrpF
							TEMP->TR_DESGRPN 	:= _DesGrpN
							TEMP->TR_GRUPOP    	:= _cGrupoP
							TEMP->TR_GRUPOF    	:= _cGrupoF
							TEMP->TR_GRUPON    	:= _cGrupoN
							MsUnLock()
						endif
						
						RecLock("TEMP",.f.)
						Do Case
							
							Case _emissao >= _ISema01 .and. ; // semana 01
								_emissao <= _FSema01
								
								TEMP->TR_PSEMA01  := TR_PSEMA01 + _Qtd
								TEMP->TR_VSEMA01  := TR_VSEMA01 + _Val
								TEMP->TR_MSEMA01  := TR_VSEMA01 / TR_PSEMA01 * 1000
								
							Case _emissao >= _ISema02 .and. ; // semana 02
								_emissao <= _FSema02
								
								TEMP->TR_PSEMA02  := TR_PSEMA02 + _Qtd
								TEMP->TR_VSEMA02  := TR_VSEMA02 + _Val
								TEMP->TR_MSEMA02  := TR_VSEMA02 / TR_PSEMA02 * 1000
								
							Case _emissao >= _ISema03 .and. ; // semana 03
								_emissao <= _FSema03
								
								TEMP->TR_PSEMA03  := TR_PSEMA03 + _Qtd
								TEMP->TR_VSEMA03  := TR_VSEMA03 + _Val
								TEMP->TR_MSEMA03  := TR_VSEMA03 / TR_PSEMA03 * 1000
								
							Case _emissao >= _ISema04 .and. ; // semana 04
								_emissao <= _FSema04
								
								TEMP->TR_PSEMA04  := TR_PSEMA04 + _Qtd
								TEMP->TR_VSEMA04  := TR_VSEMA04 + _Val
								TEMP->TR_MSEMA04  := TR_VSEMA04 / TR_PSEMA04 * 1000
								
							Case _emissao >= _ISema05 .and.  ; // semana 05
								_emissao <= mv_par02
								//								_emissao <= _FSema05
								
								TEMP->TR_PSEMA05  := TR_PSEMA05 + _Qtd
								TEMP->TR_VSEMA05  := TR_VSEMA05 + _Val
								TEMP->TR_MSEMA05  := TR_VSEMA05 / TR_PSEMA05 * 1000
								
						EndCase
						TEMP->TR_PACUMUL  := TR_PACUMUL + _Qtd
						TEMP->TR_VACUMUL  := TR_VACUMUL + _Val
						TEMP->TR_MACUMUL  := TR_VACUMUL / TR_PACUMUL * 1000
						MsUnLock()
					ENDIF
					dbSelectArea("SD1")
					dbskip()
				ENDDO
			Endif
		Endif
	ENDIF
	dbSelectArea("XF1")
	dbskip()
ENDDO
XF1->(dbclosearea())

Set Century Off

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ=ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  AQUI TERMINA O PROCESSAMENTO E COMECA A IMPRESSAO DO TEMP          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// VARIAVEIS DE TOTALIZACAO GERAL POR GRUPO DE PRODUTOS

_TGV1FRANGO := 0
_TGV2FRANGO := 0
_TGV3FRANGO := 0
_TGV4FRANGO := 0
_TGV5FRANGO := 0
_TGVAFRANGO := 0

_TGP1FRANGO := 0
_TGP2FRANGO := 0
_TGP3FRANGO := 0
_TGP4FRANGO := 0
_TGP5FRANGO := 0
_TGPAFRANGO := 0

_TGM1FRANGO := 0
_TGM2FRANGO := 0
_TGM3FRANGO := 0
_TGM4FRANGO := 0
_TGM5FRANGO := 0
_TGMAFRANGO := 0

_TGV1EMBUTI := 0
_TGV2EMBUTI := 0
_TGV3EMBUTI := 0
_TGV4EMBUTI := 0
_TGV5EMBUTI := 0
_TGVAEMBUTI := 0

_TGP1EMBUTI := 0
_TGP2EMBUTI := 0
_TGP3EMBUTI := 0
_TGP4EMBUTI := 0
_TGP5EMBUTI := 0
_TGPAEMBUTI := 0

_TGM1EMBUTI := 0
_TGM2EMBUTI := 0
_TGM3EMBUTI := 0
_TGM4EMBUTI := 0
_TGM5EMBUTI := 0
_TGMAEMBUTI := 0

_TGV1LEG := 0
_TGV2LEG := 0
_TGV3LEG := 0
_TGV4LEG := 0
_TGV5LEG := 0
_TGVALEG := 0

_TGP1LEG := 0
_TGP2LEG := 0
_TGP3LEG := 0
_TGP4LEG := 0
_TGP5LEG := 0
_TGPALEG := 0

_TGM1LEG := 0
_TGM2LEG := 0
_TGM3LEG := 0
_TGM4LEG := 0
_TGM5LEG := 0
_TGMALEG := 0

_TGP1GRAXA  := 0
_TGP2GRAXA  := 0
_TGP3GRAXA  := 0
_TGP4GRAXA  := 0
_TGP5GRAXA  := 0
_TGPAGRAXA  := 0

_TGV1GRAXA  := 0
_TGV2GRAXA  := 0
_TGV3GRAXA  := 0
_TGV4GRAXA  := 0
_TGV5GRAXA  := 0
_TGVAGRAXA  := 0

_TGM1GRAXA  := 0
_TGM2GRAXA  := 0
_TGM3GRAXA  := 0
_TGM4GRAXA  := 0
_TGM5GRAXA  := 0
_TGMAGRAXA  := 0

MontaBase()     // Monta base de preco

_cCond1	:=_cProdBase

//Cabec03 := space(70) + "Periodo de : "+dtoc(mv_par01)+" Ate : "+dtoc(mv_par02) + "      Ref.: " + _cGRUPOP+"/"+_cGRUPOF+"/"+_cGRUPON+"/"+_cProdBase
//cCabec2 := space(70) + "Periodo de : "+dtoc(mv_par01)+" Ate : "+dtoc(mv_par02) + "      Ref.: " + _cGRUPOP+"/"+_cGRUPOF+"/"+_cGRUPON+"/"+_cProdBase

dbSelectArea("TEMP")

ProcRegua(RecCount())
While !EOF()
	
	IncProc(1)
	
	If nLin > 60
		Imp0Cabec()
		nLin := nLin + 1
	Endif
	
	
	_nTGPP1		:=	0
	_nTGPP2		:=	0
	_nTGPP3		:=	0
	_nTGPP4		:=	0
	_nTGPP5		:=	0
	_nTGPPa		:=	0
	
	_nTGPV1		:=	0
	_nTGPV2		:=	0
	_nTGPV3		:=	0
	_nTGPV4		:=	0
	_nTGPV5		:=	0
	_nTGPVa		:=	0
	
	_nTGPM1		:=	0
	_nTGPM2		:=	0
	_nTGPM3		:=	0
	_nTGPM4		:=	0
	_nTGPM5		:=	0
	_nTGPMa		:=	0
	_GrupoQbrP    := TR_GRUPOP
	
	
	DO WHILE !EOF() .AND. TR_GRUPOP == _GrupoQbrP
		If nLin > 60
			Imp0Cabec()
			nLin := nLin + 1
		Endif
		_Tp1sema  := 0
		_Tp2sema  := 0
		_Tp3sema  := 0
		_Tp4sema  := 0
		_Tp5sema  := 0
		_Tpacumu  := 0
		
		_Tv1sema  := 0
		_Tv2sema  := 0
		_Tv3sema  := 0
		_Tv4sema  := 0
		_Tv5sema  := 0
		_Tvacumu  := 0
		
		_Tm1sema  := 0
		_Tm2sema  := 0
		_Tm3sema  := 0
		_Tm4sema  := 0
		_Tm5sema  := 0
		_Tmacumu  := 0
		_GrupoQbrF    := TR_GRUPOF
		@nLin,000 PSAY "|"
		@nLin,003 PSAY TR_GRUPOF +" - " + TR_DESGRPF
		@nLin,194 PSAY "|"
		nLin      := nLin + 1
		DO WHILE !EOF() .AND. TR_GRUPOF == _GrupoQbrF
			If TR_PSEMA01 = 0 .AND. TR_PSEMA02 = 0 .AND. TR_PSEMA03 = 0 .AND. TR_PSEMA04 = 0 .AND. TR_PSEMA05 = 0
				dBSkip()
				LOOP
			Endif
			
			_cDescr := TR_DESGRPP
			@nLin,000 PSAY "|"
			@nLin,002 PSAY TR_CODPROD PICTURE "999999"
			@nLin,009 PSAY TR_DESPROD PICTURE "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			@nLin,038 PSAY "|"
			
			@nLin,040 PSAY TR_PSEMA01 PICTURE "9999,999"
			@nLin,049 PSAY TR_MSEMA01 PICTURE "9999,999"
			@nLin,058 PSAY TR_MSEMA01 / _V1 PICTURE "99.99"
			@nLin,064 PSAY "|"
			
			@nLin,066 PSAY TR_PSEMA02 PICTURE "9999,999"
			@nLin,075 PSAY TR_MSEMA02 PICTURE "9999,999"
			IF 	_cCond1 == alltrim(TR_CODPROD)
				@nLin,084 PSAY TR_MSEMA02 / TR_MSEMA02	PICTURE "99.99"
			Else
				@nLin,084 PSAY TR_MSEMA02 / _V2	PICTURE "99.99"
			Endif
			@nLin,090 PSAY "|"
			
			@nLin,092 PSAY TR_PSEMA03 PICTURE "9999,999"
			@nLin,101 PSAY TR_MSEMA03 PICTURE "9999,999"
			IF 	_cCond1 == alltrim(TR_CODPROD)
				@nLin,110 PSAY TR_MSEMA03 / TR_MSEMA03 PICTURE "99.99"
			Else
				@nLin,110 PSAY TR_MSEMA03 / _V3 PICTURE "99.99"
			Endif
			@nLin,116 PSAY "|"
			
			@nLin,118 PSAY TR_PSEMA04 PICTURE "9999,999"
			@nLin,127 PSAY TR_MSEMA04 PICTURE "9999,999"
			IF 	_cCond1 == alltrim(TR_CODPROD)
				@nLin,136 PSAY TR_MSEMA04 / TR_MSEMA04 	PICTURE "99.99"
			Else
				@nLin,136 PSAY TR_MSEMA04 / _V4	PICTURE "99.99"
			Endif
			@nLin,142 PSAY "|"
			
			@nLin,144 PSAY TR_PSEMA05 PICTURE "9999,999"
			@nLin,154 PSAY TR_MSEMA05 PICTURE "9999,999"
			IF 	_cCond1 == alltrim(TR_CODPROD)
				@nLin,162 PSAY TR_MSEMA05 / TR_MSEMA05 PICTURE "99.99"
			Else
				@nLin,162 PSAY TR_MSEMA05 / _V5 PICTURE "99.99"
			Endif
			@nLin,168 PSAY "|"
			
			@nLin,169 PSAY TR_PACUMUL PICTURE "99999,999"
			@nLin,178 PSAY TR_MACUMUL PICTURE "99999,999"
			IF 	_cCond1 == alltrim(TR_CODPROD)
				@nLin,189 PSAY TR_MACUMUL / TR_MACUMUL PICTURE "99.99"
			Else
				@nLin,189 PSAY TR_MACUMUL / _V6 PICTURE "99.99"
			Endif
			@nLin,194 PSAY "|"
			
			nLin := nLin + 1
			dbSelectArea("TEMP")
			
			_TP1sema  := _TP1sema + TR_PSEMA01
			_TP2sema  := _TP2sema + TR_PSEMA02
			_TP3sema  := _TP3sema + TR_PSEMA03
			_TP4sema  := _TP4sema + TR_PSEMA04
			_TP5sema  := _TP5sema + TR_PSEMA05
			_TPAcumu  := _TPAcumu + TR_PACUMUL
			
			_TV1sema  := _TV1sema + TR_VSEMA01
			_TV2sema  := _TV2sema + TR_VSEMA02
			_TV3sema  := _TV3sema + TR_VSEMA03
			_TV4sema  := _TV4sema + TR_VSEMA04
			_TV5sema  := _TV5sema + TR_VSEMA05
			_TVAcumu  := _TVAcumu + TR_VACUMUL
			
			_TM1sema  := _TV1SEMA / _TP1SEMA
			_TM2sema  := _TV2SEMA / _TP2SEMA
			_TM3sema  := _TV3SEMA / _TP3SEMA
			_TM4sema  := _TV4SEMA / _TP4SEMA
			_TM5sema  := _TV5SEMA / _TP5SEMA
			_TMACUMU  := _TVACUMU / _TPACUMU
			
			dBSkip()
			
		Enddo
		@nLin,000 PSAY "|"
		@nLin,010 PSAY " TOTAL SUB GRUPO "
		@nLin,038 PSAY "|"
		_nMedia	:=	_TV1SEMA /	_TP1SEMA
		@nLin,040 PSAY _TP1SEMA PICTURE "9999,999"
		@nLin,049 PSAY _nMedia 	PICTURE "9999.999"
		@nLin,058 PSAY _nMedia / (_V1/1000) PICTURE "99.99"
		
		_nMedia	:=	_TV2SEMA /	_TP2SEMA
		@nLin,064 PSAY "|"
		@nLin,066 PSAY _TP2SEMA PICTURE "9999,999"
		@nLin,075 PSAY _nMedia 	PICTURE "9999.999"
		@nLin,084 PSAY _nMedia / (_V2/1000) PICTURE "99.99"
		
		_nMedia	:=	_TV3SEMA /	_TP3SEMA
		@nLin,090 PSAY "|"
		@nLin,092 PSAY _TP3SEMA PICTURE "9999,999"
		@nLin,101 PSAY _nMedia 	PICTURE "9999.999"
		@nLin,110 PSAY _nMedia / (_V3/1000) PICTURE "99.99"
		
		_nMedia	:=	_TV4SEMA /	_TP4SEMA
		@nLin,116 PSAY "|"
		@nLin,118 PSAY _TP4SEMA PICTURE "9999,999"
		@nLin,127 PSAY _nMedia 	PICTURE "9999.999"
		@nLin,136 PSAY _nMedia / (_V4/1000) PICTURE "99.99"
		
		_nMedia	:=	_TV5SEMA /	_TP5SEMA
		@nLin,142 PSAY "|"
		@nLin,144 PSAY _TP5SEMA PICTURE "9999,999"
		@nLin,154 PSAY _nMedia 	PICTURE "9999.999"
		@nLin,162 PSAY _nMedia / (_V5/1000) PICTURE "99.99"
		
		_nMedia	:=	_TVACUMU /	_TPACUMU
		@nLin,168 PSAY "|"
		@nLin,169 PSAY _TPACUMU PICTURE "99999,999"
		@nLin,179 PSAY _nMedia 	PICTURE "9999.999"
		@nLin,189 PSAY _nMedia / (_V6/1000) PICTURE "99.99"
		@nLin,194 PSAY "|"
		
		//ACUMULADORES DO GRUPO
		_nTGPP1		:=	_nTGPP1	+  _TP1SEMA
		_nTGPP2		:=	_nTGPP2	+  _TP2SEMA
		_nTGPP3		:=	_nTGPP3	+  _TP3SEMA
		_nTGPP4		:=	_nTGPP4	+  _TP4SEMA
		_nTGPP5		:=	_nTGPP5	+  _TP5SEMA
		_nTGPPa		:=	_nTGPPa	+  _TPACUMU
		
		_nTGPV1		:=	_nTGPV1	+  _TV1SEMA
		_nTGPV2		:=	_nTGPV2	+  _TV2SEMA
		_nTGPV3		:=	_nTGPV3	+  _TV3SEMA
		_nTGPV4		:=	_nTGPV4	+  _TV4SEMA
		_nTGPV5		:=	_nTGPV5	+  _TV5SEMA
		_nTGPVa		:=	_nTGPVa	+  _TVACUMU
		
		_TG1sema  := _TM1SEMA / _TP1SEMA
		_TG2sema  := _TM2SEMA / _TP2SEMA
		_TG3sema  := _TM3SEMA / _TP3SEMA
		_TG4sema  := _TM4SEMA / _TP4SEMA
		_TG5sema  := _TM5SEMA / _TP5SEMA
		_TGACUMU  := _TMACUMU / _TPACUMU
		
		nLin := nLin + 1
		@nLin,000 PSAY "|"+Replic("=",193)+"|"
		nLin      := nLin + 1
		
		//
		IF _GrupoQbrP < "0490" .OR. (_GrupoQbrP >= "0600" .AND. _GrupoQbrP <= "0899") //_GrupoQbrP < "0490"  // GRUPO FRANGO
			//		IF VAL(_GRUPO) < 49  // GRUPO FRANGO
			
			_TGP1FRANGO := _TGP1FRANGO + _TP1SEMA
			_TGP2FRANGO := _TGP2FRANGO + _TP2SEMA
			_TGP3FRANGO := _TGP3FRANGO + _TP3SEMA
			_TGP4FRANGO := _TGP4FRANGO + _TP4SEMA
			_TGP5FRANGO := _TGP5FRANGO + _TP5SEMA
			_TGPAFRANGO := _TGPAFRANGO + _TPACUMU
			
			_TGV1FRANGO := _TGV1FRANGO + _TV1SEMA
			_TGV2FRANGO := _TGV2FRANGO + _TV2SEMA
			_TGV3FRANGO := _TGV3FRANGO + _TV3SEMA
			_TGV4FRANGO := _TGV4FRANGO + _TV4SEMA
			_TGV5FRANGO := _TGV5FRANGO + _TV5SEMA
			_TGVAFRANGO := _TGVAFRANGO + _TVACUMU
			
			_TGM1FRANGO := _TGV1FRANGO / _TGP1FRANGO * 1000
			_TGM2FRANGO := _TGV2FRANGO / _TGP2FRANGO * 1000
			_TGM3FRANGO := _TGV3FRANGO / _TGP3FRANGO * 1000
			_TGM4FRANGO := _TGV4FRANGO / _TGP4FRANGO * 1000
			_TGM5FRANGO := _TGV5FRANGO / _TGP5FRANGO * 1000
			_TGMAFRANGO := _TGVAFRANGO / _TGPAFRANGO * 1000
			
			//		ENDIF
			
			//		IF VAL(_GRUPO) >=50 .AND. VAL(_GRUPO) < 89  // GRUPO EMBUTIDO
		ELSEIF _GrupoQbrP ="0500" //_GrupoQbrP >="0500" .AND. _GrupoQbrP < "0890"  // GRUPO EMBUTIDO
			
			_TGP1EMBUTI := _TGP1EMBUTI + _TP1SEMA
			_TGP2EMBUTI := _TGP2EMBUTI + _TP2SEMA
			_TGP3EMBUTI := _TGP3EMBUTI + _TP3SEMA
			_TGP4EMBUTI := _TGP4EMBUTI + _TP4SEMA
			_TGP5EMBUTI := _TGP5EMBUTI + _TP5SEMA
			_TGPAEMBUTI := _TGPAEMBUTI + _TPACUMU
			
			_TGV1EMBUTI := _TGV1EMBUTI + _TV1SEMA
			_TGV2EMBUTI := _TGV2EMBUTI + _TV2SEMA
			_TGV3EMBUTI := _TGV3EMBUTI + _TV3SEMA
			_TGV4EMBUTI := _TGV4EMBUTI + _TV4SEMA
			_TGV5EMBUTI := _TGV5EMBUTI + _TV5SEMA
			_TGVAEMBUTI := _TGVAEMBUTI + _TVACUMU
			
			_TGM1EMBUTI := _TGV1EMBUTI / _TGP1EMBUTI * 1000
			_TGM2EMBUTI := _TGV2EMBUTI / _TGP2EMBUTI * 1000
			_TGM3EMBUTI := _TGV3EMBUTI / _TGP3EMBUTI * 1000
			_TGM4EMBUTI := _TGV4EMBUTI / _TGP4EMBUTI * 1000
			_TGM5EMBUTI := _TGV5EMBUTI / _TGP5EMBUTI * 1000
			_TGMAEMBUTI := _TGVAEMBUTI / _TGPAEMBUTI * 1000
			
			//		ENDIF
			
			//		IF VAL(_GrupoQbrP) >="0900 // GRUPO OUTROS
		&&Chamado 035064 - criar grupo legumes em separado.	
		ELSEIF _GrupoQbrP == "0919"  //>= "0920" .And. _GrupoQbrP <= "0929" // GRUPO LEGUMES
			
			_TGP1LEG := _TGP1LEG + _TP1SEMA
			_TGP2LEG := _TGP2LEG + _TP2SEMA
			_TGP3LEG := _TGP3LEG + _TP3SEMA
			_TGP4LEG := _TGP4LEG + _TP4SEMA
			_TGP5LEG := _TGP5LEG + _TP5SEMA
			_TGPALEG := _TGPALEG + _TPACUMU
			
			_TGV1LEG := _TGV1LEG + _TV1SEMA
			_TGV2LEG := _TGV2LEG + _TV2SEMA
			_TGV3LEG := _TGV3LEG + _TV3SEMA
			_TGV4LEG := _TGV4LEG + _TV4SEMA
			_TGV5LEG := _TGV5LEG + _TV5SEMA
			_TGVALEG := _TGVALEG + _TVACUMU
			
			_TGM1LEG := _TGV1LEG / _TGP1LEG * 1000
			_TGM2LEG := _TGV2LEG / _TGP2LEG * 1000
			_TGM3LEG := _TGV3LEG / _TGP3LEG * 1000
			_TGM4LEG := _TGV4LEG / _TGP4LEG * 1000
			_TGM5LEG := _TGV5LEG / _TGP5LEG * 1000
			_TGMALEG := _TGVALEG / _TGPALEG * 1000	
			
			
		ELSE
			_TGP1GRAXA := _TGP1GRAXA + _TP1SEMA
			_TGP2GRAXA := _TGP2GRAXA + _TP2SEMA
			_TGP3GRAXA := _TGP3GRAXA + _TP3SEMA
			_TGP4GRAXA := _TGP4GRAXA + _TP4SEMA
			_TGP5GRAXA := _TGP5GRAXA + _TP5SEMA
			_TGPAGRAXA := _TGPAGRAXA + _TPACUMU
			
			_TGV1GRAXA := _TGV1GRAXA + _TV1SEMA
			_TGV2GRAXA := _TGV2GRAXA + _TV2SEMA
			_TGV3GRAXA := _TGV3GRAXA + _TV3SEMA
			_TGV4GRAXA := _TGV4GRAXA + _TV4SEMA
			_TGV5GRAXA := _TGV5GRAXA + _TV5SEMA
			_TGVAGRAXA := _TGVAGRAXA + _TVACUMU
			
			_TGM1GRAXA := _TGV1GRAXA / _TGP1GRAXA * 1000
			_TGM2GRAXA := _TGV2GRAXA / _TGP2GRAXA * 1000
			_TGM3GRAXA := _TGV3GRAXA / _TGP3GRAXA * 1000
			_TGM4GRAXA := _TGV4GRAXA / _TGP4GRAXA * 1000
			_TGM5GRAXA := _TGV5GRAXA / _TGP5GRAXA * 1000
			_TGMAGRAXA := _TGVAGRAXA / _TGPAGRAXA * 1000
			
			
		ENDIF
		
	enddo
	If nLin > 60
		Imp0Cabec()
		nLin := nLin + 1
	Endif
	
	_nTGPV1	:=	_nTGPV1 / _nTGPP1
	_nTGPV2	:=	_nTGPV2 / _nTGPP2
	_nTGPV3	:=	_nTGPV3 / _nTGPP3
	_nTGPV4	:=	_nTGPV4 / _nTGPP4
	_nTGPV5	:=	_nTGPV5 / _nTGPP5
	_nTGPVa	:=	_nTGPVa / _nTGPPa
	_nPerc	:=	_nTGPV1 / (_V1/1000)
	
	
	@nLin,000 PSAY "|"
	@nLin,001 PSAY "TOTAL GRUPO " +_GrupoQbrP+" "+_cDescr
	@nLin,038 PSAY "|"
	@nLin,040 PSAY _nTGPP1 			PICTURE "9999,999"
	@nLin,049 PSAY _nTGPV1 			PICTURE "9999.999"
	@nLin,058 PSAY _nPerc        	PICTURE "99.99"
	
	_nPerc	:=	_nTGPV2 / (_V2/1000)
	@nLin,064 PSAY "|"
	@nLin,066 PSAY _nTGPP2 			PICTURE "9999,999"
	@nLin,075 PSAY _nTGPV2 			PICTURE "9999.999"
	@nLin,084 PSAY _nPerc 			PICTURE "99.99"
	
	_nPerc	:=	_nTGPV3 / (_V3/1000)
	@nLin,090 PSAY "|"
	@nLin,092 PSAY _nTGPP3 		 	PICTURE "9999,999"
	@nLin,101 PSAY _nTGPV3 			PICTURE "9999.999"
	//	@nLin,110 PSAY _nTGPV3 / _V3 	PICTURE "99.99"
	@nLin,110 PSAY _nPerc		 	PICTURE "99.99"
	
	_nPerc	:=	_nTGPV4 / (_V4/1000)
	@nLin,116 PSAY "|"
	@nLin,118 PSAY _nTGPP4			PICTURE "9999,999"
	@nLin,127 PSAY _nTGPV4 			PICTURE "9999.999"
	//	@nLin,136 PSAY _nTGPV4 / _V4 	PICTURE "99.99"
	@nLin,136 PSAY _nPerc		 	PICTURE "99.99"
	
	_nPerc	:=	_nTGPV5 / (_V5/1000)
	@nLin,142 PSAY "|"
	@nLin,144 PSAY _nTGPP5 			PICTURE "9999,999"
	@nLin,153 PSAY _nTGPV5 			PICTURE "9999.999"
	//	@nLin,162 PSAY _nTGPV5 / _V5 	PICTURE "99.99"
	@nLin,162 PSAY _nPerc		 	PICTURE "99.99"
	
	_nPerc	:=	_nTGPVa / (_V6/1000)
	@nLin,168 PSAY "|"
	@nLin,169 PSAY _nTGPPa 			PICTURE "99999,999" 
	@nLin,179 PSAY _nTGPVa 			PICTURE "9999.999"
	@nLin,189 PSAY _nPerc		 	PICTURE "99.99"
	//	@nLin,189 PSAY _nTGPVa / _V6 	PICTURE "99.99"
	@nLin,194 PSAY "|"
	_GrupoQbrP	:=	TR_GRUPOP
	nLin := nLin + 1
	@nLin,000 PSAY "|"+Replic("_",193)+"|"
	nLin      := nLin + 1
EndDo

@nLin,000 PSAY "|"+Replic("=",193)+"|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,010 PSAY " TOTAL GRUPO FRANGO "
@nLin,038 PSAY "|"
@nLin,040 PSAY _TGP1FRANGO PICTURE "9999999"
@nLin,048 PSAY _TGM1FRANGO PICTURE "9999999"
@nLin,058 PSAY _TGM1FRANGO / _V1 PICTURE "99.99"
@nLin,064 PSAY "|"
@nLin,067 PSAY _TGP2FRANGO PICTURE "9999999"
@nLin,075 PSAY _TGM2FRANGO PICTURE "9999999"
@nLin,085 PSAY _TGM2FRANGO / _V2 PICTURE "99.99"
@nLin,090 PSAY "|"
@nLin,093 PSAY _TGP3FRANGO PICTURE "9999999"
@nLin,101 PSAY _TGM3FRANGO PICTURE "9999999"
@nLin,111 PSAY _TGM3FRANGO  / _V3 PICTURE "99.99"
@nLin,116 PSAY "|"
@nLin,118 PSAY _TGP4FRANGO PICTURE "9999999"
@nLin,127 PSAY _TGM4FRANGO PICTURE "9999999"
@nLin,137 PSAY _TGM4FRANGO / _V4 PICTURE "99.99"
@nLin,142 PSAY "|"
@nLin,145 PSAY _TGP5FRANGO PICTURE "9999999"
@nLin,153 PSAY _TGM5FRANGO PICTURE "9999999"
@nLin,163 PSAY _TGM5FRANGO / _V5 PICTURE "99.99"
@nLin,168 PSAY "|"
//@nLin,171 PSAY _TGPAFRANGO PICTURE "9999999" // ALTERADO LEONARDO (HC) PARA AUMENTO DA PICTURE
@nLin,171 PSAY _TGPAFRANGO PICTURE "99999999"
@nLin,179 PSAY _TGMAFRANGO PICTURE "9999999"
@nLin,189 PSAY _TGMAFRANGO / _V6 PICTURE "99.99"
@nLin,194 PSAY "|"

nLin := nLin + 1
@nLin,038 PSAY "|"
@nLin,064 PSAY "|"
@nLin,090 PSAY "|"
@nLin,116 PSAY "|"
@nLin,142 PSAY "|"
@nLin,168 PSAY "|"
@nLin,000 PSAY "|"
@nLin,010 PSAY " TOTAL GRUPO EMBUTIDOS "
@nLin,038 PSAY "|"
@nLin,040 PSAY _TGP1EMBUTI PICTURE "9999999"
@nLin,048 PSAY _TGM1EMBUTI PICTURE "9999999"
@nLin,058 PSAY _TGM1EMBUTI / _V1 PICTURE "99.99"
@nLin,064 PSAY "|"
@nLin,067 PSAY _TGP2EMBUTI PICTURE "9999999"
@nLin,075 PSAY _TGM2EMBUTI PICTURE "9999999"
@nLin,085 PSAY _TGM2EMBUTI / _V2 PICTURE "99.99"
@nLin,090 PSAY "|"
@nLin,093 PSAY _TGP3EMBUTI PICTURE "9999999"
@nLin,101 PSAY _TGM3EMBUTI PICTURE "9999999"
@nLin,111 PSAY _TGM3EMBUTI  / _V3 PICTURE "99.99"
@nLin,116 PSAY "|"
@nLin,118 PSAY _TGP4EMBUTI PICTURE "9999999"
@nLin,127 PSAY _TGM4EMBUTI PICTURE "9999999"
@nLin,137 PSAY _TGM4EMBUTI / _V4 PICTURE "99.99"
@nLin,142 PSAY "|"
@nLin,145 PSAY _TGP5EMBUTI PICTURE "9999999"
@nLin,153 PSAY _TGM5EMBUTI PICTURE "9999999"
@nLin,163 PSAY _TGM5EMBUTI / _V5 PICTURE "99.99"
@nLin,168 PSAY "|"
@nLin,171 PSAY _TGPAEMBUTI PICTURE "9999999"
@nLin,179 PSAY _TGMAEMBUTI PICTURE "9999999"
@nLin,189 PSAY _TGMAEMBUTI / _V6 PICTURE "99.99"
@nLin,194 PSAY "|"

nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,010 PSAY " TOTAL GRUPO GRAXARIA "
@nLin,038 PSAY "|"
@nLin,040 PSAY _TGP1GRAXA PICTURE "9999999"
@nLin,048 PSAY _TGM1GRAXA PICTURE "9999999"
@nLin,058 PSAY _TGM1GRAXA / _V1 PICTURE "99.99"
@nLin,064 PSAY "|"
@nLin,067 PSAY _TGP2GRAXA PICTURE "9999999"
@nLin,075 PSAY _TGM2GRAXA PICTURE "9999999"
@nLin,085 PSAY _TGM2GRAXA / _V2 PICTURE "99.99"
@nLin,090 PSAY "|"
@nLin,093 PSAY _TGP3GRAXA PICTURE "9999999"
@nLin,101 PSAY _TGM3GRAXA PICTURE "9999999"
@nLin,111 PSAY _TGM3GRAXA  / _V3 PICTURE "99.99"
@nLin,116 PSAY "|"
@nLin,118 PSAY _TGP4GRAXA PICTURE "9999999"
@nLin,127 PSAY _TGM4GRAXA PICTURE "9999999"
@nLin,137 PSAY _TGM4GRAXA / _V4 PICTURE "99.99"
@nLin,142 PSAY "|"
@nLin,145 PSAY _TGP5GRAXA PICTURE "9999999"
@nLin,153 PSAY _TGM5GRAXA PICTURE "9999999"
@nLin,163 PSAY _TGM5GRAXA / _V5 PICTURE "99.99"
@nLin,168 PSAY "|"
@nLin,171 PSAY _TGPAGRAXA PICTURE "9999999"
@nLin,179 PSAY _TGMAGRAXA PICTURE "9999999"
@nLin,189 PSAY _TGMAGRAXA / _V6 PICTURE "99.99"
@nLin,194 PSAY "|"

&&Chamado 035064 - Criado totalizador legumes
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,010 PSAY " TOTAL GRUPO LEGUMES "
@nLin,038 PSAY "|"
@nLin,040 PSAY _TGP1LEG PICTURE "9999999"
@nLin,048 PSAY _TGM1LEG PICTURE "9999999"
@nLin,058 PSAY _TGM1LEG / _V1 PICTURE "99.99"
@nLin,064 PSAY "|"
@nLin,067 PSAY _TGP2LEG PICTURE "9999999"
@nLin,075 PSAY _TGM2LEG PICTURE "9999999"
@nLin,085 PSAY _TGM2LEG / _V2 PICTURE "99.99"
@nLin,090 PSAY "|"
@nLin,093 PSAY _TGP3LEG PICTURE "9999999"
@nLin,101 PSAY _TGM3LEG PICTURE "9999999"
@nLin,111 PSAY _TGM3LEG  / _V3 PICTURE "99.99"
@nLin,116 PSAY "|"
@nLin,118 PSAY _TGP4LEG PICTURE "9999999"
@nLin,127 PSAY _TGM4LEG PICTURE "9999999"
@nLin,137 PSAY _TGM4LEG / _V4 PICTURE "99.99"
@nLin,142 PSAY "|"
@nLin,145 PSAY _TGP5LEG PICTURE "9999999"
@nLin,153 PSAY _TGM5LEG PICTURE "9999999"
@nLin,163 PSAY _TGM5LEG / _V5 PICTURE "99.99"
@nLin,168 PSAY "|"
@nLin,171 PSAY _TGPALEG PICTURE "9999999"
@nLin,179 PSAY _TGMALEG PICTURE "9999999"
@nLin,189 PSAY _TGMALEG / _V6 PICTURE "99.99"
@nLin,194 PSAY "|"
nLin := nLin + 1

@nLin,000 PSAY "|"+Replic("=",193)+"|"

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(NomeRel)
endif

dbSelectArea("SD2")
set filter to

dbSelectArea("SF2")
dbSetOrder(1)
//                      
dbSelectArea('TEMP')
dbclosearea("TEMP")      
fErase(_cNomTrb+'.*')

return

******************************************************************************
// Substituido pelo assistente de conversao do AP5 IDE em 14/05/01 ==> Function ImpCabec
******************************************************************************

Static Function Imp0Cabec()
cCabec1 := space(70) + "Periodo de : "+dtoc(mv_par01)+" Ate : "+dtoc(mv_par02) + "      Ref.: " + _cGRUPOP+"/"+_cGRUPOF+"/"+_cGRUPON+"/"+_cProdBase
nLin	:=	Cabec(cTitulo,cCabec1,cCabec2,cPrograma,cTamanho)
//nLin := 1
//@nlin,00 PSAY Cabec01
//nLin := nLin + 1
//@nLin,00 PSAY Cabec02
//nLin := nLin + 1
//@nLin,00 PSAY Cabec03
nLin := nLin + 1
@nLin,00 PSAY Cabec04
nLin := nLin + 1
@nLin,00 PSAY Cabec05
nLin := nLin + 1
@nLin,00 PSAY Cabec06
nLin := nLin + 1
@nLin,00 PSAY Cabec07
nLin := nLin + 1
@nLin,00 PSAY Cabec08
nLin := nLin + 1
@nLin,00 PSAY Cabec09

Return


STATIC FUNCTION PROCURAGRUPO

dbSelectArea("SBM")
dbSeek(xfilial() + _cGRUPON )
_DesGrpN	 	:=	SBM->BM_DESC
//					IF alltrim(_Produto) ="47"
//						msgstop(_Produto)
//					endif
Do While !EOF() .AND. !BOF()
	If 	SBM->BM_NIVEL	== "2"
		_cGrupoF				:=	SBM->BM_GRUPO
		_DesGrpF				:=	SBM->BM_DESC
		dbskip(-1)
		Do While !EOF()
			If 	SBM->BM_NIVEL	== "1"
				_cGrupoP				:=	SBM->BM_GRUPO
				_DesGrpP				:=	SBM->BM_DESC
				Exit
			else
				dbskip(-1)
			Endif
		Enddo
		Exit
	Else
		dbskip(-1)
	Endif
Enddo
RETURN

STATIC FUNCTION MONTABASE

_cProdBase		:=	MV_PAR03

dbSelectArea("SB1")
DbsetOrder(1)
dbSeek(xFilial("SB1")+_cProdBase)
_cB1Grupo	:=	SB1->B1_GRUPO  //  ALTERADO EM  28/12/06 XGRPANT PRESERVA GRUPO
//_cB1Grupo	:=	SB1->B1_XGRPANT    
_cGRUPON 	:=	_cB1Grupo

PROCURAGRUPO()

dbSelectArea("TEMP")
If dbSeek(_cGRUPOP+_cGRUPOF+_cGRUPON+_cProdBase)
	_v1 := TR_MSEMA01
	_v2 := TR_MSEMA02
	_v3 := TR_MSEMA03
	_v4 := TR_MSEMA04
	_v5 := TR_MSEMA05
	_v6 := TR_MACUMUL
ELSE
	_v1 := 1
	_v2 := 1
	_v3 := 1
	_v4 := 1
	_v5 := 1
	_v6 := 1
ENDIF
dbGoTop()
return
