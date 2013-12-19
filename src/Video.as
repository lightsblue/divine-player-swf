package {

  import flash.events.NetStatusEvent;
  import flash.media.SoundTransform;
  import flash.net.NetConnection;
  import flash.net.NetStream;
  import flash.external.ExternalInterface;

  public class Video extends flash.media.Video {

    private var url: String;
    private var autoplay: Boolean;
    private var loop: Boolean;
    private var muted: Boolean;
    private var playing: Boolean;

    private var stream: NetStream;
    private var connection: NetConnection = new NetConnection();

    public function Video(url: String, width: uint, height: uint, autoplay: Boolean = true, loop: Boolean = true, muted: Boolean = true) {
      super(width, height);

      this.url = url;
      this.autoplay = autoplay;
      this.loop = loop;
      this.muted = muted;

      connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
      connection.connect(null);
    }

    public function play(): void {
      playing = true;
      stream.resume();
    }

    public function pause(): void {
      playing = false;
      stream.pause();
    }

    public function currentTime(offset:Number): void {
      stream.seek(offset);
    }

    public function getCurrentTime(): Number {
      return stream.time;
    }

    public function isPaused(): Boolean {
      return !playing;
    }

    public function mute(): void {
      muted = true;
      stream.soundTransform = new SoundTransform(0);
    }

    public function unmute(): void {
      muted = false;
      stream.soundTransform = new SoundTransform(1);
    }

    public function isMuted(): Boolean {
      return muted;
    }

    private function throwError(code: int, description: String): void {
      var onError: String = loaderInfo.parameters.onError;
      if (onError) {
        ExternalInterface.call(["divinePlayer", ExternalInterface.objectID, "onError"].join("_"), code, description);
      }
    }

    private function netStatusHandler(e: NetStatusEvent): void {
      switch (e.info.code) {
        case "NetConnection.Connect.Success":
          stream = new NetStream(connection);
          stream.bufferTime = 0.5;
          stream.client = {};
          stream.client.onMetaData = function(infoObject:Object): void {
            if (infoObject.hasOwnProperty("duration") && infoObject["duration"] is Number) {
              var onDuration: String = loaderInfo.parameters.onDuration;
              ExternalInterface.call(["divinePlayer", ExternalInterface.objectID, "onDuration"].join("_"), infoObject["duration"]);
            }
          };
          stream.soundTransform = new SoundTransform(muted ? 0 : 1);
          stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
          attachNetStream(stream);

          stream.play(url);
          if (autoplay) {
            playing = true;
          } else {
            playing = false;
            pause();
          }
          break;
        case "NetStream.Play.Stop":
          if (loop) stream.seek(0);
          break;
        case "NetConnection.Connect.Failed":
        case "NetStream.Play.StreamNotFound":
           throwError(e.info.code, e.info.description);
           break;
         default:
           if (e.info.level == "error") {
             throwError(e.info.code, e.info.description);
           }
      }
    }

  }

}
