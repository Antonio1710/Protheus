#INCLUDE 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE 'Parmtype.ch'
#INCLUDE "Topconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "MSMGADD.CH"  
#INCLUDE "FWBROWSE.CH"   
#INCLUDE "DBINFO.CH"
#INCLUDE 'FILEIO.CH'
  
Static cTitulo      := "Conciliação PB3 X SA1"

/*/{Protheus.doc} User Function ADFIN070P
	Conciliação PB3 X SA1
	@type  Function
	@author WILLIAM COSTA
	@since 08/11/2018
	@version 01
	@history Ticket 8190 	  - Abel Babini      - 19/01/2021 - Ajuste campo A1_SIMPLES para A1_SIMPNAC 
	@history Ticket 69520 - Leonardo P. Monteiro   - 17/03/2022 - Preparação da rotina para integrações de diferentes Empresas/Filiais com a entrada da nova filial de Itupeva.
/*/

User Function ADFIN070P()

	Local   aArea      := GetArea()
	Local   oMark      := NIL
	Local   cFunNamBkp := FunName()
	Local   aSeek      := {}
    Local   aIndex     := {}
    Local   lMarcar    := .F.
    Private aMark      := {}
    Private cAliasTmp  := "TRC"
    Private cInd1      := ""
	Private cInd2      := ""
	Private cInd3      := ""
	Private cInd4      := ""
	Private cInd5      := ""
	Private aTrab      := NIL
	Private cArqs      := ""
	Private aCampos    := {}
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SA1')
	
	If Select("TRC") > 0
		TRC->(DbCloseArea())
	EndIf
	
	MsgRun("Criando estrutura e carregando dados no arquivo temporário...",,{|| aTRC := FileTRC() } )
		
	//Definindo as colunas que serão usadas no browse
	
	aAdd(aMark, {"Campo SA1"     , "TMP_CPSA1" , "C", 10, 0, "@!"                  })
    aAdd(aMark, {"Descricao SA1" , "TMP_DESSA1", "C", 14, 0, "@!"                  })
    aAdd(aMark, {"Campo PB3"     , "TMP_CPPB3" , "C", 10, 0, "@!"                  })
    aAdd(aMark, {"Descricao PB3" , "TMP_DESPB3", "C", 14, 0, "@!"                  })
    aAdd(aMark, {"Qtd Inativo"   , "TMP_QTDINA", "N", 17, 0, "@E 9,999,999,999,999"})
    aAdd(aMark, {"Qtd Ativo"     , "TMP_QTDATI", "N", 17, 0, "@E 9,999,999,999,999"})
    aAdd(aMark, {"Qtd Diferenca" , "TMP_QTDDIF", "N", 17, 0, "@E 9,999,999,999,999"})
    
    SetFunName("ADFIN070P")
	
	aAdd(aIndex, "TMP_CPSA1" )
	aAdd(aIndex, "TMP_DESSA1" )
	aAdd(aIndex, "TMP_QTDINA" )
	aAdd(aIndex, "TMP_QTDATI" )
	aAdd(aIndex, "TMP_QTDDIF" ) 
	
	aAdd(aSeek,{"Codigo SA1"    ,{{"","C",010,0,"TMP_CPSA1" ,"@!"                  }} } )
	aAdd(aSeek,{"Descricao SA1" ,{{"","C",014,0,"TMP_DESSA1" ,"@!"                 }} } )
	aAdd(aSeek,{"Qtd Inativo"   ,{{"","N",017,0,"TMP_QTDINA","@E 9,999,999,999,999"}} } )
    aAdd(aSeek,{"Qtd Ativo"     ,{{"","N",017,0,"TMP_QTDATI","@E 9,999,999,999,999"}} } )
	aAdd(aSeek,{"Qtd Diferenca"	,{{"","N",017,0,"TMP_QTDDIF","@E 9,999,999,999,999"}} } )
     
    //Criando o browse da temporária
    oMark := FWMarkBrowse():New()
    oMark:SetAlias(cAliasTmp)
    oMark:oBrowse:SetQueryIndex(aIndex)
    oMark:SetTemporary(.T.)
    oMark:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
    oMark:SetFields(aMark)
    oMark:DisableDetails()
    oMark:SetDescription(cTitulo)
    oMark:SetFieldMark( 'TMP_OK' )
    oMark:oBrowse:Setfocus() //Seta o foco na grade
    
    oMark:Activate()
	
	SetFunName("cFunNamBkp")
	DelTabTemporaria()
	RestArea(aArea)
	
Return Nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 *---------------------------------------------------------------------*/
Static Function MenuDef()

	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Marcar Todos'              ACTION 'u_FIN070Marcar()'    OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Desmarcar Todos'           ACTION 'u_FIN070Desmarcar()' OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Gerar Excel'               ACTION 'u_FIN070EXCEL()'     OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Processar Campos Marcados' ACTION 'u_FIN070Processa()'  OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Total Geral Diferencas'    ACTION 'u_FIN070Total()'     OPERATION 2 ACCESS 0
	
Return(aRot)

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	
	Local oModel    := Nil
	
	//Criando o modelo e os relacionamentos
	oModel := FWLoadModel('zAFIN070') 
	
Return(oModel)

/*---------------------------------------------------------------------*
 | Função:  ViewDef                                                    |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	
	Local oView			:= Nil
	
	//Criando a View
	oView := FWLoadView('zAFIN070')
	
Return(oView)

STATIC FUNCTION DelTabTemporaria()

    DbSelectArea('TRC')
    Dbclosearea('TRC')
    FErase( GetSrvProfString("StartPath", "\undefined") + cArqs + ".DBF" )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd1 + ".IDX" )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd2 + ".IDX" )
    FErase( GetSrvProfString("StartPath", "\undefined") + cInd3 + ".IDX" )
     
Return (NIL)

Static Function FileTRC()

	Local aStrut   := {}
	Local nCont    := 0
	Local lLibBlq  := .F.
	
    //Criando a estrutura que terá na tabela
    aAdd(aStrut, {"TMP_OK"    , "C", 02, 0} )
	aAdd(aStrut, {"TMP_CPSA1" , "C", 10, 0} )
    aAdd(aStrut, {"TMP_DESSA1", "C", 14, 0} )
    aAdd(aStrut, {"TMP_CPPB3" , "C", 10, 0} )
    aAdd(aStrut, {"TMP_DESPB3", "C", 14, 0} )
    aAdd(aStrut, {"TMP_QTDINA", "N", 17, 0} )
    aAdd(aStrut, {"TMP_QTDATI", "N", 17, 0} )
    aAdd(aStrut, {"TMP_QTDDIF", "N", 17, 0} )
     
    // Criar fisicamente o arquivo.
	cArqs := CriaTrab( aStrut, .T. )
	cInd1 := Left( cArqs, 7 ) + "1"
	cInd2 := Left( cArqs, 7 ) + "2"
	cInd3 := Left( cArqs, 7 ) + "3"
	cInd4 := Left( cArqs, 7 ) + "4"
	cInd5 := Left( cArqs, 7 ) + "5"
	
	// Acessar o arquivo e coloca-lo na lista de arquivos abertos.
	dbUseArea( .T., __LocalDriver, cArqs, cAliasTmp, .F., .F. )
	
	// Criar os índices.               
	IndRegua( cAliasTmp, cInd1, "TMP_CPSA1" , , , "Criando índices...")
	IndRegua( cAliasTmp, cInd2, "TMP_DESSA1", , , "Criando índices...")
	IndRegua( cAliasTmp, cInd3, "TMP_QTDINA", , , "Criando índices...")
	IndRegua( cAliasTmp, cInd4, "TMP_QTDATI", , , "Criando índices...")
	IndRegua( cAliasTmp, cInd5, "TMP_QTDDIF", , , "Criando índices...")
	
	// Libera os índices.
	dbClearIndex()
	
	// Agrega a lista dos índices da tabela (arquivo).
	dbSetIndex( cInd1 + OrdBagExt() )  
	dbSetIndex( cInd2 + OrdBagExt() )
	dbSetIndex( cInd3 + OrdBagExt() )
	dbSetIndex( cInd4 + OrdBagExt() )
	dbSetIndex( cInd5 + OrdBagExt() )
	
	// *** INICIO CRIAR LINHAS TABELA TEMPORARIA *** //
	//Ticket 8190 	  - Abel Babini      - 19/01/2021 - Ajuste campo A1_SIMPLES para A1_SIMPNAC 
	aAdd(aCampos,{"","A1_NOME"   ,BuscaNome("A1_NOME")   ,"PB3_NOME"  ,BuscaNome("PB3_NOME")  ,BuscaDiferenca("A1_NOME"  ,"PB3_NOME",1   ),BuscaDiferenca("A1_NOME"  ,"PB3_NOME",2   ),BuscaDiferenca("A1_NOME"  ,"PB3_NOME",3   )})
	aAdd(aCampos,{"","A1_NREDUZ" ,BuscaNome("A1_NREDUZ") ,"PB3_NREDUZ",BuscaNome("PB3_NREDUZ"),BuscaDiferenca("A1_NREDUZ","PB3_NREDUZ",1 ),BuscaDiferenca("A1_NREDUZ","PB3_NREDUZ",2 ),BuscaDiferenca("A1_NREDUZ","PB3_NREDUZ",3 )})
	aAdd(aCampos,{"","A1_PESSOA" ,BuscaNome("A1_PESSOA") ,"PB3_PESSOA",BuscaNome("PB3_PESSOA"),BuscaDiferenca("A1_PESSOA","PB3_PESSOA",1 ),BuscaDiferenca("A1_PESSOA","PB3_PESSOA",2 ),BuscaDiferenca("A1_PESSOA","PB3_PESSOA",3 )})
	aAdd(aCampos,{"","A1_VEND"   ,BuscaNome("A1_VEND")   ,"PB3_VEND"  ,BuscaNome("PB3_VEND")  ,BuscaVendedor ("A1_VEND","PB3_VEND",1     ),BuscaVendedor ("A1_VEND","PB3_VEND",2     ),BuscaVendedor ("A1_VEND","PB3_VEND",3     )})
	aAdd(aCampos,{"","A1_TIPO"   ,BuscaNome("A1_TIPO")   ,"PB3_TIPO"  ,BuscaNome("PB3_TIPO")  ,BuscaDiferenca("A1_TIPO","PB3_TIPO",1     ),BuscaDiferenca("A1_TIPO","PB3_TIPO",2     ),BuscaDiferenca("A1_TIPO","PB3_TIPO",3     )})
	aAdd(aCampos,{"","A1_CEP"    ,BuscaNome("A1_CEP")    ,"PB3_CEP"   ,BuscaNome("PB3_CEP")   ,BuscaDiferenca("A1_CEP","PB3_CEP",1       ),BuscaDiferenca("A1_CEP","PB3_CEP",2       ),BuscaDiferenca("A1_CEP","PB3_CEP",3       )})
	aAdd(aCampos,{"","A1_END"    ,BuscaNome("A1_END")    ,"PB3_END"   ,BuscaNome("PB3_END")   ,BuscaEndereco ("A1_END","PB3_END",1       ),BuscaEndereco ("A1_END","PB3_END",2       ),BuscaEndereco ("A1_END","PB3_END",3       )})
	aAdd(aCampos,{"","A1_EST"    ,BuscaNome("A1_EST")    ,"PB3_EST"   ,BuscaNome("PB3_EST")   ,BuscaDiferenca("A1_EST","PB3_EST",1       ),BuscaDiferenca("A1_EST","PB3_EST",2       ),BuscaDiferenca("A1_EST","PB3_EST",3       )})
	aAdd(aCampos,{"","A1_COD_MUN",BuscaNome("A1_COD_MUN"),"PB3_COD_MU",BuscaNome("PB3_COD_MU"),BuscaDiferenca("A1_COD_MUN","PB3_COD_MU",1),BuscaDiferenca("A1_COD_MUN","PB3_COD_MU",2),BuscaDiferenca("A1_COD_MUN","PB3_COD_MU",3)})
	aAdd(aCampos,{"","A1_NATUREZ",BuscaNome("A1_NATUREZ"),"PB3_NATURE",BuscaNome("PB3_NATURE"),BuscaDiferenca("A1_NATUREZ","PB3_NATURE",1),BuscaDiferenca("A1_NATUREZ","PB3_NATURE",2),BuscaDiferenca("A1_NATUREZ","PB3_NATURE",3)})
	aAdd(aCampos,{"","A1_MUN"    ,BuscaNome("A1_MUN")    ,"PB3_MUN"   ,BuscaNome("PB3_MUN")   ,BuscaDiferenca("A1_MUN","PB3_MUN",1       ),BuscaDiferenca("A1_MUN","PB3_MUN",2       ),BuscaDiferenca("A1_MUN","PB3_MUN",3       )})
	aAdd(aCampos,{"","A1_BAIRRO" ,BuscaNome("A1_BAIRRO") ,"PB3_BAIRRO",BuscaNome("PB3_BAIRRO"),BuscaDiferenca("A1_BAIRRO","PB3_BAIRRO",1 ),BuscaDiferenca("A1_BAIRRO","PB3_BAIRRO",2 ),BuscaDiferenca("A1_BAIRRO","PB3_BAIRRO",3 )})
	aAdd(aCampos,{"","A1_ATIVIDA",BuscaNome("A1_ATIVIDA"),"PB3_ATIVID",BuscaNome("PB3_ATIVID"),BuscaDiferenca("A1_ATIVIDA","PB3_ATIVID",1),BuscaDiferenca("A1_ATIVIDA","PB3_ATIVID",2),BuscaDiferenca("A1_ATIVIDA","PB3_ATIVID",3)})
	aAdd(aCampos,{"","A1_TEL"    ,BuscaNome("A1_TEL")    ,"PB3_TEL"   ,BuscaNome("PB3_TEL")   ,BuscaTelefone ("A1_TEL","PB3_TEL",1       ),BuscaTelefone ("A1_TEL","PB3_TEL",2       ),BuscaTelefone ("A1_TEL","PB3_TEL",3       )})
	aAdd(aCampos,{"","A1_TELEX"  ,BuscaNome("A1_TELEX")  ,"PB3_TELEX" ,BuscaNome("PB3_TELEX") ,BuscaDiferenca("A1_TELEX","PB3_TELEX",1   ),BuscaDiferenca("A1_TELEX","PB3_TELEX",2   ),BuscaDiferenca("A1_TELEX","PB3_TELEX",3   )})
	aAdd(aCampos,{"","A1_FAX"    ,BuscaNome("A1_FAX")    ,"PB3_FAX"   ,BuscaNome("PB3_FAX")   ,BuscaDiferenca("A1_FAX","PB3_FAX",1       ),BuscaDiferenca("A1_FAX","PB3_FAX",2       ),BuscaDiferenca("A1_FAX","PB3_FAX",3       )})
	aAdd(aCampos,{"","A1_CONTATO",BuscaNome("A1_CONTATO"),"PB3_CONTAT",BuscaNome("PB3_CONTAT"),BuscaDiferenca("A1_CONTATO","PB3_CONTAT",1),BuscaDiferenca("A1_CONTATO","PB3_CONTAT",2),BuscaDiferenca("A1_CONTATO","PB3_CONTAT",3)})
	aAdd(aCampos,{"","A1_ENDCOB" ,BuscaNome("A1_ENDCOB") ,"PB3_ENDCOB",BuscaNome("PB3_ENDCOB"),BuscaEndereco ("A1_ENDCOB","PB3_ENDCOB",1 ),BuscaEndereco ("A1_ENDCOB","PB3_ENDCOB",2 ),BuscaEndereco ("A1_ENDCOB","PB3_ENDCOB",3 )})
	aAdd(aCampos,{"","A1_BAIRROC",BuscaNome("A1_BAIRROC"),"PB3_BAIRCB",BuscaNome("PB3_BAIRCB"),BuscaDiferenca("A1_BAIRROC","PB3_BAIRCB",1),BuscaDiferenca("A1_BAIRROC","PB3_BAIRCB",2),BuscaDiferenca("A1_BAIRROC","PB3_BAIRCB",3)})
	aAdd(aCampos,{"","A1_CEPC"   ,BuscaNome("A1_CEPC")   ,"PB3_CEPCOB",BuscaNome("PB3_CEPCOB"),BuscaDiferenca("A1_CEPC","PB3_CEPCOB",1   ),BuscaDiferenca("A1_CEPC","PB3_CEPCOB",2   ),BuscaDiferenca("A1_CEPC","PB3_CEPCOB",3   )})
	aAdd(aCampos,{"","A1_MUNC"   ,BuscaNome("A1_MUNC")   ,"PB3_CIDACO",BuscaNome("PB3_CIDACO"),BuscaDiferenca("A1_MUNC","PB3_CIDACO",1   ),BuscaDiferenca("A1_MUNC","PB3_CIDACO",2   ),BuscaDiferenca("A1_MUNC","PB3_CIDACO",3   )})
	aAdd(aCampos,{"","A1_ESTC"   ,BuscaNome("A1_ESTC")   ,"PB3_UFCOB" ,BuscaNome("PB3_UFCOB") ,BuscaDiferenca("A1_ESTC","PB3_UFCOB",1    ),BuscaDiferenca("A1_ESTC","PB3_UFCOB",2    ),BuscaDiferenca("A1_ESTC","PB3_UFCOB",3    )})
	aAdd(aCampos,{"","A1_CGC"    ,BuscaNome("A1_CGC")    ,"PB3_CGC"   ,BuscaNome("PB3_CGC")   ,BuscaDiferenca("A1_CGC","PB3_CGC",1       ),BuscaDiferenca("A1_CGC","PB3_CGC",2       ),BuscaDiferenca("A1_CGC","PB3_CGC",3       )})
	aAdd(aCampos,{"","A1_INSCR"  ,BuscaNome("A1_INSCR")  ,"PB3_INSCR" ,BuscaNome("PB3_INSCR") ,BuscaDiferenca("A1_INSCR","PB3_INSCR",1   ),BuscaDiferenca("A1_INSCR","PB3_INSCR",2   ),BuscaDiferenca("A1_INSCR","PB3_INSCR",3   )})
	aAdd(aCampos,{"","A1_INSCRM" ,BuscaNome("A1_INSCRM") ,"PB3_INSCRM",BuscaNome("PB3_INSCR") ,BuscaDiferenca("A1_INSCRM","PB3_INSCRM",1 ),BuscaDiferenca("A1_INSCRM","PB3_INSCRM",2 ),BuscaDiferenca("A1_INSCRM","PB3_INSCRM",3 )})
	aAdd(aCampos,{"","A1_COMIS"  ,BuscaNome("A1_COMIS")  ,"PB3_COMIS" ,BuscaNome("PB3_COMIS") ,BuscaDiferenca("A1_COMIS","PB3_COMIS",1   ),BuscaDiferenca("A1_COMIS","PB3_COMIS",2   ),BuscaDiferenca("A1_COMIS","PB3_COMIS",3   )})
	aAdd(aCampos,{"","A1_REGIAO" ,BuscaNome("A1_REGIAO") ,"PB3_REGIAO",BuscaNome("PB3_REGIAO"),BuscaDiferenca("A1_REGIAO","PB3_REGIAO",1 ),BuscaDiferenca("A1_REGIAO","PB3_REGIAO",2 ),BuscaDiferenca("A1_REGIAO","PB3_REGIAO",3 )})
	aAdd(aCampos,{"","A1_CONTA"  ,BuscaNome("A1_CONTA")  ,"PB3_CONTA" ,BuscaNome("PB3_CONTA") ,BuscaDiferenca("A1_CONTA","PB3_CONTA",1   ),BuscaDiferenca("A1_CONTA","PB3_CONTA",2   ),BuscaDiferenca("A1_CONTA","PB3_CONTA",3   )})
	aAdd(aCampos,{"","A1_BCO1"   ,BuscaNome("A1_BCO1")   ,"PB3_BCO1"  ,BuscaNome("PB3_BCO1")  ,BuscaDiferenca("A1_BCO1","PB3_BCO1",1     ),BuscaDiferenca("A1_BCO1","PB3_BCO1",2     ),BuscaDiferenca("A1_BCO1","PB3_BCO1",3     )})
	aAdd(aCampos,{"","A1_BCO2"   ,BuscaNome("A1_BCO2")   ,"PB3_BCO2"  ,BuscaNome("PB3_BCO2")  ,BuscaDiferenca("A1_BCO2","PB3_BCO2",1     ),BuscaDiferenca("A1_BCO2","PB3_BCO2",2     ),BuscaDiferenca("A1_BCO2","PB3_BCO2",3     )})
	aAdd(aCampos,{"","A1_BCO3"   ,BuscaNome("A1_BCO3")   ,"PB3_BCO3"  ,BuscaNome("PB3_BCO3")  ,BuscaDiferenca("A1_BCO3","PB3_BCO3",1     ),BuscaDiferenca("A1_BCO3","PB3_BCO3",2     ),BuscaDiferenca("A1_BCO3","PB3_BCO3",3     )})
	aAdd(aCampos,{"","A1_BCO4"   ,BuscaNome("A1_BCO4")   ,"PB3_BCO4"  ,BuscaNome("PB3_BCO4")  ,BuscaDiferenca("A1_BCO4","PB3_BCO4",1     ),BuscaDiferenca("A1_BCO4","PB3_BCO4",2     ),BuscaDiferenca("A1_BCO4","PB3_BCO4",3     )})
	aAdd(aCampos,{"","A1_BCO5"   ,BuscaNome("A1_BCO5")   ,"PB3_BCO5"  ,BuscaNome("PB3_BCO5")  ,BuscaDiferenca("A1_BCO5","PB3_BCO5",1     ),BuscaDiferenca("A1_BCO5","PB3_BCO5",2     ),BuscaDiferenca("A1_BCO5","PB3_BCO5",3     )})
	aAdd(aCampos,{"","A1_TRANSP" ,BuscaNome("A1_TRANSP") ,"PB3_TRANSP",BuscaNome("PB3_TRANSP"),BuscaDiferenca("A1_TRANSP","PB3_TRANSP",1 ),BuscaDiferenca("A1_TRANSP","PB3_TRANSP",2 ),BuscaDiferenca("A1_TRANSP","PB3_TRANSP",3 )})
	aAdd(aCampos,{"","A1_TPFRET" ,BuscaNome("A1_TPFRET") ,"PB3_TPFRET",BuscaNome("PB3_TPFRET"),BuscaDiferenca("A1_TPFRET","PB3_TPFRET",1 ),BuscaDiferenca("A1_TPFRET","PB3_TPFRET",2 ),BuscaDiferenca("A1_TPFRET","PB3_TPFRET",3 )})
	aAdd(aCampos,{"","A1_COND"   ,BuscaNome("A1_COND")   ,"PB3_COND"  ,BuscaNome("PB3_COND")  ,BuscaDiferenca("A1_COND","PB3_COND",1     ),BuscaDiferenca("A1_COND","PB3_COND",2     ),BuscaDiferenca("A1_COND","PB3_COND",3     )})
	aAdd(aCampos,{"","A1_CLASSE" ,BuscaNome("A1_CLASSE") ,"PB3_CLASSE",BuscaNome("PB3_CLASSE"),BuscaDiferenca("A1_CLASSE","PB3_CLASSE",1 ),BuscaDiferenca("A1_CLASSE","PB3_CLASSE",2 ),BuscaDiferenca("A1_CLASSE","PB3_CLASSE",3 )})
	aAdd(aCampos,{"","A1_RISCO"  ,BuscaNome("A1_RISCO")  ,"PB3_RISCO" ,BuscaNome("PB3_RISCO") ,BuscaDiferenca("A1_RISCO","PB3_RISCO",1   ),BuscaDiferenca("A1_RISCO","PB3_RISCO",2   ),BuscaDiferenca("A1_RISCO","PB3_RISCO",3   )})
	aAdd(aCampos,{"","A1_LC"     ,BuscaNome("A1_LC" )    ,"PB3_LIMAPR",BuscaNome("PB3_LIMAPR"),BuscaDiferenca("A1_LC","PB3_LIMAPR",1     ),BuscaDiferenca("A1_LC","PB3_LIMAPR",2     ),BuscaDiferenca("A1_LC","PB3_LIMAPR",3     )})
	aAdd(aCampos,{"","A1_VENCLC" ,BuscaNome("A1_VENCLC") ,"PB3_VENCLC",BuscaNome("PB3_VENCLC"),BuscaDiferenca("A1_VENCLC","PB3_VENCLC",1 ),BuscaDiferenca("A1_VENCLC","PB3_VENCLC",2 ),BuscaDiferenca("A1_VENCLC","PB3_VENCLC",3 )})
	aAdd(aCampos,{"","A1_MCOMPRA",BuscaNome("A1_MCOMPRA"),"PB3_MCOMPR",BuscaNome("PB3_MCOMPR"),BuscaDiferenca("A1_MCOMPRA","PB3_MCOMPR",1),BuscaDiferenca("A1_MCOMPRA","PB3_MCOMPR",2),BuscaDiferenca("A1_MCOMPRA","PB3_MCOMPR",3)})
	aAdd(aCampos,{"","A1_METR"   ,BuscaNome("A1_METR")   ,"PB3_METR"  ,BuscaNome("PB3_METR")  ,BuscaDiferenca("A1_METR","PB3_METR",1     ),BuscaDiferenca("A1_METR","PB3_METR",2     ),BuscaDiferenca("A1_METR","PB3_METR",3     )})
	aAdd(aCampos,{"","A1_MSALDO" ,BuscaNome("A1_MSALDO") ,"PB3_MSALDO",BuscaNome("PB3_MSALDO"),BuscaDiferenca("A1_MSALDO","PB3_MSALDO",1 ),BuscaDiferenca("A1_MSALDO","PB3_MSALDO",2 ),BuscaDiferenca("A1_MSALDO","PB3_MSALDO",3 )})
	aAdd(aCampos,{"","A1_NROCOM" ,BuscaNome("A1_NROCOM") ,"PB3_NROCOM",BuscaNome("PB3_NROCOM"),BuscaDiferenca("A1_NROCOM","PB3_NROCOM",1 ),BuscaDiferenca("A1_NROCOM","PB3_NROCOM",2 ),BuscaDiferenca("A1_NROCOM","PB3_NROCOM",3 )})
	aAdd(aCampos,{"","A1_PRICOM" ,BuscaNome("A1_PRICOM") ,"PB3_PRICOM",BuscaNome("PB3_PRICOM"),BuscaDiferenca("A1_PRICOM","PB3_PRICOM",1 ),BuscaDiferenca("A1_PRICOM","PB3_PRICOM",2 ),BuscaDiferenca("A1_PRICOM","PB3_PRICOM",3 )})
	aAdd(aCampos,{"","A1_ULTCOM" ,BuscaNome("A1_ULTCOM") ,"PB3_ULTCOM",BuscaNome("PB3_ULTCOM"),BuscaDiferenca("A1_ULTCOM","PB3_ULTCOM",1 ),BuscaDiferenca("A1_ULTCOM","PB3_ULTCOM",2 ),BuscaDiferenca("A1_ULTCOM","PB3_ULTCOM",3 )})
	aAdd(aCampos,{"","A1_TEMVIS" ,BuscaNome("A1_TEMVIS") ,"PB3_TEMVIS",BuscaNome("PB3_TEMVIS"),BuscaDiferenca("A1_TEMVIS","PB3_TEMVIS",1 ),BuscaDiferenca("A1_TEMVIS","PB3_TEMVIS",2 ),BuscaDiferenca("A1_TEMVIS","PB3_TEMVIS",3 )})
	aAdd(aCampos,{"","A1_ULTVIS" ,BuscaNome("A1_ULTVIS") ,"PB3_ULTVIS",BuscaNome("PB3_ULTVIS"),BuscaDiferenca("A1_ULTVIS","PB3_ULTVIS",1 ),BuscaDiferenca("A1_ULTVIS","PB3_ULTVIS",2 ),BuscaDiferenca("A1_ULTVIS","PB3_ULTVIS",3 )})
	aAdd(aCampos,{"","A1_MENSAGE",BuscaNome("A1_MENSAGE"),"PB3_MENSAG",BuscaNome("PB3_MENSAG"),BuscaDiferenca("A1_MENSAGE","PB3_MENSAG",1),BuscaDiferenca("A1_MENSAGE","PB3_MENSAG",2),BuscaDiferenca("A1_MENSAGE","PB3_MENSAG",3)})
	aAdd(aCampos,{"","A1_NROPAG" ,BuscaNome("A1_NROPAG") ,"PB3_NROPAG",BuscaNome("PB3_NROPAG"),BuscaDiferenca("A1_NROPAG","PB3_NROPAG",1 ),BuscaDiferenca("A1_NROPAG","PB3_NROPAG",2 ),BuscaDiferenca("A1_NROPAG","PB3_NROPAG",3 )})
	aAdd(aCampos,{"","A1_SALDUP" ,BuscaNome("A1_SALDUP") ,"PB3_SALDUP",BuscaNome("PB3_SALDUP"),BuscaDiferenca("A1_SALDUP","PB3_SALDUP",1 ),BuscaDiferenca("A1_SALDUP","PB3_SALDUP",2 ),BuscaDiferenca("A1_SALDUP","PB3_SALDUP",3 )})
	aAdd(aCampos,{"","A1_SALPEDL",BuscaNome("A1_SALPEDL"),"PB3_SALPEL",BuscaNome("PB3_SALPEL"),BuscaDiferenca("A1_SALPEDL","PB3_SALPEL",1),BuscaDiferenca("A1_SALPEDL","PB3_SALPEL",2),BuscaDiferenca("A1_SALPEDL","PB3_SALPEL",3)})
	aAdd(aCampos,{"","A1_SUFRAMA",BuscaNome("A1_SUFRAMA"),"PB3_SUFRAM",BuscaNome("PB3_SUFRAM"),BuscaDiferenca("A1_SUFRAMA","PB3_SUFRAM",1),BuscaDiferenca("A1_SUFRAMA","PB3_SUFRAM",2),BuscaDiferenca("A1_SUFRAMA","PB3_SUFRAM",3)})
	aAdd(aCampos,{"","A1_TRANSF" ,BuscaNome("A1_TRANSF") ,"PB3_TRANSF",BuscaNome("PB3_TRANSF"),BuscaDiferenca("A1_TRANSF","PB3_TRANSF",1 ),BuscaDiferenca("A1_TRANSF","PB3_TRANSF",2 ),BuscaDiferenca("A1_TRANSF","PB3_TRANSF",3 )})
	aAdd(aCampos,{"","A1_ATR"    ,BuscaNome("A1_ATR")    ,"PB3_ATR"   ,BuscaNome("PB3_ATR")   ,BuscaDiferenca("A1_ATR","PB3_ATR",1       ),BuscaDiferenca("A1_ATR","PB3_ATR",2       ),BuscaDiferenca("A1_ATR","PB3_ATR",3       )})
	aAdd(aCampos,{"","A1_VACUM"  ,BuscaNome("A1_VACUM")  ,"PB3_VACUM" ,BuscaNome("PB3_VACUM") ,BuscaDiferenca("A1_VACUM","PB3_VACUM",1   ),BuscaDiferenca("A1_VACUM","PB3_VACUM",2   ),BuscaDiferenca("A1_VACUM","PB3_VACUM",3   )})
	aAdd(aCampos,{"","A1_SALPED" ,BuscaNome("A1_SALPED") ,"PB3_SALPED",BuscaNome("PB3_SALPED"),BuscaDiferenca("A1_SALPED","PB3_SALPED",1 ),BuscaDiferenca("A1_SALPED","PB3_SALPED",2 ),BuscaDiferenca("A1_SALPED","PB3_SALPED",3 )})
	aAdd(aCampos,{"","A1_TITPROT",BuscaNome("A1_TITPROT"),"PB3_TITPRO",BuscaNome("PB3_TITPRO"),BuscaDiferenca("A1_TITPROT","PB3_TITPRO",1),BuscaDiferenca("A1_TITPROT","PB3_TITPRO",2),BuscaDiferenca("A1_TITPROT","PB3_TITPRO",3)})
	aAdd(aCampos,{"","A1_DTULTIT",BuscaNome("A1_DTULTIT"),"PB3_DTULTI",BuscaNome("PB3_DTULTI"),BuscaDiferenca("A1_DTULTIT","PB3_DTULTI",1),BuscaDiferenca("A1_DTULTIT","PB3_DTULTI",2),BuscaDiferenca("A1_DTULTIT","PB3_DTULTI",3)})
	aAdd(aCampos,{"","A1_CHQDEVO",BuscaNome("A1_CHQDEVO"),"PB3_CHQDEV",BuscaNome("PB3_CHQDEV"),BuscaDiferenca("A1_CHQDEVO","PB3_CHQDEV",1),BuscaDiferenca("A1_CHQDEVO","PB3_CHQDEV",2),BuscaDiferenca("A1_CHQDEVO","PB3_CHQDEV",3)})
	aAdd(aCampos,{"","A1_DTULCHQ",BuscaNome("A1_DTULCHQ"),"PB3_DTULCH",BuscaNome("PB3_DTULCH"),BuscaDiferenca("A1_DTULCHQ","PB3_DTULCH",1),BuscaDiferenca("A1_DTULCHQ","PB3_DTULCH",2),BuscaDiferenca("A1_DTULCHQ","PB3_DTULCH",3)})
	aAdd(aCampos,{"","A1_MATR"   ,BuscaNome("A1_MATR")   ,"PB3_MATR"  ,BuscaNome("PB3_MATR")  ,BuscaDiferenca("A1_MATR","PB3_MATR",1     ),BuscaDiferenca("A1_MATR","PB3_MATR",2     ),BuscaDiferenca("A1_MATR","PB3_MATR",3     )})
	aAdd(aCampos,{"","A1_MAIDUPL",BuscaNome("A1_MAIDUPL"),"PB3_MAIDUP",BuscaNome("PB3_MAIDUP"),BuscaDiferenca("A1_MAIDUPL","PB3_MAIDUP",1),BuscaDiferenca("A1_MAIDUPL","PB3_MAIDUP",2),BuscaDiferenca("A1_MAIDUPL","PB3_MAIDUP",3)})
	aAdd(aCampos,{"","A1_TABELA" ,BuscaNome("A1_TABELA") ,"PB3_TABELA",BuscaNome("PB3_TABELA"),BuscaDiferenca("A1_TABELA","PB3_TABELA",1 ),BuscaDiferenca("A1_TABELA","PB3_TABELA",2 ),BuscaDiferenca("A1_TABELA","PB3_TABELA",3 )})
	aAdd(aCampos,{"","A1_INCISS" ,BuscaNome("A1_INCISS") ,"PB3_INCISS",BuscaNome("PB3_INCISS"),BuscaDiferenca("A1_INCISS","PB3_INCISS",1 ),BuscaDiferenca("A1_INCISS","PB3_INCISS",2 ),BuscaDiferenca("A1_INCISS","PB3_INCISS",3 )})
	aAdd(aCampos,{"","A1_AGREG"  ,BuscaNome("A1_AGREG")  ,"PB3_AGREG" ,BuscaNome("PB3_AGREG") ,BuscaDiferenca("A1_AGREG","PB3_AGREG",1   ),BuscaDiferenca("A1_AGREG","PB3_AGREG",2   ),BuscaDiferenca("A1_AGREG","PB3_AGREG",3   )})
	aAdd(aCampos,{"","A1_SALDUPM",BuscaNome("A1_SALDUPM"),"PB3_SALDUF",BuscaNome("PB3_SALDUF"),BuscaDiferenca("A1_SALDUPM","PB3_SALDUF",1),BuscaDiferenca("A1_SALDUPM","PB3_SALDUF",2),BuscaDiferenca("A1_SALDUPM","PB3_SALDUF",3)})
	aAdd(aCampos,{"","A1_PAGATR" ,BuscaNome("A1_PAGATR") ,"PB3_PAGATR",BuscaNome("PB3_PAGATR"),BuscaDiferenca("A1_PAGATR","PB3_PAGATR",1 ),BuscaDiferenca("A1_PAGATR","PB3_PAGATR",2 ),BuscaDiferenca("A1_PAGATR","PB3_PAGATR",3 )})
	aAdd(aCampos,{"","A1_CARGO1" ,BuscaNome("A1_CARGO1") ,"PB3_CARGO1",BuscaNome("PB3_CARGO1"),BuscaDiferenca("A1_CARGO1","PB3_CARGO1",1 ),BuscaDiferenca("A1_CARGO1","PB3_CARGO1",2 ),BuscaDiferenca("A1_CARGO1","PB3_CARGO1",3 )})
	aAdd(aCampos,{"","A1_SUPER"  ,BuscaNome("A1_SUPER")  ,"PB3_SUPER" ,BuscaNome("PB3_SUPER") ,BuscaDiferenca("A1_SUPER","PB3_SUPER",1   ),BuscaDiferenca("A1_SUPER","PB3_SUPER",2   ),BuscaDiferenca("A1_SUPER","PB3_SUPER",3   )})
	aAdd(aCampos,{"","A1_RTEC"   ,BuscaNome("A1_RTEC")   ,"PB3_RTEC"  ,BuscaNome("PB3_RTEC")  ,BuscaDiferenca("A1_RTEC","PB3_RTEC",1     ),BuscaDiferenca("A1_RTEC","PB3_RTEC",2     ),BuscaDiferenca("A1_RTEC","PB3_RTEC",3     )})
	aAdd(aCampos,{"","A1_ALIQIR" ,BuscaNome("A1_ALIQIR") ,"PB3_ALIQIR",BuscaNome("PB3_ALIQIR"),BuscaDiferenca("A1_ALIQIR","PB3_ALIQIR",1 ),BuscaDiferenca("A1_ALIQIR","PB3_ALIQIR",2 ),BuscaDiferenca("A1_ALIQIR","PB3_ALIQIR",3 )})
	aAdd(aCampos,{"","A1_OBSERV" ,BuscaNome("A1_OBSERV") ,"PB3_OBSERV",BuscaNome("PB3_OBSERV"),BuscaDiferenca("A1_OBSERV","PB3_OBSERV",1 ),BuscaDiferenca("A1_OBSERV","PB3_OBSERV",2 ),BuscaDiferenca("A1_OBSERV","PB3_OBSERV",3 )})
	aAdd(aCampos,{"","A1_CALCSUF",BuscaNome("A1_CALCSUF"),"PB3_CALCSU",BuscaNome("PB3_CALCSU"),BuscaDiferenca("A1_CALCSUF","PB3_CALCSU",1),BuscaDiferenca("A1_CALCSUF","PB3_CALCSU",2),BuscaDiferenca("A1_CALCSUF","PB3_CALCSU",3)})
	aAdd(aCampos,{"","A1_RG"     ,BuscaNome("A1_RG")     ,"PB3_RG"    ,BuscaNome("PB3_RG")    ,BuscaDiferenca("A1_RG","PB3_RG",1         ),BuscaDiferenca("A1_RG","PB3_RG",2         ),BuscaDiferenca("A1_RG","PB3_RG",3         )})
	aAdd(aCampos,{"","A1_DTNASC" ,BuscaNome("A1_DTNASC") ,"PB3_DTNASC",BuscaNome("PB3_DTNASC"),BuscaDiferenca("A1_DTNASC","PB3_DTNASC",1 ),BuscaDiferenca("A1_DTNASC","PB3_DTNASC",2 ),BuscaDiferenca("A1_DTNASC","PB3_DTNASC",3 )})
	aAdd(aCampos,{"","A1_CLIFAT" ,BuscaNome("A1_CLIFAT") ,"PB3_CLIFAT",BuscaNome("PB3_CLIFAT"),BuscaDiferenca("A1_CLIFAT","PB3_CLIFAT",1 ),BuscaDiferenca("A1_CLIFAT","PB3_CLIFAT",2 ),BuscaDiferenca("A1_CLIFAT","PB3_CLIFAT",3 )})
	aAdd(aCampos,{"","A1_GRPTRIB",BuscaNome("A1_GRPTRIB"),"PB3_GRPTRI",BuscaNome("PB3_GRPTRI"),BuscaDiferenca("A1_GRPTRIB","PB3_GRPTRI",1),BuscaDiferenca("A1_GRPTRIB","PB3_GRPTRI",2),BuscaDiferenca("A1_GRPTRIB","PB3_GRPTRI",3)})
	aAdd(aCampos,{"","A1_ENDENT" ,BuscaNome("A1_ENDENT") ,"PB3_ENDENT",BuscaNome("PB3_ENDENT"),BuscaEndereco ("A1_ENDENT","PB3_ENDENT",1 ),BuscaEndereco ("A1_ENDENT","PB3_ENDENT",2 ),BuscaEndereco ("A1_ENDENT","PB3_ENDENT",3 )})
	aAdd(aCampos,{"","A1_BAIRROE",BuscaNome("A1_BAIRROE"),"PB3_BAIREN",BuscaNome("PB3_BAIREN"),BuscaDiferenca("A1_BAIRROE","PB3_BAIREN",1),BuscaDiferenca("A1_BAIRROE","PB3_BAIREN",2),BuscaDiferenca("A1_BAIRROE","PB3_BAIREN",3)})
	aAdd(aCampos,{"","A1_CEPE"   ,BuscaNome("A1_CEPE")   ,"PB3_CEPENT",BuscaNome("PB3_CEPENT"),BuscaDiferenca("A1_CEPE","PB3_CEPENT",1   ),BuscaDiferenca("A1_CEPE","PB3_CEPENT",2   ),BuscaDiferenca("A1_CEPE","PB3_CEPENT",3   )})
	aAdd(aCampos,{"","A1_MUNE"   ,BuscaNome("A1_MUNE")   ,"PB3_CIDENT",BuscaNome("PB3_CIDENT"),BuscaDiferenca("A1_MUNE","PB3_CIDENT",1   ),BuscaDiferenca("A1_MUNE","PB3_CIDENT",2   ),BuscaDiferenca("A1_MUNE","PB3_CIDENT",3   )})
	aAdd(aCampos,{"","A1_ESTE"   ,BuscaNome("A1_ESTE")   ,"PB3_UFENT" ,BuscaNome("PB3_UFENT") ,BuscaDiferenca("A1_ESTE","PB3_UFENT",1    ),BuscaDiferenca("A1_ESTE","PB3_UFENT",2    ),BuscaDiferenca("A1_ESTE","PB3_UFENT",3    )})
	aAdd(aCampos,{"","A1_CGCENT" ,BuscaNome("A1_CGCENT") ,"PB3_CPFENT",BuscaNome("PB3_CPFENT"),BuscaDiferenca("A1_CGCENT","PB3_CPFENT",1 ),BuscaDiferenca("A1_CGCENT","PB3_CPFENT",2 ),BuscaDiferenca("A1_CGCENT","PB3_CPFENT",3 )})
	aAdd(aCampos,{"","A1_INSENT" ,BuscaNome("A1_INSENT") ,"PB3_INSCEN",BuscaNome("PB3_INSCEN"),BuscaDiferenca("A1_INSENT","PB3_INSCEN",1 ),BuscaDiferenca("A1_INSENT","PB3_INSCEN",2 ),BuscaDiferenca("A1_INSENT","PB3_INSCEN",3 )})
	aAdd(aCampos,{"","A1_SATIV1" ,BuscaNome("A1_SATIV1") ,"PB3_SEGTO" ,BuscaNome("PB3_SEGTO") ,BuscaDiferenca("A1_SATIV1","PB3_SEGTO",1  ),BuscaDiferenca("A1_SATIV1","PB3_SEGTO",2  ),BuscaDiferenca("A1_SATIV1","PB3_SEGTO",3  )})
	aAdd(aCampos,{"","A1_SATIV2" ,BuscaNome("A1_SATIV2") ,"PB3_SUBSEG",BuscaNome("PB3_SUBSEG"),BuscaDiferenca("A1_SATIV2","PB3_SUBSEG",1 ),BuscaDiferenca("A1_SATIV2","PB3_SUBSEG",2 ),BuscaDiferenca("A1_SATIV2","PB3_SUBSEG",3 )})
	aAdd(aCampos,{"","A1_EMAIL"  ,BuscaNome("A1_EMAIL")  ,"PB3_EMAIL" ,BuscaNome("PB3_EMAIL") ,BuscaDiferenca("A1_EMAIL","PB3_EMAIL",1   ),BuscaDiferenca("A1_EMAIL","PB3_EMAIL",2   ),BuscaDiferenca("A1_EMAIL","PB3_EMAIL",3   )})
	aAdd(aCampos,{"","A1_CODMUN" ,BuscaNome("A1_CODMUN") ,"PB3_CODMUN",BuscaNome("PB3_CODMUN"),BuscaDiferenca("A1_CODMUN","PB3_CODMUN",1 ),BuscaDiferenca("A1_CODMUN","PB3_CODMUN",2 ),BuscaDiferenca("A1_CODMUN","PB3_CODMUN",3 )})
	aAdd(aCampos,{"","A1_CODPAIS",BuscaNome("A1_CODPAIS"),"PB3_CODPAI",BuscaNome("PB3_CODPAI"),BuscaDiferenca("A1_CODPAIS","PB3_CODPAI",1),BuscaDiferenca("A1_CODPAIS","PB3_CODPAI",2),BuscaDiferenca("A1_CODPAIS","PB3_CODPAI",3)})
	aAdd(aCampos,{"","A1_HPAGE"  ,BuscaNome("A1_HPAGE")  ,"PB3_HPAGE" ,BuscaNome("PB3_HPAGE") ,BuscaDiferenca("A1_HPAGE","PB3_HPAGE",1   ),BuscaDiferenca("A1_HPAGE","PB3_HPAGE",2   ),BuscaDiferenca("A1_HPAGE","PB3_HPAGE",3   )})
	aAdd(aCampos,{"","A1_CODHIST",BuscaNome("A1_CODHIST"),"PB3_CODHIS",BuscaNome("PB3_CODHIS"),BuscaDiferenca("A1_CODHIST","PB3_CODHIS",1),BuscaDiferenca("A1_CODHIST","PB3_CODHIS",2),BuscaDiferenca("A1_CODHIST","PB3_CODHIS",3)})
	aAdd(aCampos,{"","A1_PAIS"   ,BuscaNome("A1_PAIS")   ,"PB3_PAIS"  ,BuscaNome("PB3_PAIS")  ,BuscaDiferenca("A1_PAIS","PB3_PAIS",1     ),BuscaDiferenca("A1_PAIS","PB3_PAIS",2     ),BuscaDiferenca("A1_PAIS","PB3_PAIS",3     )})
	aAdd(aCampos,{"","A1_TMPSTD" ,BuscaNome("A1_TMPSTD") ,"PB3_TMPSTD",BuscaNome("PB3_TMPSTD"),BuscaDiferenca("A1_TMPSTD","PB3_TMPSTD",1 ),BuscaDiferenca("A1_TMPSTD","PB3_TMPSTD",2 ),BuscaDiferenca("A1_TMPSTD","PB3_TMPSTD",3 )})
	aAdd(aCampos,{"","A1_RECINSS",BuscaNome("A1_RECINSS"),"PB3_RECINS",BuscaNome("PB3_RECINS"),BuscaDiferenca("A1_RECINSS","PB3_RECINS",1),BuscaDiferenca("A1_RECINSS","PB3_RECINS",2),BuscaDiferenca("A1_RECINSS","PB3_RECINS",3)})
	aAdd(aCampos,{"","A1_NOMSOC1",BuscaNome("A1_NOMSOC1"),"PB3_NOMSO1",BuscaNome("PB3_NOMSO1"),BuscaDiferenca("A1_NOMSOC1","PB3_NOMSO1",1),BuscaDiferenca("A1_NOMSOC1","PB3_NOMSO1",2),BuscaDiferenca("A1_NOMSOC1","PB3_NOMSO1",3)})
	aAdd(aCampos,{"","A1_CPFSOC1",BuscaNome("A1_CPFSOC1"),"PB3_NOMSO2",BuscaNome("PB3_NOMSO2"),BuscaDiferenca("A1_CPFSOC1","PB3_NOMSO2",1),BuscaDiferenca("A1_CPFSOC1","PB3_NOMSO2",2),BuscaDiferenca("A1_CPFSOC1","PB3_NOMSO2",3)})
	aAdd(aCampos,{"","A1_NOMSOC2",BuscaNome("A1_NOMSOC2"),"PB3_NOMSO2",BuscaNome("PB3_NOMSO2"),BuscaDiferenca("A1_NOMSOC2","PB3_NOMSO2",1),BuscaDiferenca("A1_NOMSOC2","PB3_NOMSO2",2),BuscaDiferenca("A1_NOMSOC2","PB3_NOMSO2",3)})
	aAdd(aCampos,{"","A1_CPFSOC2",BuscaNome("A1_CPFSOC2"),"PB3_CGCSO2",BuscaNome("PB3_CGCSO2"),BuscaDiferenca("A1_CPFSOC2","PB3_CGCSO2",1),BuscaDiferenca("A1_CPFSOC2","PB3_CGCSO2",2),BuscaDiferenca("A1_CPFSOC2","PB3_CGCSO2",3)})
	aAdd(aCampos,{"","A1_NOMSOC3",BuscaNome("A1_NOMSOC3"),"PB3_NOMSO3",BuscaNome("PB3_NOMSO3"),BuscaDiferenca("A1_NOMSOC3","PB3_NOMSO3",1),BuscaDiferenca("A1_NOMSOC3","PB3_NOMSO3",2),BuscaDiferenca("A1_NOMSOC3","PB3_NOMSO3",3)})
	aAdd(aCampos,{"","A1_DEST_1" ,BuscaNome("A1_DEST_1") ,"PB3_DEST_1",BuscaNome("PB3_DEST_1"),BuscaDiferenca("A1_DEST_1","PB3_DEST_1",1 ),BuscaDiferenca("A1_DEST_1","PB3_DEST_1",2 ),BuscaDiferenca("A1_DEST_1","PB3_DEST_1",3 )})
	aAdd(aCampos,{"","A1_DEST_2" ,BuscaNome("A1_DEST_2") ,"PB3_DEST_2",BuscaNome("PB3_DEST_2"),BuscaDiferenca("A1_DEST_2","PB3_DEST_2",1 ),BuscaDiferenca("A1_DEST_2","PB3_DEST_2",2 ),BuscaDiferenca("A1_DEST_2","PB3_DEST_2",3 )})
	aAdd(aCampos,{"","A1_DEST_3" ,BuscaNome("A1_DEST_3") ,"PB3_DEST_3",BuscaNome("PB3_DEST_3"),BuscaDiferenca("A1_DEST_3","PB3_DEST_3",1 ),BuscaDiferenca("A1_DEST_3","PB3_DEST_3",2 ),BuscaDiferenca("A1_DEST_3","PB3_DEST_3",3 )})
	aAdd(aCampos,{"","A1_CODAGE" ,BuscaNome("A1_CODAGE") ,"PB3_CODAGE",BuscaNome("PB3_CODAGE"),BuscaDiferenca("A1_CODAGE","PB3_CODAGE",1 ),BuscaDiferenca("A1_CODAGE","PB3_CODAGE",2 ),BuscaDiferenca("A1_CODAGE","PB3_CODAGE",3 )})
	aAdd(aCampos,{"","A1_CLASVEN",BuscaNome("A1_CLASVEN"),"PB3_CLASVE",BuscaNome("PB3_CLASVE"),BuscaDiferenca("A1_CLASVEN","PB3_CLASVE",1),BuscaDiferenca("A1_CLASVEN","PB3_CLASVE",2),BuscaDiferenca("A1_CLASVEN","PB3_CLASVE",3)})
	aAdd(aCampos,{"","A1_CODMARC",BuscaNome("A1_CODMARC"),"PB3_CODMAR",BuscaNome("PB3_CODMAR"),BuscaDiferenca("A1_CODMARC","PB3_CODMAR",1),BuscaDiferenca("A1_CODMARC","PB3_CODMAR",2),BuscaDiferenca("A1_CODMARC","PB3_CODMAR",3)})
	aAdd(aCampos,{"","A1_COMAGE" ,BuscaNome("A1_COMAGE") ,"PB3_COMAGE",BuscaNome("PB3_CODMAR"),BuscaDiferenca("A1_COMAGE","PB3_COMAGE",1 ),BuscaDiferenca("A1_COMAGE","PB3_COMAGE",2 ),BuscaDiferenca("A1_COMAGE","PB3_COMAGE",3 )})
	aAdd(aCampos,{"","A1_CXPOSTA",BuscaNome("A1_CXPOSTA"),"PB3_CXPOST",BuscaNome("PB3_CXPOST"),BuscaDiferenca("A1_CXPOSTA","PB3_CXPOST",1),BuscaDiferenca("A1_CXPOSTA","PB3_CXPOST",2),BuscaDiferenca("A1_CXPOSTA","PB3_CXPOST",3)})
	aAdd(aCampos,{"","A1_CONDPAG",BuscaNome("A1_CONDPAG"),"PB3_CONDPA",BuscaNome("PB3_CONDPA"),BuscaDiferenca("A1_CONDPAG","PB3_CONDPA",1),BuscaDiferenca("A1_CONDPAG","PB3_CONDPA",2),BuscaDiferenca("A1_CONDPAG","PB3_CONDPA",3)})
	aAdd(aCampos,{"","A1_DIASPAG",BuscaNome("A1_DIASPAG"),"PB3_DIASPA",BuscaNome("PB3_DIASPA"),BuscaDiferenca("A1_DIASPAG","PB3_DIASPA",1),BuscaDiferenca("A1_DIASPAG","PB3_DIASPA",2),BuscaDiferenca("A1_DIASPAG","PB3_DIASPA",3)})
	aAdd(aCampos,{"","A1_ESTADO" ,BuscaNome("A1_ESTADO") ,"PB3_ESTADO",BuscaNome("PB3_ESTADO"),BuscaDiferenca("A1_ESTADO","PB3_ESTADO",1 ),BuscaDiferenca("A1_ESTADO","PB3_ESTADO",2 ),BuscaDiferenca("A1_ESTADO","PB3_ESTADO",3 )})
	aAdd(aCampos,{"","A1_SUBCOD" ,BuscaNome("A1_SUBCOD") ,"PB3_SUBCOD",BuscaNome("PB3_SUBCOD"),BuscaDiferenca("A1_SUBCOD","PB3_SUBCOD",1 ),BuscaDiferenca("A1_SUBCOD","PB3_SUBCOD",2 ),BuscaDiferenca("A1_SUBCOD","PB3_SUBCOD",3 )})
	aAdd(aCampos,{"","A1_FORMVIS",BuscaNome("A1_FORMVIS"),"PB3_FORMVI",BuscaNome("PB3_FORMVI"),BuscaDiferenca("A1_FORMVIS","PB3_FORMVI",1),BuscaDiferenca("A1_FORMVIS","PB3_FORMVI",2),BuscaDiferenca("A1_FORMVIS","PB3_FORMVI",3)})
	aAdd(aCampos,{"","A1_RECCOFI",BuscaNome("A1_RECCOFI"),"PB3_RECCOF",BuscaNome("PB3_RECCOF"),BuscaDiferenca("A1_RECCOFI","PB3_RECCOF",1),BuscaDiferenca("A1_RECCOFI","PB3_RECCOF",2),BuscaDiferenca("A1_RECCOFI","PB3_RECCOF",3)})
	aAdd(aCampos,{"","A1_RECCSLL",BuscaNome("A1_RECCSLL"),"PB3_RECCSL",BuscaNome("PB3_RECCSL"),BuscaDiferenca("A1_RECCSLL","PB3_RECCSL",1),BuscaDiferenca("A1_RECCSLL","PB3_RECCSL",2),BuscaDiferenca("A1_RECCSLL","PB3_RECCSL",3)})
	aAdd(aCampos,{"","A1_RECPIS" ,BuscaNome("A1_RECPIS") ,"PB3_RECPIS",BuscaNome("PB3_RECPIS"),BuscaDiferenca("A1_RECPIS","PB3_RECPIS",1 ),BuscaDiferenca("A1_RECPIS","PB3_RECPIS",2 ),BuscaDiferenca("A1_RECPIS","PB3_RECPIS",3 )})
	aAdd(aCampos,{"","A1_TIPCLI" ,BuscaNome("A1_TIPCLI") ,"PB3_TIPCLI",BuscaNome("PB3_TIPCLI"),BuscaDiferenca("A1_TIPCLI","PB3_TIPCLI",1 ),BuscaDiferenca("A1_TIPCLI","PB3_TIPCLI",2 ),BuscaDiferenca("A1_TIPCLI","PB3_TIPCLI",3 )})
	aAdd(aCampos,{"","A1_TMPVIS" ,BuscaNome("A1_TMPVIS") ,"PB3_TMPVIS",BuscaNome("PB3_TMPVIS"),BuscaDiferenca("A1_TMPVIS","PB3_TMPVIS",1 ),BuscaDiferenca("A1_TMPVIS","PB3_TMPVIS",2 ),BuscaDiferenca("A1_TMPVIS","PB3_TMPVIS",3 )})
	aAdd(aCampos,{"","A1_IMPENT" ,BuscaNome("A1_IMPENT") ,"PB3_IMPEND",BuscaNome("PB3_IMPEND"),BuscaDiferenca("A1_IMPENT","PB3_IMPEND",1 ),BuscaDiferenca("A1_IMPENT","PB3_IMPEND",2 ),BuscaDiferenca("A1_IMPENT","PB3_IMPEND",3 )})
	aAdd(aCampos,{"","A1_NRE"    ,BuscaNome("A1_NRE")    ,"PB3_REGESP",BuscaNome("PB3_REGESP"),BuscaDiferenca("A1_NRE","PB3_REGESP",1    ),BuscaDiferenca("A1_NRE","PB3_REGESP",2    ),BuscaDiferenca("A1_NRE","PB3_REGESP",3    )})
	aAdd(aCampos,{"","A1_DDD"    ,BuscaNome("A1_DDD")    ,"PB3_DDD"   ,BuscaNome("PB3_DDD")   ,BuscaDiferenca("A1_DDD","PB3_DDD",1       ),BuscaDiferenca("A1_DDD","PB3_DDD",2       ),BuscaDiferenca("A1_DDD","PB3_DDD",3       )})
	aAdd(aCampos,{"","A1_DDI"    ,BuscaNome("A1_DDI")    ,"PB3_DDI"   ,BuscaNome("PB3_DDI")   ,BuscaDiferenca("A1_DDI","PB3_DDI",1       ),BuscaDiferenca("A1_DDI","PB3_DDI",2       ),BuscaDiferenca("A1_DDI","PB3_DDI",3       )})
	aAdd(aCampos,{"","A1_PFISICA",BuscaNome("A1_PFISICA"),"PB3_PFISIC",BuscaNome("PB3_PFISIC"),BuscaDiferenca("A1_PFISICA","PB3_PFISIC",1),BuscaDiferenca("A1_PFISICA","PB3_PFISIC",2),BuscaDiferenca("A1_PFISICA","PB3_PFISIC",3)})
	aAdd(aCampos,{"","A1_LCFIN"  ,BuscaNome("A1_LCFIN")  ,"PB3_LCFIN" ,BuscaNome("PB3_LCFIN") ,BuscaDiferenca("A1_LCFIN","PB3_LCFIN",1   ),BuscaDiferenca("A1_LCFIN","PB3_LCFIN",2   ),BuscaDiferenca("A1_LCFIN","PB3_LCFIN",3   )})
	aAdd(aCampos,{"","A1_MOEDALC",BuscaNome("A1_MOEDALC"),"PB3_MOEDAL",BuscaNome("PB3_MOEDAL"),BuscaDiferenca("A1_MOEDALC","PB3_MOEDAL",1),BuscaDiferenca("A1_MOEDALC","PB3_MOEDAL",2),BuscaDiferenca("A1_MOEDALC","PB3_MOEDAL",3)})
	aAdd(aCampos,{"","A1_RECISS" ,BuscaNome("A1_RECISS") ,"PB3_RECISS",BuscaNome("PB3_RECISS"),BuscaDiferenca("A1_RECISS","PB3_RECISS",1 ),BuscaDiferenca("A1_RECISS","PB3_RECISS",2 ),BuscaDiferenca("A1_RECISS","PB3_RECISS",3 )})
	aAdd(aCampos,{"","A1_TIPPER" ,BuscaNome("A1_TIPPER") ,"PB3_RECISS",BuscaNome("PB3_RECISS"),BuscaDiferenca("A1_TIPPER","PB3_RECISS",1 ),BuscaDiferenca("A1_TIPPER","PB3_RECISS",2 ),BuscaDiferenca("A1_TIPPER","PB3_RECISS",3 )})
	aAdd(aCampos,{"","A1_SALFIN" ,BuscaNome("A1_SALFIN") ,"PB3_SALFIN",BuscaNome("PB3_SALFIN"),BuscaDiferenca("A1_SALFIN","PB3_SALFIN",1 ),BuscaDiferenca("A1_SALFIN","PB3_SALFIN",2 ),BuscaDiferenca("A1_SALFIN","PB3_SALFIN",3 )})
	aAdd(aCampos,{"","A1_B2B"    ,BuscaNome("A1_B2B")    ,"PB3_B2B"   ,BuscaNome("PB3_B2B")   ,BuscaDiferenca("A1_B2B","PB3_B2B",1       ),BuscaDiferenca("A1_B2B","PB3_B2B",2       ),BuscaDiferenca("A1_B2B","PB3_B2B",3       )})
	aAdd(aCampos,{"","A1_PRIOR"  ,BuscaNome("A1_PRIOR")  ,"PB3_B2B"   ,BuscaNome("PB3_B2B")   ,BuscaDiferenca("A1_PRIOR","PB3_B2B",1     ),BuscaDiferenca("A1_PRIOR","PB3_B2B",2     ),BuscaDiferenca("A1_PRIOR","PB3_B2B",3     )})
	aAdd(aCampos,{"","A1_GRPVEN" ,BuscaNome("A1_GRPVEN") ,"PB3_GRPVEN",BuscaNome("PB3_GRPVEN"),BuscaDiferenca("A1_GRPVEN","PB3_GRPVEN",1 ),BuscaDiferenca("A1_GRPVEN","PB3_GRPVEN",2 ),BuscaDiferenca("A1_GRPVEN","PB3_GRPVEN",3 )})
	aAdd(aCampos,{"","A1_GRPVEN" ,BuscaNome("A1_GRPVEN") ,"PB3_GRPVEN",BuscaNome("PB3_GRPVEN"),BuscaDiferenca("A1_GRPVEN","PB3_GRPVEN",1 ),BuscaDiferenca("A1_GRPVEN","PB3_GRPVEN",2 ),BuscaDiferenca("A1_GRPVEN","PB3_GRPVEN",3 )})
	aAdd(aCampos,{"","A1_CLICNV" ,BuscaNome("A1_CLICNV") ,"PB3_CLICNV",BuscaNome("PB3_CLICNV"),BuscaDiferenca("A1_CLICNV","PB3_CLICNV",1 ),BuscaDiferenca("A1_CLICNV","PB3_CLICNV",2 ),BuscaDiferenca("A1_CLICNV","PB3_CLICNV",3 )})
	aAdd(aCampos,{"","A1_SITUA"  ,BuscaNome("A1_SITUA")  ,"PB3_SITUA" ,BuscaNome("PB3_SITUA") ,BuscaDiferenca("A1_SITUA","PB3_SITUA",1   ),BuscaDiferenca("A1_SITUA","PB3_SITUA",2   ),BuscaDiferenca("A1_SITUA","PB3_SITUA",3   )})
	aAdd(aCampos,{"","A1_ABATIMP",BuscaNome("A1_ABATIMP"),"PB3_ABATIM",BuscaNome("PB3_ABATIM"),BuscaDiferenca("A1_ABATIMP","PB3_ABATIM",1),BuscaDiferenca("A1_ABATIMP","PB3_ABATIM",2),BuscaDiferenca("A1_ABATIMP","PB3_ABATIM",3)})
	aAdd(aCampos,{"","A1_REGCOB" ,BuscaNome("A1_REGCOB") ,"PB3_REGCOB",BuscaNome("PB3_REGCOB"),BuscaDiferenca("A1_REGCOB","PB3_REGCOB",1 ),BuscaDiferenca("A1_REGCOB","PB3_REGCOB",2 ),BuscaDiferenca("A1_REGCOB","PB3_REGCOB",3 )})
	aAdd(aCampos,{"","A1_TPESSOA",BuscaNome("A1_TPESSOA"),"PB3_TPESSO",BuscaNome("PB3_TPESSO"),BuscaDiferenca("A1_TPESSOA","PB3_TPESSO",1),BuscaDiferenca("A1_TPESSOA","PB3_TPESSO",2),BuscaDiferenca("A1_TPESSOA","PB3_TPESSO",3)})
	aAdd(aCampos,{"","A1_CODLOC" ,BuscaNome("A1_CODLOC") ,"PB3_CODLOC",BuscaNome("PB3_CODLOC"),BuscaDiferenca("A1_CODLOC","PB3_CODLOC",1 ),BuscaDiferenca("A1_CODLOC","PB3_CODLOC",2 ),BuscaDiferenca("A1_CODLOC","PB3_CODLOC",3 )})
	aAdd(aCampos,{"","A1_CONTAB" ,BuscaNome("A1_CONTAB") ,"PB3_CONTAB",BuscaNome("PB3_CONTAB"),BuscaDiferenca("A1_CONTAB","PB3_CONTAB",1 ),BuscaDiferenca("A1_CONTAB","PB3_CONTAB",2 ),BuscaDiferenca("A1_CONTAB","PB3_CONTAB",3 )})
	aAdd(aCampos,{"","A1_INSCRUR",BuscaNome("A1_INSCRUR"),"PB3_INSCRU",BuscaNome("PB3_INSCRU"),BuscaDiferenca("A1_INSCRUR","PB3_INSCRU",1),BuscaDiferenca("A1_INSCRUR","PB3_INSCRU",2),BuscaDiferenca("A1_INSCRUR","PB3_INSCRU",3)})
	aAdd(aCampos,{"","A1_NUMRA"  ,BuscaNome("A1_NUMRA")  ,"PB3_NUMRA" ,BuscaNome("PB3_NUMRA") ,BuscaDiferenca("A1_NUMRA","PB3_NUMRA",1   ),BuscaDiferenca("A1_NUMRA","PB3_NUMRA",2   ),BuscaDiferenca("A1_NUMRA","PB3_NUMRA",3   )})
	aAdd(aCampos,{"","A1_CDRDES" ,BuscaNome("A1_CDRDES") ,"PB3_CDRDES",BuscaNome("PB3_CDRDES"),BuscaDiferenca("A1_CDRDES","PB3_CDRDES",1 ),BuscaDiferenca("A1_CDRDES","PB3_CDRDES",2 ),BuscaDiferenca("A1_CDRDES","PB3_CDRDES",3 )})
	aAdd(aCampos,{"","A1_FILDEB" ,BuscaNome("A1_FILDEB") ,"PB3_FILDEB",BuscaNome("PB3_FILDEB"),BuscaDiferenca("A1_FILDEB","PB3_FILDEB",1 ),BuscaDiferenca("A1_FILDEB","PB3_FILDEB",2 ),BuscaDiferenca("A1_FILDEB","PB3_FILDEB",3 )})
	aAdd(aCampos,{"","A1_CODFOR" ,BuscaNome("A1_CODFOR") ,"PB3_CODFOR",BuscaNome("PB3_CODFOR"),BuscaDiferenca("A1_CODFOR","PB3_CODFOR",1 ),BuscaDiferenca("A1_CODFOR","PB3_CODFOR",2 ),BuscaDiferenca("A1_CODFOR","PB3_CODFOR",3 )})
	aAdd(aCampos,{"","A1_ABICS"  ,BuscaNome("A1_ABICS")  ,"PB3_ABICS" ,BuscaNome("PB3_ABICS") ,BuscaDiferenca("A1_ABICS","PB3_ABICS",1   ),BuscaDiferenca("A1_ABICS","PB3_ABICS",2   ),BuscaDiferenca("A1_ABICS","PB3_ABICS",3   )})
	aAdd(aCampos,{"","A1_BLEMAIL",BuscaNome("A1_BLEMAIL"),"PB3_ABICS" ,BuscaNome("PB3_ABICS") ,BuscaDiferenca("A1_BLEMAIL","PB3_ABICS",1 ),BuscaDiferenca("A1_BLEMAIL","PB3_ABICS",2 ),BuscaDiferenca("A1_BLEMAIL","PB3_ABICS",3 )})
	aAdd(aCampos,{"","A1_TIPOCLI",BuscaNome("A1_TIPOCLI"),"PB3_TIPOCL",BuscaNome("PB3_TIPOCL"),BuscaDiferenca("A1_TIPOCLI","PB3_TIPOCL",1),BuscaDiferenca("A1_TIPOCLI","PB3_TIPOCL",2),BuscaDiferenca("A1_TIPOCLI","PB3_TIPOCL",3)})
	aAdd(aCampos,{"","A1_SIMPNAC",BuscaNome("A1_SIMPNAC"),"PB3_SIMPLE",BuscaNome("PB3_SIMPLE"),BuscaDiferenca("A1_SIMPNAC","PB3_SIMPLE",1),BuscaDiferenca("A1_SIMPNAC","PB3_SIMPLE",2),BuscaDiferenca("A1_SIMPNAC","PB3_SIMPLE",3)})
	aAdd(aCampos,{"","A1_RECIRRF",BuscaNome("A1_RECIRRF"),"PB3_RECIRR",BuscaNome("PB3_RECIRR"),BuscaDiferenca("A1_RECIRRF","PB3_RECIRR",1),BuscaDiferenca("A1_RECIRRF","PB3_RECIRR",2),BuscaDiferenca("A1_RECIRRF","PB3_RECIRR",3)})
	aAdd(aCampos,{"","A1_TPISSRS",BuscaNome("A1_TPISSRS"),"PB3_TPISSR",BuscaNome("PB3_TPISSR"),BuscaDiferenca("A1_TPISSRS","PB3_TPISSR",1),BuscaDiferenca("A1_TPISSRS","PB3_TPISSR",2),BuscaDiferenca("A1_TPISSRS","PB3_TPISSR",3)})
	aAdd(aCampos,{"","A1_CTARE"  ,BuscaNome("A1_CTARE")  ,"PB3_CTARE" ,BuscaNome("PB3_CTARE") ,BuscaDiferenca("A1_CTARE","PB3_CTARE",1   ),BuscaDiferenca("A1_CTARE","PB3_CTARE",2   ),BuscaDiferenca("A1_CTARE","PB3_CTARE",3   )})
	aAdd(aCampos,{"","A1_RECFET" ,BuscaNome("A1_RECFET") ,"PB3_RECFET",BuscaNome("PB3_RECFET"),BuscaDiferenca("A1_RECFET","PB3_RECFET",1 ),BuscaDiferenca("A1_RECFET","PB3_RECFET",2 ),BuscaDiferenca("A1_RECFET","PB3_RECFET",3 )})
	aAdd(aCampos,{"","A1_CONTRIB",BuscaNome("A1_CONTRIB"),"PB3_CONTRI",BuscaNome("PB3_CONTRI"),BuscaDiferenca("A1_CONTRIB","PB3_CONTRI",1),BuscaDiferenca("A1_CONTRIB","PB3_CONTRI",2),BuscaDiferenca("A1_CONTRIB","PB3_CONTRI",3)})
	aAdd(aCampos,{"","A1_VINCULO",BuscaNome("A1_VINCULO"),"PB3_VINCUL",BuscaNome("PB3_VINCUL"),BuscaDiferenca("A1_VINCULO","PB3_VINCUL",1),BuscaDiferenca("A1_VINCULO","PB3_VINCUL",2),BuscaDiferenca("A1_VINCULO","PB3_VINCUL",3)})
	aAdd(aCampos,{"","A1_DTINIV" ,BuscaNome("A1_DTINIV") ,"PB3_DTINIV",BuscaNome("PB3_DTINIV"),BuscaDiferenca("A1_DTINIV","PB3_DTINIV",1 ),BuscaDiferenca("A1_DTINIV","PB3_DTINIV",2 ),BuscaDiferenca("A1_DTINIV","PB3_DTINIV",3 )})
	aAdd(aCampos,{"","A1_DTFIMV" ,BuscaNome("A1_DTFIMV") ,"PB3_DTFIMV",BuscaNome("PB3_DTFIMV"),BuscaDiferenca("A1_DTFIMV","PB3_DTFIMV",1 ),BuscaDiferenca("A1_DTFIMV","PB3_DTFIMV",2 ),BuscaDiferenca("A1_DTFIMV","PB3_DTFIMV",3 )})
	aAdd(aCampos,{"","A1_ZZDESCB",BuscaNome("A1_ZZDESCB"),"PB3_DESC"  ,BuscaNome("PB3_DESC")  ,BuscaDiferenca("A1_ZZDESCB","PB3_DESC",1  ),BuscaDiferenca("A1_ZZDESCB","PB3_DESC",2  ),BuscaDiferenca("A1_ZZDESCB","PB3_DESC",3  )})
	aAdd(aCampos,{"","A1_CBO"    ,BuscaNome("A1_CBO")    ,"PB3_CBO"   ,BuscaNome("PB3_CBO")   ,BuscaDiferenca("A1_CBO","PB3_CBO",1       ),BuscaDiferenca("A1_CBO","PB3_CBO",2       ),BuscaDiferenca("A1_CBO","PB3_CBO",3       )})
	aAdd(aCampos,{"","A1_CNAE"   ,BuscaNome("A1_CNAE")   ,"PB3_CNAE"  ,BuscaNome("PB3_CNAE")  ,BuscaDiferenca("A1_CNAE","PB3_CNAE",1     ),BuscaDiferenca("A1_CNAE","PB3_CNAE",2     ),BuscaDiferenca("A1_CNAE","PB3_CNAE",3     )})
	aAdd(aCampos,{"","A1_LOCCONS",BuscaNome("A1_LOCCONS"),"PB3_LOCCON",BuscaNome("PB3_LOCCON"),BuscaDiferenca("A1_LOCCONS","PB3_LOCCON",1),BuscaDiferenca("A1_LOCCONS","PB3_LOCCON",2),BuscaDiferenca("A1_LOCCONS","PB3_LOCCON",3)})
	aAdd(aCampos,{"","A1_CEINSS" ,BuscaNome("A1_CEINSS") ,"PB3_CEINSS",BuscaNome("PB3_CEINSS"),BuscaDiferenca("A1_CEINSS","PB3_CEINSS",1 ),BuscaDiferenca("A1_CEINSS","PB3_CEINSS",2 ),BuscaDiferenca("A1_CEINSS","PB3_CEINSS",3 )})
	aAdd(aCampos,{"","A1_FRETISS",BuscaNome("A1_FRETISS"),"PB3_FRETIS",BuscaNome("PB3_FRETIS"),BuscaDiferenca("A1_FRETISS","PB3_FRETIS",1),BuscaDiferenca("A1_FRETISS","PB3_FRETIS",2),BuscaDiferenca("A1_FRETISS","PB3_FRETIS",3)})
	aAdd(aCampos,{"","A1_TIMEKEE",BuscaNome("A1_TIMEKEE"),"PB3_TIMEKE",BuscaNome("PB3_TIMEKE"),BuscaDiferenca("A1_TIMEKEE","PB3_TIMEKE",1),BuscaDiferenca("A1_TIMEKEE","PB3_TIMEKE",2),BuscaDiferenca("A1_TIMEKEE","PB3_TIMEKE",3)})
	aAdd(aCampos,{"","A1_COMPLEM",BuscaNome("A1_COMPLEM"),"PB3_COMPLE",BuscaNome("PB3_COMPLE"),BuscaDiferenca("A1_COMPLEM","PB3_COMPLE",1),BuscaDiferenca("A1_COMPLEM","PB3_COMPLE",2),BuscaDiferenca("A1_COMPLEM","PB3_COMPLE",3)})
	aAdd(aCampos,{"","A1_FOMEZER",BuscaNome("A1_FOMEZER"),"PB3_FOMEZE",BuscaNome("PB3_FOMEZE"),BuscaDiferenca("A1_FOMEZER","PB3_FOMEZE",1),BuscaDiferenca("A1_FOMEZER","PB3_FOMEZE",2),BuscaDiferenca("A1_FOMEZER","PB3_FOMEZE",3)})
	aAdd(aCampos,{"","A1_TEL2"   ,BuscaNome("A1_TEL2")   ,"PB3_TEL2"  ,BuscaNome("PB3_TEL2")  ,BuscaDiferenca("A1_TEL2","PB3_TEL2",1     ),BuscaDiferenca("A1_TEL2","PB3_TEL2",2     ),BuscaDiferenca("A1_TEL2","PB3_TEL2",3     )})
	aAdd(aCampos,{"","A1_TEL3"   ,BuscaNome("A1_TEL3")   ,"PB3_TEL3"  ,BuscaNome("PB3_TEL3")  ,BuscaDiferenca("A1_TEL3","PB3_TEL3",1     ),BuscaDiferenca("A1_TEL3","PB3_TEL3",2     ),BuscaDiferenca("A1_TEL3","PB3_TEL3",3     )})
	aAdd(aCampos,{"","A1_TEL4"   ,BuscaNome("A1_TEL4")   ,"PB3_TEL4"  ,BuscaNome("PB3_TEL4")  ,BuscaDiferenca("A1_TEL4","PB3_TEL4",1     ),BuscaDiferenca("A1_TEL4","PB3_TEL4",2     ),BuscaDiferenca("A1_TEL4","PB3_TEL4",3     )})
	aAdd(aCampos,{"","A1_TEL5"   ,BuscaNome("A1_TEL5")   ,"PB3_TEL5"  ,BuscaNome("PB3_TEL5")  ,BuscaDiferenca("A1_TEL5","PB3_TEL5",1     ),BuscaDiferenca("A1_TEL5","PB3_TEL5",2     ),BuscaDiferenca("A1_TEL5","PB3_TEL5",3     )})
	aAdd(aCampos,{"","A1_TEL6"   ,BuscaNome("A1_TEL6")   ,"PB3_TEL6"  ,BuscaNome("PB3_TEL6")  ,BuscaDiferenca("A1_TEL6","PB3_TEL6",1     ),BuscaDiferenca("A1_TEL6","PB3_TEL6",2     ),BuscaDiferenca("A1_TEL6","PB3_TEL6",3     )})
	aAdd(aCampos,{"","A1_XLONGIT",BuscaNome("A1_XLONGIT"),"PB3_XLONGI",BuscaNome("PB3_XLONGI"),BuscaDiferenca("A1_XLONGIT","PB3_XLONGI",1),BuscaDiferenca("A1_XLONGIT","PB3_XLONGI",2),BuscaDiferenca("A1_XLONGIT","PB3_XLONGI",3)})
	aAdd(aCampos,{"","A1_XLATITU",BuscaNome("A1_XLATITU"),"PB3_XLATIT",BuscaNome("PB3_XLATIT"),BuscaDiferenca("A1_XLATITU","PB3_XLATIT",1),BuscaDiferenca("A1_XLATITU","PB3_XLATIT",2),BuscaDiferenca("A1_XLATITU","PB3_XLATIT",3)})
	aAdd(aCampos,{"","A1_CODRED" ,BuscaNome("A1_CODRED") ,"PB3_CODRED",BuscaNome("PB3_CODRED"),BuscaDiferenca("A1_CODRED","PB3_CODRED",1 ),BuscaDiferenca("A1_CODRED","PB3_CODRED",2 ),BuscaDiferenca("A1_CODRED","PB3_CODRED",3 )})
	aAdd(aCampos,{"","A1_TPREDE" ,BuscaNome("A1_TPREDE") ,"PB3_TPREDE",BuscaNome("PB3_TPREDE"),BuscaDiferenca("A1_TPREDE","PB3_TPREDE",1 ),BuscaDiferenca("A1_TPREDE","PB3_TPREDE",2 ),BuscaDiferenca("A1_TPREDE","PB3_TPREDE",3 )})
	aAdd(aCampos,{"","A1_NOMEASS",BuscaNome("A1_NOMEASS"),"PB3_NOMEAS",BuscaNome("PB3_NOMEAS"),BuscaDiferenca("A1_NOMEASS","PB3_NOMEAS",1),BuscaDiferenca("A1_NOMEASS","PB3_NOMEAS",2),BuscaDiferenca("A1_NOMEASS","PB3_NOMEAS",3)})
	aAdd(aCampos,{"","A1_XOBRPC" ,BuscaNome("A1_XOBRPC") ,"PB3_XOBRPC",BuscaNome("PB3_XOBRPC"),BuscaDiferenca("A1_XOBRPC","PB3_XOBRPC",1 ),BuscaDiferenca("A1_XOBRPC","PB3_XOBRPC",2 ),BuscaDiferenca("A1_XOBRPC","PB3_XOBRPC",3 )})
	aAdd(aCampos,{"","A1_EMAICO" ,BuscaNome("A1_EMAICO") ,"PB3_EMAICO",BuscaNome("PB3_EMAICO"),BuscaDiferenca("A1_EMAICO","PB3_EMAICO",1 ),BuscaDiferenca("A1_EMAICO","PB3_EMAICO",2 ),BuscaDiferenca("A1_EMAICO","PB3_EMAICO",3 )})
	aAdd(aCampos,{"","A1_XTELCON",BuscaNome("A1_XTELCON"),"PB3_XTELCO",BuscaNome("PB3_XTELCO"),BuscaDiferenca("A1_XTELCON","PB3_XTELCO",1),BuscaDiferenca("A1_XTELCON","PB3_XTELCO",2),BuscaDiferenca("A1_XTELCON","PB3_XTELCO",3)})
	aAdd(aCampos,{"","A1_EMLAVC" ,BuscaNome("A1_EMLAVC") ,"PB3_EMLAVC",BuscaNome("PB3_EMLAVC"),BuscaDiferenca("A1_EMLAVC","PB3_EMLAVC",1 ),BuscaDiferenca("A1_EMLAVC","PB3_EMLAVC",2 ),BuscaDiferenca("A1_EMLAVC","PB3_EMLAVC",3 )})
	aAdd(aCampos,{"","A1_XVEND2" ,BuscaNome("A1_XVEND2") ,"PB3_XVEND2",BuscaNome("PB3_XVEND2"),BuscaDiferenca("A1_XVEND2","PB3_XVEND2",1 ),BuscaDiferenca("A1_XVEND2","PB3_XVEND2",2 ),BuscaDiferenca("A1_XVEND2","PB3_XVEND2",3 )})
	aAdd(aCampos,{"","A1_XRISCO" ,BuscaNome("A1_XRISCO") ,"PB3_XRISCO",BuscaNome("PB3_XRISCO"),BuscaDiferenca("A1_XRISCO","PB3_XRISCO",1 ),BuscaDiferenca("A1_XRISCO","PB3_XRISCO",2 ),BuscaDiferenca("A1_XRISCO","PB3_XRISCO",3 )})
	aAdd(aCampos,{"","A1_XDTRISC",BuscaNome("A1_XDTRISC"),"PB3_XDTRIS",BuscaNome("PB3_XDTRIS"),BuscaDiferenca("A1_XDTRISC","PB3_XDTRIS",1),BuscaDiferenca("A1_XDTRISC","PB3_XDTRIS",2),BuscaDiferenca("A1_XDTRISC","PB3_XDTRIS",3)})
	aAdd(aCampos,{"","A1_HRINIM" ,BuscaNome("A1_HRINIM") ,"PB3_HRINIM",BuscaNome("PB3_HRINIM"),BuscaDiferenca("A1_HRINIM","PB3_HRINIM",1 ),BuscaDiferenca("A1_HRINIM","PB3_HRINIM",2 ),BuscaDiferenca("A1_HRINIM","PB3_HRINIM",3 )})
	aAdd(aCampos,{"","A1_HRFINM" ,BuscaNome("A1_HRFINM") ,"PB3_HRFINM",BuscaNome("PB3_HRFINM"),BuscaDiferenca("A1_HRFINM","PB3_HRFINM",1 ),BuscaDiferenca("A1_HRFINM","PB3_HRFINM",2 ),BuscaDiferenca("A1_HRFINM","PB3_HRFINM",3 )})
	aAdd(aCampos,{"","A1_HRINIT" ,BuscaNome("A1_HRINIT") ,"PB3_HRINIT",BuscaNome("PB3_HRINIT"),BuscaDiferenca("A1_HRINIT","PB3_HRINIT",1 ),BuscaDiferenca("A1_HRINIT","PB3_HRINIT",2 ),BuscaDiferenca("A1_HRINIT","PB3_HRINIT",3 )})
	aAdd(aCampos,{"","A1_HRFINT" ,BuscaNome("A1_HRFINT") ,"PB3_HRFINT",BuscaNome("PB3_HRFINT"),BuscaDiferenca("A1_HRFINT","PB3_HRFINT",1 ),BuscaDiferenca("A1_HRFINT","PB3_HRFINT",2 ),BuscaDiferenca("A1_HRFINT","PB3_HRFINT",3 )})
	aAdd(aCampos,{"","A1_XPROMOT",BuscaNome("A1_XPROMOT"),"PB3_PROMOT",BuscaNome("PB3_PROMOT"),BuscaDiferenca("A1_XPROMOT","PB3_PROMOT",1),BuscaDiferenca("A1_XPROMOT","PB3_PROMOT",2),BuscaDiferenca("A1_XPROMOT","PB3_PROMOT",3)})
	aAdd(aCampos,{"","A1_XEMCSF" ,BuscaNome("A1_XEMCSF") ,"PB3_EMCSF" ,BuscaNome("PB3_EMCSF") ,BuscaDiferenca("A1_XEMCSF","PB3_EMCSF",1  ),BuscaDiferenca("A1_XEMCSF","PB3_EMCSF",2  ),BuscaDiferenca("A1_XEMCSF","PB3_EMCSF",3  )})
	aAdd(aCampos,{"","A1_CODMUNE",BuscaNome("A1_CODMUNE"),"PB3_CODMUE",BuscaNome("PB3_CODMUE"),BuscaDiferenca("A1_CODMUNE","PB3_CODMUE",1),BuscaDiferenca("A1_CODMUNE","PB3_CODMUE",2),BuscaDiferenca("A1_CODMUNE","PB3_CODMUE",3)})
	aAdd(aCampos,{"","A1_SALPEDB",BuscaNome("A1_SALPEDB"),"PB3_SALPEB",BuscaNome("PB3_SALPEB"),BuscaDiferenca("A1_SALPEDB","PB3_SALPEB",1),BuscaDiferenca("A1_SALPEDB","PB3_SALPEB",2),BuscaDiferenca("A1_SALPEDB","PB3_SALPEB",3)})
	aAdd(aCampos,{"","A1_RAZENT" ,BuscaNome("A1_RAZENT") ,"PB3_NOMEEN",BuscaNome("PB3_NOMEEN"),BuscaDiferenca("A1_RAZENT","PB3_NOMEEN",1 ),BuscaDiferenca("A1_RAZENT","PB3_NOMEEN",2 ),BuscaDiferenca("A1_RAZENT","PB3_NOMEEN",3 )})
	aAdd(aCampos,{"","A1_REGIMST",BuscaNome("A1_REGIMST"),"PB3_REGIST",BuscaNome("PB3_REGIST"),BuscaDiferenca("A1_REGIMST","PB3_REGIST",1),BuscaDiferenca("A1_REGIMST","PB3_REGIST",2),BuscaDiferenca("A1_REGIMST","PB3_REGIST",3)})
	aAdd(aCampos,{"","A1_MSBLQL" ,BuscaNome("A1_MSBLQL")  ,"PB3_BLOQUE",BuscaNome("PB3_BLOQUE"),BuscaDiferenca("A1_MSBLQL","PB3_BLOQUE",1 ),BuscaDiferenca("A1_MSBLQL","PB3_BLOQUE",2 ),BuscaDiferenca("A1_MSBLQL","PB3_BLOQUE",3 )})
	aAdd(aCampos,{"","A1_XLOCEXP",BuscaNome("A1_XLOCEXP"),"PB3_XLOCPA" ,BuscaNome("PB3_XLOCPA"),BuscaDiferenca("A1_XLOCEXP","PB3_XLOCPA",1),BuscaDiferenca("A1_XLOCEXP","PB3_XLOCPA",2),BuscaDiferenca("A1_XLOCEXP","PB3_XLOCPA",3)})
	
	For nCont :=1 to Len(aCampos)
	
		TRC->(RecLock("TRC",.T.))
		
			 TRC->TMP_OK     := aCampos[nCont][1]
			 TRC->TMP_CPSA1  := aCampos[nCont][2]
			 TRC->TMP_DESSA1 := aCampos[nCont][3]
			 TRC->TMP_CPPB3  := aCampos[nCont][4]
			 TRC->TMP_DESPB3 := aCampos[nCont][5]
			 TRC->TMP_QTDINA := aCampos[nCont][6]
			 TRC->TMP_QTDATI := aCampos[nCont][7]
			 TRC->TMP_QTDDIF := aCampos[nCont][8]
			 
		TRC->(MsUnLock())
		
	NEXT nCont
	
	// *** FINAL CRIAR LINHAS TABELA TEMPORARIA *** //
	
Return({cArqs,cInd1,cInd2,cInd3,cInd4,cInd5})

User Function FIN070Marcar(cMarca,lMarcar)

    Local aArea  := TRC->( GetArea() )
    Local cMarca := oMark:Mark()

	U_ADINF009P('ADFIN070P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SA1')
    
    dbSelectArea("TRC")
    TRC->( dbGoTop() )
    While !TRC->( Eof() )
    
        RecLock( "TRC", .F. )
        	TRC->TMP_OK := cMarca
        MsUnlock()
        
        TRC->( dbSkip() )
        
    EndDo
 
 	oMark:Refresh(.T.)
    RestArea(aArea)
    
Return(Nil)

User Function FIN070Desmarcar(cMarca,lMarcar)

    Local aArea  := TRC->( GetArea() )

	U_ADINF009P('ADFIN070P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SA1')
 
    dbSelectArea("TRC")
    TRC->( dbGoTop() )
    While !TRC->( Eof() )
    
        RecLock( "TRC", .F. )
        	TRC->TMP_OK := ''
        MsUnlock()
        
        TRC->( dbSkip() )
        
    EndDo
 
 	oMark:Refresh(.T.)
    RestArea(aArea)
    
Return(Nil)

STATIC FUNCTION BuscaNome(cCampo)

	Local cRet  := ''
	Local aArea := GetArea()
	
	DBSELECTAREA("SX3")
	SX3->( dbSetOrder(2)) // Campo
	IF SX3->(dbSeek(cCampo, .T. ))
	
		cREt := SX3->X3_TITULO
	
	ENDIF
	
	RestArea(aArea)
	
RETURN(cRet)

STATIC FUNCTION BuscaDiferenca(cCampo1,cCampo2,nAtivo)

	Local nRet:= 0
	
    SqlCountDif(cCampo1,cCampo2,nAtivo)
    
    While TRD->(!EOF())
	                  
        nRet := TRD->COUNT
        
    	TRD->(dbSkip())
	ENDDO
	TRD->(dbCloseArea())
    
RETURN(nRet)

STATIC FUNCTION BuscaVendedor(cCampo1,cCampo2,nAtivo)

	Local nRet:= 0
	
    SqlCountVend(cCampo1,cCampo2,nAtivo)
    
    While TRF->(!EOF())
	                  
        nRet := TRF->COUNT
        
    	TRF->(dbSkip())
    	
	ENDDO
	TRF->(dbCloseArea())
    
RETURN(nRet)

STATIC FUNCTION BuscaEndereco(cCampo1,cCampo2,nAtivo)

	Local nRet:= 0
	
    SqlCountEnd(cCampo1,cCampo2,nAtivo)
    
    While TRG->(!EOF())
	                  
        nRet := TRG->COUNT
        
    	TRG->(dbSkip())
    	
	ENDDO
	TRG->(dbCloseArea())
    
RETURN(nRet)

STATIC FUNCTION BuscaTelefone(cCampo1,cCampo2,nAtivo)

	Local nRet:= 0
	
    SqlCountTel(cCampo1,cCampo2,nAtivo)
    
    While TRH->(!EOF())
	                  
        nRet := TRH->COUNT
        
    	TRH->(dbSkip())
    	
	ENDDO
	TRH->(dbCloseArea())
    
RETURN(nRet)

STATIC FUNCTION BuscaTotalGeral(cAtivo)

	Local cRet  := ''
	Local nCont := 0
	
    SqlTotalGeral(cAtivo)
    
    While TRI->(!EOF())
	                  
        nCont := nCont + 1
        
    	TRI->(dbSkip())
    	
	ENDDO
	TRI->(dbCloseArea())
	
	cRet := cValToChar(nCont) 
    
RETURN(cRet)

User FUNCTION FIN070EXCEL()

	PRIVATE oExcel      := FWMSEXCEL():New()
	PRIVATE cArquivo    := 'REL_PB3_SA1' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha   := "Conciliacao PB3_SA1"
    PRIVATE aLinhas     := {}

	U_ADINF009P('ADFIN070P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SA1')

	IF MSGYESNO("Deseja Gerar o Relatório Diferencial em Excel dos seguintes campos," + aCampos[Omark:Obrowse:NAT][2] + " e " + aCampos[Omark:Obrowse:NAT][4] + " ?")
	
		BEGIN SEQUENCE
			
			IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
			    Alert("Não Existe Excel Instalado")
	            BREAK
	        EndIF
			
			Cabec(aCampos[Omark:Obrowse:NAT][2],aCampos[Omark:Obrowse:NAT][4])             
			GeraExcel(aCampos[Omark:Obrowse:NAT][2],aCampos[Omark:Obrowse:NAT][4])
		          
			SalvaXml()
			CriaExcel()
		
		    MsgInfo("Arquivo Excel gerado!")    
		    
		END SEQUENCE 
		
	ENDIF
	
	oMark:Refresh(.T.)
	 
Return(Nil)

Static Function GeraExcel(cCAmpo1,cCampo2)

    Local nLinha  := 0
	Local nExcel  := 0
	Private cCab1 := cCAmpo1
	Private cCab2 := cCampo2
	
	IF ALLTRIM(cCAmpo1) == 'A1_VEND'
	
		SqlGeral2(cCAmpo1,cCampo2)
	
	ELSEIF ALLTRIM(cCAmpo1) == 'A1_END'   .OR. ;
	       ALLTRIM(cCAmpo1) == 'A1_ENDCOB' .OR. ;
	       ALLTRIM(cCAmpo1) == 'A1_ENDENT'
	
		SqlGeral3(cCAmpo1,cCampo2)
		
	ELSEIF ALLTRIM(cCAmpo1) == 'A1_TEL' 
	
		SqlGeral4(cCAmpo1,cCampo2)
	
	ELSE 
	
		SqlGeral(cCAmpo1,cCampo2)
	
	ENDIF 
	
	DBSELECTAREA("TRE")
	TRE->(DBGOTOP())
	WHILE TRE->(!EOF())
	
		nLinha  := nLinha + 1                                       
	
        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G 
	   	               "", ; // 08 H   
	   	               "", ; // 09 I  
	   	               "", ; // 10 J  
	   	               ""  ; // 11 K
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := TRE->A1_COD     //A
		aLinhas[nLinha][02] := TRE->PB3_CODSA1 //B
		aLinhas[nLinha][03] := TRE->A1_LOJA    //C
		aLinhas[nLinha][04] := TRE->PB3_LOJSA1 //D
		aLinhas[nLinha][05] := TRE->A1_NOME    //E
		aLinhas[nLinha][06] := TRE->PB3_NOME   //F
		aLinhas[nLinha][07] := TRE->A1_CGC     //G
		aLinhas[nLinha][08] := TRE->PB3_CGC    //H
		aLinhas[nLinha][09] := TRE->A1_MSBLQL  //I
		aLinhas[nLinha][10] := TRE->&(cCab1)   //J
		aLinhas[nLinha][11] := TRE->&(cCab2)   //K
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
		TRE->(dbSkip())    
	
	END //end do while TRB
	TRE->( DBCLOSEAREA() )   
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
   	oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
	                                 aLinhas[nExcel][02],; // 02 B  
	                                 aLinhas[nExcel][03],; // 03 C  
	                                 aLinhas[nExcel][04],; // 04 D  
	                                 aLinhas[nExcel][05],; // 05 E  
	                                 aLinhas[nExcel][06],; // 06 F  
	                                 aLinhas[nExcel][07],; // 07 G 
	                                 aLinhas[nExcel][08],; // 08 H  
	                                 aLinhas[nExcel][09],; // 09 I  
	                                 aLinhas[nExcel][10],; // 10 J  
	                                 aLinhas[nExcel][11] ; // 11 K
	                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile('C:\temp\' + cArquivo)

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open('C:\temp\' + cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function Cabec(cCAmpo1,cCampo2) 

	oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"A1_COD "          ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_CODSA1 "      ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"A1_LOJA "         ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_LOJSA1 "      ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"A1_NOME "         ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_NOME "        ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"A1_CGC "          ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_CGC "         ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"A1_MSBLQL "       ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,'"' + cCAmpo1 + '"',1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,'"' + cCampo2 + '"',1,1) // 11 K
	
RETURN(NIL)

User Function FIN070Processa()

	Local aArea    := GetArea()
    Local cMarca   := oMark:Mark()
    Local lInverte := oMark:IsInvert()
    Local nCont    := 0
    Local nOpcao   := 0
    Local oDlg     := NIL

	U_ADINF009P('ADFIN070P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SA1')
    
    DEFINE MSDIALOG oDlg FROM	18,1 TO 80,300 TITLE "FIN070Processa - Processar" PIXEL
	  
		@  1, 3 	TO 28, 140 OF oDlg  PIXEL
		
		If File("adoro.bmp")
		
			@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
			oBmp:lStretch:=.T.
			
		EndIf
		
		@ 05, 37 SAY "Processar Quais dados?" SIZE 90, 7 OF oDlg PIXEL 
		@ 012,036 BUTTON "Inativos" SIZE 022, 012 PIXEL OF oDlg ACTION (nOpcao := 1, oDlg:End())
		@ 012,072 BUTTON "Ativos"   SIZE 022, 012 PIXEL OF oDlg ACTION (nOpcao := 2, oDlg:End())
		@ 012,108 BUTTON "Ambos"    SIZE 022, 012 PIXEL OF oDlg ACTION (nOpcao := 3, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	
	BEGIN TRANSACTION
	
		IF nOpcao > 0 
     
		    //Percorrendo os registros da TRC
		    DBSELECTAREA("TRC")
		    TRC->(DbGoTop())
		    While !TRC->(EoF())
		    
		        //Caso esteja marcado processa as informacoes.
		        If oMark:IsMark(cMarca)
		        
		            IF TRC->TMP_QTDDIF > 0
		            
		            	nCont:= nCont + 1
		            
			            IF ALLTRIM(TRC->TMP_CPSA1) == 'A1_VEND'
				
			            	GravaLog(TRC->TMP_CPSA1,TRC->TMP_CPPB3)
							UpdCampoVend(TRC->TMP_CPSA1,TRC->TMP_CPPB3,nOpcao)
						
						ELSEIF ALLTRIM(TRC->TMP_CPSA1) == 'A1_END'   .OR. ;
						       ALLTRIM(TRC->TMP_CPSA1) == 'A1_ENDCOB' .OR. ;
						       ALLTRIM(TRC->TMP_CPSA1) == 'A1_ENDENT'
						
						    GravaLog(TRC->TMP_CPSA1,TRC->TMP_CPPB3)
							UpdCampoEnd(TRC->TMP_CPSA1,TRC->TMP_CPPB3,nOpcao)
							
						ELSEIF ALLTRIM(TRC->TMP_CPSA1) == 'A1_TEL' 
						
							GravaLog(TRC->TMP_CPSA1,TRC->TMP_CPPB3)
							UpdCampoTel(TRC->TMP_CPSA1,TRC->TMP_CPPB3,nOpcao)
						
						ELSE 
						
							GravaLog(TRC->TMP_CPSA1,TRC->TMP_CPPB3)
							UpdCampoNormal(TRC->TMP_CPSA1,TRC->TMP_CPPB3,nOpcao)
							
						ENDIF 
		                
			            IF nOpcao == 1
		            	
		            		//Limpando a marca
		            		RecLock('TRC', .F.)
		            		
				                TRC->TMP_OK     := ''
				                TRC->TMP_QTDINA := 0
				                TRC->TMP_QTDATI := TRC->TMP_QTDATI
				                TRC->TMP_QTDDIF := TRC->TMP_QTDATI + TRC->TMP_QTDINA 
				                
			                TRC->(MsUnlock())
			                
			            ELSEIF nOpcao == 2
		            	
		            		//Limpando a marca
		            		RecLock('TRC', .F.)
		            		
				                TRC->TMP_OK     := ''
				                TRC->TMP_QTDINA := TRC->TMP_QTDINA
				                TRC->TMP_QTDATI := 0
				                TRC->TMP_QTDDIF := TRC->TMP_QTDATI + TRC->TMP_QTDINA 
				                
			                TRC->(MsUnlock())
			                
			            ELSE        
			            
			            	//Limpando a marca
		            		RecLock('TRC', .F.)
		            		
				                TRC->TMP_OK     := ''
				                TRC->TMP_QTDINA := 0
				                TRC->TMP_QTDATI := 0
				                TRC->TMP_QTDDIF := 0 
				                
			                TRC->(MsUnlock())
		                
		                ENDIF
			        ENDIF 
		        ENDIF
		         
		        TRC->(DbSkip())
		        
		    ENDDO
	    ENDIF
    END TRANSACTION
     
    //Mostrando a mensagem de registros marcados
    MsgInfo('Foram Processados <b>' + cValToChar(nCont) + ' Campo(s)</b>.', "Atenção")
     
    //Restaurando área armazenada
    RestArea(aArea)
	
	oMark:Refresh(.T.)

RETURN(NIL)

User Function FIN070Total()

	Local cTotInativo := BuscaTotalGeral('1')
	Local cTotAtivo   := BuscaTotalGeral('2')
	Local cTotal      := CVALTOCHAR(VAL(cTotInativo) + VAL(cTotAtivo))
	Local oDlg        := NIL

	U_ADINF009P('ADFIN070P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SA1')

	DEFINE MSDIALOG oDlg FROM	18,1 TO 80,360 TITLE "FIN070Total - Total Divergência" PIXEL
	  
		@  1, 3 	TO 28, 317 OF oDlg  PIXEL
		
		If File("adoro.bmp")
		
			@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
			oBmp:lStretch:=.T.
			
		EndIf
		
		@ 05, 037 SAY "Total Inativo:" SIZE 30, 7 OF oDlg PIXEL 
		@ 12, 037 MSGET cTotInativo    SIZE	40, 9 OF oDlg PIXEL WHEN .F.
		@ 05, 084 SAY "Total Ativo:"   SIZE 30, 7 OF oDlg PIXEL 
		@ 12, 084 MSGET cTotAtivo      SIZE	40, 9 OF oDlg PIXEL WHEN .F.
		@ 05, 131 SAY "Total Geral:"   SIZE 30, 7 OF oDlg PIXEL 
		@ 12, 131 MSGET cTotal         SIZE	40, 9 OF oDlg PIXEL WHEN .F.
		//DEFINE SBUTTON FROM 12,86 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED
	
	oMark:Refresh(.T.)

RETURN(NIL)

STATIC FUNCTION GravaLog(cCAmpo1,cCampo2)

	Private cCab3 := cCAmpo1
	Private cCab4 := cCampo2

	IF ALLTRIM(cCAmpo1) == 'A1_VEND'
	
		SqlGeral2(cCAmpo1,cCampo2)
		
	ELSEIF ALLTRIM(cCAmpo1) == 'A1_END'   .OR. ;
	       ALLTRIM(cCAmpo1) == 'A1_ENDCOB' .OR. ;
	       ALLTRIM(cCAmpo1) == 'A1_ENDENT'
	
		SqlGeral3(cCAmpo1,cCampo2)
		
	ELSEIF ALLTRIM(cCAmpo1) == 'A1_TEL' 
	
		SqlGeral4(cCAmpo1,cCampo2)
	
	ELSE 
	
		SqlGeral(cCAmpo1,cCampo2)
		 
	ENDIF
	
	DBSELECTAREA("TRE")
	TRE->(DBGOTOP())
	WHILE TRE->(!EOF())
	
		RecLock("ZBE",.T.)
		
			ZBE->ZBE_FILIAL := ''
			ZBE->ZBE_DATA	:= Date()
			ZBE->ZBE_HORA	:= cValToChar(Time())
			ZBE->ZBE_USUARI	:= cUserName
			ZBE->ZBE_LOG	:= "A1_COD: " + TRE->A1_COD + " PB3_CODSA1: " + TRE->PB3_CODSA1 + " A1_LOJA: " + TRE->A1_LOJA + " PB3_LOJSA1: " + TRE->PB3_LOJSA1 + " Alteração campo " + cCAmpo2 + " de: " + TRE->&(cCab4) + " para: " + TRE->&(cCab3)   
			ZBE->ZBE_MODULO	:= "FINANCEIRO"
			ZBE->ZBE_ROTINA	:= "ADFIN070P"
			
		MsUnlock()
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
		TRE->(dbSkip())    
	
	END //end do while TRB
	TRE->( DBCLOSEAREA() )
			
RETURN(NIL)			

STATIC FUNCTION SqlCountDif(cCampo1,cCampo2,nAtivo)

	Local cQuery:= ''

	cQuery:= "SELECT COUNT(*) AS COUNT  " 
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	
	IF nAtivo == 1
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nAtivo == 2
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '2' "
	
	ENDIF
	
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND SA1." + cCampo1 + " <> PB3." + cCampo2 + " "
	
    TCQUERY cQuery new alias "TRD"
    
RETURN(NIL)

Static Function SqlGeral(cCampo1,cCampo2)

	Local cQuery:= ''

	cQuery:= "SELECT SA1.A1_COD,         " 
	cQuery+= "       PB3.PB3_CODSA1,     "
	cQuery+= "       SA1.A1_LOJA,        "
	cQuery+= "       PB3.PB3_LOJSA1,     " 
	cQuery+= "       SA1.A1_NOME,        "
	cQuery+= "       PB3.PB3_NOME,       "
	cQuery+= "       SA1.A1_CGC,         "
	cQuery+= "       PB3.PB3_CGC,        "
	cQuery+= "       SA1.A1_MSBLQL,      "
	cQuery+= "       SA1." + cCampo1 + ","
	cQuery+= "       PB3." + cCampo2 + " "
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND SA1." + cCampo1 + " <> PB3." + cCampo2 + " "
	
    TCQUERY cQuery new alias "TRE"
	
RETURN()

Static Function SqlGeral2(cCampo1,cCampo2)

	Local cQuery:= ''

	cQuery:= "SELECT SA1.A1_COD,         " 
	cQuery+= "       PB3.PB3_CODSA1,     "
	cQuery+= "       SA1.A1_LOJA,        "
	cQuery+= "       PB3.PB3_LOJSA1,     " 
	cQuery+= "       SA1.A1_NOME,        "
	cQuery+= "       PB3.PB3_NOME,       "
	cQuery+= "       SA1.A1_CGC,         "
	cQuery+= "       PB3.PB3_CGC,        "
	cQuery+= "       SA1.A1_MSBLQL,      "
	cQuery+= "       SA1." + cCampo1 + ","
	cQuery+= "       PB3." + cCampo2 + " "
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.PB3_VEND        <> '' "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	cQuery+= "        AND SA1.A1_VEND         <> '' "
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND SA1.A1_VEND         NOT IN (SELECT A3_COD FROM SA3010 WHERE A3_CODUSR = PB3.PB3_VEND AND D_E_L_E_T_ <> '*') "
	
    TCQUERY cQuery new alias "TRE"
	
RETURN()

Static Function SqlGeral3(cCampo1,cCampo2)

	Local cQuery:= ''

	cQuery:= "SELECT SA1.A1_COD,         " 
	cQuery+= "       PB3.PB3_CODSA1,     "
	cQuery+= "       SA1.A1_LOJA,        "
	cQuery+= "       PB3.PB3_LOJSA1,     " 
	cQuery+= "       SA1.A1_NOME,        "
	cQuery+= "       PB3.PB3_NOME,       "
	cQuery+= "       SA1.A1_CGC,         "
	cQuery+= "       PB3.PB3_CGC,        "
	cQuery+= "       SA1.A1_MSBLQL,      "
	cQuery+= "       CASE WHEN CHARINDEX(','," + cCampo1 + ") > 0 THEN SUBSTRING("+cCampo1+",1,CHARINDEX(',',"+cCampo1+") - 1)  ELSE "+cCampo1+" END AS " + cCampo1 + ","
	cQuery+= "       CASE WHEN CHARINDEX(',',"+cCampo2+" ) > 0 THEN SUBSTRING("+cCampo2+" ,1,CHARINDEX(',',"+cCampo2+") - 1)  ELSE "+cCampo2+"  END  AS " + cCampo2 + " "
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND CASE WHEN CHARINDEX(','," + cCampo1 + ") > 0 THEN SUBSTRING("+cCampo1+",1,CHARINDEX(',',"+cCampo1+") - 1)  ELSE "+cCampo1+" END     <> CASE WHEN CHARINDEX(',',"+cCampo2+" ) > 0 THEN SUBSTRING("+cCampo2+" ,1,CHARINDEX(',',"+cCampo2+") - 1)  ELSE "+cCampo2+"  END "
	
    TCQUERY cQuery new alias "TRE"
	
RETURN()

Static Function SqlGeral4(cCampo1,cCampo2)

	Local cQuery:= ''

	cQuery:= "SELECT SA1.A1_COD,         " 
	cQuery+= "       PB3.PB3_CODSA1,     "
	cQuery+= "       SA1.A1_LOJA,        "
	cQuery+= "       PB3.PB3_LOJSA1,     " 
	cQuery+= "       SA1.A1_NOME,        "
	cQuery+= "       PB3.PB3_NOME,       "
	cQuery+= "       SA1.A1_CGC,         "
	cQuery+= "       PB3.PB3_CGC,        "
	cQuery+= "       SA1.A1_MSBLQL,      "
	cQuery+= "       SA1.A1_DDD + SA1." + cCampo1 + " A1_TEL,"
	cQuery+= "       PB3." + cCampo2 + " "
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.PB3_VEND        <> '' "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND SA1.A1_DDD + SA1.A1_TEL  <> PB3.PB3_TEL "
	
    TCQUERY cQuery new alias "TRE"
	
RETURN()


STATIC FUNCTION SqlCountVend(cCampo1,cCampo2,nAtivo)

	Local cQuery:= ''

	cQuery:= "SELECT COUNT(*) AS COUNT  " 
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	cQuery+= "        AND SA1.A1_VEND         <> '' "
	
	IF nAtivo == 1
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nAtivo == 2
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '2' "
	
	ENDIF
	
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND SA1.A1_VEND         NOT IN (SELECT A3_COD FROM SA3010 WHERE A3_CODUSR = PB3.PB3_VEND AND D_E_L_E_T_ <> '*') "
	
    TCQUERY cQuery new alias "TRF"
    
RETURN(NIL)

STATIC FUNCTION SqlCountEnd(cCampo1,cCampo2,nAtivo)

	Local cQuery:= ''

	cQuery:= "SELECT COUNT(*) AS COUNT  " 
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	
	IF nAtivo == 1
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nAtivo == 2
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '2' "
	
	ENDIF
	
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND CASE WHEN CHARINDEX(','," + cCampo1 + ") > 0 THEN SUBSTRING("+cCampo1+",1,CHARINDEX(',',"+cCampo1+") - 1)  ELSE "+cCampo1+" END     <> CASE WHEN CHARINDEX(',',"+cCampo2+" ) > 0 THEN SUBSTRING("+cCampo2+" ,1,CHARINDEX(',',"+cCampo2+") - 1)  ELSE "+cCampo2+"  END "
	
    TCQUERY cQuery new alias "TRG"
    
RETURN(NIL)

STATIC FUNCTION SqlCountTel(cCampo1,cCampo2,nAtivo)

	Local cQuery:= ''

	cQuery:= "SELECT COUNT(*) AS COUNT  " 
	cQuery+= " FROM "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= "         ON PB3.PB3_FILIAL       = SA1.A1_FILIAL "
	cQuery+= "        AND PB3.PB3_CODSA1       = SA1.A1_COD "
	cQuery+= "        AND PB3.PB3_LOJSA1       = SA1.A1_LOJA "
	cQuery+= "        AND PB3.D_E_L_E_T_      <> '*' "
	cQuery+= "      WHERE SA1.A1_FILIAL        = '' "
	
	IF nAtivo == 1
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nAtivo == 2
	
		cQuery+= "        AND SA1.A1_MSBLQL      = '2' "
	
	ENDIF
	
	cQuery+= "        AND SA1.D_E_L_E_T_      <> '*' "
	cQuery+= "        AND SA1.A1_DDD + SA1.A1_TEL  <> PB3.PB3_TEL "
	
    TCQUERY cQuery new alias "TRH"
    
RETURN(NIL)

STATIC FUNCTION UpdCampoVend(cCampo1,cCampo2,nOpc)

	Local cUpd := ''
	Local cIntregou := ''

	cUpd:= "UPDATE PB3010 "
	cUpd+= "SET " + cCampo2 + "  = ISNULL((SELECT A3_CODUSR FROM "+RETSQLNAME("SA3") + " WHERE A3_COD = A1_VEND AND D_E_L_E_T_ <> '*'),'') FROM "+RETSQLNAME("PB3") + " "
	cUpd+= "INNER JOIN "+RETSQLNAME("SA1") + " "
	cUpd+= "  ON A1_FILIAL  = PB3_FILIAL "
	cUpd+= "  AND A1_COD    = PB3_CODSA1 "
	cUpd+= "  AND A1_LOJA   = PB3_LOJSA1 "
	cUpd+= "  AND A1_VEND  <> '' "
	
	IF nOpc == 1
	
		cUpd+= "        AND A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nOpc == 2
	
		cUpd+= "        AND A1_MSBLQL      = '2' "
	
	ENDIF
	
	cUpd+= "  AND "+RETSQLNAME("SA1") + ".D_E_L_E_T_ <> '*' "
	cUpd+= "  WHERE PB3_FILIAL  = '' "
	cUpd+= "  AND PB3_CODSA1   <> '' "
	cUpd+= "  AND PB3_LOJSA1   <> '' "
	cUpd+= "  AND PB3_VEND     <> '' "
	cUpd+= "  AND "+RETSQLNAME("PB3") + ".D_E_L_E_T_ <> '*'  "
	cUpd+= "  AND A1_VEND NOT IN (SELECT A3_COD FROM SA3010 WHERE A3_CODUSR = PB3_VEND AND D_E_L_E_T_ <> '*') "
		
	If (TCSQLExec(cUpd) < 0)
	
    	cIntregou += " TCSQLError() - UpdCampoVend: " 
    	conout("TCSQLError() " + TCSQLError())
    	
	EndIf        

RETURN(NIL)

STATIC FUNCTION UpdCampoEnd(cCampo1,cCampo2,nOpc)

	Local cUpd := ''
	Local cIntregou := ''

	cUpd:= "UPDATE PB3010 "
	cUpd+= "SET " + cCampo2 + " =  CASE WHEN CHARINDEX(','," + cCampo1 + ") > 0 THEN SUBSTRING(" + cCampo1 + ",1,CHARINDEX(','," + cCampo1 + ") - 1)  ELSE " + cCampo1 + " END FROM "+RETSQLNAME("PB3") + " "
	cUpd+= "INNER JOIN "+RETSQLNAME("SA1") + " "
	cUpd+= "  ON A1_FILIAL  = PB3_FILIAL "
	cUpd+= "  AND A1_COD    = PB3_CODSA1 "
	cUpd+= "  AND A1_LOJA   = PB3_LOJSA1 "
	cUpd+= "  AND A1_VEND  <> '' "
	
	IF nOpc == 1
	
		cUpd+= "        AND A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nOpc == 2
	
		cUpd+= "        AND A1_MSBLQL      = '2' "
	
	ENDIF
	
	cUpd+= "  AND "+RETSQLNAME("SA1") + ".D_E_L_E_T_ <> '*' "
	cUpd+= "  WHERE PB3_FILIAL  = '' "
	cUpd+= "  AND PB3_CODSA1   <> '' "
	cUpd+= "  AND PB3_LOJSA1   <> '' "
	cUpd+= "  AND PB3_VEND     <> '' "
	cUpd+= "  AND "+RETSQLNAME("PB3") + ".D_E_L_E_T_ <> '*'  "
	cUpd+= "  AND CASE WHEN CHARINDEX(','," + cCampo1 + ") > 0 THEN SUBSTRING(" + cCampo1 + ",1,CHARINDEX(','," + cCampo1 + ") - 1)  ELSE " + cCampo1 + " END     <> CASE WHEN CHARINDEX(','," + cCampo2 + " ) > 0 THEN SUBSTRING(" + cCampo2 + " ,1,CHARINDEX(','," + cCampo2 + ") - 1)  ELSE " + cCampo2 + "  END "
		
	If (TCSQLExec(cUpd) < 0)
	
    	cIntregou += " TCSQLError() - UpdCampoVend: " 
    	conout("TCSQLError() " + TCSQLError())
    	
	EndIf        

RETURN(NIL)

STATIC FUNCTION UpdCampoTel(cCampo1,cCampo2,nOpc)

	Local cUpd      := ''
	Local cIntregou := ''
	
	cUpd:= "UPDATE PB3010 "
	cUpd+= "SET " + cCampo2 + "  = SA1.A1_DDD + SA1." + cCampo1 + " FROM "+RETSQLNAME("PB3") + " "
	cUpd+= "INNER JOIN "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK)  "
	cUpd+= "        ON SA1.A1_FILIAL                       = PB3_FILIAL "
	cUpd+= "       AND SA1.A1_COD                          = PB3_CODSA1 "
	cUpd+= "       AND SA1.A1_LOJA                         = PB3_LOJSA1 "
	
	IF nOpc == 1
	
		cUpd+= "        AND SA1.A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nOpc == 2
	
		cUpd+= "        AND SA1.A1_MSBLQL      = '2' "
	
	ENDIF
	
	cUpd+= "       AND SA1.D_E_L_E_T_                     <> '*' "
	cUpd+= "     WHERE PB3_FILIAL                          = '' "
	cUpd+= "       AND PB3_CODSA1                         <> '' "
	cUpd+= "       AND PB3_LOJSA1                         <> '' "
	cUpd+= "       AND "+RETSQLNAME("PB3") + ".D_E_L_E_T_ <> '*'  "
	cUpd+= "       AND A1_DDD +" + cCampo2 + "            <> SA1." + cCampo1 + " "
		
	If (TCSQLExec(cUpd) < 0)
	
    	cIntregou += " TCSQLError() - UpdCampoVend: " 
    	conout("TCSQLError() " + TCSQLError())
    	
	EndIf

RETURN(NIL)

STATIC FUNCTION UpdCampoNormal(cCampo1,cCampo2,nOpc)

	Local cUpd      := ''
	Local cIntregou := ''
	
	cUpd:= "UPDATE PB3010 "
	cUpd+= "SET " + cCampo2 + "  = SA1." + cCampo1 + " FROM "+RETSQLNAME("PB3") + " "
	cUpd+= "INNER JOIN "+RETSQLNAME("SA1") + " SA1 WITH(NOLOCK)  "
	cUpd+= "        ON SA1.A1_FILIAL                       = PB3_FILIAL "
	cUpd+= "       AND SA1.A1_COD                          = PB3_CODSA1 "
	cUpd+= "       AND SA1.A1_LOJA                         = PB3_LOJSA1 "
	
	IF nOpc == 1
	
		cUpd+= "        AND SA1.A1_MSBLQL      = '1' "
	
	ENDIF
	 
	IF nOpc == 2
	
		cUpd+= "        AND SA1.A1_MSBLQL      = '2' "
	
	ENDIF
	
	cUpd+= "       AND SA1.D_E_L_E_T_                     <> '*' "
	cUpd+= "     WHERE PB3_FILIAL                          = '' "
	cUpd+= "       AND PB3_CODSA1                         <> '' "
	cUpd+= "       AND PB3_LOJSA1                         <> '' "
	cUpd+= "       AND "+RETSQLNAME("PB3") + ".D_E_L_E_T_ <> '*'  "
	cUpd+= "       AND " + cCampo2 + "                    <> SA1." + cCampo1 + " "
		
	If (TCSQLExec(cUpd) < 0)
	
    	cIntregou += " TCSQLError() - UpdCampoVend: " 
    	conout("TCSQLError() " + TCSQLError())
    	
	EndIf

RETURN(NIL)

Static Function SqlTotalGeral(cAtivo)

	BeginSQL Alias "TRI"
			%NoPARSER%  
			SELECT SA1.A1_COD,
			       PB3.PB3_CODSA1,
			       SA1.A1_LOJA,
				   PB3.PB3_LOJSA1,
			       SA1.A1_NOME,
			       PB3.PB3_NOME,
				   SA1.A1_NREDUZ,
				   PB3.PB3_NREDUZ,
				   SA1.A1_PESSOA,
				   PB3.PB3_PESSOA,
			       SA1.A1_VEND,
				   PB3.PB3_VEND,
			       SA1.A1_TIPO,
				   PB3.PB3_TIPO,
			       SA1.A1_CEP,
				   PB3.PB3_CEP,
				   SA1.A1_END,
				   PB3.PB3_END,
				   SA1.A1_EST,
				   PB3.PB3_EST,
				   SA1.A1_COD_MUN,
				   PB3.PB3_COD_MU,
				   SA1.A1_NATUREZ,
				   PB3.PB3_NATURE,
				   SA1.A1_MUN,
				   PB3.PB3_MUN,
				   SA1.A1_BAIRRO,
				   PB3.PB3_BAIRRO,
			       SA1.A1_ATIVIDA,
				   PB3.PB3_ATIVID,
				   SA1.A1_TEL,
				   PB3.PB3_TEL,
			       SA1.A1_TELEX,
				   PB3.PB3_TELEX,
			       SA1.A1_FAX,
				   PB3.PB3_FAX,
			       SA1.A1_CONTATO,
				   PB3.PB3_CONTAT,
			       SA1.A1_ENDCOB,
				   PB3.PB3_ENDCOB,
			       SA1.A1_BAIRROC,
				   PB3.PB3_BAIRCB,
			       SA1.A1_CEPC,
				   PB3.PB3_CEPCOB,
			       SA1.A1_MUNC,
				   PB3.PB3_CIDACO,
				   SA1.A1_ESTC,
				   PB3.PB3_UFCOB,
			       SA1.A1_CGC,
				   PB3.PB3_CGC,
				   SA1.A1_INSCR,
				   PB3.PB3_INSCR,
			       SA1.A1_INSCRM,
				   PB3.PB3_INSCRM,
			       SA1.A1_COMIS,
				   PB3.PB3_COMIS,
			       SA1.A1_REGIAO,
				   PB3.PB3_REGIAO,
			       SA1.A1_CONTA,
				   PB3.PB3_CONTA,
			       SA1.A1_BCO1,
				   PB3.PB3_BCO1,
			       SA1.A1_BCO2,
				   PB3.PB3_BCO2,
			       SA1.A1_BCO3,
				   PB3.PB3_BCO3,
			       SA1.A1_BCO4,
				   PB3.PB3_BCO4,
			       SA1.A1_BCO5,
				   PB3.PB3_BCO5,
			       SA1.A1_TRANSP,
				   PB3.PB3_TRANSP,
			       SA1.A1_TPFRET,
				   PB3.PB3_TPFRET,
			       SA1.A1_COND,
				   PB3.PB3_COND,
			       SA1.A1_CLASSE,
				   PB3.PB3_CLASSE,
			       SA1.A1_RISCO,
				   PB3.PB3_RISCO,
			       SA1.A1_LC, 
				   PB3.PB3_LIMAPR,
			       SA1.A1_VENCLC,
				   PB3.PB3_VENCLC,
			       SA1.A1_MCOMPRA,
				   PB3.PB3_MCOMPR,
			       SA1.A1_METR,
				   PB3.PB3_METR,
			       SA1.A1_MSALDO,
				   PB3.PB3_MSALDO,
			       SA1.A1_NROCOM,
				   PB3.PB3_NROCOM,
			       SA1.A1_PRICOM,
				   PB3.PB3_PRICOM,
			       SA1.A1_ULTCOM,
				   PB3.PB3_ULTCOM,
			       SA1.A1_TEMVIS,
				   PB3.PB3_TEMVIS,
				   SA1.A1_ULTVIS,
				   PB3.PB3_ULTVIS,
				   SA1.A1_MENSAGE,
				   PB3.PB3_MENSAG,
				   SA1.A1_SALPEDL,
				   PB3.PB3_SALPEL,
				   SA1.A1_SUFRAMA,
				   PB3.PB3_SUFRAM,
			       SA1.A1_TRANSF,
				   PB3.PB3_TRANSF,
				   SA1.A1_ATR,
				   PB3_ATR,
			       SA1.A1_VACUM,
				   PB3.PB3_VACUM,
			       SA1.A1_SALPED,
				   PB3.PB3_SALPED,
			       SA1.A1_TITPROT,
				   PB3.PB3_TITPRO,
			       SA1.A1_DTULTIT,
				   PB3.PB3_DTULTI,
				   SA1.A1_CHQDEVO,
				   PB3.PB3_CHQDEV,
				   SA1.A1_DTULCHQ,
				   PB3.PB3_DTULCH,
			       SA1.A1_MATR,
				   PB3.PB3_MATR,
			       SA1.A1_MAIDUPL,
				   PB3.PB3_MAIDUP,
			       SA1.A1_TABELA,
				   PB3.PB3_TABELA,
			       SA1.A1_INCISS,
				   PB3.PB3_INCISS,
			       SA1.A1_AGREG,
				   PB3.PB3_AGREG,
			       SA1.A1_SALDUPM,
				   PB3.PB3_SALDUF,
			       SA1.A1_PAGATR,
				   PB3.PB3_PAGATR,
				   SA1.A1_CARGO1,
				   PB3.PB3_CARGO1,
			       SA1.A1_SUPER,
				   PB3.PB3_SUPER,
			       SA1.A1_RTEC,
				   PB3.PB3_RTEC,
			       SA1.A1_ALIQIR,
				   PB3.PB3_ALIQIR,
			       SA1.A1_OBSERV,
				   PB3.PB3_OBSERV,
			       SA1.A1_CALCSUF,
				   PB3.PB3_CALCSU,
			       SA1.A1_RG,
				   PB3.PB3_RG,
			       SA1.A1_DTNASC,
				   PB3.PB3_DTNASC,
			       SA1.A1_CLIFAT,
				   PB3.PB3_CLIFAT,
			       SA1.A1_GRPTRIB,
				   PB3.PB3_GRPTRI,
			       SA1.A1_ENDENT,
				   PB3.PB3_ENDENT,
			       SA1.A1_BAIRROE,
				   PB3.PB3_BAIREN,
			       SA1.A1_CEPE,
				   PB3.PB3_CEPENT,
			       SA1.A1_MUNE,
				   PB3.PB3_CIDENT,
			       SA1.A1_ESTE,
				   PB3.PB3_UFENT,
			       SA1.A1_CGCENT,
				   PB3.PB3_CPFENT,
			       SA1.A1_INSENT,
				   PB3.PB3_INSCEN,
				   SA1.A1_SATIV1,
				   PB3.PB3_SEGTO,
			       SA1.A1_SATIV2,
				   PB3.PB3_SUBSEG,
				   SA1.A1_EMAIL,
				   PB3.PB3_EMAIL,
			       SA1.A1_CODMUN,
				   PB3.PB3_CODMUN,
			       SA1.A1_CODPAIS,
				   PB3.PB3_CODPAI,
			       SA1.A1_HPAGE,
				   PB3.PB3_HPAGE,
			       SA1.A1_CODHIST,
				   PB3.PB3_CODHIS,
			       SA1.A1_PAIS,
				   PB3.PB3_PAIS,
			       SA1.A1_TMPSTD,
				   PB3.PB3_TMPSTD,
			       SA1.A1_RECINSS,
				   PB3.PB3_RECINS,
			       SA1.A1_NOMSOC1,
				   PB3.PB3_NOMSO1,
			       SA1.A1_CPFSOC1,
				   PB3.PB3_CGCSO3,
			       SA1.A1_NOMSOC2,
				   PB3.PB3_NOMSO2,
			       SA1.A1_CPFSOC2,
				   PB3.PB3_CGCSO2,
			       SA1.A1_NOMSOC3,
				   PB3.PB3_NOMSO3,
			       SA1.A1_DEST_1,
				   PB3.PB3_DEST_1,
			       SA1.A1_DEST_2,
				   PB3.PB3_DEST_2,
			       SA1.A1_DEST_3,
				   PB3.PB3_DEST_3,
			       SA1.A1_CODAGE,
				   PB3.PB3_CODAGE,
			       SA1.A1_CLASVEN,
				   PB3.PB3_CLASVE,
			       SA1.A1_CODMARC,
				   PB3.PB3_CODMAR,
			       SA1.A1_COMAGE,
				   PB3.PB3_COMAGE,
			       SA1.A1_CXPOSTA,
				   PB3.PB3_CXPOST,
			       SA1.A1_CONDPAG,
				   PB3.PB3_CONDPA,
			       SA1.A1_DIASPAG,
				   PB3.PB3_DIASPA,
			       SA1.A1_ESTADO,
				   PB3.PB3_ESTADO,
			       SA1.A1_SUBCOD,
				   PB3.PB3_SUBCOD,
			       SA1.A1_FORMVIS,
				   PB3.PB3_FORMVI,
			       SA1.A1_RECCOFI,
				   PB3.PB3_RECCOF,
			       SA1.A1_RECCSLL,
				   PB3.PB3_RECCSL,
			       SA1.A1_RECPIS,
				   PB3.PB3_RECPIS,
			       SA1.A1_TIPCLI,
				   PB3.PB3_TIPCLI,
			       SA1.A1_TMPVIS,
				   PB3.PB3_TMPVIS,
			       SA1.A1_IMPENT,
				   PB3.PB3_IMPEND,
			       SA1.A1_NRE,
				   PB3.PB3_REGESP,
			       SA1.A1_DDD,
				   PB3.PB3_DDD,
			       SA1.A1_DDI,
				   PB3.PB3_DDI,
			       SA1.A1_PFISICA,
				   PB3.PB3_PFISIC,
			       SA1.A1_LCFIN,
				   PB3.PB3_LCFIN,
			       SA1.A1_MOEDALC,
				   PB3.PB3_MOEDAL,
			       SA1.A1_RECISS,
				   PB3.PB3_RECISS,
			       SA1.A1_TIPPER,
				   PB3.PB3_TIPPER,
				   SA1.A1_SALFIN,
				   PB3.PB3_SALFIN,
			       SA1.A1_B2B,
				   PB3.PB3_B2B,
			       SA1.A1_PRIOR,
				   PB3.PB3_PRIOR,
			       SA1.A1_GRPVEN,
				   PB3.PB3_GRPVEN,
			       SA1.A1_CLICNV,
				   PB3.PB3_CLICNV,
			       SA1.A1_SITUA,
				   PB3.PB3_SITUA,
			       SA1.A1_ABATIMP,
				   PB3.PB3_ABATIM,
			       SA1.A1_REGCOB,
				   PB3.PB3_REGCOB,
			       SA1.A1_TPESSOA,
				   PB3.PB3_TPESSO,
			       SA1.A1_CODLOC,
				   PB3.PB3_CODLOC,
				   SA1.A1_CONTAB,
				   PB3.PB3_CONTAB,
			       SA1.A1_INSCRUR,
				   PB3.PB3_INSCRU,
			       SA1.A1_NUMRA,
				   PB3.PB3_NUMRA,
			       SA1.A1_CDRDES,
				   PB3.PB3_CDRDES,
			       SA1.A1_FILDEB,
				   PB3.PB3_FILDEB,
			       SA1.A1_CODFOR,
				   PB3.PB3_CODFOR,
			       SA1.A1_ABICS,
				   PB3.PB3_ABICS,
			       SA1.A1_BLEMAIL,
				   PB3.PB3_BLEMAI,
			       SA1.A1_TIPOCLI,
				   PB3.PB3_TIPOCL,
			       SA1.A1_SIMPNAC,
				   PB3.PB3_SIMPLE,
			       SA1.A1_RECIRRF,
				   PB3.PB3_RECIRR,
			       SA1.A1_TPISSRS,
				   PB3.PB3_TPISSR,
			       SA1.A1_CTARE,
				   PB3.PB3_CTARE, 
			       SA1.A1_RECFET,
				   PB3.PB3_RECFET,
			       SA1.A1_CONTRIB,
				   PB3.PB3_CONTRI,
			       SA1.A1_VINCULO,
				   PB3.PB3_VINCUL,
			       SA1.A1_DTINIV,
				   PB3.PB3_DTINIV, 
			       SA1.A1_DTFIMV,
				   PB3.PB3_DTFIMV, 
				   SA1.A1_ZZDESCB,
				   PB3.PB3_DESC,
			       SA1.A1_CBO,
				   PB3.PB3_CBO,
			       SA1.A1_CNAE,
				   PB3.PB3_CNAE,
			       SA1.A1_LOCCONS,
				   PB3.PB3_LOCCON,
			       SA1.A1_CEINSS,
				   PB3.PB3_CEINSS,
			       SA1.A1_FRETISS,
				   PB3.PB3_FRETIS,
			       SA1.A1_TIMEKEE,
				   PB3.PB3_TIMEKE,
			       SA1.A1_COMPLEM,
				   PB3.PB3_COMPLE,
			       SA1.A1_FOMEZER,
				   PB3.PB3_FOMEZE,
				   SA1.A1_TEL2,
				   PB3.PB3_TEL2,
				   SA1.A1_TEL3,
				   PB3.PB3_TEL3,
				   SA1.A1_TEL4,
				   PB3.PB3_TEL4,
			       SA1.A1_TEL5,
				   PB3.PB3_TEL5,
			       SA1.A1_TEL6,
				   PB3.PB3_TEL6,
				   SA1.A1_XLONGIT,
				   PB3.PB3_XLONGI,
			       SA1.A1_XLATITU,
				   PB3.PB3_XLATIT,
				   SA1.A1_CODRED,
				   PB3.PB3_CODRED,
			       SA1.A1_TPREDE,
				   PB3.PB3_TPREDE,
			       SA1.A1_NOMEASS,
				   PB3.PB3_NOMEAS,
			       SA1.A1_XOBRPC,
				   PB3.PB3_XOBRPC,
			       SA1.A1_EMAICO,
				   PB3.PB3_EMAICO,
			       SA1.A1_XTELCON,
				   PB3.PB3_XTELCO,
				   SA1.A1_EMLAVC,
				   PB3.PB3_EMLAVC,
			       SA1.A1_XVEND2,
				   PB3.PB3_XVEND2,
			       SA1.A1_XRISCO,
				   PB3.PB3_XRISCO,
			       SA1.A1_XDTRISC,
				   PB3.PB3_XDTRIS,
				   SA1.A1_HRINIM,
				   PB3.PB3_HRINIM,
			       SA1.A1_HRFINM,
				   PB3.PB3_HRFINM,
			       SA1.A1_HRINIT,
				   PB3.PB3_HRINIT,
			       SA1.A1_HRFINT,
				   PB3.PB3_HRFINT,
				   SA1.A1_XPROMOT,
				   PB3.PB3_PROMOT,
				   SA1.A1_XEMCSF,
				   PB3.PB3_EMCSF,
				   SA1.A1_CODMUNE,
				   PB3.PB3_CODMUE,
				   SA1.A1_SALPEDB,
				   PB3.PB3_SALPEB,
				   SA1.A1_RAZENT,
				   PB3.PB3_NOMEEN,
				   SA1.A1_REGIMST,
				   PB3.PB3_REGIST,
				   SA1.A1_MSBLQL,
				   PB3.PB3_BLOQUE 
			  FROM %TABLE:SA1% SA1 WITH(NOLOCK)
			INNER JOIN %TABLE:PB3% PB3 WITH(NOLOCK)
			        ON PB3.PB3_FILIAL = SA1.A1_FILIAL
				   AND PB3.PB3_CODSA1 = SA1.A1_COD
			       AND PB3.PB3_LOJSA1 = SA1.A1_LOJA
				   AND PB3.D_E_L_E_T_  <> '*'
			     WHERE SA1.A1_FILIAL = ''
			       AND SA1.A1_MSBLQL = %EXP:cAtivo%
				   AND SA1.D_E_L_E_T_  <> '*'
				   AND (
				        SA1.A1_NOME    <> PB3.PB3_NOME
				    OR  SA1.A1_NREDUZ  <> PB3.PB3_NREDUZ
					OR  SA1.A1_PESSOA  <> PB3.PB3_PESSOA
					OR	SA1.A1_VEND    NOT IN (SELECT A3_COD FROM SA3010 WHERE A3_CODUSR = PB3.PB3_VEND AND D_E_L_E_T_ <> '*')
					OR  SA1.A1_TIPO    <> PB3.PB3_TIPO
					OR  SA1.A1_CEP     <> PB3.PB3_CEP
			        OR  CASE WHEN CHARINDEX(',',SA1.A1_END) > 0 THEN SUBSTRING(SA1.A1_END,1,CHARINDEX(',',SA1.A1_END) - 1)  ELSE SA1.A1_END END     <> CASE WHEN CHARINDEX(',',PB3.PB3_END ) > 0 THEN SUBSTRING(PB3.PB3_END ,1,CHARINDEX(',',PB3.PB3_END) - 1)  ELSE PB3.PB3_END  END
					OR  SA1.A1_EST     <> PB3.PB3_EST
					OR  SA1.A1_COD_MUN <> PB3.PB3_COD_MU
			        OR  SA1.A1_NATUREZ <> PB3.PB3_NATURE
					OR  SA1.A1_MUN     <> PB3.PB3_MUN
					OR  SA1.A1_BAIRRO  <> PB3.PB3_BAIRRO
					OR  SA1.A1_ATIVIDA <> PB3.PB3_ATIVID
					OR 	SA1.A1_DDD + SA1.A1_TEL  <> PB3.PB3_TEL
					OR  SA1.A1_TELEX   <> PB3.PB3_TELEX  
					OR  SA1.A1_FAX     <> PB3.PB3_FAX
			        OR  SA1.A1_CONTATO <> PB3.PB3_CONTAT
					OR  CASE WHEN CHARINDEX(',',SA1.A1_ENDCOB) > 0 THEN SUBSTRING(SA1.A1_ENDCOB,1,CHARINDEX(',',SA1.A1_ENDCOB) - 1)  ELSE SA1.A1_ENDCOB END     <> CASE WHEN CHARINDEX(',',PB3.PB3_ENDCOB ) > 0 THEN SUBSTRING(PB3.PB3_ENDCOB ,1,CHARINDEX(',',PB3.PB3_ENDCOB) - 1)  ELSE PB3.PB3_ENDCOB  END
					OR  SA1.A1_BAIRROC <> PB3.PB3_BAIRCB
					OR  SA1.A1_CEPC    <> PB3.PB3_CEPCOB
			        OR  SA1.A1_MUNC    <> PB3.PB3_CIDACO
					OR  SA1.A1_ESTC    <> PB3.PB3_UFCOB
					OR  SA1.A1_CGC     <> PB3.PB3_CGC
					OR  SA1.A1_INSCR   <> PB3.PB3_INSCR
					OR  SA1.A1_INSCRM  <> PB3.PB3_INSCRM
					OR  SA1.A1_COMIS   <> PB3.PB3_COMIS
					OR  SA1.A1_REGIAO  <> PB3.PB3_REGIAO
					OR  SA1.A1_CONTA   <> PB3.PB3_CONTA
					OR  SA1.A1_BCO1    <> PB3.PB3_BCO1
			        OR  SA1.A1_BCO2    <> PB3.PB3_BCO2
			        OR  SA1.A1_BCO3    <> PB3.PB3_BCO3
			        OR  SA1.A1_BCO4    <> PB3.PB3_BCO4
			        OR  SA1.A1_BCO5    <> PB3.PB3_BCO5
					OR  SA1.A1_TRANSP  <> PB3.PB3_TRANSP
			        OR  SA1.A1_TPFRET  <> PB3.PB3_TPFRET
			        OR  SA1.A1_COND    <> PB3.PB3_COND
			        OR  SA1.A1_CLASSE  <> PB3.PB3_CLASSE
			        OR  SA1.A1_RISCO   <> PB3.PB3_RISCO
			        OR  SA1.A1_LC      <> PB3.PB3_LIMAPR
					OR  SA1.A1_VENCLC  <> PB3.PB3_VENCLC
			        OR  SA1.A1_MCOMPRA <> PB3.PB3_MCOMPR
					OR  SA1.A1_METR    <> PB3.PB3_METR
					OR  SA1.A1_MSALDO  <> PB3.PB3_MSALDO
					OR  SA1.A1_NROCOM  <> PB3.PB3_NROCOM
					OR  SA1.A1_PRICOM  <> PB3.PB3_PRICOM
					OR  SA1.A1_ULTCOM  <> PB3.PB3_ULTCOM
					OR  SA1.A1_TEMVIS  <> PB3.PB3_TEMVIS
			        OR  SA1.A1_ULTVIS  <> PB3.PB3_ULTVIS
					OR  SA1.A1_MENSAGE <> PB3.PB3_MENSAG
					OR  SA1.A1_NROPAG  <> PB3.PB3_NROPAG
					OR  SA1.A1_SALDUP  <> PB3.PB3_SALDUP
					OR  SA1.A1_SALPEDL <> PB3.PB3_SALPEL
					OR  SA1.A1_SUFRAMA <> PB3.PB3_SUFRAM
			        OR  SA1.A1_TRANSF  <> PB3.PB3_TRANSF
					OR  SA1.A1_ATR     <> PB3.PB3_ATR
					OR  SA1.A1_VACUM   <> PB3.PB3_VACUM
					OR  SA1.A1_SALPED  <> PB3.PB3_SALPED
					OR  SA1.A1_TITPROT <> PB3.PB3_TITPRO
					OR  SA1.A1_DTULTIT <> PB3.PB3_DTULTI
					OR  SA1.A1_CHQDEVO <> PB3.PB3_CHQDEV
			        OR  SA1.A1_DTULCHQ <> PB3.PB3_DTULCH
			        OR  SA1.A1_MATR    <> PB3.PB3_MATR
			        OR  SA1.A1_MAIDUPL <> PB3.PB3_MAIDUP
			        OR  SA1.A1_TABELA  <> PB3.PB3_TABELA
			        OR  SA1.A1_INCISS  <> PB3.PB3_INCISS
			        OR  SA1.A1_AGREG   <> PB3.PB3_AGREG
			        OR  SA1.A1_SALDUPM <> PB3.PB3_SALDUF
			        OR  SA1.A1_PAGATR  <> PB3.PB3_PAGATR
				    OR  SA1.A1_CARGO1  <> PB3.PB3_CARGO1
			        OR  SA1.A1_SUPER   <> PB3.PB3_SUPER
			        OR  SA1.A1_RTEC    <> PB3.PB3_RTEC
			        OR  SA1.A1_ALIQIR  <> PB3.PB3_ALIQIR
			        OR  SA1.A1_OBSERV  <> PB3.PB3_OBSERV
			        OR  SA1.A1_CALCSUF <> PB3.PB3_CALCSU
			        OR  SA1.A1_RG      <> PB3.PB3_RG
			        OR  SA1.A1_DTNASC  <> PB3.PB3_DTNASC
			        OR  SA1.A1_CLIFAT  <> PB3.PB3_CLIFAT
			        OR  SA1.A1_GRPTRIB <> PB3.PB3_GRPTRI
			        OR  CASE WHEN CHARINDEX(',',SA1.A1_ENDENT ) > 0 THEN SUBSTRING(SA1.A1_ENDENT ,1,CHARINDEX(',',SA1.A1_ENDENT ) - 1)  ELSE SA1.A1_ENDENT  END  <> CASE WHEN CHARINDEX(',',PB3.PB3_ENDENT ) > 0 THEN SUBSTRING(PB3.PB3_ENDENT ,1,CHARINDEX(',',PB3.PB3_ENDENT) - 1)  ELSE PB3.PB3_ENDENT  END
			        OR  SA1.A1_BAIRROE <> PB3.PB3_BAIREN
			        OR  SA1.A1_CEPE    <> PB3.PB3_CEPENT
			        OR  SA1.A1_MUNE    <> PB3.PB3_CIDENT
			        OR  SA1.A1_ESTE    <> PB3.PB3_UFENT
			        OR  SA1.A1_CGCENT  <> PB3.PB3_CPFENT
			        OR  SA1.A1_INSENT  <> PB3.PB3_INSCEN
			        OR  SA1.A1_SATIV1  <> PB3.PB3_SEGTO
			        OR  SA1.A1_SATIV2  <> PB3.PB3_SUBSEG
			        OR  SA1.A1_EMAIL   <> PB3.PB3_EMAIL
			        OR  SA1.A1_CODMUN  <> PB3.PB3_CODMUN
			        OR  SA1.A1_CODPAIS <> PB3.PB3_CODPAI
			        OR  SA1.A1_HPAGE   <> PB3.PB3_HPAGE
			        OR  SA1.A1_CODHIST <> PB3.PB3_CODHIS
			        OR  SA1.A1_PAIS    <> PB3.PB3_PAIS
			        OR  SA1.A1_TMPSTD  <> PB3.PB3_TMPSTD
			        OR  SA1.A1_RECINSS <> PB3.PB3_RECINS
			        OR  SA1.A1_NOMSOC1 <> PB3.PB3_NOMSO1
			        OR  SA1.A1_CPFSOC1 <> PB3.PB3_CGCSO3
			        OR  SA1.A1_NOMSOC2 <> PB3.PB3_NOMSO2
			        OR  SA1.A1_CPFSOC2 <> PB3.PB3_CGCSO2
			        OR  SA1.A1_NOMSOC3 <> PB3.PB3_NOMSO3
			        OR  SA1.A1_DEST_1  <> PB3.PB3_DEST_1
			        OR  SA1.A1_DEST_2  <> PB3.PB3_DEST_2
			        OR  SA1.A1_DEST_3  <> PB3.PB3_DEST_3
			        OR  SA1.A1_CODAGE  <> PB3.PB3_CODAGE
			        OR  SA1.A1_CLASVEN <> PB3.PB3_CLASVE
			        OR  SA1.A1_CODMARC <> PB3.PB3_CODMAR
			        OR  SA1.A1_COMAGE  <> PB3.PB3_COMAGE
			        OR  SA1.A1_CXPOSTA <> PB3.PB3_CXPOST
			        OR  SA1.A1_CONDPAG <> PB3.PB3_CONDPA
			        OR  SA1.A1_DIASPAG <> PB3.PB3_DIASPA
			        OR  SA1.A1_ESTADO  <> PB3.PB3_ESTADO
			        OR  SA1.A1_SUBCOD  <> PB3.PB3_SUBCOD
			        OR  SA1.A1_FORMVIS <> PB3.PB3_FORMVI
			        OR  SA1.A1_RECCOFI <> PB3.PB3_RECCOF
			        OR  SA1.A1_RECCSLL <> PB3.PB3_RECCSL
			        OR  SA1.A1_RECPIS  <> PB3.PB3_RECPIS
			        OR  SA1.A1_TIPCLI  <> PB3.PB3_TIPCLI
			        OR  SA1.A1_TMPVIS  <> PB3.PB3_TMPVIS
			        OR  SA1.A1_IMPENT  <> PB3.PB3_IMPEND
			        OR  SA1.A1_NRE     <> PB3.PB3_REGESP
			        OR  SA1.A1_DDI     <> PB3.PB3_DDI
			        OR  SA1.A1_PFISICA <> PB3.PB3_PFISIC
			        OR  SA1.A1_LCFIN   <> PB3.PB3_LCFIN
			        OR  SA1.A1_MOEDALC <> PB3.PB3_MOEDAL
			        OR  SA1.A1_RECISS  <> PB3.PB3_RECISS
			        OR  SA1.A1_TIPPER  <> PB3.PB3_TIPPER
			        OR  SA1.A1_SALFIN  <> PB3.PB3_SALFIN
			        OR  SA1.A1_B2B     <> PB3.PB3_B2B
			        OR  SA1.A1_PRIOR   <> PB3.PB3_PRIOR
			        OR  SA1.A1_GRPVEN  <> PB3.PB3_GRPVEN
			        OR  SA1.A1_CLICNV  <> PB3.PB3_CLICNV
			        OR  SA1.A1_SITUA   <> PB3.PB3_SITUA
			        OR  SA1.A1_ABATIMP <> PB3.PB3_ABATIM
			        OR  SA1.A1_REGCOB  <> PB3.PB3_REGCOB
			        OR  SA1.A1_TPESSOA <> PB3.PB3_TPESSO
			        OR  SA1.A1_CODLOC  <> PB3.PB3_CODLOC
			        OR  SA1.A1_CONTAB  <> PB3.PB3_CONTAB
			        OR  SA1.A1_INSCRUR <> PB3.PB3_INSCRU
			        OR  SA1.A1_NUMRA   <> PB3.PB3_NUMRA
			        OR  SA1.A1_CDRDES  <> PB3.PB3_CDRDES
			        OR  SA1.A1_FILDEB  <> PB3.PB3_FILDEB
			        OR  SA1.A1_CODFOR  <> PB3.PB3_CODFOR
			        OR  SA1.A1_ABICS   <> PB3.PB3_ABICS
			        OR  SA1.A1_BLEMAIL <> PB3.PB3_BLEMAI
			        OR  SA1.A1_TIPOCLI <> PB3.PB3_TIPOCL
			        OR  SA1.A1_SIMPNAC <> PB3.PB3_SIMPLE
			        OR  SA1.A1_RECIRRF <> PB3.PB3_RECIRR
			        OR  SA1.A1_TPISSRS <> PB3.PB3_TPISSR
			        OR  SA1.A1_CTARE   <> PB3.PB3_CTARE 
			        OR  SA1.A1_RECFET  <> PB3.PB3_RECFET
			        OR  SA1.A1_CONTRIB <> PB3.PB3_CONTRI 
			        OR  SA1.A1_VINCULO <> PB3.PB3_VINCUL
			        OR  SA1.A1_DTINIV  <> PB3.PB3_DTINIV 
			        OR  SA1.A1_DTFIMV  <> PB3.PB3_DTFIMV 
			        OR  SA1.A1_ZZDESCB <> PB3.PB3_DESC
			        OR  SA1.A1_CBO     <> PB3.PB3_CBO
			        OR  SA1.A1_CNAE    <> PB3.PB3_CNAE
			        OR  SA1.A1_LOCCONS <> PB3.PB3_LOCCON
			        OR  SA1.A1_CEINSS  <> PB3.PB3_CEINSS
			        OR  SA1.A1_FRETISS <> PB3.PB3_FRETIS
			        OR  SA1.A1_TIMEKEE <> PB3.PB3_TIMEKE
			        OR  SA1.A1_COMPLEM <> PB3.PB3_COMPLE
			        OR  SA1.A1_FOMEZER <> PB3.PB3_FOMEZE
			        OR  SA1.A1_TEL2    <> PB3.PB3_TEL2
					OR  SA1.A1_TEL3    <> PB3.PB3_TEL3
					OR  SA1.A1_TEL4    <> PB3.PB3_TEL4
			        OR  SA1.A1_TEL5    <> PB3.PB3_TEL5
			        OR  SA1.A1_TEL6    <> PB3.PB3_TEL6
				    OR  SA1.A1_XLONGIT <> PB3.PB3_XLONGI 
			        OR  SA1.A1_XLATITU <> PB3.PB3_XLATIT
				    OR  SA1.A1_CODRED  <> PB3.PB3_CODRED
					OR  SA1.A1_TPREDE  <> PB3.PB3_TPREDE
			        OR  SA1.A1_NOMEASS <> PB3.PB3_NOMEAS
					OR  SA1.A1_XOBRPC  <> PB3.PB3_XOBRPC
					OR  SA1.A1_EMAICO  <> PB3.PB3_EMAICO
					OR  SA1.A1_XTELCON <> PB3.PB3_XTELCO
					OR  SA1.A1_EMLAVC  <> PB3.PB3_EMLAVC
			        OR  SA1.A1_XVEND2  <> PB3.PB3_XVEND2
					OR  SA1.A1_XRISCO  <> PB3.PB3_XRISCO
					OR  SA1.A1_XDTRISC <> PB3.PB3_XDTRIS
					OR  SA1.A1_HRINIM  <> PB3.PB3_HRINIM
			        OR  SA1.A1_HRFINM  <> PB3.PB3_HRFINM
			        OR  SA1.A1_HRINIT  <> PB3.PB3_HRINIT
			        OR  SA1.A1_HRFINT  <> PB3.PB3_HRFINT
					OR  SA1.A1_XPROMOT <> PB3.PB3_PROMOT
					OR  SA1.A1_XEMCSF  <> PB3.PB3_EMCSF
					OR  SA1.A1_CODMUNE <> PB3.PB3_CODMUE
					OR  SA1.A1_SALPEDB <> PB3.PB3_SALPEB
					OR  SA1.A1_RAZENT  <> PB3.PB3_NOMEEN
					OR  SA1.A1_REGIMST <> PB3.PB3_REGIST
					OR  SA1.A1_MSBLQL  <> PB3.PB3_BLOQUE)
			
					ORDER BY A1_COD,A1_LOJA
			  
	EndSQl           
	  
RETURN(NIL)
