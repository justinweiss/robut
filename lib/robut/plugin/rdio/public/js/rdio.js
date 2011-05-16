RdioPlayer = (function () {

  function initPlayer (options) {
      // on page load use SWFObject to load the API swf into div#apiswf
    var flashvars = {
      'playbackToken': options.token, // from token.js
      'domain': options.domain,                // from token.js
      'listener': options.callbackName    // the global name of the object that will receive callbacks from the SWF
    };
    var params = {
      'allowScriptAccess': 'always'
    };
    var attributes = {};
    swfobject.embedSWF('http://www.rdio.com/api/swf/', // the location of the Rdio Playback API SWF
                       options.elementId, // the ID of the element that will be replaced with the SWF
                       1, 1, '9.0.0', 'expressInstall.swf', flashvars, params, attributes);
  }

  var updateQueue = function (callbackObject, element) {
    
    $.ajax({
      url: '/queue.json',
      dataType: 'json',
      success: function (data) {
        if (data.length > 0) {

          if (!callbackObject.playing) {
            element.rdio_play(data[0]);
            data = data.slice(1);
          }

          for (var i = 0, _length = data.length; i < _length; i++) {
            element.rdio_queue(data[i]);
          }

        }
      }
    });
  
    setTimeout(function () {
      updateQueue(callbackObject, element)
    }, 5000);
  };

  function createCallback(rdio, callbackName, elementId) {
    var callback = {};

    callback.ready = function () {
      self.ready = true;
      var element = document.getElementById(elementId);
      rdio.player = element;
      updateQueue(callback, element);
    }
    
    callback.playStateChanged = function (playState) {
      if (playState === 1 || playState === 3) {
        callback.playing = true;
      } else {
        callback.playing = false;
      }
    }

    callback.sourceTitle = function (source) {
      return source.artist + " - " + source.name;
    }

    callback.sourceList = function (source) {
      var queue = "";
      for (var i = 0, _length = source.length; i < _length; i++) {
        queue += "<li class=\"source\">" +
          callback.sourceTitle(source[i]) +
          "</li>";
      }
      return queue;
    }
    
    callback.queueChanged = function (newQueue) {
      $('#queue').html(callback.sourceList(newQueue));
      if (newQueue.length > 0) {
        $('#queue_header').show().html('Queue (' + newQueue.length + ')');
      } else {
        $('#queue_header').hide();
      }
    }

    callback.playingSourceChanged = function (playingSource) {
      var source = []
      if (playingSource.tracks) {
        source = playingSource.tracks;
      } else {
        source = [playingSource];
      }
      $('#now_playing').html(callback.sourceList(source));
      $('#album_art').attr('src', playingSource.icon); 
    }

    callback.playingTrackChanged = function(playingTrack, sourcePosition) {
      if (playingTrack) {
        $('#now_playing li').removeClass('playing');
        $('#now_playing li').eq(sourcePosition).addClass('playing');
        $('title').html(callback.sourceTitle(playingTrack) + " - Powered by Rdio");
        $('#current_track').show().html("Now Playing: " + callback.sourceTitle(playingTrack));
      } else {
        $('#current_track').hide();
      }
    }

    window[callbackName] = callback;
    return callback;
  }

  function RdioPlayer (options) {
    this.options = options;
    this.callback = createCallback(this, options.callbackName, options.elementId);
    initPlayer(options);
  }

  return RdioPlayer;
})();

$(document).ready(function () {
  window.rdio = new RdioPlayer({
    token: "GAlNi78J_____zlyYWs5ZG02N2pkaHlhcWsyOWJtYjkyN2xvY2FsaG9zdEbwl7EHvbylWSWFWYMZwfc=",
    domain: "localhost",
    elementId: 'apiswf',
    callbackName: 'rdio_callback'
  });
});

