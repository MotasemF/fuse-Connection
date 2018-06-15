using Uno;
using Uno.UX;
using Uno.IO;
using Fuse.Triggers;
using Fuse.Triggers.Actions;
using Uno.Threading;
using Fuse;
using Uno.Permissions;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Scripting;

[extern(Android) ForeignInclude (Language.Java,
    "android.net.ConnectivityManager",
    "android.net.NetworkInfo",
    "android.app.Activity",
    "android.content.Context")]

[UXGlobalModule]
public class Connection: NativeModule
{
    static readonly Connection _instance;
    public Connection()
    {
        if(_instance != null) return;
        _instance = this;

        if defined(Android){
            Permissions.Request(Permissions.Android.ACCESS_NETWORK_STATE).Then(OnPermissionsPermitted,OnPermissionsRejected);
        }

        Resource.SetGlobalKey(_instance, "Connection");
        AddMember(new NativeFunction("isConnected", (NativeCallback)isConnected));
    }
    object isConnected(Context c, object[] args)
    {
        return getConnection();
    }

    [Foreign(Language.Java)]
    private static extern(Android) bool getConnection(){
        @{
            Activity a = com.fuse.Activity.getRootActivity();
            boolean haveConnectedWifi = false;
            boolean haveConnectedMobile = false;

            ConnectivityManager cm = (ConnectivityManager) a.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo[] netInfo = cm.getAllNetworkInfo();
            for (NetworkInfo ni : netInfo) {
                if (ni.getTypeName().equalsIgnoreCase("WIFI"))
                    if (ni.isConnected())
                        haveConnectedWifi = true;
                if (ni.getTypeName().equalsIgnoreCase("MOBILE"))
                    if (ni.isConnected())
                        haveConnectedMobile = true;
            }
            return haveConnectedWifi || haveConnectedMobile;
        @}
    }

    
    private static extern(iOS) bool getConnection(){
        return false;
    }


    private static extern(!Mobile) bool getConnection(){
        return false;
    }


    extern(Android) void OnPermissionsPermitted(PlatformPermission p)
    {
        debug_log("Permissions allowed" + p);
    }

    extern(Android) void OnPermissionsRejected(Exception e)
    {
        debug_log("PermissionDenied "+ e);
    }




}