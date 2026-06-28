// Adapted from https://github.com/beyond-the-cloud-dev/apex-consts (MIT License).
// Class names use the full word "Constants", never the abbreviated "Consts".
// See .agents/standards/APEX_CONSTANTS_FRAMEWORK.md for usage rules.
// Add one static property below per {SObject}Constants class created under concrete-constants/.
@SuppressWarnings('PMD.PropertyNamingConventions')
public class Constants {
    public static final AccountConstants ACCOUNT {
        get {
            return AccountConstants.INSTANCE;
        }
    }

    // Add the next object, e.g.:
    // public static final ContactConstants CONTACT {
    //     get {
    //         return ContactConstants.INSTANCE;
    //     }
    // }
}
