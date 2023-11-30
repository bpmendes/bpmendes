
import { Controller, Inject } from '@philips/odin-ext';
import WPUMC from '../../../../../common/odin-utils/controllers/WPUMC';
@Controller({ domain: 'serter/SerTerF1', code: 1262837, parent: 59802 })
export default class AnalisePrescrOncWJMI extends WPUMC {

    @Inject('externalAccessManager')
    externalAccessManager;

    @Inject('tasyWLoaderPopup')
    tasyWLoaderPopup;

    @Inject('actionRequestService')
    actionRequestService;

    @Inject('DialogBoxType')
    dialogBoxType;

    async action(schematics) {
        const activePanel = schematics.get(59800);
        const param518 = schematics.getParameter(518);
        const nrPrescricao = activePanel.getValue('NR_PRESCRICAO');

        if (param518){
          const parameter = {};
          parameter.NR_PRESCRICAO_P = nrPrescricao;
          const result = await this.executeQueryAsHash('GET_IF_ANALYSIS_ACTIVE', parameter);
          const ieAnalysisIsActive = result.IE_ANALISE_ATIVA;
          const ieNuseHasAnalysis = result.DT_INICIO_ANALISE_ENF;
          if (ieAnalysisIsActive == 'S' || !ieNuseHasAnalysis && param518 == 'F' || ieNuseHasAnalysis && param518 == 'E'){
            this.externalAccessApoFunction(schematics);
          } else {
            const conf = {
              showClose: false,
              okButtonCode: 300446,
              cancelButtonCode: 300445,
              type: this.dialogBoxType.INFORMATION,
              message: 997941,
              defaultShow: 'BOTH'
            };

            this.tasyWdialogbox(conf).then(
              () => {
                return this.startAnalysis(schematics);
              }).finally(() => {
                this.externalAccessApoFunction(schematics);
              });
          }
        } else {
          this.externalAccessApoFunction(schematics);
        }
    }

    startAnalysis(schematics) {
      const activeDbPanel = schematics.get(59800);

      const parameters = {
        NR_ATENDIMENTO_P: activeDbPanel.getValue('NR_ATENDIMENTO'),
        CD_PESSOA_FISICA_P: activeDbPanel.getValue('CD_PESSOA_FISICA'),
        CD_RESP_ANALISE_P: this.sessionData.getUser().cdPessoaFisica,
        IE_TIPO_USUARIO_P: schematics.getParameter(518),
        IE_ACAO_P: 'I',
        NM_USUARIO_P: this.sessionData.getUser().nmUsuario,
        DS_JUSTIFICATIVA_P: null,
        IE_LIB_FARM_P: null,
        IE_RETORNO_CPOE_P: null,
        QT_HORAS_QUIMIO_P: 0,
        NR_PRESCRICAO_P: activeDbPanel.getValue('NR_PRESCRICAO')
      };

      return this.executeProcedure('UPDATE_STATUS_ANALYSIS', parameters);
    }

    externalAccessApoFunction(schematics) {
      const wdbp = schematics.get(59800);
      const SERTERF2 = 476;
      const nrPrescricao = wdbp.getValue('NR_PRESCRICAO');

      this.externalAccessManager.doOpenExternal(SERTERF2, 'externalAccessGPTO', {
        nrPrescricao
      }).then(
        () => {
          wdbp.reactivate();
        },
        () => {
            this.loader = this.tasyWLoaderPopup();
            const params = {};
            params.NR_PRESCRICAO_P = wdbp.getValue('NR_PRESCRICAO');
            params.CD_FUNCAO_P = 476;
            params.procedureID = 10062764;
            this.actionRequestService.request('SerTerF1', 'executeProcedure', [{
                'tipo': 'HashMap',
                'valor': params
            }]).finally(() => {
                this.loader.close();
            });
            wdbp.reactivate();
        });
    }
}
