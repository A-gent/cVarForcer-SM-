/*
 * ma_cexec equivalent for server-side sourcemod control
 *
 * penned
 *
 */

#include <sourcemod>

#pragma semicolon 1
#define PLUGIN_VERSION "1.0.0.3"

public Plugin:myinfo =
{
    name = "Client Execute (cVarForcer)",
    author = "knight",
    description = "Execute commands on clients from Server-side with SourceMod",
    version = PLUGIN_VERSION,
    url = "https://a-gent.github.io/cVarForcer-SM-/"
};


public OnPluginStart ()
{
    CreateConVar ("cvarforcer_version", PLUGIN_VERSION, "Client Exec (cVarForcer) v1.09-1.90", FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
    /* register the cvarforcer console command */
    RegAdminCmd ("cvarforcer", ClientExec, ADMFLAG_RCON);
}

public Action:ClientExec (client, args)
{
    decl String:szClient[MAX_NAME_LENGTH] = "";
    decl String:szCommand[80] = "";
    static iClient = -1, iMaxClients = 0;

    iMaxClients = GetMaxClients ();

    if (args == 2)
    {
        GetCmdArg (1, szClient, sizeof (szClient));
        GetCmdArg (2, szCommand, sizeof (szCommand));

        if (!strcmp (szClient, "#all", false))
        {
            for (iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected (iClient) && IsClientInGame (iClient))
                {
                    if (IsFakeClient (iClient))
                        FakeClientCommand (iClient, szCommand);
                    else
                        ClientCommand (iClient, szCommand);
                }
            }
        }
        else if (!strcmp (szClient, "#bots", false))
        {
            for (iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected (iClient) && IsClientInGame (iClient) && IsFakeClient (iClient))
                    FakeClientCommand (iClient, szCommand);
            }
        }
        else if ((iClient = FindTarget (client, szClient, false, true)) != -1)
        {
            if (IsFakeClient (iClient))
                FakeClientCommand (iClient, szCommand);
            else
                ClientCommand (iClient, szCommand);
        }
    }
    else
    {
        ReplyToCommand (client, "cVarForcer: invalid format");
        ReplyToCommand (client, "Usage: cvarforcer \"<user>\" \"<command>\"");
    }

    return Plugin_Handled;
}

