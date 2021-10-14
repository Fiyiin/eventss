import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";
import * as QRCode from "qrcode";

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

async function generateQR(): Promise<string> {
  return await QRCode.toDataURL("Your registration has been approved!");
}

export const createUser = functions.https.onCall(async (data, context) => {
  try {
    await admin.firestore().collection("users").add({
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      phoneNumber: data.phoneNumber,
      approvalStatus: "Pending",
    });

    sendEmail(data.email, "Eventss Registration", "Thank you for registering on Eventss, your registration is pending review. Expect a follow-up email when our review is complete", "<b>Thank you for registering on Eventss, your registration is pending review. </b><b>Expect a follow-up email when our review is complete</b>");

    await admin.firestore().collection("events").doc(data.eventId).update({
      registered_users: admin.firestore.FieldValue.increment(1),
    });

    return ({
      message: `User with ID: ${data.id} added`,
      error: false, data: data,
    });
  } catch (error) {
    return ({message: error, error: true});
  }
});

export const approveRegistration = functions.https.onCall(async (data, context) => {
  functions.logger.info("approve logs!", {structuredData: true});
  try {
    await admin.firestore().collection("users").doc(data.id).update({
      approvalStatus: data.approvalStatus,
    });
    if (data.approvalStatus == "Denied") {
      sendEmail(data.email, "Eventss Registration", "Thank you for registering on Eventss, your registration has been denied", "<b>Thank you for registering on Eventss, your registration has been denied </b>");
    } else {
      const img = await generateQR();
      sendEmail(data.email, "Eventss Registration", "Thank you for registering on Eventss, your registration has been approved.", "<b>Thank you for registering on Eventss, your registration is has been approved.</b><br><img src=\"" + img + "\" alt=\"QR code\" width=\"500\" height=\"600\">");
    }

    return ({
      message: "registration confirmed",
      error: false, data: data,
    });
  } catch (error) {
    return ({message: error, error: true});
  }
});

export const createEvent = functions.https.onCall(async (data, context) => {
  try {
    await admin.firestore().collection("events").add({
      name: data.name,
      registered_users: 0,
      checked_in_users: 0,
    });

    return ({
      message: "event created",
      error: false, data: data,
    });
  } catch (error) {
    return ({message: error, error: true});
  }
});
