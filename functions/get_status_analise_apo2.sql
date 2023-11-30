create or replace function get_status_analise_apo2(nr_atendimento_p number,
                                                  cd_pessoa_fisica_p varchar2,
                                                  nr_prescricao_p prescr_medica.nr_prescricao%type,
                                                  ie_opcao_p varchar2 default null) return varchar2 is

/*
ie_opcao_p = 1: Retorna ordenacao (1-Pendente, 2-Em analise, 3-Finalizada)
ie_opcao_p = 2: Retorna descricao (Pendente, Em analise, Finalizada)
*/

ie_status_w		varchar2(150 char);
ie_param_518_w    varchar2(1 char);
dt_inicio_analise_enf_w date;
dt_fim_analise_enf_w date;
nm_compl_resp_analise_enf_w varchar2(255);
dt_inicio_analise_farm_w date;
dt_fim_analise_farm_w date;
nm_compl_resp_analise_farm_w varchar2(255);

begin
ie_param_518_w := nvl(obter_valor_param_usuario(3130, 518, obter_perfil_ativo, wheb_usuario_pck.get_nm_usuario, wheb_usuario_pck.get_cd_estabelecimento),'N');
dt_inicio_analise_enf_w := obter_dt_analise_apo2(nr_prescricao_p,'E','DTI');
dt_fim_analise_enf_w := obter_dt_analise_apo2(nr_prescricao_p,'E','DTF');
nm_compl_resp_analise_enf_w := obter_resp_analise_apo2(nr_prescricao_p,'E','NM');
dt_inicio_analise_farm_w := obter_dt_analise_apo2(nr_prescricao_p,'F','DTI');
dt_fim_analise_farm_w := obter_dt_analise_apo2(nr_prescricao_p,'F','DTF');
nm_compl_resp_analise_farm_w := obter_resp_analise_apo2(nr_prescricao_p,'F','NM');

if (ie_param_518_w = 'E') then

    if	(dt_inicio_analise_enf_w is not null) and
        (dt_fim_analise_enf_w is null) and
        (nm_compl_resp_analise_enf_w is not null) then

            if	(ie_opcao_p = 1) then
                ie_status_w	:=	2;
            else
                ie_status_w	:=	substr(wheb_mensagem_pck.get_texto(1199197), 1, 150);
            end if;

    elsif	(dt_fim_analise_enf_w is not null) and
            (nm_compl_resp_analise_enf_w is not null) then

                if	(ie_opcao_p = 1) then
                    ie_status_w	:=	3;
                else
                    ie_status_w	:=	substr(wheb_mensagem_pck.get_texto(1199198), 1, 150);
                end if;

    else

        if	(ie_opcao_p = 1) then
            ie_status_w	:=	1;
        else
            ie_status_w	:=	substr(wheb_mensagem_pck.get_texto(1139207), 1, 150);
        end if;

    end if;

elsif (ie_param_518_w = 'F') then

    if	(dt_inicio_analise_farm_w is not null) and
        (dt_fim_analise_farm_w is null) and
        (nm_compl_resp_analise_farm_w is not null) then

            if	(ie_opcao_p = 1) then
                ie_status_w	:=	2;
            else
                ie_status_w	:=	substr(wheb_mensagem_pck.get_texto(1199197),1 ,150);
            end if;

    elsif	(dt_fim_analise_farm_w is not null) and
            (nm_compl_resp_analise_farm_w is not null) then

                if	(ie_opcao_p = 1) then
                    ie_status_w	:=	3;
                else
                    ie_status_w	:=	substr(wheb_mensagem_pck.get_texto(1199198),1 ,150);
                end if;

    else

        if	(ie_opcao_p = 1) then
            ie_status_w	:=	1;
        else
            ie_status_w	:=	substr(wheb_mensagem_pck.get_texto(1139207),1 ,150);
        end if;

    end if;

end if;

return	ie_status_w;

end get_status_analise_apo2;