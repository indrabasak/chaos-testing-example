const {ServerlessCustomDomain} = require('serverless-domain-manager');

class CustomServerlessCustomDomain extends ServerlessCustomDomain {
  constructor(serverless, options) {
    super(serverless, options);
    this.serverless = serverless;
  }

  async init() {
    this.serverless.cli.log('CustomServerlessCustomDomain::Init');
  }
}

module.exports = CustomServerlessCustomDomain;
