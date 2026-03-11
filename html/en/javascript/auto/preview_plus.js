var left_hidden_tiles = [];
var right_hidden_tiles = [];

document.observe("dom:loaded", function(){
	var count =1;
	var limit= 0;
	var previews = $$(".ep_preview_plus_tile");
	
	if(previews.length == 0){
		return;
	}
	//120 is the width of the two arrows. because they are tds they get crushed small if you dont hard code the width
	limit = Math.floor(($("ep_inplace_controls_container").getWidth()-120)/previews.first().getWidth());
		
	if(limit >= previews.length){
	      $("ep_inplace_previous_button").hide();
	      $("ep_inplace_next_button").hide()
	}
	previews.each(
		function(el){
        		if(count > limit){
         			right_hidden_tiles.push(el.remove()); 
        		}
        		count++;
				
		}
	);
	
	$("ep_inplace_previous_button").observe("click", function(event){
		if(left_hidden_tiles.length>0){
        		right_hidden_tiles.push($$(".ep_preview_plus_tile").last().remove());
			var new_tile = left_hidden_tiles.shift();
			new_tile.firstChild.hide()
        		$("ep_inplace_tile_container").insertBefore(new_tile, $$(".ep_preview_plus_tile").first());
			new_tile.firstChild.appear({duration:0.5});
			set_arrows();
		}
	});

    	$("ep_inplace_next_button").observe("click", function(event){
		if(right_hidden_tiles.length>0){
        		left_hidden_tiles.unshift($$(".ep_preview_plus_tile").first().remove());
			var new_tile = right_hidden_tiles.shift();
			new_tile.firstChild.hide()
          		$("ep_inplace_tile_container").insertBefore(new_tile, $("ep_inplace_next_button"));
			new_tile.firstChild.appear({ duration: 0.5 });
			set_arrows();
		}
        });
		
	//$$(".ep_preview_plus").first().show();	

	set_arrows();
});

function ep_preview_plus_show(preview_to_show, url){
	var preview_div = $(preview_to_show);
	if(preview_div){
		preview_div.show();
	}else{
		new Ajax.Request(url, {
			method: 'get',
			onLoaded: function(response){
				$('ep_inplace_ajaxload').show();			
			},
			onSuccess: function(response) {
				$('ep_inplace_ajaxload').hide();			
				var preview_div = "<div id='"+preview_to_show+"' class='ep_preview_plus'>"+response.responseText+"</div>";
				var video_id = "player"+preview_to_show;
				preview_div = preview_div.replace(/id="player"/, 'id="'+video_id+'"');
  				$("ep_preview_plus_area").innerHTML += preview_div;
			
				var video_preview = "player"+preview_to_show;
				if(preview_div.match(video_id)){
					$f(video_id, '/flowplayer/flowplayer-3.1.5.swf', { clip: { autoPlay: false, onBeforeBegin: function() { $f("player").close(); }  } });
				}
			}
		});
	}
}

function ep_inplace_tile_click(num, url){
	$$(".ep_preview_plus").each(
		function(prev) {prev.hide();}
	);
	ep_preview_plus_show("ep_preview_plus_"+num, url);
	$("ep_preview_plus_area").scrollTop =0;
}

function set_arrows(){
	if(left_hidden_tiles.length > 0){
	        $("ep_inplace_previous_button").setAttribute("class", "ep_inplace_previous_button_enabled");
	}else{
	        $("ep_inplace_previous_button").setAttribute("class", "ep_inplace_previous_button_disabled");
	}
	if(right_hidden_tiles.length > 0){
	        $("ep_inplace_next_button").setAttribute("class", "ep_inplace_next_button_enabled");
	}else{
	        $("ep_inplace_next_button").setAttribute("class", "ep_inplace_next_button_disabled");
	}
}
