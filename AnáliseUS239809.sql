-- INICIAR ANALISE FARMACIA
exec ALTERA_STATUS_ANALISE_APO(830315,'F','I','bpmendes');
-- FINALIZAR ANALISE FARMACIA
exec ALTERA_STATUS_ANALISE_APO(830315,'F','F','bpmendes');
-- DESFAZER ANALISE FARMACIA
exec ALTERA_STATUS_ANALISE_APO(830315,'F','D','bpmendes');

-- INICIAR ANALISE ENFERMAGEM
exec ALTERA_STATUS_ANALISE_APO(830315,'E','I','bpmendes');
-- FINALIZAR ANALISE ENFERMAGEM
exec ALTERA_STATUS_ANALISE_APO(830315,'E','F','bpmendes');
-- DESFAZER ANALISE ENFERMAGEM
exec ALTERA_STATUS_ANALISE_APO(830315,'E','D','bpmendes');

select Obter_dt_analise_prescr_apo(830315,'E','DTI') dt_inicio_enf,
    Obter_dt_analise_prescr_apo(830315,'E','DTF') dt_fim_enf,
    Obter_dt_analise_prescr_apo(830315,'F','DTI') dt_inicio_farm,
    Obter_dt_analise_prescr_apo(830315,'F','DTF') dt_fim_farm,
    obter_situacao_analise_apo(830315) ie_analise_ativa,
    obter_resp_analise_prescr_apo(830315,'E','U') nm_usuario_enf,    
    obter_resp_analise_prescr_apo(830315,'E','NM') nm_compl_resp_enf,
    obter_resp_analise_prescr_apo(830315,'F','U') nm_usuario_farm,    
    obter_resp_analise_prescr_apo(830315,'F','NM') nm_compl_resp_farm,
    obter_status_analise_apo(830315,1) cd_status,
    obter_status_analise_apo(830315,2) ds_status
from dual;

UPDATE prescr_medica_compl
                  SET    dt_inicio_analise_enf = NULL,
                         nm_usuario_analise_enf = NULL
                  WHERE  nr_prescricao = 830315;
                  commit;

select	to_char(dt_inicio_prescr,'dd/mm/yyyy hh24:mi:ss') dt_inicio_prescr,
        to_char(dt_validade_prescr,'dd/mm/yyyy hh24:mi:ss') dt_validade_prescr
/*into	dt_inicio_prescr_w,
        dt_validade_prescr_w*/
from	prescr_medica
where	nr_prescricao = 830315;

select OBTER_SE_VALID_PRESCR(830315,sysdate) from dual;

