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
  
Static cTitulo      := "Conciliação PB3 X SZF"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFIN075P º Autor ³ WILLIAM COSTA      º Data ³ 14/06/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Conciliação PB3 X SZF                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADFIN075P()

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
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SZF')
	
	If Select("TRC") > 0
		TRC->(DbCloseArea())
	EndIf
	
	MsgRun("Criando estrutura e carregando dados no arquivo temporário...",,{|| aTRC := FileTRC() } )
		
	//Definindo as colunas que serão usadas no browse
	
	aAdd(aMark, {"Campo SZF"     , "TMP_CPSZF" , "C", 10, 0, "@!"                  })
    aAdd(aMark, {"Descricao SZF" , "TMP_DESSZF", "C", 14, 0, "@!"                  })
    aAdd(aMark, {"Campo PB3"     , "TMP_CPPB3" , "C", 10, 0, "@!"                  })
    aAdd(aMark, {"Descricao PB3" , "TMP_DESPB3", "C", 14, 0, "@!"                  })
    aAdd(aMark, {"Qtd Inativo"   , "TMP_QTDINA", "N", 17, 0, "@E 9,999,999,999,999"})
    aAdd(aMark, {"Qtd Ativo"     , "TMP_QTDATI", "N", 17, 0, "@E 9,999,999,999,999"})
    aAdd(aMark, {"Qtd Diferenca" , "TMP_QTDDIF", "N", 17, 0, "@E 9,999,999,999,999"})
    
    SetFunName("ADFIN075P")
	
	aAdd(aIndex, "TMP_CPSZF" )
	aAdd(aIndex, "TMP_DESSZF" )
	aAdd(aIndex, "TMP_QTDINA" )
	aAdd(aIndex, "TMP_QTDATI" )
	aAdd(aIndex, "TMP_QTDDIF" ) 
	
	aAdd(aSeek,{"Codigo SZF"    ,{{"","C",010,0,"TMP_CPSZF" ,"@!"                  }} } )
	aAdd(aSeek,{"Descricao SZF" ,{{"","C",014,0,"TMP_DESSZF" ,"@!"                 }} } )
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
	
	ADD OPTION aRot TITLE 'Marcar Todos'              ACTION 'u_FIN075Marcar()'    OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Desmarcar Todos'           ACTION 'u_FIN075Desmarcar()' OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Gerar Excel'               ACTION 'u_FIN075EXCEL()'     OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Processar Campos Marcados' ACTION 'u_FIN075Processa()'  OPERATION 2 ACCESS 0
	ADD OPTION aRot TITLE 'Total Geral Diferencas'    ACTION 'u_FIN075Total()'     OPERATION 2 ACCESS 0
	
Return(aRot)

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	
	Local oModel    := Nil
	
	//Criando o modelo e os relacionamentos
	oModel := FWLoadModel('zAFIN075') 
	
Return(oModel)

/*---------------------------------------------------------------------*
 | Função:  ViewDef                                                    |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	
	Local oView			:= Nil
	
	//Criando a View
	oView := FWLoadView('zAFIN075')
	
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
	aAdd(aStrut, {"TMP_CPSZF" , "C", 10, 0} )
    aAdd(aStrut, {"TMP_DESSZF", "C", 14, 0} )
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
	IndRegua( cAliasTmp, cInd1, "TMP_CPSZF" , , , "Criando índices...")
	IndRegua( cAliasTmp, cInd2, "TMP_DESSZF", , , "Criando índices...")
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
	aAdd(aCampos,{"","ZF_REDE"   ,BuscaNome("ZF_REDE")   ,"PB3_CODRED"  ,BuscaNome("PB3_CODRED")  ,BuscaDiferenca("ZF_REDE"  ,"PB3_CODRED",1   ),BuscaDiferenca("ZF_REDE"  ,"PB3_CODRED",2   ),BuscaDiferenca("ZF_REDE"  ,"PB3_CODRED",3   )})
	
	For nCont :=1 to Len(aCampos)
	
		TRC->(RecLock("TRC",.T.))
		
			 TRC->TMP_OK     := aCampos[nCont][1]
			 TRC->TMP_CPSZF  := aCampos[nCont][2]
			 TRC->TMP_DESSZF := aCampos[nCont][3]
			 TRC->TMP_CPPB3  := aCampos[nCont][4]
			 TRC->TMP_DESPB3 := aCampos[nCont][5]
			 TRC->TMP_QTDINA := aCampos[nCont][6]
			 TRC->TMP_QTDATI := aCampos[nCont][7]
			 TRC->TMP_QTDDIF := aCampos[nCont][8]
			 
		TRC->(MsUnLock())
		
	NEXT nCont
	
	// *** FINAL CRIAR LINHAS TABELA TEMPORARIA *** //
	
Return({cArqs,cInd1,cInd2,cInd3,cInd4,cInd5})

User Function FIN075Marcar(cMarca,lMarcar)

    Local aArea  := TRC->( GetArea() )
    Local cMarca := oMark:Mark()

	U_ADINF009P('ADFIN075P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SZF')
    
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

User Function FIN075Desmarcar(cMarca,lMarcar)

    Local aArea  := TRC->( GetArea() )

	U_ADINF009P('ADFIN075P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SZF')
 
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

User FUNCTION FIN075EXCEL()

	PRIVATE oExcel      := FWMSEXCEL():New()
	PRIVATE cArquivo    := 'REL_PB3_SZF' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	PRIVATE oMsExcel
	PRIVATE cPlanilha   := "Conciliacao PB3_SZF"
    PRIVATE aLinhas     := {}

	U_ADINF009P('ADFIN075P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SZF')

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
	
	SqlGeral(cCAmpo1,cCampo2)
	
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
	   	               ""  ; // 09 I  
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		aLinhas[nLinha][01] := TRE->ZF_REDE     //A
		aLinhas[nLinha][02] := TRE->PB3_COD    //B
		aLinhas[nLinha][03] := TRE->PB3_LOJA   //C
		aLinhas[nLinha][04] := TRE->PB3_NOME   //D
		aLinhas[nLinha][05] := TRE->ZF_CGCMAT  //E
		aLinhas[nLinha][06] := TRE->PB3_CGC    //F
		aLinhas[nLinha][07] := TRE->PB3_BLOQUE //G
		aLinhas[nLinha][08] := TRE->&(cCab1)   //J
		aLinhas[nLinha][09] := TRE->&(cCab2)   //K
		
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
	                                 aLinhas[nExcel][09] ; // 09 I  
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
    oExcel:AddColumn(cPlanilha,cTitulo,"ZF_REDE "         ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_COD "         ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_LOJA "        ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_NOME "        ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"ZF_CGCMAT "       ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_CGC "         ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_BLOQUE "      ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,'"' + cCAmpo1 + '"',1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,'"' + cCampo2 + '"',1,1) // 09 I
	
RETURN(NIL)

User Function FIN075Processa()

	Local aArea    := GetArea()
    Local cMarca   := oMark:Mark()
    Local lInverte := oMark:IsInvert()
    Local nCont    := 0
    Local nOpcao   := 0
    Local oDlg     := NIL

	U_ADINF009P('ADFIN075P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SZF')
    
    DEFINE MSDIALOG oDlg FROM	18,1 TO 80,300 TITLE "FIN075Processa - Processar" PIXEL
	  
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
		               					
						GravaLog(TRC->TMP_CPSZF,TRC->TMP_CPPB3)
						UpdCampoNormal(TRC->TMP_CPSZF,TRC->TMP_CPPB3,nOpcao)
							
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

User Function FIN075Total()

	Local cTotInativo := BuscaTotalGeral('1')
	Local cTotAtivo   := BuscaTotalGeral('2')
	Local cTotal      := CVALTOCHAR(VAL(cTotInativo) + VAL(cTotAtivo))
	Local oDlg        := NIL

	U_ADINF009P('ADFIN075P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Conciliação PB3 X SZF')

	DEFINE MSDIALOG oDlg FROM	18,1 TO 80,360 TITLE "FIN075Total - Total Divergência" PIXEL
	  
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

	SqlGeral(cCAmpo1,cCampo2)
	
	DBSELECTAREA("TRE")
	TRE->(DBGOTOP())
	WHILE TRE->(!EOF())
	
		RecLock("ZBE",.T.)
		
			ZBE->ZBE_FILIAL := ''
			ZBE->ZBE_DATA	:= Date()
			ZBE->ZBE_HORA	:= cValToChar(Time())
			ZBE->ZBE_USUARI	:= cUserName
			ZBE->ZBE_LOG	:= "ZF_REDE: " + TRE->ZF_REDE + " PB3_COD: " + TRE->PB3_COD + " PB3_LOJA: " + TRE->PB3_LOJA + " Alteração campo " + cCAmpo2 + " de: " + TRE->&(cCab4) + " para: " + TRE->&(cCab3)   
			ZBE->ZBE_MODULO	:= "FINANCEIRO"
			ZBE->ZBE_ROTINA	:= "ADFIN075P"
			
		MsUnlock()
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
		TRE->(dbSkip())    
	
	END //end do while TRB
	TRE->( DBCLOSEAREA() )
			
RETURN(NIL)			

STATIC FUNCTION SqlCountDif(cCampo1,cCampo2,nAtivo)

	Local cQuery:= ''

	cQuery:= "SELECT COUNT(*) AS COUNT  " 
	cQuery+= " FROM "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("SZF") + " SZF WITH(NOLOCK) "
	cQuery+= "         ON ZF_CGCMAT          = LEFT(PB3_CGC,8) "
	cQuery+= "        AND SZF.D_E_L_E_T_ <> '*' "
	cQuery+= "      WHERE PB3_CGC           <> '00000000000000' "
	cQuery+= "        AND PB3.D_E_L_E_T_ <> '*' "
	
	
	IF nAtivo == 1
	
		cQuery+= "        AND PB3.PB3_BLOQUE      = '1' "
	
	ENDIF
	 
	IF nAtivo == 2
	
		cQuery+= "        AND PB3.PB3_BLOQUE      = '2' "
	
	ENDIF
	
	cQuery+= "        AND SZF." + cCampo1 + " <> PB3." + cCampo2 + " "
	
    TCQUERY cQuery new alias "TRD"
    
RETURN(NIL)

Static Function SqlGeral(cCampo1,cCampo2)

	Local cQuery:= ''
	
	cQuery:= "SELECT PB3_COD,PB3_LOJA,PB3_CODRED,ZF_REDE,PB3_CGC,LEFT(PB3_CGC,8) AS PB3_CGCMATRIZ,ZF_CGCMAT,PB3_NOME, PB3_BLOQUE  " 
	cQuery+= " FROM "+RETSQLNAME("PB3") + " PB3 WITH(NOLOCK) "
	cQuery+= " INNER JOIN "+RETSQLNAME("SZF") + " SZF WITH(NOLOCK) "
	cQuery+= "         ON ZF_CGCMAT          = LEFT(PB3_CGC,8) "
	cQuery+= "        AND SZF.D_E_L_E_T_ <> '*' "
	cQuery+= "      WHERE PB3_CGC           <> '00000000000000' "
	cQuery+= "        AND PB3.D_E_L_E_T_ <> '*' "
	cQuery+= "        AND SZF." + cCampo1 + " <> PB3." + cCampo2 + " "
	
    TCQUERY cQuery new alias "TRE"
	
RETURN()

STATIC FUNCTION UpdCampoNormal(cCampo1,cCampo2,nOpc)

	Local cUpd      := ''
	Local cIntregou := ''
	
	cUpd:= "UPDATE PB3010 "
	cUpd+= "SET " + cCampo2 + "  = SZF." + cCampo1 + " FROM "+RETSQLNAME("PB3") + " "
	cUpd+= " INNER JOIN "+RETSQLNAME("SZF") + " SZF WITH(NOLOCK) "
	cUpd+= "         ON ZF_CGCMAT          = LEFT(PB3_CGC,8) "
	cUpd+= "        AND SZF.D_E_L_E_T_ <> '*' "
	cUpd+= "      WHERE PB3_CGC           <> '00000000000000' "
	cUpd+= "        AND PB3010.D_E_L_E_T_ <> '*' "
	cUpd+= "        AND SZF." + cCampo1 + " <> " + cCampo2 + " "
	
	IF nOpc == 1
	
		cUpd+= "        AND PB3_BLOQUE      = '1' "
	
	ENDIF
	 
	IF nOpc == 2
	
		cUpd+= "        AND PB3_BLOQUE      = '2' "
	
	ENDIF
	
	If (TCSQLExec(cUpd) < 0)
	
    	cIntregou += " TCSQLError() - UpdCampoVend: " 
    	conout("TCSQLError() " + TCSQLError())
    	
	EndIf
    
RETURN(NIL)

Static Function SqlTotalGeral(cAtivo)

	BeginSQL Alias "TRI"
			%NoPARSER%
			SELECT PB3_COD,PB3_LOJA,PB3_CODRED,ZF_REDE,PB3_CGC,LEFT(PB3_CGC,8) AS PB3_CGCMATRIZ,PB3_NOME, PB3_BLOQUE
			  FROM %TABLE:PB3%, %TABLE:SZF%
			 WHERE PB3_CGC                <> '00000000000000'
			   AND %TABLE:PB3%.D_E_L_E_T_ <> '*'
			   AND ZF_CGCMAT               = LEFT(PB3_CGC,8)
			   AND PB3_CODRED             <> ZF_REDE
			   AND %TABLE:SZF%.D_E_L_E_T_ <> '*'
				
				ORDER BY %TABLE:PB3%.PB3_COD,%TABLE:PB3%.PB3_LOJA  
			  
	EndSQl           
	  
RETURN(NIL)