const fs = require('fs');
const nunjucks = require('nunjucks');
const AWS = require('aws-sdk');

function setup() {
  AWS.config.update({
    region: 'us-west-2',
    endpoint: 'http://127.0.0.1:4566'
  });

  AWS.config.credentials = new AWS.Credentials({
    accessKeyId: 'test',
    secretAccessKey: 'test'
  });
}
function convert() {
  const args = process.argv;
  if (args.length === 3) {
    console.log('---------- 1 convert');
    nunjucks.configure('./environments/us-west-2', { autoescape: true });
    console.log('---------- 2 convert');
    const str = nunjucks.render('local.yml.njk', { HOSTED_ZONE: args[2] });
    fs.writeFileSync('./environments/us-west-2/local.yml', str);
  }
  console.log(args);

  console.log('---------- 3 convert');
}

module.exports = { convert };

setup();
convert();
