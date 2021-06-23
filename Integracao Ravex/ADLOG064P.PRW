#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH"  

/*/{Protheus.doc} User Function ADLOG064P U_ADLOG064P()
    Programa gera viagem faturada manual do ravex.
    Chamado 12287
    @type  Function
    @author WILLIAM COSTA
    @since 09/10/2019
    @version 01
	@history ticket T.I - Fernando Macieira - 28/04/2021 - Validação da tabela de frete cadastrado no veículo. Alerta o executor que as Nfe não serão entregues devido a falta da tabela de preço.
/*/
USER FUNCTION ADLOG064P()

	Private cPerg      	:= 'ADLOG064P'
	Private oDtEntrega 	:= NIL
	Private cDtEntrega 	:= SPACE(10)
	Private oRoteiro   	:= NIL
	Private cRoteiro   	:= SPACE(03)
	Private nOpcao     	:= 0
	Private oDlg       	:= NIL
	Private cDtFat     	:= ''
	Private cRotFat    	:= ''
	Private lDtFat     	:= .T.
	Private lRotFat    	:= .T.
	Private lTabFre		:= .T.
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "ADLOG064P - Gera Viagem Fatura Manual" 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa gera viagem faturada manual do ravex')

	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de gerar manualmente " )
	AADD(aSays,"Viagem Faturada" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| o:oWnd:End(), Processa({||GERA_ADLOG064P()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  

RETURN(NIL)

STATIC FUNCTION GERA_ADLOG064P()

    IF MV_PAR01 == 2 // SIM

    	u_ADLOG003P()

	ELSE

		nOpcao := 0

		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Informe a Data de Entrega e o Roteiro que deseja reenviar") From 100,0 To 200,400 PIXEL
			
			@ 03,020 SAY   "Data de Entrega:"                             SIZE 070,007 OF oDlg PIXEL
			@ 03,080 MSGet oDtEntrega VAR cDtEntrega PICTURE "99/99/9999" SIZE 050,010 OF oDlg PIXEL

			@ 18,020 SAY   "Roteiro:"	                                  SIZE 070,007 OF oDlg PIXEL
			@ 18,080 MSGet oRoteiro VAR cRoteiro     PICTURE '999'        SIZE 020,010 OF oDlg PIXEL
			
			DEFINE SBUTTON FROM 38,050 TYPE 1 ACTION (nOpcao:=1, oDlg:End()) ENABLE OF oDlg PIXEL
			DEFINE SBUTTON FROM 38,100 TYPE 2 ACTION ( oDlg:End()) ENABLE OF oDlg PIXEL

		ACTIVATE MSDIALOG  oDlg CENTERED

		IF nOpcao == 1               .AND. ; 
		   ALLTRIM(cDtEntrega) <> '' .AND. ;
		   ALLTRIM(cRoteiro)   <> '' 

			SqlRAVEXFAT(DTOS(CTOD(cDtEntrega)),cRoteiro)
			DBSELECTAREA("TRB")
 			TRB->(DBGOTOP())

			cDtFat     := TRB->F2_EMISSAO
			cRotFat    := TRB->F2_ROTEIRO
			lDtFat     := .T.
			lRotFat    := .T.

			While TRB->(!EOF()) 
			
				// inicio Verifica a data de faturamento se é tudo igual

				IF lDtFat == .T.

					IF cDtFat <> TRB->F2_EMISSAO

						lDtFat :=  .F.

					ENDIF

				ENDIF

				// final Verifica a data de faturamento se é tudo igual

				// inicio Verifica o roteiro se é tudo igual

				IF lRotFat == .T.

					IF cRotFat <> TRB->F2_ROTEIRO

						lRotFat :=  .F.

					ENDIF

				ENDIF

				if lTabFre == .T.
					if Empty(TRB->ZV4_XFRET)
						lTabFre := .F.
						msgalert("O veículo placa '"+ TRB->C5_PLACA +"' não possui tabela de frete cadastada!")
					endif
				endif

				// final Verifica o roteiro se é tudo igual	
	
				TRB->(dbSkip())
						
			ENDDO
			TRB->(dbCloseArea())

			IF ALLTRIM(cDtFat)  <> ''  .AND. ;
			   ALLTRIM(cRotFat) <> ''  .AND. ;
			   lDtFat           == .T. .AND. ;
			   lRotFat          == .T. .AND. ;
			   lTabFre			== .T.


				SqlRAVEXFAT(DTOS(CTOD(cDtEntrega)),cRoteiro)
				DBSELECTAREA("TRB")
				TRB->(DBGOTOP())
				While TRB->(!EOF()) 

					DBSELECTAREA("SF2")
					DBSETORDER(1)
					IF DBSEEK(TRB->F2_FILIAL+TRB->F2_DOC+TRB->F2_SERIE,.T.)

							Reclock("SF2",.F.)  

								SF2->F2_XRAVEX := .F.

							MsUnlock() 
							
					ELSE

						ALERT("NOTAS NAO ENCONTRADAS ")

					ENDIF
			
					TRB->(dbSkip())
							
				ENDDO
				TRB->(dbCloseArea())

				u_ADLOG003P()

			ENDIF	
			
		ELSE

			ALERT("Feito o Cancelamento")

		ENDIF
    ENDIF 

RETURN(NIL)

Static Function MontaPerg()
    
    U_xPutSX1(cPerg,"01",'Gerar de Todos ?','','',"mv_ch1","N",01,0,01,"C","","","","","MV_PAR01" ,"Não","Não","Não","","Sim","Sim","Sim","","","","","","","",""," ")
    
	Pergunte(cPerg,.F.)
	
Return(Nil)            

STATIC FUNCTION SqlRAVEXFAT(cData,cRot)                          

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT SF2.F2_PLACA,
				   SF2.F2_DOC, 
				   SF2.F2_CHVNFE,
				   SC5.C5_XRAVEX,
				   SF2.F2_XRAVEX,
				   SC5.C5_NOTA,
				   SC5.C5_ROTEIRO,
				   SC5.C5_DTENTR,
				   F2_ROTEIRO,
				   SF2.F2_EMISSAO,
				   F2_HORA,
				   A1_XLONGIT,
				   A1_XLATITU,
				   SF2.F2_FILIAL,
				   SF2.F2_SERIE,
				   ZV4.ZV4_XFRET,
				   SC5.C5_PLACA
			  FROM %Table:SC5% SC5 WITH(NOLOCK), 
			       %Table:SF2% SF2 WITH(NOLOCK),
			       %Table:SA1% SA1 WITH(NOLOCK),
				   %Table:ZV4% ZV4 WITH(NOLOCK)
			 WHERE SC5.C5_DTENTR   = %EXP:cData%
			   AND SC5.C5_ROTEIRO  = %EXP:cRot%
			   AND SC5.C5_FILIAL   = SF2.F2_FILIAL
			   AND SC5.C5_NOTA     = SF2.F2_DOC
			   AND SC5.C5_SERIE    = SF2.F2_SERIE
			   AND SC5.C5_CLIENT   = SF2.F2_CLIENT
			   AND SC5.C5_LOJACLI  = SF2.F2_LOJA
			   AND SC5.C5_PLACA    = ZV4.ZV4_PLACA
			   AND SC5.C5_XRAVEX   = 'T'
			   AND SF2.D_E_L_E_T_ <> '*'
			   AND SA1.A1_COD      = SC5.C5_CLIENTE
			   AND SA1.A1_LOJA     = SC5.C5_LOJACLI
			   AND SA1.D_E_L_E_T_ <> '*'
			   AND ZV4.D_E_L_E_T_ <> '*'
			   AND ISNULL(ZV4.D_E_L_E_T_,'') <> '*'
			ORDER BY C5_ROTEIRO
 			 
	 EndSQl  
	            
RETURN(NIL) 
