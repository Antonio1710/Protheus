#INCLUDE "PROTHEUS.CH"     
#INCLUDE "RWMAKE.CH"
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FI040ROT  �Autor  �Adriana Oliveira �    Data �  11/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE para incluir op��o RECEBIDO para titulos gerados pelo   ���
���          � m�dulo de Exporta��o                                       ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/
User Function FI040ROT()

Local _aRotina := PARAMIXB

If Alltrim(cEmpAnt) == "01" //Apenas se empresa 01-Adoro  //Incluido por Adriana em 02/12/2015
	If __cUserID $ GETMV("MV_#USUREC")   &&usuario com permissao para marcar recebido no titulo Exportacao
		aAdd( _aRotina, {"Recebido Tit.Exp.", "U_RECEEC()", 0, 7}) 
	Endif                                                                        
Endif


If Alltrim(cEmpAnt) == "01" 
	If __cUserID $ GETMV("MV_#USUVNC")   &&usuario com permissao aletrar data de vencimento dos titulos de Exporta��o EEC
		aAdd( _aRotina, {"Alt.Venc Tit.Exp.", "U_ALTVENC()", 0, 7}) 
	Endif                                                                        
Endif


Return _aRotina


/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RecEEC    �Autor  �Adriana Oliveira �    Data �  11/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para grava��o do campo E1_RECEEC                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/
User Function ALTVENC()

Local dDtVencLot  := SE1->E1_VENCREA 
Local dDtVencOld  := SE1->E1_VENCREA    
Local nOpc        := 0         
//
Local oBntProcessar
Local oBntCancelar
Local oData
Local oSay1
Local oTlDtProcVnct
  

If Alltrim(SE1->E1_ORIGEM) <> "SIGAEEC"   //se titulo n�o foi gerado pelo m�dulo de Exporta��o nao deixa elterar a data de vencimento
	
	Aviso( "Aviso",OemToAnsi("T�tulo n�o foi gerado pelo SIGAEEC. Altera��o Nao permitida!"),{"Sair"} )
	Return
	
Endif

	Define MsDialog oTlDtProcVnct Title "Titulo Exporta��o" From 000, 000  To 145, 240 COLORS 0, 16777215 Pixel Style 128

    @ 007, 025 Say oSay1 Prompt "Por favor, informe a data de vencimento." Size 108, 012 Of oTlDtProcVnct COLORS 0, 16777215 Pixel
    @ 026, 035 MsGet oData Var dDtVencLot Size 060, 010 Of oTlDtProcVnct COLORS 0, 16777215 Pixel
    
    @ 050, 008 Button oBntProcessar Prompt "Ok"        Size 044, 011  Of oTlDtProcVnct Pixel Action(nOpc:=1,oTlDtProcVnct:End())
    @ 050, 072 Button oBntCancelar  Prompt "Cancelar"  Size 044, 011  Of oTlDtProcVnct Pixel Action(oTlDtProcVnct:End())

  	Activate MsDialog oTlDtProcVnct Centered
	
	If nOpc = 1

		If Reclock("SE1",.F.)
			SE1->E1_VENCTO  := dDtVencLot
			SE1->E1_VENCREA := dDtVencLot
	    	SE1->E1_VENCORI := dDtVencLot
			MsUnlock()
		EndIf
		
		//grava log das altera�oes de vcnto do titulo de exporta��o
		u_GrLogZBE (Date(),TIME(),cUserName," ALTERAR VNCTO EEC "," FINANCEIRO","FI040ROT ",;
 	                            "TITULO EEC: "+SE1->E1_NUM+" VCNTO DE "+ DTOC(dDtVencOld)+ " VCNTO PARA: " + DTOC(dDtVencLot) ,ComputerName(),LogUserName()) 
		
		
		Aviso( "Aviso",OemToAnsi("Data de Vencimento Alterado do Titulo "+SE1->E1_NUM),{"Sair"} )
	
	Else
	
		MsgAlert(" Processo Cancelado ")
		
	EndIf
	


Return
/* 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RecEEC    �Autor  �Adriana Oliveira �    Data �  11/11/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para grava��o do campo E1_RECEEC                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFIN                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/
User Function RecEEC()
                                                                        
If Alltrim(SE1->E1_ORIGEM) <> "SIGAEEC"   //se titulo n�o foi gerado pelo m�dulo de Exporta��o, questiona, mas n�o impede
	If !MsgBox("T�tulo n�o foi gerado pelo SIGAEEC, confirma?","CONFIRMA��O","YESNO")
		Return
	Endif
endif

If !MsgBox("T�tulo "+iif(SE1->E1_RECEEC="S","J� marcado","N�O marcado")+" como Recebido, "+iif(SE1->E1_RECEEC="S","apaga marca��o "," confirma marca��o ")+"?","CONFIRMA��O","YESNO") 
	Return 
else
	If Reclock("SE1",.F.)
		SE1->E1_RECEEC := iif(SE1->E1_RECEEC="S"," ","S") // se estiver com Sim, limpa, se estiver limpo, grava S (sim)
		MsUnlock()
	Endif
Endif
	
Return