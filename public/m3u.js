$(function(){
  $('form#m3u').submit(function(e){
    e.preventDefault();
    var input = $('#username').val();
    $.ajax({
      url: '/'+input+'.json',
      dataType: 'json',
      success: function(data, status, xhr){
        var new_playlist = $('<li class="playlist"><a href="/'+data.permalink+'.m3u"><img src="'+data.avatar_url+'"/></a></li>');
        var link = new_playlist.find(':first-child')
        link.hide();
        $('ul#playlists').append(new_playlist);
        link.fadeIn('slow');
        $('#message').html(data.username + ' added, '+data.track_count+' tracks. Drag their picture to your player of choice, or the bookmarks bar or whatever else you see fit to do with it.');
        $('input[type=text]').val('');
      },
      error: function(xhr, text, thrown){
        alert(input+': '+xhr.responseText);
      }
    });
  });
});  