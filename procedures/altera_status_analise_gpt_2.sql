create or replace procedure altera_status_analise_gpt(	nr_atendimento_p	number,
					cd_pessoa_fisica_p	varchar2,
					cd_resp_analise_p	varchar2,
					ie_tipo_usuario_p	varchar2,
					ie_acao_p		varchar2,
					nm_usuario_p		varchar2,
					ds_justificativa_p	varchar2 default null,
					ie_lib_farm_p		varchar2 default null,
					ie_retorno_cpoe_p	varchar2 default null,
					qt_horas_quimio_p	in number default 0,
					nr_prescricao_p	    number default null) is 

dt_inicio_analise_w 		date;
nr_sequencia_w				number;
nm_resp_analise_w			varchar2(15);
ie_lib_pendente_w			varchar2(1);
ie_commit_w					varchar2(1) := 'N';
desfazer_inicio_analise_w 	varchar2(1) := 'N';
nr_prescr_analise_w			prescr_medica.nr_prescricao%type;
nr_prescricao_w				prescr_medica.nr_prescricao%type;
ds_alteracao_rastre_w		log_tasy.ds_log%type;
ie_info_rastre_prescr_w		varchar2(1 char);
cd_estabelecimento_ativo_w	estabelecimento.cd_estabelecimento%type;

cursor	c01 is
select	nr_prescricao
from	prescr_medica
where	nr_atendimento = nr_atendimento_p
and		cd_pessoa_fisica = cd_pessoa_fisica_p
and		ie_tipo_usuario_p = 'F'
and 	dt_liberacao is not null 
and 	((nvl(ie_lib_farm_p,'S') = 'N') or (nvl(ie_lib_farm,'N') = 'S')) 
and 	dt_liberacao_farmacia is null
and		(((nm_usuario_analise_farm	= nm_usuario_p) and 
		  (dt_inicio_analise_farm = dt_inicio_analise_w)) or 
		 (desfazer_inicio_analise_w = 'S'))
and 	dt_prescricao > (sysdate - 7)
union
select	nr_prescricao
from	prescr_medica
where	cd_pessoa_fisica = cd_pessoa_fisica_p
and		nr_atendimento_p is null
and		ie_tipo_usuario_p = 'F'
and 	dt_liberacao is not null 
and 	((nvl(ie_lib_farm_p,'S') = 'N') or (nvl(ie_lib_farm,'N') = 'S'))
and 	dt_liberacao_farmacia is null
and		(((nm_usuario_analise_farm	= nm_usuario_p) and 
		  (dt_inicio_analise_farm = dt_inicio_analise_w)) or 
		 (desfazer_inicio_analise_w = 'S'))
and 	dt_prescricao > (sysdate - 7);

cursor	c02 is
select	nr_prescricao
from	prescr_medica
where	nr_atendimento = nr_atendimento_p
and		cd_pessoa_fisica = cd_pessoa_fisica_p
and		dt_liberacao_medico is not null 
and		dt_liberacao is null
and		dt_inicio_analise_farm is null
and		nm_usuario_analise_farm is null
and 	dt_prescricao > (sysdate - 7)
union
select	nr_prescricao
from	prescr_medica
where	cd_pessoa_fisica = cd_pessoa_fisica_p
and		nr_atendimento_p is null
and		dt_liberacao_medico is not null 
and		dt_liberacao is null
and		dt_inicio_analise_farm is null
and		nm_usuario_analise_farm is null
and 	dt_prescricao > (sysdate - 7);

cursor	c03 is
select	a.nr_prescricao
from	prescr_medica a,
		prescr_medica_compl b
where	a.nr_prescricao = b.nr_prescricao
and		a.nr_atendimento = nr_atendimento_p
and		a.cd_pessoa_fisica = cd_pessoa_fisica_p
and		a.dt_liberacao is null
and		a.dt_liberacao_medico is not null 
and		b.nm_usuario_analise_enf	= nm_usuario_p
and		b.dt_inicio_analise_enf = dt_inicio_analise_w
and 	dt_prescricao > (sysdate - 7)
union
select	a.nr_prescricao
from	prescr_medica a,
		prescr_medica_compl b
where	a.nr_prescricao = b.nr_prescricao
and		nr_atendimento_p is null
and		a.cd_pessoa_fisica = cd_pessoa_fisica_p
and		a.dt_liberacao is null
and		a.dt_liberacao_medico is not null 
and		b.nm_usuario_analise_enf	= nm_usuario_p
and		b.dt_inicio_analise_enf = dt_inicio_analise_w
and 	dt_prescricao > (sysdate - 7);

begin

if	(obter_se_usuario_medico(nm_usuario_p) = 'S') then
	wheb_mensagem_pck.exibir_mensagem_abort(1073442);
end if;	

if (obter_pf_usuario(nm_usuario_p, 'C') is null) then
	-- O usuario utilizado nao possui numero de pessoa fisica vinculado...
	wheb_mensagem_pck.exibir_mensagem_abort(1194237);
end if;

ie_info_rastre_prescr_w 	:= 'N';

cd_estabelecimento_ativo_w := wheb_usuario_pck.get_cd_estabelecimento;

desfazer_inicio_analise_w := nvl(Obter_Valor_Param_Usuario(252,21, Obter_perfil_Ativo, wheb_usuario_pck.get_nm_usuario, nvl(cd_estabelecimento_ativo_w, 0)),'N');

ie_info_rastre_prescr_w := obter_se_info_rastre_prescr('AG', nm_usuario_p, wheb_usuario_pck.get_cd_perfil, cd_estabelecimento_ativo_w);

if(ie_info_rastre_prescr_w = 'S') then
	ds_alteracao_rastre_w := substr('01-Gerar log Rastreabilidade Alteracoes / altera_status_analise_gpt'|| pls_util_pck.enter_w ||
		' - nr_atendimento_p: ' || nr_atendimento_p || pls_util_pck.enter_w ||
		' - cd_pessoa_fisica_p: ' || cd_pessoa_fisica_p || pls_util_pck.enter_w ||
		' - cd_resp_analise_p: ' || cd_resp_analise_p || pls_util_pck.enter_w ||
		' - ie_tipo_usuario_p: ' || ie_tipo_usuario_p || pls_util_pck.enter_w ||
		' - ie_acao_p: ' || ie_acao_p || pls_util_pck.enter_w ||
		' - nm_usuario_p: ' || nm_usuario_p || pls_util_pck.enter_w ||
		' - ds_justificativa_p: ' || ds_justificativa_p || pls_util_pck.enter_w ||
		' - ie_lib_farm_p: ' || ie_lib_farm_p || pls_util_pck.enter_w ||
		' - ie_retorno_cpoe_p: ' || ie_retorno_cpoe_p || pls_util_pck.enter_w ||
		' - qt_horas_quimio_p: ' || qt_horas_quimio_p || pls_util_pck.enter_w ||
		' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800), 1, 2000);

	gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
end if;

/*Só acessa o bloco if se for executado da função Análise da Prescrição de Oncologia - APO ou Quimioterapia*/
if  (nvl(wheb_usuario_pck.get_cd_funcao,1) = 476 or nvl(wheb_usuario_pck.get_cd_funcao,1) = 3130) and (nr_prescricao_p is not null) then
    select 	max(nr_sequencia),
        max(nm_resp_analise),
        max(dt_inicio_analise)
    into	nr_sequencia_w,
        nm_resp_analise_w,
        dt_inicio_analise_w
    from 	gpt_hist_analise_plano
    where	((nr_atendimento = nr_atendimento_p) or (cd_pessoa_fisica = cd_pessoa_fisica_p and nr_atendimento_p is null))
    and	dt_fim_analise is null
    and	ie_tipo_usuario = ie_tipo_usuario_p
    and nr_prescricao = nr_prescricao_p;
else
    select 	max(nr_sequencia),
	max(nm_resp_analise),
	max(dt_inicio_analise)
    into	nr_sequencia_w,
        nm_resp_analise_w,
        dt_inicio_analise_w
    from 	gpt_hist_analise_plano
    where	((nr_atendimento = nr_atendimento_p) or (cd_pessoa_fisica = cd_pessoa_fisica_p and nr_atendimento_p is null))
    and	dt_fim_analise is null
    and	ie_tipo_usuario = ie_tipo_usuario_p
    and nr_prescricao is null;
end if;

if	(nr_sequencia_w > 0 and ((nm_resp_analise_w <> nm_usuario_p) and (desfazer_inicio_analise_w <> 'S'))) then
	wheb_mensagem_pck.exibir_mensagem_abort(718533);
else	
	begin
		if	((nvl(nr_sequencia_w,0) = 0) and ((upper(ie_acao_p) = 'I') or (ie_retorno_cpoe_p = 'S'))) then
            /*Só acessa o bloco if se for executado da função Análise da Prescrição de Oncologia - APO ou Quimioterapia*/
            if (nvl(wheb_usuario_pck.get_cd_funcao,1) = 476 or nvl(wheb_usuario_pck.get_cd_funcao,1) = 3130) then
                begin
                    begin

                        insert into gpt_hist_analise_plano (
                            nr_sequencia,
                            dt_atualizacao,
                            nm_usuario,
                            dt_inicio_analise,
                            nm_resp_analise,
                            ie_tipo_usuario,
                            nr_atendimento,
                            cd_pessoa_fisica,
                            cd_resp_analise,
                            nr_prescricao)
                        values(
                            gpt_hist_analise_plano_seq.nextval,
                            sysdate,
                            nm_usuario_p,
                            sysdate,
                            nm_usuario_p,
                            ie_tipo_usuario_p,
                            nr_atendimento_p,
                            cd_pessoa_fisica_p,
                            cd_resp_analise_p,
                            nr_prescricao_p);

                    exception when others then
                        ds_alteracao_rastre_w	:= substr(	'02-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                            ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                            ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                        gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                    end;

                    if	(ie_tipo_usuario_p = 'F') then
                        begin

                            update	prescr_medica
                            set		dt_inicio_analise_farm = sysdate,
                                    nm_usuario_analise_farm = nm_usuario_p
                            where	((nr_atendimento = nr_atendimento_p) or (cd_pessoa_fisica = cd_pessoa_fisica_p and nr_atendimento_p is null))
                            and		cd_pessoa_fisica = cd_pessoa_fisica_p
                            and		dt_liberacao is not null 
                            and 	((nvl(ie_lib_farm_p,'S') = 'N') or (nvl(ie_lib_farm,'N') = 'S'))
                            and 	dt_liberacao_farmacia is null
                            and		dt_inicio_analise_farm is null
                            and		nm_usuario_analise_farm is null
                            and 	cd_funcao_origem not in (924,950)
                            and		((dt_prescricao > (sysdate - 7) and nr_seq_atend is null) or
                                     (nr_seq_atend is not null and dt_prescricao between inicio_dia(sysdate - 3) and sysdate + (qt_horas_quimio_p / 24)));

                        exception when others then
                            ds_alteracao_rastre_w	:= substr(	'03-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                                ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                                ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                            gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                        end;

                    elsif	(ie_tipo_usuario_p = 'E') then
                        begin
                            open c02;
                            loop
                            fetch c02 into
                                nr_prescricao_w;
                            exit when c02%notfound;
                                begin

                                    gerar_prescr_medica_compl(	nr_prescricao_w, nm_usuario_p, nm_usuario_p, sysdate);

                                exception when others then
                                    ds_alteracao_rastre_w	:= substr(	'04-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                                        ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                                        ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                                    gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                                end;
                            end loop;
                            close c02;
                        end;
                    end if;
                end;
            else
                begin
                    begin

                        insert into gpt_hist_analise_plano (
                            nr_sequencia,
                            dt_atualizacao,
                            nm_usuario,
                            dt_inicio_analise,
                            nm_resp_analise,
                            ie_tipo_usuario,
                            nr_atendimento,
                            cd_pessoa_fisica,
                            cd_resp_analise)
                        values(
                            gpt_hist_analise_plano_seq.nextval,
                            sysdate,
                            nm_usuario_p,
                            sysdate,
                            nm_usuario_p,
                            ie_tipo_usuario_p,
                            nr_atendimento_p,
                            cd_pessoa_fisica_p,
                            cd_resp_analise_p);

                    exception when others then
                        ds_alteracao_rastre_w	:= substr(	'02-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                            ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                            ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                        gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                    end;

                    if	(ie_tipo_usuario_p = 'F') then
                        if (nr_prescricao_p is not null) then
                            begin

                                update	prescr_medica
                                set		dt_inicio_analise_farm = sysdate,
                                        nm_usuario_analise_farm = nm_usuario_p
                                where	((nr_atendimento = nr_atendimento_p) or (cd_pessoa_fisica = cd_pessoa_fisica_p and nr_atendimento_p is null))
                                and		cd_pessoa_fisica = cd_pessoa_fisica_p
                                and     nr_prescricao = nr_prescricao_p
                                and		dt_liberacao is not null 
                                and 	((nvl(ie_lib_farm_p,'S') = 'N') or (nvl(ie_lib_farm,'N') = 'S'))
                                and 	dt_liberacao_farmacia is null
                                and		dt_inicio_analise_farm is null
                                and		nm_usuario_analise_farm is null
                                and 	cd_funcao_origem not in (924,950)
                                and		((dt_prescricao > (sysdate - 7) and nr_seq_atend is null) or
                                         (nr_seq_atend is not null and dt_prescricao between inicio_dia(sysdate - 3) and sysdate + (qt_horas_quimio_p / 24)));

                            exception when others then
                                ds_alteracao_rastre_w	:= substr(	'03-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                                    ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                                    ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                                gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                            end;
                        else
                            begin

                                update	prescr_medica
                                set		dt_inicio_analise_farm = sysdate,
                                        nm_usuario_analise_farm = nm_usuario_p
                                where	((nr_atendimento = nr_atendimento_p) or (cd_pessoa_fisica = cd_pessoa_fisica_p and nr_atendimento_p is null))
                                and		cd_pessoa_fisica = cd_pessoa_fisica_p
                                and		dt_liberacao is not null 
                                and 	((nvl(ie_lib_farm_p,'S') = 'N') or (nvl(ie_lib_farm,'N') = 'S'))
                                and 	dt_liberacao_farmacia is null
                                and		dt_inicio_analise_farm is null
                                and		nm_usuario_analise_farm is null
                                and 	cd_funcao_origem not in (924,950)
                                and		((dt_prescricao > (sysdate - 7) and nr_seq_atend is null) or
                                         (nr_seq_atend is not null and dt_prescricao between inicio_dia(sysdate - 3) and sysdate + (qt_horas_quimio_p / 24)));

                            exception when others then
                                ds_alteracao_rastre_w	:= substr(	'03-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                                    ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                                    ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                                gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                            end;
                        end if;
                    elsif	(ie_tipo_usuario_p = 'E') then
                        begin
                            open c02;
                            loop
                            fetch c02 into
                                nr_prescricao_w;
                            exit when c02%notfound;
                                begin

                                    gerar_prescr_medica_compl(	nr_prescricao_w, nm_usuario_p, nm_usuario_p, sysdate);

                                exception when others then
                                    ds_alteracao_rastre_w	:= substr(	'04-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
                                                                        ' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
                                                                        ' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
                                    gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
                                end;
                            end loop;
                            close c02;
                        end;
                    end if;
                end;
            end if;
		elsif	(upper(ie_acao_p) = 'F') then
			begin
				if (ie_tipo_usuario_p = 'F') then

					/*Condicao similar a consulta de codigo 728796, utilizada para obter as prescricoes a serem liberadas pela farmacia*/

					select	decode(count(*),0,'N','S')
					into	ie_lib_pendente_w
					from	prescr_material a left join prescr_medica b on (a.nr_prescricao = b.nr_prescricao)
					where	((dt_lib_farmacia is null)	and
								(dt_lib_enfermagem is not null) and
								((nvl(ie_lib_farm_p,'S') = 'N') or (nvl(ie_lib_farm,'N') = 'S')) and
								(dt_liberacao_farmacia is null) and
								(dt_inicio_analise_farm is not null) and
								(nm_usuario_analise_farm = nm_usuario_p))
					and		b.dt_liberacao is not null
					and		((nr_atendimento = nr_atendimento_p) or (cd_pessoa_fisica = cd_pessoa_fisica_p and nr_atendimento_p is null))
					and		((dt_prescricao between inicio_dia(sysdate - 3) and fim_dia(sysdate)) 
							or (nr_seq_atend is not null and dt_prescricao between inicio_dia(sysdate - 3) and sysdate + (qt_horas_quimio_p / 24)))
					and		b.dt_suspensao is null
					and		b.cd_funcao_origem not in (924, 950);

				end if;

				if	(ie_lib_pendente_w = 'S') then					
					wheb_mensagem_pck.exibir_mensagem_abort(810132);					
				else	
					begin

						update 	gpt_hist_analise_plano
						set		dt_fim_analise = sysdate
						where	nr_sequencia = nr_sequencia_w;

					exception when others then
						ds_alteracao_rastre_w	:= substr(	'05-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
															' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
															' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
						gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
					end;
				end if;
			end;
		elsif	(upper(ie_acao_p) = 'D') then
			begin
				begin
                    /*Só acessa o bloco if se for executado da função Análise da Prescrição de Oncologia - APO ou Quimioterapia*/
                    if  (nvl(wheb_usuario_pck.get_cd_funcao,1) = 476 or nvl(wheb_usuario_pck.get_cd_funcao,1) = 3130) and (nr_prescricao_p is not null) then                            
                        delete from gpt_hist_analise_plano
                        where	nr_prescricao = nr_prescricao_p
                        and     ie_tipo_usuario = ie_tipo_usuario_p;
                    else
                        delete from gpt_hist_analise_plano
                        where	nr_sequencia = nr_sequencia_w
                        and     nr_prescricao is null;
                    end if;

				exception when others then
					ds_alteracao_rastre_w	:= substr(	'06-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
														' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
														' - nr_atendimento_p: '||nr_atendimento_p, 1, 2000);
					gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
				end;

				if	(ie_tipo_usuario_p = 'F') then				

					open c01;
					loop
					fetch c01 into
						nr_prescr_analise_w;
					exit when c01%notfound;
					begin
						begin

							update	prescr_medica
							set		dt_inicio_analise_farm 		= null,
									nm_usuario_analise_farm 	= null
							where	nr_prescricao 				= nr_prescr_analise_w;

						exception when others then
							ds_alteracao_rastre_w	:= substr(	'07-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
																' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
																' - nr_atendimento_p: '||nr_atendimento_p|| pls_util_pck.enter_w ||
																' - nr_prescr_analise_w: '||nr_prescr_analise_w, 1, 2000);
							gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
						end;

						begin

							insert into log_analise_prescr(
								nr_sequencia,
								dt_atualizacao,
								nm_usuario,
								nr_prescricao,
								ie_acao,
								dt_acao,
								nm_usuario_acao,
								ds_motivo_acao)
							values	(log_analise_prescr_seq.nextval,
								sysdate,
								nm_usuario_p,
								nr_prescr_analise_w,
								'D',
								sysdate,
								nm_usuario_p,
								ds_justificativa_p);

						exception when others then
							ds_alteracao_rastre_w	:= substr(	'08-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
																' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
																' - nr_atendimento_p: '||nr_atendimento_p|| pls_util_pck.enter_w ||
																' - nr_prescr_analise_w: '||nr_prescr_analise_w, 1, 2000);
							gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
						end;

					end;
					end loop;
					close c01;

				elsif	(ie_tipo_usuario_p = 'E') then

					open c03;
					loop
					fetch c03 into
						nr_prescricao_w;
					exit when c03%notfound;
						begin

						begin

							update	prescr_medica_compl
							set		dt_inicio_analise_enf = null,
									nm_usuario_analise_enf = null
							where	nr_prescricao = nr_prescricao_w;

						exception when others then
							ds_alteracao_rastre_w	:= substr(	'09-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
																' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
																' - nr_atendimento_p: '||nr_atendimento_p|| pls_util_pck.enter_w ||
																' - nr_prescricao_w: '||nr_prescricao_w, 1, 2000);
							gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
						end;

						begin

							insert into log_analise_prescr(
								nr_sequencia,
								dt_atualizacao,
								nm_usuario,
								nr_prescricao,
								ie_acao,
								dt_acao,
								nm_usuario_acao,
								ds_motivo_acao)
							values	(log_analise_prescr_seq.nextval,
								sysdate,
								nm_usuario_p,
								nr_prescricao_w,
								'D',
								sysdate,
								nm_usuario_p,
								ds_justificativa_p);

						exception when others then
							ds_alteracao_rastre_w	:= substr(	'10-Exception altera_status_analise_gpt: '||sqlerrm(sqlcode)|| pls_util_pck.enter_w ||
																' - ds_stack: '||substr(dbms_utility.format_call_stack,1,1800)|| pls_util_pck.enter_w ||
																' - nr_atendimento_p: '||nr_atendimento_p|| pls_util_pck.enter_w ||
																' - nr_prescricao_w: '||nr_prescricao_w, 1, 2000);
							gravar_log_tasy(cd_log_p => 50, ds_log_p => ds_alteracao_rastre_w, nm_usuario_p => nm_usuario_p);
						end;

						end;
					end loop;
					close c03;					

				end if;

			end;
		end if;

		ie_commit_w := 'S';

	end;
end if;

if	(ie_commit_w = 'S') then
	commit;
end if;

end altera_status_analise_gpt;
/
