import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
const client = new DynamoDBClient({
  region: process.env.REGION,
});
const generateUserId = (length = 8) => {
  const characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return `user-${result}`;
};

export const handler = async (event) => {
  for (const record of event.Records) {
    const messageBody = record.body;
    console.log("messageBody: ", messageBody);
    const body = JSON.parse(messageBody);
    const input = {
      TableName: process.env.TABLE_NAME,
      Item: {
        id: { S: generateUserId() },
        email: { S: body.email },
        username: { S: body.username },
        first_name: { S: body.first_name },
        last_name: { S: body.last_name },
        phone: { S: body.phone },
      },
      ConditionExpression: "attribute_not_exists(email)",
    };
    const command = new PutItemCommand(input);
    let response = {};
    try {
      response = await client.send(command);
    } catch (e) {
      console.error("error: ", e);
      response = {
        status: 401,
        message: e.message,
      };
    }
    console.log("response: ", response);
    return response;
  }

  return { statusCode: 200, body: "Success" };
};
