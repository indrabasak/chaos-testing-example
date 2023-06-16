const {
  FisClient,
  CreateExperimentTemplateCommand,
  StartExperimentCommand,
  StopExperimentCommand,
  DeleteExperimentTemplateCommand
} = require('@aws-sdk/client-fis');
const { TemplateBuilder } = require('./template-builder');

class ExperimentHelper {
  constructor(endpoint, region) {
    this.endpoint = endpoint;
    this.region = region;

    this.client = new FisClient({
      endpoint: this.endpoint,
      region: this.region
    });
  }

  async startExperiment(service) {
    try {
      const params = TemplateBuilder.createTemplate(service);
      const command = new CreateExperimentTemplateCommand(params);
      const data = await this.client.send(command);
      this.experimentTemplateId = data.experimentTemplate.id;
      console.log(data);

      const startCmd = new StartExperimentCommand({
        experimentTemplateId: this.experimentTemplateId
      });
      const startResponse = await this.client.send(startCmd);
      console.debug(startResponse);
      this.experimentId = startResponse.experiment.id;
    } catch (e) {
      console.debug(e);
      throw new Error('Failed to create experiment');
    }
  }

  async stopExperiment() {
    if (this.experimentId) {
      const stopCmd = new StopExperimentCommand({ id: this.experimentId });
      const stopRsp = await this.client.send(stopCmd);
      console.log(stopRsp);
    }

    if (this.experimentTemplateId) {
      const deleteCmd = new DeleteExperimentTemplateCommand({
        id: this.experimentTemplateId
      });
      const deleteRsp = await this.client.send(deleteCmd);
      console.log(deleteRsp);
    }
  }
}

module.exports = { ExperimentHelper };
