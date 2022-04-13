#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ AD0075   บ Autor ณ Daniel             บ Data ณ  14/03/06   บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDescricao ณ Resumo de Descontos e Acrescimos                           บฑฑ
//ฑฑบ          ณ                                                            บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ Logistica                                                  บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

/*
+----------------------------------------------------------------------------+
|                                 MANUTENCAO                                 |
+----------------------------------------------------------------------------+
|[1]   |TROCADO RETORNO DE DADOS POR UMA QUERY |14/03/06 |DANIEL P. SILVEIRA |
+----------------------------------------------------------------------------+
@history ticket 70750 - Everson - 07/04/2022 - Adapta็ใo do fonte para nova filial.
*/
User Function AD0075
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Resumo de Descontos e Acrescimos')

cPerg   := "AD0075"
Pergunte(cPerg,.F.)

//ณ Variaveis utilizadas para parametros                         ณ
//ณ mv_par01             // Data de                              |
//ณ mv_par02             // Data ate                             ณ
//| mv_par03			 // Tipo de Frete						 |

cDesc1         := "Este programa tem como objetivo imprimir relatorio "
cDesc2         := "de acordo com os parametros informados pelo usuario."
cDesc3         := "Resumo de Descontos e Acrescimos"
cPict          := ""
titulo         := "Resumo de Descontos e Acrescimos"
nLin           := 80
Cabec1         := ""
Cabec2         := ""
imprime        := .T.
aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "AD0075" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "AD0075" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString:=""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := SetPrint(cString,NomeProg,"AD0075",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
nTipo := If(aReturn[4]==1,15,18)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  22/08/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem

_dDtEntr1 := mv_par01
_dDtEntr2 := mv_par02

Cabec1  := space(20)+ "Periodo de : " + DTOC(_dDtEntr1) + space(5) + " Ate : " + DTOC(_dDtEntr2)
Cabec3  := "|---------------------------------------------------------------------------------|"
Cabec4  := "|             DESCRICAO             |       DESCONTOS      |       ACRESCIMOS     |"
Cabec5  := "|---------------------------------------------------------------------------------|"

//Cabec7  := "|=========================================================================================|"
//Cabec8  := "|  TOTAL     |                              |                      |
//Cabec9  := "|=========================================================================================|"

//          0         1         2         3         4         5         6         7         8         9         10
//          012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234    
//
                  
_nTotDesc  := 0                                                                                  
_nTotAcr   := 0

cQuery:=" SELECT  ZJ_CODIGO,ZJ_DESCRIC,ZK_TIPFRT, "+;
" (CASE WHEN ZI_TIPO='A' THEN SUM(ZI_VALOR) ELSE 0 END) AS ACRESCIMO, " +;
" (CASE WHEN ZI_TIPO='D' THEN SUM(ZI_VALOR) ELSE 0 END) AS DESCONTO  " +;
" FROM "+RETSQLNAME("SZJ")+","+RETSQLNAME("SZK")+","+RETSQLNAME("SZI")+" " +;      
" WHERE "+;
" ZK_FILIAL = '" + FWxFilial("SZK") + "' AND ZJ_FILIAL = '" + FWxFilial("SZJ") + "' AND ZI_FILIAL = '" + FWxFilial("SZI") + "' "+; //ticket 70750 - Everson - 07/04/2022.
" AND ZJ_CODIGO=ZI_CODIGO " +; 
" AND ZK_GUIA=ZI_GUIA " +; 
" AND ZK_ROTEIRO = ZI_ROTEIRO " +;  
" AND ZK_PLACAPG = ZI_PLACA " +;                                                 
" AND ZK_TIPFRT<>'' " +;  
" AND ZK_TIPFRT='"+UPPER(MV_PAR03)+"' "+;
" AND( ZI_DATALAN >='"+DTOS(MV_PAR01)+"' AND ZI_DATALAN <='"+DTOS(MV_PAR02)+"')  "+;
" AND "+RETSQLNAME("SZJ")+".D_E_L_E_T_<>'*' " +;
" AND "+RETSQLNAME("SZI")+".D_E_L_E_T_<>'*' " +;
" AND "+RETSQLNAME("SZK")+".D_E_L_E_T_<>'*' " +;
" GROUP BY ZJ_CODIGO,ZJ_DESCRIC,ZI_TIPO,ZK_TIPFRT "+;
" ORDER BY ZJ_CODIGO "

TCQUERY cQuery new Alias "DEAC"     

DbSelectArea("DEAC")
dbGoTop()
While !eof()
	                       
   _nTotAcr +=DEAC->ACRESCIMO  //total do acrescimo
//   _nTotDesc+=DEAC->DESCONTO   //total do desconto
   _nTotDesc := _nTotDesc + DEAC->DESCONTO

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   If nLin > 65
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
      @nLin,000 PSAY CABEC3
      nLin := nLin + 1
      @nLin,000 PSAY CABEC4
      nLin := nLin + 1
      @nLin,000 PSAY CABEC5
      nLin := nLin + 1
   Endif
	
// Detalhe do Tipo do Lancamento    
	
   @nLin,000 PSAY "|"
   @nLin,002 PSAY DEAC->ZJ_CODIGO + " " + SUBSTR (DEAC->ZJ_DESCRIC,1,30)
   @nLin,036 PSAY "|"  
   @nLin,045 PSAY DEAC->DESCONTO PICTURE "@E 9,999,999.99"
   @nLin,059 PSAY "|"
   @nLin,068 PSAY DEAC->ACRESCIMO PICTURE "@E 9,999,999.99"
   @nLin,082 PSAY "|"
   nLin := nLin + 1
   @nLin,000 PSAY "|" + REPLICATE ("-",81)+ "|"
   nLin := nLin + 1

	
   dbselectarea("DEAC")
   dbskip()
Enddo
                                 

//fechando area em uso
DbCloseArea("DEAC")
DbCloseArea("TFRT")
@nLin,000 PSAY "|" + REPLICATE ("-",81)+ "|"
nLin := nLin + 1
@nLin,000 PSAY "|"
@nLin,082 PSAY "|"
nLin := nLin + 1
@nLin,000 PSAY "|" +" "+ "TOTAL GERAL =>"
@nLin,036 PSAY "|"
@nLin,045 PSAY _nTotDesc PICTURE "@E 9,999,999.99"    
@nLin,059 PSAY "|"
@nLin,068 PSAY _nTotAcr PICTURE "@E 9,999,999.99"
@nLin,082 PSAY "|"
nLin := nLin + 1
@nLin,000 PSAY "|"+ REPLICATE ("_",81)+ "|"
nLin := nLin + 1

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return
