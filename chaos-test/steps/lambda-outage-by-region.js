/**
 * Cucumber steps for chaos testing of an example application
 *
 * @author Indra Basak
 * @since Jun 14, 2023
 */
const { Given, Then, When, After } = require('@cucumber/cucumber');
const assert = require('assert').strict;
require('dotenv-flow').config();
const { ExperimentHelper } = require('../util/experiment-helper');
const { RestHelper } = require('../util/rest-helper');

const helper = new ExperimentHelper(
  process.env.LOCALSTACK_URL,
  process.env.AWS_REGION
);

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
  await helper.startExperiment('lambda');
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
  console.log('Cleaning up experiments');
  await helper.stopExperiment();
});
