#Include "Protheus.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ADGetSX5 � Autor � Celso Costa - HCConsys� Data � 15/10/09 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza Numeracao de Nota Fiscal ( SX5 )                  ���
�������������|�����������������������������������������������������������Ĵ��
���Sintaxe   � ADGetSX5                                                   ���
�������������|�����������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ADGetSX5()

Local _cNumSX5 := ""
Local _lVal    := .F.
Local _aSX5Num		:= {}
Local _cAliasSF1	:= ""
Local _cAliasSF2	:= ""
Local _cSerNF     := "01 " 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Atualiza Numeracao de Nota Fiscal ( SX5 )')

if cempant == "01" .and. cfilant == "03"

   //��������������������������������������������������������������Ŀ
   //� Posiciona SX5                                                �
   //����������������������������������������������������������������
   dbSelectArea( "SX5" )
   SX5->( dbSetOrder( 01 ) )

   If !SX5->( dbSeek( xFilial( "SX5" ) + "01" + "01" ) )
	   MsgStop( "Registro nao encontrado", "Atencao" )
	   Return ( Nil )
   EndIf

   _cNumSX5 := RetAsc( SX5->X5_DESCRI, 09, .T. )

   //��������������������������������������������������������������Ŀ
   //� Get do Novo Conteudo                                         �
   //����������������������������������������������������������������
   If MsgGet2( "Informe o numero da proxima Nota Fiscal a ser gerada", "Nota Fiscal: ",@_cNumSX5 )

      &&valida numero da nf digitado Mauricio HC Consys.   
      _cNumDig := RetAsc( _cNumSX5, 09, .T. )
      _cAliasSF1 := GetNextAlias()

      BeginSql Alias _cAliasSF1
	      SELECT TOP 01 SF1.F1_DOC
	      FROM %Table:SF1% SF1
	      WHERE SF1.F1_FILIAL = %xFilial:SF1%
	      AND SF1.F1_FORMUL = %Exp:'S'%
	      AND SF1.F1_SERIE = %Exp:_cSerNF%
	      AND SF1.F1_ESPECIE = %Exp:'SPED'%
	      AND LEN(SF1.F1_DOC) > 6
	      ORDER BY SF1.F1_DOC DESC
      EndSql					

      While ( _cAliasSF1 )->( !Eof() )

	         aAdd( _aSX5Num, ( _cAliasSF1 )->F1_DOC )
	
	        ( _cAliasSF1 )->( dbSkip() )
	
      EndDo

      ( _cAliasSF1 )->( dbCloseArea() )

      //��������������������������������������������������������������Ŀ
      //� Sequencia de Notas de Saida                                  �
      //����������������������������������������������������������������
      _cAliasSF2 := GetNextAlias()

      BeginSql Alias _cAliasSF2
	      SELECT TOP 01 SF2.F2_DOC
	      FROM %Table:SF2% SF2
	      WHERE SF2.F2_FILIAL = %xFilial:SF2%
	      AND SF2.F2_SERIE = %Exp:_cSerNF%
	      AND SF2.F2_ESPECIE = %Exp:'SPED'%
		  AND SF2.F2_EMISSAO > %Exp:'20100201'% // ALTERADO POR HCCONSYS EM 23/10/09 PARA desprezar notas emitidas com data anterior, pois existem
	      AND LEN(SF2.F2_DOC) > 6
	      ORDER BY SF2.F2_DOC DESC
      EndSql					

      While ( _cAliasSF2 )->( !Eof() )

	         aAdd( _aSX5Num, ( _cAliasSF2 )->F2_DOC )
	
	         ( _cAliasSF2 )->( dbSkip() )
	
      EndDo

      ( _cAliasSF2 )->( dbCloseArea() )

      //��������������������������������������������������������������Ŀ
      //� Indexa Array de sequencia de numeracao                       �
      //����������������������������������������������������������������
      aSort( _aSX5Num )

      //��������������������������������������������������������������Ŀ
      //� Valida sequencial de numeracao                               �
      //����������������������������������������������������������������
      If Len( _aSX5Num ) > 00

	      if _cNumDig <= AllTrim( _aSX5Num[ Len( _aSX5Num ) ] )
            _lVal := .T.   
         elseif _cNumDig > Soma1(AllTrim( _aSX5Num[ Len( _aSX5Num ) ] ))
            _lVal := .T.
         endif
   
      EndIf
   
      //��������������������������������������������������������������Ŀ
      //� Atualiza SX5                                                 �
      //����������������������������������������������������������������
      if _lVal == .F.
         RecLock( "SX5", .F. )
            SX5->X5_DESCRI		:= RetAsc( _cNumSX5, 09, .T. )
            SX5->X5_DESCSPA	:= RetAsc( _cNumSX5, 09, .T. )
            SX5->X5_DESCENG	:= RetAsc( _cNumSX5, 09, .T. )
         SX5->( MsUnLock() )
      else
         MsgStop( "O numero da NF informado nao eh o correto para a sequencia de numeracao" , "ADGETSX5" )
      endif   
   EndIf
else
   MsgAlert("Esta rotina e somente para Adoro Filial Sao Carlos!!!")
endif   

Return ( Nil )