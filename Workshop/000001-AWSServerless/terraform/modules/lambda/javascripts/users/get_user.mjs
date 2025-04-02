import { DynamoDBClient, ScanCommand } from "@aws-sdk/client-dynamodb";
const client = new DynamoDBClient({
  region: process.env.REGION,
});

export const handler = async (event) => {
  const input = {
    TableName: process.env.TABLE_NAME,
  };
  const command = new ScanCommand(input);
  let response = {};
  try {
    const data = await client.send(command);
    if (data.Items) {
      response = {
        status: 200,
        data: data.Items.map((item) => {
          return {
            id: item.id.S,
            username: item?.username.S,
            email: item?.email.S,
            first_name: item?.first_name.S,
            last_name: item?.last_name.S,
            phone: item?.phone.S,
          };
        }),
      };
    } else {
      response = data;
    }
  } catch (e) {
    response = {
      status: 401,
      message: e.message,
    };
  }
  return response;
};
