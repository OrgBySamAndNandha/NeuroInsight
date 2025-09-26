const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize the Firebase Admin SDK
admin.initializeApp();

/**
 * Notification 1: Welcome new users.
 * Triggers when a new user account is created in Firebase Authentication.
 */
exports.sendWelcomeNotification = functions.auth.user().onCreate(
    async (user) => {
      const displayName = user.displayName || "User";
      const userId = user.uid;

      // Get the user's FCM token from the 'users' collection
      const userDoc = await admin
          .firestore()
          .collection("users")
          .doc(userId)
          .get();

      // Exit if the user document or token doesn't exist
      if (!userDoc.exists || !userDoc.data().fcmToken) {
        console.log(`No FCM token found for new user: ${displayName}`);
        return null;
      }

      const fcmToken = userDoc.data().fcmToken;

      const payload = {
        notification: {
          title: `Welcome to Neural Insight, ${displayName}!`,
          body: "We're glad to have you on this journey with us.",
        },
        token: fcmToken,
      };

      console.log(`Sending welcome notification to: ${displayName}`);
      return admin.messaging().send(payload);
    },
);

/**
 * Notification 2: Daily routine reminder.
 * Scheduled function that runs every day at 8:00 AM IST.
 */
exports.sendDailyRoutineNotification = functions.pubsub
    .schedule("every day 08:00")
    .timeZone("Asia/Kolkata")
    .onRun(async () => {
      const now = new Date();
      const hour = now.getHours();
      let routinePeriod = "Morning";

      if (hour >= 12 && hour < 17) {
        routinePeriod = "Afternoon";
      } else if (hour >= 17 && hour < 21) {
        routinePeriod = "Evening";
      } else if (hour >= 21 || hour < 4) {
        routinePeriod = "Night";
      }

      // Get all users who have an FCM token
      const usersSnapshot = await admin
          .firestore()
          .collection("users")
          .where("fcmToken", "!=", null)
          .get();

      if (usersSnapshot.empty) {
        console.log("No users found with FCM tokens.");
        return null;
      }

      const promises = [];
      usersSnapshot.forEach((doc) => {
        const fcmToken = doc.data().fcmToken;
        const payload = {
          notification: {
            title: "Your Daily Routine is Ready!",
            body:
                        "Here are your " +
                        routinePeriod +
                        " tasks to keep your mind sharp.",
          },
          token: fcmToken,
        };
        promises.push(admin.messaging().send(payload));
      });

      console.log(
          `Sending ${promises.length} daily routine notifications.`,
      );
      return Promise.all(promises);
    });

/**
 * Notification 3: Appointment request confirmation.
 * Triggers when a new document is created in the 'appointments' collection.
 */
exports.notifyOnAppointmentCreate = functions.firestore
    .document("appointments/{appointmentId}")
    .onCreate(async (snap) => {
      const appointmentData = snap.data();
      const patientId = appointmentData.patientId;

      // Get patient's FCM token from the 'users' collection
      const userDoc = await admin
          .firestore()
          .collection("users")
          .doc(patientId)
          .get();

      if (!userDoc.exists || !userDoc.data().fcmToken) {
        console.log(
            "No FCM token for user " +
                patientId +
                " on new appointment.",
        );
        return null;
      }

      const fcmToken = userDoc.data().fcmToken;

      const payload = {
        notification: {
          title: "Appointment Request Sent!",
          body:
                    "Your request has been submitted. " +
                    "We will notify you of any updates.",
        },
        token: fcmToken,
      };

      console.log(
          `Sending appointment creation notification to user: ${patientId}`,
      );
      return admin.messaging().send(payload);
    });

/**
 * Notification 4: Doctor confirms appointment with schedule.
 * Triggers when a document in the 'appointments' collection is updated.
 */
exports.notifyOnAppointmentUpdate = functions.firestore
    .document("appointments/{appointmentId}")
    .onUpdate(async (change) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();

      // Only send if status changed to 'confirmed'
      if (
        beforeData.status !== "confirmed" &&
            afterData.status === "confirmed"
      ) {
        const patientId = afterData.patientId;
        const confirmedDoctorId = afterData.confirmedDoctorId;
        const appointmentTimestamp = afterData.appointmentDate;

        // Get the Doctor's name from the 'doctors' collection
        const doctorDoc = await admin
            .firestore()
            .collection("doctors")
            .doc(confirmedDoctorId)
            .get();
        let doctorName = "Your Doctor";
        if (doctorDoc.exists) {
          doctorName = doctorDoc.data().doctorName;
        }

        // Get patient's FCM token from the 'users' collection
        const userDoc = await admin
            .firestore()
            .collection("users")
            .doc(patientId)
            .get();

        if (!userDoc.exists || !userDoc.data().fcmToken) {
          console.log(
              "No FCM token for user " +
                    patientId +
                    " on appointment confirmation.",
          );
          return null;
        }

        const fcmToken = userDoc.data().fcmToken;

        // Convert the Firestore timestamp to a readable date string
        const appointmentDate = appointmentTimestamp.toDate();
        const formattedDate = new Intl.DateTimeFormat(
            "en-US",
            {
              dateStyle: "full",
              timeStyle: "short",
            },
        ).format(appointmentDate);

        const payload = {
          notification: {
            title: "Your Appointment is Confirmed!",
            body:
                        "Your appointment with " +
                        doctorName +
                        " is scheduled for " +
                        formattedDate +
                        ".",
          },
          token: fcmToken,
        };

        console.log(
            "Sending appointment confirmation to user: " + patientId,
        );
        return admin.messaging().send(payload);
      }

      // If status did not change to 'confirmed', do nothing
      return null;
    });
