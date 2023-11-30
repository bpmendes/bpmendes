create or replace FUNCTION Obter_resp_analise_apo2(nr_prescricao_p   IN prescr_medica.nr_prescricao%TYPE,
                                                  ie_tipo_usuario_p  IN VARCHAR2,
                                                  ie_registro_p      IN VARCHAR2)
RETURN VARCHAR2
IS
  /*
  U : Usuario responsavel analise
  NM: Nome responsavel analise
  */
  nm_compl_resp_analise_w   VARCHAR2(255);
  nm_usuario_resp_analise_w VARCHAR2(15);
  nm_retorno_w              VARCHAR2(255);
BEGIN
    if (ie_tipo_usuario_p = 'F') then
        select max(NM_USUARIO_ANALISE_FARM),
            max(obter_nome_usuario(NM_USUARIO_ANALISE_FARM))
        into nm_usuario_resp_analise_w,
            nm_compl_resp_analise_w
        from prescr_medica
        where nr_prescricao = nr_prescricao_p;
    elsif (ie_tipo_usuario_p = 'E') then
        select max(a.NM_USUARIO_ANALISE_ENF),
            max(obter_nome_usuario(a.NM_USUARIO_ANALISE_ENF))
        into nm_usuario_resp_analise_w,
            nm_compl_resp_analise_w
        from prescr_medica_compl a
        where a.nr_prescricao = nr_prescricao_p;
    end if;

    IF( nm_compl_resp_analise_w IS NOT NULL )
      AND ( ie_registro_p = 'NM' ) THEN
      nm_retorno_w := nm_compl_resp_analise_w;
    ELSIF( nm_usuario_resp_analise_w IS NOT NULL )
         AND ( ie_registro_p = 'U' ) THEN
      nm_retorno_w := nm_usuario_resp_analise_w;
    END IF;

    RETURN nm_retorno_w;
END obter_resp_analise_apo2;