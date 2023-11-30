create or replace FUNCTION Obter_se_analise_ativa_apo2 (nr_prescricao_p prescr_medica.nr_prescricao%TYPE)
RETURN VARCHAR2 IS
  ie_retorno_w             VARCHAR2(1);
  dt_inicio_analise_enf_w  gpt_hist_analise_plano.dt_inicio_analise%TYPE;
  dt_fim_analise_enf_w     gpt_hist_analise_plano.dt_fim_analise%TYPE;
  dt_inicio_analise_farm_w gpt_hist_analise_plano.dt_inicio_analise%TYPE;
  dt_fim_analise_farm_w    gpt_hist_analise_plano.dt_fim_analise%TYPE;
BEGIN
    SELECT Max((SELECT Obter_dt_analise_apo2(x.nr_prescricao, 'E', 'DTI')
                FROM   prescr_medica x
                WHERE  x.nr_prescricao = a.nr_prescricao)),
           Max((SELECT Obter_dt_analise_apo2(x.nr_prescricao, 'E', 'DTF')
                FROM   prescr_medica x
                WHERE  x.nr_prescricao = a.nr_prescricao)),
           Max((SELECT Obter_dt_analise_apo2(x.nr_prescricao, 'F', 'DTI')
                FROM   prescr_medica x
                WHERE  x.nr_prescricao = a.nr_prescricao)),
           Max((SELECT Obter_dt_analise_apo2(x.nr_prescricao, 'F', 'DTF')
                FROM   prescr_medica x
                WHERE  x.nr_prescricao = a.nr_prescricao))
    INTO   dt_inicio_analise_enf_w, dt_fim_analise_enf_w,
           dt_inicio_analise_farm_w,
           dt_fim_analise_farm_w
    FROM   prescr_material a
    WHERE  a.nr_prescricao = nr_prescricao_p;

    IF ( nr_prescricao_p IS NOT NULL ) THEN
      BEGIN
          CASE
            WHEN ( dt_inicio_analise_farm_w IS NULL
                   AND dt_fim_analise_farm_w IS NULL
                   AND dt_inicio_analise_enf_w IS NOT NULL
                   AND dt_fim_analise_enf_w IS NOT NULL ) THEN
              ie_retorno_w := 'N';
            WHEN ( dt_inicio_analise_farm_w IS NOT NULL
                   AND dt_fim_analise_farm_w IS NULL
                   AND dt_inicio_analise_enf_w IS NOT NULL
                   AND dt_fim_analise_enf_w IS NOT NULL )
                  OR ( dt_inicio_analise_farm_w IS NULL
                       AND dt_fim_analise_farm_w IS NULL
                       AND dt_inicio_analise_enf_w IS NOT NULL
                       AND dt_fim_analise_enf_w IS NULL ) THEN
              ie_retorno_w := 'S';
            ELSE
              ie_retorno_w := 'N';
          END CASE;
      END;
    END IF;

    RETURN ie_retorno_w;
END obter_se_analise_ativa_apo2;