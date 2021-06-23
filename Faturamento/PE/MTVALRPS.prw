//��������������������������������������������������������������Ŀ
//� Includes/Defines                                             �
//����������������������������������������������������������������
#Include "Protheus.CH"  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MTVALRPS   � Autor � HCConsys - Celso    � Data �14/10/2009���
�������������������������������������������������������������������������Ĵ��
���Descricao � Validacao do numero de nota fiscal de saida                ���
�������������|�����������������������������������������������������������Ĵ��
���Uso       � Especifico Adoro                                           ���
�������������|�����������������������������������������������������������Ĵ��
���Parametros�                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MTVALRPS()

//��������������������������������������������������������������Ŀ
//� Variaveis Locais                                             �
//����������������������������������������������������������������
Local _aArea		:= GetArea()
Local _aSX5Num		:= {}
Local _cAliasSF1	:= ""
Local _cAliasSF2	:= ""
Local _lRet			:= .T. 

//��������������������������������������������������������������Ŀ
//� Variaveis Publicas                                           �
//����������������������������������������������������������������
Public _lVldNFAD


if cEmpant == "01" .AND. cfilant == "03"
   //��������������������������������������������������������������Ŀ
   //� Valida usuario                                               �
   //����������������������������������������������������������������
   If AllTrim( Upper( PswRet( 01 )[ 01 ][ 02 ] ) ) == "BALANCA/SC"
	   Return ( .T. )
   EndIf	

   //��������������������������������������������������������������Ŀ
   //� Validacoes                                                   �
   //����������������������������������������������������������������
   If ValType( _lVldNFAD ) != "U"
	   If _lVldNFAD
		   Return ( .T. )
	   EndIf
   EndIf

   //��������������������������������������������������������������Ŀ
   //� Sequencia de Notas de Entrada - Formulario proprio = "S"     �
   //����������������������������������������������������������������
   _cAliasSF1 := GetNextAlias()

   /*
   BeginSql Alias _cAliasSF1
	   SELECT TOP 01 SF1.F1_DOC
	   FROM %Table:SF1% SF1
	   WHERE SF1.F1_FILIAL = %xFilial:SF1%
	   AND SF1.F1_FORMUL = %Exp:'S'%
	   AND SF1.F1_SERIE = %Exp:ParamIxb[ 01 ]%
	   AND SF1.F1_ESPECIE = %Exp:'SPED'%
	   ORDER BY SUBSTRING (SF1.F1_DOC,7,4) DESC
   EndSql					
   */                       
   //ALTERADO LEONARDO (HC) PARA CONTEMPLAR NOTAS COM MAIS DE 6 CARACTERES
   BeginSql Alias _cAliasSF1
	   SELECT TOP 01 SF1.F1_DOC
	   FROM %Table:SF1% SF1
	   WHERE SF1.F1_FILIAL = %xFilial:SF1%
	   AND SF1.F1_FORMUL = %Exp:'S'%
	   AND SF1.F1_SERIE = %Exp:ParamIxb[ 01 ]%
	   AND SF1.F1_ESPECIE = %Exp:'SPED'%
	   AND LEN(SF1.F1_DOC) > 6
	   ORDER BY F1_DOC DESC
   EndSql					

   While ( _cAliasSF1 )->( !Eof() )      
	     aAdd( _aSX5Num, (_cAliasSF1)->F1_DOC)
	      ( _cAliasSF1 )->( dbSkip() )
   EndDo

   ( _cAliasSF1 )->( dbCloseArea() )

   //��������������������������������������������������������������Ŀ
   //� Sequencia de Notas de Saida                                  �
   //����������������������������������������������������������������
   _cAliasSF2 := GetNextAlias()

   BeginSql Alias _cAliasSF2

// ALTERADO POR HCCONSYS EM 23/02/2010, pois nao estava trazendo o ultimo numero corretamente. 

//	   SELECT TOP 01 SF2.F2_DOC
//	   FROM %Table:SF2% SF2
//	   WHERE SF2.F2_FILIAL = %xFilial:SF2%
//	   AND SF2.F2_SERIE = %Exp:ParamIxb[ 01 ]%
//	   AND SF2.F2_ESPECIE = %Exp:'SPED'%
//	   AND SF2.F2_EMISSAO > %Exp:'20100201'% // ALTERADO POR HCCONSYS EM 23/10/09 PARA desprezar notas emitidas com data anterior, pois existem
//	   ORDER BY SUBSTRING (SF2.F2_DOC,7,4) DESC //Eduardo Ordena de acordo com o numero da nota 9 dig.
	   

		SELECT TOP 01 SF2.F2_DOC
		FROM %Table:SF2% SF2
		WHERE SF2.F2_FILIAL = %xFilial:SF2%
		AND SF2.F2_SERIE = %Exp:ParamIxb[ 01 ]%
		AND SF2.F2_ESPECIE = %Exp:'SPED'%
		AND SF2.F2_EMISSAO > %Exp:'20100201'% // ALTERADO POR HCCONSYS EM 23/10/09 PARA desprezar notas emitidas com data anterior, pois existem
		// notas com 6 digitos 
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
   If Len( _aSX5Num ) > 00  //Numero de Itens

	   dbSelectArea( "SX5" )
	   SX5->( dbSetOrder( 01 ) )

	   If SX5->( dbSeek( xFilial( "SX5" ) + "01" + ParamIxb[ 01 ] ) ) .And. RetAsc( ( Val( SX5->X5_DESCRI ) - 01 ), 09, .T. ) > AllTrim( _aSX5Num[ Len( _aSX5Num ) ] ) //Alterado de 6 para 9 digitos de acordo com o numero da nota. Eduardo.
		   MsgStop( "Existem divergencias no sequencial de numeracao de Notas Fiscais, ultima NF gerada " + AllTrim( _aSX5Num[ Len( _aSX5Num ) ] ) + " e sequencial " + AllTrim( SX5->X5_DESCRI ), "MTVALRPS" )
		   _lRet := .F.
	   EndIf

   EndIf

endif

Return ( _lRet )