﻿using System.Linq;
using Frapid.ApplicationState.Cache;
using Frapid.Account.DTO;
using Frapid.DataAccess;

namespace Frapid.Account.DAL
{
    public static class FacebookSignIn
    {
        public static LoginResult SignIn(string facebookUserId,  string email, int officeId, string name, string token, string browser,
            string ipAddress, string culture)
        {
            const string sql =
                "SELECT * FROM account.fb_sign_in(@0::text,@1::text,@2::integer,@3::text,@4::text,@5::text,@6::text,@7::text);";
            return Factory.Get<LoginResult>(AppUsers.GetCatalog(), sql, facebookUserId, email, officeId, name, token, browser,
                ipAddress, culture).FirstOrDefault();
        }
    }
}