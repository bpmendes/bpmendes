create or replace FUNCTION obter_dt_analise_apo2(nr_prescricao_p     IN prescr_medica.nr_prescricao%TYPE,
                                                ie_tipo_usuario_p   IN VARCHAR2,
                                                ie_registro_p       IN VARCHAR2)
RETURN DATE
IS
  /*
  DTI : Data inicio analise
  DTF: Data Fim analise
  */
  dt_inicio_analise_w DATE;
  dt_fim_analise_w    DATE;
  dt_retorno_w        DATE;
BEGIN
    if (ie_tipo_usuario_p = 'F') then
        select max(dt_inicio_analise_farm),
            max(dt_liberacao_farmacia)
        into dt_inicio_analise_w,
            dt_fim_analise_w
        from prescr_medica
        where nr_prescricao = nr_prescricao_p;
    elsif (ie_tipo_usuario_p = 'E') then
        select max(a.dt_inicio_analise_enf),
            max(b.dt_liberacao)
        into dt_inicio_analise_w,
            dt_fim_analise_w
        from prescr_medica_compl a,
            prescr_medica b
        where a.nr_prescricao = b.nr_prescricao
        and a.nr_prescricao = nr_prescricao_p;
    end if;

    IF ( ie_registro_p = 'DTI' ) THEN
      dt_retorno_w := dt_inicio_analise_w;
    ELSIF ( ie_registro_p = 'DTF' ) THEN
      dt_retorno_w := dt_fim_analise_w;
    END IF;

    RETURN dt_retorno_w;
END obter_dt_analise_apo2;
/