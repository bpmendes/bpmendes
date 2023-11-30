-- Gravar log
ds_alteracao_rastre_w	:= substr(	' - nr_seq_analise_apo_w: '||nr_seq_analise_apo_w, 1, 2000);
gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => 'bpmendes');

-- Consultar log gerado
select to_char(dt_atualizacao,'dd/mm/yyyy hh24:mi:ss') dt_atualizacao,
    ds_log
from log_tasy
where cd_log = 50
and nm_usuario = 'bpmendes'
order by dt_atualizacao desc;

-- Localizar nome de objetos
select *
from OBJETO_SISTEMA
where nr_sequencia = 10062764;

-- Localizar texto por expressões
select *
from dic_objeto
where cd_exp_informacao = 616556;

-- Localizar expressões
select cd_expressao,
    ds_expressao_br,
    ds_expressao_us,
    ds_expressao_mx
from DIC_EXPRESSAO a
where 1=1
and lower(a.ds_expressao_br) = 'data prevista'
--and lower(a.ds_expressao_us) = 'reference date'
--and lower(a.ds_expressao_mx) = 'data de referência'
--and lower(ds_expressao_br) like '%prescr%vencida%'
--and lower(ds_expressao_us) like '%não conforme%'
--and lower(ds_expressao_mx) like '%não conforme%'
--and cd_expressao = 735610
order by a.ds_expressao_br, a.cd_expressao desc;

-- Alterar parâmetro usuário
update FUNCAO_PARAM_USUARIO
set vl_parametro = 'E'
where cd_funcao = 3130
and nr_sequencia = 518
and nm_usuario_param = 'bpmendes';
commit;
/
-- Valor parâmetro usuário
select /*obter_nome_perfil(c.cd_perfil) ds_perfil,
    c.cd_perfil,*/
    b.cd_funcao || ' - ' || obter_nome_funcao(b.cd_funcao) nm_funcao,
    b.nr_sequencia,
    b.ds_parametro,
    a.vl_parametro
from funcao_param_usuario a,
    funcao_parametro b/*,
    funcao_param_perfil c*/
where 1=1/*b.cd_funcao = c.cd_funcao
and b.nr_sequencia = c.nr_sequencia*/
and a.cd_funcao = b.cd_funcao
and a.nr_sequencia = b.nr_sequencia
and a.vl_parametro is not null
--and nvl(b.ie_situacao_html5,'A') = 'A'
--and c.cd_funcao = 1691
and a.cd_funcao = 3130
and a.nr_sequencia = 306
--and a.nm_usuario_param = 'bpmendes'
--and lower(obter_nome_funcao(b.cd_funcao)) like '%rep%'
--and lower(b.ds_parametro) like '%adep%'
group by b.nr_sequencia,
    b.ds_parametro,
    a.vl_parametro,
    b.cd_funcao/*,
    c.cd_perfil*/
order by b.ds_parametro;


update usuario
set cd_pessoa_fisica = 632432 /*PF normal*/,
    IE_TIPO_EVOLUCAO = 3 /*Tipo evolução Médico*/
-- set cd_pessoa_fisica = 632444 /*PF médico*/
where nm_usuario = 'bpmendes';
commit;


alter session set current_schema=Tasy;

-- Localizar objeto pelo nome da tabela
select obter_nome_funcao(a.cd_funcao),
    a.*
from OBJETO_SCHEMATIC a
where 1=1 
and lower(a.nm_tabela) = 'rep_arredonda_diluicao'
--and upper(a.nm_tabela) = 'FAR_ETAPA_MAT_ADIC'
;

select *
from funcao_schematic
where nr_sequencia = 520;

-- Localizar Action por procedure
select b.NR_SEQUENCIA,
    b.nm_acao,
    b.cd_funcao,
    obter_nome_funcao(b.cd_funcao) as nm_funcao,
    A.IE_ACAO_EVENTO,
    decode(a.NR_SEQ_DIC_OBJ_SQL,null,a.NR_SEQ_DIC_OBJ_MSG,a.NR_SEQ_OBJ_PROC,a.NR_SEQ_OBJ_WDLG,a.NR_SEQ_DIC_OBJ_SQL) nr_objeto
from OBJ_SCHEMATIC_EVENTO_ACAO a,
    OBJ_SCHEMATIC_EVENTO b
where 1=1
--AND b.nm_acao = 'GET_IF_CAN_TRANSFER'
--AND a.NR_SEQ_OBJ_PROC = 84935
--AND lower(SUBSTR((SELECT X.NM_OBJETO FROM OBJETO_SISTEMA X WHERE X.NR_SEQUENCIA = A.NR_SEQ_OBJ_PROC),1,255)) = 'liberar_prescr_farmacia_js'
AND upper(SUBSTR((SELECT X.NM_OBJETO FROM OBJETO_SISTEMA X WHERE X.NR_SEQUENCIA = A.NR_SEQ_OBJ_PROC),1,255)) = 'GPT_RECRIAR_MAT_QUIMIO'
and b.NR_SEQUENCIA = a.NR_SEQ_OBJ_EVENTO
group by b.NR_SEQUENCIA,
    b.nm_acao,
    b.cd_funcao,
    obter_nome_funcao(b.cd_funcao),
    A.IE_ACAO_EVENTO,
    a.NR_SEQ_DIC_OBJ_MSG,
    a.NR_SEQ_OBJ_PROC,
    a.NR_SEQ_OBJ_WDLG,
    a.NR_SEQ_DIC_OBJ_SQL;

-- Validar objetos do sistema
exec valida_objetos_sistema;

-- Função schematics
select obter_nome_funcao(a.cd_funcao) as ds_funcao,
    a.nr_sequencia,
    a.ds_parametro
from FUNCAO_PARAMETRO a
where lower(a.ds_parametro) like '%cadastro%paciente%'
and nvl(a.ie_situacao_html5,'A') = 'A'
--and b.nm_usuario_param in ('bpmendes')
and a.cd_funcao = 916
order by ds_funcao;

select distinct a.ie_situacao_html5
from funcao_parametro a
where a.ie_situacao_html5 is not null
group by a.ie_situacao_html5;

select ds_proc_exame
from PROC_INTERNO
where ie_tipo ='AP'
and nvl(ie_situacao,'A') = 'A';

select ds_funcao,
    ie_status_html
from funcao
where ie_situacao = 'A'
and lower(ds_funcao) like '%amostra%';

-- Localizar função pela tabela
select  distinct NM_TABELA, 
    CD_FUNCAO,
    substr(obter_nome_funcao(CD_FUNCAO), 1, 100) as DS_FUNCAO
 from  OBJETO_SCHEMATIC
 where upper(NM_TABELA) LIKE upper(NVL('%HD_EQUIPE%', 0))
 order by NM_TABELA, 3;
 
 -- Dominio
 select distinct a.ds_dominio,
    a.cd_dominio,
    b.vl_dominio,
    b.ds_valor_dominio, 
    c.ds_expressao_us
 from dominio a,
    valor_dominio b,
    DIC_EXPRESSAO c
where b.cd_dominio = a.cd_dominio
and c.cd_expressao = b.cd_exp_valor_dominio
/*and lower(b.ds_valor_dominio) like '%regra%'
and lower(a.ds_dominio) like '%parâmetro%'*/
and a.cd_dominio = 2211
order by b.vl_dominio;

-- Versões geradas
 select cd_versao,
 to_char(trunc(dt_versao),'dd/mm/rrrr') geracao,
 to_char(trunc(dt_versao+18),'dd/mm/rrrr') extranet
 from ( 
 select cd_versao,
 dt_versao
 from APLICACAO_TASY_VERSAO
 where cd_aplicacao_tasy = 'Tasy'
 order by 2 desc)
 where rownum < 10
 order by dt_versao desc;
 
 select ospr.nr_product_requirement, cr.cd_CRS_ID
from corp.man_ordem_serv_imp_pr@whebl01_dbcorp ospr,
    corp.MAN_ORDEM_SERV_IMPACTO@whebl01_dbcorp os,
    corp.REG_PRODUCT_REQUIREMENT@whebl01_dbcorp pr,
    corp.REG_CUSTOMER_REQUIREMENT@whebl01_dbcorp cr
where ospr.NR_SEQ_IMPACTO = os.nr_sequencia
  and pr.NR_CUSTOMER_REQUIREMENT = cr.nr_sequencia
  and ospr.NR_PRODUCT_REQUIREMENT = pr.nr_sequencia
 and os.NR_SEQ_ORDEM_SERV = 2257949;
 
 -----Liberar acesso ao shematic
insert into funcao_schematic_lib values(FUNCAO_SCHEMATIC_LIB_SEQ.nextval,sysdate,'bpmendes',sysdate,'bpmendes','lfreichert',10852,'T');
commit;

------Pesquisa função schematic
select *
from funcao_schematic_lib
where nm_usuario_liberado = 'lfreichert'
and nr_seq_funcao_schematic = 10852;

select nr_sequencia,
    ds_schematic
from funcao_schematic
where lower(ds_schematic) like '%exam%management%';

select max(nr_sequencia), nr_seq_funcao_schematic from funcao_schematic_lib group by nr_seq_funcao_schematic;-- where nr_seq_funcao_schematic = 241;
-- TELA DE VÍNCULO PELA AÇÃO DE BOTÃO "EDIT ORDER UNIT/RP"
SELECT u.NR_SEQUENCIA, u.SI_CPOE_TYPE_OF_ITEM, u.NR_SEQ_CPOE_TIPO_PEDIDO 
FROM CPOE_ORDER_UNIT u,
CPOE_TIPO_PEDIDO c 
where C.NR_SEQ_SUB_GRP IN ('B', 'L')
AND C.NR_SEQUENCIA = u.NR_SEQ_CPOE_TIPO_PEDIDO
and u.nr_atendimento = 3439461;


-- validação tela sem o parametro 46, havendo registro abrir WDLG para vincular o setor de coleta
select * 
from PROC_INTERNO p, 
PROC_ORDER_TYPE t,
CPOE_TIPO_PEDIDO c
where C.NR_SEQ_SUB_GRP IN ('B', 'L')
AND C.NR_SEQUENCIA = T.NR_SEQ_ORDER_TYPE
AND P.NR_SEQUENCIA = T.NR_SEQ_PROC_INTERNO
AND T.NR_SEQ_PROC_INTERNO = 34605; -- valor da tela
LIBERAR_PRESCRICAO;

-- Localizador de objetos
select    substr(a.nm_objeto,1,30) nome_objeto,
    a.qt_ocorrencia
from    table(localizacao_objetos_pck.obter_objetos_comando('update','prescr_medica','dt_liberacao')) a
order by 1;
far_estoque_cabine
select *
from dic_expressao
where 1=1
--and lower(ds_expressao_us) like '%fourth%name%'
and lower(ds_expressao_br) like '%simplificado%'
--and cd_expressao = 738696
;

/*
first name - 737420
BR: Segundo nome / EN: Scond name / glossary: Refers to the second name of a person // Segundo nome de um indivíduo
third name - 737424
BR: Quarto nome / EN: Fourth name / glossary: Refers to the fourth name of a person // Quarto nome de um indivíduo
*/


SELECT CD_EXPRESSAO,   
obter_nome_funcao(cd_funcao) ds_funcao,
obter_valor_dominio(8246,ie_utilizacao)ds_use,
OBTER_DESC_ESTRUT_SCHEMATIC_2(nr_seq_obj_schematic) ds_local,
obter_desc_expressao_test(cd_exp_desc) ds_informacao,
NR_SEQUENCIA
FROM     W_DIC_EXPRESSAO_USO_HTML
WHERE     cd_expressao = '';


select *
from dic_objeto
where 1=1
--and ds_sql like '%737420%'
and nr_sequencia = 754485;