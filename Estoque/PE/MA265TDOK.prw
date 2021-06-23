#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.ch'

//�����������������������������������������������������������������������������
//�����������������������������������������������������������������������������
//�������������������������������������������������������������������������ͻ��
//���Programa  �MA265TDOK �Autor  �WILLIAM COSTA       � Data �  08/05/2018 ���
//�������������������������������������������������������������������������͹��
//���Desc.     � Ponto de entrada para tratar a validacao dos campos de     ���
//���          � enderecar produtos MATA265                                 ���
//�������������������������������������������������������������������������͹��
//���Uso       � SIGAEST                                                    ���
//�������������������������������������������������������������������������ͼ��
//�����������������������������������������������������������������������������


USER FUNCTION MA265TDOK()
	
	Local lRet        := .T.
	Local nCont       := 0
	Local nPosLocaliz := 0
	Local nPosData    := 0
	Local nEstorno    := 0
	
	nPosLocaliz := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_LOCALIZ" } )
	nPosData    := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_DATA" 	 } )
	nEstorno    := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_ESTORNO" } )
	
	FOR nCont:=1 TO LEN(aCols)
	
		IF aCols[nCont][nEstorno] <> 'S' //Regra para validar somente a linha que n�o tem estorno
		
			//Regra para a filial 02 local 02
			IF FWFILIAL("SDA")       == '02' .AND. ;
			   !(ALLTRIM(M->DA_LOCAL) $ GETMV("MV_#ARMEXC",,'03')) // Locais para n�o entrar nessa valida��o
			
				IF aCols[nCont][nPosLocaliz] <> Posicione("SBE",10,xFilial("SBE")+M->DA_PRODUTO+M->DA_LOCAL,"BE_LOCALIZ")
				   
				    MsgStop("OL� " + Alltrim(cUserName) + ", o endere�o n�o est� correto, favor verificar", "MA265TDOK-01 - VALIDA ENDERE�AMENTO")
					lRet        := .F.
					
				ENDIF
			ENDIF
			
			IF aCols[nCont][nPosData] <> M->DA_DATA   
			
				MsgStop("OL� " + Alltrim(cUserName) + ", S� � permitido endere�ar produto com a mesma data da entrada", "MA265TDOK-02 - VALIDA ENDERE�AMENTO")
				lRet        := .F.
				
			ENDIF
		ENDIF
	NEXT

RETURN(lRet)