import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";

admin.initializeApp();

async function sendEmail(email: string, subject: string, contentPlain: string, contentHTML: string) {
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
    subject: subject,
    text: contentPlain,
    html: contentHTML,
  });

  functions.logger.info("Message sent: %s", info.messageId);
}

export const createUser = functions.https.onCall(async (data, context) => {
  functions.logger.info("createUser logs!", { structuredData: true });

  try {
    await admin.firestore().collection("users").add({
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      phoneNumber: data.phoneNumber,
      approvalStatus: 'Pending',
    });
    sendEmail(data.email, "Eventss Registration", "Thank you for registering on Eventss, your registration is pending review. Expect a follow-up email when our review is complete", "<b>Thank you for registering on Eventss, your registration is pending review. </b><b>Expect a follow-up email when our review is complete</b>");
    return ({
      message: `User with ID: ${data.id} added`,
      error: false, data: data,
    });
  } catch (error) {
    return ({ message: error, error: true });
  }
});

export const approveRegistration = functions.https.onCall(async (data, context) => {

  try {
    await admin.firestore().collection("users").doc(data.id).update({
      approved: data.approval,
    });
    if (data.approval == false) {
      sendEmail(data.email, "Eventss Registration", "Thank you for registering on Eventss, your registration has been denied", "<b>Thank you for registering on Eventss, your registration has been denied </b>");
    } else {
      sendEmail(data.email, "Eventss Registration", "Thank you for registering on Eventss, your registration has been approved.", "<b>Thank you for registering on Eventss, your registration is has been approved.");
    }

    return ({
      message: `registration confirmed`,
      error: false, data: data,
    });
  } catch (error) {
    return ({ message: error, error: true });
  }
});
