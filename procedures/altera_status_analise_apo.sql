CREATE OR replace PROCEDURE altera_status_analise_apo(
nr_prescricao_p   IN prescr_medica.nr_prescricao%TYPE,
ie_tipo_usuario_p IN VARCHAR2,
ie_acao_p         IN VARCHAR2,
nm_usuario_p      IN VARCHAR2)
IS

  dt_inicio_analise_w DATE;
  dt_fim_analise_w    DATE;
  nm_resp_analise_w   pessoa_fisica.nm_pessoa_fisica%TYPE;
  ds_erro_prescr_w    VARCHAR2(1000);
  nr_prescr_erro_w    VARCHAR2(1000);
  ie_commit_w         VARCHAR2(1) := 'N';
  nr_atendimento_w    prescr_medica.nr_atendimento%TYPE;       

BEGIN

  nm_resp_analise_w := Obter_resp_analise_prescr_apo(nr_prescricao_p, ie_tipo_usuario_p, 'U');
  dt_inicio_analise_w := Obter_dt_analise_prescr_apo(nr_prescricao_p, ie_tipo_usuario_p, 'DTI');
  dt_fim_analise_w := Obter_dt_analise_prescr_apo(nr_prescricao_p, ie_tipo_usuario_p, 'DTF');
  
  SELECT max(nr_atendimento)
  INTO   nr_atendimento_w
  FROM   prescr_medica
  WHERE  nr_prescricao = nr_prescricao_p;
  
    IF ( nm_resp_analise_w <> nm_usuario_p ) THEN
      wheb_mensagem_pck.Exibir_mensagem_abort(718533);
    ELSE
      BEGIN
          IF ( ( Upper(ie_acao_p) = 'I' )
               AND ( dt_fim_analise_w IS NULL )
               AND ( nr_prescricao_p IS NOT NULL ) ) THEN
            BEGIN
                IF ( ie_tipo_usuario_p = 'F' ) THEN
                  UPDATE prescr_medica
                  SET    dt_inicio_analise_farm = SYSDATE,
                         nm_usuario_analise_farm = nm_usuario_p
                  WHERE  nr_prescricao = nr_prescricao_p
                         AND dt_liberacao_farmacia IS NULL
                         AND dt_inicio_analise_farm IS NULL
                         AND nm_usuario_analise_farm IS NULL
                         AND cd_funcao_origem NOT IN ( 924, 950 );
                ELSIF ( ie_tipo_usuario_p = 'E' ) THEN
                  Gerar_prescr_medica_compl(nr_prescricao_p, nm_usuario_p, nm_usuario_p, SYSDATE);
                END IF;
            END;
          ELSIF ( ( Upper(ie_acao_p) = 'F' )
                  AND ( nr_prescricao_p IS NOT NULL ) ) THEN
            BEGIN
                IF ( ie_tipo_usuario_p = 'F' ) THEN
                  Liberar_prescricao_farmacia(nr_prescricao_p, 0, nm_usuario_p, 'N');
                ELSIF ( ie_tipo_usuario_p = 'E' ) THEN
                  Liberar_prescricao_enf_html5(nr_prescricao_p, nr_atendimento_w, 'N', obter_perfil_ativo, nm_usuario_p, 'N', ds_erro_prescr_w, nr_prescr_erro_w);
                END IF;
            END;
          ELSIF ( Upper(ie_acao_p) = 'D' ) THEN
            BEGIN
                IF ( ie_tipo_usuario_p = 'F' ) THEN
                  UPDATE prescr_medica
                  SET    dt_inicio_analise_farm = NULL,
                         nm_usuario_analise_farm = NULL
                  WHERE  nr_prescricao = nr_prescricao_p;
                ELSIF ( ie_tipo_usuario_p = 'E' ) THEN
                  UPDATE prescr_medica_compl
                  SET    dt_inicio_analise_enf = NULL,
                         nm_usuario_analise_enf = NULL
                  WHERE  nr_prescricao = nr_prescricao_p;
                END IF;
            END;
          END IF;

          ie_commit_w := 'S';
      END;
    END IF;

    IF ( ie_commit_w = 'S' ) THEN
      COMMIT;
    END IF;
END altera_status_analise_apo;
/
