import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";

admin.initializeApp();

async function sendEmail(email: string) {
  const transport = nodemailer.createTransport({
    host: "smtp.mailtrap.io",
    port: 2525,
    auth: {
      user: "b192f938f3e18f",
      pass: "315b67084fc42a",
    },
  });

  const info = await transport.sendMail({
    from: "\"Eventss\" <admin@eventss.com>",
    to: email,
    subject: "Eventss Registration",
    text: "Thank you for registering on Eventss, your registration is pending review. Expect a follow-up email when our review is complete",
    html: "<b>Thank you for registering on Eventss, your registration is pending review. </b><b>Expect a follow-up email when our review is complete</b>",
  });

  functions.logger.info("Message sent: %s", info.messageId);
}

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
    sendEmail(data.email);
    return ({
      message: `User with ID: ${data.id} added`,
      error: false, data: data,
    });
  } catch (error) {
    return ({message: error, error: true});
  }
});
