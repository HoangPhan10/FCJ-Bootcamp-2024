import { DynamoDBClient, DeleteItemCommand } from "@aws-sdk/client-dynamodb";
const client = new DynamoDBClient({
  region: process.env.REGION,
});

export const handler = async (event) => {
  const input = {
    TableName: process.env.TABLE_NAME,
    Key: {
      id: { S: event.id },
      email: { S: event.email },
    },
  };
  const command = new DeleteItemCommand(input);
  let response = {};
  try {
    await client.send(command);
    response = {
      status: 200,
      message: "Delete item successfully",
    };
  } catch (e) {
    response = {
      status: 401,
      message: e.message,
    };
  }
  return response;
};
