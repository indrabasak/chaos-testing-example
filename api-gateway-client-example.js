const {
  APIGatewayClient,
  GetDomainNameCommand
} = require('@aws-sdk/client-api-gateway');

// eslint-disable-next-line no-unused-vars
async function test() {
  // const gateway = new APIGatewayClient({
  //   region: 'us-west-2',
  //   invokeUrl: 'http://localhost:4566',
  //   credentials: {
  //     accessKeyId: 'test',
  //     secretAccessKey:
  //       'FwoGZXIvYXdzEBAaDO2YXFkpcQMRlfUkQyL+AeVNR/HCwI3bZh0h7Yftnettmnulh381AYfZAEQCMwrsONx8aeaX4bGcCHcxkwinYfZ+jH2ptFo67MUcWdbIFoFVopcBFAIGeGvNJ/47sgWhCQ0NBKfdwzpVECcZdXzj6Nxfk++SNlWMfhChl9kcdbkCeOGNKWC2KiCEyQiB1hA1N0y1H4IUbTjaZKO//i6ZNHv+5QrVduEmNxERtQEFdKCegmC7N8Faoe1mo2YSBBR8LfmAfwTHT6SNFc8/bAEPfFndM68fduVWCM5+ALUVLi1q6f/bnBJa/R+WQWePDMY9D/cHQ30llPTBh67+g82KMZS7cQYj0HeelxxmHz2HKIWotaQGMjMXy0RuLQNzYKhmVJkUbuAytwtXGRSffYp9O64914gE4Spf43DL2l7BrfuCSbO5aGfa8R4=Lees-'
  //   }
  // });

  const gateway = new APIGatewayClient({
    endpoint: 'http://localhost:4566',
    region: 'us-west-2',
    credentials: {
      accessKeyId: 'test',
      secretAccessKey: 'test'
    }
  });
  const domainInfo = await gateway.send(
    new GetDomainNameCommand({
      domainName: 'chaos-example.demo.com'
    })
  );

  console.log(domainInfo);
}

module.exports = { test };

test();
