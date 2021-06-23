#include "rwmake.ch"

/*{Protheus.doc} User Function REDEACLC
	Programa para atualizacao dos campos A1_LCREDE e A1_SLDREDE Estes campos se referem respectivamente a Limite de Credito e Saldo da "Rede" (todas as lojas de um mesmo CNPJ)
	@type  Function
	@author Rogerio Nutti
	@since 30/01/2002
	@version 01
	@history Chamado 056381 - William Costa - 17/03/2020 - Adicionado log em todos os reclock do campo ZF_LCREDE para descobrir seu valor antes e depois 
*/

User Function REDEACLC()       

        U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para atualizacao dos campos A1_LCREDE e A1_SLDREDE')

        SetPrvt("_CALI,_NORD,_NREC,")

        //Montagem da tela pra receber os dados preliminares                  

        @ 200,51 TO 380,380 DIALOG oDlg1 TITLE "Atencao "
        @ 30,010 SAY "Esta rotina executa a atualizacao dos Saldos e Limites de "
        @ 40,010 SAY "Credito para as redes de lojas. "
        @ 75,040 BMPBUTTON TYPE 01 ACTION Continua()
        @ 75,095 BMPBUTTON TYPE 02 ACTION Close(oDlg1)
        ACTIVATE DIALOG oDlg1 CENTERED

Return()


Static Function Continua()

        #IFDEF WINDOWS
                Close(oDlg1)
        #ENDIF

        //Processamento do SA1                                                

        _cCNPJAnt	:=	""
        dbSelectArea("SZF")
        dbSetOrder(1)
        dbgotop()

        Processa( {|| RunCont()},"Aguarde ..." )

Return

Static Function RunCont()

        ProcRegua(RecCount())

        Do While !Eof()
                
                IncProc("Processando: "+SZF->ZF_REDE+", Matriz CNPJ: "+SZF->ZF_CGCMAT)
                // ALTERADO POR HERALDO 24/04/2003
                // SE FOR MESMO CGC ELE NAO CALCULA MAIS
                If _cCNPJAnt	!=	SZF->ZF_CGCMAT
                        _cCNPJAnt	:=	SZF->ZF_CGCMAT
                Else

                u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 1","FINANCEIRO","REDEACLC",;
                                        "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(0),ComputerName(),LogUserName())

                RecLock("SZF",.F.)
                Replace ZF_LCREDE  With 0
                Replace ZF_SLDREDE With 0
                MsUnlock()
                        Dbskip()
                        Loop
                Endif
                _nMaiorLC := 0
                _nSldRede := 0
                
                // Identifica se ‚ cosinha Industrial
                

                IF SZF->ZF_COZINDL !="S"

                        // Posiciona o primeiro cliente da rede e verifica todos pelo CNPJ
                        
                        dbSelectArea("SA1")
                        dbSetOrder(3)

                        If dbSeek( xFilial("SA1") + SZF->ZF_CGCMAT )

                                Do While !Eof() .and. SA1->A1_FILIAL        == xFilial("SA1") .and. ;
                                                Subs(SA1->A1_CGC,1,8) == SZF->ZF_CGCMAT

                                        // Verifica qual o maior Limit Cred   
                                        
                                        If SA1->A1_LC > _nMaiorLC

                                                _nMaiorLC := SA1->A1_LC
                                        Endif

                                        //Verifica e acumula o saldo dos clientes da rede   
                                        
                                        dbSelectArea("SE1")
                                        dbSetOrder(8)
                                        If dbSeek( xFilial("SE1") + SA1->A1_COD + SA1->A1_LOJA )

                                                Do While !Eof() .and. SA1->A1_COD==SE1->E1_CLIENTE .and.;
                                                SA1->A1_LOJA==SE1->E1_LOJA

                                                        // despreza provisorios
                                                        If Alltrim(SE1->E1_TIPO) == "PR"
                                                                dbSelectArea("SE1")
                                                                dbSkip()
                                                                Loop
                                                        Endif

                                                        // Se RA ou NCC, ou abatimentos subtrai
                                                        If Alltrim(SE1->E1_TIPO) $ "RA/NCC" .or. Subs(SE1->E1_TIPO,1,3)=="-"
                                                                _nSldRede := _nSldRede - SE1->E1_SALDO
                                                        Else
                                                                _nSldRede := _nSldRede + SE1->E1_SALDO
                                                        Endif

                                                        dbSelectArea("SE1")
                                                        dbSkip()
                                                Enddo

                                        Endif

                                        dbSelectArea("SA1")
                                        dbSkip()
                                Enddo

                        Endif
                        dbSelectArea("SZF")

                        u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 2","FINANCEIRO","REDEACLC",;
                                        "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(_nMaiorLC),ComputerName(),LogUserName())

                        RecLock("SZF",.F.)
                        Replace ZF_LCREDE  With _nMaiorLC
                        Replace ZF_SLDREDE With _nSldRede
                        MsUnlock()
                ELSE

                        //Posiciona o primeiro cliente da cozinha e verifica todos pelo CNPJ        
                        
                        dbSelectArea("SA1")
                        dbSetOrder(6)

                        If dbSeek( xFilial("SA1") + SZF->ZF_CGCMAT )

                                Do While !Eof() .and. SA1->A1_FILIAL           == xFilial("SA1") .and. ;
                                                Subs(SA1->A1_CGCENT,1,8) == SZF->ZF_CGCMAT

                                        // Verifica qual o maior Limit Cred   
                                        
                                        If SA1->A1_LC > _nMaiorLC
                                                _nMaiorLC := SA1->A1_LC
                                        Endif

                                        // Verifica e acumula o saldo dos clientes da rede   
                                        
                                        dbSelectArea("SE1")
                                        dbSetOrder(8)

                                        If dbSeek( xFilial("SE1") + SA1->A1_COD + SA1->A1_LOJA )

                                                Do While !Eof() .and. SA1->A1_COD==SE1->E1_CLIENTE .and.;
                                                                SA1->A1_LOJA==SE1->E1_LOJA

                                                        // despreza provisorios

                                                        If Alltrim(SE1->E1_TIPO) == "PR"
                                                                dbSelectArea("SE1")
                                                                dbSkip()
                                                                Loop
                                                        Endif

                                                        // Se RA ou NCC, ou abatimentos subtrai

                                                        If Alltrim(SE1->E1_TIPO) $ "RA/NCC" .or. Subs(SE1->E1_TIPO,1,3)=="-"
                                                                _nSldRede := _nSldRede - SE1->E1_SALDO
                                                        Else
                                                                _nSldRede := _nSldRede + SE1->E1_SALDO
                                                        Endif

                                                        dbSelectArea("SE1")
                                                        dbSkip()
                                                Enddo

                                        Endif

                                        dbSelectArea("SA1")
                                        dbSkip()
                                Enddo

                        Endif

                        dbSelectArea("SZF")

                        u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE MENSAGEM 3","FINANCEIRO","REDEACLC",;
                                        "CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(_nMaiorLC),ComputerName(),LogUserName())

                        RecLock("SZF",.F.)
                        Replace ZF_LCREDE  With _nMaiorLC
                        Replace ZF_SLDREDE With _nSldRede
                        MsUnlock()
                endif

                dbSelectArea("SZF")
                dbSkip()
                
        Enddo

Return