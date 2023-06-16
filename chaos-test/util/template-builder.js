class TemplateBuilder {
  static createTemplate(serviceName) {
    return {
      actions: {
        'lambda all operation': {
          actionId: 'localstack:generic:api-error',
          parameters: {
            service: serviceName,
            percentage: '100',
            exception: 'exception, terrible error in lambda',
            errorCode: '500',
            region: 'us-west-2'
          }
        }
      },
      description: 'terrible error in lambda - 1',
      stopConditions: [
        {
          source: 'none'
        }
      ],
      roleArn: 'arn:aws:iam:123456789012:role/ExperimentRole'
    };
  }
}

module.exports = { TemplateBuilder };
