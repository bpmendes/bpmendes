-- INICIAR ANALISE FARMACIA
exec ALTERA_STATUS_ANALISE_GPT(1001345,632447,632432,'F','I','bpmendes',null,null,null,0,830259);
-- FINALIZAR ANALISE FARMACIA
exec ALTERA_STATUS_ANALISE_GPT(1001345,632447,632432,'F','F','bpmendes',null,null,null,0,830257);
-- DESFAZER ANALISE FARMACIA
exec ALTERA_STATUS_ANALISE_GPT(1001345,632447,632432,'F','D','bpmendes',null,null,null,0,830257);

-- INICIAR ANALISE ENFERMAGEM
exec ALTERA_STATUS_ANALISE_GPT(1001345,632447,632432,'E','I','bpmendes',null,null,null,0,830287);
-- FINALIZAR ANALISE ENFERMAGEM
exec ALTERA_STATUS_ANALISE_GPT(1001345,632447,632432,'E','F','bpmendes',null,null,null,0);
-- DESFAZER ANALISE ENFERMAGEM
exec ALTERA_STATUS_ANALISE_GPT(1001345,632447,632432,'E','D','bpmendes',null,null,null,0,830289);

select dt_prevista
from paciente_atendimento
where nr_prescricao = 830297;

select	dt_inicio_prescr,
        dt_validade_prescr
/*into	dt_inicio_prescr_w,
        dt_validade_prescr_w*/
from	prescr_medica
where	nr_prescricao = 830289;

select OBTER_SE_VALID_PRESCR(830297,sysdate) from dual;

select a.nr_sequencia,
    to_char(a.dt_atualizacao,'dd/mm/yyyy hh24:mi:ss'),
    a.nm_usuario,
    a.nr_prescricao,
    a.dt_inicio_analise,
    a.dt_fim_analise,
    a.ie_tipo_usuario,
    Obter_dt_analise_apo(a.nr_atendimento, 'E', 'DTI', a.cd_pessoa_fisica, a.nr_prescricao) dt_inicio_enf,
    Obter_dt_analise_apo(a.nr_atendimento, 'E', 'DTF', a.cd_pessoa_fisica, a.nr_prescricao) dt_fim_enf,
    Obter_dt_analise_apo(a.nr_atendimento, 'F', 'DTI', a.cd_pessoa_fisica, a.nr_prescricao) dt_inicio_farm,
    Obter_dt_analise_apo(a.nr_atendimento, 'E', 'DTF', a.cd_pessoa_fisica, a.nr_prescricao) dt_fim_farm
from gpt_hist_analise_plano a
where a.nr_prescricao = 830297
order by a.nr_sequencia desc;
OBTER_SE_ANALISE_ATIVA_APO;
select to_char(dt_atualizacao,'dd/mm/yyyy hh24:mi:ss') dt_atualizacao,
    ds_log
from log_tasy
where cd_log = 50
and nm_usuario = 'bpmendes'
order by dt_atualizacao desc;

select Max((case
                when ((select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is not null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is not null) then
                'N'
                when ((select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is not null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is not null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is not null)
              or (((select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is not null
              and (select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao) is null)) then
                'S'
              else
                'S'
            end )) ie_analise_ativa,
    Max((select Get_status_analise_apo(x.nr_atendimento, x.cd_pessoa_fisica, x.nr_prescricao, 2) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao)) ds_status,
    Max((select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao)) dt_inicio_enf,
    Max((select Obter_dt_analise_apo(x.nr_atendimento, 'E', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao)) dt_fim_enf,
    Max((select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTI', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao)) dt_inicio_farm,
    Max((select Obter_dt_analise_apo(x.nr_atendimento, 'F', 'DTF', x.cd_pessoa_fisica, x.nr_prescricao) from PRESCR_MEDICA x where  x.nr_prescricao = a.nr_prescricao)) dt_fim_farm
from   PRESCR_MATERIAL a
where  a.nr_prescricao = 830259; 

select max(nr_prescricao)
--into nr_seq_analise_gpt_w
from gpt_hist_analise_plano
where ((nr_atendimento = 1001345) or (cd_pessoa_fisica = 632447))
and ie_tipo_usuario = 'F'/*
and	dt_fim_analise is null*/
and nr_prescricao = 830259;

select 	max(a.nr_sequencia)
from 	gpt_hist_analise_plano a
where	((a.nr_atendimento = 1001345) or (a.cd_pessoa_fisica = 632447))
and a.nr_prescricao = 830259
and a.nr_sequencia = (
        select b.nr_sequencia
        from gpt_hist_analise_plano b
        where b.nr_sequencia = a.nr_sequencia
        and b.ie_tipo_usuario = 'E'
        and b.dt_fim_analise is not null
    );

select 	max(dt_inicio_analise) dt_inicio_analise,
        max(dt_fim_analise) dt_fim_analise
from 	gpt_hist_analise_plano
where 	nr_prescricao = 830259
and     ie_tipo_usuario = 'F';

update gpt_hist_analise_plano
set dt_fim_analise = sysdate
where nr_sequencia = 515;
commit;

delete from gpt_hist_analise_plano
where nr_sequencia in (535);
commit;