#include "Protheus.ch" 
#include "TopConn.ch"
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ADVEN049P  บAutor  ณFernando            บ Data ณ24/03/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonitoramento Libera็ใo Credito Pedido de Venda             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADVEN049P()    //u_ADVEN049P()

Local oDlg     := Nil
Local cTitulo  := "Monitoramento Ped.Venda"
Local oOv      := LoadBitmap( GetResources(), "BR_VERDE")
Local oNa      := LoadBitmap( GetResources(), "BR_AMARELO" )
Local oNz      := LoadBitmap( GetResources(), "BR_AZUL" )
Local oNl      := LoadBitmap( GetResources(), "BR_LARANJA" )
Local oNe      := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oOk      := LoadBitmap( GetResources(), "BR_CANCEL" )

Local i        := 0
Local cLine    := ""
 
Local cParm    := "" 
Local cHora    := ""
Local cData    := ""		
Local cUser    := ""			
   		
Private oLbx   := Nil
Private aVetor := {}
Private oTimer := Nil   
Private cPerg  := "ADVEN049P"

Private nTotalCX  := 0
Private nTotalKG  := 0
Private nTotalPed := 0 
Private nVlrTotal := 0  

Private aListBox1 := {}
Private oListBox1

Private nVezes    := 1

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Monitoramento Libera็ใo Credito Pedido de Venda')

cLine := "{IIf(aVetor[oLbx:nAt,1] <> 5,IIf(aVetor[oLbx:nAt,1] <> 2,IIf(aVetor[oLbx:nAt,1] <> 1,IIf(aVetor[oLbx:nAt,1] <> 3,IIf(aVetor[oLbx:nAt,1] <> 4,oOk,oNl),oNz),oOv),oNa),oNe)"
 
For i:=2 To 7
   cLine += ",aVetor[oLbx:nAt]["+AllTrim(Str(i))+"]"
Next

cLine += "}"
bLine := &("{|| "+cLine+"}")

&& chamada da pergunta
If !Pergunte(cPerg,.T.) 
	Return
EndIf 


    /******
	* Monta a tela para usuario visualizar consulta |
    ******/
    DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 490,720 PIXEL
                                                                                               
   	  
   	    @ 10,10 LISTBOX oLbx FIELDS HEADER " ","","Pedido(s)","Caixa(s)", "  KG  ","  R$  "," % ", SIZE 340,80 OF oDlg PIXEL 
   
  		DEFINE TIMER oTimer INTERVAL 40000 ACTION  LoadArq(2) OF oDlg
   
   		oTimer:Activate()
   		LoadArq(2) 
  		
  			
	   	@ 100,20 SAY "Entrega De : "+Dtoc(Mv_Par01) SIZE 100,007 OF oDlg PIXEL
	   	@ 110,20 SAY "Entrega Ate: "+Dtoc(Mv_Par02) SIZE 100,007 OF oDlg PIXEL 
	   	
	   	
	   	@ C(095),C(10) TO C(185),C(275) LABEL "LOG-ACESSO" PIXEL OF oDlg
	   	
	   	
	   	//list box do log 
	   	cQry := " SELECT TOP 10 ZBE_DATA, ZBE_HORA, ZBE_PARAME, ZBE_USUARI FROM "+retSqlName("ZBE")+" WHERE ZBE_ROTINA = 'ADLCOMXXP' ORDER BY R_E_C_N_O_ DESC "
		TcQuery cQry new alias "LOGA"
		 
		LOGA->(dbgotop())
   		While !LOGA->(EOF())
   		
   			cParm := Alltrim(LOGA->ZBE_PARAME)
   			cHora := LOGA->ZBE_HORA 
   			cData := dToC(sToD(LOGA->(ZBE_DATA)))
   			cUser := alltrim(LOGA->ZBE_USUARI)
   			
   			Aadd(aListBox1,{cUser+" "+cData+" "+cHora +"-->"+cParm    , " DATA ENTREGA DE:"+Dtoc(MV_PAR01)+" ATE "+Dtoc(MV_PAR02)})
		
   		LOGA->(dbSkip())
   		EndDo
	
   		dbCloseArea("LOGA")


		@ C(100),C(015) ListBox oListBox1 Fields ;
		HEADER " LOG "," PARAMETROS ";
		Size C(255),C(080) Of oDlg Pixel;
		//ColSizes 
		oListBox1:SetArray(aListBox1)

   		
   		oListBox1:bLine := {|| {aListBox1[oListBox1:nAt,1],aListBox1[oListBox1:nAt,2]} }
	  
		DEFINE SBUTTON FROM 100,260 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTER


/******
 * Fun็ใo para atualizar o vetor e o Listbox
 ******/
Static Function LoadArq(nTp) 

Local nLeg 			:= 0
Local nDesc    		:= "" 
Local cNumFilial    := Substr(CNUMEMP,3,2)
aVetor := {}  

If nTp==2
   oTimer:Deactivate()
Endif


nTotalCX  := 0
nTotalKG  := 0
nTotalPed := 0 
nVlrTotal := 0

If nTp==2 

	If SELECT("TMP1") > 0
	   DBSELECTAREA("TMP1")
	   DBCLOSEAREA("TMP1")
	Endif 
    //

	Query := " SELECT "

	Query += " COUNT(FONTES2.PED) AS PED,"
	Query += " SUM(FONTES2.QTDCX) AS CX,"
	Query += " SUM(FONTES2.QTDKG) AS KG,"
	Query += " SUM(FONTES2.VALOR) AS VLR,"
	Query += " FONTES2.LEGENDA "

	Query += " FROM "
	Query += " ( "
	Query += " SELECT " 

	Query += " FONTES1.PED, "
	Query += " FONTES1.QTDCX, "
	Query += " FONTES1.QTDKG, "
	Query += " FONTES1.VALOR, "
	Query += " FONTES1.VENDEDOR, "
	Query += " FONTES1.PREAPROV, "
	Query += " FONTES1.C9PEDIDO, "
	Query += " FONTES1.CREDITO, "
	Query += " FONTES1.ESTOQUE, "
	Query += " FONTES1.PBRUTO, "

	Query += " CASE " 
		
	Query += " WHEN FONTES1.LIBEROK = ''  and FONTES1.NOTA = ''  and FONTES1.BLQ = '' THEN 'VERDE' "	  //-- 'PDV.ABERTO'    -- Verde
	Query += " WHEN FONTES1.LIBEROK IN('E','S')  and FONTES1.NOTA <> '' and FONTES1.BLQ = '' THEN 'VERMELHO' "   //-- 'PDV.ECERRADO'  -- Vermelho
	Query += " WHEN FONTES1.LIBEROK <> '' and FONTES1.NOTA = ''  and FONTES1.BLQ = '' THEN 'AMARELO' "	  //-- 'PDV.LIBERADO'  -- Amarelo
	Query += " WHEN FONTES1.BLQ = '1' THEN 'AZUL'"		    											  //'PDV.BLOQUEADO REGRA' " // Azul
	Query += " WHEN FONTES1.BLQ = '2' THEN 'LARANJA'"													  //'PDV.BLOQUEADO VERBA' " // Laranja

	Query += " ELSE 'VALIDAR' "
	Query += " END AS 'LEGENDA' "

	Query += " FROM  "
	Query += " ( "
	Query += " SELECT " 

	Query += " DADOS.PED,  "
	Query += " SUM(DADOS.QTDCX) QTDCX,  "
	Query += " SUM(DADOS.QTDKG) QTDKG, " 
	Query += " SUM(DADOS.VALOR) VALOR, " 	
	Query += " DADOS.VENDEDOR, "
	Query += " DADOS.PREAPROV, "
	Query += " ISNULL(DADOS.C9PEDIDO,'') C9PEDIDO, " 
	Query += " ISNULL((SELECT TOP 1 C9_BLCRED FROM "+retsqlname("SC9")+"  SC9 WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS CREDITO, " 
	Query += " ISNULL((SELECT TOP 1 C9_BLEST  FROM "+retsqlname("SC9")+"  SC9 WHERE SC9.C9_PEDIDO = DADOS.PED  AND SC9.C9_FILIAL = '02' AND SC9.D_E_L_E_T_ = '' ),'') AS ESTOQUE, "
	Query += " DADOS.PBRUTO, "
	Query += " DADOS.LIBEROK, "
	Query += " DADOS.NOTA, "
	Query += " DADOS.BLQ "

	Query += " FROM  "
	Query += " (SELECT "
	Query += " Distinct(C6_PRODUTO)AS PRODUTO,  "
	Query += " C5_VEND1   AS VENDEDOR, " 
	Query += " C6_NUM     as PED, "
			
	Query += " (C6_UNSVEN)  AS QTDCX, "  
	Query += " (C6_QTDVEN)  AS QTDKG, "  
	Query += " (C6_VALOR)   AS VALOR, "  
	Query += " (C6_QTDORI)  AS KGORI, " 
	Query += " (C6_QTDORI2) AS CXORI, " 
	Query += " C9_PEDIDO    AS C9PEDIDO, "
	Query += " C5_XPREAPR   AS PREAPROV, "
	Query += " C5_PBRUTO    AS PBRUTO, "
	Query += " C5_LIBEROK   AS LIBEROK, "
	Query += " C5_NOTA      AS NOTA, "
	Query += " C5_BLQ		AS BLQ "

	Query += " FROM "+retsqlname("SC6")+" SC6 WITH (NOLOCK) " 
				   
	Query += " LEFT JOIN "+retsqlname("SC9")+"  SC9 WITH (NOLOCK) " 
	Query += " ON  SC6.C6_FILIAL = SC9.C9_FILIAL  "   
	Query += " AND SC6.C6_NUM    = SC9.C9_PEDIDO  "  
	Query += " AND SC6.C6_CLI    = SC9.C9_CLIENTE  "  
	Query += " AND SC6.C6_LOJA   = SC9.C9_LOJA "    
	Query += " AND SC9.D_E_L_E_T_ <> '*' " 
								
	Query += " INNER JOIN "+retsqlname("SC5")+"  SC5 WITH (NOLOCK) " 
	Query += " ON  SC6.C6_FILIAL  = SC5.C5_FILIAL "  
	Query += " AND SC6.C6_NUM     = SC5.C5_NUM "  
	Query += " AND SC6.C6_CLI     = SC5.C5_CLIENTE "  
	Query += " AND SC6.C6_LOJA    = SC5.C5_LOJACLI "   
	Query += " AND SC5.D_E_L_E_T_ <> '*' " 
				   
	Query += " INNER JOIN "+retsqlname("SA3")+"  SA3 WITH (NOLOCK) " 
	Query += " ON SC5.C5_VEND1 = SA3.A3_COD "    
	Query += " AND SA3.D_E_L_E_T_ <> '*' " 
			
	Query += " INNER JOIN "+retsqlname("SZR")+"  SZR WITH (NOLOCK) "  
	Query += " ON SA3.A3_CODSUP = SZR.ZR_CODIGO  " 
	Query += " AND SZR.D_E_L_E_T_ <> '*'  "
				   
	Query += " WHERE SC6.C6_SEGUM NOT IN ('KG','') " 
	Query += " AND SC5.C5_FILIAL   = '"+cNumFilial+"'" //PEGA A FILIAL LOGADA E NAO POSICIONADA
	Query += " AND SC5.C5_DTENTR   >=  '"+Dtos(Mv_Par01)+"' AND SC5.C5_DTENTR <= '"+Dtos(Mv_Par02)+"'"
	Query += " AND SC6.D_E_L_E_T_  <> '*' "
	Query += " AND SC5.C5_TIPO     =  'N' " 
	Query += " AND SC6.C6_UNSVEN   >  0   "
	Query += ") as DADOS   "
	Query += " GROUP BY PED, VENDEDOR,C9PEDIDO,PREAPROV,PBRUTO,LIBEROK,NOTA,BLQ) AS FONTES1) AS FONTES2 "
	Query += " GROUP BY FONTES2.LEGENDA "
	Query += " ORDER BY PED DESC "
	
 	TCQUERY Query new alias "TMP1"    
   
    TMP1->(dbgotop())
    While !EOF()  
   			nTotalPed := nTotalPed + TMP1->PED 
   			nTotalCX  := nTotalCX  + TMP1->CX
   			nTotalKG  := nTotalKG  + TMP1->KG
   			nVlrTotal := nVlrTotal + TMP1->VLR
   	DbSkip()
   	End
  
   	TMP1->(dbgotop())
   	While !EOF()     
   		
   		If TMP1->LEGENDA = 'VERDE'
   			nLeg  := 1
   			nDesc := "ABERTO"
   		ElseIf TMP1->LEGENDA = 'AMARELO'
   			nLeg := 2              
   			nDesc := "LIBERADO"
   		ElseIf TMP1->LEGENDA = 'AZUL'
   			nLeg := 3  
   			nDesc := "BLOQUEADO"
   		ElseIf TMP1->LEGENDA = 'LARANJA'
   			nLeg := 4
   			nDesc := "BLOQUEADO"
   		ElseIf TMP1->LEGENDA = 'VERMELHO'
   			nLeg := 5
   			nDesc := "ENCERRADO"		
   	    EndIf
   	    
 		aAdd(aVetor,{nLeg,nDesc,TMP1->PED,Transform(TMP1->CX, "@E 999,999,999") ,Transform(TMP1->KG,"@E 999,999,999.99"),Transform(TMP1->VLR,"@E 999,999,999.99"),IIF(TMP1->LEGENDA <> 'CORTE',ROUND((TMP1->PED/nTotalPed)*100,3),),})
   	
   	DbSkip()
   	End 
  	
   	//total
   	aAdd(aVetor,{0,"TOTAL ->",nTotalPed,Transform(nTotalCX, "@E 999,999,999") ,Transform(nTotalKG,"@E 999,999,999.99"),Transform(nVlrTotal,"@E 999,999,999.99"),,})
    

Else                                                 
 	aAdd(aVetor,{2,"","","","","", })  
End IF 	


	
	If nVezes == 1
		
		TMP1->(dbgotop())
		While !EOF() 
			
			u_GrLogZBE(Date(),TIME(),cUserName,"SITUAวรO/CONTROLE DE PEDIDOS VENDA","COMERCIAL","ADLCOMXXP",;
				  	   "QTD.PED "+CVALTOCHAR(TMP1->PED)+" "+TMP1->LEGENDA,ComputerName(),LogUserName())  
				  	   
 		DbSkip()
 		End
		
		nVezes++
	
	EndIf	


/******
* Carrega o vetor conforme a condicao |
******/
If nTp==2

   oLbx:SetArray(aVetor)
   oLbx:bLine := bLine  
   oLbx:GoBottom()
   oLbx:Refresh()
   oTimer:Activate()

Endif





Return               

                    
