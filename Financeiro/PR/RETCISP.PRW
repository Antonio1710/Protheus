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

#Define CRLF  Chr( 13 ) + Chr( 10 )

Static cTitulo := "Retorno CISP"

/*/{Protheus.doc} User Function nomeFunction
	Retorno CISP
	@type  Function
	@author Celso Costa
	@since 29/10/2007
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history chamado 050729 - FWNM - 24/06/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE
/*/
User Function RetCISP()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aFontes		:= {}
	Local _aCposBrw	:= {}
	Local _nCtCpos		:= 00 
	Local cSave := ''      

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Retorno - CISP')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Private                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cArqXLS   := "CISP.XLS"

	Private _aLayOut	:= {}
	//Private _cPerg		:= "RTCISP"
	Private _cPerg		:= PADR("RTCISP",10," ")
	Private _cArqTrb	:= ""
	Private cCadastro	:= OemToAnsi( "Consulta da carga inicial e alteracoes diarias do SINTEGRA, RECEITA, FEDERAL e SUFRAMA" )
	Private aRotina	:=	{	{ OemToAnsi( "Visualizar" ), "U_VisCISP()", 00, 01 },;
									{ OemToAnsi( "Pesquisar"  ), "U_PsqCISP()", 00, 02 } }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fontes dos registros de retorno                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( _aFontes, { "PARAM"	, "Dados comum a todos associados, fornecidos pela CISP"	} )
	Aadd( _aFontes, { "SIN"		, "Dados fornecidos pelo SINTEGRA"								} )
	Aadd( _aFontes, { "REC"		, "Dados fornecidos pela RECEITA FEDERAL"						} )
	Aadd( _aFontes, { "SUF"		, "Dados fornecidos pelo SUFRAMA"								} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LayOut do arquivo de retorno CISP                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ LayOut CISP    Sq ,  Campo		, Tp , Tam, Pini, Pfim, Formato					, Descricao											, Fonte             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( _aLayout, { "01", "SRF_IDE"	, "N", 001, 0001, 0001, "9"						, "Identif. consulta (1-Sin/2-Rec/3-Suf)"	, "PARAM."			} )
	Aadd( _aLayout, { "02", "SRF_ASC"	, "N", 003, 0002, 0004, "999"						, "Numero do Associado Junto a CISP"		, "PARAM."			} )
	Aadd( _aLayout, { "03", "SRF_CLI"	, "C", 014, 0005, 0018, "99999999999999"		, "Cliente (CNPJ)"								, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "04", "SRF_INS"	, "C", 020, 0019, 0038, "FIXOS"					, "Inscricao Estadual"							, "SIN/SUF"			} )
	Aadd( _aLayout, { "05", "SRF_RZS"	, "C", 150, 0039, 0188, "FIXOS"					, "Razao Social"									, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "06", "SRF_LGD"	, "C", 100, 0189, 0288, "FIXOS"					, "Logradouro"										, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "07", "SRF_NMR"	, "C", 010, 0289, 0298, "FIXOS"					, "Numero"											, "REC/SIN"			} )
	Aadd( _aLayout, { "08", "SRF_CPT"	, "C", 070, 0299, 0368, "FIXOS"					, "Complemento de Endereco"					, "REC/SIN"			} )
	Aadd( _aLayout, { "09", "SRF_BRR"	, "C", 050, 0369, 0418, "FIXOS"					, "Bairro"											, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "10", "SRF_MNC"	, "C", 080, 0419, 0498, "FIXOS"					, "Municipio"										, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "11", "SRF_UF"	, "C", 002, 0499, 0500, "FIXOS"					, "Unidade Federativa.(Estado)"				, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "12", "SRF_CEP"	, "N", 008, 0501, 0508, "99999999"				, "CEP"												, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "13", "SRF_DDD"	, "C", 006, 0509, 0514, "FIXOS"					, "DDD"												, "RESERVA"			} )
	Aadd( _aLayout, { "14", "SRF_TEL"	, "C", 040, 0515, 0554, "FIXOS"					, "Telefone"										, "SIN/SUF"			} )
	Aadd( _aLayout, { "15", "SRF_EML"	, "C", 050, 0555, 0604, "FIXOS"					, "E-mail"											, "SIN/SUF"			} )
	Aadd( _aLayout, { "16", "SRF_ATV"	, "C", 010, 0605, 0614, "FIXOS"					, "Codigo de Atividade Economica"			, "REC/SIN"			} )
	Aadd( _aLayout, { "17", "SRF_ARG"	, "C", 100, 0615, 0714, "FIXOS"					, "Regime de Apuracao"							, "SIN"				} )
	Aadd( _aLayout, { "18", "SRF_SCL"	, "C", 050, 0715, 0764, "FIXOS"					, "Situacao Cadastral"							, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "19", "SRF_GER"	, "D", 008, 0765, 0772, "99999999(AAAAMMDD)"	, "Data de Geracao da Infor. na CISP"		, "PARAM."			} )
	Aadd( _aLayout, { "20", "SRF_DTS"	, "D", 008, 0773, 0780, "99999999(AAAAMMDD)"	, "Data da Situacao"								, "REC/SIN"			} )
	Aadd( _aLayout, { "21", "SRF_DTC"	, "D", 008, 0781, 0788, "99999999(AAAAMMDD)"	, "Data da Consulta"								, "REC/SIN/SUF"	} )
	Aadd( _aLayout, { "22", "SRF_NCT"	, "N", 010, 0789, 0798, "9999999999"			, "Numero da Consulta"							, "SIN"				} )
	Aadd( _aLayout, { "23", "SRF_NMF"	, "C", 070, 0799, 0868, "FIXOS"					, "Nome Fantasia"									, "REC"				} )
	Aadd( _aLayout, { "24", "SRF_CNJ"	, "C", 006, 0869, 0874, "FIXOS"					, "Codigo Natureza Juridica"					, "REC"				} )
	Aadd( _aLayout, { "25", "SRF_DNJ"	, "C", 070, 0875, 0944, "FIXOS"					, "Descricao Natureza Juridica"				, "REC"				} )
	Aadd( _aLayout, { "26", "SRF_SSP"	, "C", 050, 0945, 0994, "FIXOS"					, "Situacao Especial"							, "REC"				} )
	Aadd( _aLayout, { "27", "SRF_DTP"	, "D", 008, 0995, 1002, "99999999(AAAAMMDD)"	, "Data Situacao Especial"						, "REC"				} )
	Aadd( _aLayout, { "28", "SRF_DTA"	, "D", 008, 1003, 1010, "99999999(AAAAMMDD)"	, "Data da Abertura"								, "REC"				} )
	Aadd( _aLayout, { "29", "SRF_IRE"	, "D", 008, 1011, 1018, "99999999(AAAAMMDD)"	, "Data Insc. na Rec.Estadual/Suframa"		, "SIN/SUF"			} )
	Aadd( _aLayout, { "30", "SRF_MI"	, "C", 050, 1019, 1068, "FIXOS"					, "Motivo da Inscricao"							, "SIN"				} )
	Aadd( _aLayout, { "31", "SRF_BRE"	, "D", 008, 1069, 1076, "99999999(AAAAMMDD)"	, "Data da Baixa na Receita Estadual"		, "SIN"				} )
	Aadd( _aLayout, { "32", "SRF_MB"	, "C", 050, 1077, 1126, "FIXOS"					, "Motivo da Baixa"								, "SIN"				} )
	Aadd( _aLayout, { "33", "SRF_PE"	, "C", 040, 1127, 1166, "FIXOS"					, "Porte da Empresa"								, "SIN"				} )
	Aadd( _aLayout, { "34", "SRF_OBS"	, "C", 250, 1167, 1416, "FIXOS"					, "Observacoes"									, "SIN"				} )
	Aadd( _aLayout, { "35", "SRF_ICMS"	, "C", 005, 1417, 1421, "FIXOS"					, "Credenciamento Antecipado (ICMS)"		, "SIN"				} )
	Aadd( _aLayout, { "36", "SRF_FAX"	, "C", 040, 1422, 1461, "FIXOS"					, "Numero do FAX"									, "SIN"				} )
	Aadd( _aLayout, { "37", "SRF_ISF"	, "N", 010, 1462, 1471, "9999999999"			, "Inscricao da SUFRAMA"						, "SUF"				} )
	Aadd( _aLayout, { "38", "SRF_DTV"	, "D", 008, 1472, 1479, "99999999(AAAAMMDD)"	, "Data Validade  Insc. SUFRAMA"				, "SUF"				} )
	Aadd( _aLayout, { "39", "SRF_TI"	, "C", 020, 1480, 1499, "FIXOS"					, "Tipo de Incentivo EX.: (ICMS, IPI)"		, "SUF"				} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Private                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ValidPerg()

	If !Pergunte( "RTCISP", .T. )
		Return ( Nil )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo temporario para consulta                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CriaTemp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostra consulta                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("CISP")


	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 26/06/2020
	//cArqXLS := __RELDIR+"_CISP"
	
	cPath := cGetFile("Arquivo XLS.", "Selecione o diretório para salvar o XLS",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

    fErase( cPath+cArqXLS )

	//COPY TO &(cArqXLS) VIA "DBFCDXADS"    

	bBloco := { || GeraXLS() }
	MsAguarde(bBloco,"Aguarde...","Gerando arquivo " + cPath + cArqXLS,.F.)
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos campos exibidos no Browse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*_aCposBrw	:=	{	{ "Cliente (CNPJ)"								, {|| CISP->SRF_CLI	}, PesqPict( "SA1", "A1_CGC" )	},;
							{ "Inscricao Estadual"							, {|| CISP->SRF_INS	}, PesqPict( "SA1", "A1_INSCR" )	},;
							{ "Razao Social"									, {|| CISP->SRF_RZS	} },;
							{ "Logradouro"										, {|| CISP->SRF_LGD	} },;
							{ "Numero"											, {|| CISP->SRF_NMR	} },;
							{ "Complemento de Endereco"					, {|| CISP->SRF_CPT	} },;
							{ "Bairro"											, {|| CISP->SRF_BRR	} },;
							{ "Municipio"										, {|| CISP->SRF_MNC	} },;
							{ "Unidade Federativa.(Estado)"				, {|| CISP->SRF_UF	} },;
							{ "CEP"												, {|| CISP->SRF_CEP	}, PesqPict( "SA1", "A1_CEP" )	},;
							{ "DDD"												, {|| CISP->SRF_DDD	} },;
							{ "Telefone"										, {|| CISP->SRF_TEL	} },;
							{ "E-mail"											, {|| CISP->SRF_EML	} },;
							{ "Codigo de Atividade Economica"			, {|| CISP->SRF_ATV	} },;
							{ "Regime de Apuracao"					 		, {|| CISP->SRF_ARG	} },;
							{ "Situacao Cadastral"							, {|| CISP->SRF_SCL	} },;
							{ "Data de Geracao da Infor. na CISP"		, {|| CISP->SRF_GER	} },;
							{ "Data da Situacao"								, {|| CISP->SRF_DTS	} },;
							{ "Data da Consulta"								, {|| CISP->SRF_DTC	} },;
							{ "Numero da Consulta"							, {|| CISP->SRF_NCT	} },;
							{ "Nome Fantasia"									, {|| CISP->SRF_NMF	} },;
							{ "Codigo Natureza Juridica"					, {|| CISP->SRF_CNJ	} },;
							{ "Descricao Natureza Juridica"				, {|| CISP->SRF_DNJ	} },;
							{ "Situacao Especial"							, {|| CISP->SRF_SSP	} },;
							{ "Data Situacao Especial"						, {|| CISP->SRF_DTP	} },;
							{ "Data da Abertura"								, {|| CISP->SRF_DTA	} },;
							{ "Data Insc. na Rec.Estadual/Suframa"		, {|| CISP->SRF_IRE	} },;
							{ "Motivo da Inscricao"							, {|| CISP->SRF_MI	} },;
							{ "Data da Baixa na Receita Estadual"		, {|| CISP->SRF_BRE	} },;
							{ "Motivo da Baixa"								, {|| CISP->SRF_MB	} },;
							{ "Porte da Empresa"								, {|| CISP->SRF_PE	} },;
							{ "Observacoes"									, {|| CISP->SRF_OBS	} },;
							{ "Credenciamento Antecipado (ICMS)"		, {|| CISP->SRF_ICMS	} },;
							{ "Numero do FAX"									, {|| CISP->SRF_FAX	} },;
							{ "Inscricao da SUFRAMA"						, {|| CISP->SRF_ISF	} },;
							{ "Data Validade  Insc. SUFRAMA"				, {|| CISP->SRF_DTV	} },;
							{ "Tipo de Incentivo EX.: (ICMS, IPI)"		, {|| CISP->SRF_TI	} } } */

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca mBrowse                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*mBrowse( 06, 01, 22, 75, "CISP", _aCposBrw,,,,, )*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta arquivos temporarios                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CISP->( dbCloseArea() )

	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 26/06/2020
	If File( _cArqTrb + GETDBEXTENSION() )
		FErase( _cArqTrb + GETDBEXTENSION() )
	EndIf

	If File( _cArqTrb + OrdBagExt() )
		FErase( _cArqTrb + OrdBagExt() )
	EndIf
	//

	// *** INICIO CHAMADO 040506 WILLIAM COSTA *** //

	//_cSave := cGetFile("Arquivo XLS.", "Selecione o diretório para salvar o XLS",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	/*
	//IF FILE(cArqXLS + ".dbf")
	IF FILE(cArqXLS + GETDBEXTENSION()) 
		Copy File (cArqXLS + GETDBEXTENSION()) To  (_cSave + "cisp" + GETDBEXTENSION())
		//Copy File (cArqXLS + ".dbf") To  (_cSave + "cisp.dbf")
	ENDIF

	//IF FILE(cArqXLS + ".dbf")
	IF FILE(cArqXLS + GETDBEXTENSION())
		FErase(cArqXLS + GETDBEXTENSION())
		//FErase(cArqXLS + ".dbf")
	ENDIF
	*/

Return ( Nil )

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
Static Function CriaTemp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aStruct		:= {}
	Local _nCtLayOut	:= 00

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta estrutura do arquivo temporario                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For _nCtLayOut := 01 To Len( _aLayOut )
		Aadd( _aStruct, { _aLayOut[ _nCtLayOut, 02 ], _aLayOut[ _nCtLayOut, 03 ], _aLayOut[ _nCtLayOut, 04 ], 00 } )
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo temporario                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cArqTrb := CriaTrab( _aStruct, .T. )

	dbUseArea( .T. ,, _cArqTrb, "CISP", .T., .F. )
	IndRegua( "CISP", _cArqTrb, "SRF_CLI",,, )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa arquivo retorno                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLocal( AllTrim( Upper( mv_par01 ) ) )

Return ( Nil )

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
Static Function ProcLocal( _pLocFile )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aFiles		:= {}
	Local _cExtFile	:= "TXT"
	Local _cNewArq		:= ""
	Local _nRegs		:= 00

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( _pLocFile )
		MsgStop( "O arquivo informado no parametro nao existe!", "Atencao" )
		Return ( Nil )
	EndIf

	Processa( { ||ProcTexto( _pLocFile ) } )

Return ( Nil )

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
Static Function ProcTexto( _pArquivo )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _nRegs		:= 01
	Local _nHdlTxt		:= ""
	Local _cLinTxt		:= ""
	Local _xStr	 		:= ""
	Local _nCtLayOut	:= 00
	Local _aLeitura	:= {}
	Local _nCtLeitura	:= 00
	Local _cStrLido	:= ""
	Local _nAscan		:= 00

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Forma LayOut de leitura do arquivo                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For _nCtLayOut := 01 To Len( _aLayOut )
		Aadd( _aLeitura, { _aLayOut[ _nCtLayOut, 05 ], _aLayOut[ _nCtLayOut, 04 ], _aLayOut[ _nCtLayOut, 03 ], _aLayOut[ _nCtLayOut, 02 ] } )
	Next

	_nHdlTxt	:= FT_FUse( _pArquivo )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcRegua( FT_FLastRec() )

	FT_FGoTop()

	While !FT_FEof()

		IncProc( "Processando registro(s) : " + AllTrim( Str( _nRegs, 10 ) ) + " ..." )

		_cLinTxt	:= FT_FReadLn()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se a linha do arquivo esta em branco                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty( _cLinTxt ) .Or. EmpTy( SubStr( _cLinTxt, 02, 03 ) )
			FT_FSkip()
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua filtro de registros ATIVOS                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nAscan := aScan( _aLeitura, { |x| AllTrim( Upper( x[ 04 ] ) ) == "SRF_SCL" } )

		If _nAscan > 00
		
			If mv_par02 == 01 .And. Upper( AllTrim( SubStr( _cLinTxt, _aLeitura[ _nAscan, 01 ], ( _aLeitura[ _nAscan, 02 ] - 01 ) ) ) ) != "ATIVA"
				FT_FSkip()
				Loop
			ElseIf mv_par02 == 02 .And.  Upper( AllTrim( SubStr( _cLinTxt, _aLeitura[ _nAscan, 01 ], ( _aLeitura[ _nAscan, 02 ] - 01 ) ) ) ) == "ATIVA"
				FT_FSkip()
				Loop
			EndIf
		
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria registro no arquivo leitura                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nRegs++
	
		_xStr := ""

		RecLock( "CISP", .T. )

		aEval( _aLeitura, {|x|	_xStr	:= SubStr( _cLinTxt, x[ 01 ], x[ 02 ] ),;
										_xStr	:= Iif( x[ 03 ] == "N", Val( _xStr ), Iif( x[ 03 ] == "D", StoD( _xStr ), _xStr ) ),;
										CISP->( FieldPut( CISP->( FieldPos( x[ 04 ] ) ), _xStr ) ) } )

		CISP->( MsUnLock() )

		FT_FSkip()

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza leitura                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FUse()

Return ( Nil )

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
User Function VisCISP()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _nCtCpo		:= 00
	Local _cAssunto	:= ""
	Local _cCampo		:= ""
	Local oDlg

	U_ADINF009P('RETCISP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Retorno - CISP')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta array com campos para visualizacao                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For _nCtCpo := 01 To Len( _aLayOut )
		_cCampo		:= Iif( _aLayOut[ _nCtCpo, 03 ] == "N", AllTrim( Str( CISP->&( _aLayOut[ _nCtCpo, 02 ] ) ) ), Iif( _aLayOut[ _nCtCpo, 03 ] == "D", DtoC( CISP->&( _aLayOut[ _nCtCpo, 02 ] ) ), CISP->&( _aLayOut[ _nCtCpo, 02 ] ) ) )
		_cAssunto	+= _aLayOut[ _nCtCpo, 08 ] + ": " + _cCampo + CRLF
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Visualizacao                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	__cFileLog := MemoWrite( Criatrab( ,.F. ) + ".LOG", _cAssunto )

	Define MsDialog oDlg Title OemToAnsi( "CISP - Visualizacao" ) From 03, 00 To 440, 417 Pixel

	@ 05, 05 Get oMemo Var _cAssunto MEMO HScroll ReadOnly Size 200, 190 Of oDlg Pixel

	oMemo:bRClicked := {||AllwaysTrue()}

	Define SButton From 200, 175 Type 01 Action oDlg:End() Enable Of oDlg Pixel

	Activate MsDialog oDlg Centered

Return ( Nil )

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
Static Function ValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea	:= GetArea()
	Local _aRegs	:= {}
	Local i,j

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria registros de pergunta                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( _aRegs, {_cPerg,"01","Nome do arquivo"		,"","","mv_ch1","C",60,00,00,"G","","","","","","","","","","","","","","","","","","","","","","","","","","","","S","","",""} )
	Aadd( _aRegs, {_cPerg,"02","Situacao Cadastral"	,"","","mv_ch2","N",01,00,00,"C","","","Ativo","","","","","Nao ativo","","","","","Ambos","","","","","","","","","","","","","","","S","","",""} )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida/Cria Pergunte                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SX1" )
	dbSetOrder( 01 )

	For i := 01 To Len( _aRegs )

		If !dbSeek( _cPerg + _aRegs[ i, 02 ] )

			RecLock( "SX1", .T. )

			For j := 01 To FCount()
			
				If j <= Len( _aRegs[ i ] )
					FieldPut( j, _aRegs[ i, j ] )
				EndIf

			Next

			SX1->( MsUnlock() )

		EndIf

	Next

	RestArea( _aArea )

Return ( Nil )

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
User Function PsqCISP()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis Locais                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local _aArea		:= GetArea()
	Local _cPesqCGC	:= Space( 14 )
	Local _nOpca		:= 00
	Local oDlg1

	U_ADINF009P('RETCISP' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Retorno - CISP')

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Tela                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Define MsDialog oDlg1 Title OemToAnsi( "Pesquisa" ) From 05, 00 To 10, 45

	@ 020.0, 005 Say OemToAnsi( "CGC"	) Size 080, 10 Pixel Of oDlg1

	@ 019.2, 025 MsGet _cPesqCGC	Size 055, 10 Pixel Of oDlg1 Picture PesqPict( "SA1", "A1_CGC" )

	Activate MsDialog oDlg1 On Init EnchoiceBar( oDlg1, {||_nOpca := 01, oDlg1:End() }, {||_nOpca := 00, oDlg1:End()} ) Centered

	If CISP->( !dbSeek( _cPesqCGC ) ) .Or. _nOpca != 01
		RestArea( _aArea )
	EndIf

Return ( Nil )

/*/{Protheus.doc} Static Function GeraXLS
	(long_description)
	@type  Static Function
	@author FWNM
	@since 26/06/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 26/06/2020
/*/
Static Function GeraXLS()
	
	Local oExcel    := FWMsExcelEx():New()
    Local nLinha    := 0
    Local nExcel    := 1

    Private aLinhas   := {}
	Private cArqXLS   := "CISP.XLS"

	CISP->( dbGoTop() )

	// Cabecalho Excel
    oExcel:AddworkSheet(cArqXLS)
	oExcel:AddTable (cArqXLS,cTitulo)
    oExcel:AddColumn(cArqXLS,cTitulo,"SRF_IDE"      ,1,1) // 01 A
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_ASC"      ,1,1) // 02 B
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_CLI"      ,1,1) // 03 C
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_INS"      ,1,1) // 04 D
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_RZS"      ,1,1) // 05 E
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_LGD"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_NMR"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_CPT"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_BRR"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_MNC"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_UF"       ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_CEP"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DDD"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_TEL"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_EML"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_ATV"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_ARG"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_SCL"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_GER"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DTS"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DTC"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_NCT"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_NMF"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_CNJ"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DNJ"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_SSP"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DTP"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DTA"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_IRE"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_MI"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_BRE"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_MB"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_PE"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_OBS"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_ICMS"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_FAX"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_ISF"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_DTV"      ,1,1) // 06 F
	oExcel:AddColumn(cArqXLS,cTitulo,"SRF_TI"      ,1,1) // 06 F

    // Gera Excel
    CISP->( dbGoTop() )
    Do While CISP->( !EOF() )

    	nLinha++

	   	aAdd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               ""  ; // 09 I  
	   	                   })

		aLinhas[nLinha][01] := CISP->SRF_IDE     //A
		aLinhas[nLinha][02] := CISP->SRF_ASC     //A
		aLinhas[nLinha][03] := CISP->SRF_CLI     //A
		aLinhas[nLinha][04] := CISP->SRF_INS     //A
		aLinhas[nLinha][05] := CISP->SRF_RZS     //A
		aLinhas[nLinha][06] := CISP->SRF_LGD     //A
		aLinhas[nLinha][07] := CISP->SRF_NMR     //A
		aLinhas[nLinha][08] := CISP->SRF_CPT     //A
		aLinhas[nLinha][09] := CISP->SRF_BRR     //A
		aLinhas[nLinha][10] := CISP->SRF_MNC     //A
		aLinhas[nLinha][11] := CISP->SRF_UF     //A
		aLinhas[nLinha][12] := CISP->SRF_CEP     //A
		aLinhas[nLinha][13] := CISP->SRF_DDD     //A
		aLinhas[nLinha][14] := CISP->SRF_TEL     //A
		aLinhas[nLinha][15] := CISP->SRF_EML     //A
		aLinhas[nLinha][16] := CISP->SRF_ATV     //A
		aLinhas[nLinha][17] := CISP->SRF_ARG     //A
		aLinhas[nLinha][18] := CISP->SRF_SCL     //A
		aLinhas[nLinha][19] := CISP->SRF_GER     //A
		aLinhas[nLinha][20] := CISP->SRF_DTS     //A
		aLinhas[nLinha][21] := CISP->SRF_DTC     //A
		aLinhas[nLinha][22] := CISP->SRF_NCT     //A
		aLinhas[nLinha][23] := CISP->SRF_NMF     //A
		aLinhas[nLinha][24] := CISP->SRF_CNJ     //A
		aLinhas[nLinha][25] := CISP->SRF_DNJ     //A
		aLinhas[nLinha][26] := CISP->SRF_SSP     //A
		aLinhas[nLinha][27] := CISP->SRF_DTP     //A
		aLinhas[nLinha][28] := CISP->SRF_DTA     //A
		aLinhas[nLinha][29] := CISP->SRF_IRE     //A
		aLinhas[nLinha][30] := CISP->SRF_MI     //A
		aLinhas[nLinha][31] := CISP->SRF_BRE     //A
		aLinhas[nLinha][32] := CISP->SRF_MB     //A
		aLinhas[nLinha][33] := CISP->SRF_PE     //A
		aLinhas[nLinha][34] := CISP->SRF_OBS     //A
		aLinhas[nLinha][35] := CISP->SRF_ICMS     //A
		aLinhas[nLinha][36] := CISP->SRF_FAX     //A
		aLinhas[nLinha][37] := CISP->SRF_ISF     //A
		aLinhas[nLinha][38] := CISP->SRF_DTV     //A
		aLinhas[nLinha][39] := CISP->SRF_TI     //A

        CISP->( dbSkip() )

    EndDo

	// IMPRIME LINHA NO EXCEL
	For nExcel := 1 to nLinha
       	oExcel:AddRow(cArqXLS,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                     aLinhas[nExcel][02],; // 02 B  
	                                     aLinhas[nExcel][03],; // 03 C  
	                                     aLinhas[nExcel][04],; // 04 D  
	                                     aLinhas[nExcel][05],; // 05 E  
	                                     aLinhas[nExcel][06],; // 06 F  
	                                     aLinhas[nExcel][07],; // 07 G 
	                                     aLinhas[nExcel][08],; // 08 H  
	                                     aLinhas[nExcel][09],; // 08 H  
	                                     aLinhas[nExcel][10],; // 08 H  
	                                     aLinhas[nExcel][11],; // 08 H  
	                                     aLinhas[nExcel][12],; // 08 H  
	                                     aLinhas[nExcel][13],; // 08 H  
	                                     aLinhas[nExcel][14],; // 08 H  
	                                     aLinhas[nExcel][15],; // 08 H  
	                                     aLinhas[nExcel][16],; // 08 H  
	                                     aLinhas[nExcel][17],; // 08 H  
	                                     aLinhas[nExcel][18],; // 08 H  
	                                     aLinhas[nExcel][19],; // 08 H  
	                                     aLinhas[nExcel][20],; // 08 H  
	                                     aLinhas[nExcel][21],; // 08 H  
	                                     aLinhas[nExcel][22],; // 08 H  
	                                     aLinhas[nExcel][23],; // 08 H  
	                                     aLinhas[nExcel][24],; // 08 H  
	                                     aLinhas[nExcel][25],; // 08 H  
	                                     aLinhas[nExcel][26],; // 08 H  
	                                     aLinhas[nExcel][27],; // 08 H  
	                                     aLinhas[nExcel][28],; // 08 H  
	                                     aLinhas[nExcel][29],; // 08 H  
	                                     aLinhas[nExcel][30],; // 08 H  
	                                     aLinhas[nExcel][31],; // 08 H  
	                                     aLinhas[nExcel][32],; // 08 H  
	                                     aLinhas[nExcel][33],; // 08 H  
	                                     aLinhas[nExcel][34],; // 08 H  
	                                     aLinhas[nExcel][35],; // 08 H  
	                                     aLinhas[nExcel][36],; // 08 H  
	                                     aLinhas[nExcel][37],; // 08 H  
	                                     aLinhas[nExcel][38],; // 08 H  
	                                     aLinhas[nExcel][39] ; // 09 I  
	                                                        }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    Next nExcel

    oExcel:Activate()
	oExcel:GetXMLFile(cPath + cArqXLS)

	MSGINFO("Arquivo " + cPath + cArqXLS + " criado com sucesso! Arquivo será aberto automaticamente em seguida...", "Arquivo CISP Gerado")

	// Abre Excel
	If ! ApOleClient( 'MsExcel' )
		MsgStop( 'Excel não instalado! Abra o arquivo manualmente no diretório:' + cPath + cArqXLS )
		Return
	EndIf
	
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( cPath + cArqXLS ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

Return