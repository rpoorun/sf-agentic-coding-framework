/**
 * @description       : Lazy singleton holding Account picklist values and the object's API name. Adapted from beyond-the-cloud-dev/apex-consts.
 * @author            : {author_name} <{author_email}>
 * @group             : Constants
 * @last modified on  : {DD-MM-YYYY}
 * @last modified by  : {author_name} <{author_email}>
 * @test              : AccountConstantsTest
 **/
@SuppressWarnings('PMD.FieldNamingConventions, PMD.EmptyStatementBlock')
public class AccountConstants {
    public static final AccountConstants INSTANCE = new AccountConstants();

    public final String API_NAME = Account.sObjectType.getDescribe().getName();

    public final Type TYPE = new Type();
    public final Rating RATING = new Rating();

    public class Type {
        public final String CHANNEL_PARTNER_RESELLER = 'Channel Partner / Reseller';
        public final String CUSTOMER_CHANNEL = 'Customer - Channel';
        public final String CUSTOMER_DIRECT = 'Customer - Direct';
        public final String INSTALLATION_PARTNER = 'Installation Partner';
        public final String OTHER = 'Other';
        public final String PROSPECT = 'Prospect';
        public final String TECHNOLOGY_PARTNER = 'Technology Partner';
    }

    public class Rating {
        public final String COLD = 'Cold';
        public final String HOT = 'Hot';
        public final String WARM = 'Warm';
    }

    private AccountConstants() {}
}
