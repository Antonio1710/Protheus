#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE 'Parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "MSMGADD.CH"  
#INCLUDE "FWBROWSE.CH"   
#INCLUDE "DBINFO.CH"
#INCLUDE 'FILEIO.CH'
  
Static cTitulo      := "Extrato de Fechamento por Veículo"

/*/{Protheus.doc} User Function AD0052
	Extrato de Fechamento por Veiculo
	@type  Function
	@author Gustavo Gonela
	@since 18/07/2003
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history chamado 050729 - FWNM - 26/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function AD0052

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Extrato de Fechamento por Veiculo ')

	cPerg   := PADR("AD0052",10," ")

	//------------------------------------------
	// Adiciona pergunta para exportar Excel
	// HC CONSYS - 08/04/2009
	//------------------------------------------
	PutSx1(cPerg,"06","Exporta Ms-Excel ?  ","Exporta Ms-Excel ?  ","Exporta Ms-Excel ?  ","mv_ch6","N",1,0,1,"C","","","","","mv_par06",;
	"Sim   ","Sim   ","Sim ","","Nao       ","Nao        ","Nao  ","","","","","","","","","","","","","")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01             // Data de                              |
	//³ mv_par02             // Data ate                             ³
	//| mv_par03             // Placa de                             |
	//³ mv_par04             // Placa ate                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de acordo com os parametros informados pelo usuario."
	cDesc3       := "Extrato de Fechamento por Veiculo"
	cPict        := ""
	titulo       := "Extrato de Fechamento por Veiculo"
	nLin         := 80
	Cabec1       := ""
	Cabec2       := ""
	imprime      := .T.
	aOrd := {}

	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "P"
	Private nomeprog     := "AD0052" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "AD0052" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString := "SZK"
	Private oExcel := FWMsExcelEx():New()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//=========================================================
	// Cria arquivo temporario para ser exportado no Ms-Excel
	// HC CONSYS - 08/04/2009
	//=========================================================
	if mv_par06 == 1
		bBloco:={|| ArqTemp2()}
		MsAguarde(bBloco,"Aguarde...","Criando arquivo temporário...",.F.)
	endif

	//=======================================================================
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//=======================================================================
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	dbSelectArea(cString)
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(RecCount())

	// Parametros
	_dDtEntr  := mv_par01
	_dDtEntr2 := mv_par02
	_cVeic    := mv_par03
	_cVeic2   := mv_par04
	_cTipFrt  := mv_par05

	// Variaveis de Trabalho
	_nTotFret   := 0
	_nTotPeso   := 0
	_nEntr      := 0
	_nViag      := 0
	_nTotEntr   := 0
	_ntTKmpag   := 0
	_cTipVei    := space(2)


	//Cabec3  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)
	//Cabec4  := "Transportador: " + _cTransp_Tit + SPACE(05) +"Veiculo : " + _cVeic_Tit
	//Cabec5  := "|-----------------------------------------------------------------------------------------------------------------------------------------------|"
	//Cabec6  := "|   DATA    |      TOTAL FRETE       |      PESO       |  ENTR.  |      KM      |       DESCRICAO       |     ACRESCIMO     |     DESCONTO      |"
	//Cabec7  := "|-----------------------------------------------------------------------------------------------------------------------------------------------|"

	//Cabec7  := "|=============================================================================================================================================|"
	//Cabec8  := "|=============================================================================================================================================|"
	//Cabec9  := "|=============================================================================================================================================|"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicionamento do primeiro registro e loop principal. Pode-se criar ³
	//³ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ³
	//³ cessa enquanto a filial do registro for a filial corrente. Por exem ³
	//³ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ³
	//³                                                                     ³
	//³ dbSeek(xFilial())                                                   ³
	//³ While !EOF() .And. xFilial() == A1_FILIAL                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Cabec1  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)
	//Cabec2  := SPACE(02)+ "Transportador: " + _cTransp + SPACE(07) +"Veiculo : " +_cVeic
	Cabec3  := "|----------------------------------------------------------------------|"
	Cabec4  := "|   DATA     |   TOTAL FRETE   |     PESO      |  ENTR.  |     KM      |"
	Cabec5  := "|----------------------------------------------------------------------|"

	Cabec6  := "|------------------------------------------------------------------------------|"
	Cabec7  := "|   DATA    | TIPO |         DESCRICAO          |   ACRESCIMO   |   DESCONTO   |"
	Cabec8  := "|------------------------------------------------------------------------------|"

	Cabec9   := "Relacao dos Fretes"
	Cabec10  := "Relacao dos Descontos e Acrescimos"

	//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14
	//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234

	// Frete
	dbSelectArea("ZV4")
	dbSetOrder(1)  //   Indice Placa
	dbSeek(xFilial("ZV4")+_cVeic)
	DO While !EOF ()
		If ZV4_PLACA >=  _cVeic .AND. ZV4_PLACA <=  _cVeic2
			Cabec2  := SPACE(02)+ "Transportador: " + ZV4_FORNEC + "  " + SUBSTR(ZV4_NOMFOR,1,30) +"Veiculo : "+_cTipVei+" "+ZV4_PLACA
			_cTipVei  := ZV4->ZV4_TIPVEI
			_nTotFret := 0
			_cPrim   := 'S'
			//REMOVIDO
			//DANIEL 03/02/07
			/*
			dbSelectArea("SZK")
			dbSetOrder(09)  //   Indice Placa + Data
			dbSeek(xFilial("SZK")+ ZV4->ZV4_PLACA + dtos(_dDtEntr),.F.)
			*/
			
			//DANIEL  - INCCLUIDO
			//03/02/07
			cQuery:=""
			cQuery+=" SELECT * "
			cQuery+=" FROM "+retsqlname("SZK")+" "
			cQuery+=" WHERE "
			cQuery+=" ZK_PLACAPG='"+ZV4->ZV4_PLACA+"' "
			cQuery+=" AND (ZK_DTENTR BETWEEN '"+DTOS(_dDtEntr)+"' AND '"+DTOS(_dDtEntr2)+"') "
			cQuery+=" AND D_E_L_E_T_='' "
			cQuery+=" AND ZK_TIPFRT='"+_cTipFrt+"' "
			cQuery+=" ORDER BY ZK_PLACAPG+ZK_DTENTR+ZK_ROTEIRO "
			TCQUERY cQuery NEW Alias "TMP"
			DBSELECTAREA("TMP")
			DBGOTOP()
			
			DO While !EOF ()
				//DANIEL 03/02/07
				//REMOVIDO
				/*
				.and. TMP->ZK_PLACAPG = ZV4->ZV4_PLACA
				
				If  TMP->ZK_DTENTR >= DTOS(_dDtEntr) .and. TMP->ZK_DTENTR <= DTOS(_dDtEntr2)
				
				Despresa os Tipos de Frete que nao esta no parametro
				If !TMP->ZK_TIPFRT $_cTipFrt
				Dbskip()
				Loop
				ENDIF
				dbSelectArea("SZK")
				dbSetOrder(11)  //   Indice Placa + Data
				*/
				If nLin > 60  .OR. _cPrim  = 'S'
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
					@nLin,000 PSAY CABEC9
					nLin := nLin + 1
					@nLin,000 PSAY CABEC3
					nLin := nLin + 1
					@nLin,000 PSAY CABEC4
					nLin := nLin + 1
					@nLin,000 PSAY CABEC5
					nLin := nLin + 1
					_cPrim  = 'N'
				Endif
				
				//--------------------------------------------------
				// Atualiza arquivo temporario para exportar Excel
				//--------------------------------------------------
				if mv_par06 == 1
					dbSelectArea("TR2")
					recLock("TR2",.T.)
					replace TR2->COD_TRANSP with ZV4->ZV4_FORNEC
					replace TR2->NOM_TRANSP with ZV4->ZV4_NOMFOR
					replace TR2->VEICULO    with ZV4->ZV4_PLACA
					replace TR2->DATA_      with stod(TMP->ZK_DTENTR)
					replace TR2->TOT_FRETE  with TMP->ZK_VALFRET
					replace TR2->PESO       with TMP->ZK_PBRUTO
					replace TR2->ENTR       with TMP->ZK_ENTREGA - TMP->ZK_ENTRDEV
					replace TR2->KM         with TMP->ZK_KMPAG
					TR2->(msUnlock())
				endif
				
				//-- Imprime detalhes...
				dbSelectArea("TMP")
				@nLin,000 PSAY "|"
				@nLin,002 PSAY stod(TMP->ZK_DTENTR)
				@nLin,013 PSAY "|"
				@nLin,016 PSAY TMP->ZK_VALFRET   Picture "@E 999,999.99"
				@nLin,031 PSAY "|"
				@nLin,033 PSAY TMP->ZK_PBRUTO    Picture "@E 999,999.99"
				@nLin,047 PSAY "|"
				_nEntr := TMP->ZK_ENTREGA - TMP->ZK_ENTRDEV
				@nLin,048 PSAY _nEntr Picture "@E 9999"
				@nLin,057 PSAY "|"
				@nLin,058 PSAY TMP->ZK_KMPAG     Picture "@E 999,999.99"
				@nLin,071 PSAY "|"
				nLin := nLin + 1
				
				_nTotFret   += TMP->ZK_VALFRET
				_nTotPeso   += TMP->ZK_PBRUTO
				_ntTKmpag   += TMP->ZK_KMPAG
				_nTotEntr   +=_nEntr
				_nViag      += 1
				_nEntr      := 0
				//			Endif
				DbSkip()
			Enddo
			
			If nLin > 60
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
				@nLin,000 PSAY CABEC10
				nLin := nLin + 1
				@nLin,000 PSAY CABEC6
				nLin := nLin + 1
				@nLin,000 PSAY CABEC7
				nLin := nLin + 1
				@nLin,000 PSAY CABEC8
				nLin := nLin + 1
			Endif
			DBCLOSEAREA("TMP")
			IF _nTotFret > 0
				@nLin,000 PSAY "|"+ Replicate ("=",70)+ "|"
				nLin := nLin + 1
				@nLin,000 PSAY "|"
				@nLin,002 PSAY " TOTAL "
				@nLin,013 PSAY "|"
				@nLin,016 PSAY _nTotFret Picture "@E 999,999.99"
				@nLin,031 PSAY "|"
				@nLin,033 PSAY _nTotPeso  Picture "@E 999,999.99"
				@nLin,047 PSAY "|"
				@nLin,048 PSAY _nTotEntr  Picture "@E 9999"
				@nLin,057 PSAY "|"
				@nLin,058 PSAY _ntTKmpag   Picture "@E 999,999.99"
				@nLin,071 PSAY "|"
				nLin := nLin + 1
				@nLin,000 PSAY "|"+ Replicate ("=",70)+ "|"
				nLin := nLin + 1
				@nLin,000 PSAY SPACE(2)+ "TOTAL DE VIAGENS "
				@nLin,021 PSAY _nViag
				nLin := nLin + 1
				@nLin,000 PSAY Replicate ("_",72)
				nLin := nLin + 2
				
				// Zerando as variaveis
				_nTotPeso   := 0
				_ntTKmpag   := 0
				_nTotEntr   := 0
				_nEntr      := 0
				_nViag      := 0
				
				// Descontos e Acrescimos
				_nTotAcres := 0
				_nTotDesc  := 0
				_ImpDes    := 'S'

				// Lancamento de desconto e acrescimo
				If nLin > 60
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
					@nLin,000 PSAY CABEC10
					nLin := nLin + 1
					@nLin,000 PSAY CABEC6
					nLin := nLin + 1
					@nLin,000 PSAY CABEC7
					nLin := nLin + 1
					@nLin,000 PSAY CABEC8
					nLin := nLin + 1
				Endif
				dbSelectArea("SZI")
				dbGotop()
				dbSetOrder(4) // PLACA PAGTO + DATA
				dbSeek(xFilial("SZI")+_cVeic + dtos(_dDtEntr),.T.)
				DO While !EOF ().and. ZI_PLACA = _cVeic
					If DTOS(ZI_DATALAN) >= dtos(_dDtEntr) .and. DTOS(ZI_DATALAN) <= dtos(_dDtEntr2)
						If  _ImpDes  = 'S'
							@nLin,000 PSAY CABEC10
							nLin := nLin + 1
							@nLin,000 PSAY CABEC6
							nLin := nLin + 1
							@nLin,000 PSAY CABEC7
							nLin := nLin + 1
							@nLin,000 PSAY CABEC8
							nLin := nLin + 1
							_ImpDes  = 'N'
						Endif
						IF TRIM(SZI->ZI_TIPO) = 'A'
							
							@nLin,000 PSAY "|"
							@nLin,002 PSAY ZI_DATALAN
							@nLin,012 PSAY "|"
							@nLin,015 PSAY ZI_TIPO
							@nLin,019 PSAY "|"
							@nLin,021 PSAY SUBSTR(ZI_DESCRIC,1,15)   Picture "@!"
							@nLin,048 PSAY "|"
							@nLin,050 PSAY ZI_VALOR Picture "@E 9,999,999.99"
							@nLin,064 PSAY "|"
							@nLin,065 PSAY 0 Picture "@E 9,999,999.99"
							@nLin,079 PSAY "|"
							_nTotAcres += ZI_VALOR
							nLin := nLin + 1
						ELSE
							If TRIM(ZI_TIPO) = 'D'
								
								@nLin,000 PSAY "|"
								@nLin,002 PSAY ZI_DATALAN
								@nLin,012 PSAY "|"
								@nLin,015 PSAY ZI_TIPO
								@nLin,019 PSAY "|"
								@nLin,021 PSAY SUBSTR(ZI_DESCRIC,1,25)   Picture "@!"
								@nLin,048 PSAY "|"
								@nLin,050 PSAY 0 Picture "@E 9,999,999.99"
								@nLin,064 PSAY "|"
								@nLin,065 PSAY ZI_VALOR Picture "@E 9,999,999.99"
								@nLin,079 PSAY "|"
								_nTotDesc += ZI_VALOR
								nLin := nLin + 1
							ENDIF
							//  Verifica salto de pagina um pouco antes
							If nLin > 60
								Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
								nLin := 9
								@nLin,000 PSAY CABEC10
								nLin := nLin + 1
								@nLin,000 PSAY CABEC6
								nLin := nLin + 1
								@nLin,000 PSAY CABEC7
								nLin := nLin + 1
								@nLin,000 PSAY CABEC8
								nLin := nLin + 1
							Endif
							
						ENDIF
					ENDIF
					Dbskip()
				Enddo
				If nLin > 55
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
					@nLin,000 PSAY CABEC10
					nLin := nLin + 1
					@nLin,000 PSAY CABEC6
					nLin := nLin + 1
					@nLin,000 PSAY CABEC7
					nLin := nLin + 1
					@nLin,000 PSAY CABEC8
					nLin := nLin + 1
				Endif
				If  ( _nTotAcres +  _nTotDesc ) <> 0
					
					@nLin,000 PSAY "|"+ Replicate ("=",78)+ "|"
					nLin := nLin + 1
					@nLin,000 PSAY "|"
					@nLin,002 PSAY "TOTAL"
					@nLin,012 PSAY "|"
					@nLin,019 PSAY "|"
					@nLin,048 PSAY "|"
					@nLin,050 PSAY _nTotAcres   Picture "@E 9,999,999.99"
					@nLin,064 PSAY "|"
					@nLin,065 PSAY _nTotDesc    Picture "@E 9,999,999.99"
					@nLin,079 PSAY "|"
					nLin := nLin + 1
					@nLin,000 PSAY "|"+ Replicate ("=",78)+ "|"
					nLin := nLin + 1
					@nLin,000 PSAY SPACE(2)+ "TOTAL A PAGAR "
					@nLin,021 PSAY _nTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99"
					nLin := nLin + 1
					@nLin,000 PSAY Replicate ("_",79)
					
					// Zerando as variaveis
					_nTotAcres := 0
					_nTotDesc  := 0
					_nTotFret  := 0
					
					If nLin > 60
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
						@nLin,000 PSAY CABEC3
						nLin := nLin + 1
						@nLin,000 PSAY CABEC4
						nLin := nLin + 1
						@nLin,000 PSAY CABEC5
						nLin := nLin + 1
					Endif
				Endif
			Endif
		ENDIF
		dbSelectArea("ZV4")
		Dbskip()
	Enddo

	dbCloseArea("SZI")
	dbCloseArea("SZK")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SET DEVICE TO SCREEN

	//==============================================================
	// Exporta p/ Excel , conf. parametro
	// HC CONSYS - 08/04/2009
	//==============================================================
	if mv_par06 == 1
		bBloco:={|| expExcel()}
		MsAguarde(bBloco,"Aguarde...","Exportando dados para Microsoft Excel...",.F.)
		dbSelectArea("TR2")
		dbCloseArea()
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

//===================================================================================
//
// Funcao para exportar e abrir arquivo no MS-Excel
//
// HC CONSYS - 08/04/2009
//
//===================================================================================
Static Function expExcel()

    // Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 26/06/2020
	Local nLinha    := 0
    Local nExcel    := 1

    Private aLinhas   := {}

	dbSelectArea("TR2")

	cDirDocs := MsDocPath()
	cPath    := AllTrim(GetTempPath())

	//cArq:="\AD0052"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".DBF"
	cArq:="\AD0052"+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)+".XLS"
	_cCamin:=cDirDocs+cArq

	// Cabecalho Excel
    oExcel:AddworkSheet(cArq)
	oExcel:AddTable (cArq,cTitulo)
    oExcel:AddColumn(cArq,cTitulo,"COD_TRANSP"  ,1,1) // 01 A
	oExcel:AddColumn(cArq,cTitulo,"NOM_TRANSP"  ,1,1) // 02 B
	oExcel:AddColumn(cArq,cTitulo,"VEICULO"     ,1,1) // 03 C
	oExcel:AddColumn(cArq,cTitulo,"DATA_"       ,1,1) // 04 D
	oExcel:AddColumn(cArq,cTitulo,"TOT_FRETE"   ,1,1) // 05 E
	oExcel:AddColumn(cArq,cTitulo,"PESO"        ,1,1) // 06 F
	oExcel:AddColumn(cArq,cTitulo,"ENTR"        ,1,1) // 07 G
	oExcel:AddColumn(cArq,cTitulo,"KM"          ,1,1) // 08 H

    // Gera Excel
    TR2->( dbGoTop() )
    Do While TR2->( !EOF() )

    	nLinha++

	   	aAdd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "" ; // 08 H   
	   	                   })

		aLinhas[nLinha][01] := TR2->COD_TRANSP //A
		aLinhas[nLinha][02] := TR2->NOM_TRANSP //B
		aLinhas[nLinha][03] := TR2->VEICULO    //C
		aLinhas[nLinha][04] := TR2->DATA_      //D
		aLinhas[nLinha][05] := TR2->TOT_FRETE  //E
		aLinhas[nLinha][06] := TR2->PESO       //F
		aLinhas[nLinha][07] := TR2->ENTR       //G
		aLinhas[nLinha][08] := TR2->KM         //J

        TR2->( dbSkip() )

    EndDo

	// IMPRIME LINHA NO EXCEL
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArq,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel 

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArq)
	
	/*
	COPY TO &_cCamin VIA "DBFCDXADS"
	CpyS2T(_cCamin, cPath, .T. )
	*/

	//------------------------------
	// Abre MS-EXCEL
	//------------------------------
	If ! ApOleClient( 'MsExcel' )
		MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo não está instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
		Return
	EndIf
	oExcel:= MsExcel():New()  //Objeto para abrir Excel.
	oExcel:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
	oExcel:SetVisible(.T.)

Return

/**********************************************************************/
//
//
/* Função para criar arquivo temporario para a exportacao no Excel
//
//
//**********************************************************************/
Static Function ArqTemp2()

	mat1 := {}
	aadd( mat1 , { "COD_TRANSP" ,  "C" , 10, 0 } )
	aadd( mat1 , { "NOM_TRANSP" ,  "C" , 50, 0 } )
	aadd( mat1 , { "VEICULO"    ,  "C" , 10, 0 } )
	aadd( mat1 , { "DATA_"       ,  "D" , 08, 0 } )
	aadd( mat1 , { "TOT_FRETE"  ,  "N" , 12, 2 } )
	aadd( mat1 , { "PESO"       ,  "N" , 12, 2 } )
	aadd( mat1 , { "ENTR"       ,  "N" , 06, 0 } )
	aadd( mat1 , { "KM"         ,  "N" , 12, 2 } )
	cArqTra1 := criaTrab(mat1,.t.)
	use &cArqTra1 alias TR2 new

Return