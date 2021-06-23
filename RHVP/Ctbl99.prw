#Include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLctoDeb  �Autor  � Adilson Silva      � Data � 01/04/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca Conta Debito.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���   DATA   � Programador   � Manutencao efetuada                        ���
�������������������������������������������������������������������������͹��
���03/01/2019�Adriana        �046184 || OS 047367 || CONTABILIDADE        ���
���          �               �GERENCIAL|| MONIK|| Correcao contabilizacao ��� 
���          �               �dos lancamentos de 13o                      ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FLCTODEB()

	Local cConta := Space(20)
	 
	U_ADINF009P('CTBL99' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	 
	/* Desabilitado por Adriana em 03/01/2019
	//by Isamu, para tratar verbas pagas na Folha e 13o
	If Srz->Rz_PD $ "106/115/117/208" .and. Srz->Rz_Tipo == "13"
	   cConta := "211710006"
	Endif
	               
	If !(Srz->Rz_PD $ "106/115/117/208") .and. !(Srz->Rz_Tipo == "13") .or.;
	    (Srz->Rz_PD $ "106/115/117/208") .and. !(Srz->Rz_Tipo == "13")
	
	   If SRV->(dbSeek( xFilial("SRV") + SRZ->RZ_PD )) 
	      cConta := SRV->RV_DEBITO
	   EndIf
	 
	Endif
	*/
	 
	If Srz->Rz_PD $ "106/115/117/208" .and. Srz->Rz_Tipo == "13" // por Adriana em 03/01/2019 
	    cConta := "211710006"
	Else
	    If SRV->(dbSeek( xFilial("SRV") + SRZ->RZ_PD )) 
	       cConta := SRV->RV_DEBITO
	    EndIf
	Endif    
       
Return( cConta )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fLctoCre  �Autor  � Adilson Silva      � Data � 01/04/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca Conta Credito.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���   DATA   � Programador   � Manutencao efetuada                        ���
�������������������������������������������������������������������������͹��
���03/01/2019�Adriana        �046184 || OS 047367 || CONTABILIDADE        ���
���          �               �GERENCIAL|| MONIK|| Correcao contabilizacao ��� 
���          �               �dos lancamentos de 13o                      ���
�������������������������������������������������������������������������͹��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FLCTOCRE()

	Local cConta := Space(20)

	U_ADINF009P('CTBL99' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	 
	/* Desabilitado por Adriana em 03/01/2019
	//by Isamu, para tratar verbas pagas na Folha e 13o
	If Srz->Rz_PD $ "106/115/117/208" .and. Srz->Rz_Tipo == "13"
	   cConta := "191110010"           
	Endif
	
	If !(Srz->Rz_PD $ "106/115/117/208") .and. !(Srz->Rz_Tipo == "13") .or.;
	   (Srz->Rz_PD $ "106/115/117/208") .and. !(Srz->Rz_Tipo == "13")
	   If SRV->(dbSeek( xFilial("SRV") + SRZ->RZ_PD ))
	      cConta := SRV->RV_CREDIT
	   EndIf
	 
	Endif
	*/
	
	If Srz->Rz_PD $ "106/115/117/208" .and. Srz->Rz_Tipo == "13" // por Adriana em 03/01/2019 
	   cConta := "191110010"           
	Else
	   If SRV->(dbSeek( xFilial("SRV") + SRZ->RZ_PD ))
	      cConta := SRV->RV_CREDIT
	   EndIf
	 
	Endif
  
Return( cConta )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCcDeb    �Autor  � Adilson Silva      � Data � 01/04/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca Centro de Custo Debito.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FCCDEB()

	Local cConta    := Space(20)
	Local cCusto    := Space(09)

	U_ADINF009P('CTBL99' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If SRV->(dbSeek( xFilial("SRV") + SRZ->RZ_PD ))
	   cConta := SRV->RV_DEBITO
	EndIf
	 
	If !( Left(cConta,1) $ "12" )
	   cCusto := SRZ->RZ_CC
	EndIf
 
Return( cCusto )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCcCre    �Autor  � Adilson Silva      � Data � 01/04/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca Centro de Custo Debito.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FCCCRED()

	Local cConta    := Space(20)
	Local cCusto    := Space(09)

	U_ADINF009P('CTBL99' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Busca Conta Debito.')
	
	If SRV->(dbSeek( xFilial("SRV") + SRZ->RZ_PD ))
	   cConta := SRV->RV_CREDIT
	EndIf
	 
	If !( Left(cConta,1) $ "12" )
	   cCusto := SRZ->RZ_CC
	EndIf
 
Return( cCusto )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fItemCtb  �Autor  � Adilson Silva      � Data � 01/04/2005  ���
�������������������������������������������������������������������������͹��
���Desc.     � Busca Item Contabil.                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FITEMCTB()

	Local aOld     := GETAREA()
	Local cVarMv   := "MV_ITCB" + SRZ->RZ_FILIAL
	Local cItemCtb := Space( 09 )

	U_ADINF009P('CTBL99' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Busca Conta Debito.')
	
	cItemCtb := GETMV( cVarMv )
	
	ZZ4->(dbSetOrder( 1 ))
	If ZZ4->(dbSeek( xFilial("ZZ4") + SRZ->RZ_CC + SRZ->RZ_FILIAL ))
	   cItemCtb := ZZ4->ZZ4_ITEM
	EndIf
	
	RESTAREA( aOld )
 
Return( cItemCtb )
