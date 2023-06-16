/**
 * Cucumber steps for chaos testing of an example application
 *
 * @author Indra Basak
 * @since Jun 14, 2023
 */
// eslint-disable-next-line import/no-extraneous-dependencies
const {
  FisClient,
  CreateExperimentTemplateCommand,
  StartExperimentCommand,
  StopExperimentCommand,
  DeleteExperimentTemplateCommand
} = require('@aws-sdk/client-fis');
const { Given, Then, When, After } = require('@cucumber/cucumber');
const assert = require('assert').strict;
require('dotenv-flow').config();
const { RestHelper } = require('../util/rest-helper');
const { TemplateBuilder } = require('../util/template-builder');

const client = new FisClient({
  endpoint: 'http://localhost:4566',
  region: 'us-west-2'
});

/// ////////////////////////////////////////////////////////////////////////////////
// Scenario Outline: test resiliency by injecting chaos to all lambdas in a region
/// ////////////////////////////////////////////////////////////////////////////////
Given(
  'localstack setup is up and running for testing lambdas chaos in a region',
  async () => {
    console.log('Checking if localstack is up');
    const config = {
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const response = await RestHelper.get(
      `${process.env.LOCALSTACK_URL}`,
      config
    );
    assert.equal(response.status, 200);
  }
);

When('request to {} gets a response code of {int}', async (path, code) => {
  const config = {
    headers: {
      'Content-Type': 'application/json'
    }
  };

  const response = await RestHelper.get(
    `${process.env.BASE_URL}${path}`,
    config
  );
  assert.equal(response.status, code);
  console.log('END - health endpoint response successful');
});

When('I inject fault', async () => {
  console.log('1 ------------------------');

  try {
    const params = TemplateBuilder.createTemplate('lambda');
    const command = new CreateExperimentTemplateCommand(params);
    const data = await client.send(command);
    this.experimentTemplateId = data.experimentTemplate.id;
    console.log(data);

    const startCmd = new StartExperimentCommand({
      experimentTemplateId: this.experimentTemplateId
    });
    console.log('2 ------------------------');
    this.startResponse = await client.send(startCmd);
    console.log(this.startResponse);
    this.experimentId = this.startResponse.experiment.id;
  } catch (e) {
    console.log(e);
  }
});

Then(
  'send a GET request to {} and I should get a response code of {int}',
  { timeout: 50 * 1000 },
  async (path, code) => {
    const config = {
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const response = await RestHelper.get(
      `${process.env.BASE_URL}${path}`,
      config
    );

    assert.equal(response.status, code);
    console.log(`END - ${path} endpoint response successful`);
  }
);

Then(
  'resend a GET request to {} and I should get a response code of {int}',
  { timeout: 50 * 1000 },
  async (path, code) => {
    const config = {
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const response = await RestHelper.get(
      `${process.env.BASE_URL}${path}`,
      config
    );

    assert.equal(response.status, code);
    console.log('END - health endpoint response successful');
  }
);

After(async () => {
  console.log('$$$$$$$$$$$$$$$$$$$$$$ Cleaning up experiments');
  console.log(this.startResponse);

  if (this.experimentId) {
    const stopCmd = new StopExperimentCommand({ id: this.experimentId });
    const stopRsp = await client.send(stopCmd);
    console.log(stopRsp);
  }

  if (this.experimentTemplateId) {
    const deleteCmd = new DeleteExperimentTemplateCommand({
      id: this.experimentTemplateId
    });
    const deleteRsp = await client.send(deleteCmd);
    console.log(deleteRsp);
  }
});
