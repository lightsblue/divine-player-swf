package {

  import flash.external.ExternalInterface;

  public class Logger {

    public static function log(... args: *): void {
      ExternalInterface.call("console.log", args.join(", "));
    }

    public static function error(... args: *): void {
      ExternalInterface.call("console.error", args.join(", "));
    }

  }

}
