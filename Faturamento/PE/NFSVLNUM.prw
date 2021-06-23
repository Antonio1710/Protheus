//��������������������������������������������������������������Ŀ
//� Includes/Defines                                             �
//����������������������������������������������������������������
#Include "Protheus.CH"  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � NFSVLNUM   � Autor � HCConsys - Celso    � Data �14/10/2009���
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
User Function NFSVLNUM()

//��������������������������������������������������������������Ŀ
//� Variaveis Locais                                             �
//����������������������������������������������������������������
Local _aArea		:= GetArea()
Local _aSX5Num		:= {}
Local _cAliasSF1	:= ""
Local _cAliasSF2	:= ""
Local _lRet			:= .T. 

if cEmpant == "01" .AND. cfilant == "03"

   //��������������������������������������������������������������Ŀ
   //� Valida usuario                                               �
   //����������������������������������������������������������������
   If AllTrim( Upper( PswRet( 01 )[ 01 ][ 02 ] ) ) == "BALANCA/SC"
	   MsgStop( "Usuario sem permissao para alteracao do Numero de Nota Fiscal", "NFSVLNUM" )
	   Return ( .F. )
   EndIf	

   //��������������������������������������������������������������Ŀ
   //� Variaveis Publicas                                           �
   //����������������������������������������������������������������
   Public _lVldNFAD

   //��������������������������������������������������������������Ŀ
   //� Sequencia de Notas de Entrada - Formulario proprio = "S"     �
   //����������������������������������������������������������������
   _cAliasSF1 := GetNextAlias()

   BeginSql Alias _cAliasSF1
	   SELECT TOP 01 SF1.F1_DOC
	   FROM %Table:SF1% SF1
	   WHERE SF1.F1_FILIAL = %xFilial:SF1%
	   AND SF1.F1_FORMUL = %Exp:'S'%
	   AND SF1.F1_SERIE = %Exp:ParamIxb[ 02 ]%
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
	   AND SF2.F2_SERIE = %Exp:ParamIxb[ 02 ]%
	   AND SF2.F2_ESPECIE = %Exp:'SPED'%
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

	   If RetAsc( ( Val( ParamIxb[ 01 ] ) - 01 ), 06, .T. ) > AllTrim( _aSX5Num[ Len( _aSX5Num ) ] )
		   _lRet := MsgStop( "Existem divergencias no sequencial de numeracao de Notas Fiscais, ultima NF gerada " + AllTrim( _aSX5Num[ Len( _aSX5Num ) ] ) + " e sequencial " + AllTrim( ParamIxb[ 01 ] ), "NFSVLNUM" )
		   _lRet			:= .F.
		   _lVldNFAD	:= .F.
	   Else
		  _lVldNFAD	:= .T.
	   EndIf

   EndIf
endif
Return ( _lRet )