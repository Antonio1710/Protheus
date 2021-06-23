#INCLUDE "rwmake.ch"

/*{Protheus.doc} User Function AD0125
	Relatório de Solicitação de Armazém
	@type  Function
	@author Desconhecido
	@since 16/03/2018
	@version 01
	@history TICKET 6105 - William Costa - 09/12/2020 - Aumentei o Tamanho do Campo de Endereço de 17 para 19 Caracteres.Retirei os Espaços em Branco do Endereço, assim fica mais caracter para ser mostrado do Endereço.Retirei 2 espaços no final da Observação, para poder aumentar o Endereço.Adicionei uma linha para separação entre um produto e outro da S.A, acho que fica mais Fácil de Ler.
	
*/

User Function AD0125()

	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "Requisição ao Almoxarifado"
	Local cPict         := ""
	Local titulo        := "Requisição ao Almoxarifado"
	Local nLin          := 80
	Local Cabec1        := ""
	Local Cabec2        := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 80
	Private tamanho     := "P"
	Private nomeprog    := "AD0125" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "AD0125" // Coloque aqui o nome do arquivo usado para impressao em disco
	
	Private cString := "SCP"
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Requisição ao Almoxarifado')
	   
	dbSelectArea("SCP")
	dbSetOrder(1)
	
	//Monta a interface padrao com o usuario...                           
	
	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	//Processamento. RPTSTATUS monta janela com a regua de processamento. 
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local CcnumCP
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	//SETREGUA -> Indica quantos registros serao processados para a regua 
	
	SetRegua(RecCount())
	
	If lAbortPrint
    	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
        //Exit
    Endif

    //Impressao do cabecalho do relatorio. . .                            
    
    If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
    	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    	nLin := 5
    Endif

    // Coloque aqui a logica da impressao do seu programa...
    // Utilize PSAY para saida na impressora. Por exemplo:
   
    CcnumCP := SCP->CP_NUM 
    @ nLin,000 PSAY "CONTROLE DE REQUISICAO AO ALMOXARIFADO"
    nLin := nLin + 1 // Avanca a linha de impressao
	@ nLin,000 PSAY "ADORO S/A                   "+ DTOC(DATE())
	nLin := nLin + 1 // Avanca a linha de impressao
	@ nLin,000 PSAY "AD0125                      "+TIME()
	nLin := nLin + 2 // Avanca a linha de impressao
	@ nLin,000 PSAY "Usuario       :"+_cAutNome
	nLin := nLin + 1 // Avanca a linha de impressao
	@ nLin,000 PSAY "Requisicao    :"+SCP->CP_NUM  +" Emissao     :"+DTOC(SCP->CP_EMISSAO)
	nLin := nLin + 1 // Avanca a linha de impressao
	@ nLin,000 PSAY "Ordem Servico :"+SCP->CP_NUMOS 													
	nLin := nLin + 1 // Avanca a linha de impressao
	@ nLin,000 PSAY "Setor         :"+ SCP->CP_CC  +" Solicitante :"+SCP->CP_SOLICIT			
	nLin := nLin + 3 // Avanca a linha de impressao
	@ nLin,000 PSAY "Produto Endereco             Un. Requ. Atend. OBS"										
	nLin := nLin + 1 // Avanca a linha de impressao
	@ nLin,000 PSAY "======= ==================   === ===== ====== =================================="
	nLin := nLin + 1 // Avanca a linha de impressao
	   
	WHILE  SCP->CP_NUM == CcnumCP
	
		@ nLin,000 PSAY SUBSTR(SCP->CP_PRODUTO,1,8)
		@ nLin,008 PSAY SUBSTR(ALLTRIM(STRTRAN(SCP->CP_LOCALMX,' ','')),1,19)
		@ nLin,029 PSAY SCP->CP_UM
		@ nLin,033 PSAY SCP->CP_QUANT
		
		IF SCP->CP_QUJE > 0
		
			@ nLin,039 PSAY SCP->CP_QUJE
			
		ENDIF
		
		@ nLin,046 PSAY SUBSTR(SCP->CP_OBS,1,35)
		
		nLin = nLin + 1
		                            
		@ nLin,000 PSAY ALLTRIM(SCP->CP_DESCRI	)
		
		nLin = nLin + 1

		@ nLin,000 PSAY "________________________________________________________________________________"

		nLin = nLin + 1
	 					
	    //Verifica o cancelamento pelo usuario...                             
	    
	    IF lAbortPrint
	   
	      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
    	  EXIT
    	  
	    ENDIF
	   
        DBSKIP()
       
	ENDDO
	
	nLin := nLin + 3				
    @ nLin,002 PSAY "-----------------      ------------------"
	nlin := nlin + 2
   	@ nLin,002 PSAY "   ASSINATURA              ASSINATURA    "
   	nlin := nlin + 1
	@ nLin,002 PSAY "    RECEBIDO               ALMOXARIFE    "
	nLin := nLin + 1										
	
	//Finaliza a execucao do relatorio...                                 
	
	SET DEVICE TO SCREEN
	
	//Se impressao em disco, chama o gerenciador de impressao...          
	
	If aReturn[5]==1
	   dbCommitAll()
	   SET PRINTER TO
	   OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

RETURN(NIL)
