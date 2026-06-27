// Vendored from https://github.com/beyond-the-cloud-dev/apex-consts (MIT License).
// See .agents/standards/APEX_CONSTANTS_FRAMEWORK.md for usage rules.
// Add one static property below per {SObject}Consts class created under concrete-consts/.
@SuppressWarnings('PMD.PropertyNamingConventions')
public class Consts {
    public static final AccountConsts ACCOUNT {
        get {
            return AccountConsts.INSTANCE;
        }
    }

    public static final ContactConsts CONTACT {
        get {
            return ContactConsts.INSTANCE;
        }
    }

    public static final OpportunityConsts OPPORTUNITY {
        get {
            return OpportunityConsts.INSTANCE;
        }
    }

    public static final ProfileConsts PROFILE {
        get {
            return ProfileConsts.INSTANCE;
        }
    }
}
