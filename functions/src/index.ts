import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const createUser = functions.https.onCall(async (data, context) => {
  functions.logger.info("createUser logs!", {structuredData: true});

  try {
    await admin.firestore().collection("users").add({
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      phoneNumber: data.phoneNumber,
      approved: false,
    });
    return ({
      message: `User with ID: ${data.id} added`,
      error: false, data: data,
    });
  } catch (error) {
    return ({message: error, error: true});
  }
});
