const https = require('https');
const util = require('util');
const AWS = require('aws-sdk');
const ec2 = new AWS.EC2();
const cwEvents = new AWS.CloudWatchEvents({ apiVersion: '2015-10-07' });

exports.handler = (event, context, callback) => {
  console.log(event);
  // 'djin-newswires-eim-base'
  // First get the id of the existing image (if there is one)
  describeImages(event.imageName)
    // Now deregsiter the image if there is one already there
    .then((images) => {
      return deregisterImage(images)
    })
    // Now get the current Instance Id
    .then((result) => {
      return describeInstances(event.instanceName);
    })
    // Now create the new image
    .then((instanceId) => {
      return createImage(instanceId, event.imageName, event.description);
    })
    // All done so disable the rule
    .then((result) => {
     return disableRule(event.ruleName, event.disableRule);
    })
    // Try and send a message to slack
    .then((result) => {
      return sendSlackMessage(event.imageName, event.instanceName, event.webHook, event.ruleName, true);
    })
    // OK All done
    .then((result) => {
      console.log('All actions completed successfully');
    })
    // Catch all errors
    .catch((err) => {
      console.log(err);
      console.log('OOOps something went terribly wrong');
      return sendSlackMessage(event.imageName, event.instanceName, event.webHook, event.ruleName, false);
    });

  function describeImages(imageName) {
    console.log('Getting avaialble Images')
    return new Promise((resolve, reject) => {
      let params = {
        Filters: [
          {
            Name: 'name',
            Values: [
              imageName
            ]
          }
        ]
      }
      ec2.describeImages(params, function (err, data) {
        if (err) {
          console.log(`*********** Error Describing Images`);
          reject(JSON.stringify(err))
        } else {
          console.log(`Found ${data.Images.length} images.`)
          resolve(data.Images)
        }
      });

    })
  }

  function deregisterImage(images) {
    console.log('Deregistering Image')
    return new Promise((resolve, reject) => {
      console.log(`Found ${images.length} images`)
      if (images.length > 0) {
        console.log(`Deregistering Image ${images[0].ImageId}`);
        params = {
          ImageId: images[0].ImageId
        };
        ec2.deregisterImage(params, (err, data) => {
          if (err) {
            console.log(`*********** Error Deregistering Image`);
            reject(JSON.stringify(err));
          } else {
            console.log("Successfully deregistered AMI")
            resolve('Deregistered');
          }
        });
      } else {
        console.log('Skipping deregsitration')
        resolve('Skipped Deregsiter');
      }
    });

  }

  function describeInstances(instanceName) {
    console.log('Getting avaialble Instances')
    return new Promise((resolve, reject) => {
      params = {
        Filters: [
          {
            Name: 'tag:Name',
            Values: [
              instanceName
            ]
          },
          {
            Name: 'instance-state-name',
            Values: [
              'running'
            ]
          }
        ]
      };
      ec2.describeInstances(params, (err, data) => {
        if (err) {
          console.log(`*********** Error Describing Instances`);
          reject(JSON.stringify(err));
        } else {
          if (data.Reservations.length > 0) {
            console.log(`Found Instance: ${data.Reservations[0].Instances[0].InstanceId}`);
            resolve(data.Reservations[0].Instances[0].InstanceId);
          } else {
            reject("Instance not found")
          }
        }
      });
    })
  }

  function createImage(instanceId, imageName, description) {
    console.log('Creating New Image')
    return new Promise((resolve, reject) => {
      params = {
        InstanceId: instanceId,
        Name: imageName,
        Description: description,
        NoReboot: true
      };
      ec2.createImage(params, (err, data) => {
        if (err) {
          console.log(`*********** Error Creating Image`);
          reject(JSON.stringify(err));
        }
        else {
          console.log('Image created succeefully');
          resolve('Image created');
        }
      });
    })
  }

  function disableRule(ruleName, disableRule) {
    console.log('Disabling Rule')
    return new Promise((resolve, reject) => {
      if (disableRule) {
        const params = {
          Name: ruleName
        };
        
        cwEvents.disableRule(params, (err, data) => {
          if (err) {
            console.log(`*********** Error dsiabling rule ${params.Name}`);
            reject(JSON.stringify(err));
          } else {
            console.log('Rule Successfully disabled')
            resolve('Rule Successfully disabled');
          }
        });
      } else {
        console.log("Rule not disabled");
        resolve("Disable rule skipped");
      }
      
    })
  }

  function sendSlackMessage(imageName, instanceName, webHook, ruleName, success) {
    console.log("Sending message to slack");
    return new Promise((resolve, reject) => {
      const POST_OPTIONS = {
        hostname: 'hooks.slack.com',
        path: webHook,
        method: 'POST',
      }
      const message = {
        username: "Instance Snapshot Creator",
        text: '',
        icon_emoji: ":aws:"
      };

      if (success) {
        message.text = `AMI ${imageName} created from instance ${instanceName} by rule ${ruleName}`;
      } else {
        message.text = `*** Failed to create AMI ${imageName} created from instance ${instanceName} by rule ${ruleName}, please see CloudWatch logs for more details`;
      }

      let req = https.request(POST_OPTIONS, function (res) {
        res.setEncoding('utf8');
        res.on('data', function (data) {
          console.log('Message successfully sent')
          resolve("Message Sent: " + data);
        });
      }).on("error", function (e) {
        reject("Failed: " + e);
      });
      req.write(util.format("%j", message));
      req.end();
    });
  }

};