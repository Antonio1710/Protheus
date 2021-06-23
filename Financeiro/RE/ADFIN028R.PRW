#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "AP5MAIL.ch"
                                                  
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADFIN028R º Autor ³WILLIAM COSTA       º Data ³  19/01/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Importa arquivo gerado pela CISP com informacoes da RECEITAº±±
//±±º          ³  SINTEGRA relativo clientes quanto a status deles.         º±±
//±±º          ³  Gerando um relatorio de previa para verificao da acao a   º±±
//±±º          ³  ser tomada pelo financeiro                                º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ AD'ORO - SOLICITACAO ALBERTO                               º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

  
User Function ADFIN028R()

	Local _lRet        := .F.
	Private oDlg01
	Private oFont1
	Private _cFile
	Private _aDadosGer := {}
	Private _aDadosFin := {} 
	Private aLinhas    := {} 
	Private nLinha     := 0
	Private _cMotivo   := ''
	Private _cDscMot   := ''
	Private _cCNPJ     := ''
	Private cStatus    := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa arquivo gerado pela CISP com informacoes da RECEITA SINTEGRA relativo clientes quanto a status deles. Gerando um relatorio de previa para verificao da acao a ser tomada pelo financeiro ')
	
	Define msDialog oDlg01 From 00,00 To 220,370 Title "Importa arquivo com Status RECEITA/SINTEGRA de Clientes" Pixel
	Define Font oFont1 Name "Arial" Size 0,-10 Bold   //-12
	@005,005 to 080,180 of oDlg01 Pixel      //45,180
	@010,010 Say "Rotina para importar arquivo TXT com informções da " Font oFont1 of oDlg01 Pixel
	@020,010 Say "RECEITA/SINTEGRA/SUFRAMA sobre o status de Clientes.Somente" Font oFont1 of oDlg01 Pixel
	@030,010 Say "dados da RECEITA/SINTEGRA serao considerados. A condição do" Font oFont1 of oDlg01 Pixel
	@040,010 Say "cadastro dos clientes(bloqueado ou Não) mu1da em função dessa" Font oFont1 of oDlg01 Pixel
	@050,010 Say "informação. Email é enviado aos responsaveis." Font oFont1 of oDlg01 Pixel
	
	@080,115 BmpButton Type 1 Action(_lRet := .T.,Close(oDlg01))
	@080,150 BmpButton Type 2 Action(_lRet := .F.,Close(oDlg01))
	Activate Dialog oDlg01 Centered
	
	If _lRet
	   _cFile := cGetFile("Arquivo REC/SIN/SUF|*.txt|",OemToAnsi("Abrir arquivo..."),,'C:\',.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	   IF !Empty(_cFile)
	      if (MsgNoYes("Confirma inicio da importação?" + _cFile))
	         _aFile := Directory(_cFile)
	         _nIn := 0
	         Processa( {|| ProcFile()},"Importando o arquivo..." )
	         If _nIn > 0
	            MsgInfo("Atençao! Houve problema com o arquivo")
	         Endif
	         DbSelectArea("SA1")
	         DbSetOrder(1)
	         dbGotop()         
	      Endif
	   Else
	      MsgInfo("Não foi escolhido nenhum arquivo para ser importado.","Atenção")      
	   Endif
	Endif   
	
	LogAdLog004R()

Return(_lRet)

Static function ProcFile()

	
    FT_FUSE(_cFile)
    _nTam := FT_FLASTREC()
    FT_FGoTop()
    ProcRegua(_nTam)
    While !(FT_Feof())
    	IncProc("importando dados e realizando as atualizações necessarias...")
        _cTxt := Alltrim(FT_FReadLN())
        _cTxt := Alltrim(_cTxt)
             
        	LeArq()
             
            FT_FSKIP() 
    Enddo
    FT_FUSE()
                  
	for _nz := 1 to len(_aDadosGer)
	    _cStatSIN := "C"
	    _cStatREC := "C"
	    If _aDadosGer[_nz][4] == "1" &&Sintegra
	       _cStatSIN := "C"
	       _cStatREC := "C" 
	       if alltrim(_aDadosGer[_nz][2]) == "ATIVA" .Or. Alltrim(_aDadosGer[_nz][2]) == "ATIVO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO ATIVO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO COM RESTRICAO" ;
	           .Or. Alltrim(_aDadosGer[_nz][2]) == "ATIVO - HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO - ATIVO" 
	          _cStatSIN := "A"     &&ativo
	       Elseif Substr(Alltrim(_aDadosGer[_nz][2]),1,14) == "NAO HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "INAPTO" .Or. Alltrim(_aDadosGer[_nz][2]) == "INAPTA" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADA" ;
	            .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO (VIDE OBS)" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSA" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSO" ;
	            .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXA DEFERIDA"
	          _cStatSIN := "B"     &&Bloqueado
	       Endif      
	       //fprocCli(_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatCISP,"1")
	       _nPos  := Ascan(_aDadosFin,{|x| x[1]  == _aDadosGer[_nz][1]} )   &&verifico se ja existe gravado o CNPJ 
	       If _nPos = 0
		       AADD(_aDadosFin,{_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatSIN,_cStatREC})
	       Else                      
	         _aDadosFin[_nPOs][3] := _cStatSIN       
	       Endif       
	    Elseif _aDadosGer[_nz][4] == "2"  &&Receita
	       _cStatSIN := "C"
	       _cStatREC := "C"  
	       if alltrim(_aDadosGer[_nz][2]) == "ATIVA" .Or. Alltrim(_aDadosGer[_nz][2]) == "ATIVO".Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO ATIVO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO COM RESTRICAO"
	          _cStatREC := "A"     &&ativo
	       Elseif Alltrim(_aDadosGer[_nz][2]) == "INAPTA" .Or. Alltrim(_aDadosGer[_nz][2]) == "CANCELADA" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSA" .Or. Alltrim(_aDadosGer[_nz][2]) == "INAPTO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADA" ;
	             .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO (VIDE OBS)" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSA" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXA DEFERIDA"
	          _cStatREC := "B"     &&Bloqueado
	       Endif     
	       //fprocCli(_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatCISP,"2")
	       _nPos  := Ascan(_aDadosFin,{|x| x[1]  == _aDadosGer[_nz][1]} )   &&verifico se ja existe gravado o CNPJ 
	       If _nPos = 0
		       AADD(_aDadosFin,{_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatSIN,_cStatREC})
	       Else                      
	         _aDadosFin[_nPOs][4] := _cStatREC       
	       Endif
	    Endif                     
	NEXT _nz
	
	for _nz := 1 to len(_aDadosFin)
	    //fprocCli(_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatCISP,"2")
	    fprocCli(_aDadosFIN[_nz][1],_aDadosFIN[_nz][2],_aDadosFIN[_nz][3],_aDadosFIN[_nz][4])
	NEXT _nz 
	


Return()


Static function fprocCli(_cCNPJ,_cSitua,_cStSIN,_cStREC)
       
       DbSelectarea("SA1")               &&confirmado junto a Adriana e Alberto, so considerar clientes com cadastro na SA1...
       DbSetOrder(3)
       if dbseek(xFilial("SA1")+ALltrim(_cCNPJ))
          If SA1->A1_MSBLQL == "2" .Or. Empty(SA1->A1_MSBLQL)
             _cStatProt := "A"
          Elseif SA1->A1_MSBLQL == "1"   
             _cStatProt := "B"
          Endif          
          IF _cStatProt == "A" .And. (_cStSIN == "B" .Or. _cStREC == "B")      &&Neste caso vou bloquear no Protheus...
             IF _cStSIN == "B"
                _cMotivo := "IF"
                _cDscMot := "Cliente bloqueado por irregularidade Fiscal relativo ao SINTEGRA."
                cStatus  := 'Bloqueado'
                //AdoGrvBloq( SA1->A1_COD,SA1->A1_LOJA,_cMotivo, _cDscMot,_cCNPJ)
                CarregaLinhaExcel() //will
             Elseif _cStREC == "B"   
                _cMotivo := "IF"
                _cDscMot := "Cliente bloqueado por irregularidade Fiscal relativo a RECEITA."
                cStatus  := 'Bloqueado'
                //AdoGrvBloq( SA1->A1_COD,SA1->A1_LOJA,_cMotivo, _cDscMot,_cCNPJ)
                CarregaLinhaExcel() //will
             Endif   
          Elseif _cStatProt == "B" .And. (_cStSIN == "A" .AND. _cStREC == "A") &&neste caso vou enviar email para avaliarem o desbloqueio ou não....
                _cMotivo := "IF"                
                _cDscMot := "Cliente se encontra com situação de ATIVO junto a SINTEGRA/RECEITA e bloqueado no Protheus."                                                                                   
                cStatus  := 'Sem Alteração'
                //AdoGrvlib( SA1->A1_COD,SA1->A1_LOJA,_cMotivo, _cDscMot,_cCNPJ)           
                CarregaLinhaExcel() //will
          Endif
       Endif
Return()
                                                                                                                   	
Static function LeArq()

	_cStatCISP := ""
	
	If Substr(_cTxt,1,1) == "1" .Or. Substr(_cTxt,1,1) == "2"  &&1 Sintegra     2 Receita
	   
	   _cTp     := Substr(_cTxt,1,1)
	   _cCNPJ   := Substr(_cTxt,5,14)
	   _cSitua  := Substr(_cTxt,715,50)
	   _cDTCONS := Substr(_cTxt,781,8)
	   
	   _nPos  := Ascan(_aDadosGer,{|x| (x[1] + x[4]) == (_cCNPJ + _cTp)} )   &&verifico se ja existe gravado o CNPJ + Tipo
	   If _nPos = 0
		  AADD(_aDadosGer,{_cCNPJ,_cSitua,_cDTCONS,_cTp})
	   Else      
	      IF STOD(_cDTCONS) > STOD(_aDadosger[_nPos][3])  && se data no registro atual é maior que data ja registrada no array
	         _aDadosGer[_nPos][2] := _cSitua
	         _aDadosGer[_nPOs][3] := _cDTCONS
	         _aDadosGer[_nPos][4] := _cTp
	      Endif
	   Endif
	     
	Endif      
             
Return() 

Static Function LogAdLog004R()  
  
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'REL_PREVIA_SINTEGRA_CISP.XML'
	Public oMsExcel
	Public cPlanilha   := "SINTEGRA CISP"
    Public cTitulo     := "SINTEGRA CISP"
	
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return(NIL) 

STATIC FUNCTION CarregaLinhaExcel()

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
   	               "", ; // 11 K  
   	               ""  ; // 12 L   
   	                  })
	//===================== FINAL CRIA VETOR COM POSICAO VAZIA
	
	//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
	aLinhas[nLinha][01] := SA1->A1_COD                                                                    //A
	aLinhas[nLinha][02] := SA1->A1_LOJA                                                                   //B
	aLinhas[nLinha][03] := SA1->A1_NOME                                                                   //C
	aLinhas[nLinha][04] := SA1->A1_CGC                                                                         //D
	aLinhas[nLinha][05] := SA1->A1_VEND + '-' + POSICIONE("SA3",1,xFilial("SA3")+SA1->A1_VEND, "A3_NOME") //E
	aLinhas[nLinha][06] := Posicione("PB3",11,xFilial("PB3")+SA1->A1_COD+SA1->A1_LOJA,"PB3_LIMAPR")       //F
	aLinhas[nLinha][07] := SA1->A1_COND +"-"+Posicione("SE4",1,xFilial("SE4")+SA1->A1_COND,"E4_DESCRI")   //G
	aLinhas[nLinha][08] := cUserName+ " data: "+DtoC( dDatabase )                                         //H
	aLinhas[nLinha][09] := SA1->A1_MSBLQL                                                                 //I
	aLinhas[nLinha][10] := Posicione("PB3",11,xFilial("PB3")+SA1->A1_COD+SA1->A1_LOJA,"PB3_BLOQUE")       //J
	aLinhas[nLinha][11] := cStatus                                                                        //K
	aLinhas[nLinha][12] := "Informação para avaliação : "+ _cMotivo+" - "+ _cDscMot                       //L
	
	//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			

RETURN(NIL)

Static Function GeraExcel()

    Local cNomeRegiao := ''
	Local nExcel      := 0
	
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
	                                 aLinhas[nExcel][11],; // 11 K  
	                                 aLinhas[nExcel][12] ; // 12 L  
	                                                    }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS
    NEXT      
    nLinha  := 0
	//============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_PREVIA_SINTEGRA_CISP.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_PREVIA_SINTEGRA_CISP.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return() 

Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Codigo "          ,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Loja "            ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome "            ,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"CNPJ "            ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Vendedor "        ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Limite Aprov "    ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"Prazo "           ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Usuario/Arquivo " ,1,1) // 08 H 			
	oExcel:AddColumn(cPlanilha,cTitulo,"A1_MSBLQL "       ,1,1) // 09 I 			
	oExcel:AddColumn(cPlanilha,cTitulo,"PB3_BLOQUE "      ,1,1) // 10 J 			
	oExcel:AddColumn(cPlanilha,cTitulo,"Cliente Será "    ,1,1) // 11 K			
	oExcel:AddColumn(cPlanilha,cTitulo,"Motivo "          ,1,1) // 12 L
		
RETURN(NIL)     