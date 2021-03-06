/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'icomoon\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-popout' : '&#x2b;',
			'icon-search' : '&#xf002;',
			'icon-heart-empty' : '&#xf08a;',
			'icon-star' : '&#xe000;',
			'icon-github' : '&#xe001;',
			'icon-compass' : '&#xe002;',
			'icon-compass-2' : '&#xe003;',
			'icon-star-2' : '&#xe004;',
			'icon-film' : '&#xe005;',
			'icon-monitor' : '&#xe006;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, c, el;
	for (i = 0; ; i += 1) {
		el = els[i];
		if(!el) {
			break;
		}
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};