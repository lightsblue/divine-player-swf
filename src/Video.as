package {

  import flash.events.NetStatusEvent;
  import flash.media.SoundTransform;
  import flash.net.NetConnection;
  import flash.net.NetStream;
  import flash.external.ExternalInterface;
  import flash.events.Event;

  public class Video extends flash.media.Video {

    private var url: String;
    private var autoplay: Boolean;
    private var loop: Boolean;
    private var muted: Boolean;
    private var playing: Boolean;
    private var streamTime: Number;

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

      this.addEventListener(Event.ENTER_FRAME, function (e:Event): void {
        if (!stream) { return; }
        if (!isPaused() && stream.time != streamTime) {
          streamTime = stream.time;
          externalCall("onTimeUpdate", streamTime);
        }
      });
    }

    public function play(): void {
      playing = true;
      stream.resume();
      externalCall("onPlay", null);
    }

    public function pause(): void {
      playing = false;
      stream.pause();
      externalCall("onPause", null);
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
      externalCall("onVolumeChange", null);
    }

    public function unmute(): void {
      muted = false;
      stream.soundTransform = new SoundTransform(1);
      externalCall("onVolumeChange", null);
    }

    public function isMuted(): Boolean {
      return muted;
    }

    private function externalCall (key, value): void {
      if (key && isSafe(ExternalInterface.objectID)) {
        ExternalInterface.call(["divinePlayer", ExternalInterface.objectID, key].join("_"), value);
      }
    }

    private function throwError(code: int, description: String): void {
      var onError: String = loaderInfo.parameters.onError;
      if (onError && isSafe(ExternalInterface.objectID)) {
        ExternalInterface.call(["divinePlayer", ExternalInterface.objectID, "onError"].join("_"), code, description);
      }
    }

    private function isSafe(value: String): Boolean {
      return /^[0-9A-Z]+$/i.test(value);
    }

    private function netStatusHandler(e: NetStatusEvent): void {
      switch (e.info.code) {
        case "NetConnection.Connect.Success":
          stream = new NetStream(connection);
          stream.bufferTime = 0.5;
          stream.client = {};
          stream.client.onMetaData = function(infoObject:Object): void {
            if (infoObject.hasOwnProperty("duration") && infoObject["duration"] is Number && isSafe(ExternalInterface.objectID)) {
              var onDuration: String = loaderInfo.parameters.onDuration;
              externalCall("onDuration", infoObject["duration"]);
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
        case "NetStream.Play.Start":
          externalCall("onPlay", null);
          break;
        case "NetStream.Play.Stop":
          externalCall("onEnded", null);
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
