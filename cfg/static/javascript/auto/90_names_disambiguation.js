function names_show_disambiguation_info( item_id )
{	
	// Hide any still showing disambigution boxes
	if ( $$('div.names_disambiguation') != null ) {
		$$('div.names_disambiguation').each(function(disambig_node) {
			disambig_node.hide();
		});
	}
	
	var affiliations = $(item_id).select( '[name = "names_affiliation"]' );
	var fois = $(item_id).select( '[name = "names_foi"]' );
	var publications = $(item_id).select( '[name = "names_publication"]' );
	
	var out = "<strong>Names author information</strong><br/><br/>";
			
	var affiliation_text = "";
	affiliations.each( function(li) {
		var a = li.innerHTML;
		affiliation_text += a + "<br/>";
	});	
	if ( affiliation_text.length < 1) 
	{
		affiliation_text = "None listed";
	}
	out += "<strong><em>Affiliations:</em></strong><br/>" + affiliation_text;
			
	var foi_text = "";
	fois.each( function(li) {
		var f = li.innerHTML;
		foi_text += f + "<br/>";
	});	
	if ( foi_text.length < 1) 
	{
		foi_text = "None listed";
	}
	out += "<br/><strong><em>Fields of Interest:</em></strong><br/>" + foi_text;	
	
	var publications_text = "";
	publications.each( function(li) {
		var p = li.innerHTML;
		publications_text += '"' + p + '"' + "<br/><br/>";
	});	
	if ( publications_text.length < 1) 
	{
		publications_text = "None listed";
	}
	out += "<br/><strong><em>Selected publications:</em></strong><br/>" + publications_text;
	
	if ( $(item_id + '.foi') == undefined ) 
	{	
		var info_div = new Element( 'div', { id: item_id + '.foi', class: 'names_disambiguation' } );
		document.body.appendChild(info_div);
		Element.absolutize(info_div);
		info_div.clonePosition( 
			$(item_id), { offsetLeft: $(item_id).getWidth(), setHeight: false, setWidth: false} 
		);
		info_div.innerHTML = out;
		info_div.setStyle({
			borderStyle: 'dotted',
			borderTopWidth: '1px',
			borderRightWidth: '1px',
			borderBottomWidth: '1px',
			borderLeftWidth: '0px',
			borderColor: 'grey',
			backgroundColor: '#E0E0FF',
			padding: '10px',
			width: '200px',
			height: 'auto'
		});
	}
	else 
	{
		$(item_id + '.foi').show();
	}
}

function names_hide_disambiguation_info( item_id )
{
	if ( $(item_id + '.foi') != null )
		$(item_id + '.foi').hide();
}
