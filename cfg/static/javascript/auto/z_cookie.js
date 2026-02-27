function getCookie(c_name)
{
var c_value = document.cookie;
var c_start = c_value.indexOf(" " + c_name + "=");
if (c_start == -1)
  {
  c_start = c_value.indexOf(c_name + "=");
  }
if (c_start == -1)
  {
  c_value = null;
  }
else
  {
  c_start = c_value.indexOf("=", c_start) + 1;
  var c_end = c_value.indexOf(";", c_start);
  if (c_end == -1)
    {
    c_end = c_value.length;
    }
  c_value = unescape(c_value.substring(c_start,c_end));
  }
return c_value;
}

function setCookie(c_name,value,exdays)
{
	var exdate=new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value=escape(value) + ((exdays==null) ? "" : ";expires="+exdate.toUTCString()) +";path=/";
	document.cookie=c_name + "=" + c_value;
}


if (getCookie("cookiesAccepted") != "true"){

	Event.observe(window, 'load', function() {
  		var div = new Element ('div', {
    	 	 id: 'ep_cookies_overlay'
  		});
  		var div_content = new Element ('div', {
		 id: 'ep_cookies_box',
		 'class': 'border shadow',
		});
  		var h3_message = new Element ('h3', {
    	 	 id: 'ep_cookie_head'
  		});
  		var div_message = new Element ('div', {
    		 id: 'ep_cookies_message',
		 'class': 'ep_cookies_messages'
  		});

  		var div_accept = new Element ('div', {
    	 	 id: 'ep_cookies_accept',
     	 	 'class': 'cookies_button btn-docklands border'
  		});
		var div_post_button = new Element ('div', {
		 id: 'ep_cookies_post_button',
		 'class': 'ep_cookies_messages'
		});

  		div.insert (div_content);
  		div_content.insert (h3_message);
  		div_content.insert (div_message);
  		div_content.insert (div_accept);
		div_content.insert (div_post_button);
  
  		div.hide ();
  		$(document.body).insert (div);

  		div_accept.observe ('click', function(e) {
    
    			setCookie("cookiesAccepted","true",100);
    			Effect.Fade ('ep_cookies_overlay', {
    	 	 	 duration: .5
    			})
  		});


  		eprints.currentRepository().phrase ({'cookies_title': {},'cookies_help': {}, 'cookies_action_accept': {}, 'cookies_post_button_message': {}}, function(phrases) {
    			h3_message.insert (phrases['cookies_title']);
    			div_message.insert (phrases['cookies_help']);
    			div_accept.insert (phrases['cookies_action_accept']);
			div_post_button.insert (phrases['cookies_post_button_message']);

    			Effect.Appear ('ep_cookies_overlay', {
      	 	 	 duration: .0
    			});
			Effect.Appear ('ep_cookies_box', {
                         duration: .5
                        });

  		});
	});

}


